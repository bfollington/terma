---
name: research
description: Use when a specific question must be answered before work can sensibly proceed — how something currently works, whether an approach is viable, what already exists, what a change would touch. Concerns answering the question that was actually asked, at a confidence level stated honestly. Trigger on investigation requests and on discovering that a decision rests on something unverified. Do NOT use for building a general model of an unfamiliar codebase — that is orient.
---

# Research

Research is answering a question. Everything else it produces is overhead.

The failure is almost never insufficient reading. It is answering a nearby question — easier, adjacent, and not the one on which anything depends.

## Sharpen the question first

Before looking anywhere, ask what turns on the answer. Which decision is waiting? What would change if the answer came back the other way?

If nothing changes either way, the question is not worth researching. If the answer would change everything, that is the thing to establish first and cheaply.

Most questions arrive vague — "how does auth work" — and the vague version has no end condition, so research expands to fill available time. The sharp version is what is actually needed: *does the session survive a restart, and where is that decided?* That has an answer, and a point at which it is reached.

## The code is the fact

Sources rank by how closely they describe what actually runs:

**The code** is what happens. **The tests** are what someone believed, checked. **The git history** is why, and often the only record of a decision. **The comments and docs** are intent, at the time of writing, possibly since diverged. **Issues and discussions** are what people said, which may not be what was built.

Never let the lower ranks stand for the higher ones. When the doc and the code disagree, the code is right and the disagreement is itself a finding worth reporting.

The tests deserve particular attention — they state assertions the system already makes, and the question being researched is often already answered by a test nobody remembered writing.

Where cheap, prefer running the thing to reading it. One printed value settles what an hour of tracing leaves ambiguous.

## Stop at the answer

Research has a natural end: the question is answered, with enough confidence for the decision that is waiting. Not when everything relevant has been read — that condition is never met.

Two failure directions. Stopping at the first plausible answer, which is usually the shallow one. Continuing past the answer into general education about the subsystem, which fills context and delays the decision.

The check: could the waiting decision now be made? If yes, stop. If no, name what specifically is still missing, and go get that.

## Answer first, then evidence

Lead with the answer. Then the evidence, with locations, so it can be checked rather than trusted.

State confidence honestly and distinguish: **verified** — read it, ran it, here is the file and line. **Inferred** — the code implies it, not directly observed. **Assumed** — proceeded on, unchecked.

Anything not established is more valuable said than omitted. A finding that says *this is how it works, except the retry path which I did not trace* is more useful than one implying complete coverage. The unexamined corner is where the next surprise lives, and naming it costs one sentence.

Where the question turns out to be malformed — resting on a premise that is false — that is the finding. Report it rather than answering the question as asked.

## Failure modes

- **Answering the adjacent question.** Easier, related, useless to the decision waiting.
- **Reading without stopping.** No end condition, so context fills and nothing concludes.
- **Docs as evidence.** Reporting the intent as the behaviour.
- **Uniform confidence.** Verified and guessed presented in the same voice.
- **Burying the answer.** A narrative of the search, with the finding somewhere in the middle.
- **Ignoring the tests.** Where the answer often already is, written down.
- **Not saying what was skipped.** Silence reads as coverage.
