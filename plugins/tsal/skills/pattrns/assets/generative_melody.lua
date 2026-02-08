-- Generative Melody Template
-- Creates a constrained random melody that stays in key
-- Uses a random walk with interval constraints for musicality

return pattern {
  unit = "1/16",

  -- Euclidean rhythm for rhythmic interest
  pulse = pulse.euclidean(7, 16),

  -- Generative melody with constraints
  event = function(init_context)
    -- Choose your scale
    local notes = scale("c4", "pentatonic minor").notes
    -- Or try: scale("c4", "minor").notes
    --         scale("c4", "major").notes
    --         scale("c4", "dorian").notes
    --         scale("c4", "phrygian").notes

    local last_index = 1

    -- Optional: seed for reproducible randomness
    -- local rand = math.randomstate(12345)

    return function(context)
      local next_index = last_index

      -- Constrained random walk: prefer small intervals (max 2 steps)
      -- This creates smoother, more musical melodies
      while math.abs(next_index - last_index) > 2 do
        next_index = math.random(#notes)
        -- If using seeded random: next_index = rand(1, #notes)
      end

      last_index = next_index
      return notes[next_index]
    end
  end
}

-- Tips for customization:
-- 1. Change scale root and mode to explore different tonalities
-- 2. Adjust interval constraint (> 2) for larger jumps
-- 3. Modify euclidean parameters for different rhythms
-- 4. Add note transformations like :volume(), :delay(), :panning()
-- 5. Use seeded random (uncomment lines) for consistent results
