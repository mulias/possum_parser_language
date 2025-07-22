  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  (Destructure 2-4
    (NumberString 0-1 5)
    (Merge 16-17
      (Merge 12-13
        (Merge 8-9
          (NumberString 6-7 1)
          (NumberString 10-11 6)
        (NumberString 14-15 3)
      (Negation 21-22
        (Merge 21-22
          (NumberString 19-20 2)
          (NumberString 23-24 3)
