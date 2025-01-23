# Possum Overview

This guide covers the basics of Possum and should give you enough context to handle a wide range of parsing situations.

At a hight level Possum is a command line tool and domain specific scripting language for turning plain text into JSON. Each example in this guide uses the `possum` command to execute a Possum program. This program specifies how to read an input string and build a JSON value out of the contained data. On success the resulting JSON value is printed to standard out.

In these examples the `-p` argument defines the parser program, while the `-i`  argument defines the input. The `possum` command can also read programs and inputs from files, but we're going to keep each example to one or a few lines, so files won't be necessary.

## The Basics

A Possum program is made up of parsers, functions that define both what text inputs are valid and how to transform valid inputs into structured data. The Possum runtime takes a program and an input string and either successfully parses the input into a JSON encoded value, or fails if the input was malformed.

This section covers parsers that match against specific strings or numbers in the input text, and then returns the matched value unchanged. Later on we'll introduce ways to compose these basic parsers together to make compound parsers that can validate more complex inputs and produce any JSON value as output.

### Literal Parsers

String literals are parsers which match the exact text of the string and return the string value on success.
```
  $ possum -p '"Hello World!"' -i 'Hello World!'
  "Hello World!"
```

String literals can use double or single quotes. JSON strings are encoded with double quotes, so the program output will always use double quotes.
```
  $ possum -p 'Time to "parse some text"' -i 'Time to "parse some text"'
  "Time to \"parse some text\""
```

Number literals are parsers which match the exact digits of a number and return the number value on success. Possum supports the same number format as JSON, which includes positive and negative numbers, integers, and numbers with fraction and/or exponent parts.
```
  $ possum -p '12' -i '1245'
  12

  $ possum -p '-37' -i '-37'
  -37

  $ possum -p '10.45' -i '10.45'
  10.45

  $ possum -p '1e23' -i '1e23'
  1e23
```

### Range Parsers

Character ranges are parsers that match a single Unicode code point that falls within an inclusive range.
```
  $ possum -p '"a".."z"' -i 'g'
  "g"
```

Code points are, broadly speaking, how Unicode defines units of text. This means we can use character range parsers for more than just ASCII characters. The emoji "😄" is code point `U+1F604` and "🤠" is `U+1F920`, so "😅" (`U+1F605`) is in the range. It's worth noting that some units of text are made up of multiple code points stuck together, so character ranges won't work for absolutely everything that looks like a single character. This limitation shouldn't be an issue in the majority of parsing use cases.
```
  $ possum -p '"😄".."🤠"' -i '😅'
  "😅"
```

Integer ranges use the same `..` syntax, but match all integers that fall within an inclusive range.

```
  $ possum -p '1..9' -i '78'
  7

  $ possum -p '70..80' -i '78'
  78
```

### Greed and Failure

Parsers always start matching from the beginning of the input, do not skip over any input, and return the longest possible match.
```
  $ possum -p '"match this: "' -i 'match this: but not this'
  "match this: "
```

After parsing, any extra input is thrown out. This means that the empty string `""` is a parser that always succeeds, no matter the input.
```
  $ possum -p '""' -i 'Call me Ishmael. Some years ago — never mind how long...'
  ""
```

If the parser fails to find a match, Possum returns an error.
```
  $ possum -p '"my parser"' -i 'not my parser'
  [TODO: error output]
```

## The Standard Library

Possum has a standard library with parsers covering many common parsing situations. We'll be using parsers from the standard library in our examples, so here's a quick overview.

### Parsing Strings

Use `char` to parse exactly one character, returning the value as a string.
```
  $ possum -p 'char' -i '123'
  "1"
```

Parse and return an upper- or lower-case letter from the English alphabet with `alpha`. To parse multiple letters try changing `alpha` to `alphas`.
```
  $ possum -p 'alpha' -i 'Foo123! bar'
  "F"

  $ possum -p 'alphas' -i 'Foo123! bar'
  "Foo"
```

Parse and return one or more alphanumeric characters with `word`. This parser also accepts `_` and `-`.
```
  $ possum -p 'word' -i 'Foo123! bar'
  "Foo123"
```

