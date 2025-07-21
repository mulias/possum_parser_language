  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ []' -i ''
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
              .end: usize = 7
            .node: ast.Ast.Node
              .Array: array_list.ArrayListAlignedUnmanaged(..)
                .items: []*ast.Ast.RNode
                  (empty)
                .capacity: usize = 0

  $ possum -p '"" $ [1, 2, 3]' -i ''
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
              .end: usize = 14
            .node: ast.Ast.Node
              .Array: array_list.ArrayListAlignedUnmanaged(..)
                .items: []*ast.Ast.RNode
                  *ast.Ast.RNode
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
                  *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 9
                      .end: usize = 10
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .NumberString: elem.Elem.NumberStringElem
                          .sId: u32 = 4644
                          .format: elem.Elem.NumberStringElem.Format
                            .Integer
                          .negated: bool = false
                  *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 12
                      .end: usize = 13
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .NumberString: elem.Elem.NumberStringElem
                          .sId: u32 = 5954
                          .format: elem.Elem.NumberStringElem.Format
                            .Integer
                          .negated: bool = false
                .capacity: usize = 16

  $ possum -p '"" $ [1, 2, 3,]' -i ''
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
              .end: usize = 15
            .node: ast.Ast.Node
              .Array: array_list.ArrayListAlignedUnmanaged(..)
                .items: []*ast.Ast.RNode
                  *ast.Ast.RNode
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
                  *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 9
                      .end: usize = 10
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .NumberString: elem.Elem.NumberStringElem
                          .sId: u32 = 4644
                          .format: elem.Elem.NumberStringElem.Format
                            .Integer
                          .negated: bool = false
                  *ast.Ast.RNode
                    .region: region.Region
                      .start: usize = 12
                      .end: usize = 13
                    .node: ast.Ast.Node
                      .ElemNode: elem.Elem
                        .NumberString: elem.Elem.NumberStringElem
                          .sId: u32 = 5954
                          .format: elem.Elem.NumberStringElem.Format
                            .Integer
                          .negated: bool = false
                .capacity: usize = 16

  $ possum -p '"" $ [...[1]]' -i ''
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
              .start: usize = 6
              .end: usize = 9
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 5
                    .end: usize = 6
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        (empty)
                      .capacity: usize = 0
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 9
                    .end: usize = 12
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        *ast.Ast.RNode
                          .region: region.Region
                            .start: usize = 10
                            .end: usize = 11
                          .node: ast.Ast.Node
                            .ElemNode: elem.Elem
                              .NumberString: elem.Elem.NumberStringElem
                                .sId: u32 = 786
                                .format: elem.Elem.NumberStringElem.Format
                                  .Integer
                                .negated: bool = false
                      .capacity: usize = 16

  $ possum -p '"" $ [...[1],]' -i ''
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
              .start: usize = 6
              .end: usize = 9
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 5
                    .end: usize = 6
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        (empty)
                      .capacity: usize = 0
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 9
                    .end: usize = 12
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        *ast.Ast.RNode
                          .region: region.Region
                            .start: usize = 10
                            .end: usize = 11
                          .node: ast.Ast.Node
                            .ElemNode: elem.Elem
                              .NumberString: elem.Elem.NumberStringElem
                                .sId: u32 = 786
                                .format: elem.Elem.NumberStringElem.Format
                                  .Integer
                                .negated: bool = false
                      .capacity: usize = 16

  $ possum -p '"" $ [...[1], ...[2]]' -i ''
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
              .start: usize = 12
              .end: usize = 13
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 6
                    .end: usize = 9
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 5
                          .end: usize = 6
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              (empty)
                            .capacity: usize = 0
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 9
                          .end: usize = 12
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              *ast.Ast.RNode
                                .region: region.Region
                                  .start: usize = 10
                                  .end: usize = 11
                                .node: ast.Ast.Node
                                  .ElemNode: elem.Elem
                                    .NumberString: elem.Elem.NumberStringElem
                                      .sId: u32 = 786
                                      .format: elem.Elem.NumberStringElem.Format
                                        .Integer
                                      .negated: bool = false
                            .capacity: usize = 16
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 17
                    .end: usize = 20
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        *ast.Ast.RNode
                          .region: region.Region
                            .start: usize = 18
                            .end: usize = 19
                          .node: ast.Ast.Node
                            .ElemNode: elem.Elem
                              .NumberString: elem.Elem.NumberStringElem
                                .sId: u32 = 4644
                                .format: elem.Elem.NumberStringElem.Format
                                  .Integer
                                .negated: bool = false
                      .capacity: usize = 16


  $ possum -p '"" $ [1, ...[2]]' -i ''
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
              .start: usize = 9
              .end: usize = 12
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 5
                    .end: usize = 6
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        *ast.Ast.RNode
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
                      .capacity: usize = 16
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 12
                    .end: usize = 15
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        *ast.Ast.RNode
                          .region: region.Region
                            .start: usize = 13
                            .end: usize = 14
                          .node: ast.Ast.Node
                            .ElemNode: elem.Elem
                              .NumberString: elem.Elem.NumberStringElem
                                .sId: u32 = 4644
                                .format: elem.Elem.NumberStringElem.Format
                                  .Integer
                                .negated: bool = false
                      .capacity: usize = 16

  $ possum -p '"" $ [1, ...[2], 3]' -i ''
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
              .start: usize = 15
              .end: usize = 16
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 9
                    .end: usize = 12
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 5
                          .end: usize = 6
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              *ast.Ast.RNode
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
                            .capacity: usize = 16
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 12
                          .end: usize = 15
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              *ast.Ast.RNode
                                .region: region.Region
                                  .start: usize = 13
                                  .end: usize = 14
                                .node: ast.Ast.Node
                                  .ElemNode: elem.Elem
                                    .NumberString: elem.Elem.NumberStringElem
                                      .sId: u32 = 4644
                                      .format: elem.Elem.NumberStringElem.Format
                                        .Integer
                                      .negated: bool = false
                            .capacity: usize = 16
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 17
                    .end: usize = 19
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        *ast.Ast.RNode
                          .region: region.Region
                            .start: usize = 17
                            .end: usize = 18
                          .node: ast.Ast.Node
                            .ElemNode: elem.Elem
                              .NumberString: elem.Elem.NumberStringElem
                                .sId: u32 = 5954
                                .format: elem.Elem.NumberStringElem.Format
                                  .Integer
                                .negated: bool = false
                      .capacity: usize = 16

  $ possum -p '"" $ [...[1], 2, ...[3]]' -i ''
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
              .start: usize = 12
              .end: usize = 13
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 6
                    .end: usize = 9
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 5
                          .end: usize = 6
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              (empty)
                            .capacity: usize = 0
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 9
                          .end: usize = 12
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              *ast.Ast.RNode
                                .region: region.Region
                                  .start: usize = 10
                                  .end: usize = 11
                                .node: ast.Ast.Node
                                  .ElemNode: elem.Elem
                                    .NumberString: elem.Elem.NumberStringElem
                                      .sId: u32 = 786
                                      .format: elem.Elem.NumberStringElem.Format
                                        .Integer
                                      .negated: bool = false
                            .capacity: usize = 16
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 22
                    .end: usize = 23
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 14
                          .end: usize = 15
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              *ast.Ast.RNode
                                .region: region.Region
                                  .start: usize = 14
                                  .end: usize = 15
                                .node: ast.Ast.Node
                                  .ElemNode: elem.Elem
                                    .NumberString: elem.Elem.NumberStringElem
                                      .sId: u32 = 4644
                                      .format: elem.Elem.NumberStringElem.Format
                                        .Integer
                                      .negated: bool = false
                            .capacity: usize = 16
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 20
                          .end: usize = 23
                        .node: ast.Ast.Node
                          .Array: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []*ast.Ast.RNode
                              *ast.Ast.RNode
                                .region: region.Region
                                  .start: usize = 21
                                  .end: usize = 22
                                .node: ast.Ast.Node
                                  .ElemNode: elem.Elem
                                    .NumberString: elem.Elem.NumberStringElem
                                      .sId: u32 = 5954
                                      .format: elem.Elem.NumberStringElem.Format
                                        .Integer
                                      .negated: bool = false
                            .capacity: usize = 16

  $ possum -p '"" -> [..._]' -i ''
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
              .start: usize = 7
              .end: usize = 10
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 6
                    .end: usize = 7
                  .node: ast.Ast.Node
                    .Array: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []*ast.Ast.RNode
                        (empty)
                      .capacity: usize = 0
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 10
                    .end: usize = 11
                  .node: ast.Ast.Node
                    .ElemNode: elem.Elem
                      .ValueVar: u32 = 398

  $ possum -p '"" $ [1, 2 3]' -i '' 2> /dev/null || echo "missing comma error"
  missing comma error

  $ possum -p '"" $ [1, 2, 3,,]' -i '' 2> /dev/null || echo "too much comma error"
  too much comma error

  $ possum -p '"" $ [...[] ...[]]' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error

  $ possum -p '"" $ [...[], ...[] ...[]]' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error
