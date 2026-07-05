Right-built strings: each recursion level prepends a value segment onto
the unique rope accumulator in place. No bytes are copied until the
final print flattens the rope once; before ropes this shape was
quadratic (every level copied the whole suffix).

  $ PRINT_MEMORY_REPORT=true possum -p 'int -> N $ S(N) ; S(N) = N -> ..0 $ "" | ("ab" + S(N - 1))' -i '20'
  "abababababababababababababababababababab"
  ===== memory report =====
  dyns created:      48
  dyns live:         47 (string 1, array 0, object 0, function 30, native 16, closure 0)
  live ref counts:   unique 1, shared 0, immortal 46
  merges:            19 in place, 0 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  strings interned:  534
  bytes in use:      4656

With fast paths disabled every level copies the whole suffix again:
one string allocation per level instead of one rope total.

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p 'int -> N $ S(N) ; S(N) = N -> ..0 $ "" | ("ab" + S(N - 1))' -i '20'
  "abababababababababababababababababababab"
  ===== memory report =====
  dyns created:      67
  dyns live:         47 (string 1, array 0, object 0, function 30, native 16, closure 0)
  live ref counts:   unique 1, shared 0, immortal 46
  merges:            0 in place, 19 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  strings interned:  534
  bytes in use:      4376
