  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/toml.possum -i '' --no-stdlib
  
  ================0:@fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ================0:@Fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ==============0:@Codepoint==============
  0000    | GetLocal l0
  0002    | NativeCode 6: stringToCodepointNative
  0004    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 9: multiplyNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 11: powerNative
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
  
  ================1:simple================
  simple = custom(simple_value)
  ========================================
  0000    | GetConstant 0: custom
  0002    | GetConstant 1: simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:tagged================
  tagged = custom(tagged_value)
  ========================================
  0000    | GetConstant 0: custom
  0002    | GetConstant 205: tagged_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:custom================
  custom(value) =
    maybe(_comments + maybe(ws)) &
    _with_root_table(value) | _no_root_table(value) -> Doc &
    maybe(maybe(ws) + _comments) $
    _Doc.Value(Doc)
  ========================================
  0000    | PushVar Doc
  0002    | GetConstant 2: maybe
  0004    | GetConstant 3: @fn0
  0006    | CallFunction 1
  0008    | TakeRight 8 -> 38
  0011    | SetInputMark
  0012    | GetConstant 4: _with_root_table
  0014    | GetLocal l0
  0016    | CallFunction 1
  0018    | Or 18 -> 27
  0021    | GetConstant 5: _no_root_table
  0023    | GetLocalMove l0
  0025    | CallFunction 1
  0027    | JumpIfFailure 27 -> 38
  0030    | MatchWindowEnter 2
  0032    | MatchScrutinee r0
  0034    | MatchBind l1 r0
  0037    | MatchWindowExit
  0038    | TakeRight 38 -> 56
  0041    | GetConstant 2: maybe
  0043    | GetConstant 6: @fn1
  0045    | CallFunction 1
  0047    | TakeRight 47 -> 56
  0050    | GetConstant 7: _Doc.Value
  0052    | GetLocalMove l1
  0054    | CallTailFunction 1
  0056    | End
  ========================================
  
  ===========1:_with_root_table===========
  _with_root_table(value) =
    _root_table(value, _Doc.Empty) -> RootDoc &
    (_ws > _tables(value, RootDoc)) | const(RootDoc)
  ========================================
  0000    | PushVar2 RootDoc
  0003    | GetConstant 13: _root_table
  0005    | GetLocal l0
  0007    | CallFunctionConstant 14: _Doc.Empty
  0009    | CallFunction 2
  0011    | JumpIfFailure 11 -> 22
  0014    | MatchWindowEnter 2
  0016    | MatchScrutinee r0
  0018    | MatchBind l1 r0
  0021    | MatchWindowExit
  0022    | TakeRight 22 -> 48
  0025    | SetInputMark
  0026    | CallFunctionConstant 15: _ws
  0028    | TakeRight 28 -> 39
  0031    | GetConstant 16: _tables
  0033    | GetLocalMove l0
  0035    | GetLocal l1
  0037    | CallFunction 2
  0039    | Or 39 -> 48
  0042    | GetConstant 17: const
  0044    | GetLocalMove l1
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  =============1:_root_table==============
  _root_table(value, Doc) =
    _table_body(value, [], Doc)
  ========================================
  0000    | GetConstant 18: _table_body
  0002    | GetLocalMove l0
  0004    | PushEmptyArray
  0005    | GetLocalMove l1
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ============1:_no_root_table============
  _no_root_table(value) =
    _table(value, _Doc.Empty) | _array_of_tables(value, _Doc.Empty) -> NewDoc &
    _tables(value, NewDoc)
  ========================================
  0000    | PushVar2 NewDoc
  0003    | SetInputMark
  0004    | GetConstant 93: _table
  0006    | GetLocal l0
  0008    | CallFunctionConstant 14: _Doc.Empty
  0010    | CallFunction 2
  0012    | Or 12 -> 23
  0015    | GetConstant 94: _array_of_tables
  0017    | GetLocal l0
  0019    | CallFunctionConstant 14: _Doc.Empty
  0021    | CallFunction 2
  0023    | JumpIfFailure 23 -> 34
  0026    | MatchWindowEnter 2
  0028    | MatchScrutinee r0
  0030    | MatchBind l1 r0
  0033    | MatchWindowExit
  0034    | TakeRight 34 -> 45
  0037    | GetConstant 16: _tables
  0039    | GetLocalMove l0
  0041    | GetLocalMove l1
  0043    | CallTailFunction 2
  0045    | End
  ========================================
  
  ===============1:_tables================
  _tables(value, Doc) =
    _ws >
    _table(value, Doc) | _array_of_tables(value, Doc) -> NewDoc ?
    _tables(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | PushVar2 NewDoc
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | CallFunctionConstant 15: _ws
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 93: _table
  0012    | GetLocal l0
  0014    | GetLocal l1
  0016    | CallFunction 2
  0018    | Or 18 -> 29
  0021    | GetConstant 94: _array_of_tables
  0023    | GetLocal l0
  0025    | GetLocal l1
  0027    | CallFunction 2
  0029    | JumpIfFailure 29 -> 40
  0032    | MatchWindowEnter 2
  0034    | MatchScrutinee r0
  0036    | MatchBind l2 r0
  0039    | MatchWindowExit
  0040    | ConditionalThen 40 -> 54
  0043    | GetConstant 16: _tables
  0045    | GetLocalMove l0
  0047    | GetLocalMove l2
  0049    | CallTailFunction 2
  0051    | Jump 51 -> 60
  0054    | GetConstant 17: const
  0056    | GetLocalMove l1
  0058    | CallTailFunction 1
  0060    | End
  ========================================
  
  ================1:_table================
  _table(value, Doc) =
    _table_header -> HeaderPath & _ws_newline & (
      _table_body(value, HeaderPath, Doc) |
      const(_Doc.EnsureTableAtPath(Doc, HeaderPath))
    )
  ========================================
  0000    | PushVar2 HeaderPath
  0003    | CallFunctionConstant 95: _table_header
  0005    | JumpIfFailure 5 -> 16
  0008    | MatchWindowEnter 2
  0010    | MatchScrutinee r0
  0012    | MatchBind l2 r0
  0015    | MatchWindowExit
  0016    | TakeRight 16 -> 21
  0019    | CallFunctionConstant 20: _ws_newline
  0021    | TakeRight 21 -> 50
  0024    | SetInputMark
  0025    | GetConstant 18: _table_body
  0027    | GetLocalMove l0
  0029    | GetLocal l2
  0031    | GetLocal l1
  0033    | CallFunction 3
  0035    | Or 35 -> 50
  0038    | GetConstant 17: const
  0040    | GetConstant 96: _Doc.EnsureTableAtPath
  0042    | GetLocalMove l1
  0044    | GetLocalMove l2
  0046    | CallFunction 2
  0048    | CallTailFunction 1
  0050    | End
  ========================================
  
  ===========1:_array_of_tables===========
  _array_of_tables(value, Doc) =
    _array_of_tables_header -> HeaderPath & _ws_newline &
    default(_table_body(value, [], _Doc.Empty), _Doc.Empty) -> InnerDoc $
    _Doc.AppendAtPath(Doc, HeaderPath, InnerDoc)
  ========================================
  0000    | PushVar2 HeaderPath
  0003    | PushVar2 InnerDoc
  0006    | CallFunctionConstant 99: _array_of_tables_header
  0008    | JumpIfFailure 8 -> 19
  0011    | MatchWindowEnter 2
  0013    | MatchScrutinee r0
  0015    | MatchBind l2 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 24
  0022    | CallFunctionConstant 20: _ws_newline
  0024    | TakeRight 24 -> 63
  0027    | GetConstant 53: default
  0029    | GetConstant 100: @fn2
  0031    | CreateClosure 1
  0033    | CaptureLocal l0
  0035    | CallFunctionConstant 14: _Doc.Empty
  0037    | CallFunction 2
  0039    | JumpIfFailure 39 -> 50
  0042    | MatchWindowEnter 2
  0044    | MatchScrutinee r0
  0046    | MatchBind l3 r0
  0049    | MatchWindowExit
  0050    | TakeRight 50 -> 63
  0053    | GetConstant 101: _Doc.AppendAtPath
  0055    | GetLocalMove l1
  0057    | GetLocalMove l2
  0059    | GetLocalMove l3
  0061    | CallTailFunction 3
  0063    | End
  ========================================
  
  =================1:_ws==================
  _ws = maybe_many(ws | _comment)
  ========================================
  0000    | GetConstant 63: maybe_many
  0002    | GetConstant 65: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============1:_ws_line===============
  _ws_line = maybe_many(spaces | _comment)
  ========================================
  0000    | GetConstant 63: maybe_many
  0002    | GetConstant 64: @fn4
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============1:_ws_newline==============
  _ws_newline = _ws_line + (nl | end) + _ws
  ========================================
  0000    | CallFunctionConstant 60: _ws_line
  0002    | JumpIfFailure 2 -> 14
  0005    | SetInputMark
  0006    | CallFunctionConstant 61: newline
  0008    | Or 8 -> 13
  0011    | CallFunctionConstant 62: end_of_input
  0013    | Merge
  0014    | JumpIfFailure 14 -> 20
  0017    | CallFunctionConstant 15: _ws
  0019    | Merge
  0020    | End
  ========================================
  
  ==============1:_comments===============
  _comments = many_sep(_comment, ws)
  ========================================
  0000    | GetConstant 10: many_sep
  0002    | GetConstant 11: _comment
  0004    | GetConstant 9: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============1:_table_header=============
  _table_header = "[" > surround(_path, maybe(ws)) < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 13
  0005    | GetConstant 56: surround
  0007    | GetConstant 23: _path
  0009    | GetConstant 97: @fn5
  0011    | CallFunction 2
  0013    | JumpIfFailure 13 -> 19
  0016    | ParseChar ']'
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =======1:_array_of_tables_header========
  _array_of_tables_header =
    "[[" > surround(_path, maybe(ws)) < "]]"
  ========================================
  0000    | CallFunctionConstant 102: "[["
  0002    | TakeRight 2 -> 13
  0005    | GetConstant 56: surround
  0007    | GetConstant 23: _path
  0009    | GetConstant 103: @fn6
  0011    | CallFunction 2
  0013    | JumpIfFailure 13 -> 19
  0016    | CallFunctionConstant 104: "]]"
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =============1:_table_body==============
  _table_body(value, HeaderPath, Doc) =
    _table_pair(value) -> [KeyPath, Val] & _ws_newline &
    const(_Doc.InsertPairAtHeaderPath(Doc, HeaderPath, KeyPath, Val)) -> NewDoc &
    _table_body(value, HeaderPath, NewDoc) | const(NewDoc)
  ========================================
  0000    | PushVar2 KeyPath
  0003    | PushVar2 Val
  0006    | PushVar2 NewDoc
  0009    | GetConstant 19: _table_pair
  0011    | GetLocal l0
  0013    | CallFunction 1
  0015    | JumpIfFailure 15 -> 51
  0018    | MatchWindowEnter 4
  0020    | MatchScrutinee r0
  0022    | MatchType r0 array -> 49
  0027    | MatchLen r0 2 -> 49
  0032    | MatchElem r1 r0[0]
  0036    | MatchBind l3 r1
  0039    | MatchElem r2 r0[1]
  0043    | MatchBind l4 r2
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | TakeRight 51 -> 56
  0054    | CallFunctionConstant 20: _ws_newline
  0056    | TakeRight 56 -> 86
  0059    | GetConstant 17: const
  0061    | GetConstant 21: _Doc.InsertPairAtHeaderPath
  0063    | GetLocalMove l2
  0065    | GetLocal l1
  0067    | GetLocalMove l3
  0069    | GetLocalMove l4
  0071    | CallFunction 4
  0073    | CallFunction 1
  0075    | JumpIfFailure 75 -> 86
  0078    | MatchWindowEnter 2
  0080    | MatchScrutinee r0
  0082    | MatchBind l5 r0
  0085    | MatchWindowExit
  0086    | TakeRight 86 -> 109
  0089    | SetInputMark
  0090    | GetConstant 18: _table_body
  0092    | GetLocalMove l0
  0094    | GetLocalMove l1
  0096    | GetLocal l5
  0098    | CallFunction 3
  0100    | Or 100 -> 109
  0103    | GetConstant 17: const
  0105    | GetLocalMove l5
  0107    | CallTailFunction 1
  0109    | End
  ========================================
  
  =============1:_table_pair==============
  _table_pair(value) =
    tuple2_sep(_path, surround("=", maybe(spaces)), value)
  ========================================
  0000    | GetConstant 22: tuple2_sep
  0002    | GetConstant 23: _path
  0004    | GetConstant 24: @fn7
  0006    | GetLocalMove l0
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ================1:_path=================
  _path = array_sep(_key, surround(".", maybe(ws)))
  ========================================
  0000    | GetConstant 25: array_sep
  0002    | GetConstant 26: _key
  0004    | GetConstant 27: @fn9
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================1:_key=================
  _key =
    many(alpha | numeral | "_" | "-") |
    string.basic |
    string.literal
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 28: many
  0003    | GetConstant 29: @fn11
  0005    | CallFunction 1
  0007    | Or 7 -> 18
  0010    | SetInputMark
  0011    | CallFunctionConstant 30: string.basic
  0013    | Or 13 -> 18
  0016    | CallTailFunctionConstant 31: string.literal
  0018    | End
  ========================================
  
  ===============1:_comment===============
  _comment = "#" > maybe(line)
  ========================================
  0000    | ParseChar '#'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 2: maybe
  0007    | GetConstant 12: line
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  =============1:simple_value=============
  simple_value =
    string |
    datetime |
    number |
    boolean |
    array(simple_value) |
    inline_table(simple_value)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 113: string
  0003    | Or 3 -> 40
  0006    | SetInputMark
  0007    | CallFunctionConstant 114: datetime
  0009    | Or 9 -> 40
  0012    | SetInputMark
  0013    | CallFunctionConstant 115: number
  0015    | Or 15 -> 40
  0018    | SetInputMark
  0019    | CallFunctionConstant 116: boolean
  0021    | Or 21 -> 40
  0024    | SetInputMark
  0025    | GetConstant 117: array
  0027    | GetConstant 1: simple_value
  0029    | CallFunction 1
  0031    | Or 31 -> 40
  0034    | GetConstant 118: inline_table
  0036    | GetConstant 1: simple_value
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  =============1:tagged_value=============
  tagged_value =
    string |
    _tag($"datetime", $"offset", datetime.offset) |
    _tag($"datetime", $"local", datetime.local) |
    _tag($"datetime", $"date-local", datetime.local_date) |
    _tag($"datetime", $"time-local", datetime.local_time) |
    number.binary_integer |
    number.octal_integer |
    number.hex_integer |
    _tag($"float", $"infinity", number.infinity) |
    _tag($"float", $"not-a-number", number.not_a_number) |
    number.float |
    number.integer |
    boolean |
    array(tagged_value) |
    inline_table(tagged_value)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 113: string
  0003    | Or 3 -> 154
  0006    | SetInputMark
  0007    | GetConstant 206: _tag
  0009    | PushString2 "datetime"
  0012    | PushString2 "offset"
  0015    | GetConstant 129: datetime.offset
  0017    | CallFunction 3
  0019    | Or 19 -> 154
  0022    | SetInputMark
  0023    | GetConstant 206: _tag
  0025    | PushString2 "datetime"
  0028    | PushString2 "local"
  0031    | GetConstant 130: datetime.local
  0033    | CallFunction 3
  0035    | Or 35 -> 154
  0038    | SetInputMark
  0039    | GetConstant 206: _tag
  0041    | PushString2 "datetime"
  0044    | PushString2 "date-local"
  0047    | GetConstant 131: datetime.local_date
  0049    | CallFunction 3
  0051    | Or 51 -> 154
  0054    | SetInputMark
  0055    | GetConstant 206: _tag
  0057    | PushString2 "datetime"
  0060    | PushString2 "time-local"
  0063    | GetConstant 132: datetime.local_time
  0065    | CallFunction 3
  0067    | Or 67 -> 154
  0070    | SetInputMark
  0071    | CallFunctionConstant 145: number.binary_integer
  0073    | Or 73 -> 154
  0076    | SetInputMark
  0077    | CallFunctionConstant 146: number.octal_integer
  0079    | Or 79 -> 154
  0082    | SetInputMark
  0083    | CallFunctionConstant 147: number.hex_integer
  0085    | Or 85 -> 154
  0088    | SetInputMark
  0089    | GetConstant 206: _tag
  0091    | PushString2 "float"
  0094    | PushString2 "infinity"
  0097    | GetConstant 148: number.infinity
  0099    | CallFunction 3
  0101    | Or 101 -> 154
  0104    | SetInputMark
  0105    | GetConstant 206: _tag
  0107    | PushString2 "float"
  0110    | PushString2 "not-a-number"
  0113    | GetConstant 149: number.not_a_number
  0115    | CallFunction 3
  0117    | Or 117 -> 154
  0120    | SetInputMark
  0121    | CallFunctionConstant 150: number.float
  0123    | Or 123 -> 154
  0126    | SetInputMark
  0127    | CallFunctionConstant 151: number.integer
  0129    | Or 129 -> 154
  0132    | SetInputMark
  0133    | CallFunctionConstant 116: boolean
  0135    | Or 135 -> 154
  0138    | SetInputMark
  0139    | GetConstant 117: array
  0141    | GetConstant 205: tagged_value
  0143    | CallFunction 1
  0145    | Or 145 -> 154
  0148    | GetConstant 118: inline_table
  0150    | GetConstant 205: tagged_value
  0152    | CallTailFunction 1
  0154    | End
  ========================================
  
  =================1:_tag=================
  _tag(Type, Subtype, value) =
    value -> Value $ {"type": Type, "subtype": Subtype, "value": Value}
  ========================================
  0000    | PushVar2 Value
  0003    | CallFunctionLocal l2
  0005    | JumpIfFailure 5 -> 16
  0008    | MatchWindowEnter 2
  0010    | MatchScrutinee r0
  0012    | MatchBind l3 r0
  0015    | MatchWindowExit
  0016    | TakeRight 16 -> 42
  0019    | GetConstantMutable 207: {_0_, _1_, _2_}
  0021    | PushString2 "type"
  0024    | GetLocalMove l0
  0026    | InsertKeyVal 0
  0028    | PushString2 "subtype"
  0031    | GetLocalMove l1
  0033    | InsertKeyVal 1
  0035    | PushString2 "value"
  0038    | GetLocalMove l3
  0040    | InsertKeyVal 2
  0042    | End
  ========================================
  
  ================1:string================
  string =
    string.multi_line_basic |
    string.multi_line_literal |
    string.basic |
    string.literal
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 119: string.multi_line_basic
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 120: string.multi_line_literal
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | CallFunctionConstant 30: string.basic
  0015    | Or 15 -> 20
  0018    | CallTailFunctionConstant 31: string.literal
  0020    | End
  ========================================
  
  ===============1:datetime===============
  datetime =
    datetime.offset |
    datetime.local |
    datetime.local_date |
    datetime.local_time
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 129: datetime.offset
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 130: datetime.local
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | CallFunctionConstant 131: datetime.local_date
  0015    | Or 15 -> 20
  0018    | CallTailFunctionConstant 132: datetime.local_time
  0020    | End
  ========================================
  
  ================1:number================
  number =
    number.binary_integer |
    number.octal_integer |
    number.hex_integer |
    number.infinity |
    number.not_a_number |
    number.float |
    number.integer
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 145: number.binary_integer
  0003    | Or 3 -> 38
  0006    | SetInputMark
  0007    | CallFunctionConstant 146: number.octal_integer
  0009    | Or 9 -> 38
  0012    | SetInputMark
  0013    | CallFunctionConstant 147: number.hex_integer
  0015    | Or 15 -> 38
  0018    | SetInputMark
  0019    | CallFunctionConstant 148: number.infinity
  0021    | Or 21 -> 38
  0024    | SetInputMark
  0025    | CallFunctionConstant 149: number.not_a_number
  0027    | Or 27 -> 38
  0030    | SetInputMark
  0031    | CallFunctionConstant 150: number.float
  0033    | Or 33 -> 38
  0036    | CallTailFunctionConstant 151: number.integer
  0038    | End
  ========================================
  
  ===============1:boolean================
  boolean = !stdlib.boolean("true", "false")
  ========================================
  0000    | GetConstant 197: boolean
  0002    | PushString2 "true"
  0005    | PushString2 "false"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  ================1:array=================
  array(elem) =
    "[" > _ws > default(
      array_sep(surround(elem, _ws), ",") < maybe(surround(",", _ws)),
      []
    ) < _ws < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 15: _ws
  0007    | TakeRight 7 -> 21
  0010    | GetConstant 53: default
  0012    | GetConstant 198: @fn12
  0014    | CreateClosure 1
  0016    | CaptureLocal l0
  0018    | PushEmptyArray
  0019    | CallFunction 2
  0021    | JumpIfFailure 21 -> 27
  0024    | CallFunctionConstant 15: _ws
  0026    | TakeLeft
  0027    | JumpIfFailure 27 -> 33
  0030    | ParseChar ']'
  0032    | TakeLeft
  0033    | End
  ========================================
  
  =============1:inline_table=============
  inline_table(value) =
    _empty_inline_table | _nonempty_inline_table(value) -> InlineDoc $
    _Doc.Value(InlineDoc)
  ========================================
  0000    | PushVar2 InlineDoc
  0003    | SetInputMark
  0004    | CallFunctionConstant 201: _empty_inline_table
  0006    | Or 6 -> 15
  0009    | GetConstant 202: _nonempty_inline_table
  0011    | GetLocalMove l0
  0013    | CallFunction 1
  0015    | JumpIfFailure 15 -> 26
  0018    | MatchWindowEnter 2
  0020    | MatchScrutinee r0
  0022    | MatchBind l1 r0
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 35
  0029    | GetConstant 7: _Doc.Value
  0031    | GetLocalMove l1
  0033    | CallTailFunction 1
  0035    | End
  ========================================
  
  =========1:_empty_inline_table==========
  _empty_inline_table = "{" > maybe(spaces) < "}" $ _Doc.Empty
  ========================================
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 2: maybe
  0007    | GetConstant 59: spaces
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 17
  0014    | ParseChar '}'
  0016    | TakeLeft
  0017    | TakeRight 17 -> 22
  0020    | CallTailFunctionConstant 14: _Doc.Empty
  0022    | End
  ========================================
  
  ========1:_nonempty_inline_table========
  _nonempty_inline_table(value) =
    "{" > maybe(spaces) >
    _inline_table_pair(value, _Doc.Empty) -> DocWithFirstPair &
    _inline_table_body(value, DocWithFirstPair)
    < maybe(spaces) < "}"
  ========================================
  0000    | PushVar2 DocWithFirstPair
  0003    | ParseChar '{'
  0005    | TakeRight 5 -> 14
  0008    | GetConstant 2: maybe
  0010    | GetConstant 59: spaces
  0012    | CallFunction 1
  0014    | TakeRight 14 -> 25
  0017    | GetConstant 203: _inline_table_pair
  0019    | GetLocal l0
  0021    | CallFunctionConstant 14: _Doc.Empty
  0023    | CallFunction 2
  0025    | JumpIfFailure 25 -> 36
  0028    | MatchWindowEnter 2
  0030    | MatchScrutinee r0
  0032    | MatchBind l1 r0
  0035    | MatchWindowExit
  0036    | TakeRight 36 -> 63
  0039    | GetConstant 204: _inline_table_body
  0041    | GetLocalMove l0
  0043    | GetLocalMove l1
  0045    | CallFunction 2
  0047    | JumpIfFailure 47 -> 57
  0050    | GetConstant 2: maybe
  0052    | GetConstant 59: spaces
  0054    | CallFunction 1
  0056    | TakeLeft
  0057    | JumpIfFailure 57 -> 63
  0060    | ParseChar '}'
  0062    | TakeLeft
  0063    | End
  ========================================
  
  ==========1:_inline_table_body==========
  _inline_table_body(value, Doc) =
    "," > _inline_table_pair(value, Doc) -> NewDoc ?
    _inline_table_body(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | PushVar2 NewDoc
  0003    | SetInputMark
  0004    | ParseChar ','
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 203: _inline_table_pair
  0011    | GetLocal l0
  0013    | GetLocal l1
  0015    | CallFunction 2
  0017    | JumpIfFailure 17 -> 28
  0020    | MatchWindowEnter 2
  0022    | MatchScrutinee r0
  0024    | MatchBind l2 r0
  0027    | MatchWindowExit
  0028    | ConditionalThen 28 -> 42
  0031    | GetConstant 204: _inline_table_body
  0033    | GetLocalMove l0
  0035    | GetLocalMove l2
  0037    | CallTailFunction 2
  0039    | Jump 39 -> 48
  0042    | GetConstant 17: const
  0044    | GetLocalMove l1
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  ==========1:_inline_table_pair==========
  _inline_table_pair(value, Doc) =
    maybe(spaces) &
    _path -> Key &
    maybe(spaces) & "=" & maybe(spaces) &
    value -> Val &
    maybe(spaces) $
    _Doc.InsertAtPath(Doc, Key, Val)
  ========================================
  0000    | PushVar2 Key
  0003    | PushVar2 Val
  0006    | GetConstant 2: maybe
  0008    | GetConstant 59: spaces
  0010    | CallFunction 1
  0012    | TakeRight 12 -> 28
  0015    | CallFunctionConstant 23: _path
  0017    | JumpIfFailure 17 -> 28
  0020    | MatchWindowEnter 2
  0022    | MatchScrutinee r0
  0024    | MatchBind l2 r0
  0027    | MatchWindowExit
  0028    | TakeRight 28 -> 37
  0031    | GetConstant 2: maybe
  0033    | GetConstant 59: spaces
  0035    | CallFunction 1
  0037    | TakeRight 37 -> 42
  0040    | ParseChar '='
  0042    | TakeRight 42 -> 51
  0045    | GetConstant 2: maybe
  0047    | GetConstant 59: spaces
  0049    | CallFunction 1
  0051    | TakeRight 51 -> 67
  0054    | CallFunctionLocal l0
  0056    | JumpIfFailure 56 -> 67
  0059    | MatchWindowEnter 2
  0061    | MatchScrutinee r0
  0063    | MatchBind l3 r0
  0066    | MatchWindowExit
  0067    | TakeRight 67 -> 89
  0070    | GetConstant 2: maybe
  0072    | GetConstant 59: spaces
  0074    | CallFunction 1
  0076    | TakeRight 76 -> 89
  0079    | GetConstant 66: _Doc.InsertAtPath
  0081    | GetLocalMove l1
  0083    | GetLocalMove l2
  0085    | GetLocalMove l3
  0087    | CallTailFunction 3
  0089    | End
  ========================================
  
  =======1:string.multi_line_basic========
  string.multi_line_basic =
    skip(`"""`) + skip(maybe(nl)) +
    default(
      many_until(
        _escaped_ctrl_char | _escaped_unicode |
        ws | (`\` + ws > "") | unless(char, ctrl_char | `\`),
        `"""`
      ),
      $""
    )
    + skip(`"""`) + (`"` * 0..2)
  ========================================
  0000    | GetConstant 121: skip
  0002    | PushString2 """""
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 121: skip
  0012    | GetConstant 122: @fn15
  0014    | CallFunction 1
  0016    | Merge
  0017    | JumpIfFailure 17 -> 28
  0020    | GetConstant 53: default
  0022    | GetConstant 123: @fn16
  0024    | PushEmptyString
  0025    | CallFunction 2
  0027    | Merge
  0028    | JumpIfFailure 28 -> 39
  0031    | GetConstant 121: skip
  0033    | PushString2 """""
  0036    | CallFunction 1
  0038    | Merge
  0039    | JumpIfFailure 39 -> 97
  0042    | PushNull
  0043    | PushInteger 0
  0045    | ValidateRepeatPattern
  0046    | JumpIfZero 46 -> 64
  0049    | Swap
  0050    | ParseChar '"'
  0052    | Merge
  0053    | JumpIfFailure 53 -> 94
  0056    | Swap
  0057    | Decrement
  0058    | JumpIfZero 58 -> 64
  0061    | JumpBack 61 -> 49
  0064    | Drop
  0065    | PushInteger 2
  0067    | PushInteger 0
  0069    | NegateNumber
  0070    | Merge
  0071    | ValidateRepeatPattern
  0072    | JumpIfZero 72 -> 95
  0075    | Swap
  0076    | SetInputMark
  0077    | ParseChar '"'
  0079    | JumpIfFailure 79 -> 92
  0082    | PopInputMark
  0083    | Merge
  0084    | Swap
  0085    | Decrement
  0086    | JumpIfZero 86 -> 95
  0089    | JumpBack 89 -> 75
  0092    | ResetInput
  0093    | Drop
  0094    | Swap
  0095    | Drop
  0096    | Merge
  0097    | End
  ========================================
  
  ======1:string.multi_line_literal=======
  string.multi_line_literal =
    skip(`'''`) + skip(maybe(nl)) +
    default(many_until(char, `'''`), $"")
    + skip(`'''`) + (`'` * 0..2)
  ========================================
  0000    | GetConstant 121: skip
  0002    | PushString2 "'''"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 121: skip
  0012    | GetConstant 127: @fn19
  0014    | CallFunction 1
  0016    | Merge
  0017    | JumpIfFailure 17 -> 28
  0020    | GetConstant 53: default
  0022    | GetConstant 128: @fn20
  0024    | PushEmptyString
  0025    | CallFunction 2
  0027    | Merge
  0028    | JumpIfFailure 28 -> 39
  0031    | GetConstant 121: skip
  0033    | PushString2 "'''"
  0036    | CallFunction 1
  0038    | Merge
  0039    | JumpIfFailure 39 -> 97
  0042    | PushNull
  0043    | PushInteger 0
  0045    | ValidateRepeatPattern
  0046    | JumpIfZero 46 -> 64
  0049    | Swap
  0050    | ParseChar '''
  0052    | Merge
  0053    | JumpIfFailure 53 -> 94
  0056    | Swap
  0057    | Decrement
  0058    | JumpIfZero 58 -> 64
  0061    | JumpBack 61 -> 49
  0064    | Drop
  0065    | PushInteger 2
  0067    | PushInteger 0
  0069    | NegateNumber
  0070    | Merge
  0071    | ValidateRepeatPattern
  0072    | JumpIfZero 72 -> 95
  0075    | Swap
  0076    | SetInputMark
  0077    | ParseChar '''
  0079    | JumpIfFailure 79 -> 92
  0082    | PopInputMark
  0083    | Merge
  0084    | Swap
  0085    | Decrement
  0086    | JumpIfZero 86 -> 95
  0089    | JumpBack 89 -> 75
  0092    | ResetInput
  0093    | Drop
  0094    | Swap
  0095    | Drop
  0096    | Merge
  0097    | End
  ========================================
  
  =============1:string.basic=============
  string.basic = '"' > _string.basic_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 34: _string.basic_body
  0007    | JumpIfFailure 7 -> 13
  0010    | ParseChar '"'
  0012    | TakeLeft
  0013    | End
  ========================================
  
  ==========1:_string.basic_body==========
  _string.basic_body =
    many(
      _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, ctrl_char | `\` | '"')
    ) | const($"")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 28: many
  0003    | GetConstant 35: @fn21
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 17: const
  0012    | PushEmptyString
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  ============1:string.literal============
  string.literal = "'" > default(chars_until("'"), $"") < "'"
  ========================================
  0000    | ParseChar '''
  0002    | TakeRight 2 -> 12
  0005    | GetConstant 53: default
  0007    | GetConstant 54: @fn23
  0009    | PushEmptyString
  0010    | CallFunction 2
  0012    | JumpIfFailure 12 -> 18
  0015    | ParseChar '''
  0017    | TakeLeft
  0018    | End
  ========================================
  
  ==========1:_escaped_ctrl_char==========
  _escaped_ctrl_char =
    (`\"` $ `"`) |
    (`\\` $ `\`) |
    (`\b` $ "\b") |
    (`\f` $ "\f") |
    (`\n` $ "\n") |
    (`\r` $ "\r") |
    (`\t` $ "\t")
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 41: "\""
  0003    | TakeRight 3 -> 9
  0006    | PushString2 """
  0009    | Or 9 -> 80
  0012    | SetInputMark
  0013    | CallFunctionConstant 42: "\\"
  0015    | TakeRight 15 -> 21
  0018    | PushString2 "\"
  0021    | Or 21 -> 80
  0024    | SetInputMark
  0025    | CallFunctionConstant 43: "\b"
  0027    | TakeRight 27 -> 33
  0030    | PushString2 "\x08" (esc)
  0033    | Or 33 -> 80
  0036    | SetInputMark
  0037    | CallFunctionConstant 44: "\f"
  0039    | TakeRight 39 -> 45
  0042    | PushString2 "\x0c" (esc)
  0045    | Or 45 -> 80
  0048    | SetInputMark
  0049    | CallFunctionConstant 45: "\n"
  0051    | TakeRight 51 -> 57
  0054    | PushString2 "
  "
  0057    | Or 57 -> 80
  0060    | SetInputMark
  0061    | CallFunctionConstant 46: "\r"
  0063    | TakeRight 63 -> 69
  0066    | PushString2 "\r (no-eol) (esc)
  "
  0069    | Or 69 -> 80
  0072    | CallFunctionConstant 47: "\t"
  0074    | TakeRight 74 -> 80
  0077    | PushString2 "\t" (esc)
  0080    | End
  ========================================
  
  ===========1:_escaped_unicode===========
  _escaped_unicode =
    (`\u` > (hex_numeral * 4) -> U $ @Codepoint(U)) |
    (`\U` > (hex_numeral * 8) -> U $ @Codepoint(U))
  ========================================
  0000    | PushVar2 U
  0003    | SetInputMark
  0004    | CallFunctionConstant 48: "\u"
  0006    | TakeRight 6 -> 33
  0009    | PushNull
  0010    | PushInteger 4
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 32
  0016    | Swap
  0017    | CallFunctionConstant 49: hex_numeral
  0019    | Merge
  0020    | JumpIfFailure 20 -> 31
  0023    | Swap
  0024    | Decrement
  0025    | JumpIfZero 25 -> 32
  0028    | JumpBack 28 -> 16
  0031    | Swap
  0032    | Drop
  0033    | JumpIfFailure 33 -> 44
  0036    | MatchWindowEnter 2
  0038    | MatchScrutinee r0
  0040    | MatchBind l0 r0
  0043    | MatchWindowExit
  0044    | TakeRight 44 -> 53
  0047    | GetConstant 50: @Codepoint
  0049    | GetLocal l0
  0051    | CallFunction 1
  0053    | Or 53 -> 105
  0056    | CallFunctionConstant 51: "\U"
  0058    | TakeRight 58 -> 85
  0061    | PushNull
  0062    | PushInteger 8
  0064    | ValidateRepeatPattern
  0065    | JumpIfZero 65 -> 84
  0068    | Swap
  0069    | CallFunctionConstant 49: hex_numeral
  0071    | Merge
  0072    | JumpIfFailure 72 -> 83
  0075    | Swap
  0076    | Decrement
  0077    | JumpIfZero 77 -> 84
  0080    | JumpBack 80 -> 68
  0083    | Swap
  0084    | Drop
  0085    | JumpIfFailure 85 -> 96
  0088    | MatchWindowEnter 2
  0090    | MatchScrutinee r0
  0092    | MatchBind l0 r0
  0095    | MatchWindowExit
  0096    | TakeRight 96 -> 105
  0099    | GetConstant 50: @Codepoint
  0101    | GetLocalMove l0
  0103    | CallTailFunction 1
  0105    | End
  ========================================
  
  ===========1:datetime.offset============
  datetime.offset = datetime.local_date + ("T" | "t" | " ") + _datetime.time_offset
  ========================================
  0000    | CallFunctionConstant 131: datetime.local_date
  0002    | JumpIfFailure 2 -> 20
  0005    | SetInputMark
  0006    | ParseChar 'T'
  0008    | Or 8 -> 19
  0011    | SetInputMark
  0012    | ParseChar 't'
  0014    | Or 14 -> 19
  0017    | ParseChar ' '
  0019    | Merge
  0020    | JumpIfFailure 20 -> 26
  0023    | CallFunctionConstant 133: _datetime.time_offset
  0025    | Merge
  0026    | End
  ========================================
  
  ============1:datetime.local============
  datetime.local = datetime.local_date + ("T" | "t" | " ") + datetime.local_time
  ========================================
  0000    | CallFunctionConstant 131: datetime.local_date
  0002    | JumpIfFailure 2 -> 20
  0005    | SetInputMark
  0006    | ParseChar 'T'
  0008    | Or 8 -> 19
  0011    | SetInputMark
  0012    | ParseChar 't'
  0014    | Or 14 -> 19
  0017    | ParseChar ' '
  0019    | Merge
  0020    | JumpIfFailure 20 -> 26
  0023    | CallFunctionConstant 132: datetime.local_time
  0025    | Merge
  0026    | End
  ========================================
  
  =========1:datetime.local_date==========
  datetime.local_date =
    _datetime.year + "-" + _datetime.month + "-" + _datetime.mday
  ========================================
  0000    | CallFunctionConstant 134: _datetime.year
  0002    | JumpIfFailure 2 -> 8
  0005    | ParseChar '-'
  0007    | Merge
  0008    | JumpIfFailure 8 -> 14
  0011    | CallFunctionConstant 135: _datetime.month
  0013    | Merge
  0014    | JumpIfFailure 14 -> 20
  0017    | ParseChar '-'
  0019    | Merge
  0020    | JumpIfFailure 20 -> 26
  0023    | CallFunctionConstant 136: _datetime.mday
  0025    | Merge
  0026    | End
  ========================================
  
  ============1:_datetime.year============
  _datetime.year = numeral * 4
  ========================================
  0000    | PushNull
  0001    | PushInteger 4
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | CallFunctionConstant 33: numeral
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
  
  ===========1:_datetime.month============
  _datetime.month = ("0" + "1".."9") | ("1" + "0".."2")
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '0'
  0003    | JumpIfFailure 3 -> 10
  0006    | ParseCodepointRange '1'..'9'
  0009    | Merge
  0010    | Or 10 -> 22
  0013    | ParseChar '1'
  0015    | JumpIfFailure 15 -> 22
  0018    | ParseCodepointRange '0'..'2'
  0021    | Merge
  0022    | End
  ========================================
  
  ============1:_datetime.mday============
  _datetime.mday = ("0".."2" + "1".."9") | "30" | "31"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'2'
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseCodepointRange '1'..'9'
  0010    | Merge
  0011    | Or 11 -> 22
  0014    | SetInputMark
  0015    | CallFunctionConstant 137: "30"
  0017    | Or 17 -> 22
  0020    | CallTailFunctionConstant 138: "31"
  0022    | End
  ========================================
  
  =========1:datetime.local_time==========
  datetime.local_time =
    _datetime.hours + ":" +
    _datetime.minutes + ":" +
    _datetime.seconds +
    maybe("." + (numeral * 1..9))
  ========================================
  0000    | CallFunctionConstant 140: _datetime.hours
  0002    | JumpIfFailure 2 -> 8
  0005    | ParseChar ':'
  0007    | Merge
  0008    | JumpIfFailure 8 -> 14
  0011    | CallFunctionConstant 141: _datetime.minutes
  0013    | Merge
  0014    | JumpIfFailure 14 -> 20
  0017    | ParseChar ':'
  0019    | Merge
  0020    | JumpIfFailure 20 -> 26
  0023    | CallFunctionConstant 142: _datetime.seconds
  0025    | Merge
  0026    | JumpIfFailure 26 -> 36
  0029    | GetConstant 2: maybe
  0031    | GetConstant 143: @fn24
  0033    | CallFunction 1
  0035    | Merge
  0036    | End
  ========================================
  
  ========1:_datetime.time_offset=========
  _datetime.time_offset = datetime.local_time + ("Z" | "z" | _datetime.time_numoffset)
  ========================================
  0000    | CallFunctionConstant 132: datetime.local_time
  0002    | JumpIfFailure 2 -> 20
  0005    | SetInputMark
  0006    | ParseChar 'Z'
  0008    | Or 8 -> 19
  0011    | SetInputMark
  0012    | ParseChar 'z'
  0014    | Or 14 -> 19
  0017    | CallFunctionConstant 139: _datetime.time_numoffset
  0019    | Merge
  0020    | End
  ========================================
  
  =======1:_datetime.time_numoffset=======
  _datetime.time_numoffset = ("+" | "-") + _datetime.hours + ":" + _datetime.minutes
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | JumpIfFailure 8 -> 14
  0011    | CallFunctionConstant 140: _datetime.hours
  0013    | Merge
  0014    | JumpIfFailure 14 -> 20
  0017    | ParseChar ':'
  0019    | Merge
  0020    | JumpIfFailure 20 -> 26
  0023    | CallFunctionConstant 141: _datetime.minutes
  0025    | Merge
  0026    | End
  ========================================
  
  ===========1:_datetime.hours============
  _datetime.hours = ("0".."1" + "0".."9") | ("2" + "0".."3")
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'1'
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseCodepointRange '0'..'9'
  0010    | Merge
  0011    | Or 11 -> 23
  0014    | ParseChar '2'
  0016    | JumpIfFailure 16 -> 23
  0019    | ParseCodepointRange '0'..'3'
  0022    | Merge
  0023    | End
  ========================================
  
  ==========1:_datetime.minutes===========
  _datetime.minutes = "0".."5" + "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'5'
  0003    | JumpIfFailure 3 -> 10
  0006    | ParseCodepointRange '0'..'9'
  0009    | Merge
  0010    | End
  ========================================
  
  ==========1:_datetime.seconds===========
  _datetime.seconds = ("0".."5" + "0".."9") | "60"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'5'
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseCodepointRange '0'..'9'
  0010    | Merge
  0011    | Or 11 -> 16
  0014    | CallTailFunctionConstant 144: "60"
  0016    | End
  ========================================
  
  ============1:number.integer============
  number.integer = as_number(
    _number.sign +
    _number.integer_part
  )
  ========================================
  0000    | GetConstant 184: as_number
  0002    | GetConstant 196: @fn25
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============1:_number.sign=============
  _number.sign = maybe("-" | skip("+"))
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 190: @fn26
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========1:_number.integer_part=========
  _number.integer_part =
    ("1".."9" + many(maybe("_") > numeral)) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 14
  0007    | GetConstant 28: many
  0009    | GetConstant 191: @fn27
  0011    | CallFunction 1
  0013    | Merge
  0014    | Or 14 -> 19
  0017    | CallTailFunctionConstant 33: numeral
  0019    | End
  ========================================
  
  =============1:number.float=============
  number.float = as_number(
    _number.sign +
    _number.integer_part + (
      (_number.fraction_part + maybe(_number.exponent_part)) |
      _number.exponent_part
    )
  )
  ========================================
  0000    | GetConstant 184: as_number
  0002    | GetConstant 185: @fn28
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ========1:_number.fraction_part=========
  _number.fraction_part = "." + many_sep(numerals, maybe("_"))
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 14
  0005    | GetConstant 10: many_sep
  0007    | GetConstant 192: numerals
  0009    | GetConstant 193: @fn29
  0011    | CallFunction 2
  0013    | Merge
  0014    | End
  ========================================
  
  ========1:_number.exponent_part=========
  _number.exponent_part =
    ("e" | "E") + maybe("-" | "+") + many_sep(numerals, maybe("_"))
  ========================================
  0000    | SetInputMark
  0001    | ParseChar 'e'
  0003    | Or 3 -> 8
  0006    | ParseChar 'E'
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 2: maybe
  0013    | GetConstant 194: @fn30
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 30
  0021    | GetConstant 10: many_sep
  0023    | GetConstant 192: numerals
  0025    | GetConstant 195: @fn31
  0027    | CallFunction 2
  0029    | Merge
  0030    | End
  ========================================
  
  ===========1:number.infinity============
  number.infinity = maybe("+" | "-") + "inf"
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 180: @fn32
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 181: "inf"
  0011    | Merge
  0012    | End
  ========================================
  
  =========1:number.not_a_number==========
  number.not_a_number = maybe("+" | "-") + "nan"
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 182: @fn33
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 183: "nan"
  0011    | Merge
  0012    | End
  ========================================
  
  ========1:number.binary_integer=========
  number.binary_integer =
    "0b" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral)),
      array_sep(binary_digit, maybe("_"))
    ) -> Digits $
    Num.FromBinaryDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | CallFunctionConstant 152: "0b"
  0005    | TakeRight 5 -> 36
  0008    | GetConstant 153: one_or_both
  0010    | GetConstant 154: @fn34
  0012    | GetConstant 155: @fn37
  0014    | CallFunction 2
  0016    | JumpIfFailure 16 -> 27
  0019    | MatchWindowEnter 2
  0021    | MatchScrutinee r0
  0023    | MatchBind l0 r0
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 36
  0030    | GetConstant 156: Num.FromBinaryDigits
  0032    | GetLocalMove l0
  0034    | CallTailFunction 1
  0036    | End
  ========================================
  
  =========1:number.octal_integer=========
  number.octal_integer =
    "0o" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral)),
      array_sep(octal_digit, maybe("_"))
    ) -> Digits $
    Num.FromOctalDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | CallFunctionConstant 163: "0o"
  0005    | TakeRight 5 -> 36
  0008    | GetConstant 153: one_or_both
  0010    | GetConstant 164: @fn39
  0012    | GetConstant 165: @fn42
  0014    | CallFunction 2
  0016    | JumpIfFailure 16 -> 27
  0019    | MatchWindowEnter 2
  0021    | MatchScrutinee r0
  0023    | MatchBind l0 r0
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 36
  0030    | GetConstant 166: Num.FromOctalDigits
  0032    | GetLocalMove l0
  0034    | CallTailFunction 1
  0036    | End
  ========================================
  
  ==========1:number.hex_integer==========
  number.hex_integer =
    "0x" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral)),
      array_sep(hex_digit, maybe("_"))
    ) -> Digits $
    Num.FromHexDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | CallFunctionConstant 172: "0x"
  0005    | TakeRight 5 -> 36
  0008    | GetConstant 153: one_or_both
  0010    | GetConstant 173: @fn44
  0012    | GetConstant 174: @fn47
  0014    | CallFunction 2
  0016    | JumpIfFailure 16 -> 27
  0019    | MatchWindowEnter 2
  0021    | MatchScrutinee r0
  0023    | MatchBind l0 r0
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 36
  0030    | GetConstant 175: Num.FromHexDigits
  0032    | GetLocalMove l0
  0034    | CallTailFunction 1
  0036    | End
  ========================================
  
  ==============1:_Doc.Empty==============
  _Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant 81: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  ==============1:_Doc.Value==============
  _Doc.Value(Doc) = Obj.Get(Doc, "value")
  ========================================
  0000    | GetConstant 78: Obj.Get
  0002    | GetLocalMove l0
  0004    | PushString2 "value"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ==============1:_Doc.Type===============
  _Doc.Type(Doc) = Obj.Get(Doc, "type")
  ========================================
  0000    | GetConstant 78: Obj.Get
  0002    | GetLocalMove l0
  0004    | PushString2 "type"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ===============1:_Doc.Has===============
  _Doc.Has(Doc, Key) = Obj.Has(_Doc.Type(Doc), Key)
  ========================================
  0000    | GetConstant 77: Obj.Has
  0002    | GetConstant 76: _Doc.Type
  0004    | GetLocalMove l0
  0006    | CallFunction 1
  0008    | GetLocalMove l1
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ===============1:_Doc.Get===============
  _Doc.Get(Doc, Key) = {
    "value": Obj.Get(_Doc.Value(Doc), Key),
    "type": Obj.Get(_Doc.Type(Doc), Key),
  }
  ========================================
  0000    | GetConstantMutable 80: {_0_, _1_}
  0002    | PushString2 "value"
  0005    | GetConstant 78: Obj.Get
  0007    | GetConstant 7: _Doc.Value
  0009    | GetLocal l0
  0011    | CallFunction 1
  0013    | GetLocal l1
  0015    | CallFunction 2
  0017    | InsertKeyVal 0
  0019    | PushString2 "type"
  0022    | GetConstant 78: Obj.Get
  0024    | GetConstant 76: _Doc.Type
  0026    | GetLocalMove l0
  0028    | CallFunction 1
  0030    | GetLocalMove l1
  0032    | CallFunction 2
  0034    | InsertKeyVal 1
  0036    | End
  ========================================
  
  =============1:_Doc.IsTable=============
  _Doc.IsTable(Doc) = Is.Object(_Doc.Type(Doc))
  ========================================
  0000    | GetConstant 79: Is.Object
  0002    | GetConstant 76: _Doc.Type
  0004    | GetLocalMove l0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  =============1:_Doc.Insert==============
  _Doc.Insert(Doc, Key, Val, Type) =
    _Doc.IsTable(Doc) &
    {
      "value": Obj.Put(_Doc.Value(Doc), Key, Val),
      "type": Obj.Put(_Doc.Type(Doc), Key, Type),
    }
  ========================================
  0000    | GetConstant 73: _Doc.IsTable
  0002    | GetLocal l0
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 49
  0009    | GetConstantMutable 82: {_0_, _1_}
  0011    | PushString2 "value"
  0014    | GetConstant 83: Obj.Put
  0016    | GetConstant 7: _Doc.Value
  0018    | GetLocal l0
  0020    | CallFunction 1
  0022    | GetLocal l1
  0024    | GetLocalMove l2
  0026    | CallFunction 3
  0028    | InsertKeyVal 0
  0030    | PushString2 "type"
  0033    | GetConstant 83: Obj.Put
  0035    | GetConstant 76: _Doc.Type
  0037    | GetLocalMove l0
  0039    | CallFunction 1
  0041    | GetLocalMove l1
  0043    | GetLocalMove l3
  0045    | CallFunction 3
  0047    | InsertKeyVal 1
  0049    | End
  ========================================
  
  ======1:_Doc.AppendToArrayOfTables======
  _Doc.AppendToArrayOfTables(Doc, Key, ElementDoc) =
    _Doc.Get(Doc, Key) -> {"value": Vs, "type": ["array_of_tables", Ts]} &
    _Doc.Insert(
      Doc,
      Key,
      [...Vs, _Doc.Value(ElementDoc)],
      ["array_of_tables", [...Ts, _Doc.Type(ElementDoc)]],
    )
  ========================================
  0000    | PushVar2 Vs
  0003    | PushVar2 Ts
  0006    | GetConstant 74: _Doc.Get
  0008    | GetLocal l0
  0010    | GetLocal l1
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 80
  0017    | MatchWindowEnter 6
  0019    | MatchScrutinee r0
  0021    | MatchType r0 object -> 78
  0026    | MatchKeys r0 2 -> 78
  0031    | MatchKey r1 r0["value"] -> 78
  0038    | MatchBind l3 r1
  0041    | MatchKey r2 r0["type"] -> 78
  0048    | MatchType r2 array -> 78
  0053    | MatchLen r2 2 -> 78
  0058    | MatchElem r3 r2[0]
  0062    | MatchConst r3 "array_of_tables" -> 78
  0068    | MatchElem r4 r2[1]
  0072    | MatchBind l4 r4
  0075    | Jump 75 -> 79
  0078    | MatchFail
  0079    | MatchWindowExit
  0080    | TakeRight 80 -> 137
  0083    | GetConstant 75: _Doc.Insert
  0085    | GetLocalMove l0
  0087    | GetLocalMove l1
  0089    | PushEmptyArray
  0090    | JumpIfFailure 90 -> 96
  0093    | GetLocalMove l3
  0095    | Merge
  0096    | JumpIfFailure 96 -> 110
  0099    | GetConstantMutable 110: [_]
  0101    | GetConstant 7: _Doc.Value
  0103    | GetLocal l2
  0105    | CallFunction 1
  0107    | InsertAtIndex 0
  0109    | Merge
  0110    | GetConstantMutable 111: ["array_of_tables", _]
  0112    | PushEmptyArray
  0113    | JumpIfFailure 113 -> 119
  0116    | GetLocalMove l4
  0118    | Merge
  0119    | JumpIfFailure 119 -> 133
  0122    | GetConstantMutable 112: [_]
  0124    | GetConstant 76: _Doc.Type
  0126    | GetLocalMove l2
  0128    | CallFunction 1
  0130    | InsertAtIndex 0
  0132    | Merge
  0133    | InsertAtIndex 1
  0135    | CallTailFunction 4
  0137    | End
  ========================================
  
  ==========1:_Doc.InsertAtPath===========
  _Doc.InsertAtPath(Doc, Path, Val) =
    _Doc.UpdateAtPath(Doc, Path, Val, _Doc.ValueUpdater)
  ========================================
  0000    | GetConstant 70: _Doc.UpdateAtPath
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | GetLocalMove l2
  0008    | GetConstant 71: _Doc.ValueUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  ========1:_Doc.EnsureTableAtPath========
  _Doc.EnsureTableAtPath(Doc, Path) =
    _Doc.UpdateAtHeaderPath(Doc, Path, {}, _Doc.MissingTableUpdater)
  ========================================
  0000    | GetConstant 67: _Doc.UpdateAtHeaderPath
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | PushEmptyObject
  0007    | GetConstant 98: _Doc.MissingTableUpdater
  0009    | CallTailFunction 4
  0011    | End
  ========================================
  
  ==========1:_Doc.AppendAtPath===========
  _Doc.AppendAtPath(Doc, Path, ElementDoc) =
    _Doc.UpdateAtHeaderPath(Doc, Path, ElementDoc, _Doc.AppendUpdater)
  ========================================
  0000    | GetConstant 67: _Doc.UpdateAtHeaderPath
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | GetLocalMove l2
  0008    | GetConstant 105: _Doc.AppendUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  ==========1:_Doc.UpdateAtPath===========
  _Doc.UpdateAtPath(Doc, Path, Val, Updater) =
    Path -> [Key] ? Updater(Doc, Key, Val) :
    Path -> [Key, ...PathRest] ? (
      (
        _Doc.Has(Doc, Key) ? (
          _Doc.IsTable(_Doc.Get(Doc, Key)) &
          _Doc.UpdateAtPath(_Doc.Get(Doc, Key), PathRest, Val, Updater)
        ) :
        _Doc.UpdateAtPath(_Doc.Empty, PathRest, Val, Updater)
      ) -> InnerDoc &
      _Doc.Insert(Doc, Key, _Doc.Value(InnerDoc), _Doc.Type(InnerDoc))
    ) :
    Doc
  ========================================
  0000    | PushVar2 Key
  0003    | PushVar2 PathRest
  0006    | PushVar2 InnerDoc
  0009    | SetInputMark
  0010    | GetLocal l1
  0012    | JumpIfFailure 12 -> 41
  0015    | MatchWindowEnter 3
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array -> 39
  0024    | MatchLen r0 1 -> 39
  0029    | MatchElem r1 r0[0]
  0033    | MatchBind l4 r1
  0036    | Jump 36 -> 40
  0039    | MatchFail
  0040    | MatchWindowExit
  0041    | ConditionalThen 41 -> 57
  0044    | GetLocalMove l3
  0046    | GetLocalMove l0
  0048    | GetLocalMove l4
  0050    | GetLocalMove l2
  0052    | CallTailFunction 3
  0054    | Jump 54 -> 199
  0057    | SetInputMark
  0058    | GetLocalMove l1
  0060    | JumpIfFailure 60 -> 97
  0063    | MatchWindowEnter 4
  0065    | MatchScrutinee r0
  0067    | MatchType r0 array -> 95
  0072    | MatchLenMin r0 1 -> 95
  0077    | MatchElem r1 r0[0]
  0081    | MatchBind l4 r1
  0084    | MatchSlice r2 r0[1..^0]
  0089    | MatchBind l5 r2
  0092    | Jump 92 -> 96
  0095    | MatchFail
  0096    | MatchWindowExit
  0097    | ConditionalThen 97 -> 197
  0100    | SetInputMark
  0101    | GetConstant 72: _Doc.Has
  0103    | GetLocal l0
  0105    | GetLocal l4
  0107    | CallFunction 2
  0109    | ConditionalThen 109 -> 148
  0112    | GetConstant 73: _Doc.IsTable
  0114    | GetConstant 74: _Doc.Get
  0116    | GetLocal l0
  0118    | GetLocal l4
  0120    | CallFunction 2
  0122    | CallFunction 1
  0124    | TakeRight 124 -> 145
  0127    | GetConstant 70: _Doc.UpdateAtPath
  0129    | GetConstant 74: _Doc.Get
  0131    | GetLocal l0
  0133    | GetLocal l4
  0135    | CallFunction 2
  0137    | GetLocalMove l5
  0139    | GetLocalMove l2
  0141    | GetLocalMove l3
  0143    | CallFunction 4
  0145    | Jump 145 -> 160
  0148    | GetConstant 70: _Doc.UpdateAtPath
  0150    | CallFunctionConstant 14: _Doc.Empty
  0152    | GetLocalMove l5
  0154    | GetLocalMove l2
  0156    | GetLocalMove l3
  0158    | CallFunction 4
  0160    | JumpIfFailure 160 -> 171
  0163    | MatchWindowEnter 2
  0165    | MatchScrutinee r0
  0167    | MatchBind l6 r0
  0170    | MatchWindowExit
  0171    | TakeRight 171 -> 194
  0174    | GetConstant 75: _Doc.Insert
  0176    | GetLocalMove l0
  0178    | GetLocalMove l4
  0180    | GetConstant 7: _Doc.Value
  0182    | GetLocal l6
  0184    | CallFunction 1
  0186    | GetConstant 76: _Doc.Type
  0188    | GetLocalMove l6
  0190    | CallFunction 1
  0192    | CallTailFunction 4
  0194    | Jump 194 -> 199
  0197    | GetLocalMove l0
  0199    | End
  ========================================
  
  ==========1:_Doc.ValueUpdater===========
  _Doc.ValueUpdater(Doc, Key, Val) =
    _Doc.Has(Doc, Key) ? @Fail : _Doc.Insert(Doc, Key, Val, "value")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 72: _Doc.Has
  0003    | GetLocal l0
  0005    | GetLocal l1
  0007    | CallFunction 2
  0009    | ConditionalThen 9 -> 17
  0012    | CallTailFunctionConstant 84: @Fail
  0014    | Jump 14 -> 30
  0017    | GetConstant 75: _Doc.Insert
  0019    | GetLocalMove l0
  0021    | GetLocalMove l1
  0023    | GetLocalMove l2
  0025    | PushString2 "value"
  0028    | CallTailFunction 4
  0030    | End
  ========================================
  
  =======1:_Doc.MissingTableUpdater=======
  _Doc.MissingTableUpdater(Doc, Key, _Val) =
    _Doc.Has(Doc, Key) ?
    (_Doc.IsTable(_Doc.Get(Doc, Key)) & Doc) :
    _Doc.Insert(Doc, Key, {}, {})
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 72: _Doc.Has
  0003    | GetLocal l0
  0005    | GetLocal l1
  0007    | CallFunction 2
  0009    | ConditionalThen 9 -> 32
  0012    | GetConstant 73: _Doc.IsTable
  0014    | GetConstant 74: _Doc.Get
  0016    | GetLocal l0
  0018    | GetLocalMove l1
  0020    | CallFunction 2
  0022    | CallFunction 1
  0024    | TakeRight 24 -> 29
  0027    | GetLocalMove l0
  0029    | Jump 29 -> 42
  0032    | GetConstant 75: _Doc.Insert
  0034    | GetLocalMove l0
  0036    | GetLocalMove l1
  0038    | PushEmptyObject
  0039    | PushEmptyObject
  0040    | CallTailFunction 4
  0042    | End
  ========================================
  
  ==========1:_Doc.AppendUpdater==========
  _Doc.AppendUpdater(Doc, Key, ElementDoc) =
    (
      _Doc.Has(Doc, Key) ? Doc :
      _Doc.Insert(Doc, Key, [], ["array_of_tables", []])
    ) -> DocWithKey &
    _Doc.AppendToArrayOfTables(DocWithKey, Key, ElementDoc)
  ========================================
  0000    | PushVar2 DocWithKey
  0003    | SetInputMark
  0004    | GetConstant 72: _Doc.Has
  0006    | GetLocal l0
  0008    | GetLocal l1
  0010    | CallFunction 2
  0012    | ConditionalThen 12 -> 20
  0015    | GetLocalMove l0
  0017    | Jump 17 -> 31
  0020    | GetConstant 75: _Doc.Insert
  0022    | GetLocalMove l0
  0024    | GetLocal l1
  0026    | PushEmptyArray
  0027    | GetConstant 106: ["array_of_tables", []]
  0029    | CallFunction 4
  0031    | JumpIfFailure 31 -> 42
  0034    | MatchWindowEnter 2
  0036    | MatchScrutinee r0
  0038    | MatchBind l3 r0
  0041    | MatchWindowExit
  0042    | TakeRight 42 -> 55
  0045    | GetConstant 107: _Doc.AppendToArrayOfTables
  0047    | GetLocalMove l3
  0049    | GetLocalMove l1
  0051    | GetLocalMove l2
  0053    | CallTailFunction 3
  0055    | End
  ========================================
  
  =====1:_Doc.InsertPairAtHeaderPath======
  _Doc.InsertPairAtHeaderPath(Doc, HeaderPath, KeyPath, Val) =
    HeaderPath -> [] ? _Doc.InsertAtPath(Doc, KeyPath, Val) :
    _Doc.UpdateAtHeaderPath(Doc, HeaderPath, [KeyPath, Val], _Doc.PairUpdater)
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l1
  0003    | JumpIfFailure 3 -> 25
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 array -> 23
  0015    | MatchLen r0 0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | ConditionalThen 25 -> 41
  0028    | GetConstant 66: _Doc.InsertAtPath
  0030    | GetLocalMove l0
  0032    | GetLocalMove l2
  0034    | GetLocalMove l3
  0036    | CallTailFunction 3
  0038    | Jump 38 -> 61
  0041    | GetConstant 67: _Doc.UpdateAtHeaderPath
  0043    | GetLocalMove l0
  0045    | GetLocalMove l1
  0047    | GetConstantMutable 68: [_, _]
  0049    | GetLocalMove l2
  0051    | InsertAtIndex 0
  0053    | GetLocalMove l3
  0055    | InsertAtIndex 1
  0057    | GetConstant 69: _Doc.PairUpdater
  0059    | CallTailFunction 4
  0061    | End
  ========================================
  
  ===========1:_Doc.PairUpdater===========
  _Doc.PairUpdater(Doc, Key, KeyPathAndVal) =
    KeyPathAndVal -> [KeyPath, Val] &
    (_Doc.Has(Doc, Key) ? _Doc.Get(Doc, Key) : _Doc.Empty) -> SubDoc &
    _Doc.IsTable(SubDoc) &
    _Doc.InsertAtPath(SubDoc, KeyPath, Val) -> NewSubDoc &
    _Doc.Insert(Doc, Key, _Doc.Value(NewSubDoc), _Doc.Type(NewSubDoc))
  ========================================
  0000    | PushVar2 KeyPath
  0003    | PushVar2 Val
  0006    | PushVar2 SubDoc
  0009    | PushVar2 NewSubDoc
  0012    | GetLocalMove l2
  0014    | JumpIfFailure 14 -> 50
  0017    | MatchWindowEnter 4
  0019    | MatchScrutinee r0
  0021    | MatchType r0 array -> 48
  0026    | MatchLen r0 2 -> 48
  0031    | MatchElem r1 r0[0]
  0035    | MatchBind l3 r1
  0038    | MatchElem r2 r0[1]
  0042    | MatchBind l4 r2
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | TakeRight 50 -> 89
  0053    | SetInputMark
  0054    | GetConstant 72: _Doc.Has
  0056    | GetLocal l0
  0058    | GetLocal l1
  0060    | CallFunction 2
  0062    | ConditionalThen 62 -> 76
  0065    | GetConstant 74: _Doc.Get
  0067    | GetLocal l0
  0069    | GetLocal l1
  0071    | CallFunction 2
  0073    | Jump 73 -> 78
  0076    | CallFunctionConstant 14: _Doc.Empty
  0078    | JumpIfFailure 78 -> 89
  0081    | MatchWindowEnter 2
  0083    | MatchScrutinee r0
  0085    | MatchBind l5 r0
  0088    | MatchWindowExit
  0089    | TakeRight 89 -> 98
  0092    | GetConstant 73: _Doc.IsTable
  0094    | GetLocal l5
  0096    | CallFunction 1
  0098    | TakeRight 98 -> 122
  0101    | GetConstant 66: _Doc.InsertAtPath
  0103    | GetLocalMove l5
  0105    | GetLocalMove l3
  0107    | GetLocalMove l4
  0109    | CallFunction 3
  0111    | JumpIfFailure 111 -> 122
  0114    | MatchWindowEnter 2
  0116    | MatchScrutinee r0
  0118    | MatchBind l6 r0
  0121    | MatchWindowExit
  0122    | TakeRight 122 -> 145
  0125    | GetConstant 75: _Doc.Insert
  0127    | GetLocalMove l0
  0129    | GetLocalMove l1
  0131    | GetConstant 7: _Doc.Value
  0133    | GetLocal l6
  0135    | CallFunction 1
  0137    | GetConstant 76: _Doc.Type
  0139    | GetLocalMove l6
  0141    | CallFunction 1
  0143    | CallTailFunction 4
  0145    | End
  ========================================
  
  =======1:_Doc.UpdateAtHeaderPath========
  _Doc.UpdateAtHeaderPath(Doc, Path, Val, Updater) =
    Path -> [Key] ? Updater(Doc, Key, Val) :
    Path -> [Key, ...PathRest] ?
    _Doc.DescendHeaderKey(Doc, Key, PathRest, Val, Updater) :
    Doc
  ========================================
  0000    | PushVar2 Key
  0003    | PushVar2 PathRest
  0006    | SetInputMark
  0007    | GetLocal l1
  0009    | JumpIfFailure 9 -> 38
  0012    | MatchWindowEnter 3
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 36
  0021    | MatchLen r0 1 -> 36
  0026    | MatchElem r1 r0[0]
  0030    | MatchBind l4 r1
  0033    | Jump 33 -> 37
  0036    | MatchFail
  0037    | MatchWindowExit
  0038    | ConditionalThen 38 -> 54
  0041    | GetLocalMove l3
  0043    | GetLocalMove l0
  0045    | GetLocalMove l4
  0047    | GetLocalMove l2
  0049    | CallTailFunction 3
  0051    | Jump 51 -> 116
  0054    | SetInputMark
  0055    | GetLocalMove l1
  0057    | JumpIfFailure 57 -> 94
  0060    | MatchWindowEnter 4
  0062    | MatchScrutinee r0
  0064    | MatchType r0 array -> 92
  0069    | MatchLenMin r0 1 -> 92
  0074    | MatchElem r1 r0[0]
  0078    | MatchBind l4 r1
  0081    | MatchSlice r2 r0[1..^0]
  0086    | MatchBind l5 r2
  0089    | Jump 89 -> 93
  0092    | MatchFail
  0093    | MatchWindowExit
  0094    | ConditionalThen 94 -> 114
  0097    | GetConstant 85: _Doc.DescendHeaderKey
  0099    | GetLocalMove l0
  0101    | GetLocalMove l4
  0103    | GetLocalMove l5
  0105    | GetLocalMove l2
  0107    | GetLocalMove l3
  0109    | CallTailFunction 5
  0111    | Jump 111 -> 116
  0114    | GetLocalMove l0
  0116    | End
  ========================================
  
  ========1:_Doc.DescendHeaderKey=========
  _Doc.DescendHeaderKey(Doc, Key, PathRest, Val, Updater) =
    _Doc.Has(Doc, Key) ? (
      _Doc.Get(Doc, Key) -> Current &
      (
        _Doc.Type(Current) -> ["array_of_tables", ..._] ?
        _Doc.UpdateAtLastAoTElement(Current, PathRest, Val, Updater) :
        _Doc.IsTable(Current) &
        _Doc.UpdateAtHeaderPath(Current, PathRest, Val, Updater)
      ) -> Updated &
      _Doc.Insert(Doc, Key, _Doc.Value(Updated), _Doc.Type(Updated))
    ) : (
      _Doc.UpdateAtHeaderPath(_Doc.Empty, PathRest, Val, Updater) -> InnerDoc &
      _Doc.Insert(Doc, Key, _Doc.Value(InnerDoc), _Doc.Type(InnerDoc))
    )
  ========================================
  0000    | PushVar2 Current
  0003    | PushUnderscoreVar
  0004    | PushVar2 Updated
  0007    | PushVar2 InnerDoc
  0010    | SetInputMark
  0011    | GetConstant 72: _Doc.Has
  0013    | GetLocal l0
  0015    | GetLocal l1
  0017    | CallFunction 2
  0019    | ConditionalThen 19 -> 159
  0022    | GetConstant 74: _Doc.Get
  0024    | GetLocal l0
  0026    | GetLocal l1
  0028    | CallFunction 2
  0030    | JumpIfFailure 30 -> 41
  0033    | MatchWindowEnter 2
  0035    | MatchScrutinee r0
  0037    | MatchBind l5 r0
  0040    | MatchWindowExit
  0041    | TakeRight 41 -> 133
  0044    | SetInputMark
  0045    | GetConstant 76: _Doc.Type
  0047    | GetLocal l5
  0049    | CallFunction 1
  0051    | JumpIfFailure 51 -> 83
  0054    | MatchWindowEnter 3
  0056    | MatchScrutinee r0
  0058    | MatchType r0 array -> 81
  0063    | MatchLenMin r0 1 -> 81
  0068    | MatchElem r1 r0[0]
  0072    | MatchConst r1 "array_of_tables" -> 81
  0078    | Jump 78 -> 82
  0081    | MatchFail
  0082    | MatchWindowExit
  0083    | ConditionalThen 83 -> 101
  0086    | GetConstant 87: _Doc.UpdateAtLastAoTElement
  0088    | GetLocalMove l5
  0090    | GetLocalMove l2
  0092    | GetLocalMove l3
  0094    | GetLocalMove l4
  0096    | CallFunction 4
  0098    | Jump 98 -> 122
  0101    | GetConstant 73: _Doc.IsTable
  0103    | GetLocal l5
  0105    | CallFunction 1
  0107    | TakeRight 107 -> 122
  0110    | GetConstant 67: _Doc.UpdateAtHeaderPath
  0112    | GetLocalMove l5
  0114    | GetLocalMove l2
  0116    | GetLocalMove l3
  0118    | GetLocalMove l4
  0120    | CallFunction 4
  0122    | JumpIfFailure 122 -> 133
  0125    | MatchWindowEnter 2
  0127    | MatchScrutinee r0
  0129    | MatchBind l7 r0
  0132    | MatchWindowExit
  0133    | TakeRight 133 -> 156
  0136    | GetConstant 75: _Doc.Insert
  0138    | GetLocalMove l0
  0140    | GetLocalMove l1
  0142    | GetConstant 7: _Doc.Value
  0144    | GetLocal l7
  0146    | CallFunction 1
  0148    | GetConstant 76: _Doc.Type
  0150    | GetLocalMove l7
  0152    | CallFunction 1
  0154    | CallTailFunction 4
  0156    | Jump 156 -> 205
  0159    | GetConstant 67: _Doc.UpdateAtHeaderPath
  0161    | CallFunctionConstant 14: _Doc.Empty
  0163    | GetLocalMove l2
  0165    | GetLocalMove l3
  0167    | GetLocalMove l4
  0169    | CallFunction 4
  0171    | JumpIfFailure 171 -> 182
  0174    | MatchWindowEnter 2
  0176    | MatchScrutinee r0
  0178    | MatchBind l8 r0
  0181    | MatchWindowExit
  0182    | TakeRight 182 -> 205
  0185    | GetConstant 75: _Doc.Insert
  0187    | GetLocalMove l0
  0189    | GetLocalMove l1
  0191    | GetConstant 7: _Doc.Value
  0193    | GetLocal l8
  0195    | CallFunction 1
  0197    | GetConstant 76: _Doc.Type
  0199    | GetLocalMove l8
  0201    | CallFunction 1
  0203    | CallTailFunction 4
  0205    | End
  ========================================
  
  =====1:_Doc.UpdateAtLastAoTElement======
  _Doc.UpdateAtLastAoTElement(AoTDoc, PathRest, Val, Updater) =
    _Doc.Value(AoTDoc) -> [...VsInit, VLast] &
    _Doc.Type(AoTDoc) -> ["array_of_tables", [...TsInit, TLast]] &
    _Doc.UpdateAtHeaderPath(
      {"value": VLast, "type": TLast}, PathRest, Val, Updater
    ) -> UpdatedLast &
    {
      "value": [...VsInit, _Doc.Value(UpdatedLast)],
      "type": ["array_of_tables", [...TsInit, _Doc.Type(UpdatedLast)]],
    }
  ========================================
  0000    | PushVar2 VsInit
  0003    | PushVar2 VLast
  0006    | PushVar2 TsInit
  0009    | PushVar2 TLast
  0012    | PushVar2 UpdatedLast
  0015    | GetConstant 7: _Doc.Value
  0017    | GetLocal l0
  0019    | CallFunction 1
  0021    | JumpIfFailure 21 -> 58
  0024    | MatchWindowEnter 4
  0026    | MatchScrutinee r0
  0028    | MatchType r0 array -> 56
  0033    | MatchLenMin r0 1 -> 56
  0038    | MatchSlice r1 r0[0..^1]
  0043    | MatchBind l4 r1
  0046    | MatchElemBack r2 r0[^0]
  0050    | MatchBind l5 r2
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | MatchWindowExit
  0058    | TakeRight 58 -> 128
  0061    | GetConstant 76: _Doc.Type
  0063    | GetLocalMove l0
  0065    | CallFunction 1
  0067    | JumpIfFailure 67 -> 128
  0070    | MatchWindowEnter 6
  0072    | MatchScrutinee r0
  0074    | MatchType r0 array -> 126
  0079    | MatchLen r0 2 -> 126
  0084    | MatchElem r1 r0[0]
  0088    | MatchConst r1 "array_of_tables" -> 126
  0094    | MatchElem r2 r0[1]
  0098    | MatchType r2 array -> 126
  0103    | MatchLenMin r2 1 -> 126
  0108    | MatchSlice r3 r2[0..^1]
  0113    | MatchBind l6 r3
  0116    | MatchElemBack r4 r2[^0]
  0120    | MatchBind l7 r4
  0123    | Jump 123 -> 127
  0126    | MatchFail
  0127    | MatchWindowExit
  0128    | TakeRight 128 -> 168
  0131    | GetConstant 67: _Doc.UpdateAtHeaderPath
  0133    | GetConstantMutable 88: {_0_, _1_}
  0135    | PushString2 "value"
  0138    | GetLocalMove l5
  0140    | InsertKeyVal 0
  0142    | PushString2 "type"
  0145    | GetLocalMove l7
  0147    | InsertKeyVal 1
  0149    | GetLocalMove l1
  0151    | GetLocalMove l2
  0153    | GetLocalMove l3
  0155    | CallFunction 4
  0157    | JumpIfFailure 157 -> 168
  0160    | MatchWindowEnter 2
  0162    | MatchScrutinee r0
  0164    | MatchBind l8 r0
  0167    | MatchWindowExit
  0168    | TakeRight 168 -> 229
  0171    | GetConstantMutable 89: {_0_, _1_}
  0173    | PushString2 "value"
  0176    | PushEmptyArray
  0177    | JumpIfFailure 177 -> 183
  0180    | GetLocalMove l4
  0182    | Merge
  0183    | JumpIfFailure 183 -> 197
  0186    | GetConstantMutable 90: [_]
  0188    | GetConstant 7: _Doc.Value
  0190    | GetLocal l8
  0192    | CallFunction 1
  0194    | InsertAtIndex 0
  0196    | Merge
  0197    | InsertKeyVal 0
  0199    | PushString2 "type"
  0202    | GetConstantMutable 91: ["array_of_tables", _]
  0204    | PushEmptyArray
  0205    | JumpIfFailure 205 -> 211
  0208    | GetLocalMove l6
  0210    | Merge
  0211    | JumpIfFailure 211 -> 225
  0214    | GetConstantMutable 92: [_]
  0216    | GetConstant 76: _Doc.Type
  0218    | GetLocalMove l8
  0220    | CallFunction 1
  0222    | InsertAtIndex 0
  0224    | Merge
  0225    | InsertAtIndex 1
  0227    | InsertKeyVal 1
  0229    | End
  ========================================
  
  ================1:@main=================
  simple
  ========================================
  0000    | CallTailFunctionConstant 208: simple
  0002    | End
  ========================================
  
  =================1:@fn0=================
  _comments + maybe(ws)
  ========================================
  0000    | CallFunctionConstant 8: _comments
  0002    | JumpIfFailure 2 -> 12
  0005    | GetConstant 2: maybe
  0007    | GetConstant 9: whitespace
  0009    | CallFunction 1
  0011    | Merge
  0012    | End
  ========================================
  
  =================1:@fn1=================
  maybe(ws) + _comments
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 8: _comments
  0011    | Merge
  0012    | End
  ========================================
  
  =================1:@fn2=================
  _table_body(value, [], _Doc.Empty)
  ========================================
  0000    | PushVar2 value
  0003    | SetClosureCaptures
  0004    | GetConstant 18: _table_body
  0006    | GetLocalMove l0
  0008    | PushEmptyArray
  0009    | CallFunctionConstant 14: _Doc.Empty
  0011    | CallTailFunction 3
  0013    | End
  ========================================
  
  =================1:@fn3=================
  ws | _comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 9: whitespace
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 11: _comment
  0008    | End
  ========================================
  
  =================1:@fn4=================
  spaces | _comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 59: spaces
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 11: _comment
  0008    | End
  ========================================
  
  =================1:@fn5=================
  maybe(ws)
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn6=================
  maybe(ws)
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn8=================
  maybe(spaces)
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 59: spaces
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn7=================
  surround("=", maybe(spaces))
  ========================================
  0000    | GetConstant 56: surround
  0002    | PushString2 "="
  0005    | GetConstant 58: @fn8
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn10=================
  maybe(ws)
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn9=================
  surround(".", maybe(ws))
  ========================================
  0000    | GetConstant 56: surround
  0002    | PushString2 "."
  0005    | GetConstant 57: @fn10
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn11=================
  alpha | numeral | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 32: alpha
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 33: numeral
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | ParseChar '_'
  0015    | Or 15 -> 20
  0018    | ParseChar '-'
  0020    | End
  ========================================
  
  ================1:@fn13=================
  surround(elem, _ws)
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 56: surround
  0006    | GetLocalMove l0
  0008    | GetConstant 15: _ws
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ================1:@fn14=================
  surround(",", _ws)
  ========================================
  0000    | GetConstant 56: surround
  0002    | PushString2 ","
  0005    | GetConstant 15: _ws
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn12=================
  array_sep(surround(elem, _ws), ",") < maybe(surround(",", _ws))
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 25: array_sep
  0006    | GetConstant 199: @fn13
  0008    | CreateClosure 1
  0010    | CaptureLocal l0
  0012    | PushString2 ","
  0015    | CallFunction 2
  0017    | JumpIfFailure 17 -> 27
  0020    | GetConstant 2: maybe
  0022    | GetConstant 200: @fn14
  0024    | CallFunction 1
  0026    | TakeLeft
  0027    | End
  ========================================
  
  ================1:@fn15=================
  maybe(nl)
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 61: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn18=================
  ctrl_char | `\`
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 52: ctrl_char
  0003    | Or 3 -> 8
  0006    | ParseChar '\'
  0008    | End
  ========================================
  
  ================1:@fn17=================
  _escaped_ctrl_char | _escaped_unicode |
        ws | (`\` + ws > "") | unless(char, ctrl_char | `\`)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 36: _escaped_ctrl_char
  0003    | Or 3 -> 42
  0006    | SetInputMark
  0007    | CallFunctionConstant 37: _escaped_unicode
  0009    | Or 9 -> 42
  0012    | SetInputMark
  0013    | CallFunctionConstant 9: whitespace
  0015    | Or 15 -> 42
  0018    | SetInputMark
  0019    | ParseChar '\'
  0021    | JumpIfFailure 21 -> 27
  0024    | CallFunctionConstant 9: whitespace
  0026    | Merge
  0027    | TakeRight 27 -> 31
  0030    | PushEmptyString
  0031    | Or 31 -> 42
  0034    | GetConstant 38: unless
  0036    | GetConstant 39: char
  0038    | GetConstant 126: @fn18
  0040    | CallTailFunction 2
  0042    | End
  ========================================
  
  ================1:@fn16=================
  many_until(
        _escaped_ctrl_char | _escaped_unicode |
        ws | (`\` + ws > "") | unless(char, ctrl_char | `\`),
        `"""`
      )
  ========================================
  0000    | GetConstant 124: many_until
  0002    | GetConstant 125: @fn17
  0004    | PushString2 """""
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn19=================
  maybe(nl)
  ========================================
  0000    | GetConstant 2: maybe
  0002    | GetConstant 61: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn20=================
  many_until(char, `'''`)
  ========================================
  0000    | GetConstant 124: many_until
  0002    | GetConstant 39: char
  0004    | PushString2 "'''"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn22=================
  ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 52: ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  ================1:@fn21=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 36: _escaped_ctrl_char
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 37: _escaped_unicode
  0009    | Or 9 -> 20
  0012    | GetConstant 38: unless
  0014    | GetConstant 39: char
  0016    | GetConstant 40: @fn22
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ================1:@fn23=================
  chars_until("'")
  ========================================
  0000    | GetConstant 55: chars_until
  0002    | PushString2 "'"
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ================1:@fn24=================
  "." + (numeral * 1..9)
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 60
  0005    | PushNull
  0006    | PushInteger 1
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 27
  0012    | Swap
  0013    | CallFunctionConstant 33: numeral
  0015    | Merge
  0016    | JumpIfFailure 16 -> 57
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 12
  0027    | Drop
  0028    | PushInteger 9
  0030    | PushInteger 1
  0032    | NegateNumber
  0033    | Merge
  0034    | ValidateRepeatPattern
  0035    | JumpIfZero 35 -> 58
  0038    | Swap
  0039    | SetInputMark
  0040    | CallFunctionConstant 33: numeral
  0042    | JumpIfFailure 42 -> 55
  0045    | PopInputMark
  0046    | Merge
  0047    | Swap
  0048    | Decrement
  0049    | JumpIfZero 49 -> 58
  0052    | JumpBack 52 -> 38
  0055    | ResetInput
  0056    | Drop
  0057    | Swap
  0058    | Drop
  0059    | Merge
  0060    | End
  ========================================
  
  ================1:@fn25=================
  _number.sign +
    _number.integer_part
  ========================================
  0000    | CallFunctionConstant 186: _number.sign
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 187: _number.integer_part
  0007    | Merge
  0008    | End
  ========================================
  
  ================1:@fn26=================
  "-" | skip("+")
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 13
  0006    | GetConstant 121: skip
  0008    | PushString2 "+"
  0011    | CallTailFunction 1
  0013    | End
  ========================================
  
  ================1:@fn27=================
  maybe("_") > numeral
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 11
  0009    | CallTailFunctionConstant 33: numeral
  0011    | End
  ========================================
  
  ================1:@fn28=================
  _number.sign +
    _number.integer_part + (
      (_number.fraction_part + maybe(_number.exponent_part)) |
      _number.exponent_part
    )
  ========================================
  0000    | CallFunctionConstant 186: _number.sign
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 187: _number.integer_part
  0007    | Merge
  0008    | JumpIfFailure 8 -> 30
  0011    | SetInputMark
  0012    | CallFunctionConstant 188: _number.fraction_part
  0014    | JumpIfFailure 14 -> 24
  0017    | GetConstant 2: maybe
  0019    | GetConstant 189: _number.exponent_part
  0021    | CallFunction 1
  0023    | Merge
  0024    | Or 24 -> 29
  0027    | CallFunctionConstant 189: _number.exponent_part
  0029    | Merge
  0030    | End
  ========================================
  
  ================1:@fn29=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn30=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
  ========================================
  
  ================1:@fn31=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn32=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | End
  ========================================
  
  ================1:@fn33=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | End
  ========================================
  
  ================1:@fn35=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn36=================
  skip("_") < peek(binary_numeral)
  ========================================
  0000    | GetConstant 121: skip
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 159: peek
  0011    | GetConstant 160: binary_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ================1:@fn34=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral))
  ========================================
  0000    | GetConstant 25: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant 157: @fn35
  0005    | CallFunction 2
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 2: maybe
  0012    | GetConstant 158: @fn36
  0014    | CallFunction 1
  0016    | Merge
  0017    | End
  ========================================
  
  ================1:@fn38=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn37=================
  array_sep(binary_digit, maybe("_"))
  ========================================
  0000    | GetConstant 25: array_sep
  0002    | GetConstant 161: binary_digit
  0004    | GetConstant 162: @fn38
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================1:@fn40=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn41=================
  skip("_") < peek(octal_numeral)
  ========================================
  0000    | GetConstant 121: skip
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 159: peek
  0011    | GetConstant 169: octal_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ================1:@fn39=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral))
  ========================================
  0000    | GetConstant 25: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant 167: @fn40
  0005    | CallFunction 2
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 2: maybe
  0012    | GetConstant 168: @fn41
  0014    | CallFunction 1
  0016    | Merge
  0017    | End
  ========================================
  
  ================1:@fn43=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn42=================
  array_sep(octal_digit, maybe("_"))
  ========================================
  0000    | GetConstant 25: array_sep
  0002    | GetConstant 170: octal_digit
  0004    | GetConstant 171: @fn43
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================1:@fn45=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn46=================
  skip("_") < peek(hex_numeral)
  ========================================
  0000    | GetConstant 121: skip
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 159: peek
  0011    | GetConstant 49: hex_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ================1:@fn44=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral))
  ========================================
  0000    | GetConstant 25: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant 176: @fn45
  0005    | CallFunction 2
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 2: maybe
  0012    | GetConstant 177: @fn46
  0014    | CallFunction 1
  0016    | Merge
  0017    | End
  ========================================
  
  ================1:@fn48=================
  maybe("_")
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn47=================
  array_sep(hex_digit, maybe("_"))
  ========================================
  0000    | GetConstant 25: array_sep
  0002    | GetConstant 178: hex_digit
  0004    | GetConstant 179: @fn48
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================2:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  ================2:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ===============2:numeral================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ===============2:numerals===============
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 10: many
  0002    | GetConstant 17: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ============2:binary_numeral============
  binary_numeral = "0" | "1"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '0'
  0003    | Or 3 -> 8
  0006    | ParseChar '1'
  0008    | End
  ========================================
  
  ============2:octal_numeral=============
  octal_numeral = "0".."7"
  ========================================
  0000    | ParseCodepointRange '0'..'7'
  0003    | End
  ========================================
  
  =============2:hex_numeral==============
  hex_numeral = numeral | "a".."f" | "A".."F"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 17: numeral
  0003    | Or 3 -> 16
  0006    | SetInputMark
  0007    | ParseCodepointRange 'a'..'f'
  0010    | Or 10 -> 16
  0013    | ParseCodepointRange 'A'..'F'
  0016    | End
  ========================================
  
  =================2:line=================
  line = chars_until(newline | end_of_input)
  ========================================
  0000    | GetConstant 0: chars_until
  0002    | GetConstant 1: @fn2
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================2:space=================
  space =
    " " | "\t" | "\u0000A0" | "\u002000".."\u00200A" | "\u00202F" | "\u00205F" | "\u003000"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar ' '
  0003    | Or 3 -> 43
  0006    | SetInputMark
  0007    | ParseChar '\t' (esc)
  0009    | Or 9 -> 43
  0012    | SetInputMark
  0013    | CallFunctionConstant 13: "\xc2\xa0" (esc)
  0015    | Or 15 -> 43
  0018    | SetInputMark
  0019    | PushString2 "\xe2\x80\x80" (esc)
  0022    | PushString2 "\xe2\x80\x8a" (esc)
  0025    | ParseRange
  0026    | Or 26 -> 43
  0029    | SetInputMark
  0030    | CallFunctionConstant 14: "\xe2\x80\xaf" (esc)
  0032    | Or 32 -> 43
  0035    | SetInputMark
  0036    | CallFunctionConstant 15: "\xe2\x81\x9f" (esc)
  0038    | Or 38 -> 43
  0041    | CallTailFunctionConstant 16: "\xe3\x80\x80" (esc)
  0043    | End
  ========================================
  
  ================2:spaces================
  spaces = many(space)
  ========================================
  0000    | GetConstant 10: many
  0002    | GetConstant 12: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============2:newline================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 6: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 7: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 8: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 9: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  ===============2:newline================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 6: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 7: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 8: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 9: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  ==============2:whitespace==============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 10: many
  0002    | GetConstant 11: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============2:whitespace==============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 10: many
  0002    | GetConstant 11: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============2:chars_until==============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 2: many_until
  0002    | GetConstant 3: char
  0004    | GetLocalMove l0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==============2:ctrl_char===============
  ctrl_char = "\u000000".."\u00001F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x1f' (esc)
  0003    | End
  ========================================
  
  =================2:@fn2=================
  newline | end_of_input
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 4: newline
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 5: end_of_input
  0008    | End
  ========================================
  
  =================2:@fn3=================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 12: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: newline
  0008    | End
  ========================================
  
  =================3:many=================
  many(p) = p * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | CallFunctionLocal l0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal l0
  0026    | JumpIfFailure 26 -> 34
  0029    | PopInputMark
  0030    | Merge
  0031    | JumpBack 31 -> 23
  0034    | ResetInput
  0035    | Drop
  0036    | Swap
  0037    | Drop
  0038    | End
  ========================================
  
  ===============3:many_sep===============
  many_sep(p, sep) = p + ((sep > p) * 0..)
  ========================================
  0000    | CallFunctionLocal l0
  0002    | JumpIfFailure 2 -> 54
  0005    | PushNull
  0006    | PushInteger 0
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 32
  0012    | Swap
  0013    | CallFunctionLocal l1
  0015    | TakeRight 15 -> 20
  0018    | CallFunctionLocal l0
  0020    | Merge
  0021    | JumpIfFailure 21 -> 51
  0024    | Swap
  0025    | Decrement
  0026    | JumpIfZero 26 -> 32
  0029    | JumpBack 29 -> 12
  0032    | Swap
  0033    | SetInputMark
  0034    | CallFunctionLocal l1
  0036    | TakeRight 36 -> 41
  0039    | CallFunctionLocal l0
  0041    | JumpIfFailure 41 -> 49
  0044    | PopInputMark
  0045    | Merge
  0046    | JumpBack 46 -> 33
  0049    | ResetInput
  0050    | Drop
  0051    | Swap
  0052    | Drop
  0053    | Merge
  0054    | End
  ========================================
  
  ==============3:many_until==============
  many_until(p, stop) = unless(p, stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 2: unless
  0010    | GetLocal l0
  0012    | GetLocal l1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 2: unless
  0032    | GetLocal l0
  0034    | GetLocal l1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | JumpIfFailure 50 -> 60
  0053    | GetConstant 3: peek
  0055    | GetLocalMove l1
  0057    | CallFunction 1
  0059    | TakeLeft
  0060    | End
  ========================================
  
  ==============3:maybe_many==============
  maybe_many(p) = p * 0..
  ========================================
  0000    | PushNull
  0001    | PushInteger 0
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 22
  0007    | Swap
  0008    | CallFunctionLocal l0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal l0
  0026    | JumpIfFailure 26 -> 34
  0029    | PopInputMark
  0030    | Merge
  0031    | JumpBack 31 -> 23
  0034    | ResetInput
  0035    | Drop
  0036    | Swap
  0037    | Drop
  0038    | End
  ========================================
  
  =================3:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | CallFunctionConstant 5: @input.offset
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 26
  0018    | GetConstant 6: @at
  0020    | GetLocalMove l1
  0022    | GetLocalMove l0
  0024    | CallTailFunction 2
  0026    | End
  ========================================
  
  ================3:maybe=================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 0: succeed
  0008    | End
  ========================================
  
  ================3:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 4: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal l0
  0013    | End
  ========================================
  
  =================3:skip=================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 8: null
  0002    | GetLocalMove l0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============3:succeed================
  succeed = const($null)
  ========================================
  0000    | GetConstant 1: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ===============3:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l0
  0003    | Or 3 -> 12
  0006    | GetConstant 1: const
  0008    | GetLocalMove l1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================3:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ==============3:as_number===============
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | CallFunctionLocal l0
  0011    | JumpIfFailure 11 -> 33
  0014    | MatchScrutinee r2
  0016    | MatchType r2 string -> 32
  0021    | MatchCastNum r6 <- r2 -> 32
  0026    | MatchBind l1 r6
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | TakeRight 33 -> 38
  0036    | GetLocalMove l1
  0038    | End
  ========================================
  
  ===============3:surround===============
  surround(p, fill) = fill > p < fill
  ========================================
  0000    | CallFunctionLocal l1
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionLocal l0
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionLocal l1
  0012    | TakeLeft
  0013    | End
  ========================================
  
  =============3:end_of_input=============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 7: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 4: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 0: succeed
  0013    | End
  ========================================
  
  =============3:end_of_input=============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 7: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 4: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 0: succeed
  0013    | End
  ========================================
  
  =============3:one_or_both==============
  one_or_both(a, b) = (a + maybe(b)) | (maybe(a) + b)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l0
  0003    | JumpIfFailure 3 -> 13
  0006    | GetConstant 9: maybe
  0008    | GetLocal l1
  0010    | CallFunction 1
  0012    | Merge
  0013    | Or 13 -> 28
  0016    | GetConstant 9: maybe
  0018    | GetLocalMove l0
  0020    | CallFunction 1
  0022    | JumpIfFailure 22 -> 28
  0025    | CallFunctionLocal l1
  0027    | Merge
  0028    | End
  ========================================
  
  =================4:true=================
  true(t) = t $ true
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 6
  0005    | PushTrue
  0006    | End
  ========================================
  
  ================4:false=================
  false(f) = f $ false
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 6
  0005    | PushFalse
  0006    | End
  ========================================
  
  ===============4:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetLocalMove l0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetLocalMove l1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  =================4:null=================
  null(n) = n $ null
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 6
  0005    | PushNull
  0006    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =============6:binary_digit=============
  binary_digit = 0..1
  ========================================
  0000    | ParseIntegerRange 0..1
  0003    | End
  ========================================
  
  =============6:octal_digit==============
  octal_digit = 0..7
  ========================================
  0000    | ParseIntegerRange 0..7
  0003    | End
  ========================================
  
  ==============6:hex_digit===============
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
  0001    | CallFunctionConstant 0: digit
  0003    | Or 3 -> 104
  0006    | SetInputMark
  0007    | SetInputMark
  0008    | ParseChar 'a'
  0010    | Or 10 -> 15
  0013    | ParseChar 'A'
  0015    | TakeRight 15 -> 20
  0018    | PushInteger 10
  0020    | Or 20 -> 104
  0023    | SetInputMark
  0024    | SetInputMark
  0025    | ParseChar 'b'
  0027    | Or 27 -> 32
  0030    | ParseChar 'B'
  0032    | TakeRight 32 -> 37
  0035    | PushInteger 11
  0037    | Or 37 -> 104
  0040    | SetInputMark
  0041    | SetInputMark
  0042    | ParseChar 'c'
  0044    | Or 44 -> 49
  0047    | ParseChar 'C'
  0049    | TakeRight 49 -> 54
  0052    | PushInteger 12
  0054    | Or 54 -> 104
  0057    | SetInputMark
  0058    | SetInputMark
  0059    | ParseChar 'd'
  0061    | Or 61 -> 66
  0064    | ParseChar 'D'
  0066    | TakeRight 66 -> 71
  0069    | PushInteger 13
  0071    | Or 71 -> 104
  0074    | SetInputMark
  0075    | SetInputMark
  0076    | ParseChar 'e'
  0078    | Or 78 -> 83
  0081    | ParseChar 'E'
  0083    | TakeRight 83 -> 88
  0086    | PushInteger 14
  0088    | Or 88 -> 104
  0091    | SetInputMark
  0092    | ParseChar 'f'
  0094    | Or 94 -> 99
  0097    | ParseChar 'F'
  0099    | TakeRight 99 -> 104
  0102    | PushInteger 15
  0104    | End
  ========================================
  
  ==============7:array_sep===============
  array_sep(elem, sep) = tuple1(elem) + (tuple1(sep > elem) * 0..)
  ========================================
  0000    | GetConstant 1: tuple1
  0002    | GetLocal l0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 68
  0009    | PushNull
  0010    | PushInteger 0
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 41
  0016    | Swap
  0017    | GetConstant 1: tuple1
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
  0043    | GetConstant 1: tuple1
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
  
  ================7:tuple1================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal l0
  0005    | JumpIfFailure 5 -> 16
  0008    | MatchWindowEnter 2
  0010    | MatchScrutinee r0
  0012    | MatchBind l1 r0
  0015    | MatchWindowExit
  0016    | TakeRight 16 -> 25
  0019    | GetConstantMutable 3: [_]
  0021    | GetLocalMove l1
  0023    | InsertAtIndex 0
  0025    | End
  ========================================
  
  ==============7:tuple2_sep==============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar2 E1
  0003    | PushVar2 E2
  0006    | CallFunctionLocal l0
  0008    | JumpIfFailure 8 -> 19
  0011    | MatchWindowEnter 2
  0013    | MatchScrutinee r0
  0015    | MatchBind l3 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 24
  0022    | CallFunctionLocal l1
  0024    | TakeRight 24 -> 53
  0027    | CallFunctionLocal l2
  0029    | JumpIfFailure 29 -> 40
  0032    | MatchWindowEnter 2
  0034    | MatchScrutinee r0
  0036    | MatchBind l4 r0
  0039    | MatchWindowExit
  0040    | TakeRight 40 -> 53
  0043    | GetConstantMutable 0: [_, _]
  0045    | GetLocalMove l3
  0047    | InsertAtIndex 0
  0049    | GetLocalMove l4
  0051    | InsertAtIndex 1
  0053    | End
  ========================================
  
  =================7:@fn0=================
  sep > elem
  ========================================
  0000    | PushVar2 sep
  0003    | PushVar2 elem
  0006    | SetClosureCaptures
  0007    | CallFunctionLocal l0
  0009    | TakeRight 9 -> 14
  0012    | CallTailFunctionLocal l1
  0014    | End
  ========================================
  
  =============8:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar2 L
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 30
  0014    | MatchScrutinee r3
  0016    | MatchRepeatInit r3 /1 n=r5 base=r6 -> 29
  0023    | MatchBind l2 r5
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | TakeRight 30 -> 35
  0033    | GetLocalMove l2
  0035    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 9: multiplyNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 11: powerNative
  0006    | End
  ========================================
  
  =========9:Num.FromBinaryDigits=========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | GetConstant 0: Array.Length
  0005    | GetLocal l0
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 20
  0012    | MatchWindowEnter 2
  0014    | MatchScrutinee r0
  0016    | MatchBind l1 r0
  0019    | MatchWindowExit
  0020    | TakeRight 20 -> 39
  0023    | GetConstant 1: _Num.FromBinaryDigits
  0025    | GetLocalMove l0
  0027    | GetLocalMove l1
  0029    | JumpIfFailure 29 -> 35
  0032    | PushNegInteger -1
  0034    | Merge
  0035    | PushInteger 0
  0037    | CallTailFunction 3
  0039    | End
  ========================================
  
  ========9:_Num.FromBinaryDigits=========
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
  0000    | PushVar2 B
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetLocalMove l0
  0009    | JumpIfFailure 9 -> 46
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 44
  0021    | MatchLenMin r0 1 -> 44
  0026    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 113
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 73
  0054    | MatchWindowEnter 2
  0056    | MatchScrutinee r0
  0058    | MatchInRange r0 0..1 -> 71
  0068    | Jump 68 -> 72
  0071    | MatchFail
  0072    | MatchWindowExit
  0073    | TakeRight 73 -> 110
  0076    | GetConstant 1: _Num.FromBinaryDigits
  0078    | GetLocalMove l4
  0080    | GetLocal l1
  0082    | JumpIfFailure 82 -> 88
  0085    | PushNegInteger -1
  0087    | Merge
  0088    | GetLocalMove l2
  0090    | JumpIfFailure 90 -> 108
  0093    | GetConstant 4: @Multiply
  0095    | GetLocalMove l3
  0097    | GetConstant 5: @Power
  0099    | PushInteger 2
  0101    | GetLocalMove l1
  0103    | CallFunction 2
  0105    | CallFunction 2
  0107    | Merge
  0108    | CallTailFunction 3
  0110    | Jump 110 -> 115
  0113    | GetLocalMove l2
  0115    | End
  ========================================
  
  =========9:Num.FromOctalDigits==========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | GetConstant 0: Array.Length
  0005    | GetLocal l0
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 20
  0012    | MatchWindowEnter 2
  0014    | MatchScrutinee r0
  0016    | MatchBind l1 r0
  0019    | MatchWindowExit
  0020    | TakeRight 20 -> 39
  0023    | GetConstant 6: _Num.FromOctalDigits
  0025    | GetLocalMove l0
  0027    | GetLocalMove l1
  0029    | JumpIfFailure 29 -> 35
  0032    | PushNegInteger -1
  0034    | Merge
  0035    | PushInteger 0
  0037    | CallTailFunction 3
  0039    | End
  ========================================
  
  =========9:_Num.FromOctalDigits=========
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
  0000    | PushVar2 O
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetLocalMove l0
  0009    | JumpIfFailure 9 -> 46
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 44
  0021    | MatchLenMin r0 1 -> 44
  0026    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 113
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 73
  0054    | MatchWindowEnter 2
  0056    | MatchScrutinee r0
  0058    | MatchInRange r0 0..7 -> 71
  0068    | Jump 68 -> 72
  0071    | MatchFail
  0072    | MatchWindowExit
  0073    | TakeRight 73 -> 110
  0076    | GetConstant 6: _Num.FromOctalDigits
  0078    | GetLocalMove l4
  0080    | GetLocal l1
  0082    | JumpIfFailure 82 -> 88
  0085    | PushNegInteger -1
  0087    | Merge
  0088    | GetLocalMove l2
  0090    | JumpIfFailure 90 -> 108
  0093    | GetConstant 4: @Multiply
  0095    | GetLocalMove l3
  0097    | GetConstant 5: @Power
  0099    | PushInteger 8
  0101    | GetLocalMove l1
  0103    | CallFunction 2
  0105    | CallFunction 2
  0107    | Merge
  0108    | CallTailFunction 3
  0110    | Jump 110 -> 115
  0113    | GetLocalMove l2
  0115    | End
  ========================================
  
  ==========9:Num.FromHexDigits===========
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | GetConstant 0: Array.Length
  0005    | GetLocal l0
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 20
  0012    | MatchWindowEnter 2
  0014    | MatchScrutinee r0
  0016    | MatchBind l1 r0
  0019    | MatchWindowExit
  0020    | TakeRight 20 -> 39
  0023    | GetConstant 8: _Num.FromHexDigits
  0025    | GetLocalMove l0
  0027    | GetLocalMove l1
  0029    | JumpIfFailure 29 -> 35
  0032    | PushNegInteger -1
  0034    | Merge
  0035    | PushInteger 0
  0037    | CallTailFunction 3
  0039    | End
  ========================================
  
  ==========9:_Num.FromHexDigits==========
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
  0000    | PushVar2 H
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetLocalMove l0
  0009    | JumpIfFailure 9 -> 46
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 44
  0021    | MatchLenMin r0 1 -> 44
  0026    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 113
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 73
  0054    | MatchWindowEnter 2
  0056    | MatchScrutinee r0
  0058    | MatchInRange r0 0..15 -> 71
  0068    | Jump 68 -> 72
  0071    | MatchFail
  0072    | MatchWindowExit
  0073    | TakeRight 73 -> 110
  0076    | GetConstant 8: _Num.FromHexDigits
  0078    | GetLocalMove l4
  0080    | GetLocal l1
  0082    | JumpIfFailure 82 -> 88
  0085    | PushNegInteger -1
  0087    | Merge
  0088    | GetLocalMove l2
  0090    | JumpIfFailure 90 -> 108
  0093    | GetConstant 4: @Multiply
  0095    | GetLocalMove l3
  0097    | GetConstant 5: @Power
  0099    | PushInteger 16
  0101    | GetLocalMove l1
  0103    | CallFunction 2
  0105    | CallFunction 2
  0107    | Merge
  0108    | CallTailFunction 3
  0110    | Jump 110 -> 115
  0113    | GetLocalMove l2
  0115    | End
  ========================================
  
  ===============13:Obj.Has===============
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove l0
  0003    | JumpIfFailure 3 -> 35
  0006    | MatchWindowEnter 5
  0008    | MatchScrutinee r0
  0010    | MatchType r0 object -> 33
  0015    | MatchKeysMin r0 1 -> 33
  0020    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 33
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================
  
  ===============13:Obj.Get===============
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar2 V
  0003    | PushUnderscoreVar
  0004    | GetLocalMove l0
  0006    | JumpIfFailure 6 -> 41
  0009    | MatchWindowEnter 5
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object -> 39
  0018    | MatchKeysMin r0 1 -> 39
  0023    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 39
  0033    | MatchBind l2 r3
  0036    | Jump 36 -> 40
  0039    | MatchFail
  0040    | MatchWindowExit
  0041    | TakeRight 41 -> 46
  0044    | GetLocalMove l2
  0046    | End
  ========================================
  
  ===============13:Obj.Put===============
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | JumpIfFailure 1 -> 7
  0004    | GetLocalMove l0
  0006    | Merge
  0007    | JumpIfFailure 7 -> 19
  0010    | GetConstantMutable 2: {_0_}
  0012    | GetLocalMove l1
  0014    | GetLocalMove l2
  0016    | InsertKeyVal 0
  0018    | Merge
  0019    | End
  ========================================
  
  ==============14:Is.Object==============
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetLocalMove l0
  0003    | JumpIfFailure 3 -> 20
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 object -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | End
  ========================================
