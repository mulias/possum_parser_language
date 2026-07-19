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
  0009    | JumpIfFailure 9 -> 32
  0012    | MatchWindowEnter 2 fail->30
  0016    | MatchScrutinee r0
  0018    | MatchType r0 num_or_codepoint
  0021    | MatchBound r0 hi 1
  0027    | Jump 27 -> 31
  0030    | MatchFail
  0031    | MatchWindowExit
  0032    | CallFunction 1
  0034    | ConditionalThen 34 -> 46
  0037    | GetConstant 0: const
  0039    | GetLocalMove l0
  0041    | CallTailFunction 1
  0043    | Jump 43 -> 110
  0046    | GetConstant 2: fib
  0048    | GetLocal l0
  0050    | JumpIfFailure 50 -> 56
  0053    | PushNegInteger -1
  0055    | Merge
  0056    | CallFunction 1
  0058    | JumpIfFailure 58 -> 71
  0061    | MatchWindowEnter 2 fail->70
  0065    | MatchScrutinee r0
  0067    | MatchBind l1 r0
  0070    | MatchWindowExit
  0071    | TakeRight 71 -> 110
  0074    | GetConstant 2: fib
  0076    | GetLocalMove l0
  0078    | JumpIfFailure 78 -> 84
  0081    | PushNegInteger -2
  0083    | Merge
  0084    | CallFunction 1
  0086    | JumpIfFailure 86 -> 99
  0089    | MatchWindowEnter 2 fail->98
  0093    | MatchScrutinee r0
  0095    | MatchBind l2 r0
  0098    | MatchWindowExit
  0099    | TakeRight 99 -> 110
  0102    | GetLocalMove l1
  0104    | JumpIfFailure 104 -> 110
  0107    | GetLocalMove l2
  0109    | Merge
  0110    | End
  ========================================
  
  =================2:Fib==================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 26
  0006    | MatchWindowEnter 2 fail->24
  0010    | MatchScrutinee r0
  0012    | MatchType r0 num_or_codepoint
  0015    | MatchBound r0 hi 1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | Or 26 -> 57
  0029    | GetConstant 3: Fib
  0031    | GetLocal l0
  0033    | JumpIfFailure 33 -> 39
  0036    | PushNegInteger -1
  0038    | Merge
  0039    | CallFunction 1
  0041    | JumpIfFailure 41 -> 57
  0044    | GetConstant 3: Fib
  0046    | GetLocalMove l0
  0048    | JumpIfFailure 48 -> 54
  0051    | PushNegInteger -2
  0053    | Merge
  0054    | CallFunction 1
  0056    | Merge
  0057    | End
  ========================================
  
  ================2:@main=================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | PushVar N
  0002    | PushInteger 0
  0004    | ParseLowerBoundedRange
  0005    | JumpIfFailure 5 -> 18
  0008    | MatchWindowEnter 2 fail->17
  0012    | MatchScrutinee r0
  0014    | MatchBind l0 r0
  0017    | MatchWindowExit
  0018    | TakeRight 18 -> 50
  0021    | GetConstant 2: fib
  0023    | GetLocal l0
  0025    | CallFunction 1
  0027    | JumpIfFailure 27 -> 50
  0030    | MatchWindowEnter 2 fail->48
  0034    | MatchScrutinee r0
  0036    | GetConstant 3: Fib
  0038    | GetLocalMove l0
  0040    | CallFunction 1
  0042    | MatchEval r0
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | End
  ========================================
