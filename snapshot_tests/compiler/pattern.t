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
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4 fail->45
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["a"]
  0029    | MatchCmp r1 == 1
  0034    | MatchObjectRest r2 r0 \ ["a"]
  0039    | MatchBind l0 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4 fail->45
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["b"]
  0029    | MatchCmp r1 == 2
  0034    | MatchObjectRest r2 r0 \ ["b"]
  0039    | MatchBind l0 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4 fail->45
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchObjectRest r1 r0 \ ["b"]
  0029    | MatchBind l0 r1
  0032    | MatchKey r2 r0["b"]
  0037    | MatchCmp r2 == 2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4 fail->45
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["a"]
  0029    | MatchCmp r1 == 1
  0034    | MatchObjectRest r2 r0 \ ["a"]
  0039    | MatchBind l0 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | End
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
  0004    | JumpIfFailure 4 -> 50
  0007    | MatchWindowEnter 6 fail->48
  0011    | MatchScrutinee r0
  0013    | MatchClaimSeed r2 <- []
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | GetLocalMove l1
  0026    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0031    | MatchWindowEnter 2 fail->41
  0035    | MatchSubScrutinee r0 ^r4
  0038    | MatchBind l2 r0
  0041    | MatchWindowExit
  0042    | MatchClaimAdd r2 r3
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | TakeRight 50 -> 55
  0053    | GetLocalMove l2
  0055    | End
  ========================================
  
  ================2:@main=================
  1
  ========================================
  0000    | ParseNumberStringChar 1
  0002    | End
  ========================================

A computed search key matches each candidate member key in its own child
window before the value window, retrying on a mismatch:

  $ possum -p 'const({"123": 1}) -> {"%(0 + N)": 1, ..._} $ N' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"123": 1}) -> {"%(0 + N)": 1, ..._} $ N
  ========================================
  0000    | PushVar N
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"123": 1}
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 89
  0011    | MatchWindowEnter 6 fail->87
  0015    | MatchScrutinee r0
  0017    | MatchClaimSeed r2 <- []
  0021    | MatchType r0 object
  0024    | MatchCount r0 >=1
  0028    | MatchIterInit r5
  0030    | MatchClaimScan key=r3 val=r4 src=r0 cursor=r5 claims=r2
  0036    | MatchWindowEnter 6 fail->56
  0040    | MatchSubScrutinee r0 ^r3
  0043    | MatchType r0 string
  0046    | MatchCast r4 <- num r0
  0050    | MatchBind l0 r4
  0053    | Jump 53 -> 60
  0056    | MatchWindowExit
  0057    | JumpBack 57 -> 30
  0060    | MatchWindowExit
  0061    | MatchWindowEnter 2 fail->76
  0065    | MatchSubScrutinee r0 ^r4
  0068    | MatchCmp r0 == 1
  0073    | Jump 73 -> 80
  0076    | MatchWindowExit
  0077    | JumpBack 77 -> 30
  0080    | MatchWindowExit
  0081    | MatchClaimAdd r2 r3
  0084    | Jump 84 -> 88
  0087    | MatchFail
  0088    | MatchWindowExit
  0089    | TakeRight 89 -> 94
  0092    | GetLocalMove l0
  0094    | End
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

An untyped merge evaluates its non-solvable parts (here a call, pushed by
the eval bridge), then MatchMergeEval pops them and writes the residual
whose type it resolves at match time into the dead register for the
trailing leftover to bind.

  $ possum -p 'I(V) = V ; ("" $ 14) -> (I(2) + X) $ X' -i ''
  
  ==================2:I===================
  I(V) = V
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  ("" $ 14) -> (I(2) + X) $ X
  ========================================
  0000    | PushVar X
  0002    | PushInteger 14
  0004    | JumpIfFailure 4 -> 31
  0007    | MatchWindowEnter 2 fail->29
  0011    | MatchScrutinee r0
  0013    | GetConstant 0: I
  0015    | PushInteger 2
  0017    | CallFunction 1
  0019    | MatchMergeEval r1 <- r0 - <pop>
  0023    | MatchBind l0 r1
  0026    | Jump 26 -> 30
  0029    | MatchFail
  0030    | MatchWindowExit
  0031    | TakeRight 31 -> 36
  0034    | GetLocalMove l0
  0036    | End
  ========================================

An untyped merge with no solvable part is an equality test: every part
evaluates, so the parts merge into one value on the stack that MatchEval
compares against the scrutinee.

  $ possum -p '("" $ 3 -> A) & ("" $ 4 -> B) & (("" $ 7) -> (A + B))' -i ''
  
  ================2:@main=================
  ("" $ 3 -> A) & ("" $ 4 -> B) & (("" $ 7) -> (A + B))
  ========================================
  0000    | PushVar A
  0002    | PushVar B
  0004    | PushInteger 3
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l0 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 37
  0022    | PushInteger 4
  0024    | JumpIfFailure 24 -> 37
  0027    | MatchWindowEnter 2 fail->36
  0031    | MatchScrutinee r0
  0033    | MatchBind l1 r0
  0036    | MatchWindowExit
  0037    | TakeRight 37 -> 64
  0040    | PushInteger 7
  0042    | JumpIfFailure 42 -> 64
  0045    | MatchWindowEnter 2 fail->62
  0049    | MatchScrutinee r0
  0051    | GetLocalMove l0
  0053    | GetLocalMove l1
  0055    | Merge
  0056    | MatchEval r0
  0059    | Jump 59 -> 63
  0062    | MatchFail
  0063    | MatchWindowExit
  0064    | End
  ========================================

