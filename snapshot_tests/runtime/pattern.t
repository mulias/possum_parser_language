  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  4

  $ possum -p '0 -> (1 + 1 + 2)' -i '0'
  
  Parse Failure: value 0 did not match pattern (1 + 1 + 2)
  
  input:1:1:
  
  1 \xe2\x96\x8f 0 (esc)
    \xe2\x96\x8f  ^ (esc)
  
  while matching parser `@main`
  
  program:1:5-16:
  
  1 \xe2\x96\x8f 0 -> (1 + 1 + 2) (esc)
    \xe2\x96\x8f      ^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '5 -> (2 + 3)' -i '5'
  5

  $ possum -p '7 -> (2 + 3)' -i '7'
  
  Parse Failure: value 7 did not match pattern (2 + 3)
  
  input:1:1:
  
  1 \xe2\x96\x8f 7 (esc)
    \xe2\x96\x8f  ^ (esc)
  
  while matching parser `@main`
  
  program:1:5-12:
  
  1 \xe2\x96\x8f 7 -> (2 + 3) (esc)
    \xe2\x96\x8f      ^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '10 -> (3 + 2 + 5)' -i '10'
  10

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  7

  $ possum -p 'X = 3; 8 -> (X + 4)' -i '8'
  
  Parse Failure: value 8 did not match pattern (X + 4)
  
  input:1:1:
  
  1 \xe2\x96\x8f 8 (esc)
    \xe2\x96\x8f  ^ (esc)
  
  while matching parser `@main`
  
  program:1:12-19:
  
  1 \xe2\x96\x8f X = 3; 8 -> (X + 4) (esc)
    \xe2\x96\x8f             ^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  5

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  2

  $ possum -p '8 -> (2 + X + 3) $ X' -i '8'
  3

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  5

  $ possum -p '5 -> (X + 6 + 3 - (2 + 3)) $ X' -i '5'
  1

  $ possum -p '5 -> (1 + 6 + 3 - (X + 3)) $ X' -i '5'
  2

  $ possum -p 'const([1,2,3]) -> [1, -X, 3] $ X' -i ''
  -2

  $ possum -p '5 -> -X $ X' -i '5'
  -5

  $ possum -p '5 -> --X $ X' -i '5'
  5

  $ possum -p '5 -> -(X + 1) $ X' -i '5'
  -6

  $ possum -p '5 -> Num.Add(3,2)' -i '5'
  5

  $ possum -p '"29" -> "%(0 + N)" $ N' -i '29'
  29

  $ possum -p 'const({"ab": 2}) -> {"a" + B: 2} $ B' -i ''
  [UnsupportedPattern]
  [1]

  $ possum -p '"123" -> "%(A)"' -i '123'
  "123"

  $ possum -p '"ab" > "cdef" -> ("c" + X)' -i 'abcdef'
  "cdef"

  $ possum -p '"ab" > "cdef" -> "c%(X)"' -i 'abcdef'
  "cdef"

  $ possum -p 'A = {"x": 1} ; const({"z": true, "x": 1}) -> (B + A) $ B' -i ''
  {"z": true}

  $ possum -p 'A = {"x": 1} ; const($`{"z": true, "x": 1}`) -> "%(B + A)" $ B' -i ''
  [UnsupportedPattern]
  [1]

An untyped merge (`part + X`) whose parts are runtime values dispatches on
the parts' type at match time: number subtract, string / array prefix,
object key removal, or boolean OR.

  $ possum -p 'G = "" $ 9 ; ("" $ 14) -> (G + X) $ X' -i ''
  5

  $ possum -p 'I(V) = V ; ("" $ 14) -> (I(2) + X) $ X' -i ''
  12

  $ possum -p 'P = "" $ "abc" ; ("" $ "abcdef") -> (P + X) $ X' -i ''
  "def"

  $ possum -p 'P = "" $ [1, 2] ; const([1, 2, 3, 4]) -> (P + X) $ X' -i ''
  [3, 4]

  $ possum -p 'P = "" $ {"x": 1} ; const({"x": 1, "y": 2}) -> (P + X) $ X' -i ''
  {"y": 2}

  $ possum -p 'P = "" $ $true ; const($true) -> (P + X) $ X' -i ''
  false

