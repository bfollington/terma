---
name: plan
description: Creates a structured implementation plan by breaking down tasks, identifying dependencies, estimating complexity, and defining milestones for a feature or problem. Use when the user wants to plan, design an approach, build a roadmap, define a strategy, outline implementation steps, or asks "how should I build this?" before writing code.
---

## Overview

This skill produces a structured plan that organises work into clear phases, tasks, and dependencies before any code is written.

## What $ARGUMENTS Does

Pass any relevant context as `$ARGUMENTS` — such as the feature description, constraints, tech stack, or scope. If no arguments are given, the skill will prompt for the necessary details.

## Workflow

1. **Gather requirements** — Understand the goal, constraints, and context from `$ARGUMENTS` or by asking clarifying questions. Ask: *What is the desired outcome? What are the constraints (time, tech stack, scope)?*
2. **Analyse the problem** — Identify the key components, unknowns, risks, and dependencies involved. Ask: *What must exist before each part can start? What could block progress?* For example: an authentication system must exist before implementing user profiles; a database schema must be finalised before writing data-access logic.
3. **Structure the plan** — Break the work down into phases and tasks with a logical sequence. Ask: *Can this be parallelised? What is the smallest testable increment?*
4. **Validate with the user** — Present the plan and invite feedback before proceeding to implementation. Ask: *Does this order make sense? Are there missing pieces or constraints I haven't accounted for?*

### Complexity Estimation Heuristics

When labelling tasks `low / medium / high`:

- **Low** — Well-understood, self-contained change with no external dependencies (e.g., adding a config flag, updating a UI label).
- **Medium** — Touches multiple components or requires coordination across layers, but the approach is clear (e.g., adding a new API endpoint with validation and tests).
- **High** — Significant unknowns, cross-cutting concerns, or architectural decisions involved (e.g., migrating an auth system, introducing a new data store).

## Example Output Format

```
## Plan: <Feature or Problem Title>

### Phase 1: <Phase Name>
- [ ] Task A — <brief description> (complexity: low/medium/high)
- [ ] Task B — depends on Task A

### Phase 2: <Phase Name>
- [ ] Task C
- [ ] Task D — depends on Task C

### Dependencies
- Task B requires Task A to be complete
- Phase 2 assumes Phase 1 is fully tested

### Open Questions / Risks
- <Any unknowns that need resolution before or during implementation>
```

---

Read and apply the guidance from @../../lib/plan.md

$ARGUMENTS
