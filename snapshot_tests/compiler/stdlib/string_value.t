  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/string_value.possum -i '' --no-stdlib
  
  ==============1:Str.Length==============
  Str.Length(S) = S -> ("\u000000".. * L) $ L
  ========================================
  0000    | PushVar L
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 30
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | MatchRepeatRange r0 r2 _0_.. -> 28
  0022    | MatchBind l1 r2
  0025    | Jump 25 -> 29
  0028    | MatchFail
  0029    | MatchWindowExit
  0030    | TakeRight 30 -> 35
  0033    | GetLocalMove l1
  0035    | End
  ========================================
