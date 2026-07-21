  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/ast.possum -i '' --no-stdlib
  
  ================0:@Fail=================
  0000    | PushFail
  0001    | End
  ========================================
  
  ============0:@input.offset=============
  0000    | NativeCode 2: inputOffsetNative
  0002    | End
  ========================================
  
  =============0:@input.line==============
  0000    | NativeCode 4: inputLineNative
  0002    | End
  ========================================
  
  ==========0:@input.line_offset==========
  0000    | NativeCode 6: inputLineOffsetNative
  0002    | End
  ========================================
  
  =======1:with_operator_precedence=======
  with_operator_precedence(operand, prefix, infix, postfix) =
    _with_precedence_start(operand, prefix, infix, postfix, $0)
  ========================================
  0000    | GetConstant 0: _with_precedence_start
  0002    | GetLocalMove l0
  0004    | GetLocalMove l1
  0006    | GetLocalMove l2
  0008    | GetLocalMove l3
  0010    | PushInteger 0
  0012    | CallTailFunction 5
  0014    | End
  ========================================
  
  ========1:_with_precedence_start========
  _with_precedence_start(operand, prefix, infix, postfix, LeftBindingPower) =
    prefix -> {"power": PrefixBindingPower, ...PrefixNode} ? (
      _with_precedence_start(
        operand, prefix, infix, postfix,
        PrefixBindingPower
      ) -> Node &
      _with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        {...PrefixNode, "prefixed": Node, ..._MergePos(PrefixNode, Node)}
      )
    ) : (
      operand -> Node &
      _with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        Node
      )
    )
  ========================================
  0000    | PushVar PrefixBindingPower
  0002    | PushVar PrefixNode
  0004    | PushVar Node
  0006    | PushUnderscoreVar
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | SetInputMark
  0011    | CallFunctionLocal l1
  0013    | JumpIfFailure 13 -> 50
  0016    | MatchScrutinee r8
  0018    | MatchType r8 object -> 49
  0023    | MatchKeysMin r8 1 -> 49
  0028    | MatchKey r9 r8["power"] -> 49
  0035    | MatchBind l5 r9
  0038    | MatchObjectRest r10 r8 \ ["power"]
  0043    | MatchBind l6 r10
  0046    | Jump 46 -> 50
  0049    | MatchFail
  0050    | ConditionalThen 50 -> 126
  0053    | GetConstant 0: _with_precedence_start
  0055    | GetLocal l0
  0057    | GetLocal l1
  0059    | GetLocal l2
  0061    | GetLocal l3
  0063    | GetLocalMove l5
  0065    | CallFunction 5
  0067    | JumpIfFailure 67 -> 75
  0070    | MatchScrutinee r8
  0072    | MatchBind l7 r8
  0075    | TakeRight 75 -> 123
  0078    | GetConstant 3: _with_precedence_rest
  0080    | GetLocalMove l0
  0082    | GetLocalMove l1
  0084    | GetLocalMove l2
  0086    | GetLocalMove l3
  0088    | GetLocalMove l4
  0090    | PushEmptyObject
  0091    | JumpIfFailure 91 -> 97
  0094    | GetLocal l6
  0096    | Merge
  0097    | JumpIfFailure 97 -> 121
  0100    | GetConstantMutable 4: {_0_}
  0102    | PushString "prefixed"
  0104    | GetLocal l7
  0106    | InsertKeyVal 0
  0108    | JumpIfFailure 108 -> 120
  0111    | GetConstant 5: _MergePos
  0113    | GetLocalMove l6
  0115    | GetLocalMove l7
  0117    | CallFunction 2
  0119    | Merge
  0120    | Merge
  0121    | CallTailFunction 6
  0123    | Jump 123 -> 155
  0126    | CallFunctionLocal l0
  0128    | JumpIfFailure 128 -> 136
  0131    | MatchScrutinee r8
  0133    | MatchBind l7 r8
  0136    | TakeRight 136 -> 155
  0139    | GetConstant 3: _with_precedence_rest
  0141    | GetLocalMove l0
  0143    | GetLocalMove l1
  0145    | GetLocalMove l2
  0147    | GetLocalMove l3
  0149    | GetLocalMove l4
  0151    | GetLocalMove l7
  0153    | CallTailFunction 6
  0155    | End
  ========================================
  
  ========1:_with_precedence_rest=========
  _with_precedence_rest(operand, prefix, infix, postfix, LeftBindingPower, Node) =
    postfix -> {"power": RightBindingPower, ...PostfixNode} &
    const(Is.LessThan(LeftBindingPower, RightBindingPower)) ? (
      _with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        {...PostfixNode, "postfixed": Node, ..._MergePos(Node, PostfixNode)}
      )
    ) :
    infix -> {"power": [RightBindingPower, NextLeftBindingPower], ...InfixNode} &
    const(Is.LessThan(LeftBindingPower, RightBindingPower)) ? (
      _with_precedence_start(
        operand, prefix, infix, postfix,
        NextLeftBindingPower
      ) -> RightNode &
      _with_precedence_rest(
        operand, prefix, infix, postfix,
        LeftBindingPower,
        {...InfixNode, "left": Node, "right": RightNode, ..._MergePos(Node, RightNode)}
      )
    ) :
    const(Node)
  ========================================
  0000    | PushVar RightBindingPower
  0002    | PushVar PostfixNode
  0004    | PushVar NextLeftBindingPower
  0006    | PushVar InfixNode
  0008    | PushVar RightNode
  0010    | PushUnderscoreVar
  0011    | PushUnderscoreVar
  0012    | PushUnderscoreVar
  0013    | PushUnderscoreVar
  0014    | PushUnderscoreVar
  0015    | PushUnderscoreVar
  0016    | SetInputMark
  0017    | CallFunctionLocal l3
  0019    | JumpIfFailure 19 -> 56
  0022    | MatchScrutinee r11
  0024    | MatchType r11 object -> 55
  0029    | MatchKeysMin r11 1 -> 55
  0034    | MatchKey r12 r11["power"] -> 55
  0041    | MatchBind l6 r12
  0044    | MatchObjectRest r13 r11 \ ["power"]
  0049    | MatchBind l7 r13
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | TakeRight 56 -> 71
  0059    | GetConstant 7: const
  0061    | GetConstant 8: Is.LessThan
  0063    | GetLocal l4
  0065    | GetLocal l6
  0067    | CallFunction 2
  0069    | CallFunction 1
  0071    | ConditionalThen 71 -> 122
  0074    | GetConstant 3: _with_precedence_rest
  0076    | GetLocalMove l0
  0078    | GetLocalMove l1
  0080    | GetLocalMove l2
  0082    | GetLocalMove l3
  0084    | GetLocalMove l4
  0086    | PushEmptyObject
  0087    | JumpIfFailure 87 -> 93
  0090    | GetLocal l7
  0092    | Merge
  0093    | JumpIfFailure 93 -> 117
  0096    | GetConstantMutable 9: {_0_}
  0098    | PushString "postfixed"
  0100    | GetLocal l5
  0102    | InsertKeyVal 0
  0104    | JumpIfFailure 104 -> 116
  0107    | GetConstant 5: _MergePos
  0109    | GetLocalMove l5
  0111    | GetLocalMove l7
  0113    | CallFunction 2
  0115    | Merge
  0116    | Merge
  0117    | CallTailFunction 6
  0119    | Jump 119 -> 286
  0122    | SetInputMark
  0123    | CallFunctionLocal l2
  0125    | JumpIfFailure 125 -> 183
  0128    | MatchScrutinee r11
  0130    | MatchType r11 object -> 182
  0135    | MatchKeysMin r11 1 -> 182
  0140    | MatchKey r12 r11["power"] -> 182
  0147    | MatchType r12 array -> 182
  0152    | MatchLen r12 2 -> 182
  0157    | MatchElem r13 r12[0]
  0161    | MatchBind l6 r13
  0164    | MatchElem r14 r12[1]
  0168    | MatchBind l8 r14
  0171    | MatchObjectRest r15 r11 \ ["power"]
  0176    | MatchBind l9 r15
  0179    | Jump 179 -> 183
  0182    | MatchFail
  0183    | TakeRight 183 -> 198
  0186    | GetConstant 7: const
  0188    | GetConstant 8: Is.LessThan
  0190    | GetLocal l4
  0192    | GetLocalMove l6
  0194    | CallFunction 2
  0196    | CallFunction 1
  0198    | ConditionalThen 198 -> 280
  0201    | GetConstant 0: _with_precedence_start
  0203    | GetLocal l0
  0205    | GetLocal l1
  0207    | GetLocal l2
  0209    | GetLocal l3
  0211    | GetLocalMove l8
  0213    | CallFunction 5
  0215    | JumpIfFailure 215 -> 223
  0218    | MatchScrutinee r11
  0220    | MatchBind l10 r11
  0223    | TakeRight 223 -> 277
  0226    | GetConstant 3: _with_precedence_rest
  0228    | GetLocalMove l0
  0230    | GetLocalMove l1
  0232    | GetLocalMove l2
  0234    | GetLocalMove l3
  0236    | GetLocalMove l4
  0238    | PushEmptyObject
  0239    | JumpIfFailure 239 -> 245
  0242    | GetLocalMove l9
  0244    | Merge
  0245    | JumpIfFailure 245 -> 275
  0248    | GetConstantMutable 11: {_0_, _1_}
  0250    | PushString "left"
  0252    | GetLocal l5
  0254    | InsertKeyVal 0
  0256    | PushString "right"
  0258    | GetLocal l10
  0260    | InsertKeyVal 1
  0262    | JumpIfFailure 262 -> 274
  0265    | GetConstant 5: _MergePos
  0267    | GetLocalMove l5
  0269    | GetLocalMove l10
  0271    | CallFunction 2
  0273    | Merge
  0274    | Merge
  0275    | CallTailFunction 6
  0277    | Jump 277 -> 286
  0280    | GetConstant 7: const
  0282    | GetLocalMove l5
  0284    | CallTailFunction 1
  0286    | End
  ========================================
  
  =================1:node=================
  node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | PushVar2 Value
  0003    | PushUnderscoreVar
  0004    | PushUnderscoreVar
  0005    | CallFunctionLocal l0
  0007    | JumpIfFailure 7 -> 15
  0010    | MatchScrutinee r3
  0012    | MatchBind l2 r3
  0015    | TakeRight 15 -> 34
  0018    | GetConstantMutable 16: {_0_, _1_}
  0020    | PushString2 "type"
  0023    | GetLocalMove l1
  0025    | InsertKeyVal 0
  0027    | PushString2 "value"
  0030    | GetLocalMove l2
  0032    | InsertKeyVal 1
  0034    | End
  ========================================
  
  =============1:prefix_node==============
  prefix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 20
  0005    | GetConstantMutable 17: {_0_, _1_}
  0007    | PushString2 "type"
  0010    | GetLocalMove l1
  0012    | InsertKeyVal 0
  0014    | PushString "power"
  0016    | GetLocalMove l2
  0018    | InsertKeyVal 1
  0020    | End
  ========================================
  
  ==============1:infix_node==============
  infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    op $ {"type": Type, "power": [LeftBindingPower, RightBindingPower]}
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 28
  0005    | GetConstantMutable 18: {_0_, _1_}
  0007    | PushString2 "type"
  0010    | GetLocalMove l1
  0012    | InsertKeyVal 0
  0014    | PushString "power"
  0016    | GetConstantMutable 19: [_, _]
  0018    | GetLocalMove l2
  0020    | InsertAtIndex 0
  0022    | GetLocalMove l3
  0024    | InsertAtIndex 1
  0026    | InsertKeyVal 1
  0028    | End
  ========================================
  
  =============1:postfix_node=============
  postfix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal l0
  0002    | TakeRight 2 -> 20
  0005    | GetConstantMutable 20: {_0_, _1_}
  0007    | PushString2 "type"
  0010    | GetLocalMove l1
  0012    | InsertKeyVal 0
  0014    | PushString "power"
  0016    | GetLocalMove l2
  0018    | InsertKeyVal 1
  0020    | End
  ========================================
  
  ===========1:with_offset_pos============
  with_offset_pos(node) =
    @input.offset -> StartOffset &
    node -> Node &
    @input.offset -> EndOffset $
    {...Node, "startpos": StartOffset, "endpos": EndOffset}
  ========================================
  0000    | PushVar2 StartOffset
  0003    | PushVar Node
  0005    | PushVar2 EndOffset
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | CallFunctionConstant 21: @input.offset
  0012    | JumpIfFailure 12 -> 20
  0015    | MatchScrutinee r4
  0017    | MatchBind l1 r4
  0020    | TakeRight 20 -> 33
  0023    | CallFunctionLocal l0
  0025    | JumpIfFailure 25 -> 33
  0028    | MatchScrutinee r4
  0030    | MatchBind l2 r4
  0033    | TakeRight 33 -> 76
  0036    | CallFunctionConstant 21: @input.offset
  0038    | JumpIfFailure 38 -> 46
  0041    | MatchScrutinee r4
  0043    | MatchBind l3 r4
  0046    | TakeRight 46 -> 76
  0049    | PushEmptyObject
  0050    | JumpIfFailure 50 -> 56
  0053    | GetLocalMove l2
  0055    | Merge
  0056    | JumpIfFailure 56 -> 76
  0059    | GetConstantMutable 22: {_0_, _1_}
  0061    | PushString2 "startpos"
  0064    | GetLocalMove l1
  0066    | InsertKeyVal 0
  0068    | PushString2 "endpos"
  0071    | GetLocalMove l3
  0073    | InsertKeyVal 1
  0075    | Merge
  0076    | End
  ========================================
  
  ============1:with_line_pos=============
  with_line_pos(node) =
    @input.line -> StartLine &
    @input.line_offset -> StartLineOffset &
    node -> Node &
    @input.line -> EndLine &
    @input.line_offset -> EndLineOffset $
    {
      ...Node,
      "startpos": {"line": StartLine, "offset": StartLineOffset},
      "endpos": {"line": EndLine, "offset": EndLineOffset},
    }
  ========================================
  0000    | PushVar2 StartLine
  0003    | PushVar2 StartLineOffset
  0006    | PushVar Node
  0008    | PushVar2 EndLine
  0011    | PushVar2 EndLineOffset
  0014    | PushUnderscoreVar
  0015    | PushUnderscoreVar
  0016    | CallFunctionConstant 23: @input.line
  0018    | JumpIfFailure 18 -> 26
  0021    | MatchScrutinee r6
  0023    | MatchBind l1 r6
  0026    | TakeRight 26 -> 39
  0029    | CallFunctionConstant 24: @input.line_offset
  0031    | JumpIfFailure 31 -> 39
  0034    | MatchScrutinee r6
  0036    | MatchBind l2 r6
  0039    | TakeRight 39 -> 52
  0042    | CallFunctionLocal l0
  0044    | JumpIfFailure 44 -> 52
  0047    | MatchScrutinee r6
  0049    | MatchBind l3 r6
  0052    | TakeRight 52 -> 65
  0055    | CallFunctionConstant 23: @input.line
  0057    | JumpIfFailure 57 -> 65
  0060    | MatchScrutinee r6
  0062    | MatchBind l4 r6
  0065    | TakeRight 65 -> 136
  0068    | CallFunctionConstant 24: @input.line_offset
  0070    | JumpIfFailure 70 -> 78
  0073    | MatchScrutinee r6
  0075    | MatchBind l5 r6
  0078    | TakeRight 78 -> 136
  0081    | PushEmptyObject
  0082    | JumpIfFailure 82 -> 88
  0085    | GetLocalMove l3
  0087    | Merge
  0088    | JumpIfFailure 88 -> 136
  0091    | GetConstantMutable 25: {_0_, _1_}
  0093    | PushString2 "startpos"
  0096    | GetConstantMutable 26: {_0_, _1_}
  0098    | PushString2 "line"
  0101    | GetLocalMove l1
  0103    | InsertKeyVal 0
  0105    | PushString2 "offset"
  0108    | GetLocalMove l2
  0110    | InsertKeyVal 1
  0112    | InsertKeyVal 0
  0114    | PushString2 "endpos"
  0117    | GetConstantMutable 27: {_0_, _1_}
  0119    | PushString2 "line"
  0122    | GetLocalMove l4
  0124    | InsertKeyVal 0
  0126    | PushString2 "offset"
  0129    | GetLocalMove l5
  0131    | InsertKeyVal 1
  0133    | InsertKeyVal 1
  0135    | Merge
  0136    | End
  ========================================
  
  ==============1:_MergePos===============
  _MergePos(Left, Right) = {
    ...(Left -> {"startpos": StartPos, ..._} ? {"startpos": StartPos} : {}),
    ...(Right -> {"endpos": EndPos, ..._} ? {"endpos": EndPos} : {}),
  }
  ========================================
  0000    | PushVar2 StartPos
  0003    | PushUnderscoreVar
  0004    | PushVar2 EndPos
  0007    | PushUnderscoreVar
  0008    | PushUnderscoreVar
  0009    | PushUnderscoreVar
  0010    | PushEmptyObject
  0011    | JumpIfFailure 11 -> 63
  0014    | SetInputMark
  0015    | GetLocalMove l0
  0017    | JumpIfFailure 17 -> 46
  0020    | MatchScrutinee r5
  0022    | MatchType r5 object -> 45
  0027    | MatchKeysMin r5 1 -> 45
  0032    | MatchKey r6 r5["startpos"] -> 45
  0039    | MatchBind l2 r6
  0042    | Jump 42 -> 46
  0045    | MatchFail
  0046    | ConditionalThen 46 -> 61
  0049    | GetConstantMutable 13: {_0_}
  0051    | PushString2 "startpos"
  0054    | GetLocalMove l2
  0056    | InsertKeyVal 0
  0058    | Jump 58 -> 62
  0061    | PushEmptyObject
  0062    | Merge
  0063    | JumpIfFailure 63 -> 115
  0066    | SetInputMark
  0067    | GetLocalMove l1
  0069    | JumpIfFailure 69 -> 98
  0072    | MatchScrutinee r5
  0074    | MatchType r5 object -> 97
  0079    | MatchKeysMin r5 1 -> 97
  0084    | MatchKey r6 r5["endpos"] -> 97
  0091    | MatchBind l4 r6
  0094    | Jump 94 -> 98
  0097    | MatchFail
  0098    | ConditionalThen 98 -> 113
  0101    | GetConstantMutable 15: {_0_}
  0103    | PushString2 "endpos"
  0106    | GetLocalMove l4
  0108    | InsertKeyVal 0
  0110    | Jump 110 -> 114
  0113    | PushEmptyObject
  0114    | Merge
  0115    | End
  ========================================
  
  ================2:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove l0
  0002    | End
  ========================================
  
  =============14:Is.LessThan=============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | PushUnderscoreVar
  0001    | PushUnderscoreVar
  0002    | SetInputMark
  0003    | GetLocal l0
  0005    | JumpIfFailure 5 -> 19
  0008    | MatchScrutinee r2
  0010    | MatchSlot r2 l1 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | ConditionalThen 19 -> 27
  0022    | CallTailFunctionConstant 0: @Fail
  0024    | Jump 24 -> 48
  0027    | GetLocalMove l0
  0029    | JumpIfFailure 29 -> 48
  0032    | MatchScrutinee r2
  0034    | MatchInRange r2 ..s1 -> 47
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | End
  ========================================
