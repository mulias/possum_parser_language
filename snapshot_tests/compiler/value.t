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
  0004    | DestructurePlan 0: bind A
  0006    | TakeRight 6 -> 11
  0009    | GetLocalMove 0
  0011    | End
  ========================================

  $ possum -p '1 -> A $ [A]' -i ''
  
  ================2:@main=================
  1 -> A $ [A]
  ========================================
  0000    | PushVar A
  0002    | ParseNumberStringChar 1
  0004    | DestructurePlan 0: bind A
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 0: [_]
  0011    | GetLocalMove 0
  0013    | InsertAtIndex 0
  0015    | End
  ========================================

  $ possum -p '2 -> A $ [1, [2]]' -i ''
  
  ================2:@main=================
  2 -> A $ [1, [2]]
  ========================================
  0000    | PushVar A
  0002    | ParseNumberStringChar 2
  0004    | DestructurePlan 0: bind A
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 0: [1, _]
  0011    | GetConstant 1: [2]
  0013    | InsertAtIndex 1
  0015    | End
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
  0004    | DestructurePlan 0: bind A
  0006    | TakeRight 6 -> 19
  0009    | GetConstantMutable 0: [_]
  0011    | GetConstantMutable 1: [_]
  0013    | GetLocalMove 0
  0015    | InsertAtIndex 0
  0017    | InsertAtIndex 0
  0019    | End
  ========================================

  $ possum -p 'Foo = 1 -> A & A + A ; "" $ [Foo]' -i ''
  
  =================2:Foo==================
  Foo = 1 -> A & A + A
  ========================================
  0000    | PushVar A
  0002    | PushInteger 1
  0004    | DestructurePlan 0: bind A
  0006    | TakeRight 6 -> 17
  0009    | GetLocal 0
  0011    | JumpIfFailure 11 -> 17
  0014    | GetLocalMove 0
  0016    | Merge
  0017    | End
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
  
  ================5:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
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
  0006    | DestructurePlan 0: bind A
  0008    | TakeRight 8 -> 32
  0011    | ParseNumberStringChar 2
  0013    | DestructurePlan 1: bind B
  0015    | TakeRight 15 -> 32
  0018    | GetConstantMutable 0: {_0_, _1_}
  0020    | PushString "a"
  0022    | GetLocalMove 0
  0024    | InsertKeyVal 0
  0026    | PushString "b"
  0028    | GetLocalMove 1
  0030    | InsertKeyVal 1
  0032    | End
  ========================================

  $ possum -p 'const({"a": 1 + 2 + 3})' -i '12'
  
  ================5:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
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
  
  ================5:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
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
  0000    | GetConstantMutable 0: [1, _, 3]
  0002    | PushInteger 1
  0004    | NegateNumber
  0005    | InsertAtIndex 1
  0007    | End
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
  0000    | GetLocalMove 0
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

