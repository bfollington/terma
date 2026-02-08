# Pattrns Core Techniques Reference

## Architecture Overview

### Three-Stage Pipeline: Pulse → Gate → Event

Pattrns separates rhythm from melody through a three-stage architecture:

**Pulse (Rhythm Generator)**
- Defines when events occur
- Can be static arrays: `{1, 0, 1, 1}` or dynamic functions
- Supports subdivisions (cramming): `{1, {1, 1, 1}}` = quarter note then triplet
- Pulse values: 0/1 (binary) or 0.0-1.0 (weighted/probabilistic)
- Default: continuous pulse of 1's

**Gate (Pulse Filter)**
- Optional filter between pulse and event
- Default: threshold gate (passes values > 0)
- Use for probability-based triggering, complex filtering, dynamic pattern morphing
- Accesses `context.pulse_value` to make decisions

**Event (Note Generator)**
- Produces actual musical output (notes, chords)
- Can be static sequences, static chords, dynamic functions, or Tidal Cycles mini-notation

### Basic Pattern Structure

```lua
return pattern {
  unit = "1/16",              -- Time grid
  resolution = 1,             -- Multiplier (e.g., 2/3 for triplets)
  offset = 0,                 -- Delay start
  repeats = true,             -- Loop forever
  pulse = {1, 0, 1, 1},      -- Rhythm
  gate = function(ctx) ... end,  -- Optional filter
  event = {"c4", "e4", "g4"}    -- Notes
}
```

## Euclidean Rhythms

The core algorithmic rhythm tool. Distributes N hits evenly across K steps.

```lua
pulse.euclidean(3, 8)  -- {1,0,0,1,0,0,1,0} (tresillo)
pulse.euclidean(5, 8)  -- {1,0,1,0,1,0,1,1} (cinquillo)
pulse.euclidean(7, 16, 2)  -- 7 hits in 16 steps, rotate by 2
```

**Musical Applications:**
- (3,8): African tresillo rhythm
- (5,8): Cuban cinquillo
- (7,16): Complex polyrhythm for breakbeat variation
- Combine multiple: `pulse.euclidean(3,8) + pulse.euclidean(5,8)` (Schillinger technique)

**Euclidean with Notes:**
```lua
local s = scale("c3", "minor")
local notes =
  pulse.from(s:chord("i", 3)):euclidean(8) +
  pulse.from(s:chord("vi", 3)):euclidean(8, 1):reverse() +
  pulse.from(s:chord("v", 3)):euclidean(8)
```

## Pulse Operations

**Transformations:**
- `reverse()`: Invert order
- `rotate(n)`: Shift left/right
- `repeat_n(n)`: Duplicate pattern
- `spread(factor)`: Expand/compress timing
- `take(n)`: First n elements
- `map(fn)`: Transform each element
- `distributed(n, len)`: Similar to Euclidean, different algorithm

**Combinations:**
- `+`: Concatenate patterns
- `*`: Repeat pattern
- Example: `pulse.from{1,0} * 3 + {1,1}` = `{1,0,1,0,1,0,1,1}`

## Randomization & Controlled Chaos

### Seeded Randomization

Uses Xoshiro256PlusPlus RNG for cross-platform consistency:

```lua
-- Global seed (affects all random calls)
math.randomseed(12345)

-- Local generator (independent stream)
event = function(init_context)
  local rand = math.randomstate(1234)  -- Consistent random sequence
  local notes = scale("c5", "minor").notes
  return function(context)
    return notes[rand(1, #notes)]
  end
end
```

### Probability Gates

```lua
gate = function(init_context)
  local rand = math.randomstate(12366)
  return function(context)
    return context.pulse_value > rand()  -- pulse value as probability
  end
end
```

### Constrained Random Walk

```lua
event = function(init_context)
  local notes = scale("c4", "pentatonic minor").notes
  local last_index = 1
  return function(context)
    local next_index = last_index
    -- Prefer small intervals for smoother melodies
    while math.abs(next_index - last_index) > 2 do
      next_index = math.random(#notes)
    end
    last_index = next_index
    return notes[next_index]
  end
end
```

## Scale-Based Generation

### Random Notes from Scale

```lua
local s = scale("c4", "minor")
event = function(context)
  return s.notes[math.random(#s.notes)]
end
```

### Chord Progressions from Scale Degrees

```lua
local cmin = scale("c4", "minor")
event = sequence(
  cmin:chord("i"),   -- C minor (tonic)
  cmin:chord("iv"),  -- F minor (subdominant)
  cmin:chord("v"),   -- G minor (dominant)
  note(cmin:chord("i")):transpose({-12})  -- C minor, bass down
)
```

### Using Cycles for Progressions

```lua
cycle("i iv v i"):map(function(init_context)
  local s = scale("c4", "minor")
  return function(context, value)
    return s:chord(value)  -- Roman numeral chord degrees
  end
end)
```

## Pattern Evolution

### Stateful Generators

