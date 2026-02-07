# Strudel Technical Reference: Operations and Pattern Syntax

Strudel ports TidalCycles' functional pattern language to JavaScript, implementing pure functional reactive programming for live-coded music. Patterns are immutable query functions that transform time spans into event streams.

## Core Concepts

**Pattern Query Model**: Patterns are opaque functions `TimeSpan → [Event]` that generate events on-demand. Transformations create new patterns wrapping old ones, manipulating queries before and results after.

**Cycles**: The fundamental temporal unit. Default cycle = 0.5 CPS (2 seconds). All patterns align to cycle boundaries using rational numbers (fractions) for precise timing.

**Immutability**: Every transformation returns a new pattern. No mutation.

**Method Chaining**: Fluent interface for composing transformations: `.fast(2).rev().add(7)`

## Mini-Notation DSL

The mini-notation is a domain-specific language for expressing rhythmic patterns concisely. Double-quoted strings are automatically parsed as mini-notation.

### Sequence and Structure

```javascript
// Space-separated sequence - events evenly distributed
note("c e g b")  // 4 events per cycle, each 1/4 cycle

// Square brackets - subdivide parent event's time
note("e5 [b4 c5] d5 [c5 b4]")  // Nested subdivisions
note("e5 [b4 c5] d5 [c5 b4 [d5 e5]]")  // Arbitrary depth

// Angle brackets - slow cat (one per cycle)
note("<e5 b4 d5 c5>")  // One element each cycle
note("<e5 b4 d5 c5>*8")  // Can be multiplied

// Comma - parallel/simultaneous events
note("[g3,b3,e4]")  // Chord (polyphony)
note("g3,b3,e4")  // Outer brackets optional
```

### Timing Operators

```javascript
// * - Multiplication (speed up)
note("[e5 b4 d5 c5]*2")  // Play twice per cycle
sound("hh*8")  // 8 hi-hats per cycle

// / - Division (slow down)
note("[e5 b4 d5 c5]/2")  // Spread over 2 cycles

// @ - Weight/elongation (relative duration)
note("<[g3,b3,e4]@2 [a3,c3,e4] [b3,d3,f#4]>*2")
// @2 element is twice as long as @1 elements

// ! - Replication (repeat without speeding up)
note("<[g3,b3,e4]!2 [a3,c3,e4]>*2")
sound("[bd!4, cp!3]")  // Different repetition counts

// ~ or - - Rest/silence
note("[b4 [~ c5] d5 e5]")
sound("bd hh - rim")
```

### Euclidean Rhythms

```javascript
// (pulses, steps, offset?)
s("bd(3,8)")  // 3 beats over 8 steps (Bjorklund algorithm)
s("bd(3,8,0)")  // Optional offset (default 0)
s("bd(3,8,3)")  // Start from position 3
note("e5(2,8) b4(3,8) d5(2,8) c5(3,8)")  // Multiple patterns

// Negative pulses invert pattern
s("bd(-3,8)")
```

### Polymeter

```javascript
// {} - Curly braces for polymeter
sound("{per per:6 [~ per:14] per:27, text:17 ~ ~ ~ tone:29}")
// Patterns repeat until LCM fits cycle
// First pattern sets pulse/meter

// With step specification %
note("{c eb g, c2 g2}%6")  // Align to 6 steps
```

### Randomness

```javascript
// ? - Degradation (random removal)
sound("bd hh? sd? oh")  // ? = 50% removal
sound("bd hh?0.1 sd?0.9 oh")  // Explicit probabilities

// | - Random choice per cycle
note("[c3|e3|a3], [c4|e4|a4]")
```

### Sample Selection

```javascript
sound("casio:1")  // Select sample 1 from bank
sound("hh:0 hh:1 hh:2 hh:3")  // Explicit indices

// Alternative functional form (more composable)
n("0 1 [4 2] 3*2").sound("jazz")
```

### Mini-Notation to Function Equivalents

| Mini-Notation | Function | Description |
|---------------|----------|-------------|
| `"x y"` | `seq(x, y)` | Sequence (fastcat) |
| `"<x y>"` | `cat(x, y)` | Slow cat |
| `"x,y"` | `stack(x, y)` | Parallel |
| `"x@3 y@2"` | `stepcat([3,x], [2,y])` | Weighted steps |
| `"{a b c, x y}"` | `polymeter([a,b,c], [x,y])` | Polymeter |
| `"{x y z}%2"` | `polymeterSteps(2, x,y,z)` | Polymeter with steps |
| `"~"` | `silence` | Rest |
| `"x*n"` | `fast(n)` | Speed up |
| `"x/n"` | `slow(n)` | Slow down |

