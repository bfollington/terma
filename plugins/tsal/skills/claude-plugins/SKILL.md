# Claude Code Plugins Quick Reference

Full docs:
- [Create plugins](https://code.claude.com/docs/en/plugins.md)
- [Discover & install plugins](https://code.claude.com/docs/en/discover-plugins.md)
- [Plugins reference](https://code.claude.com/docs/en/plugins-reference.md)
- [Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces.md)

## Plugins vs Standalone

| Approach | Skill names | Best for |
|----------|-------------|----------|
| **Standalone** (`.claude/`) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teams, community distribution, versioned releases |

## Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json      # Required manifest
├── commands/            # Slash commands (Markdown files)
├── skills/              # Agent skills (SKILL.md files)
├── agents/              # Custom agent definitions
├── hooks/
│   └── hooks.json       # Event handlers
├── .mcp.json            # MCP server configs
└── .lsp.json            # LSP server configs
```

**Common mistake**: Don't put `commands/`, `skills/`, etc. inside `.claude-plugin/`. Only `plugin.json` goes there.

## Manifest (plugin.json)

```json
{
  "name": "my-plugin",
  "description": "What the plugin does",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  },
  "homepage": "https://github.com/you/my-plugin",
  "repository": "https://github.com/you/my-plugin",
  "license": "MIT"
}
```

The `name` field becomes the skill namespace prefix (e.g., `/my-plugin:hello`).

## Quick Commands

### Marketplace Management

```bash
# Add marketplaces
/plugin marketplace add owner/repo              # GitHub
/plugin marketplace add https://gitlab.com/org/repo.git  # Other Git
/plugin marketplace add ./local-path            # Local directory
/plugin marketplace add https://example.com/marketplace.json  # URL

# Add specific branch/tag
/plugin marketplace add owner/repo#v1.0.0

# List, update, remove
/plugin marketplace list
/plugin marketplace update marketplace-name
/plugin marketplace remove marketplace-name
```

Shortcuts: `/plugin market` works, `rm` instead of `remove`

### Plugin Installation

```bash
# Install (defaults to user scope)
/plugin install plugin-name@marketplace-name

# Install with specific scope
claude plugin install plugin-name@marketplace-name --scope project
claude plugin install plugin-name@marketplace-name --scope local

# Enable/disable without uninstalling
/plugin disable plugin-name@marketplace-name
/plugin enable plugin-name@marketplace-name

# Uninstall
/plugin uninstall plugin-name@marketplace-name
```

### Interactive UI

```bash
/plugin    # Opens plugin manager with tabs:
           # - Discover: browse available plugins
           # - Installed: manage your plugins
           # - Marketplaces: add/remove marketplaces
           # - Errors: view loading errors
```

Navigate tabs with **Tab** / **Shift+Tab**

## Installation Scopes

| Scope | Who sees it | Stored in |
|-------|-------------|-----------|
| **User** | You, all projects | `~/.claude/settings.json` |
| **Project** | All collaborators | `.claude/settings.json` |
| **Local** | You, this repo only | `.claude/settings.local.json` |
| **Managed** | All org users | Admin-controlled |

## Testing During Development

```bash
# Load plugin from local directory
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

Restart Claude Code after making changes.

## Official Marketplace Plugins

### Code Intelligence (LSP)

| Language | Plugin | Binary required |
|----------|--------|-----------------|
| TypeScript | `typescript-lsp` | `typescript-language-server` |
| Python | `pyright-lsp` | `pyright-langserver` |
| Rust | `rust-analyzer-lsp` | `rust-analyzer` |
| Go | `gopls-lsp` | `gopls` |
| C/C++ | `clangd-lsp` | `clangd` |

Install: `/plugin install typescript-lsp@claude-plugins-official`

### External Integrations (MCP)

`github`, `gitlab`, `atlassian`, `asana`, `linear`, `notion`, `figma`, `vercel`, `firebase`, `supabase`, `slack`, `sentry`

### Development Workflows

`commit-commands`, `pr-review-toolkit`, `agent-sdk-dev`, `plugin-dev`

## Creating a Skill in a Plugin

Create `skills/my-skill/SKILL.md`:

```yaml
---
name: my-skill
description: What the skill does. Use when [context].
---

Instructions for Claude when this skill is invoked...
```

## Creating a Command in a Plugin

Create `commands/hello.md`:

```yaml
---
description: Greet the user
disable-model-invocation: true
---

Greet the user named "$ARGUMENTS" warmly.
```

Use as: `/my-plugin:hello Alex`

## Hooks in Plugins

Create `hooks/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{
          "type": "command",
          "command": "jq -r '.tool_input.file_path' | xargs npm run lint:fix"
        }]
      }
    ]
  }
}
```

## LSP Configuration

Create `.lsp.json` at plugin root:

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

## Auto-Updates

- Official marketplaces: auto-update enabled by default
- Third-party/local: disabled by default
- Toggle per-marketplace in `/plugin` > Marketplaces
- Disable all: `export DISABLE_AUTOUPDATER=true`
- Plugins only: `DISABLE_AUTOUPDATER=true FORCE_AUTOUPDATE_PLUGINS=true`

## Team Setup

Add to `.claude/settings.json` for automatic marketplace prompts:

```json
{
  "extraKnownMarketplaces": ["your-org/team-plugins"],
  "enabledPlugins": ["plugin-name@your-org-team-plugins"]
}
```

## Troubleshooting

- **`/plugin` not recognized**: Requires Claude Code 1.0.33+. Run `claude --version`
- **Plugin skills not appearing**: `rm -rf ~/.claude/plugins/cache`, restart, reinstall
- **LSP binary not found**: Check `/plugin` Errors tab, install required binary
- **Marketplace not loading**: Verify `.claude-plugin/marketplace.json` exists at path
- **Files not found**: Plugins are cached; paths outside plugin directory won't work

## Convert Standalone to Plugin

1. Create `my-plugin/.claude-plugin/plugin.json`
2. Copy `.claude/commands` to `my-plugin/commands/`
3. Copy `.claude/skills` to `my-plugin/skills/`
4. Move hooks from `settings.json` to `my-plugin/hooks/hooks.json`
5. Test: `claude --plugin-dir ./my-plugin`
