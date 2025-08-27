# Possum Language Documentation

Possum is a text parsing language with some support for general purpose computation. A Possum program is made up of parsers, functions that define both what text inputs are valid and how to transform valid inputs into structured data. The Possum runtime takes a program and an input string and either successfully parses the input into a JSON encoded value, or fails if the input does not meet the parser requirements.

## Literal Parsers

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

Infix operators compose parsers to create more complex parsers.

| Operator       | Name        | Precedence | Associativity | Description      |
| -------------- | ----------- | ---------- | ------------- | -----------------|
| `p1 > p2`      | Take Right  | 3          | Left          | Match `p1` and then `p2`, return the result of `p2` |
| `p1 < p2`      | Take Left   | 3          | Left          | Match `p1` and then `p2`, return the result of `p1` |
| `p1 \| p2`     | Or          | 3          | Right         | Match `p1`, if no match is found try `p2` instead |
| `p1 ! p2`      | Backtrack   | 3          | Right         | Match `p1` and then go back in the input and match `p2` instead, return the result of `p2` |
| `p1 + p2`      | Merge       | 3          | Left          | Match `p1` and then `p2`, return a merged result |
| `p $ V`        | Return      | 3          | Left          | Match `p` and then return the value `V` |
| `p -> P`       | Destructure | 3          | Left          | Match `p`, compare the resulting value against the pattern `P` |
| `p * P`        | Repeat      | 3          | Left          | Match `p` a number of times determined by the pattern `P`, merge all results |
| `p1 & p2`      | Sequence    | 2          | Left          | Match `p1` and then `p2`, returning the result of `p2` |
| `p1 ? p2 : p3` | Conditional | 1          | Right         | Match `p1`, if successful then match `p2` next. If `p1` fails then try `p3` instead |

Operators with a higher precedence are evaluated first, and parsers with the same precedence are generally evaluated left to right.

### Merge

The merge operator `p1 + p2` combines parsed values of the same type. If the two values have different types then the operation will throw a runtime error. The one exception is `null`, which can merge with any other type and acts as the identity of that type.

| `p1` and `p2` both return | `p1 + p2` Behavior  |
| ------------------------- | ------------------- |
| Strings                   | Concatenate strings |
| Arrays                    | Concatenate arrays  |
| Objects                   | Combine objects, overwriting existing `V1` values with `V2` values |
| Numbers                   | Sum numbers         |
| Booleans                  | Logical or          |
| null                      | null                |

### Return

When a parser successfully matches against the input it returns a JSON value. In many cases the return value is implicit, for example we know that the parser `123 | 456` will either return the value `123`, `456`, or fail. In contrast, the return operator `p $ V` first matches `p`, and then on success returns an explicitly constructed value `V`.

Constructed values can be any valid JSON data, including arrays, objects, `true`, `false`, and `null`. Values can also reference variables, call value functions, be interpolated into strings, numbers can be modified with arithmetic, and arrays and objects can be combined with `...` spread syntax. Finally, in a value context all of the infix operators have similar behaviors, but do not match against the input.

| Constructed Value          | Description                            |
| -------------------------- | -------------------------------------- |
| `Var`                      | Variable for a value                   |
| `"string"`                 | String literal                         |
| `"Hello %(Name)"`          | String interpolation                   |
| `123`                      | Integer literal                        |
| `-1.334e23`                | Number literal                         |
| `1 + 2e-4`                 | Number arithmetic                      |
| `2.1 - 12`                 | Number arithmetic                      |
| `2.1 * 12`                 | Number arithmetic                      |
| `2.1 / 12`                 | Number arithmetic                      |
| `2 ^ 5`                    | Number arithmetic                      |
| `true`                     | Constant value `true`                  |
| `false`                    | Constant value `false`                 |
| `null`                     | Constant value `null`                  |
| `["a", 0, true, Var]`      | Array of values                        |
| `[1, 2, ...Nums]`          | Array including all elements from `Nums` array |
| `{"foo": 0, "bar": Var}`   | Object of key/value pairs              |
| `{"foo": 0, Var: null}`    | Object with the string value of variable `Var` as a key  |
| `{...Stuff, "things": true }` | Object including all entries from `Stuff` object |
| `Reverse([1, 2, 3])`       | Value function                         |
| `Is.Number(N) ? N + 1 : 0` | Control flow                           |
| `MyArray -> [A, B, C]`     | Destructure                            |

