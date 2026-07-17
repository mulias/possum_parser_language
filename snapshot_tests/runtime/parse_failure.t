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

Multi-line input shows a context window with the caret on the failure line,
and every grammar site that failed at the farthest position is listed:

  $ printf '{\n  "count": 12,\n  "value": tru,\n  "next": null\n}' > config.json
  $ possum -p 'input(json)' config.json
  
  Parse Failure at input 3:11
  
  config.json:3:11:
  
  1 \xe2\x96\x8f { (esc)
  2 \xe2\x96\x8f   "count": 12, (esc)
  3 \xe2\x96\x8f   "value": tru, (esc)
    \xe2\x96\x8f            ^ (esc)
  4 \xe2\x96\x8f   "next": null (esc)
  5 \xe2\x96\x8f } (esc)
  
  expected one of:
    " " (parser `space`, stdlib/string.possum:40:2)
    "\t" (parser `space`, stdlib/string.possum:40:8)
    "\u0000A0" (parser `space`, stdlib/string.possum:40:15)
    "\u002000".."\u00200A" (parser `space`, stdlib/string.possum:40:28)
    "\u00202F" (parser `space`, stdlib/string.possum:40:53)
    "\u00205F" (parser `space`, stdlib/string.possum:40:66)
    "\u003000" (parser `space`, stdlib/string.possum:40:79)
    "\r\n" (parser `newline`, stdlib/string.possum:44:10)
    "\u00000D" (parser `newline`, stdlib/string.possum:44:31)
    "\u000085" (parser `newline`, stdlib/string.possum:44:44)
    "\u002028" (parser `newline`, stdlib/string.possum:44:57)
    "\u002029" (parser `newline`, stdlib/string.possum:44:70)
    t (parser `true`, stdlib/const.possum:1:10)
    f (parser `false`, stdlib/const.possum:3:11)
    n (parser `null`, stdlib/const.possum:9:10)
    p (parser `maybe`, stdlib/combinator.possum:16:11)
    "9" (parser `_number_integer_part`, stdlib/number.possum:53:29)
    "9" (parser `numeral`, stdlib/string.possum:19:15)
    "%(0 + N)" (parser `as_number`, stdlib/combinator.possum:36:20)
    '"' (parser `string`, stdlib/json.possum:20:9)
    "[" (parser `array`, stdlib/json.possum:56:14)
    "{" (parser `object`, stdlib/json.possum:59:2)
    V (parser `pair_sep`, stdlib/object.possum:19:54)
  [ParserFailure]
  [1]

Pattern mismatch reports the rejected value and the pattern; input failures
tied at the same position join the expected set:

  $ possum -p 'int -> 0..255' -i '300'
  
  Parse Failure: value 300 did not match pattern 0..255
  
  input:1:3:
  
  1 \xe2\x96\x8f 300 (esc)
    \xe2\x96\x8f    ^ (esc)
  
  expected one of:
    "9" (parser `numeral`, stdlib/string.possum:19:15)
    0..255 (parser `@main`, program:1:7)
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

Ties at the farthest position collect the expected set in attempt order:

  $ possum -p '"aa" | "ab"' -i 'ax'
  
  Parse Failure at input 1:0
  
  input:1:0:
  
  1 \xe2\x96\x8f ax (esc)
    \xe2\x96\x8f ^ (esc)
  
  expected one of:
    "aa" (parser `@main`, program:1:0)
    "ab" (parser `@main`, program:1:7)
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

A site that fails repeatedly at the farthest position appears in the
expected set once:

  $ possum -p 'w(p) = "aa" > p ; w("x") | w("y") | "ab"' -i 'ax'
  
  Parse Failure at input 1:0
  
  input:1:0:
  
  1 \xe2\x96\x8f ax (esc)
    \xe2\x96\x8f ^ (esc)
  
  expected one of:
    "aa" (parser `w`, program:1:7)
    "ab" (parser `@main`, program:1:36)
  [ParserFailure]
  [1]

The expected set is capped; overflow is marked rather than silently dropped:

  $ possum -p '"a00" | "a01" | "a02" | "a03" | "a04" | "a05" | "a06" | "a07" | "a08" | "a09" | "a10" | "a11" | "a12" | "a13" | "a14" | "a15" | "a16" | "a17" | "a18" | "a19" | "a20" | "a21" | "a22" | "a23" | "a24" | "a25" | "a26" | "a27" | "a28" | "a29" | "a30" | "a31" | "a32"' -i 'z'
  
  Parse Failure at input 1:0
  
  input:1:0:
  
  1 \xe2\x96\x8f z (esc)
    \xe2\x96\x8f ^ (esc)
  
  expected one of:
    "a00" (parser `@main`, program:1:0)
    "a01" (parser `@main`, program:1:8)
    "a02" (parser `@main`, program:1:16)
    "a03" (parser `@main`, program:1:24)
    "a04" (parser `@main`, program:1:32)
    "a05" (parser `@main`, program:1:40)
    "a06" (parser `@main`, program:1:48)
    "a07" (parser `@main`, program:1:56)
    "a08" (parser `@main`, program:1:64)
    "a09" (parser `@main`, program:1:72)
    "a10" (parser `@main`, program:1:80)
    "a11" (parser `@main`, program:1:88)
    "a12" (parser `@main`, program:1:96)
    "a13" (parser `@main`, program:1:104)
    "a14" (parser `@main`, program:1:112)
    "a15" (parser `@main`, program:1:120)
    "a16" (parser `@main`, program:1:128)
    "a17" (parser `@main`, program:1:136)
    "a18" (parser `@main`, program:1:144)
    "a19" (parser `@main`, program:1:152)
    "a20" (parser `@main`, program:1:160)
    "a21" (parser `@main`, program:1:168)
    "a22" (parser `@main`, program:1:176)
    "a23" (parser `@main`, program:1:184)
    "a24" (parser `@main`, program:1:192)
    "a25" (parser `@main`, program:1:200)
    "a26" (parser `@main`, program:1:208)
    "a27" (parser `@main`, program:1:216)
    "a28" (parser `@main`, program:1:224)
    "a29" (parser `@main`, program:1:232)
    "a30" (parser `@main`, program:1:240)
    "a31" (parser `@main`, program:1:248)
    \xe2\x80\xa6 and others (esc)
  [ParserFailure]
  [1]

Upper-bounded integer range at end of input (previously an out-of-bounds read):

  $ possum -p '..5' -i ''
  
  Parse Failure: expected ..5
  
  input:1:0:
  
  1 \xe2\x96\x8f (esc)
    \xe2\x96\x8f^ (esc)
  
  while matching parser `@main`
  
  program:1:0-3:
  
  1 \xe2\x96\x8f ..5 (esc)
    \xe2\x96\x8f ^^^ (esc)
  
  [ParserFailure]
  [1]
