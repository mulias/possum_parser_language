  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  
  =============1:Array.First==============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushVar F
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 34
  0008    | MatchWindowEnter 3
  0010    | MatchScrutinee r0
  0012    | MatchType r0 array -> 32
  0017    | MatchLenMin r0 1 -> 32
  0022    | MatchElem r1 r0[0]
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
  0000    | PushUnderscoreVar
  0001    | PushVar R
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 35
  0008    | MatchWindowEnter 3
  0010    | MatchScrutinee r0
  0012    | MatchType r0 array -> 33
  0017    | MatchLenMin r0 1 -> 33
  0022    | MatchSlice r1 r0[1..^0]
  0027    | MatchBind l2 r1
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
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
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l2 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l3 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 68
  0047    | GetConstant 0: _Array.Reverse
  0049    | GetLocalMove l3
  0051    | GetConstantMutable 1: [_]
  0053    | GetLocalMove l2
  0055    | InsertAtIndex 0
  0057    | JumpIfFailure 57 -> 63
  0060    | GetLocalMove l1
  0062    | Merge
  0063    | CallTailFunction 2
  0065    | Jump 65 -> 70
  0068    | GetLocalMove l1
  0070    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 79
  0047    | GetConstant 2: _Array.Map
  0049    | GetLocalMove l4
  0051    | GetLocal l1
  0053    | PushEmptyArray
  0054    | JumpIfFailure 54 -> 60
  0057    | GetLocalMove l2
  0059    | Merge
  0060    | JumpIfFailure 60 -> 74
  0063    | GetConstantMutable 3: [_]
  0065    | GetLocalMove l1
  0067    | GetLocalMove l3
  0069    | CallFunction 1
  0071    | InsertAtIndex 0
  0073    | Merge
  0074    | CallTailFunction 3
  0076    | Jump 76 -> 81
  0079    | GetLocalMove l2
  0081    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 90
  0047    | GetConstant 4: _Array.Filter
  0049    | GetLocalMove l4
  0051    | GetLocal l1
  0053    | SetInputMark
  0054    | GetLocalMove l1
  0056    | GetLocal l3
  0058    | CallFunction 1
  0060    | ConditionalThen 60 -> 83
  0063    | PushEmptyArray
  0064    | JumpIfFailure 64 -> 70
  0067    | GetLocalMove l2
  0069    | Merge
  0070    | JumpIfFailure 70 -> 80
  0073    | GetConstantMutable 5: [_]
  0075    | GetLocalMove l3
  0077    | InsertAtIndex 0
  0079    | Merge
  0080    | Jump 80 -> 85
  0083    | GetLocalMove l2
  0085    | CallTailFunction 3
  0087    | Jump 87 -> 92
  0090    | GetLocalMove l2
  0092    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 90
  0047    | GetConstant 6: _Array.Reject
  0049    | GetLocalMove l4
  0051    | GetLocal l1
  0053    | SetInputMark
  0054    | GetLocalMove l1
  0056    | GetLocal l3
  0058    | CallFunction 1
  0060    | ConditionalThen 60 -> 68
  0063    | GetLocalMove l2
  0065    | Jump 65 -> 85
  0068    | PushEmptyArray
  0069    | JumpIfFailure 69 -> 75
  0072    | GetLocalMove l2
  0074    | Merge
  0075    | JumpIfFailure 75 -> 85
  0078    | GetConstantMutable 7: [_]
  0080    | GetLocalMove l3
  0082    | InsertAtIndex 0
  0084    | Merge
  0085    | CallTailFunction 3
  0087    | Jump 87 -> 92
  0090    | GetLocalMove l2
  0092    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l2 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l3 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 64
  0047    | GetConstant 8: _Array.Merge
  0049    | GetLocalMove l3
  0051    | GetLocalMove l1
  0053    | JumpIfFailure 53 -> 59
  0056    | GetLocalMove l2
  0058    | Merge
  0059    | CallTailFunction 2
  0061    | Jump 61 -> 66
  0064    | GetLocalMove l1
  0066    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 70
  0047    | GetConstant 9: _Array.MapMerge
  0049    | GetLocalMove l4
  0051    | GetLocal l1
  0053    | GetLocalMove l2
  0055    | JumpIfFailure 55 -> 65
  0058    | GetLocalMove l1
  0060    | GetLocalMove l3
  0062    | CallFunction 1
  0064    | Merge
  0065    | CallTailFunction 3
  0067    | Jump 67 -> 72
  0070    | GetLocalMove l2
  0072    | End
  ========================================
  
  =============1:Array.Reduce=============
  Array.Reduce(A, Fn, Acc) =
    A -> [First, ...Rest] ? Array.Reduce(Rest, Fn, Fn(Acc, First)) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 66
  0047    | GetConstant 10: Array.Reduce
  0049    | GetLocalMove l4
  0051    | GetLocal l1
  0053    | GetLocalMove l1
  0055    | GetLocalMove l2
  0057    | GetLocalMove l3
  0059    | CallFunction 2
  0061    | CallTailFunction 3
  0063    | Jump 63 -> 68
  0066    | GetLocalMove l2
  0068    | End
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
  0015    | JumpIfFailure 15 -> 52
  0018    | MatchWindowEnter 4
  0020    | MatchScrutinee r0
  0022    | MatchType r0 array -> 50
  0027    | MatchLenMin r0 1 -> 50
  0032    | MatchElem r1 r0[0]
  0036    | MatchBind l3 r1
  0039    | MatchSlice r2 r0[1..^0]
  0044    | MatchBind l4 r2
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | TakeRight 52 -> 94
  0055    | GetLocalMove l1
  0057    | JumpIfFailure 57 -> 94
  0060    | MatchWindowEnter 4
  0062    | MatchScrutinee r0
  0064    | MatchType r0 array -> 92
  0069    | MatchLenMin r0 1 -> 92
  0074    | MatchElem r1 r0[0]
  0078    | MatchBind l5 r1
  0081    | MatchSlice r2 r0[1..^0]
  0086    | MatchBind l6 r2
  0089    | Jump 89 -> 93
  0092    | MatchFail
  0093    | MatchWindowExit
  0094    | ConditionalThen 94 -> 127
  0097    | GetConstant 11: _Array.ZipObject
  0099    | GetLocalMove l4
  0101    | GetLocalMove l6
  0103    | PushEmptyObject
  0104    | JumpIfFailure 104 -> 110
  0107    | GetLocalMove l2
  0109    | Merge
  0110    | JumpIfFailure 110 -> 122
  0113    | GetConstantMutable 12: {_0_}
  0115    | GetLocalMove l3
  0117    | GetLocalMove l5
  0119    | InsertKeyVal 0
  0121    | Merge
  0122    | CallTailFunction 3
  0124    | Jump 124 -> 129
  0127    | GetLocalMove l2
  0129    | End
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
  0015    | JumpIfFailure 15 -> 52
  0018    | MatchWindowEnter 4
  0020    | MatchScrutinee r0
  0022    | MatchType r0 array -> 50
  0027    | MatchLenMin r0 1 -> 50
  0032    | MatchElem r1 r0[0]
  0036    | MatchBind l3 r1
  0039    | MatchSlice r2 r0[1..^0]
  0044    | MatchBind l4 r2
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | TakeRight 52 -> 94
  0055    | GetLocalMove l1
  0057    | JumpIfFailure 57 -> 94
  0060    | MatchWindowEnter 4
  0062    | MatchScrutinee r0
  0064    | MatchType r0 array -> 92
  0069    | MatchLenMin r0 1 -> 92
  0074    | MatchElem r1 r0[0]
  0078    | MatchBind l5 r1
  0081    | MatchSlice r2 r0[1..^0]
  0086    | MatchBind l6 r2
  0089    | Jump 89 -> 93
  0092    | MatchFail
  0093    | MatchWindowExit
  0094    | ConditionalThen 94 -> 133
  0097    | GetConstant 13: _Array.ZipPairs
  0099    | GetLocalMove l4
  0101    | GetLocalMove l6
  0103    | PushEmptyArray
  0104    | JumpIfFailure 104 -> 110
  0107    | GetLocalMove l2
  0109    | Merge
  0110    | JumpIfFailure 110 -> 128
  0113    | GetConstantMutable 14: [_]
  0115    | GetConstantMutable 15: [_, _]
  0117    | GetLocalMove l3
  0119    | InsertAtIndex 0
  0121    | GetLocalMove l5
  0123    | InsertAtIndex 1
  0125    | InsertAtIndex 0
  0127    | Merge
  0128    | CallTailFunction 3
  0130    | Jump 130 -> 135
  0133    | GetLocalMove l2
  0135    | End
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
  0008    | PushUnderscoreVar
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 48
  0014    | MatchWindowEnter 4
  0016    | MatchScrutinee r0
  0018    | MatchType r0 array -> 46
  0023    | MatchLenMin r0 1 -> 46
  0028    | MatchElem r1 r0[0]
  0032    | MatchBind l1 r1
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l2 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | TakeRight 48 -> 82
  0051    | GetLocalMove l1
  0053    | JumpIfFailure 53 -> 82
  0056    | MatchWindowEnter 3
  0058    | MatchScrutinee r0
  0060    | MatchType r0 array -> 80
  0065    | MatchLenMin r0 1 -> 80
  0070    | MatchElem r1 r0[0]
  0074    | MatchBind l3 r1
  0077    | Jump 77 -> 81
  0080    | MatchFail
  0081    | MatchWindowExit
  0082    | TakeRight 82 -> 97
  0085    | GetConstant 21: __Table.FirstPerRow
  0087    | GetLocalMove l2
  0089    | GetConstantMutable 22: [_]
  0091    | GetLocalMove l3
  0093    | InsertAtIndex 0
  0095    | CallTailFunction 2
  0097    | End
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
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 48
  0014    | MatchWindowEnter 4
  0016    | MatchScrutinee r0
  0018    | MatchType r0 array -> 46
  0023    | MatchLenMin r0 1 -> 46
  0028    | MatchElem r1 r0[0]
  0032    | MatchBind l2 r1
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l3 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | TakeRight 48 -> 82
  0051    | GetLocalMove l2
  0053    | JumpIfFailure 53 -> 82
  0056    | MatchWindowEnter 3
  0058    | MatchScrutinee r0
  0060    | MatchType r0 array -> 80
  0065    | MatchLenMin r0 1 -> 80
  0070    | MatchElem r1 r0[0]
  0074    | MatchBind l4 r1
  0077    | Jump 77 -> 81
  0080    | MatchFail
  0081    | MatchWindowExit
  0082    | ConditionalThen 82 -> 111
  0085    | GetConstant 21: __Table.FirstPerRow
  0087    | GetLocalMove l3
  0089    | PushEmptyArray
  0090    | JumpIfFailure 90 -> 96
  0093    | GetLocalMove l1
  0095    | Merge
  0096    | JumpIfFailure 96 -> 106
  0099    | GetConstantMutable 23: [_]
  0101    | GetLocalMove l4
  0103    | InsertAtIndex 0
  0105    | Merge
  0106    | CallTailFunction 2
  0108    | Jump 108 -> 113
  0111    | GetLocalMove l1
  0113    | End
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
  0009    | SetInputMark
  0010    | GetLocalMove l0
  0012    | JumpIfFailure 12 -> 49
  0015    | MatchWindowEnter 4
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array -> 47
  0024    | MatchLenMin r0 1 -> 47
  0029    | MatchElem r1 r0[0]
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
  0077    | MatchBind l5 r1
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
  0104    | GetLocalMove l5
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
  0008    | JumpIfFailure 8 -> 45
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 43
  0020    | MatchLenMin r0 1 -> 43
  0025    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 82
  0048    | GetConstant 30: _Table.ZipObjects
  0050    | GetLocal l0
  0052    | GetLocalMove l4
  0054    | PushEmptyArray
  0055    | JumpIfFailure 55 -> 61
  0058    | GetLocalMove l2
  0060    | Merge
  0061    | JumpIfFailure 61 -> 77
  0064    | GetConstantMutable 31: [_]
  0066    | GetConstant 32: Array.ZipObject
  0068    | GetLocalMove l0
  0070    | GetLocalMove l3
  0072    | CallFunction 2
  0074    | InsertAtIndex 0
  0076    | Merge
  0077    | CallTailFunction 3
  0079    | Jump 79 -> 84
  0082    | GetLocalMove l2
  0084    | End
  ========================================
