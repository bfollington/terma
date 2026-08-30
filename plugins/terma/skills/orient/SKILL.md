---
name: orient
description: Use when arriving in an unfamiliar codebase, or returning to one after long enough that its shape has been forgotten. Concerns building a working model of what the system is and where its decisions live, before touching anything. Trigger at the start of work in a new repository, or when a change is about to be made somewhere not yet understood. Do NOT use for a codebase already held in mind, or for answering one specific question — that is research.
---

# Orient

Arriving in a codebase, the temptation is to start reading files. Files are the least informative thing available.

The goal is not coverage. It is a model good enough to predict: where would a change of this kind go, what would it touch, and what would object.

## What the system is for

Before structure, purpose. A system's shape only makes sense against what it is trying to do — the same directory layout is elegant for one purpose and absurd for another.

The README if it is honest, and what runs when the thing starts. Follow one real path from entry point to outcome — one request, one command, one frame. A single traced path teaches more than any amount of breadth, because it shows what the system actually does as opposed to what it contains.

## Find where decisions live

Most of a codebase is consequence. A small part is decision, and that part is what needs to be understood.

Look for:

- **The vocabulary.** The nouns that recur across modules are the domain model, whether or not anything says so. Learning these is most of orienting — after them, code that was opaque becomes readable.
- **The core types.** Where the domain's concepts are defined is where its claims about the world are made.
- **The seams.** Where this system meets other systems, storage, the network, the user. Interesting things happen at boundaries and most bugs live there.
- **The shape of the tests.** What is tested heavily is what has hurt before. What has no tests is either trivial or feared.
- **What is recent.** Git history shows where the work actually is. A directory untouched for two years is settled; one with forty commits this month is contested or unfinished.

## Read the deviations

Consistency is cheap to learn — see the pattern once and it holds everywhere. The information is in the exceptions.

The module that does not follow the convention, the special case in an otherwise uniform dispatch, the comment explaining why something obvious is not done. These encode what was learned the hard way, and they are exactly what a newcomer will violate first.

When something looks wrong, assume a reason before assuming a mistake. Sometimes there is none — but the reason, when there is one, is usually the most valuable thing available.

## Know what is still unknown

Orienting ends not with a summary of the codebase but with a usable map, and maps are honest about their edges.

Worth stating plainly: what the system does, the words it uses for its concepts, where the important decisions are, which parts are settled and which are moving, and — critically — which parts have deliberately not been understood yet.

The last one matters most. A model presented as complete when it covers a third of the system leads to confident changes in the unexamined two thirds.

## Failure modes

- **Exhaustive reading.** Enumerating files until context is full. Produces a list, not a model.
- **Structure without purpose.** Describing the directory tree, which nobody needed described.
- **Believing the docs.** They describe an intention, possibly from a previous version. The code and the git log are the facts.
- **Missing the vocabulary.** Reading the code without learning its words, so everything stays a little foreign.
- **Skipping the entry point.** Never following one path end to end, so the pieces never join up.
- **Confident maps of unvisited ground.** Not saying which parts were not looked at.