| Operator       | Description                             |
| -------------- | --------------------------------------- |
| `V1 > V2`      | Compute `V1` and `V2`, return `V2`      |
| `V1 < V2`      | Compute `V1` and `V2`, return `V1`      |
| `V1 \| V2`     | Compute `V1`, on failure try `V2` instead |
| `V1 ! V2`      | Same as `>`                             |
| `V1 + V2`      | Compute `V1` and `V2`, return a merged result |
| `V1 $ V2`      | Same as `>`                             |
| `V -> P`       | Compute `V`, destructure against the pattern `P` |
| `V * P`        | Compute `V`, merge with self a number of times determined by the pattern `P` |
| `V1 & V2`      | Compute `V1` and `V2`, return `V2`
| `V1 ? V2 : V3` | Compute `V1`, if successful then compute `V2`. If `V1` fails then try `V3` instead |

Despite not interacting with the parsing state, values still have a concept of failure which is used in control flow. Values can fail by either calling the `@Fail` builtin function, or by failing to destructure against a pattern.

### Destructure

The `p -> P` destructure operator asserts that a parsed value matches the structure of a pattern and optionally binds the value or a substructure of the value to local variables. After `p` successfully parses part of the input the resulting value is destructured against the pattern. If the value and pattern match structurally then parsing succeeds. If the value and pattern do not match structurally then the destructure fails.

Patterns can contain variables that are both bound and unbound. Variables must be `UpperCamelCase`. Variables cannot be re-bound within a parser, so once the variable is set any subsequent references will use the bound value instead of re-binding.

| Destructured Value      | Description                                               |
| ----------------------- | --------------------------------------------------------- |
| `p -> V`                | Match a value `V`, or if unbound set `V` to the parsed value |
| `p -> "abc"`            | Match a string exactly                                    |
| `` p -> `\nfoo` ``       | Match the exact string `"\nfoo"`, no escapes             |
| `p -> "%('a'..'z')%(_)"` | Match a string that starts with a character between "a" and "z", inclusive |
| `p -> (\u000000.. * 10)` | Match any string of length 10                            |
| `p -> true`             | Match a constant exactly                                  |
| `p -> 5`                | Match a number exactly                                    |
| `p -> 2..7`             | Match a number between 2 and 7, inclusive                 |
| `p -> (0 + N)`          | Match the exact number `N`, or if unbound match any number and bind the value to `N` |
| `p -> (N + 100)`        | Match the exact number, or if `N` is unbound match any number and bind such that `N + 100` is equal to the parsed value |
| `p -> [1, 2, 3]`        | Match an array exactly                                    |
| `p -> [A, ..._]`        | Match an array with at least one element, match or bind the first element to `A` |
| `p -> ([A] * 5`)        | Match an array of 5 identical elements, match or bind the repeated element to `A` |
| `p -> [A, ..._, Z]`     | Match an array with at least two elements, match or bind the first element to `A` and last to `Z` |
| `p -> [1, B, _]`        | Match an array of length 3 starting with `1`, match or bind the second element to `B` |
| `p -> {"a": 1, "b": 2}` | Match an object exactly                                   |
| `p -> {"a": 1, ..._}`   | Match an object where the key `"a"` has the value `1`     |
| `p -> {_: 1, ..._}`     | Match an object where one of the keys has the value `1`   |
| `p -> {"a": A, ..._}`   | Match an object with the key `"a"`, match or bind the value to `A` |
| `p -> {..._, "a": A}`   | As above, object patterns are not position dependant      |
| `p -> {"a": _, "b": B}` | Match an object with exactly the keys `"a"` and `"b"`, match or bind the value of `"b"` to `B` |
| `p -> [...A]`           | Match the array `A`, or if unbound bind the value to `A`  |
| `p -> {...O}`           | Match the object `O`, or if unbound bind the value to `O` |
| `p -> "%(S)"`           | Match the string `S`, or if unbound bind the value to `S` |
| `p -> "%(null)"`        | Match a string encoding a constant                        |
| `p -> "%(0 + N)"`       | Match a string encoding a number, match or bind the number to `N` |
| `p -> "%(N + 1)"`       | Match a string encoding a number, match or bind the calculated value of `N`  |
| `p -> "%([...A])"`      | Match a string encoding an array, match or bind the array to `A` |
| `p -> "%({..._})"`      | Match a string encoding any object                        |