### Complete Mini-Notation Example

```javascript
n("60(3,8) [64 67]!2 <69 [72 74]*2> ~@2 [60,64,67]?0.5")
  .sound("piano")
// Uses: Euclidean, replication, angle brackets,
// rests, weight, polyphony, probability
```

## Pattern Construction

### Basic Constructors

```javascript
// cat / slowcat - one per cycle
cat("e5", "b4", ["d5", "c5"]).note()
// Equivalent: "<e5 b4 [d5 c5]>"

// seq / sequence / fastcat - cram into one cycle
seq("e5", "b4", ["d5", "c5"]).note()
// Equivalent: "e5 b4 [d5 c5]"

// stack / polyrhythm - simultaneous
stack("g3", "b3", ["e4", "d4"]).note()
// Equivalent: "g3,b3,[e4,d4]"

// Chained form
s("hh*4").stack(note("c4(5,8)"))
```

### Weighted Concatenation

```javascript
// stepcat - proportional steps
stepcat([3,"e3"], [1, "g3"]).note()
// Equivalent: "e3@3 g3"

stepcat("bd sd cp", "hh hh").sound()
// Infers steps from pattern length

// arrange - multi-cycle patterns
arrange(
  [4, "<c a f e>(3,8)"],
  [2, "<g a>(5,8)"]
).note()
```

### Polymeter

```javascript
polymeter("c eb g", "c2 g2").note()
// First pattern repeats 2x, second 3x to fit LCM=6
// Equivalent: "{c eb g, c2 g2}%6"

polymeterSteps(2, ["c", "d", "e", "f"]).note()
// 2 steps per cycle
```

## Time and Rhythm Operations

### Speed Control

```javascript
// fast - speed up by factor
s("bd hh sd hh").fast(2)
// Mini-notation: "[bd hh sd hh]*2"

// slow - slow down by factor
s("bd hh sd hh").slow(2)
// Mini-notation: "[bd hh sd hh]/2"

// Accepts patterns
note("c d e f").fast("<1 2 4>")

// hurry - fast + speed (pitch shift)
note("c e g").hurry(2)
```

### Temporal Shifting

```javascript
// early - nudge pattern earlier
"bd ~".stack("hh ~".early(.1)).s()

// late - nudge pattern later
"bd ~".stack("hh ~".late(.1)).s()

// Can be patterned for micro-timing
s("hh*8").late("[0 .01]*4")  // Humanization
```

### Temporal Windowing

```javascript
// zoom - play portion over full cycle
s("bd*2 hh*3 [sd bd]*2 perc").zoom(0.25, 0.75)
// Equivalent to: s("hh*3 [sd bd]*2")

// compress - compress into timespan, leave gap
cat(
  s("bd sd").compress(.25, .75),
  s("~ bd sd ~")
)

// linger - select and repeat fraction
s("lt ht mt cp, [hh oh]*2").linger("<1 .5 .25 .125>")

// fastGap - speed up but leave gap
s("bd sd").fastGap(2)  // Compressed into first half
```

### Reversal and Rotation

```javascript
// rev - reverse pattern
note("c d e g").rev()

// palindrome - alternate forward/backward each cycle
note("c d e g").palindrome()

// iter - rotate starting position each cycle
note("0 1 2 3".scale('A minor')).iter(4)
// Cycle 1: 0 1 2 3
// Cycle 2: 1 2 3 0
// Cycle 3: 2 3 0 1
// Cycle 4: 3 0 1 2

// iterBack - reverse iteration
note("0 1 2 3".scale('A minor')).iterBack(4)
```

### Duration Control

```javascript
// clip / legato - multiply duration, cut samples
note("c a f e").s("piano").clip("<.5 1 2>")

// ply - repeat each event n times
s("bd ~ sd cp").ply("<1 2 3>")

// segment - sample continuous pattern at discrete points
note(saw.range(40,52).segment(24))
```

### Euclidean Operations

