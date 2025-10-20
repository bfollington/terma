# Bevy-Specific Development Tips

## Using Bevy Registry Examples

**The registry examples are your bible.** Bevy ships with extensive examples that demonstrate best practices and patterns.

**Location:**
```bash
~/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/bevy-0.17.1/examples
```

**When to consult registry examples:**
- Before implementing a new feature type
- When unsure about API usage
- To see working patterns for complex systems
- To understand how plugins should be structured
- For reference implementations of common game mechanics

**How to use them:**
1. Browse the examples directory for relevant use cases
2. Study the complete implementation (not just snippets)
3. Note how they structure components, systems, and plugins
4. Adapt patterns to your specific needs

There are MANY examples covering:
- 2D/3D rendering
- Animation
- Audio
- Input handling
- UI systems
- Physics
- Scenes and assets
- And much more

**Always refer to examples before diving into implementation.**

## Plugin Structure

Break your app into discrete modules using plugins whenever possible.

**Why use plugins:**
- Organizes code by feature/domain
- Makes systems reusable
- Improves code discoverability
- Enables modular development
- Follows Bevy best practices

**Plugin pattern:**
```rust
use bevy::prelude::*;

pub struct CombatPlugin;

impl Plugin for CombatPlugin {
    fn build(&self, app: &mut App) {
        app
            .add_event::<DamageEvent>()
            .add_systems(Startup, setup_combat)
            .add_systems(Update, (
                process_damage,
                check_death,
                update_health_bars,
            ));
    }
}

// In main.rs
fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_plugins(CombatPlugin)
        .add_plugins(MovementPlugin)
        .add_plugins(UIPlugin)
        .run();
}
```

**References:**
- Plugin guide: https://bevy.org/learn/quick-start/getting-started/plugins/
- System sets: https://bevy-cheatbook.github.io/programming/system-sets.html

## Build Performance and Optimization

### Dynamic Linking

**Always use dynamic linking during development:**
```bash
cargo build --features bevy/dynamic_linking
```

**Why:**
- 2-3x faster compile times
- Critical for iteration speed
- Only affects development builds

**Setup in `.cargo/config.toml`:**
```toml
[target.x86_64-unknown-linux-gnu]
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=lld"]

[target.x86_64-apple-darwin]
rustflags = ["-C", "link-arg=-fuse-ld=/usr/local/opt/llvm/bin/ld64.lld"]
```

**Optimization levels** - See: https://bevy.org/learn/quick-start/getting-started/setup/

For faster dev builds, add to `Cargo.toml`:
```toml
[profile.dev]
opt-level = 1

[profile.dev.package."*"]
opt-level = 3
```

### Build Management

**CRITICAL: Do not delete target binaries freely!**

Bevy takes **minutes** to rebuild from scratch. Be mindful of:

1. **Target directory management:**
   - Avoid `cargo clean` unless absolutely necessary
   - Incremental builds are your friend
   - Each clean rebuild costs valuable development time

2. **Version and dependency management:**
   - Bevy is under active development
   - Be mindful of the version you are using
   - Dependencies can get tangled easily
   - Version mismatches can force complete rebuilds
   - Stick to one Bevy version per project when possible

3. **Crate dependencies:**
   - Adding/removing dependencies triggers rebuilds
   - Changing feature flags triggers rebuilds
   - Plan dependency changes carefully
   - Batch dependency updates when possible

**Best practices:**
- Use `cargo check` for quick validation (no binary)
- Use `cargo build --features bevy/dynamic_linking` for testing
- Only use `cargo clean` when dealing with corrupted build artifacts
- Keep a stable `Cargo.lock` for consistent builds

## Domain-Driven Design for ECS

**Pure ECS structure demands careful data modeling.**

### Think Before You Code

Because it's hard to search a massive list of systems in one file, you must:

1. **Design the data model first:**
   - What entities exist in your domain?
   - What components do they need?
   - What behaviors (systems) operate on them?
   - How do components relate?

2. **Refer to docs and existing code:**
   - Check Bevy examples for similar patterns
   - Review the official docs for component design
   - Look at existing project code for consistency
   - Understand the domain before implementing

3. **Use bounded contexts:**
   - Group related components together
   - Create plugins per domain area
   - Keep systems focused on single responsibilities
   - Avoid cross-domain coupling

### Example Domain Modeling Process

**Bad approach:**
```
❌ Start coding immediately
❌ Add systems to one giant file
❌ Discover missing components mid-implementation
❌ Hard to navigate, hard to maintain
```

**Good approach:**
```
✅ Define the domain (e.g., "Combat System")
✅ List entities (Player, Enemy, Projectile)
✅ List components (Health, Damage, Armor)
✅ List events (DamageEvent, DeathEvent)
✅ List systems (process_damage, check_death, spawn_projectile)
✅ Check examples for similar implementations
✅ Create CombatPlugin
✅ Implement incrementally
✅ Test at each step
```

### File Organization for Discoverability

```
src/
├── main.rs                      # App setup only
├── plugins/
│   ├── mod.rs
│   ├── combat.rs                # CombatPlugin
│   ├── movement.rs              # MovementPlugin
│   └── inventory.rs             # InventoryPlugin
├── components/
│   ├── mod.rs
│   ├── combat.rs                # Health, Armor, Damage
│   ├── movement.rs              # Velocity, Speed
│   └── inventory.rs             # Inventory, Item
└── events.rs                    # All game events
```

**Benefits:**
- Easy to find related code
- Clear domain boundaries
- Plugin-based modularity
- Searchable by feature/domain

## Version Management

**Bevy is under active development.**

1. **Check your Bevy version:**
   ```bash
   cargo tree | grep bevy
   ```

2. **Stay on one version per project:**
   - Avoid mixing Bevy versions
   - Update all Bevy crates together
   - Test thoroughly after version updates

3. **API changes between versions:**
   - Read the migration guide when updating
   - Bevy's API evolves rapidly
   - Code from older versions may not work
   - Examples are version-specific

4. **When seeking help:**
   - Always mention your Bevy version
   - Check if examples match your version
   - Look for version-specific documentation

## Summary Checklist

**Before implementing:**
- [ ] Check registry examples for similar features
- [ ] Design the data model (entities, components, events, systems)
- [ ] Create a plugin for the feature domain
- [ ] Review existing code for patterns

**During development:**
- [ ] Use `cargo build --features bevy/dynamic_linking`
- [ ] Avoid `cargo clean` unless necessary
- [ ] Test incrementally
- [ ] Keep systems focused and organized

**After implementation:**
- [ ] Verify the feature works
- [ ] Check for code organization issues
- [ ] Document domain-specific patterns
- [ ] Update plugin structure if needed
