// Polyrhythmic pattern with multiple time signatures

stack(
  s("bd(3,8)"),                          // 3 against 8
  s("sd(5,8,2)"),                        // 5 against 8, offset by 2
  s("hh*8").speed(perlin.range(.9, 1.1)),
  s("metal(7,16)").gain(.5)              // 7 against 16
).cpm(130)
