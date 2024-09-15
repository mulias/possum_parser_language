# Possum Language Documentation

Possum is a text parsing language with some very minimal utilities for general purpose computation. A Possum program is made up of parsers, functions that define both what text inputs are valid and how to transform valid inputs into structured data. The Possum runtime takes a program and an input string and either successfully parses the input into a JSON encoded value, or fails if the input does not meet the parser requirements.

## Value Literal Parsers

The simplest parsers are for strings, numbers, and contiguous ranges of codepoints or integers.

| Parser      | Name            | Match Behavior              | Value Returned |
| ----------- | --------------- | --------------------------- | -------------- |
| `"abc"`     | String literal  | Characters of string, with escapes | Matched string |
| `'xyz'`     | String literal  | Characters of string, with escapes | Matched string |
| `` `\n` ``  | Backtick string literal | Exact characters of string | Matched string |
| `123`       | Integer literal | Exact characters of integer | Matched number |
| `-1.334e23` | Number literal  | Exact characters of number  | Matched number |
| `"a".."z"`  | Character Range | One unicode codepoint within range | Matched string |
| `1..9`      | Integer Range   | One integer within range    | Matched number |
| `"~"..`     | Lower bounded range | One codepoint or integer greater than or equal to the lower bound | Matched string/number |
| `..100`     | Upper bounded range | One codepoint or integer less than or equal to the upper bound | Matched string/number |

String literals using single and double quotes support the following escape characters.

| Escape Character | Substitution               |
| ---------------- | -------------------------- |
| `\0`             | Null character             |
| `\b`             | Backspace                  |
| `\t`             | Tab                        |
| `\n`             | New line                   |
| `\v`             | Vertical tab               |
| `\f`             | Form feed                  |
| `\r`             | Carriage return            |
| `\'`             | Single quote               |
| `\"`             | Double quote               |
| `\\`             | Backslash                  |
| `\u000000` to `\u10FFFF` | unicode code-point |

## Infix Operators

Infix operators compose parsers in order to create more complex parsers.

| Operator       | Name        | Precedence | Associativity | Description      |
| -------------- | ----------- | ---------- | ------------- | -----------------|
| `p1 \| p2`     | Or          | 3          | Left          | Match `p1`, if no match is found try `p2` instead |
| `p1 > p2`      | Take Right  | 3          | Left          | Match `p1` and then `p2`, return the result of `p2` |
| `p1 < p2`      | Take Left   | 3          | Left          | Match `p1` and then `p2`, return the result of `p1` |
| `p1 + p2`      | Merge       | 3          | Left          | Match `p1` and then `p2`, return a merged result |
| `p1 ! p2`      | Backtrack   | 3          | Left          | Match `p1` and then go back in the input and match `p2` instead, return the result of `p2` |
| `p -> P`       | Destructure | 3          | Left          | Match `p`, destructure the resulting value against the pattern `P` |
| `p $ V`        | Return      | 3          | Left          | Match `p` and then return the value `V` |
| `p1 & p2`      | Sequence    | 2          | Left          | Match `p1` and then `p2`, returning the result of `p2` |
| `p1 ? p2 : p3` | Conditional | 1          | Right         | Match `p1`, if successful then match `p2` next. If `p1` fails then try `p2` instead. |

Operators with a higher precedence are evaluated first, and parsers with the same precedence are generally evaluated left to right. Conditionals are right associative so that multiple conditions can be chained in a row.

## Parser Interpolation for Strings

TODO

## Constructing Values

Values are produced by successfully matching parsers against an input. In many cases the value is implicit, for example we know that the parser `123 | 456` will either return the value `123`, `456`, or fail. In a few cases values can be used explicit:

* A returned value, which appears on the right side of a `$`
```
my_parser $ [1, 2, 3]
```

* Parser arguments
```
bar(B) = "bar" $ B ;
bar({"bar": true})
```

* A pattern to destructure on, which appears on the right side of a `->`
```
array(int) -> [1, 2, ...Rest]
```

In the first two cases we construct a value which is then returned by a parser. In the third case we pattern match the result of the right-side parser against the left-side value, which is explored in more detail in the section "Destructuring Values".

