# Standard Library

The Possum standard library defines an extensive collection of parsers and
value functions. The standard library is imported by default, but can be omitted
with the `--no-stdlib` command line flag.

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
| `fail` | Fails with no match | N/A |
| `succeed` | Succeeds with no match | Empty string |
| `peek(p)` | Parses `p`, consumes no input on success | Result of `p` |
| `maybe(p)` | Parses `p`, or succeeds with no match | Result of `p`, or `""` if `p` fails |
| `skip(p)` | Parses `p`  | `""` |
| `nullable(p)` | Parses `p`, or succeeds with no match | Result of `p`, or `null` if `p` fails |
| `default(p, D)` | Parses `p` or succeeds with no match | Result of `p`, or `D` if `p` fails |
| `const(C)` | Succeeds with no match | Value `C` |
| `string_of(p)` | Parses `p` | Result of `p` as a dense single-line JSON encoded string |
| `number_of(p)` | Parses `p`, succeeds if the value is a valid JSON number or string encoding of a number | Number |
| `surround(p, fill)` | Parses `fill`, then `p`, then `fill` again | Result of `p` |
| `balanced_pairs(open, p, close)` | Parses `open`, matches `p` zero or more times, and then matches `close`. If another `open` is found before `close` then recursively matches the inner pair and includes it in the result. | Value with a balanced number of `open` and `close` sub-values |
| `input(p)` | Strips leading and trailing whitespace, succeeds if `p` parses to end of input | Result of `p` |
| `many(p)` | One or more `p` | Merged values parsed by `p` |
| `until(p, stop)` | One or more `p`, must be followed by `stop` which is not consumed | Merged values parsed by `p` |
| `unless(p, excluded)` | Fails if `excluded` succeeds, otherwise parses `p` | Matched string |
| `repeat(p, N)` | Parses `p` exactly `N` times | Merged values parsed by `p` |
| `repeat_between(p, L, H)` | Parses `p` at least `L` and at most `H` times | Merged values parsed by `p` |
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
| `tuple(elem, N)` | Parser `elem` exactly `N` times | Array of values returned by `elem` |
| `tuple_sep(elem, sep, N)` | Parser `elem` exactly `N` times, interspersed with `sep` | Array of values returned by `elem` |
| `object(key, value)` | Both `key` and `value` together one or more times | Object of key/value pairs |
| `object_sep(key, pair_sep, value, sep)` | Parses `key`, `pair_sep`, and `value` together one or more times, interspersed with `sep` | Object of key/value pairs |
| `object_until(key, value, stop)` | One or more `key`/`value` pairs, must be followed by `stop` which is not consumed | Object of key/value pairs |
| `maybe_object(key, value)` | Both `key` and `value` together zero or more times | Object of key/value pairs, maybe empty |
| `maybe_object_sep(key, pair_sep, value, sep)` | Parses `key`, `pair_sep`, and `value` together zero or more times, interspersed with `sep` | Object of key/value pairs, maybe empty|
| `label(Key, value)` | Parses `value` | Parsed `Value` wrapped in a `{Key: Value}` object |
| `json_object` | Parses an arbitrary JSON object | Object with any JSON members |
| `json_array` | Parses an arbitrary JSON array | Array with any JSON elements |
| `json_string` | Parses a double-quoted string, handling JSON escape characters | String |
| `json` | JSON encoded value | Matched JSON |

### Values

| Function | Prerequisites | Behavior | Returns |
| -------- | ------------- | -------- | --------|
| `IsArray(V)` | None      | Succeed if `V` is an array | `V`, an array |
| `IsObject(V)` | None     | Succeed if `V` is an object | `V`, an object |
| `IsString(V)` | None     | Succeed if `V` is a string | `V`, a string |
| `IsTrue(V)` | None       | Succeed if `V` is `true` | `true` |
| `IsFalse(V)` | None      | Succeed if `V` is `false` | `false` |
| `IsBoolean(V)` | None    | Succeed if `V` is a `true` or `false` | `true` or `false` |
| `IsNull(V)` | None       | Succeed if `V` is `null` | `null` |

| `First(E)` | `E` is an enumerable | Succeed if `E` has at least one element | First element in `E` |
| `Last(E)` | `E` is an enumerable | Succeed if `E` has at least one element | Last element in `E` |
| `Front(E)` | `E` is an enumerable |Succeed if `E` has at least one element | All but last element in `E` |
| `Tail(E)` | `E` is an enumerable |Succeed if `E` has at least one element | All but first element in `E` |

| `Map(F, E)` | `F` is a function, `E` is an enumerable | Apply `F` to
| `Reverse(E)` | `E` is an enumerable |
| `Reduce(F, Acc, E)` | `E` is an enumerable |

| `MergeAll(A)` | `A` is an array | Merge all elements of `A` into a single value | Merged value |
| `SplitAll(E)` | `E` is an enumerable | Split each element of `E` into an array | Array of elements |

| `Filter(F, E)` | `F` is a function, `E` is an enumerable |
| `Reject(F, E)` | `F` is a function, `E` is an enumerable |

| `TransposeTable(T)` | `T` is an array of arrays | Flip table elements along a diagonal, bottom left element becomes the top right element | Array of arrays |
| `RotateTableClockwise(T)` | `T` is an array of arrays | Shift table elements so rows become columns, bottom left element becomes the first element | Array of arrays |
| `RotateTableCounterClockwise(T)` | `T` is an array of arrays | Shift table elements so rows become columns, top right element becomes the first element | Array of arrays |

| `ZipIntoArray(E1, E2)` | `E1` and `E2` are both enumerables |
| `ZipIntoObject(Keys, E)` | `Keys` is an array of strings, `E` is an enumerable |




Apply `F(Val)` for each `Val` in `Enum`, an array, object, or string | Array of parsed values |
| `Fold(F, Acc, Enum)` | Parser `p(Acc, Val)` for each `Val` in array `A` and the accumulated value `Acc` | Final `Acc` |

| `Tabular(Header, Rows)`
|

|  | Succeed with no match, given `Header` is an array of strings and `Rows` is a table of values | Array of objects with header col/row col pairs |
| `Map(F, Enum)` | Apply `F(Val)` for each `Val` in `Enum`, an array, object, or string | Array of parsed values |
| `Fold(F, Acc, Enum)` | Parser `p(Acc, Val)` for each `Val` in array `A` and the accumulated value `Acc` | Final `Acc` |
| `Reject(` |
| `RotateTableClockwise(Table)` |



| `MergeArray(A)` | Succeed with no match, given `A` is an array of arrays | Array with all elements of sub-arrays |
| `ZipArray(A, B)` | Succeed with no match, given `A` and `B` are both arrays | Array of `[ ValueA, ValueB ]` tuples |
| `ZipObject(A, B)` | Succeed with no match, given `A` and `B` are both arrays | Array of `[ ValueA, ValueB ]` tuples |
| `RotateTableClockwise(T)` | Succeed with no match, given `T` is an array of arrays | Shift table elements so rows become columns, bottom left element becomes the first element |
| `RotateTableCounterClockwise(T)` | Succeed with no match, given `T` is an array of arrays | Shift table elements so rows become columns, top right element becomes the first element |

