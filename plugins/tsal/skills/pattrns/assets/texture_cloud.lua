-- Texture Cloud Template
-- Creates sparse, atmospheric texture with random note events
-- Perfect for ambient, drone, or textural layers

return pattern {
  unit = "1/16",

  -- Sparse random triggers
  pulse = function(context)
    -- Adjust threshold for density (0.92 = ~8% trigger rate)
    -- Lower number = more triggers
    -- Higher number = fewer triggers (more sparse)
    return math.random() > 0.92
  end,

  event = function(init_context)
    -- Choose your scale
    local notes = scale("c4", "phrygian").notes
    -- Try: "pentatonic major", "pentatonic minor", "minor", "major"

    -- Optional: seed for reproducibility
    -- local rand = math.randomstate(54321)

    return function(context)
      -- Pick from upper register for atmospheric quality
      local note_index = math.random(5, #notes)
      -- If using seeded random: local note_index = rand(5, #notes)

      return note(notes[note_index])
        :volume(0.2 + math.random() * 0.3)  -- Quiet, varying volume
        :delay(math.random() * 0.8)         -- Random timing offset
        :panning(math.random() * 2 - 1)     -- Spread across stereo field
    end
  end
}

-- Tips for customization:
-- 1. Adjust pulse threshold (0.92) for more/less density
-- 2. Change scale for different moods
-- 3. Modify note_index range: (1, #notes) for full range
-- 4. Adjust volume range for louder/quieter textures
-- 5. Change unit to "1/32" or "1/64" for finer-grained events
-- 6. Add instrument routing: :instrument(math.random(0, 7))
-- 7. For drones, use lower threshold and longer notes

-- Variations to try:
-- Dense texture: pulse threshold 0.7
-- Very sparse: pulse threshold 0.97
-- Low texture: note_index from (1, 4)
-- High texture: note_index from (8, #notes)
