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
