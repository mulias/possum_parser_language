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
  0009    | JumpIfFailure 9 -> 48
  0012    | MatchWindowEnter 4 fail->46
  0016    | MatchScrutinee r0
  0018    | MatchType r0 object
  0021    | MatchCount r0 >=1
  0025    | MatchKey r1 r0["power"]
  0030    | MatchBind l5 r1
  0033    | MatchObjectRest r2 r0 \ ["power"]
  0040    | MatchBind l6 r2
  0043    | Jump 43 -> 47
  0046    | MatchFail
  0047    | MatchWindowExit
  0048    | ConditionalThen 48 -> 129
  0051    | GetConstant 0: _with_precedence_start
  0053    | GetLocal l0
  0055    | GetLocal l1
  0057    | GetLocal l2
  0059    | GetLocal l3
  0061    | GetLocalMove l5
  0063    | CallFunction 5
  0065    | JumpIfFailure 65 -> 78
  0068    | MatchWindowEnter 2 fail->77
  0072    | MatchScrutinee r0
  0074    | MatchBind l7 r0
  0077    | MatchWindowExit
  0078    | TakeRight 78 -> 126
  0081    | GetConstant 3: _with_precedence_rest
  0083    | GetLocalMove l0
  0085    | GetLocalMove l1
  0087    | GetLocalMove l2
  0089    | GetLocalMove l3
  0091    | GetLocalMove l4
  0093    | PushEmptyObject
  0094    | JumpIfFailure 94 -> 100
  0097    | GetLocal l6
  0099    | Merge
  0100    | JumpIfFailure 100 -> 124
  0103    | GetConstantMutable 4: {_0_}
  0105    | PushString "prefixed"
  0107    | GetLocal l7
  0109    | InsertKeyVal 0
  0111    | JumpIfFailure 111 -> 123
  0114    | GetConstant 5: _MergePos
  0116    | GetLocalMove l6
  0118    | GetLocalMove l7
  0120    | CallFunction 2
  0122    | Merge
  0123    | Merge
  0124    | CallTailFunction 6
  0126    | Jump 126 -> 163
  0129    | CallFunctionLocal l0
  0131    | JumpIfFailure 131 -> 144
  0134    | MatchWindowEnter 2 fail->143
  0138    | MatchScrutinee r0
  0140    | MatchBind l7 r0
  0143    | MatchWindowExit
  0144    | TakeRight 144 -> 163
  0147    | GetConstant 3: _with_precedence_rest
  0149    | GetLocalMove l0
  0151    | GetLocalMove l1
  0153    | GetLocalMove l2
  0155    | GetLocalMove l3
  0157    | GetLocalMove l4
  0159    | GetLocalMove l7
  0161    | CallTailFunction 6
  0163    | End
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
  0013    | JumpIfFailure 13 -> 52
  0016    | MatchWindowEnter 4 fail->50
  0020    | MatchScrutinee r0
  0022    | MatchType r0 object
  0025    | MatchCount r0 >=1
  0029    | MatchKey r1 r0["power"]
  0034    | MatchBind l6 r1
  0037    | MatchObjectRest r2 r0 \ ["power"]
  0044    | MatchBind l7 r2
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | TakeRight 52 -> 67
  0055    | GetConstant 7: const
  0057    | GetConstant 8: Is.LessThan
  0059    | GetLocal l4
  0061    | GetLocal l6
  0063    | CallFunction 2
  0065    | CallFunction 1
  0067    | ConditionalThen 67 -> 118
  0070    | GetConstant 3: _with_precedence_rest
  0072    | GetLocalMove l0
  0074    | GetLocalMove l1
  0076    | GetLocalMove l2
  0078    | GetLocalMove l3
  0080    | GetLocalMove l4
  0082    | PushEmptyObject
  0083    | JumpIfFailure 83 -> 89
  0086    | GetLocal l7
  0088    | Merge
  0089    | JumpIfFailure 89 -> 113
  0092    | GetConstantMutable 9: {_0_}
  0094    | PushString "postfixed"
  0096    | GetLocal l5
  0098    | InsertKeyVal 0
  0100    | JumpIfFailure 100 -> 112
  0103    | GetConstant 5: _MergePos
  0105    | GetLocalMove l5
  0107    | GetLocalMove l7
  0109    | CallFunction 2
  0111    | Merge
  0112    | Merge
  0113    | CallTailFunction 6
  0115    | Jump 115 -> 288
  0118    | SetInputMark
  0119    | CallFunctionLocal l2
  0121    | JumpIfFailure 121 -> 180
  0124    | MatchWindowEnter 6 fail->178
  0128    | MatchScrutinee r0
  0130    | MatchType r0 object
  0133    | MatchCount r0 >=1
  0137    | MatchKey r1 r0["power"]
  0142    | MatchType r1 array
  0145    | MatchCount r1 ==2
  0149    | MatchElem r2 r1[0]
  0154    | MatchBind l6 r2
  0157    | MatchElem r3 r1[1]
  0162    | MatchBind l8 r3
  0165    | MatchObjectRest r4 r0 \ ["power"]
  0172    | MatchBind l9 r4
  0175    | Jump 175 -> 179
  0178    | MatchFail
  0179    | MatchWindowExit
  0180    | TakeRight 180 -> 195
  0183    | GetConstant 7: const
  0185    | GetConstant 8: Is.LessThan
  0187    | GetLocal l4
  0189    | GetLocalMove l6
  0191    | CallFunction 2
  0193    | CallFunction 1
  0195    | ConditionalThen 195 -> 282
  0198    | GetConstant 0: _with_precedence_start
  0200    | GetLocal l0
  0202    | GetLocal l1
  0204    | GetLocal l2
  0206    | GetLocal l3
  0208    | GetLocalMove l8
  0210    | CallFunction 5
  0212    | JumpIfFailure 212 -> 225
  0215    | MatchWindowEnter 2 fail->224
  0219    | MatchScrutinee r0
  0221    | MatchBind l10 r0
  0224    | MatchWindowExit
  0225    | TakeRight 225 -> 279
  0228    | GetConstant 3: _with_precedence_rest
  0230    | GetLocalMove l0
  0232    | GetLocalMove l1
  0234    | GetLocalMove l2
  0236    | GetLocalMove l3
  0238    | GetLocalMove l4
  0240    | PushEmptyObject
  0241    | JumpIfFailure 241 -> 247
  0244    | GetLocalMove l9
  0246    | Merge
  0247    | JumpIfFailure 247 -> 277
  0250    | GetConstantMutable 11: {_0_, _1_}
  0252    | PushString "left"
  0254    | GetLocal l5
  0256    | InsertKeyVal 0
  0258    | PushString "right"
  0260    | GetLocal l10
  0262    | InsertKeyVal 1
  0264    | JumpIfFailure 264 -> 276
  0267    | GetConstant 5: _MergePos
  0269    | GetLocalMove l5
  0271    | GetLocalMove l10
  0273    | CallFunction 2
  0275    | Merge
  0276    | Merge
  0277    | CallTailFunction 6
  0279    | Jump 279 -> 288
  0282    | GetConstant 7: const
  0284    | GetLocalMove l5
  0286    | CallTailFunction 1
  0288    | End
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
