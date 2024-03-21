# Standard Library

The Possum standard library defines an extensive collection of parsers and
(eventually) value functions.

The entirety of the standard library is implemented using core Possum language
features, leaving users free to override certain functions, copy a subset of
needed parsers, or even create a whole new alternative standard library.

### Parsers

| Parser | Match Behavior | Returns |
| ------ | -------------- | ------- |
| `char` | One character  | Matched string |
| `alpha` | One character in `"a".."z"` or `"A".."Z"` | Matched string |
| `alphas` | One or more `alpha`s | Matched string |
| `lower` | One character in `"a".."z"` | Matched string |
| `lowers` | One or more `lower`s | Matched string |
| `upper` | One character in `"A".."Z"` | Matched string |
| `uppers` | One or more `upper`s | Matched string |
| `numeral` | One character in `"0".."9"` | Matched string |
| `numerals` | One or more `numeral`s | Matched string |
| `space` | One space or tab character | Matched string |
| `spaces` | One or more `space`s | Matched string |
| `newline` | Either `\n` or `\r\n` | Matched string |
| `newlines` | One or more `newline`s | Matched string |
| `nl`   | Alias for `newline` | As above |
| `end_of_input` | End of string or file input | Empty string |
| `end`  | Alias for `end_of_input` | As above |
| `whitespace` | One or more space, tab, or newline characters | Matched string |
| `ws`   | Alias for `whitespace` | As above |
| `word` | One or more non-whitespace characters | Matched string |
| `line` | Match all characters until a newline or end of input, which is not consumed | Matched string |
| `digit` | One character in `"0".."9"` | Number between `0` and `9` |
| `integer` | Any valid JSON integer | Number |
| `int`  | Alias for `integer` | As above |
| `scientific_integer` | Number in the format `123e10` | Number |
| `float` | Any valid JSON number with a fractional part | Number |
| `scientific_float` | Number in the format `1.23e10` | Number |
| `number` | Any valid JSON number, including optional fraction and exponent parts | Number |
| `num`  | Alias for `number` | As above |
| `true(t)` | Matches `t` | `true` |
| `false(f)` | Matches `f` | `false` |
| `boolean(t, f)` | Matches `t` or `f` | `true` or `false` |
| `bool(t, f)` | Alias for `boolean` | As above |
| `null(n)` | Matches `n` | `null` |
| `peek(p)` | Parses `p`, consumes no input on success | Result of `p` |
| `maybe(p)` | Parses `p`, or succeeds with no match | Result of `p`, or `""` if `p` fails |
| `skip(p)` | Parses `p`  | `""` |
| `nullable(p)` | Parses `p`, or succeeds with no match | Result of `p`, or `null` if `p` fails |
| `default(p, D)` | Parses `p` or succeeds with no match | Result of `p`, or `D` if `p` fails |
| `const(C)` | Succeeds with no match | Value `C` |
| `number_of(p)` | Parses `p`, succeeds if the value is a valid JSON number or string encoding of a number | Number |
| `surround(p, fill)` | Parses `fill`, then `p`, then `fill` again | Result of `p` |
| `input(p)` | Strips leading and trailing whitespace, succeeds if `p` parses to end of input | Result of `p` |
| `many(p)` | One or more `p` | Merged values parsed by `p` |
| `until(p, stop)` | One or more `p`, must be followed by `stop` which is not consumed | Merged values parsed by `p` |
| `unless(p, excluded)` | Fails if `excluded` succeeds, otherwise parses `p` | Matched string |
| `scan(p)` | Skip characters until `p` matches | Result of `p` |
| `array(elem)` | One or more `elem` | Array of values parsed by `elem` |
| `array_sep(elem, sep)` | One or more `elem`, interspersed with `sep` | Array of values parsed by `elem` |
| `array_until(elem, stop)` | One or more `elem`, must be followed by `stop` which is not consumed | Array of values parsed by `elem` |
| `maybe_array(elem)` | Zero or more `elem` | Array of values parsed by `elem`, maybe empty |
| `maybe_array_sep(elem, sep)` | Zero or more `elem`, interspersed with `sep` | Array of values parsed by `elem`, maybe empty |
| `table_sep(elem, sep, row_sep)` | One or more `elem`, interspersed with `sep` or `row_sep` | Array of array of values parsed by `elem` |
| `maybe_table_sep(elem, sep, row_sep)` | Zero or more `elem`, interspersed with `sep` or `row_sep` | Array of array of values parsed by `elem`, maybe empty |
| `single(elem)` | Parses `elem` once | Result of `elem` wrapped in an array |
| `pair(elem)` | Parses `elem` twice | Array of values returned by `elem` |
| `pair_sep(elem, sep)` | Parses `elem` twice, interspersed with `sep` | Array of values returned by `elem` |
| `triple(elem)` | Parses `elem` three times | Array of values returned by `elem` |
| `triple_sep(elem, sep)` | Parses `elem` three times, interspersed with `sep` | Array of values returned by `elem` |
| `object(key, value)` | Both `key` and `value` together one or more times | Object of key/value pairs |
| `object_sep(key, pair_sep, value, sep)` | Parses `key`, `pair_sep`, and `value` together one or more times, interspersed with `sep` | Object of key/value pairs |
| `object_until(key, value, stop)` | One or more `key`/`value` pairs, must be followed by `stop` which is not consumed | Object of key/value pairs |
| `maybe_object(key, value)` | Both `key` and `value` together zero or more times | Object of key/value pairs, maybe empty |
| `maybe_object_sep(key, pair_sep, value, sep)` | Parses `key`, `pair_sep`, and `value` together zero or more times, interspersed with `sep` | Object of key/value pairs, maybe empty|
| `label(Key, value)` | Parses `value` | Parsed `Value` wrapped in a `{Key: Value}` object |

### Values

TODO
