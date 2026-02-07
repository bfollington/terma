# Godot Architecture Patterns

Proven architectural patterns for building maintainable Godot projects, especially when working with LLM coding assistants.

## Core Principles

### 1. Component-Based Design
Break functionality into small, reusable components attached as Node children.

**Benefits:**
- Each component is a focused, understandable file
- Easy to add/remove features
- Clear responsibilities
- LLM-friendly (small files, clear purpose)

### 2. Signal-Driven Communication
Use signals for loose coupling between systems.

**Benefits:**
- Self-documenting (signals show available events)
- Easy to connect UI without modifying game logic
- No complex dependency injection needed
- Clear event flow

### 3. Resource-Based Data
Separate logic (.gd) from data (.tres).

**Benefits:**
- Data files are simple and safe to edit
- Easy to create variants
- Designer-friendly
- LLM can edit data without touching logic

---

## Pattern 1: Component-Based Interaction System

**Use for:** Objects that can be interacted with in different ways.

### Structure

```
BaseInteractable.gd (parent script)
├─ is_interactable: bool
├─ interaction_nodes: Array[InteractionComponent]
└─ interact(player) -> void

InteractionComponent.gd (child node script)
├─ interaction_text: String
├─ is_enabled: bool
├─ interact(player) -> bool
└─ signal: was_interacted_with
```

### Implementation

**BaseInteractable.gd:**
```gdscript
extends Node3D
class_name BaseInteractable

@export var is_interactable: bool = true
var interaction_nodes: Array[InteractionComponent] = []

func _ready():
    # Gather all interaction components
    for child in get_children():
        if child is InteractionComponent:
            interaction_nodes.append(child)

func interact(player) -> void:
    if not is_interactable:
        return

    for interaction in interaction_nodes:
        if interaction.is_enabled:
            interaction.interact(player)
            break  # Only one interaction per press
```

**InteractionComponent.gd:**
```gdscript
extends Node
class_name InteractionComponent

signal was_interacted_with(player)

@export var interaction_text: String = "Interact"
@export var is_enabled: bool = true

func interact(player) -> bool:
    if not is_enabled:
        return false

    _perform_interaction(player)
    was_interacted_with.emit(player)
    return true

func _perform_interaction(player) -> void:
    # Override in subclasses
    pass
```

**Example Subclass - PickupInteraction.gd:**
```gdscript
extends InteractionComponent
class_name PickupInteraction

@export var item_resource: ItemResource

func _perform_interaction(player) -> void:
    if not item_resource:
        push_error("No item resource assigned")
        return

    player.inventory.add_item(item_resource)
    get_parent().queue_free()  # Remove the pickup
```

### Scene Setup (.tscn)

```
[ext_resource type="Script" path="res://src/base_interactable.gd" id="1"]
[ext_resource type="Script" path="res://src/pickup_interaction.gd" id="2"]
[ext_resource type="Resource" path="res://resources/items/key.tres" id="3"]

[node name="KeyPickup" type="StaticBody3D"]
script = ExtResource("1")

[node name="PickupInteraction" type="Node" parent="."]
script = ExtResource("2")
interaction_text = "Pick up Key"
item_resource = ExtResource("3")

[node name="MeshInstance3D" type="MeshInstance3D" parent="."]
# ... mesh configuration
```

### Usage Benefits
- Single object can have multiple interaction types
- Easy to add new interaction types (just create new subclass)
- Interactions can be enabled/disabled dynamically
- Clear separation of concerns

---

## Pattern 2: Attribute System

**Use for:** Health, mana, stamina, or any numeric attribute with min/max values.

### Structure

```
Attribute.gd (base class)
├─ attribute_name: String
├─ value_current: float (with setter)
├─ value_max: float
├─ value_start: float
├─ signal: attribute_changed(name, current, max, increased)
└─ signal: attribute_reached_zero(name)

HealthAttribute.gd (specialized)
├─ extends Attribute
├─ signal: damage_taken(amount)
└─ signal: death()
```

### Implementation

**Attribute.gd:**
```gdscript
extends Node
class_name Attribute

signal attribute_changed(attribute_name: String, value_current: float, value_max: float, value_increased: bool)
signal attribute_reached_zero(attribute_name: String)

@export var attribute_name: String = "Attribute"
@export var value_max: float = 100.0
@export var value_start: float = 100.0

var value_current: float:
    set(value):
        var old_value = value_current
        value_current = clamp(value, 0, value_max)
        var increased = value_current > old_value

        attribute_changed.emit(attribute_name, value_current, value_max, increased)

        if value_current <= 0:
            attribute_reached_zero.emit(attribute_name)

func _ready():
    value_current = value_start

func add(amount: float) -> void:
    value_current += amount

func subtract(amount: float) -> void:
    value_current -= amount
```

