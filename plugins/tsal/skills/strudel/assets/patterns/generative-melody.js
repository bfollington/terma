// Generative melody using Euclidean rhythms and scale

note("<0 2 4 6>*8")
  .scale("C:minor")
  .euclid(5, 8)                          // Euclidean distribution
  .fast("<1 2 4>")                       // Variable speed
  .every(4, rev)                         // Reverse every 4 cycles
  .sometimes(add(12))                    // Random octave jumps
  .off(1/8, x => x.add(7).degradeBy(.3)) // Echo with fifth
  .s("sawtooth")
  .lpf(sine.range(300, 2000).slow(8))
  .room(.3)
  .gain(.5)
