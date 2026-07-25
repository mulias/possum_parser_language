  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/cast_value.possum -i '' --no-stdlib
  
  ==============1:As.Number===============
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | PushVar N
  0002    | SetInputMark
  0003    | GetConstant 0: Is.Number
  0005    | GetLocal l0
  0007    | CallFunction 1
  0009    | Or 9 -> 43
  0012    | GetLocalMove l0
  0014    | JumpIfFailure 14 -> 38
  0017    | MatchWindowEnter 6 fail->36
  0021    | MatchScrutinee r0
  0023    | MatchType r0 string
  0026    | MatchCast r4 <- num r0
  0030    | MatchBind l1 r4
  0033    | Jump 33 -> 37
  0036    | MatchFail
  0037    | MatchWindowExit
  0038    | TakeRight 38 -> 43
  0041    | GetLocalMove l1
  0043    | End
  ========================================
  
  ==============1:As.String===============
  As.String(V) = "%(V)"
  ========================================
  0000    | PushEmptyString
  0001    | GetLocalMove l0
  0003    | MergeAsString
  0004    | End
  ========================================
  
  ==============2:Is.Number===============
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 22
  0005    | MatchWindowEnter 2 fail->20
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 0
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | End
  ========================================
