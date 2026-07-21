  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/string_value.possum -i '' --no-stdlib
  
  ==============1:Str.Length==============
  Str.Length(S) = S -> ("\u000000".. * L) $ L
  ========================================
  0000    | PushVar L
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 30
  0010    | MatchScrutinee r2
  0012    | MatchRepeatRange r2 r4 _0_.. -> 29
  0023    | MatchBind l1 r4
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | TakeRight 30 -> 35
  0033    | GetLocalMove l1
  0035    | End
  ========================================
