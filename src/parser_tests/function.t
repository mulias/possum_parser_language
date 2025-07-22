  $ export PRINT_AST=true RUN_VM=false

  $ possum -p 'foo(a, b, c) = a + b + c' -i ''
  (DeclareGlobal 0-24
    (CallOrDefineFunction 0-11
      (ParserVar 0-3 foo)
      (ParamsOrArgs 4-11
        (ParserVar 4-5 a)
        (ParamsOrArgs 7-11
          (ParserVar 7-8 b)
          (ParserVar 10-11 c)
    (Merge 15-24
      (Merge 15-20
        (ParserVar 15-16 a)
        (ParserVar 19-20 b)
      (ParserVar 23-24 c)

