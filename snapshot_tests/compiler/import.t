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
