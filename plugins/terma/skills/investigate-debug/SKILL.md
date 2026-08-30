---
name: investigate-debug
description: Use when something is wrong and the cause is not yet known — failures, regressions, flaky behaviour, performance problems, incidents, or a user report that does not match what the code appears to do. Concerns holding the difference between what is observed and what is believed, and spending each action on the question that most divides the possibilities. Trigger on any debugging or investigation where the answer is not already obvious. Do NOT use when the cause is already known and only the fix remains.
---

# Investigate & Debug

Debugging is the discipline of not knowing yet.

The failure is not in the code. It is in the difference between what the system does and what is believed about it, and that belief is wrong somewhere specific. The work is finding where — which means the central act is not fixing, it is *distinguishing*.

Every action should divide the possibilities. An action that cannot come out two ways is not an experiment; it is reassurance.

## Observation is not inference

Keep these apart, in writing, always:

- **Observed** — what was actually seen, with where it came from. The log line, the exit code, the response body.
- **Inferred** — what is concluded from it. Note the reasoning; that is what turns out to be wrong.
- **Assumed** — carried unchecked from before the investigation started.

Nearly every long debugging session contains a moment where an inference was recorded as an observation, and hours were then spent inside a world that does not exist. The assumptions are the dangerous category precisely because they are not felt as beliefs — they are felt as background.

When stuck for a while, the answer is almost always in the assumed list. Go back and check the thing so obvious it was never checked.

## Two hypotheses, minimum

One hypothesis is not an investigation. It is a hunch being confirmed, and every observation will be read as supporting it.

Hold at least two live explanations, and prefer the experiment that *separates* them over the one that would confirm the favourite. Ask of each: what would I see if this were true, that I would *not* see if the other were? That question is the whole method — where the predictions differ is where the information is, and if two hypotheses predict the same thing, testing there is wasted.

State the prediction before running the thing. A prediction made afterwards accommodates whatever happened.

## Bisect the space, not the code

The instinct is to start where the error appeared. The error appeared at the end; the cause is upstream, and often in a different subsystem.

Better to halve the possibility space. Does it happen with the network stubbed? With one record instead of ten thousand? On the previous commit? In a fresh environment? Each answer eliminates a region — and it does not matter whether the answer is yes or no, which is how to tell it was a good question.

Reproduce it first if reproduction is at all possible. A failure that can be summoned on demand is nearly solved; one that must be waited for will consume days. Making the reproduction smaller and faster is usually the highest-value work available, even when it feels like a detour from finding the cause.

For a regression, bisect history. It is dull, mechanical, and beats reasoning almost every time.

## Negative results are results

The eliminated hypothesis is progress, and the note that says *it is not the cache, verified by X* is what stops the same avenue being explored again in two hours, or by whoever picks this up next.

An investigation that records only the path to the answer discards most of what it learned.

## Understand before fixing

A fix that works but whose mechanism is not understood is not a fix. It may have moved the symptom, changed the timing, or masked one of two causes.

Before changing anything, be able to say: this input, through this path, produces this wrong result, *because* — and have the because be a mechanism, not a correlation. Then the fix has a target, and it is possible to say what else the bug was affecting that nobody had noticed.

The test to write is the one that fails now for the right reason and would fail again if this specific cause returned. Not a test that the symptom is gone — those pass for many reasons.

Then check whether the cause has siblings. Bugs of a kind rarely occur once.

## Notes that survive

Investigations outlast the context holding them — through compaction, interruption, handover, or a day off.

Keep a running note from the start, weighted to what is expensive to re-derive: what is established and how, what has been ruled out and by what, the current leading explanation, and the next experiment that would divide the space. Not a transcript. The commands that produced nothing are the least valuable thing to preserve; the conclusions and the eliminations are the most.

Write it so someone arriving cold could take the next action without repeating the last twenty.

## Failure modes

- **Fixing the symptom.** The exception is gone. Whatever produced it still runs.
- **One hypothesis.** Confirmation with extra steps.
- **Random perturbation.** Changing things to see what happens, without a prediction. When it starts working, nothing has been learned, and it will return.
- **Inference recorded as observation.** The most costly single error available.
- **Starting at the error site.** That is where it surfaced, not where it began.
- **Not reproducing first.** Every subsequent result becomes ambiguous.
- **Trusting the story over the system.** The documentation, the comment, and the variable name all describe intent. The behaviour is the fact.
- **Silent dead ends.** Ruling something out and not writing it down, then ruling it out again later.
