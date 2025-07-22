  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '""' -i ''
  (String 0-2 "")

  $ possum -p '"hello"' -i ''
  (String 0-7 "hello")

  $ possum -p "'world'" -i ''
  (String 0-7 "world")

  $ possum -p '"%(word)"' -i ''
  (StringTemplate 0-9
    (String 0-9 "")
    (ParserVar 0-4 word)

  $ possum -p '"Hello %(word)"' -i ''
  (StringTemplate 0-15
    (String 0-15 "Hello ")
    (ParserVar 0-4 word)

  $ possum -p '"%(word) World"' -i ''
  (StringTemplate 0-15
    (String 0-15 "")
    (ParserVar 0-4 word)
    (String 4-5 " World")

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  (StringTemplate 0-27
    (String 0-27 "Hello ")
    (ParserVar 0-4 word)
    (String 4-5 " and ")
    (ParserVar 0-4 word)

  $ possum -p '"" $ "%(5)"' -i ''
  (Return 3-4
    (String 0-2 "")
    (StringTemplate 5-11
      (String 5-11 "")
      (NumberString 0-1 5)

  $ possum -p '"" -> "%(Str)"' -i ''
  (Destructure 3-5
    (String 0-2 "")
    (StringTemplate 6-14
      (String 6-14 "")
      (ValueVar 0-3 Str)

  $ possum -p '"Hello %(int + word)"' -i ''
  (StringTemplate 0-21
    (String 0-21 "Hello ")
    (Merge 4-5
      (ParserVar 0-3 int)
      (ParserVar 6-10 word)