```javascript
// euclid - distribute pulses across steps
note("c3").euclid(3,8)  // Cuban tresillo
// Mini-notation: "c3(3,8)"

// euclidRot - with rotation offset
note("c3").euclidRot(3,16,14)  // Samba rhythm
// Mini-notation: "c3(3,16,14)"

// euclidLegato - hold each pulse until next
note("c3").euclidLegato(3,8)
```

### Swing and Groove

```javascript
// swingBy - delay events in second half of slices
s("hh*8").swingBy(1/3, 4)
// offset: 0=none, 0.5=half delay, 1=wrap
// subdivision: slices per cycle

// swing - shorthand (1/3 offset)
s("hh*8").swing(4)
```

### Tempo Control

```javascript
// Global tempo
setcps(1)     // 1 cycle per second
setcpm(110)   // 110 cycles per minute

// Pattern-specific tempo
s("<bd sd>,hh*2").cpm(90)  // 90 BPM

// BPM to CPS conversion:
// setcpm(bpm/bpc) where bpc = beats per cycle
setcpm(110/4)  // 4-beat cycles at 110 BPM
```

## Pattern Transformations and Combinators

### Higher-Order Functions

```javascript
// every - apply transformation every n cycles
note("c d e f").every(4, x => x.rev())

// when - conditional application
"c3 eb3 g3".when("<0 1>/2", x => x.sub(5)).note()

// lastOf / firstOf - apply at specific cycle position
note("c3 d3 e3 g3").lastOf(4, x => x.rev())
note("c3 d3 e3 g3").firstOf(4, x => x.rev())
```

### Stochastic Application

```javascript
// Probability-based transformations
s("hh*8").sometimes(x => x.speed("0.5"))      // 50%
s("hh*8").sometimesBy(.4, x => x.speed("0.5"))  // 40%

// Named probability functions
.often(fn)         // 75%
.rarely(fn)        // 25%
.almostNever(fn)   // 10%
.almostAlways(fn)  // 90%
.always(fn)        // 100%
.never(fn)         // 0%

// Cycle-level (not event-level)
s("bd,hh*8").someCyclesBy(.3, x => x.speed("0.5"))
s("bd,hh*8").someCycles(x => x.speed("0.5"))  // 50%
```

### Layering and Accumulation

```javascript
// superimpose - layer transformation on original
"<0 2 4 6>*8"
  .superimpose(x => x.add(2))
  .scale('C minor').note()

// layer - transformations without original
"<0 2 4 6>*8"
  .layer(x => x.add("0,2"))
  .scale('C minor').note()

// off - offset and layer transformation
"c3 eb3 g3".off(1/8, x => x.add(7)).note()
n("0 [4 <3 2>] <2 3> [~ 1]")
  .off(1/16, x => x.add(4))
  .off(1/8, x => x.add(7))

// echo - repeats with velocity decay
s("bd sd").echo(3, 1/6, .8)

// echoWith - custom function each iteration
"<0 [2 4]>"
  .echoWith(4, 1/8, (p,n) => p.add(n*2))
  .scale("C:minor").note()
```

### Structural Transformations

```javascript
// chunk - divide into n parts, apply per cycle
"0 1 2 3".chunk(4, x => x.add(7)).scale("A:minor").note()

// chunkBack - reverse order
"0 1 2 3".chunkBack(4, x => x.add(7)).scale("A:minor").note()

// fastChunk - source pattern doesn't repeat
"<0 8> 1 2 3 4 5 6 7"
  .fastChunk(4, x => x.color('red')).slow(2)
  .scale("C2:major").note()

// inside - apply transformation inside slower cycle
"0 1 2 3 4 3 2 1".inside(4, rev).scale('C major').note()
// Equivalent: .slow(4).rev().fast(4)

// outside - apply transformation outside faster cycle
"<[0 1] 2 [3 4] 5>".outside(4, rev).scale('C major').note()
// Equivalent: .fast(4).rev().slow(4)
```

### Masking and Filtering

```javascript
// struct - apply structure to pattern
note("c,eb,g")
  .struct("x ~ x ~ ~ x ~ x ~ ~ ~ x ~ x ~ ~")
  .slow(2)

// mask - silence when mask is 0 or "~"
note("c [eb,g] d [eb,g]").mask("<1 [0 1]>")

// reset / restart - restart pattern on onsets
s("[<bd lt> sd]*2, hh*8").reset("<x@3 x(5,8)>")
s("[<bd lt> sd]*2, hh*8").restart("<x@3 x(5,8)>")
```

