  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  ==========count_valid_passport==========
  count_valid_passport = (valid_passport $ 1) | (passport $ 0)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 0: valid_passport
  0003    | TakeRight 3 -> 7
  0006    | PushNumberOne
  0007    | Or 7 -> 16
  0010    | CallFunctionConstant 1: passport
  0012    | TakeRight 12 -> 16
  0015    | PushNumberZero
  0016    | End
  ========================================
  
  =============valid_passport=============
  valid_passport =
    passport -> {
      "byr": _, "iyr": _, "eyr": _, "hgt": _,
      "hcl": _, "ecl": _, "pid": _, ..._,
    }
  ========================================
  0000    | PushUnderscoreVar
  0001    | CallFunctionConstant 1: passport
  0003    | Destructure 0: ({"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _} + _)
  0005    | End
  ========================================
  
  =================@fn41==================
  space | nl
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 6: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 7: newline
  0008    | End
  ========================================
  
  ================passport================
  passport = object_sep(alphas, ":", token, space | nl)
  ========================================
  0000    | GetConstant 2: object_sep
  0002    | GetConstant 3: alphas
  0004    | PushChar ':'
  0006    | GetConstant 4: token
  0008    | GetConstant 5: @fn41
  0010    | CallTailFunction 4
  0012    | End
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
  0010    | PushNull
  0011    | PushNumberZero
  0012    | ValidateRepeatPattern
  0013    | JumpIfZero 13 -> 44
  0016    | Swap
  0017    | CallFunctionLocal 3
  0019    | TakeRight 19 -> 32
  0022    | GetConstant 0: pair_sep
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | GetBoundLocal 2
  0030    | CallFunction 3
  0032    | Merge
  0033    | JumpIfFailure 33 -> 71
  0036    | Swap
  0037    | Decrement
  0038    | JumpIfZero 38 -> 44
  0041    | JumpBack 41 -> 16
  0044    | Swap
  0045    | SetInputMark
  0046    | CallFunctionLocal 3
  0048    | TakeRight 48 -> 61
  0051    | GetConstant 0: pair_sep
  0053    | GetBoundLocal 0
  0055    | GetBoundLocal 1
  0057    | GetBoundLocal 2
  0059    | CallFunction 3
  0061    | JumpIfFailure 61 -> 69
  0064    | PopInputMark
  0065    | Merge
  0066    | JumpBack 66 -> 45
  0069    | ResetInput
  0070    | Drop
  0071    | Swap
  0072    | Drop
  0073    | Merge
  0074    | End
  ========================================
  
  ================pair_sep================
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushCharVar K
  0002    | PushCharVar V
  0004    | CallFunctionLocal 0
  0006    | Destructure 0: K
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 1
  0013    | TakeRight 13 -> 31
  0016    | CallFunctionLocal 2
  0018    | Destructure 1: V
  0020    | TakeRight 20 -> 31
  0023    | GetConstant 1: {_0_}
  0025    | GetBoundLocal 3
  0027    | GetBoundLocal 4
  0029    | InsertKeyVal 0
  0031    | End
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
  
  =================alpha==================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  =================@fn48==================
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
  0002    | GetConstant 4: @fn48
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
  
  =================@fn52==================
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
  0002    | GetConstant 9: @fn52
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
  0013    | CallFunctionConstant 12: "\xc2\xa0" (esc)
  0015    | Or 15 -> 41
  0018    | SetInputMark
  0019    | GetConstant 13: "\xe2\x80\x80" (esc)
  0021    | GetConstant 14: "\xe2\x80\x8a" (esc)
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
  
  ================newline=================
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
  
  =================@fn55==================
  nl+nl
  ========================================
  0000    | CallFunctionConstant 7: newline
  0002    | CallFunctionConstant 7: newline
  0004    | Merge
  0005    | End
  ========================================
  
  =================@main==================
  many_sep(count_valid_passport, nl+nl)
  ========================================
  0000    | GetConstant 8: many_sep
  0002    | GetConstant 9: count_valid_passport
  0004    | GetConstant 10: @fn55
  0006    | CallTailFunction 2
  0008    | End
  ========================================

