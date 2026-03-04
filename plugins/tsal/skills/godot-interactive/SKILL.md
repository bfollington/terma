---
name: godot-interactive
description: "Interact with a running Godot game via MCP — launch, screenshot, click, inspect scene tree, get/set properties. Powered by godot-mcp + GodotMCPBridge autoload."
---

# Godot Interactive Testing Skill

Playwright-like interaction loop for Godot games via MCP. Launch, observe, click, inspect, and manipulate a running game through a bridge autoload.

## Overview

This skill enables LLM-driven interactive testing of Godot games through the godot-mcp MCP server and a GodotMCPBridge autoload. You can:

- Launch and stop Godot projects via MCP
- Capture viewport screenshots automatically or on-demand
- Inspect the scene tree with Control node positions and text
- Simulate clicks, key presses, and input actions
- Read and write node properties at runtime
- Implement iterative test/debug loops (observe → inspect → interact → observe)

This is particularly useful for:
- Automated UI testing
- Debugging visual issues
- Verifying game state without manual playtesting
- Creating reproducible test scenarios
- Validating UI layouts and interactions

## Prerequisites

**godot-mcp server:**
- Installed at `~/code/godot-mcp` (or configurable path)
- Built with `npm install && npm run build`
- Repository: https://github.com/yourusername/godot-mcp

**Claude Desktop configuration:**
- MCP server configured in `~/.claude/mcp.json` (see Setup)

**Godot project setup:**
- GodotMCPBridge autoload installed
- Remote debugger enabled (automatic when running via `run_project`)

## Setup for New Projects

### 1. Copy the Bridge Autoload

Copy the bridge script into your project:
```bash
cp assets/templates/godot_mcp_bridge.gd res://scripts/autoload/godot_mcp_bridge.gd
```

### 2. Register the Autoload

Add to `project.godot`:
```ini
[autoload]

GodotMCPBridge="*res://scripts/autoload/godot_mcp_bridge.gd"
```

Or via Godot editor:
- Project → Project Settings → Autoload
- Path: `res://scripts/autoload/godot_mcp_bridge.gd`
- Name: `GodotMCPBridge`
- Enable: Yes

### 3. Create MCP Configuration

Create `.mcp.json` at project root (use template):
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

**Example paths:**
- macOS: `/Applications/Godot 4.5.app/Contents/MacOS/Godot`
- Linux: `/usr/bin/godot` or `~/godot/bin/godot`
- Windows: `C:/Godot/godot.exe`

**Project-local godot-mcp:**
If you keep godot-mcp in your project (e.g., `.tools/godot-mcp`):
```json
"args": [".tools/godot-mcp/build/index.js"]
```

## MCP Tools Reference

All tools are provided by the godot-mcp server and work through the GodotMCPBridge autoload.

### run_project(projectPath)

Launch a Godot project with remote debugger enabled.

**Parameters:**
- `projectPath` (string): Absolute path to project directory containing `project.godot`

**Returns:**
- Success confirmation with process ID

**Example:**
```typescript
run_project({ projectPath: "/Users/ben/code/my-game" })
```

**Notes:**
- Automatically enables remote debugger on port 6007
- Takes 2-3 seconds for project to fully start
- Bridge begins auto-capturing screenshots every 2 seconds
- Check `get_debug_output()` if game doesn't appear to start

### stop_project()

Stop the currently running Godot project.

**Parameters:** None

**Returns:**
- Success confirmation

**Example:**
```typescript
stop_project()
```

**Notes:**
- Kills the Godot process gracefully
- Cleans up debugger connection
- Safe to call even if no project is running

### get_debug_output()

Retrieve stdout/stderr from the running Godot process.

**Parameters:** None

**Returns:**
- Array of log lines (most recent first)

**Example:**
```typescript
get_debug_output()
// Returns: ["Frame 1234", "Button pressed", "MCP command: click", ...]
```

