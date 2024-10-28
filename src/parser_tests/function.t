  $ export PRINT_AST=true RUN_VM=false

  $ possum -p 'foo(a, b, c) = a + b + c' -i ''
  []*ast.Ast.LocNode
    *ast.Ast.LocNode
      .loc: location.Location
        .line: usize = 1
        .start: usize = 13
        .length: usize = 1
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .DeclareGlobal
          .left: *ast.Ast.LocNode
            .loc: location.Location
              .line: usize = 1
              .start: usize = 3
              .length: usize = 1
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .CallOrDefineFunction
                .left: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 0
                    .length: usize = 3
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .ParserVar: u32 = 2704
                .right: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 5
                    .length: usize = 1
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .ParamsOrArgs
                      .left: *ast.Ast.LocNode
                        .loc: location.Location
                          .line: usize = 1
                          .start: usize = 4
                          .length: usize = 1
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .ParserVar: u32 = 131
                      .right: *ast.Ast.LocNode
                        .loc: location.Location
                          .line: usize = 1
                          .start: usize = 8
                          .length: usize = 1
                        .node: ast.Ast.Node
                          .InfixNode: ast.Ast.Infix
                            .infixType: ast.Ast.InfixType
                              .ParamsOrArgs
                            .left: *ast.Ast.LocNode
                              .loc: location.Location
                                .line: usize = 1
                                .start: usize = 7
                                .length: usize = 1
                              .node: ast.Ast.Node
                                .ElemNode: elem.Elem
                                  .ParserVar: u32 = 677
                            .right: *ast.Ast.LocNode
                              .loc: location.Location
                                .line: usize = 1
                                .start: usize = 10
                                .length: usize = 1
                              .node: ast.Ast.Node
                                .ElemNode: elem.Elem
                                  .ParserVar: u32 = 685
          .right: *ast.Ast.LocNode
            .loc: location.Location
              .line: usize = 1
              .start: usize = 21
              .length: usize = 1
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 17
                    .length: usize = 1
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.LocNode
                        .loc: location.Location
                          .line: usize = 1
                          .start: usize = 15
                          .length: usize = 1
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .ParserVar: u32 = 131
                      .right: *ast.Ast.LocNode
                        .loc: location.Location
                          .line: usize = 1
                          .start: usize = 19
                          .length: usize = 1
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .ParserVar: u32 = 677
                .right: *ast.Ast.LocNode
                  .loc: location.Location
                    .line: usize = 1
                    .start: usize = 23
                    .length: usize = 1
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .ParserVar: u32 = 685

