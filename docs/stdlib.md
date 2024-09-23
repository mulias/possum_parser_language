# Standard Library

These parsers and value functions are always available in Possum programs, unless Possum is ran with the `--no-stdlib` flag.

## String Parsers

| Parser             | Match Behavior             | Returns                    |
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
| `alnum`            | One `alpha` or `numeral`   | Matched string             |
| `alnums`           | One or more `alnum`s       | Matched string             |
| `token`            | One or more non-whitespace characters | Matched string  |
| `word`             | One or more alphanumeric characters, "_", or "-" | Matched string |
| `line`             | Match all characters until a newline or end of input, which is not consumed | Matched string |
| `space`            | One non-line-breaking blank character | Matched string  |
| `spaces`           | One or more `space`s       | Matched string             |
| `newline`          | One line-breaking blank character, or the two character line break code `"\r\n"` | Matched string |
| `nl`               | Alias for `newline`        | As above                   |
| `newlines`         | One or more `newline`s     | Matched string             |
| `nls`              | Alias for `newlines`       | As above                   |
| `whitespace`       | One or more space, tab, or newline characters | Matched string |
| `ws`               | Alias for `whitespace`     | As above                   |
| `json_string`      | Valid JSON string          | Matched string contents, not including quotes |

## Number Parsers

| Parser             | Match Behavior             | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `digit`            | One Arabic numeral, "0" to "9" | Integer number between 0 and 9 |
| `integer`          | Valid JSON integer         | Integer number             |
| `int`              | Alias for `integer`        | As above                   |
| `non_negative_integer` | Valid JSON integer without a leading minus sign | Integer number greater than or equal to zero |
| `negative_integer` | Valid JSON integer with a leading minus sign | Integer number less than or equal to `-0` |
| `float`            | Valid JSON number with an integer and fractional part | Number |
| `scientific_integer` | Valid JSON number with an integer and exponent part | Number |
| `scientific_float` | Valid JSON number with an integer, fractional, and exponent part | Number |
| `number`           | Valid JSON number with integer part and optional fraction and exponent part | Number |
| `num`              | Alias for `number`         | As above |

## Constant Parsers

| Parser             | Match Behavior             | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `true(t)`          | Parses `t`                 | `true`                     |
| `false(f)`         | Parses `f`                 | `false`                    |
| `boolean(t, f)`    | Parses `t` or `f`          | `true` or `false`          |
| `bool(t, f)`       | Alias for `boolean`        | As above                   |
| `null(n)`          | Parses `n`                 | `null`                     |

## Repeated Value Parsers

| Parser             | Match Behavior             | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `many(p)`          | One or more `p`            | Merged values parsed by `p` |
| `many_sep(p, sep)` | One or more `p`, interspersed with `sep` | Marged values parsed by `p` |
| `many_until(p, stop)` | One or more `p`, must be followed by `stop` which is not consumed | Merged values parsed by `p` |
| `maybe_many(p)`    | Zero or more `p`           | Merged values parsed by `p`, or `null` if `p` fails |
| `maybe_many_sep(p)` | Zero or more `p`, interspersed with `sep` | Merged values parsed by `p`, or `null` if `p` fails |
| `repeat(p, N)`     | Parses `p` exactly `N` times, where `N` is a non-negative integer | Merged values parsed by `p`, or `null` if `N` is 0 |
| `repeat_between(p, N, M)` | Parses `p` at least `N` times and up to `M` times, where `N` and `M` are non-negative integers | Merged values parsed by `p`, or `null` if `N` is 0 and no matches found |

## Array Parsers

| Parser             | Match Behavior             | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `array(elem)`      | One or more `elem`         | Array of values parsed by `elem` |
| `array_sep(elem, sep)` | One or more `elem`, interspersed with `sep` | Array of values parsed by `elem` |
| `array_until(elem, stop)` | One or more `elem`, must be followed by `stop` which is not consumed | Array of values parsed by `elem` |
| `maybe_array(elem)` | Zero or more `elem`       | Array of values parsed by `elem`, maybe empty |
| `maybe_array_sep(elem, sep)` | Zero or more `elem`, interspersed with `sep` | Array of values parsed by `elem`, maybe empty |
| `tuple1(elem)`     | Parses `elem`              | Array of length 1 continuing result of `elem` |
| `tuple2(elem1, elem2)` | Parses `elem1` and then `elem2` | Array of length 2 containing parsed elements |
| `tuple2_sep(elem1, sep, elem2)` | Parses `elem1`, `sep`, and then `elem2` | Array of length 2 containing parsed elements |
| `tuple3(elem1, elem2, elem3)` | Runs three element parsers in order | Array of length 3 containing parsed elements |
| `tuple3_sep(elem1, sep1, elem2, sep2, elem3)` | Runs three element parsers, interspersed with `sep` | Array of length 3 containing parsed elements |
| `tuple(elem, N)`   | Parses `elem` exactly `N` times, where `N` is a non-negative integer | Array of values parsed by `elem` |
| `tuple_sep(elem, sep, N)` | Parses `elem` exactly `N` times, interspersed with `sep`, where `N` is a non-negative integer | Array of values parsed by `elem` |
| `table_sep(elem, sep, row_sep)` | One or more `elem`, interspersed with `sep` or `row_sep` | Array of array of values parsed by `elem` |
| `maybe_table_sep(elem, sep, row_sep)` | Zero or more `elem`, interspersed with `sep` or `row_sep` | Array of array of values parsed by `elem`, maybe empty |
| `json_array(elem)` | JSON formatted array with square brackets and comma separators, containing zero or more `elem`s | Array of values parsed by `elem` |

