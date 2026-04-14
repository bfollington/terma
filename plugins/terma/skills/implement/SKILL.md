---
name: implement
description: "Execute a defined implementation plan by delegating to subagents and writing code following terma's functional, type-driven style. Use when a plan exists and it is time to write code, execute tasks in parallel, or translate a step-by-step plan into working implementation. Trigger terms: implement, execute, build, code it up, start coding, do it, carry out the plan."
---

# Implement Plan

Executes the implementation plan by creating subagents and delegating tasks.

## Workflow

1. **Confirm the plan** — verify a clear plan exists before starting; if not, run the `plan` skill first
2. **Assign subagents** — create one subagent per parallelizable work unit from the plan
3. **Apply code style** — each agent writes functional, type-driven, flat code per the terma style guide
4. **Respect sync points** — halt and reconcile at defined sync points before proceeding
5. **Verify each step** — confirm the done condition for each step before moving to the next
6. **Integrate** — assemble completed units and run integration checks

## Quality Gates per Step

- Types defined before functions
- Functions pure where possible; side effects isolated
- No class used where a plain function would suffice
- Module stays focused; split if straining
- Smallest change that satisfies the step's done condition

## Guidance

- [@../../lib/implement.md](../../lib/implement.md) — subagent delegation and implementation methodology
- [@../../lib/domain-driven-design.md](../../lib/domain-driven-design.md) — domain modeling
- [@../../lib/code-style.md](../../lib/code-style.md) — functional architecture and module guidelines
- [@../../lib/type-driven.md](../../lib/type-driven.md) — type-driven development
- [@../../lib/tdd.md](../../lib/tdd.md) — test-driven development
- [@../../lib/functional-architecture.md](../../lib/functional-architecture.md) — functional architecture patterns
