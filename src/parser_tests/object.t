  $ export PRINT_AST=true RUN_VM=false

  $ possum -p '"" $ {}' -i ''
  (Return 1:0-7
    (String 1:0-2 "")
    (Object 1:5-7 []))

  $ possum -p '"" $ {"a": 1}' -i ''
  (Return 1:0-13
    (String 1:0-2 "")
    (Object 1:5-13 [
      (ObjectPair (String 1:6-9 "a") (NumberString 1:11-12 1))
    ]))

  $ possum -p '"" $ {A: 1,}' -i ''
  (Return 1:0-12
    (String 1:0-2 "")
    (Object 1:5-12 [
      (ObjectPair (Identifier 1:6-7 A) (NumberString 1:9-10 1))
    ]))

  $ possum -p '"" $ {...{"x": Z}}' -i ''
  (Return 1:0-18
    (String 1:0-2 "")
    (Merge 1:5-18
      (Object 1:5-6 [])
      (Object 1:9-17 [
        (ObjectPair (String 1:10-13 "x") (Identifier 1:15-16 Z))
      ])))

  $ possum -p '"" $ {...{"x": Z},}' -i ''
  (Return 1:0-19
    (String 1:0-2 "")
    (Merge 1:5-19
      (Object 1:5-6 [])
      (Object 1:9-17 [
        (ObjectPair (String 1:10-13 "x") (Identifier 1:15-16 Z))
      ])))

  $ possum -p '"" $ {...{"a": 1}, ...{"b": 2}}' -i ''
  (Return 1:0-31
    (String 1:0-2 "")
    (Merge 1:5-31
      (Merge 1:5-6
        (Object 1:5-6 [])
        (Object 1:9-17 [
          (ObjectPair (String 1:10-13 "a") (NumberString 1:15-16 1))
        ]))
      (Object 1:22-31 [
        (ObjectPair (String 1:23-26 "b") (NumberString 1:28-29 2))
      ])))

  $ possum -p '"" $ {"a": 1, ...{"b": 2}}' -i ''
  (Return 1:0-26
    (String 1:0-2 "")
    (Merge 1:5-26
      (Object 1:5-17 [
        (ObjectPair (String 1:6-9 "a") (NumberString 1:11-12 1))
      ])
      (Object 1:17-25 [
        (ObjectPair (String 1:18-21 "b") (NumberString 1:23-24 2))
      ])))

  $ possum -p '"" $ {"a": 1, ...{"b": 2}, "c": 3}' -i ''
  (Return 1:0-34
    (String 1:0-2 "")
    (Merge 1:5-34
      (Merge 1:5-17
        (Object 1:5-17 [
          (ObjectPair (String 1:6-9 "a") (NumberString 1:11-12 1))
        ])
        (Object 1:17-25 [
          (ObjectPair (String 1:18-21 "b") (NumberString 1:23-24 2))
        ]))
      (Object 1:27-34 [
        (ObjectPair (String 1:27-30 "c") (NumberString 1:32-33 3))
      ])))

  $ possum -p '"" $ {...{"a": 1}, "b": 2, ...{"c": 3}}' -i ''
  (Return 1:0-39
    (String 1:0-2 "")
    (Merge 1:5-39
      (Merge 1:5-6
        (Object 1:5-6 [])
        (Object 1:9-17 [
          (ObjectPair (String 1:10-13 "a") (NumberString 1:15-16 1))
        ]))
      (Merge 1:19-39
        (Object 1:19-20 [
          (ObjectPair (String 1:19-22 "b") (NumberString 1:24-25 2))
        ])
        (Object 1:30-38 [
          (ObjectPair (String 1:31-34 "c") (NumberString 1:36-37 3))
        ]))))

  $ possum -p '"" $ {"a": 1 "b": 2}' -i ''
  
  Syntax Error: expected closing '}', found '"'
  
  program:1:13-14:
  1 \xe2\x96\x8f "" $ {"a": 1 "b": 2} (esc)
    \xe2\x96\x8f              ^ (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '"" $ {"a": 1, "b": 2,,}' -i ''
  
  Syntax Error: expected expression, found ','
  
  program:1:21-22:
  1 \xe2\x96\x8f "" $ {"a": 1, "b": 2,,} (esc)
    \xe2\x96\x8f                      ^ (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '"" $ {...{} ...{}}' -i ''
  
  Syntax Error: expected closing '}', found '...'
  
  program:1:12-15:
  1 \xe2\x96\x8f "" $ {...{} ...{}} (esc)
    \xe2\x96\x8f             ^^^ (esc)
  
  [UnexpectedInput]
  [1]

  $ possum -p '"" $ {...{}, ...{} ...{}}' -i ''
  
  Syntax Error: expected closing '}', found '...'
  
  program:1:19-22:
  1 \xe2\x96\x8f "" $ {...{}, ...{} ...{}} (esc)
    \xe2\x96\x8f                    ^^^ (esc)
  
  [UnexpectedInput]
  [1]
