# Common Bevy Pitfalls Reference

## 1. Forgetting to Register Systems

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
