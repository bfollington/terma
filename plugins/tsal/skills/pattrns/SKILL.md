---
name: pattrns
description: Guide for creating generative, emergent music with Pattrns, the Lua-based pattern sequencing engine for Renoise. Use when composing algorithmic patterns, generating evolving breakbeats/rhythms, creating generative melodies/harmonies, designing textures, or working with euclidean rhythms and live coding patterns. Covers breakbeat/jungle/DnB, IDM/experimental, jazz, industrial/trip-hop, and ambient styles.
---

# Pattrns - Generative Music Creation

## Overview

Pattrns is a Lua-based pattern generation engine for Renoise that enables algorithmic, generative music creation. Use this skill when working with Pattrns to create emergent, evolving musical patterns across genres including breakbeat/jungle, IDM, jazz, industrial/trip-hop, and ambient music.

**Core Architecture:** Pattrns separates rhythm from melody through a **Pulse → Gate → Event** pipeline:
- **Pulse**: Defines when events occur (rhythm)
- **Gate**: Optional filter for pulse values (probability, complexity)
- **Event**: Generates notes, chords, or sequences (melody/harmony)

This separation enables powerful generative techniques where rhythms and melodies can evolve independently and be recombined in creative ways.

## When to Use This Skill

Invoke this skill when:
- Creating generative or algorithmic patterns in Renoise
- Working with euclidean rhythms or polyrhythms
- Designing evolving, emergent musical structures
- Generating breakbeats, complex drum patterns, or rhythmic variations
- Creating generative melodies, harmonies, or chord progressions
- Building textural, ambient, or atmospheric patterns
- Using Tidal Cycles mini-notation for pattern creation
- Developing patterns that resample and resequence for iterative composition

## Quick Start

### Basic Pattern Structure

Every Pattrns pattern follows this structure:

```lua
return pattern {
  unit = "1/16",              -- Time grid (1/16, 1/8, 1/4, bars, etc.)
  resolution = 1,             -- Multiplier (2/3 for triplets)
  offset = 0,                 -- Delay pattern start
  repeats = true,             -- Loop pattern
  pulse = {1, 0, 1, 1},      -- Static rhythm array
  event = {"c4", "e4", "g4"} -- Static note sequence
}
```

### Essential Techniques at a Glance

**Euclidean Rhythms** (most common starting point):
```lua
pulse = pulse.euclidean(7, 16)  -- 7 hits distributed in 16 steps
```

**Scale-Based Melodies**:
```lua
local s = scale("c4", "minor")
event = s.notes  -- Use scale notes as sequence
```

**Random Generation with Control**:
```lua
event = function(context)
  local notes = scale("c4", "pentatonic minor").notes
  return notes[math.random(#notes)]
end
```

**Tidal Cycles Mini-Notation**:
```lua
return cycle("kd ~ sn ~, [hh hh]*4"):map({
  kd = "c4 #1",  -- Kick drum
  sn = "c4 #2",  -- Snare
  hh = "c4 #3 v0.5"  -- Hi-hat, quieter
})
```

## Core Workflow

### 1. Choose Musical Goal

Identify what to create:
- **Rhythmic**: Drum pattern, breakbeat, groove
- **Melodic**: Bassline, lead, arpeggio
- **Harmonic**: Chord progression, pad, texture
- **Textural**: Atmosphere, drone, evolving soundscape

### 2. Design Rhythm (Pulse)

Start with rhythmic foundation:

**Static Arrays:**
```lua
pulse = {1, 0, 1, 1, 0, 1, 0, 0}  -- Hand-crafted rhythm
```

**Euclidean Distribution:**
```lua
pulse = pulse.euclidean(5, 8)     -- Algorithmic rhythm
```

**Dynamic/Generative:**
```lua
pulse = function(context)
  return math.random() > 0.5      -- Probabilistic rhythm
end
```

**Subdivisions (Cramming):**
```lua
pulse = {1, {1, 1, 1}, 1, 0}      -- Quarter + triplet + quarter + rest
```

### 3. Design Note Generation (Event)

Create melodic/harmonic content:

**Static Sequence:**
```lua
event = {"c4", "e4", "g4", "b4"}
```

**Scale-Based:**
```lua
local s = scale("c4", "minor")
event = function(context)
  return s.notes[math.imod(context.step, #s.notes)]
end
```

