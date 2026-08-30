---
name: code-review
description: Use when reviewing written code — your own or someone else's. Concerns finding what the code will cost later rather than what it violates now, and saying it in a way that can be acted on. Trigger on requests to review, critique, or give feedback on an implementation, and before handing off work you wrote. Do NOT use for debugging behaviour or for deciding what to build.
---

# Code Review

The question is not whether the code is good. It is **what will this cost the next person to change it** — and whether that cost is worth naming now.

Working code that is hard to change is the expensive case, and it is invisible to tests. That is what review is for. Style has a formatter; correctness has a test suite; neither has an opinion about the thing that will make the next feature take three days instead of one.

## Read for the story first

Before any judgement, read it the way someone will read it in six months with no context: top to bottom, following the names.

Where does it stop making sense? Where does a name promise one thing and the body do another? Where is a paragraph of explanation needed to bridge two lines?

Those points are the review. They are where the code and its meaning have separated, and they matter more than anything a checklist finds. A reader tripping is not a reader's failing.

## What is actually worth saying

In order of what it costs later:

**The claim that is false.** A type that permits states the domain does not have. A name that says one thing while the code does another. An invariant enforced at one call site and assumed at four. These are wrong now and get more wrong.

**The boundary that will transmit change.** Business logic in a utility. An abstraction extracted on the second use. Two modules that must be edited together every time. Ask what one likely upcoming change would require, and see how far it spreads.

**Errors that lose information.** A swallowed exception, a cause not preserved, a message that names no cause and no remedy, a failure returned as a null the caller will not check.

**Effects where they should not be.** I/O in the middle of the decision-making, so the logic can only be tested through the network. Hidden mutation of something a caller still holds.

**The thing that isn't there.** The case not handled, the concept the code keeps describing in phrases because it has no name, the test that would have caught this class of mistake.

**Duplication that has earned abstraction** — three real uses with the same shape, not two that rhyme. And its opposite, more common: an abstraction serving one caller, which should be inlined.

Below that line is preference. Say it once, quietly, or not at all. A review of thirty items has no priority; a review of four gets acted on.

## Say it so it can be acted on

Name the location, the consequence, and the route. "This is unclear" cannot be acted on; "`process` in sync.ts:40 both writes and validates, so the validation can only be tested by writing — splitting the check out makes it testable with a literal" can.

Where there is more than one way through, give them and recommend one. Handing back a problem with no route is work transferred, not review given.

Separate what should change now from what is worth knowing. Not everything found needs fixing in this change — but the thing not fixed should be *known*, and said plainly rather than implied.

And say what is right, specifically. Not politeness — calibration. A review that only ever names problems leaves the reader unable to tell which of their instincts to keep.

## Reviewing your own work

The failure mode is different: the intent is known, so the code appears to say it.

Read what is written, not what was meant. Best after a gap, or by reading it in the reverse of the order it was written. The parts that were hardest to write are the parts to be most suspicious of — difficulty in writing usually means the design was fighting, and the fight left marks.

## Failure modes

- **Checklist review.** Running rules over the diff without reading it as a whole. Finds everything except what matters.
- **Uniform severity.** Naming a design flaw and an import order together, so both read as equally optional.
- **Style as substance.** Filling a review with what a formatter should handle.
- **Restating the diff.** Describing what the change does back to the person who wrote it.
- **Vague unease.** "This feels complex." Either locate it or drop it.
- **Rewriting in your own idiom.** Different is not worse. Reserve it for cost, not taste.
- **Reviewing only the diff.** The change is often fine, and wrong in context, and the context is not in the diff.
