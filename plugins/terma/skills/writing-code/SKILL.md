---
name: writing-code
description: Use when writing or restructuring code in any language. Concerns the shape of the code itself — what is data and what is function, where effects live, what the names say, when a module has stopped having one subject. Trigger on any implementation task, and on review of code that works but reads badly. Do NOT use for choosing what to build, planning sequence, or debugging behaviour.
---

# Writing Code

Write code like Rich Hickey. Values over places. Data over ceremony. The simple thing, which is not the easy thing — simple means unentangled, one subject per construct, and it is a property of the artifact, not of how familiar it feels to write.

The program should read like the story of what it does.

## Data first, then functions over it

Prefer plain data that can be printed, compared, serialised, and passed to a small set of well-named functions. A map is inspectable at three in the morning; an object graph is not.

Reach for a class only where it is genuinely the right model — a resource with a lifetime, a service holding references to other services. Those exist. They are rarer than the instinct suggests.

Prefer static pure functions. Prefer map, filter and reduce where they say what is happening more clearly than a loop — and a loop where they do not. This is a language of preference, not a rule: no currying gymnastics, no point-free obscurity, nothing that trades a reader's time for a writer's cleverness. Function orientation is enough on its own.

## Let the types do the talking

Write the types first. They are the design, not the annotation of one — arrange them so the invalid state cannot be spelled, and the function bodies get shorter and the tests get fewer.

Types are a to-do list. When a function needs a capability, take it as an argument and let the signature say what is still missing. When the inferred type comes out strange, the design is strange; the type is reporting, not obstructing.

Take data, not capabilities. A function given the seats already reserved is pure, testable with a literal, and says in its signature exactly what it needs. The same function given a `fetchReservedSeats` is neither, and now needs a mock to test. Push the fetching outward to the caller.

## Effects at the edges

Gather what is needed, compute, then write the result. Impure, pure, impure — the middle holds the decisions and the outside holds the I/O, and this keeps the part that is worth testing trivial to test.

The core should be large and the shell thin. When business logic migrates into the shell it becomes untestable by accident, and the tests that follow it there are slow and flaky and will eventually be deleted.

Where failure is an expected outcome — parsing, validation, anything reading the outside world — put it in the return type so the caller cannot forget it. Where failure means the program is broken, throw. Errors are part of the domain: give them cases with names, not strings to be compared. Do not carry a two-track apparatus into code that has one honest failure mode.

An error should say what happened, where, and what to do about it. Preserve the cause when wrapping. A good error message is worth a thousand print statements.

## Names, modules, story

The names of functions, modules, parameters and variables are the story someone reads at three in the morning, possibly you. Names in the code should be the words used about the problem — one word per concept, the same word everywhere, and if the domain's word is wrong, change the domain's word rather than keeping two.

Modules should be namespaced carefully, decoupled, and of medium size. Not a constellation of tiny fragments; not one file that has eaten a subsystem. When a module strains to state its single subject in a sentence, split it — regularly, in passing, two pieces at a time. Do not boil the ocean and reorganise everything at once.

Decompose by what changes together, not by what looks alike. Things that change for the same reason belong in the same place; things that change for different reasons do not, however similar their shape.

Structure grows organically. Do not abstract upfront into a system that anticipates needs nobody has expressed, and do not defer all organisation to the end. Watch the linguistics of the codebase develop and let modules split off as they earn it.

## Duplication, and the cost of being wrong

Duplication is cheaper than the wrong abstraction. Copy first; wait for the pattern to show itself under three real uses; then extract — and extract the stable, generic thing, not the business logic that will diverge next month.

Every line is a line to be maintained. The best code is the code not written, and the second best is code that can be deleted without a migration. Prefer the mistake that is isolated and disposable over the one wired into nine call sites.

Write the smallest change that does the job, or leave the code cleaner than it was found. Not both in the same commit.

## Sequence

Make it work, make it right, make it fast — in that order, and most code never needs the third.

*Work* is types sketched, utilities plugged together, the light turning on. *Right* is tests pressing hard on it, gaps closed, assertions at the boundaries, names reconsidered now that the shape is known. *Fast* is last, is measured rather than guessed, and is the one place where the code may be allowed to get less clear — with the reason written down beside it.

Slow is smooth and smooth is fast. One thing at a time, each cut deliberate, no thrashing.

## Failure modes

- **Classes as namespaces.** A class holding no lifetime and no references is a module with extra steps.
- **Stringly-typed everything.** Domain concepts as bare strings and maps, compared by equality, misspelled at one call site.
- **Capability injection into pure code.** Passing functions where data would do, then needing mocks to test.
- **Swallowed errors.** A caught exception with an empty body. The failure still happened; now nothing knows.
- **Premature abstraction.** A shared helper extracted on the second use, which the third use then has to fight.
- **Anaemic splitting.** Types in one file, functions in another, nothing gained but two files to open.
- **Cleverness.** Code that is a puzzle. If explaining it takes a paragraph, it is not simple, however short.
