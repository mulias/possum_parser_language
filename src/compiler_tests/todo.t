  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '1..(..90)' -i '1111'
  
  Program Error: Range bound must be an integer or codepoint
  
  program:1:3-9:
  1 \xe2\x96\x8f 1..(..90) (esc)
    \xe2\x96\x8f    ^^^^^^ (esc)
  
  [InvalidAst]
  [1]

  $ possum -p 'foo(A) = "" $ A ; foo("a")' -i ''
  
  ==================foo===================
  foo(A) = "" $ A
  ========================================
  0000    | PushEmptyString
  0001    | CallFunction 0
  0003    | TakeRight 3 -> 8
  0006    | GetBoundLocal 0
  0008    | End
  ========================================
  
  Program Error: Expected value but got parser
  
  program:1:22-25:
  1 \xe2\x96\x8f foo(A) = "" $ A ; foo("a") (esc)
    \xe2\x96\x8f                       ^^^ (esc)
  
  [InvalidAst]
  [1]
