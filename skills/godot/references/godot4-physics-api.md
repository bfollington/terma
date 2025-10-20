# Godot 4.x Physics API Quick Reference

This reference covers common physics operations in Godot 4.x, focusing on correct API usage and common patterns.

## Raycasting

### PhysicsRayQueryParameters3D (Correct Class Name)

**Important**: The class is `PhysicsRayQueryParameters3D`, NOT `PhysicsRayQuery3D`.

### Basic Raycast Setup

```gdscript
# Get the physics space
var space_state = get_world_3d().direct_space_state

# Create ray query parameters
var query = PhysicsRayQueryParameters3D.create(from_position, to_position)

# Optional: Exclude specific bodies
query.exclude = [self, other_body]

# Optional: Set collision mask (which layers to check)
query.collision_mask = 1  # Layer 1 only
query.collision_mask = 0b0011  # Layers 1 and 2

# Perform the raycast
var result = space_state.intersect_ray(query)

# Check if hit something
if result:
    var hit_object = result.collider
    var hit_position = result.position
    var hit_normal = result.normal
```

### Common Raycast Patterns

**Camera-based raycast (first-person interaction):**
```gdscript
var camera = get_viewport().get_camera_3d()
var from = camera.global_position
var to = from + (-camera.global_transform.basis.z * range)

var query = PhysicsRayQueryParameters3D.create(from, to)
query.exclude = [player]
var result = space_state.intersect_ray(query)
```

**Downward raycast (ground detection):**
```gdscript
var from = global_position
var to = global_position + Vector3.DOWN * 10.0

var query = PhysicsRayQueryParameters3D.create(from, to)
var result = space_state.intersect_ray(query)

if result:
    var distance_to_ground = from.distance_to(result.position)
```

**Line-of-sight check:**
```gdscript
func has_line_of_sight(target: Node3D) -> bool:
    var space_state = get_world_3d().direct_space_state
    var from = global_position
    var to = target.global_position

    var query = PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [self, target]

    var result = space_state.intersect_ray(query)
    return not result  # True if nothing blocking
```

## Shape Queries

### PhysicsShapeQueryParameters3D

For checking if a shape overlaps with objects (useful for area attacks, detection zones).

```gdscript
# Create shape query
var query = PhysicsShapeQueryParameters3D.new()

# Set the shape (sphere, box, capsule, etc.)
var sphere = SphereShape3D.new()
sphere.radius = 2.0
query.shape = sphere

# Set transform (position and rotation)
query.transform = Transform3D(Basis(), global_position)

# Optional: collision mask
query.collision_mask = 1

# Perform query
var space_state = get_world_3d().direct_space_state
var results = space_state.intersect_shape(query)

# Iterate results
for result in results:
    var collider = result.collider
    # Do something with each overlapping object
```

### Common Shape Query Patterns

**Area attack (sphere around player):**
```gdscript
func perform_area_attack(radius: float, damage: float):
    var query = PhysicsShapeQueryParameters3D.new()
    var sphere = SphereShape3D.new()
    sphere.radius = radius
    query.shape = sphere
    query.transform = Transform3D(Basis(), global_position)
    query.collision_mask = 2  # Enemies layer

    var space_state = get_world_3d().direct_space_state
    var results = space_state.intersect_shape(query)

    for result in results:
        if result.collider.has_method("take_damage"):
            result.collider.take_damage(damage)
```

**Cone detection (enemy field of view):**
```gdscript
# Use multiple raycasts in a cone pattern
func detect_in_cone(angle_degrees: float, range: float) -> Array:
    var detected = []
    var rays = 5  # Number of rays in cone

    for i in range(rays):
        var angle = -angle_degrees/2 + (angle_degrees / (rays-1)) * i
        var direction = global_transform.basis.z.rotated(Vector3.UP, deg_to_rad(angle))

        var from = global_position
        var to = from + direction * range

        var query = PhysicsRayQueryParameters3D.create(from, to)
        var result = space_state.intersect_ray(query)

        if result:
            detected.append(result.collider)

    return detected
```

## Collision Layers and Masks

Understanding layers is critical for efficient physics.

### Layer Setup

```gdscript
# In project settings, name your layers:
# Layer 1: World (walls, floors)
# Layer 2: Player
# Layer 3: Enemies
# Layer 4: Projectiles
# Layer 5: Interactables

# Set what layers an object is ON
collision_layer = 0b00010  # Layer 2 (Player)

# Set what layers an object can COLLIDE WITH
collision_mask = 0b00101  # Layers 1 (World) and 3 (Enemies)
```

