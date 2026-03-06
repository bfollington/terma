---
name: implement
description: Executes multi-step implementation plans by writing code across files and modules, running tests, and verifying changes. Use when the user has a defined technical plan, spec, architecture doc, or step-by-step instructions ready to be coded — e.g. "execute the plan", "start building", "implement the spec", "code this up", "follow the implementation steps", "start coding", or "build this out".
---

# Implement Plan

Read and apply the guidance from @../../lib/implement.md

## General Implementation Workflow

1. **Read the plan** — Fully understand the spec, steps, or instructions before writing any code.
2. **Identify affected files and modules** — Determine which files need to be created or modified.
3. **Implement step by step** — Follow the plan sequentially, completing each step before moving to the next.
4. **Run tests** — After implementation, run the relevant test suite to verify correctness (e.g. `npm test`, `pytest`, `cargo test`, `go test ./...`).
   - If tests fail: analyse the failure → fix the code → re-run tests → only proceed when passing (or explicitly flag unresolvable failures).
5. **Check for breaking changes** — Review diffs (`git diff`) for unintended side effects or regressions.
6. **Summarise what was done** — Provide a brief report of changes made, files touched, and any deviations from the original plan.

## Example Workflow

Given a plan file `PLAN.md`:
```
## Steps
1. Add a `formatDate(date: Date): string` utility in `src/utils/date.ts`
2. Import and use it in `src/components/EventCard.tsx`
3. Add unit tests in `tests/utils/date.test.ts`
```

The agent would:
1. Read `PLAN.md` in full before touching any files.
2. Create `src/utils/date.ts` with the `formatDate` implementation.
3. Update `src/components/EventCard.tsx` to import and call `formatDate`.
4. Write tests in `tests/utils/date.test.ts`, then run `npm test` to confirm they pass.
5. Run `git diff` to check no unintended files were modified.
6. Report: "Added `formatDate` utility, updated `EventCard`, all tests passing. No deviations from plan."

## Validation Checklist

- [ ] All steps in the plan have been addressed
- [ ] New or modified code follows existing conventions and style
- [ ] Tests pass (or failures are explained and flagged)
- [ ] No unintended files were modified
- [ ] Any ambiguities in the plan were surfaced and resolved before or during implementation
