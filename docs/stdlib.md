# Standard Library

These parsers and value functions are always available in Possum programs, unless Possum is ran with the `--no-stdlib` flag.

## Parsers

### Strings

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `char`             | One [code point], informally called a "character" | Matched string |
| `ascii`            | One [ASCII] code point     | Matched string |
| `alpha`            | One lower- or upper-case letter from the English alphabet, "a" to "z" or "A" to "Z" | Matched string |
| `alphas`           | One or more `alpha`s       | Matched string             |
| `lower`            | One lower-case letter from the English alphabet, "a" to "z" | Matched string |
| `lowers`           | One or more `lower`s       | Matched string             |
| `upper`            | One upper-case letter from the English alphabet, "A" to "Z" | Matched string |
| `uppers`           | One or more `upper`s       | Matched string             |
| `numeral`          | One Arabic numeral, "0" to "9" | Matched string         |
| `numerals`         | One or more `numeral`s     | Matched string             |
| `binary_numeral`   | One binary numeral, "0" or "1" | Matched string         |
| `octal_numeral`    | One octal numeral, "0" to "7" | Matched string          |
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
| `chars_until(stop)` | One or more codepoints, must be followed by `stop` which is not consumed | Merged string of all matched codepoints |

[code point]: https://en.wikipedia.org/wiki/Code_point
[ascii]: https://en.wikipedia.org/wiki/ASCII

### Numbers

| Parser             | Parses                     | Returns                    |
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
| `non_negative_number` | Valid JSON number without a leading minus sign | Integer number greater than or equal to zero |
| `negative_number`  | Valid JSON number with a leading minus sign | Integer number less than or equal to `-0` |
| `binary_digit`     | One binary numeral "0" or "1" | Integer number 0 or 1   |
| `octal_digit`      | One octal numeral "0" to "7" | Integer number between 0 and 7 |
| `hex_digit`        | One hexadecimal numeral, "0" to "9", "a" to "f", or "A" to "F" | Integer number between 0 and 15 |
| `binary_integer`   | Binary digits, no leading zeros | Integer number converted to base 10 |
| `octal_integer`    | Octal digits, no leading zeros | Integer number converted to base 10 |
| `hex_integer`      | hexadecimal digits, no leading zeros | Integer number converted to base 10 |

### Constants

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `true(t)`          | `t`                        | `true`                     |
| `false(f)`         | `f`                        | `false`                    |
| `boolean(t, f)`    | `t` or `f`                 | `true` or `false`          |
| `bool(t, f)`       | Alias for `boolean`        | As above                   |
| `null(n)`          | `n`                        | `null`                     |

### Arrays

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
| `rows(elem, col_sep, row_sep)` | One or more `elem`, interspersed with `col_sep` or `row_sep` | Array of arrays of values in each row, rows may be of different lengths |
| `rows_padded(elem, col_sep, row_sep, Pad)` | One or more `elem`, interspersed with `col_sep` or `row_sep` | Array of arrays of values in each row, short rows are padded with `Pad` to all be the same length |
| `columns(elem, col_sep, row_sep)` | One or more `elem`, interspersed with `col_sep` or `row_sep` | Array of arrays of values in each column, columns may be of different lengths |
| `cols(elem, col_sep, row_sep)` | Alias for `columns` | As above              |
| `columns_padded(elem, col_sep, row_sep, Pad)` | One or more `elem`, interspersed with `col_sep` or `row_sep` | Array of arrays of values in each column, short rows are padded with `Pad` to all be the same length |
| `cols_padded(elem, col_sep, row_sep, Pad)` | Alias for `columns_padded` | As above |

### Objects

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

### Repeated

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `many(p)`          | One or more `p`            | Merged values parsed by `p` |
| `many_sep(p, sep)` | One or more `p`, interspersed with `sep` | Marged values parsed by `p` |
| `many_until(p, stop)` | One or more `p`, must be followed by `stop` which is not consumed | Merged values parsed by `p` |
| `maybe_many(p)`    | Zero or more `p`           | Merged values parsed by `p`, or `null` if `p` fails |
| `maybe_many_sep(p, sep)` | Zero or more `p`, interspersed with `sep` | Merged values parsed by `p`, or `null` if `p` fails |

