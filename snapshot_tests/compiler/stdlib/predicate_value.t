  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/predicate_value.possum -i '' --no-stdlib
  
  ================0:@Fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ==============1:Is.String===============
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r2
  0010    | MatchType r2 string -> 23
  0015    | MatchLenMin r2 0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | End
  ========================================
  
  ==============1:Is.Number===============
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 21
  0008    | MatchScrutinee r2
  0010    | MatchMergeNum r3 r2 - 0 -> 20
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | End
  ========================================
  
  ===============1:Is.Bool================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 21
  0008    | MatchScrutinee r2
  0010    | MatchMergeBool r3 r2 claim false -> 20
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | End
  ========================================
  
  ===============1:Is.Null================
  Is.Null(V) = V -> null
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 19
  0007    | MatchScrutinee r1
  0009    | MatchConst r1 null -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================
  
  ===============1:Is.Array===============
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r2
  0010    | MatchType r2 array -> 23
  0015    | MatchLenMin r2 0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | End
  ========================================
  
  ==============1:Is.Object===============
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 19
  0008    | MatchScrutinee r2
  0010    | MatchType r2 object -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================
  
  ===============1:Is.Equal===============
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 18
  0007    | MatchScrutinee r2
  0009    | MatchSlot r2 l1 -> 17
  0014    | Jump 14 -> 18
  0017    | MatchFail
  0018    | End
  ========================================
  
  =============1:Is.LessThan==============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 19
  0008    | MatchScrutinee r2
  0010    | MatchSlot r2 l1 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | ConditionalThen 19 -> 27
  0022    | CallTailFunctionConstant 3: @Fail
  0024    | Jump 24 -> 48
  0027    | GetLocalMove l0
  0029    | JumpIfFailure 29 -> 48
  0032    | MatchScrutinee r2
  0034    | MatchInRange r2 ..s1 -> 47
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | End
  ========================================
  
  ==========1:Is.LessThanOrEqual==========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 23
  0007    | MatchScrutinee r2
  0009    | MatchInRange r2 ..s1 -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================
  
  ============1:Is.GreaterThan============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 19
  0008    | MatchScrutinee r2
  0010    | MatchSlot r2 l1 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | ConditionalThen 19 -> 27
  0022    | CallTailFunctionConstant 3: @Fail
  0024    | Jump 24 -> 48
  0027    | GetLocalMove l0
  0029    | JumpIfFailure 29 -> 48
  0032    | MatchScrutinee r2
  0034    | MatchInRange r2 s1.. -> 47
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | End
  ========================================
  
  ========1:Is.GreaterThanOrEqual=========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 23
  0007    | MatchScrutinee r2
  0009    | MatchInRange r2 s1.. -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================