An untyped merge with an interior solvable splits the known parts around
it: the parts before strip from the front (MatchMergeEval) and the parts
after strip from the end (MatchMergeEvalBack), chaining through the dead
register so the solvable binds the span carved out between them.

  $ possum -p 'A = "" $ "x" ; C = "" $ "z" ; ("" $ "xyz") -> (A + M + C) $ M' -i ''
  
  ==================2:A===================
  A = "" $ "x"
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 6
  0004    | PushString "x"
  0006    | End
  ========================================
  
  ==================2:C===================
  C = "" $ "z"
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 6
  0004    | PushString "z"
  0006    | End
  ========================================
  
  ================2:@main=================
  ("" $ "xyz") -> (A + M + C) $ M
  ========================================
  0000    | PushVar M
  0002    | PushString "xyz"
  0004    | JumpIfFailure 4 -> 33
  0007    | MatchWindowEnter 2 fail->31
  0011    | MatchScrutinee r0
  0013    | CallFunctionConstant 0: A
  0015    | MatchMergeEval r1 <- r0 - <pop>
  0019    | CallFunctionConstant 1: C
  0021    | MatchMergeEval r1 <- r1 - <pop> (back)
  0025    | MatchBind l0 r1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | TakeRight 33 -> 38
  0036    | GetLocalMove l0
  0038    | End
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
  0014    | MatchSpanInit r0 front=r2 end=r3
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
  0014    | MatchSpanInit r0 front=r2 end=r3
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
  0018    | MatchSpanInit r0 front=r2 end=r3
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

A repeat with a literal count of 1 folds away (P * 1 = P). Nested unit
repeats collapse entirely, so this destructures as a plain array with no
repeat steps or match plan.

  $ possum -p '"" $ [1] -> ((([1] * 1) * 1) * 1)' -i ''
  
  ================2:@main=================
  "" $ [1] -> ((([1] * 1) * 1) * 1)
  ========================================
  0000    | GetConstant 0: [1]
  0002    | JumpIfFailure 2 -> 33
  0005    | MatchWindowEnter 3 fail->31
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array
  0014    | MatchCount r0 ==1
  0018    | MatchElem r1 r0[0]
  0023    | MatchCmp r1 == 1
  0028    | Jump 28 -> 32
  0031    | MatchFail
  0032    | MatchWindowExit
  0033    | End
  ========================================


The unit wrappers around a non-unit repeat fold away too, leaving the
single array-chunk repeat (`[1] * 2`) that already steps inline.

  $ possum -p '"" $ [1, 1] -> ((([1] * 1) * 2) * 1)' -i ''
  
  ================2:@main=================
  "" $ [1, 1] -> ((([1] * 1) * 2) * 1)
  ========================================
  0000    | GetConstant 0: [1, 1]
  0002    | JumpIfFailure 2 -> 106
  0005    | MatchWindowEnter 5 fail->104
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array
  0014    | MatchRepeatInit r0 /1 n=r2 base=r3
  0019    | MatchCmp r2 == 2
  0024    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->101
  0031    | MatchWindowEnter 3 fail->58
  0035    | MatchSubScrutinee r0 ^r4
  0038    | MatchType r0 array
  0041    | MatchCount r0 ==1
  0045    | MatchElem r1 r0[0]
  0050    | MatchCmp r1 == 1
  0055    | Jump 55 -> 60
  0058    | MatchWindowExit
  0059    | MatchRefail
  0060    | MatchWindowExit
  0061    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->101
  0068    | MatchWindowEnter 3 fail->95
  0072    | MatchSubScrutinee r0 ^r4
  0075    | MatchType r0 array
  0078    | MatchCount r0 ==1
  0082    | MatchElem r1 r0[0]
  0087    | MatchCmp r1 == 1
  0092    | Jump 92 -> 97
  0095    | MatchWindowExit
  0096    | MatchRefail
  0097    | MatchWindowExit
  0098    | JumpBack 98 -> 61
  0101    | Jump 101 -> 105
  0104    | MatchFail
  0105    | MatchWindowExit
  0106    | End
  ========================================

Two nested constant repeats consolidate into one: (P * a) * b folds to
P * (a * b), so ([1] * 2) * 3 becomes [1] * 6 with a single chunk loop.

  $ possum -p '"" $ [1, 1] -> (([1] * 2) * 3)' -i ''
  
  ================2:@main=================
  "" $ [1, 1] -> (([1] * 2) * 3)
  ========================================
  0000    | GetConstant 0: [1, 1]
  0002    | JumpIfFailure 2 -> 106
  0005    | MatchWindowEnter 5 fail->104
  0009    | MatchScrutinee r0
  0011    | MatchType r0 array
  0014    | MatchRepeatInit r0 /1 n=r2 base=r3
  0019    | MatchCmp r2 == 6
  0024    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->101
  0031    | MatchWindowEnter 3 fail->58
  0035    | MatchSubScrutinee r0 ^r4
  0038    | MatchType r0 array
  0041    | MatchCount r0 ==1
  0045    | MatchElem r1 r0[0]
  0050    | MatchCmp r1 == 1
  0055    | Jump 55 -> 60
  0058    | MatchWindowExit
  0059    | MatchRefail
  0060    | MatchWindowExit
  0061    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->101
  0068    | MatchWindowEnter 3 fail->95
  0072    | MatchSubScrutinee r0 ^r4
  0075    | MatchType r0 array
  0078    | MatchCount r0 ==1
  0082    | MatchElem r1 r0[0]
  0087    | MatchCmp r1 == 1
  0092    | Jump 92 -> 97
  0095    | MatchWindowExit
  0096    | MatchRefail
  0097    | MatchWindowExit
  0098    | JumpBack 98 -> 61
  0101    | Jump 101 -> 105
  0104    | MatchFail
  0105    | MatchWindowExit
  0106    | End
  ========================================

An all-placeholder object repeat reuses MatchRepeatInit (which counts
members instead of elements when the value is an object) and needs no
per-chunk loop — the count check is the whole match.

  $ possum -p '"" $ {"a": 1} -> ({_: _} * S) $ S' -i ''
  
  ================2:@main=================
  "" $ {"a": 1} -> ({_: _} * S) $ S
  ========================================
  0000    | PushVar S
  0002    | GetConstant 0: {"a": 1}
  0004    | JumpIfFailure 4 -> 29
  0007    | MatchWindowEnter 4 fail->27
  0011    | MatchScrutinee r0
  0013    | MatchType r0 object
  0016    | MatchRepeatInit r0 /1 n=r2 base=r3
  0021    | MatchBind l0 r2
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l0
  0034    | End
  ========================================

