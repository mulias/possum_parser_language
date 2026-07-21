  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array.possum -i '' --no-stdlib
  
  ================0:@fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  =================0:@Add=================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 6: addNative
  0006    | End
  ========================================
  
  ============0:@input.offset=============
  0000    | NativeCode 2: inputOffsetNative
  0002    | End
  ========================================
  
  =================0:@at==================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | NativeCode 4: setInputPositionNative
  0005    | JumpIfFailure 5 -> 13
  0008    | GetLocal l1
  0010    | CallFunction 0
  0012    | ResetInput
  0013    | End
  ========================================
  
  ================1:array=================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  
  ==============1:array_sep===============
  array_sep(elem, sep) = tuple1(elem) + (tuple1(sep > elem) * 0..)
  ========================================
  0000    | GetConstant 0: tuple1
  0002    | GetLocal l0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 68
  0009    | PushNull
  0010    | PushInteger 0
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 41
  0016    | Swap
  0017    | GetConstant 0: tuple1
  0019    | GetConstant 2: @fn0
  0021    | CreateClosure 2
  0023    | CaptureLocal l1
  0025    | CaptureLocal l0
  0027    | CallFunction 1
  0029    | Merge
  0030    | JumpIfFailure 30 -> 65
  0033    | Swap
  0034    | Decrement
  0035    | JumpIfZero 35 -> 41
  0038    | JumpBack 38 -> 16
  0041    | Swap
  0042    | SetInputMark
  0043    | GetConstant 0: tuple1
  0045    | GetConstant 2: @fn0
  0047    | CreateClosure 2
  0049    | CaptureLocal l1
  0051    | CaptureLocal l0
  0053    | CallFunction 1
  0055    | JumpIfFailure 55 -> 63
  0058    | PopInputMark
  0059    | Merge
  0060    | JumpBack 60 -> 42
  0063    | ResetInput
  0064    | Drop
  0065    | Swap
  0066    | Drop
  0067    | Merge
  0068    | End
  ========================================
  
  =============1:array_until==============
  array_until(elem, stop) = unless(tuple1(elem), stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 32
  0007    | Swap
  0008    | GetConstant 3: unless
  0010    | GetConstant 4: @fn1
  0012    | CreateClosure 1
  0014    | CaptureLocal l0
  0016    | GetLocal l1
  0018    | CallFunction 2
  0020    | Merge
  0021    | JumpIfFailure 21 -> 56
  0024    | Swap
  0025    | Decrement
  0026    | JumpIfZero 26 -> 32
  0029    | JumpBack 29 -> 7
  0032    | Swap
  0033    | SetInputMark
  0034    | GetConstant 3: unless
  0036    | GetConstant 4: @fn1
  0038    | CreateClosure 1
  0040    | CaptureLocal l0
  0042    | GetLocal l1
  0044    | CallFunction 2
  0046    | JumpIfFailure 46 -> 54
  0049    | PopInputMark
  0050    | Merge
  0051    | JumpBack 51 -> 33
  0054    | ResetInput
  0055    | Drop
  0056    | Swap
  0057    | Drop
  0058    | JumpIfFailure 58 -> 68
  0061    | GetConstant 5: peek
  0063    | GetLocalMove l1
  0065    | CallFunction 1
  0067    | TakeLeft
  0068    | End
  ========================================
  
  =============1:maybe_array==============
  maybe_array(elem) = default(array(elem), [])
  ========================================
  0000    | GetConstant 6: default
  0002    | GetConstant 7: @fn2
  0004    | CreateClosure 1
  0006    | CaptureLocal l0
  0008    | PushEmptyArray
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===========1:maybe_array_sep============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 6: default
  0002    | GetConstant 9: @fn3
  0004    | CreateClosure 2
  0006    | CaptureLocal l0
  0008    | CaptureLocal l1
  0010    | PushEmptyArray
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ================1:tuple1================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar Elem
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================1:tuple2================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | CallFunctionLocal l0
  0008    | JumpIfFailure 8 -> 16
  0011    | MatchScrutinee r4
  0013    | MatchBind l2 r4
  0016    | TakeRight 16 -> 42
  0019    | CallFunctionLocal l1
  0021    | JumpIfFailure 21 -> 29
  0024    | MatchScrutinee r4
  0026    | MatchBind l3 r4
  0029    | TakeRight 29 -> 42
  0032    | GetConstantMutable 11: [_, _]
  0034    | GetLocalMove l2
  0036    | InsertAtIndex 0
  0038    | GetLocalMove l3
  0040    | InsertAtIndex 1
  0042    | End
  ========================================
  
  ==============1:tuple2_sep==============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | CallFunctionLocal l0
  0008    | JumpIfFailure 8 -> 16
  0011    | MatchScrutinee r5
  0013    | MatchBind l3 r5
  0016    | TakeRight 16 -> 21
  0019    | CallFunctionLocal l1
  0021    | TakeRight 21 -> 47
  0024    | CallFunctionLocal l2
  0026    | JumpIfFailure 26 -> 34
  0029    | MatchScrutinee r5
  0031    | MatchBind l4 r5
  0034    | TakeRight 34 -> 47
  0037    | GetConstantMutable 12: [_, _]
  0039    | GetLocalMove l3
  0041    | InsertAtIndex 0
  0043    | GetLocalMove l4
  0045    | InsertAtIndex 1
  0047    | End
  ========================================
  
  ================1:tuple3================
  tuple3(elem1, elem2, elem3) =
    elem1 -> E1 &
    elem2 -> E2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | PushVar E3
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionLocal l0
  0010    | JumpIfFailure 10 -> 18
  0013    | MatchScrutinee r6
  0015    | MatchBind l3 r6
  0018    | TakeRight 18 -> 31
  0021    | CallFunctionLocal l1
  0023    | JumpIfFailure 23 -> 31
  0026    | MatchScrutinee r6
  0028    | MatchBind l4 r6
  0031    | TakeRight 31 -> 61
  0034    | CallFunctionLocal l2
  0036    | JumpIfFailure 36 -> 44
  0039    | MatchScrutinee r6
  0041    | MatchBind l5 r6
  0044    | TakeRight 44 -> 61
  0047    | GetConstantMutable 13: [_, _, _]
  0049    | GetLocalMove l3
  0051    | InsertAtIndex 0
  0053    | GetLocalMove l4
  0055    | InsertAtIndex 1
  0057    | GetLocalMove l5
  0059    | InsertAtIndex 2
  0061    | End
  ========================================
  
  ==============1:tuple3_sep==============
  tuple3_sep(elem1, sep1, elem2, sep2, elem3) =
    elem1 -> E1 & sep1 &
    elem2 -> E2 & sep2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | PushVar E3
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionLocal l0
  0010    | JumpIfFailure 10 -> 18
  0013    | MatchScrutinee r8
  0015    | MatchBind l5 r8
  0018    | TakeRight 18 -> 23
  0021    | CallFunctionLocal l1
  0023    | TakeRight 23 -> 36
  0026    | CallFunctionLocal l2
  0028    | JumpIfFailure 28 -> 36
  0031    | MatchScrutinee r8
  0033    | MatchBind l6 r8
  0036    | TakeRight 36 -> 41
  0039    | CallFunctionLocal l3
  0041    | TakeRight 41 -> 71
  0044    | CallFunctionLocal l4
  0046    | JumpIfFailure 46 -> 54
  0049    | MatchScrutinee r8
  0051    | MatchBind l7 r8
  0054    | TakeRight 54 -> 71
  0057    | GetConstantMutable 14: [_, _, _]
  0059    | GetLocalMove l5
  0061    | InsertAtIndex 0
  0063    | GetLocalMove l6
  0065    | InsertAtIndex 1
  0067    | GetLocalMove l7
  0069    | InsertAtIndex 2
  0071    | End
  ========================================
  
  ================1:tuple=================
  tuple(elem, N) = tuple1(elem) * N
  ========================================
  0000    | PushNull
  0001    | GetLocalMove l1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 27
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetLocal l0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 26
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 27
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | Drop
  0028    | End
  ========================================
  
  ==============1:tuple_sep===============
  tuple_sep(elem, sep, N) = tuple1(elem) + (tuple1(sep > elem) * (N - 1))
  ========================================
  0000    | GetConstant 0: tuple1
  0002    | GetLocal l0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 66
  0009    | PushNull
  0010    | GetLocal l2
  0012    | JumpIfFailure 12 -> 18
  0015    | PushNegInteger -1
  0017    | Merge
  0018    | ValidateRepeatPattern
  0019    | JumpIfZero 19 -> 52
  0022    | Swap
  0023    | SetInputMark
  0024    | GetConstant 0: tuple1
  0026    | GetConstant 15: @fn4
  0028    | CreateClosure 2
  0030    | CaptureLocal l1
  0032    | CaptureLocal l0
  0034    | CallFunction 1
  0036    | JumpIfFailure 36 -> 49
  0039    | PopInputMark
  0040    | Merge
  0041    | Swap
  0042    | Decrement
  0043    | JumpIfZero 43 -> 52
  0046    | JumpBack 46 -> 22
  0049    | ResetInput
  0050    | Drop
  0051    | Swap
  0052    | NegateNumber
  0053    | GetLocal l2
  0055    | JumpIfFailure 55 -> 61
  0058    | PushNegInteger -1
  0060    | Merge
  0061    | Merge
  0062    | DestructurePlan 0: (bound_eq N + eq -1)
  0064    | Drop
  0065    | Merge
  0066    | End
  ========================================
  
  =================1:rows=================
  rows(elem, col_sep, row_sep) =
    tuple1(array_sep(elem, col_sep)) +
    (tuple1(row_sep > array_sep(elem, col_sep)) * 0..)
  ========================================
  0000    | GetConstant 0: tuple1
  0002    | GetConstant 16: @fn5
  0004    | CreateClosure 2
  0006    | CaptureLocal l0
  0008    | CaptureLocal l1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 78
  0015    | PushNull
  0016    | PushInteger 0
  0018    | ValidateRepeatPattern
  0019    | JumpIfZero 19 -> 49
  0022    | Swap
  0023    | GetConstant 0: tuple1
  0025    | GetConstant 17: @fn6
  0027    | CreateClosure 3
  0029    | CaptureLocal l2
  0031    | CaptureLocal l0
  0033    | CaptureLocal l1
  0035    | CallFunction 1
  0037    | Merge
  0038    | JumpIfFailure 38 -> 75
  0041    | Swap
  0042    | Decrement
  0043    | JumpIfZero 43 -> 49
  0046    | JumpBack 46 -> 22
  0049    | Swap
  0050    | SetInputMark
  0051    | GetConstant 0: tuple1
  0053    | GetConstant 17: @fn6
  0055    | CreateClosure 3
  0057    | CaptureLocal l2
  0059    | CaptureLocal l0
  0061    | CaptureLocal l1
  0063    | CallFunction 1
  0065    | JumpIfFailure 65 -> 73
  0068    | PopInputMark
  0069    | Merge
  0070    | JumpBack 70 -> 50
  0073    | ResetInput
  0074    | Drop
  0075    | Swap
  0076    | Drop
  0077    | Merge
  0078    | End
  ========================================
  
  =============1:rows_padded==============
  rows_padded(elem, col_sep, row_sep, Pad) =
    peek(_dimensions(elem, col_sep, row_sep)) -> [MaxRowLen, _] &
    elem -> First & _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [First], [])
  ========================================
  0000    | PushVar2 MaxRowLen
  0003    | PushUnderscoreVar
  0004    | PushVar2 First
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | GetConstant 5: peek
  0012    | GetConstant 18: @fn7
  0014    | CreateClosure 3
  0016    | CaptureLocal l0
  0018    | CaptureLocal l1
  0020    | CaptureLocal l2
  0022    | CallFunction 1
  0024    | JumpIfFailure 24 -> 50
  0027    | MatchScrutinee r7
  0029    | MatchType r7 array -> 49
  0034    | MatchLen r7 2 -> 49
  0039    | MatchElem r8 r7[0]
  0043    | MatchBind l4 r8
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | TakeRight 50 -> 63
  0053    | CallFunctionLocal l0
  0055    | JumpIfFailure 55 -> 63
  0058    | MatchScrutinee r7
  0060    | MatchBind l6 r7
  0063    | TakeRight 63 -> 89
  0066    | GetConstant 19: _rows_padded
  0068    | GetLocalMove l0
  0070    | GetLocalMove l1
  0072    | GetLocalMove l2
  0074    | GetLocalMove l3
  0076    | PushInteger 1
  0078    | GetLocalMove l4
  0080    | GetConstantMutable 20: [_]
  0082    | GetLocalMove l6
  0084    | InsertAtIndex 0
  0086    | PushEmptyArray
  0087    | CallTailFunction 8
  0089    | End
  ========================================
  
  =============1:_rows_padded=============
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    col_sep > elem -> Elem ?
    _rows_padded(elem, col_sep, row_sep, Pad, Num.Inc(RowLen), MaxRowLen, [...AccRow, Elem], AccRows) :
    row_sep > elem -> NextRow ?
    _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [NextRow], [...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)]) :
    const([...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)])
  ========================================
  0000    | PushVar Elem
  0002    | PushVar2 NextRow
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | SetInputMark
  0008    | CallFunctionLocal l1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal l0
  0015    | JumpIfFailure 15 -> 23
  0018    | MatchScrutinee r10
  0020    | MatchBind l8 r10
  0023    | ConditionalThen 23 -> 68
  0026    | GetConstant 19: _rows_padded
  0028    | GetLocalMove l0
  0030    | GetLocalMove l1
  0032    | GetLocalMove l2
  0034    | GetLocalMove l3
  0036    | GetConstant 23: Num.Inc
  0038    | GetLocalMove l4
  0040    | CallFunction 1
  0042    | GetLocalMove l5
  0044    | PushEmptyArray
  0045    | JumpIfFailure 45 -> 51
  0048    | GetLocalMove l6
  0050    | Merge
  0051    | JumpIfFailure 51 -> 61
  0054    | GetConstantMutable 27: [_]
  0056    | GetLocalMove l8
  0058    | InsertAtIndex 0
  0060    | Merge
  0061    | GetLocalMove l7
  0063    | CallTailFunction 8
  0065    | Jump 65 -> 180
  0068    | SetInputMark
  0069    | CallFunctionLocal l2
  0071    | TakeRight 71 -> 76
  0074    | CallFunctionLocal l0
  0076    | JumpIfFailure 76 -> 84
  0079    | MatchScrutinee r10
  0081    | MatchBind l9 r10
  0084    | ConditionalThen 84 -> 144
  0087    | GetConstant 19: _rows_padded
  0089    | GetLocalMove l0
  0091    | GetLocalMove l1
  0093    | GetLocalMove l2
  0095    | GetLocal l3
  0097    | PushInteger 1
  0099    | GetLocal l5
  0101    | GetConstantMutable 28: [_]
  0103    | GetLocalMove l9
  0105    | InsertAtIndex 0
  0107    | PushEmptyArray
  0108    | JumpIfFailure 108 -> 114
  0111    | GetLocalMove l7
  0113    | Merge
  0114    | JumpIfFailure 114 -> 139
  0117    | GetConstantMutable 29: [_]
  0119    | GetConstant 30: Array.AppendN
  0121    | GetLocalMove l6
  0123    | GetLocalMove l3
  0125    | GetLocalMove l5
  0127    | JumpIfFailure 127 -> 134
  0130    | GetLocalMove l4
  0132    | NegateNumber
  0133    | Merge
  0134    | CallFunction 3
  0136    | InsertAtIndex 0
  0138    | Merge
  0139    | CallTailFunction 8
  0141    | Jump 141 -> 180
  0144    | GetConstant 25: const
  0146    | PushEmptyArray
  0147    | JumpIfFailure 147 -> 153
  0150    | GetLocalMove l7
  0152    | Merge
  0153    | JumpIfFailure 153 -> 178
  0156    | GetConstantMutable 31: [_]
  0158    | GetConstant 30: Array.AppendN
  0160    | GetLocalMove l6
  0162    | GetLocalMove l3
  0164    | GetLocalMove l5
  0166    | JumpIfFailure 166 -> 173
  0169    | GetLocalMove l4
  0171    | NegateNumber
  0172    | Merge
  0173    | CallFunction 3
  0175    | InsertAtIndex 0
  0177    | Merge
  0178    | CallTailFunction 1
  0180    | End
  ========================================
  
  =============1:_dimensions==============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 21
  0005    | GetConstant 22: __dimensions
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
  0011    | GetLocalMove l2
  0013    | PushInteger 1
  0015    | PushInteger 1
  0017    | PushInteger 0
  0019    | CallTailFunction 6
  0021    | End
  ========================================
  
  =============1:__dimensions=============
  __dimensions(elem, col_sep, row_sep, RowLen, ColLen, MaxRowLen) =
    col_sep > elem ?
    __dimensions(elem, col_sep, row_sep, Num.Inc(RowLen), ColLen, MaxRowLen) :
    row_sep > elem ?
    __dimensions(elem, col_sep, row_sep, $1, Num.Inc(ColLen), Num.Max(RowLen, MaxRowLen)) :
    const([Num.Max(RowLen, MaxRowLen), ColLen])
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l1
  0003    | TakeRight 3 -> 8
  0006    | CallFunctionLocal l0
  0008    | ConditionalThen 8 -> 34
  0011    | GetConstant 22: __dimensions
  0013    | GetLocalMove l0
  0015    | GetLocalMove l1
  0017    | GetLocalMove l2
  0019    | GetConstant 23: Num.Inc
  0021    | GetLocalMove l3
  0023    | CallFunction 1
  0025    | GetLocalMove l4
  0027    | GetLocalMove l5
  0029    | CallTailFunction 6
  0031    | Jump 31 -> 94
  0034    | SetInputMark
  0035    | CallFunctionLocal l2
  0037    | TakeRight 37 -> 42
  0040    | CallFunctionLocal l0
  0042    | ConditionalThen 42 -> 74
  0045    | GetConstant 22: __dimensions
  0047    | GetLocalMove l0
  0049    | GetLocalMove l1
  0051    | GetLocalMove l2
  0053    | PushInteger 1
  0055    | GetConstant 23: Num.Inc
  0057    | GetLocalMove l4
  0059    | CallFunction 1
  0061    | GetConstant 24: Num.Max
  0063    | GetLocalMove l3
  0065    | GetLocalMove l5
  0067    | CallFunction 2
  0069    | CallTailFunction 6
  0071    | Jump 71 -> 94
  0074    | GetConstant 25: const
  0076    | GetConstantMutable 26: [_, _]
  0078    | GetConstant 24: Num.Max
  0080    | GetLocalMove l3
  0082    | GetLocalMove l5
  0084    | CallFunction 2
  0086    | InsertAtIndex 0
  0088    | GetLocalMove l4
  0090    | InsertAtIndex 1
  0092    | CallTailFunction 1
  0094    | End
  ========================================
  
  ===============1:columns================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 32: rows
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
  0011    | GetLocalMove l2
  0013    | CallFunction 3
  0015    | JumpIfFailure 15 -> 23
  0018    | MatchScrutinee r4
  0020    | MatchBind l3 r4
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 33: Table.Transpose
  0028    | GetLocalMove l3
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  ===============1:columns================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 32: rows
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
  0011    | GetLocalMove l2
  0013    | CallFunction 3
  0015    | JumpIfFailure 15 -> 23
  0018    | MatchScrutinee r4
  0020    | MatchBind l3 r4
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 33: Table.Transpose
  0028    | GetLocalMove l3
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 34: rows_padded
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
  0011    | GetLocalMove l2
  0013    | GetLocalMove l3
  0015    | CallFunction 4
  0017    | JumpIfFailure 17 -> 25
  0020    | MatchScrutinee r5
  0022    | MatchBind l4 r5
  0025    | TakeRight 25 -> 34
  0028    | GetConstant 33: Table.Transpose
  0030    | GetLocalMove l4
  0032    | CallTailFunction 1
  0034    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 34: rows_padded
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
  0011    | GetLocalMove l2
  0013    | GetLocalMove l3
  0015    | CallFunction 4
  0017    | JumpIfFailure 17 -> 25
  0020    | MatchScrutinee r5
  0022    | MatchBind l4 r5
  0025    | TakeRight 25 -> 34
  0028    | GetConstant 33: Table.Transpose
  0030    | GetLocalMove l4
  0032    | CallTailFunction 1
  0034    | End
  ========================================
  
  =================1:@fn0=================
  sep > elem
  ========================================
  0000    | PushVar sep
  0002    | PushVar elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal l0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal l1
  0012    | End
  ========================================
  
  =================1:@fn1=================
  tuple1(elem)
  ========================================
  0000    | PushVar elem
  0002    | SetClosureCaptures
  0003    | GetConstant 0: tuple1
  0005    | GetLocalMove l0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================1:@fn2=================
  array(elem)
  ========================================
  0000    | PushVar elem
  0002    | SetClosureCaptures
  0003    | GetConstant 8: array
  0005    | GetLocalMove l0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================1:@fn3=================
  array_sep(elem, sep)
  ========================================
  0000    | PushVar elem
  0002    | PushVar sep
  0004    | SetClosureCaptures
  0005    | GetConstant 10: array_sep
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================1:@fn4=================
  sep > elem
  ========================================
  0000    | PushVar sep
  0002    | PushVar elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal l0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal l1
  0012    | End
  ========================================
  
  =================1:@fn5=================
  array_sep(elem, col_sep)
  ========================================
  0000    | PushVar elem
  0002    | PushVar col_sep
  0004    | SetClosureCaptures
  0005    | GetConstant 10: array_sep
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================1:@fn6=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | PushVar2 row_sep
  0003    | PushVar elem
  0005    | PushVar col_sep
  0007    | SetClosureCaptures
  0008    | CallFunctionLocal l0
  0010    | TakeRight 10 -> 21
  0013    | GetConstant 10: array_sep
  0015    | GetLocalMove l1
  0017    | GetLocalMove l2
  0019    | CallTailFunction 2
  0021    | End
  ========================================
  
  =================1:@fn7=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | PushVar elem
  0002    | PushVar col_sep
  0004    | PushVar2 row_sep
  0007    | SetClosureCaptures
  0008    | GetConstant 21: _dimensions
  0010    | GetLocalMove l0
  0012    | GetLocalMove l1
  0014    | GetLocalMove l2
  0016    | CallTailFunction 3
  0018    | End
  ========================================
  
  =================2:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionConstant 1: @input.offset
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 25
  0017    | GetConstant 2: @at
  0019    | GetLocalMove l1
  0021    | GetLocalMove l0
  0023    | CallTailFunction 2
  0025    | End
  ========================================
  
  ================2:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 0: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal l0
  0013    | End
  ========================================
  
  ===============2:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l0
  0003    | Or 3 -> 12
  0006    | GetConstant 3: const
  0008    | GetLocalMove l1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================2:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ============8:Array.AppendN=============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstantMutable 0: [_]
  0007    | GetLocalMove l1
  0009    | InsertAtIndex 0
  0011    | GetLocalMove l2
  0013    | RepeatValue
  0014    | Merge
  0015    | End
  ========================================
  
  ===========8:Table.Transpose============
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant 1: _Table.Transpose
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ===========8:_Table.Transpose===========
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
  0009    | GetConstant 2: _Table.FirstPerRow
  0011    | GetLocal l0
  0013    | CallFunction 1
  0015    | JumpIfFailure 15 -> 23
  0018    | MatchScrutinee r4
  0020    | MatchBind l2 r4
  0023    | TakeRight 23 -> 40
  0026    | GetConstant 3: _Table.RestPerRow
  0028    | GetLocalMove l0
  0030    | CallFunction 1
  0032    | JumpIfFailure 32 -> 40
  0035    | MatchScrutinee r4
  0037    | MatchBind l3 r4
  0040    | ConditionalThen 40 -> 69
  0043    | GetConstant 1: _Table.Transpose
  0045    | GetLocalMove l3
  0047    | PushEmptyArray
  0048    | JumpIfFailure 48 -> 54
  0051    | GetLocalMove l1
  0053    | Merge
  0054    | JumpIfFailure 54 -> 64
  0057    | GetConstantMutable 4: [_]
  0059    | GetLocalMove l2
  0061    | InsertAtIndex 0
  0063    | Merge
  0064    | CallTailFunction 2
  0066    | Jump 66 -> 71
  0069    | GetLocalMove l1
  0071    | End
  ========================================
  
  ==========8:_Table.FirstPerRow==========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | PushVar2 VeryFirst
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | PushUnderscoreVar
  0012    | PushUnderscoreVar
  0013    | PushUnderscoreVar
  0014    | GetLocalMove l0
  0016    | JumpIfFailure 16 -> 50
  0019    | MatchScrutinee r5
  0021    | MatchType r5 array -> 49
  0026    | MatchLenMin r5 1 -> 49
  0031    | MatchElem r6 r5[0]
  0035    | MatchBind l1 r6
  0038    | MatchSlice r7 r5[1..^0]
  0043    | MatchBind l2 r7
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | TakeRight 50 -> 81
  0053    | GetLocalMove l1
  0055    | JumpIfFailure 55 -> 81
  0058    | MatchScrutinee r5
  0060    | MatchType r5 array -> 80
  0065    | MatchLenMin r5 1 -> 80
  0070    | MatchElem r6 r5[0]
  0074    | MatchBind l3 r6
  0077    | Jump 77 -> 81
  0080    | MatchFail
  0081    | TakeRight 81 -> 96
  0084    | GetConstant 5: __Table.FirstPerRow
  0086    | GetLocalMove l2
  0088    | GetConstantMutable 6: [_]
  0090    | GetLocalMove l3
  0092    | InsertAtIndex 0
  0094    | CallTailFunction 2
  0096    | End
  ========================================
  
  =========8:__Table.FirstPerRow==========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | PushVar2 First
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | PushUnderscoreVar
  0012    | PushUnderscoreVar
  0013    | PushUnderscoreVar
  0014    | SetInputMark
  0015    | GetLocalMove l0
  0017    | JumpIfFailure 17 -> 51
  0020    | MatchScrutinee r6
  0022    | MatchType r6 array -> 50
  0027    | MatchLenMin r6 1 -> 50
  0032    | MatchElem r7 r6[0]
  0036    | MatchBind l2 r7
  0039    | MatchSlice r8 r6[1..^0]
  0044    | MatchBind l3 r8
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | TakeRight 51 -> 82
  0054    | GetLocalMove l2
  0056    | JumpIfFailure 56 -> 82
  0059    | MatchScrutinee r6
  0061    | MatchType r6 array -> 81
  0066    | MatchLenMin r6 1 -> 81
  0071    | MatchElem r7 r6[0]
  0075    | MatchBind l4 r7
  0078    | Jump 78 -> 82
  0081    | MatchFail
  0082    | ConditionalThen 82 -> 111
  0085    | GetConstant 5: __Table.FirstPerRow
  0087    | GetLocalMove l3
  0089    | PushEmptyArray
  0090    | JumpIfFailure 90 -> 96
  0093    | GetLocalMove l1
  0095    | Merge
  0096    | JumpIfFailure 96 -> 106
  0099    | GetConstantMutable 7: [_]
  0101    | GetLocalMove l4
  0103    | InsertAtIndex 0
  0105    | Merge
  0106    | CallTailFunction 2
  0108    | Jump 108 -> 113
  0111    | GetLocalMove l1
  0113    | End
  ========================================
  
  ==========8:_Table.RestPerRow===========
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant 8: __Table.RestPerRow
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ==========8:__Table.RestPerRow==========
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
  0010    | PushUnderscoreVar
  0011    | PushUnderscoreVar
  0012    | PushUnderscoreVar
  0013    | PushUnderscoreVar
  0014    | SetInputMark
  0015    | GetLocalMove l0
  0017    | JumpIfFailure 17 -> 51
  0020    | MatchScrutinee r6
  0022    | MatchType r6 array -> 50
  0027    | MatchLenMin r6 1 -> 50
  0032    | MatchElem r7 r6[0]
  0036    | MatchBind l2 r7
  0039    | MatchSlice r8 r6[1..^0]
  0044    | MatchBind l3 r8
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | ConditionalThen 51 -> 135
  0054    | SetInputMark
  0055    | GetLocalMove l2
  0057    | JumpIfFailure 57 -> 84
  0060    | MatchScrutinee r6
  0062    | MatchType r6 array -> 83
  0067    | MatchLenMin r6 1 -> 83
  0072    | MatchSlice r7 r6[1..^0]
  0077    | MatchBind l5 r7
  0080    | Jump 80 -> 84
  0083    | MatchFail
  0084    | ConditionalThen 84 -> 113
  0087    | GetConstant 8: __Table.RestPerRow
  0089    | GetLocalMove l3
  0091    | PushEmptyArray
  0092    | JumpIfFailure 92 -> 98
  0095    | GetLocalMove l1
  0097    | Merge
  0098    | JumpIfFailure 98 -> 108
  0101    | GetConstantMutable 9: [_]
  0103    | GetLocalMove l5
  0105    | InsertAtIndex 0
  0107    | Merge
  0108    | CallTailFunction 2
  0110    | Jump 110 -> 132
  0113    | GetConstant 8: __Table.RestPerRow
  0115    | GetLocalMove l3
  0117    | PushEmptyArray
  0118    | JumpIfFailure 118 -> 124
  0121    | GetLocalMove l1
  0123    | Merge
  0124    | JumpIfFailure 124 -> 130
  0127    | GetConstant 10: [[]]
  0129    | Merge
  0130    | CallTailFunction 2
  0132    | Jump 132 -> 137
  0135    | GetLocalMove l1
  0137    | End
  ========================================
  
  ===============9:Num.Inc================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant 0: @Add
  0002    | GetLocalMove l0
  0004    | PushInteger 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============9:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r2
  0010    | MatchInRange r2 s1.. -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | ConditionalThen 24 -> 32
  0027    | GetLocalMove l0
  0029    | Jump 29 -> 34
  0032    | GetLocalMove l1
  0034    | End
  ========================================
