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
  0005    | Or 5 -> 27
  0008    | GetConstant 0: Fib
  0010    | GetBoundLocal 0
  0012    | GetConstant 1: -1
  0014    | Merge
  0015    | CallFunction 1
  0017    | GetConstant 2: Fib
  0019    | GetBoundLocal 0
  0021    | GetConstant 3: -2
  0023    | Merge
  0024    | CallFunction 1
  0026    | Merge
  0027    | End
  ========================================
  
  =================@main==================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | GetConstant 0: N
  0002    | GetConstant 1: 0
  0004    | ParseLowerBoundedRange
  0005    | Destructure 0: N
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 2: fib
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | Destructure 1: Fib(N)
  0018    | End
  ========================================