This list is not exhaustive. Pattern matching in Possum is intended to be maximally flexible, but with some notable limitations:
  - No control flow operators (`>`, `<`, `|`, `!`, `&`, `?:`)
  - No nested destructuring
  - Only one value may be an unknown subset of a larger structure, guaranteeing that there is only one way to interpret the pattern
    - `foo -> [[A, B], C, ...D, {...E}, F]` is fine, since despite having many potentially unbound variables only `D` is a subset of the outer array pattern with unknown length, and only `E` is a subset of the second to last array pattern element, which must be an object.
    - `foo -> [1, ...A, 5, ...B, 10]` will not compile, since both `A` and `B` are subsets of the array. In this case there are some values that have a single solution, such as `[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]`, while other values could bind `A` and `B` in multiple ways, such as `[1, 5, 5, 5, 5, 5, 10]`.

### Repeat

The repeat operator `p * P` runs the parser `p` multiple times in a row, merging the results together into one value. The right-side pattern determines the number of repeats, and must be an integer, integer range, or contain unbound variables witch will be bound to concrete integer values.

| Destructured Value      | Description                                               |
| ----------------------- | --------------------------------------------------------- |
| `p * 5`                 | `p` exactly 5 times                                       |
| `p * (9 + 2)`           | `p` exactly 11 times                                      |
| `p * (3 - 3)`           | `p` zero times, always succeeds with `null`               |
| `p * (2 * 3)`           | `p` exactly 6 times                                       |
| `p * 0..`               | `p` zero or more times                                    |
| `p * ..3`               | `p` zero to 3 times                                       |
| `p * 1..100`            | `p` one to 100 times                                      |
| `p * N`                 | `p` exactly `N` times, or if `N` is unbound parse `p` zero or more times and bind the number of repeats to `N` |
| `p * (N + 2)`           | `p` exactly `N + 2` times, or zero or more times and bind the calculated value of `N` |

The pattern may not contain more than one unbound variable.

If the repeated parser succeeds after zero matches the resulting value is `null`. The repeated merging behavior depends on the type of the parsed value, as defined by the `+` merge operator. For example `1..9 * 5` parses the input `12345` as `1 + 2 + 3 + 4 + 5 = 15`, while `1..9 -> D $ [D] * 5` parses the same input as `[1, 2, 3, 4, 5]`.

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

## Named Parsers

A named parser can be an alias for an existing parser, or a new parser function that may be parametrized by other parsers and values. All parser names must be `snake_case`.

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

Unlike parsers, value functions don't consume input and can only manipulate and return concrete values. Value functions may use the same infix operators as parsers, but in this context the operators only act as control flow.

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

Value functions are, in practice, syntactic sugar for parsers that never consume input and always return a desired value. We can de-sugar the previous example by replacing every instance of a value `V` in a parser-only position with a constant parser `"" $ V`.
```
my_reverse = my_reverse

my_array = "" $ [1, 2, 3]

my_array_reversed_and_doubled = reverse(my_array) -> RA & "" $ RA + RA

is_array(A) = "" $ (A -> [..._])

reverse(V) =
  is_array(V) > _reverese_array(V, []) |
  is_string(V) > _reverse_string_rec(V, "")

_reverse_array(A, Acc) =
  "" $ A -> [First, ...Rest] ?
  _reverse_array(Rest, [...Acc, First]) :
  "" $ Acc
```

## Builtins

The `@` symbol is reserved as a prefix for builtin parsers and value functions. These functions can't be defined at the program level.

| Function          | Behavior                                              | Returns               |
| ----------------- | ----------------------------------------------------- | --------------------- |
| `@fail`           | Fail, attribute the failure to parent parser          | N/A                   |
| `@Fail`           | Fail, attribute the failure to parent parser or value | N/A                   |
| `@Crash(Message)` | Halt the program and report the error with `Message`  | N/A                   |
| `@dbg(p)`         | Parses `p`, prints program state to stderr            | Result of `p`         |
| `@Dbg(V)`         | Prints program state to stderr                        | Value `V`             |
| `@dbg_break(p)`   | Parses `p`, pauses execution and prints program state to stderr | Result of `p` |
| `@DbgBreak(V)`    | Pauses execution and prints program state to stderr   | Value `V`             |
| `@input.offset`   | Succeeds with no match                                | Parsing position as a character offset |
| `@input.line`     | Succeeds with no match                                | Parsing line position |
| `@input.line_offset` | Succeeds with no match                             | Parsing col position  |
