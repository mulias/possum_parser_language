  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i '' --no-stdlib
  
  ================0:@fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ================0:@Fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ==============0:@Codepoint==============
  0000    | GetLocal 0
  0002    | NativeCode 14: stringToCodepointNative
  0004    | End
  ========================================
  
  =======0:@SurrogatePairCodepoint========
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 12: stringsToSurrogateCodepointNative
  0006    | End
  ========================================
  
  =================0:@Add=================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 10: addNative
  0006    | End
  ========================================
  
  ==============0:@Subtract===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 21: subtractNative
  0006    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 6: multiplyNative
  0006    | End
  ========================================
  
  ===============0:@Divide================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 23: divideNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 8: powerNative
  0006    | End
  ========================================
  
  ===============0:@Modulus===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 25: modulusNative
  0006    | End
  ========================================
  
  ================0:@Floor================
  0000    | GetLocal 0
  0002    | NativeCode 27: floorNative
  0004    | End
  ========================================
  
  ===============0:@Ceiling===============
  0000    | GetLocal 0
  0002    | NativeCode 29: ceilingNative
  0004    | End
  ========================================
  
  ============0:@input.offset=============
  0000    | NativeCode 2: inputOffsetNative
  0002    | End
  ========================================
  
  =============0:@input.line==============
  0000    | NativeCode 17: inputLineNative
  0002    | End
  ========================================
  
  ==========0:@input.line_offset==========
  0000    | NativeCode 19: inputLineOffsetNative
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
  
  =================1:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  ================1:ascii=================
  ascii = "\u000000".."\u00007F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x7f' (esc)
  0003    | End
  ========================================
  
  ================1:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================1:alphas================
  alphas = many(alpha)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: alpha
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:lower=================
  lower = "a".."z"
  ========================================
  0000    | ParseCodepointRange 'a'..'z'
  0003    | End
  ========================================
  
  ================1:lowers================
  lowers = many(lower)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 2: lower
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:upper=================
  upper = "A".."Z"
  ========================================
  0000    | ParseCodepointRange 'A'..'Z'
  0003    | End
  ========================================
  
  ================1:uppers================
  uppers = many(upper)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 3: upper
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============1:numeral================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ===============1:numerals===============
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 4: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ============1:binary_numeral============
  binary_numeral = "0" | "1"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '0'
  0003    | Or 3 -> 8
  0006    | ParseChar '1'
  0008    | End
  ========================================
  
  ============1:octal_numeral=============
  octal_numeral = "0".."7"
  ========================================
  0000    | ParseCodepointRange '0'..'7'
  0003    | End
  ========================================
  
  =============1:hex_numeral==============
  hex_numeral = numeral | "a".."f" | "A".."F"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 4: numeral
  0003    | Or 3 -> 16
  0006    | SetInputMark
  0007    | ParseCodepointRange 'a'..'f'
  0010    | Or 10 -> 16
  0013    | ParseCodepointRange 'A'..'F'
  0016    | End
  ========================================
  
  ================1:alnum=================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 1: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
  ========================================
  
  ================1:alnums================
  alnums = many(alnum)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 5: alnum
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:token=================
  token = many(unless(char, whitespace))
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 6: @fn0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:word=================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 22: @fn1
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:line=================
  line = chars_until(newline | end_of_input)
  ========================================
  0000    | GetConstant 23: chars_until
  0002    | GetConstant 24: @fn2
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:space=================
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
  0013    | CallFunctionConstant 14: "\xc2\xa0" (esc)
  0015    | Or 15 -> 41
  0018    | SetInputMark
  0019    | PushString "\xe2\x80\x80" (esc)
  0021    | PushString "\xe2\x80\x8a" (esc)
  0023    | ParseRange
  0024    | Or 24 -> 41
  0027    | SetInputMark
  0028    | CallFunctionConstant 15: "\xe2\x80\xaf" (esc)
  0030    | Or 30 -> 41
  0033    | SetInputMark
  0034    | CallFunctionConstant 16: "\xe2\x81\x9f" (esc)
  0036    | Or 36 -> 41
  0039    | CallTailFunctionConstant 17: "\xe3\x80\x80" (esc)
  0041    | End
  ========================================
  
  ================1:spaces================
  spaces = many(space)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 12: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============1:newline================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 18: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 19: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 20: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 21: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  ===============1:newline================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 18: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 19: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 20: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 21: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  ===============1:newlines===============
  newlines = many(newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============1:newlines===============
  newlines = many(newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============1:whitespace==============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 11: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============1:whitespace==============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 11: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============1:chars_until==============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 25: many_until
  0002    | GetConstant 8: char
  0004    | GetBoundLocalMove 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================1:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============1:integer================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 33: @fn4
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============1:integer================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 33: @fn4
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========1:non_negative_integer=========
  non_negative_integer = as_number(_number_integer_part)
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 35: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========1:negative_integer===========
  negative_integer = as_number("-" + _number_integer_part)
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 37: @fn5
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:float=================
  float = as_number(maybe("-") + _number_integer_part + _number_fraction_part)
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 38: @fn6
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========1:scientific_integer==========
  scientific_integer = as_number(
    maybe("-") +
    _number_integer_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 40: @fn7
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========1:scientific_float===========
  scientific_float = as_number(
    maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 43: @fn8
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:number================
  number = as_number(
    maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 44: @fn9
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:number================
  number = as_number(
    maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 44: @fn9
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========1:non_negative_number==========
  non_negative_number = as_number(
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 45: @fn10
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========1:negative_number============
  negative_number = as_number(
    "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 46: @fn11
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========1:_number_integer_part=========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 10
  0007    | CallFunctionConstant 36: numerals
  0009    | Merge
  0010    | Or 10 -> 15
  0013    | CallTailFunctionConstant 4: numeral
  0015    | End
  ========================================
  
  ========1:_number_fraction_part=========
  _number_fraction_part = "." + numerals
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 36: numerals
  0007    | Merge
  0008    | End
  ========================================
  
  ========1:_number_exponent_part=========
  _number_exponent_part = ("e" | "E") + maybe("-" | "+") + numerals
  ========================================
  0000    | SetInputMark
  0001    | ParseChar 'e'
  0003    | Or 3 -> 8
  0006    | ParseChar 'E'
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 34: maybe
  0013    | GetConstant 42: @fn12
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 24
  0021    | CallFunctionConstant 36: numerals
  0023    | Merge
  0024    | End
  ========================================
  
  =============1:binary_digit=============
  binary_digit = 0..1
  ========================================
  0000    | ParseIntegerRange 0..1
  0003    | End
  ========================================
  
  =============1:octal_digit==============
  octal_digit = 0..7
  ========================================
  0000    | ParseIntegerRange 0..7
  0003    | End
  ========================================
  
  ==============1:hex_digit===============
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
  0001    | CallFunctionConstant 47: digit
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
  
  ============1:binary_integer============
  binary_integer = array(binary_digit) -> Digits $ Num.FromBinaryDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | GetConstant 48: array
  0005    | GetConstant 49: binary_digit
  0007    | CallFunction 1
  0009    | Destructure 2: Digits
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 50: Num.FromBinaryDigits
  0016    | GetBoundLocalMove 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  ============1:octal_integer=============
  octal_integer = array(octal_digit) -> Digits $ Num.FromOctalDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | GetConstant 48: array
  0005    | GetConstant 57: octal_digit
  0007    | CallFunction 1
  0009    | Destructure 8: Digits
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 58: Num.FromOctalDigits
  0016    | GetBoundLocalMove 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  =============1:hex_integer==============
  hex_integer = array(hex_digit) -> Digits $ Num.FromHexDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | GetConstant 48: array
  0005    | GetConstant 60: hex_digit
  0007    | CallFunction 1
  0009    | Destructure 12: Digits
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 61: Num.FromHexDigits
  0016    | GetBoundLocalMove 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  =================1:true=================
  true(t) = t $ true
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushTrue
  0006    | End
  ========================================
  
  ================1:false=================
  false(f) = f $ false
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushFalse
  0006    | End
  ========================================
  
  ===============1:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 63: true
  0003    | GetBoundLocalMove 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 64: false
  0012    | GetBoundLocalMove 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ===============1:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 63: true
  0003    | GetBoundLocalMove 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 64: false
  0012    | GetBoundLocalMove 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  =================1:null=================
  null(n) = n $ null
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushNull
  0006    | End
  ========================================
  
  ================1:array=================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 26
  0007    | Swap
  0008    | GetConstant 51: tuple1
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Merge
  0015    | JumpIfFailure 15 -> 44
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 7
  0026    | Swap
  0027    | SetInputMark
  0028    | GetConstant 51: tuple1
  0030    | GetBoundLocal 0
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
  0000    | GetConstant 51: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 68
  0009    | PushNull
  0010    | PushInteger 0
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 41
  0016    | Swap
  0017    | GetConstant 51: tuple1
  0019    | GetConstant 65: @fn13
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
  0043    | GetConstant 51: tuple1
  0045    | GetConstant 65: @fn13
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
  0008    | GetConstant 7: unless
  0010    | GetConstant 66: @fn14
  0012    | CreateClosure 1
  0014    | CaptureLocal 0
  0016    | GetBoundLocal 1
  0018    | CallFunction 2
  0020    | Merge
  0021    | JumpIfFailure 21 -> 56
  0024    | Swap
  0025    | Decrement
  0026    | JumpIfZero 26 -> 32
  0029    | JumpBack 29 -> 7
  0032    | Swap
  0033    | SetInputMark
  0034    | GetConstant 7: unless
  0036    | GetConstant 66: @fn14
  0038    | CreateClosure 1
  0040    | CaptureLocal 0
  0042    | GetBoundLocal 1
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
  0061    | GetConstant 26: peek
  0063    | GetBoundLocalMove 1
  0065    | CallFunction 1
  0067    | TakeLeft
  0068    | End
  ========================================
  
  =============1:maybe_array==============
  maybe_array(elem) = default(array(elem), [])
  ========================================
  0000    | GetConstant 67: default
  0002    | GetConstant 68: @fn15
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | PushEmptyArray
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===========1:maybe_array_sep============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 67: default
  0002    | GetConstant 69: @fn16
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
  0000    | PushVar2 Elem
  0003    | CallFunctionLocal 0
  0005    | Destructure 3: Elem
  0007    | TakeRight 7 -> 16
  0010    | GetConstantMutable 52: [_]
  0012    | GetBoundLocalMove 1
  0014    | InsertAtIndex 0
  0016    | End
  ========================================
  
  ================1:tuple2================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar2 E1
  0003    | PushVar2 E2
  0006    | CallFunctionLocal 0
  0008    | Destructure 16: E1
  0010    | TakeRight 10 -> 30
  0013    | CallFunctionLocal 1
  0015    | Destructure 17: E2
  0017    | TakeRight 17 -> 30
  0020    | GetConstantMutable 71: [_, _]
  0022    | GetBoundLocalMove 2
  0024    | InsertAtIndex 0
  0026    | GetBoundLocalMove 3
  0028    | InsertAtIndex 1
  0030    | End
  ========================================
  
  ==============1:tuple2_sep==============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | PushVar2 E1
  0003    | PushVar2 E2
  0006    | CallFunctionLocal 0
  0008    | Destructure 18: E1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 35
  0018    | CallFunctionLocal 2
  0020    | Destructure 19: E2
  0022    | TakeRight 22 -> 35
  0025    | GetConstantMutable 72: [_, _]
  0027    | GetBoundLocalMove 3
  0029    | InsertAtIndex 0
  0031    | GetBoundLocalMove 4
  0033    | InsertAtIndex 1
  0035    | End
  ========================================
  
  ================1:tuple3================
  tuple3(elem1, elem2, elem3) =
    elem1 -> E1 &
    elem2 -> E2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | PushVar2 E1
  0003    | PushVar2 E2
  0006    | PushVar2 E3
  0009    | CallFunctionLocal 0
  0011    | Destructure 20: E1
  0013    | TakeRight 13 -> 20
  0016    | CallFunctionLocal 1
  0018    | Destructure 21: E2
  0020    | TakeRight 20 -> 44
  0023    | CallFunctionLocal 2
  0025    | Destructure 22: E3
  0027    | TakeRight 27 -> 44
  0030    | GetConstantMutable 73: [_, _, _]
  0032    | GetBoundLocalMove 3
  0034    | InsertAtIndex 0
  0036    | GetBoundLocalMove 4
  0038    | InsertAtIndex 1
  0040    | GetBoundLocalMove 5
  0042    | InsertAtIndex 2
  0044    | End
  ========================================
  
  ==============1:tuple3_sep==============
  tuple3_sep(elem1, sep1, elem2, sep2, elem3) =
    elem1 -> E1 & sep1 &
    elem2 -> E2 & sep2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | PushVar2 E1
  0003    | PushVar2 E2
  0006    | PushVar2 E3
  0009    | CallFunctionLocal 0
  0011    | Destructure 23: E1
  0013    | TakeRight 13 -> 18
  0016    | CallFunctionLocal 1
  0018    | TakeRight 18 -> 25
  0021    | CallFunctionLocal 2
  0023    | Destructure 24: E2
  0025    | TakeRight 25 -> 30
  0028    | CallFunctionLocal 3
  0030    | TakeRight 30 -> 54
  0033    | CallFunctionLocal 4
  0035    | Destructure 25: E3
  0037    | TakeRight 37 -> 54
  0040    | GetConstantMutable 74: [_, _, _]
  0042    | GetBoundLocalMove 5
  0044    | InsertAtIndex 0
  0046    | GetBoundLocalMove 6
  0048    | InsertAtIndex 1
  0050    | GetBoundLocalMove 7
  0052    | InsertAtIndex 2
  0054    | End
  ========================================
  
  ================1:tuple=================
  tuple(elem, N) = tuple1(elem) * N
  ========================================
  0000    | PushNull
  0001    | GetBoundLocalMove 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 27
  0007    | Swap
  0008    | GetConstant 51: tuple1
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
  
  ==============1:tuple_sep===============
  tuple_sep(elem, sep, N) = tuple1(elem) + (tuple1(sep > elem) * (N - 1))
  ========================================
  0000    | GetConstant 51: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 50
  0009    | PushNull
  0010    | GetBoundLocalMove 2
  0012    | JumpIfFailure 12 -> 18
  0015    | PushNegInteger -1
  0017    | Merge
  0018    | ValidateRepeatPattern
  0019    | JumpIfZero 19 -> 48
  0022    | Swap
  0023    | GetConstant 51: tuple1
  0025    | GetConstant 75: @fn17
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
  0000    | GetConstant 51: tuple1
  0002    | GetConstant 76: @fn18
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
  0023    | GetConstant 51: tuple1
  0025    | GetConstant 77: @fn19
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
  0051    | GetConstant 51: tuple1
  0053    | GetConstant 77: @fn19
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
  0007    | GetConstant 26: peek
  0009    | GetConstant 78: @fn20
  0011    | CreateClosure 3
  0013    | CaptureLocal 0
  0015    | CaptureLocal 1
  0017    | CaptureLocal 2
  0019    | CallFunction 1
  0021    | Destructure 26: [MaxRowLen, _]
  0023    | TakeRight 23 -> 30
  0026    | CallFunctionLocal 0
  0028    | Destructure 27: First
  0030    | TakeRight 30 -> 56
  0033    | GetConstant 79: _rows_padded
  0035    | GetBoundLocalMove 0
  0037    | GetBoundLocalMove 1
  0039    | GetBoundLocalMove 2
  0041    | GetBoundLocalMove 3
  0043    | PushInteger 1
  0045    | GetBoundLocalMove 4
  0047    | GetConstantMutable 80: [_]
  0049    | GetBoundLocalMove 6
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
  0000    | PushVar2 Elem
  0003    | PushVar2 NextRow
  0006    | SetInputMark
  0007    | CallFunctionLocal 1
  0009    | TakeRight 9 -> 14
  0012    | CallFunctionLocal 0
  0014    | Destructure 29: Elem
  0016    | ConditionalThen 16 -> 61
  0019    | GetConstant 79: _rows_padded
  0021    | GetBoundLocalMove 0
  0023    | GetBoundLocalMove 1
  0025    | GetBoundLocalMove 2
  0027    | GetBoundLocalMove 3
  0029    | GetConstant 83: Num.Inc
  0031    | GetBoundLocalMove 4
  0033    | CallFunction 1
  0035    | GetBoundLocalMove 5
  0037    | PushEmptyArray
  0038    | JumpIfFailure 38 -> 44
  0041    | GetBoundLocalMove 6
  0043    | Merge
  0044    | JumpIfFailure 44 -> 54
  0047    | GetConstantMutable 87: [_]
  0049    | GetBoundLocalMove 8
  0051    | InsertAtIndex 0
  0053    | Merge
  0054    | GetBoundLocalMove 7
  0056    | CallTailFunction 8
  0058    | Jump 58 -> 167
  0061    | SetInputMark
  0062    | CallFunctionLocal 2
  0064    | TakeRight 64 -> 69
  0067    | CallFunctionLocal 0
  0069    | Destructure 30: NextRow
  0071    | ConditionalThen 71 -> 131
  0074    | GetConstant 79: _rows_padded
  0076    | GetBoundLocalMove 0
  0078    | GetBoundLocalMove 1
  0080    | GetBoundLocalMove 2
  0082    | GetBoundLocal 3
  0084    | PushInteger 1
  0086    | GetBoundLocal 5
  0088    | GetConstantMutable 88: [_]
  0090    | GetBoundLocalMove 9
  0092    | InsertAtIndex 0
  0094    | PushEmptyArray
  0095    | JumpIfFailure 95 -> 101
  0098    | GetBoundLocalMove 7
  0100    | Merge
  0101    | JumpIfFailure 101 -> 126
  0104    | GetConstantMutable 89: [_]
  0106    | GetConstant 90: Array.AppendN
  0108    | GetBoundLocalMove 6
  0110    | GetBoundLocalMove 3
  0112    | GetBoundLocalMove 5
  0114    | JumpIfFailure 114 -> 121
  0117    | GetBoundLocalMove 4
  0119    | NegateNumber
  0120    | Merge
  0121    | CallFunction 3
  0123    | InsertAtIndex 0
  0125    | Merge
  0126    | CallTailFunction 8
  0128    | Jump 128 -> 167
  0131    | GetConstant 31: const
  0133    | PushEmptyArray
  0134    | JumpIfFailure 134 -> 140
  0137    | GetBoundLocalMove 7
  0139    | Merge
  0140    | JumpIfFailure 140 -> 165
  0143    | GetConstantMutable 91: [_]
  0145    | GetConstant 90: Array.AppendN
  0147    | GetBoundLocalMove 6
  0149    | GetBoundLocalMove 3
  0151    | GetBoundLocalMove 5
  0153    | JumpIfFailure 153 -> 160
  0156    | GetBoundLocalMove 4
  0158    | NegateNumber
  0159    | Merge
  0160    | CallFunction 3
  0162    | InsertAtIndex 0
  0164    | Merge
  0165    | CallTailFunction 1
  0167    | End
  ========================================
  
  =============1:_dimensions==============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 21
  0005    | GetConstant 82: __dimensions
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | GetBoundLocalMove 2
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
  0011    | GetConstant 82: __dimensions
  0013    | GetBoundLocalMove 0
  0015    | GetBoundLocalMove 1
  0017    | GetBoundLocalMove 2
  0019    | GetConstant 83: Num.Inc
  0021    | GetBoundLocalMove 3
  0023    | CallFunction 1
  0025    | GetBoundLocalMove 4
  0027    | GetBoundLocalMove 5
  0029    | CallTailFunction 6
  0031    | Jump 31 -> 94
  0034    | SetInputMark
  0035    | CallFunctionLocal 2
  0037    | TakeRight 37 -> 42
  0040    | CallFunctionLocal 0
  0042    | ConditionalThen 42 -> 74
  0045    | GetConstant 82: __dimensions
  0047    | GetBoundLocalMove 0
  0049    | GetBoundLocalMove 1
  0051    | GetBoundLocalMove 2
  0053    | PushInteger 1
  0055    | GetConstant 83: Num.Inc
  0057    | GetBoundLocalMove 4
  0059    | CallFunction 1
  0061    | GetConstant 84: Num.Max
  0063    | GetBoundLocalMove 3
  0065    | GetBoundLocalMove 5
  0067    | CallFunction 2
  0069    | CallTailFunction 6
  0071    | Jump 71 -> 94
  0074    | GetConstant 31: const
  0076    | GetConstantMutable 85: [_, _]
  0078    | GetConstant 84: Num.Max
  0080    | GetBoundLocalMove 3
  0082    | GetBoundLocalMove 5
  0084    | CallFunction 2
  0086    | InsertAtIndex 0
  0088    | GetBoundLocalMove 4
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
  0003    | GetConstant 93: rows
  0005    | GetBoundLocalMove 0
  0007    | GetBoundLocalMove 1
  0009    | GetBoundLocalMove 2
  0011    | CallFunction 3
  0013    | Destructure 31: Rows
  0015    | TakeRight 15 -> 24
  0018    | GetConstant 94: Table.Transpose
  0020    | GetBoundLocalMove 3
  0022    | CallTailFunction 1
  0024    | End
  ========================================
  
  ===============1:columns================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 93: rows
  0005    | GetBoundLocalMove 0
  0007    | GetBoundLocalMove 1
  0009    | GetBoundLocalMove 2
  0011    | CallFunction 3
  0013    | Destructure 31: Rows
  0015    | TakeRight 15 -> 24
  0018    | GetConstant 94: Table.Transpose
  0020    | GetBoundLocalMove 3
  0022    | CallTailFunction 1
  0024    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 105: rows_padded
  0005    | GetBoundLocalMove 0
  0007    | GetBoundLocalMove 1
  0009    | GetBoundLocalMove 2
  0011    | GetBoundLocalMove 3
  0013    | CallFunction 4
  0015    | Destructure 40: Rows
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 94: Table.Transpose
  0022    | GetBoundLocalMove 4
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  ============1:columns_padded============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | PushVar2 Rows
  0003    | GetConstant 105: rows_padded
  0005    | GetBoundLocalMove 0
  0007    | GetBoundLocalMove 1
  0009    | GetBoundLocalMove 2
  0011    | GetBoundLocalMove 3
  0013    | CallFunction 4
  0015    | Destructure 40: Rows
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 94: Table.Transpose
  0022    | GetBoundLocalMove 4
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  ================1:object================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 106: pair
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 106: pair
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | End
  ========================================
  
  ==============1:object_sep==============
  object_sep(key, kv_sep, value, sep) =
    pair_sep(key, kv_sep, value) +
    ((sep > pair_sep(key, kv_sep, value)) * 0..)
  ========================================
  0000    | GetConstant 108: pair_sep
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | CallFunction 3
  0010    | JumpIfFailure 10 -> 78
  0013    | PushNull
  0014    | PushInteger 0
  0016    | ValidateRepeatPattern
  0017    | JumpIfZero 17 -> 48
  0020    | Swap
  0021    | CallFunctionLocal 3
  0023    | TakeRight 23 -> 36
  0026    | GetConstant 108: pair_sep
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 1
  0032    | GetBoundLocal 2
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
  0055    | GetConstant 108: pair_sep
  0057    | GetBoundLocal 0
  0059    | GetBoundLocal 1
  0061    | GetBoundLocal 2
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
  
  =============1:object_until=============
  object_until(key, value, stop) =
    unless(pair(key, value), stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 34
  0007    | Swap
  0008    | GetConstant 7: unless
  0010    | GetConstant 110: @fn21
  0012    | CreateClosure 2
  0014    | CaptureLocal 0
  0016    | CaptureLocal 1
  0018    | GetBoundLocal 2
  0020    | CallFunction 2
  0022    | Merge
  0023    | JumpIfFailure 23 -> 60
  0026    | Swap
  0027    | Decrement
  0028    | JumpIfZero 28 -> 34
  0031    | JumpBack 31 -> 7
  0034    | Swap
  0035    | SetInputMark
  0036    | GetConstant 7: unless
  0038    | GetConstant 110: @fn21
  0040    | CreateClosure 2
  0042    | CaptureLocal 0
  0044    | CaptureLocal 1
  0046    | GetBoundLocal 2
  0048    | CallFunction 2
  0050    | JumpIfFailure 50 -> 58
  0053    | PopInputMark
  0054    | Merge
  0055    | JumpBack 55 -> 35
  0058    | ResetInput
  0059    | Drop
  0060    | Swap
  0061    | Drop
  0062    | JumpIfFailure 62 -> 72
  0065    | GetConstant 26: peek
  0067    | GetBoundLocalMove 2
  0069    | CallFunction 1
  0071    | TakeLeft
  0072    | End
  ========================================
  
  =============1:maybe_object=============
  maybe_object(key, value) = default(object(key, value), {})
  ========================================
  0000    | GetConstant 67: default
  0002    | GetConstant 111: @fn22
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyObject
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ===========1:maybe_object_sep===========
  maybe_object_sep(key, pair_sep, value, sep) =
    default(object_sep(key, pair_sep, value, sep), {})
  ========================================
  0000    | GetConstant 67: default
  0002    | GetConstant 113: @fn23
  0004    | CreateClosure 4
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CaptureLocal 2
  0012    | CaptureLocal 3
  0014    | PushEmptyObject
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  =================1:pair=================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 41: K
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionLocal 1
  0015    | Destructure 42: V
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 107: {_0_}
  0022    | GetBoundLocalMove 2
  0024    | GetBoundLocalMove 3
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  ===============1:pair_sep===============
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 43: K
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 33
  0018    | CallFunctionLocal 2
  0020    | Destructure 44: V
  0022    | TakeRight 22 -> 33
  0025    | GetConstantMutable 109: {_0_}
  0027    | GetBoundLocalMove 3
  0029    | GetBoundLocalMove 4
  0031    | InsertKeyVal 0
  0033    | End
  ========================================
  
  ===============1:record1================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | PushVar2 Value
  0003    | CallFunctionLocal 1
  0005    | Destructure 45: Value
  0007    | TakeRight 7 -> 18
  0010    | GetConstantMutable 115: {_0_}
  0012    | GetBoundLocalMove 0
  0014    | GetBoundLocalMove 2
  0016    | InsertKeyVal 0
  0018    | End
  ========================================
  
  ===============1:record2================
  record2(Key1, value1, Key2, value2) =
    value1 -> V1 &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar2 V1
  0003    | PushVar2 V2
  0006    | CallFunctionLocal 1
  0008    | Destructure 46: V1
  0010    | TakeRight 10 -> 34
  0013    | CallFunctionLocal 3
  0015    | Destructure 47: V2
  0017    | TakeRight 17 -> 34
  0020    | GetConstantMutable 116: {_0_, _1_}
  0022    | GetBoundLocalMove 0
  0024    | GetBoundLocalMove 4
  0026    | InsertKeyVal 0
  0028    | GetBoundLocalMove 2
  0030    | GetBoundLocalMove 5
  0032    | InsertKeyVal 1
  0034    | End
  ========================================
  
  =============1:record2_sep==============
  record2_sep(Key1, value1, sep, Key2, value2) =
    value1 -> V1 & sep &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar2 V1
  0003    | PushVar2 V2
  0006    | CallFunctionLocal 1
  0008    | Destructure 48: V1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 2
  0015    | TakeRight 15 -> 39
  0018    | CallFunctionLocal 4
  0020    | Destructure 49: V2
  0022    | TakeRight 22 -> 39
  0025    | GetConstantMutable 117: {_0_, _1_}
  0027    | GetBoundLocalMove 0
  0029    | GetBoundLocalMove 5
  0031    | InsertKeyVal 0
  0033    | GetBoundLocalMove 3
  0035    | GetBoundLocalMove 6
  0037    | InsertKeyVal 1
  0039    | End
  ========================================
  
  ===============1:record3================
  record3(Key1, value1, Key2, value2, Key3, value3) =
    value1 -> V1 &
    value2 -> V2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | PushVar2 V1
  0003    | PushVar2 V2
  0006    | PushVar2 V3
  0009    | CallFunctionLocal 1
  0011    | Destructure 50: V1
  0013    | TakeRight 13 -> 20
  0016    | CallFunctionLocal 3
  0018    | Destructure 51: V2
  0020    | TakeRight 20 -> 50
  0023    | CallFunctionLocal 5
  0025    | Destructure 52: V3
  0027    | TakeRight 27 -> 50
  0030    | GetConstantMutable 118: {_0_, _1_, _2_}
  0032    | GetBoundLocalMove 0
  0034    | GetBoundLocalMove 6
  0036    | InsertKeyVal 0
  0038    | GetBoundLocalMove 2
  0040    | GetBoundLocalMove 7
  0042    | InsertKeyVal 1
  0044    | GetBoundLocalMove 4
  0046    | GetBoundLocalMove 8
  0048    | InsertKeyVal 2
  0050    | End
  ========================================
  
  =============1:record3_sep==============
  record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3) =
    value1 -> V1 & sep1 &
    value2 -> V2 & sep2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | PushVar2 V1
  0003    | PushVar2 V2
  0006    | PushVar2 V3
  0009    | CallFunctionLocal 1
  0011    | Destructure 53: V1
  0013    | TakeRight 13 -> 18
  0016    | CallFunctionLocal 2
  0018    | TakeRight 18 -> 25
  0021    | CallFunctionLocal 4
  0023    | Destructure 54: V2
  0025    | TakeRight 25 -> 30
  0028    | CallFunctionLocal 5
  0030    | TakeRight 30 -> 60
  0033    | CallFunctionLocal 7
  0035    | Destructure 55: V3
  0037    | TakeRight 37 -> 60
  0040    | GetConstantMutable 119: {_0_, _1_, _2_}
  0042    | GetBoundLocalMove 0
  0044    | GetBoundLocalMove 8
  0046    | InsertKeyVal 0
  0048    | GetBoundLocalMove 3
  0050    | GetBoundLocalMove 9
  0052    | InsertKeyVal 1
  0054    | GetBoundLocalMove 6
  0056    | GetBoundLocalMove 10
  0058    | InsertKeyVal 2
  0060    | End
  ========================================
  
  =================1:many=================
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
  
  ===============1:many_sep===============
  many_sep(p, sep) = p + ((sep > p) * 0..)
  ========================================
  0000    | CallFunctionLocal 0
  0002    | JumpIfFailure 2 -> 54
  0005    | PushNull
  0006    | PushInteger 0
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 32
  0012    | Swap
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 20
  0018    | CallFunctionLocal 0
  0020    | Merge
  0021    | JumpIfFailure 21 -> 51
  0024    | Swap
  0025    | Decrement
  0026    | JumpIfZero 26 -> 32
  0029    | JumpBack 29 -> 12
  0032    | Swap
  0033    | SetInputMark
  0034    | CallFunctionLocal 1
  0036    | TakeRight 36 -> 41
  0039    | CallFunctionLocal 0
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
  
  ==============1:many_until==============
  many_until(p, stop) = unless(p, stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 7: unless
  0010    | GetBoundLocal 0
  0012    | GetBoundLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 7: unless
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
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
  0053    | GetConstant 26: peek
  0055    | GetBoundLocalMove 1
  0057    | CallFunction 1
  0059    | TakeLeft
  0060    | End
  ========================================
  
  ==============1:maybe_many==============
  maybe_many(p) = p * 0..
  ========================================
  0000    | PushNull
  0001    | PushInteger 0
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
  
  ============1:maybe_many_sep============
  maybe_many_sep(p, sep) = many_sep(p, sep) | succeed
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 120: many_sep
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | CallFunction 2
  0009    | Or 9 -> 14
  0012    | CallTailFunctionConstant 30: succeed
  0014    | End
  ========================================
  
  =================1:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar2 Pos
  0003    | CallFunctionConstant 27: @input.offset
  0005    | Destructure 0: Pos
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 28: @at
  0012    | GetBoundLocalMove 1
  0014    | GetBoundLocalMove 0
  0016    | CallTailFunction 2
  0018    | End
  ========================================
  
  ================1:maybe=================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 30: succeed
  0008    | End
  ========================================
  
  ================1:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 10: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  =================1:skip=================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 121: null
  0002    | GetBoundLocalMove 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:find=================
  find(p) = p | (char > find(p))
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 17
  0006    | CallFunctionConstant 8: char
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 122: find
  0013    | GetBoundLocalMove 0
  0015    | CallTailFunction 1
  0017    | End
  ========================================
  
  ===============1:find_all===============
  find_all(p) = array(find(p)) < maybe(many(char))
  ========================================
  0000    | GetConstant 48: array
  0002    | GetConstant 123: @fn24
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 20
  0013    | GetConstant 34: maybe
  0015    | GetConstant 124: @fn25
  0017    | CallFunction 1
  0019    | TakeLeft
  0020    | End
  ========================================
  
  =============1:find_before==============
  find_before(p, stop) = stop ? @fail : p | (char > find_before(p, stop))
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 10: @fail
  0008    | Jump 8 -> 30
  0011    | SetInputMark
  0012    | CallFunctionLocal 0
  0014    | Or 14 -> 30
  0017    | CallFunctionConstant 8: char
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 125: find_before
  0024    | GetBoundLocalMove 0
  0026    | GetBoundLocalMove 1
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ===========1:find_all_before============
  find_all_before(p, stop) = array(find_before(p, stop)) < maybe(chars_until(stop))
  ========================================
  0000    | GetConstant 48: array
  0002    | GetConstant 126: @fn26
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 26
  0015    | GetConstant 34: maybe
  0017    | GetConstant 127: @fn27
  0019    | CreateClosure 1
  0021    | CaptureLocal 1
  0023    | CallFunction 1
  0025    | TakeLeft
  0026    | End
  ========================================
  
  ===============1:succeed================
  succeed = const($null)
  ========================================
  0000    | GetConstant 31: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ===============1:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 12
  0006    | GetConstant 31: const
  0008    | GetBoundLocalMove 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================1:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  ==============1:as_number===============
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionLocal 0
  0005    | Destructure 1: "%(0 + N)"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 1
  0012    | End
  ========================================
  
  ==============1:as_string===============
  as_string(p) = "%(p)"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionLocal 0
  0003    | MergeAsString
  0004    | End
  ========================================
  
  ===============1:surround===============
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
  
  =============1:end_of_input=============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 8: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 10: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 30: succeed
  0013    | End
  ========================================
  
  =============1:end_of_input=============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 8: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 10: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 30: succeed
  0013    | End
  ========================================
  
  ================1:input=================
  input(p) = surround(p, maybe(whitespace)) < end_of_input
  ========================================
  0000    | GetConstant 128: surround
  0002    | GetBoundLocalMove 0
  0004    | GetConstant 129: @fn28
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 14
  0011    | CallFunctionConstant 29: end_of_input
  0013    | TakeLeft
  0014    | End
  ========================================
  
  =============1:one_or_both==============
  one_or_both(a, b) = (a + maybe(b)) | (maybe(a) + b)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | JumpIfFailure 3 -> 13
  0006    | GetConstant 34: maybe
  0008    | GetBoundLocal 1
  0010    | CallFunction 1
  0012    | Merge
  0013    | Or 13 -> 28
  0016    | GetConstant 34: maybe
  0018    | GetBoundLocalMove 0
  0020    | CallFunction 1
  0022    | JumpIfFailure 22 -> 28
  0025    | CallFunctionLocal 1
  0027    | Merge
  0028    | End
  ========================================
  
  =================1:json=================
  json =
    json.boolean |
    json.null |
    json.number |
    json.string |
    json.array(json) |
    json.object(json)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 130: json.boolean
  0003    | Or 3 -> 40
  0006    | SetInputMark
  0007    | CallFunctionConstant 131: json.null
  0009    | Or 9 -> 40
  0012    | SetInputMark
  0013    | CallFunctionConstant 132: number
  0015    | Or 15 -> 40
  0018    | SetInputMark
  0019    | CallFunctionConstant 133: json.string
  0021    | Or 21 -> 40
  0024    | SetInputMark
  0025    | GetConstant 134: json.array
  0027    | GetConstant 135: json
  0029    | CallFunction 1
  0031    | Or 31 -> 40
  0034    | GetConstant 136: json.object
  0036    | GetConstant 135: json
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  =============1:json.boolean=============
  json.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 137: boolean
  0002    | PushString2 "true"
  0005    | PushString2 "false"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  ==============1:json.null===============
  json.null = null("null")
  ========================================
  0000    | GetConstant 121: null
  0002    | PushString2 "null"
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ================1:number================
  number = as_number(
    maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant 44: @fn9
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============1:json.string==============
  json.string = '"' > _json.string_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 138: _json.string_body
  0007    | JumpIfFailure 7 -> 13
  0010    | ParseChar '"'
  0012    | TakeLeft
  0013    | End
  ========================================
  
  ==========1:_json.string_body===========
  _json.string_body =
    many(
      _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
    ) | const($"")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetConstant 139: @fn29
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 31: const
  0012    | PushEmptyString
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  ==============1:_ctrl_char==============
  _ctrl_char = "\u000000".."\u00001F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x1f' (esc)
  0003    | End
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
  0001    | CallFunctionConstant 143: "\""
  0003    | TakeRight 3 -> 9
  0006    | PushString2 """
  0009    | Or 9 -> 90
  0012    | SetInputMark
  0013    | CallFunctionConstant 144: "\\"
  0015    | TakeRight 15 -> 21
  0018    | PushString2 "\"
  0021    | Or 21 -> 90
  0024    | SetInputMark
  0025    | CallFunctionConstant 145: "\/"
  0027    | TakeRight 27 -> 33
  0030    | PushString2 "/"
  0033    | Or 33 -> 90
  0036    | SetInputMark
  0037    | CallFunctionConstant 146: "\b"
  0039    | TakeRight 39 -> 45
  0042    | PushString2 "\x08" (esc)
  0045    | Or 45 -> 90
  0048    | SetInputMark
  0049    | CallFunctionConstant 147: "\f"
  0051    | TakeRight 51 -> 57
  0054    | PushString2 "\x0c" (esc)
  0057    | Or 57 -> 90
  0060    | SetInputMark
  0061    | CallFunctionConstant 148: "\n"
  0063    | TakeRight 63 -> 68
  0066    | PushString "
  "
  0068    | Or 68 -> 90
  0071    | SetInputMark
  0072    | CallFunctionConstant 149: "\r"
  0074    | TakeRight 74 -> 79
  0077    | PushString "\r (no-eol) (esc)
  "
  0079    | Or 79 -> 90
  0082    | CallFunctionConstant 150: "\t"
  0084    | TakeRight 84 -> 90
  0087    | PushString2 "\t" (esc)
  0090    | End
  ========================================
  
  ===========1:_escaped_unicode===========
  _escaped_unicode = _escaped_surrogate_pair | _escaped_codepoint
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 151: _escaped_surrogate_pair
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 152: _escaped_codepoint
  0008    | End
  ========================================
  
  =======1:_escaped_surrogate_pair========
  _escaped_surrogate_pair = _valid_surrogate_pair | _invalid_surrogate_pair
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 153: _valid_surrogate_pair
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 154: _invalid_surrogate_pair
  0008    | End
  ========================================
  
  ========1:_valid_surrogate_pair=========
  _valid_surrogate_pair =
    _high_surrogate -> H & _low_surrogate -> L $ @SurrogatePairCodepoint(H, L)
  ========================================
  0000    | PushVar2 H
  0003    | PushVar2 L
  0006    | CallFunctionConstant 155: _high_surrogate
  0008    | Destructure 56: H
  0010    | TakeRight 10 -> 28
  0013    | CallFunctionConstant 156: _low_surrogate
  0015    | Destructure 57: L
  0017    | TakeRight 17 -> 28
  0020    | GetConstant 157: @SurrogatePairCodepoint
  0022    | GetBoundLocalMove 0
  0024    | GetBoundLocalMove 1
  0026    | CallTailFunction 2
  0028    | End
  ========================================
  
  =======1:_invalid_surrogate_pair========
  _invalid_surrogate_pair = _low_surrogate | _high_surrogate $ "\u00FFFD"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 156: _low_surrogate
  0003    | Or 3 -> 8
  0006    | CallFunctionConstant 155: _high_surrogate
  0008    | TakeRight 8 -> 14
  0011    | PushString2 "\xef\xbf\xbd" (esc)
  0014    | End
  ========================================
  
  ===========1:_high_surrogate============
  _high_surrogate =
    `\u` > ("D" | "d") + ("8" | "9" | "A" | "B" | "a" | "b") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 158: "\u"
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
  0052    | CallFunctionConstant 159: hex_numeral
  0054    | Merge
  0055    | JumpIfFailure 55 -> 61
  0058    | CallFunctionConstant 159: hex_numeral
  0060    | Merge
  0061    | End
  ========================================
  
  ============1:_low_surrogate============
  _low_surrogate =
    `\u` > ("D" | "d") + ("C".."F" | "c".."f") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 158: "\u"
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
  0030    | CallFunctionConstant 159: hex_numeral
  0032    | Merge
  0033    | JumpIfFailure 33 -> 39
  0036    | CallFunctionConstant 159: hex_numeral
  0038    | Merge
  0039    | End
  ========================================
  
  ==========1:_escaped_codepoint==========
  _escaped_codepoint = `\u` > (hex_numeral * 4) -> U $ @Codepoint(U)
  ========================================
  0000    | PushVar2 U
  0003    | CallFunctionConstant 158: "\u"
  0005    | TakeRight 5 -> 32
  0008    | PushNull
  0009    | PushInteger 4
  0011    | ValidateRepeatPattern
  0012    | JumpIfZero 12 -> 31
  0015    | Swap
  0016    | CallFunctionConstant 159: hex_numeral
  0018    | Merge
  0019    | JumpIfFailure 19 -> 30
  0022    | Swap
  0023    | Decrement
  0024    | JumpIfZero 24 -> 31
  0027    | JumpBack 27 -> 15
  0030    | Swap
  0031    | Drop
  0032    | Destructure 58: U
  0034    | TakeRight 34 -> 43
  0037    | GetConstant 160: @Codepoint
  0039    | GetBoundLocalMove 0
  0041    | CallTailFunction 1
  0043    | End
  ========================================
  
  ==============1:json.array==============
  json.array(elem) = "[" > maybe_array_sep(surround(elem, maybe(ws)), ",") < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 18
  0005    | GetConstant 162: maybe_array_sep
  0007    | GetConstant 163: @fn31
  0009    | CreateClosure 1
  0011    | CaptureLocal 0
  0013    | PushString2 ","
  0016    | CallFunction 2
  0018    | JumpIfFailure 18 -> 24
  0021    | ParseChar ']'
  0023    | TakeLeft
  0024    | End
  ========================================
  
  =============1:json.object==============
  json.object(value) =
    "{" >
    maybe_object_sep(
      surround(json.string, maybe(ws)), ":",
      surround(value, maybe(ws)), ","
    )
    < "}"
  ========================================
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 23
  0005    | GetConstant 165: maybe_object_sep
  0007    | GetConstant 166: @fn33
  0009    | PushString2 ":"
  0012    | GetConstant 167: @fn35
  0014    | CreateClosure 1
  0016    | CaptureLocal 0
  0018    | PushString2 ","
  0021    | CallFunction 4
  0023    | JumpIfFailure 23 -> 29
  0026    | ParseChar '}'
  0028    | TakeLeft
  0029    | End
  ========================================
  
  =============1:toml.simple==============
  toml.simple = toml.custom(toml.simple_value)
  ========================================
  0000    | GetConstant 170: toml.custom
  0002    | GetConstant 171: toml.simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============1:toml.simple==============
  toml.simple = toml.custom(toml.simple_value)
  ========================================
  0000    | GetConstant 170: toml.custom
  0002    | GetConstant 171: toml.simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============1:toml.tagged==============
  toml.tagged = toml.custom(toml.tagged_value)
  ========================================
  0000    | GetConstant 170: toml.custom
  0002    | GetConstant2 322: toml.tagged_value
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =============1:toml.custom==============
  toml.custom(value) =
    maybe(_toml.comments + maybe(ws)) &
    _toml.with_root_table(value) | _toml.no_root_table(value) -> Doc &
    maybe(maybe(ws) + _toml.comments) $
    _Toml.Doc.Value(Doc)
  ========================================
  0000    | PushVar2 Doc
  0003    | GetConstant 34: maybe
  0005    | GetConstant 172: @fn37
  0007    | CallFunction 1
  0009    | TakeRight 9 -> 30
  0012    | SetInputMark
  0013    | GetConstant 173: _toml.with_root_table
  0015    | GetBoundLocal 0
  0017    | CallFunction 1
  0019    | Or 19 -> 28
  0022    | GetConstant 174: _toml.no_root_table
  0024    | GetBoundLocalMove 0
  0026    | CallFunction 1
  0028    | Destructure 59: Doc
  0030    | TakeRight 30 -> 48
  0033    | GetConstant 34: maybe
  0035    | GetConstant 175: @fn38
  0037    | CallFunction 1
  0039    | TakeRight 39 -> 48
  0042    | GetConstant 176: _Toml.Doc.Value
  0044    | GetBoundLocalMove 1
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  ========1:_toml.with_root_table=========
  _toml.with_root_table(value) =
    _toml.root_table(value, _Toml.Doc.Empty) -> RootDoc &
    (_toml.ws > _toml.tables(value, RootDoc)) | const(RootDoc)
  ========================================
  0000    | PushVar2 RootDoc
  0003    | GetConstant 180: _toml.root_table
  0005    | GetBoundLocal 0
  0007    | CallFunctionConstant 181: _Toml.Doc.Empty
  0009    | CallFunction 2
  0011    | Destructure 60: RootDoc
  0013    | TakeRight 13 -> 39
  0016    | SetInputMark
  0017    | CallFunctionConstant 182: _toml.ws
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 183: _toml.tables
  0024    | GetBoundLocalMove 0
  0026    | GetBoundLocal 1
  0028    | CallFunction 2
  0030    | Or 30 -> 39
  0033    | GetConstant 31: const
  0035    | GetBoundLocalMove 1
  0037    | CallTailFunction 1
  0039    | End
  ========================================
  
  ===========1:_toml.root_table===========
  _toml.root_table(value, Doc) =
    _toml.table_body(value, [], Doc)
  ========================================
  0000    | GetConstant 184: _toml.table_body
  0002    | GetBoundLocalMove 0
  0004    | PushEmptyArray
  0005    | GetBoundLocalMove 1
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  =========1:_toml.no_root_table==========
  _toml.no_root_table(value) =
    _toml.table(value, _Toml.Doc.Empty) | _toml.array_of_tables(value, _Toml.Doc.Empty) -> NewDoc &
    _toml.tables(value, NewDoc)
  ========================================
  0000    | PushVar2 NewDoc
  0003    | SetInputMark
  0004    | GetConstant 226: _toml.table
  0006    | GetBoundLocal 0
  0008    | CallFunctionConstant 181: _Toml.Doc.Empty
  0010    | CallFunction 2
  0012    | Or 12 -> 23
  0015    | GetConstant 227: _toml.array_of_tables
  0017    | GetBoundLocal 0
  0019    | CallFunctionConstant 181: _Toml.Doc.Empty
  0021    | CallFunction 2
  0023    | Destructure 77: NewDoc
  0025    | TakeRight 25 -> 36
  0028    | GetConstant 183: _toml.tables
  0030    | GetBoundLocalMove 0
  0032    | GetBoundLocalMove 1
  0034    | CallTailFunction 2
  0036    | End
  ========================================
  
  =============1:_toml.tables=============
  _toml.tables(value, Doc) =
    _toml.ws >
    _toml.table(value, Doc) | _toml.array_of_tables(value, Doc) -> NewDoc ?
    _toml.tables(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | PushVar2 NewDoc
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | CallFunctionConstant 182: _toml.ws
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 226: _toml.table
  0012    | GetBoundLocal 0
  0014    | GetBoundLocal 1
  0016    | CallFunction 2
  0018    | Or 18 -> 29
  0021    | GetConstant 227: _toml.array_of_tables
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | CallFunction 2
  0029    | Destructure 71: NewDoc
  0031    | ConditionalThen 31 -> 45
  0034    | GetConstant 183: _toml.tables
  0036    | GetBoundLocalMove 0
  0038    | GetBoundLocalMove 2
  0040    | CallTailFunction 2
  0042    | Jump 42 -> 51
  0045    | GetConstant 31: const
  0047    | GetBoundLocalMove 1
  0049    | CallTailFunction 1
  0051    | End
  ========================================
  
  =============1:_toml.table==============
  _toml.table(value, Doc) =
    _toml.table_header -> HeaderPath & _toml.ws_newline & (
      _toml.table_body(value, HeaderPath, Doc) |
      const(_Toml.Doc.EnsureTableAtPath(Doc, HeaderPath))
    )
  ========================================
  0000    | PushVar2 HeaderPath
  0003    | CallFunctionConstant 228: _toml.table_header
  0005    | Destructure 72: HeaderPath
  0007    | TakeRight 7 -> 12
  0010    | CallFunctionConstant 186: _toml.ws_newline
  0012    | TakeRight 12 -> 41
  0015    | SetInputMark
  0016    | GetConstant 184: _toml.table_body
  0018    | GetBoundLocalMove 0
  0020    | GetBoundLocal 2
  0022    | GetBoundLocal 1
  0024    | CallFunction 3
  0026    | Or 26 -> 41
  0029    | GetConstant 31: const
  0031    | GetConstant 229: _Toml.Doc.EnsureTableAtPath
  0033    | GetBoundLocalMove 1
  0035    | GetBoundLocalMove 2
  0037    | CallFunction 2
  0039    | CallTailFunction 1
  0041    | End
  ========================================
  
  ========1:_toml.array_of_tables=========
  _toml.array_of_tables(value, Doc) =
    _toml.array_of_tables_header -> HeaderPath & _toml.ws_newline &
    default(_toml.table_body(value, [], _Toml.Doc.Empty), _Toml.Doc.Empty) -> InnerDoc $
    _Toml.Doc.AppendAtPath(Doc, HeaderPath, _Toml.Doc.Value(InnerDoc))
  ========================================
  0000    | PushVar2 HeaderPath
  0003    | PushVar2 InnerDoc
  0006    | CallFunctionConstant 232: _toml.array_of_tables_header
  0008    | Destructure 73: HeaderPath
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionConstant 186: _toml.ws_newline
  0015    | TakeRight 15 -> 49
  0018    | GetConstant 67: default
  0020    | GetConstant 233: @fn39
  0022    | CreateClosure 1
  0024    | CaptureLocal 0
  0026    | CallFunctionConstant 181: _Toml.Doc.Empty
  0028    | CallFunction 2
  0030    | Destructure 74: InnerDoc
  0032    | TakeRight 32 -> 49
  0035    | GetConstant 234: _Toml.Doc.AppendAtPath
  0037    | GetBoundLocalMove 1
  0039    | GetBoundLocalMove 2
  0041    | GetConstant 176: _Toml.Doc.Value
  0043    | GetBoundLocalMove 3
  0045    | CallFunction 1
  0047    | CallTailFunction 3
  0049    | End
  ========================================
  
  ===============1:_toml.ws===============
  _toml.ws = maybe_many(ws | _toml.comment)
  ========================================
  0000    | GetConstant 207: maybe_many
  0002    | GetConstant 209: @fn40
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ============1:_toml.ws_line=============
  _toml.ws_line = maybe_many(spaces | _toml.comment)
  ========================================
  0000    | GetConstant 207: maybe_many
  0002    | GetConstant 208: @fn41
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========1:_toml.ws_newline===========
  _toml.ws_newline = _toml.ws_line + (nl | end) + _toml.ws
  ========================================
  0000    | CallFunctionConstant 206: _toml.ws_line
  0002    | JumpIfFailure 2 -> 14
  0005    | SetInputMark
  0006    | CallFunctionConstant 13: newline
  0008    | Or 8 -> 13
  0011    | CallFunctionConstant 29: end_of_input
  0013    | Merge
  0014    | JumpIfFailure 14 -> 20
  0017    | CallFunctionConstant 182: _toml.ws
  0019    | Merge
  0020    | End
  ========================================
  
  ============1:_toml.comments============
  _toml.comments = many_sep(_toml.comment, ws)
  ========================================
  0000    | GetConstant 120: many_sep
  0002    | GetConstant 178: _toml.comment
  0004    | GetConstant 9: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==========1:_toml.table_header==========
  _toml.table_header = "[" > surround(_toml.path, maybe(ws)) < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 13
  0005    | GetConstant 128: surround
  0007    | GetConstant 189: _toml.path
  0009    | GetConstant 230: @fn42
  0011    | CallFunction 2
  0013    | JumpIfFailure 13 -> 19
  0016    | ParseChar ']'
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =====1:_toml.array_of_tables_header=====
  _toml.array_of_tables_header =
    "[[" > surround(_toml.path, maybe(ws)) < "]]"
  ========================================
  0000    | CallFunctionConstant 235: "[["
  0002    | TakeRight 2 -> 13
  0005    | GetConstant 128: surround
  0007    | GetConstant 189: _toml.path
  0009    | GetConstant 236: @fn43
  0011    | CallFunction 2
  0013    | JumpIfFailure 13 -> 19
  0016    | CallFunctionConstant 237: "]]"
  0018    | TakeLeft
  0019    | End
  ========================================
  
  ===========1:_toml.table_body===========
  _toml.table_body(value, HeaderPath, Doc) =
    _toml.table_pair(value) -> [KeyPath, Val] & _toml.ws_newline &
    const(_Toml.Doc.InsertAtPath(Doc, HeaderPath + KeyPath, Val)) -> NewDoc &
    _toml.table_body(value, HeaderPath, NewDoc) | const(NewDoc)
  ========================================
  0000    | PushVar2 KeyPath
  0003    | PushVar2 Val
  0006    | PushVar2 NewDoc
  0009    | GetConstant 185: _toml.table_pair
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | Destructure 61: [KeyPath, Val]
  0017    | TakeRight 17 -> 22
  0020    | CallFunctionConstant 186: _toml.ws_newline
  0022    | TakeRight 22 -> 47
  0025    | GetConstant 31: const
  0027    | GetConstant 187: _Toml.Doc.InsertAtPath
  0029    | GetBoundLocalMove 2
  0031    | GetBoundLocal 1
  0033    | JumpIfFailure 33 -> 39
  0036    | GetBoundLocalMove 3
  0038    | Merge
  0039    | GetBoundLocalMove 4
  0041    | CallFunction 3
  0043    | CallFunction 1
  0045    | Destructure 62: NewDoc
  0047    | TakeRight 47 -> 70
  0050    | SetInputMark
  0051    | GetConstant 184: _toml.table_body
  0053    | GetBoundLocalMove 0
  0055    | GetBoundLocalMove 1
  0057    | GetBoundLocal 5
  0059    | CallFunction 3
  0061    | Or 61 -> 70
  0064    | GetConstant 31: const
  0066    | GetBoundLocalMove 5
  0068    | CallTailFunction 1
  0070    | End
  ========================================
  
  ===========1:_toml.table_pair===========
  _toml.table_pair(value) =
    tuple2_sep(_toml.path, surround("=", maybe(spaces)), value)
  ========================================
  0000    | GetConstant 188: tuple2_sep
  0002    | GetConstant 189: _toml.path
  0004    | GetConstant 190: @fn44
  0006    | GetBoundLocalMove 0
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==============1:_toml.path==============
  _toml.path = array_sep(_toml.key, surround(".", maybe(ws)))
  ========================================
  0000    | GetConstant 70: array_sep
  0002    | GetConstant 191: _toml.key
  0004    | GetConstant 192: @fn46
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==============1:_toml.key===============
  _toml.key =
    many(alpha | numeral | "_" | "-") |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetConstant 193: @fn48
  0005    | CallFunction 1
  0007    | Or 7 -> 18
  0010    | SetInputMark
  0011    | CallFunctionConstant 194: toml.string.basic
  0013    | Or 13 -> 18
  0016    | CallTailFunctionConstant 195: toml.string.literal
  0018    | End
  ========================================
  
  ============1:_toml.comment=============
  _toml.comment = "#" > maybe(line)
  ========================================
  0000    | ParseChar '#'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 34: maybe
  0007    | GetConstant 179: line
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  ==========1:toml.simple_value===========
  toml.simple_value =
    toml.string |
    toml.datetime |
    toml.number |
    toml.boolean |
    toml.array(toml.simple_value) |
    toml.inline_table(toml.simple_value)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 241: toml.string
  0003    | Or 3 -> 40
  0006    | SetInputMark
  0007    | CallFunctionConstant 242: toml.datetime
  0009    | Or 9 -> 40
  0012    | SetInputMark
  0013    | CallFunctionConstant 243: toml.number
  0015    | Or 15 -> 40
  0018    | SetInputMark
  0019    | CallFunctionConstant 244: toml.boolean
  0021    | Or 21 -> 40
  0024    | SetInputMark
  0025    | GetConstant 245: toml.array
  0027    | GetConstant 171: toml.simple_value
  0029    | CallFunction 1
  0031    | Or 31 -> 40
  0034    | GetConstant 246: toml.inline_table
  0036    | GetConstant 171: toml.simple_value
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  ==========1:toml.tagged_value===========
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
  0001    | CallFunctionConstant 241: toml.string
  0003    | Or 3 -> 173
  0006    | SetInputMark
  0007    | GetConstant2 323: _toml.tag
  0010    | PushString2 "datetime"
  0013    | PushString2 "offset"
  0016    | GetConstant2 256: toml.datetime.offset
  0019    | CallFunction 3
  0021    | Or 21 -> 173
  0024    | SetInputMark
  0025    | GetConstant2 323: _toml.tag
  0028    | PushString2 "datetime"
  0031    | PushString2 "local"
  0034    | GetConstant2 257: toml.datetime.local
  0037    | CallFunction 3
  0039    | Or 39 -> 173
  0042    | SetInputMark
  0043    | GetConstant2 323: _toml.tag
  0046    | PushString2 "datetime"
  0049    | PushString2 "date-local"
  0052    | GetConstant2 258: toml.datetime.local_date
  0055    | CallFunction 3
  0057    | Or 57 -> 173
  0060    | SetInputMark
  0061    | GetConstant2 323: _toml.tag
  0064    | PushString2 "datetime"
  0067    | PushString2 "time-local"
  0070    | GetConstant2 259: toml.datetime.local_time
  0073    | CallFunction 3
  0075    | Or 75 -> 173
  0078    | SetInputMark
  0079    | CallFunctionConstant2 272: toml.number.binary_integer
  0082    | Or 82 -> 173
  0085    | SetInputMark
  0086    | CallFunctionConstant2 273: toml.number.octal_integer
  0089    | Or 89 -> 173
  0092    | SetInputMark
  0093    | CallFunctionConstant2 274: toml.number.hex_integer
  0096    | Or 96 -> 173
  0099    | SetInputMark
  0100    | GetConstant2 323: _toml.tag
  0103    | PushString2 "float"
  0106    | PushString2 "infinity"
  0109    | GetConstant2 275: toml.number.infinity
  0112    | CallFunction 3
  0114    | Or 114 -> 173
  0117    | SetInputMark
  0118    | GetConstant2 323: _toml.tag
  0121    | PushString2 "float"
  0124    | PushString2 "not-a-number"
  0127    | GetConstant2 276: toml.number.not_a_number
  0130    | CallFunction 3
  0132    | Or 132 -> 173
  0135    | SetInputMark
  0136    | CallFunctionConstant2 277: toml.number.float
  0139    | Or 139 -> 173
  0142    | SetInputMark
  0143    | CallFunctionConstant2 278: toml.number.integer
  0146    | Or 146 -> 173
  0149    | SetInputMark
  0150    | CallFunctionConstant 244: toml.boolean
  0152    | Or 152 -> 173
  0155    | SetInputMark
  0156    | GetConstant 245: toml.array
  0158    | GetConstant2 322: toml.tagged_value
  0161    | CallFunction 1
  0163    | Or 163 -> 173
  0166    | GetConstant 246: toml.inline_table
  0168    | GetConstant2 322: toml.tagged_value
  0171    | CallTailFunction 1
  0173    | End
  ========================================
  
  ==============1:_toml.tag===============
  _toml.tag(Type, Subtype, value) =
    value -> Value $ {"type": Type, "subtype": Subtype, "value": Value}
  ========================================
  0000    | PushVar2 Value
  0003    | CallFunctionLocal 2
  0005    | Destructure 86: Value
  0007    | TakeRight 7 -> 34
  0010    | GetConstantMutable2 324: {_0_, _1_, _2_}
  0013    | PushString2 "type"
  0016    | GetBoundLocalMove 0
  0018    | InsertKeyVal 0
  0020    | PushString2 "subtype"
  0023    | GetBoundLocalMove 1
  0025    | InsertKeyVal 1
  0027    | PushString2 "value"
  0030    | GetBoundLocalMove 3
  0032    | InsertKeyVal 2
  0034    | End
  ========================================
  
  =============1:toml.string==============
  toml.string =
    toml.string.multi_line_basic |
    toml.string.multi_line_literal |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 247: toml.string.multi_line_basic
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 248: toml.string.multi_line_literal
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | CallFunctionConstant 194: toml.string.basic
  0015    | Or 15 -> 20
  0018    | CallTailFunctionConstant 195: toml.string.literal
  0020    | End
  ========================================
  
  ============1:toml.datetime=============
  toml.datetime =
    toml.datetime.offset |
    toml.datetime.local |
    toml.datetime.local_date |
    toml.datetime.local_time
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 256: toml.datetime.offset
  0004    | Or 4 -> 24
  0007    | SetInputMark
  0008    | CallFunctionConstant2 257: toml.datetime.local
  0011    | Or 11 -> 24
  0014    | SetInputMark
  0015    | CallFunctionConstant2 258: toml.datetime.local_date
  0018    | Or 18 -> 24
  0021    | CallTailFunctionConstant2 259: toml.datetime.local_time
  0024    | End
  ========================================
  
  =============1:toml.number==============
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
  0001    | CallFunctionConstant2 272: toml.number.binary_integer
  0004    | Or 4 -> 45
  0007    | SetInputMark
  0008    | CallFunctionConstant2 273: toml.number.octal_integer
  0011    | Or 11 -> 45
  0014    | SetInputMark
  0015    | CallFunctionConstant2 274: toml.number.hex_integer
  0018    | Or 18 -> 45
  0021    | SetInputMark
  0022    | CallFunctionConstant2 275: toml.number.infinity
  0025    | Or 25 -> 45
  0028    | SetInputMark
  0029    | CallFunctionConstant2 276: toml.number.not_a_number
  0032    | Or 32 -> 45
  0035    | SetInputMark
  0036    | CallFunctionConstant2 277: toml.number.float
  0039    | Or 39 -> 45
  0042    | CallTailFunctionConstant2 278: toml.number.integer
  0045    | End
  ========================================
  
  =============1:toml.boolean=============
  toml.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 137: boolean
  0002    | PushString2 "true"
  0005    | PushString2 "false"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  ==============1:toml.array==============
  toml.array(elem) =
    "[" > _toml.ws > default(
      array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws)),
      []
    ) < _toml.ws < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 182: _toml.ws
  0007    | TakeRight 7 -> 22
  0010    | GetConstant 67: default
  0012    | GetConstant2 315: @fn49
  0015    | CreateClosure 1
  0017    | CaptureLocal 0
  0019    | PushEmptyArray
  0020    | CallFunction 2
  0022    | JumpIfFailure 22 -> 28
  0025    | CallFunctionConstant 182: _toml.ws
  0027    | TakeLeft
  0028    | JumpIfFailure 28 -> 34
  0031    | ParseChar ']'
  0033    | TakeLeft
  0034    | End
  ========================================
  
  ==========1:toml.inline_table===========
  toml.inline_table(value) =
    _toml.empty_inline_table | _toml.nonempty_inline_table(value) -> InlineDoc $
    _Toml.Doc.Value(InlineDoc)
  ========================================
  0000    | PushVar2 InlineDoc
  0003    | SetInputMark
  0004    | CallFunctionConstant2 318: _toml.empty_inline_table
  0007    | Or 7 -> 17
  0010    | GetConstant2 319: _toml.nonempty_inline_table
  0013    | GetBoundLocalMove 0
  0015    | CallFunction 1
  0017    | Destructure 81: InlineDoc
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 176: _Toml.Doc.Value
  0024    | GetBoundLocalMove 1
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  =======1:_toml.empty_inline_table=======
  _toml.empty_inline_table = "{" > maybe(spaces) < "}" $ _Toml.Doc.Empty
  ========================================
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 34: maybe
  0007    | GetConstant 205: spaces
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 17
  0014    | ParseChar '}'
  0016    | TakeLeft
  0017    | TakeRight 17 -> 22
  0020    | CallTailFunctionConstant 181: _Toml.Doc.Empty
  0022    | End
  ========================================
  
  =====1:_toml.nonempty_inline_table======
  _toml.nonempty_inline_table(value) =
    "{" > maybe(spaces) >
    _toml.inline_table_pair(value, _Toml.Doc.Empty) -> DocWithFirstPair &
    _toml.inline_table_body(value, DocWithFirstPair)
    < maybe(spaces) < "}"
  ========================================
  0000    | PushVar2 DocWithFirstPair
  0003    | ParseChar '{'
  0005    | TakeRight 5 -> 14
  0008    | GetConstant 34: maybe
  0010    | GetConstant 205: spaces
  0012    | CallFunction 1
  0014    | TakeRight 14 -> 26
  0017    | GetConstant2 320: _toml.inline_table_pair
  0020    | GetBoundLocal 0
  0022    | CallFunctionConstant 181: _Toml.Doc.Empty
  0024    | CallFunction 2
  0026    | Destructure 82: DocWithFirstPair
  0028    | TakeRight 28 -> 56
  0031    | GetConstant2 321: _toml.inline_table_body
  0034    | GetBoundLocalMove 0
  0036    | GetBoundLocalMove 1
  0038    | CallFunction 2
  0040    | JumpIfFailure 40 -> 50
  0043    | GetConstant 34: maybe
  0045    | GetConstant 205: spaces
  0047    | CallFunction 1
  0049    | TakeLeft
  0050    | JumpIfFailure 50 -> 56
  0053    | ParseChar '}'
  0055    | TakeLeft
  0056    | End
  ========================================
  
  =======1:_toml.inline_table_body========
  _toml.inline_table_body(value, Doc) =
    "," > _toml.inline_table_pair(value, Doc) -> NewDoc ?
    _toml.inline_table_body(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | PushVar2 NewDoc
  0003    | SetInputMark
  0004    | ParseChar ','
  0006    | TakeRight 6 -> 18
  0009    | GetConstant2 320: _toml.inline_table_pair
  0012    | GetBoundLocal 0
  0014    | GetBoundLocal 1
  0016    | CallFunction 2
  0018    | Destructure 85: NewDoc
  0020    | ConditionalThen 20 -> 35
  0023    | GetConstant2 321: _toml.inline_table_body
  0026    | GetBoundLocalMove 0
  0028    | GetBoundLocalMove 2
  0030    | CallTailFunction 2
  0032    | Jump 32 -> 41
  0035    | GetConstant 31: const
  0037    | GetBoundLocalMove 1
  0039    | CallTailFunction 1
  0041    | End
  ========================================
  
  =======1:_toml.inline_table_pair========
  _toml.inline_table_pair(value, Doc) =
    maybe(spaces) &
    _toml.path -> Key &
    maybe(spaces) & "=" & maybe(spaces) &
    value -> Val &
    maybe(spaces) $
    _Toml.Doc.InsertAtPath(Doc, Key, Val)
  ========================================
  0000    | PushVar2 Key
  0003    | PushVar2 Val
  0006    | GetConstant 34: maybe
  0008    | GetConstant 205: spaces
  0010    | CallFunction 1
  0012    | TakeRight 12 -> 19
  0015    | CallFunctionConstant 189: _toml.path
  0017    | Destructure 83: Key
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 34: maybe
  0024    | GetConstant 205: spaces
  0026    | CallFunction 1
  0028    | TakeRight 28 -> 33
  0031    | ParseChar '='
  0033    | TakeRight 33 -> 42
  0036    | GetConstant 34: maybe
  0038    | GetConstant 205: spaces
  0040    | CallFunction 1
  0042    | TakeRight 42 -> 49
  0045    | CallFunctionLocal 0
  0047    | Destructure 84: Val
  0049    | TakeRight 49 -> 71
  0052    | GetConstant 34: maybe
  0054    | GetConstant 205: spaces
  0056    | CallFunction 1
  0058    | TakeRight 58 -> 71
  0061    | GetConstant 187: _Toml.Doc.InsertAtPath
  0063    | GetBoundLocalMove 1
  0065    | GetBoundLocalMove 2
  0067    | GetBoundLocalMove 3
  0069    | CallTailFunction 3
  0071    | End
  ========================================
  
  =====1:toml.string.multi_line_basic=====
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
  0000    | GetConstant 249: skip
  0002    | PushString2 """""
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 249: skip
  0012    | GetConstant 250: @fn52
  0014    | CallFunction 1
  0016    | Merge
  0017    | JumpIfFailure 17 -> 28
  0020    | GetConstant 67: default
  0022    | GetConstant 251: @fn53
  0024    | PushEmptyString
  0025    | CallFunction 2
  0027    | Merge
  0028    | JumpIfFailure 28 -> 39
  0031    | GetConstant 249: skip
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
  
  ====1:toml.string.multi_line_literal====
  toml.string.multi_line_literal =
    skip(`'''`) + skip(maybe(nl)) +
    default(many_until(char, `'''`), $"")
    + skip(`'''`) + (`'` * 0..2)
  ========================================
  0000    | GetConstant 249: skip
  0002    | PushString2 "'''"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 249: skip
  0012    | GetConstant 254: @fn56
  0014    | CallFunction 1
  0016    | Merge
  0017    | JumpIfFailure 17 -> 28
  0020    | GetConstant 67: default
  0022    | GetConstant 255: @fn57
  0024    | PushEmptyString
  0025    | CallFunction 2
  0027    | Merge
  0028    | JumpIfFailure 28 -> 39
  0031    | GetConstant 249: skip
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
  
  ==========1:toml.string.basic===========
  toml.string.basic = '"' > _toml.string.basic_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 196: _toml.string.basic_body
  0007    | JumpIfFailure 7 -> 13
  0010    | ParseChar '"'
  0012    | TakeLeft
  0013    | End
  ========================================
  
  =======1:_toml.string.basic_body========
  _toml.string.basic_body =
    many(
      _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
    ) | const($"")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetConstant 197: @fn58
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 31: const
  0012    | PushEmptyString
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  =========1:toml.string.literal==========
  toml.string.literal = "'" > default(chars_until("'"), $"") < "'"
  ========================================
  0000    | ParseChar '''
  0002    | TakeRight 2 -> 12
  0005    | GetConstant 67: default
  0007    | GetConstant 202: @fn60
  0009    | PushEmptyString
  0010    | CallFunction 2
  0012    | JumpIfFailure 12 -> 18
  0015    | ParseChar '''
  0017    | TakeLeft
  0018    | End
  ========================================
  
  =======1:_toml.escaped_ctrl_char========
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
  0001    | CallFunctionConstant 143: "\""
  0003    | TakeRight 3 -> 9
  0006    | PushString2 """
  0009    | Or 9 -> 78
  0012    | SetInputMark
  0013    | CallFunctionConstant 144: "\\"
  0015    | TakeRight 15 -> 21
  0018    | PushString2 "\"
  0021    | Or 21 -> 78
  0024    | SetInputMark
  0025    | CallFunctionConstant 146: "\b"
  0027    | TakeRight 27 -> 33
  0030    | PushString2 "\x08" (esc)
  0033    | Or 33 -> 78
  0036    | SetInputMark
  0037    | CallFunctionConstant 147: "\f"
  0039    | TakeRight 39 -> 45
  0042    | PushString2 "\x0c" (esc)
  0045    | Or 45 -> 78
  0048    | SetInputMark
  0049    | CallFunctionConstant 148: "\n"
  0051    | TakeRight 51 -> 56
  0054    | PushString "
  "
  0056    | Or 56 -> 78
  0059    | SetInputMark
  0060    | CallFunctionConstant 149: "\r"
  0062    | TakeRight 62 -> 67
  0065    | PushString "\r (no-eol) (esc)
  "
  0067    | Or 67 -> 78
  0070    | CallFunctionConstant 150: "\t"
  0072    | TakeRight 72 -> 78
  0075    | PushString2 "\t" (esc)
  0078    | End
  ========================================
  
  ========1:_toml.escaped_unicode=========
  _toml.escaped_unicode =
    (`\u` > (hex_numeral * 4) -> U $ @Codepoint(U)) |
    (`\U` > (hex_numeral * 8) -> U $ @Codepoint(U))
  ========================================
  0000    | PushVar2 U
  0003    | SetInputMark
  0004    | CallFunctionConstant 158: "\u"
  0006    | TakeRight 6 -> 33
  0009    | PushNull
  0010    | PushInteger 4
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 32
  0016    | Swap
  0017    | CallFunctionConstant 159: hex_numeral
  0019    | Merge
  0020    | JumpIfFailure 20 -> 31
  0023    | Swap
  0024    | Decrement
  0025    | JumpIfZero 25 -> 32
  0028    | JumpBack 28 -> 16
  0031    | Swap
  0032    | Drop
  0033    | Destructure 63: U
  0035    | TakeRight 35 -> 44
  0038    | GetConstant 160: @Codepoint
  0040    | GetBoundLocal 0
  0042    | CallFunction 1
  0044    | Or 44 -> 87
  0047    | CallFunctionConstant 201: "\U"
  0049    | TakeRight 49 -> 76
  0052    | PushNull
  0053    | PushInteger 8
  0055    | ValidateRepeatPattern
  0056    | JumpIfZero 56 -> 75
  0059    | Swap
  0060    | CallFunctionConstant 159: hex_numeral
  0062    | Merge
  0063    | JumpIfFailure 63 -> 74
  0066    | Swap
  0067    | Decrement
  0068    | JumpIfZero 68 -> 75
  0071    | JumpBack 71 -> 59
  0074    | Swap
  0075    | Drop
  0076    | Destructure 64: U
  0078    | TakeRight 78 -> 87
  0081    | GetConstant 160: @Codepoint
  0083    | GetBoundLocalMove 0
  0085    | CallTailFunction 1
  0087    | End
  ========================================
  
  =========1:toml.datetime.offset=========
  toml.datetime.offset = toml.datetime.local_date + ("T" | "t" | " ") + _toml.datetime.time_offset
  ========================================
  0000    | CallFunctionConstant2 258: toml.datetime.local_date
  0003    | JumpIfFailure 3 -> 21
  0006    | SetInputMark
  0007    | ParseChar 'T'
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | ParseChar 't'
  0015    | Or 15 -> 20
  0018    | ParseChar ' '
  0020    | Merge
  0021    | JumpIfFailure 21 -> 28
  0024    | CallFunctionConstant2 260: _toml.datetime.time_offset
  0027    | Merge
  0028    | End
  ========================================
  
  =========1:toml.datetime.local==========
  toml.datetime.local = toml.datetime.local_date + ("T" | "t" | " ") + toml.datetime.local_time
  ========================================
  0000    | CallFunctionConstant2 258: toml.datetime.local_date
  0003    | JumpIfFailure 3 -> 21
  0006    | SetInputMark
  0007    | ParseChar 'T'
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | ParseChar 't'
  0015    | Or 15 -> 20
  0018    | ParseChar ' '
  0020    | Merge
  0021    | JumpIfFailure 21 -> 28
  0024    | CallFunctionConstant2 259: toml.datetime.local_time
  0027    | Merge
  0028    | End
  ========================================
  
  =======1:toml.datetime.local_date=======
  toml.datetime.local_date =
    _toml.datetime.year + "-" + _toml.datetime.month + "-" + _toml.datetime.mday
  ========================================
  0000    | CallFunctionConstant2 261: _toml.datetime.year
  0003    | JumpIfFailure 3 -> 9
  0006    | ParseChar '-'
  0008    | Merge
  0009    | JumpIfFailure 9 -> 16
  0012    | CallFunctionConstant2 262: _toml.datetime.month
  0015    | Merge
  0016    | JumpIfFailure 16 -> 22
  0019    | ParseChar '-'
  0021    | Merge
  0022    | JumpIfFailure 22 -> 29
  0025    | CallFunctionConstant2 263: _toml.datetime.mday
  0028    | Merge
  0029    | End
  ========================================
  
  =========1:_toml.datetime.year==========
  _toml.datetime.year = numeral * 4
  ========================================
  0000    | PushNull
  0001    | PushInteger 4
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | CallFunctionConstant 4: numeral
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
  
  =========1:_toml.datetime.month=========
  _toml.datetime.month = ("0" + "1".."9") | ("1" + "0".."2")
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
  
  =========1:_toml.datetime.mday==========
  _toml.datetime.mday = ("0".."2" + "1".."9") | "30" | "31"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'2'
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseCodepointRange '1'..'9'
  0010    | Merge
  0011    | Or 11 -> 24
  0014    | SetInputMark
  0015    | CallFunctionConstant2 264: "30"
  0018    | Or 18 -> 24
  0021    | CallTailFunctionConstant2 265: "31"
  0024    | End
  ========================================
  
  =======1:toml.datetime.local_time=======
  toml.datetime.local_time =
    _toml.datetime.hours + ":" +
    _toml.datetime.minutes + ":" +
    _toml.datetime.seconds +
    maybe("." + (numeral * 1..9))
  ========================================
  0000    | CallFunctionConstant2 267: _toml.datetime.hours
  0003    | JumpIfFailure 3 -> 9
  0006    | ParseChar ':'
  0008    | Merge
  0009    | JumpIfFailure 9 -> 16
  0012    | CallFunctionConstant2 268: _toml.datetime.minutes
  0015    | Merge
  0016    | JumpIfFailure 16 -> 22
  0019    | ParseChar ':'
  0021    | Merge
  0022    | JumpIfFailure 22 -> 29
  0025    | CallFunctionConstant2 269: _toml.datetime.seconds
  0028    | Merge
  0029    | JumpIfFailure 29 -> 40
  0032    | GetConstant 34: maybe
  0034    | GetConstant2 270: @fn61
  0037    | CallFunction 1
  0039    | Merge
  0040    | End
  ========================================
  
  ======1:_toml.datetime.time_offset======
  _toml.datetime.time_offset = toml.datetime.local_time + ("Z" | "z" | _toml.datetime.time_numoffset)
  ========================================
  0000    | CallFunctionConstant2 259: toml.datetime.local_time
  0003    | JumpIfFailure 3 -> 22
  0006    | SetInputMark
  0007    | ParseChar 'Z'
  0009    | Or 9 -> 21
  0012    | SetInputMark
  0013    | ParseChar 'z'
  0015    | Or 15 -> 21
  0018    | CallFunctionConstant2 266: _toml.datetime.time_numoffset
  0021    | Merge
  0022    | End
  ========================================
  
  ====1:_toml.datetime.time_numoffset=====
  _toml.datetime.time_numoffset = ("+" | "-") + _toml.datetime.hours + ":" + _toml.datetime.minutes
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | JumpIfFailure 8 -> 15
  0011    | CallFunctionConstant2 267: _toml.datetime.hours
  0014    | Merge
  0015    | JumpIfFailure 15 -> 21
  0018    | ParseChar ':'
  0020    | Merge
  0021    | JumpIfFailure 21 -> 28
  0024    | CallFunctionConstant2 268: _toml.datetime.minutes
  0027    | Merge
  0028    | End
  ========================================
  
  =========1:_toml.datetime.hours=========
  _toml.datetime.hours = ("0".."1" + "0".."9") | ("2" + "0".."3")
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
  
  ========1:_toml.datetime.minutes========
  _toml.datetime.minutes = "0".."5" + "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'5'
  0003    | JumpIfFailure 3 -> 10
  0006    | ParseCodepointRange '0'..'9'
  0009    | Merge
  0010    | End
  ========================================
  
  ========1:_toml.datetime.seconds========
  _toml.datetime.seconds = ("0".."5" + "0".."9") | "60"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'5'
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseCodepointRange '0'..'9'
  0010    | Merge
  0011    | Or 11 -> 17
  0014    | CallTailFunctionConstant2 271: "60"
  0017    | End
  ========================================
  
  =========1:toml.number.integer==========
  toml.number.integer = as_number(
    _toml.number.sign +
    _toml.number.integer_part
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant2 314: @fn62
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ==========1:_toml.number.sign===========
  _toml.number.sign = maybe("-" | skip("+"))
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant2 309: @fn63
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ======1:_toml.number.integer_part=======
  _toml.number.integer_part =
    ("1".."9" + many(maybe("_") > numeral)) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 15
  0007    | GetConstant 0: many
  0009    | GetConstant2 310: @fn64
  0012    | CallFunction 1
  0014    | Merge
  0015    | Or 15 -> 20
  0018    | CallTailFunctionConstant 4: numeral
  0020    | End
  ========================================
  
  ==========1:toml.number.float===========
  toml.number.float = as_number(
    _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  )
  ========================================
  0000    | GetConstant 32: as_number
  0002    | GetConstant2 304: @fn65
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ======1:_toml.number.fraction_part======
  _toml.number.fraction_part = "." + many_sep(numerals, maybe("_"))
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstant 120: many_sep
  0007    | GetConstant 36: numerals
  0009    | GetConstant2 311: @fn66
  0012    | CallFunction 2
  0014    | Merge
  0015    | End
  ========================================
  
  ======1:_toml.number.exponent_part======
  _toml.number.exponent_part =
    ("e" | "E") + maybe("-" | "+") + many_sep(numerals, maybe("_"))
  ========================================
  0000    | SetInputMark
  0001    | ParseChar 'e'
  0003    | Or 3 -> 8
  0006    | ParseChar 'E'
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 34: maybe
  0013    | GetConstant2 312: @fn67
  0016    | CallFunction 1
  0018    | Merge
  0019    | JumpIfFailure 19 -> 32
  0022    | GetConstant 120: many_sep
  0024    | GetConstant 36: numerals
  0026    | GetConstant2 313: @fn68
  0029    | CallFunction 2
  0031    | Merge
  0032    | End
  ========================================
  
  =========1:toml.number.infinity=========
  toml.number.infinity = maybe("+" | "-") + "inf"
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant2 300: @fn69
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 14
  0010    | CallFunctionConstant2 301: "inf"
  0013    | Merge
  0014    | End
  ========================================
  
  =======1:toml.number.not_a_number=======
  toml.number.not_a_number = maybe("+" | "-") + "nan"
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant2 302: @fn70
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 14
  0010    | CallFunctionConstant2 303: "nan"
  0013    | Merge
  0014    | End
  ========================================
  
  ======1:toml.number.binary_integer======
  toml.number.binary_integer =
    "0b" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral)),
      array_sep(binary_digit, maybe("_"))
    ) -> Digits $
    Num.FromBinaryDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | CallFunctionConstant2 279: "0b"
  0006    | TakeRight 6 -> 31
  0009    | GetConstant2 280: one_or_both
  0012    | GetConstant2 281: @fn71
  0015    | GetConstant2 282: @fn74
  0018    | CallFunction 2
  0020    | Destructure 78: Digits
  0022    | TakeRight 22 -> 31
  0025    | GetConstant 50: Num.FromBinaryDigits
  0027    | GetBoundLocalMove 0
  0029    | CallTailFunction 1
  0031    | End
  ========================================
  
  ======1:toml.number.octal_integer=======
  toml.number.octal_integer =
    "0o" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral)),
      array_sep(octal_digit, maybe("_"))
    ) -> Digits $
    Num.FromOctalDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | CallFunctionConstant2 287: "0o"
  0006    | TakeRight 6 -> 31
  0009    | GetConstant2 280: one_or_both
  0012    | GetConstant2 288: @fn76
  0015    | GetConstant2 289: @fn79
  0018    | CallFunction 2
  0020    | Destructure 79: Digits
  0022    | TakeRight 22 -> 31
  0025    | GetConstant 58: Num.FromOctalDigits
  0027    | GetBoundLocalMove 0
  0029    | CallTailFunction 1
  0031    | End
  ========================================
  
  =======1:toml.number.hex_integer========
  toml.number.hex_integer =
    "0x" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral)),
      array_sep(hex_digit, maybe("_"))
    ) -> Digits $
    Num.FromHexDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | CallFunctionConstant2 294: "0x"
  0006    | TakeRight 6 -> 31
  0009    | GetConstant2 280: one_or_both
  0012    | GetConstant2 295: @fn81
  0015    | GetConstant2 296: @fn84
  0018    | CallFunction 2
  0020    | Destructure 80: Digits
  0022    | TakeRight 22 -> 31
  0025    | GetConstant 61: Num.FromHexDigits
  0027    | GetBoundLocalMove 0
  0029    | CallTailFunction 1
  0031    | End
  ========================================
  
  ===========1:_Toml.Doc.Empty============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant 221: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  ===========1:_Toml.Doc.Value============
  _Toml.Doc.Value(Doc) = Obj.Get(Doc, "value")
  ========================================
  0000    | GetConstant 218: Obj.Get
  0002    | GetBoundLocalMove 0
  0004    | PushString2 "value"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ============1:_Toml.Doc.Type============
  _Toml.Doc.Type(Doc) = Obj.Get(Doc, "type")
  ========================================
  0000    | GetConstant 218: Obj.Get
  0002    | GetBoundLocalMove 0
  0004    | PushString2 "type"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ============1:_Toml.Doc.Has=============
  _Toml.Doc.Has(Doc, Key) = Obj.Has(_Toml.Doc.Type(Doc), Key)
  ========================================
  0000    | GetConstant 217: Obj.Has
  0002    | GetConstant 216: _Toml.Doc.Type
  0004    | GetBoundLocalMove 0
  0006    | CallFunction 1
  0008    | GetBoundLocalMove 1
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ============1:_Toml.Doc.Get=============
  _Toml.Doc.Get(Doc, Key) = {
    "value": Obj.Get(_Toml.Doc.Value(Doc), Key),
    "type": Obj.Get(_Toml.Doc.Type(Doc), Key),
  }
  ========================================
  0000    | GetConstantMutable 220: {_0_, _1_}
  0002    | PushString2 "value"
  0005    | GetConstant 218: Obj.Get
  0007    | GetConstant 176: _Toml.Doc.Value
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | GetBoundLocal 1
  0015    | CallFunction 2
  0017    | InsertKeyVal 0
  0019    | PushString2 "type"
  0022    | GetConstant 218: Obj.Get
  0024    | GetConstant 216: _Toml.Doc.Type
  0026    | GetBoundLocalMove 0
  0028    | CallFunction 1
  0030    | GetBoundLocalMove 1
  0032    | CallFunction 2
  0034    | InsertKeyVal 1
  0036    | End
  ========================================
  
  ==========1:_Toml.Doc.IsTable===========
  _Toml.Doc.IsTable(Doc) = Is.Object(_Toml.Doc.Type(Doc))
  ========================================
  0000    | GetConstant 219: Is.Object
  0002    | GetConstant 216: _Toml.Doc.Type
  0004    | GetBoundLocalMove 0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ===========1:_Toml.Doc.Insert===========
  _Toml.Doc.Insert(Doc, Key, Val, Type) =
    _Toml.Doc.IsTable(Doc) &
    {
      "value": Obj.Put(_Toml.Doc.Value(Doc), Key, Val),
      "type": Obj.Put(_Toml.Doc.Type(Doc), Key, Type),
    }
  ========================================
  0000    | GetConstant 213: _Toml.Doc.IsTable
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 49
  0009    | GetConstantMutable 222: {_0_, _1_}
  0011    | PushString2 "value"
  0014    | GetConstant 223: Obj.Put
  0016    | GetConstant 176: _Toml.Doc.Value
  0018    | GetBoundLocal 0
  0020    | CallFunction 1
  0022    | GetBoundLocal 1
  0024    | GetBoundLocalMove 2
  0026    | CallFunction 3
  0028    | InsertKeyVal 0
  0030    | PushString2 "type"
  0033    | GetConstant 223: Obj.Put
  0035    | GetConstant 216: _Toml.Doc.Type
  0037    | GetBoundLocalMove 0
  0039    | CallFunction 1
  0041    | GetBoundLocalMove 1
  0043    | GetBoundLocalMove 3
  0045    | CallFunction 3
  0047    | InsertKeyVal 1
  0049    | End
  ========================================
  
  ===1:_Toml.Doc.AppendToArrayOfTables====
  _Toml.Doc.AppendToArrayOfTables(Doc, Key, Val) =
    _Toml.Doc.Get(Doc, Key) -> {"value": AoT, "type": "array_of_tables"} &
    _Toml.Doc.Insert(Doc, Key, [...AoT, Val], "array_of_tables")
  ========================================
  0000    | PushVar2 AoT
  0003    | GetConstant 214: _Toml.Doc.Get
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | Destructure 76: {"value": AoT, "type": "array_of_tables"}
  0013    | TakeRight 13 -> 44
  0016    | GetConstant 215: _Toml.Doc.Insert
  0018    | GetBoundLocalMove 0
  0020    | GetBoundLocalMove 1
  0022    | PushEmptyArray
  0023    | JumpIfFailure 23 -> 29
  0026    | GetBoundLocalMove 3
  0028    | Merge
  0029    | JumpIfFailure 29 -> 39
  0032    | GetConstantMutable 240: [_]
  0034    | GetBoundLocalMove 2
  0036    | InsertAtIndex 0
  0038    | Merge
  0039    | PushString2 "array_of_tables"
  0042    | CallTailFunction 4
  0044    | End
  ========================================
  
  ========1:_Toml.Doc.InsertAtPath========
  _Toml.Doc.InsertAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.ValueUpdater)
  ========================================
  0000    | GetConstant 210: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocalMove 0
  0004    | GetBoundLocalMove 1
  0006    | GetBoundLocalMove 2
  0008    | GetConstant 211: _Toml.Doc.ValueUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =====1:_Toml.Doc.EnsureTableAtPath======
  _Toml.Doc.EnsureTableAtPath(Doc, Path) =
    _Toml.Doc.UpdateAtPath(Doc, Path, {}, _Toml.Doc.MissingTableUpdater)
  ========================================
  0000    | GetConstant 210: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocalMove 0
  0004    | GetBoundLocalMove 1
  0006    | PushEmptyObject
  0007    | GetConstant 231: _Toml.Doc.MissingTableUpdater
  0009    | CallTailFunction 4
  0011    | End
  ========================================
  
  ========1:_Toml.Doc.AppendAtPath========
  _Toml.Doc.AppendAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.AppendUpdater)
  ========================================
  0000    | GetConstant 210: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocalMove 0
  0004    | GetBoundLocalMove 1
  0006    | GetBoundLocalMove 2
  0008    | GetConstant 238: _Toml.Doc.AppendUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  ========1:_Toml.Doc.UpdateAtPath========
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
  0000    | PushVar2 Key
  0003    | PushVar2 PathRest
  0006    | PushVar2 InnerDoc
  0009    | SetInputMark
  0010    | GetBoundLocal 1
  0012    | Destructure 65: [Key]
  0014    | ConditionalThen 14 -> 30
  0017    | GetBoundLocalMove 3
  0019    | GetBoundLocalMove 0
  0021    | GetBoundLocalMove 4
  0023    | GetBoundLocalMove 2
  0025    | CallTailFunction 3
  0027    | Jump 27 -> 128
  0030    | SetInputMark
  0031    | GetBoundLocalMove 1
  0033    | Destructure 66: ([Key] + PathRest)
  0035    | ConditionalThen 35 -> 126
  0038    | SetInputMark
  0039    | GetConstant 212: _Toml.Doc.Has
  0041    | GetBoundLocal 0
  0043    | GetBoundLocal 4
  0045    | CallFunction 2
  0047    | ConditionalThen 47 -> 86
  0050    | GetConstant 213: _Toml.Doc.IsTable
  0052    | GetConstant 214: _Toml.Doc.Get
  0054    | GetBoundLocal 0
  0056    | GetBoundLocal 4
  0058    | CallFunction 2
  0060    | CallFunction 1
  0062    | TakeRight 62 -> 83
  0065    | GetConstant 210: _Toml.Doc.UpdateAtPath
  0067    | GetConstant 214: _Toml.Doc.Get
  0069    | GetBoundLocal 0
  0071    | GetBoundLocal 4
  0073    | CallFunction 2
  0075    | GetBoundLocalMove 5
  0077    | GetBoundLocalMove 2
  0079    | GetBoundLocalMove 3
  0081    | CallFunction 4
  0083    | Jump 83 -> 98
  0086    | GetConstant 210: _Toml.Doc.UpdateAtPath
  0088    | CallFunctionConstant 181: _Toml.Doc.Empty
  0090    | GetBoundLocalMove 5
  0092    | GetBoundLocalMove 2
  0094    | GetBoundLocalMove 3
  0096    | CallFunction 4
  0098    | Destructure 67: InnerDoc
  0100    | TakeRight 100 -> 123
  0103    | GetConstant 215: _Toml.Doc.Insert
  0105    | GetBoundLocalMove 0
  0107    | GetBoundLocalMove 4
  0109    | GetConstant 176: _Toml.Doc.Value
  0111    | GetBoundLocal 6
  0113    | CallFunction 1
  0115    | GetConstant 216: _Toml.Doc.Type
  0117    | GetBoundLocalMove 6
  0119    | CallFunction 1
  0121    | CallTailFunction 4
  0123    | Jump 123 -> 128
  0126    | GetBoundLocalMove 0
  0128    | End
  ========================================
  
  ========1:_Toml.Doc.ValueUpdater========
  _Toml.Doc.ValueUpdater(Doc, Key, Val) =
    _Toml.Doc.Has(Doc, Key) ? @Fail : _Toml.Doc.Insert(Doc, Key, Val, "value")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 212: _Toml.Doc.Has
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | ConditionalThen 9 -> 17
  0012    | CallTailFunctionConstant 225: @Fail
  0014    | Jump 14 -> 30
  0017    | GetConstant 215: _Toml.Doc.Insert
  0019    | GetBoundLocalMove 0
  0021    | GetBoundLocalMove 1
  0023    | GetBoundLocalMove 2
  0025    | PushString2 "value"
  0028    | CallTailFunction 4
  0030    | End
  ========================================
  
  ====1:_Toml.Doc.MissingTableUpdater=====
  _Toml.Doc.MissingTableUpdater(Doc, Key, _Val) =
    _Toml.Doc.IsTable(_Toml.Doc.Get(Doc, Key)) ? Doc :
    _Toml.Doc.Insert(Doc, Key, {}, {})
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 213: _Toml.Doc.IsTable
  0003    | GetConstant 214: _Toml.Doc.Get
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | CallFunction 1
  0013    | ConditionalThen 13 -> 21
  0016    | GetBoundLocalMove 0
  0018    | Jump 18 -> 31
  0021    | GetConstant 215: _Toml.Doc.Insert
  0023    | GetBoundLocalMove 0
  0025    | GetBoundLocalMove 1
  0027    | PushEmptyObject
  0028    | PushEmptyObject
  0029    | CallTailFunction 4
  0031    | End
  ========================================
  
  =======1:_Toml.Doc.AppendUpdater========
  _Toml.Doc.AppendUpdater(Doc, Key, Val) =
    (
      _Toml.Doc.Has(Doc, Key) ? Doc :
      _Toml.Doc.Insert(Doc, Key, [], "array_of_tables")
    ) -> DocWithKey &
    _Toml.Doc.AppendToArrayOfTables(DocWithKey, Key, Val)
  ========================================
  0000    | PushVar2 DocWithKey
  0003    | SetInputMark
  0004    | GetConstant 212: _Toml.Doc.Has
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 1
  0010    | CallFunction 2
  0012    | ConditionalThen 12 -> 20
  0015    | GetBoundLocalMove 0
  0017    | Jump 17 -> 32
  0020    | GetConstant 215: _Toml.Doc.Insert
  0022    | GetBoundLocalMove 0
  0024    | GetBoundLocal 1
  0026    | PushEmptyArray
  0027    | PushString2 "array_of_tables"
  0030    | CallFunction 4
  0032    | Destructure 75: DocWithKey
  0034    | TakeRight 34 -> 47
  0037    | GetConstant 239: _Toml.Doc.AppendToArrayOfTables
  0039    | GetBoundLocalMove 3
  0041    | GetBoundLocalMove 1
  0043    | GetBoundLocalMove 2
  0045    | CallTailFunction 3
  0047    | End
  ========================================
  
  =====1:ast.with_operator_precedence=====
  ast.with_operator_precedence(operand, prefix, infix, postfix) =
    _ast.with_precedence_start(operand, prefix, infix, postfix, $0)
  ========================================
  0000    | GetConstant2 325: _ast.with_precedence_start
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | GetBoundLocalMove 2
  0009    | GetBoundLocalMove 3
  0011    | PushInteger 0
  0013    | CallTailFunction 5
  0015    | End
  ========================================
  
  ======1:_ast.with_precedence_start======
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
  0000    | PushVar2 PrefixBindingPower
  0003    | PushVar2 PrefixNode
  0006    | PushVar2 Node
  0009    | SetInputMark
  0010    | CallFunctionLocal 1
  0012    | Destructure 87: ({"power": PrefixBindingPower} + PrefixNode)
  0014    | ConditionalThen 14 -> 89
  0017    | GetConstant2 325: _ast.with_precedence_start
  0020    | GetBoundLocal 0
  0022    | GetBoundLocal 1
  0024    | GetBoundLocal 2
  0026    | GetBoundLocal 3
  0028    | GetBoundLocalMove 5
  0030    | CallFunction 5
  0032    | Destructure 88: Node
  0034    | TakeRight 34 -> 86
  0037    | GetConstant2 326: _ast.with_precedence_rest
  0040    | GetBoundLocalMove 0
  0042    | GetBoundLocalMove 1
  0044    | GetBoundLocalMove 2
  0046    | GetBoundLocalMove 3
  0048    | GetBoundLocalMove 4
  0050    | PushEmptyObject
  0051    | JumpIfFailure 51 -> 57
  0054    | GetBoundLocal 6
  0056    | Merge
  0057    | JumpIfFailure 57 -> 84
  0060    | GetConstantMutable2 327: {_0_}
  0063    | PushString2 "prefixed"
  0066    | GetBoundLocal 7
  0068    | InsertKeyVal 0
  0070    | JumpIfFailure 70 -> 83
  0073    | GetConstant2 328: _Ast.MergePos
  0076    | GetBoundLocalMove 6
  0078    | GetBoundLocalMove 7
  0080    | CallFunction 2
  0082    | Merge
  0083    | Merge
  0084    | CallTailFunction 6
  0086    | Jump 86 -> 113
  0089    | CallFunctionLocal 0
  0091    | Destructure 89: Node
  0093    | TakeRight 93 -> 113
  0096    | GetConstant2 326: _ast.with_precedence_rest
  0099    | GetBoundLocalMove 0
  0101    | GetBoundLocalMove 1
  0103    | GetBoundLocalMove 2
  0105    | GetBoundLocalMove 3
  0107    | GetBoundLocalMove 4
  0109    | GetBoundLocalMove 7
  0111    | CallTailFunction 6
  0113    | End
  ========================================
  
  ======1:_ast.with_precedence_rest=======
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
  0000    | PushVar2 RightBindingPower
  0003    | PushVar2 PostfixNode
  0006    | PushVar2 NextLeftBindingPower
  0009    | PushVar2 InfixNode
  0012    | PushVar2 RightNode
  0015    | SetInputMark
  0016    | CallFunctionLocal 3
  0018    | Destructure 90: ({"power": RightBindingPower} + PostfixNode)
  0020    | TakeRight 20 -> 36
  0023    | GetConstant 31: const
  0025    | GetConstant2 329: Is.LessThan
  0028    | GetBoundLocal 4
  0030    | GetBoundLocal 6
  0032    | CallFunction 2
  0034    | CallFunction 1
  0036    | ConditionalThen 36 -> 91
  0039    | GetConstant2 326: _ast.with_precedence_rest
  0042    | GetBoundLocalMove 0
  0044    | GetBoundLocalMove 1
  0046    | GetBoundLocalMove 2
  0048    | GetBoundLocalMove 3
  0050    | GetBoundLocalMove 4
  0052    | PushEmptyObject
  0053    | JumpIfFailure 53 -> 59
  0056    | GetBoundLocal 7
  0058    | Merge
  0059    | JumpIfFailure 59 -> 86
  0062    | GetConstantMutable2 330: {_0_}
  0065    | PushString2 "postfixed"
  0068    | GetBoundLocal 5
  0070    | InsertKeyVal 0
  0072    | JumpIfFailure 72 -> 85
  0075    | GetConstant2 328: _Ast.MergePos
  0078    | GetBoundLocalMove 5
  0080    | GetBoundLocalMove 7
  0082    | CallFunction 2
  0084    | Merge
  0085    | Merge
  0086    | CallTailFunction 6
  0088    | Jump 88 -> 200
  0091    | SetInputMark
  0092    | CallFunctionLocal 2
  0094    | Destructure 91: ({"power": [RightBindingPower, NextLeftBindingPower]} + InfixNode)
  0096    | TakeRight 96 -> 112
  0099    | GetConstant 31: const
  0101    | GetConstant2 329: Is.LessThan
  0104    | GetBoundLocal 4
  0106    | GetBoundLocalMove 6
  0108    | CallFunction 2
  0110    | CallFunction 1
  0112    | ConditionalThen 112 -> 194
  0115    | GetConstant2 325: _ast.with_precedence_start
  0118    | GetBoundLocal 0
  0120    | GetBoundLocal 1
  0122    | GetBoundLocal 2
  0124    | GetBoundLocal 3
  0126    | GetBoundLocalMove 8
  0128    | CallFunction 5
  0130    | Destructure 92: RightNode
  0132    | TakeRight 132 -> 191
  0135    | GetConstant2 326: _ast.with_precedence_rest
  0138    | GetBoundLocalMove 0
  0140    | GetBoundLocalMove 1
  0142    | GetBoundLocalMove 2
  0144    | GetBoundLocalMove 3
  0146    | GetBoundLocalMove 4
  0148    | PushEmptyObject
  0149    | JumpIfFailure 149 -> 155
  0152    | GetBoundLocalMove 9
  0154    | Merge
  0155    | JumpIfFailure 155 -> 189
  0158    | GetConstantMutable2 331: {_0_, _1_}
  0161    | PushString2 "left"
  0164    | GetBoundLocal 5
  0166    | InsertKeyVal 0
  0168    | PushString2 "right"
  0171    | GetBoundLocal 10
  0173    | InsertKeyVal 1
  0175    | JumpIfFailure 175 -> 188
  0178    | GetConstant2 328: _Ast.MergePos
  0181    | GetBoundLocalMove 5
  0183    | GetBoundLocalMove 10
  0185    | CallFunction 2
  0187    | Merge
  0188    | Merge
  0189    | CallTailFunction 6
  0191    | Jump 191 -> 200
  0194    | GetConstant 31: const
  0196    | GetBoundLocalMove 5
  0198    | CallTailFunction 1
  0200    | End
  ========================================
  
  ===============1:ast.node===============
  ast.node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | PushVar2 Value
  0003    | CallFunctionLocal 0
  0005    | Destructure 97: Value
  0007    | TakeRight 7 -> 27
  0010    | GetConstantMutable2 334: {_0_, _1_}
  0013    | PushString2 "type"
  0016    | GetBoundLocalMove 1
  0018    | InsertKeyVal 0
  0020    | PushString2 "value"
  0023    | GetBoundLocalMove 2
  0025    | InsertKeyVal 1
  0027    | End
  ========================================
  
  ===========1:ast.prefix_node============
  ast.prefix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 22
  0005    | GetConstantMutable2 335: {_0_, _1_}
  0008    | PushString2 "type"
  0011    | GetBoundLocalMove 1
  0013    | InsertKeyVal 0
  0015    | PushString2 "power"
  0018    | GetBoundLocalMove 2
  0020    | InsertKeyVal 1
  0022    | End
  ========================================
  
  ============1:ast.infix_node============
  ast.infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    op $ {"type": Type, "power": [LeftBindingPower, RightBindingPower]}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 31
  0005    | GetConstantMutable2 336: {_0_, _1_}
  0008    | PushString2 "type"
  0011    | GetBoundLocalMove 1
  0013    | InsertKeyVal 0
  0015    | PushString2 "power"
  0018    | GetConstantMutable2 337: [_, _]
  0021    | GetBoundLocalMove 2
  0023    | InsertAtIndex 0
  0025    | GetBoundLocalMove 3
  0027    | InsertAtIndex 1
  0029    | InsertKeyVal 1
  0031    | End
  ========================================
  
  ===========1:ast.postfix_node===========
  ast.postfix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 22
  0005    | GetConstantMutable2 338: {_0_, _1_}
  0008    | PushString2 "type"
  0011    | GetBoundLocalMove 1
  0013    | InsertKeyVal 0
  0015    | PushString2 "power"
  0018    | GetBoundLocalMove 2
  0020    | InsertKeyVal 1
  0022    | End
  ========================================
  
  =========1:ast.with_offset_pos==========
  ast.with_offset_pos(node) =
    @input.offset -> StartOffset &
    node -> Node &
    @input.offset -> EndOffset $
    {...Node, "startpos": StartOffset, "endpos": EndOffset}
  ========================================
  0000    | PushVar2 StartOffset
  0003    | PushVar2 Node
  0006    | PushVar2 EndOffset
  0009    | CallFunctionConstant 27: @input.offset
  0011    | Destructure 98: StartOffset
  0013    | TakeRight 13 -> 20
  0016    | CallFunctionLocal 0
  0018    | Destructure 99: Node
  0020    | TakeRight 20 -> 58
  0023    | CallFunctionConstant 27: @input.offset
  0025    | Destructure 100: EndOffset
  0027    | TakeRight 27 -> 58
  0030    | PushEmptyObject
  0031    | JumpIfFailure 31 -> 37
  0034    | GetBoundLocalMove 2
  0036    | Merge
  0037    | JumpIfFailure 37 -> 58
  0040    | GetConstantMutable2 339: {_0_, _1_}
  0043    | PushString2 "startpos"
  0046    | GetBoundLocalMove 1
  0048    | InsertKeyVal 0
  0050    | PushString2 "endpos"
  0053    | GetBoundLocalMove 3
  0055    | InsertKeyVal 1
  0057    | Merge
  0058    | End
  ========================================
  
  ==========1:ast.with_line_pos===========
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
  0000    | PushVar2 StartLine
  0003    | PushVar2 StartLineOffset
  0006    | PushVar2 Node
  0009    | PushVar2 EndLine
  0012    | PushVar2 EndLineOffset
  0015    | CallFunctionConstant2 340: @input.line
  0018    | Destructure 101: StartLine
  0020    | TakeRight 20 -> 28
  0023    | CallFunctionConstant2 341: @input.line_offset
  0026    | Destructure 102: StartLineOffset
  0028    | TakeRight 28 -> 35
  0031    | CallFunctionLocal 0
  0033    | Destructure 103: Node
  0035    | TakeRight 35 -> 43
  0038    | CallFunctionConstant2 340: @input.line
  0041    | Destructure 104: EndLine
  0043    | TakeRight 43 -> 112
  0046    | CallFunctionConstant2 341: @input.line_offset
  0049    | Destructure 105: EndLineOffset
  0051    | TakeRight 51 -> 112
  0054    | PushEmptyObject
  0055    | JumpIfFailure 55 -> 61
  0058    | GetBoundLocalMove 3
  0060    | Merge
  0061    | JumpIfFailure 61 -> 112
  0064    | GetConstantMutable2 342: {_0_, _1_}
  0067    | PushString2 "startpos"
  0070    | GetConstantMutable2 343: {_0_, _1_}
  0073    | PushString2 "line"
  0076    | GetBoundLocalMove 1
  0078    | InsertKeyVal 0
  0080    | PushString2 "offset"
  0083    | GetBoundLocalMove 2
  0085    | InsertKeyVal 1
  0087    | InsertKeyVal 0
  0089    | PushString2 "endpos"
  0092    | GetConstantMutable2 344: {_0_, _1_}
  0095    | PushString2 "line"
  0098    | GetBoundLocalMove 4
  0100    | InsertKeyVal 0
  0102    | PushString2 "offset"
  0105    | GetBoundLocalMove 5
  0107    | InsertKeyVal 1
  0109    | InsertKeyVal 1
  0111    | Merge
  0112    | End
  ========================================
  
  ==============1:Str.Length==============
  Str.Length(S) = S -> ("\u000000".. * L) $ L
  ========================================
  0000    | PushVar2 L
  0003    | GetBoundLocalMove 0
  0005    | Destructure 106: ("\x00".. * L) (esc)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 1
  0012    | End
  ========================================
  
  =================0:@Add=================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 10: addNative
  0006    | End
  ========================================
  
  ==============0:@Subtract===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 21: subtractNative
  0006    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 6: multiplyNative
  0006    | End
  ========================================
  
  ===============0:@Divide================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 23: divideNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 8: powerNative
  0006    | End
  ========================================
  
  ===============0:@Modulus===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 25: modulusNative
  0006    | End
  ========================================
  
  ================0:@Floor================
  0000    | GetLocal 0
  0002    | NativeCode 27: floorNative
  0004    | End
  ========================================
  
  ===============0:@Ceiling===============
  0000    | GetLocal 0
  0002    | NativeCode 29: ceilingNative
  0004    | End
  ========================================
  
  ===============1:Num.Inc================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant 86: @Add
  0002    | GetBoundLocalMove 0
  0004    | PushInteger 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============1:Num.Dec================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant2 345: @Subtract
  0003    | GetBoundLocalMove 0
  0005    | PushInteger 1
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ===============1:Num.Abs================
  Num.Abs(N) = N -> 0.. | -N
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 107: 0..
  0005    | Or 5 -> 11
  0008    | GetBoundLocalMove 0
  0010    | NegateNumber
  0011    | End
  ========================================
  
  ===============1:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 28: B..
  0005    | ConditionalThen 5 -> 13
  0008    | GetBoundLocalMove 0
  0010    | Jump 10 -> 15
  0013    | GetBoundLocalMove 1
  0015    | End
  ========================================
  
  ===============1:Num.Min================
  Num.Min(A, B) = A -> ..B ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 108: ..B
  0005    | ConditionalThen 5 -> 13
  0008    | GetBoundLocalMove 0
  0010    | Jump 10 -> 15
  0013    | GetBoundLocalMove 1
  0015    | End
  ========================================
  
  =========1:Num.FromBinaryDigits=========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | GetConstant 53: Array.Length
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | Destructure 4: Len
  0011    | TakeRight 11 -> 30
  0014    | GetConstant 54: _Num.FromBinaryDigits
  0016    | GetBoundLocalMove 0
  0018    | GetBoundLocalMove 1
  0020    | JumpIfFailure 20 -> 26
  0023    | PushNegInteger -1
  0025    | Merge
  0026    | PushInteger 0
  0028    | CallTailFunction 3
  0030    | End
  ========================================
  
  ========1:_Num.FromBinaryDigits=========
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
  0007    | GetBoundLocalMove 0
  0009    | Destructure 6: ([B] + Rest)
  0011    | ConditionalThen 11 -> 58
  0014    | GetBoundLocal 3
  0016    | Destructure 7: 0..1
  0018    | TakeRight 18 -> 55
  0021    | GetConstant 54: _Num.FromBinaryDigits
  0023    | GetBoundLocalMove 4
  0025    | GetBoundLocal 1
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -1
  0032    | Merge
  0033    | GetBoundLocalMove 2
  0035    | JumpIfFailure 35 -> 53
  0038    | GetConstant 55: @Multiply
  0040    | GetBoundLocalMove 3
  0042    | GetConstant 56: @Power
  0044    | PushInteger 2
  0046    | GetBoundLocalMove 1
  0048    | CallFunction 2
  0050    | CallFunction 2
  0052    | Merge
  0053    | CallTailFunction 3
  0055    | Jump 55 -> 60
  0058    | GetBoundLocalMove 2
  0060    | End
  ========================================
  
  =========1:Num.FromOctalDigits==========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | GetConstant 53: Array.Length
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | Destructure 9: Len
  0011    | TakeRight 11 -> 30
  0014    | GetConstant 59: _Num.FromOctalDigits
  0016    | GetBoundLocalMove 0
  0018    | GetBoundLocalMove 1
  0020    | JumpIfFailure 20 -> 26
  0023    | PushNegInteger -1
  0025    | Merge
  0026    | PushInteger 0
  0028    | CallTailFunction 3
  0030    | End
  ========================================
  
  =========1:_Num.FromOctalDigits=========
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
  0007    | GetBoundLocalMove 0
  0009    | Destructure 10: ([O] + Rest)
  0011    | ConditionalThen 11 -> 58
  0014    | GetBoundLocal 3
  0016    | Destructure 11: 0..7
  0018    | TakeRight 18 -> 55
  0021    | GetConstant 59: _Num.FromOctalDigits
  0023    | GetBoundLocalMove 4
  0025    | GetBoundLocal 1
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -1
  0032    | Merge
  0033    | GetBoundLocalMove 2
  0035    | JumpIfFailure 35 -> 53
  0038    | GetConstant 55: @Multiply
  0040    | GetBoundLocalMove 3
  0042    | GetConstant 56: @Power
  0044    | PushInteger 8
  0046    | GetBoundLocalMove 1
  0048    | CallFunction 2
  0050    | CallFunction 2
  0052    | Merge
  0053    | CallTailFunction 3
  0055    | Jump 55 -> 60
  0058    | GetBoundLocalMove 2
  0060    | End
  ========================================
  
  ==========1:Num.FromHexDigits===========
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | GetConstant 53: Array.Length
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | Destructure 13: Len
  0011    | TakeRight 11 -> 30
  0014    | GetConstant 62: _Num.FromHexDigits
  0016    | GetBoundLocalMove 0
  0018    | GetBoundLocalMove 1
  0020    | JumpIfFailure 20 -> 26
  0023    | PushNegInteger -1
  0025    | Merge
  0026    | PushInteger 0
  0028    | CallTailFunction 3
  0030    | End
  ========================================
  
  ==========1:_Num.FromHexDigits==========
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
  0007    | GetBoundLocalMove 0
  0009    | Destructure 14: ([H] + Rest)
  0011    | ConditionalThen 11 -> 58
  0014    | GetBoundLocal 3
  0016    | Destructure 15: 0..15
  0018    | TakeRight 18 -> 55
  0021    | GetConstant 62: _Num.FromHexDigits
  0023    | GetBoundLocalMove 4
  0025    | GetBoundLocal 1
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -1
  0032    | Merge
  0033    | GetBoundLocalMove 2
  0035    | JumpIfFailure 35 -> 53
  0038    | GetConstant 55: @Multiply
  0040    | GetBoundLocalMove 3
  0042    | GetConstant 56: @Power
  0044    | PushInteger 16
  0046    | GetBoundLocalMove 1
  0048    | CallFunction 2
  0050    | CallFunction 2
  0052    | Merge
  0053    | CallTailFunction 3
  0055    | Jump 55 -> 60
  0058    | GetBoundLocalMove 2
  0060    | End
  ========================================
  
  =============1:Array.First==============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushVar F
  0002    | PushUnderscoreVar
  0003    | GetBoundLocalMove 0
  0005    | Destructure 109: ([F] + _)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 1
  0012    | End
  ========================================
  
  ==============1:Array.Rest==============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar2 R
  0004    | GetBoundLocalMove 0
  0006    | Destructure 110: ([_] + R)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocalMove 2
  0013    | End
  ========================================
  
  =============1:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar2 L
  0004    | GetBoundLocalMove 0
  0006    | Destructure 5: ([_] * L)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocalMove 2
  0013    | End
  ========================================
  
  ============1:Array.Reverse=============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant2 346: _Array.Reverse
  0003    | GetBoundLocalMove 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============1:_Array.Reverse============
  _Array.Reverse(A, Acc) =
    A -> [First, ...Rest] ? _Array.Reverse(Rest, [First, ...Acc]) : Acc
  ========================================
  0000    | PushVar2 First
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 0
  0009    | Destructure 111: ([First] + Rest)
  0011    | ConditionalThen 11 -> 37
  0014    | GetConstant2 346: _Array.Reverse
  0017    | GetBoundLocalMove 3
  0019    | GetConstantMutable2 347: [_]
  0022    | GetBoundLocalMove 2
  0024    | InsertAtIndex 0
  0026    | JumpIfFailure 26 -> 32
  0029    | GetBoundLocalMove 1
  0031    | Merge
  0032    | CallTailFunction 2
  0034    | Jump 34 -> 39
  0037    | GetBoundLocalMove 1
  0039    | End
  ========================================
  
  ==============1:Array.Map===============
  Array.Map(A, Fn) = _Array.Map(A, Fn, [])
  ========================================
  0000    | GetConstant2 348: _Array.Map
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==============1:_Array.Map==============
  _Array.Map(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.Map(Rest, Fn, [...Acc, Fn(First)]) : Acc
  ========================================
  0000    | PushVar2 First
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 0
  0009    | Destructure 112: ([First] + Rest)
  0011    | ConditionalThen 11 -> 48
  0014    | GetConstant2 348: _Array.Map
  0017    | GetBoundLocalMove 4
  0019    | GetBoundLocal 1
  0021    | PushEmptyArray
  0022    | JumpIfFailure 22 -> 28
  0025    | GetBoundLocalMove 2
  0027    | Merge
  0028    | JumpIfFailure 28 -> 43
  0031    | GetConstantMutable2 349: [_]
  0034    | GetBoundLocalMove 1
  0036    | GetBoundLocalMove 3
  0038    | CallFunction 1
  0040    | InsertAtIndex 0
  0042    | Merge
  0043    | CallTailFunction 3
  0045    | Jump 45 -> 50
  0048    | GetBoundLocalMove 2
  0050    | End
  ========================================
  
  =============1:Array.Filter=============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant2 350: _Array.Filter
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============1:_Array.Filter=============
  _Array.Filter(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Filter(Rest, Pred, Pred(First) ? [...Acc, First] : Acc) :
    Acc
  ========================================
  0000    | PushVar2 First
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 0
  0009    | Destructure 113: ([First] + Rest)
  0011    | ConditionalThen 11 -> 59
  0014    | GetConstant2 350: _Array.Filter
  0017    | GetBoundLocalMove 4
  0019    | GetBoundLocal 1
  0021    | SetInputMark
  0022    | GetBoundLocalMove 1
  0024    | GetBoundLocal 3
  0026    | CallFunction 1
  0028    | ConditionalThen 28 -> 52
  0031    | PushEmptyArray
  0032    | JumpIfFailure 32 -> 38
  0035    | GetBoundLocalMove 2
  0037    | Merge
  0038    | JumpIfFailure 38 -> 49
  0041    | GetConstantMutable2 351: [_]
  0044    | GetBoundLocalMove 3
  0046    | InsertAtIndex 0
  0048    | Merge
  0049    | Jump 49 -> 54
  0052    | GetBoundLocalMove 2
  0054    | CallTailFunction 3
  0056    | Jump 56 -> 61
  0059    | GetBoundLocalMove 2
  0061    | End
  ========================================
  
  =============1:Array.Reject=============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant2 352: _Array.Reject
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============1:_Array.Reject=============
  _Array.Reject(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reject(Rest, Pred, Pred(First) ? Acc : [...Acc, First]) :
    Acc
  ========================================
  0000    | PushVar2 First
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 0
  0009    | Destructure 114: ([First] + Rest)
  0011    | ConditionalThen 11 -> 59
  0014    | GetConstant2 352: _Array.Reject
  0017    | GetBoundLocalMove 4
  0019    | GetBoundLocal 1
  0021    | SetInputMark
  0022    | GetBoundLocalMove 1
  0024    | GetBoundLocal 3
  0026    | CallFunction 1
  0028    | ConditionalThen 28 -> 36
  0031    | GetBoundLocalMove 2
  0033    | Jump 33 -> 54
  0036    | PushEmptyArray
  0037    | JumpIfFailure 37 -> 43
  0040    | GetBoundLocalMove 2
  0042    | Merge
  0043    | JumpIfFailure 43 -> 54
  0046    | GetConstantMutable2 353: [_]
  0049    | GetBoundLocalMove 3
  0051    | InsertAtIndex 0
  0053    | Merge
  0054    | CallTailFunction 3
  0056    | Jump 56 -> 61
  0059    | GetBoundLocalMove 2
  0061    | End
  ========================================
  
  =============1:Array.Merge==============
  Array.Merge(A) = _Array.Merge(A, null)
  ========================================
  0000    | GetConstant2 354: _Array.Merge
  0003    | GetBoundLocalMove 0
  0005    | PushNull
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============1:_Array.Merge=============
  _Array.Merge(A, Acc) =
    A -> [First, ...Rest] ? _Array.Merge(Rest, Acc + First) : Acc
  ========================================
  0000    | PushVar2 First
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 0
  0009    | Destructure 115: ([First] + Rest)
  0011    | ConditionalThen 11 -> 32
  0014    | GetConstant2 354: _Array.Merge
  0017    | GetBoundLocalMove 3
  0019    | GetBoundLocalMove 1
  0021    | JumpIfFailure 21 -> 27
  0024    | GetBoundLocalMove 2
  0026    | Merge
  0027    | CallTailFunction 2
  0029    | Jump 29 -> 34
  0032    | GetBoundLocalMove 1
  0034    | End
  ========================================
  
  ============1:Array.MapMerge============
  Array.MapMerge(A, Fn) = _Array.MapMerge(A, Fn, null)
  ========================================
  0000    | GetConstant2 355: _Array.MapMerge
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushNull
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===========1:_Array.MapMerge============
  _Array.MapMerge(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.MapMerge(Rest, Fn, Acc + Fn(First)) : Acc
  ========================================
  0000    | PushVar2 First
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 0
  0009    | Destructure 116: ([First] + Rest)
  0011    | ConditionalThen 11 -> 38
  0014    | GetConstant2 355: _Array.MapMerge
  0017    | GetBoundLocalMove 4
  0019    | GetBoundLocal 1
  0021    | GetBoundLocalMove 2
  0023    | JumpIfFailure 23 -> 33
  0026    | GetBoundLocalMove 1
  0028    | GetBoundLocalMove 3
  0030    | CallFunction 1
  0032    | Merge
  0033    | CallTailFunction 3
  0035    | Jump 35 -> 40
  0038    | GetBoundLocalMove 2
  0040    | End
  ========================================
  
  =============1:Array.Reduce=============
  Array.Reduce(A, Fn, Acc) =
    A -> [First, ...Rest] ? Array.Reduce(Rest, Fn, Fn(Acc, First)) : Acc
  ========================================
  0000    | PushVar2 First
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 0
  0009    | Destructure 117: ([First] + Rest)
  0011    | ConditionalThen 11 -> 34
  0014    | GetConstant2 356: Array.Reduce
  0017    | GetBoundLocalMove 4
  0019    | GetBoundLocal 1
  0021    | GetBoundLocalMove 1
  0023    | GetBoundLocalMove 2
  0025    | GetBoundLocalMove 3
  0027    | CallFunction 2
  0029    | CallTailFunction 3
  0031    | Jump 31 -> 36
  0034    | GetBoundLocalMove 2
  0036    | End
  ========================================
  
  ===========1:Array.ZipObject============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant2 357: _Array.ZipObject
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushEmptyObject
  0008    | CallTailFunction 3
  0010    | End
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
  0013    | GetBoundLocalMove 0
  0015    | Destructure 118: ([K] + KsRest)
  0017    | TakeRight 17 -> 24
  0020    | GetBoundLocalMove 1
  0022    | Destructure 119: ([V] + VsRest)
  0024    | ConditionalThen 24 -> 59
  0027    | GetConstant2 357: _Array.ZipObject
  0030    | GetBoundLocalMove 4
  0032    | GetBoundLocalMove 6
  0034    | PushEmptyObject
  0035    | JumpIfFailure 35 -> 41
  0038    | GetBoundLocalMove 2
  0040    | Merge
  0041    | JumpIfFailure 41 -> 54
  0044    | GetConstantMutable2 358: {_0_}
  0047    | GetBoundLocalMove 3
  0049    | GetBoundLocalMove 5
  0051    | InsertKeyVal 0
  0053    | Merge
  0054    | CallTailFunction 3
  0056    | Jump 56 -> 61
  0059    | GetBoundLocalMove 2
  0061    | End
  ========================================
  
  ============1:Array.ZipPairs============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant2 359: _Array.ZipPairs
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
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
  0013    | GetBoundLocalMove 0
  0015    | Destructure 120: ([First1] + Rest1)
  0017    | TakeRight 17 -> 24
  0020    | GetBoundLocalMove 1
  0022    | Destructure 121: ([First2] + Rest2)
  0024    | ConditionalThen 24 -> 66
  0027    | GetConstant2 359: _Array.ZipPairs
  0030    | GetBoundLocalMove 4
  0032    | GetBoundLocalMove 6
  0034    | PushEmptyArray
  0035    | JumpIfFailure 35 -> 41
  0038    | GetBoundLocalMove 2
  0040    | Merge
  0041    | JumpIfFailure 41 -> 61
  0044    | GetConstantMutable2 360: [_]
  0047    | GetConstantMutable2 361: [_, _]
  0050    | GetBoundLocalMove 3
  0052    | InsertAtIndex 0
  0054    | GetBoundLocalMove 5
  0056    | InsertAtIndex 1
  0058    | InsertAtIndex 0
  0060    | Merge
  0061    | CallTailFunction 3
  0063    | Jump 63 -> 68
  0066    | GetBoundLocalMove 2
  0068    | End
  ========================================
  
  ============1:Array.AppendN=============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstantMutable 92: [_]
  0007    | GetBoundLocalMove 1
  0009    | InsertAtIndex 0
  0011    | GetBoundLocalMove 2
  0013    | RepeatValue
  0014    | Merge
  0015    | End
  ========================================
  
  ===========1:Table.Transpose============
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant 95: _Table.Transpose
  0002    | GetBoundLocalMove 0
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
  0007    | GetConstant 96: _Table.FirstPerRow
  0009    | GetBoundLocal 0
  0011    | CallFunction 1
  0013    | Destructure 32: FirstPerRow
  0015    | TakeRight 15 -> 26
  0018    | GetConstant 97: _Table.RestPerRow
  0020    | GetBoundLocalMove 0
  0022    | CallFunction 1
  0024    | Destructure 33: RestPerRow
  0026    | ConditionalThen 26 -> 55
  0029    | GetConstant 95: _Table.Transpose
  0031    | GetBoundLocalMove 3
  0033    | PushEmptyArray
  0034    | JumpIfFailure 34 -> 40
  0037    | GetBoundLocalMove 1
  0039    | Merge
  0040    | JumpIfFailure 40 -> 50
  0043    | GetConstantMutable 98: [_]
  0045    | GetBoundLocalMove 2
  0047    | InsertAtIndex 0
  0049    | Merge
  0050    | CallTailFunction 2
  0052    | Jump 52 -> 57
  0055    | GetBoundLocalMove 1
  0057    | End
  ========================================
  
  ==========1:_Table.FirstPerRow==========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | PushVar2 VeryFirst
  0009    | PushUnderscoreVar
  0010    | GetBoundLocalMove 0
  0012    | Destructure 34: ([Row] + Rest)
  0014    | TakeRight 14 -> 21
  0017    | GetBoundLocalMove 1
  0019    | Destructure 35: ([VeryFirst] + _)
  0021    | TakeRight 21 -> 36
  0024    | GetConstant 99: __Table.FirstPerRow
  0026    | GetBoundLocalMove 2
  0028    | GetConstantMutable 100: [_]
  0030    | GetBoundLocalMove 3
  0032    | InsertAtIndex 0
  0034    | CallTailFunction 2
  0036    | End
  ========================================
  
  =========1:__Table.FirstPerRow==========
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
  0011    | GetBoundLocalMove 0
  0013    | Destructure 36: ([Row] + Rest)
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocalMove 2
  0020    | Destructure 37: ([First] + _)
  0022    | ConditionalThen 22 -> 51
  0025    | GetConstant 99: __Table.FirstPerRow
  0027    | GetBoundLocalMove 3
  0029    | PushEmptyArray
  0030    | JumpIfFailure 30 -> 36
  0033    | GetBoundLocalMove 1
  0035    | Merge
  0036    | JumpIfFailure 36 -> 46
  0039    | GetConstantMutable 101: [_]
  0041    | GetBoundLocalMove 4
  0043    | InsertAtIndex 0
  0045    | Merge
  0046    | CallTailFunction 2
  0048    | Jump 48 -> 53
  0051    | GetBoundLocalMove 1
  0053    | End
  ========================================
  
  ==========1:_Table.RestPerRow===========
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant 102: __Table.RestPerRow
  0002    | GetBoundLocalMove 0
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
  0003    | PushVar2 Rest
  0006    | PushUnderscoreVar
  0007    | PushVar2 RowRest
  0010    | SetInputMark
  0011    | GetBoundLocalMove 0
  0013    | Destructure 38: ([Row] + Rest)
  0015    | ConditionalThen 15 -> 74
  0018    | SetInputMark
  0019    | GetBoundLocalMove 2
  0021    | Destructure 39: ([_] + RowRest)
  0023    | ConditionalThen 23 -> 52
  0026    | GetConstant 102: __Table.RestPerRow
  0028    | GetBoundLocalMove 3
  0030    | PushEmptyArray
  0031    | JumpIfFailure 31 -> 37
  0034    | GetBoundLocalMove 1
  0036    | Merge
  0037    | JumpIfFailure 37 -> 47
  0040    | GetConstantMutable 103: [_]
  0042    | GetBoundLocalMove 5
  0044    | InsertAtIndex 0
  0046    | Merge
  0047    | CallTailFunction 2
  0049    | Jump 49 -> 71
  0052    | GetConstant 102: __Table.RestPerRow
  0054    | GetBoundLocalMove 3
  0056    | PushEmptyArray
  0057    | JumpIfFailure 57 -> 63
  0060    | GetBoundLocalMove 1
  0062    | Merge
  0063    | JumpIfFailure 63 -> 69
  0066    | GetConstant 104: [[]]
  0068    | Merge
  0069    | CallTailFunction 2
  0071    | Jump 71 -> 76
  0074    | GetBoundLocalMove 1
  0076    | End
  ========================================
  
  ========1:Table.RotateClockwise=========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant2 362: Array.Map
  0003    | GetConstant 94: Table.Transpose
  0005    | GetBoundLocalMove 0
  0007    | CallFunction 1
  0009    | GetConstant2 363: Array.Reverse
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =====1:Table.RotateCounterClockwise=====
  Table.RotateCounterClockwise(T) = Array.Reverse(Table.Transpose(T))
  ========================================
  0000    | GetConstant2 363: Array.Reverse
  0003    | GetConstant 94: Table.Transpose
  0005    | GetBoundLocalMove 0
  0007    | CallFunction 1
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  ===========1:Table.ZipObjects===========
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant2 364: _Table.ZipObjects
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==========1:_Table.ZipObjects===========
  _Table.ZipObjects(Ks, Rows, Acc) =
    Rows -> [Row, ...Rest] ?
    _Table.ZipObjects(Ks, Rest, [...Acc, Array.ZipObject(Ks, Row)]) :
    Acc
  ========================================
  0000    | PushVar2 Row
  0003    | PushVar2 Rest
  0006    | SetInputMark
  0007    | GetBoundLocalMove 1
  0009    | Destructure 122: ([Row] + Rest)
  0011    | ConditionalThen 11 -> 51
  0014    | GetConstant2 364: _Table.ZipObjects
  0017    | GetBoundLocal 0
  0019    | GetBoundLocalMove 4
  0021    | PushEmptyArray
  0022    | JumpIfFailure 22 -> 28
  0025    | GetBoundLocalMove 2
  0027    | Merge
  0028    | JumpIfFailure 28 -> 46
  0031    | GetConstantMutable2 365: [_]
  0034    | GetConstant2 366: Array.ZipObject
  0037    | GetBoundLocalMove 0
  0039    | GetBoundLocalMove 3
  0041    | CallFunction 2
  0043    | InsertAtIndex 0
  0045    | Merge
  0046    | CallTailFunction 3
  0048    | Jump 48 -> 53
  0051    | GetBoundLocalMove 2
  0053    | End
  ========================================
  
  ===============1:Obj.Has================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 68: ({K: _} + _)
  0005    | End
  ========================================
  
  ===============1:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar2 V
  0003    | PushUnderscoreVar
  0004    | GetBoundLocalMove 0
  0006    | Destructure 69: ({K: V} + _)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocalMove 2
  0013    | End
  ========================================
  
  ===============1:Obj.Put================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | JumpIfFailure 1 -> 7
  0004    | GetBoundLocalMove 0
  0006    | Merge
  0007    | JumpIfFailure 7 -> 19
  0010    | GetConstantMutable 224: {_0_}
  0012    | GetBoundLocalMove 1
  0014    | GetBoundLocalMove 2
  0016    | InsertKeyVal 0
  0018    | Merge
  0019    | End
  ========================================
  
  ===============1:Obj.Size===============
  Obj.Size(O) = _Obj.Size(O, 0)
  ========================================
  0000    | GetConstant2 367: _Obj.Size
  0003    | GetBoundLocalMove 0
  0005    | PushInteger 0
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ==============1:_Obj.Size===============
  _Obj.Size(O, Acc) = O -> {_: _, ...Rest} ? _Obj.Size(Rest, Acc + 1) : Acc
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar2 Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 123: ({_: _} + Rest)
  0009    | ConditionalThen 9 -> 30
  0012    | GetConstant2 367: _Obj.Size
  0015    | GetBoundLocalMove 3
  0017    | GetBoundLocalMove 1
  0019    | JumpIfFailure 19 -> 25
  0022    | PushInteger 1
  0024    | Merge
  0025    | CallTailFunction 2
  0027    | Jump 27 -> 32
  0030    | GetBoundLocalMove 1
  0032    | End
  ========================================
  
  ===============1:Obj.Keys===============
  Obj.Keys(O) = _Obj.Keys(O, [])
  ========================================
  0000    | GetConstant2 368: _Obj.Keys
  0003    | GetBoundLocalMove 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==============1:_Obj.Keys===============
  _Obj.Keys(O, Acc) = O -> {K: _, ...Rest} ? _Obj.Keys(Rest, [...Acc, K]) : Acc
  ========================================
  0000    | PushVar2 K
  0003    | PushUnderscoreVar
  0004    | PushVar2 Rest
  0007    | SetInputMark
  0008    | GetBoundLocalMove 0
  0010    | Destructure 124: ({K: _} + Rest)
  0012    | ConditionalThen 12 -> 43
  0015    | GetConstant2 368: _Obj.Keys
  0018    | GetBoundLocalMove 4
  0020    | PushEmptyArray
  0021    | JumpIfFailure 21 -> 27
  0024    | GetBoundLocalMove 1
  0026    | Merge
  0027    | JumpIfFailure 27 -> 38
  0030    | GetConstantMutable2 369: [_]
  0033    | GetBoundLocalMove 2
  0035    | InsertAtIndex 0
  0037    | Merge
  0038    | CallTailFunction 2
  0040    | Jump 40 -> 45
  0043    | GetBoundLocalMove 1
  0045    | End
  ========================================
  
  ==============1:Obj.Values==============
  Obj.Values(O) = _Obj.Values(O, [])
  ========================================
  0000    | GetConstant2 370: _Obj.Values
  0003    | GetBoundLocalMove 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============1:_Obj.Values==============
  _Obj.Values(O, Acc) = O -> {_: V, ...Rest} ? _Obj.Values(Rest, [...Acc, V]) : Acc
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar2 V
  0004    | PushVar2 Rest
  0007    | SetInputMark
  0008    | GetBoundLocalMove 0
  0010    | Destructure 125: ({_: V} + Rest)
  0012    | ConditionalThen 12 -> 43
  0015    | GetConstant2 370: _Obj.Values
  0018    | GetBoundLocalMove 4
  0020    | PushEmptyArray
  0021    | JumpIfFailure 21 -> 27
  0024    | GetBoundLocalMove 1
  0026    | Merge
  0027    | JumpIfFailure 27 -> 38
  0030    | GetConstantMutable2 371: [_]
  0033    | GetBoundLocalMove 3
  0035    | InsertAtIndex 0
  0037    | Merge
  0038    | CallTailFunction 2
  0040    | Jump 40 -> 45
  0043    | GetBoundLocalMove 1
  0045    | End
  ========================================
  
  ============1:_Ast.MergePos=============
  _Ast.MergePos(Left, Right) = {
    ...(Left -> {"startpos": StartPos, ..._} ? {"startpos": StartPos} : {}),
    ...(Right -> {"endpos": EndPos, ..._} ? {"endpos": EndPos} : {}),
  }
  ========================================
  0000    | PushVar2 StartPos
  0003    | PushUnderscoreVar
  0004    | PushVar2 EndPos
  0007    | PushEmptyObject
  0008    | JumpIfFailure 8 -> 34
  0011    | SetInputMark
  0012    | GetBoundLocalMove 0
  0014    | Destructure 95: ({"startpos": StartPos} + _)
  0016    | ConditionalThen 16 -> 32
  0019    | GetConstantMutable2 332: {_0_}
  0022    | PushString2 "startpos"
  0025    | GetBoundLocalMove 2
  0027    | InsertKeyVal 0
  0029    | Jump 29 -> 33
  0032    | PushEmptyObject
  0033    | Merge
  0034    | JumpIfFailure 34 -> 60
  0037    | SetInputMark
  0038    | GetBoundLocalMove 1
  0040    | Destructure 96: ({"endpos": EndPos} + _)
  0042    | ConditionalThen 42 -> 58
  0045    | GetConstantMutable2 333: {_0_}
  0048    | PushString2 "endpos"
  0051    | GetBoundLocalMove 4
  0053    | InsertKeyVal 0
  0055    | Jump 55 -> 59
  0058    | PushEmptyObject
  0059    | Merge
  0060    | End
  ========================================
  
  ==============1:Is.String===============
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 126: ("" + _)
  0005    | End
  ========================================
  
  ==============1:Is.Number===============
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 127: (0 + _)
  0005    | End
  ========================================
  
  ===============1:Is.Bool================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 128: (false + _)
  0005    | End
  ========================================
  
  ===============1:Is.Null================
  Is.Null(V) = V -> null
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 129: null
  0004    | End
  ========================================
  
  ===============1:Is.Array===============
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 130: ([] + _)
  0005    | End
  ========================================
  
  ==============1:Is.Object===============
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 70: ({} + _)
  0005    | End
  ========================================
  
  ===============1:Is.Equal===============
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 131: B
  0004    | End
  ========================================
  
  =============1:Is.LessThan==============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 93: B
  0005    | ConditionalThen 5 -> 13
  0008    | CallTailFunctionConstant 225: @Fail
  0010    | Jump 10 -> 17
  0013    | GetBoundLocalMove 0
  0015    | Destructure 94: ..B
  0017    | End
  ========================================
  
  ==========1:Is.LessThanOrEqual==========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 132: ..B
  0004    | End
  ========================================
  
  ============1:Is.GreaterThan============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 133: B
  0005    | ConditionalThen 5 -> 13
  0008    | CallTailFunctionConstant 225: @Fail
  0010    | Jump 10 -> 17
  0013    | GetBoundLocalMove 0
  0015    | Destructure 134: B..
  0017    | End
  ========================================
  
  ========1:Is.GreaterThanOrEqual=========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 135: B..
  0004    | End
  ========================================
  
  ==============1:As.Number===============
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | PushVar2 N
  0003    | SetInputMark
  0004    | GetConstant2 372: Is.Number
  0007    | GetBoundLocal 0
  0009    | CallFunction 1
  0011    | Or 11 -> 23
  0014    | GetBoundLocalMove 0
  0016    | Destructure 136: "%(0 + N)"
  0018    | TakeRight 18 -> 23
  0021    | GetBoundLocalMove 1
  0023    | End
  ========================================
  
  ==============1:As.String===============
  As.String(V) = "%(V)"
  ========================================
  0000    | PushEmptyString
  0001    | GetBoundLocalMove 0
  0003    | MergeAsString
  0004    | End
  ========================================
  
  =================1:@fn0=================
  unless(char, whitespace)
  ========================================
  0000    | GetConstant 7: unless
  0002    | GetConstant 8: char
  0004    | GetConstant 9: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================1:@fn1=================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 5: alnum
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '_'
  0009    | Or 9 -> 14
  0012    | ParseChar '-'
  0014    | End
  ========================================
  
  =================1:@fn2=================
  newline | end_of_input
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 13: newline
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 29: end_of_input
  0008    | End
  ========================================
  
  =================1:@fn3=================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 12: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 13: newline
  0008    | End
  ========================================
  
  =================1:@fn4=================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString2 "-"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionConstant 35: _number_integer_part
  0012    | Merge
  0013    | End
  ========================================
  
  =================1:@fn5=================
  "-" + _number_integer_part
  ========================================
  0000    | ParseChar '-'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 35: _number_integer_part
  0007    | Merge
  0008    | End
  ========================================
  
  =================1:@fn6=================
  maybe("-") + _number_integer_part + _number_fraction_part
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString2 "-"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionConstant 35: _number_integer_part
  0012    | Merge
  0013    | JumpIfFailure 13 -> 19
  0016    | CallFunctionConstant 39: _number_fraction_part
  0018    | Merge
  0019    | End
  ========================================
  
  =================1:@fn7=================
  maybe("-") +
    _number_integer_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString2 "-"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionConstant 35: _number_integer_part
  0012    | Merge
  0013    | JumpIfFailure 13 -> 19
  0016    | CallFunctionConstant 41: _number_exponent_part
  0018    | Merge
  0019    | End
  ========================================
  
  =================1:@fn8=================
  maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString2 "-"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionConstant 35: _number_integer_part
  0012    | Merge
  0013    | JumpIfFailure 13 -> 19
  0016    | CallFunctionConstant 39: _number_fraction_part
  0018    | Merge
  0019    | JumpIfFailure 19 -> 25
  0022    | CallFunctionConstant 41: _number_exponent_part
  0024    | Merge
  0025    | End
  ========================================
  
  =================1:@fn9=================
  maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString2 "-"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionConstant 35: _number_integer_part
  0012    | Merge
  0013    | JumpIfFailure 13 -> 23
  0016    | GetConstant 34: maybe
  0018    | GetConstant 39: _number_fraction_part
  0020    | CallFunction 1
  0022    | Merge
  0023    | JumpIfFailure 23 -> 33
  0026    | GetConstant 34: maybe
  0028    | GetConstant 41: _number_exponent_part
  0030    | CallFunction 1
  0032    | Merge
  0033    | End
  ========================================
  
  ================1:@fn10=================
  _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | CallFunctionConstant 35: _number_integer_part
  0002    | JumpIfFailure 2 -> 12
  0005    | GetConstant 34: maybe
  0007    | GetConstant 39: _number_fraction_part
  0009    | CallFunction 1
  0011    | Merge
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 34: maybe
  0017    | GetConstant 41: _number_exponent_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | End
  ========================================
  
  ================1:@fn11=================
  "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | ParseChar '-'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 35: _number_integer_part
  0007    | Merge
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 34: maybe
  0013    | GetConstant 39: _number_fraction_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 28
  0021    | GetConstant 34: maybe
  0023    | GetConstant 41: _number_exponent_part
  0025    | CallFunction 1
  0027    | Merge
  0028    | End
  ========================================
  
  ================1:@fn12=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
  ========================================
  
  ================1:@fn13=================
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
  
  ================1:@fn14=================
  tuple1(elem)
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 51: tuple1
  0006    | GetBoundLocalMove 0
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ================1:@fn15=================
  array(elem)
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 48: array
  0006    | GetBoundLocalMove 0
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ================1:@fn16=================
  array_sep(elem, sep)
  ========================================
  0000    | PushVar2 elem
  0003    | PushVar2 sep
  0006    | SetClosureCaptures
  0007    | GetConstant 70: array_sep
  0009    | GetBoundLocalMove 0
  0011    | GetBoundLocalMove 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ================1:@fn17=================
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
  
  ================1:@fn18=================
  array_sep(elem, col_sep)
  ========================================
  0000    | PushVar2 elem
  0003    | PushVar2 col_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 70: array_sep
  0009    | GetBoundLocalMove 0
  0011    | GetBoundLocalMove 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ================1:@fn19=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | PushVar2 row_sep
  0003    | PushVar2 elem
  0006    | PushVar2 col_sep
  0009    | SetClosureCaptures
  0010    | CallFunctionLocal 0
  0012    | TakeRight 12 -> 23
  0015    | GetConstant 70: array_sep
  0017    | GetBoundLocalMove 1
  0019    | GetBoundLocalMove 2
  0021    | CallTailFunction 2
  0023    | End
  ========================================
  
  ================1:@fn20=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | PushVar2 elem
  0003    | PushVar2 col_sep
  0006    | PushVar2 row_sep
  0009    | SetClosureCaptures
  0010    | GetConstant 81: _dimensions
  0012    | GetBoundLocalMove 0
  0014    | GetBoundLocalMove 1
  0016    | GetBoundLocalMove 2
  0018    | CallTailFunction 3
  0020    | End
  ========================================
  
  ================1:@fn21=================
  pair(key, value)
  ========================================
  0000    | PushVar2 key
  0003    | PushVar2 value
  0006    | SetClosureCaptures
  0007    | GetConstant 106: pair
  0009    | GetBoundLocalMove 0
  0011    | GetBoundLocalMove 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ================1:@fn22=================
  object(key, value)
  ========================================
  0000    | PushVar2 key
  0003    | PushVar2 value
  0006    | SetClosureCaptures
  0007    | GetConstant 112: object
  0009    | GetBoundLocalMove 0
  0011    | GetBoundLocalMove 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ================1:@fn23=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | PushVar2 key
  0003    | PushVar2 pair_sep
  0006    | PushVar2 value
  0009    | PushVar2 sep
  0012    | SetClosureCaptures
  0013    | GetConstant 114: object_sep
  0015    | GetBoundLocalMove 0
  0017    | GetBoundLocalMove 1
  0019    | GetBoundLocalMove 2
  0021    | GetBoundLocalMove 3
  0023    | CallTailFunction 4
  0025    | End
  ========================================
  
  ================1:@fn24=================
  find(p)
  ========================================
  0000    | PushVar2 p
  0003    | SetClosureCaptures
  0004    | GetConstant 122: find
  0006    | GetBoundLocalMove 0
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ================1:@fn25=================
  many(char)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 8: char
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn26=================
  find_before(p, stop)
  ========================================
  0000    | PushVar2 p
  0003    | PushVar2 stop
  0006    | SetClosureCaptures
  0007    | GetConstant 125: find_before
  0009    | GetBoundLocalMove 0
  0011    | GetBoundLocalMove 1
  0013    | CallTailFunction 2
  0015    | End
  ========================================
  
  ================1:@fn27=================
  chars_until(stop)
  ========================================
  0000    | PushVar2 stop
  0003    | SetClosureCaptures
  0004    | GetConstant 23: chars_until
  0006    | GetBoundLocalMove 0
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ================1:@fn28=================
  maybe(whitespace)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn30=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 161: _ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  ================1:@fn29=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 140: _escaped_ctrl_char
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 141: _escaped_unicode
  0009    | Or 9 -> 20
  0012    | GetConstant 7: unless
  0014    | GetConstant 8: char
  0016    | GetConstant 142: @fn30
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ================1:@fn32=================
  maybe(ws)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn31=================
  surround(elem, maybe(ws))
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 128: surround
  0006    | GetBoundLocalMove 0
  0008    | GetConstant 164: @fn32
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ================1:@fn34=================
  maybe(ws)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn33=================
  surround(json.string, maybe(ws))
  ========================================
  0000    | GetConstant 128: surround
  0002    | GetConstant 133: json.string
  0004    | GetConstant 168: @fn34
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================1:@fn36=================
  maybe(ws)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn35=================
  surround(value, maybe(ws))
  ========================================
  0000    | PushVar2 value
  0003    | SetClosureCaptures
  0004    | GetConstant 128: surround
  0006    | GetBoundLocalMove 0
  0008    | GetConstant 169: @fn36
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ================1:@fn37=================
  _toml.comments + maybe(ws)
  ========================================
  0000    | CallFunctionConstant 177: _toml.comments
  0002    | JumpIfFailure 2 -> 12
  0005    | GetConstant 34: maybe
  0007    | GetConstant 9: whitespace
  0009    | CallFunction 1
  0011    | Merge
  0012    | End
  ========================================
  
  ================1:@fn38=================
  maybe(ws) + _toml.comments
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 177: _toml.comments
  0011    | Merge
  0012    | End
  ========================================
  
  ================1:@fn39=================
  _toml.table_body(value, [], _Toml.Doc.Empty)
  ========================================
  0000    | PushVar2 value
  0003    | SetClosureCaptures
  0004    | GetConstant 184: _toml.table_body
  0006    | GetBoundLocalMove 0
  0008    | PushEmptyArray
  0009    | CallFunctionConstant 181: _Toml.Doc.Empty
  0011    | CallTailFunction 3
  0013    | End
  ========================================
  
  ================1:@fn40=================
  ws | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 9: whitespace
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 178: _toml.comment
  0008    | End
  ========================================
  
  ================1:@fn41=================
  spaces | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 205: spaces
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 178: _toml.comment
  0008    | End
  ========================================
  
  ================1:@fn42=================
  maybe(ws)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn43=================
  maybe(ws)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn45=================
  maybe(spaces)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 205: spaces
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn44=================
  surround("=", maybe(spaces))
  ========================================
  0000    | GetConstant 128: surround
  0002    | PushString2 "="
  0005    | GetConstant 204: @fn45
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn47=================
  maybe(ws)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn46=================
  surround(".", maybe(ws))
  ========================================
  0000    | GetConstant 128: surround
  0002    | PushString2 "."
  0005    | GetConstant 203: @fn47
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn48=================
  alpha | numeral | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 1: alpha
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 4: numeral
  0009    | Or 9 -> 20
  0012    | SetInputMark
  0013    | ParseChar '_'
  0015    | Or 15 -> 20
  0018    | ParseChar '-'
  0020    | End
  ========================================
  
  ================1:@fn50=================
  surround(elem, _toml.ws)
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 128: surround
  0006    | GetBoundLocalMove 0
  0008    | GetConstant 182: _toml.ws
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ================1:@fn51=================
  surround(",", _toml.ws)
  ========================================
  0000    | GetConstant 128: surround
  0002    | PushString2 ","
  0005    | GetConstant 182: _toml.ws
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn49=================
  array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws))
  ========================================
  0000    | PushVar2 elem
  0003    | SetClosureCaptures
  0004    | GetConstant 70: array_sep
  0006    | GetConstant2 316: @fn50
  0009    | CreateClosure 1
  0011    | CaptureLocal 0
  0013    | PushString2 ","
  0016    | CallFunction 2
  0018    | JumpIfFailure 18 -> 29
  0021    | GetConstant 34: maybe
  0023    | GetConstant2 317: @fn51
  0026    | CallFunction 1
  0028    | TakeLeft
  0029    | End
  ========================================
  
  ================1:@fn52=================
  maybe(nl)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn55=================
  _ctrl_char | `\`
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 161: _ctrl_char
  0003    | Or 3 -> 8
  0006    | ParseChar '\'
  0008    | End
  ========================================
  
  ================1:@fn54=================
  _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 198: _toml.escaped_ctrl_char
  0003    | Or 3 -> 42
  0006    | SetInputMark
  0007    | CallFunctionConstant 199: _toml.escaped_unicode
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
  0034    | GetConstant 7: unless
  0036    | GetConstant 8: char
  0038    | GetConstant 253: @fn55
  0040    | CallTailFunction 2
  0042    | End
  ========================================
  
  ================1:@fn53=================
  many_until(
        _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`),
        `"""`
      )
  ========================================
  0000    | GetConstant 25: many_until
  0002    | GetConstant 252: @fn54
  0004    | PushString2 """""
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn56=================
  maybe(nl)
  ========================================
  0000    | GetConstant 34: maybe
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn57=================
  many_until(char, `'''`)
  ========================================
  0000    | GetConstant 25: many_until
  0002    | GetConstant 8: char
  0004    | PushString2 "'''"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn59=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 161: _ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  ================1:@fn58=================
  _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 198: _toml.escaped_ctrl_char
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 199: _toml.escaped_unicode
  0009    | Or 9 -> 20
  0012    | GetConstant 7: unless
  0014    | GetConstant 8: char
  0016    | GetConstant 200: @fn59
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ================1:@fn60=================
  chars_until("'")
  ========================================
  0000    | GetConstant 23: chars_until
  0002    | PushString2 "'"
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ================1:@fn61=================
  "." + (numeral * 1..9)
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 60
  0005    | PushNull
  0006    | PushInteger 1
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 27
  0012    | Swap
  0013    | CallFunctionConstant 4: numeral
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
  0040    | CallFunctionConstant 4: numeral
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
  
  ================1:@fn62=================
  _toml.number.sign +
    _toml.number.integer_part
  ========================================
  0000    | CallFunctionConstant2 305: _toml.number.sign
  0003    | JumpIfFailure 3 -> 10
  0006    | CallFunctionConstant2 306: _toml.number.integer_part
  0009    | Merge
  0010    | End
  ========================================
  
  ================1:@fn63=================
  "-" | skip("+")
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 13
  0006    | GetConstant 249: skip
  0008    | PushString2 "+"
  0011    | CallTailFunction 1
  0013    | End
  ========================================
  
  ================1:@fn64=================
  maybe("_") > numeral
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 11
  0009    | CallTailFunctionConstant 4: numeral
  0011    | End
  ========================================
  
  ================1:@fn65=================
  _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  ========================================
  0000    | CallFunctionConstant2 305: _toml.number.sign
  0003    | JumpIfFailure 3 -> 10
  0006    | CallFunctionConstant2 306: _toml.number.integer_part
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | SetInputMark
  0014    | CallFunctionConstant2 307: _toml.number.fraction_part
  0017    | JumpIfFailure 17 -> 28
  0020    | GetConstant 34: maybe
  0022    | GetConstant2 308: _toml.number.exponent_part
  0025    | CallFunction 1
  0027    | Merge
  0028    | Or 28 -> 34
  0031    | CallFunctionConstant2 308: _toml.number.exponent_part
  0034    | Merge
  0035    | End
  ========================================
  
  ================1:@fn66=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn67=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
  ========================================
  
  ================1:@fn68=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn69=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | End
  ========================================
  
  ================1:@fn70=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | End
  ========================================
  
  ================1:@fn72=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn73=================
  skip("_") < peek(binary_numeral)
  ========================================
  0000    | GetConstant 249: skip
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 17
  0009    | GetConstant 26: peek
  0011    | GetConstant2 285: binary_numeral
  0014    | CallFunction 1
  0016    | TakeLeft
  0017    | End
  ========================================
  
  ================1:@fn71=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral))
  ========================================
  0000    | GetConstant 70: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 283: @fn72
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 34: maybe
  0013    | GetConstant2 284: @fn73
  0016    | CallFunction 1
  0018    | Merge
  0019    | End
  ========================================
  
  ================1:@fn75=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn74=================
  array_sep(binary_digit, maybe("_"))
  ========================================
  0000    | GetConstant 70: array_sep
  0002    | GetConstant 49: binary_digit
  0004    | GetConstant2 286: @fn75
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn77=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn78=================
  skip("_") < peek(octal_numeral)
  ========================================
  0000    | GetConstant 249: skip
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 17
  0009    | GetConstant 26: peek
  0011    | GetConstant2 292: octal_numeral
  0014    | CallFunction 1
  0016    | TakeLeft
  0017    | End
  ========================================
  
  ================1:@fn76=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral))
  ========================================
  0000    | GetConstant 70: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 290: @fn77
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 34: maybe
  0013    | GetConstant2 291: @fn78
  0016    | CallFunction 1
  0018    | Merge
  0019    | End
  ========================================
  
  ================1:@fn80=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn79=================
  array_sep(octal_digit, maybe("_"))
  ========================================
  0000    | GetConstant 70: array_sep
  0002    | GetConstant 57: octal_digit
  0004    | GetConstant2 293: @fn80
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================1:@fn82=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn83=================
  skip("_") < peek(hex_numeral)
  ========================================
  0000    | GetConstant 249: skip
  0002    | PushString "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 26: peek
  0011    | GetConstant 159: hex_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ================1:@fn81=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral))
  ========================================
  0000    | GetConstant 70: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 297: @fn82
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 34: maybe
  0013    | GetConstant2 298: @fn83
  0016    | CallFunction 1
  0018    | Merge
  0019    | End
  ========================================
  
  ================1:@fn85=================
  maybe("_")
  ========================================
  0000    | GetConstant 34: maybe
  0002    | PushString "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:@fn84=================
  array_sep(hex_digit, maybe("_"))
  ========================================
  0000    | GetConstant 70: array_sep
  0002    | GetConstant 60: hex_digit
  0004    | GetConstant2 299: @fn85
  0007    | CallTailFunction 2
  0009    | End
  ========================================