A constrained-pair object repeat claims its members into a fresh array
(MatchClaimInit) and matches one group per iteration: MatchClaimScan finds
an unclaimed member, a child window matches its value (binding V in group
0, comparing it in later groups via bind_mode), and MatchClaimAdd records
the key. MatchClaimDone exits once the array covers every member.

  $ possum -p '"" $ {"a": 1, "b": 1} -> ({_: V} * N) $ N' -i ''
  
  ================2:@main=================
  "" $ {"a": 1, "b": 1} -> ({_: V} * N) $ N
  ========================================
  0000    | PushVar V
  0002    | PushVar N
  0004    | GetConstant 0: {"a": 1, "b": 1}
  0006    | JumpIfFailure 6 -> 106
  0009    | MatchWindowEnter 9 fail->104
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object
  0018    | MatchRepeatInit r0 /1 n=r2 base=r3
  0023    | MatchBind l1 r2
  0026    | MatchClaimSeed r4 <- []
  0030    | MatchClaimCount n=r8 <- (members(r0) - 0) / 1
  0035    | MatchClaimDoneCount claims=r4 count=r8 done->101
  0040    | MatchIterInit r7
  0042    | MatchClaimScan key=r5 val=r6 src=r0 cursor=r7 claims=r4
  0048    | MatchWindowEnter 2 fail->58
  0052    | MatchSubScrutinee r0 ^r6
  0055    | MatchBind l0 r0
  0058    | MatchWindowExit
  0059    | MatchClaimAdd r4 r5
  0062    | MatchClaimDoneCount claims=r4 count=r8 done->101
  0067    | MatchIterInit r7
  0069    | MatchClaimScan key=r5 val=r6 src=r0 cursor=r7 claims=r4
  0075    | MatchWindowEnter 2 fail->90
  0079    | MatchSubScrutinee r0 ^r6
  0082    | MatchCmp r0 == l0
  0087    | Jump 87 -> 94
  0090    | MatchWindowExit
  0091    | JumpBack 91 -> 69
  0094    | MatchWindowExit
  0095    | MatchClaimAdd r4 r5
  0098    | JumpBack 98 -> 62
  0101    | Jump 101 -> 105
  0104    | MatchFail
  0105    | MatchWindowExit
  0106    | TakeRight 106 -> 111
  0109    | GetLocalMove l1
  0111    | End
  ========================================


An object merge with a repeat part and a rest loads the known count product
into a target size (MatchCountLoad), seeds the claim array from the const-key
list (MatchClaimSeed, empty here), claims exactly count-many groups
(MatchClaimDoneCount), then builds the rest from the unclaimed members
(MatchClaimRest).

  $ possum -p 'const({"a": 1, "b": 2, "c": 3, "d": 4}) -> {...({_: _} * 3), ...Rest} $ Rest' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2, "c": 3, "d": 4}) -> {...({_: _} * 3), ...Rest} $ Rest
  ========================================
  0000    | PushVar Rest
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2, "c": 3, "d": 4}
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 77
  0011    | MatchWindowEnter 9 fail->75
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchClaimSeed r4 <- []
  0024    | PushInteger 3
  0026    | MatchCountLoad r3 <- len(r4) + <pop> * 1
  0030    | MatchClaimDoneCount claims=r4 count=r3 done->65
  0035    | MatchIterInit r7
  0037    | MatchClaimScan key=r5 val=r6 src=r0 cursor=r7 claims=r4
  0043    | MatchClaimAdd r4 r5
  0046    | MatchClaimDoneCount claims=r4 count=r3 done->65
  0051    | MatchIterInit r7
  0053    | MatchClaimScan key=r5 val=r6 src=r0 cursor=r7 claims=r4
  0059    | MatchClaimAdd r4 r5
  0062    | JumpBack 62 -> 46
  0065    | MatchClaimRest r1 <- r0 \ claims=r4
  0069    | MatchBind l0 r1
  0072    | Jump 72 -> 76
  0075    | MatchFail
  0076    | MatchWindowExit
  0077    | TakeRight 77 -> 82
  0080    | GetLocalMove l0
  0082    | End
  ========================================

The exact (no-rest) shape derives the count from the object's member surplus
over the seeded const keys (MatchClaimCount) and binds it; an all-placeholder
chunk needs no group loop.

  $ possum -p 'const({"a": 1, "b": 2, "c": 3}) -> {"a": 1, ...({_: _} * N)} $ N' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "b": 2, "c": 3}) -> {"a": 1, ...({_: _} * N)} $ N
  ========================================
  0000    | PushVar N
  0002    | GetConstant 0: const
  0004    | GetConstant 1: {"a": 1, "b": 2, "c": 3}
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 9 fail->45
  0015    | MatchScrutinee r0
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | MatchKey r1 r0["a"]
  0029    | MatchCmp r1 == 1
  0034    | MatchClaimCount n=r3 <- (members(r0) - 1) / 1
  0039    | MatchBind l0 r3
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | TakeRight 47 -> 52
  0050    | GetLocalMove l0
  0052    | End
  ========================================

An object merge with structural and runtime parts solves on the claim
array: the structural part probes its const key (MatchClaimKey) and claims
it, the evaluated part pops and claims all of its members (MatchClaimObject),
and the solvable takes the unclaimed rest (MatchClaimRest).

  $ possum -p 'A = {"a": 1} ; const({"a": 1, "q": 5, "r": 6}) -> (A + {"q": Q} + R) $ [Q, R]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ==================2:A===================
  A = {"a": 1}
  ========================================
  0000    | GetConstant 0: {"a": 1}
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "q": 5, "r": 6}) -> (A + {"q": Q} + R) $ [Q, R]
  ========================================
  0000    | PushVar Q
  0002    | PushVar R
  0004    | GetConstant 1: const
  0006    | GetConstant 2: {"a": 1, "q": 5, "r": 6}
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 56
  0013    | MatchWindowEnter 7 fail->54
  0017    | MatchScrutinee r0
  0019    | MatchType r0 object
  0022    | MatchClaimSeed r2 <- []
  0026    | CallFunctionConstant 4: A
  0028    | MatchClaimObject claims=r2 <- members(<pop>) in r0
  0031    | PushString "q"
  0033    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0038    | MatchBind l0 r4
  0041    | MatchClaimAdd r2 r3
  0044    | MatchClaimRest r1 <- r0 \ claims=r2
  0048    | MatchBind l1 r1
  0051    | Jump 51 -> 55
  0054    | MatchFail
  0055    | MatchWindowExit
  0056    | TakeRight 56 -> 69
  0059    | GetConstantMutable 5: [_, _]
  0061    | GetLocalMove l0
  0063    | InsertAtIndex 0
  0065    | GetLocalMove l1
  0067    | InsertAtIndex 1
  0069    | End
  ========================================

