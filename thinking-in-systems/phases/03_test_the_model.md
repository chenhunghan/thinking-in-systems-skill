# Phase 3: Test the Model

A model is only useful if it reflects reality well enough to think with. Before relying on the structure you've mapped, interrogate it. It's tempting to fall in love with an elegant model — resist that. The goal is accuracy, not elegance.

## Three validation questions

### 1. Are the driving factors likely to unfold this way?

Look at the flows and forces you've identified. Are they realistic? Are you assuming something will keep growing that might plateau? Are you assuming stability where disruption is likely? Are the rates of flow plausible?

Ask the user:
- "In the real world, do these flows actually behave the way we've drawn them?"
- "What could change that?"
- "Are we assuming any flow stays constant that might actually vary?"

### 2. If they did, would the system react this way?

Follow the logic of the model forward. If the flows behave as mapped, do the feedback loops produce the behavior you actually observe?

Compare the model's predicted behavior-over-time to the actual behavior-over-time:
- If the model says the stock should be rising but in reality it's flat → something is missing. An unidentified outflow? A balancing loop you haven't found? A delay?
- If the model says the system should oscillate but in reality it's stable → maybe a buffer is absorbing the variation, or a loop you mapped isn't actually active.
- If the model matches reality on the main trends but misses timing → delays are probably different than assumed.

Ask: "Does our model produce the behavior-over-time pattern we actually see? Where does it diverge?"

### 3. What is driving the driving factors?

This is the question that expands the model. Every flow has a cause. Every cause has a cause.

You've drawn a boundary — what's outside it that matters? Ask:
- "We said X drives this flow. But what drives X?"
- "Is there something outside our current boundary that we need to bring in?"
- "If we zoom out one level, what do we see?"

This question often reveals that the system is larger than initially scoped. That's OK — expand the boundary if needed, but consciously and deliberately. Every expansion adds complexity. The goal is the **simplest model that explains the behavior you observe** — no simpler, no more complex.

## Signs your model needs work

- The model predicts behavior that doesn't match reality
- You can't explain a major observed pattern with the current structure
- Key actors in the system would disagree with how you've represented their part
- The model has no feedback loops (almost all real systems have them)
- The model has no delays (almost all real systems have them)
- Everything in the model is linear and proportional (real systems are full of nonlinearities)

## Signs your model is good enough (for now)

- It reproduces the major behavior-over-time patterns you observe
- It explains why past interventions succeeded or failed
- People who live in the system recognize the structure when you show it to them
- It reveals at least one thing that wasn't obvious before you built it
- You can identify where the model is weakest and what would break it

"Good enough" is not "perfect." Perfect models don't exist. The model is a thinking tool — the question is whether it helps you think better about this system than you could without it.

## Moving forward

When the model feels solid — not perfect, but solid enough that it reproduces the observed behavior and you understand its limitations — move to Phase 4 to understand why the system works well, before looking at what's broken.
