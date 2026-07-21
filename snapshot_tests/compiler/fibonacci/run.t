  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | SetInputMark
  0007    | GetConstant 0: const
  0009    | GetLocal l0
  0011    | JumpIfFailure 11 -> 30
  0014    | MatchScrutinee r3
  0016    | MatchInRange r3 ..1 -> 29
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | CallFunction 1
  0032    | ConditionalThen 32 -> 44
  0035    | GetConstant 0: const
  0037    | GetLocalMove l0
  0039    | CallTailFunction 1
  0041    | Jump 41 -> 98
  0044    | GetConstant 2: fib
  0046    | GetLocal l0
  0048    | JumpIfFailure 48 -> 54
  0051    | PushNegInteger -1
  0053    | Merge
  0054    | CallFunction 1
  0056    | JumpIfFailure 56 -> 64
  0059    | MatchScrutinee r3
  0061    | MatchBind l1 r3
  0064    | TakeRight 64 -> 98
  0067    | GetConstant 2: fib
  0069    | GetLocalMove l0
  0071    | JumpIfFailure 71 -> 77
  0074    | PushNegInteger -2
  0076    | Merge
  0077    | CallFunction 1
  0079    | JumpIfFailure 79 -> 87
  0082    | MatchScrutinee r3
  0084    | MatchBind l2 r3
  0087    | TakeRight 87 -> 98
  0090    | GetLocalMove l1
  0092    | JumpIfFailure 92 -> 98
  0095    | GetLocalMove l2
  0097    | Merge
  0098    | End
  ========================================
  
  =================2:Fib==================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r1
  0010    | MatchInRange r1 ..1 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | Or 24 -> 55
  0027    | GetConstant 3: Fib
  0029    | GetLocal l0
  0031    | JumpIfFailure 31 -> 37
  0034    | PushNegInteger -1
  0036    | Merge
  0037    | CallFunction 1
  0039    | JumpIfFailure 39 -> 55
  0042    | GetConstant 3: Fib
  0044    | GetLocalMove l0
  0046    | JumpIfFailure 46 -> 52
  0049    | PushNegInteger -2
  0051    | Merge
  0052    | CallFunction 1
  0054    | Merge
  0055    | End
  ========================================
  
  ================2:@main=================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushInteger 0
  0006    | ParseLowerBoundedRange
  0007    | JumpIfFailure 7 -> 15
  0010    | MatchScrutinee r1
  0012    | MatchBind l0 r1
  0015    | TakeRight 15 -> 44
  0018    | GetConstant 2: fib
  0020    | GetLocal l0
  0022    | CallFunction 1
  0024    | JumpIfFailure 24 -> 44
  0027    | MatchScrutinee r1
  0029    | GetConstant 3: Fib
  0031    | GetLocalMove l0
  0033    | CallFunction 1
  0035    | MatchEval r1 -> 43
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | End
  ========================================
