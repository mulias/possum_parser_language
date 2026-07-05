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
  0000    | PushCharVar A
  0002    | PushCharVar B
  0004    | PushCharVar C
  0006    | GetConstant 0: const
  0008    | GetConstant 1: [1, 2, 3]
  0010    | CallFunction 1
  0012    | Destructure 0: [A, B, C]
  0014    | End
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
  0000    | PushCharVar B
  0002    | PushCharVar C
  0004    | GetConstant 0: const
  0006    | GetConstant 1: [1, 2, 3]
  0008    | CallFunction 1
  0010    | Destructure 0: [A, B, C]
  0012    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: [A, 2, 3]
  0010    | End
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
  0000    | PushCharVar A
  0002    | PushCharVar B
  0004    | GetConstant 0: const
  0006    | GetConstantMutable 1: [1, _]
  0008    | GetConstantMutable 2: [_, 3]
  0010    | GetConstant 3: [2]
  0012    | InsertAtIndex 0
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | Destructure 0: [A, [[B], 3]]
  0020    | TakeRight 20 -> 25
  0023    | GetBoundLocalMove 1
  0025    | End
  ========================================

  $ possum -p '3 -> (2 + B)' -i '3'
  
  =================@main==================
  3 -> (2 + B)
  ========================================
  0000    | PushCharVar B
  0002    | ParseThree
  0003    | Destructure 0: (2 + B)
  0005    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: [A, 2, 3]
  0010    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: const
  0004    | GetConstantMutable 1: [1, _, 3]
  0006    | GetConstant 2: @Add
  0008    | PushNumberOne
  0009    | PushNumberTwo
  0010    | CallFunction 2
  0012    | InsertAtIndex 1
  0014    | CallFunction 1
  0016    | Destructure 0: [A, @Add(1, 1), 3]
  0018    | End
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
  0000    | PushCharVar B
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: ([1] + B + [3])
  0010    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: const
  0004    | GetConstantMutable 1: [1, _, 2, 3]
  0006    | GetConstant 2: [2]
  0008    | InsertAtIndex 1
  0010    | CallFunction 1
  0012    | Destructure 0: ([1, A] + A + [3])
  0014    | End
  ========================================

  $ possum -p '"foobar" -> ("fo" + Ob + "ar") $ Ob' -i ''
  
  =================@main==================
  "foobar" -> ("fo" + Ob + "ar") $ Ob
  ========================================
  0000    | GetConstant 0: Ob
  0002    | CallFunctionConstant 1: "foobar"
  0004    | Destructure 0: ("fo" + Ob + "ar")
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
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
  0000    | GetConstant 0: Rest
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: ([1] + Rest)
  0010    | TakeRight 10 -> 15
  0013    | GetBoundLocalMove 0
  0015    | End
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
  0000    | PushCharVar A
  0002    | PushCharVar B
  0004    | GetConstant 0: const
  0006    | GetConstant 1: {"a": 1, "b": 2}
  0008    | CallFunction 1
  0010    | Destructure 0: {"a": A, "b": B}
  0012    | End
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
  0000    | PushCharVar B
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: ({"a": 1} + B)
  0010    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: ({"b": 2} + A)
  0010    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: (A + {"b": 2})
  0010    | End
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
  0000    | PushCharVar B
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: ({"a": 1} + B)
  0010    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  =================@main==================
  2 -> 0..5
  ========================================
  0000    | ParseTwo
  0001    | Destructure 0: 0..5
  0003    | End
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
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | PushUnderscoreVar
  0005    | GetConstant 2: RowRest
  0007    | SetInputMark
  0008    | GetBoundLocalMove 0
  0010    | Destructure 0: ([Row] + Rest)
  0012    | ConditionalThen 12 -> 71
  0015    | SetInputMark
  0016    | GetBoundLocalMove 2
  0018    | Destructure 1: ([_] + RowRest)
  0020    | ConditionalThen 20 -> 49
  0023    | GetConstant 3: __Table.RestPerRow
  0025    | GetBoundLocalMove 3
  0027    | PushEmptyArray
  0028    | JumpIfFailure 28 -> 34
  0031    | GetBoundLocalMove 1
  0033    | Merge
  0034    | JumpIfFailure 34 -> 44
  0037    | GetConstantMutable 4: [_]
  0039    | GetBoundLocalMove 5
  0041    | InsertAtIndex 0
  0043    | Merge
  0044    | CallTailFunction 2
  0046    | Jump 46 -> 68
  0049    | GetConstant 3: __Table.RestPerRow
  0051    | GetBoundLocalMove 3
  0053    | PushEmptyArray
  0054    | JumpIfFailure 54 -> 60
  0057    | GetBoundLocalMove 1
  0059    | Merge
  0060    | JumpIfFailure 60 -> 66
  0063    | GetConstant 5: [[]]
  0065    | Merge
  0066    | CallTailFunction 2
  0068    | Jump 68 -> 73
  0071    | GetBoundLocalMove 1
  0073    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | ParseOne
  0001    | End
  ========================================

  $ possum -p 'Obj.Get(O, K) = O -> {K: V, ..._} & V ; 1' -i '1'
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushCharVar V
  0002    | PushUnderscoreVar
  0003    | GetBoundLocalMove 0
  0005    | Destructure 0: ({K: V} + _)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 2
  0012    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | ParseOne
  0001    | End
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
  0000    | PushCharVar X
  0002    | ParseNumberStringChar 5
  0004    | Destructure 0: (2 + X + 3)
  0006    | End
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
  0000    | PushCharVar X
  0002    | ParseNumberStringChar 6
  0004    | Destructure 0: (1 + X + 3)
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
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
  0000    | PushCharVar X
  0002    | ParseNumberStringChar 6
  0004    | Destructure 0: (1 + X + -3)
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
  ========================================

  $ possum -p '6 -> (1 - X + 3) $ X' -i '6'
  
  =================@main==================
  6 -> (1 - X + 3) $ X
  ========================================
  0000    | PushCharVar X
  0002    | ParseNumberStringChar 6
  0004    | Destructure 0: (1 + -X + 3)
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
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
  0000    | PushCharVar X
  0002    | ParseNumberStringChar 5
  0004    | Destructure 0: (-X + -1)
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
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
  0000    | PushCharVar X
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 5, 2]
  0006    | CallFunction 1
  0008    | Destructure 0: [1, (-X + -1), 2]
  0010    | TakeRight 10 -> 15
  0013    | GetBoundLocalMove 0
  0015    | End
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
  0000    | PushCharVar N
  0002    | CallFunctionConstant 0: "50"
  0004    | Destructure 0: "%(0 + N)"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
  ========================================

  $ possum -p '"ab" * 3' -i 'ababab'
  
  =================@main==================
  "ab" * 3
  ========================================
  0000    | PushNull
  0001    | PushNumberThree
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 22
  0006    | Swap
  0007    | CallFunctionConstant 0: "ab"
  0009    | Merge
  0010    | JumpIfFailure 10 -> 21
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 22
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | Drop
  0023    | End
  ========================================

  $ possum -p '2 * (2 * 2)' -i '2222'
  
  =================@main==================
  2 * (2 * 2)
  ========================================
  0000    | PushNull
  0001    | PushNumber 4
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

  $ possum -p '2 * (2 + (-1 * -1))' -i '2222'
  
  =================@main==================
  2 * (2 + (-1 * -1))
  ========================================
  0000    | PushNull
  0001    | PushNumberThree
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | ParseTwo
  0008    | Merge
  0009    | JumpIfFailure 9 -> 20
  0012    | Swap
  0013    | Decrement
  0014    | JumpIfZero 14 -> 21
  0017    | JumpBack 17 -> 6
  0020    | Swap
  0021    | Drop
  0022    | End
  ========================================

  $ possum -p '123 -> V' -i '123'
  
  =================@main==================
  123 -> V
  ========================================
  0000    | PushCharVar V
  0002    | CallFunctionConstant 0: 123
  0004    | Destructure 0: V
  0006    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | CallFunctionLocal 0
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 21
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | SetInputMark
  0023    | CallFunctionLocal 0
  0025    | JumpIfFailure 25 -> 33
  0028    | PopInputMark
  0029    | Merge
  0030    | JumpBack 30 -> 22
  0033    | ResetInput
  0034    | Drop
  0035    | Swap
  0036    | Drop
  0037    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | CallFunctionLocal 0
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 21
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | SetInputMark
  0023    | CallFunctionLocal 0
  0025    | JumpIfFailure 25 -> 33
  0028    | PopInputMark
  0029    | Merge
  0030    | JumpBack 30 -> 22
  0033    | ResetInput
  0034    | Drop
  0035    | Swap
  0036    | Drop
  0037    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | CallFunctionLocal 0
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 21
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | SetInputMark
  0023    | CallFunctionLocal 0
  0025    | JumpIfFailure 25 -> 33
  0028    | PopInputMark
  0029    | Merge
  0030    | JumpBack 30 -> 22
  0033    | ResetInput
  0034    | Drop
  0035    | Swap
  0036    | Drop
  0037    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | CallFunctionLocal 0
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 21
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | SetInputMark
  0023    | CallFunctionLocal 0
  0025    | JumpIfFailure 25 -> 33
  0028    | PopInputMark
  0029    | Merge
  0030    | JumpBack 30 -> 22
  0033    | ResetInput
  0034    | Drop
  0035    | Swap
  0036    | Drop
  0037    | End
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
  
  =================@fn37==================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 3: _number_integer_part
  0011    | Merge
  0012    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn37
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushCharVar N
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: "%(0 + N)"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 1
  0011    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | CallFunctionLocal 0
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 21
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | SetInputMark
  0023    | CallFunctionLocal 0
  0025    | JumpIfFailure 25 -> 33
  0028    | PopInputMark
  0029    | Merge
  0030    | JumpBack 30 -> 22
  0033    | ResetInput
  0034    | Drop
  0035    | Swap
  0036    | Drop
  0037    | End
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
  0000    | PushCharVar N
  0002    | ParseNumberStringChar 8
  0004    | Destructure 0: (0 + N)
  0006    | End
  ========================================

  $ possum -p '8 -> (N + 100)' -i '8'
  
  =================@main==================
  8 -> (N + 100)
  ========================================
  0000    | PushCharVar N
  0002    | ParseNumberStringChar 8
  0004    | Destructure 0: (N + 100)
  0006    | End
  ========================================

  $ possum -p 'array(digit) -> [1, 2, 3]' -i '123'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0000    | PushCharVar A
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: array
  0005    | GetConstant 1: digit
  0007    | CallFunction 1
  0009    | Destructure 0: ([A] + _)
  0011    | End
  ========================================

  $ possum -p 'array(digit) -> ([1] * 5)' -i '11111'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | Destructure 0: [A, A, A, A, A]
  0010    | End
  ========================================

  $ possum -p 'array(digit) -> ([1] * N) $ N' -i '11111111'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0000    | PushCharVar N
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | Destructure 0: ([1] * N)
  0010    | TakeRight 10 -> 15
  0013    | GetBoundLocalMove 0
  0015    | End
  ========================================

  $ possum -p 'array(digit) -> [A, ..._, Z]' -i '12345678'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0000    | PushCharVar A
  0002    | PushUnderscoreVar
  0003    | PushCharVar Z
  0005    | GetConstant 0: array
  0007    | GetConstant 1: digit
  0009    | CallFunction 1
  0011    | Destructure 0: ([A] + _ + [Z])
  0013    | End
  ========================================

  $ possum -p 'array(digit) -> [1, B, _]' -i '123'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0000    | PushCharVar B
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: array
  0005    | GetConstant 1: digit
  0007    | CallFunction 1
  0009    | Destructure 0: [1, B, _]
  0011    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": 1, "b": 2}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 0: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 0: pair
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 1: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 0: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 0: pair
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 1: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 0: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 0: pair
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 1: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
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
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 0: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 0: pair
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 1: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
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
  0000    | PushCharVar A
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: object
  0005    | GetConstant 1: alpha
  0007    | GetConstant 2: digit
  0009    | CallFunction 2
  0011    | Destructure 0: ({"a": A} + _)
  0013    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {..._, "a": A}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 0: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 0: pair
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 1: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
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
  0001    | PushCharVar A
  0003    | GetConstant 0: object
  0005    | GetConstant 1: alpha
  0007    | GetConstant 2: digit
  0009    | CallFunction 2
  0011    | Destructure 0: ({} + _ + {"a": A})
  0013    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": _, "b": B}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 0: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 0: pair
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 1: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
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
  0001    | PushCharVar B
  0003    | GetConstant 0: object
  0005    | GetConstant 1: alpha
  0007    | GetConstant 2: digit
  0009    | CallFunction 2
  0011    | Destructure 0: {"a": _, "b": B}
  0013    | End
  ========================================

  $ possum -p 'array(digit) -> [...A]' -i '123'
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 0: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 0: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 1: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 0: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 2: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
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
  0000    | PushCharVar A
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | Destructure 0: ([] + A)
  0010    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {...O}' -i 'a1b2'
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 0: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 0: pair
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 1: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
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
  0000    | PushCharVar O
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | Destructure 0: ({} + O)
  0012    | End
  ========================================

  $ possum -p '"abc" -> "%(S)"' -i 'abc'
  
  =================@main==================
  "abc" -> "%(S)"
  ========================================
  0000    | PushCharVar S
  0002    | CallFunctionConstant 0: "abc"
  0004    | Destructure 0: "%(S)"
  0006    | End
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
  0000    | PushCharVar N
  0002    | CallFunctionConstant 0: "null"
  0004    | Destructure 0: "%(N)"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
  ========================================

  $ possum -p '"true" -> "%(true + B)" $ B' -i 'true'
  
  =================@main==================
  "true" -> "%(true + B)" $ B
  ========================================
  0000    | PushCharVar B
  0002    | CallFunctionConstant 0: "true"
  0004    | Destructure 0: "%(true + B)"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
  ========================================

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  
  =================@main==================
  "123" -> "%(0 + N)"
  ========================================
  0000    | PushCharVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | Destructure 0: "%(0 + N)"
  0006    | End
  ========================================

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  
  =================@main==================
  "123" -> "%(N + 1)"
  ========================================
  0000    | PushCharVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | Destructure 0: "%(N + 1)"
  0006    | End
  ========================================

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  
  =================@main==================
  "[1,2,3]" -> "%([...A])"
  ========================================
  0000    | PushCharVar A
  0002    | CallFunctionConstant 0: "[1,2,3]"
  0004    | Destructure 0: "%([] + A)"
  0006    | End
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
  0000    | PushCharVar N
  0002    | CallFunctionConstant 0: "abcabcabc"
  0004    | Destructure 0: "%(("abc" * N))"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
  ========================================

  $ possum -p '"prefix123123suffix" -> "%(`prefix` + (`123` * N) + `suffix`)" $ N' -i 'prefix123123suffix'
  
  =================@main==================
  "prefix123123suffix" -> "%(`prefix` + (`123` * N) + `suffix`)" $ N
  ========================================
  0000    | PushCharVar N
  0002    | CallFunctionConstant 0: "prefix123123suffix"
  0004    | Destructure 0: "%("prefix" + ("123" * N) + "suffix")"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 0
  0011    | End
  ========================================

  $ possum -p '"" -> ("" * N)' -i ''
  
  =================@main==================
  "" -> ("" * N)
  ========================================
  0000    | PushCharVar N
  0002    | PushEmptyString
  0003    | Destructure 0: ("" * N)
  0005    | End
  ========================================

  $ possum -p '"" -> "%(`` * N)"' -i ''
  
  =================@main==================
  "" -> "%(`` * N)"
  ========================================
  0000    | PushCharVar N
  0002    | PushEmptyString
  0003    | Destructure 0: "%(("" * N))"
  0005    | End
  ========================================

  $ possum -p '"" $ 0 -> (0 * N)' -i ''
  
  =================@main==================
  "" $ 0 -> (0 * N)
  ========================================
  0000    | PushCharVar N
  0002    | PushNumberZero
  0003    | Destructure 0: (0 * N)
  0005    | End
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
  0000    | PushCharVar N
  0002    | GetConstant 0: const
  0004    | PushTrue
  0005    | CallFunction 1
  0007    | Destructure 0: (true * N)
  0009    | End
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
  0000    | PushCharVar N
  0002    | GetConstant 0: const
  0004    | PushFalse
  0005    | CallFunction 1
  0007    | Destructure 0: (false * N)
  0009    | End
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
