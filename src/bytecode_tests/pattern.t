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
  0015    | JumpIfFailure 15 -> 50
  0018    | GetAtIndex 0
  0020    | GetLocal 0
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 48
  0026    | Pop
  0027    | GetAtIndex 1
  0029    | GetLocal 1
  0031    | Destructure
  0032    | JumpIfFailure 32 -> 48
  0035    | Pop
  0036    | GetAtIndex 2
  0038    | GetLocal 2
  0040    | Destructure
  0041    | JumpIfFailure 41 -> 48
  0044    | Pop
  0045    | JumpIfSuccess 45 -> 50
  0048    | Swap
  0049    | Pop
  0050    | End
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
  0013    | JumpIfFailure 13 -> 48
  0016    | GetAtIndex 0
  0018    | GetConstant 5: 1
  0020    | Destructure
  0021    | JumpIfFailure 21 -> 46
  0024    | Pop
  0025    | GetAtIndex 1
  0027    | GetLocal 0
  0029    | Destructure
  0030    | JumpIfFailure 30 -> 46
  0033    | Pop
  0034    | GetAtIndex 2
  0036    | GetLocal 1
  0038    | Destructure
  0039    | JumpIfFailure 39 -> 46
  0042    | Pop
  0043    | JumpIfSuccess 43 -> 48
  0046    | Swap
  0047    | Pop
  0048    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 2, 3]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | GetConstant 3: [_, 2, 3]
  0010    | Destructure
  0011    | JumpIfFailure 11 -> 28
  0014    | GetAtIndex 0
  0016    | GetLocal 0
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 26
  0022    | Pop
  0023    | JumpIfSuccess 23 -> 28
  0026    | Swap
  0027    | Pop
  0028    | End
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
  0021    | JumpIfFailure 21 -> 81
  0024    | GetAtIndex 0
  0026    | GetLocal 0
  0028    | Destructure
  0029    | JumpIfFailure 29 -> 79
  0032    | Pop
  0033    | GetAtIndex 1
  0035    | GetConstant 7: [_, 3]
  0037    | Destructure
  0038    | JumpIfFailure 38 -> 72
  0041    | GetAtIndex 0
  0043    | GetConstant 8: [_]
  0045    | Destructure
  0046    | JumpIfFailure 46 -> 63
  0049    | GetAtIndex 0
  0051    | GetLocal 1
  0053    | Destructure
  0054    | JumpIfFailure 54 -> 61
  0057    | Pop
  0058    | JumpIfSuccess 58 -> 63
  0061    | Swap
  0062    | Pop
  0063    | JumpIfFailure 63 -> 70
  0066    | Pop
  0067    | JumpIfSuccess 67 -> 72
  0070    | Swap
  0071    | Pop
  0072    | JumpIfFailure 72 -> 79
  0075    | Pop
  0076    | JumpIfSuccess 76 -> 81
  0079    | Swap
  0080    | Pop
  0081    | TakeRight 81 -> 86
  0084    | GetBoundLocal 1
  0086    | End
  ========================================

