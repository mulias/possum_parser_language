# Possum Language Documentation

## Program Structure

A program consists of one main parser and zero, one, or many named parsers.
Named parsers may optionally specify parameters. Parsers are separated by
semicolons. The main parser can show up before, after, or in-between named
parsers. Named parsers can reference each other and themselves recursively, and
can be defined in any order.

```
<parser_name_1>(<param1>, <param2>, <param3>) = <parser> ;
<parser_name_2> = <parser> ;
<main_parser>
```

## Language Core

Possum provides a small set of basic parsers, infix combinators to chain parsers
together, and a way to construct and pattern match on values.

### Basic Parsers

These low-level parsers are necessary for building more complex parsers. In
practice the string literal, number literal, and `char` parsers have broad
utility in parser programs, while regex, `peek`, `string_of`, and `number_of`
can usually be ignored in favor of higher level parsers from the standard
library.

| Parser | Match Behavior | Returns |
| ------ | -------------- | ------- |
| `"string lit"` | Exact characters of string | Matched string |
| `'string lit'` | Exact characters of string | Matched string |
| `/[a-z]/` | String matching regex pattern, without skipping any input | Matched string, or array with capture groups |
| `123`  | Exact characters of number | Matched number |
| `-1.334e23` | Exact characters of number | Matched number |
| `char` | Any single character | Matched string |
| `peek(p)` | Parses `p`, consumes no input on success | Result of `p` |
| `string_of(p)` | Parses `p` | Result of `p` as a JSON encoded string |
| `number_of(p)` | parses `p`, given `p` returns a number or string encoding of a number | Result of `p` as a number |

### Infix Combinators

Infix operations make it easy to compose parsers without excessive nesting and
parentheses.

| Combinator | Name | Description |
| ---------- | ---- | ----------- |
| `p1 \| p2` | Or   | Try `p1`, if no match is found try `p2` instead |
| `p1 > p2`  | Take Right | Match `p1` and then `p2`, return the result of `p2` |
| `p1 < p2`  | Take Left | Match `p1` and then `p2`, return the result of `p1` |
| `p1 + p2`  | Concat | Match `p1` and then `p2`, if both return strings then succeed with the concatenated string value |
| `p $ Value` | Return | Match `p` and then return `Value` |
| `p1 & ... & pN $ Value` | Sequence | Match `p1`, then `p2`, up through `pN`, return `Value` |
| `Patter <- p` | Destructure | Match `p`, compare the result of `p` to `Pattern` as described below |

### Values

Values can only be used in a few places:

- A returned value, which appears on the right side of a `$`
```
my_parser $ [1,2,3]
```

- Parser arguments
```
bar(B) = "bar" $ B ;
bar({"bar": true})
```

- A pattern to destructure on, which appears on the left side of a `<-`
```
[1, 2, ...C] <- array(int) $ C
```

In the first two cases we construct a value which is then returned by a parser.
In the third case we pattern match the result of the right-side parser against
the left-side value. In this example `array(int)` must return an array of length
at least two, where the first two elements are `1` and `2`. The rest of the
array is assigned to variable `C`. This variable can be referenced later in the
parser. If the parser result does not match the pattern then the parser fails.

| Value | Description |
| ----- | ----------- |
| `"string"` | String literal |
| `123` | Number literal |
| `-1.334e23` | Number literal |
| `true` | Constant value `true` |
| `false` | Constant value `false` |
| `null` | Constant value `null` |
| `Var` | Variable for a value |
| `[ "a", 0, true, Var ]` | Array of values |
| `[ "a", ...Var ]` | Array, including all of the elements of the array `Var` |
| `{ "foo": 0, "bar": Var }` | Object of name/value pairs |
| `{ "foo": 0, Var: null }` | Object with the string `Var` as a pair name |
| `{ "foo": 0, ...Var }` | Object, containing all of the members of the object `Var` |

## Standard Library

These parsers could all be defined using the core language features, but are
provided for convenience.

