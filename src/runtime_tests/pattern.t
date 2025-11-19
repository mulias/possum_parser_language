  $ export PRINT_DESTRUCTURE=true

  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  
  Destructure:
      4 -> 4
  Destructure Success: 4 -> 4
  4

  $ possum -p '0 -> (1 + 1 + 2)' -i '0'
  
  Destructure:
      0 -> 4
  Destructure Failure: 0 -> 4
  [ParserFailure]
  [1]

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  Destructure:
      5 -> 5
  Destructure Success: 5 -> 5
  5

  $ possum -p '7 -> (2 + 3)' -i '7'
  
  Destructure:
      7 -> 5
  Destructure Failure: 7 -> 5
  [ParserFailure]
  [1]

  $ possum -p '10 -> (3 + 2 + 5)' -i '10'
  
  Destructure:
      10 -> 10
  Destructure Success: 10 -> 10
  10

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  
  Destructure:
      7 -> (X + 4)
      7 -> 7
  Destructure Success: 7 -> (X + 4)
  7

  $ possum -p 'X = 3; 8 -> (X + 4)' -i '8'
  
  Destructure:
      8 -> (X + 4)
      8 -> 7
  Destructure Failure: 8 -> (X + 4)
  [ParserFailure]
  [1]

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  
  Destructure:
      5 -> (X + Y)
      5 -> 5
  Destructure Success: 5 -> (X + Y)
  5

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  
  Destructure:
      6 -> (1 + X + 3)
          2 -> X
  Destructure Success: 6 -> (1 + X + 3)
  2

  $ possum -p '8 -> (2 + X + 3) $ X' -i '8'
  
  Destructure:
      8 -> (2 + X + 3)
          3 -> X
  Destructure Success: 8 -> (2 + X + 3)
  3

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  
  Destructure:
      5 -> 5
  Destructure Success: 5 -> 5
  5

  $ possum -p '5 -> (X + 6 + 3 - (2 + 3)) $ X' -i '5'
  
  Destructure:
      5 -> (X + 6 + 3 + -5)
          1 -> X
  Destructure Success: 5 -> (X + 6 + 3 + -5)
  1

  $ possum -p '5 -> (1 + 6 + 3 - (X + 3)) $ X' -i '5'
  
  Destructure:
      5 -> (10 + (-X + -3))
          -2 -> -X
  Destructure Success: 5 -> (10 + (-X + -3))
  2

  $ possum -p 'const([1,2,3]) -> [1, -X, 3] $ X' -i ''
  
  Destructure:
      [1, 2, 3] -> [1, -X, 3]
          1 -> 1
          2 -> -X
          3 -> 3
  Destructure Success: [1, 2, 3] -> [1, -X, 3]
  -2

  $ possum -p '5 -> -X $ X' -i '5'
  
  Destructure:
      5 -> -X
  Destructure Success: 5 -> -X
  -5

  $ possum -p '5 -> --X $ X' -i '5'
  
  Destructure:
      5 -> --X
  Destructure Success: 5 -> --X
  5

  $ possum -p '5 -> -(X + 1) $ X' -i '5'
  
  Destructure:
      5 -> (-X + -1)
          6 -> -X
  Destructure Success: 5 -> (-X + -1)
  -6

  $ possum -p '5 -> Num.Add(3,2)' -i '5'
  
  Destructure:
      5 -> Num.Add(3, 2)
  
  Eval Pattern Function: Num.Add(3, 2)
  
      5 -> 5
  Destructure Success: 5 -> Num.Add(3, 2)
  5

  $ possum -p '"29" -> "%(0 + N)" $ N' -i '29'
  
  Destructure:
      "29" -> "%(0 + N)"
          29 -> (0 + N)
              29 -> N
  Destructure Success: "29" -> "%(0 + N)"
  29

  $ possum -p 'const({"ab": 2}) -> {"a" + B: 2} $ B' -i ''
  
  Destructure:
      {"ab": 2} -> {("a" + B): 2}
          {"ab": 2} -> {("a" + B): 2}
              "ab" -> ("a" + B)
                  "a" -> "a"
                  "b" -> B
              2 -> 2
  Destructure Success: {"ab": 2} -> {("a" + B): 2}
  "b"

  $ possum -p '"123" -> "%(A)"' -i '123'
  
  Destructure:
      "123" -> "%(A)"
          "123" -> A
  Destructure Success: "123" -> "%(A)"
  "123"

  $ possum -p '"ab" > "cdef" -> ("c" + X)' -i 'abcdef'
  
  Destructure:
      "cdef" -> ("c" + X)
          "c" -> "c"
          "def" -> X
  Destructure Success: "cdef" -> ("c" + X)
  "cdef"

  $ possum -p '"ab" > "cdef" -> "c%(X)"' -i 'abcdef'
  
  Destructure:
      "cdef" -> "c%(X)"
          "c" -> "c"
          "def" -> X
  Destructure Success: "cdef" -> "c%(X)"
  "cdef"

  $ possum -p 'A = {"x": 1} ; const({"z": true, "x": 1}) -> (B + A) $ B' -i ''
  
  Destructure:
      {"z": true, "x": 1} -> (B + A)
  
  Eval Pattern Function: A
  
      1 -> 1
          {"z": true} -> B
  Destructure Success: {"z": true, "x": 1} -> (B + A)
  {"z": true}

  $ possum -p 'A = {"x": 1} ; const($`{"z": true, "x": 1}`) -> "%(B + A)" $ B' -i ''
  
  Destructure:
      "{"z": true, "x": 1}" -> "%(B + A)"
  
  Eval Pattern Function: A
  
          {"z": true, "x": 1} -> (B + A)
          1 -> 1
              {"z": true} -> B
  Destructure Success: "{"z": true, "x": 1}" -> "%(B + A)"
  {"z": true}

  $ possum -p '123 -> V' -i '123'
  
  Destructure:
      123 -> V
  Destructure Success: 123 -> V
  123

  $ possum -p '"abc" -> "abc"' -i 'abc'
  
  Destructure:
      "abc" -> "abc"
      "abc" -> "abc"
  Destructure Success: "abc" -> "abc"
  "abc"

  $ possum -p 'many(char) -> `\nfoo`' -i '\nfoo'
  
  Destructure:
      "\nfoo" -> "\nfoo"
      "\nfoo" -> "\nfoo"
  Destructure Success: "\nfoo" -> "\nfoo"
  "\\nfoo"

  $ possum -p 'many(char) -> "%(`a`..`z`)%(_)"' -i 'abcd'
  
  Destructure:
      "abcd" -> "%("a".."z")%(_)"
          "a" -> "a".."z"
          "bcd" -> _
  Destructure Success: "abcd" -> "%("a".."z")%(_)"
  "abcd"

  $ possum -p 'numerals -> ("3" * 10)' -i '3333333333'
  
  Destructure:
      "3333333333" -> "3333333333"
      "3333333333" -> "3333333333"
  Destructure Success: "3333333333" -> "3333333333"
  "3333333333"

  $ possum -p 'numerals -> ("3" * N) $ N' -i '3333333333'
  
  Destructure:
      "3333333333" -> ("3" * N)
          10 -> N
  Destructure Success: "3333333333" -> ("3" * N)
  10

  $ possum -p '(char * 10) -> ("\u000000".. * 10)' -i '12345678901234567890'
  
  Destructure:
      "1234567890" -> ("\x00".. * 10) (esc)
          "1" -> "\x00".. (esc)
          "2" -> "\x00".. (esc)
          "3" -> "\x00".. (esc)
          "4" -> "\x00".. (esc)
          "5" -> "\x00".. (esc)
          "6" -> "\x00".. (esc)
          "7" -> "\x00".. (esc)
          "8" -> "\x00".. (esc)
          "9" -> "\x00".. (esc)
          "0" -> "\x00".. (esc)
  Destructure Success: "1234567890" -> ("\x00".. * 10) (esc)
  "1234567890"

  $ possum -p 'bool(1, 0) -> true' -i '1'
  
  Destructure:
      true -> true
  Destructure Success: true -> true
  true

  $ possum -p 'int -> 5' -i '5'
  
  Destructure:
      "5" -> "%(0 + N)"
          5 -> (0 + N)
              5 -> N
  Destructure Success: "5" -> "%(0 + N)"
  
  Destructure:
      5 -> 5
  Destructure Success: 5 -> 5
  5

  $ possum -p '5 -> 2..7' -i '5'
  
  Destructure:
      5 -> 2..7
  Destructure Success: 5 -> 2..7
  5

  $ possum -p '8 -> (0 + N)' -i '8'
  
  Destructure:
      8 -> (0 + N)
          8 -> N
  Destructure Success: 8 -> (0 + N)
  8

  $ possum -p '8 -> (N + 100)' -i '8'
  
  Destructure:
      8 -> (N + 100)
          -92 -> N
  Destructure Success: 8 -> (N + 100)
  8

  $ possum -p 'array(digit) -> [1, 2, 3]' -i '123'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      2 -> Elem
  Destructure Success: 2 -> Elem
  
  Destructure:
      3 -> Elem
  Destructure Success: 3 -> Elem
  
  Destructure:
      [1, 2, 3] -> [1, 2, 3]
          1 -> 1
          2 -> 2
          3 -> 3
  Destructure Success: [1, 2, 3] -> [1, 2, 3]
  [1, 2, 3]

  $ possum -p 'array(digit) -> [A, ..._]' -i '123'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      2 -> Elem
  Destructure Success: 2 -> Elem
  
  Destructure:
      3 -> Elem
  Destructure Success: 3 -> Elem
  
  Destructure:
      [1, 2, 3] -> ([A] + _)
          1 -> A
          [2, 3] -> _
  Destructure Success: [1, 2, 3] -> ([A] + _)
  [1, 2, 3]

  $ possum -p 'array(digit) -> ([1] * 5)' -i '11111'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      [1, 1, 1, 1, 1] -> [1, 1, 1, 1, 1]
          1 -> 1
          1 -> 1
          1 -> 1
          1 -> 1
          1 -> 1
  Destructure Success: [1, 1, 1, 1, 1] -> [1, 1, 1, 1, 1]
  [1, 1, 1, 1, 1]

  $ possum -p 'array(digit) -> ([A] * 5)' -i '11111'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      [1, 1, 1, 1, 1] -> [A, A, A, A, A]
          1 -> A
          1 -> A
          1 -> 1
          1 -> A
          1 -> 1
          1 -> A
          1 -> 1
          1 -> A
          1 -> 1
  Destructure Success: [1, 1, 1, 1, 1] -> [A, A, A, A, A]
  [1, 1, 1, 1, 1]

  $ possum -p 'array(digit) -> ([1] * N) $ N' -i '11111111'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      [1, 1, 1, 1, 1, 1, 1, 1] -> ([1] * N)
      1 -> 1
      1 -> 1
      1 -> 1
      1 -> 1
      1 -> 1
      1 -> 1
      1 -> 1
      1 -> 1
          8 -> N
  Destructure Success: [1, 1, 1, 1, 1, 1, 1, 1] -> ([1] * N)
  8

  $ possum -p 'array(digit) -> [A, ..._, Z]' -i '12345678'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      2 -> Elem
  Destructure Success: 2 -> Elem
  
  Destructure:
      3 -> Elem
  Destructure Success: 3 -> Elem
  
  Destructure:
      4 -> Elem
  Destructure Success: 4 -> Elem
  
  Destructure:
      5 -> Elem
  Destructure Success: 5 -> Elem
  
  Destructure:
      6 -> Elem
  Destructure Success: 6 -> Elem
  
  Destructure:
      7 -> Elem
  Destructure Success: 7 -> Elem
  
  Destructure:
      8 -> Elem
  Destructure Success: 8 -> Elem
  
  Destructure:
      [1, 2, 3, 4, 5, 6, 7, 8] -> ([A] + _ + [Z])
          1 -> A
          [2, 3, 4, 5, 6, 7] -> _
          8 -> Z
  Destructure Success: [1, 2, 3, 4, 5, 6, 7, 8] -> ([A] + _ + [Z])
  [1, 2, 3, 4, 5, 6, 7, 8]

  $ possum -p 'array(digit) -> [1, B, _]' -i '123'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      2 -> Elem
  Destructure Success: 2 -> Elem
  
  Destructure:
      3 -> Elem
  Destructure Success: 3 -> Elem
  
  Destructure:
      [1, 2, 3] -> [1, B, _]
          1 -> 1
          2 -> B
          3 -> _
  Destructure Success: [1, 2, 3] -> [1, B, _]
  [1, 2, 3]

  $ possum -p 'object(alpha, digit) -> {"a": 1, "b": 2}' -i 'a1b2'
  
  Destructure:
      "a" -> K
  Destructure Success: "a" -> K
  
  Destructure:
      1 -> V
  Destructure Success: 1 -> V
  
  Destructure:
      "b" -> K
  Destructure Success: "b" -> K
  
  Destructure:
      2 -> V
  Destructure Success: 2 -> V
  
  Destructure:
      {"a": 1, "b": 2} -> {"a": 1, "b": 2}
          {"a": 1} -> {"a": 1}
              1 -> 1
          {"b": 2} -> {"b": 2}
              2 -> 2
  Destructure Success: {"a": 1, "b": 2} -> {"a": 1, "b": 2}
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {"a": 1, ..._}' -i 'a1b2'
  
  Destructure:
      "a" -> K
  Destructure Success: "a" -> K
  
  Destructure:
      1 -> V
  Destructure Success: 1 -> V
  
  Destructure:
      "b" -> K
  Destructure Success: "b" -> K
  
  Destructure:
      2 -> V
  Destructure Success: 2 -> V
  
  Destructure:
      {"a": 1, "b": 2} -> ({"a": 1} + _)
          1 -> 1
          {"b": 2} -> _
  Destructure Success: {"a": 1, "b": 2} -> ({"a": 1} + _)
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {_: 1, ..._}' -i 'a1b2'
  
  Destructure:
      "a" -> K
  Destructure Success: "a" -> K
  
  Destructure:
      1 -> V
  Destructure Success: 1 -> V
  
  Destructure:
      "b" -> K
  Destructure Success: "b" -> K
  
  Destructure:
      2 -> V
  Destructure Success: 2 -> V
  
  Destructure:
      {"a": 1, "b": 2} -> ({_: 1} + _)
          "a" -> _
          1 -> 1
          {"b": 2} -> _
  Destructure Success: {"a": 1, "b": 2} -> ({_: 1} + _)
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {"a": A, ..._}' -i 'a1b2'
  
  Destructure:
      "a" -> K
  Destructure Success: "a" -> K
  
  Destructure:
      1 -> V
  Destructure Success: 1 -> V
  
  Destructure:
      "b" -> K
  Destructure Success: "b" -> K
  
  Destructure:
      2 -> V
  Destructure Success: 2 -> V
  
  Destructure:
      {"a": 1, "b": 2} -> ({"a": A} + _)
          1 -> A
          {"b": 2} -> _
  Destructure Success: {"a": 1, "b": 2} -> ({"a": A} + _)
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {..._, "a": A}' -i 'a1b2'
  
  Destructure:
      "a" -> K
  Destructure Success: "a" -> K
  
  Destructure:
      1 -> V
  Destructure Success: 1 -> V
  
  Destructure:
      "b" -> K
  Destructure Success: "b" -> K
  
  Destructure:
      2 -> V
  Destructure Success: 2 -> V
  
  Destructure:
      {"a": 1, "b": 2} -> ({} + _ + {"a": A})
          1 -> A
          {"b": 2} -> _
  Destructure Success: {"a": 1, "b": 2} -> ({} + _ + {"a": A})
  {"a": 1, "b": 2}

  $ possum -p 'object(alpha, digit) -> {"a": _, "b": B}' -i 'a1b2'
  
  Destructure:
      "a" -> K
  Destructure Success: "a" -> K
  
  Destructure:
      1 -> V
  Destructure Success: 1 -> V
  
  Destructure:
      "b" -> K
  Destructure Success: "b" -> K
  
  Destructure:
      2 -> V
  Destructure Success: 2 -> V
  
  Destructure:
      {"a": 1, "b": 2} -> {"a": _, "b": B}
          {"a": 1} -> {"a": _}
              1 -> _
          {"b": 2} -> {"b": B}
              2 -> B
  Destructure Success: {"a": 1, "b": 2} -> {"a": _, "b": B}
  {"a": 1, "b": 2}

  $ possum -p 'array(digit) -> [...A]' -i '123'
  
  Destructure:
      1 -> Elem
  Destructure Success: 1 -> Elem
  
  Destructure:
      2 -> Elem
  Destructure Success: 2 -> Elem
  
  Destructure:
      3 -> Elem
  Destructure Success: 3 -> Elem
  
  Destructure:
      [1, 2, 3] -> ([] + A)
          [1, 2, 3] -> A
  Destructure Success: [1, 2, 3] -> ([] + A)
  [1, 2, 3]

  $ possum -p 'object(alpha, digit) -> {...O}' -i 'a1b2'
  
  Destructure:
      "a" -> K
  Destructure Success: "a" -> K
  
  Destructure:
      1 -> V
  Destructure Success: 1 -> V
  
  Destructure:
      "b" -> K
  Destructure Success: "b" -> K
  
  Destructure:
      2 -> V
  Destructure Success: 2 -> V
  
  Destructure:
      {"a": 1, "b": 2} -> ({} + O)
          {"a": 1, "b": 2} -> O
  Destructure Success: {"a": 1, "b": 2} -> ({} + O)
  {"a": 1, "b": 2}

  $ possum -p '"abc" -> "%(S)"' -i 'abc'
  
  Destructure:
      "abc" -> "%(S)"
          "abc" -> S
  Destructure Success: "abc" -> "%(S)"
  "abc"

  $ possum -p '"null" -> "%(null)"' -i 'null'
  
  Destructure:
      "null" -> "%(null)"
          "null" -> "null"
  Destructure Success: "null" -> "%(null)"
  "null"

  $ possum -p '"null" -> "%(null + N)" $ N' -i 'null'
  
  Destructure:
      "null" -> "%(N)"
          "null" -> N
  Destructure Success: "null" -> "%(N)"
  "null"

  $ possum -p '"true" -> "%(true + B)" $ B' -i 'true'
  
  Destructure:
      "true" -> "%(true + B)"
          true -> (true + B)
              false -> B
  Destructure Success: "true" -> "%(true + B)"
  false

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  
  Destructure:
      "123" -> "%(0 + N)"
          123 -> (0 + N)
              123 -> N
  Destructure Success: "123" -> "%(0 + N)"
  "123"

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  
  Destructure:
      "123" -> "%(N + 1)"
          123 -> (N + 1)
              122 -> N
  Destructure Success: "123" -> "%(N + 1)"
  "123"

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  
  Destructure:
      "[1,2,3]" -> "%([] + A)"
          [1, 2, 3] -> ([] + A)
              [1, 2, 3] -> A
  Destructure Success: "[1,2,3]" -> "%([] + A)"
  "[1,2,3]"

  $ possum -p '`{"a": 1, "b": 2}` -> "%({..._})"' -i '{"a": 1, "b": 2}'
  
  Destructure:
      "{"a": 1, "b": 2}" -> "%({} + _)"
          {"a": 1, "b": 2} -> ({} + _)
              {"a": 1, "b": 2} -> _
  Destructure Success: "{"a": 1, "b": 2}" -> "%({} + _)"
  "{\"a\": 1, \"b\": 2}"

  $ possum -p '"abcabcabc" -> "%( `abc` * N)" $ N' -i 'abcabcabc'
  
  Destructure:
      "abcabcabc" -> "%(("abc" * N))"
          "abcabcabc" -> ("abc" * N)
              3 -> N
  Destructure Success: "abcabcabc" -> "%(("abc" * N))"
  3

  $ possum -p '"prefix123123suffix" -> "%(`prefix` + (`123` * N) + `suffix`)" $ N' -i 'prefix123123suffix'
  
  Destructure:
      "prefix123123suffix" -> "%("prefix" + ("123" * N) + "suffix")"
          "prefix123123suffix" -> ("prefix" + ("123" * N) + "suffix")
              "prefix" -> "prefix"
              "123123" -> ("123" * N)
                  2 -> N
              "suffix" -> "suffix"
  Destructure Success: "prefix123123suffix" -> "%("prefix" + ("123" * N) + "suffix")"
  2

  $ possum -p '"" -> ("" * N)' -i ''
  
  Destructure:
      "" -> ("" * N)
          1 -> N
  Destructure Success: "" -> ("" * N)
  ""

  $ possum -p '"" -> "%(`` * N)"' -i ''
  
  Destructure:
      "" -> "%(("" * N))"
          "" -> ("" * N)
              1 -> N
  Destructure Success: "" -> "%(("" * N))"
  ""

  $ possum -p '"" $ 0 -> (0 * N)' -i ''
  
  Destructure:
      0 -> (0 * N)
          1 -> N
  Destructure Success: 0 -> (0 * N)
  0

  $ possum -p 'const($true) -> (true * N)' -i ''
  
  Destructure:
      true -> (true * N)
          1 -> N
  Destructure Success: true -> (true * N)
  true

  $ possum -p 'const($false) -> (false * N)' -i ''
  
  Destructure:
      false -> (false * N)
          1 -> N
  Destructure Success: false -> (false * N)
  false

  $ possum -p 'Length(A) = A -> ([_] * L) $ L ; const(Length([1,2,3]))' -i ''
  
  Destructure:
      [1, 2, 3] -> ([_] * L)
          [1] -> [_]
              1 -> _
          [2] -> [_]
              2 -> _
          [3] -> [_]
              3 -> _
          3 -> L
  Destructure Success: [1, 2, 3] -> ([_] * L)
  3
