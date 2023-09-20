# Possum Language Documentation

The core Possum language provides primitives for creating parsers that transform
unstructured text into JSON. Possum has very few reserved keywords, and instead
relies on infix operators for program logic and control flow. Some of the

## Value Literal Parsers

The simplest parsers are for strings, numbers, and contiguous ranges of strings
or integers.

| Parser      | Name                    | Match Behavior                     | Value Returned |
| ----------- | ----------------------- | ---------------------------------- | -------------- |
| `"abc"`     | String literal          | Characters of string, with escapes | Matched string |
| `'xyz'`     | String literal          | Characters of string, with escapes | Matched string |
| `` `\n` ``  | Backtick string literal | Exact characters of string         | Matched string |
| `"a".."z"`  | String Range            | All strings within range           | Matched string |
| `123`       | Integer literal         | Exact characters of integer        | Matched number |
| `1..9`      | Integer Range           | All integers within range          | Matched number |
| `-1.334e23` | Number literal          | Exact characters of number         | Matched number |

String literals using single and double quotes support the following escape
characters.

| Escape Character | Substitution              |
| ---------------- | ------------------------- |
| `\'`             | Single quote              |
| `\"`             | Double quote              |
| `\\`             | Backslash                 |
| `\n`             | New line                  |
| `\r`             | Carriage return           |
| `\t`             | Tab                       |
| `\b`             | Backspace                 |
| `\f`             | Form feed                 |
| `\u1234`         | 16-bit unicode code-point |
| `\U0010FFFF`     | 32-bit unicode code-point |

In contrast, backtick strings use the exact characters of the string. This means
that while `"\n"` and `'\n'` are string parsers that match a newline, `` `\n` ``
is a string parser that matches a backslash character and then a lowercase "n".
The only character that can't be represented in a backtick string is a backtick.

## Infix Operators

Infix operators compose parsers in order to create more complex parsers.

| Operator       | Name        | Binding Power | Description                             |
| ---------------| ----------- | ------------- | --------------------------------------- |
| `p1 \| p2`     | Or          | 5 / 6         | Match `p1`, if no match is found try `p2` instead |
| `p1 > p2`      | Take Right  | 5 / 6         | Match `p1` and then `p2`, return the result of `p2` |
| `p1 < p2`      | Take Left   | 5 / 6         | Match `p1` and then `p2`, return the result of `p1` |
| `p1 + p2`      | Merge       | 5 / 6         | Match `p1` and then `p2`, if both return values of the same type then return a merged result |
| `p1 ! p2`      | Backtrack   | 5 / 6         | Match `p1` and then go back in the input and match `p2` instead, return the result of `p2` |
| `P <- p`       | Destructure | 7 / 6         | Match `p`, destructure the resulting value against the pattern `P` |
| `p $ V`        | Return      | 5 / 8         | Match `p` and then return the value `V` |
| `p1 & p2`      | Sequence    | 3 / 4         | Match `p1` and then `p2`, returning the result of `p2` |
| `p1 ? p2 : p3` | Conditional | 2 / 1         | Match `p1`, if successful then match `p2` next. If `p1` fails then try `p2` instead. |

Operator precedence is formally defined in terms of "binding power", which
specifies how strongly each operator attracts its left/right operands.
Individual parsers are grouped together into composite parsers based on this
binding power. Parsers are evaluated left to right by grouping, and left to
right within each grouping recursively. Higher binding power produces the
inner-most groupings, while lower binding power corresponds to the outer-most
groupings.

Informally, parsers are grouped by these cases in priority order:
* Values are always grouped with their Return operator
* Patterns are always grouped with their Destructure operator
* Explicit parentheses
* Conditional if/then/else branches
* Either side of a Sequence
* Everything else, left associative

