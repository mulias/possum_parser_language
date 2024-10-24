# Possum Parser Language

Possum is a domain-specific language designed for parsing text into JSON. You can use Possum for tasks ranging from single-line scripts for data extraction to quickly prototyping a new programming language syntax. The language aims to make parsing friendly and fun, and uses a minimal feature set to write declarative programs that are both compact and readable.

Possum is inspired by classic Unix utilities like [AWK] and [sed], as well as tools such as Haskell's [Parsec] library, [Definite Clause Grammars] in Prolog, [jq], [Parser Expression Grammars] in [many] [languages], and [Rosie Pattern Language].

[AWK]: https://en.wikipedia.org/wiki/AWK
[sed]: https://en.wikipedia.org/wiki/Sed
[Parsec]: https://hackage.haskell.org/package/parsec
[Definite Clause Grammars]: https://en.wikipedia.org/wiki/Definite_clause_grammar
[jq]: https://stedolan.github.io/jq/
[Parser Expression Grammars]: https://en.wikipedia.org/wiki/Parsing_expression_grammar
[many]: https://docs.rs/peg/latest/peg/
[languages]: https://janet-lang.org/docs/peg.html
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


  $ possum --parser='table_sep(int, ",", nl)' numbers.txt
  [
    [31, 88, 35, 24, 46, 48, 95, 42, 18, 43, 71, 32, 92, 62, 97, 63, 50, 2, 60, 58, 74, 66],
    [15, 87, 57, 34, 14, 3, 54, 93, 75, 22, 45, 10],
    [56, 12, 83, 30, 8, 76, 1, 78, 82, 39, 98, 37, 19, 26, 81, 64, 55, 41, 16, 4, 72, 5],
    [52, 80, 84, 67, 21, 86, 23, 91, 0, 68, 36, 13, 44, 20, 69, 40, 90],
    [96, 27, 77, 38, 49, 94, 47, 9, 65, 28, 59, 79, 6, 29, 61, 53, 11, 17, 73, 99, 25, 89, 51, 7, 33, 85, 70]
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
    {
      "from": [8, 0],
      "to": [0, 8]
    },
    {
      "from": [0, 9],
      "to": [5, 9]
    },
    {
      "from": [9, 4],
      "to": [3, 4]
    },
    ...
  ]
```

### Parse an abstract syntax tree

This example uses `possum` as a [shebang script](https://en.wikipedia.org/wiki/Shebang_(Unix)).

```
  $ cat fibonacci.rkt
  (define (fib n)
    (if (<= n 1) n
        (+ (fib (- n 1)) (fib (- n 2)))))

  (display "Fibonacci of 10 is ")
  (display (fib 10))


  $ cat lisp_ast
  #!/usr/bin/env possum

  input(program)

  program = array_sep(expr, maybe(ws))

  expr =
    node("apply", apply)   |
    node("number", number) |
    node("string", string) |
    node("atom", atom)

  apply = "(" > maybe_array_sep(expr, maybe(ws)) < ")"

  atom_char = unless(char, "(" | ")" | '"' | ws)
  atom = many(atom_char)

  string = '"' > default(many_until(char, '"'), "") < '"'

  node(Type, p) = p -> Value $ {"type": Type, "value": Value}


  $ lisp_ast fibonacci.rkt
  [
    {
      "type": "apply",
      "value": [
        {"type": "atom", "value": "define"},
        {
          "type": "apply",
          "value": [
            {"type": "atom", "value": "fib"},
            {"type": "atom", "value": "n"}
          ]
        },
        ...
      ]
    },
    ...
    {
      "type": "apply",
      "value": [
        {"type": "atom", "value": "display"},
        {
          "type": "apply",
          "value": [
            {"type": "atom", "value": "fib"},
            {"type": "number", "value": 10}
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
    N -> ..1 ? N :
    Fib(N - 1) + Fib(N - 2)

  int -> N $ "Fibonacci of %(N) is %(Fib(N))"


  $ possum fibonacci.possum --input=10
  "Fibonacci of 10 is 55"
```

## Installation

Precompiled binaries are available on the [Github releases page].

To build from source with Nix run `nix develop` to enter a shell environment with the necessary dependencies. To build from source without Nix you'll need to first install the dependencies specified in `flake.nix`. Run `zig build --release=safe` to produce the binary `zig-out/bin/possum`, and run `zig build --help` to view other options.

[github releases page]: https://github.com/mulias/possum_parser_language/releases/latest

## Documentation

The official Possum docs are included in this repository and baked in to the Possum cli tool:

* [`overview`] - Example-based guide covering Possum's main features.
* [`advanced`] - Continuation of the example-based guide, focusing on more specialized and situational functionality.
* [`language`] - Condensed reference for the core language.
* [`cli`] - Using Possum from the command line.
* [`stdlib`] - Possum standard library reference.
* [`stdlib-ast`]: Using the stdlib to parse abstract syntax trees.

Some other helpful resources:

* [`examples` directory] features a number of parsing use cases, including [Advent of Code] puzzle input parsers.
* [Blog posts about Possum]

[`overview`]: docs/overview.md
[`advanced`]: docs/advanced.md
[`language`]: docs/language.md
[`cli`]: docs/cli.txt
[`stdlib`]: docs/stdlib.md
[`stdlib-ast`]: docs/stdlib-ast.md
[`examples` directory]: examples/
[Advent of Code]: https://adventofcode.com/
[Blog posts about Possum]: https://mulias.github.io/tags/possum/

## `~~~(##)'>` Regarding Possums

It's a well known fact that your computer is full of little guys who run around and make all the things you want happen. These little guys come in all shapes and sizes and are good at doing many different things. In this case the little guy making your program work is a possum. They rustle through your text files and forage for the bits of data you want to keep and store those in their pouch. Once they've carefully looked behind every stone and under each newline they arrange everything they've collected as nicely formatted JSON. What a helpful little guy!
