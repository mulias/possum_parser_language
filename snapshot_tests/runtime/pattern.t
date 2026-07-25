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
  "b"

  $ possum -p '"123" -> "%(A)"' -i '123'
  "123"

  $ possum -p '"ab" > "cdef" -> ("c" + X)' -i 'abcdef'
  "cdef"

  $ possum -p '"ab" > "cdef" -> "c%(X)"' -i 'abcdef'
  "cdef"

  $ possum -p 'A = {"x": 1} ; const({"z": true, "x": 1}) -> (B + A) $ B' -i ''
  {"z": true}

  $ possum -p 'A = {"x": 1} ; const($`{"z": true, "x": 1}`) -> "%(B + A)" $ B' -i ''
  {"z": true}

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

  $ possum -p 'const({"a": 1, "b": 2, "c": 3, "d": 4}) -> {...({_: _} * 3), ...Rest} $ Rest' -i ''
  {"d": 4}

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

  $ possum -p 'const({"a": 1, "b": 2, "c": 1}) -> {...({_: 1} * 2), ...Rest} $ Rest' -i ''
  {"b": 2}

  $ possum -p 'const({"a": 1, "b": 2, "c": 3}) -> {"a": 1, ...({_: _} * N)} $ N' -i ''
  [UnsupportedPattern]
  [1]

  $ possum -p 'const({"a": 5} * 3)' -i ''
  {"a": 5}

  $ possum -p 'O = {"a": 5} ; const({"a": 5}) -> (O * N) $ N' -i ''
  1

  $ possum -p 'O = {"a": 5} ; const({}) -> (O * N) $ N' -i ''
  0

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







