  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetLocalMove l0
  0008    | JumpIfFailure 8 -> 37
  0011    | MatchScrutinee r3
  0013    | MatchType r3 object -> 36
  0018    | MatchKeysMin r3 1 -> 36
  0023    | MatchKeyBound key=r5 val=r6 src=r3[l1] keys=r5..r5 \ [] -> 36
  0033    | Jump 33 -> 37
  0036    | MatchFail
  0037    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | GetLocalMove l0
  0010    | JumpIfFailure 10 -> 42
  0013    | MatchScrutinee r4
  0015    | MatchType r4 object -> 41
  0020    | MatchKeysMin r4 1 -> 41
  0025    | MatchKeyBound key=r6 val=r7 src=r4[l1] keys=r6..r6 \ [] -> 41
  0035    | MatchBind l2 r7
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | TakeRight 42 -> 47
  0045    | GetLocalMove l2
  0047    | End
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
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | SetInputMark
  0012    | GetLocalMove l0
  0014    | JumpIfFailure 14 -> 58
  0017    | MatchScrutinee r5
  0019    | MatchType r5 object -> 57
  0024    | MatchKeysMin r5 1 -> 57
  0029    | MatchSearchInit r10
  0031    | MatchNextUnclaimed key=r8 val=r9 src=r5 cursor=r10 keys=r8..r8 \ [] loop->57
  0041    | MatchBind l2 r8
  0044    | MatchObjectRestSearch r6 r5 \ [] r8..r9
  0051    | MatchBind l4 r6
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | ConditionalThen 58 -> 87
  0061    | GetConstant 3: _Obj.Keys
  0063    | GetLocalMove l4
  0065    | PushEmptyArray
  0066    | JumpIfFailure 66 -> 72
  0069    | GetLocalMove l1
  0071    | Merge
  0072    | JumpIfFailure 72 -> 82
  0075    | GetConstantMutable 6: [_]
  0077    | GetLocalMove l2
  0079    | InsertAtIndex 0
  0081    | Merge
  0082    | CallTailFunction 2
  0084    | Jump 84 -> 89
  0087    | GetLocalMove l1
  0089    | End
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
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | SetInputMark
  0012    | GetLocalMove l0
  0014    | JumpIfFailure 14 -> 58
  0017    | MatchScrutinee r5
  0019    | MatchType r5 object -> 57
  0024    | MatchKeysMin r5 1 -> 57
  0029    | MatchSearchInit r10
  0031    | MatchNextUnclaimed key=r8 val=r9 src=r5 cursor=r10 keys=r8..r8 \ [] loop->57
  0041    | MatchBind l3 r9
  0044    | MatchObjectRestSearch r6 r5 \ [] r8..r9
  0051    | MatchBind l4 r6
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | ConditionalThen 58 -> 87
  0061    | GetConstant 7: _Obj.Values
  0063    | GetLocalMove l4
  0065    | PushEmptyArray
  0066    | JumpIfFailure 66 -> 72
  0069    | GetLocalMove l1
  0071    | Merge
  0072    | JumpIfFailure 72 -> 82
  0075    | GetConstantMutable 10: [_]
  0077    | GetLocalMove l3
  0079    | InsertAtIndex 0
  0081    | Merge
  0082    | CallTailFunction 2
  0084    | Jump 84 -> 89
  0087    | GetLocalMove l1
  0089    | End
  ========================================
