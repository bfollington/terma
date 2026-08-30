# Terma (གཏེར་མ)
[![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg

A highly-opinionated library of philosophy and process for developing software with LLMs.

Works with any agent that reads `SKILL.md` — Claude Code, Codex, Cursor, Gemini CLI,
Zed, Copilot and others — and installs as a Claude Code plugin marketplace. Both read
the same files.

## Installation

**Any agent** — Claude Code, Codex, Cursor, Gemini CLI, Zed, Copilot and others,
via the [skills CLI](https://skills.sh):

```
npx skills add bfollington/terma
```

Add `-s convergent-planning,surface-forks` to take only some, or `-l` to list what's
there without installing.

For every project on the machine rather than the current one, install globally:

```
npx skills add bfollington/terma -g --skill '*' --agent '*' -y
```

Skills land in `~/.agents/skills/` — that is the real content, and the directory to
back up or edit. How each agent picks them up from there varies: some get a symlink
farm of their own (`~/.claude/skills/` is symlinks pointing back into `.agents`),
while others — Codex among them — read `~/.agents/skills/` directly and get no
per-agent directory at all. An empty `~/.codex/skills/` is not a failed install.

Update later with `npx skills update -g`. The repo is the source, so local edits under
`~/.agents/skills/` are overwritten on the next update — change `plugins/` and push
instead.

**Claude Code**, as a plugin marketplace:

```
/plugin marketplace add <git-url-or-local-path>
/plugin install terma@terma
/plugin install terma@tsal
```

Or during development:

```
claude --plugin-dir ./plugins/terma --plugin-dir ./plugins/tsal
```

Both work off the same files — the skills CLI reads `.claude-plugin/marketplace.json`
to find the plugin roots, so there is one source of truth and no duplication.

Pick one for Claude Code rather than running both: the plugin presents skills as
`terma:surface-forks` and a global install presents the same skill as `surface-forks`,
so together they show up twice. The one thing only the plugin carries is
`plugins/terma/agents/` — the skills CLI installs skills, not subagents, so a global
install leaves those 6 behind. Copy them to `~/.claude/agents/` if you want them.

## What's in it

Skills, not procedures. Each one is an index card of crystallized wisdom meant to change how a
situation is seen before anything is done — dense enough to be worth loading, narrow enough to
compose with the others. Most fire on their own when the situation calls for them.

**Thinking about change**

| Skill | The idea |
|-------|----------|
| `surface-forks` | Find what a change collides with before making it, then name the routes through |
| `convergent-planning` | A plan is a sequence of ambiguity collapses; a step nothing could contradict is not a step |
| `concurrent-change` | What can happen at once is decided by what the pieces must agree on |
| `idea-to-prototype` | Open, then close, then open — and find the fastest thing that would settle it |

**Thinking about code**

| Skill | The idea |
|-------|----------|
| `writing-code` | Values over places, data over ceremony, the program as the story of what it does |
| `domain-modeling` | The model is a claim about the world; the words are the model |
| `decomposition` | Boundaries isolate change, not enable reuse — cut by what changes together |
| `implement` | Always know the distance to the last checkpoint; stop rather than compensate |
| `code-review` | Not whether the code is good — what it will cost the next person to change it |
| `investigate-debug` | The discipline of not knowing yet; every action should divide the possibilities |

**Getting oriented, and everything else**

| Skill | The idea |
|-------|----------|
| `orient` | Build a model that predicts, not a summary that covers |
| `research` | Answer the question actually asked, at a confidence stated honestly |
| `ideate` | A deck of moves — good thinking is playing the right card at the right time |
| `authoring-skills` | Say the thing that is not already known; cut rather than append |
| `skill-improver` | Turn real friction into a change, usually a sharper sentence rather than a new one |

`plan` routes to whichever of the planning skills the moment calls for.

## Patterns

- feature dev: `orient`, `plan`, `surface-forks`, `implement`, `code-review`
- research: `orient`, `research`
- something is broken: `investigate-debug`
- a new idea: `ideate`, `idea-to-prototype`

## Structure

```
.claude-plugin/marketplace.json   # Marketplace manifest
plugins/terma/                    # Process & philosophy plugin
  .claude-plugin/plugin.json      # Plugin manifest
  agents/                         # Subagent definitions
  skills/                         # One directory per skill, each a self-contained SKILL.md
plugins/tsal/                     # Domain-specific skills plugin
  .claude-plugin/plugin.json      # Plugin manifest
  skills/                         # Domain skills (bevy, godot, strudel, etc.)
```

## Customizing

Edit anything under `plugins/terma/` or `plugins/tsal/`. Each skill is self-contained — there are
no shared includes to chase, so a skill can be rewritten or deleted without touching anything else.
`authoring-skills` describes what a good one looks like if you want to add your own.

`CANDIDATES.md` lists skills worth writing and the reasoning for each, deliberately unwritten
until real friction calls for them.

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