### Pattern Selection

```javascript
// pick - select patterns by index/name
note("<0 1 2!2 3>".pick(["g a", "e f", "f g f g", "g c d"]))
s("<a!2 [a,b] b>".pick({a: "bd(3,8)", b: "sd sd"}))

// pickRestart - restart chosen pattern when triggered
"<a@2 b@2 c@2 d@2>".pickRestart({
  a: n("0 1 2 0"),
  b: n("2 3 4 ~"),
  c: n("[4 5] [4 3] 2 0"),
  d: n("0 -3 0 ~")
}).scale("C:major").s("piano")

// squeeze - compress selected pattern into event
note(squeeze("<0@2 [1!2] 2>", ["g a", "f g f g", "g a c d"]))

// inhabit / pickSqueeze - cycles squeezed into target
"<a b [a,b]>".inhabit({a: s("bd(3,8)"), b: s("cp sd")})
```

### Arpeggiation

```javascript
// arp - select indices in stacked notes
note("<[c,eb,g]!2 [c,f,ab] [d,f,ab]>")
  .arp("0 [0,2] 1 [0,2]")

// arpWith - custom selection function
note("<[c,eb,g]!2 [c,f,ab] [d,f,ab]>")
  .arpWith(haps => haps[2])
```

### Randomness

```javascript
// degradeBy - random event removal
s("hh*8").degradeBy(0.2)  // Remove 20%
// Mini-notation: "[hh?0.2]*8"

s("hh*8").degrade()  // 50% removal

// undegradeBy - inverse degradation
s("hh*10").layer(
  x => x.degradeBy(0.2).pan(0),
  x => x.undegradeBy(0.8).pan(1)
)

// choose - random choice each event
note("c2 g2!2 d2 f1").s(choose("sine", "triangle", "bd:6"))

// wchoose - weighted random choice
note("c2 g2!2 d2 f1")
  .s(wchoose(["sine",10], ["triangle",1], ["bd:6",1]))

// chooseCycles / randcat - random per cycle
chooseCycles("bd", "hh", "sd").s().fast(8)
// Mini-notation: s("bd | hh | sd").fast(8)

// wchooseCycles - weighted cycle choice
wchooseCycles(["bd(3,8)",5], ["hh hh hh",3]).fast(4).s()
```

### Value Modifiers

```javascript
// Arithmetic operations
n("0 2 4".add("<0 3 4 0>")).scale("C:major")  // Transposition
note("c3 e3 g3".add("<0 5 7 0>"))  // Transpose notes
n("0 2 4".sub("<0 1 2 3>")).scale("C4:minor")  // Descending
"<1 1.5 2>*4".mul(150).freq()  // Multiplication
pattern.div(2)  // Division

// Rounding
pattern.round()  // Nearest integer
pattern.floor()  // Floor
pattern.ceil()   // Ceiling

// Range mapping
sine.range(100, 2000)    // Map 0-1 to range
sine.rangex(100, 2000)   // Exponential curve
sine2.range2(100, 2000)  // Map -1 to 1 to range
```

### Stereo Operations

```javascript
// jux - apply function only to right channel
s("lt ht mt ht hh").jux(rev)

// juxBy - adjustable stereo width (0=mono, 1=full)
s("bd lt [~ ht] mt cp ~ bd hh").juxBy("<0 .5 1>/2", rev)

// pan - stereo position (0=left, 1=right)
s("[bd hh]*2").pan("<.5 1 .5 0>")
s("bd rim sd rim bd ~ cp rim").pan(sine.slow(2))
```

### Looping

```javascript
// ribbon - loop pattern slice at offset for cycles
note("<c d e f>").ribbon(1, 2)
n(irand(8).segment(4)).scale("c:pentatonic").ribbon(1337, 2)
```

## Audio Effects and Sound Design

### Filters