### Common Layer Patterns

**Player should collide with world and enemies:**
```gdscript
# Player
collision_layer = 0b00010  # Layer 2
collision_mask = 0b00101   # Layers 1 (world) and 3 (enemies)
```

**Enemy projectile should hit player but not other enemies:**
```gdscript
# Enemy Projectile
collision_layer = 0b01000   # Layer 4
collision_mask = 0b00011    # Layers 1 (world) and 2 (player)
```

**Interaction raycast should only hit interactables:**
```gdscript
var query = PhysicsRayQueryParameters3D.create(from, to)
query.collision_mask = 0b10000  # Layer 5 (interactables) only
```

## Area3D vs RigidBody3D vs StaticBody3D vs CharacterBody3D

### When to Use Each

**StaticBody3D**
- Non-moving collision objects (walls, floors, obstacles)
- Cannot be moved by physics
- Very efficient

**CharacterBody3D**
- Player characters, NPCs with custom movement
- Controlled by code, not physics engine
- Has `move_and_slide()` for smooth movement
- Use for anything you want direct control over

**RigidBody3D**
- Objects controlled by physics (crates, barrels, ragdolls)
- Affected by gravity, forces, collisions
- Good for destructible/pushable objects

**Area3D**
- Trigger zones (doesn't block movement)
- Detection volumes (pickup radius, damage zones)
- Cannot collide physically, only detect overlaps

### Common Patterns

**Damage zone (Area3D):**
```gdscript
extends Area3D

signal body_damaged(body: Node3D, damage: float)

@export var damage_per_second: float = 10.0

func _ready():
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

var bodies_inside: Array[Node3D] = []

func _on_body_entered(body: Node3D):
    bodies_inside.append(body)

func _on_body_exited(body: Node3D):
    bodies_inside.erase(body)

func _process(delta: float):
    for body in bodies_inside:
        if body.has_method("take_damage"):
            body.take_damage(damage_per_second * delta)
            body_damaged.emit(body, damage_per_second * delta)
```

**Pickup detection (Area3D child of player):**
```gdscript
# As child of CharacterBody3D (player)
extends Area3D

func _ready():
    collision_layer = 0  # Not on any layer
    collision_mask = 0b10000  # Only detect interactables

    body_entered.connect(_on_pickup_entered)

func _on_pickup_entered(body: Node3D):
    if body.has_method("pickup"):
        body.pickup(get_parent())  # Pass player to pickup
```

## Performance Tips

1. **Use collision layers efficiently** - Don't check unnecessary layers
2. **Limit raycast distance** - Shorter rays are faster
3. **Cache space_state** - Don't call `get_world_3d().direct_space_state` every frame if possible
4. **Use Areas for detection** - More efficient than frequent raycasts
5. **Exclude irrelevant bodies** - Use `query.exclude` to skip known objects

## Common Gotchas

1. **Wrong class name**: It's `PhysicsRayQueryParameters3D`, not `PhysicsRayQuery3D`
2. **Forgetting collision mask**: Raycast won't hit anything if mask is 0
3. **Self-collision**: Always exclude `self` from queries
4. **Result dictionary**: Check `if result:` before accessing `result.collider`
5. **Global vs local positions**: Raycasts use global coordinates
6. **Basis direction**: `-transform.basis.z` is forward, not `transform.basis.z`

## Debugging Physics

```gdscript
# Visualize raycasts in editor
func _draw_debug_ray(from: Vector3, to: Vector3, hit: bool):
    var immediate = ImmediateMesh.new()
    var material = StandardMaterial3D.new()
    material.albedo_color = Color.RED if hit else Color.GREEN
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

    # Add debug line drawing here
    # (Use MeshInstance3D with ImmediateMesh for runtime visualization)

# Print collision layers
func debug_print_layers():
    print("collision_layer: ", collision_layer, " (binary: ", String.num_int64(collision_layer, 2), ")")
    print("collision_mask: ", collision_mask, " (binary: ", String.num_int64(collision_mask, 2), ")")
```

## Further Reading

- Official Godot 4 Physics Docs: https://docs.godotengine.org/en/stable/tutorials/physics/
- Understanding collision layers: https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#collision-layers-and-masks
