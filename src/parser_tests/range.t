  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '1 -> 0..9' -i ''
  (Destructure 1:0-9
    (NumberString 1:0-1 1)
    (Range 1:5-9 (NumberString 1:5-6 0) (NumberString 1:8-9 9)))

  $ possum -p '1 -> ..9' -i ''
  (Destructure 1:0-8
    (NumberString 1:0-1 1)
    (Range 1:5-8 () (NumberString 1:7-8 9)))

  $ possum -p '1 -> 88..' -i ''
  (Destructure 1:0-9
    (NumberString 1:0-1 1)
    (Range 1:5-9 (NumberString 1:5-7 88) ()))

  $ possum -p '1 -> ..' -i ''
  
  Syntax Error: expected expression, found end of program
  
  program:1:7:
  1 \xe2\x96\x8f 1 -> .. (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '1 -> --4..(8 + 77)' -i ''
  (Destructure 1:0-18
    (NumberString 1:0-1 1)
    (Range 1:5-18
      (Negation 1:5-8 (Negation 1:6-8 (NumberString 1:7-8 4)))
      (Merge 1:10-18
        (NumberString 1:11-12 8)
        (NumberString 1:15-17 77))))
