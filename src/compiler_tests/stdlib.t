  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i '' --no-stdlib
  
  =================@fn37==================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | End
  ========================================
  
  ==========toml.number.infinity==========
  toml.number.infinity = maybe("+" | "-") + "inf"
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: @fn37
  0004    | CallFunction 1
  0006    | CallFunctionConstant 2: "inf"
  0008    | Merge
  0009    | End
  ========================================
  
  =================maybe==================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 3: succeed
  0008    | End
  ========================================
  
  ================succeed=================
  succeed = const($null)
  ========================================
  0000    | GetConstant 4: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocal 0
  0002    | End
  ========================================
  
  ==========Num.FromBinaryDigits==========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | GetConstant 5: Len
  0002    | GetConstant 6: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 0: Len
  0010    | TakeRight 10 -> 24
  0013    | GetConstant 7: _Num.FromBinaryDigits
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | PushNumberNegOne
  0020    | Merge
  0021    | PushNumberZero
  0022    | CallTailFunction 3
  0024    | End
  ========================================
  
  ==============Array.Length==============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar L
  0003    | GetBoundLocal 0
  0005    | Destructure 1: ([_] * L)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocal 2
  0012    | End
  ========================================
  
  =========_Num.FromBinaryDigits==========
  _Num.FromBinaryDigits(Bs, Pos, Acc) =
    Bs -> [B, ...Rest] ? (
      B -> 0..1 &
      _Num.FromBinaryDigits(
        Rest,
        Pos - 1,
        Acc + Num.Mul(B, Num.Pow(2, Pos)),
      )
    ) :
    Acc
  ========================================
  0000    | PushCharVar B
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 2: ([B] + Rest)
  0009    | ConditionalThen 9 -> 48
  0012    | GetBoundLocal 3
  0014    | Destructure 3: 0..1
  0016    | TakeRight 16 -> 45
  0019    | GetConstant 7: _Num.FromBinaryDigits
  0021    | GetBoundLocal 4
  0023    | GetBoundLocal 1
  0025    | PushNumberNegOne
  0026    | Merge
  0027    | GetBoundLocal 2
  0029    | GetConstant 9: @Multiply
  0031    | GetBoundLocal 3
  0033    | GetConstant 10: @Power
  0035    | PushNumberTwo
  0036    | GetBoundLocal 1
  0038    | CallFunction 2
  0040    | CallFunction 2
  0042    | Merge
  0043    | CallTailFunction 3
  0045    | Jump 45 -> 50
  0048    | GetBoundLocal 2
  0050    | End
  ========================================
  
  ============_Toml.Doc.Value=============
  _Toml.Doc.Value(Doc) = Obj.Get(Doc, "value")
  ========================================
  0000    | GetConstant 11: Obj.Get
  0002    | GetBoundLocal 0
  0004    | GetConstant 12: "value"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushCharVar V
  0002    | PushUnderscoreVar
  0003    | GetBoundLocal 0
  0005    | Destructure 4: ({K: V} + _)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocal 2
  0012    | End
  ========================================
  
  ================Obj.Put=================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | GetBoundLocal 0
  0003    | Merge
  0004    | GetConstant 13: {_0_}
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | InsertKeyVal 0
  0012    | Merge
  0013    | End
  ========================================
  
  ==============Is.LessThan===============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 5: B
  0005    | ConditionalThen 5 -> 13
  0008    | CallTailFunctionConstant 14: @Fail
  0010    | Jump 10 -> 17
  0013    | GetBoundLocal 0
  0015    | Destructure 6: ..B
  0017    | End
  ========================================
  
  ===============_Array.Map===============
  _Array.Map(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.Map(Rest, Fn, [...Acc, Fn(First)]) : Acc
  ========================================
  0000    | GetConstant 15: First
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 7: ([First] + Rest)
  0009    | ConditionalThen 9 -> 38
  0012    | GetConstant 16: _Array.Map
  0014    | GetBoundLocal 4
  0016    | GetBoundLocal 1
  0018    | PushEmptyArray
  0019    | GetBoundLocal 2
  0021    | Merge
  0022    | GetConstant 17: [_]
  0024    | GetBoundLocal 1
  0026    | GetBoundLocal 3
  0028    | CallFunction 1
  0030    | InsertAtIndex 0
  0032    | Merge
  0033    | CallTailFunction 3
  0035    | Jump 35 -> 40
  0038    | GetBoundLocal 2
  0040    | End
  ========================================
  
  =================tuple3=================
  tuple3(elem1, elem2, elem3) =
    elem1 -> E1 &
    elem2 -> E2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | GetConstant 18: E1
  0002    | GetConstant 19: E2
  0004    | GetConstant 20: E3
  0006    | CallFunctionLocal 0
  0008    | Destructure 8: E1
  0010    | TakeRight 10 -> 17
  0013    | CallFunctionLocal 1
  0015    | Destructure 9: E2
  0017    | TakeRight 17 -> 41
  0020    | CallFunctionLocal 2
  0022    | Destructure 10: E3
  0024    | TakeRight 24 -> 41
  0027    | GetConstant 21: [_, _, _]
  0029    | GetBoundLocal 3
  0031    | InsertAtIndex 0
  0033    | GetBoundLocal 4
  0035    | InsertAtIndex 1
  0037    | GetBoundLocal 5
  0039    | InsertAtIndex 2
  0041    | End
  ========================================
  
  ================pair_sep================
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 11: K
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 1
  0013    | TakeRight 13 -> 31
  0016    | CallFunctionLocal 2
  0018    | Destructure 12: V
  0020    | TakeRight 20 -> 31
  0023    | GetConstant 22: {_0_}
  0025    | GetBoundLocal 3
  0027    | GetBoundLocal 4
  0029    | InsertKeyVal 0
  0031    | End
  ========================================
  
  =============octal_numeral==============
  octal_numeral = "0".."7"
  ========================================
  0000    | ParseCodepointRange '0'..'7'
  0003    | End
  ========================================
  
  ==========_toml.datetime.mday===========
  _toml.datetime.mday = ("0".."2" + "1".."9") | "30" | "31"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'2'
  0004    | ParseCodepointRange '1'..'9'
  0007    | Merge
  0008    | Or 8 -> 19
  0011    | SetInputMark
  0012    | CallFunctionConstant 23: "30"
  0014    | Or 14 -> 19
  0017    | CallTailFunctionConstant 24: "31"
  0019    | End
  ========================================
  
  =============_toml.comments=============
  _toml.comments = many_sep(_toml.comment, ws)
  ========================================
  0000    | GetConstant 25: many_sep
  0002    | GetConstant 26: _toml.comment
  0004    | GetConstant 27: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================many_sep================
  many_sep(p, sep) = p + ((sep > p) * 0..)
  ========================================
  0000    | CallFunctionLocal 0
  0002    | PushNull
  0003    | PushNumberZero
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 28
  0008    | Swap
  0009    | CallFunctionLocal 1
  0011    | TakeRight 11 -> 16
  0014    | CallFunctionLocal 0
  0016    | Merge
  0017    | JumpIfFailure 17 -> 47
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 8
  0028    | Swap
  0029    | SetInputMark
  0030    | CallFunctionLocal 1
  0032    | TakeRight 32 -> 37
  0035    | CallFunctionLocal 0
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 29
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | Merge
  0050    | End
  ========================================
  
  =============_toml.comment==============
  _toml.comment = "#" > maybe(line)
  ========================================
  0000    | ParseChar '#'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 0: maybe
  0007    | GetConstant 28: line
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  =================@fn62==================
  newline | end_of_input
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 31: newline
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 32: end_of_input
  0008    | End
  ========================================
  
  ==================line==================
  line = chars_until(newline | end_of_input)
  ========================================
  0000    | GetConstant 29: chars_until
  0002    | GetConstant 30: @fn62
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============chars_until===============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 33: many_until
  0002    | GetConstant 34: char
  0004    | GetBoundLocal 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============many_until===============
  many_until(p, stop) = unless(p, stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 35: unless
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallFunction 2
  0015    | Merge
  0016    | JumpIfFailure 16 -> 47
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 6
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 35: unless
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 45
  0040    | PopInputMark
  0041    | Merge
  0042    | JumpBack 42 -> 28
  0045    | ResetInput
  0046    | Drop
  0047    | Swap
  0048    | Drop
  0049    | JumpIfFailure 49 -> 59
  0052    | GetConstant 36: peek
  0054    | GetBoundLocal 1
  0056    | CallFunction 1
  0058    | TakeLeft
  0059    | End
  ========================================
  
  =================unless=================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 37: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  ==================peek==================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | GetConstant 38: Pos
  0002    | CallFunctionConstant 39: @input.offset
  0004    | Destructure 13: Pos
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 40: @at
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 0
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  ================newline=================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 41: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 42: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 43: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 44: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  ==============end_of_input==============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 34: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 37: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 3: succeed
  0013    | End
  ========================================
  
  =================@fn70==================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 47: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 31: newline
  0008    | End
  ========================================
  
  ===============whitespace===============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant 46: @fn70
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================many==================
  many(p) = p * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | CallFunctionLocal 0
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 21
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | SetInputMark
  0023    | CallFunctionLocal 0
  0025    | JumpIfFailure 25 -> 33
  0028    | PopInputMark
  0029    | Merge
  0030    | JumpBack 30 -> 22
  0033    | ResetInput
  0034    | Drop
  0035    | Swap
  0036    | Drop
  0037    | End
  ========================================
  
  =================space==================
  space =
    " " | "\t" | "\u0000A0" | "\u002000".."\u00200A" | "\u00202F" | "\u00205F" | "\u003000"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar ' '
  0003    | Or 3 -> 41
  0006    | SetInputMark
  0007    | ParseChar '\t' (esc)
  0009    | Or 9 -> 41
  0012    | SetInputMark
  0013    | CallFunctionConstant 48: "\xc2\xa0" (esc)
  0015    | Or 15 -> 41
  0018    | SetInputMark
  0019    | GetConstant 49: "\xe2\x80\x80" (esc)
  0021    | GetConstant 50: "\xe2\x80\x8a" (esc)
  0023    | ParseRange
  0024    | Or 24 -> 41
  0027    | SetInputMark
  0028    | CallFunctionConstant 51: "\xe2\x80\xaf" (esc)
  0030    | Or 30 -> 41
  0033    | SetInputMark
  0034    | CallFunctionConstant 52: "\xe2\x81\x9f" (esc)
  0036    | Or 36 -> 41
  0039    | CallTailFunctionConstant 53: "\xe3\x80\x80" (esc)
  0041    | End
  ========================================
  
  =================@fn74==================
  array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 56: elem
  0002    | GetConstant 57: col_sep
  0004    | SetClosureCaptures
  0005    | GetConstant 58: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn76==================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 60: row_sep
  0002    | GetConstant 56: elem
  0004    | GetConstant 57: col_sep
  0006    | SetClosureCaptures
  0007    | CallFunctionLocal 0
  0009    | TakeRight 9 -> 20
  0012    | GetConstant 58: array_sep
  0014    | GetBoundLocal 1
  0016    | GetBoundLocal 2
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  =================@fn77==================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 60: row_sep
  0002    | GetConstant 56: elem
  0004    | GetConstant 57: col_sep
  0006    | SetClosureCaptures
  0007    | CallFunctionLocal 0
  0009    | TakeRight 9 -> 20
  0012    | GetConstant 58: array_sep
  0014    | GetBoundLocal 1
  0016    | GetBoundLocal 2
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ==================rows==================
  rows(elem, col_sep, row_sep) =
    tuple1(array_sep(elem, col_sep)) +
    (tuple1(row_sep > array_sep(elem, col_sep)) * 0..)
  ========================================
  0000    | GetConstant 54: tuple1
  0002    | GetConstant 55: @fn74
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | PushNull
  0013    | PushNumberZero
  0014    | ValidateRepeatPattern
  0015    | JumpIfZero 15 -> 45
  0018    | Swap
  0019    | GetConstant 54: tuple1
  0021    | GetConstant 59: @fn76
  0023    | CreateClosure 3
  0025    | CaptureLocal 2
  0027    | CaptureLocal 0
  0029    | CaptureLocal 1
  0031    | CallFunction 1
  0033    | Merge
  0034    | JumpIfFailure 34 -> 71
  0037    | Swap
  0038    | Decrement
  0039    | JumpIfZero 39 -> 45
  0042    | JumpBack 42 -> 18
  0045    | Swap
  0046    | SetInputMark
  0047    | GetConstant 54: tuple1
  0049    | GetConstant 61: @fn77
  0051    | CreateClosure 3
  0053    | CaptureLocal 2
  0055    | CaptureLocal 0
  0057    | CaptureLocal 1
  0059    | CallFunction 1
  0061    | JumpIfFailure 61 -> 69
  0064    | PopInputMark
  0065    | Merge
  0066    | JumpBack 66 -> 46
  0069    | ResetInput
  0070    | Drop
  0071    | Swap
  0072    | Drop
  0073    | Merge
  0074    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 62: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 14: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstant 63: [_]
  0011    | GetBoundLocal 1
  0013    | InsertAtIndex 0
  0015    | End
  ========================================
  
  =================@fn79==================
  sep > elem
  ========================================
  0000    | GetConstant 65: sep
  0002    | GetConstant 56: elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  =================@fn80==================
  sep > elem
  ========================================
  0000    | GetConstant 65: sep
  0002    | GetConstant 56: elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  ===============array_sep================
  array_sep(elem, sep) = tuple1(elem) + (tuple1(sep > elem) * 0..)
  ========================================
  0000    | GetConstant 54: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | PushNull
  0007    | PushNumberZero
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 37
  0012    | Swap
  0013    | GetConstant 54: tuple1
  0015    | GetConstant 64: @fn79
  0017    | CreateClosure 2
  0019    | CaptureLocal 1
  0021    | CaptureLocal 0
  0023    | CallFunction 1
  0025    | Merge
  0026    | JumpIfFailure 26 -> 61
  0029    | Swap
  0030    | Decrement
  0031    | JumpIfZero 31 -> 37
  0034    | JumpBack 34 -> 12
  0037    | Swap
  0038    | SetInputMark
  0039    | GetConstant 54: tuple1
  0041    | GetConstant 66: @fn80
  0043    | CreateClosure 2
  0045    | CaptureLocal 1
  0047    | CaptureLocal 0
  0049    | CallFunction 1
  0051    | JumpIfFailure 51 -> 59
  0054    | PopInputMark
  0055    | Merge
  0056    | JumpBack 56 -> 38
  0059    | ResetInput
  0060    | Drop
  0061    | Swap
  0062    | Drop
  0063    | Merge
  0064    | End
  ========================================
  
  =========_toml.with_root_table==========
  _toml.with_root_table(value) =
    _toml.root_table(value, _Toml.Doc.Empty) -> RootDoc &
    (_toml.ws > _toml.tables(value, RootDoc)) | const(RootDoc)
  ========================================
  0000    | GetConstant 67: RootDoc
  0002    | GetConstant 68: _toml.root_table
  0004    | GetBoundLocal 0
  0006    | CallFunctionConstant 69: _Toml.Doc.Empty
  0008    | CallFunction 2
  0010    | Destructure 15: RootDoc
  0012    | TakeRight 12 -> 38
  0015    | SetInputMark
  0016    | CallFunctionConstant 70: _toml.ws
  0018    | TakeRight 18 -> 29
  0021    | GetConstant 71: _toml.tables
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | CallFunction 2
  0029    | Or 29 -> 38
  0032    | GetConstant 4: const
  0034    | GetBoundLocal 1
  0036    | CallTailFunction 1
  0038    | End
  ========================================
  
  ============_toml.root_table============
  _toml.root_table(value, Doc) =
    _toml.table_body(value, [], Doc)
  ========================================
  0000    | GetConstant 72: _toml.table_body
  0002    | GetBoundLocal 0
  0004    | PushEmptyArray
  0005    | GetBoundLocal 1
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ============_toml.table_body============
  _toml.table_body(value, HeaderPath, Doc) =
    _toml.table_pair(value) -> [KeyPath, Val] & _toml.ws_newline &
    const(_Toml.Doc.InsertAtPath(Doc, HeaderPath + KeyPath, Val)) -> NewDoc &
    _toml.table_body(value, HeaderPath, NewDoc) | const(NewDoc)
  ========================================
  0000    | GetConstant 73: KeyPath
  0002    | GetConstant 74: Val
  0004    | GetConstant 75: NewDoc
  0006    | GetConstant 76: _toml.table_pair
  0008    | GetBoundLocal 0
  0010    | CallFunction 1
  0012    | Destructure 16: [KeyPath, Val]
  0014    | TakeRight 14 -> 19
  0017    | CallFunctionConstant 77: _toml.ws_newline
  0019    | TakeRight 19 -> 41
  0022    | GetConstant 4: const
  0024    | GetConstant 78: _Toml.Doc.InsertAtPath
  0026    | GetBoundLocal 2
  0028    | GetBoundLocal 1
  0030    | GetBoundLocal 3
  0032    | Merge
  0033    | GetBoundLocal 4
  0035    | CallFunction 3
  0037    | CallFunction 1
  0039    | Destructure 17: NewDoc
  0041    | TakeRight 41 -> 64
  0044    | SetInputMark
  0045    | GetConstant 72: _toml.table_body
  0047    | GetBoundLocal 0
  0049    | GetBoundLocal 1
  0051    | GetBoundLocal 5
  0053    | CallFunction 3
  0055    | Or 55 -> 64
  0058    | GetConstant 4: const
  0060    | GetBoundLocal 5
  0062    | CallTailFunction 1
  0064    | End
  ========================================
  
  =================@fn94==================
  maybe(spaces)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 84: spaces
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn92==================
  surround("=", maybe(spaces))
  ========================================
  0000    | GetConstant 82: surround
  0002    | PushChar '='
  0004    | GetConstant 83: @fn94
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_toml.table_pair============
  _toml.table_pair(value) =
    tuple2_sep(_toml.path, surround("=", maybe(spaces)), value)
  ========================================
  0000    | GetConstant 79: tuple2_sep
  0002    | GetConstant 80: _toml.path
  0004    | GetConstant 81: @fn92
  0006    | GetBoundLocal 0
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===============tuple2_sep===============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 18: E1
  0002    | GetConstant 19: E2
  0004    | CallFunctionLocal 0
  0006    | Destructure 18: E1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 1
  0013    | TakeRight 13 -> 33
  0016    | CallFunctionLocal 2
  0018    | Destructure 19: E2
  0020    | TakeRight 20 -> 33
  0023    | GetConstant 85: [_, _]
  0025    | GetBoundLocal 3
  0027    | InsertAtIndex 0
  0029    | GetBoundLocal 4
  0031    | InsertAtIndex 1
  0033    | End
  ========================================
  
  =================@fn99==================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn98==================
  surround(".", maybe(ws))
  ========================================
  0000    | GetConstant 82: surround
  0002    | PushChar '.'
  0004    | GetConstant 88: @fn99
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============_toml.path===============
  _toml.path = array_sep(_toml.key, surround(".", maybe(ws)))
  ========================================
  0000    | GetConstant 58: array_sep
  0002    | GetConstant 86: _toml.key
  0004    | GetConstant 87: @fn98
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn102=================
  alpha | numeral | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 90: alpha
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 91: numeral
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | ParseChar '_'
  0015    | Or 15 -> 20
  0018    | ParseChar '-'
  0020    | End
  ========================================
  
  ===============_toml.key================
  _toml.key =
    many(alpha | numeral | "_" | "-") |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 45: many
  0003    | GetConstant 89: @fn102
  0005    | CallFunction 1
  0007    | Or 7 -> 18
  0010    | SetInputMark
  0011    | CallFunctionConstant 92: toml.string.basic
  0013    | Or 13 -> 18
  0016    | CallTailFunctionConstant 93: toml.string.literal
  0018    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ===========toml.string.basic============
  toml.string.basic = '"' > _toml.string.basic_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 94: _toml.string.basic_body
  0007    | JumpIfFailure 7 -> 13
  0010    | ParseChar '"'
  0012    | TakeLeft
  0013    | End
  ========================================
  
  =================@fn109=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 99: _ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  =================@fn106=================
  _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 96: _toml.escaped_ctrl_char
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 97: _toml.escaped_unicode
  0009    | Or 9 -> 20
  0012    | GetConstant 35: unless
  0014    | GetConstant 34: char
  0016    | GetConstant 98: @fn109
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ========_toml.string.basic_body=========
  _toml.string.basic_body =
    many(
      _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
    ) | const($"")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 45: many
  0003    | GetConstant 95: @fn106
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 4: const
  0012    | PushEmptyString
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  ========_toml.escaped_ctrl_char=========
  _toml.escaped_ctrl_char =
    (`\"` $ `"`) |
    (`\\` $ `\`) |
    (`\b` $ "\b") |
    (`\f` $ "\f") |
    (`\n` $ "\n") |
    (`\r` $ "\r") |
    (`\t` $ "\t")
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 100: "\""
  0003    | TakeRight 3 -> 8
  0006    | PushChar '"'
  0008    | Or 8 -> 73
  0011    | SetInputMark
  0012    | CallFunctionConstant 101: "\\"
  0014    | TakeRight 14 -> 19
  0017    | PushChar '\'
  0019    | Or 19 -> 73
  0022    | SetInputMark
  0023    | CallFunctionConstant 102: "\b"
  0025    | TakeRight 25 -> 30
  0028    | PushChar '\x08' (esc)
  0030    | Or 30 -> 73
  0033    | SetInputMark
  0034    | CallFunctionConstant 103: "\f"
  0036    | TakeRight 36 -> 41
  0039    | PushChar '\x0c' (esc)
  0041    | Or 41 -> 73
  0044    | SetInputMark
  0045    | CallFunctionConstant 104: "\n"
  0047    | TakeRight 47 -> 52
  0050    | PushChar '
  '
  0052    | Or 52 -> 73
  0055    | SetInputMark
  0056    | CallFunctionConstant 105: "\r"
  0058    | TakeRight 58 -> 63
  0061    | PushChar '\r (no-eol) (esc)
  '
  0063    | Or 63 -> 73
  0066    | CallFunctionConstant 106: "\t"
  0068    | TakeRight 68 -> 73
  0071    | PushChar '\t' (esc)
  0073    | End
  ========================================
  
  =========_toml.escaped_unicode==========
  _toml.escaped_unicode =
    (`\u` > (hex_numeral * 4) -> U $ @Codepoint(U)) |
    (`\U` > (hex_numeral * 8) -> U $ @Codepoint(U))
  ========================================
  0000    | PushCharVar U
  0002    | SetInputMark
  0003    | CallFunctionConstant 107: "\u"
  0005    | TakeRight 5 -> 32
  0008    | PushNull
  0009    | PushNumber 4
  0011    | ValidateRepeatPattern
  0012    | JumpIfZero 12 -> 31
  0015    | Swap
  0016    | CallFunctionConstant 108: hex_numeral
  0018    | Merge
  0019    | JumpIfFailure 19 -> 30
  0022    | Swap
  0023    | Decrement
  0024    | JumpIfZero 24 -> 31
  0027    | JumpBack 27 -> 15
  0030    | Swap
  0031    | Drop
  0032    | Destructure 20: U
  0034    | TakeRight 34 -> 43
  0037    | GetConstant 109: @Codepoint
  0039    | GetBoundLocal 0
  0041    | CallFunction 1
  0043    | Or 43 -> 86
  0046    | CallFunctionConstant 110: "\U"
  0048    | TakeRight 48 -> 75
  0051    | PushNull
  0052    | PushNumber 8
  0054    | ValidateRepeatPattern
  0055    | JumpIfZero 55 -> 74
  0058    | Swap
  0059    | CallFunctionConstant 108: hex_numeral
  0061    | Merge
  0062    | JumpIfFailure 62 -> 73
  0065    | Swap
  0066    | Decrement
  0067    | JumpIfZero 67 -> 74
  0070    | JumpBack 70 -> 58
  0073    | Swap
  0074    | Drop
  0075    | Destructure 21: U
  0077    | TakeRight 77 -> 86
  0080    | GetConstant 109: @Codepoint
  0082    | GetBoundLocal 0
  0084    | CallTailFunction 1
  0086    | End
  ========================================
  
  ==============hex_numeral===============
  hex_numeral = numeral | "a".."f" | "A".."F"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 91: numeral
  0003    | Or 3 -> 16
  0006    | SetInputMark
  0007    | ParseCodepointRange 'a'..'f'
  0010    | Or 10 -> 16
  0013    | ParseCodepointRange 'A'..'F'
  0016    | End
  ========================================
  
  ===============_ctrl_char===============
  _ctrl_char = "\u000000".."\u00001F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x1f' (esc)
  0003    | End
  ========================================
  
  =================@fn113=================
  chars_until("'")
  ========================================
  0000    | GetConstant 29: chars_until
  0002    | PushChar '''
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========toml.string.literal===========
  toml.string.literal = "'" > default(chars_until("'"), $"") < "'"
  ========================================
  0000    | ParseChar '''
  0002    | TakeRight 2 -> 12
  0005    | GetConstant 111: default
  0007    | GetConstant 112: @fn113
  0009    | PushEmptyString
  0010    | CallFunction 2
  0012    | JumpIfFailure 12 -> 18
  0015    | ParseChar '''
  0017    | TakeLeft
  0018    | End
  ========================================
  
  ================default=================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 12
  0006    | GetConstant 4: const
  0008    | GetBoundLocal 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================surround================
  surround(p, fill) = fill > p < fill
  ========================================
  0000    | CallFunctionLocal 1
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionLocal 0
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionLocal 1
  0012    | TakeLeft
  0013    | End
  ========================================
  
  =================spaces=================
  spaces = many(space)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant 47: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ============_toml.ws_newline============
  _toml.ws_newline = _toml.ws_line + (nl | end) + _toml.ws
  ========================================
  0000    | CallFunctionConstant 113: _toml.ws_line
  0002    | SetInputMark
  0003    | CallFunctionConstant 31: newline
  0005    | Or 5 -> 10
  0008    | CallFunctionConstant 32: end_of_input
  0010    | Merge
  0011    | CallFunctionConstant 70: _toml.ws
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn116=================
  spaces | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 84: spaces
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 26: _toml.comment
  0008    | End
  ========================================
  
  =============_toml.ws_line==============
  _toml.ws_line = maybe_many(spaces | _toml.comment)
  ========================================
  0000    | GetConstant 114: maybe_many
  0002    | GetConstant 115: @fn116
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============maybe_many===============
  maybe_many(p) = p * 0..
  ========================================
  0000    | PushNull
  0001    | PushNumberZero
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 21
  0006    | Swap
  0007    | CallFunctionLocal 0
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | Swap
  0014    | Decrement
  0015    | JumpIfZero 15 -> 21
  0018    | JumpBack 18 -> 6
  0021    | Swap
  0022    | SetInputMark
  0023    | CallFunctionLocal 0
  0025    | JumpIfFailure 25 -> 33
  0028    | PopInputMark
  0029    | Merge
  0030    | JumpBack 30 -> 22
  0033    | ResetInput
  0034    | Drop
  0035    | Swap
  0036    | Drop
  0037    | End
  ========================================
  
  =================@fn117=================
  ws | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 27: whitespace
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 26: _toml.comment
  0008    | End
  ========================================
  
  ================_toml.ws================
  _toml.ws = maybe_many(ws | _toml.comment)
  ========================================
  0000    | GetConstant 114: maybe_many
  0002    | GetConstant 116: @fn117
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========_Toml.Doc.InsertAtPath=========
  _Toml.Doc.InsertAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.ValueUpdater)
  ========================================
  0000    | GetConstant 117: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetConstant 118: _Toml.Doc.ValueUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =========_Toml.Doc.UpdateAtPath=========
  _Toml.Doc.UpdateAtPath(Doc, Path, Val, Updater) =
    Path -> [Key] ? Updater(Doc, Key, Val) :
    Path -> [Key, ...PathRest] ? (
      (
        _Toml.Doc.Has(Doc, Key) ? (
          _Toml.Doc.IsTable(_Toml.Doc.Get(Doc, Key)) &
          _Toml.Doc.UpdateAtPath(_Toml.Doc.Get(Doc, Key), PathRest, Val, Updater)
        ) :
        _Toml.Doc.UpdateAtPath(_Toml.Doc.Empty, PathRest, Val, Updater)
      ) -> InnerDoc &
      _Toml.Doc.Insert(Doc, Key, _Toml.Doc.Value(InnerDoc), _Toml.Doc.Type(InnerDoc))
    ) :
    Doc
  ========================================
  0000    | GetConstant 119: Key
  0002    | GetConstant 120: PathRest
  0004    | GetConstant 121: InnerDoc
  0006    | SetInputMark
  0007    | GetBoundLocal 1
  0009    | Destructure 22: [Key]
  0011    | ConditionalThen 11 -> 27
  0014    | GetBoundLocal 3
  0016    | GetBoundLocal 0
  0018    | GetBoundLocal 4
  0020    | GetBoundLocal 2
  0022    | CallTailFunction 3
  0024    | Jump 24 -> 125
  0027    | SetInputMark
  0028    | GetBoundLocal 1
  0030    | Destructure 23: ([Key] + PathRest)
  0032    | ConditionalThen 32 -> 123
  0035    | SetInputMark
  0036    | GetConstant 122: _Toml.Doc.Has
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 4
  0042    | CallFunction 2
  0044    | ConditionalThen 44 -> 83
  0047    | GetConstant 123: _Toml.Doc.IsTable
  0049    | GetConstant 124: _Toml.Doc.Get
  0051    | GetBoundLocal 0
  0053    | GetBoundLocal 4
  0055    | CallFunction 2
  0057    | CallFunction 1
  0059    | TakeRight 59 -> 80
  0062    | GetConstant 117: _Toml.Doc.UpdateAtPath
  0064    | GetConstant 124: _Toml.Doc.Get
  0066    | GetBoundLocal 0
  0068    | GetBoundLocal 4
  0070    | CallFunction 2
  0072    | GetBoundLocal 5
  0074    | GetBoundLocal 2
  0076    | GetBoundLocal 3
  0078    | CallFunction 4
  0080    | Jump 80 -> 95
  0083    | GetConstant 117: _Toml.Doc.UpdateAtPath
  0085    | CallFunctionConstant 69: _Toml.Doc.Empty
  0087    | GetBoundLocal 5
  0089    | GetBoundLocal 2
  0091    | GetBoundLocal 3
  0093    | CallFunction 4
  0095    | Destructure 24: InnerDoc
  0097    | TakeRight 97 -> 120
  0100    | GetConstant 125: _Toml.Doc.Insert
  0102    | GetBoundLocal 0
  0104    | GetBoundLocal 4
  0106    | GetConstant 126: _Toml.Doc.Value
  0108    | GetBoundLocal 6
  0110    | CallFunction 1
  0112    | GetConstant 127: _Toml.Doc.Type
  0114    | GetBoundLocal 6
  0116    | CallFunction 1
  0118    | CallTailFunction 4
  0120    | Jump 120 -> 125
  0123    | GetBoundLocal 0
  0125    | End
  ========================================
  
  =============_Toml.Doc.Has==============
  _Toml.Doc.Has(Doc, Key) = Obj.Has(_Toml.Doc.Type(Doc), Key)
  ========================================
  0000    | GetConstant 128: Obj.Has
  0002    | GetConstant 127: _Toml.Doc.Type
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetBoundLocal 1
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ================Obj.Has=================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 25: ({K: _} + _)
  0005    | End
  ========================================
  
  =============_Toml.Doc.Type=============
  _Toml.Doc.Type(Doc) = Obj.Get(Doc, "type")
  ========================================
  0000    | GetConstant 11: Obj.Get
  0002    | GetBoundLocal 0
  0004    | GetConstant 129: "type"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===========_Toml.Doc.IsTable============
  _Toml.Doc.IsTable(Doc) = Is.Object(_Toml.Doc.Type(Doc))
  ========================================
  0000    | GetConstant 130: Is.Object
  0002    | GetConstant 127: _Toml.Doc.Type
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ===============Is.Object================
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 26: ({} + _)
  0005    | End
  ========================================
  
  =============_Toml.Doc.Get==============
  _Toml.Doc.Get(Doc, Key) = {
    "value": Obj.Get(_Toml.Doc.Value(Doc), Key),
    "type": Obj.Get(_Toml.Doc.Type(Doc), Key),
  }
  ========================================
  0000    | GetConstant 131: {_0_, _1_}
  0002    | GetConstant 12: "value"
  0004    | GetConstant 11: Obj.Get
  0006    | GetConstant 126: _Toml.Doc.Value
  0008    | GetBoundLocal 0
  0010    | CallFunction 1
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | InsertKeyVal 0
  0018    | GetConstant 129: "type"
  0020    | GetConstant 11: Obj.Get
  0022    | GetConstant 127: _Toml.Doc.Type
  0024    | GetBoundLocal 0
  0026    | CallFunction 1
  0028    | GetBoundLocal 1
  0030    | CallFunction 2
  0032    | InsertKeyVal 1
  0034    | End
  ========================================
  
  ============_Toml.Doc.Empty=============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant 132: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  ============_Toml.Doc.Insert============
  _Toml.Doc.Insert(Doc, Key, Val, Type) =
    _Toml.Doc.IsTable(Doc) &
    {
      "value": Obj.Put(_Toml.Doc.Value(Doc), Key, Val),
      "type": Obj.Put(_Toml.Doc.Type(Doc), Key, Type),
    }
  ========================================
  0000    | GetConstant 123: _Toml.Doc.IsTable
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 47
  0009    | GetConstant 133: {_0_, _1_}
  0011    | GetConstant 12: "value"
  0013    | GetConstant 134: Obj.Put
  0015    | GetConstant 126: _Toml.Doc.Value
  0017    | GetBoundLocal 0
  0019    | CallFunction 1
  0021    | GetBoundLocal 1
  0023    | GetBoundLocal 2
  0025    | CallFunction 3
  0027    | InsertKeyVal 0
  0029    | GetConstant 129: "type"
  0031    | GetConstant 134: Obj.Put
  0033    | GetConstant 127: _Toml.Doc.Type
  0035    | GetBoundLocal 0
  0037    | CallFunction 1
  0039    | GetBoundLocal 1
  0041    | GetBoundLocal 3
  0043    | CallFunction 3
  0045    | InsertKeyVal 1
  0047    | End
  ========================================
  
  =========_Toml.Doc.ValueUpdater=========
  _Toml.Doc.ValueUpdater(Doc, Key, Val) =
    _Toml.Doc.Has(Doc, Key) ? @Fail : _Toml.Doc.Insert(Doc, Key, Val, "value")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 122: _Toml.Doc.Has
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | ConditionalThen 9 -> 17
  0012    | CallTailFunctionConstant 14: @Fail
  0014    | Jump 14 -> 29
  0017    | GetConstant 125: _Toml.Doc.Insert
  0019    | GetBoundLocal 0
  0021    | GetBoundLocal 1
  0023    | GetBoundLocal 2
  0025    | GetConstant 12: "value"
  0027    | CallTailFunction 4
  0029    | End
  ========================================
  
  ==============_toml.tables==============
  _toml.tables(value, Doc) =
    _toml.ws >
    _toml.table(value, Doc) | _toml.array_of_tables(value, Doc) -> NewDoc ?
    _toml.tables(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant 75: NewDoc
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | CallFunctionConstant 70: _toml.ws
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 135: _toml.table
  0011    | GetBoundLocal 0
  0013    | GetBoundLocal 1
  0015    | CallFunction 2
  0017    | Or 17 -> 28
  0020    | GetConstant 136: _toml.array_of_tables
  0022    | GetBoundLocal 0
  0024    | GetBoundLocal 1
  0026    | CallFunction 2
  0028    | Destructure 27: NewDoc
  0030    | ConditionalThen 30 -> 44
  0033    | GetConstant 71: _toml.tables
  0035    | GetBoundLocal 0
  0037    | GetBoundLocal 2
  0039    | CallTailFunction 2
  0041    | Jump 41 -> 50
  0044    | GetConstant 4: const
  0046    | GetBoundLocal 1
  0048    | CallTailFunction 1
  0050    | End
  ========================================
  
  ==============_toml.table===============
  _toml.table(value, Doc) =
    _toml.table_header -> HeaderPath & _toml.ws_newline & (
      _toml.table_body(value, HeaderPath, Doc) |
      const(_Toml.Doc.EnsureTableAtPath(Doc, HeaderPath))
    )
  ========================================
  0000    | GetConstant 137: HeaderPath
  0002    | CallFunctionConstant 138: _toml.table_header
  0004    | Destructure 28: HeaderPath
  0006    | TakeRight 6 -> 11
  0009    | CallFunctionConstant 77: _toml.ws_newline
  0011    | TakeRight 11 -> 40
  0014    | SetInputMark
  0015    | GetConstant 72: _toml.table_body
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 2
  0021    | GetBoundLocal 1
  0023    | CallFunction 3
  0025    | Or 25 -> 40
  0028    | GetConstant 4: const
  0030    | GetConstant 139: _Toml.Doc.EnsureTableAtPath
  0032    | GetBoundLocal 1
  0034    | GetBoundLocal 2
  0036    | CallFunction 2
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  =================@fn136=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========_toml.table_header===========
  _toml.table_header = "[" > surround(_toml.path, maybe(ws)) < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 13
  0005    | GetConstant 82: surround
  0007    | GetConstant 80: _toml.path
  0009    | GetConstant 140: @fn136
  0011    | CallFunction 2
  0013    | JumpIfFailure 13 -> 19
  0016    | ParseChar ']'
  0018    | TakeLeft
  0019    | End
  ========================================
  
  ======_Toml.Doc.EnsureTableAtPath=======
  _Toml.Doc.EnsureTableAtPath(Doc, Path) =
    _Toml.Doc.UpdateAtPath(Doc, Path, {}, _Toml.Doc.MissingTableUpdater)
  ========================================
  0000    | GetConstant 117: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | PushEmptyObject
  0007    | GetConstant 141: _Toml.Doc.MissingTableUpdater
  0009    | CallTailFunction 4
  0011    | End
  ========================================
  
  =====_Toml.Doc.MissingTableUpdater======
  _Toml.Doc.MissingTableUpdater(Doc, Key, _Val) =
    _Toml.Doc.IsTable(_Toml.Doc.Get(Doc, Key)) ? Doc :
    _Toml.Doc.Insert(Doc, Key, {}, {})
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 123: _Toml.Doc.IsTable
  0003    | GetConstant 124: _Toml.Doc.Get
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | CallFunction 1
  0013    | ConditionalThen 13 -> 21
  0016    | GetBoundLocal 0
  0018    | Jump 18 -> 31
  0021    | GetConstant 125: _Toml.Doc.Insert
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | PushEmptyObject
  0028    | PushEmptyObject
  0029    | CallTailFunction 4
  0031    | End
  ========================================
  
  =================@fn140=================
  _toml.table_body(value, [], _Toml.Doc.Empty)
  ========================================
  0000    | GetConstant 144: value
  0002    | SetClosureCaptures
  0003    | GetConstant 72: _toml.table_body
  0005    | GetBoundLocal 0
  0007    | PushEmptyArray
  0008    | CallFunctionConstant 69: _Toml.Doc.Empty
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  =========_toml.array_of_tables==========
  _toml.array_of_tables(value, Doc) =
    _toml.array_of_tables_header -> HeaderPath & _toml.ws_newline &
    default(_toml.table_body(value, [], _Toml.Doc.Empty), _Toml.Doc.Empty) -> InnerDoc $
    _Toml.Doc.AppendAtPath(Doc, HeaderPath, _Toml.Doc.Value(InnerDoc))
  ========================================
  0000    | GetConstant 137: HeaderPath
  0002    | GetConstant 121: InnerDoc
  0004    | CallFunctionConstant 142: _toml.array_of_tables_header
  0006    | Destructure 29: HeaderPath
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionConstant 77: _toml.ws_newline
  0013    | TakeRight 13 -> 47
  0016    | GetConstant 111: default
  0018    | GetConstant 143: @fn140
  0020    | CreateClosure 1
  0022    | CaptureLocal 0
  0024    | CallFunctionConstant 69: _Toml.Doc.Empty
  0026    | CallFunction 2
  0028    | Destructure 30: InnerDoc
  0030    | TakeRight 30 -> 47
  0033    | GetConstant 145: _Toml.Doc.AppendAtPath
  0035    | GetBoundLocal 1
  0037    | GetBoundLocal 2
  0039    | GetConstant 126: _Toml.Doc.Value
  0041    | GetBoundLocal 3
  0043    | CallFunction 1
  0045    | CallTailFunction 3
  0047    | End
  ========================================
  
  =================@fn141=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ======_toml.array_of_tables_header======
  _toml.array_of_tables_header =
    "[[" > surround(_toml.path, maybe(ws)) < "]]"
  ========================================
  0000    | CallFunctionConstant 146: "[["
  0002    | TakeRight 2 -> 13
  0005    | GetConstant 82: surround
  0007    | GetConstant 80: _toml.path
  0009    | GetConstant 147: @fn141
  0011    | CallFunction 2
  0013    | JumpIfFailure 13 -> 19
  0016    | CallFunctionConstant 148: "]]"
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =========_Toml.Doc.AppendAtPath=========
  _Toml.Doc.AppendAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.AppendUpdater)
  ========================================
  0000    | GetConstant 117: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetConstant 149: _Toml.Doc.AppendUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  ========_Toml.Doc.AppendUpdater=========
  _Toml.Doc.AppendUpdater(Doc, Key, Val) =
    (
      _Toml.Doc.Has(Doc, Key) ? Doc :
      _Toml.Doc.Insert(Doc, Key, [], "array_of_tables")
    ) -> DocWithKey &
    _Toml.Doc.AppendToArrayOfTables(DocWithKey, Key, Val)
  ========================================
  0000    | GetConstant 150: DocWithKey
  0002    | SetInputMark
  0003    | GetConstant 122: _Toml.Doc.Has
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | ConditionalThen 11 -> 19
  0014    | GetBoundLocal 0
  0016    | Jump 16 -> 30
  0019    | GetConstant 125: _Toml.Doc.Insert
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 1
  0025    | PushEmptyArray
  0026    | GetConstant 151: "array_of_tables"
  0028    | CallFunction 4
  0030    | Destructure 31: DocWithKey
  0032    | TakeRight 32 -> 45
  0035    | GetConstant 152: _Toml.Doc.AppendToArrayOfTables
  0037    | GetBoundLocal 3
  0039    | GetBoundLocal 1
  0041    | GetBoundLocal 2
  0043    | CallTailFunction 3
  0045    | End
  ========================================
  
  ====_Toml.Doc.AppendToArrayOfTables=====
  _Toml.Doc.AppendToArrayOfTables(Doc, Key, Val) =
    _Toml.Doc.Get(Doc, Key) -> {"value": AoT, "type": "array_of_tables"} &
    _Toml.Doc.Insert(Doc, Key, [...AoT, Val], "array_of_tables")
  ========================================
  0000    | GetConstant 153: AoT
  0002    | GetConstant 124: _Toml.Doc.Get
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | Destructure 32: {"value": AoT, "type": "array_of_tables"}
  0012    | TakeRight 12 -> 36
  0015    | GetConstant 125: _Toml.Doc.Insert
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 1
  0021    | PushEmptyArray
  0022    | GetBoundLocal 3
  0024    | Merge
  0025    | GetConstant 154: [_]
  0027    | GetBoundLocal 2
  0029    | InsertAtIndex 0
  0031    | Merge
  0032    | GetConstant 151: "array_of_tables"
  0034    | CallTailFunction 4
  0036    | End
  ========================================
  
  =========_toml.datetime.seconds=========
  _toml.datetime.seconds = ("0".."5" + "0".."9") | "60"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'5'
  0004    | ParseCodepointRange '0'..'9'
  0007    | Merge
  0008    | Or 8 -> 13
  0011    | CallTailFunctionConstant 155: "60"
  0013    | End
  ========================================
  
  ================Num.Abs=================
  Num.Abs(N) = N -> 0.. | -N
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 33: 0..
  0005    | Or 5 -> 11
  0008    | GetBoundLocal 0
  0010    | NegateNumber
  0011    | End
  ========================================
  
  =========Is.GreaterThanOrEqual==========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 34: B..
  0004    | End
  ========================================
  
  ================newlines================
  newlines = many(newline)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant 31: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========toml.simple_value============
  toml.simple_value =
    toml.string |
    toml.datetime |
    toml.number |
    toml.boolean |
    toml.array(toml.simple_value) |
    toml.inline_table(toml.simple_value)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 156: toml.string
  0003    | Or 3 -> 40
  0006    | SetInputMark
  0007    | CallFunctionConstant 157: toml.datetime
  0009    | Or 9 -> 40
  0012    | SetInputMark
  0013    | CallFunctionConstant 158: toml.number
  0015    | Or 15 -> 40
  0018    | SetInputMark
  0019    | CallFunctionConstant 159: toml.boolean
  0021    | Or 21 -> 40
  0024    | SetInputMark
  0025    | GetConstant 160: toml.array
  0027    | GetConstant 161: toml.simple_value
  0029    | CallFunction 1
  0031    | Or 31 -> 40
  0034    | GetConstant 162: toml.inline_table
  0036    | GetConstant 161: toml.simple_value
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  ==============toml.string===============
  toml.string =
    toml.string.multi_line_basic |
    toml.string.multi_line_literal |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 163: toml.string.multi_line_basic
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 164: toml.string.multi_line_literal
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | CallFunctionConstant 92: toml.string.basic
  0015    | Or 15 -> 20
  0018    | CallTailFunctionConstant 93: toml.string.literal
  0020    | End
  ========================================
  
  =================@fn159=================
  maybe(nl)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 31: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn162=================
  _ctrl_char | `\`
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 99: _ctrl_char
  0003    | Or 3 -> 8
  0006    | ParseChar '\'
  0008    | End
  ========================================
  
  =================@fn161=================
  _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 96: _toml.escaped_ctrl_char
  0003    | Or 3 -> 39
  0006    | SetInputMark
  0007    | CallFunctionConstant 97: _toml.escaped_unicode
  0009    | Or 9 -> 39
  0012    | SetInputMark
  0013    | CallFunctionConstant 27: whitespace
  0015    | Or 15 -> 39
  0018    | SetInputMark
  0019    | ParseChar '\'
  0021    | CallFunctionConstant 27: whitespace
  0023    | Merge
  0024    | TakeRight 24 -> 28
  0027    | PushEmptyString
  0028    | Or 28 -> 39
  0031    | GetConstant 35: unless
  0033    | GetConstant 34: char
  0035    | GetConstant 170: @fn162
  0037    | CallTailFunction 2
  0039    | End
  ========================================
  
  =================@fn160=================
  many_until(
        _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`),
        `"""`
      )
  ========================================
  0000    | GetConstant 33: many_until
  0002    | GetConstant 169: @fn161
  0004    | GetConstant 166: """""
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ======toml.string.multi_line_basic======
  toml.string.multi_line_basic =
    skip(`"""`) + skip(maybe(nl)) +
    default(
      many_until(
        _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`),
        `"""`
      ),
      $""
    )
    + skip(`"""`) + (`"` * 0..2)
  ========================================
  0000    | GetConstant 165: skip
  0002    | GetConstant 166: """""
  0004    | CallFunction 1
  0006    | GetConstant 165: skip
  0008    | GetConstant 167: @fn159
  0010    | CallFunction 1
  0012    | Merge
  0013    | GetConstant 111: default
  0015    | GetConstant 168: @fn160
  0017    | PushEmptyString
  0018    | CallFunction 2
  0020    | Merge
  0021    | GetConstant 165: skip
  0023    | GetConstant 166: """""
  0025    | CallFunction 1
  0027    | Merge
  0028    | PushNull
  0029    | PushNumberZero
  0030    | ValidateRepeatPattern
  0031    | JumpIfZero 31 -> 49
  0034    | Swap
  0035    | ParseChar '"'
  0037    | Merge
  0038    | JumpIfFailure 38 -> 77
  0041    | Swap
  0042    | Decrement
  0043    | JumpIfZero 43 -> 49
  0046    | JumpBack 46 -> 34
  0049    | Drop
  0050    | PushNumberTwo
  0051    | PushNumberZero
  0052    | NegateNumber
  0053    | Merge
  0054    | ValidateRepeatPattern
  0055    | JumpIfZero 55 -> 78
  0058    | Swap
  0059    | SetInputMark
  0060    | ParseChar '"'
  0062    | JumpIfFailure 62 -> 75
  0065    | PopInputMark
  0066    | Merge
  0067    | Swap
  0068    | Decrement
  0069    | JumpIfZero 69 -> 78
  0072    | JumpBack 72 -> 58
  0075    | ResetInput
  0076    | Drop
  0077    | Swap
  0078    | Drop
  0079    | Merge
  0080    | End
  ========================================
  
  ==================skip==================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 171: null
  0002    | GetBoundLocal 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================null==================
  null(n) = n $ null
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushNull
  0006    | End
  ========================================
  
  =================@fn164=================
  maybe(nl)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 31: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn165=================
  many_until(char, `'''`)
  ========================================
  0000    | GetConstant 33: many_until
  0002    | GetConstant 34: char
  0004    | GetConstant 172: "'''"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =====toml.string.multi_line_literal=====
  toml.string.multi_line_literal =
    skip(`'''`) + skip(maybe(nl)) +
    default(many_until(char, `'''`), $"")
    + skip(`'''`) + (`'` * 0..2)
  ========================================
  0000    | GetConstant 165: skip
  0002    | GetConstant 172: "'''"
  0004    | CallFunction 1
  0006    | GetConstant 165: skip
  0008    | GetConstant 173: @fn164
  0010    | CallFunction 1
  0012    | Merge
  0013    | GetConstant 111: default
  0015    | GetConstant 174: @fn165
  0017    | PushEmptyString
  0018    | CallFunction 2
  0020    | Merge
  0021    | GetConstant 165: skip
  0023    | GetConstant 172: "'''"
  0025    | CallFunction 1
  0027    | Merge
  0028    | PushNull
  0029    | PushNumberZero
  0030    | ValidateRepeatPattern
  0031    | JumpIfZero 31 -> 49
  0034    | Swap
  0035    | ParseChar '''
  0037    | Merge
  0038    | JumpIfFailure 38 -> 77
  0041    | Swap
  0042    | Decrement
  0043    | JumpIfZero 43 -> 49
  0046    | JumpBack 46 -> 34
  0049    | Drop
  0050    | PushNumberTwo
  0051    | PushNumberZero
  0052    | NegateNumber
  0053    | Merge
  0054    | ValidateRepeatPattern
  0055    | JumpIfZero 55 -> 78
  0058    | Swap
  0059    | SetInputMark
  0060    | ParseChar '''
  0062    | JumpIfFailure 62 -> 75
  0065    | PopInputMark
  0066    | Merge
  0067    | Swap
  0068    | Decrement
  0069    | JumpIfZero 69 -> 78
  0072    | JumpBack 72 -> 58
  0075    | ResetInput
  0076    | Drop
  0077    | Swap
  0078    | Drop
  0079    | Merge
  0080    | End
  ========================================
  
  =============toml.datetime==============
  toml.datetime =
    toml.datetime.offset |
    toml.datetime.local |
    toml.datetime.local_date |
    toml.datetime.local_time
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 175: toml.datetime.offset
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 176: toml.datetime.local
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | CallFunctionConstant 177: toml.datetime.local_date
  0015    | Or 15 -> 20
  0018    | CallTailFunctionConstant 178: toml.datetime.local_time
  0020    | End
  ========================================
  
  ==========toml.datetime.offset==========
  toml.datetime.offset = toml.datetime.local_date + ("T" | "t" | " ") + _toml.datetime.time_offset
  ========================================
  0000    | CallFunctionConstant 177: toml.datetime.local_date
  0002    | SetInputMark
  0003    | ParseChar 'T'
  0005    | Or 5 -> 16
  0008    | SetInputMark
  0009    | ParseChar 't'
  0011    | Or 11 -> 16
  0014    | ParseChar ' '
  0016    | Merge
  0017    | CallFunctionConstant 179: _toml.datetime.time_offset
  0019    | Merge
  0020    | End
  ========================================
  
  ========toml.datetime.local_date========
  toml.datetime.local_date =
    _toml.datetime.year + "-" + _toml.datetime.month + "-" + _toml.datetime.mday
  ========================================
  0000    | CallFunctionConstant 180: _toml.datetime.year
  0002    | ParseChar '-'
  0004    | Merge
  0005    | CallFunctionConstant 181: _toml.datetime.month
  0007    | Merge
  0008    | ParseChar '-'
  0010    | Merge
  0011    | CallFunctionConstant 182: _toml.datetime.mday
  0013    | Merge
  0014    | End
  ========================================
  
  ==========_toml.datetime.year===========
  _toml.datetime.year = numeral * 4
  ========================================
  0000    | PushNull
  0001    | PushNumber 4
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | CallFunctionConstant 91: numeral
  0010    | Merge
  0011    | JumpIfFailure 11 -> 22
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 23
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | Drop
  0024    | End
  ========================================
  
  ==========_toml.datetime.month==========
  _toml.datetime.month = ("0" + "1".."9") | ("1" + "0".."2")
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '0'
  0003    | ParseCodepointRange '1'..'9'
  0006    | Merge
  0007    | Or 7 -> 16
  0010    | ParseChar '1'
  0012    | ParseCodepointRange '0'..'2'
  0015    | Merge
  0016    | End
  ========================================
  
  =======_toml.datetime.time_offset=======
  _toml.datetime.time_offset = toml.datetime.local_time + ("Z" | "z" | _toml.datetime.time_numoffset)
  ========================================
  0000    | CallFunctionConstant 178: toml.datetime.local_time
  0002    | SetInputMark
  0003    | ParseChar 'Z'
  0005    | Or 5 -> 16
  0008    | SetInputMark
  0009    | ParseChar 'z'
  0011    | Or 11 -> 16
  0014    | CallFunctionConstant 183: _toml.datetime.time_numoffset
  0016    | Merge
  0017    | End
  ========================================
  
  =================@fn176=================
  "." + (numeral * 1..9)
  ========================================
  0000    | ParseChar '.'
  0002    | PushNull
  0003    | PushNumberOne
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 23
  0008    | Swap
  0009    | CallFunctionConstant 91: numeral
  0011    | Merge
  0012    | JumpIfFailure 12 -> 52
  0015    | Swap
  0016    | Decrement
  0017    | JumpIfZero 17 -> 23
  0020    | JumpBack 20 -> 8
  0023    | Drop
  0024    | PushNumber 9
  0026    | PushNumberOne
  0027    | NegateNumber
  0028    | Merge
  0029    | ValidateRepeatPattern
  0030    | JumpIfZero 30 -> 53
  0033    | Swap
  0034    | SetInputMark
  0035    | CallFunctionConstant 91: numeral
  0037    | JumpIfFailure 37 -> 50
  0040    | PopInputMark
  0041    | Merge
  0042    | Swap
  0043    | Decrement
  0044    | JumpIfZero 44 -> 53
  0047    | JumpBack 47 -> 33
  0050    | ResetInput
  0051    | Drop
  0052    | Swap
  0053    | Drop
  0054    | Merge
  0055    | End
  ========================================
  
  ========toml.datetime.local_time========
  toml.datetime.local_time =
    _toml.datetime.hours + ":" +
    _toml.datetime.minutes + ":" +
    _toml.datetime.seconds +
    maybe("." + (numeral * 1..9))
  ========================================
  0000    | CallFunctionConstant 184: _toml.datetime.hours
  0002    | ParseChar ':'
  0004    | Merge
  0005    | CallFunctionConstant 185: _toml.datetime.minutes
  0007    | Merge
  0008    | ParseChar ':'
  0010    | Merge
  0011    | CallFunctionConstant 186: _toml.datetime.seconds
  0013    | Merge
  0014    | GetConstant 0: maybe
  0016    | GetConstant 187: @fn176
  0018    | CallFunction 1
  0020    | Merge
  0021    | End
  ========================================
  
  ==========_toml.datetime.hours==========
  _toml.datetime.hours = ("0".."1" + "0".."9") | ("2" + "0".."3")
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'1'
  0004    | ParseCodepointRange '0'..'9'
  0007    | Merge
  0008    | Or 8 -> 17
  0011    | ParseChar '2'
  0013    | ParseCodepointRange '0'..'3'
  0016    | Merge
  0017    | End
  ========================================
  
  =========_toml.datetime.minutes=========
  _toml.datetime.minutes = "0".."5" + "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'5'
  0003    | ParseCodepointRange '0'..'9'
  0006    | Merge
  0007    | End
  ========================================
  
  =====_toml.datetime.time_numoffset======
  _toml.datetime.time_numoffset = ("+" | "-") + _toml.datetime.hours + ":" + _toml.datetime.minutes
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | CallFunctionConstant 184: _toml.datetime.hours
  0010    | Merge
  0011    | ParseChar ':'
  0013    | Merge
  0014    | CallFunctionConstant 185: _toml.datetime.minutes
  0016    | Merge
  0017    | End
  ========================================
  
  ==========toml.datetime.local===========
  toml.datetime.local = toml.datetime.local_date + ("T" | "t" | " ") + toml.datetime.local_time
  ========================================
  0000    | CallFunctionConstant 177: toml.datetime.local_date
  0002    | SetInputMark
  0003    | ParseChar 'T'
  0005    | Or 5 -> 16
  0008    | SetInputMark
  0009    | ParseChar 't'
  0011    | Or 11 -> 16
  0014    | ParseChar ' '
  0016    | Merge
  0017    | CallFunctionConstant 178: toml.datetime.local_time
  0019    | Merge
  0020    | End
  ========================================
  
  ==============toml.number===============
  toml.number =
    toml.number.binary_integer |
    toml.number.octal_integer |
    toml.number.hex_integer |
    toml.number.infinity |
    toml.number.not_a_number |
    toml.number.float |
    toml.number.integer
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 188: toml.number.binary_integer
  0003    | Or 3 -> 38
  0006    | SetInputMark
  0007    | CallFunctionConstant 189: toml.number.octal_integer
  0009    | Or 9 -> 38
  0012    | SetInputMark
  0013    | CallFunctionConstant 190: toml.number.hex_integer
  0015    | Or 15 -> 38
  0018    | SetInputMark
  0019    | CallFunctionConstant 191: toml.number.infinity
  0021    | Or 21 -> 38
  0024    | SetInputMark
  0025    | CallFunctionConstant 192: toml.number.not_a_number
  0027    | Or 27 -> 38
  0030    | SetInputMark
  0031    | CallFunctionConstant 193: toml.number.float
  0033    | Or 33 -> 38
  0036    | CallTailFunctionConstant 194: toml.number.integer
  0038    | End
  ========================================
  
  =================@fn185=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn186=================
  skip("_") < peek(binary_numeral)
  ========================================
  0000    | GetConstant 165: skip
  0002    | PushChar '_'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 36: peek
  0011    | GetConstant 201: binary_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn184=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral))
  ========================================
  0000    | GetConstant 58: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant 199: @fn185
  0005    | CallFunction 2
  0007    | GetConstant 0: maybe
  0009    | GetConstant 200: @fn186
  0011    | CallFunction 1
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn190=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn188=================
  array_sep(binary_digit, maybe("_"))
  ========================================
  0000    | GetConstant 58: array_sep
  0002    | GetConstant 203: binary_digit
  0004    | GetConstant 204: @fn190
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =======toml.number.binary_integer=======
  toml.number.binary_integer =
    "0b" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral)),
      array_sep(binary_digit, maybe("_"))
    ) -> Digits $
    Num.FromBinaryDigits(Digits)
  ========================================
  0000    | GetConstant 195: Digits
  0002    | CallFunctionConstant 196: "0b"
  0004    | TakeRight 4 -> 26
  0007    | GetConstant 197: one_or_both
  0009    | GetConstant 198: @fn184
  0011    | GetConstant 202: @fn188
  0013    | CallFunction 2
  0015    | Destructure 35: Digits
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 205: Num.FromBinaryDigits
  0022    | GetBoundLocal 0
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  ==============one_or_both===============
  one_or_both(a, b) = (a + maybe(b)) | (maybe(a) + b)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | GetConstant 0: maybe
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | Merge
  0010    | Or 10 -> 22
  0013    | GetConstant 0: maybe
  0015    | GetBoundLocal 0
  0017    | CallFunction 1
  0019    | CallFunctionLocal 1
  0021    | Merge
  0022    | End
  ========================================
  
  =============binary_numeral=============
  binary_numeral = "0" | "1"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '0'
  0003    | Or 3 -> 8
  0006    | ParseChar '1'
  0008    | End
  ========================================
  
  ==============binary_digit==============
  binary_digit = 0..1
  ========================================
  0000    | ParseIntegerRange 0..1
  0003    | End
  ========================================
  
  =================@fn193=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn194=================
  skip("_") < peek(octal_numeral)
  ========================================
  0000    | GetConstant 165: skip
  0002    | PushChar '_'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 36: peek
  0011    | GetConstant 210: octal_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn192=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral))
  ========================================
  0000    | GetConstant 58: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant 208: @fn193
  0005    | CallFunction 2
  0007    | GetConstant 0: maybe
  0009    | GetConstant 209: @fn194
  0011    | CallFunction 1
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn197=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn195=================
  array_sep(octal_digit, maybe("_"))
  ========================================
  0000    | GetConstant 58: array_sep
  0002    | GetConstant 212: octal_digit
  0004    | GetConstant 213: @fn197
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =======toml.number.octal_integer========
  toml.number.octal_integer =
    "0o" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral)),
      array_sep(octal_digit, maybe("_"))
    ) -> Digits $
    Num.FromOctalDigits(Digits)
  ========================================
  0000    | GetConstant 195: Digits
  0002    | CallFunctionConstant 206: "0o"
  0004    | TakeRight 4 -> 26
  0007    | GetConstant 197: one_or_both
  0009    | GetConstant 207: @fn192
  0011    | GetConstant 211: @fn195
  0013    | CallFunction 2
  0015    | Destructure 36: Digits
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 214: Num.FromOctalDigits
  0022    | GetBoundLocal 0
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  ==============octal_digit===============
  octal_digit = 0..7
  ========================================
  0000    | ParseIntegerRange 0..7
  0003    | End
  ========================================
  
  ==========Num.FromOctalDigits===========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | GetConstant 5: Len
  0002    | GetConstant 6: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 37: Len
  0010    | TakeRight 10 -> 24
  0013    | GetConstant 215: _Num.FromOctalDigits
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | PushNumberNegOne
  0020    | Merge
  0021    | PushNumberZero
  0022    | CallTailFunction 3
  0024    | End
  ========================================
  
  ==========_Num.FromOctalDigits==========
  _Num.FromOctalDigits(Os, Pos, Acc) =
    Os -> [O, ...Rest] ? (
      O -> 0..7 &
      _Num.FromOctalDigits(
        Rest,
        Pos - 1,
        Acc + Num.Mul(O, Num.Pow(8, Pos)),
      )
    ) :
    Acc
  ========================================
  0000    | PushCharVar O
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 38: ([O] + Rest)
  0009    | ConditionalThen 9 -> 49
  0012    | GetBoundLocal 3
  0014    | Destructure 39: 0..7
  0016    | TakeRight 16 -> 46
  0019    | GetConstant 215: _Num.FromOctalDigits
  0021    | GetBoundLocal 4
  0023    | GetBoundLocal 1
  0025    | PushNumberNegOne
  0026    | Merge
  0027    | GetBoundLocal 2
  0029    | GetConstant 9: @Multiply
  0031    | GetBoundLocal 3
  0033    | GetConstant 10: @Power
  0035    | PushNumber 8
  0037    | GetBoundLocal 1
  0039    | CallFunction 2
  0041    | CallFunction 2
  0043    | Merge
  0044    | CallTailFunction 3
  0046    | Jump 46 -> 51
  0049    | GetBoundLocal 2
  0051    | End
  ========================================
  
  =================@fn201=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn202=================
  skip("_") < peek(hex_numeral)
  ========================================
  0000    | GetConstant 165: skip
  0002    | PushChar '_'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 36: peek
  0011    | GetConstant 108: hex_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn200=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral))
  ========================================
  0000    | GetConstant 58: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant 218: @fn201
  0005    | CallFunction 2
  0007    | GetConstant 0: maybe
  0009    | GetConstant 219: @fn202
  0011    | CallFunction 1
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn205=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn203=================
  array_sep(hex_digit, maybe("_"))
  ========================================
  0000    | GetConstant 58: array_sep
  0002    | GetConstant 221: hex_digit
  0004    | GetConstant 222: @fn205
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ========toml.number.hex_integer=========
  toml.number.hex_integer =
    "0x" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral)),
      array_sep(hex_digit, maybe("_"))
    ) -> Digits $
    Num.FromHexDigits(Digits)
  ========================================
  0000    | GetConstant 195: Digits
  0002    | CallFunctionConstant 216: "0x"
  0004    | TakeRight 4 -> 26
  0007    | GetConstant 197: one_or_both
  0009    | GetConstant 217: @fn200
  0011    | GetConstant 220: @fn203
  0013    | CallFunction 2
  0015    | Destructure 40: Digits
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 223: Num.FromHexDigits
  0022    | GetBoundLocal 0
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  ===============hex_digit================
  hex_digit =
    digit |
    ("a" | "A" $ 10) |
    ("b" | "B" $ 11) |
    ("c" | "C" $ 12) |
    ("d" | "D" $ 13) |
    ("e" | "E" $ 14) |
    ("f" | "F" $ 15)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 224: digit
  0003    | Or 3 -> 104
  0006    | SetInputMark
  0007    | SetInputMark
  0008    | ParseChar 'a'
  0010    | Or 10 -> 15
  0013    | ParseChar 'A'
  0015    | TakeRight 15 -> 20
  0018    | PushNumber 10
  0020    | Or 20 -> 104
  0023    | SetInputMark
  0024    | SetInputMark
  0025    | ParseChar 'b'
  0027    | Or 27 -> 32
  0030    | ParseChar 'B'
  0032    | TakeRight 32 -> 37
  0035    | PushNumber 11
  0037    | Or 37 -> 104
  0040    | SetInputMark
  0041    | SetInputMark
  0042    | ParseChar 'c'
  0044    | Or 44 -> 49
  0047    | ParseChar 'C'
  0049    | TakeRight 49 -> 54
  0052    | PushNumber 12
  0054    | Or 54 -> 104
  0057    | SetInputMark
  0058    | SetInputMark
  0059    | ParseChar 'd'
  0061    | Or 61 -> 66
  0064    | ParseChar 'D'
  0066    | TakeRight 66 -> 71
  0069    | PushNumber 13
  0071    | Or 71 -> 104
  0074    | SetInputMark
  0075    | SetInputMark
  0076    | ParseChar 'e'
  0078    | Or 78 -> 83
  0081    | ParseChar 'E'
  0083    | TakeRight 83 -> 88
  0086    | PushNumber 14
  0088    | Or 88 -> 104
  0091    | SetInputMark
  0092    | ParseChar 'f'
  0094    | Or 94 -> 99
  0097    | ParseChar 'F'
  0099    | TakeRight 99 -> 104
  0102    | PushNumber 15
  0104    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===========Num.FromHexDigits============
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | GetConstant 5: Len
  0002    | GetConstant 6: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 41: Len
  0010    | TakeRight 10 -> 24
  0013    | GetConstant 225: _Num.FromHexDigits
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | PushNumberNegOne
  0020    | Merge
  0021    | PushNumberZero
  0022    | CallTailFunction 3
  0024    | End
  ========================================
  
  ===========_Num.FromHexDigits===========
  _Num.FromHexDigits(Hs, Pos, Acc) =
    Hs -> [H, ...Rest] ? (
      H -> 0..15 &
      _Num.FromHexDigits(
        Rest,
        Pos - 1,
        Acc + Num.Mul(H, Num.Pow(16, Pos)),
      )
    ) :
    Acc
  ========================================
  0000    | PushCharVar H
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 42: ([H] + Rest)
  0009    | ConditionalThen 9 -> 49
  0012    | GetBoundLocal 3
  0014    | Destructure 43: 0..15
  0016    | TakeRight 16 -> 46
  0019    | GetConstant 225: _Num.FromHexDigits
  0021    | GetBoundLocal 4
  0023    | GetBoundLocal 1
  0025    | PushNumberNegOne
  0026    | Merge
  0027    | GetBoundLocal 2
  0029    | GetConstant 9: @Multiply
  0031    | GetBoundLocal 3
  0033    | GetConstant 10: @Power
  0035    | PushNumber 16
  0037    | GetBoundLocal 1
  0039    | CallFunction 2
  0041    | CallFunction 2
  0043    | Merge
  0044    | CallTailFunction 3
  0046    | Jump 46 -> 51
  0049    | GetBoundLocal 2
  0051    | End
  ========================================
  
  =================@fn208=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | End
  ========================================
  
  ========toml.number.not_a_number========
  toml.number.not_a_number = maybe("+" | "-") + "nan"
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 226: @fn208
  0004    | CallFunction 1
  0006    | CallFunctionConstant 227: "nan"
  0008    | Merge
  0009    | End
  ========================================
  
  =================@fn210=================
  _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  ========================================
  0000    | CallFunctionConstant 230: _toml.number.sign
  0002    | CallFunctionConstant 231: _toml.number.integer_part
  0004    | Merge
  0005    | SetInputMark
  0006    | CallFunctionConstant 232: _toml.number.fraction_part
  0008    | GetConstant 0: maybe
  0010    | GetConstant 233: _toml.number.exponent_part
  0012    | CallFunction 1
  0014    | Merge
  0015    | Or 15 -> 20
  0018    | CallFunctionConstant 233: _toml.number.exponent_part
  0020    | Merge
  0021    | End
  ========================================
  
  ===========toml.number.float============
  toml.number.float = as_number(
    _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  )
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant 229: @fn210
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushCharVar N
  0002    | CallFunctionLocal 0
  0004    | Destructure 44: "%(0 + N)"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocal 1
  0011    | End
  ========================================
  
  =================@fn215=================
  "-" | skip("+")
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 12
  0006    | GetConstant 165: skip
  0008    | PushChar '+'
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ===========_toml.number.sign============
  _toml.number.sign = maybe("-" | skip("+"))
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 234: @fn215
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn216=================
  maybe("_") > numeral
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 11
  0009    | CallTailFunctionConstant 91: numeral
  0011    | End
  ========================================
  
  =======_toml.number.integer_part========
  _toml.number.integer_part =
    ("1".."9" + many(maybe("_") > numeral)) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | GetConstant 45: many
  0006    | GetConstant 235: @fn216
  0008    | CallFunction 1
  0010    | Merge
  0011    | Or 11 -> 16
  0014    | CallTailFunctionConstant 91: numeral
  0016    | End
  ========================================
  
  =================@fn218=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.fraction_part=======
  _toml.number.fraction_part = "." + many_sep(numerals, maybe("_"))
  ========================================
  0000    | ParseChar '.'
  0002    | GetConstant 25: many_sep
  0004    | GetConstant 236: numerals
  0006    | GetConstant 237: @fn218
  0008    | CallFunction 2
  0010    | Merge
  0011    | End
  ========================================
  
  ================numerals================
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant 91: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn219=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
  ========================================
  
  =================@fn220=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.exponent_part=======
  _toml.number.exponent_part =
    ("e" | "E") + maybe("-" | "+") + many_sep(numerals, maybe("_"))
  ========================================
  0000    | SetInputMark
  0001    | ParseChar 'e'
  0003    | Or 3 -> 8
  0006    | ParseChar 'E'
  0008    | GetConstant 0: maybe
  0010    | GetConstant 238: @fn219
  0012    | CallFunction 1
  0014    | Merge
  0015    | GetConstant 25: many_sep
  0017    | GetConstant 236: numerals
  0019    | GetConstant 239: @fn220
  0021    | CallFunction 2
  0023    | Merge
  0024    | End
  ========================================
  
  =================@fn221=================
  _toml.number.sign +
    _toml.number.integer_part
  ========================================
  0000    | CallFunctionConstant 230: _toml.number.sign
  0002    | CallFunctionConstant 231: _toml.number.integer_part
  0004    | Merge
  0005    | End
  ========================================
  
  ==========toml.number.integer===========
  toml.number.integer = as_number(
    _toml.number.sign +
    _toml.number.integer_part
  )
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant 240: @fn221
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============toml.boolean==============
  toml.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 241: boolean
  0002    | GetConstant 242: "true"
  0004    | GetConstant 243: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================boolean=================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 244: true
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 245: false
  0012    | GetBoundLocal 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ==================true==================
  true(t) = t $ true
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushTrue
  0006    | End
  ========================================
  
  =================false==================
  false(f) = f $ false
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushFalse
  0006    | End
  ========================================
  
  =================@fn226=================
  surround(elem, _toml.ws)
  ========================================
  0000    | GetConstant 56: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 82: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 70: _toml.ws
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn227=================
  surround(",", _toml.ws)
  ========================================
  0000    | GetConstant 82: surround
  0002    | PushChar ','
  0004    | GetConstant 70: _toml.ws
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn225=================
  array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws))
  ========================================
  0000    | GetConstant 56: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 58: array_sep
  0005    | GetConstant 247: @fn226
  0007    | CreateClosure 1
  0009    | CaptureLocal 0
  0011    | PushChar ','
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 25
  0018    | GetConstant 0: maybe
  0020    | GetConstant 248: @fn227
  0022    | CallFunction 1
  0024    | TakeLeft
  0025    | End
  ========================================
  
  ===============toml.array===============
  toml.array(elem) =
    "[" > _toml.ws > default(
      array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws)),
      []
    ) < _toml.ws < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 70: _toml.ws
  0007    | TakeRight 7 -> 21
  0010    | GetConstant 111: default
  0012    | GetConstant 246: @fn225
  0014    | CreateClosure 1
  0016    | CaptureLocal 0
  0018    | PushEmptyArray
  0019    | CallFunction 2
  0021    | JumpIfFailure 21 -> 27
  0024    | CallFunctionConstant 70: _toml.ws
  0026    | TakeLeft
  0027    | JumpIfFailure 27 -> 33
  0030    | ParseChar ']'
  0032    | TakeLeft
  0033    | End
  ========================================
  
  ===========toml.inline_table============
  toml.inline_table(value) =
    _toml.empty_inline_table | _toml.nonempty_inline_table(value) -> InlineDoc $
    _Toml.Doc.Value(InlineDoc)
  ========================================
  0000    | GetConstant 249: InlineDoc
  0002    | SetInputMark
  0003    | CallFunctionConstant 250: _toml.empty_inline_table
  0005    | Or 5 -> 14
  0008    | GetConstant 251: _toml.nonempty_inline_table
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Destructure 45: InlineDoc
  0016    | TakeRight 16 -> 25
  0019    | GetConstant 126: _Toml.Doc.Value
  0021    | GetBoundLocal 1
  0023    | CallTailFunction 1
  0025    | End
  ========================================
  
  ========_toml.empty_inline_table========
  _toml.empty_inline_table = "{" > maybe(spaces) < "}" $ _Toml.Doc.Empty
  ========================================
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 0: maybe
  0007    | GetConstant 84: spaces
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 17
  0014    | ParseChar '}'
  0016    | TakeLeft
  0017    | TakeRight 17 -> 22
  0020    | CallTailFunctionConstant 69: _Toml.Doc.Empty
  0022    | End
  ========================================
  
  ======_toml.nonempty_inline_table=======
  _toml.nonempty_inline_table(value) =
    "{" > maybe(spaces) >
    _toml.inline_table_pair(value, _Toml.Doc.Empty) -> DocWithFirstPair &
    _toml.inline_table_body(value, DocWithFirstPair)
    < maybe(spaces) < "}"
  ========================================
  0000    | GetConstant 252: DocWithFirstPair
  0002    | ParseChar '{'
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 0: maybe
  0009    | GetConstant 84: spaces
  0011    | CallFunction 1
  0013    | TakeRight 13 -> 24
  0016    | GetConstant 253: _toml.inline_table_pair
  0018    | GetBoundLocal 0
  0020    | CallFunctionConstant 69: _Toml.Doc.Empty
  0022    | CallFunction 2
  0024    | Destructure 46: DocWithFirstPair
  0026    | TakeRight 26 -> 53
  0029    | GetConstant 254: _toml.inline_table_body
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 1
  0035    | CallFunction 2
  0037    | JumpIfFailure 37 -> 47
  0040    | GetConstant 0: maybe
  0042    | GetConstant 84: spaces
  0044    | CallFunction 1
  0046    | TakeLeft
  0047    | JumpIfFailure 47 -> 53
  0050    | ParseChar '}'
  0052    | TakeLeft
  0053    | End
  ========================================
  
  ========_toml.inline_table_pair=========
  _toml.inline_table_pair(value, Doc) =
    maybe(spaces) &
    _toml.path -> Key &
    maybe(spaces) & "=" & maybe(spaces) &
    value -> Val &
    maybe(spaces) $
    _Toml.Doc.InsertAtPath(Doc, Key, Val)
  ========================================
  0000    | GetConstant 119: Key
  0002    | GetConstant 74: Val
  0004    | GetConstant 0: maybe
  0006    | GetConstant 84: spaces
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 17
  0013    | CallFunctionConstant 80: _toml.path
  0015    | Destructure 47: Key
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 0: maybe
  0022    | GetConstant 84: spaces
  0024    | CallFunction 1
  0026    | TakeRight 26 -> 31
  0029    | ParseChar '='
  0031    | TakeRight 31 -> 40
  0034    | GetConstant 0: maybe
  0036    | GetConstant 84: spaces
  0038    | CallFunction 1
  0040    | TakeRight 40 -> 47
  0043    | CallFunctionLocal 0
  0045    | Destructure 48: Val
  0047    | TakeRight 47 -> 69
  0050    | GetConstant 0: maybe
  0052    | GetConstant 84: spaces
  0054    | CallFunction 1
  0056    | TakeRight 56 -> 69
  0059    | GetConstant 78: _Toml.Doc.InsertAtPath
  0061    | GetBoundLocal 1
  0063    | GetBoundLocal 2
  0065    | GetBoundLocal 3
  0067    | CallTailFunction 3
  0069    | End
  ========================================
  
  ========_toml.inline_table_body=========
  _toml.inline_table_body(value, Doc) =
    "," > _toml.inline_table_pair(value, Doc) -> NewDoc ?
    _toml.inline_table_body(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant 75: NewDoc
  0002    | SetInputMark
  0003    | ParseChar ','
  0005    | TakeRight 5 -> 16
  0008    | GetConstant 253: _toml.inline_table_pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Destructure 49: NewDoc
  0018    | ConditionalThen 18 -> 32
  0021    | GetConstant 254: _toml.inline_table_body
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 2
  0027    | CallTailFunction 2
  0029    | Jump 29 -> 38
  0032    | GetConstant 4: const
  0034    | GetBoundLocal 1
  0036    | CallTailFunction 1
  0038    | End
  ========================================
  
  =================@fn233=================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | CallFunctionConstant2 256: _number_integer_part
  0009    | Merge
  0010    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant 255: @fn233
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_number_integer_part==========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | CallFunctionConstant 236: numerals
  0006    | Merge
  0007    | Or 7 -> 12
  0010    | CallTailFunctionConstant 91: numeral
  0012    | End
  ========================================
  
  ===========__Table.RestPerRow===========
  __Table.RestPerRow(T, Acc) =
    T -> [Row, ...Rest] ? (
      Row -> [_, ...RowRest] ?
      __Table.RestPerRow(Rest, [...Acc, RowRest]) :
      __Table.RestPerRow(Rest, [...Acc, []])
    ) :
    Acc
  ========================================
  0000    | GetConstant2 257: Row
  0003    | GetConstant 8: Rest
  0005    | PushUnderscoreVar
  0006    | GetConstant2 258: RowRest
  0009    | SetInputMark
  0010    | GetBoundLocal 0
  0012    | Destructure 50: ([Row] + Rest)
  0014    | ConditionalThen 14 -> 65
  0017    | SetInputMark
  0018    | GetBoundLocal 2
  0020    | Destructure 51: ([_] + RowRest)
  0022    | ConditionalThen 22 -> 47
  0025    | GetConstant2 259: __Table.RestPerRow
  0028    | GetBoundLocal 3
  0030    | PushEmptyArray
  0031    | GetBoundLocal 1
  0033    | Merge
  0034    | GetConstant2 260: [_]
  0037    | GetBoundLocal 5
  0039    | InsertAtIndex 0
  0041    | Merge
  0042    | CallTailFunction 2
  0044    | Jump 44 -> 62
  0047    | GetConstant2 259: __Table.RestPerRow
  0050    | GetBoundLocal 3
  0052    | PushEmptyArray
  0053    | GetBoundLocal 1
  0055    | Merge
  0056    | GetConstant2 261: [[]]
  0059    | Merge
  0060    | CallTailFunction 2
  0062    | Jump 62 -> 67
  0065    | GetBoundLocal 1
  0067    | End
  ========================================
  
  ============ast.postfix_node============
  ast.postfix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 21
  0005    | GetConstant2 262: {_0_, _1_}
  0008    | GetConstant 129: "type"
  0010    | GetBoundLocal 1
  0012    | InsertKeyVal 0
  0014    | GetConstant2 263: "power"
  0017    | GetBoundLocal 2
  0019    | InsertKeyVal 1
  0021    | End
  ========================================
  
  ===============_Obj.Keys================
  _Obj.Keys(O, Acc) = O -> {K: _, ...Rest} ? _Obj.Keys(Rest, [...Acc, K]) : Acc
  ========================================
  0000    | PushCharVar K
  0002    | PushUnderscoreVar
  0003    | GetConstant 8: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 52: ({K: _} + Rest)
  0010    | ConditionalThen 10 -> 35
  0013    | GetConstant2 264: _Obj.Keys
  0016    | GetBoundLocal 4
  0018    | PushEmptyArray
  0019    | GetBoundLocal 1
  0021    | Merge
  0022    | GetConstant2 265: [_]
  0025    | GetBoundLocal 2
  0027    | InsertAtIndex 0
  0029    | Merge
  0030    | CallTailFunction 2
  0032    | Jump 32 -> 37
  0035    | GetBoundLocal 1
  0037    | End
  ========================================
  
  =================@fn244=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 56: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 54: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn245=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 56: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 54: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============array_until===============
  array_until(elem, stop) = unless(tuple1(elem), stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 32
  0006    | Swap
  0007    | GetConstant 35: unless
  0009    | GetConstant2 266: @fn244
  0012    | CreateClosure 1
  0014    | CaptureLocal 0
  0016    | GetBoundLocal 1
  0018    | CallFunction 2
  0020    | Merge
  0021    | JumpIfFailure 21 -> 57
  0024    | Swap
  0025    | Decrement
  0026    | JumpIfZero 26 -> 32
  0029    | JumpBack 29 -> 6
  0032    | Swap
  0033    | SetInputMark
  0034    | GetConstant 35: unless
  0036    | GetConstant2 267: @fn245
  0039    | CreateClosure 1
  0041    | CaptureLocal 0
  0043    | GetBoundLocal 1
  0045    | CallFunction 2
  0047    | JumpIfFailure 47 -> 55
  0050    | PopInputMark
  0051    | Merge
  0052    | JumpBack 52 -> 33
  0055    | ResetInput
  0056    | Drop
  0057    | Swap
  0058    | Drop
  0059    | JumpIfFailure 59 -> 69
  0062    | GetConstant 36: peek
  0064    | GetBoundLocal 1
  0066    | CallFunction 1
  0068    | TakeLeft
  0069    | End
  ========================================
  
  =================@fn247=================
  maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | CallFunctionConstant2 256: _number_integer_part
  0009    | Merge
  0010    | GetConstant 0: maybe
  0012    | GetConstant2 269: _number_fraction_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | GetConstant 0: maybe
  0020    | GetConstant2 270: _number_exponent_part
  0023    | CallFunction 1
  0025    | Merge
  0026    | End
  ========================================
  
  =================number=================
  number = as_number(
    maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 268: @fn247
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =========_number_fraction_part==========
  _number_fraction_part = "." + numerals
  ========================================
  0000    | ParseChar '.'
  0002    | CallFunctionConstant 236: numerals
  0004    | Merge
  0005    | End
  ========================================
  
  =================@fn250=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
  ========================================
  
  =========_number_exponent_part==========
  _number_exponent_part = ("e" | "E") + maybe("-" | "+") + numerals
  ========================================
  0000    | SetInputMark
  0001    | ParseChar 'e'
  0003    | Or 3 -> 8
  0006    | ParseChar 'E'
  0008    | GetConstant 0: maybe
  0010    | GetConstant2 271: @fn250
  0013    | CallFunction 1
  0015    | Merge
  0016    | CallFunctionConstant 236: numerals
  0018    | Merge
  0019    | End
  ========================================
  
  =============columns_padded=============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant2 272: Rows
  0003    | GetConstant2 273: rows_padded
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 1
  0010    | GetBoundLocal 2
  0012    | GetBoundLocal 3
  0014    | CallFunction 4
  0016    | Destructure 53: Rows
  0018    | TakeRight 18 -> 28
  0021    | GetConstant2 274: Table.Transpose
  0024    | GetBoundLocal 4
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  =================@fn255=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | GetConstant 56: elem
  0002    | GetConstant 57: col_sep
  0004    | GetConstant 60: row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant2 277: _dimensions
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 3
  0018    | End
  ========================================
  
  ==============rows_padded===============
  rows_padded(elem, col_sep, row_sep, Pad) =
    peek(_dimensions(elem, col_sep, row_sep)) -> [MaxRowLen, _] &
    elem -> First & _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [First], [])
  ========================================
  0000    | GetConstant2 275: MaxRowLen
  0003    | PushUnderscoreVar
  0004    | GetConstant 15: First
  0006    | GetConstant 36: peek
  0008    | GetConstant2 276: @fn255
  0011    | CreateClosure 3
  0013    | CaptureLocal 0
  0015    | CaptureLocal 1
  0017    | CaptureLocal 2
  0019    | CallFunction 1
  0021    | Destructure 54: [MaxRowLen, _]
  0023    | TakeRight 23 -> 30
  0026    | CallFunctionLocal 0
  0028    | Destructure 55: First
  0030    | TakeRight 30 -> 57
  0033    | GetConstant2 278: _rows_padded
  0036    | GetBoundLocal 0
  0038    | GetBoundLocal 1
  0040    | GetBoundLocal 2
  0042    | GetBoundLocal 3
  0044    | PushNumberOne
  0045    | GetBoundLocal 4
  0047    | GetConstant2 279: [_]
  0050    | GetBoundLocal 6
  0052    | InsertAtIndex 0
  0054    | PushEmptyArray
  0055    | CallTailFunction 8
  0057    | End
  ========================================
  
  ==============_dimensions===============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 19
  0005    | GetConstant2 280: __dimensions
  0008    | GetBoundLocal 0
  0010    | GetBoundLocal 1
  0012    | GetBoundLocal 2
  0014    | PushNumberOne
  0015    | PushNumberOne
  0016    | PushNumberZero
  0017    | CallTailFunction 6
  0019    | End
  ========================================
  
  ==============__dimensions==============
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
  0008    | ConditionalThen 8 -> 36
  0011    | GetConstant2 280: __dimensions
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | GetConstant2 281: Num.Inc
  0023    | GetBoundLocal 3
  0025    | CallFunction 1
  0027    | GetBoundLocal 4
  0029    | GetBoundLocal 5
  0031    | CallTailFunction 6
  0033    | Jump 33 -> 100
  0036    | SetInputMark
  0037    | CallFunctionLocal 2
  0039    | TakeRight 39 -> 44
  0042    | CallFunctionLocal 0
  0044    | ConditionalThen 44 -> 78
  0047    | GetConstant2 280: __dimensions
  0050    | GetBoundLocal 0
  0052    | GetBoundLocal 1
  0054    | GetBoundLocal 2
  0056    | PushNumberOne
  0057    | GetConstant2 281: Num.Inc
  0060    | GetBoundLocal 4
  0062    | CallFunction 1
  0064    | GetConstant2 282: Num.Max
  0067    | GetBoundLocal 3
  0069    | GetBoundLocal 5
  0071    | CallFunction 2
  0073    | CallTailFunction 6
  0075    | Jump 75 -> 100
  0078    | GetConstant 4: const
  0080    | GetConstant2 283: [_, _]
  0083    | GetConstant2 282: Num.Max
  0086    | GetBoundLocal 3
  0088    | GetBoundLocal 5
  0090    | CallFunction 2
  0092    | InsertAtIndex 0
  0094    | GetBoundLocal 4
  0096    | InsertAtIndex 1
  0098    | CallTailFunction 1
  0100    | End
  ========================================
  
  ================Num.Inc=================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant2 284: @Add
  0003    | GetBoundLocal 0
  0005    | PushNumberOne
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Max=================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 56: B..
  0005    | ConditionalThen 5 -> 13
  0008    | GetBoundLocal 0
  0010    | Jump 10 -> 15
  0013    | GetBoundLocal 1
  0015    | End
  ========================================
  
  ==============_rows_padded==============
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    col_sep > elem -> Elem ?
    _rows_padded(elem, col_sep, row_sep, Pad, Num.Inc(RowLen), MaxRowLen, [...AccRow, Elem], AccRows) :
    row_sep > elem -> NextRow ?
    _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [NextRow], [...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)]) :
    const([...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)])
  ========================================
  0000    | GetConstant 62: Elem
  0002    | GetConstant2 285: NextRow
  0005    | SetInputMark
  0006    | CallFunctionLocal 1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 0
  0013    | Destructure 57: Elem
  0015    | ConditionalThen 15 -> 57
  0018    | GetConstant2 278: _rows_padded
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 1
  0025    | GetBoundLocal 2
  0027    | GetBoundLocal 3
  0029    | GetConstant2 281: Num.Inc
  0032    | GetBoundLocal 4
  0034    | CallFunction 1
  0036    | GetBoundLocal 5
  0038    | PushEmptyArray
  0039    | GetBoundLocal 6
  0041    | Merge
  0042    | GetConstant2 286: [_]
  0045    | GetBoundLocal 8
  0047    | InsertAtIndex 0
  0049    | Merge
  0050    | GetBoundLocal 7
  0052    | CallTailFunction 8
  0054    | Jump 54 -> 150
  0057    | SetInputMark
  0058    | CallFunctionLocal 2
  0060    | TakeRight 60 -> 65
  0063    | CallFunctionLocal 0
  0065    | Destructure 58: NextRow
  0067    | ConditionalThen 67 -> 121
  0070    | GetConstant2 278: _rows_padded
  0073    | GetBoundLocal 0
  0075    | GetBoundLocal 1
  0077    | GetBoundLocal 2
  0079    | GetBoundLocal 3
  0081    | PushNumberOne
  0082    | GetBoundLocal 5
  0084    | GetConstant2 287: [_]
  0087    | GetBoundLocal 9
  0089    | InsertAtIndex 0
  0091    | PushEmptyArray
  0092    | GetBoundLocal 7
  0094    | Merge
  0095    | GetConstant2 288: [_]
  0098    | GetConstant2 289: Array.AppendN
  0101    | GetBoundLocal 6
  0103    | GetBoundLocal 3
  0105    | GetBoundLocal 5
  0107    | GetBoundLocal 4
  0109    | NegateNumber
  0110    | Merge
  0111    | CallFunction 3
  0113    | InsertAtIndex 0
  0115    | Merge
  0116    | CallTailFunction 8
  0118    | Jump 118 -> 150
  0121    | GetConstant 4: const
  0123    | PushEmptyArray
  0124    | GetBoundLocal 7
  0126    | Merge
  0127    | GetConstant2 290: [_]
  0130    | GetConstant2 289: Array.AppendN
  0133    | GetBoundLocal 6
  0135    | GetBoundLocal 3
  0137    | GetBoundLocal 5
  0139    | GetBoundLocal 4
  0141    | NegateNumber
  0142    | Merge
  0143    | CallFunction 3
  0145    | InsertAtIndex 0
  0147    | Merge
  0148    | CallTailFunction 1
  0150    | End
  ========================================
  
  =============Array.AppendN==============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetBoundLocal 0
  0002    | GetConstant2 291: [_]
  0005    | GetBoundLocal 1
  0007    | InsertAtIndex 0
  0009    | GetBoundLocal 2
  0011    | RepeatValue
  0012    | Merge
  0013    | End
  ========================================
  
  ============Table.Transpose=============
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant2 292: _Table.Transpose
  0003    | GetBoundLocal 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_Table.Transpose============
  _Table.Transpose(T, Acc) =
    _Table.FirstPerRow(T) -> FirstPerRow &
    _Table.RestPerRow(T) -> RestPerRow ?
    _Table.Transpose(RestPerRow, [...Acc, FirstPerRow]) :
    Acc
  ========================================
  0000    | GetConstant2 293: FirstPerRow
  0003    | GetConstant2 294: RestPerRow
  0006    | SetInputMark
  0007    | GetConstant2 295: _Table.FirstPerRow
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Destructure 59: FirstPerRow
  0016    | TakeRight 16 -> 28
  0019    | GetConstant2 296: _Table.RestPerRow
  0022    | GetBoundLocal 0
  0024    | CallFunction 1
  0026    | Destructure 60: RestPerRow
  0028    | ConditionalThen 28 -> 53
  0031    | GetConstant2 292: _Table.Transpose
  0034    | GetBoundLocal 3
  0036    | PushEmptyArray
  0037    | GetBoundLocal 1
  0039    | Merge
  0040    | GetConstant2 297: [_]
  0043    | GetBoundLocal 2
  0045    | InsertAtIndex 0
  0047    | Merge
  0048    | CallTailFunction 2
  0050    | Jump 50 -> 55
  0053    | GetBoundLocal 1
  0055    | End
  ========================================
  
  ===========_Table.FirstPerRow===========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | GetConstant2 257: Row
  0003    | GetConstant 8: Rest
  0005    | GetConstant2 298: VeryFirst
  0008    | PushUnderscoreVar
  0009    | GetBoundLocal 0
  0011    | Destructure 61: ([Row] + Rest)
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 1
  0018    | Destructure 62: ([VeryFirst] + _)
  0020    | TakeRight 20 -> 37
  0023    | GetConstant2 299: __Table.FirstPerRow
  0026    | GetBoundLocal 2
  0028    | GetConstant2 300: [_]
  0031    | GetBoundLocal 3
  0033    | InsertAtIndex 0
  0035    | CallTailFunction 2
  0037    | End
  ========================================
  
  ==========__Table.FirstPerRow===========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant2 257: Row
  0003    | GetConstant 8: Rest
  0005    | GetConstant 15: First
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 63: ([Row] + Rest)
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 2
  0018    | Destructure 64: ([First] + _)
  0020    | ConditionalThen 20 -> 45
  0023    | GetConstant2 299: __Table.FirstPerRow
  0026    | GetBoundLocal 3
  0028    | PushEmptyArray
  0029    | GetBoundLocal 1
  0031    | Merge
  0032    | GetConstant2 301: [_]
  0035    | GetBoundLocal 4
  0037    | InsertAtIndex 0
  0039    | Merge
  0040    | CallTailFunction 2
  0042    | Jump 42 -> 47
  0045    | GetBoundLocal 1
  0047    | End
  ========================================
  
  ===========_Table.RestPerRow============
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant2 259: __Table.RestPerRow
  0003    | GetBoundLocal 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 90: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 91: numeral
  0008    | End
  ========================================
  
  =================lower==================
  lower = "a".."z"
  ========================================
  0000    | ParseCodepointRange 'a'..'z'
  0003    | End
  ========================================
  
  =================@fn278=================
  unless(char, whitespace)
  ========================================
  0000    | GetConstant 35: unless
  0002    | GetConstant 34: char
  0004    | GetConstant 27: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  token = many(unless(char, whitespace))
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant2 302: @fn278
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ================columns=================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant2 272: Rows
  0003    | GetConstant2 303: rows
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 1
  0010    | GetBoundLocal 2
  0012    | CallFunction 3
  0014    | Destructure 65: Rows
  0016    | TakeRight 16 -> 26
  0019    | GetConstant2 274: Table.Transpose
  0022    | GetBoundLocal 3
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  ======Table.RotateCounterClockwise======
  Table.RotateCounterClockwise(T) = Array.Reverse(Table.Transpose(T))
  ========================================
  0000    | GetConstant2 304: Array.Reverse
  0003    | GetConstant2 274: Table.Transpose
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  =============Array.Reverse==============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant2 305: _Array.Reverse
  0003    | GetBoundLocal 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Array.Reverse=============
  _Array.Reverse(A, Acc) =
    A -> [First, ...Rest] ? _Array.Reverse(Rest, [First, ...Acc]) : Acc
  ========================================
  0000    | GetConstant 15: First
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 66: ([First] + Rest)
  0009    | ConditionalThen 9 -> 32
  0012    | GetConstant2 305: _Array.Reverse
  0015    | GetBoundLocal 3
  0017    | GetConstant2 306: [_]
  0020    | GetBoundLocal 2
  0022    | InsertAtIndex 0
  0024    | GetBoundLocal 1
  0026    | Merge
  0027    | CallTailFunction 2
  0029    | Jump 29 -> 34
  0032    | GetBoundLocal 1
  0034    | End
  ========================================
  
  ===========_escaped_ctrl_char===========
  _escaped_ctrl_char =
    (`\"` $ `"`) |
    (`\\` $ `\`) |
    (`\/` $ `/`) |
    (`\b` $ "\b") |
    (`\f` $ "\f") |
    (`\n` $ "\n") |
    (`\r` $ "\r") |
    (`\t` $ "\t")
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 100: "\""
  0003    | TakeRight 3 -> 8
  0006    | PushChar '"'
  0008    | Or 8 -> 85
  0011    | SetInputMark
  0012    | CallFunctionConstant 101: "\\"
  0014    | TakeRight 14 -> 19
  0017    | PushChar '\'
  0019    | Or 19 -> 85
  0022    | SetInputMark
  0023    | CallFunctionConstant2 307: "\/"
  0026    | TakeRight 26 -> 31
  0029    | PushChar '/'
  0031    | Or 31 -> 85
  0034    | SetInputMark
  0035    | CallFunctionConstant 102: "\b"
  0037    | TakeRight 37 -> 42
  0040    | PushChar '\x08' (esc)
  0042    | Or 42 -> 85
  0045    | SetInputMark
  0046    | CallFunctionConstant 103: "\f"
  0048    | TakeRight 48 -> 53
  0051    | PushChar '\x0c' (esc)
  0053    | Or 53 -> 85
  0056    | SetInputMark
  0057    | CallFunctionConstant 104: "\n"
  0059    | TakeRight 59 -> 64
  0062    | PushChar '
  '
  0064    | Or 64 -> 85
  0067    | SetInputMark
  0068    | CallFunctionConstant 105: "\r"
  0070    | TakeRight 70 -> 75
  0073    | PushChar '\r (no-eol) (esc)
  '
  0075    | Or 75 -> 85
  0078    | CallFunctionConstant 106: "\t"
  0080    | TakeRight 80 -> 85
  0083    | PushChar '\t' (esc)
  0085    | End
  ========================================
  
  =============Is.GreaterThan=============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 67: B
  0005    | ConditionalThen 5 -> 13
  0008    | CallTailFunctionConstant 14: @Fail
  0010    | Jump 10 -> 17
  0013    | GetBoundLocal 0
  0015    | Destructure 68: B..
  0017    | End
  ========================================
  
  ===============json.null================
  json.null = null("null")
  ========================================
  0000    | GetConstant 171: null
  0002    | GetConstant2 308: "null"
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ================Is.Bool=================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 69: (false + _)
  0005    | End
  ========================================
  
  ===============As.String================
  As.String(V) = "%(V)"
  ========================================
  0000    | PushEmptyString
  0001    | GetBoundLocal 0
  0003    | MergeAsString
  0004    | End
  ========================================
  
  ==============Array.Merge===============
  Array.Merge(A) = _Array.Merge(A, null)
  ========================================
  0000    | GetConstant2 309: _Array.Merge
  0003    | GetBoundLocal 0
  0005    | PushNull
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==============_Array.Merge==============
  _Array.Merge(A, Acc) =
    A -> [First, ...Rest] ? _Array.Merge(Rest, Acc + First) : Acc
  ========================================
  0000    | GetConstant 15: First
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 70: ([First] + Rest)
  0009    | ConditionalThen 9 -> 27
  0012    | GetConstant2 309: _Array.Merge
  0015    | GetBoundLocal 3
  0017    | GetBoundLocal 1
  0019    | GetBoundLocal 2
  0021    | Merge
  0022    | CallTailFunction 2
  0024    | Jump 24 -> 29
  0027    | GetBoundLocal 1
  0029    | End
  ========================================
  
  ==========non_negative_integer==========
  non_negative_integer = as_number(_number_integer_part)
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 256: _number_integer_part
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ============Table.ZipObjects============
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant2 310: _Table.ZipObjects
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===========_Table.ZipObjects============
  _Table.ZipObjects(Ks, Rows, Acc) =
    Rows -> [Row, ...Rest] ?
    _Table.ZipObjects(Ks, Rest, [...Acc, Array.ZipObject(Ks, Row)]) :
    Acc
  ========================================
  0000    | GetConstant2 257: Row
  0003    | GetConstant 8: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 1
  0008    | Destructure 71: ([Row] + Rest)
  0010    | ConditionalThen 10 -> 44
  0013    | GetConstant2 310: _Table.ZipObjects
  0016    | GetBoundLocal 0
  0018    | GetBoundLocal 4
  0020    | PushEmptyArray
  0021    | GetBoundLocal 2
  0023    | Merge
  0024    | GetConstant2 311: [_]
  0027    | GetConstant2 312: Array.ZipObject
  0030    | GetBoundLocal 0
  0032    | GetBoundLocal 3
  0034    | CallFunction 2
  0036    | InsertAtIndex 0
  0038    | Merge
  0039    | CallTailFunction 3
  0041    | Jump 41 -> 46
  0044    | GetBoundLocal 2
  0046    | End
  ========================================
  
  ============Array.ZipObject=============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant2 313: _Array.ZipObject
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyObject
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.ZipObject============
  _Array.ZipObject(Ks, Vs, Acc) =
    Ks -> [K, ...KsRest] & Vs -> [V, ...VsRest] ?
    _Array.ZipObject(KsRest, VsRest, {...Acc, K: V}) :
    Acc
  ========================================
  0000    | PushCharVar K
  0002    | GetConstant2 314: KsRest
  0005    | PushCharVar V
  0007    | GetConstant2 315: VsRest
  0010    | SetInputMark
  0011    | GetBoundLocal 0
  0013    | Destructure 72: ([K] + KsRest)
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocal 1
  0020    | Destructure 73: ([V] + VsRest)
  0022    | ConditionalThen 22 -> 51
  0025    | GetConstant2 313: _Array.ZipObject
  0028    | GetBoundLocal 4
  0030    | GetBoundLocal 6
  0032    | PushEmptyObject
  0033    | GetBoundLocal 2
  0035    | Merge
  0036    | GetConstant2 316: {_0_}
  0039    | GetBoundLocal 3
  0041    | GetBoundLocal 5
  0043    | InsertKeyVal 0
  0045    | Merge
  0046    | CallTailFunction 3
  0048    | Jump 48 -> 53
  0051    | GetBoundLocal 2
  0053    | End
  ========================================
  
  ==============Array.First===============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushCharVar F
  0002    | PushUnderscoreVar
  0003    | GetBoundLocal 0
  0005    | Destructure 74: ([F] + _)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocal 1
  0012    | End
  ========================================
  
  ============_escaped_unicode============
  _escaped_unicode = _escaped_surrogate_pair | _escaped_codepoint
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 317: _escaped_surrogate_pair
  0004    | Or 4 -> 10
  0007    | CallTailFunctionConstant2 318: _escaped_codepoint
  0010    | End
  ========================================
  
  ========_escaped_surrogate_pair=========
  _escaped_surrogate_pair = _valid_surrogate_pair | _invalid_surrogate_pair
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 319: _valid_surrogate_pair
  0004    | Or 4 -> 10
  0007    | CallTailFunctionConstant2 320: _invalid_surrogate_pair
  0010    | End
  ========================================
  
  =========_valid_surrogate_pair==========
  _valid_surrogate_pair =
    _high_surrogate -> H & _low_surrogate -> L $ @SurrogatePairCodepoint(H, L)
  ========================================
  0000    | PushCharVar H
  0002    | PushCharVar L
  0004    | CallFunctionConstant2 321: _high_surrogate
  0007    | Destructure 75: H
  0009    | TakeRight 9 -> 29
  0012    | CallFunctionConstant2 322: _low_surrogate
  0015    | Destructure 76: L
  0017    | TakeRight 17 -> 29
  0020    | GetConstant2 323: @SurrogatePairCodepoint
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | CallTailFunction 2
  0029    | End
  ========================================
  
  ============_high_surrogate=============
  _high_surrogate =
    `\u` > ("D" | "d") + ("8" | "9" | "A" | "B" | "a" | "b") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 107: "\u"
  0002    | TakeRight 2 -> 13
  0005    | SetInputMark
  0006    | ParseChar 'D'
  0008    | Or 8 -> 13
  0011    | ParseChar 'd'
  0013    | SetInputMark
  0014    | ParseChar '8'
  0016    | Or 16 -> 45
  0019    | SetInputMark
  0020    | ParseChar '9'
  0022    | Or 22 -> 45
  0025    | SetInputMark
  0026    | ParseChar 'A'
  0028    | Or 28 -> 45
  0031    | SetInputMark
  0032    | ParseChar 'B'
  0034    | Or 34 -> 45
  0037    | SetInputMark
  0038    | ParseChar 'a'
  0040    | Or 40 -> 45
  0043    | ParseChar 'b'
  0045    | Merge
  0046    | CallFunctionConstant 108: hex_numeral
  0048    | Merge
  0049    | CallFunctionConstant 108: hex_numeral
  0051    | Merge
  0052    | End
  ========================================
  
  =============_low_surrogate=============
  _low_surrogate =
    `\u` > ("D" | "d") + ("C".."F" | "c".."f") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 107: "\u"
  0002    | TakeRight 2 -> 13
  0005    | SetInputMark
  0006    | ParseChar 'D'
  0008    | Or 8 -> 13
  0011    | ParseChar 'd'
  0013    | SetInputMark
  0014    | ParseCodepointRange 'C'..'F'
  0017    | Or 17 -> 23
  0020    | ParseCodepointRange 'c'..'f'
  0023    | Merge
  0024    | CallFunctionConstant 108: hex_numeral
  0026    | Merge
  0027    | CallFunctionConstant 108: hex_numeral
  0029    | Merge
  0030    | End
  ========================================
  
  ========_invalid_surrogate_pair=========
  _invalid_surrogate_pair = _low_surrogate | _high_surrogate $ "\u00FFFD"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 322: _low_surrogate
  0004    | Or 4 -> 10
  0007    | CallFunctionConstant2 321: _high_surrogate
  0010    | TakeRight 10 -> 16
  0013    | GetConstant2 324: "\xef\xbf\xbd" (esc)
  0016    | End
  ========================================
  
  ===========_escaped_codepoint===========
  _escaped_codepoint = `\u` > (hex_numeral * 4) -> U $ @Codepoint(U)
  ========================================
  0000    | PushCharVar U
  0002    | CallFunctionConstant 107: "\u"
  0004    | TakeRight 4 -> 31
  0007    | PushNull
  0008    | PushNumber 4
  0010    | ValidateRepeatPattern
  0011    | JumpIfZero 11 -> 30
  0014    | Swap
  0015    | CallFunctionConstant 108: hex_numeral
  0017    | Merge
  0018    | JumpIfFailure 18 -> 29
  0021    | Swap
  0022    | Decrement
  0023    | JumpIfZero 23 -> 30
  0026    | JumpBack 26 -> 14
  0029    | Swap
  0030    | Drop
  0031    | Destructure 77: U
  0033    | TakeRight 33 -> 42
  0036    | GetConstant 109: @Codepoint
  0038    | GetBoundLocal 0
  0040    | CallTailFunction 1
  0042    | End
  ========================================
  
  ===============Str.Length===============
  Str.Length(S) = S -> ("\u000000".. * L) $ L
  ========================================
  0000    | PushCharVar L
  0002    | GetBoundLocal 0
  0004    | Destructure 78: ("\x00".. * L) (esc)
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocal 1
  0011    | End
  ========================================
  
  =================@fn308=================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 326: alnum
  0004    | Or 4 -> 15
  0007    | SetInputMark
  0008    | ParseChar '_'
  0010    | Or 10 -> 15
  0013    | ParseChar '-'
  0015    | End
  ========================================
  
  ==================word==================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant2 325: @fn308
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn310=================
  _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | CallFunctionConstant2 256: _number_integer_part
  0003    | GetConstant 0: maybe
  0005    | GetConstant2 269: _number_fraction_part
  0008    | CallFunction 1
  0010    | Merge
  0011    | GetConstant 0: maybe
  0013    | GetConstant2 270: _number_exponent_part
  0016    | CallFunction 1
  0018    | Merge
  0019    | End
  ========================================
  
  ==========non_negative_number===========
  non_negative_number = as_number(
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 327: @fn310
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ==============json.string===============
  json.string = '"' > _json.string_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 8
  0005    | CallFunctionConstant2 328: _json.string_body
  0008    | JumpIfFailure 8 -> 14
  0011    | ParseChar '"'
  0013    | TakeLeft
  0014    | End
  ========================================
  
  =================@fn314=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 99: _ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  =================@fn313=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 330: _escaped_ctrl_char
  0004    | Or 4 -> 23
  0007    | SetInputMark
  0008    | CallFunctionConstant2 331: _escaped_unicode
  0011    | Or 11 -> 23
  0014    | GetConstant 35: unless
  0016    | GetConstant 34: char
  0018    | GetConstant2 332: @fn314
  0021    | CallTailFunction 2
  0023    | End
  ========================================
  
  ===========_json.string_body============
  _json.string_body =
    many(
      _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
    ) | const($"")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 45: many
  0003    | GetConstant2 329: @fn313
  0006    | CallFunction 1
  0008    | Or 8 -> 16
  0011    | GetConstant 4: const
  0013    | PushEmptyString
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ================Obj.Keys================
  Obj.Keys(O) = _Obj.Keys(O, [])
  ========================================
  0000    | GetConstant2 264: _Obj.Keys
  0003    | GetBoundLocal 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============Array.ZipPairs=============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant2 333: _Array.ZipPairs
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.ZipPairs=============
  _Array.ZipPairs(A1, A2, Acc) =
    A1 -> [First1, ...Rest1] & A2 -> [First2, ...Rest2] ?
    _Array.ZipPairs(Rest1, Rest2, [...Acc, [First1, First2]]) :
    Acc
  ========================================
  0000    | GetConstant2 334: First1
  0003    | GetConstant2 335: Rest1
  0006    | GetConstant2 336: First2
  0009    | GetConstant2 337: Rest2
  0012    | SetInputMark
  0013    | GetBoundLocal 0
  0015    | Destructure 79: ([First1] + Rest1)
  0017    | TakeRight 17 -> 24
  0020    | GetBoundLocal 1
  0022    | Destructure 80: ([First2] + Rest2)
  0024    | ConditionalThen 24 -> 60
  0027    | GetConstant2 333: _Array.ZipPairs
  0030    | GetBoundLocal 4
  0032    | GetBoundLocal 6
  0034    | PushEmptyArray
  0035    | GetBoundLocal 2
  0037    | Merge
  0038    | GetConstant2 338: [_]
  0041    | GetConstant2 339: [_, _]
  0044    | GetBoundLocal 3
  0046    | InsertAtIndex 0
  0048    | GetBoundLocal 5
  0050    | InsertAtIndex 1
  0052    | InsertAtIndex 0
  0054    | Merge
  0055    | CallTailFunction 3
  0057    | Jump 57 -> 62
  0060    | GetBoundLocal 2
  0062    | End
  ========================================
  
  =======_ast.with_precedence_rest========
  _ast.with_precedence_rest(operand, prefix, infix, postfix, LeftBindingPower, Node) =
    postfix -> {"power": RightBindingPower, ...PostfixNode} &
    const(Is.LessThan(LeftBindingPower, RightBindingPower)) ? (
      _ast.with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        {...PostfixNode, "postfixed": Node, ..._Ast.MergePos(Node, PostfixNode)}
      )
    ) :
    infix -> {"power": [RightBindingPower, NextLeftBindingPower], ...InfixNode} &
    const(Is.LessThan(LeftBindingPower, RightBindingPower)) ? (
      _ast.with_precedence_start(
        operand, prefix, infix, postfix,
        NextLeftBindingPower
      ) -> RightNode &
      _ast.with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        {...InfixNode, "left": Node, "right": RightNode, ..._Ast.MergePos(Node, RightNode)}
      )
    ) :
    const(Node)
  ========================================
  0000    | GetConstant2 340: RightBindingPower
  0003    | GetConstant2 341: PostfixNode
  0006    | GetConstant2 342: NextLeftBindingPower
  0009    | GetConstant2 343: InfixNode
  0012    | GetConstant2 344: RightNode
  0015    | SetInputMark
  0016    | CallFunctionLocal 3
  0018    | Destructure 81: ({"power": RightBindingPower} + PostfixNode)
  0020    | TakeRight 20 -> 36
  0023    | GetConstant 4: const
  0025    | GetConstant2 345: Is.LessThan
  0028    | GetBoundLocal 4
  0030    | GetBoundLocal 6
  0032    | CallFunction 2
  0034    | CallFunction 1
  0036    | ConditionalThen 36 -> 82
  0039    | GetConstant2 346: _ast.with_precedence_rest
  0042    | GetBoundLocal 0
  0044    | GetBoundLocal 1
  0046    | GetBoundLocal 2
  0048    | GetBoundLocal 3
  0050    | GetBoundLocal 4
  0052    | PushEmptyObject
  0053    | GetBoundLocal 7
  0055    | Merge
  0056    | GetConstant2 347: {_0_}
  0059    | GetConstant2 348: "postfixed"
  0062    | GetBoundLocal 5
  0064    | InsertKeyVal 0
  0066    | GetConstant2 349: _Ast.MergePos
  0069    | GetBoundLocal 5
  0071    | GetBoundLocal 7
  0073    | CallFunction 2
  0075    | Merge
  0076    | Merge
  0077    | CallTailFunction 6
  0079    | Jump 79 -> 182
  0082    | SetInputMark
  0083    | CallFunctionLocal 2
  0085    | Destructure 82: ({"power": [RightBindingPower, NextLeftBindingPower]} + InfixNode)
  0087    | TakeRight 87 -> 103
  0090    | GetConstant 4: const
  0092    | GetConstant2 345: Is.LessThan
  0095    | GetBoundLocal 4
  0097    | GetBoundLocal 6
  0099    | CallFunction 2
  0101    | CallFunction 1
  0103    | ConditionalThen 103 -> 176
  0106    | GetConstant2 350: _ast.with_precedence_start
  0109    | GetBoundLocal 0
  0111    | GetBoundLocal 1
  0113    | GetBoundLocal 2
  0115    | GetBoundLocal 3
  0117    | GetBoundLocal 8
  0119    | CallFunction 5
  0121    | Destructure 83: RightNode
  0123    | TakeRight 123 -> 173
  0126    | GetConstant2 346: _ast.with_precedence_rest
  0129    | GetBoundLocal 0
  0131    | GetBoundLocal 1
  0133    | GetBoundLocal 2
  0135    | GetBoundLocal 3
  0137    | GetBoundLocal 4
  0139    | PushEmptyObject
  0140    | GetBoundLocal 9
  0142    | Merge
  0143    | GetConstant2 351: {_0_, _1_}
  0146    | GetConstant2 352: "left"
  0149    | GetBoundLocal 5
  0151    | InsertKeyVal 0
  0153    | GetConstant2 353: "right"
  0156    | GetBoundLocal 10
  0158    | InsertKeyVal 1
  0160    | GetConstant2 349: _Ast.MergePos
  0163    | GetBoundLocal 5
  0165    | GetBoundLocal 10
  0167    | CallFunction 2
  0169    | Merge
  0170    | Merge
  0171    | CallTailFunction 6
  0173    | Jump 173 -> 182
  0176    | GetConstant 4: const
  0178    | GetBoundLocal 5
  0180    | CallTailFunction 1
  0182    | End
  ========================================
  
  =============_Ast.MergePos==============
  _Ast.MergePos(Left, Right) = {
    ...(Left -> {"startpos": StartPos, ..._} ? {"startpos": StartPos} : {}),
    ...(Right -> {"endpos": EndPos, ..._} ? {"endpos": EndPos} : {}),
  }
  ========================================
  0000    | GetConstant2 354: StartPos
  0003    | PushUnderscoreVar
  0004    | GetConstant2 355: EndPos
  0007    | PushEmptyObject
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 84: ({"startpos": StartPos} + _)
  0013    | ConditionalThen 13 -> 29
  0016    | GetConstant2 356: {_0_}
  0019    | GetConstant2 357: "startpos"
  0022    | GetBoundLocal 2
  0024    | InsertKeyVal 0
  0026    | Jump 26 -> 30
  0029    | PushEmptyObject
  0030    | Merge
  0031    | SetInputMark
  0032    | GetBoundLocal 1
  0034    | Destructure 85: ({"endpos": EndPos} + _)
  0036    | ConditionalThen 36 -> 52
  0039    | GetConstant2 358: {_0_}
  0042    | GetConstant2 359: "endpos"
  0045    | GetBoundLocal 4
  0047    | InsertKeyVal 0
  0049    | Jump 49 -> 53
  0052    | PushEmptyObject
  0053    | Merge
  0054    | End
  ========================================
  
  =======_ast.with_precedence_start=======
  _ast.with_precedence_start(operand, prefix, infix, postfix, LeftBindingPower) =
    prefix -> {"power": PrefixBindingPower, ...PrefixNode} ? (
      _ast.with_precedence_start(
        operand, prefix, infix, postfix,
        PrefixBindingPower
      ) -> Node &
      _ast.with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        {...PrefixNode, "prefixed": Node, ..._Ast.MergePos(PrefixNode, Node)}
      )
    ) : (
      operand -> Node &
      _ast.with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        Node
      )
    )
  ========================================
  0000    | GetConstant2 360: PrefixBindingPower
  0003    | GetConstant2 361: PrefixNode
  0006    | GetConstant2 362: Node
  0009    | SetInputMark
  0010    | CallFunctionLocal 1
  0012    | Destructure 86: ({"power": PrefixBindingPower} + PrefixNode)
  0014    | ConditionalThen 14 -> 80
  0017    | GetConstant2 350: _ast.with_precedence_start
  0020    | GetBoundLocal 0
  0022    | GetBoundLocal 1
  0024    | GetBoundLocal 2
  0026    | GetBoundLocal 3
  0028    | GetBoundLocal 5
  0030    | CallFunction 5
  0032    | Destructure 87: Node
  0034    | TakeRight 34 -> 77
  0037    | GetConstant2 346: _ast.with_precedence_rest
  0040    | GetBoundLocal 0
  0042    | GetBoundLocal 1
  0044    | GetBoundLocal 2
  0046    | GetBoundLocal 3
  0048    | GetBoundLocal 4
  0050    | PushEmptyObject
  0051    | GetBoundLocal 6
  0053    | Merge
  0054    | GetConstant2 363: {_0_}
  0057    | GetConstant2 364: "prefixed"
  0060    | GetBoundLocal 7
  0062    | InsertKeyVal 0
  0064    | GetConstant2 349: _Ast.MergePos
  0067    | GetBoundLocal 6
  0069    | GetBoundLocal 7
  0071    | CallFunction 2
  0073    | Merge
  0074    | Merge
  0075    | CallTailFunction 6
  0077    | Jump 77 -> 104
  0080    | CallFunctionLocal 0
  0082    | Destructure 88: Node
  0084    | TakeRight 84 -> 104
  0087    | GetConstant2 346: _ast.with_precedence_rest
  0090    | GetBoundLocal 0
  0092    | GetBoundLocal 1
  0094    | GetBoundLocal 2
  0096    | GetBoundLocal 3
  0098    | GetBoundLocal 4
  0100    | GetBoundLocal 7
  0102    | CallTailFunction 6
  0104    | End
  ========================================
  
  =================@fn330=================
  find_before(p, stop)
  ========================================
  0000    | PushCharVar p
  0002    | GetConstant2 367: stop
  0005    | SetClosureCaptures
  0006    | GetConstant2 368: find_before
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  =================@fn332=================
  chars_until(stop)
  ========================================
  0000    | GetConstant2 367: stop
  0003    | SetClosureCaptures
  0004    | GetConstant 29: chars_until
  0006    | GetBoundLocal 0
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ============find_all_before=============
  find_all_before(p, stop) = array(find_before(p, stop)) < maybe(chars_until(stop))
  ========================================
  0000    | GetConstant2 365: array
  0003    | GetConstant2 366: @fn330
  0006    | CreateClosure 2
  0008    | CaptureLocal 0
  0010    | CaptureLocal 1
  0012    | CallFunction 1
  0014    | JumpIfFailure 14 -> 29
  0017    | GetConstant 0: maybe
  0019    | GetConstant2 369: @fn332
  0022    | CreateClosure 1
  0024    | CaptureLocal 1
  0026    | CallFunction 1
  0028    | TakeLeft
  0029    | End
  ========================================
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 54: tuple1
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 43
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 6
  0025    | Swap
  0026    | SetInputMark
  0027    | GetConstant 54: tuple1
  0029    | GetBoundLocal 0
  0031    | CallFunction 1
  0033    | JumpIfFailure 33 -> 41
  0036    | PopInputMark
  0037    | Merge
  0038    | JumpBack 38 -> 26
  0041    | ResetInput
  0042    | Drop
  0043    | Swap
  0044    | Drop
  0045    | End
  ========================================
  
  ==============find_before===============
  find_before(p, stop) = stop ? @fail : p | (char > find_before(p, stop))
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 37: @fail
  0008    | Jump 8 -> 31
  0011    | SetInputMark
  0012    | CallFunctionLocal 0
  0014    | Or 14 -> 31
  0017    | CallFunctionConstant 34: char
  0019    | TakeRight 19 -> 31
  0022    | GetConstant2 368: find_before
  0025    | GetBoundLocal 0
  0027    | GetBoundLocal 1
  0029    | CallTailFunction 2
  0031    | End
  ========================================
  
  ==========_toml.no_root_table===========
  _toml.no_root_table(value) =
    _toml.table(value, _Toml.Doc.Empty) | _toml.array_of_tables(value, _Toml.Doc.Empty) -> NewDoc &
    _toml.tables(value, NewDoc)
  ========================================
  0000    | GetConstant 75: NewDoc
  0002    | SetInputMark
  0003    | GetConstant 135: _toml.table
  0005    | GetBoundLocal 0
  0007    | CallFunctionConstant 69: _Toml.Doc.Empty
  0009    | CallFunction 2
  0011    | Or 11 -> 22
  0014    | GetConstant 136: _toml.array_of_tables
  0016    | GetBoundLocal 0
  0018    | CallFunctionConstant 69: _Toml.Doc.Empty
  0020    | CallFunction 2
  0022    | Destructure 89: NewDoc
  0024    | TakeRight 24 -> 35
  0027    | GetConstant 71: _toml.tables
  0029    | GetBoundLocal 0
  0031    | GetBoundLocal 1
  0033    | CallTailFunction 2
  0035    | End
  ========================================
  
  =============_Array.Filter==============
  _Array.Filter(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Filter(Rest, Pred, Pred(First) ? [...Acc, First] : Acc) :
    Acc
  ========================================
  0000    | GetConstant 15: First
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 90: ([First] + Rest)
  0009    | ConditionalThen 9 -> 51
  0012    | GetConstant2 370: _Array.Filter
  0015    | GetBoundLocal 4
  0017    | GetBoundLocal 1
  0019    | SetInputMark
  0020    | GetBoundLocal 1
  0022    | GetBoundLocal 3
  0024    | CallFunction 1
  0026    | ConditionalThen 26 -> 44
  0029    | PushEmptyArray
  0030    | GetBoundLocal 2
  0032    | Merge
  0033    | GetConstant2 371: [_]
  0036    | GetBoundLocal 3
  0038    | InsertAtIndex 0
  0040    | Merge
  0041    | Jump 41 -> 46
  0044    | GetBoundLocal 2
  0046    | CallTailFunction 3
  0048    | Jump 48 -> 53
  0051    | GetBoundLocal 2
  0053    | End
  ========================================
  
  ================Is.Array================
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 91: ([] + _)
  0005    | End
  ========================================
  
  =================tuple2=================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 18: E1
  0002    | GetConstant 19: E2
  0004    | CallFunctionLocal 0
  0006    | Destructure 92: E1
  0008    | TakeRight 8 -> 29
  0011    | CallFunctionLocal 1
  0013    | Destructure 93: E2
  0015    | TakeRight 15 -> 29
  0018    | GetConstant2 372: [_, _]
  0021    | GetBoundLocal 2
  0023    | InsertAtIndex 0
  0025    | GetBoundLocal 3
  0027    | InsertAtIndex 1
  0029    | End
  ========================================
  
  =============Array.MapMerge=============
  Array.MapMerge(A, Fn) = _Array.MapMerge(A, Fn, null)
  ========================================
  0000    | GetConstant2 373: _Array.MapMerge
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushNull
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.MapMerge=============
  _Array.MapMerge(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.MapMerge(Rest, Fn, Acc + Fn(First)) : Acc
  ========================================
  0000    | GetConstant 15: First
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 94: ([First] + Rest)
  0009    | ConditionalThen 9 -> 33
  0012    | GetConstant2 373: _Array.MapMerge
  0015    | GetBoundLocal 4
  0017    | GetBoundLocal 1
  0019    | GetBoundLocal 2
  0021    | GetBoundLocal 1
  0023    | GetBoundLocal 3
  0025    | CallFunction 1
  0027    | Merge
  0028    | CallTailFunction 3
  0030    | Jump 30 -> 35
  0033    | GetBoundLocal 2
  0035    | End
  ========================================
  
  =================@fn342=================
  array(elem)
  ========================================
  0000    | GetConstant 56: elem
  0002    | SetClosureCaptures
  0003    | GetConstant2 365: array
  0006    | GetBoundLocal 0
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ==============maybe_array===============
  maybe_array(elem) = default(array(elem), [])
  ========================================
  0000    | GetConstant 111: default
  0002    | GetConstant2 374: @fn342
  0005    | CreateClosure 1
  0007    | CaptureLocal 0
  0009    | PushEmptyArray
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  =================@fn344=================
  maybe("-") +
    _number_integer_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | CallFunctionConstant2 256: _number_integer_part
  0009    | Merge
  0010    | CallFunctionConstant2 270: _number_exponent_part
  0013    | Merge
  0014    | End
  ========================================
  
  ===========scientific_integer===========
  scientific_integer = as_number(
    maybe("-") +
    _number_integer_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 375: @fn344
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================alphas=================
  alphas = many(alpha)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant 90: alpha
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============ast.infix_node=============
  ast.infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    op $ {"type": Type, "power": [LeftBindingPower, RightBindingPower]}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 30
  0005    | GetConstant2 376: {_0_, _1_}
  0008    | GetConstant 129: "type"
  0010    | GetBoundLocal 1
  0012    | InsertKeyVal 0
  0014    | GetConstant2 263: "power"
  0017    | GetConstant2 377: [_, _]
  0020    | GetBoundLocal 2
  0022    | InsertAtIndex 0
  0024    | GetBoundLocal 3
  0026    | InsertAtIndex 1
  0028    | InsertKeyVal 1
  0030    | End
  ========================================
  
  ==============_Obj.Values===============
  _Obj.Values(O, Acc) = O -> {_: V, ...Rest} ? _Obj.Values(Rest, [...Acc, V]) : Acc
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar V
  0003    | GetConstant 8: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 95: ({_: V} + Rest)
  0010    | ConditionalThen 10 -> 35
  0013    | GetConstant2 378: _Obj.Values
  0016    | GetBoundLocal 4
  0018    | PushEmptyArray
  0019    | GetBoundLocal 1
  0021    | Merge
  0022    | GetConstant2 379: [_]
  0025    | GetBoundLocal 3
  0027    | InsertAtIndex 0
  0029    | Merge
  0030    | CallTailFunction 2
  0032    | Jump 32 -> 37
  0035    | GetBoundLocal 1
  0037    | End
  ========================================
  
  ==========ast.with_offset_pos===========
  ast.with_offset_pos(node) =
    @input.offset -> StartOffset &
    node -> Node &
    @input.offset -> EndOffset $
    {...Node, "startpos": StartOffset, "endpos": EndOffset}
  ========================================
  0000    | GetConstant2 380: StartOffset
  0003    | GetConstant2 362: Node
  0006    | GetConstant2 381: EndOffset
  0009    | CallFunctionConstant 39: @input.offset
  0011    | Destructure 96: StartOffset
  0013    | TakeRight 13 -> 20
  0016    | CallFunctionLocal 0
  0018    | Destructure 97: Node
  0020    | TakeRight 20 -> 52
  0023    | CallFunctionConstant 39: @input.offset
  0025    | Destructure 98: EndOffset
  0027    | TakeRight 27 -> 52
  0030    | PushEmptyObject
  0031    | GetBoundLocal 2
  0033    | Merge
  0034    | GetConstant2 382: {_0_, _1_}
  0037    | GetConstant2 357: "startpos"
  0040    | GetBoundLocal 1
  0042    | InsertKeyVal 0
  0044    | GetConstant2 359: "endpos"
  0047    | GetBoundLocal 3
  0049    | InsertKeyVal 1
  0051    | Merge
  0052    | End
  ========================================
  
  =================@fn354=================
  find(p)
  ========================================
  0000    | PushCharVar p
  0002    | SetClosureCaptures
  0003    | GetConstant2 384: find
  0006    | GetBoundLocal 0
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  =================@fn356=================
  many(char)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant 34: char
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================find_all================
  find_all(p) = array(find(p)) < maybe(many(char))
  ========================================
  0000    | GetConstant2 365: array
  0003    | GetConstant2 383: @fn354
  0006    | CreateClosure 1
  0008    | CaptureLocal 0
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 23
  0015    | GetConstant 0: maybe
  0017    | GetConstant2 385: @fn356
  0020    | CallFunction 1
  0022    | TakeLeft
  0023    | End
  ========================================
  
  ==================find==================
  find(p) = p | (char > find(p))
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 18
  0006    | CallFunctionConstant 34: char
  0008    | TakeRight 8 -> 18
  0011    | GetConstant2 384: find
  0014    | GetBoundLocal 0
  0016    | CallTailFunction 1
  0018    | End
  ========================================
  
  ===============object_sep===============
  object_sep(key, kv_sep, value, sep) =
    pair_sep(key, kv_sep, value) +
    ((sep > pair_sep(key, kv_sep, value)) * 0..)
  ========================================
  0000    | GetConstant2 386: pair_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | CallFunction 3
  0011    | PushNull
  0012    | PushNumberZero
  0013    | ValidateRepeatPattern
  0014    | JumpIfZero 14 -> 46
  0017    | Swap
  0018    | CallFunctionLocal 3
  0020    | TakeRight 20 -> 34
  0023    | GetConstant2 386: pair_sep
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | GetBoundLocal 2
  0032    | CallFunction 3
  0034    | Merge
  0035    | JumpIfFailure 35 -> 74
  0038    | Swap
  0039    | Decrement
  0040    | JumpIfZero 40 -> 46
  0043    | JumpBack 43 -> 17
  0046    | Swap
  0047    | SetInputMark
  0048    | CallFunctionLocal 3
  0050    | TakeRight 50 -> 64
  0053    | GetConstant2 386: pair_sep
  0056    | GetBoundLocal 0
  0058    | GetBoundLocal 1
  0060    | GetBoundLocal 2
  0062    | CallFunction 3
  0064    | JumpIfFailure 64 -> 72
  0067    | PopInputMark
  0068    | Merge
  0069    | JumpBack 69 -> 47
  0072    | ResetInput
  0073    | Drop
  0074    | Swap
  0075    | Drop
  0076    | Merge
  0077    | End
  ========================================
  
  =============octal_integer==============
  octal_integer = array(octal_digit) -> Digits $ Num.FromOctalDigits(Digits)
  ========================================
  0000    | GetConstant 195: Digits
  0002    | GetConstant2 365: array
  0005    | GetConstant 212: octal_digit
  0007    | CallFunction 1
  0009    | Destructure 99: Digits
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 214: Num.FromOctalDigits
  0016    | GetBoundLocal 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  =============maybe_many_sep=============
  maybe_many_sep(p, sep) = many_sep(p, sep) | succeed
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 25: many_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | Or 9 -> 14
  0012    | CallTailFunctionConstant 3: succeed
  0014    | End
  ========================================
  
  ===============Array.Map================
  Array.Map(A, Fn) = _Array.Map(A, Fn, [])
  ========================================
  0000    | GetConstant 16: _Array.Map
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | PushEmptyArray
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  =========Table.RotateClockwise==========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant2 387: Array.Map
  0003    | GetConstant2 274: Table.Transpose
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | GetConstant2 304: Array.Reverse
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ===============_toml.tag================
  _toml.tag(Type, Subtype, value) =
    value -> Value $ {"type": Type, "subtype": Subtype, "value": Value}
  ========================================
  0000    | GetConstant2 388: Value
  0003    | CallFunctionLocal 2
  0005    | Destructure 100: Value
  0007    | TakeRight 7 -> 32
  0010    | GetConstant2 389: {_0_, _1_, _2_}
  0013    | GetConstant 129: "type"
  0015    | GetBoundLocal 0
  0017    | InsertKeyVal 0
  0019    | GetConstant2 390: "subtype"
  0022    | GetBoundLocal 1
  0024    | InsertKeyVal 1
  0026    | GetConstant 12: "value"
  0028    | GetBoundLocal 3
  0030    | InsertKeyVal 2
  0032    | End
  ========================================
  
  ===========ast.with_line_pos============
  ast.with_line_pos(node) =
    @input.line -> StartLine &
    @input.line_offset -> StartLineOffset &
    node -> Node &
    @input.line -> EndLine &
    @input.line_offset -> EndLineOffset $
    {
      ...Node,
      "startpos": {"line": StartLine, "offset": StartLineOffset},
      "endpos": {"line": EndLine, "offset": EndLineOffset},
    }
  ========================================
  0000    | GetConstant2 391: StartLine
  0003    | GetConstant2 392: StartLineOffset
  0006    | GetConstant2 362: Node
  0009    | GetConstant2 393: EndLine
  0012    | GetConstant2 394: EndLineOffset
  0015    | CallFunctionConstant2 395: @input.line
  0018    | Destructure 101: StartLine
  0020    | TakeRight 20 -> 28
  0023    | CallFunctionConstant2 396: @input.line_offset
  0026    | Destructure 102: StartLineOffset
  0028    | TakeRight 28 -> 35
  0031    | CallFunctionLocal 0
  0033    | Destructure 103: Node
  0035    | TakeRight 35 -> 43
  0038    | CallFunctionConstant2 395: @input.line
  0041    | Destructure 104: EndLine
  0043    | TakeRight 43 -> 106
  0046    | CallFunctionConstant2 396: @input.line_offset
  0049    | Destructure 105: EndLineOffset
  0051    | TakeRight 51 -> 106
  0054    | PushEmptyObject
  0055    | GetBoundLocal 3
  0057    | Merge
  0058    | GetConstant2 397: {_0_, _1_}
  0061    | GetConstant2 357: "startpos"
  0064    | GetConstant2 398: {_0_, _1_}
  0067    | GetConstant2 399: "line"
  0070    | GetBoundLocal 1
  0072    | InsertKeyVal 0
  0074    | GetConstant2 400: "offset"
  0077    | GetBoundLocal 2
  0079    | InsertKeyVal 1
  0081    | InsertKeyVal 0
  0083    | GetConstant2 359: "endpos"
  0086    | GetConstant2 401: {_0_, _1_}
  0089    | GetConstant2 399: "line"
  0092    | GetBoundLocal 4
  0094    | InsertKeyVal 0
  0096    | GetConstant2 400: "offset"
  0099    | GetBoundLocal 5
  0101    | InsertKeyVal 1
  0103    | InsertKeyVal 1
  0105    | Merge
  0106    | End
  ========================================
  
  =================@fn369=================
  object(key, value)
  ========================================
  0000    | GetConstant2 403: key
  0003    | GetConstant 144: value
  0005    | SetClosureCaptures
  0006    | GetConstant2 404: object
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ==============maybe_object==============
  maybe_object(key, value) = default(object(key, value), {})
  ========================================
  0000    | GetConstant 111: default
  0002    | GetConstant2 402: @fn369
  0005    | CreateClosure 2
  0007    | CaptureLocal 0
  0009    | CaptureLocal 1
  0011    | PushEmptyObject
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 28
  0006    | Swap
  0007    | GetConstant2 405: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 49
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 6
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant2 405: pair
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | CallFunction 2
  0039    | JumpIfFailure 39 -> 47
  0042    | PopInputMark
  0043    | Merge
  0044    | JumpBack 44 -> 29
  0047    | ResetInput
  0048    | Drop
  0049    | Swap
  0050    | Drop
  0051    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 106: K
  0008    | TakeRight 8 -> 27
  0011    | CallFunctionLocal 1
  0013    | Destructure 107: V
  0015    | TakeRight 15 -> 27
  0018    | GetConstant2 406: {_0_}
  0021    | GetBoundLocal 2
  0023    | GetBoundLocal 3
  0025    | InsertKeyVal 0
  0027    | End
  ========================================
  
  ==============toml.simple===============
  toml.simple = toml.custom(toml.simple_value)
  ========================================
  0000    | GetConstant2 407: toml.custom
  0003    | GetConstant 161: toml.simple_value
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn375=================
  _toml.comments + maybe(ws)
  ========================================
  0000    | CallFunctionConstant2 410: _toml.comments
  0003    | GetConstant 0: maybe
  0005    | GetConstant 27: whitespace
  0007    | CallFunction 1
  0009    | Merge
  0010    | End
  ========================================
  
  =================@fn376=================
  maybe(ws) + _toml.comments
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallFunction 1
  0006    | CallFunctionConstant2 410: _toml.comments
  0009    | Merge
  0010    | End
  ========================================
  
  ==============toml.custom===============
  toml.custom(value) =
    maybe(_toml.comments + maybe(ws)) &
    _toml.with_root_table(value) | _toml.no_root_table(value) -> Doc &
    maybe(maybe(ws) + _toml.comments) $
    _Toml.Doc.Value(Doc)
  ========================================
  0000    | GetConstant2 408: Doc
  0003    | GetConstant 0: maybe
  0005    | GetConstant2 409: @fn375
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 33
  0013    | SetInputMark
  0014    | GetConstant2 411: _toml.with_root_table
  0017    | GetBoundLocal 0
  0019    | CallFunction 1
  0021    | Or 21 -> 31
  0024    | GetConstant2 412: _toml.no_root_table
  0027    | GetBoundLocal 0
  0029    | CallFunction 1
  0031    | Destructure 108: Doc
  0033    | TakeRight 33 -> 52
  0036    | GetConstant 0: maybe
  0038    | GetConstant2 413: @fn376
  0041    | CallFunction 1
  0043    | TakeRight 43 -> 52
  0046    | GetConstant 126: _Toml.Doc.Value
  0048    | GetBoundLocal 1
  0050    | CallTailFunction 1
  0052    | End
  ========================================
  
  =================@fn378=================
  sep > elem
  ========================================
  0000    | GetConstant 65: sep
  0002    | GetConstant 56: elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  ===============tuple_sep================
  tuple_sep(elem, sep, N) = tuple1(elem) + (tuple1(sep > elem) * (N - 1))
  ========================================
  0000    | GetConstant 54: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | PushNull
  0007    | GetBoundLocal 2
  0009    | PushNumberNegOne
  0010    | Merge
  0011    | ValidateRepeatPattern
  0012    | JumpIfZero 12 -> 42
  0015    | Swap
  0016    | GetConstant 54: tuple1
  0018    | GetConstant2 414: @fn378
  0021    | CreateClosure 2
  0023    | CaptureLocal 1
  0025    | CaptureLocal 0
  0027    | CallFunction 1
  0029    | Merge
  0030    | JumpIfFailure 30 -> 41
  0033    | Swap
  0034    | Decrement
  0035    | JumpIfZero 35 -> 42
  0038    | JumpBack 38 -> 15
  0041    | Swap
  0042    | Drop
  0043    | Merge
  0044    | End
  ========================================
  
  ================Num.Dec=================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant2 415: @Subtract
  0003    | GetBoundLocal 0
  0005    | PushNumberOne
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn383=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn382=================
  surround(json.string, maybe(ws))
  ========================================
  0000    | GetConstant 82: surround
  0002    | GetConstant2 418: json.string
  0005    | GetConstant2 419: @fn383
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =================@fn385=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn384=================
  surround(value, maybe(ws))
  ========================================
  0000    | GetConstant 144: value
  0002    | SetClosureCaptures
  0003    | GetConstant 82: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant2 421: @fn385
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ==============json.object===============
  json.object(value) =
    "{" >
    maybe_object_sep(
      surround(json.string, maybe(ws)), ":",
      surround(value, maybe(ws)), ","
    )
    < "}"
  ========================================
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 24
  0005    | GetConstant2 416: maybe_object_sep
  0008    | GetConstant2 417: @fn382
  0011    | PushChar ':'
  0013    | GetConstant2 420: @fn384
  0016    | CreateClosure 1
  0018    | CaptureLocal 0
  0020    | PushChar ','
  0022    | CallFunction 4
  0024    | JumpIfFailure 24 -> 30
  0027    | ParseChar '}'
  0029    | TakeLeft
  0030    | End
  ========================================
  
  =================@fn386=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | GetConstant2 403: key
  0003    | GetConstant2 423: pair_sep
  0006    | GetConstant 144: value
  0008    | GetConstant 65: sep
  0010    | SetClosureCaptures
  0011    | GetConstant2 424: object_sep
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | GetBoundLocal 3
  0022    | CallTailFunction 4
  0024    | End
  ========================================
  
  ============maybe_object_sep============
  maybe_object_sep(key, pair_sep, value, sep) =
    default(object_sep(key, pair_sep, value, sep), {})
  ========================================
  0000    | GetConstant 111: default
  0002    | GetConstant2 422: @fn386
  0005    | CreateClosure 4
  0007    | CaptureLocal 0
  0009    | CaptureLocal 1
  0011    | CaptureLocal 2
  0013    | CaptureLocal 3
  0015    | PushEmptyObject
  0016    | CallTailFunction 2
  0018    | End
  ========================================
  
  =================@fn388=================
  "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | ParseChar '-'
  0002    | CallFunctionConstant2 256: _number_integer_part
  0005    | Merge
  0006    | GetConstant 0: maybe
  0008    | GetConstant2 269: _number_fraction_part
  0011    | CallFunction 1
  0013    | Merge
  0014    | GetConstant 0: maybe
  0016    | GetConstant2 270: _number_exponent_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | End
  ========================================
  
  ============negative_number=============
  negative_number = as_number(
    "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 425: @fn388
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn390=================
  pair(key, value)
  ========================================
  0000    | GetConstant2 403: key
  0003    | GetConstant 144: value
  0005    | SetClosureCaptures
  0006    | GetConstant2 405: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  =================@fn391=================
  pair(key, value)
  ========================================
  0000    | GetConstant2 403: key
  0003    | GetConstant 144: value
  0005    | SetClosureCaptures
  0006    | GetConstant2 405: pair
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ==============object_until==============
  object_until(key, value, stop) =
    unless(pair(key, value), stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 34
  0006    | Swap
  0007    | GetConstant 35: unless
  0009    | GetConstant2 426: @fn390
  0012    | CreateClosure 2
  0014    | CaptureLocal 0
  0016    | CaptureLocal 1
  0018    | GetBoundLocal 2
  0020    | CallFunction 2
  0022    | Merge
  0023    | JumpIfFailure 23 -> 61
  0026    | Swap
  0027    | Decrement
  0028    | JumpIfZero 28 -> 34
  0031    | JumpBack 31 -> 6
  0034    | Swap
  0035    | SetInputMark
  0036    | GetConstant 35: unless
  0038    | GetConstant2 427: @fn391
  0041    | CreateClosure 2
  0043    | CaptureLocal 0
  0045    | CaptureLocal 1
  0047    | GetBoundLocal 2
  0049    | CallFunction 2
  0051    | JumpIfFailure 51 -> 59
  0054    | PopInputMark
  0055    | Merge
  0056    | JumpBack 56 -> 35
  0059    | ResetInput
  0060    | Drop
  0061    | Swap
  0062    | Drop
  0063    | JumpIfFailure 63 -> 73
  0066    | GetConstant 36: peek
  0068    | GetBoundLocal 2
  0070    | CallFunction 1
  0072    | TakeLeft
  0073    | End
  ========================================
  
  =================lowers=================
  lowers = many(lower)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant2 428: lower
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ==============json.boolean==============
  json.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 241: boolean
  0002    | GetConstant 242: "true"
  0004    | GetConstant 243: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================record1=================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | GetConstant2 388: Value
  0003    | CallFunctionLocal 1
  0005    | Destructure 109: Value
  0007    | TakeRight 7 -> 19
  0010    | GetConstant2 429: {_0_}
  0013    | GetBoundLocal 0
  0015    | GetBoundLocal 2
  0017    | InsertKeyVal 0
  0019    | End
  ========================================
  
  =================@fn397=================
  array_sep(elem, sep)
  ========================================
  0000    | GetConstant 56: elem
  0002    | GetConstant 65: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 58: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 111: default
  0002    | GetConstant2 430: @fn397
  0005    | CreateClosure 2
  0007    | CaptureLocal 0
  0009    | CaptureLocal 1
  0011    | PushEmptyArray
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  ===============_Obj.Size================
  _Obj.Size(O, Acc) = O -> {_: _, ...Rest} ? _Obj.Size(Rest, Acc + 1) : Acc
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 8: Rest
  0003    | SetInputMark
  0004    | GetBoundLocal 0
  0006    | Destructure 110: ({_: _} + Rest)
  0008    | ConditionalThen 8 -> 25
  0011    | GetConstant2 431: _Obj.Size
  0014    | GetBoundLocal 3
  0016    | GetBoundLocal 1
  0018    | PushNumberOne
  0019    | Merge
  0020    | CallTailFunction 2
  0022    | Jump 22 -> 27
  0025    | GetBoundLocal 1
  0027    | End
  ========================================
  
  ================Is.Null=================
  Is.Null(V) = V -> null
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 111: null
  0004    | End
  ========================================
  
  ==============toml.tagged===============
  toml.tagged = toml.custom(toml.tagged_value)
  ========================================
  0000    | GetConstant2 407: toml.custom
  0003    | GetConstant2 432: toml.tagged_value
  0006    | CallTailFunction 1
  0008    | End
  ========================================
  
  ===========toml.tagged_value============
  toml.tagged_value =
    toml.string |
    _toml.tag($"datetime", $"offset", toml.datetime.offset) |
    _toml.tag($"datetime", $"local", toml.datetime.local) |
    _toml.tag($"datetime", $"date-local", toml.datetime.local_date) |
    _toml.tag($"datetime", $"time-local", toml.datetime.local_time) |
    toml.number.binary_integer |
    toml.number.octal_integer |
    toml.number.hex_integer |
    _toml.tag($"float", $"infinity", toml.number.infinity) |
    _toml.tag($"float", $"not-a-number", toml.number.not_a_number) |
    toml.number.float |
    toml.number.integer |
    toml.boolean |
    toml.array(toml.tagged_value) |
    toml.inline_table(toml.tagged_value)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 156: toml.string
  0003    | Or 3 -> 162
  0006    | SetInputMark
  0007    | GetConstant2 433: _toml.tag
  0010    | GetConstant2 434: "datetime"
  0013    | GetConstant2 400: "offset"
  0016    | GetConstant 175: toml.datetime.offset
  0018    | CallFunction 3
  0020    | Or 20 -> 162
  0023    | SetInputMark
  0024    | GetConstant2 433: _toml.tag
  0027    | GetConstant2 434: "datetime"
  0030    | GetConstant2 435: "local"
  0033    | GetConstant 176: toml.datetime.local
  0035    | CallFunction 3
  0037    | Or 37 -> 162
  0040    | SetInputMark
  0041    | GetConstant2 433: _toml.tag
  0044    | GetConstant2 434: "datetime"
  0047    | GetConstant2 436: "date-local"
  0050    | GetConstant 177: toml.datetime.local_date
  0052    | CallFunction 3
  0054    | Or 54 -> 162
  0057    | SetInputMark
  0058    | GetConstant2 433: _toml.tag
  0061    | GetConstant2 434: "datetime"
  0064    | GetConstant2 437: "time-local"
  0067    | GetConstant 178: toml.datetime.local_time
  0069    | CallFunction 3
  0071    | Or 71 -> 162
  0074    | SetInputMark
  0075    | CallFunctionConstant 188: toml.number.binary_integer
  0077    | Or 77 -> 162
  0080    | SetInputMark
  0081    | CallFunctionConstant 189: toml.number.octal_integer
  0083    | Or 83 -> 162
  0086    | SetInputMark
  0087    | CallFunctionConstant 190: toml.number.hex_integer
  0089    | Or 89 -> 162
  0092    | SetInputMark
  0093    | GetConstant2 433: _toml.tag
  0096    | GetConstant2 438: "float"
  0099    | GetConstant2 439: "infinity"
  0102    | GetConstant 191: toml.number.infinity
  0104    | CallFunction 3
  0106    | Or 106 -> 162
  0109    | SetInputMark
  0110    | GetConstant2 433: _toml.tag
  0113    | GetConstant2 438: "float"
  0116    | GetConstant2 440: "not-a-number"
  0119    | GetConstant 192: toml.number.not_a_number
  0121    | CallFunction 3
  0123    | Or 123 -> 162
  0126    | SetInputMark
  0127    | CallFunctionConstant 193: toml.number.float
  0129    | Or 129 -> 162
  0132    | SetInputMark
  0133    | CallFunctionConstant 194: toml.number.integer
  0135    | Or 135 -> 162
  0138    | SetInputMark
  0139    | CallFunctionConstant 159: toml.boolean
  0141    | Or 141 -> 162
  0144    | SetInputMark
  0145    | GetConstant 160: toml.array
  0147    | GetConstant2 432: toml.tagged_value
  0150    | CallFunction 1
  0152    | Or 152 -> 162
  0155    | GetConstant 162: toml.inline_table
  0157    | GetConstant2 432: toml.tagged_value
  0160    | CallTailFunction 1
  0162    | End
  ========================================
  
  =================tuple==================
  tuple(elem, N) = tuple1(elem) * N
  ========================================
  0000    | PushNull
  0001    | GetBoundLocal 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 27
  0007    | Swap
  0008    | GetConstant 54: tuple1
  0010    | GetBoundLocal 0
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
  
  ================Is.Equal================
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 112: B
  0004    | End
  ========================================
  
  ===============As.Number================
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | PushCharVar N
  0002    | SetInputMark
  0003    | GetConstant2 441: Is.Number
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Or 10 -> 22
  0013    | GetBoundLocal 0
  0015    | Destructure 113: "%(0 + N)"
  0017    | TakeRight 17 -> 22
  0020    | GetBoundLocal 1
  0022    | End
  ========================================
  
  ===============Is.Number================
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 114: (0 + _)
  0005    | End
  ========================================
  
  ===========Is.LessThanOrEqual===========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 115: ..B
  0004    | End
  ========================================
  
  =================uppers=================
  uppers = many(upper)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant2 442: upper
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================upper==================
  upper = "A".."Z"
  ========================================
  0000    | ParseCodepointRange 'A'..'Z'
  0003    | End
  ========================================
  
  =================@fn410=================
  maybe(whitespace)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  input(p) = surround(p, maybe(whitespace)) < end_of_input
  ========================================
  0000    | GetConstant 82: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant2 443: @fn410
  0007    | CallFunction 2
  0009    | JumpIfFailure 9 -> 15
  0012    | CallFunctionConstant 32: end_of_input
  0014    | TakeLeft
  0015    | End
  ========================================
  
  ===============Obj.Values===============
  Obj.Values(O) = _Obj.Values(O, [])
  ========================================
  0000    | GetConstant2 378: _Obj.Values
  0003    | GetBoundLocal 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn413=================
  maybe("-") + _number_integer_part + _number_fraction_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | CallFunctionConstant2 256: _number_integer_part
  0009    | Merge
  0010    | CallFunctionConstant2 269: _number_fraction_part
  0013    | Merge
  0014    | End
  ========================================
  
  =================float==================
  float = as_number(maybe("-") + _number_integer_part + _number_fraction_part)
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 444: @fn413
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ============ast.prefix_node=============
  ast.prefix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 21
  0005    | GetConstant2 445: {_0_, _1_}
  0008    | GetConstant 129: "type"
  0010    | GetBoundLocal 1
  0012    | InsertKeyVal 0
  0014    | GetConstant2 263: "power"
  0017    | GetBoundLocal 2
  0019    | InsertKeyVal 1
  0021    | End
  ========================================
  
  ==============Array.Filter==============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant2 370: _Array.Filter
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==================json==================
  json =
    json.boolean |
    json.null |
    json.number |
    json.string |
    json.array(json) |
    json.object(json)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 446: json.boolean
  0004    | Or 4 -> 48
  0007    | SetInputMark
  0008    | CallFunctionConstant2 447: json.null
  0011    | Or 11 -> 48
  0014    | SetInputMark
  0015    | CallFunctionConstant2 448: number
  0018    | Or 18 -> 48
  0021    | SetInputMark
  0022    | CallFunctionConstant2 418: json.string
  0025    | Or 25 -> 48
  0028    | SetInputMark
  0029    | GetConstant2 449: json.array
  0032    | GetConstant2 450: json
  0035    | CallFunction 1
  0037    | Or 37 -> 48
  0040    | GetConstant2 451: json.object
  0043    | GetConstant2 450: json
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  =================@fn420=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 27: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn419=================
  surround(elem, maybe(ws))
  ========================================
  0000    | GetConstant 56: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 82: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant2 454: @fn420
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ===============json.array===============
  json.array(elem) = "[" > maybe_array_sep(surround(elem, maybe(ws)), ",") < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 19
  0005    | GetConstant2 452: maybe_array_sep
  0008    | GetConstant2 453: @fn419
  0011    | CreateClosure 1
  0013    | CaptureLocal 0
  0015    | PushChar ','
  0017    | CallFunction 2
  0019    | JumpIfFailure 19 -> 25
  0022    | ParseChar ']'
  0024    | TakeLeft
  0025    | End
  ========================================
  
  =================@fn422=================
  "-" + _number_integer_part
  ========================================
  0000    | ParseChar '-'
  0002    | CallFunctionConstant2 256: _number_integer_part
  0005    | Merge
  0006    | End
  ========================================
  
  ============negative_integer============
  negative_integer = as_number("-" + _number_integer_part)
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 455: @fn422
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =============binary_integer=============
  binary_integer = array(binary_digit) -> Digits $ Num.FromBinaryDigits(Digits)
  ========================================
  0000    | GetConstant 195: Digits
  0002    | GetConstant2 365: array
  0005    | GetConstant 203: binary_digit
  0007    | CallFunction 1
  0009    | Destructure 116: Digits
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 205: Num.FromBinaryDigits
  0016    | GetBoundLocal 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  =================@fn425=================
  maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | CallFunctionConstant2 256: _number_integer_part
  0009    | Merge
  0010    | CallFunctionConstant2 269: _number_fraction_part
  0013    | Merge
  0014    | CallFunctionConstant2 270: _number_exponent_part
  0017    | Merge
  0018    | End
  ========================================
  
  ============scientific_float============
  scientific_float = as_number(
    maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 228: as_number
  0002    | GetConstant2 456: @fn425
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ==============Array.Reduce==============
  Array.Reduce(A, Fn, Acc) =
    A -> [First, ...Rest] ? Array.Reduce(Rest, Fn, Fn(Acc, First)) : Acc
  ========================================
  0000    | GetConstant 15: First
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 117: ([First] + Rest)
  0009    | ConditionalThen 9 -> 32
  0012    | GetConstant2 457: Array.Reduce
  0015    | GetBoundLocal 4
  0017    | GetBoundLocal 1
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 2
  0023    | GetBoundLocal 3
  0025    | CallFunction 2
  0027    | CallTailFunction 3
  0029    | Jump 29 -> 34
  0032    | GetBoundLocal 2
  0034    | End
  ========================================
  
  =================alnums=================
  alnums = many(alnum)
  ========================================
  0000    | GetConstant 45: many
  0002    | GetConstant2 326: alnum
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ================ast.node================
  ast.node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | GetConstant2 388: Value
  0003    | CallFunctionLocal 0
  0005    | Destructure 118: Value
  0007    | TakeRight 7 -> 25
  0010    | GetConstant2 458: {_0_, _1_}
  0013    | GetConstant 129: "type"
  0015    | GetBoundLocal 1
  0017    | InsertKeyVal 0
  0019    | GetConstant 12: "value"
  0021    | GetBoundLocal 2
  0023    | InsertKeyVal 1
  0025    | End
  ========================================
  
  ==============hex_integer===============
  hex_integer = array(hex_digit) -> Digits $ Num.FromHexDigits(Digits)
  ========================================
  0000    | GetConstant 195: Digits
  0002    | GetConstant2 365: array
  0005    | GetConstant 221: hex_digit
  0007    | CallFunction 1
  0009    | Destructure 119: Digits
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 223: Num.FromHexDigits
  0016    | GetBoundLocal 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  ==============Array.Reject==============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant2 459: _Array.Reject
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_Array.Reject==============
  _Array.Reject(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reject(Rest, Pred, Pred(First) ? Acc : [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant 15: First
  0002    | GetConstant 8: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 120: ([First] + Rest)
  0009    | ConditionalThen 9 -> 51
  0012    | GetConstant2 459: _Array.Reject
  0015    | GetBoundLocal 4
  0017    | GetBoundLocal 1
  0019    | SetInputMark
  0020    | GetBoundLocal 1
  0022    | GetBoundLocal 3
  0024    | CallFunction 1
  0026    | ConditionalThen 26 -> 34
  0029    | GetBoundLocal 2
  0031    | Jump 31 -> 46
  0034    | PushEmptyArray
  0035    | GetBoundLocal 2
  0037    | Merge
  0038    | GetConstant2 460: [_]
  0041    | GetBoundLocal 3
  0043    | InsertAtIndex 0
  0045    | Merge
  0046    | CallTailFunction 3
  0048    | Jump 48 -> 53
  0051    | GetBoundLocal 2
  0053    | End
  ========================================
  
  ===============Is.String================
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 121: ("" + _)
  0005    | End
  ========================================
  
  ===============as_string================
  as_string(p) = "%(p)"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionLocal 0
  0003    | MergeAsString
  0004    | End
  ========================================
  
  ================Obj.Size================
  Obj.Size(O) = _Obj.Size(O, 0)
  ========================================
  0000    | GetConstant2 431: _Obj.Size
  0003    | GetBoundLocal 0
  0005    | PushNumberZero
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Min=================
  Num.Min(A, B) = A -> ..B ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 122: ..B
  0005    | ConditionalThen 5 -> 13
  0008    | GetBoundLocal 0
  0010    | Jump 10 -> 15
  0013    | GetBoundLocal 1
  0015    | End
  ========================================
  
  ===============Array.Rest===============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar R
  0003    | GetBoundLocal 0
  0005    | Destructure 123: ([_] + R)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocal 2
  0012    | End
  ========================================
  
  ================record3=================
  record3(Key1, value1, Key2, value2, Key3, value3) =
    value1 -> V1 &
    value2 -> V2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | GetConstant2 461: V1
  0003    | GetConstant2 462: V2
  0006    | GetConstant2 463: V3
  0009    | CallFunctionLocal 1
  0011    | Destructure 124: V1
  0013    | TakeRight 13 -> 20
  0016    | CallFunctionLocal 3
  0018    | Destructure 125: V2
  0020    | TakeRight 20 -> 51
  0023    | CallFunctionLocal 5
  0025    | Destructure 126: V3
  0027    | TakeRight 27 -> 51
  0030    | GetConstant2 464: {_0_, _1_, _2_}
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 6
  0037    | InsertKeyVal 0
  0039    | GetBoundLocal 2
  0041    | GetBoundLocal 7
  0043    | InsertKeyVal 1
  0045    | GetBoundLocal 4
  0047    | GetBoundLocal 8
  0049    | InsertKeyVal 2
  0051    | End
  ========================================
  
  ===============tuple3_sep===============
  tuple3_sep(elem1, sep1, elem2, sep2, elem3) =
    elem1 -> E1 & sep1 &
    elem2 -> E2 & sep2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | GetConstant 18: E1
  0002    | GetConstant 19: E2
  0004    | GetConstant 20: E3
  0006    | CallFunctionLocal 0
  0008    | Destructure 127: E1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 22
  0018    | CallFunctionLocal 2
  0020    | Destructure 128: E2
  0022    | TakeRight 22 -> 27
  0025    | CallFunctionLocal 3
  0027    | TakeRight 27 -> 52
  0030    | CallFunctionLocal 4
  0032    | Destructure 129: E3
  0034    | TakeRight 34 -> 52
  0037    | GetConstant2 465: [_, _, _]
  0040    | GetBoundLocal 5
  0042    | InsertAtIndex 0
  0044    | GetBoundLocal 6
  0046    | InsertAtIndex 1
  0048    | GetBoundLocal 7
  0050    | InsertAtIndex 2
  0052    | End
  ========================================
  
  ================record2=================
  record2(Key1, value1, Key2, value2) =
    value1 -> V1 &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | GetConstant2 461: V1
  0003    | GetConstant2 462: V2
  0006    | CallFunctionLocal 1
  0008    | Destructure 130: V1
  0010    | TakeRight 10 -> 35
  0013    | CallFunctionLocal 3
  0015    | Destructure 131: V2
  0017    | TakeRight 17 -> 35
  0020    | GetConstant2 466: {_0_, _1_}
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 4
  0027    | InsertKeyVal 0
  0029    | GetBoundLocal 2
  0031    | GetBoundLocal 5
  0033    | InsertKeyVal 1
  0035    | End
  ========================================
  
  ==============record2_sep===============
  record2_sep(Key1, value1, sep, Key2, value2) =
    value1 -> V1 & sep &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | GetConstant2 461: V1
  0003    | GetConstant2 462: V2
  0006    | CallFunctionLocal 1
  0008    | Destructure 132: V1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 2
  0015    | TakeRight 15 -> 40
  0018    | CallFunctionLocal 4
  0020    | Destructure 133: V2
  0022    | TakeRight 22 -> 40
  0025    | GetConstant2 467: {_0_, _1_}
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 5
  0032    | InsertKeyVal 0
  0034    | GetBoundLocal 3
  0036    | GetBoundLocal 6
  0038    | InsertKeyVal 1
  0040    | End
  ========================================
  
  =================ascii==================
  ascii = "\u000000".."\u00007F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x7f' (esc)
  0003    | End
  ========================================
  
  ======ast.with_operator_precedence======
  ast.with_operator_precedence(operand, prefix, infix, postfix) =
    _ast.with_precedence_start(operand, prefix, infix, postfix, $0)
  ========================================
  0000    | GetConstant2 350: _ast.with_precedence_start
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | GetBoundLocal 3
  0011    | PushNumberZero
  0012    | CallTailFunction 5
  0014    | End
  ========================================
  
  ==============record3_sep===============
  record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3) =
    value1 -> V1 & sep1 &
    value2 -> V2 & sep2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | GetConstant2 461: V1
  0003    | GetConstant2 462: V2
  0006    | GetConstant2 463: V3
  0009    | CallFunctionLocal 1
  0011    | Destructure 134: V1
  0013    | TakeRight 13 -> 18
  0016    | CallFunctionLocal 2
  0018    | TakeRight 18 -> 25
  0021    | CallFunctionLocal 4
  0023    | Destructure 135: V2
  0025    | TakeRight 25 -> 30
  0028    | CallFunctionLocal 5
  0030    | TakeRight 30 -> 61
  0033    | CallFunctionLocal 7
  0035    | Destructure 136: V3
  0037    | TakeRight 37 -> 61
  0040    | GetConstant2 468: {_0_, _1_, _2_}
  0043    | GetBoundLocal 0
  0045    | GetBoundLocal 8
  0047    | InsertKeyVal 0
  0049    | GetBoundLocal 3
  0051    | GetBoundLocal 9
  0053    | InsertKeyVal 1
  0055    | GetBoundLocal 6
  0057    | GetBoundLocal 10
  0059    | InsertKeyVal 2
  0061    | End
  ========================================

