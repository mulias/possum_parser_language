  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ []' -i ''
  (Return 0-7
    (String 0-2 "")
    (Array 5-7 ()))


  $ possum -p '"" $ [1, 2, 3]' -i ''
  (Return 0-14
    (String 0-2 "")
    (Array 5-14 ((NumberString 6-7 1) (NumberString 9-10 2) (NumberString 12-13 3))))

  $ possum -p '"" $ [1, 2, 3,]' -i ''
  (Return 0-15
    (String 0-2 "")
    (Array 5-15 ((NumberString 6-7 1) (NumberString 9-10 2) (NumberString 12-13 3))))

  $ possum -p '"" $ [...[1]]' -i ''
  (Return 0-13
    (String 0-2 "")
    (Merge 9-13
      (Array 5-6 ())
      (Array 9-12 ((NumberString 10-11 1)))))

  $ possum -p '"" $ [...[1],]' -i ''
  (Return 0-14
    (String 0-2 "")
    (Merge 9-14
      (Array 5-6 ())
      (Array 9-12 ((NumberString 10-11 1)))))

  $ possum -p '"" $ [...[1], ...[2]]' -i ''
  (Return 0-21
    (String 0-2 "")
    (Merge 9-21
      (Merge 9-10
        (Array 5-6 ())
        (Array 9-12 ((NumberString 10-11 1))))
      (Array 17-21 ((NumberString 18-19 2)))))


  $ possum -p '"" $ [1, ...[2]]' -i ''
  (Return 0-16
    (String 0-2 "")
    (Merge 12-16
      (Array 5-6 ((NumberString 6-7 1)))
      (Array 12-15 ((NumberString 13-14 2)))))

  $ possum -p '"" $ [1, ...[2], 3]' -i ''
  (Return 0-19
    (String 0-2 "")
    (Merge 12-19
      (Merge 12-13
        (Array 5-6 ((NumberString 6-7 1)))
        (Array 12-15 ((NumberString 13-14 2))))
      (Array 17-19 ((NumberString 17-18 3)))))

  $ possum -p '"" $ [...[1], 2, ...[3]]' -i ''
  (Return 0-24
    (String 0-2 "")
    (Merge 9-24
      (Merge 9-10
        (Array 5-6 ())
        (Array 9-12 ((NumberString 10-11 1))))
      (Merge 14-24
        (Array 14-15 ((NumberString 14-15 2)))
        (Array 20-23 ((NumberString 21-22 3))))))

  $ possum -p '"" -> [..._]' -i ''
  (Destructure 0-12
    (String 0-2 "")
    (Merge 10-12
      (Array 6-7 ())
      (ValueVar 10-11 _)))

  $ possum -p '"" $ [1, 2 3]' -i ''
  
  Error at '3': Expected closing ']'
  
  "" $ [1, 2 3]
             ^
  
  [UnexpectedInput]
  [1]

  $ possum -p '"" $ [1, 2, 3,,]' -i ''
  
  Error at ',': Expect expression.
  
  "" $ [1, 2, 3,,]
                ^
  
  [UnexpectedInput]
  [1]

  $ possum -p '"" $ [...[] ...[]]' -i ''
  
  Error at '...': Expected closing ']'
  
  "" $ [...[] ...[]]
              ^^^
  
  [UnexpectedInput]
  [1]

  $ possum -p '"" $ [...[], ...[] ...[]]' -i ''
  
  Error at '...': Expected closing ']'
  
  "" $ [...[], ...[] ...[]]
                     ^^^
  
  [UnexpectedInput]
  [1]
