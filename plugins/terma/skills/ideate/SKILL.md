---
name: ideate
description: Brainstorm and explore ideas by generating alternative approaches, structured idea frameworks, and creative possibilities for a project or feature. Use when the user wants to ideate, think through options, spitball ideas, explore alternatives, or ask "what if" — e.g., "brainstorm features", "what are my choices here", "help me think through this", or "give me some alternatives".
---

# Ideate

I'm trying to brainstorm: $ARGUMENTS

## Workflow

1. **Understand the context** — Identify the problem space, constraints, and goals from `$ARGUMENTS` and the current project.
2. **Explore the idea deck** — Use a subagent or Task() to read and apply the guidance from @../../lib/ideate.md, which contains the full deck of ideation techniques and frameworks.
3. **Generate ideas** — Apply relevant techniques from the deck to produce a diverse set of ideas. Aim for breadth before depth.
4. **Present results** — Organise ideas into a clear, scannable output (e.g., grouped themes, ranked options, or a pros/cons breakdown) so the user can evaluate and act on them.

## Core Techniques (inline summary)

These three techniques are a good starting point before consulting the full deck:

- **Reverse assumptions** — List 5 assumptions baked into the current design, then write the opposite of each to find non-obvious directions. Ask: *"What if we removed this constraint entirely — what would that unlock?"* (e.g., "What if the user never has to log in?").
- **Combine or remix** — List existing features or concepts, then ask: *"What new value is created if I merge X with Y?"* (e.g., "Merge the search flow with the onboarding wizard — what does that experience look like?").
- **Solve adjacent problems** — Step one stage before and after the stated problem and ask: *"What struggle exists just outside the stated scope?"* (e.g., for a notification feature: "How do users *dismiss* or *action* those notifications — can we design for that too?").

Detailed technique guidance and the full idea deck are in @../../lib/ideate.md — read and apply that file for the complete set of frameworks.

## Example Output

Below is what a typical brainstorm result looks like for "add a notification feature":

**Theme A — Delivery mechanisms**
- In-app banner (low friction, easily dismissed)
- Email digest (async, suits low-urgency updates)
- Push notification (high attention, risk of fatigue)

**Theme B — User control**
- Per-channel mute/snooze controls
- Quiet-hours scheduling
- Preference centre accessible from every notification

**Theme C — Adjacent opportunity**
- "Action from notification" — let users resolve the triggering event without leaving the notification (e.g., approve a request inline)

*Ranked top pick:* In-app banner + inline action, because it minimises context switching while keeping interruption low.
