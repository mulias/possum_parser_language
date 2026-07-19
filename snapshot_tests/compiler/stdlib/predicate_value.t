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
  0002    | JumpIfFailure 2 -> 23
  0005    | MatchWindowEnter 2 fail->21
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string
  0014    | MatchCount r0 >=0
  0018    | Jump 18 -> 22
  0021    | MatchFail
  0022    | MatchWindowExit
  0023    | End
  ========================================
  
  ==============1:Is.Number===============
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
  
  ===============1:Is.Bool================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchMergeBool r1 r0 claim false
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == null
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================
  
  ===============1:Is.Array===============
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 23
  0005    | MatchWindowEnter 2 fail->21
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array
  0014    | MatchCount r0 >=0
  0018    | Jump 18 -> 22
  0021    | MatchFail
  0022    | MatchWindowExit
  0023    | End
  ========================================
  
  ==============1:Is.Object===============
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 19
  0005    | MatchWindowEnter 2 fail->17
  0009    | MatchScrutinee r0
  0011    | MatchType r0 object
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == l1
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
  0006    | MatchWindowEnter 2 fail->20
  0010    | MatchScrutinee r0
  0012    | MatchCmp r0 == l1
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | ConditionalThen 22 -> 30
  0025    | CallTailFunctionConstant 3: @Fail
  0027    | Jump 27 -> 55
  0030    | GetLocalMove l0
  0032    | JumpIfFailure 32 -> 55
  0035    | MatchWindowEnter 2 fail->53
  0039    | MatchScrutinee r0
  0041    | MatchType r0 num_or_codepoint
  0044    | MatchBound r0 hi s1
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
  ========================================
  
  ==========1:Is.LessThanOrEqual==========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2 fail->23
  0009    | MatchScrutinee r0
  0011    | MatchType r0 num_or_codepoint
  0014    | MatchBound r0 hi s1
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
  ========================================
  
  ============1:Is.GreaterThan============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 22
  0006    | MatchWindowEnter 2 fail->20
  0010    | MatchScrutinee r0
  0012    | MatchCmp r0 == l1
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | ConditionalThen 22 -> 30
  0025    | CallTailFunctionConstant 3: @Fail
  0027    | Jump 27 -> 55
  0030    | GetLocalMove l0
  0032    | JumpIfFailure 32 -> 55
  0035    | MatchWindowEnter 2 fail->53
  0039    | MatchScrutinee r0
  0041    | MatchType r0 num_or_codepoint
  0044    | MatchBound r0 lo s1
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
  ========================================
  
  ========1:Is.GreaterThanOrEqual=========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2 fail->23
  0009    | MatchScrutinee r0
  0011    | MatchType r0 num_or_codepoint
  0014    | MatchBound r0 lo s1
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
  ========================================
