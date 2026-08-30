extends Node
## Godot MCP Bridge
## Autoload singleton enabling Claude Code to observe and control the game.
##
## Features:
## - Saves viewport screenshots on demand
## - Polls a command file for input commands (click, key, action)
## - Writes responses to a response file
##
## ## Instance directory (bridge protocol v4.0)
##
## Every file lives in a PER-PROJECT directory so two different Godot projects
## (or two worktrees of one project) can each run a bridge without fighting over
## the same paths. Before v4.0 these were fixed `/tmp/godot_*` paths, so whichever
## instance polled first ate the other's commands and clobbered its screenshot.
##
##   dir   = $GODOT_MCP_DIR, else /tmp/godot-mcp/<slug>
##   slug  = <project-dir-name>-<first 8 hex of sha1(absolute project path)>
##
##   <dir>/command.json    written by the client, consumed + deleted by the bridge
##   <dir>/response.json   written by the bridge, read by the client
##   <dir>/screenshot.png  written by the bridge
##   <dir>/instance.json   written on ready — lets clients discover live instances
##                         by globbing /tmp/godot-mcp/*/instance.json
##
## The slug formula is a cross-language contract: `.commands/*.sh` (python) and
## the godot-mcp server (typescript) derive it identically. Change it in one
## place and the tooling stops finding the game.

const BRIDGE_VERSION := "4.0"
const DEFAULT_ROOT := "/tmp/godot-mcp"

var instance_dir: String = ""
var screenshot_path: String = ""
var command_path: String = ""
var response_path: String = ""

## Set to true to enable command-triggered and on-request screenshots.
var screenshots_enabled := false

var response_prefix := "MCP_RESPONSE:"
var _frames_since_ready := 0


## Absolute project path with no trailing slash — the hash input.
static func project_root() -> String:
	var root := ProjectSettings.globalize_path("res://")
	while root.length() > 1 and root.ends_with("/"):
		root = root.substr(0, root.length() - 1)
	return root


## <dir-name>-<sha1[0:8]>. Must match the python and typescript implementations.
static func instance_slug() -> String:
	var root := project_root()
	return "%s-%s" % [root.get_file(), root.sha1_text().substr(0, 8)]


static func resolve_instance_dir() -> String:
	var override := OS.get_environment("GODOT_MCP_DIR")
	if not override.is_empty():
		return override
	return DEFAULT_ROOT.path_join(instance_slug())


func _ready() -> void:
	# Keep polling while the SceneTree is paused. LimboConsole pauses the whole tree
	# whenever it opens (limbo_console.gd: `get_tree().paused = true`) and exempts only
	# itself (`process_mode = PROCESS_MODE_ALWAYS`). The bridge inherited the default, so
	# opening the in-game console silently froze it: every command — console, key,
	# screenshot, property — sat unread in command.json until the console was closed, and
	# the caller just saw "Timeout waiting for bridge response" or, worse, a stale
	# screenshot and a command that appeared to do nothing. The bridge is out-of-band
	# tooling; pause is a game-state concept and should never apply to it.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Two instances of the SAME project (the multiplayer spike, PAR-ff2a019c) still
	# share one instance dir, since they share a project path. Launch the secondary
	# with GODOT_MCP_DISABLE_BRIDGE=1 so only the primary answers.
	# Two DIFFERENT projects no longer collide — see the instance-directory doc above.
	if OS.get_environment("GODOT_MCP_DISABLE_BRIDGE") == "1":
		print("Godot MCP Bridge disabled via GODOT_MCP_DISABLE_BRIDGE.")
		set_process(false)
		return

	instance_dir = resolve_instance_dir()
	DirAccess.make_dir_recursive_absolute(instance_dir)
	screenshot_path = instance_dir.path_join("screenshot.png")
	command_path = instance_dir.path_join("command.json")
	response_path = instance_dir.path_join("response.json")

	# Clean up a stale command file from a previous run
	if FileAccess.file_exists(command_path):
		DirAccess.remove_absolute(command_path)
	_write_instance_manifest()

	print(response_prefix + '{"type":"ready","bridge_version":"%s","dir":"%s"}' % [BRIDGE_VERSION, instance_dir])
	print("Godot MCP Bridge initialized — dir: %s" % instance_dir)


## Advertises this instance so clients can find it without being told the project path.
func _write_instance_manifest() -> void:
	var f := FileAccess.open(instance_dir.path_join("instance.json"), FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({
		"project": project_root(),
		"slug": instance_slug(),
		"pid": OS.get_process_id(),
		"bridge_version": BRIDGE_VERSION,
	}, "\t"))
	f.close()


