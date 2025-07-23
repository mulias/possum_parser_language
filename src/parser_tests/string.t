  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '""' -i ''
  (String 0-2 "")

  $ possum -p '"hello"' -i ''
  (String 0-7 "hello")

  $ possum -p "'world'" -i ''
  (String 0-7 "world")

  $ possum -p '"%(word)"' -i ''
  (StringTemplate 0-9 (ParserVar 3-7 word))

  $ possum -p '"Hello %(word)"' -i ''
  (StringTemplate 0-15
    (String 1-7 "Hello ")
    (ParserVar 9-13 word))

  $ possum -p '"%(word) World"' -i ''
  (StringTemplate 0-15
    (ParserVar 3-7 word)
    (String 8-14 " World"))

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  (StringTemplate 0-27
    (String 1-7 "Hello ")
    (ParserVar 9-13 word)
    (String 14-19 " and ")
    (ParserVar 21-25 word))

  $ possum -p '"" $ "%(5)"' -i ''
  (Return 0-11
    (String 0-2 "")
    (StringTemplate 5-11 (NumberString 8-9 5)))

  $ possum -p '"" -> "%(Str)"' -i ''
  (Destructure 0-14
    (String 0-2 "")
    (StringTemplate 6-14 (ValueVar 9-12 Str)))

  $ possum -p '"Hello %(int + word)"' -i ''
  (StringTemplate 0-21
    (String 1-7 "Hello ")
    (Merge 9-19
      (ParserVar 9-12 int)
      (ParserVar 15-19 word)))
