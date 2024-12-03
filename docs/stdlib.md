# Standard Library

These parsers and value functions are always available in Possum programs, unless Possum is ran with the `--no-stdlib` flag.

## Strings

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `char`             | One [code point](https://en.wikipedia.org/wiki/Code_point), informally called a "character" | Matched string |
| `ascii`            | One [ASCII](https://en.wikipedia.org/wiki/ASCII) code point | Matched string |
| `alpha`            | One lower- or upper-case letter from the English alphabet, "a" to "z" or "A" to "Z" | Matched string |
| `alphas`           | One or more `alpha`s       | Matched string             |
| `lower`            | One lower-case letter from the English alphabet, "a" to "Z" | Matched string |
| `lowers`           | One or more `lower`s       | Matched string             |
| `upper`            | One upper-case letter from the English alphabet, "A" to "Z" | Matched string |
| `uppers`           | One or more `upper`s       | Matched string             |
| `numeral`          | One Arabic numeral, "0" to "9" | Matched string         |
| `numerals`         | One or more `numeral`s     | Matched string             |
| `hex_numeral`      | One hexadecimal numeral, "0" to "9", "a" to "f", or "A" to "F" | Matched string |
| `alnum`            | One `alpha` or `numeral`   | Matched string             |
| `alnums`           | One or more `alnum`s       | Matched string             |
| `token`            | One or more non-whitespace characters | Matched string  |
| `word`             | One or more alphanumeric characters, "_", or "-" | Matched string |
| `line`             | All characters until a newline or end of input, which is not consumed | Matched string |
| `space`            | One non-line-breaking blank character | Matched string  |
| `spaces`           | One or more `space`s       | Matched string             |
| `newline`          | One line-breaking blank character, or the two character line break code `"\r\n"` | Matched string |
| `nl`               | Alias for `newline`        | As above                   |
| `newlines`         | One or more `newline`s     | Matched string             |
| `nls`              | Alias for `newlines`       | As above                   |
| `whitespace`       | One or more space, tab, or newline characters | Matched string |
| `ws`               | Alias for `whitespace`     | As above                   |

## Numbers

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `digit`            | One Arabic numeral, "0" to "9" | Integer number between 0 and 9 |
| `hex_digit`        | One hexadecimal numeral, "0" to "9", "a" to "f", or "A" to "F" | Integer number between 0 and 15 |
| `integer`          | Valid JSON integer         | Integer number             |
| `int`              | Alias for `integer`        | As above                   |
| `non_negative_integer` | Valid JSON integer without a leading minus sign | Integer number greater than or equal to zero |
| `negative_integer` | Valid JSON integer with a leading minus sign | Integer number less than or equal to `-0` |
| `float`            | Valid JSON number with an integer and fractional part | Number |
| `scientific_integer` | Valid JSON number with an integer and exponent part | Number |
| `scientific_float` | Valid JSON number with an integer, fractional, and exponent part | Number |
| `number`           | Valid JSON number with integer part and optional fraction and exponent part | Number |
| `num`              | Alias for `number`         | As above |
| `non_negative_number` | Valid JSON number without a leading minus sign | Integer number greater than or equal to zero |
| `negative_number`  | Valid JSON number with a leading minus sign | Integer number less than or equal to `-0` |

## Constants

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `true(t)`          | `t`                        | `true`                     |
| `false(f)`         | `f`                        | `false`                    |
| `boolean(t, f)`    | `t` or `f`                 | `true` or `false`          |
| `bool(t, f)`       | Alias for `boolean`        | As above                   |
| `null(n)`          | `n`                        | `null`                     |

## Repeated Values

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `many(p)`          | One or more `p`            | Merged values parsed by `p` |
| `many_sep(p, sep)` | One or more `p`, interspersed with `sep` | Marged values parsed by `p` |
| `many_until(p, stop)` | One or more `p`, must be followed by `stop` which is not consumed | Merged values parsed by `p` |
| `chars_until(stop)` | One or more codepoints, must be followed by `stop` which is not consumed | Merged string of all matched codepoints |
| `maybe_many(p)`    | Zero or more `p`           | Merged values parsed by `p`, or `null` if `p` fails |
| `maybe_many_sep(p, sep)` | Zero or more `p`, interspersed with `sep` | Merged values parsed by `p`, or `null` if `p` fails |
| `repeat2(p)`       | `p` two times              | Merged values parsed by `p` |
| `repeat3(p)`       | `p` three times            | Merged values parsed by `p` |
| `repeat4(p)`       | `p` four times             | Merged values parsed by `p` |
| `repeat5(p)`       | `p` five times             | Merged values parsed by `p` |
| `repeat6(p)`       | `p` six times              | Merged values parsed by `p` |
| `repeat7(p)`       | `p` seven times            | Merged values parsed by `p` |
| `repeat8(p)`       | `p` eight times            | Merged values parsed by `p` |
| `repeat9(p)`       | `p` nine times             | Merged values parsed by `p` |
| `repeat(p, N)`     | `p` exactly `N` times, where `N` is a non-negative integer | Merged values parsed by `p`, or `null` if `N` is 0 |
| `repeat_between(p, N, M)` | `p` at least `N` times and up to `M` times, where `N` and `M` are non-negative integers | Merged values parsed by `p`, or `null` if `N` is 0 and no matches found |

## Arrays

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `array(elem)`      | One or more `elem`         | Array of values parsed by `elem` |
| `array_sep(elem, sep)` | One or more `elem`, interspersed with `sep` | Array of values parsed by `elem` |
| `array_until(elem, stop)` | One or more `elem`, must be followed by `stop` which is not consumed | Array of values parsed by `elem` |
| `maybe_array(elem)` | Zero or more `elem`       | Array of values parsed by `elem`, maybe empty |
| `maybe_array_sep(elem, sep)` | Zero or more `elem`, interspersed with `sep` | Array of values parsed by `elem`, maybe empty |
| `tuple1(elem)`     | `elem`                     | Array of length 1 continuing result of `elem` |
| `tuple2(elem1, elem2)` | `elem1` and then `elem2` | Array of length 2 containing parsed elements |
| `tuple2_sep(elem1, sep, elem2)` | `elem1`, `sep`, and then `elem2` | Array of length 2 containing parsed elements |
| `tuple3(elem1, elem2, elem3)` | three element parsers in order | Array of length 3 containing parsed elements |
| `tuple3_sep(elem1, sep1, elem2, sep2, elem3)` | three element parsers, interspersed with separators | Array of length 3 containing parsed elements |
| `tuple(elem, N)`   | `elem` exactly `N` times, where `N` is a non-negative integer | Array of values parsed by `elem` |
| `tuple_sep(elem, sep, N)` | `elem` exactly `N` times, interspersed with `sep`, where `N` is a non-negative integer | Array of values parsed by `elem` |
| `table_sep(elem, sep, row_sep)` | One or more `elem`, interspersed with `sep` or `row_sep` | Array of array of values parsed by `elem` |
| `maybe_table_sep(elem, sep, row_sep)` | Zero or more `elem`, interspersed with `sep` or `row_sep` | Array of array of values parsed by `elem`, maybe empty |

## Objects

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `object(key, value)` | Both `key` and `value` together one or more times | Object of key/value pairs |
| `object_sep(key, pair_sep, value, sep)` | `key`, `pair_sep`, and `value` together one or more times, interspersed with `sep` | Object of key/value pairs |
| `object_until(key, value, stop)` | One or more `key`/`value` pairs, must be followed by `stop` which is not consumed | Object of key/value pairs |
| `maybe_object(key, value)` | Both `key` and `value` together zero or more times | Object of key/value pairs, maybe empty |
| `maybe_object_sep(key, pair_sep, value, sep)` | `key`, `pair_sep`, and `value` together zero or more times, interspersed with `sep` | Object of key/value pairs, maybe empty|
| `pair(key, value)` | `key` and then `value` once each | Object with a single key/value pair |
| `pair_sep(key, sep, value)` | `key`, `sep`, and `value` once each | Object with a single key/value pair |
| `record1(Key, value)` | Parses `value` | Object with `Key` associated to the parsed `value` |
| `record2(Key1, value1, Key2, value2)` | `value1` and then `value2` | Object with `Key1` associated to the parsed `value1`, etc |
| `record2_sep(Key1, value1, sep, Key2, value2)` | `value1`, `sep`, and then `value2` | Object with `Key1` associated to the parsed `value1`, etc |
| `record3(Key1, value1, Key2, value2, Key3, value3)` | three value parsers in order | Object with `Key1` associated to the parsed `value1`, etc |
| `record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3)` | three value parsers, interspersed with separators | Object with `Key1` associated to the parsed `value1`, etc |

## Utility Parsers

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `peek(p)`          | `p`, consumes no input on success | Result of `p`       |
| `maybe(p)`         | `p` or succeeds with no match | Result of `p`, or `null` if `p` fails |
| `unless(p, excluded)` | `p` unless parsing `excluded` instead would succeed | Result of `p` |
| `skip(p)`          | `p`                        | `null`                     |
| `find(p)`          | Skip input until `p` succeeds | Result of `p`           |
| `find_all(p)`      | Entire input, succeeds if `p` matches at least once | Array of one or more results of `p` |
| `find_before(p, stop)` | Skip input until `p` succeeds, or fail if `stop` is found first | Result of `p` |
| `find_all_before(p, stop)` | Entire input until `stop`, succeeds if `p` matches at least once | Array of one or more results of `p` |
| `succeed`          | Succeeds, consumes no input | `null` |
| `default(p, D)`    | `p` or succeeds with no match | Result of `p`, or `D` if `p` fails |
| `const(C)`         | Succeeds with no match     | Value `C` |
| `number_of(p)`     | `p`, succeeds if the value is a valid JSON number or string encoding of a number | Number |
| `string_of(p)`     | `p`                        | Compact encoding of the parsed value as a JSON string |
| `surround(p, fill)` | `fill`, then `p`, then `fill` again | Result of `p` |
| `end_of_input`     | End of string or file input | `null` |
| `end`              | Alias for `end_of_input`   | As above |
| `input(p)`         | Strips leading and trailing whitespace, succeeds if `p` parses to end of input | Result of `p` |

## JSON

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `json`             | Any valid JSON             | Matched JSON               |
| `json_string`      | Valid JSON string          | Matched string contents, not including quotes |
| `json_number`      | Alias for `number`         | Number |
| `json_boolean`     | JSON "true" or "false" keyword | `true` or `false`      |
| `json_null`        | JSON "null" keyword        | `null`                     |
| `json_array(elem)` | JSON formatted array with square brackets and comma separators, containing zero or more `elem`s | Array of values parsed by `elem` |
| `json_object(value)` | JSON formatted object with braces, string keys, colon and comma separators, containing zero or more `value`s | Object with string keys and values parsed by `value` |

## Abstract Syntax Trees

See the `stdlib-ast` docs for more detailed documentation.

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `ast_with_operator_precedence(operand, prefix, infix, postfix)` | `operands`s with prefix and postfix operators, composed with infix operators | Abstract syntax tree |
| `ast_node(Type, value)` | `value`               | Object with a `"type"` and `"value"` field |

| Value Function     | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `AstOpPrecedence(OpNode, BindingPower)` | Returns array with two elements, `OpNode` and `BindingPower` |
| `AstInfixOpPrecedence(OpNode, LeftBindingPower, RightBindingPower)` | Returns array with three elements, `OpNode`, `LeftBindingPower`, and `RightBindingPower` |

## Value Functions

| Value Function     | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `True`             | Alias for the `true` constant                           |
| `False`            | Alias for the `false` constant                          |
| `Null`             | Alias for the `null` constant                           |
| `Inc(N)`           | Increment, return `N + 1`                               |
| `Dec(N)`           | Decrement, return `N - 1`                               |
| `ArrayFirst(A)`    | Return the first element in `A`, fail if `A` is not an array with at least one element |
| `ArrayRest(A)`     | Return the remaining array without the first element, fails if `A` is not an array with at least one element |
| `Map(A, Fn)`       | Apply the function `Fn` to each element in the array `A` |
| `Reverse(A)`       | Reverse elements of the array `A` so that the first element becomes the last, etc |
| `ZipIntoObject(Ks, Vs)` | Pair together keys from `Ks` and values from `Vs` into an object |
| `TransposeTable(T)` | Swap an array of arrays over the diagonal so that rows become columns |
| `RotateTableClockwise(T)` | Rotate an array of arrays 90 degrees clockwise |
| `Filter(A, Pred)`  | Apply the function `Pred` to each element in the array `A`, return an array excluding elements where `Pred` fails |
| `Reject(A, Pred)`  | Apply the function `Pred` to each element in the array `A`, return an array excluding elements where `Pred` succeeds |
| `IsNull(V)`        | Succeeds and returns `V` if the value is `null`, otherwise fails |
| `Tabular(Headers, Rows)` | Transform an array of `Rows` into an array of objects where each column is paired with its header from `Headers` |
| `LessThan(A, B)` | Succeeds and returns `A` if `A` is strictly less than `B` |
| `GreaterThan(A, B)` | Succeeds and returns `A` if `A` is strictly greater than `B` |
