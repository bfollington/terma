# Common Godot Pitfalls and Solutions

This document catalogs frequent mistakes, gotchas, and their solutions when working with Godot 4.x projects.

## Initialization and @onready Timing

### The Problem

`@onready` variables are initialized when `_ready()` is called, but the order of initialization across the scene tree can cause issues.

### Common Pitfall: Null References from Parent Methods

**Problem:**
```gdscript
# In child component
@onready var player: CharacterBody3D = get_parent()
@onready var camera: Camera3D = player.get_camera()  # ❌ Returns null!

func _ready():
    # camera is null here - get_camera() wasn't available during @onready
```

**Why it fails:**
- `@onready` runs before `_ready()` in the scene tree
- If `get_camera()` returns a node that's dynamically set up, it may not exist yet
- Parent initialization might not be complete

**Solution: Use dynamic getters**
```gdscript
# ✅ Better approach
@onready var player: CharacterBody3D = get_parent()

func _get_camera() -> Camera3D:
    if player and player.has_method("get_camera"):
        return player.get_camera()
    return null

func perform_action():
    var camera = _get_camera()
    if camera:
        # Use camera
```

**Solution: Initialize in _ready()**
```gdscript
# ✅ Alternative approach
var player: CharacterBody3D
var camera: Camera3D

func _ready():
    player = get_parent()
    if player and player.has_method("get_camera"):
        camera = player.get_camera()
```

### Common Pitfall: Accessing Child Nodes Too Early

**Problem:**
```gdscript
# Parent node
@onready var child_component = $ChildComponent

func _ready():
    child_component.setup()  # ❌ Might fail if child's _ready() hasn't run

# Child node
var is_initialized: bool = false

func _ready():
    # Complex initialization
    is_initialized = true

func setup():
    if not is_initialized:
        push_error("Called setup() before initialization!")
```

**Solution: Use call_deferred or signals**
```gdscript
# ✅ Parent waits for child to be ready
func _ready():
    await get_tree().process_frame  # Wait one frame
    child_component.setup()

# ✅ Or use signals
func _ready():
    child_component.initialized.connect(_on_child_ready)

func _on_child_ready():
    # Child is definitely ready now
```

### _ready() Execution Order

**Key principle**: `_ready()` is called **bottom-up** in the scene tree (children before parents).

```
SceneRoot
├─ Parent (ready called THIRD)
   ├─ Child1 (ready called FIRST)
   └─ Child2 (ready called SECOND)
```

**Implications:**
- Children's `_ready()` complete before parent's `_ready()` starts
- Parent can safely access child nodes in `_ready()`
- Children should NOT assume parent is ready during their `_ready()`

**Example:**
```gdscript
# Child component
func _ready():
    var parent = get_parent()
    # ❌ Don't call parent.initialize() - parent's _ready() hasn't run yet
    # ✅ Instead, emit a signal or wait
    ready.emit()

# Parent
func _ready():
    for child in get_children():
        # ✅ Children are fully ready here
        if child.has_method("configure"):
            child.configure(some_data)
```

## Node References and get_node()

### Common Pitfall: Hardcoded NodePaths Breaking

**Problem:**
```gdscript
@onready var health_bar = $"../UI/HealthBar"  # ❌ Fragile - breaks if hierarchy changes
```

**Solution: Use groups or signals**
```gdscript
# ✅ Add HealthBar to "ui_health" group in editor
func _ready():
    var health_bar = get_tree().get_first_node_in_group("ui_health")

# ✅ Or use signals
signal health_changed(current: float, max: float)

func take_damage(amount: float):
    health -= amount
    health_changed.emit(health, max_health)  # UI listens to this
```

### Common Pitfall: Using get_node() in @onready with Complex Paths

**Problem:**
```gdscript
@onready var camera = get_node("../../CameraPivot/Camera3D")  # ❌ Error-prone
```

**Solution: Find node by type or group**
```gdscript
# ✅ Find by type
func _get_camera() -> Camera3D:
    var current = get_parent()
    while current:
        if current is Camera3D:
            return current
        for child in current.get_children():
            if child is Camera3D:
                return child
        current = current.get_parent()
    return null

# ✅ Or add camera to "camera" group and find it
func _ready():
    var camera = get_tree().get_first_node_in_group("main_camera")
```

## Signal Connection Issues

### Common Pitfall: Connecting Signals in Wrong Order

