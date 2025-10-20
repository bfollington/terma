# Godot File Formats Reference

This reference provides detailed syntax information for Godot's text-based file formats.

## GDScript Files (.gd)

Standard Python-like script files. Full GDScript syntax is supported.

### Basic Structure

```gdscript
extends BaseClass
class_name MyClass

signal my_signal(param: Type)

@export var speed: float = 5.0
@export_group("Combat")
@export var damage: int = 10

var _internal_var: String = ""

func _ready() -> void:
    print("Ready")

func my_function(param: int) -> bool:
    return param > 0
```

### Key Features
- Full object-oriented programming
- Type hints (optional but recommended)
- Signals for event-driven communication
- Export variables for Inspector editing
- Inheritance with `extends`
- Class naming with `class_name`

## Scene Files (.tscn)

Text serialization of scene node hierarchies. **STRICT FORMATTING REQUIRED**.

### File Structure

```
[gd_scene load_steps=N format=3 uid="uid://..."]

[ext_resource type="Type" path="res://path" id="1_name"]
[ext_resource type="Type" path="res://path" id="2_other"]

[sub_resource type="SomeType" id="SubResource_1"]
property = value

[node name="Root" type="NodeType"]
script = ExtResource("1_name")
property = value

[node name="Child" type="ChildType" parent="."]
property = value

[node name="Grandchild" type="Node" parent="Child"]
another_property = 123
```

### Critical Rules

#### 1. Header Format
```
[gd_scene load_steps=3 format=3 uid="uid://unique_identifier"]
```
- `load_steps`: Number of resources to load (ExtResource + SubResource count)
- `format`: Always 3 for Godot 4.x
- `uid`: Unique identifier (DO NOT change - breaks references)

#### 2. ExtResource Declarations
```
[ext_resource type="Script" path="res://src/my_script.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/other.tscn" id="2_scene"]
```
- Must be declared before use
- `id` format: `number_descriptive_name`
- Common types: `Script`, `PackedScene`, `Texture2D`, `Material`

#### 3. ExtResource References
```
script = ExtResource("1_script")
texture = ExtResource("3_texture")
```
- **NEVER use `preload()`** - that's GDScript syntax
- **ALWAYS use `ExtResource("id")`**

#### 4. SubResource Declarations
```
[sub_resource type="BoxShape3D" id="SubResource_collision"]
size = Vector3(1, 2, 1)
```
- For resources defined inline within the scene
- Referenced with `SubResource("id")`

#### 5. Node Hierarchy
```
[node name="Player" type="CharacterBody3D"]
script = ExtResource("1_player")

[node name="CollisionShape" type="CollisionShape3D" parent="."]
shape = SubResource("SubResource_collision")

[node name="Model" type="MeshInstance3D" parent="."]
mesh = ExtResource("2_mesh")

[node name="Texture" type="Sprite2D" parent="Model"]
texture = ExtResource("3_texture")
```
- Root node: no parent
- Direct children: `parent="."`
- Nested children: `parent="ParentNodeName"`
- Deep nesting: `parent="Parent/Child"`

#### 6. Scene Instancing
```
[node name="Enemy" type="Node3D"]

[node name="BaseEnemy" parent="." instance=ExtResource("5_enemy_scene")]

[node name="SomeChild" parent="BaseEnemy" index="2"]
property = "modified value"
```
- `instance=ExtResource()`: Instantiate another scene
- `index="N"`: Modify instanced scene's child (see Instance Property Overrides below)

### Instance Property Overrides

**CRITICAL CONCEPT**: When you instance a scene in a .tscn file, the instance starts with ALL default property values from the source scene. To customize an instance, you MUST explicitly override properties using special syntax.

#### The Problem

```
# item_pickup.tscn (source scene)
[node name="ItemPickup" type="StaticBody3D"]

[node name="PickupInteraction" type="Node" parent="."]
script = ExtResource("1_pickup")
item_resource = null  # Default value
quantity = 1
```

If you instance this scene WITHOUT overriding properties:

```
# level.tscn
[node name="KeyPickup" parent="." instance=ExtResource("6_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 3)
```

The `item_resource` will be `null` - the instance uses the default! This is a common source of bugs.

#### The Solution: Property Overrides

To customize an instanced scene's child nodes, use the `index` parameter:

