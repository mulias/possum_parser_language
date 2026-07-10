Array of runtime-built inner arrays. Each iteration builds [C, C] via
InsertAtIndex and wraps it; the outer accumulator merges in place, but the
merge retains the inner arrays, so they report as shared. Stealing children
from a consumed unique rhs would flip that split.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ [[C, C]]) * 3 $ "ok"' -i 'aaa'
  "ok"
  ===== memory report =====
  dyns created:      8
  dyns live:         2 (string 0, array 2, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 0, shared 0, immortal 2
  merges:            2 in place, 0 copied
  inserts:           9 in place, 0 copied
  husks:             3 parked, 1 reused
  strings interned:  9
  strings size:      26 chars
  bytes in use:      368

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
  dyns live:         6 (string 0, array 6, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 4, shared 0, immortal 2
  merges:            2 in place, 0 copied
  inserts:           9 in place, 0 copied
  husks:             2 parked, 1 reused
  strings interned:  8
  strings size:      23 chars
  bytes in use:      1104
