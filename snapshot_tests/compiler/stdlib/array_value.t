  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  
  =============1:Array.First==============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushVar F
  0002    | PushUnderscoreVar
  0003    | GetLocalMove 0
  0005    | DestructurePlan 0: ([bind F] + _)
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove 1
  0012    | End
  ========================================
  
  ==============1:Array.Rest==============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar R
  0003    | GetLocalMove 0
  0005    | DestructurePlan 1: ([_] + bind R)
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove 2
  0012    | End
  ========================================
  
  =============1:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar L
  0003    | GetLocalMove 0
  0005    | DestructurePlan 2: ([_] * bind L)
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove 2
  0012    | End
  ========================================
  
  ============1:Array.Reverse=============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant 0: _Array.Reverse
  0002    | GetLocalMove 0
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 3: ([bind First] + bind Rest)
  0009    | ConditionalThen 9 -> 33
  0012    | GetConstant 0: _Array.Reverse
  0014    | GetLocalMove 3
  0016    | GetConstantMutable 1: [_]
  0018    | GetLocalMove 2
  0020    | InsertAtIndex 0
  0022    | JumpIfFailure 22 -> 28
  0025    | GetLocalMove 1
  0027    | Merge
  0028    | CallTailFunction 2
  0030    | Jump 30 -> 35
  0033    | GetLocalMove 1
  0035    | End
  ========================================
  
  ==============1:Array.Map===============
  Array.Map(A, Fn) = _Array.Map(A, Fn, [])
  ========================================
  0000    | GetConstant 2: _Array.Map
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 4: ([bind First] + bind Rest)
  0009    | ConditionalThen 9 -> 44
  0012    | GetConstant 2: _Array.Map
  0014    | GetLocalMove 4
  0016    | GetLocal 1
  0018    | PushEmptyArray
  0019    | JumpIfFailure 19 -> 25
  0022    | GetLocalMove 2
  0024    | Merge
  0025    | JumpIfFailure 25 -> 39
  0028    | GetConstantMutable 3: [_]
  0030    | GetLocalMove 1
  0032    | GetLocalMove 3
  0034    | CallFunction 1
  0036    | InsertAtIndex 0
  0038    | Merge
  0039    | CallTailFunction 3
  0041    | Jump 41 -> 46
  0044    | GetLocalMove 2
  0046    | End
  ========================================
  
  =============1:Array.Filter=============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant 4: _Array.Filter
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 5: ([bind First] + bind Rest)
  0009    | ConditionalThen 9 -> 55
  0012    | GetConstant 4: _Array.Filter
  0014    | GetLocalMove 4
  0016    | GetLocal 1
  0018    | SetInputMark
  0019    | GetLocalMove 1
  0021    | GetLocal 3
  0023    | CallFunction 1
  0025    | ConditionalThen 25 -> 48
  0028    | PushEmptyArray
  0029    | JumpIfFailure 29 -> 35
  0032    | GetLocalMove 2
  0034    | Merge
  0035    | JumpIfFailure 35 -> 45
  0038    | GetConstantMutable 5: [_]
  0040    | GetLocalMove 3
  0042    | InsertAtIndex 0
  0044    | Merge
  0045    | Jump 45 -> 50
  0048    | GetLocalMove 2
  0050    | CallTailFunction 3
  0052    | Jump 52 -> 57
  0055    | GetLocalMove 2
  0057    | End
  ========================================
  
  =============1:Array.Reject=============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant 6: _Array.Reject
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 6: ([bind First] + bind Rest)
  0009    | ConditionalThen 9 -> 55
  0012    | GetConstant 6: _Array.Reject
  0014    | GetLocalMove 4
  0016    | GetLocal 1
  0018    | SetInputMark
  0019    | GetLocalMove 1
  0021    | GetLocal 3
  0023    | CallFunction 1
  0025    | ConditionalThen 25 -> 33
  0028    | GetLocalMove 2
  0030    | Jump 30 -> 50
  0033    | PushEmptyArray
  0034    | JumpIfFailure 34 -> 40
  0037    | GetLocalMove 2
  0039    | Merge
  0040    | JumpIfFailure 40 -> 50
  0043    | GetConstantMutable 7: [_]
  0045    | GetLocalMove 3
  0047    | InsertAtIndex 0
  0049    | Merge
  0050    | CallTailFunction 3
  0052    | Jump 52 -> 57
  0055    | GetLocalMove 2
  0057    | End
  ========================================
  
  =============1:Array.Merge==============
  Array.Merge(A) = _Array.Merge(A, null)
  ========================================
  0000    | GetConstant 8: _Array.Merge
  0002    | GetLocalMove 0
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 7: ([bind First] + bind Rest)
  0009    | ConditionalThen 9 -> 29
  0012    | GetConstant 8: _Array.Merge
  0014    | GetLocalMove 3
  0016    | GetLocalMove 1
  0018    | JumpIfFailure 18 -> 24
  0021    | GetLocalMove 2
  0023    | Merge
  0024    | CallTailFunction 2
  0026    | Jump 26 -> 31
  0029    | GetLocalMove 1
  0031    | End
  ========================================
  
  ============1:Array.MapMerge============
  Array.MapMerge(A, Fn) = _Array.MapMerge(A, Fn, null)
  ========================================
  0000    | GetConstant 9: _Array.MapMerge
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 8: ([bind First] + bind Rest)
  0009    | ConditionalThen 9 -> 35
  0012    | GetConstant 9: _Array.MapMerge
  0014    | GetLocalMove 4
  0016    | GetLocal 1
  0018    | GetLocalMove 2
  0020    | JumpIfFailure 20 -> 30
  0023    | GetLocalMove 1
  0025    | GetLocalMove 3
  0027    | CallFunction 1
  0029    | Merge
  0030    | CallTailFunction 3
  0032    | Jump 32 -> 37
  0035    | GetLocalMove 2
  0037    | End
  ========================================
  
  =============1:Array.Reduce=============
  Array.Reduce(A, Fn, Acc) =
    A -> [First, ...Rest] ? Array.Reduce(Rest, Fn, Fn(Acc, First)) : Acc
  ========================================
  0000    | PushVar First
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove 0
  0007    | DestructurePlan 9: ([bind First] + bind Rest)
  0009    | ConditionalThen 9 -> 31
  0012    | GetConstant 10: Array.Reduce
  0014    | GetLocalMove 4
  0016    | GetLocal 1
  0018    | GetLocalMove 1
  0020    | GetLocalMove 2
  0022    | GetLocalMove 3
  0024    | CallFunction 2
  0026    | CallTailFunction 3
  0028    | Jump 28 -> 33
  0031    | GetLocalMove 2
  0033    | End
  ========================================
  
  ===========1:Array.ZipObject============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant 11: _Array.ZipObject
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
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
  0013    | GetLocalMove 0
  0015    | DestructurePlan 10: ([bind K] + bind KsRest)
  0017    | TakeRight 17 -> 24
  0020    | GetLocalMove 1
  0022    | DestructurePlan 11: ([bind V] + bind VsRest)
  0024    | ConditionalThen 24 -> 57
  0027    | GetConstant 11: _Array.ZipObject
  0029    | GetLocalMove 4
  0031    | GetLocalMove 6
  0033    | PushEmptyObject
  0034    | JumpIfFailure 34 -> 40
  0037    | GetLocalMove 2
  0039    | Merge
  0040    | JumpIfFailure 40 -> 52
  0043    | GetConstantMutable 12: {_0_}
  0045    | GetLocalMove 3
  0047    | GetLocalMove 5
  0049    | InsertKeyVal 0
  0051    | Merge
  0052    | CallTailFunction 3
  0054    | Jump 54 -> 59
  0057    | GetLocalMove 2
  0059    | End
  ========================================
  
  ============1:Array.ZipPairs============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant 13: _Array.ZipPairs
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
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
  0013    | GetLocalMove 0
  0015    | DestructurePlan 12: ([bind First1] + bind Rest1)
  0017    | TakeRight 17 -> 24
  0020    | GetLocalMove 1
  0022    | DestructurePlan 13: ([bind First2] + bind Rest2)
  0024    | ConditionalThen 24 -> 63
  0027    | GetConstant 13: _Array.ZipPairs
  0029    | GetLocalMove 4
  0031    | GetLocalMove 6
  0033    | PushEmptyArray
  0034    | JumpIfFailure 34 -> 40
  0037    | GetLocalMove 2
  0039    | Merge
  0040    | JumpIfFailure 40 -> 58
  0043    | GetConstantMutable 14: [_]
  0045    | GetConstantMutable 15: [_, _]
  0047    | GetLocalMove 3
  0049    | InsertAtIndex 0
  0051    | GetLocalMove 5
  0053    | InsertAtIndex 1
  0055    | InsertAtIndex 0
  0057    | Merge
  0058    | CallTailFunction 3
  0060    | Jump 60 -> 65
  0063    | GetLocalMove 2
  0065    | End
  ========================================
  
  ============1:Array.AppendN=============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetLocalMove 0
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstantMutable 16: [_]
  0007    | GetLocalMove 1
  0009    | InsertAtIndex 0
  0011    | GetLocalMove 2
  0013    | RepeatValue
  0014    | Merge
  0015    | End
  ========================================
  
  ===========1:Table.Transpose============
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant 17: _Table.Transpose
  0002    | GetLocalMove 0
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
  0009    | GetLocal 0
  0011    | CallFunction 1
  0013    | DestructurePlan 14: bind FirstPerRow
  0015    | TakeRight 15 -> 26
  0018    | GetConstant 19: _Table.RestPerRow
  0020    | GetLocalMove 0
  0022    | CallFunction 1
  0024    | DestructurePlan 15: bind RestPerRow
  0026    | ConditionalThen 26 -> 55
  0029    | GetConstant 17: _Table.Transpose
  0031    | GetLocalMove 3
  0033    | PushEmptyArray
  0034    | JumpIfFailure 34 -> 40
  0037    | GetLocalMove 1
  0039    | Merge
  0040    | JumpIfFailure 40 -> 50
  0043    | GetConstantMutable 20: [_]
  0045    | GetLocalMove 2
  0047    | InsertAtIndex 0
  0049    | Merge
  0050    | CallTailFunction 2
  0052    | Jump 52 -> 57
  0055    | GetLocalMove 1
  0057    | End
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
  0009    | GetLocalMove 0
  0011    | DestructurePlan 16: ([bind Row] + bind Rest)
  0013    | TakeRight 13 -> 20
  0016    | GetLocalMove 1
  0018    | DestructurePlan 17: ([bind VeryFirst] + _)
  0020    | TakeRight 20 -> 35
  0023    | GetConstant 21: __Table.FirstPerRow
  0025    | GetLocalMove 2
  0027    | GetConstantMutable 22: [_]
  0029    | GetLocalMove 3
  0031    | InsertAtIndex 0
  0033    | CallTailFunction 2
  0035    | End
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
  0009    | GetLocalMove 0
  0011    | DestructurePlan 18: ([bind Row] + bind Rest)
  0013    | TakeRight 13 -> 20
  0016    | GetLocalMove 2
  0018    | DestructurePlan 19: ([bind First] + _)
  0020    | ConditionalThen 20 -> 49
  0023    | GetConstant 21: __Table.FirstPerRow
  0025    | GetLocalMove 3
  0027    | PushEmptyArray
  0028    | JumpIfFailure 28 -> 34
  0031    | GetLocalMove 1
  0033    | Merge
  0034    | JumpIfFailure 34 -> 44
  0037    | GetConstantMutable 23: [_]
  0039    | GetLocalMove 4
  0041    | InsertAtIndex 0
  0043    | Merge
  0044    | CallTailFunction 2
  0046    | Jump 46 -> 51
  0049    | GetLocalMove 1
  0051    | End
  ========================================
  
  ==========1:_Table.RestPerRow===========
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant 24: __Table.RestPerRow
  0002    | GetLocalMove 0
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
  0010    | GetLocalMove 0
  0012    | DestructurePlan 20: ([bind Row] + bind Rest)
  0014    | ConditionalThen 14 -> 73
  0017    | SetInputMark
  0018    | GetLocalMove 2
  0020    | DestructurePlan 21: ([_] + bind RowRest)
  0022    | ConditionalThen 22 -> 51
  0025    | GetConstant 24: __Table.RestPerRow
  0027    | GetLocalMove 3
  0029    | PushEmptyArray
  0030    | JumpIfFailure 30 -> 36
  0033    | GetLocalMove 1
  0035    | Merge
  0036    | JumpIfFailure 36 -> 46
  0039    | GetConstantMutable 25: [_]
  0041    | GetLocalMove 5
  0043    | InsertAtIndex 0
  0045    | Merge
  0046    | CallTailFunction 2
  0048    | Jump 48 -> 70
  0051    | GetConstant 24: __Table.RestPerRow
  0053    | GetLocalMove 3
  0055    | PushEmptyArray
  0056    | JumpIfFailure 56 -> 62
  0059    | GetLocalMove 1
  0061    | Merge
  0062    | JumpIfFailure 62 -> 68
  0065    | GetConstant 26: [[]]
  0067    | Merge
  0068    | CallTailFunction 2
  0070    | Jump 70 -> 75
  0073    | GetLocalMove 1
  0075    | End
  ========================================
  
  ========1:Table.RotateClockwise=========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant 27: Array.Map
  0002    | GetConstant 28: Table.Transpose
  0004    | GetLocalMove 0
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
  0004    | GetLocalMove 0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ===========1:Table.ZipObjects===========
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant 30: _Table.ZipObjects
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
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
  0006    | GetLocalMove 1
  0008    | DestructurePlan 22: ([bind Row] + bind Rest)
  0010    | ConditionalThen 10 -> 47
  0013    | GetConstant 30: _Table.ZipObjects
  0015    | GetLocal 0
  0017    | GetLocalMove 4
  0019    | PushEmptyArray
  0020    | JumpIfFailure 20 -> 26
  0023    | GetLocalMove 2
  0025    | Merge
  0026    | JumpIfFailure 26 -> 42
  0029    | GetConstantMutable 31: [_]
  0031    | GetConstant 32: Array.ZipObject
  0033    | GetLocalMove 0
  0035    | GetLocalMove 3
  0037    | CallFunction 2
  0039    | InsertAtIndex 0
  0041    | Merge
  0042    | CallTailFunction 3
  0044    | Jump 44 -> 49
  0047    | GetLocalMove 2
  0049    | End
  ========================================
