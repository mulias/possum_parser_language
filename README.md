# Possum Parser Language

Possum is a domain specific language for parsing arbitrary text into JSON. A
Possum program describes both the expected input format and the desired output
format of data by composing simple parser functions to create larger and more
complex parsers. Possum is inspired by a number of languages and tools
including [Awk], Haskell's [Parsec] library, [Definite Clause Grammars] in
Prolog, [jq], [Parser Expression Grammars], and [Rosie Pattern Language].

[Awk]: https://en.wikipedia.org/wiki/AWK
[Parsec]: https://hackage.haskell.org/package/parsec
[Definite Clause Grammars]: https://en.wikipedia.org/wiki/Definite_clause_grammar
[jq]: https://stedolan.github.io/jq/
[Parser Expression Grammars]: https://en.wikipedia.org/wiki/Parsing_expression_grammar
[Rosie Pattern Language]: https://rosie-lang.org/

## Examples

### Parse an array of arrays of numbers

```
  $ cat numbers.txt
  31,88,35,24,46,48,95,42,18,43,71,32,92,62,97,63,50,2,60,58,74,66
  15,87,57,34,14,3,54,93,75,22,45,10
  56,12,83,30,8,76,1,78,82,39,98,37,19,26,81,64,55,41,16,4,72,5
  52,80,84,67,21,86,23,91,0,68,36,13,44,20,69,40,90
  96,27,77,38,49,94,47,9,65,28,59,79,6,29,61,53,11,17,73,99,25,89,51,7,33,85,70


  $ possum -p 'table_sep(int, ",", nl)' numbers.txt
  [
    [
      31, 88, 35, 24, 46, 48, 95, 42, 18, 43, 71, 32, 92, 62, 97, 63, 50, 2,
      60, 58, 74, 66
    ],
    [ 15, 87, 57, 34, 14, 3, 54, 93, 75, 22, 45, 10 ],
    ...
  ]
```

### Parse a list of line segments

```
  $ cat lines.txt
  8,0 -> 0,8
  0,9 -> 5,9
  9,4 -> 3,4
  2,2 -> 2,1
  7,0 -> 7,4
  6,4 -> 2,0
  0,9 -> 2,9
  3,4 -> 1,4
  0,0 -> 8,8
  5,5 -> 8,2


  $ cat lines_parser.possum
  point = tuple2_sep(int, ",", int)
  line = record2_sep("from", point, " -> ", "to", point)
  array_sep(line, nl)


  $ possum lines_parser.possum lines.txt
  [
    { "from": [ 8, 0 ], "to": [ 0, 8 ] },
    { "from": [ 0, 9 ], "to": [ 5, 9 ] },
    { "from": [ 9, 4 ], "to": [ 3, 4 ] },
    { "from": [ 2, 2 ], "to": [ 2, 1 ] },
    ...
  ]
```

### Parse an abstract syntax tree

```
  $ cat fibonacci.rkt
  (define (fib n)
    (cond ((= n 0) 0)
          ((= n 1) 1)
          (else (+ (fib (- n 1)) (fib (- n 2))))))

  (display "Fibonacci of 10 is ")
  (display (fib 10))


  $ cat lisp_parser.possum
  input(program)

  program = array_sep(expr, maybe(ws))

  expr =
    node("apply", apply) |
    node("atom", atom) |
    node("number", number) |
    node("string", string)

  apply = "(" > maybe_array_sep(expr, maybe(ws)) < ")"

  atom_char = unless(char, "(" | ")" | '"')
  atom = many(atom_char)

  string = '"' > maybe(until(char, '"')) < '"'

  node(Type, p) = p -> Value $ {"type": Type, "value": Value}


  $ possum lisp_parser.possum fibonacci.rkt
  [
    {
      "type": "apply",
      "value": [
        { "type": "atom", "value": "define" },
        {
          "type": "apply",
          "value": [
            { "type": "atom", "value": "fib" },
            { "type": "atom", "value": "n" }
          ]
        },
        ...
      ]
    },
    {
      "type": "apply",
      "value": [
        { "type": "atom", "value": "display" },
        {
          "type": "apply",
          "value": [
            { "type": "atom", "value": "fib" },
            { "type": "number", "value": 10 }
          ]
        }
      ]
    }
  ]
```

### Fibonacci Sequence

```
  $ cat fibonacci.possum
  Fib(N) =
    N -> 0 ? 0 :
    N -> 1 ? 1 :
    Fib(N - 1) + Fib(N - 2)

  int -> N $ Fib(N)


  $ possum fibonacci.possum --input=10
  55
```

## Installation

The prototype version of Possum is still available on the [Github releases page].
The new implementation does not yet have precompiled binaries, but can be built
from source via `zig build`.

[github releases page]: https://github.com/mulias/possum_parser_language/releases

## Documentation

- [`overview`]: Example-based guide covering Possum's main features.
- [`advanced`]: Continuation of the example-based guide, focusing on more
    specialized and situational functionality.
- [`language`]: Condensed reference for the core language.
- [`cli`]: Using Possum from the command line.
- [`stdlib`]: Possum standard library reference.

[`overview`]: docs/overview.md
[`advanced`]: docs/advanced.md
[`language`]: docs/language.md
[`cli`]: docs/cli.txt
[`stdlib`]: docs/stdlib.md

## `~~~(##)'>` Regarding Possums

It's a well known fact that your computer is full of little guys who run around
and make all the things you want happen. These little guys come in all shapes
and sizes and are good at doing many different things. In this case the little
guy making your program work is a possum. They rustle through your text files
and forage for the bits of data you want to keep and store those in their pouch.
Once they've carefully looked behind every stone and under each newline they
arrange everything they've collected as nicely formatted JSON. What a helpful
little guy!