```lua
event = function(init_context)
  local counter = 0
  local variation = 1
  return function(context)
    counter = counter + 1
    -- Change variation every 16 steps
    if counter % 16 == 0 then
      variation = (variation % 4) + 1
    end
    local note_sets = {
      {"c4", "e4", "g4"},
      {"d4", "f4", "a4"},
      {"e4", "g4", "b4"},
      {"f4", "a4", "c5"}
    }
    local notes = note_sets[variation]
    return notes[math.imod(context.step, #notes)]
  end
end
```

### Time-Based Evolution

```lua
event = function(context)
  -- Melody gets higher as pattern progresses
  local octave = math.floor(context.step / 32)
  local base_note = scale("c", "minor").notes[math.imod(context.step, 7)]
  return base_note + (octave * 12)
end
```

## Polyrhythms & Unusual Time Signatures

### Via Cycles

```lua
-- 4 over 3 polyrhythm
cycle("[C3 D#4 F3 G#4], [[D#3 G4 F4]/64]*63")
```

### Via Subdivisions

```lua
pulse = {1, {1, 1, 1}, 1, {1, 1}}  -- 4 + triplet + 4 + duplet
```

### Via Resolution

```lua
unit = "1/4",
resolution = 5/4  -- 5 quarter notes in space of 4 (quintuplet)
```

## Note Transformations

```lua
-- Single transformations
note("c4"):transpose(12)      -- Up one octave
note("c4"):volume(0.5)        -- Half volume
note("c4"):amplify(1.5)       -- 150% of current volume
note("c4"):panning(-1)        -- Hard left
note("c4"):delay(0.1)         -- Slight timing delay
note("c4"):instrument(2)      -- Route to instrument 2

-- Chord transformations
note("c4'min"):transpose({12, 0, 0})  -- 1st inversion

-- Sequence transformations
sequence("c4", "e4", "g4"):amplify(0.5)
```

## Tidal Cycles Mini-Notation

### Key Symbols

- ` ` (space): Separates steps
- `,`: Parallel patterns (polyphony)
- `< >`: Alternates between values each cycle
- `|`: Random choice
- `*N`: Repeat N times
- `_`: Elongate/hold
- `~`: Rest
- `(n,k,o)`: Euclidean rhythm (n hits in k steps, o offset)
- `?p`: Probability (e.g., `c4?0.3` = 30% chance)

### Pattrns-Specific Syntax

`:` sets attributes (instrument/volume/pan/delay):

```lua
-- Attribute syntax
cycle("c4:v0.5:p-0.5")  -- C4, volume 0.5, pan left
cycle("c4:2")           -- C4 on instrument 2

-- Multi-channel drums with mapping
cycle("[kd ~]*2 ~ [~ kd] ~, [~ sn]*2, [<oh hh>*12]")
  :map({
    kd = "c4 #11",
    sn = "c4 #5",
    oh = "c4 #7",
    hh = "c4 #6 v0.5"
  })
```

## Texture Generation

### Dense Polyrhythmic Layers

```lua
-- Many euclidean patterns = complex texture
cycle("[c4(3,8)], [e4(5,13)], [g4(7,16)]")
  :map(function(context, value)
    return note(value)
      :volume(0.3 + math.random() * 0.4)
      :delay(math.random() * 0.3)
      :panning(math.random() * 2 - 1)
  end)
```

### Granular-Style Event Clouds

```lua
unit = "1/64",
pulse = function(context)
  return math.random() > 0.7  -- Sparse random
end,
event = function(context)
  local notes = scale("c6", "pentatonic").notes
  return note(notes[math.random(#notes)])
    :volume(0.1 + math.random() * 0.3)
    :delay(math.random())
end
```

## Common Pattern Recipes

### Probability-Based Event Filtering

```lua
gate = function(context)
  -- Higher probability on downbeats
  local is_downbeat = (context.pulse_step - 1) % 4 == 0
  local probability = is_downbeat and 0.9 or 0.3
  return math.random() < probability
end
```

### Combining Structure + Chaos

```lua
-- Structured rhythm, random notes
pulse = pulse.euclidean(7, 16),
event = function(context)
  return scale("c4", "minor").notes[math.random(7)]
end
```

### Cycle-Based Variation

```lua
-- Alternate between patterns
event = cycle("<[c4 e4 g4] [d4 f4 a4]>")

-- Random choice
event = cycle("[c4 e4 g4]|[d4 f4 a4]|[e4 g4 b4]")
```

## Tracker-Specific Considerations

### Lua Quirks

**1-Based Indexing:**
```lua
local notes = {"c4", "e4", "g4"}
return notes[1]  -- "c4", not "e4"!
```

**Array Wrapping:**
```lua
-- Use math.imod for proper 1-based wrapping
local index = math.imod(context.step, #notes)
```

### State Management

- **Global state**: Shared across all triggers
- **Local state** (in generators): Per-trigger isolation
- Use generators when you need separate state per note

### Performance Tips

- Cache expensive calculations in init functions
- Use local variables
- Avoid creating garbage (tables) in inner loops
- Return `nil` or `{}` for rests