**Chord Progressions:**
```lua
local s = scale("c4", "minor")
event = sequence(
  s:chord("i"),   -- Tonic
  s:chord("iv"),  -- Subdominant
  s:chord("v")    -- Dominant
)
```

**Generative/Evolving:**
```lua
event = function(init_context)
  local state = initial_value
  return function(context)
    -- Update and use state to create evolution
    state = state + delta
    return generate_from(state)
  end
end
```

### 4. Add Variation (Optional Gate)

Filter or modify pulse triggers:

```lua
gate = function(context)
  -- Higher probability on downbeats
  local is_downbeat = (context.pulse_step - 1) % 4 == 0
  local probability = is_downbeat and 0.9 or 0.3
  return math.random() < probability
end
```

### 5. Add Control (Parameters)

Enable live tweaking without code changes:

```lua
parameter = {
  parameter.integer("variation", 1, {1, 4}),
  parameter.number("density", 0.5, {0.0, 1.0}),
}

-- Access in functions
event = function(context)
  local var = context.parameter.variation
  -- Use var to select different patterns
end
```

### 6. Iterate & Evolve

**Workflow for Emergent Music:**
1. Generate pattern → Test in Renoise
2. Render/bounce to audio
3. Resample and chop
4. Create new patterns using resampled material
5. Layer and arrange into parts
6. Repeat process for continuous evolution

## Common Musical Tasks

### Creating Breakbeats

Load `references/genre_recipes.md` and search for "Breakbeat" for complete examples.

**Quick pattern:**
```lua
-- Euclidean-based break
local kick = pulse.euclidean(4, 16)
local snare = pulse.euclidean(3, 16, 2)
local hats = pulse.from{1,0,1,0}:repeat_n(4)

-- Use cycle notation to combine
return cycle("[kd*16], [sn*16], [hh*16]"):map({
  kd = function(ctx) return kick[math.imod(ctx.step,16)] and "c4 #1" end,
  sn = function(ctx) return snare[math.imod(ctx.step,16)] and "c4 #2" end,
  hh = function(ctx) return hats[math.imod(ctx.step,16)] and "c4 #3" end
})
```

### Generative Melodies

Load `references/core_techniques.md` and search for "Constrained Random Walk" or "Scale-Based Generation".

**Quick pattern:**
```lua
return pattern {
  unit = "1/16",
  pulse = pulse.euclidean(7, 16),  -- Rhythmic interest
  event = function(init_context)
    local notes = scale("c4", "pentatonic minor").notes
    local last_idx = 1
    return function(context)
      -- Prefer small intervals (smoother melody)
      local next_idx = last_idx
      while math.abs(next_idx - last_idx) > 2 do
        next_idx = math.random(#notes)
      end
      last_idx = next_idx
      return notes[next_idx]
    end
  end
}
```

### Chord Progressions

Load `references/core_techniques.md` and search for "Chord Progressions".

**Quick pattern:**
```lua
local s = scale("c4", "minor")
return pattern {
  unit = "1/4",  -- Whole notes
  pulse = {1, 1, 1, 1},
  event = sequence(
    s:chord("i", 3),   -- i minor
    s:chord("iv", 3),  -- iv minor
    s:chord("v", 3),   -- v minor
    s:chord("i", 3)    -- i minor
  )
}
```

### Evolving Textures

Load `references/genre_recipes.md` and search for "Ambient" or "Textural".

**Quick pattern:**
```lua
return pattern {
  unit = "1/16",
  pulse = function(context)
    return math.random() > 0.85  -- Sparse
  end,
  event = function(context)
    local notes = scale("c4", "phrygian").notes
    return note(notes[math.random(#notes)])
      :volume(0.2 + math.random() * 0.3)
      :delay(math.random() * 0.5)
      :panning(math.random() * 2 - 1)
  end
}
```

### Polyrhythms

Load `references/core_techniques.md` and search for "Polyrhythms".

**Quick pattern:**
```lua
-- 3:4:5 polyrhythm
cycle("[c4*3]/4, [e4*4]/4, [g4*5]/4")
```

## Key Techniques Reference

For detailed explanations and complete code examples, load these reference files:

### Core Techniques (`references/core_techniques.md`)
Load when working with:
- Euclidean rhythms and pulse operations
- Randomization and controlled chaos
- Scale-based generation
- Pattern evolution and stateful generators
- Polyrhythms and unusual time signatures
- Note transformations
- Tidal Cycles mini-notation
- Texture generation

