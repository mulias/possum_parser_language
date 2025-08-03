  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '1 -> 0..9' -i ''
  (Destructure 0-9
    (NumberString 0-1 1)
    (Range 5-9 (NumberString 5-6 0) (NumberString 8-9 9)))

  $ possum -p '1 -> ..9' -i ''
  (Destructure 0-8
    (NumberString 0-1 1)
    (Range 5-8 () (NumberString 7-8 9)))

  $ possum -p '1 -> 88..' -i ''
  (Destructure 0-9
    (NumberString 0-1 1)
    (Range 5-9 (NumberString 5-7 88) ()))

  $ possum -p '1 -> ..' -i ''
  
  Error at end: Expect expression.
  
  1 -> ..
  
  [UnexpectedInput]
  [1]

  $ possum -p '1 -> --4..(8 + 77)' -i ''
  (Destructure 0-18
    (NumberString 0-1 1)
    (Range 5-18
      (Negation 5-8 (Negation 6-8 (NumberString 7-8 4)))
      (Merge 10-18
        (NumberString 11-12 8)
        (NumberString 15-17 77))))