The solvable can sit at either end or between the known parts. A leading
solvable strips the known parts from the end (string / array suffix); an
interior solvable carves the span between the leading prefix and trailing
suffix. Order-independent types (number, object) subtract both groups.

  $ possum -p 'P = "" $ "def" ; ("" $ "abcdef") -> (X + P) $ X' -i ''
  "abc"

  $ possum -p 'P = "" $ [3, 4] ; const([1, 2, 3, 4]) -> (X + P) $ X' -i ''
  [1, 2]

  $ possum -p 'A = "" $ "ab" ; C = "" $ "ef" ; ("" $ "abcdef") -> (A + X + C) $ X' -i ''
  "cd"

  $ possum -p 'A = "" $ [1] ; C = "" $ [4] ; const([1, 2, 3, 4]) -> (A + X + C) $ X' -i ''
  [2, 3]

  $ possum -p 'A = "" $ 2 ; C = "" $ 3 ; ("" $ 10) -> (A + X + C) $ X' -i ''
  5

  $ possum -p 'A = {"a": 1} ; C = {"c": 3} ; const({"a": 1, "b": 2, "c": 3}) -> (A + X + C) $ X' -i ''
  {"b": 2}

A part that is not a prefix of the value fails the match:

  $ possum -p 'P = "" $ "zzz" ; ("" $ "abcdef") -> (P + X) $ X' -i ''
  
  Parse Failure: value "abcdef" did not match pattern (P + X)
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:36-43:
  
  1 \xe2\x96\x8f P = "" $ "zzz" ; ("" $ "abcdef") -> (P + X) $ X (esc)
    \xe2\x96\x8f                                     ^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '123 -> V' -i '123'
  123

  $ possum -p '"abc" -> "abc"' -i 'abc'
  "abc"

  $ possum -p 'many(char) -> `\nfoo`' -i '\nfoo'
  "\\nfoo"

  $ possum -p '"a3" -> "a%(1..5)"' -i 'a3'
  "a3"

  $ possum -p '"a7" -> "a%(1..5)"' -i 'a7'
  
  Parse Failure: value "a7" did not match pattern "a%(1..5)"
  
  input:1:2:
  
  1 \xe2\x96\x8f a7 (esc)
    \xe2\x96\x8f   ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-18:
  
  1 \xe2\x96\x8f "a7" -> "a%(1..5)" (esc)
    \xe2\x96\x8f         ^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '"ax" -> "a%(1..5)"' -i 'ax'
  
  Parse Failure: value "ax" did not match pattern "a%(1..5)"
  
  input:1:2:
  
  1 \xe2\x96\x8f ax (esc)
    \xe2\x96\x8f   ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-18:
  
  1 \xe2\x96\x8f "ax" -> "a%(1..5)" (esc)
    \xe2\x96\x8f         ^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'many(char) -> "%(`a`..`z`)%(_)"' -i 'abcd'
  "abcd"

  $ possum -p 'numerals -> ("3" * 10)' -i '3333333333'
  "3333333333"

  $ possum -p 'numerals -> ("3" * N) $ N' -i '3333333333'
  10

  $ possum -p '(char * 10) -> ("\u000000".. * 10)' -i '12345678901234567890'
  "1234567890"

  $ possum -p 'bool(1, 0) -> true' -i '1'
  true

  $ possum -p 'int -> 5' -i '5'
  5

  $ possum -p '5 -> 2..7' -i '5'
  5

Equal bounds are a valid single-value range.

  $ possum -p '5 -> 5..5' -i '5'
  5

A range whose bounds are both known at compile time is rejected when the
lower bound exceeds the upper bound.

  $ possum -p '10 -> 10..2' -i '10'
  
  Program Error: Range lower bound must not be greater than upper bound
  
  program:1:6-11:
  1 \xe2\x96\x8f 10 -> 10..2 (esc)
    \xe2\x96\x8f       ^^^^^ (esc)
  
  [InvalidAst]
  [1]

A codepoint range is checked the same way.

  $ possum -p '"m" -> `z`..`a`' -i 'm'
  
  Program Error: Range lower bound must not be greater than upper bound
  
  program:1:7-15:
  1 \xe2\x96\x8f "m" -> `z`..`a` (esc)
    \xe2\x96\x8f        ^^^^^^^^ (esc)
  
  [InvalidAst]
  [1]

When a bound is only known at runtime the inverted range is not a compile
error; it matches nothing and fails.

  $ possum -p '(2 -> N) & (10 -> N..2)' -i '2'
  
  Parse Failure: expected 10
  
  input:1:1:
  
  1 \xe2\x96\x8f 2 (esc)
    \xe2\x96\x8f  ^ (esc)
  
  while matching parser `@main`
  
  program:1:12-14:
  
  1 \xe2\x96\x8f (2 -> N) & (10 -> N..2) (esc)
    \xe2\x96\x8f             ^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '8 -> (0 + N)' -i '8'
  8

  $ possum -p '8 -> (N + 100)' -i '8'
  8

  $ possum -p 'array(digit) -> [1, 2, 3]' -i '123'
  [1, 2, 3]

  $ possum -p 'array(digit) -> [A, ..._]' -i '123'
  [1, 2, 3]

  $ possum -p 'array(digit) -> ([1] * 5)' -i '11111'
  [1, 1, 1, 1, 1]

  $ possum -p 'array(digit) -> ([A] * 5)' -i '11111'
  [1, 1, 1, 1, 1]

  $ possum -p 'array(digit) -> ([1] * N) $ N' -i '11111111'
  8

