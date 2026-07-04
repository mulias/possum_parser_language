Repeated object merges with overlapping keys and runtime values: each
in-place merge overwrites the same keys via put, which releases the
replaced value's handle.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ {"k": C, "n": [C]}) * 3' -i 'aaa'
  {
    "k": "a",
    "n": ["a"]
  }
  ===== memory report =====
  dyns created:      44
  dyns live:         39 (string 0, array 2, object 2, function 19, native 16, closure 0)
  live ref counts:   unique 2, shared 0, immortal 37
  merges:            2 in place, 0 copied
  inserts:           3 in place, 6 copied
  gc runs:           0
  strings interned:  529
  bytes in use:      3920

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p '("a" -> C $ {"k": C, "n": [C]}) * 3' -i 'aaa'
  {
    "k": "a",
    "n": ["a"]
  }
  ===== memory report =====
  dyns created:      49
  dyns live:         39 (string 0, array 2, object 2, function 19, native 16, closure 0)
  live ref counts:   unique 2, shared 0, immortal 37
  merges:            0 in place, 2 copied
  inserts:           0 in place, 9 copied
  gc runs:           0
  strings interned:  529
  bytes in use:      3920

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
  dyns created:      45
  dyns live:         43 (string 0, array 5, object 3, function 19, native 16, closure 0)
  live ref counts:   unique 3, shared 0, immortal 40
  merges:            1 in place, 1 copied
  inserts:           1 in place, 3 copied
  gc runs:           0
  strings interned:  528
  bytes in use:      4736
