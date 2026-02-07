# Terma (གཏེར་མ)
[![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg

This is a highly-opinionated library of philosophy and process for developing software with LLMs, specifically Claude Code.

Distributed as a Claude Code plugin marketplace.

## Installation

From within Claude Code:

```
/plugin marketplace add <git-url-or-local-path>
/plugin install terma@terma
/plugin install terma@tsal
```

Or test locally during development:

```
claude --plugin-dir ./plugins/terma --plugin-dir ./plugins/tsal
```

## Quick Start

Use `/terma:orient` to begin each session. Use `/terma:research :question` to probe the codebase and write a report to `/research`. Then, use `/terma:plan` to plan a change to the application.

Use `/terma:implement` to spin up one or more well-instructed subagents to implement the plan.

Use `/terma:code-review` after implementation. Use `/terma:ideate` to brainstorm.

## Core Commands

| Command | Purpose |
|---------|---------|
| `/terma:orient` | Explore and summarize the project structure |
| `/terma:research` | Deep-dive investigation, writes report to `/research` |
| `/terma:plan` | Plan next steps without implementing |
| `/terma:implement` | Delegate implementation to subagents |
| `/terma:code-review` | Review code for quality and consistency |
| `/terma:ideate` | Brainstorm using the ideation card deck |

## Patterns

- feature dev: `/terma:orient`, `/terma:plan`, `/terma:implement`, `/terma:code-review`
- research: `/terma:orient`, `/terma:research`
- brainstorm: `/terma:ideate`

## Structure

```
.claude-plugin/marketplace.json   # Marketplace manifest
plugins/terma/                    # Process & philosophy plugin
  .claude-plugin/plugin.json      # Plugin manifest
  agents/                         # Subagent definitions
  skills/                         # Commands & meta skills
  lib/                            # Shared philosophy & process modules
plugins/tsal/                     # Domain-specific skills plugin
  .claude-plugin/plugin.json      # Plugin manifest
  skills/                         # Domain skills (bevy, godot, strudel, etc.)
```

## Customizing

Edit anything under `plugins/terma/` or `plugins/tsal/`. The `lib/` directory in terma contains composable modules referenced by skills via `@` paths. Domain-specific skills live in tsal and can be modified independently.

## Trivia

The `subagent.md` lib module encourages "ultrathinking", which may burn through usage quickly. Consider customizing it manually until we have variables.

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
