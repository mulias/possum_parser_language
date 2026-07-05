  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '"" $ [1, 2, [1+1+1]]' -i ''
  
  =================@main==================
  "" $ [1, 2, [1+1+1]]
  ========================================
  0000    | GetConstantMutable 0: [1, 2, _]
  0002    | GetConstant 1: [3]
  0004    | InsertAtIndex 2
  0006    | End
  ========================================

  $ possum -p '1 -> A $ A' -i ''
  
  =================@main==================
  1 -> A $ A
  ========================================
  0000    | PushVar2 A
  0003    | ParseOne
  0004    | Destructure 0: A
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
  ========================================

  $ possum -p '1 -> A $ [A]' -i ''
  
  =================@main==================
  1 -> A $ [A]
  ========================================
  0000    | PushVar2 A
  0003    | ParseOne
  0004    | Destructure 0: A
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 0: [_]
  0011    | GetBoundLocalMove 0
  0013    | InsertAtIndex 0
  0015    | End
  ========================================

  $ possum -p '2 -> A $ [1, [2]]' -i ''
  
  =================@main==================
  2 -> A $ [1, [2]]
  ========================================
  0000    | PushVar2 A
  0003    | ParseTwo
  0004    | Destructure 0: A
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 0: [1, _]
  0011    | GetConstant 1: [2]
  0013    | InsertAtIndex 1
  0015    | End
  ========================================

  $ possum -p 'Foo = 1 + 1 ; "" $ [Foo]' -i ''
  
  =================@main==================
  "" $ [Foo]
  ========================================
  0000    | GetConstant 0: [2]
  0002    | End
  ========================================

  $ possum -p '1 -> A $ [[A]]' -i ''
  
  =================@main==================
  1 -> A $ [[A]]
  ========================================
  0000    | PushVar2 A
  0003    | ParseOne
  0004    | Destructure 0: A
  0006    | TakeRight 6 -> 19
  0009    | GetConstantMutable 0: [_]
  0011    | GetConstantMutable 1: [_]
  0013    | GetBoundLocalMove 0
  0015    | InsertAtIndex 0
  0017    | InsertAtIndex 0
  0019    | End
  ========================================

  $ possum -p 'Foo = 1 -> A & A + A ; "" $ [Foo]' -i ''
  
  ==================Foo===================
  Foo = 1 -> A & A + A
  ========================================
  0000    | PushVar2 A
  0003    | PushInteger 1
  0005    | Destructure 0: A
  0007    | TakeRight 7 -> 18
  0010    | GetBoundLocal 0
  0012    | JumpIfFailure 12 -> 18
  0015    | GetBoundLocalMove 0
  0017    | Merge
  0018    | End
  ========================================
  
  =================@main==================
  "" $ [Foo]
  ========================================
  0000    | GetConstantMutable 0: [_]
  0002    | CallFunctionConstant 1: Foo
  0004    | InsertAtIndex 0
  0006    | End
  ========================================

  $ possum -p 'A = [1,2,3] ; const([...A, ...A])' -i ''
  
  ===================A====================
  A = [1,2,3]
  ========================================
  0000    | GetConstant 0: [1, 2, 3]
  0002    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
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
  
  =================@main==================
  1 -> A & 2 -> B $ {"a": A, "b": B}
  ========================================
  0000    | PushVar2 A
  0003    | PushVar2 B
  0006    | ParseOne
  0007    | Destructure 0: A
  0009    | TakeRight 9 -> 34
  0012    | ParseTwo
  0013    | Destructure 1: B
  0015    | TakeRight 15 -> 34
  0018    | GetConstantMutable 0: {_0_, _1_}
  0020    | PushString2 "a"
  0023    | GetBoundLocalMove 0
  0025    | InsertKeyVal 0
  0027    | PushString2 "b"
  0030    | GetBoundLocalMove 1
  0032    | InsertKeyVal 1
  0034    | End
  ========================================

  $ possum -p 'const({"a": 1 + 2 + 3})' -i '12'
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1 + 2 + 3})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {"a": 6}
  0004    | CallTailFunction 1
  0006    | End
  ========================================

  $ possum -p 'const({"a": [{"b": "foo"}]})' -i '12'
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": [{"b": "foo"}]})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstantMutable 1: {_0_}
  0004    | PushString2 "a"
  0007    | GetConstantMutable 2: [_]
  0009    | GetConstant 3: {"b": "foo"}
  0011    | InsertAtIndex 0
  0013    | InsertKeyVal 0
  0015    | CallTailFunction 1
  0017    | End
  ========================================

  $ possum -p '"" $ "%(1 + 1)"' -i ''
  
  =================@main==================
  "" $ "%(1 + 1)"
  ========================================
  0000    | PushEmptyString
  0001    | PushInteger 2
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p 'Obj.Put(O, K, V) = {...O, K: V} ; 1' -i '1'
  
  ================Obj.Put=================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | JumpIfFailure 1 -> 7
  0004    | GetBoundLocalMove 0
  0006    | Merge
  0007    | JumpIfFailure 7 -> 19
  0010    | GetConstantMutable 0: {_0_}
  0012    | GetBoundLocalMove 1
  0014    | GetBoundLocalMove 2
  0016    | InsertKeyVal 0
  0018    | Merge
  0019    | End
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
  0000    | SetInputMark
  0001    | PushInteger 1
  0003    | ConditionalThen 3 -> 11
  0006    | PushInteger 2
  0008    | Jump 8 -> 13
  0011    | PushInteger 3
  0013    | End
  ========================================

  $ possum -p '"" $ [1 ? 2 : 3]' -i ''
  
  =================@main==================
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
  
  =================@main==================
  "" $ [1, -X, 3]
  ========================================
  0000    | GetConstantMutable 0: [1, _, 3]
  0002    | PushInteger 1
  0004    | NegateNumber
  0005    | InsertAtIndex 1
  0007    | End
  ========================================

  $ possum -p '"ab" * 3' -i 'ababab'
  
  =================@main==================
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
  
  =================@main==================
  2 * (2 * 2)
  ========================================
  0000    | PushNull
  0001    | PushInteger 4
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
  0000    | PushInteger 1
  0002    | End
  ========================================

  $ possum -p 'A = 1 ; "" $ [A]' -i ''
  
  =================@main==================
  "" $ [A]
  ========================================
  0000    | GetConstant 0: [1]
  0002    | End
  ========================================

  $ possum -p 'Foo(X) = X ; A = [Foo] ; "" $ [A]' -i ''
  
  ==================Foo===================
  Foo(X) = X
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  ===================A====================
  A = [Foo]
  ========================================
  0000    | GetConstantMutable 0: [_]
  0002    | GetConstant 1: Foo
  0004    | InsertAtIndex 0
  0006    | End
  ========================================
  
  =================@main==================
  "" $ [A]
  ========================================
  0000    | GetConstantMutable 2: [_]
  0002    | CallFunctionConstant 3: A
  0004    | InsertAtIndex 0
  0006    | End
  ========================================

