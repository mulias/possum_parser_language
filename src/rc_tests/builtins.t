Builtin- and stdlib-heavy run: the json parser exercises native code,
string templates, and container construction.

  $ PRINT_MEMORY_REPORT=true possum -p 'input(json)' -i '{"a": [1, 2], "b": "xy"}'
  {
    "a": [1, 2],
    "b": "xy"
  }
  ===== memory report =====
  dyns created:      113
  dyns live:         106 (string 0, array 4, object 4, function 82, native 16, closure 0)
  live ref counts:   unique 4, shared 0, immortal 102
  merges:            2 in place, 0 copied
  inserts:           4 in place, 0 copied
  mutable constants: 0 reused, 4 copied
  strings interned:  572
  bytes in use:      11552

A dyn string passed to a native builtin and kept live: the native
releases the popped argument handle, so U reports unique in the result
instead of carrying the popped copy's count forever.

  $ PRINT_MEMORY_REPORT=true possum -p '("" $ ("00" + "41")) -> U & ("" $ @Codepoint(U)) -> C & ("" $ [U, C])' -i ''
  ["0041", "A"]
  ===== memory report =====
  dyns created:      39
  dyns live:         38 (string 1, array 2, object 0, function 19, native 16, closure 0)
  live ref counts:   unique 1, shared 1, immortal 36
  merges:            0 in place, 0 copied
  inserts:           2 in place, 0 copied
  mutable constants: 0 reused, 1 copied
  strings interned:  529
  bytes in use:      3465
