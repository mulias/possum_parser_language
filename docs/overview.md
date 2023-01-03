# Possum Overview

## Basic Parsers

String literals are parsers which match the characters composing the string and
return a string value on success. A string literal is denoted by single or
double quotes.
```
  $ possum -p "\"abc\"" -i "abc"
  "abc"

  $ possum -p "'abc'" -i "abc"
  "abc"
```

Number literals are parsers which match the characters composing the number and
return a number value on success.
```
  $ possum -p "12" -i "1245"
  12

  $ possum --parser="-37" --input="-37"
  -37

  $ possum -p "10.45" -i "10.45"
  10.45

  $ possum -p "1e23" -i "1e23"
  1e23
```

Parsers always start matching from the beginning of the input and return the
longest possible match. Any extra input is thrown out.
```
  $ possum -p "'input: '" -i "input: foo bar baz"
  "input: "

  $ possum -p "''" -i "abc"
  ""
```

If the parser fails to find a match an error is returned.
```
  $ possum -p "'my parser'" -i "no match here"

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 1:
  no match here
  ^

  The last attempted parser was:
  "my parser"

  But no match was found.

  $ possum -p "10" -i "0010"

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 1:
  0010
  ^

  The last attempted parser was:
  10

  But no match was found.
```

Built in parser functions provide shortcuts for common parsing situations. Some
examples for parsing strings and numbers:
```
  $ possum -p "char" -i "123"
  "1"

  $ possum -p "alpha" -i "foo bar"
  "f"

  $ possum -p "word" -i "foo bar"
  "foo"

  $ possum -p "whitespace" -i "       "
  "       "

  $ possum -p "ws" -i "       "
  "       "

  $ possum -p "digit" -i "31987abc"
  3

  $ possum -p "int" -i "31987abc"
  31987

  $ possum -p "number" -i "12.45e-10"
  12.45e-10
```

Some parser functions are parametrized by other parsers. The parsers `many` and
`until` both run a parser one or more times, returning the concatenation of all
of the parsed string values.
```
  $ possum -p "many(alpha)" -i "abcdefg1234"
  "abcdefg"

  $ possum -p "until(char, 3)" -i "abcdefg1234"
  "abcdefg12"
```

The parsers `true`, `false`, `bool`, and `null` return the appropriate constant
values when the provided parser matches.
```
  $ possum -p "true('True')" -i "True"
  true

  $ possum -p "false('No')" -i "No"
  false

  $ possum -p "bool(1, 0)" -i "0"
  false

  $ possum -p "null(number)" -i "123"
  null
```

Finally `array`, `array_sep`, `object`, and `object_sep` return ordered list
collections (arrays) and key/value pair collections (objects).
```
  $ possum -p "array(digit)" -i "1010111001"
  [ 1, 0, 1, 0, 1, 1, 1, 0, 0, 1 ]

  $ possum -p "array_sep(int, ',')" -i "1,2,3,4,5,6"
  [ 1, 2, 3, 4, 5, 6 ]

  $ possum -p "object(alpha, int)" -i "a12b34c56"
  { "a": 12, "b": 34, "c": 56 }

  $ possum -p "object_sep(many(alpha), ':', int, ' ; ')" -i "foo:33 ; bar:1"
  { "foo": 33, "bar": 1 }
```

## Composing Parsers

The `|` infix combinator ("or") tries to match the left-side parser and then if
that fails tries to match the right-side parser.
```
  $ possum -p "'one' | 'two'" -i "two"
  "two"
```

The `>` combinator ("take right") matches the left-side parser, throws out the
result, and then matches and returns the right-side parser.
```
  $ possum -p "'one ' > 'two'" -i "one two"
  "two"
```

Similarly the `<` combinator ("take left") matches the left-side parser, keeps
the result, then matches the right-side parser. If the right-side parser
succeeds then the left-side result is returned.
```
  $ possum -p "'one' < ' two'" -i "one two"
  "one"

  $ possum -p "'(' > int < ')'" -i "(5)"
  5

  $ possum -p "'one' < ' two' | ' four'" -i "one three"

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 4:
  one three
     ^

  The last attempted parser was:
  " four"

  But no match was found.
```