Given this arbitrary example parser
```
p1 | p2 > p3 $ V1 < p4 + P1 <- p5 & p6 | p7 + p8 & p9
```
we can determine operator precedence by repeatedly grouping operators where the
inner binding power is greater than the outer binding power.
```
  p1   |   p2   >   p3   $   V1   <   p4   +   P1   <-   p5   &   p6   |   p7   +   p8   &   p9
0    7   8    7   8    7   11   7   8    7   8    9    8    3   4    7   8    7   8    3   4    0

   (p1 | p2)    >   p3   $   V1   <   p4   +   P1   <-   p5   &   p6   |   p7   +   p8   &   p9
0             7   8    7   11   7   8    7   8    9    8    3   4    7   8    7   8    3   4    0

     ((p1 | p2) > p3)    $   V1   <   p4   +   P1   <-   p5   &   p6   |   p7   +   p8   &   p9
0                      7   11   7   8    7   8    9    8    3   4    7   8    7   8    3   4    0

                                          ...

     ((((p1 | p2) > p3) $ V1) < p4)        +    (P1 <- p5)    &      ((p6 | p7) + p8)    &   p9
0                                        7   8              3   4                      3   4    0

                                          ...

         (((((((p1 | p2) > p3) $ V1) < p4) + (P1 <- p5)) & ((p6 | p7) + p8)) & p9)
```

Viewed as a tree:
```
p1 | p2 > p3 $ V1 < p4 + P1 <- p5 & p6 | p7 + p8 & p9

                                  .------------- & -.
                                  '                 '
                       .--------- & --------.      p9
                       '                    '
                  .----+----.          .--- + -.
                  '         '          '       '
             .--- < -.   .- <- -.   .- | -.   p8
             '       '   '      '   '     '
        .--- $ -.   p4   P1    p5   p6   p7
        '       '
   .--- > -.   V1
   '       '
.- | -.   p3
'     '
p1   p2
```

## Constructing Values

Values are produced by successfully matching parsers against an input. In many
cases the value is implicit, for example we know that the parser `123 | 456`
will either return the value `123`, `456`, or fail. In a few cases values can be
used explicit:

* A returned value, which appears on the right side of a `$`
```
my_parser $ [1,2,3]
```

* Parser arguments
```
bar(B) = "bar" $ B ;
bar({"bar": true})
```

* A pattern to destructure on, which appears on the left side of a `<-`
```
[1, 2, ...Rest] <- array(int)
```

In the first two cases we construct a value which is then returned by a parser.
In the third case we pattern match the result of the right-side parser against
the left-side value, which is explored in more detail in the section
"Destructuring Values".

Constructed values can be any valid JSON data, including arrays, objects, true,
false, and null. Additionally values can be interpolated into strings, numbers
can be added and subtracted, arrays/objects can be combined with `...` spread
syntax, and values of the same type can be merged (see "Merging Values").
Finally, values can reference local variables (from destructuring), and call
value functions.

Type mismatches when constructing values is always a runtime error. For example
`[1, 2, 3, ...{"a": true}]` would produce a runtime error that an object spread
can't be used in an array.


| Constructed Value          | Description                            |
| -------------------------- | -------------------------------------- |
| `Var`                      | Variable for a value                   |
| `"string"`                 | String literal                         |
| `"hello %(Foo)"`           | String interpolation                   |
| `` `hello %(Foo)` ``       | Exact string literal, no interpolation |
| `123`                      | Integer literal                        |
| `-1.334e23`                | Number literal                         |
| `1 + 2e-4`                 | Number arithmetic                      |
| `2.1 - 12`                 | Number arithmetic                      |
| `true`                     | Constant value `true`                  |
| `false`                    | Constant value `false`                 |
| `null`                     | Constant value `null`                  |
| `[ "a", 0, true, Var ]`    | Array of values                        |
| `[ "a", ...Var ]`          | Array, including all of the elements of the array `Var` |
| `{ "foo": 0, "bar": Var }` | Object of key/value pairs              |
| `{ "foo": 0, Var: null }`  | Object with the string `Var` as a key  |
| `{ "foo": 0, ...Var }`     | Object, containing all of the members of the object `Var` |
| `Value1 + Value2`          | Merge two values of the same type      |
| `Reverse([1, 2, 3])`       | Value function                         |

## Merging Values

Both parsers and constructed values can use an infix `+` to merge their result.
If both parsers return values of the same type, or if both values are of the
same type, then the merged value will be a combination of the two values. If the
two values have different types then the operation will throw a runtime error.
Note that in JSON `true` and `false` are distinct constants and therefore can't
be merged.

