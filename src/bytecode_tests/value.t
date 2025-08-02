  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '"" $ [1, 2, [1+1+1]]' -i ''
  
  =================@main==================
  "" $ [1, 2, [1+1+1]]
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 23
  0007    | GetConstant 1: [1, 2, _]
  0009    | GetConstant 2: [_]
  0011    | GetConstant 3: 1
  0013    | GetConstant 4: 1
  0015    | Merge
  0016    | GetConstant 5: 1
  0018    | Merge
  0019    | InsertAtIndex 0
  0021    | InsertAtIndex 2
  0023    | End
  ========================================

  $ possum -p '1 -> A $ A' -i ''
  
  =================@main==================
  1 -> A $ A
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | CallFunction 0
  0006    | Destructure 0: A
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 0
  0013    | End
  ========================================

  $ possum -p '1 -> A $ [A]' -i ''
  
  =================@main==================
  1 -> A $ [A]
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | CallFunction 0
  0006    | Destructure 0: A
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 2: [_]
  0013    | GetBoundLocal 0
  0015    | InsertAtIndex 0
  0017    | End
  ========================================

  $ possum -p '2 -> A $ [1, [2]]' -i ''
  
  =================@main==================
  2 -> A $ [1, [2]]
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 2
  0004    | CallFunction 0
  0006    | Destructure 0: A
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 2: [1, _]
  0013    | GetConstant 3: [2]
  0015    | InsertAtIndex 1
  0017    | End
  ========================================

  $ possum -p 'Foo = 1 + 1 ; "" $ [Foo]' -i ''
  
  ==================Foo===================
  Foo = 1 + 1
  ========================================
  0000    | GetConstant 0: 1
  0002    | GetConstant 1: 1
  0004    | Merge
  0005    | End
  ========================================
  
  =================@main==================
  "" $ [Foo]
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: [_]
  0009    | GetConstant 2: Foo
  0011    | CallFunction 0
  0013    | InsertAtIndex 0
  0015    | End
  ========================================

  $ possum -p '1 -> A $ [[A]]' -i ''
  
  =================@main==================
  1 -> A $ [[A]]
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | CallFunction 0
  0006    | Destructure 0: A
  0008    | TakeRight 8 -> 21
  0011    | GetConstant 2: [_]
  0013    | GetConstant 3: [_]
  0015    | GetBoundLocal 0
  0017    | InsertAtIndex 0
  0019    | InsertAtIndex 0
  0021    | End
  ========================================

  $ possum -p 'Foo = 1 -> A & A + A ; "" $ [Foo]' -i ''
  
  ==================Foo===================
  Foo = 1 -> A & A + A
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | Destructure 0: A
  0006    | TakeRight 6 -> 14
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 0
  0013    | Merge
  0014    | End
  ========================================
  
  =================@main==================
  "" $ [Foo]
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: [_]
  0009    | GetConstant 2: Foo
  0011    | CallFunction 0
  0013    | InsertAtIndex 0
  0015    | End
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
  0000    | GetConstant 0: const
  0002    | GetConstant 1: []
  0004    | GetConstant 2: A
  0006    | CallFunction 0
  0008    | Merge
  0009    | GetConstant 3: A
  0011    | CallFunction 0
  0013    | Merge
  0014    | CallFunction 1
  0016    | End
  ========================================

  $ possum -p '1 -> A & 2 -> B $ {"a": A, "b": B}' -i '12'
  
  =================@main==================
  1 -> A & 2 -> B $ {"a": A, "b": B}
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: 1
  0006    | CallFunction 0
  0008    | Destructure 0: A
  0010    | TakeRight 10 -> 32
  0013    | GetConstant 3: 2
  0015    | CallFunction 0
  0017    | Destructure 1: B
  0019    | TakeRight 19 -> 32
  0022    | GetConstant 4: {}
  0024    | GetBoundLocal 0
  0026    | InsertAtKey 5: "a"
  0028    | GetBoundLocal 1
  0030    | InsertAtKey 6: "b"
  0032    | End
  ========================================

  $ possum -p 'const({"a": 1 + 2 + 3})' -i '12'
  
  =================@main==================
  const({"a": 1 + 2 + 3})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {}
  0004    | GetConstant 3: 1
  0006    | GetConstant 4: 2
  0008    | Merge
  0009    | GetConstant 5: 3
  0011    | Merge
  0012    | InsertAtKey 2: "a"
  0014    | CallFunction 1
  0016    | End
  ========================================

  $ possum -p 'const({"a": [{"b": "foo"}]})' -i '12'
  
  =================@main==================
  const({"a": [{"b": "foo"}]})
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {}
  0004    | GetConstant 3: [_]
  0006    | GetConstant 4: {"b": "foo"}
  0008    | InsertAtIndex 0
  0010    | InsertAtKey 2: "a"
  0012    | CallFunction 1
  0014    | End
  ========================================

  $ possum -p '"" $ "%(1 + 1)"' -i ''
  
  =================@main==================
  "" $ "%(1 + 1)"
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: ""
  0009    | GetConstant 2: 1
  0011    | GetConstant 3: 1
  0013    | Merge
  0014    | MergeAsString
  0015    | End
  ========================================

  $ possum -p 'Obj.Put(O, K, V) = {...O, K: V} ; 1' -i '1'
  
  ================Obj.Put=================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | GetConstant 0: {}
  0002    | GetBoundLocal 0
  0004    | Merge
  0005    | GetConstant 1: {_0_}
  0007    | GetBoundLocal 1
  0009    | GetBoundLocal 2
  0011    | InsertKeyVal 0
  0013    | Merge
  0014    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
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
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p '"" $ (1 ? 2 : 3)' -i ''
  
  =================@main==================
  "" $ (1 ? 2 : 3)
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 20
  0007    | SetInputMark
  0008    | GetConstant 1: 1
  0010    | ConditionalThen 10 -> 18
  0013    | GetConstant 2: 2
  0015    | ConditionalElse 15 -> 20
  0018    | GetConstant 3: 3
  0020    | End
  ========================================

  $ possum -p '"" $ [1 ? 2 : 3]' -i ''
  
  =================@main==================
  "" $ [1 ? 2 : 3]
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 24
  0007    | GetConstant 1: [_]
  0009    | SetInputMark
  0010    | GetConstant 2: 1
  0012    | ConditionalThen 12 -> 20
  0015    | GetConstant 3: 2
  0017    | ConditionalElse 17 -> 22
  0020    | GetConstant 4: 3
  0022    | InsertAtIndex 0
  0024    | End
  ========================================

  $ possum -p 'X = 1 ; "" $ [1, -X, 3]' -i ''
  
  =================@main==================
  "" $ [1, -X, 3]
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 14
  0007    | GetConstant 1: [1, _, 3]
  0009    | GetConstant 2: 1
  0011    | NegateNumber
  0012    | InsertAtIndex 1
  0014    | End
  ========================================
