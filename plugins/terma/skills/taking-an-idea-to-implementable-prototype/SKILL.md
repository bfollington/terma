---
name: idea-to-prototype
description: Takes a raw idea through a structured, interactive multi-agent process to produce an implementable prototype plan. Use when a user wants to explore, develop, or validate a new idea — capturing a concept brief, generating pitch summaries, producing design sketches, writing a scoped technical specification, compiling research briefs on prior art, and outputting a phased project timeline — to decide if something is worth building or to fail fast. Ideal for brainstorming sessions, product ideation, prototype scoping, and turning vague concepts into actionable plans. Distinct from general project planning by its end-to-end ideation-to-prototype workflow with explicit kill criteria at each phase.
---

# Taking an idea to implementable prototype

Use a team of agents to support this process. The goal is to go from a raw idea to something worth building — or to fail fast along the way. This is an interactive, creative discussion; document key artifacts and decisions at each phase.

## Agent Roles

Assign specialised agents to drive each phase:

- **Concept Agent** — Phase 1: captures and expands the raw idea
- **Pitch Agent** — Phase 2: stress-tests value proposition and audience fit
- **Design Agent** — Phase 3: explores mechanics and user flows
- **Spec Agent** — Phase 4: scopes the minimal buildable prototype
- **Research Agent** — Phase 5: finds prior art and reusable components
- **Planning Agent** — Phase 6: structures the build into phases and gates

Agents may hand off sequentially or work in parallel where phases overlap (e.g., Research can run alongside Design).

---

## Phase 1 — Capture Concept
*Diverge: imagine, collect inspiration, hold multiple possibilities*

**Goal:** Articulate the idea in its fullest, most open form before converging.

**Actions:**
- Prompt the user with open questions: *What problem does this solve? Who feels this pain? What's the dream outcome?*
- Generate 3–5 variations on the core concept to explore the space
- Record all angles without filtering

**Artifact — Concept Brief:**
```
Idea: <one-line summary>
Problem space: <what pain or opportunity exists>
Possible forms: <2–5 variations on how this could manifest>
Inspiration / analogues: <anything similar, even loosely>
Open questions: <what we don't know yet>
```

**Gate:** A Concept Brief exists with at least one clearly articulated problem space. If the idea cannot be stated as a problem or opportunity, loop back.

---

## Phase 2 — Produce Pitch
*Converge: find the compelling angle, run creative Q&A*

**Goal:** Determine whether this idea is worth pursuing over other ideas competing for time and attention.

**Actions:**
- Answer three forcing questions: *Who specifically benefits? Why does this matter now? What makes this distinct?*
- Identify the single most compelling angle
- Actively attempt to kill the idea — if no strong counter-argument emerges, proceed

**Artifact — Pitch Summary:**
```
One-liner: <idea in one sentence>
Audience: <who benefits and why they care>
Why now: <timing, context, or urgency>
Unique angle: <what makes this different>
Biggest risk: <the most likely reason this fails>
Verdict: PROCEED / KILL / REVISIT
```

**Gate:** Pitch answers all three forcing questions with specifics. A "KILL" verdict here is a valid, valuable outcome — not a failure.

---

## Phase 3 — Design
*Diverge: explore how it works in deeper detail*

**Goal:** Understand the internal mechanics, user flows, and key decisions before committing to a scope.

**Actions:**
- Map the core user journey (entry → key action → outcome)
- Identify the 2–3 central design decisions that most affect the outcome
- Explore edge cases and interaction patterns; reference prior art where useful (e.g., patterns from Christopher Alexander, Brett Victor's explorable explanations)

**Artifact — Design Sketch:**
```
Core user journey:
  1. User starts at: <entry point>
  2. Key action: <what the user does>
  3. Outcome: <what changes for them>

Central design decisions:
  - Decision A: <option 1> vs <option 2> — leaning toward: <choice + rationale>
  - Decision B: ...

Key unknowns / risks: <what could invalidate this design>
```

**Gate:** Core user journey is legible and at least two design decisions are documented. If no coherent journey exists, return to Phase 1 or 2.

---

## Phase 4 — Spec
*Converge: define the minimal buildable prototype*

**Goal:** Scope a prototype that delivers the maximum signal about viability in the minimum build time — either confirming the concept or invalidating it quickly.

**Actions:**
- Strip the design to its essential hypothesis-testing core
- List what is explicitly OUT of scope for the prototype
- Define what a "good outcome" looks like (success signal) and what would confirm the concept is wrong (kill signal)

**Artifact — Prototype Spec:**
```
Prototype hypothesis: <the one thing this build will prove or disprove>
In scope:
  - <feature / behaviour 1>
  - <feature / behaviour 2>
Out of scope (deferred):
  - <anything that can wait>
Success signal: <observable result that confirms the concept>
Kill signal: <observable result that invalidates the concept>
Estimated build effort: <rough order of magnitude — hours / days / weeks>
```

**Gate:** Hypothesis is stated as a falsifiable claim. Both success and kill signals are concrete and observable. If spec cannot be scoped to a prototype, escalate to stakeholders before proceeding.

---

## Phase 5 — Research
*Find prior art, resources, and faster paths*

**Goal:** Avoid reinventing the wheel; find the best existing examples to draw from or build on.

**Actions:**
- Search for existing implementations, papers, open-source projects, or tools that overlap with the spec
- Identify the closest analogues and what can be reused or adapted
- Flag any findings that materially change the spec or design

**Artifact — Research Brief:**
```
Prior art found:
  - <source>: <what it does> — relevance: <how it applies>
  - ...
Reusable components / libraries / patterns: <list>
Gaps not addressed by prior art: <what must be built from scratch>
Spec changes triggered by research: <any updates to Phase 4 spec>
```

**Gate:** At least one search pass completed. If a prior solution fully solves the problem, surface it before proceeding to build.

---

## Phase 6 — Project Plan
*Construct a phased plan with validation gates*

**Goal:** Translate the spec into an ordered, executable build plan that pre-empts common blockers.

**Actions:**
- Break the prototype into phases (e.g., scaffold → core loop → validation)
- Within each phase, list concrete tasks
- Attach a validation gate to each phase — a checkpoint that must pass before the next phase begins
- Flag known risks and mitigation strategies up front

**Artifact — Project Timeline:**
```
Phase 1: <name>
  Tasks:
    - [ ] <task>
    - [ ] <task>
  Validation gate: <what must be true to proceed>

Phase 2: <name>
  Tasks:
    - [ ] <task>
  Validation gate: <what must be true to proceed>

Known risks:
  - Risk: <description> — Mitigation: <approach>

Definition of done (prototype): <what the completed prototype delivers>
```

**Gate:** Plan reviewed for obvious gaps or sequencing errors before implementation begins. Pre-empt as many issues as possible here to avoid wasted effort during implementation.