```
# level.tscn
[ext_resource type="PackedScene" path="res://scenes/item_pickup.tscn" id="6_pickup"]
[ext_resource type="Resource" path="res://resources/test_key.tres" id="7_key"]

[node name="KeyPickup" parent="." instance=ExtResource("6_pickup")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 3)

[node name="PickupInteraction" parent="KeyPickup" index="0"]
item_resource = ExtResource("7_key")
quantity = 1
```

**Key points:**
- `parent="KeyPickup"` - References the instanced scene node
- `index="0"` - Indicates this is modifying the first child (0-indexed)
- Property assignments override the defaults

#### Finding the Correct Index

The `index` parameter corresponds to the child's position in the parent's child list (0-indexed). To find it:

1. **Open the source scene** in the Godot editor
2. **Look at the Scene tree** - the order of children determines the index
3. **Count from 0** - first child is `index="0"`, second is `index="1"`, etc.

Or examine the source .tscn file to see the node order.

#### Multiple Property Overrides

You can override multiple children of an instance:

```
[node name="Door" parent="." instance=ExtResource("5_door")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2, 0, 0)

[node name="DoorInteraction" parent="Door" index="0"]
required_key = "gold_key"
interaction_text = "Unlock Gold Door"

[node name="MeshInstance3D" parent="Door" index="1"]
material_override = ExtResource("8_gold_material")
```

#### Common Patterns

**Configuring pickup items:**
```
[node name="HealthPotion" parent="." instance=ExtResource("6_pickup")]

[node name="PickupInteraction" parent="HealthPotion" index="0"]
item_resource = ExtResource("7_health_potion")
quantity = 3
```

**Configuring doors:**
```
[node name="LockedDoor" parent="." instance=ExtResource("5_door")]

[node name="DoorInteraction" parent="LockedDoor" index="0"]
starts_locked = true
required_key = "dungeon_key"
```

**Configuring enemy spawns:**
```
[node name="BossSlime" parent="." instance=ExtResource("8_slime")]

[node name="Slime" parent="BossSlime" index="0"]
max_health = 200.0
move_speed = 3.0
```

#### When NOT to Use Index

Don't use `index` for properties on the root node of the instance - those can be set directly:

```
# ✅ CORRECT - Root node properties set directly
[node name="Slime" parent="." instance=ExtResource("8_slime")]
max_health = 50.0
move_speed = 2.0

# ❌ WRONG - Don't use index for root properties
[node name="Slime" parent="." instance=ExtResource("8_slime")]

[node name="Slime" parent="Slime" index="0"]  # This is confusing and wrong!
max_health = 50.0
```

### Safe vs Risky Edits

#### ✅ SAFE Edits
```
# Add new ExtResource declaration
[ext_resource type="Script" path="res://new.gd" id="10_new"]

# Modify simple property values
[node name="Player"]
move_speed = 6.0

# Add new top-level node
[node name="NewNode" type="Node" parent="."]
script = ExtResource("10_new")

# Add new child to existing node
[node name="Component" type="Node" parent="Player"]
```

#### ⚠️ RISKY Edits
```
# Modifying instanced scene children (can break on editor re-save)
[node name="Mesh" parent="Enemy/Model" index="3"]

# Complex node restructuring
# Moving nodes between parents
```

#### ❌ DANGEROUS - Never Do
```
# Changing UIDs (breaks all references)
uid="uid://different_id"

# Deleting ExtResource declarations still in use
# Restructuring instanced scenes heavily
```

## Resource Files (.tres)

Serialized resource data. **NO GDSCRIPT SYNTAX ALLOWED**.

### File Structure

```
[gd_resource type="Resource" script_class="ClassName" load_steps=N format=3 uid="uid://..."]

[ext_resource type="Script" path="res://path/to/script.gd" id="1_script"]

[sub_resource type="Resource" id="SubRes_1"]
script = ExtResource("1_script")
property = value

[resource]
script = ExtResource("1_script")
property1 = "value"
property2 = 42
nested_resource = SubResource("SubRes_1")
```

### Critical Rules

#### 1. NO GDScript Syntax
```
# ❌ WRONG - GDScript syntax not allowed
script = preload("res://script.gd")
var my_value = 10
const SPEED = 5.0
func do_something():
    pass

# ✅ CORRECT - Resource syntax only
script = ExtResource("1_script")
my_value = 10
speed = 5.0
```

#### 2. ExtResource for External References
```
# ❌ WRONG
[resource]
script = preload("res://spell_effect.gd")

# ✅ CORRECT
[ext_resource type="Script" path="res://spell_effect.gd" id="1_effect"]

[resource]
script = ExtResource("1_effect")
```

