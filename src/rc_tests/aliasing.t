Sharing forces a copy exactly where needed. A is a runtime-built array
also read by the second Or alternative, so the first alternative's merge
must copy; after the first alternative fails at "x", the second returns
the unmutated A.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> A & ((("" $ (A + [2])) -> B & "x") | ("" $ A))' -i 'aa'
  [1, 1]
  ===== memory report =====
  dyns created:      5
  dyns live:         3 (string 0, array 3, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 2
  merges:            0 in place, 2 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  husks:             1 parked, 0 reused
  strings interned:  9
  strings size:      25 chars
  bytes in use:      552

When the first alternative succeeds, the copy is the fresh result and A
dies unread in its slot.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> A & (("" $ (A + [2])) | ("" $ A))' -i 'aa'
  [1, 1, 2]
  ===== memory report =====
  dyns created:      5
  dyns live:         3 (string 0, array 3, object 0, function 0, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 2
  merges:            0 in place, 2 copied
  inserts:           0 in place, 0 copied
  mutable constants: 0 reused, 0 copied
  closures:          0 reused, 0 created
  husks:             1 parked, 0 reused
  strings interned:  8
  strings size:      23 chars
  bytes in use:      552
