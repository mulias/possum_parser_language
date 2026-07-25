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
  0006    | JumpIfFailure 6 -> 57
  0009    | MatchWindowEnter 5 fail->55
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array
  0018    | MatchCount r0 ==3
  0022    | MatchElem r1 r0[0]
  0027    | MatchCmp r1 == 1
  0032    | MatchElem r2 r0[1]
  0037    | MatchCmp r2 == 2
  0042    | MatchElem r3 r0[2]
  0047    | MatchCmp r3 == 3
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0012    | JumpIfFailure 12 -> 57
  0015    | MatchWindowEnter 5 fail->55
  0019    | MatchScrutinee r0
  0021    | MatchType r0 array
  0024    | MatchCount r0 ==3
  0028    | MatchElem r1 r0[0]
  0033    | MatchBind l0 r1
  0036    | MatchElem r2 r0[1]
  0041    | MatchBind l1 r2
  0044    | MatchElem r3 r0[2]
  0049    | MatchBind l2 r3
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
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
  0004    | GetConstant 0: const
  0006    | GetConstant 1: [1, 2, 3]
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 57
  0013    | MatchWindowEnter 5 fail->55
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array
  0022    | MatchCount r0 ==3
  0026    | MatchElem r1 r0[0]
  0031    | MatchCmp r1 == 1
  0036    | MatchElem r2 r0[1]
  0041    | MatchBind l0 r2
  0044    | MatchElem r3 r0[2]
  0049    | MatchBind l1 r3
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0011    | MatchWindowEnter 5 fail->55
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 ==3
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l0 r1
  0032    | MatchElem r2 r0[1]
  0037    | MatchCmp r2 == 2
  0042    | MatchElem r3 r0[2]
  0047    | MatchCmp r3 == 3
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
  0018    | JumpIfFailure 18 -> 89
  0021    | MatchWindowEnter 7 fail->87
  0025    | MatchScrutinee r0
  0027    | MatchType r0 array
  0030    | MatchCount r0 ==2
  0034    | MatchElem r1 r0[0]
  0039    | MatchBind l0 r1
  0042    | MatchElem r2 r0[1]
  0047    | MatchType r2 array
  0050    | MatchCount r2 ==2
  0054    | MatchElem r3 r2[0]
  0059    | MatchType r3 array
  0062    | MatchCount r3 ==1
  0066    | MatchElem r4 r3[0]
  0071    | MatchBind l1 r4
  0074    | MatchElem r5 r2[1]
  0079    | MatchCmp r5 == 3
  0084    | Jump 84 -> 88
  0087    | MatchFail
  0088    | MatchWindowExit
  0089    | TakeRight 89 -> 94
  0092    | GetLocalMove l1
  0094    | End
  ========================================

  $ possum -p '3 -> (2 + B)' -i '3'
  
  ================2:@main=================
  3 -> (2 + B)
  ========================================
  0000    | PushVar B
  0002    | ParseNumberStringChar 3
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - 2
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
  0008    | JumpIfFailure 8 -> 57
  0011    | MatchWindowEnter 5 fail->55
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 ==3
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l0 r1
  0032    | MatchElem r2 r0[1]
  0037    | MatchCmp r2 == 2
  0042    | MatchElem r3 r0[2]
  0047    | MatchCmp r3 == 3
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
  0018    | JumpIfFailure 18 -> 73
  0021    | MatchWindowEnter 5 fail->71
  0025    | MatchScrutinee r0
  0027    | MatchType r0 array
  0030    | MatchCount r0 ==3
  0034    | MatchElem r1 r0[0]
  0039    | MatchBind l0 r1
  0042    | MatchElem r2 r0[1]
  0047    | GetConstant 2: @Add
  0049    | PushInteger 1
  0051    | PushInteger 1
  0053    | CallFunction 2
  0055    | MatchEval r2
  0058    | MatchElem r3 r0[2]
  0063    | MatchCmp r3 == 3
  0068    | Jump 68 -> 72
  0071    | MatchFail
  0072    | MatchWindowExit
  0073    | End
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
  0006    | JumpIfFailure 6 -> 47
  0009    | MatchWindowEnter 4 fail->45
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array
  0018    | MatchCount r0 ==2
  0022    | MatchElem r1 r0[0]
  0027    | MatchCmp r1 == 1
  0032    | MatchElem r2 r0[1]
  0037    | MatchCmp r2 == 2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0008    | JumpIfFailure 8 -> 57
  0011    | MatchWindowEnter 5 fail->55
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 >=2
  0024    | MatchElem r1 r0[0]
  0029    | MatchCmp r1 == 1
  0034    | MatchSlice r2 r0[1..^1]
  0039    | MatchBind l0 r2
  0042    | MatchElem r3 r0[^0]
  0047    | MatchCmp r3 == 3
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0015    | MatchWindowEnter 6 fail->69
  0019    | MatchScrutinee r0
  0021    | MatchType r0 array
  0024    | MatchCount r0 >=3
  0028    | MatchElem r1 r0[0]
  0033    | MatchCmp r1 == 1
  0038    | MatchElem r2 r0[1]
  0043    | MatchBind l0 r2
  0046    | MatchSlice r3 r0[2..^1]
  0051    | MatchCmp r3 == l0
  0056    | MatchElem r4 r0[^0]
  0061    | MatchCmp r4 == 3
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
  0004    | JumpIfFailure 4 -> 43
  0007    | MatchWindowEnter 3 fail->41
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCount r0 >=4
  0020    | MatchStrEnd r0 prefix "fo"
  0025    | MatchStrEnd r0 suffix "ar"
  0030    | MatchSlice r1 r0[2..^2]
  0035    | MatchBind l0 r1
  0038    | Jump 38 -> 42
  0041    | MatchFail
  0042    | MatchWindowExit
  0043    | TakeRight 43 -> 48
  0046    | GetLocalMove l0
  0048    | End
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
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4 fail->45
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 >=1
  0024    | MatchElem r1 r0[0]
  0029    | MatchCmp r1 == 1
  0034    | MatchSlice r2 r0[1..^0]
  0039    | MatchBind l0 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | TakeRight 47 -> 52
  0050    | GetLocalMove l0
  0052    | End
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
  0006    | JumpIfFailure 6 -> 47
  0009    | MatchWindowEnter 4 fail->45
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object
  0018    | MatchCount r0 ==2
  0022    | MatchKey r1 r0["a"]
  0027    | MatchCmp r1 == 1
  0032    | MatchKey r2 r0["b"]
  0037    | MatchCmp r2 == 2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0010    | JumpIfFailure 10 -> 47
  0013    | MatchWindowEnter 4 fail->45
  0017    | MatchScrutinee r0
  0019    | MatchType r0 object
  0022    | MatchCount r0 ==2
  0026    | MatchKey r1 r0["a"]
  0031    | MatchBind l0 r1
  0034    | MatchKey r2 r0["b"]
  0039    | MatchBind l1 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0006    | JumpIfFailure 6 -> 37
  0009    | MatchWindowEnter 2 fail->35
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object
  0018    | MatchCount r0 ==2
  0022    | MatchKey r1 r0["a"]
  0027    | MatchKey r1 r0["b"]
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | End
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
  0008    | JumpIfFailure 8 -> 49
  0011    | MatchWindowEnter 4 fail->47
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["a"]
  0029    | MatchCmp r1 == 1
  0034    | MatchObjectRest r2 r0 \ ["a"]
  0041    | MatchBind l0 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | End
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
  0008    | JumpIfFailure 8 -> 49
  0011    | MatchWindowEnter 4 fail->47
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["b"]
  0029    | MatchCmp r1 == 2
  0034    | MatchObjectRest r2 r0 \ ["b"]
  0041    | MatchBind l0 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | End
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
  0008    | JumpIfFailure 8 -> 49
  0011    | MatchWindowEnter 4 fail->47
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchObjectRest r1 r0 \ ["b"]
  0031    | MatchBind l0 r1
  0034    | MatchKey r2 r0["b"]
  0039    | MatchCmp r2 == 2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | End
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
  0008    | JumpIfFailure 8 -> 49
  0011    | MatchWindowEnter 4 fail->47
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["a"]
  0029    | MatchCmp r1 == 1
  0034    | MatchObjectRest r2 r0 \ ["a"]
  0041    | MatchBind l0 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | End
  ========================================

  $ possum -p '2 -> 0..5' -i '2'
  
  ================2:@main=================
  2 -> 0..5
  ========================================
  0000    | ParseNumberStringChar 2
  0002    | JumpIfFailure 2 -> 31
  0005    | MatchWindowEnter 2 fail->29
  0009    | MatchScrutinee r0
  0011    | MatchType r0 num_or_codepoint
  0014    | MatchBound r0 lo 0
  0020    | MatchBound r0 hi 5
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | MatchWindowExit
  0031    | End
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
  0002    | JumpIfFailure 2 -> 31
  0005    | MatchWindowEnter 2 fail->29
  0009    | MatchScrutinee r0
  0011    | MatchType r0 num_or_codepoint
  0014    | MatchBound r0 lo "a"
  0020    | MatchBound r0 hi "z"
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | MatchWindowExit
  0031    | End
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
  0002    | JumpIfFailure 2 -> 25
  0005    | MatchWindowEnter 2 fail->23
  0009    | MatchScrutinee r0
  0011    | MatchType r0 num_or_codepoint
  0014    | MatchBound r0 hi "z"
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | End
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
  0002    | JumpIfFailure 2 -> 23
  0005    | MatchWindowEnter 2 fail->21
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array
  0014    | MatchCount r0 >=0
  0018    | Jump 18 -> 22
  0021    | MatchFail
  0022    | MatchWindowExit
  0023    | End
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
  0009    | JumpIfFailure 9 -> 46
  0012    | MatchWindowEnter 4 fail->44
  0016    | MatchScrutinee r0
  0018    | MatchType r0 array
  0021    | MatchCount r0 >=1
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l2 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l3 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 132
  0049    | SetInputMark
  0050    | GetLocalMove l2
  0052    | JumpIfFailure 52 -> 81
  0055    | MatchWindowEnter 3 fail->79
  0059    | MatchScrutinee r0
  0061    | MatchType r0 array
  0064    | MatchCount r0 >=1
  0068    | MatchSlice r1 r0[1..^0]
  0073    | MatchBind l4 r1
  0076    | Jump 76 -> 80
  0079    | MatchFail
  0080    | MatchWindowExit
  0081    | ConditionalThen 81 -> 110
  0084    | GetConstant 0: __Table.RestPerRow
  0086    | GetLocalMove l3
  0088    | PushEmptyArray
  0089    | JumpIfFailure 89 -> 95
  0092    | GetLocalMove l1
  0094    | Merge
  0095    | JumpIfFailure 95 -> 105
  0098    | GetConstantMutable 1: [_]
  0100    | GetLocalMove l4
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
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 44
  0007    | MatchWindowEnter 5 fail->42
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object
  0016    | MatchCount r0 >=1
  0020    | MatchKeyBound key=r2 val=r3 src=r0[l1] keys=r2..r2 \ []
  0028    | MatchWindowEnter 2 fail->38
  0032    | MatchSubScrutinee r0 ^r3
  0035    | MatchBind l2 r0
  0038    | MatchWindowExit
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | TakeRight 44 -> 49
  0047    | GetLocalMove l2
  0049    | End
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == 4
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == 5
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
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - 5
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == 7
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == 5
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
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - 4
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == -1
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
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - -2
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
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - 4 neg
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == 5
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
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - -1 neg
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
  0008    | JumpIfFailure 8 -> 63
  0011    | MatchWindowEnter 5 fail->61
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 ==3
  0024    | MatchElem r1 r0[0]
  0029    | MatchCmp r1 == 1
  0034    | MatchElem r2 r0[1]
  0039    | MatchMergeNum r4 r2 - -1 neg
  0045    | MatchBind l0 r4
  0048    | MatchElem r3 r0[2]
  0053    | MatchCmp r3 == 2
  0058    | Jump 58 -> 62
  0061    | MatchFail
  0062    | MatchWindowExit
  0063    | TakeRight 63 -> 68
  0066    | GetLocalMove l0
  0068    | End
  ========================================

  $ possum -p '"1" -> "%(1)"' -i '1'
  
  ================2:@main=================
  "1" -> "%(1)"
  ========================================
  0000    | ParseChar '1'
  0002    | JumpIfFailure 2 -> 35
  0005    | MatchWindowEnter 6 fail->33
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "1"
  0025    | MatchCmp r2 == r3
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================

  $ possum -p '"2" -> "%(1 + 1)"' -i '2'
  
  ================2:@main=================
  "2" -> "%(1 + 1)"
  ========================================
  0000    | ParseChar '2'
  0002    | JumpIfFailure 2 -> 35
  0005    | MatchWindowEnter 6 fail->33
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "2"
  0025    | MatchCmp r2 == r3
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================

  $ possum -p '"50" -> "%(0 + N)" $ N' -i '50'
  
  ================2:@main=================
  "50" -> "%(0 + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "50"
  0004    | JumpIfFailure 4 -> 28
  0007    | MatchWindowEnter 6 fail->26
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCast r4 <- num r0
  0020    | MatchBind l0 r4
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | TakeRight 28 -> 33
  0031    | GetLocalMove l0
  0033    | End
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l0 r0
  0016    | MatchWindowExit
  0017    | End
  ========================================

  $ possum -p '"abc" -> "abc"' -i 'abc'
  
  ================2:@main=================
  "abc" -> "abc"
  ========================================
  0000    | CallFunctionConstant 0: "abc"
  0002    | JumpIfFailure 2 -> 21
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == "abc"
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
  0009    | MatchWindowEnter 2 fail->23
  0013    | MatchScrutinee r0
  0015    | MatchCmp r0 == "\nfoo"
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
  0006    | JumpIfFailure 6 -> 48
  0009    | MatchWindowEnter 6 fail->46
  0013    | MatchScrutinee r0
  0015    | MatchType r0 string
  0018    | MatchStrInit r0 front=r2 end=r3
  0022    | MatchStrChar r5 r0 cursor=r2 opp=r3 front
  0028    | MatchType r5 num_or_codepoint
  0031    | MatchBound r5 lo "a"
  0037    | MatchBound r5 hi "z"
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | End
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
  0002    | JumpIfFailure 2 -> 26
  0005    | MatchWindowEnter 3 fail->24
  0009    | MatchScrutinee r0
  0011    | PushString "3"
  0013    | MatchRepeatValue r0 r2
  0016    | MatchCmp r2 == 10
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | End
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
  0006    | JumpIfFailure 6 -> 34
  0009    | MatchWindowEnter 3 fail->32
  0013    | MatchScrutinee r0
  0015    | MatchRepeatRange r0 r2 _0_..
  0024    | MatchCmp r2 == 10
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | MatchWindowExit
  0034    | End
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
  0009    | MatchWindowEnter 2 fail->23
  0013    | MatchScrutinee r0
  0015    | MatchCmp r0 == true
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
  0004    | JumpIfFailure 4 -> 28
  0007    | MatchWindowEnter 6 fail->26
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCast r4 <- num r0
  0020    | MatchBind l1 r4
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | TakeRight 28 -> 33
  0031    | GetLocalMove l1
  0033    | End
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
  0005    | MatchWindowEnter 2 fail->19
  0009    | MatchScrutinee r0
  0011    | MatchCmp r0 == 5
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
  0002    | JumpIfFailure 2 -> 31
  0005    | MatchWindowEnter 2 fail->29
  0009    | MatchScrutinee r0
  0011    | MatchType r0 num_or_codepoint
  0014    | MatchBound r0 lo 2
  0020    | MatchBound r0 hi 7
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | MatchWindowExit
  0031    | End
  ========================================

  $ possum -p '8 -> (0 + N)' -i '8'
  
  ================2:@main=================
  8 -> (0 + N)
  ========================================
  0000    | PushVar N
  0002    | ParseNumberStringChar 8
  0004    | JumpIfFailure 4 -> 27
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - 0
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
  0007    | MatchWindowEnter 2 fail->25
  0011    | MatchScrutinee r0
  0013    | MatchMergeNum r1 r0 - 100
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [1, 2, 3]
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: digit
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 57
  0009    | MatchWindowEnter 5 fail->55
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array
  0018    | MatchCount r0 ==3
  0022    | MatchElem r1 r0[0]
  0027    | MatchCmp r1 == 1
  0032    | MatchElem r2 r0[1]
  0037    | MatchCmp r2 == 2
  0042    | MatchElem r3 r0[2]
  0047    | MatchCmp r3 == 3
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [A, ..._]
  ========================================
  0000    | PushVar A
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 37
  0011    | MatchWindowEnter 3 fail->35
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 >=1
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l0 r1
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | End
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([1] * 5)
  ========================================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: digit
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 107
  0009    | MatchWindowEnter 5 fail->105
  0013    | MatchScrutinee r0
  0015    | MatchRepeatInit r0 /1 n=r2 base=r3
  0020    | MatchCmp r2 == 5
  0025    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->102
  0032    | MatchWindowEnter 3 fail->59
  0036    | MatchSubScrutinee r0 ^r4
  0039    | MatchType r0 array
  0042    | MatchCount r0 ==1
  0046    | MatchElem r1 r0[0]
  0051    | MatchCmp r1 == 1
  0056    | Jump 56 -> 61
  0059    | MatchWindowExit
  0060    | MatchRefail
  0061    | MatchWindowExit
  0062    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->102
  0069    | MatchWindowEnter 3 fail->96
  0073    | MatchSubScrutinee r0 ^r4
  0076    | MatchType r0 array
  0079    | MatchCount r0 ==1
  0083    | MatchElem r1 r0[0]
  0088    | MatchCmp r1 == 1
  0093    | Jump 93 -> 98
  0096    | MatchWindowExit
  0097    | MatchRefail
  0098    | MatchWindowExit
  0099    | JumpBack 99 -> 62
  0102    | Jump 102 -> 106
  0105    | MatchFail
  0106    | MatchWindowExit
  0107    | End
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([A] * 5)
  ========================================
  0000    | PushVar A
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 107
  0011    | MatchWindowEnter 5 fail->105
  0015    | MatchScrutinee r0
  0017    | MatchRepeatInit r0 /1 n=r2 base=r3
  0022    | MatchCmp r2 == 5
  0027    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->102
  0034    | MatchWindowEnter 3 fail->59
  0038    | MatchSubScrutinee r0 ^r4
  0041    | MatchType r0 array
  0044    | MatchCount r0 ==1
  0048    | MatchElem r1 r0[0]
  0053    | MatchBind l0 r1
  0056    | Jump 56 -> 61
  0059    | MatchWindowExit
  0060    | MatchRefail
  0061    | MatchWindowExit
  0062    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->102
  0069    | MatchWindowEnter 3 fail->96
  0073    | MatchSubScrutinee r0 ^r4
  0076    | MatchType r0 array
  0079    | MatchCount r0 ==1
  0083    | MatchElem r1 r0[0]
  0088    | MatchCmp r1 == l0
  0093    | Jump 93 -> 98
  0096    | MatchWindowExit
  0097    | MatchRefail
  0098    | MatchWindowExit
  0099    | JumpBack 99 -> 62
  0102    | Jump 102 -> 106
  0105    | MatchFail
  0106    | MatchWindowExit
  0107    | End
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> ([1] * N) $ N
  ========================================
  0000    | PushVar N
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 107
  0011    | MatchWindowEnter 5 fail->105
  0015    | MatchScrutinee r0
  0017    | MatchRepeatInit r0 /1 n=r2 base=r3
  0022    | MatchBind l0 r2
  0025    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->102
  0032    | MatchWindowEnter 3 fail->59
  0036    | MatchSubScrutinee r0 ^r4
  0039    | MatchType r0 array
  0042    | MatchCount r0 ==1
  0046    | MatchElem r1 r0[0]
  0051    | MatchCmp r1 == 1
  0056    | Jump 56 -> 61
  0059    | MatchWindowExit
  0060    | MatchRefail
  0061    | MatchWindowExit
  0062    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->102
  0069    | MatchWindowEnter 3 fail->96
  0073    | MatchSubScrutinee r0 ^r4
  0076    | MatchType r0 array
  0079    | MatchCount r0 ==1
  0083    | MatchElem r1 r0[0]
  0088    | MatchCmp r1 == 1
  0093    | Jump 93 -> 98
  0096    | MatchWindowExit
  0097    | MatchRefail
  0098    | MatchWindowExit
  0099    | JumpBack 99 -> 62
  0102    | Jump 102 -> 106
  0105    | MatchFail
  0106    | MatchWindowExit
  0107    | TakeRight 107 -> 112
  0110    | GetLocalMove l0
  0112    | End
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [A, ..._, Z]
  ========================================
  0000    | PushVar A
  0002    | PushVar Z
  0004    | GetConstant 0: array
  0006    | GetConstant 1: digit
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 47
  0013    | MatchWindowEnter 4 fail->45
  0017    | MatchScrutinee r0
  0019    | MatchType r0 array
  0022    | MatchCount r0 >=2
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l0 r1
  0034    | MatchElem r2 r0[^0]
  0039    | MatchBind l1 r2
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [1, B, _]
  ========================================
  0000    | PushVar B
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4 fail->45
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 ==3
  0024    | MatchElem r1 r0[0]
  0029    | MatchCmp r1 == 1
  0034    | MatchElem r2 r0[1]
  0039    | MatchBind l0 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": 1, "b": 2}
  ========================================
  0000    | GetConstant 0: object
  0002    | GetConstant 1: alpha
  0004    | GetConstant 2: digit
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 49
  0011    | MatchWindowEnter 4 fail->47
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 ==2
  0024    | MatchKey r1 r0["a"]
  0029    | MatchCmp r1 == 1
  0034    | MatchKey r2 r0["b"]
  0039    | MatchCmp r2 == 2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | End
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": 1, ..._}
  ========================================
  0000    | GetConstant 0: object
  0002    | GetConstant 1: alpha
  0004    | GetConstant 2: digit
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 39
  0011    | MatchWindowEnter 3 fail->37
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["a"]
  0029    | MatchCmp r1 == 1
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
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
  
  ================2:@main=================
  object(alpha, digit) -> {_: 1, ..._}
  ========================================
  0000    | GetConstant 0: object
  0002    | GetConstant 1: alpha
  0004    | GetConstant 2: digit
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 59
  0011    | MatchWindowEnter 5 fail->57
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchSearchInit r4
  0026    | MatchNextUnclaimed key=r2 val=r3 src=r0 cursor=r4 keys=r2..r2 \ []
  0034    | MatchWindowEnter 2 fail->49
  0038    | MatchSubScrutinee r0 ^r3
  0041    | MatchCmp r0 == 1
  0046    | Jump 46 -> 53
  0049    | MatchWindowExit
  0050    | JumpBack 50 -> 26
  0053    | MatchWindowExit
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | MatchWindowExit
  0059    | End
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": A, ..._}
  ========================================
  0000    | PushVar A
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 39
  0013    | MatchWindowEnter 3 fail->37
  0017    | MatchScrutinee r0
  0019    | MatchType r0 object
  0022    | MatchCount r0 >=1
  0026    | MatchKey r1 r0["a"]
  0031    | MatchBind l0 r1
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
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
  
  ================2:@main=================
  object(alpha, digit) -> {..._, "a": A}
  ========================================
  0000    | PushVar A
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 39
  0013    | MatchWindowEnter 3 fail->37
  0017    | MatchScrutinee r0
  0019    | MatchType r0 object
  0022    | MatchCount r0 >=1
  0026    | MatchKey r1 r0["a"]
  0031    | MatchBind l0 r1
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
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
  
  ================2:@main=================
  object(alpha, digit) -> {"a": _, "b": B}
  ========================================
  0000    | PushVar B
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 44
  0013    | MatchWindowEnter 3 fail->42
  0017    | MatchScrutinee r0
  0019    | MatchType r0 object
  0022    | MatchCount r0 ==2
  0026    | MatchKey r2 r0["a"]
  0031    | MatchKey r1 r0["b"]
  0036    | MatchBind l0 r1
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | End
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
  0004    | JumpIfFailure 4 -> 17
  0007    | MatchWindowEnter 2 fail->16
  0011    | MatchScrutinee r0
  0013    | MatchBind l1 r0
  0016    | MatchWindowExit
  0017    | TakeRight 17 -> 26
  0020    | GetConstantMutable 1: [_]
  0022    | GetLocalMove l1
  0024    | InsertAtIndex 0
  0026    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> [...A]
  ========================================
  0000    | PushVar A
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 37
  0011    | MatchWindowEnter 3 fail->35
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 >=0
  0024    | MatchSlice r1 r0[0..^0]
  0029    | MatchBind l0 r1
  0032    | Jump 32 -> 36
  0035    | MatchFail
  0036    | MatchWindowExit
  0037    | End
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
  
  ================2:@main=================
  object(alpha, digit) -> {...O}
  ========================================
  0000    | PushVar O
  0002    | GetConstant 0: object
  0004    | GetConstant 1: alpha
  0006    | GetConstant 2: digit
  0008    | CallFunction 2
  0010    | JumpIfFailure 10 -> 37
  0013    | MatchWindowEnter 3 fail->35
  0017    | MatchScrutinee r0
  0019    | MatchType r0 object
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
  0004    | JumpIfFailure 4 -> 33
  0007    | MatchWindowEnter 2 fail->31
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCount r0 >=0
  0020    | MatchSlice r1 r0[0..^0]
  0025    | MatchBind l0 r1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | End
  ========================================

  $ possum -p '"null" -> "%(null)"' -i 'null'
  
  ================2:@main=================
  "null" -> "%(null)"
  ========================================
  0000    | CallFunctionConstant 0: "null"
  0002    | JumpIfFailure 2 -> 35
  0005    | MatchWindowEnter 6 fail->33
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "null"
  0025    | MatchCmp r2 == r3
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | End
  ========================================

  $ possum -p '"null" -> "%(null + N)" $ N' -i 'null'
  
  ================2:@main=================
  "null" -> "%(null + N)" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "null"
  0004    | JumpIfFailure 4 -> 33
  0007    | MatchWindowEnter 2 fail->31
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCount r0 >=0
  0020    | MatchSlice r1 r0[0..^0]
  0025    | MatchBind l0 r1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 38
  0036    | GetLocalMove l0
  0038    | End
  ========================================

  $ possum -p '"true" -> "%(true + B)" $ B' -i 'true'
  
  ================2:@main=================
  "true" -> "%(true + B)" $ B
  ========================================
  0000    | PushVar B
  0002    | CallFunctionConstant 0: "true"
  0004    | JumpIfFailure 4 -> 33
  0007    | MatchWindowEnter 6 fail->31
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCast r4 <- bool r0
  0020    | MatchMergeBool r1 r4 claim true
  0025    | MatchBind l0 r1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 38
  0036    | GetLocalMove l0
  0038    | End
  ========================================

  $ possum -p '"123" -> "%(0 + N)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(0 + N)"
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | JumpIfFailure 4 -> 28
  0007    | MatchWindowEnter 6 fail->26
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCast r4 <- num r0
  0020    | MatchBind l0 r4
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | End
  ========================================

  $ possum -p '"123" -> "%(N + 1)"' -i '123'
  
  ================2:@main=================
  "123" -> "%(N + 1)"
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "123"
  0004    | JumpIfFailure 4 -> 34
  0007    | MatchWindowEnter 6 fail->32
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCast r4 <- num r0
  0020    | MatchMergeNum r1 r4 - 1
  0026    | MatchBind l0 r1
  0029    | Jump 29 -> 33
  0032    | MatchFail
  0033    | MatchWindowExit
  0034    | End
  ========================================

  $ possum -p '"[1,2,3]" -> "%([...A])"' -i '[1,2,3]'
  
  ================2:@main=================
  "[1,2,3]" -> "%([...A])"
  ========================================
  0000    | PushVar A
  0002    | CallFunctionConstant 0: "[1,2,3]"
  0004    | JumpIfFailure 4 -> 53
  0007    | MatchWindowEnter 6 fail->51
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchCast r4 <- json r0
  0020    | MatchWindowEnter 3 fail->45
  0024    | MatchSubScrutinee r0 ^r4
  0027    | MatchType r0 array
  0030    | MatchCount r0 >=0
  0034    | MatchSlice r1 r0[0..^0]
  0039    | MatchBind l0 r1
  0042    | Jump 42 -> 47
  0045    | MatchWindowExit
  0046    | MatchRefail
  0047    | MatchWindowExit
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | MatchWindowExit
  0053    | End
  ========================================

  $ possum -p '`{"a": 1, "b": 2}` -> "%({..._})"' -i '{"a": 1, "b": 2}'
  
  ================2:@main=================
  `{"a": 1, "b": 2}` -> "%({..._})"
  ========================================
  0000    | CallFunctionConstant 0: "{"a": 1, "b": 2}"
  0002    | JumpIfFailure 2 -> 39
  0005    | MatchWindowEnter 6 fail->37
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string
  0014    | MatchCast r4 <- json r0
  0018    | MatchWindowEnter 2 fail->31
  0022    | MatchSubScrutinee r0 ^r4
  0025    | MatchType r0 object
  0028    | Jump 28 -> 33
  0031    | MatchWindowExit
  0032    | MatchRefail
  0033    | MatchWindowExit
  0034    | Jump 34 -> 38
  0037    | MatchFail
  0038    | MatchWindowExit
  0039    | End
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
  0006    | MatchWindowEnter 3 fail->22
  0010    | MatchScrutinee r0
  0012    | PushEmptyString
  0013    | MatchRepeatValue r0 r2
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
  0007    | MatchWindowEnter 3 fail->24
  0011    | MatchScrutinee r0
  0013    | PushInteger 0
  0015    | MatchRepeatValue r0 r2
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
  0010    | MatchWindowEnter 3 fail->26
  0014    | MatchScrutinee r0
  0016    | PushTrue
  0017    | MatchRepeatValue r0 r2
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
  0010    | MatchWindowEnter 3 fail->26
  0014    | MatchScrutinee r0
  0016    | PushFalse
  0017    | MatchRepeatValue r0 r2
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
  0005    | MatchWindowEnter 2 fail->23
  0009    | MatchScrutinee r0
  0011    | GetConstant 0: Double
  0013    | PushInteger 3
  0015    | CallFunction 1
  0017    | MatchEval r0
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
  0005    | MatchWindowEnter 2 fail->23
  0009    | MatchScrutinee r0
  0011    | GetConstant 0: _Inc
  0013    | PushInteger 5
  0015    | CallFunction 1
  0017    | MatchEval r0
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
  0005    | MatchWindowEnter 2 fail->25
  0009    | MatchScrutinee r0
  0011    | GetConstant 0: Double
  0013    | GetConstant 1: Inc
  0015    | PushInteger 1
  0017    | CallFunction 2
  0019    | MatchEval r0
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
  0002    | JumpIfFailure 2 -> 38
  0005    | MatchWindowEnter 6 fail->36
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string
  0014    | MatchCast r4 <- num r0
  0018    | MatchType r4 num_or_codepoint
  0021    | MatchBound r4 lo -5
  0027    | MatchBound r4 hi -1
  0033    | Jump 33 -> 37
  0036    | MatchFail
  0037    | MatchWindowExit
  0038    | End
  ========================================

  $ possum -p '"a-3" -> "a%(-(1..5))"' -i 'a-3'
  
  ================2:@main=================
  "a-3" -> "a%(-(1..5))"
  ========================================
  0000    | CallFunctionConstant 0: "a-3"
  0002    | JumpIfFailure 2 -> 54
  0005    | MatchWindowEnter 6 fail->52
  0009    | MatchScrutinee r0
  0011    | MatchType r0 string
  0014    | MatchStrInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "a"
  0025    | MatchStrRest r4 r0[r2..r3]
  0030    | MatchCast r4 <- num r4
  0034    | MatchType r4 num_or_codepoint
  0037    | MatchBound r4 lo -5
  0043    | MatchBound r4 hi -1
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | End
  ========================================

  $ possum -p '-4 -> (2 * -(1..5))' -i '-4'
  
  ================2:@main=================
  -4 -> (2 * -(1..5))
  ========================================
  0000    | CallFunctionConstant 0: -4
  0002    | JumpIfFailure 2 -> 36
  0005    | MatchWindowEnter 3 fail->34
  0009    | MatchScrutinee r0
  0011    | PushInteger 2
  0013    | MatchRepeatValue r0 r2
  0016    | MatchType r2 num_or_codepoint
  0019    | MatchBound r2 lo -5
  0025    | MatchBound r2 hi -1
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | MatchWindowExit
  0036    | End
  ========================================

  $ possum -p '"aa" -> ("a" * -(1..2))' -i 'aa'
  
  ================2:@main=================
  "aa" -> ("a" * -(1..2))
  ========================================
  0000    | CallFunctionConstant 0: "aa"
  0002    | JumpIfFailure 2 -> 36
  0005    | MatchWindowEnter 3 fail->34
  0009    | MatchScrutinee r0
  0011    | PushString "a"
  0013    | MatchRepeatValue r0 r2
  0016    | MatchType r2 num_or_codepoint
  0019    | MatchBound r2 lo -2
  0025    | MatchBound r2 hi -1
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | MatchWindowExit
  0036    | End
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
  0004    | JumpIfFailure 4 -> 47
  0007    | MatchWindowEnter 4 fail->45
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchCount r0 ==2
  0020    | MatchElem r1 r0[0]
  0025    | MatchBind l0 r1
  0028    | MatchElem r2 r0[1]
  0033    | GetConstant 1: Inc
  0035    | GetLocalMove l0
  0037    | CallFunction 1
  0039    | MatchEval r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0004    | JumpIfFailure 4 -> 47
  0007    | MatchWindowEnter 4 fail->45
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchCount r0 ==2
  0020    | MatchElem r2 r0[1]
  0025    | MatchBind l0 r2
  0028    | MatchElem r1 r0[0]
  0033    | GetConstant 1: Inc
  0035    | GetLocalMove l0
  0037    | CallFunction 1
  0039    | MatchEval r1
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0005    | MatchWindowEnter 2 fail->27
  0009    | MatchScrutinee r0
  0011    | GetConstant 0: Inc
  0013    | GetConstant 0: Inc
  0015    | PushInteger 1
  0017    | CallFunction 1
  0019    | CallFunction 1
  0021    | MatchEval r0
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
  0004    | JumpIfFailure 4 -> 53
  0007    | MatchWindowEnter 4 fail->51
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchCount r0 ==2
  0020    | MatchElem r1 r0[0]
  0025    | MatchBind l0 r1
  0028    | MatchElem r2 r0[1]
  0033    | GetConstant 1: Inc
  0035    | GetLocalMove l0
  0037    | JumpIfFailure 37 -> 43
  0040    | PushInteger 1
  0042    | Merge
  0043    | CallFunction 1
  0045    | MatchEval r2
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | MatchWindowExit
  0053    | End
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
  0014    | JumpIfFailure 14 -> 86
  0017    | MatchWindowEnter 5 fail->84
  0021    | MatchScrutinee r0
  0023    | MatchType r0 object
  0026    | MatchCount r0 ==1
  0030    | MatchSearchInit r4
  0032    | MatchNextUnclaimed key=r2 val=r3 src=r0 cursor=r4 keys=r2..r2 \ []
  0040    | MatchWindowEnter 4 fail->73
  0044    | MatchSubScrutinee r0 ^r3
  0047    | MatchType r0 array
  0050    | MatchCount r0 ==2
  0054    | MatchElem r1 r0[0]
  0059    | MatchBind l1 r1
  0062    | MatchElem r2 r0[1]
  0067    | MatchBind l2 r2
  0070    | Jump 70 -> 77
  0073    | MatchWindowExit
  0074    | JumpBack 74 -> 32
  0077    | MatchWindowExit
  0078    | MatchBind l0 r2
  0081    | Jump 81 -> 85
  0084    | MatchFail
  0085    | MatchWindowExit
  0086    | TakeRight 86 -> 103
  0089    | GetConstantMutable 3: [_, _, _]
  0091    | GetLocalMove l0
  0093    | InsertAtIndex 0
  0095    | GetLocalMove l1
  0097    | InsertAtIndex 1
  0099    | GetLocalMove l2
  0101    | InsertAtIndex 2
  0103    | End
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
  0002    | JumpIfFailure 2 -> 58
  0005    | MatchWindowEnter 5 fail->56
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array
  0014    | MatchCount r0 ==3
  0018    | MatchElem r1 r0[0]
  0023    | MatchCmp r1 == 1
  0028    | MatchElem r2 r0[1]
  0033    | GetConstant 2: Inc
  0035    | PushInteger 1
  0037    | CallFunction 1
  0039    | NegateNumber
  0040    | MatchEval r2
  0043    | MatchElem r3 r0[2]
  0048    | MatchCmp r3 == 3
  0053    | Jump 53 -> 57
  0056    | MatchFail
  0057    | MatchWindowExit
  0058    | End
  ========================================

  $ possum -p 'Check(Y) = [1, -2, 3] -> [1, -Y, 3] ; "" $ Check(2)' -i ''
  
  ================2:Check=================
  Check(Y) = [1, -2, 3] -> [1, -Y, 3]
  ========================================
  0000    | GetConstant 0: [1, -2, 3]
  0002    | JumpIfFailure 2 -> 54
  0005    | MatchWindowEnter 5 fail->52
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array
  0014    | MatchCount r0 ==3
  0018    | MatchElem r1 r0[0]
  0023    | MatchCmp r1 == 1
  0028    | MatchElem r2 r0[1]
  0033    | GetLocalMove l0
  0035    | NegateNumber
  0036    | MatchEval r2
  0039    | MatchElem r3 r0[2]
  0044    | MatchCmp r3 == 3
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | End
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
  0002    | JumpIfFailure 2 -> 26
  0005    | MatchWindowEnter 3 fail->24
  0009    | MatchScrutinee r0
  0011    | CallFunctionConstant 2: F
  0013    | MatchRepeatValue r0 r2
  0016    | MatchCmp r2 == 2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | End
  ========================================
