  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'foo(p) = p(1, 2, 3, 4, 5) ; bar(a, B) = a $ B ; foo(bar)' -i ''
  
  ==================foo===================
  foo(p) = p(1, 2, 3, 4, 5)
  ========================================
  0000    | GetBoundLocalMove 0
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
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocalMove 1
  0007    | End
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
  
  ==================foo===================
  foo(p) = p($1, 2, 3, $4, 5)
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | AssertFunctionArity 5
  0004    | AssertParamTypes 00001001
  0006    | PushInteger 1
  0008    | PushNumberStringTwo
  0009    | PushNumberStringThree
  0010    | PushInteger 4
  0012    | GetConstant 0: 5
  0014    | CallTailFunction 5
  0016    | End
  ========================================
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocalMove 1
  0007    | End
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
  
  ==================foo===================
  foo(p) = p(1, $2)
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | AssertFunctionArity 2
  0004    | AssertParamTypes 00000010
  0006    | PushNumberStringOne
  0007    | PushInteger 2
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocalMove 1
  0007    | End
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
  
  ==================foo===================
  foo(p) = p($1, 2, 3, $4, 5, 6, 7, 8, [], 10, $"a", 12, 13, 14, 15, $true, 17)
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | AssertFunctionArity 17
  0004    | AssertParamTypes4 00000000000000001000010100001001
  0009    | PushInteger 1
  0011    | PushNumberStringTwo
  0012    | PushNumberStringThree
  0013    | PushInteger 4
  0015    | GetConstant 0: 5
  0017    | GetConstant 1: 6
  0019    | GetConstant 2: 7
  0021    | GetConstant 3: 8
  0023    | PushEmptyArray
  0024    | GetConstant 4: 10
  0026    | PushString "a"
  0028    | GetConstant 5: 12
  0030    | GetConstant 6: 13
  0032    | GetConstant 7: 14
  0034    | GetConstant 8: 15
  0036    | PushTrue
  0037    | GetConstant 9: 17
  0039    | CallTailFunction 17
  0041    | End
  ========================================
  
  ==================bar===================
  bar(a, B) = a $ B
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 7
  0005    | GetBoundLocalMove 1
  0007    | End
  ========================================
  
  =================@main==================
  foo(bar)
  ========================================
  0000    | GetConstant 10: foo
  0002    | GetConstant 11: bar
  0004    | CallTailFunction 1
  0006    | End
  ========================================
