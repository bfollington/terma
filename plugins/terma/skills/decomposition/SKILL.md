---
name: decomposition
description: Use when deciding where the boundaries in a system go — what becomes a module, a service, a process, a package; what gets extracted, merged, or left duplicated. Concerns which cut isolates change rather than which cut looks tidy. Trigger on refactors, restructuring, "this file is too big", extracting shared code, and designing the shape of something new. Do NOT use for local code style, or for naming and modelling the domain itself.
---

# Decomposition

Modularity is not about reuse. It is about isolating change — so that being wrong about one thing costs one thing.

Every boundary is a bet that what is on either side will change at different rates, for different reasons. A good cut means a mistake stays local and can be deleted. A bad cut means a mistake is load-bearing, spread across nine call sites, and the fix is a migration.

Ask of any boundary: **when this turns out to be wrong, what does it cost to remove?**

## Cut by rate of change

The instinct is to group things that look alike. Look-alike grouping produces a `utils` module containing business logic, and a `models` directory whose contents change for six unrelated reasons.

Group what changes *together*, for the *same reason*. Volatile apart from stable. Policy apart from mechanism — the rule about what should happen apart from the machinery of making it happen. Hard problems isolated so the hardness has one address.

The clearest signal a boundary is wrong: a single feature request keeps requiring edits on both sides of it, every time.

## Pull, transform, push

The useful unit is a process: acquire data, turn it into other data, emit it. The three phases have opposite natures and should not be mixed.

*Pull* and *push* meet the world. They fail, time out, arrive malformed, and can only be honestly tested against something real. Keep them thin and defensive, and hold low expectations of anything on the other side.

*Transform* is where the decisions live. Pure, testable with literals, and it should be the large part. Business logic that drifts into the operational phases becomes untestable by accident.

Effects described as data, then performed at the edge, stay inspectable — a decision you can print is a decision you can test. The boundary between phases is where invariants get enforced: strong at the edges means the interior can be understood on its own.

## Three things a transform can do

- **Accrete** — add information. Now more is known than before.
- **Reduce** — discard differences that do not matter. This is what abstraction actually is.
- **Reshape** — reorganise to enable the other two. Not abstraction, though it is often mistaken for it.

Most code that feels like it is abstracting is reshaping: moving the same information into a different arrangement, adding a layer and no leverage. Real abstraction throws something away on purpose.

To abstract is to treat different things as the same. Whether that is right depends entirely on context — an abstraction has no quality in isolation, only a fit. When judging one, ask what it discards, and whether anyone downstream needs what was discarded.

## Layer for different users

Build the flexible, clumsy, complete thing. Then build the pleasant thing on top of it.

One API cannot serve both the common workflow and the unusual demand without becoming a configuration language. Two layers can: the lower one is fully capable and nobody enjoys using it, the upper one is a joy and does eighty percent. Neither compromises the other.

Wrap third-party libraries at a boundary you own, even thinly. The wrapper is what makes replacement possible later, and it is the only chance to have the vocabulary be yours instead of theirs.

## Sometimes one big lump

Not everything should be decomposed. Business logic is irreducibly messy, and premature carving spreads that mess across modules where it becomes structural.

One big mistake is easier to delete than eighteen small entangled ones. When the shape is genuinely unknown, write it in one place, let it be ugly, and let the seams appear under real use. They will — and they will be somewhere other than where they were predicted.

The failure to avoid is not "this file is long". It is "this file has three subjects and every change touches all three".

## Warning signs

- an API with many consumers and no versioning story
- business rules living in a utility module
- a shared abstraction extracted on the second use
- deep dependency chains where a leaf change ripples to the root
- modules that must be edited in lockstep
- anything that would take a migration to remove

Each of these is a boundary that has stopped isolating change and started transmitting it.

## Deletion is the measure

The value of a design is how cheaply it can be wrong.

Code is a liability carried, not an asset accumulated. Deleted code is progress. A component that can be replaced without touching its neighbours is a good component, whatever its internals look like — and legacy code that stays out of the way is good code, however old.

Write it assuming it is wrong somewhere, and arrange things so that finding out is cheap.

## Failure modes

- **Reuse-driven boundaries.** Extracting because two things look similar, not because they change together.
- **Reshaping called abstraction.** A new layer, the same information, no leverage gained.
- **Utils as a dumping ground.** A module with no subject accumulates the code nobody found a home for.
- **Decomposing an unknown shape.** Carving before real use has shown where the seams are.
- **Boundaries with no owner.** A shared thing everything reaches into, which nobody can change.
- **Symmetric splitting.** One file into three because three is tidy, not because there were three subjects.
