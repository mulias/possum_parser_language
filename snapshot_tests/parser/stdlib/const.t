  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/const.possum -i '' --no-stdlib
  (DeclareGlobal 1:0-18
    (Function 1:0-7
      (True 1:0-4) [
        (Identifier 1:5-6 t)
      ])
    (Return 1:10-18
      (Identifier 1:10-11 t)
      (True 1:14-18)))
  
  (DeclareGlobal 3:0-20
    (Function 3:0-8
      (False 3:0-5) [
        (Identifier 3:6-7 f)
      ])
    (Return 3:11-20
      (Identifier 3:11-12 f)
      (False 3:15-20)))
  
  (DeclareGlobal 5:0-34
    (Function 5:0-13
      (Identifier 5:0-7 boolean) [
        (Identifier 5:8-9 t)
        (Identifier 5:11-12 f)
      ])
    (Or 5:16-34
      (Function 5:16-23
        (True 5:16-20) [
          (Identifier 5:21-22 t)
        ])
      (Function 5:26-34
        (False 5:26-31) [
          (Identifier 5:32-33 f)
        ])))
  
  (DeclareGlobal 7:0-14
    (Identifier 7:0-4 bool)
    (Identifier 7:7-14 boolean))
  
  (DeclareGlobal 9:0-18
    (Function 9:0-7
      (Null 9:0-4) [
        (Identifier 9:5-6 n)
      ])
    (Return 9:10-18
      (Identifier 9:10-11 n)
      (Null 9:14-18)))