With no solvable, the claims must cover every member: the member count
(MatchClaimCount with a unit pair) feeds a MatchClaimDoneCount that jumps
past the MatchRefail on full coverage.

  $ possum -p 'A = {"a": 1} ; B = {"q": 2} ; const({"a": 1, "q": 2, "z": 3}) -> (A + B + {"z": 3}) $ "ok"' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ==================2:A===================
  A = {"a": 1}
  ========================================
  0000    | GetConstant 0: {"a": 1}
  0002    | End
  ========================================
  
  ==================2:B===================
  B = {"q": 2}
  ========================================
  0000    | GetConstant 1: {"q": 2}
  0002    | End
  ========================================
  
  ================2:@main=================
  const({"a": 1, "q": 2, "z": 3}) -> (A + B + {"z": 3}) $ "ok"
  ========================================
  0000    | GetConstant 2: const
  0002    | GetConstant 3: {"a": 1, "q": 2, "z": 3}
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 63
  0009    | MatchWindowEnter 7 fail->61
  0013    | MatchScrutinee r0
  0015    | MatchType r0 object
  0018    | MatchClaimSeed r2 <- []
  0022    | CallFunctionConstant 5: A
  0024    | MatchClaimObject claims=r2 <- members(<pop>) in r0
  0027    | CallFunctionConstant 6: B
  0029    | MatchClaimObject claims=r2 <- members(<pop>) in r0
  0032    | PushString "z"
  0034    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0039    | MatchCmp r4 == 3
  0044    | MatchClaimAdd r2 r3
  0047    | MatchClaimCount n=r6 <- (members(r0) - 0) / 1
  0052    | MatchClaimDoneCount claims=r2 count=r6 done->58
  0057    | MatchRefail
  0058    | Jump 58 -> 62
  0061    | MatchFail
  0062    | MatchWindowExit
  0063    | TakeRight 63 -> 68
  0066    | PushString "ok"
  0068    | End
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
  0006    | JumpIfFailure 6 -> 110
  0009    | MatchWindowEnter 5 fail->108
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array
  0018    | MatchRepeatInit r0 /1 n=r2 base=r3
  0023    | MatchCmp r2 == 5
  0028    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->105
  0035    | MatchWindowEnter 3 fail->62
  0039    | MatchSubScrutinee r0 ^r4
  0042    | MatchType r0 array
  0045    | MatchCount r0 ==1
  0049    | MatchElem r1 r0[0]
  0054    | MatchCmp r1 == 1
  0059    | Jump 59 -> 64
  0062    | MatchWindowExit
  0063    | MatchRefail
  0064    | MatchWindowExit
  0065    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->105
  0072    | MatchWindowEnter 3 fail->99
  0076    | MatchSubScrutinee r0 ^r4
  0079    | MatchType r0 array
  0082    | MatchCount r0 ==1
  0086    | MatchElem r1 r0[0]
  0091    | MatchCmp r1 == 1
  0096    | Jump 96 -> 101
  0099    | MatchWindowExit
  0100    | MatchRefail
  0101    | MatchWindowExit
  0102    | JumpBack 102 -> 65
  0105    | Jump 105 -> 109
  0108    | MatchFail
  0109    | MatchWindowExit
  0110    | End
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
  0008    | JumpIfFailure 8 -> 110
  0011    | MatchWindowEnter 5 fail->108
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchRepeatInit r0 /1 n=r2 base=r3
  0025    | MatchCmp r2 == 5
  0030    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->105
  0037    | MatchWindowEnter 3 fail->62
  0041    | MatchSubScrutinee r0 ^r4
  0044    | MatchType r0 array
  0047    | MatchCount r0 ==1
  0051    | MatchElem r1 r0[0]
  0056    | MatchBind l0 r1
  0059    | Jump 59 -> 64
  0062    | MatchWindowExit
  0063    | MatchRefail
  0064    | MatchWindowExit
  0065    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->105
  0072    | MatchWindowEnter 3 fail->99
  0076    | MatchSubScrutinee r0 ^r4
  0079    | MatchType r0 array
  0082    | MatchCount r0 ==1
  0086    | MatchElem r1 r0[0]
  0091    | MatchCmp r1 == l0
  0096    | Jump 96 -> 101
  0099    | MatchWindowExit
  0100    | MatchRefail
  0101    | MatchWindowExit
  0102    | JumpBack 102 -> 65
  0105    | Jump 105 -> 109
  0108    | MatchFail
  0109    | MatchWindowExit
  0110    | End
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
  0008    | JumpIfFailure 8 -> 110
  0011    | MatchWindowEnter 5 fail->108
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchRepeatInit r0 /1 n=r2 base=r3
  0025    | MatchBind l0 r2
  0028    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->105
  0035    | MatchWindowEnter 3 fail->62
  0039    | MatchSubScrutinee r0 ^r4
  0042    | MatchType r0 array
  0045    | MatchCount r0 ==1
  0049    | MatchElem r1 r0[0]
  0054    | MatchCmp r1 == 1
  0059    | Jump 59 -> 64
  0062    | MatchWindowExit
  0063    | MatchRefail
  0064    | MatchWindowExit
  0065    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->105
  0072    | MatchWindowEnter 3 fail->99
  0076    | MatchSubScrutinee r0 ^r4
  0079    | MatchType r0 array
  0082    | MatchCount r0 ==1
  0086    | MatchElem r1 r0[0]
  0091    | MatchCmp r1 == 1
  0096    | Jump 96 -> 101
  0099    | MatchWindowExit
  0100    | MatchRefail
  0101    | MatchWindowExit
  0102    | JumpBack 102 -> 65
  0105    | Jump 105 -> 109
  0108    | MatchFail
  0109    | MatchWindowExit
  0110    | TakeRight 110 -> 115
  0113    | GetLocalMove l0
  0115    | End
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
  0008    | JumpIfFailure 8 -> 64
  0011    | MatchWindowEnter 6 fail->62
  0015    | MatchScrutinee r0
  0017    | MatchClaimSeed r2 <- []
  0021    | MatchType r0 object
  0024    | MatchCount r0 >=1
  0028    | MatchIterInit r5
  0030    | MatchClaimScan key=r3 val=r4 src=r0 cursor=r5 claims=r2
  0036    | MatchWindowEnter 2 fail->51
  0040    | MatchSubScrutinee r0 ^r4
  0043    | MatchCmp r0 == 1
  0048    | Jump 48 -> 55
  0051    | MatchWindowExit
  0052    | JumpBack 52 -> 30
  0055    | MatchWindowExit
  0056    | MatchClaimAdd r2 r3
  0059    | Jump 59 -> 63
  0062    | MatchFail
  0063    | MatchWindowExit
  0064    | End
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
  0010    | JumpIfFailure 10 -> 35
  0013    | MatchWindowEnter 3 fail->33
  0017    | MatchScrutinee r0
  0019    | MatchType r0 object
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
  0014    | MatchSpanInit r0 front=r2 end=r3
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
  0004    | JumpIfFailure 4 -> 42
  0007    | MatchWindowEnter 6 fail->40
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchWindowEnter 3 fail->34
  0020    | MatchSubScrutinee r0 ^r0
  0023    | PushString "abc"
  0025    | MatchRepeatValue r0 r2
  0028    | MatchBind l0 r2
  0031    | Jump 31 -> 36
  0034    | MatchWindowExit
  0035    | MatchRefail
  0036    | MatchWindowExit
  0037    | Jump 37 -> 41
  0040    | MatchFail
  0041    | MatchWindowExit
  0042    | TakeRight 42 -> 47
  0045    | GetLocalMove l0
  0047    | End
  ========================================

