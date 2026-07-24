  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  
  =============1:Array.First==============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushVar F
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 35
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 33
  0016    | MatchCount r0 >=1 -> 33
  0022    | MatchElem r1 r0[0]
  0027    | MatchBind l1 r1
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | TakeRight 35 -> 40
  0038    | GetLocalMove l1
  0040    | End
  ========================================
  
  ==============1:Array.Rest==============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushVar R
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 35
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 33
  0016    | MatchCount r0 >=1 -> 33
  0022    | MatchSlice r1 r0[1..^0]
  0027    | MatchBind l1 r1
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | TakeRight 35 -> 40
  0038    | GetLocalMove l1
  0040    | End
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
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l2 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l3 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 70
  0049    | GetConstant 0: _Array.Reverse
  0051    | GetLocalMove l3
  0053    | GetConstantMutable 1: [_]
  0055    | GetLocalMove l2
  0057    | InsertAtIndex 0
  0059    | JumpIfFailure 59 -> 65
  0062    | GetLocalMove l1
  0064    | Merge
  0065    | CallTailFunction 2
  0067    | Jump 67 -> 72
  0070    | GetLocalMove l1
  0072    | End
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
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 81
  0049    | GetConstant 2: _Array.Map
  0051    | GetLocalMove l4
  0053    | GetLocal l1
  0055    | PushEmptyArray
  0056    | JumpIfFailure 56 -> 62
  0059    | GetLocalMove l2
  0061    | Merge
  0062    | JumpIfFailure 62 -> 76
  0065    | GetConstantMutable 3: [_]
  0067    | GetLocalMove l1
  0069    | GetLocalMove l3
  0071    | CallFunction 1
  0073    | InsertAtIndex 0
  0075    | Merge
  0076    | CallTailFunction 3
  0078    | Jump 78 -> 83
  0081    | GetLocalMove l2
  0083    | End
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
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 92
  0049    | GetConstant 4: _Array.Filter
  0051    | GetLocalMove l4
  0053    | GetLocal l1
  0055    | SetInputMark
  0056    | GetLocalMove l1
  0058    | GetLocal l3
  0060    | CallFunction 1
  0062    | ConditionalThen 62 -> 85
  0065    | PushEmptyArray
  0066    | JumpIfFailure 66 -> 72
  0069    | GetLocalMove l2
  0071    | Merge
  0072    | JumpIfFailure 72 -> 82
  0075    | GetConstantMutable 5: [_]
  0077    | GetLocalMove l3
  0079    | InsertAtIndex 0
  0081    | Merge
  0082    | Jump 82 -> 87
  0085    | GetLocalMove l2
  0087    | CallTailFunction 3
  0089    | Jump 89 -> 94
  0092    | GetLocalMove l2
  0094    | End
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
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 92
  0049    | GetConstant 6: _Array.Reject
  0051    | GetLocalMove l4
  0053    | GetLocal l1
  0055    | SetInputMark
  0056    | GetLocalMove l1
  0058    | GetLocal l3
  0060    | CallFunction 1
  0062    | ConditionalThen 62 -> 70
  0065    | GetLocalMove l2
  0067    | Jump 67 -> 87
  0070    | PushEmptyArray
  0071    | JumpIfFailure 71 -> 77
  0074    | GetLocalMove l2
  0076    | Merge
  0077    | JumpIfFailure 77 -> 87
  0080    | GetConstantMutable 7: [_]
  0082    | GetLocalMove l3
  0084    | InsertAtIndex 0
  0086    | Merge
  0087    | CallTailFunction 3
  0089    | Jump 89 -> 94
  0092    | GetLocalMove l2
  0094    | End
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
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l2 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l3 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 66
  0049    | GetConstant 8: _Array.Merge
  0051    | GetLocalMove l3
  0053    | GetLocalMove l1
  0055    | JumpIfFailure 55 -> 61
  0058    | GetLocalMove l2
  0060    | Merge
  0061    | CallTailFunction 2
  0063    | Jump 63 -> 68
  0066    | GetLocalMove l1
  0068    | End
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
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 72
  0049    | GetConstant 9: _Array.MapMerge
  0051    | GetLocalMove l4
  0053    | GetLocal l1
  0055    | GetLocalMove l2
  0057    | JumpIfFailure 57 -> 67
  0060    | GetLocalMove l1
  0062    | GetLocalMove l3
  0064    | CallFunction 1
  0066    | Merge
  0067    | CallTailFunction 3
  0069    | Jump 69 -> 74
  0072    | GetLocalMove l2
  0074    | End
  ========================================
  
  =============1:Array.Reduce=============
  Array.Reduce(A, Fn, Acc) =
    A -> [First, ...Rest] ? Array.Reduce(Rest, Fn, Fn(Acc, First)) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 68
  0049    | GetConstant 10: Array.Reduce
  0051    | GetLocalMove l4
  0053    | GetLocal l1
  0055    | GetLocalMove l1
  0057    | GetLocalMove l2
  0059    | GetLocalMove l3
  0061    | CallFunction 2
  0063    | CallTailFunction 3
  0065    | Jump 65 -> 70
  0068    | GetLocalMove l2
  0070    | End
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
  0015    | JumpIfFailure 15 -> 54
  0018    | MatchWindowEnter 4
  0020    | MatchScrutinee r0
  0022    | MatchType r0 array -> 52
  0027    | MatchCount r0 >=1 -> 52
  0033    | MatchElem r1 r0[0]
  0038    | MatchBind l3 r1
  0041    | MatchSlice r2 r0[1..^0]
  0046    | MatchBind l4 r2
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | TakeRight 54 -> 98
  0057    | GetLocalMove l1
  0059    | JumpIfFailure 59 -> 98
  0062    | MatchWindowEnter 4
  0064    | MatchScrutinee r0
  0066    | MatchType r0 array -> 96
  0071    | MatchCount r0 >=1 -> 96
  0077    | MatchElem r1 r0[0]
  0082    | MatchBind l5 r1
  0085    | MatchSlice r2 r0[1..^0]
  0090    | MatchBind l6 r2
  0093    | Jump 93 -> 97
  0096    | MatchFail
  0097    | MatchWindowExit
  0098    | ConditionalThen 98 -> 131
  0101    | GetConstant 11: _Array.ZipObject
  0103    | GetLocalMove l4
  0105    | GetLocalMove l6
  0107    | PushEmptyObject
  0108    | JumpIfFailure 108 -> 114
  0111    | GetLocalMove l2
  0113    | Merge
  0114    | JumpIfFailure 114 -> 126
  0117    | GetConstantMutable 12: {_0_}
  0119    | GetLocalMove l3
  0121    | GetLocalMove l5
  0123    | InsertKeyVal 0
  0125    | Merge
  0126    | CallTailFunction 3
  0128    | Jump 128 -> 133
  0131    | GetLocalMove l2
  0133    | End
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
  0015    | JumpIfFailure 15 -> 54
  0018    | MatchWindowEnter 4
  0020    | MatchScrutinee r0
  0022    | MatchType r0 array -> 52
  0027    | MatchCount r0 >=1 -> 52
  0033    | MatchElem r1 r0[0]
  0038    | MatchBind l3 r1
  0041    | MatchSlice r2 r0[1..^0]
  0046    | MatchBind l4 r2
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | TakeRight 54 -> 98
  0057    | GetLocalMove l1
  0059    | JumpIfFailure 59 -> 98
  0062    | MatchWindowEnter 4
  0064    | MatchScrutinee r0
  0066    | MatchType r0 array -> 96
  0071    | MatchCount r0 >=1 -> 96
  0077    | MatchElem r1 r0[0]
  0082    | MatchBind l5 r1
  0085    | MatchSlice r2 r0[1..^0]
  0090    | MatchBind l6 r2
  0093    | Jump 93 -> 97
  0096    | MatchFail
  0097    | MatchWindowExit
  0098    | ConditionalThen 98 -> 137
  0101    | GetConstant 13: _Array.ZipPairs
  0103    | GetLocalMove l4
  0105    | GetLocalMove l6
  0107    | PushEmptyArray
  0108    | JumpIfFailure 108 -> 114
  0111    | GetLocalMove l2
  0113    | Merge
  0114    | JumpIfFailure 114 -> 132
  0117    | GetConstantMutable 14: [_]
  0119    | GetConstantMutable 15: [_, _]
  0121    | GetLocalMove l3
  0123    | InsertAtIndex 0
  0125    | GetLocalMove l5
  0127    | InsertAtIndex 1
  0129    | InsertAtIndex 0
  0131    | Merge
  0132    | CallTailFunction 3
  0134    | Jump 134 -> 139
  0137    | GetLocalMove l2
  0139    | End
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
  0010    | JumpIfFailure 10 -> 49
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 47
  0022    | MatchCount r0 >=1 -> 47
  0028    | MatchElem r1 r0[0]
  0033    | MatchBind l1 r1
  0036    | MatchSlice r2 r0[1..^0]
  0041    | MatchBind l2 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | TakeRight 49 -> 85
  0052    | GetLocalMove l1
  0054    | JumpIfFailure 54 -> 85
  0057    | MatchWindowEnter 3
  0059    | MatchScrutinee r0
  0061    | MatchType r0 array -> 83
  0066    | MatchCount r0 >=1 -> 83
  0072    | MatchElem r1 r0[0]
  0077    | MatchBind l3 r1
  0080    | Jump 80 -> 84
  0083    | MatchFail
  0084    | MatchWindowExit
  0085    | TakeRight 85 -> 100
  0088    | GetConstant 21: __Table.FirstPerRow
  0090    | GetLocalMove l2
  0092    | GetConstantMutable 22: [_]
  0094    | GetLocalMove l3
  0096    | InsertAtIndex 0
  0098    | CallTailFunction 2
  0100    | End
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
  0010    | JumpIfFailure 10 -> 49
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 47
  0022    | MatchCount r0 >=1 -> 47
  0028    | MatchElem r1 r0[0]
  0033    | MatchBind l2 r1
  0036    | MatchSlice r2 r0[1..^0]
  0041    | MatchBind l3 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | TakeRight 49 -> 85
  0052    | GetLocalMove l2
  0054    | JumpIfFailure 54 -> 85
  0057    | MatchWindowEnter 3
  0059    | MatchScrutinee r0
  0061    | MatchType r0 array -> 83
  0066    | MatchCount r0 >=1 -> 83
  0072    | MatchElem r1 r0[0]
  0077    | MatchBind l4 r1
  0080    | Jump 80 -> 84
  0083    | MatchFail
  0084    | MatchWindowExit
  0085    | ConditionalThen 85 -> 114
  0088    | GetConstant 21: __Table.FirstPerRow
  0090    | GetLocalMove l3
  0092    | PushEmptyArray
  0093    | JumpIfFailure 93 -> 99
  0096    | GetLocalMove l1
  0098    | Merge
  0099    | JumpIfFailure 99 -> 109
  0102    | GetConstantMutable 23: [_]
  0104    | GetLocalMove l4
  0106    | InsertAtIndex 0
  0108    | Merge
  0109    | CallTailFunction 2
  0111    | Jump 111 -> 116
  0114    | GetLocalMove l1
  0116    | End
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
  0011    | JumpIfFailure 11 -> 50
  0014    | MatchWindowEnter 4
  0016    | MatchScrutinee r0
  0018    | MatchType r0 array -> 48
  0023    | MatchCount r0 >=1 -> 48
  0029    | MatchElem r1 r0[0]
  0034    | MatchBind l2 r1
  0037    | MatchSlice r2 r0[1..^0]
  0042    | MatchBind l3 r2
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | ConditionalThen 50 -> 138
  0053    | SetInputMark
  0054    | GetLocalMove l2
  0056    | JumpIfFailure 56 -> 87
  0059    | MatchWindowEnter 3
  0061    | MatchScrutinee r0
  0063    | MatchType r0 array -> 85
  0068    | MatchCount r0 >=1 -> 85
  0074    | MatchSlice r1 r0[1..^0]
  0079    | MatchBind l4 r1
  0082    | Jump 82 -> 86
  0085    | MatchFail
  0086    | MatchWindowExit
  0087    | ConditionalThen 87 -> 116
  0090    | GetConstant 24: __Table.RestPerRow
  0092    | GetLocalMove l3
  0094    | PushEmptyArray
  0095    | JumpIfFailure 95 -> 101
  0098    | GetLocalMove l1
  0100    | Merge
  0101    | JumpIfFailure 101 -> 111
  0104    | GetConstantMutable 25: [_]
  0106    | GetLocalMove l4
  0108    | InsertAtIndex 0
  0110    | Merge
  0111    | CallTailFunction 2
  0113    | Jump 113 -> 135
  0116    | GetConstant 24: __Table.RestPerRow
  0118    | GetLocalMove l3
  0120    | PushEmptyArray
  0121    | JumpIfFailure 121 -> 127
  0124    | GetLocalMove l1
  0126    | Merge
  0127    | JumpIfFailure 127 -> 133
  0130    | GetConstant 26: [[]]
  0132    | Merge
  0133    | CallTailFunction 2
  0135    | Jump 135 -> 140
  0138    | GetLocalMove l1
  0140    | End
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
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 45
  0020    | MatchCount r0 >=1 -> 45
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l3 r1
  0034    | MatchSlice r2 r0[1..^0]
  0039    | MatchBind l4 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | ConditionalThen 47 -> 84
  0050    | GetConstant 30: _Table.ZipObjects
  0052    | GetLocal l0
  0054    | GetLocalMove l4
  0056    | PushEmptyArray
  0057    | JumpIfFailure 57 -> 63
  0060    | GetLocalMove l2
  0062    | Merge
  0063    | JumpIfFailure 63 -> 79
  0066    | GetConstantMutable 31: [_]
  0068    | GetConstant 32: Array.ZipObject
  0070    | GetLocalMove l0
  0072    | GetLocalMove l3
  0074    | CallFunction 2
  0076    | InsertAtIndex 0
  0078    | Merge
  0079    | CallTailFunction 3
  0081    | Jump 81 -> 86
  0084    | GetLocalMove l2
  0086    | End
  ========================================