**HealthAttribute.gd:**
```gdscript
extends Attribute
class_name HealthAttribute

signal damage_taken(amount: float)
signal death()

func _ready():
    super._ready()
    attribute_name = "Health"
    attribute_reached_zero.connect(_on_death)

func take_damage(amount: float) -> void:
    subtract(amount)
    damage_taken.emit(amount)

func heal(amount: float) -> void:
    add(amount)

func _on_death() -> void:
    death.emit()
```

### Parent Integration

**BaseEnemy.gd:**
```gdscript
extends CharacterBody3D
class_name BaseEnemy

var attributes: Dictionary = {}

func _ready():
    # Gather all attributes
    for child in get_children():
        if child is Attribute:
            attributes[child.attribute_name] = child
            child.attribute_changed.connect(_on_attribute_changed)

    # Connect to health-specific signals
    if attributes.has("Health"):
        attributes["Health"].death.connect(_on_death)

func _on_attribute_changed(attr_name: String, current: float, max_val: float, increased: bool):
    # Update UI or trigger effects
    pass

func _on_death():
    # Drop loot, play animation, etc.
    queue_free()
```

### Scene Setup (.tscn)

```
[ext_resource type="Script" path="res://src/base_enemy.gd" id="1"]
[ext_resource type="Script" path="res://src/health_attribute.gd" id="2"]

[node name="Enemy" type="CharacterBody3D"]
script = ExtResource("1")

[node name="HealthAttribute" type="Node" parent="."]
script = ExtResource("2")
value_max = 50.0
value_start = 50.0
```

---

## Pattern 3: Resource-Based Effect System

**Use for:** Spells, abilities, items, or any combinable effects.

### Structure

```
SpellEffect.gd (individual effect)
├─ effect_type: enum
├─ magnitude_min/max: float
├─ duration: float
└─ apply_effect(target, caster)

SpellResource.gd (combines effects)
├─ effects: Array[SpellEffect]
├─ mana_cost: float
├─ projectile_speed: float
└─ spell_color: Color
```

### Implementation

**SpellEffect.gd:**
```gdscript
extends Resource
class_name SpellEffect

enum EffectType {
    DAMAGE,
    HEAL,
    RESTORE_MANA,
    DAMAGE_OVER_TIME,
    HEAL_OVER_TIME,
    SLOW,
    SPEED_BOOST,
    STUN,
    # ... more types
}

@export var effect_type: EffectType = EffectType.DAMAGE
@export var magnitude_min: float = 10.0
@export var magnitude_max: float = 10.0
@export var duration: float = 0.0
@export var tick_rate: float = 1.0  # For over-time effects

func apply_effect(target: Node, caster: Node) -> void:
    var magnitude = randf_range(magnitude_min, magnitude_max)

    match effect_type:
        EffectType.DAMAGE:
            _apply_damage(target, magnitude)
        EffectType.HEAL:
            _apply_heal(target, magnitude)
        EffectType.SLOW:
            _apply_slow(target, magnitude, duration)
        # ... handle other types

func _apply_damage(target: Node, amount: float) -> void:
    if target.has_method("take_damage"):
        target.take_damage(amount)

func _apply_heal(target: Node, amount: float) -> void:
    if target.has_node("HealthAttribute"):
        target.get_node("HealthAttribute").heal(amount)

func _apply_slow(target: Node, percent: float, dur: float) -> void:
    # Apply slow effect logic
    pass
```

**SpellResource.gd:**
```gdscript
extends Resource
class_name SpellResource

@export var spell_id: String = ""
@export var spell_name: String = "Spell"
@export var mana_cost: float = 10.0
@export var effects: Array[SpellEffect] = []
@export var projectile_speed: float = 20.0
@export var spell_color: Color = Color.WHITE

func cast(caster: Node, target_position: Vector3) -> void:
    # Spawn projectile or apply effects immediately
    pass

func apply_effects(target: Node, caster: Node) -> void:
    for effect in effects:
        effect.apply_effect(target, caster)
```

### Data File (.tres)

