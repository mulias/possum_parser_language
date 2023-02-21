  $ possum -p "space" -i "    abc    "
  " "

  $ possum -p "spaces" -i "   abc    "
  "   "

  $ possum -p "symbol" -i "?foo"
  "?"

  $ possum -p "symbols" -i "!'#\$?(]@[)>,<=foo"
  "!'#$?(]@[)>,<="

  $ possum -p "newline" -i "
  > "
  "\n"

  $ possum -p "newlines" -i "
  > 
  > 
  > "
  "\n\n\n"

  $ possum -p "nl" -i "
  > "
  "\n"

  $ possum -p "123 > end_of_input" -i "123"
  ""

  $ possum -p "123 < end" -i "123"
  123

  $ possum -p "whitespace" -i "
  > 
  >    foo
  > "
  "\n\n   "

  $ possum -p "ws" -i "
  > 
  >    foo
  > "
  "\n\n   "

  $ possum -p "word" -i "foo123 bar456"
  "foo123"

  $ possum -p "word > space > word" -i "foo123 bar456"
  "bar456"

  $ possum -p "digit" -i "9876"
  9

  $ possum -p "integer" -i "9876"
  9876

  $ possum -p "integer" --input="-12"
  -12

  $ possum -p "integer" --input="-0"
  -0

  $ possum -p "integer" --input="-011"
  -0

  $ possum -p "int" -i "9876.00123"
  9876

  $ possum -p "float" -i "9876.00123"
  9876.00123

  $ possum -p "float" -i "9e-34"
  9e-34

  $ possum -p "float" -i "9.880e-34"
  9.880e-34

  $ possum -p "float" -i "123"
  
  Error Parsing End of Input
  
  ~~~(##)'>  I reached the end of the input before completing the parser.
  
  The last attempted parser was:
  float
  number_of
  "E"
  
  But there's not enough input left to match on.
  [123]

  $ possum -p "number" -i "9876"
  9876

  $ possum -p "number" --input="-12"
  -12

  $ possum -p "number" --input="-0"
  -0

  $ possum -p "number" --input="-011"
  -0

  $ possum -p "number" -i "9876.00123"
  9876.00123

  $ possum -p "num" -i "9876.00123"
  9876.00123

  $ possum -p "num" -i "9e-34"
  9e-34

  $ possum -p "number" -i "9.880e-34"
  9.880e-34

  $ possum -p "num" -i "123"
  123

  $ possum -p "true(1)" -i "1"
  true

  $ possum -p "false('F')" -i "F"
  false

  $ possum -p "boolean('t', 'f')" -i "t"
  true

  $ possum -p "bool(1, 0)" -i "0"
  false

  $ possum -p "null(42)" -i "42"
  null

  $ possum -p "many(numeral)" -i "123 456"
  "123"

  $ possum -p "until(char, 'stop')" -i "gogogogogogogogogostop"
  "gogogogogogogogogo"

  $ possum -p "scan('stop')" -i "gogogogogogogogogostop"
  "stop"

  $ possum -p "array('go' | 'stop')" -i "gogogogogogogogogostop"
  [ "go", "go", "go", "go", "go", "go", "go", "go", "go", "stop" ]

  $ possum -p "array_sep(alphas, space)" -i "go go go go go go go go go stop"
  [ "go", "go", "go", "go", "go", "go", "go", "go", "go", "stop" ]

  $ possum -p "table_sep(digit, '-', '|')" -i "1-2-3|4-5-6|7-8-9"
  [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]

  $ possum -p "object(numerals < ':', bool('x', 'y'))" -i "123:x456:y"
  { "123": true, "456": false }

  $ possum -p "object_sep(alphas, ':' < maybe(spaces), alphas, ',' < maybe(spaces))" -i "foo: a, bar: b"
  { "foo": "a", "bar": "b" }

  $ possum -p "input(word)" -i "       **input**     "
  "**input**"

  $ possum -p "fail" -i "some input"
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 1:
  some input
  ^
  
  The last attempted parser was:
  fail
  Destructure
  
  But no match was found.
  [123]

  $ possum -p "succeed" -i "some input"
  null

  $ possum -p "maybe(123)" -i "123"
  123

  $ possum -p "maybe(123)" -i "456"
  null

  $ possum -p "default(array(digit), [])" -i "456"
  [ 4, 5, 6 ]

  $ possum -p "default(array(digit), [])" -i "a"
  []

  $ possum -p "const(true)" -i "456"
  true