A bare binder with an unbound count is under-constrained: the pattern greedily
claims the whole value and the count binds to 1, the repeat's identity.

  $ possum -p 'json -> (A * N) $ [A, N]' -i '"abcabc"'
  ["abcabc", 1]

  $ possum -p 'json -> (A * N) $ [A, N]' -i '[1, 2, 3]'
  [
    [1, 2, 3],
    1
  ]

  $ possum -p 'json -> (_ * N) $ N' -i '42'
  1

An all-placeholder object chunk counts members: the count is the object's
member count divided by the chunk's member count.

  $ possum -p 'object(alpha, digit) -> ({_: _} * S) $ S' -i 'a1b2'
  2

  $ possum -p 'object(alpha, digit) -> ({_: _, _: _} * S) $ S' -i 'a1b2c3d4'
  2

  $ possum -p 'object(alpha, digit) -> ({_: _} * 2)' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p 'ObjLen(O) = O -> ({_: _} * L) $ L ; const(ObjLen({"a": 1, "b": 2, "c": 3}))' -i ''
  3

The chunk's container type is enforced: an object repeat rejects an array
value and an array repeat rejects an object value.

  $ possum -p 'const([1, 2]) -> ({_: _} * S) $ S' -i ''
  
  Parse Failure: value [1, 2] did not match pattern ({_: _} * S)
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:17-29:
  
  1 \xe2\x96\x8f const([1, 2]) -> ({_: _} * S) $ S (esc)
    \xe2\x96\x8f                  ^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'array(digit) -> [A, ..._, Z]' -i '12345678'
  [1, 2, 3, 4, 5, 6, 7, 8]

  $ possum -p 'array(digit) -> [1, B, _]' -i '123'
  [1, 2, 3]

  $ possum -p 'object(alpha, digit) -> {"a": 1, "b": 2}' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {"a": 1, ..._}' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {_: 1, ..._}' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {"a": A, ..._}' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {..._, "a": A}' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {"a": _, "b": B}' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p 'array(digit) -> [...A]' -i '123'
  [1, 2, 3]

  $ possum -p 'object(alpha, digit) -> {...O}' -i 'a1b2'
  {"a": 1, "b": 2}

  $ possum -p '"abc" -> "%(S)"' -i 'abc'
  "abc"

  $ possum -p '"null" -> "%(null)"' -i 'null'
  "null"

  $ possum -p '"null" -> "%(null + N)" $ N' -i 'null'
  "null"

  $ possum -p '"true" -> "%(true + B)" $ B' -i 'true'
  false

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  "123"

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  "123"

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  "[1,2,3]"

  $ possum -p '`{"a": 1, "b": 2}` -> "%({..._})"' -i '{"a": 1, "b": 2}'
  "{\"a\": 1, \"b\": 2}"

  $ possum -p '"abcabcabc" -> "%( `abc` * N)" $ N' -i 'abcabcabc'
  3

A repeat segment surrounded by literals matches the residual span the fixed
literals leave between the cursors:

  $ possum -p '"pre_ababab_end" -> "pre_%(`ab` * N)_end" $ N' -i 'pre_ababab_end'
  3

  $ possum -p '"x_aaaa" -> "x_%(`a` * N)" $ N' -i 'x_aaaa'
  4

  $ possum -p '"prefix123123suffix" -> "%(`prefix` + (`123` * N) + `suffix`)" $ N' -i 'prefix123123suffix'
  [UnsupportedPattern]
  [1]

  $ possum -p '"" -> ("" * N)' -i ''
  ""

  $ possum -p '"" -> "%(`` * N)"' -i ''
  ""

  $ possum -p '"" $ 0 -> (0 * N)' -i ''
  0

  $ possum -p 'const($true) -> (true * N)' -i ''
  true

  $ possum -p 'const($false) -> (false * N)' -i ''
  false

  $ possum -p 'Length(A) = A -> ([_] * L) $ L ; const(Length([1,2,3]))' -i ''
  3

  $ possum -p '"12345" -> ("0".."9" * 5)' -i "12345"
  "12345"

  $ possum -p '"12345" -> ("0".."9" * N) $ N' -i "12345"
  5

