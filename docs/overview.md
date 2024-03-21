# Possum Overview

This guide covers the basics of Possum and should give you enough context to
handle a wide range of parsing situations.

At a hight level Possum is a command line tool and domain specific scripting
language for turning plain text into JSON. Each example in this guide uses the
`possum` command to execute a Possum program. This program specifies how to read
an input string and build a JSON value out of the contained data. On success the
resulting JSON value is printed to standard out.

In these examples the `-p` or `--parser=` argument defines the parser program,
while the `-i` or `--input=` argument defines the input. The `possum` command
can also read programs and inputs from files, but we're going to keep each
example to one or a few lines, so files won't be necessary.

## Basic Parsers

String literals are parsers which match the characters composing the string and
return a string value on success. String literals can be created with double or
single quotes. JSON strings are encoded with double quotes, so the program
output will always use double quotes.
```
  $ possum -p '"abc"' -i 'abc'
  "abc"

  $ possum -p "'abc'" -i 'abc'
  "abc"
```

Character ranges are parsers that match a single unicode code point that falls
within an inclusive range.
```
  $ possum -p '"a".."z"' -i 'g'
  "g"

  $ possum -p '"😄".."🫠"' -i '😅'
  "😅"
```

Number literals are parsers which match the characters composing the number and
return a number value on success.
```
  $ possum -p '12' -i '1245'
  12

  $ possum --parser='-37' --input='-37'
  -37

  $ possum -p '10.45' -i '10.45'
  10.45

  $ possum -p '1e23' -i '1e23'
  1e23
```

Integer ranges are parsers that match all integers that fall within the range,
inclusive.
```
  $ possum -p '1..9' -i '77'
  7

  $ possum -p '70..80' -i '77'
  77
```

Parsers always start matching from the beginning of the input and return the
longest possible match. Any extra input is thrown out.
```
  $ possum -p '"inp".."input: "' -i 'input: foo bar baz'
  "input: "

  $ possum -p '""' -i 'abc'
  ""
```

If the parser fails to find a match an error is returned.
```
  $ possum -p '"my parser"' -i 'no match here'

  [TODO: error output]
```

## The Standard Library

Possum has a standard library with parsers covering many common parsing
situations. We'll be using parsers from the standard library in our examples,
including the following parsers for strings and numbers.
```
  $ possum -p 'char' -i '123'
  "1"

  $ possum -p 'alpha' -i 'foo bar'
  "f"

  $ possum -p 'word' -i 'foo bar'
  "foo"

  $ possum -p 'spaces' -i '       '
  "       "

  $ possum -p 'newline' -i '
  '
  "\n"

  $ possum -p 'nl' -i '
  '
  "\n"

  $ possum -p 'whitespace' -i '

    '
  "\n\n  "

  $ possum -p 'ws' -i '

    '
  "\n\n  "

  $ possum -p 'digit' -i '31987abc'
  3

  $ possum -p 'int' -i '31987abc'
  31987

  $ possum -p 'number' -i '12.45e-10xyz'
  12.45e-10
```

Some parser functions are parametrized by other parsers. The standard library
parsers `many(p)` and `until(p, stop)` both run a parser one or more times,
returning the concatenation of all of the parsed values.
```
  $ possum -p 'many(alpha)' -i 'abcdefg1234'
  "abcdefg"

  $ possum -p 'until(char, 3)' -i 'abcdefg1234'
  "abcdefg12"
```

The parsers `true(t)`, `false(f)`, `bool(t, f)`, and `null(n)` return the
appropriate constant values when the provided parser matches.
```
  $ possum -p 'true("True")' -i 'True'
  true

  $ possum -p 'false("No")' -i 'No'
  false

  $ possum -p 'bool(1, 0)' -i '0'
  false

  $ possum -p 'null(number)' -i '123'
  null
```