Parse and return one or more non-whitespace characters with `token`.
```
  $ possum -p 'token' -i 'Foo123! bar'
  "Foo123!"
```

Some parsers are parametrized by other parsers. The parser `many(p)` tries to run the parser `p` repeatedly until it no longer succeeds, and returns the concatenation of all of the parsed values.
```
  $ possum -p 'many("a".."d")' -i 'abcdefg'
  "abcd"
```

### Parsing Whitespace

The `space` parser matches a single blank non-line-breaking character. This usually means an ASCII space or tab. By convention `spaces` will instead parse multiple blank characters at once.
```
  $ possum -p 'space' -i '       '
  " "

  $ possum -p 'spaces' -i '       '
  "       "
```

The `newline` parser matches and returns a single line-breaking character. To parse multiple line breaks use `newlines`. These parsers are aliased to the abbreviations `nl` and `nls`, respectively.
```
  $ possum -p 'newline' -i '

  '
  "\n"

  $ possum -p 'newlines' -i '

  '
  "\n\n"

  $ possum -p 'nls' -i '

  '
  "\n\n"
```

To parse all contiguous whitespace use `whitespace` or `ws`.
```
  $ possum -p 'whitespace' -i '

    '
  "\n\n  "

  $ possum -p 'ws' -i '

    '
  "\n\n  "
```

### Parsing Numbers

The `digit` parser matches a single Arabic numeral between `0` and `9`, and returns the numeral as an integer.
```
  $ possum -p 'digit' -i '31987abc'
  3
```

Parse any valid JSON integer with `integer`, or the alias `int`.
```
  $ possum -p 'int' -i '31987abc'
  31987
```

Parse any valid JSON number with `number` or `num`. This includes numbers with fraction and/or exponent parts.
```
  $ possum -p 'number' -i '12.45e-10xyz'
  12.45e-10
```

### Parsing Constants

The parsers `true(t)`, `false(f)`, `bool(t, f)`, and `null(n)` return the appropriate constant values when the provided parser matches.
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

### Parsing Collections

Finally, `array(elem)` and `object(key, value)` return ordered list collections (arrays) and key/value pair collections (objects).
```
  $ possum -p 'array(digit)' -i '1010111001'
  [ 1, 0, 1, 0, 1, 1, 1, 0, 0, 1 ]

  $ possum -p 'object(alpha, int)' -i 'a12b34c56'
  { "a": 12, "b": 34, "c": 56 }
```

Collections frequently use separator characters between elements. You can use `array_sep(elem, sep)` and `object_sep(key, pair_sep, value, sep)` to handle these cases, parsing the separators but excluding them from the result.
```
  $ possum -p 'array_sep(int, ',')' -i '1,2,3,4,5,6'
  [ 1, 2, 3, 4, 5, 6 ]

  $ possum -p 'object_sep(alphas, ":", int, " ; ")' -i 'foo:33 ; bar:1'
  { "foo": 33, "bar": 1 }
```

## Composing Parsers

We've now covered both basic parsers for strings and numbers, and some of the high-level parser functions from Possum's standard library. The last big feature we need is the ability to stick parsers together in order to create larger parsers for more complex inputs. In Possum we do this with *infix operators*, symbols that go between two parsers to change how and when the parsers get ran on the input.

### Or

The "or" operator `p1 | p2` tries to match the parser `p1` and then if that fails tries to match `p2` instead.
```
  $ possum -p '"one" | "two"' -i 'two'
  "two"
```

If both parsers fail then the compound parser fails.
```
  $ possum -p '"one" | "two"' -i 'three'
  [TODO: error output]
```

### Take Right

The "take right" operator `p1 > p2` matches `p1` and then matches and returns `p2`.
```
  $ possum -p '"one" > " " > "two"' -i 'one two'
  "two"
```

If either parser fails then the compound parser fails.
```
  $ possum -p '"three" > " two"' -i 'one two'
  [TODO: error output]
```

### Take Left