| Parser | Match Behavior | Returns |
| ------ | -------------- | ------- |
| `alpha` | One character in `a-z` or `A-Z` | Matched string |
| `lower` | One character in `a-z` | Matched string |
| `upper` | One character in `A-Z` | Matched string |
| `numeral` | One character in `0-9` | Matched string |
| `space` | One whitespace character in ` \t\r\n` | Matched string |
| `symbol` | One character in `!"#$%&'()*+,-.\/:;<=>?@[]^_{}~\|` | Matched string |
| `newline` | Either `\n` or `\r\n` | Matched string |
| `nl`   | Alias for `newline` | Matched string |
| `end_of_input` | End of string or file input | `null` |
| `end`  | Alias for `end_of_input` | As above |
| `whitespace` | One or more `space` | Matched string |
| `ws`   | Alias for `whitespace` | As above |
| `word` | One or more non-whitespace character | Matched string |
| `digit` | One character in `0-9` | Number between `0` and `9` |
| `integer` | Any valid JSON integer | Number |
| `int`  | Alias for `integer` | As above |
| `number` | Any valid JSON number, including fraction and exponent parts | Number |
| `num`  | Alias for `number` | As above |
| `true(t)` | Parses `t` | `true` |
| `false(f)` | Parses `f` | `false` |
| `boolean(t, f)` | Parses `t` or `f` | `true` or `false` |
| `bool(t, f)` | Alias for `boolean` | As above |
| `null(n)` | Parses `n` | `null` |
| `many(s)` | One or more `s` | Concatenated string values returned by `s` |
| `until(s, stop)` | One or more `s`, must be followed by `stop` which is not consumed | Concatenated string values returned by `s` |
| `scan(p)` | Skip characters until `p` matches | Value of `p` |
| `array(element)` | One or more `element` | Array of values returned by `element` |
| `array_sep(element, sep)` | One or more `element`, interspersed with `sep` | Array of values returned by `element` |
| `table_sep(element, sep, row_sep)` | One or more `element`, interspersed with `sep` or `row_sep` | Array of array of values |
| `object(name, value)` | Both `name` and `value` together one or more times | Object of name/value pairs |
| `object_sep(name, pair_sep, value, sep)` | Parses `name`, `pair_sep`, and `value` together one or more times, interspersed with `sep` | Object of name/value pairs |
| `input(p)` | `maybe(ws) > p < maybe(ws) < eof` | Value of `p` |
| `fail` | Fails with no match | N/A |
| `succeed` | Succeeds with no match | `null` |
| `maybe(p)` | Parses `p`, or succeeds with no match | Value of `p`, or `null` if `p` fails |
| `default(p, D)` | Parses `p` or succeeds with no match | Value of `p`, or `D` if `p` fails |
| `const(C)` | Succeeds with no match | Value `C` |

## Todo

These are tentative core/library parsers which may or may not get implemented.

| Parser | Match Behavior | Returns |
| ------ | -------------- | ------- |
| `pos` | Succeed with no match | Current input parsing position as `[CharOffsetNumber, LineNumber, ColNumber]` |
| `match(p, V)` | Parser `p`, only if the result exactly matches `V` | Result of `p` |
| `repeat(s, N)` | Parser `s` exactly `N` times | Concatenated string values returned by `s` |
| `repeat_between(s, L, H)` | Parser `s` at least `L` and at most `H` times | Concatenated string values returned by `s` |
| `tuple(element, N)` | Parser `element` exactly `N` times | Array of with values returned by `element` |
| `tuple_sep(element, sep, N)` | Parser `element` exactly `N` times, interspersed with `sep` | Array of with values returned by `element` |
| `not(p, V)` | Parser `p`, fails if `p` returns the value `V` | Matched string |
| `unless(p, V)` | Fails if `p` matches, otherwise succeed with no match | Value `V` |
| `if(test, Then)` | Parser `test` | Value `Then` |
| `if_else(test, Then, Else)` | Parser `test` or succeeds with no match | Value `Then` if `p` succeeds, otherwise `Else` |
| `map(p, A)` | Parser `p(Val)` for each `Val` in array `A` | Array of parsed values |
| `fold(p, InitAcc, A)` | Parser `p(Acc, Val)` for each `Val` in array `A` and the accumulated value `Acc` | Final `Acc` |
| `tabular(Header, Rows)` | Succeed with no match, given `Header` is an array of strings and `Rows` is an array of arrays of values | Array of objects with header col/row col pairs |
| `array_flatten(A)` | Succeed with no match, given `A` is an array of arrays | Array with all elements of sub-arrays |
| `array_concat(A)` | Succeed with no match, given `A` is an array of strings | Concatenated string elements |
| `zip_array(A, B)` | Succeed with no match, given `A` and `B` are both arrays | Array of `[ ValueA, ValueB ]` tuples |
| `zip_object(A, B)` | Succeed with no match, given `A` and `B` are both arrays | Array of `[ ValueA, ValueB ]` tuples |
| `rotate_table_clockwise(T)` | Succeed with no match, given `T` is an array of arrays | Shift table elements so rows become columns, bottom left element becomes the first element |
| `rotate_table_counter_clockwise(T)` | Succeed with no match, given `T` is an array of arrays | Shift table elements so rows become columns, top right element becomes the first element |