The `+` combinator ("concat") combines two string parsers, matching and
returning the two values together. This combinator will fail at runtime if
either parser returns a non-string value.
```
  $ possum -p "ws > word + ws + word < ws" -i "   foo   bar   "
  "foo   bar"

  $ possum -p "alpha + digit" -i "a1"

  Error Concatenating Strings

  ~~~(##)'>  I successfully parsed two values, but couldn't concatenate the result
  because at least one of the values is not a string.

  The parser failed on line 1, characters 1-13:
  alpha + digit
  ^^^^^^^^^^^^^

  The right-side parser returned a number instead of a string.
```

Parsers are greedy. The `word` parser matches all characters up to the next
whitespace. Parsing `word` before a string literal will fail because the string
literal part has already been matched.
```
  $ possum -p "word > 'DEF'" -i "ABCDEF"

  Error Parsing End of Input

  ~~~(##)'>  I reached the end of the input before completing the parser.

  The last attempted parser was:
  "DEF"

  But there's not enough input left to match on.
```

## Building and Destructuring Values

The `$` combinator ("return") matches the left-side parser, and then on success
returns the value specified on the right.
```
  $ possum -p "12345 $ 'Password Accepted'" -i "12345"
  "Password Accepted"

  $ possum -p "'true' $ false" -i "true"
  false
```

The value returned by `$` can be any valid JSON data, including arrays,
objects, true, false, and null.
```
  $ possum -p "1 > 2 > 3 $ [1, 2, 3]" -i "123"
  [ 1, 2, 3 ]

  $ possum -p "7 $ {'is_seven': true}" -i "7"
  { "is_seven": true }

  $ possum -p "'nil' $ null" -i "nil"
  null
```

The `&` combinator ("sequence") matches the left-side parser and then matches
the right-side parser. In this case we no longer know what value the
composed parser should return, so a sequence of parsers must always specify
their collective return value using `$`.
```
  $ possum -p "int & ws & int & ws & int $ 'Three numbers!'" -i "1 2 3"
  "Three numbers!"
```

The `<-` combinator ("destructure") matches the right-side parser, and then
compares the result to the pattern on the left. If the parsed value has the same
structure as the pattern then the parser matches and the whole value is
returned. Pattern can be any value, including arrays and objects. We can use `_`
as a special pattern value to indicate that any value is valid at that place in
the pattern.
```
  $ possum -p "5 <- int" -i "5"
  5

  $ possum -p "[1, _, 3] <- array(digit)" -i "153"

  Error Reading Program

  ~~~(##)'>  I ran into a syntax issue in your program.

  The issue starts on line 1, character 3:
  [1, _, 3] <- array(digit)
    ^

  Eventually there will be a more helpful error message here, but in the meantime
  here's the parsing steps leading up to the failure:
  main_parser
  parser_steps
  step
  json
  json_array

  The last step did not succeed and there were no other options.

  $ possum -p "5 <- int" -i "55"

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 3:
  55
    ^

  The last attempted parser was:
  Destructure

  But no match was found.
```

Patterns can also contain `UpperCamelCase` variables, which match any value and
assign the value to the variable. Variables can be used later in the same
parser.
```
  $ possum -p "
      Left <- int & ws &
      Op <- word & ws &
      Right <- int $
      {'left': Left, 'op': Op, 'right': Right}
    " -i "12 + 99"
  { "left": 12, "op": "+", "right": 99 }

  $ possum -p "[1, N, 3] <- array(digit) $ [N, N, N]" -i "193"
  [ 9, 9, 9 ]
```

Variables in a pattern can only be assigned once. Any subsequent references to a
variable use the previously assigned value. In this example the parser matches
three digits, but only if the second and third digit have the same value as the
first digit.
```
  $ possum -p "D <- digit & D <- digit & D <- digit $ [D, D, D]" -i "444"
  [ 4, 4, 4 ]

  $ possum -p "D <- digit & D <- digit & D <- digit $ [D, D, D]" -i "445"

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 4:
  445
     ^

  The last attempted parser was:
  Destructure

  But no match was found.
```

