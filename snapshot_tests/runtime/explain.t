The --explain flag appends a parse trace to the failure report. Tail-called
parsers are rebuilt into one logical chain even though the VM never held
their frames:

  $ possum --explain -p 'a = "" > b ; b = "" > c ; c = "" > "x" ; a' -i 'y'
  
  Parse Failure: expected "x"
  
  input:1:0:
  
  1 \xe2\x96\x8f y (esc)
    \xe2\x96\x8f ^ (esc)
  
  while matching parser `c`
  
  program:1:35-38:
  
  1 \xe2\x96\x8f a = "" > b ; b = "" > c ; c = "" > "x" ; a (esc)
    \xe2\x96\x8f                                    ^^^ (esc)
  
  
  Parse trace (pruned to attempts reaching 1:0):
  
  @main \xc2\xbb a \xc2\xbb b \xc2\xbb c  \xe2\x9c\x97 at 1:0 (esc)
  [ParserFailure]
  [1]

A trace through the stdlib json parser prunes to the attempts that reached
the failure position; parsers that fell short collapse to one line and
successful subtrees collapse unless the decisive failure backtracked away
inside them:

  $ possum --explain -p 'json' -i '[1, x]'
  
  Parse Failure at input 1:4
  
  input:1:4:
  
  1 \xe2\x96\x8f [1, x] (esc)
    \xe2\x96\x8f     ^ (esc)
  
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
    Elem (parser `tuple1`, stdlib/array.possum:15:24)
  
  Parse trace (pruned to attempts reaching 1:4):
  
  @main  \xe2\x9c\x97 at 1:4 (esc)
  \xe2\x94\x94\xe2\x94\x80 @main \xc2\xbb value \xc2\xbb object  \xe2\x9c\x97 at 1:4 (esc)
     \xe2\x94\x9c\xe2\x94\x80 boolean \xc2\xbb boolean \xc2\xbb false  \xe2\x9c\x97 reached 1:0 (esc)
     \xe2\x94\x9c\xe2\x94\x80 null \xc2\xbb null  \xe2\x9c\x97 reached 1:0 (esc)
     \xe2\x94\x9c\xe2\x94\x80 number \xc2\xbb as_number  \xe2\x9c\x97 reached 1:0 (esc)
     \xe2\x94\x9c\xe2\x94\x80 string  \xe2\x9c\x97 reached 1:0 (esc)
     \xe2\x94\x94\xe2\x94\x80 array  \xe2\x9c\x97 at 1:4 (esc)
        \xe2\x94\x94\xe2\x94\x80 maybe_array_sep \xc2\xbb default  \xe2\x9c\x93 consumed 1:1..1:2 (esc)
           \xe2\x94\x94\xe2\x94\x80 @fn3 \xc2\xbb array_sep  \xe2\x9c\x93 consumed 1:1..1:2 (esc)
              \xe2\x94\x9c\xe2\x94\x80 tuple1  \xe2\x9c\x93 consumed 1:1..1:2 (esc)
              \xe2\x94\x94\xe2\x94\x80 tuple1  \xe2\x9c\x97 at 1:4 (esc)
                 \xe2\x94\x94\xe2\x94\x80 @fn0  \xe2\x9c\x97 at 1:4 (esc)
                    \xe2\x94\x94\xe2\x94\x80 @fn2 \xc2\xbb surround  \xe2\x9c\x97 at 1:4 (esc)
                       \xe2\x94\x9c\xe2\x94\x80 @fn3 \xc2\xbb maybe  \xe2\x9c\x93 consumed 1:3..1:4 (esc)
                       \xe2\x94\x82  \xe2\x94\x94\xe2\x94\x80 whitespace \xc2\xbb many  \xe2\x9c\x93 consumed 1:3..1:4 (esc)
                       \xe2\x94\x82     \xe2\x94\x9c\xe2\x94\x80 @fn3  \xe2\x9c\x93 consumed 1:3..1:4 (esc)
                       \xe2\x94\x82     \xe2\x94\x94\xe2\x94\x80 @fn3 \xc2\xbb newline  \xe2\x9c\x97 at 1:4 (esc)
                       \xe2\x94\x82        \xe2\x94\x94\xe2\x94\x80 space  \xe2\x9c\x97 at 1:4 (esc)
                       \xe2\x94\x94\xe2\x94\x80 value \xc2\xbb object  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x9c\xe2\x94\x80 boolean \xc2\xbb boolean \xc2\xbb false  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x82  \xe2\x94\x94\xe2\x94\x80 true  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x9c\xe2\x94\x80 null \xc2\xbb null  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x9c\xe2\x94\x80 number \xc2\xbb as_number  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x82  \xe2\x94\x94\xe2\x94\x80 @fn5  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x82     \xe2\x94\x9c\xe2\x94\x80 maybe \xc2\xbb succeed \xc2\xbb const  \xe2\x9c\x93 consumed 1:4..1:4 (esc)
                          \xe2\x94\x82     \xe2\x94\x94\xe2\x94\x80 _number_integer_part \xc2\xbb numeral  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x9c\xe2\x94\x80 string  \xe2\x9c\x97 at 1:4 (esc)
                          \xe2\x94\x94\xe2\x94\x80 array  \xe2\x9c\x97 at 1:4 (esc)
  
  pruned: 2 successful subtrees, 2 failed attempts falling short of 1:4
  [ParserFailure]
  [1]