**Use cases:**
- Check if game started successfully
- Debug print statements from your game
- Verify bridge initialization ("Godot MCP Bridge initialized")
- Inspect error messages

### game_screenshot()

Capture the current viewport and return as base64 image.

**Parameters:** None

**Returns:**
- Base64-encoded PNG image of the game viewport

**Example:**
```typescript
game_screenshot()
// Returns: base64 PNG data
```

**Notes:**
- Captures the main viewport at full resolution
- Bridge auto-saves screenshots to `/tmp/godot_screenshot.png` every 2 seconds
- This tool provides immediate capture via MCP response
- Works on stock Godot (unlike `capture_screenshot` from upstream DAP)

### game_scene_tree(path, depth)

Inspect the scene tree with node types, positions, and properties.

**Parameters:**
- `path` (string, optional): Root path to start inspection, default: `/root`
- `depth` (number, optional): Traversal depth, default: 3

**Returns:**
- JSON tree structure with nodes

**Node properties:**
- `name`: Node name
- `type`: Node class (Control, Button, Label, Node3D, etc.)
- `rect`: For Control nodes: `{x, y, w, h}` in screen coordinates
- `visible`: For Control nodes: visibility state
- `text`: For Button/Label nodes: display text
- `children`: Array of child nodes (up to depth limit)

**Example:**
```typescript
game_scene_tree({ path: "/root/Main/UILayer", depth: 2 })
// Returns:
{
  "name": "UILayer",
  "type": "CanvasLayer",
  "children": [
    {
      "name": "VictoryPopup",
      "type": "CenterContainer",
      "rect": {"x": 640, "y": 360, "w": 400, "h": 200},
      "visible": true,
      "children": [
        {
          "name": "OKButton",
          "type": "Button",
          "rect": {"x": 720, "y": 480, "w": 80, "h": 40},
          "text": "OK",
          "visible": true
        }
      ]
    }
  ]
}
```

**Use cases:**
- Find clickable UI elements (buttons, controls)
- Verify UI layout and positioning
- Check visibility states
- Locate nodes by name/type for property access

**Key gotcha:** UI coordinates are full resolution (e.g., 1920x1080), not screenshot pixel coordinates. Always use `game_scene_tree` to get accurate `rect` values for clicking.

### game_click(x, y, button)

Simulate a mouse click at screen coordinates.

**Parameters:**
- `x` (number): Screen X coordinate
- `y` (number): Screen Y coordinate
- `button` (number, optional): Mouse button index, default: 1 (left click)
  - 1: Left button (MOUSE_BUTTON_LEFT)
  - 2: Right button (MOUSE_BUTTON_RIGHT)
  - 3: Middle button (MOUSE_BUTTON_MIDDLE)

**Returns:**
- Success confirmation with coordinates
- Automatically captures screenshot after click

**Example:**
```typescript
game_click({ x: 720, y: 480, button: 1 })
// Returns: {"type": "click", "success": true, "x": 720, "y": 480}
```

**Notes:**
- Simulates press + release with 50ms delay
- Takes a screenshot 200ms after release
- Use `game_scene_tree` to find button `rect` coordinates
- Coordinates are in full window resolution, not SubViewport pixels

**Workflow:**
1. Call `game_screenshot()` to see the game
2. Call `game_scene_tree()` to find button positions
3. Call `game_click()` with button's center coordinates
4. Call `game_screenshot()` to verify result

### game_key(key)

Simulate a key press using Godot key names.

**Parameters:**
- `key` (string): Godot key name (e.g., "Space", "Escape", "Enter", "A")

**Returns:**
- Success confirmation
- Automatically captures screenshot after key press

**Example:**
```typescript
game_key({ key: "Space" })
game_key({ key: "Escape" })
game_key({ key: "Q" })
```

**Common key names:**
- Letters: "A", "B", "C", etc.
- Numbers: "0", "1", "2", etc.
- Special: "Space", "Enter", "Escape", "Tab"
- Arrows: "Up", "Down", "Left", "Right"
- Function: "F1", "F2", etc.

