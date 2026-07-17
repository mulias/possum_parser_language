  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove 0
  0003    | DestructurePlan 0: ({bound_eq K: _} + _)
  0005    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | PushUnderscoreVar
  0003    | GetLocalMove 0
  0005    | DestructurePlan 1: ({bound_eq K: bind V} + _)
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove 2
  0012    | End
  ========================================
  
  ===============1:Obj.Put================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | JumpIfFailure 1 -> 7
  0004    | GetLocalMove 0
  0006    | Merge
  0007    | JumpIfFailure 7 -> 19
  0010    | GetConstantMutable 0: {_0_}
  0012    | GetLocalMove 1
  0014    | GetLocalMove 2
  0016    | InsertKeyVal 0
  0018    | Merge
  0019    | End
  ========================================
  
  ===============1:Obj.Size===============
  Obj.Size(O) = O -> ({_: _} * S) & S
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar S
  0003    | GetLocalMove 0
  0005    | DestructurePlan 2: ({_: _} * bind S)
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove 2
  0012    | End
  ========================================
  
  ===============1:Obj.Keys===============
  Obj.Keys(O) = _Obj.Keys(O, [])
  ========================================
  0000    | GetConstant 1: _Obj.Keys
  0002    | GetLocalMove 0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ==============1:_Obj.Keys===============
  _Obj.Keys(O, Acc) = O -> {K: _, ...Rest} ? _Obj.Keys(Rest, [...Acc, K]) : Acc
  ========================================
  0000    | PushVar K
  0002    | PushUnderscoreVar
  0003    | PushVar Rest
  0005    | SetInputMark
  0006    | GetLocalMove 0
  0008    | DestructurePlan 3: ({bind K: _} + bind Rest)
  0010    | ConditionalThen 10 -> 39
  0013    | GetConstant 1: _Obj.Keys
  0015    | GetLocalMove 4
  0017    | PushEmptyArray
  0018    | JumpIfFailure 18 -> 24
  0021    | GetLocalMove 1
  0023    | Merge
  0024    | JumpIfFailure 24 -> 34
  0027    | GetConstantMutable 2: [_]
  0029    | GetLocalMove 2
  0031    | InsertAtIndex 0
  0033    | Merge
  0034    | CallTailFunction 2
  0036    | Jump 36 -> 41
  0039    | GetLocalMove 1
  0041    | End
  ========================================
  
  ==============1:Obj.Values==============
  Obj.Values(O) = _Obj.Values(O, [])
  ========================================
  0000    | GetConstant 3: _Obj.Values
  0002    | GetLocalMove 0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  =============1:_Obj.Values==============
  _Obj.Values(O, Acc) = O -> {_: V, ...Rest} ? _Obj.Values(Rest, [...Acc, V]) : Acc
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar V
  0003    | PushVar Rest
  0005    | SetInputMark
  0006    | GetLocalMove 0
  0008    | DestructurePlan 4: ({_: bind V} + bind Rest)
  0010    | ConditionalThen 10 -> 39
  0013    | GetConstant 3: _Obj.Values
  0015    | GetLocalMove 4
  0017    | PushEmptyArray
  0018    | JumpIfFailure 18 -> 24
  0021    | GetLocalMove 1
  0023    | Merge
  0024    | JumpIfFailure 24 -> 34
  0027    | GetConstantMutable 4: [_]
  0029    | GetLocalMove 3
  0031    | InsertAtIndex 0
  0033    | Merge
  0034    | CallTailFunction 2
  0036    | Jump 36 -> 41
  0039    | GetLocalMove 1
  0041    | End
  ========================================
