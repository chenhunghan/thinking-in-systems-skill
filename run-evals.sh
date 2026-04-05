#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash run-evals.sh                       # run all (auto-detects claude or codex)
#   bash run-evals.sh --triggers-only       # trigger evals only
#   bash run-evals.sh --tasks-only          # task evals only
#   bash run-evals.sh --task 7              # single task eval by id
#   bash run-evals.sh --trigger 5           # single trigger eval by index (0-based)
#   CLI=codex bash run-evals.sh             # force codex backend
#   CLI=claude bash run-evals.sh            # force claude backend

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

RUN_TASKS=true
RUN_TRIGGERS=true
SINGLE_TASK=""
SINGLE_TRIGGER=""
case "${1:-}" in
  --triggers-only) RUN_TASKS=false ;;
  --tasks-only) RUN_TRIGGERS=false ;;
  --task) RUN_TRIGGERS=false; SINGLE_TASK="${2:?missing eval id}" ;;
  --trigger) RUN_TASKS=false; SINGLE_TRIGGER="${2:?missing trigger index}" ;;
esac

# Auto-detect CLI backend
if [ -z "${CLI:-}" ]; then
  if command -v claude >/dev/null 2>&1; then
    CLI=claude
  elif command -v codex >/dev/null 2>&1; then
    CLI=codex
  else
    echo "Error: neither 'claude' nor 'codex' CLI found. Install one or set CLI=<path>." >&2
    exit 1
  fi
fi
echo "Using CLI: $CLI"

# Model selection per backend
case "$CLI" in
  claude|*/claude)
    MODEL_GENERATE="${MODEL_GENERATE:-sonnet}"
    MODEL_GRADE="${MODEL_GRADE:-haiku}"
    ;;
  codex|*/codex)
    MODEL_GENERATE="${MODEL_GENERATE:-}"
    MODEL_GRADE="${MODEL_GRADE:-}"
    ;;
  *)
    MODEL_GENERATE="${MODEL_GENERATE:-}"
    MODEL_GRADE="${MODEL_GRADE:-}"
    ;;
esac
echo "Models: generate=$MODEL_GENERATE grade=$MODEL_GRADE"

# CLI-agnostic prompt runner
# Usage: run_prompt <model> <system_prompt> <user_prompt>
run_prompt() {
  local model="$1" system="$2" prompt="$3"
  case "$CLI" in
    claude|*/claude)
      local claude_args=(-p --model "$model" --max-turns 5)
      claude_args+=(--disallowedTools Bash Read Write Edit Glob Grep WebFetch Task TodoWrite)
      [ -n "$system" ] && claude_args+=(--system-prompt "$system")
      claude "${claude_args[@]}" -- "$prompt" 2>/dev/null
      ;;
    codex|*/codex)
      local tmpout codex_args
      tmpout=$(mktemp)
      codex_args=(exec --sandbox read-only -o "$tmpout")
      [ -n "$model" ] && codex_args+=(-m "$model")
      echo "$system" | codex "${codex_args[@]}" "$prompt" >/dev/null 2>&1 || true
      cat "$tmpout"
      rm -f "$tmpout"
      ;;
    *)
      echo "Error: unsupported CLI '$CLI'" >&2
      return 1
      ;;
  esac
}

SKILL_DIR="thinking-in-systems"
SKILL_FILE="$SKILL_DIR/SKILL.md"
EVALS_FILE="$SKILL_DIR/evals/evals.json"
TRIGGERS_FILE="$SKILL_DIR/evals/trigger-evals.json"

# Find the next available run directory
RUN_NUM=1
while [ -d "thinking-in-systems-workspace/eval-run-$RUN_NUM" ]; do
  RUN_NUM=$((RUN_NUM + 1))
done
OUT_DIR="thinking-in-systems-workspace/eval-run-$RUN_NUM"
RESULTS_FILE="$OUT_DIR/results.json"
echo "Output directory: $OUT_DIR"

mkdir -p "$OUT_DIR"

SKILL_CONTENT=$(<"$SKILL_FILE")

