extends Node
## Godot MCP Bridge
## Autoload singleton enabling Claude Code to observe and control the game.
##
## Features:
## - Auto-saves viewport screenshots to /tmp/godot_screenshot.png every 2s
## - Polls /tmp/godot_mcp_command.json for input commands (click, key, action)
## - Writes responses to /tmp/godot_mcp_response.json
##
## Usage from Claude Code:
##   Write command JSON to /tmp/godot_mcp_command.json
##   Read /tmp/godot_screenshot.png to see result
##   Read /tmp/godot_mcp_response.json for command confirmation

const SCREENSHOT_PATH := "/tmp/godot_screenshot.png"
const COMMAND_PATH := "/tmp/godot_mcp_command.json"
const RESPONSE_PATH := "/tmp/godot_mcp_response.json"
const SCREENSHOT_INTERVAL := 2.0

var response_prefix := "MCP_RESPONSE:"
var _screenshot_timer := 0.0
var _frames_since_ready := 0

func _ready():
	# Clean up stale command file from previous runs
	if FileAccess.file_exists(COMMAND_PATH):
		DirAccess.remove_absolute(COMMAND_PATH)
	print(response_prefix + '{"type":"ready","bridge_version":"3.0"}')
	print("Godot MCP Bridge initialized — screenshots: %s, commands: %s" % [SCREENSHOT_PATH, COMMAND_PATH])

func _process(delta: float):
	# Wait a few frames for the scene to render before first screenshot
	if _frames_since_ready < 10:
		_frames_since_ready += 1
		if _frames_since_ready == 10:
			_save_screenshot()
		return

	# Poll for command file
	_poll_commands()

	# Periodic screenshots
	_screenshot_timer += delta
	if _screenshot_timer >= SCREENSHOT_INTERVAL:
		_screenshot_timer = 0.0
		_save_screenshot()


# --- Screenshots ---

func _save_screenshot():
	var viewport = get_tree().root.get_viewport()
	if not viewport:
		return
	var img = viewport.get_texture().get_image()
	if not img:
		return
	img.save_png(SCREENSHOT_PATH)

func request_screenshot():
	_save_screenshot()
	_write_response({"type": "screenshot", "success": true, "path": SCREENSHOT_PATH})


# --- Command polling ---

func _poll_commands():
	if not FileAccess.file_exists(COMMAND_PATH):
		return

	var f = FileAccess.open(COMMAND_PATH, FileAccess.READ)
	if not f:
		return
	var text = f.get_as_text()
	f.close()

	# Delete the command file immediately so we don't re-process
	DirAccess.remove_absolute(COMMAND_PATH)

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

func _execute_command(cmd: Dictionary):
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
		_:
			_write_response({"type": "error", "message": "Unknown action: " + action})

func _write_response(data: Dictionary):
	var f = FileAccess.open(RESPONSE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data, "\t"))
		f.close()
	print(response_prefix + JSON.stringify(data))


# --- Input simulation ---

func _cmd_click(cmd: Dictionary):
	var x = int(cmd.get("x", 0))
	var y = int(cmd.get("y", 0))
	var button = int(cmd.get("button", MOUSE_BUTTON_LEFT))

	# Press
	var press = InputEventMouseButton.new()
	press.button_index = button
	press.pressed = true
	press.position = Vector2(x, y)
	press.global_position = Vector2(x, y)
	Input.parse_input_event(press)

	# Release after a short delay
	await get_tree().create_timer(0.05).timeout
	var release = InputEventMouseButton.new()
	release.button_index = button
	release.pressed = false
	release.position = Vector2(x, y)
	release.global_position = Vector2(x, y)
	Input.parse_input_event(release)

	# Take a screenshot right after to show the result
	await get_tree().create_timer(0.2).timeout
	_save_screenshot()

	_write_response({"type": "click", "success": true, "x": x, "y": y})

func _cmd_key(cmd: Dictionary):
	var keycode_str = cmd.get("key", "")
	var keycode = OS.find_keycode_from_string(keycode_str)
	if keycode == KEY_NONE:
		_write_response({"type": "error", "message": "Unknown key: " + keycode_str})
		return

	var press = InputEventKey.new()
	press.keycode = keycode
	press.pressed = true
	Input.parse_input_event(press)

	await get_tree().create_timer(0.05).timeout
	var release = InputEventKey.new()
	release.keycode = keycode
	release.pressed = false
	Input.parse_input_event(release)

	await get_tree().create_timer(0.2).timeout
	_save_screenshot()

	_write_response({"type": "key", "success": true, "key": keycode_str})

func _cmd_action(cmd: Dictionary):
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

func _cmd_get_tree(cmd: Dictionary):
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

func _cmd_get_property(cmd: Dictionary):
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

func _cmd_set_property(cmd: Dictionary):
	var node_path = cmd.get("node_path", "")
	var property = cmd.get("property", "")
	var value = cmd.get("value")
	var node = _resolve_node(node_path)
	if not node:
		_write_response({"type": "error", "message": "Node not found: " + node_path})
		return
	node.set(property, value)
	await get_tree().create_timer(0.1).timeout
	_save_screenshot()
	_write_response({"type": "set_property", "success": true, "node": node_path, "property": property})

func _variant_to_json(value) -> Variant:
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
