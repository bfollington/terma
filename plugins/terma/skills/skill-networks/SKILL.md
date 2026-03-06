---
name: skill-design
description: Guides the agent in designing, writing, and composing SKILL.md files as tightly focused packets of wisdom — including structuring frontmatter YAML, writing description fields, organising skill sections, and validating conciseness. Covers all abstraction levels—specific knowledge, practices, mental models, techniques, principles, and abstract processes—and emphasises composability with other skills. Use when creating a new skill, refining an existing skill, thinking about how skills compose together, or structuring condensed mental-model cards for an agent skill library.
---

When designing a skill, think first about how it will be used. Skills are tightly focused, all-signal packages of distilled wisdom — index cards of functionality written to be maximally effective and composable, not encyclopaedias. Skills occur at many levels of abstraction:

- **specific knowledge** — "Testing with Deno"
- **specific practice** — "SWOT Analysis", "Technical Review"
- **mental models** — "Multi-scale Thinking", "Pace Layers"
- **techniques** — "Invert Foreground and Background", "Enabling Constraints", "Spread of Three Ideas", oblique strategies
- **principles** — "Domain Driven Design", "Design for Emergence"
- **abstract processes** — "Taking an Idea from Concept to Implementable", "Understanding what's truly motivating about an idea", "Bisecting Possibility Space", "Contrasting Multiple Models", "Representing Abstract Systems using Category Theory"

All skills should be aware that other skills may want to compose with them and encourage the agent to consider certain kinds of skills in concert with the specific skill.

---

## Skill Creation Workflow

1. **Identify abstraction level** — Decide which of the six levels above best fits the skill. This determines the appropriate tone (concrete steps vs. conceptual framing) and density.
2. **Name and describe** — Write the `name` (lowercase, hyphenated) and `description` (third-person, includes a "Use when…" clause with natural trigger terms). The description is the primary routing signal; make it precise.
3. **Draft core content** — Write the skill body as a focused packet: the key principle, model, or process. Avoid padding. Every sentence should earn its place.
4. **Add composition hints** — Explicitly note which other skill types or domains pair well with this skill, so the agent knows when to reach for complementary skills.
5. **Validate conciseness** — Apply the bloat checklist below before finalising.

---

## Frontmatter Template

```yaml
---
name: your-skill-name
description: One-to-two sentence description in third-person that names what the skill does and includes a "Use when..." clause with natural trigger phrases.
---
```

Optional fields (`tags`, `allowed-tools`, `version`, etc.) should only be added when they provide genuine routing or execution value.

---

## Bloat Checklist

A skill is **appropriately concise** when:
- [ ] Every paragraph contains a distinct, actionable or conceptual point
- [ ] No sentence merely restates the title or description
- [ ] Examples illustrate; they do not repeat the principle in different words
- [ ] The body can be read in under 60 seconds
- [ ] Composition hints are present but brief (one sentence or a short list)

A skill is **too bloated** when:
- It contains background context the agent already has from general training
- It hedges the same point more than once
- It includes step-by-step instructions that belong in a separate, more specific skill
- Its body exceeds roughly 400–500 tokens for a conceptual skill, or ~800 tokens for a procedural one

---

## Worked Examples

### Specific Knowledge skill (tight, factual)
```
---
name: deno-testing
description: Covers writing and running tests in Deno using the built-in test runner. Use when writing Deno tests, debugging test failures, or setting up a Deno test suite.
---

Use `Deno.test("name", () => { ... })` as the unit of test. Run with `deno test`. Use `--filter` to run a subset. Assertions live in `https://deno.land/std/assert/mod.ts`. Group related tests with a shared prefix in the name string. For async tests return a Promise or use async/await directly inside the callback.
```

### Mental Model skill (conceptual, composable)
```
---
name: pace-layers
description: Applies Stewart Brand's Pace Layers model to reason about change at different timescales within a system. Use when analysing why parts of a system resist change, prioritising interventions, or understanding systemic inertia.
---

Systems are composed of layers that change at vastly different speeds: fashion/art → commerce → infrastructure → governance → culture → nature (fastest to slowest). Faster layers innovate; slower layers provide stability and absorb shocks. Interventions aimed at a slow layer using fast-layer tools usually fail. When diagnosing friction or planning change, identify which layer you are operating in and what constraints the layers below impose.

Composes well with: Multi-scale Thinking, Domain Driven Design, Design for Emergence.
```

### Abstract Process skill (procedural, open-ended)
```
---
name: bisect-possibility-space
description: A technique for narrowing a large solution space by repeatedly halving it with targeted questions or experiments. Use when facing an overwhelming number of options, debugging an unknown root cause, or exploring a new domain efficiently.
---

State the full possibility space explicitly. Identify a question whose answer eliminates roughly half. Commit to the answer (don't hedge), then repeat on the remaining half. Stop when the remaining space is small enough to evaluate directly. The key discipline is committing to binary splits rather than exploring branches in parallel, which preserves cognitive focus and produces a traceable decision path.

Composes well with: Contrasting Multiple Models, Technical Review.
```
