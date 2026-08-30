---
name: godot-interactive
description: "Interact with a running Godot game via MCP — launch, screenshot, click, inspect scene tree, get/set properties, call methods, run dev-console commands. Powered by godot-mcp + the GodotMCPBridge autoload (protocol v4.0)."
---

# Godot Interactive (MCP)

Drive a running Godot game from an agent: launch it, look at it, click it, inspect the scene
tree, read and write node properties, call methods, and run dev-console commands — an
observe → interact → observe loop that replaces manual playtesting for anything verifiable.

## The two halves

1. **godot-mcp** — a Node MCP server. Spawns/kills the Godot process, captures its stdout, and
   wraps a file protocol into `game_*` tools.
2. **GodotMCPBridge** — a GDScript autoload running *inside* the game. Polls a command file
   every frame, executes commands on the live tree, writes responses and screenshots.

Everything interactive goes through the bridge. If the bridge isn't loaded or isn't being
found, every `game_*` tool times out while `run_project` still reports success.

**Limitation:** the MCP spawns its own Godot process. It cannot attach to a game you launched
with F5 from the editor.

---

## Protocol v4.0: where the files live

Every bridge file lives in a **per-project directory**:

```
dir  = $GODOT_MCP_DIR, else /tmp/godot-mcp/<slug>
slug = <project-dir-name>-<first 8 hex of sha1(absolute project path)>

<dir>/command.json     written by the client, consumed + deleted by the bridge
<dir>/response.json    written by the bridge, read by the client
<dir>/screenshot.png   written by the bridge
<dir>/instance.json    written on ready — {project, slug, pid, bridge_version}
```

**Before v4.0 these were fixed `/tmp/godot_*` paths.** Two Godot projects running at once
silently ate each other's commands and clobbered each other's screenshots — results came back
from the wrong game with no error at all. If you find `/tmp/godot_screenshot.png` or
`/tmp/godot_mcp_command.json` referenced anywhere, that documentation or that bridge copy is
pre-v4.0 and wrong.

The slug formula is a **cross-language contract** — the GDScript bridge, the TypeScript server,
and any shell/python helpers must derive it identically. Change it in one place and the tooling
stops finding the game.

Clients discover live games by globbing `/tmp/godot-mcp/*/instance.json`; a crash leaves the
manifest behind, so treat it as a hint and confirm the `pid` is alive.