```javascript
// Low-pass filter (cutoff: 0-20000 Hz)
s("bd sd,hh*8").lpf("<4000 2000 1000 500>")
// Aliases: cutoff, ctf, lp

// With Q-factor (resonance: 0-50)
s("bd*16").lpf("1000:0 1000:10 1000:20 1000:30")
s("bd sd,hh*8").lpf(2000).lpq("<0 10 20 30>")
// Aliases: lpq, resonance

// High-pass filter
s("bd sd,hh*8").hpf("<4000 2000 1000 500>")
s("bd sd,hh*8").hpf(2000).hpq("<0 10 20 30>")
// Aliases: hp, hcutoff, hresonance

// Band-pass filter
s("bd sd,hh*6").bpf("<1000 2000 4000 8000>")
s("bd sd").bpf(500).bpq("<0 1 2 3>")
// Aliases: bandf, bp, bandq

// Filter type selection (12db, ladder, 24db)
note("{f g g c d a a#}%8").s("sawtooth")
  .lpenv(4).lpf(500).ftype("<0 1 2>").lpq(1)

note("c f g g a c d4").fast(2)
  .sound('sawtooth')
  .lpf(200).ftype("<ladder 12db 24db>")

// Vowel formant filter
note("[c2 <eb2 <g2 g1>>]*2").s('sawtooth')
  .vowel("<a e i <o u>>")
// Vowels: a e i o u ae aa oe ue y uh un en an on
```

### Filter Envelopes

```javascript
// Each filter type has ADSR envelope control
note("[c eb g <f bb>](3,8,<0 1>)".sub(12))
  .s("sawtooth")
  .lpf(sine.range(300,2000).slow(16))  // Cutoff
  .lpq(sine.range(2,10).slow(32))      // Resonance
  .lpa(0.005)     // Attack
  .lpd(.02)       // Decay
  .lps(.5)        // Sustain (0-1)
  .lpr(.1)        // Release
  .lpenv(4)       // Envelope depth (can be negative)
  .ftype('24db')

// High-pass envelope: hpa, hpd, hps, hpr, hpenv
// Band-pass envelope: bpa, bpd, bps, bpr, bpenv
```

### Amplitude Envelope (ADSR)

```javascript
// Individual parameters (time in seconds, sustain 0-1)
note("c3 e3 f3 g3")
  .attack("<0 .1 .5>")      // Time to peak
  .decay("<.1 .2 .3 .4>")   // Time to sustain
  .sustain("<0 .1 .4 .6 1>")  // Sustain level
  .release("<0 .1 .4 .6 1>/2")  // Release time

// Combined ADSR
note("[c3 bb2 f3 eb3]*2").sound("sawtooth")
  .lpf(600)
  .adsr(".1:.1:.5:.2")
```

### Pitch Envelope

```javascript
// Pitch modulation envelope (chiptune/percussive sounds)
n("<-4,0 5 2 1>*<2!3 4>")
  .scale("<C F>/8:pentatonic")
  .s("gm_electric_guitar_jazz")
  .penv("<.5 0 7 -2>*2")  // Modulation in semitones
  .patt(.02)              // Attack time
  .pdec(.1)               // Decay time
  .prel(.1)               // Release time
  .pcurve("<0 1>")        // 0=linear, 1=exponential
  .panchor("<0 .5 1>")    // Anchor point
```

### Waveshaping and Distortion

```javascript
// Distortion (0-10+, gets loud!)
s("bd sd,hh*8").distort("<0 2 3 10:.5>")

// With postgain (second parameter)
note("d1!8").s("sine")
  .penv(36).pdecay(.12)
  .distort("8:.4")

// Bit crusher (1=severe, 16=minimal)
s("<bd sd>,hh*3").fast(2).crush("<16 8 7 6 5 4 3 2>")

// Coarse (sample rate reduction, Chrome-only)
s("bd sd,hh*8").coarse("<1 4 8 16 32>")
```

### Delay (Global Effect)

```javascript
// Basic delay (level: 0-1)
s("bd bd").delay("<0 .25 .5 1>")

// With time and feedback in mininotation
s("bd bd").delay("0.65:0.25:0.9 0.65:0.125:0.7")

// Separate parameters
s("bd bd")
  .delay(.25)
  .delaytime("<.125 .25 .5 1>")
  .delayfeedback("<.25 .5 .75>")  // WARNING: >=1 infinite
// Aliases: delayt, dt / delayfb, dfb
```

### Reverb (Global Effect)

