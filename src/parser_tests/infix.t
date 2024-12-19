  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"a" > "b" > "c" | "abz"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 16
        .end: usize = 17
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .Or
          .left: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 10
              .end: usize = 11
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .TakeRight
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 4
                    .end: usize = 5
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .TakeRight
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 0
                          .end: usize = 3
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .String: u32 = 242
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 6
                          .end: usize = 9
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .String: u32 = 818
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 12
                    .end: usize = 15
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .String: u32 = 824
          .right: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 18
              .end: usize = 23
            .node: ast.Ast.Node
              .ElemNode: elem.Elem
                .String: u32 = 5317

  $ possum -p '"" $ (1-2)' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 3
        .end: usize = 4
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .Return
          .left: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 0
              .end: usize = 2
            .node: ast.Ast.Node
              .ElemNode: elem.Elem
                .String: u32 = 1768
          .right: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 7
              .end: usize = 8
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .NumberSubtract
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 6
                    .end: usize = 7
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .NumberString: elem.Elem.NumberString
                        .sId: u32 = 786
                        .format: elem.Elem.NumberString.Format
                          .Integer
                        .negated: bool = false
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 8
                    .end: usize = 9
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .NumberString: elem.Elem.NumberString
                        .sId: u32 = 3979
                        .format: elem.Elem.NumberString.Format
                          .Integer
                        .negated: bool = false
