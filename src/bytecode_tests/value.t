  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '"" $ [1, 2, [1+1+1]]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: ""
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
  0000    1 GetConstant 0: A
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
  0000    1 GetConstant 0: A
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
  0000    1 GetConstant 0: A
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
  0000    1 GetConstant 0: 1
  0002    | JumpIfFailure 2 -> 8
  0005    | GetConstant 1: 1
  0007    | Merge
  0008    | End
  ========================================
  
  =================@main==================
  0000    1 GetConstant 0: ""
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
  0000    1 GetConstant 0: A
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
  0000    1 GetConstant 0: A
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
  0000    1 GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: [_]
  0009    | GetConstant 2: Foo
  0011    | CallFunction 0
  0013    | InsertAtIndex 0
  0015    | End
  ========================================