**Notes:**
- Uses `OS.find_keycode_from_string()` - must be valid Godot key name
- Simulates press + release with 50ms delay
- Takes screenshot 200ms after release
- Case-sensitive for letters (use uppercase "A", not "a")

### game_action(name)

Trigger a Godot input action defined in InputMap.

**Parameters:**
- `name` (string): Action name from project InputMap

**Returns:**
- Success confirmation
- Automatically captures screenshot after action

**Example:**
```typescript
game_action({ name: "jump" })
game_action({ name: "ui_accept" })
game_action({ name: "shoot" })
```

**Notes:**
- Action must be defined in project's InputMap (project.godot)
- Simulates action press + release with 50ms delay
- Takes screenshot 200ms after release
- Works with multi-key bindings (triggers the action, not specific keys)

**Use cases:**
- Test gameplay actions without knowing exact key bindings
- Trigger complex input combinations (e.g., "dash" = Shift+W)
- Test controller/gamepad actions

### game_get_property(node_path, property)

Read a node property at runtime.

**Parameters:**
- `node_path` (string): Absolute node path from `/root` (e.g., `/root/Main/Player`)
- `property` (string): Property name (e.g., `position`, `health`, `visible`)

**Returns:**
- Property value (JSON-serialized)

**Example:**
```typescript
game_get_property({ node_path: "/root/Main/Player", property: "position" })
// Returns: {"x": 5.2, "y": 0.0, "z": 3.8}

game_get_property({ node_path: "/root/Main/UILayer/HUD", property: "visible" })
// Returns: true
```

**Supported types:**
- Primitives: bool, int, float, String
- Vectors: Vector2, Vector2i, Vector3, Vector3i (as `{x, y, z}`)
- Color: `{r, g, b, a}`
- Arrays/Dictionaries: recursively converted
- Objects: `"<ClassName>"`
- NodePath: string representation

**Use cases:**
- Verify game state (player health, position, score)
- Check UI visibility and text
- Validate object properties after interactions

### game_set_property(node_path, property, value)

Write a node property at runtime.

**Parameters:**
- `node_path` (string): Absolute node path from `/root`
- `property` (string): Property name
- `value` (any): New value (JSON-serializable)

**Returns:**
- Success confirmation
- Automatically captures screenshot after change

**Example:**
```typescript
game_set_property({
  node_path: "/root/Main/Player",
  property: "position",
  value: { x: 10, y: 0, z: 5 }
})

game_set_property({
  node_path: "/root/Main/UILayer/VictoryPopup",
  property: "visible",
  value: true
})
```

**Notes:**
- Takes screenshot 100ms after property change
- Use JSON object syntax for Vector2/Vector3: `{x, y}` or `{x, y, z}`
- For testing, you can force game states (show popups, move player, etc.)

**Use cases:**
- Force UI visibility for testing
- Teleport player to test positions
- Set health/score to test edge cases
- Trigger game states without playing through

## Workflow Patterns

### Pattern 1: Basic UI Test Loop

Test a button click and verify the result.

**Steps:**

1. **Launch the game:**
   ```typescript
   run_project({ projectPath: "/Users/ben/code/my-game" })
   ```

2. **Wait for startup (check logs):**
   ```typescript
   get_debug_output()
   // Look for "Godot MCP Bridge initialized"
   ```

3. **Observe initial state:**
   ```typescript
   game_screenshot()
   ```

4. **Inspect scene tree to find button:**
   ```typescript
   game_scene_tree({ path: "/root/Main/UILayer", depth: 3 })
   // Note the button's rect: {x: 720, y: 480, w: 80, h: 40}
   ```

5. **Click button center:**
   ```typescript
   game_click({ x: 760, y: 500 })  // Center of button
   ```

6. **Verify result:**
   ```typescript
   game_screenshot()  // See visual result
   get_debug_output()  // Check for print statements
   ```

### Pattern 2: Property Inspection and Validation

