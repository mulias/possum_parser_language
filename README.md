# Possum Parser Language

Possum is a domain specific language for parsing arbitrary text into JSON. A
Possum program describes both the expected input format and the desired output
format of data by composing simple parser functions to create larger and more
complex parsers. Possum is inspired by a number of languages and tools
including [Awk], Haskell's [Parsec] library, [Definite Clause Grammars] in
Prolog, [jq], [Parser Expression Grammars], and [Rosie Pattern Language].

The reference implementation for Possum is Opossum, which is written in OCaml.

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
  point = pair_sep(int, ",")
  line = P1 <- point & " -> " & P2 <- point $ {"from": P1, "to": P2}
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

### Parse Git Short Logs

```
  $ git log --oneline --no-decorate -5
  5faeac6 Merge pull request #12 from mulias/em/v0.3.0
  e06db43 v0.3.0
  343a99a Merge pull request #11 from mulias/em/backtrack
  ffed1bb Add backtrack combinator
  e16be7a Fix github action configurations for macOS


  $ git log --oneline --no-decorate -5 | possum -p 'array_sep(commit,nl);commit=label("sha",word)+skip(ws)+label("title",line)' -
  [
    {
      "sha": "5faeac6",
      "title": "Merge pull request #12 from mulias/em/v0.3.0"
    },
    { "sha": "e06db43", "title": "v0.3.0" },
    {
      "sha": "343a99a",
      "title": "Merge pull request #11 from mulias/em/backtrack"
    },
    { "sha": "ffed1bb", "title": "Add backtrack combinator" },
    { "sha": "e16be7a", "title": "Fix github action configurations for macOS" }
  ]
```

### Parse an abstract syntax tree

```
  $ cat fibonacci.rkt
  (define (fib n)
    (cond ((= n 1) 0)
          ((= n 2) 1)
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

  node(Type, p) = Value <- p $ {"type": Type, "value": Value}


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
    1 <- N ? 0 :
    2 <- N ? 1 :
    Fib(N - 1) + Fib(N - 2)

  N <- int $ "Fibonacci of %(N) is %(Fib(N))"


  $ possum fibonacci.possum --input=10
  "Fibonacci of 10 is 55"
  55
```

## Installation

Precompiled binaries are available from the [Github releases page].

To build Opossum from source you'll have to install opam, make a switch for the
project, and then run dune to build the executable. This can be done using the
provided Nix config, if you're in to that kind of thing.

```
  $ cd opossum
  $ nix-shell shell.nix --run "opam switch create ."
  $ nix-shell shell.nix --run "dune build ./bin/possum.exe"
  $ cp ./_build/default/bin/possum.exe ~/my_bin_path/possum
```

[github releases page]: https://github.com/mulias/possum_parser_language/releases

## Documentation

Possum's documentation is bundled with the executable, and can be accessed
from the command line with `possum --docs=[overview | advanced | language | cli
| stdlib`.

- [`overview`]: Example-based guide covering Possum's main features.
- [`advanced`]: Continuation of the example-based guide, focusing on more
    specialized and situational functionality.
- [`language`]: Condensed reference for the core language.
- [`cli`]: Using Possum from the command line.
- [`stdlib`]: Possum standard library reference.

[`overview`]: docs/overview.md
[`advanced`]: docs/advanced.md
[`language`]: docs/language.md
[`cli`]: docs/cli.md
[`stdlib`]: docs/stdlib.md

## Examples

The [expect tests directory] covers a wide range of parsing use cases, including
[Advent of Code] [puzzle inputs], [tabular data], a [mostly useless JSON parser], and a
[parser for encoding Possum's own abstract syntax tree] as JSON. Each `*.t` file
is a [Cram test] which shows example Possum invocations and the expected JSON
output.

[expect tests directory]: opossum/test/expect/
[advent of code]: https://adventofcode.com/
[puzzle inputs]: opossum/test/expect/advent_2021_day_04.t/
[tabular data]: opossum/test/expect/tabular_data.t/
[mostly useless JSON parser]: opossum/test/expect/json.t/
[parser for encoding possum's own abstract syntax tree]: opossum/test/expect/possum_ast.t/
[cram test]: https://bitheap.org/cram/

## `~~~(##)'>` Regarding Possums

It's a well known fact that your computer is full of little guys who run around
and make all the things you want happen. These little guys come in all shapes
and sizes and are good at doing many different things. In this case the little
guy making your program work is a possum. They rustle through your text files
and forage for the bits of data you want to keep and store those in their pouch.
Once they've carefully looked behind every stone and under each newline they
arrange everything they've collected as nicely formatted JSON. What a helpful
little guy!
