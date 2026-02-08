# Pattrns API Quick Reference

## Pattern Structure

```lua
return pattern {
  unit = "1/16" | "1/8" | "1/4" | "bars" | "beats" | "ms" | "seconds",
  resolution = 1,        -- Multiplier (2/3 for triplets, 3/2 for dotted)
  offset = 0,            -- Delay start in time units
  repeats = true,        -- Loop pattern
  pulse = {...} | function,
  gate = function,       -- Optional
  event = {...} | function | cycle_string
}
```

## Time Units

- `"1/1"`, `"1/2"`, `"1/4"`, `"1/8"`, `"1/16"`, `"1/32"`, `"1/64"`
- `"bars"`, `"beats"` (alias for 1/4)
- `"ms"`, `"seconds"` (wall-clock time)

## Pulse Functions

### Euclidean Rhythms
```lua
pulse.euclidean(hits, steps)           -- Distribute hits in steps
pulse.euclidean(hits, steps, offset)   -- With rotation
```

### Pulse Operations
```lua
pulse.from{1, 0, 1, 0}          -- Create from array
pulse.new(len, fn)              -- Generate from function
pulse.new(len, iterator)        -- Generate from iterator

-- Transformations
:reverse()                      -- Reverse order
:rotate(n)                      -- Shift by n steps
:repeat_n(n)                    -- Repeat n times
:spread(factor)                 -- Stretch/compress
:take(n)                        -- First n elements
:map(fn)                        -- Transform each element
:distributed(n, len)            -- Alternative distribution

-- Combinations
pulse1 + pulse2                 -- Concatenate
pulse * n                       -- Repeat n times
```

## Scale Functions

### Creating Scales
```lua
scale(root, mode)               -- Create scale
scale("c4", "major")
scale("c4", "minor")
scale("c4", "dorian")
scale("c4", "phrygian")
scale("c4", "lydian")
scale("c4", "mixolydian")
scale("c4", "pentatonic major")
scale("c4", "pentatonic minor")
scale("c4", "chromatic")
```

### Scale Properties
```lua
s.notes                         -- Array of MIDI note numbers
s.root                          -- Root note
s.mode                          -- Scale mode name
```

### Scale Methods
```lua
s:chord(degree)                 -- Chord from scale degree
s:chord(degree, num_notes)      -- Chord with n notes
s:chord("i")                    -- Roman numeral (i-vii)
s:chord("I")                    -- Uppercase for major
s:notes_iter()                  -- Iterator over notes
```

## Note Functions

### Creating Notes
```lua
note("c4")                      -- MIDI note name
note(60)                        -- MIDI note number
note{"c4", "e4", "g4"}         -- Chord
chord("c4", "maj")              -- Named chord
chord("c4", "min")
chord("c4", "dom7")
chord("c4", "maj7")
```

### Note Transformations
```lua
note("c4"):transpose(n)         -- Transpose by semitones
note("c4"):volume(v)            -- Set volume (0.0-1.0)
note("c4"):amplify(factor)      -- Multiply volume
note("c4"):panning(p)           -- Pan (-1.0 to 1.0)
note("c4"):delay(d)             -- Timing delay (0.0-1.0)
note("c4"):instrument(n)        -- Instrument/sample number

-- Chord-specific
note(chord):transpose({12,0,0}) -- Transpose individual notes
```

## Sequence Functions

```lua
sequence("c4", "e4", "g4")      -- Static sequence
sequence(note1, note2, ...)     -- Note objects

-- Transformations (same as note)
:transpose(n)
:volume(v)
:amplify(factor)
:panning(p)
:delay(d)
:instrument(n)
```

## Cycle (Tidal Mini-Notation)

