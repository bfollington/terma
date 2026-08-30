---
name: concurrent-change
description: Use when work is about to be split across multiple agents, or when deciding whether it should be. Concurrency is a property of the change, not a scheduling decision — what can proceed at once is determined by what the pieces have to agree on. Trigger on any request to parallelise, fan out, delegate to subagents, or run work concurrently, and whenever a plan has more than one independent-looking piece. Do NOT use for single-threaded work, or for splitting purely to appear fast.
---

# Concurrent Change

Parallelism is not decided. It is discovered — by finding what the pieces of a change must agree on, and noticing which of them already do.

Two agents can work at once when nothing either produces changes what the other assumes. That is the whole condition. It is a fact about the change, and no amount of instruction, file-locking, or careful sequencing in the prompt can create it where it does not hold.

One operation: **find the agreements the work depends on, establish them first, then fan out over what remains.**

## The unit is the contract, not the file

The instinct is to split by file or directory, because those look separable. They are not the boundary. Two agents editing different files collide the moment they must agree on a name, a shape, a rule, or an error case — and they will resolve that disagreement differently, in isolation, each locally correct.

The real boundary is the contract: the types, signatures, invariants, and vocabulary the pieces share. Work is concurrent when the contract between the pieces is already fixed.

This gives the sequence, and it is almost always the same:

**Establish the contract in one place, alone. Then fan out over the implementations.**

Types, module boundaries, error cases, the names of things — these are what everything downstream reads. Written once, sequentially, they cost little. Discovered independently by four agents, they produce four dialects and a merge that has to pick a winner and rewrite the losers.

The contract is not a design document. It is the actual thing — the type definitions, the signatures, the empty modules — committed and readable, so each agent reads the same source rather than a description of it.

## What is actually parallel

After the contract exists, ask of each pair of pieces: *if both are done at the same time, does either invalidate what the other assumed?*

Genuinely concurrent — the shared thing is fixed and only read:
- implementations behind an already-written interface
- independent leaves: one per adapter, per platform, per endpoint, per case of a settled enum
- reading and investigating anything, always — there is nothing to collide

Not concurrent, however it is arranged:
- anything that may rename, re-shape, or re-scope the shared vocabulary
- two pieces that must arrive at a consistent answer to a question neither has been given
- work whose *findings* redirect the other work — the second agent proceeds on a premise the first is in the process of destroying

That last one is the expensive mistake. Investigation fans out well; acting on unfinished investigation does not.

## Sizing

A piece worth giving to an agent is one that can be stated in a few lines, carries its own means of verification, and returns something small enough to be read.

Too small and the overhead of stating it exceeds doing it. Too large and it makes contract-level decisions on its own — which is the split failing, silently, in a way that only shows at merge.

The signal for "too large": the piece cannot be described without describing how it should be built. That means the design is still open, and it belongs in the contract phase, sequential.

Each piece needs its own check, run inside the piece. An agent that cannot tell whether its own work landed returns a claim, and claims must be re-verified centrally — which serialises the thing that was parallelised.

## Merging

Plan the merge before the fan-out, because it decides the split.

What comes back should be small: what changed, what was verified and how, what was assumed. Not a narrative. If the returns have to be read in full to be integrated, the split was wrong — too much was left open.

The join is where contract violations surface. Two pieces that each verified fine can still contradict each other, and nothing in either piece can see it. Check the shared surface explicitly after the join: does it still say one thing?

Merge conflicts in text are the cheap case — a tool reports them. The expensive case is two pieces that merge cleanly and now disagree in meaning.

## The default

Most work is not parallel, and running it concurrently makes it slower and worse.

Sequential is right when the work is one coherent change, when each piece teaches something the next needs, when the design is still moving, or when the total is small enough that coordination costs more than the work. A single agent holding the whole change in view produces something consistent; four produce something assembled.

Fan out when the pieces are genuinely independent, numerous enough to matter, and each large enough to be worth stating. Three or more real leaves behind a fixed contract is the case that pays.

## Shape

```
Change: five storage backends behind one interface.

Sequential first — this is the contract, and everything reads it:
  Store trait, error cases, the round-trip property test.
  Nothing else starts until this is committed.

Then concurrent — five pieces, each reads the trait, none writes it:
  one agent per backend. Each returns: passing/failing round-trip
  property, plus anything it could not satisfy.

Not concurrent: the trait itself. If any backend cannot satisfy it,
  the trait is wrong — that comes back to the middle, sequentially,
  and re-fans. Expect this once.

Join: run the property suite across all five together. Two backends
  passing alone can still disagree about what an empty key means.
```

## Failure modes

- **Splitting by file.** Directories look independent and are not. The contract is the boundary.
- **Fanning out before the contract exists.** Each agent invents the missing vocabulary. Merge picks one and rewrites three.
- **Parallel investigation into parallel action.** Fine to look at once; not to act on what is still being looked at.
- **Unverifiable pieces.** Agents that return claims rather than checked results push all verification to the join.
- **Coordination in prose.** "Don't touch the shared types" is not a mechanism. If two pieces can both change something, eventually both will.
- **Splitting for appearance.** Fan-out on work that was three sequential steps costs more and returns something less coherent.
- **Silent re-fan.** A backend that cannot meet the contract is information about the contract. Not something to work around locally.