A range count factor in a product with an unbound factor solves greedily:
the largest repetition count in the range that divides the derived count
wins, and the quotient binds the unbound factor.

  $ possum -p '("" $ "aaaaaa") -> (("a" * 2..3) * N) $ N' -i ''
  2

  $ possum -p '("" $ "aaaa") -> (("a" * 2..3) * N) $ N' -i ''
  2

  $ possum -p '("" $ "aaaaaa") -> (("a" * 2..) * N) $ N' -i ''
  1

  $ possum -p 'Id(N) = N -> M & M ; json -> {A: Id(A), ..._} $ A' -i '{"x": "y", "a": "a"}'
  "a"

  $ possum -p 'Id(N) = N -> M & M ; json -> {A: Id(A), "z": 1} $ A | (json -> A $ A)' -i '{"x": "y", "a": "a"}'
  {"x": "y", "a": "a"}

  $ possum -p 'Id(N) = N -> M & M ; const([1, 2]) -> [Id(1), X] $ X' -i ''
  2

  $ possum -p 'const({"a": 5, "b": 6, "c": 7}) -> ({_: _} * Size) $ Size' -i ''
  3

  $ possum -p 'const({}) -> ({K: V} * Size) $ Size' -i ''
  0

  $ possum -p 'const({"a": 5}) -> ({K: V} * Size) $ Size' -i ''
  1

  $ possum -p 'const({"a": 1, "b": 2, "c": 1, "d": 2}) -> ({_: 1, _: 2} * N) $ N' -i ''
  2

  $ possum -p 'const({"a": 5, "b": 6}) -> ({K: V} * Size) $ Size' -i ''
  
  Parse Failure: value {"a": 5, "b": 6} did not match pattern ({K: V} * Size)
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:27-42:
  
  1 \xe2\x96\x8f const({"a": 5, "b": 6}) -> ({K: V} * Size) $ Size (esc)
    \xe2\x96\x8f                            ^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'const({"a": 1, "b": 1, "c": 1}) -> ({_: V} * 3) $ V' -i ''
  1

  $ possum -p 'const({"a": 1, "b": 1, "c": 1}) -> ({_: V} * N) $ N' -i ''
  3

  $ possum -p 'const({"a": 1, "b": 2, "c": 1}) -> ({_: V} * 3) $ V' -i ''
  
  Parse Failure: value {"a": 1, "b": 2, "c": 1} did not match pattern ({_: V} * 3)
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:35-47:
  
  1 \xe2\x96\x8f const({"a": 1, "b": 2, "c": 1}) -> ({_: V} * 3) $ V (esc)
    \xe2\x96\x8f                                    ^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'const({"a": 1, "b": 1, "c": 1}) -> ({_: 1} * 3)' -i ''
  {"a": 1, "b": 1, "c": 1}

  $ possum -p 'const({"a": 1, "b": 2, "c": 1}) -> ({_: 1} * 3)' -i ''
  
  Parse Failure: value {"a": 1, "b": 2, "c": 1} did not match pattern ({_: 1} * 3)
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:35-47:
  
  1 \xe2\x96\x8f const({"a": 1, "b": 2, "c": 1}) -> ({_: 1} * 3) (esc)
    \xe2\x96\x8f                                    ^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'const({"a": 1, "b": 1, "c": 1}) -> ({_: 1} * 2)' -i ''
  
  Parse Failure: value {"a": 1, "b": 1, "c": 1} did not match pattern ({_: 1} * 2)
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:35-47:
  
  1 \xe2\x96\x8f const({"a": 1, "b": 1, "c": 1}) -> ({_: 1} * 2) (esc)
    \xe2\x96\x8f                                    ^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'const({"q": 1}) -> ({"q": _} * 1)' -i ''
  {"q": 1}

  $ possum -p 'const({"q": 1, "r": 2}) -> ({"q": _} * 2)' -i ''
  
  Parse Failure: value {"q": 1, "r": 2} did not match pattern ({"q": _} * 2)
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:27-41:
  
  1 \xe2\x96\x8f const({"q": 1, "r": 2}) -> ({"q": _} * 2) (esc)
    \xe2\x96\x8f                            ^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

An object merge with a repeat part claims count-many disjoint member groups;
the remainder feeds the rest. Known count, all-placeholder chunk: the first
three members are claimed, Rest is the fourth.

  $ possum -p 'const({"a": 1, "b": 2, "c": 3, "d": 4}) -> {...({_: _} * 3), ...Rest} $ Rest' -i ''
  {"d": 4}

