  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/cast_value.possum -i '' --no-stdlib
  
  ==============1:As.Number===============
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetConstant 0: Is.Number
  0011    | GetLocal l0
  0013    | CallFunction 1
  0015    | Or 15 -> 47
  0018    | GetLocalMove l0
  0020    | JumpIfFailure 20 -> 42
  0023    | MatchScrutinee r2
  0025    | MatchType r2 string -> 41
  0030    | MatchCastNum r6 <- r2 -> 41
  0035    | MatchBind l1 r6
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | TakeRight 42 -> 47
  0045    | GetLocalMove l1
  0047    | End
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
  0000    | PushUnderscoreVar
  0001    | GetLocalMove l0
  0003    | JumpIfFailure 3 -> 22
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchMergeNum r1 r0 - 0 -> 20
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | End
  ========================================
