---
name: research
description: "Investigate a topic, technology, codebase question, or approach and produce a structured findings document. Use when gathering information before implementation, understanding existing code behavior, exploring a technology choice, or answering a specific question about the codebase. Trigger terms: research, investigate, find out, explore, understand, how does, why does, look into."
---

# Research

Investigates and produces a written findings document for: $ARGUMENTS

Uses a subagent to explore the codebase or topic thoroughly, then writes results to `research/YYYYMMDD_QUESTION.md`.

## Workflow

1. **Clarify the question** — make the research question precise before starting
2. **Explore broadly** — read relevant files, tests, and documentation; do not stop at the first answer
3. **Check tests** — tests reveal assertions the codebase already makes and implicit feature coverage
4. **Synthesize findings** — summarize what was found, what is uncertain, and what the next step should be
5. **Write output** — save results to `research/YYYYMMDD_QUESTION.md` with a clear answer and supporting evidence

## Output Format

```
research/YYYYMMDD_<short-question-slug>.md
```

Include:
- **Question**: what was investigated
- **Findings**: structured answer with supporting evidence
- **Uncertainty**: what remains unclear
- **Recommended next step**: plan, implement, or further research

## Guidance

See [@../../lib/research.md](../../lib/research.md) for subagent coordination and full research methodology.
