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
  0046    | ConditionalThen 46 -> 113
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 73
  0054    | MatchWindowEnter 2
  0056    | MatchScrutinee r0
  0058    | MatchInRange r0 0..1 -> 71
  0068    | Jump 68 -> 72
  0071    | MatchFail
  0072    | MatchWindowExit
  0073    | TakeRight 73 -> 110
  0076    | GetConstant 4: _Num.FromBinaryDigits
  0078    | GetLocalMove l4
  0080    | GetLocal l1
  0082    | JumpIfFailure 82 -> 88
  0085    | PushNegInteger -1
  0087    | Merge
  0088    | GetLocalMove l2
  0090    | JumpIfFailure 90 -> 108
  0093    | GetConstant 6: @Multiply
  0095    | GetLocalMove l3
  0097    | GetConstant 7: @Power
  0099    | PushInteger 2
  0101    | GetLocalMove l1
  0103    | CallFunction 2
  0105    | CallFunction 2
  0107    | Merge
  0108    | CallTailFunction 3
  0110    | Jump 110 -> 115
  0113    | GetLocalMove l2
  0115    | End
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
  0046    | ConditionalThen 46 -> 113
  0049    | GetLocal l3
  0051    | JumpIfFailure 51 -> 73
  0054    | MatchWindowEnter 2
  0056    | MatchScrutinee r0
  0058    | MatchInRange r0 0..7 -> 71
  0068    | Jump 68 -> 72
  0071    | MatchFail
  0072    | MatchWindowExit
  0073    | TakeRight 73 -> 110
  0076    | GetConstant 8: _Num.FromOctalDigits
  0078    | GetLocalMove l4
  0080    | GetLocal l1
  0082    | JumpIfFailure 82 -> 88
  0085    | PushNegInteger -1
  0087    | Merge
  0088    | GetLocalMove l2
  0090    | JumpIfFailure 90 -> 108
  0093    | GetConstant 6: @Multiply
  0095    | GetLocalMove l3
  0097    | GetConstant 7: @Power
  0099    | PushInteger 8
  0101    | GetLocalMove l1
  0103    | CallFunction 2
  0105    | CallFunction 2
  0107    | Merge
  0108    | CallTailFunction 3
  0110    | Jump 110 -> 115
  0113    | GetLocalMove l2
  0115    | End
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
  0047    | ConditionalThen 47 -> 114
  0050    | GetLocal l3
  0052    | JumpIfFailure 52 -> 74
  0055    | MatchWindowEnter 2
  0057    | MatchScrutinee r0
  0059    | MatchInRange r0 0..15 -> 72
  0069    | Jump 69 -> 73
  0072    | MatchFail
  0073    | MatchWindowExit
  0074    | TakeRight 74 -> 111
  0077    | GetConstant 10: _Num.FromHexDigits
  0079    | GetLocalMove l4
  0081    | GetLocal l1
  0083    | JumpIfFailure 83 -> 89
  0086    | PushNegInteger -1
  0088    | Merge
  0089    | GetLocalMove l2
  0091    | JumpIfFailure 91 -> 109
  0094    | GetConstant 6: @Multiply
  0096    | GetLocalMove l3
  0098    | GetConstant 7: @Power
  0100    | PushInteger 16
  0102    | GetLocalMove l1
  0104    | CallFunction 2
  0106    | CallFunction 2
  0108    | Merge
  0109    | CallTailFunction 3
  0111    | Jump 111 -> 116
  0114    | GetLocalMove l2
  0116    | End
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
