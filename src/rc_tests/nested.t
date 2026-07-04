Array of runtime-built inner arrays. Each iteration builds [C, C] via
InsertAtIndex and wraps it; the outer accumulator merges in place, but the
merge retains the inner arrays, so they report as shared. Stealing children
from a consumed unique rhs would flip that split.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ [[C, C]]) * 3 $ "ok"' -i 'aaa'
  "ok"
  ===== memory report =====
  dyns created:      44
  dyns live:         37 (string 0, array 2, object 0, function 19, native 16, closure 0)
  live ref counts:   unique 0, shared 0, immortal 37
  merges:            2 in place, 0 copied
  inserts:           3 in place, 6 copied
  gc runs:           0
  strings interned:  529
  bytes in use:      3392

Same build with the small result kept live, to pin the unique/shared split
of the survivors.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ [[C, C]]) * 3' -i 'aaa'
  [
    ["a", "a"],
    ["a", "a"],
    ["a", "a"]
  ]
  ===== memory report =====
  dyns created:      44
  dyns live:         41 (string 0, array 6, object 0, function 19, native 16, closure 0)
  live ref counts:   unique 4, shared 0, immortal 37
  merges:            2 in place, 0 copied
  inserts:           3 in place, 6 copied
  gc runs:           0
  strings interned:  528
  bytes in use:      4128