Too few members for the count: the group scan exhausts and the match fails.

  $ possum -p 'const({"a": 1, "b": 2}) -> {...({_: _} * 3), ...Rest} $ Rest' -i ''
  
  Parse Failure: value {"a": 1, "b": 2} did not match pattern {...({_: _} * 3), ...Rest}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:27-53:
  
  1 \xe2\x96\x8f const({"a": 1, "b": 2}) -> {...({_: _} * 3), ...Rest} $ Rest (esc)
    \xe2\x96\x8f                            ^^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

Constrained pairs: each claimed member's value must match. Rest is the member
whose value the pairs did not claim.

  $ possum -p 'const({"a": 1, "b": 2, "c": 1}) -> {...({_: 1} * 2), ...Rest} $ Rest' -i ''
  {"b": 2}

Exact shape (no rest) with a solvable count: the count binds to the member
surplus over the const key.

  $ possum -p 'const({"a": 1, "b": 2, "c": 3}) -> {"a": 1, ...({_: _} * N)} $ N' -i ''
  2

A bound count read from an earlier destructure claims that many groups.

  $ possum -p 'json -> [K, {...({_: _} * K), ...Rest}] $ Rest' -i '[2, {"a": 1, "b": 2, "c": 3, "d": 4}]'
  {"c": 3, "d": 4}

A binder in the chunk value binds in the first group and compares in later
groups, so every claimed value must be equal.

  $ possum -p 'const({"a": 9, "b": 9, "z": 0}) -> {...({_: V} * 2), ...Rest} $ [V, Rest]' -i ''
  [
    9,
    {"z": 0}
  ]

  $ possum -p 'const({"a": 9, "b": 8, "z": 0}) -> {...({_: V} * 2), ...Rest} $ [V, Rest]' -i ''
  
  Parse Failure: value {"a": 9, "b": 8, "z": 0} did not match pattern {...({_: V} * 2), ...Rest}
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:35-61:
  
  1 \xe2\x96\x8f const({"a": 9, "b": 8, "z": 0}) -> {...({_: V} * 2), ...Rest} $ [V, Rest] (esc)
    \xe2\x96\x8f                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A pre-bound count in the exact shape is an exact-coverage test: it holds when
the members past the const key equal the count, and fails otherwise.

  $ possum -p 'json -> [N, {"a": 1, ...({_: _} * N)}] $ "ok"' -i '[2, {"a": 1, "b": 2, "c": 3}]'
  "ok"

  $ possum -p 'json -> [N, {"a": 1, ...({_: _} * N)}] $ "ok"' -i '[5, {"a": 1, "b": 2, "c": 3}]'
  
  Parse Failure: value [5, {"a": 1, "b": 2, "c": 3}] did not match pattern [N, {"a": 1, ...({_: _} * N)}]
  
  input:1:29:
  
  1 \xe2\x96\x8f [5, {"a": 1, "b": 2, "c": 3}] (esc)
    \xe2\x96\x8f                              ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-38:
  
  1 \xe2\x96\x8f json -> [N, {"a": 1, ...({_: _} * N)}] $ "ok" (esc)
    \xe2\x96\x8f         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

Constrained pairs with a solvable count in the exact shape: the count binds to
the surplus over the const key that matches the pair value.

  $ possum -p 'const({"a": 1, "b": 1, "c": 1}) -> {"a": 1, ...({_: 1} * N)} $ N' -i ''
  2

A count of zero claims nothing; the rest is the whole object.

  $ possum -p 'const({"a": 1, "b": 2}) -> {...({_: _} * 0), ...Rest} $ Rest' -i ''
  {"a": 1, "b": 2}

  $ possum -p 'const({"a": 5} * 3)' -i ''
  {"a": 5}

  $ possum -p 'O = {"a": 5} ; const({"a": 5}) -> (O * N) $ N' -i ''
  1

  $ possum -p 'O = {"a": 5} ; const({}) -> (O * N) $ N' -i ''
  0

An object merge mixing structural, runtime, and solvable parts solves on
the claim array: each part claims members of the scrutinee exclusively —
a structural part probes and claims one member per pair, an evaluated
part (a bound read, global, or call) claims all of its members at once —
and the single solvable part takes the unclaimed rest.

  $ possum -p 'const({"b": 2}) -> B & json -> (B + A + {"q": Q}) $ [A, Q]' -i '{"a": 1, "b": 2, "q": 42}'
  [
    {"a": 1},
    42
  ]

  $ possum -p 'Conf = {"b": 2} ; json -> (Conf + R + {"q": Q}) $ [R, Q]' -i '{"a": 1, "b": 2, "q": 42}'
  [
    {"a": 1},
    42
  ]

  $ possum -p 'Wrap(V) = {"w": V} ; json -> (Wrap(1) + R + {"q": Q}) $ [R, Q]' -i '{"w": 1, "b": 2, "q": 42}'
  [
    {"b": 2},
    42
  ]

