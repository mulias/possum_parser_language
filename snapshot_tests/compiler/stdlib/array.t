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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================1:tuple2================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l2 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 50
  0022    | CallFunctionLocal l1
  0024    | JumpIfFailure 24 -> 37
  0027    | MatchWindowEnter 2 fail->36
  0031    | MatchScrutinee r0
  0033    | MatchBind l3 r0
  0036    | MatchWindowExit
  0037    | TakeRight 37 -> 50
  0040    | GetConstantMutable 11: [_, _]
  0042    | GetLocalMove l2
  0044    | InsertAtIndex 0
  0046    | GetLocalMove l3
  0048    | InsertAtIndex 1
  0050    | End
  ========================================
  
  ==============1:tuple2_sep==============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l3 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 24
  0022    | CallFunctionLocal l1
  0024    | TakeRight 24 -> 55
  0027    | CallFunctionLocal l2
  0029    | JumpIfFailure 29 -> 42
  0032    | MatchWindowEnter 2 fail->41
  0036    | MatchScrutinee r0
  0038    | MatchBind l4 r0
  0041    | MatchWindowExit
  0042    | TakeRight 42 -> 55
  0045    | GetConstantMutable 12: [_, _]
  0047    | GetLocalMove l3
  0049    | InsertAtIndex 0
  0051    | GetLocalMove l4
  0053    | InsertAtIndex 1
  0055    | End
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
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l3 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 39
  0024    | CallFunctionLocal l1
  0026    | JumpIfFailure 26 -> 39
  0029    | MatchWindowEnter 2 fail->38
  0033    | MatchScrutinee r0
  0035    | MatchBind l4 r0
  0038    | MatchWindowExit
  0039    | TakeRight 39 -> 74
  0042    | CallFunctionLocal l2
  0044    | JumpIfFailure 44 -> 57
  0047    | MatchWindowEnter 2 fail->56
  0051    | MatchScrutinee r0
  0053    | MatchBind l5 r0
  0056    | MatchWindowExit
  0057    | TakeRight 57 -> 74
  0060    | GetConstantMutable 13: [_, _, _]
  0062    | GetLocalMove l3
  0064    | InsertAtIndex 0
  0066    | GetLocalMove l4
  0068    | InsertAtIndex 1
  0070    | GetLocalMove l5
  0072    | InsertAtIndex 2
  0074    | End
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
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l5 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 26
  0024    | CallFunctionLocal l1
  0026    | TakeRight 26 -> 44
  0029    | CallFunctionLocal l2
  0031    | JumpIfFailure 31 -> 44
  0034    | MatchWindowEnter 2 fail->43
  0038    | MatchScrutinee r0
  0040    | MatchBind l6 r0
  0043    | MatchWindowExit
  0044    | TakeRight 44 -> 49
  0047    | CallFunctionLocal l3
  0049    | TakeRight 49 -> 84
  0052    | CallFunctionLocal l4
  0054    | JumpIfFailure 54 -> 67
  0057    | MatchWindowEnter 2 fail->66
  0061    | MatchScrutinee r0
  0063    | MatchBind l7 r0
  0066    | MatchWindowExit
  0067    | TakeRight 67 -> 84
  0070    | GetConstantMutable 14: [_, _, _]
  0072    | GetLocalMove l5
  0074    | InsertAtIndex 0
  0076    | GetLocalMove l6
  0078    | InsertAtIndex 1
  0080    | GetLocalMove l7
  0082    | InsertAtIndex 2
  0084    | End
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
  0006    | JumpIfFailure 6 -> 89
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
  0062    | JumpIfFailure 62 -> 87
  0065    | MatchWindowEnter 2 fail->85
  0069    | MatchScrutinee r0
  0071    | MatchMergeNum r1 r0 - -1
  0077    | MatchCmp r1 == l2
  0082    | Jump 82 -> 86
  0085    | MatchFail
  0086    | MatchWindowExit
  0087    | Drop
  0088    | Merge
  0089    | End
  ========================================
  
  =================1:rows=================
  rows(elem, col_sep, row_sep) =
    tuple1(array_sep(elem, col_sep)) +
    (tuple1(row_sep > array_sep(elem, col_sep)) * 0..)
  ========================================
  0000    | GetConstant 0: tuple1
  0002    | GetConstant 17: @fn5
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
  0025    | GetConstant 18: @fn6
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
  0053    | GetConstant 18: @fn6
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
  0008    | GetConstant 19: @fn7
  0010    | CreateClosure 3
  0012    | CaptureLocal l0
  0014    | CaptureLocal l1
  0016    | CaptureLocal l2
  0018    | CallFunction 1
  0020    | JumpIfFailure 20 -> 49
  0023    | MatchWindowEnter 3 fail->47
  0027    | MatchScrutinee r0
  0029    | MatchType r0 array
  0032    | MatchCount r0 ==2
  0036    | MatchElem r1 r0[0]
  0041    | MatchBind l4 r1
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | TakeRight 49 -> 67
  0052    | CallFunctionLocal l0
  0054    | JumpIfFailure 54 -> 67
  0057    | MatchWindowEnter 2 fail->66
  0061    | MatchScrutinee r0
  0063    | MatchBind l5 r0
  0066    | MatchWindowExit
  0067    | TakeRight 67 -> 93
  0070    | GetConstant 20: _rows_padded
  0072    | GetLocalMove l0
  0074    | GetLocalMove l1
  0076    | GetLocalMove l2
  0078    | GetLocalMove l3
  0080    | PushInteger 1
  0082    | GetLocalMove l4
  0084    | GetConstantMutable 21: [_]
  0086    | GetLocalMove l5
  0088    | InsertAtIndex 0
  0090    | PushEmptyArray
  0091    | CallTailFunction 8
  0093    | End
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
  0013    | JumpIfFailure 13 -> 26
  0016    | MatchWindowEnter 2 fail->25
  0020    | MatchScrutinee r0
  0022    | MatchBind l8 r0
  0025    | MatchWindowExit
  0026    | ConditionalThen 26 -> 71
  0029    | GetConstant 20: _rows_padded
  0031    | GetLocalMove l0
  0033    | GetLocalMove l1
  0035    | GetLocalMove l2
  0037    | GetLocalMove l3
  0039    | GetConstant 24: Num.Inc
  0041    | GetLocalMove l4
  0043    | CallFunction 1
  0045    | GetLocalMove l5
  0047    | PushEmptyArray
  0048    | JumpIfFailure 48 -> 54
  0051    | GetLocalMove l6
  0053    | Merge
  0054    | JumpIfFailure 54 -> 64
  0057    | GetConstantMutable 28: [_]
  0059    | GetLocalMove l8
  0061    | InsertAtIndex 0
  0063    | Merge
  0064    | GetLocalMove l7
  0066    | CallTailFunction 8
  0068    | Jump 68 -> 188
  0071    | SetInputMark
  0072    | CallFunctionLocal l2
  0074    | TakeRight 74 -> 79
  0077    | CallFunctionLocal l0
  0079    | JumpIfFailure 79 -> 92
  0082    | MatchWindowEnter 2 fail->91
  0086    | MatchScrutinee r0
  0088    | MatchBind l9 r0
  0091    | MatchWindowExit
  0092    | ConditionalThen 92 -> 152
  0095    | GetConstant 20: _rows_padded
  0097    | GetLocalMove l0
  0099    | GetLocalMove l1
  0101    | GetLocalMove l2
  0103    | GetLocal l3
  0105    | PushInteger 1
  0107    | GetLocal l5
  0109    | GetConstantMutable 29: [_]
  0111    | GetLocalMove l9
  0113    | InsertAtIndex 0
  0115    | PushEmptyArray
  0116    | JumpIfFailure 116 -> 122
  0119    | GetLocalMove l7
  0121    | Merge
  0122    | JumpIfFailure 122 -> 147
  0125    | GetConstantMutable 30: [_]
  0127    | GetConstant 31: Array.AppendN
  0129    | GetLocalMove l6
  0131    | GetLocalMove l3
  0133    | GetLocalMove l5
  0135    | JumpIfFailure 135 -> 142
  0138    | GetLocalMove l4
  0140    | NegateNumber
  0141    | Merge
  0142    | CallFunction 3
  0144    | InsertAtIndex 0
  0146    | Merge
  0147    | CallTailFunction 8
  0149    | Jump 149 -> 188
  0152    | GetConstant 26: const
  0154    | PushEmptyArray
  0155    | JumpIfFailure 155 -> 161
  0158    | GetLocalMove l7
  0160    | Merge
  0161    | JumpIfFailure 161 -> 186
  0164    | GetConstantMutable 32: [_]
  0166    | GetConstant 31: Array.AppendN
  0168    | GetLocalMove l6
  0170    | GetLocalMove l3
  0172    | GetLocalMove l5
  0174    | JumpIfFailure 174 -> 181
  0177    | GetLocalMove l4
  0179    | NegateNumber
  0180    | Merge
  0181    | CallFunction 3
  0183    | InsertAtIndex 0
  0185    | Merge
  0186    | CallTailFunction 1
  0188    | End
  ========================================
  
  =============1:_dimensions==============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 21
  0005    | GetConstant 23: __dimensions
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
  0011    | GetConstant 23: __dimensions
  0013    | GetLocalMove l0
  0015    | GetLocalMove l1
  0017    | GetLocalMove l2
  0019    | GetConstant 24: Num.Inc
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
  0045    | GetConstant 23: __dimensions
  0047    | GetLocalMove l0
  0049    | GetLocalMove l1
  0051    | GetLocalMove l2
  0053    | PushInteger 1
  0055    | GetConstant 24: Num.Inc
  0057    | GetLocalMove l4
  0059    | CallFunction 1
  0061    | GetConstant 25: Num.Max
  0063    | GetLocalMove l3
  0065    | GetLocalMove l5
  0067    | CallFunction 2
  0069    | CallTailFunction 6
  0071    | Jump 71 -> 94
  0074    | GetConstant 26: const
  0076    | GetConstantMutable 27: [_, _]
  0078    | GetConstant 25: Num.Max
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
  0003    | GetConstant 33: rows
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | CallFunction 3
  0013    | JumpIfFailure 13 -> 26
  0016    | MatchWindowEnter 2 fail->25
  0020    | MatchScrutinee r0
  0022    | MatchBind l3 r0
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 35
  0029    | GetConstant 34: Table.Transpose
  0031    | GetLocalMove l3
  0033    | CallTailFunction 1
  0035    | End
  ========================================
  
  ===============1:columns================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 33: rows
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | CallFunction 3
  0013    | JumpIfFailure 13 -> 26
  0016    | MatchWindowEnter 2 fail->25
  0020    | MatchScrutinee r0
  0022    | MatchBind l3 r0
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 35
  0029    | GetConstant 34: Table.Transpose
  0031    | GetLocalMove l3
  0033    | CallTailFunction 1
  0035    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 35: rows_padded
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | GetLocalMove l3
  0013    | CallFunction 4
  0015    | JumpIfFailure 15 -> 28
  0018    | MatchWindowEnter 2 fail->27
  0022    | MatchScrutinee r0
  0024    | MatchBind l4 r0
  0027    | MatchWindowExit
  0028    | TakeRight 28 -> 37
  0031    | GetConstant 34: Table.Transpose
  0033    | GetLocalMove l4
  0035    | CallTailFunction 1
  0037    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 35: rows_padded
  0005    | GetLocalMove l0
  0007    | GetLocalMove l1
  0009    | GetLocalMove l2
  0011    | GetLocalMove l3
  0013    | CallFunction 4
  0015    | JumpIfFailure 15 -> 28
  0018    | MatchWindowEnter 2 fail->27
  0022    | MatchScrutinee r0
  0024    | MatchBind l4 r0
  0027    | MatchWindowExit
  0028    | TakeRight 28 -> 37
  0031    | GetConstant 34: Table.Transpose
  0033    | GetLocalMove l4
  0035    | CallTailFunction 1
  0037    | End
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
  0000    | PushVar row_sep
  0002    | PushVar elem
  0004    | PushVar col_sep
  0006    | SetClosureCaptures
  0007    | CallFunctionLocal l0
  0009    | TakeRight 9 -> 20
  0012    | GetConstant 10: array_sep
  0014    | GetLocalMove l1
  0016    | GetLocalMove l2
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  =================1:@fn7=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | PushVar elem
  0002    | PushVar col_sep
  0004    | PushVar row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 22: _dimensions
  0009    | GetLocalMove l0
  0011    | GetLocalMove l1
  0013    | GetLocalMove l2
  0015    | CallTailFunction 3
  0017    | End
  ========================================
  
  =================2:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | CallFunctionConstant 1: @input.offset
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 28
  0020    | GetConstant 2: @at
  0022    | GetLocalMove l1
  0024    | GetLocalMove l0
  0026    | CallTailFunction 2
  0028    | End
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
  0013    | JumpIfFailure 13 -> 26
  0016    | MatchWindowEnter 2 fail->25
  0020    | MatchScrutinee r0
  0022    | MatchBind l2 r0
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 48
  0029    | GetConstant 3: _Table.RestPerRow
  0031    | GetLocalMove l0
  0033    | CallFunction 1
  0035    | JumpIfFailure 35 -> 48
  0038    | MatchWindowEnter 2 fail->47
  0042    | MatchScrutinee r0
  0044    | MatchBind l3 r0
  0047    | MatchWindowExit
  0048    | ConditionalThen 48 -> 77
  0051    | GetConstant 1: _Table.Transpose
  0053    | GetLocalMove l3
  0055    | PushEmptyArray
  0056    | JumpIfFailure 56 -> 62
  0059    | GetLocalMove l1
  0061    | Merge
  0062    | JumpIfFailure 62 -> 72
  0065    | GetConstantMutable 4: [_]
  0067    | GetLocalMove l2
  0069    | InsertAtIndex 0
  0071    | Merge
  0072    | CallTailFunction 2
  0074    | Jump 74 -> 79
  0077    | GetLocalMove l1
  0079    | End
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
  0014    | MatchWindowEnter 4 fail->46
  0018    | MatchScrutinee r0
  0020    | MatchType r0 array
  0023    | MatchCount r0 >=1
  0027    | MatchElem r1 r0[0]
  0032    | MatchBind l1 r1
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l2 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | TakeRight 48 -> 82
  0051    | GetLocalMove l1
  0053    | JumpIfFailure 53 -> 82
  0056    | MatchWindowEnter 3 fail->80
  0060    | MatchScrutinee r0
  0062    | MatchType r0 array
  0065    | MatchCount r0 >=1
  0069    | MatchElem r1 r0[0]
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
  0015    | MatchWindowEnter 4 fail->47
  0019    | MatchScrutinee r0
  0021    | MatchType r0 array
  0024    | MatchCount r0 >=1
  0028    | MatchElem r1 r0[0]
  0033    | MatchBind l2 r1
  0036    | MatchSlice r2 r0[1..^0]
  0041    | MatchBind l3 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | TakeRight 49 -> 83
  0052    | GetLocalMove l2
  0054    | JumpIfFailure 54 -> 83
  0057    | MatchWindowEnter 3 fail->81
  0061    | MatchScrutinee r0
  0063    | MatchType r0 array
  0066    | MatchCount r0 >=1
  0070    | MatchElem r1 r0[0]
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
  0015    | MatchWindowEnter 4 fail->47
  0019    | MatchScrutinee r0
  0021    | MatchType r0 array
  0024    | MatchCount r0 >=1
  0028    | MatchElem r1 r0[0]
  0033    | MatchBind l2 r1
  0036    | MatchSlice r2 r0[1..^0]
  0041    | MatchBind l3 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | ConditionalThen 49 -> 135
  0052    | SetInputMark
  0053    | GetLocalMove l2
  0055    | JumpIfFailure 55 -> 84
  0058    | MatchWindowEnter 3 fail->82
  0062    | MatchScrutinee r0
  0064    | MatchType r0 array
  0067    | MatchCount r0 >=1
  0071    | MatchSlice r1 r0[1..^0]
  0076    | MatchBind l4 r1
  0079    | Jump 79 -> 83
  0082    | MatchFail
  0083    | MatchWindowExit
  0084    | ConditionalThen 84 -> 113
  0087    | GetConstant 8: __Table.RestPerRow
  0089    | GetLocalMove l3
  0091    | PushEmptyArray
  0092    | JumpIfFailure 92 -> 98
  0095    | GetLocalMove l1
  0097    | Merge
  0098    | JumpIfFailure 98 -> 108
  0101    | GetConstantMutable 9: [_]
  0103    | GetLocalMove l4
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
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 26
  0006    | MatchWindowEnter 2 fail->24
  0010    | MatchScrutinee r0
  0012    | MatchType r0 num_or_codepoint
  0015    | MatchBound r0 lo s1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | ConditionalThen 26 -> 34
  0029    | GetLocalMove l0
  0031    | Jump 31 -> 36
  0034    | GetLocalMove l1
  0036    | End
  ========================================
