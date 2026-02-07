# Debug Command

Read and apply the guidance from @../lib/debugging-strategy.md

## Debugging Assistant

I'll help you debug systematically. You described the issue as: **$ARGUMENTS**

Let's apply the debugging strategy to your problem.

### Step 1: Make it Reproducible

First, let's ensure we can reliably trigger the bug:

- **When does it occur?** (Always/Sometimes/Rarely?)
- **What are the exact steps to reproduce?**
- **What environment/configuration is needed?**
- **Can you create a minimal test case?**

### Step 2: Make it Visible

Now let's observe what's happening:

- **What is the expected behavior?**
- **What is the actual behavior?**
- **What error messages or symptoms appear?**
- **Have you captured relevant logs/traces?**

### Step 3: Form Initial Hypotheses

Based on the symptoms, what might be causing this?

Consider:
- Recent changes that correlate with the bug appearing
- Similar issues you've encountered before
- Common causes for this type of symptom

### Debugging Approach

Based on your description, here's a systematic approach:

1. **Binary Search Strategy**
   - If it's a regression: Use `git bisect` to find the breaking change
   - If it's input-dependent: Minimize the failing test case
   - If it's intermittent: Add logging to capture failure conditions

2. **State Inspection Points**
   ```bash
   # Add strategic logging before and after suspected problem areas
   echo "State before: $(relevant_command)" | tee -a debug.log
   # [Your operation here]
   echo "State after: $(relevant_command)" | tee -a debug.log
   ```

3. **Hypothesis Testing Template**
   ```
   Hypothesis: [Your theory about the cause]
   Test: [How you'll verify this]
   Expected if true: [What you should see]
   Expected if false: [Alternative outcome]
   ```

### Quick Checks

Before diving deep, verify these basics:

- [ ] Are you debugging the right version of the code?
- [ ] Is your environment correctly configured?
- [ ] Are you looking at the correct logs/servers?
- [ ] Have you tried with a clean cache/restart?
- [ ] Could this be a race condition or timing issue?

### Remember: The Bug Is Not Where You Think It Is

If you've been debugging for a while without progress:
- Question your assumptions about how the system works
- Look one level up/down in the stack
- Check for side effects you haven't considered
- Explain the problem to someone else (or a rubber duck)

### Next Steps

1. Start with the reproducibility checklist above
2. Apply binary search to narrow down the problem space
3. Form and test specific hypotheses
4. Keep a debugging log of what you've tried

Good debugging is systematic elimination, not random experimentation. Let's find this bug!

---

*For detailed debugging strategies and techniques, see the included debugging-strategy guide above.*
