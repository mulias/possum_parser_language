  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'const([1,2,3]) -> [A,B,C]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: C
  0006    | GetConstant 3: const
  0008    | GetConstant 4: [1, 2, 3]
  0010    | CallFunction 1
  0012    | GetConstant 5: [_, _, _]
  0014    | Destructure
  0015    | GetAtIndex 0
  0017    | GetLocal 0
  0019    | Destructure
  0020    | Pop
  0021    | GetAtIndex 1
  0023    | GetLocal 1
  0025    | Destructure
  0026    | Pop
  0027    | GetAtIndex 2
  0029    | GetLocal 2
  0031    | Destructure
  0032    | Pop
  0033    | End
  ========================================

  $ possum -p 'A = 1 ; const([1,2,3]) -> [A,B,C]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: B
  0002    | GetConstant 1: C
  0004    | GetConstant 2: const
  0006    | GetConstant 3: [1, 2, 3]
  0008    | CallFunction 1
  0010    | GetConstant 4: [_, _, _]
  0012    | Destructure
  0013    | GetAtIndex 0
  0015    | GetConstant 5: 1
  0017    | Destructure
  0018    | Pop
  0019    | GetAtIndex 1
  0021    | GetLocal 0
  0023    | Destructure
  0024    | Pop
  0025    | GetAtIndex 2
  0027    | GetLocal 1
  0029    | Destructure
  0030    | Pop
  0031    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 2, 3]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | GetConstant 3: [_, 2, 3]
  0010    | Destructure
  0011    | GetAtIndex 0
  0013    | GetLocal 0
  0015    | Destructure
  0016    | Pop
  0017    | End
  ========================================

  $ possum -p 'const([1,[[2],3]]) -> [A, [[B], 3]] $ B' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: const
  0006    | GetConstant 3: [1, _]
  0008    | GetConstant 4: [_, 3]
  0010    | GetConstant 5: [2]
  0012    | InsertAtIndex 0
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | GetConstant 6: [_, _]
  0020    | Destructure
  0021    | GetAtIndex 0
  0023    | GetLocal 0
  0025    | Destructure
  0026    | Pop
  0027    | GetAtIndex 1
  0029    | GetConstant 7: [_, 3]
  0031    | Destructure
  0032    | GetAtIndex 0
  0034    | GetConstant 8: [_]
  0036    | Destructure
  0037    | GetAtIndex 0
  0039    | GetLocal 1
  0041    | Destructure
  0042    | Pop
  0043    | Pop
  0044    | Pop
  0045    | TakeRight 45 -> 50
  0048    | GetBoundLocal 1
  0050    | End
  ========================================

