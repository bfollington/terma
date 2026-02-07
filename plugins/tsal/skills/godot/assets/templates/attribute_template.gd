extends Node
class_name AttributeTemplate

## Base attribute system for managing numeric values with min/max constraints.
##
## Usage:
## 1. Attach to character/object as child node
## 2. Set value_max and value_start in Inspector
## 3. Connect to signals in parent script
## 4. Call add()/subtract() to modify value
##
## Example:
##   var health = $HealthAttribute
##   health.attribute_changed.connect(_on_health_changed)
##   health.subtract(10.0)  # Take 10 damage

# Signals
signal attribute_changed(attribute_name: String, value_current: float, value_max: float, value_increased: bool)
signal attribute_reached_zero(attribute_name: String)
signal attribute_reached_max(attribute_name: String)

# Configuration
@export_group("Attribute Settings")
@export var attribute_name: String = "Attribute"
@export var value_max: float = 100.0
@export var value_start: float = 100.0

@export_group("Regeneration")
@export var auto_regenerate: bool = false
@export var regen_rate: float = 1.0  # Per second
@export var regen_delay: float = 3.0  # Delay after damage

# Current value with automatic clamping and signal emission
var value_current: float:
	set(value):
		var old_value = value_current
		value_current = clamp(value, 0, value_max)
		var increased = value_current > old_value

		attribute_changed.emit(attribute_name, value_current, value_max, increased)

		if value_current <= 0:
			attribute_reached_zero.emit(attribute_name)
		elif value_current >= value_max and old_value < value_max:
			attribute_reached_max.emit(attribute_name)

# Internal state for regeneration
var _regen_timer: float = 0.0

## Initialize the attribute
func _ready() -> void:
	value_current = value_start
	print("[", attribute_name, "] Initialized: ", value_current, "/", value_max)

## Handle regeneration
func _process(delta: float) -> void:
	if not auto_regenerate:
		return

	if value_current >= value_max:
		_regen_timer = 0.0
		return

	_regen_timer += delta
	if _regen_timer >= regen_delay:
		add(regen_rate * delta)

## Add to the attribute value
func add(amount: float) -> void:
	if amount <= 0:
		return
	value_current += amount

## Subtract from the attribute value
func subtract(amount: float) -> void:
	if amount <= 0:
		return
	value_current -= amount
	_regen_timer = 0.0  # Reset regen timer on damage

## Set to a specific value
func set_value(new_value: float) -> void:
	value_current = new_value

## Set to maximum
func set_to_max() -> void:
	value_current = value_max

## Set to zero
func set_to_zero() -> void:
	value_current = 0.0

## Get current percentage (0.0 to 1.0)
func get_percentage() -> float:
	if value_max <= 0:
		return 0.0
	return value_current / value_max

## Check if attribute is depleted
func is_depleted() -> bool:
	return value_current <= 0

## Check if attribute is full
func is_full() -> bool:
	return value_current >= value_max

## Get remaining value
func get_remaining() -> float:
	return value_max - value_current