# Load phase files as references
REFS_CONTENT=""
PHASES_DIR="$SKILL_DIR/phases"
if [ -d "$PHASES_DIR" ]; then
  for ref_file in "$PHASES_DIR"/*.md; do
    [ -f "$ref_file" ] || continue
    REFS_CONTENT+="
<reference path=\"${ref_file#$SKILL_DIR/}\">
$(<"$ref_file")
</reference>
"
  done
fi

SYSTEM_PROMPT="You are evaluating a systems thinking skill. The skill instructs an AI agent to guide users through understanding system structure using Donella Meadows' framework from \"Thinking in Systems: A Primer.\"

Here is the full SKILL.md content the agent would receive:

<skill>
$SKILL_CONTENT
</skill>
${REFS_CONTENT:+
The skill also has these phase reference files. Each phase file is loaded when the agent enters that phase:
$REFS_CONTENT}
You are role-playing as the agent that has loaded this skill. When given a user prompt, respond EXACTLY as the agent would: guide the user through the systems thinking exploration following the phases and posture described in the skill.

Since this is a single-turn eval of a multi-turn skill, demonstrate the FULL exploration in one response. Walk through each relevant phase: ask the questions you would ask, then proceed as if the user provided reasonable answers. Produce any diagrams the skill instructs you to create. Follow the phase ordering described in the skill.

IMPORTANT: You must follow every instruction in the skill including Posture, Core Definitions, Phases, and Diagram requirements. Show your work through all phases — do not skip phases or collapse them into a summary. Do NOT use any tools — respond only with text."

echo '{"task_evals":[],"trigger_evals":[]}' > "$RESULTS_FILE"

TASK_PASS_TOTAL=0
TASK_FAIL_TOTAL=0
TASK_EVAL_COUNT=0

if [ "$RUN_TASKS" = true ]; then
echo "=== RUNNING TASK-LEVEL EVALS ==="
EVAL_COUNT=$(jq '.evals | length' "$EVALS_FILE")

for i in $(seq 0 $((EVAL_COUNT - 1))); do
  EVAL_ID=$(jq -r ".evals[$i].id" "$EVALS_FILE")
  [ -n "$SINGLE_TASK" ] && [ "$EVAL_ID" != "$SINGLE_TASK" ] && continue
  PROMPT=$(jq -r ".evals[$i].prompt" "$EVALS_FILE")
  EXPECTATIONS=$(jq -r ".evals[$i].expectations[] | \"- \" + ." "$EVALS_FILE")

  echo ""
  echo "--- Eval #$EVAL_ID: ${PROMPT:0:80}..."

  RESPONSE=$(run_prompt "$MODEL_GENERATE" "$SYSTEM_PROMPT" "$PROMPT") || { echo "  [ERROR] generate failed"; continue; }

  echo "$RESPONSE" > "$OUT_DIR/eval-${EVAL_ID}-response.txt"

  # Grade the response against expectations
  GRADE_PROMPT="Grade this AI agent response against the expected behaviors. The agent is supposed to be a systems thinking companion guiding users through Donella Meadows' framework. For each expectation, answer PASS or FAIL with a brief reason.

Response to grade:
<response>
$RESPONSE
</response>

Expectations:
$EXPECTATIONS

Output format — one line per expectation, nothing else:
PASS|FAIL: <expectation summary> — <reason>"

  GRADE=$(run_prompt "$MODEL_GRADE" "" "$GRADE_PROMPT") || { echo "  [ERROR] grading failed"; continue; }

  echo "$GRADE" > "$OUT_DIR/eval-${EVAL_ID}-grade.txt"

  PASS_COUNT=$(echo "$GRADE" | grep -c "^PASS" || true)
  FAIL_COUNT=$(echo "$GRADE" | grep -c "^FAIL" || true)
  TOTAL=$((PASS_COUNT + FAIL_COUNT))
  TASK_PASS_TOTAL=$((TASK_PASS_TOTAL + PASS_COUNT))
  TASK_FAIL_TOTAL=$((TASK_FAIL_TOTAL + FAIL_COUNT))
  TASK_EVAL_COUNT=$((TASK_EVAL_COUNT + 1))

  if [ "$FAIL_COUNT" -eq 0 ] && [ "$TOTAL" -gt 0 ]; then
    echo "  PASS ($PASS_COUNT/$TOTAL expectations)"
  else
    echo "  PARTIAL ($PASS_COUNT/$TOTAL expectations)"
    echo "$GRADE" | grep "^FAIL" | sed 's/^/    /'
  fi
done

echo ""
echo "--- Task Eval Summary ---"
echo "  Evals run: $TASK_EVAL_COUNT"
echo "  Total expectations: $((TASK_PASS_TOTAL + TASK_FAIL_TOTAL))"
echo "  Passed: $TASK_PASS_TOTAL"
echo "  Failed: $TASK_FAIL_TOTAL"
if [ $((TASK_PASS_TOTAL + TASK_FAIL_TOTAL)) -gt 0 ]; then
  PASS_RATE=$(echo "scale=1; $TASK_PASS_TOTAL * 100 / ($TASK_PASS_TOTAL + $TASK_FAIL_TOTAL)" | bc)
  echo "  Pass rate: ${PASS_RATE}%"
fi
fi

TRIGGER_PASS=0
TRIGGER_FAIL=0

if [ "$RUN_TRIGGERS" = true ]; then
echo ""
echo "=== RUNNING TRIGGER-LEVEL EVALS ==="
TRIGGER_COUNT=$(jq 'length' "$TRIGGERS_FILE")

for i in $(seq 0 $((TRIGGER_COUNT - 1))); do
  [ -n "$SINGLE_TRIGGER" ] && [ "$i" != "$SINGLE_TRIGGER" ] && continue
  QUERY=$(jq -r ".[$i].query" "$TRIGGERS_FILE")
  EXPECTED=$(jq -r ".[$i].should_trigger" "$TRIGGERS_FILE")

  TRIGGER_PROMPT="Given this skill description (from SKILL.md frontmatter):

description: $(head -4 "$SKILL_FILE" | grep 'description:' | sed 's/^description: //')

Should this skill activate for the following user query? Answer ONLY 'yes' or 'no'.

Query: \"$QUERY\""

  ANSWER=$(run_prompt "$MODEL_GRADE" "" "$TRIGGER_PROMPT") || { echo "  [ERROR] trigger eval failed for: ${QUERY:0:50}"; continue; }

  ANSWER_LOWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

  if [ "$EXPECTED" = "true" ]; then
    EXPECTED_ANSWER="yes"
  else
    EXPECTED_ANSWER="no"
  fi

  if [[ "$ANSWER_LOWER" == *"$EXPECTED_ANSWER"* ]]; then
    TRIGGER_PASS=$((TRIGGER_PASS + 1))
    STATUS="PASS"
  else
    TRIGGER_FAIL=$((TRIGGER_FAIL + 1))
    STATUS="FAIL (got: $ANSWER_LOWER, expected: $EXPECTED_ANSWER)"
  fi

  echo "  [$STATUS] ${QUERY:0:80}..."
done

echo ""
echo "=== TRIGGER SUMMARY ==="
echo "Trigger evals: $TRIGGER_PASS pass, $TRIGGER_FAIL fail out of $TRIGGER_COUNT"
fi

echo ""
echo "=== OVERALL ==="
echo "Full results in: $OUT_DIR/"
