# Possum Advanced Features

This guide covers  of Possum and should give you enough

String literals and ranges can also use single quotes or backticks.

## Alternative String Literal Syntax

```
  $ possum -p '"\n\n"' -i '

  '
  "\n\n"

  $ possum -p '"\\n\\n"' -i '\n\n'
  "\\n\\n"

  $ possum -p '"\\\\\\\\"' -i '\\\\'
  "\\\\\\\\"

  $ possum -p "'\\\\\\\\'" -i '\\\\'
  "\\\\\\\\"

  $ possum -p '`\\\\`' -i '\\\\'
  "\\\\\\\\"

  $ possum -p '"\"\"\""' -i '"""'
  "\"\"\""

  $ possum -p '`"""`' -i '"""'
  "\"\"\""
```

## Uncommon Infix Operators

The "backtrack" operator `p1 ! p2` matches `p1` and then goes back in the input
and matches `p2` instead, returning the result of `p2`. This means that in order
for the parser to succeed both `p1` and `p2` must succeed.
```
  $ possum -p '123 ! int' -i '123456789'
  123456789
```
The standard library uses backtracking to implement `peek(p)`.
```
peek(p) = (V <- p) ! const(V)
```
In practice `peek` can do everything that backtracking can do, so I've
personally come to prefer it.
```
  $ possum -p 'peek(123) & int' -i '123456789'
  123456789
```

The "conditional" operator `p1 ? p2 : p3` matches `p1` and then on
success matches and returns `p2`. If `p1` fails then it matches
and returns `p3` instead. This operator is necessary in a few specific
situations. One is when the desired parsing behavior is to fail when a parser
succeeds. In the following examples we want the parser to fail if the input
starts with a number, otherwise if the input doesn't start with a number parse
the first word.
```
  $ possum -p '(number > fail) | word' -i 'ThisShouldSucceed'
  "ThisShouldSucceed"

  $ possum -p '(number > fail) | word' -i '123ThisShouldFail'
  "123ThisShouldFail"

  $ possum -p 'number ? fail : word' -i '123ThisShouldFail'
  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 4:
  123ThisShouldFail
     ^

  The last attempted parser was:
  number
  fail

  But no match was found.
```
The other use case is [tail call] optimized recursive parsers. To help motivate
this case, here's an example of how we can implement the `many(p)` parser from
the standard library using simple recursion:
```
many(p) = p + (many(p) | "")
```
This implementation will work for small inputs, but could fail with a stack
overflow error on large inputs. The recursive call to `maybe(p)` is not in tail
position, since neither the `+` or `|` can resolve until the recursive call
returns, and as a result each function call must happen in a new stack frame. We
can instead use tail call recursion to re-use the same stack frame. In the
following case the recursive call to `_many_rec(p, Acc)` isn't at the end of the
parser, but it's in a terminating position because we know that only one of the
branches of the conditional will get executed.
```
many(p) = First <- p & _many_rec(p, First)

_many_rec(p, Acc) =
  Next <- p ?
  _many_rec(p, Acc + Next) :
  const(Acc)
```
The standard library is written using tail call recursion so that users don't
run into surprises at runtime. In general user-defined parsers should be fine
using naive recursion, or better yet use standard library functions instead.

[tail call]: https://en.wikipedia.org/wiki/Tail_call

## Building and Destructuring Values

Variables in a pattern can only be assigned once. Any subsequent references to a
variable use the previously assigned value. In this example the parser matches
three digits, but only if the second and third digit have the same value as the
first digit.
```
  $ possum -p 'D <- digit & D <- digit & D <- digit $ [D, D, D]' -i '444'
  [ 4, 4, 4 ]

  $ possum -p 'D <- digit & D <- digit & D <- digit $ [D, D, D]' -i '445'

  Error Parsing Input

  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.

  The parser failed on line 1, character 3:
  445
    ^

  The last attempted parser was:
  Destructure

  But no match was found.
