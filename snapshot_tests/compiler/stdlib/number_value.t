  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number_value.possum -i '' --no-stdlib
  
  =================0:@Add=================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 1: addNative
  0006    | End
  ========================================
  
  ==============0:@Subtract===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 3: subtractNative
  0006    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 5: multiplyNative
  0006    | End
  ========================================
  
  ===============0:@Divide================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 7: divideNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 9: powerNative
  0006    | End
  ========================================
  
  ===============0:@Modulus===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 11: modulusNative
  0006    | End
  ========================================
  
  ================0:@Floor================
  0000    | GetLocal 0
  0002    | NativeCode 13: floorNative
  0004    | End
  ========================================
  
  ===============0:@Ceiling===============
  0000    | GetLocal 0
  0002    | NativeCode 15: ceilingNative
  0004    | End
  ========================================
  
  =================0:@Add=================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 1: addNative
  0006    | End
  ========================================
  
  ==============0:@Subtract===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 3: subtractNative
  0006    | End
  ========================================
  
  ==============0:@Multiply===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 5: multiplyNative
  0006    | End
  ========================================
  
  ===============0:@Divide================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 7: divideNative
  0006    | End
  ========================================
  
  ================0:@Power================
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 9: powerNative
  0006    | End
  ========================================
  
  ===============0:@Modulus===============
  0000    | GetLocal 0
  0002    | GetLocal 1
  0004    | NativeCode 11: modulusNative
  0006    | End
  ========================================
  
  ================0:@Floor================
  0000    | GetLocal 0
  0002    | NativeCode 13: floorNative
  0004    | End
  ========================================
  
  ===============0:@Ceiling===============
  0000    | GetLocal 0
  0002    | NativeCode 15: ceilingNative
  0004    | End
  ========================================
  
  ===============1:Num.Inc================
  Num.Inc(N) = @Add(N, 1)
  ========================================
  0000    | GetConstant 0: @Add
  0002    | GetLocalMove 0
  0004    | PushInteger 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============1:Num.Dec================
  Num.Dec(N) = @Subtract(N, 1)
  ========================================
  0000    | GetConstant 1: @Subtract
  0002    | GetLocalMove 0
  0004    | PushInteger 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============1:Num.Abs================
  Num.Abs(N) = N -> 0.. | -N
  ========================================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | DestructurePlan 0: 0..
  0005    | Or 5 -> 11
  0008    | GetLocalMove 0
  0010    | NegateNumber
  0011    | End
  ========================================
  
  ===============1:Num.Max================
  Num.Max(A, B) = A -> B.. ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | DestructurePlan 1: B..
  0005    | ConditionalThen 5 -> 13
  0008    | GetLocalMove 0
  0010    | Jump 10 -> 15
  0013    | GetLocalMove 1
  0015    | End
  ========================================
  
  ===============1:Num.Min================
  Num.Min(A, B) = A -> ..B ? A : B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | DestructurePlan 2: ..B
  0005    | ConditionalThen 5 -> 13
  0008    | GetLocalMove 0
  0010    | Jump 10 -> 15
  0013    | GetLocalMove 1
  0015    | End
  ========================================
  
  =========1:Num.FromBinaryDigits=========
  Num.FromBinaryDigits(Bs) =
    Array.Length(Bs) -> Len &
    _Num.FromBinaryDigits(Bs, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | GetConstant 2: Array.Length
  0004    | GetLocal 0
  0006    | CallFunction 1
  0008    | DestructurePlan 3: bind Len
  0010    | TakeRight 10 -> 29
  0013    | GetConstant 3: _Num.FromBinaryDigits
  0015    | GetLocalMove 0
  0017    | GetLocalMove 1
  0019    | JumpIfFailure 19 -> 25
  0022    | PushNegInteger -1
  0024    | Merge
  0025    | PushInteger 0
  0027    | CallTailFunction 3
  0029    | End
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 4: ([bind B] + bind Rest)
  0009    | ConditionalThen 9 -> 56
  0012    | GetLocal 3
  0014    | DestructurePlan 5: 0..1
  0016    | TakeRight 16 -> 53
  0019    | GetConstant 3: _Num.FromBinaryDigits
  0021    | GetLocalMove 4
  0023    | GetLocal 1
  0025    | JumpIfFailure 25 -> 31
  0028    | PushNegInteger -1
  0030    | Merge
  0031    | GetLocalMove 2
  0033    | JumpIfFailure 33 -> 51
  0036    | GetConstant 4: @Multiply
  0038    | GetLocalMove 3
  0040    | GetConstant 5: @Power
  0042    | PushInteger 2
  0044    | GetLocalMove 1
  0046    | CallFunction 2
  0048    | CallFunction 2
  0050    | Merge
  0051    | CallTailFunction 3
  0053    | Jump 53 -> 58
  0056    | GetLocalMove 2
  0058    | End
  ========================================
  
  =========1:Num.FromOctalDigits==========
  Num.FromOctalDigits(Os) =
    Array.Length(Os) -> Len &
    _Num.FromOctalDigits(Os, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | GetConstant 2: Array.Length
  0004    | GetLocal 0
  0006    | CallFunction 1
  0008    | DestructurePlan 6: bind Len
  0010    | TakeRight 10 -> 29
  0013    | GetConstant 6: _Num.FromOctalDigits
  0015    | GetLocalMove 0
  0017    | GetLocalMove 1
  0019    | JumpIfFailure 19 -> 25
  0022    | PushNegInteger -1
  0024    | Merge
  0025    | PushInteger 0
  0027    | CallTailFunction 3
  0029    | End
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
  0005    | GetLocalMove 0
  0007    | DestructurePlan 7: ([bind O] + bind Rest)
  0009    | ConditionalThen 9 -> 56
  0012    | GetLocal 3
  0014    | DestructurePlan 8: 0..7
  0016    | TakeRight 16 -> 53
  0019    | GetConstant 6: _Num.FromOctalDigits
  0021    | GetLocalMove 4
  0023    | GetLocal 1
  0025    | JumpIfFailure 25 -> 31
  0028    | PushNegInteger -1
  0030    | Merge
  0031    | GetLocalMove 2
  0033    | JumpIfFailure 33 -> 51
  0036    | GetConstant 4: @Multiply
  0038    | GetLocalMove 3
  0040    | GetConstant 5: @Power
  0042    | PushInteger 8
  0044    | GetLocalMove 1
  0046    | CallFunction 2
  0048    | CallFunction 2
  0050    | Merge
  0051    | CallTailFunction 3
  0053    | Jump 53 -> 58
  0056    | GetLocalMove 2
  0058    | End
  ========================================
  
  ==========1:Num.FromHexDigits===========
  Num.FromHexDigits(Hs) =
    Array.Length(Hs) -> Len &
    _Num.FromHexDigits(Hs, Len - 1, 0)
  ========================================
  0000    | PushVar Len
  0002    | GetConstant 2: Array.Length
  0004    | GetLocal 0
  0006    | CallFunction 1
  0008    | DestructurePlan 9: bind Len
  0010    | TakeRight 10 -> 29
  0013    | GetConstant 7: _Num.FromHexDigits
  0015    | GetLocalMove 0
  0017    | GetLocalMove 1
  0019    | JumpIfFailure 19 -> 25
  0022    | PushNegInteger -1
  0024    | Merge
  0025    | PushInteger 0
  0027    | CallTailFunction 3
  0029    | End
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
  0006    | GetLocalMove 0
  0008    | DestructurePlan 10: ([bind H] + bind Rest)
  0010    | ConditionalThen 10 -> 57
  0013    | GetLocal 3
  0015    | DestructurePlan 11: 0..15
  0017    | TakeRight 17 -> 54
  0020    | GetConstant 7: _Num.FromHexDigits
  0022    | GetLocalMove 4
  0024    | GetLocal 1
  0026    | JumpIfFailure 26 -> 32
  0029    | PushNegInteger -1
  0031    | Merge
  0032    | GetLocalMove 2
  0034    | JumpIfFailure 34 -> 52
  0037    | GetConstant 4: @Multiply
  0039    | GetLocalMove 3
  0041    | GetConstant 5: @Power
  0043    | PushInteger 16
  0045    | GetLocalMove 1
  0047    | CallFunction 2
  0049    | CallFunction 2
  0051    | Merge
  0052    | CallTailFunction 3
  0054    | Jump 54 -> 59
  0057    | GetLocalMove 2
  0059    | End
  ========================================
  
  =============2:Array.Length=============
  Array.Length(A) = A -> ([_] * L) & L
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushVar L
  0003    | GetLocalMove 0
  0005    | DestructurePlan 0: ([_] * bind L)
  0007    | TakeRight 7 -> 12
  0010    | GetLocalMove 2
  0012    | End
  ========================================
