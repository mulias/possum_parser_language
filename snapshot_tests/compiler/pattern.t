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
  0006    | JumpIfFailure 6 -> 65
  0009    | MatchWindowEnter 5
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array -> 63
  0018    | MatchCount r0 ==3 -> 63
  0024    | MatchElem r1 r0[0]
  0029    | MatchCmp r1 == 1 -> 63
  0036    | MatchElem r2 r0[1]
  0041    | MatchCmp r2 == 2 -> 63
  0048    | MatchElem r3 r0[2]
  0053    | MatchCmp r3 == 3 -> 63
  0060    | Jump 60 -> 64
  0063    | MatchFail
  0064    | MatchWindowExit
  0065    | End
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
  0012    | JumpIfFailure 12 -> 59
  0015    | MatchWindowEnter 5
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array -> 57
  0024    | MatchCount r0 ==3 -> 57
  0030    | MatchElem r1 r0[0]
  0035    | MatchBind l0 r1
  0038    | MatchElem r2 r0[1]
  0043    | MatchBind l1 r2
  0046    | MatchElem r3 r0[2]
  0051    | MatchBind l2 r3
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | MatchWindowExit
  0059    | End
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
  0010    | JumpIfFailure 10 -> 61
  0013    | MatchWindowEnter 5
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 59
  0022    | MatchCount r0 ==3 -> 59
  0028    | MatchElem r1 r0[0]
  0033    | MatchCmp r1 == 1 -> 59
  0040    | MatchElem r2 r0[1]
  0045    | MatchBind l0 r2
  0048    | MatchElem r3 r0[2]
  0053    | MatchBind l1 r3
  0056    | Jump 56 -> 60
  0059    | MatchFail
  0060    | MatchWindowExit
  0061    | End
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
  0008    | JumpIfFailure 8 -> 63
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 61
  0020    | MatchCount r0 ==3 -> 61
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l0 r1
  0034    | MatchElem r2 r0[1]
  0039    | MatchCmp r2 == 2 -> 61
  0046    | MatchElem r3 r0[2]
  0051    | MatchCmp r3 == 3 -> 61
  0058    | Jump 58 -> 62
  0061    | MatchFail
  0062    | MatchWindowExit
  0063    | End
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
  0018    | JumpIfFailure 18 -> 101
  0021    | MatchWindowEnter 7
  0023    | MatchScrutinee r0
  0025    | MatchType r0 array -> 99
  0030    | MatchCount r0 ==2 -> 99
  0036    | MatchElem r1 r0[0]
  0041    | MatchBind l0 r1
  0044    | MatchElem r2 r0[1]
  0049    | MatchType r2 array -> 99
  0054    | MatchCount r2 ==2 -> 99
  0060    | MatchElem r3 r2[0]
  0065    | MatchType r3 array -> 99
  0070    | MatchCount r3 ==1 -> 99
  0076    | MatchElem r4 r3[0]
  0081    | MatchBind l1 r4
  0084    | MatchElem r5 r2[1]
  0089    | MatchCmp r5 == 3 -> 99
  0096    | Jump 96 -> 100
  0099    | MatchFail
  0100    | MatchWindowExit
  0101    | TakeRight 101 -> 106
  0104    | GetLocalMove l1
  0106    | End
  ========================================

  $ possum -p '3 -> (2 + B)' -i '3'
  
  ================2:@main=================
  3 -> (2 + B)
  ========================================
  0000    | PushVar B
  0002    | ParseNumberStringChar 3
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 2 -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
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
  0008    | JumpIfFailure 8 -> 63
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 61
  0020    | MatchCount r0 ==3 -> 61
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l0 r1
  0034    | MatchElem r2 r0[1]
  0039    | MatchCmp r2 == 2 -> 61
  0046    | MatchElem r3 r0[2]
  0051    | MatchCmp r3 == 3 -> 61
  0058    | Jump 58 -> 62
  0061    | MatchFail
  0062    | MatchWindowExit
  0063    | End
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
  0018    | JumpIfFailure 18 -> 79
  0021    | MatchWindowEnter 5
  0023    | MatchScrutinee r0
  0025    | MatchType r0 array -> 77
  0030    | MatchCount r0 ==3 -> 77
  0036    | MatchElem r1 r0[0]
  0041    | MatchBind l0 r1
  0044    | MatchElem r2 r0[1]
  0049    | GetConstant 2: @Add
  0051    | PushInteger 1
  0053    | PushInteger 1
  0055    | CallFunction 2
  0057    | MatchEval r2 -> 77
  0062    | MatchElem r3 r0[2]
  0067    | MatchCmp r3 == 3 -> 77
  0074    | Jump 74 -> 78
  0077    | MatchFail
  0078    | MatchWindowExit
  0079    | End
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
  0006    | JumpIfFailure 6 -> 53
  0009    | MatchWindowEnter 4
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array -> 51
  0018    | MatchCount r0 ==2 -> 51
  0024    | MatchElem r1 r0[0]
  0029    | MatchCmp r1 == 1 -> 51
  0036    | MatchElem r2 r0[1]
  0041    | MatchCmp r2 == 2 -> 51
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | MatchWindowExit
  0053    | End
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
  0008    | JumpIfFailure 8 -> 63
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 61
  0020    | MatchCount r0 >=2 -> 61
  0026    | MatchElem r1 r0[0]
  0031    | MatchCmp r1 == 1 -> 61
  0038    | MatchSlice r2 r0[1..^1]
  0043    | MatchBind l0 r2
  0046    | MatchElem r3 r0[^0]
  0051    | MatchCmp r3 == 3 -> 61
  0058    | Jump 58 -> 62
  0061    | MatchFail
  0062    | MatchWindowExit
  0063    | End
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
  0012    | JumpIfFailure 12 -> 79
  0015    | MatchWindowEnter 6
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array -> 77
  0024    | MatchCount r0 >=3 -> 77
  0030    | MatchElem r1 r0[0]
  0035    | MatchCmp r1 == 1 -> 77
  0042    | MatchElem r2 r0[1]
  0047    | MatchBind l0 r2
  0050    | MatchSlice r3 r0[2..^1]
  0055    | MatchCmp r3 == l0 -> 77
  0062    | MatchElem r4 r0[^0]
  0067    | MatchCmp r4 == 3 -> 77
  0074    | Jump 74 -> 78
  0077    | MatchFail
  0078    | MatchWindowExit
  0079    | End
  ========================================

  $ possum -p '"foobar" -> ("fo" + Ob + "ar") $ Ob' -i ''
  
  ================2:@main=================
  "foobar" -> ("fo" + Ob + "ar") $ Ob
  ========================================
  0000    | PushVar Ob
  0002    | CallFunctionConstant 0: "foobar"
  0004    | JumpIfFailure 4 -> 49
  0007    | MatchWindowEnter 3
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 47
  0016    | MatchCount r0 >=4 -> 47
  0022    | MatchStrEnd r0 prefix "fo" -> 47
  0029    | MatchStrEnd r0 suffix "ar" -> 47
  0036    | MatchSlice r1 r0[2..^2]
  0041    | MatchBind l0 r1
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | TakeRight 49 -> 54
  0052    | GetLocalMove l0
  0054    | End
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
  0008    | JumpIfFailure 8 -> 51
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 49
  0020    | MatchCount r0 >=1 -> 49
  0026    | MatchElem r1 r0[0]
  0031    | MatchCmp r1 == 1 -> 49
  0038    | MatchSlice r2 r0[1..^0]
  0043    | MatchBind l0 r2
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | TakeRight 51 -> 56
  0054    | GetLocalMove l0
  0056    | End
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
  0006    | JumpIfFailure 6 -> 57
  0009    | MatchWindowEnter 4
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object -> 55
  0018    | MatchCount r0 ==2 -> 55
  0024    | MatchKey r1 r0["a"] -> 55
  0031    | MatchCmp r1 == 1 -> 55
  0038    | MatchKey r2 r0["b"] -> 55
  0045    | MatchCmp r2 == 2 -> 55
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0010    | JumpIfFailure 10 -> 53
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 51
  0022    | MatchCount r0 ==2 -> 51
  0028    | MatchKey r1 r0["a"] -> 51
  0035    | MatchBind l0 r1
  0038    | MatchKey r2 r0["b"] -> 51
  0045    | MatchBind l1 r2
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | MatchWindowExit
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
  0000    | GetConstant 0: const
  0002    | GetConstant 1: {"a": 1, "b": 2}
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 43
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object -> 41
  0018    | MatchCount r0 ==2 -> 41
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
  0008    | JumpIfFailure 8 -> 55
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 53
  0020    | MatchCount r0 >=1 -> 53
  0026    | MatchKey r1 r0["a"] -> 53
  0033    | MatchCmp r1 == 1 -> 53
  0040    | MatchObjectRest r2 r0 \ ["a"]
  0047    | MatchBind l0 r2
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
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
  0008    | JumpIfFailure 8 -> 55
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 53
  0020    | MatchCount r0 >=1 -> 53
  0026    | MatchKey r1 r0["b"] -> 53
  0033    | MatchCmp r1 == 2 -> 53
  0040    | MatchObjectRest r2 r0 \ ["b"]
  0047    | MatchBind l0 r2
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
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
  0008    | JumpIfFailure 8 -> 55
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 53
  0020    | MatchCount r0 >=1 -> 53
  0026    | MatchObjectRest r1 r0 \ ["b"]
  0033    | MatchBind l0 r1
  0036    | MatchKey r2 r0["b"] -> 53
  0043    | MatchCmp r2 == 2 -> 53
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
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
  0008    | JumpIfFailure 8 -> 55
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 53
  0020    | MatchCount r0 >=1 -> 53
  0026    | MatchKey r1 r0["a"] -> 53
  0033    | MatchCmp r1 == 1 -> 53
  0040    | MatchObjectRest r2 r0 \ ["a"]
  0047    | MatchBind l0 r2
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  ================2:@main=================
  2 -> 0..5
  ========================================
  0000    | ParseNumberStringChar 2
  0002    | JumpIfFailure 2 -> 35
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 num_or_codepoint -> 33
  0014    | MatchBound r0 lo 0 -> 33
  0022    | MatchBound r0 hi 5 -> 33
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
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
  0002    | JumpIfFailure 2 -> 35
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 num_or_codepoint -> 33
  0014    | MatchBound r0 lo "a" -> 33
  0022    | MatchBound r0 hi "z" -> 33
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
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
  0002    | JumpIfFailure 2 -> 27
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 num_or_codepoint -> 25
  0014    | MatchBound r0 hi "z" -> 25
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
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
  0000    | GetLocalMove l0
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 array -> 23
  0014    | MatchCount r0 >=0 -> 23
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
  0004    | PushVar RowRest
  0006    | SetInputMark
  0007    | GetLocalMove l0
  0009    | JumpIfFailure 9 -> 48
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array -> 46
  0021    | MatchCount r0 >=1 -> 46
  0027    | MatchElem r1 r0[0]
  0032    | MatchBind l2 r1
  0035    | MatchSlice r2 r0[1..^0]
  0040    | MatchBind l3 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | ConditionalThen 48 -> 136
  0051    | SetInputMark
  0052    | GetLocalMove l2
  0054    | JumpIfFailure 54 -> 85
  0057    | MatchWindowEnter 3
  0059    | MatchScrutinee r0
  0061    | MatchType r0 array -> 83
  0066    | MatchCount r0 >=1 -> 83
  0072    | MatchSlice r1 r0[1..^0]
  0077    | MatchBind l4 r1
  0080    | Jump 80 -> 84
  0083    | MatchFail
  0084    | MatchWindowExit
  0085    | ConditionalThen 85 -> 114
  0088    | GetConstant 0: __Table.RestPerRow
  0090    | GetLocalMove l3
  0092    | PushEmptyArray
  0093    | JumpIfFailure 93 -> 99
  0096    | GetLocalMove l1
  0098    | Merge
  0099    | JumpIfFailure 99 -> 109
  0102    | GetConstantMutable 1: [_]
  0104    | GetLocalMove l4
  0106    | InsertAtIndex 0
  0108    | Merge
  0109    | CallTailFunction 2
  0111    | Jump 111 -> 133
  0114    | GetConstant 0: __Table.RestPerRow
  0116    | GetLocalMove l3
  0118    | PushEmptyArray
  0119    | JumpIfFailure 119 -> 125
  0122    | GetLocalMove l1
  0124    | Merge
  0125    | JumpIfFailure 125 -> 131
  0128    | GetConstant 2: [[]]
  0130    | Merge
  0131    | CallTailFunction 2
  0133    | Jump 133 -> 138
  0136    | GetLocalMove l1
  0138    | End
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
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 46
  0007    | MatchWindowEnter 5
  0009    | MatchScrutinee r0
  0011    | MatchType r0 object -> 44
  0016    | MatchCount r0 >=1 -> 44
  0022    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ [] -> 44
  0032    | MatchWindowEnter 2
  0034    | MatchSubScrutinee r0 ^r3
  0037    | MatchBind l2 r0
  0040    | MatchWindowExit
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | TakeRight 46 -> 51
  0049    | GetLocalMove l2
  0051    | End
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
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == 4 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================

  $ possum -p '5 -> (2 + 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 + 3)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == 5 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================

  $ possum -p '5 -> (2 + X + 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 + X + 3)
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 5
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 5 -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
  ========================================

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  
  ================2:@main=================
  7 -> (X + 4)
  ========================================
  0000    | ParseNumberStringChar 7
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == 7 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  
  ================2:@main=================
  5 -> (X + Y)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == 5 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 + X + 3) $ X
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 4 -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 32
  0030    | GetLocalMove l0
  0032    | End
  ========================================

  $ possum -p '5 -> (2 - 3)' -i '5'
  
  ================2:@main=================
  5 -> (2 - 3)
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == -1 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================

  $ possum -p '6 -> (1 + X - 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 + X - 3) $ X
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - -2 -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 32
  0030    | GetLocalMove l0
  0032    | End
  ========================================

  $ possum -p '6 -> (1 - X + 3) $ X' -i '6'
  
  ================2:@main=================
  6 -> (1 - X + 3) $ X
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 6
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 4 neg -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 32
  0030    | GetLocalMove l0
  0032    | End
  ========================================

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  
  ================2:@main=================
  5 -> (1 + 6 + 3 - (2 + 3))
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == 5 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================

  $ possum -p '5 -> -(X + 1) $ X' -i '5'
  
  ================2:@main=================
  5 -> -(X + 1) $ X
  ========================================
  0000    | PushVar X
  0002    | ParseNumberStringChar 5
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - -1 neg -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 32
  0030    | GetLocalMove l0
  0032    | End
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
  0008    | JumpIfFailure 8 -> 71
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 69
  0020    | MatchCount r0 ==3 -> 69
  0026    | MatchElem r1 r0[0]
  0031    | MatchCmp r1 == 1 -> 69
  0038    | MatchElem r2 r0[1]
  0043    | MatchMergeNum r4 r2 - -1 neg -> 69
  0051    | MatchBind l0 r4
  0054    | MatchElem r3 r0[2]
  0059    | MatchCmp r3 == 2 -> 69
  0066    | Jump 66 -> 70
  0069    | MatchFail
  0070    | MatchWindowExit
  0071    | TakeRight 71 -> 76
  0074    | GetLocalMove l0
  0076    | End
  ========================================

  $ possum -p '"1" -> "%(1)"' -i '1'
  
  ================2:@main=================
  "1" -> "%(1)"
  ========================================
  0000    | ParseChar '1'
  0002    | JumpIfFailure 2 -> 39
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 37
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "1" -> 37
  0027    | MatchCmp r2 == r3 -> 37
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
  ========================================

  $ possum -p '"2" -> "%(1 + 1)"' -i '2'
  
  ================2:@main=================
  "2" -> "%(1 + 1)"
  ========================================
  0000    | ParseChar '2'
  0002    | JumpIfFailure 2 -> 39
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 37
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "2" -> 37
  0027    | MatchCmp r2 == r3 -> 37
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
  ========================================

  $ possum -p '"50" -> "%(0 + N)" $ N' -i '50'
  
  ================2:@main=================
  "50" -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "50"
  0004    | JumpIfFailure 4 -> 30
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 28
  0016    | MatchCast r4 <- num r0 -> 28
  0022    | MatchBind l0 r4
  0025    | Jump 25 -> 29
  0028    | MatchFail
  0029    | MatchWindowExit
  0030    | TakeRight 30 -> 35
  0033    | GetLocalMove l0
  0035    | End
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
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == "abc" -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
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
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchCmp r0 == "\nfoo" -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
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
  0000    | GetConstant 0: many
  0002    | GetConstant 1: char
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 56
  0009    | MatchWindowEnter 6
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string -> 54
  0018    | MatchStrInit r0 front=r2 end=r3
  0022    | MatchStrChar r5 r0 cursor=r2 opp=r3 front -> 54
  0030    | MatchType r5 num_or_codepoint -> 54
  0035    | MatchBound r5 lo "a" -> 54
  0043    | MatchBound r5 hi "z" -> 54
  0051    | Jump 51 -> 55
  0054    | MatchFail
  0055    | MatchWindowExit
  0056    | End
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
  0002    | JumpIfFailure 2 -> 28
  0005    | MatchWindowEnter 3
  0007    | MatchScrutinee r0
  0009    | PushString "3"
  0011    | MatchRepeatValue r0 r2 -> 26
  0016    | MatchCmp r2 == 10 -> 26
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | End
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
  0006    | JumpIfFailure 6 -> 36
  0009    | MatchWindowEnter 3
  0011    | MatchScrutinee r0
  0013    | MatchRepeatRange r0 r2 _0_.. -> 34
  0024    | MatchCmp r2 == 10 -> 34
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | MatchWindowExit
  0036    | End
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
  0006    | JumpIfFailure 6 -> 25
  0009    | MatchWindowEnter 2
  0011    | MatchScrutinee r0
  0013    | MatchCmp r0 == true -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
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
  0004    | JumpIfFailure 4 -> 30
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 28
  0016    | MatchCast r4 <- num r0 -> 28
  0022    | MatchBind l1 r4
  0025    | Jump 25 -> 29
  0028    | MatchFail
  0029    | MatchWindowExit
  0030    | TakeRight 30 -> 35
  0033    | GetLocalMove l1
  0035    | End
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
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchCmp r0 == 5 -> 19
  0016    | Jump 16 -> 20
  0019    | MatchFail
  0020    | MatchWindowExit
  0021    | End
  ========================================

  $ possum -p '5 -> 2..7' -i '5'
  
  ================2:@main=================
  5 -> 2..7
  ========================================
  0000    | ParseNumberStringChar 5
  0002    | JumpIfFailure 2 -> 35
  0005    | MatchWindowEnter 2
  0007    | MatchScrutinee r0
  0009    | MatchType r0 num_or_codepoint -> 33
  0014    | MatchBound r0 lo 2 -> 33
  0022    | MatchBound r0 hi 7 -> 33
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================

  $ possum -p '8 -> (0 + N)' -i '8'
  
  ================2:@main=================
  8 -> (0 + N)
  ========================================
  0000    | PushVar N
  0002    | ParseNumberStringChar 8
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 0 -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
  ========================================

  $ possum -p '8 -> (N + 100)' -i '8'
  
  ================2:@main=================
  8 -> (N + 100)
  ========================================
  0000    | PushVar N
  0002    | ParseNumberStringChar 8
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchMergeNum r1 r0 - 100 -> 25
  0019    | MatchBind l0 r1
  0022    | Jump 22 -> 26
  0025    | MatchFail
  0026    | MatchWindowExit
  0027    | End
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
  0006    | JumpIfFailure 6 -> 65
  0009    | MatchWindowEnter 5
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array -> 63
  0018    | MatchCount r0 ==3 -> 63
  0024    | MatchElem r1 r0[0]
  0029    | MatchCmp r1 == 1 -> 63
  0036    | MatchElem r2 r0[1]
  0041    | MatchCmp r2 == 2 -> 63
  0048    | MatchElem r3 r0[2]
  0053    | MatchCmp r3 == 3 -> 63
  0060    | Jump 60 -> 64
  0063    | MatchFail
  0064    | MatchWindowExit
  0065    | End
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
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 39
  0011    | MatchWindowEnter 3
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 37
  0020    | MatchCount r0 >=1 -> 37
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l0 r1
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
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
  0006    | JumpIfFailure 6 -> 121
  0009    | MatchWindowEnter 5
  0011    | MatchScrutinee r0
  0013    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 119
  0020    | MatchCmp r2 == 5 -> 119
  0027    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->116
  0034    | MatchWindowEnter 3
  0036    | MatchSubScrutinee r0 ^r4
  0039    | MatchType r0 array -> 65
  0044    | MatchCount r0 ==1 -> 65
  0050    | MatchElem r1 r0[0]
  0055    | MatchCmp r1 == 1 -> 65
  0062    | Jump 62 -> 69
  0065    | MatchWindowExit
  0066    | Jump 66 -> 119
  0069    | MatchWindowExit
  0070    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->116
  0077    | MatchWindowEnter 3
  0079    | MatchSubScrutinee r0 ^r4
  0082    | MatchType r0 array -> 108
  0087    | MatchCount r0 ==1 -> 108
  0093    | MatchElem r1 r0[0]
  0098    | MatchCmp r1 == 1 -> 108
  0105    | Jump 105 -> 112
  0108    | MatchWindowExit
  0109    | Jump 109 -> 119
  0112    | MatchWindowExit
  0113    | JumpBack 113 -> 70
  0116    | Jump 116 -> 120
  0119    | MatchFail
  0120    | MatchWindowExit
  0121    | End
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
  0008    | JumpIfFailure 8 -> 119
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 117
  0022    | MatchCmp r2 == 5 -> 117
  0029    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->114
  0036    | MatchWindowEnter 3
  0038    | MatchSubScrutinee r0 ^r4
  0041    | MatchType r0 array -> 63
  0046    | MatchCount r0 ==1 -> 63
  0052    | MatchElem r1 r0[0]
  0057    | MatchBind l0 r1
  0060    | Jump 60 -> 67
  0063    | MatchWindowExit
  0064    | Jump 64 -> 117
  0067    | MatchWindowExit
  0068    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->114
  0075    | MatchWindowEnter 3
  0077    | MatchSubScrutinee r0 ^r4
  0080    | MatchType r0 array -> 106
  0085    | MatchCount r0 ==1 -> 106
  0091    | MatchElem r1 r0[0]
  0096    | MatchCmp r1 == l0 -> 106
  0103    | Jump 103 -> 110
  0106    | MatchWindowExit
  0107    | Jump 107 -> 117
  0110    | MatchWindowExit
  0111    | JumpBack 111 -> 68
  0114    | Jump 114 -> 118
  0117    | MatchFail
  0118    | MatchWindowExit
  0119    | End
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
  0008    | JumpIfFailure 8 -> 119
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 117
  0022    | MatchBind l0 r2
  0025    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->114
  0032    | MatchWindowEnter 3
  0034    | MatchSubScrutinee r0 ^r4
  0037    | MatchType r0 array -> 63
  0042    | MatchCount r0 ==1 -> 63
  0048    | MatchElem r1 r0[0]
  0053    | MatchCmp r1 == 1 -> 63
  0060    | Jump 60 -> 67
  0063    | MatchWindowExit
  0064    | Jump 64 -> 117
  0067    | MatchWindowExit
  0068    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->114
  0075    | MatchWindowEnter 3
  0077    | MatchSubScrutinee r0 ^r4
  0080    | MatchType r0 array -> 106
  0085    | MatchCount r0 ==1 -> 106
  0091    | MatchElem r1 r0[0]
  0096    | MatchCmp r1 == 1 -> 106
  0103    | Jump 103 -> 110
  0106    | MatchWindowExit
  0107    | Jump 107 -> 117
  0110    | MatchWindowExit
  0111    | JumpBack 111 -> 68
  0114    | Jump 114 -> 118
  0117    | MatchFail
  0118    | MatchWindowExit
  0119    | TakeRight 119 -> 124
  0122    | GetLocalMove l0
  0124    | End
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
  0002    | PushVar Z
  0004    | GetConstant 0: array
  0006    | GetConstant 1: digit
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 49
  0013    | MatchWindowEnter 4
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array -> 47
  0022    | MatchCount r0 >=2 -> 47
  0028    | MatchElem r1 r0[0]
  0033    | MatchBind l0 r1
  0036    | MatchElem r2 r0[^0]
  0041    | MatchBind l1 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | End
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
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 51
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 49
  0020    | MatchCount r0 ==3 -> 49
  0026    | MatchElem r1 r0[0]
  0031    | MatchCmp r1 == 1 -> 49
  0038    | MatchElem r2 r0[1]
  0043    | MatchBind l0 r2
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | End
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
  0008    | JumpIfFailure 8 -> 59
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 57
  0020    | MatchCount r0 ==2 -> 57
  0026    | MatchKey r1 r0["a"] -> 57
  0033    | MatchCmp r1 == 1 -> 57
  0040    | MatchKey r2 r0["b"] -> 57
  0047    | MatchCmp r2 == 2 -> 57
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | MatchWindowExit
  0059    | End
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
  0000    | GetConstant 0: object
  0002    | GetConstant 1: alpha
  0004    | GetConstant 2: digit
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 45
  0011    | MatchWindowEnter 3
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 43
  0020    | MatchCount r0 >=1 -> 43
  0026    | MatchKey r1 r0["a"] -> 43
  0033    | MatchCmp r1 == 1 -> 43
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | End
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
  0000    | GetConstant 0: object
  0002    | GetConstant 1: alpha
  0004    | GetConstant 2: digit
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 63
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object -> 61
  0020    | MatchCount r0 >=1 -> 61
  0026    | MatchSearchInit r4
  0028    | MatchNextUnclaimed key=r2 val=r3 src=r0 cursor=r4 keys=r2..r2 \ [] loop->61
  0038    | MatchWindowEnter 2
  0040    | MatchSubScrutinee r0 ^r3
  0043    | MatchCmp r0 == 1 -> 53
  0050    | Jump 50 -> 57
  0053    | MatchWindowExit
  0054    | JumpBack 54 -> 28
  0057    | MatchWindowExit
  0058    | Jump 58 -> 62
  0061    | MatchFail
  0062    | MatchWindowExit
  0063    | End
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
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 43
  0013    | MatchWindowEnter 3
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 41
  0022    | MatchCount r0 >=1 -> 41
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
  0000    | PushVar A
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 43
  0013    | MatchWindowEnter 3
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 41
  0022    | MatchCount r0 >=1 -> 41
  0028    | MatchKey r1 r0["a"] -> 41
  0035    | MatchBind l0 r1
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
  0000    | PushVar B
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 50
  0013    | MatchWindowEnter 3
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 48
  0022    | MatchCount r0 ==2 -> 48
  0028    | MatchKey r2 r0["a"] -> 48
  0035    | MatchKey r1 r0["b"] -> 48
  0042    | MatchBind l0 r1
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
  0008    | JumpIfFailure 8 -> 39
  0011    | MatchWindowEnter 3
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 37
  0020    | MatchCount r0 >=0 -> 37
  0026    | MatchSlice r1 r0[0..^0]
  0031    | MatchBind l0 r1
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
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
  0010    | JumpIfFailure 10 -> 37
  0013    | MatchWindowEnter 3
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object -> 35
  0022    | MatchObjectRest r1 r0 \ []
  0029    | MatchBind l0 r1
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | End
  ========================================

  $ possum -p '"abc" -> "%(S)"' -i 'abc'
  
  ================2:@main=================
  "abc" -> "%(S)"
  ========================================
  0000    | PushVar S
  0002    | CallFunctionConstant 0: "abc"
  0004    | JumpIfFailure 4 -> 35
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 33
  0016    | MatchCount r0 >=0 -> 33
  0022    | MatchSlice r1 r0[0..^0]
  0027    | MatchBind l0 r1
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================

  $ possum -p '"null" -> "%(null)"' -i 'null'
  
  ================2:@main=================
  "null" -> "%(null)"
  ========================================
  0000    | CallFunctionConstant 0: "null"
  0002    | JumpIfFailure 2 -> 39
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 37
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "null" -> 37
  0027    | MatchCmp r2 == r3 -> 37
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
  ========================================

  $ possum -p '"null" -> "%(null + N)" $ N' -i 'null'
  
  ================2:@main=================
  "null" -> "%(null + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "null"
  0004    | JumpIfFailure 4 -> 35
  0007    | MatchWindowEnter 2
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 33
  0016    | MatchCount r0 >=0 -> 33
  0022    | MatchSlice r1 r0[0..^0]
  0027    | MatchBind l0 r1
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | TakeRight 35 -> 40
  0038    | GetLocalMove l0
  0040    | End
  ========================================

  $ possum -p '"true" -> "%(true + B)" $ B' -i 'true'
  
  ================2:@main=================
  "true" -> "%(true + B)" $ B
  ========================================
  0000    | PushVar B
  0002    | CallFunctionConstant 0: "true"
  0004    | JumpIfFailure 4 -> 37
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 35
  0016    | MatchCast r4 <- bool r0 -> 35
  0022    | MatchMergeBool r1 r4 claim true -> 35
  0029    | MatchBind l0 r1
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | TakeRight 37 -> 42
  0040    | GetLocalMove l0
  0042    | End
  ========================================

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(0 + N)"
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | JumpIfFailure 4 -> 30
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 28
  0016    | MatchCast r4 <- num r0 -> 28
  0022    | MatchBind l0 r4
  0025    | Jump 25 -> 29
  0028    | MatchFail
  0029    | MatchWindowExit
  0030    | End
  ========================================

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(N + 1)"
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | JumpIfFailure 4 -> 38
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 36
  0016    | MatchCast r4 <- num r0 -> 36
  0022    | MatchMergeNum r1 r4 - 1 -> 36
  0030    | MatchBind l0 r1
  0033    | Jump 33 -> 37
  0036    | MatchFail
  0037    | MatchWindowExit
  0038    | End
  ========================================

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  
  ================2:@main=================
  "[1,2,3]" -> "%([...A])"
  ========================================
  0000    | PushVar A
  0002    | CallFunctionConstant 0: "[1,2,3]"
  0004    | JumpIfFailure 4 -> 59
  0007    | MatchWindowEnter 6
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string -> 57
  0016    | MatchCast r4 <- json r0 -> 57
  0022    | MatchWindowEnter 3
  0024    | MatchSubScrutinee r0 ^r4
  0027    | MatchType r0 array -> 49
  0032    | MatchCount r0 >=0 -> 49
  0038    | MatchSlice r1 r0[0..^0]
  0043    | MatchBind l0 r1
  0046    | Jump 46 -> 53
  0049    | MatchWindowExit
  0050    | Jump 50 -> 57
  0053    | MatchWindowExit
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | MatchWindowExit
  0059    | End
  ========================================

  $ possum -p '`{"a": 1, "b": 2}` -> "%({..._})"' -i '{"a": 1, "b": 2}'
  
  ================2:@main=================
  `{"a": 1, "b": 2}` -> "%({..._})"
  ========================================
  0000    | CallFunctionConstant 0: "{"a": 1, "b": 2}"
  0002    | JumpIfFailure 2 -> 43
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 41
  0014    | MatchCast r4 <- json r0 -> 41
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
  0002    | JumpIfFailure 2 -> 46
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 44
  0014    | MatchCast r4 <- num r0 -> 44
  0020    | MatchType r4 num_or_codepoint -> 44
  0025    | MatchBound r4 lo -5 -> 44
  0033    | MatchBound r4 hi -1 -> 44
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | End
  ========================================

  $ possum -p '"a-3" -> "a%(-(1..5))"' -i 'a-3'
  
  ================2:@main=================
  "a-3" -> "a%(-(1..5))"
  ========================================
  0000    | CallFunctionConstant 0: "a-3"
  0002    | JumpIfFailure 2 -> 64
  0005    | MatchWindowEnter 6
  0007    | MatchScrutinee r0
  0009    | MatchType r0 string -> 62
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "a" -> 62
  0027    | MatchStrRest r4 r0[r2..r3]
  0032    | MatchCast r4 <- num r4 -> 62
  0038    | MatchType r4 num_or_codepoint -> 62
  0043    | MatchBound r4 lo -5 -> 62
  0051    | MatchBound r4 hi -1 -> 62
  0059    | Jump 59 -> 63
  0062    | MatchFail
  0063    | MatchWindowExit
  0064    | End
  ========================================

  $ possum -p '-4 -> (2 * -(1..5))' -i '-4'
  
  ================2:@main=================
  -4 -> (2 * -(1..5))
  ========================================
  0000    | CallFunctionConstant 0: -4
  0002    | JumpIfFailure 2 -> 42
  0005    | MatchWindowEnter 3
  0007    | MatchScrutinee r0
  0009    | PushInteger 2
  0011    | MatchRepeatValue r0 r2 -> 40
  0016    | MatchType r2 num_or_codepoint -> 40
  0021    | MatchBound r2 lo -5 -> 40
  0029    | MatchBound r2 hi -1 -> 40
  0037    | Jump 37 -> 41
  0040    | MatchFail
  0041    | MatchWindowExit
  0042    | End
  ========================================

  $ possum -p '"aa" -> ("a" * -(1..2))' -i 'aa'
  
  ================2:@main=================
  "aa" -> ("a" * -(1..2))
  ========================================
  0000    | CallFunctionConstant 0: "aa"
  0002    | JumpIfFailure 2 -> 42
  0005    | MatchWindowEnter 3
  0007    | MatchScrutinee r0
  0009    | PushString "a"
  0011    | MatchRepeatValue r0 r2 -> 40
  0016    | MatchType r2 num_or_codepoint -> 40
  0021    | MatchBound r2 lo -2 -> 40
  0029    | MatchBound r2 hi -1 -> 40
  0037    | Jump 37 -> 41
  0040    | MatchFail
  0041    | MatchWindowExit
  0042    | End
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
  0004    | JumpIfFailure 4 -> 51
  0007    | MatchWindowEnter 4
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 49
  0016    | MatchCount r0 ==2 -> 49
  0022    | MatchElem r1 r0[0]
  0027    | MatchBind l0 r1
  0030    | MatchElem r2 r0[1]
  0035    | GetConstant 1: Inc
  0037    | GetLocalMove l0
  0039    | CallFunction 1
  0041    | MatchEval r2 -> 49
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | End
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
  0004    | JumpIfFailure 4 -> 51
  0007    | MatchWindowEnter 4
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 49
  0016    | MatchCount r0 ==2 -> 49
  0022    | MatchElem r2 r0[1]
  0027    | MatchBind l0 r2
  0030    | MatchElem r1 r0[0]
  0035    | GetConstant 1: Inc
  0037    | GetLocalMove l0
  0039    | CallFunction 1
  0041    | MatchEval r1 -> 49
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | MatchWindowExit
  0051    | End
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
  0004    | JumpIfFailure 4 -> 57
  0007    | MatchWindowEnter 4
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array -> 55
  0016    | MatchCount r0 ==2 -> 55
  0022    | MatchElem r1 r0[0]
  0027    | MatchBind l0 r1
  0030    | MatchElem r2 r0[1]
  0035    | GetConstant 1: Inc
  0037    | GetLocalMove l0
  0039    | JumpIfFailure 39 -> 45
  0042    | PushInteger 1
  0044    | Merge
  0045    | CallFunction 1
  0047    | MatchEval r2 -> 55
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0014    | JumpIfFailure 14 -> 92
  0017    | MatchWindowEnter 5
  0019    | MatchScrutinee r0
  0021    | MatchType r0 object -> 90
  0026    | MatchCount r0 ==1 -> 90
  0032    | MatchSearchInit r4
  0034    | MatchNextUnclaimed key=r2 val=r3 src=r0 cursor=r4 keys=r2..r2 \ [] loop->90
  0044    | MatchWindowEnter 4
  0046    | MatchSubScrutinee r0 ^r3
  0049    | MatchType r0 array -> 79
  0054    | MatchCount r0 ==2 -> 79
  0060    | MatchElem r1 r0[0]
  0065    | MatchBind l1 r1
  0068    | MatchElem r2 r0[1]
  0073    | MatchBind l2 r2
  0076    | Jump 76 -> 83
  0079    | MatchWindowExit
  0080    | JumpBack 80 -> 34
  0083    | MatchWindowExit
  0084    | MatchBind l0 r2
  0087    | Jump 87 -> 91
  0090    | MatchFail
  0091    | MatchWindowExit
  0092    | TakeRight 92 -> 109
  0095    | GetConstantMutable 3: [_, _, _]
  0097    | GetLocalMove l0
  0099    | InsertAtIndex 0
  0101    | GetLocalMove l1
  0103    | InsertAtIndex 1
  0105    | GetLocalMove l2
  0107    | InsertAtIndex 2
  0109    | End
  ========================================

  $ possum -p 'Inc(N) = "" $ N + 1 ; ("" $ [1, -2, 3]) -> [1, -Inc(1), 3]' -i ''
  
  =================2:Inc==================
  Inc(N) = "" $ N + 1
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 6
  0004    | GetLocalMove l0
  0006    | JumpIfFailure 6 -> 12
  0009    | PushInteger 1
  0011    | Merge
  0012    | End
  ========================================
  
  ================2:@main=================
  ("" $ [1, -2, 3]) -> [1, -Inc(1), 3]
  ========================================
  0000    | GetConstant 0: [1, -2, 3]
  0002    | JumpIfFailure 2 -> 66
  0005    | MatchWindowEnter 5
  0007    | MatchScrutinee r0
  0009    | MatchType r0 array -> 64
  0014    | MatchCount r0 ==3 -> 64
  0020    | MatchElem r1 r0[0]
  0025    | MatchCmp r1 == 1 -> 64
  0032    | MatchElem r2 r0[1]
  0037    | GetConstant 2: Inc
  0039    | PushInteger 1
  0041    | CallFunction 1
  0043    | NegateNumber
  0044    | MatchEval r2 -> 64
  0049    | MatchElem r3 r0[2]
  0054    | MatchCmp r3 == 3 -> 64
  0061    | Jump 61 -> 65
  0064    | MatchFail
  0065    | MatchWindowExit
  0066    | End
  ========================================

  $ possum -p 'Check(Y) = [1, -2, 3] -> [1, -Y, 3] ; "" $ Check(2)' -i ''
  
  ================2:Check=================
  Check(Y) = [1, -2, 3] -> [1, -Y, 3]
  ========================================
  0000    | GetConstant 0: [1, -2, 3]
  0002    | JumpIfFailure 2 -> 62
  0005    | MatchWindowEnter 5
  0007    | MatchScrutinee r0
  0009    | MatchType r0 array -> 60
  0014    | MatchCount r0 ==3 -> 60
  0020    | MatchElem r1 r0[0]
  0025    | MatchCmp r1 == 1 -> 60
  0032    | MatchElem r2 r0[1]
  0037    | GetLocalMove l0
  0039    | NegateNumber
  0040    | MatchEval r2 -> 60
  0045    | MatchElem r3 r0[2]
  0050    | MatchCmp r3 == 3 -> 60
  0057    | Jump 57 -> 61
  0060    | MatchFail
  0061    | MatchWindowExit
  0062    | End
  ========================================
  
  ================2:@main=================
  "" $ Check(2)
  ========================================
  0000    | GetConstant 3: Check
  0002    | PushInteger 2
  0004    | CallTailFunction 1
  0006    | End
  ========================================

  $ possum -p 'F = "" $ [1] ; ("" $ [1, 1]) -> (F() * 2)' -i ''
  
  ==================2:F===================
  F = "" $ [1]
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 6
  0004    | GetConstant 0: [1]
  0006    | End
  ========================================
  
  ================2:@main=================
  ("" $ [1, 1]) -> (F() * 2)
  ========================================
  0000    | GetConstant 1: [1, 1]
  0002    | JumpIfFailure 2 -> 28
  0005    | MatchWindowEnter 3
  0007    | MatchScrutinee r0
  0009    | CallFunctionConstant 2: F
  0011    | MatchRepeatValue r0 r2 -> 26
  0016    | MatchCmp r2 == 2 -> 26
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | End
  ========================================
