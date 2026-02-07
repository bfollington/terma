extends Node
class_name ComponentTemplate

## A reusable component template following Godot best practices.
##
## Usage:
## 1. Attach as child node to the object that needs this functionality
## 2. Export variables appear in Inspector for easy configuration
## 3. Use signals for loose coupling with parent/other systems

# Signals for event-driven communication
signal component_activated
signal component_deactivated
signal component_updated(data: Dictionary)

# Export variables for Inspector configuration
@export_group("Component Settings")
@export var is_enabled: bool = true
@export var auto_start: bool = true

@export_group("Behavior")
@export var update_interval: float = 1.0

# Internal state
var _timer: float = 0.0
var _is_active: bool = false

## Called when the node enters the scene tree
func _ready() -> void:
	if auto_start:
		activate()

## Called every frame
func _process(delta: float) -> void:
	if not _is_active or not is_enabled:
		return

	_timer += delta
	if _timer >= update_interval:
		_update()
		_timer = 0.0

## Activate the component
func activate() -> void:
	if _is_active:
		return

	_is_active = true
	component_activated.emit()
	print("[", name, "] Component activated")

## Deactivate the component
func deactivate() -> void:
	if not _is_active:
		return

	_is_active = false
	component_deactivated.emit()
	print("[", name, "] Component deactivated")

## Internal update logic - override in subclasses
func _update() -> void:
	var data = {
		"timestamp": Time.get_ticks_msec(),
		"component": name
	}
	component_updated.emit(data)

## Public interface for parent to call
func do_something() -> void:
	if not is_enabled:
		push_warning("Component not enabled")
		return

	# Implementation here
	pass
