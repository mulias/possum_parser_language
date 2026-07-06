Single-line input, string literal mismatch:

  $ possum -p '"hello"' -i 'help'
  
  Parse Failure: expected "hello"
  
  input:1:0:
  
  1 \xe2\x96\x8f help (esc)
    \xe2\x96\x8f ^ (esc)
  
  while matching parser `@main`
  
  program:1:0-7:
  
  1 \xe2\x96\x8f "hello" (esc)
    \xe2\x96\x8f ^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

Char literal mismatch:

  $ possum -p "'a'" -i 'b'
  
  Parse Failure: expected 'a'
  
  input:1:0:
  
  1 \xe2\x96\x8f b (esc)
    \xe2\x96\x8f ^ (esc)
  
  while matching parser `@main`
  
  program:1:0-3:
  
  1 \xe2\x96\x8f 'a' (esc)
    \xe2\x96\x8f ^^^ (esc)
  
  [ParserFailure]
  [1]

Number literal mismatch:

  $ possum -p '123' -i '124'
  
  Parse Failure: expected 123
  
  input:1:0:
  
  1 \xe2\x96\x8f 124 (esc)
    \xe2\x96\x8f ^ (esc)
  
  while matching parser `@main`
  
  program:1:0-3:
  
  1 \xe2\x96\x8f 123 (esc)
    \xe2\x96\x8f ^^^ (esc)
  
  [ParserFailure]
  [1]

Multi-line input shows a context window with the caret on the failure line:

  $ printf '{\n  "count": 12,\n  "value": tru,\n  "next": null\n}' > config.json
  $ possum -p 'input(json)' config.json
  
  Parse Failure: expected " "
  
  config.json:3:11:
  
  1 \xe2\x96\x8f { (esc)
  2 \xe2\x96\x8f   "count": 12, (esc)
  3 \xe2\x96\x8f   "value": tru, (esc)
    \xe2\x96\x8f            ^ (esc)
  4 \xe2\x96\x8f   "next": null (esc)
  5 \xe2\x96\x8f } (esc)
  
  while matching parser `space`
  
  stdlib/core.possum:42:2-5:
  
  40 \xe2\x96\x8f (esc)
  41 \xe2\x96\x8f space = (esc)
  42 \xe2\x96\x8f   " " | "\\t" | "\\u0000A0" | "\\u002000".."\\u00200A" | "\\u00202F" | "\\u00205F" | "\\u003000" (esc)
     \xe2\x96\x8f   ^^^ (esc)
  43 \xe2\x96\x8f (esc)
  44 \xe2\x96\x8f spaces = many(space) (esc)
  
  [ParserFailure]
  [1]

Pattern mismatch reports the rejected value and the pattern:

  $ possum -p 'int -> 0..255' -i '300'
  
  Parse Failure: value 300 did not match pattern 0..255
  
  input:1:3:
  
  1 \xe2\x96\x8f 300 (esc)
    \xe2\x96\x8f    ^ (esc)
  
  while matching parser `@main`
  
  program:1:7-13:
  
  1 \xe2\x96\x8f int -> 0..255 (esc)
    \xe2\x96\x8f        ^^^^^^ (esc)
  
  [ParserFailure]
  [1]

A large rejected value is truncated:

  $ possum -p 'json -> [0]' -i '[11111, 22222, 33333, 44444, 55555, 66666, 77777, 88888, 99999, 10101, 20202, 30303]'
  
  Parse Failure: value [11111, 22222, 33333, 44444, 55555, 66666, 77777, 88888, 99999, \xe2\x80\xa6 did not match pattern [0] (esc)
  
  input:1:84:
  
  1 \xe2\x96\x8f [11111, 22222, 33333, 44444, 55555, 66666, 77777, 88888, 99999, 10101, 20202, 30303] (esc)
    \xe2\x96\x8f                                                                                     ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-11:
  
  1 \xe2\x96\x8f json -> [0] (esc)
    \xe2\x96\x8f         ^^^ (esc)
  
  [ParserFailure]
  [1]

Failure at offset 0:

  $ possum -p '"a"' -i 'b'
  
  Parse Failure: expected "a"
  
  input:1:0:
  
  1 \xe2\x96\x8f b (esc)
    \xe2\x96\x8f ^ (esc)
  
  while matching parser `@main`
  
  program:1:0-3:
  
  1 \xe2\x96\x8f "a" (esc)
    \xe2\x96\x8f ^^^ (esc)
  
  [ParserFailure]
  [1]

Failure at end of input:

  $ possum -p '"abc" & "def"' -i 'abc'
  
  Parse Failure: expected "def"
  
  input:1:3:
  
  1 \xe2\x96\x8f abc (esc)
    \xe2\x96\x8f    ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-13:
  
  1 \xe2\x96\x8f "abc" & "def" (esc)
    \xe2\x96\x8f         ^^^^^ (esc)
  
  [ParserFailure]
  [1]

Empty input:

  $ possum -p '"a"' -i ''
  
  Parse Failure: expected "a"
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:0-3:
  
  1 \xe2\x96\x8f "a" (esc)
    \xe2\x96\x8f ^^^ (esc)
  
  [ParserFailure]
  [1]

Tie at the farthest position keeps the first-recorded failure:

  $ possum -p '"aa" | "ab"' -i 'ax'
  
  Parse Failure: expected "aa"
  
  input:1:0:
  
  1 \xe2\x96\x8f ax (esc)
    \xe2\x96\x8f ^ (esc)
  
  while matching parser `@main`
  
  program:1:0-4:
  
  1 \xe2\x96\x8f "aa" | "ab" (esc)
    \xe2\x96\x8f ^^^^ (esc)
  
  [ParserFailure]
  [1]

Tail-called parsers report the innermost parser, not a stale caller:

  $ possum -p 'a = "" > b ; b = "" > c ; c = "" > "x" ; a' -i 'y'
  
  Parse Failure: expected "x"
  
  input:1:0:
  
  1 \xe2\x96\x8f y (esc)
    \xe2\x96\x8f ^ (esc)
  
  while matching parser `c`
  
  program:1:35-38:
  
  1 \xe2\x96\x8f a = "" > b ; b = "" > c ; c = "" > "x" ; a (esc)
    \xe2\x96\x8f                                    ^^^ (esc)
  
  [ParserFailure]
  [1]

Bare @fail:

  $ possum -p '"abc" > @fail' -i 'abc'
  
  Parse Failure: expected @fail
  
  input:1:3:
  
  1 \xe2\x96\x8f abc (esc)
    \xe2\x96\x8f    ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-13:
  
  1 \xe2\x96\x8f "abc" > @fail (esc)
    \xe2\x96\x8f         ^^^^^ (esc)
  
  [ParserFailure]
  [1]
