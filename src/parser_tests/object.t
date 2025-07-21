  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ {}' -i ''
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
              .end: usize = 6
            .node: ast.Ast.Node
              .Object: array_list.ArrayListAlignedUnmanaged(..)
                .items: []ast.Ast.ObjectPair
                  (empty)
                .capacity: usize = 0

  $ possum -p '"" $ {"a": 1}' -i ''
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
              .end: usize = 6
            .node: ast.Ast.Node
              .Object: array_list.ArrayListAlignedUnmanaged(..)
                .items: []ast.Ast.ObjectPair
                  ast.Ast.ObjectPair
                    .key: *ast.Ast.RNode
                      .region: region.Region
                        .start: usize = 6
                        .end: usize = 9
                      .node: ast.Ast.Node
                        .ElemNode: elem.Elem
                          .String: u32 = 242
                    .value: *ast.Ast.RNode
                      .region: region.Region
                        .start: usize = 11
                        .end: usize = 12
                      .node: ast.Ast.Node
                        .ElemNode: elem.Elem
                          .NumberString: elem.Elem.NumberStringElem
                            .sId: u32 = 786
                            .format: elem.Elem.NumberStringElem.Format
                              .Integer
                            .negated: bool = false
                .capacity: usize = 8

  $ possum -p '"" $ {A: 1,}' -i ''
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
              .end: usize = 6
            .node: ast.Ast.Node
              .Object: array_list.ArrayListAlignedUnmanaged(..)
                .items: []ast.Ast.ObjectPair
                  ast.Ast.ObjectPair
                    .key: *ast.Ast.RNode
                      .region: region.Region
                        .start: usize = 6
                        .end: usize = 7
                      .node: ast.Ast.Node
                        .ElemNode: elem.Elem
                          .ValueVar: u32 = 139
                    .value: *ast.Ast.RNode
                      .region: region.Region
                        .start: usize = 9
                        .end: usize = 10
                      .node: ast.Ast.Node
                        .ElemNode: elem.Elem
                          .NumberString: elem.Elem.NumberStringElem
                            .sId: u32 = 786
                            .format: elem.Elem.NumberStringElem.Format
                              .Integer
                            .negated: bool = false
                .capacity: usize = 8

  $ possum -p '"" $ {...{"x": Z}}' -i ''
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
              .end: usize = 10
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 5
                    .end: usize = 6
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        (empty)
                      .capacity: usize = 0
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 9
                    .end: usize = 10
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        ast.Ast.ObjectPair
                          .key: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 10
                              .end: usize = 13
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .String: u32 = 5954
                          .value: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 15
                              .end: usize = 16
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .ValueVar: u32 = 246
                      .capacity: usize = 8

  $ possum -p '"" $ {...{"x": Z},}' -i ''
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
              .end: usize = 10
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 5
                    .end: usize = 6
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        (empty)
                      .capacity: usize = 0
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 9
                    .end: usize = 10
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        ast.Ast.ObjectPair
                          .key: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 10
                              .end: usize = 13
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .String: u32 = 5954
                          .value: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 15
                              .end: usize = 16
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .ValueVar: u32 = 246
                      .capacity: usize = 8

  $ possum -p '"" $ {...{"a": 1}, ...{"b": 2}}' -i ''
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
              .start: usize = 17
              .end: usize = 18
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 6
                    .end: usize = 10
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 5
                          .end: usize = 6
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              (empty)
                            .capacity: usize = 0
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 9
                          .end: usize = 10
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              ast.Ast.ObjectPair
                                .key: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 10
                                    .end: usize = 13
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .String: u32 = 242
                                .value: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 15
                                    .end: usize = 16
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .NumberString: elem.Elem.NumberStringElem
                                        .sId: u32 = 786
                                        .format: elem.Elem.NumberStringElem.Format
                                          .Integer
                                        .negated: bool = false
                            .capacity: usize = 8
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 22
                    .end: usize = 23
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        ast.Ast.ObjectPair
                          .key: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 23
                              .end: usize = 26
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .String: u32 = 818
                          .value: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 28
                              .end: usize = 29
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .NumberString: elem.Elem.NumberStringElem
                                  .sId: u32 = 4644
                                  .format: elem.Elem.NumberStringElem.Format
                                    .Integer
                                  .negated: bool = false
                      .capacity: usize = 8

  $ possum -p '"" $ {"a": 1, ...{"b": 2}}' -i ''
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
              .start: usize = 14
              .end: usize = 18
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 5
                    .end: usize = 6
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        ast.Ast.ObjectPair
                          .key: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 6
                              .end: usize = 9
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .String: u32 = 242
                          .value: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 11
                              .end: usize = 12
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .NumberString: elem.Elem.NumberStringElem
                                  .sId: u32 = 786
                                  .format: elem.Elem.NumberStringElem.Format
                                    .Integer
                                  .negated: bool = false
                      .capacity: usize = 8
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 17
                    .end: usize = 18
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        ast.Ast.ObjectPair
                          .key: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 18
                              .end: usize = 21
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .String: u32 = 818
                          .value: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 23
                              .end: usize = 24
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .NumberString: elem.Elem.NumberStringElem
                                  .sId: u32 = 4644
                                  .format: elem.Elem.NumberStringElem.Format
                                    .Integer
                                  .negated: bool = false
                      .capacity: usize = 8

  $ possum -p '"" $ {"a": 1, ...{"b": 2}, "c": 3}' -i ''
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
              .start: usize = 25
              .end: usize = 26
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 14
                    .end: usize = 18
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 5
                          .end: usize = 6
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              ast.Ast.ObjectPair
                                .key: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 6
                                    .end: usize = 9
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .String: u32 = 242
                                .value: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 11
                                    .end: usize = 12
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .NumberString: elem.Elem.NumberStringElem
                                        .sId: u32 = 786
                                        .format: elem.Elem.NumberStringElem.Format
                                          .Integer
                                        .negated: bool = false
                            .capacity: usize = 8
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 17
                          .end: usize = 18
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              ast.Ast.ObjectPair
                                .key: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 18
                                    .end: usize = 21
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .String: u32 = 818
                                .value: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 23
                                    .end: usize = 24
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .NumberString: elem.Elem.NumberStringElem
                                        .sId: u32 = 4644
                                        .format: elem.Elem.NumberStringElem.Format
                                          .Integer
                                        .negated: bool = false
                            .capacity: usize = 8
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 27
                    .end: usize = 30
                  .node: ast.Ast.Node
                    .Object: array_list.ArrayListAlignedUnmanaged(..)
                      .items: []ast.Ast.ObjectPair
                        ast.Ast.ObjectPair
                          .key: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 27
                              .end: usize = 30
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .String: u32 = 824
                          .value: *ast.Ast.RNode
                            .region: region.Region
                              .start: usize = 32
                              .end: usize = 33
                            .node: ast.Ast.Node
                              .ElemNode: elem.Elem
                                .NumberString: elem.Elem.NumberStringElem
                                  .sId: u32 = 5954
                                  .format: elem.Elem.NumberStringElem.Format
                                    .Integer
                                  .negated: bool = false
                      .capacity: usize = 8

  $ possum -p '"" $ {...{"a": 1}, "b": 2, ...{"c": 3}}' -i ''
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
              .start: usize = 17
              .end: usize = 18
            .node: ast.Ast.Node
              .InfixNode: ast.Ast.Infix
                .infixType: ast.Ast.InfixType
                  .Merge
                .left: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 6
                    .end: usize = 10
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 5
                          .end: usize = 6
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              (empty)
                            .capacity: usize = 0
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 9
                          .end: usize = 10
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              ast.Ast.ObjectPair
                                .key: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 10
                                    .end: usize = 13
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .String: u32 = 242
                                .value: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 15
                                    .end: usize = 16
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .NumberString: elem.Elem.NumberStringElem
                                        .sId: u32 = 786
                                        .format: elem.Elem.NumberStringElem.Format
                                          .Integer
                                        .negated: bool = false
                            .capacity: usize = 8
                .right: *ast.Ast.RNode
                  .region: region.Region
                    .start: usize = 37
                    .end: usize = 38
                  .node: ast.Ast.Node
                    .InfixNode: ast.Ast.Infix
                      .infixType: ast.Ast.InfixType
                        .Merge
                      .left: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 19
                          .end: usize = 22
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              ast.Ast.ObjectPair
                                .key: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 19
                                    .end: usize = 22
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .String: u32 = 818
                                .value: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 24
                                    .end: usize = 25
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .NumberString: elem.Elem.NumberStringElem
                                        .sId: u32 = 4644
                                        .format: elem.Elem.NumberStringElem.Format
                                          .Integer
                                        .negated: bool = false
                            .capacity: usize = 8
                      .right: *ast.Ast.RNode
                        .region: region.Region
                          .start: usize = 30
                          .end: usize = 31
                        .node: ast.Ast.Node
                          .Object: array_list.ArrayListAlignedUnmanaged(..)
                            .items: []ast.Ast.ObjectPair
                              ast.Ast.ObjectPair
                                .key: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 31
                                    .end: usize = 34
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .String: u32 = 824
                                .value: *ast.Ast.RNode
                                  .region: region.Region
                                    .start: usize = 36
                                    .end: usize = 37
                                  .node: ast.Ast.Node
                                    .ElemNode: elem.Elem
                                      .NumberString: elem.Elem.NumberStringElem
                                        .sId: u32 = 5954
                                        .format: elem.Elem.NumberStringElem.Format
                                          .Integer
                                        .negated: bool = false
                            .capacity: usize = 8

  $ possum -p '"" $ {"a": 1 "b": 2}' -i '' 2> /dev/null || echo "missing comma error"
  missing comma error

  $ possum -p '"" $ {"a": 1, "b": 2,,}' -i '' 2> /dev/null || echo "too much comma error"
  too much comma error

  $ possum -p '"" $ {...{} ...{}}' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error

  $ possum -p '"" $ {...{}, ...{} ...{}}' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error
