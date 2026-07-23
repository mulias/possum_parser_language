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
  0009    | JumpIfFailure 9 -> 49
  0012    | MatchWindowEnter 4
  0014    | MatchScrutinee r0
  0016    | MatchType r0 object -> 47
  0021    | MatchKeysMin r0 1 -> 47
  0026    | MatchKey r1 r0["power"] -> 47
  0033    | MatchBind l5 r1
  0036    | MatchObjectRest r2 r0 \ ["power"]
  0041    | MatchBind l6 r2
  0044    | Jump 44 -> 48
  0047    | MatchFail
  0048    | MatchWindowExit
  0049    | ConditionalThen 49 -> 128
  0052    | GetConstant 0: _with_precedence_start
  0054    | GetLocal l0
  0056    | GetLocal l1
  0058    | GetLocal l2
  0060    | GetLocal l3
  0062    | GetLocalMove l5
  0064    | CallFunction 5
  0066    | JumpIfFailure 66 -> 77
  0069    | MatchWindowEnter 2
  0071    | MatchScrutinee r0
  0073    | MatchBind l7 r0
  0076    | MatchWindowExit
  0077    | TakeRight 77 -> 125
  0080    | GetConstant 3: _with_precedence_rest
  0082    | GetLocalMove l0
  0084    | GetLocalMove l1
  0086    | GetLocalMove l2
  0088    | GetLocalMove l3
  0090    | GetLocalMove l4
  0092    | PushEmptyObject
  0093    | JumpIfFailure 93 -> 99
  0096    | GetLocal l6
  0098    | Merge
  0099    | JumpIfFailure 99 -> 123
  0102    | GetConstantMutable 4: {_0_}
  0104    | PushString "prefixed"
  0106    | GetLocal l7
  0108    | InsertKeyVal 0
  0110    | JumpIfFailure 110 -> 122
  0113    | GetConstant 5: _MergePos
  0115    | GetLocalMove l6
  0117    | GetLocalMove l7
  0119    | CallFunction 2
  0121    | Merge
  0122    | Merge
  0123    | CallTailFunction 6
  0125    | Jump 125 -> 160
  0128    | CallFunctionLocal l0
  0130    | JumpIfFailure 130 -> 141
  0133    | MatchWindowEnter 2
  0135    | MatchScrutinee r0
  0137    | MatchBind l7 r0
  0140    | MatchWindowExit
  0141    | TakeRight 141 -> 160
  0144    | GetConstant 3: _with_precedence_rest
  0146    | GetLocalMove l0
  0148    | GetLocalMove l1
  0150    | GetLocalMove l2
  0152    | GetLocalMove l3
  0154    | GetLocalMove l4
  0156    | GetLocalMove l7
  0158    | CallTailFunction 6
  0160    | End
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
  0013    | JumpIfFailure 13 -> 53
  0016    | MatchWindowEnter 4
  0018    | MatchScrutinee r0
  0020    | MatchType r0 object -> 51
  0025    | MatchKeysMin r0 1 -> 51
  0030    | MatchKey r1 r0["power"] -> 51
  0037    | MatchBind l6 r1
  0040    | MatchObjectRest r2 r0 \ ["power"]
  0045    | MatchBind l7 r2
  0048    | Jump 48 -> 52
  0051    | MatchFail
  0052    | MatchWindowExit
  0053    | TakeRight 53 -> 68
  0056    | GetConstant 7: const
  0058    | GetConstant 8: Is.LessThan
  0060    | GetLocal l4
  0062    | GetLocal l6
  0064    | CallFunction 2
  0066    | CallFunction 1
  0068    | ConditionalThen 68 -> 119
  0071    | GetConstant 3: _with_precedence_rest
  0073    | GetLocalMove l0
  0075    | GetLocalMove l1
  0077    | GetLocalMove l2
  0079    | GetLocalMove l3
  0081    | GetLocalMove l4
  0083    | PushEmptyObject
  0084    | JumpIfFailure 84 -> 90
  0087    | GetLocal l7
  0089    | Merge
  0090    | JumpIfFailure 90 -> 114
  0093    | GetConstantMutable 9: {_0_}
  0095    | PushString "postfixed"
  0097    | GetLocal l5
  0099    | InsertKeyVal 0
  0101    | JumpIfFailure 101 -> 113
  0104    | GetConstant 5: _MergePos
  0106    | GetLocalMove l5
  0108    | GetLocalMove l7
  0110    | CallFunction 2
  0112    | Merge
  0113    | Merge
  0114    | CallTailFunction 6
  0116    | Jump 116 -> 289
  0119    | SetInputMark
  0120    | CallFunctionLocal l2
  0122    | JumpIfFailure 122 -> 183
  0125    | MatchWindowEnter 6
  0127    | MatchScrutinee r0
  0129    | MatchType r0 object -> 181
  0134    | MatchKeysMin r0 1 -> 181
  0139    | MatchKey r1 r0["power"] -> 181
  0146    | MatchType r1 array -> 181
  0151    | MatchLen r1 2 -> 181
  0156    | MatchElem r2 r1[0]
  0160    | MatchBind l6 r2
  0163    | MatchElem r3 r1[1]
  0167    | MatchBind l8 r3
  0170    | MatchObjectRest r4 r0 \ ["power"]
  0175    | MatchBind l9 r4
  0178    | Jump 178 -> 182
  0181    | MatchFail
  0182    | MatchWindowExit
  0183    | TakeRight 183 -> 198
  0186    | GetConstant 7: const
  0188    | GetConstant 8: Is.LessThan
  0190    | GetLocal l4
  0192    | GetLocalMove l6
  0194    | CallFunction 2
  0196    | CallFunction 1
  0198    | ConditionalThen 198 -> 283
  0201    | GetConstant 0: _with_precedence_start
  0203    | GetLocal l0
  0205    | GetLocal l1
  0207    | GetLocal l2
  0209    | GetLocal l3
  0211    | GetLocalMove l8
  0213    | CallFunction 5
  0215    | JumpIfFailure 215 -> 226
  0218    | MatchWindowEnter 2
  0220    | MatchScrutinee r0
  0222    | MatchBind l10 r0
  0225    | MatchWindowExit
  0226    | TakeRight 226 -> 280
  0229    | GetConstant 3: _with_precedence_rest
  0231    | GetLocalMove l0
  0233    | GetLocalMove l1
  0235    | GetLocalMove l2
  0237    | GetLocalMove l3
  0239    | GetLocalMove l4
  0241    | PushEmptyObject
  0242    | JumpIfFailure 242 -> 248
  0245    | GetLocalMove l9
  0247    | Merge
  0248    | JumpIfFailure 248 -> 278
  0251    | GetConstantMutable 11: {_0_, _1_}
  0253    | PushString "left"
  0255    | GetLocal l5
  0257    | InsertKeyVal 0
  0259    | PushString "right"
  0261    | GetLocal l10
  0263    | InsertKeyVal 1
  0265    | JumpIfFailure 265 -> 277
  0268    | GetConstant 5: _MergePos
  0270    | GetLocalMove l5
  0272    | GetLocalMove l10
  0274    | CallFunction 2
  0276    | Merge
  0277    | Merge
  0278    | CallTailFunction 6
  0280    | Jump 280 -> 289
  0283    | GetConstant 7: const
  0285    | GetLocalMove l5
  0287    | CallTailFunction 1
  0289    | End
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
  0003    | PushUnderscoreVar
  0004    | PushVar2 EndPos
  0007    | PushEmptyObject
  0008    | JumpIfFailure 8 -> 63
  0011    | SetInputMark
  0012    | GetLocalMove l0
  0014    | JumpIfFailure 14 -> 46
  0017    | MatchWindowEnter 3
  0019    | MatchScrutinee r0
  0021    | MatchType r0 object -> 44
  0026    | MatchKeysMin r0 1 -> 44
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
  0063    | JumpIfFailure 63 -> 118
  0066    | SetInputMark
  0067    | GetLocalMove l1
  0069    | JumpIfFailure 69 -> 101
  0072    | MatchWindowEnter 3
  0074    | MatchScrutinee r0
  0076    | MatchType r0 object -> 99
  0081    | MatchKeysMin r0 1 -> 99
  0086    | MatchKey r1 r0["endpos"] -> 99
  0093    | MatchBind l4 r1
  0096    | Jump 96 -> 100
  0099    | MatchFail
  0100    | MatchWindowExit
  0101    | ConditionalThen 101 -> 116
  0104    | GetConstantMutable 15: {_0_}
  0106    | PushString2 "endpos"
  0109    | GetLocalMove l4
  0111    | InsertKeyVal 0
  0113    | Jump 113 -> 117
  0116    | PushEmptyObject
  0117    | Merge
  0118    | End
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
