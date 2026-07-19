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
  0006    | SetInputMark
  0007    | CallFunctionLocal l1
  0009    | JumpIfFailure 9 -> 46
  0012    | MatchWindowEnter 4 fail->44
  0016    | MatchScrutinee r0
  0018    | MatchType r0 object
  0021    | MatchCount r0 >=1
  0025    | MatchKey r1 r0["power"]
  0030    | MatchBind l5 r1
  0033    | MatchObjectRest r2 r0 \ ["power"]
  0038    | MatchBind l6 r2
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 127
  0049    | GetConstant 0: _with_precedence_start
  0051    | GetLocal l0
  0053    | GetLocal l1
  0055    | GetLocal l2
  0057    | GetLocal l3
  0059    | GetLocalMove l5
  0061    | CallFunction 5
  0063    | JumpIfFailure 63 -> 76
  0066    | MatchWindowEnter 2 fail->75
  0070    | MatchScrutinee r0
  0072    | MatchBind l7 r0
  0075    | MatchWindowExit
  0076    | TakeRight 76 -> 124
  0079    | GetConstant 3: _with_precedence_rest
  0081    | GetLocalMove l0
  0083    | GetLocalMove l1
  0085    | GetLocalMove l2
  0087    | GetLocalMove l3
  0089    | GetLocalMove l4
  0091    | PushEmptyObject
  0092    | JumpIfFailure 92 -> 98
  0095    | GetLocal l6
  0097    | Merge
  0098    | JumpIfFailure 98 -> 122
  0101    | GetConstantMutable 4: {_0_}
  0103    | PushString "prefixed"
  0105    | GetLocal l7
  0107    | InsertKeyVal 0
  0109    | JumpIfFailure 109 -> 121
  0112    | GetConstant 5: _MergePos
  0114    | GetLocalMove l6
  0116    | GetLocalMove l7
  0118    | CallFunction 2
  0120    | Merge
  0121    | Merge
  0122    | CallTailFunction 6
  0124    | Jump 124 -> 161
  0127    | CallFunctionLocal l0
  0129    | JumpIfFailure 129 -> 142
  0132    | MatchWindowEnter 2 fail->141
  0136    | MatchScrutinee r0
  0138    | MatchBind l7 r0
  0141    | MatchWindowExit
  0142    | TakeRight 142 -> 161
  0145    | GetConstant 3: _with_precedence_rest
  0147    | GetLocalMove l0
  0149    | GetLocalMove l1
  0151    | GetLocalMove l2
  0153    | GetLocalMove l3
  0155    | GetLocalMove l4
  0157    | GetLocalMove l7
  0159    | CallTailFunction 6
  0161    | End
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
  0010    | SetInputMark
  0011    | CallFunctionLocal l3
  0013    | JumpIfFailure 13 -> 50
  0016    | MatchWindowEnter 4 fail->48
  0020    | MatchScrutinee r0
  0022    | MatchType r0 object
  0025    | MatchCount r0 >=1
  0029    | MatchKey r1 r0["power"]
  0034    | MatchBind l6 r1
  0037    | MatchObjectRest r2 r0 \ ["power"]
  0042    | MatchBind l7 r2
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | TakeRight 50 -> 65
  0053    | GetConstant 7: const
  0055    | GetConstant 8: Is.LessThan
  0057    | GetLocal l4
  0059    | GetLocal l6
  0061    | CallFunction 2
  0063    | CallFunction 1
  0065    | ConditionalThen 65 -> 116
  0068    | GetConstant 3: _with_precedence_rest
  0070    | GetLocalMove l0
  0072    | GetLocalMove l1
  0074    | GetLocalMove l2
  0076    | GetLocalMove l3
  0078    | GetLocalMove l4
  0080    | PushEmptyObject
  0081    | JumpIfFailure 81 -> 87
  0084    | GetLocal l7
  0086    | Merge
  0087    | JumpIfFailure 87 -> 111
  0090    | GetConstantMutable 9: {_0_}
  0092    | PushString "postfixed"
  0094    | GetLocal l5
  0096    | InsertKeyVal 0
  0098    | JumpIfFailure 98 -> 110
  0101    | GetConstant 5: _MergePos
  0103    | GetLocalMove l5
  0105    | GetLocalMove l7
  0107    | CallFunction 2
  0109    | Merge
  0110    | Merge
  0111    | CallTailFunction 6
  0113    | Jump 113 -> 284
  0116    | SetInputMark
  0117    | CallFunctionLocal l2
  0119    | JumpIfFailure 119 -> 176
  0122    | MatchWindowEnter 6 fail->174
  0126    | MatchScrutinee r0
  0128    | MatchType r0 object
  0131    | MatchCount r0 >=1
  0135    | MatchKey r1 r0["power"]
  0140    | MatchType r1 array
  0143    | MatchCount r1 ==2
  0147    | MatchElem r2 r1[0]
  0152    | MatchBind l6 r2
  0155    | MatchElem r3 r1[1]
  0160    | MatchBind l8 r3
  0163    | MatchObjectRest r4 r0 \ ["power"]
  0168    | MatchBind l9 r4
  0171    | Jump 171 -> 175
  0174    | MatchFail
  0175    | MatchWindowExit
  0176    | TakeRight 176 -> 191
  0179    | GetConstant 7: const
  0181    | GetConstant 8: Is.LessThan
  0183    | GetLocal l4
  0185    | GetLocalMove l6
  0187    | CallFunction 2
  0189    | CallFunction 1
  0191    | ConditionalThen 191 -> 278
  0194    | GetConstant 0: _with_precedence_start
  0196    | GetLocal l0
  0198    | GetLocal l1
  0200    | GetLocal l2
  0202    | GetLocal l3
  0204    | GetLocalMove l8
  0206    | CallFunction 5
  0208    | JumpIfFailure 208 -> 221
  0211    | MatchWindowEnter 2 fail->220
  0215    | MatchScrutinee r0
  0217    | MatchBind l10 r0
  0220    | MatchWindowExit
  0221    | TakeRight 221 -> 275
  0224    | GetConstant 3: _with_precedence_rest
  0226    | GetLocalMove l0
  0228    | GetLocalMove l1
  0230    | GetLocalMove l2
  0232    | GetLocalMove l3
  0234    | GetLocalMove l4
  0236    | PushEmptyObject
  0237    | JumpIfFailure 237 -> 243
  0240    | GetLocalMove l9
  0242    | Merge
  0243    | JumpIfFailure 243 -> 273
  0246    | GetConstantMutable 11: {_0_, _1_}
  0248    | PushString "left"
  0250    | GetLocal l5
  0252    | InsertKeyVal 0
  0254    | PushString "right"
  0256    | GetLocal l10
  0258    | InsertKeyVal 1
  0260    | JumpIfFailure 260 -> 272
  0263    | GetConstant 5: _MergePos
  0265    | GetLocalMove l5
  0267    | GetLocalMove l10
  0269    | CallFunction 2
  0271    | Merge
  0272    | Merge
  0273    | CallTailFunction 6
  0275    | Jump 275 -> 284
  0278    | GetConstant 7: const
  0280    | GetLocalMove l5
  0282    | CallTailFunction 1
  0284    | End
  ========================================
  
  =================1:node=================
  node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | PushVar2 Value
  0003    | CallFunctionLocal l0
  0005    | JumpIfFailure 5 -> 18
  0008    | MatchWindowEnter 2 fail->17
  0012    | MatchScrutinee r0
  0014    | MatchBind l2 r0
  0017    | MatchWindowExit
  0018    | TakeRight 18 -> 37
  0021    | GetConstantMutable 16: {_0_, _1_}
  0023    | PushString2 "type"
  0026    | GetLocalMove l1
  0028    | InsertKeyVal 0
  0030    | PushString2 "value"
  0033    | GetLocalMove l2
  0035    | InsertKeyVal 1
  0037    | End
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
  0008    | CallFunctionConstant 21: @input.offset
  0010    | JumpIfFailure 10 -> 23
  0013    | MatchWindowEnter 2 fail->22
  0017    | MatchScrutinee r0
  0019    | MatchBind l1 r0
  0022    | MatchWindowExit
  0023    | TakeRight 23 -> 41
  0026    | CallFunctionLocal l0
  0028    | JumpIfFailure 28 -> 41
  0031    | MatchWindowEnter 2 fail->40
  0035    | MatchScrutinee r0
  0037    | MatchBind l2 r0
  0040    | MatchWindowExit
  0041    | TakeRight 41 -> 89
  0044    | CallFunctionConstant 21: @input.offset
  0046    | JumpIfFailure 46 -> 59
  0049    | MatchWindowEnter 2 fail->58
  0053    | MatchScrutinee r0
  0055    | MatchBind l3 r0
  0058    | MatchWindowExit
  0059    | TakeRight 59 -> 89
  0062    | PushEmptyObject
  0063    | JumpIfFailure 63 -> 69
  0066    | GetLocalMove l2
  0068    | Merge
  0069    | JumpIfFailure 69 -> 89
  0072    | GetConstantMutable 22: {_0_, _1_}
  0074    | PushString2 "startpos"
  0077    | GetLocalMove l1
  0079    | InsertKeyVal 0
  0081    | PushString2 "endpos"
  0084    | GetLocalMove l3
  0086    | InsertKeyVal 1
  0088    | Merge
  0089    | End
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
  0014    | CallFunctionConstant 23: @input.line
  0016    | JumpIfFailure 16 -> 29
  0019    | MatchWindowEnter 2 fail->28
  0023    | MatchScrutinee r0
  0025    | MatchBind l1 r0
  0028    | MatchWindowExit
  0029    | TakeRight 29 -> 47
  0032    | CallFunctionConstant 24: @input.line_offset
  0034    | JumpIfFailure 34 -> 47
  0037    | MatchWindowEnter 2 fail->46
  0041    | MatchScrutinee r0
  0043    | MatchBind l2 r0
  0046    | MatchWindowExit
  0047    | TakeRight 47 -> 65
  0050    | CallFunctionLocal l0
  0052    | JumpIfFailure 52 -> 65
  0055    | MatchWindowEnter 2 fail->64
  0059    | MatchScrutinee r0
  0061    | MatchBind l3 r0
  0064    | MatchWindowExit
  0065    | TakeRight 65 -> 83
  0068    | CallFunctionConstant 23: @input.line
  0070    | JumpIfFailure 70 -> 83
  0073    | MatchWindowEnter 2 fail->82
  0077    | MatchScrutinee r0
  0079    | MatchBind l4 r0
  0082    | MatchWindowExit
  0083    | TakeRight 83 -> 159
  0086    | CallFunctionConstant 24: @input.line_offset
  0088    | JumpIfFailure 88 -> 101
  0091    | MatchWindowEnter 2 fail->100
  0095    | MatchScrutinee r0
  0097    | MatchBind l5 r0
  0100    | MatchWindowExit
  0101    | TakeRight 101 -> 159
  0104    | PushEmptyObject
  0105    | JumpIfFailure 105 -> 111
  0108    | GetLocalMove l3
  0110    | Merge
  0111    | JumpIfFailure 111 -> 159
  0114    | GetConstantMutable 25: {_0_, _1_}
  0116    | PushString2 "startpos"
  0119    | GetConstantMutable 26: {_0_, _1_}
  0121    | PushString2 "line"
  0124    | GetLocalMove l1
  0126    | InsertKeyVal 0
  0128    | PushString2 "offset"
  0131    | GetLocalMove l2
  0133    | InsertKeyVal 1
  0135    | InsertKeyVal 0
  0137    | PushString2 "endpos"
  0140    | GetConstantMutable 27: {_0_, _1_}
  0142    | PushString2 "line"
  0145    | GetLocalMove l4
  0147    | InsertKeyVal 0
  0149    | PushString2 "offset"
  0152    | GetLocalMove l5
  0154    | InsertKeyVal 1
  0156    | InsertKeyVal 1
  0158    | Merge
  0159    | End
  ========================================
  
  ==============1:_MergePos===============
  _MergePos(Left, Right) = {
    ...(Left -> {"startpos": StartPos, ..._} ? {"startpos": StartPos} : {}),
    ...(Right -> {"endpos": EndPos, ..._} ? {"endpos": EndPos} : {}),
  }
  ========================================
  0000    | PushVar2 StartPos
  0003    | PushVar2 EndPos
  0006    | PushEmptyObject
  0007    | JumpIfFailure 7 -> 59
  0010    | SetInputMark
  0011    | GetLocalMove l0
  0013    | JumpIfFailure 13 -> 42
  0016    | MatchWindowEnter 3 fail->40
  0020    | MatchScrutinee r0
  0022    | MatchType r0 object
  0025    | MatchCount r0 >=1
  0029    | MatchKey r1 r0["startpos"]
  0034    | MatchBind l2 r1
  0037    | Jump 37 -> 41
  0040    | MatchFail
  0041    | MatchWindowExit
  0042    | ConditionalThen 42 -> 57
  0045    | GetConstantMutable 13: {_0_}
  0047    | PushString2 "startpos"
  0050    | GetLocalMove l2
  0052    | InsertKeyVal 0
  0054    | Jump 54 -> 58
  0057    | PushEmptyObject
  0058    | Merge
  0059    | JumpIfFailure 59 -> 111
  0062    | SetInputMark
  0063    | GetLocalMove l1
  0065    | JumpIfFailure 65 -> 94
  0068    | MatchWindowEnter 3 fail->92
  0072    | MatchScrutinee r0
  0074    | MatchType r0 object
  0077    | MatchCount r0 >=1
  0081    | MatchKey r1 r0["endpos"]
  0086    | MatchBind l3 r1
  0089    | Jump 89 -> 93
  0092    | MatchFail
  0093    | MatchWindowExit
  0094    | ConditionalThen 94 -> 109
  0097    | GetConstantMutable 15: {_0_}
  0099    | PushString2 "endpos"
  0102    | GetLocalMove l3
  0104    | InsertKeyVal 0
  0106    | Jump 106 -> 110
  0109    | PushEmptyObject
  0110    | Merge
  0111    | End
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
  0000    | SetInputMark
  0001    | GetLocal l0
  0003    | JumpIfFailure 3 -> 22
  0006    | MatchWindowEnter 2 fail->20
  0010    | MatchScrutinee r0
  0012    | MatchCmp r0 == l1
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | ConditionalThen 22 -> 30
  0025    | CallTailFunctionConstant 0: @Fail
  0027    | Jump 27 -> 55
  0030    | GetLocalMove l0
  0032    | JumpIfFailure 32 -> 55
  0035    | MatchWindowEnter 2 fail->53
  0039    | MatchScrutinee r0
  0041    | MatchType r0 num_or_codepoint
  0044    | MatchBound r0 hi s1
  0050    | Jump 50 -> 54
  0053    | MatchFail
  0054    | MatchWindowExit
  0055    | End
  ========================================
