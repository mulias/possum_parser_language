  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ==================fib===================
  0000    3 GetConstant 0: N1
  0002    | GetConstant 1: N2
  0004    2 SetInputMark
  0005    | GetConstant 2: const
  0007    | GetBoundLocal 0
  0009    | GetConstant 3: _
  0011    | GetConstant 4: 1
  0013    | DestructureRange
  0014    | CallFunction 1
  0016    | ConditionalThen 16 -> 28
  0019    | GetConstant 5: const
  0021    | GetBoundLocal 0
  0023    | CallTailFunction 1
  0025    | ConditionalElse 25 -> 68
  0028    3 GetConstant 6: fib
  0030    | GetBoundLocal 0
  0032    | GetConstant 7: 1
  0034    | NegateNumber
  0035    | Merge
  0036    | CallFunction 1
  0038    | GetLocal 1
  0040    | Destructure
  0041    | TakeRight 41 -> 68
  0044    | GetConstant 8: fib
  0046    | GetBoundLocal 0
  0048    | GetConstant 9: 2
  0050    | NegateNumber
  0051    | Merge
  0052    | CallFunction 1
  0054    | GetLocal 2
  0056    | Destructure
  0057    | TakeRight 57 -> 68
  0060    4 GetBoundLocal 1
  0062    | JumpIfFailure 62 -> 68
  0065    | GetBoundLocal 2
  0067    | Merge
  0068    2 End
  ========================================
  
  ==================Fib===================
  0000    6 SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: _
  0005    | GetConstant 1: 1
  0007    | DestructureRange
  0008    | Or 8 -> 35
  0011    | GetConstant 2: Fib
  0013    | GetBoundLocal 0
  0015    | GetConstant 3: 1
  0017    | NegateNumber
  0018    | Merge
  0019    | CallFunction 1
  0021    | JumpIfFailure 21 -> 35
  0024    | GetConstant 4: Fib
  0026    | GetBoundLocal 0
  0028    | GetConstant 5: 2
  0030    | NegateNumber
  0031    | Merge
  0032    | CallFunction 1
  0034    | Merge
  0035    | End
  ========================================
  
  =================@main==================
  0000    8 GetConstant 0: N
  0002    | ParseLowerBoundedRange 1: 0
  0004    | GetLocal 0
  0006    | Destructure
  0007    | TakeRight 7 -> 23
  0010    | GetConstant 2: fib
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | GetConstant 3: Fib
  0018    | GetBoundLocal 0
  0020    | CallFunction 1
  0022    | Destructure
  0023    9 End
  ========================================