Similarly the "take left" operator `p1 < p2` matches `p1`, keeps the result, then matches `p2`. If both succeed then the value parsed by `p1` is returned.
```
  $ possum -p '"one" < " " < "two"' -i 'one two'
  "one"

  $ possum -p '"(" > int < ")"' -i '(5)'
  5
```

If either parser fails then the compound parser fails.
```
  $ possum -p '"one" < " " < "two"' -i 'three'
  [TODO: error output]
```

### Merge

The "merge" operator `p1 + p2` matches `p1` and then `p2` and combines the two values.

Merging will concatenate strings:
```
  $ possum -p 'word + ws + word' -i 'foo   bar'
  "foo   bar"
```

Concatenate arrays:
```
  $ possum -p 'array(digit) + array(alpha)' -i '98765hefty'
  [9, 8, 7, 6, 5, "h", "e", "f", "t", "y"]
```

Combine objects, overwriting existing values:
```
  $ possum -p 'object(char, 0) + object(char, 1)' -i 'a0b0c0c1a1d1'
  {"a": 1, "b": 0, "c": 1, "d": 1}
```

Sum numbers:
```
  $ possum -p '123 + 321' -i '123321'
  444
```

And apply logical "or" to booleans:
```
  $ possum -p 'bool(1, 0) + bool(1, 0)' -i '10'
  true
```

If the two parsed values have different types then the operation will throw a runtime error.
```
  $ possum -p 'alpha + digit' -i 'a1'
  [TODO: error output]
```

The one exception to this rule is the value `null`, which can be merged with any other value, acting as the identity value for that data type:

```
  $ possum -p 'null("N") + int' -i 'N123'
  123
```

### Return

The "return" operator `p $ V` matches `p`, and then on success returns the value `V`.
```
  $ possum -p '12345 $ "Password Accepted"' -i '12345'
  "Password Accepted"

  $ possum -p '"too true" $ true' -i 'too true'
  true
```

The value on the right-side of `$` can be any valid JSON data, including arrays, objects, true, false, and null.
```
  $ possum -p '1 > 2 > 3 $ [1, 2, 3]' -i '123'
  [1, 2, 3]

  $ possum -p '7 $ {"isSeven": true}' -i '7'
  {"isSeven": true}

  $ possum -p '"nil" $ null' -i 'nil'
  null
```

### Destructure

The "destructure" operator `p -> P` matches `p`, and then compares the result to the pattern `P`. If the parsed value has the same structure as the pattern then the parser matches and the whole value is returned. The pattern can be any value, including arrays and objects.
```
  $ possum -p 'int -> 5' -i '5'
  5

  $ possum -p 'array(digit) -> [1, 5, 3]' -i '153'
  [ 1, 5, 3 ]
```

If the parsed value does not match the pattern then the parser fails.
```
  $ possum -p 'int -> 5' -i '55'
  [TODO: error output]
```

Patterns can also contain `UpperCamelCase` variables, which match any value and assign the value to the variable. Variables can be used later in the same parser.

```
  $ possum -p "number -> N $ [N, N, N]" -i "9"
  [ 9, 9, 9 ]

  $ possum -p "array(digit) -> [1, N, 3] $ N" -i "153"
  5
```

### Sequence

The "sequence" operator `p1 & p2` matches `p1` and then matches and returns `p2`. This behavior is similar to `>`, but `&` has a more general precedence, grouping parts of a parser together in a similar way to parentheses. Because of this `>` is best suited for parsing and then ignoring a value within a parsing step, while `&` is more useful in stringing together a list of steps. Instead of grouping like this:
```
  $ possum -p 'int > ws > (int | "foo") > ws > (int | "bar")' -i '1 foo 3'
  3
```

A sequence of parsers can be written like this:
```
  $ possum -p 'int & ws & int | "foo" & ws & int | "bar"' -i '1 foo 3'
  3
```

### Putting it all together

Using the return, destructure, and sequence operators together we can implement a very common pattern in Possum — matching a sequence of parsers, destructuring to assign values to variables, and then building a return value using the variables.
```
  $ possum -p '
      int   -> Left  & ws &
      token -> Op    & ws &
      int   -> Right $
      {"left": Left, "op": Op, "right": Right}
    ' -i '12 + 99'
  { "left": 12, "op": "+", "right": 99 }
```

