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

A local definition shadows a dumped name.

  $ possum -p '!"util.possum" ; vowel = "z" ; vowel' -i 'z'
  "z"

Among unqualified dumps, the later import wins.

  $ cat > one.possum <<'EOF'
  > letter = "a"
  > EOF
  $ cat > two.possum <<'EOF'
  > letter = "b"
  > EOF

  $ possum -p '!"one.possum" ; !"two.possum" ; letter' -i 'b'
  "b"

  $ possum -p '!"two.possum" ; !"one.possum" ; letter' -i 'a'
  "a"

A barrel module re-exports its imports: dumped names bind bare, alias
namespaces nest.

  $ cat > digits.possum <<'EOF'
  > zero = "0"
  > EOF
  $ cat > barrel.possum <<'EOF'
  > !"one.possum"
  > digits = !"digits.possum"
  > EOF

  $ possum -p '!"barrel.possum" ; letter + digits.zero' -i 'a0'
  "a0"

  $ possum -p 'bar = !"barrel.possum" ; bar.letter + bar.digits.zero' -i 'a0'
  "a0"

Root binding chains through re-exports: an alias member that is itself
an alias reaches the target module's main parser and exports.

  $ cat > word.possum <<'EOF'
  > bang = "!"
  > "w" > bang
  > EOF
  $ cat > middle.possum <<'EOF'
  > w = !"word.possum"
  > EOF

  $ possum -p 'm = !"middle.possum" ; m.w' -i 'w!'
  "!"

  $ possum -p 'm = !"middle.possum" ; m.w.bang' -i '!'
  "!"

Mutual namespace aliases are fine when the definitions ground out.

  $ cat > m1.possum <<'EOF'
  > m2 = !"m2.possum"
  > aa = "a"
  > EOF
  $ cat > m2.possum <<'EOF'
  > m1 = !"m1.possum"
  > bb = "b"
  > EOF

  $ possum -p 'x = !"m1.possum" ; x.m2.m1.aa + x.m2.bb' -i 'ab'
  "ab"

The expression form works in patterns as a pattern function call.

  $ cat > pairlib.possum <<'EOF'
  > Pair(A, B) = [A, B]
  > EOF

  $ possum -p 'array_sep(int, ",") -> !"pairlib.possum".Pair(1, 2) $ "ok"' -i '1,2'
  "ok"

A stdlib submodule imports individually: a dump binds its exports bare,
an alias namespaces the same cached module.

  $ possum --no-stdlib -p '!stdlib/json ; string' -i '"hi"'
  "hi"

  $ possum -p 'j = !stdlib/json ; j.string' -i '"hi"'
  "hi"

'_!' imports without re-exporting: the dump is usable in its own module,
but a module dumping the importer cannot reach through it, bare or via
an alias member.

  $ cat > priv.possum <<'EOF2'
  > _!"util.possum"
  > loud = vowel + "!"
  > EOF2

  $ possum -p '!"priv.possum" ; loud' -i 'a!'
  "a!"

  $ possum -p '!"priv.possum" ; vowel' -i 'a'
  
  Program Error: undefined variable 'vowel'
  
  program:1:17-22:
  1 \xe2\x96\x8f !"priv.possum" ; vowel (esc)
    \xe2\x96\x8f                  ^^^^^ (esc)
  
  [UndefinedVariable]
  [1]

  $ possum -p 'p = !"priv.possum" ; p.vowel' -i 'a'
  
  Program Error: 'p.vowel' is not exported by the module imported as 'p'
  
  program:1:21-28:
  1 \xe2\x96\x8f p = !"priv.possum" ; p.vowel (esc)
    \xe2\x96\x8f                      ^^^^^^^ (esc)
  
  [ImportResolution]
  [1]

The implicit stdlib dump is private: stdlib is usable in every module
but not reachable through another module's namespace or re-exports.

  $ possum -p 'u = !"util.possum" ; u.int' -i '5'
  
  Program Error: 'u.int' is not exported by the module imported as 'u'
  
  program:1:21-26:
  1 \xe2\x96\x8f u = !"util.possum" ; u.int (esc)
    \xe2\x96\x8f                      ^^^^^ (esc)
  
  [ImportResolution]
  [1]

The stdlib modules' own private imports do not leak: json privately
imports the string module.

  $ possum -p 'j = !stdlib/json ; j.alpha' -i 'x'
  
  Program Error: 'j.alpha' is not exported by the module imported as 'j'
  
  program:1:19-26:
  1 \xe2\x96\x8f j = !stdlib/json ; j.alpha (esc)
    \xe2\x96\x8f                    ^^^^^^^ (esc)
  
  [ImportResolution]
  [1]

'--no-stdlib' with an explicit private dump still binds locally.

  $ possum --no-stdlib -p '_!stdlib ; int' -i '5'
  5
