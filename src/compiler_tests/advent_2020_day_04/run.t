  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  ==================@fn4==================
  space | nl
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 4: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 5: newline
  0008    | End
  ========================================
  
  ================passport================
  passport = object_sep(alphas, ":", token, space | nl)
  ========================================
  0000    | GetConstant 0: object_sep
  0002    | GetConstant 1: alphas
  0004    | PushString2 ":"
  0007    | GetConstant 2: token
  0009    | GetConstant 3: @fn4
  0011    | CallTailFunction 4
  0013    | End
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
  0010    | JumpIfFailure 10 -> 78
  0013    | PushNull
  0014    | PushInteger 0
  0016    | ValidateRepeatPattern
  0017    | JumpIfZero 17 -> 48
  0020    | Swap
  0021    | CallFunctionLocal 3
  0023    | TakeRight 23 -> 36
  0026    | GetConstant 0: pair_sep
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
  0055    | GetConstant 0: pair_sep
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
  
  ================pair_sep================
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushVar2 K
  0003    | PushVar2 V
  0006    | CallFunctionLocal 0
  0008    | Destructure 0: K
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 1
  0015    | TakeRight 15 -> 33
  0018    | CallFunctionLocal 2
  0020    | Destructure 1: V
  0022    | TakeRight 22 -> 33
  0025    | GetConstantMutable 1: {_0_}
  0027    | GetBoundLocalMove 3
  0029    | GetBoundLocalMove 4
  0031    | InsertKeyVal 0
  0033    | End
  ========================================
  
  =================alphas=================
  alphas = many(alpha)
  ========================================
  0000    | GetConstant 2: many
  0002    | GetConstant 3: alpha
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================many==================
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
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================@fn11==================
  unless(char, whitespace)
  ========================================
  0000    | GetConstant 5: unless
  0002    | GetConstant 6: char
  0004    | GetConstant 7: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  token = many(unless(char, whitespace))
  ========================================
  0000    | GetConstant 2: many
  0002    | GetConstant 4: @fn11
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================unless=================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 8: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  ==================char==================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  =================@fn16==================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 10: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 11: newline
  0008    | End
  ========================================
  
  ===============whitespace===============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 2: many
  0002    | GetConstant 9: @fn16
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================space==================
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
  0013    | CallFunctionConstant 12: "\xc2\xa0" (esc)
  0015    | Or 15 -> 43
  0018    | SetInputMark
  0019    | PushString2 "\xe2\x80\x80" (esc)
  0022    | PushString2 "\xe2\x80\x8a" (esc)
  0025    | ParseRange
  0026    | Or 26 -> 43
  0029    | SetInputMark
  0030    | CallFunctionConstant 13: "\xe2\x80\xaf" (esc)
  0032    | Or 32 -> 43
  0035    | SetInputMark
  0036    | CallFunctionConstant 14: "\xe2\x81\x9f" (esc)
  0038    | Or 38 -> 43
  0041    | CallTailFunctionConstant 15: "\xe3\x80\x80" (esc)
  0043    | End
  ========================================
  
  ================newline=================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 16: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 17: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 18: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 19: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  =============valid_passport=============
  valid_passport =
    passport -> {
      "byr": _, "iyr": _, "eyr": _, "hgt": _,
      "hcl": _, "ecl": _, "pid": _, ..._,
    }
  ========================================
  0000    | PushUnderscoreVar
  0001    | CallFunctionConstant 6: passport
  0003    | Destructure 0: ({"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _} + _)
  0005    | End
  ========================================
  
  ==========count_valid_passport==========
  count_valid_passport = (valid_passport $ 1) | (passport $ 0)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 7: valid_passport
  0003    | TakeRight 3 -> 8
  0006    | PushInteger 1
  0008    | Or 8 -> 18
  0011    | CallFunctionConstant 6: passport
  0013    | TakeRight 13 -> 18
  0016    | PushInteger 0
  0018    | End
  ========================================
  
  ================many_sep================
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
  
  =================@fn21==================
  nl+nl
  ========================================
  0000    | CallFunctionConstant 5: newline
  0002    | JumpIfFailure 2 -> 8
  0005    | CallFunctionConstant 5: newline
  0007    | Merge
  0008    | End
  ========================================
  
  =================@main==================
  many_sep(count_valid_passport, nl+nl)
  ========================================
  0000    | GetConstant 8: many_sep
  0002    | GetConstant 9: count_valid_passport
  0004    | GetConstant 10: @fn21
  0006    | CallTailFunction 2
  0008    | End
  ========================================

