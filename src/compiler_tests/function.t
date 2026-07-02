  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'foo(p) = p(1, 2, 3, 4, 5) ; bar(a, B) = a $ B ; foo(bar)' -i ''
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocal 1
  0007    | End
  ========================================
  
  ==================foo===================
  foo(p) = p(1, 2, 3, 4, 5)
  ========================================
  0000    | GetBoundLocal 0
  0002    | AssertFunctionArity 5
  0004    | AssertParamTypes 00000000
  0006    | PushNumberStringOne
  0007    | PushNumberStringTwo
  0008    | PushNumberStringThree
  0009    | GetConstant 0: 4
  0011    | GetConstant 1: 5
  0013    | CallTailFunction 5
  0015    | End
  ========================================
  
  =================@main==================
  foo(bar)
  ========================================
  0000    | GetConstant 2: foo
  0002    | GetConstant 3: bar
  0004    | CallTailFunction 1
  0006    | End
  ========================================

  $ possum -p 'foo(p) = p($1, 2, 3, $4, 5) ; bar(a, B) = a $ B ; foo(bar)' -i ''
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocal 1
  0007    | End
  ========================================
  
  ==================foo===================
  foo(p) = p($1, 2, 3, $4, 5)
  ========================================
  0000    | GetBoundLocal 0
  0002    | AssertFunctionArity 5
  0004    | AssertParamTypes 00001001
  0006    | PushNumberOne
  0007    | PushNumberStringTwo
  0008    | PushNumberStringThree
  0009    | PushNumber 4
  0011    | GetConstant 0: 5
  0013    | CallTailFunction 5
  0015    | End
  ========================================
  
  =================@main==================
  foo(bar)
  ========================================
  0000    | GetConstant 1: foo
  0002    | GetConstant 2: bar
  0004    | CallTailFunction 1
  0006    | End
  ========================================


  $ possum -p 'foo(p) = p(1, $2) ; bar(a, B) = a $ B ; foo(bar)' -i ''
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocal 1
  0007    | End
  ========================================
  
  ==================foo===================
  foo(p) = p(1, $2)
  ========================================
  0000    | GetBoundLocal 0
  0002    | AssertFunctionArity 2
  0004    | AssertParamTypes 00000010
  0006    | PushNumberStringOne
  0007    | PushNumberTwo
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =================@main==================
  foo(bar)
  ========================================
  0000    | GetConstant 0: foo
  0002    | GetConstant 1: bar
  0004    | CallTailFunction 1
  0006    | End
  ========================================

  $ possum -p 'foo(p) = p($1, 2, 3, $4, 5, 6, 7, 8, [], 10, $"a", 12, 13, 14, 15, $true, 17) ; bar(a, B) = a $ B ; foo(bar)' -i ''
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocal 1
  0007    | End
  ========================================
  
  ==================foo===================
  foo(p) = p($1, 2, 3, $4, 5, 6, 7, 8, [], 10, $"a", 12, 13, 14, 15, $true, 17)
  ========================================
  0000    | GetBoundLocal 0
  0002    | AssertFunctionArity 17
  0004    | AssertParamTypes4 00000000000000001000010100001001
  0009    | PushNumberOne
  0010    | PushNumberStringTwo
  0011    | PushNumberStringThree
  0012    | PushNumber 4
  0014    | GetConstant 0: 5
  0016    | GetConstant 1: 6
  0018    | GetConstant 2: 7
  0020    | GetConstant 3: 8
  0022    | PushEmptyArray
  0023    | GetConstant 4: 10
  0025    | PushChar 'a'
  0027    | GetConstant 5: 12
  0029    | GetConstant 6: 13
  0031    | GetConstant 7: 14
  0033    | GetConstant 8: 15
  0035    | PushTrue
  0036    | GetConstant 9: 17
  0038    | CallTailFunction 17
  0040    | End
  ========================================
  
  =================@main==================
  foo(bar)
  ========================================
  0000    | GetConstant 10: foo
  0002    | GetConstant 11: bar
  0004    | CallTailFunction 1
  0006    | End
  ========================================
