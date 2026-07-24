  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 41
  0005    | MatchWindowEnter 5
  0007    | MatchScrutinee r0
  0009    | MatchType r0 object -> 39
  0014    | MatchCount r0 >=1 -> 39
  0020    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 39
  0030    | MatchWindowEnter 2
  0032    | MatchSubScrutinee r0 ^r3
  0035    | MatchWindowExit
  0036    | Jump 36 -> 40
  0039    | MatchFail
  0040    | MatchWindowExit
  0041    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 46
  0007    | MatchWindowEnter 5
  0009    | MatchScrutinee r0
  0011    | MatchType r0 object -> 44
  0016    | MatchCount r0 >=1 -> 44
  0022    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 44
  0032    | MatchWindowEnter 2
  0034    | MatchSubScrutinee r0 ^r3
  0037    | MatchBind l2 r0
  0040    | MatchWindowExit
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | TakeRight 46 -> 51
  0049    | GetLocalMove l2
  0051    | End
  ========================================
  
  ===============1:Obj.Put================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | JumpIfFailure 1 -> 7
  0004    | GetLocalMove l0
  0006    | Merge
  0007    | JumpIfFailure 7 -> 19
  0010    | GetConstantMutable 2: {_0_}
  0012    | GetLocalMove l1
  0014    | GetLocalMove l2
  0016    | InsertKeyVal 0
  0018    | Merge
  0019    | End
  ========================================
  
  ===============1:Obj.Size===============
  Obj.Size(O) = O -> ({_: _} * S) & S
  ========================================
  0000    | PushVar S
  0002    | GetLocalMove l0
  0004    | DestructurePlan 0: ({_: _} * bind S)
  0006    | TakeRight 6 -> 11
  0009    | GetLocalMove l1
  0011    | End
  ========================================
  
  ===============1:Obj.Keys===============
  Obj.Keys(O) = _Obj.Keys(O, [])
  ========================================
  0000    | GetConstant 3: _Obj.Keys
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ==============1:_Obj.Keys===============
  _Obj.Keys(O, Acc) = O -> {K: _, ...Rest} ? _Obj.Keys(Rest, [...Acc, K]) : Acc
  ========================================
  0000    | PushVar K
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 61
  0010    | MatchWindowEnter 6
  0012    | MatchScrutinee r0
  0014    | MatchType r0 object -> 59
  0019    | MatchCount r0 >=1 -> 59
  0025    | MatchSearchInit r5
  0027    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ [] loop->59
  0037    | MatchWindowEnter 2
  0039    | MatchSubScrutinee r0 ^r4
  0042    | MatchWindowExit
  0043    | MatchBind l2 r3
  0046    | MatchObjectRest r1 r0 \ [] r3..r4
  0053    | MatchBind l3 r1
  0056    | Jump 56 -> 60
  0059    | MatchFail
  0060    | MatchWindowExit
  0061    | ConditionalThen 61 -> 90
  0064    | GetConstant 3: _Obj.Keys
  0066    | GetLocalMove l3
  0068    | PushEmptyArray
  0069    | JumpIfFailure 69 -> 75
  0072    | GetLocalMove l1
  0074    | Merge
  0075    | JumpIfFailure 75 -> 85
  0078    | GetConstantMutable 6: [_]
  0080    | GetLocalMove l2
  0082    | InsertAtIndex 0
  0084    | Merge
  0085    | CallTailFunction 2
  0087    | Jump 87 -> 92
  0090    | GetLocalMove l1
  0092    | End
  ========================================
  
  ==============1:Obj.Values==============
  Obj.Values(O) = _Obj.Values(O, [])
  ========================================
  0000    | GetConstant 7: _Obj.Values
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  =============1:_Obj.Values==============
  _Obj.Values(O, Acc) = O -> {_: V, ...Rest} ? _Obj.Values(Rest, [...Acc, V]) : Acc
  ========================================
  0000    | PushVar V
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 61
  0010    | MatchWindowEnter 6
  0012    | MatchScrutinee r0
  0014    | MatchType r0 object -> 59
  0019    | MatchCount r0 >=1 -> 59
  0025    | MatchSearchInit r5
  0027    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ [] loop->59
  0037    | MatchWindowEnter 2
  0039    | MatchSubScrutinee r0 ^r4
  0042    | MatchBind l2 r0
  0045    | MatchWindowExit
  0046    | MatchObjectRest r1 r0 \ [] r3..r4
  0053    | MatchBind l3 r1
  0056    | Jump 56 -> 60
  0059    | MatchFail
  0060    | MatchWindowExit
  0061    | ConditionalThen 61 -> 90
  0064    | GetConstant 7: _Obj.Values
  0066    | GetLocalMove l3
  0068    | PushEmptyArray
  0069    | JumpIfFailure 69 -> 75
  0072    | GetLocalMove l1
  0074    | Merge
  0075    | JumpIfFailure 75 -> 85
  0078    | GetConstantMutable 10: [_]
  0080    | GetLocalMove l2
  0082    | InsertAtIndex 0
  0084    | Merge
  0085    | CallTailFunction 2
  0087    | Jump 87 -> 92
  0090    | GetLocalMove l1
  0092    | End
  ========================================
