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
  0002    | GetLocalMove 0
  0004    | GetLocalMove 1
  0006    | GetLocalMove 2
  0008    | GetLocalMove 3
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
  0007    | CallFunctionLocal 1
  0009    | DestructurePlan 0: ({"power": bind PrefixBindingPower} + bind PrefixNode)
  0011    | ConditionalThen 11 -> 81
  0014    | GetConstant 0: _with_precedence_start
  0016    | GetLocal 0
  0018    | GetLocal 1
  0020    | GetLocal 2
  0022    | GetLocal 3
  0024    | GetLocalMove 5
  0026    | CallFunction 5
  0028    | DestructurePlan 1: bind Node
  0030    | TakeRight 30 -> 78
  0033    | GetConstant 1: _with_precedence_rest
  0035    | GetLocalMove 0
  0037    | GetLocalMove 1
  0039    | GetLocalMove 2
  0041    | GetLocalMove 3
  0043    | GetLocalMove 4
  0045    | PushEmptyObject
  0046    | JumpIfFailure 46 -> 52
  0049    | GetLocal 6
  0051    | Merge
  0052    | JumpIfFailure 52 -> 76
  0055    | GetConstantMutable 2: {_0_}
  0057    | PushString "prefixed"
  0059    | GetLocal 7
  0061    | InsertKeyVal 0
  0063    | JumpIfFailure 63 -> 75
  0066    | GetConstant 3: _MergePos
  0068    | GetLocalMove 6
  0070    | GetLocalMove 7
  0072    | CallFunction 2
  0074    | Merge
  0075    | Merge
  0076    | CallTailFunction 6
  0078    | Jump 78 -> 104
  0081    | CallFunctionLocal 0
  0083    | DestructurePlan 2: bind Node
  0085    | TakeRight 85 -> 104
  0088    | GetConstant 1: _with_precedence_rest
  0090    | GetLocalMove 0
  0092    | GetLocalMove 1
  0094    | GetLocalMove 2
  0096    | GetLocalMove 3
  0098    | GetLocalMove 4
  0100    | GetLocalMove 7
  0102    | CallTailFunction 6
  0104    | End
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
  0011    | CallFunctionLocal 3
  0013    | DestructurePlan 3: ({"power": bind RightBindingPower} + bind PostfixNode)
  0015    | TakeRight 15 -> 30
  0018    | GetConstant 4: const
  0020    | GetConstant 5: Is.LessThan
  0022    | GetLocal 4
  0024    | GetLocalMove 6
  0026    | CallFunction 2
  0028    | CallFunction 1
  0030    | ConditionalThen 30 -> 81
  0033    | GetConstant 1: _with_precedence_rest
  0035    | GetLocalMove 0
  0037    | GetLocalMove 1
  0039    | GetLocalMove 2
  0041    | GetLocalMove 3
  0043    | GetLocalMove 4
  0045    | PushEmptyObject
  0046    | JumpIfFailure 46 -> 52
  0049    | GetLocal 7
  0051    | Merge
  0052    | JumpIfFailure 52 -> 76
  0055    | GetConstantMutable 6: {_0_}
  0057    | PushString "postfixed"
  0059    | GetLocal 5
  0061    | InsertKeyVal 0
  0063    | JumpIfFailure 63 -> 75
  0066    | GetConstant 3: _MergePos
  0068    | GetLocalMove 5
  0070    | GetLocalMove 7
  0072    | CallFunction 2
  0074    | Merge
  0075    | Merge
  0076    | CallTailFunction 6
  0078    | Jump 78 -> 183
  0081    | SetInputMark
  0082    | CallFunctionLocal 2
  0084    | DestructurePlan 4: ({"power": [bind RightBindingPower, bind NextLeftBindingPower]} + bind InfixNode)
  0086    | TakeRight 86 -> 101
  0089    | GetConstant 4: const
  0091    | GetConstant 5: Is.LessThan
  0093    | GetLocal 4
  0095    | GetLocalMove 6
  0097    | CallFunction 2
  0099    | CallFunction 1
  0101    | ConditionalThen 101 -> 177
  0104    | GetConstant 0: _with_precedence_start
  0106    | GetLocal 0
  0108    | GetLocal 1
  0110    | GetLocal 2
  0112    | GetLocal 3
  0114    | GetLocalMove 8
  0116    | CallFunction 5
  0118    | DestructurePlan 5: bind RightNode
  0120    | TakeRight 120 -> 174
  0123    | GetConstant 1: _with_precedence_rest
  0125    | GetLocalMove 0
  0127    | GetLocalMove 1
  0129    | GetLocalMove 2
  0131    | GetLocalMove 3
  0133    | GetLocalMove 4
  0135    | PushEmptyObject
  0136    | JumpIfFailure 136 -> 142
  0139    | GetLocalMove 9
  0141    | Merge
  0142    | JumpIfFailure 142 -> 172
  0145    | GetConstantMutable 7: {_0_, _1_}
  0147    | PushString "left"
  0149    | GetLocal 5
  0151    | InsertKeyVal 0
  0153    | PushString "right"
  0155    | GetLocal 10
  0157    | InsertKeyVal 1
  0159    | JumpIfFailure 159 -> 171
  0162    | GetConstant 3: _MergePos
  0164    | GetLocalMove 5
  0166    | GetLocalMove 10
  0168    | CallFunction 2
  0170    | Merge
  0171    | Merge
  0172    | CallTailFunction 6
  0174    | Jump 174 -> 183
  0177    | GetConstant 4: const
  0179    | GetLocalMove 5
  0181    | CallTailFunction 1
  0183    | End
  ========================================
  
  =================1:node=================
  node(value, Type) =
    value -> Value $ {"type": Type, "value": Value}
  ========================================
  0000    | PushVar2 Value
  0003    | CallFunctionLocal 0
  0005    | DestructurePlan 8: bind Value
  0007    | TakeRight 7 -> 26
  0010    | GetConstantMutable 10: {_0_, _1_}
  0012    | PushString2 "type"
  0015    | GetLocalMove 1
  0017    | InsertKeyVal 0
  0019    | PushString2 "value"
  0022    | GetLocalMove 2
  0024    | InsertKeyVal 1
  0026    | End
  ========================================
  
  =============1:prefix_node==============
  prefix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 20
  0005    | GetConstantMutable 11: {_0_, _1_}
  0007    | PushString2 "type"
  0010    | GetLocalMove 1
  0012    | InsertKeyVal 0
  0014    | PushString "power"
  0016    | GetLocalMove 2
  0018    | InsertKeyVal 1
  0020    | End
  ========================================
  
  ==============1:infix_node==============
  infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    op $ {"type": Type, "power": [LeftBindingPower, RightBindingPower]}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 28
  0005    | GetConstantMutable 12: {_0_, _1_}
  0007    | PushString2 "type"
  0010    | GetLocalMove 1
  0012    | InsertKeyVal 0
  0014    | PushString "power"
  0016    | GetConstantMutable 13: [_, _]
  0018    | GetLocalMove 2
  0020    | InsertAtIndex 0
  0022    | GetLocalMove 3
  0024    | InsertAtIndex 1
  0026    | InsertKeyVal 1
  0028    | End
  ========================================
  
  =============1:postfix_node=============
  postfix_node(op, Type, BindingPower) =
    op $ {"type": Type, "power": BindingPower}
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 20
  0005    | GetConstantMutable 14: {_0_, _1_}
  0007    | PushString2 "type"
  0010    | GetLocalMove 1
  0012    | InsertKeyVal 0
  0014    | PushString "power"
  0016    | GetLocalMove 2
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
  0008    | CallFunctionConstant 15: @input.offset
  0010    | DestructurePlan 9: bind StartOffset
  0012    | TakeRight 12 -> 19
  0015    | CallFunctionLocal 0
  0017    | DestructurePlan 10: bind Node
  0019    | TakeRight 19 -> 56
  0022    | CallFunctionConstant 15: @input.offset
  0024    | DestructurePlan 11: bind EndOffset
  0026    | TakeRight 26 -> 56
  0029    | PushEmptyObject
  0030    | JumpIfFailure 30 -> 36
  0033    | GetLocalMove 2
  0035    | Merge
  0036    | JumpIfFailure 36 -> 56
  0039    | GetConstantMutable 16: {_0_, _1_}
  0041    | PushString2 "startpos"
  0044    | GetLocalMove 1
  0046    | InsertKeyVal 0
  0048    | PushString2 "endpos"
  0051    | GetLocalMove 3
  0053    | InsertKeyVal 1
  0055    | Merge
  0056    | End
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
  0014    | CallFunctionConstant 17: @input.line
  0016    | DestructurePlan 12: bind StartLine
  0018    | TakeRight 18 -> 25
  0021    | CallFunctionConstant 18: @input.line_offset
  0023    | DestructurePlan 13: bind StartLineOffset
  0025    | TakeRight 25 -> 32
  0028    | CallFunctionLocal 0
  0030    | DestructurePlan 14: bind Node
  0032    | TakeRight 32 -> 39
  0035    | CallFunctionConstant 17: @input.line
  0037    | DestructurePlan 15: bind EndLine
  0039    | TakeRight 39 -> 104
  0042    | CallFunctionConstant 18: @input.line_offset
  0044    | DestructurePlan 16: bind EndLineOffset
  0046    | TakeRight 46 -> 104
  0049    | PushEmptyObject
  0050    | JumpIfFailure 50 -> 56
  0053    | GetLocalMove 3
  0055    | Merge
  0056    | JumpIfFailure 56 -> 104
  0059    | GetConstantMutable 19: {_0_, _1_}
  0061    | PushString2 "startpos"
  0064    | GetConstantMutable 20: {_0_, _1_}
  0066    | PushString2 "line"
  0069    | GetLocalMove 1
  0071    | InsertKeyVal 0
  0073    | PushString2 "offset"
  0076    | GetLocalMove 2
  0078    | InsertKeyVal 1
  0080    | InsertKeyVal 0
  0082    | PushString2 "endpos"
  0085    | GetConstantMutable 21: {_0_, _1_}
  0087    | PushString2 "line"
  0090    | GetLocalMove 4
  0092    | InsertKeyVal 0
  0094    | PushString2 "offset"
  0097    | GetLocalMove 5
  0099    | InsertKeyVal 1
  0101    | InsertKeyVal 1
  0103    | Merge
  0104    | End
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
  0008    | JumpIfFailure 8 -> 33
  0011    | SetInputMark
  0012    | GetLocalMove 0
  0014    | DestructurePlan 6: ({"startpos": bind StartPos} + _)
  0016    | ConditionalThen 16 -> 31
  0019    | GetConstantMutable 8: {_0_}
  0021    | PushString2 "startpos"
  0024    | GetLocalMove 2
  0026    | InsertKeyVal 0
  0028    | Jump 28 -> 32
  0031    | PushEmptyObject
  0032    | Merge
  0033    | JumpIfFailure 33 -> 58
  0036    | SetInputMark
  0037    | GetLocalMove 1
  0039    | DestructurePlan 7: ({"endpos": bind EndPos} + _)
  0041    | ConditionalThen 41 -> 56
  0044    | GetConstantMutable 9: {_0_}
  0046    | PushString2 "endpos"
  0049    | GetLocalMove 4
  0051    | InsertKeyVal 0
  0053    | Jump 53 -> 57
  0056    | PushEmptyObject
  0057    | Merge
  0058    | End
  ========================================
  
  ================2:const=================
  const(C) = "" $ C
  ========================================
  0000    | GetLocalMove 0
  0002    | End
  ========================================
  
  =============14:Is.LessThan=============
  Is.LessThan(A, B) = A -> B ? @Fail : A -> ..B
  ========================================
  0000    | SetInputMark
  0001    | GetLocal 0
  0003    | DestructurePlan 0: bound_eq B
  0005    | ConditionalThen 5 -> 13
  0008    | CallTailFunctionConstant 0: @Fail
  0010    | Jump 10 -> 17
  0013    | GetLocalMove 0
  0015    | DestructurePlan 1: ..B
  0017    | End
  ========================================
