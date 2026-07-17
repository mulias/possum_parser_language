  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array.possum -i '' --no-stdlib
  
  ================0:@fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  =================0:@Add=================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 6: addNative
  0006    | End
  ========================================
  
  ============0:@input.offset=============
  0000    | NativeCode 2: inputOffsetNative
  0002    | End
  ========================================
  
  =================0:@at==================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | NativeCode 4: setInputPositionNative
  0005    | JumpIfFailure 5 -> 13
  0008    | GetLocal 1
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
  0010    | GetLocal 0
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
  0030    | GetLocal 0
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
  0002    | GetLocal 0
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
  0023    | CaptureLocal 1
  0025    | CaptureLocal 0
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
  0049    | CaptureLocal 1
  0051    | CaptureLocal 0
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
  0014    | CaptureLocal 0
  0016    | GetLocal 1
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
  0040    | CaptureLocal 0
  0042    | GetLocal 1
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
  0063    | GetLocalMove 1
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
  0006    | CaptureLocal 0
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
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyArray
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ================1:tuple1================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar Elem
  0002    | CallFunctionLocal 0
  0004    | DestructurePlan 0: bind Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 1: [_]
  0011    | GetLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
  ========================================
  
  ================1:tuple2================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | CallFunctionLocal 0
  0006    | DestructurePlan 1: bind E1
  0008    | TakeRight 8 -> 28
  0011    | CallFunctionLocal 1
  0013    | DestructurePlan 2: bind E2
  0015    | TakeRight 15 -> 28
  0018    | GetConstantMutable 11: [_, _]
  0020    | GetLocalMove 2
  0022    | InsertAtIndex 0
  0024    | GetLocalMove 3
  0026    | InsertAtIndex 1
  0028    | End
  ========================================
  
  ==============1:tuple2_sep==============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar E1
  0002    | PushVar E2
  0004    | CallFunctionLocal 0
  0006    | DestructurePlan 3: bind E1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 1
  0013    | TakeRight 13 -> 33
  0016    | CallFunctionLocal 2
  0018    | DestructurePlan 4: bind E2
  0020    | TakeRight 20 -> 33
  0023    | GetConstantMutable 12: [_, _]
  0025    | GetLocalMove 3
  0027    | InsertAtIndex 0
  0029    | GetLocalMove 4
  0031    | InsertAtIndex 1
  0033    | End
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
  0006    | CallFunctionLocal 0
  0008    | DestructurePlan 5: bind E1
  0010    | TakeRight 10 -> 17
  0013    | CallFunctionLocal 1
  0015    | DestructurePlan 6: bind E2
  0017    | TakeRight 17 -> 41
  0020    | CallFunctionLocal 2
  0022    | DestructurePlan 7: bind E3
  0024    | TakeRight 24 -> 41
  0027    | GetConstantMutable 13: [_, _, _]
  0029    | GetLocalMove 3
  0031    | InsertAtIndex 0
  0033    | GetLocalMove 4
  0035    | InsertAtIndex 1
  0037    | GetLocalMove 5
  0039    | InsertAtIndex 2
  0041    | End
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
  0006    | CallFunctionLocal 0
  0008    | DestructurePlan 8: bind E1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 22
  0018    | CallFunctionLocal 2
  0020    | DestructurePlan 9: bind E2
  0022    | TakeRight 22 -> 27
  0025    | CallFunctionLocal 3
  0027    | TakeRight 27 -> 51
  0030    | CallFunctionLocal 4
  0032    | DestructurePlan 10: bind E3
  0034    | TakeRight 34 -> 51
  0037    | GetConstantMutable 14: [_, _, _]
  0039    | GetLocalMove 5
  0041    | InsertAtIndex 0
  0043    | GetLocalMove 6
  0045    | InsertAtIndex 1
  0047    | GetLocalMove 7
  0049    | InsertAtIndex 2
  0051    | End
  ========================================
  
  ================1:tuple=================
  tuple(elem, N) = tuple1(elem) * N
  ========================================
  0000    | PushNull
  0001    | GetLocalMove 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 27
  0007    | Swap
  0008    | GetConstant 0: tuple1
  0010    | GetLocal 0
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
  0002    | GetLocal 0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 50
  0009    | PushNull
  0010    | GetLocalMove 2
  0012    | JumpIfFailure 12 -> 18
  0015    | PushNegInteger -1
  0017    | Merge
  0018    | ValidateRepeatPattern
  0019    | JumpIfZero 19 -> 48
  0022    | Swap
  0023    | GetConstant 0: tuple1
  0025    | GetConstant 15: @fn4
  0027    | CreateClosure 2
  0029    | CaptureLocal 1
  0031    | CaptureLocal 0
  0033    | CallFunction 1
  0035    | Merge
  0036    | JumpIfFailure 36 -> 47
  0039    | Swap
  0040    | Decrement
  0041    | JumpIfZero 41 -> 48
  0044    | JumpBack 44 -> 22
  0047    | Swap
  0048    | Drop
  0049    | Merge
  0050    | End
  ========================================
  
  =================1:rows=================
  rows(elem, col_sep, row_sep) =
    tuple1(array_sep(elem, col_sep)) +
    (tuple1(row_sep > array_sep(elem, col_sep)) * 0..)
  ========================================
  0000    | GetConstant 0: tuple1
  0002    | GetConstant 16: @fn5
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
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
  0029    | CaptureLocal 2
  0031    | CaptureLocal 0
  0033    | CaptureLocal 1
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
  0057    | CaptureLocal 2
  0059    | CaptureLocal 0
  0061    | CaptureLocal 1
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
  0007    | GetConstant 5: peek
  0009    | GetConstant 18: @fn7
  0011    | CreateClosure 3
  0013    | CaptureLocal 0
  0015    | CaptureLocal 1
  0017    | CaptureLocal 2
  0019    | CallFunction 1
  0021    | DestructurePlan 11: [bind MaxRowLen, _]
  0023    | TakeRight 23 -> 30
  0026    | CallFunctionLocal 0
  0028    | DestructurePlan 12: bind First
  0030    | TakeRight 30 -> 56
  0033    | GetConstant 19: _rows_padded
  0035    | GetLocalMove 0
  0037    | GetLocalMove 1
  0039    | GetLocalMove 2
  0041    | GetLocalMove 3
  0043    | PushInteger 1
  0045    | GetLocalMove 4
  0047    | GetConstantMutable 20: [_]
  0049    | GetLocalMove 6
  0051    | InsertAtIndex 0
  0053    | PushEmptyArray
  0054    | CallTailFunction 8
  0056    | End
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
  0006    | CallFunctionLocal 1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 0
  0013    | DestructurePlan 13: bind Elem
  0015    | ConditionalThen 15 -> 60
  0018    | GetConstant 19: _rows_padded
  0020    | GetLocalMove 0
  0022    | GetLocalMove 1
  0024    | GetLocalMove 2
  0026    | GetLocalMove 3
  0028    | GetConstant 23: Num.Inc
  0030    | GetLocalMove 4
  0032    | CallFunction 1
  0034    | GetLocalMove 5
  0036    | PushEmptyArray
  0037    | JumpIfFailure 37 -> 43
  0040    | GetLocalMove 6
  0042    | Merge
  0043    | JumpIfFailure 43 -> 53
  0046    | GetConstantMutable 27: [_]
  0048    | GetLocalMove 8
  0050    | InsertAtIndex 0
  0052    | Merge
  0053    | GetLocalMove 7
  0055    | CallTailFunction 8
  0057    | Jump 57 -> 166
  0060    | SetInputMark
  0061    | CallFunctionLocal 2
  0063    | TakeRight 63 -> 68
  0066    | CallFunctionLocal 0
  0068    | DestructurePlan 14: bind NextRow
  0070    | ConditionalThen 70 -> 130
  0073    | GetConstant 19: _rows_padded
  0075    | GetLocalMove 0
  0077    | GetLocalMove 1
  0079    | GetLocalMove 2
  0081    | GetLocal 3
  0083    | PushInteger 1
  0085    | GetLocal 5
  0087    | GetConstantMutable 28: [_]
  0089    | GetLocalMove 9
  0091    | InsertAtIndex 0
  0093    | PushEmptyArray
  0094    | JumpIfFailure 94 -> 100
  0097    | GetLocalMove 7
  0099    | Merge
  0100    | JumpIfFailure 100 -> 125
  0103    | GetConstantMutable 29: [_]
  0105    | GetConstant 30: Array.AppendN
  0107    | GetLocalMove 6
  0109    | GetLocalMove 3
  0111    | GetLocalMove 5
  0113    | JumpIfFailure 113 -> 120
  0116    | GetLocalMove 4
  0118    | NegateNumber
  0119    | Merge
  0120    | CallFunction 3
  0122    | InsertAtIndex 0
  0124    | Merge
  0125    | CallTailFunction 8
  0127    | Jump 127 -> 166
  0130    | GetConstant 25: const
  0132    | PushEmptyArray
  0133    | JumpIfFailure 133 -> 139
  0136    | GetLocalMove 7
  0138    | Merge
  0139    | JumpIfFailure 139 -> 164
  0142    | GetConstantMutable 31: [_]
  0144    | GetConstant 30: Array.AppendN
  0146    | GetLocalMove 6
  0148    | GetLocalMove 3
  0150    | GetLocalMove 5
  0152    | JumpIfFailure 152 -> 159
  0155    | GetLocalMove 4
  0157    | NegateNumber
  0158    | Merge
  0159    | CallFunction 3
  0161    | InsertAtIndex 0
  0163    | Merge
  0164    | CallTailFunction 1
  0166    | End
  ========================================
  
  =============1:_dimensions==============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 21
  0005    | GetConstant 22: __dimensions
  0007    | GetLocalMove 0
  0009    | GetLocalMove 1
  0011    | GetLocalMove 2
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
  0001    | CallFunctionLocal 1
  0003    | TakeRight 3 -> 8
  0006    | CallFunctionLocal 0
  0008    | ConditionalThen 8 -> 34
  0011    | GetConstant 22: __dimensions
  0013    | GetLocalMove 0
  0015    | GetLocalMove 1
  0017    | GetLocalMove 2
  0019    | GetConstant 23: Num.Inc
  0021    | GetLocalMove 3
  0023    | CallFunction 1
  0025    | GetLocalMove 4
  0027    | GetLocalMove 5
  0029    | CallTailFunction 6
  0031    | Jump 31 -> 94
  0034    | SetInputMark
  0035    | CallFunctionLocal 2
  0037    | TakeRight 37 -> 42
  0040    | CallFunctionLocal 0
  0042    | ConditionalThen 42 -> 74
  0045    | GetConstant 22: __dimensions
  0047    | GetLocalMove 0
  0049    | GetLocalMove 1
  0051    | GetLocalMove 2
  0053    | PushInteger 1
  0055    | GetConstant 23: Num.Inc
  0057    | GetLocalMove 4
  0059    | CallFunction 1
  0061    | GetConstant 24: Num.Max
  0063    | GetLocalMove 3
  0065    | GetLocalMove 5
  0067    | CallFunction 2
  0069    | CallTailFunction 6
  0071    | Jump 71 -> 94
  0074    | GetConstant 25: const
  0076    | GetConstantMutable 26: [_, _]
  0078    | GetConstant 24: Num.Max
  0080    | GetLocalMove 3
  0082    | GetLocalMove 5
  0084    | CallFunction 2
  0086    | InsertAtIndex 0
  0088    | GetLocalMove 4
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
  0005    | GetLocalMove 0
  0007    | GetLocalMove 1
  0009    | GetLocalMove 2
  0011    | CallFunction 3
  0013    | DestructurePlan 15: bind Rows
  0015    | TakeRight 15 -> 24
  0018    | GetConstant 33: Table.Transpose
  0020    | GetLocalMove 3
  0022    | CallTailFunction 1
  0024    | End
  ========================================
  
  ===============1:columns================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 32: rows
  0005    | GetLocalMove 0
  0007    | GetLocalMove 1
  0009    | GetLocalMove 2
  0011    | CallFunction 3
  0013    | DestructurePlan 15: bind Rows
  0015    | TakeRight 15 -> 24
  0018    | GetConstant 33: Table.Transpose
  0020    | GetLocalMove 3
  0022    | CallTailFunction 1
  0024    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 34: rows_padded
  0005    | GetLocalMove 0
  0007    | GetLocalMove 1
  0009    | GetLocalMove 2
  0011    | GetLocalMove 3
  0013    | CallFunction 4
  0015    | DestructurePlan 16: bind Rows
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 33: Table.Transpose
  0022    | GetLocalMove 4
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 34: rows_padded
  0005    | GetLocalMove 0
  0007    | GetLocalMove 1
  0009    | GetLocalMove 2
  0011    | GetLocalMove 3
  0013    | CallFunction 4
  0015    | DestructurePlan 16: bind Rows
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 33: Table.Transpose
  0022    | GetLocalMove 4
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  =================1:@fn0=================
  sep > elem
  ========================================
  0000    | PushVar sep
  0002    | PushVar elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  =================1:@fn1=================
  tuple1(elem)
  ========================================
  0000    | PushVar elem
  0002    | SetClosureCaptures
  0003    | GetConstant 0: tuple1
  0005    | GetLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================1:@fn2=================
  array(elem)
  ========================================
  0000    | PushVar elem
  0002    | SetClosureCaptures
  0003    | GetConstant 8: array
  0005    | GetLocalMove 0
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
  0007    | GetLocalMove 0
  0009    | GetLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================1:@fn4=================
  sep > elem
  ========================================
  0000    | PushVar sep
  0002    | PushVar elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  =================1:@fn5=================
  array_sep(elem, col_sep)
  ========================================
  0000    | PushVar elem
  0002    | PushVar col_sep
  0004    | SetClosureCaptures
  0005    | GetConstant 10: array_sep
  0007    | GetLocalMove 0
  0009    | GetLocalMove 1
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
  0007    | CallFunctionLocal 0
  0009    | TakeRight 9 -> 20
  0012    | GetConstant 10: array_sep
  0014    | GetLocalMove 1
  0016    | GetLocalMove 2
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
  0007    | GetConstant 21: _dimensions
  0009    | GetLocalMove 0
  0011    | GetLocalMove 1
  0013    | GetLocalMove 2
  0015    | CallTailFunction 3
  0017    | End
  ========================================
  
  =================2:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | CallFunctionConstant 1: @input.offset
  0004    | DestructurePlan 0: bind Pos
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 2: @at
  0011    | GetLocalMove 1
  0013    | GetLocalMove 0
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ================2:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 0: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  ===============2:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 12
  0006    | GetConstant 3: const
  0008    | GetLocalMove 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================2:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
  0002    | End
  ========================================
  
  ===============9:Num.Inc================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant 0: @Add
  0002    | GetLocalMove 0
  0004    | PushInteger 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============9:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | DestructurePlan 0: B..
  0005    | ConditionalThen 5 -> 13
  0008    | GetLocalMove 0
  0010    | Jump 10 -> 15
  0013    | GetLocalMove 1
  0015    | End
  ========================================
  
  ============10:Array.AppendN============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetLocalMove 0
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstantMutable 0: [_]
  0007    | GetLocalMove 1
  0009    | InsertAtIndex 0
  0011    | GetLocalMove 2
  0013    | RepeatValue
  0014    | Merge
  0015    | End
  ========================================
  
  ===========10:Table.Transpose===========
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant 1: _Table.Transpose
  0002    | GetLocalMove 0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ==========10:_Table.Transpose===========
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
  0009    | GetLocal 0
  0011    | CallFunction 1
  0013    | DestructurePlan 0: bind FirstPerRow
  0015    | TakeRight 15 -> 26
  0018    | GetConstant 3: _Table.RestPerRow
  0020    | GetLocalMove 0
  0022    | CallFunction 1
  0024    | DestructurePlan 1: bind RestPerRow
  0026    | ConditionalThen 26 -> 55
  0029    | GetConstant 1: _Table.Transpose
  0031    | GetLocalMove 3
  0033    | PushEmptyArray
  0034    | JumpIfFailure 34 -> 40
  0037    | GetLocalMove 1
  0039    | Merge
  0040    | JumpIfFailure 40 -> 50
  0043    | GetConstantMutable 4: [_]
  0045    | GetLocalMove 2
  0047    | InsertAtIndex 0
  0049    | Merge
  0050    | CallTailFunction 2
  0052    | Jump 52 -> 57
  0055    | GetLocalMove 1
  0057    | End
  ========================================
  
  =========10:_Table.FirstPerRow==========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | PushVar2 VeryFirst
  0009    | PushUnderscoreVar
  0010    | GetLocalMove 0
  0012    | DestructurePlan 2: ([bind Row] + bind Rest)
  0014    | TakeRight 14 -> 21
  0017    | GetLocalMove 1
  0019    | DestructurePlan 3: ([bind VeryFirst] + _)
  0021    | TakeRight 21 -> 36
  0024    | GetConstant 5: __Table.FirstPerRow
  0026    | GetLocalMove 2
  0028    | GetConstantMutable 6: [_]
  0030    | GetLocalMove 3
  0032    | InsertAtIndex 0
  0034    | CallTailFunction 2
  0036    | End
  ========================================
  
  =========10:__Table.FirstPerRow=========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | PushVar2 First
  0009    | PushUnderscoreVar
  0010    | SetInputMark
  0011    | GetLocalMove 0
  0013    | DestructurePlan 4: ([bind Row] + bind Rest)
  0015    | TakeRight 15 -> 22
  0018    | GetLocalMove 2
  0020    | DestructurePlan 5: ([bind First] + _)
  0022    | ConditionalThen 22 -> 51
  0025    | GetConstant 5: __Table.FirstPerRow
  0027    | GetLocalMove 3
  0029    | PushEmptyArray
  0030    | JumpIfFailure 30 -> 36
  0033    | GetLocalMove 1
  0035    | Merge
  0036    | JumpIfFailure 36 -> 46
  0039    | GetConstantMutable 7: [_]
  0041    | GetLocalMove 4
  0043    | InsertAtIndex 0
  0045    | Merge
  0046    | CallTailFunction 2
  0048    | Jump 48 -> 53
  0051    | GetLocalMove 1
  0053    | End
  ========================================
  
  ==========10:_Table.RestPerRow==========
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant 8: __Table.RestPerRow
  0002    | GetLocalMove 0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  =========10:__Table.RestPerRow==========
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
  0010    | SetInputMark
  0011    | GetLocalMove 0
  0013    | DestructurePlan 6: ([bind Row] + bind Rest)
  0015    | ConditionalThen 15 -> 74
  0018    | SetInputMark
  0019    | GetLocalMove 2
  0021    | DestructurePlan 7: ([_] + bind RowRest)
  0023    | ConditionalThen 23 -> 52
  0026    | GetConstant 8: __Table.RestPerRow
  0028    | GetLocalMove 3
  0030    | PushEmptyArray
  0031    | JumpIfFailure 31 -> 37
  0034    | GetLocalMove 1
  0036    | Merge
  0037    | JumpIfFailure 37 -> 47
  0040    | GetConstantMutable 9: [_]
  0042    | GetLocalMove 5
  0044    | InsertAtIndex 0
  0046    | Merge
  0047    | CallTailFunction 2
  0049    | Jump 49 -> 71
  0052    | GetConstant 8: __Table.RestPerRow
  0054    | GetLocalMove 3
  0056    | PushEmptyArray
  0057    | JumpIfFailure 57 -> 63
  0060    | GetLocalMove 1
  0062    | Merge
  0063    | JumpIfFailure 63 -> 69
  0066    | GetConstant 10: [[]]
  0068    | Merge
  0069    | CallTailFunction 2
  0071    | Jump 71 -> 76
  0074    | GetLocalMove 1
  0076    | End
  ========================================