```javascript
// Basic reverb (level: 0-1)
s("bd sd [~ bd] sd").room("<0 .2 .4 .6 .8 1>")

// With room size in mininotation
s("bd sd [~ bd] sd").room("<0.9:1 0.9:4>")

// Room parameters (recalculated when changed)
s("bd sd [~ bd] sd")
  .room(.8)
  .rsize(4)           // Size: 0-10
  .rfade(4)           // Fade time in seconds
  .rlp(5000)          // Lowpass: 0-20000 Hz
  .rdim(400)          // Lowpass at -60dB: 0-20000 Hz

// Custom impulse response
s("bd sd [~ bd] sd")
  .room(.8)
  .ir("<shaker_large:0 shaker_large:2>")
```

### Phaser

```javascript
n(run(8)).scale("D:pentatonic").s("sawtooth")
  .release(0.5)
  .phaser("<1 2 4 8>")      // Speed of modulation
  .phaserdepth("<0 .5 .75 1>")      // Depth: 0-1, default 0.75
  .phasercenter("<800 2000 4000>")  // Center Hz, default 1000
  .phasersweep("<800 2000 4000>")   // Sweep: 0-4000, default 2000
```

### Tremolo (Amplitude Modulation)

```javascript
note("d d d# d".fast(4)).s("supersaw")
  .tremolosync("4")              // Speed in cycles
  .tremolodepth("<1 2 .7>")      // Depth
  .tremoloskew("<.5 0 1>")       // Shape: 0-1
  .tremolophase("<0 .25 .66>")   // Phase offset in cycles
  .tremoloshape("<sine tri square>")  // Shape type
```

### Dynamics

```javascript
// Gain (exponential multiplier)
s("hh*8").gain(".4!2 1 .4!2 1 .4 1").fast(2)

// Velocity (0-1, multiplied with gain)
s("hh*8")
  .gain(".4!2 1 .4!2 1 .4 1")
  .velocity(".4 1")

// Compressor (format: "threshold:ratio:knee:attack:release")
s("bd sd [~ bd] sd,hh*8")
  .compressor("-20:20:10:.002:.02")

// Postgain (applied after all effects)
.postgain(1.5)
```

### Sample Manipulation

```javascript
// Begin/End (0-1, proportion of sample)
samples({ rave: 'rave/AREUREADY.wav' }, 'github:tidalcycles/dirt-samples')
s("rave").begin("<0 .25 .5 .75>").fast(2)
s("bd*2,oh*4").end("<.1 .2 .5 1>").fast(2)

// Speed (playback rate, negative = reverse)
s("bd*6").speed("1 2 4 1 -2 -4")
speed("1 1.5*2 [2 1.1]").s("piano").clip(1)

// Looping
s("casio").loop(1)
s("space").loop(1)
  .loopBegin("<0 .125 .25>")
  .loopEnd("<1 .75 .5 .25>")

// Wavetables (samples starting with "wt_" auto-loop)
samples('github:bubobubobubobubo/dough-waveforms')
note("c eb g bb").s("wt_dbass").clip(2)

// Slicing and chopping
samples('github:tidalcycles/dirt-samples')
s("breaks165")
  .slice(8, "0 1 <2 2*2> 3 [4 0] 5 6 7".every(3, rev))
  .slow(0.75)

// Splice (adjusts speed to match duration)
s("breaks165")
  .splice(8, "0 1 [2 3 0]@2 3 0@2 7")

// Striate (progressive portions)
s("numbers:0 numbers:1 numbers:2").striate(6).slow(3)

// Duration control
note("c a f e").s("piano").clip("<.5 1 2>")  // Clip/legato
s("rhodes").loopAt(2)  // Fit to N cycles
s("rhodes/2").fit()    // Fit to event duration

// Cut groups (stop previous in group)
s("[oh hh]*4").cut(1)
```

### Synthesis

