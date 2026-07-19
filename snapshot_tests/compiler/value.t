  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '"" $ [1, 2, [1+1+1]]' -i ''
  
  ================2:@main=================
  "" $ [1, 2, [1+1+1]]
  ========================================
  0000    | GetConstantMutable 0: [1, 2, _]
  0002    | GetConstant 1: [3]
  0004    | InsertAtIndex 2
  0006    | End
  ========================================

  $ possum -p '1 -> A $ A' -i ''
  
  ================2:@main=================
  1 -> A $ A
  ========================================
  0000    | PushVar A
  0002    | ParseNumberStringChar 1
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l0 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 22
  0020    | GetLocalMove l0
  0022    | End
  ========================================

  $ possum -p '1 -> A $ [A]' -i ''
  
  ================2:@main=================
  1 -> A $ [A]
  ========================================
  0000    | PushVar A
  0002    | ParseNumberStringChar 1
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l0 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 0: [_]
  0022    | GetLocalMove l0
  0024    | InsertAtIndex 0
  0026    | End
  ========================================

  $ possum -p '2 -> A $ [1, [2]]' -i ''
  
  ================2:@main=================
  2 -> A $ [1, [2]]
  ========================================
  0000    | PushVar A
  0002    | ParseNumberStringChar 2
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l0 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 0: [1, _]
  0022    | GetConstant 1: [2]
  0024    | InsertAtIndex 1
  0026    | End
  ========================================

  $ possum -p 'Foo = 1 + 1 ; "" $ [Foo]' -i ''
  
  ================2:@main=================
  "" $ [Foo]
  ========================================
  0000    | GetConstant 0: [2]
  0002    | End
  ========================================

  $ possum -p '1 -> A $ [[A]]' -i ''
  
  ================2:@main=================
  1 -> A $ [[A]]
  ========================================
  0000    | PushVar A
  0002    | ParseNumberStringChar 1
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l0 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 30
  0020    | GetConstantMutable 0: [_]
  0022    | GetConstantMutable 1: [_]
  0024    | GetLocalMove l0
  0026    | InsertAtIndex 0
  0028    | InsertAtIndex 0
  0030    | End
  ========================================

  $ possum -p 'Foo = 1 -> A & A + A ; "" $ [Foo]' -i ''
  
  =================2:Foo==================
  Foo = 1 -> A & A + A
  ========================================
  0000    | PushVar A
  0002    | PushInteger 1
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l0 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 28
  0020    | GetLocal l0
  0022    | JumpIfFailure 22 -> 28
  0025    | GetLocalMove l0
  0027    | Merge
  0028    | End
  ========================================
  
  ================2:@main=================
  "" $ [Foo]
  ========================================
  0000    | GetConstantMutable 0: [_]
  0002    | CallFunctionConstant 1: Foo
  0004    | InsertAtIndex 0
  0006    | End
  ========================================

  $ possum -p 'A = [1,2,3] ; const([...A, ...A])' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ==================2:A===================
  A = [1,2,3]
  ========================================
  0000    | GetConstant 0: [1, 2, 3]
  0002    | End
  ========================================
  
  ================2:@main=================
  const([...A, ...A])
  ========================================
  0000    | GetConstant 1: const
  0002    | PushEmptyArray
  0003    | JumpIfFailure 3 -> 9
  0006    | CallFunctionConstant 2: A
  0008    | Merge
  0009    | JumpIfFailure 9 -> 15
  0012    | CallFunctionConstant 2: A
  0014    | Merge
  0015    | CallTailFunction 1
  0017    | End
  ========================================

  $ possum -p '1 -> A & 2 -> B $ {"a": A, "b": B}' -i '12'
  
  ================2:@main=================
  1 -> A & 2 -> B $ {"a": A, "b": B}
  ========================================
  0000    | PushVar A
  0002    | PushVar B
  0004    | ParseNumberStringChar 1
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l0 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 54
  0022    | ParseNumberStringChar 2
  0024    | JumpIfFailure 24 -> 37
  0027    | MatchWindowEnter 2 fail->36
  0031    | MatchScrutinee r0
  0033    | MatchBind l1 r0
  0036    | MatchWindowExit
  0037    | TakeRight 37 -> 54
  0040    | GetConstantMutable 0: {_0_, _1_}
  0042    | PushString "a"
  0044    | GetLocalMove l0
  0046    | InsertKeyVal 0
  0048    | PushString "b"
  0050    | GetLocalMove l1
  0052    | InsertKeyVal 1
  0054    | End
  ========================================

  $ possum -p 'const({"a": 1 + 2 + 3})' -i '12'
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1 + 2 + 3})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {"a": 6}
  0004    | CallTailFunction 1
  0006    | End
  ========================================

  $ possum -p 'const({"a": [{"b": "foo"}]})' -i '12'
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": [{"b": "foo"}]})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstantMutable 1: {_0_}
  0004    | PushString "a"
  0006    | GetConstantMutable 2: [_]
  0008    | GetConstant 3: {"b": "foo"}
  0010    | InsertAtIndex 0
  0012    | InsertKeyVal 0
  0014    | CallTailFunction 1
  0016    | End
  ========================================

  $ possum -p '"" $ "%(1 + 1)"' -i ''
  
  ================2:@main=================
  "" $ "%(1 + 1)"
  ========================================
  0000    | PushEmptyString
  0001    | PushInteger 2
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p 'Obj.Put(O, K, V) = {...O, K: V} ; 1' -i '1'
  
  ===============2:Obj.Put================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | JumpIfFailure 1 -> 7
  0004    | GetLocalMove l0
  0006    | Merge
  0007    | JumpIfFailure 7 -> 19
  0010    | GetConstantMutable 0: {_0_}
  0012    | GetLocalMove l1
  0014    | GetLocalMove l2
  0016    | InsertKeyVal 0
  0018    | Merge
  0019    | End
  ========================================
  
  ================2:@main=================
  1
  ========================================
  0000    | ParseNumberStringChar 1
  0002    | End
  ========================================

  $ possum -p '_Toml.Doc.Empty = {"value": {}, "type": {}} ; 1' -i '1'
  
  ===========2:_Toml.Doc.Empty============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant 0: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  ================2:@main=================
  1
  ========================================
  0000    | ParseNumberStringChar 1
  0002    | End
  ========================================

  $ possum -p '"" $ (1 ? 2 : 3)' -i ''
  
  ================2:@main=================
  "" $ (1 ? 2 : 3)
  ========================================
  0000    | SetInputMark
  0001    | PushInteger 1
  0003    | ConditionalThen 3 -> 11
  0006    | PushInteger 2
  0008    | Jump 8 -> 13
  0011    | PushInteger 3
  0013    | End
  ========================================

  $ possum -p '"" $ [1 ? 2 : 3]' -i ''
  
  ================2:@main=================
  "" $ [1 ? 2 : 3]
  ========================================
  0000    | GetConstantMutable 0: [_]
  0002    | SetInputMark
  0003    | PushInteger 1
  0005    | ConditionalThen 5 -> 13
  0008    | PushInteger 2
  0010    | Jump 10 -> 15
  0013    | PushInteger 3
  0015    | InsertAtIndex 0
  0017    | End
  ========================================

  $ possum -p 'X = 1 ; "" $ [1, -X, 3]' -i ''
  
  ================2:@main=================
  "" $ [1, -X, 3]
  ========================================
  0000    | GetConstant 0: [1, -1, 3]
  0002    | End
  ========================================

  $ possum -p 'Inc(N) = N + 1 ; "" $ [1, -Inc(1), 3]' -i ''
  
  =================2:Inc==================
  Inc(N) = N + 1
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 8
  0005    | PushInteger 1
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  "" $ [1, -Inc(1), 3]
  ========================================
  0000    | GetConstantMutable 0: [1, _, 3]
  0002    | GetConstant 1: Inc
  0004    | PushInteger 1
  0006    | CallFunction 1
  0008    | NegateNumber
  0009    | InsertAtIndex 1
  0011    | End
  ========================================

  $ possum -p '"ab" * 3' -i 'ababab'
  
  ================2:@main=================
  "ab" * 3
  ========================================
  0000    | PushNull
  0001    | PushInteger 3
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | CallFunctionConstant 0: "ab"
  0010    | Merge
  0011    | JumpIfFailure 11 -> 22
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 23
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | Drop
  0024    | End
  ========================================

  $ possum -p '2 * (2 * 2)' -i '2222'
  
  ================2:@main=================
  2 * (2 * 2)
  ========================================
  0000    | PushNull
  0001    | PushInteger 4
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | ParseNumberStringChar 2
  0010    | Merge
  0011    | JumpIfFailure 11 -> 22
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 23
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | Drop
  0024    | End
  ========================================

  $ possum -p 'A = B ; B = C ; C = 1 ; "" $ A' -i ''
  
  ================2:@main=================
  "" $ A
  ========================================
  0000    | PushInteger 1
  0002    | End
  ========================================

  $ possum -p 'A = 1 ; "" $ [A]' -i ''
  
  ================2:@main=================
  "" $ [A]
  ========================================
  0000    | GetConstant 0: [1]
  0002    | End
  ========================================

  $ possum -p 'Foo(X) = X ; A = [Foo] ; "" $ [A]' -i ''
  
  =================2:Foo==================
  Foo(X) = X
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ==================2:A===================
  A = [Foo]
  ========================================
  0000    | GetConstantMutable 0: [_]
  0002    | GetConstant 1: Foo
  0004    | InsertAtIndex 0
  0006    | End
  ========================================
  
  ================2:@main=================
  "" $ [A]
  ========================================
  0000    | GetConstantMutable 2: [_]
  0002    | CallFunctionConstant 3: A
  0004    | InsertAtIndex 0
  0006    | End
  ========================================

