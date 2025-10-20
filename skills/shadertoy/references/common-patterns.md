# Common Shadertoy Patterns and Techniques

This document contains reusable patterns, techniques, and best practices extracted from real shader work.

## Coordinate System Setup

### Standard UV Normalization (Aspect-Corrected)
```glsl
// Centers coordinates at (0,0) with aspect ratio correction
vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / min(iResolution.y, iResolution.x);
// OR alternative form:
vec2 uv = (fragCoord * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
```

### Simple Normalized UV (0 to 1)
```glsl
vec2 uv = fragCoord / iResolution.xy;
```

### Centered UV for Effects
```glsl
vec2 uv = fragCoord / iResolution.xy - vec2(1.0, 0.5);
```

## Complex Number Mathematics

### Complex Number Operations
```glsl
// Complex multiplication
#define cx_mul(a, b) vec2(a.x*b.x - a.y*b.y, a.x*b.y + a.y*b.x)

// Complex division
#define cx_div(a, b) vec2(((a.x*b.x + a.y*b.y)/(b.x*b.x + b.y*b.y)),((a.y*b.x - a.x*b.y)/(b.x*b.x + b.y*b.y)))

// Complex sine
#define cx_sin(a) vec2(sin(a.x) * cosh(a.y), cos(a.x) * sinh(a.y))

// Complex cosine
#define cx_cos(a) vec2(cos(a.x) * cosh(a.y), -sin(a.x) * sinh(a.y))

// Complex tangent
vec2 cx_tan(vec2 a) {
    return cx_div(cx_sin(a), cx_cos(a));
}

// Complex logarithm
vec2 cx_log(vec2 a) {
    float rpart = sqrt((a.x * a.x) + (a.y * a.y));
    float ipart = atan(a.y, a.x);
    if (ipart > PI) ipart = ipart - (2.0 * PI);
    return vec2(log(rpart), ipart);
}

// Convert to polar coordinates
vec2 as_polar(vec2 z) {
    return vec2(length(z), atan(z.y, z.x));
}

// Complex power
vec2 cx_pow(vec2 v, float p) {
    vec2 z = as_polar(v);
    return pow(z.x, p) * vec2(cos(z.y * p), sin(z.y * p));
}
```

## Color Palettes

### Cosine Palette (IQ's Famous Technique)
```glsl
vec3 palette(float t, vec3 a, vec3 b, vec3 c, vec3 d) {
    return a + b * cos(2.0 * PI * (c * t + d));
}

// Example presets:
vec3 chrome(float t) {
    return palette(t,
        vec3(0.5, 0.5, 0.5),    // base
        vec3(0.5, 0.5, 0.5),    // amplitude
        vec3(1.0, 1.0, 0.5),    // frequency
        vec3(0.8, 0.90, 0.30)   // phase
    );
}
```

### Multi-Layer Palettes with Noise
```glsl
vec3 palette(float t, int layer) {
    vec3[3] a = vec3[](
        vec3(0.01, 0.012, 0.015),
        vec3(0.012, 0.01, 0.015),
        vec3(0.01, 0.013, 0.015)
    );
    vec3[3] b = vec3[](
        vec3(0.03, 0.03, 0.04),
        vec3(0.035, 0.025, 0.04),
        vec3(0.025, 0.035, 0.04)
    );

    float noise = hash21(vec2(t, float(layer))) * 0.01;
    return a[layer] + b[layer] * (0.5 + 0.5 * sin(t * PI * 2.0)) + noise;
}
```

## Hash Functions (Pseudo-Random)

### Simple 2D Hash
```glsl
float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 435.345));
    p += dot(p, p + 34.23);
    return fract(p.x * p.y);
}
```

### PCG Hash (High Quality)
```glsl
uint pcg_hash(uint seed) {
    uint state = seed * 747796405u + 2891336453u;
    uint word = ((state >> ((state >> 28u) + 4u)) ^ state) * 277803737u;
    return (word >> 22u) ^ word;
}
```

## Ray Marching

### Basic Ray Marching Loop
```glsl
vec3 render(vec3 ro, vec3 rd, float timeOffset) {
    float t = 0.0;
    float maxd = 10.0;
    vec3 col = vec3(0.0);

    for (int i = 0; i < 100; i++) {
        vec3 p = ro + rd * t;
        float d = map(p, timeOffset);

        if (d < 0.001) {
            // Hit surface - compute lighting
            vec3 n = calcNormal(p, timeOffset);
            // ... lighting calculations
            break;
        }

        if (t > maxd) break;
        t += d * 0.5;  // Step multiplier (0.5 for safety)
    }

    return col;
}
```

### Normal Calculation (Tetrahedron Method)
```glsl
vec3 calcNormal(vec3 p, float timeOffset) {
    vec2 e = vec2(0.001, 0.0);
    return normalize(vec3(
        map(p + e.xyy, timeOffset) - map(p - e.xyy, timeOffset),
        map(p + e.yxy, timeOffset) - map(p - e.yxy, timeOffset),
        map(p + e.yyx, timeOffset) - map(p - e.yyx, timeOffset)
    ));
}
```

## 3D Transformations

### Axis-Angle Rotation
```glsl
void rot(inout vec3 p, vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    mat3 m = mat3(
        oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
        oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
        oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c
    );
    p = m * p;
}
```

### 2D Rotation Matrix
```glsl
mat2 rot2d(float a) {
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c);
}

// Usage:
// p.xy *= rot2d(angle);
```

