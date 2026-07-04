Builtin- and stdlib-heavy run: the json parser exercises native code,
string templates, and container construction. Builtins skip decrements, so
this pins the overcounts that builtin decrements would later remove.

  $ PRINT_MEMORY_REPORT=true possum -p 'input(json)' -i '{"a": [1, 2], "b": "xy"}'
  {
    "a": [1, 2],
    "b": "xy"
  }
  ===== memory report =====
  dyns created:      113
  dyns live:         104 (string 0, array 3, object 3, function 82, native 16, closure 0)
  live ref counts:   unique 2, shared 0, immortal 102
  merges:            2 in place, 0 copied
  inserts:           0 in place, 4 copied
  gc runs:           0
  strings interned:  572
  bytes in use:      11104
