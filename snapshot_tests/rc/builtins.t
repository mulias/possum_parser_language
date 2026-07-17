Builtin- and stdlib-heavy run: the json parser exercises native code,
string templates, and container construction.

  $ PRINT_MEMORY_REPORT=true possum -p 'input(json)' -i '{"a": [1, 2], "b": "xy"}'
  {
    "a": [1, 2],
    "b": "xy"
  }
  ===== memory report =====
  dyns created:      82
  dyns live:         74 (string 0, array 3, object 3, function 66, native 2, closure 0)
  live ref counts:   unique 2, shared 0, immortal 72
  merges:            2 in place, 0 copied
  inserts:           4 in place, 0 copied
  husks:             6 parked, 1 reused
  strings interned:  116
  strings size:      757 chars
  bytes in use:      8528

A dyn string passed to a native builtin and kept live: the native
releases the popped argument handle, so U reports unique in the result
instead of carrying the popped copy's count forever.

  $ PRINT_MEMORY_REPORT=true possum -p '("" $ ("00" + "41")) -> U & ("" $ @Codepoint(U)) -> C & ("" $ [U, C])' -i ''
  ["0041", "A"]
  ===== memory report =====
  dyns created:      6
  dyns live:         5 (string 1, array 2, object 0, function 1, native 1, closure 0)
  live ref counts:   unique 2, shared 0, immortal 3
  merges:            0 in place, 0 copied
  inserts:           2 in place, 0 copied
  husks:             0 parked, 0 reused
  strings interned:  11
  strings size:      41 chars
  bytes in use:      609
