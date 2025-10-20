# Common Skill Improvement Patterns

This document catalogs recurring patterns of issues found in skills and processes, along with their solutions.

## Pattern Categories

### 1. Clarity Issues

**Ambiguous tool descriptions**
- **Symptom**: Claude hesitates or asks clarifying questions about when/how to use a tool
- **Solution**: Add concrete trigger examples, decision trees, or "when to use vs when not to use" sections
- **Example fix**: Instead of "Use for data processing", write "Use when converting CSV to JSON, filtering datasets, or aggregating metrics"

**Jargon without context**
- **Symptom**: User or Claude confused by domain-specific terms
- **Solution**: Add a glossary or inline definitions for specialized terminology
- **Example fix**: First mention of "DAG" becomes "DAG (Directed Acyclic Graph)"

**Vague workflow steps**
- **Symptom**: Claude implements steps incorrectly or asks for clarification
- **Solution**: Make steps concrete and specific with clear inputs/outputs
- **Example fix**: Instead of "Process the data", write "Use ast-grep to extract all function definitions and write them to functions.json"

### 2. Completeness Issues

**Missing prerequisites**
- **Symptom**: Workflow fails because required tools, files, or setup wasn't checked
- **Solution**: Add prerequisite verification step at workflow beginning
- **Example fix**: Add "Before starting: verify `pdflatex` is installed with `which pdflatex`"

**Undocumented edge cases**
- **Symptom**: Workflow succeeds in common cases but fails in edge scenarios
- **Solution**: Document known edge cases and how to handle them
- **Example fix**: Add section "Handling Large Files (>100MB)" with chunking strategy

**Incomplete error handling**
- **Symptom**: When errors occur, Claude doesn't know how to recover
- **Solution**: Add troubleshooting section or error recovery procedures
- **Example fix**: "If API returns 429: wait 60 seconds and retry up to 3 times"

### 3. Efficiency Issues

**Redundant instructions**
- **Symptom**: Same information appears in multiple places, causing confusion
- **Solution**: Consolidate to single source of truth, use references for details
- **Example fix**: Move detailed API schema from SKILL.md to `references/api_schema.md`

**Missing scripts for repetitive tasks**
- **Symptom**: Claude rewrites the same code pattern multiple times
- **Solution**: Extract to a script in `scripts/` directory
- **Example fix**: PDF rotation code → `scripts/rotate_pdf.py`

**Context bloat**
- **Symptom**: Skill loads too much information into context unnecessarily
- **Solution**: Move verbose content to `references/` or `assets/`, load only when needed
- **Example fix**: Move 5000-line schema doc from SKILL.md to `references/schema.md`

**Missing templates**
- **Symptom**: Claude recreates boilerplate from scratch each time
- **Solution**: Add template to `assets/` directory
- **Example fix**: HTML starter → `assets/html-template/index.html`

### 4. Usability Issues

**Poor discoverability**
- **Symptom**: User doesn't know skill exists or when to invoke it
- **Solution**: Improve skill description to be more specific about triggers
- **Example fix**: Change description from "Helps with data" to "This skill should be used when working with BigQuery databases, writing SQL queries, or analyzing query performance"

**Overwhelming complexity**
- **Symptom**: Skill tries to do too much, confuses rather than helps
- **Solution**: Split into multiple focused skills or simplify scope
- **Example fix**: Split "web-development" into "frontend-builder" and "api-builder"

**Inconsistent terminology**
- **Symptom**: Same concept called different names throughout skill
- **Solution**: Standardize terminology, add glossary if needed
- **Example fix**: Consistently use "endpoint" instead of mixing "endpoint", "route", "API path"

### 5. Structural Issues

**Wrong abstraction level**
- **Symptom**: Skill either too general (unhelpful) or too specific (inflexible)
- **Solution**: Aim for the "Goldilocks zone" - general patterns with concrete examples
- **Example fix**: Don't document every git command; document the workflow patterns

**Missing decision trees**
- **Symptom**: Claude unsure which path to take when multiple options exist
- **Solution**: Add explicit decision flowchart or conditional logic
- **Example fix**: "If file is .pdf → use pdf-editor skill, if .docx → use docx skill"

**Undocumented scripts**
- **Symptom**: Scripts exist but Claude doesn't know when/how to use them
- **Solution**: Reference scripts explicitly in SKILL.md with usage examples
- **Example fix**: Add "To rotate PDFs, use `scripts/rotate_pdf.py --input file.pdf --degrees 90`"

## Meta-Pattern: Skillful Means

The Buddhist concept of upaya (skillful means) applies to skill development:

- **Concrete over abstract**: Prefer working examples to theoretical descriptions
- **Simplicity over completeness**: Better to handle 80% of cases well than 100% poorly
- **Clarity over cleverness**: Straightforward instructions beat elegant complexity
- **Practical over perfect**: Ship useful skills, improve iteratively
- **Harmonious over comprehensive**: Reduce friction, don't add features

## When to Create a New Skill

Sometimes improvement means recognizing a new skill is needed:

- **Distinct domain**: Topic is sufficiently different from existing skills
- **Recurring workflow**: Same multi-step process happens repeatedly
- **Specialized tools**: Requires unique scripts, templates, or references
- **Clear trigger**: Obvious when this skill should activate vs others

**Anti-pattern**: Creating micro-skills for single operations that could be simple instructions.
