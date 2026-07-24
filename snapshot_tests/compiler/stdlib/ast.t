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
  0009    | JumpIfFailure 9 -> 52
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 object -> 50
  0021    | MatchCount r0 >=1 -> 50
  0027    | MatchKey r1 r0["power"] -> 50
  0034    | MatchBind l5 r1
  0037    | MatchObjectRest r2 r0 \ ["power"]
  0044    | MatchBind l6 r2
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | ConditionalThen 52 -> 131
  0055    | GetConstant 0: _with_precedence_start
  0057    | GetLocal l0
  0059    | GetLocal l1
  0061    | GetLocal l2
  0063    | GetLocal l3
  0065    | GetLocalMove l5
  0067    | CallFunction 5
  0069    | JumpIfFailure 69 -> 80
  0072    | MatchWindowEnter 2
  0074    | MatchScrutinee r0
  0076    | MatchBind l7 r0
  0079    | MatchWindowExit
  0080    | TakeRight 80 -> 128
  0083    | GetConstant 3: _with_precedence_rest
  0085    | GetLocalMove l0
  0087    | GetLocalMove l1
  0089    | GetLocalMove l2
  0091    | GetLocalMove l3
  0093    | GetLocalMove l4
  0095    | PushEmptyObject
  0096    | JumpIfFailure 96 -> 102
  0099    | GetLocal l6
  0101    | Merge
  0102    | JumpIfFailure 102 -> 126
  0105    | GetConstantMutable 4: {_0_}
  0107    | PushString "prefixed"
  0109    | GetLocal l7
  0111    | InsertKeyVal 0
  0113    | JumpIfFailure 113 -> 125
  0116    | GetConstant 5: _MergePos
  0118    | GetLocalMove l6
  0120    | GetLocalMove l7
  0122    | CallFunction 2
  0124    | Merge
  0125    | Merge
  0126    | CallTailFunction 6
  0128    | Jump 128 -> 163
  0131    | CallFunctionLocal l0
  0133    | JumpIfFailure 133 -> 144
  0136    | MatchWindowEnter 2
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
  0013    | JumpIfFailure 13 -> 56
  0016    | MatchWindowEnter 4
  0018    | MatchScrutinee r0
  0020    | MatchType r0 object -> 54
  0025    | MatchCount r0 >=1 -> 54
  0031    | MatchKey r1 r0["power"] -> 54
  0038    | MatchBind l6 r1
  0041    | MatchObjectRest r2 r0 \ ["power"]
  0048    | MatchBind l7 r2
  0051    | Jump 51 -> 55
  0054    | MatchFail
  0055    | MatchWindowExit
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
  0119    | Jump 119 -> 298
  0122    | SetInputMark
  0123    | CallFunctionLocal l2
  0125    | JumpIfFailure 125 -> 192
  0128    | MatchWindowEnter 6
  0130    | MatchScrutinee r0
  0132    | MatchType r0 object -> 190
  0137    | MatchCount r0 >=1 -> 190
  0143    | MatchKey r1 r0["power"] -> 190
  0150    | MatchType r1 array -> 190
  0155    | MatchCount r1 ==2 -> 190
  0161    | MatchElem r2 r1[0]
  0166    | MatchBind l6 r2
  0169    | MatchElem r3 r1[1]
  0174    | MatchBind l8 r3
  0177    | MatchObjectRest r4 r0 \ ["power"]
  0184    | MatchBind l9 r4
  0187    | Jump 187 -> 191
  0190    | MatchFail
  0191    | MatchWindowExit
  0192    | TakeRight 192 -> 207
  0195    | GetConstant 7: const
  0197    | GetConstant 8: Is.LessThan
  0199    | GetLocal l4
  0201    | GetLocalMove l6
  0203    | CallFunction 2
  0205    | CallFunction 1
  0207    | ConditionalThen 207 -> 292
  0210    | GetConstant 0: _with_precedence_start
  0212    | GetLocal l0
  0214    | GetLocal l1
  0216    | GetLocal l2
  0218    | GetLocal l3
  0220    | GetLocalMove l8
  0222    | CallFunction 5
  0224    | JumpIfFailure 224 -> 235
  0227    | MatchWindowEnter 2
  0229    | MatchScrutinee r0
  0231    | MatchBind l10 r0
  0234    | MatchWindowExit
  0235    | TakeRight 235 -> 289
  0238    | GetConstant 3: _with_precedence_rest
  0240    | GetLocalMove l0
  0242    | GetLocalMove l1
  0244    | GetLocalMove l2
  0246    | GetLocalMove l3
  0248    | GetLocalMove l4
  0250    | PushEmptyObject
  0251    | JumpIfFailure 251 -> 257
  0254    | GetLocalMove l9
  0256    | Merge
  0257    | JumpIfFailure 257 -> 287
  0260    | GetConstantMutable 11: {_0_, _1_}
  0262    | PushString "left"
  0264    | GetLocal l5
  0266    | InsertKeyVal 0
  0268    | PushString "right"
  0270    | GetLocal l10
  0272    | InsertKeyVal 1
  0274    | JumpIfFailure 274 -> 286
  0277    | GetConstant 5: _MergePos
  0279    | GetLocalMove l5
  0281    | GetLocalMove l10
  0283    | CallFunction 2
  0285    | Merge
  0286    | Merge
  0287    | CallTailFunction 6
  0289    | Jump 289 -> 298
  0292    | GetConstant 7: const
  0294    | GetLocalMove l5
  0296    | CallTailFunction 1
  0298    | End
  ========================================
  
  =================1:node=================
  node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | PushVar2 Value
  0003    | CallFunctionLocal l0
  0005    | JumpIfFailure 5 -> 16
  0008    | MatchWindowEnter 2
  0010    | MatchScrutinee r0
  0012    | MatchBind l2 r0
  0015    | MatchWindowExit
  0016    | TakeRight 16 -> 35
  0019    | GetConstantMutable 16: {_0_, _1_}
  0021    | PushString2 "type"
  0024    | GetLocalMove l1
  0026    | InsertKeyVal 0
  0028    | PushString2 "value"
  0031    | GetLocalMove l2
  0033    | InsertKeyVal 1
  0035    | End
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
  0010    | JumpIfFailure 10 -> 21
  0013    | MatchWindowEnter 2
  0015    | MatchScrutinee r0
  0017    | MatchBind l1 r0
  0020    | MatchWindowExit
  0021    | TakeRight 21 -> 37
  0024    | CallFunctionLocal l0
  0026    | JumpIfFailure 26 -> 37
  0029    | MatchWindowEnter 2
  0031    | MatchScrutinee r0
  0033    | MatchBind l2 r0
  0036    | MatchWindowExit
  0037    | TakeRight 37 -> 83
  0040    | CallFunctionConstant 21: @input.offset
  0042    | JumpIfFailure 42 -> 53
  0045    | MatchWindowEnter 2
  0047    | MatchScrutinee r0
  0049    | MatchBind l3 r0
  0052    | MatchWindowExit
  0053    | TakeRight 53 -> 83
  0056    | PushEmptyObject
  0057    | JumpIfFailure 57 -> 63
  0060    | GetLocalMove l2
  0062    | Merge
  0063    | JumpIfFailure 63 -> 83
  0066    | GetConstantMutable 22: {_0_, _1_}
  0068    | PushString2 "startpos"
  0071    | GetLocalMove l1
  0073    | InsertKeyVal 0
  0075    | PushString2 "endpos"
  0078    | GetLocalMove l3
  0080    | InsertKeyVal 1
  0082    | Merge
  0083    | End
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
  0016    | JumpIfFailure 16 -> 27
  0019    | MatchWindowEnter 2
  0021    | MatchScrutinee r0
  0023    | MatchBind l1 r0
  0026    | MatchWindowExit
  0027    | TakeRight 27 -> 43
  0030    | CallFunctionConstant 24: @input.line_offset
  0032    | JumpIfFailure 32 -> 43
  0035    | MatchWindowEnter 2
  0037    | MatchScrutinee r0
  0039    | MatchBind l2 r0
  0042    | MatchWindowExit
  0043    | TakeRight 43 -> 59
  0046    | CallFunctionLocal l0
  0048    | JumpIfFailure 48 -> 59
  0051    | MatchWindowEnter 2
  0053    | MatchScrutinee r0
  0055    | MatchBind l3 r0
  0058    | MatchWindowExit
  0059    | TakeRight 59 -> 75
  0062    | CallFunctionConstant 23: @input.line
  0064    | JumpIfFailure 64 -> 75
  0067    | MatchWindowEnter 2
  0069    | MatchScrutinee r0
  0071    | MatchBind l4 r0
  0074    | MatchWindowExit
  0075    | TakeRight 75 -> 149
  0078    | CallFunctionConstant 24: @input.line_offset
  0080    | JumpIfFailure 80 -> 91
  0083    | MatchWindowEnter 2
  0085    | MatchScrutinee r0
  0087    | MatchBind l5 r0
  0090    | MatchWindowExit
  0091    | TakeRight 91 -> 149
  0094    | PushEmptyObject
  0095    | JumpIfFailure 95 -> 101
  0098    | GetLocalMove l3
  0100    | Merge
  0101    | JumpIfFailure 101 -> 149
  0104    | GetConstantMutable 25: {_0_, _1_}
  0106    | PushString2 "startpos"
  0109    | GetConstantMutable 26: {_0_, _1_}
  0111    | PushString2 "line"
  0114    | GetLocalMove l1
  0116    | InsertKeyVal 0
  0118    | PushString2 "offset"
  0121    | GetLocalMove l2
  0123    | InsertKeyVal 1
  0125    | InsertKeyVal 0
  0127    | PushString2 "endpos"
  0130    | GetConstantMutable 27: {_0_, _1_}
  0132    | PushString2 "line"
  0135    | GetLocalMove l4
  0137    | InsertKeyVal 0
  0139    | PushString2 "offset"
  0142    | GetLocalMove l5
  0144    | InsertKeyVal 1
  0146    | InsertKeyVal 1
  0148    | Merge
  0149    | End
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
  0007    | JumpIfFailure 7 -> 63
  0010    | SetInputMark
  0011    | GetLocalMove l0
  0013    | JumpIfFailure 13 -> 46
  0016    | MatchWindowEnter 3
  0018    | MatchScrutinee r0
  0020    | MatchType r0 object -> 44
  0025    | MatchCount r0 >=1 -> 44
  0031    | MatchKey r1 r0["startpos"] -> 44
  0038    | MatchBind l2 r1
  0041    | Jump 41 -> 45
  0044    | MatchFail
  0045    | MatchWindowExit
  0046    | ConditionalThen 46 -> 61
  0049    | GetConstantMutable 13: {_0_}
  0051    | PushString2 "startpos"
  0054    | GetLocalMove l2
  0056    | InsertKeyVal 0
  0058    | Jump 58 -> 62
  0061    | PushEmptyObject
  0062    | Merge
  0063    | JumpIfFailure 63 -> 119
  0066    | SetInputMark
  0067    | GetLocalMove l1
  0069    | JumpIfFailure 69 -> 102
  0072    | MatchWindowEnter 3
  0074    | MatchScrutinee r0
  0076    | MatchType r0 object -> 100
  0081    | MatchCount r0 >=1 -> 100
  0087    | MatchKey r1 r0["endpos"] -> 100
  0094    | MatchBind l3 r1
  0097    | Jump 97 -> 101
  0100    | MatchFail
  0101    | MatchWindowExit
  0102    | ConditionalThen 102 -> 117
  0105    | GetConstantMutable 15: {_0_}
  0107    | PushString2 "endpos"
  0110    | GetLocalMove l3
  0112    | InsertKeyVal 0
  0114    | Jump 114 -> 118
  0117    | PushEmptyObject
  0118    | Merge
  0119    | End
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
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchCmp r0 == l1 -> 20
  0017    | Jump 17 -> 21
  0020    | MatchFail
  0021    | MatchWindowExit
  0022    | ConditionalThen 22 -> 30
  0025    | CallTailFunctionConstant 0: @Fail
  0027    | Jump 27 -> 57
  0030    | GetLocalMove l0
  0032    | JumpIfFailure 32 -> 57
  0035    | MatchWindowEnter 2
  0037    | MatchScrutinee r0
  0039    | MatchType r0 num_or_codepoint -> 55
  0044    | MatchBound r0 hi s1 -> 55
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | MatchWindowExit
  0057    | End
  ========================================
