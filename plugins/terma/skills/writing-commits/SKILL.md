---
name: writing-commits
description: Use when writing a commit message. Concerns writing for the reader who finds the commit months later through blame, bisect or log, with no access to the session that produced it. Gives a default PROBLEM / SOLUTION form for repositories without a convention, and a width check. Do NOT use for PR descriptions or other prose (writing-prose covers those), or for code comments (writing-code).
---

# Writing Commits

The reader of a commit message arrives from `git blame` or `git bisect`,
looking at one changed line and asking why it is like this. They have the
diff. They do not have the conversation, the issue thread, the dev server or
the person who wrote it. The message is the only account of the change that
survives, so it has to carry the reason on its own.

That reader wants the problem first. A diff shows what changed; it never
shows what was wrong before, or what would break if the change were reverted.

## Follow the repository, or use this form

If the repository has a convention, follow it. Read `git log` to find out.
If it has none, use this form:

```
Retry only idempotent HTTP requests by default

PROBLEM
fetchWithRetry retried every failed request, including POSTs. A POST
that timed out had often already reached the payments API, so the
retry created a second order and charged the customer twice:

    POST /orders  -> timeout after 30 s (order 8841 created)
    POST /orders  -> 201 (order 8842 created)

SOLUTION
By default, fetchWithRetry now retries only GET, HEAD, PUT and DELETE.
A caller can opt a POST in with `retryNonIdempotent: true`, together
with an idempotency key header, so that the server can drop the
duplicate. Retries now wait with exponential backoff and full jitter,
starting at 200 ms and capped at 5 s.
```

The subject is written for someone who knows nothing about the project, in
72 characters or fewer. `PROBLEM` states what was wrong, in 100 words or
fewer, with a short concrete example when one exists, such as a code sample
or the wrong output; examples do not count toward the limit. `SOLUTION`
states what the change does about it, in 160 words or fewer. An optional
`DESIGN DISCUSSION` can follow, for structure, rejected alternatives and the
data behind the design.

Wrap the body at 72 columns, and check it with `scripts/commit-width.sh`
rather than by eye.

## The commit outlives the machine

A commit describes the change, not the circumstances of writing it. Leave out
home-folder paths, worktree names, ports, dev-server URLs, run IDs, and
anything that refers to the conversation ("as requested", "the user asked").
Name the lasting thing: "the local dev server", not ":8026". Issue numbers
are fine here; this is where they belong.

Do not state what you were not given. If the session never established the
retry count or the header name, the message does not name them.

## Failure modes

- **Diff narration.** The message repeats what the diff shows and never says
  what was wrong.
- **Session residue.** Paths, ports, run IDs or conversation references.
- **Insider subject.** A subject that only makes sense to someone who was
  there ("Fix the retry thing", "Address review").
- **Invented specifics.** A formula, limit or name that the change did not
  establish.
- **Convention override.** The PROBLEM / SOLUTION form forced onto a
  repository that already has its own.
