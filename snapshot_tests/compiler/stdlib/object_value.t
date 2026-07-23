  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove l0
  0003    | JumpIfFailure 3 -> 35
  0006    | MatchWindowEnter 5
  0008    | MatchScrutinee r0
  0010    | MatchType r0 object -> 33
  0015    | MatchKeysMin r0 1 -> 33
  0020    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 33
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 40
  0008    | MatchWindowEnter 5
  0010    | MatchScrutinee r0
  0012    | MatchType r0 object -> 38
  0017    | MatchKeysMin r0 1 -> 38
  0022    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 38
  0032    | MatchBind l2 r3
  0035    | Jump 35 -> 39
  0038    | MatchFail
  0039    | MatchWindowExit
  0040    | TakeRight 40 -> 45
  0043    | GetLocalMove l2
  0045    | End
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
  0000    | PushUnderscoreVar
  0001    | PushVar S
  0003    | GetLocalMove l0
  0005    | DestructurePlan 0: ({_: _} * bind S)
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove l2
  0012    | End
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
  0002    | PushUnderscoreVar
  0003    | PushVar Rest
  0005    | SetInputMark
  0006    | GetLocalMove l0
  0008    | JumpIfFailure 8 -> 55
  0011    | MatchWindowEnter 6
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 53
  0020    | MatchKeysMin r0 1 -> 53
  0025    | MatchSearchInit r5
  0027    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ [] loop->53
  0037    | MatchBind l2 r3
  0040    | MatchObjectRestSearch r1 r0 \ [] r3..r4
  0047    | MatchBind l4 r1
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | ConditionalThen 55 -> 84
  0058    | GetConstant 3: _Obj.Keys
  0060    | GetLocalMove l4
  0062    | PushEmptyArray
  0063    | JumpIfFailure 63 -> 69
  0066    | GetLocalMove l1
  0068    | Merge
  0069    | JumpIfFailure 69 -> 79
  0072    | GetConstantMutable 6: [_]
  0074    | GetLocalMove l2
  0076    | InsertAtIndex 0
  0078    | Merge
  0079    | CallTailFunction 2
  0081    | Jump 81 -> 86
  0084    | GetLocalMove l1
  0086    | End
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
  0000    | PushUnderscoreVar
  0001    | PushVar V
  0003    | PushVar Rest
  0005    | SetInputMark
  0006    | GetLocalMove l0
  0008    | JumpIfFailure 8 -> 55
  0011    | MatchWindowEnter 6
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 53
  0020    | MatchKeysMin r0 1 -> 53
  0025    | MatchSearchInit r5
  0027    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ [] loop->53
  0037    | MatchBind l3 r4
  0040    | MatchObjectRestSearch r1 r0 \ [] r3..r4
  0047    | MatchBind l4 r1
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | ConditionalThen 55 -> 84
  0058    | GetConstant 7: _Obj.Values
  0060    | GetLocalMove l4
  0062    | PushEmptyArray
  0063    | JumpIfFailure 63 -> 69
  0066    | GetLocalMove l1
  0068    | Merge
  0069    | JumpIfFailure 69 -> 79
  0072    | GetConstantMutable 10: [_]
  0074    | GetLocalMove l3
  0076    | InsertAtIndex 0
  0078    | Merge
  0079    | CallTailFunction 2
  0081    | Jump 81 -> 86
  0084    | GetLocalMove l1
  0086    | End
  ========================================