```javascript
// Basic oscillators (sine, sawtooth, square, triangle)
note("c2 <eb2 <g2 g1>>".fast(2))
  .sound("<sawtooth square triangle sine>")

// Default is triangle if only note() used
note("c2 e2 g2")

// Limiting harmonics (additive synthesis)
note("c2 <eb2 <g2 g1>>".fast(2))
  .sound("sawtooth")
  .n("<32 16 8 4>")  // Number of harmonic partials

// Noise oscillators (white, pink, brown, crackle)
sound("<white pink brown>")
note("c3").noise("<0.1 0.25 0.5>")
s("crackle*4").density("<0.01 0.04 0.2 0.5>".slow(2))

// Vibrato
note("a e").vib("<.5 1 2 4 8 16>")  // Frequency in Hz
note("a e").vib("<.5 1 2 4 8 16>:12")  // With depth
note("a e").vib(4).vibmod("<.25 .5 1 2 12>")  // Depth separately

// FM synthesis
note("c e g b g e")
  .fm("<0 1 2 8 32>")           // Modulation index
  .fmh("<1 2 1.5 1.61>")        // Harmonicity ratio
  .fmattack("<0 .05 .1 .2>")    // FM envelope attack
  .fmdecay("<.01 .05 .1 .2>")   // FM envelope decay
  .fmsustain("<1 .75 .5 0>")    // FM envelope sustain
  .fmenv("<exp lin>")           // Envelope curve
```

## Signals and Continuous Patterns

Signals are continuous patterns with infinite temporal resolution.

### Basic Signals

```javascript
// Unipolar (0 to 1)
sine, cosine, saw, tri, square, rand, perlin

// Bipolar (-1 to 1)
sine2, cosine2, saw2, tri2, square2, rand2

// Integer random
irand(n)  // Random integers 0 to n-1
```

### Signal Transformations

```javascript
// Range mapping
s("[bd sd]*2,hh*8").cutoff(sine.range(500,4000))
s("[bd sd]*2,hh*8").cutoff(sine.rangex(500,4000))  // Exponential

// Bipolar range
s("[bd sd]*2,hh*8").cutoff(sine2.range2(500,4000))

// Temporal modulation
note("<[c2 c3]*4 [bb1 bb2]*4>")
  .sound("sawtooth")
  .lpf(sine.range(100, 2000).slow(4))

// Perlin noise for smooth random values
s("bd sd,hh*4").cutoff(perlin.range(500,2000))

// Segment signal at discrete points
note("c e g b").lpf(tri.range(100, 5000).segment(16))
```

### Signal Usage Examples

```javascript
// Complex filter modulation
note("[c eb g <f bb>](3,8,<0 1>)".sub(12))
  .s("sawtooth/64")
  .lpf(sine.range(300,2000).slow(16))
  .lpa(0.005)
  .lpd(perlin.range(.02,.2))
  .lps(perlin.range(0,.5).slow(3))
  .lpenv(perlin.range(1,8).slow(2))

// Generative melody
note(saw.range(0,15).segment(8).scale("C:minor"))

// Random cutoff sweep
s("bd*4,hh*8").cutoff(perlin.range(500, 8000))
```

## Pattern Alignment Strategies

When combining patterns with different structures, alignment strategies control how values interact:

```javascript
// Default (.in) - right values applied INTO left structure
'0 [1 2] 3'.add('10 20')  // '10 [11 12] 23'

// .out - left values applied OUT TO right structure
'0 1 2'.add.out('10 20')

// .mix - structures combined, events at intersections
'0 1 2'.add.mix('10 20')

// .squeeze - right cycles squeezed into left events
"0 1 2".add.squeeze("10 20")
// Equivalent: "[10 20] [11 21] [12 22]"

// .squeezeout - left cycles squeezed into right events
"0 1 2".add.squeezeout("10 20")
// Equivalent: "[10 11 12] [20 21 22]"

// .reset - right cycles truncated to fit left events
"0 1 2 3 4 5 6 7".add.reset("10 [20 30]")
// Equivalent: "10 11 12 13 20 21 30 31"

// .restart - like reset but from cycle 0
"0 1 2 3".add.restart("10 20")
```

## Practical Composition Examples

### Layered Techno Pattern

```javascript
samples({
  bd: ['bd/BT0AADA.wav','bd/BT0AAD0.wav'],
  sd: ['sd/rytm-01-classic.wav','sd/rytm-00-hard.wav'],
  hh: ['hh27/000_hh27closedhh.wav']
}, 'github:tidalcycles/dirt-samples');

stack(
  // Drums with random variation
  s("bd,[~ <sd!3 sd(3,4,2)>],hh*8")
    .speed(perlin.range(.7,.9)),

  // Bassline with octave jumps and detuning
  "<a1 b1*2 a1(3,8) e2>"
    .off(1/8, x => x.add(12).degradeBy(.5))
    .add(perlin.range(0,.5))
    .superimpose(add(.05))
    .note()
    .decay(.15).sustain(0)
    .s('sawtooth')
    .gain(.4)
    .cutoff(sine.slow(7).range(300,5000)),

  // Chord progression with voicings
  "<Am7!3 <Em7 E7b13 Em7 Ebm7b5>>".voicings('lefthand')
    .superimpose(x => x.add(.04))
    .add(perlin.range(0,.5))
    .note()
    .s('sawtooth')
    .cutoff(1000).lpenv(3)
)
```

