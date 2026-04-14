---
name: plan
description: "Create a precise, step-by-step implementation plan before writing any code. Use when translating research findings into actionable steps, coordinating parallel work across subagents, or ensuring a solid foundation before implementation begins. Trigger terms: plan, design approach, next steps, break down, task breakdown, before we code, how to approach."
---

# Plan

Creates a structured implementation plan for: $ARGUMENTS

No implementation — only careful planning. Optimizes use of time and tokens by thinking ahead before acting.

## Workflow

1. **Review research** — confirm understanding of the problem and constraints from prior research
2. **Define success** — state what done looks like and how it will be verified
3. **Sequence steps** — each step is exactly one change, verifiable independently
4. **Lay foundations first** — foundation → scaffolding → cladding; never skip ahead
5. **Identify parallelizable work** — mark steps that can run concurrently via subagents
6. **Plan sync points** — define where parallel agents must wait for one another to avoid conflicts
7. **Apply composition principles** — prefer deletable, composable units; see lib references below

## Step Format

Each step should include:
- **What**: the single change to make
- **Why**: which goal it advances
- **Done when**: the verification condition
- **Blocks**: any steps that depend on this one

## Guidance

- [@../../lib/plan.md](../../lib/plan.md) — planning methodology and subagent coordination
- [@../../lib/composition.md](../../lib/composition.md) — composition philosophy
- [@../../lib/easy-to-delete.md](../../lib/easy-to-delete.md) — deletability principles
