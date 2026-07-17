A well-formed import of a file that does not exist fails module lookup.

  $ possum -p '!"json.possum"' -i ''
  
  Program Error: cannot find module 'json.possum'
  
  program:1:0-14:
  1 \xe2\x96\x8f !"json.possum" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

A selector-less import denotes a whole module, which is not an
expression; name the module first to use its root parser inline.

  $ possum -p '!"json.possum" > "x"' -i ''
  
  Validation Error: A module import is not an expression; bind it with 'name = !...' first
  
  program:1:0-14:
  1 \xe2\x96\x8f !"json.possum" > "x" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^ (esc)
  
  [InvalidImport]
  [1]

  $ possum -p 'foo = "a" & !"json.possum"' -i ''
  
  Validation Error: A module import is not an expression; bind it with 'name = !...' first
  
  program:1:12-26:
  1 \xe2\x96\x8f foo = "a" & !"json.possum" (esc)
    \xe2\x96\x8f             ^^^^^^^^^^^^^^ (esc)
  
  [InvalidImport]
  [1]

  $ possum -p '"" $ !"json.possum"' -i ''
  
  Validation Error: A module import is not an expression; bind it with 'Name = !...' first
  
  program:1:5-19:
  1 \xe2\x96\x8f "" $ !"json.possum" (esc)
    \xe2\x96\x8f      ^^^^^^^^^^^^^^ (esc)
  
  [InvalidImport]
  [1]