Constructed values can be any valid JSON data, including arrays, objects, `true`, `false`, and `null`. Additionally values can be interpolated into strings, numbers can be added and subtracted, and values of the same type can be merged (see "Merging Values"). Finally, values can reference local variables (from destructuring), and call value functions.

| Constructed Value          | Description                            |
| -------------------------- | -------------------------------------- |
| `Var`                      | Variable for a value                   |
| `"string"`                 | String literal                         |
| `"My name is %(MyName)"`   | String interpolation                   |
| `123`                      | Integer literal                        |
| `-1.334e23`                | Number literal                         |
| `1 + 2e-4`                 | Number arithmetic                      |
| `2.1 - 12`                 | Number arithmetic                      |
| `true`                     | Constant value `true`                  |
| `false`                    | Constant value `false`                 |
| `null`                     | Constant value `null`                  |
| `["a", 0, true, Var]`      | Array of values                        |
| `{"foo": 0, "bar": Var}`   | Object of key/value pairs              |
| `{"foo": 0, Var: null}`    | Object with the string `Var` as a key  |
| `Value1 + Value2`          | Merge two values                       |
| `Reverse([1, 2, 3])`       | Value function                         |

## Merging Values

Both parsers and constructed values can use an infix `+` to merge their result. If both parsers return values of the same type, or if both values are of the same type, then the merged value will be a combination of the two values. If the two values have different types then the operation will throw a runtime error. The one exception is `null`, which can merge with any other type and acts as the identity of that type.

| `V1` and `V2` Are Both | `V1 + V2` Behavior  |
| ---------------------- | ------------------- |
| Strings                | Concatenate strings |
| Arrays                 | Concatenate arrays  |
| Objects                | Combine objects, adding fields from the right-side object to the left-side object, possibly replacing existing values |
| Numbers                | Sum numbers         |
| Booleans               | Logical or          |

## Destructuring Values

The `->` pattern matching operator is used to assert the structure of a parsed value and optionally bind the value or a substructure of the value to local variables.

Bound variables must be `UpperCamelCase`. Values cannot be re-bound within a parser, so once the variable is set any subsequent uses will reference the initial value instead of re-binding.

| Destructured Value      | Description                                               |
| ----------------------- | --------------------------------------------------------- |
| `p -> V`                | Bind a parsed value to `V`                                |
| `p -> (0 + N)`          | Match a number using arithmetic, bind the value to `N`    |
| `p -> [...A]`           | Match an array using a spread, bind the value to `A`      |
| `p -> {...O}`           | Match an object using a spread, bind the value to `O`     |
| `p -> "%(S)"`           | Match a string using interpolation, bind the value to `S` |
| `` p -> `%(S)` ``       | Match the exact string, no interpolation                  |
| `p -> true`             | Match a constant exactly                                  |
| `p -> 5`                | Match a number exactly                                    |
| `p -> N + 100`          | Match a number, bind `N` such that `N + 100` is equal to the matched number |
| `p -> [1, 2, 3]`        | Match an array exactly                                    |
| `p -> [A, ..._]`        | Match an array with at least one element, bind the first element to `A` |
| `p -> [A, ..._, Z]`     | Match an array with at least two elements, bind the first element to `A` and last to `Z` |
| `p -> [1, B, _]`        | Match an array of length 3 starting with `1`, bind the second element to `B` |
| `p -> {"a": 1, "b": 2}` | Match an object exactly                                   |
| `p -> {"a": 1, ..._}`   | Match an object where the key `"a"` has the value `1`     |
| `p -> {_: 1, ..._}`     | Match an object where one of the keys has the value `1`   |
| `p -> {"a": A, ..._}`   | Match an object with the key `"a"`, bind the value to `A` |
| `p -> {..._, "a": A}`   | As above, object patterns are not position dependant      |
| `p -> {"a": _, "b": B}` | Match an object with exactly the keys `"a"` and `"b"`, bind the value of `"b"` to `B` |
| `p -> "abc"`            | Match a string exactly                                    |
| `p -> "%3(S)"`          | Bind a string of length 3 to `S`                          |
| `p -> "abc%(Rest)"`     | Match `"abc"` and bind any remaining string to `Rest`     |
| `p -> "%(Front)d"`      | Match a string ending in `d`, bind all but the last character to `Front` |
| `p -> "%1(A)%(_)"`      | Match a string of length at least one, bind the first character to `A` |
| `p -> "%(null)"`        | Match a string encoding a constant                        |
| `p -> "%(0 + N)"`       | Match a string encoding a number, bind the number to `N`  |
| `p -> "%2(0 + _)"`      | Match a string of length 2 encoding a number              |
| `p -> "%(N + 1)"`       | Match a string encoding a number, calculate and bind `N`  |
| `p -> "%([...A])"`      | Match a string encoding an array, bind the array to `A`   |
| `p -> "%({..._})"`      | Match a string encoding an object                         |

