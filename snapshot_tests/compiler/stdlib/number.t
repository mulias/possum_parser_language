  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number.possum -i '' --no-stdlib
  
  ==============0:@Multiply===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 1: multiplyNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 3: powerNative
  0006    | End
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============1:integer================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========1:non_negative_integer=========
  non_negative_integer = as_number(_number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 3: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========1:negative_integer===========
  negative_integer = as_number("-" + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 6: @fn1
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================1:float=================
  float = as_number(maybe("-") + _number_integer_part + _number_fraction_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 7: @fn2
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 9: @fn3
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 12: @fn4
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 13: @fn5
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 13: @fn5
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 14: @fn6
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
  0000    | GetConstant 0: as_number
  0002    | GetConstant 15: @fn7
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========1:_number_integer_part=========
  _number_integer_part = ("1".."9" + numerals) | numeral
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange '1'..'9'
  0004    | JumpIfFailure 4 -> 10
  0007    | CallFunctionConstant 4: numerals
  0009    | Merge
  0010    | Or 10 -> 15
  0013    | CallTailFunctionConstant 5: numeral
  0015    | End
  ========================================
  
  ========1:_number_fraction_part=========
  _number_fraction_part = "." + numerals
  ========================================
  0000    | ParseChar '.'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 4: numerals
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
  0011    | GetConstant 2: maybe
  0013    | GetConstant 11: @fn8
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 24
  0021    | CallFunctionConstant 4: numerals
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
  0001    | CallFunctionConstant 16: digit
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
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 17: array
  0007    | GetConstant 18: binary_digit
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 19
  0014    | MatchScrutinee r1
  0016    | MatchBind l0 r1
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 19: Num.FromBinaryDigits
  0024    | GetLocalMove l0
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  ============1:octal_integer=============
  octal_integer = array(octal_digit) -> Digits $ Num.FromOctalDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 17: array
  0007    | GetConstant 20: octal_digit
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 19
  0014    | MatchScrutinee r1
  0016    | MatchBind l0 r1
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 21: Num.FromOctalDigits
  0024    | GetLocalMove l0
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  =============1:hex_integer==============
  hex_integer = array(hex_digit) -> Digits $ Num.FromHexDigits(Digits)
  ========================================
  0000    | PushVar2 Digits
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 17: array
  0007    | GetConstant 22: hex_digit
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 19
  0014    | MatchScrutinee r1
  0016    | MatchBind l0 r1
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 23: Num.FromHexDigits
  0024    | GetLocalMove l0
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  =================1:@fn0=================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 3: _number_integer_part
  0011    | Merge
  0012    | End
  ========================================
  
  =================1:@fn1=================
  "-" + _number_integer_part
  ========================================
  0000    | ParseChar '-'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 3: _number_integer_part
  0007    | Merge
  0008    | End
  ========================================
  
  =================1:@fn2=================
  maybe("-") + _number_integer_part + _number_fraction_part
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 3: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 18
  0015    | CallFunctionConstant 8: _number_fraction_part
  0017    | Merge
  0018    | End
  ========================================
  
  =================1:@fn3=================
  maybe("-") +
    _number_integer_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 3: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 18
  0015    | CallFunctionConstant 10: _number_exponent_part
  0017    | Merge
  0018    | End
  ========================================
  
  =================1:@fn4=================
  maybe("-") +
    _number_integer_part +
    _number_fraction_part +
    _number_exponent_part
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 12
  0009    | CallFunctionConstant 3: _number_integer_part
  0011    | Merge
  0012    | JumpIfFailure 12 -> 18
  0015    | CallFunctionConstant 8: _number_fraction_part
  0017    | Merge
  0018    | JumpIfFailure 18 -> 24
  0021    | CallFunctionConstant 10: _number_exponent_part
  0023    | Merge
  0024    | End
  ========================================
  
  =================1:@fn5=================
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
  0017    | GetConstant 8: _number_fraction_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 32
  0025    | GetConstant 2: maybe
  0027    | GetConstant 10: _number_exponent_part
  0029    | CallFunction 1
  0031    | Merge
  0032    | End
  ========================================
  
  =================1:@fn6=================
  _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | CallFunctionConstant 3: _number_integer_part
  0002    | JumpIfFailure 2 -> 12
  0005    | GetConstant 2: maybe
  0007    | GetConstant 8: _number_fraction_part
  0009    | CallFunction 1
  0011    | Merge
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 2: maybe
  0017    | GetConstant 10: _number_exponent_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | End
  ========================================
  
  =================1:@fn7=================
  "-" +
    _number_integer_part +
    maybe(_number_fraction_part) +
    maybe(_number_exponent_part)
  ========================================
  0000    | ParseChar '-'
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 3: _number_integer_part
  0007    | Merge
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 2: maybe
  0013    | GetConstant 8: _number_fraction_part
  0015    | CallFunction 1
  0017    | Merge
  0018    | JumpIfFailure 18 -> 28
  0021    | GetConstant 2: maybe
  0023    | GetConstant 10: _number_exponent_part
  0025    | CallFunction 1
  0027    | Merge
  0028    | End
  ========================================
  
  =================1:@fn8=================
  "-" | "+"
  ========================================
  0000    | SetInputMark
  0001    | ParseChar '-'
  0003    | Or 3 -> 8
  0006    | ParseChar '+'
  0008    | End
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
  
  ================3:maybe=================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 0: succeed
  0008    | End
  ========================================
  
  ===============3:succeed================
  succeed = const($null)
  ========================================
  0000    | GetConstant 1: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
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
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionLocal l0
  0010    | JumpIfFailure 10 -> 32
  0013    | MatchScrutinee r2
  0015    | MatchType r2 string -> 31
  0020    | MatchCastNum r6 <- r2 -> 31
  0025    | MatchBind l1 r6
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | TakeRight 32 -> 37
  0035    | GetLocalMove l1
  0037    | End
  ========================================
  
  ================7:array=================
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
  
  ================7:tuple1================
  tuple1(elem) =  elem -> Elem $ [Elem]
  ========================================
  0000    | PushVar2 Elem
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | CallFunctionLocal l0
  0007    | JumpIfFailure 7 -> 15
  0010    | MatchScrutinee r2
  0012    | MatchBind l1 r2
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
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
  0004    | NativeCode 1: multiplyNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 3: powerNative
  0006    | End
  ========================================
  
  =========9:Num.FromBinaryDigits=========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: Array.Length
  0007    | GetLocal l0
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 19
  0014    | MatchScrutinee r2
  0016    | MatchBind l1 r2
  0019    | TakeRight 19 -> 38
  0022    | GetConstant 1: _Num.FromBinaryDigits
  0024    | GetLocalMove l0
  0026    | GetLocalMove l1
  0028    | JumpIfFailure 28 -> 34
  0031    | PushNegInteger -1
  0033    | Merge
  0034    | PushInteger 0
  0036    | CallTailFunction 3
  0038    | End
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
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | SetInputMark
  0011    | GetLocalMove l0
  0013    | JumpIfFailure 13 -> 47
  0016    | MatchScrutinee r5
  0018    | MatchType r5 array -> 46
  0023    | MatchLenMin r5 1 -> 46
  0028    | MatchElem r6 r5[0]
  0032    | MatchBind l3 r6
  0035    | MatchSlice r7 r5[1..^0]
  0040    | MatchBind l4 r7
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | ConditionalThen 47 -> 111
  0050    | GetLocal l3
  0052    | JumpIfFailure 52 -> 71
  0055    | MatchScrutinee r5
  0057    | MatchInRange r5 0..1 -> 70
  0067    | Jump 67 -> 71
  0070    | MatchFail
  0071    | TakeRight 71 -> 108
  0074    | GetConstant 1: _Num.FromBinaryDigits
  0076    | GetLocalMove l4
  0078    | GetLocal l1
  0080    | JumpIfFailure 80 -> 86
  0083    | PushNegInteger -1
  0085    | Merge
  0086    | GetLocalMove l2
  0088    | JumpIfFailure 88 -> 106
  0091    | GetConstant 4: @Multiply
  0093    | GetLocalMove l3
  0095    | GetConstant 5: @Power
  0097    | PushInteger 2
  0099    | GetLocalMove l1
  0101    | CallFunction 2
  0103    | CallFunction 2
  0105    | Merge
  0106    | CallTailFunction 3
  0108    | Jump 108 -> 113
  0111    | GetLocalMove l2
  0113    | End
  ========================================
  
  =========9:Num.FromOctalDigits==========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: Array.Length
  0007    | GetLocal l0
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 19
  0014    | MatchScrutinee r2
  0016    | MatchBind l1 r2
  0019    | TakeRight 19 -> 38
  0022    | GetConstant 6: _Num.FromOctalDigits
  0024    | GetLocalMove l0
  0026    | GetLocalMove l1
  0028    | JumpIfFailure 28 -> 34
  0031    | PushNegInteger -1
  0033    | Merge
  0034    | PushInteger 0
  0036    | CallTailFunction 3
  0038    | End
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
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | SetInputMark
  0011    | GetLocalMove l0
  0013    | JumpIfFailure 13 -> 47
  0016    | MatchScrutinee r5
  0018    | MatchType r5 array -> 46
  0023    | MatchLenMin r5 1 -> 46
  0028    | MatchElem r6 r5[0]
  0032    | MatchBind l3 r6
  0035    | MatchSlice r7 r5[1..^0]
  0040    | MatchBind l4 r7
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | ConditionalThen 47 -> 111
  0050    | GetLocal l3
  0052    | JumpIfFailure 52 -> 71
  0055    | MatchScrutinee r5
  0057    | MatchInRange r5 0..7 -> 70
  0067    | Jump 67 -> 71
  0070    | MatchFail
  0071    | TakeRight 71 -> 108
  0074    | GetConstant 6: _Num.FromOctalDigits
  0076    | GetLocalMove l4
  0078    | GetLocal l1
  0080    | JumpIfFailure 80 -> 86
  0083    | PushNegInteger -1
  0085    | Merge
  0086    | GetLocalMove l2
  0088    | JumpIfFailure 88 -> 106
  0091    | GetConstant 4: @Multiply
  0093    | GetLocalMove l3
  0095    | GetConstant 5: @Power
  0097    | PushInteger 8
  0099    | GetLocalMove l1
  0101    | CallFunction 2
  0103    | CallFunction 2
  0105    | Merge
  0106    | CallTailFunction 3
  0108    | Jump 108 -> 113
  0111    | GetLocalMove l2
  0113    | End
  ========================================
  
  ==========9:Num.FromHexDigits===========
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | PushVar2 Len
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: Array.Length
  0007    | GetLocal l0
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 19
  0014    | MatchScrutinee r2
  0016    | MatchBind l1 r2
  0019    | TakeRight 19 -> 38
  0022    | GetConstant 8: _Num.FromHexDigits
  0024    | GetLocalMove l0
  0026    | GetLocalMove l1
  0028    | JumpIfFailure 28 -> 34
  0031    | PushNegInteger -1
  0033    | Merge
  0034    | PushInteger 0
  0036    | CallTailFunction 3
  0038    | End
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
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | SetInputMark
  0011    | GetLocalMove l0
  0013    | JumpIfFailure 13 -> 47
  0016    | MatchScrutinee r5
  0018    | MatchType r5 array -> 46
  0023    | MatchLenMin r5 1 -> 46
  0028    | MatchElem r6 r5[0]
  0032    | MatchBind l3 r6
  0035    | MatchSlice r7 r5[1..^0]
  0040    | MatchBind l4 r7
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | ConditionalThen 47 -> 111
  0050    | GetLocal l3
  0052    | JumpIfFailure 52 -> 71
  0055    | MatchScrutinee r5
  0057    | MatchInRange r5 0..15 -> 70
  0067    | Jump 67 -> 71
  0070    | MatchFail
  0071    | TakeRight 71 -> 108
  0074    | GetConstant 8: _Num.FromHexDigits
  0076    | GetLocalMove l4
  0078    | GetLocal l1
  0080    | JumpIfFailure 80 -> 86
  0083    | PushNegInteger -1
  0085    | Merge
  0086    | GetLocalMove l2
  0088    | JumpIfFailure 88 -> 106
  0091    | GetConstant 4: @Multiply
  0093    | GetLocalMove l3
  0095    | GetConstant 5: @Power
  0097    | PushInteger 16
  0099    | GetLocalMove l1
  0101    | CallFunction 2
  0103    | CallFunction 2
  0105    | Merge
  0106    | CallTailFunction 3
  0108    | Jump 108 -> 113
  0111    | GetLocalMove l2
  0113    | End
  ========================================