### Utility

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
| `as_number(p)`     | `p`, succeeds if the value is a valid JSON number or string encoding of a number | Number |
| `as_string(p)`     | `p`                        | Compact encoding of the parsed value as a JSON string |
| `surround(p, fill)` | `fill`, then `p`, then `fill` again | Result of `p` |
| `end_of_input`     | End of string or file input | `null` |
| `end`              | Alias for `end_of_input`   | As above |
| `input(p)`         | Strips leading and trailing whitespace, succeeds if `p` parses to end of input | Result of `p` |
| `one_or_both(a, b)` | `a`, `b`, or `a + b`      | Result of the successful parser, or two results merged |

### JSON

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `json`             | Any valid JSON             | Matched JSON               |
| `json.string`      | Valid JSON string          | Matched string contents, not including quotes |
| `json.number`      | Alias for `number`         | Number |
| `json.boolean`     | JSON "true" or "false" keyword | `true` or `false`      |
| `json.null`        | JSON "null" keyword        | `null`                     |
| `json.array(elem)` | JSON array containing zero or more `elem`s | Array of values parsed by `elem` |
| `json.object(value)` | JSON object containing zero or more `value`s | Object with values parsed by `value` |

### TOML

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `toml`             | Alias for `toml.simple`    | As below                   |
| `toml.simple`      | Valid TOML document        | Object with TOML values, unsupported types encoded as strings |
| `toml.tagged`      | Valid TOML document        | Object with TOML values, unsupported types encoded as strings tagged with type information |
| `toml.custom(value)` | TOML document with custom `value`s for each key/value pair | Object with parsed values |
| `toml.simple_value` | Valid TOML value          | Parsed value, unsupported types encoded as strings |
| `toml.tagged_value` | Valid TOML value          | Parsed value, unsupported types encoded as strings tagged with type information |
| `toml.string`      | [TOML string]              | String                     |
| `toml.datetime`    | [TOML date-time]           | String                     |
| `toml.number`      | [TOML number]              | Integer, float, or string encoding of Infinity/NaN/Binary/Octal/Hex number |
| `toml.boolean`     | [TOML boolean]             | `true` or `false`          |
| `toml.array(elem)` | [TOML array] containing zero or more `elem`s | Array of values parsed by `elem` |
| `toml.inline_table(value)` | [TOML inline table] containing zero or more `value`s | Object with values parsed by `value` |
| `toml.string.basic` | TOML single-line [basic string] | String               |
| `toml.string.literal` | TOML single-line [literal string] | String           |
| `toml.string.multi_line_basic` | TOML multi-line [basic string] | String     |
| `toml.string.multi_line_literal` | TOML multi-line [literal string] | String |
| `toml.datetime.offset` | [TOML date-time] with timezone offset | String      |
| `toml.datetime.local` | [TOML date-time] without timezone offset | String    |
| `toml.datetime.local_date` | [TOML date] without time or offset | String     |
| `toml.datetime.local_time` | [TOML time] without date or offset | String     |
| `toml.number.integer` | [TOML integer]          | Integer number             |
| `toml.number.float` | [TOML float]              | Float number               |
| `toml.number.infinity` | TOML infinity          | String                     |
| `toml.number.not_a_number` | TOML NaN           | String                     |
| `toml.number.binary_integer` | TOML binary integer | Integer                 |
| `toml.number.octal_integer` | TOML octal integer | Integer                   |
| `toml.number.hex_integer` | TOML hexadecimal integer | Integer               |

[TOML string]: https://toml.io/en/v1.0.0#string
[TOML date-time]: https://toml.io/en/v1.0.0#offset-date-time
[TOML date]: https://toml.io/en/v1.0.0#local-date
[TOML time]: https://toml.io/en/v1.0.0#local-time
[TOML number]: https://toml.io/en/v1.0.0#integer
[TOML boolean]: https://toml.io/en/v1.0.0#boolean
[TOML array]: https://toml.io/en/v1.0.0#array
[TOML inline table]: https://toml.io/en/v1.0.0#inline-table
[basic string]: https://toml.io/en/v1.0.0#string
[literal string]: https://toml.io/en/v1.0.0#string
[TOML integer]: https://toml.io/en/v1.0.0#integer
[TOML float]: https://toml.io/en/v1.0.0#float

### Abstract Syntax Trees

See the `stdlib-ast` docs for more detailed documentation.

| Parser             | Parses                     | Returns                    |
| ------------------ | -------------------------- | -------------------------- |
| `ast.with_operator_precedence(operand, prefix, infix, postfix)` | `operands`s with prefix and postfix operators, composed with infix operators | Abstract syntax tree |
| `ast.node(Type, value)` | `value`               | Object with `"type"`, `"value"`, `"start"`, and `"end"` fields |

