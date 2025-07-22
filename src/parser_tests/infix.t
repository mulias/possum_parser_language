  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"a" > "b" > "c" | "abz"' -i ''
  (Or 0-23
    (TakeRight 0-15
      (TakeRight 0-9
        (String 0-3 "a")
        (String 6-9 "b")
      (String 12-15 "c")
    (String 18-23 "abz")

  $ possum -p '"" $ (1-2)' -i ''
  (Return 0-9
    (String 0-2 "")
    (Merge 6-9
      (NumberString 6-7 1)
      (Negation 8-9 (NumberString 8-9 2))
