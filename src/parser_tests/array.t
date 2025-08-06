  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ []' -i ''
  (Return 1:0-7
    (String 1:0-2 "")
    (Array 1:5-7 []))


  $ possum -p '"" $ [1, 2, 3]' -i ''
  (Return 1:0-14
    (String 1:0-2 "")
    (Array 1:5-14 [
      (NumberString 1:6-7 1)
      (NumberString 1:9-10 2)
      (NumberString 1:12-13 3)
    ]))

  $ possum -p '"" $ [1, 2, 3,]' -i ''
  (Return 1:0-15
    (String 1:0-2 "")
    (Array 1:5-15 [
      (NumberString 1:6-7 1)
      (NumberString 1:9-10 2)
      (NumberString 1:12-13 3)
    ]))

  $ possum -p '"" $ [...[1]]' -i ''
  (Return 1:0-13
    (String 1:0-2 "")
    (Merge 1:5-13
      (Array 1:5-6 [])
      (Array 1:9-12 [
        (NumberString 1:10-11 1)
      ])))

  $ possum -p '"" $ [...[1],]' -i ''
  (Return 1:0-14
    (String 1:0-2 "")
    (Merge 1:5-14
      (Array 1:5-6 [])
      (Array 1:9-12 [
        (NumberString 1:10-11 1)
      ])))

  $ possum -p '"" $ [...[1], ...[2]]' -i ''
  (Return 1:0-21
    (String 1:0-2 "")
    (Merge 1:5-21
      (Merge 1:5-6
        (Array 1:5-6 [])
        (Array 1:9-12 [
          (NumberString 1:10-11 1)
        ]))
      (Array 1:17-21 [
        (NumberString 1:18-19 2)
      ])))


  $ possum -p '"" $ [1, ...[2]]' -i ''
  (Return 1:0-16
    (String 1:0-2 "")
    (Merge 1:5-16
      (Array 1:5-6 [
        (NumberString 1:6-7 1)
      ])
      (Array 1:12-15 [
        (NumberString 1:13-14 2)
      ])))

  $ possum -p '"" $ [1, ...[2], 3]' -i ''
  (Return 1:0-19
    (String 1:0-2 "")
    (Merge 1:5-19
      (Merge 1:5-6
        (Array 1:5-6 [
          (NumberString 1:6-7 1)
        ])
        (Array 1:12-15 [
          (NumberString 1:13-14 2)
        ]))
      (Array 1:17-19 [
        (NumberString 1:17-18 3)
      ])))

  $ possum -p '"" $ [...[1], 2, ...[3]]' -i ''
  (Return 1:0-24
    (String 1:0-2 "")
    (Merge 1:5-24
      (Merge 1:5-6
        (Array 1:5-6 [])
        (Array 1:9-12 [
          (NumberString 1:10-11 1)
        ]))
      (Merge 1:14-24
        (Array 1:14-15 [
          (NumberString 1:14-15 2)
        ])
        (Array 1:20-23 [
          (NumberString 1:21-22 3)
        ]))))

  $ possum -p '"" -> [..._]' -i ''
  (Destructure 1:0-12
    (String 1:0-2 "")
    (Merge 1:6-12
      (Array 1:6-7 [])
      (ValueVar 1:10-11 _)))

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
