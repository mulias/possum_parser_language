Parsing the full input uses an input substring, no dynamic string allocation.

  $ PRINT_MEMORY_REPORT=true possum -p 'f ; f = "a" + (f | "")' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  ===== memory report =====
  dyns created:      37
  dyns live:         36 (string 0, array 0, object 0, function 20, native 16, closure 0)
  live ref counts:   unique 0, shared 0, immortal 36
  merges:            0 in place, 0 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  strings interned:  528
  bytes in use:      3136

Right-built strings: each recursion level prepends a value segment onto
the unique rope accumulator in place. No bytes are copied until the
final print flattens the rope once; before ropes this shape was
quadratic (every level copied the whole suffix).

  $ PRINT_MEMORY_REPORT=true possum -p 'f ; f = ("a" $ "b") + (f | "")' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  ===== memory report =====
  dyns created:      38
  dyns live:         37 (string 1, array 0, object 0, function 20, native 16, closure 0)
  live ref counts:   unique 1, shared 0, immortal 36
  merges:            52 in place, 0 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  strings interned:  528
  bytes in use:      3824

With fast paths disabled every level copies the whole suffix again:
one string allocation per level instead of one rope total.

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p 'f ; f = ("a" $ "b") + (f | "")' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  ===== memory report =====
  dyns created:      90
  dyns live:         37 (string 1, array 0, object 0, function 20, native 16, closure 0)
  live ref counts:   unique 1, shared 0, immortal 36
  merges:            0 in place, 52 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  strings interned:  528
  bytes in use:      3270
