Object patterns with non-constant keys search the object for a member the
pair accepts. Every pair claims a distinct member: a search never re-matches
a member already matched by a constant-key pair or by an earlier search.

A wildcard pair must find its own member, not re-use one a constant key
already matched:

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, _: 1}' -i ''
  
  Parse Failure: value {"a": 1, "b": 2} did not match pattern {"a": 1, _: 1}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:27-41:
  
  1 \xe2\x96\x8f const({"a": 1, "b": 2}) -> {"a": 1, _: 1} (esc)
    \xe2\x96\x8f                            ^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'const({"a": 1, "b": 1}) -> {"a": 1, _: 1}' -i ''
  {"a": 1, "b": 1}

A search binds the key of the member it claims:

  $ possum -p 'const({"a": 1, "b": 1}) -> {"a": 1, K: 1} $ K' -i ''
  "b"

Constant keys are claimed no matter where the search pair appears in the
pattern:

  $ possum -p 'const({"a": 1, "c": 1}) -> {K: 1, "a": 1} $ K' -i ''
  "c"

Search pairs claim distinct members from each other:

  $ possum -p 'const({"x": 1, "y": 1}) -> {A: 1, B: 1} $ [A, B]' -i ''
  ["x", "y"]

  $ possum -p 'const({"x": 1, "y": 2}) -> {A: 1, B: 1} $ [A, B]' -i ''
  
  Parse Failure: value {"x": 1, "y": 2} did not match pattern {A: 1, B: 1}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:27-39:
  
  1 \xe2\x96\x8f const({"x": 1, "y": 2}) -> {A: 1, B: 1} $ [A, B] (esc)
    \xe2\x96\x8f                            ^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A bound key probes for its member directly, claiming it like any other
pair.

  $ possum -p '"" $ Obj.Get({"a": 1, "b": 2}, "b")' -i ''
  2

A bound key must be a string:

  $ possum -p "(('' \$ 1) -> K) & (('' \$ {\"1\": 5}) -> {K: V}) \$ V" -i ''
  
  Runtime Error: Object key must be a string
  
  
  program:1:39-40:
  
  1 \xe2\x96\x8f (('' $ 1) -> K) & (('' $ {"1": 5}) -> {K: V}) $ V (esc)
    \xe2\x96\x8f                                        ^ (esc)
  
  [RuntimeError]
  [1]

A bound key equal to a constant key cannot re-claim that member:

  $ cat > claim.possum <<'EOF'
  > input(m)
  > F(K) = {"a": 1, "x": 2} -> {"a": 1, K: _}
  > m = "" $ F("a")
  > EOF

  $ possum claim.possum -i ''
  
  Parse Failure: value {"a": 1, "x": 2} did not match pattern {"a": 1, K: _}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  expected one of:
    " " (parser `space`, stdlib/string.possum:40:2)
    "\t" (parser `space`, stdlib/string.possum:40:8)
    "\u0000A0" (parser `space`, stdlib/string.possum:40:15)
    "\u002000".."\u00200A" (parser `space`, stdlib/string.possum:40:28)
    "\u00202F" (parser `space`, stdlib/string.possum:40:53)
    "\u00205F" (parser `space`, stdlib/string.possum:40:66)
    "\u003000" (parser `space`, stdlib/string.possum:40:79)
    "\r\n" (parser `newline`, stdlib/string.possum:44:10)
    "\u00000D" (parser `newline`, stdlib/string.possum:44:31)
    "\u000085" (parser `newline`, stdlib/string.possum:44:44)
    "\u002028" (parser `newline`, stdlib/string.possum:44:57)
    "\u002029" (parser `newline`, stdlib/string.possum:44:70)
    {"a": 1, K: _} (parser `F`, claim.possum:2:27)
  [ParserFailure]
  [1]

A rest pattern collects the members no pair claimed:

  $ possum -p 'const({"a": 1, "b": 2, "c": 3}) -> {"a": 1, K: 2, ...R} $ [K, R]' -i ''
  [
    "b",
    {"c": 3}
  ]