### Creating Cycles
```lua
cycle("c4 e4 g4")               -- Simple sequence
cycle("c4 e4 g4, d4 f4 a4")    -- Polyphonic (parallel)
cycle("[c4 e4] [g4 b4]")        -- Groups
cycle("c4*4")                   -- Repeat
cycle("c4 ~")                   -- Rest
cycle("c4 e4_")                 -- Elongate
cycle("c4?0.5")                 -- 50% probability
cycle("<c4 e4 g4>")             -- Alternate each cycle
cycle("c4|e4|g4")               -- Random choice
cycle("c4(3,8)")                -- Euclidean (3 hits in 8)
```

### Cycle Attributes
```lua
cycle("c4:v0.5")                -- Volume
cycle("c4:p-1")                 -- Pan
cycle("c4:d0.2")                -- Delay
cycle("c4:2")                   -- Instrument
cycle("c4:v0.5:p-0.5:2")       -- Combined
```

### Cycle Mapping
```lua
cycle("kd ~ sn ~"):map({
  kd = "c4 #1",                 -- Map to note
  sn = function(ctx)            -- Map to function
    return note("c4 #2"):volume(0.8)
  end
})
```

## Context Object

Available in gate and event functions:

```lua
-- Timing info
context.beats_per_min           -- Current BPM
context.beats_per_bar           -- Time signature
context.step                    -- Global step counter
context.pulse_step              -- Pulse step counter

-- Pulse info
context.pulse_value             -- Current pulse value (0.0-1.0)

-- Parameters (if defined)
context.parameter.param_name    -- Access parameter values
```

## Parameters

```lua
parameter = {
  parameter.integer("name", default, {min, max}),
  parameter.number("name", default, {min, max}),
  parameter.boolean("name", default),
}
```

Access in functions: `context.parameter.name`

## Random Functions

```lua
math.random()                   -- 0.0 to 1.0
math.random(n)                  -- 1 to n (integer)
math.random(min, max)           -- min to max (integer)
math.randomseed(seed)           -- Set global seed
math.randomstate(seed)          -- Create local RNG

-- Example usage
local rand = math.randomstate(1234)
rand()                          -- 0.0 to 1.0
rand(10)                        -- 1 to 10
```

## Utility Functions

```lua
math.imod(value, modulus)       -- 1-based modulo for arrays
table.contains(tbl, value)      -- Check if value in table
table.find(tbl, value)          -- Get index of value
```

## Common Patterns

### Static Pulse, Dynamic Event
```lua
pulse = pulse.euclidean(7, 16),
event = function(context)
  return scale("c4", "minor").notes[math.random(7)]
end
```

### Dynamic Pulse, Static Event
```lua
pulse = function(context)
  return math.random() > 0.5
end,
event = {"c4", "e4", "g4"}
```

### Stateful Generator
```lua
event = function(init_context)
  local state = initial_value
  return function(context)
    -- Update state
    state = state + 1
    -- Use state to generate output
    return something_based_on(state)
  end
end
```

### Probability Gate
```lua
gate = function(context)
  return context.pulse_value > math.random()
end
```

### Position-Dependent Pattern
```lua
event = function(context)
  local position = context.pulse_step % 16
  if position < 4 then
    return pattern_a
  else
    return pattern_b
  end
end
```

## Workflow Tips

1. **Start simple**: Static pulse + static event
2. **Add variation**: Make one dynamic (usually event first)
3. **Add complexity**: Make both dynamic or add gate
4. **Add control**: Use parameters for live tweaking
5. **Optimize**: Cache calculations in init functions
6. **Test**: Use `repeats = false` for testing finite patterns

## Common Gotchas

- **Lua is 1-indexed**: `array[1]` is first element, not `array[0]`
- **Use math.imod**: For wrapping array access with proper 1-based behavior
- **Global vs local state**: Use generators for per-trigger state isolation
- **Return nil for rests**: Don't return 0 or false, return `nil` or `{}`
- **Pulse values**: Can be binary (0/1) or weighted (0.0-1.0)
- **Context availability**: Init functions don't have full context, inner functions do
