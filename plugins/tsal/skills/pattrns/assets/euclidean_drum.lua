-- Euclidean Drum Pattern Template
-- A versatile drum pattern using euclidean rhythm distribution
-- Modify the euclidean parameters (hits, steps, offset) to create variations

-- Define euclidean rhythms for each drum element
local kick = pulse.euclidean(4, 16)        -- 4 kicks in 16 steps
local snare = pulse.euclidean(3, 16, 2)    -- 3 snares in 16 steps, offset by 2
local hats = pulse.from{1,0,1,0}:repeat_n(4)  -- 16th note hi-hats
local ghost_snare = pulse.euclidean(7, 16):map(function(k, v)
  return v * (math.random() > 0.6 and 0.3 or 0)  -- Sparse ghost notes at low volume
end)

-- Combine drums using cycle notation with mapping
return cycle("[kd*16], [sn*16], [gs*16], [hh*16]"):map({
  kd = function(context)
    return kick[math.imod(context.step, 16)] and "c4 #1"
  end,
  sn = function(context)
    local v = snare[math.imod(context.step, 16)]
    return v and note("c4 #2"):volume(v)
  end,
  gs = function(context)
    local v = ghost_snare[math.imod(context.step, 16)]
    return v > 0 and note("c4 #2"):volume(v)
  end,
  hh = function(context)
    return hats[math.imod(context.step, 16)] and "c4 #3 v0.5"
  end
})

-- Tips for customization:
-- 1. Change euclidean parameters: (hits, steps, offset)
--    - More hits = denser rhythm
--    - More steps = longer pattern
--    - Offset rotates the pattern
-- 2. Adjust instrument numbers (#1, #2, #3) to match your drum kit
-- 3. Modify volume values to change dynamics
-- 4. Add more drum elements by extending the pattern
