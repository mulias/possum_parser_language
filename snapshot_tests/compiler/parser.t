  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'p = 1 ; -p' -i '-1'
  
  Validation Error: Negation is only valid on a number in parser context
  
  program:1:9-10:
  1 \xe2\x96\x8f p = 1 ; -p (esc)
    \xe2\x96\x8f          ^ (esc)
  
  [InvalidAst]
  [1]

  $ possum -p 'p = 1 ; -p..' -i '-4'
  
  Validation Error: Negation is only valid on a number in parser context
  
  program:1:9-10:
  1 \xe2\x96\x8f p = 1 ; -p.. (esc)
    \xe2\x96\x8f          ^ (esc)
  
  [InvalidAst]
  [1]

  $ possum -p 'f ; f = "a" + (f | "")' -i 'aa'
  
  ==================2:f===================
  f = "a" + (f | "")
  ========================================
  0000    | ParseChar 'a'
  0002    | JumpIfFailure 2 -> 13
  0005    | SetInputMark
  0006    | CallFunctionConstant 0: f
  0008    | Or 8 -> 12
  0011    | PushEmptyString
  0012    | Merge
  0013    | End
  ========================================
  
  ================2:@main=================
  f
  ========================================
  0000    | CallTailFunctionConstant 0: f
  0002    | End
  ========================================

