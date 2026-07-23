  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '""' -i ''
  
  ================2:@main=================
  ""
  ========================================
  0000    | PushEmptyString
  0001    | End
  ========================================

  $ possum -p '"hello"' -i ''
  
  ================2:@main=================
  "hello"
  ========================================
  0000    | CallTailFunctionConstant 0: "hello"
  0002    | End
  ========================================

  $ possum -p "'world'" -i ''
  
  ================2:@main=================
  'world'
  ========================================
  0000    | CallTailFunctionConstant 0: "world"
  0002    | End
  ========================================

  $ possum -p '"%(word)"' -i ''
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ===============3:numeral================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ================3:alnum=================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
  ========================================
  
  =================3:word=================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn1
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================3:@fn1=================
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
  
  =================4:many=================
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
  
  ================2:@main=================
  "%(word)"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionConstant 0: word
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p '"Hello %(word)"' -i ''
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ===============3:numeral================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ================3:alnum=================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
  ========================================
  
  =================3:word=================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn1
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================3:@fn1=================
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
  
  =================4:many=================
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
  
  ================2:@main=================
  "Hello %(word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | JumpIfFailure 2 -> 10
  0005    | PushEmptyString
  0006    | CallFunctionConstant 1: word
  0008    | MergeAsString
  0009    | Merge
  0010    | End
  ========================================

  $ possum -p '"%(word) World"' -i ''
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ===============3:numeral================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ================3:alnum=================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
  ========================================
  
  =================3:word=================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn1
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================3:@fn1=================
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
  
  =================4:many=================
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
  
  ================2:@main=================
  "%(word) World"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionConstant 0: word
  0003    | MergeAsString
  0004    | JumpIfFailure 4 -> 10
  0007    | CallFunctionConstant 1: " World"
  0009    | Merge
  0010    | End
  ========================================

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ===============3:numeral================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ================3:alnum=================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 4: numeral
  0008    | End
  ========================================
  
  =================3:word=================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn1
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================3:@fn1=================
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
  
  =================4:many=================
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
  
  ================2:@main=================
  "Hello %(word) and %(word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | JumpIfFailure 2 -> 10
  0005    | PushEmptyString
  0006    | CallFunctionConstant 1: word
  0008    | MergeAsString
  0009    | Merge
  0010    | JumpIfFailure 10 -> 16
  0013    | CallFunctionConstant 2: " and "
  0015    | Merge
  0016    | JumpIfFailure 16 -> 24
  0019    | PushEmptyString
  0020    | CallFunctionConstant 1: word
  0022    | MergeAsString
  0023    | Merge
  0024    | End
  ========================================

  $ possum -p '"" $ "%(5)"' -i ''
  
  ================2:@main=================
  "" $ "%(5)"
  ========================================
  0000    | PushEmptyString
  0001    | PushInteger 5
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p '"" -> "%(Str)"' -i ''
  
  ================2:@main=================
  "" -> "%(Str)"
  ========================================
  0000    | PushVar Str
  0002    | PushEmptyString
  0003    | JumpIfFailure 3 -> 33
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 string -> 31
  0015    | MatchLenMin r0 0 -> 31
  0020    | MatchSlice r1 r0[0..^0]
  0025    | MatchBind l0 r1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | End
  ========================================

  $ possum -p '"Hello %(int + word)"' -i ''
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ===============3:numeral================
  numeral = "0".."9"
  ========================================
  0000    | ParseCodepointRange '0'..'9'
  0003    | End
  ========================================
  
  ===============3:numerals===============
  numerals = many(numeral)
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================3:alnum=================
  alnum = alpha | numeral
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 4: alpha
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 1: numeral
  0008    | End
  ========================================
  
  =================3:word=================
  word = many(alnum | "_" | "-")
  ========================================
  0000    | GetConstant 0: many
  0002    | GetConstant 2: @fn1
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================3:@fn1=================
  alnum | "_" | "-"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 3: alnum
  0003    | Or 3 -> 14
  0006    | SetInputMark
  0007    | ParseChar '_'
  0009    | Or 9 -> 14
  0012    | ParseChar '-'
  0014    | End
  ========================================
  
  =================4:many=================
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
  
  ================4:maybe=================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 0: succeed
  0008    | End
  ========================================
  
  ===============4:succeed================
  succeed = const($null)
  ========================================
  0000    | GetConstant 1: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ==============4:as_number===============
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 29
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 27
  0016    | MatchCastNum r4 <- r0 -> 27
  0021    | MatchBind l1 r4
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l1
  0034    | End
  ========================================
  
  ===============6:integer================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===============6:integer================
  integer = as_number(maybe("-") + _number_integer_part)
  ========================================
  0000    | GetConstant 0: as_number
  0002    | GetConstant 1: @fn0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =========6:_number_integer_part=========
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
  
  =================6:@fn0=================
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
  
  ================2:@main=================
  "Hello %(int + word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | JumpIfFailure 2 -> 16
  0005    | PushEmptyString
  0006    | CallFunctionConstant 1: integer
  0008    | JumpIfFailure 8 -> 14
  0011    | CallFunctionConstant 2: word
  0013    | Merge
  0014    | MergeAsString
  0015    | Merge
  0016    | End
  ========================================

