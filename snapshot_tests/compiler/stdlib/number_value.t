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
  0003    | JumpIfFailure 3 -> 25
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchInRange r0 0.. -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | Or 25 -> 31
  0028    | GetLocalMove l0
  0030    | NegateNumber
  0031    | End
  ========================================
  
  ===============1:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 25
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchInRange r0 s1.. -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | ConditionalThen 25 -> 33
  0028    | GetLocalMove l0
  0030    | Jump 30 -> 35
  0033    | GetLocalMove l1
  0035    | End
  ========================================
  
  ===============1:Num.Min================
  Num.Min(A, B) = A -> ..B ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 25
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchInRange r0 ..s1 -> 23
  0020    | Jump 20 -> 24
  0023    | MatchFail
  0024    | MatchWindowExit
  0025    | ConditionalThen 25 -> 33
  0028    | GetLocalMove l0
  0030    | Jump 30 -> 35
  0033    | GetLocalMove l1
  0035    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 111
  0047    | GetLocal l3
  0049    | JumpIfFailure 49 -> 71
  0052    | MatchWindowEnter 2
  0054    | MatchScrutinee r0
  0056    | MatchInRange r0 0..1 -> 69
  0066    | Jump 66 -> 70
  0069    | MatchFail
  0070    | MatchWindowExit
  0071    | TakeRight 71 -> 108
  0074    | GetConstant 4: _Num.FromBinaryDigits
  0076    | GetLocalMove l4
  0078    | GetLocal l1
  0080    | JumpIfFailure 80 -> 86
  0083    | PushNegInteger -1
  0085    | Merge
  0086    | GetLocalMove l2
  0088    | JumpIfFailure 88 -> 106
  0091    | GetConstant 6: @Multiply
  0093    | GetLocalMove l3
  0095    | GetConstant 7: @Power
  0097    | PushInteger 2
  0099    | GetLocalMove l1
  0101    | CallFunction 2
  0103    | CallFunction 2
  0105    | Merge
  0106    | CallTailFunction 3
  0108    | Jump 108 -> 113
  0111    | GetLocalMove l2
  0113    | End
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
  0007    | JumpIfFailure 7 -> 44
  0010    | MatchWindowEnter 4
  0012    | MatchScrutinee r0
  0014    | MatchType r0 array -> 42
  0019    | MatchLenMin r0 1 -> 42
  0024    | MatchElem r1 r0[0]
  0028    | MatchBind l3 r1
  0031    | MatchSlice r2 r0[1..^0]
  0036    | MatchBind l4 r2
  0039    | Jump 39 -> 43
  0042    | MatchFail
  0043    | MatchWindowExit
  0044    | ConditionalThen 44 -> 111
  0047    | GetLocal l3
  0049    | JumpIfFailure 49 -> 71
  0052    | MatchWindowEnter 2
  0054    | MatchScrutinee r0
  0056    | MatchInRange r0 0..7 -> 69
  0066    | Jump 66 -> 70
  0069    | MatchFail
  0070    | MatchWindowExit
  0071    | TakeRight 71 -> 108
  0074    | GetConstant 8: _Num.FromOctalDigits
  0076    | GetLocalMove l4
  0078    | GetLocal l1
  0080    | JumpIfFailure 80 -> 86
  0083    | PushNegInteger -1
  0085    | Merge
  0086    | GetLocalMove l2
  0088    | JumpIfFailure 88 -> 106
  0091    | GetConstant 6: @Multiply
  0093    | GetLocalMove l3
  0095    | GetConstant 7: @Power
  0097    | PushInteger 8
  0099    | GetLocalMove l1
  0101    | CallFunction 2
  0103    | CallFunction 2
  0105    | Merge
  0106    | CallTailFunction 3
  0108    | Jump 108 -> 113
  0111    | GetLocalMove l2
  0113    | End
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
  0008    | JumpIfFailure 8 -> 45
  0011    | MatchWindowEnter 4
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 43
  0020    | MatchLenMin r0 1 -> 43
  0025    | MatchElem r1 r0[0]
  0029    | MatchBind l3 r1
  0032    | MatchSlice r2 r0[1..^0]
  0037    | MatchBind l4 r2
  0040    | Jump 40 -> 44
  0043    | MatchFail
  0044    | MatchWindowExit
  0045    | ConditionalThen 45 -> 112
  0048    | GetLocal l3
  0050    | JumpIfFailure 50 -> 72
  0053    | MatchWindowEnter 2
  0055    | MatchScrutinee r0
  0057    | MatchInRange r0 0..15 -> 70
  0067    | Jump 67 -> 71
  0070    | MatchFail
  0071    | MatchWindowExit
  0072    | TakeRight 72 -> 109
  0075    | GetConstant 10: _Num.FromHexDigits
  0077    | GetLocalMove l4
  0079    | GetLocal l1
  0081    | JumpIfFailure 81 -> 87
  0084    | PushNegInteger -1
  0086    | Merge
  0087    | GetLocalMove l2
  0089    | JumpIfFailure 89 -> 107
  0092    | GetConstant 6: @Multiply
  0094    | GetLocalMove l3
  0096    | GetConstant 7: @Power
  0098    | PushInteger 16
  0100    | GetLocalMove l1
  0102    | CallFunction 2
  0104    | CallFunction 2
  0106    | Merge
  0107    | CallTailFunction 3
  0109    | Jump 109 -> 114
  0112    | GetLocalMove l2
  0114    | End
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
