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
  0009    | Destructure 0: ..1
  0011    | CallFunction 1
  0013    | ConditionalThen 13 -> 25
  0016    | GetConstant 3: const
  0018    | GetBoundLocal 0
  0020    | CallTailFunction 1
  0022    | ConditionalElse 22 -> 69
  0025    | GetConstant 4: fib
  0027    | GetBoundLocal 0
  0029    | JumpIfFailure 29 -> 36
  0032    | GetConstant 5: 1
  0034    | NegateNumber
  0035    | Merge
  0036    | CallFunction 1
  0038    | Destructure 1: N1
  0040    | TakeRight 40 -> 69
  0043    | GetConstant 6: fib
  0045    | GetBoundLocal 0
  0047    | JumpIfFailure 47 -> 54
  0050    | GetConstant 7: 2
  0052    | NegateNumber
  0053    | Merge
  0054    | CallFunction 1
  0056    | Destructure 2: N2
  0058    | TakeRight 58 -> 69
  0061    | GetBoundLocal 1
  0063    | JumpIfFailure 63 -> 69
  0066    | GetBoundLocal 2
  0068    | Merge
  0069    | End
  ========================================
  
  ==================Fib===================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 0: ..1
  0005    | Or 5 -> 38
  0008    | GetConstant 0: Fib
  0010    | GetBoundLocal 0
  0012    | JumpIfFailure 12 -> 19
  0015    | GetConstant 1: 1
  0017    | NegateNumber
  0018    | Merge
  0019    | CallFunction 1
  0021    | JumpIfFailure 21 -> 38
  0024    | GetConstant 2: Fib
  0026    | GetBoundLocal 0
  0028    | JumpIfFailure 28 -> 35
  0031    | GetConstant 3: 2
  0033    | NegateNumber
  0034    | Merge
  0035    | CallFunction 1
  0037    | Merge
  0038    | End
  ========================================
  
  =================@main==================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | GetConstant 0: N
  0002    | ParseLowerBoundedRange 1: 0
  0004    | Destructure 0: N
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 2: fib
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | Destructure 1: Fib(N)
  0017    | End
  ========================================
