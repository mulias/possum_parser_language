  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '""' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 2
      .node: ast.Ast.Node
        .ElemNode: elem.Elem
          .String: u32 = 1919

  $ possum -p '"hello"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 7
      .node: ast.Ast.Node
        .ElemNode: elem.Elem
          .String: u32 = 5954

  $ possum -p "'world'" -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 7
      .node: ast.Ast.Node
        .ElemNode: elem.Elem
          .String: u32 = 5954

  $ possum -p '"%(word)"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 9
      .node: ast.Ast.Node
        .StringTemplate: array_list.ArrayListAlignedUnmanaged(..)
          .items: []*ast.Ast.RNode
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 9
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .String: u32 = 1919
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 4
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .ParserVar: u32 = 393
          .capacity: usize = 16

  $ possum -p '"Hello %(word)"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 15
      .node: ast.Ast.Node
        .StringTemplate: array_list.ArrayListAlignedUnmanaged(..)
          .items: []*ast.Ast.RNode
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 15
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .String: u32 = 5954
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 4
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .ParserVar: u32 = 393
          .capacity: usize = 16

  $ possum -p '"%(word) World"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 15
      .node: ast.Ast.Node
        .StringTemplate: array_list.ArrayListAlignedUnmanaged(..)
          .items: []*ast.Ast.RNode
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 15
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .String: u32 = 1919
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 4
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .ParserVar: u32 = 393
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 4
                .end: usize = 5
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .String: u32 = 5954
          .capacity: usize = 16

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 27
      .node: ast.Ast.Node
        .StringTemplate: array_list.ArrayListAlignedUnmanaged(..)
          .items: []*ast.Ast.RNode
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 27
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .String: u32 = 5954
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 4
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .ParserVar: u32 = 393
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 4
                .end: usize = 5
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .String: u32 = 5961
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 4
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .ParserVar: u32 = 393
          .capacity: usize = 16

  $ possum -p '"" $ "%(5)"' -i ''
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
                .String: u32 = 1919
          .right: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 5
              .end: usize = 11
            .node: ast.Ast.Node
              .StringTemplate: array_list.ArrayListAlignedUnmanaged(..)
                .items: []*ast.Ast.RNode
                  *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 5
                      .end: usize = 11
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .String: u32 = 1919
                  *ast.Ast.RNode
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
                .capacity: usize = 16

  $ possum -p '"" -> "%(Str)"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 3
        .end: usize = 5
      .node: ast.Ast.Node
        .InfixNode: ast.Ast.Infix
          .infixType: ast.Ast.InfixType
            .Destructure
          .left: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 0
              .end: usize = 2
            .node: ast.Ast.Node
              .ElemNode: elem.Elem
                .String: u32 = 1919
          .right: *ast.Ast.RNode
            .region: region.Region
              .start: usize = 6
              .end: usize = 14
            .node: ast.Ast.Node
              .StringTemplate: array_list.ArrayListAlignedUnmanaged(..)
                .items: []*ast.Ast.RNode
                  *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 6
                      .end: usize = 14
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .String: u32 = 1919
                  *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 0
                      .end: usize = 3
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .ValueVar: u32 = 5954
                .capacity: usize = 16

  $ possum -p '"Hello %(int + word)"' -i ''
  []*ast.Ast.RNode
    *ast.Ast.RNode
      .region: region.Region
        .start: usize = 0
        .end: usize = 21
      .node: ast.Ast.Node
        .StringTemplate: array_list.ArrayListAlignedUnmanaged(..)
          .items: []*ast.Ast.RNode
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 0
                .end: usize = 21
              .node: ast.Ast.Node
                .ElemNode: elem.Elem
                  .String: u32 = 5954
            *ast.Ast.RNode
              .region: region.Region
                .start: usize = 4
                .end: usize = 5
              .node: ast.Ast.Node
                .InfixNode: ast.Ast.Infix
                  .infixType: ast.Ast.InfixType
                    .Merge
                  .left: *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 0
                      .end: usize = 3
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .ParserVar: u32 = 590
                  .right: *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 6
                      .end: usize = 10
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .ParserVar: u32 = 393
          .capacity: usize = 16
