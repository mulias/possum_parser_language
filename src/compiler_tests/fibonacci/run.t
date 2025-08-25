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
  0022    | Jump 22 -> 60
  0025    | GetConstant 4: fib
  0027    | GetBoundLocal 0
  0029    | GetConstant 5: 1
  0031    | NegateNumber
  0032    | Merge
  0033    | CallFunction 1
  0035    | Destructure 1: N1
  0037    | TakeRight 37 -> 60
  0040    | GetConstant 6: fib
  0042    | GetBoundLocal 0
  0044    | GetConstant 7: 2
  0046    | NegateNumber
  0047    | Merge
  0048    | CallFunction 1
  0050    | Destructure 2: N2
  0052    | TakeRight 52 -> 60
  0055    | GetBoundLocal 1
  0057    | GetBoundLocal 2
  0059    | Merge
  0060    | End
  ========================================
  
  ==================Fib===================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 0: ..1
  0005    | Or 5 -> 29
  0008    | GetConstant 0: Fib
  0010    | GetBoundLocal 0
  0012    | GetConstant 1: 1
  0014    | NegateNumber
  0015    | Merge
  0016    | CallFunction 1
  0018    | GetConstant 2: Fib
  0020    | GetBoundLocal 0
  0022    | GetConstant 3: 2
  0024    | NegateNumber
  0025    | Merge
  0026    | CallFunction 1
  0028    | Merge
  0029    | End
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
