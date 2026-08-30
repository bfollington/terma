---
name: surface-forks
description: Use during any implementation, design, refactor, or debugging task, in any language or codebase. Before changing anything that touches an existing domain concept, rule, type, or invariant, find what the change collides with and name the routes through it — instead of letting the first workable route settle the question silently. Trigger on any request to build, change, model, extend, or restructure, including small changes and including when the user says nothing about design. Do NOT use for purely additive isolated code, pure explanation, or review with no change proposed.
---

# Surface Forks

Systems go wrong where a change had implications past the ones considered. Not a bad decision — an unexamined reach. The change was correct locally and quietly contradicted something the system already committed to elsewhere.

One operation: **find the collisions before implementing, then name the routes through them.**

## What is not a fork

- **Preference.** Button left or right. Nothing downstream depends on it.
- **Convergent ordering.** A before B or B before A, same end state, no residue.
- **Isolated addition.** New code that names no existing concept and no existing rule reads.

These are most changes. Pick and continue silently. A skill that flags everything gets turned off, and that is a worse outcome than never flagging anything.

## The test: search, don't forecast

Do not estimate how hard something would be to undo — that is knowable only after knowing the implications, which is the unknown. Instead, before changing anything that names a domain concept, locate every place that concept is already committed to: definitions, constructors, validators, matches over its cases, serialisation, tests that state rules about it.

A fork exists when the change would do any of these to what was found:

- **Duplicate** — the concept already exists under another name, and a second spelling is about to appear
- **Split** — one concept becomes two that must now be kept in agreement by hand, and will drift
- **Contradict** — two places will now assert different things about the same subject
- **Widen or narrow an invariant** — a rule that held for all values will hold for some, or a constraint others rely on is about to loosen

If nothing was found, or nothing collides, there is no fork. Proceed.

## The move

At the point the collision is found — before implementing — report in a few lines:

- **What it collides with**, by name and location. Concrete sites, not categories.
- **The routes.** There is usually more than one way to the same outcome, and they disturb different things. Give each route and what it touches.
- **Which route is being taken**, and what it leaves inconsistent.

Then proceed on that route. Do not block. Stop and ask only when every route contradicts something already asserted, or when the collision reveals the request itself is ambiguous.

```
Collides with: Order.status is matched exhaustively in 4 places, and
`isRefundable` in billing/rules assumes Placed implies a payment record.

Routes:
  A. New status case — touches all 4 matches, breaks the isRefundable assumption.
  B. Separate Refund entity — nothing existing changes, adds a second lifecycle to keep in sync.
  C. Field on Order — nothing breaks now, and existing orders carry a null that means
     "not applicable" rather than "unknown".

Taking B: the isRefundable rule stays true as written. Cost is two lifecycles.
```

## Encode the resolution

A collision resolved and not written down will be re-resolved differently later, because nothing is there to hit. Make the resolution something a future change collides with loudly:

- make the contradicted state unrepresentable (types, smart constructors, exhaustive matches with no default branch)
- a property or invariant test that states the rule rather than the behaviour — if it would still pass once the rule is violated, it is not stating the rule
- a validator called at the boundary, with the invariant written in prose beside it

This is what tests are for here: not confirming the code does what it does, but ensuring the next change hits something.

## Calibration

If the reported collisions are ones the user already had in mind, the search is too shallow — it is restating the obvious rather than finding reach. Roughly one report in four should name a site they had forgotten. If none do, widen the search before flagging anything.

## Failure modes

- **Category collisions.** "This might affect the order system." Useless. Name files, functions, call sites.
- **Retrospective disclosure.** Finding the collision after implementing. Now it is a summary, not a fork.
- **Single-route framing.** Presenting one option as the only path. If only one route was found, look again — usually the second route is the one that touches nothing.
- **Inflation.** Dressing an isolated addition as a collision to appear thorough.
- **Asking instead of routing.** Handing the choice back with no recommendation.