## Parser Programs

A program consists of one main parser statement and zero, one, or many parsers and value functions. Statements may be separated by newlines or semicolons and can be defined in any order. Named parsers and values may be functions that specify parameters, and can reference each other and themselves recursively.

```
parser_1(param1, param2, param3) = parser_body_1
parser_2 = parser_body_2 ; parser_3 = parser_body_3
main_parser
Value1 = ValueBody1
Value2(Param1) = ValueBody2
_private_parser = proviate_parser_body
```

Running a parser program without a main parser produces a runtime error.

## Named Parsers

A named parser can be an alias for an existing parser, or a new parser that may be parametrized by other parsers and values. All parser names must be `snake_case`.

```
# Alias for an existing parser
my_array = array

# Zero-arg parser
foo_or_array_of_foo = "foo" | my_array("foo")

# Parser with recursive reference
foo_foo_foo_bar = "foo" + ("bar" | foo_foo_foo_bar)

# Parametrized parser
quadruple(p) = p -> A & p -> B & p -> C & p -> D $ [A,B,C,D]

# Parser with a value param
merge_const(p, C) = p + const(C)

# Public parser referencing a private parser
many(p) = p -> First & _many(p, First)

# Private parser
_many(p, Acc) = p -> Next ? _many(p, Acc + Next) : const(Acc)
```

## Value Functions

A value function can be an alias for an existing value function, or a new function that may be parametrized by other values. All value function names must be `UpperCamelCase`.

Unlike parsers, value functions don't consume input and can only manipulate and return concrete values. Value functions may use the same infix operators as parsers, but in this context the operators only act as control flow. All value functions must be invoked with parentheses, even when the function takes no arguments. An `UpperCamelCase` value without `()` is assumed to be a local variable.

```
# Alias for an existing value function
MyReverse = Reverse

# Zero-arg value function
MyArray = [1, 2, 3]

# Zero-arg value function
MyArrayReversedAndDoubled = MyReverse(MyArray()) -> RA & RA + RA

# Value function
IsArray(A) = A -> [..._]

# Public function referencing a private function
Reverse(V) =
  IsArray(V) > _ReverseArray(V, []) |
  IsString(V) > _ReverseString(V, "")

# Private value function
_ReverseArray(A, Acc) =
  A -> [First, ...Rest] ?
  _ReverseArray(Rest, [...Acc, First]) :
  Acc
```

This syntax may seem surprising, since up until now the infix operators have only been used to compose parsers. Value functions are, in practice, syntactic sugar for parsers that never consume input and always return a desired value. We can de-sugar the previous example by replacing every instance of a value `V` in a parser-only position with a constant parser `"" $ V`.
```
my_reverse = my_reverse

my_array = "" $ [1, 2, 3]

my_array_reversed_and_doubled = reverse(my_array) -> RA & "" $ RA + RA

is_array(A) = "" $ A -> [..._]

reverse(V) =
  is_array(V) > _reverese_array(V, []) |
  is_string(V) > _reverse_string_rec(V, "")

_reverse_array(A, Acc) =
  "" $ A -> [First, ...Rest] ?
  _reverse_array(Rest, [...Acc, First]) :
  "" $ Acc
```

## Meta Functions

The `@` symbol is reserved as a prefix for parsers and value functions that perform meta-level introspection and control flow. These functions are built-in and can't be defined at the program level.

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
