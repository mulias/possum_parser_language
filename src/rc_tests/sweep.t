Sweep releases dead holders' child handles. X is wrapped, the wrapper is
dropped, and the large string repeat crosses the GC threshold; after a
sweep X is unique again, so the final merge extends it in place instead
of copying — one fewer dyn created, and gc runs is nonzero.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> X & ("" $ [X]) & ("" $ ("y" * 1200000)) & ("" $ (X + [2]))' -i 'aa'
  [1, 1, 2]
  ===== memory report =====
  dyns created:      42
  dyns live:         40 (string 0, array 5, object 0, function 19, native 16, closure 0)
  live ref counts:   unique 2, shared 0, immortal 38
  merges:            1199999 in place, 1 copied
  inserts:           1 in place, 0 copied
  mutable constants: 0 reused, 1 copied
  gc runs:           4
  strings interned:  530
  bytes in use:      3944

A wrapper built and dropped inside a failed Or alternative: the report's
own collection sweeps the wrapper, so the returned X reports unique
rather than shared.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> X & ((("" $ [X]) & "x") | ("" $ X))' -i 'aa'
  [1, 1]
  ===== memory report =====
  dyns created:      40
  dyns live:         39 (string 0, array 4, object 0, function 19, native 16, closure 0)
  live ref counts:   unique 2, shared 0, immortal 37
  merges:            0 in place, 1 copied
  inserts:           1 in place, 0 copied
  mutable constants: 0 reused, 1 copied
  gc runs:           0
  strings interned:  529
  bytes in use:      3760
