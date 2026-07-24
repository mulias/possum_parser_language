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
  0009    | JumpIfFailure 9 -> 50
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 object -> 48
  0021    | MatchCount r0 >=1 -> 48
  0027    | MatchKey r1 r0["power"] -> 48
  0034    | MatchBind l5 r1
  0037    | MatchObjectRest r2 r0 \ ["power"]
  0042    | MatchBind l6 r2
  0045    | Jump 45 -> 49
  0048    | MatchFail
  0049    | MatchWindowExit
  0050    | ConditionalThen 50 -> 129
  0053    | GetConstant 0: _with_precedence_start
  0055    | GetLocal l0
  0057    | GetLocal l1
  0059    | GetLocal l2
  0061    | GetLocal l3
  0063    | GetLocalMove l5
  0065    | CallFunction 5
  0067    | JumpIfFailure 67 -> 78
  0070    | MatchWindowEnter 2
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
  0126    | Jump 126 -> 161
  0129    | CallFunctionLocal l0
  0131    | JumpIfFailure 131 -> 142
  0134    | MatchWindowEnter 2
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
  0013    | JumpIfFailure 13 -> 54
  0016    | MatchWindowEnter 4
  0018    | MatchScrutinee r0
  0020    | MatchType r0 object -> 52
  0025    | MatchCount r0 >=1 -> 52
  0031    | MatchKey r1 r0["power"] -> 52
  0038    | MatchBind l6 r1
  0041    | MatchObjectRest r2 r0 \ ["power"]
  0046    | MatchBind l7 r2
  0049    | Jump 49 -> 53
  0052    | MatchFail
  0053    | MatchWindowExit
  0054    | TakeRight 54 -> 69
  0057    | GetConstant 7: const
  0059    | GetConstant 8: Is.LessThan
  0061    | GetLocal l4
  0063    | GetLocal l6
  0065    | CallFunction 2
  0067    | CallFunction 1
  0069    | ConditionalThen 69 -> 120
  0072    | GetConstant 3: _with_precedence_rest
  0074    | GetLocalMove l0
  0076    | GetLocalMove l1
  0078    | GetLocalMove l2
  0080    | GetLocalMove l3
  0082    | GetLocalMove l4
  0084    | PushEmptyObject
  0085    | JumpIfFailure 85 -> 91
  0088    | GetLocal l7
  0090    | Merge
  0091    | JumpIfFailure 91 -> 115
  0094    | GetConstantMutable 9: {_0_}
  0096    | PushString "postfixed"
  0098    | GetLocal l5
  0100    | InsertKeyVal 0
  0102    | JumpIfFailure 102 -> 114
  0105    | GetConstant 5: _MergePos
  0107    | GetLocalMove l5
  0109    | GetLocalMove l7
  0111    | CallFunction 2
  0113    | Merge
  0114    | Merge
  0115    | CallTailFunction 6
  0117    | Jump 117 -> 294
  0120    | SetInputMark
  0121    | CallFunctionLocal l2
  0123    | JumpIfFailure 123 -> 188
  0126    | MatchWindowEnter 6
  0128    | MatchScrutinee r0
  0130    | MatchType r0 object -> 186
  0135    | MatchCount r0 >=1 -> 186
  0141    | MatchKey r1 r0["power"] -> 186
  0148    | MatchType r1 array -> 186
  0153    | MatchCount r1 ==2 -> 186
  0159    | MatchElem r2 r1[0]
  0164    | MatchBind l6 r2
  0167    | MatchElem r3 r1[1]
  0172    | MatchBind l8 r3
  0175    | MatchObjectRest r4 r0 \ ["power"]
  0180    | MatchBind l9 r4
  0183    | Jump 183 -> 187
  0186    | MatchFail
  0187    | MatchWindowExit
  0188    | TakeRight 188 -> 203
  0191    | GetConstant 7: const
  0193    | GetConstant 8: Is.LessThan
  0195    | GetLocal l4
  0197    | GetLocalMove l6
  0199    | CallFunction 2
  0201    | CallFunction 1
  0203    | ConditionalThen 203 -> 288
  0206    | GetConstant 0: _with_precedence_start
  0208    | GetLocal l0
  0210    | GetLocal l1
  0212    | GetLocal l2
  0214    | GetLocal l3
  0216    | GetLocalMove l8
  0218    | CallFunction 5
  0220    | JumpIfFailure 220 -> 231
  0223    | MatchWindowEnter 2
  0225    | MatchScrutinee r0
  0227    | MatchBind l10 r0
  0230    | MatchWindowExit
  0231    | TakeRight 231 -> 285
  0234    | GetConstant 3: _with_precedence_rest
  0236    | GetLocalMove l0
  0238    | GetLocalMove l1
  0240    | GetLocalMove l2
  0242    | GetLocalMove l3
  0244    | GetLocalMove l4
  0246    | PushEmptyObject
  0247    | JumpIfFailure 247 -> 253
  0250    | GetLocalMove l9
  0252    | Merge
  0253    | JumpIfFailure 253 -> 283
  0256    | GetConstantMutable 11: {_0_, _1_}
  0258    | PushString "left"
  0260    | GetLocal l5
  0262    | InsertKeyVal 0
  0264    | PushString "right"
  0266    | GetLocal l10
  0268    | InsertKeyVal 1
  0270    | JumpIfFailure 270 -> 282
  0273    | GetConstant 5: _MergePos
  0275    | GetLocalMove l5
  0277    | GetLocalMove l10
  0279    | CallFunction 2
  0281    | Merge
  0282    | Merge
  0283    | CallTailFunction 6
  0285    | Jump 285 -> 294
  0288    | GetConstant 7: const
  0290    | GetLocalMove l5
  0292    | CallTailFunction 1
  0294    | End
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
  0003    | JumpIfFailure 3 -> 20
  0006    | MatchWindowEnter 2
  0008    | MatchScrutinee r0
  0010    | MatchSlot r0 l1 -> 18
  0015    | Jump 15 -> 19
  0018    | MatchFail
  0019    | MatchWindowExit
  0020    | ConditionalThen 20 -> 28
  0023    | CallTailFunctionConstant 0: @Fail
  0025    | Jump 25 -> 52
  0028    | GetLocalMove l0
  0030    | JumpIfFailure 30 -> 52
  0033    | MatchWindowEnter 2
  0035    | MatchScrutinee r0
  0037    | MatchInRange r0 ..s1 -> 50
  0047    | Jump 47 -> 51
  0050    | MatchFail
  0051    | MatchWindowExit
  0052    | End
  ========================================
