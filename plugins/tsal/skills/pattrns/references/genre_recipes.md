# Genre-Specific Recipes for Pattrns

## Breakbeat / Jungle / Drum & Bass

### Complex Break Construction

```lua
-- Euclidean-based amen break variation
local kick = pulse.euclidean(4, 16)
local snare = pulse.euclidean(3, 16, 2):reverse()
local hats = pulse.from{1,0,1,0}:repeat_n(4)
local ghost_snare = pulse.euclidean(7, 16):map(function(k, v)
  return v * (math.random() > 0.6 and 0.3 or 0)  -- Sparse, quiet
end)

return cycle("[kd*16], [sn*16], [gs*16], [hh*16]"):map({
  kd = function(context)
    return kick[math.imod(context.step,16)] and "c4 #1"
  end,
  sn = function(context)
    local v = snare[math.imod(context.step,16)]
    return v and note("c4 #2"):volume(v)
  end,
  gs = function(context)
    local v = ghost_snare[math.imod(context.step,16)]
    return v > 0 and note("c4 #2"):volume(v)
  end,
  hh = function(context)
    return hats[math.imod(context.step,16)] and "c4 #3 v0.5"
  end
})
```

### Swing & Groove

```lua
-- Triplet feel for jungle swing
unit = "1/16",
resolution = 2/3,  -- Triplet subdivision
event = function(context)
  -- Add subtle random timing humanization
  return note("c4"):delay(0.05 * math.random())
end
```

### Reese Bassline

```lua
-- Random walk bassline with jungle-style rhythm
return pattern {
  unit = "1/16",
  pulse = pulse.euclidean(7, 16, 3),
  event = function(init_context)
    local last_note = 1
    local rand = math.randomstate(12345)
    local bass_notes = scale("c2", "minor").notes
    return function(context)
      -- Occasional jumps, mostly stepwise
      if rand() > 0.8 then
        last_note = rand(#bass_notes)
      else
        last_note = math.imod(last_note + rand(-1, 1), #bass_notes)
      end
      return bass_notes[last_note]
    end
  end
}
```

### Break Chopping Workflow

1. Generate complex drum pattern with variations
2. Render to audio in Renoise
3. Use timing variations via `:delay()` for humanization
4. Layer multiple instances with different random seeds
5. Resample and chop in pattern editor

## IDM / Experimental

### Glitchy Effects via Probability

```lua
-- Irregular, glitchy rhythm
pulse = function(context)
  if context.pulse_step % 7 == 0 then
    return math.random()
  end
  -- Sudden subdivisions
  if math.random() > 0.9 then
    return {1, 1, 1, 1}
  end
  return math.random() > 0.7
end
```

### Unusual Structures (Prime Numbers)

```lua
pulse = function(context)
  local primes = {2, 3, 5, 7, 11, 13, 17, 19, 23}
  return table.contains(primes, context.pulse_step % 24)
end
```

### Algorithmic Complexity (Fibonacci)

```lua
event = function(init_context)
  local fib = {1, 1, 2, 3, 5, 8, 13, 21}
  local scale_notes = scale("c4", "chromatic").notes
  return function(context)
    local index = fib[math.imod(context.step, #fib)]
    return scale_notes[math.imod(index, #scale_notes)]
  end
end
```

### Polymetric Madness

```lua
-- 5:7:3 polyrhythm
cycle("[c4*5]/4, [e4*7]/4, [g4*3]/4")
```

### Evolving Glitch Textures

```lua
-- Dense, chaotic event cloud
return pattern {
  unit = "1/64",
  pulse = function(context)
    -- Clustered random triggers
    local cluster = math.floor(context.pulse_step / 16) % 2
    return math.random() > (cluster == 0 and 0.9 or 0.5)
  end,
  event = function(context)
    local notes = scale("c4", "chromatic").notes
    return note(notes[math.random(#notes)])
      :volume(0.2 + math.random() * 0.5)
      :delay(math.random())
      :panning(math.random() * 2 - 1)
  end
}
```

## Jazz / Improvisation

### Swing Implementation

```lua
-- Classic jazz swing
unit = "1/8",
resolution = 2/3,  -- Triplet subdivision = swing feel
event = sequence("c4", "e4", "g4", "b4")
```

### Walking Bassline

