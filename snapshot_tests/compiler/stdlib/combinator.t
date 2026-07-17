  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/combinator.possum -i '' --no-stdlib
  
  ================0:@fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ============0:@input.offset=============
  0000    | NativeCode 2: inputOffsetNative
  0002    | End
  ========================================
  
  =================0:@at==================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | NativeCode 4: setInputPositionNative
  0005    | JumpIfFailure 5 -> 13
  0008    | GetLocal 1
  0010    | CallFunction 0
  0012    | ResetInput
  0013    | End
  ========================================
  
  =================1:many=================
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
  
  ===============1:many_sep===============
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
  
  ==============1:many_until==============
  many_until(p, stop) = unless(p, stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: unless
  0010    | GetLocal 0
  0012    | GetLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: unless
  0032    | GetLocal 0
  0034    | GetLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | JumpIfFailure 50 -> 60
  0053    | GetConstant 1: peek
  0055    | GetLocalMove 1
  0057    | CallFunction 1
  0059    | TakeLeft
  0060    | End
  ========================================
  
  ==============1:maybe_many==============
  maybe_many(p) = p * 0..
  ========================================
  0000    | PushNull
  0001    | PushInteger 0
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
  
  ============1:maybe_many_sep============
  maybe_many_sep(p, sep) = many_sep(p, sep) | succeed
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 5: many_sep
  0003    | GetLocalMove 0
  0005    | GetLocalMove 1
  0007    | CallFunction 2
  0009    | Or 9 -> 14
  0012    | CallTailFunctionConstant 6: succeed
  0014    | End
  ========================================
  
  =================1:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | CallFunctionConstant 3: @input.offset
  0004    | DestructurePlan 0: bind Pos
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 4: @at
  0011    | GetLocalMove 1
  0013    | GetLocalMove 0
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ================1:maybe=================
  maybe(p) = p | succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 6: succeed
  0008    | End
  ========================================
  
  ================1:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 2: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  =================1:skip=================
  skip(p) = null(p)
  ========================================
  0000    | GetConstant 8: null
  0002    | GetLocalMove 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:find=================
  find(p) = p | (char > find(p))
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 17
  0006    | CallFunctionConstant 9: char
  0008    | TakeRight 8 -> 17
  0011    | GetConstant 10: find
  0013    | GetLocalMove 0
  0015    | CallTailFunction 1
  0017    | End
  ========================================
  
  ===============1:find_all===============
  find_all(p) = !stdlib.array(find(p)) < maybe(many(char))
  ========================================
  0000    | GetConstant 11: array
  0002    | GetConstant 12: @fn0
  0004    | CreateClosure 1
  0006    | CaptureLocal 0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 20
  0013    | GetConstant 13: maybe
  0015    | GetConstant 14: @fn1
  0017    | CallFunction 1
  0019    | TakeLeft
  0020    | End
  ========================================
  
  =============1:find_before==============
  find_before(p, stop) = stop ? @fail : p | (char > find_before(p, stop))
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 2: @fail
  0008    | Jump 8 -> 30
  0011    | SetInputMark
  0012    | CallFunctionLocal 0
  0014    | Or 14 -> 30
  0017    | CallFunctionConstant 9: char
  0019    | TakeRight 19 -> 30
  0022    | GetConstant 16: find_before
  0024    | GetLocalMove 0
  0026    | GetLocalMove 1
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ===========1:find_all_before============
  find_all_before(p, stop) = !stdlib.array(find_before(p, stop)) < maybe(chars_until(stop))
  ========================================
  0000    | GetConstant 11: array
  0002    | GetConstant 17: @fn2
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 26
  0015    | GetConstant 13: maybe
  0017    | GetConstant 18: @fn3
  0019    | CreateClosure 1
  0021    | CaptureLocal 1
  0023    | CallFunction 1
  0025    | TakeLeft
  0026    | End
  ========================================
  
  ===============1:succeed================
  succeed = const($null)
  ========================================
  0000    | GetConstant 7: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ===============1:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 12
  0006    | GetConstant 7: const
  0008    | GetLocalMove 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================1:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
  0002    | End
  ========================================
  
  ==============1:as_number===============
  as_number(p) = p -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar2 N
  0003    | CallFunctionLocal 0
  0005    | DestructurePlan 1: tmpl((eq 0 + bind N))
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove 1
  0012    | End
  ========================================
  
  ==============1:as_string===============
  as_string(p) = "%(p)"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionLocal 0
  0003    | MergeAsString
  0004    | End
  ========================================
  
  ===============1:surround===============
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
  
  =============1:end_of_input=============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 9: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 2: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 6: succeed
  0013    | End
  ========================================
  
  =============1:end_of_input=============
  end_of_input = char ? @fail : succeed
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 9: char
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 2: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionConstant 6: succeed
  0013    | End
  ========================================
  
  ================1:input=================
  input(p) = surround(p, maybe(whitespace)) < end_of_input
  ========================================
  0000    | GetConstant 20: surround
  0002    | GetLocalMove 0
  0004    | GetConstant 21: @fn4
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 14
  0011    | CallFunctionConstant 22: end_of_input
  0013    | TakeLeft
  0014    | End
  ========================================
  
  =============1:one_or_both==============
  one_or_both(a, b) = (a + maybe(b)) | (maybe(a) + b)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | JumpIfFailure 3 -> 13
  0006    | GetConstant 13: maybe
  0008    | GetLocal 1
  0010    | CallFunction 1
  0012    | Merge
  0013    | Or 13 -> 28
  0016    | GetConstant 13: maybe
  0018    | GetLocalMove 0
  0020    | CallFunction 1
  0022    | JumpIfFailure 22 -> 28
  0025    | CallFunctionLocal 1
  0027    | Merge
  0028    | End
  ========================================
  
  =================1:@fn0=================
  find(p)
  ========================================
  0000    | PushVar p
  0002    | SetClosureCaptures
  0003    | GetConstant 10: find
  0005    | GetLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================1:@fn1=================
  many(char)
  ========================================
  0000    | GetConstant 15: many
  0002    | GetConstant 9: char
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================1:@fn2=================
  find_before(p, stop)
  ========================================
  0000    | PushVar p
  0002    | PushVar stop
  0004    | SetClosureCaptures
  0005    | GetConstant 16: find_before
  0007    | GetLocalMove 0
  0009    | GetLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================1:@fn3=================
  chars_until(stop)
  ========================================
  0000    | PushVar stop
  0002    | SetClosureCaptures
  0003    | GetConstant 19: chars_until
  0005    | GetLocalMove 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================1:@fn4=================
  maybe(whitespace)
  ========================================
  0000    | GetConstant 13: maybe
  0002    | GetConstant 23: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================2:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  ================2:space=================
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
  0013    | CallFunctionConstant 6: "\xc2\xa0" (esc)
  0015    | Or 15 -> 43
  0018    | SetInputMark
  0019    | PushString2 "\xe2\x80\x80" (esc)
  0022    | PushString2 "\xe2\x80\x8a" (esc)
  0025    | ParseRange
  0026    | Or 26 -> 43
  0029    | SetInputMark
  0030    | CallFunctionConstant 7: "\xe2\x80\xaf" (esc)
  0032    | Or 32 -> 43
  0035    | SetInputMark
  0036    | CallFunctionConstant 8: "\xe2\x81\x9f" (esc)
  0038    | Or 38 -> 43
  0041    | CallTailFunctionConstant 9: "\xe3\x80\x80" (esc)
  0043    | End
  ========================================
  
  ===============2:newline================
  newline = "\r\n" | "\u00000A".."\u00000D" | "\u000085" | "\u002028" | "\u002029"
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 10: "\r (esc)
  "
  0003    | Or 3 -> 27
  0006    | SetInputMark
  0007    | ParseCodepointRange '
  '..'\r (no-eol) (esc)
  '
  0010    | Or 10 -> 27
  0013    | SetInputMark
  0014    | CallFunctionConstant 11: "\xc2\x85" (esc)
  0016    | Or 16 -> 27
  0019    | SetInputMark
  0020    | CallFunctionConstant 12: "\xe2\x80\xa8" (esc)
  0022    | Or 22 -> 27
  0025    | CallTailFunctionConstant 13: "\xe2\x80\xa9" (esc)
  0027    | End
  ========================================
  
  ==============2:whitespace==============
  whitespace = many(space | newline)
  ========================================
  0000    | GetConstant 2: many
  0002    | GetConstant 3: @fn3
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============2:chars_until==============
  chars_until(stop) = many_until(char, stop)
  ========================================
  0000    | GetConstant 0: many_until
  0002    | GetConstant 1: char
  0004    | GetLocalMove 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================2:@fn3=================
  space | newline
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 4: space
  0003    | Or 3 -> 8
  0006    | CallTailFunctionConstant 5: newline
  0008    | End
  ========================================
  
  =================3:many=================
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
  
  ==============3:many_until==============
  many_until(p, stop) = unless(p, stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: unless
  0010    | GetLocal 0
  0012    | GetLocal 1
  0014    | CallFunction 2
  0016    | Merge
  0017    | JumpIfFailure 17 -> 48
  0020    | Swap
  0021    | Decrement
  0022    | JumpIfZero 22 -> 28
  0025    | JumpBack 25 -> 7
  0028    | Swap
  0029    | SetInputMark
  0030    | GetConstant 0: unless
  0032    | GetLocal 0
  0034    | GetLocal 1
  0036    | CallFunction 2
  0038    | JumpIfFailure 38 -> 46
  0041    | PopInputMark
  0042    | Merge
  0043    | JumpBack 43 -> 29
  0046    | ResetInput
  0047    | Drop
  0048    | Swap
  0049    | Drop
  0050    | JumpIfFailure 50 -> 60
  0053    | GetConstant 1: peek
  0055    | GetLocalMove 1
  0057    | CallFunction 1
  0059    | TakeLeft
  0060    | End
  ========================================
  
  =================3:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | CallFunctionConstant 3: @input.offset
  0004    | DestructurePlan 0: bind Pos
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 4: @at
  0011    | GetLocalMove 1
  0013    | GetLocalMove 0
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ================3:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 2: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  =================4:null=================
  null(n) = n $ null
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushNull
  0006    | End
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
  0010    | GetLocal 0
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
  0030    | GetLocal 0
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
  0000    | PushVar Elem
  0002    | CallFunctionLocal 0
  0004    | DestructurePlan 0: bind Elem
  0006    | TakeRight 6 -> 15
  0009    | GetConstantMutable 1: [_]
  0011    | GetLocalMove 1
  0013    | InsertAtIndex 0
  0015    | End
  ========================================
