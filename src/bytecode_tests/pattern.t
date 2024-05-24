  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'const([1,2,3]) -> [A,B,C]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: C
  0006    | GetConstant 3: const
  0008    | GetConstant 4: [1, 2, 3]
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 45
  0015    | GetConstant 5: [_, _, _]
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 45
  0021    | GetAtIndex 0
  0023    | GetLocal 0
  0025    | Destructure
  0026    | Pop
  0027    | JumpIfFailure 27 -> 45
  0030    | GetAtIndex 1
  0032    | GetLocal 1
  0034    | Destructure
  0035    | Pop
  0036    | JumpIfFailure 36 -> 45
  0039    | GetAtIndex 2
  0041    | GetLocal 2
  0043    | Destructure
  0044    | Pop
  0045    | End
  ========================================

  $ possum -p 'A = 1 ; const([1,2,3]) -> [A,B,C]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: B
  0002    | GetConstant 1: C
  0004    | GetConstant 2: const
  0006    | GetConstant 3: [1, 2, 3]
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 43
  0013    | GetConstant 4: [_, _, _]
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 43
  0019    | GetAtIndex 0
  0021    | GetConstant 5: 1
  0023    | Destructure
  0024    | Pop
  0025    | JumpIfFailure 25 -> 43
  0028    | GetAtIndex 1
  0030    | GetLocal 0
  0032    | Destructure
  0033    | Pop
  0034    | JumpIfFailure 34 -> 43
  0037    | GetAtIndex 2
  0039    | GetLocal 1
  0041    | Destructure
  0042    | Pop
  0043    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 2, 3]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 23
  0011    | GetConstant 3: [_, 2, 3]
  0013    | Destructure
  0014    | JumpIfFailure 14 -> 23
  0017    | GetAtIndex 0
  0019    | GetLocal 0
  0021    | Destructure
  0022    | Pop
  0023    | End
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
  0018    | JumpIfFailure 18 -> 66
  0021    | GetConstant 6: [_, _]
  0023    | Destructure
  0024    | JumpIfFailure 24 -> 66
  0027    | GetAtIndex 0
  0029    | GetLocal 0
  0031    | Destructure
  0032    | Pop
  0033    | JumpIfFailure 33 -> 66
  0036    | GetAtIndex 1
  0038    | JumpIfFailure 38 -> 65
  0041    | GetConstant 7: [_, 3]
  0043    | Destructure
  0044    | JumpIfFailure 44 -> 65
  0047    | GetAtIndex 0
  0049    | JumpIfFailure 49 -> 64
  0052    | GetConstant 8: [_]
  0054    | Destructure
  0055    | JumpIfFailure 55 -> 64
  0058    | GetAtIndex 0
  0060    | GetLocal 1
  0062    | Destructure
  0063    | Pop
  0064    | Pop
  0065    | Pop
  0066    | TakeRight 66 -> 71
  0069    | GetBoundLocal 1
  0071    | End
  ========================================

