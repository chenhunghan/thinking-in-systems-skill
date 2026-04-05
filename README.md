# Thinking in Systems

An agent skill that guides users through systems thinking using the framework from Donella Meadows' *Thinking in Systems: A Primer*.

<p align="center">
  <img width="400" height="600" src="https://github.com/user-attachments/assets/554f71f7-7fcf-4b8a-9e26-da6dbd863d92" />
</p>

The skill helps users move beyond surface-level events to see the feedback loops, stocks, flows, and mental models that produce the patterns they observe. It follows a Socratic approach — asking questions before asserting, letting the user build understanding rather than being told.

## What it does

When a user describes a situation — why something keeps happening, why a fix didn't work, how a system behaves — this skill guides them through a structured exploration:

1. **Is it a system?** — Identify elements, interconnections, and purpose
2. **Stocks and flows** — Map what accumulates and what changes
3. **Test the model** — Challenge the model against reality
4. **Why systems work well** — Understand resilience, self-organization, hierarchy
5. **Why systems surprise us** — Recognize boundaries, delays, bounded rationality
6. **System traps** — Identify common structural traps and their opportunities
7. **Leverage points** — Find where small shifts produce big changes

The skill produces structural diagrams (stocks, flows, feedback loops) and behavior-over-time graphs throughout the exploration.

## Install

```bash
npx skills add chenhunghan/thinking-in-systems-skill
```

## Triggers

The skill activates when a user:

- Describes observations about how something behaves
- Asks why something keeps happening
- Wants to understand the structure behind patterns
- Wants to model a system
- Describes recurring patterns or unintended consequences
- Describes situations where fixes don't seem to work
- Focuses too much on events and needs help seeing deeper structure

## Structure

```
thinking-in-systems-skill/        # repo root
  README.md
  LICENSE
  .gitignore
  run-evals.sh                    # eval runner (run from repo root)
  thinking-in-systems/            # skill directory
    SKILL.md                      # Skill definition (frontmatter + instructions)
    phases/                       # Phase reference files read during exploration
      01_is_it_a_system.md
      02_stocks_and_flows.md
      03_test_the_model.md
      04_why_systems_work_well.md
      05_why_systems_surprise_us.md
      06_system_traps.md
      07_leverage_points.md
    evals/                        # Eval definitions
      evals.json                  # 10 task evals, 75 expectations
      trigger-evals.json          # 28 trigger boundary tests
```

## Running evals

Prerequisites: `claude` CLI installed and authenticated.

```bash
# from repo root
chmod +x run-evals.sh
./run-evals.sh
```

Results are written to `thinking-in-systems-workspace/eval-run-N/` (gitignored). Each eval produces a response file and a grade file with pass/fail per expectation.

## License

[MIT](LICENSE)
