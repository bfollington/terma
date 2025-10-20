// Amen break-style pattern with slicing

samples('github:tidalcycles/dirt-samples')

s("breaks165")
  .slice(8, "0 1 <2 2*2> 3 [4 0] 5 6 7".every(3, rev))
  .slow(0.75)
  .sometimes(x => x.speed("<1 0.5 2>"))  // Occasional speed changes
  .room(.2)
  .hpf(100)                              // Clean up low end
  .gain(.7)
