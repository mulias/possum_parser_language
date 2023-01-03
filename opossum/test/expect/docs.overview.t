# Possum Overview

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
  [123]

  $ possum -p "10" -i "0010"
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 1:
  0010
  ^
  
  The last attempted parser was:
  10
  
  But no match was found.
  [123]
```

Built in parsers provide shortcuts for common parsing situations. Some examples
for parsing strings and numbers:
```
  $ possum -p "int" -i "31987abc"
  31987

  $ possum -p "whitespace" -i "       "
  "       "

  $ possum -p "ws" -i "       "
  "       "

  $ possum -p "word" -i "foo bar"
  "foo"
```

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
  [123]
```

The `+` combinator ("concat") combines two string parsers, matching and
returning the two values together. This combinator will fail at runtime if
either parser returns a non-string JSON value.
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
  [123]
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
  [123]
```

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

  $ possum -p "'T' $ true" -i "T"
  true
```

The `&` combinator ("sequence") matches the left-side parser and then matches
the right-side parser. In this case we no longer know what value the
composed parser should return, so a sequence of parsers must always specify
their collective return value using `$`.
```
  $ possum -p "int & ws & int & ws & int $ 'Three numbers!'" -i "1 2 3"
  "Three numbers!"
```

We can also assign parsed values to `UpperCamelCase` variables, and then use
these variables in the returned value. This `Var <- parser` form is only valid in
the sequence of parsers to the left of a `$`.
```
  $ possum -p "I <- int $ I" -i "12 + 99"
  12

  $ possum -p "A <- int & ws & B <- int & ws & C <- int $ [A, B, C]" -i "1 2 3"
  [ 1, 2, 3 ]

  $ possum -p "
  >   Left <- int & ws &
  >   Op <- word & ws &
  >   Right <- int $
  >   {'left': Left, 'op': Op, 'right': Right}
  > " -i "12 + 99"
  { "left": 12, "op": "+", "right": 99 }
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
  [123]
```

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
  >   if(condition, Then) = condition $ Then ;
  >   if(12, true)
  > " -i "12"
  true
```

Similarly, `const` is a parser which always succeeds, consumes no input, and
returns a value.
```
  $ possum -p "
  >  const(Value) = '' $ Value ;
  >  const(['hello', 'world'])
  > " -i "Some input"
  [ "hello", "world" ]
```

Parsers can be recursive and referenced before they are defined.
```
  $ possum -p "
  >  tuple = '{' & A <- int_or_tuple & ',' & B <- int_or_tuple & '}' $ [A, B] ;
  >  int_or_tuple = int | tuple ;
  >  int_or_tuple
  > " -i "{{1,{5,7}},{12,3}}"
  [ [ 1, [ 5, 7 ] ], [ 12, 3 ] ]
```

Recursive parsers can be used to build up arrays and objects using `...` spread
syntax to add the members of an object or array to a new object or array.
```
  $ possum -p "
  >  int_list =
  >    (I <- int & ',' & L <- int_list $ [I, ...L]) |
  >    (I <- int $ [I]) ;
  >  int_list
  > " -i "1,2,3,4,5,6"
  [ 1, 2, 3, 4, 5, 6 ]

  $ possum -p "
  >  rev_int_list =
  >    (I <- int & ',' & L <- rev_int_list $ [...L, I]) |
  >    (I <- int $ [I]) ;
  >  rev_int_list
  > " -i "1,2,3,4,5,6"
  [ 6, 5, 4, 3, 2, 1 ]

  $ possum -p "
  >  field = Key <- many(alpha) & ':' & Val <- int $ {Key: Val} ;
  >  fields = F <- field & ws & Fs <- fields $ {...F, ...Fs} | field ;
  >  fields
  > " -i "foo:33 bar:1"
  { "foo": 33, "bar": 1 }
```

That said, you shouldn't have to worry about recursion in the majority of
cases. Built in parsers such as `array`, `array_sep`, `object`, and
`object_sep` should usually be sufficient.
```
  $ possum -p "array(digit)" -i "1010111001"
  [ 1, 0, 1, 0, 1, 1, 1, 0, 0, 1 ]

  $ possum -p "array_sep(int, ',')" -i "1,2,3,4,5,6"
  [ 1, 2, 3, 4, 5, 6 ]

  $ possum -p "object(many(alpha) < ':', int < maybe(ws))" -i "foo:33 bar:1"
  { "foo": 33, "bar": 1 }

  $ possum -p "object_sep(many(alpha), ':', int, ws+';'+ws)" -i "foo:33 ; bar:1"
  { "foo": 33, "bar": 1 }
```

We can also recursively iterate over values by pattern matching on
assignment. When a pattern is used instead of just a variable the parser will
fail if the parsed value does not match the pattern.
```
  $ possum -p "
  >  zip_pairs(Names, Values) = (
  >    [N, ...Ns] <- const(Names) &
  >    [V, ...Vs] <- const(Values) &
  >    Rest <- zip_pairs(Ns, Vs) $
  >    {N: V, ...Rest}
  >  ) | const({}) ;
  > 
  >  Names <- array(alpha) & ';' & Values <- array(digit) &
  >  Pairs <- zip_pairs(Names, Values) $ Pairs
  > " -i "ABC;123"
  { "A": 1, "B": 2, "C": 3 }
```

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
  [123]

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
  [123]
```