func _exit_tree() -> void:
	# Best-effort: a crash leaves the manifest behind, so clients must treat a
	# manifest as a hint and confirm liveness (the pid is there for that).
	if instance_dir.is_empty():
		return
	var manifest := instance_dir.path_join("instance.json")
	if FileAccess.file_exists(manifest):
		DirAccess.remove_absolute(manifest)

func _process(_delta: float) -> void:
	# Wait a few frames for the scene to render before first screenshot
	if _frames_since_ready < 10:
		_frames_since_ready += 1
		if _frames_since_ready == 10:
			_save_screenshot()
		return

	# Poll for command file. Screenshots are taken on demand only — after each
	# command (via _settle + _save_screenshot in the handlers) and on explicit
	# request_screenshot(). No periodic timer: the every-2s viewport→image
	# readback was a recurring ~15-40ms main-thread stall during dev sessions.
	_poll_commands()


# --- Screenshots ---

## Captures the viewport to screenshot_path.
## `force` bypasses the `screenshots_enabled` gate: the flag only mutes the
## AUTOMATIC post-command captures (so profiling can suppress their ~29ms GPU
## readback), but an explicit request_screenshot() must always produce a fresh
## frame — otherwise "look at the game" silently returns a stale cached PNG.
func _save_screenshot(force := false) -> bool:
	if not screenshots_enabled and not force:
		return false
	var viewport = get_tree().root.get_viewport()
	if not viewport:
		return false
	var img = viewport.get_texture().get_image()
	if not img:
		return false
	# Save at CANVAS size so screenshot pixels ARE input coordinates.
	#
	# Three spaces used to be in play: the render texture (root size x
	# content_scale_factor, e.g. 2112x1188), the canvas that Controls and injected
	# input events live in (1745x981), and whatever the reader scaled the PNG to.
	# Anyone picking a coordinate off the image and feeding it to game_click was
	# silently off by the content-scale factor, which made clicking any Control
	# unreliable in a way that looked like "the click did nothing".
	# Collapsing the PNG onto the canvas makes the mapping the identity.
	var canvas_size := viewport.get_visible_rect().size
	if canvas_size.x > 0.0 and canvas_size.y > 0.0 \
			and (img.get_width() != int(canvas_size.x) or img.get_height() != int(canvas_size.y)):
		img.resize(int(canvas_size.x), int(canvas_size.y), Image.INTERPOLATE_BILINEAR)
	img.save_png(screenshot_path)
	return true

func request_screenshot() -> void:
	var ok := _save_screenshot(true)
	_write_response({"type": "screenshot", "success": ok, "path": screenshot_path, "fresh": ok})


# --- Command polling ---

func _poll_commands() -> void:
	if not FileAccess.file_exists(command_path):
		return

	var f = FileAccess.open(command_path, FileAccess.READ)
	if not f:
		return
	var text = f.get_as_text()
	f.close()

	# Delete the command file immediately so we don't re-process
	DirAccess.remove_absolute(command_path)

	if text.strip_edges().is_empty():
		return

	var json = JSON.new()
	var err = json.parse(text)
	if err != OK:
		_write_response({"type": "error", "message": "Invalid JSON: " + json.get_error_message()})
		return

	var cmd = json.data
	if cmd is not Dictionary:
		_write_response({"type": "error", "message": "Command must be a JSON object"})
		return

	_execute_command(cmd)

func _execute_command(cmd: Dictionary) -> void:
	var action = cmd.get("action", "")
	print("MCP command: " + action)

	match action:
		"click":
			_cmd_click(cmd)
		"key":
			_cmd_key(cmd)
		"action_press":
			_cmd_action(cmd)
		"screenshot":
			request_screenshot()
		"get_tree":
			_cmd_get_tree(cmd)
		"get_property":
			_cmd_get_property(cmd)
		"set_property":
			_cmd_set_property(cmd)
		"console":
			_cmd_console(cmd)
		"type_text":
			_cmd_type_text(cmd)
		"call_method":
			_cmd_call_method(cmd)
		_:
			_write_response({"type": "error", "message": "Unknown action: " + action})

