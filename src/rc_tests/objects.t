Repeated object merges with overlapping keys and runtime values: each
in-place merge overwrites the same keys via put, which releases the
replaced value's handle.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ {"k": C, "n": [C]}) * 3' -i 'aaa'
  {
    "k": "a",
    "n": ["a"]
  }
  ===== memory report =====
  dyns created:      8
  dyns live:         4 (string 0, array 2, object 2, function 0, native 0, closure 0)
  live ref counts:   unique 2, shared 0, immortal 2
  merges:            2 in place, 0 copied
  inserts:           9 in place, 0 copied
  husks:             2 parked, 1 reused
  strings interned:  10
  strings size:      27 chars
  bytes in use:      896

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p '("a" -> C $ {"k": C, "n": [C]}) * 3' -i 'aaa'
  {
    "k": "a",
    "n": ["a"]
  }
  ===== memory report =====
  dyns created:      14
  dyns live:         4 (string 0, array 2, object 2, function 0, native 0, closure 0)
  live ref counts:   unique 2, shared 0, immortal 2
  merges:            0 in place, 2 copied
  inserts:           0 in place, 9 copied
  husks:             0 parked, 0 reused
  strings interned:  10
  strings size:      27 chars
  bytes in use:      896

A replaced value kept live through a binding: the object merge overwrites
"n" from V to [2], releasing V's handle, so V reports unique in the final
result instead of shared.

  $ PRINT_MEMORY_REPORT=true possum -p '(("a" $ [1]) * 2) -> V & ("" $ ({"n": V} + {"n": [2]})) -> O & ("" $ [V, O])' -i 'aa'
  [
    [1, 1],
    {
      "n": [2]
    }
  ]
  ===== memory report =====
  dyns created:      10
  dyns live:         8 (string 0, array 5, object 3, function 0, native 0, closure 0)
  live ref counts:   unique 3, shared 0, immortal 5
  merges:            1 in place, 1 copied
  inserts:           4 in place, 0 copied
  husks:             1 parked, 0 reused
  strings interned:  10
  strings size:      27 chars
  bytes in use:      1712
