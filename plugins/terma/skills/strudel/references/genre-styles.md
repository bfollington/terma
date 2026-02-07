# Genre and Artist Style Reference

This reference provides genre-specific characteristics and artist styles to help translate user references into concrete Strudel techniques.

## Dark Ambient Hip-Hop

### Lorn

**Sonic Characteristics:**
- Heavily pitched-down vocal samples (`.speed(0.5-0.7)`)
- Deep, melodic sub bass (sine wave with light saturation, `.lpf(180-250)`)
- Glitchy, industrial textures (`.degradeBy()`, `.scrub()` on metal samples)
- Heavy reverb and delay (`.room(.6-.9)`, `.delay(.25-.5)`)
- Slow tempos (65-80 BPM)
- Sparse, weighted drums with long decay

**Strudel Techniques:**
```javascript
// Lorn-style bass
note("d1 f1 g1 d1")
  .s("sine")
  .lpf(200)
  .shape(.3-.5)
  .decay(.6-.8)
  .room(.2)

// Glitchy textures
s("metal").n("<2 4 7 3>").fit()
  .scrub(irand(8).div(8).seg(16))
  .dist("2:.6")
  .hpf(8000)
  .delay(.5)
  .room(.6)
```

### Clams Casino

**Sonic Characteristics:**
- Ethereal, pitched vocal chops (`.speed(0.5-0.8)`, heavy reverb)
- Lush pad layers with stereo width (`.pan()` modulation)
- Dreamy atmosphere (long reverb tails `.room(.8-.9)`, `.size(.9-.95)`)
- Simple, sparse drum patterns
- Extended chord voicings (7ths, 9ths, 11ths)
- Delay as melodic element (`.delay(.375-.5)`)

**Strudel Techniques:**
```javascript
// Clams Casino-style vocals
s("vox").n("<0 2 4 1>").fit()
  .speed(choose([0.5, 0.6, 0.7]))
  .room(.8)
  .size(.9)
  .delay(.375)

// Atmospheric pads
note("<d2 f2 g2 a2>")
  .add(note("[0,7,10,14]")) // Extended chords
  .s("sine")
  .attack(1.5)
  .release(3)
  .room(.9)
  .pan(sine.range(0.3, 0.7).slow(16))
```

## Techno

### General Techno

**Sonic Characteristics:**
- 4/4 kick pattern (120-140 BPM)
- Euclidean hi-hat patterns
- Repetitive, hypnotic elements
- Filter sweeps on synth lines
- Heavy use of delay and reverb

**Strudel Techniques:**
```javascript
// Techno kick
s("bd(4,4)").n(27)
  .gain(.9)
  .lpf(120)

// Euclidean hats
s("hh").struct("x(5,8)")
  .gain(.4)
  .hpf(8000)

// Acid bassline
note("<c2 eb2 f2 g2>")
  .s("sawtooth")
  .lpf(sine.range(300, 2000).fast(4))
  .resonance(10)
```

### Dub Techno

**Sonic Characteristics:**
- Deep, rolling bass
- Chord stabs with long delay (`.delay(.5-.75)`)
- Minimalist drums
- Heavy reverb creating space
- Slower tempo (120-125 BPM)

**Strudel Techniques:**
```javascript
// Dub chord stabs
note("<d3 f3 a3>").slow(4)
  .s("sawtooth")
  .decay(.3)
  .delay(.75)
  .room(.8)
  .lpf(1500)
```

## Drum & Bass / Jungle

### Jungle

**Sonic Characteristics:**
- Fast tempo (160-180 BPM)
- Amen break manipulation
- Deep sub bass (sine wave, 40-80 Hz)
- Reggae/dub influences
- Sample chops and edits

**Strudel Techniques:**
```javascript
// Amen break
s("breaks").n(0).fit()
  .scrub(irand(16).div(16).seg(8))
  .fast(2)
  .sometimes(rev)

// Jungle sub bass
note("d1 ~ ~ d1 ~ d1 ~ ~")
  .s("sine")
  .lpf(80)
  .decay(.6)
  .sustain(.8)
```

### Liquid DnB

**Sonic Characteristics:**
- Melodic elements
- Smooth pads and chords
- Jazz-influenced harmony
- Warm bass tones
- Soulful vocals

**Strudel Techniques:**
```javascript
// Liquid pad
note("<d3 f3 a3 c4>")
  .add(note("[0,4,7]"))
  .s("sine")
  .attack(1)
  .release(2)
  .room(.7)
  .lpf(3000)
```

## Trap / Hip-Hop

### Trap

