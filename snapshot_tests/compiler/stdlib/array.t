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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================1:tuple2================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 46
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 46
  0036    | GetConstantMutable 11: [_, _]
  0038    | GetLocalMove l2
  0040    | InsertAtIndex 0
  0042    | GetLocalMove l3
  0044    | InsertAtIndex 1
  0046    | End
  ========================================
  
  ==============1:tuple2_sep==============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l3 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 22
  0020    | CallFunctionLocal l1
  0022    | TakeRight 22 -> 51
  0025    | CallFunctionLocal l2
  0027    | JumpIfFailure 27 -> 38
  0030    | MatchWindowEnter 2
  0032    | MatchScrutinee r0
  0034    | MatchBind l4 r0
  0037    | MatchWindowExit
  0038    | TakeRight 38 -> 51
  0041    | GetConstantMutable 12: [_, _]
  0043    | GetLocalMove l3
  0045    | InsertAtIndex 0
  0047    | GetLocalMove l4
  0049    | InsertAtIndex 1
  0051    | End
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
  0006    | CallFunctionLocal l0
  0008    | JumpIfFailure 8 -> 19
  0011    | MatchWindowEnter 2
  0013    | MatchScrutinee r0
  0015    | MatchBind l3 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 35
  0022    | CallFunctionLocal l1
  0024    | JumpIfFailure 24 -> 35
  0027    | MatchWindowEnter 2
  0029    | MatchScrutinee r0
  0031    | MatchBind l4 r0
  0034    | MatchWindowExit
  0035    | TakeRight 35 -> 68
  0038    | CallFunctionLocal l2
  0040    | JumpIfFailure 40 -> 51
  0043    | MatchWindowEnter 2
  0045    | MatchScrutinee r0
  0047    | MatchBind l5 r0
  0050    | MatchWindowExit
  0051    | TakeRight 51 -> 68
  0054    | GetConstantMutable 13: [_, _, _]
  0056    | GetLocalMove l3
  0058    | InsertAtIndex 0
  0060    | GetLocalMove l4
  0062    | InsertAtIndex 1
  0064    | GetLocalMove l5
  0066    | InsertAtIndex 2
  0068    | End
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
  0006    | CallFunctionLocal l0
  0008    | JumpIfFailure 8 -> 19
  0011    | MatchWindowEnter 2
  0013    | MatchScrutinee r0
  0015    | MatchBind l5 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 24
  0022    | CallFunctionLocal l1
  0024    | TakeRight 24 -> 40
  0027    | CallFunctionLocal l2
  0029    | JumpIfFailure 29 -> 40
  0032    | MatchWindowEnter 2
  0034    | MatchScrutinee r0
  0036    | MatchBind l6 r0
  0039    | MatchWindowExit
  0040    | TakeRight 40 -> 45
  0043    | CallFunctionLocal l3
  0045    | TakeRight 45 -> 78
  0048    | CallFunctionLocal l4
  0050    | JumpIfFailure 50 -> 61
  0053    | MatchWindowEnter 2
  0055    | MatchScrutinee r0
  0057    | MatchBind l7 r0
  0060    | MatchWindowExit
  0061    | TakeRight 61 -> 78
  0064    | GetConstantMutable 14: [_, _, _]
  0066    | GetLocalMove l5
  0068    | InsertAtIndex 0
  0070    | GetLocalMove l6
  0072    | InsertAtIndex 1
  0074    | GetLocalMove l7
  0076    | InsertAtIndex 2
  0078    | End
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
  0003    | PushVar2 First
  0006    | GetConstant 5: peek
  0008    | GetConstant 18: @fn7
  0010    | CreateClosure 3
  0012    | CaptureLocal l0
  0014    | CaptureLocal l1
  0016    | CaptureLocal l2
  0018    | CallFunction 1
  0020    | JumpIfFailure 20 -> 49
  0023    | MatchWindowEnter 3
  0025    | MatchScrutinee r0
  0027    | MatchType r0 array -> 47
  0032    | MatchLen r0 2 -> 47
  0037    | MatchElem r1 r0[0]
  0041    | MatchBind l4 r1
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | TakeRight 49 -> 65
  0052    | CallFunctionLocal l0
  0054    | JumpIfFailure 54 -> 65
  0057    | MatchWindowEnter 2
  0059    | MatchScrutinee r0
  0061    | MatchBind l5 r0
  0064    | MatchWindowExit
  0065    | TakeRight 65 -> 91
  0068    | GetConstant 19: _rows_padded
  0070    | GetLocalMove l0
  0072    | GetLocalMove l1
  0074    | GetLocalMove l2
  0076    | GetLocalMove l3
  0078    | PushInteger 1
  0080    | GetLocalMove l4
  0082    | GetConstantMutable 20: [_]
  0084    | GetLocalMove l5
  0086    | InsertAtIndex 0
  0088    | PushEmptyArray
  0089    | CallTailFunction 8
  0091    | End
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
  0005    | SetInputMark
  0006    | CallFunctionLocal l1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal l0
  0013    | JumpIfFailure 13 -> 24
  0016    | MatchWindowEnter 2
  0018    | MatchScrutinee r0
  0020    | MatchBind l8 r0
  0023    | MatchWindowExit
  0024    | ConditionalThen 24 -> 69
  0027    | GetConstant 19: _rows_padded
  0029    | GetLocalMove l0
  0031    | GetLocalMove l1
  0033    | GetLocalMove l2
  0035    | GetLocalMove l3
  0037    | GetConstant 23: Num.Inc
  0039    | GetLocalMove l4
  0041    | CallFunction 1
  0043    | GetLocalMove l5
  0045    | PushEmptyArray
  0046    | JumpIfFailure 46 -> 52
  0049    | GetLocalMove l6
  0051    | Merge
  0052    | JumpIfFailure 52 -> 62
  0055    | GetConstantMutable 27: [_]
  0057    | GetLocalMove l8
  0059    | InsertAtIndex 0
  0061    | Merge
  0062    | GetLocalMove l7
  0064    | CallTailFunction 8
  0066    | Jump 66 -> 184
  0069    | SetInputMark
  0070    | CallFunctionLocal l2
  0072    | TakeRight 72 -> 77
  0075    | CallFunctionLocal l0
  0077    | JumpIfFailure 77 -> 88
  0080    | MatchWindowEnter 2
  0082    | MatchScrutinee r0
  0084    | MatchBind l9 r0
  0087    | MatchWindowExit
  0088    | ConditionalThen 88 -> 148
  0091    | GetConstant 19: _rows_padded
  0093    | GetLocalMove l0
  0095    | GetLocalMove l1
  0097    | GetLocalMove l2
  0099    | GetLocal l3
  0101    | PushInteger 1
  0103    | GetLocal l5
  0105    | GetConstantMutable 28: [_]
  0107    | GetLocalMove l9
  0109    | InsertAtIndex 0
  0111    | PushEmptyArray
  0112    | JumpIfFailure 112 -> 118
  0115    | GetLocalMove l7
  0117    | Merge
  0118    | JumpIfFailure 118 -> 143
  0121    | GetConstantMutable 29: [_]
  0123    | GetConstant 30: Array.AppendN
  0125    | GetLocalMove l6
  0127    | GetLocalMove l3
  0129    | GetLocalMove l5
  0131    | JumpIfFailure 131 -> 138
  0134    | GetLocalMove l4
  0136    | NegateNumber
  0137    | Merge
  0138    | CallFunction 3
  0140    | InsertAtIndex 0
  0142    | Merge
  0143    | CallTailFunction 8
  0145    | Jump 145 -> 184
  0148    | GetConstant 25: const
  0150    | PushEmptyArray
  0151    | JumpIfFailure 151 -> 157
  0154    | GetLocalMove l7
  0156    | Merge
  0157    | JumpIfFailure 157 -> 182
  0160    | GetConstantMutable 31: [_]
  0162    | GetConstant 30: Array.AppendN
  0164    | GetLocalMove l6
  0166    | GetLocalMove l3
  0168    | GetLocalMove l5
  0170    | JumpIfFailure 170 -> 177
  0173    | GetLocalMove l4
  0175    | NegateNumber
  0176    | Merge
  0177    | CallFunction 3
  0179    | InsertAtIndex 0
  0181    | Merge
  0182    | CallTailFunction 1
  0184    | End
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
  0003    | GetConstant 32: rows
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | CallFunction 3
  0013    | JumpIfFailure 13 -> 24
  0016    | MatchWindowEnter 2
  0018    | MatchScrutinee r0
  0020    | MatchBind l3 r0
  0023    | MatchWindowExit
  0024    | TakeRight 24 -> 33
  0027    | GetConstant 33: Table.Transpose
  0029    | GetLocalMove l3
  0031    | CallTailFunction 1
  0033    | End
  ========================================
  
  ===============1:columns================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 32: rows
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | CallFunction 3
  0013    | JumpIfFailure 13 -> 24
  0016    | MatchWindowEnter 2
  0018    | MatchScrutinee r0
  0020    | MatchBind l3 r0
  0023    | MatchWindowExit
  0024    | TakeRight 24 -> 33
  0027    | GetConstant 33: Table.Transpose
  0029    | GetLocalMove l3
  0031    | CallTailFunction 1
  0033    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 34: rows_padded
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | GetLocalMove l3
  0013    | CallFunction 4
  0015    | JumpIfFailure 15 -> 26
  0018    | MatchWindowEnter 2
  0020    | MatchScrutinee r0
  0022    | MatchBind l4 r0
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 35
  0029    | GetConstant 33: Table.Transpose
  0031    | GetLocalMove l4
  0033    | CallTailFunction 1
  0035    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 34: rows_padded
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | GetLocalMove l3
  0013    | CallFunction 4
  0015    | JumpIfFailure 15 -> 26
  0018    | MatchWindowEnter 2
  0020    | MatchScrutinee r0
  0022    | MatchBind l4 r0
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 35
  0029    | GetConstant 33: Table.Transpose
  0031    | GetLocalMove l4
  0033    | CallTailFunction 1
  0035    | End
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
  0002    | CallFunctionConstant 1: @input.offset
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 26
  0018    | GetConstant 2: @at
  0020    | GetLocalMove l1
  0022    | GetLocalMove l0
  0024    | CallTailFunction 2
  0026    | End
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
  0006    | SetInputMark
  0007    | GetConstant 2: _Table.FirstPerRow
  0009    | GetLocal l0
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 24
  0016    | MatchWindowEnter 2
  0018    | MatchScrutinee r0
  0020    | MatchBind l2 r0
  0023    | MatchWindowExit
  0024    | TakeRight 24 -> 44
  0027    | GetConstant 3: _Table.RestPerRow
  0029    | GetLocalMove l0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 44
  0036    | MatchWindowEnter 2
  0038    | MatchScrutinee r0
  0040    | MatchBind l3 r0
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 73
  0047    | GetConstant 1: _Table.Transpose
  0049    | GetLocalMove l3
  0051    | PushEmptyArray
  0052    | JumpIfFailure 52 -> 58
  0055    | GetLocalMove l1
  0057    | Merge
  0058    | JumpIfFailure 58 -> 68
  0061    | GetConstantMutable 4: [_]
  0063    | GetLocalMove l2
  0065    | InsertAtIndex 0
  0067    | Merge
  0068    | CallTailFunction 2
  0070    | Jump 70 -> 75
  0073    | GetLocalMove l1
  0075    | End
  ========================================
  
  ==========8:_Table.FirstPerRow==========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | PushVar2 VeryFirst
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
  0085    | GetConstant 5: __Table.FirstPerRow
  0087    | GetLocalMove l2
  0089    | GetConstantMutable 6: [_]
  0091    | GetLocalMove l3
  0093    | InsertAtIndex 0
  0095    | CallTailFunction 2
  0097    | End
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
  0049    | TakeRight 49 -> 83
  0052    | GetLocalMove l2
  0054    | JumpIfFailure 54 -> 83
  0057    | MatchWindowEnter 3
  0059    | MatchScrutinee r0
  0061    | MatchType r0 array -> 81
  0066    | MatchLenMin r0 1 -> 81
  0071    | MatchElem r1 r0[0]
  0075    | MatchBind l4 r1
  0078    | Jump 78 -> 82
  0081    | MatchFail
  0082    | MatchWindowExit
  0083    | ConditionalThen 83 -> 112
  0086    | GetConstant 5: __Table.FirstPerRow
  0088    | GetLocalMove l3
  0090    | PushEmptyArray
  0091    | JumpIfFailure 91 -> 97
  0094    | GetLocalMove l1
  0096    | Merge
  0097    | JumpIfFailure 97 -> 107
  0100    | GetConstantMutable 7: [_]
  0102    | GetLocalMove l4
  0104    | InsertAtIndex 0
  0106    | Merge
  0107    | CallTailFunction 2
  0109    | Jump 109 -> 114
  0112    | GetLocalMove l1
  0114    | End
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
  0077    | MatchBind l4 r1
  0080    | Jump 80 -> 84
  0083    | MatchFail
  0084    | MatchWindowExit
  0085    | ConditionalThen 85 -> 114
  0088    | GetConstant 8: __Table.RestPerRow
  0090    | GetLocalMove l3
  0092    | PushEmptyArray
  0093    | JumpIfFailure 93 -> 99
  0096    | GetLocalMove l1
  0098    | Merge
  0099    | JumpIfFailure 99 -> 109
  0102    | GetConstantMutable 9: [_]
  0104    | GetLocalMove l4
  0106    | InsertAtIndex 0
  0108    | Merge
  0109    | CallTailFunction 2
  0111    | Jump 111 -> 133
  0114    | GetConstant 8: __Table.RestPerRow
  0116    | GetLocalMove l3
  0118    | PushEmptyArray
  0119    | JumpIfFailure 119 -> 125
  0122    | GetLocalMove l1
  0124    | Merge
  0125    | JumpIfFailure 125 -> 131
  0128    | GetConstant 10: [[]]
  0130    | Merge
  0131    | CallTailFunction 2
  0133    | Jump 133 -> 138
  0136    | GetLocalMove l1
  0138    | End
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
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 25
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchInRange r0 s1.. -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | ConditionalThen 25 -> 33
  0028    | GetLocalMove l0
  0030    | Jump 30 -> 35
  0033    | GetLocalMove l1
  0035    | End
  ========================================
