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
  0009    | Or 9 -> 44
  0012    | GetLocalMove l0
  0014    | JumpIfFailure 14 -> 39
  0017    | MatchWindowEnter 6
  0019    | MatchScrutinee r0
  0021    | MatchType r0 string -> 37
  0026    | MatchCastNum r4 <- r0 -> 37
  0031    | MatchBind l1 r4
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | TakeRight 39 -> 44
  0042    | GetLocalMove l1
  0044    | End
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
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchMergeNum r1 r0 - 0 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================
