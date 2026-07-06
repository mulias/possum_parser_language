Sweep releases dead holders' child handles. X is wrapped, the wrapper is
dropped, and the large string repeat crosses the GC threshold; after a
sweep X is unique again, so the final merge extends it in place instead
of copying — one fewer dyn created, and gc runs is nonzero.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> X & ("" $ [X]) & ("" $ ("y" * 1200000)) & ("" $ (X + [2]))' -i 'aa'
  [1, 1, 2]
  ===== memory report =====
  dyns created:      7
  dyns live:         5 (string 0, array 5, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 2, shared 0, immortal 3
  merges:            1199999 in place, 1 copied
  inserts:           1 in place, 0 copied
  mutable constants: 0 reused, 1 copied
  closures:          0 reused, 0 created
  strings interned:  530
  strings size:      5536 chars
  bytes in use:      920

A wrapper built and dropped inside a failed Or alternative: the report's
own collection sweeps the wrapper, so the returned X reports unique
rather than shared.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> X & ((("" $ [X]) & "x") | ("" $ X))' -i 'aa'
  [1, 1]
  ===== memory report =====
  dyns created:      5
  dyns live:         4 (string 0, array 4, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 2, shared 0, immortal 2
  merges:            0 in place, 1 copied
  inserts:           1 in place, 0 copied
  mutable constants: 0 reused, 1 copied
  closures:          0 reused, 0 created
  strings interned:  529
  strings size:      5534 chars
  bytes in use:      736
