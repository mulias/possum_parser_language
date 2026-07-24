  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number_value.possum -i '' --no-stdlib
  
  =================0:@Add=================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 1: addNative
  0006    | End
  ========================================
  
  ==============0:@Subtract===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 3: subtractNative
  0006    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 5: multiplyNative
  0006    | End
  ========================================
  
  ===============0:@Divide================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 7: divideNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 9: powerNative
  0006    | End
  ========================================
  
  ===============0:@Modulus===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 11: modulusNative
  0006    | End
  ========================================
  
  ================0:@Floor================
  0000    | GetLocal l0
  0002    | NativeCode 13: floorNative
  0004    | End
  ========================================
  
  ===============0:@Ceiling===============
  0000    | GetLocal l0
  0002    | NativeCode 15: ceilingNative
  0004    | End
  ========================================
  
  =================0:@Add=================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 1: addNative
  0006    | End
  ========================================
  
  ==============0:@Subtract===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 3: subtractNative
  0006    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 5: multiplyNative
  0006    | End
  ========================================
  
  ===============0:@Divide================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 7: divideNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 9: powerNative
  0006    | End
  ========================================
  
  ===============0:@Modulus===============
  0000    | GetLocal l0
  0002    | GetLocal l1
  0004    | NativeCode 11: modulusNative
  0006    | End
  ========================================
  
  ================0:@Floor================
  0000    | GetLocal l0
  0002    | NativeCode 13: floorNative
  0004    | End
  ========================================
  
  ===============0:@Ceiling===============
  0000    | GetLocal l0
  0002    | NativeCode 15: ceilingNative
  0004    | End
  ========================================
  
  ===============1:Num.Inc================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant 0: @Add
  0002    | GetLocalMove l0
  0004    | PushInteger 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============1:Num.Dec================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant 1: @Subtract
  0002    | GetLocalMove l0
  0004    | PushInteger 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============1:Num.Abs================
  Num.Abs(N) = N -> 0.. | -N
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 28
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 num_or_codepoint -> 26
  0015    | MatchBound r0 lo 0 -> 26
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | Or 28 -> 34
  0031    | GetLocalMove l0
  0033    | NegateNumber
  0034    | End
  ========================================
  
  ===============1:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 28
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 num_or_codepoint -> 26
  0015    | MatchBound r0 lo s1 -> 26
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | ConditionalThen 28 -> 36
  0031    | GetLocalMove l0
  0033    | Jump 33 -> 38
  0036    | GetLocalMove l1
  0038    | End
  ========================================
  
  ===============1:Num.Min================
  Num.Min(A, B) = A -> ..B ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 28
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchType r0 num_or_codepoint -> 26
  0015    | MatchBound r0 hi s1 -> 26
  0023    | Jump 23 -> 27
  0026    | MatchFail
  0027    | MatchWindowExit
  0028    | ConditionalThen 28 -> 36
  0031    | GetLocalMove l0
  0033    | Jump 33 -> 38
  0036    | GetLocalMove l1
  0038    | End
  ========================================
  
  =========1:Num.FromBinaryDigits=========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | GetConstant 3: Array.Length
  0004    | GetLocal l0
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 19
  0011    | MatchWindowEnter 2
  0013    | MatchScrutinee r0
  0015    | MatchBind l1 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 38
  0022    | GetConstant 4: _Num.FromBinaryDigits
  0024    | GetLocalMove l0
  0026    | GetLocalMove l1
  0028    | JumpIfFailure 28 -> 34
  0031    | PushNegInteger -1
  0033    | Merge
  0034    | PushInteger 0
  0036    | CallTailFunction 3
  0038    | End
  ========================================
  
  ========1:_Num.FromBinaryDigits=========
  _Num.FromBinaryDigits(Bs, Pos, Acc) =
    Bs -> [B, ...Rest] ? (
      B -> 0..1 &
      _Num.FromBinaryDigits(
        Rest,
        Pos - 1,
        Acc + Num.Mul(B, Num.Pow(2, Pos)),
      )
    ) :
    Acc
  ========================================
  0000    | PushVar B
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 124
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 84
  0054    | MatchWindowEnter 2
  0056    | MatchScrutinee r0
  0058    | MatchType r0 num_or_codepoint -> 82
  0063    | MatchBound r0 lo 0 -> 82
  0071    | MatchBound r0 hi 1 -> 82
  0079    | Jump 79 -> 83
  0082    | MatchFail
  0083    | MatchWindowExit
  0084    | TakeRight 84 -> 121
  0087    | GetConstant 4: _Num.FromBinaryDigits
  0089    | GetLocalMove l4
  0091    | GetLocal l1
  0093    | JumpIfFailure 93 -> 99
  0096    | PushNegInteger -1
  0098    | Merge
  0099    | GetLocalMove l2
  0101    | JumpIfFailure 101 -> 119
  0104    | GetConstant 6: @Multiply
  0106    | GetLocalMove l3
  0108    | GetConstant 7: @Power
  0110    | PushInteger 2
  0112    | GetLocalMove l1
  0114    | CallFunction 2
  0116    | CallFunction 2
  0118    | Merge
  0119    | CallTailFunction 3
  0121    | Jump 121 -> 126
  0124    | GetLocalMove l2
  0126    | End
  ========================================
  
  =========1:Num.FromOctalDigits==========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | GetConstant 3: Array.Length
  0004    | GetLocal l0
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 19
  0011    | MatchWindowEnter 2
  0013    | MatchScrutinee r0
  0015    | MatchBind l1 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 38
  0022    | GetConstant 8: _Num.FromOctalDigits
  0024    | GetLocalMove l0
  0026    | GetLocalMove l1
  0028    | JumpIfFailure 28 -> 34
  0031    | PushNegInteger -1
  0033    | Merge
  0034    | PushInteger 0
  0036    | CallTailFunction 3
  0038    | End
  ========================================
  
  =========1:_Num.FromOctalDigits=========
  _Num.FromOctalDigits(Os, Pos, Acc) =
    Os -> [O, ...Rest] ? (
      O -> 0..7 &
      _Num.FromOctalDigits(
        Rest,
        Pos - 1,
        Acc + Num.Mul(O, Num.Pow(8, Pos)),
      )
    ) :
    Acc
  ========================================
  0000    | PushVar O
  0002    | PushVar Rest
  0004    | SetInputMark
  0005    | GetLocalMove l0
  0007    | JumpIfFailure 7 -> 46
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 44
  0019    | MatchCount r0 >=1 -> 44
  0025    | MatchElem r1 r0[0]
  0030    | MatchBind l3 r1
  0033    | MatchSlice r2 r0[1..^0]
  0038    | MatchBind l4 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 124
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 84
  0054    | MatchWindowEnter 2
  0056    | MatchScrutinee r0
  0058    | MatchType r0 num_or_codepoint -> 82
  0063    | MatchBound r0 lo 0 -> 82
  0071    | MatchBound r0 hi 7 -> 82
  0079    | Jump 79 -> 83
  0082    | MatchFail
  0083    | MatchWindowExit
  0084    | TakeRight 84 -> 121
  0087    | GetConstant 8: _Num.FromOctalDigits
  0089    | GetLocalMove l4
  0091    | GetLocal l1
  0093    | JumpIfFailure 93 -> 99
  0096    | PushNegInteger -1
  0098    | Merge
  0099    | GetLocalMove l2
  0101    | JumpIfFailure 101 -> 119
  0104    | GetConstant 6: @Multiply
  0106    | GetLocalMove l3
  0108    | GetConstant 7: @Power
  0110    | PushInteger 8
  0112    | GetLocalMove l1
  0114    | CallFunction 2
  0116    | CallFunction 2
  0118    | Merge
  0119    | CallTailFunction 3
  0121    | Jump 121 -> 126
  0124    | GetLocalMove l2
  0126    | End
  ========================================
  
  ==========1:Num.FromHexDigits===========
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | GetConstant 3: Array.Length
  0004    | GetLocal l0
  0006    | CallFunction 1
  0008    | JumpIfFailure 8 -> 19
  0011    | MatchWindowEnter 2
  0013    | MatchScrutinee r0
  0015    | MatchBind l1 r0
  0018    | MatchWindowExit
  0019    | TakeRight 19 -> 38
  0022    | GetConstant 10: _Num.FromHexDigits
  0024    | GetLocalMove l0
  0026    | GetLocalMove l1
  0028    | JumpIfFailure 28 -> 34
  0031    | PushNegInteger -1
  0033    | Merge
  0034    | PushInteger 0
  0036    | CallTailFunction 3
  0038    | End
  ========================================
  
  ==========1:_Num.FromHexDigits==========
  _Num.FromHexDigits(Hs, Pos, Acc) =
    Hs -> [H, ...Rest] ? (
      H -> 0..15 &
      _Num.FromHexDigits(
        Rest,
        Pos - 1,
        Acc + Num.Mul(H, Num.Pow(16, Pos)),
      )
    ) :
    Acc
  ========================================
  0000    | PushVar2 H
  0003    | PushVar Rest
  0005    | SetInputMark
  0006    | GetLocalMove l0
  0008    | JumpIfFailure 8 -> 47
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 45
  0020    | MatchCount r0 >=1 -> 45
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l3 r1
  0034    | MatchSlice r2 r0[1..^0]
  0039    | MatchBind l4 r2
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | MatchWindowExit
  0047    | ConditionalThen 47 -> 125
  0050    | GetLocal l3
  0052    | JumpIfFailure 52 -> 85
  0055    | MatchWindowEnter 2
  0057    | MatchScrutinee r0
  0059    | MatchType r0 num_or_codepoint -> 83
  0064    | MatchBound r0 lo 0 -> 83
  0072    | MatchBound r0 hi 15 -> 83
  0080    | Jump 80 -> 84
  0083    | MatchFail
  0084    | MatchWindowExit
  0085    | TakeRight 85 -> 122
  0088    | GetConstant 10: _Num.FromHexDigits
  0090    | GetLocalMove l4
  0092    | GetLocal l1
  0094    | JumpIfFailure 94 -> 100
  0097    | PushNegInteger -1
  0099    | Merge
  0100    | GetLocalMove l2
  0102    | JumpIfFailure 102 -> 120
  0105    | GetConstant 6: @Multiply
  0107    | GetLocalMove l3
  0109    | GetConstant 7: @Power
  0111    | PushInteger 16
  0113    | GetLocalMove l1
  0115    | CallFunction 2
  0117    | CallFunction 2
  0119    | Merge
  0120    | CallTailFunction 3
  0122    | Jump 122 -> 127
  0125    | GetLocalMove l2
  0127    | End
  ========================================
  
  =============2:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushVar L
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 26
  0007    | MatchWindowEnter 5
  0009    | MatchScrutinee r0
  0011    | MatchRepeatInit r0 /1 n=r2 base=r3 -> 24
  0018    | MatchBind l1 r2
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | TakeRight 26 -> 31
  0029    | GetLocalMove l1
  0031    | End
  ========================================
