  $ possum -p '"a" * 3' -i 'aaaaaa'
  "aaa"

  $ possum -p '"a" * 2..' -i 'a'
  [ParserFailure]
  [1]

  $ possum -p '"a" * 2..' -i 'aaaaaaaa'
  "aaaaaaaa"

  $ possum -p '"a" * 4..6' -i 'aaaaaaaaaaa'
  "aaaaaa"

  $ possum -p '"a" * 4..6' -i 'aa'
  [ParserFailure]
  [1]

  $ possum -p '"a" * 4..6' -i 'aaaa'
  "aaaa"

  $ possum -p '"a" * N' -i 'aaaaa'
  "aaaaa"

  $ possum -p 'N = 3 ; "a" * N' -i 'aaaaa'
  "aaa"

  $ possum -p 'N = 3 ; "a" * (N + 1)' -i 'aaaaa'
  "aaaa"

  $ possum -p '"a" * (N + 1) $ N' -i 'aaaaa'
  4

  $ possum -p '"a" * (0..1 + 1)' -i 'aaaaa'
  "aa"
