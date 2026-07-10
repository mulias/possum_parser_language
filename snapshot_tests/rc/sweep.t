Sweep releases dead holders' child handles. X is wrapped, the wrapper is
dropped, and the large string repeat crosses the GC threshold; after a
sweep X is unique again, so the final merge extends it in place instead
of copying — one fewer dyn created, and gc runs is nonzero.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> X & ("" $ [X]) & ("" $ ("y" * 1200000)) & ("" $ (X + [2]))' -i 'aa'
  [1, 1, 2]
  ===== memory report =====
  dyns created:      7
  dyns live:         4 (string 0, array 4, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 3
  merges:            1199999 in place, 1 copied
  inserts:           1 in place, 0 copied
  husks:             2 parked, 0 reused
  strings interned:  9
  strings size:      25 chars
  bytes in use:      736

A wrapper built and dropped inside a failed Or alternative: the report's
own collection sweeps the wrapper, so the returned X reports unique
rather than shared.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> X & ((("" $ [X]) & "x") | ("" $ X))' -i 'aa'
  [1, 1]
  ===== memory report =====
  dyns created:      5
  dyns live:         3 (string 0, array 3, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 2
  merges:            0 in place, 1 copied
  inserts:           1 in place, 0 copied
  husks:             1 parked, 0 reused
  strings interned:  8
  strings size:      23 chars
  bytes in use:      552
