  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 45
  0005    | MatchWindowEnter 6 fail->43
  0009    | MatchScrutinee r0
  0011    | MatchClaimSeed r2 <- []
  0015    | MatchType r0 object
  0018    | MatchCount r0 >=1
  0022    | GetLocalMove l1
  0024    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0029    | MatchWindowEnter 2 fail->36
  0033    | MatchSubScrutinee r0 ^r4
  0036    | MatchWindowExit
  0037    | MatchClaimAdd r2 r3
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 50
  0007    | MatchWindowEnter 6 fail->48
  0011    | MatchScrutinee r0
  0013    | MatchClaimSeed r2 <- []
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | GetLocalMove l1
  0026    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0031    | MatchWindowEnter 2 fail->41
  0035    | MatchSubScrutinee r0 ^r4
  0038    | MatchBind l2 r0
  0041    | MatchWindowExit
  0042    | MatchClaimAdd r2 r3
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | TakeRight 50 -> 55
  0053    | GetLocalMove l2
  0055    | End
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
  0004    | JumpIfFailure 4 -> 29
  0007    | MatchWindowEnter 4 fail->27
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object
  0016    | MatchRepeatInit r0 /1 n=r2 base=r3
  0021    | MatchBind l1 r2
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l1
  0034    | End
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
  0010    | MatchWindowEnter 7 fail->59
  0014    | MatchScrutinee r0
  0016    | MatchClaimSeed r3 <- []
  0020    | MatchType r0 object
  0023    | MatchCount r0 >=1
  0027    | MatchIterInit r6
  0029    | MatchClaimScan key=r4 val=r5 src=r0 cursor=r6 claims=r3
  0035    | MatchBind l2 r4
  0038    | MatchWindowEnter 2 fail->45
  0042    | MatchSubScrutinee r0 ^r5
  0045    | MatchWindowExit
  0046    | MatchClaimAdd r3 r4
  0049    | MatchClaimRest r1 <- r0 \ claims=r3
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
  0078    | GetConstantMutable 5: [_]
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
  0000    | GetConstant 6: _Obj.Values
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
  0010    | MatchWindowEnter 7 fail->59
  0014    | MatchScrutinee r0
  0016    | MatchClaimSeed r3 <- []
  0020    | MatchType r0 object
  0023    | MatchCount r0 >=1
  0027    | MatchIterInit r6
  0029    | MatchClaimScan key=r4 val=r5 src=r0 cursor=r6 claims=r3
  0035    | MatchWindowEnter 2 fail->45
  0039    | MatchSubScrutinee r0 ^r5
  0042    | MatchBind l2 r0
  0045    | MatchWindowExit
  0046    | MatchClaimAdd r3 r4
  0049    | MatchClaimRest r1 <- r0 \ claims=r3
  0053    | MatchBind l3 r1
  0056    | Jump 56 -> 60
  0059    | MatchFail
  0060    | MatchWindowExit
  0061    | ConditionalThen 61 -> 90
  0064    | GetConstant 6: _Obj.Values
  0066    | GetLocalMove l3
  0068    | PushEmptyArray
  0069    | JumpIfFailure 69 -> 75
  0072    | GetLocalMove l1
  0074    | Merge
  0075    | JumpIfFailure 75 -> 85
  0078    | GetConstantMutable 8: [_]
  0080    | GetLocalMove l2
  0082    | InsertAtIndex 0
  0084    | Merge
  0085    | CallTailFunction 2
  0087    | Jump 87 -> 92
  0090    | GetLocalMove l1
  0092    | End
  ========================================
