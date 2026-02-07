// Classic acid bassline with TB-303 style filter modulation

note("[<g1 f1>/8](<3 5>,8)")
  .clip(perlin.range(.15, 1.5))
  .release(.1)
  .s("sawtooth")
  .lpf(sine.range(400, 800).slow(16))    // Sweeping filter
  .lpq(cosine.range(6, 14).slow(3))      // Moving resonance
  .lpenv(sine.mul(4).slow(4))            // Filter envelope
  .lpd(.2).lpa(.02)
  .ftype('24db')
  .rarely(add(note(12)))                 // Occasional octave jump
  .room(.2).shape(.3)