A repeat segment between literals: the cursor scheduler chomps the fixed
prefix and suffix, MatchSpanRest takes the residual span, and the repeat
matches it in a child window.

  $ possum -p '"pre_ababab_end" -> "pre_%(`ab` * N)_end" $ N' -i 'pre_ababab_end'
  
  ================2:@main=================
  "pre_ababab_end" -> "pre_%(`ab` * N)_end" $ N
  ========================================
  0000    | PushVar N
  0002    | CallFunctionConstant 0: "pre_ababab_end"
  0004    | JumpIfFailure 4 -> 65
  0007    | MatchWindowEnter 6 fail->63
  0011    | MatchScrutinee r0
  0013    | MatchType r0 string
  0016    | MatchSpanInit r0 front=r2 end=r3
  0020    | MatchStrLit r0 cursor=r2 opp=r3 front "pre_"
  0027    | MatchStrLit r0 cursor=r3 opp=r2 back "_end"
  0034    | MatchSpanRest r4 r0[r2..r3]
  0039    | MatchWindowEnter 3 fail->57
  0043    | MatchSubScrutinee r0 ^r4
  0046    | PushString "ab"
  0048    | MatchRepeatValue r0 r2
  0051    | MatchBind l0 r2
  0054    | Jump 54 -> 59
  0057    | MatchWindowExit
  0058    | MatchRefail
  0059    | MatchWindowExit
  0060    | Jump 60 -> 64
  0063    | MatchFail
  0064    | MatchWindowExit
  0065    | TakeRight 65 -> 70
  0068    | GetLocalMove l0
  0070    | End
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
  0003    | JumpIfFailure 3 -> 40
  0006    | MatchWindowEnter 6 fail->38
  0010    | MatchScrutinee r0
  0012    | MatchType r0 string
  0015    | MatchWindowEnter 3 fail->32
  0019    | MatchSubScrutinee r0 ^r0
  0022    | PushEmptyString
  0023    | MatchRepeatValue r0 r2
  0026    | MatchBind l0 r2
  0029    | Jump 29 -> 34
  0032    | MatchWindowExit
  0033    | MatchRefail
  0034    | MatchWindowExit
  0035    | Jump 35 -> 39
  0038    | MatchFail
  0039    | MatchWindowExit
  0040    | End
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
  0014    | MatchSpanInit r0 front=r2 end=r3
  0018    | MatchStrLit r0 cursor=r2 opp=r3 front "a"
  0025    | MatchSpanRest r4 r0[r2..r3]
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
  0014    | JumpIfFailure 14 -> 91
  0017    | MatchWindowEnter 6 fail->89
  0021    | MatchScrutinee r0
  0023    | MatchClaimSeed r2 <- []
  0027    | MatchType r0 object
  0030    | MatchCount r0 ==1
  0034    | MatchIterInit r5
  0036    | MatchClaimScan key=r3 val=r4 src=r0 cursor=r5 claims=r2
  0042    | MatchBind l0 r3
  0045    | MatchWindowEnter 4 fail->78
  0049    | MatchSubScrutinee r0 ^r4
  0052    | MatchType r0 array
  0055    | MatchCount r0 ==2
  0059    | MatchElem r1 r0[0]
  0064    | MatchBind l1 r1
  0067    | MatchElem r2 r0[1]
  0072    | MatchBind l2 r2
  0075    | Jump 75 -> 82
  0078    | MatchWindowExit
  0079    | JumpBack 79 -> 36
  0082    | MatchWindowExit
  0083    | MatchClaimAdd r2 r3
  0086    | Jump 86 -> 90
  0089    | MatchFail
  0090    | MatchWindowExit
  0091    | TakeRight 91 -> 108
  0094    | GetConstantMutable 3: [_, _, _]
  0096    | GetLocalMove l0
  0098    | InsertAtIndex 0
  0100    | GetLocalMove l1
  0102    | InsertAtIndex 1
  0104    | GetLocalMove l2
  0106    | InsertAtIndex 2
  0108    | End
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

  $ possum -p '(("" $ "pt") -> K) & (const({"a": 1, "pt": [3, 4]}) -> {K: [X, Y], ..._}) $ [X, Y]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  (("" $ "pt") -> K) & (const({"a": 1, "pt": [3, 4]}) -> {K: [X, Y], ..._}) $ [X, Y]
  ========================================
  0000    | PushVar K
  0002    | PushVar X
  0004    | PushVar Y
  0006    | PushString "pt"
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l0 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 120
  0024    | GetConstant 0: const
  0026    | GetConstantMutable 1: {"a": 1, _1_}
  0028    | PushString "pt"
  0030    | GetConstant 2: [3, 4]
  0032    | InsertKeyVal 1
  0034    | CallFunction 1
  0036    | JumpIfFailure 36 -> 107
  0039    | MatchWindowEnter 6 fail->105
  0043    | MatchScrutinee r0
  0045    | MatchClaimSeed r2 <- []
  0049    | MatchType r0 object
  0052    | MatchCount r0 >=1
  0056    | GetLocalMove l0
  0058    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0063    | MatchWindowEnter 4 fail->96
  0067    | MatchSubScrutinee r0 ^r4
  0070    | MatchType r0 array
  0073    | MatchCount r0 ==2
  0077    | MatchElem r1 r0[0]
  0082    | MatchBind l1 r1
  0085    | MatchElem r2 r0[1]
  0090    | MatchBind l2 r2
  0093    | Jump 93 -> 98
  0096    | MatchWindowExit
  0097    | MatchRefail
  0098    | MatchWindowExit
  0099    | MatchClaimAdd r2 r3
  0102    | Jump 102 -> 106
  0105    | MatchFail
  0106    | MatchWindowExit
  0107    | TakeRight 107 -> 120
  0110    | GetConstantMutable 4: [_, _]
  0112    | GetLocalMove l1
  0114    | InsertAtIndex 0
  0116    | GetLocalMove l2
  0118    | InsertAtIndex 1
  0120    | End
  ========================================

  $ possum -p '(("" $ "pt") -> K) & (const({"pt": {"x": 9}}) -> {K: {"x": X}, ..._}) $ X' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  (("" $ "pt") -> K) & (const({"pt": {"x": 9}}) -> {K: {"x": X}, ..._}) $ X
  ========================================
  0000    | PushVar K
  0002    | PushVar X
  0004    | PushString "pt"
  0006    | JumpIfFailure 6 -> 19
  0009    | MatchWindowEnter 2 fail->18
  0013    | MatchScrutinee r0
  0015    | MatchBind l0 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 102
  0022    | GetConstant 0: const
  0024    | GetConstantMutable 1: {_0_}
  0026    | PushString "pt"
  0028    | GetConstant 2: {"x": 9}
  0030    | InsertKeyVal 0
  0032    | CallFunction 1
  0034    | JumpIfFailure 34 -> 97
  0037    | MatchWindowEnter 6 fail->95
  0041    | MatchScrutinee r0
  0043    | MatchClaimSeed r2 <- []
  0047    | MatchType r0 object
  0050    | MatchCount r0 >=1
  0054    | GetLocalMove l0
  0056    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0061    | MatchWindowEnter 3 fail->86
  0065    | MatchSubScrutinee r0 ^r4
  0068    | MatchType r0 object
  0071    | MatchCount r0 ==1
  0075    | MatchKey r1 r0["x"]
  0080    | MatchBind l1 r1
  0083    | Jump 83 -> 88
  0086    | MatchWindowExit
  0087    | MatchRefail
  0088    | MatchWindowExit
  0089    | MatchClaimAdd r2 r3
  0092    | Jump 92 -> 96
  0095    | MatchFail
  0096    | MatchWindowExit
  0097    | TakeRight 97 -> 102
  0100    | GetLocalMove l1
  0102    | End
  ========================================

  $ possum -p '(("" $ "a") -> K) & (const({"a": 5}) -> {K: [X, Y]}) $ X' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  (("" $ "a") -> K) & (const({"a": 5}) -> {K: [X, Y]}) $ X
  ========================================
  0000    | PushVar K
  0002    | PushVar X
  0004    | PushVar Y
  0006    | PushString "a"
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l0 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 106
  0024    | GetConstant 0: const
  0026    | GetConstant 1: {"a": 5}
  0028    | CallFunction 1
  0030    | JumpIfFailure 30 -> 101
  0033    | MatchWindowEnter 6 fail->99
  0037    | MatchScrutinee r0
  0039    | MatchClaimSeed r2 <- []
  0043    | MatchType r0 object
  0046    | MatchCount r0 ==1
  0050    | GetLocalMove l0
  0052    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0057    | MatchWindowEnter 4 fail->90
  0061    | MatchSubScrutinee r0 ^r4
  0064    | MatchType r0 array
  0067    | MatchCount r0 ==2
  0071    | MatchElem r1 r0[0]
  0076    | MatchBind l1 r1
  0079    | MatchElem r2 r0[1]
  0084    | MatchBind l2 r2
  0087    | Jump 87 -> 92
  0090    | MatchWindowExit
  0091    | MatchRefail
  0092    | MatchWindowExit
  0093    | MatchClaimAdd r2 r3
  0096    | Jump 96 -> 100
  0099    | MatchFail
  0100    | MatchWindowExit
  0101    | TakeRight 101 -> 106
  0104    | GetLocalMove l1
  0106    | End
  ========================================

  $ possum -p 'Field = "" $ "email" ; ("" $ {"email": 5, "other": 9}) -> {Field: V, ..._} $ V' -i ''
  
  ================2:Field=================
  Field = "" $ "email"
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 6
  0004    | PushString "email"
  0006    | End
  ========================================
  
  ================2:@main=================
  ("" $ {"email": 5, "other": 9}) -> {Field: V, ..._} $ V
  ========================================
  0000    | PushVar V
  0002    | GetConstant 0: {"email": 5, "other": 9}
  0004    | JumpIfFailure 4 -> 50
  0007    | MatchWindowEnter 6 fail->48
  0011    | MatchScrutinee r0
  0013    | MatchClaimSeed r2 <- []
  0017    | MatchType r0 object
  0020    | MatchCount r0 >=1
  0024    | CallFunctionConstant 2: Field
  0026    | MatchClaimKey key=r3 val=r4 src=r0 claims=r2
  0031    | MatchWindowEnter 2 fail->41
  0035    | MatchSubScrutinee r0 ^r4
  0038    | MatchBind l0 r0
  0041    | MatchWindowExit
  0042    | MatchClaimAdd r2 r3
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | TakeRight 50 -> 55
  0053    | GetLocalMove l0
  0055    | End
  ========================================

  $ possum -p 'I(V)=V ; "" $ [1,1,1,1,1,1] -> (I([1]) * I(2) * I(3))' -i ''
  
  ==================2:I===================
  I(V)=V
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  "" $ [1,1,1,1,1,1] -> (I([1]) * I(2) * I(3))
  ========================================
  0000    | GetConstant 0: [1, 1, 1, 1, 1, 1]
  0002    | JumpIfFailure 2 -> 41
  0005    | MatchWindowEnter 3 fail->39
  0009    | MatchScrutinee r0
  0011    | GetConstant 1: I
  0013    | GetConstant 2: [1]
  0015    | CallFunction 1
  0017    | MatchRepeatValue r0 r2
  0020    | GetConstant 1: I
  0022    | PushInteger 3
  0024    | CallFunction 1
  0026    | GetConstant 1: I
  0028    | PushInteger 2
  0030    | CallFunction 1
  0032    | RepeatValue
  0033    | MatchEval r2
  0036    | Jump 36 -> 40
  0039    | MatchFail
  0040    | MatchWindowExit
  0041    | End
  ========================================

  $ possum -p '"" $ [1,1,1,1,1,1] -> ((([1] * 2) * N) * 3) $ N' -i ''
  
  ================2:@main=================
  "" $ [1,1,1,1,1,1] -> ((([1] * 2) * N) * 3) $ N
  ========================================
  0000    | PushVar N
  0002    | GetConstant 0: [1, 1, 1, 1, 1, 1]
  0004    | JumpIfFailure 4 -> 114
  0007    | MatchWindowEnter 5 fail->112
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchRepeatInit r0 /1 n=r2 base=r3
  0021    | PushInteger 3
  0023    | PushInteger 2
  0025    | RepeatValue
  0026    | MatchDivideEval r2 <- r2 / <pop>
  0029    | MatchBind l0 r2
  0032    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->109
  0039    | MatchWindowEnter 3 fail->66
  0043    | MatchSubScrutinee r0 ^r4
  0046    | MatchType r0 array
  0049    | MatchCount r0 ==1
  0053    | MatchElem r1 r0[0]
  0058    | MatchCmp r1 == 1
  0063    | Jump 63 -> 68
  0066    | MatchWindowExit
  0067    | MatchRefail
  0068    | MatchWindowExit
  0069    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->109
  0076    | MatchWindowEnter 3 fail->103
  0080    | MatchSubScrutinee r0 ^r4
  0083    | MatchType r0 array
  0086    | MatchCount r0 ==1
  0090    | MatchElem r1 r0[0]
  0095    | MatchCmp r1 == 1
  0100    | Jump 100 -> 105
  0103    | MatchWindowExit
  0104    | MatchRefail
  0105    | MatchWindowExit
  0106    | JumpBack 106 -> 69
  0109    | Jump 109 -> 113
  0112    | MatchFail
  0113    | MatchWindowExit
  0114    | TakeRight 114 -> 119
  0117    | GetLocalMove l0
  0119    | End
  ========================================

  $ possum -p '"" $ [1,1,1,1,1,1] -> ([1] * (2 * N)) $ N' -i ''
  
  ================2:@main=================
  "" $ [1,1,1,1,1,1] -> ([1] * (2 * N)) $ N
  ========================================
  0000    | PushVar N
  0002    | GetConstant 0: [1, 1, 1, 1, 1, 1]
  0004    | JumpIfFailure 4 -> 111
  0007    | MatchWindowEnter 5 fail->109
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchRepeatInit r0 /1 n=r2 base=r3
  0021    | PushInteger 2
  0023    | MatchDivideEval r2 <- r2 / <pop>
  0026    | MatchBind l0 r2
  0029    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->106
  0036    | MatchWindowEnter 3 fail->63
  0040    | MatchSubScrutinee r0 ^r4
  0043    | MatchType r0 array
  0046    | MatchCount r0 ==1
  0050    | MatchElem r1 r0[0]
  0055    | MatchCmp r1 == 1
  0060    | Jump 60 -> 65
  0063    | MatchWindowExit
  0064    | MatchRefail
  0065    | MatchWindowExit
  0066    | MatchRepeatNext r0 base=r3+1 chunk=r4 done->106
  0073    | MatchWindowEnter 3 fail->100
  0077    | MatchSubScrutinee r0 ^r4
  0080    | MatchType r0 array
  0083    | MatchCount r0 ==1
  0087    | MatchElem r1 r0[0]
  0092    | MatchCmp r1 == 1
  0097    | Jump 97 -> 102
  0100    | MatchWindowExit
  0101    | MatchRefail
  0102    | MatchWindowExit
  0103    | JumpBack 103 -> 66
  0106    | Jump 106 -> 110
  0109    | MatchFail
  0110    | MatchWindowExit
  0111    | TakeRight 111 -> 116
  0114    | GetLocalMove l0
  0116    | End
  ========================================

  $ possum -p 'I(V)=V ; array(digit) -> (I([1]) * I(2) * N * I(3)) $ N' -i '111111111111'
  
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
  
  ==================2:I===================
  I(V)=V
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  array(digit) -> (I([1]) * I(2) * N * I(3)) $ N
  ========================================
  0000    | PushVar N
  0002    | GetConstant 0: array
  0004    | GetConstant 1: digit
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 50
  0011    | MatchWindowEnter 3 fail->48
  0015    | MatchScrutinee r0
  0017    | GetConstant 2: I
  0019    | GetConstant 3: [1]
  0021    | CallFunction 1
  0023    | MatchRepeatValue r0 r2
  0026    | GetConstant 2: I
  0028    | PushInteger 3
  0030    | CallFunction 1
  0032    | GetConstant 2: I
  0034    | PushInteger 2
  0036    | CallFunction 1
  0038    | RepeatValue
  0039    | MatchDivideEval r2 <- r2 / <pop>
  0042    | MatchBind l0 r2
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | TakeRight 50 -> 55
  0053    | GetLocalMove l0
  0055    | End
  ========================================

  $ possum -p '("" $ "aaaaaa") -> (("a" * 2..3) * N) $ N' -i ''
  
  ================2:@main=================
  ("" $ "aaaaaa") -> (("a" * 2..3) * N) $ N
  ========================================
  0000    | PushVar N
  0002    | PushString "aaaaaa"
  0004    | JumpIfFailure 4 -> 35
  0007    | MatchWindowEnter 3 fail->33
  0011    | MatchScrutinee r0
  0013    | PushString "a"
  0015    | MatchRepeatValue r0 r2
  0018    | MatchRepeatRangeDivide r2 r2 2..3
  0027    | MatchBind l0 r2
  0030    | Jump 30 -> 34
  0033    | MatchFail
  0034    | MatchWindowExit
  0035    | TakeRight 35 -> 40
  0038    | GetLocalMove l0
  0040    | End
  ========================================

  $ possum -p 'I(V) = V ; "" $ [1,1] -> (I([1]) * 2)' -i ''
  
  ==================2:I===================
  I(V) = V
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  "" $ [1,1] -> (I([1]) * 2)
  ========================================
  0000    | GetConstant 0: [1, 1]
  0002    | JumpIfFailure 2 -> 30
  0005    | MatchWindowEnter 3 fail->28
  0009    | MatchScrutinee r0
  0011    | GetConstant 1: I
  0013    | GetConstant 2: [1]
  0015    | CallFunction 1
  0017    | MatchRepeatValue r0 r2
  0020    | MatchCmp r2 == 2
  0025    | Jump 25 -> 29
  0028    | MatchFail
  0029    | MatchWindowExit
  0030    | End
  ========================================

  $ possum -p '("" $ "aaa") -> ("a" * 2..3)' -i ''
  
  ================2:@main=================
  ("" $ "aaa") -> ("a" * 2..3)
  ========================================
  0000    | PushString "aaa"
  0002    | JumpIfFailure 2 -> 36
  0005    | MatchWindowEnter 3 fail->34
  0009    | MatchScrutinee r0
  0011    | PushString "a"
  0013    | MatchRepeatValue r0 r2
  0016    | MatchType r2 num_or_codepoint
  0019    | MatchBound r2 lo 2
  0025    | MatchBound r2 hi 3
  0031    | Jump 31 -> 35
  0034    | MatchFail
  0035    | MatchWindowExit
  0036    | End
  ========================================

