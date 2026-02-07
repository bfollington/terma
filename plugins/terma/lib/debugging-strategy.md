# Debugging Strategy

## Core Principle: Make it Reproducible → Make it Visible → Make it Obvious

The fundamental debugging workflow:
1. **Reproducible**: Can you trigger the bug reliably?
2. **Visible**: Can you see what's happening when it occurs?
3. **Obvious**: Can you narrow down exactly where and why?

## Binary Search Debugging

When facing a complex bug, systematically narrow the search space:

1. **Time-based bisection**: "It worked yesterday, fails today"
   - Use git bisect to find the breaking commit
   - Check deployment timestamps and correlate with first reports

2. **Code-path bisection**: "It fails somewhere in this flow"
   - Add checkpoint logging at the midpoint
   - Determine which half contains the bug
   - Repeat until isolated

3. **Data bisection**: "It fails with certain inputs"
   - Find minimal reproducible test case
   - Remove half the data/config and test
   - Binary search the problem data

## Hypothesis-Driven Debugging

Structure your debugging scientifically:

1. **Form hypothesis**: "I think X causes Y because Z"
2. **Design experiment**: How to test this specific hypothesis
3. **Predict outcome**: What you expect to see if correct/incorrect
4. **Run experiment**: Execute and observe
5. **Update mental model**: Refine understanding based on results

### Example Template
```
Hypothesis: The cache invalidation fails when keys contain Unicode
Experiment: Log all cache keys before invalidation
Expected if true: Unicode characters in failed invalidations
Expected if false: Only ASCII in all keys
Result: [Observe and record]
Next hypothesis: [Based on results]
```

## State Inspection Techniques

### 1. Snapshot Comparison
```bash
# Before the operation
echo "=== STATE BEFORE ===" >> debug.log
[dump relevant state] >> debug.log

# After the operation  
echo "=== STATE AFTER ===" >> debug.log
[dump relevant state] >> debug.log

# Diff to see what changed
diff -u <(grep -A50 "STATE BEFORE" debug.log) <(grep -A50 "STATE AFTER" debug.log)
```

### 2. Watch Points
- Set breakpoints that trigger on data changes, not code execution
- Log every modification to suspect variables
- Track object lifecycle (creation → modification → destruction)

### 3. State Assertions
```python
# Add invariant checks throughout code
assert user.balance >= 0, f"Negative balance: {user.balance}"
assert len(items) == initial_count - removed_count
```

## Logging Strategies

### Strategic Logging Placement
1. **Boundaries**: Entry/exit of major components
2. **Decisions**: Before every if/switch statement in suspect code
3. **Mutations**: Before and after state changes
4. **Errors**: Full context when exceptions occur

### Structured Logging Format
```
[timestamp] [level] [component] [request-id] message {key=value ...}
```

Example:
```
2024-01-07 10:15:23 DEBUG auth-service req-123 checking permissions {user=alice, resource=orders, action=read}
```

### Conditional Debug Logging
```python
# Enable verbose logging for specific conditions
if user.id in DEBUG_USERS or request.path.startswith('/problem-endpoint'):
    logger.debug(f"Full request context: {request.__dict__}")
```

## Common Debugging Anti-Patterns

### 1. "Shotgun Debugging"
**Wrong**: Making random changes hoping something works
**Right**: Change one thing at a time based on hypothesis

### 2. "Print Statement Accumulation"
**Wrong**: Adding prints everywhere without strategy
**Right**: Strategic logging at key decision points

### 3. "Fix Without Understanding"
**Wrong**: Apply Stack Overflow solution without knowing why
**Right**: Understand root cause before implementing fix

### 4. "Debugging in Production"
**Wrong**: Testing fixes directly on live system
**Right**: Reproduce locally, fix, test, then deploy

### 5. "Assumption-Driven Debugging"
**Wrong**: "It must be the database connection"
**Right**: Verify each assumption with evidence

## The Prime Directive: "The Bug Is Not Where You Think It Is"

When stuck, challenge your assumptions:

1. **Question the obvious**: "This can't be wrong" → Verify it anyway
2. **Check the basics**: 
   - Is the code you're editing actually running?
   - Are you connected to the right environment?
   - Is your build/cache actually updated?
3. **Expand the search**: 
   - The bug might be in dependencies
   - The bug might be in your debugging code
   - The bug might be in the infrastructure

## Quick Debugging Checklist

- [ ] Can I reproduce it reliably?
- [ ] Have I verified my assumptions?
- [ ] Am I looking at the right version/environment?
- [ ] Have I checked the logs before and after the failure?
- [ ] Can I make a minimal test case?
- [ ] Have I tried explaining it to someone else (rubber duck)?
- [ ] Did I check for similar past issues?
- [ ] Is my mental model of the system accurate?

## Emergency Debugging

When production is on fire:

1. **Stabilize first**: Rollback, scale, or circuit break
2. **Preserve evidence**: Capture logs, metrics, heap dumps
3. **Communicate status**: Keep stakeholders informed
4. **Fix systematically**: Don't panic-patch

Remember: A well-understood bug fixed tomorrow is better than a mysterious "fix" deployed today.