### Domain Folding (Fractal-like Repetition)
```glsl
vec3 foldRotate(vec3 p, float timeOffset) {
    float t = iTime * 0.2 + timeOffset;
    rot(p, vec3(sin(t), cos(t), 0.5), t * 0.3);

    for (int i = 0; i < 5; i++) {
        p = abs(p);  // Fold space
        rot(p, vec3(0.707, 0.707, 0.0), 0.785);
        p -= 0.5 * smoothstep(-1.0, 1.0, sin(iTime * 0.1 + timeOffset));
    }
    return p;
}
```

## Distance Fields (SDFs)

### Octahedron
```glsl
float sdOctahedron(vec3 p, float s) {
    p = abs(p);
    float m = p.x + p.y + p.z - s;
    return m * 0.57735027;
}
```

### Sphere
```glsl
float sdSphere(vec3 p, float r) {
    return length(p) - r;
}
```

### Box
```glsl
float sdBox(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}
```

## Noise Functions

### Simplex Noise 3D
```glsl
// (Full implementation in glsl-reference.md or use texture-based noise)
float snoise(vec3 v) {
    // ... simplex noise implementation
}
```

### FBM (Fractional Brownian Motion)
```glsl
float fbm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < 5; i++) {
        value += amplitude * snoise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}
```

## Post-Processing Effects

### Vignette
```glsl
float vignette(vec2 uv) {
    uv *= 1.0 - uv.yx;
    float vig = uv.x * uv.y * 15.0;
    return pow(vig, 0.25);
}
```

### Film Grain / Dithering
```glsl
// Add subtle noise to reduce banding
float dither = hash21(fragCoord + iTime) * 0.001;
finalCol += dither;
```

### Gamma Correction
```glsl
// Apply gamma correction for proper color output
finalCol = pow(finalCol, vec3(0.45));  // ~1/2.2
```

### Blur (9-tap Gaussian)
```glsl
vec3 blur9(vec2 p, vec2 resolution, vec2 direction) {
    vec3 color = vec3(0.0);
    vec2 off1 = vec2(1.3846153846) * direction;
    vec2 off2 = vec2(3.2307692308) * direction;
    color += pixel(p) * 0.2270270270;
    color += pixel(p + (off1 / resolution)) * 0.3162162162;
    color += pixel(p - (off1 / resolution)) * 0.3162162162;
    color += pixel(p + (off2 / resolution)) * 0.0702702703;
    color += pixel(p - (off2 / resolution)) * 0.0702702703;
    return color;
}
```

## Blend Modes

### Soft Light
```glsl
float softLight(float s, float d) {
    return (s < 0.5) ? d - (1.0 - 2.0 * s) * d * (1.0 - d)
                     : (d < 0.25) ? d + (2.0 * s - 1.0) * d * ((16.0 * d - 12.0) * d + 3.0)
                                  : d + (2.0 * s - 1.0) * (sqrt(d) - d);
}

vec3 softLight(vec3 s, vec3 d) {
    return vec3(softLight(s.x, d.x), softLight(s.y, d.y), softLight(s.z, d.z));
}
```

### Hard Light
```glsl
float hardLight(float s, float d) {
    return (s < 0.5) ? 2.0 * s * d : 1.0 - 2.0 * (1.0 - s) * (1.0 - d);
}
```

## Multi-Pass Rendering

### Buffer Setup Pattern
```glsl
// Buffer A (a.glsl) - Computation/generation
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    // ... compute values, store in fragColor
}

// Buffer B (b.glsl) - Temporal blending/feedback
#define BUFFER_A iChannel0
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    vec4 current = texture(BUFFER_A, uv);
    vec4 previous = texture(iChannel1, uv);  // Self-feedback
    fragColor = mix(previous, current, 0.1);  // Blend factor
}

// Main (main.glsl) - Final output
#define BUFFER_B iChannel1
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(BUFFER_B, uv);
}
```

## Time-Based Animation

### Smooth Periodic Motion
```glsl
float t = iTime * 0.2;  // Scale time
float wave = sin(t) * 0.5 + 0.5;  // 0 to 1
float smooth_wave = smoothstep(0.0, 1.0, wave);
```

### Camera Orbit
```glsl
vec3 ro = vec3(0.0, 0.0, -4.0);
vec3 rd = normalize(vec3(uv, 2.0));
rot(ro, vec3(1.0, 1.0, 0.0), iTime * 0.12);
rot(rd, vec3(1.0, 1.0, 0.0), iTime * 0.12);
```

## Performance Tips

1. **Loop Unrolling**: Use fixed iteration counts, not dynamic
2. **Early Exit**: Check distance thresholds to break ray marching early
3. **Step Multiplier**: Use `t += d * 0.5` instead of `t += d` for safety vs speed tradeoff
4. **Minimize Texture Reads**: Cache texture lookups when used multiple times
5. **Avoid Branches**: Use `mix()` and `step()` instead of `if` statements when possible
6. **Dithering**: Add small noise to reduce banding artifacts from limited precision

## Common Constants

```glsl
#define PI 3.1415926535897932384626433832795
#define TAU 6.283185307179586
#define PHI 1.618033988749895  // Golden ratio
```

## Debugging Techniques

### Visualize Distance Field
```glsl
fragColor = vec4(vec3(map(p)), 1.0);  // Bright = far, dark = near
```

### Visualize Normals
```glsl
vec3 n = calcNormal(p);
fragColor = vec4(n * 0.5 + 0.5, 1.0);  // Map -1..1 to 0..1
```

### Visualize UV Space
```glsl
fragColor = vec4(fract(uv), 0.0, 1.0);  // Shows UV tiling
```
