> This help only covers the parts of GLSL ES that are relevant for Shadertoy. For the complete specification please have a look at [GLSL ES specification](https://www.khronos.org/registry/OpenGL/specs/es/3.0/GLSL_ES_Specification_3.00.pdf)

## Language:
**Version:** `WebGL 2.0`
**Arithmetic:** `( ) + - ! * / %`
**Logical/Relatonal:** `~ < > <= >= == != && ||`
**Bit Operators:** `& ^ | << >>`
**Comments:** `// /* */`
**Types:** `void` `bool` `int` `uint` `float` `vec2` `vec3` `vec4` `bvec2` `bvec3` `bvec4` `ivec2` `ivec3` `ivec4` `uvec2` `uvec3` `uvec4` `mat2` `mat3` `mat4` `mat?x?` `sampler2D,` `sampler3D` `samplerCube`
**Format:** `float a = 1.0; int b = 1; uint i = 1U; int i = 0x1;`
**Function Parameter Qualifiers:** `[none]` `in` `out` `inout`
**Global Variable Qualifiers:** `const`
**Vector Components:** `.xyzw` `.rgba` `.stpq`
**Flow Control:** `if` `else` `for` `return` `break` `continue` `switch/case`
**Output:** `vec4 fragColor`
**Input:** `vec2 fragCoord`
**Preprocessor:** `#` `#define` `#undef` `#if` `#ifdef` `#ifndef` `#else` `#elif` `#endif` `#error` `#pragma` `#line`

## Built-in Functions:
| function | description |
| -- | -- |
| `type` [`radians`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/radians.xhtml) (`type degrees`) | degrees to radians |
| `type` [`degrees`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/degrees.xhtml) (`type radians`) | radians to degrees |
| `type` [`sin`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sin.xhtml) (`type angle`) | |
| `type` [`cos`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/cos.xhtml) (`type angle`) | |
| `type` [`tan`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/tan.xhtml) (`type angle`) | |
| `type` [`asin`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/asin.xhtml) (`type x`) | |
| `type` [`acos`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/acos.xhtml) (`type x`) | |
| `type` [`atan`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/atan.xhtml) (`type y, type x`) | |
| `type` [`atan`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/atan.xhtml) (`type y_over_x`) | |
| `type` [`sinh`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sinh.xhtml) (`type x`) | |
| `type` [`cosh`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/cosh.xhtml) (`type x`) | |
| `type` [`tanh`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/tanh.xhtml) (`type x`) | |
| `type` [`asinh`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/asinh.xhtml) (`type x`) | |
| `type` [`acosh`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/acosh.xhtml) (`type x`) | |
| `type` [`atanh`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/atanh.xhtml) (`type x`) | |
| `type` [`pow`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/pow.xhtml) (`type x, type y`) | |
| `type` [`exp`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/exp.xhtml) (`type x`) | |
| `type` [`log`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/log.xhtml) (`type x`) | |
| `type` [`exp2`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/exp2.xhtml) (`type x`) | |
| `type` [`log2`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/log2.xhtml) (`type x`) | |
| `type` [`sqrt`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sqrt.xhtml) (`type x`) | |
| `type` [`inversesqrt`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/inversesqrt.xhtml) (`type x`) | |
| `type` [`abs`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/abs.xhtml) (`type x`) | |
| `type` [`sign`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/sign.xhtml) (`type x`) | |
| `type` [`floor`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/floor.xhtml) (`type x`) | |
| `type` [`ceil`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/ceil.xhtml) (`type x`) | |
| `type` [`trunc`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/trunc.xhtml) (`type x`) | |
| `type` [`fract`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/fract.xhtml) (`type x`) | the fractional part of x. Same as `x - floor(x)`. |
| `type` [`mod`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/mod.xhtml) (`type x, float y`) | modulo |
| `type` [`modf`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/modf.xhtml) (`type x, out type i`) | |
| `type` [`min`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/min.xhtml) (`type x, type y`) | |
| `type` [`max`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/max.xhtml) (`type x, type y`) | |
| `type` [`clamp`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/clamp.xhtml) (`type x, type minV, type maxV`) | |
| `type` [`mix`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/mix.xhtml) (`type x, type y, type a`) | |
| `type` [`step`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/step.xhtml) (`type edge, type x`) | |
| `type` [`smoothstep`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/smoothstep.xhtml) (`type a, type b, type x`) | |
| `float` [`length`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/length.xhtml) (`type x`) | |
| `float` [`distance`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/distance.xhtml) (`type p0, type p1`) | |
| `float` [`dot`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/dot.xhtml) (`type x, type y`) | |
| `vec3` [`cross`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/cross.xhtml) (`vec3 x, vec3 y`) | |
| `type` [`normalize`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/normalize.xhtml) (`type x`) | |
| `type` [`faceforward`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/faceforward.xhtml) (`type N, type I, type Nref`) | |
| `type` [`reflect`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/reflect.xhtml) (`type I, type N`) | |
| `type` [`refract`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/refract.xhtml) (`type I, type N,float eta`) | |
| `float` [`determinant`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/determinant.xhtml) (`mat? m`) | |
| `mat?x?` [`outerProduct`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/outerProduct.xhtml) (`vec? c, vec? r`) | |
| `type` [`matrixCompMult`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/matrixCompMult.xhtml) (`type x, type y`) | |
| `type` [`inverse`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/inverse.xhtml) (`type inverse`) | |
| `type` [`transpose`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/transpose.xhtml) (`type inverse`) | |
| `vec4` [`texture`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/texture.xhtml) (` sampler? , vec? coord [, float bias]`) | |
| `vec4` [`textureLod`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureLod.xhtml) (` sampler, vec? coord, float lod`) | |
| `vec4` [`textureLodOffset`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureLodOffset.xhtml) (` sampler? sampler, vec? coord, float lod, ivec? offset`) | |
| `vec4` [`textureGrad`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureGrad.xhtml) (` sampler? , vec? coord, vec2 dPdx, vec2 dPdy`) | |
| `vec4 textureGradOffset sampler? , vec? coord, vec? dPdx, vec? dPdy, vec? offset)` | |
| `vec4` [`textureProj`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureProj.xhtml) (` sampler? , vec? coord [, float bias]`) | |
| `vec4` [`textureProjLod`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureProjLod.xhtml) (` sampler? , vec? coord, float lod`) | |
| `vec4` [`textureProjLodOffset`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureProjLodOffset.xhtml) (` sampler? , vec? coord, float lod, vec? offset`) | |
| `vec4` [`textureProjGrad`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureProjGrad.xhtml) (` sampler? , vec? coord, vec2 dPdx, vec2 dPdy`) | |
| `vec4` [`texelFetch`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/texelFetch.xhtml) (` sampler? , ivec? coord, int lod`) | |
| `vec4` [`texelFetchOffset`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/texelFetchOffset.xhtml) (` sampler?, ivec? coord, int lod, ivec? offset `) | |
| `ivec?` [`textureSize`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/textureSize.xhtml) (` sampler? , int lod`) | |
| `type` [`dFdx`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/dFdx.xhtml) (`type x`) | |
| `type` [`dFdy`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/dFdy.xhtml) (`type x`) | |
| `type` [`fwidth`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/fwidth.xhtml) (`type p`) |  the sum of the absolute value of derivatives in x and y |
| `type` [`isnan`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/isnan.xhtml) (`type x`) | |
| `type` [`isinf`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/isinf.xhtml) (`type x`) | |
| `float` [`intBitsToFloat`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/intBitsToFloat.xhtml) (`int v`) | |
| `uint` [`uintBitsToFloat`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/uintBitsToFloat.xhtml) (`uint v`) | |
| `int` [`floatBitsToInt`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/floatBitsToInt.xhtml) (`float v`) | |
| `uint` [`floatBitsToUint`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/floatBitsToUint.xhtml) (`float v`) | |
| `uint` [`packSnorm2x16`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/packSnorm2x16.xhtml) (`vec2 v`) | |
| `uint` [`packUnorm2x16`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/packUnorm2x16.xhtml) (`vec2 v`) | |
| `vec2` [`unpackSnorm2x16`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/unpackSnorm2x16.xhtml) (`uint p`) | |
| `vec2` [`unpackUnorm2x16`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/unpackUnorm2x16.xhtml) (`uint p`) | |
| `bvec` [`lessThan`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/lessThan.xhtml) (`type x, type y`) | |
| `bvec` [`lessThanEqual`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/lessThanEqual.xhtml) (`type x, type y`) | |
| `bvec` [`greaterThan`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/greaterThan.xhtml) (`type x, type y`) | |
| `bvec` [`greaterThanEqual`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/greaterThanEqual.xhtml) (`type x, type y`) | |
| `bvec` [`equal`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/equal.xhtml) (`type x, type y`) | |
| `bvec` [`notEqual`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/notEqual.xhtml) (`type x, type y`) | |
| `bool` [`any`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/any.xhtml) (`bvec x`) | |
| `bool` [`all`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/all.xhtml) (`bvec x`) | |
| `bvec` [`not`](https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/not.xhtml) (`bvec x`) | |

## Conversions

* Int to Float: `int(uv.x * 3.0)`

## How-to
**Use structs:** `struct myDataType { float occlusion; vec3 color; }; myDataType myData = myDataType(0.7, vec3(1.0, 2.0, 3.0));`
**Initialize arrays:** `float[] x = float[] (0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6);`
**Do conversions:** `int a = 3; float b = float(a);`
**Do component swizzling:** `vec4 a = vec4(1.0,2.0,3.0,4.0); vec4 b = a.zyyw;`
**Access matrix components:** `mat4 m; m[1] = vec4(2.0); m[0][0] = 1.0; m[2][3] = 2.0;`

> **Be careful!**

**the f suffix for floating point numbers:**  `1.0f` is illegal in GLSL. You must use `1.0`
**saturate():** `saturate(x)` doesn't exist in GLSL. Use `clamp(x,0.0,1.0)` instead
**pow/sqrt:** please don't feed `sqrt()` and `pow()` with negative numbers. Add an `abs()` or `max(0.0, x)` to the argument
**mod:** please don't do `mod(x,0.0)`. This is undefined in some platforms
**variables:** initialize your variables! Don't assume they'll be set to zero by default
**functions:** don't name your functions the same as some of your variables

## Shadertoy Inputs
| type | name | description |
| --- | --- | --- |
| `vec3`| `iResolution` | image/buffer	The viewport resolution (z is pixel aspect ratio, usually 1.0) |
| `float` | `iTime` | image/sound/buffer	Current time in seconds |
| `float` | `iTimeDelta` | image/buffer	Time it takes to render a frame, in seconds |
| `int` | `iFrame` | image/buffer	Current frame |
| `float` | `iFrameRate` | image/buffer	Number of frames rendered per second |
| `float` | `iChannelTime[4]` | image/buffer	Time for channel (if video or sound), in seconds |
| `vec3` | `iChannelResolution[4]` | image/buffer/sound	Input texture resolution for each channel |
| `vec4` | `iMouse` | image/buffer	xy = current pixel coords (if LMB is down). zw = click pixel |
| `sampler2D` | `iChannel{i}` | image/buffer/sound	Sampler for input textures i |
| `vec4` | `iDate` | image/buffer/sound	Year, month, day, time in seconds in .xyzw |
| `float` | `iSampleRate` | image/buffer/sound	The sound sample rate (typically 44100) |

## Shadertoy Outputs

#### Image shaders:
fragColor is used as output channel. It is not, for now, mandatory but recommended to leave the alpha channel to 1.0.

#### Sound shaders:
the mainSound() function returns a vec2 containing the left and right (stereo) sound channel wave data.
