---
name: skill-management
description: Create, update, and manage Claude Code skills. Use when working with SKILL.md files, slash commands, or extending Claude's capabilities.
---

# Skills Quick Reference

Full docs: https://code.claude.com/docs/en/skills.md

## Skill Locations

| Location   | Path                                     | Scope            |
|------------|------------------------------------------|------------------|
| Personal   | `~/.claude/skills/<name>/SKILL.md`       | All your projects|
| Project    | `.claude/skills/<name>/SKILL.md`         | This project only|
| Plugin     | `<plugin>/skills/<name>/SKILL.md`        | Where enabled    |
| Enterprise | Managed settings                         | All org users    |

Priority: enterprise > personal > project. Plugin skills use `plugin:skill` namespace.

## Directory Structure

```
my-skill/
├── SKILL.md           # Required - main instructions
├── reference.md       # Optional - detailed docs (loaded on demand)
├── examples/          # Optional - example outputs
└── scripts/           # Optional - executable scripts
```

Keep SKILL.md under 500 lines; move detailed reference to separate files.

## Frontmatter Reference

```yaml
---
name: skill-name                    # Display name (defaults to directory name)
description: What it does           # RECOMMENDED - helps Claude decide when to use
argument-hint: [issue-number]       # Shown in autocomplete
disable-model-invocation: true      # Only user can invoke via /name
user-invocable: false               # Only Claude can invoke (hidden from / menu)
allowed-tools: Read, Grep, Glob     # Restrict tool access
model: opus                         # Model override (sonnet, opus, haiku)
context: fork                       # Run in isolated subagent
agent: Explore                      # Subagent type when context: fork
hooks: ...                          # Skill-scoped hooks
---
```

All fields optional. Only `description` is recommended.

## String Substitutions

Formatting purposes: all times it would be ! I have written ❗️.

| Variable               | Description                              |
|------------------------|------------------------------------------|
| `$ARGUMENTS`           | All arguments passed to skill            |
| `$ARGUMENTS[N]` / `$N` | Specific argument (0-indexed)            |
| `${CLAUDE_SESSION_ID}` | Current session ID                       |
| `` ❗️`command` ``       | Dynamic injection - runs before sending  |

If `$ARGUMENTS` not in content, args appended as `ARGUMENTS: <value>`.

## Invocation Control

| Setting                          | User invokes | Claude invokes | In context     |
|----------------------------------|--------------|----------------|----------------|
| (default)                        | Yes          | Yes            | Description    |
| `disable-model-invocation: true` | Yes          | No             | Not loaded     |
| `user-invocable: false`          | No           | Yes            | Description    |

## Subagent Execution

Add `context: fork` to run in isolation. Skill content becomes the subagent's task.

```yaml
---
name: deep-research
context: fork
agent: Explore        # or Plan, general-purpose, or custom agent name
---
Research $ARGUMENTS thoroughly...
```

Built-in agents: `Explore`, `Plan`, `general-purpose`. Custom agents from `.claude/agents/`.

## Dynamic Context Injection

Shell commands run BEFORE content sent to Claude:

```yaml
---
name: pr-summary
---
PR diff: ❗️`gh pr diff`
PR comments: ❗️`gh pr view --comments`

Summarize this PR...
```

## Extended Thinking

Include "ultrathink" anywhere in skill content to enable extended thinking.

## Common Patterns

**Reference skill** (conventions/guidelines):
```yaml
---
name: api-conventions
description: API design patterns for this codebase
---
When writing API endpoints:
- Use RESTful naming
- Return consistent error formats
```

**Task skill** (user-triggered action):
```yaml
---
name: deploy
description: Deploy to production
disable-model-invocation: true
context: fork
---
Deploy $ARGUMENTS:
1. Run tests
2. Build
3. Push to deployment target
```

**Read-only skill** (restricted tools):
```yaml
---
name: safe-reader
description: Explore without modifying
allowed-tools: Read, Grep, Glob
---
```

## Permissions

Restrict in `/permissions`:
- `Skill` - deny all skills
- `Skill(name)` - exact match
- `Skill(name *)` - prefix match with args

## Troubleshooting

- **Skill not triggering**: Check description keywords, verify with "What skills are available?"
- **Triggers too often**: Make description more specific or add `disable-model-invocation: true`
- **Missing skills**: Budget is 2% of context window. Set `SLASH_COMMAND_TOOL_CHAR_BUDGET` to override.
