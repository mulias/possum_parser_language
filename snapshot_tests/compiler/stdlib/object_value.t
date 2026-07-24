  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 34
  0005    | MatchWindowEnter 5
  0007    | MatchScrutinee r0
  0009    | MatchType r0 object -> 32
  0014    | MatchKeysMin r0 1 -> 32
  0019    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 32
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | MatchWindowExit
  0034    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 39
  0007    | MatchWindowEnter 5
  0009    | MatchScrutinee r0
  0011    | MatchType r0 object -> 37
  0016    | MatchKeysMin r0 1 -> 37
  0021    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 37
  0031    | MatchBind l2 r3
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | TakeRight 39 -> 44
  0042    | GetLocalMove l2
  0044    | End
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
  0007    | JumpIfFailure 7 -> 54
  0010    | MatchWindowEnter 6
  0012    | MatchScrutinee r0
  0014    | MatchType r0 object -> 52
  0019    | MatchKeysMin r0 1 -> 52
  0024    | MatchSearchInit r5
  0026    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ [] loop->52
  0036    | MatchBind l2 r3
  0039    | MatchObjectRestSearch r1 r0 \ [] r3..r4
  0046    | MatchBind l3 r1
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | ConditionalThen 54 -> 83
  0057    | GetConstant 3: _Obj.Keys
  0059    | GetLocalMove l3
  0061    | PushEmptyArray
  0062    | JumpIfFailure 62 -> 68
  0065    | GetLocalMove l1
  0067    | Merge
  0068    | JumpIfFailure 68 -> 78
  0071    | GetConstantMutable 6: [_]
  0073    | GetLocalMove l2
  0075    | InsertAtIndex 0
  0077    | Merge
  0078    | CallTailFunction 2
  0080    | Jump 80 -> 85
  0083    | GetLocalMove l1
  0085    | End
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
  0007    | JumpIfFailure 7 -> 54
  0010    | MatchWindowEnter 6
  0012    | MatchScrutinee r0
  0014    | MatchType r0 object -> 52
  0019    | MatchKeysMin r0 1 -> 52
  0024    | MatchSearchInit r5
  0026    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ [] loop->52
  0036    | MatchBind l2 r4
  0039    | MatchObjectRestSearch r1 r0 \ [] r3..r4
  0046    | MatchBind l3 r1
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | ConditionalThen 54 -> 83
  0057    | GetConstant 7: _Obj.Values
  0059    | GetLocalMove l3
  0061    | PushEmptyArray
  0062    | JumpIfFailure 62 -> 68
  0065    | GetLocalMove l1
  0067    | Merge
  0068    | JumpIfFailure 68 -> 78
  0071    | GetConstantMutable 10: [_]
  0073    | GetLocalMove l2
  0075    | InsertAtIndex 0
  0077    | Merge
  0078    | CallTailFunction 2
  0080    | Jump 80 -> 85
  0083    | GetLocalMove l1
  0085    | End
  ========================================