A placeholder solvable absorbs the unclaimed members.

  $ possum -p 'const({"b": 2}) -> B & json -> (B + _ + {"q": Q}) $ Q' -i '{"a": 1, "b": 2, "q": 42}'
  42

A binding search pair in a structural part scans the unclaimed members.

  $ possum -p 'const({"b": 2}) -> B & json -> (B + {K: 42} + R) $ [K, R]' -i '{"a": 1, "b": 2, "q": 42}'
  [
    "q",
    {"a": 1}
  ]

With no solvable part, the claims must cover every member exactly.

  $ possum -p 'const({"b": 2}) -> B & const({"a": 1}) -> A & json -> (B + A + {"q": Q}) $ Q' -i '{"a": 1, "b": 2, "q": 42}'
  42

  $ possum -p 'const({"b": 2}) -> B & json -> (B + {"q": Q}) $ Q' -i '{"a": 1, "b": 2, "q": 42}'
  
  Parse Failure: value {"a": 1, "b": 2, "q": 42} did not match pattern (B + {"q": Q})
  
  input:1:25:
  
  1 \xe2\x96\x8f {"a": 1, "b": 2, "q": 42} (esc)
    \xe2\x96\x8f                          ^ (esc)
  
  while matching parser `@main`
  
  program:1:31-45:
  
  1 \xe2\x96\x8f const({"b": 2}) -> B & json -> (B + {"q": Q}) $ Q (esc)
    \xe2\x96\x8f                                ^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]








An evaluated part whose member is missing or unequal in the scrutinee, or
whose value is not an object, fails the match.

  $ possum -p 'const({"b": 9}) -> B & json -> (B + {"q": Q} + R) $ R' -i '{"b": 2, "q": 42}'
  
  Parse Failure: value {"b": 2, "q": 42} did not match pattern (B + {"q": Q} + R)
  
  input:1:17:
  
  1 \xe2\x96\x8f {"b": 2, "q": 42} (esc)
    \xe2\x96\x8f                  ^ (esc)
  
  while matching parser `@main`
  
  program:1:31-49:
  
  1 \xe2\x96\x8f const({"b": 9}) -> B & json -> (B + {"q": Q} + R) $ R (esc)
    \xe2\x96\x8f                                ^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]








  $ possum -p 'I(V) = V ; json -> (I(5) + {"q": Q} + R) $ R' -i '{"b": 2, "q": 42}'
  
  Parse Failure: value {"b": 2, "q": 42} did not match pattern (I(5) + {"q": Q} + R)
  
  input:1:17:
  
  1 \xe2\x96\x8f {"b": 2, "q": 42} (esc)
    \xe2\x96\x8f                  ^ (esc)
  
  while matching parser `@main`
  
  program:1:19-40:
  
  1 \xe2\x96\x8f I(V) = V ; json -> (I(5) + {"q": Q} + R) $ R (esc)
    \xe2\x96\x8f                    ^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]








Parts claim exclusively: a key one part claimed fails a later part that
probes it, unlike merge construction where duplicate keys fold.

  $ possum -p 'const({"a": 1}) -> B & json -> (B + {"a": A} + R) $ [A, R]' -i '{"a": 1, "b": 2}'
  
  Parse Failure: value {"a": 1, "b": 2} did not match pattern (B + {"a": A} + R)
  
  input:1:16:
  
  1 \xe2\x96\x8f {"a": 1, "b": 2} (esc)
    \xe2\x96\x8f                 ^ (esc)
  
  while matching parser `@main`
  
  program:1:31-49:
  
  1 \xe2\x96\x8f const({"a": 1}) -> B & json -> (B + {"a": A} + R) $ [A, R] (esc)
    \xe2\x96\x8f                                ^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]








