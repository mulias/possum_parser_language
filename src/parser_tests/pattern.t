  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 2
        .end: usize = 4
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .Destructure
          .left: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 0
              .end: usize = 1
            .node: ast.Ast.Node
              .ElemNode: elem.Elem
                .NumberString: elem.Elem.NumberStringElem
                  .sId: u32 = 5954
                  .format: elem.Elem.NumberStringElem.Format
                    .Integer
                  .negated: bool = false
          .right: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 16
              .end: usize = 17
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 12
                    .end: usize = 13
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 8
                          .end: usize = 9
                        .node: ast.Ast.Node
                          .InfixNode: ast.Ast.Infix
                            .infixType: ast.Ast.InfixType
                              .Merge
                            .left: *ast.Ast.RNode
                              .region: region.Region
                                .start: usize = 6
                                .end: usize = 7
                              .node: ast.Ast.Node
                                .ElemNode: elem.Elem
                                  .NumberString: elem.Elem.NumberStringElem
                                    .sId: u32 = 786
                                    .format: elem.Elem.NumberStringElem.Format
                                      .Integer
                                    .negated: bool = false
                            .right: *ast.Ast.RNode
                              .region: region.Region
                                .start: usize = 10
                                .end: usize = 11
                              .node: ast.Ast.Node
                                .ElemNode: elem.Elem
                                  .NumberString: elem.Elem.NumberStringElem
                                    .sId: u32 = 5957
                                    .format: elem.Elem.NumberStringElem.Format
                                      .Integer
                                    .negated: bool = false
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 14
                          .end: usize = 15
                        .node: ast.Ast.Node
                          .ElemNode: elem.Elem
                            .NumberString: elem.Elem.NumberStringElem
                              .sId: u32 = 5960
                              .format: elem.Elem.NumberStringElem.Format
                                .Integer
                              .negated: bool = false
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 21
                    .end: usize = 22
                  .node: ast.Ast.Node
                    .Negation: *ast.Ast.RNode
                      .region: region.Region
                        .start: usize = 21
                        .end: usize = 22
                      .node: ast.Ast.Node
                        .InfixNode: ast.Ast.Infix
                          .infixType: ast.Ast.InfixType
                            .Merge
                          .left: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 19
                              .end: usize = 20
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .NumberString: elem.Elem.NumberStringElem
                                  .sId: u32 = 4644
                                  .format: elem.Elem.NumberStringElem.Format
                                    .Integer
                                  .negated: bool = false
                          .right: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 23
                              .end: usize = 24
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .NumberString: elem.Elem.NumberStringElem
                                  .sId: u32 = 5960
                                  .format: elem.Elem.NumberStringElem.Format
                                    .Integer
                                  .negated: bool = false
