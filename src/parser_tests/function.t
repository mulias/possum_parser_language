  $ export PRINT_AST=true RUN_VM=false

  $ possum -p 'foo(a, b, c) = a + b + c' -i ''
  (DeclareGlobal 1:0-24
    (Function 1:0-12
      (ParserVar 1:0-3 foo)
      ((ParserVar 1:4-5 a)
       (ParserVar 1:7-8 b)
       (ParserVar 1:10-11 c)))
    (Merge 1:15-24
      (Merge 1:15-20
        (ParserVar 1:15-16 a)
        (ParserVar 1:19-20 b))
      (ParserVar 1:23-24 c)))