Finally `array(elem)`, `array_sep(elem, sep)`, `object(key, value)`, and
`object_sep(key, pair_sep, value, sep)` return ordered list collections (arrays)
and key/value pair collections (objects).
```
  $ possum -p 'array(digit)' -i '1010111001'
  [ 1, 0, 1, 0, 1, 1, 1, 0, 0, 1 ]

  $ possum -p 'array_sep(int, ',')' -i '1,2,3,4,5,6'
  [ 1, 2, 3, 4, 5, 6 ]

  $ possum -p 'object(alpha, int)' -i 'a12b34c56'
  { "a": 12, "b": 34, "c": 56 }

  $ possum -p 'object_sep(many(alpha), ":", int, " ; ")' -i 'foo:33 ; bar:1'
  { "foo": 33, "bar": 1 }
```

## Debugging

TODO

## Composing Parsers

The infix "or" operator `p1 | p2` tries to match `p1` and then if that fails
tries to match `p2` instead.
```
  $ possum -p '"one" | "two"' -i 'two'
  "two"
```

The "take right" operator `p1 > p2` matches `p1` and then matches and returns
`p2`.
```
  $ possum -p '"one " > "two"' -i 'one two'
  "two"
```

Similarly the "take left" operator `p1 < p2` matches `p1`, keeps the result,
then matches `p2`. If both succeed then `p1` is returned.
```
  $ possum -p '"one" < " two"' -i 'one two'
  "one"

  $ possum -p '"(" > int < ")"' -i '(5)'
  5

  $ possum -p '"one" < " two" | " four"' -i 'one three'

  [TODO: error output]
```

The "merge" operator `p1 + p2` matches `p1` and then `p2` and combines the two
values. The merging behavior for two values of the same type is:

* Concatenate strings

* Concatenate arrays

* Combine objects, adding fields from the right-side object to the left-side
  object, possibly replacing exisiting values.

* Sum numbers

* Leave matching constants unchanged

If the two parsed values have different types then the operation will throw a
runtime error. Note that in JSON `true` and `false` are distinct constants and
therefore can't be merged.
```
  $ possum -p 'ws > word + ws + word < ws' -i '   foo   bar   '
  "foo   bar"

  $ possum -p 'array(digit) + array(alpha)' -i '1123418ahfty'
  [1, 1, 2, 3, 4, 1, 8, "a", "h", "f", "t", "y"]

  $ possum -p '123 + 321' -i '123321'
  444

  $ possum -p 'null("N") + null("N")' -i 'NN'
  null

  $ possum -p 'alpha + digit' -i 'a1'

  [TODO: error output]


  $ possum -p 'bool(1, 0) + bool(1, 0)' -i '10'

  [TODO: error output]
```

The "return" operator `p $ V` matches `p`, and then on success returns the
value `V`.
```
  $ possum -p '12345 $ "Password Accepted"' -i '12345'
  "Password Accepted"

  $ possum -p '"true" $ false' -i 'true'
  false
```

The value on the right-side of `$` can be any valid JSON data, including arrays,
objects, true, false, and null.
```
  $ possum -p '1 > 2 > 3 $ [1, 2, 3]' -i '123'
  [ 1, 2, 3 ]

  $ possum -p '7 $ {"isSeven": true}' -i '7'
  { "isSeven": true }

  $ possum -p '"nil" $ null' -i 'nil'
  null
```

The "destructure" operator `P <- p` matches `p`, and then compares the result
to the pattern `P` on the left. If the parsed value has the same structure as
the pattern then the parser matches and the whole value is returned. The pattern
can be any value, including arrays and objects.
```
  $ possum -p '5 <- int' -i '5'
  5

  $ possum -p '[1, 5, 3] <- array(digit)' -i '153'
  [ 1, 5, 3 ]

  $ possum -p '5 <- int' -i '55'

  [TODO: error output]
```

Patterns can also contain `UpperCamelCase` variables, which match any value and
assign the value to the variable. Variables can be used later in the same
parser.
```
  $ possum -p "N <- number $ [N, N, N]" -i "9"
  [ 9, 9, 9 ]

  $ possum -p "[1, N, 3] <- array(digit) $ N" -i "153"
  5
```

