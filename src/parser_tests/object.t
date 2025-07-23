  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ {}' -i ''
  (Return 0-7
    (String 0-2 "")
    (Object 5-7))

  $ possum -p '"" $ {"a": 1}' -i ''
  (Return 0-13
    (String 0-2 "")
    (Object 5-13
      ((String 6-9 "a") (NumberString 11-12 1))))

  $ possum -p '"" $ {A: 1,}' -i ''
  (Return 0-12
    (String 0-2 "")
    (Object 5-12
      ((ValueVar 6-7 A) (NumberString 9-10 1))))

  $ possum -p '"" $ {...{"x": Z}}' -i ''
  (Return 0-17
    (String 0-2 "")
    (Merge 9-17
      (Object 5-6)
      (Object 9-17
        ((String 10-13 "x") (ValueVar 15-16 Z)))))

  $ possum -p '"" $ {...{"x": Z},}' -i ''
  (Return 0-17
    (String 0-2 "")
    (Merge 9-17
      (Object 5-6)
      (Object 9-17
        ((String 10-13 "x") (ValueVar 15-16 Z)))))

  $ possum -p '"" $ {...{"a": 1}, ...{"b": 2}}' -i ''
  (Return 0-30
    (String 0-2 "")
    (Merge 9-30
      (Merge 9-17
        (Object 5-6)
        (Object 9-17
          ((String 10-13 "a") (NumberString 15-16 1))))
      (Object 22-30
        ((String 23-26 "b") (NumberString 28-29 2)))))

  $ possum -p '"" $ {"a": 1, ...{"b": 2}}' -i ''
  (Return 0-25
    (String 0-2 "")
    (Merge 17-25
      (Object 5-17
        ((String 6-9 "a") (NumberString 11-12 1)))
      (Object 17-25
        ((String 18-21 "b") (NumberString 23-24 2)))))

  $ possum -p '"" $ {"a": 1, ...{"b": 2}, "c": 3}' -i ''
  (Return 0-28
    (String 0-2 "")
    (Merge 17-28
      (Merge 17-25
        (Object 5-17
          ((String 6-9 "a") (NumberString 11-12 1)))
        (Object 17-25
          ((String 18-21 "b") (NumberString 23-24 2))))
      (Object 27-28
        ((String 27-30 "c") (NumberString 32-33 3)))))

  $ possum -p '"" $ {...{"a": 1}, "b": 2, ...{"c": 3}}' -i ''
  (Return 0-38
    (String 0-2 "")
    (Merge 9-38
      (Merge 9-17
        (Object 5-6)
        (Object 9-17
          ((String 10-13 "a") (NumberString 15-16 1))))
      (Merge 19-38
        (Object 19-20
          ((String 19-22 "b") (NumberString 24-25 2)))
        (Object 30-38
          ((String 31-34 "c") (NumberString 36-37 3))))))

  $ possum -p '"" $ {"a": 1 "b": 2}' -i ''
  "" $ {"a": 1 "b": 2}
               ^
  Error at '"': Expected closing '}'
  error.UnexpectedInput
  [1]

  $ possum -p '"" $ {"a": 1, "b": 2,,}' -i ''
  "" $ {"a": 1, "b": 2,,}
                       ^
  Error at ',': Expected object member key
  error.UnexpectedInput
  [1]

  $ possum -p '"" $ {...{} ...{}}' -i ''
  "" $ {...{} ...{}}
              ^^^
  Error at '...': Expected closing '}'
  error.UnexpectedInput
  [1]

  $ possum -p '"" $ {...{}, ...{} ...{}}' -i ''
  "" $ {...{}, ...{} ...{}}
                     ^^^
  Error at '...': Expected closing '}'
  error.UnexpectedInput
  [1]
