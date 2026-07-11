Parsing the full input uses an input substring, no dynamic string allocation.

  $ PRINT_MEMORY_REPORT=true possum -p 'f ; f = "a" + (f | "")' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  ===== memory report =====
  dyns created:      2
  dyns live:         1 (string 0, array 0, object 0, function 1, native 0, closure 0)
  live ref counts:   unique 0, shared 0, immortal 1
  merges:            0 in place, 0 copied
  inserts:           0 in place, 0 copied
  husks:             0 parked, 0 reused
  strings interned:  8
  strings size:      23 chars
  bytes in use:      112

Right-built strings: each recursion level prepends a value segment onto
the unique rope accumulator in place. No bytes are copied until the
final print flattens the rope once; before ropes this shape was
quadratic (every level copied the whole suffix).

  $ PRINT_MEMORY_REPORT=true possum -p 'f ; f = ("a" $ "b") + (f | "")' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  ===== memory report =====
  dyns created:      3
  dyns live:         2 (string 1, array 0, object 0, function 1, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 1
  merges:            52 in place, 0 copied
  inserts:           0 in place, 0 copied
  husks:             0 parked, 0 reused
  strings interned:  9
  strings size:      25 chars
  bytes in use:      792

With fast paths disabled every level copies the whole suffix again:
one string allocation per level instead of one rope total.

  $ PRINT_MEMORY_REPORT=true DISABLE_RC_FAST_PATHS=true possum -p 'f ; f = ("a" $ "b") + (f | "")' -i 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
  "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  ===== memory report =====
  dyns created:      55
  dyns live:         2 (string 1, array 0, object 0, function 1, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 1
  merges:            0 in place, 52 copied
  inserts:           0 in place, 0 copied
  husks:             0 parked, 0 reused
  strings interned:  9
  strings size:      25 chars
  bytes in use:      238

Each iteration builds a fresh rope from the bound char and a value
string, and the accumulator merge splices and consumes it: the rope
husk parks and the next iteration's rope creation takes it back, so
one rope allocation cycles through the whole loop.

  $ PRINT_MEMORY_REPORT=true possum -p 'f * 8 ; f = char -> C $ (C + ",")' -i 'abcdefgh'
  "a,b,c,d,e,f,g,h,"
  ===== memory report =====
  dyns created:      5
  dyns live:         3 (string 1, array 0, object 0, function 2, native 0, closure 0)
  live ref counts:   unique 1, shared 0, immortal 2
  merges:            7 in place, 0 copied
  inserts:           0 in place, 0 copied
  husks:             7 parked, 6 reused
  strings interned:  11
  strings size:      32 chars
  bytes in use:      424
