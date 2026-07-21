  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  
  =============1:Array.First==============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushVar F
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetLocalMove l0
  0008    | JumpIfFailure 8 -> 34
  0011    | MatchScrutinee r3
  0013    | MatchType r3 array -> 33
  0018    | MatchLenMin r3 1 -> 33
  0023    | MatchElem r4 r3[0]
  0027    | MatchBind l1 r4
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | TakeRight 34 -> 39
  0037    | GetLocalMove l1
  0039    | End
  ========================================
  
  ==============1:Array.Rest==============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar R
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetLocalMove l0
  0008    | JumpIfFailure 8 -> 35
  0011    | MatchScrutinee r3
  0013    | MatchType r3 array -> 34
  0018    | MatchLenMin r3 1 -> 34
  0023    | MatchSlice r4 r3[1..^0]
  0028    | MatchBind l2 r4
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | TakeRight 35 -> 40
  0038    | GetLocalMove l2
  0040    | End
  ========================================
  
  =============1:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar L
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | GetLocalMove l0
  0010    | JumpIfFailure 10 -> 29
  0013    | MatchScrutinee r3
  0015    | MatchRepeatInit r3 /1 n=r5 base=r6 -> 28
  0022    | MatchBind l2 r5
  0025    | Jump 25 -> 29
  0028    | MatchFail
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l2
  0034    | End
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r4
  0016    | MatchType r4 array -> 44
  0021    | MatchLenMin r4 1 -> 44
  0026    | MatchElem r5 r4[0]
  0030    | MatchBind l2 r5
  0033    | MatchSlice r6 r4[1..^0]
  0038    | MatchBind l3 r6
  0041    | Jump 41 -> 45
  0044    | MatchFail
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r5
  0016    | MatchType r5 array -> 44
  0021    | MatchLenMin r5 1 -> 44
  0026    | MatchElem r6 r5[0]
  0030    | MatchBind l3 r6
  0033    | MatchSlice r7 r5[1..^0]
  0038    | MatchBind l4 r7
  0041    | Jump 41 -> 45
  0044    | MatchFail
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r5
  0016    | MatchType r5 array -> 44
  0021    | MatchLenMin r5 1 -> 44
  0026    | MatchElem r6 r5[0]
  0030    | MatchBind l3 r6
  0033    | MatchSlice r7 r5[1..^0]
  0038    | MatchBind l4 r7
  0041    | Jump 41 -> 45
  0044    | MatchFail
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r5
  0016    | MatchType r5 array -> 44
  0021    | MatchLenMin r5 1 -> 44
  0026    | MatchElem r6 r5[0]
  0030    | MatchBind l3 r6
  0033    | MatchSlice r7 r5[1..^0]
  0038    | MatchBind l4 r7
  0041    | Jump 41 -> 45
  0044    | MatchFail
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r4
  0016    | MatchType r4 array -> 44
  0021    | MatchLenMin r4 1 -> 44
  0026    | MatchElem r5 r4[0]
  0030    | MatchBind l2 r5
  0033    | MatchSlice r6 r4[1..^0]
  0038    | MatchBind l3 r6
  0041    | Jump 41 -> 45
  0044    | MatchFail
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r5
  0016    | MatchType r5 array -> 44
  0021    | MatchLenMin r5 1 -> 44
  0026    | MatchElem r6 r5[0]
  0030    | MatchBind l3 r6
  0033    | MatchSlice r7 r5[1..^0]
  0038    | MatchBind l4 r7
  0041    | Jump 41 -> 45
  0044    | MatchFail
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r5
  0016    | MatchType r5 array -> 44
  0021    | MatchLenMin r5 1 -> 44
  0026    | MatchElem r6 r5[0]
  0030    | MatchBind l3 r6
  0033    | MatchSlice r7 r5[1..^0]
  0038    | MatchBind l4 r7
  0041    | Jump 41 -> 45
  0044    | MatchFail
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
  0012    | PushUnderscoreVar
  0013    | PushUnderscoreVar
  0014    | PushUnderscoreVar
  0015    | PushUnderscoreVar
  0016    | SetInputMark
  0017    | GetLocalMove l0
  0019    | JumpIfFailure 19 -> 53
  0022    | MatchScrutinee r7
  0024    | MatchType r7 array -> 52
  0029    | MatchLenMin r7 1 -> 52
  0034    | MatchElem r8 r7[0]
  0038    | MatchBind l3 r8
  0041    | MatchSlice r9 r7[1..^0]
  0046    | MatchBind l4 r9
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | TakeRight 53 -> 92
  0056    | GetLocalMove l1
  0058    | JumpIfFailure 58 -> 92
  0061    | MatchScrutinee r7
  0063    | MatchType r7 array -> 91
  0068    | MatchLenMin r7 1 -> 91
  0073    | MatchElem r8 r7[0]
  0077    | MatchBind l5 r8
  0080    | MatchSlice r9 r7[1..^0]
  0085    | MatchBind l6 r9
  0088    | Jump 88 -> 92
  0091    | MatchFail
  0092    | ConditionalThen 92 -> 125
  0095    | GetConstant 11: _Array.ZipObject
  0097    | GetLocalMove l4
  0099    | GetLocalMove l6
  0101    | PushEmptyObject
  0102    | JumpIfFailure 102 -> 108
  0105    | GetLocalMove l2
  0107    | Merge
  0108    | JumpIfFailure 108 -> 120
  0111    | GetConstantMutable 12: {_0_}
  0113    | GetLocalMove l3
  0115    | GetLocalMove l5
  0117    | InsertKeyVal 0
  0119    | Merge
  0120    | CallTailFunction 3
  0122    | Jump 122 -> 127
  0125    | GetLocalMove l2
  0127    | End
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
  0012    | PushUnderscoreVar
  0013    | PushUnderscoreVar
  0014    | PushUnderscoreVar
  0015    | PushUnderscoreVar
  0016    | SetInputMark
  0017    | GetLocalMove l0
  0019    | JumpIfFailure 19 -> 53
  0022    | MatchScrutinee r7
  0024    | MatchType r7 array -> 52
  0029    | MatchLenMin r7 1 -> 52
  0034    | MatchElem r8 r7[0]
  0038    | MatchBind l3 r8
  0041    | MatchSlice r9 r7[1..^0]
  0046    | MatchBind l4 r9
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | TakeRight 53 -> 92
  0056    | GetLocalMove l1
  0058    | JumpIfFailure 58 -> 92
  0061    | MatchScrutinee r7
  0063    | MatchType r7 array -> 91
  0068    | MatchLenMin r7 1 -> 91
  0073    | MatchElem r8 r7[0]
  0077    | MatchBind l5 r8
  0080    | MatchSlice r9 r7[1..^0]
  0085    | MatchBind l6 r9
  0088    | Jump 88 -> 92
  0091    | MatchFail
  0092    | ConditionalThen 92 -> 131
  0095    | GetConstant 13: _Array.ZipPairs
  0097    | GetLocalMove l4
  0099    | GetLocalMove l6
  0101    | PushEmptyArray
  0102    | JumpIfFailure 102 -> 108
  0105    | GetLocalMove l2
  0107    | Merge
  0108    | JumpIfFailure 108 -> 126
  0111    | GetConstantMutable 14: [_]
  0113    | GetConstantMutable 15: [_, _]
  0115    | GetLocalMove l3
  0117    | InsertAtIndex 0
  0119    | GetLocalMove l5
  0121    | InsertAtIndex 1
  0123    | InsertAtIndex 0
  0125    | Merge
  0126    | CallTailFunction 3
  0128    | Jump 128 -> 133
  0131    | GetLocalMove l2
  0133    | End
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
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetConstant 18: _Table.FirstPerRow
  0011    | GetLocal l0
  0013    | CallFunction 1
  0015    | JumpIfFailure 15 -> 23
  0018    | MatchScrutinee r4
  0020    | MatchBind l2 r4
  0023    | TakeRight 23 -> 40
  0026    | GetConstant 19: _Table.RestPerRow
  0028    | GetLocalMove l0
  0030    | CallFunction 1
  0032    | JumpIfFailure 32 -> 40
  0035    | MatchScrutinee r4
  0037    | MatchBind l3 r4
  0040    | ConditionalThen 40 -> 69
  0043    | GetConstant 17: _Table.Transpose
  0045    | GetLocalMove l3
  0047    | PushEmptyArray
  0048    | JumpIfFailure 48 -> 54
  0051    | GetLocalMove l1
  0053    | Merge
  0054    | JumpIfFailure 54 -> 64
  0057    | GetConstantMutable 20: [_]
  0059    | GetLocalMove l2
  0061    | InsertAtIndex 0
  0063    | Merge
  0064    | CallTailFunction 2
  0066    | Jump 66 -> 71
  0069    | GetLocalMove l1
  0071    | End
  ========================================
  
  ==========1:_Table.FirstPerRow==========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar Rest
  0005    | PushVar2 VeryFirst
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | PushUnderscoreVar
  0012    | PushUnderscoreVar
  0013    | GetLocalMove l0
  0015    | JumpIfFailure 15 -> 49
  0018    | MatchScrutinee r5
  0020    | MatchType r5 array -> 48
  0025    | MatchLenMin r5 1 -> 48
  0030    | MatchElem r6 r5[0]
  0034    | MatchBind l1 r6
  0037    | MatchSlice r7 r5[1..^0]
  0042    | MatchBind l2 r7
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | TakeRight 49 -> 80
  0052    | GetLocalMove l1
  0054    | JumpIfFailure 54 -> 80
  0057    | MatchScrutinee r5
  0059    | MatchType r5 array -> 79
  0064    | MatchLenMin r5 1 -> 79
  0069    | MatchElem r6 r5[0]
  0073    | MatchBind l3 r6
  0076    | Jump 76 -> 80
  0079    | MatchFail
  0080    | TakeRight 80 -> 95
  0083    | GetConstant 21: __Table.FirstPerRow
  0085    | GetLocalMove l2
  0087    | GetConstantMutable 22: [_]
  0089    | GetLocalMove l3
  0091    | InsertAtIndex 0
  0093    | CallTailFunction 2
  0095    | End
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
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | PushUnderscoreVar
  0012    | SetInputMark
  0013    | GetLocalMove l0
  0015    | JumpIfFailure 15 -> 49
  0018    | MatchScrutinee r6
  0020    | MatchType r6 array -> 48
  0025    | MatchLenMin r6 1 -> 48
  0030    | MatchElem r7 r6[0]
  0034    | MatchBind l2 r7
  0037    | MatchSlice r8 r6[1..^0]
  0042    | MatchBind l3 r8
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | TakeRight 49 -> 80
  0052    | GetLocalMove l2
  0054    | JumpIfFailure 54 -> 80
  0057    | MatchScrutinee r6
  0059    | MatchType r6 array -> 79
  0064    | MatchLenMin r6 1 -> 79
  0069    | MatchElem r7 r6[0]
  0073    | MatchBind l4 r7
  0076    | Jump 76 -> 80
  0079    | MatchFail
  0080    | ConditionalThen 80 -> 109
  0083    | GetConstant 21: __Table.FirstPerRow
  0085    | GetLocalMove l3
  0087    | PushEmptyArray
  0088    | JumpIfFailure 88 -> 94
  0091    | GetLocalMove l1
  0093    | Merge
  0094    | JumpIfFailure 94 -> 104
  0097    | GetConstantMutable 23: [_]
  0099    | GetLocalMove l4
  0101    | InsertAtIndex 0
  0103    | Merge
  0104    | CallTailFunction 2
  0106    | Jump 106 -> 111
  0109    | GetLocalMove l1
  0111    | End
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
  0005    | PushUnderscoreVar
  0006    | PushVar2 RowRest
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | PushUnderscoreVar
  0012    | PushUnderscoreVar
  0013    | SetInputMark
  0014    | GetLocalMove l0
  0016    | JumpIfFailure 16 -> 50
  0019    | MatchScrutinee r6
  0021    | MatchType r6 array -> 49
  0026    | MatchLenMin r6 1 -> 49
  0031    | MatchElem r7 r6[0]
  0035    | MatchBind l2 r7
  0038    | MatchSlice r8 r6[1..^0]
  0043    | MatchBind l3 r8
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | ConditionalThen 50 -> 134
  0053    | SetInputMark
  0054    | GetLocalMove l2
  0056    | JumpIfFailure 56 -> 83
  0059    | MatchScrutinee r6
  0061    | MatchType r6 array -> 82
  0066    | MatchLenMin r6 1 -> 82
  0071    | MatchSlice r7 r6[1..^0]
  0076    | MatchBind l5 r7
  0079    | Jump 79 -> 83
  0082    | MatchFail
  0083    | ConditionalThen 83 -> 112
  0086    | GetConstant 24: __Table.RestPerRow
  0088    | GetLocalMove l3
  0090    | PushEmptyArray
  0091    | JumpIfFailure 91 -> 97
  0094    | GetLocalMove l1
  0096    | Merge
  0097    | JumpIfFailure 97 -> 107
  0100    | GetConstantMutable 25: [_]
  0102    | GetLocalMove l5
  0104    | InsertAtIndex 0
  0106    | Merge
  0107    | CallTailFunction 2
  0109    | Jump 109 -> 131
  0112    | GetConstant 24: __Table.RestPerRow
  0114    | GetLocalMove l3
  0116    | PushEmptyArray
  0117    | JumpIfFailure 117 -> 123
  0120    | GetLocalMove l1
  0122    | Merge
  0123    | JumpIfFailure 123 -> 129
  0126    | GetConstant 26: [[]]
  0128    | Merge
  0129    | CallTailFunction 2
  0131    | Jump 131 -> 136
  0134    | GetLocalMove l1
  0136    | End
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
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | SetInputMark
  0010    | GetLocalMove l1
  0012    | JumpIfFailure 12 -> 46
  0015    | MatchScrutinee r5
  0017    | MatchType r5 array -> 45
  0022    | MatchLenMin r5 1 -> 45
  0027    | MatchElem r6 r5[0]
  0031    | MatchBind l3 r6
  0034    | MatchSlice r7 r5[1..^0]
  0039    | MatchBind l4 r7
  0042    | Jump 42 -> 46
  0045    | MatchFail
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
