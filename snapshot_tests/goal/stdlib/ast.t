Full created-stage goal form of stdlib/ast.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/ast.possum -i '' --no-stdlib
  with_operator_precedence(operand, prefix, infix, postfix) =
    (call _with_precedence_start [operand~0 prefix~1 infix~2 postfix~3 0])
  
  _with_precedence_start(operand, prefix, infix, postfix, LeftBindingPower) =
    (alt
      (arm
        guard: (match
          scrutinee: (call prefix~1)
          %0 = scrutinee
          %1 = key %0 "power"
          %2 = members_rest %0
          (arm
            (is_type %0 object)
            (keys_min %0 1)
            (has_key %0 "power")
            (bind %1 PrefixBindingPower~5)
            (bind %2 PrefixNode~6)))
        body: (seq result=1
          (match
            scrutinee: (call _with_precedence_start [operand~0 prefix~1 infix~2 postfix~3 PrefixBindingPower~5])
            %0 = scrutinee
            (arm
              (bind %0 Node~7)))
          (call _with_precedence_rest [
            operand~0
            prefix~1
            infix~2
            postfix~3
            LeftBindingPower~4
            (merge
              (merge
                (object [])
                PrefixNode~6)
              (merge
                (object [
                  (pair "prefixed" Node~7)
                ])
                (call _MergePos [PrefixNode~6 Node~7])))
          ])))
      (arm
        body: (seq result=1
          (match
            scrutinee: (call operand~0)
            %0 = scrutinee
            (arm
              (bind %0 Node~7)))
          (call _with_precedence_rest [operand~0 prefix~1 infix~2 postfix~3 LeftBindingPower~4 Node~7]))))
  
  _with_precedence_rest(operand, prefix, infix, postfix, LeftBindingPower, Node) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: (call postfix~3)
            %0 = scrutinee
            %1 = key %0 "power"
            %2 = members_rest %0
            (arm
              (is_type %0 object)
              (keys_min %0 1)
              (has_key %0 "power")
              (bind %1 RightBindingPower~6)
              (bind %2 PostfixNode~7)))
          (call const [(call Is.LessThan [LeftBindingPower~4 RightBindingPower~6])]))
        body: (call _with_precedence_rest [
          operand~0
          prefix~1
          infix~2
          postfix~3
          LeftBindingPower~4
          (merge
            (merge
              (object [])
              PostfixNode~7)
            (merge
              (object [
                (pair "postfixed" Node~5)
              ])
              (call _MergePos [Node~5 PostfixNode~7])))
        ]))
      (arm
        guard: (seq result=1
          (match
            scrutinee: (call infix~2)
            %0 = scrutinee
            %1 = key %0 "power"
            %2 = elem %1 0
            %3 = elem %1 1
            %4 = members_rest %0
            (arm
              (is_type %0 object)
              (keys_min %0 1)
              (has_key %0 "power")
              (is_type %1 array)
              (len_eq %1 2)
              (bind %2 RightBindingPower~6)
              (bind %3 NextLeftBindingPower~8)
              (bind %4 InfixNode~9)))
          (call const [(call Is.LessThan [LeftBindingPower~4 RightBindingPower~6])]))
        body: (seq result=1
          (match
            scrutinee: (call _with_precedence_start [operand~0 prefix~1 infix~2 postfix~3 NextLeftBindingPower~8])
            %0 = scrutinee
            (arm
              (bind %0 RightNode~10)))
          (call _with_precedence_rest [
            operand~0
            prefix~1
            infix~2
            postfix~3
            LeftBindingPower~4
            (merge
              (merge
                (object [])
                InfixNode~9)
              (merge
                (object [
                  (pair "left" Node~5)
                  (pair "right" RightNode~10)
                ])
                (call _MergePos [Node~5 RightNode~10])))
          ])))
      (arm
        body: (call const [Node~5])))
  
  node(value, Type) =
    (seq result=1
      (match
        scrutinee: (call value~0)
        %0 = scrutinee
        (arm
          (bind %0 Value~2)))
      (object [
        (pair "type" Type~1)
        (pair "value" Value~2)
      ]))
  
  prefix_node(op, Type, BindingPower) =
    (seq result=1
      (call op~0)
      (object [
        (pair "type" Type~1)
        (pair "power" BindingPower~2)
      ]))
  
  infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    (seq result=1
      (call op~0)
      (object [
        (pair "type" Type~1)
        (pair
          "power"
          (array [
            LeftBindingPower~2
            RightBindingPower~3
          ]))
      ]))
  
  postfix_node(op, Type, BindingPower) =
    (seq result=1
      (call op~0)
      (object [
        (pair "type" Type~1)
        (pair "power" BindingPower~2)
      ]))
  
  with_offset_pos(node) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call @input.offset)
          %0 = scrutinee
          (arm
            (bind %0 StartOffset~1)))
        (match
          scrutinee: (call node~0)
          %0 = scrutinee
          (arm
            (bind %0 Node~2))))
      (seq result=1
        (match
          scrutinee: (call @input.offset)
          %0 = scrutinee
          (arm
            (bind %0 EndOffset~3)))
        (merge
          (merge
            (object [])
            Node~2)
          (object [
            (pair "startpos" StartOffset~1)
            (pair "endpos" EndOffset~3)
          ]))))
  
  with_line_pos(node) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (match
              scrutinee: (call @input.line)
              %0 = scrutinee
              (arm
                (bind %0 StartLine~1)))
            (match
              scrutinee: (call @input.line_offset)
              %0 = scrutinee
              (arm
                (bind %0 StartLineOffset~2))))
          (match
            scrutinee: (call node~0)
            %0 = scrutinee
            (arm
              (bind %0 Node~3))))
        (match
          scrutinee: (call @input.line)
          %0 = scrutinee
          (arm
            (bind %0 EndLine~4))))
      (seq result=1
        (match
          scrutinee: (call @input.line_offset)
          %0 = scrutinee
          (arm
            (bind %0 EndLineOffset~5)))
        (merge
          (merge
            (object [])
            Node~3)
          (object [
            (pair
              "startpos"
              (object [
                (pair "line" StartLine~1)
                (pair "offset" StartLineOffset~2)
              ]))
            (pair
              "endpos"
              (object [
                (pair "line" EndLine~4)
                (pair "offset" EndLineOffset~5)
              ]))
          ]))))
  
  _MergePos(Left, Right) =
    (merge
      (merge
        (object [])
        (alt
          (arm
            guard: (match
              scrutinee: Left~0
              %0 = scrutinee
              %1 = key %0 "startpos"
              (arm
                (is_type %0 object)
                (keys_min %0 1)
                (has_key %0 "startpos")
                (bind %1 StartPos~2)))
            body: (object [
              (pair "startpos" StartPos~2)
            ]))
          (arm
            body: (object []))))
      (alt
        (arm
          guard: (match
            scrutinee: Right~1
            %0 = scrutinee
            %1 = key %0 "endpos"
            (arm
              (is_type %0 object)
              (keys_min %0 1)
              (has_key %0 "endpos")
              (bind %1 EndPos~4)))
          body: (object [
            (pair "endpos" EndPos~4)
          ]))
        (arm
          body: (object []))))
  
