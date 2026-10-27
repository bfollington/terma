# Writing eval

A blind A/B test for `writing-prose` and `writing-commits`. It answers one
question: does a reader prefer what an agent writes with these skills, over
what the same agent writes without them?

Run it from an agent session that can spawn subagents. Subagents do not
receive the user's AGENTS.md or CLAUDE.md, so a subagent loads a skill only
when the skill's description matches the task. To match a real session, the
skill arm's prompt includes the Writing Style section of AGENTS.md word for
word.

## Files

- `tasks/*.md` — one writing task per file. Each brief gives the facts the
  writer may use, and contains traps that the skills target: numbered points
  that invite back-references, session details (paths, ports, run IDs) that
  should stay out of a commit, and an unverified hunch that should stay marked
  as a guess.
- `judge.md` — the instructions for the blind judge.

## Procedure

1. For each task, spawn two writer subagents in each arm, with the brief
   inline. Each writer saves only its text to `<task>.<arm>.<n>.md` in a
   scratch folder and replies in one line, so the outputs stay out of the
   main conversation.
   - **base** — "Do not load any skill. Write in your normal default
     style. Use no tools except one Write call."
   - **skill** — "Follow these standing instructions:", then the Writing
     Style section of AGENTS.md, then "Use no tools except loading skills
     and one Write call." Ask it to name the skills it loaded.
2. For each task, shuffle the four outputs under the letters A to D. Write
   `judge.md`, the brief and the lettered responses into one file, and keep
   the letter-to-arm key in a separate file.
3. Spawn one judge subagent per task. Tell it not to load any skill, and to
   read only its blind file.
4. Map each judge's `RANKING:` line back to the arms through the key. Record
   the rank of each output, and the token count of each writer from its task
   notification.

## Reading the result

With two outputs per arm, an arm that makes no difference takes first place
in a task half the time, so it takes first place in all five tasks about one
time in 32. One judge per task is noisy, and most gaps are rated "slight", so
read the judges' quoted problems as well as the ranks. The quotes show what
to change next.

## Results so far

Two runs in October 2026, each with five tasks and two outputs per arm.

| Run | Skill version | Skill arm first | Mean rank, skill | Mean rank, base |
|---|---|---|---|---|
| 1 | first stance-based version | 5 of 5 tasks | 1.8 | 3.2 |
| 2 | adds reference entries, outside knowledge, openers | 5 of 5 tasks | 1.6 | 3.4 |

In run 1 the skill arm loaded skills from their descriptions alone. In run 2
its prompt also carried the Writing Style section of AGENTS.md, as a real
session does.

- The largest difference was invented specifics. Base outputs stated plausible
  details that were not in the brief: a backoff formula, a rejection rule, a
  reason for choosing full jitter, credential environment variables, a
  positional command-line argument. Skill outputs marked most outside
  knowledge as memory or guesswork.
- Skill outputs still made smaller errors of the same kind: "doubles" for
  "grows exponentially", an assumed "processing list", and one unmarked
  performance claim. One README used definition-list syntax, which GitHub
  does not render.
- `writing-prose` added about 2.5k tokens per writer. A task that also loads
  `writing-commits` added about 10k.
