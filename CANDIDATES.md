# Candidate Skills

Skills worth writing, and the reasoning for each. Not a backlog to burn down — a skill
written to clear an entry here is a skill written from imagination, which is the failure
mode `authoring-skills` warns about. These wait until real friction says they are needed.

Each entry names what it would say, why it is not covered by what exists, and what would
make it hard to write well.

---

### hold-the-thread

**The idea.** Record-keeping as a first-class practice, at two scales at once: the macro
task, so its shape is never lost, and the details as they are completed, so none are
dropped on the floor. The point is that the user should not have to double-check
everything — the record is what makes the work auditable without re-doing it.

This is bigger than notes for a single session. It is how a project maintains a memory
structure over its whole life: something closer to a wiki or an Obsidian vault than a
scratch file, where entries accumulate, link, and stay navigable.

Three pieces:

- **Epistemic honesty in the record.** Only what is known to be factual gets recorded as
  fact. What is not known is recorded *as* not known. The distinction between established,
  inferred, and assumed has to survive into the artifact, because that is what makes the
  reasoning reconstructable later. A record that flattens all three into confident prose
  is worse than no record — it launders guesses into facts.

- **Reconstructable decisions.** Statements should be written so a reader can rebuild not
  just what was decided but why, and what was rejected. This is what makes a record
  usable in three months instead of merely archaeological.

- **Embodied in code and tools, not only text.** Prose degrades and goes stale. A script,
  a check, a generated index, a test that states a rule — these hold the thread in a way a
  paragraph cannot, because they fail when they stop being true. The skill should push
  toward mechanisms wherever a mechanism will do the job that a note is being asked to do.

And it must keep the *user* in sync over a long project, which is a design problem in its
own right: what to surface, when, at what granularity, without producing a firehose.

**Why it is not covered.** `investigate-debug` has a small version scoped to a single
investigation. Nothing covers the project scale, the epistemic discipline, or the
tools-over-prose move.

**The hard part.** Not becoming a note-taking template — the old `investigate-debug`
failed exactly there, with fill-in-the-blank forms. The wisdom is in the selection (what
survives, what is disposable, what should be a mechanism instead) rather than in a
structure to fill. This is a genuinely hard skill to write and probably the most valuable
of these, because it is a place LLMs reliably fail.

**Priority.** First.

---

### knowing-when-it-is-futile

**The idea.** Not "stop more often" — agents that stop preemptively are worse than ones
that push. The two real failures are opposite: **quitting on something that was actually
doable**, and **grinding on when the task is provably impossible or the plan is flawed**.

The second is the more interesting one. When an agent has genuinely established that what
it was asked for cannot be done as specified — the premise is false, the plan contradicts
itself, the task is impossible — continuing to try is not diligence, it is waste. But the
resolution is not to halt. It is to **call up the stack**: report to the supervising agent
or the user with what was established and why it forecloses the approach.

So the bar is high. Escalate only when sure it is impossible, and escalate *with the
evidence*, not with a shrug.

**Why it is not covered.** `implement` says stop rather than compensate, but is about
noticing drift mid-task. `convergent-planning` says a failed check means re-plan. Neither
addresses the case where the whole task is unachievable as framed, nor the escalation
move — which is the actual content here.

**The hard part.** Calibration is everything, and it cuts both ways. Written loosely it
produces agents that give up on hard-but-doable work, which is a worse outcome than
over-persistence. It needs the specific tells that distinguish *hard* from *impossible*,
and a genuinely high bar for the escalation. "Be sure" is not a bar; the skill has to say
what sure looks like.

**Priority.** Second, and only worth writing if the calibration can be made concrete.

---

### user-preferences

**The idea.** Possibly nothing. Recorded here because the honest version of the idea
originally filed as "taste" turned out to be something else.

What is *not* a skill: structure first, clear and easy to understand, functional-programming
inspired. Those read like aesthetic taste but are ways of working, and `writing-code` and
`decomposition` already carry them.

What might be left is the genuinely personal layer — this user prefers to work in these
ways, in these situations — which is preference capture rather than wisdom. That may
belong in memory rather than in a skill, since it is per-user and not a reusable mental
model.

Aesthetic taste proper is probably not skill material at all.

**The hard part.** Separating a preference worth recording from a rule that already
exists elsewhere, without producing a vague page about liking good code. It is unclear
this should exist; it is filed so the question is not re-opened from scratch.

**Priority.** Unresolved. Revisit only if a concrete case appears where an agent got
something wrong that a stated preference would have prevented.

---

### thinking-out-loud (not a skill — a prompt)

**Resolved: this should not be an agent-invoked skill.**

The original idea was that an agent would detect a musing and respond by opening the space
rather than executing. But the natural form is the opposite: something typed manually at
the start of a session to set the frame — *here is what we are doing, this is pie in the
sky, I am imagining what is possible.*

That is a user-supplied frame, not an inference the agent should be making. `map-the-space`
already handles the response once the frame is set, and its trigger covers the detection
case well enough.

So: no skill. If anything, a short snippet or prompt template kept outside the skills
directory.

---

## Notes on writing any of these

The bar is `surface-forks`: a reframe that changes how the situation is seen, concrete
enough to act on, with failure modes that name traps invisible from inside. See
`plugins/terma/skills/authoring-skills/SKILL.md`.

Two tests before starting. Has the friction actually occurred, more than once? And would
the content have been produced anyway without the skill? A yes to the second means there
is nothing to write yet.
