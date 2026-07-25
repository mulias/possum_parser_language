  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 40
  0005    | MatchWindowEnter 5 fail->38
  0009    | MatchScrutinee r0
  0011    | MatchType r0 object
  0014    | MatchCount r0 >=1
  0018    | GetLocalMove l1
  0020    | MatchKeyClaim key=r2 val=r3 src=r0 keys=r2..r2 \ []
  0027    | MatchWindowEnter 2 fail->34
  0031    | MatchSubScrutinee r0 ^r3
  0034    | MatchWindowExit
  0035    | Jump 35 -> 39
  0038    | MatchFail
  0039    | MatchWindowExit
  0040    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 45
  0007    | MatchWindowEnter 5 fail->43
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object
  0016    | MatchCount r0 >=1
  0020    | GetLocalMove l1
  0022    | MatchKeyClaim key=r2 val=r3 src=r0 keys=r2..r2 \ []
  0029    | MatchWindowEnter 2 fail->39
  0033    | MatchSubScrutinee r0 ^r3
  0036    | MatchBind l2 r0
  0039    | MatchWindowExit
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | TakeRight 45 -> 50
  0048    | GetLocalMove l2
  0050    | End
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
  0007    | JumpIfFailure 7 -> 59
  0010    | MatchWindowEnter 6 fail->57
  0014    | MatchScrutinee r0
  0016    | MatchType r0 object
  0019    | MatchCount r0 >=1
  0023    | MatchSearchInit r5
  0025    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ []
  0033    | MatchBind l2 r3
  0036    | MatchWindowEnter 2 fail->43
  0040    | MatchSubScrutinee r0 ^r4
  0043    | MatchWindowExit
  0044    | MatchObjectRest r1 r0 \ [] r3..r4
  0051    | MatchBind l3 r1
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | MatchWindowExit
  0059    | ConditionalThen 59 -> 88
  0062    | GetConstant 3: _Obj.Keys
  0064    | GetLocalMove l3
  0066    | PushEmptyArray
  0067    | JumpIfFailure 67 -> 73
  0070    | GetLocalMove l1
  0072    | Merge
  0073    | JumpIfFailure 73 -> 83
  0076    | GetConstantMutable 6: [_]
  0078    | GetLocalMove l2
  0080    | InsertAtIndex 0
  0082    | Merge
  0083    | CallTailFunction 2
  0085    | Jump 85 -> 90
  0088    | GetLocalMove l1
  0090    | End
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
  0007    | JumpIfFailure 7 -> 59
  0010    | MatchWindowEnter 6 fail->57
  0014    | MatchScrutinee r0
  0016    | MatchType r0 object
  0019    | MatchCount r0 >=1
  0023    | MatchSearchInit r5
  0025    | MatchNextUnclaimed key=r3 val=r4 src=r0 cursor=r5 keys=r3..r3 \ []
  0033    | MatchWindowEnter 2 fail->43
  0037    | MatchSubScrutinee r0 ^r4
  0040    | MatchBind l2 r0
  0043    | MatchWindowExit
  0044    | MatchObjectRest r1 r0 \ [] r3..r4
  0051    | MatchBind l3 r1
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | MatchWindowExit
  0059    | ConditionalThen 59 -> 88
  0062    | GetConstant 7: _Obj.Values
  0064    | GetLocalMove l3
  0066    | PushEmptyArray
  0067    | JumpIfFailure 67 -> 73
  0070    | GetLocalMove l1
  0072    | Merge
  0073    | JumpIfFailure 73 -> 83
  0076    | GetConstantMutable 10: [_]
  0078    | GetLocalMove l2
  0080    | InsertAtIndex 0
  0082    | Merge
  0083    | CallTailFunction 2
  0085    | Jump 85 -> 90
  0088    | GetLocalMove l1
  0090    | End
  ========================================
