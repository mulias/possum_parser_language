  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/cast_value.possum -i '' --no-stdlib
  (Import 1:0-18 stdlib/Predicate private)
  
  (DeclareGlobal 3:0-51
    (Function 3:0-12
      (Identifier 3:0-9 As.Number) [
        (Identifier 3:10-11 V)
      ])
    (Or 3:15-51
      (Function 3:15-27
        (Identifier 3:15-24 Is.Number) [
          (Identifier 3:25-26 V)
        ])
      (Return 3:30-51
        (Destructure 3:31-46
          (Identifier 3:31-32 V)
          (StringTemplate 3:36-46 [
            (Merge 3:39-44
              (NumberString 3:39-40 0)
              (Identifier 3:43-44 N))
          ]))
        (Identifier 3:49-50 N))))
  
  (DeclareGlobal 5:0-21
    (Function 5:0-12
      (Identifier 5:0-9 As.String) [
        (Identifier 5:10-11 V)
      ])
    (StringTemplate 5:15-21 [
      (Identifier 5:18-19 V)
    ]))
