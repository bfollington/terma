# Agents Guide

Instructions for AI agents working on this repository.

## What This Is

Terma is a Claude Code plugin marketplace. The repo root is the marketplace, containing two plugins: `plugins/terma/` (development process commands, agents, and lib modules) and `plugins/tsal/` (domain-specific skills).

## Repository Layout

```
.claude-plugin/marketplace.json     # Marketplace manifest
plugins/terma/                      # Process & philosophy plugin
  .claude-plugin/plugin.json        # Plugin manifest
  agents/                           # Subagent definitions (6 .md files)
  skills/                           # Self-contained skills, one directory each
plugins/tsal/                       # Domain-specific skills plugin
  .claude-plugin/plugin.json        # Plugin manifest
  skills/                           # Domain skills (bevy, godot, strudel, etc.)
.claude/commands/                   # Project-local dev commands (not part of plugin)
build.ts, build.sh                  # Legacy build tools (optional)
```

## Validating the Marketplace

Validate the marketplace structure:

```bash
claude plugin validate .
```

Or from within Claude Code:

```
/plugin validate .
```

This checks:
- `.claude-plugin/marketplace.json` exists and is valid JSON
- Plugin sources resolve correctly
- Plugin manifests are well-formed

## Testing Locally

Load the plugin directly without installing:

```bash
claude --plugin-dir ./plugins/terma
```

This makes all terma commands, agents, and skills available in the session. Verify by:

1. Checking commands are visible: `/terma:feature`, `/terma:plan`, etc.
2. Checking agents appear in the agents list
3. Checking skills are discoverable (e.g. skill-improver)

To test tsal:

```bash
claude --plugin-dir ./plugins/tsal
```

Verify domain skills are discoverable (e.g. bevy, godot, strudel)

## Installing from Local Path

To test the full marketplace flow:

```
/plugin marketplace add ./path/to/terma
/plugin install terma@terma
```

To uninstall:

```
/plugin uninstall terma@terma
```

## Managing the Marketplace

### Adding a Plugin

1. Create a new directory under `plugins/`
2. Add `.claude-plugin/plugin.json` with at minimum a `name` field
3. Add commands, agents, skills as needed
4. Add an entry to `.claude-plugin/marketplace.json` in the `plugins` array

### Updating the Plugin Version

Update the version in both:
- `plugins/terma/.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json` (the plugin entry's `version` field)

### Skills Are Self-Contained

Terma skills do not share includes. Each `SKILL.md` stands alone, so it can be read, rewritten, or
deleted without tracing a chain of `@` references, and loading one does not silently pull in five
others. There was previously a `lib/` directory of shared modules referenced via `@` paths; it was
dissolved into the skills themselves.

Where two skills genuinely adjoin, name the neighbour in prose rather than including it — the reader
can load it if the moment calls for it.

The house style is described in `plugins/terma/skills/authoring-skills/SKILL.md`. In short: say what
would not have been done anyway, one subject per skill, a description that states both when it fires
and when it does not, and a failure-modes list at the end.

### Adding a New Skill

Domain-specific skills go in `plugins/tsal/skills/`. Meta/process skills go in `plugins/terma/skills/`.

1. Create a directory under the appropriate plugin's `skills/`
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Add `references/` subdirectory for supporting documentation
4. Add `assets/` for templates, examples, etc.

### Adding a New Agent

1. Create a `.md` file in `plugins/terma/agents/`
2. Include YAML frontmatter with `name`, `description`, and optionally `color`
3. Write the system prompt as the markdown body

## Project-Local Commands

The `.claude/commands/` directory contains commands specific to developing terma itself (modularize, review, suggest). These are not part of the distributed plugin.
