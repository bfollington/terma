// Basic techno drum pattern
// Classic 4/4 kick with offbeat hi-hats and syncopated snare

stack(
  s("bd(3,8)"),                    // Euclidean kick pattern
  s("sd:[~ <sd!3 sd(3,4,2)>]"),   // Syncopated snare
  s("hh*8")                        // Hi-hat on every 8th
    .speed(perlin.range(.9, 1.1)) // Subtle speed variation
    .gain(perlin.range(.3, .5)),  // Dynamic variation
  s("oh").euclid(3, 16)            // Open hi-hat accents
    .gain(.4)
).cpm(128)