A repeated local in a pattern shows the bind, then the failed equality
check:

  $ possum --explain -p 'json -> [A, A]' -i '[1, 2]'
  
  Parse Failure: value [1, 2] did not match pattern [A, A]
  
  input:1:6:
  
  1 \xe2\x96\x8f [1, 2] (esc)
    \xe2\x96\x8f       ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-14:
  
  1 \xe2\x96\x8f json -> [A, A] (esc)
    \xe2\x96\x8f         ^^^^^^ (esc)
  
  
  Parse trace (pruned to attempts reaching 1:6):
  
  @main  \xe2\x9c\x97 at 1:6 (esc)
  \xe2\x94\x9c\xe2\x94\x80 @main \xc2\xbb value  \xe2\x9c\x93 consumed 1:0..1:6 (esc)
  \xe2\x94\x94\xe2\x94\x80 destructure at program:1:8  \xe2\x9c\x97 [1, 2] did not match [A, A] (esc)
     \xe2\x94\x9c\xe2\x94\x80 1 vs A  \xe2\x9c\x93  A bound to 1 (esc)
     \xe2\x94\x94\xe2\x94\x80 2 vs A  \xe2\x9c\x97 (esc)
  
  pruned: 1 successful subtrees, 0 failed attempts falling short of 1:6
  [ParserFailure]
  [1]

A nested object pattern failure shows the failing key path:

  $ possum --explain -p 'json -> {"user": {"age": 0..150}}' -i '{"user": {"age": 200}}'
  
  Parse Failure: value {"user": {"age": 200}} did not match pattern {"user": {"age": 0..150}}
  
  input:1:22:
  
  1 \xe2\x96\x8f {"user": {"age": 200}} (esc)
    \xe2\x96\x8f                       ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-33:
  
  1 \xe2\x96\x8f json -> {"user": {"age": 0..150}} (esc)
    \xe2\x96\x8f         ^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  
  Parse trace (pruned to attempts reaching 1:22):
  
  @main  \xe2\x9c\x97 at 1:22 (esc)
  \xe2\x94\x9c\xe2\x94\x80 @main \xc2\xbb value \xc2\xbb object  \xe2\x9c\x93 consumed 1:0..1:22 (esc)
  \xe2\x94\x94\xe2\x94\x80 destructure at program:1:8  \xe2\x9c\x97 {"user": {"age": 200}} did not match {"user": {"age": 0..150}} (esc)
     \xe2\x94\x94\xe2\x94\x80 {"age": 200} vs {"age": 0..150}  \xe2\x9c\x97 (esc)
        \xe2\x94\x94\xe2\x94\x80 200 vs 0..150  \xe2\x9c\x97 (esc)
  
  pruned: 1 successful subtrees, 0 failed attempts falling short of 1:22
  [ParserFailure]
  [1]

A merge pattern mismatch reports the whole value against the whole pattern:

  $ possum --explain -p 'word -> ("a" + Rest)' -i 'bcd'
  
  Parse Failure: value "bcd" did not match pattern ("a" + Rest)
  
  input:1:3:
  
  1 \xe2\x96\x8f bcd (esc)
    \xe2\x96\x8f    ^ (esc)
  
  expected one of:
    "z" (parser `alpha`, stdlib/string.possum:7:13)
    "Z" (parser `alpha`, stdlib/string.possum:7:24)
    "9" (parser `numeral`, stdlib/string.possum:19:15)
    p (parser `many`, stdlib/combinator.possum:4:10)
    ("a" + Rest) (parser `@main`, program:1:8)
  
  Parse trace (pruned to attempts reaching 1:3):
  
  @main  \xe2\x9c\x97 at 1:3 (esc)
  \xe2\x94\x9c\xe2\x94\x80 word \xc2\xbb many  \xe2\x9c\x93 consumed 1:0..1:3 (esc)
  \xe2\x94\x82  \xe2\x94\x9c\xe2\x94\x80 @fn1  \xe2\x9c\x93 consumed 1:0..1:1 (esc)
  \xe2\x94\x82  \xe2\x94\x9c\xe2\x94\x80 @fn1  \xe2\x9c\x93 consumed 1:1..1:2 (esc)
  \xe2\x94\x82  \xe2\x94\x9c\xe2\x94\x80 @fn1  \xe2\x9c\x93 consumed 1:2..1:3 (esc)
  \xe2\x94\x82  \xe2\x94\x94\xe2\x94\x80 @fn1  \xe2\x9c\x97 at 1:3 (esc)
  \xe2\x94\x82     \xe2\x94\x94\xe2\x94\x80 alnum \xc2\xbb numeral  \xe2\x9c\x97 at 1:3 (esc)
  \xe2\x94\x82        \xe2\x94\x94\xe2\x94\x80 alpha  \xe2\x9c\x97 at 1:3 (esc)
  \xe2\x94\x94\xe2\x94\x80 destructure at program:1:8  \xe2\x9c\x97 "bcd" did not match ("a" + Rest) (esc)
  
  pruned: 3 successful subtrees, 0 failed attempts falling short of 1:3
  [ParserFailure]
  [1]

Explain output is only printed when the parse fails:

  $ possum --explain -p '"a"' -i 'a'
  "a"
