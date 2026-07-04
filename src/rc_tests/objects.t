Repeated object merges with overlapping keys and runtime values: each
in-place merge overwrites the same keys via put, which currently leaves
the replaced values overcounted. Releasing replaced values would change
these counts.

  $ PRINT_MEMORY_REPORT=true possum -p '("a" -> C $ {"k": C, "n": [C]}) * 3' -i 'aaa'
  {
    "k": "a",
    "n": ["a"]
  }
  ===== memory report =====
  dyns created:      44
  dyns live:         39 (string 0, array 2, object 2, function 19, native 16, closure 0)
  live ref counts:   unique 1, shared 1, immortal 37
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
  live ref counts:   unique 1, shared 1, immortal 37
  merges:            0 in place, 2 copied
  inserts:           0 in place, 9 copied
  gc runs:           0
  strings interned:  529
  bytes in use:      3920
