extends Node
class_name InteractionTemplate

## Base class for interaction components following the component pattern.
##
## Usage:
## 1. Create subclass extending InteractionTemplate
## 2. Override _perform_interaction() with custom logic
## 3. Attach as child to BaseInteractable object
## 4. Set interaction_text and other exports in Inspector
##
## Example subclass:
##   extends InteractionTemplate
##   class_name DoorInteraction
##
##   @export var door_id: String
##   @export var requires_key: bool = false
##
##   func _perform_interaction(player) -> void:
##       if requires_key and not player.has_key(door_id):
##           return
##       get_parent().open()

# Signals
signal was_interacted_with(player: Node)
signal interaction_enabled
signal interaction_disabled

# Configuration
@export_group("Interaction Settings")
@export var interaction_text: String = "Interact"
@export var is_enabled: bool = true
@export var single_use: bool = false

@export_group("Requirements")
@export var required_item_id: String = ""
@export var minimum_level: int = 0

# Internal state
var _has_been_used: bool = false

## Attempt to interact with this component
## Returns true if interaction was successful
func interact(player: Node) -> bool:
	if not can_interact(player):
		return false

	_perform_interaction(player)
	was_interacted_with.emit(player)

	if single_use:
		_has_been_used = true
		disable()

	return true

## Check if interaction is possible
func can_interact(player: Node) -> bool:
	if not is_enabled:
		return false

	if single_use and _has_been_used:
		return false

	if required_item_id and not _player_has_item(player, required_item_id):
		return false

	if minimum_level > 0 and not _player_meets_level(player, minimum_level):
		return false

	return true

## Get the text to display for this interaction
func get_interaction_text() -> String:
	return interaction_text

## Enable this interaction
func enable() -> void:
	is_enabled = true
	interaction_enabled.emit()

## Disable this interaction
func disable() -> void:
	is_enabled = false
	interaction_disabled.emit()

## Reset for reuse (if not single_use)
func reset() -> void:
	if not single_use:
		_has_been_used = false
		enable()

## OVERRIDE THIS: Perform the actual interaction logic
func _perform_interaction(player: Node) -> void:
	print("[", get_parent().name, "] Interacted by ", player.name)
	# Override in subclasses with specific interaction logic

## Helper: Check if player has required item
func _player_has_item(player: Node, item_id: String) -> bool:
	if not player.has_method("has_item"):
		return false
	return player.has_item(item_id)

## Helper: Check if player meets level requirement
func _player_meets_level(player: Node, level: int) -> bool:
	if not player.has_method("get_level"):
		return false
	return player.get_level() >= level