The sequence operator `p1 & p2` matches `p1` and then matches and returns `p2`.
This behavior is similar to `>`, but `&` has lower precedence.
Counter-intuitively, "lower" in this case means that parsers on either side of
the `&` get grouped together, creating a series of parsing steps without extra
parentheses.
```
  $ possum -p "int & ws & int | "foo" & ws & int" -i "1 foo 3"
  3
```

Using the return, destructure, and sequence operators together we can implement
a very common pattern in possum -- matching a sequence of parsers, destructuring
to assign values to variables, and then building a return value using the
variables.
```
  $ possum -p '
      Left <- int & ws &
      Op <- word & ws &
      Right <- int $
      {"left": Left, "op": Op, "right": Right}
    ' -i '12 + 99'
  { "left": 12, "op": "+", "right": 99 }

```

## Defining Parsers

Parsers can be split up and reused by defining the parser and then using it
by name. Parser definitions can be separated by semicolons or newlines.
```
  $ possum -p 'first_field = "first=" > int ; first_field' -i "first=88"
  88

  $ possum -p '
      a = "a"
      skip_x = "x" $ ""
      ax = a | skip_x
      ax + ax + ax + ax + ax + ax + ax
    ' -i 'xxaxaxa'
  "aaa"
```

Named Parsers can be parameterized with other parsers.
```
  $ possum -p 'first_field(p) = "first=" > p ; first_field(int)' -i 'first=111'
  111

  $ possum -p 'first_field(p) = "first=" > p ; first_field(word)' -i 'first=One'
  "One"
```

Named parsers can also be parameterized by values. Here's how to implement `if`,
a parser where the value `Then` is returned when the parser `condition`
succeeds, otherwise `if` fails. Note that parser variables are always
`snake_case` while value variables are always `UpperCamelCase`.
```
  $ possum -p '
      if(condition, Then) = condition $ Then ;
      if(12, true)
    ' -i '12'
  true
```

Parsers can be recursive and referenced before they are defined.
```
  $ possum -p '
      tuple = "{" & A <- int_or_tuple & ";" & B <- int_or_tuple & "}" $ [A, B] ;
      int_or_tuple = int | tuple ;
      int_or_tuple
    ' -i '{{1;{5;7}};{12;3}}'
  [ [ 1, [ 5, 7 ] ], [ 12, 3 ] ]
```

## A Few More Standard Library Parsers

At this point you should be well equipped to browse the standard library, but
here are a few more parsers that you might find particularly useful.

The parser `maybe(p)` runs the provided parser and either returns the parsed
value when the parser succeeds, or returns an empty value when the parser
fails.
```
  $ possum -p '"foo" + maybe("bar") + "baz"' -i 'foobaz'
  "foobaz"
```

Similarly, `default(p, D)` sets a default value to return if the parser fails.
```
  $ possum -p 'default(number, 10)' -i 'foobaz'
  10
```

Once you're happy with a parser, you may want to ensure that it always parses
the whole input by using `end_of_input` or `end` to specify that the end of the
input has been reached.
```
  $ possum -p 'int < end' -i '12'
  12

  $ possum -p 'int < end' -i '12three'

  [TODO: error output]
```

Alternatively, `input(p)` wraps a parser to both strip surrounding whitespace
and make sure the whole input it parsed.
```
  $ possum -p 'input(int)' -i '   12   '
  12
```

Similar to how `array_sep(elem, sep)` handles one-dimensional data with
separators, `table_sep(array, sep, row_sep)` handles two dimensional data with
both column and row separators.
```
  $ possum -p 'input(table_sep(number, spaces, ws))' -i '
    1 2 3                                                                                                                                                                                               [17:47:46]
    4 5 6
    7 8 9
  '
  [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]
```

Use `scan(p)` to skip characters until the provided parser matches.
```
  $ possum -p 'scan(number)' -i 'sdffgerfsdf83324asfdsdf99221'
  83324
```
