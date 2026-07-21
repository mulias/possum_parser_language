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
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r1
  0010    | MatchInRange r1 0.. -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | Or 24 -> 30
  0027    | GetLocalMove l0
  0029    | NegateNumber
  0030    | End
  ========================================
  
  ===============1:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r2
  0010    | MatchInRange r2 s1.. -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | ConditionalThen 24 -> 32
  0027    | GetLocalMove l0
  0029    | Jump 29 -> 34
  0032    | GetLocalMove l1
  0034    | End
  ========================================
  
  ===============1:Num.Min================
  Num.Min(A, B) = A -> ..B ? A : B
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 24
  0008    | MatchScrutinee r2
  0010    | MatchInRange r2 ..s1 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | ConditionalThen 24 -> 32
  0027    | GetLocalMove l0
  0029    | Jump 29 -> 34
  0032    | GetLocalMove l1
  0034    | End
  ========================================
  
  =========1:Num.FromBinaryDigits=========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | GetConstant 3: Array.Length
  0006    | GetLocal l0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 18
  0013    | MatchScrutinee r2
  0015    | MatchBind l1 r2
  0018    | TakeRight 18 -> 37
  0021    | GetConstant 4: _Num.FromBinaryDigits
  0023    | GetLocalMove l0
  0025    | GetLocalMove l1
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -1
  0032    | Merge
  0033    | PushInteger 0
  0035    | CallTailFunction 3
  0037    | End
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r5
  0016    | MatchType r5 array -> 44
  0021    | MatchLenMin r5 1 -> 44
  0026    | MatchElem r6 r5[0]
  0030    | MatchBind l3 r6
  0033    | MatchSlice r7 r5[1..^0]
  0038    | MatchBind l4 r7
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | ConditionalThen 45 -> 109
  0048    | GetLocal l3
  0050    | JumpIfFailure 50 -> 69
  0053    | MatchScrutinee r5
  0055    | MatchInRange r5 0..1 -> 68
  0065    | Jump 65 -> 69
  0068    | MatchFail
  0069    | TakeRight 69 -> 106
  0072    | GetConstant 4: _Num.FromBinaryDigits
  0074    | GetLocalMove l4
  0076    | GetLocal l1
  0078    | JumpIfFailure 78 -> 84
  0081    | PushNegInteger -1
  0083    | Merge
  0084    | GetLocalMove l2
  0086    | JumpIfFailure 86 -> 104
  0089    | GetConstant 6: @Multiply
  0091    | GetLocalMove l3
  0093    | GetConstant 7: @Power
  0095    | PushInteger 2
  0097    | GetLocalMove l1
  0099    | CallFunction 2
  0101    | CallFunction 2
  0103    | Merge
  0104    | CallTailFunction 3
  0106    | Jump 106 -> 111
  0109    | GetLocalMove l2
  0111    | End
  ========================================
  
  =========1:Num.FromOctalDigits==========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | GetConstant 3: Array.Length
  0006    | GetLocal l0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 18
  0013    | MatchScrutinee r2
  0015    | MatchBind l1 r2
  0018    | TakeRight 18 -> 37
  0021    | GetConstant 8: _Num.FromOctalDigits
  0023    | GetLocalMove l0
  0025    | GetLocalMove l1
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -1
  0032    | Merge
  0033    | PushInteger 0
  0035    | CallTailFunction 3
  0037    | End
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
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | SetInputMark
  0009    | GetLocalMove l0
  0011    | JumpIfFailure 11 -> 45
  0014    | MatchScrutinee r5
  0016    | MatchType r5 array -> 44
  0021    | MatchLenMin r5 1 -> 44
  0026    | MatchElem r6 r5[0]
  0030    | MatchBind l3 r6
  0033    | MatchSlice r7 r5[1..^0]
  0038    | MatchBind l4 r7
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | ConditionalThen 45 -> 109
  0048    | GetLocal l3
  0050    | JumpIfFailure 50 -> 69
  0053    | MatchScrutinee r5
  0055    | MatchInRange r5 0..7 -> 68
  0065    | Jump 65 -> 69
  0068    | MatchFail
  0069    | TakeRight 69 -> 106
  0072    | GetConstant 8: _Num.FromOctalDigits
  0074    | GetLocalMove l4
  0076    | GetLocal l1
  0078    | JumpIfFailure 78 -> 84
  0081    | PushNegInteger -1
  0083    | Merge
  0084    | GetLocalMove l2
  0086    | JumpIfFailure 86 -> 104
  0089    | GetConstant 6: @Multiply
  0091    | GetLocalMove l3
  0093    | GetConstant 7: @Power
  0095    | PushInteger 8
  0097    | GetLocalMove l1
  0099    | CallFunction 2
  0101    | CallFunction 2
  0103    | Merge
  0104    | CallTailFunction 3
  0106    | Jump 106 -> 111
  0109    | GetLocalMove l2
  0111    | End
  ========================================
  
  ==========1:Num.FromHexDigits===========
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | PushUnderscoreVar
  0003    | PushUnderscoreVar
  0004    | GetConstant 3: Array.Length
  0006    | GetLocal l0
  0008    | CallFunction 1
  0010    | JumpIfFailure 10 -> 18
  0013    | MatchScrutinee r2
  0015    | MatchBind l1 r2
  0018    | TakeRight 18 -> 37
  0021    | GetConstant 10: _Num.FromHexDigits
  0023    | GetLocalMove l0
  0025    | GetLocalMove l1
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -1
  0032    | Merge
  0033    | PushInteger 0
  0035    | CallTailFunction 3
  0037    | End
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
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | SetInputMark
  0010    | GetLocalMove l0
  0012    | JumpIfFailure 12 -> 46
  0015    | MatchScrutinee r5
  0017    | MatchType r5 array -> 45
  0022    | MatchLenMin r5 1 -> 45
  0027    | MatchElem r6 r5[0]
  0031    | MatchBind l3 r6
  0034    | MatchSlice r7 r5[1..^0]
  0039    | MatchBind l4 r7
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | ConditionalThen 46 -> 110
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 70
  0054    | MatchScrutinee r5
  0056    | MatchInRange r5 0..15 -> 69
  0066    | Jump 66 -> 70
  0069    | MatchFail
  0070    | TakeRight 70 -> 107
  0073    | GetConstant 10: _Num.FromHexDigits
  0075    | GetLocalMove l4
  0077    | GetLocal l1
  0079    | JumpIfFailure 79 -> 85
  0082    | PushNegInteger -1
  0084    | Merge
  0085    | GetLocalMove l2
  0087    | JumpIfFailure 87 -> 105
  0090    | GetConstant 6: @Multiply
  0092    | GetLocalMove l3
  0094    | GetConstant 7: @Power
  0096    | PushInteger 16
  0098    | GetLocalMove l1
  0100    | CallFunction 2
  0102    | CallFunction 2
  0104    | Merge
  0105    | CallTailFunction 3
  0107    | Jump 107 -> 112
  0110    | GetLocalMove l2
  0112    | End
  ========================================
  
  =============2:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar L
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | PushUnderscoreVar
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | GetLocalMove l0
  0010    | JumpIfFailure 10 -> 29
  0013    | MatchScrutinee r3
  0015    | MatchRepeatInit r3 /1 n=r5 base=r6 -> 28
  0022    | MatchBind l2 r5
  0025    | Jump 25 -> 29
  0028    | MatchFail
  0029    | TakeRight 29 -> 34
  0032    | GetLocalMove l2
  0034    | End
  ========================================