**Two instances of the *same* project still share a directory** and will race. Launch the
secondary with `GODOT_MCP_DISABLE_BRIDGE=1` (the bundled template's env var — rename it to your
project's prefix if you prefer) so only the primary answers. Before driving a game, check
whether the user already has one running (`pgrep -fl "Godot.*<project>"`) — if they do, your
commands land in their session and theirs land in yours.

---

## Four things that silently lie to you

These are the expensive failures. All four look like a bug in whatever you just changed.

### 1. The screenshot on disk can be stale

`game_screenshot` **reads the PNG off disk** — it does not force a capture. Fresh frames come
from exactly two places:

- an explicit `{"action":"screenshot"}` over the file protocol (`request_screenshot()`), which
  always captures regardless of settings; or
- the automatic post-command capture after `game_click` / `game_key` / `game_console` /
  `game_set_property` — **which only happens when `screenshots_enabled` is true.**

`screenshots_enabled` defaults to **false** (the readback costs ~29ms of GPU stall), so on a
fresh launch every screenshot returned alongside a command is whatever was last written.
**Enable it once per session:**

```
game_set_property(node_path: "/root/GodotMCPBridge", property: "screenshots_enabled", value: true)
```

There is also **no periodic screenshot timer** (the old every-2s save was a recurring 15–40ms
main-thread stall). Nothing refreshes the PNG on its own.

### 2. An occluded window renders nothing

Godot stops drawing when its window is fully occluded. `viewport.get_texture().get_image()`
then returns null, the bridge keeps serving **the last frame it drew**, and everything else
keeps working perfectly — commands succeed, `game_scene_tree` reports live and correct state,
and every screenshot shows a world from before your change.

**The tell:** two screenshots across a change that should be visible come back byte-identical.

```bash
md5 -q /tmp/godot-mcp/<slug>/screenshot.png    # same hash twice = nothing is rendering
```

**Do not "fix" this with `open -a Godot`** (macOS) — that raises the Godot *editor*, a separate
process that will occlude the game and cause the exact problem you are trying to solve. Raise
the game by PID:

```bash
PID=$(ps ax -o pid,command | grep "[G]odot -d --path $PWD" | awk '{print $1}' | head -1)
osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $PID) to true"
```

If you are in a session where you cannot make the game window visibly frontmost, screenshots
are simply unavailable — stop retrying. `game_scene_tree`, `game_get_property`,
`game_call_method`, `game_console` and `get_debug_output` all work regardless. Verify state by
reading properties, and hand the visual call to the user with an exact repro.

### 3. Async transitions return a mid-transition frame

Any command that kicks off a fade / rebuild / scene swap finishes long after the bridge's
default 0.2s post-command capture. Pass **`settle`** (seconds) so a single call waits for the
settled frame instead of screenshotting mid-fade and screenshotting again:

```
game_console(command: "switch_biome ice", settle: 2.5)
game_set_property(node_path: "...", property: "...", value: ..., settle: 1.0)
```

Note which tools actually return an image: `game_click`, `game_key`, `game_action`,
`game_console` and `game_type_text` do; **`game_set_property` returns JSON only.** Its `settle`
delays the screenshot the bridge writes to *disk*, so it pays off on the next read of that file,
not in the response you get back.

### 4. A restart leaves the previous instance's last frame on disk

Right after relaunching, the PNG attached to a click/key response is the **old** process's
final frame. It looks convincing and it is a different game. After a restart, force a capture
before believing any image.

---

## Tool reference

### Process control

| Tool | What it does | Key params |
|---|---|---|
| `run_project` | Spawn Godot in debug mode, capture stdout/stderr | `projectPath`, `scene` |
| `get_debug_output` | Accumulated stdout + stderr | — |
| `stop_project` | Kill the Godot process | — |

`run_project` takes 2–3s to become drivable. Confirm with `get_debug_output()` and look for
`Godot MCP Bridge initialized` before sending `game_*` commands.

**Prefer `pkill` over `stop_project` to stop it.** `stop_project` can dump the entire
accumulated stdout into your context. `pkill -f "<godot binary path>"` is clean. A running
game is the CPU-heavy part of any session — stop it before large subagent fan-outs, and
whenever the user needs the machine back.

### Game interaction (via the bridge)

| Tool | What it does | Key params |
|---|---|---|
| `game_screenshot` | Return the PNG currently on disk (see lie #1) | — |
| `game_scene_tree` | Scene tree as JSON; Control nodes carry `rect`, `visible`, `text` | `path` (`/root`), `depth` (3) |
| `game_click` | Synthetic press+release at canvas coordinates | `x`, `y`, `button` (1=L, 2=R, 3=M) |
| `game_key` | Key press by Godot key name (`Space`, `Escape`, `Return`, `A`) | `key` |
| `game_action` | Trigger an InputMap action — no key binding needed | `name` |
| `game_get_property` | Read a node property | `node_path`, `property` |
| `game_set_property` | Write a node property | `node_path`, `property`, `value`, `settle` |
| `game_call_method` | Call a method, return its result | `node_path`, `method`, `args` |
| `game_console` | Run a dev-console command (LimboConsole) | `command`, `settle` |
| `game_type_text` | Type into the focused text field, optionally submit | `text`, `submit` |

Notes that matter:

- **Vectors cross the wire as dicts.** `{"x":1,"y":-4}` → `Vector2i` when all-int, else
  `Vector2`; add `"z"` for `Vector3i`/`Vector3`. A dict that isn't x/y(/z)-shaped passes through
  raw. The same shape comes back from `game_get_property`; `Color` returns `{r,g,b,a}`.
- **Stringified values are coerced** on `set_property`, so `"true"` and `true` both work.
- `game_key` uses `OS.find_keycode_from_string()` — uppercase `"A"`, not `"a"`.
- **`game_type_text` is unreliable for anything that matters.** Injected key events depend on
  focus. If the target is a dev console, use `game_console` instead — it bypasses focus and
  unicode entirely.
- **The bridge acts on *nodes*.** A `ShaderMaterial` is not a node, so you cannot poke shader
  uniforms live. Tuning a shader means an edit-and-restart cycle unless the project exposes an
  in-game tuning panel. This is the one thing that reliably breaks the fast loop.
- **`game_call_method` must be awaited inside the bridge.** `callv` on a method containing
  `await` raises "Trying to call an async function without await" as a *debugger break*, which
  hard-freezes the game and takes the bridge with it — every later command times out and the
  only cure is a relaunch. The bundled template awaits `callv`, which handles both cases; if
  you port an older bridge, this is the fix.
- A `success: true` response only means the bridge dispatched the call. If the call itself
  errored, that shows up in the game's stderr — check `get_debug_output()`, not the return.

### Offline / headless tools

| Tool | What it does |
|---|---|
| `create_scene`, `add_node`, `load_sprite`, `save_scene` | Edit `.tscn` files without the editor |
| `launch_editor`, `get_godot_version`, `list_projects`, `get_project_info` | Project info |

**Never open the editor while using the interactive loop** (it occludes the game — see lie #2),
and never kill an editor the user has open; they may have unsaved scene work.

---

## Coordinates

The bridge saves the PNG at **canvas size** — `viewport.get_visible_rect().size`, not the
render-texture size — specifically so that **a pixel read off the screenshot is a valid click
coordinate**. The mapping is the identity.

This was not always true. Three spaces used to be in play (render texture at
`root_size × content_scale_factor`, the canvas that Controls and injected input live in, and
whatever the reader scaled the image to), and anyone picking a coordinate off the image was
silently off by the content-scale factor — which read as "clicking Controls doesn't work".
If a bridge you are porting doesn't resize to canvas size, that bug is still present.

Even so, **prefer not to hand-derive coordinates.** In order of preference:

1. A dev-console command that presses the button by name or id (see below).
2. `game_scene_tree` → the target's `rect` → click its centre.
3. Reading pixels off the screenshot.

`game_click` goes through `Input.parse_input_event()`, so it respects Godot's input handling:
if a Control absorbs the event, nothing deeper sees it. "The click did nothing" is usually
occlusion or a modal eating input, not a bad coordinate.

---

## Give the project a dev console — the biggest win available

The single highest-leverage thing you can add to a Godot project for agent-driven testing is a
dev console ([LimboConsole](https://github.com/limbonaut/limbo_console) is what the bridge
targets) with commands that *navigate and stage* the game: start a run, jump to level N, grant
an item, switch environment, open a specific screen, set a seed. With those in place you drive
the whole game through `game_console` and never guess a pixel coordinate or click through a
menu again.

Console commands worth writing for your project:

| Purpose | Shape | Why it pays off |
|---|---|---|
| Boot straight into gameplay | `start_run`, `restart_run` | Skips menus entirely |
| Jump to state | `skip_to_level <n>`, `set_seed <n>` | Reproducible scenarios |
| Grant / force | `give_item <id>`, `add_currency <n>` | Tests states you'd otherwise grind to |
| **List buttons** | `ui_buttons [filter]` | See below — this one is worth its weight |
| **Press buttons** | `ui_press <id>` / `ui_click <id>` | Staging vs. real-input testing |
| Reset layering | `reset_ui_layers` | Screens stack and become unusable |
| Live tuning | `tune_<system>` | Feel/look changes without an edit-restart cycle |

**`ui_buttons` is the answer to "why did my click do nothing".** Have it print, for every
visible button: `[id] <node path> "<label>" @x,y WxH` plus `DISABLED`, `MOUSE_IGNORE`,
`focused`, and — critically — `BLOCKED BY <node>` when something is drawn over the button's
centre. Then:

| | `ui_press <id>` | `ui_click <id>` |
|---|---|---|
| Path | emits `pressed()` directly | full synthetic mouse event |
| Use for | **staging** — just make it happen | **testing** that a real click works |
| Occluded button | fires anyway | refuses, and names the blocker |

For staging, reach for `ui_press`: it cannot be defeated by focus, occlusion, or a modal eating
input. Use `ui_click` only when the question is genuinely "would a player's click land here?".

Generalising: **before writing a coordinate click or a `game_call_method` into a private
method, check whether a console command already does it.**

### Two console traps

**Console commands do not return their output.** `game_console` executes the command and
returns a screenshot; the command's own `print`s go to the in-game console log. So any command
whose entire purpose is to tell you something is a **silent no-op from your side** unless you
read that log — and you will wrongly conclude the command "did nothing". To read it: open the
console (its log fills the screen), force a screenshot, read the PNG, close it again.

**An open console usually pauses the tree.** LimboConsole sets `get_tree().paused = true`.
Two consequences:

- The bridge autoload must be `process_mode = PROCESS_MODE_ALWAYS` or it freezes with the game
  and stops answering commands entirely.
- **A paused tree ticks no process frames**, so any console command that `await`s frames can
  never complete while the console is open. Such commands must close the console themselves.

---

## The loop

```
1. run_project(projectPath: "/abs/path")        # wait ~3s; foreground the game window
2. get_debug_output()                           # confirm "Godot MCP Bridge initialized"
3. game_set_property(/root/GodotMCPBridge, screenshots_enabled, true)
4. game_console(command: "start_run", settle: 3)
5. <force a capture> → read the PNG directly (the Read tool renders PNGs — no MCP round-trip)
6. game_get_property(...)                       # verify state, not just pixels
7. get_debug_output()                           # errors and prints
8. pkill -f "<godot binary>"                    # free the CPU
```

**Verify with properties, not screenshots.** For any boolean question — is it visible, did the
score change, is the state `VICTORY` — read the property. It is live and true regardless of
render state, whereas a screenshot has four ways to lie to you. Reserve screenshots for layout
and look.

**Force states instead of playing to them.** `game_set_property` on a state enum or a popup's
`visible` gets you to the case you want to inspect in one call.

---

## Gotchas

- **Code changes need a full restart.** Debug runs do not hot-reload GDScript. Kill, relaunch.
- **A brand-new `class_name` fails headless syntax checks** until the project is reimported —
  `--check-only` reads the global class cache, so you get a spurious
  `Identifier "Foo" not declared`. Run `godot --headless --path . --import` once.
- **Headless Godot under an agent sandbox crashes or hangs.** If it cannot write `user://logs`
  it either dies with SIGSEGV or hangs on an XPC `Connection Invalid` — which surfaces as a
  segfault backtrace or a test-suite timeout and gets debugged as a real bug for half an hour.
  It is just filesystem denial. Disable the sandbox on the *first* Godot call, and tell
  subagents the same up front.
- **The bridge screenshot is not a deliverable.** It is resampled down to canvas size on
  purpose (see Coordinates). Fine for looking at; wrong for anything shipped. For real assets,
  render at full resolution from inside the game.
- **A 1–2s one-shot animation cannot be caught with MCP round-trips** — the calls straddle the
  window and you see idle → idle, which reads as "nothing happened". Trigger it, then grab 5–7
  frames ~0.1s apart in a single shell command.
- **Fine detail is the human's job.** The PNG is downscaled in the agent's view; small props
  and fast motion read poorly. Hand feel- and motion-based judgements to the user, who is
  looking at the window at full resolution.
- **Screens stack.** Opening a modal over an already-open modal usually produces something
  unusable rather than an error. Reset UI layers when moving between screens.
- **Warps often only go forward.** A "jump to level N" command that silently no-ops going
  backwards will waste your time; start a fresh run instead.

---

## Setup for a new project

1. **Build the server:** `cd <godot-mcp> && npm install && npm run build`

2. **Copy the bridge** from `assets/templates/godot_mcp_bridge.gd` into the project as
   `res://scripts/autoload/godot_mcp_bridge.gd`. Use *this* template — it speaks protocol
   v4.0. Copies bundled with older checkouts of godot-mcp may still be v3 (global `/tmp/godot_*`
   paths), and a v3 bridge is invisible to a v4 server.

3. **Register the autoload** in `project.godot`:
   ```ini
   [autoload]
   GodotMCPBridge="*res://scripts/autoload/godot_mcp_bridge.gd"
   ```

4. **Create `.mcp.json`** at the project root (template: `assets/templates/mcp.json.template`):
   ```json
   {
     "mcpServers": {
       "godot": {
         "command": "node",
         "args": ["<PATH_TO_GODOT_MCP>/build/index.js"],
         "env": { "GODOT_PATH": "<PATH_TO_GODOT_BINARY>" }
       }
     }
   }
   ```
   Godot paths: macOS `/Applications/Godot.app/Contents/MacOS/Godot`, Linux `/usr/bin/godot`,
   Windows `C:/Godot/godot.exe`.

5. **Validate:** `godot --headless --path . --import 2>&1 | grep -E "SCRIPT ERROR|ERROR:"`

6. **Restart the session** — MCP servers load at startup.

7. **Then earn the real speedup:** add the dev-console commands above. The MCP tools are the
   floor; a project with `start_run` / `skip_to_level` / `ui_buttons` is an order of magnitude
   faster to drive than one without.

---

## Troubleshooting

**`game_*` tools time out, but `run_project` succeeded**
Bridge not loaded, or not where the client is looking. Check `get_debug_output()` for
`Godot MCP Bridge initialized`, confirm the autoload is registered, and confirm the bridge is
v4.0 — a v3 bridge writes to `/tmp/godot_*` and the server will never see it. Then check
`/tmp/godot-mcp/*/instance.json` for which instances are actually live.

**Commands land in the wrong game**
Two instances of the same project share a directory and race for commands. Symptoms are
uncanny: a command "succeeds" but hits the other instance, responses get clobbered, screenshots
alternate between two states. Run one, or launch the secondary with the bridge disabled.

**Screenshot is stale, black, or identical across changes**
In order: is `screenshots_enabled` true? Is the window occluded (check the md5)? Did you force
a capture rather than reading the file? Was there a restart since the last capture? Only after
all four should you suspect the camera or the scene.

**A click has no effect**
Almost never the coordinate. Check `visible`, check `mouse_filter`, and check what is drawn
over the target — a `ui_buttons`-style command reports the blocker directly. For staging,
bypass input entirely and emit `pressed()`.

**Property reads say "node not found"**
The node is created at runtime or lives at a different path than the scene file suggests.
`game_scene_tree(path: "/root", depth: 5)` and read the real path — the live root is often
`/root/<MainSceneName>`, not the class name you expect.
