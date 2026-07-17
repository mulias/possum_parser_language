  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/repeat.possum -i '' --no-stdlib
  (Import 1:0-13 stdlib/util)
  
  (DeclareGlobal 3:0-17
    (Function 3:0-7
      (Identifier 3:0-4 many) [
        (Identifier 3:5-6 p)
      ])
    (Repeat 3:10-17
      (Identifier 3:10-11 p)
      (Range 3:14-17 (NumberString 3:14-15 1) ())))
  
  (DeclareGlobal 5:0-40
    (Function 5:0-16
      (Identifier 5:0-8 many_sep) [
        (Identifier 5:9-10 p)
        (Identifier 5:12-15 sep)
      ])
    (Merge 5:19-40
      (Identifier 5:19-20 p)
      (Repeat 5:23-40
        (TakeRight 5:24-33
          (Identifier 5:25-28 sep)
          (Identifier 5:31-32 p))
        (Range 5:36-39 (NumberString 5:36-37 0) ()))))
  
  (DeclareGlobal 7:0-56
    (Function 7:0-19
      (Identifier 7:0-10 many_until) [
        (Identifier 7:11-12 p)
        (Identifier 7:14-18 stop)
      ])
    (TakeLeft 7:22-56
      (Repeat 7:22-43
        (Function 7:22-37
          (Identifier 7:22-28 unless) [
            (Identifier 7:29-30 p)
            (Identifier 7:32-36 stop)
          ])
        (Range 7:40-43 (NumberString 7:40-41 1) ()))
      (Function 7:46-56
        (Identifier 7:46-50 peek) [
          (Identifier 7:51-55 stop)
        ])))
  
  (DeclareGlobal 9:0-23
    (Function 9:0-13
      (Identifier 9:0-10 maybe_many) [
        (Identifier 9:11-12 p)
      ])
    (Repeat 9:16-23
      (Identifier 9:16-17 p)
      (Range 9:20-23 (NumberString 9:20-21 0) ())))
  
  (DeclareGlobal 11:0-51
    (Function 11:0-22
      (Identifier 11:0-14 maybe_many_sep) [
        (Identifier 11:15-16 p)
        (Identifier 11:18-21 sep)
      ])
    (Or 11:25-51
      (Function 11:25-41
        (Identifier 11:25-33 many_sep) [
          (Identifier 11:34-35 p)
          (Identifier 11:37-40 sep)
        ])
      (Identifier 11:44-51 succeed)))
