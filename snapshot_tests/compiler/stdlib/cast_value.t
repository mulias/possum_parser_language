  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/cast_value.possum -i '' --no-stdlib
  
  ==============1:As.Number===============
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | PushVar N
  0002    | SetInputMark
  0003    | GetConstant 0: Is.Number
  0005    | GetLocal 0
  0007    | CallFunction 1
  0009    | Or 9 -> 21
  0012    | GetLocalMove 0
  0014    | DestructurePlan 0: tmpl((eq 0 + bind N))
  0016    | TakeRight 16 -> 21
  0019    | GetLocalMove 1
  0021    | End
  ========================================
  
  ==============1:As.String===============
  As.String(V) = "%(V)"
  ========================================
  0000    | PushEmptyString
  0001    | GetLocalMove 0
  0003    | MergeAsString
  0004    | End
  ========================================
  
  ==============2:Is.Number===============
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove 0
  0003    | DestructurePlan 0: (eq 0 + _)
  0005    | End
  ========================================
