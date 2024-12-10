  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'const([1,2,3]) -> [1,2,3]' -i ''
  
  =================@main==================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: [1, 2, 3]
  0004    | CallFunction 1
  0006    | GetConstant 2: [1, 2, 3]
  0008    | Destructure
  0009    | JumpIfFailure 9 -> 17
  0012    | JumpIfSuccess 12 -> 17
  0015    | Swap
  0016    | Pop
  0017    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A,B,C]' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
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
  0000    | GetConstant 0: B
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
  0000    | GetConstant 0: A
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
  0000    | GetConstant 0: A
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

  $ possum -p '3 -> (2 + B)' -i '3'
  
  =================@main==================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: 3
  0004    | CallFunction 0
  0006    | GetConstant 2: 2
  0008    | GetLocal 0
  0010    | PrepareMergePattern 2
  0012    | JumpIfFailure 12 -> 34
  0015    | GetConstant 3: 2
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 32
  0021    | Pop
  0022    | GetLocal 0
  0024    | Destructure
  0025    | JumpIfFailure 25 -> 32
  0028    | Pop
  0029    | JumpIfSuccess 29 -> 34
  0032    | Swap
  0033    | Pop
  0034    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 1 + 1, 3]' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | GetConstant 3: [_, _, 3]
  0010    | Destructure
  0011    | JumpIfFailure 11 -> 62
  0014    | GetAtIndex 0
  0016    | GetLocal 0
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 60
  0022    | Pop
  0023    | GetAtIndex 1
  0025    | GetConstant 4: 1
  0027    | GetConstant 5: 1
  0029    | PrepareMergePattern 2
  0031    | JumpIfFailure 31 -> 53
  0034    | GetConstant 6: 1
  0036    | Destructure
  0037    | JumpIfFailure 37 -> 51
  0040    | Pop
  0041    | GetConstant 7: 1
  0043    | Destructure
  0044    | JumpIfFailure 44 -> 51
  0047    | Pop
  0048    | JumpIfSuccess 48 -> 53
  0051    | Swap
  0052    | Pop
  0053    | JumpIfFailure 53 -> 60
  0056    | Pop
  0057    | JumpIfSuccess 57 -> 62
  0060    | Swap
  0061    | Pop
  0062    | End
  ========================================

  $ possum -p 'const([1,2]) -> ([1] + [2])' -i ''
  
  =================@main==================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: [1, 2]
  0004    | CallFunction 1
  0006    | GetConstant 2: [1]
  0008    | GetConstant 3: [2]
  0010    | PrepareMergePattern 2
  0012    | JumpIfFailure 12 -> 50
  0015    | GetConstant 4: [1]
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 26
  0021    | JumpIfSuccess 21 -> 26
  0024    | Swap
  0025    | Pop
  0026    | JumpIfFailure 26 -> 48
  0029    | Pop
  0030    | GetConstant 5: [2]
  0032    | Destructure
  0033    | JumpIfFailure 33 -> 41
  0036    | JumpIfSuccess 36 -> 41
  0039    | Swap
  0040    | Pop
  0041    | JumpIfFailure 41 -> 48
  0044    | Pop
  0045    | JumpIfSuccess 45 -> 50
  0048    | Swap
  0049    | Pop
  0050    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> ([1] + B + [3])' -i ''
  
  =================@main==================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | GetConstant 3: [1]
  0010    | GetLocal 0
  0012    | GetConstant 4: [3]
  0014    | PrepareMergePattern 3
  0016    | JumpIfFailure 16 -> 61
  0019    | GetConstant 5: [1]
  0021    | Destructure
  0022    | JumpIfFailure 22 -> 30
  0025    | JumpIfSuccess 25 -> 30
  0028    | Swap
  0029    | Pop
  0030    | JumpIfFailure 30 -> 59
  0033    | Pop
  0034    | GetLocal 0
  0036    | Destructure
  0037    | JumpIfFailure 37 -> 59
  0040    | Pop
  0041    | GetConstant 6: [3]
  0043    | Destructure
  0044    | JumpIfFailure 44 -> 52
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | JumpIfFailure 52 -> 59
  0055    | Pop
  0056    | JumpIfSuccess 56 -> 61
  0059    | Swap
  0060    | Pop
  0061    | End
  ========================================

  $ possum -p 'const([1,[2],2,3]) -> ([1,A] + A + [3])' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, _, 2, 3]
  0006    | GetConstant 3: [2]
  0008    | InsertAtIndex 1
  0010    | CallFunction 1
  0012    | GetConstant 4: [1, _]
  0014    | GetLocal 0
  0016    | GetConstant 5: [3]
  0018    | PrepareMergePattern 3
  0020    | JumpIfFailure 20 -> 74
  0023    | GetConstant 6: [1, _]
  0025    | Destructure
  0026    | JumpIfFailure 26 -> 43
  0029    | GetAtIndex 1
  0031    | GetLocal 0
  0033    | Destructure
  0034    | JumpIfFailure 34 -> 41
  0037    | Pop
  0038    | JumpIfSuccess 38 -> 43
  0041    | Swap
  0042    | Pop
  0043    | JumpIfFailure 43 -> 72
  0046    | Pop
  0047    | GetLocal 0
  0049    | Destructure
  0050    | JumpIfFailure 50 -> 72
  0053    | Pop
  0054    | GetConstant 7: [3]
  0056    | Destructure
  0057    | JumpIfFailure 57 -> 65
  0060    | JumpIfSuccess 60 -> 65
  0063    | Swap
  0064    | Pop
  0065    | JumpIfFailure 65 -> 72
  0068    | Pop
  0069    | JumpIfSuccess 69 -> 74
  0072    | Swap
  0073    | Pop
  0074    | End
  ========================================

  $ possum -p '"foobar" -> ("fo" + Ob + "ar") $ Ob' -i ''
  
  =================@main==================
  0000    | GetConstant 0: Ob
  0002    | GetConstant 1: "foobar"
  0004    | CallFunction 0
  0006    | GetConstant 2: "fo"
  0008    | GetLocal 0
  0010    | GetConstant 3: "ar"
  0012    | PrepareMergePattern 3
  0014    | JumpIfFailure 14 -> 43
  0017    | GetConstant 4: "fo"
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 41
  0023    | Pop
  0024    | GetLocal 0
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 41
  0030    | Pop
  0031    | GetConstant 5: "ar"
  0033    | Destructure
  0034    | JumpIfFailure 34 -> 41
  0037    | Pop
  0038    | JumpIfSuccess 38 -> 43
  0041    | Swap
  0042    | Pop
  0043    | TakeRight 43 -> 48
  0046    | GetBoundLocal 0
  0048    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [1, ...Rest] $ Rest' -i ''
  
  =================@main==================
  0000    | GetConstant 0: Rest
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | GetConstant 3: [1]
  0010    | GetLocal 0
  0012    | PrepareMergePattern 2
  0014    | JumpIfFailure 14 -> 44
  0017    | GetConstant 4: [1]
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 28
  0023    | JumpIfSuccess 23 -> 28
  0026    | Swap
  0027    | Pop
  0028    | JumpIfFailure 28 -> 42
  0031    | Pop
  0032    | GetLocal 0
  0034    | Destructure
  0035    | JumpIfFailure 35 -> 42
  0038    | Pop
  0039    | JumpIfSuccess 39 -> 44
  0042    | Swap
  0043    | Pop
  0044    | TakeRight 44 -> 49
  0047    | GetBoundLocal 0
  0049    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, "b": 2}' -i ''
  
  =================@main==================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {"a": 1, "b": 2}
  0004    | CallFunction 1
  0006    | GetConstant 2: {"a": 1, "b": 2}
  0008    | Destructure
  0009    | JumpIfFailure 9 -> 17
  0012    | JumpIfSuccess 12 -> 17
  0015    | Swap
  0016    | Pop
  0017    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": A, "b": B}' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: const
  0006    | GetConstant 3: {"a": 1, "b": 2}
  0008    | CallFunction 1
  0010    | GetConstant 4: {"a": _, "b": _}
  0012    | Destructure
  0013    | JumpIfFailure 13 -> 41
  0016    | GetConstant 5: "a"
  0018    | GetAtKey
  0019    | GetLocal 0
  0021    | Destructure
  0022    | JumpIfFailure 22 -> 39
  0025    | Pop
  0026    | GetConstant 6: "b"
  0028    | GetAtKey
  0029    | GetLocal 1
  0031    | Destructure
  0032    | JumpIfFailure 32 -> 39
  0035    | Pop
  0036    | JumpIfSuccess 36 -> 41
  0039    | Swap
  0040    | Pop
  0041    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": _, "b": _}' -i ''
  
  =================@main==================
  0000    | GetConstant 0: _
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | GetConstant 3: {"a": _, "b": _}
  0010    | Destructure
  0011    | JumpIfFailure 11 -> 39
  0014    | GetConstant 4: "a"
  0016    | GetAtKey
  0017    | GetLocal 0
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 37
  0023    | Pop
  0024    | GetConstant 5: "b"
  0026    | GetAtKey
  0027    | GetLocal 0
  0029    | Destructure
  0030    | JumpIfFailure 30 -> 37
  0033    | Pop
  0034    | JumpIfSuccess 34 -> 39
  0037    | Swap
  0038    | Pop
  0039    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"a": 1} + B)' -i ''
  
  =================@main==================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | GetConstant 3: {"a": 1}
  0010    | GetLocal 0
  0012    | PrepareMergePattern 2
  0014    | JumpIfFailure 14 -> 44
  0017    | GetConstant 4: {"a": 1}
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 28
  0023    | JumpIfSuccess 23 -> 28
  0026    | Swap
  0027    | Pop
  0028    | JumpIfFailure 28 -> 42
  0031    | Pop
  0032    | GetLocal 0
  0034    | Destructure
  0035    | JumpIfFailure 35 -> 42
  0038    | Pop
  0039    | JumpIfSuccess 39 -> 44
  0042    | Swap
  0043    | Pop
  0044    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"b": 2} + A)' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | GetConstant 3: {"b": 2}
  0010    | GetLocal 0
  0012    | PrepareMergePattern 2
  0014    | JumpIfFailure 14 -> 44
  0017    | GetConstant 4: {"b": 2}
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 28
  0023    | JumpIfSuccess 23 -> 28
  0026    | Swap
  0027    | Pop
  0028    | JumpIfFailure 28 -> 42
  0031    | Pop
  0032    | GetLocal 0
  0034    | Destructure
  0035    | JumpIfFailure 35 -> 42
  0038    | Pop
  0039    | JumpIfSuccess 39 -> 44
  0042    | Swap
  0043    | Pop
  0044    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> (A + {"b": 2})' -i ''
  
  =================@main==================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | GetLocal 0
  0010    | GetConstant 3: {"b": 2}
  0012    | PrepareMergePattern 2
  0014    | JumpIfFailure 14 -> 44
  0017    | GetLocal 0
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 42
  0023    | Pop
  0024    | GetConstant 4: {"b": 2}
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 35
  0030    | JumpIfSuccess 30 -> 35
  0033    | Swap
  0034    | Pop
  0035    | JumpIfFailure 35 -> 42
  0038    | Pop
  0039    | JumpIfSuccess 39 -> 44
  0042    | Swap
  0043    | Pop
  0044    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, ...B}' -i ''
  
  =================@main==================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | GetConstant 3: {"a": 1}
  0010    | GetLocal 0
  0012    | PrepareMergePattern 2
  0014    | JumpIfFailure 14 -> 44
  0017    | GetConstant 4: {"a": 1}
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 28
  0023    | JumpIfSuccess 23 -> 28
  0026    | Swap
  0027    | Pop
  0028    | JumpIfFailure 28 -> 42
  0031    | Pop
  0032    | GetLocal 0
  0034    | Destructure
  0035    | JumpIfFailure 35 -> 42
  0038    | Pop
  0039    | JumpIfSuccess 39 -> 44
  0042    | Swap
  0043    | Pop
  0044    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  =================@main==================
  0000    | GetConstant 0: 2
  0002    | CallFunction 0
  0004    | GetConstant 1: 0
  0006    | GetConstant 2: 5
  0008    | DestructureRange
  0009    | End
  ========================================

  $ possum -p 'char -> "a".."z"' -i 'q'
  
  =================@main==================
  0000    | GetConstant 0: char
  0002    | CallFunction 0
  0004    | GetConstant 1: "a"
  0006    | GetConstant 2: "z"
  0008    | DestructureRange
  0009    | End
  ========================================

  $ possum -p 'char -> .."z"' -i '!'
  
  =================@main==================
  0000    | GetConstant 0: char
  0002    | CallFunction 0
  0004    | GetConstant 1: _
  0006    | GetConstant 2: "z"
  0008    | DestructureRange
  0009    | End
  ========================================
