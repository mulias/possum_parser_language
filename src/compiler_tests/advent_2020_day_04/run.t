  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  =================@fn39==================
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
  0009    | GetConstant 3: @fn39
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
  0010    | JumpIfFailure 10 -> 77
  0013    | PushNull
  0014    | PushNumberZero
  0015    | ValidateRepeatPattern
  0016    | JumpIfZero 16 -> 47
  0019    | Swap
  0020    | CallFunctionLocal 3
  0022    | TakeRight 22 -> 35
  0025    | GetConstant 0: pair_sep
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
  0054    | GetConstant 0: pair_sep
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
  
  =================@fn46==================
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
  0002    | GetConstant 4: @fn46
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
  
  =================@fn50==================
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
  0002    | GetConstant 9: @fn50
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
  0003    | TakeRight 3 -> 7
  0006    | PushNumberOne
  0007    | Or 7 -> 16
  0010    | CallFunctionConstant 6: passport
  0012    | TakeRight 12 -> 16
  0015    | PushNumberZero
  0016    | End
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
  
  =================@fn55==================
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
  0004    | GetConstant 10: @fn55
  0006    | CallTailFunction 2
  0008    | End
  ========================================

