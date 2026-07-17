  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/ast.possum -i '' --no-stdlib
  (Import 1:0-19 stdlib/combinator private)
  
  (Import 2:0-18 stdlib/Predicate private)
  
  (DeclareGlobal 4:0-121
    (Function 4:0-57
      (Identifier 4:0-24 with_operator_precedence) [
        (Identifier 4:25-32 operand)
        (Identifier 4:34-40 prefix)
        (Identifier 4:42-47 infix)
        (Identifier 4:49-56 postfix)
      ])
    (Function 5:2-61
      (Identifier 5:2-24 _with_precedence_start) [
        (Identifier 5:25-32 operand)
        (Identifier 5:34-40 prefix)
        (Identifier 5:42-47 infix)
        (Identifier 5:49-56 postfix)
        (ValueLabel 5:58-59 (NumberString 5:59-60 0))
      ]))
  
  (DeclareGlobal 7:0-553
    (Function 7:0-73
      (Identifier 7:0-22 _with_precedence_start) [
        (Identifier 7:23-30 operand)
        (Identifier 7:32-38 prefix)
        (Identifier 7:40-45 infix)
        (Identifier 7:47-54 postfix)
        (Identifier 7:56-72 LeftBindingPower)
      ])
    (Conditional 8:2-477
      (Destructure 8:2-56
        (Identifier 8:2-8 prefix)
        (Merge 8:12-56
          (Object 8:12-45 [
            (ObjectPair (String 8:13-20 "power") (Identifier 8:22-40 PrefixBindingPower))
          ])
          (Identifier 8:45-55 PrefixNode)))
      (TakeRight 8:59-340
        (Destructure 9:4-105
          (Function 9:4-97
            (Identifier 9:4-26 _with_precedence_start) [
              (Identifier 10:6-13 operand)
              (Identifier 10:15-21 prefix)
              (Identifier 10:23-28 infix)
              (Identifier 10:30-37 postfix)
              (Identifier 11:6-24 PrefixBindingPower)
            ])
          (Identifier 12:9-13 Node))
        (Function 13:4-167
          (Identifier 13:4-25 _with_precedence_rest) [
            (Identifier 14:6-13 operand)
            (Identifier 14:15-21 prefix)
            (Identifier 14:23-28 infix)
            (Identifier 14:30-37 postfix)
            (Identifier 15:6-22 LeftBindingPower)
            (Merge 16:6-71
              (Merge 16:6-7
                (Object 16:6-7 [])
                (Identifier 16:10-20 PrefixNode))
              (Merge 16:22-71
                (Object 16:22-23 [
                  (ObjectPair (String 16:22-32 "prefixed") (Identifier 16:34-38 Node))
                ])
                (Function 16:43-70
                  (Identifier 16:43-52 _MergePos) [
                    (Identifier 16:53-63 PrefixNode)
                    (Identifier 16:65-69 Node)
                  ])))
          ]))
      (TakeRight 18:6-140
        (Destructure 19:4-19
          (Identifier 19:4-11 operand)
          (Identifier 19:15-19 Node))
        (Function 20:4-106
          (Identifier 20:4-25 _with_precedence_rest) [
            (Identifier 21:6-13 operand)
            (Identifier 21:15-21 prefix)
            (Identifier 21:23-28 infix)
            (Identifier 21:30-37 postfix)
            (Identifier 22:6-22 LeftBindingPower)
            (Identifier 23:6-10 Node)
          ]))))
  
  (DeclareGlobal 27:0-838
    (Function 27:0-78
      (Identifier 27:0-21 _with_precedence_rest) [
        (Identifier 27:22-29 operand)
        (Identifier 27:31-37 prefix)
        (Identifier 27:39-44 infix)
        (Identifier 27:46-53 postfix)
        (Identifier 27:55-71 LeftBindingPower)
        (Identifier 27:73-77 Node)
      ])
    (Conditional 28:2-757
      (TakeRight 28:2-117
        (Destructure 28:2-57
          (Identifier 28:2-9 postfix)
          (Merge 28:13-57
            (Object 28:13-45 [
              (ObjectPair (String 28:14-21 "power") (Identifier 28:23-40 RightBindingPower))
            ])
            (Identifier 28:45-56 PostfixNode)))
        (Function 29:2-57
          (Identifier 29:2-7 const) [
            (Function 29:8-56
              (Identifier 29:8-19 Is.LessThan) [
                (Identifier 29:20-36 LeftBindingPower)
                (Identifier 29:38-55 RightBindingPower)
              ])
          ]))
      (Function 29:60-236
        (Identifier 30:4-25 _with_precedence_rest) [
          (Identifier 31:6-13 operand)
          (Identifier 31:15-21 prefix)
          (Identifier 31:23-28 infix)
          (Identifier 31:30-37 postfix)
          (Identifier 32:6-22 LeftBindingPower)
          (Merge 33:6-74
            (Merge 33:6-7
              (Object 33:6-7 [])
              (Identifier 33:10-21 PostfixNode))
            (Merge 33:23-74
              (Object 33:23-24 [
                (ObjectPair (String 33:23-34 "postfixed") (Identifier 33:36-40 Node))
              ])
              (Function 33:45-73
                (Identifier 33:45-54 _MergePos) [
                  (Identifier 33:55-59 Node)
                  (Identifier 33:61-72 PostfixNode)
                ])))
        ])
      (Conditional 36:2-458
        (TakeRight 36:2-137
          (Destructure 36:2-77
            (Identifier 36:2-7 infix)
            (Merge 36:11-77
              (Object 36:11-67 [
                (ObjectPair
                  (String 36:12-19 "power")
                  (Array 36:21-62 [
                    (Identifier 36:22-39 RightBindingPower)
                    (Identifier 36:41-61 NextLeftBindingPower)
                  ]))
              ])
              (Identifier 36:67-76 InfixNode)))
          (Function 37:2-57
            (Identifier 37:2-7 const) [
              (Function 37:8-56
                (Identifier 37:8-19 Is.LessThan) [
                  (Identifier 37:20-36 LeftBindingPower)
                  (Identifier 37:38-55 RightBindingPower)
                ])
            ]))
        (TakeRight 37:60-362
          (Destructure 38:4-112
            (Function 38:4-99
              (Identifier 38:4-26 _with_precedence_start) [
                (Identifier 39:6-13 operand)
                (Identifier 39:15-21 prefix)
                (Identifier 39:23-28 infix)
                (Identifier 39:30-37 postfix)
                (Identifier 40:6-26 NextLeftBindingPower)
              ])
            (Identifier 41:9-18 RightNode))
          (Function 42:4-181
            (Identifier 42:4-25 _with_precedence_rest) [
              (Identifier 43:6-13 operand)
              (Identifier 43:15-21 prefix)
              (Identifier 43:23-28 infix)
              (Identifier 43:30-37 postfix)
              (Identifier 44:6-22 LeftBindingPower)
              (Merge 45:6-85
                (Merge 45:6-7
                  (Object 45:6-7 [])
                  (Identifier 45:10-19 InfixNode))
                (Merge 45:21-85
                  (Object 45:21-22 [
                    (ObjectPair (String 45:21-27 "left") (Identifier 45:29-33 Node))
                    (ObjectPair (String 45:35-42 "right") (Identifier 45:44-53 RightNode))
                  ])
                  (Function 45:58-84
                    (Identifier 45:58-67 _MergePos) [
                      (Identifier 45:68-72 Node)
                      (Identifier 45:74-83 RightNode)
                    ])))
            ]))
        (Function 48:2-13
          (Identifier 48:2-7 const) [
            (Identifier 48:8-12 Node)
          ]))))
  
  (DeclareGlobal 50:0-69
    (Function 50:0-17
      (Identifier 50:0-4 node) [
        (Identifier 50:5-10 value)
        (Identifier 50:12-16 Type)
      ])
    (Return 51:2-49
      (Destructure 51:2-16
        (Identifier 51:2-7 value)
        (Identifier 51:11-16 Value))
      (Object 51:19-49 [
        (ObjectPair (String 51:20-26 "type") (Identifier 51:28-32 Type))
        (ObjectPair (String 51:34-41 "value") (Identifier 51:43-48 Value))
      ])))
  
  (DeclareGlobal 53:0-82
    (Function 53:0-35
      (Identifier 53:0-11 prefix_node) [
        (Identifier 53:12-14 op)
        (Identifier 53:16-20 Type)
        (Identifier 53:22-34 BindingPower)
      ])
    (Return 54:2-44
      (Identifier 54:2-4 op)
      (Object 54:7-44 [
        (ObjectPair (String 54:8-14 "type") (Identifier 54:16-20 Type))
        (ObjectPair (String 54:22-29 "power") (Identifier 54:31-43 BindingPower))
      ])))
  
  (DeclareGlobal 56:0-129
    (Function 56:0-57
      (Identifier 56:0-10 infix_node) [
        (Identifier 56:11-13 op)
        (Identifier 56:15-19 Type)
        (Identifier 56:21-37 LeftBindingPower)
        (Identifier 56:39-56 RightBindingPower)
      ])
    (Return 57:2-69
      (Identifier 57:2-4 op)
      (Object 57:7-69 [
        (ObjectPair (String 57:8-14 "type") (Identifier 57:16-20 Type))
        (ObjectPair
          (String 57:22-29 "power")
          (Array 57:31-68 [
            (Identifier 57:32-48 LeftBindingPower)
            (Identifier 57:50-67 RightBindingPower)
          ]))
      ])))
  
  (DeclareGlobal 59:0-83
    (Function 59:0-36
      (Identifier 59:0-12 postfix_node) [
        (Identifier 59:13-15 op)
        (Identifier 59:17-21 Type)
        (Identifier 59:23-35 BindingPower)
      ])
    (Return 60:2-44
      (Identifier 60:2-4 op)
      (Object 60:7-44 [
        (ObjectPair (String 60:8-14 "type") (Identifier 60:16-20 Type))
        (ObjectPair (String 60:22-29 "power") (Identifier 60:31-43 BindingPower))
      ])))
  
  (DeclareGlobal 62:0-162
    (Function 62:0-21
      (Identifier 62:0-15 with_offset_pos) [
        (Identifier 62:16-20 node)
      ])
    (TakeRight 63:2-138
      (TakeRight 63:2-47
        (Destructure 63:2-30
          (Identifier 63:2-15 @input.offset)
          (Identifier 63:19-30 StartOffset))
        (Destructure 64:2-14
          (Identifier 64:2-6 node)
          (Identifier 64:10-14 Node)))
      (Return 65:2-88
        (Destructure 65:2-28
          (Identifier 65:2-15 @input.offset)
          (Identifier 65:19-28 EndOffset))
        (Merge 66:2-57
          (Merge 66:2-3
            (Object 66:2-3 [])
            (Identifier 66:6-10 Node))
          (Object 66:12-57 [
            (ObjectPair (String 66:12-22 "startpos") (Identifier 66:24-35 StartOffset))
            (ObjectPair (String 66:37-45 "endpos") (Identifier 66:47-56 EndOffset))
          ])))))
  
  (DeclareGlobal 68:0-319
    (Function 68:0-19
      (Identifier 68:0-13 with_line_pos) [
        (Identifier 68:14-18 node)
      ])
    (TakeRight 69:2-297
      (TakeRight 69:2-112
        (TakeRight 69:2-85
          (TakeRight 69:2-68
            (Destructure 69:2-26
              (Identifier 69:2-13 @input.line)
              (Identifier 69:17-26 StartLine))
            (Destructure 70:2-39
              (Identifier 70:2-20 @input.line_offset)
              (Identifier 70:24-39 StartLineOffset)))
          (Destructure 71:2-14
            (Identifier 71:2-6 node)
            (Identifier 71:10-14 Node)))
        (Destructure 72:2-24
          (Identifier 72:2-13 @input.line)
          (Identifier 72:17-24 EndLine)))
      (Return 73:2-182
        (Destructure 73:2-37
          (Identifier 73:2-20 @input.line_offset)
          (Identifier 73:24-37 EndLineOffset))
        (Merge 74:2-142
          (Merge 74:2-3
            (Object 74:2-3 [])
            (Identifier 75:7-11 Node))
          (Object 76:4-125 [
            (ObjectPair
              (String 76:4-14 "startpos")
              (Object 76:16-62 [
                (ObjectPair (String 76:17-23 "line") (Identifier 76:25-34 StartLine))
                (ObjectPair (String 76:36-44 "offset") (Identifier 76:46-61 StartLineOffset))
              ]))
            (ObjectPair
              (String 77:4-12 "endpos")
              (Object 77:14-56 [
                (ObjectPair (String 77:15-21 "line") (Identifier 77:23-30 EndLine))
                (ObjectPair (String 77:32-40 "offset") (Identifier 77:42-55 EndLineOffset))
              ]))
          ])))))
  
  (DeclareGlobal 80:0-171
    (Function 80:0-22
      (Identifier 80:0-9 _MergePos) [
        (Identifier 80:10-14 Left)
        (Identifier 80:16-21 Right)
      ])
    (Merge 80:25-171
      (Merge 80:25-26
        (Object 80:25-26 [])
        (Conditional 81:5-73
          (Destructure 81:6-42
            (Identifier 81:6-10 Left)
            (Merge 81:14-42
              (Object 81:14-40 [
                (ObjectPair (String 81:15-25 "startpos") (Identifier 81:27-35 StartPos))
              ])
              (Identifier 81:40-41 _)))
          (Object 81:45-67 [
            (ObjectPair (String 81:46-56 "startpos") (Identifier 81:58-66 StartPos))
          ])
          (Object 81:70-73 [])))
      (Conditional 82:5-69
        (Destructure 82:6-39
          (Identifier 82:6-11 Right)
          (Merge 82:15-39
            (Object 82:15-37 [
              (ObjectPair (String 82:16-24 "endpos") (Identifier 82:26-32 EndPos))
            ])
            (Identifier 82:37-38 _)))
        (Object 82:42-60 [
          (ObjectPair (String 82:43-51 "endpos") (Identifier 82:53-59 EndPos))
        ])
        (Object 82:63-66 []))))
