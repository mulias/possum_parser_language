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
  0003    | JumpIfFailure 3 -> 26
  0006    | MatchWindowEnter 2 fail->24
  0010    | MatchScrutinee r0
  0012    | MatchType r0 num_or_codepoint
  0015    | MatchBound r0 lo 0
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | Or 26 -> 32
  0029    | GetLocalMove l0
  0031    | NegateNumber
  0032    | End
  ========================================
  
  ===============1:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 26
  0006    | MatchWindowEnter 2 fail->24
  0010    | MatchScrutinee r0
  0012    | MatchType r0 num_or_codepoint
  0015    | MatchBound r0 lo s1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | ConditionalThen 26 -> 34
  0029    | GetLocalMove l0
  0031    | Jump 31 -> 36
  0034    | GetLocalMove l1
  0036    | End
  ========================================
  
  ===============1:Num.Min================
  Num.Min(A, B) = A -> ..B ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 26
  0006    | MatchWindowEnter 2 fail->24
  0010    | MatchScrutinee r0
  0012    | MatchType r0 num_or_codepoint
  0015    | MatchBound r0 hi s1
  0021    | Jump 21 -> 25
  0024    | MatchFail
  0025    | MatchWindowExit
  0026    | ConditionalThen 26 -> 34
  0029    | GetLocalMove l0
  0031    | Jump 31 -> 36
  0034    | GetLocalMove l1
  0036    | End
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
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l1 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 40
  0024    | GetConstant 4: _Num.FromBinaryDigits
  0026    | GetLocalMove l0
  0028    | GetLocalMove l1
  0030    | JumpIfFailure 30 -> 36
  0033    | PushNegInteger -1
  0035    | Merge
  0036    | PushInteger 0
  0038    | CallTailFunction 3
  0040    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 118
  0047    | GetLocal l3
  0049    | JumpIfFailure 49 -> 78
  0052    | MatchWindowEnter 2 fail->76
  0056    | MatchScrutinee r0
  0058    | MatchType r0 num_or_codepoint
  0061    | MatchBound r0 lo 0
  0067    | MatchBound r0 hi 1
  0073    | Jump 73 -> 77
  0076    | MatchFail
  0077    | MatchWindowExit
  0078    | TakeRight 78 -> 115
  0081    | GetConstant 4: _Num.FromBinaryDigits
  0083    | GetLocalMove l4
  0085    | GetLocal l1
  0087    | JumpIfFailure 87 -> 93
  0090    | PushNegInteger -1
  0092    | Merge
  0093    | GetLocalMove l2
  0095    | JumpIfFailure 95 -> 113
  0098    | GetConstant 6: @Multiply
  0100    | GetLocalMove l3
  0102    | GetConstant 7: @Power
  0104    | PushInteger 2
  0106    | GetLocalMove l1
  0108    | CallFunction 2
  0110    | CallFunction 2
  0112    | Merge
  0113    | CallTailFunction 3
  0115    | Jump 115 -> 120
  0118    | GetLocalMove l2
  0120    | End
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
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l1 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 40
  0024    | GetConstant 8: _Num.FromOctalDigits
  0026    | GetLocalMove l0
  0028    | GetLocalMove l1
  0030    | JumpIfFailure 30 -> 36
  0033    | PushNegInteger -1
  0035    | Merge
  0036    | PushInteger 0
  0038    | CallTailFunction 3
  0040    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4 fail->42
  0014    | MatchScrutinee r0
  0016    | MatchType r0 array
  0019    | MatchCount r0 >=1
  0023    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 118
  0047    | GetLocal l3
  0049    | JumpIfFailure 49 -> 78
  0052    | MatchWindowEnter 2 fail->76
  0056    | MatchScrutinee r0
  0058    | MatchType r0 num_or_codepoint
  0061    | MatchBound r0 lo 0
  0067    | MatchBound r0 hi 7
  0073    | Jump 73 -> 77
  0076    | MatchFail
  0077    | MatchWindowExit
  0078    | TakeRight 78 -> 115
  0081    | GetConstant 8: _Num.FromOctalDigits
  0083    | GetLocalMove l4
  0085    | GetLocal l1
  0087    | JumpIfFailure 87 -> 93
  0090    | PushNegInteger -1
  0092    | Merge
  0093    | GetLocalMove l2
  0095    | JumpIfFailure 95 -> 113
  0098    | GetConstant 6: @Multiply
  0100    | GetLocalMove l3
  0102    | GetConstant 7: @Power
  0104    | PushInteger 8
  0106    | GetLocalMove l1
  0108    | CallFunction 2
  0110    | CallFunction 2
  0112    | Merge
  0113    | CallTailFunction 3
  0115    | Jump 115 -> 120
  0118    | GetLocalMove l2
  0120    | End
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
  0008    | JumpIfFailure 8 -> 21
  0011    | MatchWindowEnter 2 fail->20
  0015    | MatchScrutinee r0
  0017    | MatchBind l1 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 40
  0024    | GetConstant 10: _Num.FromHexDigits
  0026    | GetLocalMove l0
  0028    | GetLocalMove l1
  0030    | JumpIfFailure 30 -> 36
  0033    | PushNegInteger -1
  0035    | Merge
  0036    | PushInteger 0
  0038    | CallTailFunction 3
  0040    | End
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
  0008    | JumpIfFailure 8 -> 45
  0011    | MatchWindowEnter 4 fail->43
  0015    | MatchScrutinee r0
  0017    | MatchType r0 array
  0020    | MatchCount r0 >=1
  0024    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 119
  0048    | GetLocal l3
  0050    | JumpIfFailure 50 -> 79
  0053    | MatchWindowEnter 2 fail->77
  0057    | MatchScrutinee r0
  0059    | MatchType r0 num_or_codepoint
  0062    | MatchBound r0 lo 0
  0068    | MatchBound r0 hi 15
  0074    | Jump 74 -> 78
  0077    | MatchFail
  0078    | MatchWindowExit
  0079    | TakeRight 79 -> 116
  0082    | GetConstant 10: _Num.FromHexDigits
  0084    | GetLocalMove l4
  0086    | GetLocal l1
  0088    | JumpIfFailure 88 -> 94
  0091    | PushNegInteger -1
  0093    | Merge
  0094    | GetLocalMove l2
  0096    | JumpIfFailure 96 -> 114
  0099    | GetConstant 6: @Multiply
  0101    | GetLocalMove l3
  0103    | GetConstant 7: @Power
  0105    | PushInteger 16
  0107    | GetLocalMove l1
  0109    | CallFunction 2
  0111    | CallFunction 2
  0113    | Merge
  0114    | CallTailFunction 3
  0116    | Jump 116 -> 121
  0119    | GetLocalMove l2
  0121    | End
  ========================================
  
  =============2:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushVar L
  0002    | GetLocalMove l0
  0004    | JumpIfFailure 4 -> 29
  0007    | MatchWindowEnter 5 fail->27
  0011    | MatchScrutinee r0
  0013    | MatchType r0 array
  0016    | MatchRepeatInit r0 /1 n=r2 base=r3
  0021    | MatchBind l1 r2
  0024    | Jump 24 -> 28
  0027    | MatchFail
  0028    | MatchWindowExit
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l1
  0034    | End
  ========================================
