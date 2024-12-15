  $ export PRINT_AST=true RUN_VM=false

  $ possum -p 'foo(a, b, c) = a + b + c' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 13
        .end: usize = 14
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .DeclareGlobal
          .left: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 3
              .end: usize = 4
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .CallOrDefineFunction
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 0
                    .end: usize = 3
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .ParserVar: u32 = 3507
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 5
                    .end: usize = 6
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .ParamsOrArgs
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 4
                          .end: usize = 5
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .ParserVar: u32 = 242
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 8
                          .end: usize = 9
                        .node: ast.Ast.Node
                          .InfixNode: ast.Ast.Infix
                            .infixType: ast.Ast.InfixType
                              .ParamsOrArgs
                            .left: *ast.Ast.RNode
                              .region: region.Region
                                .start: usize = 7
                                .end: usize = 8
                              .node: ast.Ast.Node
                                .ElemNode: elem.Elem
                                  .ParserVar: u32 = 818
                            .right: *ast.Ast.RNode
                              .region: region.Region
                                .start: usize = 10
                                .end: usize = 11
                              .node: ast.Ast.Node
                                .ElemNode: elem.Elem
                                  .ParserVar: u32 = 824
          .right: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 21
              .end: usize = 22
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 17
                    .end: usize = 18
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 15
                          .end: usize = 16
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .ParserVar: u32 = 242
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 19
                          .end: usize = 20
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .ParserVar: u32 = 818
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 23
                    .end: usize = 24
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .ParserVar: u32 = 824

