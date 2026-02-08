-- Evolving Chord Progression Template
-- Creates a slowly changing chord progression with variation
-- Perfect for ambient, jazz, or evolving harmonic content

return pattern {
  unit = "1/4",  -- Quarter notes (adjust for tempo)
  pulse = {1, 1, 1, 1},  -- Steady pulse

  event = function(init_context)
    -- Define chord progressions for different sections
    local scale_root = "c4"
    local scale_mode = "minor"
    -- Try: "major", "dorian", "phrygian", "lydian", "mixolydian"

    local s = scale(scale_root, scale_mode)

    -- Multiple chord progressions to cycle through
    local progressions = {
      {s:chord("i", 3), s:chord("iv", 3), s:chord("v", 3), s:chord("i", 3)},
      {s:chord("i", 3), s:chord("vi", 3), s:chord("iv", 3), s:chord("v", 3)},
      {s:chord("i", 4), s:chord("iii", 4), s:chord("vi", 4), s:chord("ii", 4)},
    }

    local current_progression = 1
    local evolution_counter = 0

    return function(context)
      evolution_counter = evolution_counter + 1

      -- Change progression every 16 steps (4 bars of 4 beats)
      if evolution_counter % 16 == 0 then
        current_progression = (current_progression % #progressions) + 1
      end

      local progression = progressions[current_progression]
      local chord_index = math.imod(context.step, #progression)
      local current_chord = progression[chord_index]

      -- Optional: add subtle variations
      if math.random() > 0.8 then
        -- Occasionally add a random inversion or voicing
        return note(current_chord)
          :transpose({math.random(-12, 12), 0, 0})
      else
        return current_chord
      end
    end
  end
}

-- Tips for customization:
-- 1. Change scale_root and scale_mode for different tonalities
-- 2. Add more progressions to the progressions table
-- 3. Adjust evolution speed (% 16) for faster/slower changes
-- 4. Modify chord sizes: s:chord("i", 4) for 4-note chords
-- 5. Add dynamics: :volume(0.3 + math.random() * 0.4)
-- 6. Use different time units (1/8, bars) for different feels
