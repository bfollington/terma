---
name: implement
description: Use when carrying out a change that is already decided — building the thing rather than choosing it. Concerns staying oriented while the code is in motion — knowing how far from the last checkpoint, noticing when the plan has stopped matching what is being found, and stopping rather than compensating. Trigger on executing a plan or building a defined feature. Do NOT use for deciding what to build, or for restructuring code that already works.
---

# Implement

Implementation is where a plan meets what is actually there, and what is actually there always differs. The skill is not in the typing. It is in noticing the difference early, while it is still cheap.

Slow is smooth and smooth is fast. One change at a time, each cut deliberate, no thrashing.

## Always know where you are

At any moment, be able to answer: what is the last state that was known good, what is being changed right now, and what would show whether it worked.

When those cannot be answered, that is the finding, and it precedes everything else. Work that has drifted from its last verified point is accumulating unverified assumptions, and the cost of discovering a mistake grows with every one added.

The distance to the last checkpoint is the single most useful thing to track. Keep it short. A change verified in three places is three cheap failures; the same change verified once at the end is one expensive one.

## Build outward from what holds

Types and the shape of the data first — they are the design, and everything downstream reads them. Then the pure logic that moves between them, which can be checked with literals. Then the effects, the integration, the parts that need a real environment to say anything.

This is not ceremony. It is ordering by feedback speed: establish the things that can be checked in a second before the things that need a deploy.

Make it work, make it right, make it fast, and be honest about which phase is current. *Work* is the light turning on — sketched, plugged together, ugly. *Right* is tests pressing on it, gaps closed, names reconsidered now the shape is known. *Fast* is last, measured rather than guessed, and usually never needed.

Confusing the phases is what produces both the polished thing that turns out to be the wrong thing, and the sprawling thing that was never made right.

## Let structure emerge, but do not let it go

Do not abstract upfront into a system anticipating needs nobody has stated. Do not write everything in one file and defer all organisation to the end.

Split modules when they strain — in passing, two at a time, while the reason is fresh. Watch the vocabulary of the codebase develop and let boundaries appear where the code keeps asking for them. Not rigidity, not paranoia; just never letting it get out of hand.

## When the ground moves

The plan will be wrong somewhere. It was written with less information than is now available. That is the normal case, not a failure.

What matters is what happens at that moment. The instinct is to compensate — patch the difference, keep going, absorb the mismatch quietly. That is how a small wrong assumption becomes a structural one, and how the finished thing ends up shaped by an error nobody remembers making.

Stop instead, and say plainly: this is not going to scale, or it is no longer clear why this direction is right, or what was found contradicts what the plan assumed. Being confused is information. Concealing it under further work destroys the information and keeps the confusion.

Two heads solve it faster. Regrouping early is cheap; regrouping after three days of compensation is not.

## Leave it collidable

A decision made and not encoded is a decision that will be made differently later, because nothing is there to hit.

Where something was resolved — an invariant chosen, an ambiguity settled, a case ruled out — make it something the next change runs into: a type that will not hold the wrong state, a test that states the rule rather than the behaviour, a validator with the reason written beside it.

A test that would still pass once the rule is violated is not stating the rule.

## Failure modes

- **Compensating.** Discovering the plan was wrong and working around it silently.
- **Long unverified stretches.** Many changes since anything was checked, so a failure now has many possible causes.
- **Skipping to *right*.** Polishing something before knowing it is the right thing.
- **Scope drift.** Fixing adjacent things along the way, so the change can no longer be reviewed or reverted as a unit.
- **Deferred organisation.** Everything in one place, to be sorted later, which is never.
- **Speculative structure.** Layers built for requirements nobody has stated.
- **Silent confusion.** Continuing to produce code while no longer knowing why it is right.
