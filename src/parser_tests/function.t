  $ export PRINT_AST=true RUN_VM=false

  $ possum -p 'foo(a, b, c) = a + b + c' -i ''
  (DeclareGlobal 13-14
    (CallOrDefineFunction 3-4
      (ParserVar 0-3 foo)
      (ParamsOrArgs 5-6
        (ParserVar 4-5 a)
        (ParamsOrArgs 8-9
          (ParserVar 7-8 b)
          (ParserVar 10-11 c)
    (Merge 21-22
      (Merge 17-18
        (ParserVar 15-16 a)
        (ParserVar 19-20 b)
      (ParserVar 23-24 c)

