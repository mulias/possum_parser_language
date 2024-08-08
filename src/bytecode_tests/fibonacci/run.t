  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ==================fib===================
  0000    4 GetConstant 0: N1
  0002    | GetConstant 1: N2
  0004    2 SetInputMark
  0005    | GetConstant 2: const
  0007    | GetBoundLocal 0
  0009    | CallFunction 1
  0011    | GetConstant 3: 0
  0013    | Destructure
  0014    | ConditionalThen 14 -> 26
  0017    | GetConstant 4: const
  0019    | GetConstant 5: 0
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 88
  0026    3 SetInputMark
  0027    | GetConstant 6: const
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | GetConstant 7: 1
  0035    | Destructure
  0036    | ConditionalThen 36 -> 48
  0039    | GetConstant 8: const
  0041    | GetConstant 9: 1
  0043    | CallTailFunction 1
  0045    | ConditionalElse 45 -> 88
  0048    4 GetConstant 10: fib
  0050    | GetBoundLocal 0
  0052    | GetConstant 11: 1
  0054    | NegateNumber
  0055    | Merge
  0056    | CallFunction 1
  0058    | GetLocal 1
  0060    | Destructure
  0061    | TakeRight 61 -> 88
  0064    | GetConstant 12: fib
  0066    | GetBoundLocal 0
  0068    | GetConstant 13: 2
  0070    | NegateNumber
  0071    | Merge
  0072    | CallFunction 1
  0074    | GetLocal 2
  0076    | Destructure
  0077    | TakeRight 77 -> 88
  0080    5 GetBoundLocal 1
  0082    | JumpIfFailure 82 -> 88
  0085    | GetBoundLocal 2
  0087    | Merge
  0088    2 End
  ========================================
  
  ==================Fib===================
  0000    8 SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: 0
  0005    | Destructure
  0006    | ConditionalThen 6 -> 14
  0009    | GetConstant 1: 0
  0011    | ConditionalElse 11 -> 52
  0014    9 SetInputMark
  0015    | GetBoundLocal 0
  0017    | GetConstant 2: 1
  0019    | Destructure
  0020    | ConditionalThen 20 -> 28
  0023    | GetConstant 3: 1
  0025    | ConditionalElse 25 -> 52
  0028   10 GetConstant 4: Fib
  0030    | GetBoundLocal 0
  0032    | GetConstant 5: 1
  0034    | NegateNumber
  0035    | Merge
  0036    | CallFunction 1
  0038    | JumpIfFailure 38 -> 52
  0041    | GetConstant 6: Fib
  0043    | GetBoundLocal 0
  0045    | GetConstant 7: 2
  0047    | NegateNumber
  0048    | Merge
  0049    | CallFunction 1
  0051    | Merge
  0052    8 End
  ========================================
  
  =================@main==================
  0000   12 GetConstant 0: N
  0002    | GetConstant 1: integer
  0004    | CallFunction 0
  0006    | GetLocal 0
  0008    | Destructure
  0009    | TakeRight 9 -> 25
  0012    | GetConstant 2: fib
  0014    | GetBoundLocal 0
  0016    | CallFunction 1
  0018    | GetConstant 3: Fib
  0020    | GetBoundLocal 0
  0022    | CallFunction 1
  0024    | Destructure
  0025   13 End
  ========================================