### Algorithmic Acid Pattern

```javascript
note("[<g1 f1>/8](<3 5>,8)")
  .clip(perlin.range(.15,1.5))
  .release(.1)
  .s("sawtooth")
  .lpf(sine.range(400,800).slow(16))
  .lpq(cosine.range(6,14).slow(3))
  .lpenv(sine.mul(4).slow(4))
  .lpd(.2).lpa(.02)
  .ftype('24db')
  .rarely(add(note(12)))
  .room(.2).shape(.3)
  .superimpose(x => x.add(note(12)).delay(.5).bpf(1000))
```

### Polyrhythmic Drums

```javascript
stack(
  s("bd(3,8)"),
  s("sd(5,8,2)"),
  s("hh*8").speed(perlin.range(.9,1.1)),
  s("metal(7,16)").gain(.5)
).cpm(130)
```

### Generative Melody with Conditional Transformations

```javascript
note("<0 2 4 6>*8")
  .scale("C:minor")
  .euclid(5,8)
  .fast("<1 2 4>")
  .every(4, rev)
  .sometimes(add(12))
  .off(1/8, x => x.add(7).degradeBy(.3))
  .s("sawtooth")
  .lpf(sine.range(300,2000).slow(8))
  .room(.3)
```

### Phasing Pattern

```javascript
note("<C D G A Bb D C A G D Bb A>*[6,6.1]")
  .scale("C:major")
  .s("sine")
  .gain(.5)
```

### Complex Rhythmic Transformation

```javascript
"0 1 2 3 4 3 2 1"
  .inside(4, rev)
  .euclid(3,8)
  .iter(4)
  .scale('C major')
  .note()
  .s("triangle")
  .jux(rev)
  .room(.5)
```

## Key Functional Programming Patterns

1. **Immutability**: Patterns never mutate; transformations return new patterns
2. **Composition**: Build complex patterns from simple functions via chaining
3. **Currying**: Functions return new functions for flexible application
4. **Higher-order functions**: Functions that accept/return functions (jux, off, every, etc.)
5. **Pipelining**: Chain operations fluently with dot notation
6. **Pure functions**: No side effects, same input → same output
7. **Lazy evaluation**: Patterns computed only when queried
8. **Functor structure**: Patterns form a functor with `.fmap()` semantics
9. **Monadic operations**: `.bind()` / `.join()` for pattern-of-patterns

## Lambda Functions and Combinators

Arrow functions essential for transformations:

```javascript
// Basic lambda
.off(1/8, x => x.add(7))

// Multiple transformations
.layer(
  x => x.s("sawtooth").vib(4),
  x => x.s("square").add(note(12))
)

// With index parameter
.echoWith(4, 1/8, (p, n) => p.add(n*2))

// Composition
const transform = x => x.fast(2).rev().add(7)
pattern.every(4, transform)
```

## Best Practices

1. **Use lambda functions** for inline transformations
2. **Chain methods** for readable pipelines
3. **Compose reusable** transformation functions
4. **Leverage signals** for continuous modulation
5. **Combine patterns** with stack/layer for polyphony
6. **Apply probability** for variation and evolution
7. **Use alignment modes** to control pattern interaction
8. **Segment signals** when discrete events needed
9. **Pattern all parameters** for dynamic variation
10. **Test in REPL** at https://strudel.cc/

## Resources

- **Documentation**: https://strudel.cc/
- **Workshop**: https://strudel.cc/workshop/getting-started/
- **REPL**: https://strudel.cc/
- **Function Reference**: https://strudel.cc/workshop/recap/
- **GitHub (archived)**: https://github.com/tidalcycles/strudel
- **Codeberg (active)**: https://codeberg.org/uzu/strudel
- **TypeScript Defs**: https://github.com/mnvr/strudel-ts
- **Discord**: https://discord.com/invite/HGEdXmRkzT
