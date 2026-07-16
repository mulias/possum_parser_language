Imports load modules from disk. An unqualified dump binds the named
exports bare; the module's main parser is dropped.

  $ cat > util.possum <<'EOF'
  > vowel = "a" | "e" | "i" | "o" | "u"
  > Ten = 10
  > "<" > vowel < ">"
  > EOF

  $ possum -p '!"util.possum" ; vowel' -i 'e'
  "e"

An alias binds the module as a namespace, with the module's main parser
at the root.

  $ possum -p 'u = !"util.possum" ; u.vowel + u.vowel' -i 'ae'
  "ae"

  $ possum -p 'u = !"util.possum" ; u' -i '<i>'
  "i"

An uppercase alias imports the module's values.

  $ possum -p 'V = !"util.possum" ; "x" $ V.Ten' -i 'x'
  10

An inline expression references one export without binding a name.

  $ possum -p '!"util.possum".vowel + "!"' -i 'u!'
  "u!"

A file parser's relative imports resolve against its own directory, not
the working directory.

  $ mkdir lib
  $ cat > lib/word.possum <<'EOF'
  > bee = "b"
  > combo = !"inner.possum".inner + bee
  > EOF
  $ cat > lib/inner.possum <<'EOF'
  > inner = "i"
  > EOF
  $ cat > main.possum <<'EOF'
  > !"lib/word.possum"
  > combo + combo
  > EOF

  $ possum main.possum -i 'ibib'
  "ibib"

Import cycles are allowed when the definitions ground out.

  $ cat > ping.possum <<'EOF'
  > ping = "p" | !"pong.possum".pong
  > EOF
  $ cat > pong.possum <<'EOF'
  > pong = "q" | !"ping.possum".ping
  > EOF

  $ possum -p '!"ping.possum".ping' -i 'q'
  "q"

Two spellings of the same path compile the module once and may be
aliased twice.

  $ possum -p 'a = !"util.possum" ; b = !"./util.possum" ; a.vowel + b.vowel' -i 'oi'
  "oi"

'!stdlib' makes the standard library reachable when the automatic
inclusion is disabled.

  $ possum --no-stdlib -p 'int' -i '5'
  
  Program Error: undefined variable 'int'
  
  program:1:0-3:
  1 \xe2\x96\x8f int (esc)
    \xe2\x96\x8f ^^^ (esc)
  
  [UndefinedVariable]
  [1]

  $ possum --no-stdlib -p '!stdlib ; int' -i '5'
  5

'!stdlib' is a cache hit when the standard library is already included.

  $ possum -p '!stdlib ; int' -i '5'
  5
