  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  
  =============1:Array.First==============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushVar F
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 33
  0007    | MatchWindowEnter 3 fail->31
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchCount r0 >=1
  0020    | MatchElem r1 r0[0]
  0025    | MatchBind l1 r1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 38
  0036    | GetLocalMove l1
  0038    | End
  ========================================
  
  ==============1:Array.Rest==============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushVar R
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 33
  0007    | MatchWindowEnter 3 fail->31
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchCount r0 >=1
  0020    | MatchSlice r1 r0[1..^0]
  0025    | MatchBind l1 r1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 38
  0036    | GetLocalMove l1
  0038    | End
  ========================================
  
  =============1:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushVar L
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 29
  0007    | MatchWindowEnter 5 fail->27
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchRepeatInit r0 /1 n=r2 base=r3
  0021    | MatchBind l1 r2
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l1
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
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
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
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
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
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
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
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
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
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
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
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
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
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
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
  0018    | MatchWindowEnter 4 fail->50
  0022    | MatchScrutinee r0
  0024    | MatchType r0 array
  0027    | MatchCount r0 >=1
  0031    | MatchElem r1 r0[0]
  0036    | MatchBind l3 r1
  0039    | MatchSlice r2 r0[1..^0]
  0044    | MatchBind l4 r2
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | TakeRight 52 -> 94
  0055    | GetLocalMove l1
  0057    | JumpIfFailure 57 -> 94
  0060    | MatchWindowEnter 4 fail->92
  0064    | MatchScrutinee r0
  0066    | MatchType r0 array
  0069    | MatchCount r0 >=1
  0073    | MatchElem r1 r0[0]
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
  0018    | MatchWindowEnter 4 fail->50
  0022    | MatchScrutinee r0
  0024    | MatchType r0 array
  0027    | MatchCount r0 >=1
  0031    | MatchElem r1 r0[0]
  0036    | MatchBind l3 r1
  0039    | MatchSlice r2 r0[1..^0]
  0044    | MatchBind l4 r2
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | TakeRight 52 -> 94
  0055    | GetLocalMove l1
  0057    | JumpIfFailure 57 -> 94
  0060    | MatchWindowEnter 4 fail->92
  0064    | MatchScrutinee r0
  0066    | MatchType r0 array
  0069    | MatchCount r0 >=1
  0073    | MatchElem r1 r0[0]
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
  0013    | JumpIfFailure 13 -> 26
  0016    | MatchWindowEnter 2 fail->25
  0020    | MatchScrutinee r0
  0022    | MatchBind l2 r0
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 48
  0029    | GetConstant 19: _Table.RestPerRow
  0031    | GetLocalMove l0
  0033    | CallFunction 1
  0035    | JumpIfFailure 35 -> 48
  0038    | MatchWindowEnter 2 fail->47
  0042    | MatchScrutinee r0
  0044    | MatchBind l3 r0
  0047    | MatchWindowExit
  0048    | ConditionalThen 48 -> 77
  0051    | GetConstant 17: _Table.Transpose
  0053    | GetLocalMove l3
  0055    | PushEmptyArray
  0056    | JumpIfFailure 56 -> 62
  0059    | GetLocalMove l1
  0061    | Merge
  0062    | JumpIfFailure 62 -> 72
  0065    | GetConstantMutable 20: [_]
  0067    | GetLocalMove l2
  0069    | InsertAtIndex 0
  0071    | Merge
  0072    | CallTailFunction 2
  0074    | Jump 74 -> 79
  0077    | GetLocalMove l1
  0079    | End
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
  0010    | JumpIfFailure 10 -> 47
  0013    | MatchWindowEnter 4 fail->45
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array
  0022    | MatchCount r0 >=1
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l1 r1
  0034    | MatchSlice r2 r0[1..^0]
  0039    | MatchBind l2 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | TakeRight 47 -> 81
  0050    | GetLocalMove l1
  0052    | JumpIfFailure 52 -> 81
  0055    | MatchWindowEnter 3 fail->79
  0059    | MatchScrutinee r0
  0061    | MatchType r0 array
  0064    | MatchCount r0 >=1
  0068    | MatchElem r1 r0[0]
  0073    | MatchBind l3 r1
  0076    | Jump 76 -> 80
  0079    | MatchFail
  0080    | MatchWindowExit
  0081    | TakeRight 81 -> 96
  0084    | GetConstant 21: __Table.FirstPerRow
  0086    | GetLocalMove l2
  0088    | GetConstantMutable 22: [_]
  0090    | GetLocalMove l3
  0092    | InsertAtIndex 0
  0094    | CallTailFunction 2
  0096    | End
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
  0010    | JumpIfFailure 10 -> 47
  0013    | MatchWindowEnter 4 fail->45
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array
  0022    | MatchCount r0 >=1
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l2 r1
  0034    | MatchSlice r2 r0[1..^0]
  0039    | MatchBind l3 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | TakeRight 47 -> 81
  0050    | GetLocalMove l2
  0052    | JumpIfFailure 52 -> 81
  0055    | MatchWindowEnter 3 fail->79
  0059    | MatchScrutinee r0
  0061    | MatchType r0 array
  0064    | MatchCount r0 >=1
  0068    | MatchElem r1 r0[0]
  0073    | MatchBind l4 r1
  0076    | Jump 76 -> 80
  0079    | MatchFail
  0080    | MatchWindowExit
  0081    | ConditionalThen 81 -> 110
  0084    | GetConstant 21: __Table.FirstPerRow
  0086    | GetLocalMove l3
  0088    | PushEmptyArray
  0089    | JumpIfFailure 89 -> 95
  0092    | GetLocalMove l1
  0094    | Merge
  0095    | JumpIfFailure 95 -> 105
  0098    | GetConstantMutable 23: [_]
  0100    | GetLocalMove l4
  0102    | InsertAtIndex 0
  0104    | Merge
  0105    | CallTailFunction 2
  0107    | Jump 107 -> 112
  0110    | GetLocalMove l1
  0112    | End
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
  0011    | JumpIfFailure 11 -> 48
  0014    | MatchWindowEnter 4 fail->46
  0018    | MatchScrutinee r0
  0020    | MatchType r0 array
  0023    | MatchCount r0 >=1
  0027    | MatchElem r1 r0[0]
  0032    | MatchBind l2 r1
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l3 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | ConditionalThen 48 -> 134
  0051    | SetInputMark
  0052    | GetLocalMove l2
  0054    | JumpIfFailure 54 -> 83
  0057    | MatchWindowEnter 3 fail->81
  0061    | MatchScrutinee r0
  0063    | MatchType r0 array
  0066    | MatchCount r0 >=1
  0070    | MatchSlice r1 r0[1..^0]
  0075    | MatchBind l4 r1
  0078    | Jump 78 -> 82
  0081    | MatchFail
  0082    | MatchWindowExit
  0083    | ConditionalThen 83 -> 112
  0086    | GetConstant 24: __Table.RestPerRow
  0088    | GetLocalMove l3
  0090    | PushEmptyArray
  0091    | JumpIfFailure 91 -> 97
  0094    | GetLocalMove l1
  0096    | Merge
  0097    | JumpIfFailure 97 -> 107
  0100    | GetConstantMutable 25: [_]
  0102    | GetLocalMove l4
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
  0005    | SetInputMark
  0006    | GetLocalMove l1
  0008    | JumpIfFailure 8 -> 45
  0011    | MatchWindowEnter 4 fail->43
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 >=1
  0024    | MatchElem r1 r0[0]
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
