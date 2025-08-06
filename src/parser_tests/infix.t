  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"a" > "b" > "c" | "abz"' -i ''
  (Or 1:0-23
    (TakeRight 1:0-15
      (TakeRight 1:0-9
        (String 1:0-3 "a")
        (String 1:6-9 "b"))
      (String 1:12-15 "c"))
    (String 1:18-23 "abz"))

  $ possum -p '"" $ (1-2)' -i ''
  (Return 1:0-10
    (String 1:0-2 "")
    (Merge 1:5-10
      (NumberString 1:6-7 1)
      (Negation 1:8-9 (NumberString 1:8-9 2))))
