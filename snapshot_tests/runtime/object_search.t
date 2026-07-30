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

A bound key's value may itself be a structural pattern: the probed
member's value matches the sub-pattern in a nested window, binding its
variables.

  $ possum -p '(("" $ "pt") -> K) & (const({"a": 1, "pt": [3, 4]}) -> {K: [X, Y], ..._}) $ [X, Y]' -i ''
  [3, 4]

  $ possum -p '(("" $ "pt") -> K) & (const({"pt": {"x": 9}}) -> {K: {"x": X}, ..._}) $ X' -i ''
  9

A bound key whose member fails the structural value fails the match; the
probe commits to that member, so no other is tried.

  $ possum -p '(("" $ "a") -> K) & (const({"a": 5}) -> {K: [X, Y]}) $ X' -i ''
  
  Parse Failure: value {"a": 5} did not match pattern {K: [X, Y]}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:40-51:
  
  1 \xe2\x96\x8f (("" $ "a") -> K) & (const({"a": 5}) -> {K: [X, Y]}) $ X (esc)
    \xe2\x96\x8f                                         ^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A module global names a known key too: the eval bridge pushes its value
(here a zero-arity parser's result) and probes that member directly.

  $ possum -p 'Field = "" $ "email" ; ("" $ {"email": 5, "other": 9}) -> {Field: V, ..._} $ V' -i ''
  5

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

A scanning pair's value may itself be a structural pattern: the search
finds the member whose value matches the sub-pattern, binding the key and
the sub-pattern's variables together.

  $ possum -p 'const({"pt": [3, 4]}) -> {K: [X, Y]} $ [K, X, Y]' -i ''
  ["pt", 3, 4]

A member that does not fit the structural value is skipped for one that
does, even when it shares the value's outer type:

  $ possum -p 'const({"a": [1], "pt": [3, 4], "c": 5}) -> {K: [X, Y], ...R} $ [K, X, Y]' -i ''
  ["pt", 3, 4]

Tests inside the structural value narrow which member is claimed:

  $ possum -p 'const({"a": [1, 2], "pt": [3, 4]}) -> {K: [3, Y], ...R} $ [K, Y]' -i ''
  ["pt", 4]

The search fails when no member matches the structural value:

  $ possum -p 'const({"a": 1, "b": 2}) -> {K: [X, Y]}' -i ''
  
  Parse Failure: value {"a": 1, "b": 2} did not match pattern {K: [X, Y]}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:27-38:
  
  1 \xe2\x96\x8f const({"a": 1, "b": 2}) -> {K: [X, Y]} (esc)
    \xe2\x96\x8f                            ^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A structural value nests object destructures too:

  $ possum -p 'const({"a": 1, "pt": {"x": 3}}) -> {K: {"x": X}, ...R} $ [K, X]' -i ''
  ["pt", 3]

The scan binds the candidate key before matching the value, so the value
may read the key: an eval that computes from it, or an element that
compares against it. The search skips members that disagree.

  $ possum -p 'Id(Z) = "" $ Z ; ("" $ {"a": "x", "5": "5"}) -> {A: Id(A), ..._} $ A' -i ''
  "5"

  $ possum -p 'const({"q": [1, 2], "x": ["x", 9]}) -> {A: [A, B], ..._} $ [A, B]' -i ''
  ["x", 9]

A computed key is itself a sub-pattern: the scan matches each candidate
member key against it in a child window, skipping keys it rejects and
solving the key's binds. Here only "123" parses as the number the template
requires, and its value must also match.

  $ possum -p 'const({"a": 1, "123": 1}) -> {"%(0 + N)": 1, ..._} $ N' -i ''
  123

  $ possum -p 'const({"5": 9, "123": 1}) -> {"%(0 + N)": 1, ..._} $ N' -i ''
  123

A computed key can bind through a literal prefix, and the value may read
the binding:

  $ possum -p 'const({"id_7": "7"}) -> {"id_%(N)": N, ..._} $ N' -i ''
  "7"

A function-call key evaluates to a string that probes its member directly:

  $ possum -p 'X(I) = I ; const({"a": 5}) -> {X("a"): W} $ W' -i ''
  5

  $ possum -p 'X(I) = I ; const({"b": 5}) -> {X("a"): W} $ W' -i ''
  
  Parse Failure: value {"b": 5} did not match pattern {X("a"): W}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:30-41:
  
  1 \xe2\x96\x8f X(I) = I ; const({"b": 5}) -> {X("a"): W} $ W (esc)
    \xe2\x96\x8f                               ^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A call key that evaluates to a non-string is a runtime error, like a bound
key that is not a string. The probe cannot look up a non-string member.

  $ possum -p 'X(I) = I ; const({"1": 5}) -> {X(1): W} $ W' -i ''
  
  Runtime Error: Object key must be a string
  
  
  program:1:31-35:
  
  1 \xe2\x96\x8f X(I) = I ; const({"1": 5}) -> {X(1): W} $ W (esc)
    \xe2\x96\x8f                                ^^^^ (esc)
  
  [RuntimeError]
  [1]

An object key that can never be a string is rejected at goal construction.
A non-string literal:

  $ possum -p '10 -> {2: W}' -i ''
  
  Validation Error: Object key must be a string
  
  program:1:7-8:
  1 \xe2\x96\x8f 10 -> {2: W} (esc)
    \xe2\x96\x8f        ^ (esc)
  
  [InvalidPatternNode]
  [1]

A container or range key is rejected the same way:

  $ possum -p '10 -> {[1]: W}' -i ''
  
  Validation Error: Object key must be a string
  
  program:1:7-10:
  1 \xe2\x96\x8f 10 -> {[1]: W} (esc)
    \xe2\x96\x8f        ^^^ (esc)
  
  [InvalidPatternNode]
  [1]

  $ possum -p '10 -> {1..2: W}' -i ''
  
  Validation Error: Object key must be a string
  
  program:1:7-11:
  1 \xe2\x96\x8f 10 -> {1..2: W} (esc)
    \xe2\x96\x8f        ^^^^ (esc)
  
  [InvalidPatternNode]
  [1]
