---
name: code-review
description: Reviews code for quality, correctness, and best practices by identifying bugs, suggesting refactoring opportunities, checking error handling, and reviewing naming conventions and code structure. Use when the user wants a code review, feedback on their implementation, to review a PR or pull request, to check their code, look over a function, or critique changes — e.g. "review my PR", "check my code", "look over this function", "critique my implementation".
---

# Code Review

Read and apply the guidance from @../../lib/review.md

## Overview

A thorough code review examines code across several dimensions:

- **Correctness** — logic errors, off-by-one errors, unhandled edge cases, null/undefined handling
- **Readability** — naming conventions, clarity of intent, comment quality, code organisation
- **Performance** — inefficient algorithms, unnecessary iterations, memory concerns
- **Security** — input validation, injection risks, exposed secrets, improper access control
- **Error handling** — missing try/catch, unhandled promise rejections, silent failures

## Workflow

1. **Read the code** — understand its stated purpose and intended behaviour
2. **Identify issues** — note bugs, smells, and improvement opportunities as you read
3. **Categorise by severity** — distinguish blockers (bugs, security issues) from suggestions (style, minor refactors)
4. **Provide actionable feedback** — for each issue, explain what is wrong, why it matters, and how to fix it
5. **Verify fixes** — confirm suggested changes address the identified issues without introducing new problems

## Feedback Format

Structure review feedback clearly, for example:

```
**[Severity: Critical | Major | Minor | Suggestion]** Short title

What: Brief description of the issue.
Why: Why it matters (impact on correctness, security, performance, etc.).
Fix: Concrete suggestion or corrected code snippet.
```

Prioritise critical and major issues at the top. Group related feedback where possible to avoid overwhelming the author.

## Examples

### Example 1 — Critical bug and a Suggestion in the same function

**Code under review:**
```python
def get_user(user_id):
    result = db.query(f"SELECT * FROM users WHERE id = {user_id}")
    return result[0]
```

**Review feedback:**

```
**[Severity: Critical]** SQL injection vulnerability

What: The query is built by directly interpolating `user_id` into the SQL string.
Why: An attacker can pass a crafted value (e.g. `1 OR 1=1`) to read, modify, or
     delete arbitrary data in the database.
Fix: Use a parameterised query:
     result = db.query("SELECT * FROM users WHERE id = %s", (user_id,))
```

```
**[Severity: Suggestion]** No guard against missing user

What: `result[0]` raises an IndexError when no matching user is found.
Why: Silent crashes are hard to debug and expose an unhelpful error to callers.
Fix: Return None (or raise a descriptive exception) explicitly:
     return result[0] if result else None
```

---

### Example 2 — Major error-handling gap

**Code under review:**
```javascript
async function fetchConfig(url) {
  const response = await fetch(url);
  const data = await response.json();
  return data;
}
```

**Review feedback:**

```
**[Severity: Major]** Unhandled network and HTTP errors

What: Neither fetch failures (network down) nor non-2xx HTTP responses are caught.
Why: A failed fetch rejects the promise and crashes the caller; a 404 or 500
     silently returns an error body that callers treat as valid config.
Fix: Check response.ok and wrap in try/catch:

     async function fetchConfig(url) {
       try {
         const response = await fetch(url);
         if (!response.ok) throw new Error(`HTTP ${response.status}`);
         return await response.json();
       } catch (err) {
         throw new Error(`Failed to fetch config: ${err.message}`);
       }
     }
```
