  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ {}' -i ''
  (Return 0-6
    (String 0-2 "")
    (Object 5-6)

  $ possum -p '"" $ {"a": 1}' -i ''
  (Return 0-6
    (String 0-2 "")
    (Object 5-6
      ((String 6-9 "a") (NumberString 11-12 1))

  $ possum -p '"" $ {A: 1,}' -i ''
  (Return 0-6
    (String 0-2 "")
    (Object 5-6
      ((ValueVar 6-7 A) (NumberString 9-10 1))

  $ possum -p '"" $ {...{"x": Z}}' -i ''
  (Return 0-10
    (String 0-2 "")
    (Merge 6-10
      (Object 5-6)
      (Object 9-10
        ((String 10-13 "x") (ValueVar 15-16 Z))

  $ possum -p '"" $ {...{"x": Z},}' -i ''
  (Return 0-10
    (String 0-2 "")
    (Merge 6-10
      (Object 5-6)
      (Object 9-10
        ((String 10-13 "x") (ValueVar 15-16 Z))

  $ possum -p '"" $ {...{"a": 1}, ...{"b": 2}}' -i ''
  (Return 0-18
    (String 0-2 "")
    (Merge 17-18
      (Merge 6-10
        (Object 5-6)
        (Object 9-10
          ((String 10-13 "a") (NumberString 15-16 1))
      (Object 22-23
        ((String 23-26 "b") (NumberString 28-29 2))

  $ possum -p '"" $ {"a": 1, ...{"b": 2}}' -i ''
  (Return 0-18
    (String 0-2 "")
    (Merge 14-18
      (Object 5-6
        ((String 6-9 "a") (NumberString 11-12 1))
      (Object 17-18
        ((String 18-21 "b") (NumberString 23-24 2))

  $ possum -p '"" $ {"a": 1, ...{"b": 2}, "c": 3}' -i ''
  (Return 0-26
    (String 0-2 "")
    (Merge 25-26
      (Merge 14-18
        (Object 5-6
          ((String 6-9 "a") (NumberString 11-12 1))
        (Object 17-18
          ((String 18-21 "b") (NumberString 23-24 2))
      (Object 27-30
        ((String 27-30 "c") (NumberString 32-33 3))

  $ possum -p '"" $ {...{"a": 1}, "b": 2, ...{"c": 3}}' -i ''
  (Return 0-18
    (String 0-2 "")
    (Merge 17-18
      (Merge 6-10
        (Object 5-6)
        (Object 9-10
          ((String 10-13 "a") (NumberString 15-16 1))
      (Merge 37-38
        (Object 19-22
          ((String 19-22 "b") (NumberString 24-25 2))
        (Object 30-31
          ((String 31-34 "c") (NumberString 36-37 3))

  $ possum -p '"" $ {"a": 1 "b": 2}' -i '' 2> /dev/null || echo "missing comma error"
  missing comma error

  $ possum -p '"" $ {"a": 1, "b": 2,,}' -i '' 2> /dev/null || echo "too much comma error"
  too much comma error

  $ possum -p '"" $ {...{} ...{}}' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error

  $ possum -p '"" $ {...{}, ...{} ...{}}' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error
