Array of runtime-built inner arrays. Each iteration builds [C, C] via
InsertAtIndex and wraps it; the outer accumulator merges in place, but the
merge retains the inner arrays, so they report as shared. Stealing children
from a consumed unique rhs would flip that split.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ [[C, C]]) * 3 $ "ok"' -i 'aaa'
  "ok"
  ===== memory report =====
  dyns created:      43
  dyns live:         39 (string 0, array 4, object 0, function 19, native 16, closure 0)
  live ref counts:   unique 2, shared 0, immortal 37
  merges:            2 in place, 0 copied
  inserts:           9 in place, 0 copied
  mutable constants: 1 reused, 5 copied
  strings interned:  529
  bytes in use:      3760

Same build with the small result kept live, to pin the unique/shared split
of the survivors.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ [[C, C]]) * 3' -i 'aaa'
  [
    ["a", "a"],
    ["a", "a"],
    ["a", "a"]
  ]
  ===== memory report =====
  dyns created:      43
  dyns live:         42 (string 0, array 7, object 0, function 19, native 16, closure 0)
  live ref counts:   unique 4, shared 1, immortal 37
  merges:            2 in place, 0 copied
  inserts:           9 in place, 0 copied
  mutable constants: 1 reused, 5 copied
  strings interned:  528
  bytes in use:      4312
