  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ==================fib===================
  fib(N) =
    const(N -> ..1) ? const(N) :
    fib(N - $1) -> N1 & fib(N - $2) -> N2 $
    (N1 + N2)
  ========================================
  0000    | GetConstant 0: N1
  0002    | GetConstant 1: N2
  0004    | SetInputMark
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
  0025    | ConditionalElse 25 -> 74
  0028    | GetConstant 6: fib
  0030    | GetBoundLocal 0
  0032    | JumpIfFailure 32 -> 39
  0035    | GetConstant 7: 1
  0037    | NegateNumber
  0038    | Merge
  0039    | CallFunction 1
  0041    | GetLocal 1
  0043    | Destructure
  0044    | TakeRight 44 -> 74
  0047    | GetConstant 8: fib
  0049    | GetBoundLocal 0
  0051    | JumpIfFailure 51 -> 58
  0054    | GetConstant 9: 2
  0056    | NegateNumber
  0057    | Merge
  0058    | CallFunction 1
  0060    | GetLocal 2
  0062    | Destructure
  0063    | TakeRight 63 -> 74
  0066    | GetBoundLocal 1
  0068    | JumpIfFailure 68 -> 74
  0071    | GetBoundLocal 2
  0073    | Merge
  0074    | End
  ========================================
  
  ==================Fib===================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: _
  0005    | GetConstant 1: 1
  0007    | DestructureRange
  0008    | Or 8 -> 41
  0011    | GetConstant 2: Fib
  0013    | GetBoundLocal 0
  0015    | JumpIfFailure 15 -> 22
  0018    | GetConstant 3: 1
  0020    | NegateNumber
  0021    | Merge
  0022    | CallFunction 1
  0024    | JumpIfFailure 24 -> 41
  0027    | GetConstant 4: Fib
  0029    | GetBoundLocal 0
  0031    | JumpIfFailure 31 -> 38
  0034    | GetConstant 5: 2
  0036    | NegateNumber
  0037    | Merge
  0038    | CallFunction 1
  0040    | Merge
  0041    | End
  ========================================
  
  =================@main==================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | GetConstant 0: N
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
  0023    | End
  ========================================
