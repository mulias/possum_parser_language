# Possum Parser Language

Possum is a domain specific language for parsing arbitrary text into JSON. A
Possum program describes both the expected input format and the desired output
format of data by composing simple parser functions to create larger and more
complex parsers. Possum is primarily inspired by [Awk], Haskell's [Parsec]
library, [Definite Clause Grammars] in Prolog, [jq], and [Rosie Pattern
Language].

The reference implementation for Possum is Opossum, which is written in OCaml.

[Awk]: https://en.wikipedia.org/wiki/AWK
[Parsec]: https://hackage.haskell.org/package/parsec
[Definite Clause Grammars]: https://en.wikipedia.org/wiki/Definite_clause_grammar
[jq]: https://stedolan.github.io/jq/
[Rosie Pattern Language]: https://rosie-lang.org/

## A Simple example

You've got some lists of numbers and you want to do something to them. Why?
That's your business not mine. The lists are separated by new lines and within
each list the numbers are separated by commas:

```
31,88,35,24,46,48,95,42,18,43,71,32,92,62,97,63,50,2,60,58,74,66
15,87,57,34,14,3,54,93,75,22,45,10
56,12,83,30,8,76,1,78,82,39,98,37,19,26,81,64,55,41,16,4,72,5
52,80,84,67,21,86,23,91,0,68,36,13,44,20,69,40,90
96,27,77,38,49,94,47,9,65,28,59,79,6,29,61,53,11,17,73,99,25,89,51,7,33,85,70
```

If I were you and I wanted to use this data in a JavaScript program I might
write code like this:

```
input = readMyCoolNumbersTextFile()
numbers = input.split("\n").map(row => row.split(",").map(n => Number(n)))
```

It's not beautiful, but if it works then it works.

Here's a Possum program which produces the same structured data:

```
array_sep(array_sep(int, ","), nl)
```

This isn't much shorter than the JavaScript code, but it is more declarative --
instead of specifying the order of steps to transform the data, we describe the
shape of the data and let Possum do the rest.

We can use `possum` to run this parser from the command line and save the result:

```
  $ possum -p 'array_sep(array_sep(int, ","), nl)' my_cool_numbers.txt > my_cool_numbers.json

  $ cat my_cool_numbers.json
  [
    [
      31, 88, 35, 24, 46, 48, 95, 42, 18, 43, 71, 32, 92, 62, 97, 63, 50, 2,
      60, 58, 74, 66
    ],
    [ 15, 87, 57, 34, 14, 3, 54, 93, 75, 22, 45, 10 ],
    ...
  ]
```

Now using the data is just a matter of loading JSON:

```
input = readMyCoolNumbersJsonFile()
numbers = JSON.parse(input)
```

## Installation

For now you're going to have to use Nix to build a `possum` executable which can
be run on your personal home computer.

```
  $ cd opossum
  $ nix-shell shell.nix --run "dune build ./bin/possum.exe"
  $ cp ./_build/default/bin/possum.exe ~/my_bin_path/possum
```

## Documentation

- [Overview]: example-based guide of possum's main features
- [Documentation]: details for the core language and standard library
- [CLI]: using possum from the command line

[overview]: docs/overview.md
[documentation]: docs/language.md
[cli]: docs/cli.md

## Examples

The [expect tests directory] covers a wide range of parsing use cases, including
[Advent of Code] [puzzle inputs], [tabular data], a [mostly useless JSON parser], and a
[parser for encoding possum's own abstract syntax tree] as JSON. Each `*.t` file
is a [Cram test] which shows example possum invocations and the expected JSON
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
