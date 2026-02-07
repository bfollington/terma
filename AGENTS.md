# Agents Guide

Instructions for AI agents working on this repository.

## What This Is

Terma is a Claude Code plugin marketplace. The repo root is the marketplace, and `plugins/terma/` contains the terma plugin with commands, agents, skills, and shared lib modules.

## Repository Layout

```
.claude-plugin/marketplace.json     # Marketplace manifest
plugins/terma/                      # The terma plugin
  .claude-plugin/plugin.json        # Plugin manifest
  commands/                         # Slash commands (18 .md files)
  agents/                           # Subagent definitions (6 .md files)
  skills/                           # Domain skills (bevy, godot, strudel, etc.)
  lib/                              # Shared philosophy & process modules
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
3. Checking skills are discoverable (e.g. bevy, godot, strudel)

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

### How Commands Reference Shared Modules

Commands in `plugins/terma/commands/` reference shared modules in `plugins/terma/lib/` using `@` path syntax:

```markdown
Read and apply the guidance from @../lib/feature.md
```

Lib modules can reference other lib modules:

```markdown
Read and apply the guidance from @./thought-process.md
```

When the plugin is installed, the entire `plugins/terma/` directory is cached, so all internal relative paths resolve correctly.

### Adding a New Command

1. Create a `.md` file in `plugins/terma/commands/`
2. Use `$ARGUMENTS` to capture user input
3. Reference lib modules with `@../lib/module.md` for shared guidance
4. The command will be available as `/terma:command-name`

### Adding a New Skill

1. Create a directory under `plugins/terma/skills/`
2. Add a `SKILL.md` with YAML frontmatter (`name`, `description`)
3. Add `references/` subdirectory for supporting documentation
4. Add `assets/` for templates, examples, etc.

### Adding a New Agent

1. Create a `.md` file in `plugins/terma/agents/`
2. Include YAML frontmatter with `name`, `description`, and optionally `color`
3. Write the system prompt as the markdown body

## Project-Local Commands

The `.claude/commands/` directory contains commands specific to developing terma itself (modularize, review, suggest). These are not part of the distributed plugin.
