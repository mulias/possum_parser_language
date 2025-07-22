  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ []' -i ''
  (Return 3-4
    (String 0-2 "")
    (Array 5-7 ())


  $ possum -p '"" $ [1, 2, 3]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Array 5-14 ((NumberString 6-7 1) (NumberString 9-10 2) (NumberString 12-13 3)))

  $ possum -p '"" $ [1, 2, 3,]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Array 5-15 ((NumberString 6-7 1) (NumberString 9-10 2) (NumberString 12-13 3)))

  $ possum -p '"" $ [...[1]]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Merge 6-9
      (Array 5-6 ())
      (Array 9-12 ((NumberString 10-11 1)))

  $ possum -p '"" $ [...[1],]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Merge 6-9
      (Array 5-6 ())
      (Array 9-12 ((NumberString 10-11 1)))

  $ possum -p '"" $ [...[1], ...[2]]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Merge 12-13
      (Merge 6-9
        (Array 5-6 ())
        (Array 9-12 ((NumberString 10-11 1)))
      (Array 17-20 ((NumberString 18-19 2)))


  $ possum -p '"" $ [1, ...[2]]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Merge 9-12
      (Array 5-6 ((NumberString 6-7 1)))
      (Array 12-15 ((NumberString 13-14 2)))

  $ possum -p '"" $ [1, ...[2], 3]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Merge 15-16
      (Merge 9-12
        (Array 5-6 ((NumberString 6-7 1)))
        (Array 12-15 ((NumberString 13-14 2)))
      (Array 17-19 ((NumberString 17-18 3)))

  $ possum -p '"" $ [...[1], 2, ...[3]]' -i ''
  (Return 3-4
    (String 0-2 "")
    (Merge 12-13
      (Merge 6-9
        (Array 5-6 ())
        (Array 9-12 ((NumberString 10-11 1)))
      (Merge 22-23
        (Array 14-15 ((NumberString 14-15 2)))
        (Array 20-23 ((NumberString 21-22 3)))

  $ possum -p '"" -> [..._]' -i ''
  (Destructure 3-5
    (String 0-2 "")
    (Merge 7-10
      (Array 6-7 ())
      (ValueVar 10-11 _)

  $ possum -p '"" $ [1, 2 3]' -i '' 2> /dev/null || echo "missing comma error"
  missing comma error

  $ possum -p '"" $ [1, 2, 3,,]' -i '' 2> /dev/null || echo "too much comma error"
  too much comma error

  $ possum -p '"" $ [...[] ...[]]' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error

  $ possum -p '"" $ [...[], ...[] ...[]]' -i '' 2> /dev/null || echo "missing comma in spread error"
  missing comma in spread error