```lua
event = function(init_context)
  local progression = {
    scale("c3", "mixolydian").notes,  -- C7
    scale("f3", "mixolydian").notes,  -- F7
    scale("g3", "mixolydian").notes,  -- G7
    scale("c3", "major").notes        -- Cmaj
  }
  local chord_index = 1
  local step_in_bar = 0

  return function(context)
    step_in_bar = (step_in_bar + 1) % 4
    if step_in_bar == 0 then
      chord_index = math.imod(chord_index + 1, #progression)
    end
    local current_scale = progression[chord_index]
    -- Stepwise motion through chord tones
    return current_scale[math.imod(step_in_bar, #current_scale)]
  end
end
```

### Harmonic Substitutions

```lua
event = function(context)
  local chords = {
    scale("c4", "major"):chord(1),
    scale("c4", "major"):chord(5)
  }
  -- Randomly substitute with tritone sub
  if math.random() > 0.8 then
    return chord("f#4", "dom7")  -- Tritone substitution
  else
    return chords[math.imod(context.step, #chords)]
  end
end
```

### Improvisation Simulation (Lick Library)

```lua
event = function(init_context)
  local lick_library = {
    {48, 52, 55, 60},  -- Lick 1
    {48, 50, 51, 55},  -- Lick 2
    {55, 52, 48, 47}   -- Lick 3
  }
  local current_lick = 1
  local lick_position = 1

  return function(context)
    -- Occasionally change lick
    if context.step % 8 == 0 and math.random() > 0.6 then
      current_lick = math.random(#lick_library)
      lick_position = 1
    end
    local lick = lick_library[current_lick]
    local note = lick[lick_position]
    lick_position = math.imod(lick_position + 1, #lick)
    return note
  end
end
```

### Comping Patterns

```lua
-- Sparse chord voicings with syncopation
return pattern {
  unit = "1/8",
  resolution = 2/3,  -- Swing
  pulse = {0, 0.8, 0, 0.6, 0, 0, 0.9, 0},
  event = function(init_context)
    local voicings = {
      scale("c4", "major"):chord(1, 4),   -- Cmaj7
      scale("c4", "dorian"):chord(2, 4),  -- Dm7
      scale("c4", "major"):chord(5, 4),   -- G7
    }
    return function(context)
      local chord_idx = math.floor(context.step / 8) % #voicings + 1
      return note(voicings[chord_idx])
        :volume(context.pulse_value)
    end
  end
}
```

## Industrial / Trip-Hop

### Heavy, Sparse Grooves

```lua
-- 90s trip-hop style
return pattern {
  unit = "1/16",
  pulse = {1, 0, 0, {0, 0, 1}, 0, 1, 0, 0},
  event = sequence(
    note("c2"):volume(1.0),    -- Kick
    note("c3"):volume(0.8),    -- Snare
    note("g2"):volume(0.4)     -- Ghost note
  )
}
```

### Industrial Noise Textures

```lua
-- Sparse industrial texture layer
return pattern {
  unit = "1/64",
  pulse = function(context)
    return math.random() > 0.95  -- Very sparse
  end,
  event = function(context)
    return note(36 + math.random(0, 24))
      :volume(0.1 + math.random() * 0.2)
      :delay(math.random())
      :panning(math.random() * 2 - 1)
  end
}
```

### Sample Variation (Weighted Random)

```lua
event = function(context)
  local samples = {0, 1, 2, 3, 4, 5}
  local weights = {0.4, 0.3, 0.2, 0.05, 0.03, 0.02}

  local r = math.random()
  local sum = 0
  for i, weight in ipairs(weights) do
    sum = sum + weight
    if r < sum then
      return note("c4"):instrument(samples[i])
    end
  end
end
```

### Dark, Heavy Bassline

```lua
-- Slow, menacing bass
return pattern {
  unit = "1/8",
  pulse = pulse.euclidean(5, 16),
  event = function(init_context)
    local progression = {
      scale("c2", "phrygian").notes,
      scale("d#2", "phrygian").notes,
    }
    return function(context)
      local section = math.floor(context.step / 16) % 2 + 1
      local notes = progression[section]
      return notes[math.imod(context.step, #notes)]
    end
  end
}
```

## Ambient / Textural

### Slow Evolution

