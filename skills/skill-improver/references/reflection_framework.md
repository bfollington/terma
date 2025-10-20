# Reflection Framework for Skill Improvement

This framework provides structured questions to guide thoughtful reflection after using a skill or completing a process.

## When to Reflect

Reflection is most valuable:
- At natural checkpoints (feature complete, bug resolved, task finished)
- After experiencing friction or confusion
- When a skill was just used and the experience is fresh
- After discovering a workaround or novel pattern
- When the user expresses frustration

**Not** after every tiny task - reflection should be purposeful, not reflexive.

## Reflection Questions

Work through these questions systematically. Not all will apply to every situation.

### 1. Process Execution

**What was attempted?**
- What was the original goal or request?
- Which skills or processes were involved?
- What tools were used?

**How did it go?**
- Did the process complete successfully?
- Were there blockers, errors, or unexpected issues?
- What workarounds were needed?

**What felt smooth?**
- Which parts of the workflow felt natural and efficient?
- What aspects of the skill helped most?
- Where did the instructions match reality well?

**What felt rough?**
- Where did confusion arise (for Claude or user)?
- What required trial-and-error that shouldn't have?
- What took longer than expected?

### 2. Skill Content Analysis

**Clarity**
- Were instructions clear and actionable?
- Was any terminology confusing or undefined?
- Were there ambiguous decision points?
- Did examples help or confuse?

**Completeness**
- Was any necessary information missing?
- Were edge cases handled?
- Were error recovery procedures documented?
- Were prerequisites clearly stated?

**Efficiency**
- Was there redundant information?
- Could repetitive tasks be scripted?
- Should any content move to `references/` or `assets/`?
- Is context being used efficiently?

**Accuracy**
- Were any instructions outdated or incorrect?
- Did APIs or tools behave differently than documented?
- Were file paths or commands wrong?

### 3. Tool and Resource Analysis

**Missing tools**
- Was there a script that should exist but doesn't?
- Would a template have helped?
- Should reference documentation be added?

**Wrong tools**
- Were existing scripts insufficient or buggy?
- Are templates outdated or not fit for purpose?
- Is reference documentation incomplete or wrong?

**Tool usage friction**
- Were tools difficult to discover?
- Were usage instructions unclear?
- Did tools require patching or modification?

### 4. Pattern Recognition

**Recurring problems**
- Is this the first time this issue appeared, or recurring?
- Have similar issues occurred in other skills?
- Is there a systemic problem to address?

**Novel solutions**
- Was a new technique or approach discovered?
- Should this become standard practice?
- Would other skills benefit from this learning?

**User preferences**
- Did the user express preferences about how to work?
- Are there patterns in what frustrates or pleases them?
- Should preferences be documented for future sessions?

### 5. Improvement Identification

**What should change?**
- Specific wording clarifications needed
- Missing sections to add
- Incorrect information to fix
- Resources to create or update
- Entire sections to restructure

**Priority assessment**
- High impact: Fixes blockers, prevents errors, eliminates major friction
- Medium impact: Improves clarity, adds helpful references, smooths workflow
- Low impact: Minor wording tweaks, aesthetic improvements

**Scope assessment**
- Quick fixes: Simple edits to SKILL.md
- Medium effort: Creating new scripts or reference docs
- Major work: Restructuring skill, splitting into multiple skills

## Improvement Principles

### Do

- **Be specific**: "Add error handling for 404 responses" not "improve error handling"
- **Show evidence**: Reference concrete moments of confusion or failure
- **Consider cost/benefit**: Will this improvement actually help future usage?
- **Think iteratively**: Small improvements compound over time
- **Document principles**: Capture the "why" behind practices, not just "what"

### Don't

- **Don't pile on changes**: One focused improvement is better than five vague ones
- **Don't over-engineer**: Resist adding complexity that won't be used
- **Don't duplicate**: If information exists elsewhere, reference it instead
- **Don't assume**: Validate that the improvement actually solves the problem
- **Don't spam**: Not every session needs recommendations

## Output Format

When suggesting improvements, structure them clearly:

**Skill/Process**: [Name of skill or process being improved]

**Issue Observed**: [Concrete description of what went wrong or could be better]

**Root Cause**: [Why this happened - what's missing or wrong in current skill]

**Proposed Change**: [Specific, actionable improvement]

**Impact**: [High/Medium/Low - what this fixes or improves]

**Implementation**: [What files to change, what to add/remove/modify]

---

Example:

**Skill/Process**: pdf-editor

**Issue Observed**: When rotating PDFs, Claude had to rewrite the PyPDF2 rotation code three times because file permissions varied

**Root Cause**: No script exists for PDF rotation; file permission handling not documented

**Proposed Change**:
1. Create `scripts/rotate_pdf.py` with permission handling
2. Add "Troubleshooting: Permission Issues" section to SKILL.md

**Impact**: High - eliminates code rewriting, prevents permission errors

**Implementation**:
- Create `/scripts/rotate_pdf.py` with proper error handling
- Add troubleshooting section after "Rotating PDFs" in SKILL.md
- Reference script in workflow: "Use `scripts/rotate_pdf.py --input file.pdf --degrees 90`"
