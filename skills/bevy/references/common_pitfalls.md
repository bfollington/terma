# Common Bevy Pitfalls Reference

## 1. Using Old Event System in Bevy 0.17

**❌ Problem:**
```rust
// Bevy 0.15/0.16 event system doesn't work in 0.17
#[derive(Event)]
struct MyEvent { data: String }

app.add_event::<MyEvent>()
   .add_systems(Update, handle_event);

fn handle_event(mut events: EventReader<MyEvent>) { /* ... */ }
fn trigger(mut events: EventWriter<MyEvent>) { /* ... */ }
```

**Symptoms:**
- Compilation error: `MyEvent is not a Message`
- `method 'send' not found for MessageWriter`
- `method 'read' not found for MessageReader`

**✅ Solution:**
Migrate to the observer pattern:
```rust
// Bevy 0.17 observer pattern
#[derive(Event, Clone)]  // Must derive Clone!
struct MyEvent { data: String }

app.add_observer(handle_event);  // Use observer, not system

fn handle_event(
    trigger: Trigger<MyEvent>,  // Trigger parameter
    // ... other params
) {
    let event = trigger.event();
}

fn trigger_event(mut commands: Commands) {
    commands.trigger(MyEvent { data: "test".into() });
}
```

See `references/bevy_specific_tips.md` for complete migration guide.

## 2. Querying Material Handles in Bevy 0.17

**❌ Problem:**
```rust
// Bevy 0.15/0.16 pattern doesn't work in 0.17
Query<&Handle<StandardMaterial>>
```

**Symptoms:**
- `Handle<StandardMaterial> is not a Component`
- Query trait bounds not satisfied

**✅ Solution:**
Use the `MeshMaterial3d` wrapper:
```rust
Query<&MeshMaterial3d<StandardMaterial>>

// Access handle with .0
for material_3d in query.iter() {
    if let Some(material) = materials.get_mut(&material_3d.0) {
        material.emissive = color;
    }
}
```

## 3. Forgetting to Register Systems

**❌ Problem:**
```rust
// Created system but forgot to add to app
pub fn my_new_system() { /* ... */ }
```

**✅ Solution:**
Always add to `main.rs`:
```rust
.add_systems(Update, my_new_system)
```

## 2. Borrowing Conflicts

**❌ Problem:**
```rust
// Can't have multiple mutable borrows
mut query1: Query<&mut Transform>,
mut query2: Query<&mut Transform>,  // Error!
```

**✅ Solution:**
```rust
// Use get_many_mut for specific entities
mut query: Query<&mut Transform>,

if let Ok([mut a, mut b]) = query.get_many_mut([entity_a, entity_b]) {
    // Can mutate both
}
```

## 3. Infinite Loops with Events

**❌ Problem:**
```rust
// System reads and writes same event type
fn system(
    mut events: EventWriter<MyEvent>,
    reader: EventReader<MyEvent>,
) {
    for event in reader.read() {
        events.send(MyEvent);  // Infinite loop!
    }
}
```

**✅ Solution:**
Use different event types or add termination condition.

## 4. Not Using Changed<T>

**❌ Problem:**
```rust
// Runs every frame for every entity
fn system(query: Query<&BigFive>) {
    for traits in query.iter() {
        // Expensive calculation every frame
    }
}
```

**✅ Solution:**
```rust
// Only runs when BigFive changes
fn system(query: Query<&BigFive, Changed<BigFive>>) {
    for traits in query.iter() {
        // Only when needed
    }
}
```

## 5. Entity Queries After Despawn

**❌ Problem:**
```rust
commands.entity(entity).despawn();
// Later in same system
let component = query.get(entity).unwrap();  // Crash!
```

**✅ Solution:**
Commands apply at end of stage. Use `Ok()` pattern:
```rust
if let Ok(component) = query.get(entity) {
    // Safe
}
```

## 6. Material/Asset Handle Confusion

**❌ Problem:**
```rust
// Created material but didn't store handle
materials.add(StandardMaterial { .. });  // Handle dropped!
```

**✅ Solution:**
```rust
let material_handle = materials.add(StandardMaterial { .. });
commands.spawn((
    MeshMaterial3d(material_handle),
    // ...
));
```

## 7. System Ordering Issues

**❌ Problem:**
```rust
// UI updates before state changes
.add_systems(Update, (
    update_ui,
    process_input,  // Wrong order!
))
```

**✅ Solution:**
Order systems by dependencies:
```rust
.add_systems(Update, (
    // Input processing
    process_input,

    // State changes
    update_state,

    // UI updates (reads state)
    update_ui,
))
```

## 8. Not Filtering Queries Early

**❌ Problem:**
```rust
// Filter in loop (inefficient)
Query<(&A, Option<&B>, Option<&C>)>
// Then check in loop
```

**✅ Solution:**
```rust
// Filter in query (efficient)
Query<&A, (With<B>, Without<C>)>
```
