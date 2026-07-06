String repeat: the accumulator is unique after the first copy, so every
later merge appends in place. With fast paths disabled every merge copies,
visible as ~500 extra dyns created.

  $ PRINT_MEMORY_REPORT=true possum -p '"" $ "ab" * 500 $ "ok"' -i ''
  "ok"
  ===== memory report =====
  dyns created:      2
  dyns live:         0 (string 0, array 0, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 0, shared 0, immortal 0
  merges:            498 in place, 0 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  husks:             0 parked, 0 reused
  strings interned:  9
  strings size:      27 chars
  bytes in use:      0

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p '"" $ "ab" * 500 $ "ok"' -i ''
  "ok"
  ===== memory report =====
  dyns created:      500
  dyns live:         0 (string 0, array 0, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 0, shared 0, immortal 0
  merges:            0 in place, 498 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  husks:             0 parked, 0 reused
  strings interned:  9
  strings size:      27 chars
  bytes in use:      0

Array repeat with the result kept live: the result array survives to the
report as the only unique live dyn.

  $ PRINT_MEMORY_REPORT=true possum -p '"" $ [1] * 5' -i ''
  [1, 1, 1, 1, 1]
  ===== memory report =====
  dyns created:      3
  dyns live:         2 (string 0, array 2, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 1
  merges:            3 in place, 1 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  husks:             0 parked, 0 reused
  strings interned:  7
  strings size:      21 chars
  bytes in use:      368
