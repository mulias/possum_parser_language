  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ==================fib===================
  fib(N) =
    const(N -> ..1) ? const(N) :
    fib(N - $1) -> N1 & fib(N - $2) -> N2 $
    (N1 + N2)
  ========================================
  0000    | PushVar2 N1
  0003    | PushVar2 N2
  0006    | SetInputMark
  0007    | GetConstant 0: const
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ..1
  0013    | CallFunction 1
  0015    | ConditionalThen 15 -> 27
  0018    | GetConstant 0: const
  0020    | GetBoundLocalMove 0
  0022    | CallTailFunction 1
  0024    | Jump 24 -> 68
  0027    | GetConstant 1: fib
  0029    | GetBoundLocal 0
  0031    | JumpIfFailure 31 -> 36
  0034    | PushNumberNegOne
  0035    | Merge
  0036    | CallFunction 1
  0038    | Destructure 1: N1
  0040    | TakeRight 40 -> 68
  0043    | GetConstant 1: fib
  0045    | GetBoundLocalMove 0
  0047    | JumpIfFailure 47 -> 53
  0050    | PushNegNumber -2
  0052    | Merge
  0053    | CallFunction 1
  0055    | Destructure 2: N2
  0057    | TakeRight 57 -> 68
  0060    | GetBoundLocalMove 1
  0062    | JumpIfFailure 62 -> 68
  0065    | GetBoundLocalMove 2
  0067    | Merge
  0068    | End
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
  0008    | GetConstant 2: Fib
  0010    | GetBoundLocal 0
  0012    | JumpIfFailure 12 -> 17
  0015    | PushNumberNegOne
  0016    | Merge
  0017    | CallFunction 1
  0019    | JumpIfFailure 19 -> 35
  0022    | GetConstant 2: Fib
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
  0000    | PushVar2 N
  0003    | PushNumberZero
  0004    | ParseLowerBoundedRange
  0005    | Destructure 4: N
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 1: fib
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | Destructure 5: Fib(N)
  0018    | End
  ========================================