```lua
-- Very slow, evolving texture
return pattern {
  unit = "bars",
  resolution = 4,  -- Every 4 bars
  event = function(init_context)
    local evolution = 0
    return function(context)
      evolution = evolution + 0.1
      local base_scale = scale("c3", "pentatonic major").notes
      -- Notes drift upward slowly
      local octave_shift = math.floor(evolution / 2) * 12
      local note_choice = base_scale[math.imod(context.step, #base_scale)]
      return note(note_choice + octave_shift):volume(0.3)
    end
  end
}
```

### Dense Polyphonic Pads

```lua
-- Overlapping chord tones
event = function(context)
  local chord_notes = scale("c3", "major"):chord(
    math.imod(context.step, 7), 4
  )
  return note(chord_notes)
    :volume(0.2 + 0.1 * math.random())
    :delay(math.random() * 0.5)  -- Desynchronize
end
```

### Generative Drone

```lua
-- Breathing drone with slow modulation
return pattern {
  unit = "seconds",
  resolution = 8,  -- Every 8 seconds
  pulse = function(context)
    return math.random() > 0.3  -- Some rests
  end,
  event = function(context)
    local drone_notes = {48, 55, 60, 67}  -- C, G, C, G
    return note(drone_notes)
      :volume(0.1 + 0.1 * math.sin(context.pulse_step * 0.1))
      :panning(math.sin(context.pulse_step * 0.05))
  end
}
```

### Sparse Atmospheric Events

```lua
-- Rare, atmospheric note events
return pattern {
  unit = "1/16",
  pulse = function(context)
    return math.random() > 0.92  -- Very rare triggers
  end,
  event = function(context)
    local scale_notes = scale("c4", "phrygian").notes
    -- High notes, long delays
    return note(scale_notes[math.random(5, #scale_notes)])
      :volume(0.2)
      :delay(math.random() * 0.8)
      :panning(math.random() * 2 - 1)
  end
}
```

### Evolving Harmonic Field

```lua
-- Slowly shifting chord progression
event = function(init_context)
  local phase = 0
  local scales = {
    scale("c3", "major"),
    scale("c3", "dorian"),
    scale("c3", "phrygian"),
    scale("c3", "lydian"),
  }

  return function(context)
    phase = phase + 0.01
    -- Evolve through scales
    local scale_idx = math.floor(2 + 2 * math.sin(phase))
    local current_scale = scales[scale_idx]

    -- Random chord from current scale
    local degree = math.random(1, 7)
    return current_scale:chord(degree, 3)
  end
end
```

## Cross-Genre Techniques

### Markov Chain (Probability Matrix)

```lua
-- State-based note selection
event = function(init_context)
  local transition_matrix = {
    [1] = {[1]=0.1, [2]=0.3, [3]=0.4, [4]=0.2},
    [2] = {[1]=0.2, [2]=0.2, [3]=0.3, [4]=0.3},
    [3] = {[1]=0.3, [2]=0.3, [3]=0.1, [4]=0.3},
    [4] = {[1]=0.2, [2]=0.2, [3]=0.2, [4]=0.4},
  }
  local scale_notes = scale("c4", "minor").notes
  local current_note = 1

  return function(context)
    local r = math.random()
    local sum = 0
    for next_note, prob in pairs(transition_matrix[current_note]) do
      sum = sum + prob
      if r < sum then
        current_note = next_note
        return scale_notes[current_note]
      end
    end
  end
end
```

### Genetic Evolution (Fitness-Based)

```lua
-- Evolve pattern toward a target
event = function(init_context)
  local target_melody = {60, 64, 67, 72}
  local population_size = 10

  -- Initialize population
  local population = {}
  for i = 1, population_size do
    population[i] = {}
    for j = 1, 4 do
      population[i][j] = 60 + math.random(0, 12)
    end
  end

  local generation = 0

  return function(context)
    if context.step % 16 == 0 then
      -- Evaluate fitness and evolve
      generation = generation + 1
      -- (Add selection, crossover, mutation logic here)
    end

    local best = population[1]
    local note_idx = math.imod(context.step, #best)
    return best[note_idx]
  end
end
```

### Bouncing Ball Physics

```lua
-- Physical simulation as rhythm
pulse = function(init_context)
  local distance = 100
  local speed = 1
  local step = 0
  local step_size = distance / speed

  return function(context)
    step = step + 1
    if step >= step_size then
      distance = distance * 0.8  -- Decay
      step_size = distance / speed
      step = 0
      return 1
    end
    return 0
  end
end
```
