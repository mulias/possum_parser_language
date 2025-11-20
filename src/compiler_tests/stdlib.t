  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i ''
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  =================ascii==================
  ascii = "\u000000".."\u00007F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x7f' (esc)
  0003    | End
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
  
  =================alphas=================
  alphas = many(alpha)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: alpha
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================lower==================
  lower = "a".."z"
  ========================================
  0000    | ParseCodepointRange 'a'..'z'
  0003    | End
  ========================================
  
  =================lowers=================
  lowers = many(lower)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 2: lower
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================upper==================
  upper = "A".."Z"
  ========================================
  0000    | ParseCodepointRange 'A'..'Z'
  0003    | End
  ========================================
  
  =================uppers=================
  uppers = many(upper)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 3: upper
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ================numerals================
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 4: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============binary_numeral=============
  binary_numeral = "0" | "1"
  ========================================
  0000    | SetInputMark
  0001    | PushChar '0'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar '1'
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =============octal_numeral==============
  octal_numeral = "0".."7"
  ========================================
  0000    | ParseCodepointRange '0'..'7'
  0003    | End
  ========================================
  
  ==============hex_numeral===============
  hex_numeral = numeral | "a".."f" | "A".."F"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 4: numeral
  0003    | CallFunction 0
  0005    | Or 5 -> 18
  0008    | SetInputMark
  0009    | ParseCodepointRange 'a'..'f'
  0012    | Or 12 -> 18
  0015    | ParseCodepointRange 'A'..'F'
  0018    | End
  ========================================
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 1: alpha
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 4: numeral
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================alnums=================
  alnums = many(alnum)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 5: alnum
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn686=================
  unless(char, whitespace)
  ========================================
  0000    | GetConstant 7: unless
  0002    | GetConstant 8: char
  0004    | GetConstant 9: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  token = many(unless(char, whitespace))
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 6: @fn686
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn687=================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 5: alnum
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | PushChar '_'
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | PushChar '-'
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  ==================word==================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 10: @fn687
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn688=================
  newline | end_of_input
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 13: newline
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 14: end_of_input
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==================line==================
  line = chars_until(newline | end_of_input)
  ========================================
  0000    | GetConstant 11: chars_until
  0002    | GetConstant 12: @fn688
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================space==================
  space =
    " " | "\t" | "\u0000A0" | "\u002000".."\u00200A" | "\u00202F" | "\u00205F" | "\u003000"
  ========================================
  0000    | SetInputMark
  0001    | PushChar ' '
  0003    | CallFunction 0
  0005    | Or 5 -> 53
  0008    | SetInputMark
  0009    | PushChar '\t' (esc)
  0011    | CallFunction 0
  0013    | Or 13 -> 53
  0016    | SetInputMark
  0017    | GetConstant 15: "\xc2\xa0" (esc)
  0019    | CallFunction 0
  0021    | Or 21 -> 53
  0024    | SetInputMark
  0025    | GetConstant 16: "\xe2\x80\x80" (esc)
  0027    | GetConstant 17: "\xe2\x80\x8a" (esc)
  0029    | ParseRange
  0030    | Or 30 -> 53
  0033    | SetInputMark
  0034    | GetConstant 18: "\xe2\x80\xaf" (esc)
  0036    | CallFunction 0
  0038    | Or 38 -> 53
  0041    | SetInputMark
  0042    | GetConstant 19: "\xe2\x81\x9f" (esc)
  0044    | CallFunction 0
  0046    | Or 46 -> 53
  0049    | GetConstant 20: "\xe3\x80\x80" (esc)
  0051    | CallFunction 0
  0053    | End
  ========================================
  
  =================spaces=================
  spaces = many(space)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 21: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================newline=================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 22: "\r (esc)
  "
  0003    | CallFunction 0
  0005    | Or 5 -> 35
  0008    | SetInputMark
  0009    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0012    | Or 12 -> 35
  0015    | SetInputMark
  0016    | GetConstant 23: "\xc2\x85" (esc)
  0018    | CallFunction 0
  0020    | Or 20 -> 35
  0023    | SetInputMark
  0024    | GetConstant 24: "\xe2\x80\xa8" (esc)
  0026    | CallFunction 0
  0028    | Or 28 -> 35
  0031    | GetConstant 25: "\xe2\x80\xa9" (esc)
  0033    | CallFunction 0
  0035    | End
  ========================================
  
  ================newlines================
  newlines = many(newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn689=================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 21: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 13: newline
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ===============whitespace===============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 26: @fn689
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============chars_until===============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 27: many_until
  0002    | GetConstant 8: char
  0004    | GetBoundLocal 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@fn690=================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | GetConstant 31: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 29: @fn690
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========non_negative_integer==========
  non_negative_integer = as_number(_number_integer_part)
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 31: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn691=================
  "-" + _number_integer_part
  ========================================
  0000    | PushChar '-'
  0002    | CallFunction 0
  0004    | GetConstant 31: _number_integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  ============negative_integer============
  negative_integer = as_number("-" + _number_integer_part)
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 32: @fn691
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn692=================
  maybe("-") + _number_integer_part + _number_fraction_part
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | GetConstant 31: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 34: _number_fraction_part
  0013    | CallFunction 0
  0015    | Merge
  0016    | End
  ========================================
  
  =================float==================
  float = as_number(maybe("-") + _number_integer_part + _number_fraction_part)
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 33: @fn692
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn693=================
  maybe("-") +
    _number_integer_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | GetConstant 31: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 36: _number_exponent_part
  0013    | CallFunction 0
  0015    | Merge
  0016    | End
  ========================================
  
  ===========scientific_integer===========
  scientific_integer = as_number(
    maybe("-") +
    _number_integer_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 35: @fn693
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn694=================
  maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | GetConstant 31: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 34: _number_fraction_part
  0013    | CallFunction 0
  0015    | Merge
  0016    | GetConstant 36: _number_exponent_part
  0018    | CallFunction 0
  0020    | Merge
  0021    | End
  ========================================
  
  ============scientific_float============
  scientific_float = as_number(
    maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 37: @fn694
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn695=================
  maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | GetConstant 31: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 30: maybe
  0013    | GetConstant 34: _number_fraction_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | GetConstant 30: maybe
  0020    | GetConstant 36: _number_exponent_part
  0022    | CallFunction 1
  0024    | Merge
  0025    | End
  ========================================
  
  =================number=================
  number = as_number(
    maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 38: @fn695
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn696=================
  _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 31: _number_integer_part
  0002    | CallFunction 0
  0004    | GetConstant 30: maybe
  0006    | GetConstant 34: _number_fraction_part
  0008    | CallFunction 1
  0010    | Merge
  0011    | GetConstant 30: maybe
  0013    | GetConstant 36: _number_exponent_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | End
  ========================================
  
  ==========non_negative_number===========
  non_negative_number = as_number(
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 39: @fn696
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn697=================
  "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | PushChar '-'
  0002    | CallFunction 0
  0004    | GetConstant 31: _number_integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | GetConstant 30: maybe
  0011    | GetConstant 34: _number_fraction_part
  0013    | CallFunction 1
  0015    | Merge
  0016    | GetConstant 30: maybe
  0018    | GetConstant 36: _number_exponent_part
  0020    | CallFunction 1
  0022    | Merge
  0023    | End
  ========================================
  
  ============negative_number=============
  negative_number = as_number(
    "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant 40: @fn697
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_number_integer_part==========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | GetConstant 41: numerals
  0006    | CallFunction 0
  0008    | Merge
  0009    | Or 9 -> 16
  0012    | GetConstant 4: numeral
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =========_number_fraction_part==========
  _number_fraction_part = "." + numerals
  ========================================
  0000    | PushChar '.'
  0002    | CallFunction 0
  0004    | GetConstant 41: numerals
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  =================@fn698=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | PushChar '-'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar '+'
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_number_exponent_part==========
  _number_exponent_part = ("e" | "E") + maybe("-" | "+") + numerals
  ========================================
  0000    | SetInputMark
  0001    | PushChar 'e'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar 'E'
  0010    | CallFunction 0
  0012    | GetConstant 30: maybe
  0014    | GetConstant 42: @fn698
  0016    | CallFunction 1
  0018    | Merge
  0019    | GetConstant 41: numerals
  0021    | CallFunction 0
  0023    | Merge
  0024    | End
  ========================================
  
  ==============binary_digit==============
  binary_digit = 0..1
  ========================================
  0000    | ParseIntegerRange 0..1
  0003    | End
  ========================================
  
  ==============octal_digit===============
  octal_digit = 0..7
  ========================================
  0000    | ParseIntegerRange 0..7
  0003    | End
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
  0001    | GetConstant 43: digit
  0003    | CallFunction 0
  0005    | Or 5 -> 130
  0008    | SetInputMark
  0009    | SetInputMark
  0010    | PushChar 'a'
  0012    | CallFunction 0
  0014    | Or 14 -> 21
  0017    | PushChar 'A'
  0019    | CallFunction 0
  0021    | TakeRight 21 -> 26
  0024    | PushNumber 10
  0026    | Or 26 -> 130
  0029    | SetInputMark
  0030    | SetInputMark
  0031    | PushChar 'b'
  0033    | CallFunction 0
  0035    | Or 35 -> 42
  0038    | PushChar 'B'
  0040    | CallFunction 0
  0042    | TakeRight 42 -> 47
  0045    | PushNumber 11
  0047    | Or 47 -> 130
  0050    | SetInputMark
  0051    | SetInputMark
  0052    | PushChar 'c'
  0054    | CallFunction 0
  0056    | Or 56 -> 63
  0059    | PushChar 'C'
  0061    | CallFunction 0
  0063    | TakeRight 63 -> 68
  0066    | PushNumber 12
  0068    | Or 68 -> 130
  0071    | SetInputMark
  0072    | SetInputMark
  0073    | PushChar 'd'
  0075    | CallFunction 0
  0077    | Or 77 -> 84
  0080    | PushChar 'D'
  0082    | CallFunction 0
  0084    | TakeRight 84 -> 89
  0087    | PushNumber 13
  0089    | Or 89 -> 130
  0092    | SetInputMark
  0093    | SetInputMark
  0094    | PushChar 'e'
  0096    | CallFunction 0
  0098    | Or 98 -> 105
  0101    | PushChar 'E'
  0103    | CallFunction 0
  0105    | TakeRight 105 -> 110
  0108    | PushNumber 14
  0110    | Or 110 -> 130
  0113    | SetInputMark
  0114    | PushChar 'f'
  0116    | CallFunction 0
  0118    | Or 118 -> 125
  0121    | PushChar 'F'
  0123    | CallFunction 0
  0125    | TakeRight 125 -> 130
  0128    | PushNumber 15
  0130    | End
  ========================================
  
  =============binary_integer=============
  binary_integer = array(binary_digit) -> Digits $ Num.FromBinaryDigits(Digits)
  ========================================
  0000    | GetConstant 44: Digits
  0002    | GetConstant 45: array
  0004    | GetConstant 46: binary_digit
  0006    | CallFunction 1
  0008    | Destructure 0: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 47: Num.FromBinaryDigits
  0015    | GetBoundLocal 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  =============octal_integer==============
  octal_integer = array(octal_digit) -> Digits $ Num.FromOctalDigits(Digits)
  ========================================
  0000    | GetConstant 44: Digits
  0002    | GetConstant 45: array
  0004    | GetConstant 48: octal_digit
  0006    | CallFunction 1
  0008    | Destructure 1: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 49: Num.FromOctalDigits
  0015    | GetBoundLocal 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  ==============hex_integer===============
  hex_integer = array(hex_digit) -> Digits $ Num.FromHexDigits(Digits)
  ========================================
  0000    | GetConstant 44: Digits
  0002    | GetConstant 45: array
  0004    | GetConstant 50: hex_digit
  0006    | CallFunction 1
  0008    | Destructure 2: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 51: Num.FromHexDigits
  0015    | GetBoundLocal 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  ==================true==================
  true(t) = t $ true
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | True
  0008    | End
  ========================================
  
  =================false==================
  false(f) = f $ false
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | False
  0008    | End
  ========================================
  
  ================boolean=================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 52: true
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 53: false
  0012    | GetBoundLocal 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ==================null==================
  null(n) = n $ null
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | Null
  0008    | End
  ========================================
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | Null
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
  
  =================@fn699=================
  sep > elem
  ========================================
  0000    | GetConstant 56: sep
  0002    | GetConstant 57: elem
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn700=================
  sep > elem
  ========================================
  0000    | GetConstant 56: sep
  0002    | GetConstant 57: elem
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ===============array_sep================
  array_sep(elem, sep) = tuple1(elem) + (tuple1(sep > elem) * 0..)
  ========================================
  0000    | GetConstant 54: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | Null
  0007    | PushNumberZero
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 37
  0012    | Swap
  0013    | GetConstant 54: tuple1
  0015    | GetConstant 55: @fn699
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
  0041    | GetConstant 58: @fn700
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
  
  =================@fn701=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 57: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 54: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn702=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 57: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 54: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============array_until===============
  array_until(elem, stop) = unless(tuple1(elem), stop) * 1.. < peek(stop)
  ========================================
  0000    | Null
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 31
  0006    | Swap
  0007    | GetConstant 7: unless
  0009    | GetConstant 59: @fn701
  0011    | CreateClosure 1
  0013    | CaptureLocal 0
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | Merge
  0020    | JumpIfFailure 20 -> 55
  0023    | Swap
  0024    | Decrement
  0025    | JumpIfZero 25 -> 31
  0028    | JumpBack 28 -> 6
  0031    | Swap
  0032    | SetInputMark
  0033    | GetConstant 7: unless
  0035    | GetConstant 60: @fn702
  0037    | CreateClosure 1
  0039    | CaptureLocal 0
  0041    | GetBoundLocal 1
  0043    | CallFunction 2
  0045    | JumpIfFailure 45 -> 53
  0048    | PopInputMark
  0049    | Merge
  0050    | JumpBack 50 -> 32
  0053    | ResetInput
  0054    | Drop
  0055    | Swap
  0056    | Drop
  0057    | JumpIfFailure 57 -> 67
  0060    | GetConstant 61: peek
  0062    | GetBoundLocal 1
  0064    | CallFunction 1
  0066    | TakeLeft
  0067    | End
  ========================================
  
  =================@fn703=================
  array(elem)
  ========================================
  0000    | GetConstant 57: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 45: array
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  maybe_array(elem) = default(array(elem), [])
  ========================================
  0000    | GetConstant 62: default
  0002    | GetConstant 63: @fn703
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | PushEmptyArray
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn704=================
  array_sep(elem, sep)
  ========================================
  0000    | GetConstant 57: elem
  0002    | GetConstant 56: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 65: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 62: default
  0002    | GetConstant 64: @fn704
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyArray
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 66: Elem
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 3: Elem
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 67: [_]
  0013    | GetBoundLocal 1
  0015    | InsertAtIndex 0
  0017    | End
  ========================================
  
  =================tuple2=================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 68: E1
  0002    | GetConstant 69: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 4: E1
  0010    | TakeRight 10 -> 32
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | Destructure 5: E2
  0019    | TakeRight 19 -> 32
  0022    | GetConstant 70: [_, _]
  0024    | GetBoundLocal 2
  0026    | InsertAtIndex 0
  0028    | GetBoundLocal 3
  0030    | InsertAtIndex 1
  0032    | End
  ========================================
  
  ===============tuple2_sep===============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 68: E1
  0002    | GetConstant 69: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 6: E1
  0010    | TakeRight 10 -> 17
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 39
  0020    | GetBoundLocal 2
  0022    | CallFunction 0
  0024    | Destructure 7: E2
  0026    | TakeRight 26 -> 39
  0029    | GetConstant 71: [_, _]
  0031    | GetBoundLocal 3
  0033    | InsertAtIndex 0
  0035    | GetBoundLocal 4
  0037    | InsertAtIndex 1
  0039    | End
  ========================================
  
  =================tuple3=================
  tuple3(elem1, elem2, elem3) =
    elem1 -> E1 &
    elem2 -> E2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | GetConstant 68: E1
  0002    | GetConstant 69: E2
  0004    | GetConstant 72: E3
  0006    | GetBoundLocal 0
  0008    | CallFunction 0
  0010    | Destructure 8: E1
  0012    | TakeRight 12 -> 21
  0015    | GetBoundLocal 1
  0017    | CallFunction 0
  0019    | Destructure 9: E2
  0021    | TakeRight 21 -> 47
  0024    | GetBoundLocal 2
  0026    | CallFunction 0
  0028    | Destructure 10: E3
  0030    | TakeRight 30 -> 47
  0033    | GetConstant 73: [_, _, _]
  0035    | GetBoundLocal 3
  0037    | InsertAtIndex 0
  0039    | GetBoundLocal 4
  0041    | InsertAtIndex 1
  0043    | GetBoundLocal 5
  0045    | InsertAtIndex 2
  0047    | End
  ========================================
  
  ===============tuple3_sep===============
  tuple3_sep(elem1, sep1, elem2, sep2, elem3) =
    elem1 -> E1 & sep1 &
    elem2 -> E2 & sep2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | GetConstant 68: E1
  0002    | GetConstant 69: E2
  0004    | GetConstant 72: E3
  0006    | GetBoundLocal 0
  0008    | CallFunction 0
  0010    | Destructure 11: E1
  0012    | TakeRight 12 -> 19
  0015    | GetBoundLocal 1
  0017    | CallFunction 0
  0019    | TakeRight 19 -> 28
  0022    | GetBoundLocal 2
  0024    | CallFunction 0
  0026    | Destructure 12: E2
  0028    | TakeRight 28 -> 35
  0031    | GetBoundLocal 3
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 61
  0038    | GetBoundLocal 4
  0040    | CallFunction 0
  0042    | Destructure 13: E3
  0044    | TakeRight 44 -> 61
  0047    | GetConstant 74: [_, _, _]
  0049    | GetBoundLocal 5
  0051    | InsertAtIndex 0
  0053    | GetBoundLocal 6
  0055    | InsertAtIndex 1
  0057    | GetBoundLocal 7
  0059    | InsertAtIndex 2
  0061    | End
  ========================================
  
  =================tuple==================
  tuple(elem, N) = tuple1(elem) * N
  ========================================
  0000    | Null
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
  
  =================@fn710=================
  sep > elem
  ========================================
  0000    | GetConstant 56: sep
  0002    | GetConstant 57: elem
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ===============tuple_sep================
  tuple_sep(elem, sep, N) = tuple1(elem) + (tuple1(sep > elem) * (N - 1))
  ========================================
  0000    | GetConstant 54: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | Null
  0007    | GetBoundLocal 2
  0009    | PushNumberNegOne
  0010    | Merge
  0011    | ValidateRepeatPattern
  0012    | JumpIfZero 12 -> 41
  0015    | Swap
  0016    | GetConstant 54: tuple1
  0018    | GetConstant 75: @fn710
  0020    | CreateClosure 2
  0022    | CaptureLocal 1
  0024    | CaptureLocal 0
  0026    | CallFunction 1
  0028    | Merge
  0029    | JumpIfFailure 29 -> 40
  0032    | Swap
  0033    | Decrement
  0034    | JumpIfZero 34 -> 41
  0037    | JumpBack 37 -> 15
  0040    | Swap
  0041    | Drop
  0042    | Merge
  0043    | End
  ========================================
  
  =================@fn711=================
  array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 57: elem
  0002    | GetConstant 77: col_sep
  0004    | SetClosureCaptures
  0005    | GetConstant 65: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn712=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 79: row_sep
  0002    | GetConstant 57: elem
  0004    | GetConstant 77: col_sep
  0006    | SetClosureCaptures
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 22
  0014    | GetConstant 65: array_sep
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | CallTailFunction 2
  0022    | End
  ========================================
  
  =================@fn713=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 79: row_sep
  0002    | GetConstant 57: elem
  0004    | GetConstant 77: col_sep
  0006    | SetClosureCaptures
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 22
  0014    | GetConstant 65: array_sep
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | CallTailFunction 2
  0022    | End
  ========================================
  
  ==================rows==================
  rows(elem, col_sep, row_sep) =
    tuple1(array_sep(elem, col_sep)) +
    (tuple1(row_sep > array_sep(elem, col_sep)) * 0..)
  ========================================
  0000    | GetConstant 54: tuple1
  0002    | GetConstant 76: @fn711
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | Null
  0013    | PushNumberZero
  0014    | ValidateRepeatPattern
  0015    | JumpIfZero 15 -> 45
  0018    | Swap
  0019    | GetConstant 54: tuple1
  0021    | GetConstant 78: @fn712
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
  0049    | GetConstant 80: @fn713
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
  
  =================@fn714=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | GetConstant 57: elem
  0002    | GetConstant 77: col_sep
  0004    | GetConstant 79: row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 84: _dimensions
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 2
  0015    | CallTailFunction 3
  0017    | End
  ========================================
  
  ==============rows_padded===============
  rows_padded(elem, col_sep, row_sep, Pad) =
    peek(_dimensions(elem, col_sep, row_sep)) -> [MaxRowLen, _] &
    elem -> First & _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [First], [])
  ========================================
  0000    | GetConstant 81: MaxRowLen
  0002    | PushUnderscoreVar
  0003    | GetConstant 82: First
  0005    | GetConstant 61: peek
  0007    | GetConstant 83: @fn714
  0009    | CreateClosure 3
  0011    | CaptureLocal 0
  0013    | CaptureLocal 1
  0015    | CaptureLocal 2
  0017    | CallFunction 1
  0019    | Destructure 14: [MaxRowLen, _]
  0021    | TakeRight 21 -> 30
  0024    | GetBoundLocal 0
  0026    | CallFunction 0
  0028    | Destructure 15: First
  0030    | TakeRight 30 -> 55
  0033    | GetConstant 85: _rows_padded
  0035    | GetBoundLocal 0
  0037    | GetBoundLocal 1
  0039    | GetBoundLocal 2
  0041    | GetBoundLocal 3
  0043    | PushNumberOne
  0044    | GetBoundLocal 4
  0046    | GetConstant 86: [_]
  0048    | GetBoundLocal 6
  0050    | InsertAtIndex 0
  0052    | PushEmptyArray
  0053    | CallTailFunction 8
  0055    | End
  ========================================
  
  ==============_rows_padded==============
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    col_sep > elem -> Elem ?
    _rows_padded(elem, col_sep, row_sep, Pad, Num.Inc(RowLen), MaxRowLen, [...AccRow, Elem], AccRows) :
    row_sep > elem -> NextRow ?
    _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [NextRow], [...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)]) :
    const([...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)])
  ========================================
  0000    | GetConstant 66: Elem
  0002    | GetConstant 87: NextRow
  0004    | SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | Destructure 16: Elem
  0018    | ConditionalThen 18 -> 57
  0021    | GetConstant 85: _rows_padded
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | GetBoundLocal 2
  0029    | GetBoundLocal 3
  0031    | GetConstant 88: Num.Inc
  0033    | GetBoundLocal 4
  0035    | CallFunction 1
  0037    | GetBoundLocal 5
  0039    | PushEmptyArray
  0040    | GetBoundLocal 6
  0042    | Merge
  0043    | GetConstant 89: [_]
  0045    | GetBoundLocal 8
  0047    | InsertAtIndex 0
  0049    | Merge
  0050    | GetBoundLocal 7
  0052    | CallTailFunction 8
  0054    | Jump 54 -> 148
  0057    | SetInputMark
  0058    | GetBoundLocal 2
  0060    | CallFunction 0
  0062    | TakeRight 62 -> 69
  0065    | GetBoundLocal 0
  0067    | CallFunction 0
  0069    | Destructure 17: NextRow
  0071    | ConditionalThen 71 -> 121
  0074    | GetConstant 85: _rows_padded
  0076    | GetBoundLocal 0
  0078    | GetBoundLocal 1
  0080    | GetBoundLocal 2
  0082    | GetBoundLocal 3
  0084    | PushNumberOne
  0085    | GetBoundLocal 5
  0087    | GetConstant 90: [_]
  0089    | GetBoundLocal 9
  0091    | InsertAtIndex 0
  0093    | PushEmptyArray
  0094    | GetBoundLocal 7
  0096    | Merge
  0097    | GetConstant 91: [_]
  0099    | GetConstant 92: Array.AppendN
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
  0118    | Jump 118 -> 148
  0121    | GetConstant 93: const
  0123    | PushEmptyArray
  0124    | GetBoundLocal 7
  0126    | Merge
  0127    | GetConstant 94: [_]
  0129    | GetConstant 92: Array.AppendN
  0131    | GetBoundLocal 6
  0133    | GetBoundLocal 3
  0135    | GetBoundLocal 5
  0137    | GetBoundLocal 4
  0139    | NegateNumber
  0140    | Merge
  0141    | CallFunction 3
  0143    | InsertAtIndex 0
  0145    | Merge
  0146    | CallTailFunction 1
  0148    | End
  ========================================
  
  ==============_dimensions===============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 20
  0007    | GetConstant 95: __dimensions
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 2
  0015    | PushNumberOne
  0016    | PushNumberOne
  0017    | PushNumberZero
  0018    | CallTailFunction 6
  0020    | End
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
  0001    | GetBoundLocal 1
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 12
  0008    | GetBoundLocal 0
  0010    | CallFunction 0
  0012    | ConditionalThen 12 -> 38
  0015    | GetConstant 95: __dimensions
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 2
  0023    | GetConstant 88: Num.Inc
  0025    | GetBoundLocal 3
  0027    | CallFunction 1
  0029    | GetBoundLocal 4
  0031    | GetBoundLocal 5
  0033    | CallTailFunction 6
  0035    | Jump 35 -> 101
  0038    | SetInputMark
  0039    | GetBoundLocal 2
  0041    | CallFunction 0
  0043    | TakeRight 43 -> 50
  0046    | GetBoundLocal 0
  0048    | CallFunction 0
  0050    | ConditionalThen 50 -> 81
  0053    | GetConstant 95: __dimensions
  0055    | GetBoundLocal 0
  0057    | GetBoundLocal 1
  0059    | GetBoundLocal 2
  0061    | PushNumberOne
  0062    | GetConstant 88: Num.Inc
  0064    | GetBoundLocal 4
  0066    | CallFunction 1
  0068    | GetConstant 96: Num.Max
  0070    | GetBoundLocal 3
  0072    | GetBoundLocal 5
  0074    | CallFunction 2
  0076    | CallTailFunction 6
  0078    | Jump 78 -> 101
  0081    | GetConstant 93: const
  0083    | GetConstant 97: [_, _]
  0085    | GetConstant 96: Num.Max
  0087    | GetBoundLocal 3
  0089    | GetBoundLocal 5
  0091    | CallFunction 2
  0093    | InsertAtIndex 0
  0095    | GetBoundLocal 4
  0097    | InsertAtIndex 1
  0099    | CallTailFunction 1
  0101    | End
  ========================================
  
  ================columns=================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant 98: Rows
  0002    | GetConstant 99: rows
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | CallFunction 3
  0012    | Destructure 18: Rows
  0014    | TakeRight 14 -> 23
  0017    | GetConstant 100: Table.Transpose
  0019    | GetBoundLocal 3
  0021    | CallTailFunction 1
  0023    | End
  ========================================
  
  =============columns_padded=============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant 98: Rows
  0002    | GetConstant 101: rows_padded
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | GetBoundLocal 3
  0012    | CallFunction 4
  0014    | Destructure 19: Rows
  0016    | TakeRight 16 -> 25
  0019    | GetConstant 100: Table.Transpose
  0021    | GetBoundLocal 4
  0023    | CallTailFunction 1
  0025    | End
  ========================================
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | Null
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 102: pair
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
  0029    | GetConstant 102: pair
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
  0049    | End
  ========================================
  
  ===============object_sep===============
  object_sep(key, kv_sep, value, sep) =
    pair_sep(key, kv_sep, value) +
    ((sep > pair_sep(key, kv_sep, value)) * 0..)
  ========================================
  0000    | GetConstant 103: pair_sep
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | CallFunction 3
  0010    | Null
  0011    | PushNumberZero
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 46
  0016    | Swap
  0017    | GetBoundLocal 3
  0019    | CallFunction 0
  0021    | TakeRight 21 -> 34
  0024    | GetConstant 103: pair_sep
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | GetBoundLocal 2
  0032    | CallFunction 3
  0034    | Merge
  0035    | JumpIfFailure 35 -> 75
  0038    | Swap
  0039    | Decrement
  0040    | JumpIfZero 40 -> 46
  0043    | JumpBack 43 -> 16
  0046    | Swap
  0047    | SetInputMark
  0048    | GetBoundLocal 3
  0050    | CallFunction 0
  0052    | TakeRight 52 -> 65
  0055    | GetConstant 103: pair_sep
  0057    | GetBoundLocal 0
  0059    | GetBoundLocal 1
  0061    | GetBoundLocal 2
  0063    | CallFunction 3
  0065    | JumpIfFailure 65 -> 73
  0068    | PopInputMark
  0069    | Merge
  0070    | JumpBack 70 -> 47
  0073    | ResetInput
  0074    | Drop
  0075    | Swap
  0076    | Drop
  0077    | Merge
  0078    | End
  ========================================
  
  =================@fn721=================
  pair(key, value)
  ========================================
  0000    | GetConstant 105: key
  0002    | GetConstant 106: value
  0004    | SetClosureCaptures
  0005    | GetConstant 102: pair
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn722=================
  pair(key, value)
  ========================================
  0000    | GetConstant 105: key
  0002    | GetConstant 106: value
  0004    | SetClosureCaptures
  0005    | GetConstant 102: pair
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============object_until==============
  object_until(key, value, stop) =
    unless(pair(key, value), stop) * 1.. < peek(stop)
  ========================================
  0000    | Null
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 33
  0006    | Swap
  0007    | GetConstant 7: unless
  0009    | GetConstant 104: @fn721
  0011    | CreateClosure 2
  0013    | CaptureLocal 0
  0015    | CaptureLocal 1
  0017    | GetBoundLocal 2
  0019    | CallFunction 2
  0021    | Merge
  0022    | JumpIfFailure 22 -> 59
  0025    | Swap
  0026    | Decrement
  0027    | JumpIfZero 27 -> 33
  0030    | JumpBack 30 -> 6
  0033    | Swap
  0034    | SetInputMark
  0035    | GetConstant 7: unless
  0037    | GetConstant 107: @fn722
  0039    | CreateClosure 2
  0041    | CaptureLocal 0
  0043    | CaptureLocal 1
  0045    | GetBoundLocal 2
  0047    | CallFunction 2
  0049    | JumpIfFailure 49 -> 57
  0052    | PopInputMark
  0053    | Merge
  0054    | JumpBack 54 -> 34
  0057    | ResetInput
  0058    | Drop
  0059    | Swap
  0060    | Drop
  0061    | JumpIfFailure 61 -> 71
  0064    | GetConstant 61: peek
  0066    | GetBoundLocal 2
  0068    | CallFunction 1
  0070    | TakeLeft
  0071    | End
  ========================================
  
  =================@fn723=================
  object(key, value)
  ========================================
  0000    | GetConstant 105: key
  0002    | GetConstant 106: value
  0004    | SetClosureCaptures
  0005    | GetConstant 109: object
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  maybe_object(key, value) = default(object(key, value), {})
  ========================================
  0000    | GetConstant 62: default
  0002    | GetConstant 108: @fn723
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyObject
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn724=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | GetConstant 105: key
  0002    | GetConstant 111: pair_sep
  0004    | GetConstant 106: value
  0006    | GetConstant 56: sep
  0008    | SetClosureCaptures
  0009    | GetConstant 112: object_sep
  0011    | GetBoundLocal 0
  0013    | GetBoundLocal 1
  0015    | GetBoundLocal 2
  0017    | GetBoundLocal 3
  0019    | CallTailFunction 4
  0021    | End
  ========================================
  
  ============maybe_object_sep============
  maybe_object_sep(key, pair_sep, value, sep) =
    default(object_sep(key, pair_sep, value, sep), {})
  ========================================
  0000    | GetConstant 62: default
  0002    | GetConstant 110: @fn724
  0004    | CreateClosure 4
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CaptureLocal 2
  0012    | CaptureLocal 3
  0014    | PushEmptyObject
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 20: K
  0010    | TakeRight 10 -> 30
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | Destructure 21: V
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 113: {_0_}
  0024    | GetBoundLocal 2
  0026    | GetBoundLocal 3
  0028    | InsertKeyVal 0
  0030    | End
  ========================================
  
  ================pair_sep================
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 22: K
  0010    | TakeRight 10 -> 17
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 37
  0020    | GetBoundLocal 2
  0022    | CallFunction 0
  0024    | Destructure 23: V
  0026    | TakeRight 26 -> 37
  0029    | GetConstant 114: {_0_}
  0031    | GetBoundLocal 3
  0033    | GetBoundLocal 4
  0035    | InsertKeyVal 0
  0037    | End
  ========================================
  
  ================record1=================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | GetConstant 115: Value
  0002    | GetBoundLocal 1
  0004    | CallFunction 0
  0006    | Destructure 24: Value
  0008    | TakeRight 8 -> 19
  0011    | GetConstant 116: {_0_}
  0013    | GetBoundLocal 0
  0015    | GetBoundLocal 2
  0017    | InsertKeyVal 0
  0019    | End
  ========================================
  
  ================record2=================
  record2(Key1, value1, Key2, value2) =
    value1 -> V1 &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | GetConstant 117: V1
  0002    | GetConstant 118: V2
  0004    | GetBoundLocal 1
  0006    | CallFunction 0
  0008    | Destructure 25: V1
  0010    | TakeRight 10 -> 36
  0013    | GetBoundLocal 3
  0015    | CallFunction 0
  0017    | Destructure 26: V2
  0019    | TakeRight 19 -> 36
  0022    | GetConstant 119: {_0_, _1_}
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 4
  0028    | InsertKeyVal 0
  0030    | GetBoundLocal 2
  0032    | GetBoundLocal 5
  0034    | InsertKeyVal 1
  0036    | End
  ========================================
  
  ==============record2_sep===============
  record2_sep(Key1, value1, sep, Key2, value2) =
    value1 -> V1 & sep &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | GetConstant 117: V1
  0002    | GetConstant 118: V2
  0004    | GetBoundLocal 1
  0006    | CallFunction 0
  0008    | Destructure 27: V1
  0010    | TakeRight 10 -> 17
  0013    | GetBoundLocal 2
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 43
  0020    | GetBoundLocal 4
  0022    | CallFunction 0
  0024    | Destructure 28: V2
  0026    | TakeRight 26 -> 43
  0029    | GetConstant 120: {_0_, _1_}
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 5
  0035    | InsertKeyVal 0
  0037    | GetBoundLocal 3
  0039    | GetBoundLocal 6
  0041    | InsertKeyVal 1
  0043    | End
  ========================================
  
  ================record3=================
  record3(Key1, value1, Key2, value2, Key3, value3) =
    value1 -> V1 &
    value2 -> V2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | GetConstant 117: V1
  0002    | GetConstant 118: V2
  0004    | GetConstant 121: V3
  0006    | GetBoundLocal 1
  0008    | CallFunction 0
  0010    | Destructure 29: V1
  0012    | TakeRight 12 -> 21
  0015    | GetBoundLocal 3
  0017    | CallFunction 0
  0019    | Destructure 30: V2
  0021    | TakeRight 21 -> 53
  0024    | GetBoundLocal 5
  0026    | CallFunction 0
  0028    | Destructure 31: V3
  0030    | TakeRight 30 -> 53
  0033    | GetConstant 122: {_0_, _1_, _2_}
  0035    | GetBoundLocal 0
  0037    | GetBoundLocal 6
  0039    | InsertKeyVal 0
  0041    | GetBoundLocal 2
  0043    | GetBoundLocal 7
  0045    | InsertKeyVal 1
  0047    | GetBoundLocal 4
  0049    | GetBoundLocal 8
  0051    | InsertKeyVal 2
  0053    | End
  ========================================
  
  ==============record3_sep===============
  record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3) =
    value1 -> V1 & sep1 &
    value2 -> V2 & sep2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | GetConstant 117: V1
  0002    | GetConstant 118: V2
  0004    | GetConstant 121: V3
  0006    | GetBoundLocal 1
  0008    | CallFunction 0
  0010    | Destructure 32: V1
  0012    | TakeRight 12 -> 19
  0015    | GetBoundLocal 2
  0017    | CallFunction 0
  0019    | TakeRight 19 -> 28
  0022    | GetBoundLocal 4
  0024    | CallFunction 0
  0026    | Destructure 33: V2
  0028    | TakeRight 28 -> 35
  0031    | GetBoundLocal 5
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 67
  0038    | GetBoundLocal 7
  0040    | CallFunction 0
  0042    | Destructure 34: V3
  0044    | TakeRight 44 -> 67
  0047    | GetConstant 123: {_0_, _1_, _2_}
  0049    | GetBoundLocal 0
  0051    | GetBoundLocal 8
  0053    | InsertKeyVal 0
  0055    | GetBoundLocal 3
  0057    | GetBoundLocal 9
  0059    | InsertKeyVal 1
  0061    | GetBoundLocal 6
  0063    | GetBoundLocal 10
  0065    | InsertKeyVal 2
  0067    | End
  ========================================
  
  ==================many==================
  many(p) = p * 1..
  ========================================
  0000    | Null
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 23
  0006    | Swap
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 39
  0015    | Swap
  0016    | Decrement
  0017    | JumpIfZero 17 -> 23
  0020    | JumpBack 20 -> 6
  0023    | Swap
  0024    | SetInputMark
  0025    | GetBoundLocal 0
  0027    | CallFunction 0
  0029    | JumpIfFailure 29 -> 37
  0032    | PopInputMark
  0033    | Merge
  0034    | JumpBack 34 -> 24
  0037    | ResetInput
  0038    | Drop
  0039    | Swap
  0040    | Drop
  0041    | End
  ========================================
  
  ================many_sep================
  many_sep(p, sep) = p + ((sep > p) * 0..)
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | Null
  0005    | PushNumberZero
  0006    | ValidateRepeatPattern
  0007    | JumpIfZero 7 -> 34
  0010    | Swap
  0011    | GetBoundLocal 1
  0013    | CallFunction 0
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocal 0
  0020    | CallFunction 0
  0022    | Merge
  0023    | JumpIfFailure 23 -> 57
  0026    | Swap
  0027    | Decrement
  0028    | JumpIfZero 28 -> 34
  0031    | JumpBack 31 -> 10
  0034    | Swap
  0035    | SetInputMark
  0036    | GetBoundLocal 1
  0038    | CallFunction 0
  0040    | TakeRight 40 -> 47
  0043    | GetBoundLocal 0
  0045    | CallFunction 0
  0047    | JumpIfFailure 47 -> 55
  0050    | PopInputMark
  0051    | Merge
  0052    | JumpBack 52 -> 35
  0055    | ResetInput
  0056    | Drop
  0057    | Swap
  0058    | Drop
  0059    | Merge
  0060    | End
  ========================================
  
  ===============many_until===============
  many_until(p, stop) = unless(p, stop) * 1.. < peek(stop)
  ========================================
  0000    | Null
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 7: unless
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
  0029    | GetConstant 7: unless
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
  0052    | GetConstant 61: peek
  0054    | GetBoundLocal 1
  0056    | CallFunction 1
  0058    | TakeLeft
  0059    | End
  ========================================
  
  ===============maybe_many===============
  maybe_many(p) = p * 0..
  ========================================
  0000    | Null
  0001    | PushNumberZero
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 23
  0006    | Swap
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 39
  0015    | Swap
  0016    | Decrement
  0017    | JumpIfZero 17 -> 23
  0020    | JumpBack 20 -> 6
  0023    | Swap
  0024    | SetInputMark
  0025    | GetBoundLocal 0
  0027    | CallFunction 0
  0029    | JumpIfFailure 29 -> 37
  0032    | PopInputMark
  0033    | Merge
  0034    | JumpBack 34 -> 24
  0037    | ResetInput
  0038    | Drop
  0039    | Swap
  0040    | Drop
  0041    | End
  ========================================
  
  =============maybe_many_sep=============
  maybe_many_sep(p, sep) = many_sep(p, sep) | succeed
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 124: many_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | Or 9 -> 16
  0012    | GetConstant 125: succeed
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ==================peek==================
  peek(p) = p -> V ! const(V)
  ========================================
  0000    | PushCharVar V
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | Destructure 35: V
  0009    | Backtrack 9 -> 18
  0012    | GetConstant 93: const
  0014    | GetBoundLocal 1
  0016    | CallTailFunction 1
  0018    | End
  ========================================
  
  =================maybe==================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 125: succeed
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================unless=================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 1
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 126: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 19
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  ==================skip==================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 127: null
  0002    | GetBoundLocal 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================find==================
  find(p) = p | (char > find(p))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 21
  0008    | GetConstant 8: char
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 21
  0015    | GetConstant 128: find
  0017    | GetBoundLocal 0
  0019    | CallTailFunction 1
  0021    | End
  ========================================
  
  =================@fn732=================
  find(p)
  ========================================
  0000    | PushCharVar p
  0002    | SetClosureCaptures
  0003    | GetConstant 128: find
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn733=================
  many(char)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 8: char
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================find_all================
  find_all(p) = array(find(p)) < maybe(many(char))
  ========================================
  0000    | GetConstant 45: array
  0002    | GetConstant 129: @fn732
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 20
  0013    | GetConstant 30: maybe
  0015    | GetConstant 130: @fn733
  0017    | CallFunction 1
  0019    | TakeLeft
  0020    | End
  ========================================
  
  ==============find_before===============
  find_before(p, stop) = stop ? @fail : p | (char > find_before(p, stop))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 1
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 126: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 38
  0015    | SetInputMark
  0016    | GetBoundLocal 0
  0018    | CallFunction 0
  0020    | Or 20 -> 38
  0023    | GetConstant 8: char
  0025    | CallFunction 0
  0027    | TakeRight 27 -> 38
  0030    | GetConstant 131: find_before
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallTailFunction 2
  0038    | End
  ========================================
  
  =================@fn734=================
  find_before(p, stop)
  ========================================
  0000    | PushCharVar p
  0002    | GetConstant 133: stop
  0004    | SetClosureCaptures
  0005    | GetConstant 131: find_before
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn735=================
  chars_until(stop)
  ========================================
  0000    | GetConstant 133: stop
  0002    | SetClosureCaptures
  0003    | GetConstant 11: chars_until
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ============find_all_before=============
  find_all_before(p, stop) = array(find_before(p, stop)) < maybe(chars_until(stop))
  ========================================
  0000    | GetConstant 45: array
  0002    | GetConstant 132: @fn734
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 26
  0015    | GetConstant 30: maybe
  0017    | GetConstant 134: @fn735
  0019    | CreateClosure 1
  0021    | CaptureLocal 1
  0023    | CallFunction 1
  0025    | TakeLeft
  0026    | End
  ========================================
  
  ================succeed=================
  succeed = const($null)
  ========================================
  0000    | GetConstant 93: const
  0002    | Null
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ================default=================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 14
  0008    | GetConstant 93: const
  0010    | GetBoundLocal 1
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | PushEmptyString
  0001    | CallFunction 0
  0003    | TakeRight 3 -> 8
  0006    | GetBoundLocal 0
  0008    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushCharVar N
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 36: "%(0 + N)"
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 1
  0013    | End
  ========================================
  
  ===============as_string================
  as_string(p) = "%(p)"
  ========================================
  0000    | PushEmptyString
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | MergeAsString
  0006    | End
  ========================================
  
  ================surround================
  surround(p, fill) = fill > p < fill
  ========================================
  0000    | GetBoundLocal 1
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  ==============end_of_input==============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 8: char
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 126: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 19
  0015    | GetConstant 125: succeed
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  =================@fn736=================
  maybe(whitespace)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  input(p) = surround(p, maybe(whitespace)) < end_of_input
  ========================================
  0000    | GetConstant 135: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant 136: @fn736
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 16
  0011    | GetConstant 14: end_of_input
  0013    | CallFunction 0
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ==============one_or_both===============
  one_or_both(a, b) = (a + maybe(b)) | (maybe(a) + b)
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | GetConstant 30: maybe
  0007    | GetBoundLocal 1
  0009    | CallFunction 1
  0011    | Merge
  0012    | Or 12 -> 26
  0015    | GetConstant 30: maybe
  0017    | GetBoundLocal 0
  0019    | CallFunction 1
  0021    | GetBoundLocal 1
  0023    | CallFunction 0
  0025    | Merge
  0026    | End
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
  0001    | GetConstant 137: json.boolean
  0003    | CallFunction 0
  0005    | Or 5 -> 48
  0008    | SetInputMark
  0009    | GetConstant 138: json.null
  0011    | CallFunction 0
  0013    | Or 13 -> 48
  0016    | SetInputMark
  0017    | GetConstant 139: number
  0019    | CallFunction 0
  0021    | Or 21 -> 48
  0024    | SetInputMark
  0025    | GetConstant 140: json.string
  0027    | CallFunction 0
  0029    | Or 29 -> 48
  0032    | SetInputMark
  0033    | GetConstant 141: json.array
  0035    | GetConstant 142: json
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042    | GetConstant 143: json.object
  0044    | GetConstant 142: json
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  ==============json.boolean==============
  json.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 144: boolean
  0002    | GetConstant 145: "true"
  0004    | GetConstant 146: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============json.null================
  json.null = null("null")
  ========================================
  0000    | GetConstant 127: null
  0002    | GetConstant 147: "null"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============json.string===============
  json.string = '"' > _json.string_body < '"'
  ========================================
  0000    | PushChar '"'
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 148: _json.string_body
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | PushChar '"'
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =================@fn738=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 153: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | PushChar '\'
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | PushChar '"'
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn737=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 150: _escaped_ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 24
  0008    | SetInputMark
  0009    | GetConstant 151: _escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 24
  0016    | GetConstant 7: unless
  0018    | GetConstant 8: char
  0020    | GetConstant 152: @fn738
  0022    | CallTailFunction 2
  0024    | End
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
  0001    | GetConstant 0: many
  0003    | GetConstant 149: @fn737
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 93: const
  0012    | PushEmptyString
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  ===============_ctrl_char===============
  _ctrl_char = "\u000000".."\u00001F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x1f' (esc)
  0003    | End
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
  0001    | GetConstant 154: "\""
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | PushChar '"'
  0010    | Or 10 -> 100
  0013    | SetInputMark
  0014    | GetConstant 155: "\\"
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 23
  0021    | PushChar '\'
  0023    | Or 23 -> 100
  0026    | SetInputMark
  0027    | GetConstant 156: "\/"
  0029    | CallFunction 0
  0031    | TakeRight 31 -> 36
  0034    | PushChar '/'
  0036    | Or 36 -> 100
  0039    | SetInputMark
  0040    | GetConstant 157: "\b"
  0042    | CallFunction 0
  0044    | TakeRight 44 -> 49
  0047    | PushChar '\x08' (esc)
  0049    | Or 49 -> 100
  0052    | SetInputMark
  0053    | GetConstant 158: "\f"
  0055    | CallFunction 0
  0057    | TakeRight 57 -> 62
  0060    | PushChar '\x0c' (esc)
  0062    | Or 62 -> 100
  0065    | SetInputMark
  0066    | GetConstant 159: "\n"
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 75
  0073    | PushChar '
  '
  0075    | Or 75 -> 100
  0078    | SetInputMark
  0079    | GetConstant 160: "\r"
  0081    | CallFunction 0
  0083    | TakeRight 83 -> 88
  0086    | PushChar '\r (no-eol) (esc)
  '
  0088    | Or 88 -> 100
  0091    | GetConstant 161: "\t"
  0093    | CallFunction 0
  0095    | TakeRight 95 -> 100
  0098    | PushChar '\t' (esc)
  0100    | End
  ========================================
  
  ============_escaped_unicode============
  _escaped_unicode = _escaped_surrogate_pair | _escaped_codepoint
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 162: _escaped_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 163: _escaped_codepoint
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========_escaped_surrogate_pair=========
  _escaped_surrogate_pair = _valid_surrogate_pair | _invalid_surrogate_pair
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 164: _valid_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 165: _invalid_surrogate_pair
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_valid_surrogate_pair==========
  _valid_surrogate_pair =
    _high_surrogate -> H & _low_surrogate -> L $ @SurrogatePairCodepoint(H, L)
  ========================================
  0000    | PushCharVar H
  0002    | PushCharVar L
  0004    | GetConstant 166: _high_surrogate
  0006    | CallFunction 0
  0008    | Destructure 37: H
  0010    | TakeRight 10 -> 30
  0013    | GetConstant 167: _low_surrogate
  0015    | CallFunction 0
  0017    | Destructure 38: L
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 168: @SurrogatePairCodepoint
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ========_invalid_surrogate_pair=========
  _invalid_surrogate_pair = _low_surrogate | _high_surrogate $ "\u00FFFD"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 167: _low_surrogate
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 166: _high_surrogate
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 17
  0015    | GetConstant 169: "\xef\xbf\xbd" (esc)
  0017    | End
  ========================================
  
  ============_high_surrogate=============
  _high_surrogate =
    `\u` > ("D" | "d") + ("8" | "9" | "A" | "B" | "a" | "b") + hex_numeral + hex_numeral
  ========================================
  0000    | GetConstant 170: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | PushChar 'D'
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | PushChar 'd'
  0017    | CallFunction 0
  0019    | SetInputMark
  0020    | PushChar '8'
  0022    | CallFunction 0
  0024    | Or 24 -> 63
  0027    | SetInputMark
  0028    | PushChar '9'
  0030    | CallFunction 0
  0032    | Or 32 -> 63
  0035    | SetInputMark
  0036    | PushChar 'A'
  0038    | CallFunction 0
  0040    | Or 40 -> 63
  0043    | SetInputMark
  0044    | PushChar 'B'
  0046    | CallFunction 0
  0048    | Or 48 -> 63
  0051    | SetInputMark
  0052    | PushChar 'a'
  0054    | CallFunction 0
  0056    | Or 56 -> 63
  0059    | PushChar 'b'
  0061    | CallFunction 0
  0063    | Merge
  0064    | GetConstant 171: hex_numeral
  0066    | CallFunction 0
  0068    | Merge
  0069    | GetConstant 171: hex_numeral
  0071    | CallFunction 0
  0073    | Merge
  0074    | End
  ========================================
  
  =============_low_surrogate=============
  _low_surrogate =
    `\u` > ("D" | "d") + ("C".."F" | "c".."f") + hex_numeral + hex_numeral
  ========================================
  0000    | GetConstant 170: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | PushChar 'D'
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | PushChar 'd'
  0017    | CallFunction 0
  0019    | SetInputMark
  0020    | ParseCodepointRange 'C'..'F'
  0023    | Or 23 -> 29
  0026    | ParseCodepointRange 'c'..'f'
  0029    | Merge
  0030    | GetConstant 171: hex_numeral
  0032    | CallFunction 0
  0034    | Merge
  0035    | GetConstant 171: hex_numeral
  0037    | CallFunction 0
  0039    | Merge
  0040    | End
  ========================================
  
  ===========_escaped_codepoint===========
  _escaped_codepoint = `\u` > (hex_numeral * 4) -> U $ @Codepoint(U)
  ========================================
  0000    | PushCharVar U
  0002    | GetConstant 170: "\u"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 35
  0009    | Null
  0010    | PushNumber 4
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 34
  0016    | Swap
  0017    | GetConstant 171: hex_numeral
  0019    | CallFunction 0
  0021    | Merge
  0022    | JumpIfFailure 22 -> 33
  0025    | Swap
  0026    | Decrement
  0027    | JumpIfZero 27 -> 34
  0030    | JumpBack 30 -> 16
  0033    | Swap
  0034    | Drop
  0035    | Destructure 39: U
  0037    | TakeRight 37 -> 46
  0040    | GetConstant 172: @Codepoint
  0042    | GetBoundLocal 0
  0044    | CallTailFunction 1
  0046    | End
  ========================================
  
  =================@fn740=================
  maybe(ws)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn739=================
  surround(elem, maybe(ws))
  ========================================
  0000    | GetConstant 57: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 135: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 175: @fn740
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===============json.array===============
  json.array(elem) = "[" > maybe_array_sep(surround(elem, maybe(ws)), ",") < "]"
  ========================================
  0000    | PushChar '['
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | GetConstant 173: maybe_array_sep
  0009    | GetConstant 174: @fn739
  0011    | CreateClosure 1
  0013    | CaptureLocal 0
  0015    | PushChar ','
  0017    | CallFunction 2
  0019    | JumpIfFailure 19 -> 27
  0022    | PushChar ']'
  0024    | CallFunction 0
  0026    | TakeLeft
  0027    | End
  ========================================
  
  =================@fn742=================
  maybe(ws)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn741=================
  surround(json.string, maybe(ws))
  ========================================
  0000    | GetConstant 135: surround
  0002    | GetConstant 140: json.string
  0004    | GetConstant 178: @fn742
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn744=================
  maybe(ws)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn743=================
  surround(value, maybe(ws))
  ========================================
  0000    | GetConstant 106: value
  0002    | SetClosureCaptures
  0003    | GetConstant 135: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 180: @fn744
  0009    | CallTailFunction 2
  0011    | End
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
  0000    | PushChar '{'
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 23
  0007    | GetConstant 176: maybe_object_sep
  0009    | GetConstant 177: @fn741
  0011    | PushChar ':'
  0013    | GetConstant 179: @fn743
  0015    | CreateClosure 1
  0017    | CaptureLocal 0
  0019    | PushChar ','
  0021    | CallFunction 4
  0023    | JumpIfFailure 23 -> 31
  0026    | PushChar '}'
  0028    | CallFunction 0
  0030    | TakeLeft
  0031    | End
  ========================================
  
  ==============toml.simple===============
  toml.simple = toml.custom(toml.simple_value)
  ========================================
  0000    | GetConstant 181: toml.custom
  0002    | GetConstant 182: toml.simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============toml.tagged===============
  toml.tagged = toml.custom(toml.tagged_value)
  ========================================
  0000    | GetConstant 181: toml.custom
  0002    | GetConstant 183: toml.tagged_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn745=================
  _toml.comments + maybe(ws)
  ========================================
  0000    | GetConstant 186: _toml.comments
  0002    | CallFunction 0
  0004    | GetConstant 30: maybe
  0006    | GetConstant 9: whitespace
  0008    | CallFunction 1
  0010    | Merge
  0011    | End
  ========================================
  
  =================@fn746=================
  maybe(ws) + _toml.comments
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallFunction 1
  0006    | GetConstant 186: _toml.comments
  0008    | CallFunction 0
  0010    | Merge
  0011    | End
  ========================================
  
  ==============toml.custom===============
  toml.custom(value) =
    maybe(_toml.comments + maybe(ws)) &
    _toml.with_root_table(value) | _toml.no_root_table(value) -> Doc &
    maybe(maybe(ws) + _toml.comments) $
    _Toml.Doc.Value(Doc)
  ========================================
  0000    | GetConstant 184: Doc
  0002    | GetConstant 30: maybe
  0004    | GetConstant 185: @fn745
  0006    | CallFunction 1
  0008    | TakeRight 8 -> 29
  0011    | SetInputMark
  0012    | GetConstant 187: _toml.with_root_table
  0014    | GetBoundLocal 0
  0016    | CallFunction 1
  0018    | Or 18 -> 27
  0021    | GetConstant 188: _toml.no_root_table
  0023    | GetBoundLocal 0
  0025    | CallFunction 1
  0027    | Destructure 40: Doc
  0029    | TakeRight 29 -> 47
  0032    | GetConstant 30: maybe
  0034    | GetConstant 189: @fn746
  0036    | CallFunction 1
  0038    | TakeRight 38 -> 47
  0041    | GetConstant 190: _Toml.Doc.Value
  0043    | GetBoundLocal 1
  0045    | CallTailFunction 1
  0047    | End
  ========================================
  
  =========_toml.with_root_table==========
  _toml.with_root_table(value) =
    _toml.root_table(value, _Toml.Doc.Empty) -> RootDoc &
    (_toml.ws > _toml.tables(value, RootDoc)) | const(RootDoc)
  ========================================
  0000    | GetConstant 191: RootDoc
  0002    | GetConstant 192: _toml.root_table
  0004    | GetBoundLocal 0
  0006    | GetConstant 193: _Toml.Doc.Empty
  0008    | CallFunction 0
  0010    | CallFunction 2
  0012    | Destructure 41: RootDoc
  0014    | TakeRight 14 -> 42
  0017    | SetInputMark
  0018    | GetConstant 194: _toml.ws
  0020    | CallFunction 0
  0022    | TakeRight 22 -> 33
  0025    | GetConstant 195: _toml.tables
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 1
  0031    | CallFunction 2
  0033    | Or 33 -> 42
  0036    | GetConstant 93: const
  0038    | GetBoundLocal 1
  0040    | CallTailFunction 1
  0042    | End
  ========================================
  
  ============_toml.root_table============
  _toml.root_table(value, Doc) =
    _toml.table_body(value, [], Doc)
  ========================================
  0000    | GetConstant 196: _toml.table_body
  0002    | GetBoundLocal 0
  0004    | PushEmptyArray
  0005    | GetBoundLocal 1
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ==========_toml.no_root_table===========
  _toml.no_root_table(value) =
    _toml.table(value, _Toml.Doc.Empty) | _toml.array_of_tables(value, _Toml.Doc.Empty) -> NewDoc &
    _toml.tables(value, NewDoc)
  ========================================
  0000    | GetConstant 197: NewDoc
  0002    | SetInputMark
  0003    | GetConstant 198: _toml.table
  0005    | GetBoundLocal 0
  0007    | GetConstant 193: _Toml.Doc.Empty
  0009    | CallFunction 0
  0011    | CallFunction 2
  0013    | Or 13 -> 26
  0016    | GetConstant 199: _toml.array_of_tables
  0018    | GetBoundLocal 0
  0020    | GetConstant 193: _Toml.Doc.Empty
  0022    | CallFunction 0
  0024    | CallFunction 2
  0026    | Destructure 42: NewDoc
  0028    | TakeRight 28 -> 39
  0031    | GetConstant 195: _toml.tables
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | CallTailFunction 2
  0039    | End
  ========================================
  
  ==============_toml.tables==============
  _toml.tables(value, Doc) =
    _toml.ws >
    _toml.table(value, Doc) | _toml.array_of_tables(value, Doc) -> NewDoc ?
    _toml.tables(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant 197: NewDoc
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | GetConstant 194: _toml.ws
  0006    | CallFunction 0
  0008    | TakeRight 8 -> 19
  0011    | GetConstant 198: _toml.table
  0013    | GetBoundLocal 0
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | Or 19 -> 30
  0022    | GetConstant 199: _toml.array_of_tables
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | CallFunction 2
  0030    | Destructure 43: NewDoc
  0032    | ConditionalThen 32 -> 46
  0035    | GetConstant 195: _toml.tables
  0037    | GetBoundLocal 0
  0039    | GetBoundLocal 2
  0041    | CallTailFunction 2
  0043    | Jump 43 -> 52
  0046    | GetConstant 93: const
  0048    | GetBoundLocal 1
  0050    | CallTailFunction 1
  0052    | End
  ========================================
  
  ==============_toml.table===============
  _toml.table(value, Doc) =
    _toml.table_header -> HeaderPath & _toml.ws_newline & (
      _toml.table_body(value, HeaderPath, Doc) |
      const(_Toml.Doc.EnsureTableAtPath(Doc, HeaderPath))
    )
  ========================================
  0000    | GetConstant 200: HeaderPath
  0002    | GetConstant 201: _toml.table_header
  0004    | CallFunction 0
  0006    | Destructure 44: HeaderPath
  0008    | TakeRight 8 -> 15
  0011    | GetConstant 202: _toml.ws_newline
  0013    | CallFunction 0
  0015    | TakeRight 15 -> 44
  0018    | SetInputMark
  0019    | GetConstant 196: _toml.table_body
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 2
  0025    | GetBoundLocal 1
  0027    | CallFunction 3
  0029    | Or 29 -> 44
  0032    | GetConstant 93: const
  0034    | GetConstant 203: _Toml.Doc.EnsureTableAtPath
  0036    | GetBoundLocal 1
  0038    | GetBoundLocal 2
  0040    | CallFunction 2
  0042    | CallTailFunction 1
  0044    | End
  ========================================
  
  =================@fn747=================
  _toml.table_body(value, [], _Toml.Doc.Empty)
  ========================================
  0000    | GetConstant 106: value
  0002    | SetClosureCaptures
  0003    | GetConstant 196: _toml.table_body
  0005    | GetBoundLocal 0
  0007    | PushEmptyArray
  0008    | GetConstant 193: _Toml.Doc.Empty
  0010    | CallFunction 0
  0012    | CallTailFunction 3
  0014    | End
  ========================================
  
  =========_toml.array_of_tables==========
  _toml.array_of_tables(value, Doc) =
    _toml.array_of_tables_header -> HeaderPath & _toml.ws_newline &
    default(_toml.table_body(value, [], _Toml.Doc.Empty), _Toml.Doc.Empty) -> InnerDoc $
    _Toml.Doc.AppendAtPath(Doc, HeaderPath, _Toml.Doc.Value(InnerDoc))
  ========================================
  0000    | GetConstant 200: HeaderPath
  0002    | GetConstant 204: InnerDoc
  0004    | GetConstant 205: _toml.array_of_tables_header
  0006    | CallFunction 0
  0008    | Destructure 45: HeaderPath
  0010    | TakeRight 10 -> 17
  0013    | GetConstant 202: _toml.ws_newline
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 53
  0020    | GetConstant 62: default
  0022    | GetConstant 206: @fn747
  0024    | CreateClosure 1
  0026    | CaptureLocal 0
  0028    | GetConstant 193: _Toml.Doc.Empty
  0030    | CallFunction 0
  0032    | CallFunction 2
  0034    | Destructure 46: InnerDoc
  0036    | TakeRight 36 -> 53
  0039    | GetConstant 207: _Toml.Doc.AppendAtPath
  0041    | GetBoundLocal 1
  0043    | GetBoundLocal 2
  0045    | GetConstant 190: _Toml.Doc.Value
  0047    | GetBoundLocal 3
  0049    | CallFunction 1
  0051    | CallTailFunction 3
  0053    | End
  ========================================
  
  =================@fn748=================
  ws | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 9: whitespace
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 210: _toml.comment
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ================_toml.ws================
  _toml.ws = maybe_many(ws | _toml.comment)
  ========================================
  0000    | GetConstant 208: maybe_many
  0002    | GetConstant 209: @fn748
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn749=================
  spaces | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 212: spaces
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 210: _toml.comment
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =============_toml.ws_line==============
  _toml.ws_line = maybe_many(spaces | _toml.comment)
  ========================================
  0000    | GetConstant 208: maybe_many
  0002    | GetConstant 211: @fn749
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ============_toml.ws_newline============
  _toml.ws_newline = _toml.ws_line + (nl | end) + _toml.ws
  ========================================
  0000    | GetConstant 213: _toml.ws_line
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | GetConstant 13: newline
  0007    | CallFunction 0
  0009    | Or 9 -> 16
  0012    | GetConstant 14: end_of_input
  0014    | CallFunction 0
  0016    | Merge
  0017    | GetConstant 194: _toml.ws
  0019    | CallFunction 0
  0021    | Merge
  0022    | End
  ========================================
  
  =============_toml.comments=============
  _toml.comments = many_sep(_toml.comment, ws)
  ========================================
  0000    | GetConstant 124: many_sep
  0002    | GetConstant 210: _toml.comment
  0004    | GetConstant 9: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn750=================
  maybe(ws)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========_toml.table_header===========
  _toml.table_header = "[" > surround(_toml.path, maybe(ws)) < "]"
  ========================================
  0000    | PushChar '['
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 135: surround
  0009    | GetConstant 214: _toml.path
  0011    | GetConstant 215: @fn750
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | PushChar ']'
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
  ========================================
  
  =================@fn751=================
  maybe(ws)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ======_toml.array_of_tables_header======
  _toml.array_of_tables_header =
    "[[" > surround(_toml.path, maybe(ws)) < "]]"
  ========================================
  0000    | GetConstant 216: "[["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 135: surround
  0009    | GetConstant 214: _toml.path
  0011    | GetConstant 217: @fn751
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 218: "]]"
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
  ========================================
  
  ============_toml.table_body============
  _toml.table_body(value, HeaderPath, Doc) =
    _toml.table_pair(value) -> [KeyPath, Val] & _toml.ws_newline &
    const(_Toml.Doc.InsertAtPath(Doc, HeaderPath + KeyPath, Val)) -> NewDoc &
    _toml.table_body(value, HeaderPath, NewDoc) | const(NewDoc)
  ========================================
  0000    | GetConstant 219: KeyPath
  0002    | GetConstant 220: Val
  0004    | GetConstant 197: NewDoc
  0006    | GetConstant 221: _toml.table_pair
  0008    | GetBoundLocal 0
  0010    | CallFunction 1
  0012    | Destructure 47: [KeyPath, Val]
  0014    | TakeRight 14 -> 21
  0017    | GetConstant 202: _toml.ws_newline
  0019    | CallFunction 0
  0021    | TakeRight 21 -> 43
  0024    | GetConstant 93: const
  0026    | GetConstant 222: _Toml.Doc.InsertAtPath
  0028    | GetBoundLocal 2
  0030    | GetBoundLocal 1
  0032    | GetBoundLocal 3
  0034    | Merge
  0035    | GetBoundLocal 4
  0037    | CallFunction 3
  0039    | CallFunction 1
  0041    | Destructure 48: NewDoc
  0043    | TakeRight 43 -> 66
  0046    | SetInputMark
  0047    | GetConstant 196: _toml.table_body
  0049    | GetBoundLocal 0
  0051    | GetBoundLocal 1
  0053    | GetBoundLocal 5
  0055    | CallFunction 3
  0057    | Or 57 -> 66
  0060    | GetConstant 93: const
  0062    | GetBoundLocal 5
  0064    | CallTailFunction 1
  0066    | End
  ========================================
  
  =================@fn753=================
  maybe(spaces)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 212: spaces
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn752=================
  surround("=", maybe(spaces))
  ========================================
  0000    | GetConstant 135: surround
  0002    | PushChar '='
  0004    | GetConstant 225: @fn753
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_toml.table_pair============
  _toml.table_pair(value) =
    tuple2_sep(_toml.path, surround("=", maybe(spaces)), value)
  ========================================
  0000    | GetConstant 223: tuple2_sep
  0002    | GetConstant 214: _toml.path
  0004    | GetConstant 224: @fn752
  0006    | GetBoundLocal 0
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =================@fn755=================
  maybe(ws)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn754=================
  surround(".", maybe(ws))
  ========================================
  0000    | GetConstant 135: surround
  0002    | PushChar '.'
  0004    | GetConstant 228: @fn755
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============_toml.path===============
  _toml.path = array_sep(_toml.key, surround(".", maybe(ws)))
  ========================================
  0000    | GetConstant 65: array_sep
  0002    | GetConstant 226: _toml.key
  0004    | GetConstant 227: @fn754
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn756=================
  alpha | numeral | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 1: alpha
  0003    | CallFunction 0
  0005    | Or 5 -> 28
  0008    | SetInputMark
  0009    | GetConstant 4: numeral
  0011    | CallFunction 0
  0013    | Or 13 -> 28
  0016    | SetInputMark
  0017    | PushChar '_'
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | PushChar '-'
  0026    | CallFunction 0
  0028    | End
  ========================================
  
  ===============_toml.key================
  _toml.key =
    many(alpha | numeral | "_" | "-") |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetConstant 229: @fn756
  0005    | CallFunction 1
  0007    | Or 7 -> 22
  0010    | SetInputMark
  0011    | GetConstant 230: toml.string.basic
  0013    | CallFunction 0
  0015    | Or 15 -> 22
  0018    | GetConstant 231: toml.string.literal
  0020    | CallFunction 0
  0022    | End
  ========================================
  
  =============_toml.comment==============
  _toml.comment = "#" > maybe(line)
  ========================================
  0000    | PushChar '#'
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 30: maybe
  0009    | GetConstant 232: line
  0011    | CallTailFunction 1
  0013    | End
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
  0001    | GetConstant 233: toml.string
  0003    | CallFunction 0
  0005    | Or 5 -> 48
  0008    | SetInputMark
  0009    | GetConstant 234: toml.datetime
  0011    | CallFunction 0
  0013    | Or 13 -> 48
  0016    | SetInputMark
  0017    | GetConstant 235: toml.number
  0019    | CallFunction 0
  0021    | Or 21 -> 48
  0024    | SetInputMark
  0025    | GetConstant 236: toml.boolean
  0027    | CallFunction 0
  0029    | Or 29 -> 48
  0032    | SetInputMark
  0033    | GetConstant 237: toml.array
  0035    | GetConstant 182: toml.simple_value
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042    | GetConstant 238: toml.inline_table
  0044    | GetConstant 182: toml.simple_value
  0046    | CallTailFunction 1
  0048    | End
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
  0001    | GetConstant 233: toml.string
  0003    | CallFunction 0
  0005    | Or 5 -> 159
  0008    | SetInputMark
  0009    | GetConstant 239: _toml.tag
  0011    | GetConstant 240: "datetime"
  0013    | GetConstant 241: "offset"
  0015    | GetConstant 242: toml.datetime.offset
  0017    | CallFunction 3
  0019    | Or 19 -> 159
  0022    | SetInputMark
  0023    | GetConstant 239: _toml.tag
  0025    | GetConstant 240: "datetime"
  0027    | GetConstant 243: "local"
  0029    | GetConstant 244: toml.datetime.local
  0031    | CallFunction 3
  0033    | Or 33 -> 159
  0036    | SetInputMark
  0037    | GetConstant 239: _toml.tag
  0039    | GetConstant 240: "datetime"
  0041    | GetConstant 245: "date-local"
  0043    | GetConstant 246: toml.datetime.local_date
  0045    | CallFunction 3
  0047    | Or 47 -> 159
  0050    | SetInputMark
  0051    | GetConstant 239: _toml.tag
  0053    | GetConstant 240: "datetime"
  0055    | GetConstant 247: "time-local"
  0057    | GetConstant 248: toml.datetime.local_time
  0059    | CallFunction 3
  0061    | Or 61 -> 159
  0064    | SetInputMark
  0065    | GetConstant 249: toml.number.binary_integer
  0067    | CallFunction 0
  0069    | Or 69 -> 159
  0072    | SetInputMark
  0073    | GetConstant 250: toml.number.octal_integer
  0075    | CallFunction 0
  0077    | Or 77 -> 159
  0080    | SetInputMark
  0081    | GetConstant 251: toml.number.hex_integer
  0083    | CallFunction 0
  0085    | Or 85 -> 159
  0088    | SetInputMark
  0089    | GetConstant 239: _toml.tag
  0091    | GetConstant 252: "float"
  0093    | GetConstant 253: "infinity"
  0095    | GetConstant 254: toml.number.infinity
  0097    | CallFunction 3
  0099    | Or 99 -> 159
  0102    | SetInputMark
  0103    | GetConstant 239: _toml.tag
  0105    | GetConstant 252: "float"
  0107    | GetConstant 255: "not-a-number"
  0109    | GetConstant2 256: toml.number.not_a_number
  0112    | CallFunction 3
  0114    | Or 114 -> 159
  0117    | SetInputMark
  0118    | GetConstant2 257: toml.number.float
  0121    | CallFunction 0
  0123    | Or 123 -> 159
  0126    | SetInputMark
  0127    | GetConstant2 258: toml.number.integer
  0130    | CallFunction 0
  0132    | Or 132 -> 159
  0135    | SetInputMark
  0136    | GetConstant 236: toml.boolean
  0138    | CallFunction 0
  0140    | Or 140 -> 159
  0143    | SetInputMark
  0144    | GetConstant 237: toml.array
  0146    | GetConstant 183: toml.tagged_value
  0148    | CallFunction 1
  0150    | Or 150 -> 159
  0153    | GetConstant 238: toml.inline_table
  0155    | GetConstant 183: toml.tagged_value
  0157    | CallTailFunction 1
  0159    | End
  ========================================
  
  ===============_toml.tag================
  _toml.tag(Type, Subtype, value) =
    value -> Value $ {"type": Type, "subtype": Subtype, "value": Value}
  ========================================
  0000    | GetConstant 115: Value
  0002    | GetBoundLocal 2
  0004    | CallFunction 0
  0006    | Destructure 49: Value
  0008    | TakeRight 8 -> 35
  0011    | GetConstant2 259: {_0_, _1_, _2_}
  0014    | GetConstant2 260: "type"
  0017    | GetBoundLocal 0
  0019    | InsertKeyVal 0
  0021    | GetConstant2 261: "subtype"
  0024    | GetBoundLocal 1
  0026    | InsertKeyVal 1
  0028    | GetConstant2 262: "value"
  0031    | GetBoundLocal 3
  0033    | InsertKeyVal 2
  0035    | End
  ========================================
  
  ==============toml.string===============
  toml.string =
    toml.string.multi_line_basic |
    toml.string.multi_line_literal |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 263: toml.string.multi_line_basic
  0004    | CallFunction 0
  0006    | Or 6 -> 30
  0009    | SetInputMark
  0010    | GetConstant2 264: toml.string.multi_line_literal
  0013    | CallFunction 0
  0015    | Or 15 -> 30
  0018    | SetInputMark
  0019    | GetConstant 230: toml.string.basic
  0021    | CallFunction 0
  0023    | Or 23 -> 30
  0026    | GetConstant 231: toml.string.literal
  0028    | CallFunction 0
  0030    | End
  ========================================
  
  =============toml.datetime==============
  toml.datetime =
    toml.datetime.offset |
    toml.datetime.local |
    toml.datetime.local_date |
    toml.datetime.local_time
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 242: toml.datetime.offset
  0003    | CallFunction 0
  0005    | Or 5 -> 28
  0008    | SetInputMark
  0009    | GetConstant 244: toml.datetime.local
  0011    | CallFunction 0
  0013    | Or 13 -> 28
  0016    | SetInputMark
  0017    | GetConstant 246: toml.datetime.local_date
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 248: toml.datetime.local_time
  0026    | CallFunction 0
  0028    | End
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
  0001    | GetConstant 249: toml.number.binary_integer
  0003    | CallFunction 0
  0005    | Or 5 -> 55
  0008    | SetInputMark
  0009    | GetConstant 250: toml.number.octal_integer
  0011    | CallFunction 0
  0013    | Or 13 -> 55
  0016    | SetInputMark
  0017    | GetConstant 251: toml.number.hex_integer
  0019    | CallFunction 0
  0021    | Or 21 -> 55
  0024    | SetInputMark
  0025    | GetConstant 254: toml.number.infinity
  0027    | CallFunction 0
  0029    | Or 29 -> 55
  0032    | SetInputMark
  0033    | GetConstant2 256: toml.number.not_a_number
  0036    | CallFunction 0
  0038    | Or 38 -> 55
  0041    | SetInputMark
  0042    | GetConstant2 257: toml.number.float
  0045    | CallFunction 0
  0047    | Or 47 -> 55
  0050    | GetConstant2 258: toml.number.integer
  0053    | CallFunction 0
  0055    | End
  ========================================
  
  ==============toml.boolean==============
  toml.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 144: boolean
  0002    | GetConstant 145: "true"
  0004    | GetConstant 146: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn759=================
  surround(elem, _toml.ws)
  ========================================
  0000    | GetConstant 57: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 135: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 194: _toml.ws
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn760=================
  surround(",", _toml.ws)
  ========================================
  0000    | GetConstant 135: surround
  0002    | PushChar ','
  0004    | GetConstant 194: _toml.ws
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn758=================
  array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws))
  ========================================
  0000    | GetConstant 57: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 65: array_sep
  0005    | GetConstant2 266: @fn759
  0008    | CreateClosure 1
  0010    | CaptureLocal 0
  0012    | PushChar ','
  0014    | CallFunction 2
  0016    | JumpIfFailure 16 -> 27
  0019    | GetConstant 30: maybe
  0021    | GetConstant2 267: @fn760
  0024    | CallFunction 1
  0026    | TakeLeft
  0027    | End
  ========================================
  
  ===============toml.array===============
  toml.array(elem) =
    "[" > _toml.ws > default(
      array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws)),
      []
    ) < _toml.ws < "]"
  ========================================
  0000    | PushChar '['
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 194: _toml.ws
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 26
  0014    | GetConstant 62: default
  0016    | GetConstant2 265: @fn758
  0019    | CreateClosure 1
  0021    | CaptureLocal 0
  0023    | PushEmptyArray
  0024    | CallFunction 2
  0026    | JumpIfFailure 26 -> 34
  0029    | GetConstant 194: _toml.ws
  0031    | CallFunction 0
  0033    | TakeLeft
  0034    | JumpIfFailure 34 -> 42
  0037    | PushChar ']'
  0039    | CallFunction 0
  0041    | TakeLeft
  0042    | End
  ========================================
  
  ===========toml.inline_table============
  toml.inline_table(value) =
    _toml.empty_inline_table | _toml.nonempty_inline_table(value) -> InlineDoc $
    _Toml.Doc.Value(InlineDoc)
  ========================================
  0000    | GetConstant2 268: InlineDoc
  0003    | SetInputMark
  0004    | GetConstant2 269: _toml.empty_inline_table
  0007    | CallFunction 0
  0009    | Or 9 -> 19
  0012    | GetConstant2 270: _toml.nonempty_inline_table
  0015    | GetBoundLocal 0
  0017    | CallFunction 1
  0019    | Destructure 50: InlineDoc
  0021    | TakeRight 21 -> 30
  0024    | GetConstant 190: _Toml.Doc.Value
  0026    | GetBoundLocal 1
  0028    | CallTailFunction 1
  0030    | End
  ========================================
  
  ========_toml.empty_inline_table========
  _toml.empty_inline_table = "{" > maybe(spaces) < "}" $ _Toml.Doc.Empty
  ========================================
  0000    | PushChar '{'
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 30: maybe
  0009    | GetConstant 212: spaces
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 21
  0016    | PushChar '}'
  0018    | CallFunction 0
  0020    | TakeLeft
  0021    | TakeRight 21 -> 28
  0024    | GetConstant 193: _Toml.Doc.Empty
  0026    | CallTailFunction 0
  0028    | End
  ========================================
  
  ======_toml.nonempty_inline_table=======
  _toml.nonempty_inline_table(value) =
    "{" > maybe(spaces) >
    _toml.inline_table_pair(value, _Toml.Doc.Empty) -> DocWithFirstPair &
    _toml.inline_table_body(value, DocWithFirstPair)
    < maybe(spaces) < "}"
  ========================================
  0000    | GetConstant2 271: DocWithFirstPair
  0003    | PushChar '{'
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 16
  0010    | GetConstant 30: maybe
  0012    | GetConstant 212: spaces
  0014    | CallFunction 1
  0016    | TakeRight 16 -> 30
  0019    | GetConstant2 272: _toml.inline_table_pair
  0022    | GetBoundLocal 0
  0024    | GetConstant 193: _Toml.Doc.Empty
  0026    | CallFunction 0
  0028    | CallFunction 2
  0030    | Destructure 51: DocWithFirstPair
  0032    | TakeRight 32 -> 62
  0035    | GetConstant2 273: _toml.inline_table_body
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 1
  0042    | CallFunction 2
  0044    | JumpIfFailure 44 -> 54
  0047    | GetConstant 30: maybe
  0049    | GetConstant 212: spaces
  0051    | CallFunction 1
  0053    | TakeLeft
  0054    | JumpIfFailure 54 -> 62
  0057    | PushChar '}'
  0059    | CallFunction 0
  0061    | TakeLeft
  0062    | End
  ========================================
  
  ========_toml.inline_table_body=========
  _toml.inline_table_body(value, Doc) =
    "," > _toml.inline_table_pair(value, Doc) -> NewDoc ?
    _toml.inline_table_body(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant 197: NewDoc
  0002    | SetInputMark
  0003    | PushChar ','
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 19
  0010    | GetConstant2 272: _toml.inline_table_pair
  0013    | GetBoundLocal 0
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | Destructure 52: NewDoc
  0021    | ConditionalThen 21 -> 36
  0024    | GetConstant2 273: _toml.inline_table_body
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 2
  0031    | CallTailFunction 2
  0033    | Jump 33 -> 42
  0036    | GetConstant 93: const
  0038    | GetBoundLocal 1
  0040    | CallTailFunction 1
  0042    | End
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
  0000    | GetConstant2 274: Key
  0003    | GetConstant 220: Val
  0005    | GetConstant 30: maybe
  0007    | GetConstant 212: spaces
  0009    | CallFunction 1
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 214: _toml.path
  0016    | CallFunction 0
  0018    | Destructure 53: Key
  0020    | TakeRight 20 -> 29
  0023    | GetConstant 30: maybe
  0025    | GetConstant 212: spaces
  0027    | CallFunction 1
  0029    | TakeRight 29 -> 36
  0032    | PushChar '='
  0034    | CallFunction 0
  0036    | TakeRight 36 -> 45
  0039    | GetConstant 30: maybe
  0041    | GetConstant 212: spaces
  0043    | CallFunction 1
  0045    | TakeRight 45 -> 54
  0048    | GetBoundLocal 0
  0050    | CallFunction 0
  0052    | Destructure 54: Val
  0054    | TakeRight 54 -> 76
  0057    | GetConstant 30: maybe
  0059    | GetConstant 212: spaces
  0061    | CallFunction 1
  0063    | TakeRight 63 -> 76
  0066    | GetConstant 222: _Toml.Doc.InsertAtPath
  0068    | GetBoundLocal 1
  0070    | GetBoundLocal 2
  0072    | GetBoundLocal 3
  0074    | CallTailFunction 3
  0076    | End
  ========================================
  
  =================@fn761=================
  maybe(nl)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn764=================
  _ctrl_char | `\`
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 153: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar '\'
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================@fn763=================
  _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 280: _toml.escaped_ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 54
  0009    | SetInputMark
  0010    | GetConstant2 281: _toml.escaped_unicode
  0013    | CallFunction 0
  0015    | Or 15 -> 54
  0018    | SetInputMark
  0019    | GetConstant 9: whitespace
  0021    | CallFunction 0
  0023    | Or 23 -> 54
  0026    | SetInputMark
  0027    | PushChar '\'
  0029    | CallFunction 0
  0031    | GetConstant 9: whitespace
  0033    | CallFunction 0
  0035    | Merge
  0036    | TakeRight 36 -> 42
  0039    | PushEmptyString
  0040    | CallFunction 0
  0042    | Or 42 -> 54
  0045    | GetConstant 7: unless
  0047    | GetConstant 8: char
  0049    | GetConstant2 282: @fn764
  0052    | CallTailFunction 2
  0054    | End
  ========================================
  
  =================@fn762=================
  many_until(
        _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`),
        `"""`
      )
  ========================================
  0000    | GetConstant 27: many_until
  0002    | GetConstant2 279: @fn763
  0005    | GetConstant2 276: """""
  0008    | CallTailFunction 2
  0010    | End
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
  0000    | GetConstant2 275: skip
  0003    | GetConstant2 276: """""
  0006    | CallFunction 1
  0008    | GetConstant2 275: skip
  0011    | GetConstant2 277: @fn761
  0014    | CallFunction 1
  0016    | Merge
  0017    | GetConstant 62: default
  0019    | GetConstant2 278: @fn762
  0022    | PushEmptyString
  0023    | CallFunction 2
  0025    | Merge
  0026    | GetConstant2 275: skip
  0029    | GetConstant2 276: """""
  0032    | CallFunction 1
  0034    | Merge
  0035    | Null
  0036    | PushNumberZero
  0037    | ValidateRepeatPattern
  0038    | JumpIfZero 38 -> 58
  0041    | Swap
  0042    | PushChar '"'
  0044    | CallFunction 0
  0046    | Merge
  0047    | JumpIfFailure 47 -> 88
  0050    | Swap
  0051    | Decrement
  0052    | JumpIfZero 52 -> 58
  0055    | JumpBack 55 -> 41
  0058    | Drop
  0059    | PushNumberTwo
  0060    | PushNumberZero
  0061    | NegateNumber
  0062    | Merge
  0063    | ValidateRepeatPattern
  0064    | JumpIfZero 64 -> 89
  0067    | Swap
  0068    | SetInputMark
  0069    | PushChar '"'
  0071    | CallFunction 0
  0073    | JumpIfFailure 73 -> 86
  0076    | PopInputMark
  0077    | Merge
  0078    | Swap
  0079    | Decrement
  0080    | JumpIfZero 80 -> 89
  0083    | JumpBack 83 -> 67
  0086    | ResetInput
  0087    | Drop
  0088    | Swap
  0089    | Drop
  0090    | Merge
  0091    | End
  ========================================
  
  =================@fn765=================
  maybe(nl)
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn766=================
  many_until(char, `'''`)
  ========================================
  0000    | GetConstant 27: many_until
  0002    | GetConstant 8: char
  0004    | GetConstant2 283: "'''"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  =====toml.string.multi_line_literal=====
  toml.string.multi_line_literal =
    skip(`'''`) + skip(maybe(nl)) +
    default(many_until(char, `'''`), $"")
    + skip(`'''`) + (`'` * 0..2)
  ========================================
  0000    | GetConstant2 275: skip
  0003    | GetConstant2 283: "'''"
  0006    | CallFunction 1
  0008    | GetConstant2 275: skip
  0011    | GetConstant2 284: @fn765
  0014    | CallFunction 1
  0016    | Merge
  0017    | GetConstant 62: default
  0019    | GetConstant2 285: @fn766
  0022    | PushEmptyString
  0023    | CallFunction 2
  0025    | Merge
  0026    | GetConstant2 275: skip
  0029    | GetConstant2 283: "'''"
  0032    | CallFunction 1
  0034    | Merge
  0035    | Null
  0036    | PushNumberZero
  0037    | ValidateRepeatPattern
  0038    | JumpIfZero 38 -> 58
  0041    | Swap
  0042    | PushChar '''
  0044    | CallFunction 0
  0046    | Merge
  0047    | JumpIfFailure 47 -> 88
  0050    | Swap
  0051    | Decrement
  0052    | JumpIfZero 52 -> 58
  0055    | JumpBack 55 -> 41
  0058    | Drop
  0059    | PushNumberTwo
  0060    | PushNumberZero
  0061    | NegateNumber
  0062    | Merge
  0063    | ValidateRepeatPattern
  0064    | JumpIfZero 64 -> 89
  0067    | Swap
  0068    | SetInputMark
  0069    | PushChar '''
  0071    | CallFunction 0
  0073    | JumpIfFailure 73 -> 86
  0076    | PopInputMark
  0077    | Merge
  0078    | Swap
  0079    | Decrement
  0080    | JumpIfZero 80 -> 89
  0083    | JumpBack 83 -> 67
  0086    | ResetInput
  0087    | Drop
  0088    | Swap
  0089    | Drop
  0090    | Merge
  0091    | End
  ========================================
  
  ===========toml.string.basic============
  toml.string.basic = '"' > _toml.string.basic_body < '"'
  ========================================
  0000    | PushChar '"'
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 12
  0007    | GetConstant2 286: _toml.string.basic_body
  0010    | CallFunction 0
  0012    | JumpIfFailure 12 -> 20
  0015    | PushChar '"'
  0017    | CallFunction 0
  0019    | TakeLeft
  0020    | End
  ========================================
  
  =================@fn768=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 153: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | PushChar '\'
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | PushChar '"'
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn767=================
  _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 280: _toml.escaped_ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 27
  0009    | SetInputMark
  0010    | GetConstant2 281: _toml.escaped_unicode
  0013    | CallFunction 0
  0015    | Or 15 -> 27
  0018    | GetConstant 7: unless
  0020    | GetConstant 8: char
  0022    | GetConstant2 288: @fn768
  0025    | CallTailFunction 2
  0027    | End
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
  0001    | GetConstant 0: many
  0003    | GetConstant2 287: @fn767
  0006    | CallFunction 1
  0008    | Or 8 -> 16
  0011    | GetConstant 93: const
  0013    | PushEmptyString
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  =================@fn769=================
  chars_until("'")
  ========================================
  0000    | GetConstant 11: chars_until
  0002    | PushChar '''
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========toml.string.literal===========
  toml.string.literal = "'" > default(chars_until("'"), $"") < "'"
  ========================================
  0000    | PushChar '''
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 62: default
  0009    | GetConstant2 289: @fn769
  0012    | PushEmptyString
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | PushChar '''
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
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
  0001    | GetConstant 154: "\""
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | PushChar '"'
  0010    | Or 10 -> 87
  0013    | SetInputMark
  0014    | GetConstant 155: "\\"
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 23
  0021    | PushChar '\'
  0023    | Or 23 -> 87
  0026    | SetInputMark
  0027    | GetConstant 157: "\b"
  0029    | CallFunction 0
  0031    | TakeRight 31 -> 36
  0034    | PushChar '\x08' (esc)
  0036    | Or 36 -> 87
  0039    | SetInputMark
  0040    | GetConstant 158: "\f"
  0042    | CallFunction 0
  0044    | TakeRight 44 -> 49
  0047    | PushChar '\x0c' (esc)
  0049    | Or 49 -> 87
  0052    | SetInputMark
  0053    | GetConstant 159: "\n"
  0055    | CallFunction 0
  0057    | TakeRight 57 -> 62
  0060    | PushChar '
  '
  0062    | Or 62 -> 87
  0065    | SetInputMark
  0066    | GetConstant 160: "\r"
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 75
  0073    | PushChar '\r (no-eol) (esc)
  '
  0075    | Or 75 -> 87
  0078    | GetConstant 161: "\t"
  0080    | CallFunction 0
  0082    | TakeRight 82 -> 87
  0085    | PushChar '\t' (esc)
  0087    | End
  ========================================
  
  =========_toml.escaped_unicode==========
  _toml.escaped_unicode =
    (`\u` > (hex_numeral * 4) -> U $ @Codepoint(U)) |
    (`\U` > (hex_numeral * 8) -> U $ @Codepoint(U))
  ========================================
  0000    | PushCharVar U
  0002    | SetInputMark
  0003    | GetConstant 170: "\u"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 36
  0010    | Null
  0011    | PushNumber 4
  0013    | ValidateRepeatPattern
  0014    | JumpIfZero 14 -> 35
  0017    | Swap
  0018    | GetConstant 171: hex_numeral
  0020    | CallFunction 0
  0022    | Merge
  0023    | JumpIfFailure 23 -> 34
  0026    | Swap
  0027    | Decrement
  0028    | JumpIfZero 28 -> 35
  0031    | JumpBack 31 -> 17
  0034    | Swap
  0035    | Drop
  0036    | Destructure 55: U
  0038    | TakeRight 38 -> 47
  0041    | GetConstant 172: @Codepoint
  0043    | GetBoundLocal 0
  0045    | CallTailFunction 1
  0047    | Or 47 -> 95
  0050    | GetConstant2 290: "\U"
  0053    | CallFunction 0
  0055    | TakeRight 55 -> 84
  0058    | Null
  0059    | PushNumber 8
  0061    | ValidateRepeatPattern
  0062    | JumpIfZero 62 -> 83
  0065    | Swap
  0066    | GetConstant 171: hex_numeral
  0068    | CallFunction 0
  0070    | Merge
  0071    | JumpIfFailure 71 -> 82
  0074    | Swap
  0075    | Decrement
  0076    | JumpIfZero 76 -> 83
  0079    | JumpBack 79 -> 65
  0082    | Swap
  0083    | Drop
  0084    | Destructure 56: U
  0086    | TakeRight 86 -> 95
  0089    | GetConstant 172: @Codepoint
  0091    | GetBoundLocal 0
  0093    | CallTailFunction 1
  0095    | End
  ========================================
  
  ==========toml.datetime.offset==========
  toml.datetime.offset = toml.datetime.local_date + ("T" | "t" | " ") + _toml.datetime.time_offset
  ========================================
  0000    | GetConstant 246: toml.datetime.local_date
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | PushChar 'T'
  0007    | CallFunction 0
  0009    | Or 9 -> 24
  0012    | SetInputMark
  0013    | PushChar 't'
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | PushChar ' '
  0022    | CallFunction 0
  0024    | Merge
  0025    | GetConstant2 291: _toml.datetime.time_offset
  0028    | CallFunction 0
  0030    | Merge
  0031    | End
  ========================================
  
  ==========toml.datetime.local===========
  toml.datetime.local = toml.datetime.local_date + ("T" | "t" | " ") + toml.datetime.local_time
  ========================================
  0000    | GetConstant 246: toml.datetime.local_date
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | PushChar 'T'
  0007    | CallFunction 0
  0009    | Or 9 -> 24
  0012    | SetInputMark
  0013    | PushChar 't'
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | PushChar ' '
  0022    | CallFunction 0
  0024    | Merge
  0025    | GetConstant 248: toml.datetime.local_time
  0027    | CallFunction 0
  0029    | Merge
  0030    | End
  ========================================
  
  ========toml.datetime.local_date========
  toml.datetime.local_date =
    _toml.datetime.year + "-" + _toml.datetime.month + "-" + _toml.datetime.mday
  ========================================
  0000    | GetConstant2 292: _toml.datetime.year
  0003    | CallFunction 0
  0005    | PushChar '-'
  0007    | CallFunction 0
  0009    | Merge
  0010    | GetConstant2 293: _toml.datetime.month
  0013    | CallFunction 0
  0015    | Merge
  0016    | PushChar '-'
  0018    | CallFunction 0
  0020    | Merge
  0021    | GetConstant2 294: _toml.datetime.mday
  0024    | CallFunction 0
  0026    | Merge
  0027    | End
  ========================================
  
  ==========_toml.datetime.year===========
  _toml.datetime.year = numeral * 4
  ========================================
  0000    | Null
  0001    | PushNumber 4
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 25
  0007    | Swap
  0008    | GetConstant 4: numeral
  0010    | CallFunction 0
  0012    | Merge
  0013    | JumpIfFailure 13 -> 24
  0016    | Swap
  0017    | Decrement
  0018    | JumpIfZero 18 -> 25
  0021    | JumpBack 21 -> 7
  0024    | Swap
  0025    | Drop
  0026    | End
  ========================================
  
  ==========_toml.datetime.month==========
  _toml.datetime.month = ("0" + "1".."9") | "11" | "12"
  ========================================
  0000    | SetInputMark
  0001    | PushChar '0'
  0003    | CallFunction 0
  0005    | ParseCodepointRange '1'..'9'
  0008    | Merge
  0009    | Or 9 -> 26
  0012    | SetInputMark
  0013    | GetConstant2 295: "11"
  0016    | CallFunction 0
  0018    | Or 18 -> 26
  0021    | GetConstant2 296: "12"
  0024    | CallFunction 0
  0026    | End
  ========================================
  
  ==========_toml.datetime.mday===========
  _toml.datetime.mday = ("0".."2" + "1".."9") | "30" | "31"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'2'
  0004    | ParseCodepointRange '1'..'9'
  0007    | Merge
  0008    | Or 8 -> 25
  0011    | SetInputMark
  0012    | GetConstant2 297: "30"
  0015    | CallFunction 0
  0017    | Or 17 -> 25
  0020    | GetConstant2 298: "31"
  0023    | CallFunction 0
  0025    | End
  ========================================
  
  =================@fn770=================
  "." + (numeral * 1..9)
  ========================================
  0000    | PushChar '.'
  0002    | CallFunction 0
  0004    | Null
  0005    | PushNumberOne
  0006    | ValidateRepeatPattern
  0007    | JumpIfZero 7 -> 27
  0010    | Swap
  0011    | GetConstant 4: numeral
  0013    | CallFunction 0
  0015    | Merge
  0016    | JumpIfFailure 16 -> 58
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 10
  0027    | Drop
  0028    | PushNumber 9
  0030    | PushNumberOne
  0031    | NegateNumber
  0032    | Merge
  0033    | ValidateRepeatPattern
  0034    | JumpIfZero 34 -> 59
  0037    | Swap
  0038    | SetInputMark
  0039    | GetConstant 4: numeral
  0041    | CallFunction 0
  0043    | JumpIfFailure 43 -> 56
  0046    | PopInputMark
  0047    | Merge
  0048    | Swap
  0049    | Decrement
  0050    | JumpIfZero 50 -> 59
  0053    | JumpBack 53 -> 37
  0056    | ResetInput
  0057    | Drop
  0058    | Swap
  0059    | Drop
  0060    | Merge
  0061    | End
  ========================================
  
  ========toml.datetime.local_time========
  toml.datetime.local_time =
    _toml.datetime.hours + ":" +
    _toml.datetime.minutes + ":" +
    _toml.datetime.seconds +
    maybe("." + (numeral * 1..9))
  ========================================
  0000    | GetConstant2 299: _toml.datetime.hours
  0003    | CallFunction 0
  0005    | PushChar ':'
  0007    | CallFunction 0
  0009    | Merge
  0010    | GetConstant2 300: _toml.datetime.minutes
  0013    | CallFunction 0
  0015    | Merge
  0016    | PushChar ':'
  0018    | CallFunction 0
  0020    | Merge
  0021    | GetConstant2 301: _toml.datetime.seconds
  0024    | CallFunction 0
  0026    | Merge
  0027    | GetConstant 30: maybe
  0029    | GetConstant2 302: @fn770
  0032    | CallFunction 1
  0034    | Merge
  0035    | End
  ========================================
  
  =======_toml.datetime.time_offset=======
  _toml.datetime.time_offset = toml.datetime.local_time + ("Z" | "z" | _toml.datetime.time_numoffset)
  ========================================
  0000    | GetConstant 248: toml.datetime.local_time
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | PushChar 'Z'
  0007    | CallFunction 0
  0009    | Or 9 -> 25
  0012    | SetInputMark
  0013    | PushChar 'z'
  0015    | CallFunction 0
  0017    | Or 17 -> 25
  0020    | GetConstant2 303: _toml.datetime.time_numoffset
  0023    | CallFunction 0
  0025    | Merge
  0026    | End
  ========================================
  
  =====_toml.datetime.time_numoffset======
  _toml.datetime.time_numoffset = ("+" | "-") + _toml.datetime.hours + ":" + _toml.datetime.minutes
  ========================================
  0000    | SetInputMark
  0001    | PushChar '+'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar '-'
  0010    | CallFunction 0
  0012    | GetConstant2 299: _toml.datetime.hours
  0015    | CallFunction 0
  0017    | Merge
  0018    | PushChar ':'
  0020    | CallFunction 0
  0022    | Merge
  0023    | GetConstant2 300: _toml.datetime.minutes
  0026    | CallFunction 0
  0028    | Merge
  0029    | End
  ========================================
  
  ==========_toml.datetime.hours==========
  _toml.datetime.hours = ("0".."1" + "0".."9") | ("2" + "0".."3")
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'1'
  0004    | ParseCodepointRange '0'..'9'
  0007    | Merge
  0008    | Or 8 -> 19
  0011    | PushChar '2'
  0013    | CallFunction 0
  0015    | ParseCodepointRange '0'..'3'
  0018    | Merge
  0019    | End
  ========================================
  
  =========_toml.datetime.minutes=========
  _toml.datetime.minutes = "0".."5" + "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'5'
  0003    | ParseCodepointRange '0'..'9'
  0006    | Merge
  0007    | End
  ========================================
  
  =========_toml.datetime.seconds=========
  _toml.datetime.seconds = ("0".."5" + "0".."9") | "60"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'5'
  0004    | ParseCodepointRange '0'..'9'
  0007    | Merge
  0008    | Or 8 -> 16
  0011    | GetConstant2 304: "60"
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn771=================
  _toml.number.sign +
    _toml.number.integer_part
  ========================================
  0000    | GetConstant2 306: _toml.number.sign
  0003    | CallFunction 0
  0005    | GetConstant2 307: _toml.number.integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | End
  ========================================
  
  ==========toml.number.integer===========
  toml.number.integer = as_number(
    _toml.number.sign +
    _toml.number.integer_part
  )
  ========================================
  0000    | GetConstant 28: as_number
  0002    | GetConstant2 305: @fn771
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn772=================
  "-" | skip("+")
  ========================================
  0000    | SetInputMark
  0001    | PushChar '-'
  0003    | CallFunction 0
  0005    | Or 5 -> 15
  0008    | GetConstant2 275: skip
  0011    | PushChar '+'
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  ===========_toml.number.sign============
  _toml.number.sign = maybe("-" | skip("+"))
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant2 308: @fn772
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn773=================
  maybe("_") > numeral
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 13
  0009    | GetConstant 4: numeral
  0011    | CallFunction 0
  0013    | End
  ========================================
  
  =======_toml.number.integer_part========
  _toml.number.integer_part =
    ("1".."9" + many(maybe("_") > numeral)) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | GetConstant 0: many
  0006    | GetConstant2 309: @fn773
  0009    | CallFunction 1
  0011    | Merge
  0012    | Or 12 -> 19
  0015    | GetConstant 4: numeral
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  =================@fn774=================
  _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  ========================================
  0000    | GetConstant2 306: _toml.number.sign
  0003    | CallFunction 0
  0005    | GetConstant2 307: _toml.number.integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | SetInputMark
  0012    | GetConstant2 311: _toml.number.fraction_part
  0015    | CallFunction 0
  0017    | GetConstant 30: maybe
  0019    | GetConstant2 312: _toml.number.exponent_part
  0022    | CallFunction 1
  0024    | Merge
  0025    | Or 25 -> 33
  0028    | GetConstant2 312: _toml.number.exponent_part
  0031    | CallFunction 0
  0033    | Merge
  0034    | End
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
  0000    | GetConstant 28: as_number
  0002    | GetConstant2 310: @fn774
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn775=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.fraction_part=======
  _toml.number.fraction_part = "." + many_sep(numerals, maybe("_"))
  ========================================
  0000    | PushChar '.'
  0002    | CallFunction 0
  0004    | GetConstant 124: many_sep
  0006    | GetConstant 41: numerals
  0008    | GetConstant2 313: @fn775
  0011    | CallFunction 2
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn776=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | PushChar '-'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar '+'
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================@fn777=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.exponent_part=======
  _toml.number.exponent_part =
    ("e" | "E") + maybe("-" | "+") + many_sep(numerals, maybe("_"))
  ========================================
  0000    | SetInputMark
  0001    | PushChar 'e'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar 'E'
  0010    | CallFunction 0
  0012    | GetConstant 30: maybe
  0014    | GetConstant2 314: @fn776
  0017    | CallFunction 1
  0019    | Merge
  0020    | GetConstant 124: many_sep
  0022    | GetConstant 41: numerals
  0024    | GetConstant2 315: @fn777
  0027    | CallFunction 2
  0029    | Merge
  0030    | End
  ========================================
  
  =================@fn778=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | PushChar '+'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar '-'
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==========toml.number.infinity==========
  toml.number.infinity = maybe("+" | "-") + "inf"
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant2 316: @fn778
  0005    | CallFunction 1
  0007    | GetConstant2 317: "inf"
  0010    | CallFunction 0
  0012    | Merge
  0013    | End
  ========================================
  
  =================@fn779=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | PushChar '+'
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | PushChar '-'
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========toml.number.not_a_number========
  toml.number.not_a_number = maybe("+" | "-") + "nan"
  ========================================
  0000    | GetConstant 30: maybe
  0002    | GetConstant2 318: @fn779
  0005    | CallFunction 1
  0007    | GetConstant2 319: "nan"
  0010    | CallFunction 0
  0012    | Merge
  0013    | End
  ========================================
  
  =================@fn781=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn782=================
  skip("_") < peek(binary_numeral)
  ========================================
  0000    | GetConstant2 275: skip
  0003    | PushChar '_'
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 18
  0010    | GetConstant 61: peek
  0012    | GetConstant2 325: binary_numeral
  0015    | CallFunction 1
  0017    | TakeLeft
  0018    | End
  ========================================
  
  =================@fn780=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral))
  ========================================
  0000    | GetConstant 65: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 323: @fn781
  0006    | CallFunction 2
  0008    | GetConstant 30: maybe
  0010    | GetConstant2 324: @fn782
  0013    | CallFunction 1
  0015    | Merge
  0016    | End
  ========================================
  
  =================@fn784=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn783=================
  array_sep(binary_digit, maybe("_"))
  ========================================
  0000    | GetConstant 65: array_sep
  0002    | GetConstant 46: binary_digit
  0004    | GetConstant2 327: @fn784
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  =======toml.number.binary_integer=======
  toml.number.binary_integer =
    "0b" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral)),
      array_sep(binary_digit, maybe("_"))
    ) -> Digits $
    Num.FromBinaryDigits(Digits)
  ========================================
  0000    | GetConstant 44: Digits
  0002    | GetConstant2 320: "0b"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 32
  0010    | GetConstant2 321: one_or_both
  0013    | GetConstant2 322: @fn780
  0016    | GetConstant2 326: @fn783
  0019    | CallFunction 2
  0021    | Destructure 57: Digits
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 47: Num.FromBinaryDigits
  0028    | GetBoundLocal 0
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  =================@fn786=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn787=================
  skip("_") < peek(octal_numeral)
  ========================================
  0000    | GetConstant2 275: skip
  0003    | PushChar '_'
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 18
  0010    | GetConstant 61: peek
  0012    | GetConstant2 332: octal_numeral
  0015    | CallFunction 1
  0017    | TakeLeft
  0018    | End
  ========================================
  
  =================@fn785=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral))
  ========================================
  0000    | GetConstant 65: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 330: @fn786
  0006    | CallFunction 2
  0008    | GetConstant 30: maybe
  0010    | GetConstant2 331: @fn787
  0013    | CallFunction 1
  0015    | Merge
  0016    | End
  ========================================
  
  =================@fn789=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn788=================
  array_sep(octal_digit, maybe("_"))
  ========================================
  0000    | GetConstant 65: array_sep
  0002    | GetConstant 48: octal_digit
  0004    | GetConstant2 334: @fn789
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  =======toml.number.octal_integer========
  toml.number.octal_integer =
    "0o" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral)),
      array_sep(octal_digit, maybe("_"))
    ) -> Digits $
    Num.FromOctalDigits(Digits)
  ========================================
  0000    | GetConstant 44: Digits
  0002    | GetConstant2 328: "0o"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 32
  0010    | GetConstant2 321: one_or_both
  0013    | GetConstant2 329: @fn785
  0016    | GetConstant2 333: @fn788
  0019    | CallFunction 2
  0021    | Destructure 58: Digits
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 49: Num.FromOctalDigits
  0028    | GetBoundLocal 0
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  =================@fn791=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn792=================
  skip("_") < peek(hex_numeral)
  ========================================
  0000    | GetConstant2 275: skip
  0003    | PushChar '_'
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 61: peek
  0012    | GetConstant 171: hex_numeral
  0014    | CallFunction 1
  0016    | TakeLeft
  0017    | End
  ========================================
  
  =================@fn790=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral))
  ========================================
  0000    | GetConstant 65: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 337: @fn791
  0006    | CallFunction 2
  0008    | GetConstant 30: maybe
  0010    | GetConstant2 338: @fn792
  0013    | CallFunction 1
  0015    | Merge
  0016    | End
  ========================================
  
  =================@fn794=================
  maybe("_")
  ========================================
  0000    | GetConstant 30: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn793=================
  array_sep(hex_digit, maybe("_"))
  ========================================
  0000    | GetConstant 65: array_sep
  0002    | GetConstant 50: hex_digit
  0004    | GetConstant2 340: @fn794
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ========toml.number.hex_integer=========
  toml.number.hex_integer =
    "0x" & one_or_both(
      array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral)),
      array_sep(hex_digit, maybe("_"))
    ) -> Digits $
    Num.FromHexDigits(Digits)
  ========================================
  0000    | GetConstant 44: Digits
  0002    | GetConstant2 335: "0x"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 32
  0010    | GetConstant2 321: one_or_both
  0013    | GetConstant2 336: @fn790
  0016    | GetConstant2 339: @fn793
  0019    | CallFunction 2
  0021    | Destructure 59: Digits
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 51: Num.FromHexDigits
  0028    | GetBoundLocal 0
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  ============_Toml.Doc.Empty=============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant2 341: {"value": {}, "type": {}}
  0003    | End
  ========================================
  
  ============_Toml.Doc.Value=============
  _Toml.Doc.Value(Doc) = Obj.Get(Doc, "value")
  ========================================
  0000    | GetConstant2 342: Obj.Get
  0003    | GetBoundLocal 0
  0005    | GetConstant2 262: "value"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =============_Toml.Doc.Type=============
  _Toml.Doc.Type(Doc) = Obj.Get(Doc, "type")
  ========================================
  0000    | GetConstant2 342: Obj.Get
  0003    | GetBoundLocal 0
  0005    | GetConstant2 260: "type"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =============_Toml.Doc.Has==============
  _Toml.Doc.Has(Doc, Key) = Obj.Has(_Toml.Doc.Type(Doc), Key)
  ========================================
  0000    | GetConstant2 343: Obj.Has
  0003    | GetConstant2 344: _Toml.Doc.Type
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | GetBoundLocal 1
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =============_Toml.Doc.Get==============
  _Toml.Doc.Get(Doc, Key) = {
    "value": Obj.Get(_Toml.Doc.Value(Doc), Key),
    "type": Obj.Get(_Toml.Doc.Type(Doc), Key),
  }
  ========================================
  0000    | GetConstant2 345: {_0_, _1_}
  0003    | GetConstant2 262: "value"
  0006    | GetConstant2 342: Obj.Get
  0009    | GetConstant 190: _Toml.Doc.Value
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | InsertKeyVal 0
  0021    | GetConstant2 260: "type"
  0024    | GetConstant2 342: Obj.Get
  0027    | GetConstant2 344: _Toml.Doc.Type
  0030    | GetBoundLocal 0
  0032    | CallFunction 1
  0034    | GetBoundLocal 1
  0036    | CallFunction 2
  0038    | InsertKeyVal 1
  0040    | End
  ========================================
  
  ===========_Toml.Doc.IsTable============
  _Toml.Doc.IsTable(Doc) = Is.Object(_Toml.Doc.Type(Doc))
  ========================================
  0000    | GetConstant2 346: Is.Object
  0003    | GetConstant2 344: _Toml.Doc.Type
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ============_Toml.Doc.Insert============
  _Toml.Doc.Insert(Doc, Key, Val, Type) =
    _Toml.Doc.IsTable(Doc) &
    {
      "value": Obj.Put(_Toml.Doc.Value(Doc), Key, Val),
      "type": Obj.Put(_Toml.Doc.Type(Doc), Key, Type),
    }
  ========================================
  0000    | GetConstant2 347: _Toml.Doc.IsTable
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | TakeRight 7 -> 54
  0010    | GetConstant2 348: {_0_, _1_}
  0013    | GetConstant2 262: "value"
  0016    | GetConstant2 349: Obj.Put
  0019    | GetConstant 190: _Toml.Doc.Value
  0021    | GetBoundLocal 0
  0023    | CallFunction 1
  0025    | GetBoundLocal 1
  0027    | GetBoundLocal 2
  0029    | CallFunction 3
  0031    | InsertKeyVal 0
  0033    | GetConstant2 260: "type"
  0036    | GetConstant2 349: Obj.Put
  0039    | GetConstant2 344: _Toml.Doc.Type
  0042    | GetBoundLocal 0
  0044    | CallFunction 1
  0046    | GetBoundLocal 1
  0048    | GetBoundLocal 3
  0050    | CallFunction 3
  0052    | InsertKeyVal 1
  0054    | End
  ========================================
  
  ====_Toml.Doc.AppendToArrayOfTables=====
  _Toml.Doc.AppendToArrayOfTables(Doc, Key, Val) =
    _Toml.Doc.Get(Doc, Key) -> {"value": AoT, "type": "array_of_tables"} &
    _Toml.Doc.Insert(Doc, Key, [...AoT, Val], "array_of_tables")
  ========================================
  0000    | GetConstant2 350: AoT
  0003    | GetConstant2 351: _Toml.Doc.Get
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 1
  0010    | CallFunction 2
  0012    | Destructure 60: {"value": AoT, "type": "array_of_tables"}
  0014    | TakeRight 14 -> 41
  0017    | GetConstant2 352: _Toml.Doc.Insert
  0020    | GetBoundLocal 0
  0022    | GetBoundLocal 1
  0024    | PushEmptyArray
  0025    | GetBoundLocal 3
  0027    | Merge
  0028    | GetConstant2 353: [_]
  0031    | GetBoundLocal 2
  0033    | InsertAtIndex 0
  0035    | Merge
  0036    | GetConstant2 354: "array_of_tables"
  0039    | CallTailFunction 4
  0041    | End
  ========================================
  
  =========_Toml.Doc.InsertAtPath=========
  _Toml.Doc.InsertAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.ValueUpdater)
  ========================================
  0000    | GetConstant2 355: _Toml.Doc.UpdateAtPath
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | GetConstant2 356: _Toml.Doc.ValueUpdater
  0012    | CallTailFunction 4
  0014    | End
  ========================================
  
  ======_Toml.Doc.EnsureTableAtPath=======
  _Toml.Doc.EnsureTableAtPath(Doc, Path) =
    _Toml.Doc.UpdateAtPath(Doc, Path, {}, _Toml.Doc.MissingTableUpdater)
  ========================================
  0000    | GetConstant2 355: _Toml.Doc.UpdateAtPath
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyObject
  0008    | GetConstant2 357: _Toml.Doc.MissingTableUpdater
  0011    | CallTailFunction 4
  0013    | End
  ========================================
  
  =========_Toml.Doc.AppendAtPath=========
  _Toml.Doc.AppendAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.AppendUpdater)
  ========================================
  0000    | GetConstant2 355: _Toml.Doc.UpdateAtPath
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | GetConstant2 358: _Toml.Doc.AppendUpdater
  0012    | CallTailFunction 4
  0014    | End
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
  0000    | GetConstant2 274: Key
  0003    | GetConstant2 359: PathRest
  0006    | GetConstant 204: InnerDoc
  0008    | SetInputMark
  0009    | GetBoundLocal 1
  0011    | Destructure 61: [Key]
  0013    | ConditionalThen 13 -> 29
  0016    | GetBoundLocal 3
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 4
  0022    | GetBoundLocal 2
  0024    | CallTailFunction 3
  0026    | Jump 26 -> 137
  0029    | SetInputMark
  0030    | GetBoundLocal 1
  0032    | Destructure 62: ([Key] + PathRest)
  0034    | ConditionalThen 34 -> 135
  0037    | SetInputMark
  0038    | GetConstant2 360: _Toml.Doc.Has
  0041    | GetBoundLocal 0
  0043    | GetBoundLocal 4
  0045    | CallFunction 2
  0047    | ConditionalThen 47 -> 90
  0050    | GetConstant2 347: _Toml.Doc.IsTable
  0053    | GetConstant2 351: _Toml.Doc.Get
  0056    | GetBoundLocal 0
  0058    | GetBoundLocal 4
  0060    | CallFunction 2
  0062    | CallFunction 1
  0064    | TakeRight 64 -> 87
  0067    | GetConstant2 355: _Toml.Doc.UpdateAtPath
  0070    | GetConstant2 351: _Toml.Doc.Get
  0073    | GetBoundLocal 0
  0075    | GetBoundLocal 4
  0077    | CallFunction 2
  0079    | GetBoundLocal 5
  0081    | GetBoundLocal 2
  0083    | GetBoundLocal 3
  0085    | CallFunction 4
  0087    | Jump 87 -> 105
  0090    | GetConstant2 355: _Toml.Doc.UpdateAtPath
  0093    | GetConstant 193: _Toml.Doc.Empty
  0095    | CallFunction 0
  0097    | GetBoundLocal 5
  0099    | GetBoundLocal 2
  0101    | GetBoundLocal 3
  0103    | CallFunction 4
  0105    | Destructure 63: InnerDoc
  0107    | TakeRight 107 -> 132
  0110    | GetConstant2 352: _Toml.Doc.Insert
  0113    | GetBoundLocal 0
  0115    | GetBoundLocal 4
  0117    | GetConstant 190: _Toml.Doc.Value
  0119    | GetBoundLocal 6
  0121    | CallFunction 1
  0123    | GetConstant2 344: _Toml.Doc.Type
  0126    | GetBoundLocal 6
  0128    | CallFunction 1
  0130    | CallTailFunction 4
  0132    | Jump 132 -> 137
  0135    | GetBoundLocal 0
  0137    | End
  ========================================
  
  =========_Toml.Doc.ValueUpdater=========
  _Toml.Doc.ValueUpdater(Doc, Key, Val) =
    _Toml.Doc.Has(Doc, Key) ? @Fail : _Toml.Doc.Insert(Doc, Key, Val, "value")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 360: _Toml.Doc.Has
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | ConditionalThen 10 -> 21
  0013    | GetConstant2 361: @Fail
  0016    | CallTailFunction 0
  0018    | Jump 18 -> 35
  0021    | GetConstant2 352: _Toml.Doc.Insert
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | GetBoundLocal 2
  0030    | GetConstant2 262: "value"
  0033    | CallTailFunction 4
  0035    | End
  ========================================
  
  =====_Toml.Doc.MissingTableUpdater======
  _Toml.Doc.MissingTableUpdater(Doc, Key, _Val) =
    _Toml.Doc.IsTable(_Toml.Doc.Get(Doc, Key)) ? Doc :
    _Toml.Doc.Insert(Doc, Key, {}, {})
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 347: _Toml.Doc.IsTable
  0004    | GetConstant2 351: _Toml.Doc.Get
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallFunction 2
  0013    | CallFunction 1
  0015    | ConditionalThen 15 -> 23
  0018    | GetBoundLocal 0
  0020    | Jump 20 -> 34
  0023    | GetConstant2 352: _Toml.Doc.Insert
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | PushEmptyObject
  0031    | PushEmptyObject
  0032    | CallTailFunction 4
  0034    | End
  ========================================
  
  ========_Toml.Doc.AppendUpdater=========
  _Toml.Doc.AppendUpdater(Doc, Key, Val) =
    (
      _Toml.Doc.Has(Doc, Key) ? Doc :
      _Toml.Doc.Insert(Doc, Key, [], "array_of_tables")
    ) -> DocWithKey &
    _Toml.Doc.AppendToArrayOfTables(DocWithKey, Key, Val)
  ========================================
  0000    | GetConstant2 362: DocWithKey
  0003    | SetInputMark
  0004    | GetConstant2 360: _Toml.Doc.Has
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallFunction 2
  0013    | ConditionalThen 13 -> 21
  0016    | GetBoundLocal 0
  0018    | Jump 18 -> 34
  0021    | GetConstant2 352: _Toml.Doc.Insert
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | PushEmptyArray
  0029    | GetConstant2 354: "array_of_tables"
  0032    | CallFunction 4
  0034    | Destructure 64: DocWithKey
  0036    | TakeRight 36 -> 50
  0039    | GetConstant2 363: _Toml.Doc.AppendToArrayOfTables
  0042    | GetBoundLocal 3
  0044    | GetBoundLocal 1
  0046    | GetBoundLocal 2
  0048    | CallTailFunction 3
  0050    | End
  ========================================
  
  ======ast.with_operator_precedence======
  ast.with_operator_precedence(operand, prefix, infix, postfix) =
    _ast.with_precedence_start(operand, prefix, infix, postfix, $0)
  ========================================
  0000    | GetConstant2 364: _ast.with_precedence_start
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | GetBoundLocal 3
  0011    | PushNumberZero
  0012    | CallTailFunction 5
  0014    | End
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
  0000    | GetConstant2 365: PrefixBindingPower
  0003    | GetConstant2 366: PrefixNode
  0006    | GetConstant2 367: Node
  0009    | SetInputMark
  0010    | GetBoundLocal 1
  0012    | CallFunction 0
  0014    | Destructure 65: ({"power": PrefixBindingPower} + PrefixNode)
  0016    | ConditionalThen 16 -> 82
  0019    | GetConstant2 364: _ast.with_precedence_start
  0022    | GetBoundLocal 0
  0024    | GetBoundLocal 1
  0026    | GetBoundLocal 2
  0028    | GetBoundLocal 3
  0030    | GetBoundLocal 5
  0032    | CallFunction 5
  0034    | Destructure 66: Node
  0036    | TakeRight 36 -> 79
  0039    | GetConstant2 368: _ast.with_precedence_rest
  0042    | GetBoundLocal 0
  0044    | GetBoundLocal 1
  0046    | GetBoundLocal 2
  0048    | GetBoundLocal 3
  0050    | GetBoundLocal 4
  0052    | PushEmptyObject
  0053    | GetBoundLocal 6
  0055    | Merge
  0056    | GetConstant2 369: {_0_}
  0059    | GetConstant2 370: "prefixed"
  0062    | GetBoundLocal 7
  0064    | InsertKeyVal 0
  0066    | GetConstant2 371: _Ast.MergePos
  0069    | GetBoundLocal 6
  0071    | GetBoundLocal 7
  0073    | CallFunction 2
  0075    | Merge
  0076    | Merge
  0077    | CallTailFunction 6
  0079    | Jump 79 -> 108
  0082    | GetBoundLocal 0
  0084    | CallFunction 0
  0086    | Destructure 67: Node
  0088    | TakeRight 88 -> 108
  0091    | GetConstant2 368: _ast.with_precedence_rest
  0094    | GetBoundLocal 0
  0096    | GetBoundLocal 1
  0098    | GetBoundLocal 2
  0100    | GetBoundLocal 3
  0102    | GetBoundLocal 4
  0104    | GetBoundLocal 7
  0106    | CallTailFunction 6
  0108    | End
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
  0000    | GetConstant2 372: RightBindingPower
  0003    | GetConstant2 373: PostfixNode
  0006    | GetConstant2 374: NextLeftBindingPower
  0009    | GetConstant2 375: InfixNode
  0012    | GetConstant2 376: RightNode
  0015    | SetInputMark
  0016    | GetBoundLocal 3
  0018    | CallFunction 0
  0020    | Destructure 68: ({"power": RightBindingPower} + PostfixNode)
  0022    | TakeRight 22 -> 38
  0025    | GetConstant 93: const
  0027    | GetConstant2 377: Is.LessThan
  0030    | GetBoundLocal 4
  0032    | GetBoundLocal 6
  0034    | CallFunction 2
  0036    | CallFunction 1
  0038    | ConditionalThen 38 -> 84
  0041    | GetConstant2 368: _ast.with_precedence_rest
  0044    | GetBoundLocal 0
  0046    | GetBoundLocal 1
  0048    | GetBoundLocal 2
  0050    | GetBoundLocal 3
  0052    | GetBoundLocal 4
  0054    | PushEmptyObject
  0055    | GetBoundLocal 7
  0057    | Merge
  0058    | GetConstant2 378: {_0_}
  0061    | GetConstant2 379: "postfixed"
  0064    | GetBoundLocal 5
  0066    | InsertKeyVal 0
  0068    | GetConstant2 371: _Ast.MergePos
  0071    | GetBoundLocal 5
  0073    | GetBoundLocal 7
  0075    | CallFunction 2
  0077    | Merge
  0078    | Merge
  0079    | CallTailFunction 6
  0081    | Jump 81 -> 186
  0084    | SetInputMark
  0085    | GetBoundLocal 2
  0087    | CallFunction 0
  0089    | Destructure 69: ({"power": [RightBindingPower, NextLeftBindingPower]} + InfixNode)
  0091    | TakeRight 91 -> 107
  0094    | GetConstant 93: const
  0096    | GetConstant2 377: Is.LessThan
  0099    | GetBoundLocal 4
  0101    | GetBoundLocal 6
  0103    | CallFunction 2
  0105    | CallFunction 1
  0107    | ConditionalThen 107 -> 180
  0110    | GetConstant2 364: _ast.with_precedence_start
  0113    | GetBoundLocal 0
  0115    | GetBoundLocal 1
  0117    | GetBoundLocal 2
  0119    | GetBoundLocal 3
  0121    | GetBoundLocal 8
  0123    | CallFunction 5
  0125    | Destructure 70: RightNode
  0127    | TakeRight 127 -> 177
  0130    | GetConstant2 368: _ast.with_precedence_rest
  0133    | GetBoundLocal 0
  0135    | GetBoundLocal 1
  0137    | GetBoundLocal 2
  0139    | GetBoundLocal 3
  0141    | GetBoundLocal 4
  0143    | PushEmptyObject
  0144    | GetBoundLocal 9
  0146    | Merge
  0147    | GetConstant2 380: {_0_, _1_}
  0150    | GetConstant2 381: "left"
  0153    | GetBoundLocal 5
  0155    | InsertKeyVal 0
  0157    | GetConstant2 382: "right"
  0160    | GetBoundLocal 10
  0162    | InsertKeyVal 1
  0164    | GetConstant2 371: _Ast.MergePos
  0167    | GetBoundLocal 5
  0169    | GetBoundLocal 10
  0171    | CallFunction 2
  0173    | Merge
  0174    | Merge
  0175    | CallTailFunction 6
  0177    | Jump 177 -> 186
  0180    | GetConstant 93: const
  0182    | GetBoundLocal 5
  0184    | CallTailFunction 1
  0186    | End
  ========================================
  
  ================ast.node================
  ast.node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | GetConstant 115: Value
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 71: Value
  0008    | TakeRight 8 -> 28
  0011    | GetConstant2 383: {_0_, _1_}
  0014    | GetConstant2 260: "type"
  0017    | GetBoundLocal 1
  0019    | InsertKeyVal 0
  0021    | GetConstant2 262: "value"
  0024    | GetBoundLocal 2
  0026    | InsertKeyVal 1
  0028    | End
  ========================================
  
  ============ast.prefix_node=============
  ast.prefix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 24
  0007    | GetConstant2 384: {_0_, _1_}
  0010    | GetConstant2 260: "type"
  0013    | GetBoundLocal 1
  0015    | InsertKeyVal 0
  0017    | GetConstant2 385: "power"
  0020    | GetBoundLocal 2
  0022    | InsertKeyVal 1
  0024    | End
  ========================================
  
  =============ast.infix_node=============
  ast.infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    op $ {"type": Type, "power": [LeftBindingPower, RightBindingPower]}
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 33
  0007    | GetConstant2 386: {_0_, _1_}
  0010    | GetConstant2 260: "type"
  0013    | GetBoundLocal 1
  0015    | InsertKeyVal 0
  0017    | GetConstant2 385: "power"
  0020    | GetConstant2 387: [_, _]
  0023    | GetBoundLocal 2
  0025    | InsertAtIndex 0
  0027    | GetBoundLocal 3
  0029    | InsertAtIndex 1
  0031    | InsertKeyVal 1
  0033    | End
  ========================================
  
  ============ast.postfix_node============
  ast.postfix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 24
  0007    | GetConstant2 388: {_0_, _1_}
  0010    | GetConstant2 260: "type"
  0013    | GetBoundLocal 1
  0015    | InsertKeyVal 0
  0017    | GetConstant2 385: "power"
  0020    | GetBoundLocal 2
  0022    | InsertKeyVal 1
  0024    | End
  ========================================
  
  ==========ast.with_offset_pos===========
  ast.with_offset_pos(node) =
    @input.offset -> StartOffset &
    node -> Node &
    @input.offset -> EndOffset $
    {...Node, "startpos": StartOffset, "endpos": EndOffset}
  ========================================
  0000    | GetConstant2 389: StartOffset
  0003    | GetConstant2 367: Node
  0006    | GetConstant2 390: EndOffset
  0009    | GetConstant2 391: @input.offset
  0012    | CallFunction 0
  0014    | Destructure 72: StartOffset
  0016    | TakeRight 16 -> 25
  0019    | GetBoundLocal 0
  0021    | CallFunction 0
  0023    | Destructure 73: Node
  0025    | TakeRight 25 -> 60
  0028    | GetConstant2 391: @input.offset
  0031    | CallFunction 0
  0033    | Destructure 74: EndOffset
  0035    | TakeRight 35 -> 60
  0038    | PushEmptyObject
  0039    | GetBoundLocal 2
  0041    | Merge
  0042    | GetConstant2 392: {_0_, _1_}
  0045    | GetConstant2 393: "startpos"
  0048    | GetBoundLocal 1
  0050    | InsertKeyVal 0
  0052    | GetConstant2 394: "endpos"
  0055    | GetBoundLocal 3
  0057    | InsertKeyVal 1
  0059    | Merge
  0060    | End
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
  0000    | GetConstant2 395: StartLine
  0003    | GetConstant2 396: StartLineOffset
  0006    | GetConstant2 367: Node
  0009    | GetConstant2 397: EndLine
  0012    | GetConstant2 398: EndLineOffset
  0015    | GetConstant2 399: @input.line
  0018    | CallFunction 0
  0020    | Destructure 75: StartLine
  0022    | TakeRight 22 -> 32
  0025    | GetConstant2 400: @input.line_offset
  0028    | CallFunction 0
  0030    | Destructure 76: StartLineOffset
  0032    | TakeRight 32 -> 41
  0035    | GetBoundLocal 0
  0037    | CallFunction 0
  0039    | Destructure 77: Node
  0041    | TakeRight 41 -> 51
  0044    | GetConstant2 399: @input.line
  0047    | CallFunction 0
  0049    | Destructure 78: EndLine
  0051    | TakeRight 51 -> 114
  0054    | GetConstant2 400: @input.line_offset
  0057    | CallFunction 0
  0059    | Destructure 79: EndLineOffset
  0061    | TakeRight 61 -> 114
  0064    | PushEmptyObject
  0065    | GetBoundLocal 3
  0067    | Merge
  0068    | GetConstant2 401: {_0_, _1_}
  0071    | GetConstant2 393: "startpos"
  0074    | GetConstant2 402: {_0_, _1_}
  0077    | GetConstant2 403: "line"
  0080    | GetBoundLocal 1
  0082    | InsertKeyVal 0
  0084    | GetConstant 241: "offset"
  0086    | GetBoundLocal 2
  0088    | InsertKeyVal 1
  0090    | InsertKeyVal 0
  0092    | GetConstant2 394: "endpos"
  0095    | GetConstant2 404: {_0_, _1_}
  0098    | GetConstant2 403: "line"
  0101    | GetBoundLocal 4
  0103    | InsertKeyVal 0
  0105    | GetConstant 241: "offset"
  0107    | GetBoundLocal 5
  0109    | InsertKeyVal 1
  0111    | InsertKeyVal 1
  0113    | Merge
  0114    | End
  ========================================
  
  ================Num.Inc=================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant2 405: @Add
  0003    | GetBoundLocal 0
  0005    | PushNumberOne
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Dec=================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant2 406: @Subtract
  0003    | GetBoundLocal 0
  0005    | PushNumberOne
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Abs=================
  Num.Abs(N) = N -> 0.. | -N
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 80: 0..
  0005    | Or 5 -> 11
  0008    | GetBoundLocal 0
  0010    | NegateNumber
  0011    | End
  ========================================
  
  ================Num.Max=================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 81: B..
  0005    | ConditionalThen 5 -> 13
  0008    | GetBoundLocal 0
  0010    | Jump 10 -> 15
  0013    | GetBoundLocal 1
  0015    | End
  ========================================
  
  ==========Num.FromBinaryDigits==========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | GetConstant2 407: Len
  0003    | GetConstant2 408: Array.Length
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Destructure 82: Len
  0012    | TakeRight 12 -> 27
  0015    | GetConstant2 409: _Num.FromBinaryDigits
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | PushNumberNegOne
  0023    | Merge
  0024    | PushNumberZero
  0025    | CallTailFunction 3
  0027    | End
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
  0002    | GetConstant2 410: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 83: ([B] + Rest)
  0010    | ConditionalThen 10 -> 52
  0013    | GetBoundLocal 3
  0015    | Destructure 84: 0..1
  0017    | TakeRight 17 -> 49
  0020    | GetConstant2 409: _Num.FromBinaryDigits
  0023    | GetBoundLocal 4
  0025    | GetBoundLocal 1
  0027    | PushNumberNegOne
  0028    | Merge
  0029    | GetBoundLocal 2
  0031    | GetConstant2 411: @Multiply
  0034    | GetBoundLocal 3
  0036    | GetConstant2 412: @Power
  0039    | PushNumberTwo
  0040    | GetBoundLocal 1
  0042    | CallFunction 2
  0044    | CallFunction 2
  0046    | Merge
  0047    | CallTailFunction 3
  0049    | Jump 49 -> 54
  0052    | GetBoundLocal 2
  0054    | End
  ========================================
  
  ==========Num.FromOctalDigits===========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | GetConstant2 407: Len
  0003    | GetConstant2 408: Array.Length
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Destructure 85: Len
  0012    | TakeRight 12 -> 27
  0015    | GetConstant2 413: _Num.FromOctalDigits
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | PushNumberNegOne
  0023    | Merge
  0024    | PushNumberZero
  0025    | CallTailFunction 3
  0027    | End
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
  0002    | GetConstant2 410: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 86: ([O] + Rest)
  0010    | ConditionalThen 10 -> 53
  0013    | GetBoundLocal 3
  0015    | Destructure 87: 0..7
  0017    | TakeRight 17 -> 50
  0020    | GetConstant2 413: _Num.FromOctalDigits
  0023    | GetBoundLocal 4
  0025    | GetBoundLocal 1
  0027    | PushNumberNegOne
  0028    | Merge
  0029    | GetBoundLocal 2
  0031    | GetConstant2 411: @Multiply
  0034    | GetBoundLocal 3
  0036    | GetConstant2 412: @Power
  0039    | PushNumber 8
  0041    | GetBoundLocal 1
  0043    | CallFunction 2
  0045    | CallFunction 2
  0047    | Merge
  0048    | CallTailFunction 3
  0050    | Jump 50 -> 55
  0053    | GetBoundLocal 2
  0055    | End
  ========================================
  
  ===========Num.FromHexDigits============
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | GetConstant2 407: Len
  0003    | GetConstant2 408: Array.Length
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Destructure 88: Len
  0012    | TakeRight 12 -> 27
  0015    | GetConstant2 414: _Num.FromHexDigits
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | PushNumberNegOne
  0023    | Merge
  0024    | PushNumberZero
  0025    | CallTailFunction 3
  0027    | End
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
  0002    | GetConstant2 410: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 89: ([H] + Rest)
  0010    | ConditionalThen 10 -> 53
  0013    | GetBoundLocal 3
  0015    | Destructure 90: 0..15
  0017    | TakeRight 17 -> 50
  0020    | GetConstant2 414: _Num.FromHexDigits
  0023    | GetBoundLocal 4
  0025    | GetBoundLocal 1
  0027    | PushNumberNegOne
  0028    | Merge
  0029    | GetBoundLocal 2
  0031    | GetConstant2 411: @Multiply
  0034    | GetBoundLocal 3
  0036    | GetConstant2 412: @Power
  0039    | PushNumber 16
  0041    | GetBoundLocal 1
  0043    | CallFunction 2
  0045    | CallFunction 2
  0047    | Merge
  0048    | CallTailFunction 3
  0050    | Jump 50 -> 55
  0053    | GetBoundLocal 2
  0055    | End
  ========================================
  
  ==============Array.First===============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushCharVar F
  0002    | PushUnderscoreVar
  0003    | GetBoundLocal 0
  0005    | Destructure 91: ([F] + _)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocal 1
  0012    | End
  ========================================
  
  ===============Array.Rest===============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar R
  0003    | GetBoundLocal 0
  0005    | Destructure 92: ([_] + R)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocal 2
  0012    | End
  ========================================
  
  ==============Array.Length==============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar L
  0003    | GetBoundLocal 0
  0005    | Destructure 93: ([_] * L)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocal 2
  0012    | End
  ========================================
  
  =============Array.Reverse==============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant2 415: _Array.Reverse
  0003    | GetBoundLocal 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Array.Reverse=============
  _Array.Reverse(A, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reverse(Rest, [First, ...Acc]) :
    Acc
  ========================================
  0000    | GetConstant 82: First
  0002    | GetConstant2 410: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 94: ([First] + Rest)
  0010    | ConditionalThen 10 -> 33
  0013    | GetConstant2 415: _Array.Reverse
  0016    | GetBoundLocal 3
  0018    | GetConstant2 416: [_]
  0021    | GetBoundLocal 2
  0023    | InsertAtIndex 0
  0025    | GetBoundLocal 1
  0027    | Merge
  0028    | CallTailFunction 2
  0030    | Jump 30 -> 35
  0033    | GetBoundLocal 1
  0035    | End
  ========================================
  
  ===============Array.Map================
  Array.Map(A, Fn) = _Array.Map(A, Fn, [])
  ========================================
  0000    | GetConstant2 417: _Array.Map
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===============_Array.Map===============
  _Array.Map(A, Fn, Acc) =
    A -> [First, ...Rest] ?
    _Array.Map(Rest, Fn, [...Acc, Fn(First)]) :
    Acc
  ========================================
  0000    | GetConstant 82: First
  0002    | GetConstant2 410: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 95: ([First] + Rest)
  0010    | ConditionalThen 10 -> 41
  0013    | GetConstant2 417: _Array.Map
  0016    | GetBoundLocal 4
  0018    | GetBoundLocal 1
  0020    | PushEmptyArray
  0021    | GetBoundLocal 2
  0023    | Merge
  0024    | GetConstant2 418: [_]
  0027    | GetBoundLocal 1
  0029    | GetBoundLocal 3
  0031    | CallFunction 1
  0033    | InsertAtIndex 0
  0035    | Merge
  0036    | CallTailFunction 3
  0038    | Jump 38 -> 43
  0041    | GetBoundLocal 2
  0043    | End
  ========================================
  
  ==============Array.Filter==============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant2 419: _Array.Filter
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_Array.Filter==============
  _Array.Filter(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Filter(Rest, Pred, Pred(First) ? [...Acc, First] : Acc) :
    Acc
  ========================================
  0000    | GetConstant 82: First
  0002    | GetConstant2 410: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 96: ([First] + Rest)
  0010    | ConditionalThen 10 -> 52
  0013    | GetConstant2 419: _Array.Filter
  0016    | GetBoundLocal 4
  0018    | GetBoundLocal 1
  0020    | SetInputMark
  0021    | GetBoundLocal 1
  0023    | GetBoundLocal 3
  0025    | CallFunction 1
  0027    | ConditionalThen 27 -> 45
  0030    | PushEmptyArray
  0031    | GetBoundLocal 2
  0033    | Merge
  0034    | GetConstant2 420: [_]
  0037    | GetBoundLocal 3
  0039    | InsertAtIndex 0
  0041    | Merge
  0042    | Jump 42 -> 47
  0045    | GetBoundLocal 2
  0047    | CallTailFunction 3
  0049    | Jump 49 -> 54
  0052    | GetBoundLocal 2
  0054    | End
  ========================================
  
  ==============Array.Reject==============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant2 421: _Array.Reject
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
  0000    | GetConstant 82: First
  0002    | GetConstant2 410: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 97: ([First] + Rest)
  0010    | ConditionalThen 10 -> 52
  0013    | GetConstant2 421: _Array.Reject
  0016    | GetBoundLocal 4
  0018    | GetBoundLocal 1
  0020    | SetInputMark
  0021    | GetBoundLocal 1
  0023    | GetBoundLocal 3
  0025    | CallFunction 1
  0027    | ConditionalThen 27 -> 35
  0030    | GetBoundLocal 2
  0032    | Jump 32 -> 47
  0035    | PushEmptyArray
  0036    | GetBoundLocal 2
  0038    | Merge
  0039    | GetConstant2 422: [_]
  0042    | GetBoundLocal 3
  0044    | InsertAtIndex 0
  0046    | Merge
  0047    | CallTailFunction 3
  0049    | Jump 49 -> 54
  0052    | GetBoundLocal 2
  0054    | End
  ========================================
  
  ============Array.ZipObject=============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant2 423: _Array.ZipObject
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
  0002    | GetConstant2 424: KsRest
  0005    | PushCharVar V
  0007    | GetConstant2 425: VsRest
  0010    | SetInputMark
  0011    | GetBoundLocal 0
  0013    | Destructure 98: ([K] + KsRest)
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocal 1
  0020    | Destructure 99: ([V] + VsRest)
  0022    | ConditionalThen 22 -> 51
  0025    | GetConstant2 423: _Array.ZipObject
  0028    | GetBoundLocal 4
  0030    | GetBoundLocal 6
  0032    | PushEmptyObject
  0033    | GetBoundLocal 2
  0035    | Merge
  0036    | GetConstant2 426: {_0_}
  0039    | GetBoundLocal 3
  0041    | GetBoundLocal 5
  0043    | InsertKeyVal 0
  0045    | Merge
  0046    | CallTailFunction 3
  0048    | Jump 48 -> 53
  0051    | GetBoundLocal 2
  0053    | End
  ========================================
  
  =============Array.ZipPairs=============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant2 427: _Array.ZipPairs
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
  0000    | GetConstant2 428: First1
  0003    | GetConstant2 429: Rest1
  0006    | GetConstant2 430: First2
  0009    | GetConstant2 431: Rest2
  0012    | SetInputMark
  0013    | GetBoundLocal 0
  0015    | Destructure 100: ([First1] + Rest1)
  0017    | TakeRight 17 -> 24
  0020    | GetBoundLocal 1
  0022    | Destructure 101: ([First2] + Rest2)
  0024    | ConditionalThen 24 -> 60
  0027    | GetConstant2 427: _Array.ZipPairs
  0030    | GetBoundLocal 4
  0032    | GetBoundLocal 6
  0034    | PushEmptyArray
  0035    | GetBoundLocal 2
  0037    | Merge
  0038    | GetConstant2 432: [_]
  0041    | GetConstant2 433: [_, _]
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
  
  =============Array.AppendN==============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetBoundLocal 0
  0002    | GetConstant2 434: [_]
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
  0000    | GetConstant2 435: _Table.Transpose
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
  0000    | GetConstant2 436: FirstPerRow
  0003    | GetConstant2 437: RestPerRow
  0006    | SetInputMark
  0007    | GetConstant2 438: _Table.FirstPerRow
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Destructure 102: FirstPerRow
  0016    | TakeRight 16 -> 28
  0019    | GetConstant2 439: _Table.RestPerRow
  0022    | GetBoundLocal 0
  0024    | CallFunction 1
  0026    | Destructure 103: RestPerRow
  0028    | ConditionalThen 28 -> 53
  0031    | GetConstant2 435: _Table.Transpose
  0034    | GetBoundLocal 3
  0036    | PushEmptyArray
  0037    | GetBoundLocal 1
  0039    | Merge
  0040    | GetConstant2 440: [_]
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
  0000    | GetConstant2 441: Row
  0003    | GetConstant2 410: Rest
  0006    | GetConstant2 442: VeryFirst
  0009    | PushUnderscoreVar
  0010    | GetBoundLocal 0
  0012    | Destructure 104: ([Row] + Rest)
  0014    | TakeRight 14 -> 21
  0017    | GetBoundLocal 1
  0019    | Destructure 105: ([VeryFirst] + _)
  0021    | TakeRight 21 -> 38
  0024    | GetConstant2 443: __Table.FirstPerRow
  0027    | GetBoundLocal 2
  0029    | GetConstant2 444: [_]
  0032    | GetBoundLocal 3
  0034    | InsertAtIndex 0
  0036    | CallTailFunction 2
  0038    | End
  ========================================
  
  ==========__Table.FirstPerRow===========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant2 441: Row
  0003    | GetConstant2 410: Rest
  0006    | GetConstant 82: First
  0008    | PushUnderscoreVar
  0009    | SetInputMark
  0010    | GetBoundLocal 0
  0012    | Destructure 106: ([Row] + Rest)
  0014    | TakeRight 14 -> 21
  0017    | GetBoundLocal 2
  0019    | Destructure 107: ([First] + _)
  0021    | ConditionalThen 21 -> 46
  0024    | GetConstant2 443: __Table.FirstPerRow
  0027    | GetBoundLocal 3
  0029    | PushEmptyArray
  0030    | GetBoundLocal 1
  0032    | Merge
  0033    | GetConstant2 445: [_]
  0036    | GetBoundLocal 4
  0038    | InsertAtIndex 0
  0040    | Merge
  0041    | CallTailFunction 2
  0043    | Jump 43 -> 48
  0046    | GetBoundLocal 1
  0048    | End
  ========================================
  
  ===========_Table.RestPerRow============
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant2 446: __Table.RestPerRow
  0003    | GetBoundLocal 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
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
  0000    | GetConstant2 441: Row
  0003    | GetConstant2 410: Rest
  0006    | PushUnderscoreVar
  0007    | GetConstant2 447: RowRest
  0010    | SetInputMark
  0011    | GetBoundLocal 0
  0013    | Destructure 108: ([Row] + Rest)
  0015    | ConditionalThen 15 -> 66
  0018    | SetInputMark
  0019    | GetBoundLocal 2
  0021    | Destructure 109: ([_] + RowRest)
  0023    | ConditionalThen 23 -> 48
  0026    | GetConstant2 446: __Table.RestPerRow
  0029    | GetBoundLocal 3
  0031    | PushEmptyArray
  0032    | GetBoundLocal 1
  0034    | Merge
  0035    | GetConstant2 448: [_]
  0038    | GetBoundLocal 5
  0040    | InsertAtIndex 0
  0042    | Merge
  0043    | CallTailFunction 2
  0045    | Jump 45 -> 63
  0048    | GetConstant2 446: __Table.RestPerRow
  0051    | GetBoundLocal 3
  0053    | PushEmptyArray
  0054    | GetBoundLocal 1
  0056    | Merge
  0057    | GetConstant2 449: [[]]
  0060    | Merge
  0061    | CallTailFunction 2
  0063    | Jump 63 -> 68
  0066    | GetBoundLocal 1
  0068    | End
  ========================================
  
  =========Table.RotateClockwise==========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant2 450: Array.Map
  0003    | GetConstant 100: Table.Transpose
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | GetConstant2 451: Array.Reverse
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  ======Table.RotateCounterClockwise======
  Table.RotateCounterClockwise(T) = Array.Reverse(Table.Transpose(T))
  ========================================
  0000    | GetConstant2 451: Array.Reverse
  0003    | GetConstant 100: Table.Transpose
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  ============Table.ZipObjects============
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant2 452: _Table.ZipObjects
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
  0000    | GetConstant2 441: Row
  0003    | GetConstant2 410: Rest
  0006    | SetInputMark
  0007    | GetBoundLocal 1
  0009    | Destructure 110: ([Row] + Rest)
  0011    | ConditionalThen 11 -> 45
  0014    | GetConstant2 452: _Table.ZipObjects
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 4
  0021    | PushEmptyArray
  0022    | GetBoundLocal 2
  0024    | Merge
  0025    | GetConstant2 453: [_]
  0028    | GetConstant2 454: Array.ZipObject
  0031    | GetBoundLocal 0
  0033    | GetBoundLocal 3
  0035    | CallFunction 2
  0037    | InsertAtIndex 0
  0039    | Merge
  0040    | CallTailFunction 3
  0042    | Jump 42 -> 47
  0045    | GetBoundLocal 2
  0047    | End
  ========================================
  
  ================Obj.Has=================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 111: ({K: _} + _)
  0005    | End
  ========================================
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushCharVar V
  0002    | PushUnderscoreVar
  0003    | GetBoundLocal 0
  0005    | Destructure 112: ({K: V} + _)
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
  0004    | GetConstant2 455: {_0_}
  0007    | GetBoundLocal 1
  0009    | GetBoundLocal 2
  0011    | InsertKeyVal 0
  0013    | Merge
  0014    | End
  ========================================
  
  =============_Ast.MergePos==============
  _Ast.MergePos(Left, Right) = {
    ...(Left -> {"startpos": StartPos, ..._} ? {"startpos": StartPos} : {}),
    ...(Right -> {"endpos": EndPos, ..._} ? {"endpos": EndPos} : {}),
  }
  ========================================
  0000    | GetConstant2 456: StartPos
  0003    | PushUnderscoreVar
  0004    | GetConstant2 457: EndPos
  0007    | PushEmptyObject
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 113: ({"startpos": StartPos} + _)
  0013    | ConditionalThen 13 -> 29
  0016    | GetConstant2 458: {_0_}
  0019    | GetConstant2 393: "startpos"
  0022    | GetBoundLocal 2
  0024    | InsertKeyVal 0
  0026    | Jump 26 -> 30
  0029    | PushEmptyObject
  0030    | Merge
  0031    | SetInputMark
  0032    | GetBoundLocal 1
  0034    | Destructure 114: ({"endpos": EndPos} + _)
  0036    | ConditionalThen 36 -> 52
  0039    | GetConstant2 459: {_0_}
  0042    | GetConstant2 394: "endpos"
  0045    | GetBoundLocal 4
  0047    | InsertKeyVal 0
  0049    | Jump 49 -> 53
  0052    | PushEmptyObject
  0053    | Merge
  0054    | End
  ========================================
  
  ===============Is.String================
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 115: ("" + _)
  0005    | End
  ========================================
  
  ===============Is.Number================
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 116: (0 + _)
  0005    | End
  ========================================
  
  ================Is.Bool=================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 117: (false + _)
  0005    | End
  ========================================
  
  ================Is.Null=================
  Is.Null(V) = V -> null
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 118: null
  0004    | End
  ========================================
  
  ================Is.Array================
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 119: ([] + _)
  0005    | End
  ========================================
  
  ===============Is.Object================
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocal 0
  0003    | Destructure 120: ({} + _)
  0005    | End
  ========================================
  
  ================Is.Equal================
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 121: B
  0004    | End
  ========================================
  
  ==============Is.LessThan===============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 122: B
  0005    | ConditionalThen 5 -> 16
  0008    | GetConstant2 361: @Fail
  0011    | CallTailFunction 0
  0013    | Jump 13 -> 20
  0016    | GetBoundLocal 0
  0018    | Destructure 123: ..B
  0020    | End
  ========================================
  
  ===========Is.LessThanOrEqual===========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 124: ..B
  0004    | End
  ========================================
  
  =============Is.GreaterThan=============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 125: B
  0005    | ConditionalThen 5 -> 16
  0008    | GetConstant2 361: @Fail
  0011    | CallTailFunction 0
  0013    | Jump 13 -> 20
  0016    | GetBoundLocal 0
  0018    | Destructure 126: B..
  0020    | End
  ========================================
  
  =========Is.GreaterThanOrEqual==========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 127: B..
  0004    | End
  ========================================
  
  ===============As.Number================
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | PushCharVar N
  0002    | SetInputMark
  0003    | GetConstant2 460: Is.Number
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Or 10 -> 22
  0013    | GetBoundLocal 0
  0015    | Destructure 128: "%(0 + N)"
  0017    | TakeRight 17 -> 22
  0020    | GetBoundLocal 1
  0022    | End
  ========================================
  
  ===============As.String================
  As.String(V) = "%(V)"
  ========================================
  0000    | PushEmptyString
  0001    | GetBoundLocal 0
  0003    | MergeAsString
  0004    | End
  ========================================

