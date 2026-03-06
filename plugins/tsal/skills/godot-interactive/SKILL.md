---
name: godot-interactive
description: "Interact with a running Godot game via MCP — launch, screenshot, click, inspect scene tree, get/set properties. Powered by godot-mcp + GodotMCPBridge autoload. Use when debugging Godot games, testing game behavior, automating game interactions, or validating UI layouts in a Godot project. Useful for game development workflows involving automated UI testing, visual debugging, verifying game state, or creating reproducible test scenarios for .gd / GDScript-based projects."
---

# Godot Interactive Testing Skill

Playwright-like interaction loop for Godot games via MCP. Launch, observe, click, inspect, and manipulate a running game through a bridge autoload.

## Overview

This skill enables LLM-driven interactive testing of Godot games through the godot-mcp MCP server and a GodotMCPBridge autoload. The core loop is: **observe → inspect → interact → verify** (see Core Workflow below).

## Prerequisites

**godot-mcp server:**
- Installed at `~/code/godot-mcp` (or configurable path)
- Built with `npm install && npm run build`
- Repository: https://github.com/yourusername/godot-mcp

**Godot project setup:**
- GodotMCPBridge autoload installed
- Remote debugger enabled (automatic when running via `run_project`)

## Setup for New Projects

### 1. Copy the Bridge Autoload

```bash
cp assets/templates/godot_mcp_bridge.gd res://scripts/autoload/godot_mcp_bridge.gd
```

### 2. Register the Autoload

Add to `project.godot`:
```ini
[autoload]
GodotMCPBridge="*res://scripts/autoload/godot_mcp_bridge.gd"
```

Or via editor: Project → Project Settings → Autoload → add `GodotMCPBridge`.

### 3. Create MCP Configuration

```bash
cp assets/templates/mcp.json.template .mcp.json
```

Edit paths:
```json
{
  "mcpServers": {
    "godot": {
      "command": "node",
      "args": ["<PATH_TO_GODOT_MCP>/build/index.js"],
      "env": {
        "GODOT_PATH": "<PATH_TO_GODOT_BINARY>"
      }
    }
  }
}
```

## MCP Tools Reference

| Tool | Purpose | Key Notes |
|---|---|---|
| `run_project(projectPath)` | Launch project with remote debugger | Wait 2–3 s or poll `get_debug_output()` before other calls |
| `stop_project()` | Stop the running project | Always call when done |
| `get_debug_output()` | Retrieve stdout/stderr (most recent first) | Confirm bridge startup: "Godot MCP Bridge initialized" |
| `game_screenshot()` | Capture viewport as base64 PNG | Use this, not upstream DAP `capture_screenshot` |
| `game_scene_tree(path?, depth?)` | Inspect scene tree with types, `rect`, `visible`, `text` | Default: `/root`, depth 3; `rect` is full-window coordinates |
| `game_click(x, y, button?)` | Simulate mouse click; auto-screenshot 200 ms after | `button`: 1=left (default), 2=right, 3=middle |
| `game_key(key)` | Simulate key press (Godot key names, case-sensitive) | E.g. `"Space"`, `"Escape"`, `"Enter"`, `"F1"`–`"F12"` |
| `game_action(name)` | Trigger an InputMap action by name | Action must exist in project's InputMap |
| `game_get_property(node_path, property)` | Read a node property at runtime | Vectors returned as `{x,y,z}`, Color as `{r,g,b,a}` |
| `game_set_property(node_path, property, value)` | Write a node property; auto-screenshot 100 ms after | Use JSON objects for vectors: `{x, y}` or `{x, y, z}` |

**⚠️ Key gotcha:** UI coordinates are full window resolution (e.g., 1920×1080), not screenshot pixel coordinates. Always use `game_scene_tree` `rect` values for click coordinates — never guess from screenshot pixels.

## Core Workflow: Observe → Inspect → Interact → Verify

```typescript
// 1. Launch and confirm startup
run_project({ projectPath: "/Users/ben/code/my-game" })
get_debug_output()  // Wait for "Godot MCP Bridge initialized"

// 2. Observe initial state
game_screenshot()

// 3. Inspect scene tree to find button position
game_scene_tree({ path: "/root/Main/UILayer", depth: 3 })
// Find: { name: "PlayButton", rect: {x: 860, y: 520, w: 200, h: 80} }

// 4. Click button center (use rect, not screenshot pixels)
game_click({ x: 960, y: 560 })

// 5. Verify result visually and via state
game_screenshot()
game_get_property({ node_path: "/root/Main", property: "state" })
get_debug_output()

// 6. Clean up
stop_project()
```

### Forcing Game States for Testing

Skip manual play to reach specific scenarios:

```typescript
run_project({ projectPath: "/path/to/game" })

// Jump to level 5
game_set_property({ node_path: "/root/Main", property: "current_level", value: 5 })

// Force victory popup visible
game_set_property({
  node_path: "/root/Main/UILayer/VictoryPopup",
  property: "visible",
  value: true
})

game_screenshot()
game_click({ x: 760, y: 500 })  // Click OK using rect from game_scene_tree
stop_project()
```

### Debugging Visual Issues

```typescript
run_project({ projectPath: "/path/to/game" })
game_screenshot()  // Observe: button not visible

game_get_property({ node_path: "/root/Main/UILayer/PlayButton", property: "visible" })
// Returns: false — button is hidden

// Fix in code, then restart and verify:
stop_project()
run_project({ projectPath: "/path/to/game" })
game_screenshot()
```

## Best Practices

1. **Always use `game_scene_tree` for coordinates** — never guess click positions from screenshot pixels
2. **Check `get_debug_output()` after interactions** — look for print statements and errors
3. **Validate internal state, not just visuals** — use `game_get_property` to confirm game logic
4. **Use `game_set_property` to skip setup** — force states rather than playing through manually
5. **Always call `stop_project()` when done** — free resources

## Troubleshooting

| Symptom | Check | Solution |
|---|---|---|
| Game won't start / black screenshot | Godot path in `.mcp.json`, bridge autoload registered | `get_debug_output()` — look for "Godot MCP Bridge initialized" |
| Click doesn't work | Coordinates correct? Button visible? Blocked by another node? | `game_scene_tree()` + `game_get_property(..., "visible")` |
| "Node not found" from `game_get_property` | Node path correct? Node exists at runtime? | `game_scene_tree({ depth: 5 })` to find correct path |
| Screenshot is black | Game still rendering after launch | Wait 3 seconds; check `get_debug_output()` for "Frame N" output |
| Tools fail immediately after `run_project` | Bridge not initialized yet | Poll `get_debug_output()` for "Godot MCP Bridge initialized" before calling tools |

## Summary

1. **Launch** with `run_project()` → confirm with `get_debug_output()`
2. **Observe** with `game_screenshot()` + `game_scene_tree()`
3. **Interact** with `game_click()`, `game_key()`, `game_action()`
4. **Inspect/modify** with `game_get_property()` + `game_set_property()`
5. **Iterate** until behavior is verified, then `stop_project()`

**Key insights:** Always use `game_scene_tree` for accurate UI coordinates. Bridge autoload handles all synchronization automatically. `game_screenshot()` works on stock Godot; upstream DAP `capture_screenshot` does not.