## Values

### Numbers

| Value              | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `Num.Add(A, B)`    | Sum `A` and `B`, error if values are not numbers or null |
| `Num.Sub(A, B)`    | Subtract `B` from `A`, error if values are not numbers or null |
| `Num.Mul(A, B)`    | Multiply `A` and `B`, error if values are not numbers or null |
| `Num.Div(A, B)`    | Divide `A` by `B`, error if values are not numbers or null, or if `B` is 0 |
| `Num.Pow(A, B)`    | Raise `A` to the exponent `B`, error if values are not numbers or null |
| `Num.Inc(N)`       | Increment, return `N + 1`                               |
| `Num.Dec(N)`       | Decrement, return `N - 1`                               |
| `Num.FromBinaryDigits(Bs)` | Convert an array of `0`s and `1`s to a base 10 integer |
| `Num.FromOctalDigits(Os)` | Convert an array of numbers between 0 and 7 to a base 10 integer |
| `Num.FromHexDigits(Hs)` | Convert an array of numbers between 0 and 15 to a base 10 integer |

### Arrays

| Value              | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `Array.First(A)`   | Get the first element in `A`, fail if `A` is not an array with at least one element |
| `Array.Rest(A)`    | Return the remaining array without the first element, fails if `A` is not an array with at least one element |
| `Array.Length(A)`  | Number of elements in `A`                               |
| `Array.Reverse(A)` | Reverse elements of the array `A` so that the first element becomes the last, etc |
| `Array.Map(A, Fn)` | Apply the function `Fn` to each element in the array `A` |
| `Array.Filter(A, Pred)` | Apply the function `Pred` to each element in the array `A`, return an array excluding elements where `Pred` fails |
| `Array.Reject(A, Pred)` | Apply the function `Pred` to each element in the array `A`, return an array excluding elements where `Pred` succeeds |
| `Array.ZipObject(Ks, Vs)` | Pair together keys from `Ks` and values from `Vs` into an object |
| `Array.ZipPairs(Ks, Vs)` | Pair together keys from `Ks` and values from `Vs` into an object |
| `Table.Transpose(T)` | Swap an array of arrays over the diagonal so that rows become columns |
| `Table.RotateClockwise(T)` | Rotate an array of arrays 90 degrees clockwise |
| `Table.RotateCounterClockwise(T)` | Rotate an array of arrays 90 degrees clockwise |
| `Table.ZipObjects(Ks, Rows)` | Transform an array of `Rows` into an array of objects where each column is paired with its header from `Headers` |

### Objects

| Value              | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `Obj.Get(O, K)`    | Retrieve the value associated with the key `K` in the object `O` |
| `Obj.Put(O, K, V)` | Add the key `K` with value `V` to the object `O`        |

### Abstract Syntax Trees

See the `stdlib-ast` docs for more detailed documentation.

| Value Function     | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `Ast.OpPrecedence(OpNode, BindingPower)` | Returns array with two elements, `OpNode` and `BindingPower` |
| `Ast.InfixOpPrecedence(OpNode, LeftBindingPower, RightBindingPower)` | Returns array with three elements, `OpNode`, `LeftBindingPower`, and `RightBindingPower` |

### Predicates

| Value              | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `Is.String(V)`     | Return `V` if the value is a string, otherwise fail     |
| `Is.Number(V)`     | Return `V` if the value is a number, otherwise fail     |
| `Is.Bool(V)`       | Return `V` if the value is `true` or `false`, otherwise fail |
| `Is.Null(V)`       | Return `V` if the value is `null`, otherwise fail       |
| `Is.Array(V)`      | Return `V` if the value is an array, otherwise fail     |
| `Is.Object(V)`     | Return `V` if the value is an object, otherwise fail    |
| `Is.Equal(A, B)`   | Return `A` if `A` and `B` are structurally equal values |
| `Is.LessThan(A, B)` | Return `A` if `A` is strictly less than `B`            |
| `Is.LessThanOrEqual(A, B)` | Return `A` if `A` is less than or equal to `B`  |
| `Is.GreaterThan(A, B)` | Return `A` if `A` is strictly greater than `B`      |
| `Is.GreaterThanOrEqual(A, B)` | Return `A` if `A` is greater than or equal to `B` |

### Conversion

| Value              | Behavior                                                |
| ------------------ | ------------------------------------------------------- |
| `As.Number(V)`     | Convert string encoding of number into a number         |
| `As.String(V)`     | Convert any value into a string containing a compact JSON encoding of the value|
