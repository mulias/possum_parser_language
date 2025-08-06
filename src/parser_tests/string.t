  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '""' -i ''
  (String 1:0-2 "")

  $ possum -p '"hello"' -i ''
  (String 1:0-7 "hello")

  $ possum -p "'world'" -i ''
  (String 1:0-7 "world")

  $ possum -p '"%(word)"' -i ''
  (StringTemplate 1:0-9 [
    (ParserVar 1:3-7 word)
  ])

  $ possum -p '"Hello %(word)"' -i ''
  (StringTemplate 1:0-15 [
    (String 1:1-7 "Hello ")
    (ParserVar 1:9-13 word)
  ])

  $ possum -p '"%(word) World"' -i ''
  (StringTemplate 1:0-15 [
    (ParserVar 1:3-7 word)
    (String 1:8-14 " World")
  ])

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  (StringTemplate 1:0-27 [
    (String 1:1-7 "Hello ")
    (ParserVar 1:9-13 word)
    (String 1:14-19 " and ")
    (ParserVar 1:21-25 word)
  ])

  $ possum -p '"" $ "%(5)"' -i ''
  (Return 1:0-11
    (String 1:0-2 "")
    (StringTemplate 1:5-11 [
      (NumberString 1:8-9 5)
    ]))

  $ possum -p '"" -> "%(Str)"' -i ''
  (Destructure 1:0-14
    (String 1:0-2 "")
    (StringTemplate 1:6-14 [
      (ValueVar 1:9-12 Str)
    ]))

  $ possum -p '"Hello %(int + word)"' -i ''
  (StringTemplate 1:0-21 [
    (String 1:1-7 "Hello ")
    (Merge 1:9-19
      (ParserVar 1:9-12 int)
      (ParserVar 1:15-19 word))
  ])