Verify game state after actions.

**Steps:**

1. **Launch and perform action:**
   ```typescript
   run_project({ projectPath: "/path/to/game" })
   game_click({ x: 640, y: 360 })  // Click play button
   ```

2. **Read game state:**
   ```typescript
   game_get_property({ node_path: "/root/Main/Player", property: "health" })
   // Returns: 100

   game_get_property({ node_path: "/root/Main/Ball", property: "position" })
   // Returns: {"x": 0, "y": 0, "z": 0}
   ```

3. **Trigger gameplay:**
   ```typescript
   game_action({ name: "select_card" })
   ```

4. **Verify state change:**
   ```typescript
   game_get_property({ node_path: "/root/Main/Ball", property: "position" })
   // Returns: {"x": 5, "y": 0, "z": 3}  // Ball moved!
   ```

### Pattern 3: Forcing Game States for Testing

Set up specific scenarios without manual play.

**Steps:**

1. **Launch game:**
   ```typescript
   run_project({ projectPath: "/path/to/game" })
   ```

2. **Force victory state:**
   ```typescript
   game_set_property({
     node_path: "/root/Main",
     property: "state",
     value: "VICTORY"
   })
   ```

3. **Show victory popup:**
   ```typescript
   game_set_property({
     node_path: "/root/Main/UILayer/VictoryPopup",
     property: "visible",
     value: true
   })
   ```

4. **Verify UI appears correctly:**
   ```typescript
   game_screenshot()
   game_scene_tree({ path: "/root/Main/UILayer/VictoryPopup" })
   ```

5. **Test OK button:**
   ```typescript
   game_click({ x: 760, y: 500 })
   ```

### Pattern 4: Debugging Visual Issues

Investigate rendering problems.

**Steps:**

1. **Launch game:**
   ```typescript
   run_project({ projectPath: "/path/to/game" })
   ```

2. **Capture screenshot:**
   ```typescript
   game_screenshot()
   // Observe: button is not visible
   ```

3. **Inspect button properties:**
   ```typescript
   game_get_property({ node_path: "/root/Main/UILayer/PlayButton", property: "visible" })
   // Returns: false  // Aha! Button is hidden
   ```

4. **Check parent visibility:**
   ```typescript
   game_get_property({ node_path: "/root/Main/UILayer", property: "visible" })
   // Returns: true
   ```

5. **Fix the bug** (in code):
   ```gdscript
   # In your script:
   $PlayButton.visible = true  # Was missing this line
   ```

6. **Restart and verify:**
   ```typescript
   stop_project()
   run_project({ projectPath: "/path/to/game" })
   game_screenshot()
   ```

## Key Gotchas

### Gotcha 1: UI Coordinates Are Full Resolution

**Problem:** Screenshots are 640x360 (SubViewport), but UI coordinates are 1920x1080 (window resolution).

**Solution:** Always use `game_scene_tree` to get button `rect` values. Do not manually calculate click coordinates from screenshot pixels.

**Example:**
```typescript
// ❌ WRONG: Clicking screenshot pixel coordinates
game_screenshot()  // 640x360 image
game_click({ x: 320, y: 180 })  // Center of screenshot = WRONG

// ✅ CORRECT: Use scene_tree rect
game_scene_tree({ path: "/root/Main/UILayer" })
// Returns: { name: "PlayButton", rect: {x: 860, y: 520, w: 200, h: 80} }
game_click({ x: 960, y: 560 })  // Center of rect = CORRECT
```

### Gotcha 2: Stock Godot DAP Limitation

**Problem:** The upstream Godot DAP `capture_screenshot` tool doesn't work on stock Godot builds.

**Solution:** Use `game_screenshot()` from this skill instead. It works through the file-based bridge protocol (`/tmp/godot_screenshot.png`).

**Why it matters:** Other Godot DAP tools may advertise `capture_screenshot`, but it requires a custom Godot build with DAP screenshot support. The bridge's `game_screenshot()` always works.

