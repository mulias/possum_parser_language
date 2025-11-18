  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i ''
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCharacter
  0001    | End
  ========================================
  
  =================ascii==================
  ascii = "\u000000".."\u00007F"
  ========================================
  0000    | ParseFixedRange 0 1: _0 "\x7f" (esc)
  0003    | End
  ========================================
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseFixedRange 0 1: "a" "z"
  0004    | Or 4 -> 10
  0007    | ParseFixedRange 2 3: "A" "Z"
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
  0000    | ParseFixedRange 0 1: "a" "z"
  0003    | End
  ========================================
  
  =================lowers=================
  lowers = many(lower)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: lower
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================upper==================
  upper = "A".."Z"
  ========================================
  0000    | ParseFixedRange 0 1: "A" "Z"
  0003    | End
  ========================================
  
  =================uppers=================
  uppers = many(upper)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: upper
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseFixedRange 0 1: "0" "9"
  0003    | End
  ========================================
  
  ================numerals================
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============binary_numeral=============
  binary_numeral = "0" | "1"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "0"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "1"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =============octal_numeral==============
  octal_numeral = "0".."7"
  ========================================
  0000    | ParseFixedRange 0 1: "0" "7"
  0003    | End
  ========================================
  
  ==============hex_numeral===============
  hex_numeral = numeral | "a".."f" | "A".."F"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: numeral
  0003    | CallFunction 0
  0005    | Or 5 -> 18
  0008    | SetInputMark
  0009    | ParseFixedRange 1 2: "a" "f"
  0012    | Or 12 -> 18
  0015    | ParseFixedRange 3 4: "A" "F"
  0018    | End
  ========================================
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: alpha
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: numeral
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================alnums=================
  alnums = many(alnum)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: alnum
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn730=================
  unless(char, whitespace)
  ========================================
  0000    | GetConstant 0: unless
  0002    | GetConstant 1: char
  0004    | GetConstant 2: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  token = many(unless(char, whitespace))
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn730
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn731=================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: alnum
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | GetConstant 1: "_"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: "-"
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  ==================word==================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn731
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn732=================
  newline | end_of_input
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: newline
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: end_of_input
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==================line==================
  line = chars_until(newline | end_of_input)
  ========================================
  0000    | GetConstant 0: chars_until
  0002    | GetConstant 1: @fn732
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================space==================
  space =
    " " | "\t" | "\u0000A0" | "\u002000".."\u00200A" | "\u00202F" | "\u00205F" | "\u003000"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: " "
  0003    | CallFunction 0
  0005    | Or 5 -> 51
  0008    | SetInputMark
  0009    | GetConstant 1: "\t" (esc)
  0011    | CallFunction 0
  0013    | Or 13 -> 51
  0016    | SetInputMark
  0017    | GetConstant 2: "\xc2\xa0" (esc)
  0019    | CallFunction 0
  0021    | Or 21 -> 51
  0024    | SetInputMark
  0025    | ParseFixedRange 3 4: "\xe2\x80\x80" "\xe2\x80\x8a" (esc)
  0028    | Or 28 -> 51
  0031    | SetInputMark
  0032    | GetConstant 5: "\xe2\x80\xaf" (esc)
  0034    | CallFunction 0
  0036    | Or 36 -> 51
  0039    | SetInputMark
  0040    | GetConstant 6: "\xe2\x81\x9f" (esc)
  0042    | CallFunction 0
  0044    | Or 44 -> 51
  0047    | GetConstant 7: "\xe3\x80\x80" (esc)
  0049    | CallFunction 0
  0051    | End
  ========================================
  
  =================spaces=================
  spaces = many(space)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================newline=================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "\r (esc)
  "
  0003    | CallFunction 0
  0005    | Or 5 -> 35
  0008    | SetInputMark
  0009    | ParseFixedRange 1 2: "
  " "\r (no-eol) (esc)
  "
  0012    | Or 12 -> 35
  0015    | SetInputMark
  0016    | GetConstant 3: "\xc2\x85" (esc)
  0018    | CallFunction 0
  0020    | Or 20 -> 35
  0023    | SetInputMark
  0024    | GetConstant 4: "\xe2\x80\xa8" (esc)
  0026    | CallFunction 0
  0028    | Or 28 -> 35
  0031    | GetConstant 5: "\xe2\x80\xa9" (esc)
  0033    | CallFunction 0
  0035    | End
  ========================================
  
  ================newlines================
  newlines = many(newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn733=================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: newline
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ===============whitespace===============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn733
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============chars_until===============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 0: many_until
  0002    | GetConstant 1: char
  0004    | GetBoundLocal 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseFixedRange 0 1: 0 9
  0003    | End
  ========================================
  
  =================@fn734=================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | GetConstant 2: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn734
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========non_negative_integer==========
  non_negative_integer = as_number(_number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn735=================
  "-" + _number_integer_part
  ========================================
  0000    | GetConstant 0: "-"
  0002    | CallFunction 0
  0004    | GetConstant 1: _number_integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  ============negative_integer============
  negative_integer = as_number("-" + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn735
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn736=================
  maybe("-") + _number_integer_part + _number_fraction_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | GetConstant 2: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 3: _number_fraction_part
  0013    | CallFunction 0
  0015    | Merge
  0016    | End
  ========================================
  
  =================float==================
  float = as_number(maybe("-") + _number_integer_part + _number_fraction_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn736
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn737=================
  maybe("-") +
    _number_integer_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | GetConstant 2: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 3: _number_exponent_part
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn737
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn738=================
  maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | GetConstant 2: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 3: _number_fraction_part
  0013    | CallFunction 0
  0015    | Merge
  0016    | GetConstant 4: _number_exponent_part
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn738
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn739=================
  maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | GetConstant 2: _number_integer_part
  0008    | CallFunction 0
  0010    | Merge
  0011    | GetConstant 3: maybe
  0013    | GetConstant 4: _number_fraction_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | GetConstant 5: maybe
  0020    | GetConstant 6: _number_exponent_part
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn739
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn740=================
  _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 0: _number_integer_part
  0002    | CallFunction 0
  0004    | GetConstant 1: maybe
  0006    | GetConstant 2: _number_fraction_part
  0008    | CallFunction 1
  0010    | Merge
  0011    | GetConstant 3: maybe
  0013    | GetConstant 4: _number_exponent_part
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn740
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn741=================
  "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 0: "-"
  0002    | CallFunction 0
  0004    | GetConstant 1: _number_integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | GetConstant 2: maybe
  0011    | GetConstant 3: _number_fraction_part
  0013    | CallFunction 1
  0015    | Merge
  0016    | GetConstant 4: maybe
  0018    | GetConstant 5: _number_exponent_part
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn741
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_number_integer_part==========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseFixedRange 0 1: "1" "9"
  0004    | GetConstant 2: numerals
  0006    | CallFunction 0
  0008    | Merge
  0009    | Or 9 -> 16
  0012    | GetConstant 3: numeral
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =========_number_fraction_part==========
  _number_fraction_part = "." + numerals
  ========================================
  0000    | GetConstant 0: "."
  0002    | CallFunction 0
  0004    | GetConstant 1: numerals
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  =================@fn742=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_number_exponent_part==========
  _number_exponent_part = ("e" | "E") + maybe("-" | "+") + numerals
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "E"
  0010    | CallFunction 0
  0012    | GetConstant 2: maybe
  0014    | GetConstant 3: @fn742
  0016    | CallFunction 1
  0018    | Merge
  0019    | GetConstant 4: numerals
  0021    | CallFunction 0
  0023    | Merge
  0024    | End
  ========================================
  
  ==============binary_digit==============
  binary_digit = 0..1
  ========================================
  0000    | ParseFixedRange 0 1: 0 1
  0003    | End
  ========================================
  
  ==============octal_digit===============
  octal_digit = 0..7
  ========================================
  0000    | ParseFixedRange 0 1: 0 7
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
  0001    | GetConstant 0: digit
  0003    | CallFunction 0
  0005    | Or 5 -> 130
  0008    | SetInputMark
  0009    | SetInputMark
  0010    | GetConstant 1: "a"
  0012    | CallFunction 0
  0014    | Or 14 -> 21
  0017    | GetConstant 2: "A"
  0019    | CallFunction 0
  0021    | TakeRight 21 -> 26
  0024    | GetConstant 3: 10
  0026    | Or 26 -> 130
  0029    | SetInputMark
  0030    | SetInputMark
  0031    | GetConstant 4: "b"
  0033    | CallFunction 0
  0035    | Or 35 -> 42
  0038    | GetConstant 5: "B"
  0040    | CallFunction 0
  0042    | TakeRight 42 -> 47
  0045    | GetConstant 6: 11
  0047    | Or 47 -> 130
  0050    | SetInputMark
  0051    | SetInputMark
  0052    | GetConstant 7: "c"
  0054    | CallFunction 0
  0056    | Or 56 -> 63
  0059    | GetConstant 8: "C"
  0061    | CallFunction 0
  0063    | TakeRight 63 -> 68
  0066    | GetConstant 9: 12
  0068    | Or 68 -> 130
  0071    | SetInputMark
  0072    | SetInputMark
  0073    | GetConstant 10: "d"
  0075    | CallFunction 0
  0077    | Or 77 -> 84
  0080    | GetConstant 11: "D"
  0082    | CallFunction 0
  0084    | TakeRight 84 -> 89
  0087    | GetConstant 12: 13
  0089    | Or 89 -> 130
  0092    | SetInputMark
  0093    | SetInputMark
  0094    | GetConstant 13: "e"
  0096    | CallFunction 0
  0098    | Or 98 -> 105
  0101    | GetConstant 14: "E"
  0103    | CallFunction 0
  0105    | TakeRight 105 -> 110
  0108    | GetConstant 15: 14
  0110    | Or 110 -> 130
  0113    | SetInputMark
  0114    | GetConstant 16: "f"
  0116    | CallFunction 0
  0118    | Or 118 -> 125
  0121    | GetConstant 17: "F"
  0123    | CallFunction 0
  0125    | TakeRight 125 -> 130
  0128    | GetConstant 18: 15
  0130    | End
  ========================================
  
  =============binary_integer=============
  binary_integer = array(binary_digit) -> Digits $ Num.FromBinaryDigits(Digits)
  ========================================
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: array
  0004    | GetConstant 2: binary_digit
  0006    | CallFunction 1
  0008    | Destructure 0: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 3: Num.FromBinaryDigits
  0015    | GetBoundLocal 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  =============octal_integer==============
  octal_integer = array(octal_digit) -> Digits $ Num.FromOctalDigits(Digits)
  ========================================
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: array
  0004    | GetConstant 2: octal_digit
  0006    | CallFunction 1
  0008    | Destructure 0: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 3: Num.FromOctalDigits
  0015    | GetBoundLocal 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  ==============hex_integer===============
  hex_integer = array(hex_digit) -> Digits $ Num.FromHexDigits(Digits)
  ========================================
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: array
  0004    | GetConstant 2: hex_digit
  0006    | CallFunction 1
  0008    | Destructure 0: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 3: Num.FromHexDigits
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
  0001    | GetConstant 0: true
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
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
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 27
  0008    | Swap
  0009    | GetConstant 2: tuple1
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
  0029    | GetConstant 3: tuple1
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
  0000    | GetConstant 0: sep
  0002    | GetConstant 1: elem
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
  0000    | GetConstant 0: sep
  0002    | GetConstant 1: elem
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
  0000    | GetConstant 0: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | GetConstant 1: null
  0008    | GetConstant 2: 0
  0010    | ValidateRepeatPattern
  0011    | JumpIfZero 11 -> 39
  0014    | Swap
  0015    | GetConstant 3: tuple1
  0017    | GetConstant 4: @fn743
  0019    | CaptureLocal 0 1
  0022    | CaptureLocal 1 0
  0025    | CallFunction 1
  0027    | Merge
  0028    | JumpIfFailure 28 -> 63
  0031    | Swap
  0032    | Decrement
  0033    | JumpIfZero 33 -> 39
  0036    | JumpBack 36 -> 14
  0039    | Swap
  0040    | SetInputMark
  0041    | GetConstant 5: tuple1
  0043    | GetConstant 6: @fn744
  0045    | CaptureLocal 0 1
  0048    | CaptureLocal 1 0
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
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn746=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: tuple1
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============array_until===============
  array_until(elem, stop) = unless(tuple1(elem), stop) * 1.. < peek(stop)
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 32
  0008    | Swap
  0009    | GetConstant 2: unless
  0011    | GetConstant 3: @fn745
  0013    | CaptureLocal 0 0
  0016    | GetBoundLocal 1
  0018    | CallFunction 2
  0020    | Merge
  0021    | JumpIfFailure 21 -> 55
  0024    | Swap
  0025    | Decrement
  0026    | JumpIfZero 26 -> 32
  0029    | JumpBack 29 -> 8
  0032    | Swap
  0033    | SetInputMark
  0034    | GetConstant 4: unless
  0036    | GetConstant 5: @fn746
  0038    | CaptureLocal 0 0
  0041    | GetBoundLocal 1
  0043    | CallFunction 2
  0045    | JumpIfFailure 45 -> 53
  0048    | PopInputMark
  0049    | Merge
  0050    | JumpBack 50 -> 33
  0053    | ResetInput
  0054    | Drop
  0055    | Swap
  0056    | Drop
  0057    | JumpIfFailure 57 -> 67
  0060    | GetConstant 6: peek
  0062    | GetBoundLocal 1
  0064    | CallFunction 1
  0066    | TakeLeft
  0067    | End
  ========================================
  
  =================@fn747=================
  array(elem)
  ========================================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: array
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  maybe_array(elem) = default(array(elem), [])
  ========================================
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn747
  0004    | CaptureLocal 0 0
  0007    | GetConstant 2: []
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn749=================
  array_sep(elem, sep)
  ========================================
  0000    | GetConstant 0: elem
  0002    | GetConstant 1: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 2: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn749
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: []
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 0: Elem
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 0: Elem
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 1: [_]
  0013    | GetBoundLocal 1
  0015    | InsertAtIndex 0
  0017    | End
  ========================================
  
  =================tuple2=================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 0: E1
  0010    | TakeRight 10 -> 32
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | Destructure 1: E2
  0019    | TakeRight 19 -> 32
  0022    | GetConstant 2: [_, _]
  0024    | GetBoundLocal 2
  0026    | InsertAtIndex 0
  0028    | GetBoundLocal 3
  0030    | InsertAtIndex 1
  0032    | End
  ========================================
  
  ===============tuple2_sep===============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
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
  0029    | GetConstant 2: [_, _]
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
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetConstant 2: E3
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
  0033    | GetConstant 3: [_, _, _]
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
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetConstant 2: E3
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
  0047    | GetConstant 3: [_, _, _]
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
  0000    | GetConstant 0: null
  0002    | GetBoundLocal 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 28
  0008    | Swap
  0009    | GetConstant 1: tuple1
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
  0000    | GetConstant 0: sep
  0002    | GetConstant 1: elem
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
  0000    | GetConstant 0: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | GetConstant 1: null
  0008    | GetBoundLocal 2
  0010    | GetConstant 2: -1
  0012    | Merge
  0013    | ValidateRepeatPattern
  0014    | JumpIfZero 14 -> 43
  0017    | Swap
  0018    | GetConstant 3: tuple1
  0020    | GetConstant 4: @fn756
  0022    | CaptureLocal 0 1
  0025    | CaptureLocal 1 0
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
  0000    | GetConstant 0: elem
  0002    | GetConstant 1: col_sep
  0004    | SetClosureCaptures
  0005    | GetConstant 2: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn758=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 0: row_sep
  0002    | GetConstant 1: elem
  0004    | GetConstant 2: col_sep
  0006    | SetClosureCaptures
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 22
  0014    | GetConstant 3: array_sep
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | CallTailFunction 2
  0022    | End
  ========================================
  
  =================@fn759=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 0: row_sep
  0002    | GetConstant 1: elem
  0004    | GetConstant 2: col_sep
  0006    | SetClosureCaptures
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 22
  0014    | GetConstant 3: array_sep
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
  0000    | GetConstant 0: tuple1
  0002    | GetConstant 1: @fn757
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CallFunction 1
  0012    | GetConstant 2: null
  0014    | GetConstant 3: 0
  0016    | ValidateRepeatPattern
  0017    | JumpIfZero 17 -> 48
  0020    | Swap
  0021    | GetConstant 4: tuple1
  0023    | GetConstant 5: @fn758
  0025    | CaptureLocal 0 1
  0028    | CaptureLocal 1 2
  0031    | CaptureLocal 2 0
  0034    | CallFunction 1
  0036    | Merge
  0037    | JumpIfFailure 37 -> 75
  0040    | Swap
  0041    | Decrement
  0042    | JumpIfZero 42 -> 48
  0045    | JumpBack 45 -> 20
  0048    | Swap
  0049    | SetInputMark
  0050    | GetConstant 6: tuple1
  0052    | GetConstant 7: @fn759
  0054    | CaptureLocal 0 1
  0057    | CaptureLocal 1 2
  0060    | CaptureLocal 2 0
  0063    | CallFunction 1
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
  
  =================@fn760=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | GetConstant 0: elem
  0002    | GetConstant 1: col_sep
  0004    | GetConstant 2: row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 3: _dimensions
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
  0000    | GetConstant 0: MaxRowLen
  0002    | GetConstant 1: _
  0004    | GetConstant 2: First
  0006    | GetConstant 3: peek
  0008    | GetConstant 4: @fn760
  0010    | CaptureLocal 0 0
  0013    | CaptureLocal 1 1
  0016    | CaptureLocal 2 2
  0019    | CallFunction 1
  0021    | Destructure 0: [MaxRowLen, _]
  0023    | TakeRight 23 -> 32
  0026    | GetBoundLocal 0
  0028    | CallFunction 0
  0030    | Destructure 1: First
  0032    | TakeRight 32 -> 59
  0035    | GetConstant 5: _rows_padded
  0037    | GetBoundLocal 0
  0039    | GetBoundLocal 1
  0041    | GetBoundLocal 2
  0043    | GetBoundLocal 3
  0045    | GetConstant 6: 1
  0047    | GetBoundLocal 4
  0049    | GetConstant 7: [_]
  0051    | GetBoundLocal 6
  0053    | InsertAtIndex 0
  0055    | GetConstant 8: []
  0057    | CallTailFunction 8
  0059    | End
  ========================================
  
  ==============_rows_padded==============
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    col_sep > elem -> Elem ?
    _rows_padded(elem, col_sep, row_sep, Pad, Num.Inc(RowLen), MaxRowLen, [...AccRow, Elem], AccRows) :
    row_sep > elem -> NextRow ?
    _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [NextRow], [...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)]) :
    const([...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)])
  ========================================
  0000    | GetConstant 0: Elem
  0002    | GetConstant 1: NextRow
  0004    | SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | Destructure 0: Elem
  0018    | ConditionalThen 18 -> 58
  0021    | GetConstant 2: _rows_padded
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | GetBoundLocal 2
  0029    | GetBoundLocal 3
  0031    | GetConstant 3: Num.Inc
  0033    | GetBoundLocal 4
  0035    | CallFunction 1
  0037    | GetBoundLocal 5
  0039    | GetConstant 4: []
  0041    | GetBoundLocal 6
  0043    | Merge
  0044    | GetConstant 5: [_]
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
  0075    | GetConstant 6: _rows_padded
  0077    | GetBoundLocal 0
  0079    | GetBoundLocal 1
  0081    | GetBoundLocal 2
  0083    | GetBoundLocal 3
  0085    | GetConstant 7: 1
  0087    | GetBoundLocal 5
  0089    | GetConstant 8: [_]
  0091    | GetBoundLocal 9
  0093    | InsertAtIndex 0
  0095    | GetConstant 9: []
  0097    | GetBoundLocal 7
  0099    | Merge
  0100    | GetConstant 10: [_]
  0102    | GetConstant 11: Array.AppendN
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
  0124    | GetConstant 12: const
  0126    | GetConstant 13: []
  0128    | GetBoundLocal 7
  0130    | Merge
  0131    | GetConstant 14: [_]
  0133    | GetConstant 15: Array.AppendN
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
  0007    | GetConstant 0: __dimensions
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 2
  0015    | GetConstant 1: 1
  0017    | GetConstant 2: 1
  0019    | GetConstant 3: 0
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
  0015    | GetConstant 0: __dimensions
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 2
  0023    | GetConstant 1: Num.Inc
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
  0053    | GetConstant 2: __dimensions
  0055    | GetBoundLocal 0
  0057    | GetBoundLocal 1
  0059    | GetBoundLocal 2
  0061    | GetConstant 3: 1
  0063    | GetConstant 4: Num.Inc
  0065    | GetBoundLocal 4
  0067    | CallFunction 1
  0069    | GetConstant 5: Num.Max
  0071    | GetBoundLocal 3
  0073    | GetBoundLocal 5
  0075    | CallFunction 2
  0077    | CallTailFunction 6
  0079    | Jump 79 -> 102
  0082    | GetConstant 6: const
  0084    | GetConstant 7: [_, _]
  0086    | GetConstant 8: Num.Max
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
  0000    | GetConstant 0: Rows
  0002    | GetConstant 1: rows
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | CallFunction 3
  0012    | Destructure 0: Rows
  0014    | TakeRight 14 -> 23
  0017    | GetConstant 2: Table.Transpose
  0019    | GetBoundLocal 3
  0021    | CallTailFunction 1
  0023    | End
  ========================================
  
  =============columns_padded=============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant 0: Rows
  0002    | GetConstant 1: rows_padded
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | GetBoundLocal 3
  0012    | CallFunction 4
  0014    | Destructure 0: Rows
  0016    | TakeRight 16 -> 25
  0019    | GetConstant 2: Table.Transpose
  0021    | GetBoundLocal 4
  0023    | CallTailFunction 1
  0025    | End
  ========================================
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 29
  0008    | Swap
  0009    | GetConstant 2: pair
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
  0031    | GetConstant 3: pair
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
  0000    | GetConstant 0: pair_sep
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | CallFunction 3
  0010    | GetConstant 1: null
  0012    | GetConstant 2: 0
  0014    | ValidateRepeatPattern
  0015    | JumpIfZero 15 -> 48
  0018    | Swap
  0019    | GetBoundLocal 3
  0021    | CallFunction 0
  0023    | TakeRight 23 -> 36
  0026    | GetConstant 3: pair_sep
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
  0057    | GetConstant 4: pair_sep
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
  0000    | GetConstant 0: key
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetConstant 2: pair
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn772=================
  pair(key, value)
  ========================================
  0000    | GetConstant 0: key
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetConstant 2: pair
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============object_until==============
  object_until(key, value, stop) =
    unless(pair(key, value), stop) * 1.. < peek(stop)
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 35
  0008    | Swap
  0009    | GetConstant 2: unless
  0011    | GetConstant 3: @fn771
  0013    | CaptureLocal 0 0
  0016    | CaptureLocal 1 1
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
  0037    | GetConstant 4: unless
  0039    | GetConstant 5: @fn772
  0041    | CaptureLocal 0 0
  0044    | CaptureLocal 1 1
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
  0066    | GetConstant 6: peek
  0068    | GetBoundLocal 2
  0070    | CallFunction 1
  0072    | TakeLeft
  0073    | End
  ========================================
  
  =================@fn773=================
  object(key, value)
  ========================================
  0000    | GetConstant 0: key
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetConstant 2: object
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  maybe_object(key, value) = default(object(key, value), {})
  ========================================
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn773
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: {}
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================@fn775=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | GetConstant 0: key
  0002    | GetConstant 1: pair_sep
  0004    | GetConstant 2: value
  0006    | GetConstant 3: sep
  0008    | SetClosureCaptures
  0009    | GetConstant 4: object_sep
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
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn775
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | CaptureLocal 3 3
  0016    | GetConstant 2: {}
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 30
  0013    | GetBoundLocal 1
  0015    | CallFunction 0
  0017    | Destructure 1: V
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 2: {_0_}
  0024    | GetBoundLocal 2
  0026    | GetBoundLocal 3
  0028    | InsertKeyVal 0
  0030    | End
  ========================================
  
  ================pair_sep================
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
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
  0029    | GetConstant 2: {_0_}
  0031    | GetBoundLocal 3
  0033    | GetBoundLocal 4
  0035    | InsertKeyVal 0
  0037    | End
  ========================================
  
  ================record1=================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | GetConstant 0: Value
  0002    | GetBoundLocal 1
  0004    | CallFunction 0
  0006    | Destructure 0: Value
  0008    | TakeRight 8 -> 19
  0011    | GetConstant 1: {_0_}
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
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
  0004    | GetBoundLocal 1
  0006    | CallFunction 0
  0008    | Destructure 0: V1
  0010    | TakeRight 10 -> 36
  0013    | GetBoundLocal 3
  0015    | CallFunction 0
  0017    | Destructure 1: V2
  0019    | TakeRight 19 -> 36
  0022    | GetConstant 2: {_0_, _1_}
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
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
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
  0029    | GetConstant 2: {_0_, _1_}
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
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
  0004    | GetConstant 2: V3
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
  0033    | GetConstant 3: {_0_, _1_, _2_}
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
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
  0004    | GetConstant 2: V3
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
  0047    | GetConstant 3: {_0_, _1_, _2_}
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
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 1
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
  0004    | GetConstant 0: null
  0006    | GetConstant 1: 0
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
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 1
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 29
  0008    | Swap
  0009    | GetConstant 2: unless
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
  0031    | GetConstant 3: unless
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
  0054    | GetConstant 4: peek
  0056    | GetBoundLocal 1
  0058    | CallFunction 1
  0060    | TakeLeft
  0061    | End
  ========================================
  
  ===============maybe_many===============
  maybe_many(p) = p * 0..
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 0
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
  0001    | GetConstant 0: many_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | Or 9 -> 16
  0012    | GetConstant 1: succeed
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ==================peek==================
  peek(p) = p -> V ! const(V)
  ========================================
  0000    | GetConstant 0: V
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | Destructure 0: V
  0009    | Backtrack 9 -> 18
  0012    | GetConstant 1: const
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
  0008    | GetConstant 0: succeed
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
  0008    | GetConstant 0: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 19
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  ==================skip==================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 0: null
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
  0008    | GetConstant 0: char
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 21
  0015    | GetConstant 1: find
  0017    | GetBoundLocal 0
  0019    | CallTailFunction 1
  0021    | End
  ========================================
  
  =================@fn784=================
  find(p)
  ========================================
  0000    | GetConstant 0: p
  0002    | SetClosureCaptures
  0003    | GetConstant 1: find
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn785=================
  many(char)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: char
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================find_all================
  find_all(p) = array(find(p)) < maybe(many(char))
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: @fn784
  0004    | CaptureLocal 0 0
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 19
  0012    | GetConstant 2: maybe
  0014    | GetConstant 3: @fn785
  0016    | CallFunction 1
  0018    | TakeLeft
  0019    | End
  ========================================
  
  ==============find_before===============
  find_before(p, stop) = stop ? @fail : p | (char > find_before(p, stop))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 1
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 0: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 38
  0015    | SetInputMark
  0016    | GetBoundLocal 0
  0018    | CallFunction 0
  0020    | Or 20 -> 38
  0023    | GetConstant 1: char
  0025    | CallFunction 0
  0027    | TakeRight 27 -> 38
  0030    | GetConstant 2: find_before
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallTailFunction 2
  0038    | End
  ========================================
  
  =================@fn786=================
  find_before(p, stop)
  ========================================
  0000    | GetConstant 0: p
  0002    | GetConstant 1: stop
  0004    | SetClosureCaptures
  0005    | GetConstant 2: find_before
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn787=================
  chars_until(stop)
  ========================================
  0000    | GetConstant 0: stop
  0002    | SetClosureCaptures
  0003    | GetConstant 1: chars_until
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ============find_all_before=============
  find_all_before(p, stop) = array(find_before(p, stop)) < maybe(chars_until(stop))
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: @fn786
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 25
  0015    | GetConstant 2: maybe
  0017    | GetConstant 3: @fn787
  0019    | CaptureLocal 1 0
  0022    | CallFunction 1
  0024    | TakeLeft
  0025    | End
  ========================================
  
  ================succeed=================
  succeed = const($null)
  ========================================
  0000    | GetConstant 0: const
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
  0008    | GetConstant 0: const
  0010    | GetBoundLocal 1
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 9
  0007    | GetBoundLocal 0
  0009    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | GetConstant 0: N
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
  0000    | GetConstant 0: ""
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
  0001    | GetConstant 0: char
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 1: @fail
  0010    | CallFunction 0
  0012    | Jump 12 -> 19
  0015    | GetConstant 2: succeed
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  =================@fn788=================
  maybe(whitespace)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  input(p) = surround(p, maybe(whitespace)) < end_of_input
  ========================================
  0000    | GetConstant 0: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: @fn788
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 16
  0011    | GetConstant 2: end_of_input
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
  0005    | GetConstant 0: maybe
  0007    | GetBoundLocal 1
  0009    | CallFunction 1
  0011    | Merge
  0012    | Or 12 -> 26
  0015    | GetConstant 1: maybe
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
  0001    | GetConstant 0: json.boolean
  0003    | CallFunction 0
  0005    | Or 5 -> 48
  0008    | SetInputMark
  0009    | GetConstant 1: json.null
  0011    | CallFunction 0
  0013    | Or 13 -> 48
  0016    | SetInputMark
  0017    | GetConstant 2: number
  0019    | CallFunction 0
  0021    | Or 21 -> 48
  0024    | SetInputMark
  0025    | GetConstant 3: json.string
  0027    | CallFunction 0
  0029    | Or 29 -> 48
  0032    | SetInputMark
  0033    | GetConstant 4: json.array
  0035    | GetConstant 5: json
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042    | GetConstant 6: json.object
  0044    | GetConstant 7: json
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  ==============json.boolean==============
  json.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 0: boolean
  0002    | GetConstant 1: "true"
  0004    | GetConstant 2: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============json.null================
  json.null = null("null")
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: "null"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============json.string===============
  json.string = '"' > _json.string_body < '"'
  ========================================
  0000    | GetConstant 0: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 1: _json.string_body
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetConstant 2: """
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =================@fn790=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | GetConstant 1: "\"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: """
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn789=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _escaped_ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 24
  0008    | SetInputMark
  0009    | GetConstant 1: _escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 24
  0016    | GetConstant 2: unless
  0018    | GetConstant 3: char
  0020    | GetConstant 4: @fn790
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
  0003    | GetConstant 1: @fn789
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 2: const
  0012    | GetConstant 3: ""
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ===============_ctrl_char===============
  _ctrl_char = "\u000000".."\u00001F"
  ========================================
  0000    | ParseFixedRange 0 1: _0 "\x1f" (esc)
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
  0001    | GetConstant 0: "\""
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | GetConstant 1: """
  0010    | Or 10 -> 100
  0013    | SetInputMark
  0014    | GetConstant 2: "\\"
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 23
  0021    | GetConstant 3: "\"
  0023    | Or 23 -> 100
  0026    | SetInputMark
  0027    | GetConstant 4: "\/"
  0029    | CallFunction 0
  0031    | TakeRight 31 -> 36
  0034    | GetConstant 5: "/"
  0036    | Or 36 -> 100
  0039    | SetInputMark
  0040    | GetConstant 6: "\b"
  0042    | CallFunction 0
  0044    | TakeRight 44 -> 49
  0047    | GetConstant 7: "\x08" (esc)
  0049    | Or 49 -> 100
  0052    | SetInputMark
  0053    | GetConstant 8: "\f"
  0055    | CallFunction 0
  0057    | TakeRight 57 -> 62
  0060    | GetConstant 9: "\x0c" (esc)
  0062    | Or 62 -> 100
  0065    | SetInputMark
  0066    | GetConstant 10: "\n"
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 75
  0073    | GetConstant 11: "
  "
  0075    | Or 75 -> 100
  0078    | SetInputMark
  0079    | GetConstant 12: "\r"
  0081    | CallFunction 0
  0083    | TakeRight 83 -> 88
  0086    | GetConstant 13: "\r (no-eol) (esc)
  "
  0088    | Or 88 -> 100
  0091    | GetConstant 14: "\t"
  0093    | CallFunction 0
  0095    | TakeRight 95 -> 100
  0098    | GetConstant 15: "\t" (esc)
  0100    | End
  ========================================
  
  ============_escaped_unicode============
  _escaped_unicode = _escaped_surrogate_pair | _escaped_codepoint
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _escaped_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _escaped_codepoint
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========_escaped_surrogate_pair=========
  _escaped_surrogate_pair = _valid_surrogate_pair | _invalid_surrogate_pair
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _valid_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _invalid_surrogate_pair
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_valid_surrogate_pair==========
  _valid_surrogate_pair =
    _high_surrogate -> H & _low_surrogate -> L $ @SurrogatePairCodepoint(H, L)
  ========================================
  0000    | GetConstant 0: H
  0002    | GetConstant 1: L
  0004    | GetConstant 2: _high_surrogate
  0006    | CallFunction 0
  0008    | Destructure 0: H
  0010    | TakeRight 10 -> 30
  0013    | GetConstant 3: _low_surrogate
  0015    | CallFunction 0
  0017    | Destructure 1: L
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 4: @SurrogatePairCodepoint
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ========_invalid_surrogate_pair=========
  _invalid_surrogate_pair = _low_surrogate | _high_surrogate $ "\u00FFFD"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _low_surrogate
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _high_surrogate
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 17
  0015    | GetConstant 2: "\xef\xbf\xbd" (esc)
  0017    | End
  ========================================
  
  ============_high_surrogate=============
  _high_surrogate =
    `\u` > ("D" | "d") + ("8" | "9" | "A" | "B" | "a" | "b") + hex_numeral + hex_numeral
  ========================================
  0000    | GetConstant 0: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | GetConstant 1: "D"
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | GetConstant 2: "d"
  0017    | CallFunction 0
  0019    | SetInputMark
  0020    | GetConstant 3: "8"
  0022    | CallFunction 0
  0024    | Or 24 -> 63
  0027    | SetInputMark
  0028    | GetConstant 4: "9"
  0030    | CallFunction 0
  0032    | Or 32 -> 63
  0035    | SetInputMark
  0036    | GetConstant 5: "A"
  0038    | CallFunction 0
  0040    | Or 40 -> 63
  0043    | SetInputMark
  0044    | GetConstant 6: "B"
  0046    | CallFunction 0
  0048    | Or 48 -> 63
  0051    | SetInputMark
  0052    | GetConstant 7: "a"
  0054    | CallFunction 0
  0056    | Or 56 -> 63
  0059    | GetConstant 8: "b"
  0061    | CallFunction 0
  0063    | Merge
  0064    | GetConstant 9: hex_numeral
  0066    | CallFunction 0
  0068    | Merge
  0069    | GetConstant 10: hex_numeral
  0071    | CallFunction 0
  0073    | Merge
  0074    | End
  ========================================
  
  =============_low_surrogate=============
  _low_surrogate =
    `\u` > ("D" | "d") + ("C".."F" | "c".."f") + hex_numeral + hex_numeral
  ========================================
  0000    | GetConstant 0: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | GetConstant 1: "D"
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | GetConstant 2: "d"
  0017    | CallFunction 0
  0019    | SetInputMark
  0020    | ParseFixedRange 3 4: "C" "F"
  0023    | Or 23 -> 29
  0026    | ParseFixedRange 5 6: "c" "f"
  0029    | Merge
  0030    | GetConstant 7: hex_numeral
  0032    | CallFunction 0
  0034    | Merge
  0035    | GetConstant 8: hex_numeral
  0037    | CallFunction 0
  0039    | Merge
  0040    | End
  ========================================
  
  ===========_escaped_codepoint===========
  _escaped_codepoint = `\u` > (hex_numeral * 4) -> U $ @Codepoint(U)
  ========================================
  0000    | GetConstant 0: U
  0002    | GetConstant 1: "\u"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 36
  0009    | GetConstant 2: null
  0011    | GetConstant 3: 4
  0013    | ValidateRepeatPattern
  0014    | JumpIfZero 14 -> 35
  0017    | Swap
  0018    | GetConstant 4: hex_numeral
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
  0041    | GetConstant 5: @Codepoint
  0043    | GetBoundLocal 0
  0045    | CallTailFunction 1
  0047    | End
  ========================================
  
  =================@fn792=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn791=================
  surround(elem, maybe(ws))
  ========================================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: @fn792
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===============json.array===============
  json.array(elem) = "[" > maybe_array_sep(surround(elem, maybe(ws)), ",") < "]"
  ========================================
  0000    | GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 18
  0007    | GetConstant 1: maybe_array_sep
  0009    | GetConstant 2: @fn791
  0011    | CaptureLocal 0 0
  0014    | GetConstant 3: ","
  0016    | CallFunction 2
  0018    | JumpIfFailure 18 -> 26
  0021    | GetConstant 4: "]"
  0023    | CallFunction 0
  0025    | TakeLeft
  0026    | End
  ========================================
  
  =================@fn794=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn793=================
  surround(json.string, maybe(ws))
  ========================================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: json.string
  0004    | GetConstant 2: @fn794
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn796=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn795=================
  surround(value, maybe(ws))
  ========================================
  0000    | GetConstant 0: value
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: @fn796
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
  0000    | GetConstant 0: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 22
  0007    | GetConstant 1: maybe_object_sep
  0009    | GetConstant 2: @fn793
  0011    | GetConstant 3: ":"
  0013    | GetConstant 4: @fn795
  0015    | CaptureLocal 0 0
  0018    | GetConstant 5: ","
  0020    | CallFunction 4
  0022    | JumpIfFailure 22 -> 30
  0025    | GetConstant 6: "}"
  0027    | CallFunction 0
  0029    | TakeLeft
  0030    | End
  ========================================
  
  ==============toml.simple===============
  toml.simple = toml.custom(toml.simple_value)
  ========================================
  0000    | GetConstant 0: toml.custom
  0002    | GetConstant 1: toml.simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============toml.tagged===============
  toml.tagged = toml.custom(toml.tagged_value)
  ========================================
  0000    | GetConstant 0: toml.custom
  0002    | GetConstant 1: toml.tagged_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn797=================
  _toml.comments + maybe(ws)
  ========================================
  0000    | GetConstant 0: _toml.comments
  0002    | CallFunction 0
  0004    | GetConstant 1: maybe
  0006    | GetConstant 2: whitespace
  0008    | CallFunction 1
  0010    | Merge
  0011    | End
  ========================================
  
  =================@fn798=================
  maybe(ws) + _toml.comments
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallFunction 1
  0006    | GetConstant 2: _toml.comments
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
  0000    | GetConstant 0: Doc
  0002    | GetConstant 1: maybe
  0004    | GetConstant 2: @fn797
  0006    | CallFunction 1
  0008    | TakeRight 8 -> 29
  0011    | SetInputMark
  0012    | GetConstant 3: _toml.with_root_table
  0014    | GetBoundLocal 0
  0016    | CallFunction 1
  0018    | Or 18 -> 27
  0021    | GetConstant 4: _toml.no_root_table
  0023    | GetBoundLocal 0
  0025    | CallFunction 1
  0027    | Destructure 0: Doc
  0029    | TakeRight 29 -> 47
  0032    | GetConstant 5: maybe
  0034    | GetConstant 6: @fn798
  0036    | CallFunction 1
  0038    | TakeRight 38 -> 47
  0041    | GetConstant 7: _Toml.Doc.Value
  0043    | GetBoundLocal 1
  0045    | CallTailFunction 1
  0047    | End
  ========================================
  
  =========_toml.with_root_table==========
  _toml.with_root_table(value) =
    _toml.root_table(value, _Toml.Doc.Empty) -> RootDoc &
    (_toml.ws > _toml.tables(value, RootDoc)) | const(RootDoc)
  ========================================
  0000    | GetConstant 0: RootDoc
  0002    | GetConstant 1: _toml.root_table
  0004    | GetBoundLocal 0
  0006    | GetConstant 2: _Toml.Doc.Empty
  0008    | CallFunction 0
  0010    | CallFunction 2
  0012    | Destructure 0: RootDoc
  0014    | TakeRight 14 -> 42
  0017    | SetInputMark
  0018    | GetConstant 3: _toml.ws
  0020    | CallFunction 0
  0022    | TakeRight 22 -> 33
  0025    | GetConstant 4: _toml.tables
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 1
  0031    | CallFunction 2
  0033    | Or 33 -> 42
  0036    | GetConstant 5: const
  0038    | GetBoundLocal 1
  0040    | CallTailFunction 1
  0042    | End
  ========================================
  
  ============_toml.root_table============
  _toml.root_table(value, Doc) =
    _toml.table_body(value, [], Doc)
  ========================================
  0000    | GetConstant 0: _toml.table_body
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | GetBoundLocal 1
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==========_toml.no_root_table===========
  _toml.no_root_table(value) =
    _toml.table(value, _Toml.Doc.Empty) | _toml.array_of_tables(value, _Toml.Doc.Empty) -> NewDoc &
    _toml.tables(value, NewDoc)
  ========================================
  0000    | GetConstant 0: NewDoc
  0002    | SetInputMark
  0003    | GetConstant 1: _toml.table
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: _Toml.Doc.Empty
  0009    | CallFunction 0
  0011    | CallFunction 2
  0013    | Or 13 -> 26
  0016    | GetConstant 3: _toml.array_of_tables
  0018    | GetBoundLocal 0
  0020    | GetConstant 4: _Toml.Doc.Empty
  0022    | CallFunction 0
  0024    | CallFunction 2
  0026    | Destructure 0: NewDoc
  0028    | TakeRight 28 -> 39
  0031    | GetConstant 5: _toml.tables
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
  0000    | GetConstant 0: NewDoc
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | GetConstant 1: _toml.ws
  0006    | CallFunction 0
  0008    | TakeRight 8 -> 19
  0011    | GetConstant 2: _toml.table
  0013    | GetBoundLocal 0
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | Or 19 -> 30
  0022    | GetConstant 3: _toml.array_of_tables
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | CallFunction 2
  0030    | Destructure 0: NewDoc
  0032    | ConditionalThen 32 -> 46
  0035    | GetConstant 4: _toml.tables
  0037    | GetBoundLocal 0
  0039    | GetBoundLocal 2
  0041    | CallTailFunction 2
  0043    | Jump 43 -> 52
  0046    | GetConstant 5: const
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
  0000    | GetConstant 0: HeaderPath
  0002    | GetConstant 1: _toml.table_header
  0004    | CallFunction 0
  0006    | Destructure 0: HeaderPath
  0008    | TakeRight 8 -> 15
  0011    | GetConstant 2: _toml.ws_newline
  0013    | CallFunction 0
  0015    | TakeRight 15 -> 44
  0018    | SetInputMark
  0019    | GetConstant 3: _toml.table_body
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 2
  0025    | GetBoundLocal 1
  0027    | CallFunction 3
  0029    | Or 29 -> 44
  0032    | GetConstant 4: const
  0034    | GetConstant 5: _Toml.Doc.EnsureTableAtPath
  0036    | GetBoundLocal 1
  0038    | GetBoundLocal 2
  0040    | CallFunction 2
  0042    | CallTailFunction 1
  0044    | End
  ========================================
  
  =================@fn800=================
  _toml.table_body(value, [], _Toml.Doc.Empty)
  ========================================
  0000    | GetConstant 0: value
  0002    | SetClosureCaptures
  0003    | GetConstant 1: _toml.table_body
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: []
  0009    | GetConstant 3: _Toml.Doc.Empty
  0011    | CallFunction 0
  0013    | CallTailFunction 3
  0015    | End
  ========================================
  
  =========_toml.array_of_tables==========
  _toml.array_of_tables(value, Doc) =
    _toml.array_of_tables_header -> HeaderPath & _toml.ws_newline &
    default(_toml.table_body(value, [], _Toml.Doc.Empty), _Toml.Doc.Empty) -> InnerDoc $
    _Toml.Doc.AppendAtPath(Doc, HeaderPath, _Toml.Doc.Value(InnerDoc))
  ========================================
  0000    | GetConstant 0: HeaderPath
  0002    | GetConstant 1: InnerDoc
  0004    | GetConstant 2: _toml.array_of_tables_header
  0006    | CallFunction 0
  0008    | Destructure 0: HeaderPath
  0010    | TakeRight 10 -> 17
  0013    | GetConstant 3: _toml.ws_newline
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 52
  0020    | GetConstant 4: default
  0022    | GetConstant 5: @fn800
  0024    | CaptureLocal 0 0
  0027    | GetConstant 6: _Toml.Doc.Empty
  0029    | CallFunction 0
  0031    | CallFunction 2
  0033    | Destructure 1: InnerDoc
  0035    | TakeRight 35 -> 52
  0038    | GetConstant 7: _Toml.Doc.AppendAtPath
  0040    | GetBoundLocal 1
  0042    | GetBoundLocal 2
  0044    | GetConstant 8: _Toml.Doc.Value
  0046    | GetBoundLocal 3
  0048    | CallFunction 1
  0050    | CallTailFunction 3
  0052    | End
  ========================================
  
  =================@fn802=================
  ws | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: whitespace
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _toml.comment
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ================_toml.ws================
  _toml.ws = maybe_many(ws | _toml.comment)
  ========================================
  0000    | GetConstant 0: maybe_many
  0002    | GetConstant 1: @fn802
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn803=================
  spaces | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: spaces
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _toml.comment
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =============_toml.ws_line==============
  _toml.ws_line = maybe_many(spaces | _toml.comment)
  ========================================
  0000    | GetConstant 0: maybe_many
  0002    | GetConstant 1: @fn803
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ============_toml.ws_newline============
  _toml.ws_newline = _toml.ws_line + (nl | end) + _toml.ws
  ========================================
  0000    | GetConstant 0: _toml.ws_line
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | GetConstant 1: newline
  0007    | CallFunction 0
  0009    | Or 9 -> 16
  0012    | GetConstant 2: end_of_input
  0014    | CallFunction 0
  0016    | Merge
  0017    | GetConstant 3: _toml.ws
  0019    | CallFunction 0
  0021    | Merge
  0022    | End
  ========================================
  
  =============_toml.comments=============
  _toml.comments = many_sep(_toml.comment, ws)
  ========================================
  0000    | GetConstant 0: many_sep
  0002    | GetConstant 1: _toml.comment
  0004    | GetConstant 2: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn804=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========_toml.table_header===========
  _toml.table_header = "[" > surround(_toml.path, maybe(ws)) < "]"
  ========================================
  0000    | GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: surround
  0009    | GetConstant 2: _toml.path
  0011    | GetConstant 3: @fn804
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 4: "]"
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
  ========================================
  
  =================@fn805=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ======_toml.array_of_tables_header======
  _toml.array_of_tables_header =
    "[[" > surround(_toml.path, maybe(ws)) < "]]"
  ========================================
  0000    | GetConstant 0: "[["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: surround
  0009    | GetConstant 2: _toml.path
  0011    | GetConstant 3: @fn805
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 4: "]]"
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
  0000    | GetConstant 0: KeyPath
  0002    | GetConstant 1: Val
  0004    | GetConstant 2: NewDoc
  0006    | GetConstant 3: _toml.table_pair
  0008    | GetBoundLocal 0
  0010    | CallFunction 1
  0012    | Destructure 0: [KeyPath, Val]
  0014    | TakeRight 14 -> 21
  0017    | GetConstant 4: _toml.ws_newline
  0019    | CallFunction 0
  0021    | TakeRight 21 -> 43
  0024    | GetConstant 5: const
  0026    | GetConstant 6: _Toml.Doc.InsertAtPath
  0028    | GetBoundLocal 2
  0030    | GetBoundLocal 1
  0032    | GetBoundLocal 3
  0034    | Merge
  0035    | GetBoundLocal 4
  0037    | CallFunction 3
  0039    | CallFunction 1
  0041    | Destructure 1: NewDoc
  0043    | TakeRight 43 -> 66
  0046    | SetInputMark
  0047    | GetConstant 7: _toml.table_body
  0049    | GetBoundLocal 0
  0051    | GetBoundLocal 1
  0053    | GetBoundLocal 5
  0055    | CallFunction 3
  0057    | Or 57 -> 66
  0060    | GetConstant 8: const
  0062    | GetBoundLocal 5
  0064    | CallTailFunction 1
  0066    | End
  ========================================
  
  =================@fn807=================
  maybe(spaces)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: spaces
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn806=================
  surround("=", maybe(spaces))
  ========================================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: "="
  0004    | GetConstant 2: @fn807
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_toml.table_pair============
  _toml.table_pair(value) =
    tuple2_sep(_toml.path, surround("=", maybe(spaces)), value)
  ========================================
  0000    | GetConstant 0: tuple2_sep
  0002    | GetConstant 1: _toml.path
  0004    | GetConstant 2: @fn806
  0006    | GetBoundLocal 0
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =================@fn809=================
  maybe(ws)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn808=================
  surround(".", maybe(ws))
  ========================================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: "."
  0004    | GetConstant 2: @fn809
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============_toml.path===============
  _toml.path = array_sep(_toml.key, surround(".", maybe(ws)))
  ========================================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: _toml.key
  0004    | GetConstant 2: @fn808
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn810=================
  alpha | numeral | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: alpha
  0003    | CallFunction 0
  0005    | Or 5 -> 28
  0008    | SetInputMark
  0009    | GetConstant 1: numeral
  0011    | CallFunction 0
  0013    | Or 13 -> 28
  0016    | SetInputMark
  0017    | GetConstant 2: "_"
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 3: "-"
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
  0003    | GetConstant 1: @fn810
  0005    | CallFunction 1
  0007    | Or 7 -> 22
  0010    | SetInputMark
  0011    | GetConstant 2: toml.string.basic
  0013    | CallFunction 0
  0015    | Or 15 -> 22
  0018    | GetConstant 3: toml.string.literal
  0020    | CallFunction 0
  0022    | End
  ========================================
  
  =============_toml.comment==============
  _toml.comment = "#" > maybe(line)
  ========================================
  0000    | GetConstant 0: "#"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: line
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
  0001    | GetConstant 0: toml.string
  0003    | CallFunction 0
  0005    | Or 5 -> 48
  0008    | SetInputMark
  0009    | GetConstant 1: toml.datetime
  0011    | CallFunction 0
  0013    | Or 13 -> 48
  0016    | SetInputMark
  0017    | GetConstant 2: toml.number
  0019    | CallFunction 0
  0021    | Or 21 -> 48
  0024    | SetInputMark
  0025    | GetConstant 3: toml.boolean
  0027    | CallFunction 0
  0029    | Or 29 -> 48
  0032    | SetInputMark
  0033    | GetConstant 4: toml.array
  0035    | GetConstant 5: toml.simple_value
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042    | GetConstant 6: toml.inline_table
  0044    | GetConstant 7: toml.simple_value
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
  0001    | GetConstant 0: toml.string
  0003    | CallFunction 0
  0005    | Or 5 -> 156
  0008    | SetInputMark
  0009    | GetConstant 1: _toml.tag
  0011    | GetConstant 2: "datetime"
  0013    | GetConstant 3: "offset"
  0015    | GetConstant 4: toml.datetime.offset
  0017    | CallFunction 3
  0019    | Or 19 -> 156
  0022    | SetInputMark
  0023    | GetConstant 5: _toml.tag
  0025    | GetConstant 6: "datetime"
  0027    | GetConstant 7: "local"
  0029    | GetConstant 8: toml.datetime.local
  0031    | CallFunction 3
  0033    | Or 33 -> 156
  0036    | SetInputMark
  0037    | GetConstant 9: _toml.tag
  0039    | GetConstant 10: "datetime"
  0041    | GetConstant 11: "date-local"
  0043    | GetConstant 12: toml.datetime.local_date
  0045    | CallFunction 3
  0047    | Or 47 -> 156
  0050    | SetInputMark
  0051    | GetConstant 13: _toml.tag
  0053    | GetConstant 14: "datetime"
  0055    | GetConstant 15: "time-local"
  0057    | GetConstant 16: toml.datetime.local_time
  0059    | CallFunction 3
  0061    | Or 61 -> 156
  0064    | SetInputMark
  0065    | GetConstant 17: toml.number.binary_integer
  0067    | CallFunction 0
  0069    | Or 69 -> 156
  0072    | SetInputMark
  0073    | GetConstant 18: toml.number.octal_integer
  0075    | CallFunction 0
  0077    | Or 77 -> 156
  0080    | SetInputMark
  0081    | GetConstant 19: toml.number.hex_integer
  0083    | CallFunction 0
  0085    | Or 85 -> 156
  0088    | SetInputMark
  0089    | GetConstant 20: _toml.tag
  0091    | GetConstant 21: "float"
  0093    | GetConstant 22: "infinity"
  0095    | GetConstant 23: toml.number.infinity
  0097    | CallFunction 3
  0099    | Or 99 -> 156
  0102    | SetInputMark
  0103    | GetConstant 24: _toml.tag
  0105    | GetConstant 25: "float"
  0107    | GetConstant 26: "not-a-number"
  0109    | GetConstant 27: toml.number.not_a_number
  0111    | CallFunction 3
  0113    | Or 113 -> 156
  0116    | SetInputMark
  0117    | GetConstant 28: toml.number.float
  0119    | CallFunction 0
  0121    | Or 121 -> 156
  0124    | SetInputMark
  0125    | GetConstant 29: toml.number.integer
  0127    | CallFunction 0
  0129    | Or 129 -> 156
  0132    | SetInputMark
  0133    | GetConstant 30: toml.boolean
  0135    | CallFunction 0
  0137    | Or 137 -> 156
  0140    | SetInputMark
  0141    | GetConstant 31: toml.array
  0143    | GetConstant 32: toml.tagged_value
  0145    | CallFunction 1
  0147    | Or 147 -> 156
  0150    | GetConstant 33: toml.inline_table
  0152    | GetConstant 34: toml.tagged_value
  0154    | CallTailFunction 1
  0156    | End
  ========================================
  
  ===============_toml.tag================
  _toml.tag(Type, Subtype, value) =
    value -> Value $ {"type": Type, "subtype": Subtype, "value": Value}
  ========================================
  0000    | GetConstant 0: Value
  0002    | GetBoundLocal 2
  0004    | CallFunction 0
  0006    | Destructure 0: Value
  0008    | TakeRight 8 -> 25
  0011    | GetConstant 1: {}
  0013    | GetBoundLocal 0
  0015    | InsertAtKey 2: "type"
  0017    | GetBoundLocal 1
  0019    | InsertAtKey 3: "subtype"
  0021    | GetBoundLocal 3
  0023    | InsertAtKey 4: "value"
  0025    | End
  ========================================
  
  ==============toml.string===============
  toml.string =
    toml.string.multi_line_basic |
    toml.string.multi_line_literal |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: toml.string.multi_line_basic
  0003    | CallFunction 0
  0005    | Or 5 -> 28
  0008    | SetInputMark
  0009    | GetConstant 1: toml.string.multi_line_literal
  0011    | CallFunction 0
  0013    | Or 13 -> 28
  0016    | SetInputMark
  0017    | GetConstant 2: toml.string.basic
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 3: toml.string.literal
  0026    | CallFunction 0
  0028    | End
  ========================================
  
  =============toml.datetime==============
  toml.datetime =
    toml.datetime.offset |
    toml.datetime.local |
    toml.datetime.local_date |
    toml.datetime.local_time
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: toml.datetime.offset
  0003    | CallFunction 0
  0005    | Or 5 -> 28
  0008    | SetInputMark
  0009    | GetConstant 1: toml.datetime.local
  0011    | CallFunction 0
  0013    | Or 13 -> 28
  0016    | SetInputMark
  0017    | GetConstant 2: toml.datetime.local_date
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 3: toml.datetime.local_time
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
  0001    | GetConstant 0: toml.number.binary_integer
  0003    | CallFunction 0
  0005    | Or 5 -> 52
  0008    | SetInputMark
  0009    | GetConstant 1: toml.number.octal_integer
  0011    | CallFunction 0
  0013    | Or 13 -> 52
  0016    | SetInputMark
  0017    | GetConstant 2: toml.number.hex_integer
  0019    | CallFunction 0
  0021    | Or 21 -> 52
  0024    | SetInputMark
  0025    | GetConstant 3: toml.number.infinity
  0027    | CallFunction 0
  0029    | Or 29 -> 52
  0032    | SetInputMark
  0033    | GetConstant 4: toml.number.not_a_number
  0035    | CallFunction 0
  0037    | Or 37 -> 52
  0040    | SetInputMark
  0041    | GetConstant 5: toml.number.float
  0043    | CallFunction 0
  0045    | Or 45 -> 52
  0048    | GetConstant 6: toml.number.integer
  0050    | CallFunction 0
  0052    | End
  ========================================
  
  ==============toml.boolean==============
  toml.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 0: boolean
  0002    | GetConstant 1: "true"
  0004    | GetConstant 2: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn813=================
  surround(elem, _toml.ws)
  ========================================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: _toml.ws
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn814=================
  surround(",", _toml.ws)
  ========================================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: ","
  0004    | GetConstant 2: _toml.ws
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn812=================
  array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws))
  ========================================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: array_sep
  0005    | GetConstant 2: @fn813
  0007    | CaptureLocal 0 0
  0010    | GetConstant 3: ","
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 24
  0017    | GetConstant 4: maybe
  0019    | GetConstant 5: @fn814
  0021    | CallFunction 1
  0023    | TakeLeft
  0024    | End
  ========================================
  
  ===============toml.array===============
  toml.array(elem) =
    "[" > _toml.ws > default(
      array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws)),
      []
    ) < _toml.ws < "]"
  ========================================
  0000    | GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 1: _toml.ws
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 25
  0014    | GetConstant 2: default
  0016    | GetConstant 3: @fn812
  0018    | CaptureLocal 0 0
  0021    | GetConstant 4: []
  0023    | CallFunction 2
  0025    | JumpIfFailure 25 -> 33
  0028    | GetConstant 5: _toml.ws
  0030    | CallFunction 0
  0032    | TakeLeft
  0033    | JumpIfFailure 33 -> 41
  0036    | GetConstant 6: "]"
  0038    | CallFunction 0
  0040    | TakeLeft
  0041    | End
  ========================================
  
  ===========toml.inline_table============
  toml.inline_table(value) =
    _toml.empty_inline_table | _toml.nonempty_inline_table(value) -> InlineDoc $
    _Toml.Doc.Value(InlineDoc)
  ========================================
  0000    | GetConstant 0: InlineDoc
  0002    | SetInputMark
  0003    | GetConstant 1: _toml.empty_inline_table
  0005    | CallFunction 0
  0007    | Or 7 -> 16
  0010    | GetConstant 2: _toml.nonempty_inline_table
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | Destructure 0: InlineDoc
  0018    | TakeRight 18 -> 27
  0021    | GetConstant 3: _Toml.Doc.Value
  0023    | GetBoundLocal 1
  0025    | CallTailFunction 1
  0027    | End
  ========================================
  
  ========_toml.empty_inline_table========
  _toml.empty_inline_table = "{" > maybe(spaces) < "}" $ _Toml.Doc.Empty
  ========================================
  0000    | GetConstant 0: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: spaces
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 21
  0016    | GetConstant 3: "}"
  0018    | CallFunction 0
  0020    | TakeLeft
  0021    | TakeRight 21 -> 28
  0024    | GetConstant 4: _Toml.Doc.Empty
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
  0000    | GetConstant 0: DocWithFirstPair
  0002    | GetConstant 1: "{"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 15
  0009    | GetConstant 2: maybe
  0011    | GetConstant 3: spaces
  0013    | CallFunction 1
  0015    | TakeRight 15 -> 28
  0018    | GetConstant 4: _toml.inline_table_pair
  0020    | GetBoundLocal 0
  0022    | GetConstant 5: _Toml.Doc.Empty
  0024    | CallFunction 0
  0026    | CallFunction 2
  0028    | Destructure 0: DocWithFirstPair
  0030    | TakeRight 30 -> 59
  0033    | GetConstant 6: _toml.inline_table_body
  0035    | GetBoundLocal 0
  0037    | GetBoundLocal 1
  0039    | CallFunction 2
  0041    | JumpIfFailure 41 -> 51
  0044    | GetConstant 7: maybe
  0046    | GetConstant 8: spaces
  0048    | CallFunction 1
  0050    | TakeLeft
  0051    | JumpIfFailure 51 -> 59
  0054    | GetConstant 9: "}"
  0056    | CallFunction 0
  0058    | TakeLeft
  0059    | End
  ========================================
  
  ========_toml.inline_table_body=========
  _toml.inline_table_body(value, Doc) =
    "," > _toml.inline_table_pair(value, Doc) -> NewDoc ?
    _toml.inline_table_body(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant 0: NewDoc
  0002    | SetInputMark
  0003    | GetConstant 1: ","
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 2: _toml.inline_table_pair
  0012    | GetBoundLocal 0
  0014    | GetBoundLocal 1
  0016    | CallFunction 2
  0018    | Destructure 0: NewDoc
  0020    | ConditionalThen 20 -> 34
  0023    | GetConstant 3: _toml.inline_table_body
  0025    | GetBoundLocal 0
  0027    | GetBoundLocal 2
  0029    | CallTailFunction 2
  0031    | Jump 31 -> 40
  0034    | GetConstant 4: const
  0036    | GetBoundLocal 1
  0038    | CallTailFunction 1
  0040    | End
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
  0000    | GetConstant 0: Key
  0002    | GetConstant 1: Val
  0004    | GetConstant 2: maybe
  0006    | GetConstant 3: spaces
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 4: _toml.path
  0015    | CallFunction 0
  0017    | Destructure 0: Key
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 5: maybe
  0024    | GetConstant 6: spaces
  0026    | CallFunction 1
  0028    | TakeRight 28 -> 35
  0031    | GetConstant 7: "="
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 44
  0038    | GetConstant 8: maybe
  0040    | GetConstant 9: spaces
  0042    | CallFunction 1
  0044    | TakeRight 44 -> 53
  0047    | GetBoundLocal 0
  0049    | CallFunction 0
  0051    | Destructure 1: Val
  0053    | TakeRight 53 -> 75
  0056    | GetConstant 10: maybe
  0058    | GetConstant 11: spaces
  0060    | CallFunction 1
  0062    | TakeRight 62 -> 75
  0065    | GetConstant 12: _Toml.Doc.InsertAtPath
  0067    | GetBoundLocal 1
  0069    | GetBoundLocal 2
  0071    | GetBoundLocal 3
  0073    | CallTailFunction 3
  0075    | End
  ========================================
  
  =================@fn816=================
  maybe(nl)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn819=================
  _ctrl_char | `\`
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "\"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================@fn818=================
  _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _toml.escaped_ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 52
  0008    | SetInputMark
  0009    | GetConstant 1: _toml.escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 52
  0016    | SetInputMark
  0017    | GetConstant 2: whitespace
  0019    | CallFunction 0
  0021    | Or 21 -> 52
  0024    | SetInputMark
  0025    | GetConstant 3: "\"
  0027    | CallFunction 0
  0029    | GetConstant 4: whitespace
  0031    | CallFunction 0
  0033    | Merge
  0034    | TakeRight 34 -> 41
  0037    | GetConstant 5: ""
  0039    | CallFunction 0
  0041    | Or 41 -> 52
  0044    | GetConstant 6: unless
  0046    | GetConstant 7: char
  0048    | GetConstant 8: @fn819
  0050    | CallTailFunction 2
  0052    | End
  ========================================
  
  =================@fn817=================
  many_until(
        _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`),
        `"""`
      )
  ========================================
  0000    | GetConstant 0: many_until
  0002    | GetConstant 1: @fn818
  0004    | GetConstant 2: """""
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
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: """""
  0004    | CallFunction 1
  0006    | GetConstant 2: skip
  0008    | GetConstant 3: @fn816
  0010    | CallFunction 1
  0012    | Merge
  0013    | GetConstant 4: default
  0015    | GetConstant 5: @fn817
  0017    | GetConstant 6: ""
  0019    | CallFunction 2
  0021    | Merge
  0022    | GetConstant 7: skip
  0024    | GetConstant 8: """""
  0026    | CallFunction 1
  0028    | Merge
  0029    | GetConstant 9: null
  0031    | GetConstant 10: 0
  0033    | ValidateRepeatPattern
  0034    | JumpIfZero 34 -> 54
  0037    | Swap
  0038    | GetConstant 11: """
  0040    | CallFunction 0
  0042    | Merge
  0043    | JumpIfFailure 43 -> 86
  0046    | Swap
  0047    | Decrement
  0048    | JumpIfZero 48 -> 54
  0051    | JumpBack 51 -> 37
  0054    | Drop
  0055    | GetConstant 12: 2
  0057    | GetConstant 13: 0
  0059    | NegateNumber
  0060    | Merge
  0061    | ValidateRepeatPattern
  0062    | JumpIfZero 62 -> 87
  0065    | Swap
  0066    | SetInputMark
  0067    | GetConstant 14: """
  0069    | CallFunction 0
  0071    | JumpIfFailure 71 -> 84
  0074    | PopInputMark
  0075    | Merge
  0076    | Swap
  0077    | Decrement
  0078    | JumpIfZero 78 -> 87
  0081    | JumpBack 81 -> 65
  0084    | ResetInput
  0085    | Drop
  0086    | Swap
  0087    | Drop
  0088    | Merge
  0089    | End
  ========================================
  
  =================@fn820=================
  maybe(nl)
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn821=================
  many_until(char, `'''`)
  ========================================
  0000    | GetConstant 0: many_until
  0002    | GetConstant 1: char
  0004    | GetConstant 2: "'''"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =====toml.string.multi_line_literal=====
  toml.string.multi_line_literal =
    skip(`'''`) + skip(maybe(nl)) +
    default(many_until(char, `'''`), $"")
    + skip(`'''`) + (`'` * 0..2)
  ========================================
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: "'''"
  0004    | CallFunction 1
  0006    | GetConstant 2: skip
  0008    | GetConstant 3: @fn820
  0010    | CallFunction 1
  0012    | Merge
  0013    | GetConstant 4: default
  0015    | GetConstant 5: @fn821
  0017    | GetConstant 6: ""
  0019    | CallFunction 2
  0021    | Merge
  0022    | GetConstant 7: skip
  0024    | GetConstant 8: "'''"
  0026    | CallFunction 1
  0028    | Merge
  0029    | GetConstant 9: null
  0031    | GetConstant 10: 0
  0033    | ValidateRepeatPattern
  0034    | JumpIfZero 34 -> 54
  0037    | Swap
  0038    | GetConstant 11: "'"
  0040    | CallFunction 0
  0042    | Merge
  0043    | JumpIfFailure 43 -> 86
  0046    | Swap
  0047    | Decrement
  0048    | JumpIfZero 48 -> 54
  0051    | JumpBack 51 -> 37
  0054    | Drop
  0055    | GetConstant 12: 2
  0057    | GetConstant 13: 0
  0059    | NegateNumber
  0060    | Merge
  0061    | ValidateRepeatPattern
  0062    | JumpIfZero 62 -> 87
  0065    | Swap
  0066    | SetInputMark
  0067    | GetConstant 14: "'"
  0069    | CallFunction 0
  0071    | JumpIfFailure 71 -> 84
  0074    | PopInputMark
  0075    | Merge
  0076    | Swap
  0077    | Decrement
  0078    | JumpIfZero 78 -> 87
  0081    | JumpBack 81 -> 65
  0084    | ResetInput
  0085    | Drop
  0086    | Swap
  0087    | Drop
  0088    | Merge
  0089    | End
  ========================================
  
  ===========toml.string.basic============
  toml.string.basic = '"' > _toml.string.basic_body < '"'
  ========================================
  0000    | GetConstant 0: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 1: _toml.string.basic_body
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetConstant 2: """
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =================@fn823=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 20
  0008    | SetInputMark
  0009    | GetConstant 1: "\"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: """
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn822=================
  _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _toml.escaped_ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 24
  0008    | SetInputMark
  0009    | GetConstant 1: _toml.escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 24
  0016    | GetConstant 2: unless
  0018    | GetConstant 3: char
  0020    | GetConstant 4: @fn823
  0022    | CallTailFunction 2
  0024    | End
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
  0003    | GetConstant 1: @fn822
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 2: const
  0012    | GetConstant 3: ""
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  =================@fn824=================
  chars_until("'")
  ========================================
  0000    | GetConstant 0: chars_until
  0002    | GetConstant 1: "'"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========toml.string.literal===========
  toml.string.literal = "'" > default(chars_until("'"), $"") < "'"
  ========================================
  0000    | GetConstant 0: "'"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: default
  0009    | GetConstant 2: @fn824
  0011    | GetConstant 3: ""
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 4: "'"
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
  0001    | GetConstant 0: "\""
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | GetConstant 1: """
  0010    | Or 10 -> 87
  0013    | SetInputMark
  0014    | GetConstant 2: "\\"
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 23
  0021    | GetConstant 3: "\"
  0023    | Or 23 -> 87
  0026    | SetInputMark
  0027    | GetConstant 4: "\b"
  0029    | CallFunction 0
  0031    | TakeRight 31 -> 36
  0034    | GetConstant 5: "\x08" (esc)
  0036    | Or 36 -> 87
  0039    | SetInputMark
  0040    | GetConstant 6: "\f"
  0042    | CallFunction 0
  0044    | TakeRight 44 -> 49
  0047    | GetConstant 7: "\x0c" (esc)
  0049    | Or 49 -> 87
  0052    | SetInputMark
  0053    | GetConstant 8: "\n"
  0055    | CallFunction 0
  0057    | TakeRight 57 -> 62
  0060    | GetConstant 9: "
  "
  0062    | Or 62 -> 87
  0065    | SetInputMark
  0066    | GetConstant 10: "\r"
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 75
  0073    | GetConstant 11: "\r (no-eol) (esc)
  "
  0075    | Or 75 -> 87
  0078    | GetConstant 12: "\t"
  0080    | CallFunction 0
  0082    | TakeRight 82 -> 87
  0085    | GetConstant 13: "\t" (esc)
  0087    | End
  ========================================
  
  =========_toml.escaped_unicode==========
  _toml.escaped_unicode =
    (`\u` > (hex_numeral * 4) -> U $ @Codepoint(U)) |
    (`\U` > (hex_numeral * 8) -> U $ @Codepoint(U))
  ========================================
  0000    | GetConstant 0: U
  0002    | SetInputMark
  0003    | GetConstant 1: "\u"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 37
  0010    | GetConstant 2: null
  0012    | GetConstant 3: 4
  0014    | ValidateRepeatPattern
  0015    | JumpIfZero 15 -> 36
  0018    | Swap
  0019    | GetConstant 4: hex_numeral
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
  0042    | GetConstant 5: @Codepoint
  0044    | GetBoundLocal 0
  0046    | CallTailFunction 1
  0048    | Or 48 -> 96
  0051    | GetConstant 6: "\U"
  0053    | CallFunction 0
  0055    | TakeRight 55 -> 85
  0058    | GetConstant 7: null
  0060    | GetConstant 8: 8
  0062    | ValidateRepeatPattern
  0063    | JumpIfZero 63 -> 84
  0066    | Swap
  0067    | GetConstant 9: hex_numeral
  0069    | CallFunction 0
  0071    | Merge
  0072    | JumpIfFailure 72 -> 83
  0075    | Swap
  0076    | Decrement
  0077    | JumpIfZero 77 -> 84
  0080    | JumpBack 80 -> 66
  0083    | Swap
  0084    | Drop
  0085    | Destructure 1: U
  0087    | TakeRight 87 -> 96
  0090    | GetConstant 10: @Codepoint
  0092    | GetBoundLocal 0
  0094    | CallTailFunction 1
  0096    | End
  ========================================
  
  ==========toml.datetime.offset==========
  toml.datetime.offset = toml.datetime.local_date + ("T" | "t" | " ") + _toml.datetime.time_offset
  ========================================
  0000    | GetConstant 0: toml.datetime.local_date
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | GetConstant 1: "T"
  0007    | CallFunction 0
  0009    | Or 9 -> 24
  0012    | SetInputMark
  0013    | GetConstant 2: "t"
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | GetConstant 3: " "
  0022    | CallFunction 0
  0024    | Merge
  0025    | GetConstant 4: _toml.datetime.time_offset
  0027    | CallFunction 0
  0029    | Merge
  0030    | End
  ========================================
  
  ==========toml.datetime.local===========
  toml.datetime.local = toml.datetime.local_date + ("T" | "t" | " ") + toml.datetime.local_time
  ========================================
  0000    | GetConstant 0: toml.datetime.local_date
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | GetConstant 1: "T"
  0007    | CallFunction 0
  0009    | Or 9 -> 24
  0012    | SetInputMark
  0013    | GetConstant 2: "t"
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | GetConstant 3: " "
  0022    | CallFunction 0
  0024    | Merge
  0025    | GetConstant 4: toml.datetime.local_time
  0027    | CallFunction 0
  0029    | Merge
  0030    | End
  ========================================
  
  ========toml.datetime.local_date========
  toml.datetime.local_date =
    _toml.datetime.year + "-" + _toml.datetime.month + "-" + _toml.datetime.mday
  ========================================
  0000    | GetConstant 0: _toml.datetime.year
  0002    | CallFunction 0
  0004    | GetConstant 1: "-"
  0006    | CallFunction 0
  0008    | Merge
  0009    | GetConstant 2: _toml.datetime.month
  0011    | CallFunction 0
  0013    | Merge
  0014    | GetConstant 3: "-"
  0016    | CallFunction 0
  0018    | Merge
  0019    | GetConstant 4: _toml.datetime.mday
  0021    | CallFunction 0
  0023    | Merge
  0024    | End
  ========================================
  
  ==========_toml.datetime.year===========
  _toml.datetime.year = numeral * 4
  ========================================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: 4
  0004    | ValidateRepeatPattern
  0005    | JumpIfZero 5 -> 26
  0008    | Swap
  0009    | GetConstant 2: numeral
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
  0001    | GetConstant 0: "0"
  0003    | CallFunction 0
  0005    | ParseFixedRange 1 2: "1" "9"
  0008    | Merge
  0009    | Or 9 -> 24
  0012    | SetInputMark
  0013    | GetConstant 3: "11"
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | GetConstant 4: "12"
  0022    | CallFunction 0
  0024    | End
  ========================================
  
  ==========_toml.datetime.mday===========
  _toml.datetime.mday = ("0".."2" + "1".."9") | "30" | "31"
  ========================================
  0000    | SetInputMark
  0001    | ParseFixedRange 0 1: "0" "2"
  0004    | ParseFixedRange 2 3: "1" "9"
  0007    | Merge
  0008    | Or 8 -> 23
  0011    | SetInputMark
  0012    | GetConstant 4: "30"
  0014    | CallFunction 0
  0016    | Or 16 -> 23
  0019    | GetConstant 5: "31"
  0021    | CallFunction 0
  0023    | End
  ========================================
  
  =================@fn825=================
  "." + (numeral * 1..9)
  ========================================
  0000    | GetConstant 0: "."
  0002    | CallFunction 0
  0004    | GetConstant 1: null
  0006    | GetConstant 2: 1
  0008    | ValidateRepeatPattern
  0009    | JumpIfZero 9 -> 29
  0012    | Swap
  0013    | GetConstant 3: numeral
  0015    | CallFunction 0
  0017    | Merge
  0018    | JumpIfFailure 18 -> 61
  0021    | Swap
  0022    | Decrement
  0023    | JumpIfZero 23 -> 29
  0026    | JumpBack 26 -> 12
  0029    | Drop
  0030    | GetConstant 4: 9
  0032    | GetConstant 5: 1
  0034    | NegateNumber
  0035    | Merge
  0036    | ValidateRepeatPattern
  0037    | JumpIfZero 37 -> 62
  0040    | Swap
  0041    | SetInputMark
  0042    | GetConstant 6: numeral
  0044    | CallFunction 0
  0046    | JumpIfFailure 46 -> 59
  0049    | PopInputMark
  0050    | Merge
  0051    | Swap
  0052    | Decrement
  0053    | JumpIfZero 53 -> 62
  0056    | JumpBack 56 -> 40
  0059    | ResetInput
  0060    | Drop
  0061    | Swap
  0062    | Drop
  0063    | Merge
  0064    | End
  ========================================
  
  ========toml.datetime.local_time========
  toml.datetime.local_time =
    _toml.datetime.hours + ":" +
    _toml.datetime.minutes + ":" +
    _toml.datetime.seconds +
    maybe("." + (numeral * 1..9))
  ========================================
  0000    | GetConstant 0: _toml.datetime.hours
  0002    | CallFunction 0
  0004    | GetConstant 1: ":"
  0006    | CallFunction 0
  0008    | Merge
  0009    | GetConstant 2: _toml.datetime.minutes
  0011    | CallFunction 0
  0013    | Merge
  0014    | GetConstant 3: ":"
  0016    | CallFunction 0
  0018    | Merge
  0019    | GetConstant 4: _toml.datetime.seconds
  0021    | CallFunction 0
  0023    | Merge
  0024    | GetConstant 5: maybe
  0026    | GetConstant 6: @fn825
  0028    | CallFunction 1
  0030    | Merge
  0031    | End
  ========================================
  
  =======_toml.datetime.time_offset=======
  _toml.datetime.time_offset = toml.datetime.local_time + ("Z" | "z" | _toml.datetime.time_numoffset)
  ========================================
  0000    | GetConstant 0: toml.datetime.local_time
  0002    | CallFunction 0
  0004    | SetInputMark
  0005    | GetConstant 1: "Z"
  0007    | CallFunction 0
  0009    | Or 9 -> 24
  0012    | SetInputMark
  0013    | GetConstant 2: "z"
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | GetConstant 3: _toml.datetime.time_numoffset
  0022    | CallFunction 0
  0024    | Merge
  0025    | End
  ========================================
  
  =====_toml.datetime.time_numoffset======
  _toml.datetime.time_numoffset = ("+" | "-") + _toml.datetime.hours + ":" + _toml.datetime.minutes
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "-"
  0010    | CallFunction 0
  0012    | GetConstant 2: _toml.datetime.hours
  0014    | CallFunction 0
  0016    | Merge
  0017    | GetConstant 3: ":"
  0019    | CallFunction 0
  0021    | Merge
  0022    | GetConstant 4: _toml.datetime.minutes
  0024    | CallFunction 0
  0026    | Merge
  0027    | End
  ========================================
  
  ==========_toml.datetime.hours==========
  _toml.datetime.hours = ("0".."1" + "0".."9") | ("2" + "0".."3")
  ========================================
  0000    | SetInputMark
  0001    | ParseFixedRange 0 1: "0" "1"
  0004    | ParseFixedRange 2 3: "0" "9"
  0007    | Merge
  0008    | Or 8 -> 19
  0011    | GetConstant 4: "2"
  0013    | CallFunction 0
  0015    | ParseFixedRange 5 6: "0" "3"
  0018    | Merge
  0019    | End
  ========================================
  
  =========_toml.datetime.minutes=========
  _toml.datetime.minutes = "0".."5" + "0".."9"
  ========================================
  0000    | ParseFixedRange 0 1: "0" "5"
  0003    | ParseFixedRange 2 3: "0" "9"
  0006    | Merge
  0007    | End
  ========================================
  
  =========_toml.datetime.seconds=========
  _toml.datetime.seconds = ("0".."5" + "0".."9") | "60"
  ========================================
  0000    | SetInputMark
  0001    | ParseFixedRange 0 1: "0" "5"
  0004    | ParseFixedRange 2 3: "0" "9"
  0007    | Merge
  0008    | Or 8 -> 15
  0011    | GetConstant 4: "60"
  0013    | CallFunction 0
  0015    | End
  ========================================
  
  =================@fn826=================
  _toml.number.sign +
    _toml.number.integer_part
  ========================================
  0000    | GetConstant 0: _toml.number.sign
  0002    | CallFunction 0
  0004    | GetConstant 1: _toml.number.integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  ==========toml.number.integer===========
  toml.number.integer = as_number(
    _toml.number.sign +
    _toml.number.integer_part
  )
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn826
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn827=================
  "-" | skip("+")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 14
  0008    | GetConstant 1: skip
  0010    | GetConstant 2: "+"
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  ===========_toml.number.sign============
  _toml.number.sign = maybe("-" | skip("+"))
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: @fn827
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn828=================
  maybe("_") > numeral
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 13
  0009    | GetConstant 2: numeral
  0011    | CallFunction 0
  0013    | End
  ========================================
  
  =======_toml.number.integer_part========
  _toml.number.integer_part =
    ("1".."9" + many(maybe("_") > numeral)) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseFixedRange 0 1: "1" "9"
  0004    | GetConstant 2: many
  0006    | GetConstant 3: @fn828
  0008    | CallFunction 1
  0010    | Merge
  0011    | Or 11 -> 18
  0014    | GetConstant 4: numeral
  0016    | CallFunction 0
  0018    | End
  ========================================
  
  =================@fn829=================
  _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  ========================================
  0000    | GetConstant 0: _toml.number.sign
  0002    | CallFunction 0
  0004    | GetConstant 1: _toml.number.integer_part
  0006    | CallFunction 0
  0008    | Merge
  0009    | SetInputMark
  0010    | GetConstant 2: _toml.number.fraction_part
  0012    | CallFunction 0
  0014    | GetConstant 3: maybe
  0016    | GetConstant 4: _toml.number.exponent_part
  0018    | CallFunction 1
  0020    | Merge
  0021    | Or 21 -> 28
  0024    | GetConstant 5: _toml.number.exponent_part
  0026    | CallFunction 0
  0028    | Merge
  0029    | End
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn829
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn830=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.fraction_part=======
  _toml.number.fraction_part = "." + many_sep(numerals, maybe("_"))
  ========================================
  0000    | GetConstant 0: "."
  0002    | CallFunction 0
  0004    | GetConstant 1: many_sep
  0006    | GetConstant 2: numerals
  0008    | GetConstant 3: @fn830
  0010    | CallFunction 2
  0012    | Merge
  0013    | End
  ========================================
  
  =================@fn831=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================@fn832=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.exponent_part=======
  _toml.number.exponent_part =
    ("e" | "E") + maybe("-" | "+") + many_sep(numerals, maybe("_"))
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "E"
  0010    | CallFunction 0
  0012    | GetConstant 2: maybe
  0014    | GetConstant 3: @fn831
  0016    | CallFunction 1
  0018    | Merge
  0019    | GetConstant 4: many_sep
  0021    | GetConstant 5: numerals
  0023    | GetConstant 6: @fn832
  0025    | CallFunction 2
  0027    | Merge
  0028    | End
  ========================================
  
  =================@fn833=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "-"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==========toml.number.infinity==========
  toml.number.infinity = maybe("+" | "-") + "inf"
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: @fn833
  0004    | CallFunction 1
  0006    | GetConstant 2: "inf"
  0008    | CallFunction 0
  0010    | Merge
  0011    | End
  ========================================
  
  =================@fn834=================
  "+" | "-"
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "-"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========toml.number.not_a_number========
  toml.number.not_a_number = maybe("+" | "-") + "nan"
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: @fn834
  0004    | CallFunction 1
  0006    | GetConstant 2: "nan"
  0008    | CallFunction 0
  0010    | Merge
  0011    | End
  ========================================
  
  =================@fn836=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn837=================
  skip("_") < peek(binary_numeral)
  ========================================
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 2: peek
  0011    | GetConstant 3: binary_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn835=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral))
  ========================================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: 0
  0004    | GetConstant 2: @fn836
  0006    | CallFunction 2
  0008    | GetConstant 3: maybe
  0010    | GetConstant 4: @fn837
  0012    | CallFunction 1
  0014    | Merge
  0015    | End
  ========================================
  
  =================@fn839=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn838=================
  array_sep(binary_digit, maybe("_"))
  ========================================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: binary_digit
  0004    | GetConstant 2: @fn839
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
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: "0b"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 28
  0009    | GetConstant 2: one_or_both
  0011    | GetConstant 3: @fn835
  0013    | GetConstant 4: @fn838
  0015    | CallFunction 2
  0017    | Destructure 0: Digits
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 5: Num.FromBinaryDigits
  0024    | GetBoundLocal 0
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  =================@fn841=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn842=================
  skip("_") < peek(octal_numeral)
  ========================================
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 2: peek
  0011    | GetConstant 3: octal_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn840=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral))
  ========================================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: 0
  0004    | GetConstant 2: @fn841
  0006    | CallFunction 2
  0008    | GetConstant 3: maybe
  0010    | GetConstant 4: @fn842
  0012    | CallFunction 1
  0014    | Merge
  0015    | End
  ========================================
  
  =================@fn844=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn843=================
  array_sep(octal_digit, maybe("_"))
  ========================================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: octal_digit
  0004    | GetConstant 2: @fn844
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
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: "0o"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 28
  0009    | GetConstant 2: one_or_both
  0011    | GetConstant 3: @fn840
  0013    | GetConstant 4: @fn843
  0015    | CallFunction 2
  0017    | Destructure 0: Digits
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 5: Num.FromOctalDigits
  0024    | GetBoundLocal 0
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  =================@fn846=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn847=================
  skip("_") < peek(hex_numeral)
  ========================================
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 2: peek
  0011    | GetConstant 3: hex_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn845=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral))
  ========================================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: 0
  0004    | GetConstant 2: @fn846
  0006    | CallFunction 2
  0008    | GetConstant 3: maybe
  0010    | GetConstant 4: @fn847
  0012    | CallFunction 1
  0014    | Merge
  0015    | End
  ========================================
  
  =================@fn849=================
  maybe("_")
  ========================================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn848=================
  array_sep(hex_digit, maybe("_"))
  ========================================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: hex_digit
  0004    | GetConstant 2: @fn849
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
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: "0x"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 28
  0009    | GetConstant 2: one_or_both
  0011    | GetConstant 3: @fn845
  0013    | GetConstant 4: @fn848
  0015    | CallFunction 2
  0017    | Destructure 0: Digits
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 5: Num.FromHexDigits
  0024    | GetBoundLocal 0
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  ============_Toml.Doc.Empty=============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant 0: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  ============_Toml.Doc.Value=============
  _Toml.Doc.Value(Doc) = Obj.Get(Doc, "value")
  ========================================
  0000    | GetConstant 0: Obj.Get
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: "value"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Toml.Doc.Type=============
  _Toml.Doc.Type(Doc) = Obj.Get(Doc, "type")
  ========================================
  0000    | GetConstant 0: Obj.Get
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: "type"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Toml.Doc.Has==============
  _Toml.Doc.Has(Doc, Key) = Obj.Has(_Toml.Doc.Type(Doc), Key)
  ========================================
  0000    | GetConstant 0: Obj.Has
  0002    | GetConstant 1: _Toml.Doc.Type
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetBoundLocal 1
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  =============_Toml.Doc.Get==============
  _Toml.Doc.Get(Doc, Key) = {
    "value": Obj.Get(_Toml.Doc.Value(Doc), Key),
    "type": Obj.Get(_Toml.Doc.Type(Doc), Key),
  }
  ========================================
  0000    | GetConstant 0: {}
  0002    | GetConstant 2: Obj.Get
  0004    | GetConstant 3: _Toml.Doc.Value
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | GetBoundLocal 1
  0012    | CallFunction 2
  0014    | InsertAtKey 1: "value"
  0016    | GetConstant 5: Obj.Get
  0018    | GetConstant 6: _Toml.Doc.Type
  0020    | GetBoundLocal 0
  0022    | CallFunction 1
  0024    | GetBoundLocal 1
  0026    | CallFunction 2
  0028    | InsertAtKey 4: "type"
  0030    | End
  ========================================
  
  ===========_Toml.Doc.IsTable============
  _Toml.Doc.IsTable(Doc) = Is.Object(_Toml.Doc.Type(Doc))
  ========================================
  0000    | GetConstant 0: Is.Object
  0002    | GetConstant 1: _Toml.Doc.Type
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ============_Toml.Doc.Insert============
  _Toml.Doc.Insert(Doc, Key, Val, Type) =
    _Toml.Doc.IsTable(Doc) &
    {
      "value": Obj.Put(_Toml.Doc.Value(Doc), Key, Val),
      "type": Obj.Put(_Toml.Doc.Type(Doc), Key, Type),
    }
  ========================================
  0000    | GetConstant 0: _Toml.Doc.IsTable
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 43
  0009    | GetConstant 1: {}
  0011    | GetConstant 3: Obj.Put
  0013    | GetConstant 4: _Toml.Doc.Value
  0015    | GetBoundLocal 0
  0017    | CallFunction 1
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 2
  0023    | CallFunction 3
  0025    | InsertAtKey 2: "value"
  0027    | GetConstant 6: Obj.Put
  0029    | GetConstant 7: _Toml.Doc.Type
  0031    | GetBoundLocal 0
  0033    | CallFunction 1
  0035    | GetBoundLocal 1
  0037    | GetBoundLocal 3
  0039    | CallFunction 3
  0041    | InsertAtKey 5: "type"
  0043    | End
  ========================================
  
  ====_Toml.Doc.AppendToArrayOfTables=====
  _Toml.Doc.AppendToArrayOfTables(Doc, Key, Val) =
    _Toml.Doc.Get(Doc, Key) -> {"value": AoT, "type": "array_of_tables"} &
    _Toml.Doc.Insert(Doc, Key, [...AoT, Val], "array_of_tables")
  ========================================
  0000    | GetConstant 0: AoT
  0002    | GetConstant 1: _Toml.Doc.Get
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | Destructure 0: {"value": AoT, "type": "array_of_tables"}
  0012    | TakeRight 12 -> 37
  0015    | GetConstant 2: _Toml.Doc.Insert
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 1
  0021    | GetConstant 3: []
  0023    | GetBoundLocal 3
  0025    | Merge
  0026    | GetConstant 4: [_]
  0028    | GetBoundLocal 2
  0030    | InsertAtIndex 0
  0032    | Merge
  0033    | GetConstant 5: "array_of_tables"
  0035    | CallTailFunction 4
  0037    | End
  ========================================
  
  =========_Toml.Doc.InsertAtPath=========
  _Toml.Doc.InsertAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.ValueUpdater)
  ========================================
  0000    | GetConstant 0: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetConstant 1: _Toml.Doc.ValueUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  ======_Toml.Doc.EnsureTableAtPath=======
  _Toml.Doc.EnsureTableAtPath(Doc, Path) =
    _Toml.Doc.UpdateAtPath(Doc, Path, {}, _Toml.Doc.MissingTableUpdater)
  ========================================
  0000    | GetConstant 0: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: {}
  0008    | GetConstant 2: _Toml.Doc.MissingTableUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =========_Toml.Doc.AppendAtPath=========
  _Toml.Doc.AppendAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.AppendUpdater)
  ========================================
  0000    | GetConstant 0: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetConstant 1: _Toml.Doc.AppendUpdater
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
  0000    | GetConstant 0: Key
  0002    | GetConstant 1: PathRest
  0004    | GetConstant 2: InnerDoc
  0006    | SetInputMark
  0007    | GetBoundLocal 1
  0009    | Destructure 0: [Key]
  0011    | ConditionalThen 11 -> 27
  0014    | GetBoundLocal 3
  0016    | GetBoundLocal 0
  0018    | GetBoundLocal 4
  0020    | GetBoundLocal 2
  0022    | CallTailFunction 3
  0024    | Jump 24 -> 127
  0027    | SetInputMark
  0028    | GetBoundLocal 1
  0030    | Destructure 1: ([Key] + PathRest)
  0032    | ConditionalThen 32 -> 125
  0035    | SetInputMark
  0036    | GetConstant 3: _Toml.Doc.Has
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 4
  0042    | CallFunction 2
  0044    | ConditionalThen 44 -> 83
  0047    | GetConstant 4: _Toml.Doc.IsTable
  0049    | GetConstant 5: _Toml.Doc.Get
  0051    | GetBoundLocal 0
  0053    | GetBoundLocal 4
  0055    | CallFunction 2
  0057    | CallFunction 1
  0059    | TakeRight 59 -> 80
  0062    | GetConstant 6: _Toml.Doc.UpdateAtPath
  0064    | GetConstant 7: _Toml.Doc.Get
  0066    | GetBoundLocal 0
  0068    | GetBoundLocal 4
  0070    | CallFunction 2
  0072    | GetBoundLocal 5
  0074    | GetBoundLocal 2
  0076    | GetBoundLocal 3
  0078    | CallFunction 4
  0080    | Jump 80 -> 97
  0083    | GetConstant 8: _Toml.Doc.UpdateAtPath
  0085    | GetConstant 9: _Toml.Doc.Empty
  0087    | CallFunction 0
  0089    | GetBoundLocal 5
  0091    | GetBoundLocal 2
  0093    | GetBoundLocal 3
  0095    | CallFunction 4
  0097    | Destructure 2: InnerDoc
  0099    | TakeRight 99 -> 122
  0102    | GetConstant 10: _Toml.Doc.Insert
  0104    | GetBoundLocal 0
  0106    | GetBoundLocal 4
  0108    | GetConstant 11: _Toml.Doc.Value
  0110    | GetBoundLocal 6
  0112    | CallFunction 1
  0114    | GetConstant 12: _Toml.Doc.Type
  0116    | GetBoundLocal 6
  0118    | CallFunction 1
  0120    | CallTailFunction 4
  0122    | Jump 122 -> 127
  0125    | GetBoundLocal 0
  0127    | End
  ========================================
  
  =========_Toml.Doc.ValueUpdater=========
  _Toml.Doc.ValueUpdater(Doc, Key, Val) =
    _Toml.Doc.Has(Doc, Key) ? @Fail : _Toml.Doc.Insert(Doc, Key, Val, "value")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _Toml.Doc.Has
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | ConditionalThen 9 -> 19
  0012    | GetConstant 1: @Fail
  0014    | CallTailFunction 0
  0016    | Jump 16 -> 31
  0019    | GetConstant 2: _Toml.Doc.Insert
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 1
  0025    | GetBoundLocal 2
  0027    | GetConstant 3: "value"
  0029    | CallTailFunction 4
  0031    | End
  ========================================
  
  =====_Toml.Doc.MissingTableUpdater======
  _Toml.Doc.MissingTableUpdater(Doc, Key, _Val) =
    _Toml.Doc.IsTable(_Toml.Doc.Get(Doc, Key)) ? Doc :
    _Toml.Doc.Insert(Doc, Key, {}, {})
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: _Toml.Doc.IsTable
  0003    | GetConstant 1: _Toml.Doc.Get
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | CallFunction 1
  0013    | ConditionalThen 13 -> 21
  0016    | GetBoundLocal 0
  0018    | Jump 18 -> 33
  0021    | GetConstant 2: _Toml.Doc.Insert
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | GetConstant 3: {}
  0029    | GetConstant 4: {}
  0031    | CallTailFunction 4
  0033    | End
  ========================================
  
  ========_Toml.Doc.AppendUpdater=========
  _Toml.Doc.AppendUpdater(Doc, Key, Val) =
    (
      _Toml.Doc.Has(Doc, Key) ? Doc :
      _Toml.Doc.Insert(Doc, Key, [], "array_of_tables")
    ) -> DocWithKey &
    _Toml.Doc.AppendToArrayOfTables(DocWithKey, Key, Val)
  ========================================
  0000    | GetConstant 0: DocWithKey
  0002    | SetInputMark
  0003    | GetConstant 1: _Toml.Doc.Has
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | ConditionalThen 11 -> 19
  0014    | GetBoundLocal 0
  0016    | Jump 16 -> 31
  0019    | GetConstant 2: _Toml.Doc.Insert
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 1
  0025    | GetConstant 3: []
  0027    | GetConstant 4: "array_of_tables"
  0029    | CallFunction 4
  0031    | Destructure 0: DocWithKey
  0033    | TakeRight 33 -> 46
  0036    | GetConstant 5: _Toml.Doc.AppendToArrayOfTables
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 1
  0042    | GetBoundLocal 2
  0044    | CallTailFunction 3
  0046    | End
  ========================================
  
  ======ast.with_operator_precedence======
  ast.with_operator_precedence(operand, prefix, infix, postfix) =
    _ast.with_precedence_start(operand, prefix, infix, postfix, $0)
  ========================================
  0000    | GetConstant 0: _ast.with_precedence_start
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetBoundLocal 3
  0010    | GetConstant 1: 0
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
  0000    | GetConstant 0: PrefixBindingPower
  0002    | GetConstant 1: PrefixNode
  0004    | GetConstant 2: Node
  0006    | SetInputMark
  0007    | GetBoundLocal 1
  0009    | CallFunction 0
  0011    | Destructure 0: ({"power": PrefixBindingPower} + PrefixNode)
  0013    | ConditionalThen 13 -> 73
  0016    | GetConstant 3: _ast.with_precedence_start
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | GetBoundLocal 2
  0024    | GetBoundLocal 3
  0026    | GetBoundLocal 5
  0028    | CallFunction 5
  0030    | Destructure 1: Node
  0032    | TakeRight 32 -> 70
  0035    | GetConstant 4: _ast.with_precedence_rest
  0037    | GetBoundLocal 0
  0039    | GetBoundLocal 1
  0041    | GetBoundLocal 2
  0043    | GetBoundLocal 3
  0045    | GetBoundLocal 4
  0047    | GetConstant 5: {}
  0049    | GetBoundLocal 6
  0051    | Merge
  0052    | GetConstant 6: {}
  0054    | GetBoundLocal 7
  0056    | InsertAtKey 7: "prefixed"
  0058    | GetConstant 8: _Ast.MergePos
  0060    | GetBoundLocal 6
  0062    | GetBoundLocal 7
  0064    | CallFunction 2
  0066    | Merge
  0067    | Merge
  0068    | CallTailFunction 6
  0070    | Jump 70 -> 98
  0073    | GetBoundLocal 0
  0075    | CallFunction 0
  0077    | Destructure 2: Node
  0079    | TakeRight 79 -> 98
  0082    | GetConstant 9: _ast.with_precedence_rest
  0084    | GetBoundLocal 0
  0086    | GetBoundLocal 1
  0088    | GetBoundLocal 2
  0090    | GetBoundLocal 3
  0092    | GetBoundLocal 4
  0094    | GetBoundLocal 7
  0096    | CallTailFunction 6
  0098    | End
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
  0000    | GetConstant 0: RightBindingPower
  0002    | GetConstant 1: PostfixNode
  0004    | GetConstant 2: NextLeftBindingPower
  0006    | GetConstant 3: InfixNode
  0008    | GetConstant 4: RightNode
  0010    | SetInputMark
  0011    | GetBoundLocal 3
  0013    | CallFunction 0
  0015    | Destructure 0: ({"power": RightBindingPower} + PostfixNode)
  0017    | TakeRight 17 -> 32
  0020    | GetConstant 5: const
  0022    | GetConstant 6: Is.LessThan
  0024    | GetBoundLocal 4
  0026    | GetBoundLocal 6
  0028    | CallFunction 2
  0030    | CallFunction 1
  0032    | ConditionalThen 32 -> 73
  0035    | GetConstant 7: _ast.with_precedence_rest
  0037    | GetBoundLocal 0
  0039    | GetBoundLocal 1
  0041    | GetBoundLocal 2
  0043    | GetBoundLocal 3
  0045    | GetBoundLocal 4
  0047    | GetConstant 8: {}
  0049    | GetBoundLocal 7
  0051    | Merge
  0052    | GetConstant 9: {}
  0054    | GetBoundLocal 5
  0056    | InsertAtKey 10: "postfixed"
  0058    | GetConstant 11: _Ast.MergePos
  0060    | GetBoundLocal 5
  0062    | GetBoundLocal 7
  0064    | CallFunction 2
  0066    | Merge
  0067    | Merge
  0068    | CallTailFunction 6
  0070    | Jump 70 -> 165
  0073    | SetInputMark
  0074    | GetBoundLocal 2
  0076    | CallFunction 0
  0078    | Destructure 1: ({"power": [RightBindingPower, NextLeftBindingPower]} + InfixNode)
  0080    | TakeRight 80 -> 95
  0083    | GetConstant 12: const
  0085    | GetConstant 13: Is.LessThan
  0087    | GetBoundLocal 4
  0089    | GetBoundLocal 6
  0091    | CallFunction 2
  0093    | CallFunction 1
  0095    | ConditionalThen 95 -> 159
  0098    | GetConstant 14: _ast.with_precedence_start
  0100    | GetBoundLocal 0
  0102    | GetBoundLocal 1
  0104    | GetBoundLocal 2
  0106    | GetBoundLocal 3
  0108    | GetBoundLocal 8
  0110    | CallFunction 5
  0112    | Destructure 2: RightNode
  0114    | TakeRight 114 -> 156
  0117    | GetConstant 15: _ast.with_precedence_rest
  0119    | GetBoundLocal 0
  0121    | GetBoundLocal 1
  0123    | GetBoundLocal 2
  0125    | GetBoundLocal 3
  0127    | GetBoundLocal 4
  0129    | GetConstant 16: {}
  0131    | GetBoundLocal 9
  0133    | Merge
  0134    | GetConstant 17: {}
  0136    | GetBoundLocal 5
  0138    | InsertAtKey 18: "left"
  0140    | GetBoundLocal 10
  0142    | InsertAtKey 19: "right"
  0144    | GetConstant 20: _Ast.MergePos
  0146    | GetBoundLocal 5
  0148    | GetBoundLocal 10
  0150    | CallFunction 2
  0152    | Merge
  0153    | Merge
  0154    | CallTailFunction 6
  0156    | Jump 156 -> 165
  0159    | GetConstant 21: const
  0161    | GetBoundLocal 5
  0163    | CallTailFunction 1
  0165    | End
  ========================================
  
  ================ast.node================
  ast.node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | GetConstant 0: Value
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | Destructure 0: Value
  0008    | TakeRight 8 -> 21
  0011    | GetConstant 1: {}
  0013    | GetBoundLocal 1
  0015    | InsertAtKey 2: "type"
  0017    | GetBoundLocal 2
  0019    | InsertAtKey 3: "value"
  0021    | End
  ========================================
  
  ============ast.prefix_node=============
  ast.prefix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 17
  0007    | GetConstant 0: {}
  0009    | GetBoundLocal 1
  0011    | InsertAtKey 1: "type"
  0013    | GetBoundLocal 2
  0015    | InsertAtKey 2: "power"
  0017    | End
  ========================================
  
  =============ast.infix_node=============
  ast.infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    op $ {"type": Type, "power": [LeftBindingPower, RightBindingPower]}
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 25
  0007    | GetConstant 0: {}
  0009    | GetBoundLocal 1
  0011    | InsertAtKey 1: "type"
  0013    | GetConstant 3: [_, _]
  0015    | GetBoundLocal 2
  0017    | InsertAtIndex 0
  0019    | GetBoundLocal 3
  0021    | InsertAtIndex 1
  0023    | InsertAtKey 2: "power"
  0025    | End
  ========================================
  
  ============ast.postfix_node============
  ast.postfix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 17
  0007    | GetConstant 0: {}
  0009    | GetBoundLocal 1
  0011    | InsertAtKey 1: "type"
  0013    | GetBoundLocal 2
  0015    | InsertAtKey 2: "power"
  0017    | End
  ========================================
  
  ==========ast.with_offset_pos===========
  ast.with_offset_pos(node) =
    @input.offset -> StartOffset &
    node -> Node &
    @input.offset -> EndOffset $
    {...Node, "startpos": StartOffset, "endpos": EndOffset}
  ========================================
  0000    | GetConstant 0: StartOffset
  0002    | GetConstant 1: Node
  0004    | GetConstant 2: EndOffset
  0006    | GetConstant 3: @input.offset
  0008    | CallFunction 0
  0010    | Destructure 0: StartOffset
  0012    | TakeRight 12 -> 21
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Destructure 1: Node
  0021    | TakeRight 21 -> 49
  0024    | GetConstant 4: @input.offset
  0026    | CallFunction 0
  0028    | Destructure 2: EndOffset
  0030    | TakeRight 30 -> 49
  0033    | GetConstant 5: {}
  0035    | GetBoundLocal 2
  0037    | Merge
  0038    | GetConstant 6: {}
  0040    | GetBoundLocal 1
  0042    | InsertAtKey 7: "startpos"
  0044    | GetBoundLocal 3
  0046    | InsertAtKey 8: "endpos"
  0048    | Merge
  0049    | End
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
  0000    | GetConstant 0: StartLine
  0002    | GetConstant 1: StartLineOffset
  0004    | GetConstant 2: Node
  0006    | GetConstant 3: EndLine
  0008    | GetConstant 4: EndLineOffset
  0010    | GetConstant 5: @input.line
  0012    | CallFunction 0
  0014    | Destructure 0: StartLine
  0016    | TakeRight 16 -> 25
  0019    | GetConstant 6: @input.line_offset
  0021    | CallFunction 0
  0023    | Destructure 1: StartLineOffset
  0025    | TakeRight 25 -> 34
  0028    | GetBoundLocal 0
  0030    | CallFunction 0
  0032    | Destructure 2: Node
  0034    | TakeRight 34 -> 43
  0037    | GetConstant 7: @input.line
  0039    | CallFunction 0
  0041    | Destructure 3: EndLine
  0043    | TakeRight 43 -> 87
  0046    | GetConstant 8: @input.line_offset
  0048    | CallFunction 0
  0050    | Destructure 4: EndLineOffset
  0052    | TakeRight 52 -> 87
  0055    | GetConstant 9: {}
  0057    | GetBoundLocal 3
  0059    | Merge
  0060    | GetConstant 10: {}
  0062    | GetConstant 12: {}
  0064    | GetBoundLocal 1
  0066    | InsertAtKey 13: "line"
  0068    | GetBoundLocal 2
  0070    | InsertAtKey 14: "offset"
  0072    | InsertAtKey 11: "startpos"
  0074    | GetConstant 16: {}
  0076    | GetBoundLocal 4
  0078    | InsertAtKey 17: "line"
  0080    | GetBoundLocal 5
  0082    | InsertAtKey 18: "offset"
  0084    | InsertAtKey 15: "endpos"
  0086    | Merge
  0087    | End
  ========================================
  
  ================Num.Inc=================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant 0: @Add
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Dec=================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant 0: @Subtract
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: 1
  0006    | CallTailFunction 2
  0008    | End
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
  0000    | GetConstant 0: Len
  0002    | GetConstant 1: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 0: Len
  0010    | TakeRight 10 -> 26
  0013    | GetConstant 2: _Num.FromBinaryDigits
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetConstant 3: -1
  0021    | Merge
  0022    | GetConstant 4: 0
  0024    | CallTailFunction 3
  0026    | End
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
  0000    | GetConstant 0: B
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([B] + Rest)
  0009    | ConditionalThen 9 -> 50
  0012    | GetBoundLocal 3
  0014    | Destructure 1: 0..1
  0016    | TakeRight 16 -> 47
  0019    | GetConstant 2: _Num.FromBinaryDigits
  0021    | GetBoundLocal 4
  0023    | GetBoundLocal 1
  0025    | GetConstant 3: -1
  0027    | Merge
  0028    | GetBoundLocal 2
  0030    | GetConstant 4: @Multiply
  0032    | GetBoundLocal 3
  0034    | GetConstant 5: @Power
  0036    | GetConstant 6: 2
  0038    | GetBoundLocal 1
  0040    | CallFunction 2
  0042    | CallFunction 2
  0044    | Merge
  0045    | CallTailFunction 3
  0047    | Jump 47 -> 52
  0050    | GetBoundLocal 2
  0052    | End
  ========================================
  
  ==========Num.FromOctalDigits===========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | GetConstant 0: Len
  0002    | GetConstant 1: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 0: Len
  0010    | TakeRight 10 -> 26
  0013    | GetConstant 2: _Num.FromOctalDigits
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetConstant 3: -1
  0021    | Merge
  0022    | GetConstant 4: 0
  0024    | CallTailFunction 3
  0026    | End
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
  0000    | GetConstant 0: O
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([O] + Rest)
  0009    | ConditionalThen 9 -> 50
  0012    | GetBoundLocal 3
  0014    | Destructure 1: 0..7
  0016    | TakeRight 16 -> 47
  0019    | GetConstant 2: _Num.FromOctalDigits
  0021    | GetBoundLocal 4
  0023    | GetBoundLocal 1
  0025    | GetConstant 3: -1
  0027    | Merge
  0028    | GetBoundLocal 2
  0030    | GetConstant 4: @Multiply
  0032    | GetBoundLocal 3
  0034    | GetConstant 5: @Power
  0036    | GetConstant 6: 8
  0038    | GetBoundLocal 1
  0040    | CallFunction 2
  0042    | CallFunction 2
  0044    | Merge
  0045    | CallTailFunction 3
  0047    | Jump 47 -> 52
  0050    | GetBoundLocal 2
  0052    | End
  ========================================
  
  ===========Num.FromHexDigits============
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | GetConstant 0: Len
  0002    | GetConstant 1: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 0: Len
  0010    | TakeRight 10 -> 26
  0013    | GetConstant 2: _Num.FromHexDigits
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetConstant 3: -1
  0021    | Merge
  0022    | GetConstant 4: 0
  0024    | CallTailFunction 3
  0026    | End
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
  0000    | GetConstant 0: H
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([H] + Rest)
  0009    | ConditionalThen 9 -> 50
  0012    | GetBoundLocal 3
  0014    | Destructure 1: 0..15
  0016    | TakeRight 16 -> 47
  0019    | GetConstant 2: _Num.FromHexDigits
  0021    | GetBoundLocal 4
  0023    | GetBoundLocal 1
  0025    | GetConstant 3: -1
  0027    | Merge
  0028    | GetBoundLocal 2
  0030    | GetConstant 4: @Multiply
  0032    | GetBoundLocal 3
  0034    | GetConstant 5: @Power
  0036    | GetConstant 6: 16
  0038    | GetBoundLocal 1
  0040    | CallFunction 2
  0042    | CallFunction 2
  0044    | Merge
  0045    | CallTailFunction 3
  0047    | Jump 47 -> 52
  0050    | GetBoundLocal 2
  0052    | End
  ========================================
  
  ==============Array.First===============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | GetConstant 0: F
  0002    | GetConstant 1: _
  0004    | GetBoundLocal 0
  0006    | Destructure 0: ([F] + _)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 1
  0013    | End
  ========================================
  
  ===============Array.Rest===============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | GetConstant 0: _
  0002    | GetConstant 1: R
  0004    | GetBoundLocal 0
  0006    | Destructure 0: ([_] + R)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 2
  0013    | End
  ========================================
  
  ==============Array.Length==============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | GetConstant 0: _
  0002    | GetConstant 1: L
  0004    | GetBoundLocal 0
  0006    | Destructure 0: ([_] * L)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 2
  0013    | End
  ========================================
  
  =============Array.Reverse==============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant 0: _Array.Reverse
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Array.Reverse=============
  _Array.Reverse(A, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reverse(Rest, [First, ...Acc]) :
    Acc
  ========================================
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([First] + Rest)
  0009    | ConditionalThen 9 -> 30
  0012    | GetConstant 2: _Array.Reverse
  0014    | GetBoundLocal 3
  0016    | GetConstant 3: [_]
  0018    | GetBoundLocal 2
  0020    | InsertAtIndex 0
  0022    | GetBoundLocal 1
  0024    | Merge
  0025    | CallTailFunction 2
  0027    | Jump 27 -> 32
  0030    | GetBoundLocal 1
  0032    | End
  ========================================
  
  ===============Array.Map================
  Array.Map(A, Fn) = _Array.Map(A, Fn, [])
  ========================================
  0000    | GetConstant 0: _Array.Map
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===============_Array.Map===============
  _Array.Map(A, Fn, Acc) =
    A -> [First, ...Rest] ?
    _Array.Map(Rest, Fn, [...Acc, Fn(First)]) :
    Acc
  ========================================
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([First] + Rest)
  0009    | ConditionalThen 9 -> 39
  0012    | GetConstant 2: _Array.Map
  0014    | GetBoundLocal 4
  0016    | GetBoundLocal 1
  0018    | GetConstant 3: []
  0020    | GetBoundLocal 2
  0022    | Merge
  0023    | GetConstant 4: [_]
  0025    | GetBoundLocal 1
  0027    | GetBoundLocal 3
  0029    | CallFunction 1
  0031    | InsertAtIndex 0
  0033    | Merge
  0034    | CallTailFunction 3
  0036    | Jump 36 -> 41
  0039    | GetBoundLocal 2
  0041    | End
  ========================================
  
  ==============Array.Filter==============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant 0: _Array.Filter
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_Array.Filter==============
  _Array.Filter(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Filter(Rest, Pred, Pred(First) ? [...Acc, First] : Acc) :
    Acc
  ========================================
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([First] + Rest)
  0009    | ConditionalThen 9 -> 50
  0012    | GetConstant 2: _Array.Filter
  0014    | GetBoundLocal 4
  0016    | GetBoundLocal 1
  0018    | SetInputMark
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 3
  0023    | CallFunction 1
  0025    | ConditionalThen 25 -> 43
  0028    | GetConstant 3: []
  0030    | GetBoundLocal 2
  0032    | Merge
  0033    | GetConstant 4: [_]
  0035    | GetBoundLocal 3
  0037    | InsertAtIndex 0
  0039    | Merge
  0040    | Jump 40 -> 45
  0043    | GetBoundLocal 2
  0045    | CallTailFunction 3
  0047    | Jump 47 -> 52
  0050    | GetBoundLocal 2
  0052    | End
  ========================================
  
  ==============Array.Reject==============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant 0: _Array.Reject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_Array.Reject==============
  _Array.Reject(A, Pred, Acc) =
    A -> [First, ...Rest] ?
    _Array.Reject(Rest, Pred, Pred(First) ? Acc : [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | Destructure 0: ([First] + Rest)
  0009    | ConditionalThen 9 -> 50
  0012    | GetConstant 2: _Array.Reject
  0014    | GetBoundLocal 4
  0016    | GetBoundLocal 1
  0018    | SetInputMark
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 3
  0023    | CallFunction 1
  0025    | ConditionalThen 25 -> 33
  0028    | GetBoundLocal 2
  0030    | Jump 30 -> 45
  0033    | GetConstant 3: []
  0035    | GetBoundLocal 2
  0037    | Merge
  0038    | GetConstant 4: [_]
  0040    | GetBoundLocal 3
  0042    | InsertAtIndex 0
  0044    | Merge
  0045    | CallTailFunction 3
  0047    | Jump 47 -> 52
  0050    | GetBoundLocal 2
  0052    | End
  ========================================
  
  ============Array.ZipObject=============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant 0: _Array.ZipObject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: {}
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.ZipObject============
  _Array.ZipObject(Ks, Vs, Acc) =
    Ks -> [K, ...KsRest] & Vs -> [V, ...VsRest] ?
    _Array.ZipObject(KsRest, VsRest, {...Acc, K: V}) :
    Acc
  ========================================
  0000    | GetConstant 0: K
  0002    | GetConstant 1: KsRest
  0004    | GetConstant 2: V
  0006    | GetConstant 3: VsRest
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ([K] + KsRest)
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 1
  0018    | Destructure 1: ([V] + VsRest)
  0020    | ConditionalThen 20 -> 48
  0023    | GetConstant 4: _Array.ZipObject
  0025    | GetBoundLocal 4
  0027    | GetBoundLocal 6
  0029    | GetConstant 5: {}
  0031    | GetBoundLocal 2
  0033    | Merge
  0034    | GetConstant 6: {_0_}
  0036    | GetBoundLocal 3
  0038    | GetBoundLocal 5
  0040    | InsertKeyVal 0
  0042    | Merge
  0043    | CallTailFunction 3
  0045    | Jump 45 -> 50
  0048    | GetBoundLocal 2
  0050    | End
  ========================================
  
  =============Array.ZipPairs=============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant 0: _Array.ZipPairs
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.ZipPairs=============
  _Array.ZipPairs(A1, A2, Acc) =
    A1 -> [First1, ...Rest1] & A2 -> [First2, ...Rest2] ?
    _Array.ZipPairs(Rest1, Rest2, [...Acc, [First1, First2]]) :
    Acc
  ========================================
  0000    | GetConstant 0: First1
  0002    | GetConstant 1: Rest1
  0004    | GetConstant 2: First2
  0006    | GetConstant 3: Rest2
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ([First1] + Rest1)
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 1
  0018    | Destructure 1: ([First2] + Rest2)
  0020    | ConditionalThen 20 -> 54
  0023    | GetConstant 4: _Array.ZipPairs
  0025    | GetBoundLocal 4
  0027    | GetBoundLocal 6
  0029    | GetConstant 5: []
  0031    | GetBoundLocal 2
  0033    | Merge
  0034    | GetConstant 6: [_]
  0036    | GetConstant 7: [_, _]
  0038    | GetBoundLocal 3
  0040    | InsertAtIndex 0
  0042    | GetBoundLocal 5
  0044    | InsertAtIndex 1
  0046    | InsertAtIndex 0
  0048    | Merge
  0049    | CallTailFunction 3
  0051    | Jump 51 -> 56
  0054    | GetBoundLocal 2
  0056    | End
  ========================================
  
  =============Array.AppendN==============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetBoundLocal 0
  0002    | GetConstant 0: [_]
  0004    | GetBoundLocal 1
  0006    | InsertAtIndex 0
  0008    | GetBoundLocal 2
  0010    | RepeatValue
  0011    | Merge
  0012    | End
  ========================================
  
  ============Table.Transpose=============
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant 0: _Table.Transpose
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
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
  0000    | GetConstant 0: FirstPerRow
  0002    | GetConstant 1: RestPerRow
  0004    | SetInputMark
  0005    | GetConstant 2: _Table.FirstPerRow
  0007    | GetBoundLocal 0
  0009    | CallFunction 1
  0011    | Destructure 0: FirstPerRow
  0013    | TakeRight 13 -> 24
  0016    | GetConstant 3: _Table.RestPerRow
  0018    | GetBoundLocal 0
  0020    | CallFunction 1
  0022    | Destructure 1: RestPerRow
  0024    | ConditionalThen 24 -> 48
  0027    | GetConstant 4: _Table.Transpose
  0029    | GetBoundLocal 3
  0031    | GetConstant 5: []
  0033    | GetBoundLocal 1
  0035    | Merge
  0036    | GetConstant 6: [_]
  0038    | GetBoundLocal 2
  0040    | InsertAtIndex 0
  0042    | Merge
  0043    | CallTailFunction 2
  0045    | Jump 45 -> 50
  0048    | GetBoundLocal 1
  0050    | End
  ========================================
  
  ===========_Table.FirstPerRow===========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | GetConstant 2: VeryFirst
  0006    | GetConstant 3: _
  0008    | GetBoundLocal 0
  0010    | Destructure 0: ([Row] + Rest)
  0012    | TakeRight 12 -> 19
  0015    | GetBoundLocal 1
  0017    | Destructure 1: ([VeryFirst] + _)
  0019    | TakeRight 19 -> 34
  0022    | GetConstant 4: __Table.FirstPerRow
  0024    | GetBoundLocal 2
  0026    | GetConstant 5: [_]
  0028    | GetBoundLocal 3
  0030    | InsertAtIndex 0
  0032    | CallTailFunction 2
  0034    | End
  ========================================
  
  ==========__Table.FirstPerRow===========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | GetConstant 2: First
  0006    | GetConstant 3: _
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ([Row] + Rest)
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 2
  0018    | Destructure 1: ([First] + _)
  0020    | ConditionalThen 20 -> 44
  0023    | GetConstant 4: __Table.FirstPerRow
  0025    | GetBoundLocal 3
  0027    | GetConstant 5: []
  0029    | GetBoundLocal 1
  0031    | Merge
  0032    | GetConstant 6: [_]
  0034    | GetBoundLocal 4
  0036    | InsertAtIndex 0
  0038    | Merge
  0039    | CallTailFunction 2
  0041    | Jump 41 -> 46
  0044    | GetBoundLocal 1
  0046    | End
  ========================================
  
  ===========_Table.RestPerRow============
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant 0: __Table.RestPerRow
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
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
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | GetConstant 2: _
  0006    | GetConstant 3: RowRest
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ([Row] + Rest)
  0013    | ConditionalThen 13 -> 62
  0016    | SetInputMark
  0017    | GetBoundLocal 2
  0019    | Destructure 1: ([_] + RowRest)
  0021    | ConditionalThen 21 -> 45
  0024    | GetConstant 4: __Table.RestPerRow
  0026    | GetBoundLocal 3
  0028    | GetConstant 5: []
  0030    | GetBoundLocal 1
  0032    | Merge
  0033    | GetConstant 6: [_]
  0035    | GetBoundLocal 5
  0037    | InsertAtIndex 0
  0039    | Merge
  0040    | CallTailFunction 2
  0042    | Jump 42 -> 59
  0045    | GetConstant 7: __Table.RestPerRow
  0047    | GetBoundLocal 3
  0049    | GetConstant 8: []
  0051    | GetBoundLocal 1
  0053    | Merge
  0054    | GetConstant 9: [[]]
  0056    | Merge
  0057    | CallTailFunction 2
  0059    | Jump 59 -> 64
  0062    | GetBoundLocal 1
  0064    | End
  ========================================
  
  =========Table.RotateClockwise==========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant 0: Array.Map
  0002    | GetConstant 1: Table.Transpose
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetConstant 2: Array.Reverse
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ======Table.RotateCounterClockwise======
  Table.RotateCounterClockwise(T) = Array.Reverse(Table.Transpose(T))
  ========================================
  0000    | GetConstant 0: Array.Reverse
  0002    | GetConstant 1: Table.Transpose
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ============Table.ZipObjects============
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant 0: _Table.ZipObjects
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===========_Table.ZipObjects============
  _Table.ZipObjects(Ks, Rows, Acc) =
    Rows -> [Row, ...Rest] ?
    _Table.ZipObjects(Ks, Rest, [...Acc, Array.ZipObject(Ks, Row)]) :
    Acc
  ========================================
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 1
  0007    | Destructure 0: ([Row] + Rest)
  0009    | ConditionalThen 9 -> 41
  0012    | GetConstant 2: _Table.ZipObjects
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 4
  0018    | GetConstant 3: []
  0020    | GetBoundLocal 2
  0022    | Merge
  0023    | GetConstant 4: [_]
  0025    | GetConstant 5: Array.ZipObject
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 3
  0031    | CallFunction 2
  0033    | InsertAtIndex 0
  0035    | Merge
  0036    | CallTailFunction 3
  0038    | Jump 38 -> 43
  0041    | GetBoundLocal 2
  0043    | End
  ========================================
  
  ================Obj.Has=================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ({K: _} + _)
  0006    | End
  ========================================
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | GetConstant 0: V
  0002    | GetConstant 1: _
  0004    | GetBoundLocal 0
  0006    | Destructure 0: ({K: V} + _)
  0008    | TakeRight 8 -> 13
  0011    | GetBoundLocal 2
  0013    | End
  ========================================
  
  ================Obj.Put=================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | GetConstant 0: {}
  0002    | GetBoundLocal 0
  0004    | Merge
  0005    | GetConstant 1: {_0_}
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
  0000    | GetConstant 0: StartPos
  0002    | GetConstant 1: _
  0004    | GetConstant 2: EndPos
  0006    | GetConstant 3: {}
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ({"startpos": StartPos} + _)
  0013    | ConditionalThen 13 -> 25
  0016    | GetConstant 4: {}
  0018    | GetBoundLocal 2
  0020    | InsertAtKey 5: "startpos"
  0022    | Jump 22 -> 27
  0025    | GetConstant 6: {}
  0027    | Merge
  0028    | SetInputMark
  0029    | GetBoundLocal 1
  0031    | Destructure 1: ({"endpos": EndPos} + _)
  0033    | ConditionalThen 33 -> 45
  0036    | GetConstant 7: {}
  0038    | GetBoundLocal 4
  0040    | InsertAtKey 8: "endpos"
  0042    | Jump 42 -> 47
  0045    | GetConstant 9: {}
  0047    | Merge
  0048    | End
  ========================================
  
  ===============Is.String================
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ("" + _)
  0006    | End
  ========================================
  
  ===============Is.Number================
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: (0 + _)
  0006    | End
  ========================================
  
  ================Is.Bool=================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | GetConstant 0: _
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
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | Destructure 0: ([] + _)
  0006    | End
  ========================================
  
  ===============Is.Object================
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | GetConstant 0: _
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
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 0: @Fail
  0010    | CallTailFunction 0
  0012    | Jump 12 -> 19
  0015    | GetBoundLocal 0
  0017    | Destructure 1: ..B
  0019    | End
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
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 0: @Fail
  0010    | CallTailFunction 0
  0012    | Jump 12 -> 19
  0015    | GetBoundLocal 0
  0017    | Destructure 1: B..
  0019    | End
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
  0000    | GetConstant 0: N
  0002    | SetInputMark
  0003    | GetConstant 1: Is.Number
  0005    | GetBoundLocal 0
  0007    | CallFunction 1
  0009    | Or 9 -> 21
  0012    | GetBoundLocal 0
  0014    | Destructure 0: "%(0 + N)"
  0016    | TakeRight 16 -> 21
  0019    | GetBoundLocal 1
  0021    | End
  ========================================
  
  ===============As.String================
  As.String(V) = "%(V)"
  ========================================
  0000    | GetConstant 0: ""
  0002    | GetBoundLocal 0
  0004    | MergeAsString
  0005    | End
  ========================================

