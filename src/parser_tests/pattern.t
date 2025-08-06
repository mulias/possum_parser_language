  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '5 -> (1 + 6 + 3 - (2 + 3))' -i '5'
  (Destructure 1:0-26
    (NumberString 1:0-1 5)
    (Merge 1:5-26
      (Merge 1:6-15
        (Merge 1:6-11
          (NumberString 1:6-7 1)
          (NumberString 1:10-11 6))
        (NumberString 1:14-15 3))
      (Negation 1:18-25
        (Merge 1:18-25
          (NumberString 1:19-20 2)
          (NumberString 1:23-24 3)))))