### Gotcha 3: Bridge Initialization Delay

**Problem:** Calling MCP tools immediately after `run_project()` may fail if bridge isn't ready.

**Solution:** Check `get_debug_output()` for "Godot MCP Bridge initialized" before calling game interaction tools.

**Example:**
```typescript
run_project({ projectPath: "/path/to/game" })
// Wait 2-3 seconds or poll debug output
get_debug_output()
// Look for: "Godot MCP Bridge initialized — screenshots: /tmp/godot_screenshot.png..."
```

### Gotcha 4: Scene Tree Depth Limit

**Problem:** `game_scene_tree()` defaults to depth 3, may not show deeply nested nodes.

**Solution:** Increase `depth` parameter for deeper inspection, or query specific subtrees.

**Example:**
```typescript
// Shallow inspection
game_scene_tree({ path: "/root/Main", depth: 2 })

// Deep inspection of UI subtree
game_scene_tree({ path: "/root/Main/UILayer/VictoryPopup", depth: 5 })
```

### Gotcha 5: File-Based Protocol Synchronization

**Problem:** Bridge uses file-based communication (`/tmp/godot_mcp_command.json` and `/tmp/godot_mcp_response.json`), which is polled every frame.

**Solution:** MCP tools handle synchronization automatically. Response is written after command completes. No manual delays needed.

**How it works:**
1. MCP tool writes command to `/tmp/godot_mcp_command.json`
2. Bridge polls the file every frame
3. Bridge executes command and deletes command file
4. Bridge writes response to `/tmp/godot_mcp_response.json`
5. Bridge prints `MCP_RESPONSE:{...}` to stdout
6. MCP tool reads response and returns to caller

**You don't need to do anything special** - just call the tools normally.

## Bridge Communication Protocol

The GodotMCPBridge autoload implements a file-based protocol for communication:

**Command file:** `/tmp/godot_mcp_command.json`
- MCP server writes JSON commands here
- Bridge polls every frame
- Bridge deletes after reading

**Response file:** `/tmp/godot_mcp_response.json`
- Bridge writes JSON responses here
- MCP server reads responses

**Screenshot file:** `/tmp/godot_screenshot.png`
- Bridge auto-saves every 2 seconds
- Bridge updates after clicks/keys (200ms delay)
- MCP tools can read this file directly

**Debug output:**
- Bridge prints `MCP_RESPONSE:{...}` to stdout
- MCP server captures via `get_debug_output()`

**Command format:**
```json
{
  "action": "click",
  "x": 640,
  "y": 360,
  "button": 1
}
```

**Response format:**
```json
{
  "type": "click",
  "success": true,
  "x": 640,
  "y": 360
}
```

## Best Practices

### 1. Always Inspect Before Clicking

Use `game_scene_tree` to find button positions - don't guess coordinates.

```typescript
// ✅ CORRECT workflow
game_scene_tree({ path: "/root/Main/UILayer" })
// Find button rect
game_click({ x: rect.x + rect.w/2, y: rect.y + rect.h/2 })

// ❌ WRONG workflow
game_screenshot()
// Guess coordinates from image
game_click({ x: 640, y: 360 })
```

### 2. Check Debug Output for Errors

After interactions, check `get_debug_output()` for print statements and errors.

```typescript
game_click({ x: 640, y: 360 })
get_debug_output()
// Look for "Button pressed" or error messages
```

### 3. Use Property Inspection for Validation

Don't just rely on screenshots - verify internal game state.

```typescript
game_click({ x: 640, y: 360 })
game_get_property({ node_path: "/root/Main/Player", property: "health" })
// Confirm health decreased as expected
```

### 4. Force States for Faster Testing

Use `game_set_property` to skip to specific game states.

```typescript
// Skip tutorial, go straight to level 5
game_set_property({ node_path: "/root/Main", property: "current_level", value: 5 })
```

### 5. Clean Up After Tests

Always stop the project when done to free resources.

```typescript
stop_project()
```