func _write_response(data: Dictionary) -> void:
	var f = FileAccess.open(response_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()
	print(response_prefix + JSON.stringify(data))


# --- Input simulation ---

## Incoming coordinates are canvas coordinates, because _save_screenshot() writes
## the PNG at canvas size. Kept as a named seam (rather than inlining the identity)
## so that if the screenshot ever stops being canvas-sized, there is exactly one
## place to fix it — and callers get the old silent-misclick bug back nowhere else.
func _screenshot_to_canvas(pos: Vector2) -> Vector2:
	var viewport := get_tree().root.get_viewport()
	if viewport == null:
		return pos
	var canvas_size := viewport.get_visible_rect().size
	var png := Image.new()
	if png.load(screenshot_path) != OK or png.get_width() <= 0:
		return pos
	if png.get_width() == int(canvas_size.x):
		return pos
	return pos * (canvas_size / Vector2(png.get_size()))


func _cmd_click(cmd: Dictionary) -> void:
	var x = int(cmd.get("x", 0))
	var y = int(cmd.get("y", 0))
	var button = int(cmd.get("button", MOUSE_BUTTON_LEFT))
	var canvas_pos := _screenshot_to_canvas(Vector2(x, y))

	# Park the cursor on the target first: Controls only accept a press they think
	# they're hovering, so a press with no preceding motion can be ignored outright.
	var motion := InputEventMouseMotion.new()
	motion.position = canvas_pos
	motion.global_position = canvas_pos
	Input.parse_input_event(motion)
	await get_tree().process_frame

	# Press
	var press = InputEventMouseButton.new()
	press.button_index = button
	press.pressed = true
	press.position = canvas_pos
	press.global_position = canvas_pos
	Input.parse_input_event(press)

	# Release after a short delay
	await get_tree().create_timer(0.05).timeout
	var release = InputEventMouseButton.new()
	release.button_index = button
	release.pressed = false
	release.position = canvas_pos
	release.global_position = canvas_pos
	Input.parse_input_event(release)

	# Take a screenshot right after to show the result
	await get_tree().create_timer(0.2).timeout
	_save_screenshot()

	# Report BOTH spaces so a future coordinate mismatch is visible in the result
	# rather than looking like "the click just didn't do anything".
	_write_response({"type": "click", "success": true, "x": x, "y": y,
		"canvas_x": int(canvas_pos.x), "canvas_y": int(canvas_pos.y)})

## Names people reasonably type that OS.find_keycode_from_string() doesn't know.
## ("Return" is the big one — it's the name in most other engines/toolkits, and
## Godot only accepts "Enter".)
const KEY_ALIASES := {
	"return": "Enter", "esc": "Escape", "del": "Delete", "ins": "Insert",
	"pgup": "Page Up", "pgdn": "Page Down", "spacebar": "Space",
	"arrowup": "Up", "arrowdown": "Down", "arrowleft": "Left", "arrowright": "Right",
}


func _cmd_key(cmd: Dictionary) -> void:
	var keycode_str = cmd.get("key", "")
	if KEY_ALIASES.has(String(keycode_str).to_lower()):
		keycode_str = KEY_ALIASES[String(keycode_str).to_lower()]
	var keycode = OS.find_keycode_from_string(keycode_str)
	if keycode == KEY_NONE:
		_write_response({"type": "error", "message": "Unknown key: " + keycode_str})
		return

	# Populate unicode for single printable characters so the key reaches text
	# fields (LineEdit/TextEdit), which ignore key events that carry no unicode.
	var unicode := 0
	if keycode_str.length() == 1:
		unicode = keycode_str.unicode_at(0)

	var press = InputEventKey.new()
	press.keycode = keycode
	press.unicode = unicode
	press.pressed = true
	Input.parse_input_event(press)

	await get_tree().create_timer(0.05).timeout
	var release = InputEventKey.new()
	release.keycode = keycode
	release.unicode = unicode
	release.pressed = false
	Input.parse_input_event(release)

	await get_tree().create_timer(0.2).timeout
	_save_screenshot()

	_write_response({"type": "key", "success": true, "key": keycode_str})

func _cmd_action(cmd: Dictionary) -> void:
	var action_name = cmd.get("name", "")
	if not InputMap.has_action(action_name):
		_write_response({"type": "error", "message": "Unknown action: " + action_name})
		return

	Input.action_press(action_name)
	await get_tree().create_timer(0.05).timeout
	Input.action_release(action_name)

	await get_tree().create_timer(0.2).timeout
	_save_screenshot()

	_write_response({"type": "action_press", "success": true, "name": action_name})


# --- Scene inspection ---

func _cmd_get_tree(cmd: Dictionary) -> void:
	var root_path = cmd.get("path", "/root")
	var max_depth = int(cmd.get("depth", 3))

	var node = get_tree().root.get_node_or_null(root_path.replace("/root", "."))
	if root_path == "/root":
		node = get_tree().root
	if not node:
		_write_response({"type": "error", "message": "Node not found: " + root_path})
		return

	var tree = _node_to_dict(node, 0, max_depth)
	_write_response({"type": "get_tree", "success": true, "tree": tree})

func _resolve_node(path: String) -> Node:
	if path == "/root":
		return get_tree().root
	var relative = path.replace("/root/", "")
	return get_tree().root.get_node_or_null(relative)

func _cmd_get_property(cmd: Dictionary) -> void:
	var node_path = cmd.get("node_path", "")
	var property = cmd.get("property", "")
	var node = _resolve_node(node_path)
	if not node:
		_write_response({"type": "error", "message": "Node not found: " + node_path})
		return
	var value = node.get(property)
	# Convert to JSON-safe types
	var json_value = _variant_to_json(value)
	_write_response({"type": "get_property", "success": true, "node": node_path, "property": property, "value": json_value})

func _cmd_set_property(cmd: Dictionary) -> void:
	var node_path = cmd.get("node_path", "")
	var property = cmd.get("property", "")
	var value = cmd.get("value")
	var node = _resolve_node(node_path)
	if not node:
		_write_response({"type": "error", "message": "Node not found: " + node_path})
		return
	node.set(property, _coerce_to_property_type(node, property, value))
	await _settle(cmd, 0.1)
	_save_screenshot()
	_write_response({"type": "set_property", "success": true, "node": node_path, "property": property})


## Waits for an optional `settle` delay (seconds) before the post-command screenshot.
## Lets a single MCP call cover an async visual change (e.g. a `switch_biome` that
## fades out, rebuilds the hole, and fades back in — ~2s) so the returned screenshot
## reflects the settled state instead of a mid-transition frame. Clamped to stay
## within the server's response-poll budget.
func _settle(cmd: Dictionary, default_sec: float) -> void:
	var settle := float(cmd.get("settle", default_sec))
	settle = clampf(settle, 0.0, 7.0)
	await get_tree().create_timer(settle).timeout


## MCP clients may deliver an untyped `value` argument as a string (e.g. the bool
## `true` arrives as "true"). Object.set() won't convert a String into a bool/number
## property, so coerce the value to the property's current type before assigning.
func _coerce_to_property_type(node: Object, property: String, value: Variant) -> Variant:
	var current = node.get(property)
	if current == null or typeof(value) == typeof(current):
		return value
	match typeof(current):
		TYPE_BOOL:
			if value is String:
				var s := String(value).strip_edges().to_lower()
				return s == "true" or s == "1" or s == "yes"
			return bool(value)
		TYPE_INT:
			if value is String:
				return int(String(value).to_float())
			if value is float or value is bool:
				return int(value)
		TYPE_FLOAT:
			if value is String:
				return String(value).to_float()
			if value is int or value is bool:
				return float(value)
		TYPE_STRING:
			return str(value)
	return value


# --- Dev console / text entry / method calls ---

## Runs a dev console command directly via LimboConsole, bypassing text-field
## focus. The reliable way to drive the in-game console from automation.
func _cmd_console(cmd: Dictionary) -> void:
	var command_line: String = str(cmd.get("command", "")).strip_edges()
	if command_line.is_empty():
		_write_response({"type": "error", "message": "console: 'command' is required"})
		return
	if not _has_limbo_console():
		_write_response({"type": "error", "message": "console: LimboConsole singleton not found"})
		return
	LimboConsole.execute_command(command_line)
	await _settle(cmd, 0.2)
	_save_screenshot()
	_write_response({"type": "console", "success": true, "command": command_line})


## Types a string into the focused LineEdit/TextEdit via real key events (with
## unicode), then optionally presses Enter to submit.
func _cmd_type_text(cmd: Dictionary) -> void:
	var text: String = str(cmd.get("text", ""))
	var submit: bool = bool(cmd.get("submit", false))
	for i in text.length():
		var ch := text[i]
		var ev := InputEventKey.new()
		ev.keycode = OS.find_keycode_from_string(ch.to_upper()) if ch.strip_edges() != "" else KEY_SPACE
		ev.unicode = ch.unicode_at(0)
		ev.pressed = true
		Input.parse_input_event(ev)
		await get_tree().create_timer(0.01).timeout
		var up := InputEventKey.new()
		up.keycode = ev.keycode
		up.unicode = ev.unicode
		up.pressed = false
		Input.parse_input_event(up)
	if submit:
		await get_tree().create_timer(0.05).timeout
		var enter := InputEventKey.new()
		enter.keycode = KEY_ENTER
		enter.pressed = true
		Input.parse_input_event(enter)
		await get_tree().create_timer(0.02).timeout
		var enter_up := InputEventKey.new()
		enter_up.keycode = KEY_ENTER
		enter_up.pressed = false
		Input.parse_input_event(enter_up)
	await get_tree().create_timer(0.2).timeout
	_save_screenshot()
	_write_response({"type": "type_text", "success": true, "text": text, "submit": submit})


## Calls a method on a node and returns the (JSON-safe) result.
func _cmd_call_method(cmd: Dictionary) -> void:
	var node_path = cmd.get("node_path", "")
	var method = cmd.get("method", "")
	var call_args: Array = cmd.get("args", [])
	var node = _resolve_node(node_path)
	if not node:
		_write_response({"type": "error", "message": "Node not found: " + node_path})
		return
	if not node.has_method(method):
		_write_response({"type": "error", "message": "Method not found: %s on %s" % [method, node_path]})
		return
	var converted_args := []
	for arg in call_args:
		converted_args.append(_json_to_variant(arg))
	# `await` is load-bearing: callv() on an ASYNC method raises "Trying to call an
	# async function without await" as a DEBUGGER BREAK, which hard-freezes the game
	# and takes the bridge with it. Awaiting handles both cases — a plain return
	# value passes straight through. (Safe to await here because _execute_command
	# already invokes the _cmd_* handlers as detached coroutines.)
	@warning_ignore("redundant_await")
	var result = await node.callv(method, converted_args)
	_write_response({
		"type": "call_method", "success": true, "node": node_path,
		"method": method, "result": _variant_to_json(result),
	})


func _has_limbo_console() -> bool:
	return get_node_or_null("/root/LimboConsole") != null

## Inverse of _variant_to_json for inbound call args: {"x","y"} dicts become vectors
## (all-int components → Vector2i/Vector3i, else Vector2/Vector3 — GDScript upcasts int
## vectors to float params, so int is the safer guess). Other values pass through.
func _json_to_variant(value: Variant) -> Variant:
	if value is Dictionary:
		var keys := (value as Dictionary).keys()
		keys.sort()
		if keys == ["x", "y"]:
			if value.x is int and value.y is int:
				return Vector2i(value.x, value.y)
			return Vector2(value.x, value.y)
		if keys == ["x", "y", "z"]:
			if value.x is int and value.y is int and value.z is int:
				return Vector3i(value.x, value.y, value.z)
			return Vector3(value.x, value.y, value.z)
	return value


func _variant_to_json(value: Variant) -> Variant:
	if value is Vector2:
		return {"x": value.x, "y": value.y}
	elif value is Vector2i:
		return {"x": value.x, "y": value.y}
	elif value is Vector3:
		return {"x": value.x, "y": value.y, "z": value.z}
	elif value is Vector3i:
		return {"x": value.x, "y": value.y, "z": value.z}
	elif value is Color:
		return {"r": value.r, "g": value.g, "b": value.b, "a": value.a}
	elif value is Transform2D:
		return str(value)
	elif value is Transform3D:
		return str(value)
	elif value is Array:
		var arr := []
		for item in value:
			arr.append(_variant_to_json(item))
		return arr
	elif value is Dictionary:
		var d := {}
		for key in value:
			d[key] = _variant_to_json(value[key])
		return d
	elif value is NodePath:
		return str(value)
	elif value is Object:
		return "<" + value.get_class() + ">"
	else:
		return value

func _node_to_dict(node: Node, depth: int, max_depth: int) -> Dictionary:
	var d := {
		"name": node.name,
		"type": node.get_class(),
	}
	if node is Control:
		d["rect"] = {
			"x": int(node.global_position.x),
			"y": int(node.global_position.y),
			"w": int(node.size.x),
			"h": int(node.size.y),
		}
		d["visible"] = node.visible
		if node is BaseButton:
			d["text"] = node.text if node.has_method("get") and "text" in node else ""
		if node is Label:
			d["text"] = node.text

	if depth < max_depth:
		var children := []
		for child in node.get_children():
			children.append(_node_to_dict(child, depth + 1, max_depth))
		if children.size() > 0:
			d["children"] = children

	return d
