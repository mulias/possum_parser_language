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
  0000    | GetConstant 0: const
  0002    | GetConstant 1: [1, 2, 3]
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 58
  0009    | MatchWindowEnter 5
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array -> 56
  0018    | MatchLen r0 3 -> 56
  0023    | MatchElem r1 r0[0]
  0027    | MatchConst r1 1 -> 56
  0033    | MatchElem r2 r0[1]
  0037    | MatchConst r2 2 -> 56
  0043    | MatchElem r3 r0[2]
  0047    | MatchConst r3 3 -> 56
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | MatchWindowExit
  0058    | End
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
  0006    | GetConstant 0: const
  0008    | GetConstant 1: [1, 2, 3]
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 55
  0015    | MatchWindowEnter 5
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array -> 53
  0024    | MatchLen r0 3 -> 53
  0029    | MatchElem r1 r0[0]
  0033    | MatchBind l0 r1
  0036    | MatchElem r2 r0[1]
  0040    | MatchBind l1 r2
  0043    | MatchElem r3 r0[2]
  0047    | MatchBind l2 r3
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
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
  0004    | GetConstant 0: const
  0006    | GetConstant 1: [1, 2, 3]
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 56
  0013    | MatchWindowEnter 5
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 54
  0022    | MatchLen r0 3 -> 54
  0027    | MatchElem r1 r0[0]
  0031    | MatchGlobal r1 1 -> 54
  0037    | MatchElem r2 r0[1]
  0041    | MatchBind l0 r2
  0044    | MatchElem r3 r0[2]
  0048    | MatchBind l1 r3
  0051    | Jump 51 -> 55
  0054    | MatchFail
  0055    | MatchWindowExit
  0056    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 2, 3]
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 57
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 55
  0020    | MatchLen r0 3 -> 55
  0025    | MatchElem r1 r0[0]
  0029    | MatchBind l0 r1
  0032    | MatchElem r2 r0[1]
  0036    | MatchConst r2 2 -> 55
  0042    | MatchElem r3 r0[2]
  0046    | MatchConst r3 3 -> 55
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0004    | GetConstant 0: const
  0006    | GetConstantMutable 1: [1, _]
  0008    | GetConstantMutable 2: [_, 3]
  0010    | GetConstant 3: [2]
  0012    | InsertAtIndex 0
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | JumpIfFailure 18 -> 92
  0021    | MatchWindowEnter 7
  0023    | MatchScrutinee r0
  0025    | MatchType r0 array -> 90
  0030    | MatchLen r0 2 -> 90
  0035    | MatchElem r1 r0[0]
  0039    | MatchBind l0 r1
  0042    | MatchElem r2 r0[1]
  0046    | MatchType r2 array -> 90
  0051    | MatchLen r2 2 -> 90
  0056    | MatchElem r3 r2[0]
  0060    | MatchType r3 array -> 90
  0065    | MatchLen r3 1 -> 90
  0070    | MatchElem r4 r3[0]
  0074    | MatchBind l1 r4
  0077    | MatchElem r5 r2[1]
  0081    | MatchConst r5 3 -> 90
  0087    | Jump 87 -> 91
  0090    | MatchFail
  0091    | MatchWindowExit
  0092    | TakeRight 92 -> 97
  0095    | GetLocalMove l1
  0097    | End
  ========================================

  $ possum -p '3 -> (2 + B)' -i '3'
  
  ================2:@main=================
  3 -> (2 + B)
  ========================================
  0000    | PushVar B
  0002    | ParseNumberStringChar 3
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 2 -> 24
  0018    | MatchBind l0 r1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 2, 3]
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 57
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 55
  0020    | MatchLen r0 3 -> 55
  0025    | MatchElem r1 r0[0]
  0029    | MatchBind l0 r1
  0032    | MatchElem r2 r0[1]
  0036    | MatchConst r2 2 -> 55
  0042    | MatchElem r3 r0[2]
  0046    | MatchConst r3 3 -> 55
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstantMutable 1: [1, _, 3]
  0006    | GetConstant 2: @Add
  0008    | PushInteger 1
  0010    | PushInteger 2
  0012    | CallFunction 2
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | JumpIfFailure 18 -> 74
  0021    | MatchWindowEnter 5
  0023    | MatchScrutinee r0
  0025    | MatchType r0 array -> 72
  0030    | MatchLen r0 3 -> 72
  0035    | MatchElem r1 r0[0]
  0039    | MatchBind l0 r1
  0042    | MatchElem r2 r0[1]
  0046    | GetConstant 2: @Add
  0048    | PushInteger 1
  0050    | PushInteger 1
  0052    | CallFunction 2
  0054    | MatchEval r2 -> 72
  0059    | MatchElem r3 r0[2]
  0063    | MatchConst r3 3 -> 72
  0069    | Jump 69 -> 73
  0072    | MatchFail
  0073    | MatchWindowExit
  0074    | End
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
  0000    | GetConstant 0: const
  0002    | GetConstant 1: [1, 2]
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 48
  0009    | MatchWindowEnter 4
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array -> 46
  0018    | MatchLen r0 2 -> 46
  0023    | MatchElem r1 r0[0]
  0027    | MatchConst r1 1 -> 46
  0033    | MatchElem r2 r0[1]
  0037    | MatchConst r2 2 -> 46
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 2, 3]
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 58
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 56
  0020    | MatchLenMin r0 2 -> 56
  0025    | MatchElem r1 r0[0]
  0029    | MatchConst r1 1 -> 56
  0035    | MatchSlice r2 r0[1..^1]
  0040    | MatchBind l0 r2
  0043    | MatchElemBack r3 r0[^0]
  0047    | MatchConst r3 3 -> 56
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | MatchWindowExit
  0058    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstantMutable 1: [1, _, 2, 3]
  0006    | GetConstant 2: [2]
  0008    | InsertAtIndex 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 71
  0015    | MatchWindowEnter 6
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array -> 69
  0024    | MatchLenMin r0 3 -> 69
  0029    | MatchElem r1 r0[0]
  0033    | MatchConst r1 1 -> 69
  0039    | MatchElem r2 r0[1]
  0043    | MatchBind l0 r2
  0046    | MatchSlice r3 r0[2..^1]
  0051    | MatchSlot r3 l0 -> 69
  0056    | MatchElemBack r4 r0[^0]
  0060    | MatchConst r4 3 -> 69
  0066    | Jump 66 -> 70
  0069    | MatchFail
  0070    | MatchWindowExit
  0071    | End
  ========================================

  $ possum -p '"foobar" -> ("fo" + Ob + "ar") $ Ob' -i ''
  
  ================2:@main=================
  "foobar" -> ("fo" + Ob + "ar") $ Ob
  ========================================
  0000    | PushVar Ob
  0002    | CallFunctionConstant 0: "foobar"
  0004    | JumpIfFailure 4 -> 46
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 44
  0016    | MatchLenMin r0 4 -> 44
  0021    | MatchStrPrefix r0 "fo" -> 44
  0027    | MatchStrSuffix r0 "ar" -> 44
  0033    | MatchSlice r1 r0[2..^2]
  0038    | MatchBind l0 r1
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: [1, 2, 3]
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 48
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 46
  0020    | MatchLenMin r0 1 -> 46
  0025    | MatchElem r1 r0[0]
  0029    | MatchConst r1 1 -> 46
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l0 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | TakeRight 48 -> 53
  0051    | GetLocalMove l0
  0053    | End
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
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {"a": 1, "b": 2}
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 54
  0009    | MatchWindowEnter 4
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object -> 52
  0018    | MatchKeys r0 2 -> 52
  0023    | MatchKey r1 r0["a"] -> 52
  0030    | MatchConst r1 1 -> 52
  0036    | MatchKey r2 r0["b"] -> 52
  0043    | MatchConst r2 2 -> 52
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | End
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
  0004    | GetConstant 0: const
  0006    | GetConstant 1: {"a": 1, "b": 2}
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 52
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 50
  0022    | MatchKeys r0 2 -> 50
  0027    | MatchKey r1 r0["a"] -> 50
  0034    | MatchBind l0 r1
  0037    | MatchKey r2 r0["b"] -> 50
  0044    | MatchBind l1 r2
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | End
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
  0001    | GetConstant 0: const
  0003    | GetConstant 1: {"a": 1, "b": 2}
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 43
  0010    | MatchWindowEnter 2
  0012    | MatchScrutinee r0
  0014    | MatchType r0 object -> 41
  0019    | MatchKeys r0 2 -> 41
  0024    | MatchKey r1 r0["a"] -> 41
  0031    | MatchKey r1 r0["b"] -> 41
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | MatchWindowExit
  0043    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 51
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 49
  0020    | MatchKeysMin r0 1 -> 49
  0025    | MatchKey r1 r0["a"] -> 49
  0032    | MatchConst r1 1 -> 49
  0038    | MatchObjectRest r2 r0 \ ["a"]
  0043    | MatchBind l0 r2
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 51
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 49
  0020    | MatchKeysMin r0 1 -> 49
  0025    | MatchKey r1 r0["b"] -> 49
  0032    | MatchConst r1 2 -> 49
  0038    | MatchObjectRest r2 r0 \ ["b"]
  0043    | MatchBind l0 r2
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 51
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 49
  0020    | MatchKeysMin r0 1 -> 49
  0025    | MatchObjectRest r1 r0 \ ["b"]
  0030    | MatchBind l0 r1
  0033    | MatchKey r2 r0["b"] -> 49
  0040    | MatchConst r2 2 -> 49
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | End
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
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2}
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 51
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 49
  0020    | MatchKeysMin r0 1 -> 49
  0025    | MatchKey r1 r0["a"] -> 49
  0032    | MatchConst r1 1 -> 49
  0038    | MatchObjectRest r2 r0 \ ["a"]
  0043    | MatchBind l0 r2
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  ================2:@main=================
  2 -> 0..5
  ========================================
  0000    | ParseNumberStringChar 2
  0002    | JumpIfFailure 2 -> 24
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 0..5 -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | MatchWindowExit
  0024    | End
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
  0000    | CallFunctionConstant 0: char
  0002    | JumpIfFailure 2 -> 24
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 "a".."z" -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | MatchWindowExit
  0024    | End
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
  0000    | CallFunctionConstant 0: char
  0002    | JumpIfFailure 2 -> 24
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 .."z" -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | MatchWindowExit
  0024    | End
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
  0001    | GetLocalMove l0
  0003    | JumpIfFailure 3 -> 25
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 array -> 23
  0015    | MatchLenMin r0 0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
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
  0007    | SetInputMark
  0008    | GetLocalMove l0
  0010    | JumpIfFailure 10 -> 47
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 45
  0022    | MatchLenMin r0 1 -> 45
  0027    | MatchElem r1 r0[0]
  0031    | MatchBind l2 r1
  0034    | MatchSlice r2 r0[1..^0]
  0039    | MatchBind l3 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | ConditionalThen 47 -> 134
  0050    | SetInputMark
  0051    | GetLocalMove l2
  0053    | JumpIfFailure 53 -> 83
  0056    | MatchWindowEnter 3
  0058    | MatchScrutinee r0
  0060    | MatchType r0 array -> 81
  0065    | MatchLenMin r0 1 -> 81
  0070    | MatchSlice r1 r0[1..^0]
  0075    | MatchBind l5 r1
  0078    | Jump 78 -> 82
  0081    | MatchFail
  0082    | MatchWindowExit
  0083    | ConditionalThen 83 -> 112
  0086    | GetConstant 0: __Table.RestPerRow
  0088    | GetLocalMove l3
  0090    | PushEmptyArray
  0091    | JumpIfFailure 91 -> 97
  0094    | GetLocalMove l1
  0096    | Merge
  0097    | JumpIfFailure 97 -> 107
  0100    | GetConstantMutable 1: [_]
  0102    | GetLocalMove l5
  0104    | InsertAtIndex 0
  0106    | Merge
  0107    | CallTailFunction 2
  0109    | Jump 109 -> 131
  0112    | GetConstant 0: __Table.RestPerRow
  0114    | GetLocalMove l3
  0116    | PushEmptyArray
  0117    | JumpIfFailure 117 -> 123
  0120    | GetLocalMove l1
  0122    | Merge
  0123    | JumpIfFailure 123 -> 129
  0126    | GetConstant 2: [[]]
  0128    | Merge
  0129    | CallTailFunction 2
  0131    | Jump 131 -> 136
  0134    | GetLocalMove l1
  0136    | End
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
  0003    | GetLocalMove l0
  0005    | JumpIfFailure 5 -> 40
  0008    | MatchWindowEnter 5
  0010    | MatchScrutinee r0
  0012    | MatchType r0 object -> 38
  0017    | MatchKeysMin r0 1 -> 38
  0022    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 38
  0032    | MatchBind l2 r3
  0035    | Jump 35 -> 39
  0038    | MatchFail
  0039    | MatchWindowExit
  0040    | TakeRight 40 -> 45
  0043    | GetLocalMove l2
  0045    | End
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
  0000    | ParseNumberStringChar 4
  0002    | JumpIfFailure 2 -> 20
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 4 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | End
  ========================================

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 + 3)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 20
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 5 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | End
  ========================================

  $ possum -p '5 -> (2 + X + 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 + X + 3)
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 5
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 5 -> 24
  0018    | MatchBind l0 r1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | End
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
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 4 -> 24
  0018    | MatchBind l0 r1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 31
  0029    | GetLocalMove l0
  0031    | End
  ========================================

  $ possum -p '5 -> (2 - 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 - 3)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 20
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 -1 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | End
  ========================================

  $ possum -p '6 -> (1 + X - 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 + X - 3) $ X
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - -2 -> 24
  0018    | MatchBind l0 r1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 31
  0029    | GetLocalMove l0
  0031    | End
  ========================================

  $ possum -p '6 -> (1 - X + 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 - X + 3) $ X
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNumNeg r1 r0 - 4 -> 24
  0018    | MatchBind l0 r1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 31
  0029    | GetLocalMove l0
  0031    | End
  ========================================

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  
  ================2:@main=================
  5 -> (1 + 6 + 3 - (2 + 3))
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 20
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 5 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | End
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
  0000    | ParseChar '1'
  0002    | JumpIfFailure 2 -> 37
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 35
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "1" -> 35
  0027    | MatchStrCovered r2==r3 -> 35
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | End
  ========================================

  $ possum -p '"2" -> "%(1 + 1)"' -i '2'
  
  ================2:@main=================
  "2" -> "%(1 + 1)"
  ========================================
  0000    | ParseChar '2'
  0002    | JumpIfFailure 2 -> 37
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 35
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "2" -> 35
  0027    | MatchStrCovered r2==r3 -> 35
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | End
  ========================================

  $ possum -p '"50" -> "%(0 + N)" $ N' -i '50'
  
  ================2:@main=================
  "50" -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "50"
  0004    | JumpIfFailure 4 -> 29
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 27
  0016    | MatchCastNum r4 <- r0 -> 27
  0021    | MatchBind l0 r4
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l0
  0034    | End
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
  0002    | CallFunctionConstant 0: 123
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l0 r0
  0014    | MatchWindowExit
  0015    | End
  ========================================

  $ possum -p '"abc" -> "abc"' -i 'abc'
  
  ================2:@main=================
  "abc" -> "abc"
  ========================================
  0000    | CallFunctionConstant 0: "abc"
  0002    | JumpIfFailure 2 -> 20
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 "abc" -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | End
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
  0000    | GetConstant 0: many
  0002    | GetConstant 1: char
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 24
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchConst r0 "\nfoo" -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | MatchWindowExit
  0024    | End
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
  0001    | GetConstant 0: many
  0003    | GetConstant 1: char
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 6
  0012    | MatchScrutinee r0
  0014    | MatchType r0 string -> 44
  0019    | MatchStrInit r0 front=r2 end=r3
  0023    | MatchStrChar r5 r0 cursor=r2 opp=r3 front -> 44
  0031    | MatchInRange r5 "a".."z" -> 44
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | End
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
  0000    | CallFunctionConstant 0: numerals
  0002    | JumpIfFailure 2 -> 27
  0005    | MatchWindowEnter 3
  0007    | MatchScrutinee r0
  0009    | PushString "3"
  0011    | MatchRepeatValue r0 r2 -> 25
  0016    | MatchConst r2 10 -> 25
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
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
  0000    | GetConstant 0: many
  0002    | GetConstant 1: char
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 35
  0009    | MatchWindowEnter 3
  0011    | MatchScrutinee r0
  0013    | MatchRepeatRange r0 r2 _0_.. -> 33
  0024    | MatchConst r2 10 -> 33
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
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
  0000    | GetConstant 0: boolean
  0002    | PushNumberStringOne
  0003    | PushNumberStringZero
  0004    | CallFunction 2
  0006    | JumpIfFailure 6 -> 24
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchConst r0 true -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | MatchWindowExit
  0024    | End
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
  int -> 5
  ========================================
  0000    | CallFunctionConstant 0: integer
  0002    | JumpIfFailure 2 -> 20
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchConst r0 5 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | End
  ========================================

  $ possum -p '5 -> 2..7' -i '5'
  
  ================2:@main=================
  5 -> 2..7
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 24
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchInRange r0 2..7 -> 22
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | MatchWindowExit
  0024    | End
  ========================================

  $ possum -p '8 -> (0 + N)' -i '8'
  
  ================2:@main=================
  8 -> (0 + N)
  ========================================
  0000    | PushVar N
  0002    | ParseNumberStringChar 8
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 0 -> 24
  0018    | MatchBind l0 r1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | End
  ========================================

  $ possum -p '8 -> (N + 100)' -i '8'
  
  ================2:@main=================
  8 -> (N + 100)
  ========================================
  0000    | PushVar N
  0002    | ParseNumberStringChar 8
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 100 -> 24
  0018    | MatchBind l0 r1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | End
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [1, 2, 3]
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: digit
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 58
  0009    | MatchWindowEnter 5
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array -> 56
  0018    | MatchLen r0 3 -> 56
  0023    | MatchElem r1 r0[0]
  0027    | MatchConst r1 1 -> 56
  0033    | MatchElem r2 r0[1]
  0037    | MatchConst r2 2 -> 56
  0043    | MatchElem r3 r0[2]
  0047    | MatchConst r3 3 -> 56
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | MatchWindowExit
  0058    | End
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [A, ..._]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: array
  0005    | GetConstant 1: digit
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 38
  0012    | MatchWindowEnter 3
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 36
  0021    | MatchLenMin r0 1 -> 36
  0026    | MatchElem r1 r0[0]
  0030    | MatchBind l0 r1
  0033    | Jump 33 -> 37
  0036    | MatchFail
  0037    | MatchWindowExit
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([1] * 5)
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: digit
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 114
  0009    | MatchWindowEnter 5
  0011    | MatchScrutinee r0
  0013    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 112
  0020    | MatchConst r2 5 -> 112
  0026    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->109
  0033    | MatchWindowEnter 3
  0035    | MatchSubScrutinee r0 ^r4
  0038    | MatchType r0 array -> 61
  0043    | MatchLen r0 1 -> 61
  0048    | MatchElem r1 r0[0]
  0052    | MatchConst r1 1 -> 61
  0058    | Jump 58 -> 65
  0061    | MatchWindowExit
  0062    | Jump 62 -> 112
  0065    | MatchWindowExit
  0066    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->109
  0073    | MatchWindowEnter 3
  0075    | MatchSubScrutinee r0 ^r4
  0078    | MatchType r0 array -> 101
  0083    | MatchLen r0 1 -> 101
  0088    | MatchElem r1 r0[0]
  0092    | MatchConst r1 1 -> 101
  0098    | Jump 98 -> 105
  0101    | MatchWindowExit
  0102    | Jump 102 -> 112
  0105    | MatchWindowExit
  0106    | JumpBack 106 -> 66
  0109    | Jump 109 -> 113
  0112    | MatchFail
  0113    | MatchWindowExit
  0114    | End
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([A] * 5)
  ========================================
  0000    | PushVar A
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 112
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 110
  0022    | MatchConst r2 5 -> 110
  0028    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->107
  0035    | MatchWindowEnter 3
  0037    | MatchSubScrutinee r0 ^r4
  0040    | MatchType r0 array -> 60
  0045    | MatchLen r0 1 -> 60
  0050    | MatchElem r1 r0[0]
  0054    | MatchBind l0 r1
  0057    | Jump 57 -> 64
  0060    | MatchWindowExit
  0061    | Jump 61 -> 110
  0064    | MatchWindowExit
  0065    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->107
  0072    | MatchWindowEnter 3
  0074    | MatchSubScrutinee r0 ^r4
  0077    | MatchType r0 array -> 99
  0082    | MatchLen r0 1 -> 99
  0087    | MatchElem r1 r0[0]
  0091    | MatchSlot r1 l0 -> 99
  0096    | Jump 96 -> 103
  0099    | MatchWindowExit
  0100    | Jump 100 -> 110
  0103    | MatchWindowExit
  0104    | JumpBack 104 -> 65
  0107    | Jump 107 -> 111
  0110    | MatchFail
  0111    | MatchWindowExit
  0112    | End
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([1] * N) $ N
  ========================================
  0000    | PushVar N
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 113
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 111
  0022    | MatchBind l0 r2
  0025    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->108
  0032    | MatchWindowEnter 3
  0034    | MatchSubScrutinee r0 ^r4
  0037    | MatchType r0 array -> 60
  0042    | MatchLen r0 1 -> 60
  0047    | MatchElem r1 r0[0]
  0051    | MatchConst r1 1 -> 60
  0057    | Jump 57 -> 64
  0060    | MatchWindowExit
  0061    | Jump 61 -> 111
  0064    | MatchWindowExit
  0065    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->108
  0072    | MatchWindowEnter 3
  0074    | MatchSubScrutinee r0 ^r4
  0077    | MatchType r0 array -> 100
  0082    | MatchLen r0 1 -> 100
  0087    | MatchElem r1 r0[0]
  0091    | MatchConst r1 1 -> 100
  0097    | Jump 97 -> 104
  0100    | MatchWindowExit
  0101    | Jump 101 -> 111
  0104    | MatchWindowExit
  0105    | JumpBack 105 -> 65
  0108    | Jump 108 -> 112
  0111    | MatchFail
  0112    | MatchWindowExit
  0113    | TakeRight 113 -> 118
  0116    | GetLocalMove l0
  0118    | End
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [A, ..._, Z]
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | PushVar Z
  0005    | GetConstant 0: array
  0007    | GetConstant 1: digit
  0009    | CallFunction 1
  0011    | JumpIfFailure 11 -> 47
  0014    | MatchWindowEnter 4
  0016    | MatchScrutinee r0
  0018    | MatchType r0 array -> 45
  0023    | MatchLenMin r0 2 -> 45
  0028    | MatchElem r1 r0[0]
  0032    | MatchBind l0 r1
  0035    | MatchElemBack r2 r0[^0]
  0039    | MatchBind l2 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [1, B, _]
  ========================================
  0000    | PushVar B
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: array
  0005    | GetConstant 1: digit
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 48
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 46
  0021    | MatchLen r0 3 -> 46
  0026    | MatchElem r1 r0[0]
  0030    | MatchConst r1 1 -> 46
  0036    | MatchElem r2 r0[1]
  0040    | MatchBind l0 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | End
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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 44
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 44
  0036    | GetConstantMutable 1: {_0_}
  0038    | GetLocalMove l2
  0040    | GetLocalMove l3
  0042    | InsertKeyVal 0
  0044    | End
  ========================================
  
  ================2:@main=================
  object(alpha, digit) -> {"a": 1, "b": 2}
  ========================================
  0000    | GetConstant 0: object
  0002    | GetConstant 1: alpha
  0004    | GetConstant 2: digit
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 56
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 54
  0020    | MatchKeys r0 2 -> 54
  0025    | MatchKey r1 r0["a"] -> 54
  0032    | MatchConst r1 1 -> 54
  0038    | MatchKey r2 r0["b"] -> 54
  0045    | MatchConst r2 2 -> 54
  0051    | Jump 51 -> 55
  0054    | MatchFail
  0055    | MatchWindowExit
  0056    | End
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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 44
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 44
  0036    | GetConstantMutable 1: {_0_}
  0038    | GetLocalMove l2
  0040    | GetLocalMove l3
  0042    | InsertKeyVal 0
  0044    | End
  ========================================
  
  ================2:@main=================
  object(alpha, digit) -> {"a": 1, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 0: object
  0003    | GetConstant 1: alpha
  0005    | GetConstant 2: digit
  0007    | CallFunction 2
  0009    | JumpIfFailure 9 -> 44
  0012    | MatchWindowEnter 3
  0014    | MatchScrutinee r0
  0016    | MatchType r0 object -> 42
  0021    | MatchKeysMin r0 1 -> 42
  0026    | MatchKey r1 r0["a"] -> 42
  0033    | MatchConst r1 1 -> 42
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 44
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 44
  0036    | GetConstantMutable 1: {_0_}
  0038    | GetLocalMove l2
  0040    | GetLocalMove l3
  0042    | InsertKeyVal 0
  0044    | End
  ========================================
  
  ================2:@main=================
  object(alpha, digit) -> {_: 1, ..._}
  ========================================
  0000    | PushUnderscoreVar
  0001    | GetConstant 0: object
  0003    | GetConstant 1: alpha
  0005    | GetConstant 2: digit
  0007    | CallFunction 2
  0009    | JumpIfFailure 9 -> 55
  0012    | MatchWindowEnter 5
  0014    | MatchScrutinee r0
  0016    | MatchType r0 object -> 53
  0021    | MatchKeysMin r0 1 -> 53
  0026    | MatchSearchInit r4
  0028    | MatchNextUnclaimed key=r2 val=r3 src=r0 cursor=r4 keys=r2..r2 \ [] loop->53
  0038    | MatchConst r3 1 -> 47
  0044    | Jump 44 -> 50
  0047    | JumpBack 47 -> 28
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 44
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 44
  0036    | GetConstantMutable 1: {_0_}
  0038    | GetLocalMove l2
  0040    | GetLocalMove l3
  0042    | InsertKeyVal 0
  0044    | End
  ========================================
  
  ================2:@main=================
  object(alpha, digit) -> {"a": A, ..._}
  ========================================
  0000    | PushVar A
  0002    | PushUnderscoreVar
  0003    | GetConstant 0: object
  0005    | GetConstant 1: alpha
  0007    | GetConstant 2: digit
  0009    | CallFunction 2
  0011    | JumpIfFailure 11 -> 43
  0014    | MatchWindowEnter 3
  0016    | MatchScrutinee r0
  0018    | MatchType r0 object -> 41
  0023    | MatchKeysMin r0 1 -> 41
  0028    | MatchKey r1 r0["a"] -> 41
  0035    | MatchBind l0 r1
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | MatchWindowExit
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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 44
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 44
  0036    | GetConstantMutable 1: {_0_}
  0038    | GetLocalMove l2
  0040    | GetLocalMove l3
  0042    | InsertKeyVal 0
  0044    | End
  ========================================
  
  ================2:@main=================
  object(alpha, digit) -> {..._, "a": A}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar A
  0003    | GetConstant 0: object
  0005    | GetConstant 1: alpha
  0007    | GetConstant 2: digit
  0009    | CallFunction 2
  0011    | JumpIfFailure 11 -> 43
  0014    | MatchWindowEnter 3
  0016    | MatchScrutinee r0
  0018    | MatchType r0 object -> 41
  0023    | MatchKeysMin r0 1 -> 41
  0028    | MatchKey r1 r0["a"] -> 41
  0035    | MatchBind l1 r1
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | MatchWindowExit
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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 44
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 44
  0036    | GetConstantMutable 1: {_0_}
  0038    | GetLocalMove l2
  0040    | GetLocalMove l3
  0042    | InsertKeyVal 0
  0044    | End
  ========================================
  
  ================2:@main=================
  object(alpha, digit) -> {"a": _, "b": B}
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar B
  0003    | GetConstant 0: object
  0005    | GetConstant 1: alpha
  0007    | GetConstant 2: digit
  0009    | CallFunction 2
  0011    | JumpIfFailure 11 -> 50
  0014    | MatchWindowEnter 3
  0016    | MatchScrutinee r0
  0018    | MatchType r0 object -> 48
  0023    | MatchKeys r0 2 -> 48
  0028    | MatchKey r2 r0["a"] -> 48
  0035    | MatchKey r1 r0["b"] -> 48
  0042    | MatchBind l1 r1
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
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
  0002    | CallFunctionLocal l0
  0004    | JumpIfFailure 4 -> 15
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchBind l1 r0
  0014    | MatchWindowExit
  0015    | TakeRight 15 -> 24
  0018    | GetConstantMutable 1: [_]
  0020    | GetLocalMove l1
  0022    | InsertAtIndex 0
  0024    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [...A]
  ========================================
  0000    | PushVar A
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 38
  0011    | MatchWindowEnter 3
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 36
  0020    | MatchLenMin r0 0 -> 36
  0025    | MatchSlice r1 r0[0..^0]
  0030    | MatchBind l0 r1
  0033    | Jump 33 -> 37
  0036    | MatchFail
  0037    | MatchWindowExit
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
  0004    | CallFunctionLocal l0
  0006    | JumpIfFailure 6 -> 17
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchBind l2 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 44
  0020    | CallFunctionLocal l1
  0022    | JumpIfFailure 22 -> 33
  0025    | MatchWindowEnter 2
  0027    | MatchScrutinee r0
  0029    | MatchBind l3 r0
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 44
  0036    | GetConstantMutable 1: {_0_}
  0038    | GetLocalMove l2
  0040    | GetLocalMove l3
  0042    | InsertKeyVal 0
  0044    | End
  ========================================
  
  ================2:@main=================
  object(alpha, digit) -> {...O}
  ========================================
  0000    | PushVar O
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 35
  0013    | MatchWindowEnter 3
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 33
  0022    | MatchObjectRest r1 r0 \ []
  0027    | MatchBind l0 r1
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================

  $ possum -p '"abc" -> "%(S)"' -i 'abc'
  
  ================2:@main=================
  "abc" -> "%(S)"
  ========================================
  0000    | PushVar S
  0002    | CallFunctionConstant 0: "abc"
  0004    | JumpIfFailure 4 -> 34
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 32
  0016    | MatchLenMin r0 0 -> 32
  0021    | MatchSlice r1 r0[0..^0]
  0026    | MatchBind l0 r1
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | MatchWindowExit
  0034    | End
  ========================================

  $ possum -p '"null" -> "%(null)"' -i 'null'
  
  ================2:@main=================
  "null" -> "%(null)"
  ========================================
  0000    | CallFunctionConstant 0: "null"
  0002    | JumpIfFailure 2 -> 37
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 35
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "null" -> 35
  0027    | MatchStrCovered r2==r3 -> 35
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | End
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
  0002    | CallFunctionConstant 0: "true"
  0004    | JumpIfFailure 4 -> 36
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 34
  0016    | MatchCastBool r4 <- r0 -> 34
  0021    | MatchMergeBool r1 r4 claim true -> 34
  0028    | MatchBind l0 r1
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | MatchWindowExit
  0036    | TakeRight 36 -> 41
  0039    | GetLocalMove l0
  0041    | End
  ========================================

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(0 + N)"
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | JumpIfFailure 4 -> 29
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 27
  0016    | MatchCastNum r4 <- r0 -> 27
  0021    | MatchBind l0 r4
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | End
  ========================================

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(N + 1)"
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | JumpIfFailure 4 -> 36
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 34
  0016    | MatchCastNum r4 <- r0 -> 34
  0021    | MatchMergeNum r1 r4 - 1 -> 34
  0028    | MatchBind l0 r1
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | MatchWindowExit
  0036    | End
  ========================================

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  
  ================2:@main=================
  "[1,2,3]" -> "%([...A])"
  ========================================
  0000    | PushVar A
  0002    | CallFunctionConstant 0: "[1,2,3]"
  0004    | JumpIfFailure 4 -> 57
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 55
  0016    | MatchCastJson r4 <- r0 -> 55
  0021    | MatchWindowEnter 3
  0023    | MatchSubScrutinee r0 ^r4
  0026    | MatchType r0 array -> 47
  0031    | MatchLenMin r0 0 -> 47
  0036    | MatchSlice r1 r0[0..^0]
  0041    | MatchBind l0 r1
  0044    | Jump 44 -> 51
  0047    | MatchWindowExit
  0048    | Jump 48 -> 55
  0051    | MatchWindowExit
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
  ========================================

  $ possum -p '`{"a": 1, "b": 2}` -> "%({..._})"' -i '{"a": 1, "b": 2}'
  
  ================2:@main=================
  `{"a": 1, "b": 2}` -> "%({..._})"
  ========================================
  0000    | PushUnderscoreVar
  0001    | CallFunctionConstant 0: "{"a": 1, "b": 2}"
  0003    | JumpIfFailure 3 -> 43
  0006    | MatchWindowEnter 6
  0008    | MatchScrutinee r0
  0010    | MatchType r0 string -> 41
  0015    | MatchCastJson r4 <- r0 -> 41
  0020    | MatchWindowEnter 2
  0022    | MatchSubScrutinee r0 ^r4
  0025    | MatchType r0 object -> 33
  0030    | Jump 30 -> 37
  0033    | MatchWindowExit
  0034    | Jump 34 -> 41
  0037    | MatchWindowExit
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | MatchWindowExit
  0043    | End
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
  0002    | PushEmptyString
  0003    | JumpIfFailure 3 -> 24
  0006    | MatchWindowEnter 3
  0008    | MatchScrutinee r0
  0010    | PushEmptyString
  0011    | MatchRepeatValue r0 r2 -> 22
  0016    | MatchBind l0 r2
  0019    | Jump 19 -> 23
  0022    | MatchFail
  0023    | MatchWindowExit
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
  0002    | PushInteger 0
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | PushInteger 0
  0013    | MatchRepeatValue r0 r2 -> 24
  0018    | MatchBind l0 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
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
  0002    | GetConstant 0: const
  0004    | PushTrue
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 28
  0010    | MatchWindowEnter 3
  0012    | MatchScrutinee r0
  0014    | PushTrue
  0015    | MatchRepeatValue r0 r2 -> 26
  0020    | MatchBind l0 r2
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
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
  0002    | GetConstant 0: const
  0004    | PushFalse
  0005    | CallFunction 1
  0007    | JumpIfFailure 7 -> 28
  0010    | MatchWindowEnter 3
  0012    | MatchScrutinee r0
  0014    | PushFalse
  0015    | MatchRepeatValue r0 r2 -> 26
  0020    | MatchBind l0 r2
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
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
  0000    | ParseNumberStringChar 6
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: Double
  0011    | PushInteger 3
  0013    | CallFunction 1
  0015    | MatchEval r0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
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
  0000    | ParseNumberStringChar 6
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: _Inc
  0011    | PushInteger 5
  0013    | CallFunction 1
  0015    | MatchEval r0 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
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
  0000    | PushInteger 4
  0002    | JumpIfFailure 2 -> 27
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: Double
  0011    | GetConstant 1: Inc
  0013    | PushInteger 1
  0015    | CallFunction 2
  0017    | MatchEval r0 -> 25
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
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
  0002    | GetConstant 0: [1, 2]
  0004    | JumpIfFailure 4 -> 48
  0007    | MatchWindowEnter 4
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 46
  0016    | MatchLen r0 2 -> 46
  0021    | MatchElem r1 r0[0]
  0025    | MatchBind l0 r1
  0028    | MatchElem r2 r0[1]
  0032    | GetConstant 1: Inc
  0034    | GetLocalMove l0
  0036    | CallFunction 1
  0038    | MatchEval r2 -> 46
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | End
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
  0002    | GetConstant 0: [2, 1]
  0004    | JumpIfFailure 4 -> 48
  0007    | MatchWindowEnter 4
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 46
  0016    | MatchLen r0 2 -> 46
  0021    | MatchElem r2 r0[1]
  0025    | MatchBind l0 r2
  0028    | MatchElem r1 r0[0]
  0032    | GetConstant 1: Inc
  0034    | GetLocalMove l0
  0036    | CallFunction 1
  0038    | MatchEval r1 -> 46
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | End
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
  0000    | ParseNumberStringChar 3
  0002    | JumpIfFailure 2 -> 29
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | GetConstant 0: Inc
  0011    | GetConstant 0: Inc
  0013    | PushInteger 1
  0015    | CallFunction 1
  0017    | CallFunction 1
  0019    | MatchEval r0 -> 27
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | End
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
  0002    | GetConstant 0: [1, 3]
  0004    | JumpIfFailure 4 -> 54
  0007    | MatchWindowEnter 4
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 52
  0016    | MatchLen r0 2 -> 52
  0021    | MatchElem r1 r0[0]
  0025    | MatchBind l0 r1
  0028    | MatchElem r2 r0[1]
  0032    | GetConstant 1: Inc
  0034    | GetLocalMove l0
  0036    | JumpIfFailure 36 -> 42
  0039    | PushInteger 1
  0041    | Merge
  0042    | CallFunction 1
  0044    | MatchEval r2 -> 52
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | End
  ========================================

  $ possum -p '"" $ {"pt": [3, 4]} -> {K: [X, Y]} $ [K, X, Y]' -i ''
  
  ================2:@main=================
  "" $ {"pt": [3, 4]} -> {K: [X, Y]} $ [K, X, Y]
  ========================================
  0000    | PushVar K
  0002    | PushVar X
  0004    | PushVar Y
  0006    | GetConstantMutable 0: {_0_}
  0008    | PushString "pt"
  0010    | GetConstant 1: [3, 4]
  0012    | InsertKeyVal 0
  0014    | JumpIfFailure 14 -> 88
  0017    | MatchWindowEnter 5
  0019    | MatchScrutinee r0
  0021    | MatchType r0 object -> 86
  0026    | MatchKeys r0 1 -> 86
  0031    | MatchSearchInit r4
  0033    | MatchNextUnclaimed key=r2 val=r3 src=r0 cursor=r4 keys=r2..r2 \ [] loop->86
  0043    | MatchWindowEnter 4
  0045    | MatchSubScrutinee r0 ^r3
  0048    | MatchType r0 array -> 75
  0053    | MatchLen r0 2 -> 75
  0058    | MatchElem r1 r0[0]
  0062    | MatchBind l1 r1
  0065    | MatchElem r2 r0[1]
  0069    | MatchBind l2 r2
  0072    | Jump 72 -> 79
  0075    | MatchWindowExit
  0076    | JumpBack 76 -> 33
  0079    | MatchWindowExit
  0080    | MatchBind l0 r2
  0083    | Jump 83 -> 87
  0086    | MatchFail
  0087    | MatchWindowExit
  0088    | TakeRight 88 -> 105
  0091    | GetConstantMutable 3: [_, _, _]
  0093    | GetLocalMove l0
  0095    | InsertAtIndex 0
  0097    | GetLocalMove l1
  0099    | InsertAtIndex 1
  0101    | GetLocalMove l2
  0103    | InsertAtIndex 2
  0105    | End
  ========================================