## Common Use Cases

### Use Case 1: Automated UI Regression Testing

Test that buttons still work after code changes.

```typescript
run_project({ projectPath: "/path/to/game" })
game_screenshot()
game_scene_tree({ path: "/root/Main/UILayer" })
game_click({ x: 640, y: 360 })  // Play button
game_get_property({ node_path: "/root/Main", property: "state" })
// Assert: state is "PLAYING"
stop_project()
```

### Use Case 2: Visual Debugging

Investigate why a UI element doesn't appear.

```typescript
run_project({ projectPath: "/path/to/game" })
game_screenshot()  // See the issue
game_scene_tree({ path: "/root/Main/UILayer" })  // Check hierarchy
game_get_property({ node_path: "/root/Main/UILayer/MissingButton", property: "visible" })
// Debug: visible is false!
```

### Use Case 3: Game State Validation

Verify gameplay logic by checking properties.

```typescript
run_project({ projectPath: "/path/to/game" })
game_action({ name: "attack" })
game_get_property({ node_path: "/root/Main/Enemy", property: "health" })
// Verify: health decreased correctly
```

### Use Case 4: Screenshot Documentation

Capture screenshots of all UI states for documentation.

```typescript
run_project({ projectPath: "/path/to/game" })
game_screenshot()  // Main menu
game_click({ x: 640, y: 360 })  // Start game
game_screenshot()  // Gameplay
game_set_property({ node_path: "/root/Main/Popup", property: "visible", value: true })
game_screenshot()  // Settings popup
```

## Troubleshooting

### Game Won't Start

**Symptoms:** `run_project()` succeeds but no screenshot appears.

**Check:**
1. Verify Godot path in `.mcp.json` is correct
2. Check `get_debug_output()` for errors
3. Ensure bridge autoload is registered in `project.godot`

**Solution:**
```typescript
get_debug_output()
// Look for "Godot MCP Bridge initialized"
// If missing, bridge isn't loaded
```

### Click Doesn't Work

**Symptoms:** `game_click()` succeeds but button doesn't respond.

**Check:**
1. Coordinates are correct (use `game_scene_tree`)
2. Button is visible (`game_get_property`)
3. UI is not blocked by another node

**Solution:**
```typescript
game_scene_tree({ path: "/root/Main/UILayer" })
// Verify button rect
game_get_property({ node_path: "/root/Main/UILayer/Button", property: "visible" })
// Verify button is visible
```

### Property Not Found

**Symptoms:** `game_get_property()` returns error "Node not found".

**Check:**
1. Node path is correct (use `game_scene_tree` to find path)
2. Node exists at runtime (may be dynamically created)

**Solution:**
```typescript
game_scene_tree({ path: "/root/Main", depth: 5 })
// Find the correct node path
```

### Screenshot Is Black/Empty

**Symptoms:** Screenshot is solid black or shows nothing.

**Check:**
1. Game has finished rendering (wait 2-3 seconds after launch)
2. Camera is active and positioned correctly
3. Scene has visible nodes

**Solution:**
```typescript
run_project({ projectPath: "/path/to/game" })
// Wait 3 seconds
get_debug_output()
// Check for "Frame N" output indicating rendering
game_screenshot()
```

## Summary

The godot-interactive skill enables automated testing and debugging of Godot games through MCP tools:

1. **Launch games** with `run_project()` and remote debugger
2. **Observe state** with `game_screenshot()` and `game_scene_tree()`
3. **Interact** with `game_click()`, `game_key()`, `game_action()`
4. **Inspect/modify** with `game_get_property()` and `game_set_property()`
5. **Iterate** in a test loop until behavior is verified

**Key insights:**
- File-based protocol is reliable and works on stock Godot
- Always use `game_scene_tree` for accurate UI coordinates
- Bridge autoload handles all synchronization automatically
- Property inspection validates internal state, not just visuals

This skill transforms Godot development from manual playtesting to automated, reproducible test scenarios.