Search patterns:
- `grep -i "euclidean" references/core_techniques.md`
- `grep -i "random" references/core_techniques.md`
- `grep -i "scale" references/core_techniques.md`

### Genre-Specific Recipes (`references/genre_recipes.md`)
Load when creating:
- **Breakbeat/Jungle/DnB**: Complex breaks, swing, reese bass
- **IDM/Experimental**: Glitchy effects, algorithmic complexity
- **Jazz**: Swing, walking bass, chord substitutions
- **Industrial/Trip-Hop**: Heavy grooves, dark textures
- **Ambient**: Slow evolution, drones, sparse atmospheres

Search patterns:
- `grep -i "breakbeat\|jungle\|dnb" references/genre_recipes.md`
- `grep -i "idm\|experimental\|glitch" references/genre_recipes.md`
- `grep -i "jazz\|swing\|walking" references/genre_recipes.md`

### API Quick Reference (`references/api_quick_reference.md`)
Load when needing:
- Function signatures and parameters
- Available scale modes
- Context object properties
- Utility functions
- Common code patterns
- Workflow tips and gotchas

## Pattern Templates

The `assets/` directory contains starter templates for common patterns:
- `euclidean_drum.lua`: Euclidean-based drum pattern
- `generative_melody.lua`: Scale-based melody with constraints
- `evolving_chord.lua`: Slowly evolving chord progression
- `texture_cloud.lua`: Sparse atmospheric texture

Copy and modify these as starting points.

## Best Practices

### Start Simple, Add Complexity
1. Begin with static pulse and static event
2. Make one dynamic (usually event first)
3. Add gate for probability/filtering
4. Add parameters for control
5. Layer multiple patterns

### Controlled Randomness
Use seeded random for reproducibility:
```lua
event = function(init_context)
  local rand = math.randomstate(12345)  -- Consistent seed
  return function(context)
    return generate_with(rand)
  end
end
```

### State Management
- **Global state**: Shared across all triggers (use sparingly)
- **Local state** (in generators): Per-trigger isolation (preferred)
- Use init function + inner function pattern for local state

### Performance Optimization
- Cache expensive calculations in init functions
- Use local variables
- Avoid creating tables in inner loops
- Return `nil` for rests, not 0 or false

### Tracker Context for Programmers
- Lua uses 1-based indexing: `array[1]` is first element
- Use `math.imod(step, #array)` for array wrapping
- Patterns run in musical time (beats/bars), not CPU time
- BPM and time signature from Renoise project settings

## Troubleshooting

**Pattern not triggering:**
- Check `unit` is appropriate for tempo
- Verify `pulse` returns non-zero values
- Check `gate` (if present) isn't filtering all events

**Notes out of key:**
- Use `scale()` to constrain note generation
- Check root note and mode are correct

**Pattern too predictable:**
- Add randomization with `math.random()`
- Use euclidean rhythms with different parameters
- Implement constrained random walk for melodies

**Pattern too chaotic:**
- Use seeded random for consistency
- Add constraints to random generation
- Use scale-based generation for harmonic coherence
- Lower probability in gates

**Lua errors:**
- Check 1-based indexing
- Verify init function returns inner function for generators
- Use `math.imod` for array wrapping, not `%`

## Generative Workflow Summary

The power of Pattrns for emergent music:

```
IDEA → ALGORITHM → PATTERN → EVENTS → AUDIO → RESAMPLE → NEW PATTERN
```

1. **Generate**: Create algorithmic patterns with controlled randomness
2. **Evolve**: Use stateful generators to create evolving material
3. **Render**: Bounce patterns to audio in Renoise
4. **Resample**: Chop and manipulate rendered audio
5. **Resequence**: Create new patterns using resampled material
6. **Iterate**: Repeat for continuous evolution and emergence

This workflow enables creating "parts" that can be assembled into songs in Renoise or exported to traditional DAWs, with each iteration adding new layers of complexity and emergence.

## Resources

### references/
Detailed technical documentation and genre-specific recipes. Load as needed:
- `core_techniques.md`: In-depth technique explanations and code patterns
- `genre_recipes.md`: Complete examples for different musical styles
- `api_quick_reference.md`: Function signatures and API reference

### assets/
Pattern templates ready to copy and modify:
- Starter templates for common musical tasks
- Genre-specific boilerplate patterns
