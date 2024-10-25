  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"a" > "b" > "c" | "abz"' -i ''
  []*ast.Ast.LocNode
    *ast.Ast.LocNode
      .loc: location.Location
        .line: usize = 1
        .start: usize = 16
        .length: usize = 1
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .Or
          .left: *ast.Ast.LocNode
            .loc: location.Location
              .line: usize = 1
              .start: usize = 10
              .length: usize = 1
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .TakeRight
                .left: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 4
                    .length: usize = 1
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .TakeRight
                      .left: *ast.Ast.LocNode
                        .loc: location.Location
                          .line: usize = 1
                          .start: usize = 0
                          .length: usize = 3
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .String: u32 = 59
                      .right: *ast.Ast.LocNode
                        .loc: location.Location
                          .line: usize = 1
                          .start: usize = 6
                          .length: usize = 3
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .String: u32 = 2344
                .right: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 12
                    .length: usize = 3
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .String: u32 = 2346
          .right: *ast.Ast.LocNode
            .loc: location.Location
              .line: usize = 1
              .start: usize = 18
              .length: usize = 5
            .node: ast.Ast.Node
              .ElemNode: elem.Elem
                .String: u32 = 2348

  $ possum -p '"" $ (1-2)' -i ''
  []*ast.Ast.LocNode
    *ast.Ast.LocNode
      .loc: location.Location
        .line: usize = 1
        .start: usize = 3
        .length: usize = 1
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .Return
          .left: *ast.Ast.LocNode
            .loc: location.Location
              .line: usize = 1
              .start: usize = 0
              .length: usize = 2
            .node: ast.Ast.Node
              .ElemNode: elem.Elem
                .String: u32 = 679
          .right: *ast.Ast.LocNode
            .loc: location.Location
              .line: usize = 1
              .start: usize = 7
              .length: usize = 1
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .NumberSubtract
                .left: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 6
                    .length: usize = 1
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .NumberString: elem.Elem.NumberString
                        .sId: u32 = 829
                        .format: elem.Elem.NumberString.Format
                          .Integer
                        .negated: bool = false
                .right: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 8
                    .length: usize = 1
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .NumberString: elem.Elem.NumberString
                        .sId: u32 = 2344
                        .format: elem.Elem.NumberString.Format
                          .Integer
                        .negated: bool = false
