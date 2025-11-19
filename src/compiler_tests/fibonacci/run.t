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
  0016    | GetConstant 2: const
  0018    | GetBoundLocal 0
  0020    | CallTailFunction 1
  0022    | Jump 22 -> 58
  0025    | GetConstant 3: fib
  0027    | GetBoundLocal 0
  0029    | GetConstant 4: -1
  0031    | Merge
  0032    | CallFunction 1
  0034    | Destructure 1: N1
  0036    | TakeRight 36 -> 58
  0039    | GetConstant 3: fib
  0041    | GetBoundLocal 0
  0043    | GetConstant 5: -2
  0045    | Merge
  0046    | CallFunction 1
  0048    | Destructure 2: N2
  0050    | TakeRight 50 -> 58
  0053    | GetBoundLocal 1
  0055    | GetBoundLocal 2
  0057    | Merge
  0058    | End
  ========================================
  
  ==================Fib===================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 3: ..1
  0005    | Or 5 -> 27
  0008    | GetConstant 6: Fib
  0010    | GetBoundLocal 0
  0012    | GetConstant 4: -1
  0014    | Merge
  0015    | CallFunction 1
  0017    | GetConstant 6: Fib
  0019    | GetBoundLocal 0
  0021    | GetConstant 5: -2
  0023    | Merge
  0024    | CallFunction 1
  0026    | Merge
  0027    | End
  ========================================
  
  =================@main==================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | GetConstant 7: N
  0002    | GetConstant 8: 0
  0004    | ParseLowerBoundedRange
  0005    | Destructure 4: N
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 3: fib
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | Destructure 5: Fib(N)
  0018    | End
  ========================================
