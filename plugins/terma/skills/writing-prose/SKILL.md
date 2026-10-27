---
name: writing-prose
description: Use when writing prose that someone else will read — a reply, a report, a review, a proposal, documentation, a message about ideas or design, a prompt or a tool description. Concerns the stance to write from — picture the reader at the moment they find the text, and write for that moment, so that the meaning arrives intact. Optimises for clarity and legibility, not for brevity, simple words or short sentences. Trigger on any prose longer than a few sentences. Do NOT use for commit messages (writing-commits covers those) or for the code itself (writing-code). Do NOT use to convert a text into a controlled language such as ASD-STE100.
---

# Writing Prose

Write from where the reader will be standing, not from where you are.

Before writing, picture the moment someone finds this text. Who are they?
What were they doing just before? What do they already hold in their head,
and what will they do next? Then write the text that moment needs. This is
a stance, not a checklist, and it produces different text in different
moments.

The goal is that the meaning arrives intact. Brevity, plain words and short
sentences sometimes serve that goal and sometimes defeat it. A terse message
that the reader has to decode has moved the work onto the reader. A plain
word that is less exact than the technical one has lost information. A text
cut into short declarative sentences can lose the reasons that connected
them. Optimise for understanding, and let length, register and vocabulary
follow from who is reading.

## The writer's context is invisible from inside

You always hold context the reader lacks, and you cannot see it, because you
fill the gaps without noticing. The text looks clear to you for exactly that
reason. So read the draft as the person who finds it, and look for the places
where it leans on something they do not have:

- a reference back to the conversation ("as discussed", "your point (1)", a
  pronoun whose noun is in an earlier turn);
- a label coined during the work ("option B", "the fix", "the second agent");
- a term the reader may not share. For a reader outside the field, describe
  what the thing does. For a reader in the field, keep the precise term, and
  add a gloss only if it might be ambiguous;
- notation standing in for a sentence (`A → B`, `X × Y`).

The person reading may be running many sessions at once. Even in a live
conversation, they return to this thread from somewhere else, so restate
enough for them to re-enter.

## The same stance, different moments

**An engineer in a live conversation.** They are mid-task and want to act.
Lead with what changed, what you found, or what you need from them. Give the
evidence next, then the detail. Density is welcome when they share the
vocabulary. Conversational tone is fine; padding is not.

**Text that stays.** Documentation, PR descriptions and reports are read later
by someone with no session at all, often arriving by search or by link. State
the durable thing, not the story of how you got there. Structure the text so
it can be scanned and entered in the middle. A reference is read one entry
at a time, so every entry says what it does, its default and its limits,
even when the name seems to say it already. Leave out anything that belongs
to this machine or this session.

**Ideas, design and creative work.** The reader is thinking with you, not
receiving a result. Keep options open where they are open. An analogy that
maps structure ("this is a cache with a human in the eviction loop") carries
meaning and belongs here. Show the reasoning, because the reasoning is the
content. Mark which ideas are considered and which are first thoughts.

**Text an agent parses in order to act.** Tool descriptions, error messages
and handoff instructions are read by something that will do exactly what the
words say and cannot ask. Be literal. Write one instruction per sentence. Name
every condition, default and limit. Say what to do next. This is the one
place where controlled, flat language is the right register.

**Text that shapes how an agent thinks.** Skills, system prompts and persona
instructions work differently. A model takes on the frame the words set up,
and the text produces the behavior it describes. A named exemplar ("write code
like Rich Hickey"), an idiom or a vivid image can set that frame in a few
words, where a literal list of rules sets it weakly. Use them when they
produce the behavior. A single file can hold several of these moments. A
skill shapes thinking, but its worked example may be written for a person.

## What holds in every moment

**Mark guesses as guesses.** A sentence that argues, instead of describes, is
where an unfounded claim hides. A motive, a justification, a "which is why",
a claim about how people behave or how code will behave all read as
background, so nobody checks them. Name the evidence, or mark the guess and
give its reason: "I'd guess this, because …". Knowledge from outside the
task counts too: what other products do, what is typical, what "people
commonly run". Say that it is from memory. Do not supply a plausible
specific that you were not given. It reads as fact, and the reader cannot
tell it from the facts around it. Keep the strength of every claim; "may have
failed" stays "may have failed". In a report, keep what was verified, and how,
apart from what was inferred.

**Keep the reason.** The sentence that explains why is often the most useful
one in the text. When you split or trim, do not cut the "because".

**Lead with what matters.** Put the main point in the main clause and the most
important thing first. "It is important that the cache is warm", not "The
cache is warm, and that is important".

**Say it, do not perform it.** In text for people, a figure of speech that
replaces a direct statement ("a dial worth turning" for "a parameter worth
varying", "earns its keep" for "is still useful") makes the reader translate
it and brings meanings you did not choose. The test is whether the figure
carries meaning the literal phrase cannot. Emphasis is the same habit in a
smaller form. Drop intensifiers, stress formatting, marketing adjectives,
announcements of what comes next, openers that grade the question ("good
questions", "all fair points"), and repetition.

## Failure modes

- **Writing from inside.** The text is clear to the writer and to nobody who
  arrives cold.
- **One register for everything.** The same flat style for a design
  conversation and an error message, or chat looseness in documentation.
- **Compression mistaken for clarity.** Short, dense text that the reader has
  to unpack.
- **Simplification that loses precision.** A plain phrase in place of the
  exact term, for a reader who knew the exact term.
- **Plausible inventions.** Specifics that fit the story but were never given,
  stated in the same voice as the facts.
- **Lost reasons.** Sentences that state what happens and no longer say why.
- **Performance.** Figures and emphasis that display the writer and carry no
  extra meaning.
- **Flattened prompts.** A skill or system prompt rewritten into literal rules,
  so the framing that produced the behavior is gone.
