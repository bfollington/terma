---
name: skill-improver
description: This skill guides structured reflection on skills and processes to identify targeted improvements, update skill files, create new skills from recurring patterns, and log friction points. Use when experiencing confusion, repeated failures, or discovering new patterns that should be codified; at natural checkpoints such as session end or after completing a complex task; or when the user asks "what went wrong", "how can we do this better", "retrospective", or "lessons learned".
---

# Skill Improver

## Overview

This skill guides reflective improvement of skills and processes through structured analysis. Rather than automatically suggesting changes, it provides a framework for mindful reflection to identify high-impact improvements without creating bloat.

The goal is to refine skills to be clearer, more complete, and more efficient.

## When to Use This Skill

- After completing a complex task that involved multiple skills or tools
- When experiencing repeated friction, confusion, or failures during execution
- When discovering a workaround or novel pattern that should be captured
- After successfully navigating a challenging workflow that could be easier next time

## Reflection Workflow

### 1. Identify the Context

Clearly establish what process or skill is being reflected upon:
- What was the original goal or request?
- Which skills were used?
- What tools and resources were involved?
- How did the process unfold?

### 2. Apply the Reflection Framework

Read `references/reflection_framework.md` and work through the questions across five dimensions:

1. **Process Execution** - What happened? What worked? What didn't?
2. **Skill Content Analysis** - Was the skill clear, complete, efficient, accurate?
3. **Tool and Resource Analysis** - Were the right tools available? Did they work well?
4. **Pattern Recognition** - Is this a one-time issue or recurring pattern?
5. **Improvement Identification** - What specific changes would help?

Focus your extraction on these key questions:
- Where did execution slow down, stall, or require backtracking? Note the specific step.
- What information was missing that had to be discovered at runtime? Name the gap.
- Was anything repeated that a script or template could have handled? Identify the repetition.
- Would this problem recur, or was it a one-time environment issue? Classify accordingly.

### 3. Identify Improvement Patterns

Read `references/improvement_patterns.md` and match each observed issue to one or more of these categories:

| Pattern | Signals |
|---|---|
| Clarity | Ambiguous descriptions, jargon, vague steps |
| Completeness | Missing prerequisites, edge cases, error handling |
| Efficiency | Redundant instructions, missing scripts, context bloat |
| Usability | Poor discoverability, overwhelming complexity |
| Structural | Wrong abstraction level, missing decision trees |

Record which pattern(s) apply — this feeds directly into step 4.

### 4. Formulate Specific Improvements

For each matched pattern, write a concrete improvement proposal:

- **Skill/Process**: Name of what's being improved
- **Issue Observed**: Concrete description of the problem
- **Root Cause**: Why this happened (what's missing or wrong)
- **Proposed Change**: Specific, actionable improvement
- **Impact**: High/Medium/Low priority
- **Implementation**: Exact files and changes needed (e.g., `skills/pdf-editor/scripts/rotate_pdf.py`, add section "Error Handling" to `skills/pdf-editor/skill.md`)

### 5. Apply Improvement Principles

Before finalizing recommendations, verify each proposed change:
- Has a specific root cause grounded in observed experience
- Simplifies rather than layers on complexity
- Documents principles and "why", not just "what"
- Passes a cost/benefit check — avoid changes that won't actually be used

### 6. Execute Improvements (if appropriate)

For **high-impact improvements**:
- Invoke the `skill-creator` skill to edit an existing skill or create a new one
- Example invocation: *"Use skill-creator to add a `scripts/rotate_pdf.py` to the `pdf-editor` skill with permission error handling"*
- For process improvements without a dedicated skill, document the new approach in the relevant `references/` file

For **lower-impact improvements**:
- Present findings to the user with the structured proposal from step 4
- Ask: *"Would you like to implement these changes now, or log them for later?"*

## Decision Tree: Improve vs Create

Sometimes the best improvement is creating a new skill. Use this decision tree:

**Create a new skill when:**
- Distinct domain sufficiently different from existing skills
- Recurring multi-step workflow that happens repeatedly
- Requires unique scripts, templates, or reference documentation
- Clear trigger that distinguishes it from other skills

**Improve existing skill when:**
- Issue is with clarity, completeness, or organization
- Missing resources (scripts, references, assets) for existing workflow
- Same domain, just needs better documentation or tools
- Edge cases or error handling need addressing

**Do nothing when:**
- Issue was a one-time environmental problem
- Adding documentation would create bloat without value
- Change would over-engineer a simple process
- Proposed improvement won't actually be used

## Resources

### references/reflection_framework.md

Structured framework with questions across five dimensions:
1. Process Execution
2. Skill Content Analysis
3. Tool and Resource Analysis
4. Pattern Recognition
5. Improvement Identification

**Extract**: For each dimension, note the specific friction point and its location in the workflow.

### references/improvement_patterns.md

Catalog of common skill issues and their solutions:
- Clarity issues (ambiguous descriptions, jargon, vague workflows)
- Completeness issues (missing prerequisites, edge cases, error handling)
- Efficiency issues (redundancy, missing scripts, context bloat, missing templates)
- Usability issues (discoverability, complexity, inconsistent terminology)
- Structural issues (abstraction level, decision trees, undocumented scripts)

**Extract**: The matched pattern name and its recommended solution type (e.g., "add script", "split skill", "add troubleshooting section").

## Example Usage

### Example 1: Missing Scripts

**Scenario**: After using the `pdf-editor` skill to rotate several PDFs, Claude had to rewrite rotation code multiple times due to varying file permissions.

**Reflection**:
- **Issue**: Rewrote PyPDF2 rotation code 3 times; permission errors not handled
- **Pattern**: "Missing scripts for repetitive tasks" + "Incomplete error handling"
- **Root Cause**: No rotation script; permission handling undocumented
- **Proposed Change**: Create `skills/pdf-editor/scripts/rotate_pdf.py` with permission handling; add "Troubleshooting" section to `skills/pdf-editor/skill.md`
- **Impact**: High — eliminates rewriting, prevents permission errors
- **Execution**: *"Use skill-creator to add `scripts/rotate_pdf.py` to the `pdf-editor` skill. The script should accept a file path and rotation angle, handle `PermissionError` with a clear message, and use PyPDF2."*

### Example 2: Missing Reference Documentation

**Scenario**: After creating a Lorn/Clams Casino inspired beat using the `strudel` skill, user feedback revealed bass tone missed the mark and URL encoding was being done too frequently.

**Issue #1**: Encoded URL after every iteration; user said only needed on initial creation
- **Root Cause**: Skill said "Always encode after modifications" — too broad
- **Proposed Change**: In `skills/strudel/skill.md`, replace "Always encode after modifications" with "Encode on initial creation and on final export only; skip during iterative editing"
- **Impact**: Medium

**Issue #2**: No guide for translating artist references (Lorn, Clams Casino) into Strudel techniques
- **Root Cause**: No reference for common genre/artist styles
- **Proposed Change**: Create `skills/strudel/references/genre-styles.md` mapping artist characteristics to Strudel functions and patterns
- **Impact**: High

**Execution**: *"Use skill-creator to (1) update the encoding instruction in the strudel skill and (2) create `references/genre-styles.md` with sections for Lorn and Clams Casino."* User approved both changes.
