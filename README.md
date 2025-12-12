# Terma (གཏེར་མ)

[![Run in Smithery](https://smithery.ai/badge/skills/bfollington)](https://smithery.ai/skills?ns=bfollington&utm_source=github&utm_medium=badge)

[![CC BY-SA 4.0][cc-by-sa-shield]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-shield]: https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg

This is a highly-opinionated library of philosophy and process for developing software with LLMs, specifically Claude Code.

Copy/clone the contents of `out` into `~/.claude/commands` to install these across all projects.

## Installation

`mkdir -p ~/.claude/commands/terma`
`mkdir -p ~/.claude/agents/terma`

`ln -s <CHECKOUT>/out/commands ~/.claude/commands/terma`
`ln -s <CHECKOUT>/subagents ~/.claude/agents/terma`

## Quick Start

Use `/orient` to begin each session. Use `/research :question` to probe the codebase and write a report to `/research`. Then, use `/plan` or just `/feature` to plan a change to the application.

Use `/implement` to spin up one or more well-instructed subagents to implement the plan.

You may find use for `/debug`, `/code-review`, `/harden` after implementation.

When you are at a known good state (i.e. about to commit) use `/progress` to write a progress report and update `LOG.md`, then commit w/ the `.md` file included. `/next-up` is like `/progress` but moves straight on to whatever additional task you provide.

You can use `/bug-report` to interactiely gather and record context for known issues, and use `/resolve` to resolve them.

We currently assume a protocol of `LOG.md`, `BUGS.md`, `SPEC.md`, `CLAUDE.md` etc. but this will and should be customized to fit.

## Patterns

- feature dev: `/orient`, `/feature`, `/implement`, `/progress`, `/compact` (loop)
  - then: `/code-review`

- bugs: `/bug-report`, `/debug`, `/resolve`, `/code-review`

- tech spike: `/prototype`, `/debug`

- improve codebase architecture: `/orient`, `/research`, `/decompose`, `/code-review`

## Customizing

The build depends on `deno`.
You can edit anything in `lib` or the root and run and use `./build.sh` to rebuild all. We use a simple `remark` transform for text inclusion, nothing fancy.

## Trivia

The `subagent.md` file encourages "ultrathinking", which may burn through usage quickly. Consider customizing it manually until we have variables.

## License

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/).
