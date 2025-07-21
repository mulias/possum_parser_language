  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '"" $ [1, 2, [1+1+1]]' -i ''
  
  =================@main==================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 29
  0007    | GetConstant 1: [1, 2, _]
  0009    | GetConstant 2: [_]
  0011    | GetConstant 3: 1
  0013    | JumpIfFailure 13 -> 19
  0016    | GetConstant 4: 1
  0018    | Merge
  0019    | JumpIfFailure 19 -> 25
  0022    | GetConstant 5: 1
  0024    | Merge
  0025    | InsertAtIndex 0
  0027    | InsertAtIndex 2
  0029    | End
  ========================================

  $ possum -p '1 -> A $ A' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | CallFunction 0
  0006    | GetLocal 0
  0008    | Destructure
  0009    | TakeRight 9 -> 14
  0012    | GetBoundLocal 0
  0014    | End
  ========================================

  $ possum -p '1 -> A $ [A]' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | CallFunction 0
  0006    | GetLocal 0
  0008    | Destructure
  0009    | TakeRight 9 -> 18
  0012    | GetConstant 2: [_]
  0014    | GetBoundLocal 0
  0016    | InsertAtIndex 0
  0018    | End
  ========================================

  $ possum -p '2 -> A $ [1, [2]]' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 2
  0004    | CallFunction 0
  0006    | GetLocal 0
  0008    | Destructure
  0009    | TakeRight 9 -> 18
  0012    | GetConstant 2: [1, _]
  0014    | GetConstant 3: [2]
  0016    | InsertAtIndex 1
  0018    | End
  ========================================

  $ possum -p 'Foo = 1 + 1 ; "" $ [Foo]' -i ''
  
  ==================Foo===================
  0000    | GetConstant 0: 1
  0002    | JumpIfFailure 2 -> 8
  0005    | GetConstant 1: 1
  0007    | Merge
  0008    | End
  ========================================
  
  =================@main==================
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
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | CallFunction 0
  0006    | GetLocal 0
  0008    | Destructure
  0009    | TakeRight 9 -> 22
  0012    | GetConstant 2: [_]
  0014    | GetConstant 3: [_]
  0016    | GetBoundLocal 0
  0018    | InsertAtIndex 0
  0020    | InsertAtIndex 0
  0022    | End
  ========================================

  $ possum -p 'Foo = 1 -> A & A + A ; "" $ [Foo]' -i ''
  
  ==================Foo===================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: 1
  0004    | GetLocal 0
  0006    | Destructure
  0007    | TakeRight 7 -> 18
  0010    | GetBoundLocal 0
  0012    | JumpIfFailure 12 -> 18
  0015    | GetBoundLocal 0
  0017    | Merge
  0018    | End
  ========================================
  
  =================@main==================
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
  0000    | GetConstant 0: [1, 2, 3]
  0002    | End
  ========================================
  
  =================@main==================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: []
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 2: A
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetConstant 3: A
  0017    | CallFunction 0
  0019    | Merge
  0020    | CallFunction 1
  0022    | End
  ========================================

  $ possum -p '1 -> A & 2 -> B $ {"a": A, "b": B}' -i '12'
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: 1
  0006    | CallFunction 0
  0008    | GetLocal 0
  0010    | Destructure
  0011    | TakeRight 11 -> 34
  0014    | GetConstant 3: 2
  0016    | CallFunction 0
  0018    | GetLocal 1
  0020    | Destructure
  0021    | TakeRight 21 -> 34
  0024    | GetConstant 4: {}
  0026    | GetBoundLocal 0
  0028    | InsertAtKey 5: "a"
  0030    | GetBoundLocal 1
  0032    | InsertAtKey 6: "b"
  0034    | End
  ========================================

  $ possum -p 'const({"a": 1 + 2 + 3})' -i '12'
  
  =================@main==================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {}
  0004    | GetConstant 3: 1
  0006    | JumpIfFailure 6 -> 12
  0009    | GetConstant 4: 2
  0011    | Merge
  0012    | JumpIfFailure 12 -> 18
  0015    | GetConstant 5: 3
  0017    | Merge
  0018    | InsertAtKey 2: "a"
  0020    | CallFunction 1
  0022    | End
  ========================================

  $ possum -p 'const({"a": [{"b": "foo"}]})' -i '12'
  
  =================@main==================
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
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 18
  0007    | GetConstant 1: ""
  0009    | GetConstant 2: 1
  0011    | JumpIfFailure 11 -> 17
  0014    | GetConstant 3: 1
  0016    | Merge
  0017    | MergeAsString
  0018    | End
  ========================================

  $ possum -p 'Obj.Put(O, K, V) = {...O, K: V} ; 1' -i '1'
  
  ================Obj.Put=================
  0000    | GetConstant 0: {}
  0002    | JumpIfFailure 2 -> 8
  0005    | GetBoundLocal 0
  0007    | Merge
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 1: {}
  0013    | GetBoundLocal 1
  0015    | GetBoundLocal 2
  0017    | InsertKeyVal
  0018    | Merge
  0019    | End
  ========================================
  
  =================@main==================
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p '_Toml.Doc.Empty = {"value": {}, "type": {}} ; 1' -i '1'
  
  ============_Toml.Doc.Empty=============
  0000    | GetConstant 0: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  =================@main==================
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
  ========================================
