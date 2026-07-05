  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i '' --no-stdlib
  
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
  0001    | ParseChar '0'
  0003    | Or 3 -> 8
  0006    | ParseChar '1'
  0008    | End
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
  0001    | CallFunctionConstant 4: numeral
  0003    | Or 3 -> 16
  0006    | SetInputMark
  0007    | ParseCodepointRange 'a'..'f'
  0010    | Or 10 -> 16
  0013    | ParseCodepointRange 'A'..'F'
  0016    | End
  ========================================
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 1: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
  ========================================
  
  =================alnums=================
  alnums = many(alnum)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 5: alnum
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn52==================
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
  0002    | GetConstant 6: @fn52
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================unless=================
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
  
  =================@fn55==================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 12: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 13: newline
  0008    | End
  ========================================
  
  ===============whitespace===============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 11: @fn55
  0004    | CallTailFunction 1
  0006    | End
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
  0013    | CallFunctionConstant 14: "\xc2\xa0" (esc)
  0015    | Or 15 -> 41
  0018    | SetInputMark
  0019    | GetConstant 15: "\xe2\x80\x80" (esc)
  0021    | GetConstant 16: "\xe2\x80\x8a" (esc)
  0023    | ParseRange
  0024    | Or 24 -> 41
  0027    | SetInputMark
  0028    | CallFunctionConstant 17: "\xe2\x80\xaf" (esc)
  0030    | Or 30 -> 41
  0033    | SetInputMark
  0034    | CallFunctionConstant 18: "\xe2\x81\x9f" (esc)
  0036    | Or 36 -> 41
  0039    | CallTailFunctionConstant 19: "\xe3\x80\x80" (esc)
  0041    | End
  ========================================
  
  ================newline=================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 20: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 21: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 22: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 23: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  =================@fn59==================
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
  
  ==================word==================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 24: @fn59
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn62==================
  newline | end_of_input
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 13: newline
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 27: end_of_input
  0008    | End
  ========================================
  
  ==================line==================
  line = chars_until(newline | end_of_input)
  ========================================
  0000    | GetConstant 25: chars_until
  0002    | GetConstant 26: @fn62
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============chars_until===============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 28: many_until
  0002    | GetConstant 8: char
  0004    | GetBoundLocalMove 0
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
  0052    | GetConstant 29: peek
  0054    | GetBoundLocalMove 1
  0056    | CallFunction 1
  0058    | TakeLeft
  0059    | End
  ========================================
  
  ==================peek==================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | GetConstant 30: Pos
  0002    | CallFunctionConstant 31: @input.offset
  0004    | Destructure 0: Pos
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 32: @at
  0011    | GetBoundLocalMove 1
  0013    | GetBoundLocalMove 0
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ==============end_of_input==============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 8: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 10: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 33: succeed
  0013    | End
  ========================================
  
  ================succeed=================
  succeed = const($null)
  ========================================
  0000    | GetConstant 34: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  =================spaces=================
  spaces = many(space)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 12: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================newlines================
  newlines = many(newline)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================digit==================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  =================@fn73==================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 38: _number_integer_part
  0011    | Merge
  0012    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 36: @fn73
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushCharVar N
  0002    | CallFunctionLocal 0
  0004    | Destructure 1: "%(0 + N)"
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 1
  0011    | End
  ========================================
  
  =================maybe==================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 33: succeed
  0008    | End
  ========================================
  
  ==========_number_integer_part==========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 10
  0007    | CallFunctionConstant 39: numerals
  0009    | Merge
  0010    | Or 10 -> 15
  0013    | CallTailFunctionConstant 4: numeral
  0015    | End
  ========================================
  
  ==========non_negative_integer==========
  non_negative_integer = as_number(_number_integer_part)
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 38: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn78==================
  "-" + _number_integer_part
  ========================================
  0000    | ParseChar '-'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 38: _number_integer_part
  0007    | Merge
  0008    | End
  ========================================
  
  ============negative_integer============
  negative_integer = as_number("-" + _number_integer_part)
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 40: @fn78
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn80==================
  maybe("-") + _number_integer_part + _number_fraction_part
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 38: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 18
  0015    | CallFunctionConstant 42: _number_fraction_part
  0017    | Merge
  0018    | End
  ========================================
  
  =================float==================
  float = as_number(maybe("-") + _number_integer_part + _number_fraction_part)
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 41: @fn80
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========_number_fraction_part==========
  _number_fraction_part = "." + numerals
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 39: numerals
  0007    | Merge
  0008    | End
  ========================================
  
  =================@fn83==================
  maybe("-") +
    _number_integer_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 38: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 18
  0015    | CallFunctionConstant 44: _number_exponent_part
  0017    | Merge
  0018    | End
  ========================================
  
  ===========scientific_integer===========
  scientific_integer = as_number(
    maybe("-") +
    _number_integer_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 43: @fn83
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn85==================
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
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 37: maybe
  0013    | GetConstant 45: @fn85
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 24
  0021    | CallFunctionConstant 39: numerals
  0023    | Merge
  0024    | End
  ========================================
  
  =================@fn87==================
  maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 38: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 18
  0015    | CallFunctionConstant 42: _number_fraction_part
  0017    | Merge
  0018    | JumpIfFailure 18 -> 24
  0021    | CallFunctionConstant 44: _number_exponent_part
  0023    | Merge
  0024    | End
  ========================================
  
  ============scientific_float============
  scientific_float = as_number(
    maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  )
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 46: @fn87
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn89==================
  maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '-'
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 38: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 37: maybe
  0017    | GetConstant 42: _number_fraction_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 32
  0025    | GetConstant 37: maybe
  0027    | GetConstant 44: _number_exponent_part
  0029    | CallFunction 1
  0031    | Merge
  0032    | End
  ========================================
  
  =================number=================
  number = as_number(
    maybe("-") +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 47: @fn89
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn91==================
  _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | CallFunctionConstant 38: _number_integer_part
  0002    | JumpIfFailure 2 -> 12
  0005    | GetConstant 37: maybe
  0007    | GetConstant 42: _number_fraction_part
  0009    | CallFunction 1
  0011    | Merge
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 37: maybe
  0017    | GetConstant 44: _number_exponent_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | End
  ========================================
  
  ==========non_negative_number===========
  non_negative_number = as_number(
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 48: @fn91
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn93==================
  "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | ParseChar '-'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 38: _number_integer_part
  0007    | Merge
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 37: maybe
  0013    | GetConstant 42: _number_fraction_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 28
  0021    | GetConstant 37: maybe
  0023    | GetConstant 44: _number_exponent_part
  0025    | CallFunction 1
  0027    | Merge
  0028    | End
  ========================================
  
  ============negative_number=============
  negative_number = as_number(
    "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  )
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant 49: @fn93
  0004    | CallTailFunction 1
  0006    | End
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
  0001    | CallFunctionConstant 50: digit
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
  
  =============binary_integer=============
  binary_integer = array(binary_digit) -> Digits $ Num.FromBinaryDigits(Digits)
  ========================================
  0000    | GetConstant 51: Digits
  0002    | GetConstant 52: array
  0004    | GetConstant 53: binary_digit
  0006    | CallFunction 1
  0008    | Destructure 2: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 54: Num.FromBinaryDigits
  0015    | GetBoundLocalMove 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  =================array==================
  array(elem) = tuple1(elem) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 25
  0006    | Swap
  0007    | GetConstant 55: tuple1
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
  0027    | GetConstant 55: tuple1
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
  
  =================tuple1=================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | GetConstant 56: Elem
  0002    | CallFunctionLocal 0
  0004    | Destructure 3: Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 57: [_]
  0011    | GetBoundLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
  ========================================
  
  ==========Num.FromBinaryDigits==========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | GetConstant 58: Len
  0002    | GetConstant 59: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 4: Len
  0010    | TakeRight 10 -> 27
  0013    | GetConstant 60: _Num.FromBinaryDigits
  0015    | GetBoundLocalMove 0
  0017    | GetBoundLocalMove 1
  0019    | JumpIfFailure 19 -> 24
  0022    | PushNumberNegOne
  0023    | Merge
  0024    | PushNumberZero
  0025    | CallTailFunction 3
  0027    | End
  ========================================
  
  ==============Array.Length==============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar L
  0003    | GetBoundLocalMove 0
  0005    | Destructure 5: ([_] * L)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 2
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
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 6: ([B] + Rest)
  0009    | ConditionalThen 9 -> 54
  0012    | GetBoundLocal 3
  0014    | Destructure 7: 0..1
  0016    | TakeRight 16 -> 51
  0019    | GetConstant 60: _Num.FromBinaryDigits
  0021    | GetBoundLocalMove 4
  0023    | GetBoundLocal 1
  0025    | JumpIfFailure 25 -> 30
  0028    | PushNumberNegOne
  0029    | Merge
  0030    | GetBoundLocalMove 2
  0032    | JumpIfFailure 32 -> 49
  0035    | GetConstant 62: @Multiply
  0037    | GetBoundLocalMove 3
  0039    | GetConstant 63: @Power
  0041    | PushNumberTwo
  0042    | GetBoundLocalMove 1
  0044    | CallFunction 2
  0046    | CallFunction 2
  0048    | Merge
  0049    | CallTailFunction 3
  0051    | Jump 51 -> 56
  0054    | GetBoundLocalMove 2
  0056    | End
  ========================================
  
  =============octal_integer==============
  octal_integer = array(octal_digit) -> Digits $ Num.FromOctalDigits(Digits)
  ========================================
  0000    | GetConstant 51: Digits
  0002    | GetConstant 52: array
  0004    | GetConstant 64: octal_digit
  0006    | CallFunction 1
  0008    | Destructure 8: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 65: Num.FromOctalDigits
  0015    | GetBoundLocalMove 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  ==========Num.FromOctalDigits===========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | GetConstant 58: Len
  0002    | GetConstant 59: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 9: Len
  0010    | TakeRight 10 -> 27
  0013    | GetConstant 66: _Num.FromOctalDigits
  0015    | GetBoundLocalMove 0
  0017    | GetBoundLocalMove 1
  0019    | JumpIfFailure 19 -> 24
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
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 10: ([O] + Rest)
  0009    | ConditionalThen 9 -> 55
  0012    | GetBoundLocal 3
  0014    | Destructure 11: 0..7
  0016    | TakeRight 16 -> 52
  0019    | GetConstant 66: _Num.FromOctalDigits
  0021    | GetBoundLocalMove 4
  0023    | GetBoundLocal 1
  0025    | JumpIfFailure 25 -> 30
  0028    | PushNumberNegOne
  0029    | Merge
  0030    | GetBoundLocalMove 2
  0032    | JumpIfFailure 32 -> 50
  0035    | GetConstant 62: @Multiply
  0037    | GetBoundLocalMove 3
  0039    | GetConstant 63: @Power
  0041    | PushNumber 8
  0043    | GetBoundLocalMove 1
  0045    | CallFunction 2
  0047    | CallFunction 2
  0049    | Merge
  0050    | CallTailFunction 3
  0052    | Jump 52 -> 57
  0055    | GetBoundLocalMove 2
  0057    | End
  ========================================
  
  ==============hex_integer===============
  hex_integer = array(hex_digit) -> Digits $ Num.FromHexDigits(Digits)
  ========================================
  0000    | GetConstant 51: Digits
  0002    | GetConstant 52: array
  0004    | GetConstant 67: hex_digit
  0006    | CallFunction 1
  0008    | Destructure 12: Digits
  0010    | TakeRight 10 -> 19
  0013    | GetConstant 68: Num.FromHexDigits
  0015    | GetBoundLocalMove 0
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  ===========Num.FromHexDigits============
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | GetConstant 58: Len
  0002    | GetConstant 59: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | Destructure 13: Len
  0010    | TakeRight 10 -> 27
  0013    | GetConstant 69: _Num.FromHexDigits
  0015    | GetBoundLocalMove 0
  0017    | GetBoundLocalMove 1
  0019    | JumpIfFailure 19 -> 24
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
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 14: ([H] + Rest)
  0009    | ConditionalThen 9 -> 55
  0012    | GetBoundLocal 3
  0014    | Destructure 15: 0..15
  0016    | TakeRight 16 -> 52
  0019    | GetConstant 69: _Num.FromHexDigits
  0021    | GetBoundLocalMove 4
  0023    | GetBoundLocal 1
  0025    | JumpIfFailure 25 -> 30
  0028    | PushNumberNegOne
  0029    | Merge
  0030    | GetBoundLocalMove 2
  0032    | JumpIfFailure 32 -> 50
  0035    | GetConstant 62: @Multiply
  0037    | GetBoundLocalMove 3
  0039    | GetConstant 63: @Power
  0041    | PushNumber 16
  0043    | GetBoundLocalMove 1
  0045    | CallFunction 2
  0047    | CallFunction 2
  0049    | Merge
  0050    | CallTailFunction 3
  0052    | Jump 52 -> 57
  0055    | GetBoundLocalMove 2
  0057    | End
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
  
  ================boolean=================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 70: true
  0003    | GetBoundLocalMove 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 71: false
  0012    | GetBoundLocalMove 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ==================null==================
  null(n) = n $ null
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushNull
  0006    | End
  ========================================
  
  =================@fn115=================
  sep > elem
  ========================================
  0000    | GetConstant 73: sep
  0002    | GetConstant 74: elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  =================@fn116=================
  sep > elem
  ========================================
  0000    | GetConstant 73: sep
  0002    | GetConstant 74: elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  ===============array_sep================
  array_sep(elem, sep) = tuple1(elem) + (tuple1(sep > elem) * 0..)
  ========================================
  0000    | GetConstant 55: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 67
  0009    | PushNull
  0010    | PushNumberZero
  0011    | ValidateRepeatPattern
  0012    | JumpIfZero 12 -> 40
  0015    | Swap
  0016    | GetConstant 55: tuple1
  0018    | GetConstant 72: @fn115
  0020    | CreateClosure 2
  0022    | CaptureLocal 1
  0024    | CaptureLocal 0
  0026    | CallFunction 1
  0028    | Merge
  0029    | JumpIfFailure 29 -> 64
  0032    | Swap
  0033    | Decrement
  0034    | JumpIfZero 34 -> 40
  0037    | JumpBack 37 -> 15
  0040    | Swap
  0041    | SetInputMark
  0042    | GetConstant 55: tuple1
  0044    | GetConstant 75: @fn116
  0046    | CreateClosure 2
  0048    | CaptureLocal 1
  0050    | CaptureLocal 0
  0052    | CallFunction 1
  0054    | JumpIfFailure 54 -> 62
  0057    | PopInputMark
  0058    | Merge
  0059    | JumpBack 59 -> 41
  0062    | ResetInput
  0063    | Drop
  0064    | Swap
  0065    | Drop
  0066    | Merge
  0067    | End
  ========================================
  
  =================@fn118=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 74: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 55: tuple1
  0005    | GetBoundLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn119=================
  tuple1(elem)
  ========================================
  0000    | GetConstant 74: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 55: tuple1
  0005    | GetBoundLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============array_until===============
  array_until(elem, stop) = unless(tuple1(elem), stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 31
  0006    | Swap
  0007    | GetConstant 7: unless
  0009    | GetConstant 76: @fn118
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
  0035    | GetConstant 77: @fn119
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
  0060    | GetConstant 29: peek
  0062    | GetBoundLocalMove 1
  0064    | CallFunction 1
  0066    | TakeLeft
  0067    | End
  ========================================
  
  =================@fn122=================
  array(elem)
  ========================================
  0000    | GetConstant 74: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 52: array
  0005    | GetBoundLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  maybe_array(elem) = default(array(elem), [])
  ========================================
  0000    | GetConstant 78: default
  0002    | GetConstant 79: @fn122
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | PushEmptyArray
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ================default=================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 12
  0006    | GetConstant 34: const
  0008    | GetBoundLocalMove 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  =================@fn124=================
  array_sep(elem, sep)
  ========================================
  0000    | GetConstant 74: elem
  0002    | GetConstant 73: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 81: array_sep
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  maybe_array_sep(elem, sep) = default(array_sep(elem, sep), [])
  ========================================
  0000    | GetConstant 78: default
  0002    | GetConstant 80: @fn124
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyArray
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================tuple2=================
  tuple2(elem1, elem2) = elem1 -> E1 & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 82: E1
  0002    | GetConstant 83: E2
  0004    | CallFunctionLocal 0
  0006    | Destructure 16: E1
  0008    | TakeRight 8 -> 28
  0011    | CallFunctionLocal 1
  0013    | Destructure 17: E2
  0015    | TakeRight 15 -> 28
  0018    | GetConstantMutable 84: [_, _]
  0020    | GetBoundLocalMove 2
  0022    | InsertAtIndex 0
  0024    | GetBoundLocalMove 3
  0026    | InsertAtIndex 1
  0028    | End
  ========================================
  
  ===============tuple2_sep===============
  tuple2_sep(elem1, sep, elem2) = elem1 -> E1 & sep & elem2 -> E2 $ [E1, E2]
  ========================================
  0000    | GetConstant 82: E1
  0002    | GetConstant 83: E2
  0004    | CallFunctionLocal 0
  0006    | Destructure 18: E1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 1
  0013    | TakeRight 13 -> 33
  0016    | CallFunctionLocal 2
  0018    | Destructure 19: E2
  0020    | TakeRight 20 -> 33
  0023    | GetConstantMutable 85: [_, _]
  0025    | GetBoundLocalMove 3
  0027    | InsertAtIndex 0
  0029    | GetBoundLocalMove 4
  0031    | InsertAtIndex 1
  0033    | End
  ========================================
  
  =================tuple3=================
  tuple3(elem1, elem2, elem3) =
    elem1 -> E1 &
    elem2 -> E2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | GetConstant 82: E1
  0002    | GetConstant 83: E2
  0004    | GetConstant 86: E3
  0006    | CallFunctionLocal 0
  0008    | Destructure 20: E1
  0010    | TakeRight 10 -> 17
  0013    | CallFunctionLocal 1
  0015    | Destructure 21: E2
  0017    | TakeRight 17 -> 41
  0020    | CallFunctionLocal 2
  0022    | Destructure 22: E3
  0024    | TakeRight 24 -> 41
  0027    | GetConstantMutable 87: [_, _, _]
  0029    | GetBoundLocalMove 3
  0031    | InsertAtIndex 0
  0033    | GetBoundLocalMove 4
  0035    | InsertAtIndex 1
  0037    | GetBoundLocalMove 5
  0039    | InsertAtIndex 2
  0041    | End
  ========================================
  
  ===============tuple3_sep===============
  tuple3_sep(elem1, sep1, elem2, sep2, elem3) =
    elem1 -> E1 & sep1 &
    elem2 -> E2 & sep2 &
    elem3 -> E3 $
    [E1, E2, E3]
  ========================================
  0000    | GetConstant 82: E1
  0002    | GetConstant 83: E2
  0004    | GetConstant 86: E3
  0006    | CallFunctionLocal 0
  0008    | Destructure 23: E1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 22
  0018    | CallFunctionLocal 2
  0020    | Destructure 24: E2
  0022    | TakeRight 22 -> 27
  0025    | CallFunctionLocal 3
  0027    | TakeRight 27 -> 51
  0030    | CallFunctionLocal 4
  0032    | Destructure 25: E3
  0034    | TakeRight 34 -> 51
  0037    | GetConstantMutable 88: [_, _, _]
  0039    | GetBoundLocalMove 5
  0041    | InsertAtIndex 0
  0043    | GetBoundLocalMove 6
  0045    | InsertAtIndex 1
  0047    | GetBoundLocalMove 7
  0049    | InsertAtIndex 2
  0051    | End
  ========================================
  
  =================tuple==================
  tuple(elem, N) = tuple1(elem) * N
  ========================================
  0000    | PushNull
  0001    | GetBoundLocalMove 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 27
  0007    | Swap
  0008    | GetConstant 55: tuple1
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
  
  =================@fn135=================
  sep > elem
  ========================================
  0000    | GetConstant 73: sep
  0002    | GetConstant 74: elem
  0004    | SetClosureCaptures
  0005    | CallFunctionLocal 0
  0007    | TakeRight 7 -> 12
  0010    | CallTailFunctionLocal 1
  0012    | End
  ========================================
  
  ===============tuple_sep================
  tuple_sep(elem, sep, N) = tuple1(elem) + (tuple1(sep > elem) * (N - 1))
  ========================================
  0000    | GetConstant 55: tuple1
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 49
  0009    | PushNull
  0010    | GetBoundLocalMove 2
  0012    | JumpIfFailure 12 -> 17
  0015    | PushNumberNegOne
  0016    | Merge
  0017    | ValidateRepeatPattern
  0018    | JumpIfZero 18 -> 47
  0021    | Swap
  0022    | GetConstant 55: tuple1
  0024    | GetConstant 89: @fn135
  0026    | CreateClosure 2
  0028    | CaptureLocal 1
  0030    | CaptureLocal 0
  0032    | CallFunction 1
  0034    | Merge
  0035    | JumpIfFailure 35 -> 46
  0038    | Swap
  0039    | Decrement
  0040    | JumpIfZero 40 -> 47
  0043    | JumpBack 43 -> 21
  0046    | Swap
  0047    | Drop
  0048    | Merge
  0049    | End
  ========================================
  
  =================@fn137=================
  array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 74: elem
  0002    | GetConstant 91: col_sep
  0004    | SetClosureCaptures
  0005    | GetConstant 81: array_sep
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn138=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 93: row_sep
  0002    | GetConstant 74: elem
  0004    | GetConstant 91: col_sep
  0006    | SetClosureCaptures
  0007    | CallFunctionLocal 0
  0009    | TakeRight 9 -> 20
  0012    | GetConstant 81: array_sep
  0014    | GetBoundLocalMove 1
  0016    | GetBoundLocalMove 2
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  =================@fn139=================
  row_sep > array_sep(elem, col_sep)
  ========================================
  0000    | GetConstant 93: row_sep
  0002    | GetConstant 74: elem
  0004    | GetConstant 91: col_sep
  0006    | SetClosureCaptures
  0007    | CallFunctionLocal 0
  0009    | TakeRight 9 -> 20
  0012    | GetConstant 81: array_sep
  0014    | GetBoundLocalMove 1
  0016    | GetBoundLocalMove 2
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ==================rows==================
  rows(elem, col_sep, row_sep) =
    tuple1(array_sep(elem, col_sep)) +
    (tuple1(row_sep > array_sep(elem, col_sep)) * 0..)
  ========================================
  0000    | GetConstant 55: tuple1
  0002    | GetConstant 90: @fn137
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 77
  0015    | PushNull
  0016    | PushNumberZero
  0017    | ValidateRepeatPattern
  0018    | JumpIfZero 18 -> 48
  0021    | Swap
  0022    | GetConstant 55: tuple1
  0024    | GetConstant 92: @fn138
  0026    | CreateClosure 3
  0028    | CaptureLocal 2
  0030    | CaptureLocal 0
  0032    | CaptureLocal 1
  0034    | CallFunction 1
  0036    | Merge
  0037    | JumpIfFailure 37 -> 74
  0040    | Swap
  0041    | Decrement
  0042    | JumpIfZero 42 -> 48
  0045    | JumpBack 45 -> 21
  0048    | Swap
  0049    | SetInputMark
  0050    | GetConstant 55: tuple1
  0052    | GetConstant 94: @fn139
  0054    | CreateClosure 3
  0056    | CaptureLocal 2
  0058    | CaptureLocal 0
  0060    | CaptureLocal 1
  0062    | CallFunction 1
  0064    | JumpIfFailure 64 -> 72
  0067    | PopInputMark
  0068    | Merge
  0069    | JumpBack 69 -> 49
  0072    | ResetInput
  0073    | Drop
  0074    | Swap
  0075    | Drop
  0076    | Merge
  0077    | End
  ========================================
  
  =================@fn142=================
  _dimensions(elem, col_sep, row_sep)
  ========================================
  0000    | GetConstant 74: elem
  0002    | GetConstant 91: col_sep
  0004    | GetConstant 93: row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 98: _dimensions
  0009    | GetBoundLocalMove 0
  0011    | GetBoundLocalMove 1
  0013    | GetBoundLocalMove 2
  0015    | CallTailFunction 3
  0017    | End
  ========================================
  
  ==============rows_padded===============
  rows_padded(elem, col_sep, row_sep, Pad) =
    peek(_dimensions(elem, col_sep, row_sep)) -> [MaxRowLen, _] &
    elem -> First & _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [First], [])
  ========================================
  0000    | GetConstant 95: MaxRowLen
  0002    | PushUnderscoreVar
  0003    | GetConstant 96: First
  0005    | GetConstant 29: peek
  0007    | GetConstant 97: @fn142
  0009    | CreateClosure 3
  0011    | CaptureLocal 0
  0013    | CaptureLocal 1
  0015    | CaptureLocal 2
  0017    | CallFunction 1
  0019    | Destructure 26: [MaxRowLen, _]
  0021    | TakeRight 21 -> 28
  0024    | CallFunctionLocal 0
  0026    | Destructure 27: First
  0028    | TakeRight 28 -> 53
  0031    | GetConstant 99: _rows_padded
  0033    | GetBoundLocalMove 0
  0035    | GetBoundLocalMove 1
  0037    | GetBoundLocalMove 2
  0039    | GetBoundLocalMove 3
  0041    | PushNumberOne
  0042    | GetBoundLocalMove 4
  0044    | GetConstantMutable 100: [_]
  0046    | GetBoundLocalMove 6
  0048    | InsertAtIndex 0
  0050    | PushEmptyArray
  0051    | CallTailFunction 8
  0053    | End
  ========================================
  
  ==============_dimensions===============
  _dimensions(elem, col_sep, row_sep) =
    elem > __dimensions(elem, col_sep, row_sep, $1, $1, $0)
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 18
  0005    | GetConstant 101: __dimensions
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | GetBoundLocalMove 2
  0013    | PushNumberOne
  0014    | PushNumberOne
  0015    | PushNumberZero
  0016    | CallTailFunction 6
  0018    | End
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
  0008    | ConditionalThen 8 -> 34
  0011    | GetConstant 101: __dimensions
  0013    | GetBoundLocalMove 0
  0015    | GetBoundLocalMove 1
  0017    | GetBoundLocalMove 2
  0019    | GetConstant 102: Num.Inc
  0021    | GetBoundLocalMove 3
  0023    | CallFunction 1
  0025    | GetBoundLocalMove 4
  0027    | GetBoundLocalMove 5
  0029    | CallTailFunction 6
  0031    | Jump 31 -> 93
  0034    | SetInputMark
  0035    | CallFunctionLocal 2
  0037    | TakeRight 37 -> 42
  0040    | CallFunctionLocal 0
  0042    | ConditionalThen 42 -> 73
  0045    | GetConstant 101: __dimensions
  0047    | GetBoundLocalMove 0
  0049    | GetBoundLocalMove 1
  0051    | GetBoundLocalMove 2
  0053    | PushNumberOne
  0054    | GetConstant 102: Num.Inc
  0056    | GetBoundLocalMove 4
  0058    | CallFunction 1
  0060    | GetConstant 103: Num.Max
  0062    | GetBoundLocalMove 3
  0064    | GetBoundLocalMove 5
  0066    | CallFunction 2
  0068    | CallTailFunction 6
  0070    | Jump 70 -> 93
  0073    | GetConstant 34: const
  0075    | GetConstantMutable 104: [_, _]
  0077    | GetConstant 103: Num.Max
  0079    | GetBoundLocalMove 3
  0081    | GetBoundLocalMove 5
  0083    | CallFunction 2
  0085    | InsertAtIndex 0
  0087    | GetBoundLocalMove 4
  0089    | InsertAtIndex 1
  0091    | CallTailFunction 1
  0093    | End
  ========================================
  
  ================Num.Inc=================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant 105: @Add
  0002    | GetBoundLocalMove 0
  0004    | PushNumberOne
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ================Num.Max=================
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
  
  ==============_rows_padded==============
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    col_sep > elem -> Elem ?
    _rows_padded(elem, col_sep, row_sep, Pad, Num.Inc(RowLen), MaxRowLen, [...AccRow, Elem], AccRows) :
    row_sep > elem -> NextRow ?
    _rows_padded(elem, col_sep, row_sep, Pad, $1, MaxRowLen, [NextRow], [...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)]) :
    const([...AccRows, Array.AppendN(AccRow, Pad, MaxRowLen - RowLen)])
  ========================================
  0000    | GetConstant 56: Elem
  0002    | GetConstant 106: NextRow
  0004    | SetInputMark
  0005    | CallFunctionLocal 1
  0007    | TakeRight 7 -> 12
  0010    | CallFunctionLocal 0
  0012    | Destructure 29: Elem
  0014    | ConditionalThen 14 -> 59
  0017    | GetConstant 99: _rows_padded
  0019    | GetBoundLocalMove 0
  0021    | GetBoundLocalMove 1
  0023    | GetBoundLocalMove 2
  0025    | GetBoundLocalMove 3
  0027    | GetConstant 102: Num.Inc
  0029    | GetBoundLocalMove 4
  0031    | CallFunction 1
  0033    | GetBoundLocalMove 5
  0035    | PushEmptyArray
  0036    | JumpIfFailure 36 -> 42
  0039    | GetBoundLocalMove 6
  0041    | Merge
  0042    | JumpIfFailure 42 -> 52
  0045    | GetConstantMutable 107: [_]
  0047    | GetBoundLocalMove 8
  0049    | InsertAtIndex 0
  0051    | Merge
  0052    | GetBoundLocalMove 7
  0054    | CallTailFunction 8
  0056    | Jump 56 -> 164
  0059    | SetInputMark
  0060    | CallFunctionLocal 2
  0062    | TakeRight 62 -> 67
  0065    | CallFunctionLocal 0
  0067    | Destructure 30: NextRow
  0069    | ConditionalThen 69 -> 128
  0072    | GetConstant 99: _rows_padded
  0074    | GetBoundLocalMove 0
  0076    | GetBoundLocalMove 1
  0078    | GetBoundLocalMove 2
  0080    | GetBoundLocal 3
  0082    | PushNumberOne
  0083    | GetBoundLocal 5
  0085    | GetConstantMutable 108: [_]
  0087    | GetBoundLocalMove 9
  0089    | InsertAtIndex 0
  0091    | PushEmptyArray
  0092    | JumpIfFailure 92 -> 98
  0095    | GetBoundLocalMove 7
  0097    | Merge
  0098    | JumpIfFailure 98 -> 123
  0101    | GetConstantMutable 109: [_]
  0103    | GetConstant 110: Array.AppendN
  0105    | GetBoundLocalMove 6
  0107    | GetBoundLocalMove 3
  0109    | GetBoundLocalMove 5
  0111    | JumpIfFailure 111 -> 118
  0114    | GetBoundLocalMove 4
  0116    | NegateNumber
  0117    | Merge
  0118    | CallFunction 3
  0120    | InsertAtIndex 0
  0122    | Merge
  0123    | CallTailFunction 8
  0125    | Jump 125 -> 164
  0128    | GetConstant 34: const
  0130    | PushEmptyArray
  0131    | JumpIfFailure 131 -> 137
  0134    | GetBoundLocalMove 7
  0136    | Merge
  0137    | JumpIfFailure 137 -> 162
  0140    | GetConstantMutable 111: [_]
  0142    | GetConstant 110: Array.AppendN
  0144    | GetBoundLocalMove 6
  0146    | GetBoundLocalMove 3
  0148    | GetBoundLocalMove 5
  0150    | JumpIfFailure 150 -> 157
  0153    | GetBoundLocalMove 4
  0155    | NegateNumber
  0156    | Merge
  0157    | CallFunction 3
  0159    | InsertAtIndex 0
  0161    | Merge
  0162    | CallTailFunction 1
  0164    | End
  ========================================
  
  =============Array.AppendN==============
  Array.AppendN(A, Val, N) = A + ([Val] * N)
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstantMutable 112: [_]
  0007    | GetBoundLocalMove 1
  0009    | InsertAtIndex 0
  0011    | GetBoundLocalMove 2
  0013    | RepeatValue
  0014    | Merge
  0015    | End
  ========================================
  
  ================columns=================
  columns(elem, col_sep, row_sep) =
    rows(elem, col_sep, row_sep) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant 113: Rows
  0002    | GetConstant 114: rows
  0004    | GetBoundLocalMove 0
  0006    | GetBoundLocalMove 1
  0008    | GetBoundLocalMove 2
  0010    | CallFunction 3
  0012    | Destructure 31: Rows
  0014    | TakeRight 14 -> 23
  0017    | GetConstant 115: Table.Transpose
  0019    | GetBoundLocalMove 3
  0021    | CallTailFunction 1
  0023    | End
  ========================================
  
  ============Table.Transpose=============
  Table.Transpose(T) = _Table.Transpose(T, [])
  ========================================
  0000    | GetConstant 116: _Table.Transpose
  0002    | GetBoundLocalMove 0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
  ========================================
  
  ============_Table.Transpose============
  _Table.Transpose(T, Acc) =
    _Table.FirstPerRow(T) -> FirstPerRow &
    _Table.RestPerRow(T) -> RestPerRow ?
    _Table.Transpose(RestPerRow, [...Acc, FirstPerRow]) :
    Acc
  ========================================
  0000    | GetConstant 117: FirstPerRow
  0002    | GetConstant 118: RestPerRow
  0004    | SetInputMark
  0005    | GetConstant 119: _Table.FirstPerRow
  0007    | GetBoundLocal 0
  0009    | CallFunction 1
  0011    | Destructure 32: FirstPerRow
  0013    | TakeRight 13 -> 24
  0016    | GetConstant 120: _Table.RestPerRow
  0018    | GetBoundLocalMove 0
  0020    | CallFunction 1
  0022    | Destructure 33: RestPerRow
  0024    | ConditionalThen 24 -> 53
  0027    | GetConstant 116: _Table.Transpose
  0029    | GetBoundLocalMove 3
  0031    | PushEmptyArray
  0032    | JumpIfFailure 32 -> 38
  0035    | GetBoundLocalMove 1
  0037    | Merge
  0038    | JumpIfFailure 38 -> 48
  0041    | GetConstantMutable 121: [_]
  0043    | GetBoundLocalMove 2
  0045    | InsertAtIndex 0
  0047    | Merge
  0048    | CallTailFunction 2
  0050    | Jump 50 -> 55
  0053    | GetBoundLocalMove 1
  0055    | End
  ========================================
  
  ===========_Table.FirstPerRow===========
  _Table.FirstPerRow(T) =
    T -> [Row, ...Rest] & Row -> [VeryFirst, ..._] &
    __Table.FirstPerRow(Rest, [VeryFirst])
  ========================================
  0000    | GetConstant 122: Row
  0002    | GetConstant 61: Rest
  0004    | GetConstant 123: VeryFirst
  0006    | PushUnderscoreVar
  0007    | GetBoundLocalMove 0
  0009    | Destructure 34: ([Row] + Rest)
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocalMove 1
  0016    | Destructure 35: ([VeryFirst] + _)
  0018    | TakeRight 18 -> 33
  0021    | GetConstant 124: __Table.FirstPerRow
  0023    | GetBoundLocalMove 2
  0025    | GetConstantMutable 125: [_]
  0027    | GetBoundLocalMove 3
  0029    | InsertAtIndex 0
  0031    | CallTailFunction 2
  0033    | End
  ========================================
  
  ==========__Table.FirstPerRow===========
  __Table.FirstPerRow(T, Acc) =
    T -> [Row, ...Rest] & Row -> [First, ..._] ?
    __Table.FirstPerRow(Rest, [...Acc, First]) :
    Acc
  ========================================
  0000    | GetConstant 122: Row
  0002    | GetConstant 61: Rest
  0004    | GetConstant 96: First
  0006    | PushUnderscoreVar
  0007    | SetInputMark
  0008    | GetBoundLocalMove 0
  0010    | Destructure 36: ([Row] + Rest)
  0012    | TakeRight 12 -> 19
  0015    | GetBoundLocalMove 2
  0017    | Destructure 37: ([First] + _)
  0019    | ConditionalThen 19 -> 48
  0022    | GetConstant 124: __Table.FirstPerRow
  0024    | GetBoundLocalMove 3
  0026    | PushEmptyArray
  0027    | JumpIfFailure 27 -> 33
  0030    | GetBoundLocalMove 1
  0032    | Merge
  0033    | JumpIfFailure 33 -> 43
  0036    | GetConstantMutable 126: [_]
  0038    | GetBoundLocalMove 4
  0040    | InsertAtIndex 0
  0042    | Merge
  0043    | CallTailFunction 2
  0045    | Jump 45 -> 50
  0048    | GetBoundLocalMove 1
  0050    | End
  ========================================
  
  ===========_Table.RestPerRow============
  _Table.RestPerRow(T) = __Table.RestPerRow(T, [])
  ========================================
  0000    | GetConstant 127: __Table.RestPerRow
  0002    | GetBoundLocalMove 0
  0004    | PushEmptyArray
  0005    | CallTailFunction 2
  0007    | End
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
  0000    | GetConstant 122: Row
  0002    | GetConstant 61: Rest
  0004    | PushUnderscoreVar
  0005    | GetConstant 128: RowRest
  0007    | SetInputMark
  0008    | GetBoundLocalMove 0
  0010    | Destructure 38: ([Row] + Rest)
  0012    | ConditionalThen 12 -> 71
  0015    | SetInputMark
  0016    | GetBoundLocalMove 2
  0018    | Destructure 39: ([_] + RowRest)
  0020    | ConditionalThen 20 -> 49
  0023    | GetConstant 127: __Table.RestPerRow
  0025    | GetBoundLocalMove 3
  0027    | PushEmptyArray
  0028    | JumpIfFailure 28 -> 34
  0031    | GetBoundLocalMove 1
  0033    | Merge
  0034    | JumpIfFailure 34 -> 44
  0037    | GetConstantMutable 129: [_]
  0039    | GetBoundLocalMove 5
  0041    | InsertAtIndex 0
  0043    | Merge
  0044    | CallTailFunction 2
  0046    | Jump 46 -> 68
  0049    | GetConstant 127: __Table.RestPerRow
  0051    | GetBoundLocalMove 3
  0053    | PushEmptyArray
  0054    | JumpIfFailure 54 -> 60
  0057    | GetBoundLocalMove 1
  0059    | Merge
  0060    | JumpIfFailure 60 -> 66
  0063    | GetConstant 130: [[]]
  0065    | Merge
  0066    | CallTailFunction 2
  0068    | Jump 68 -> 73
  0071    | GetBoundLocalMove 1
  0073    | End
  ========================================
  
  =============columns_padded=============
  columns_padded(elem, col_sep, row_sep, Pad) =
    rows_padded(elem, col_sep, row_sep, Pad) -> Rows $
    Table.Transpose(Rows)
  ========================================
  0000    | GetConstant 113: Rows
  0002    | GetConstant 131: rows_padded
  0004    | GetBoundLocalMove 0
  0006    | GetBoundLocalMove 1
  0008    | GetBoundLocalMove 2
  0010    | GetBoundLocalMove 3
  0012    | CallFunction 4
  0014    | Destructure 40: Rows
  0016    | TakeRight 16 -> 25
  0019    | GetConstant 115: Table.Transpose
  0021    | GetBoundLocalMove 4
  0023    | CallTailFunction 1
  0025    | End
  ========================================
  
  =================object=================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 27
  0006    | Swap
  0007    | GetConstant 132: pair
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
  0029    | GetConstant 132: pair
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
  
  ==================pair==================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 41: K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | Destructure 42: V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 133: {_0_}
  0020    | GetBoundLocalMove 2
  0022    | GetBoundLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
  ========================================
  
  ===============object_sep===============
  object_sep(key, kv_sep, value, sep) =
    pair_sep(key, kv_sep, value) +
    ((sep > pair_sep(key, kv_sep, value)) * 0..)
  ========================================
  0000    | GetConstant 134: pair_sep
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | CallFunction 3
  0010    | JumpIfFailure 10 -> 77
  0013    | PushNull
  0014    | PushNumberZero
  0015    | ValidateRepeatPattern
  0016    | JumpIfZero 16 -> 47
  0019    | Swap
  0020    | CallFunctionLocal 3
  0022    | TakeRight 22 -> 35
  0025    | GetConstant 134: pair_sep
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 1
  0031    | GetBoundLocal 2
  0033    | CallFunction 3
  0035    | Merge
  0036    | JumpIfFailure 36 -> 74
  0039    | Swap
  0040    | Decrement
  0041    | JumpIfZero 41 -> 47
  0044    | JumpBack 44 -> 19
  0047    | Swap
  0048    | SetInputMark
  0049    | CallFunctionLocal 3
  0051    | TakeRight 51 -> 64
  0054    | GetConstant 134: pair_sep
  0056    | GetBoundLocal 0
  0058    | GetBoundLocal 1
  0060    | GetBoundLocal 2
  0062    | CallFunction 3
  0064    | JumpIfFailure 64 -> 72
  0067    | PopInputMark
  0068    | Merge
  0069    | JumpBack 69 -> 48
  0072    | ResetInput
  0073    | Drop
  0074    | Swap
  0075    | Drop
  0076    | Merge
  0077    | End
  ========================================
  
  ================pair_sep================
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 43: K
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 1
  0013    | TakeRight 13 -> 31
  0016    | CallFunctionLocal 2
  0018    | Destructure 44: V
  0020    | TakeRight 20 -> 31
  0023    | GetConstantMutable 135: {_0_}
  0025    | GetBoundLocalMove 3
  0027    | GetBoundLocalMove 4
  0029    | InsertKeyVal 0
  0031    | End
  ========================================
  
  =================@fn176=================
  pair(key, value)
  ========================================
  0000    | GetConstant 137: key
  0002    | GetConstant 138: value
  0004    | SetClosureCaptures
  0005    | GetConstant 132: pair
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn177=================
  pair(key, value)
  ========================================
  0000    | GetConstant 137: key
  0002    | GetConstant 138: value
  0004    | SetClosureCaptures
  0005    | GetConstant 132: pair
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============object_until==============
  object_until(key, value, stop) =
    unless(pair(key, value), stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushNumberOne
  0002    | ValidateRepeatPattern
  0003    | JumpIfZero 3 -> 33
  0006    | Swap
  0007    | GetConstant 7: unless
  0009    | GetConstant 136: @fn176
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
  0037    | GetConstant 139: @fn177
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
  0064    | GetConstant 29: peek
  0066    | GetBoundLocalMove 2
  0068    | CallFunction 1
  0070    | TakeLeft
  0071    | End
  ========================================
  
  =================@fn179=================
  object(key, value)
  ========================================
  0000    | GetConstant 137: key
  0002    | GetConstant 138: value
  0004    | SetClosureCaptures
  0005    | GetConstant 141: object
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  maybe_object(key, value) = default(object(key, value), {})
  ========================================
  0000    | GetConstant 78: default
  0002    | GetConstant 140: @fn179
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyObject
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn181=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | GetConstant 137: key
  0002    | GetConstant 143: pair_sep
  0004    | GetConstant 138: value
  0006    | GetConstant 73: sep
  0008    | SetClosureCaptures
  0009    | GetConstant 144: object_sep
  0011    | GetBoundLocalMove 0
  0013    | GetBoundLocalMove 1
  0015    | GetBoundLocalMove 2
  0017    | GetBoundLocalMove 3
  0019    | CallTailFunction 4
  0021    | End
  ========================================
  
  ============maybe_object_sep============
  maybe_object_sep(key, pair_sep, value, sep) =
    default(object_sep(key, pair_sep, value, sep), {})
  ========================================
  0000    | GetConstant 78: default
  0002    | GetConstant 142: @fn181
  0004    | CreateClosure 4
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CaptureLocal 2
  0012    | CaptureLocal 3
  0014    | PushEmptyObject
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ================record1=================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | GetConstant 145: Value
  0002    | CallFunctionLocal 1
  0004    | Destructure 45: Value
  0006    | TakeRight 6 -> 17
  0009    | GetConstantMutable 146: {_0_}
  0011    | GetBoundLocalMove 0
  0013    | GetBoundLocalMove 2
  0015    | InsertKeyVal 0
  0017    | End
  ========================================
  
  ================record2=================
  record2(Key1, value1, Key2, value2) =
    value1 -> V1 &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | GetConstant 147: V1
  0002    | GetConstant 148: V2
  0004    | CallFunctionLocal 1
  0006    | Destructure 46: V1
  0008    | TakeRight 8 -> 32
  0011    | CallFunctionLocal 3
  0013    | Destructure 47: V2
  0015    | TakeRight 15 -> 32
  0018    | GetConstantMutable 149: {_0_, _1_}
  0020    | GetBoundLocalMove 0
  0022    | GetBoundLocalMove 4
  0024    | InsertKeyVal 0
  0026    | GetBoundLocalMove 2
  0028    | GetBoundLocalMove 5
  0030    | InsertKeyVal 1
  0032    | End
  ========================================
  
  ==============record2_sep===============
  record2_sep(Key1, value1, sep, Key2, value2) =
    value1 -> V1 & sep &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | GetConstant 147: V1
  0002    | GetConstant 148: V2
  0004    | CallFunctionLocal 1
  0006    | Destructure 48: V1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 2
  0013    | TakeRight 13 -> 37
  0016    | CallFunctionLocal 4
  0018    | Destructure 49: V2
  0020    | TakeRight 20 -> 37
  0023    | GetConstantMutable 150: {_0_, _1_}
  0025    | GetBoundLocalMove 0
  0027    | GetBoundLocalMove 5
  0029    | InsertKeyVal 0
  0031    | GetBoundLocalMove 3
  0033    | GetBoundLocalMove 6
  0035    | InsertKeyVal 1
  0037    | End
  ========================================
  
  ================record3=================
  record3(Key1, value1, Key2, value2, Key3, value3) =
    value1 -> V1 &
    value2 -> V2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | GetConstant 147: V1
  0002    | GetConstant 148: V2
  0004    | GetConstant 151: V3
  0006    | CallFunctionLocal 1
  0008    | Destructure 50: V1
  0010    | TakeRight 10 -> 17
  0013    | CallFunctionLocal 3
  0015    | Destructure 51: V2
  0017    | TakeRight 17 -> 47
  0020    | CallFunctionLocal 5
  0022    | Destructure 52: V3
  0024    | TakeRight 24 -> 47
  0027    | GetConstantMutable 152: {_0_, _1_, _2_}
  0029    | GetBoundLocalMove 0
  0031    | GetBoundLocalMove 6
  0033    | InsertKeyVal 0
  0035    | GetBoundLocalMove 2
  0037    | GetBoundLocalMove 7
  0039    | InsertKeyVal 1
  0041    | GetBoundLocalMove 4
  0043    | GetBoundLocalMove 8
  0045    | InsertKeyVal 2
  0047    | End
  ========================================
  
  ==============record3_sep===============
  record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3) =
    value1 -> V1 & sep1 &
    value2 -> V2 & sep2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | GetConstant 147: V1
  0002    | GetConstant 148: V2
  0004    | GetConstant 151: V3
  0006    | CallFunctionLocal 1
  0008    | Destructure 53: V1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 2
  0015    | TakeRight 15 -> 22
  0018    | CallFunctionLocal 4
  0020    | Destructure 54: V2
  0022    | TakeRight 22 -> 27
  0025    | CallFunctionLocal 5
  0027    | TakeRight 27 -> 57
  0030    | CallFunctionLocal 7
  0032    | Destructure 55: V3
  0034    | TakeRight 34 -> 57
  0037    | GetConstantMutable 153: {_0_, _1_, _2_}
  0039    | GetBoundLocalMove 0
  0041    | GetBoundLocalMove 8
  0043    | InsertKeyVal 0
  0045    | GetBoundLocalMove 3
  0047    | GetBoundLocalMove 9
  0049    | InsertKeyVal 1
  0051    | GetBoundLocalMove 6
  0053    | GetBoundLocalMove 10
  0055    | InsertKeyVal 2
  0057    | End
  ========================================
  
  ================many_sep================
  many_sep(p, sep) = p + ((sep > p) * 0..)
  ========================================
  0000    | CallFunctionLocal 0
  0002    | JumpIfFailure 2 -> 53
  0005    | PushNull
  0006    | PushNumberZero
  0007    | ValidateRepeatPattern
  0008    | JumpIfZero 8 -> 31
  0011    | Swap
  0012    | CallFunctionLocal 1
  0014    | TakeRight 14 -> 19
  0017    | CallFunctionLocal 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 50
  0023    | Swap
  0024    | Decrement
  0025    | JumpIfZero 25 -> 31
  0028    | JumpBack 28 -> 11
  0031    | Swap
  0032    | SetInputMark
  0033    | CallFunctionLocal 1
  0035    | TakeRight 35 -> 40
  0038    | CallFunctionLocal 0
  0040    | JumpIfFailure 40 -> 48
  0043    | PopInputMark
  0044    | Merge
  0045    | JumpBack 45 -> 32
  0048    | ResetInput
  0049    | Drop
  0050    | Swap
  0051    | Drop
  0052    | Merge
  0053    | End
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
  
  =============maybe_many_sep=============
  maybe_many_sep(p, sep) = many_sep(p, sep) | succeed
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 154: many_sep
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | CallFunction 2
  0009    | Or 9 -> 14
  0012    | CallTailFunctionConstant 33: succeed
  0014    | End
  ========================================
  
  ==================skip==================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 155: null
  0002    | GetBoundLocalMove 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================find==================
  find(p) = p | (char > find(p))
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 17
  0006    | CallFunctionConstant 8: char
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 156: find
  0013    | GetBoundLocalMove 0
  0015    | CallTailFunction 1
  0017    | End
  ========================================
  
  =================@fn198=================
  find(p)
  ========================================
  0000    | PushCharVar p
  0002    | SetClosureCaptures
  0003    | GetConstant 156: find
  0005    | GetBoundLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn199=================
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
  0000    | GetConstant 52: array
  0002    | GetConstant 157: @fn198
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 20
  0013    | GetConstant 37: maybe
  0015    | GetConstant 158: @fn199
  0017    | CallFunction 1
  0019    | TakeLeft
  0020    | End
  ========================================
  
  ==============find_before===============
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
  0022    | GetConstant 159: find_before
  0024    | GetBoundLocalMove 0
  0026    | GetBoundLocalMove 1
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  =================@fn202=================
  find_before(p, stop)
  ========================================
  0000    | PushCharVar p
  0002    | GetConstant 161: stop
  0004    | SetClosureCaptures
  0005    | GetConstant 159: find_before
  0007    | GetBoundLocalMove 0
  0009    | GetBoundLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn203=================
  chars_until(stop)
  ========================================
  0000    | GetConstant 161: stop
  0002    | SetClosureCaptures
  0003    | GetConstant 25: chars_until
  0005    | GetBoundLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ============find_all_before=============
  find_all_before(p, stop) = array(find_before(p, stop)) < maybe(chars_until(stop))
  ========================================
  0000    | GetConstant 52: array
  0002    | GetConstant 160: @fn202
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 26
  0015    | GetConstant 37: maybe
  0017    | GetConstant 162: @fn203
  0019    | CreateClosure 1
  0021    | CaptureLocal 1
  0023    | CallFunction 1
  0025    | TakeLeft
  0026    | End
  ========================================
  
  ===============as_string================
  as_string(p) = "%(p)"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionLocal 0
  0003    | MergeAsString
  0004    | End
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
  
  =================@fn207=================
  maybe(whitespace)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  input(p) = surround(p, maybe(whitespace)) < end_of_input
  ========================================
  0000    | GetConstant 163: surround
  0002    | GetBoundLocalMove 0
  0004    | GetConstant 164: @fn207
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 14
  0011    | CallFunctionConstant 27: end_of_input
  0013    | TakeLeft
  0014    | End
  ========================================
  
  ==============one_or_both===============
  one_or_both(a, b) = (a + maybe(b)) | (maybe(a) + b)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | JumpIfFailure 3 -> 13
  0006    | GetConstant 37: maybe
  0008    | GetBoundLocal 1
  0010    | CallFunction 1
  0012    | Merge
  0013    | Or 13 -> 28
  0016    | GetConstant 37: maybe
  0018    | GetBoundLocalMove 0
  0020    | CallFunction 1
  0022    | JumpIfFailure 22 -> 28
  0025    | CallFunctionLocal 1
  0027    | Merge
  0028    | End
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
  0001    | CallFunctionConstant 165: json.boolean
  0003    | Or 3 -> 40
  0006    | SetInputMark
  0007    | CallFunctionConstant 166: json.null
  0009    | Or 9 -> 40
  0012    | SetInputMark
  0013    | CallFunctionConstant 167: number
  0015    | Or 15 -> 40
  0018    | SetInputMark
  0019    | CallFunctionConstant 168: json.string
  0021    | Or 21 -> 40
  0024    | SetInputMark
  0025    | GetConstant 169: json.array
  0027    | GetConstant 170: json
  0029    | CallFunction 1
  0031    | Or 31 -> 40
  0034    | GetConstant 171: json.object
  0036    | GetConstant 170: json
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  ==============json.boolean==============
  json.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 172: boolean
  0002    | GetConstant 173: "true"
  0004    | GetConstant 174: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============json.null================
  json.null = null("null")
  ========================================
  0000    | GetConstant 155: null
  0002    | GetConstant 175: "null"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============json.string===============
  json.string = '"' > _json.string_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 176: _json.string_body
  0007    | JumpIfFailure 7 -> 13
  0010    | ParseChar '"'
  0012    | TakeLeft
  0013    | End
  ========================================
  
  =================@fn219=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 181: _ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  =================@fn216=================
  _escaped_ctrl_char |
      _escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 178: _escaped_ctrl_char
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 179: _escaped_unicode
  0009    | Or 9 -> 20
  0012    | GetConstant 7: unless
  0014    | GetConstant 8: char
  0016    | GetConstant 180: @fn219
  0018    | CallTailFunction 2
  0020    | End
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
  0003    | GetConstant 177: @fn216
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 34: const
  0012    | PushEmptyString
  0013    | CallTailFunction 1
  0015    | End
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
  0001    | CallFunctionConstant 182: "\""
  0003    | TakeRight 3 -> 8
  0006    | PushChar '"'
  0008    | Or 8 -> 84
  0011    | SetInputMark
  0012    | CallFunctionConstant 183: "\\"
  0014    | TakeRight 14 -> 19
  0017    | PushChar '\'
  0019    | Or 19 -> 84
  0022    | SetInputMark
  0023    | CallFunctionConstant 184: "\/"
  0025    | TakeRight 25 -> 30
  0028    | PushChar '/'
  0030    | Or 30 -> 84
  0033    | SetInputMark
  0034    | CallFunctionConstant 185: "\b"
  0036    | TakeRight 36 -> 41
  0039    | PushChar '\x08' (esc)
  0041    | Or 41 -> 84
  0044    | SetInputMark
  0045    | CallFunctionConstant 186: "\f"
  0047    | TakeRight 47 -> 52
  0050    | PushChar '\x0c' (esc)
  0052    | Or 52 -> 84
  0055    | SetInputMark
  0056    | CallFunctionConstant 187: "\n"
  0058    | TakeRight 58 -> 63
  0061    | PushChar '
  '
  0063    | Or 63 -> 84
  0066    | SetInputMark
  0067    | CallFunctionConstant 188: "\r"
  0069    | TakeRight 69 -> 74
  0072    | PushChar '\r (no-eol) (esc)
  '
  0074    | Or 74 -> 84
  0077    | CallFunctionConstant 189: "\t"
  0079    | TakeRight 79 -> 84
  0082    | PushChar '\t' (esc)
  0084    | End
  ========================================
  
  ============_escaped_unicode============
  _escaped_unicode = _escaped_surrogate_pair | _escaped_codepoint
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 190: _escaped_surrogate_pair
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 191: _escaped_codepoint
  0008    | End
  ========================================
  
  ========_escaped_surrogate_pair=========
  _escaped_surrogate_pair = _valid_surrogate_pair | _invalid_surrogate_pair
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 192: _valid_surrogate_pair
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 193: _invalid_surrogate_pair
  0008    | End
  ========================================
  
  =========_valid_surrogate_pair==========
  _valid_surrogate_pair =
    _high_surrogate -> H & _low_surrogate -> L $ @SurrogatePairCodepoint(H, L)
  ========================================
  0000    | PushCharVar H
  0002    | PushCharVar L
  0004    | CallFunctionConstant 194: _high_surrogate
  0006    | Destructure 56: H
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionConstant 195: _low_surrogate
  0013    | Destructure 57: L
  0015    | TakeRight 15 -> 26
  0018    | GetConstant 196: @SurrogatePairCodepoint
  0020    | GetBoundLocalMove 0
  0022    | GetBoundLocalMove 1
  0024    | CallTailFunction 2
  0026    | End
  ========================================
  
  ============_high_surrogate=============
  _high_surrogate =
    `\u` > ("D" | "d") + ("8" | "9" | "A" | "B" | "a" | "b") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 197: "\u"
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
  0052    | CallFunctionConstant 198: hex_numeral
  0054    | Merge
  0055    | JumpIfFailure 55 -> 61
  0058    | CallFunctionConstant 198: hex_numeral
  0060    | Merge
  0061    | End
  ========================================
  
  =============_low_surrogate=============
  _low_surrogate =
    `\u` > ("D" | "d") + ("C".."F" | "c".."f") + hex_numeral + hex_numeral
  ========================================
  0000    | CallFunctionConstant 197: "\u"
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
  0030    | CallFunctionConstant 198: hex_numeral
  0032    | Merge
  0033    | JumpIfFailure 33 -> 39
  0036    | CallFunctionConstant 198: hex_numeral
  0038    | Merge
  0039    | End
  ========================================
  
  ========_invalid_surrogate_pair=========
  _invalid_surrogate_pair = _low_surrogate | _high_surrogate $ "\u00FFFD"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 195: _low_surrogate
  0003    | Or 3 -> 8
  0006    | CallFunctionConstant 194: _high_surrogate
  0008    | TakeRight 8 -> 13
  0011    | GetConstant 199: "\xef\xbf\xbd" (esc)
  0013    | End
  ========================================
  
  ===========_escaped_codepoint===========
  _escaped_codepoint = `\u` > (hex_numeral * 4) -> U $ @Codepoint(U)
  ========================================
  0000    | PushCharVar U
  0002    | CallFunctionConstant 197: "\u"
  0004    | TakeRight 4 -> 31
  0007    | PushNull
  0008    | PushNumber 4
  0010    | ValidateRepeatPattern
  0011    | JumpIfZero 11 -> 30
  0014    | Swap
  0015    | CallFunctionConstant 198: hex_numeral
  0017    | Merge
  0018    | JumpIfFailure 18 -> 29
  0021    | Swap
  0022    | Decrement
  0023    | JumpIfZero 23 -> 30
  0026    | JumpBack 26 -> 14
  0029    | Swap
  0030    | Drop
  0031    | Destructure 58: U
  0033    | TakeRight 33 -> 42
  0036    | GetConstant 200: @Codepoint
  0038    | GetBoundLocalMove 0
  0040    | CallTailFunction 1
  0042    | End
  ========================================
  
  ===============_ctrl_char===============
  _ctrl_char = "\u000000".."\u00001F"
  ========================================
  0000    | ParseCodepointRange '\x00'..'\x1f' (esc)
  0003    | End
  ========================================
  
  =================@fn228=================
  maybe(ws)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn227=================
  surround(elem, maybe(ws))
  ========================================
  0000    | GetConstant 74: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 163: surround
  0005    | GetBoundLocalMove 0
  0007    | GetConstant 203: @fn228
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===============json.array===============
  json.array(elem) = "[" > maybe_array_sep(surround(elem, maybe(ws)), ",") < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 17
  0005    | GetConstant 201: maybe_array_sep
  0007    | GetConstant 202: @fn227
  0009    | CreateClosure 1
  0011    | CaptureLocal 0
  0013    | PushChar ','
  0015    | CallFunction 2
  0017    | JumpIfFailure 17 -> 23
  0020    | ParseChar ']'
  0022    | TakeLeft
  0023    | End
  ========================================
  
  =================@fn230=================
  maybe(ws)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn229=================
  surround(json.string, maybe(ws))
  ========================================
  0000    | GetConstant 163: surround
  0002    | GetConstant 168: json.string
  0004    | GetConstant 206: @fn230
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn232=================
  maybe(ws)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn231=================
  surround(value, maybe(ws))
  ========================================
  0000    | GetConstant 138: value
  0002    | SetClosureCaptures
  0003    | GetConstant 163: surround
  0005    | GetBoundLocalMove 0
  0007    | GetConstant 208: @fn232
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
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 21
  0005    | GetConstant 204: maybe_object_sep
  0007    | GetConstant 205: @fn229
  0009    | PushChar ':'
  0011    | GetConstant 207: @fn231
  0013    | CreateClosure 1
  0015    | CaptureLocal 0
  0017    | PushChar ','
  0019    | CallFunction 4
  0021    | JumpIfFailure 21 -> 27
  0024    | ParseChar '}'
  0026    | TakeLeft
  0027    | End
  ========================================
  
  ==============toml.simple===============
  toml.simple = toml.custom(toml.simple_value)
  ========================================
  0000    | GetConstant 209: toml.custom
  0002    | GetConstant 210: toml.simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn239=================
  _toml.comments + maybe(ws)
  ========================================
  0000    | CallFunctionConstant 213: _toml.comments
  0002    | JumpIfFailure 2 -> 12
  0005    | GetConstant 37: maybe
  0007    | GetConstant 9: whitespace
  0009    | CallFunction 1
  0011    | Merge
  0012    | End
  ========================================
  
  =================@fn241=================
  maybe(ws) + _toml.comments
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 213: _toml.comments
  0011    | Merge
  0012    | End
  ========================================
  
  ==============toml.custom===============
  toml.custom(value) =
    maybe(_toml.comments + maybe(ws)) &
    _toml.with_root_table(value) | _toml.no_root_table(value) -> Doc &
    maybe(maybe(ws) + _toml.comments) $
    _Toml.Doc.Value(Doc)
  ========================================
  0000    | GetConstant 211: Doc
  0002    | GetConstant 37: maybe
  0004    | GetConstant 212: @fn239
  0006    | CallFunction 1
  0008    | TakeRight 8 -> 29
  0011    | SetInputMark
  0012    | GetConstant 214: _toml.with_root_table
  0014    | GetBoundLocal 0
  0016    | CallFunction 1
  0018    | Or 18 -> 27
  0021    | GetConstant 215: _toml.no_root_table
  0023    | GetBoundLocalMove 0
  0025    | CallFunction 1
  0027    | Destructure 59: Doc
  0029    | TakeRight 29 -> 47
  0032    | GetConstant 37: maybe
  0034    | GetConstant 216: @fn241
  0036    | CallFunction 1
  0038    | TakeRight 38 -> 47
  0041    | GetConstant 217: _Toml.Doc.Value
  0043    | GetBoundLocalMove 1
  0045    | CallTailFunction 1
  0047    | End
  ========================================
  
  =============_toml.comments=============
  _toml.comments = many_sep(_toml.comment, ws)
  ========================================
  0000    | GetConstant 154: many_sep
  0002    | GetConstant 218: _toml.comment
  0004    | GetConstant 9: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_toml.comment==============
  _toml.comment = "#" > maybe(line)
  ========================================
  0000    | ParseChar '#'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 37: maybe
  0007    | GetConstant 219: line
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  =========_toml.with_root_table==========
  _toml.with_root_table(value) =
    _toml.root_table(value, _Toml.Doc.Empty) -> RootDoc &
    (_toml.ws > _toml.tables(value, RootDoc)) | const(RootDoc)
  ========================================
  0000    | GetConstant 220: RootDoc
  0002    | GetConstant 221: _toml.root_table
  0004    | GetBoundLocal 0
  0006    | CallFunctionConstant 222: _Toml.Doc.Empty
  0008    | CallFunction 2
  0010    | Destructure 60: RootDoc
  0012    | TakeRight 12 -> 38
  0015    | SetInputMark
  0016    | CallFunctionConstant 223: _toml.ws
  0018    | TakeRight 18 -> 29
  0021    | GetConstant 224: _toml.tables
  0023    | GetBoundLocalMove 0
  0025    | GetBoundLocal 1
  0027    | CallFunction 2
  0029    | Or 29 -> 38
  0032    | GetConstant 34: const
  0034    | GetBoundLocalMove 1
  0036    | CallTailFunction 1
  0038    | End
  ========================================
  
  ============_toml.root_table============
  _toml.root_table(value, Doc) =
    _toml.table_body(value, [], Doc)
  ========================================
  0000    | GetConstant 225: _toml.table_body
  0002    | GetBoundLocalMove 0
  0004    | PushEmptyArray
  0005    | GetBoundLocalMove 1
  0007    | CallTailFunction 3
  0009    | End
  ========================================
  
  ============_toml.table_body============
  _toml.table_body(value, HeaderPath, Doc) =
    _toml.table_pair(value) -> [KeyPath, Val] & _toml.ws_newline &
    const(_Toml.Doc.InsertAtPath(Doc, HeaderPath + KeyPath, Val)) -> NewDoc &
    _toml.table_body(value, HeaderPath, NewDoc) | const(NewDoc)
  ========================================
  0000    | GetConstant 226: KeyPath
  0002    | GetConstant 227: Val
  0004    | GetConstant 228: NewDoc
  0006    | GetConstant 229: _toml.table_pair
  0008    | GetBoundLocal 0
  0010    | CallFunction 1
  0012    | Destructure 61: [KeyPath, Val]
  0014    | TakeRight 14 -> 19
  0017    | CallFunctionConstant 230: _toml.ws_newline
  0019    | TakeRight 19 -> 44
  0022    | GetConstant 34: const
  0024    | GetConstant 231: _Toml.Doc.InsertAtPath
  0026    | GetBoundLocalMove 2
  0028    | GetBoundLocal 1
  0030    | JumpIfFailure 30 -> 36
  0033    | GetBoundLocalMove 3
  0035    | Merge
  0036    | GetBoundLocalMove 4
  0038    | CallFunction 3
  0040    | CallFunction 1
  0042    | Destructure 62: NewDoc
  0044    | TakeRight 44 -> 67
  0047    | SetInputMark
  0048    | GetConstant 225: _toml.table_body
  0050    | GetBoundLocalMove 0
  0052    | GetBoundLocalMove 1
  0054    | GetBoundLocal 5
  0056    | CallFunction 3
  0058    | Or 58 -> 67
  0061    | GetConstant 34: const
  0063    | GetBoundLocalMove 5
  0065    | CallTailFunction 1
  0067    | End
  ========================================
  
  =================@fn253=================
  maybe(spaces)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 236: spaces
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn252=================
  surround("=", maybe(spaces))
  ========================================
  0000    | GetConstant 163: surround
  0002    | PushChar '='
  0004    | GetConstant 235: @fn253
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_toml.table_pair============
  _toml.table_pair(value) =
    tuple2_sep(_toml.path, surround("=", maybe(spaces)), value)
  ========================================
  0000    | GetConstant 232: tuple2_sep
  0002    | GetConstant 233: _toml.path
  0004    | GetConstant 234: @fn252
  0006    | GetBoundLocalMove 0
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =================@fn256=================
  maybe(ws)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn255=================
  surround(".", maybe(ws))
  ========================================
  0000    | GetConstant 163: surround
  0002    | PushChar '.'
  0004    | GetConstant 239: @fn256
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============_toml.path===============
  _toml.path = array_sep(_toml.key, surround(".", maybe(ws)))
  ========================================
  0000    | GetConstant 81: array_sep
  0002    | GetConstant 237: _toml.key
  0004    | GetConstant 238: @fn255
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn259=================
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
  
  ===============_toml.key================
  _toml.key =
    many(alpha | numeral | "_" | "-") |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetConstant 240: @fn259
  0005    | CallFunction 1
  0007    | Or 7 -> 18
  0010    | SetInputMark
  0011    | CallFunctionConstant 241: toml.string.basic
  0013    | Or 13 -> 18
  0016    | CallTailFunctionConstant 242: toml.string.literal
  0018    | End
  ========================================
  
  ===========toml.string.basic============
  toml.string.basic = '"' > _toml.string.basic_body < '"'
  ========================================
  0000    | ParseChar '"'
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 243: _toml.string.basic_body
  0007    | JumpIfFailure 7 -> 13
  0010    | ParseChar '"'
  0012    | TakeLeft
  0013    | End
  ========================================
  
  =================@fn264=================
  _ctrl_char | `\` | '"'
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 181: _ctrl_char
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '\'
  0009    | Or 9 -> 14
  0012    | ParseChar '"'
  0014    | End
  ========================================
  
  =================@fn261=================
  _toml.escaped_ctrl_char |
      _toml.escaped_unicode |
      unless(char, _ctrl_char | `\` | '"')
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 245: _toml.escaped_ctrl_char
  0003    | Or 3 -> 20
  0006    | SetInputMark
  0007    | CallFunctionConstant 246: _toml.escaped_unicode
  0009    | Or 9 -> 20
  0012    | GetConstant 7: unless
  0014    | GetConstant 8: char
  0016    | GetConstant 247: @fn264
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
  0001    | GetConstant 0: many
  0003    | GetConstant 244: @fn261
  0005    | CallFunction 1
  0007    | Or 7 -> 15
  0010    | GetConstant 34: const
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
  0001    | CallFunctionConstant 182: "\""
  0003    | TakeRight 3 -> 8
  0006    | PushChar '"'
  0008    | Or 8 -> 73
  0011    | SetInputMark
  0012    | CallFunctionConstant 183: "\\"
  0014    | TakeRight 14 -> 19
  0017    | PushChar '\'
  0019    | Or 19 -> 73
  0022    | SetInputMark
  0023    | CallFunctionConstant 185: "\b"
  0025    | TakeRight 25 -> 30
  0028    | PushChar '\x08' (esc)
  0030    | Or 30 -> 73
  0033    | SetInputMark
  0034    | CallFunctionConstant 186: "\f"
  0036    | TakeRight 36 -> 41
  0039    | PushChar '\x0c' (esc)
  0041    | Or 41 -> 73
  0044    | SetInputMark
  0045    | CallFunctionConstant 187: "\n"
  0047    | TakeRight 47 -> 52
  0050    | PushChar '
  '
  0052    | Or 52 -> 73
  0055    | SetInputMark
  0056    | CallFunctionConstant 188: "\r"
  0058    | TakeRight 58 -> 63
  0061    | PushChar '\r (no-eol) (esc)
  '
  0063    | Or 63 -> 73
  0066    | CallFunctionConstant 189: "\t"
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
  0003    | CallFunctionConstant 197: "\u"
  0005    | TakeRight 5 -> 32
  0008    | PushNull
  0009    | PushNumber 4
  0011    | ValidateRepeatPattern
  0012    | JumpIfZero 12 -> 31
  0015    | Swap
  0016    | CallFunctionConstant 198: hex_numeral
  0018    | Merge
  0019    | JumpIfFailure 19 -> 30
  0022    | Swap
  0023    | Decrement
  0024    | JumpIfZero 24 -> 31
  0027    | JumpBack 27 -> 15
  0030    | Swap
  0031    | Drop
  0032    | Destructure 63: U
  0034    | TakeRight 34 -> 43
  0037    | GetConstant 200: @Codepoint
  0039    | GetBoundLocal 0
  0041    | CallFunction 1
  0043    | Or 43 -> 86
  0046    | CallFunctionConstant 248: "\U"
  0048    | TakeRight 48 -> 75
  0051    | PushNull
  0052    | PushNumber 8
  0054    | ValidateRepeatPattern
  0055    | JumpIfZero 55 -> 74
  0058    | Swap
  0059    | CallFunctionConstant 198: hex_numeral
  0061    | Merge
  0062    | JumpIfFailure 62 -> 73
  0065    | Swap
  0066    | Decrement
  0067    | JumpIfZero 67 -> 74
  0070    | JumpBack 70 -> 58
  0073    | Swap
  0074    | Drop
  0075    | Destructure 64: U
  0077    | TakeRight 77 -> 86
  0080    | GetConstant 200: @Codepoint
  0082    | GetBoundLocalMove 0
  0084    | CallTailFunction 1
  0086    | End
  ========================================
  
  =================@fn265=================
  chars_until("'")
  ========================================
  0000    | GetConstant 25: chars_until
  0002    | PushChar '''
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========toml.string.literal===========
  toml.string.literal = "'" > default(chars_until("'"), $"") < "'"
  ========================================
  0000    | ParseChar '''
  0002    | TakeRight 2 -> 12
  0005    | GetConstant 78: default
  0007    | GetConstant 249: @fn265
  0009    | PushEmptyString
  0010    | CallFunction 2
  0012    | JumpIfFailure 12 -> 18
  0015    | ParseChar '''
  0017    | TakeLeft
  0018    | End
  ========================================
  
  ============_toml.ws_newline============
  _toml.ws_newline = _toml.ws_line + (nl | end) + _toml.ws
  ========================================
  0000    | CallFunctionConstant 250: _toml.ws_line
  0002    | JumpIfFailure 2 -> 14
  0005    | SetInputMark
  0006    | CallFunctionConstant 13: newline
  0008    | Or 8 -> 13
  0011    | CallFunctionConstant 27: end_of_input
  0013    | Merge
  0014    | JumpIfFailure 14 -> 20
  0017    | CallFunctionConstant 223: _toml.ws
  0019    | Merge
  0020    | End
  ========================================
  
  =================@fn267=================
  spaces | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 236: spaces
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 218: _toml.comment
  0008    | End
  ========================================
  
  =============_toml.ws_line==============
  _toml.ws_line = maybe_many(spaces | _toml.comment)
  ========================================
  0000    | GetConstant 251: maybe_many
  0002    | GetConstant 252: @fn267
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn268=================
  ws | _toml.comment
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 9: whitespace
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 218: _toml.comment
  0008    | End
  ========================================
  
  ================_toml.ws================
  _toml.ws = maybe_many(ws | _toml.comment)
  ========================================
  0000    | GetConstant 251: maybe_many
  0002    | GetConstant 253: @fn268
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========_Toml.Doc.InsertAtPath=========
  _Toml.Doc.InsertAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.ValueUpdater)
  ========================================
  0000    | GetConstant 254: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocalMove 0
  0004    | GetBoundLocalMove 1
  0006    | GetBoundLocalMove 2
  0008    | GetConstant 255: _Toml.Doc.ValueUpdater
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
  0000    | GetConstant2 256: Key
  0003    | GetConstant2 257: PathRest
  0006    | GetConstant2 258: InnerDoc
  0009    | SetInputMark
  0010    | GetBoundLocal 1
  0012    | Destructure 65: [Key]
  0014    | ConditionalThen 14 -> 30
  0017    | GetBoundLocalMove 3
  0019    | GetBoundLocalMove 0
  0021    | GetBoundLocalMove 4
  0023    | GetBoundLocalMove 2
  0025    | CallTailFunction 3
  0027    | Jump 27 -> 134
  0030    | SetInputMark
  0031    | GetBoundLocalMove 1
  0033    | Destructure 66: ([Key] + PathRest)
  0035    | ConditionalThen 35 -> 132
  0038    | SetInputMark
  0039    | GetConstant2 259: _Toml.Doc.Has
  0042    | GetBoundLocal 0
  0044    | GetBoundLocal 4
  0046    | CallFunction 2
  0048    | ConditionalThen 48 -> 90
  0051    | GetConstant2 260: _Toml.Doc.IsTable
  0054    | GetConstant2 261: _Toml.Doc.Get
  0057    | GetBoundLocal 0
  0059    | GetBoundLocal 4
  0061    | CallFunction 2
  0063    | CallFunction 1
  0065    | TakeRight 65 -> 87
  0068    | GetConstant 254: _Toml.Doc.UpdateAtPath
  0070    | GetConstant2 261: _Toml.Doc.Get
  0073    | GetBoundLocal 0
  0075    | GetBoundLocal 4
  0077    | CallFunction 2
  0079    | GetBoundLocalMove 5
  0081    | GetBoundLocalMove 2
  0083    | GetBoundLocalMove 3
  0085    | CallFunction 4
  0087    | Jump 87 -> 102
  0090    | GetConstant 254: _Toml.Doc.UpdateAtPath
  0092    | CallFunctionConstant 222: _Toml.Doc.Empty
  0094    | GetBoundLocalMove 5
  0096    | GetBoundLocalMove 2
  0098    | GetBoundLocalMove 3
  0100    | CallFunction 4
  0102    | Destructure 67: InnerDoc
  0104    | TakeRight 104 -> 129
  0107    | GetConstant2 262: _Toml.Doc.Insert
  0110    | GetBoundLocalMove 0
  0112    | GetBoundLocalMove 4
  0114    | GetConstant 217: _Toml.Doc.Value
  0116    | GetBoundLocal 6
  0118    | CallFunction 1
  0120    | GetConstant2 263: _Toml.Doc.Type
  0123    | GetBoundLocalMove 6
  0125    | CallFunction 1
  0127    | CallTailFunction 4
  0129    | Jump 129 -> 134
  0132    | GetBoundLocalMove 0
  0134    | End
  ========================================
  
  =============_Toml.Doc.Has==============
  _Toml.Doc.Has(Doc, Key) = Obj.Has(_Toml.Doc.Type(Doc), Key)
  ========================================
  0000    | GetConstant2 264: Obj.Has
  0003    | GetConstant2 263: _Toml.Doc.Type
  0006    | GetBoundLocalMove 0
  0008    | CallFunction 1
  0010    | GetBoundLocalMove 1
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  ================Obj.Has=================
  Obj.Has(O, K) = O -> {K: _, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 68: ({K: _} + _)
  0005    | End
  ========================================
  
  =============_Toml.Doc.Type=============
  _Toml.Doc.Type(Doc) = Obj.Get(Doc, "type")
  ========================================
  0000    | GetConstant2 265: Obj.Get
  0003    | GetBoundLocalMove 0
  0005    | GetConstant2 266: "type"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  ================Obj.Get=================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushCharVar V
  0002    | PushUnderscoreVar
  0003    | GetBoundLocalMove 0
  0005    | Destructure 69: ({K: V} + _)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 2
  0012    | End
  ========================================
  
  ===========_Toml.Doc.IsTable============
  _Toml.Doc.IsTable(Doc) = Is.Object(_Toml.Doc.Type(Doc))
  ========================================
  0000    | GetConstant2 267: Is.Object
  0003    | GetConstant2 263: _Toml.Doc.Type
  0006    | GetBoundLocalMove 0
  0008    | CallFunction 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ===============Is.Object================
  Is.Object(V) = V -> {..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 70: ({} + _)
  0005    | End
  ========================================
  
  =============_Toml.Doc.Get==============
  _Toml.Doc.Get(Doc, Key) = {
    "value": Obj.Get(_Toml.Doc.Value(Doc), Key),
    "type": Obj.Get(_Toml.Doc.Type(Doc), Key),
  }
  ========================================
  0000    | GetConstantMutable2 268: {_0_, _1_}
  0003    | GetConstant2 269: "value"
  0006    | GetConstant2 265: Obj.Get
  0009    | GetConstant 217: _Toml.Doc.Value
  0011    | GetBoundLocal 0
  0013    | CallFunction 1
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | InsertKeyVal 0
  0021    | GetConstant2 266: "type"
  0024    | GetConstant2 265: Obj.Get
  0027    | GetConstant2 263: _Toml.Doc.Type
  0030    | GetBoundLocalMove 0
  0032    | CallFunction 1
  0034    | GetBoundLocalMove 1
  0036    | CallFunction 2
  0038    | InsertKeyVal 1
  0040    | End
  ========================================
  
  ============_Toml.Doc.Value=============
  _Toml.Doc.Value(Doc) = Obj.Get(Doc, "value")
  ========================================
  0000    | GetConstant2 265: Obj.Get
  0003    | GetBoundLocalMove 0
  0005    | GetConstant2 269: "value"
  0008    | CallTailFunction 2
  0010    | End
  ========================================
  
  ============_Toml.Doc.Empty=============
  _Toml.Doc.Empty = {"value": {}, "type": {}}
  ========================================
  0000    | GetConstant2 270: {"value": {}, "type": {}}
  0003    | End
  ========================================
  
  ============_Toml.Doc.Insert============
  _Toml.Doc.Insert(Doc, Key, Val, Type) =
    _Toml.Doc.IsTable(Doc) &
    {
      "value": Obj.Put(_Toml.Doc.Value(Doc), Key, Val),
      "type": Obj.Put(_Toml.Doc.Type(Doc), Key, Type),
    }
  ========================================
  0000    | GetConstant2 260: _Toml.Doc.IsTable
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | TakeRight 7 -> 54
  0010    | GetConstantMutable2 271: {_0_, _1_}
  0013    | GetConstant2 269: "value"
  0016    | GetConstant2 272: Obj.Put
  0019    | GetConstant 217: _Toml.Doc.Value
  0021    | GetBoundLocal 0
  0023    | CallFunction 1
  0025    | GetBoundLocal 1
  0027    | GetBoundLocalMove 2
  0029    | CallFunction 3
  0031    | InsertKeyVal 0
  0033    | GetConstant2 266: "type"
  0036    | GetConstant2 272: Obj.Put
  0039    | GetConstant2 263: _Toml.Doc.Type
  0042    | GetBoundLocalMove 0
  0044    | CallFunction 1
  0046    | GetBoundLocalMove 1
  0048    | GetBoundLocalMove 3
  0050    | CallFunction 3
  0052    | InsertKeyVal 1
  0054    | End
  ========================================
  
  ================Obj.Put=================
  Obj.Put(O, K, V) = {...O, K: V}
  ========================================
  0000    | PushEmptyObject
  0001    | JumpIfFailure 1 -> 7
  0004    | GetBoundLocalMove 0
  0006    | Merge
  0007    | JumpIfFailure 7 -> 20
  0010    | GetConstantMutable2 273: {_0_}
  0013    | GetBoundLocalMove 1
  0015    | GetBoundLocalMove 2
  0017    | InsertKeyVal 0
  0019    | Merge
  0020    | End
  ========================================
  
  =========_Toml.Doc.ValueUpdater=========
  _Toml.Doc.ValueUpdater(Doc, Key, Val) =
    _Toml.Doc.Has(Doc, Key) ? @Fail : _Toml.Doc.Insert(Doc, Key, Val, "value")
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 259: _Toml.Doc.Has
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | ConditionalThen 10 -> 19
  0013    | CallTailFunctionConstant2 274: @Fail
  0016    | Jump 16 -> 33
  0019    | GetConstant2 262: _Toml.Doc.Insert
  0022    | GetBoundLocalMove 0
  0024    | GetBoundLocalMove 1
  0026    | GetBoundLocalMove 2
  0028    | GetConstant2 269: "value"
  0031    | CallTailFunction 4
  0033    | End
  ========================================
  
  ==============_toml.tables==============
  _toml.tables(value, Doc) =
    _toml.ws >
    _toml.table(value, Doc) | _toml.array_of_tables(value, Doc) -> NewDoc ?
    _toml.tables(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant 228: NewDoc
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | CallFunctionConstant 223: _toml.ws
  0006    | TakeRight 6 -> 18
  0009    | GetConstant2 275: _toml.table
  0012    | GetBoundLocal 0
  0014    | GetBoundLocal 1
  0016    | CallFunction 2
  0018    | Or 18 -> 30
  0021    | GetConstant2 276: _toml.array_of_tables
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | CallFunction 2
  0030    | Destructure 71: NewDoc
  0032    | ConditionalThen 32 -> 46
  0035    | GetConstant 224: _toml.tables
  0037    | GetBoundLocalMove 0
  0039    | GetBoundLocalMove 2
  0041    | CallTailFunction 2
  0043    | Jump 43 -> 52
  0046    | GetConstant 34: const
  0048    | GetBoundLocalMove 1
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
  0000    | GetConstant2 277: HeaderPath
  0003    | CallFunctionConstant2 278: _toml.table_header
  0006    | Destructure 72: HeaderPath
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionConstant 230: _toml.ws_newline
  0013    | TakeRight 13 -> 43
  0016    | SetInputMark
  0017    | GetConstant 225: _toml.table_body
  0019    | GetBoundLocalMove 0
  0021    | GetBoundLocal 2
  0023    | GetBoundLocal 1
  0025    | CallFunction 3
  0027    | Or 27 -> 43
  0030    | GetConstant 34: const
  0032    | GetConstant2 279: _Toml.Doc.EnsureTableAtPath
  0035    | GetBoundLocalMove 1
  0037    | GetBoundLocalMove 2
  0039    | CallFunction 2
  0041    | CallTailFunction 1
  0043    | End
  ========================================
  
  =================@fn290=================
  maybe(ws)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========_toml.table_header===========
  _toml.table_header = "[" > surround(_toml.path, maybe(ws)) < "]"
  ========================================
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 14
  0005    | GetConstant 163: surround
  0007    | GetConstant 233: _toml.path
  0009    | GetConstant2 280: @fn290
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 20
  0017    | ParseChar ']'
  0019    | TakeLeft
  0020    | End
  ========================================
  
  ======_Toml.Doc.EnsureTableAtPath=======
  _Toml.Doc.EnsureTableAtPath(Doc, Path) =
    _Toml.Doc.UpdateAtPath(Doc, Path, {}, _Toml.Doc.MissingTableUpdater)
  ========================================
  0000    | GetConstant 254: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocalMove 0
  0004    | GetBoundLocalMove 1
  0006    | PushEmptyObject
  0007    | GetConstant2 281: _Toml.Doc.MissingTableUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =====_Toml.Doc.MissingTableUpdater======
  _Toml.Doc.MissingTableUpdater(Doc, Key, _Val) =
    _Toml.Doc.IsTable(_Toml.Doc.Get(Doc, Key)) ? Doc :
    _Toml.Doc.Insert(Doc, Key, {}, {})
  ========================================
  0000    | SetInputMark
  0001    | GetConstant2 260: _Toml.Doc.IsTable
  0004    | GetConstant2 261: _Toml.Doc.Get
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallFunction 2
  0013    | CallFunction 1
  0015    | ConditionalThen 15 -> 23
  0018    | GetBoundLocalMove 0
  0020    | Jump 20 -> 34
  0023    | GetConstant2 262: _Toml.Doc.Insert
  0026    | GetBoundLocalMove 0
  0028    | GetBoundLocalMove 1
  0030    | PushEmptyObject
  0031    | PushEmptyObject
  0032    | CallTailFunction 4
  0034    | End
  ========================================
  
  =================@fn294=================
  _toml.table_body(value, [], _Toml.Doc.Empty)
  ========================================
  0000    | GetConstant 138: value
  0002    | SetClosureCaptures
  0003    | GetConstant 225: _toml.table_body
  0005    | GetBoundLocalMove 0
  0007    | PushEmptyArray
  0008    | CallFunctionConstant 222: _Toml.Doc.Empty
  0010    | CallTailFunction 3
  0012    | End
  ========================================
  
  =========_toml.array_of_tables==========
  _toml.array_of_tables(value, Doc) =
    _toml.array_of_tables_header -> HeaderPath & _toml.ws_newline &
    default(_toml.table_body(value, [], _Toml.Doc.Empty), _Toml.Doc.Empty) -> InnerDoc $
    _Toml.Doc.AppendAtPath(Doc, HeaderPath, _Toml.Doc.Value(InnerDoc))
  ========================================
  0000    | GetConstant2 277: HeaderPath
  0003    | GetConstant2 258: InnerDoc
  0006    | CallFunctionConstant2 282: _toml.array_of_tables_header
  0009    | Destructure 73: HeaderPath
  0011    | TakeRight 11 -> 16
  0014    | CallFunctionConstant 230: _toml.ws_newline
  0016    | TakeRight 16 -> 52
  0019    | GetConstant 78: default
  0021    | GetConstant2 283: @fn294
  0024    | CreateClosure 1
  0026    | CaptureLocal 0
  0028    | CallFunctionConstant 222: _Toml.Doc.Empty
  0030    | CallFunction 2
  0032    | Destructure 74: InnerDoc
  0034    | TakeRight 34 -> 52
  0037    | GetConstant2 284: _Toml.Doc.AppendAtPath
  0040    | GetBoundLocalMove 1
  0042    | GetBoundLocalMove 2
  0044    | GetConstant 217: _Toml.Doc.Value
  0046    | GetBoundLocalMove 3
  0048    | CallFunction 1
  0050    | CallTailFunction 3
  0052    | End
  ========================================
  
  =================@fn295=================
  maybe(ws)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 9: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ======_toml.array_of_tables_header======
  _toml.array_of_tables_header =
    "[[" > surround(_toml.path, maybe(ws)) < "]]"
  ========================================
  0000    | CallFunctionConstant2 285: "[["
  0003    | TakeRight 3 -> 15
  0006    | GetConstant 163: surround
  0008    | GetConstant 233: _toml.path
  0010    | GetConstant2 286: @fn295
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 22
  0018    | CallFunctionConstant2 287: "]]"
  0021    | TakeLeft
  0022    | End
  ========================================
  
  =========_Toml.Doc.AppendAtPath=========
  _Toml.Doc.AppendAtPath(Doc, Path, Val) =
    _Toml.Doc.UpdateAtPath(Doc, Path, Val, _Toml.Doc.AppendUpdater)
  ========================================
  0000    | GetConstant 254: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocalMove 0
  0004    | GetBoundLocalMove 1
  0006    | GetBoundLocalMove 2
  0008    | GetConstant2 288: _Toml.Doc.AppendUpdater
  0011    | CallTailFunction 4
  0013    | End
  ========================================
  
  ========_Toml.Doc.AppendUpdater=========
  _Toml.Doc.AppendUpdater(Doc, Key, Val) =
    (
      _Toml.Doc.Has(Doc, Key) ? Doc :
      _Toml.Doc.Insert(Doc, Key, [], "array_of_tables")
    ) -> DocWithKey &
    _Toml.Doc.AppendToArrayOfTables(DocWithKey, Key, Val)
  ========================================
  0000    | GetConstant2 289: DocWithKey
  0003    | SetInputMark
  0004    | GetConstant2 259: _Toml.Doc.Has
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallFunction 2
  0013    | ConditionalThen 13 -> 21
  0016    | GetBoundLocalMove 0
  0018    | Jump 18 -> 34
  0021    | GetConstant2 262: _Toml.Doc.Insert
  0024    | GetBoundLocalMove 0
  0026    | GetBoundLocal 1
  0028    | PushEmptyArray
  0029    | GetConstant2 290: "array_of_tables"
  0032    | CallFunction 4
  0034    | Destructure 75: DocWithKey
  0036    | TakeRight 36 -> 50
  0039    | GetConstant2 291: _Toml.Doc.AppendToArrayOfTables
  0042    | GetBoundLocalMove 3
  0044    | GetBoundLocalMove 1
  0046    | GetBoundLocalMove 2
  0048    | CallTailFunction 3
  0050    | End
  ========================================
  
  ====_Toml.Doc.AppendToArrayOfTables=====
  _Toml.Doc.AppendToArrayOfTables(Doc, Key, Val) =
    _Toml.Doc.Get(Doc, Key) -> {"value": AoT, "type": "array_of_tables"} &
    _Toml.Doc.Insert(Doc, Key, [...AoT, Val], "array_of_tables")
  ========================================
  0000    | GetConstant2 292: AoT
  0003    | GetConstant2 261: _Toml.Doc.Get
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 1
  0010    | CallFunction 2
  0012    | Destructure 76: {"value": AoT, "type": "array_of_tables"}
  0014    | TakeRight 14 -> 47
  0017    | GetConstant2 262: _Toml.Doc.Insert
  0020    | GetBoundLocalMove 0
  0022    | GetBoundLocalMove 1
  0024    | PushEmptyArray
  0025    | JumpIfFailure 25 -> 31
  0028    | GetBoundLocalMove 3
  0030    | Merge
  0031    | JumpIfFailure 31 -> 42
  0034    | GetConstantMutable2 293: [_]
  0037    | GetBoundLocalMove 2
  0039    | InsertAtIndex 0
  0041    | Merge
  0042    | GetConstant2 290: "array_of_tables"
  0045    | CallTailFunction 4
  0047    | End
  ========================================
  
  ==========_toml.no_root_table===========
  _toml.no_root_table(value) =
    _toml.table(value, _Toml.Doc.Empty) | _toml.array_of_tables(value, _Toml.Doc.Empty) -> NewDoc &
    _toml.tables(value, NewDoc)
  ========================================
  0000    | GetConstant 228: NewDoc
  0002    | SetInputMark
  0003    | GetConstant2 275: _toml.table
  0006    | GetBoundLocal 0
  0008    | CallFunctionConstant 222: _Toml.Doc.Empty
  0010    | CallFunction 2
  0012    | Or 12 -> 24
  0015    | GetConstant2 276: _toml.array_of_tables
  0018    | GetBoundLocal 0
  0020    | CallFunctionConstant 222: _Toml.Doc.Empty
  0022    | CallFunction 2
  0024    | Destructure 77: NewDoc
  0026    | TakeRight 26 -> 37
  0029    | GetConstant 224: _toml.tables
  0031    | GetBoundLocalMove 0
  0033    | GetBoundLocalMove 1
  0035    | CallTailFunction 2
  0037    | End
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
  0001    | CallFunctionConstant2 294: toml.string
  0004    | Or 4 -> 46
  0007    | SetInputMark
  0008    | CallFunctionConstant2 295: toml.datetime
  0011    | Or 11 -> 46
  0014    | SetInputMark
  0015    | CallFunctionConstant2 296: toml.number
  0018    | Or 18 -> 46
  0021    | SetInputMark
  0022    | CallFunctionConstant2 297: toml.boolean
  0025    | Or 25 -> 46
  0028    | SetInputMark
  0029    | GetConstant2 298: toml.array
  0032    | GetConstant 210: toml.simple_value
  0034    | CallFunction 1
  0036    | Or 36 -> 46
  0039    | GetConstant2 299: toml.inline_table
  0042    | GetConstant 210: toml.simple_value
  0044    | CallTailFunction 1
  0046    | End
  ========================================
  
  ==============toml.string===============
  toml.string =
    toml.string.multi_line_basic |
    toml.string.multi_line_literal |
    toml.string.basic |
    toml.string.literal
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 300: toml.string.multi_line_basic
  0004    | Or 4 -> 22
  0007    | SetInputMark
  0008    | CallFunctionConstant2 301: toml.string.multi_line_literal
  0011    | Or 11 -> 22
  0014    | SetInputMark
  0015    | CallFunctionConstant 241: toml.string.basic
  0017    | Or 17 -> 22
  0020    | CallTailFunctionConstant 242: toml.string.literal
  0022    | End
  ========================================
  
  =================@fn307=================
  maybe(nl)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn310=================
  _ctrl_char | `\`
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 181: _ctrl_char
  0003    | Or 3 -> 8
  0006    | ParseChar '\'
  0008    | End
  ========================================
  
  =================@fn309=================
  _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 245: _toml.escaped_ctrl_char
  0003    | Or 3 -> 43
  0006    | SetInputMark
  0007    | CallFunctionConstant 246: _toml.escaped_unicode
  0009    | Or 9 -> 43
  0012    | SetInputMark
  0013    | CallFunctionConstant 9: whitespace
  0015    | Or 15 -> 43
  0018    | SetInputMark
  0019    | ParseChar '\'
  0021    | JumpIfFailure 21 -> 27
  0024    | CallFunctionConstant 9: whitespace
  0026    | Merge
  0027    | TakeRight 27 -> 31
  0030    | PushEmptyString
  0031    | Or 31 -> 43
  0034    | GetConstant 7: unless
  0036    | GetConstant 8: char
  0038    | GetConstant2 307: @fn310
  0041    | CallTailFunction 2
  0043    | End
  ========================================
  
  =================@fn308=================
  many_until(
        _toml.escaped_ctrl_char | _toml.escaped_unicode |
        ws | (`\` + ws > "") | unless(char, _ctrl_char | `\`),
        `"""`
      )
  ========================================
  0000    | GetConstant 28: many_until
  0002    | GetConstant2 306: @fn309
  0005    | GetConstant2 303: """""
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
  0000    | GetConstant2 302: skip
  0003    | GetConstant2 303: """""
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 20
  0011    | GetConstant2 302: skip
  0014    | GetConstant2 304: @fn307
  0017    | CallFunction 1
  0019    | Merge
  0020    | JumpIfFailure 20 -> 32
  0023    | GetConstant 78: default
  0025    | GetConstant2 305: @fn308
  0028    | PushEmptyString
  0029    | CallFunction 2
  0031    | Merge
  0032    | JumpIfFailure 32 -> 44
  0035    | GetConstant2 302: skip
  0038    | GetConstant2 303: """""
  0041    | CallFunction 1
  0043    | Merge
  0044    | JumpIfFailure 44 -> 99
  0047    | PushNull
  0048    | PushNumberZero
  0049    | ValidateRepeatPattern
  0050    | JumpIfZero 50 -> 68
  0053    | Swap
  0054    | ParseChar '"'
  0056    | Merge
  0057    | JumpIfFailure 57 -> 96
  0060    | Swap
  0061    | Decrement
  0062    | JumpIfZero 62 -> 68
  0065    | JumpBack 65 -> 53
  0068    | Drop
  0069    | PushNumberTwo
  0070    | PushNumberZero
  0071    | NegateNumber
  0072    | Merge
  0073    | ValidateRepeatPattern
  0074    | JumpIfZero 74 -> 97
  0077    | Swap
  0078    | SetInputMark
  0079    | ParseChar '"'
  0081    | JumpIfFailure 81 -> 94
  0084    | PopInputMark
  0085    | Merge
  0086    | Swap
  0087    | Decrement
  0088    | JumpIfZero 88 -> 97
  0091    | JumpBack 91 -> 77
  0094    | ResetInput
  0095    | Drop
  0096    | Swap
  0097    | Drop
  0098    | Merge
  0099    | End
  ========================================
  
  =================@fn311=================
  maybe(nl)
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant 13: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn312=================
  many_until(char, `'''`)
  ========================================
  0000    | GetConstant 28: many_until
  0002    | GetConstant 8: char
  0004    | GetConstant2 308: "'''"
  0007    | CallTailFunction 2
  0009    | End
  ========================================
  
  =====toml.string.multi_line_literal=====
  toml.string.multi_line_literal =
    skip(`'''`) + skip(maybe(nl)) +
    default(many_until(char, `'''`), $"")
    + skip(`'''`) + (`'` * 0..2)
  ========================================
  0000    | GetConstant2 302: skip
  0003    | GetConstant2 308: "'''"
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 20
  0011    | GetConstant2 302: skip
  0014    | GetConstant2 309: @fn311
  0017    | CallFunction 1
  0019    | Merge
  0020    | JumpIfFailure 20 -> 32
  0023    | GetConstant 78: default
  0025    | GetConstant2 310: @fn312
  0028    | PushEmptyString
  0029    | CallFunction 2
  0031    | Merge
  0032    | JumpIfFailure 32 -> 44
  0035    | GetConstant2 302: skip
  0038    | GetConstant2 308: "'''"
  0041    | CallFunction 1
  0043    | Merge
  0044    | JumpIfFailure 44 -> 99
  0047    | PushNull
  0048    | PushNumberZero
  0049    | ValidateRepeatPattern
  0050    | JumpIfZero 50 -> 68
  0053    | Swap
  0054    | ParseChar '''
  0056    | Merge
  0057    | JumpIfFailure 57 -> 96
  0060    | Swap
  0061    | Decrement
  0062    | JumpIfZero 62 -> 68
  0065    | JumpBack 65 -> 53
  0068    | Drop
  0069    | PushNumberTwo
  0070    | PushNumberZero
  0071    | NegateNumber
  0072    | Merge
  0073    | ValidateRepeatPattern
  0074    | JumpIfZero 74 -> 97
  0077    | Swap
  0078    | SetInputMark
  0079    | ParseChar '''
  0081    | JumpIfFailure 81 -> 94
  0084    | PopInputMark
  0085    | Merge
  0086    | Swap
  0087    | Decrement
  0088    | JumpIfZero 88 -> 97
  0091    | JumpBack 91 -> 77
  0094    | ResetInput
  0095    | Drop
  0096    | Swap
  0097    | Drop
  0098    | Merge
  0099    | End
  ========================================
  
  =============toml.datetime==============
  toml.datetime =
    toml.datetime.offset |
    toml.datetime.local |
    toml.datetime.local_date |
    toml.datetime.local_time
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant2 311: toml.datetime.offset
  0004    | Or 4 -> 24
  0007    | SetInputMark
  0008    | CallFunctionConstant2 312: toml.datetime.local
  0011    | Or 11 -> 24
  0014    | SetInputMark
  0015    | CallFunctionConstant2 313: toml.datetime.local_date
  0018    | Or 18 -> 24
  0021    | CallTailFunctionConstant2 314: toml.datetime.local_time
  0024    | End
  ========================================
  
  ==========toml.datetime.offset==========
  toml.datetime.offset = toml.datetime.local_date + ("T" | "t" | " ") + _toml.datetime.time_offset
  ========================================
  0000    | CallFunctionConstant2 313: toml.datetime.local_date
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
  0024    | CallFunctionConstant2 315: _toml.datetime.time_offset
  0027    | Merge
  0028    | End
  ========================================
  
  ========toml.datetime.local_date========
  toml.datetime.local_date =
    _toml.datetime.year + "-" + _toml.datetime.month + "-" + _toml.datetime.mday
  ========================================
  0000    | CallFunctionConstant2 316: _toml.datetime.year
  0003    | JumpIfFailure 3 -> 9
  0006    | ParseChar '-'
  0008    | Merge
  0009    | JumpIfFailure 9 -> 16
  0012    | CallFunctionConstant2 317: _toml.datetime.month
  0015    | Merge
  0016    | JumpIfFailure 16 -> 22
  0019    | ParseChar '-'
  0021    | Merge
  0022    | JumpIfFailure 22 -> 29
  0025    | CallFunctionConstant2 318: _toml.datetime.mday
  0028    | Merge
  0029    | End
  ========================================
  
  ==========_toml.datetime.year===========
  _toml.datetime.year = numeral * 4
  ========================================
  0000    | PushNull
  0001    | PushNumber 4
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
  
  ==========_toml.datetime.month==========
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
  
  ==========_toml.datetime.mday===========
  _toml.datetime.mday = ("0".."2" + "1".."9") | "30" | "31"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'2'
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseCodepointRange '1'..'9'
  0010    | Merge
  0011    | Or 11 -> 24
  0014    | SetInputMark
  0015    | CallFunctionConstant2 319: "30"
  0018    | Or 18 -> 24
  0021    | CallTailFunctionConstant2 320: "31"
  0024    | End
  ========================================
  
  =======_toml.datetime.time_offset=======
  _toml.datetime.time_offset = toml.datetime.local_time + ("Z" | "z" | _toml.datetime.time_numoffset)
  ========================================
  0000    | CallFunctionConstant2 314: toml.datetime.local_time
  0003    | JumpIfFailure 3 -> 22
  0006    | SetInputMark
  0007    | ParseChar 'Z'
  0009    | Or 9 -> 21
  0012    | SetInputMark
  0013    | ParseChar 'z'
  0015    | Or 15 -> 21
  0018    | CallFunctionConstant2 321: _toml.datetime.time_numoffset
  0021    | Merge
  0022    | End
  ========================================
  
  =================@fn325=================
  "." + (numeral * 1..9)
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 58
  0005    | PushNull
  0006    | PushNumberOne
  0007    | ValidateRepeatPattern
  0008    | JumpIfZero 8 -> 26
  0011    | Swap
  0012    | CallFunctionConstant 4: numeral
  0014    | Merge
  0015    | JumpIfFailure 15 -> 55
  0018    | Swap
  0019    | Decrement
  0020    | JumpIfZero 20 -> 26
  0023    | JumpBack 23 -> 11
  0026    | Drop
  0027    | PushNumber 9
  0029    | PushNumberOne
  0030    | NegateNumber
  0031    | Merge
  0032    | ValidateRepeatPattern
  0033    | JumpIfZero 33 -> 56
  0036    | Swap
  0037    | SetInputMark
  0038    | CallFunctionConstant 4: numeral
  0040    | JumpIfFailure 40 -> 53
  0043    | PopInputMark
  0044    | Merge
  0045    | Swap
  0046    | Decrement
  0047    | JumpIfZero 47 -> 56
  0050    | JumpBack 50 -> 36
  0053    | ResetInput
  0054    | Drop
  0055    | Swap
  0056    | Drop
  0057    | Merge
  0058    | End
  ========================================
  
  ========toml.datetime.local_time========
  toml.datetime.local_time =
    _toml.datetime.hours + ":" +
    _toml.datetime.minutes + ":" +
    _toml.datetime.seconds +
    maybe("." + (numeral * 1..9))
  ========================================
  0000    | CallFunctionConstant2 322: _toml.datetime.hours
  0003    | JumpIfFailure 3 -> 9
  0006    | ParseChar ':'
  0008    | Merge
  0009    | JumpIfFailure 9 -> 16
  0012    | CallFunctionConstant2 323: _toml.datetime.minutes
  0015    | Merge
  0016    | JumpIfFailure 16 -> 22
  0019    | ParseChar ':'
  0021    | Merge
  0022    | JumpIfFailure 22 -> 29
  0025    | CallFunctionConstant2 324: _toml.datetime.seconds
  0028    | Merge
  0029    | JumpIfFailure 29 -> 40
  0032    | GetConstant 37: maybe
  0034    | GetConstant2 325: @fn325
  0037    | CallFunction 1
  0039    | Merge
  0040    | End
  ========================================
  
  ==========_toml.datetime.hours==========
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
  
  =========_toml.datetime.minutes=========
  _toml.datetime.minutes = "0".."5" + "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'5'
  0003    | JumpIfFailure 3 -> 10
  0006    | ParseCodepointRange '0'..'9'
  0009    | Merge
  0010    | End
  ========================================
  
  =========_toml.datetime.seconds=========
  _toml.datetime.seconds = ("0".."5" + "0".."9") | "60"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '0'..'5'
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseCodepointRange '0'..'9'
  0010    | Merge
  0011    | Or 11 -> 17
  0014    | CallTailFunctionConstant2 326: "60"
  0017    | End
  ========================================
  
  =====_toml.datetime.time_numoffset======
  _toml.datetime.time_numoffset = ("+" | "-") + _toml.datetime.hours + ":" + _toml.datetime.minutes
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '+'
  0003    | Or 3 -> 8
  0006    | ParseChar '-'
  0008    | JumpIfFailure 8 -> 15
  0011    | CallFunctionConstant2 322: _toml.datetime.hours
  0014    | Merge
  0015    | JumpIfFailure 15 -> 21
  0018    | ParseChar ':'
  0020    | Merge
  0021    | JumpIfFailure 21 -> 28
  0024    | CallFunctionConstant2 323: _toml.datetime.minutes
  0027    | Merge
  0028    | End
  ========================================
  
  ==========toml.datetime.local===========
  toml.datetime.local = toml.datetime.local_date + ("T" | "t" | " ") + toml.datetime.local_time
  ========================================
  0000    | CallFunctionConstant2 313: toml.datetime.local_date
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
  0024    | CallFunctionConstant2 314: toml.datetime.local_time
  0027    | Merge
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
  0001    | CallFunctionConstant2 327: toml.number.binary_integer
  0004    | Or 4 -> 45
  0007    | SetInputMark
  0008    | CallFunctionConstant2 328: toml.number.octal_integer
  0011    | Or 11 -> 45
  0014    | SetInputMark
  0015    | CallFunctionConstant2 329: toml.number.hex_integer
  0018    | Or 18 -> 45
  0021    | SetInputMark
  0022    | CallFunctionConstant2 330: toml.number.infinity
  0025    | Or 25 -> 45
  0028    | SetInputMark
  0029    | CallFunctionConstant2 331: toml.number.not_a_number
  0032    | Or 32 -> 45
  0035    | SetInputMark
  0036    | CallFunctionConstant2 332: toml.number.float
  0039    | Or 39 -> 45
  0042    | CallTailFunctionConstant2 333: toml.number.integer
  0045    | End
  ========================================
  
  =================@fn334=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn335=================
  skip("_") < peek(binary_numeral)
  ========================================
  0000    | GetConstant2 302: skip
  0003    | PushChar '_'
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 18
  0010    | GetConstant 29: peek
  0012    | GetConstant2 339: binary_numeral
  0015    | CallFunction 1
  0017    | TakeLeft
  0018    | End
  ========================================
  
  =================@fn333=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(binary_numeral))
  ========================================
  0000    | GetConstant 81: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 337: @fn334
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 37: maybe
  0013    | GetConstant2 338: @fn335
  0016    | CallFunction 1
  0018    | Merge
  0019    | End
  ========================================
  
  =================@fn337=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn336=================
  array_sep(binary_digit, maybe("_"))
  ========================================
  0000    | GetConstant 81: array_sep
  0002    | GetConstant 53: binary_digit
  0004    | GetConstant2 341: @fn337
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
  0000    | GetConstant 51: Digits
  0002    | CallFunctionConstant2 334: "0b"
  0005    | TakeRight 5 -> 30
  0008    | GetConstant2 335: one_or_both
  0011    | GetConstant2 336: @fn333
  0014    | GetConstant2 340: @fn336
  0017    | CallFunction 2
  0019    | Destructure 78: Digits
  0021    | TakeRight 21 -> 30
  0024    | GetConstant 54: Num.FromBinaryDigits
  0026    | GetBoundLocalMove 0
  0028    | CallTailFunction 1
  0030    | End
  ========================================
  
  =================@fn339=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn340=================
  skip("_") < peek(octal_numeral)
  ========================================
  0000    | GetConstant2 302: skip
  0003    | PushChar '_'
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 18
  0010    | GetConstant 29: peek
  0012    | GetConstant2 346: octal_numeral
  0015    | CallFunction 1
  0017    | TakeLeft
  0018    | End
  ========================================
  
  =================@fn338=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(octal_numeral))
  ========================================
  0000    | GetConstant 81: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 344: @fn339
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 37: maybe
  0013    | GetConstant2 345: @fn340
  0016    | CallFunction 1
  0018    | Merge
  0019    | End
  ========================================
  
  =================@fn342=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn341=================
  array_sep(octal_digit, maybe("_"))
  ========================================
  0000    | GetConstant 81: array_sep
  0002    | GetConstant 64: octal_digit
  0004    | GetConstant2 348: @fn342
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
  0000    | GetConstant 51: Digits
  0002    | CallFunctionConstant2 342: "0o"
  0005    | TakeRight 5 -> 30
  0008    | GetConstant2 335: one_or_both
  0011    | GetConstant2 343: @fn338
  0014    | GetConstant2 347: @fn341
  0017    | CallFunction 2
  0019    | Destructure 79: Digits
  0021    | TakeRight 21 -> 30
  0024    | GetConstant 65: Num.FromOctalDigits
  0026    | GetBoundLocalMove 0
  0028    | CallTailFunction 1
  0030    | End
  ========================================
  
  =================@fn344=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn345=================
  skip("_") < peek(hex_numeral)
  ========================================
  0000    | GetConstant2 302: skip
  0003    | PushChar '_'
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 17
  0010    | GetConstant 29: peek
  0012    | GetConstant 198: hex_numeral
  0014    | CallFunction 1
  0016    | TakeLeft
  0017    | End
  ========================================
  
  =================@fn343=================
  array_sep(0, maybe("_")) + maybe(skip("_") < peek(hex_numeral))
  ========================================
  0000    | GetConstant 81: array_sep
  0002    | PushNumberStringZero
  0003    | GetConstant2 351: @fn344
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 37: maybe
  0013    | GetConstant2 352: @fn345
  0016    | CallFunction 1
  0018    | Merge
  0019    | End
  ========================================
  
  =================@fn347=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn346=================
  array_sep(hex_digit, maybe("_"))
  ========================================
  0000    | GetConstant 81: array_sep
  0002    | GetConstant 67: hex_digit
  0004    | GetConstant2 354: @fn347
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
  0000    | GetConstant 51: Digits
  0002    | CallFunctionConstant2 349: "0x"
  0005    | TakeRight 5 -> 30
  0008    | GetConstant2 335: one_or_both
  0011    | GetConstant2 350: @fn343
  0014    | GetConstant2 353: @fn346
  0017    | CallFunction 2
  0019    | Destructure 80: Digits
  0021    | TakeRight 21 -> 30
  0024    | GetConstant 68: Num.FromHexDigits
  0026    | GetBoundLocalMove 0
  0028    | CallTailFunction 1
  0030    | End
  ========================================
  
  =================@fn348=================
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
  0000    | GetConstant 37: maybe
  0002    | GetConstant2 355: @fn348
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 14
  0010    | CallFunctionConstant2 356: "inf"
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn349=================
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
  0000    | GetConstant 37: maybe
  0002    | GetConstant2 357: @fn349
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 14
  0010    | CallFunctionConstant2 358: "nan"
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn350=================
  _toml.number.sign +
    _toml.number.integer_part + (
      (_toml.number.fraction_part + maybe(_toml.number.exponent_part)) |
      _toml.number.exponent_part
    )
  ========================================
  0000    | CallFunctionConstant2 360: _toml.number.sign
  0003    | JumpIfFailure 3 -> 10
  0006    | CallFunctionConstant2 361: _toml.number.integer_part
  0009    | Merge
  0010    | JumpIfFailure 10 -> 35
  0013    | SetInputMark
  0014    | CallFunctionConstant2 362: _toml.number.fraction_part
  0017    | JumpIfFailure 17 -> 28
  0020    | GetConstant 37: maybe
  0022    | GetConstant2 363: _toml.number.exponent_part
  0025    | CallFunction 1
  0027    | Merge
  0028    | Or 28 -> 34
  0031    | CallFunctionConstant2 363: _toml.number.exponent_part
  0034    | Merge
  0035    | End
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
  0000    | GetConstant 35: as_number
  0002    | GetConstant2 359: @fn350
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn355=================
  "-" | skip("+")
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 13
  0006    | GetConstant2 302: skip
  0009    | PushChar '+'
  0011    | CallTailFunction 1
  0013    | End
  ========================================
  
  ===========_toml.number.sign============
  _toml.number.sign = maybe("-" | skip("+"))
  ========================================
  0000    | GetConstant 37: maybe
  0002    | GetConstant2 364: @fn355
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  =================@fn356=================
  maybe("_") > numeral
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 11
  0009    | CallTailFunctionConstant 4: numeral
  0011    | End
  ========================================
  
  =======_toml.number.integer_part========
  _toml.number.integer_part =
    ("1".."9" + many(maybe("_") > numeral)) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 15
  0007    | GetConstant 0: many
  0009    | GetConstant2 365: @fn356
  0012    | CallFunction 1
  0014    | Merge
  0015    | Or 15 -> 20
  0018    | CallTailFunctionConstant 4: numeral
  0020    | End
  ========================================
  
  =================@fn357=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
  0002    | PushChar '_'
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.fraction_part=======
  _toml.number.fraction_part = "." + many_sep(numerals, maybe("_"))
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 15
  0005    | GetConstant 154: many_sep
  0007    | GetConstant 39: numerals
  0009    | GetConstant2 366: @fn357
  0012    | CallFunction 2
  0014    | Merge
  0015    | End
  ========================================
  
  =================@fn358=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
  ========================================
  
  =================@fn359=================
  maybe("_")
  ========================================
  0000    | GetConstant 37: maybe
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
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 37: maybe
  0013    | GetConstant2 367: @fn358
  0016    | CallFunction 1
  0018    | Merge
  0019    | JumpIfFailure 19 -> 32
  0022    | GetConstant 154: many_sep
  0024    | GetConstant 39: numerals
  0026    | GetConstant2 368: @fn359
  0029    | CallFunction 2
  0031    | Merge
  0032    | End
  ========================================
  
  =================@fn360=================
  _toml.number.sign +
    _toml.number.integer_part
  ========================================
  0000    | CallFunctionConstant2 360: _toml.number.sign
  0003    | JumpIfFailure 3 -> 10
  0006    | CallFunctionConstant2 361: _toml.number.integer_part
  0009    | Merge
  0010    | End
  ========================================
  
  ==========toml.number.integer===========
  toml.number.integer = as_number(
    _toml.number.sign +
    _toml.number.integer_part
  )
  ========================================
  0000    | GetConstant 35: as_number
  0002    | GetConstant2 369: @fn360
  0005    | CallTailFunction 1
  0007    | End
  ========================================
  
  ==============toml.boolean==============
  toml.boolean = boolean("true", "false")
  ========================================
  0000    | GetConstant 172: boolean
  0002    | GetConstant 173: "true"
  0004    | GetConstant 174: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn362=================
  surround(elem, _toml.ws)
  ========================================
  0000    | GetConstant 74: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 163: surround
  0005    | GetBoundLocalMove 0
  0007    | GetConstant 223: _toml.ws
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn363=================
  surround(",", _toml.ws)
  ========================================
  0000    | GetConstant 163: surround
  0002    | PushChar ','
  0004    | GetConstant 223: _toml.ws
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn361=================
  array_sep(surround(elem, _toml.ws), ",") < maybe(surround(",", _toml.ws))
  ========================================
  0000    | GetConstant 74: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 81: array_sep
  0005    | GetConstant2 371: @fn362
  0008    | CreateClosure 1
  0010    | CaptureLocal 0
  0012    | PushChar ','
  0014    | CallFunction 2
  0016    | JumpIfFailure 16 -> 27
  0019    | GetConstant 37: maybe
  0021    | GetConstant2 372: @fn363
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
  0000    | ParseChar '['
  0002    | TakeRight 2 -> 7
  0005    | CallFunctionConstant 223: _toml.ws
  0007    | TakeRight 7 -> 22
  0010    | GetConstant 78: default
  0012    | GetConstant2 370: @fn361
  0015    | CreateClosure 1
  0017    | CaptureLocal 0
  0019    | PushEmptyArray
  0020    | CallFunction 2
  0022    | JumpIfFailure 22 -> 28
  0025    | CallFunctionConstant 223: _toml.ws
  0027    | TakeLeft
  0028    | JumpIfFailure 28 -> 34
  0031    | ParseChar ']'
  0033    | TakeLeft
  0034    | End
  ========================================
  
  ===========toml.inline_table============
  toml.inline_table(value) =
    _toml.empty_inline_table | _toml.nonempty_inline_table(value) -> InlineDoc $
    _Toml.Doc.Value(InlineDoc)
  ========================================
  0000    | GetConstant2 373: InlineDoc
  0003    | SetInputMark
  0004    | CallFunctionConstant2 374: _toml.empty_inline_table
  0007    | Or 7 -> 17
  0010    | GetConstant2 375: _toml.nonempty_inline_table
  0013    | GetBoundLocalMove 0
  0015    | CallFunction 1
  0017    | Destructure 81: InlineDoc
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 217: _Toml.Doc.Value
  0024    | GetBoundLocalMove 1
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  ========_toml.empty_inline_table========
  _toml.empty_inline_table = "{" > maybe(spaces) < "}" $ _Toml.Doc.Empty
  ========================================
  0000    | ParseChar '{'
  0002    | TakeRight 2 -> 11
  0005    | GetConstant 37: maybe
  0007    | GetConstant 236: spaces
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 17
  0014    | ParseChar '}'
  0016    | TakeLeft
  0017    | TakeRight 17 -> 22
  0020    | CallTailFunctionConstant 222: _Toml.Doc.Empty
  0022    | End
  ========================================
  
  ======_toml.nonempty_inline_table=======
  _toml.nonempty_inline_table(value) =
    "{" > maybe(spaces) >
    _toml.inline_table_pair(value, _Toml.Doc.Empty) -> DocWithFirstPair &
    _toml.inline_table_body(value, DocWithFirstPair)
    < maybe(spaces) < "}"
  ========================================
  0000    | GetConstant2 376: DocWithFirstPair
  0003    | ParseChar '{'
  0005    | TakeRight 5 -> 14
  0008    | GetConstant 37: maybe
  0010    | GetConstant 236: spaces
  0012    | CallFunction 1
  0014    | TakeRight 14 -> 26
  0017    | GetConstant2 377: _toml.inline_table_pair
  0020    | GetBoundLocal 0
  0022    | CallFunctionConstant 222: _Toml.Doc.Empty
  0024    | CallFunction 2
  0026    | Destructure 82: DocWithFirstPair
  0028    | TakeRight 28 -> 56
  0031    | GetConstant2 378: _toml.inline_table_body
  0034    | GetBoundLocalMove 0
  0036    | GetBoundLocalMove 1
  0038    | CallFunction 2
  0040    | JumpIfFailure 40 -> 50
  0043    | GetConstant 37: maybe
  0045    | GetConstant 236: spaces
  0047    | CallFunction 1
  0049    | TakeLeft
  0050    | JumpIfFailure 50 -> 56
  0053    | ParseChar '}'
  0055    | TakeLeft
  0056    | End
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
  0000    | GetConstant2 256: Key
  0003    | GetConstant 227: Val
  0005    | GetConstant 37: maybe
  0007    | GetConstant 236: spaces
  0009    | CallFunction 1
  0011    | TakeRight 11 -> 18
  0014    | CallFunctionConstant 233: _toml.path
  0016    | Destructure 83: Key
  0018    | TakeRight 18 -> 27
  0021    | GetConstant 37: maybe
  0023    | GetConstant 236: spaces
  0025    | CallFunction 1
  0027    | TakeRight 27 -> 32
  0030    | ParseChar '='
  0032    | TakeRight 32 -> 41
  0035    | GetConstant 37: maybe
  0037    | GetConstant 236: spaces
  0039    | CallFunction 1
  0041    | TakeRight 41 -> 48
  0044    | CallFunctionLocal 0
  0046    | Destructure 84: Val
  0048    | TakeRight 48 -> 70
  0051    | GetConstant 37: maybe
  0053    | GetConstant 236: spaces
  0055    | CallFunction 1
  0057    | TakeRight 57 -> 70
  0060    | GetConstant 231: _Toml.Doc.InsertAtPath
  0062    | GetBoundLocalMove 1
  0064    | GetBoundLocalMove 2
  0066    | GetBoundLocalMove 3
  0068    | CallTailFunction 3
  0070    | End
  ========================================
  
  ========_toml.inline_table_body=========
  _toml.inline_table_body(value, Doc) =
    "," > _toml.inline_table_pair(value, Doc) -> NewDoc ?
    _toml.inline_table_body(value, NewDoc) :
    const(Doc)
  ========================================
  0000    | GetConstant 228: NewDoc
  0002    | SetInputMark
  0003    | ParseChar ','
  0005    | TakeRight 5 -> 17
  0008    | GetConstant2 377: _toml.inline_table_pair
  0011    | GetBoundLocal 0
  0013    | GetBoundLocal 1
  0015    | CallFunction 2
  0017    | Destructure 85: NewDoc
  0019    | ConditionalThen 19 -> 34
  0022    | GetConstant2 378: _toml.inline_table_body
  0025    | GetBoundLocalMove 0
  0027    | GetBoundLocalMove 2
  0029    | CallTailFunction 2
  0031    | Jump 31 -> 40
  0034    | GetConstant 34: const
  0036    | GetBoundLocalMove 1
  0038    | CallTailFunction 1
  0040    | End
  ========================================
  
  ==============toml.tagged===============
  toml.tagged = toml.custom(toml.tagged_value)
  ========================================
  0000    | GetConstant 209: toml.custom
  0002    | GetConstant2 379: toml.tagged_value
  0005    | CallTailFunction 1
  0007    | End
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
  0001    | CallFunctionConstant2 294: toml.string
  0004    | Or 4 -> 177
  0007    | SetInputMark
  0008    | GetConstant2 380: _toml.tag
  0011    | GetConstant2 381: "datetime"
  0014    | GetConstant2 382: "offset"
  0017    | GetConstant2 311: toml.datetime.offset
  0020    | CallFunction 3
  0022    | Or 22 -> 177
  0025    | SetInputMark
  0026    | GetConstant2 380: _toml.tag
  0029    | GetConstant2 381: "datetime"
  0032    | GetConstant2 383: "local"
  0035    | GetConstant2 312: toml.datetime.local
  0038    | CallFunction 3
  0040    | Or 40 -> 177
  0043    | SetInputMark
  0044    | GetConstant2 380: _toml.tag
  0047    | GetConstant2 381: "datetime"
  0050    | GetConstant2 384: "date-local"
  0053    | GetConstant2 313: toml.datetime.local_date
  0056    | CallFunction 3
  0058    | Or 58 -> 177
  0061    | SetInputMark
  0062    | GetConstant2 380: _toml.tag
  0065    | GetConstant2 381: "datetime"
  0068    | GetConstant2 385: "time-local"
  0071    | GetConstant2 314: toml.datetime.local_time
  0074    | CallFunction 3
  0076    | Or 76 -> 177
  0079    | SetInputMark
  0080    | CallFunctionConstant2 327: toml.number.binary_integer
  0083    | Or 83 -> 177
  0086    | SetInputMark
  0087    | CallFunctionConstant2 328: toml.number.octal_integer
  0090    | Or 90 -> 177
  0093    | SetInputMark
  0094    | CallFunctionConstant2 329: toml.number.hex_integer
  0097    | Or 97 -> 177
  0100    | SetInputMark
  0101    | GetConstant2 380: _toml.tag
  0104    | GetConstant2 386: "float"
  0107    | GetConstant2 387: "infinity"
  0110    | GetConstant2 330: toml.number.infinity
  0113    | CallFunction 3
  0115    | Or 115 -> 177
  0118    | SetInputMark
  0119    | GetConstant2 380: _toml.tag
  0122    | GetConstant2 386: "float"
  0125    | GetConstant2 388: "not-a-number"
  0128    | GetConstant2 331: toml.number.not_a_number
  0131    | CallFunction 3
  0133    | Or 133 -> 177
  0136    | SetInputMark
  0137    | CallFunctionConstant2 332: toml.number.float
  0140    | Or 140 -> 177
  0143    | SetInputMark
  0144    | CallFunctionConstant2 333: toml.number.integer
  0147    | Or 147 -> 177
  0150    | SetInputMark
  0151    | CallFunctionConstant2 297: toml.boolean
  0154    | Or 154 -> 177
  0157    | SetInputMark
  0158    | GetConstant2 298: toml.array
  0161    | GetConstant2 379: toml.tagged_value
  0164    | CallFunction 1
  0166    | Or 166 -> 177
  0169    | GetConstant2 299: toml.inline_table
  0172    | GetConstant2 379: toml.tagged_value
  0175    | CallTailFunction 1
  0177    | End
  ========================================
  
  ===============_toml.tag================
  _toml.tag(Type, Subtype, value) =
    value -> Value $ {"type": Type, "subtype": Subtype, "value": Value}
  ========================================
  0000    | GetConstant 145: Value
  0002    | CallFunctionLocal 2
  0004    | Destructure 86: Value
  0006    | TakeRight 6 -> 33
  0009    | GetConstantMutable2 389: {_0_, _1_, _2_}
  0012    | GetConstant2 266: "type"
  0015    | GetBoundLocalMove 0
  0017    | InsertKeyVal 0
  0019    | GetConstant2 390: "subtype"
  0022    | GetBoundLocalMove 1
  0024    | InsertKeyVal 1
  0026    | GetConstant2 269: "value"
  0029    | GetBoundLocalMove 3
  0031    | InsertKeyVal 2
  0033    | End
  ========================================
  
  ======ast.with_operator_precedence======
  ast.with_operator_precedence(operand, prefix, infix, postfix) =
    _ast.with_precedence_start(operand, prefix, infix, postfix, $0)
  ========================================
  0000    | GetConstant2 391: _ast.with_precedence_start
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | GetBoundLocalMove 2
  0009    | GetBoundLocalMove 3
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
  0000    | GetConstant2 392: PrefixBindingPower
  0003    | GetConstant2 393: PrefixNode
  0006    | GetConstant2 394: Node
  0009    | SetInputMark
  0010    | CallFunctionLocal 1
  0012    | Destructure 87: ({"power": PrefixBindingPower} + PrefixNode)
  0014    | ConditionalThen 14 -> 89
  0017    | GetConstant2 391: _ast.with_precedence_start
  0020    | GetBoundLocal 0
  0022    | GetBoundLocal 1
  0024    | GetBoundLocal 2
  0026    | GetBoundLocal 3
  0028    | GetBoundLocalMove 5
  0030    | CallFunction 5
  0032    | Destructure 88: Node
  0034    | TakeRight 34 -> 86
  0037    | GetConstant2 395: _ast.with_precedence_rest
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
  0060    | GetConstantMutable2 396: {_0_}
  0063    | GetConstant2 397: "prefixed"
  0066    | GetBoundLocal 7
  0068    | InsertKeyVal 0
  0070    | JumpIfFailure 70 -> 83
  0073    | GetConstant2 398: _Ast.MergePos
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
  0096    | GetConstant2 395: _ast.with_precedence_rest
  0099    | GetBoundLocalMove 0
  0101    | GetBoundLocalMove 1
  0103    | GetBoundLocalMove 2
  0105    | GetBoundLocalMove 3
  0107    | GetBoundLocalMove 4
  0109    | GetBoundLocalMove 7
  0111    | CallTailFunction 6
  0113    | End
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
  0000    | GetConstant2 399: RightBindingPower
  0003    | GetConstant2 400: PostfixNode
  0006    | GetConstant2 401: NextLeftBindingPower
  0009    | GetConstant2 402: InfixNode
  0012    | GetConstant2 403: RightNode
  0015    | SetInputMark
  0016    | CallFunctionLocal 3
  0018    | Destructure 90: ({"power": RightBindingPower} + PostfixNode)
  0020    | TakeRight 20 -> 36
  0023    | GetConstant 34: const
  0025    | GetConstant2 404: Is.LessThan
  0028    | GetBoundLocal 4
  0030    | GetBoundLocal 6
  0032    | CallFunction 2
  0034    | CallFunction 1
  0036    | ConditionalThen 36 -> 91
  0039    | GetConstant2 395: _ast.with_precedence_rest
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
  0062    | GetConstantMutable2 405: {_0_}
  0065    | GetConstant2 406: "postfixed"
  0068    | GetBoundLocal 5
  0070    | InsertKeyVal 0
  0072    | JumpIfFailure 72 -> 85
  0075    | GetConstant2 398: _Ast.MergePos
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
  0099    | GetConstant 34: const
  0101    | GetConstant2 404: Is.LessThan
  0104    | GetBoundLocal 4
  0106    | GetBoundLocalMove 6
  0108    | CallFunction 2
  0110    | CallFunction 1
  0112    | ConditionalThen 112 -> 194
  0115    | GetConstant2 391: _ast.with_precedence_start
  0118    | GetBoundLocal 0
  0120    | GetBoundLocal 1
  0122    | GetBoundLocal 2
  0124    | GetBoundLocal 3
  0126    | GetBoundLocalMove 8
  0128    | CallFunction 5
  0130    | Destructure 92: RightNode
  0132    | TakeRight 132 -> 191
  0135    | GetConstant2 395: _ast.with_precedence_rest
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
  0158    | GetConstantMutable2 407: {_0_, _1_}
  0161    | GetConstant2 408: "left"
  0164    | GetBoundLocal 5
  0166    | InsertKeyVal 0
  0168    | GetConstant2 409: "right"
  0171    | GetBoundLocal 10
  0173    | InsertKeyVal 1
  0175    | JumpIfFailure 175 -> 188
  0178    | GetConstant2 398: _Ast.MergePos
  0181    | GetBoundLocalMove 5
  0183    | GetBoundLocalMove 10
  0185    | CallFunction 2
  0187    | Merge
  0188    | Merge
  0189    | CallTailFunction 6
  0191    | Jump 191 -> 200
  0194    | GetConstant 34: const
  0196    | GetBoundLocalMove 5
  0198    | CallTailFunction 1
  0200    | End
  ========================================
  
  ==============Is.LessThan===============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 93: B
  0005    | ConditionalThen 5 -> 14
  0008    | CallTailFunctionConstant2 274: @Fail
  0011    | Jump 11 -> 18
  0014    | GetBoundLocalMove 0
  0016    | Destructure 94: ..B
  0018    | End
  ========================================
  
  =============_Ast.MergePos==============
  _Ast.MergePos(Left, Right) = {
    ...(Left -> {"startpos": StartPos, ..._} ? {"startpos": StartPos} : {}),
    ...(Right -> {"endpos": EndPos, ..._} ? {"endpos": EndPos} : {}),
  }
  ========================================
  0000    | GetConstant2 410: StartPos
  0003    | PushUnderscoreVar
  0004    | GetConstant2 411: EndPos
  0007    | PushEmptyObject
  0008    | JumpIfFailure 8 -> 34
  0011    | SetInputMark
  0012    | GetBoundLocalMove 0
  0014    | Destructure 95: ({"startpos": StartPos} + _)
  0016    | ConditionalThen 16 -> 32
  0019    | GetConstantMutable2 412: {_0_}
  0022    | GetConstant2 413: "startpos"
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
  0045    | GetConstantMutable2 414: {_0_}
  0048    | GetConstant2 415: "endpos"
  0051    | GetBoundLocalMove 4
  0053    | InsertKeyVal 0
  0055    | Jump 55 -> 59
  0058    | PushEmptyObject
  0059    | Merge
  0060    | End
  ========================================
  
  ================ast.node================
  ast.node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | GetConstant 145: Value
  0002    | CallFunctionLocal 0
  0004    | Destructure 97: Value
  0006    | TakeRight 6 -> 26
  0009    | GetConstantMutable2 416: {_0_, _1_}
  0012    | GetConstant2 266: "type"
  0015    | GetBoundLocalMove 1
  0017    | InsertKeyVal 0
  0019    | GetConstant2 269: "value"
  0022    | GetBoundLocalMove 2
  0024    | InsertKeyVal 1
  0026    | End
  ========================================
  
  ============ast.prefix_node=============
  ast.prefix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 22
  0005    | GetConstantMutable2 417: {_0_, _1_}
  0008    | GetConstant2 266: "type"
  0011    | GetBoundLocalMove 1
  0013    | InsertKeyVal 0
  0015    | GetConstant2 418: "power"
  0018    | GetBoundLocalMove 2
  0020    | InsertKeyVal 1
  0022    | End
  ========================================
  
  =============ast.infix_node=============
  ast.infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    op $ {"type": Type, "power": [LeftBindingPower, RightBindingPower]}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 31
  0005    | GetConstantMutable2 419: {_0_, _1_}
  0008    | GetConstant2 266: "type"
  0011    | GetBoundLocalMove 1
  0013    | InsertKeyVal 0
  0015    | GetConstant2 418: "power"
  0018    | GetConstantMutable2 420: [_, _]
  0021    | GetBoundLocalMove 2
  0023    | InsertAtIndex 0
  0025    | GetBoundLocalMove 3
  0027    | InsertAtIndex 1
  0029    | InsertKeyVal 1
  0031    | End
  ========================================
  
  ============ast.postfix_node============
  ast.postfix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 22
  0005    | GetConstantMutable2 421: {_0_, _1_}
  0008    | GetConstant2 266: "type"
  0011    | GetBoundLocalMove 1
  0013    | InsertKeyVal 0
  0015    | GetConstant2 418: "power"
  0018    | GetBoundLocalMove 2
  0020    | InsertKeyVal 1
  0022    | End
  ========================================
  
  ==========ast.with_offset_pos===========
  ast.with_offset_pos(node) =
    @input.offset -> StartOffset &
    node -> Node &
    @input.offset -> EndOffset $
    {...Node, "startpos": StartOffset, "endpos": EndOffset}
  ========================================
  0000    | GetConstant2 422: StartOffset
  0003    | GetConstant2 394: Node
  0006    | GetConstant2 423: EndOffset
  0009    | CallFunctionConstant 31: @input.offset
  0011    | Destructure 98: StartOffset
  0013    | TakeRight 13 -> 20
  0016    | CallFunctionLocal 0
  0018    | Destructure 99: Node
  0020    | TakeRight 20 -> 58
  0023    | CallFunctionConstant 31: @input.offset
  0025    | Destructure 100: EndOffset
  0027    | TakeRight 27 -> 58
  0030    | PushEmptyObject
  0031    | JumpIfFailure 31 -> 37
  0034    | GetBoundLocalMove 2
  0036    | Merge
  0037    | JumpIfFailure 37 -> 58
  0040    | GetConstantMutable2 424: {_0_, _1_}
  0043    | GetConstant2 413: "startpos"
  0046    | GetBoundLocalMove 1
  0048    | InsertKeyVal 0
  0050    | GetConstant2 415: "endpos"
  0053    | GetBoundLocalMove 3
  0055    | InsertKeyVal 1
  0057    | Merge
  0058    | End
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
  0000    | GetConstant2 425: StartLine
  0003    | GetConstant2 426: StartLineOffset
  0006    | GetConstant2 394: Node
  0009    | GetConstant2 427: EndLine
  0012    | GetConstant2 428: EndLineOffset
  0015    | CallFunctionConstant2 429: @input.line
  0018    | Destructure 101: StartLine
  0020    | TakeRight 20 -> 28
  0023    | CallFunctionConstant2 430: @input.line_offset
  0026    | Destructure 102: StartLineOffset
  0028    | TakeRight 28 -> 35
  0031    | CallFunctionLocal 0
  0033    | Destructure 103: Node
  0035    | TakeRight 35 -> 43
  0038    | CallFunctionConstant2 429: @input.line
  0041    | Destructure 104: EndLine
  0043    | TakeRight 43 -> 112
  0046    | CallFunctionConstant2 430: @input.line_offset
  0049    | Destructure 105: EndLineOffset
  0051    | TakeRight 51 -> 112
  0054    | PushEmptyObject
  0055    | JumpIfFailure 55 -> 61
  0058    | GetBoundLocalMove 3
  0060    | Merge
  0061    | JumpIfFailure 61 -> 112
  0064    | GetConstantMutable2 431: {_0_, _1_}
  0067    | GetConstant2 413: "startpos"
  0070    | GetConstantMutable2 432: {_0_, _1_}
  0073    | GetConstant2 433: "line"
  0076    | GetBoundLocalMove 1
  0078    | InsertKeyVal 0
  0080    | GetConstant2 382: "offset"
  0083    | GetBoundLocalMove 2
  0085    | InsertKeyVal 1
  0087    | InsertKeyVal 0
  0089    | GetConstant2 415: "endpos"
  0092    | GetConstantMutable2 434: {_0_, _1_}
  0095    | GetConstant2 433: "line"
  0098    | GetBoundLocalMove 4
  0100    | InsertKeyVal 0
  0102    | GetConstant2 382: "offset"
  0105    | GetBoundLocalMove 5
  0107    | InsertKeyVal 1
  0109    | InsertKeyVal 1
  0111    | Merge
  0112    | End
  ========================================
  
  ===============Str.Length===============
  Str.Length(S) = S -> ("\u000000".. * L) $ L
  ========================================
  0000    | PushCharVar L
  0002    | GetBoundLocalMove 0
  0004    | Destructure 106: ("\x00".. * L) (esc)
  0006    | TakeRight 6 -> 11
  0009    | GetBoundLocalMove 1
  0011    | End
  ========================================
  
  ================Num.Dec=================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant2 435: @Subtract
  0003    | GetBoundLocalMove 0
  0005    | PushNumberOne
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Abs=================
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
  
  ================Num.Min=================
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
  
  ==============Array.First===============
  Array.First(A) = A -> [F, ..._] & F
  ========================================
  0000    | PushCharVar F
  0002    | PushUnderscoreVar
  0003    | GetBoundLocalMove 0
  0005    | Destructure 109: ([F] + _)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 1
  0012    | End
  ========================================
  
  ===============Array.Rest===============
  Array.Rest(A) = A -> [_, ...R] & R
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar R
  0003    | GetBoundLocalMove 0
  0005    | Destructure 110: ([_] + R)
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 2
  0012    | End
  ========================================
  
  =============Array.Reverse==============
  Array.Reverse(A) = _Array.Reverse(A, [])
  ========================================
  0000    | GetConstant2 436: _Array.Reverse
  0003    | GetBoundLocalMove 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Array.Reverse=============
  _Array.Reverse(A, Acc) =
    A -> [First, ...Rest] ? _Array.Reverse(Rest, [First, ...Acc]) : Acc
  ========================================
  0000    | GetConstant 96: First
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 111: ([First] + Rest)
  0009    | ConditionalThen 9 -> 35
  0012    | GetConstant2 436: _Array.Reverse
  0015    | GetBoundLocalMove 3
  0017    | GetConstantMutable2 437: [_]
  0020    | GetBoundLocalMove 2
  0022    | InsertAtIndex 0
  0024    | JumpIfFailure 24 -> 30
  0027    | GetBoundLocalMove 1
  0029    | Merge
  0030    | CallTailFunction 2
  0032    | Jump 32 -> 37
  0035    | GetBoundLocalMove 1
  0037    | End
  ========================================
  
  ===============Array.Map================
  Array.Map(A, Fn) = _Array.Map(A, Fn, [])
  ========================================
  0000    | GetConstant2 438: _Array.Map
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushEmptyArray
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===============_Array.Map===============
  _Array.Map(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.Map(Rest, Fn, [...Acc, Fn(First)]) : Acc
  ========================================
  0000    | GetConstant 96: First
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 112: ([First] + Rest)
  0009    | ConditionalThen 9 -> 46
  0012    | GetConstant2 438: _Array.Map
  0015    | GetBoundLocalMove 4
  0017    | GetBoundLocal 1
  0019    | PushEmptyArray
  0020    | JumpIfFailure 20 -> 26
  0023    | GetBoundLocalMove 2
  0025    | Merge
  0026    | JumpIfFailure 26 -> 41
  0029    | GetConstantMutable2 439: [_]
  0032    | GetBoundLocalMove 1
  0034    | GetBoundLocalMove 3
  0036    | CallFunction 1
  0038    | InsertAtIndex 0
  0040    | Merge
  0041    | CallTailFunction 3
  0043    | Jump 43 -> 48
  0046    | GetBoundLocalMove 2
  0048    | End
  ========================================
  
  ==============Array.Filter==============
  Array.Filter(A, Pred) = _Array.Filter(A, Pred, [])
  ========================================
  0000    | GetConstant2 440: _Array.Filter
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
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
  0000    | GetConstant 96: First
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 113: ([First] + Rest)
  0009    | ConditionalThen 9 -> 57
  0012    | GetConstant2 440: _Array.Filter
  0015    | GetBoundLocalMove 4
  0017    | GetBoundLocal 1
  0019    | SetInputMark
  0020    | GetBoundLocalMove 1
  0022    | GetBoundLocal 3
  0024    | CallFunction 1
  0026    | ConditionalThen 26 -> 50
  0029    | PushEmptyArray
  0030    | JumpIfFailure 30 -> 36
  0033    | GetBoundLocalMove 2
  0035    | Merge
  0036    | JumpIfFailure 36 -> 47
  0039    | GetConstantMutable2 441: [_]
  0042    | GetBoundLocalMove 3
  0044    | InsertAtIndex 0
  0046    | Merge
  0047    | Jump 47 -> 52
  0050    | GetBoundLocalMove 2
  0052    | CallTailFunction 3
  0054    | Jump 54 -> 59
  0057    | GetBoundLocalMove 2
  0059    | End
  ========================================
  
  ==============Array.Reject==============
  Array.Reject(A, Pred) = _Array.Reject(A, Pred, [])
  ========================================
  0000    | GetConstant2 442: _Array.Reject
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
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
  0000    | GetConstant 96: First
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 114: ([First] + Rest)
  0009    | ConditionalThen 9 -> 57
  0012    | GetConstant2 442: _Array.Reject
  0015    | GetBoundLocalMove 4
  0017    | GetBoundLocal 1
  0019    | SetInputMark
  0020    | GetBoundLocalMove 1
  0022    | GetBoundLocal 3
  0024    | CallFunction 1
  0026    | ConditionalThen 26 -> 34
  0029    | GetBoundLocalMove 2
  0031    | Jump 31 -> 52
  0034    | PushEmptyArray
  0035    | JumpIfFailure 35 -> 41
  0038    | GetBoundLocalMove 2
  0040    | Merge
  0041    | JumpIfFailure 41 -> 52
  0044    | GetConstantMutable2 443: [_]
  0047    | GetBoundLocalMove 3
  0049    | InsertAtIndex 0
  0051    | Merge
  0052    | CallTailFunction 3
  0054    | Jump 54 -> 59
  0057    | GetBoundLocalMove 2
  0059    | End
  ========================================
  
  ==============Array.Merge===============
  Array.Merge(A) = _Array.Merge(A, null)
  ========================================
  0000    | GetConstant2 444: _Array.Merge
  0003    | GetBoundLocalMove 0
  0005    | PushNull
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==============_Array.Merge==============
  _Array.Merge(A, Acc) =
    A -> [First, ...Rest] ? _Array.Merge(Rest, Acc + First) : Acc
  ========================================
  0000    | GetConstant 96: First
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 115: ([First] + Rest)
  0009    | ConditionalThen 9 -> 30
  0012    | GetConstant2 444: _Array.Merge
  0015    | GetBoundLocalMove 3
  0017    | GetBoundLocalMove 1
  0019    | JumpIfFailure 19 -> 25
  0022    | GetBoundLocalMove 2
  0024    | Merge
  0025    | CallTailFunction 2
  0027    | Jump 27 -> 32
  0030    | GetBoundLocalMove 1
  0032    | End
  ========================================
  
  =============Array.MapMerge=============
  Array.MapMerge(A, Fn) = _Array.MapMerge(A, Fn, null)
  ========================================
  0000    | GetConstant2 445: _Array.MapMerge
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
  0007    | PushNull
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.MapMerge=============
  _Array.MapMerge(A, Fn, Acc) =
    A -> [First, ...Rest] ? _Array.MapMerge(Rest, Fn, Acc + Fn(First)) : Acc
  ========================================
  0000    | GetConstant 96: First
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 116: ([First] + Rest)
  0009    | ConditionalThen 9 -> 36
  0012    | GetConstant2 445: _Array.MapMerge
  0015    | GetBoundLocalMove 4
  0017    | GetBoundLocal 1
  0019    | GetBoundLocalMove 2
  0021    | JumpIfFailure 21 -> 31
  0024    | GetBoundLocalMove 1
  0026    | GetBoundLocalMove 3
  0028    | CallFunction 1
  0030    | Merge
  0031    | CallTailFunction 3
  0033    | Jump 33 -> 38
  0036    | GetBoundLocalMove 2
  0038    | End
  ========================================
  
  ==============Array.Reduce==============
  Array.Reduce(A, Fn, Acc) =
    A -> [First, ...Rest] ? Array.Reduce(Rest, Fn, Fn(Acc, First)) : Acc
  ========================================
  0000    | GetConstant 96: First
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 0
  0007    | Destructure 117: ([First] + Rest)
  0009    | ConditionalThen 9 -> 32
  0012    | GetConstant2 446: Array.Reduce
  0015    | GetBoundLocalMove 4
  0017    | GetBoundLocal 1
  0019    | GetBoundLocalMove 1
  0021    | GetBoundLocalMove 2
  0023    | GetBoundLocalMove 3
  0025    | CallFunction 2
  0027    | CallTailFunction 3
  0029    | Jump 29 -> 34
  0032    | GetBoundLocalMove 2
  0034    | End
  ========================================
  
  ============Array.ZipObject=============
  Array.ZipObject(Ks, Vs) = _Array.ZipObject(Ks, Vs, {})
  ========================================
  0000    | GetConstant2 447: _Array.ZipObject
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
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
  0002    | GetConstant2 448: KsRest
  0005    | PushCharVar V
  0007    | GetConstant2 449: VsRest
  0010    | SetInputMark
  0011    | GetBoundLocalMove 0
  0013    | Destructure 118: ([K] + KsRest)
  0015    | TakeRight 15 -> 22
  0018    | GetBoundLocalMove 1
  0020    | Destructure 119: ([V] + VsRest)
  0022    | ConditionalThen 22 -> 57
  0025    | GetConstant2 447: _Array.ZipObject
  0028    | GetBoundLocalMove 4
  0030    | GetBoundLocalMove 6
  0032    | PushEmptyObject
  0033    | JumpIfFailure 33 -> 39
  0036    | GetBoundLocalMove 2
  0038    | Merge
  0039    | JumpIfFailure 39 -> 52
  0042    | GetConstantMutable2 450: {_0_}
  0045    | GetBoundLocalMove 3
  0047    | GetBoundLocalMove 5
  0049    | InsertKeyVal 0
  0051    | Merge
  0052    | CallTailFunction 3
  0054    | Jump 54 -> 59
  0057    | GetBoundLocalMove 2
  0059    | End
  ========================================
  
  =============Array.ZipPairs=============
  Array.ZipPairs(A1, A2) = _Array.ZipPairs(A1, A2, [])
  ========================================
  0000    | GetConstant2 451: _Array.ZipPairs
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
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
  0000    | GetConstant2 452: First1
  0003    | GetConstant2 453: Rest1
  0006    | GetConstant2 454: First2
  0009    | GetConstant2 455: Rest2
  0012    | SetInputMark
  0013    | GetBoundLocalMove 0
  0015    | Destructure 120: ([First1] + Rest1)
  0017    | TakeRight 17 -> 24
  0020    | GetBoundLocalMove 1
  0022    | Destructure 121: ([First2] + Rest2)
  0024    | ConditionalThen 24 -> 66
  0027    | GetConstant2 451: _Array.ZipPairs
  0030    | GetBoundLocalMove 4
  0032    | GetBoundLocalMove 6
  0034    | PushEmptyArray
  0035    | JumpIfFailure 35 -> 41
  0038    | GetBoundLocalMove 2
  0040    | Merge
  0041    | JumpIfFailure 41 -> 61
  0044    | GetConstantMutable2 456: [_]
  0047    | GetConstantMutable2 457: [_, _]
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
  
  =========Table.RotateClockwise==========
  Table.RotateClockwise(T) = Array.Map(Table.Transpose(T), Array.Reverse)
  ========================================
  0000    | GetConstant2 458: Array.Map
  0003    | GetConstant 115: Table.Transpose
  0005    | GetBoundLocalMove 0
  0007    | CallFunction 1
  0009    | GetConstant2 459: Array.Reverse
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  ======Table.RotateCounterClockwise======
  Table.RotateCounterClockwise(T) = Array.Reverse(Table.Transpose(T))
  ========================================
  0000    | GetConstant2 459: Array.Reverse
  0003    | GetConstant 115: Table.Transpose
  0005    | GetBoundLocalMove 0
  0007    | CallFunction 1
  0009    | CallTailFunction 1
  0011    | End
  ========================================
  
  ============Table.ZipObjects============
  Table.ZipObjects(Ks, Rows) = _Table.ZipObjects(Ks, Rows, [])
  ========================================
  0000    | GetConstant2 460: _Table.ZipObjects
  0003    | GetBoundLocalMove 0
  0005    | GetBoundLocalMove 1
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
  0000    | GetConstant 122: Row
  0002    | GetConstant 61: Rest
  0004    | SetInputMark
  0005    | GetBoundLocalMove 1
  0007    | Destructure 122: ([Row] + Rest)
  0009    | ConditionalThen 9 -> 49
  0012    | GetConstant2 460: _Table.ZipObjects
  0015    | GetBoundLocal 0
  0017    | GetBoundLocalMove 4
  0019    | PushEmptyArray
  0020    | JumpIfFailure 20 -> 26
  0023    | GetBoundLocalMove 2
  0025    | Merge
  0026    | JumpIfFailure 26 -> 44
  0029    | GetConstantMutable2 461: [_]
  0032    | GetConstant2 462: Array.ZipObject
  0035    | GetBoundLocalMove 0
  0037    | GetBoundLocalMove 3
  0039    | CallFunction 2
  0041    | InsertAtIndex 0
  0043    | Merge
  0044    | CallTailFunction 3
  0046    | Jump 46 -> 51
  0049    | GetBoundLocalMove 2
  0051    | End
  ========================================
  
  ================Obj.Size================
  Obj.Size(O) = _Obj.Size(O, 0)
  ========================================
  0000    | GetConstant2 463: _Obj.Size
  0003    | GetBoundLocalMove 0
  0005    | PushNumberZero
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============_Obj.Size================
  _Obj.Size(O, Acc) = O -> {_: _, ...Rest} ? _Obj.Size(Rest, Acc + 1) : Acc
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 61: Rest
  0003    | SetInputMark
  0004    | GetBoundLocalMove 0
  0006    | Destructure 123: ({_: _} + Rest)
  0008    | ConditionalThen 8 -> 28
  0011    | GetConstant2 463: _Obj.Size
  0014    | GetBoundLocalMove 3
  0016    | GetBoundLocalMove 1
  0018    | JumpIfFailure 18 -> 23
  0021    | PushNumberOne
  0022    | Merge
  0023    | CallTailFunction 2
  0025    | Jump 25 -> 30
  0028    | GetBoundLocalMove 1
  0030    | End
  ========================================
  
  ================Obj.Keys================
  Obj.Keys(O) = _Obj.Keys(O, [])
  ========================================
  0000    | GetConstant2 464: _Obj.Keys
  0003    | GetBoundLocalMove 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============_Obj.Keys================
  _Obj.Keys(O, Acc) = O -> {K: _, ...Rest} ? _Obj.Keys(Rest, [...Acc, K]) : Acc
  ========================================
  0000    | PushCharVar K
  0002    | PushUnderscoreVar
  0003    | GetConstant 61: Rest
  0005    | SetInputMark
  0006    | GetBoundLocalMove 0
  0008    | Destructure 124: ({K: _} + Rest)
  0010    | ConditionalThen 10 -> 41
  0013    | GetConstant2 464: _Obj.Keys
  0016    | GetBoundLocalMove 4
  0018    | PushEmptyArray
  0019    | JumpIfFailure 19 -> 25
  0022    | GetBoundLocalMove 1
  0024    | Merge
  0025    | JumpIfFailure 25 -> 36
  0028    | GetConstantMutable2 465: [_]
  0031    | GetBoundLocalMove 2
  0033    | InsertAtIndex 0
  0035    | Merge
  0036    | CallTailFunction 2
  0038    | Jump 38 -> 43
  0041    | GetBoundLocalMove 1
  0043    | End
  ========================================
  
  ===============Obj.Values===============
  Obj.Values(O) = _Obj.Values(O, [])
  ========================================
  0000    | GetConstant2 466: _Obj.Values
  0003    | GetBoundLocalMove 0
  0005    | PushEmptyArray
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==============_Obj.Values===============
  _Obj.Values(O, Acc) = O -> {_: V, ...Rest} ? _Obj.Values(Rest, [...Acc, V]) : Acc
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushCharVar V
  0003    | GetConstant 61: Rest
  0005    | SetInputMark
  0006    | GetBoundLocalMove 0
  0008    | Destructure 125: ({_: V} + Rest)
  0010    | ConditionalThen 10 -> 41
  0013    | GetConstant2 466: _Obj.Values
  0016    | GetBoundLocalMove 4
  0018    | PushEmptyArray
  0019    | JumpIfFailure 19 -> 25
  0022    | GetBoundLocalMove 1
  0024    | Merge
  0025    | JumpIfFailure 25 -> 36
  0028    | GetConstantMutable2 467: [_]
  0031    | GetBoundLocalMove 3
  0033    | InsertAtIndex 0
  0035    | Merge
  0036    | CallTailFunction 2
  0038    | Jump 38 -> 43
  0041    | GetBoundLocalMove 1
  0043    | End
  ========================================
  
  ===============Is.String================
  Is.String(V) = V -> ("" + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 126: ("" + _)
  0005    | End
  ========================================
  
  ===============Is.Number================
  Is.Number(V) = V -> (0 + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 127: (0 + _)
  0005    | End
  ========================================
  
  ================Is.Bool=================
  Is.Bool(V) = V -> (false + _)
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 128: (false + _)
  0005    | End
  ========================================
  
  ================Is.Null=================
  Is.Null(V) = V -> null
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 129: null
  0004    | End
  ========================================
  
  ================Is.Array================
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetBoundLocalMove 0
  0003    | Destructure 130: ([] + _)
  0005    | End
  ========================================
  
  ================Is.Equal================
  Is.Equal(A, B) = A -> B
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 131: B
  0004    | End
  ========================================
  
  ===========Is.LessThanOrEqual===========
  Is.LessThanOrEqual(A, B) = A -> ..B
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 132: ..B
  0004    | End
  ========================================
  
  =============Is.GreaterThan=============
  Is.GreaterThan(A, B) = A -> B ? @Fail : A -> B..
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 133: B
  0005    | ConditionalThen 5 -> 14
  0008    | CallTailFunctionConstant2 274: @Fail
  0011    | Jump 11 -> 18
  0014    | GetBoundLocalMove 0
  0016    | Destructure 134: B..
  0018    | End
  ========================================
  
  =========Is.GreaterThanOrEqual==========
  Is.GreaterThanOrEqual(A, B) = A -> B..
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | Destructure 135: B..
  0004    | End
  ========================================
  
  ===============As.Number================
  As.Number(V) = Is.Number(V) | (V -> "%(0 + N)" $ N)
  ========================================
  0000    | PushCharVar N
  0002    | SetInputMark
  0003    | GetConstant2 468: Is.Number
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | Or 10 -> 22
  0013    | GetBoundLocalMove 0
  0015    | Destructure 136: "%(0 + N)"
  0017    | TakeRight 17 -> 22
  0020    | GetBoundLocalMove 1
  0022    | End
  ========================================
  
  ===============As.String================
  As.String(V) = "%(V)"
  ========================================
  0000    | PushEmptyString
  0001    | GetBoundLocalMove 0
  0003    | MergeAsString
  0004    | End
  ========================================

