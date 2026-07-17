  $ export PRINT_AST=true RUN_VM=false

An unqualified dump of a file module. The file paths in these tests do
not exist, so each import fails to resolve after printing its AST.

  $ possum -p '!"json.possum"' -i ''
  (Import 1:0-14 "json.possum")
  
  Program Error: cannot find module 'json.possum'
  
  program:1:0-14:
  1 \xe2\x96\x8f !"json.possum" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

  $ possum -p "!'json.possum'" -i ''
  (Import 1:0-14 "json.possum")
  
  Program Error: cannot find module 'json.possum'
  
  program:1:0-14:
  1 \xe2\x96\x8f !'json.possum' (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

  $ possum -p '!`json.possum`' -i ''
  (Import 1:0-14 "json.possum")
  
  Program Error: cannot find module 'json.possum'
  
  program:1:0-14:
  1 \xe2\x96\x8f !`json.possum` (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

An alias declaration.

  $ possum -p 'json = !"json.possum"' -i ''
  (DeclareGlobal 1:0-21
    (Identifier 1:0-4 json)
    (Import 1:7-21 "json.possum"))
  
  Program Error: cannot find module 'json.possum'
  
  program:1:0-21:
  1 \xe2\x96\x8f json = !"json.possum" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

An alias declaration with a member selector.

  $ possum -p 'sep = !"array.possum".array_sep' -i ''
  (DeclareGlobal 1:0-31
    (Identifier 1:0-3 sep)
    (Import 1:6-31 "array.possum" .array_sep))
  
  Program Error: cannot find module 'array.possum'
  
  program:1:0-31:
  1 \xe2\x96\x8f sep = !"array.possum".array_sep (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

An inline expression referencing one member.

  $ possum -p '!"json.possum".bool' -i ''
  (Import 1:0-19 "json.possum" .bool)
  
  Program Error: cannot find module 'json.possum'
  
  program:1:0-19:
  1 \xe2\x96\x8f !"json.possum".bool (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

A dotted member selector.

  $ possum -p '!"f.possum".a.b' -i ''
  (Import 1:0-15 "f.possum" .a.b)
  
  Program Error: cannot find module 'f.possum'
  
  program:1:0-15:
  1 \xe2\x96\x8f !"f.possum".a.b (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

A member expression called with arguments.

  $ possum -p '!"array.possum".array_sep(int, ",")' -i ''
  (Function 1:0-35
    (Import 1:0-25 "array.possum" .array_sep) [
      (Identifier 1:26-29 int)
      (String 1:31-34 ",")
    ])
  
  Program Error: cannot find module 'array.possum'
  
  program:1:0-25:
  1 \xe2\x96\x8f !"array.possum".array_sep(int, ",") (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

Bare stdlib paths.

  $ possum -p '!stdlib' -i ''
  (Import 1:0-7 stdlib)

  $ possum -p '!stdlib/json' -i ''
  (Import 1:0-12 stdlib/json)

  $ possum -p '!stdlib/json.string' -i ''
  (Import 1:0-19 stdlib/json .string)

  $ possum -p 'json = !stdlib/json' -i ''
  (DeclareGlobal 1:0-19
    (Identifier 1:0-4 json)
    (Import 1:7-19 stdlib/json))

An uppercase member selects a value.

  $ possum -p 'Num = !"number.possum".Number' -i ''
  (DeclareGlobal 1:0-29
    (Identifier 1:0-3 Num)
    (Import 1:6-29 "number.possum" .Number))
  
  Program Error: cannot find module 'number.possum'
  
  program:1:0-29:
  1 \xe2\x96\x8f Num = !"number.possum".Number (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

Whitespace ends the import, so a detached selector is a syntax error.

  $ possum -p '!"f.possum" .bool' -i ''
  
  Syntax Error: expected newline or semicolon between statements, found '.'
  
  program:1:12-13:
  1 \xe2\x96\x8f !"f.possum" .bool (esc)
    \xe2\x96\x8f             ^ (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '! "f.possum"' -i ''
  
  Syntax Error: expected import path immediately after '!', found '"'
  
  program:1:2-3:
  1 \xe2\x96\x8f ! "f.possum" (esc)
    \xe2\x96\x8f   ^ (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '!"f.possum". bool' -i ''
  
  Syntax Error: expected a member name after '.', found 'bool'
  
  program:1:13-17:
  1 \xe2\x96\x8f !"f.possum". bool (esc)
    \xe2\x96\x8f              ^^^^ (esc)
  
  [UnexpectedInput]
  [1]

The path must be a literal: templates mean a computed path.

  $ possum -p '!"a%("b")c"' -i ''
  
  Syntax Error: import path cannot contain a template, found '"a%("b")c"'
  
  program:1:1-11:
  1 \xe2\x96\x8f !"a%("b")c" (esc)
    \xe2\x96\x8f  ^^^^^^^^^^ (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '!""' -i ''
  
  Syntax Error: import path cannot be empty, found '""'
  
  program:1:1-3:
  1 \xe2\x96\x8f !"" (esc)
    \xe2\x96\x8f  ^^ (esc)
  
  [UnexpectedInput]
  [1]

Only 'stdlib' can follow '!' without quotes.

  $ possum -p '!foo' -i ''
  
  Syntax Error: expected a string or stdlib path after '!', found 'foo'
  
  program:1:1-4:
  1 \xe2\x96\x8f !foo (esc)
    \xe2\x96\x8f  ^^^ (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '!stdlib/json/foo.bar/baz' -i ''
  
  Syntax Error: expected '/' between path segments, found 'foo.bar'
  
  program:1:13-20:
  1 \xe2\x96\x8f !stdlib/json/foo.bar/baz (esc)
    \xe2\x96\x8f              ^^^^^^^ (esc)
  
  [UnexpectedInput]
  [1]

'_!' scans as one token and imports like '!'.

  $ possum -p '_!"json.possum"' -i ''
  (Import 1:0-15 "json.possum")
  
  Program Error: cannot find module 'json.possum'
  
  program:1:0-15:
  1 \xe2\x96\x8f _!"json.possum" (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^ (esc)
  
  [UnknownModule]
  [1]

  $ possum -p '_!stdlib' -i ''
  (Import 1:0-8 stdlib)

A trailing dot is not a member name.

  $ possum -p '!"f.possum".' -i ''
  
  Syntax Error: expected a member name after '.', found end of program
  
  program:1:12:
  1 \xe2\x96\x8f !"f.possum". (esc)
    \xe2\x96\x8f             ^ (esc)
  
  [UnexpectedInput]
  [1]
