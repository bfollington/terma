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

Use `/terma:orient` to begin each session. Use `/terma:research :question` to probe the codebase and write a report to `/research`. Then, use `/terma:plan` or just `/terma:feature` to plan a change to the application.

Use `/terma:implement` to spin up one or more well-instructed subagents to implement the plan.

You may find use for `/terma:debug`, `/terma:code-review`, `/terma:harden` after implementation.

When you are at a known good state (i.e. about to commit) use `/terma:progress` to write a progress report and update `LOG.md`, then commit w/ the `.md` file included. `/terma:next-up` is like `/terma:progress` but moves straight on to whatever additional task you provide.

You can use `/terma:bug-report` to interactively gather and record context for known issues, and use `/terma:resolve` to resolve them.

We currently assume a protocol of `LOG.md`, `BUGS.md`, `SPEC.md`, `CLAUDE.md` etc. but this will and should be customized to fit.

## Patterns

- feature dev: `/terma:orient`, `/terma:feature`, `/terma:implement`, `/terma:progress`, `/compact` (loop)
  - then: `/terma:code-review`

- bugs: `/terma:bug-report`, `/terma:debug`, `/terma:resolve`, `/terma:code-review`

- tech spike: `/terma:prototype`, `/terma:debug`

- improve codebase architecture: `/terma:orient`, `/terma:research`, `/terma:decompose`, `/terma:code-review`

## Structure

```
.claude-plugin/marketplace.json   # Marketplace manifest
plugins/terma/                    # Process & philosophy plugin
  .claude-plugin/plugin.json      # Plugin manifest
  commands/                       # Slash commands
  agents/                         # Subagent definitions
  skills/                         # Meta skills (skill-improver)
  lib/                            # Shared philosophy & process modules
plugins/tsal/                     # Domain-specific skills plugin
  .claude-plugin/plugin.json      # Plugin manifest
  skills/                         # Domain skills (bevy, godot, strudel, etc.)
```

## Customizing

Edit anything under `plugins/terma/` or `plugins/tsal/`. The `lib/` directory in terma contains composable modules referenced by commands via `@` paths. Domain-specific skills live in tsal and can be modified independently.

## Trivia

The `subagent.md` lib module encourages "ultrathinking", which may burn through usage quickly. Consider customizing it manually until we have variables.

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
