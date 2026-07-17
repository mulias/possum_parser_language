  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/repeat.possum -i '' --no-stdlib
  
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
  0001    | GetConstant 2: many_sep
  0003    | GetLocalMove 0
  0005    | GetLocalMove 1
  0007    | CallFunction 2
  0009    | Or 9 -> 14
  0012    | CallTailFunctionConstant 3: succeed
  0014    | End
  ========================================
  
  =================2:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | CallFunctionConstant 1: @input.offset
  0004    | DestructurePlan 0: bind Pos
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 2: @at
  0011    | GetLocalMove 1
  0013    | GetLocalMove 0
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  ================2:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 0: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal 0
  0013    | End
  ========================================
  
  ===============2:succeed================
  succeed = const($null)
  ========================================
  0000    | GetConstant 3: const
  0002    | PushNull
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ================2:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
  0002    | End
  ========================================
