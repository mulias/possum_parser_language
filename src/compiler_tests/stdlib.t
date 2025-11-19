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
  0001    | GetConstant 5: "0"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 6: "1"
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
  0002    | GetConstant 7: alnum
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn730=================
  unless(char, whitespace)
  ========================================
  0000    | GetConstant 9: unless
  0002    | GetConstant 10: char
  0004    | GetConstant 11: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  token = many(unless(char, whitespace))
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 8: @fn730
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn731=================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 7: alnum
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | GetConstant 13: "_"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 14: "-"
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  ==================word==================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 12: @fn731
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn732=================
  newline | end_of_input
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 17: newline
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 18: end_of_input
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==================line==================
  line = chars_until(newline | end_of_input)
  ========================================
  0000    | GetConstant 15: chars_until
  0002    | GetConstant 16: @fn732
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================space==================
  space =
    " " | "\t" | "\u0000A0" | "\u002000".."\u00200A" | "\u00202F" | "\u00205F" | "\u003000"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 19: " "
  0003    | CallFunction 0
  0005    | Or 5 -> 53
  0008    | SetInputMark
  0009    | GetConstant 20: "\t" (esc)
  0011    | CallFunction 0
  0013    | Or 13 -> 53
  0016    | SetInputMark
  0017    | GetConstant 21: "\xc2\xa0" (esc)
  0019    | CallFunction 0
  0021    | Or 21 -> 53
  0024    | SetInputMark
  0025    | GetConstant 22: "\xe2\x80\x80" (esc)
  0027    | GetConstant 23: "\xe2\x80\x8a" (esc)
  0029    | ParseRange
  0030    | Or 30 -> 53
  0033    | SetInputMark
  0034    | GetConstant 24: "\xe2\x80\xaf" (esc)
  0036    | CallFunction 0
  0038    | Or 38 -> 53
  0041    | SetInputMark
  0042    | GetConstant 25: "\xe2\x81\x9f" (esc)
  0044    | CallFunction 0
  0046    | Or 46 -> 53
  0049    | GetConstant 26: "\xe3\x80\x80" (esc)
  0051    | CallFunction 0
  0053    | End
  ========================================
  
  =================spaces=================
  spaces = many(space)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 27: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================newline=================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 28: "\r (esc)
  "
  0003    | CallFunction 0
  0005    | Or 5 -> 35
  0008    | SetInputMark
  0009    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0012    | Or 12 -> 35
  0015    | SetInputMark
  0016    | GetConstant 29: "\xc2\x85" (esc)
  0018    | CallFunction 0
  0020    | Or 20 -> 35
  0023    | SetInputMark
  0024    | GetConstant 30: "\xe2\x80\xa8" (esc)
  0026    | CallFunction 0
  0028    | Or 28 -> 35
  0031    | GetConstant 31: "\xe2\x80\xa9" (esc)
  0033    | CallFunction 0
  0035    | End
  ========================================
  
  ================newlines================
  newlines = many(newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 17: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn733=================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 27: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 17: newline
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ===============whitespace===============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 32: @fn733
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============chars_until===============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 33: many_until
  0002    | GetConstant 10: char
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
  
  =================@fn734=================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 14: "-"
  0004    | CallFunction 1
  0006    | GetConstant 37: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 34: as_number
  0002    | GetConstant 35: @fn734
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========non_negative_integer==========
  non_negative_integer = as_number(_number_integer_part)
  ========================================
  0000    | GetConstant 34: as_number
  0002    | GetConstant 37: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn735=================
  "-" + _number_integer_part
  ========================================
  0000    | GetConstant 14: "-"
  0002    | CallFunction 0
  0004    | GetConstant 37: _number_integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  ============negative_integer============
  negative_integer = as_number("-" + _number_integer_part)
  ========================================
  0000    | GetConstant 34: as_number
  0002    | GetConstant 38: @fn735
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn736=================
  maybe("-") + _number_integer_part + _number_fraction_part
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 14: "-"
  0004    | CallFunction 1
  0006    | GetConstant 37: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 40: _number_fraction_part
  0013    | CallFunction 0
  0015    | Merge
  0016    | End
  ========================================
  
  =================float==================
  float = as_number(maybe("-") + _number_integer_part + _number_fraction_part)
  ========================================
  0000    | GetConstant 34: as_number
  0002    | GetConstant 39: @fn736
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn737=================
  maybe("-") +
    _number_integer_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 14: "-"
  0004    | CallFunction 1
  0006    | GetConstant 37: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 42: _number_exponent_part
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
  0000    | GetConstant 34: as_number
  0002    | GetConstant 41: @fn737
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn738=================
  maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 14: "-"
  0004    | CallFunction 1
  0006    | GetConstant 37: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 40: _number_fraction_part
  0013    | CallFunction 0
  0015    | Merge
  0016    | GetConstant 42: _number_exponent_part
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
  0000    | GetConstant 34: as_number
  0002    | GetConstant 43: @fn738
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn739=================
  maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 14: "-"
  0004    | CallFunction 1
  0006    | GetConstant 37: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 36: maybe
  0013    | GetConstant 40: _number_fraction_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | GetConstant 36: maybe
  0020    | GetConstant 42: _number_exponent_part
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
  0000    | GetConstant 34: as_number
  0002    | GetConstant 44: @fn739
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn740=================
  _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 37: _number_integer_part
  0002    | CallFunction 0
  0004    | GetConstant 36: maybe
  0006    | GetConstant 40: _number_fraction_part
  0008    | CallFunction 1
  0010    | Merge
  0011    | GetConstant 36: maybe
  0013    | GetConstant 42: _number_exponent_part
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
  0000    | GetConstant 34: as_number
  0002    | GetConstant 45: @fn740
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn741=================
  "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 14: "-"
  0002    | CallFunction 0
  0004    | GetConstant 37: _number_integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | GetConstant 36: maybe
  0011    | GetConstant 40: _number_fraction_part
  0013    | CallFunction 1
  0015    | Merge
  0016    | GetConstant 36: maybe
  0018    | GetConstant 42: _number_exponent_part
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
  0000    | GetConstant 34: as_number
  0002    | GetConstant 46: @fn741
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_number_integer_part==========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | GetConstant 47: numerals
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
  0000    | GetConstant 48: "."
  0002    | CallFunction 0
  0004    | GetConstant 47: numerals
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  =================@fn742=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 14: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 52: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_number_exponent_part==========
  _number_exponent_part = ("e" | "E") + maybe("-" | "+") + numerals
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 49: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 50: "E"
  0010    | CallFunction 0
  0012    | GetConstant 36: maybe
  0014    | GetConstant 51: @fn742
  0016    | CallFunction 1
  0018    | Merge
  0019    | GetConstant 47: numerals
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
  0001    | GetConstant 53: digit
  0003    | CallFunction 0
  0005    | Or 5 -> 130
  0008    | SetInputMark
  0009    | SetInputMark
  0010    | GetConstant 54: "a"
  0012    | CallFunction 0
  0014    | Or 14 -> 21
  0017    | GetConstant 55: "A"
  0019    | CallFunction 0
  0021    | TakeRight 21 -> 26
  0024    | GetConstant 56: 10
  0026    | Or 26 -> 130
  0029    | SetInputMark
  0030    | SetInputMark
  0031    | GetConstant 57: "b"
  0033    | CallFunction 0
  0035    | Or 35 -> 42
  0038    | GetConstant 58: "B"
  0040    | CallFunction 0
  0042    | TakeRight 42 -> 47
  0045    | GetConstant 59: 11
  0047    | Or 47 -> 130
  0050    | SetInputMark
  0051    | SetInputMark
  0052    | GetConstant 60: "c"
  0054    | CallFunction 0
  0056    | Or 56 -> 63
  0059    | GetConstant 61: "C"
  0061    | CallFunction 0
  0063    | TakeRight 63 -> 68
  0066    | GetConstant 62: 12
  0068    | Or 68 -> 130
  0071    | SetInputMark
  0072    | SetInputMark
  0073    | GetConstant 63: "d"
  0075    | CallFunction 0
  0077    | Or 77 -> 84
  0080    | GetConstant 64: "D"
  0082    | CallFunction 0
  0084    | TakeRight 84 -> 89
  0087    | GetConstant 65: 13
  0089    | Or 89 -> 130
  0092    | SetInputMark
  0093    | SetInputMark
  0094    | GetConstant 49: "e"
  0096    | CallFunction 0
  0098    | Or 98 -> 105
  0101    | GetConstant 50: "E"
  0103    | CallFunction 0
  0105    | TakeRight 105 -> 110
  0108    | GetConstant 66: 14
  0110    | Or 110 -> 130
  0113    | SetInputMark
  0114    | GetConstant 67: "f"
  0116    | CallFunction 0
  0118    | Or 118 -> 125
  0121    | GetConstant 68: "F"
  0123    | CallFunction 0
  0125    | TakeRight 125 -> 130
  0128    | GetConstant 69: 15
  0130    | End
  ========================================
  
  =============binary_integer=============
  binary_integer = array(binary_digit) -> Digits $ Num.FromBinaryDigits(Digits)
  ========================================
  0000    | GetConstant 70: Digits
  0002    | GetConstant 71: array
  0004    | GetConstant 72: binary_digit
  0006    | CallFunction 1
  0008    | Destructure 0: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 73: Num.FromBinaryDigits
  0015    | GetBoundLocal 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  =============octal_integer==============
  octal_integer = array(octal_digit) -> Digits $ Num.FromOctalDigits(Digits)
  ========================================
  0000    | GetConstant 70: Digits
  0002    | GetConstant 71: array
  0004    | GetConstant 74: octal_digit
  0006    | CallFunction 1
  0008    | Destructure 0: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 75: Num.FromOctalDigits
  0015    | GetBoundLocal 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  ==============hex_integer===============
  hex_integer = array(hex_digit) -> Digits $ Num.FromHexDigits(Digits)
  ========================================
  0000    | GetConstant 70: Digits
  0002    | GetConstant 71: array
  0004    | GetConstant 76: hex_digit
  0006    | CallFunction 1
  0008    | Destructure 0: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 77: Num.FromHexDigits
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
  0001    | GetConstant 78: true
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 79: false
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
  0000    | GetConstant 80: null
  0002    | GetConstant 81: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 27
  0008    | Swap
  0009    | GetConstant 82: tuple1
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | Merge
  0016    | JumpIfFailure 16 -> 45
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 27
  0024    | JumpBack 24 -> 8
  0027    | Swap
  0028    | SetInputMark
  0029    | GetConstant 82: tuple1
  0031    | GetBoundLocal 0
  0033    | CallFunction 1
  0035    | JumpIfFailure 35 -> 43
  0038    | PopInputMark
  0039    | Merge
  0040    | JumpBack 40 -> 28
  0043    | ResetInput
  0044    | Drop
  0045    | Swap
  0046    | Drop
  0047    | End
  ========================================
  
  =================@fn743=================
  sep > elem
  ========================================
  0000    | GetConstant 85: sep
  0002    | GetConstant 86: elem
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn744=================
  sep > elem
  ========================================
  0000    | GetConstant 85: sep
  0002    | GetConstant 86: elem
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
  0000    | GetConstant 82: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | GetConstant 80: null
  0008    | GetConstant 83: 0
  0010    | ValidateRepeatPattern
  0011    | JumpIfZero 11 -> 39
  0014    | Swap
  0015    | GetConstant 82: tuple1
  0017    | GetConstant 84: @fn743
  0019    | CreateClosure 2
  0021    | CaptureLocal 1
  0023    | CaptureLocal 0
  0025    | CallFunction 1
  0027    | Merge
  0028    | JumpIfFailure 28 -> 63
  0031    | Swap
  0032    | Decrement
  0033    | JumpIfZero 33 -> 39
  0036    | JumpBack 36 -> 14
  0039    | Swap
  0040    | SetInputMark
  0041    | GetConstant 82: tuple1
  0043    | GetConstant 87: @fn744
  0045    | CreateClosure 2
  0047    | CaptureLocal 1
  0049    | CaptureLocal 0
  0051    | CallFunction 1
  0053    | JumpIfFailure 53 -> 61
  0056    | PopInputMark
  0057    | Merge
  0058    | JumpBack 58 -> 40
  0061    | ResetInput
  0062    | Drop
  0063    | Swap
  0064    | Drop
  0065    | Merge
  0066    | End
  ========================================
  
  =================@fn745=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 86: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 82: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn746=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 86: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 82: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============array_until===============
  array_until(elem, stop) = unless(tuple1(elem), stop) * 1.. < peek(stop)
  ========================================
  0000    | GetConstant 80: null
  0002    | GetConstant 81: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 33
  0008    | Swap
  0009    | GetConstant 9: unless
  0011    | GetConstant 88: @fn745
  0013    | CreateClosure 1
  0015    | CaptureLocal 0
  0017    | GetBoundLocal 1
  0019    | CallFunction 2
  0021    | Merge
  0022    | JumpIfFailure 22 -> 57
  0025    | Swap
  0026    | Decrement
  0027    | JumpIfZero 27 -> 33
  0030    | JumpBack 30 -> 8
  0033    | Swap
  0034    | SetInputMark
  0035    | GetConstant 9: unless
  0037    | GetConstant 89: @fn746
  0039    | CreateClosure 1
  0041    | CaptureLocal 0
  0043    | GetBoundLocal 1
  0045    | CallFunction 2
  0047    | JumpIfFailure 47 -> 55
  0050    | PopInputMark
  0051    | Merge
  0052    | JumpBack 52 -> 34
  0055    | ResetInput
  0056    | Drop
  0057    | Swap
  0058    | Drop
  0059    | JumpIfFailure 59 -> 69
  0062    | GetConstant 90: peek
  0064    | GetBoundLocal 1
  0066    | CallFunction 1
  0068    | TakeLeft
  0069    | End
  ========================================
  
  =================@fn747=================
  array(elem)
  ========================================
  0000    | GetConstant 86: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 71: array
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  maybe_array(elem) = default(array(elem), [])
  ========================================
  0000    | GetConstant 91: default
  0002    | GetConstant 92: @fn747
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | GetConstant 93: []
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  =================@fn749=================
  array_sep(elem, sep)
  ========================================
  0000    | GetConstant 86: elem
  0002    | GetConstant 85: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 95: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 91: default
  0002    | GetConstant 94: @fn749
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | GetConstant 96: []
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 97: Elem
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 0: Elem
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 98: [_]
  0013    | GetBoundLocal 1
  0015    | InsertAtIndex 0
  0017    | End
  ========================================
  
  =================tuple2=================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 99: E1
  0002    | GetConstant 100: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 0: E1
  0010    | TakeRight 10 -> 32
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | Destructure 1: E2
  0019    | TakeRight 19 -> 32
  0022    | GetConstant 101: [_, _]
  0024    | GetBoundLocal 2
  0026    | InsertAtIndex 0
  0028    | GetBoundLocal 3
  0030    | InsertAtIndex 1
  0032    | End
  ========================================
  
  ===============tuple2_sep===============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 99: E1
  0002    | GetConstant 100: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 0: E1
  0010    | TakeRight 10 -> 17
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 39
  0020    | GetBoundLocal 2
  0022    | CallFunction 0
  0024    | Destructure 1: E2
  0026    | TakeRight 26 -> 39
  0029    | GetConstant 102: [_, _]
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
  0000    | GetConstant 99: E1
  0002    | GetConstant 100: E2
  0004    | GetConstant 103: E3
  0006    | GetBoundLocal 0
  0008    | CallFunction 0
  0010    | Destructure 0: E1
  0012    | TakeRight 12 -> 21
  0015    | GetBoundLocal 1
  0017    | CallFunction 0
  0019    | Destructure 1: E2
  0021    | TakeRight 21 -> 47
  0024    | GetBoundLocal 2
  0026    | CallFunction 0
  0028    | Destructure 2: E3
  0030    | TakeRight 30 -> 47
  0033    | GetConstant 104: [_, _, _]
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
  0000    | GetConstant 99: E1
  0002    | GetConstant 100: E2
  0004    | GetConstant 103: E3
  0006    | GetBoundLocal 0
  0008    | CallFunction 0
  0010    | Destructure 0: E1
  0012    | TakeRight 12 -> 19
  0015    | GetBoundLocal 1
  0017    | CallFunction 0
  0019    | TakeRight 19 -> 28
  0022    | GetBoundLocal 2
  0024    | CallFunction 0
  0026    | Destructure 1: E2
  0028    | TakeRight 28 -> 35
  0031    | GetBoundLocal 3
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 61
  0038    | GetBoundLocal 4
  0040    | CallFunction 0
  0042    | Destructure 2: E3
  0044    | TakeRight 44 -> 61
  0047    | GetConstant 105: [_, _, _]
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
  0000    | GetConstant 80: null
  0002    | GetBoundLocal 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 28
  0008    | Swap
  0009    | GetConstant 82: tuple1
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | Merge
  0016    | JumpIfFailure 16 -> 27
  0019    | Swap
  0020    | Decrement
  0021    | JumpIfZero 21 -> 28
  0024    | JumpBack 24 -> 8
  0027    | Swap
  0028    | Drop
  0029    | End
  ========================================
  
  =================@fn756=================
  sep > elem
  ========================================
  0000    | GetConstant 85: sep
  0002    | GetConstant 86: elem
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
  0000    | GetConstant 82: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | GetConstant 80: null
  0008    | GetBoundLocal 2
  0010    | GetConstant 106: -1
  0012    | Merge
  0013    | ValidateRepeatPattern
  0014    | JumpIfZero 14 -> 43
  0017    | Swap
  0018    | GetConstant 82: tuple1
  0020    | GetConstant 107: @fn756
  0022    | CreateClosure 2
  0024    | CaptureLocal 1
  0026    | CaptureLocal 0
  0028    | CallFunction 1
  0030    | Merge
  0031    | JumpIfFailure 31 -> 42
  0034    | Swap
  0035    | Decrement
  0036    | JumpIfZero 36 -> 43
  0039    | JumpBack 39 -> 17
  0042    | Swap
  0043    | Drop
  0044    | Merge
  0045    | End
  ========================================
  
  =================@fn757=================
  array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 86: elem
  0002    | GetConstant 109: col_sep
  0004    | SetClosureCaptures
  0005    | GetConstant 95: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn758=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 111: row_sep
  0002    | GetConstant 86: elem
  0004    | GetConstant 109: col_sep
  0006    | SetClosureCaptures
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 22
  0014    | GetConstant 95: array_sep
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | CallTailFunction 2
  0022    | End
  ========================================
  
  =================@fn759=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 111: row_sep
  0002    | GetConstant 86: elem
  0004    | GetConstant 109: col_sep
  0006    | SetClosureCaptures
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 22
  0014    | GetConstant 95: array_sep
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
  0000    | GetConstant 82: tuple1
  0002    | GetConstant 108: @fn757
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | GetConstant 80: null
  0014    | GetConstant 83: 0
  0016    | ValidateRepeatPattern
  0017    | JumpIfZero 17 -> 47
  0020    | Swap
  0021    | GetConstant 82: tuple1
  0023    | GetConstant 110: @fn758
  0025    | CreateClosure 3
  0027    | CaptureLocal 2
  0029    | CaptureLocal 0
  0031    | CaptureLocal 1
  0033    | CallFunction 1
  0035    | Merge
  0036    | JumpIfFailure 36 -> 73
  0039    | Swap
  0040    | Decrement
  0041    | JumpIfZero 41 -> 47
  0044    | JumpBack 44 -> 20
  0047    | Swap
  0048    | SetInputMark
  0049    | GetConstant 82: tuple1
  0051    | GetConstant 112: @fn759
  0053    | CreateClosure 3
  0055    | CaptureLocal 2
  0057    | CaptureLocal 0
  0059    | CaptureLocal 1
  0061    | CallFunction 1
  0063    | JumpIfFailure 63 -> 71
  0066    | PopInputMark
  0067    | Merge
  0068    | JumpBack 68 -> 48
  0071    | ResetInput
  0072    | Drop
  0073    | Swap
  0074    | Drop
  0075    | Merge
  0076    | End
  ========================================
  
  =================@fn760=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | GetConstant 86: elem
  0002    | GetConstant 109: col_sep
  0004    | GetConstant 111: row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 117: _dimensions
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
  0000    | GetConstant 113: MaxRowLen
  0002    | GetConstant 114: _
  0004    | GetConstant 115: First
  0006    | GetConstant 90: peek
  0008    | GetConstant 116: @fn760
  0010    | CreateClosure 3
  0012    | CaptureLocal 0
  0014    | CaptureLocal 1
  0016    | CaptureLocal 2
  0018    | CallFunction 1
  0020    | Destructure 0: [MaxRowLen, _]
  0022    | TakeRight 22 -> 31
  0025    | GetBoundLocal 0
  0027    | CallFunction 0
  0029    | Destructure 1: First
  0031    | TakeRight 31 -> 58
  0034    | GetConstant 118: _rows_padded
  0036    | GetBoundLocal 0
  0038    | GetBoundLocal 1
  0040    | GetBoundLocal 2
  0042    | GetBoundLocal 3
  0044    | GetConstant 81: 1
  0046    | GetBoundLocal 4
  0048    | GetConstant 119: [_]
  0050    | GetBoundLocal 6
  0052    | InsertAtIndex 0
  0054    | GetConstant 120: []
  0056    | CallTailFunction 8
  0058    | End
  ========================================
  
  ==============_rows_padded==============
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    col_sep > elem -> Elem ?
    _rows_padded(elem, col_sep, row_sep, Pad, Num.Inc(RowLen), MaxRowLen, [...AccRow, Elem], AccRows) :
    row_sep > elem -> NextRow ?
    _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [NextRow], [...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)]) :
    const([...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)])
  ========================================
  0000    | GetConstant 97: Elem
  0002    | GetConstant 121: NextRow
  0004    | SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | Destructure 0: Elem
  0018    | ConditionalThen 18 -> 58
  0021    | GetConstant 118: _rows_padded
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | GetBoundLocal 2
  0029    | GetBoundLocal 3
  0031    | GetConstant 122: Num.Inc
  0033    | GetBoundLocal 4
  0035    | CallFunction 1
  0037    | GetBoundLocal 5
  0039    | GetConstant 123: []
  0041    | GetBoundLocal 6
  0043    | Merge
  0044    | GetConstant 124: [_]
  0046    | GetBoundLocal 8
  0048    | InsertAtIndex 0
  0050    | Merge
  0051    | GetBoundLocal 7
  0053    | CallTailFunction 8
  0055    | Jump 55 -> 152
  0058    | SetInputMark
  0059    | GetBoundLocal 2
  0061    | CallFunction 0
  0063    | TakeRight 63 -> 70
  0066    | GetBoundLocal 0
  0068    | CallFunction 0
  0070    | Destructure 1: NextRow
  0072    | ConditionalThen 72 -> 124
  0075    | GetConstant 118: _rows_padded
  0077    | GetBoundLocal 0
  0079    | GetBoundLocal 1
  0081    | GetBoundLocal 2
  0083    | GetBoundLocal 3
  0085    | GetConstant 81: 1
  0087    | GetBoundLocal 5
  0089    | GetConstant 125: [_]
  0091    | GetBoundLocal 9
  0093    | InsertAtIndex 0
  0095    | GetConstant 126: []
  0097    | GetBoundLocal 7
  0099    | Merge
  0100    | GetConstant 127: [_]
  0102    | GetConstant 128: Array.AppendN
  0104    | GetBoundLocal 6
  0106    | GetBoundLocal 3
  0108    | GetBoundLocal 5
  0110    | GetBoundLocal 4
  0112    | NegateNumber
  0113    | Merge
  0114    | CallFunction 3
  0116    | InsertAtIndex 0
  0118    | Merge
  0119    | CallTailFunction 8
  0121    | Jump 121 -> 152
  0124    | GetConstant 129: const
  0126    | GetConstant 130: []
  0128    | GetBoundLocal 7
  0130    | Merge
  0131    | GetConstant 131: [_]
  0133    | GetConstant 128: Array.AppendN
  0135    | GetBoundLocal 6
  0137    | GetBoundLocal 3
  0139    | GetBoundLocal 5
  0141    | GetBoundLocal 4
  0143    | NegateNumber
  0144    | Merge
  0145    | CallFunction 3
  0147    | InsertAtIndex 0
  0149    | Merge
  0150    | CallTailFunction 1
  0152    | End
  ========================================
  
  ==============_dimensions===============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 23
  0007    | GetConstant 132: __dimensions
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 2
  0015    | GetConstant 81: 1
  0017    | GetConstant 81: 1
  0019    | GetConstant 83: 0
  0021    | CallTailFunction 6
  0023    | End
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
  0015    | GetConstant 132: __dimensions
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 2
  0023    | GetConstant 122: Num.Inc
  0025    | GetBoundLocal 3
  0027    | CallFunction 1
  0029    | GetBoundLocal 4
  0031    | GetBoundLocal 5
  0033    | CallTailFunction 6
  0035    | Jump 35 -> 102
  0038    | SetInputMark
  0039    | GetBoundLocal 2
  0041    | CallFunction 0
  0043    | TakeRight 43 -> 50
  0046    | GetBoundLocal 0
  0048    | CallFunction 0
  0050    | ConditionalThen 50 -> 82
  0053    | GetConstant 132: __dimensions
  0055    | GetBoundLocal 0
  0057    | GetBoundLocal 1
  0059    | GetBoundLocal 2
  0061    | GetConstant 81: 1
  0063    | GetConstant 122: Num.Inc
  0065    | GetBoundLocal 4
  0067    | CallFunction 1
  0069    | GetConstant 133: Num.Max
  0071    | GetBoundLocal 3
  0073    | GetBoundLocal 5
  0075    | CallFunction 2
  0077    | CallTailFunction 6
  0079    | Jump 79 -> 102
  0082    | GetConstant 129: const
  0084    | GetConstant 134: [_, _]
  0086    | GetConstant 133: Num.Max
  0088    | GetBoundLocal 3
  0090    | GetBoundLocal 5
  0092    | CallFunction 2
  0094    | InsertAtIndex 0
  0096    | GetBoundLocal 4
  0098    | InsertAtIndex 1
  0100    | CallTailFunction 1
  0102    | End
  ========================================
  
  ================columns=================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant 135: Rows
  0002    | GetConstant 136: rows
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | CallFunction 3
  0012    | Destructure 0: Rows
  0014    | TakeRight 14 -> 23
  0017    | GetConstant 137: Table.Transpose
  0019    | GetBoundLocal 3
  0021    | CallTailFunction 1
  0023    | End
  ========================================
  
  =============columns_padded=============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant 135: Rows
  0002    | GetConstant 138: rows_padded
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | GetBoundLocal 3
  0012    | CallFunction 4
  0014    | Destructure 0: Rows
  0016    | TakeRight 16 -> 25
  0019    | GetConstant 137: Table.Transpose
  0021    | GetBoundLocal 4
  0023    | CallTailFunction 1
  0025    | End
  ========================================
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | GetConstant 80: null
  0002    | GetConstant 81: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 29
  0008    | Swap
  0009    | GetConstant 139: pair
  0011    | GetBoundLocal 0
  0013    | GetBoundLocal 1
  0015    | CallFunction 2
  0017    | Merge
  0018    | JumpIfFailure 18 -> 49
  0021    | Swap
  0022    | Decrement
  0023    | JumpIfZero 23 -> 29
  0026    | JumpBack 26 -> 8
  0029    | Swap
  0030    | SetInputMark
  0031    | GetConstant 139: pair
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | CallFunction 2
  0039    | JumpIfFailure 39 -> 47
  0042    | PopInputMark
  0043    | Merge
  0044    | JumpBack 44 -> 30
  0047    | ResetInput
  0048    | Drop
  0049    | Swap
  0050    | Drop
  0051    | End
  ========================================
  
  ===============object_sep===============
  object_sep(key, kv_sep, value, sep) =
    pair_sep(key, kv_sep, value) +
    ((sep > pair_sep(key, kv_sep, value)) * 0..)
  ========================================
  0000    | GetConstant 140: pair_sep
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | CallFunction 3
  0010    | GetConstant 80: null
  0012    | GetConstant 83: 0
  0014    | ValidateRepeatPattern
  0015    | JumpIfZero 15 -> 48
  0018    | Swap
  0019    | GetBoundLocal 3
  0021    | CallFunction 0
  0023    | TakeRight 23 -> 36
  0026    | GetConstant 140: pair_sep
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 1
  0032    | GetBoundLocal 2
  0034    | CallFunction 3
  0036    | Merge
  0037    | JumpIfFailure 37 -> 77
  0040    | Swap
  0041    | Decrement
  0042    | JumpIfZero 42 -> 48
  0045    | JumpBack 45 -> 18
  0048    | Swap
  0049    | SetInputMark
  0050    | GetBoundLocal 3
  0052    | CallFunction 0
  0054    | TakeRight 54 -> 67
  0057    | GetConstant 140: pair_sep
  0059    | GetBoundLocal 0
  0061    | GetBoundLocal 1
  0063    | GetBoundLocal 2
  0065    | CallFunction 3
  0067    | JumpIfFailure 67 -> 75
  0070    | PopInputMark
  0071    | Merge
  0072    | JumpBack 72 -> 49
  0075    | ResetInput
  0076    | Drop
  0077    | Swap
  0078    | Drop
  0079    | Merge
  0080    | End
  ========================================
  
  =================@fn771=================
  pair(key, value)
  ========================================
  0000    | GetConstant 142: key
  0002    | GetConstant 143: value
  0004    | SetClosureCaptures
  0005    | GetConstant 139: pair
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn772=================
  pair(key, value)
  ========================================
  0000    | GetConstant 142: key
  0002    | GetConstant 143: value
  0004    | SetClosureCaptures
  0005    | GetConstant 139: pair
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============object_until==============
  object_until(key, value, stop) =
    unless(pair(key, value), stop) * 1.. < peek(stop)
  ========================================
  0000    | GetConstant 80: null
  0002    | GetConstant 81: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 35
  0008    | Swap
  0009    | GetConstant 9: unless
  0011    | GetConstant 141: @fn771
  0013    | CreateClosure 2
  0015    | CaptureLocal 0
  0017    | CaptureLocal 1
  0019    | GetBoundLocal 2
  0021    | CallFunction 2
  0023    | Merge
  0024    | JumpIfFailure 24 -> 61
  0027    | Swap
  0028    | Decrement
  0029    | JumpIfZero 29 -> 35
  0032    | JumpBack 32 -> 8
  0035    | Swap
  0036    | SetInputMark
  0037    | GetConstant 9: unless
  0039    | GetConstant 144: @fn772
  0041    | CreateClosure 2
  0043    | CaptureLocal 0
  0045    | CaptureLocal 1
  0047    | GetBoundLocal 2
  0049    | CallFunction 2
  0051    | JumpIfFailure 51 -> 59
  0054    | PopInputMark
  0055    | Merge
  0056    | JumpBack 56 -> 36
  0059    | ResetInput
  0060    | Drop
  0061    | Swap
  0062    | Drop
  0063    | JumpIfFailure 63 -> 73
  0066    | GetConstant 90: peek
  0068    | GetBoundLocal 2
  0070    | CallFunction 1
  0072    | TakeLeft
  0073    | End
  ========================================
  
  =================@fn773=================
  object(key, value)
  ========================================
  0000    | GetConstant 142: key
  0002    | GetConstant 143: value
  0004    | SetClosureCaptures
  0005    | GetConstant 146: object
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  maybe_object(key, value) = default(object(key, value), {})
  ========================================
  0000    | GetConstant 91: default
  0002    | GetConstant 145: @fn773
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | GetConstant 147: {}
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================@fn775=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | GetConstant 142: key
  0002    | GetConstant 149: pair_sep
  0004    | GetConstant 143: value
  0006    | GetConstant 85: sep
  0008    | SetClosureCaptures
  0009    | GetConstant 150: object_sep
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
  0000    | GetConstant 91: default
  0002    | GetConstant 148: @fn775
  0004    | CreateClosure 4
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CaptureLocal 2
  0012    | CaptureLocal 3
  0014    | GetConstant 151: {}
  0016    | CallTailFunction 2
  0018    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | GetConstant 152: K
  0002    | GetConstant 153: V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 30
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | Destructure 1: V
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 154: {_0_}
  0024    | GetBoundLocal 2
  0026    | GetBoundLocal 3
  0028    | InsertKeyVal 0
  0030    | End
  ========================================
  
  ================pair_sep================
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | GetConstant 152: K
  0002    | GetConstant 153: V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 17
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 37
  0020    | GetBoundLocal 2
  0022    | CallFunction 0
  0024    | Destructure 1: V
  0026    | TakeRight 26 -> 37
  0029    | GetConstant 155: {_0_}
  0031    | GetBoundLocal 3
  0033    | GetBoundLocal 4
  0035    | InsertKeyVal 0
  0037    | End
  ========================================
  
  ================record1=================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | GetConstant 156: Value
  0002    | GetBoundLocal 1
  0004    | CallFunction 0
  0006    | Destructure 0: Value
  0008    | TakeRight 8 -> 19
  0011    | GetConstant 157: {_0_}
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
  0000    | GetConstant 158: V1
  0002    | GetConstant 159: V2
  0004    | GetBoundLocal 1
  0006    | CallFunction 0
  0008    | Destructure 0: V1
  0010    | TakeRight 10 -> 36
  0013    | GetBoundLocal 3
  0015    | CallFunction 0
  0017    | Destructure 1: V2
  0019    | TakeRight 19 -> 36
  0022    | GetConstant 160: {_0_, _1_}
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
  0000    | GetConstant 158: V1
  0002    | GetConstant 159: V2
  0004    | GetBoundLocal 1
  0006    | CallFunction 0
  0008    | Destructure 0: V1
  0010    | TakeRight 10 -> 17
  0013    | GetBoundLocal 2
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 43
  0020    | GetBoundLocal 4
  0022    | CallFunction 0
  0024    | Destructure 1: V2
  0026    | TakeRight 26 -> 43
  0029    | GetConstant 161: {_0_, _1_}
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
  0000    | GetConstant 158: V1
  0002    | GetConstant 159: V2
  0004    | GetConstant 162: V3
  0006    | GetBoundLocal 1
  0008    | CallFunction 0
  0010    | Destructure 0: V1
  0012    | TakeRight 12 -> 21
  0015    | GetBoundLocal 3
  0017    | CallFunction 0
  0019    | Destructure 1: V2
  0021    | TakeRight 21 -> 53
  0024    | GetBoundLocal 5
  0026    | CallFunction 0
  0028    | Destructure 2: V3
  0030    | TakeRight 30 -> 53
  0033    | GetConstant 163: {_0_, _1_, _2_}
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
  0000    | GetConstant 158: V1
  0002    | GetConstant 159: V2
  0004    | GetConstant 162: V3
  0006    | GetBoundLocal 1
  0008    | CallFunction 0
  0010    | Destructure 0: V1
  0012    | TakeRight 12 -> 19
  0015    | GetBoundLocal 2
  0017    | CallFunction 0
  0019    | TakeRight 19 -> 28
  0022    | GetBoundLocal 4
  0024    | CallFunction 0
  0026    | Destructure 1: V2
  0028    | TakeRight 28 -> 35
  0031    | GetBoundLocal 5
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 67
  0038    | GetBoundLocal 7
  0040    | CallFunction 0
  0042    | Destructure 2: V3
  0044    | TakeRight 44 -> 67
  0047    | GetConstant 164: {_0_, _1_, _2_}
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
  0000    | GetConstant 80: null
  0002    | GetConstant 81: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 25
  0008    | Swap
  0009    | GetBoundLocal 0
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 41
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 8
  0025    | Swap
  0026    | SetInputMark
  0027    | GetBoundLocal 0
  0029    | CallFunction 0
  0031    | JumpIfFailure 31 -> 39
  0034    | PopInputMark
  0035    | Merge
  0036    | JumpBack 36 -> 26
  0039    | ResetInput
  0040    | Drop
  0041    | Swap
  0042    | Drop
  0043    | End
  ========================================
  
  ================many_sep================
  many_sep(p, sep) = p + ((sep > p) * 0..)
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | GetConstant 80: null
  0006    | GetConstant 83: 0
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 36
  0012    | Swap
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 24
  0020    | GetBoundLocal 0
  0022    | CallFunction 0
  0024    | Merge
  0025    | JumpIfFailure 25 -> 59
  0028    | Swap
  0029    | Decrement
  0030    | JumpIfZero 30 -> 36
  0033    | JumpBack 33 -> 12
  0036    | Swap
  0037    | SetInputMark
  0038    | GetBoundLocal 1
  0040    | CallFunction 0
  0042    | TakeRight 42 -> 49
  0045    | GetBoundLocal 0
  0047    | CallFunction 0
  0049    | JumpIfFailure 49 -> 57
  0052    | PopInputMark
  0053    | Merge
  0054    | JumpBack 54 -> 37
  0057    | ResetInput
  0058    | Drop
  0059    | Swap
  0060    | Drop
  0061    | Merge
  0062    | End
  ========================================
  
  ===============many_until===============
  many_until(p, stop) = unless(p, stop) * 1.. < peek(stop)
  ========================================
  0000    | GetConstant 80: null
  0002    | GetConstant 81: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 29
  0008    | Swap
  0009    | GetConstant 9: unless
  0011    | GetBoundLocal 0
  0013    | GetBoundLocal 1
  0015    | CallFunction 2
  0017    | Merge
  0018    | JumpIfFailure 18 -> 49
  0021    | Swap
  0022    | Decrement
  0023    | JumpIfZero 23 -> 29
  0026    | JumpBack 26 -> 8
  0029    | Swap
  0030    | SetInputMark
  0031    | GetConstant 9: unless
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | CallFunction 2
  0039    | JumpIfFailure 39 -> 47
  0042    | PopInputMark
  0043    | Merge
  0044    | JumpBack 44 -> 30
  0047    | ResetInput
  0048    | Drop
  0049    | Swap
  0050    | Drop
  0051    | JumpIfFailure 51 -> 61
  0054    | GetConstant 90: peek
  0056    | GetBoundLocal 1
  0058    | CallFunction 1
  0060    | TakeLeft
  0061    | End
  ========================================
  
  ===============maybe_many===============
  maybe_many(p) = p * 0..
  ========================================
  0000    | GetConstant 80: null
  0002    | GetConstant 83: 0
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 25
  0008    | Swap
  0009    | GetBoundLocal 0
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 41
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 25
  0022    | JumpBack 22 -> 8
  0025    | Swap
  0026    | SetInputMark
  0027    | GetBoundLocal 0
  0029    | CallFunction 0
  0031    | JumpIfFailure 31 -> 39
  0034    | PopInputMark
  0035    | Merge
  0036    | JumpBack 36 -> 26
  0039    | ResetInput
  0040    | Drop
  0041    | Swap
  0042    | Drop
  0043    | End
  ========================================
  
  =============maybe_many_sep=============
  maybe_many_sep(p, sep) = many_sep(p, sep) | succeed
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 165: many_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | Or 9 -> 16
  0012    | GetConstant 166: succeed
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ==================peek==================
  peek(p) = p -> V ! const(V)
  ========================================
  0000    | GetConstant 153: V
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | Destructure 0: V
  0009    | Backtrack 9 -> 18
  0012    | GetConstant 129: const
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
  0008    | GetConstant 166: succeed
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
  0008    | GetConstant 167: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 19
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  ==================skip==================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 168: null
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
  0008    | GetConstant 10: char
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 21
  0015    | GetConstant 169: find
  0017    | GetBoundLocal 0
  0019    | CallTailFunction 1
  0021    | End
  ========================================
  
  =================@fn784=================
  find(p)
  ========================================
  0000    | GetConstant 171: p
  0002    | SetClosureCaptures
  0003    | GetConstant 169: find
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn785=================
  many(char)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 10: char
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================find_all================
  find_all(p) = array(find(p)) < maybe(many(char))
  ========================================
  0000    | GetConstant 71: array
  0002    | GetConstant 170: @fn784
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 20
  0013    | GetConstant 36: maybe
  0015    | GetConstant 172: @fn785
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
  0008    | GetConstant 167: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 38
  0015    | SetInputMark
  0016    | GetBoundLocal 0
  0018    | CallFunction 0
  0020    | Or 20 -> 38
  0023    | GetConstant 10: char
  0025    | CallFunction 0
  0027    | TakeRight 27 -> 38
  0030    | GetConstant 173: find_before
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallTailFunction 2
  0038    | End
  ========================================
  
  =================@fn786=================
  find_before(p, stop)
  ========================================
  0000    | GetConstant 171: p
  0002    | GetConstant 175: stop
  0004    | SetClosureCaptures
  0005    | GetConstant 173: find_before
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn787=================
  chars_until(stop)
  ========================================
  0000    | GetConstant 175: stop
  0002    | SetClosureCaptures
  0003    | GetConstant 15: chars_until
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ============find_all_before=============
  find_all_before(p, stop) = array(find_before(p, stop)) < maybe(chars_until(stop))
  ========================================
  0000    | GetConstant 71: array
  0002    | GetConstant 174: @fn786
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 26
  0015    | GetConstant 36: maybe
  0017    | GetConstant 176: @fn787
  0019    | CreateClosure 1
  0021    | CaptureLocal 1
  0023    | CallFunction 1
  0025    | TakeLeft
  0026    | End
  ========================================
  
  ================succeed=================
  succeed = const($null)
  ========================================
  0000    | GetConstant 129: const
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
  0008    | GetConstant 129: const
  0010    | GetBoundLocal 1
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetConstant 177: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 9
  0007    | GetBoundLocal 0
  0009    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | GetConstant 178: N
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 0: "%(0 + N)"
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 1
  0013    | End
  ========================================
  
  ===============as_string================
  as_string(p) = "%(p)"
  ========================================
  0000    | GetConstant 177: ""
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | MergeAsString
  0007    | End
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
  0001    | GetConstant 10: char
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 167: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 19
  0015    | GetConstant 166: succeed
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  =================@fn788=================
  maybe(whitespace)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  input(p) = surround(p, maybe(whitespace)) < end_of_input
  ========================================
  0000    | GetConstant 179: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant 180: @fn788
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 16
  0011    | GetConstant 18: end_of_input
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
  0005    | GetConstant 36: maybe
  0007    | GetBoundLocal 1
  0009    | CallFunction 1
  0011    | Merge
  0012    | Or 12 -> 26
  0015    | GetConstant 36: maybe
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
  0001    | GetConstant 181: json.boolean
  0003    | CallFunction 0
  0005    | Or 5 -> 48
  0008    | SetInputMark
  0009    | GetConstant 182: json.null
  0011    | CallFunction 0
  0013    | Or 13 -> 48
  0016    | SetInputMark
  0017    | GetConstant 183: number
  0019    | CallFunction 0
  0021    | Or 21 -> 48
  0024    | SetInputMark
  0025    | GetConstant 184: json.string
  0027    | CallFunction 0
  0029    | Or 29 -> 48
  0032    | SetInputMark
  0033    | GetConstant 185: json.array
  0035    | GetConstant 186: json
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042    | GetConstant 187: json.object
  0044    | GetConstant 186: json
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  ==============json.boolean==============
  json.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 188: boolean
  0002    | GetConstant 189: "true"
  0004    | GetConstant 190: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============json.null================
  json.null = null("null")
  ========================================
  0000    | GetConstant 168: null
  0002    | GetConstant 191: "null"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============json.string===============
  json.string = '"' > _json.string_body < '"'
  ========================================
  0000    | GetConstant 192: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 193: _json.string_body
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetConstant 192: """
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =================@fn790=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 198: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | GetConstant 199: "\"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 192: """
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn789=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 195: _escaped_ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 24
  0008    | SetInputMark
  0009    | GetConstant 196: _escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 24
  0016    | GetConstant 9: unless
  0018    | GetConstant 10: char
  0020    | GetConstant 197: @fn790
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
  0003    | GetConstant 194: @fn789
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 129: const
  0012    | GetConstant 177: ""
  0014    | CallTailFunction 1
  0016    | End
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
  0001    | GetConstant 200: "\""
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | GetConstant 192: """
  0010    | Or 10 -> 100
  0013    | SetInputMark
  0014    | GetConstant 201: "\\"
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 23
  0021    | GetConstant 199: "\"
  0023    | Or 23 -> 100
  0026    | SetInputMark
  0027    | GetConstant 202: "\/"
  0029    | CallFunction 0
  0031    | TakeRight 31 -> 36
  0034    | GetConstant 203: "/"
  0036    | Or 36 -> 100
  0039    | SetInputMark
  0040    | GetConstant 204: "\b"
  0042    | CallFunction 0
  0044    | TakeRight 44 -> 49
  0047    | GetConstant 205: "\x08" (esc)
  0049    | Or 49 -> 100
  0052    | SetInputMark
  0053    | GetConstant 206: "\f"
  0055    | CallFunction 0
  0057    | TakeRight 57 -> 62
  0060    | GetConstant 207: "\x0c" (esc)
  0062    | Or 62 -> 100
  0065    | SetInputMark
  0066    | GetConstant 208: "\n"
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 75
  0073    | GetConstant 209: "
  "
  0075    | Or 75 -> 100
  0078    | SetInputMark
  0079    | GetConstant 210: "\r"
  0081    | CallFunction 0
  0083    | TakeRight 83 -> 88
  0086    | GetConstant 211: "\r (no-eol) (esc)
  "
  0088    | Or 88 -> 100
  0091    | GetConstant 212: "\t"
  0093    | CallFunction 0
  0095    | TakeRight 95 -> 100
  0098    | GetConstant 20: "\t" (esc)
  0100    | End
  ========================================
  
  ============_escaped_unicode============
  _escaped_unicode = _escaped_surrogate_pair | _escaped_codepoint
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 213: _escaped_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 214: _escaped_codepoint
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========_escaped_surrogate_pair=========
  _escaped_surrogate_pair = _valid_surrogate_pair | _invalid_surrogate_pair
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 215: _valid_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 216: _invalid_surrogate_pair
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_valid_surrogate_pair==========
  _valid_surrogate_pair =
    _high_surrogate -> H & _low_surrogate -> L $ @SurrogatePairCodepoint(H, L)
  ========================================
  0000    | GetConstant 217: H
  0002    | GetConstant 218: L
  0004    | GetConstant 219: _high_surrogate
  0006    | CallFunction 0
  0008    | Destructure 0: H
  0010    | TakeRight 10 -> 30
  0013    | GetConstant 220: _low_surrogate
  0015    | CallFunction 0
  0017    | Destructure 1: L
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 221: @SurrogatePairCodepoint
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ========_invalid_surrogate_pair=========
  _invalid_surrogate_pair = _low_surrogate | _high_surrogate $ "\u00FFFD"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 220: _low_surrogate
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 219: _high_surrogate
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 17
  0015    | GetConstant 222: "\xef\xbf\xbd" (esc)
  0017    | End
  ========================================
  
  ============_high_surrogate=============
  _high_surrogate =
    `\u` > ("D" | "d") + ("8" | "9" | "A" | "B" | "a" | "b") + hex_numeral + hex_numeral
  ========================================
  0000    | GetConstant 223: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | GetConstant 64: "D"
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | GetConstant 63: "d"
  0017    | CallFunction 0
  0019    | SetInputMark
  0020    | GetConstant 224: "8"
  0022    | CallFunction 0
  0024    | Or 24 -> 63
  0027    | SetInputMark
  0028    | GetConstant 225: "9"
  0030    | CallFunction 0
  0032    | Or 32 -> 63
  0035    | SetInputMark
  0036    | GetConstant 55: "A"
  0038    | CallFunction 0
  0040    | Or 40 -> 63
  0043    | SetInputMark
  0044    | GetConstant 58: "B"
  0046    | CallFunction 0
  0048    | Or 48 -> 63
  0051    | SetInputMark
  0052    | GetConstant 54: "a"
  0054    | CallFunction 0
  0056    | Or 56 -> 63
  0059    | GetConstant 57: "b"
  0061    | CallFunction 0
  0063    | Merge
  0064    | GetConstant 226: hex_numeral
  0066    | CallFunction 0
  0068    | Merge
  0069    | GetConstant 226: hex_numeral
  0071    | CallFunction 0
  0073    | Merge
  0074    | End
  ========================================
  
  =============_low_surrogate=============
  _low_surrogate =
    `\u` > ("D" | "d") + ("C".."F" | "c".."f") + hex_numeral + hex_numeral
  ========================================
  0000    | GetConstant 223: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | GetConstant 64: "D"
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | GetConstant 63: "d"
  0017    | CallFunction 0
  0019    | SetInputMark
  0020    | ParseCodepointRange 'C'..'F'
  0023    | Or 23 -> 29
  0026    | ParseCodepointRange 'c'..'f'
  0029    | Merge
  0030    | GetConstant 226: hex_numeral
  0032    | CallFunction 0
  0034    | Merge
  0035    | GetConstant 226: hex_numeral
  0037    | CallFunction 0
  0039    | Merge
  0040    | End
  ========================================
  
  ===========_escaped_codepoint===========
  _escaped_codepoint = `\u` > (hex_numeral * 4) -> U $ @Codepoint(U)
  ========================================
  0000    | GetConstant 227: U
  0002    | GetConstant 223: "\u"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 36
  0009    | GetConstant 80: null
  0011    | GetConstant 228: 4
  0013    | ValidateRepeatPattern
  0014    | JumpIfZero 14 -> 35
  0017    | Swap
  0018    | GetConstant 226: hex_numeral
  0020    | CallFunction 0
  0022    | Merge
  0023    | JumpIfFailure 23 -> 34
  0026    | Swap
  0027    | Decrement
  0028    | JumpIfZero 28 -> 35
  0031    | JumpBack 31 -> 17
  0034    | Swap
  0035    | Drop
  0036    | Destructure 0: U
  0038    | TakeRight 38 -> 47
  0041    | GetConstant 229: @Codepoint
  0043    | GetBoundLocal 0
  0045    | CallTailFunction 1
  0047    | End
  ========================================
  
  =================@fn792=================
  maybe(ws)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn791=================
  surround(elem, maybe(ws))
  ========================================
  0000    | GetConstant 86: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 179: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 233: @fn792
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===============json.array===============
  json.array(elem) = "[" > maybe_array_sep(surround(elem, maybe(ws)), ",") < "]"
  ========================================
  0000    | GetConstant 230: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | GetConstant 231: maybe_array_sep
  0009    | GetConstant 232: @fn791
  0011    | CreateClosure 1
  0013    | CaptureLocal 0
  0015    | GetConstant 234: ","
  0017    | CallFunction 2
  0019    | JumpIfFailure 19 -> 27
  0022    | GetConstant 235: "]"
  0024    | CallFunction 0
  0026    | TakeLeft
  0027    | End
  ========================================
  
  =================@fn794=================
  maybe(ws)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn793=================
  surround(json.string, maybe(ws))
  ========================================
  0000    | GetConstant 179: surround
  0002    | GetConstant 184: json.string
  0004    | GetConstant 239: @fn794
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn796=================
  maybe(ws)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn795=================
  surround(value, maybe(ws))
  ========================================
  0000    | GetConstant 143: value
  0002    | SetClosureCaptures
  0003    | GetConstant 179: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 242: @fn796
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
  0000    | GetConstant 236: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 23
  0007    | GetConstant 237: maybe_object_sep
  0009    | GetConstant 238: @fn793
  0011    | GetConstant 240: ":"
  0013    | GetConstant 241: @fn795
  0015    | CreateClosure 1
  0017    | CaptureLocal 0
  0019    | GetConstant 234: ","
  0021    | CallFunction 4
  0023    | JumpIfFailure 23 -> 31
  0026    | GetConstant 243: "}"
  0028    | CallFunction 0
  0030    | TakeLeft
  0031    | End
  ========================================
  
  ==============toml.simple===============
  toml.simple = toml.custom(toml.simple_value)
  ========================================
  0000    | GetConstant 244: toml.custom
  0002    | GetConstant 245: toml.simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============toml.tagged===============
  toml.tagged = toml.custom(toml.tagged_value)
  ========================================
  0000    | GetConstant 244: toml.custom
  0002    | GetConstant 246: toml.tagged_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn797=================
  _toml.comments + maybe(ws)
  ========================================
  0000    | GetConstant 249: _toml.comments
  0002    | CallFunction 0
  0004    | GetConstant 36: maybe
  0006    | GetConstant 11: whitespace
  0008    | CallFunction 1
  0010    | Merge
  0011    | End
  ========================================
  
  =================@fn798=================
  maybe(ws) + _toml.comments
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallFunction 1
  0006    | GetConstant 249: _toml.comments
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
  0000    | GetConstant 247: Doc
  0002    | GetConstant 36: maybe
  0004    | GetConstant 248: @fn797
  0006    | CallFunction 1
  0008    | TakeRight 8 -> 29
  0011    | SetInputMark
  0012    | GetConstant 250: _toml.with_root_table
  0014    | GetBoundLocal 0
  0016    | CallFunction 1
  0018    | Or 18 -> 27
  0021    | GetConstant 251: _toml.no_root_table
  0023    | GetBoundLocal 0
  0025    | CallFunction 1
  0027    | Destructure 0: Doc
  0029    | TakeRight 29 -> 47
  0032    | GetConstant 36: maybe
  0034    | GetConstant 252: @fn798
  0036    | CallFunction 1
  0038    | TakeRight 38 -> 47
  0041    | GetConstant 253: _Toml.Doc.Value
  0043    | GetBoundLocal 1
  0045    | CallTailFunction 1
  0047    | End
  ========================================
  
  =========_toml.with_root_table==========
  _toml.with_root_table(value) =
    _toml.root_table(value, _Toml.Doc.Empty) -> RootDoc &
    (_toml.ws > _toml.tables(value, RootDoc)) | const(RootDoc)
  ========================================
  0000    | GetConstant 254: RootDoc
  0002    | GetConstant 255: _toml.root_table
  0004    | GetBoundLocal 0
  0006    | GetConstant2 256: _Toml.Doc.Empty
  0009    | CallFunction 0
  0011    | CallFunction 2
  0013    | Destructure 0: RootDoc
  0015    | TakeRight 15 -> 45
  0018    | SetInputMark
  0019    | GetConstant2 257: _toml.ws
  0022    | CallFunction 0
  0024    | TakeRight 24 -> 36
  0027    | GetConstant2 258: _toml.tables
  0030    | GetBoundLocal 0
  0032    | GetBoundLocal 1
  0034    | CallFunction 2
  0036    | Or 36 -> 45
  0039    | GetConstant 129: const
  0041    | GetBoundLocal 1
  0043    | CallTailFunction 1
  0045    | End
  ========================================
  
  ============_toml.root_table============
  _toml.root_table(value, Doc) =
    _toml.table_body(value, [], Doc)
  ========================================
  0000    | GetConstant2 259: _toml.table_body
  0003    | GetBoundLocal 0
  0005    | GetConstant2 260: []
  0008    | GetBoundLocal 1
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  ==========_toml.no_root_table===========
  _toml.no_root_table(value) =
    _toml.table(value, _Toml.Doc.Empty) | _toml.array_of_tables(value, _Toml.Doc.Empty) -> NewDoc &
    _toml.tables(value, NewDoc)
  ========================================
  0000    | GetConstant2 261: NewDoc
  0003    | SetInputMark
  0004    | GetConstant2 262: _toml.table
  0007    | GetBoundLocal 0
  0009    | GetConstant2 256: _Toml.Doc.Empty
  0012    | CallFunction 0
  0014    | CallFunction 2
  0016    | Or 16 -> 31
  0019    | GetConstant2 263: _toml.array_of_tables
  0022    | GetBoundLocal 0
  0024    | GetConstant2 256: _Toml.Doc.Empty
  0027    | CallFunction 0
  0029    | CallFunction 2
  0031    | Destructure 0: NewDoc
  0033    | TakeRight 33 -> 45
  0036    | GetConstant2 258: _toml.tables
  0039    | GetBoundLocal 0
  0041    | GetBoundLocal 1
  0043    | CallTailFunction 2
  0045    | End
  ========================================
  
  ==============_toml.tables==============
  _toml.tables(value, Doc) =
    _toml.ws >
    _toml.table(value, Doc) | _toml.array_of_tables(value, Doc) -> NewDoc ?
    _toml.tables(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant2 261: NewDoc
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | GetConstant2 257: _toml.ws
  0008    | CallFunction 0
  0010    | TakeRight 10 -> 22
  0013    | GetConstant2 262: _toml.table
  0016    | GetBoundLocal 0
  0018    | GetBoundLocal 1
  0020    | CallFunction 2
  0022    | Or 22 -> 34
  0025    | GetConstant2 263: _toml.array_of_tables
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 1
  0032    | CallFunction 2
  0034    | Destructure 0: NewDoc
  0036    | ConditionalThen 36 -> 51
  0039    | GetConstant2 258: _toml.tables
  0042    | GetBoundLocal 0
  0044    | GetBoundLocal 2
  0046    | CallTailFunction 2
  0048    | Jump 48 -> 57
  0051    | GetConstant 129: const
  0053    | GetBoundLocal 1
  0055    | CallTailFunction 1
  0057    | End
  ========================================
  
  ==============_toml.table===============
  _toml.table(value, Doc) =
    _toml.table_header -> HeaderPath & _toml.ws_newline & (
      _toml.table_body(value, HeaderPath, Doc) |
      const(_Toml.Doc.EnsureTableAtPath(Doc, HeaderPath))
    )
  ========================================
  0000    | GetConstant2 264: HeaderPath
  0003    | GetConstant2 265: _toml.table_header
  0006    | CallFunction 0
  0008    | Destructure 0: HeaderPath
  0010    | TakeRight 10 -> 18
  0013    | GetConstant2 266: _toml.ws_newline
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 49
  0021    | SetInputMark
  0022    | GetConstant2 259: _toml.table_body
  0025    | GetBoundLocal 0
  0027    | GetBoundLocal 2
  0029    | GetBoundLocal 1
  0031    | CallFunction 3
  0033    | Or 33 -> 49
  0036    | GetConstant 129: const
  0038    | GetConstant2 267: _Toml.Doc.EnsureTableAtPath
  0041    | GetBoundLocal 1
  0043    | GetBoundLocal 2
  0045    | CallFunction 2
  0047    | CallTailFunction 1
  0049    | End
  ========================================
  
  =================@fn800=================
  _toml.table_body(value, [], _Toml.Doc.Empty)
  ========================================
  0000    | GetConstant 143: value
  0002    | SetClosureCaptures
  0003    | GetConstant2 259: _toml.table_body
  0006    | GetBoundLocal 0
  0008    | GetConstant2 271: []
  0011    | GetConstant2 256: _Toml.Doc.Empty
  0014    | CallFunction 0
  0016    | CallTailFunction 3
  0018    | End
  ========================================
  
  =========_toml.array_of_tables==========
  _toml.array_of_tables(value, Doc) =
    _toml.array_of_tables_header -> HeaderPath & _toml.ws_newline &
    default(_toml.table_body(value, [], _Toml.Doc.Empty), _Toml.Doc.Empty) -> InnerDoc $
    _Toml.Doc.AppendAtPath(Doc, HeaderPath, _Toml.Doc.Value(InnerDoc))
  ========================================
  0000    | GetConstant2 264: HeaderPath
  0003    | GetConstant2 268: InnerDoc
  0006    | GetConstant2 269: _toml.array_of_tables_header
  0009    | CallFunction 0
  0011    | Destructure 0: HeaderPath
  0013    | TakeRight 13 -> 21
  0016    | GetConstant2 266: _toml.ws_newline
  0019    | CallFunction 0
  0021    | TakeRight 21 -> 60
  0024    | GetConstant 91: default
  0026    | GetConstant2 270: @fn800
  0029    | CreateClosure 1
  0031    | CaptureLocal 0
  0033    | GetConstant2 256: _Toml.Doc.Empty
  0036    | CallFunction 0
  0038    | CallFunction 2
  0040    | Destructure 1: InnerDoc
  0042    | TakeRight 42 -> 60
  0045    | GetConstant2 272: _Toml.Doc.AppendAtPath
  0048    | GetBoundLocal 1
  0050    | GetBoundLocal 2
  0052    | GetConstant 253: _Toml.Doc.Value
  0054    | GetBoundLocal 3
  0056    | CallFunction 1
  0058    | CallTailFunction 3
  0060    | End
  ========================================
  
  =================@fn802=================
  ws | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 11: whitespace
  0003    | CallFunction 0
  0005    | Or 5 -> 13
  0008    | GetConstant2 275: _toml.comment
  0011    | CallFunction 0
  0013    | End
  ========================================
  
  ================_toml.ws================
  _toml.ws = maybe_many(ws | _toml.comment)
  ========================================
  0000    | GetConstant2 273: maybe_many
  0003    | GetConstant2 274: @fn802
  0006    | CallTailFunction 1
  0008    | End
  ========================================
  
  =================@fn803=================
  spaces | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 277: spaces
  0004    | CallFunction 0
  0006    | Or 6 -> 14
  0009    | GetConstant2 275: _toml.comment
  0012    | CallFunction 0
  0014    | End
  ========================================
  
  =============_toml.ws_line==============
  _toml.ws_line = maybe_many(spaces | _toml.comment)
  ========================================
  0000    | GetConstant2 273: maybe_many
  0003    | GetConstant2 276: @fn803
  0006    | CallTailFunction 1
  0008    | End
  ========================================
  
  ============_toml.ws_newline============
  _toml.ws_newline = _toml.ws_line + (nl | end) + _toml.ws
  ========================================
  0000    | GetConstant2 278: _toml.ws_line
  0003    | CallFunction 0
  0005    | SetInputMark
  0006    | GetConstant 17: newline
  0008    | CallFunction 0
  0010    | Or 10 -> 17
  0013    | GetConstant 18: end_of_input
  0015    | CallFunction 0
  0017    | Merge
  0018    | GetConstant2 257: _toml.ws
  0021    | CallFunction 0
  0023    | Merge
  0024    | End
  ========================================
  
  =============_toml.comments=============
  _toml.comments = many_sep(_toml.comment, ws)
  ========================================
  0000    | GetConstant 165: many_sep
  0002    | GetConstant2 275: _toml.comment
  0005    | GetConstant 11: whitespace
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  =================@fn804=================
  maybe(ws)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========_toml.table_header===========
  _toml.table_header = "[" > surround(_toml.path, maybe(ws)) < "]"
  ========================================
  0000    | GetConstant 230: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 17
  0007    | GetConstant 179: surround
  0009    | GetConstant2 279: _toml.path
  0012    | GetConstant2 280: @fn804
  0015    | CallFunction 2
  0017    | JumpIfFailure 17 -> 25
  0020    | GetConstant 235: "]"
  0022    | CallFunction 0
  0024    | TakeLeft
  0025    | End
  ========================================
  
  =================@fn805=================
  maybe(ws)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ======_toml.array_of_tables_header======
  _toml.array_of_tables_header =
    "[[" > surround(_toml.path, maybe(ws)) < "]]"
  ========================================
  0000    | GetConstant2 281: "[["
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 18
  0008    | GetConstant 179: surround
  0010    | GetConstant2 279: _toml.path
  0013    | GetConstant2 282: @fn805
  0016    | CallFunction 2
  0018    | JumpIfFailure 18 -> 27
  0021    | GetConstant2 283: "]]"
  0024    | CallFunction 0
  0026    | TakeLeft
  0027    | End
  ========================================
  
  ============_toml.table_body============
  _toml.table_body(value, HeaderPath, Doc) =
    _toml.table_pair(value) -> [KeyPath, Val] & _toml.ws_newline &
    const(_Toml.Doc.InsertAtPath(Doc, HeaderPath + KeyPath, Val)) -> NewDoc &
    _toml.table_body(value, HeaderPath, NewDoc) | const(NewDoc)
  ========================================
  0000    | GetConstant2 284: KeyPath
  0003    | GetConstant2 285: Val
  0006    | GetConstant2 261: NewDoc
  0009    | GetConstant2 286: _toml.table_pair
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | Destructure 0: [KeyPath, Val]
  0018    | TakeRight 18 -> 26
  0021    | GetConstant2 266: _toml.ws_newline
  0024    | CallFunction 0
  0026    | TakeRight 26 -> 49
  0029    | GetConstant 129: const
  0031    | GetConstant2 287: _Toml.Doc.InsertAtPath
  0034    | GetBoundLocal 2
  0036    | GetBoundLocal 1
  0038    | GetBoundLocal 3
  0040    | Merge
  0041    | GetBoundLocal 4
  0043    | CallFunction 3
  0045    | CallFunction 1
  0047    | Destructure 1: NewDoc
  0049    | TakeRight 49 -> 73
  0052    | SetInputMark
  0053    | GetConstant2 259: _toml.table_body
  0056    | GetBoundLocal 0
  0058    | GetBoundLocal 1
  0060    | GetBoundLocal 5
  0062    | CallFunction 3
  0064    | Or 64 -> 73
  0067    | GetConstant 129: const
  0069    | GetBoundLocal 5
  0071    | CallTailFunction 1
  0073    | End
  ========================================
  
  =================@fn807=================
  maybe(spaces)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant2 277: spaces
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn806=================
  surround("=", maybe(spaces))
  ========================================
  0000    | GetConstant 179: surround
  0002    | GetConstant2 290: "="
  0005    | GetConstant2 291: @fn807
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  ============_toml.table_pair============
  _toml.table_pair(value) =
    tuple2_sep(_toml.path, surround("=", maybe(spaces)), value)
  ========================================
  0000    | GetConstant2 288: tuple2_sep
  0003    | GetConstant2 279: _toml.path
  0006    | GetConstant2 289: @fn806
  0009    | GetBoundLocal 0
  0011    | CallTailFunction 3
  0013    | End
  ========================================
  
  =================@fn809=================
  maybe(ws)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 11: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn808=================
  surround(".", maybe(ws))
  ========================================
  0000    | GetConstant 179: surround
  0002    | GetConstant 48: "."
  0004    | GetConstant2 294: @fn809
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ===============_toml.path===============
  _toml.path = array_sep(_toml.key, surround(".", maybe(ws)))
  ========================================
  0000    | GetConstant 95: array_sep
  0002    | GetConstant2 292: _toml.key
  0005    | GetConstant2 293: @fn808
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =================@fn810=================
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
  0017    | GetConstant 13: "_"
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 14: "-"
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
  0003    | GetConstant2 295: @fn810
  0006    | CallFunction 1
  0008    | Or 8 -> 25
  0011    | SetInputMark
  0012    | GetConstant2 296: toml.string.basic
  0015    | CallFunction 0
  0017    | Or 17 -> 25
  0020    | GetConstant2 297: toml.string.literal
  0023    | CallFunction 0
  0025    | End
  ========================================
  
  =============_toml.comment==============
  _toml.comment = "#" > maybe(line)
  ========================================
  0000    | GetConstant2 298: "#"
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 15
  0008    | GetConstant 36: maybe
  0010    | GetConstant2 299: line
  0013    | CallTailFunction 1
  0015    | End
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
  0001    | GetConstant2 300: toml.string
  0004    | CallFunction 0
  0006    | Or 6 -> 54
  0009    | SetInputMark
  0010    | GetConstant2 301: toml.datetime
  0013    | CallFunction 0
  0015    | Or 15 -> 54
  0018    | SetInputMark
  0019    | GetConstant2 302: toml.number
  0022    | CallFunction 0
  0024    | Or 24 -> 54
  0027    | SetInputMark
  0028    | GetConstant2 303: toml.boolean
  0031    | CallFunction 0
  0033    | Or 33 -> 54
  0036    | SetInputMark
  0037    | GetConstant2 304: toml.array
  0040    | GetConstant 245: toml.simple_value
  0042    | CallFunction 1
  0044    | Or 44 -> 54
  0047    | GetConstant2 305: toml.inline_table
  0050    | GetConstant 245: toml.simple_value
  0052    | CallTailFunction 1
  0054    | End
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
  0001    | GetConstant2 300: toml.string
  0004    | CallFunction 0
  0006    | Or 6 -> 189
  0009    | SetInputMark
  0010    | GetConstant2 306: _toml.tag
  0013    | GetConstant2 307: "datetime"
  0016    | GetConstant2 308: "offset"
  0019    | GetConstant2 309: toml.datetime.offset
  0022    | CallFunction 3
  0024    | Or 24 -> 189
  0027    | SetInputMark
  0028    | GetConstant2 306: _toml.tag
  0031    | GetConstant2 307: "datetime"
  0034    | GetConstant2 310: "local"
  0037    | GetConstant2 311: toml.datetime.local
  0040    | CallFunction 3
  0042    | Or 42 -> 189
  0045    | SetInputMark
  0046    | GetConstant2 306: _toml.tag
  0049    | GetConstant2 307: "datetime"
  0052    | GetConstant2 312: "date-local"
  0055    | GetConstant2 313: toml.datetime.local_date
  0058    | CallFunction 3
  0060    | Or 60 -> 189
  0063    | SetInputMark
  0064    | GetConstant2 306: _toml.tag
  0067    | GetConstant2 307: "datetime"
  0070    | GetConstant2 314: "time-local"
  0073    | GetConstant2 315: toml.datetime.local_time
  0076    | CallFunction 3
  0078    | Or 78 -> 189
  0081    | SetInputMark
  0082    | GetConstant2 316: toml.number.binary_integer
  0085    | CallFunction 0
  0087    | Or 87 -> 189
  0090    | SetInputMark
  0091    | GetConstant2 317: toml.number.octal_integer
  0094    | CallFunction 0
  0096    | Or 96 -> 189
  0099    | SetInputMark
  0100    | GetConstant2 318: toml.number.hex_integer
  0103    | CallFunction 0
  0105    | Or 105 -> 189
  0108    | SetInputMark
  0109    | GetConstant2 306: _toml.tag
  0112    | GetConstant2 319: "float"
  0115    | GetConstant2 320: "infinity"
  0118    | GetConstant2 321: toml.number.infinity
  0121    | CallFunction 3
  0123    | Or 123 -> 189
  0126    | SetInputMark
  0127    | GetConstant2 306: _toml.tag
  0130    | GetConstant2 319: "float"
  0133    | GetConstant2 322: "not-a-number"
  0136    | GetConstant2 323: toml.number.not_a_number
  0139    | CallFunction 3
  0141    | Or 141 -> 189
  0144    | SetInputMark
  0145    | GetConstant2 324: toml.number.float
  0148    | CallFunction 0
  0150    | Or 150 -> 189
  0153    | SetInputMark
  0154    | GetConstant2 325: toml.number.integer
  0157    | CallFunction 0
  0159    | Or 159 -> 189
  0162    | SetInputMark
  0163    | GetConstant2 303: toml.boolean
  0166    | CallFunction 0
  0168    | Or 168 -> 189
  0171    | SetInputMark
  0172    | GetConstant2 304: toml.array
  0175    | GetConstant 246: toml.tagged_value
  0177    | CallFunction 1
  0179    | Or 179 -> 189
  0182    | GetConstant2 305: toml.inline_table
  0185    | GetConstant 246: toml.tagged_value
  0187    | CallTailFunction 1
  0189    | End
  ========================================
  
  ===============_toml.tag================
  _toml.tag(Type, Subtype, value) =
    value -> Value $ {"type": Type, "subtype": Subtype, "value": Value}
  ========================================
  0000    | GetConstant 156: Value
  0002    | GetBoundLocal 2
  0004    | CallFunction 0
  0006    | Destructure 0: Value
  0008    | TakeRight 8 -> 35
  0011    | GetConstant2 326: {_0_, _1_, _2_}
  0014    | GetConstant2 327: "type"
  0017    | GetBoundLocal 0
  0019    | InsertKeyVal 0
  0021    | GetConstant2 328: "subtype"
  0024    | GetBoundLocal 1
  0026    | InsertKeyVal 1
  0028    | GetConstant2 329: "value"
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
  0001    | GetConstant2 330: toml.string.multi_line_basic
  0004    | CallFunction 0
  0006    | Or 6 -> 32
  0009    | SetInputMark
  0010    | GetConstant2 331: toml.string.multi_line_literal
  0013    | CallFunction 0
  0015    | Or 15 -> 32
  0018    | SetInputMark
  0019    | GetConstant2 296: toml.string.basic
  0022    | CallFunction 0
  0024    | Or 24 -> 32
  0027    | GetConstant2 297: toml.string.literal
  0030    | CallFunction 0
  0032    | End
  ========================================
  
  =============toml.datetime==============
  toml.datetime =
    toml.datetime.offset |
    toml.datetime.local |
    toml.datetime.local_date |
    toml.datetime.local_time
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 309: toml.datetime.offset
  0004    | CallFunction 0
  0006    | Or 6 -> 32
  0009    | SetInputMark
  0010    | GetConstant2 311: toml.datetime.local
  0013    | CallFunction 0
  0015    | Or 15 -> 32
  0018    | SetInputMark
  0019    | GetConstant2 313: toml.datetime.local_date
  0022    | CallFunction 0
  0024    | Or 24 -> 32
  0027    | GetConstant2 315: toml.datetime.local_time
  0030    | CallFunction 0
  0032    | End
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
  0001    | GetConstant2 316: toml.number.binary_integer
  0004    | CallFunction 0
  0006    | Or 6 -> 59
  0009    | SetInputMark
  0010    | GetConstant2 317: toml.number.octal_integer
  0013    | CallFunction 0
  0015    | Or 15 -> 59
  0018    | SetInputMark
  0019    | GetConstant2 318: toml.number.hex_integer
  0022    | CallFunction 0
  0024    | Or 24 -> 59
  0027    | SetInputMark
  0028    | GetConstant2 321: toml.number.infinity
  0031    | CallFunction 0
  0033    | Or 33 -> 59
  0036    | SetInputMark
  0037    | GetConstant2 323: toml.number.not_a_number
  0040    | CallFunction 0
  0042    | Or 42 -> 59
  0045    | SetInputMark
  0046    | GetConstant2 324: toml.number.float
  0049    | CallFunction 0
  0051    | Or 51 -> 59
  0054    | GetConstant2 325: toml.number.integer
  0057    | CallFunction 0
  0059    | End
  ========================================
  
  ==============toml.boolean==============
  toml.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 188: boolean
  0002    | GetConstant 189: "true"
  0004    | GetConstant 190: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn813=================
  surround(elem, _toml.ws)
  ========================================
  0000    | GetConstant 86: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 179: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant2 257: _toml.ws
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  =================@fn814=================
  surround(",", _toml.ws)
  ========================================
  0000    | GetConstant 179: surround
  0002    | GetConstant 234: ","
  0004    | GetConstant2 257: _toml.ws
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  =================@fn812=================
  array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws))
  ========================================
  0000    | GetConstant 86: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 95: array_sep
  0005    | GetConstant2 333: @fn813
  0008    | CreateClosure 1
  0010    | CaptureLocal 0
  0012    | GetConstant 234: ","
  0014    | CallFunction 2
  0016    | JumpIfFailure 16 -> 27
  0019    | GetConstant 36: maybe
  0021    | GetConstant2 334: @fn814
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
  0000    | GetConstant 230: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 12
  0007    | GetConstant2 257: _toml.ws
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 29
  0015    | GetConstant 91: default
  0017    | GetConstant2 332: @fn812
  0020    | CreateClosure 1
  0022    | CaptureLocal 0
  0024    | GetConstant2 335: []
  0027    | CallFunction 2
  0029    | JumpIfFailure 29 -> 38
  0032    | GetConstant2 257: _toml.ws
  0035    | CallFunction 0
  0037    | TakeLeft
  0038    | JumpIfFailure 38 -> 46
  0041    | GetConstant 235: "]"
  0043    | CallFunction 0
  0045    | TakeLeft
  0046    | End
  ========================================
  
  ===========toml.inline_table============
  toml.inline_table(value) =
    _toml.empty_inline_table | _toml.nonempty_inline_table(value) -> InlineDoc $
    _Toml.Doc.Value(InlineDoc)
  ========================================
  0000    | GetConstant2 336: InlineDoc
  0003    | SetInputMark
  0004    | GetConstant2 337: _toml.empty_inline_table
  0007    | CallFunction 0
  0009    | Or 9 -> 19
  0012    | GetConstant2 338: _toml.nonempty_inline_table
  0015    | GetBoundLocal 0
  0017    | CallFunction 1
  0019    | Destructure 0: InlineDoc
  0021    | TakeRight 21 -> 30
  0024    | GetConstant 253: _Toml.Doc.Value
  0026    | GetBoundLocal 1
  0028    | CallTailFunction 1
  0030    | End
  ========================================
  
  ========_toml.empty_inline_table========
  _toml.empty_inline_table = "{" > maybe(spaces) < "}" $ _Toml.Doc.Empty
  ========================================
  0000    | GetConstant 236: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 14
  0007    | GetConstant 36: maybe
  0009    | GetConstant2 277: spaces
  0012    | CallFunction 1
  0014    | JumpIfFailure 14 -> 22
  0017    | GetConstant 243: "}"
  0019    | CallFunction 0
  0021    | TakeLeft
  0022    | TakeRight 22 -> 30
  0025    | GetConstant2 256: _Toml.Doc.Empty
  0028    | CallTailFunction 0
  0030    | End
  ========================================
  
  ======_toml.nonempty_inline_table=======
  _toml.nonempty_inline_table(value) =
    "{" > maybe(spaces) >
    _toml.inline_table_pair(value, _Toml.Doc.Empty) -> DocWithFirstPair &
    _toml.inline_table_body(value, DocWithFirstPair)
    < maybe(spaces) < "}"
  ========================================
  0000    | GetConstant2 339: DocWithFirstPair
  0003    | GetConstant 236: "{"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 17
  0010    | GetConstant 36: maybe
  0012    | GetConstant2 277: spaces
  0015    | CallFunction 1
  0017    | TakeRight 17 -> 32
  0020    | GetConstant2 340: _toml.inline_table_pair
  0023    | GetBoundLocal 0
  0025    | GetConstant2 256: _Toml.Doc.Empty
  0028    | CallFunction 0
  0030    | CallFunction 2
  0032    | Destructure 0: DocWithFirstPair
  0034    | TakeRight 34 -> 65
  0037    | GetConstant2 341: _toml.inline_table_body
  0040    | GetBoundLocal 0
  0042    | GetBoundLocal 1
  0044    | CallFunction 2
  0046    | JumpIfFailure 46 -> 57
  0049    | GetConstant 36: maybe
  0051    | GetConstant2 277: spaces
  0054    | CallFunction 1
  0056    | TakeLeft
  0057    | JumpIfFailure 57 -> 65
  0060    | GetConstant 243: "}"
  0062    | CallFunction 0
  0064    | TakeLeft
  0065    | End
  ========================================
  
  ========_toml.inline_table_body=========
  _toml.inline_table_body(value, Doc) =
    "," > _toml.inline_table_pair(value, Doc) -> NewDoc ?
    _toml.inline_table_body(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant2 261: NewDoc
  0003    | SetInputMark
  0004    | GetConstant 234: ","
  0006    | CallFunction 0
  0008    | TakeRight 8 -> 20
  0011    | GetConstant2 340: _toml.inline_table_pair
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 1
  0018    | CallFunction 2
  0020    | Destructure 0: NewDoc
  0022    | ConditionalThen 22 -> 37
  0025    | GetConstant2 341: _toml.inline_table_body
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 2
  0032    | CallTailFunction 2
  0034    | Jump 34 -> 43
  0037    | GetConstant 129: const
  0039    | GetBoundLocal 1
  0041    | CallTailFunction 1
  0043    | End
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
  0000    | GetConstant2 342: Key
  0003    | GetConstant2 285: Val
  0006    | GetConstant 36: maybe
  0008    | GetConstant2 277: spaces
  0011    | CallFunction 1
  0013    | TakeRight 13 -> 23
  0016    | GetConstant2 279: _toml.path
  0019    | CallFunction 0
  0021    | Destructure 0: Key
  0023    | TakeRight 23 -> 33
  0026    | GetConstant 36: maybe
  0028    | GetConstant2 277: spaces
  0031    | CallFunction 1
  0033    | TakeRight 33 -> 41
  0036    | GetConstant2 290: "="
  0039    | CallFunction 0
  0041    | TakeRight 41 -> 51
  0044    | GetConstant 36: maybe
  0046    | GetConstant2 277: spaces
  0049    | CallFunction 1
  0051    | TakeRight 51 -> 60
  0054    | GetBoundLocal 0
  0056    | CallFunction 0
  0058    | Destructure 1: Val
  0060    | TakeRight 60 -> 84
  0063    | GetConstant 36: maybe
  0065    | GetConstant2 277: spaces
  0068    | CallFunction 1
  0070    | TakeRight 70 -> 84
  0073    | GetConstant2 287: _Toml.Doc.InsertAtPath
  0076    | GetBoundLocal 1
  0078    | GetBoundLocal 2
  0080    | GetBoundLocal 3
  0082    | CallTailFunction 3
  0084    | End
  ========================================
  
  =================@fn816=================
  maybe(nl)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 17: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn819=================
  _ctrl_char | `\`
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 198: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 199: "\"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================@fn818=================
  _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 348: _toml.escaped_ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 55
  0009    | SetInputMark
  0010    | GetConstant2 349: _toml.escaped_unicode
  0013    | CallFunction 0
  0015    | Or 15 -> 55
  0018    | SetInputMark
  0019    | GetConstant 11: whitespace
  0021    | CallFunction 0
  0023    | Or 23 -> 55
  0026    | SetInputMark
  0027    | GetConstant 199: "\"
  0029    | CallFunction 0
  0031    | GetConstant 11: whitespace
  0033    | CallFunction 0
  0035    | Merge
  0036    | TakeRight 36 -> 43
  0039    | GetConstant 177: ""
  0041    | CallFunction 0
  0043    | Or 43 -> 55
  0046    | GetConstant 9: unless
  0048    | GetConstant 10: char
  0050    | GetConstant2 350: @fn819
  0053    | CallTailFunction 2
  0055    | End
  ========================================
  
  =================@fn817=================
  many_until(
        _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`),
        `"""`
      )
  ========================================
  0000    | GetConstant 33: many_until
  0002    | GetConstant2 347: @fn818
  0005    | GetConstant2 344: """""
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
  0000    | GetConstant2 343: skip
  0003    | GetConstant2 344: """""
  0006    | CallFunction 1
  0008    | GetConstant2 343: skip
  0011    | GetConstant2 345: @fn816
  0014    | CallFunction 1
  0016    | Merge
  0017    | GetConstant 91: default
  0019    | GetConstant2 346: @fn817
  0022    | GetConstant 177: ""
  0024    | CallFunction 2
  0026    | Merge
  0027    | GetConstant2 343: skip
  0030    | GetConstant2 344: """""
  0033    | CallFunction 1
  0035    | Merge
  0036    | GetConstant 80: null
  0038    | GetConstant 83: 0
  0040    | ValidateRepeatPattern
  0041    | JumpIfZero 41 -> 61
  0044    | Swap
  0045    | GetConstant 192: """
  0047    | CallFunction 0
  0049    | Merge
  0050    | JumpIfFailure 50 -> 94
  0053    | Swap
  0054    | Decrement
  0055    | JumpIfZero 55 -> 61
  0058    | JumpBack 58 -> 44
  0061    | Drop
  0062    | GetConstant2 351: 2
  0065    | GetConstant 83: 0
  0067    | NegateNumber
  0068    | Merge
  0069    | ValidateRepeatPattern
  0070    | JumpIfZero 70 -> 95
  0073    | Swap
  0074    | SetInputMark
  0075    | GetConstant 192: """
  0077    | CallFunction 0
  0079    | JumpIfFailure 79 -> 92
  0082    | PopInputMark
  0083    | Merge
  0084    | Swap
  0085    | Decrement
  0086    | JumpIfZero 86 -> 95
  0089    | JumpBack 89 -> 73
  0092    | ResetInput
  0093    | Drop
  0094    | Swap
  0095    | Drop
  0096    | Merge
  0097    | End
  ========================================
  
  =================@fn820=================
  maybe(nl)
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 17: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn821=================
  many_until(char, `'''`)
  ========================================
  0000    | GetConstant 33: many_until
  0002    | GetConstant 10: char
  0004    | GetConstant2 352: "'''"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  =====toml.string.multi_line_literal=====
  toml.string.multi_line_literal =
    skip(`'''`) + skip(maybe(nl)) +
    default(many_until(char, `'''`), $"")
    + skip(`'''`) + (`'` * 0..2)
  ========================================
  0000    | GetConstant2 343: skip
  0003    | GetConstant2 352: "'''"
  0006    | CallFunction 1
  0008    | GetConstant2 343: skip
  0011    | GetConstant2 353: @fn820
  0014    | CallFunction 1
  0016    | Merge
  0017    | GetConstant 91: default
  0019    | GetConstant2 354: @fn821
  0022    | GetConstant 177: ""
  0024    | CallFunction 2
  0026    | Merge
  0027    | GetConstant2 343: skip
  0030    | GetConstant2 352: "'''"
  0033    | CallFunction 1
  0035    | Merge
  0036    | GetConstant 80: null
  0038    | GetConstant 83: 0
  0040    | ValidateRepeatPattern
  0041    | JumpIfZero 41 -> 62
  0044    | Swap
  0045    | GetConstant2 355: "'"
  0048    | CallFunction 0
  0050    | Merge
  0051    | JumpIfFailure 51 -> 96
  0054    | Swap
  0055    | Decrement
  0056    | JumpIfZero 56 -> 62
  0059    | JumpBack 59 -> 44
  0062    | Drop
  0063    | GetConstant2 351: 2
  0066    | GetConstant 83: 0
  0068    | NegateNumber
  0069    | Merge
  0070    | ValidateRepeatPattern
  0071    | JumpIfZero 71 -> 97
  0074    | Swap
  0075    | SetInputMark
  0076    | GetConstant2 355: "'"
  0079    | CallFunction 0
  0081    | JumpIfFailure 81 -> 94
  0084    | PopInputMark
  0085    | Merge
  0086    | Swap
  0087    | Decrement
  0088    | JumpIfZero 88 -> 97
  0091    | JumpBack 91 -> 74
  0094    | ResetInput
  0095    | Drop
  0096    | Swap
  0097    | Drop
  0098    | Merge
  0099    | End
  ========================================
  
  ===========toml.string.basic============
  toml.string.basic = '"' > _toml.string.basic_body < '"'
  ========================================
  0000    | GetConstant 192: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 12
  0007    | GetConstant2 356: _toml.string.basic_body
  0010    | CallFunction 0
  0012    | JumpIfFailure 12 -> 20
  0015    | GetConstant 192: """
  0017    | CallFunction 0
  0019    | TakeLeft
  0020    | End
  ========================================
  
  =================@fn823=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 198: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | GetConstant 199: "\"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 192: """
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn822=================
  _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 348: _toml.escaped_ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 27
  0009    | SetInputMark
  0010    | GetConstant2 349: _toml.escaped_unicode
  0013    | CallFunction 0
  0015    | Or 15 -> 27
  0018    | GetConstant 9: unless
  0020    | GetConstant 10: char
  0022    | GetConstant2 358: @fn823
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
  0003    | GetConstant2 357: @fn822
  0006    | CallFunction 1
  0008    | Or 8 -> 17
  0011    | GetConstant 129: const
  0013    | GetConstant 177: ""
  0015    | CallTailFunction 1
  0017    | End
  ========================================
  
  =================@fn824=================
  chars_until("'")
  ========================================
  0000    | GetConstant 15: chars_until
  0002    | GetConstant2 355: "'"
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ==========toml.string.literal===========
  toml.string.literal = "'" > default(chars_until("'"), $"") < "'"
  ========================================
  0000    | GetConstant2 355: "'"
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 17
  0008    | GetConstant 91: default
  0010    | GetConstant2 359: @fn824
  0013    | GetConstant 177: ""
  0015    | CallFunction 2
  0017    | JumpIfFailure 17 -> 26
  0020    | GetConstant2 355: "'"
  0023    | CallFunction 0
  0025    | TakeLeft
  0026    | End
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
  0001    | GetConstant 200: "\""
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | GetConstant 192: """
  0010    | Or 10 -> 87
  0013    | SetInputMark
  0014    | GetConstant 201: "\\"
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 23
  0021    | GetConstant 199: "\"
  0023    | Or 23 -> 87
  0026    | SetInputMark
  0027    | GetConstant 204: "\b"
  0029    | CallFunction 0
  0031    | TakeRight 31 -> 36
  0034    | GetConstant 205: "\x08" (esc)
  0036    | Or 36 -> 87
  0039    | SetInputMark
  0040    | GetConstant 206: "\f"
  0042    | CallFunction 0
  0044    | TakeRight 44 -> 49
  0047    | GetConstant 207: "\x0c" (esc)
  0049    | Or 49 -> 87
  0052    | SetInputMark
  0053    | GetConstant 208: "\n"
  0055    | CallFunction 0
  0057    | TakeRight 57 -> 62
  0060    | GetConstant 209: "
  "
  0062    | Or 62 -> 87
  0065    | SetInputMark
  0066    | GetConstant 210: "\r"
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 75
  0073    | GetConstant 211: "\r (no-eol) (esc)
  "
  0075    | Or 75 -> 87
  0078    | GetConstant 212: "\t"
  0080    | CallFunction 0
  0082    | TakeRight 82 -> 87
  0085    | GetConstant 20: "\t" (esc)
  0087    | End
  ========================================
  
  =========_toml.escaped_unicode==========
  _toml.escaped_unicode =
    (`\u` > (hex_numeral * 4) -> U $ @Codepoint(U)) |
    (`\U` > (hex_numeral * 8) -> U $ @Codepoint(U))
  ========================================
  0000    | GetConstant 227: U
  0002    | SetInputMark
  0003    | GetConstant 223: "\u"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 37
  0010    | GetConstant 80: null
  0012    | GetConstant 228: 4
  0014    | ValidateRepeatPattern
  0015    | JumpIfZero 15 -> 36
  0018    | Swap
  0019    | GetConstant 226: hex_numeral
  0021    | CallFunction 0
  0023    | Merge
  0024    | JumpIfFailure 24 -> 35
  0027    | Swap
  0028    | Decrement
  0029    | JumpIfZero 29 -> 36
  0032    | JumpBack 32 -> 18
  0035    | Swap
  0036    | Drop
  0037    | Destructure 0: U
  0039    | TakeRight 39 -> 48
  0042    | GetConstant 229: @Codepoint
  0044    | GetBoundLocal 0
  0046    | CallTailFunction 1
  0048    | Or 48 -> 98
  0051    | GetConstant2 360: "\U"
  0054    | CallFunction 0
  0056    | TakeRight 56 -> 87
  0059    | GetConstant 80: null
  0061    | GetConstant2 361: 8
  0064    | ValidateRepeatPattern
  0065    | JumpIfZero 65 -> 86
  0068    | Swap
  0069    | GetConstant 226: hex_numeral
  0071    | CallFunction 0
  0073    | Merge
  0074    | JumpIfFailure 74 -> 85
  0077    | Swap
  0078    | Decrement
  0079    | JumpIfZero 79 -> 86
  0082    | JumpBack 82 -> 68
  0085    | Swap
  0086    | Drop
  0087    | Destructure 1: U
  0089    | TakeRight 89 -> 98
  0092    | GetConstant 229: @Codepoint
  0094    | GetBoundLocal 0
  0096    | CallTailFunction 1
  0098    | End
  ========================================
  
  ==========toml.datetime.offset==========
  toml.datetime.offset = toml.datetime.local_date + ("T" | "t" | " ") + _toml.datetime.time_offset
  ========================================
  0000    | GetConstant2 313: toml.datetime.local_date
  0003    | CallFunction 0
  0005    | SetInputMark
  0006    | GetConstant2 362: "T"
  0009    | CallFunction 0
  0011    | Or 11 -> 27
  0014    | SetInputMark
  0015    | GetConstant2 363: "t"
  0018    | CallFunction 0
  0020    | Or 20 -> 27
  0023    | GetConstant 19: " "
  0025    | CallFunction 0
  0027    | Merge
  0028    | GetConstant2 364: _toml.datetime.time_offset
  0031    | CallFunction 0
  0033    | Merge
  0034    | End
  ========================================
  
  ==========toml.datetime.local===========
  toml.datetime.local = toml.datetime.local_date + ("T" | "t" | " ") + toml.datetime.local_time
  ========================================
  0000    | GetConstant2 313: toml.datetime.local_date
  0003    | CallFunction 0
  0005    | SetInputMark
  0006    | GetConstant2 362: "T"
  0009    | CallFunction 0
  0011    | Or 11 -> 27
  0014    | SetInputMark
  0015    | GetConstant2 363: "t"
  0018    | CallFunction 0
  0020    | Or 20 -> 27
  0023    | GetConstant 19: " "
  0025    | CallFunction 0
  0027    | Merge
  0028    | GetConstant2 315: toml.datetime.local_time
  0031    | CallFunction 0
  0033    | Merge
  0034    | End
  ========================================
  
  ========toml.datetime.local_date========
  toml.datetime.local_date =
    _toml.datetime.year + "-" + _toml.datetime.month + "-" + _toml.datetime.mday
  ========================================
  0000    | GetConstant2 365: _toml.datetime.year
  0003    | CallFunction 0
  0005    | GetConstant 14: "-"
  0007    | CallFunction 0
  0009    | Merge
  0010    | GetConstant2 366: _toml.datetime.month
  0013    | CallFunction 0
  0015    | Merge
  0016    | GetConstant 14: "-"
  0018    | CallFunction 0
  0020    | Merge
  0021    | GetConstant2 367: _toml.datetime.mday
  0024    | CallFunction 0
  0026    | Merge
  0027    | End
  ========================================
  
  ==========_toml.datetime.year===========
  _toml.datetime.year = numeral * 4
  ========================================
  0000    | GetConstant 80: null
  0002    | GetConstant 228: 4
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 26
  0008    | Swap
  0009    | GetConstant 4: numeral
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 25
  0017    | Swap
  0018    | Decrement
  0019    | JumpIfZero 19 -> 26
  0022    | JumpBack 22 -> 8
  0025    | Swap
  0026    | Drop
  0027    | End
  ========================================
  
  ==========_toml.datetime.month==========
  _toml.datetime.month = ("0" + "1".."9") | "11" | "12"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 5: "0"
  0003    | CallFunction 0
  0005    | ParseCodepointRange '1'..'9'
  0008    | Merge
  0009    | Or 9 -> 26
  0012    | SetInputMark
  0013    | GetConstant2 368: "11"
  0016    | CallFunction 0
  0018    | Or 18 -> 26
  0021    | GetConstant2 369: "12"
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
  0012    | GetConstant2 370: "30"
  0015    | CallFunction 0
  0017    | Or 17 -> 25
  0020    | GetConstant2 371: "31"
  0023    | CallFunction 0
  0025    | End
  ========================================
  
  =================@fn825=================
  "." + (numeral * 1..9)
  ========================================
  0000    | GetConstant 48: "."
  0002    | CallFunction 0
  0004    | GetConstant 80: null
  0006    | GetConstant 81: 1
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 29
  0012    | Swap
  0013    | GetConstant 4: numeral
  0015    | CallFunction 0
  0017    | Merge
  0018    | JumpIfFailure 18 -> 62
  0021    | Swap
  0022    | Decrement
  0023    | JumpIfZero 23 -> 29
  0026    | JumpBack 26 -> 12
  0029    | Drop
  0030    | GetConstant2 376: 9
  0033    | GetConstant 81: 1
  0035    | NegateNumber
  0036    | Merge
  0037    | ValidateRepeatPattern
  0038    | JumpIfZero 38 -> 63
  0041    | Swap
  0042    | SetInputMark
  0043    | GetConstant 4: numeral
  0045    | CallFunction 0
  0047    | JumpIfFailure 47 -> 60
  0050    | PopInputMark
  0051    | Merge
  0052    | Swap
  0053    | Decrement
  0054    | JumpIfZero 54 -> 63
  0057    | JumpBack 57 -> 41
  0060    | ResetInput
  0061    | Drop
  0062    | Swap
  0063    | Drop
  0064    | Merge
  0065    | End
  ========================================
  
  ========toml.datetime.local_time========
  toml.datetime.local_time =
    _toml.datetime.hours + ":" +
    _toml.datetime.minutes + ":" +
    _toml.datetime.seconds +
    maybe("." + (numeral * 1..9))
  ========================================
  0000    | GetConstant2 372: _toml.datetime.hours
  0003    | CallFunction 0
  0005    | GetConstant 240: ":"
  0007    | CallFunction 0
  0009    | Merge
  0010    | GetConstant2 373: _toml.datetime.minutes
  0013    | CallFunction 0
  0015    | Merge
  0016    | GetConstant 240: ":"
  0018    | CallFunction 0
  0020    | Merge
  0021    | GetConstant2 374: _toml.datetime.seconds
  0024    | CallFunction 0
  0026    | Merge
  0027    | GetConstant 36: maybe
  0029    | GetConstant2 375: @fn825
  0032    | CallFunction 1
  0034    | Merge
  0035    | End
  ========================================
  
  =======_toml.datetime.time_offset=======
  _toml.datetime.time_offset = toml.datetime.local_time + ("Z" | "z" | _toml.datetime.time_numoffset)
  ========================================
  0000    | GetConstant2 315: toml.datetime.local_time
  0003    | CallFunction 0
  0005    | SetInputMark
  0006    | GetConstant2 377: "Z"
  0009    | CallFunction 0
  0011    | Or 11 -> 28
  0014    | SetInputMark
  0015    | GetConstant2 378: "z"
  0018    | CallFunction 0
  0020    | Or 20 -> 28
  0023    | GetConstant2 379: _toml.datetime.time_numoffset
  0026    | CallFunction 0
  0028    | Merge
  0029    | End
  ========================================
  
  =====_toml.datetime.time_numoffset======
  _toml.datetime.time_numoffset = ("+" | "-") + _toml.datetime.hours + ":" + _toml.datetime.minutes
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 52: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 14: "-"
  0010    | CallFunction 0
  0012    | GetConstant2 372: _toml.datetime.hours
  0015    | CallFunction 0
  0017    | Merge
  0018    | GetConstant 240: ":"
  0020    | CallFunction 0
  0022    | Merge
  0023    | GetConstant2 373: _toml.datetime.minutes
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
  0008    | Or 8 -> 20
  0011    | GetConstant2 380: "2"
  0014    | CallFunction 0
  0016    | ParseCodepointRange '0'..'3'
  0019    | Merge
  0020    | End
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
  0011    | GetConstant2 381: "60"
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn826=================
  _toml.number.sign +
    _toml.number.integer_part
  ========================================
  0000    | GetConstant2 383: _toml.number.sign
  0003    | CallFunction 0
  0005    | GetConstant2 384: _toml.number.integer_part
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
  0000    | GetConstant 34: as_number
  0002    | GetConstant2 382: @fn826
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn827=================
  "-" | skip("+")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 14: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 15
  0008    | GetConstant2 343: skip
  0011    | GetConstant 52: "+"
  0013    | CallTailFunction 1
  0015    | End
  ========================================
  
  ===========_toml.number.sign============
  _toml.number.sign = maybe("-" | skip("+"))
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant2 385: @fn827
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn828=================
  maybe("_") > numeral
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
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
  0006    | GetConstant2 386: @fn828
  0009    | CallFunction 1
  0011    | Merge
  0012    | Or 12 -> 19
  0015    | GetConstant 4: numeral
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  =================@fn829=================
  _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  ========================================
  0000    | GetConstant2 383: _toml.number.sign
  0003    | CallFunction 0
  0005    | GetConstant2 384: _toml.number.integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | SetInputMark
  0012    | GetConstant2 388: _toml.number.fraction_part
  0015    | CallFunction 0
  0017    | GetConstant 36: maybe
  0019    | GetConstant2 389: _toml.number.exponent_part
  0022    | CallFunction 1
  0024    | Merge
  0025    | Or 25 -> 33
  0028    | GetConstant2 389: _toml.number.exponent_part
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
  0000    | GetConstant 34: as_number
  0002    | GetConstant2 387: @fn829
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn830=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.fraction_part=======
  _toml.number.fraction_part = "." + many_sep(numerals, maybe("_"))
  ========================================
  0000    | GetConstant 48: "."
  0002    | CallFunction 0
  0004    | GetConstant 165: many_sep
  0006    | GetConstant 47: numerals
  0008    | GetConstant2 390: @fn830
  0011    | CallFunction 2
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn831=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 14: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 52: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================@fn832=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.exponent_part=======
  _toml.number.exponent_part =
    ("e" | "E") + maybe("-" | "+") + many_sep(numerals, maybe("_"))
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 49: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 50: "E"
  0010    | CallFunction 0
  0012    | GetConstant 36: maybe
  0014    | GetConstant2 391: @fn831
  0017    | CallFunction 1
  0019    | Merge
  0020    | GetConstant 165: many_sep
  0022    | GetConstant 47: numerals
  0024    | GetConstant2 392: @fn832
  0027    | CallFunction 2
  0029    | Merge
  0030    | End
  ========================================
  
  =================@fn833=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 52: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 14: "-"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==========toml.number.infinity==========
  toml.number.infinity = maybe("+" | "-") + "inf"
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant2 393: @fn833
  0005    | CallFunction 1
  0007    | GetConstant2 394: "inf"
  0010    | CallFunction 0
  0012    | Merge
  0013    | End
  ========================================
  
  =================@fn834=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 52: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 14: "-"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========toml.number.not_a_number========
  toml.number.not_a_number = maybe("+" | "-") + "nan"
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant2 395: @fn834
  0005    | CallFunction 1
  0007    | GetConstant2 396: "nan"
  0010    | CallFunction 0
  0012    | Merge
  0013    | End
  ========================================
  
  =================@fn836=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn837=================
  skip("_") < peek(binary_numeral)
  ========================================
  0000    | GetConstant2 343: skip
  0003    | GetConstant 13: "_"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 18
  0010    | GetConstant 90: peek
  0012    | GetConstant2 403: binary_numeral
  0015    | CallFunction 1
  0017    | TakeLeft
  0018    | End
  ========================================
  
  =================@fn835=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral))
  ========================================
  0000    | GetConstant 95: array_sep
  0002    | GetConstant2 400: 0
  0005    | GetConstant2 401: @fn836
  0008    | CallFunction 2
  0010    | GetConstant 36: maybe
  0012    | GetConstant2 402: @fn837
  0015    | CallFunction 1
  0017    | Merge
  0018    | End
  ========================================
  
  =================@fn839=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn838=================
  array_sep(binary_digit, maybe("_"))
  ========================================
  0000    | GetConstant 95: array_sep
  0002    | GetConstant 72: binary_digit
  0004    | GetConstant2 405: @fn839
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
  0000    | GetConstant 70: Digits
  0002    | GetConstant2 397: "0b"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 32
  0010    | GetConstant2 398: one_or_both
  0013    | GetConstant2 399: @fn835
  0016    | GetConstant2 404: @fn838
  0019    | CallFunction 2
  0021    | Destructure 0: Digits
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 73: Num.FromBinaryDigits
  0028    | GetBoundLocal 0
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  =================@fn841=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn842=================
  skip("_") < peek(octal_numeral)
  ========================================
  0000    | GetConstant2 343: skip
  0003    | GetConstant 13: "_"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 18
  0010    | GetConstant 90: peek
  0012    | GetConstant2 410: octal_numeral
  0015    | CallFunction 1
  0017    | TakeLeft
  0018    | End
  ========================================
  
  =================@fn840=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral))
  ========================================
  0000    | GetConstant 95: array_sep
  0002    | GetConstant2 400: 0
  0005    | GetConstant2 408: @fn841
  0008    | CallFunction 2
  0010    | GetConstant 36: maybe
  0012    | GetConstant2 409: @fn842
  0015    | CallFunction 1
  0017    | Merge
  0018    | End
  ========================================
  
  =================@fn844=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn843=================
  array_sep(octal_digit, maybe("_"))
  ========================================
  0000    | GetConstant 95: array_sep
  0002    | GetConstant 74: octal_digit
  0004    | GetConstant2 412: @fn844
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
  0000    | GetConstant 70: Digits
  0002    | GetConstant2 406: "0o"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 32
  0010    | GetConstant2 398: one_or_both
  0013    | GetConstant2 407: @fn840
  0016    | GetConstant2 411: @fn843
  0019    | CallFunction 2
  0021    | Destructure 0: Digits
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 75: Num.FromOctalDigits
  0028    | GetBoundLocal 0
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  =================@fn846=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn847=================
  skip("_") < peek(hex_numeral)
  ========================================
  0000    | GetConstant2 343: skip
  0003    | GetConstant 13: "_"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 90: peek
  0012    | GetConstant 226: hex_numeral
  0014    | CallFunction 1
  0016    | TakeLeft
  0017    | End
  ========================================
  
  =================@fn845=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral))
  ========================================
  0000    | GetConstant 95: array_sep
  0002    | GetConstant2 400: 0
  0005    | GetConstant2 415: @fn846
  0008    | CallFunction 2
  0010    | GetConstant 36: maybe
  0012    | GetConstant2 416: @fn847
  0015    | CallFunction 1
  0017    | Merge
  0018    | End
  ========================================
  
  =================@fn849=================
  maybe("_")
  ========================================
  0000    | GetConstant 36: maybe
  0002    | GetConstant 13: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn848=================
  array_sep(hex_digit, maybe("_"))
  ========================================
  0000    | GetConstant 95: array_sep
  0002    | GetConstant 76: hex_digit
  0004    | GetConstant2 418: @fn849
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
  0000    | GetConstant 70: Digits
  0002    | GetConstant2 413: "0x"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 32
  0010    | GetConstant2 398: one_or_both
  0013    | GetConstant2 414: @fn845
  0016    | GetConstant2 417: @fn848
  0019    | CallFunction 2
  0021    | Destructure 0: Digits
  0023    | TakeRight 23 -> 32
  0026    | GetConstant 77: Num.FromHexDigits
  0028    | GetBoundLocal 0
  0030    | CallTailFunction 1
  0032    | End
  ========================================
  
  ============_Toml.Doc.Empty=============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant2 419: {"value": {}, "type": {}}
  0003    | End
  ========================================
  
  ============_Toml.Doc.Value=============
  _Toml.Doc.Value(Doc) = Obj.Get(Doc, "value")
  ========================================
  0000    | GetConstant2 420: Obj.Get
  0003    | GetBoundLocal 0
  0005    | GetConstant2 329: "value"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =============_Toml.Doc.Type=============
  _Toml.Doc.Type(Doc) = Obj.Get(Doc, "type")
  ========================================
  0000    | GetConstant2 420: Obj.Get
  0003    | GetBoundLocal 0
  0005    | GetConstant2 327: "type"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =============_Toml.Doc.Has==============
  _Toml.Doc.Has(Doc, Key) = Obj.Has(_Toml.Doc.Type(Doc), Key)
  ========================================
  0000    | GetConstant2 421: Obj.Has
  0003    | GetConstant2 422: _Toml.Doc.Type
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
  0000    | GetConstant2 423: {_0_, _1_}
  0003    | GetConstant2 329: "value"
  0006    | GetConstant2 420: Obj.Get
  0009    | GetConstant 253: _Toml.Doc.Value
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | InsertKeyVal 0
  0021    | GetConstant2 327: "type"
  0024    | GetConstant2 420: Obj.Get
  0027    | GetConstant2 422: _Toml.Doc.Type
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
  0000    | GetConstant2 424: Is.Object
  0003    | GetConstant2 422: _Toml.Doc.Type
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
  0000    | GetConstant2 425: _Toml.Doc.IsTable
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | TakeRight 7 -> 54
  0010    | GetConstant2 426: {_0_, _1_}
  0013    | GetConstant2 329: "value"
  0016    | GetConstant2 427: Obj.Put
  0019    | GetConstant 253: _Toml.Doc.Value
  0021    | GetBoundLocal 0
  0023    | CallFunction 1
  0025    | GetBoundLocal 1
  0027    | GetBoundLocal 2
  0029    | CallFunction 3
  0031    | InsertKeyVal 0
  0033    | GetConstant2 327: "type"
  0036    | GetConstant2 427: Obj.Put
  0039    | GetConstant2 422: _Toml.Doc.Type
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
  0000    | GetConstant2 428: AoT
  0003    | GetConstant2 429: _Toml.Doc.Get
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 1
  0010    | CallFunction 2
  0012    | Destructure 0: {"value": AoT, "type": "array_of_tables"}
  0014    | TakeRight 14 -> 43
  0017    | GetConstant2 430: _Toml.Doc.Insert
  0020    | GetBoundLocal 0
  0022    | GetBoundLocal 1
  0024    | GetConstant2 431: []
  0027    | GetBoundLocal 3
  0029    | Merge
  0030    | GetConstant2 432: [_]
  0033    | GetBoundLocal 2
  0035    | InsertAtIndex 0
  0037    | Merge
  0038    | GetConstant2 433: "array_of_tables"
  0041    | CallTailFunction 4
  0043    | End
  ========================================
  
  =========_Toml.Doc.InsertAtPath=========
  _Toml.Doc.InsertAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.ValueUpdater)
  ========================================
  0000    | GetConstant2 434: _Toml.Doc.UpdateAtPath
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | GetConstant2 435: _Toml.Doc.ValueUpdater
  0012    | CallTailFunction 4
  0014    | End
  ========================================
  
  ======_Toml.Doc.EnsureTableAtPath=======
  _Toml.Doc.EnsureTableAtPath(Doc, Path) =
    _Toml.Doc.UpdateAtPath(Doc, Path, {}, _Toml.Doc.MissingTableUpdater)
  ========================================
  0000    | GetConstant2 434: _Toml.Doc.UpdateAtPath
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetConstant2 436: {}
  0010    | GetConstant2 437: _Toml.Doc.MissingTableUpdater
  0013    | CallTailFunction 4
  0015    | End
  ========================================
  
  =========_Toml.Doc.AppendAtPath=========
  _Toml.Doc.AppendAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.AppendUpdater)
  ========================================
  0000    | GetConstant2 434: _Toml.Doc.UpdateAtPath
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | GetConstant2 438: _Toml.Doc.AppendUpdater
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
  0000    | GetConstant2 342: Key
  0003    | GetConstant2 439: PathRest
  0006    | GetConstant2 268: InnerDoc
  0009    | SetInputMark
  0010    | GetBoundLocal 1
  0012    | Destructure 0: [Key]
  0014    | ConditionalThen 14 -> 30
  0017    | GetBoundLocal 3
  0019    | GetBoundLocal 0
  0021    | GetBoundLocal 4
  0023    | GetBoundLocal 2
  0025    | CallTailFunction 3
  0027    | Jump 27 -> 139
  0030    | SetInputMark
  0031    | GetBoundLocal 1
  0033    | Destructure 1: ([Key] + PathRest)
  0035    | ConditionalThen 35 -> 137
  0038    | SetInputMark
  0039    | GetConstant2 440: _Toml.Doc.Has
  0042    | GetBoundLocal 0
  0044    | GetBoundLocal 4
  0046    | CallFunction 2
  0048    | ConditionalThen 48 -> 91
  0051    | GetConstant2 425: _Toml.Doc.IsTable
  0054    | GetConstant2 429: _Toml.Doc.Get
  0057    | GetBoundLocal 0
  0059    | GetBoundLocal 4
  0061    | CallFunction 2
  0063    | CallFunction 1
  0065    | TakeRight 65 -> 88
  0068    | GetConstant2 434: _Toml.Doc.UpdateAtPath
  0071    | GetConstant2 429: _Toml.Doc.Get
  0074    | GetBoundLocal 0
  0076    | GetBoundLocal 4
  0078    | CallFunction 2
  0080    | GetBoundLocal 5
  0082    | GetBoundLocal 2
  0084    | GetBoundLocal 3
  0086    | CallFunction 4
  0088    | Jump 88 -> 107
  0091    | GetConstant2 434: _Toml.Doc.UpdateAtPath
  0094    | GetConstant2 256: _Toml.Doc.Empty
  0097    | CallFunction 0
  0099    | GetBoundLocal 5
  0101    | GetBoundLocal 2
  0103    | GetBoundLocal 3
  0105    | CallFunction 4
  0107    | Destructure 2: InnerDoc
  0109    | TakeRight 109 -> 134
  0112    | GetConstant2 430: _Toml.Doc.Insert
  0115    | GetBoundLocal 0
  0117    | GetBoundLocal 4
  0119    | GetConstant 253: _Toml.Doc.Value
  0121    | GetBoundLocal 6
  0123    | CallFunction 1
  0125    | GetConstant2 422: _Toml.Doc.Type
  0128    | GetBoundLocal 6
  0130    | CallFunction 1
  0132    | CallTailFunction 4
  0134    | Jump 134 -> 139
  0137    | GetBoundLocal 0
  0139    | End
  ========================================
  
  =========_Toml.Doc.ValueUpdater=========
  _Toml.Doc.ValueUpdater(Doc, Key, Val) =
    _Toml.Doc.Has(Doc, Key) ? @Fail : _Toml.Doc.Insert(Doc, Key, Val, "value")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 440: _Toml.Doc.Has
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | ConditionalThen 10 -> 21
  0013    | GetConstant2 441: @Fail
  0016    | CallTailFunction 0
  0018    | Jump 18 -> 35
  0021    | GetConstant2 430: _Toml.Doc.Insert
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | GetBoundLocal 2
  0030    | GetConstant2 329: "value"
  0033    | CallTailFunction 4
  0035    | End
  ========================================
  
  =====_Toml.Doc.MissingTableUpdater======
  _Toml.Doc.MissingTableUpdater(Doc, Key, _Val) =
    _Toml.Doc.IsTable(_Toml.Doc.Get(Doc, Key)) ? Doc :
    _Toml.Doc.Insert(Doc, Key, {}, {})
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 425: _Toml.Doc.IsTable
  0004    | GetConstant2 429: _Toml.Doc.Get
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallFunction 2
  0013    | CallFunction 1
  0015    | ConditionalThen 15 -> 23
  0018    | GetBoundLocal 0
  0020    | Jump 20 -> 38
  0023    | GetConstant2 430: _Toml.Doc.Insert
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | GetConstant2 442: {}
  0033    | GetConstant2 443: {}
  0036    | CallTailFunction 4
  0038    | End
  ========================================
  
  ========_Toml.Doc.AppendUpdater=========
  _Toml.Doc.AppendUpdater(Doc, Key, Val) =
    (
      _Toml.Doc.Has(Doc, Key) ? Doc :
      _Toml.Doc.Insert(Doc, Key, [], "array_of_tables")
    ) -> DocWithKey &
    _Toml.Doc.AppendToArrayOfTables(DocWithKey, Key, Val)
  ========================================
  0000    | GetConstant2 444: DocWithKey
  0003    | SetInputMark
  0004    | GetConstant2 440: _Toml.Doc.Has
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallFunction 2
  0013    | ConditionalThen 13 -> 21
  0016    | GetBoundLocal 0
  0018    | Jump 18 -> 36
  0021    | GetConstant2 430: _Toml.Doc.Insert
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | GetConstant2 445: []
  0031    | GetConstant2 433: "array_of_tables"
  0034    | CallFunction 4
  0036    | Destructure 0: DocWithKey
  0038    | TakeRight 38 -> 52
  0041    | GetConstant2 446: _Toml.Doc.AppendToArrayOfTables
  0044    | GetBoundLocal 3
  0046    | GetBoundLocal 1
  0048    | GetBoundLocal 2
  0050    | CallTailFunction 3
  0052    | End
  ========================================
  
  ======ast.with_operator_precedence======
  ast.with_operator_precedence(operand, prefix, infix, postfix) =
    _ast.with_precedence_start(operand, prefix, infix, postfix, $0)
  ========================================
  0000    | GetConstant2 447: _ast.with_precedence_start
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetBoundLocal 2
  0009    | GetBoundLocal 3
  0011    | GetConstant 83: 0
  0013    | CallTailFunction 5
  0015    | End
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
  0000    | GetConstant2 448: PrefixBindingPower
  0003    | GetConstant2 449: PrefixNode
  0006    | GetConstant2 450: Node
  0009    | SetInputMark
  0010    | GetBoundLocal 1
  0012    | CallFunction 0
  0014    | Destructure 0: ({"power": PrefixBindingPower} + PrefixNode)
  0016    | ConditionalThen 16 -> 84
  0019    | GetConstant2 447: _ast.with_precedence_start
  0022    | GetBoundLocal 0
  0024    | GetBoundLocal 1
  0026    | GetBoundLocal 2
  0028    | GetBoundLocal 3
  0030    | GetBoundLocal 5
  0032    | CallFunction 5
  0034    | Destructure 1: Node
  0036    | TakeRight 36 -> 81
  0039    | GetConstant2 451: _ast.with_precedence_rest
  0042    | GetBoundLocal 0
  0044    | GetBoundLocal 1
  0046    | GetBoundLocal 2
  0048    | GetBoundLocal 3
  0050    | GetBoundLocal 4
  0052    | GetConstant2 452: {}
  0055    | GetBoundLocal 6
  0057    | Merge
  0058    | GetConstant2 453: {_0_}
  0061    | GetConstant2 454: "prefixed"
  0064    | GetBoundLocal 7
  0066    | InsertKeyVal 0
  0068    | GetConstant2 455: _Ast.MergePos
  0071    | GetBoundLocal 6
  0073    | GetBoundLocal 7
  0075    | CallFunction 2
  0077    | Merge
  0078    | Merge
  0079    | CallTailFunction 6
  0081    | Jump 81 -> 110
  0084    | GetBoundLocal 0
  0086    | CallFunction 0
  0088    | Destructure 2: Node
  0090    | TakeRight 90 -> 110
  0093    | GetConstant2 451: _ast.with_precedence_rest
  0096    | GetBoundLocal 0
  0098    | GetBoundLocal 1
  0100    | GetBoundLocal 2
  0102    | GetBoundLocal 3
  0104    | GetBoundLocal 4
  0106    | GetBoundLocal 7
  0108    | CallTailFunction 6
  0110    | End
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
  0000    | GetConstant2 456: RightBindingPower
  0003    | GetConstant2 457: PostfixNode
  0006    | GetConstant2 458: NextLeftBindingPower
  0009    | GetConstant2 459: InfixNode
  0012    | GetConstant2 460: RightNode
  0015    | SetInputMark
  0016    | GetBoundLocal 3
  0018    | CallFunction 0
  0020    | Destructure 0: ({"power": RightBindingPower} + PostfixNode)
  0022    | TakeRight 22 -> 38
  0025    | GetConstant 129: const
  0027    | GetConstant2 461: Is.LessThan
  0030    | GetBoundLocal 4
  0032    | GetBoundLocal 6
  0034    | CallFunction 2
  0036    | CallFunction 1
  0038    | ConditionalThen 38 -> 86
  0041    | GetConstant2 451: _ast.with_precedence_rest
  0044    | GetBoundLocal 0
  0046    | GetBoundLocal 1
  0048    | GetBoundLocal 2
  0050    | GetBoundLocal 3
  0052    | GetBoundLocal 4
  0054    | GetConstant2 462: {}
  0057    | GetBoundLocal 7
  0059    | Merge
  0060    | GetConstant2 463: {_0_}
  0063    | GetConstant2 464: "postfixed"
  0066    | GetBoundLocal 5
  0068    | InsertKeyVal 0
  0070    | GetConstant2 455: _Ast.MergePos
  0073    | GetBoundLocal 5
  0075    | GetBoundLocal 7
  0077    | CallFunction 2
  0079    | Merge
  0080    | Merge
  0081    | CallTailFunction 6
  0083    | Jump 83 -> 190
  0086    | SetInputMark
  0087    | GetBoundLocal 2
  0089    | CallFunction 0
  0091    | Destructure 1: ({"power": [RightBindingPower, NextLeftBindingPower]} + InfixNode)
  0093    | TakeRight 93 -> 109
  0096    | GetConstant 129: const
  0098    | GetConstant2 461: Is.LessThan
  0101    | GetBoundLocal 4
  0103    | GetBoundLocal 6
  0105    | CallFunction 2
  0107    | CallFunction 1
  0109    | ConditionalThen 109 -> 184
  0112    | GetConstant2 447: _ast.with_precedence_start
  0115    | GetBoundLocal 0
  0117    | GetBoundLocal 1
  0119    | GetBoundLocal 2
  0121    | GetBoundLocal 3
  0123    | GetBoundLocal 8
  0125    | CallFunction 5
  0127    | Destructure 2: RightNode
  0129    | TakeRight 129 -> 181
  0132    | GetConstant2 451: _ast.with_precedence_rest
  0135    | GetBoundLocal 0
  0137    | GetBoundLocal 1
  0139    | GetBoundLocal 2
  0141    | GetBoundLocal 3
  0143    | GetBoundLocal 4
  0145    | GetConstant2 465: {}
  0148    | GetBoundLocal 9
  0150    | Merge
  0151    | GetConstant2 466: {_0_, _1_}
  0154    | GetConstant2 467: "left"
  0157    | GetBoundLocal 5
  0159    | InsertKeyVal 0
  0161    | GetConstant2 468: "right"
  0164    | GetBoundLocal 10
  0166    | InsertKeyVal 1
  0168    | GetConstant2 455: _Ast.MergePos
  0171    | GetBoundLocal 5
  0173    | GetBoundLocal 10
  0175    | CallFunction 2
  0177    | Merge
  0178    | Merge
  0179    | CallTailFunction 6
  0181    | Jump 181 -> 190
  0184    | GetConstant 129: const
  0186    | GetBoundLocal 5
  0188    | CallTailFunction 1
  0190    | End
  ========================================
  
  ================ast.node================
  ast.node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | GetConstant 156: Value
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 0: Value
  0008    | TakeRight 8 -> 28
  0011    | GetConstant2 469: {_0_, _1_}
  0014    | GetConstant2 327: "type"
  0017    | GetBoundLocal 1
  0019    | InsertKeyVal 0
  0021    | GetConstant2 329: "value"
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
  0007    | GetConstant2 470: {_0_, _1_}
  0010    | GetConstant2 327: "type"
  0013    | GetBoundLocal 1
  0015    | InsertKeyVal 0
  0017    | GetConstant2 471: "power"
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
  0007    | GetConstant2 472: {_0_, _1_}
  0010    | GetConstant2 327: "type"
  0013    | GetBoundLocal 1
  0015    | InsertKeyVal 0
  0017    | GetConstant2 471: "power"
  0020    | GetConstant2 473: [_, _]
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
  0007    | GetConstant2 474: {_0_, _1_}
  0010    | GetConstant2 327: "type"
  0013    | GetBoundLocal 1
  0015    | InsertKeyVal 0
  0017    | GetConstant2 471: "power"
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
  0000    | GetConstant2 475: StartOffset
  0003    | GetConstant2 450: Node
  0006    | GetConstant2 476: EndOffset
  0009    | GetConstant2 477: @input.offset
  0012    | CallFunction 0
  0014    | Destructure 0: StartOffset
  0016    | TakeRight 16 -> 25
  0019    | GetBoundLocal 0
  0021    | CallFunction 0
  0023    | Destructure 1: Node
  0025    | TakeRight 25 -> 62
  0028    | GetConstant2 477: @input.offset
  0031    | CallFunction 0
  0033    | Destructure 2: EndOffset
  0035    | TakeRight 35 -> 62
  0038    | GetConstant2 478: {}
  0041    | GetBoundLocal 2
  0043    | Merge
  0044    | GetConstant2 479: {_0_, _1_}
  0047    | GetConstant2 480: "startpos"
  0050    | GetBoundLocal 1
  0052    | InsertKeyVal 0
  0054    | GetConstant2 481: "endpos"
  0057    | GetBoundLocal 3
  0059    | InsertKeyVal 1
  0061    | Merge
  0062    | End
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
  0000    | GetConstant2 482: StartLine
  0003    | GetConstant2 483: StartLineOffset
  0006    | GetConstant2 450: Node
  0009    | GetConstant2 484: EndLine
  0012    | GetConstant2 485: EndLineOffset
  0015    | GetConstant2 486: @input.line
  0018    | CallFunction 0
  0020    | Destructure 0: StartLine
  0022    | TakeRight 22 -> 32
  0025    | GetConstant2 487: @input.line_offset
  0028    | CallFunction 0
  0030    | Destructure 1: StartLineOffset
  0032    | TakeRight 32 -> 41
  0035    | GetBoundLocal 0
  0037    | CallFunction 0
  0039    | Destructure 2: Node
  0041    | TakeRight 41 -> 51
  0044    | GetConstant2 486: @input.line
  0047    | CallFunction 0
  0049    | Destructure 3: EndLine
  0051    | TakeRight 51 -> 118
  0054    | GetConstant2 487: @input.line_offset
  0057    | CallFunction 0
  0059    | Destructure 4: EndLineOffset
  0061    | TakeRight 61 -> 118
  0064    | GetConstant2 488: {}
  0067    | GetBoundLocal 3
  0069    | Merge
  0070    | GetConstant2 489: {_0_, _1_}
  0073    | GetConstant2 480: "startpos"
  0076    | GetConstant2 490: {_0_, _1_}
  0079    | GetConstant2 491: "line"
  0082    | GetBoundLocal 1
  0084    | InsertKeyVal 0
  0086    | GetConstant2 308: "offset"
  0089    | GetBoundLocal 2
  0091    | InsertKeyVal 1
  0093    | InsertKeyVal 0
  0095    | GetConstant2 481: "endpos"
  0098    | GetConstant2 492: {_0_, _1_}
  0101    | GetConstant2 491: "line"
  0104    | GetBoundLocal 4
  0106    | InsertKeyVal 0
  0108    | GetConstant2 308: "offset"
  0111    | GetBoundLocal 5
  0113    | InsertKeyVal 1
  0115    | InsertKeyVal 1
  0117    | Merge
  0118    | End
  ========================================
  
  ================Num.Inc=================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant2 493: @Add
  0003    | GetBoundLocal 0
  0005    | GetConstant 81: 1
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================Num.Dec=================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant2 494: @Subtract
  0003    | GetBoundLocal 0
  0005    | GetConstant 81: 1
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  ================Num.Abs=================
  Num.Abs(N) = N -> 0.. | -N
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 0: 0..
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
  0003    | Destructure 0: B..
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
  0000    | GetConstant2 495: Len
  0003    | GetConstant2 496: Array.Length
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Destructure 0: Len
  0012    | TakeRight 12 -> 29
  0015    | GetConstant2 497: _Num.FromBinaryDigits
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | GetConstant 106: -1
  0024    | Merge
  0025    | GetConstant 83: 0
  0027    | CallTailFunction 3
  0029    | End
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
  0000    | GetConstant2 498: B
  0003    | GetConstant2 499: Rest
  0006    | SetInputMark
  0007    | GetBoundLocal 0
  0009    | Destructure 0: ([B] + Rest)
  0011    | ConditionalThen 11 -> 56
  0014    | GetBoundLocal 3
  0016    | Destructure 1: 0..1
  0018    | TakeRight 18 -> 53
  0021    | GetConstant2 497: _Num.FromBinaryDigits
  0024    | GetBoundLocal 4
  0026    | GetBoundLocal 1
  0028    | GetConstant 106: -1
  0030    | Merge
  0031    | GetBoundLocal 2
  0033    | GetConstant2 500: @Multiply
  0036    | GetBoundLocal 3
  0038    | GetConstant2 501: @Power
  0041    | GetConstant2 351: 2
  0044    | GetBoundLocal 1
  0046    | CallFunction 2
  0048    | CallFunction 2
  0050    | Merge
  0051    | CallTailFunction 3
  0053    | Jump 53 -> 58
  0056    | GetBoundLocal 2
  0058    | End
  ========================================
  
  ==========Num.FromOctalDigits===========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | GetConstant2 495: Len
  0003    | GetConstant2 496: Array.Length
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Destructure 0: Len
  0012    | TakeRight 12 -> 29
  0015    | GetConstant2 502: _Num.FromOctalDigits
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | GetConstant 106: -1
  0024    | Merge
  0025    | GetConstant 83: 0
  0027    | CallTailFunction 3
  0029    | End
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
  0000    | GetConstant2 503: O
  0003    | GetConstant2 499: Rest
  0006    | SetInputMark
  0007    | GetBoundLocal 0
  0009    | Destructure 0: ([O] + Rest)
  0011    | ConditionalThen 11 -> 56
  0014    | GetBoundLocal 3
  0016    | Destructure 1: 0..7
  0018    | TakeRight 18 -> 53
  0021    | GetConstant2 502: _Num.FromOctalDigits
  0024    | GetBoundLocal 4
  0026    | GetBoundLocal 1
  0028    | GetConstant 106: -1
  0030    | Merge
  0031    | GetBoundLocal 2
  0033    | GetConstant2 500: @Multiply
  0036    | GetBoundLocal 3
  0038    | GetConstant2 501: @Power
  0041    | GetConstant2 361: 8
  0044    | GetBoundLocal 1
  0046    | CallFunction 2
  0048    | CallFunction 2
  0050    | Merge
  0051    | CallTailFunction 3
  0053    | Jump 53 -> 58
  0056    | GetBoundLocal 2
  0058    | End
  ========================================
  
  ===========Num.FromHexDigits============
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | GetConstant2 495: Len
  0003    | GetConstant2 496: Array.Length
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Destructure 0: Len
  0012    | TakeRight 12 -> 29
  0015    | GetConstant2 504: _Num.FromHexDigits
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | GetConstant 106: -1
  0024    | Merge
  0025    | GetConstant 83: 0
  0027    | CallTailFunction 3
  0029    | End
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
  0000    | GetConstant 217: H
  0002    | GetConstant2 499: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 0: ([H] + Rest)
  0010    | ConditionalThen 10 -> 55
  0013    | GetBoundLocal 3
  0015    | Destructure 1: 0..15
  0017    | TakeRight 17 -> 52
  0020    | GetConstant2 504: _Num.FromHexDigits
  0023    | GetBoundLocal 4
  0025    | GetBoundLocal 1
  0027    | GetConstant 106: -1
  0029    | Merge
  0030    | GetBoundLocal 2
  0032    | GetConstant2 500: @Multiply
  0035    | GetBoundLocal 3
  0037    | GetConstant2 501: @Power
  0040    | GetConstant2 505: 16
  0043    | GetBoundLocal 1
  0045    | CallFunction 2
  0047    | CallFunction 2
  0049    | Merge
  0050    | CallTailFunction 3
  0052    | Jump 52 -> 57
  0055    | GetBoundLocal 2
  0057    | End
  ========================================
  
  ==============Array.First===============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | GetConstant2 506: F
  0003    | GetConstant 114: _
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([F] + _)
  0009    | TakeRight 9 -> 14
  0012    | GetBoundLocal 1
  0014    | End
  ========================================
  
  ===============Array.Rest===============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | GetConstant 114: _
  0002    | GetConstant2 507: R
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([_] + R)
  0009    | TakeRight 9 -> 14
  0012    | GetBoundLocal 2
  0014    | End
  ========================================
  
  ==============Array.Length==============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | GetConstant 114: _
  0002    | GetConstant 218: L
  0004    | GetBoundLocal 0
  0006    | Destructure 0: ([_] * L)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 2
  0013    | End
  ========================================
  
  =============Array.Reverse==============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant2 508: _Array.Reverse
  0003    | GetBoundLocal 0
  0005    | GetConstant2 509: []
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  =============_Array.Reverse=============
  _Array.Reverse(A, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reverse(Rest, [First, ...Acc]) :
    Acc
  ========================================
  0000    | GetConstant 115: First
  0002    | GetConstant2 499: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 0: ([First] + Rest)
  0010    | ConditionalThen 10 -> 33
  0013    | GetConstant2 508: _Array.Reverse
  0016    | GetBoundLocal 3
  0018    | GetConstant2 510: [_]
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
  0000    | GetConstant2 511: _Array.Map
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetConstant2 512: []
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  ===============_Array.Map===============
  _Array.Map(A, Fn, Acc) =
    A -> [First, ...Rest] ?
    _Array.Map(Rest, Fn, [...Acc, Fn(First)]) :
    Acc
  ========================================
  0000    | GetConstant 115: First
  0002    | GetConstant2 499: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 0: ([First] + Rest)
  0010    | ConditionalThen 10 -> 43
  0013    | GetConstant2 511: _Array.Map
  0016    | GetBoundLocal 4
  0018    | GetBoundLocal 1
  0020    | GetConstant2 513: []
  0023    | GetBoundLocal 2
  0025    | Merge
  0026    | GetConstant2 514: [_]
  0029    | GetBoundLocal 1
  0031    | GetBoundLocal 3
  0033    | CallFunction 1
  0035    | InsertAtIndex 0
  0037    | Merge
  0038    | CallTailFunction 3
  0040    | Jump 40 -> 45
  0043    | GetBoundLocal 2
  0045    | End
  ========================================
  
  ==============Array.Filter==============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant2 515: _Array.Filter
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetConstant2 516: []
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  =============_Array.Filter==============
  _Array.Filter(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Filter(Rest, Pred, Pred(First) ? [...Acc, First] : Acc) :
    Acc
  ========================================
  0000    | GetConstant 115: First
  0002    | GetConstant2 499: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 0: ([First] + Rest)
  0010    | ConditionalThen 10 -> 54
  0013    | GetConstant2 515: _Array.Filter
  0016    | GetBoundLocal 4
  0018    | GetBoundLocal 1
  0020    | SetInputMark
  0021    | GetBoundLocal 1
  0023    | GetBoundLocal 3
  0025    | CallFunction 1
  0027    | ConditionalThen 27 -> 47
  0030    | GetConstant2 517: []
  0033    | GetBoundLocal 2
  0035    | Merge
  0036    | GetConstant2 518: [_]
  0039    | GetBoundLocal 3
  0041    | InsertAtIndex 0
  0043    | Merge
  0044    | Jump 44 -> 49
  0047    | GetBoundLocal 2
  0049    | CallTailFunction 3
  0051    | Jump 51 -> 56
  0054    | GetBoundLocal 2
  0056    | End
  ========================================
  
  ==============Array.Reject==============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant2 519: _Array.Reject
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetConstant2 520: []
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  =============_Array.Reject==============
  _Array.Reject(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reject(Rest, Pred, Pred(First) ? Acc : [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant 115: First
  0002    | GetConstant2 499: Rest
  0005    | SetInputMark
  0006    | GetBoundLocal 0
  0008    | Destructure 0: ([First] + Rest)
  0010    | ConditionalThen 10 -> 54
  0013    | GetConstant2 519: _Array.Reject
  0016    | GetBoundLocal 4
  0018    | GetBoundLocal 1
  0020    | SetInputMark
  0021    | GetBoundLocal 1
  0023    | GetBoundLocal 3
  0025    | CallFunction 1
  0027    | ConditionalThen 27 -> 35
  0030    | GetBoundLocal 2
  0032    | Jump 32 -> 49
  0035    | GetConstant2 521: []
  0038    | GetBoundLocal 2
  0040    | Merge
  0041    | GetConstant2 522: [_]
  0044    | GetBoundLocal 3
  0046    | InsertAtIndex 0
  0048    | Merge
  0049    | CallTailFunction 3
  0051    | Jump 51 -> 56
  0054    | GetBoundLocal 2
  0056    | End
  ========================================
  
  ============Array.ZipObject=============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant2 523: _Array.ZipObject
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetConstant2 524: {}
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  ============_Array.ZipObject============
  _Array.ZipObject(Ks, Vs, Acc) =
    Ks -> [K, ...KsRest] & Vs -> [V, ...VsRest] ?
    _Array.ZipObject(KsRest, VsRest, {...Acc, K: V}) :
    Acc
  ========================================
  0000    | GetConstant 152: K
  0002    | GetConstant2 525: KsRest
  0005    | GetConstant 153: V
  0007    | GetConstant2 526: VsRest
  0010    | SetInputMark
  0011    | GetBoundLocal 0
  0013    | Destructure 0: ([K] + KsRest)
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocal 1
  0020    | Destructure 1: ([V] + VsRest)
  0022    | ConditionalThen 22 -> 53
  0025    | GetConstant2 523: _Array.ZipObject
  0028    | GetBoundLocal 4
  0030    | GetBoundLocal 6
  0032    | GetConstant2 527: {}
  0035    | GetBoundLocal 2
  0037    | Merge
  0038    | GetConstant2 528: {_0_}
  0041    | GetBoundLocal 3
  0043    | GetBoundLocal 5
  0045    | InsertKeyVal 0
  0047    | Merge
  0048    | CallTailFunction 3
  0050    | Jump 50 -> 55
  0053    | GetBoundLocal 2
  0055    | End
  ========================================
  
  =============Array.ZipPairs=============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant2 529: _Array.ZipPairs
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetConstant2 530: []
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  ============_Array.ZipPairs=============
  _Array.ZipPairs(A1, A2, Acc) =
    A1 -> [First1, ...Rest1] & A2 -> [First2, ...Rest2] ?
    _Array.ZipPairs(Rest1, Rest2, [...Acc, [First1, First2]]) :
    Acc
  ========================================
  0000    | GetConstant2 531: First1
  0003    | GetConstant2 532: Rest1
  0006    | GetConstant2 533: First2
  0009    | GetConstant2 534: Rest2
  0012    | SetInputMark
  0013    | GetBoundLocal 0
  0015    | Destructure 0: ([First1] + Rest1)
  0017    | TakeRight 17 -> 24
  0020    | GetBoundLocal 1
  0022    | Destructure 1: ([First2] + Rest2)
  0024    | ConditionalThen 24 -> 62
  0027    | GetConstant2 529: _Array.ZipPairs
  0030    | GetBoundLocal 4
  0032    | GetBoundLocal 6
  0034    | GetConstant2 535: []
  0037    | GetBoundLocal 2
  0039    | Merge
  0040    | GetConstant2 536: [_]
  0043    | GetConstant2 537: [_, _]
  0046    | GetBoundLocal 3
  0048    | InsertAtIndex 0
  0050    | GetBoundLocal 5
  0052    | InsertAtIndex 1
  0054    | InsertAtIndex 0
  0056    | Merge
  0057    | CallTailFunction 3
  0059    | Jump 59 -> 64
  0062    | GetBoundLocal 2
  0064    | End
  ========================================
  
  =============Array.AppendN==============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetBoundLocal 0
  0002    | GetConstant2 538: [_]
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
  0000    | GetConstant2 539: _Table.Transpose
  0003    | GetBoundLocal 0
  0005    | GetConstant2 540: []
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  ============_Table.Transpose============
  _Table.Transpose(T, Acc) =
    _Table.FirstPerRow(T) -> FirstPerRow &
    _Table.RestPerRow(T) -> RestPerRow ?
    _Table.Transpose(RestPerRow, [...Acc, FirstPerRow]) :
    Acc
  ========================================
  0000    | GetConstant2 541: FirstPerRow
  0003    | GetConstant2 542: RestPerRow
  0006    | SetInputMark
  0007    | GetConstant2 543: _Table.FirstPerRow
  0010    | GetBoundLocal 0
  0012    | CallFunction 1
  0014    | Destructure 0: FirstPerRow
  0016    | TakeRight 16 -> 28
  0019    | GetConstant2 544: _Table.RestPerRow
  0022    | GetBoundLocal 0
  0024    | CallFunction 1
  0026    | Destructure 1: RestPerRow
  0028    | ConditionalThen 28 -> 55
  0031    | GetConstant2 539: _Table.Transpose
  0034    | GetBoundLocal 3
  0036    | GetConstant2 545: []
  0039    | GetBoundLocal 1
  0041    | Merge
  0042    | GetConstant2 546: [_]
  0045    | GetBoundLocal 2
  0047    | InsertAtIndex 0
  0049    | Merge
  0050    | CallTailFunction 2
  0052    | Jump 52 -> 57
  0055    | GetBoundLocal 1
  0057    | End
  ========================================
  
  ===========_Table.FirstPerRow===========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | GetConstant2 547: Row
  0003    | GetConstant2 499: Rest
  0006    | GetConstant2 548: VeryFirst
  0009    | GetConstant 114: _
  0011    | GetBoundLocal 0
  0013    | Destructure 0: ([Row] + Rest)
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocal 1
  0020    | Destructure 1: ([VeryFirst] + _)
  0022    | TakeRight 22 -> 39
  0025    | GetConstant2 549: __Table.FirstPerRow
  0028    | GetBoundLocal 2
  0030    | GetConstant2 550: [_]
  0033    | GetBoundLocal 3
  0035    | InsertAtIndex 0
  0037    | CallTailFunction 2
  0039    | End
  ========================================
  
  ==========__Table.FirstPerRow===========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant2 547: Row
  0003    | GetConstant2 499: Rest
  0006    | GetConstant 115: First
  0008    | GetConstant 114: _
  0010    | SetInputMark
  0011    | GetBoundLocal 0
  0013    | Destructure 0: ([Row] + Rest)
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocal 2
  0020    | Destructure 1: ([First] + _)
  0022    | ConditionalThen 22 -> 49
  0025    | GetConstant2 549: __Table.FirstPerRow
  0028    | GetBoundLocal 3
  0030    | GetConstant2 551: []
  0033    | GetBoundLocal 1
  0035    | Merge
  0036    | GetConstant2 552: [_]
  0039    | GetBoundLocal 4
  0041    | InsertAtIndex 0
  0043    | Merge
  0044    | CallTailFunction 2
  0046    | Jump 46 -> 51
  0049    | GetBoundLocal 1
  0051    | End
  ========================================
  
  ===========_Table.RestPerRow============
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant2 553: __Table.RestPerRow
  0003    | GetBoundLocal 0
  0005    | GetConstant2 554: []
  0008    | CallTailFunction 2
  0010    | End
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
  0000    | GetConstant2 547: Row
  0003    | GetConstant2 499: Rest
  0006    | GetConstant 114: _
  0008    | GetConstant2 555: RowRest
  0011    | SetInputMark
  0012    | GetBoundLocal 0
  0014    | Destructure 0: ([Row] + Rest)
  0016    | ConditionalThen 16 -> 71
  0019    | SetInputMark
  0020    | GetBoundLocal 2
  0022    | Destructure 1: ([_] + RowRest)
  0024    | ConditionalThen 24 -> 51
  0027    | GetConstant2 553: __Table.RestPerRow
  0030    | GetBoundLocal 3
  0032    | GetConstant2 556: []
  0035    | GetBoundLocal 1
  0037    | Merge
  0038    | GetConstant2 557: [_]
  0041    | GetBoundLocal 5
  0043    | InsertAtIndex 0
  0045    | Merge
  0046    | CallTailFunction 2
  0048    | Jump 48 -> 68
  0051    | GetConstant2 553: __Table.RestPerRow
  0054    | GetBoundLocal 3
  0056    | GetConstant2 558: []
  0059    | GetBoundLocal 1
  0061    | Merge
  0062    | GetConstant2 559: [[]]
  0065    | Merge
  0066    | CallTailFunction 2
  0068    | Jump 68 -> 73
  0071    | GetBoundLocal 1
  0073    | End
  ========================================
  
  =========Table.RotateClockwise==========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant2 560: Array.Map
  0003    | GetConstant 137: Table.Transpose
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | GetConstant2 561: Array.Reverse
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  ======Table.RotateCounterClockwise======
  Table.RotateCounterClockwise(T) = Array.Reverse(Table.Transpose(T))
  ========================================
  0000    | GetConstant2 561: Array.Reverse
  0003    | GetConstant 137: Table.Transpose
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  ============Table.ZipObjects============
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant2 562: _Table.ZipObjects
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | GetConstant2 563: []
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  ===========_Table.ZipObjects============
  _Table.ZipObjects(Ks, Rows, Acc) =
    Rows -> [Row, ...Rest] ?
    _Table.ZipObjects(Ks, Rest, [...Acc, Array.ZipObject(Ks, Row)]) :
    Acc
  ========================================
  0000    | GetConstant2 547: Row
  0003    | GetConstant2 499: Rest
  0006    | SetInputMark
  0007    | GetBoundLocal 1
  0009    | Destructure 0: ([Row] + Rest)
  0011    | ConditionalThen 11 -> 47
  0014    | GetConstant2 562: _Table.ZipObjects
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 4
  0021    | GetConstant2 564: []
  0024    | GetBoundLocal 2
  0026    | Merge
  0027    | GetConstant2 565: [_]
  0030    | GetConstant2 566: Array.ZipObject
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 3
  0037    | CallFunction 2
  0039    | InsertAtIndex 0
  0041    | Merge
  0042    | CallTailFunction 3
  0044    | Jump 44 -> 49
  0047    | GetBoundLocal 2
  0049    | End
  ========================================
  
  ================Obj.Has=================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | GetConstant 114: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ({K: _} + _)
  0006    | End
  ========================================
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | GetConstant 153: V
  0002    | GetConstant 114: _
  0004    | GetBoundLocal 0
  0006    | Destructure 0: ({K: V} + _)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 2
  0013    | End
  ========================================
  
  ================Obj.Put=================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | GetConstant2 567: {}
  0003    | GetBoundLocal 0
  0005    | Merge
  0006    | GetConstant2 568: {_0_}
  0009    | GetBoundLocal 1
  0011    | GetBoundLocal 2
  0013    | InsertKeyVal 0
  0015    | Merge
  0016    | End
  ========================================
  
  =============_Ast.MergePos==============
  _Ast.MergePos(Left, Right) = {
    ...(Left -> {"startpos": StartPos, ..._} ? {"startpos": StartPos} : {}),
    ...(Right -> {"endpos": EndPos, ..._} ? {"endpos": EndPos} : {}),
  }
  ========================================
  0000    | GetConstant2 569: StartPos
  0003    | GetConstant 114: _
  0005    | GetConstant2 570: EndPos
  0008    | GetConstant2 571: {}
  0011    | SetInputMark
  0012    | GetBoundLocal 0
  0014    | Destructure 0: ({"startpos": StartPos} + _)
  0016    | ConditionalThen 16 -> 32
  0019    | GetConstant2 572: {_0_}
  0022    | GetConstant2 480: "startpos"
  0025    | GetBoundLocal 2
  0027    | InsertKeyVal 0
  0029    | Jump 29 -> 35
  0032    | GetConstant2 573: {}
  0035    | Merge
  0036    | SetInputMark
  0037    | GetBoundLocal 1
  0039    | Destructure 1: ({"endpos": EndPos} + _)
  0041    | ConditionalThen 41 -> 57
  0044    | GetConstant2 574: {_0_}
  0047    | GetConstant2 481: "endpos"
  0050    | GetBoundLocal 4
  0052    | InsertKeyVal 0
  0054    | Jump 54 -> 60
  0057    | GetConstant2 575: {}
  0060    | Merge
  0061    | End
  ========================================
  
  ===============Is.String================
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | GetConstant 114: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ("" + _)
  0006    | End
  ========================================
  
  ===============Is.Number================
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | GetConstant 114: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: (0 + _)
  0006    | End
  ========================================
  
  ================Is.Bool=================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | GetConstant 114: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: (false + _)
  0006    | End
  ========================================
  
  ================Is.Null=================
  Is.Null(V) = V -> null
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 0: null
  0004    | End
  ========================================
  
  ================Is.Array================
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | GetConstant 114: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ([] + _)
  0006    | End
  ========================================
  
  ===============Is.Object================
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | GetConstant 114: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ({} + _)
  0006    | End
  ========================================
  
  ================Is.Equal================
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 0: B
  0004    | End
  ========================================
  
  ==============Is.LessThan===============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 0: B
  0005    | ConditionalThen 5 -> 16
  0008    | GetConstant2 441: @Fail
  0011    | CallTailFunction 0
  0013    | Jump 13 -> 20
  0016    | GetBoundLocal 0
  0018    | Destructure 1: ..B
  0020    | End
  ========================================
  
  ===========Is.LessThanOrEqual===========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 0: ..B
  0004    | End
  ========================================
  
  =============Is.GreaterThan=============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 0: B
  0005    | ConditionalThen 5 -> 16
  0008    | GetConstant2 441: @Fail
  0011    | CallTailFunction 0
  0013    | Jump 13 -> 20
  0016    | GetBoundLocal 0
  0018    | Destructure 1: B..
  0020    | End
  ========================================
  
  =========Is.GreaterThanOrEqual==========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetBoundLocal 0
  0002    | Destructure 0: B..
  0004    | End
  ========================================
  
  ===============As.Number================
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | GetConstant 178: N
  0002    | SetInputMark
  0003    | GetConstant2 576: Is.Number
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Or 10 -> 22
  0013    | GetBoundLocal 0
  0015    | Destructure 0: "%(0 + N)"
  0017    | TakeRight 17 -> 22
  0020    | GetBoundLocal 1
  0022    | End
  ========================================
  
  ===============As.String================
  As.String(V) = "%(V)"
  ========================================
  0000    | GetConstant 177: ""
  0002    | GetBoundLocal 0
  0004    | MergeAsString
  0005    | End
  ========================================

