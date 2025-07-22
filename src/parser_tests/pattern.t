  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  (Destructure 0-24
    (NumberString 0-1 5)
    (Merge 6-24
      (Merge 6-15
        (Merge 6-11
          (NumberString 6-7 1)
          (NumberString 10-11 6)
        (NumberString 14-15 3)
      (Negation 19-24
        (Merge 19-24
          (NumberString 19-20 2)
          (NumberString 23-24 3)
