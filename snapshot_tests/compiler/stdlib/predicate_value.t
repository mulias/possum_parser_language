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
  0001    | GetLocalMove 0
  0003    | DestructurePlan 0: (eq "" + _)
  0005    | End
  ========================================
  
  ==============1:Is.Number===============
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove 0
  0003    | DestructurePlan 1: (eq 0 + _)
  0005    | End
  ========================================
  
  ===============1:Is.Bool================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove 0
  0003    | DestructurePlan 2: (eq false + _)
  0005    | End
  ========================================
  
  ===============1:Is.Null================
  Is.Null(V) = V -> null
  ========================================
  0000    | GetLocalMove 0
  0002    | DestructurePlan 3: eq null
  0004    | End
  ========================================
  
  ===============1:Is.Array===============
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove 0
  0003    | DestructurePlan 4: ([] + _)
  0005    | End
  ========================================
  
  ==============1:Is.Object===============
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove 0
  0003    | DestructurePlan 5: ({} + _)
  0005    | End
  ========================================
  
  ===============1:Is.Equal===============
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | GetLocalMove 0
  0002    | DestructurePlan 6: bound_eq B
  0004    | End
  ========================================
  
  =============1:Is.LessThan==============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | DestructurePlan 7: bound_eq B
  0005    | ConditionalThen 5 -> 13
  0008    | CallTailFunctionConstant 0: @Fail
  0010    | Jump 10 -> 17
  0013    | GetLocalMove 0
  0015    | DestructurePlan 8: ..B
  0017    | End
  ========================================
  
  ==========1:Is.LessThanOrEqual==========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetLocalMove 0
  0002    | DestructurePlan 9: ..B
  0004    | End
  ========================================
  
  ============1:Is.GreaterThan============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | DestructurePlan 10: bound_eq B
  0005    | ConditionalThen 5 -> 13
  0008    | CallTailFunctionConstant 0: @Fail
  0010    | Jump 10 -> 17
  0013    | GetLocalMove 0
  0015    | DestructurePlan 11: B..
  0017    | End
  ========================================
  
  ========1:Is.GreaterThanOrEqual=========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetLocalMove 0
  0002    | DestructurePlan 12: B..
  0004    | End
  ========================================
