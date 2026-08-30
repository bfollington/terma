---
name: convergent-planning
description: Use when planning any multi-step change, or when a plan already exists and is about to be executed. A plan is a sequence of ambiguity collapses, not a list of tasks — each step must end at a state that can be checked, and the checks must be capable of failing. Trigger on requests to plan, sequence, break down, stage, or scope work, and on any plan that reads as a list of things to do. Do NOT use for single-step changes, or where the outcome is already known and only the typing remains.
---

# Convergent Planning

A plan is not a list of things to do. It is a sequence of points at which the number of ways the work could still go down gets smaller.

Most plans fail not because a step was wrong but because nothing between the steps was capable of saying so. The work proceeds, the ambiguity is carried forward untouched, and it resolves at the end — all at once, in whatever direction it happens to fall.

One operation: **find where the plan is uncertain, and put a checkable state at each place the uncertainty ends.**

## What the steps are made of

A step is not a unit of effort. It is a unit of *ambiguity removed*. Ask of each one: what was unknown before this, and known after?

If the answer is "nothing" — the step is typing. Merge it into its neighbour. Steps that only move work forward without resolving anything belong inside a checkpoint, not between them.

If the answer is "several things" — the step is too big. Not because it is long, but because when it fails, it will not say which of the several things was wrong.

The good size is one question per step. Then a failure is a diagnosis.

## The checkpoint test

At the end of each step there is a state. Ask: **what would I run, read, or look at to know this step landed — and could that check fail?**

A check that cannot fail is not a check:

- "the code compiles" — it compiled before, for reasons unrelated to this step
- "the tests pass" — if no test in the suite makes an assertion this step could break, they passed vacuously
- "it looks right" — if it looked wrong, would it be noticed?

The check must be tied to the *specific* ambiguity the step collapsed. A step that resolves "does this API return the shape we assumed" is checked by reading a real response, not by the build succeeding.

Where no such check exists, that is the finding. Say so: the step is unverifiable, and everything after it is built on an assumption. Either find a check, or move the step earlier so it fails cheaply.

## Order by uncertainty, not by dependency

The instinct is to order steps by what depends on what. That yields a plan that is correct and expensive: the assumption that kills the design gets tested last, after everything built on it.

Order by where the plan is most likely to be wrong.

The step that would most change the rest of the plan if it came out badly goes as early as it can be made to go. Sometimes this means a throwaway probe before real work begins — a hardcoded round-trip, one request against the real service, a spike that gets deleted. Cheap and disposable, and it collapses more ambiguity than the next three steps combined.

Foundation before scaffolding before cladding — but among the things that could be next, take the one most able to prove the plan wrong.

## Naming what is not known

A plan written entirely in confident declaratives is concealing something. Every plan has unknowns; the question is whether they are on the page.

Separate them:

- **Known** — established, and where it was established. Not "presumably".
- **Assumed** — being proceeded on without checking, with a note on what breaks if false.
- **Unknown** — genuinely open, with the step that will close it.

An assumption with no step that would surface it being false is the thing that sinks plans. Find those first; they are usually stated as facts.

## The shape of a plan

```
Goal: sessions survive a restart.

Unknown → the store's write path under concurrent updates. Everything
downstream assumes last-write-wins; if it is not, the design changes.

1. Probe: two concurrent writes to one key, read back.        [collapses the unknown]
   Check: read returns one of the two writes, not a merge or an error.
   If it errors → the whole approach changes; stop and re-plan.

2. Session type + serialisation round-trip.                   [collapses "is it representable"]
   Check: property test — arbitrary session survives write/read identity.

3. Wire into the request path behind a flag.                  [collapses "does it fit"]
   Check: restart the process mid-session; the session is still there.
   This is the first check that tests the actual goal.

Assumed: sessions are small enough that size limits never bind.
   If false → surfaces at step 3 as a write error, not silently.
```

Three steps, three questions, each check able to fail, and the riskiest thing first.

## After a step fails

A failed check is the plan working. The step bounded which question was open, so the failure answers it.

Do not repair forward past a failed check. The remaining steps were built on what the check just disproved — re-plan from the new knowledge, and the plan will usually get shorter, because a real unknown just became known.

## Failure modes

- **Task lists.** Steps that name activities ("update the handler", "add tests") rather than states reached. No question, no check.
- **Vacuous checks.** A verification that would pass whether or not the step worked. Worse than none — it certifies.
- **Deferred risk.** The hard unknown scheduled last, so the plan is confident right up until it collapses.
- **Assumptions as facts.** "The API returns X" with no note of how that was established.
- **Plans that only converge at the end.** One long build, then verification. That is one checkpoint, however many steps were listed.
- **Padding.** Steps added for completeness that resolve nothing. They dilute the plan and hide the steps that matter.