An array merge with a runtime-length part lowers to the span-cursor
scheduler: MatchType/MatchSpanInit open the cursor, the bound suffix rest B
chomps backward (MatchSpanVal), and the solvable A takes the residual span
(MatchSpanRest + MatchBind). No DestructurePlan.

  $ possum -p 'const([[1,2,3],[3]]) -> [[...A, ...B], [...B]] $ [A, B]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([[1,2,3],[3]]) -> [[...A, ...B], [...B]] $ [A, B]
  ========================================
  0000    | PushVar A
  0002    | PushVar B
  0004    | GetConstant 0: const
  0006    | GetConstantMutable 1: [_, _]
  0008    | GetConstant 2: [1, 2, 3]
  0010    | InsertAtIndex 0
  0012    | GetConstant 3: [3]
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | JumpIfFailure 18 -> 86
  0021    | MatchWindowEnter 8 fail->84
  0025    | MatchScrutinee r0
  0027    | MatchType r0 array
  0030    | MatchCount r0 ==2
  0034    | MatchElem r2 r0[1]
  0039    | MatchType r2 array
  0042    | MatchCount r2 >=0
  0046    | MatchSlice r3 r2[0..^0]
  0051    | MatchBind l1 r3
  0054    | MatchElem r1 r0[0]
  0059    | MatchType r1 array
  0062    | MatchSpanInit r1 front=r5 end=r6
  0066    | GetLocal l1
  0068    | MatchSpanVal r1 cursor=r6 opp=r5 back
  0073    | MatchSpanRest r7 r1[r5..r6]
  0078    | MatchBind l0 r7
  0081    | Jump 81 -> 85
  0084    | MatchFail
  0085    | MatchWindowExit
  0086    | TakeRight 86 -> 99
  0089    | GetConstantMutable 4: [_, _]
  0091    | GetLocalMove l0
  0093    | InsertAtIndex 0
  0095    | GetLocalMove l1
  0097    | InsertAtIndex 1
  0099    | End
  ========================================

