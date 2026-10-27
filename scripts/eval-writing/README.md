# Writing eval

A blind A/B test for `writing-prose` and `writing-commits`. It answers one
question: does a reader prefer what an agent writes with these skills, over
what the same agent writes without them?

Run it from an agent session that can spawn subagents. Start a new session
after you change AGENTS.md or a skill, because subagents may see the
instructions that were loaded when the session started.

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
   - **base** — "Ignore any writing-style section in your standing
     instructions, and do not load any skill. Write in your normal default
     style. Use no tools except one Write call."
   - **skill** — "Follow all of your standing instructions. Use no tools
     except loading skills and one Write call." Ask it to name the skills it
     loaded, to confirm that loading works without a prompt.
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

October 2026, five tasks, two outputs per arm:

- An output from the skill arm ranked first in all five tasks. The mean rank
  was 1.8 for the skill arm and 3.2 for the base arm.
- The largest difference was invented specifics. Base outputs stated plausible
  details that were not in the brief, such as a backoff formula, a rejection
  rule and a time estimate. Skill outputs marked most outside knowledge as
  memory or guesswork.
- `writing-prose` added about 2.5k tokens per writer.
