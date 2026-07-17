  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/json.possum -i '' --no-stdlib
  
  ================0:@fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ==============0:@Codepoint==============
  0000    | GetLocal 0
  0002    | NativeCode 3: stringToCodepointNative
  0004    | End
  ========================================
  
  =======0:@SurrogatePairCodepoint========
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 1: stringsToSurrogateCodepointNative
  0006    | End
  ========================================
  
  ================1:value=================
  value =
    boolean |
    null |
    number |
    string |
    array(value) |
    object(value)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 0: boolean
  0003    | Or 3 -> 40
  0006    | SetInputMark
  0007    | CallFunctionConstant 1: null
  0009    | Or 9 -> 40
  0012    | SetInputMark
  0013    | CallFunctionConstant 2: number
  0015    | Or 15 -> 40
  0018    | SetInputMark
  0019    | CallFunctionConstant 3: string
  0021    | Or 21 -> 40
  0024    | SetInputMark
  0025    | GetConstant 4: array
  0027    | GetConstant 5: value
  0029    | CallFunction 1
  0031    | Or 31 -> 40
  0034    | GetConstant 6: object
  0036    | GetConstant 5: value
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  ===============1:boolean================
  boolean = !stdlib.boolean("true", "false")
  ========================================
  0000    | GetConstant 7: boolean
  0002    | PushString "true"
  0004    | PushString "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================1:null=================
  null = !stdlib.null("null")
  ========================================
  0000    | GetConstant 8: null
  0002    | PushString "null"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:string================
  string = '"' > _string_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 9: _string_body
  0007    | JumpIfFailure 7 -> 13
  0010    | ParseChar '"'
  0012    | TakeLeft
  0013    | End
  ========================================
  
  =============1:_string_body=============
  _string_body =
    many(
      _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, ctrl_char | `\` | '"')
    ) | const($"")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 10: many
  0003    | GetConstant 11: @fn0
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 12: const
  0012    | PushEmptyString
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  ==========1:_escaped_ctrl_char==========
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
  0001    | CallFunctionConstant 18: "\""
  0003    | TakeRight 3 -> 9
  0006    | PushString2 """
  0009    | Or 9 -> 92
  0012    | SetInputMark
  0013    | CallFunctionConstant 19: "\\"
  0015    | TakeRight 15 -> 21
  0018    | PushString2 "\"
  0021    | Or 21 -> 92
  0024    | SetInputMark
  0025    | CallFunctionConstant 20: "\/"
  0027    | TakeRight 27 -> 33
  0030    | PushString2 "/"
  0033    | Or 33 -> 92
  0036    | SetInputMark
  0037    | CallFunctionConstant 21: "\b"
  0039    | TakeRight 39 -> 45
  0042    | PushString2 "\x08" (esc)
  0045    | Or 45 -> 92
  0048    | SetInputMark
  0049    | CallFunctionConstant 22: "\f"
  0051    | TakeRight 51 -> 57
  0054    | PushString2 "\x0c" (esc)
  0057    | Or 57 -> 92
  0060    | SetInputMark
  0061    | CallFunctionConstant 23: "\n"
  0063    | TakeRight 63 -> 69
  0066    | PushString2 "
  "
  0069    | Or 69 -> 92
  0072    | SetInputMark
  0073    | CallFunctionConstant 24: "\r"
  0075    | TakeRight 75 -> 81
  0078    | PushString2 "\r (no-eol) (esc)
  "
  0081    | Or 81 -> 92
  0084    | CallFunctionConstant 25: "\t"
  0086    | TakeRight 86 -> 92
  0089    | PushString2 "\t" (esc)
  0092    | End
  ========================================
  
  ===========1:_escaped_unicode===========
  _escaped_unicode = _escaped_surrogate_pair | _escaped_codepoint
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 26: _escaped_surrogate_pair
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 27: _escaped_codepoint
  0008    | End
  ========================================
  
  =======1:_escaped_surrogate_pair========
  _escaped_surrogate_pair = _valid_surrogate_pair | _invalid_surrogate_pair
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 28: _valid_surrogate_pair
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 29: _invalid_surrogate_pair
  0008    | End
  ========================================
  
  ========1:_valid_surrogate_pair=========
  _valid_surrogate_pair =
    _high_surrogate -> H & _low_surrogate -> L $ @SurrogatePairCodepoint(H, L)
  ========================================
  0000    | PushVar2 H
  0003    | PushVar2 L
  0006    | CallFunctionConstant 30: _high_surrogate
  0008    | DestructurePlan 0: bind H
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionConstant 31: _low_surrogate
  0015    | DestructurePlan 1: bind L
  0017    | TakeRight 17 -> 28
  0020    | GetConstant 32: @SurrogatePairCodepoint
  0022    | GetLocalMove 0
  0024    | GetLocalMove 1
  0026    | CallTailFunction 2
  0028    | End
  ========================================
  
  =======1:_invalid_surrogate_pair========
  _invalid_surrogate_pair = _low_surrogate | _high_surrogate $ "\u00FFFD"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 31: _low_surrogate
  0003    | Or 3 -> 8
  0006    | CallFunctionConstant 30: _high_surrogate
  0008    | TakeRight 8 -> 14
  0011    | PushString2 "\xef\xbf\xbd" (esc)
  0014    | End
  ========================================
  
  ===========1:_high_surrogate============
  _high_surrogate =
    `\u` > ("D" | "d") + ("8" | "9" | "A" | "B" | "a" | "b") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 33: "\u"
  0002    | TakeRight 2 -> 13
  0005    | SetInputMark
  0006    | ParseChar 'D'
  0008    | Or 8 -> 13
  0011    | ParseChar 'd'
  0013    | JumpIfFailure 13 -> 49
  0016    | SetInputMark
  0017    | ParseChar '8'
  0019    | Or 19 -> 48
  0022    | SetInputMark
  0023    | ParseChar '9'
  0025    | Or 25 -> 48
  0028    | SetInputMark
  0029    | ParseChar 'A'
  0031    | Or 31 -> 48
  0034    | SetInputMark
  0035    | ParseChar 'B'
  0037    | Or 37 -> 48
  0040    | SetInputMark
  0041    | ParseChar 'a'
  0043    | Or 43 -> 48
  0046    | ParseChar 'b'
  0048    | Merge
  0049    | JumpIfFailure 49 -> 55
  0052    | CallFunctionConstant 34: hex_numeral
  0054    | Merge
  0055    | JumpIfFailure 55 -> 61
  0058    | CallFunctionConstant 34: hex_numeral
  0060    | Merge
  0061    | End
  ========================================
  
  ============1:_low_surrogate============
  _low_surrogate =
    `\u` > ("D" | "d") + ("C".."F" | "c".."f") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 33: "\u"
  0002    | TakeRight 2 -> 13
  0005    | SetInputMark
  0006    | ParseChar 'D'
  0008    | Or 8 -> 13
  0011    | ParseChar 'd'
  0013    | JumpIfFailure 13 -> 27
  0016    | SetInputMark
  0017    | ParseCodepointRange 'C'..'F'
  0020    | Or 20 -> 26
  0023    | ParseCodepointRange 'c'..'f'
  0026    | Merge
  0027    | JumpIfFailure 27 -> 33
  0030    | CallFunctionConstant 34: hex_numeral
  0032    | Merge
  0033    | JumpIfFailure 33 -> 39
  0036    | CallFunctionConstant 34: hex_numeral
  0038    | Merge
  0039    | End
  ========================================
  
  ==========1:_escaped_codepoint==========
  _escaped_codepoint = `\u` > (hex_numeral * 4) -> U $ @Codepoint(U)
  ========================================
  0000    | PushVar2 U
  0003    | CallFunctionConstant 33: "\u"
  0005    | TakeRight 5 -> 32
  0008    | PushNull
  0009    | PushInteger 4
  0011    | ValidateRepeatPattern
  0012    | JumpIfZero 12 -> 31
  0015    | Swap
  0016    | CallFunctionConstant 34: hex_numeral
  0018    | Merge
  0019    | JumpIfFailure 19 -> 30
  0022    | Swap
  0023    | Decrement
  0024    | JumpIfZero 24 -> 31
  0027    | JumpBack 27 -> 15
  0030    | Swap
  0031    | Drop
  0032    | DestructurePlan 2: bind U
  0034    | TakeRight 34 -> 43
  0037    | GetConstant 35: @Codepoint
  0039    | GetLocalMove 0
  0041    | CallTailFunction 1
  0043    | End
  ========================================
  
  ================1:array=================
  array(elem) = "[" > !stdlib.maybe_array_sep( surround(elem, maybe(ws)), ",") < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 18
  0005    | GetConstant 37: maybe_array_sep
  0007    | GetConstant 38: @fn2
  0009    | CreateClosure 1
  0011    | CaptureLocal 0
  0013    | PushString2 ","
  0016    | CallFunction 2
  0018    | JumpIfFailure 18 -> 24
  0021    | ParseChar ']'
  0023    | TakeLeft
  0024    | End
  ========================================
  
  ================1:object================
  object(value) =
    "{" >
    !stdlib.maybe_object_sep(
      surround(string, maybe(ws)), ":",
      surround(value, maybe(ws)), ","
    )
    < "}"
  ========================================
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 23
  0005    | GetConstant 43: maybe_object_sep
  0007    | GetConstant 44: @fn4
  0009    | PushString2 ":"
  0012    | GetConstant 45: @fn6
  0014    | CreateClosure 1
  0016    | CaptureLocal 0
  0018    | PushString2 ","
  0021    | CallFunction 4
  0023    | JumpIfFailure 23 -> 29
  0026    | ParseChar '}'
  0028    | TakeLeft
  0029    | End
  ========================================
  
  ================1:@main=================
  value
  ========================================
  0000    | CallTailFunctionConstant 5: value
  0002    | End
  ========================================
  
  =================1:@fn1=================
  ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 36: ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  =================1:@fn0=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 13: _escaped_ctrl_char
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 14: _escaped_unicode
  0009    | Or 9 -> 20
  0012    | GetConstant 15: unless
  0014    | GetConstant 16: char
  0016    | GetConstant 17: @fn1
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  =================1:@fn3=================
  maybe(ws)
  ========================================
  0000    | GetConstant 41: maybe
  0002    | GetConstant 42: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn2=================
  surround(elem, maybe(ws))
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 39: surround
  0006    | GetLocalMove 0
  0008    | GetConstant 40: @fn3
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  =================1:@fn5=================
  maybe(ws)
  ========================================
  0000    | GetConstant 41: maybe
  0002    | GetConstant 42: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn4=================
  surround(string, maybe(ws))
  ========================================
  0000    | GetConstant 39: surround
  0002    | GetConstant 3: string
  0004    | GetConstant 46: @fn5
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================1:@fn7=================
  maybe(ws)
  ========================================
  0000    | GetConstant 41: maybe
  0002    | GetConstant 42: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn6=================
  surround(value, maybe(ws))
  ========================================
  0000    | PushVar value
  0002    | SetClosureCaptures
  0003    | GetConstant 39: surround
  0005    | GetLocalMove 0
  0007    | GetConstant 47: @fn7
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================2:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
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
  0000    | GetConstant 0: many
  0002    | GetConstant 1: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============2:hex_numeral==============
  hex_numeral = numeral | "a".."f" | "A".."F"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 1: numeral
  0003    | Or 3 -> 16
  0006    | SetInputMark
  0007    | ParseCodepointRange 'a'..'f'
  0010    | Or 10 -> 16
  0013    | ParseCodepointRange 'A'..'F'
  0016    | End
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
  0013    | CallFunctionConstant 5: "\xc2\xa0" (esc)
  0015    | Or 15 -> 43
  0018    | SetInputMark
  0019    | PushString2 "\xe2\x80\x80" (esc)
  0022    | PushString2 "\xe2\x80\x8a" (esc)
  0025    | ParseRange
  0026    | Or 26 -> 43
  0029    | SetInputMark
  0030    | CallFunctionConstant 6: "\xe2\x80\xaf" (esc)
  0032    | Or 32 -> 43
  0035    | SetInputMark
  0036    | CallFunctionConstant 7: "\xe2\x81\x9f" (esc)
  0038    | Or 38 -> 43
  0041    | CallTailFunctionConstant 8: "\xe3\x80\x80" (esc)
  0043    | End
  ========================================
  
  ===============2:newline================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 9: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 10: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 11: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 12: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  ==============2:whitespace==============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 2: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============2:whitespace==============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 2: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============2:ctrl_char===============
  ctrl_char = "\u000000".."\u00001F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x1f' (esc)
  0003    | End
  ========================================
  
  =================2:@fn3=================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: space
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
  0008    | CallFunctionLocal 0
  0010    | Merge
  0011    | JumpIfFailure 11 -> 36
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 22
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | SetInputMark
  0024    | CallFunctionLocal 0
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
  
  ================4:maybe=================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 0: succeed
  0008    | End
  ========================================
  
  ================4:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 2: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  ===============4:succeed================
  succeed = const($null)
  ========================================
  0000    | GetConstant 1: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ===============4:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 12
  0006    | GetConstant 1: const
  0008    | GetLocalMove 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
  0002    | End
  ========================================
  
  ==============4:as_number===============
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionLocal 0
  0004    | DestructurePlan 0: tmpl((eq 0 + bind N))
  0006    | TakeRight 6 -> 11
  0009    | GetLocalMove 1
  0011    | End
  ========================================
  
  ===============4:surround===============
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
  
  =================5:true=================
  true(t) = t $ true
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushTrue
  0006    | End
  ========================================
  
  ================5:false=================
  false(f) = f $ false
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushFalse
  0006    | End
  ========================================
  
  ===============5:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetLocalMove 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetLocalMove 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  =================5:null=================
  null(n) = n $ null
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushNull
  0006    | End
  ========================================
  
  ================7:number================
  number = as_number(
    maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn5
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========7:_number_integer_part=========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 10
  0007    | CallFunctionConstant 6: numerals
  0009    | Merge
  0010    | Or 10 -> 15
  0013    | CallTailFunctionConstant 7: numeral
  0015    | End
  ========================================
  
  ========7:_number_fraction_part=========
  _number_fraction_part = "." + numerals
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 6: numerals
  0007    | Merge
  0008    | End
  ========================================
  
  ========7:_number_exponent_part=========
  _number_exponent_part = ("e" | "E") + maybe("-" | "+") + numerals
  ========================================
  0000    | SetInputMark
  0001    | ParseChar 'e'
  0003    | Or 3 -> 8
  0006    | ParseChar 'E'
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 2: maybe
  0013    | GetConstant 8: @fn8
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 24
  0021    | CallFunctionConstant 6: numerals
  0023    | Merge
  0024    | End
  ========================================
  
  =================7:@fn5=================
  maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 3: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 2: maybe
  0017    | GetConstant 4: _number_fraction_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 32
  0025    | GetConstant 2: maybe
  0027    | GetConstant 5: _number_exponent_part
  0029    | CallFunction 1
  0031    | Merge
  0032    | End
  ========================================
  
  =================7:@fn8=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
  ========================================
  
  ==============8:array_sep===============
  array_sep(elem, sep) = tuple1(elem) + (tuple1(sep > elem) * 0..)
  ========================================
  0000    | GetConstant 3: tuple1
  0002    | GetLocal 0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 68
  0009    | PushNull
  0010    | PushInteger 0
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 41
  0016    | Swap
  0017    | GetConstant 3: tuple1
  0019    | GetConstant 4: @fn0
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
  0043    | GetConstant 3: tuple1
  0045    | GetConstant 4: @fn0
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
  
  ===========8:maybe_array_sep============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn3
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyArray
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ================8:tuple1================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | DestructurePlan 0: bind Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 5: [_]
  0012    | GetLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  =================8:@fn0=================
  sep > elem
  ========================================
  0000    | PushVar2 sep
  0003    | PushVar2 elem
  0006    | SetClosureCaptures
  0007    | CallFunctionLocal 0
  0009    | TakeRight 9 -> 14
  0012    | CallTailFunctionLocal 1
  0014    | End
  ========================================
  
  =================8:@fn3=================
  array_sep(elem, sep)
  ========================================
  0000    | PushVar2 elem
  0003    | PushVar2 sep
  0006    | SetClosureCaptures
  0007    | GetConstant 2: array_sep
  0009    | GetLocalMove 0
  0011    | GetLocalMove 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  =============11:object_sep==============
  object_sep(key, kv_sep, value, sep) =
    pair_sep(key, kv_sep, value) +
    ((sep > pair_sep(key, kv_sep, value)) * 0..)
  ========================================
  0000    | GetConstant 3: pair_sep
  0002    | GetLocal 0
  0004    | GetLocal 1
  0006    | GetLocal 2
  0008    | CallFunction 3
  0010    | JumpIfFailure 10 -> 78
  0013    | PushNull
  0014    | PushInteger 0
  0016    | ValidateRepeatPattern
  0017    | JumpIfZero 17 -> 48
  0020    | Swap
  0021    | CallFunctionLocal 3
  0023    | TakeRight 23 -> 36
  0026    | GetConstant 3: pair_sep
  0028    | GetLocal 0
  0030    | GetLocal 1
  0032    | GetLocal 2
  0034    | CallFunction 3
  0036    | Merge
  0037    | JumpIfFailure 37 -> 75
  0040    | Swap
  0041    | Decrement
  0042    | JumpIfZero 42 -> 48
  0045    | JumpBack 45 -> 20
  0048    | Swap
  0049    | SetInputMark
  0050    | CallFunctionLocal 3
  0052    | TakeRight 52 -> 65
  0055    | GetConstant 3: pair_sep
  0057    | GetLocal 0
  0059    | GetLocal 1
  0061    | GetLocal 2
  0063    | CallFunction 3
  0065    | JumpIfFailure 65 -> 73
  0068    | PopInputMark
  0069    | Merge
  0070    | JumpBack 70 -> 49
  0073    | ResetInput
  0074    | Drop
  0075    | Swap
  0076    | Drop
  0077    | Merge
  0078    | End
  ========================================
  
  ==========11:maybe_object_sep===========
  maybe_object_sep(key, pair_sep, value, sep) =
    default(object_sep(key, pair_sep, value, sep), {})
  ========================================
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn2
  0004    | CreateClosure 4
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CaptureLocal 2
  0012    | CaptureLocal 3
  0014    | PushEmptyObject
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ==============11:pair_sep===============
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | DestructurePlan 0: bind K
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 33
  0018    | CallFunctionLocal 2
  0020    | DestructurePlan 1: bind V
  0022    | TakeRight 22 -> 33
  0025    | GetConstantMutable 4: {_0_}
  0027    | GetLocalMove 3
  0029    | GetLocalMove 4
  0031    | InsertKeyVal 0
  0033    | End
  ========================================
  
  ================11:@fn2=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | PushVar2 key
  0003    | PushVar2 pair_sep
  0006    | PushVar value
  0008    | PushVar2 sep
  0011    | SetClosureCaptures
  0012    | GetConstant 2: object_sep
  0014    | GetLocalMove 0
  0016    | GetLocalMove 1
  0018    | GetLocalMove 2
  0020    | GetLocalMove 3
  0022    | CallTailFunction 4
  0024    | End
  ========================================
