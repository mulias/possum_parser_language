  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'const([1,2,3]) -> [1,2,3]' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2,3]) -> [1,2,3]
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: [1, 2, 3]
  0004    | CallFunction 1
  0006    | Destructure 0: [1, 2, 3]
  0008    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A,B,C]' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2,3]) -> [A,B,C]
  ========================================
  0000    | PushVar2 A
  0003    | PushVar2 B
  0006    | PushVar2 C
  0009    | GetConstant 0: const
  0011    | GetConstant 1: [1, 2, 3]
  0013    | CallFunction 1
  0015    | Destructure 0: [A, B, C]
  0017    | End
  ========================================

  $ possum -p 'A = 1 ; const([1,2,3]) -> [A,B,C]' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2,3]) -> [A,B,C]
  ========================================
  0000    | PushVar2 B
  0003    | PushVar2 C
  0006    | GetConstant 0: const
  0008    | GetConstant 1: [1, 2, 3]
  0010    | CallFunction 1
  0012    | Destructure 0: [A, B, C]
  0014    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 2, 3]' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2,3]) -> [A, 2, 3]
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: const
  0005    | GetConstant 1: [1, 2, 3]
  0007    | CallFunction 1
  0009    | Destructure 0: [A, 2, 3]
  0011    | End
  ========================================

  $ possum -p 'const([1,[[2],3]]) -> [A, [[B], 3]] $ B' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,[[2],3]]) -> [A, [[B], 3]] $ B
  ========================================
  0000    | PushVar2 A
  0003    | PushVar2 B
  0006    | GetConstant 0: const
  0008    | GetConstantMutable 1: [1, _]
  0010    | GetConstantMutable 2: [_, 3]
  0012    | GetConstant 3: [2]
  0014    | InsertAtIndex 0
  0016    | InsertAtIndex 1
  0018    | CallFunction 1
  0020    | Destructure 0: [A, [[B], 3]]
  0022    | TakeRight 22 -> 27
  0025    | GetBoundLocalMove 1
  0027    | End
  ========================================

  $ possum -p '3 -> (2 + B)' -i '3'
  
  =================@main==================
  3 -> (2 + B)
  ========================================
  0000    | PushVar2 B
  0003    | ParseNumberStringChar 3
  0005    | Destructure 0: (2 + B)
  0007    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 1 + 1, 3]' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2,3]) -> [A, 1 + 1, 3]
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: const
  0005    | GetConstant 1: [1, 2, 3]
  0007    | CallFunction 1
  0009    | Destructure 0: [A, 2, 3]
  0011    | End
  ========================================

  $ possum -p 'const([1, @Add(1, 2), 3]) -> [A, @Add(1, 1), 3]' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1, @Add(1, 2), 3]) -> [A, @Add(1, 1), 3]
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: const
  0005    | GetConstantMutable 1: [1, _, 3]
  0007    | GetConstant 2: @Add
  0009    | PushInteger 1
  0011    | PushInteger 2
  0013    | CallFunction 2
  0015    | InsertAtIndex 1
  0017    | CallFunction 1
  0019    | Destructure 0: [A, @Add(1, 1), 3]
  0021    | End
  ========================================

  $ possum -p 'const([1,2]) -> ([1] + [2])' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2]) -> ([1] + [2])
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: [1, 2]
  0004    | CallFunction 1
  0006    | Destructure 0: [1, 2]
  0008    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> ([1] + B + [3])' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2,3]) -> ([1] + B + [3])
  ========================================
  0000    | PushVar2 B
  0003    | GetConstant 0: const
  0005    | GetConstant 1: [1, 2, 3]
  0007    | CallFunction 1
  0009    | Destructure 0: ([1] + B + [3])
  0011    | End
  ========================================

  $ possum -p 'const([1,[2],2,3]) -> ([1,A] + A + [3])' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,[2],2,3]) -> ([1,A] + A + [3])
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: const
  0005    | GetConstantMutable 1: [1, _, 2, 3]
  0007    | GetConstant 2: [2]
  0009    | InsertAtIndex 1
  0011    | CallFunction 1
  0013    | Destructure 0: ([1, A] + A + [3])
  0015    | End
  ========================================

  $ possum -p '"foobar" -> ("fo" + Ob + "ar") $ Ob' -i ''
  
  =================@main==================
  "foobar" -> ("fo" + Ob + "ar") $ Ob
  ========================================
  0000    | PushVar2 Ob
  0003    | CallFunctionConstant 0: "foobar"
  0005    | Destructure 0: ("fo" + Ob + "ar")
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [1, ...Rest] $ Rest' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1,2,3]) -> [1, ...Rest] $ Rest
  ========================================
  0000    | PushVar2 Rest
  0003    | GetConstant 0: const
  0005    | GetConstant 1: [1, 2, 3]
  0007    | CallFunction 1
  0009    | Destructure 0: ([1] + Rest)
  0011    | TakeRight 11 -> 16
  0014    | GetBoundLocalMove 0
  0016    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, "b": 2}' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1, "b": 2}) -> {"a": 1, "b": 2}
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {"a": 1, "b": 2}
  0004    | CallFunction 1
  0006    | Destructure 0: {"a": 1, "b": 2}
  0008    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": A, "b": B}' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1, "b": 2}) -> {"a": A, "b": B}
  ========================================
  0000    | PushVar2 A
  0003    | PushVar2 B
  0006    | GetConstant 0: const
  0008    | GetConstant 1: {"a": 1, "b": 2}
  0010    | CallFunction 1
  0012    | Destructure 0: {"a": A, "b": B}
  0014    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": _, "b": _}' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1, "b": 2}) -> {"a": _, "b": _}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 0: const
  0003    | GetConstant 1: {"a": 1, "b": 2}
  0005    | CallFunction 1
  0007    | Destructure 0: {"a": _, "b": _}
  0009    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"a": 1} + B)' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1, "b": 2}) -> ({"a": 1} + B)
  ========================================
  0000    | PushVar2 B
  0003    | GetConstant 0: const
  0005    | GetConstant 1: {"a": 1, "b": 2}
  0007    | CallFunction 1
  0009    | Destructure 0: ({"a": 1} + B)
  0011    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"b": 2} + A)' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1, "b": 2}) -> ({"b": 2} + A)
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: const
  0005    | GetConstant 1: {"a": 1, "b": 2}
  0007    | CallFunction 1
  0009    | Destructure 0: ({"b": 2} + A)
  0011    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> (A + {"b": 2})' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1, "b": 2}) -> (A + {"b": 2})
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: const
  0005    | GetConstant 1: {"a": 1, "b": 2}
  0007    | CallFunction 1
  0009    | Destructure 0: (A + {"b": 2})
  0011    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, ...B}' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const({"a": 1, "b": 2}) -> {"a": 1, ...B}
  ========================================
  0000    | PushVar2 B
  0003    | GetConstant 0: const
  0005    | GetConstant 1: {"a": 1, "b": 2}
  0007    | CallFunction 1
  0009    | Destructure 0: ({"a": 1} + B)
  0011    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  =================@main==================
  2 -> 0..5
  ========================================
  0000    | ParseNumberStringChar 2
  0002    | Destructure 0: 0..5
  0004    | End
  ========================================

  $ possum -p 'char -> "a".."z"' -i 'q'
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  =================@main==================
  char -> "a".."z"
  ========================================
  0000    | CallFunctionConstant 0: char
  0002    | Destructure 0: "a".."z"
  0004    | End
  ========================================

  $ possum -p 'char -> .."z"' -i '!'
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  =================@main==================
  char -> .."z"
  ========================================
  0000    | CallFunctionConstant 0: char
  0002    | Destructure 0: .."z"
  0004    | End
  ========================================

  $ possum -p 'const(Is.Array([1])) ; Is.Array(V) = V -> [..._]' -i '1'
  
  ================Is.Array================
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 0: ([] + _)
  0005    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const(Is.Array([1]))
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: Is.Array
  0004    | GetConstant 2: [1]
  0006    | CallFunction 1
  0008    | CallTailFunction 1
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
  __Table.RestPerRow(T, Acc) =
    T -> [Row, ...Rest] ? (
      Row -> [_, ...RowRest] ?
      __Table.RestPerRow(Rest, [...Acc, RowRest]) :
      __Table.RestPerRow(Rest, [...Acc, []])
    ) :
    Acc
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | PushUnderscoreVar
  0007    | PushVar2 RowRest
  0010    | SetInputMark
  0011    | GetBoundLocalMove 0
  0013    | Destructure 0: ([Row] + Rest)
  0015    | ConditionalThen 15 -> 74
  0018    | SetInputMark
  0019    | GetBoundLocalMove 2
  0021    | Destructure 1: ([_] + RowRest)
  0023    | ConditionalThen 23 -> 52
  0026    | GetConstant 0: __Table.RestPerRow
  0028    | GetBoundLocalMove 3
  0030    | PushEmptyArray
  0031    | JumpIfFailure 31 -> 37
  0034    | GetBoundLocalMove 1
  0036    | Merge
  0037    | JumpIfFailure 37 -> 47
  0040    | GetConstantMutable 1: [_]
  0042    | GetBoundLocalMove 5
  0044    | InsertAtIndex 0
  0046    | Merge
  0047    | CallTailFunction 2
  0049    | Jump 49 -> 71
  0052    | GetConstant 0: __Table.RestPerRow
  0054    | GetBoundLocalMove 3
  0056    | PushEmptyArray
  0057    | JumpIfFailure 57 -> 63
  0060    | GetBoundLocalMove 1
  0062    | Merge
  0063    | JumpIfFailure 63 -> 69
  0066    | GetConstant 2: [[]]
  0068    | Merge
  0069    | CallTailFunction 2
  0071    | Jump 71 -> 76
  0074    | GetBoundLocalMove 1
  0076    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | ParseNumberStringChar 1
  0002    | End
  ========================================

  $ possum -p 'Obj.Get(O, K) = O -> {K: V, ..._} & V ; 1' -i '1'
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar2 V
  0003    | PushUnderscoreVar
  0004    | GetBoundLocalMove 0
  0006    | Destructure 0: ({K: V} + _)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocalMove 2
  0013    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | ParseNumberStringChar 1
  0002    | End
  ========================================

  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  
  =================@main==================
  4 -> (1 + 1 + 2)
  ========================================
  0000    | ParseNumberStringChar 4
  0002    | Destructure 0: 4
  0004    | End
  ========================================

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  =================@main==================
  5 -> (2 + 3)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | Destructure 0: 5
  0004    | End
  ========================================

  $ possum -p '5 -> (2 + X + 3)' -i '5'
  
  =================@main==================
  5 -> (2 + X + 3)
  ========================================
  0000    | PushVar2 X
  0003    | ParseNumberStringChar 5
  0005    | Destructure 0: (2 + X + 3)
  0007    | End
  ========================================

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  
  =================@main==================
  7 -> (X + 4)
  ========================================
  0000    | ParseNumberStringChar 7
  0002    | Destructure 0: (X + 4)
  0004    | End
  ========================================

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  
  =================@main==================
  5 -> (X + Y)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | Destructure 0: (X + Y)
  0004    | End
  ========================================

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  
  =================@main==================
  6 -> (1 + X + 3) $ X
  ========================================
  0000    | PushVar2 X
  0003    | ParseNumberStringChar 6
  0005    | Destructure 0: (1 + X + 3)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p '5 -> (2 - 3)' -i '5'
  
  =================@main==================
  5 -> (2 - 3)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | Destructure 0: -1
  0004    | End
  ========================================

  $ possum -p '6 -> (1 + X - 3) $ X' -i '6'
  
  =================@main==================
  6 -> (1 + X - 3) $ X
  ========================================
  0000    | PushVar2 X
  0003    | ParseNumberStringChar 6
  0005    | Destructure 0: (1 + X + -3)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p '6 -> (1 - X + 3) $ X' -i '6'
  
  =================@main==================
  6 -> (1 - X + 3) $ X
  ========================================
  0000    | PushVar2 X
  0003    | ParseNumberStringChar 6
  0005    | Destructure 0: (1 + -X + 3)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  
  =================@main==================
  5 -> (1 + 6 + 3 - (2 + 3))
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | Destructure 0: 5
  0004    | End
  ========================================

  $ possum -p '5 -> -(X + 1) $ X' -i '5'
  
  =================@main==================
  5 -> -(X + 1) $ X
  ========================================
  0000    | PushVar2 X
  0003    | ParseNumberStringChar 5
  0005    | Destructure 0: (-X + -1)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p 'const([1, 5, 2]) -> [1, -(X + 1), 2] $ X' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const([1, 5, 2]) -> [1, -(X + 1), 2] $ X
  ========================================
  0000    | PushVar2 X
  0003    | GetConstant 0: const
  0005    | GetConstant 1: [1, 5, 2]
  0007    | CallFunction 1
  0009    | Destructure 0: [1, (-X + -1), 2]
  0011    | TakeRight 11 -> 16
  0014    | GetBoundLocalMove 0
  0016    | End
  ========================================

  $ possum -p '"1" -> "%(1)"' -i '1'
  
  =================@main==================
  "1" -> "%(1)"
  ========================================
  0000    | ParseChar '1'
  0002    | Destructure 0: "%(1)"
  0004    | End
  ========================================

  $ possum -p '"2" -> "%(1 + 1)"' -i '2'
  
  =================@main==================
  "2" -> "%(1 + 1)"
  ========================================
  0000    | ParseChar '2'
  0002    | Destructure 0: "%(2)"
  0004    | End
  ========================================

  $ possum -p '"50" -> "%(0 + N)" $ N' -i '50'
  
  =================@main==================
  "50" -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionConstant 0: "50"
  0005    | Destructure 0: "%(0 + N)"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
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
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | ParseNumberStringChar 2
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

  $ possum -p '2 * (2 + (-1 * -1))' -i '2222'
  
  =================@main==================
  2 * (2 + (-1 * -1))
  ========================================
  0000    | PushNull
  0001    | PushInteger 3
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | ParseNumberStringChar 2
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

  $ possum -p '123 -> V' -i '123'
  
  =================@main==================
  123 -> V
  ========================================
  0000    | PushVar2 V
  0003    | CallFunctionConstant 0: 123
  0005    | Destructure 0: V
  0007    | End
  ========================================

  $ possum -p '"abc" -> "abc"' -i 'abc'
  
  =================@main==================
  "abc" -> "abc"
  ========================================
  0000    | CallFunctionConstant 0: "abc"
  0002    | Destructure 0: "abc"
  0004    | End
  ========================================

  $ possum -p 'many(char) -> `\nfoo`' -i '\nfoo'
  
  ==================many==================
  many(p) = p * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | CallFunctionLocal 0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal 0
  0026    | JumpIfFailure 26 -> 34
  0029    | PopInputMark
  0030    | Merge
  0031    | JumpBack 31 -> 23
  0034    | ResetInput
  0035    | Drop
  0036    | Swap
  0037    | Drop
  0038    | End
  ========================================
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  =================@main==================
  many(char) -> `\nfoo`
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: char
  0004    | CallFunction 1
  0006    | Destructure 0: "\nfoo"
  0008    | End
  ========================================

  $ possum -p 'many(char) -> "%(`a`..`z`)%(_)"' -i 'abcd'
  
  ==================many==================
  many(p) = p * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | CallFunctionLocal 0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal 0
  0026    | JumpIfFailure 26 -> 34
  0029    | PopInputMark
  0030    | Merge
  0031    | JumpBack 31 -> 23
  0034    | ResetInput
  0035    | Drop
  0036    | Swap
  0037    | Drop
  0038    | End
  ========================================
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  =================@main==================
  many(char) -> "%(`a`..`z`)%(_)"
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 0: many
  0003    | GetConstant 1: char
  0005    | CallFunction 1
  0007    | Destructure 0: "%("a".."z")%(_)"
  0009    | End
  ========================================

  $ possum -p 'numerals -> ("3" * 10)' -i '3333333333'
  
  ================numerals================
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================many==================
  many(p) = p * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | CallFunctionLocal 0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal 0
  0026    | JumpIfFailure 26 -> 34
  0029    | PopInputMark
  0030    | Merge
  0031    | JumpBack 31 -> 23
  0034    | ResetInput
  0035    | Drop
  0036    | Swap
  0037    | Drop
  0038    | End
  ========================================
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  =================@main==================
  numerals -> ("3" * 10)
  ========================================
  0000    | CallFunctionConstant 0: numerals
  0002    | Destructure 0: "3333333333"
  0004    | End
  ========================================

  $ possum -p 'many(char) -> ("\u000000".. * 10)' -i '12345678901234567890'
  
  ==================many==================
  many(p) = p * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | CallFunctionLocal 0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal 0
  0026    | JumpIfFailure 26 -> 34
  0029    | PopInputMark
  0030    | Merge
  0031    | JumpBack 31 -> 23
  0034    | ResetInput
  0035    | Drop
  0036    | Swap
  0037    | Drop
  0038    | End
  ========================================
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  =================@main==================
  many(char) -> ("\u000000".. * 10)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: char
  0004    | CallFunction 1
  0006    | Destructure 0: ("\x00".. * 10) (esc)
  0008    | End
  ========================================

  $ possum -p 'bool(1, 0) -> true' -i '1'
  
  ================boolean=================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetBoundLocalMove 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetBoundLocalMove 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ==================true==================
  true(t) = t $ true
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushTrue
  0006    | End
  ========================================
  
  =================false==================
  false(f) = f $ false
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushFalse
  0006    | End
  ========================================
  
  =================@main==================
  bool(1, 0) -> true
  ========================================
  0000    | GetConstant 0: boolean
  0002    | PushNumberStringOne
  0003    | PushNumberStringZero
  0004    | CallFunction 2
  0006    | Destructure 0: true
  0008    | End
  ========================================

  $ possum -p 'int -> 5' -i '5'
  
  ==================@fn2==================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString2 "-"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionConstant 3: _number_integer_part
  0012    | Merge
  0013    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn2
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: "%(0 + N)"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 1
  0012    | End
  ========================================
  
  =================maybe==================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: succeed
  0008    | End
  ========================================
  
  ================succeed=================
  succeed = const($null)
  ========================================
  0000    | GetConstant 5: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  ==========_number_integer_part==========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 10
  0007    | CallFunctionConstant 6: numerals
  0009    | Merge
  0010    | Or 10 -> 15
  0013    | CallTailFunctionConstant 7: numeral
  0015    | End
  ========================================
  
  ================numerals================
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 8: many
  0002    | GetConstant 7: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================many==================
  many(p) = p * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | CallFunctionLocal 0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal 0
  0026    | JumpIfFailure 26 -> 34
  0029    | PopInputMark
  0030    | Merge
  0031    | JumpBack 31 -> 23
  0034    | ResetInput
  0035    | Drop
  0036    | Swap
  0037    | Drop
  0038    | End
  ========================================
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  =================@main==================
  int -> 5
  ========================================
  0000    | CallFunctionConstant 0: integer
  0002    | Destructure 0: 5
  0004    | End
  ========================================

  $ possum -p '5 -> 2..7' -i '5'
  
  =================@main==================
  5 -> 2..7
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | Destructure 0: 2..7
  0004    | End
  ========================================

  $ possum -p '8 -> (0 + N)' -i '8'
  
  =================@main==================
  8 -> (0 + N)
  ========================================
  0000    | PushVar2 N
  0003    | ParseNumberStringChar 8
  0005    | Destructure 0: (0 + N)
  0007    | End
  ========================================

  $ possum -p '8 -> (N + 100)' -i '8'
  
  =================@main==================
  8 -> (N + 100)
  ========================================
  0000    | PushVar2 N
  0003    | ParseNumberStringChar 8
  0005    | Destructure 0: (N + 100)
  0007    | End
  ========================================

  $ possum -p 'array(digit) -> [1, 2, 3]' -i '123'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> [1, 2, 3]
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: digit
  0004    | CallFunction 1
  0006    | Destructure 0: [1, 2, 3]
  0008    | End
  ========================================

  $ possum -p 'array(digit) -> [A, ..._]' -i '123'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> [A, ..._]
  ========================================
  0000    | PushVar2 A
  0003    | PushUnderscoreVar
  0004    | GetConstant 0: array
  0006    | GetConstant 1: digit
  0008    | CallFunction 1
  0010    | Destructure 0: ([A] + _)
  0012    | End
  ========================================

  $ possum -p 'array(digit) -> ([1] * 5)' -i '11111'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> ([1] * 5)
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: digit
  0004    | CallFunction 1
  0006    | Destructure 0: [1, 1, 1, 1, 1]
  0008    | End
  ========================================

  $ possum -p 'array(digit) -> ([A] * 5)' -i '11111'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> ([A] * 5)
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: array
  0005    | GetConstant 1: digit
  0007    | CallFunction 1
  0009    | Destructure 0: [A, A, A, A, A]
  0011    | End
  ========================================

  $ possum -p 'array(digit) -> ([1] * N) $ N' -i '11111111'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> ([1] * N) $ N
  ========================================
  0000    | PushVar2 N
  0003    | GetConstant 0: array
  0005    | GetConstant 1: digit
  0007    | CallFunction 1
  0009    | Destructure 0: ([1] * N)
  0011    | TakeRight 11 -> 16
  0014    | GetBoundLocalMove 0
  0016    | End
  ========================================

  $ possum -p 'array(digit) -> [A, ..._, Z]' -i '12345678'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> [A, ..._, Z]
  ========================================
  0000    | PushVar2 A
  0003    | PushUnderscoreVar
  0004    | PushVar2 Z
  0007    | GetConstant 0: array
  0009    | GetConstant 1: digit
  0011    | CallFunction 1
  0013    | Destructure 0: ([A] + _ + [Z])
  0015    | End
  ========================================

  $ possum -p 'array(digit) -> [1, B, _]' -i '123'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> [1, B, _]
  ========================================
  0000    | PushVar2 B
  0003    | PushUnderscoreVar
  0004    | GetConstant 0: array
  0006    | GetConstant 1: digit
  0008    | CallFunction 1
  0010    | Destructure 0: [1, B, _]
  0012    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": 1, "b": 2}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 1: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 1: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  object(alpha, digit) -> {"a": 1, "b": 2}
  ========================================
  0000    | GetConstant 0: object
  0002    | GetConstant 1: alpha
  0004    | GetConstant 2: digit
  0006    | CallFunction 2
  0008    | Destructure 0: {"a": 1, "b": 2}
  0010    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": 1, ..._}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 1: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 1: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  object(alpha, digit) -> {"a": 1, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 0: object
  0003    | GetConstant 1: alpha
  0005    | GetConstant 2: digit
  0007    | CallFunction 2
  0009    | Destructure 0: ({"a": 1} + _)
  0011    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {_: 1, ..._}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 1: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 1: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  object(alpha, digit) -> {_: 1, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 0: object
  0003    | GetConstant 1: alpha
  0005    | GetConstant 2: digit
  0007    | CallFunction 2
  0009    | Destructure 0: ({_: 1} + _)
  0011    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": A, ..._}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 1: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 1: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  object(alpha, digit) -> {"a": A, ..._}
  ========================================
  0000    | PushVar2 A
  0003    | PushUnderscoreVar
  0004    | GetConstant 0: object
  0006    | GetConstant 1: alpha
  0008    | GetConstant 2: digit
  0010    | CallFunction 2
  0012    | Destructure 0: ({"a": A} + _)
  0014    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {..._, "a": A}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 1: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 1: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  object(alpha, digit) -> {..._, "a": A}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar2 A
  0004    | GetConstant 0: object
  0006    | GetConstant 1: alpha
  0008    | GetConstant 2: digit
  0010    | CallFunction 2
  0012    | Destructure 0: ({} + _ + {"a": A})
  0014    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": _, "b": B}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 1: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 1: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  object(alpha, digit) -> {"a": _, "b": B}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar2 B
  0004    | GetConstant 0: object
  0006    | GetConstant 1: alpha
  0008    | GetConstant 2: digit
  0010    | CallFunction 2
  0012    | Destructure 0: {"a": _, "b": B}
  0014    | End
  ========================================

  $ possum -p 'array(digit) -> [...A]' -i '123'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 0: tuple1
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 42
  0037    | PopInputMark
  0038    | Merge
  0039    | JumpBack 39 -> 27
  0042    | ResetInput
  0043    | Drop
  0044    | Swap
  0045    | Drop
  0046    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 1: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  array(digit) -> [...A]
  ========================================
  0000    | PushVar2 A
  0003    | GetConstant 0: array
  0005    | GetConstant 1: digit
  0007    | CallFunction 1
  0009    | Destructure 0: ([] + A)
  0011    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {...O}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 1: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 1: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@main==================
  object(alpha, digit) -> {...O}
  ========================================
  0000    | PushVar2 O
  0003    | GetConstant 0: object
  0005    | GetConstant 1: alpha
  0007    | GetConstant 2: digit
  0009    | CallFunction 2
  0011    | Destructure 0: ({} + O)
  0013    | End
  ========================================

  $ possum -p '"abc" -> "%(S)"' -i 'abc'
  
  =================@main==================
  "abc" -> "%(S)"
  ========================================
  0000    | PushVar2 S
  0003    | CallFunctionConstant 0: "abc"
  0005    | Destructure 0: "%(S)"
  0007    | End
  ========================================

  $ possum -p '"null" -> "%(null)"' -i 'null'
  
  =================@main==================
  "null" -> "%(null)"
  ========================================
  0000    | CallFunctionConstant 0: "null"
  0002    | Destructure 0: "%(null)"
  0004    | End
  ========================================

  $ possum -p '"null" -> "%(null + N)" $ N' -i 'null'
  
  =================@main==================
  "null" -> "%(null + N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionConstant 0: "null"
  0005    | Destructure 0: "%(N)"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p '"true" -> "%(true + B)" $ B' -i 'true'
  
  =================@main==================
  "true" -> "%(true + B)" $ B
  ========================================
  0000    | PushVar2 B
  0003    | CallFunctionConstant 0: "true"
  0005    | Destructure 0: "%(true + B)"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  
  =================@main==================
  "123" -> "%(0 + N)"
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionConstant 0: "123"
  0005    | Destructure 0: "%(0 + N)"
  0007    | End
  ========================================

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  
  =================@main==================
  "123" -> "%(N + 1)"
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionConstant 0: "123"
  0005    | Destructure 0: "%(N + 1)"
  0007    | End
  ========================================

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  
  =================@main==================
  "[1,2,3]" -> "%([...A])"
  ========================================
  0000    | PushVar2 A
  0003    | CallFunctionConstant 0: "[1,2,3]"
  0005    | Destructure 0: "%([] + A)"
  0007    | End
  ========================================

  $ possum -p '`{"a": 1, "b": 2}` -> "%({..._})"' -i '{"a": 1, "b": 2}'
  
  =================@main==================
  `{"a": 1, "b": 2}` -> "%({..._})"
  ========================================
  0000    | PushUnderscoreVar
  0001    | CallFunctionConstant 0: "{"a": 1, "b": 2}"
  0003    | Destructure 0: "%({} + _)"
  0005    | End
  ========================================

  $ possum -p '"abcabcabc" -> "%( `abc` * N)" $ N' -i 'abcabcabc'
  
  =================@main==================
  "abcabcabc" -> "%( `abc` * N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionConstant 0: "abcabcabc"
  0005    | Destructure 0: "%(("abc" * N))"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p '"prefix123123suffix" -> "%(`prefix` + (`123` * N) + `suffix`)" $ N' -i 'prefix123123suffix'
  
  =================@main==================
  "prefix123123suffix" -> "%(`prefix` + (`123` * N) + `suffix`)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionConstant 0: "prefix123123suffix"
  0005    | Destructure 0: "%("prefix" + ("123" * N) + "suffix")"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 0
  0012    | End
  ========================================

  $ possum -p '"" -> ("" * N)' -i ''
  
  =================@main==================
  "" -> ("" * N)
  ========================================
  0000    | PushVar2 N
  0003    | PushEmptyString
  0004    | Destructure 0: ("" * N)
  0006    | End
  ========================================

  $ possum -p '"" -> "%(`` * N)"' -i ''
  
  =================@main==================
  "" -> "%(`` * N)"
  ========================================
  0000    | PushVar2 N
  0003    | PushEmptyString
  0004    | Destructure 0: "%(("" * N))"
  0006    | End
  ========================================

  $ possum -p '"" $ 0 -> (0 * N)' -i ''
  
  =================@main==================
  "" $ 0 -> (0 * N)
  ========================================
  0000    | PushVar2 N
  0003    | PushInteger 0
  0005    | Destructure 0: (0 * N)
  0007    | End
  ========================================

  $ possum -p 'const($true) -> (true * N)' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const($true) -> (true * N)
  ========================================
  0000    | PushVar2 N
  0003    | GetConstant 0: const
  0005    | PushTrue
  0006    | CallFunction 1
  0008    | Destructure 0: (true * N)
  0010    | End
  ========================================

  $ possum -p 'const($false) -> (false * N)' -i ''
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================@main==================
  const($false) -> (false * N)
  ========================================
  0000    | PushVar2 N
  0003    | GetConstant 0: const
  0005    | PushFalse
  0006    | CallFunction 1
  0008    | Destructure 0: (false * N)
  0010    | End
  ========================================

  $ possum -p 'Double(N) = N + N; 6 -> Double(1 + 2)' -i ''
  
  =================Double=================
  Double(N) = N + N
  ========================================
  0000    | GetBoundLocal 0
  0002    | JumpIfFailure 2 -> 8
  0005    | GetBoundLocalMove 0
  0007    | Merge
  0008    | End
  ========================================
  
  =================@main==================
  6 -> Double(1 + 2)
  ========================================
  0000    | ParseNumberStringChar 6
  0002    | Destructure 0: Double(3)
  0004    | End
  ========================================
