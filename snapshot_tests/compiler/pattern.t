  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p 'const([1,2,3]) -> [1,2,3]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2,3]) -> [1,2,3]
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: const
  0007    | GetConstant 1: [1, 2, 3]
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 60
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 59
  0021    | MatchLen r0 3 -> 59
  0026    | MatchElem r1 r0[0]
  0030    | MatchConst r1 1 -> 59
  0036    | MatchElem r2 r0[1]
  0040    | MatchConst r2 2 -> 59
  0046    | MatchElem r3 r0[2]
  0050    | MatchConst r3 3 -> 59
  0056    | Jump 56 -> 60
  0059    | MatchFail
  0060    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A,B,C]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2,3]) -> [A,B,C]
  ========================================
  0000    | PushVar A
  0002    | PushVar B
  0004    | PushVar C
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | GetConstant 0: const
  0013    | GetConstant 1: [1, 2, 3]
  0015    | CallFunction 1
  0017    | JumpIfFailure 17 -> 57
  0020    | MatchScrutinee r3
  0022    | MatchType r3 array -> 56
  0027    | MatchLen r3 3 -> 56
  0032    | MatchElem r4 r3[0]
  0036    | MatchBind l0 r4
  0039    | MatchElem r5 r3[1]
  0043    | MatchBind l1 r5
  0046    | MatchElem r6 r3[2]
  0050    | MatchBind l2 r6
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | End
  ========================================

  $ possum -p 'A = 1 ; const([1,2,3]) -> [A,B,C]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2,3]) -> [A,B,C]
  ========================================
  0000    | PushVar B
  0002    | PushVar C
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | GetConstant 0: const
  0011    | GetConstant 1: [1, 2, 3]
  0013    | CallFunction 1
  0015    | JumpIfFailure 15 -> 58
  0018    | MatchScrutinee r2
  0020    | MatchType r2 array -> 57
  0025    | MatchLen r2 3 -> 57
  0030    | MatchElem r3 r2[0]
  0034    | MatchGlobal r3 1 -> 57
  0040    | MatchElem r4 r2[1]
  0044    | MatchBind l0 r4
  0047    | MatchElem r5 r2[2]
  0051    | MatchBind l1 r5
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 2, 3]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2,3]) -> [A, 2, 3]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: const
  0009    | GetConstant 1: [1, 2, 3]
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 59
  0016    | MatchScrutinee r1
  0018    | MatchType r1 array -> 58
  0023    | MatchLen r1 3 -> 58
  0028    | MatchElem r2 r1[0]
  0032    | MatchBind l0 r2
  0035    | MatchElem r3 r1[1]
  0039    | MatchConst r3 2 -> 58
  0045    | MatchElem r4 r1[2]
  0049    | MatchConst r4 3 -> 58
  0055    | Jump 55 -> 59
  0058    | MatchFail
  0059    | End
  ========================================

  $ possum -p 'const([1,[[2],3]]) -> [A, [[B], 3]] $ B' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,[[2],3]]) -> [A, [[B], 3]] $ B
  ========================================
  0000    | PushVar A
  0002    | PushVar B
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | GetConstant 0: const
  0013    | GetConstantMutable 1: [1, _]
  0015    | GetConstantMutable 2: [_, 3]
  0017    | GetConstant 3: [2]
  0019    | InsertAtIndex 0
  0021    | InsertAtIndex 1
  0023    | CallFunction 1
  0025    | JumpIfFailure 25 -> 96
  0028    | MatchScrutinee r2
  0030    | MatchType r2 array -> 95
  0035    | MatchLen r2 2 -> 95
  0040    | MatchElem r3 r2[0]
  0044    | MatchBind l0 r3
  0047    | MatchElem r4 r2[1]
  0051    | MatchType r4 array -> 95
  0056    | MatchLen r4 2 -> 95
  0061    | MatchElem r5 r4[0]
  0065    | MatchType r5 array -> 95
  0070    | MatchLen r5 1 -> 95
  0075    | MatchElem r6 r5[0]
  0079    | MatchBind l1 r6
  0082    | MatchElem r7 r4[1]
  0086    | MatchConst r7 3 -> 95
  0092    | Jump 92 -> 96
  0095    | MatchFail
  0096    | TakeRight 96 -> 101
  0099    | GetLocalMove l1
  0101    | End
  ========================================

  $ possum -p '3 -> (2 + B)' -i '3'
  
  ================2:@main=================
  3 -> (2 + B)
  ========================================
  0000    | PushVar B
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | ParseNumberStringChar 3
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchScrutinee r1
  0011    | MatchMergeNum r2 r1 - 2 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [A, 1 + 1, 3]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2,3]) -> [A, 1 + 1, 3]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: const
  0009    | GetConstant 1: [1, 2, 3]
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 59
  0016    | MatchScrutinee r1
  0018    | MatchType r1 array -> 58
  0023    | MatchLen r1 3 -> 58
  0028    | MatchElem r2 r1[0]
  0032    | MatchBind l0 r2
  0035    | MatchElem r3 r1[1]
  0039    | MatchConst r3 2 -> 58
  0045    | MatchElem r4 r1[2]
  0049    | MatchConst r4 3 -> 58
  0055    | Jump 55 -> 59
  0058    | MatchFail
  0059    | End
  ========================================

  $ possum -p 'const([1, @Add(1, 2), 3]) -> [A, @Add(1, 1), 3]' -i ''
  
  =================0:@Add=================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 1: addNative
  0006    | End
  ========================================
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1, @Add(1, 2), 3]) -> [A, @Add(1, 1), 3]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: const
  0009    | GetConstantMutable 1: [1, _, 3]
  0011    | GetConstant 2: @Add
  0013    | PushInteger 1
  0015    | PushInteger 2
  0017    | CallFunction 2
  0019    | InsertAtIndex 1
  0021    | CallFunction 1
  0023    | JumpIfFailure 23 -> 76
  0026    | MatchScrutinee r1
  0028    | MatchType r1 array -> 75
  0033    | MatchLen r1 3 -> 75
  0038    | MatchElem r2 r1[0]
  0042    | MatchBind l0 r2
  0045    | MatchElem r3 r1[1]
  0049    | GetConstant 2: @Add
  0051    | PushInteger 1
  0053    | PushInteger 1
  0055    | CallFunction 2
  0057    | MatchEval r3 -> 75
  0062    | MatchElem r4 r1[2]
  0066    | MatchConst r4 3 -> 75
  0072    | Jump 72 -> 76
  0075    | MatchFail
  0076    | End
  ========================================

  $ possum -p 'const([1,2]) -> ([1] + [2])' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2]) -> ([1] + [2])
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | GetConstant 0: const
  0006    | GetConstant 1: [1, 2]
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 49
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 48
  0020    | MatchLen r0 2 -> 48
  0025    | MatchElem r1 r0[0]
  0029    | MatchConst r1 1 -> 48
  0035    | MatchElem r2 r0[1]
  0039    | MatchConst r2 2 -> 48
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> ([1] + B + [3])' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2,3]) -> ([1] + B + [3])
  ========================================
  0000    | PushVar B
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: const
  0009    | GetConstant 1: [1, 2, 3]
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 60
  0016    | MatchScrutinee r1
  0018    | MatchType r1 array -> 59
  0023    | MatchLenMin r1 2 -> 59
  0028    | MatchElem r2 r1[0]
  0032    | MatchConst r2 1 -> 59
  0038    | MatchSlice r3 r1[1..^1]
  0043    | MatchBind l0 r3
  0046    | MatchElemBack r4 r1[^0]
  0050    | MatchConst r4 3 -> 59
  0056    | Jump 56 -> 60
  0059    | MatchFail
  0060    | End
  ========================================

  $ possum -p 'const([1,[2],2,3]) -> ([1,A] + A + [3])' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,[2],2,3]) -> ([1,A] + A + [3])
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | GetConstant 0: const
  0010    | GetConstantMutable 1: [1, _, 2, 3]
  0012    | GetConstant 2: [2]
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | JumpIfFailure 18 -> 74
  0021    | MatchScrutinee r1
  0023    | MatchType r1 array -> 73
  0028    | MatchLenMin r1 3 -> 73
  0033    | MatchElem r2 r1[0]
  0037    | MatchConst r2 1 -> 73
  0043    | MatchElem r3 r1[1]
  0047    | MatchBind l0 r3
  0050    | MatchSlice r4 r1[2..^1]
  0055    | MatchSlot r4 l0 -> 73
  0060    | MatchElemBack r5 r1[^0]
  0064    | MatchConst r5 3 -> 73
  0070    | Jump 70 -> 74
  0073    | MatchFail
  0074    | End
  ========================================

  $ possum -p '"foobar" -> ("fo" + Ob + "ar") $ Ob' -i ''
  
  ================2:@main=================
  "foobar" -> ("fo" + Ob + "ar") $ Ob
  ========================================
  0000    | PushVar Ob
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | CallFunctionConstant 0: "foobar"
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchScrutinee r1
  0012    | MatchType r1 string -> 45
  0017    | MatchLenMin r1 4 -> 45
  0022    | MatchStrPrefix r1 "fo" -> 45
  0028    | MatchStrSuffix r1 "ar" -> 45
  0034    | MatchSlice r2 r1[2..^2]
  0039    | MatchBind l0 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | TakeRight 46 -> 51
  0049    | GetLocalMove l0
  0051    | End
  ========================================

  $ possum -p 'const([1,2,3]) -> [1, ...Rest] $ Rest' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1,2,3]) -> [1, ...Rest] $ Rest
  ========================================
  0000    | PushVar Rest
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: const
  0008    | GetConstant 1: [1, 2, 3]
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 49
  0015    | MatchScrutinee r1
  0017    | MatchType r1 array -> 48
  0022    | MatchLenMin r1 1 -> 48
  0027    | MatchElem r2 r1[0]
  0031    | MatchConst r2 1 -> 48
  0037    | MatchSlice r3 r1[1..^0]
  0042    | MatchBind l0 r3
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | TakeRight 49 -> 54
  0052    | GetLocalMove l0
  0054    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, "b": 2}' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2}) -> {"a": 1, "b": 2}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | GetConstant 0: const
  0006    | GetConstant 1: {"a": 1, "b": 2}
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 55
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 54
  0020    | MatchKeys r0 2 -> 54
  0025    | MatchKey r1 r0["a"] -> 54
  0032    | MatchConst r1 1 -> 54
  0038    | MatchKey r2 r0["b"] -> 54
  0045    | MatchConst r2 2 -> 54
  0051    | Jump 51 -> 55
  0054    | MatchFail
  0055    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": A, "b": B}' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2}) -> {"a": A, "b": B}
  ========================================
  0000    | PushVar A
  0002    | PushVar B
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | GetConstant 0: const
  0010    | GetConstant 1: {"a": 1, "b": 2}
  0012    | CallFunction 1
  0014    | JumpIfFailure 14 -> 53
  0017    | MatchScrutinee r2
  0019    | MatchType r2 object -> 52
  0024    | MatchKeys r2 2 -> 52
  0029    | MatchKey r3 r2["a"] -> 52
  0036    | MatchBind l0 r3
  0039    | MatchKey r4 r2["b"] -> 52
  0046    | MatchBind l1 r4
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": _, "b": _}' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2}) -> {"a": _, "b": _}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: const
  0005    | GetConstant 1: {"a": 1, "b": 2}
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 42
  0012    | MatchScrutinee r1
  0014    | MatchType r1 object -> 41
  0019    | MatchKeys r1 2 -> 41
  0024    | MatchKey r2 r1["a"] -> 41
  0031    | MatchKey r2 r1["b"] -> 41
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"a": 1} + B)' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2}) -> ({"a": 1} + B)
  ========================================
  0000    | PushVar B
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: const
  0008    | GetConstant 1: {"a": 1, "b": 2}
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 52
  0015    | MatchScrutinee r1
  0017    | MatchType r1 object -> 51
  0022    | MatchKeysMin r1 1 -> 51
  0027    | MatchKey r2 r1["a"] -> 51
  0034    | MatchConst r2 1 -> 51
  0040    | MatchObjectRest r3 r1 \ ["a"]
  0045    | MatchBind l0 r3
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> ({"b": 2} + A)' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2}) -> ({"b": 2} + A)
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: const
  0008    | GetConstant 1: {"a": 1, "b": 2}
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 52
  0015    | MatchScrutinee r1
  0017    | MatchType r1 object -> 51
  0022    | MatchKeysMin r1 1 -> 51
  0027    | MatchKey r2 r1["b"] -> 51
  0034    | MatchConst r2 2 -> 51
  0040    | MatchObjectRest r3 r1 \ ["b"]
  0045    | MatchBind l0 r3
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> (A + {"b": 2})' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2}) -> (A + {"b": 2})
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: const
  0008    | GetConstant 1: {"a": 1, "b": 2}
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 52
  0015    | MatchScrutinee r1
  0017    | MatchType r1 object -> 51
  0022    | MatchKeysMin r1 1 -> 51
  0027    | MatchObjectRest r2 r1 \ ["b"]
  0032    | MatchBind l0 r2
  0035    | MatchKey r3 r1["b"] -> 51
  0042    | MatchConst r3 2 -> 51
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | End
  ========================================

  $ possum -p 'const({"a": 1, "b": 2}) -> {"a": 1, ...B}' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2}) -> {"a": 1, ...B}
  ========================================
  0000    | PushVar B
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: const
  0008    | GetConstant 1: {"a": 1, "b": 2}
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 52
  0015    | MatchScrutinee r1
  0017    | MatchType r1 object -> 51
  0022    | MatchKeysMin r1 1 -> 51
  0027    | MatchKey r2 r1["a"] -> 51
  0034    | MatchConst r2 1 -> 51
  0040    | MatchObjectRest r3 r1 \ ["a"]
  0045    | MatchBind l0 r3
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  ================2:@main=================
  2 -> 0..5
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 2
  0004    | JumpIfFailure 4 -> 23
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 0..5 -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================

  $ possum -p 'char -> "a".."z"' -i 'q'
  
  =================3:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  ================2:@main=================
  char -> "a".."z"
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | CallFunctionConstant 0: char
  0004    | JumpIfFailure 4 -> 23
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 "a".."z" -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================

  $ possum -p 'char -> .."z"' -i '!'
  
  =================3:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
  ========================================
  
  ================2:@main=================
  char -> .."z"
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | CallFunctionConstant 0: char
  0004    | JumpIfFailure 4 -> 23
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 .."z" -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================

  $ possum -p 'const(Is.Array([1])) ; Is.Array(V) = V -> [..._]' -i '1'
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ===============2:Is.Array===============
  Is.Array(V) = V -> [..._]
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r2
  0010    | MatchType r2 array -> 23
  0015    | MatchLenMin r2 0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | End
  ========================================
  
  ================2:@main=================
  const(Is.Array([1]))
  ========================================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: Is.Array
  0004    | GetConstant 2: [1]
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================

  $ possum -p '
  > __Table.RestPerRow(T, Acc) =
  >   T -> [Row, ...Rest] ? (
  >     Row -> [_, ...RowRest] ?
  >     __Table.RestPerRow(Rest, [...Acc, RowRest]) :
  >     __Table.RestPerRow(Rest, [...Acc, []])
  >   ) :
  >   Acc
  > 1
  > ' -i '1'
  
  ==========2:__Table.RestPerRow==========
  __Table.RestPerRow(T, Acc) =
    T -> [Row, ...Rest] ? (
      Row -> [_, ...RowRest] ?
      __Table.RestPerRow(Rest, [...Acc, RowRest]) :
      __Table.RestPerRow(Rest, [...Acc, []])
    ) :
    Acc
  ========================================
  0000    | PushVar Row
  0002    | PushVar Rest
  0004    | PushUnderscoreVar
  0005    | PushVar RowRest
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushUnderscoreVar
  0011    | SetInputMark
  0012    | GetLocalMove l0
  0014    | JumpIfFailure 14 -> 48
  0017    | MatchScrutinee r6
  0019    | MatchType r6 array -> 47
  0024    | MatchLenMin r6 1 -> 47
  0029    | MatchElem r7 r6[0]
  0033    | MatchBind l2 r7
  0036    | MatchSlice r8 r6[1..^0]
  0041    | MatchBind l3 r8
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | ConditionalThen 48 -> 132
  0051    | SetInputMark
  0052    | GetLocalMove l2
  0054    | JumpIfFailure 54 -> 81
  0057    | MatchScrutinee r6
  0059    | MatchType r6 array -> 80
  0064    | MatchLenMin r6 1 -> 80
  0069    | MatchSlice r7 r6[1..^0]
  0074    | MatchBind l5 r7
  0077    | Jump 77 -> 81
  0080    | MatchFail
  0081    | ConditionalThen 81 -> 110
  0084    | GetConstant 0: __Table.RestPerRow
  0086    | GetLocalMove l3
  0088    | PushEmptyArray
  0089    | JumpIfFailure 89 -> 95
  0092    | GetLocalMove l1
  0094    | Merge
  0095    | JumpIfFailure 95 -> 105
  0098    | GetConstantMutable 1: [_]
  0100    | GetLocalMove l5
  0102    | InsertAtIndex 0
  0104    | Merge
  0105    | CallTailFunction 2
  0107    | Jump 107 -> 129
  0110    | GetConstant 0: __Table.RestPerRow
  0112    | GetLocalMove l3
  0114    | PushEmptyArray
  0115    | JumpIfFailure 115 -> 121
  0118    | GetLocalMove l1
  0120    | Merge
  0121    | JumpIfFailure 121 -> 127
  0124    | GetConstant 2: [[]]
  0126    | Merge
  0127    | CallTailFunction 2
  0129    | Jump 129 -> 134
  0132    | GetLocalMove l1
  0134    | End
  ========================================
  
  ================2:@main=================
  1
  ========================================
  0000    | ParseNumberStringChar 1
  0002    | End
  ========================================

  $ possum -p 'Obj.Get(O, K) = O -> {K: V, ..._} & V ; 1' -i '1'
  
  ===============2:Obj.Get================
  Obj.Get(O, K) = O -> {K: V, ..._} & V
  ========================================
  0000    | PushVar V
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | GetLocalMove l0
  0010    | JumpIfFailure 10 -> 42
  0013    | MatchScrutinee r4
  0015    | MatchType r4 object -> 41
  0020    | MatchKeysMin r4 1 -> 41
  0025    | MatchKeyBound key=r6 val=r7 src=r4[l1] keys=r6..r6 \ [] -> 41
  0035    | MatchBind l2 r7
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | TakeRight 42 -> 47
  0045    | GetLocalMove l2
  0047    | End
  ========================================
  
  ================2:@main=================
  1
  ========================================
  0000    | ParseNumberStringChar 1
  0002    | End
  ========================================

  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  
  ================2:@main=================
  4 -> (1 + 1 + 2)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 4
  0004    | JumpIfFailure 4 -> 19
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 4 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 + 3)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 5
  0004    | JumpIfFailure 4 -> 19
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 5 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================

  $ possum -p '5 -> (2 + X + 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 + X + 3)
  ========================================
  0000    | PushVar X
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | ParseNumberStringChar 5
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchScrutinee r1
  0011    | MatchMergeNum r2 r1 - 5 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | End
  ========================================

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  
  ================2:@main=================
  7 -> (X + 4)
  ========================================
  0000    | ParseNumberStringChar 7
  0002    | DestructurePlan 0: (eq 3 + eq 4)
  0004    | End
  ========================================

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  
  ================2:@main=================
  5 -> (X + Y)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | DestructurePlan 0: (eq 2 + eq 3)
  0004    | End
  ========================================

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 + X + 3) $ X
  ========================================
  0000    | PushVar X
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | ParseNumberStringChar 6
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchScrutinee r1
  0011    | MatchMergeNum r2 r1 - 4 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | TakeRight 25 -> 30
  0028    | GetLocalMove l0
  0030    | End
  ========================================

  $ possum -p '5 -> (2 - 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 - 3)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 5
  0004    | JumpIfFailure 4 -> 19
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 -1 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================

  $ possum -p '6 -> (1 + X - 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 + X - 3) $ X
  ========================================
  0000    | PushVar X
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | ParseNumberStringChar 6
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchScrutinee r1
  0011    | MatchMergeNum r2 r1 - -2 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | TakeRight 25 -> 30
  0028    | GetLocalMove l0
  0030    | End
  ========================================

  $ possum -p '6 -> (1 - X + 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 - X + 3) $ X
  ========================================
  0000    | PushVar X
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | ParseNumberStringChar 6
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchScrutinee r1
  0011    | MatchMergeNumNeg r2 r1 - 4 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | TakeRight 25 -> 30
  0028    | GetLocalMove l0
  0030    | End
  ========================================

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  
  ================2:@main=================
  5 -> (1 + 6 + 3 - (2 + 3))
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 5
  0004    | JumpIfFailure 4 -> 19
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 5 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================

  $ possum -p '5 -> -(X + 1) $ X' -i '5'
  
  ================2:@main=================
  5 -> -(X + 1) $ X
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 5
  0004    | DestructurePlan 0: negated (bind X + eq 1)
  0006    | TakeRight 6 -> 11
  0009    | GetLocalMove l0
  0011    | End
  ========================================

  $ possum -p 'const([1, 5, 2]) -> [1, -(X + 1), 2] $ X' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([1, 5, 2]) -> [1, -(X + 1), 2] $ X
  ========================================
  0000    | PushVar X
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 5, 2]
  0006    | CallFunction 1
  0008    | DestructurePlan 0: [eq 1, negated (bind X + eq 1), eq 2]
  0010    | TakeRight 10 -> 15
  0013    | GetLocalMove l0
  0015    | End
  ========================================

  $ possum -p '"1" -> "%(1)"' -i '1'
  
  ================2:@main=================
  "1" -> "%(1)"
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | ParseChar '1'
  0008    | JumpIfFailure 8 -> 40
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string -> 39
  0018    | MatchStrInit r0 front=r2 end=r3
  0022    | MatchStrLit r0 cursor=r2 opp=r3 front "1" -> 39
  0031    | MatchStrCovered r2==r3 -> 39
  0036    | Jump 36 -> 40
  0039    | MatchFail
  0040    | End
  ========================================

  $ possum -p '"2" -> "%(1 + 1)"' -i '2'
  
  ================2:@main=================
  "2" -> "%(1 + 1)"
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | ParseChar '2'
  0008    | JumpIfFailure 8 -> 40
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string -> 39
  0018    | MatchStrInit r0 front=r2 end=r3
  0022    | MatchStrLit r0 cursor=r2 opp=r3 front "2" -> 39
  0031    | MatchStrCovered r2==r3 -> 39
  0036    | Jump 36 -> 40
  0039    | MatchFail
  0040    | End
  ========================================

  $ possum -p '"50" -> "%(0 + N)" $ N' -i '50'
  
  ================2:@main=================
  "50" -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionConstant 0: "50"
  0010    | JumpIfFailure 10 -> 32
  0013    | MatchScrutinee r1
  0015    | MatchType r1 string -> 31
  0020    | MatchCastNum r5 <- r1 -> 31
  0025    | MatchBind l0 r5
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | TakeRight 32 -> 37
  0035    | GetLocalMove l0
  0037    | End
  ========================================

  $ possum -p '"ab" * 3' -i 'ababab'
  
  ================2:@main=================
  "ab" * 3
  ========================================
  0000    | PushNull
  0001    | PushInteger 3
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | CallFunctionConstant 0: "ab"
  0010    | Merge
  0011    | JumpIfFailure 11 -> 22
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 23
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | Drop
  0024    | End
  ========================================

  $ possum -p '2 * (2 * 2)' -i '2222'
  
  ================2:@main=================
  2 * (2 * 2)
  ========================================
  0000    | PushNull
  0001    | PushInteger 4
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | ParseNumberStringChar 2
  0010    | Merge
  0011    | JumpIfFailure 11 -> 22
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 23
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | Drop
  0024    | End
  ========================================

  $ possum -p '2 * (2 + (-1 * -1))' -i '2222'
  
  ================2:@main=================
  2 * (2 + (-1 * -1))
  ========================================
  0000    | PushNull
  0001    | PushInteger 3
  0003    | ValidateRepeatPattern
  0004    | JumpIfZero 4 -> 23
  0007    | Swap
  0008    | ParseNumberStringChar 2
  0010    | Merge
  0011    | JumpIfFailure 11 -> 22
  0014    | Swap
  0015    | Decrement
  0016    | JumpIfZero 16 -> 23
  0019    | JumpBack 19 -> 7
  0022    | Swap
  0023    | Drop
  0024    | End
  ========================================

  $ possum -p '123 -> V' -i '123'
  
  ================2:@main=================
  123 -> V
  ========================================
  0000    | PushVar V
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionConstant 0: 123
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r1
  0011    | MatchBind l0 r1
  0014    | End
  ========================================

  $ possum -p '"abc" -> "abc"' -i 'abc'
  
  ================2:@main=================
  "abc" -> "abc"
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | CallFunctionConstant 0: "abc"
  0004    | JumpIfFailure 4 -> 19
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 "abc" -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================

  $ possum -p 'many(char) -> `\nfoo`' -i '\nfoo'
  
  =================3:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
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
  many(char) -> `\nfoo`
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | GetConstant 0: many
  0004    | GetConstant 1: char
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 23
  0011    | MatchScrutinee r0
  0013    | MatchConst r0 "\nfoo" -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================

  $ possum -p 'many(char) -> "%(`a`..`z`)%(_)"' -i 'abcd'
  
  =================3:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
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
  many(char) -> "%(`a`..`z`)%(_)"
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: many
  0009    | GetConstant 1: char
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 49
  0016    | MatchScrutinee r1
  0018    | MatchType r1 string -> 48
  0023    | MatchStrInit r1 front=r3 end=r4
  0027    | MatchStrChar r6 r1 cursor=r3 opp=r4 front -> 48
  0035    | MatchInRange r6 "a".."z" -> 48
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | End
  ========================================

  $ possum -p 'numerals -> ("3" * 10)' -i '3333333333'
  
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
  numerals -> ("3" * 10)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | CallFunctionConstant 0: numerals
  0005    | JumpIfFailure 5 -> 27
  0008    | MatchScrutinee r0
  0010    | PushString "3"
  0012    | MatchRepeatValue r0 r2 -> 26
  0017    | MatchConst r2 10 -> 26
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | End
  ========================================

  $ possum -p 'many(char) -> ("\u000000".. * 10)' -i '12345678901234567890'
  
  =================3:char=================
  char = "\u000000"..
  ========================================
  0000    | ParseCodepoint
  0001    | End
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
  many(char) -> ("\u000000".. * 10)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: many
  0005    | GetConstant 1: char
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 35
  0012    | MatchScrutinee r0
  0014    | MatchRepeatRange r0 r2 _0_.. -> 34
  0025    | MatchConst r2 10 -> 34
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | End
  ========================================

  $ possum -p 'bool(1, 0) -> true' -i '1'
  
  =================5:true=================
  true(t) = t $ true
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 6
  0005    | PushTrue
  0006    | End
  ========================================
  
  ================5:false=================
  false(f) = f $ false
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 6
  0005    | PushFalse
  0006    | End
  ========================================
  
  ===============5:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetLocalMove l0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetLocalMove l1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ===============5:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetLocalMove l0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetLocalMove l1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ================2:@main=================
  bool(1, 0) -> true
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | GetConstant 0: boolean
  0004    | PushNumberStringOne
  0005    | PushNumberStringZero
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 23
  0011    | MatchScrutinee r0
  0013    | MatchConst r0 true -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================

  $ possum -p 'int -> 5' -i '5'
  
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionLocal l0
  0010    | JumpIfFailure 10 -> 32
  0013    | MatchScrutinee r2
  0015    | MatchType r2 string -> 31
  0020    | MatchCastNum r6 <- r2 -> 31
  0025    | MatchBind l1 r6
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | TakeRight 32 -> 37
  0035    | GetLocalMove l1
  0037    | End
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
  int -> 5
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | CallFunctionConstant 0: integer
  0004    | JumpIfFailure 4 -> 19
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 5 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | End
  ========================================

  $ possum -p '5 -> 2..7' -i '5'
  
  ================2:@main=================
  5 -> 2..7
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 5
  0004    | JumpIfFailure 4 -> 23
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 2..7 -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | End
  ========================================

  $ possum -p '8 -> (0 + N)' -i '8'
  
  ================2:@main=================
  8 -> (0 + N)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | ParseNumberStringChar 8
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchScrutinee r1
  0011    | MatchMergeNum r2 r1 - 0 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | End
  ========================================

  $ possum -p '8 -> (N + 100)' -i '8'
  
  ================2:@main=================
  8 -> (N + 100)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | ParseNumberStringChar 8
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchScrutinee r1
  0011    | MatchMergeNum r2 r1 - 100 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | End
  ========================================

  $ possum -p 'array(digit) -> [1, 2, 3]' -i '123'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [1, 2, 3]
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: array
  0007    | GetConstant 1: digit
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 60
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 59
  0021    | MatchLen r0 3 -> 59
  0026    | MatchElem r1 r0[0]
  0030    | MatchConst r1 1 -> 59
  0036    | MatchElem r2 r0[1]
  0040    | MatchConst r2 2 -> 59
  0046    | MatchElem r3 r0[2]
  0050    | MatchConst r3 3 -> 59
  0056    | Jump 56 -> 60
  0059    | MatchFail
  0060    | End
  ========================================

  $ possum -p 'array(digit) -> [A, ..._]' -i '123'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [A, ..._]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: array
  0008    | GetConstant 1: digit
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 38
  0015    | MatchScrutinee r2
  0017    | MatchType r2 array -> 37
  0022    | MatchLenMin r2 1 -> 37
  0027    | MatchElem r3 r2[0]
  0031    | MatchBind l0 r3
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | End
  ========================================

  $ possum -p 'array(digit) -> ([1] * 5)' -i '11111'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([1] * 5)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: array
  0007    | GetConstant 1: digit
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 70
  0014    | MatchScrutinee r0
  0016    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 69
  0023    | MatchConst r2 5 -> 69
  0029    | MatchRepeatNext r0 base=r3+1 done->66
  0035    | MatchElemDyn r4 r0[r3+0]
  0040    | MatchConst r4 1 -> 69
  0046    | MatchRepeatNext r0 base=r3+1 done->66
  0052    | MatchElemDyn r4 r0[r3+0]
  0057    | MatchConst r4 1 -> 69
  0063    | JumpBack 63 -> 46
  0066    | Jump 66 -> 70
  0069    | MatchFail
  0070    | End
  ========================================

  $ possum -p 'array(digit) -> ([A] * 5)' -i '11111'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([A] * 5)
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: array
  0009    | GetConstant 1: digit
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 68
  0016    | MatchScrutinee r1
  0018    | MatchRepeatInit r1 /1 n=r3 base=r4 -> 67
  0025    | MatchConst r3 5 -> 67
  0031    | MatchRepeatNext r1 base=r4+1 done->64
  0037    | MatchElemDyn r5 r1[r4+0]
  0042    | MatchBind l0 r5
  0045    | MatchRepeatNext r1 base=r4+1 done->64
  0051    | MatchElemDyn r5 r1[r4+0]
  0056    | MatchSlot r5 l0 -> 67
  0061    | JumpBack 61 -> 45
  0064    | Jump 64 -> 68
  0067    | MatchFail
  0068    | End
  ========================================

  $ possum -p 'array(digit) -> ([1] * N) $ N' -i '11111111'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([1] * N) $ N
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: array
  0009    | GetConstant 1: digit
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 69
  0016    | MatchScrutinee r1
  0018    | MatchRepeatInit r1 /1 n=r3 base=r4 -> 68
  0025    | MatchBind l0 r3
  0028    | MatchRepeatNext r1 base=r4+1 done->65
  0034    | MatchElemDyn r5 r1[r4+0]
  0039    | MatchConst r5 1 -> 68
  0045    | MatchRepeatNext r1 base=r4+1 done->65
  0051    | MatchElemDyn r5 r1[r4+0]
  0056    | MatchConst r5 1 -> 68
  0062    | JumpBack 62 -> 45
  0065    | Jump 65 -> 69
  0068    | MatchFail
  0069    | TakeRight 69 -> 74
  0072    | GetLocalMove l0
  0074    | End
  ========================================

  $ possum -p 'array(digit) -> [A, ..._, Z]' -i '12345678'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [A, ..._, Z]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushVar Z
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | GetConstant 0: array
  0011    | GetConstant 1: digit
  0013    | CallFunction 1
  0015    | JumpIfFailure 15 -> 48
  0018    | MatchScrutinee r3
  0020    | MatchType r3 array -> 47
  0025    | MatchLenMin r3 2 -> 47
  0030    | MatchElem r4 r3[0]
  0034    | MatchBind l0 r4
  0037    | MatchElemBack r5 r3[^0]
  0041    | MatchBind l2 r5
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | End
  ========================================

  $ possum -p 'array(digit) -> [1, B, _]' -i '123'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [1, B, _]
  ========================================
  0000    | PushVar B
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | GetConstant 0: array
  0009    | GetConstant 1: digit
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 49
  0016    | MatchScrutinee r2
  0018    | MatchType r2 array -> 48
  0023    | MatchLen r2 3 -> 48
  0028    | MatchElem r3 r2[0]
  0032    | MatchConst r3 1 -> 48
  0038    | MatchElem r4 r2[1]
  0042    | MatchBind l0 r4
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": 1, "b": 2}' -i 'a1b2'
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============10:object================
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
  
  ================10:pair=================
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": 1, "b": 2}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | GetConstant 0: object
  0006    | GetConstant 1: alpha
  0008    | GetConstant 2: digit
  0010    | CallFunction 2
  0012    | JumpIfFailure 12 -> 57
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 56
  0022    | MatchKeys r0 2 -> 56
  0027    | MatchKey r1 r0["a"] -> 56
  0034    | MatchConst r1 1 -> 56
  0040    | MatchKey r2 r0["b"] -> 56
  0047    | MatchConst r2 2 -> 56
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": 1, ..._}' -i 'a1b2'
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============10:object================
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
  
  ================10:pair=================
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": 1, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | GetConstant 0: object
  0006    | GetConstant 1: alpha
  0008    | GetConstant 2: digit
  0010    | CallFunction 2
  0012    | JumpIfFailure 12 -> 44
  0015    | MatchScrutinee r1
  0017    | MatchType r1 object -> 43
  0022    | MatchKeysMin r1 1 -> 43
  0027    | MatchKey r2 r1["a"] -> 43
  0034    | MatchConst r2 1 -> 43
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {_: 1, ..._}' -i 'a1b2'
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============10:object================
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
  
  ================10:pair=================
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
  
  ================2:@main=================
  object(alpha, digit) -> {_: 1, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: object
  0008    | GetConstant 1: alpha
  0010    | GetConstant 2: digit
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 57
  0017    | MatchScrutinee r1
  0019    | MatchType r1 object -> 56
  0024    | MatchKeysMin r1 1 -> 56
  0029    | MatchSearchInit r5
  0031    | MatchNextUnclaimed key=r3 val=r4 src=r1 cursor=r5 keys=r3..r3 \ [] loop->56
  0041    | MatchConst r4 1 -> 50
  0047    | Jump 47 -> 53
  0050    | JumpBack 50 -> 31
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": A, ..._}' -i 'a1b2'
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============10:object================
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
  
  ================10:pair=================
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": A, ..._}
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: object
  0008    | GetConstant 1: alpha
  0010    | GetConstant 2: digit
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 43
  0017    | MatchScrutinee r2
  0019    | MatchType r2 object -> 42
  0024    | MatchKeysMin r2 1 -> 42
  0029    | MatchKey r3 r2["a"] -> 42
  0036    | MatchBind l0 r3
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {..._, "a": A}' -i 'a1b2'
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============10:object================
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
  
  ================10:pair=================
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
  
  ================2:@main=================
  object(alpha, digit) -> {..._, "a": A}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar A
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: object
  0008    | GetConstant 1: alpha
  0010    | GetConstant 2: digit
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 43
  0017    | MatchScrutinee r2
  0019    | MatchType r2 object -> 42
  0024    | MatchKeysMin r2 1 -> 42
  0029    | MatchKey r3 r2["a"] -> 42
  0036    | MatchBind l1 r3
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {"a": _, "b": B}' -i 'a1b2'
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============10:object================
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
  
  ================10:pair=================
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": _, "b": B}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar B
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: object
  0008    | GetConstant 1: alpha
  0010    | GetConstant 2: digit
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 50
  0017    | MatchScrutinee r2
  0019    | MatchType r2 object -> 49
  0024    | MatchKeys r2 2 -> 49
  0029    | MatchKey r4 r2["a"] -> 49
  0036    | MatchKey r3 r2["b"] -> 49
  0043    | MatchBind l1 r3
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | End
  ========================================

  $ possum -p 'array(digit) -> [...A]' -i '123'
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
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
  0010    | GetLocal l0
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
  0030    | GetLocal l0
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
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 14
  0009    | MatchScrutinee r2
  0011    | MatchBind l1 r2
  0014    | TakeRight 14 -> 23
  0017    | GetConstantMutable 1: [_]
  0019    | GetLocalMove l1
  0021    | InsertAtIndex 0
  0023    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [...A]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: array
  0007    | GetConstant 1: digit
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 38
  0014    | MatchScrutinee r1
  0016    | MatchType r1 array -> 37
  0021    | MatchLenMin r1 0 -> 37
  0026    | MatchSlice r2 r1[0..^0]
  0031    | MatchBind l0 r2
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | End
  ========================================

  $ possum -p 'object(alpha, digit) -> {...O}' -i 'a1b2'
  
  ================3:alpha=================
  alpha = "a".."z" | "A".."Z"
  ========================================
  0000    | SetInputMark
  0001    | ParseCodepointRange 'a'..'z'
  0004    | Or 4 -> 10
  0007    | ParseCodepointRange 'A'..'Z'
  0010    | End
  ========================================
  
  ================6:digit=================
  digit = 0..9
  ========================================
  0000    | ParseIntegerRange 0..9
  0003    | End
  ========================================
  
  ===============10:object================
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
  
  ================10:pair=================
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
  
  ================2:@main=================
  object(alpha, digit) -> {...O}
  ========================================
  0000    | PushVar O
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: object
  0007    | GetConstant 1: alpha
  0009    | GetConstant 2: digit
  0011    | CallFunction 2
  0013    | JumpIfFailure 13 -> 35
  0016    | MatchScrutinee r1
  0018    | MatchType r1 object -> 34
  0023    | MatchObjectRest r2 r1 \ []
  0028    | MatchBind l0 r2
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | End
  ========================================

  $ possum -p '"abc" -> "%(S)"' -i 'abc'
  
  ================2:@main=================
  "abc" -> "%(S)"
  ========================================
  0000    | PushVar S
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | CallFunctionConstant 0: "abc"
  0006    | JumpIfFailure 6 -> 33
  0009    | MatchScrutinee r1
  0011    | MatchType r1 string -> 32
  0016    | MatchLenMin r1 0 -> 32
  0021    | MatchSlice r2 r1[0..^0]
  0026    | MatchBind l0 r2
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | End
  ========================================

  $ possum -p '"null" -> "%(null)"' -i 'null'
  
  ================2:@main=================
  "null" -> "%(null)"
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | CallFunctionConstant 0: "null"
  0008    | JumpIfFailure 8 -> 40
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string -> 39
  0018    | MatchStrInit r0 front=r2 end=r3
  0022    | MatchStrLit r0 cursor=r2 opp=r3 front "null" -> 39
  0031    | MatchStrCovered r2==r3 -> 39
  0036    | Jump 36 -> 40
  0039    | MatchFail
  0040    | End
  ========================================

  $ possum -p '"null" -> "%(null + N)" $ N' -i 'null'
  
  ================2:@main=================
  "null" -> "%(null + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "null"
  0004    | DestructurePlan 0: tmpl(bind N)
  0006    | TakeRight 6 -> 11
  0009    | GetLocalMove l0
  0011    | End
  ========================================

  $ possum -p '"true" -> "%(true + B)" $ B' -i 'true'
  
  ================2:@main=================
  "true" -> "%(true + B)" $ B
  ========================================
  0000    | PushVar B
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionConstant 0: "true"
  0010    | JumpIfFailure 10 -> 39
  0013    | MatchScrutinee r1
  0015    | MatchType r1 string -> 38
  0020    | MatchCastBool r5 <- r1 -> 38
  0025    | MatchMergeBool r2 r5 claim true -> 38
  0032    | MatchBind l0 r2
  0035    | Jump 35 -> 39
  0038    | MatchFail
  0039    | TakeRight 39 -> 44
  0042    | GetLocalMove l0
  0044    | End
  ========================================

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(0 + N)"
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionConstant 0: "123"
  0010    | JumpIfFailure 10 -> 32
  0013    | MatchScrutinee r1
  0015    | MatchType r1 string -> 31
  0020    | MatchCastNum r5 <- r1 -> 31
  0025    | MatchBind l0 r5
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | End
  ========================================

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(N + 1)"
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | CallFunctionConstant 0: "123"
  0010    | JumpIfFailure 10 -> 39
  0013    | MatchScrutinee r1
  0015    | MatchType r1 string -> 38
  0020    | MatchCastNum r5 <- r1 -> 38
  0025    | MatchMergeNum r2 r5 - 1 -> 38
  0032    | MatchBind l0 r2
  0035    | Jump 35 -> 39
  0038    | MatchFail
  0039    | End
  ========================================

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  
  ================2:@main=================
  "[1,2,3]" -> "%([...A])"
  ========================================
  0000    | PushVar A
  0002    | CallFunctionConstant 0: "[1,2,3]"
  0004    | DestructurePlan 0: tmpl(([] + bind A))
  0006    | End
  ========================================

  $ possum -p '`{"a": 1, "b": 2}` -> "%({..._})"' -i '{"a": 1, "b": 2}'
  
  ================2:@main=================
  `{"a": 1, "b": 2}` -> "%({..._})"
  ========================================
  0000    | PushUnderscoreVar
  0001    | CallFunctionConstant 0: "{"a": 1, "b": 2}"
  0003    | DestructurePlan 0: tmpl(({} + _))
  0005    | End
  ========================================

  $ possum -p '"abcabcabc" -> "%( `abc` * N)" $ N' -i 'abcabcabc'
  
  ================2:@main=================
  "abcabcabc" -> "%( `abc` * N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "abcabcabc"
  0004    | DestructurePlan 0: tmpl((eq "abc" * bind N))
  0006    | TakeRight 6 -> 11
  0009    | GetLocalMove l0
  0011    | End
  ========================================

  $ possum -p '"prefix123123suffix" -> "%(`prefix` + (`123` * N) + `suffix`)" $ N' -i 'prefix123123suffix'
  [UnsupportedPattern]
  [1]

  $ possum -p '"" -> ("" * N)' -i ''
  
  ================2:@main=================
  "" -> ("" * N)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushEmptyString
  0006    | JumpIfFailure 6 -> 24
  0009    | MatchScrutinee r1
  0011    | PushEmptyString
  0012    | MatchRepeatValue r1 r3 -> 23
  0017    | MatchBind l0 r3
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | End
  ========================================

  $ possum -p '"" -> "%(`` * N)"' -i ''
  
  ================2:@main=================
  "" -> "%(`` * N)"
  ========================================
  0000    | PushVar N
  0002    | PushEmptyString
  0003    | DestructurePlan 0: tmpl((eq "" * bind N))
  0005    | End
  ========================================

  $ possum -p '"" $ 0 -> (0 * N)' -i ''
  
  ================2:@main=================
  "" $ 0 -> (0 * N)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushInteger 0
  0007    | JumpIfFailure 7 -> 26
  0010    | MatchScrutinee r1
  0012    | PushInteger 0
  0014    | MatchRepeatValue r1 r3 -> 25
  0019    | MatchBind l0 r3
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | End
  ========================================

  $ possum -p 'const($true) -> (true * N)' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const($true) -> (true * N)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: const
  0007    | PushTrue
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 28
  0013    | MatchScrutinee r1
  0015    | PushTrue
  0016    | MatchRepeatValue r1 r3 -> 27
  0021    | MatchBind l0 r3
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | End
  ========================================

  $ possum -p 'const($false) -> (false * N)' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const($false) -> (false * N)
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | GetConstant 0: const
  0007    | PushFalse
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 28
  0013    | MatchScrutinee r1
  0015    | PushFalse
  0016    | MatchRepeatValue r1 r3 -> 27
  0021    | MatchBind l0 r3
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | End
  ========================================

  $ possum -p 'Double(N) = N + N; 6 -> Double(1 + 2)' -i ''
  
  ================2:Double================
  Double(N) = N + N
  ========================================
  0000    | GetLocal l0
  0002    | JumpIfFailure 2 -> 8
  0005    | GetLocalMove l0
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  6 -> Double(1 + 2)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 24
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: Double
  0011    | PushInteger 3
  0013    | CallFunction 1
  0015    | MatchEval r0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | End
  ========================================

  $ possum -p '_Inc(N) = N + 1 ; 6 -> _Inc(5)' -i '6'
  
  =================2:_Inc=================
  _Inc(N) = N + 1
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 8
  0005    | PushInteger 1
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  6 -> _Inc(5)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 24
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: _Inc
  0011    | PushInteger 5
  0013    | CallFunction 1
  0015    | MatchEval r0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | End
  ========================================

  $ possum -p 'Double(F, N) = F(N) + F(N) ; Inc(N) = N + 1 ; ("" $ 4) -> Double(Inc, 1)' -i ''
  
  ================2:Double================
  Double(F, N) = F(N) + F(N)
  ========================================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetLocalMove l0
  0011    | GetLocalMove l1
  0013    | CallFunction 1
  0015    | Merge
  0016    | End
  ========================================
  
  =================2:Inc==================
  Inc(N) = N + 1
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 8
  0005    | PushInteger 1
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  ("" $ 4) -> Double(Inc, 1)
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | PushInteger 4
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: Double
  0011    | GetConstant 1: Inc
  0013    | PushInteger 1
  0015    | CallFunction 2
  0017    | MatchEval r0 -> 25
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | End
  ========================================

  $ possum -p '"-3" -> "%(-(1..5))"' -i '-3'
  
  ================2:@main=================
  "-3" -> "%(-(1..5))"
  ========================================
  0000    | CallFunctionConstant 0: "-3"
  0002    | DestructurePlan 0: tmpl(negated eq 1..eq 5)
  0004    | End
  ========================================

  $ possum -p '"a-3" -> "a%(-(1..5))"' -i 'a-3'
  
  ================2:@main=================
  "a-3" -> "a%(-(1..5))"
  ========================================
  0000    | CallFunctionConstant 0: "a-3"
  0002    | DestructurePlan 0: tmpl(eq "a", negated eq 1..eq 5)
  0004    | End
  ========================================

  $ possum -p '-4 -> (2 * -(1..5))' -i '-4'
  
  ================2:@main=================
  -4 -> (2 * -(1..5))
  ========================================
  0000    | CallFunctionConstant 0: -4
  0002    | DestructurePlan 0: (eq 2 * negated eq 1..eq 5)
  0004    | End
  ========================================

  $ possum -p '"aa" -> ("a" * -(1..2))' -i 'aa'
  
  ================2:@main=================
  "aa" -> ("a" * -(1..2))
  ========================================
  0000    | CallFunctionConstant 0: "aa"
  0002    | DestructurePlan 0: (eq "a" * negated eq 1..eq 2)
  0004    | End
  ========================================

  $ possum -p 'Inc(A) = A + 1 ; "" $ [1, 2] -> [N, Inc(N)]' -i ''
  
  =================2:Inc==================
  Inc(A) = A + 1
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 8
  0005    | PushInteger 1
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  "" $ [1, 2] -> [N, Inc(N)]
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: [1, 2]
  0008    | JumpIfFailure 8 -> 49
  0011    | MatchScrutinee r1
  0013    | MatchType r1 array -> 48
  0018    | MatchLen r1 2 -> 48
  0023    | MatchElem r2 r1[0]
  0027    | MatchBind l0 r2
  0030    | MatchElem r3 r1[1]
  0034    | GetConstant 1: Inc
  0036    | GetLocalMove l0
  0038    | CallFunction 1
  0040    | MatchEval r3 -> 48
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | End
  ========================================

  $ possum -p 'Inc(A) = A + 1 ; "" $ [2, 1] -> [Inc(N), N]' -i ''
  
  =================2:Inc==================
  Inc(A) = A + 1
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 8
  0005    | PushInteger 1
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  "" $ [2, 1] -> [Inc(N), N]
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: [2, 1]
  0008    | JumpIfFailure 8 -> 49
  0011    | MatchScrutinee r1
  0013    | MatchType r1 array -> 48
  0018    | MatchLen r1 2 -> 48
  0023    | MatchElem r3 r1[1]
  0027    | MatchBind l0 r3
  0030    | MatchElem r2 r1[0]
  0034    | GetConstant 1: Inc
  0036    | GetLocalMove l0
  0038    | CallFunction 1
  0040    | MatchEval r2 -> 48
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | End
  ========================================

  $ possum -p 'Inc(A) = A + 1 ; 3 -> Inc(Inc(1))' -i '3'
  
  =================2:Inc==================
  Inc(A) = A + 1
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 8
  0005    | PushInteger 1
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  3 -> Inc(Inc(1))
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | ParseNumberStringChar 3
  0004    | JumpIfFailure 4 -> 28
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: Inc
  0011    | GetConstant 0: Inc
  0013    | PushInteger 1
  0015    | CallFunction 1
  0017    | CallFunction 1
  0019    | MatchEval r0 -> 27
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | End
  ========================================

  $ possum -p 'Inc(A) = A + 1 ; "" $ [1, 3] -> [N, Inc(N + 1)]' -i ''
  
  =================2:Inc==================
  Inc(A) = A + 1
  ========================================
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 8
  0005    | PushInteger 1
  0007    | Merge
  0008    | End
  ========================================
  
  ================2:@main=================
  "" $ [1, 3] -> [N, Inc(N + 1)]
  ========================================
  0000    | PushVar N
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | GetConstant 0: [1, 3]
  0008    | JumpIfFailure 8 -> 55
  0011    | MatchScrutinee r1
  0013    | MatchType r1 array -> 54
  0018    | MatchLen r1 2 -> 54
  0023    | MatchElem r2 r1[0]
  0027    | MatchBind l0 r2
  0030    | MatchElem r3 r1[1]
  0034    | GetConstant 1: Inc
  0036    | GetLocalMove l0
  0038    | JumpIfFailure 38 -> 44
  0041    | PushInteger 1
  0043    | Merge
  0044    | CallFunction 1
  0046    | MatchEval r3 -> 54
  0051    | Jump 51 -> 55
  0054    | MatchFail
  0055    | End
  ========================================