## Object Parsers

| Parser             | Match Behavior             | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `object(key, value)` | Both `key` and `value` together one or more times | Object of key/value pairs |
| `object_sep(key, pair_sep, value, sep)` | Parses `key`, `pair_sep`, and `value` together one or more times, interspersed with `sep` | Object of key/value pairs |
| `object_until(key, value, stop)` | One or more `key`/`value` pairs, must be followed by `stop` which is not consumed | Object of key/value pairs |
| `maybe_object(key, value)` | Both `key` and `value` together zero or more times | Object of key/value pairs, maybe empty |
| `maybe_object_sep(key, pair_sep, value, sep)` | Parses `key`, `pair_sep`, and `value` together zero or more times, interspersed with `sep` | Object of key/value pairs, maybe empty|
| `record1(Key, value)` | Parses `value` | Object with `Key` associated to the parsed `value` |
| `record2(Key1, value1, Key2, value2)` | Parses `value1` and then `value2` | Object with `Key1` associated to the parsed `value1`, etc |
| `record2_sep(Key1, value1, sep, Key2, value2)` | Parses `value1`, `sep`, and then `value2` | Object with `Key1` associated to the parsed `value1`, etc |
| `record3(Key1, value1, Key2, value2, Key3, value3)` | Runs three value parsers in order | Object with `Key1` associated to the parsed `value1`, etc |
| `record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3)` | Runs three value parsers, interspersed with `sep` | Object with `Key1` associated to the parsed `value1`, etc |
| `json_object(value)` | JSON formatted object with braces, string keys, colon and comma separators, containing zero or more `value`s | Object with string keys and values parsed by `value` |

## Utility Parsers

| Parser             | Match Behavior             | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `peek(p)`          | Parses `p`, consumes no input on success | Result of `p` |
| `maybe(p)`         | Parses `p`, or succeeds with no match | Result of `p`, or `null` if `p` fails |
| `unless(p, excluded)` | Fails if `excluded` would succeed, otherwise parses `p` | Result of `p` |
| `skip(p)`          | Parses `p`                 | `null` |
| `scan(p)`          | Skip input until `p` succeeds | Result of `p` |
| `succeed`          | Succeeds, consumes no input | `null` |
| `default(p, D)`    | Parses `p` or succeeds with no match | Result of `p`, or `D` if `p` fails |
| `const(C)`         | Succeeds with no match     | Value `C` |
| `number_of(p)`     | Parses `p`, succeeds if the value is a valid JSON number or string encoding of a number | Number |
| `string_of(p)`     | Parses `p`                 | Compact encoding of the parsed value as a JSON string |
| `surround(p, fill)` | Parses `fill`, then `p`, then `fill` again | Result of `p` |
| `end_of_input`     | End of string or file input | `null` |
| `end`              | Alias for `end_of_input`   | As above |
| `input(p)`         | Strips leading and trailing whitespace, succeeds if `p` parses to end of input | Result of `p` |
| `json`             | Any valid JSON             | Matched JSON               |

## Value Functions

| Value Function     | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `ArrayFirst(A)`    | Return the first element in `A`, fail if `A` is not an array with at least one element |
| `ArrayRest(A)`     | Return the remaining array without the first element, fails if `A` is not an array with at least one element |
| `Map(A, Fn)`       | Apply the function `Fn` to each element in the array `A` |
| `Reverse(A)`       | Reverse elements of the array `A` so that the first element becomes the last, etc |
| `ZipIntoObject(Ks, Vs)` | Pair together keys from `Ks` and values from `Vs` into an object |
| `TransposeTable(T)` | Swap an array of arrays over the diagonal so that rows become columns |
| `RotateTableClockwise(T)` | Rotate an array of arrays 90 degrees clockwise |
| `Reject(A, Pred)`  | Apply the function `Pred` to each element in the array `A`, return an array excluding elements where `Pred` succeeds |
| `IsNull(V)`        | Succeeds and returns `V` if the value is `null`, otherwise fails |
| `Tabular(Headers, Rows)` | Transform an array of `Rows` into an array of objects where each column is paired with its header from `Headers` |
