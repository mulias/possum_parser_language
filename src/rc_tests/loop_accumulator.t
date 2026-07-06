Compiler-emitted repeat loop: the accumulator lives on the operand stack
(Swap-juggled, never stored to a local), stays at count 1, and merges in
place every iteration.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" $ [1]) * 40 $ "ok"' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "ok"
  ===== memory report =====
  dyns created:      3
  dyns live:         1 (string 0, array 1, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 0, shared 0, immortal 1
  merges:            38 in place, 1 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  strings interned:  8
  strings size:      24 chars
  bytes in use:      184

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p '("a" $ [1]) * 40 $ "ok"' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "ok"
  ===== memory report =====
  dyns created:      41
  dyns live:         1 (string 0, array 1, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 0, shared 0, immortal 1
  merges:            0 in place, 39 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  strings interned:  8
  strings size:      24 chars
  bytes in use:      184