An object merge as a repeat pair's value binds in the first group and
compares in later groups like any sub-pattern.

  $ possum -p 'const({"x": 9}) -> B & json -> ({_: (B + {"k": K})} * 2) $ K' -i '{"p": {"x": 9, "k": 1}, "q": {"x": 9, "k": 1}}'
  1

  $ possum -p 'const({"x": 9}) -> B & json -> ({_: (B + {"k": K})} * 2) $ K' -i '{"p": {"x": 9, "k": 1}, "q": {"x": 9, "k": 2}}'
  
  Parse Failure: value {"p": {"x": 9, "k": 1}, "q": {"x": 9, "k": 2}} did not match pattern ({_: (B + {"k": K})} * 2)
  
  input:1:46:
  
  1 \xe2\x96\x8f {"p": {"x": 9, "k": 1}, "q": {"x": 9, "k": 2}} (esc)
    \xe2\x96\x8f                                               ^ (esc)
  
  while matching parser `@main`
  
  program:1:31-56:
  
  1 \xe2\x96\x8f const({"x": 9}) -> B & json -> ({_: (B + {"k": K})} * 2) $ K (esc)
    \xe2\x96\x8f                                ^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A repeat part in the mix claims count-many groups past the claims of the
parts before it; parts after it (and the rest) take what remains. The
count must be a known product.

  $ possum -p 'json -> ({_: V} * 2 + {"z": Z} + R) $ [V, Z, R]' -i '{"a": 7, "b": 7, "z": 9, "q": 5}'
  [
    7,
    9,
    {"q": 5}
  ]

  $ possum -p 'B = {"z": 9} ; json -> (B + ({_: 1} * 2) + R) $ R' -i '{"a": 1, "b": 1, "z": 9, "q": 5}'
  {"q": 5}

  $ possum -p 'json -> ({_: 1} * 2 + {"z": 9}) $ "ok"' -i '{"a": 1, "b": 1, "z": 9}'
  "ok"

Too few members match the chunk for the count: the group scan exhausts.

  $ possum -p 'B = {"z": 9} ; json -> (B + ({_: 1} * 3) + R) $ R' -i '{"a": 1, "b": 1, "z": 9, "q": 5}'
  
  Parse Failure: value {"a": 1, "b": 1, "z": 9, "q": 5} did not match pattern (B + ({_: 1} * 3) + R)
  
  input:1:32:
  
  1 \xe2\x96\x8f {"a": 1, "b": 1, "z": 9, "q": 5} (esc)
    \xe2\x96\x8f                                 ^ (esc)
  
  while matching parser `@main`
  
  program:1:23-45:
  
  1 \xe2\x96\x8f B = {"z": 9} ; json -> (B + ({_: 1} * 3) + R) $ R (esc)
    \xe2\x96\x8f                        ^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]



  $ possum -p '"a" -> A & "b" -> B & "ab" -> (A + B)' -i 'abab'
  "ab"

  $ possum -p '"a" -> A & "b" -> B & "abc" -> (A + B)' -i 'ababc'
  
  Parse Failure: value "abc" did not match pattern (A + B)
  
  input:1:5:
  
  1 \xe2\x96\x8f ababc (esc)
    \xe2\x96\x8f      ^ (esc)
  
  while matching parser `@main`
  
  program:1:31-38:
  
  1 \xe2\x96\x8f "a" -> A & "b" -> B & "abc" -> (A + B) (esc)
    \xe2\x96\x8f                                ^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '("" $ [1] -> A) & ("" $ [2] -> B) & (json -> (A + B))' -i '[1,2]'
  [1, 2]

  $ possum -p '("" $ [1] -> A) & ("" $ [2] -> B) & (json -> (A + B)) $ "ok"' -i '[1,2,3]'
  
  Parse Failure: value [1, 2, 3] did not match pattern (A + B)
  
  input:1:7:
  
  1 \xe2\x96\x8f [1,2,3] (esc)
    \xe2\x96\x8f        ^ (esc)
  
  while matching parser `@main`
  
  program:1:45-52:
  
  1 \xe2\x96\x8f ("" $ [1] -> A) & ("" $ [2] -> B) & (json -> (A + B)) $ "ok" (esc)
    \xe2\x96\x8f                                              ^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '("" $ {"a": 1} -> A) & ("" $ {"b": 2} -> B) & (json -> (A + B))' -i '{"a": 1, "b": 2}'
  {"a": 1, "b": 2}

  $ possum -p '("" $ {"a": 1} -> A) & ("" $ {} -> B) & (json -> (A + B)) $ "ok"' -i '{"a": 1, "b": 2}'
  
  Parse Failure: value {"a": 1, "b": 2} did not match pattern (A + B)
  
  input:1:16:
  
  1 \xe2\x96\x8f {"a": 1, "b": 2} (esc)
    \xe2\x96\x8f                 ^ (esc)
  
  while matching parser `@main`
  
  program:1:49-56:
  
  1 \xe2\x96\x8f ("" $ {"a": 1} -> A) & ("" $ {} -> B) & (json -> (A + B)) $ "ok" (esc)
    \xe2\x96\x8f                                                  ^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'const("b") -> A & "abc" -> "a%(A)c" $ A' -i 'abc'
  
  Program Error: Expected value but got parser
  
  program:1:6-9:
  1 \xe2\x96\x8f const("b") -> A & "abc" -> "a%(A)c" $ A (esc)
    \xe2\x96\x8f       ^^^ (esc)
  
  [FunctionCallTypeMismatch]
  [1]

  $ possum -p 'const("b") -> A & "abcd" -> "a%(A)c" $ A' -i 'abcd'
  
  Program Error: Expected value but got parser
  
  program:1:6-9:
  1 \xe2\x96\x8f const("b") -> A & "abcd" -> "a%(A)c" $ A (esc)
    \xe2\x96\x8f       ^^^ (esc)
  
  [FunctionCallTypeMismatch]
  [1]

  $ possum -p '"aéb" -> "a%("à".."ö")b" $ "ok"' -i 'aéb'
  "ok"

  $ possum -p '"aÿb" -> "a%("à".."ö")b" $ "ok"' -i 'aÿb'
  
  Parse Failure: value "a\xc3\xbfb" did not match pattern "a%("\xc3\xa0".."\xc3\xb6")b" (esc)
  
  input:1:4:
  
  1 \xe2\x96\x8f a\xc3\xbfb (esc)
    \xe2\x96\x8f     ^ (esc)
  
  while matching parser `@main`
  
  program:1:10-27:
  
  1 \xe2\x96\x8f "a\xc3\xbfb" -> "a%("\xc3\xa0".."\xc3\xb6")b" $ "ok" (esc)
    \xe2\x96\x8f           ^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p '"a😀b" -> "a%("😀".."😃")b" $ "ok"' -i 'a😀b'
  "ok"

  $ possum -p '"xyzéb" -> "%(R)%("à".."ö")b" $ R' -i 'xyzéb'
  "xyz"

  $ possum -p 'I(V)=V ; "" $ [1,1,1,1,1,1] -> (I([1]) * I(2) * I(3))' -i ''
  [1, 1, 1, 1, 1, 1]

  $ possum -p '"" $ [1,1,1,1,1,1] -> ((([1] * 2) * N) * 3) $ N' -i ''
  1

  $ possum -p '"" $ [1,1,1,1,1,1] -> ([1] * (2 * N)) $ N' -i ''
  3

  $ possum -p 'I(V)=V ; array(digit) -> (I([1]) * I(2) * N * I(3)) $ N' -i '111111111111'
  2

