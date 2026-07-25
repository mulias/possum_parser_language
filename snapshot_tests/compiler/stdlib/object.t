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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l2 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 48
  0022    | CallFunctionLocal l1
  0024    | JumpIfFailure 24 -> 37
  0027    | MatchWindowEnter 2 fail->36
  0031    | MatchScrutinee r0
  0033    | MatchBind l3 r0
  0036    | MatchWindowExit
  0037    | TakeRight 37 -> 48
  0040    | GetConstantMutable 1: {_0_}
  0042    | GetLocalMove l2
  0044    | GetLocalMove l3
  0046    | InsertKeyVal 0
  0048    | End
  ========================================
  
  ===============1:pair_sep===============
  pair_sep(key, sep, value) = key -> K & sep & value -> V $ {K: V}
  ========================================
  0000    | PushVar K
  0002    | PushVar V
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l3 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 24
  0022    | CallFunctionLocal l1
  0024    | TakeRight 24 -> 53
  0027    | CallFunctionLocal l2
  0029    | JumpIfFailure 29 -> 42
  0032    | MatchWindowEnter 2 fail->41
  0036    | MatchScrutinee r0
  0038    | MatchBind l4 r0
  0041    | MatchWindowExit
  0042    | TakeRight 42 -> 53
  0045    | GetConstantMutable 3: {_0_}
  0047    | GetLocalMove l3
  0049    | GetLocalMove l4
  0051    | InsertKeyVal 0
  0053    | End
  ========================================
  
  ===============1:record1================
  record1(Key, value) = value -> Value $ {Key: Value}
  ========================================
  0000    | PushVar Value
  0002    | CallFunctionLocal l1
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 28
  0020    | GetConstantMutable 12: {_0_}
  0022    | GetLocalMove l0
  0024    | GetLocalMove l2
  0026    | InsertKeyVal 0
  0028    | End
  ========================================
  
  ===============1:record2================
  record2(Key1, value1, Key2, value2) =
    value1 -> V1 &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | CallFunctionLocal l1
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l4 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 54
  0022    | CallFunctionLocal l3
  0024    | JumpIfFailure 24 -> 37
  0027    | MatchWindowEnter 2 fail->36
  0031    | MatchScrutinee r0
  0033    | MatchBind l5 r0
  0036    | MatchWindowExit
  0037    | TakeRight 37 -> 54
  0040    | GetConstantMutable 13: {_0_, _1_}
  0042    | GetLocalMove l0
  0044    | GetLocalMove l4
  0046    | InsertKeyVal 0
  0048    | GetLocalMove l2
  0050    | GetLocalMove l5
  0052    | InsertKeyVal 1
  0054    | End
  ========================================
  
  =============1:record2_sep==============
  record2_sep(Key1, value1, sep, Key2, value2) =
    value1 -> V1 & sep &
    value2 -> V2 $
    {Key1: V1, Key2: V2}
  ========================================
  0000    | PushVar V1
  0002    | PushVar V2
  0004    | CallFunctionLocal l1
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l5 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 24
  0022    | CallFunctionLocal l2
  0024    | TakeRight 24 -> 59
  0027    | CallFunctionLocal l4
  0029    | JumpIfFailure 29 -> 42
  0032    | MatchWindowEnter 2 fail->41
  0036    | MatchScrutinee r0
  0038    | MatchBind l6 r0
  0041    | MatchWindowExit
  0042    | TakeRight 42 -> 59
  0045    | GetConstantMutable 14: {_0_, _1_}
  0047    | GetLocalMove l0
  0049    | GetLocalMove l5
  0051    | InsertKeyVal 0
  0053    | GetLocalMove l3
  0055    | GetLocalMove l6
  0057    | InsertKeyVal 1
  0059    | End
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
  0006    | CallFunctionLocal l1
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l6 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 39
  0024    | CallFunctionLocal l3
  0026    | JumpIfFailure 26 -> 39
  0029    | MatchWindowEnter 2 fail->38
  0033    | MatchScrutinee r0
  0035    | MatchBind l7 r0
  0038    | MatchWindowExit
  0039    | TakeRight 39 -> 80
  0042    | CallFunctionLocal l5
  0044    | JumpIfFailure 44 -> 57
  0047    | MatchWindowEnter 2 fail->56
  0051    | MatchScrutinee r0
  0053    | MatchBind l8 r0
  0056    | MatchWindowExit
  0057    | TakeRight 57 -> 80
  0060    | GetConstantMutable 15: {_0_, _1_, _2_}
  0062    | GetLocalMove l0
  0064    | GetLocalMove l6
  0066    | InsertKeyVal 0
  0068    | GetLocalMove l2
  0070    | GetLocalMove l7
  0072    | InsertKeyVal 1
  0074    | GetLocalMove l4
  0076    | GetLocalMove l8
  0078    | InsertKeyVal 2
  0080    | End
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
  0006    | CallFunctionLocal l1
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l8 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 26
  0024    | CallFunctionLocal l2
  0026    | TakeRight 26 -> 44
  0029    | CallFunctionLocal l4
  0031    | JumpIfFailure 31 -> 44
  0034    | MatchWindowEnter 2 fail->43
  0038    | MatchScrutinee r0
  0040    | MatchBind l9 r0
  0043    | MatchWindowExit
  0044    | TakeRight 44 -> 49
  0047    | CallFunctionLocal l5
  0049    | TakeRight 49 -> 90
  0052    | CallFunctionLocal l7
  0054    | JumpIfFailure 54 -> 67
  0057    | MatchWindowEnter 2 fail->66
  0061    | MatchScrutinee r0
  0063    | MatchBind l10 r0
  0066    | MatchWindowExit
  0067    | TakeRight 67 -> 90
  0070    | GetConstantMutable 16: {_0_, _1_, _2_}
  0072    | GetLocalMove l0
  0074    | GetLocalMove l8
  0076    | InsertKeyVal 0
  0078    | GetLocalMove l3
  0080    | GetLocalMove l9
  0082    | InsertKeyVal 1
  0084    | GetLocalMove l6
  0086    | GetLocalMove l10
  0088    | InsertKeyVal 2
  0090    | End
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
  0002    | CallFunctionConstant 1: @input.offset
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 28
  0020    | GetConstant 2: @at
  0022    | GetLocalMove l1
  0024    | GetLocalMove l0
  0026    | CallTailFunction 2
  0028    | End
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
