  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'const([1,2,3]) -> [1,2,3]' -i ''
  
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
  
  =================@main==================
  const([1,2,3]) -> [A,B,C]
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: C
  0006    | GetConstant 3: const
  0008    | GetConstant 4: [1, 2, 3]
  0010    | CallFunction 1
  0012    | Destructure 0: [A, B, C]
  0014    | End
  ========================================

  $ possum -p 'A = 1 ; const([1,2,3]) -> [A,B,C]' -i ''
  
  =================@main==================
  const([1,2,3]) -> [A,B,C]
  ========================================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: C
  0004    | GetConstant 2: const
  0006    | GetConstant 3: [1, 2, 3]
  0008    | CallFunction 1
  0010    | Destructure 0: [A, B, C]
  0012    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 2, 3]' -i ''
  
  =================@main==================
  const([1,2,3]) -> [A, 2, 3]
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: [A, 2, 3]
  0010    | End
  ========================================

  $ possum -p 'const([1,[[2],3]]) -> [A, [[B], 3]] $ B' -i ''
  
  =================@main==================
  const([1,[[2],3]]) -> [A, [[B], 3]] $ B
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: const
  0006    | GetConstant 3: [1, _]
  0008    | GetConstant 4: [_, 3]
  0010    | GetConstant 5: [2]
  0012    | InsertAtIndex 0
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | Destructure 0: [A, [[B], 3]]
  0020    | TakeRight 20 -> 25
  0023    | GetBoundLocal 1
  0025    | End
  ========================================

  $ possum -p '3 -> (2 + B)' -i '3'
  
  =================@main==================
  3 -> (2 + B)
  ========================================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: 3
  0004    | CallFunction 0
  0006    | Destructure 0: (2 + B)
  0008    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 1 + 1, 3]' -i ''
  
  =================@main==================
  const([1,2,3]) -> [A, 1 + 1, 3]
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: [A, (1 + 1), 3]
  0010    | End
  ========================================

  $ possum -p 'const([1,2]) -> ([1] + [2])' -i ''
  
  =================@main==================
  const([1,2]) -> ([1] + [2])
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: [1, 2]
  0004    | CallFunction 1
  0006    | Destructure 0: ([1] + [2])
  0008    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> ([1] + B + [3])' -i ''
  
  =================@main==================
  const([1,2,3]) -> ([1] + B + [3])
  ========================================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: ([1] + B + [3])
  0010    | End
  ========================================

  $ possum -p 'const([1,[2],2,3]) -> ([1,A] + A + [3])' -i ''
  
  =================@main==================
  const([1,[2],2,3]) -> ([1,A] + A + [3])
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, _, 2, 3]
  0006    | GetConstant 3: [2]
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
  0002    | GetConstant 1: "foobar"
  0004    | CallFunction 0
  0006    | Destructure 0: ("fo" + Ob + "ar")
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 0
  0013    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [1, ...Rest] $ Rest' -i ''
  
  =================@main==================
  const([1,2,3]) -> [1, ...Rest] $ Rest
  ========================================
  0000    | GetConstant 0: Rest
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 2, 3]
  0006    | CallFunction 1
  0008    | Destructure 0: ([1] + Rest)
  0010    | TakeRight 10 -> 15
  0013    | GetBoundLocal 0
  0015    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, "b": 2}' -i ''
  
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
  
  =================@main==================
  const({"a": 1, "b": 2}) -> {"a": A, "b": B}
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: B
  0004    | GetConstant 2: const
  0006    | GetConstant 3: {"a": 1, "b": 2}
  0008    | CallFunction 1
  0010    | Destructure 0: {"a": A, "b": B}
  0012    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": _, "b": _}' -i ''
  
  =================@main==================
  const({"a": 1, "b": 2}) -> {"a": _, "b": _}
  ========================================
  0000    | GetConstant 0: _
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: {"a": _, "b": _}
  0010    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"a": 1} + B)' -i ''
  
  =================@main==================
  const({"a": 1, "b": 2}) -> ({"a": 1} + B)
  ========================================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: ({"a": 1} + B)
  0010    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"b": 2} + A)' -i ''
  
  =================@main==================
  const({"a": 1, "b": 2}) -> ({"b": 2} + A)
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: ({"b": 2} + A)
  0010    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> (A + {"b": 2})' -i ''
  
  =================@main==================
  const({"a": 1, "b": 2}) -> (A + {"b": 2})
  ========================================
  0000    | GetConstant 0: A
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: (A + {"b": 2})
  0010    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, ...B}' -i ''
  
  =================@main==================
  const({"a": 1, "b": 2}) -> {"a": 1, ...B}
  ========================================
  0000    | GetConstant 0: B
  0002    | GetConstant 1: const
  0004    | GetConstant 2: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | Destructure 0: ({"a": 1} + B)
  0010    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  =================@main==================
  2 -> 0..5
  ========================================
  0000    | GetConstant 0: 2
  0002    | CallFunction 0
  0004    | Destructure 0: 0..5
  0006    | End
  ========================================

  $ possum -p 'char -> "a".."z"' -i 'q'
  
  =================@main==================
  char -> "a".."z"
  ========================================
  0000    | GetConstant 0: char
  0002    | CallFunction 0
  0004    | Destructure 0: "a".."z"
  0006    | End
  ========================================

  $ possum -p 'char -> .."z"' -i '!'
  
  =================@main==================
  char -> .."z"
  ========================================
  0000    | GetConstant 0: char
  0002    | CallFunction 0
  0004    | Destructure 0: .."z"
  0006    | End
  ========================================

  $ possum -p 'const(Is.Array([1])) ; Is.Array(V) = V -> [..._]' -i '1'
  
  ================Is.Array================
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ([] + _)
  0006    | End
  ========================================
  
  =================@main==================
  const(Is.Array([1]))
  ========================================
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
  0004    | GetConstant 2: _
  0006    | GetConstant 3: RowRest
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ([Row] + Rest)
  0013    | ConditionalThen 13 -> 62
  0016    | SetInputMark
  0017    | GetBoundLocal 2
  0019    | Destructure 1: ([_] + RowRest)
  0021    | ConditionalThen 21 -> 45
  0024    | GetConstant 4: __Table.RestPerRow
  0026    | GetBoundLocal 3
  0028    | GetConstant 5: []
  0030    | GetBoundLocal 1
  0032    | Merge
  0033    | GetConstant 6: [_]
  0035    | GetBoundLocal 5
  0037    | InsertAtIndex 0
  0039    | Merge
  0040    | CallTailFunction 2
  0042    | ConditionalElse 42 -> 59
  0045    | GetConstant 7: __Table.RestPerRow
  0047    | GetBoundLocal 3
  0049    | GetConstant 8: []
  0051    | GetBoundLocal 1
  0053    | Merge
  0054    | GetConstant 9: [[]]
  0056    | Merge
  0057    | CallTailFunction 2
  0059    | ConditionalElse 59 -> 64
  0062    | GetBoundLocal 1
  0064    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p 'Obj.Get(O, K) = O -> {K: V, ..._} & V ; 1' -i '1'
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | GetConstant 0: V
  0002    | GetConstant 1: _
  0004    | GetBoundLocal 0
  0006    | Destructure 0: ({K: V} + _)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 2
  0013    | End
  ========================================
  
  =================@main==================
  1
  ========================================
  0000    | GetConstant 0: 1
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  
  =================@main==================
  4 -> (1 + 1 + 2)
  ========================================
  0000    | GetConstant 0: 4
  0002    | CallFunction 0
  0004    | Destructure 0: (1 + 1 + 2)
  0006    | End
  ========================================

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  =================@main==================
  5 -> (2 + 3)
  ========================================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | Destructure 0: (2 + 3)
  0006    | End
  ========================================

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  
  =================@main==================
  7 -> (X + 4)
  ========================================
  0000    | GetConstant 0: 7
  0002    | CallFunction 0
  0004    | Destructure 0: (X + 4)
  0006    | End
  ========================================

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  
  =================@main==================
  5 -> (X + Y)
  ========================================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | Destructure 0: (X + Y)
  0006    | End
  ========================================

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  
  =================@main==================
  6 -> (1 + X + 3) $ X
  ========================================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 6
  0004    | CallFunction 0
  0006    | Destructure 0: (1 + X + 3)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 0
  0013    | End
  ========================================

  $ possum -p '5 -> (2 - 3)' -i '5'
  
  =================@main==================
  5 -> (2 - 3)
  ========================================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | Destructure 0: (2 + -3)
  0006    | End
  ========================================

  $ possum -p '6 -> (1 + X - 3) $ X' -i '6'
  
  =================@main==================
  6 -> (1 + X - 3) $ X
  ========================================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 6
  0004    | CallFunction 0
  0006    | Destructure 0: (1 + X + -3)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 0
  0013    | End
  ========================================

  $ possum -p '6 -> (1 - X + 3) $ X' -i '6'
  
  =================@main==================
  6 -> (1 - X + 3) $ X
  ========================================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 6
  0004    | CallFunction 0
  0006    | Destructure 0: (1 + -X + 3)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 0
  0013    | End
  ========================================

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  
  =================@main==================
  5 -> (1 + 6 + 3 - (2 + 3))
  ========================================
  0000    | GetConstant 0: 5
  0002    | CallFunction 0
  0004    | Destructure 0: (1 + 6 + 3 + (-2 + -3))
  0006    | End
  ========================================

  $ possum -p '5 -> -(X + 1) $ X' -i '5'
  
  =================@main==================
  5 -> -(X + 1) $ X
  ========================================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: 5
  0004    | CallFunction 0
  0006    | Destructure 0: (-X + -1)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 0
  0013    | End
  ========================================

  $ possum -p 'const([1, 5, 2]) -> [1, -(X + 1), 2] $ X' -i ''
  
  =================@main==================
  const([1, 5, 2]) -> [1, -(X + 1), 2] $ X
  ========================================
  0000    | GetConstant 0: X
  0002    | GetConstant 1: const
  0004    | GetConstant 2: [1, 5, 2]
  0006    | CallFunction 1
  0008    | Destructure 0: [1, (-X + -1), 2]
  0010    | TakeRight 10 -> 15
  0013    | GetBoundLocal 0
  0015    | End
  ========================================

  $ possum -p '"1" -> "%(1)"' -i '1'
  
  =================@main==================
  "1" -> "%(1)"
  ========================================
  0000    | GetConstant 0: "1"
  0002    | CallFunction 0
  0004    | Destructure 0: "%(1)"
  0006    | End
  ========================================

  $ possum -p '"2" -> "%(1 + 1)"' -i '2'
  
  =================@main==================
  "2" -> "%(1 + 1)"
  ========================================
  0000    | GetConstant 0: "2"
  0002    | CallFunction 0
  0004    | Destructure 0: "%(1 + 1)"
  0006    | End
  ========================================

  $ possum -p '"50" -> "%(0 + N)" $ N' -i '50'
  
  =================@main==================
  "50" -> "%(0 + N)" $ N
  ========================================
  0000    | GetConstant 0: N
  0002    | GetConstant 1: "50"
  0004    | CallFunction 0
  0006    | Destructure 0: "%(0 + N)"
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 0
  0013    | End
  ========================================

  $ possum -p '"ab" * 3' -i 'ababab'
  
  =================@main==================
  "ab" * 3
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 3
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 26
  0008    | Swap
  0009    | GetConstant 2: "ab"
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 25
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 26
  0022    | JumpBack 22 -> 8
  0025    | Swap
  0026    | Drop
  0027    | End
  ========================================

  $ possum -p '2 * (2 * 2)' -i '2222'
  
  =================@main==================
  2 * (2 * 2)
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 4
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 26
  0008    | Swap
  0009    | GetConstant 2: 2
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 25
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 26
  0022    | JumpBack 22 -> 8
  0025    | Swap
  0026    | Drop
  0027    | End
  ========================================

  $ possum -p '2 * (2 + (-1 * -1))' -i '2222'
  
  =================@main==================
  2 * (2 + (-1 * -1))
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 3
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 26
  0008    | Swap
  0009    | GetConstant 2: 2
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 25
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 26
  0022    | JumpBack 22 -> 8
  0025    | Swap
  0026    | Drop
  0027    | End
  ========================================
