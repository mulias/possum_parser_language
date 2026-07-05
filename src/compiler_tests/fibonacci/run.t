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
  0018    | GetBoundLocalMove 0
  0020    | CallTailFunction 1
  0022    | Jump 22 -> 66
  0025    | GetConstant 3: fib
  0027    | GetBoundLocal 0
  0029    | JumpIfFailure 29 -> 34
  0032    | PushNumberNegOne
  0033    | Merge
  0034    | CallFunction 1
  0036    | Destructure 1: N1
  0038    | TakeRight 38 -> 66
  0041    | GetConstant 3: fib
  0043    | GetBoundLocalMove 0
  0045    | JumpIfFailure 45 -> 51
  0048    | PushNegNumber -2
  0050    | Merge
  0051    | CallFunction 1
  0053    | Destructure 2: N2
  0055    | TakeRight 55 -> 66
  0058    | GetBoundLocalMove 1
  0060    | JumpIfFailure 60 -> 66
  0063    | GetBoundLocalMove 2
  0065    | Merge
  0066    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  ==================Fib===================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 3: ..1
  0005    | Or 5 -> 35
  0008    | GetConstant 4: Fib
  0010    | GetBoundLocal 0
  0012    | JumpIfFailure 12 -> 17
  0015    | PushNumberNegOne
  0016    | Merge
  0017    | CallFunction 1
  0019    | JumpIfFailure 19 -> 35
  0022    | GetConstant 4: Fib
  0024    | GetBoundLocalMove 0
  0026    | JumpIfFailure 26 -> 32
  0029    | PushNegNumber -2
  0031    | Merge
  0032    | CallFunction 1
  0034    | Merge
  0035    | End
  ========================================
  
  =================@main==================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | PushCharVar N
  0002    | PushNumberZero
  0003    | ParseLowerBoundedRange
  0004    | Destructure 4: N
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 3: fib
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | Destructure 5: Fib(N)
  0017    | End
  ========================================