An array merge with a runtime-length part solves through the span cursor
scheduler: the bound rest chomps and the solvable takes the residual span.
The suffix rest B chomps backward:

  $ possum -p 'json -> [[...A, ...B], [...B]] $ [A, B]' -i '[[1, 2, 3], [3]]'
  [
    [1, 2],
    [3]
  ]

The prefix rest A chomps forward, leaving B the residual:

  $ possum -p 'json -> [[...A, ...B], [...A]] $ [A, B]' -i '[[1, 2, 3], [1]]'
  [
    [1],
    [2, 3]
  ]

An empty residual span binds an empty array:

  $ possum -p 'json -> [[...A, ...B], [...B]] $ [A, B]' -i '[[5], []]'
  [
    [5],
    []
  ]

With no solvable part, the fixed parts must cover the array exactly (the
cursors must meet); `[...B, ...B]` requires the value be B twice over:

  $ possum -p 'json -> [[...B, ...B], [...B]] $ B' -i '[[1, 1], [1]]'
  [1]

  $ possum -p 'json -> [[...B, ...B], [...B]] $ B' -i '[[1, 1, 1], [1]]'
  
  Parse Failure: value [[1, 1, 1], [1]] did not match pattern [[...B, ...B], [...B]]
  
  input:1:16:
  
  1 \xe2\x96\x8f [[1, 1, 1], [1]] (esc)
    \xe2\x96\x8f                 ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-30:
  
  1 \xe2\x96\x8f json -> [[...B, ...B], [...B]] $ B (esc)
    \xe2\x96\x8f         ^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A fixed-length structural part chomps a fixed-size chunk at the cursor and
matches it in a child window. A leading `[1]` base chomps forward:

  $ possum -p 'json -> [[1, ...A, ...B], [...B]] $ [A, B]' -i '[[1, 2, 3, 4], [3, 4]]'
  [
    [2],
    [3, 4]
  ]

The chunk's child window binds nested variables (the `[B, C]` element):

  $ possum -p 'json -> [[...A, [B, C]], [...A]] $ [A, B, C]' -i '[[7, 8, [1, 2]], [7, 8]]'
  [
    [7, 8],
    1,
    2
  ]
