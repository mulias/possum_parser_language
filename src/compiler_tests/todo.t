  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '_A = 1 ; "" $ [_A]' -i ''
  
  =================@main==================
  "" $ [_A]
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: [_]
  0009    | GetConstant 2: 1
  0011    | InsertAtIndex 0
  0013    | End
  ========================================

  $ possum -p '"" $ ([1,2] + [3, 4])' -i '1111'
  
  =================@main==================
  "" $ ([1,2] + [3, 4])
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 12
  0007    | GetConstant 1: [1, 2]
  0009    | GetConstant 2: [3, 4]
  0011    | Merge
  0012    | End
  ========================================

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
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 9
  0007    | GetBoundLocal 0
  0009    | End
  ========================================
  
  Program Error: Expected value but got parser
  
  program:1:22-25:
  1 \xe2\x96\x8f foo(A) = "" $ A ; foo("a") (esc)
    \xe2\x96\x8f                       ^^^ (esc)
  
  [InvalidAst]
  [1]