```

In addition to returning arrays and objects containing variables as elements,
we can use a variable as the key in a key/value object pair. The variable
must be a string
```
  $ possum -p 'Var <- word & " = " & Value <- int $ {Var: Value}' -i 'MY_SECRET = 12345'
  { "MY_SECRET": 12345 }

  $ possum -p 'Id <- int & " : " & Active <- bool("true", "false") $ {Id: Active}' -i '12345 : true'

  Error Creating Object

  ~~~(##)'>  I wasn't able to create an object because one of the key/value pairs
  has a key which is not a string.

  The parser failed on line 1, characters 56-57:
  Id <- int & " : " & Active <- bool("true", "false") $ {Id: Active}
                                                         ^^

  The value assigned to `Id` is a number, but it needs to be a string in order to
  create a valid object.
```

Number arithmetic
| `1 + 2e-4`        | Number arithmetic |
| `2.1 - 12`        | Number arithmetic |
| `0 + N <- p`       | Match a number using arithmetic, bind the value to `N` |
| `N + 100 <- p`     | Match a number, bind `N` such that `N + 100` is equal to the matched number |

Array spread
| `[ "a", 0, true, Var ]` | Array of values |
| `[ "a", ...Var ]` | Array, including all of the elements of the array `Var` |
| `[...A] <- p`      | Match an array using a spread, bind the value to `A` |
| `[A, ..._] <- p`   | Match an array with at least one element, bind the first element to `A` |
| `[A, ..._, Z] <- p` | Match an array with at least two elements, bind the first element to `A` and last to `Z` |

Object spread
| `{ "foo": 0, "bar": Var }` | Object of key/value pairs |
| `{ "foo": 0, Var: null }` | Object with the string `Var` as a key |
| `{ "foo": 0, ...Var }` | Object, containing all of the members of the object `Var` |
| `{...O} <- p`      | Match an object using a spread, bind the value to `O` |
| `{"a": true, "b": false} <- p` | Match an object exactly |
| `{"a": 1, ..._} <- p`   | Match an object where the key `"a"` has the value `1` |
| `{_: 1, ..._} <- p`   | Match an object where one of the keys has the value `1` |
| `{"a": A, ..._} <- p` | Match an object with the key `"a"`, bind the value to `A` |
| `{..._, "a": A} <- p` | As above, object patterns are not position dependant |
| `{"a": _, "b": B, "c": _} <- p` | Match an object with exactly the keys `"a"`, `"b"`, and `"c"`, bind the value of `"b"` to `B` |

Merging values


String interpolation
| `"hello %(Foo)"`  | String interpolation |
| `"%(S)" <- p`      | Match a string using interpolation, bind the value to `S` |
| `"%3(_)" <- p`     | Match a string of length 3 |
| `"%3(S)" <- p`     | Bind a string of length 3 to `S` |
| `"abc%(Rest)" <- p` | Match `"abc"` and bind any remaining string to `Rest` |
| `"%(Front)d" <- p` | Match a string ending in `d`, bind all but the last character to `Front` |
| `"%1(A)%(_)" <- p`  | Match a string of length at least one, bind the first character to `A` |
| `"%(null)" <- p`   | Match a string encoding a constant |
| `"%(0 + N)" <- p`  | Match a string encoding a number, bind the number to `N`|
| `"%2(0 + _)" <- p` | Match a string of length 2 encoding a number |
| `"%(N + 1)" <- p`  | Match a string encoding a number, calculate and bind `N` |
| `"%([...A])" <- p` | Match a string encoding an array, bind the array to `A` |
| `"%({..._})" <- p` | Match a string encoding an object |

## Pattern Matching and String Interpolation

Number arithmetic
| `1 + 2e-4`        | Number arithmetic |
| `2.1 - 12`        | Number arithmetic |
| `0 + N <- p`       | Match a number using arithmetic, bind the value to `N` |
| `N + 100 <- p`     | Match a number, bind `N` such that `N + 100` is equal to the matched number |
`N + M` -> `0 + N + M`

Array spread
| `[ "a", 0, true, Var ]` | Array of values |
| `[ "a", ...Var ]` | Array, including all of the elements of the array `Var` |
| `[...A] <- p`      | Match an array using a spread, bind the value to `A` |
| `[A, ..._] <- p`   | Match an array with at least one element, bind the first element to `A` |
| `[A, ..._, Z] <- p` | Match an array with at least two elements, bind the first element to `A` and last to `Z` |

Object spread
| `{ "foo": 0, "bar": Var }` | Object of key/value pairs |
| `{ "foo": 0, Var: null }` | Object with the string `Var` as a key |
| `{ "foo": 0, ...Var }` | Object, containing all of the members of the object `Var` |
| `{...O} <- p`      | Match an object using a spread, bind the value to `O` |
| `{"a": true, "b": false} <- p` | Match an object exactly |
| `{"a": 1, ..._} <- p`   | Match an object where the key `"a"` has the value `1` |
| `{_: 1, ..._} <- p`   | Match an object where one of the keys has the value `1` |
| `{"a": A, ..._} <- p` | Match an object with the key `"a"`, bind the value to `A` |
| `{..._, "a": A} <- p` | As above, object patterns are not position dependant |
| `{"a": _, "b": B, "c": _} <- p` | Match an object with exactly the keys `"a"`, `"b"`, and `"c"`, bind the value of `"b"` to `B` |

Merging values


String interpolation
| `"hello %(Foo)"`  | String interpolation |
| `"%(S)" <- p`      | Match a string using interpolation, bind the value to `S` |
| `"%3(_)" <- p`     | Match a string of length 3 |
| `"%3(S)" <- p`     | Bind a string of length 3 to `S` |
| `"abc%(Rest)" <- p` | Match `"abc"` and bind any remaining string to `Rest` |
| `"%(Front)d" <- p` | Match a string ending in `d`, bind all but the last character to `Front` |
| `"%1(A)%(_)" <- p`  | Match a string of length at least one, bind the first character to `A` |
| `"%(null)" <- p`   | Match a string encoding a constant |
| `"%(0 + N)" <- p`  | Match a string encoding a number, bind the number to `N`|
| `"%2(0 + _)" <- p` | Match a string of length 2 encoding a number |
| `"%(N + 1)" <- p`  | Match a string encoding a number, calculate and bind `N` |
| `"%([...A])" <- p` | Match a string encoding an array, bind the array to `A` |
| `"%({..._})" <- p` | Match a string encoding an object |

## Recursive Parsers

Recursive parsers can be used to build up arrays and objects using `...` spread
syntax to add the members of an object or array to a new object or array.
```
  $ possum -p "
      int_list =
        (I <- int & ',' & L <- int_list $ [I, ...L]) |
        (I <- int $ [I]) ;
      int_list
    " -i "1,2,3,4,5,6"
  [ 1, 2, 3, 4, 5, 6 ]

  $ possum -p "
      rev_int_list =
        (I <- int & ',' & L <- rev_int_list $ [...L, I]) |
        (I <- int $ [I]) ;
      rev_int_list
    " -i "1,2,3,4,5,6"
  [ 6, 5, 4, 3, 2, 1 ]

  $ possum -p "
      field = Key <- many(alpha) & ':' & Val <- int $ {Key: Val} ;
      fields = F <- field & ws & Fs <- fields $ {...F, ...Fs} | field ;
      fields
    " -i "foo:33 bar:1"
  { "foo": 33, "bar": 1 }
```

We can also recursively iterate over arrays and objects via destructuring. Here
`[K, ...Ks] <- const(Keys)` matches when `Keys` is an array with at least one
element. The first element in the array is assigned to `K`, and the remaining
(possibly empty) array is assigned to `Ks`.
```
  $ possum -p "
      zip_pairs(Keys, Values) = (
        [K, ...Ks] <- const(Keys) &
        [V, ...Vs] <- const(Values) &
        Rest <- zip_pairs(Ks, Vs) $
        {K: V, ...Rest}
      ) | const({}) ;

      Keys <- array(alpha) & ';' & Values <- array(digit) &
      Pairs <- zip_pairs(Keys, Values) $ Pairs
    " -i "ABC;123"
  { "A": 1, "B": 2, "C": 3 }
```

## Value functions

## Meta functions