#### 3. SubResource for Nested Resources
```
# Declare SubResource first
[sub_resource type="Resource" id="Effect_1"]
script = ExtResource("1_effect_script")
magnitude = 10.0

# Use in main resource
[resource]
script = ExtResource("1_main_script")
effect = SubResource("Effect_1")
```

#### 4. Typed Arrays
```
# ❌ WRONG - Untyped array
effects = [SubResource("Effect_1"), SubResource("Effect_2")]

# ✅ CORRECT - Must specify type
effects = Array[Resource]([SubResource("Effect_1"), SubResource("Effect_2")])

# ✅ ALSO CORRECT - Using ExtResource for type
[ext_resource type="Script" path="res://effect.gd" id="2_effect"]
effects = Array[ExtResource("2_effect")]([SubResource("Effect_1")])
```

#### 5. Common Data Types
```
# Primitives
my_int = 42
my_float = 3.14
my_bool = true
my_string = "text"

# Vectors
position = Vector2(10, 20)
position3d = Vector3(1, 2, 3)

# Colors
color = Color(1, 0, 0, 1)  # RGBA
color_hex = Color("#ff0000")

# Arrays
numbers = Array[int]([1, 2, 3])
strings = Array[String](["a", "b", "c"])

# Resources
script = ExtResource("1_script")
nested = SubResource("SubRes_1")
```

### Complete Example

```tres
[gd_resource type="Resource" script_class="SpellResource" load_steps=4 format=3 uid="uid://abc123"]

[ext_resource type="Script" path="res://src/spells/spell_resource.gd" id="1_spell"]
[ext_resource type="Script" path="res://src/spells/spell_effect.gd" id="2_effect"]

[sub_resource type="Resource" id="Effect_damage"]
script = ExtResource("2_effect")
effect_type = 0
magnitude_min = 15.0
magnitude_max = 25.0
duration = 0.0

[sub_resource type="Resource" id="Effect_slow"]
script = ExtResource("2_effect")
effect_type = 12
magnitude_min = 50.0
magnitude_max = 50.0
duration = 3.0

[resource]
script = ExtResource("1_spell")
spell_name = "Ice Bolt"
spell_id = "ice_bolt"
mana_cost = 20.0
spell_color = Color(0.5, 0.7, 1, 1)
projectile_speed = 15.0
effects = Array[ExtResource("2_effect")]([SubResource("Effect_damage"), SubResource("Effect_slow")])
```

## Common Mistakes Reference

### 1. preload() in .tres/.tscn
```
# ❌ WRONG
script = preload("res://script.gd")

# ✅ CORRECT
[ext_resource type="Script" path="res://script.gd" id="1"]
script = ExtResource("1")
```

### 2. GDScript Keywords in .tres
```
# ❌ WRONG
var speed = 5.0
const MAX_HEALTH = 100

# ✅ CORRECT
speed = 5.0
max_health = 100
```

### 3. Untyped Arrays in .tres
```
# ❌ WRONG
items = [SubResource("Item1"), SubResource("Item2")]

# ✅ CORRECT
items = Array[Resource]([SubResource("Item1"), SubResource("Item2")])
```

### 4. Missing ExtResource Declarations
```
# ❌ WRONG - Using without declaring
[node name="Player"]
script = ExtResource("1_player")  # Not declared!

# ✅ CORRECT - Declare first
[ext_resource type="Script" path="res://player.gd" id="1_player"]

[node name="Player"]
script = ExtResource("1_player")
```

### 5. Invalid Parent References
```
# ❌ WRONG - Parent doesn't exist
[node name="Child" parent="NonExistentNode"]

# ✅ CORRECT - Use valid parent
[node name="Parent" type="Node"]

[node name="Child" parent="Parent"]
```

### 6. Forgetting Instance Property Overrides
```
# ❌ WRONG - Instance uses default (null) values
[node name="KeyPickup" parent="." instance=ExtResource("6_pickup")]
# item_resource will be null! Pickup won't work!

# ✅ CORRECT - Override the property
[node name="KeyPickup" parent="." instance=ExtResource("6_pickup")]

[node name="PickupInteraction" parent="KeyPickup" index="0"]
item_resource = ExtResource("7_key")
```

**This is a very common bug!** Instanced scenes start with default values. If a scene has configurable components (like PickupInteraction with item_resource, or DoorInteraction with required_key), you MUST override those properties in the instance. See "Instance Property Overrides" section for details.
