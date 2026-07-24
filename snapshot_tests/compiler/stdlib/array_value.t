  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  
  =============1:Array.First==============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushVar F
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 34
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 32
  0016    | MatchLenMin r0 1 -> 32
  0021    | MatchElem r1 r0[0]
  0026    | MatchBind l1 r1
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | MatchWindowExit
  0034    | TakeRight 34 -> 39
  0037    | GetLocalMove l1
  0039    | End
  ========================================
  
  ==============1:Array.Rest==============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushVar R
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 34
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 32
  0016    | MatchLenMin r0 1 -> 32
  0021    | MatchSlice r1 r0[1..^0]
  0026    | MatchBind l1 r1
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | MatchWindowExit
  0034    | TakeRight 34 -> 39
  0037    | GetLocalMove l1
  0039    | End
  ========================================
  
  =============1:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushVar L
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 5
  0009    | MatchScrutinee r0
  0011    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 24
  0018    | MatchBind l1 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 31
  0029    | GetLocalMove l1
  0031    | End
  ========================================
  
  ============1:Array.Reverse=============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant 0: _Array.Reverse
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ============1:_Array.Reverse============
  _Array.Reverse(A, Acc) =
    A -> [First, ...Rest] ? _Array.Reverse(Rest, [First, ...Acc]) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 45
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 43
  0019    | MatchLenMin r0 1 -> 43
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l2 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l3 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 69
  0048    | GetConstant 0: _Array.Reverse
  0050    | GetLocalMove l3
  0052    | GetConstantMutable 1: [_]
  0054    | GetLocalMove l2
  0056    | InsertAtIndex 0
  0058    | JumpIfFailure 58 -> 64
  0061    | GetLocalMove l1
  0063    | Merge
  0064    | CallTailFunction 2
  0066    | Jump 66 -> 71
  0069    | GetLocalMove l1
  0071    | End
  ========================================
  
  ==============1:Array.Map===============
  Array.Map(A, Fn) = _Array.Map(A, Fn, [])
  ========================================
  0000    | GetConstant 2: _Array.Map
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushEmptyArray
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ==============1:_Array.Map==============
  _Array.Map(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.Map(Rest, Fn, [...Acc, Fn(First)]) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 45
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 43
  0019    | MatchLenMin r0 1 -> 43
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 80
  0048    | GetConstant 2: _Array.Map
  0050    | GetLocalMove l4
  0052    | GetLocal l1
  0054    | PushEmptyArray
  0055    | JumpIfFailure 55 -> 61
  0058    | GetLocalMove l2
  0060    | Merge
  0061    | JumpIfFailure 61 -> 75
  0064    | GetConstantMutable 3: [_]
  0066    | GetLocalMove l1
  0068    | GetLocalMove l3
  0070    | CallFunction 1
  0072    | InsertAtIndex 0
  0074    | Merge
  0075    | CallTailFunction 3
  0077    | Jump 77 -> 82
  0080    | GetLocalMove l2
  0082    | End
  ========================================
  
  =============1:Array.Filter=============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant 4: _Array.Filter
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushEmptyArray
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ============1:_Array.Filter=============
  _Array.Filter(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Filter(Rest, Pred, Pred(First) ? [...Acc, First] : Acc) :
    Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 45
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 43
  0019    | MatchLenMin r0 1 -> 43
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 91
  0048    | GetConstant 4: _Array.Filter
  0050    | GetLocalMove l4
  0052    | GetLocal l1
  0054    | SetInputMark
  0055    | GetLocalMove l1
  0057    | GetLocal l3
  0059    | CallFunction 1
  0061    | ConditionalThen 61 -> 84
  0064    | PushEmptyArray
  0065    | JumpIfFailure 65 -> 71
  0068    | GetLocalMove l2
  0070    | Merge
  0071    | JumpIfFailure 71 -> 81
  0074    | GetConstantMutable 5: [_]
  0076    | GetLocalMove l3
  0078    | InsertAtIndex 0
  0080    | Merge
  0081    | Jump 81 -> 86
  0084    | GetLocalMove l2
  0086    | CallTailFunction 3
  0088    | Jump 88 -> 93
  0091    | GetLocalMove l2
  0093    | End
  ========================================
  
  =============1:Array.Reject=============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant 6: _Array.Reject
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushEmptyArray
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ============1:_Array.Reject=============
  _Array.Reject(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reject(Rest, Pred, Pred(First) ? Acc : [...Acc, First]) :
    Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 45
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 43
  0019    | MatchLenMin r0 1 -> 43
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 91
  0048    | GetConstant 6: _Array.Reject
  0050    | GetLocalMove l4
  0052    | GetLocal l1
  0054    | SetInputMark
  0055    | GetLocalMove l1
  0057    | GetLocal l3
  0059    | CallFunction 1
  0061    | ConditionalThen 61 -> 69
  0064    | GetLocalMove l2
  0066    | Jump 66 -> 86
  0069    | PushEmptyArray
  0070    | JumpIfFailure 70 -> 76
  0073    | GetLocalMove l2
  0075    | Merge
  0076    | JumpIfFailure 76 -> 86
  0079    | GetConstantMutable 7: [_]
  0081    | GetLocalMove l3
  0083    | InsertAtIndex 0
  0085    | Merge
  0086    | CallTailFunction 3
  0088    | Jump 88 -> 93
  0091    | GetLocalMove l2
  0093    | End
  ========================================
  
  =============1:Array.Merge==============
  Array.Merge(A) = _Array.Merge(A, null)
  ========================================
  0000    | GetConstant 8: _Array.Merge
  0002    | GetLocalMove l0
  0004    | PushNull
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  =============1:_Array.Merge=============
  _Array.Merge(A, Acc) =
    A -> [First, ...Rest] ? _Array.Merge(Rest, Acc + First) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 45
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 43
  0019    | MatchLenMin r0 1 -> 43
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l2 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l3 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 65
  0048    | GetConstant 8: _Array.Merge
  0050    | GetLocalMove l3
  0052    | GetLocalMove l1
  0054    | JumpIfFailure 54 -> 60
  0057    | GetLocalMove l2
  0059    | Merge
  0060    | CallTailFunction 2
  0062    | Jump 62 -> 67
  0065    | GetLocalMove l1
  0067    | End
  ========================================
  
  ============1:Array.MapMerge============
  Array.MapMerge(A, Fn) = _Array.MapMerge(A, Fn, null)
  ========================================
  0000    | GetConstant 9: _Array.MapMerge
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushNull
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ===========1:_Array.MapMerge============
  _Array.MapMerge(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.MapMerge(Rest, Fn, Acc + Fn(First)) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 45
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 43
  0019    | MatchLenMin r0 1 -> 43
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 71
  0048    | GetConstant 9: _Array.MapMerge
  0050    | GetLocalMove l4
  0052    | GetLocal l1
  0054    | GetLocalMove l2
  0056    | JumpIfFailure 56 -> 66
  0059    | GetLocalMove l1
  0061    | GetLocalMove l3
  0063    | CallFunction 1
  0065    | Merge
  0066    | CallTailFunction 3
  0068    | Jump 68 -> 73
  0071    | GetLocalMove l2
  0073    | End
  ========================================
  
  =============1:Array.Reduce=============
  Array.Reduce(A, Fn, Acc) =
    A -> [First, ...Rest] ? Array.Reduce(Rest, Fn, Fn(Acc, First)) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 45
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 43
  0019    | MatchLenMin r0 1 -> 43
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 67
  0048    | GetConstant 10: Array.Reduce
  0050    | GetLocalMove l4
  0052    | GetLocal l1
  0054    | GetLocalMove l1
  0056    | GetLocalMove l2
  0058    | GetLocalMove l3
  0060    | CallFunction 2
  0062    | CallTailFunction 3
  0064    | Jump 64 -> 69
  0067    | GetLocalMove l2
  0069    | End
  ========================================
  
  ===========1:Array.ZipObject============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant 11: _Array.ZipObject
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushEmptyObject
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ===========1:_Array.ZipObject===========
  _Array.ZipObject(Ks, Vs, Acc) =
    Ks -> [K, ...KsRest] & Vs -> [V, ...VsRest] ?
    _Array.ZipObject(KsRest, VsRest, {...Acc, K: V}) :
    Acc
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 KsRest
  0006    | PushVar2 V
  0009    | PushVar2 VsRest
  0012    | SetInputMark
  0013    | GetLocalMove l0
  0015    | JumpIfFailure 15 -> 53
  0018    | MatchWindowEnter 4
  0020    | MatchScrutinee r0
  0022    | MatchType r0 array -> 51
  0027    | MatchLenMin r0 1 -> 51
  0032    | MatchElem r1 r0[0]
  0037    | MatchBind l3 r1
  0040    | MatchSlice r2 r0[1..^0]
  0045    | MatchBind l4 r2
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | MatchWindowExit
  0053    | TakeRight 53 -> 96
  0056    | GetLocalMove l1
  0058    | JumpIfFailure 58 -> 96
  0061    | MatchWindowEnter 4
  0063    | MatchScrutinee r0
  0065    | MatchType r0 array -> 94
  0070    | MatchLenMin r0 1 -> 94
  0075    | MatchElem r1 r0[0]
  0080    | MatchBind l5 r1
  0083    | MatchSlice r2 r0[1..^0]
  0088    | MatchBind l6 r2
  0091    | Jump 91 -> 95
  0094    | MatchFail
  0095    | MatchWindowExit
  0096    | ConditionalThen 96 -> 129
  0099    | GetConstant 11: _Array.ZipObject
  0101    | GetLocalMove l4
  0103    | GetLocalMove l6
  0105    | PushEmptyObject
  0106    | JumpIfFailure 106 -> 112
  0109    | GetLocalMove l2
  0111    | Merge
  0112    | JumpIfFailure 112 -> 124
  0115    | GetConstantMutable 12: {_0_}
  0117    | GetLocalMove l3
  0119    | GetLocalMove l5
  0121    | InsertKeyVal 0
  0123    | Merge
  0124    | CallTailFunction 3
  0126    | Jump 126 -> 131
  0129    | GetLocalMove l2
  0131    | End
  ========================================
  
  ============1:Array.ZipPairs============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant 13: _Array.ZipPairs
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushEmptyArray
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ===========1:_Array.ZipPairs============
  _Array.ZipPairs(A1, A2, Acc) =
    A1 -> [First1, ...Rest1] & A2 -> [First2, ...Rest2] ?
    _Array.ZipPairs(Rest1, Rest2, [...Acc, [First1, First2]]) :
    Acc
  ========================================
  0000    | PushVar2 First1
  0003    | PushVar2 Rest1
  0006    | PushVar2 First2
  0009    | PushVar2 Rest2
  0012    | SetInputMark
  0013    | GetLocalMove l0
  0015    | JumpIfFailure 15 -> 53
  0018    | MatchWindowEnter 4
  0020    | MatchScrutinee r0
  0022    | MatchType r0 array -> 51
  0027    | MatchLenMin r0 1 -> 51
  0032    | MatchElem r1 r0[0]
  0037    | MatchBind l3 r1
  0040    | MatchSlice r2 r0[1..^0]
  0045    | MatchBind l4 r2
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | MatchWindowExit
  0053    | TakeRight 53 -> 96
  0056    | GetLocalMove l1
  0058    | JumpIfFailure 58 -> 96
  0061    | MatchWindowEnter 4
  0063    | MatchScrutinee r0
  0065    | MatchType r0 array -> 94
  0070    | MatchLenMin r0 1 -> 94
  0075    | MatchElem r1 r0[0]
  0080    | MatchBind l5 r1
  0083    | MatchSlice r2 r0[1..^0]
  0088    | MatchBind l6 r2
  0091    | Jump 91 -> 95
  0094    | MatchFail
  0095    | MatchWindowExit
  0096    | ConditionalThen 96 -> 135
  0099    | GetConstant 13: _Array.ZipPairs
  0101    | GetLocalMove l4
  0103    | GetLocalMove l6
  0105    | PushEmptyArray
  0106    | JumpIfFailure 106 -> 112
  0109    | GetLocalMove l2
  0111    | Merge
  0112    | JumpIfFailure 112 -> 130
  0115    | GetConstantMutable 14: [_]
  0117    | GetConstantMutable 15: [_, _]
  0119    | GetLocalMove l3
  0121    | InsertAtIndex 0
  0123    | GetLocalMove l5
  0125    | InsertAtIndex 1
  0127    | InsertAtIndex 0
  0129    | Merge
  0130    | CallTailFunction 3
  0132    | Jump 132 -> 137
  0135    | GetLocalMove l2
  0137    | End
  ========================================
  
  ============1:Array.AppendN=============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstantMutable 16: [_]
  0007    | GetLocalMove l1
  0009    | InsertAtIndex 0
  0011    | GetLocalMove l2
  0013    | RepeatValue
  0014    | Merge
  0015    | End
  ========================================
  
  ===========1:Table.Transpose============
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant 17: _Table.Transpose
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ===========1:_Table.Transpose===========
  _Table.Transpose(T, Acc) =
    _Table.FirstPerRow(T) -> FirstPerRow &
    _Table.RestPerRow(T) -> RestPerRow ?
    _Table.Transpose(RestPerRow, [...Acc, FirstPerRow]) :
    Acc
  ========================================
  0000    | PushVar2 FirstPerRow
  0003    | PushVar2 RestPerRow
  0006    | SetInputMark
  0007    | GetConstant 18: _Table.FirstPerRow
  0009    | GetLocal l0
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 24
  0016    | MatchWindowEnter 2
  0018    | MatchScrutinee r0
  0020    | MatchBind l2 r0
  0023    | MatchWindowExit
  0024    | TakeRight 24 -> 44
  0027    | GetConstant 19: _Table.RestPerRow
  0029    | GetLocalMove l0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 44
  0036    | MatchWindowEnter 2
  0038    | MatchScrutinee r0
  0040    | MatchBind l3 r0
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 73
  0047    | GetConstant 17: _Table.Transpose
  0049    | GetLocalMove l3
  0051    | PushEmptyArray
  0052    | JumpIfFailure 52 -> 58
  0055    | GetLocalMove l1
  0057    | Merge
  0058    | JumpIfFailure 58 -> 68
  0061    | GetConstantMutable 20: [_]
  0063    | GetLocalMove l2
  0065    | InsertAtIndex 0
  0067    | Merge
  0068    | CallTailFunction 2
  0070    | Jump 70 -> 75
  0073    | GetLocalMove l1
  0075    | End
  ========================================
  
  ==========1:_Table.FirstPerRow==========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar Rest
  0005    | PushVar2 VeryFirst
  0008    | GetLocalMove l0
  0010    | JumpIfFailure 10 -> 48
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 46
  0022    | MatchLenMin r0 1 -> 46
  0027    | MatchElem r1 r0[0]
  0032    | MatchBind l1 r1
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l2 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | TakeRight 48 -> 83
  0051    | GetLocalMove l1
  0053    | JumpIfFailure 53 -> 83
  0056    | MatchWindowEnter 3
  0058    | MatchScrutinee r0
  0060    | MatchType r0 array -> 81
  0065    | MatchLenMin r0 1 -> 81
  0070    | MatchElem r1 r0[0]
  0075    | MatchBind l3 r1
  0078    | Jump 78 -> 82
  0081    | MatchFail
  0082    | MatchWindowExit
  0083    | TakeRight 83 -> 98
  0086    | GetConstant 21: __Table.FirstPerRow
  0088    | GetLocalMove l2
  0090    | GetConstantMutable 22: [_]
  0092    | GetLocalMove l3
  0094    | InsertAtIndex 0
  0096    | CallTailFunction 2
  0098    | End
  ========================================
  
  =========1:__Table.FirstPerRow==========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar Rest
  0005    | PushVar First
  0007    | SetInputMark
  0008    | GetLocalMove l0
  0010    | JumpIfFailure 10 -> 48
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 46
  0022    | MatchLenMin r0 1 -> 46
  0027    | MatchElem r1 r0[0]
  0032    | MatchBind l2 r1
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l3 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | TakeRight 48 -> 83
  0051    | GetLocalMove l2
  0053    | JumpIfFailure 53 -> 83
  0056    | MatchWindowEnter 3
  0058    | MatchScrutinee r0
  0060    | MatchType r0 array -> 81
  0065    | MatchLenMin r0 1 -> 81
  0070    | MatchElem r1 r0[0]
  0075    | MatchBind l4 r1
  0078    | Jump 78 -> 82
  0081    | MatchFail
  0082    | MatchWindowExit
  0083    | ConditionalThen 83 -> 112
  0086    | GetConstant 21: __Table.FirstPerRow
  0088    | GetLocalMove l3
  0090    | PushEmptyArray
  0091    | JumpIfFailure 91 -> 97
  0094    | GetLocalMove l1
  0096    | Merge
  0097    | JumpIfFailure 97 -> 107
  0100    | GetConstantMutable 23: [_]
  0102    | GetLocalMove l4
  0104    | InsertAtIndex 0
  0106    | Merge
  0107    | CallTailFunction 2
  0109    | Jump 109 -> 114
  0112    | GetLocalMove l1
  0114    | End
  ========================================
  
  ==========1:_Table.RestPerRow===========
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant 24: __Table.RestPerRow
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ==========1:__Table.RestPerRow==========
  __Table.RestPerRow(T, Acc) =
    T -> [Row, ...Rest] ? (
      Row -> [_, ...RowRest] ?
      __Table.RestPerRow(Rest, [...Acc, RowRest]) :
      __Table.RestPerRow(Rest, [...Acc, []])
    ) :
    Acc
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar Rest
  0005    | PushVar2 RowRest
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 49
  0014    | MatchWindowEnter 4
  0016    | MatchScrutinee r0
  0018    | MatchType r0 array -> 47
  0023    | MatchLenMin r0 1 -> 47
  0028    | MatchElem r1 r0[0]
  0033    | MatchBind l2 r1
  0036    | MatchSlice r2 r0[1..^0]
  0041    | MatchBind l3 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | ConditionalThen 49 -> 136
  0052    | SetInputMark
  0053    | GetLocalMove l2
  0055    | JumpIfFailure 55 -> 85
  0058    | MatchWindowEnter 3
  0060    | MatchScrutinee r0
  0062    | MatchType r0 array -> 83
  0067    | MatchLenMin r0 1 -> 83
  0072    | MatchSlice r1 r0[1..^0]
  0077    | MatchBind l4 r1
  0080    | Jump 80 -> 84
  0083    | MatchFail
  0084    | MatchWindowExit
  0085    | ConditionalThen 85 -> 114
  0088    | GetConstant 24: __Table.RestPerRow
  0090    | GetLocalMove l3
  0092    | PushEmptyArray
  0093    | JumpIfFailure 93 -> 99
  0096    | GetLocalMove l1
  0098    | Merge
  0099    | JumpIfFailure 99 -> 109
  0102    | GetConstantMutable 25: [_]
  0104    | GetLocalMove l4
  0106    | InsertAtIndex 0
  0108    | Merge
  0109    | CallTailFunction 2
  0111    | Jump 111 -> 133
  0114    | GetConstant 24: __Table.RestPerRow
  0116    | GetLocalMove l3
  0118    | PushEmptyArray
  0119    | JumpIfFailure 119 -> 125
  0122    | GetLocalMove l1
  0124    | Merge
  0125    | JumpIfFailure 125 -> 131
  0128    | GetConstant 26: [[]]
  0130    | Merge
  0131    | CallTailFunction 2
  0133    | Jump 133 -> 138
  0136    | GetLocalMove l1
  0138    | End
  ========================================
  
  ========1:Table.RotateClockwise=========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant 27: Array.Map
  0002    | GetConstant 28: Table.Transpose
  0004    | GetLocalMove l0
  0006    | CallFunction 1
  0008    | GetConstant 29: Array.Reverse
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  =====1:Table.RotateCounterClockwise=====
  Table.RotateCounterClockwise(T) = Array.Reverse(Table.Transpose(T))
  ========================================
  0000    | GetConstant 29: Array.Reverse
  0002    | GetConstant 28: Table.Transpose
  0004    | GetLocalMove l0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ===========1:Table.ZipObjects===========
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant 30: _Table.ZipObjects
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushEmptyArray
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ==========1:_Table.ZipObjects===========
  _Table.ZipObjects(Ks, Rows, Acc) =
    Rows -> [Row, ...Rest] ?
    _Table.ZipObjects(Ks, Rest, [...Acc, Array.ZipObject(Ks, Row)]) :
    Acc
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar Rest
  0005    | SetInputMark
  0006    | GetLocalMove l1
  0008    | JumpIfFailure 8 -> 46
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 44
  0020    | MatchLenMin r0 1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 83
  0049    | GetConstant 30: _Table.ZipObjects
  0051    | GetLocal l0
  0053    | GetLocalMove l4
  0055    | PushEmptyArray
  0056    | JumpIfFailure 56 -> 62
  0059    | GetLocalMove l2
  0061    | Merge
  0062    | JumpIfFailure 62 -> 78
  0065    | GetConstantMutable 31: [_]
  0067    | GetConstant 32: Array.ZipObject
  0069    | GetLocalMove l0
  0071    | GetLocalMove l3
  0073    | CallFunction 2
  0075    | InsertAtIndex 0
  0077    | Merge
  0078    | CallTailFunction 3
  0080    | Jump 80 -> 85
  0083    | GetLocalMove l2
  0085    | End
  ========================================
