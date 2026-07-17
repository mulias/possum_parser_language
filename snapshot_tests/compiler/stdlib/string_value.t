  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/string_value.possum -i '' --no-stdlib
  
  ==============1:Str.Length==============
  Str.Length(S) = S -> ("\u000000".. * L) $ L
  ========================================
  0000    | PushVar L
  0002    | GetLocalMove 0
  0004    | DestructurePlan 0: (_0_.. * bind L)
  0006    | TakeRight 6 -> 11
  0009    | GetLocalMove 1
  0011    | End
  ========================================
