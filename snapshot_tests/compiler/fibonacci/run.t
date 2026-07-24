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
  0004    | SetInputMark
  0005    | GetConstant 0: const
  0007    | GetLocal l0
  0009    | JumpIfFailure 9 -> 34
  0012    | MatchWindowEnter 2
  0014    | MatchScrutinee r0
  0016    | MatchType r0 num_or_codepoint -> 32
  0021    | MatchBound r0 hi 1 -> 32
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | MatchWindowExit
  0034    | CallFunction 1
  0036    | ConditionalThen 36 -> 48
  0039    | GetConstant 0: const
  0041    | GetLocalMove l0
  0043    | CallTailFunction 1
  0045    | Jump 45 -> 108
  0048    | GetConstant 2: fib
  0050    | GetLocal l0
  0052    | JumpIfFailure 52 -> 58
  0055    | PushNegInteger -1
  0057    | Merge
  0058    | CallFunction 1
  0060    | JumpIfFailure 60 -> 71
  0063    | MatchWindowEnter 2
  0065    | MatchScrutinee r0
  0067    | MatchBind l1 r0
  0070    | MatchWindowExit
  0071    | TakeRight 71 -> 108
  0074    | GetConstant 2: fib
  0076    | GetLocalMove l0
  0078    | JumpIfFailure 78 -> 84
  0081    | PushNegInteger -2
  0083    | Merge
  0084    | CallFunction 1
  0086    | JumpIfFailure 86 -> 97
  0089    | MatchWindowEnter 2
  0091    | MatchScrutinee r0
  0093    | MatchBind l2 r0
  0096    | MatchWindowExit
  0097    | TakeRight 97 -> 108
  0100    | GetLocalMove l1
  0102    | JumpIfFailure 102 -> 108
  0105    | GetLocalMove l2
  0107    | Merge
  0108    | End
  ========================================
  
  =================2:Fib==================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 28
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 num_or_codepoint -> 26
  0015    | MatchBound r0 hi 1 -> 26
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | Or 28 -> 59
  0031    | GetConstant 3: Fib
  0033    | GetLocal l0
  0035    | JumpIfFailure 35 -> 41
  0038    | PushNegInteger -1
  0040    | Merge
  0041    | CallFunction 1
  0043    | JumpIfFailure 43 -> 59
  0046    | GetConstant 3: Fib
  0048    | GetLocalMove l0
  0050    | JumpIfFailure 50 -> 56
  0053    | PushNegInteger -2
  0055    | Merge
  0056    | CallFunction 1
  0058    | Merge
  0059    | End
  ========================================
  
  ================2:@main=================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | PushVar N
  0002    | PushInteger 0
  0004    | ParseLowerBoundedRange
  0005    | JumpIfFailure 5 -> 16
  0008    | MatchWindowEnter 2
  0010    | MatchScrutinee r0
  0012    | MatchBind l0 r0
  0015    | MatchWindowExit
  0016    | TakeRight 16 -> 48
  0019    | GetConstant 2: fib
  0021    | GetLocal l0
  0023    | CallFunction 1
  0025    | JumpIfFailure 25 -> 48
  0028    | MatchWindowEnter 2
  0030    | MatchScrutinee r0
  0032    | GetConstant 3: Fib
  0034    | GetLocalMove l0
  0036    | CallFunction 1
  0038    | MatchEval r0 -> 46
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | End
  ========================================
