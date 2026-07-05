  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'p = 1 ; -p' -i '-1'
  
  =================@main==================
  -p
  ========================================
  0000    | PushNumberStringOne
  0001    | NegateParser
  0002    | CallTailFunction 0
  0004    | End
  ========================================

  $ possum -p 'p = 1 ; -p..' -i '-4'
  
  =================@main==================
  -p..
  ========================================
  0000    | PushNumberStringOne
  0001    | NegateParser
  0002    | ParseLowerBoundedRange
  0003    | End
  ========================================

  $ possum -p 'f ; f = "a" + (f | "")' -i 'aa'
  
  ===================f====================
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
  
  =================@main==================
  f
  ========================================
  0000    | CallTailFunctionConstant 0: f
  0002    | End
  ========================================