The kind of an inline member must match its context.

  $ possum -p '!"num.possum".Add' -i ''
  
  Validation Error: Value member 'Add' is not valid in parser context
  
  program:1:0-17:
  1 \xe2\x96\x8f !"num.possum".Add (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^ (esc)
  
  [InvalidImport]
  [1]

  $ possum -p '"" $ !"num.possum".add' -i ''
  
  Validation Error: Parser member 'add' is not valid in value context
  
  program:1:5-22:
  1 \xe2\x96\x8f "" $ !"num.possum".add (esc)
    \xe2\x96\x8f      ^^^^^^^^^^^^^^^^^ (esc)
  
  [InvalidImport]
  [1]

A repeated alias is a duplicate declaration.

  $ possum -p 'j = !"a.possum" ; j = !"b.possum" ; j' -i ''
  
  Validation Error: 'j' is already declared in this module
  
  program:1:18-19:
  1 \xe2\x96\x8f j = !"a.possum" ; j = !"b.possum" ; j (esc)
    \xe2\x96\x8f                   ^ (esc)
  
  [DuplicateDeclaration]
  [1]

An alias name collides with a declaration like any other name.

  $ possum -p 'j = "x" ; j = !"a.possum" ; j' -i ''
  
  Validation Error: 'j' is already declared in this module
  
  program:1:10-11:
  1 \xe2\x96\x8f j = "x" ; j = !"a.possum" ; j (esc)
    \xe2\x96\x8f           ^ (esc)
  
  [DuplicateDeclaration]
  [1]

A missing file reached through other imports reports the chain that led
there, nearest importer first.

  $ mkdir -p nested
  $ cat > nested/mid.possum <<'MID'
  > !"missing.possum"
  > MID
  $ cat > outer.possum <<'OUTER'
  > !"nested/mid.possum"
  > OUTER

  $ possum -p '!"outer.possum" ; "x"' -i 'x'
  
  Program Error: cannot find module 'missing.possum'
  
  nested/mid.possum:1:0-17:
  1 \xe2\x96\x8f !"missing.possum" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^ (esc)
  2 \xe2\x96\x8f (esc)
  
  imported from outer.possum:1:0-20:
  1 \xe2\x96\x8f !"nested/mid.possum" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^ (esc)
  2 \xe2\x96\x8f (esc)
  
  imported from program:1:0-15:
  1 \xe2\x96\x8f !"outer.possum" ; "x" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

The case of an alias must match the kind of the member it binds.

  $ cat > kinds.possum <<'KINDS'
  > add = "+"
  > Add = 1
  > KINDS

  $ possum -p 'num = !"kinds.possum".Add ; num' -i ''
  
  Program Error: alias 'num' does not match the kind of 'Add': a lowercase alias imports parsers, an uppercase alias imports values
  
  program:1:0-25:
  1 \xe2\x96\x8f num = !"kinds.possum".Add ; num (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  
  Program Error: 'num' does not match the kind of alias 'num': a lowercase alias imports parsers, an uppercase alias imports values
  
  program:1:28-31:
  1 \xe2\x96\x8f num = !"kinds.possum".Add ; num (esc)
    \xe2\x96\x8f                             ^^^ (esc)
  
  [ImportResolution]
  [1]

  $ possum -p 'Num = !"kinds.possum".add ; "x" $ Num' -i ''
  
  Program Error: alias 'Num' does not match the kind of 'add': a lowercase alias imports parsers, an uppercase alias imports values
  
  program:1:0-25:
  1 \xe2\x96\x8f Num = !"kinds.possum".add ; "x" $ Num (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  
  Program Error: 'Num' does not match the kind of alias 'Num': a lowercase alias imports parsers, an uppercase alias imports values
  
  program:1:34-37:
  1 \xe2\x96\x8f Num = !"kinds.possum".add ; "x" $ Num (esc)
    \xe2\x96\x8f                                   ^^^ (esc)
  
  [ImportResolution]
  [1]

Private members are not importable: not through a dump, not through an
alias namespace. (The inline selector form also rejects them; its
message is recorded in todo.t.)

  $ cat > priv.possum <<'PRIV'
  > _secret = "s"
  > open = "o"
  > PRIV

  $ possum -p '!"priv.possum" ; _secret' -i 's'
  
  Program Error: undefined variable '_secret'
  
  program:1:17-24:
  1 \xe2\x96\x8f !"priv.possum" ; _secret (esc)
    \xe2\x96\x8f                  ^^^^^^^ (esc)
  
  [UndefinedVariable]
  [1]

  $ possum -p 'p = !"priv.possum" ; p._secret' -i 's'
  
  Program Error: 'p._secret' is private to the module imported as 'p'
  
  program:1:21-30:
  1 \xe2\x96\x8f p = !"priv.possum" ; p._secret (esc)
    \xe2\x96\x8f                      ^^^^^^^^^ (esc)
  
  [ImportResolution]
  [1]

An uppercase alias on a module with no values binds an empty namespace;
using a member reports against the alias.

  $ possum -p 'Num = !"priv.possum" ; "x" $ Num.Missing' -i 'x'
  
  Program Error: 'Num.Missing' is not exported by the module imported as 'Num'
  
  program:1:29-40:
  1 \xe2\x96\x8f Num = !"priv.possum" ; "x" $ Num.Missing (esc)
    \xe2\x96\x8f                              ^^^^^^^^^^^ (esc)
  
  [ImportResolution]
  [1]

An unqualified dump discards the imported main parser, so a program
that is only a dump has no main parser.

  $ cat > mainy.possum <<'MAINY'
  > x = "x"
  > "<" > x
  > MAINY

  $ possum -p '!"mainy.possum"' -i '<x>'
  [NoMainParser]
  [1]

A definition cycle across modules cannot resolve.

  $ cat > cyc_a.possum <<'CYCA'
  > foo = !"cyc_b.possum".foo
  > CYCA
  $ cat > cyc_b.possum <<'CYCB'
  > foo = !"cyc_a.possum".foo
  > CYCB

  $ possum -p 'foo = !"cyc_a.possum".foo ; foo' -i ''
  
  Program Error: 'foo' is not exported by the module imported as 'foo'
  
  program:1:28-31:
  1 \xe2\x96\x8f foo = !"cyc_a.possum".foo ; foo (esc)
    \xe2\x96\x8f                             ^^^ (esc)
  
  [ImportResolution]
  [1]
