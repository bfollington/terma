# Bevy Project Structure Reference

## Standard Bevy Layout

```
src/
├── main.rs                 # App setup, plugin registration, system scheduling
├── components/
│   ├── mod.rs
│   ├── properties.rs      # Core data components
│   ├── effects.rs         # State marker components
│   ├── ui.rs             # UI marker components
│   └── [domain].rs       # Domain-specific components
├── systems/
│   ├── mod.rs
│   ├── [feature].rs      # Feature systems (one file per major feature)
│   └── ui/
│       ├── mod.rs
│       └── [ui_feature].rs
├── events.rs              # Game events and messages
└── resources.rs           # Global resources
```

## Key Principles

**1. Separation of Concerns**
- **Components** = Pure data, no logic
- **Systems** = Pure logic, operate on components
- **Events** = Communication between systems
- **Resources** = Global state (use sparingly)

**2. Module Organization**
```rust
// Good: Grouped by feature
src/systems/personality_physics.rs
src/systems/thresholds.rs
src/systems/spells.rs

// Bad: Grouped by system type
src/systems/update_systems.rs
src/systems/query_systems.rs
```

**3. Component Files**
Keep related components together:
```rust
// src/components/effects.rs
#[derive(Component)]
pub struct Burning { pub intensity: f32 }

#[derive(Component)]
pub struct Frozen;

#[derive(Component)]
pub struct Dissolving { pub progress: f32 }
```

## System Ordering

Systems run in the order they're added. Use comments to make dependencies clear:

```rust
.add_systems(
    Update,
    (
        // Input processing
        spell_input,

        // State changes (modifies data)
        process_spell_casts,

        // Derive properties from state
        derive_physics_from_personality,

        // Check for threshold crossings
        threshold_reactions,

        // Visual updates (reads state, updates rendering)
        visual_threshold_effects,
        update_temperature_visuals,

        // UI updates (must run last)
        update_inspect_display,
        update_hover_tooltip,
    ),
)
```

## Change Detection

Use `Changed<T>` to avoid unnecessary processing:

```rust
// ✅ GOOD: Only process when BigFive changes
pub fn threshold_reactions(
    mut query: Query<(Entity, &BigFive, &Name), Changed<BigFive>>,
    mut commands: Commands,
) {
    for (entity, traits, name) in query.iter() {
        if traits.extraversion > 0.6 {
            commands.entity(entity).insert(Burning {
                intensity: traits.extraversion,
            });
            println!("{} IGNITES!", name);
        }
    }
}

// ❌ BAD: Runs every frame for all entities
pub fn threshold_reactions(
    mut query: Query<(Entity, &BigFive, &Name)>,
    mut commands: Commands,
) {
    // Wasteful!
}
```
