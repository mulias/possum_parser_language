  $ export PRINT_AST=true RUN_VM=false

  $ possum -p 'foo(a, b, c) = a + b + c' -i ''
  (DeclareGlobal 0-24
    (Function 0-12
      (ParserVar 0-3 foo)
      ((ParserVar 4-5 a)
       (ParserVar 7-8 b)
       (ParserVar 10-11 c)))
    (Merge 15-24
      (Merge 15-20
        (ParserVar 15-16 a)
        (ParserVar 19-20 b))
      (ParserVar 23-24 c)))

