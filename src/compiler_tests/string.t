  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '""' -i ''
  
  =================@main==================
  ""
  ========================================
  0000    | PushEmptyString
  0001    | End
  ========================================

  $ possum -p '"hello"' -i ''
  
  =================@main==================
  "hello"
  ========================================
  0000    | CallTailFunctionConstant 0: "hello"
  0002    | End
  ========================================

  $ possum -p "'world'" -i ''
  
  =================@main==================
  'world'
  ========================================
  0000    | CallTailFunctionConstant 0: "world"
  0002    | End
  ========================================

  $ possum -p '"%(word)"' -i ''
  
  =================@fn37==================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 2: alnum
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
  0002    | GetConstant 1: @fn37
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
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
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
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  =================@main==================
  "%(word)"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionConstant 0: word
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p '"Hello %(word)"' -i ''
  
  =================@fn37==================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 2: alnum
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
  0002    | GetConstant 1: @fn37
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
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
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
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  =================@main==================
  "Hello %(word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | CallFunctionConstant 1: word
  0004    | MergeAsString
  0005    | End
  ========================================

  $ possum -p '"%(word) World"' -i ''
  
  =================@fn37==================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 2: alnum
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
  0002    | GetConstant 1: @fn37
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
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
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
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  =================@main==================
  "%(word) World"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionConstant 0: word
  0003    | MergeAsString
  0004    | CallFunctionConstant 1: " World"
  0006    | MergeAsString
  0007    | End
  ========================================

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  
  =================@fn37==================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 2: alnum
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
  0002    | GetConstant 1: @fn37
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
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
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
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  =================@main==================
  "Hello %(word) and %(word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | CallFunctionConstant 1: word
  0004    | MergeAsString
  0005    | CallFunctionConstant 2: " and "
  0007    | MergeAsString
  0008    | CallFunctionConstant 1: word
  0010    | MergeAsString
  0011    | End
  ========================================

  $ possum -p '"" $ "%(5)"' -i ''
  
  =================@main==================
  "" $ "%(5)"
  ========================================
  0000    | PushEmptyString
  0001    | PushNumber 5
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p '"" -> "%(Str)"' -i ''
  
  =================@main==================
  "" -> "%(Str)"
  ========================================
  0000    | PushVar2 Str
  0003    | PushEmptyString
  0004    | Destructure 0: "%(Str)"
  0006    | End
  ========================================

  $ possum -p '"Hello %(int + word)"' -i ''
  
  =================@fn37==================
  maybe("-") + _number_integer_part
  ========================================
  0000    | GetConstant 2: maybe
  0002    | PushString2 "-"
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 13
  0010    | CallFunctionConstant 3: _number_integer_part
  0012    | Merge
  0013    | End
  ========================================
  
  ================integer=================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn37
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============as_number================
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionLocal 0
  0005    | Destructure 0: "%(0 + N)"
  0007    | TakeRight 7 -> 12
  0010    | GetBoundLocalMove 1
  0012    | End
  ========================================
  
  =================maybe==================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: succeed
  0008    | End
  ========================================
  
  ================succeed=================
  succeed = const($null)
  ========================================
  0000    | GetConstant 5: const
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
  
  ==========_number_integer_part==========
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
  
  ================numerals================
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 8: many
  0002    | GetConstant 7: numeral
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
  
  ================numeral=================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  =================@fn46==================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 10: alnum
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
  0000    | GetConstant 8: many
  0002    | GetConstant 9: @fn46
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================alnum==================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 11: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 7: numeral
  0008    | End
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
  
  =================@main==================
  "Hello %(int + word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | CallFunctionConstant 1: integer
  0004    | JumpIfFailure 4 -> 10
  0007    | CallFunctionConstant 2: word
  0009    | Merge
  0010    | MergeAsString
  0011    | End
  ========================================

