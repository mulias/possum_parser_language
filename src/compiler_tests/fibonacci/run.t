  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ==================Fib===================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 0: ..1
  0005    | Or 5 -> 26
  0008    | GetConstant 0: Fib
  0010    | GetBoundLocal 0
  0012    | PushNumberNegOne
  0013    | Merge
  0014    | CallFunction 1
  0016    | GetConstant 0: Fib
  0018    | GetBoundLocal 0
  0020    | PushNegNumber -2
  0022    | Merge
  0023    | CallFunction 1
  0025    | Merge
  0026    | End
  ========================================
  
  ==================fib===================
  fib(N) =
    const(N -> ..1) ? const(N) :
    fib(N - $1) -> N1 & fib(N - $2) -> N2 $
    (N1 + N2)
  ========================================
  0000    | GetConstant 1: N1
  0002    | GetConstant 2: N2
  0004    | SetInputMark
  0005    | GetConstant 3: const
  0007    | GetBoundLocal 0
  0009    | Destructure 1: ..1
  0011    | CallFunction 1
  0013    | ConditionalThen 13 -> 25
  0016    | GetConstant 3: const
  0018    | GetBoundLocal 0
  0020    | CallTailFunction 1
  0022    | Jump 22 -> 57
  0025    | GetConstant 4: fib
  0027    | GetBoundLocal 0
  0029    | PushNumberNegOne
  0030    | Merge
  0031    | CallFunction 1
  0033    | Destructure 2: N1
  0035    | TakeRight 35 -> 57
  0038    | GetConstant 4: fib
  0040    | GetBoundLocal 0
  0042    | PushNegNumber -2
  0044    | Merge
  0045    | CallFunction 1
  0047    | Destructure 3: N2
  0049    | TakeRight 49 -> 57
  0052    | GetBoundLocal 1
  0054    | GetBoundLocal 2
  0056    | Merge
  0057    | End
  ========================================
  
  =================@main==================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | PushCharVar N
  0002    | PushNumberZero
  0003    | ParseLowerBoundedRange
  0004    | Destructure 4: N
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 4: fib
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | Destructure 5: Fib(N)
  0017    | End
  ========================================
