  $ export PRINT_AST=true RUN_VM=false

  $ possum -p 'foo(a, b, c) = a + b + c' -i ''
  (DeclareGlobal 1:0-24
    (Function 1:0-12
      (Identifier 1:0-3 foo) [
        (Identifier 1:4-5 a)
        (Identifier 1:7-8 b)
        (Identifier 1:10-11 c)
      ])
    (Merge 1:15-24
      (Merge 1:15-20
        (Identifier 1:15-16 a)
        (Identifier 1:19-20 b))
      (Identifier 1:23-24 c)))