```tres
[gd_resource type="Resource" script_class="SpellResource" load_steps=4 format=3]

[ext_resource type="Script" path="res://src/spells/spell_resource.gd" id="1"]
[ext_resource type="Script" path="res://src/spells/spell_effect.gd" id="2"]

[sub_resource type="Resource" id="Effect_damage"]
script = ExtResource("2")
effect_type = 0
magnitude_min = 15.0
magnitude_max = 25.0

[sub_resource type="Resource" id="Effect_slow"]
script = ExtResource("2")
effect_type = 12
magnitude_min = 50.0
magnitude_max = 50.0
duration = 3.0

[resource]
script = ExtResource("1")
spell_name = "Ice Bolt"
spell_id = "ice_bolt"
mana_cost = 20.0
spell_color = Color(0.5, 0.7, 1, 1)
projectile_speed = 15.0
effects = Array[ExtResource("2")]([SubResource("Effect_damage"), SubResource("Effect_slow")])
```

### Benefits
- Create new spells with just data (no code changes)
- Combinable effects create emergent gameplay
- Easy for LLM to generate new spell variants
- Designer-friendly (edit in Inspector)

---

## Pattern 4: Inventory System

**Use for:** Player/enemy inventories, containers, shops.

### Structure

```
ItemResource.gd (data)
├─ item_id: String
├─ item_name: String
├─ description: String
├─ icon: Texture2D
└─ stackable: bool

Inventory.gd (logic)
├─ items: Array[ItemResource]
├─ add_item(item)
├─ remove_item(item_id)
├─ has_item(item_id) -> bool
└─ signal: item_added/removed
```

### Implementation

**ItemResource.gd:**
```gdscript
extends Resource
class_name ItemResource

@export var item_id: String = ""
@export var item_name: String = "Item"
@export var description: String = ""
@export var icon: Texture2D
@export var stackable: bool = false
@export var max_stack: int = 99
```

**Inventory.gd:**
```gdscript
extends Node
class_name Inventory

signal item_added(item: ItemResource)
signal item_removed(item_id: String)

var items: Array[ItemResource] = []

func add_item(item: ItemResource) -> bool:
    if not item:
        return false

    items.append(item)
    item_added.emit(item)
    return true

func remove_item(item_id: String) -> bool:
    for i in range(items.size()):
        if items[i].item_id == item_id:
            var removed = items[i]
            items.remove_at(i)
            item_removed.emit(item_id)
            return true
    return false

func has_item(item_id: String) -> bool:
    for item in items:
        if item.item_id == item_id:
            return true
    return false

func get_item(item_id: String) -> ItemResource:
    for item in items:
        if item.item_id == item_id:
            return item
    return null
```

---

## Pattern 5: State Machine

**Use for:** AI behavior, player states, animation control.

### Structure

```
StateMachine.gd
├─ current_state: State
├─ states: Dictionary
├─ change_state(state_name)
└─ _process/_physics_process

State.gd (base)
├─ enter()
├─ exit()
├─ process(delta)
└─ physics_process(delta)
```

### Implementation

**State.gd:**
```gdscript
extends Node
class_name State

signal state_finished(next_state: String)

func enter() -> void:
    pass

func exit() -> void:
    pass

func process(delta: float) -> void:
    pass

func physics_process(delta: float) -> void:
    pass
```

**StateMachine.gd:**
```gdscript
extends Node
class_name StateMachine

@export var initial_state: String = ""

var states: Dictionary = {}
var current_state: State = null

func _ready():
    # Gather all state children
    for child in get_children():
        if child is State:
            states[child.name] = child
            child.state_finished.connect(_on_state_finished)

    if initial_state and states.has(initial_state):
        change_state(initial_state)

func _process(delta: float):
    if current_state:
        current_state.process(delta)

func _physics_process(delta: float):
    if current_state:
        current_state.physics_process(delta)

func change_state(new_state_name: String) -> void:
    if current_state:
        current_state.exit()

    current_state = states.get(new_state_name)

    if current_state:
        current_state.enter()

func _on_state_finished(next_state: String) -> void:
    change_state(next_state)
```

**Example State - IdleState.gd:**
```gdscript
extends State
class_name IdleState

@export var idle_time: float = 2.0

var timer: float = 0.0

func enter() -> void:
    timer = 0.0
    print("Entering idle state")

func process(delta: float) -> void:
    timer += delta
    if timer >= idle_time:
        state_finished.emit("Patrol")
```

---

## Combining Patterns

These patterns work together naturally:

```gdscript
# Enemy with attributes, state machine, and loot
BaseEnemy (CharacterBody3D)
├─ HealthAttribute (Attribute component)
├─ ManaAttribute (Attribute component)
├─ StateMachine
│   ├─ IdleState
│   ├─ PatrolState
│   ├─ ChaseState
│   └─ AttackState
└─ LootDropper (Component)
    └─ loot_table: Array[LootEntry]
```

Each component handles one responsibility, making the system:
- Easy to understand
- Simple to modify
- Clear to debug
- LLM-friendly to work with
