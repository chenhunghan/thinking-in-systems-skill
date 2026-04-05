# Phase 2: Stocks and Flows

Stocks and flows are the foundation of system dynamics. If Phase 1 told you *what* the system is, this phase tells you *how it moves*.

## Identifying stocks

A stock is the memory of the history of changing flows within the system. It's what has accumulated — what you can see, count, or measure at a given moment.

Ask:
- "What accumulates in this system?"
- "What can you measure or count right now, at this moment?"
- "What has built up — or depleted — over time?"
- "What would you see if you took a snapshot?"

Examples: water in a reservoir, money in an account, trust in a relationship, skill in a workforce, inventory in a warehouse, reputation of a brand, morale on a team, pollution in a lake.

Stocks change slowly because they're the accumulation of flows over time. This is why systems have **memory** (the stock carries the past) and **momentum** (the stock resists sudden change). You can't drain a bathtub instantly. You can't build trust overnight. This slowness is not a bug — it's a fundamental property.

## Identifying flows

For each stock, ask:
- "What makes this increase?" (inflows)
- "What makes this decrease?" (outflows)
- "How fast do these flows move?"
- "Can the flows be controlled? By whom? Based on what information?"

A key insight: **you can only change a stock by changing its flows.** There is no instantaneous way to fill a bathtub except through the faucet. This means understanding flows is understanding the only levers that actually move stocks.

Also note: multiple stocks can share flows. An outflow from one stock may be the inflow to another. Money spent on training (outflow from budget) becomes skill (inflow to workforce capability).

## Feedback loops

Once stocks and flows are mapped, trace the feedback loops — these are the engines of system behavior.

Start at a stock. Follow what happens when it changes:
- The stock changes → does someone notice?
- Does that observation lead to a decision or action?
- Does that action affect a flow (inflow or outflow)?
- Does that flow change lead back to the original stock or to another stock?

If the chain closes — you've found a feedback loop.

**Balancing loop (B):** The feedback opposes the change. Stock rises → something pushes it back down. Stock drops → something pushes it back up. These are goal-seeking and stabilizing. The thermostat that turns on heating when temperature drops. The hunger that drives you to eat when energy is low.

**Reinforcing loop (R):** The feedback amplifies the change. Stock rises → something pushes it higher. Stock falls → something pushes it lower. These drive growth and collapse. Compound interest. Viral spread. Erosion of trust leading to more conflict leading to more erosion.

**Which loops dominate?** In any system, multiple loops exist simultaneously. The behavior you observe comes from whichever loop is currently dominant. Dominance can shift over time — a system that was growing (reinforcing loop dominant) can hit a limit and start oscillating (balancing loop takes over). This shift is often the moment the system surprises people.

## Two diagrams to produce

### 1. Structural diagram

Show each stock as a container or box. Show inflows and outflows as arrows with labels. Label feedback loops as (R) or (B). Draw the system boundary explicitly — what's inside the model, what's outside. This is the architecture of the system.

### 2. Behavior-over-time graph

For each important stock, sketch how it changes over time. Put time on the x-axis, stock level on the y-axis.

This graph is critical — it's what moves thinking from events to patterns:
- Instead of "we missed our target last quarter" → see "performance has been declining for two years"
- Instead of "traffic was bad today" → see "congestion has been growing steadily since the highway opened"
- Instead of "morale is low" → see "morale spikes after each team event then decays back to a lower baseline each time"

The behavior-over-time graph reveals:
- **Steady trends** — reinforcing loops at work (growth or decline)
- **Oscillations** — balancing loops with delays (overshoot and correction)
- **S-curves** — reinforcing loop hitting a balancing loop (growth slowing as limits are reached)
- **Overshoot and collapse** — reinforcing loop running past a limit before delayed feedback kicks in

## Moving forward

You now have a structural model with stocks, flows, and feedback loops, plus a picture of how the system behaves over time. Before trusting this model, test it — move to Phase 3.
