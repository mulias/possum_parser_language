Array of runtime-built inner arrays. Each iteration builds [C, C] via
InsertAtIndex and wraps it; the outer accumulator merges in place, but the
merge retains the inner arrays, so they report as shared. Stealing children
from a consumed unique rhs would flip that split.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ [[C, C]]) * 3 $ "ok"' -i 'aaa'
  "ok"
  ===== memory report =====
  dyns created:      8
  dyns live:         4 (string 0, array 4, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 2, shared 0, immortal 2
  merges:            2 in place, 0 copied
  inserts:           9 in place, 0 copied
  mutable constants: 1 reused, 5 copied
  closures:          0 reused, 0 created
  strings interned:  529
  strings size:      5535 chars
  bytes in use:      736

Same build with the small result kept live, to pin the unique/shared split
of the survivors.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ [[C, C]]) * 3' -i 'aaa'
  [
    ["a", "a"],
    ["a", "a"],
    ["a", "a"]
  ]
  ===== memory report =====
  dyns created:      8
  dyns live:         7 (string 0, array 7, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 4, shared 1, immortal 2
  merges:            2 in place, 0 copied
  inserts:           9 in place, 0 copied
  mutable constants: 1 reused, 5 copied
  closures:          0 reused, 0 created
  strings interned:  528
  strings size:      5532 chars
  bytes in use:      1288