## Defining Parsers

A Possum program must have one *main parser*, and can optionally declare any number of *named parsers*. Parsers must be separated either by newlines or semicolons. Named parsers are declared with the syntax `name = parser`. At runtime Possum executes the main parser, which can reference named parsers declared in the program in the same way we reference named parsers from the standard library.
```
  $ possum -p '
      field = alphas > "=" > int
      array_sep(field, ws)
    ' -i 'first=88 second=0 third=-10'
  [88, 0, -10]
```

Named Parsers can be parameterized with both parsers and values. Parser params are always `snake_case` while value params are always `UpperCamelCase`.
```
  $ possum -p '
      if(condition, Then) = condition $ Then
      if(12345, ["return", "this", "array"])
    ' -i '12345'
  ["return", "this", "array"]
```

There's one edge case when passing values as parser args, which is that values which could be confused with parsers must be prefixed with a `$`. This includes strings, numbers, and the constants `true`, `false`, and `null`. Arrays, objects, and `UpperCamelCase` variables are always values, so there's no need to disambiguate.
```
  $ possum -p '
      if(condition, Then) = condition $ Then
      if(12345, $"return this string")
    ' -i '12345'
  "return this string"
```

Named parsers can be recursive and referenced before they are declared. The main parser can come before, after, or in between named parser declarations.
```
  $ possum -p '
      int_or_tuple

      int_or_tuple = int | tuple

      tuple = "{" &
        int_or_tuple -> A & ";" &
        int_or_tuple -> B & "}" $
        [A, B]
    ' -i '{{1;{5;7}};{12;3}}'
  [ [ 1, [ 5, 7 ] ], [ 12, 3 ] ]
```

## A Few More Standard Library Parsers

At this point you should be well equipped to browse the standard library, but here are a few more parsers that you might find particularly useful.

The parser `maybe(p)` runs `p` and either returns the parsed value if `p` succeeds, or returns `null` if `p` fails. This means `maybe(p)` will never fail, and can be merged with any other value in a concatenated output.
```
  $ possum -p '"foo" + maybe("bar") + "baz"' -i 'foobaz'
  "foobaz"
```

Similarly, `skip(p)` runs `p`, but on success always returns `null`. Since `null` can merge with any value this allows parts of the input to be ignored in a concatenated output.
```
  $ possum -p '"foo" + skip("bar") + "baz"' -i 'foobarbaz'
  "foobaz"
```

Once you're happy with a parser, you may want to ensure that it always parses the whole input by using `end_of_input` or `end` to specify that the end of the input has been reached.
```
  $ possum -p 'int < end' -i '123'
  123
```

If `end` finds unparsed input then it fails.
```
  $ possum -p 'int < end' -i '12three'
  [TODO: error output]
```

Alternatively, `input(p)` wraps a parser to both strip surrounding whitespace and make sure the whole input is parsed.
```
  $ possum -p 'input(int)' -i '   123   '
  123
```

Use `find(p)` to skip characters until the provided parser matches.
```
  $ possum -p 'find(number)' -i '___test___83324____99'
  83324
```

Similar to how `array_sep(elem, sep)` handles one-dimensional data with separators, `rows(elem, col_sep, row_sep)` handles two dimensional data with both column and row separators.

```
  $ possum -p 'input(rows(num, spaces, ws))' -i '
    1 2 3 4 5
    0 1 2 3 4
    4 5 6 1 2
  '
  [[1, 2, 3, 4, 5], [0, 1, 2, 3, 4], [4, 5, 6, 1, 2]]
```

## ~~~(##)'> Conclusion

We've made it — that's just about everything you need to know to be productive with Possum. In the very first example we matched and returned a string input exactly, but with just a few changes we can extend that parser to handle any number of variations or requirements.

```
  $ possum -p '"Hello" + ws + word + "!"' -i 'Hello Possum!'
  "Hello Possum!"
```