In addition to returning arrays and objects containing variables as elements,
we can use a variable as the name in a name/value object pair. The variable
must be a string.
```
  $ possum -p "Var <- word & ' = ' & Value <- int $ {Var: Value}" -i "MY_SECRET = 12345"
  { "MY_SECRET": 12345 }

  $ possum -p "Id <- int & ' : ' & Active <- bool('true', 'false') $ {Id: Active}" -i "12345 : true"

  Error Creating Object

  ~~~(##)'>  I wasn't able to create an object because one of the name/value pairs
  has a name which is not a string.

  The parser failed on line 1, characters 56-57:
  Id <- int & ' : ' & Active <- bool('true', 'false') $ {Id: Active}
                                                         ^^

  The value assigned to `Id` is a number, but it needs to be a string in order to
  create a valid object.
```

## Defining Parsers

Parsers can be split up and reused by first defining the parser, then using it
by name. Parser definitions are separated by semicolons.
```
  $ possum -p "first_field = 'first=' > int ; first_field" -i "first=88"
  88
```

Named Parsers can be parameterized with other parsers.
```
  $ possum -p "first_field(p) = 'first=' > p ; first_field(int)" -i "first=111"
  111

  $ possum -p "first_field(p) = 'first=' > p ; first_field(word)" -i "first=One"
  "One"
```

Named parsers can also be parameterized by values. Here's how to implement
`if`, a parser where `Then` is returned when `condition` succeeds, otherwise
the parser fails. Note that parser variables are always `snake_case` while
value variables are always `UpperCamelCase`.
```
  $ possum -p "
      if(condition, Then) = condition $ Then ;
      if(12, true)
    " -i "12"
  true
```

Similarly, `const` is a parser which always succeeds, consumes no input, and
returns a value.
```
  $ possum -p "
      const(Value) = '' $ Value ;
      const(['hello', 'world'])
    " -i "Some input"
  [ "hello", "world" ]
```

Parsers can be recursive and referenced before they are defined.
```
  $ possum -p "
      tuple = '{' & A <- int_or_tuple & ';' & B <- int_or_tuple & '}' $ [A, B] ;
      int_or_tuple = int | tuple ;
      int_or_tuple
    " -i "{{1;{5;7}};{12;3}}"
  [ [ 1, [ 5, 7 ] ], [ 12, 3 ] ]
```

Recursive parsers can be used to build up arrays and objects using `...` spread
syntax to add the members of an object or array to a new object or array.
```
  $ possum -p "
      int_list =
        (I <- int & ',' & L <- int_list $ [I, ...L]) |
        (I <- int $ [I]) ;
      int_list
    " -i "1,2,3,4,5,6"
  [ 1, 2, 3, 4, 5, 6 ]

  $ possum -p "
     rev_int_list =
       (I <- int & ',' & L <- rev_int_list $ [...L, I]) |
       (I <- int $ [I]) ;
     rev_int_list
    " -i "1,2,3,4,5,6"
  [ 6, 5, 4, 3, 2, 1 ]

  $ possum -p "
     field = Key <- many(alpha) & ':' & Val <- int $ {Key: Val} ;
     fields = F <- field & ws & Fs <- fields $ {...F, ...Fs} | field ;
     fields
    " -i "foo:33 bar:1"
  { "foo": 33, "bar": 1 }
```

We can also recursively iterate over arrays and objects via destructuring. Here
`[K, ...Ks] <- const(Keys)` matches when `Keys` is an array with at least one
element. The first element in the array is assigned to `K`, and the remaining
(possibly empty) array is assigned to `Ks`.
```
  $ possum -p "
      zip_pairs(Keys, Values) = (
        [K, ...Ks] <- const(Keys) &
        [V, ...Vs] <- const(Values) &
        Rest <- zip_pairs(Ks, Vs) $
        {K: V, ...Rest}
      ) | const({}) ;

      Keys <- array(alpha) & ';' & Values <- array(digit) &
      Pairs <- zip_pairs(Keys, Values) $ Pairs
    " -i "ABC;123"
  { "A": 1, "B": 2, "C": 3 }
```

## Other helpful parsers

Once you're happy with a parser, you may want to ensure that it always parses
the whole input by using `end_of_input` or `end` to specify the end of the
file/string, or `input` to additionally strip leading and trailing whitespace.
```
  $ possum -p "int < end" -i "12"
  12

  $ possum -p "int < end" -i "12three"

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 3:
  12three
    ^

  The last attempted parser was:
  end

  But no match was found.

  $ possum -p "input(int)" -i "   12   "
  12

  $ possum -p "input(int)" -i "   12three   "

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 6:
     12three
       ^

  The last attempted parser was:
  input

  But no match was found.
```