| `V1` and `V2` Are Both | `V1 + V2` Behavior  |
| ---------------------- | ------------------- |
| Strings                | Concatenate strings |
| Arrays                 | Concatenate arrays  |
| Objects                | Combine objects, adding fields from the right-side object to the left-side object, possibly replacing existing values |
| Numbers                | Sum numbers         |
| `true`                 | `true`              |
| `false`                | `false`             |
| `null`                 | `null`              |

## Destructuring Values

The `<-` pattern matching operator is used to assert the structure of a parsed
value and optionally bind the value or a substructure of the value to local
variables. A patterns can assert the type of a value (string, number, array,
object, constant), its length, constituent elements, and patterns within
elements. Furthermore, when a string or substring encodes a JSON value, that
value can be destructured from within the string.

Bound variables must be `UpperCamelCase`. Values cannot be re-bound within a
parser, so once the variable is set any subsequent uses will reference the
initial value instead of re-binding. The one exception to this rule is that `_`
or any variable starting with an `_` indicates a value that is part of the
pattern but should not be bound.

| Destructured Value      | Description                                               |
| ----------------------- | --------------------------------------------------------- |
| `V <- p`                | Bind a parsed value to `V`                                |
| `0 + N <- p`            | Match a number using arithmetic, bind the value to `N`    |
| `[...A] <- p`           | Match an array using a spread, bind the value to `A`      |
| `{...O} <- p`           | Match an object using a spread, bind the value to `O`     |
| `"%(S)" <- p`           | Match a string using interpolation, bind the value to `S` |
| `` `%(S)` <-p ``        | Match the exact string, no interpolation                  |
| `true <- p`             | Match a constant exactly                                  |
| `5 <- p`                | Match a number exactly                                    |
| `N + 100 <- p`          | Match a number, bind `N` such that `N + 100` is equal to the matched number |
| `[1, 2, 3] <- p`        | Match an array exactly                                    |
| `[A, ..._] <- p`        | Match an array with at least one element, bind the first element to `A` |
| `[A, ..._, Z] <- p`     | Match an array with at least two elements, bind the first element to `A` and last to `Z` |
| `[1, B, _] <- p`        | Match an array of length 3 starting with `1`, bind the second element to `B` |
| `{"a": 1, "b": 2} <- p` | Match an object exactly                                   |
| `{"a": 1, ..._} <- p`   | Match an object where the key `"a"` has the value `1`     |
| `{_: 1, ..._} <- p`     | Match an object where one of the keys has the value `1`   |
| `{"a": A, ..._} <- p`   | Match an object with the key `"a"`, bind the value to `A` |
| `{..._, "a": A} <- p`   | As above, object patterns are not position dependant      |
| `{"a": _, "b": B} <- p` | Match an object with exactly the keys `"a"` and `"b"`, bind the value of `"b"` to `B` |
| `"abc" <- p`            | Match a string exactly                                    |
| `"%3(_)" <- p`          | Match a string of length 3                                |
| `"%3(S)" <- p`          | Bind a string of length 3 to `S`                          |
| `"abc%(Rest)" <- p`     | Match `"abc"` and bind any remaining string to `Rest`     |
| `"%(Front)d" <- p`      | Match a string ending in `d`, bind all but the last character to `Front` |
| `"%1(A)%(_)" <- p`      | Match a string of length at least one, bind the first character to `A` |
| `"%(null)" <- p`        | Match a string encoding a constant                        |
| `"%(0 + N)" <- p`       | Match a string encoding a number, bind the number to `N`  |
| `"%2(0 + _)" <- p`      | Match a string of length 2 encoding a number              |
| `"%(N + 1)" <- p`       | Match a string encoding a number, calculate and bind `N`  |
| `"%([...A])" <- p`      | Match a string encoding an array, bind the array to `A`   |
| `"%({..._})" <- p`      | Match a string encoding an object                         |

## Parser Programs

A program consists of one main parser statement and zero, one, or many named
parser and value statements. Statements may be separated by newlines or
semicolons and can be defined in any order. Named parsers and values may be
functions that specify parameters, and can reference each other and themselves
recursively.

```
parser_1(param1, param2, param3) = parser_body_1
parser_2 = parser_body_2 ; parser_3 = parser_body_3
main_parser
Value1 = ValueBody1
Value2(Param1) = ValueBody2
_private_parser = proviate_parser_body
```

