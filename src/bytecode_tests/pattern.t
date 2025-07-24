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

  $ possum -p 'const(Is.Array([1])) ; Is.Array(V) = V -> [..._]' -i '1'
  
  ================Is.Array================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | GetLocal 1
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 2: []
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetLocal 1
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================
  
  =================@main==================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: Is.Array
  0004    | GetConstant 2: [1]
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | End
  ========================================

  $ possum -p '
  > __Table.RestPerRow(T, Acc) =
  >   T -> [Row, ...Rest] ? (
  >     Row -> [_, ...RowRest] ?
  >     __Table.RestPerRow(Rest, [...Acc, RowRest]) :
  >     __Table.RestPerRow(Rest, [...Acc, []])
  >   ) :
  >   Acc
  > 1
  > ' -i '1'
  
  ===========__Table.RestPerRow===========
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | GetConstant 2: _
  0006    | GetConstant 3: RowRest
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | GetConstant 4: [_]
  0013    | GetLocal 3
  0015    | PrepareMergePattern 2
  0017    | JumpIfFailure 17 -> 56
  0020    | GetConstant 5: [_]
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 40
  0026    | GetAtIndex 0
  0028    | GetLocal 2
  0030    | Destructure
  0031    | JumpIfFailure 31 -> 38
  0034    | Pop
  0035    | JumpIfSuccess 35 -> 40
  0038    | Swap
  0039    | Pop
  0040    | JumpIfFailure 40 -> 54
  0043    | Pop
  0044    | GetLocal 3
  0046    | Destructure
  0047    | JumpIfFailure 47 -> 54
  0050    | Pop
  0051    | JumpIfSuccess 51 -> 56
  0054    | Swap
  0055    | Pop
  0056    | ConditionalThen 56 -> 160
  0059    | SetInputMark
  0060    | GetBoundLocal 2
  0062    | GetConstant 6: [_]
  0064    | GetLocal 5
  0066    | PrepareMergePattern 2
  0068    | JumpIfFailure 68 -> 107
  0071    | GetConstant 7: [_]
  0073    | Destructure
  0074    | JumpIfFailure 74 -> 91
  0077    | GetAtIndex 0
  0079    | GetLocal 4
  0081    | Destructure
  0082    | JumpIfFailure 82 -> 89
  0085    | Pop
  0086    | JumpIfSuccess 86 -> 91
  0089    | Swap
  0090    | Pop
  0091    | JumpIfFailure 91 -> 105
  0094    | Pop
  0095    | GetLocal 5
  0097    | Destructure
  0098    | JumpIfFailure 98 -> 105
  0101    | Pop
  0102    | JumpIfSuccess 102 -> 107
  0105    | Swap
  0106    | Pop
  0107    | ConditionalThen 107 -> 137
  0110    | GetConstant 8: __Table.RestPerRow
  0112    | GetBoundLocal 3
  0114    | GetConstant 9: []
  0116    | JumpIfFailure 116 -> 122
  0119    | GetBoundLocal 1
  0121    | Merge
  0122    | JumpIfFailure 122 -> 132
  0125    | GetConstant 10: [_]
  0127    | GetBoundLocal 5
  0129    | InsertAtIndex 0
  0131    | Merge
  0132    | CallTailFunction 2
  0134    | ConditionalElse 134 -> 157
  0137    | GetConstant 11: __Table.RestPerRow
  0139    | GetBoundLocal 3
  0141    | GetConstant 12: []
  0143    | JumpIfFailure 143 -> 149
  0146    | GetBoundLocal 1
  0148    | Merge
  0149    | JumpIfFailure 149 -> 155
  0152    | GetConstant 13: [[]]
  0154    | Merge
  0155    | CallTailFunction 2
  0157    | ConditionalElse 157 -> 162
  0160    | GetBoundLocal 1
  0162    | End
  ========================================
  
  =================@main==================
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p 'Obj.Get(O, K) = O -> {K: V, ..._} & V ; 1' -i '1'
  
  ================Obj.Get=================
  0000    | GetConstant 0: V
  0002    | GetConstant 1: _
  0004    | GetBoundLocal 0
  0006    | GetConstant 2: {}
  0008    | GetLocal 1
  0010    | GetLocal 2
  0012    | InsertKeyVal
  0013    | GetLocal 3
  0015    | PrepareMergePattern 2
  0017    | JumpIfFailure 17 -> 62
  0020    | GetConstant 3: {}
  0022    | GetLocal 1
  0024    | GetLocal 2
  0026    | InsertKeyVal
  0027    | Destructure
  0028    | JumpIfFailure 28 -> 46
  0031    | GetLocal 1
  0033    | GetAtKey
  0034    | GetLocal 2
  0036    | Destructure
  0037    | JumpIfFailure 37 -> 44
  0040    | Pop
  0041    | JumpIfSuccess 41 -> 46
  0044    | Swap
  0045    | Pop
  0046    | JumpIfFailure 46 -> 60
  0049    | Pop
  0050    | GetLocal 3
  0052    | Destructure
  0053    | JumpIfFailure 53 -> 60
  0056    | Pop
  0057    | JumpIfSuccess 57 -> 62
  0060    | Swap
  0061    | Pop
  0062    | TakeRight 62 -> 67
  0065    | GetBoundLocal 2
  0067    | End
  ========================================
  
  =================@main==================
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  
  =================@main==================
  0000    | GetConstant 0: 4
  0002    | CallFunction 0
  0004    | GetConstant 1: 1
  0006    | GetConstant 2: 1
  0008    | GetConstant 3: 2
  0010    | PrepareMergePattern 3
  0012    | JumpIfFailure 12 -> 41
  0015    | GetConstant 4: 1
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 39
  0021    | Pop
  0022    | GetConstant 5: 1
  0024    | Destructure
  0025    | JumpIfFailure 25 -> 39
  0028    | Pop
  0029    | GetConstant 6: 2
  0031    | Destructure
  0032    | JumpIfFailure 32 -> 39
  0035    | Pop
  0036    | JumpIfSuccess 36 -> 41
  0039    | Swap
  0040    | Pop
  0041    | End
  ========================================

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  =================@main==================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | GetConstant 1: 2
  0006    | GetConstant 2: 3
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 3: 2
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetConstant 4: 3
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  
  =================@main==================
  0000    | GetConstant 0: 7
  0002    | CallFunction 0
  0004    | GetConstant 1: 3
  0006    | GetConstant 2: 4
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 3: 3
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetConstant 4: 4
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  
  =================@main==================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | GetConstant 1: 2
  0006    | GetConstant 2: 3
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 3: 2
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetConstant 4: 3
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  
  =================@main==================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 6
  0004    | CallFunction 0
  0006    | GetConstant 2: 1
  0008    | GetLocal 0
  0010    | GetConstant 3: 3
  0012    | PrepareMergePattern 3
  0014    | JumpIfFailure 14 -> 43
  0017    | GetConstant 4: 1
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 41
  0023    | Pop
  0024    | GetLocal 0
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 41
  0030    | Pop
  0031    | GetConstant 5: 3
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

  $ possum -p '5 -> (2 - 3)' -i '5'
  
  =================@main==================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | GetConstant 1: 2
  0006    | GetConstant 2: 3
  0008    | NegateNumberPattern
  0009    | PrepareMergePattern 2
  0011    | JumpIfFailure 11 -> 34
  0014    | GetConstant 3: 2
  0016    | Destructure
  0017    | JumpIfFailure 17 -> 32
  0020    | Pop
  0021    | NegateNumberPattern
  0022    | GetConstant 4: 3
  0024    | Destructure
  0025    | JumpIfFailure 25 -> 32
  0028    | Pop
  0029    | JumpIfSuccess 29 -> 34
  0032    | Swap
  0033    | Pop
  0034    | End
  ========================================

  $ possum -p '6 -> (1 + X - 3) $ X' -i '6'
  
  =================@main==================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 6
  0004    | CallFunction 0
  0006    | GetConstant 2: 1
  0008    | GetLocal 0
  0010    | GetConstant 3: 3
  0012    | NegateNumberPattern
  0013    | PrepareMergePattern 3
  0015    | JumpIfFailure 15 -> 45
  0018    | GetConstant 4: 1
  0020    | Destructure
  0021    | JumpIfFailure 21 -> 43
  0024    | Pop
  0025    | GetLocal 0
  0027    | Destructure
  0028    | JumpIfFailure 28 -> 43
  0031    | Pop
  0032    | NegateNumberPattern
  0033    | GetConstant 5: 3
  0035    | Destructure
  0036    | JumpIfFailure 36 -> 43
  0039    | Pop
  0040    | JumpIfSuccess 40 -> 45
  0043    | Swap
  0044    | Pop
  0045    | TakeRight 45 -> 50
  0048    | GetBoundLocal 0
  0050    | End
  ========================================

  $ possum -p '6 -> (1 - X + 3) $ X' -i '6'
  
  =================@main==================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 6
  0004    | CallFunction 0
  0006    | GetConstant 2: 1
  0008    | GetLocal 0
  0010    | NegateNumberPattern
  0011    | GetConstant 3: 3
  0013    | PrepareMergePattern 3
  0015    | JumpIfFailure 15 -> 45
  0018    | GetConstant 4: 1
  0020    | Destructure
  0021    | JumpIfFailure 21 -> 43
  0024    | Pop
  0025    | NegateNumberPattern
  0026    | GetLocal 0
  0028    | Destructure
  0029    | JumpIfFailure 29 -> 43
  0032    | Pop
  0033    | GetConstant 5: 3
  0035    | Destructure
  0036    | JumpIfFailure 36 -> 43
  0039    | Pop
  0040    | JumpIfSuccess 40 -> 45
  0043    | Swap
  0044    | Pop
  0045    | TakeRight 45 -> 50
  0048    | GetBoundLocal 0
  0050    | End
  ========================================

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  
  =================@main==================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | GetConstant 1: 1
  0006    | GetConstant 2: 6
  0008    | GetConstant 3: 3
  0010    | GetConstant 4: 2
  0012    | NegateNumberPattern
  0013    | GetConstant 5: 3
  0015    | NegateNumberPattern
  0016    | PrepareMergePattern 5
  0018    | JumpIfFailure 18 -> 63
  0021    | GetConstant 6: 1
  0023    | Destructure
  0024    | JumpIfFailure 24 -> 61
  0027    | Pop
  0028    | GetConstant 7: 6
  0030    | Destructure
  0031    | JumpIfFailure 31 -> 61
  0034    | Pop
  0035    | GetConstant 8: 3
  0037    | Destructure
  0038    | JumpIfFailure 38 -> 61
  0041    | Pop
  0042    | NegateNumberPattern
  0043    | GetConstant 9: 2
  0045    | Destructure
  0046    | JumpIfFailure 46 -> 61
  0049    | Pop
  0050    | NegateNumberPattern
  0051    | GetConstant 10: 3
  0053    | Destructure
  0054    | JumpIfFailure 54 -> 61
  0057    | Pop
  0058    | JumpIfSuccess 58 -> 63
  0061    | Swap
  0062    | Pop
  0063    | End
  ========================================

  $ possum -p '5 -> -(X + 1) $ X' -i '5'
  
  =================@main==================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 5
  0004    | CallFunction 0
  0006    | NegateNumber
  0007    | GetLocal 0
  0009    | GetConstant 2: 1
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 35
  0016    | GetLocal 0
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 33
  0022    | Pop
  0023    | GetConstant 3: 1
  0025    | Destructure
  0026    | JumpIfFailure 26 -> 33
  0029    | Pop
  0030    | JumpIfSuccess 30 -> 35
  0033    | Swap
  0034    | Pop
  0035    | TakeRight 35 -> 40
  0038    | GetBoundLocal 0
  0040    | End
  ========================================

  $ possum -p 'const([1, 5, 2]) -> [1, -(X + 1), 2] $ X' -i ''
  
  =================@main==================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 5, 2]
  0006    | CallFunction 1
  0008    | GetConstant 3: [1, _, 2]
  0010    | Destructure
  0011    | JumpIfFailure 11 -> 54
  0014    | GetAtIndex 1
  0016    | NegateNumber
  0017    | GetLocal 0
  0019    | GetConstant 4: 1
  0021    | PrepareMergePattern 2
  0023    | JumpIfFailure 23 -> 45
  0026    | GetLocal 0
  0028    | Destructure
  0029    | JumpIfFailure 29 -> 43
  0032    | Pop
  0033    | GetConstant 5: 1
  0035    | Destructure
  0036    | JumpIfFailure 36 -> 43
  0039    | Pop
  0040    | JumpIfSuccess 40 -> 45
  0043    | Swap
  0044    | Pop
  0045    | JumpIfFailure 45 -> 52
  0048    | Pop
  0049    | JumpIfSuccess 49 -> 54
  0052    | Swap
  0053    | Pop
  0054    | TakeRight 54 -> 59
  0057    | GetBoundLocal 0
  0059    | End
  ========================================

  $ possum -p '"1" -> "%(1)"' -i '1'
  
  =================@main==================
  0000    | GetConstant 0: "1"
  0002    | CallFunction 0
  0004    | GetConstant 1: 1
  0006    | PrepareMergePatternWithCasting 1
  0008    | JumpIfFailure 8 -> 24
  0011    | GetConstant 2: 1
  0013    | Destructure
  0014    | JumpIfFailure 14 -> 22
  0017    | Pop
  0018    | Pop
  0019    | JumpIfSuccess 19 -> 24
  0022    | Swap
  0023    | Pop
  0024    | End
  ========================================

  $ possum -p '"2" -> "%(1 + 1)"' -i '2'
  
  =================@main==================
  0000    | GetConstant 0: "2"
  0002    | CallFunction 0
  0004    | GetConstant 1: 1
  0006    | GetConstant 2: 1
  0008    | PrepareMergePatternWithCasting 2
  0010    | JumpIfFailure 10 -> 33
  0013    | GetConstant 3: 1
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 31
  0019    | Pop
  0020    | GetConstant 4: 1
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 31
  0026    | Pop
  0027    | Pop
  0028    | JumpIfSuccess 28 -> 33
  0031    | Swap
  0032    | Pop
  0033    | End
  ========================================

  $ possum -p '"50" -> "%(0 + N)" $ N' -i '50'
  
  =================@main==================
  0000    | GetConstant 0: N
  0002    | GetConstant 1: "50"
  0004    | CallFunction 0
  0006    | GetConstant 2: 0
  0008    | GetLocal 0
  0010    | PrepareMergePatternWithCasting 2
  0012    | JumpIfFailure 12 -> 35
  0015    | GetConstant 3: 0
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 33
  0021    | Pop
  0022    | GetLocal 0
  0024    | Destructure
  0025    | JumpIfFailure 25 -> 33
  0028    | Pop
  0029    | Pop
  0030    | JumpIfSuccess 30 -> 35
  0033    | Swap
  0034    | Pop
  0035    | TakeRight 35 -> 40
  0038    | GetBoundLocal 0
  0040    | End
  ========================================
