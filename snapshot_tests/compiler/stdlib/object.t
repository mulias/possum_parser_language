  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object.possum -i '' --no-stdlib
  
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
  
  ================1:object================
  object(key, value) = pair(key, value) * 1..
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 28
  0007    | Swap
  0008    | GetConstant 0: pair
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
  0030    | GetConstant 0: pair
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
  0050    | End
  ========================================
  
  ==============1:object_sep==============
  object_sep(key, kv_sep, value, sep) =
    pair_sep(key, kv_sep, value) +
    ((sep > pair_sep(key, kv_sep, value)) * 0..)
  ========================================
  0000    | GetConstant 2: pair_sep
  0002    | GetLocal 0
  0004    | GetLocal 1
  0006    | GetLocal 2
  0008    | CallFunction 3
  0010    | JumpIfFailure 10 -> 78
  0013    | PushNull
  0014    | PushInteger 0
  0016    | ValidateRepeatPattern
  0017    | JumpIfZero 17 -> 48
  0020    | Swap
  0021    | CallFunctionLocal 3
  0023    | TakeRight 23 -> 36
  0026    | GetConstant 2: pair_sep
  0028    | GetLocal 0
  0030    | GetLocal 1
  0032    | GetLocal 2
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
  0055    | GetConstant 2: pair_sep
  0057    | GetLocal 0
  0059    | GetLocal 1
  0061    | GetLocal 2
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
  
  =============1:object_until=============
  object_until(key, value, stop) =
    unless(pair(key, value), stop) * 1.. < peek(stop)
  ========================================
  0000    | PushNull
  0001    | PushInteger 1
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 34
  0007    | Swap
  0008    | GetConstant 4: unless
  0010    | GetConstant 5: @fn0
  0012    | CreateClosure 2
  0014    | CaptureLocal 0
  0016    | CaptureLocal 1
  0018    | GetLocal 2
  0020    | CallFunction 2
  0022    | Merge
  0023    | JumpIfFailure 23 -> 60
  0026    | Swap
  0027    | Decrement
  0028    | JumpIfZero 28 -> 34
  0031    | JumpBack 31 -> 7
  0034    | Swap
  0035    | SetInputMark
  0036    | GetConstant 4: unless
  0038    | GetConstant 5: @fn0
  0040    | CreateClosure 2
  0042    | CaptureLocal 0
  0044    | CaptureLocal 1
  0046    | GetLocal 2
  0048    | CallFunction 2
  0050    | JumpIfFailure 50 -> 58
  0053    | PopInputMark
  0054    | Merge
  0055    | JumpBack 55 -> 35
  0058    | ResetInput
  0059    | Drop
  0060    | Swap
  0061    | Drop
  0062    | JumpIfFailure 62 -> 72
  0065    | GetConstant 6: peek
  0067    | GetLocalMove 2
  0069    | CallFunction 1
  0071    | TakeLeft
  0072    | End
  ========================================
  
  =============1:maybe_object=============
  maybe_object(key, value) = default(object(key, value), {})
  ========================================
  0000    | GetConstant 7: default
  0002    | GetConstant 8: @fn1
  0004    | CreateClosure 2
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | PushEmptyObject
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ===========1:maybe_object_sep===========
  maybe_object_sep(key, pair_sep, value, sep) =
    default(object_sep(key, pair_sep, value, sep), {})
  ========================================
  0000    | GetConstant 7: default
  0002    | GetConstant 10: @fn2
  0004    | CreateClosure 4
  0006    | CaptureLocal 0
  0008    | CaptureLocal 1
  0010    | CaptureLocal 2
  0012    | CaptureLocal 3
  0014    | PushEmptyObject
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  =================1:pair=================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar K
  0002    | PushVar V
  0004    | CallFunctionLocal 0
  0006    | DestructurePlan 0: bind K
  0008    | TakeRight 8 -> 26
  0011    | CallFunctionLocal 1
  0013    | DestructurePlan 1: bind V
  0015    | TakeRight 15 -> 26
  0018    | GetConstantMutable 1: {_0_}
  0020    | GetLocalMove 2
  0022    | GetLocalMove 3
  0024    | InsertKeyVal 0
  0026    | End
  ========================================
  
  ===============1:pair_sep===============
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushVar K
  0002    | PushVar V
  0004    | CallFunctionLocal 0
  0006    | DestructurePlan 2: bind K
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 1
  0013    | TakeRight 13 -> 31
  0016    | CallFunctionLocal 2
  0018    | DestructurePlan 3: bind V
  0020    | TakeRight 20 -> 31
  0023    | GetConstantMutable 3: {_0_}
  0025    | GetLocalMove 3
  0027    | GetLocalMove 4
  0029    | InsertKeyVal 0
  0031    | End
  ========================================
  
  ===============1:record1================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | PushVar Value
  0002    | CallFunctionLocal 1
  0004    | DestructurePlan 4: bind Value
  0006    | TakeRight 6 -> 17
  0009    | GetConstantMutable 12: {_0_}
  0011    | GetLocalMove 0
  0013    | GetLocalMove 2
  0015    | InsertKeyVal 0
  0017    | End
  ========================================
  
  ===============1:record2================
  record2(Key1, value1, Key2, value2) =
    value1 -> V1 &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | CallFunctionLocal 1
  0006    | DestructurePlan 5: bind V1
  0008    | TakeRight 8 -> 32
  0011    | CallFunctionLocal 3
  0013    | DestructurePlan 6: bind V2
  0015    | TakeRight 15 -> 32
  0018    | GetConstantMutable 13: {_0_, _1_}
  0020    | GetLocalMove 0
  0022    | GetLocalMove 4
  0024    | InsertKeyVal 0
  0026    | GetLocalMove 2
  0028    | GetLocalMove 5
  0030    | InsertKeyVal 1
  0032    | End
  ========================================
  
  =============1:record2_sep==============
  record2_sep(Key1, value1, sep, Key2, value2) =
    value1 -> V1 & sep &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | CallFunctionLocal 1
  0006    | DestructurePlan 7: bind V1
  0008    | TakeRight 8 -> 13
  0011    | CallFunctionLocal 2
  0013    | TakeRight 13 -> 37
  0016    | CallFunctionLocal 4
  0018    | DestructurePlan 8: bind V2
  0020    | TakeRight 20 -> 37
  0023    | GetConstantMutable 14: {_0_, _1_}
  0025    | GetLocalMove 0
  0027    | GetLocalMove 5
  0029    | InsertKeyVal 0
  0031    | GetLocalMove 3
  0033    | GetLocalMove 6
  0035    | InsertKeyVal 1
  0037    | End
  ========================================
  
  ===============1:record3================
  record3(Key1, value1, Key2, value2, Key3, value3) =
    value1 -> V1 &
    value2 -> V2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | PushVar V3
  0006    | CallFunctionLocal 1
  0008    | DestructurePlan 9: bind V1
  0010    | TakeRight 10 -> 17
  0013    | CallFunctionLocal 3
  0015    | DestructurePlan 10: bind V2
  0017    | TakeRight 17 -> 47
  0020    | CallFunctionLocal 5
  0022    | DestructurePlan 11: bind V3
  0024    | TakeRight 24 -> 47
  0027    | GetConstantMutable 15: {_0_, _1_, _2_}
  0029    | GetLocalMove 0
  0031    | GetLocalMove 6
  0033    | InsertKeyVal 0
  0035    | GetLocalMove 2
  0037    | GetLocalMove 7
  0039    | InsertKeyVal 1
  0041    | GetLocalMove 4
  0043    | GetLocalMove 8
  0045    | InsertKeyVal 2
  0047    | End
  ========================================
  
  =============1:record3_sep==============
  record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3) =
    value1 -> V1 & sep1 &
    value2 -> V2 & sep2 &
    value3 -> V3 $
    {Key1: V1, Key2: V2, Key3: V3}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | PushVar V3
  0006    | CallFunctionLocal 1
  0008    | DestructurePlan 12: bind V1
  0010    | TakeRight 10 -> 15
  0013    | CallFunctionLocal 2
  0015    | TakeRight 15 -> 22
  0018    | CallFunctionLocal 4
  0020    | DestructurePlan 13: bind V2
  0022    | TakeRight 22 -> 27
  0025    | CallFunctionLocal 5
  0027    | TakeRight 27 -> 57
  0030    | CallFunctionLocal 7
  0032    | DestructurePlan 14: bind V3
  0034    | TakeRight 34 -> 57
  0037    | GetConstantMutable 16: {_0_, _1_, _2_}
  0039    | GetLocalMove 0
  0041    | GetLocalMove 8
  0043    | InsertKeyVal 0
  0045    | GetLocalMove 3
  0047    | GetLocalMove 9
  0049    | InsertKeyVal 1
  0051    | GetLocalMove 6
  0053    | GetLocalMove 10
  0055    | InsertKeyVal 2
  0057    | End
  ========================================
  
  =================1:@fn0=================
  pair(key, value)
  ========================================
  0000    | PushVar key
  0002    | PushVar value
  0004    | SetClosureCaptures
  0005    | GetConstant 0: pair
  0007    | GetLocalMove 0
  0009    | GetLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================1:@fn1=================
  object(key, value)
  ========================================
  0000    | PushVar key
  0002    | PushVar value
  0004    | SetClosureCaptures
  0005    | GetConstant 9: object
  0007    | GetLocalMove 0
  0009    | GetLocalMove 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================1:@fn2=================
  object_sep(key, pair_sep, value, sep)
  ========================================
  0000    | PushVar key
  0002    | PushVar pair_sep
  0004    | PushVar value
  0006    | PushVar sep
  0008    | SetClosureCaptures
  0009    | GetConstant 11: object_sep
  0011    | GetLocalMove 0
  0013    | GetLocalMove 1
  0015    | GetLocalMove 2
  0017    | GetLocalMove 3
  0019    | CallTailFunction 4
  0021    | End
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
  
  ===============2:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal 0
  0003    | Or 3 -> 12
  0006    | GetConstant 3: const
  0008    | GetLocalMove 1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================2:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
  0002    | End
  ========================================
