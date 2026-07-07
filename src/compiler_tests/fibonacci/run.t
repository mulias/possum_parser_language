  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ================1:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================2:fib==================
  fib(N) =
    const(N -> ..1) ? const(N) :
    fib(N - $1) -> N1 & fib(N - $2) -> N2 $
    (N1 + N2)
  ========================================
  0000    | PushVar N1
  0002    | PushVar N2
  0004    | SetInputMark
  0005    | GetConstant 0: const
  0007    | GetBoundLocal 0
  0009    | Destructure 0: ..1
  0011    | CallFunction 1
  0013    | ConditionalThen 13 -> 25
  0016    | GetConstant 0: const
  0018    | GetBoundLocalMove 0
  0020    | CallTailFunction 1
  0022    | Jump 22 -> 67
  0025    | GetConstant 1: fib
  0027    | GetBoundLocal 0
  0029    | JumpIfFailure 29 -> 35
  0032    | PushNegInteger -1
  0034    | Merge
  0035    | CallFunction 1
  0037    | DestructurePlan 0: bind N1
  0039    | TakeRight 39 -> 67
  0042    | GetConstant 1: fib
  0044    | GetBoundLocalMove 0
  0046    | JumpIfFailure 46 -> 52
  0049    | PushNegInteger -2
  0051    | Merge
  0052    | CallFunction 1
  0054    | DestructurePlan 1: bind N2
  0056    | TakeRight 56 -> 67
  0059    | GetBoundLocalMove 1
  0061    | JumpIfFailure 61 -> 67
  0064    | GetBoundLocalMove 2
  0066    | Merge
  0067    | End
  ========================================
  
  =================2:Fib==================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 1: ..1
  0005    | Or 5 -> 36
  0008    | GetConstant 2: Fib
  0010    | GetBoundLocal 0
  0012    | JumpIfFailure 12 -> 18
  0015    | PushNegInteger -1
  0017    | Merge
  0018    | CallFunction 1
  0020    | JumpIfFailure 20 -> 36
  0023    | GetConstant 2: Fib
  0025    | GetBoundLocalMove 0
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -2
  0032    | Merge
  0033    | CallFunction 1
  0035    | Merge
  0036    | End
  ========================================
  
  ================2:@main=================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | PushVar N
  0002    | PushInteger 0
  0004    | ParseLowerBoundedRange
  0005    | DestructurePlan 2: bind N
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 1: fib
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | Destructure 2: Fib(N)
  0018    | End
  ========================================
