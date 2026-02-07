// Lush ambient pad with slow chord progression

note("<[c,e,g]!3 [d,f,a] [e,g,b]!2 [f,a,c]>")
  .slow(8)                               // Very slow changes
  .superimpose(x => x.add(.04))          // Slight detuning
  .add(perlin.range(0, .2))              // Subtle pitch drift
  .s("triangle")
  .attack(2)                             // Slow fade in
  .release(3)                            // Slow fade out
  .lpf(sine.range(800, 2000).slow(32))   // Gentle filter movement
  .room(.8)                              // Heavy reverb
  .gain(.3)
