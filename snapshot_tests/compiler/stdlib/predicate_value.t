  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/predicate_value.possum -i '' --no-stdlib
  
  ================0:@Fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ==============1:Is.String===============
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 23
  0014    | MatchCount r0 >=0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
  ========================================
  
  ==============1:Is.Number===============
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 22
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchMergeNum r1 r0 - 0 -> 20
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | End
  ========================================
  
  ===============1:Is.Bool================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchMergeBool r1 r0 claim false -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================
  
  ===============1:Is.Null================
  Is.Null(V) = V -> null
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == null -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================
  
  ===============1:Is.Array===============
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 array -> 23
  0014    | MatchCount r0 >=0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
  ========================================
  
  ==============1:Is.Object===============
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 19
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 object -> 17
  0014    | Jump 14 -> 18
  0017    | MatchFail
  0018    | MatchWindowExit
  0019    | End
  ========================================
  
  ===============1:Is.Equal===============
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == l1 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================
  
  =============1:Is.LessThan==============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 22
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchCmp r0 == l1 -> 20
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | ConditionalThen 22 -> 30
  0025    | CallTailFunctionConstant 3: @Fail
  0027    | Jump 27 -> 57
  0030    | GetLocalMove l0
  0032    | JumpIfFailure 32 -> 57
  0035    | MatchWindowEnter 2
  0037    | MatchScrutinee r0
  0039    | MatchType r0 num_or_codepoint -> 55
  0044    | MatchBound r0 hi s1 -> 55
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
  ========================================
  
  ==========1:Is.LessThanOrEqual==========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 27
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 num_or_codepoint -> 25
  0014    | MatchBound r0 hi s1 -> 25
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
  ========================================
  
  ============1:Is.GreaterThan============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 22
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchCmp r0 == l1 -> 20
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | ConditionalThen 22 -> 30
  0025    | CallTailFunctionConstant 3: @Fail
  0027    | Jump 27 -> 57
  0030    | GetLocalMove l0
  0032    | JumpIfFailure 32 -> 57
  0035    | MatchWindowEnter 2
  0037    | MatchScrutinee r0
  0039    | MatchType r0 num_or_codepoint -> 55
  0044    | MatchBound r0 lo s1 -> 55
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
  ========================================
  
  ========1:Is.GreaterThanOrEqual=========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 27
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 num_or_codepoint -> 25
  0014    | MatchBound r0 lo s1 -> 25
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
  ========================================