Running a parser program without a main parser produces a runtime error. The
exception to this rule is that additional possum files included via the
`--import` cli option don't need a main parser, and are only evaluated to add
named parsers and values to the namespace.

## Named Parsers

A named parser can be an alias for an existing parser, a composite parser using
infix operators and parser functions, or a parametrized parser function. All
parser names must be `snake_case`.

```
# alias for an existing parser
w = word

# Composit parser
foo_bar = "foo" | "bar"

# Composit parser with recursive reference
foo_foo_foo_bar = "foo" + ("bar" | foo_foo_foo_bar)

# Parametrized parser function
quadruple(p) = A <- p & B <- & C <- p & D <- p $ [A,B,C,D]

# Parser function with a value param
append_const(p, C) = p + const(C)

# Public function referencing a private parser
many(p) = First <- p & _many_rec(p, First)

# Private parser function
_many_rec(p, Acc) = Next <- p ? _many_rec(p, Acc + Next) : const(Acc)
```

## Named Values

A named value can be an alias for a constructed value, a computed value
calculated with infix operators and value functions, or a value function. Named
values can use the same infix operators as parsers, but cannot parse input. All
strings and numbers within the statement are interpreted as values, and
`snake_case` parser aliases/functions are not allowed. All named values must
be `UpperCamelCase`.

```
# Alias for a value
MyArray = [1, 2, 3]

# Alias for a calculated value
MyArrayReversedAndDoubled = RA <- Reverse(MyArray) & RA + RA

# Value function
IsArray(A) = [..._] <- A

# Public function referencing a private function
Reverse(V) =
  IsArray(V) > _RevereseArrayRec(V, []) |
  IsString(V) > _ReverseStringRec(V, "")

# Private value function
_ReverseArrayRec(A, Acc) =
  [Head, ...Tail] <- A ?
  _ReverseArrayRec(Tail, [Head, ...Acc]) :
  Acc
```

This syntax may seem surprising, since up until now the infix operators have
only been used to compose parsers. Named values are, in practice, syntactic
sugar for parsers that never consume input and always return a desired value.
This is true both for names value statements and for value parameters in parser
functions.

We can de-sugar the previous example by replacing every instance of a value `V`
in a parser-only position with a constant parser `"" $ V`.
```
my_array = "" $ [1, 2, 3]

my_array_reversed_and_doubled = RA <- reverse(my_array) $ RA + RA

is_array(a) = [..._] <- a

reverse(v) =
  is_array(v) > _reverese_array_rec(v, "" $ []) |
  is_string(v) > _reverse_string_rec(v, "")

_reverse_array_rec(a, acc) =
  Acc <- acc & [Head, ...Tail] <- a ?
  _reverse_array_rec("" $ Tail, "" $ [Head, ...Acc]) :
  acc
```
Allowing named values to use the same infix operators is a simplification of
this pattern, and provides the guarantee that functions such as `Reverse` will
not consume input, which is not immediately clear when using `reverse` as a
parser.

## Meta Functions

The `@` symbol is reserved as a prefix for parsers and value functions that
perform meta-level introspection and control flow. These functions are built-in
and can't be defined at the program-level.

| Function          | Behavior                                              | Returns               |
| ----------------- | ----------------------------------------------------- | --------------------- |
| `@offset`         | Succeeds with no match                                | Parsing position as a character offset |
| `@line`           | Succeeds with no match                                | Parsing line position |
| `@col`            | Succeeds with no match                                | Parsing col position  |
| `@dbg(p)`         | Parses `p`, prints program state to stderr            | Result of `p`         |
| `@Dbg(V)`         | Prints program state to stderr                        | Value `V`             |
| `@dbg_break(p)`   | Parses `p`, pauses execution and prints program state to stderr | Result of `p` |
| `@DbgBreak(V)`    | Pauses execution and prints program state to stderr   | Value `V`             |
| `@run(p, Str)`    | Parse the string `Str` with `p`, consumes no input    | Result of `p` ran on `Str` |
| `@fail`           | Fail, attribute the failure to parent parser          | N/A                   |
| `@Fail`           | Fail, attribute the failure to parent parser or value | N/A                   |
| `@error(Message)` | Halt the program and report the error with `Message`  | N/A                   |
| `@Error(Message)` | Halt the program and report the error with `Message`  | N/A                   |

## Higher Order Functions

Possum has limit support for