**Problem:**
```gdscript
func _ready():
    $Button.pressed.connect(_on_button_pressed)
    $Button.pressed.emit()  # ❌ Connection might not be active yet
```

**Solution: Wait one frame or use call_deferred**
```gdscript
func _ready():
    $Button.pressed.connect(_on_button_pressed)
    await get_tree().process_frame
    $Button.pressed.emit()  # ✅ Connection is active

# Or
func _ready():
    $Button.pressed.connect(_on_button_pressed)
    $Button.pressed.emit.call_deferred()  # ✅ Emits after _ready() completes
```

### Common Pitfall: Memory Leaks from Signal Connections

**Problem:**
```gdscript
func _ready():
    some_node.signal_name.connect(callback)
    # ❌ If this node is freed but some_node remains, connection persists
```

**Solution: Disconnect in cleanup or use weak references**
```gdscript
var connected_node: Node

func _ready():
    connected_node = some_node
    connected_node.signal_name.connect(callback)

func _exit_tree():
    if connected_node and connected_node.signal_name.is_connected(callback):
        connected_node.signal_name.disconnect(callback)

# Or use one-shot connections
func _ready():
    some_node.signal_name.connect(callback, CONNECT_ONE_SHOT)
```

## Resource Loading and Modification

### Common Pitfall: Modifying Shared Resources

**Problem:**
```gdscript
# item_resource.tres is shared across all instances
@export var item: ItemResource

func _ready():
    item.quantity += 1  # ❌ Modifies the .tres file for ALL instances!
```

**Solution: Duplicate resources when modifying**
```gdscript
@export var item: ItemResource
var local_item: ItemResource

func _ready():
    local_item = item.duplicate()  # ✅ Create instance-specific copy
    local_item.quantity += 1  # Only affects this instance
```

### Common Pitfall: preload() in .tres Files

**Problem:**
```tres
[resource]
script = preload("res://script.gd")  # ❌ WRONG - .tres files don't support preload()
```

**Solution: Use ExtResource**
```tres
[ext_resource type="Script" path="res://script.gd" id="1"]

[resource]
script = ExtResource("1")  # ✅ Correct
```

## CharacterBody3D Movement

### Common Pitfall: Velocity Not Persisting

**Problem:**
```gdscript
func _physics_process(delta):
    var velocity = Vector3.ZERO  # ❌ Resets velocity every frame!
    velocity.x = input.x * speed
    move_and_slide()
```

**Solution: Use the velocity property**
```gdscript
func _physics_process(delta):
    velocity.x = input.x * speed  # ✅ Modifies persistent velocity
    velocity.y -= gravity * delta
    move_and_slide()
```

### Common Pitfall: Floor Detection Issues

**Problem:**
```gdscript
func _physics_process(delta):
    if is_on_floor():
        velocity.y = 0  # ❌ Causes jittering on slopes
```

**Solution: Only reset vertical velocity when needed**
```gdscript
func _physics_process(delta):
    # Apply gravity
    if not is_on_floor():
        velocity.y -= gravity * delta

    # Jump
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_force  # ✅ Only set when jumping

    move_and_slide()
```

## Transform and Basis Confusion

### Common Pitfall: Wrong Direction Vector

**Problem:**
```gdscript
var forward = transform.basis.z  # ❌ This is actually backward in Godot!
```

**Solution: Negate Z for forward**
```gdscript
var forward = -transform.basis.z  # ✅ Forward direction
var right = transform.basis.x     # ✅ Right direction
var up = transform.basis.y        # ✅ Up direction
```

### Common Pitfall: Mixing Local and Global Transforms

**Problem:**
```gdscript
position += Vector3.FORWARD * speed  # ❌ Moves in global forward, not local
```

**Solution: Use basis to transform direction**
```gdscript
position += -transform.basis.z * speed  # ✅ Moves in local forward direction

# Or use global_transform for global operations
global_position += Vector3.FORWARD * speed  # ✅ Explicitly global
```

## Input Handling

### Common Pitfall: Input Processed in _process() and _physics_process()

**Problem:**
```gdscript
func _process(delta):
    if Input.is_action_just_pressed("jump"):
        jump()  # ❌ Might miss input if physics runs at different rate

func _physics_process(delta):
    # Physics code
```

**Solution: Handle input where it's used**
```gdscript
# For movement: use _physics_process
func _physics_process(delta):
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_force
    move_and_slide()

# For UI/non-physics: use _input or _unhandled_input
func _input(event):
    if event.is_action_pressed("menu"):
        open_menu()
```

