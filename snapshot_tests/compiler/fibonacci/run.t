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
  0009    | JumpIfFailure 9 -> 31
  0012    | MatchWindowEnter 2
  0014    | MatchScrutinee r0
  0016    | MatchInRange r0 ..1 -> 29
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | MatchWindowExit
  0031    | CallFunction 1
  0033    | ConditionalThen 33 -> 45
  0036    | GetConstant 0: const
  0038    | GetLocalMove l0
  0040    | CallTailFunction 1
  0042    | Jump 42 -> 105
  0045    | GetConstant 2: fib
  0047    | GetLocal l0
  0049    | JumpIfFailure 49 -> 55
  0052    | PushNegInteger -1
  0054    | Merge
  0055    | CallFunction 1
  0057    | JumpIfFailure 57 -> 68
  0060    | MatchWindowEnter 2
  0062    | MatchScrutinee r0
  0064    | MatchBind l1 r0
  0067    | MatchWindowExit
  0068    | TakeRight 68 -> 105
  0071    | GetConstant 2: fib
  0073    | GetLocalMove l0
  0075    | JumpIfFailure 75 -> 81
  0078    | PushNegInteger -2
  0080    | Merge
  0081    | CallFunction 1
  0083    | JumpIfFailure 83 -> 94
  0086    | MatchWindowEnter 2
  0088    | MatchScrutinee r0
  0090    | MatchBind l2 r0
  0093    | MatchWindowExit
  0094    | TakeRight 94 -> 105
  0097    | GetLocalMove l1
  0099    | JumpIfFailure 99 -> 105
  0102    | GetLocalMove l2
  0104    | Merge
  0105    | End
  ========================================
  
  =================2:Fib==================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 25
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchInRange r0 ..1 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | Or 25 -> 56
  0028    | GetConstant 3: Fib
  0030    | GetLocal l0
  0032    | JumpIfFailure 32 -> 38
  0035    | PushNegInteger -1
  0037    | Merge
  0038    | CallFunction 1
  0040    | JumpIfFailure 40 -> 56
  0043    | GetConstant 3: Fib
  0045    | GetLocalMove l0
  0047    | JumpIfFailure 47 -> 53
  0050    | PushNegInteger -2
  0052    | Merge
  0053    | CallFunction 1
  0055    | Merge
  0056    | End
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
