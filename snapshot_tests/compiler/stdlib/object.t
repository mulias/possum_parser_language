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
  0001    | GetLocal l0
  0003    | NativeCode 4: setInputPositionNative
  0005    | JumpIfFailure 5 -> 13
  0008    | GetLocal l1
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
  0010    | GetLocal l0
  0012    | GetLocal l1
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
  0032    | GetLocal l0
  0034    | GetLocal l1
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
  0002    | GetLocal l0
  0004    | GetLocal l1
  0006    | GetLocal l2
  0008    | CallFunction 3
  0010    | JumpIfFailure 10 -> 78
  0013    | PushNull
  0014    | PushInteger 0
  0016    | ValidateRepeatPattern
  0017    | JumpIfZero 17 -> 48
  0020    | Swap
  0021    | CallFunctionLocal l3
  0023    | TakeRight 23 -> 36
  0026    | GetConstant 2: pair_sep
  0028    | GetLocal l0
  0030    | GetLocal l1
  0032    | GetLocal l2
  0034    | CallFunction 3
  0036    | Merge
  0037    | JumpIfFailure 37 -> 75
  0040    | Swap
  0041    | Decrement
  0042    | JumpIfZero 42 -> 48
  0045    | JumpBack 45 -> 20
  0048    | Swap
  0049    | SetInputMark
  0050    | CallFunctionLocal l3
  0052    | TakeRight 52 -> 65
  0055    | GetConstant 2: pair_sep
  0057    | GetLocal l0
  0059    | GetLocal l1
  0061    | GetLocal l2
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
  0014    | CaptureLocal l0
  0016    | CaptureLocal l1
  0018    | GetLocal l2
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
  0042    | CaptureLocal l0
  0044    | CaptureLocal l1
  0046    | GetLocal l2
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
  0067    | GetLocalMove l2
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
  0006    | CaptureLocal l0
  0008    | CaptureLocal l1
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
  0006    | CaptureLocal l0
  0008    | CaptureLocal l1
  0010    | CaptureLocal l2
  0012    | CaptureLocal l3
  0014    | PushEmptyObject
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  =================1:pair=================
  pair(key, value) = key -> K & value -> V $ {K: V}
  ========================================
  0000    | PushVar K
  0002    | PushVar V
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | CallFunctionLocal l0
  0008    | JumpIfFailure 8 -> 16
  0011    | MatchScrutinee r4
  0013    | MatchBind l2 r4
  0016    | TakeRight 16 -> 40
  0019    | CallFunctionLocal l1
  0021    | JumpIfFailure 21 -> 29
  0024    | MatchScrutinee r4
  0026    | MatchBind l3 r4
  0029    | TakeRight 29 -> 40
  0032    | GetConstantMutable 1: {_0_}
  0034    | GetLocalMove l2
  0036    | GetLocalMove l3
  0038    | InsertKeyVal 0
  0040    | End
  ========================================
  
  ===============1:pair_sep===============
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushVar K
  0002    | PushVar V
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | CallFunctionLocal l0
  0008    | JumpIfFailure 8 -> 16
  0011    | MatchScrutinee r5
  0013    | MatchBind l3 r5
  0016    | TakeRight 16 -> 21
  0019    | CallFunctionLocal l1
  0021    | TakeRight 21 -> 45
  0024    | CallFunctionLocal l2
  0026    | JumpIfFailure 26 -> 34
  0029    | MatchScrutinee r5
  0031    | MatchBind l4 r5
  0034    | TakeRight 34 -> 45
  0037    | GetConstantMutable 3: {_0_}
  0039    | GetLocalMove l3
  0041    | GetLocalMove l4
  0043    | InsertKeyVal 0
  0045    | End
  ========================================
  
  ===============1:record1================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | PushVar Value
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l1
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r3
  0011    | MatchBind l2 r3
  0014    | TakeRight 14 -> 25
  0017    | GetConstantMutable 12: {_0_}
  0019    | GetLocalMove l0
  0021    | GetLocalMove l2
  0023    | InsertKeyVal 0
  0025    | End
  ========================================
  
  ===============1:record2================
  record2(Key1, value1, Key2, value2) =
    value1 -> V1 &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | CallFunctionLocal l1
  0008    | JumpIfFailure 8 -> 16
  0011    | MatchScrutinee r6
  0013    | MatchBind l4 r6
  0016    | TakeRight 16 -> 46
  0019    | CallFunctionLocal l3
  0021    | JumpIfFailure 21 -> 29
  0024    | MatchScrutinee r6
  0026    | MatchBind l5 r6
  0029    | TakeRight 29 -> 46
  0032    | GetConstantMutable 13: {_0_, _1_}
  0034    | GetLocalMove l0
  0036    | GetLocalMove l4
  0038    | InsertKeyVal 0
  0040    | GetLocalMove l2
  0042    | GetLocalMove l5
  0044    | InsertKeyVal 1
  0046    | End
  ========================================
  
  =============1:record2_sep==============
  record2_sep(Key1, value1, sep, Key2, value2) =
    value1 -> V1 & sep &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | CallFunctionLocal l1
  0008    | JumpIfFailure 8 -> 16
  0011    | MatchScrutinee r7
  0013    | MatchBind l5 r7
  0016    | TakeRight 16 -> 21
  0019    | CallFunctionLocal l2
  0021    | TakeRight 21 -> 51
  0024    | CallFunctionLocal l4
  0026    | JumpIfFailure 26 -> 34
  0029    | MatchScrutinee r7
  0031    | MatchBind l6 r7
  0034    | TakeRight 34 -> 51
  0037    | GetConstantMutable 14: {_0_, _1_}
  0039    | GetLocalMove l0
  0041    | GetLocalMove l5
  0043    | InsertKeyVal 0
  0045    | GetLocalMove l3
  0047    | GetLocalMove l6
  0049    | InsertKeyVal 1
  0051    | End
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
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionLocal l1
  0010    | JumpIfFailure 10 -> 18
  0013    | MatchScrutinee r9
  0015    | MatchBind l6 r9
  0018    | TakeRight 18 -> 31
  0021    | CallFunctionLocal l3
  0023    | JumpIfFailure 23 -> 31
  0026    | MatchScrutinee r9
  0028    | MatchBind l7 r9
  0031    | TakeRight 31 -> 67
  0034    | CallFunctionLocal l5
  0036    | JumpIfFailure 36 -> 44
  0039    | MatchScrutinee r9
  0041    | MatchBind l8 r9
  0044    | TakeRight 44 -> 67
  0047    | GetConstantMutable 15: {_0_, _1_, _2_}
  0049    | GetLocalMove l0
  0051    | GetLocalMove l6
  0053    | InsertKeyVal 0
  0055    | GetLocalMove l2
  0057    | GetLocalMove l7
  0059    | InsertKeyVal 1
  0061    | GetLocalMove l4
  0063    | GetLocalMove l8
  0065    | InsertKeyVal 2
  0067    | End
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
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionLocal l1
  0010    | JumpIfFailure 10 -> 18
  0013    | MatchScrutinee r11
  0015    | MatchBind l8 r11
  0018    | TakeRight 18 -> 23
  0021    | CallFunctionLocal l2
  0023    | TakeRight 23 -> 36
  0026    | CallFunctionLocal l4
  0028    | JumpIfFailure 28 -> 36
  0031    | MatchScrutinee r11
  0033    | MatchBind l9 r11
  0036    | TakeRight 36 -> 41
  0039    | CallFunctionLocal l5
  0041    | TakeRight 41 -> 77
  0044    | CallFunctionLocal l7
  0046    | JumpIfFailure 46 -> 54
  0049    | MatchScrutinee r11
  0051    | MatchBind l10 r11
  0054    | TakeRight 54 -> 77
  0057    | GetConstantMutable 16: {_0_, _1_, _2_}
  0059    | GetLocalMove l0
  0061    | GetLocalMove l8
  0063    | InsertKeyVal 0
  0065    | GetLocalMove l3
  0067    | GetLocalMove l9
  0069    | InsertKeyVal 1
  0071    | GetLocalMove l6
  0073    | GetLocalMove l10
  0075    | InsertKeyVal 2
  0077    | End
  ========================================
  
  =================1:@fn0=================
  pair(key, value)
  ========================================
  0000    | PushVar key
  0002    | PushVar value
  0004    | SetClosureCaptures
  0005    | GetConstant 0: pair
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
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
  0007    | GetLocalMove l0
  0009    | GetLocalMove l1
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
  0011    | GetLocalMove l0
  0013    | GetLocalMove l1
  0015    | GetLocalMove l2
  0017    | GetLocalMove l3
  0019    | CallTailFunction 4
  0021    | End
  ========================================
  
  =================2:peek=================
  peek(p) = @input.offset -> Pos & @at(Pos, p)
  ========================================
  0000    | PushVar Pos
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionConstant 1: @input.offset
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 25
  0017    | GetConstant 2: @at
  0019    | GetLocalMove l1
  0021    | GetLocalMove l0
  0023    | CallTailFunction 2
  0025    | End
  ========================================
  
  ================2:unless================
  unless(p, excluded) = excluded ? @fail : p
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l1
  0003    | ConditionalThen 3 -> 11
  0006    | CallTailFunctionConstant 0: @fail
  0008    | Jump 8 -> 13
  0011    | CallTailFunctionLocal l0
  0013    | End
  ========================================
  
  ===============2:default================
  default(p, D) = p | const(D)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionLocal l0
  0003    | Or 3 -> 12
  0006    | GetConstant 3: const
  0008    | GetLocalMove l1
  0010    | CallTailFunction 1
  0012    | End
  ========================================
  
  ================2:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
