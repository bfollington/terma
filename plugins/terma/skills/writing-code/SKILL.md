---
name: writing-code
description: "Write clean, functional, well-structured code following the terma style guide. Use when writing new code, reviewing code style, or refactoring existing code for clarity and correctness. Trigger terms: write code, implement function, code style, refactor, clean code, functional programming."
---

# Write Code

Writes clean, functional, well-structured code following terma's opinionated style — functional-first, type-driven, flat and readable.

## Workflow

1. **Define types first** — model the domain in types before writing any logic
2. **Write pure functions** — prefer static pure functions over classes; use classes only for resources with explicit lifetimes or services with pointers to other services
3. **Keep routines small and focused** — each function does one thing; the program reads like the story of what it does
4. **Prefer flat code** — avoid deep nesting; early returns and guard clauses over else branches
5. **Name things precisely** — module names, function signatures, and types are the documentation
6. **Make the smallest change possible** — leave code cleaner than you found it; do not boil the ocean

## Core Principles

- Prefer functions over classes unless managing resources with explicit lifetimes
- Let types and signatures communicate intent; avoid comments that restate code
- Use `map`, `filter`, `reduce` over imperative loops where idiomatic
- Split modules before they strain to maintain a single focus; write a `MOD.md` when changing directory-level module purpose
- Write types → functions → tests → integrations (in that order)
- Rigor and intentionality upfront is cheaper than cleanup later

## Style Reference

See [@../../lib/code-style.md](../../lib/code-style.md) for the full functional architecture and module guidelines.
