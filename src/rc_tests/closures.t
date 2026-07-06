Closure reuse in a repeat loop: array_sep's compound argument
`tuple1(sep > elem)` is re-created every iteration, and each prior
closure is fully consumed by then, so the module cache slot holds the
only handle and the allocation is reused. With fast paths disabled every
iteration allocates a fresh closure.

  $ PRINT_MEMORY_REPORT=true possum -p 'array_sep(word, ",")' -i 'ab,cd,ef,gh,ij'
  ["ab", "cd", "ef", "gh", "ij"]
  ===== memory report =====
  dyns created:      15
  dyns live:         13 (string 0, array 3, object 0, function 9, native 0, closure 1)
  live ref counts:   unique 3, shared 0, immortal 10
  merges:            4 in place, 0 copied
  inserts:           5 in place, 0 copied
  mutable constants: 2 reused, 3 copied
  closures:          4 reused, 1 created
  husks:             1 parked, 0 reused
  strings interned:  26
  strings size:      107 chars
  bytes in use:      1648

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p 'array_sep(word, ",")' -i 'ab,cd,ef,gh,ij'
  ["ab", "cd", "ef", "gh", "ij"]
  ===== memory report =====
  dyns created:      25
  dyns live:         11 (string 0, array 2, object 0, function 9, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 10
  merges:            0 in place, 4 copied
  inserts:           0 in place, 5 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  husks:             0 parked, 0 reused
  strings interned:  26
  strings size:      107 chars
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
  dyns created:      82
  dyns live:         78 (string 0, array 4, object 5, function 62, native 2, closure 5)
  live ref counts:   unique 9, shared 1, immortal 68
  merges:            2 in place, 0 copied
  inserts:           6 in place, 0 copied
  mutable constants: 0 reused, 6 copied
  closures:          4 reused, 7 created
  husks:             1 parked, 0 reused
  strings interned:  122
  strings size:      824 chars
  bytes in use:      9232

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p 'json' -i '[{"a": 1}, {"b": 2}, {"c": 3}]'
  [
    {"a": 1},
    {"b": 2},
    {"c": 3}
  ]
  ===== memory report =====
  dyns created:      88
  dyns live:         72 (string 0, array 3, object 5, function 62, native 2, closure 0)
  live ref counts:   unique 4, shared 0, immortal 68
  merges:            0 in place, 2 copied
  inserts:           0 in place, 6 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  husks:             0 parked, 0 reused
  strings interned:  122
  strings size:      824 chars
  bytes in use:      8608