A non-empty structural merge part (the `[1]` base) slices a fixed-length
chunk with MatchSpanChunk into the chunk register and matches it in a child
window (MatchWindowEnter/MatchSubScrutinee ... MatchRefail on mismatch),
then the cursor scheduler continues.

  $ possum -p 'const([[1,2,3],[3]]) -> [[1, ...A, ...B], [...B]] $ [A, B]' -i ''
  
  ================4:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  ================2:@main=================
  const([[1,2,3],[3]]) -> [[1, ...A, ...B], [...B]] $ [A, B]
  ========================================
  0000    | PushVar A
  0002    | PushVar B
  0004    | GetConstant 0: const
  0006    | GetConstantMutable 1: [_, _]
  0008    | GetConstant 2: [1, 2, 3]
  0010    | InsertAtIndex 0
  0012    | GetConstant 3: [3]
  0014    | InsertAtIndex 1
  0016    | CallFunction 1
  0018    | JumpIfFailure 18 -> 123
  0021    | MatchWindowEnter 9 fail->121
  0025    | MatchScrutinee r0
  0027    | MatchType r0 array
  0030    | MatchCount r0 ==2
  0034    | MatchElem r2 r0[1]
  0039    | MatchType r2 array
  0042    | MatchCount r2 >=0
  0046    | MatchSlice r3 r2[0..^0]
  0051    | MatchBind l1 r3
  0054    | MatchElem r1 r0[0]
  0059    | MatchType r1 array
  0062    | MatchSpanInit r1 front=r5 end=r6
  0066    | MatchSpanChunk r8 r1[1]@cursor=r5 opp=r6 front
  0073    | MatchWindowEnter 3 fail->100
  0077    | MatchSubScrutinee r0 ^r8
  0080    | MatchType r0 array
  0083    | MatchCount r0 ==1
  0087    | MatchElem r1 r0[0]
  0092    | MatchCmp r1 == 1
  0097    | Jump 97 -> 102
  0100    | MatchWindowExit
  0101    | MatchRefail
  0102    | MatchWindowExit
  0103    | GetLocal l1
  0105    | MatchSpanVal r1 cursor=r6 opp=r5 back
  0110    | MatchSpanRest r7 r1[r5..r6]
  0115    | MatchBind l0 r7
  0118    | Jump 118 -> 122
  0121    | MatchFail
  0122    | MatchWindowExit
  0123    | TakeRight 123 -> 136
  0126    | GetConstantMutable 5: [_, _]
  0128    | GetLocalMove l0
  0130    | InsertAtIndex 0
  0132    | GetLocalMove l1
  0134    | InsertAtIndex 1
  0136    | End
  ========================================