### Common Pitfall: Mouse Capture Issues

**Problem:**
```gdscript
func _ready():
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# ❌ Escape key doesn't work - mouse is captured forever
```

**Solution: Toggle mouse mode with escape**
```gdscript
func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        else:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
```

## Type Safety and Static Typing

### Common Pitfall: Weak Typing Hiding Errors

**Problem:**
```gdscript
var node = get_node("Player")
node.health = 100  # ❌ No error if Player doesn't have health property
```

**Solution: Use static typing**
```gdscript
var player: Player = get_node("Player") as Player
if player:
    player.health = 100  # ✅ Error if Player class doesn't have health
```

### Common Pitfall: Null Checks Missing

**Problem:**
```gdscript
var target = get_tree().get_first_node_in_group("player")
var distance = global_position.distance_to(target.global_position)  # ❌ Crashes if no player
```

**Solution: Always check for null**
```gdscript
var target = get_tree().get_first_node_in_group("player")
if target:
    var distance = global_position.distance_to(target.global_position)  # ✅ Safe
```

## Scene Instancing

### Common Pitfall: Forgetting to Add Instanced Scene to Tree

**Problem:**
```gdscript
var scene = preload("res://enemy.tscn")
var enemy = scene.instantiate()
enemy.position = spawn_point  # ❌ Enemy exists but isn't in the scene tree!
```

**Solution: Add to tree**
```gdscript
var scene = preload("res://enemy.tscn")
var enemy = scene.instantiate()
add_child(enemy)  # ✅ Add to tree
enemy.global_position = spawn_point  # Use global_position after add_child
```

### Common Pitfall: Setting Position Before Adding to Tree

**Problem:**
```gdscript
var enemy = scene.instantiate()
enemy.position = Vector3(10, 0, 10)  # ❌ Local position, might be wrong after add_child
add_child(enemy)
```

**Solution: Set global position after adding**
```gdscript
var enemy = scene.instantiate()
add_child(enemy)
enemy.global_position = Vector3(10, 0, 10)  # ✅ Global position after in tree
```

## Tween Issues

### Common Pitfall: Creating Tweens Without Cleanup

**Problem:**
```gdscript
func animate():
    var tween = create_tween()
    tween.tween_property(self, "position", target, 1.0)
    # ❌ If called repeatedly, creates multiple tweens conflicting
```

**Solution: Kill previous tweens or check is_valid()**
```gdscript
var current_tween: Tween

func animate():
    if current_tween and current_tween.is_valid():
        current_tween.kill()  # ✅ Stop previous animation

    current_tween = create_tween()
    current_tween.tween_property(self, "position", target, 1.0)
```

### Common Pitfall: Tween Callbacks Not Firing

**Problem:**
```gdscript
func swing_weapon():
    var tween = create_tween()
    tween.tween_property(weapon, "rotation", target_rotation, 0.5)
    tween.tween_callback(finish_swing)  # ❌ Might not fire if tween is killed
```

**Solution: Use await or check tween validity**
```gdscript
func swing_weapon():
    var tween = create_tween()
    tween.tween_property(weapon, "rotation", target_rotation, 0.5)
    await tween.finished  # ✅ Waits for tween to complete
    finish_swing()
```

## Summary: Quick Checklist

When encountering issues, check:

- [ ] Is `@onready` causing timing issues? → Use dynamic getters or initialize in `_ready()`
- [ ] Are you accessing parent methods in child's `_ready()`? → Wait a frame or use signals
- [ ] Is a node reference null? → Check scene tree structure and initialization order
- [ ] Using `get_node()` with complex paths? → Use groups or find by type
- [ ] Modifying a shared resource? → Duplicate it first
- [ ] Movement not working? → Check you're using `velocity` property, not local variable
- [ ] Direction vector wrong? → Remember `-transform.basis.z` is forward
- [ ] Tween not working? → Kill previous tweens, use await for callbacks
- [ ] Input missed? → Process input where it's used (_physics_process for movement)
- [ ] Null reference error? → Add null checks before accessing properties
- [ ] Instance not appearing? → Remember to `add_child()` and use `global_position`

## When in Doubt

1. **Print debug info**: `print()` is your friend
2. **Check the scene tree**: Use Remote tab in editor while game runs
3. **Enable visible collision shapes**: Debug → Visible Collision Shapes
4. **Read error messages carefully**: They often point to the exact issue
5. **Consult official docs**: https://docs.godotengine.org/
