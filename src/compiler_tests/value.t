  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '"" $ [1, 2, [1+1+1]]' -i ''
  
  =================@main==================
  "" $ [1, 2, [1+1+1]]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 10
  0004    | GetConstant 0: [1, 2, _]
  0006    | GetConstant 1: [3]
  0008    | InsertAtIndex 2
  0010    | End
  ========================================

  $ possum -p '1 -> A $ A' -i ''
  
  =================@main==================
  1 -> A $ A
  ========================================
  0000    | PushCharVar A
  0002    | ParseOne
  0003    | Destructure 0: A
  0005    | TakeRight 5 -> 10
  0008    | GetBoundLocal 0
  0010    | End
  ========================================

  $ possum -p '1 -> A $ [A]' -i ''
  
  =================@main==================
  1 -> A $ [A]
  ========================================
  0000    | PushCharVar A
  0002    | ParseOne
  0003    | Destructure 0: A
  0005    | TakeRight 5 -> 14
  0008    | GetConstant 0: [_]
  0010    | GetBoundLocal 0
  0012    | InsertAtIndex 0
  0014    | End
  ========================================

  $ possum -p '2 -> A $ [1, [2]]' -i ''
  
  =================@main==================
  2 -> A $ [1, [2]]
  ========================================
  0000    | PushCharVar A
  0002    | ParseTwo
  0003    | Destructure 0: A
  0005    | TakeRight 5 -> 14
  0008    | GetConstant 0: [1, _]
  0010    | GetConstant 1: [2]
  0012    | InsertAtIndex 1
  0014    | End
  ========================================

  $ possum -p 'Foo = 1 + 1 ; "" $ [Foo]' -i ''
  
  =================@main==================
  "" $ [Foo]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 6
  0004    | GetConstant 0: [2]
  0006    | End
  ========================================

  $ possum -p '1 -> A $ [[A]]' -i ''
  
  =================@main==================
  1 -> A $ [[A]]
  ========================================
  0000    | PushCharVar A
  0002    | ParseOne
  0003    | Destructure 0: A
  0005    | TakeRight 5 -> 18
  0008    | GetConstant 0: [_]
  0010    | GetConstant 1: [_]
  0012    | GetBoundLocal 0
  0014    | InsertAtIndex 0
  0016    | InsertAtIndex 0
  0018    | End
  ========================================

  $ possum -p 'Foo = 1 -> A & A + A ; "" $ [Foo]' -i ''
  
  ==================Foo===================
  Foo = 1 -> A & A + A
  ========================================
  0000    | PushCharVar A
  0002    | PushNumberOne
  0003    | Destructure 0: A
  0005    | TakeRight 5 -> 13
  0008    | GetBoundLocal 0
  0010    | GetBoundLocal 0
  0012    | Merge
  0013    | End
  ========================================
  
  =================@main==================
  "" $ [Foo]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 12
  0004    | GetConstant 0: [_]
  0006    | GetConstant 1: Foo
  0008    | CallFunction 0
  0010    | InsertAtIndex 0
  0012    | End
  ========================================

  $ possum -p 'A = [1,2,3] ; const([...A, ...A])' -i ''
  
  ===================A====================
  A = [1,2,3]
  ========================================
  0000    | GetConstant 0: [1, 2, 3]
  0002    | End
  ========================================
  
  =================@main==================
  const([...A, ...A])
  ========================================
  0000    | GetConstant 1: const
  0002    | PushEmptyArray
  0003    | GetConstant 2: A
  0005    | CallFunction 0
  0007    | Merge
  0008    | GetConstant 2: A
  0010    | CallFunction 0
  0012    | Merge
  0013    | CallFunction 1
  0015    | End
  ========================================

  $ possum -p '1 -> A & 2 -> B $ {"a": A, "b": B}' -i '12'
  
  =================@main==================
  1 -> A & 2 -> B $ {"a": A, "b": B}
  ========================================
  0000    | PushCharVar A
  0002    | PushCharVar B
  0004    | ParseOne
  0005    | Destructure 0: A
  0007    | TakeRight 7 -> 30
  0010    | ParseTwo
  0011    | Destructure 1: B
  0013    | TakeRight 13 -> 30
  0016    | GetConstant 0: {_0_, _1_}
  0018    | PushChar 'a'
  0020    | GetBoundLocal 0
  0022    | InsertKeyVal 0
  0024    | PushChar 'b'
  0026    | GetBoundLocal 1
  0028    | InsertKeyVal 1
  0030    | End
  ========================================

  $ possum -p 'const({"a": 1 + 2 + 3})' -i '12'
  
  =================@main==================
  const({"a": 1 + 2 + 3})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {"a": 6}
  0004    | CallFunction 1
  0006    | End
  ========================================

  $ possum -p 'const({"a": [{"b": "foo"}]})' -i '12'
  
  =================@main==================
  const({"a": [{"b": "foo"}]})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {_0_}
  0004    | PushChar 'a'
  0006    | GetConstant 2: [_]
  0008    | GetConstant 3: {"b": "foo"}
  0010    | InsertAtIndex 0
  0012    | InsertKeyVal 0
  0014    | CallFunction 1
  0016    | End
  ========================================

  $ possum -p '"" $ "%(1 + 1)"' -i ''
  
  =================@main==================
  "" $ "%(1 + 1)"
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 7
  0004    | PushEmptyString
  0005    | PushNumberTwo
  0006    | MergeAsString
  0007    | End
  ========================================

  $ possum -p 'Obj.Put(O, K, V) = {...O, K: V} ; 1' -i '1'
  
  ================Obj.Put=================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | GetBoundLocal 0
  0003    | Merge
  0004    | GetConstant 0: {_0_}
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | InsertKeyVal 0
  0012    | Merge
  0013    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | ParseOne
  0001    | End
  ========================================

  $ possum -p '_Toml.Doc.Empty = {"value": {}, "type": {}} ; 1' -i '1'
  
  ============_Toml.Doc.Empty=============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant 0: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | ParseOne
  0001    | End
  ========================================

  $ possum -p '"" $ (1 ? 2 : 3)' -i ''
  
  =================@main==================
  "" $ (1 ? 2 : 3)
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 14
  0004    | SetInputMark
  0005    | PushNumberOne
  0006    | ConditionalThen 6 -> 13
  0009    | PushNumberTwo
  0010    | Jump 10 -> 14
  0013    | PushNumberThree
  0014    | End
  ========================================

  $ possum -p '"" $ [1 ? 2 : 3]' -i ''
  
  =================@main==================
  "" $ [1 ? 2 : 3]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 18
  0004    | GetConstant 0: [_]
  0006    | SetInputMark
  0007    | PushNumberOne
  0008    | ConditionalThen 8 -> 15
  0011    | PushNumberTwo
  0012    | Jump 12 -> 16
  0015    | PushNumberThree
  0016    | InsertAtIndex 0
  0018    | End
  ========================================

  $ possum -p 'X = 1 ; "" $ [1, -X, 3]' -i ''
  
  =================@main==================
  "" $ [1, -X, 3]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 10
  0004    | GetConstant 0: [1, _, 3]
  0006    | PushNumberOne
  0007    | NegateNumber
  0008    | InsertAtIndex 1
  0010    | End
  ========================================

  $ possum -p '"ab" * 3' -i 'ababab'
  
  =================@main==================
  "ab" * 3
  ========================================
  0000    | PushNull
  0001    | PushNumberThree
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 24
  0006    | Swap
  0007    | GetConstant 0: "ab"
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 23
  0015    | Swap
  0016    | Decrement
  0017    | JumpIfZero 17 -> 24
  0020    | JumpBack 20 -> 6
  0023    | Swap
  0024    | Drop
  0025    | End
  ========================================

  $ possum -p '2 * (2 * 2)' -i '2222'
  
  =================@main==================
  2 * (2 * 2)
  ========================================
  0000    | PushNull
  0001    | PushNumber 4
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | ParseTwo
  0009    | Merge
  0010    | JumpIfFailure 10 -> 21
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 22
  0018    | JumpBack 18 -> 7
  0021    | Swap
  0022    | Drop
  0023    | End
  ========================================

  $ possum -p 'A = B ; B = C ; C = 1 ; "" $ A' -i ''
  
  =================@main==================
  "" $ A
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 5
  0004    | PushNumberOne
  0005    | End
  ========================================

  $ possum -p 'A = 1 ; "" $ [A]' -i ''
  
  =================@main==================
  "" $ [A]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 6
  0004    | GetConstant 0: [1]
  0006    | End
  ========================================

  $ possum -p 'Foo(X) = X ; A = [Foo] ; "" $ [A]' -i ''
  
  ==================Foo===================
  Foo(X) = X
  ========================================
  0000    | GetBoundLocal 0
  0002    | End
  ========================================
  
  ===================A====================
  A = [Foo]
  ========================================
  0000    | GetConstant 0: [_]
  0002    | GetConstant 1: Foo
  0004    | InsertAtIndex 0
  0006    | End
  ========================================
  
  =================@main==================
  "" $ [A]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 12
  0004    | GetConstant 2: [_]
  0006    | GetConstant 3: A
  0008    | CallFunction 0
  0010    | InsertAtIndex 0
  0012    | End
  ========================================

