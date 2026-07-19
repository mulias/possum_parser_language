Full created-stage goal form of stdlib/ast.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/ast.possum -i '' --no-stdlib
  with_operator_precedence(operand, prefix, infix, postfix) =
    (call _with_precedence_start [operand prefix infix postfix 0])
  
  _with_precedence_start(operand, prefix, infix, postfix, LeftBindingPower) =
    (alt
      (arm
        guard: (match
          scrutinee: (call prefix)
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = key %0 "power"
                (is_type %0 object)
                (keys_exact %0 1)
                (has_key %0 "power")
                (local %1 PrefixBindingPower))
              (local PrefixNode))))
        body: (seq result=1
          (match
            scrutinee: (call _with_precedence_start [operand prefix infix postfix PrefixBindingPower])
            %0 = scrutinee
            (arm
              (local %0 Node)))
          (call _with_precedence_rest [
            operand
            prefix
            infix
            postfix
            LeftBindingPower
            (merge
              (merge
                (object [])
                PrefixNode)
              (merge
                (object [
                  (pair "prefixed" Node)
                ])
                (call _MergePos [PrefixNode Node])))
          ])))
      (arm
        body: (seq result=1
          (match
            scrutinee: (call operand)
            %0 = scrutinee
            (arm
              (local %0 Node)))
          (call _with_precedence_rest [operand prefix infix postfix LeftBindingPower Node]))))
  
  _with_precedence_rest(operand, prefix, infix, postfix, LeftBindingPower, Node) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: (call postfix)
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = key %0 "power"
                  (is_type %0 object)
                  (keys_exact %0 1)
                  (has_key %0 "power")
                  (local %1 RightBindingPower))
                (local PostfixNode))))
          (call const [(call Is.LessThan [LeftBindingPower RightBindingPower])]))
        body: (call _with_precedence_rest [
          operand
          prefix
          infix
          postfix
          LeftBindingPower
          (merge
            (merge
              (object [])
              PostfixNode)
            (merge
              (object [
                (pair "postfixed" Node)
              ])
              (call _MergePos [Node PostfixNode])))
        ]))
      (arm
        guard: (seq result=1
          (match
            scrutinee: (call infix)
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = key %0 "power"
                  %2 = elem %1 0
                  %3 = elem %1 1
                  (is_type %0 object)
                  (keys_exact %0 1)
                  (has_key %0 "power")
                  (is_type %1 array)
                  (len_eq %1 2)
                  (local %2 RightBindingPower)
                  (local %3 NextLeftBindingPower))
                (local InfixNode))))
          (call const [(call Is.LessThan [LeftBindingPower RightBindingPower])]))
        body: (seq result=1
          (match
            scrutinee: (call _with_precedence_start [operand prefix infix postfix NextLeftBindingPower])
            %0 = scrutinee
            (arm
              (local %0 RightNode)))
          (call _with_precedence_rest [
            operand
            prefix
            infix
            postfix
            LeftBindingPower
            (merge
              (merge
                (object [])
                InfixNode)
              (merge
                (object [
                  (pair "left" Node)
                  (pair "right" RightNode)
                ])
                (call _MergePos [Node RightNode])))
          ])))
      (arm
        body: (call const [Node])))
  
  node(value, Type) =
    (seq result=1
      (match
        scrutinee: (call value)
        %0 = scrutinee
        (arm
          (local %0 Value)))
      (object [
        (pair "type" Type)
        (pair "value" Value)
      ]))
  
  prefix_node(op, Type, BindingPower) =
    (seq result=1
      (call op)
      (object [
        (pair "type" Type)
        (pair "power" BindingPower)
      ]))
  
  infix_node(op, Type, LeftBindingPower, RightBindingPower) =
    (seq result=1
      (call op)
      (object [
        (pair "type" Type)
        (pair
          "power"
          (array [
            LeftBindingPower
            RightBindingPower
          ]))
      ]))
  
  postfix_node(op, Type, BindingPower) =
    (seq result=1
      (call op)
      (object [
        (pair "type" Type)
        (pair "power" BindingPower)
      ]))
  
  with_offset_pos(node) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call @input.offset)
          %0 = scrutinee
          (arm
            (local %0 StartOffset)))
        (match
          scrutinee: (call node)
          %0 = scrutinee
          (arm
            (local %0 Node))))
      (seq result=1
        (match
          scrutinee: (call @input.offset)
          %0 = scrutinee
          (arm
            (local %0 EndOffset)))
        (merge
          (merge
            (object [])
            Node)
          (object [
            (pair "startpos" StartOffset)
            (pair "endpos" EndOffset)
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
                (local %0 StartLine)))
            (match
              scrutinee: (call @input.line_offset)
              %0 = scrutinee
              (arm
                (local %0 StartLineOffset))))
          (match
            scrutinee: (call node)
            %0 = scrutinee
            (arm
              (local %0 Node))))
        (match
          scrutinee: (call @input.line)
          %0 = scrutinee
          (arm
            (local %0 EndLine))))
      (seq result=1
        (match
          scrutinee: (call @input.line_offset)
          %0 = scrutinee
          (arm
            (local %0 EndLineOffset)))
        (merge
          (merge
            (object [])
            Node)
          (object [
            (pair
              "startpos"
              (object [
                (pair "line" StartLine)
                (pair "offset" StartLineOffset)
              ]))
            (pair
              "endpos"
              (object [
                (pair "line" EndLine)
                (pair "offset" EndLineOffset)
              ]))
          ]))))
  
  _MergePos(Left, Right) =
    (merge
      (merge
        (object [])
        (alt
          (arm
            guard: (match
              scrutinee: Left
              %0 = scrutinee
              (arm
                (solve_merge %0
                  (set
                    %0 = scrutinee
                    %1 = key %0 "startpos"
                    (is_type %0 object)
                    (keys_exact %0 1)
                    (has_key %0 "startpos")
                    (local %1 StartPos))
                  _)))
            body: (object [
              (pair "startpos" StartPos)
            ]))
          (arm
            body: (object []))))
      (alt
        (arm
          guard: (match
            scrutinee: Right
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = key %0 "endpos"
                  (is_type %0 object)
                  (keys_exact %0 1)
                  (has_key %0 "endpos")
                  (local %1 EndPos))
                _)))
          body: (object [
            (pair "endpos" EndPos)
          ]))
        (arm
          body: (object []))))
  
