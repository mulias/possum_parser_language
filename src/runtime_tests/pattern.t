  $ export PRINT_DESTRUCTURE=true

  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  
  Destructure:
      4 -> (1 + 1 + 2)
      4 -> 4
  Destructure Success: 4 -> (1 + 1 + 2)
  4

  $ possum -p '0 -> (1 + 1 + 2)' -i '0'
  
  Destructure:
      0 -> (1 + 1 + 2)
      0 -> 4
  Destructure Failure: 0 -> (1 + 1 + 2)
  Parser Failure
  [1]

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  Destructure:
      5 -> (2 + 3)
      5 -> 5
  Destructure Success: 5 -> (2 + 3)
  5

  $ possum -p '7 -> (2 + 3)' -i '7'
  
  Destructure:
      7 -> (2 + 3)
      7 -> 5
  Destructure Failure: 7 -> (2 + 3)
  Parser Failure
  [1]

  $ possum -p '10 -> (3 + 2 + 5)' -i '10'
  
  Destructure:
      10 -> (3 + 2 + 5)
      10 -> 10
  Destructure Success: 10 -> (3 + 2 + 5)
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
  Parser Failure
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
      5 -> (1 + 6 + 3 + (-2 + -3))
      5 -> 5
  Destructure Success: 5 -> (1 + 6 + 3 + (-2 + -3))
  5

  $ possum -p '5 -> (X + 6 + 3 - (2 + 3)) $ X' -i '5'
  
  Destructure:
      5 -> (X + 6 + 3 + (-2 + -3))
          1 -> X
  Destructure Success: 5 -> (X + 6 + 3 + (-2 + -3))
  1

  $ possum -p '5 -> (1 + 6 + 3 - (X + 3)) $ X' -i '5'
  
  Destructure:
      5 -> (1 + 6 + 3 + (-X + -3))
          -2 -> -X
  Destructure Success: 5 -> (1 + 6 + 3 + (-X + -3))
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

  $ possum -p '"" -> "%(A)"' -i ''
  
  Destructure:
      "" -> "%(A)"
          "" -> A
  Destructure Success: "" -> "%(A)"
  ""

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