**Sonic Characteristics:**
- Hi-hat rolls (`.fast(4)` or `*8`)
- 808 sub bass slides (`.slide()` or portamento)
- Snare rolls and triplet patterns
- Slow tempo (130-170 BPM, half-time feel)
- Layered percussion

**Strudel Techniques:**
```javascript
// Trap hi-hat rolls
s("hh*8").n(3)
  .sometimes(fast(2))
  .gain(perlin.range(.3, .6))

// 808 bass
note("c1 ~ eb1 f1")
  .s("sine")
  .lpf(200)
  .dist("2:.8")
  .decay(.8)
```

### Boom Bap

**Sonic Characteristics:**
- Vinyl crackle texture
- Hard-hitting snare on 2 and 4
- Kicked-back swing feel
- Soul/jazz samples
- Moderate tempo (85-95 BPM)

**Strudel Techniques:**
```javascript
// Boom bap drums
stack(
  s("bd").beat("0,6,10,14", 16),
  s("sd").beat("4,12", 16).gain(.7),
  s("hh!16").gain(perlin.range(.2, .4))
).swingBy(0.4, 8)

// Vinyl texture
s("vinyl").n(2).fit()
  .gain(.2)
  .hpf(800)
  .room(.2)
```

## Ambient / Experimental

### Dark Ambient

**Sonic Characteristics:**
- Long, evolving textures
- Low-frequency drones
- Sparse or absent rhythm
- Heavy reverb and space
- Dissonant or atonal harmony

**Strudel Techniques:**
```javascript
// Dark drone
note("d1 f1 ab1")
  .s("sine")
  .attack(4)
  .release(8)
  .room(.95)
  .dist("0.5:.3")
  .lpf(sine.range(200, 800).slow(32))

// Textural noise
s("white")
  .lpf(perlin.range(400, 1200))
  .hpf(300)
  .gain(.15)
  .room(.9)
```

### IDM / Glitch

**Sonic Characteristics:**
- Complex rhythmic patterns (Euclidean, polyrhythms)
- Digital artifacts and glitches (`.degradeBy()`, `.crush()`)
- Unconventional time signatures
- Precise, robotic sounds
- Frequent pattern variation

**Strudel Techniques:**
```javascript
// Glitchy pattern
s("bd hh sd").struct("x(5,13)")
  .degradeBy(perlin.range(0, .5))
  .crush(4)
  .sometimes(ply(2))
  .every(4, rev)

// Polyrhythmic layers
stack(
  s("bd(3,8)"),
  s("sd(5,13)"),
  s("hh(7,16)")
)
```

## House

### Deep House

**Sonic Characteristics:**
- Warm, groovy basslines
- Soulful vocal samples
- Jazzy chords (7ths, 9ths)
- Subtle percussion layers
- 4/4 kick with open hi-hat on offbeats
- Tempo (120-125 BPM)

**Strudel Techniques:**
```javascript
// Deep house bass
note("c2 ~ eb2 ~ f2 ~ eb2 ~")
  .s("sawtooth")
  .lpf(800)
  .resonance(5)
  .decay(.4)

// Jazzy chords
note("<c3 eb3 f3 bb3>")
  .add(note("[0,4,7,10]"))
  .s("triangle")
  .attack(.3)
  .decay(.8)
  .room(.4)
```

### Acid House

**Sonic Characteristics:**
- TB-303 bassline (`.resonance(10-20)`)
- Filter sweeps (sine/perlin modulation)
- Repetitive, hypnotic
- Squelchy, resonant sounds
- Moderate tempo (120-130 BPM)

**Strudel Techniques:**
```javascript
// 303 bassline
note("<c2 eb2 f2 g2>")
  .s("sawtooth")
  .lpf(sine.range(200, 2500).fast(4))
  .resonance(15)
  .decay(.1)
  .gain(.6)
```

## Usage Guidelines

**When using this reference:**

1. **Identify user's reference** - Look for artist/genre mentions in request
2. **Load relevant section** - Read applicable characteristics
3. **Apply techniques** - Use provided Strudel code patterns
4. **Adapt, don't copy** - Treat examples as starting points, not templates
5. **Combine elements** - Mix characteristics from multiple genres/artists as needed

**Searching this file:**
```bash
grep -i "lorn" references/genre-styles.md
grep -i "trap" references/genre-styles.md
grep -i "ambient" references/genre-styles.md
```

## Contributing New Styles

When discovering new genre/artist patterns through usage:

1. Document sonic characteristics (what you hear)
2. Provide Strudel implementation techniques (how to create it)
3. Include BPM ranges, typical effects, and structural elements
4. Add concrete code examples that demonstrate the style
