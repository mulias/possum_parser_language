Closure reuse in a repeat loop: array_sep's compound argument
`tuple1(sep > elem)` is re-created every iteration, and each prior
closure is fully consumed by then, so its parked husk serves the next
creation. With fast paths disabled every iteration allocates a fresh
closure.

  $ PRINT_MEMORY_REPORT=true possum -p 'array_sep(word, ",")' -i 'ab,cd,ef,gh,ij'
  ["ab", "cd", "ef", "gh", "ij"]
  ===== memory report =====
  dyns created:      15
  dyns live:         11 (string 0, array 2, object 0, function 9, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 10
  merges:            4 in place, 0 copied
  inserts:           5 in place, 0 copied
  husks:             9 parked, 6 reused
  strings interned:  26
  strings size:      106 chars
  bytes in use:      1376

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p 'array_sep(word, ",")' -i 'ab,cd,ef,gh,ij'
  ["ab", "cd", "ef", "gh", "ij"]
  ===== memory report =====
  dyns created:      25
  dyns live:         11 (string 0, array 2, object 0, function 9, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 10
  merges:            0 in place, 4 copied
  inserts:           0 in place, 5 copied
  husks:             0 parked, 0 reused
  strings interned:  26
  strings size:      106 chars
  bytes in use:      1376

Object closures: object_sep itself takes plain-variable arguments and
allocates no closures; the closures come from maybe_object_sep's compound
arguments, once per object. Parsing repeated objects consumes each
object's closures before the next object starts, so they reuse from the
second object on.

  $ PRINT_MEMORY_REPORT=true possum -p 'json' -i '[{"a": 1}, {"b": 2}, {"c": 3}]'
  [
    {"a": 1},
    {"b": 2},
    {"c": 3}
  ]
  ===== memory report =====
  dyns created:      83
  dyns live:         73 (string 0, array 3, object 5, function 63, native 2, closure 0)
  live ref counts:   unique 4, shared 0, immortal 69
  merges:            2 in place, 0 copied
  inserts:           6 in place, 0 copied
  husks:             9 parked, 4 reused
  strings interned:  114
  strings size:      738 chars
  bytes in use:      8720

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p 'json' -i '[{"a": 1}, {"b": 2}, {"c": 3}]'
  [
    {"a": 1},
    {"b": 2},
    {"c": 3}
  ]
  ===== memory report =====
  dyns created:      89
  dyns live:         73 (string 0, array 3, object 5, function 63, native 2, closure 0)
  live ref counts:   unique 4, shared 0, immortal 69
  merges:            0 in place, 2 copied
  inserts:           0 in place, 6 copied
  husks:             0 parked, 0 reused
  strings interned:  114
  strings size:      738 chars
  bytes in use:      8720
