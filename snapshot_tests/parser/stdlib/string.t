  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/string.possum -i '' --no-stdlib
  (Import 1:0-19 stdlib/combinator private)
  
  (DeclareGlobal 3:0-19
    (Identifier 3:0-4 char)
    (Range 3:7-19 (String 3:7-17 "\x00") ())) (esc)
  
  (DeclareGlobal 5:0-30
    (Identifier 5:0-5 ascii)
    (Range 5:8-30 (String 5:8-18 "\x00") (String 5:20-30 "\x7f"))) (esc)
  
  (DeclareGlobal 7:0-27
    (Identifier 7:0-5 alpha)
    (Or 7:8-27
      (Range 7:8-16 (String 7:8-11 "a") (String 7:13-16 "z"))
      (Range 7:19-27 (String 7:19-22 "A") (String 7:24-27 "Z"))))
  
  (DeclareGlobal 9:0-20
    (Identifier 9:0-6 alphas)
    (Function 9:9-20
      (Identifier 9:9-13 many) [
        (Identifier 9:14-19 alpha)
      ]))
  
  (DeclareGlobal 11:0-16
    (Identifier 11:0-5 lower)
    (Range 11:8-16 (String 11:8-11 "a") (String 11:13-16 "z")))
  
  (DeclareGlobal 13:0-20
    (Identifier 13:0-6 lowers)
    (Function 13:9-20
      (Identifier 13:9-13 many) [
        (Identifier 13:14-19 lower)
      ]))
  
  (DeclareGlobal 15:0-16
    (Identifier 15:0-5 upper)
    (Range 15:8-16 (String 15:8-11 "A") (String 15:13-16 "Z")))
  
  (DeclareGlobal 17:0-20
    (Identifier 17:0-6 uppers)
    (Function 17:9-20
      (Identifier 17:9-13 many) [
        (Identifier 17:14-19 upper)
      ]))
  
  (DeclareGlobal 19:0-18
    (Identifier 19:0-7 numeral)
    (Range 19:10-18 (String 19:10-13 "0") (String 19:15-18 "9")))
  
  (DeclareGlobal 21:0-24
    (Identifier 21:0-8 numerals)
    (Function 21:11-24
      (Identifier 21:11-15 many) [
        (Identifier 21:16-23 numeral)
      ]))
  
  (DeclareGlobal 23:0-26
    (Identifier 23:0-14 binary_numeral)
    (Or 23:17-26
      (String 23:17-20 "0")
      (String 23:23-26 "1")))
  
  (DeclareGlobal 25:0-24
    (Identifier 25:0-13 octal_numeral)
    (Range 25:16-24 (String 25:16-19 "0") (String 25:21-24 "7")))
  
  (DeclareGlobal 27:0-43
    (Identifier 27:0-11 hex_numeral)
    (Or 27:14-43
      (Identifier 27:14-21 numeral)
      (Or 27:24-43
        (Range 27:24-32 (String 27:24-27 "a") (String 27:29-32 "f"))
        (Range 27:35-43 (String 27:35-38 "A") (String 27:40-43 "F")))))
  
  (DeclareGlobal 29:0-23
    (Identifier 29:0-5 alnum)
    (Or 29:8-23
      (Identifier 29:8-13 alpha)
      (Identifier 29:16-23 numeral)))
  
  (DeclareGlobal 31:0-20
    (Identifier 31:0-6 alnums)
    (Function 31:9-20
      (Identifier 31:9-13 many) [
        (Identifier 31:14-19 alnum)
      ]))
  
  (DeclareGlobal 33:0-38
    (Identifier 33:0-5 token)
    (Function 33:8-38
      (Identifier 33:8-12 many) [
        (Function 33:13-37
          (Identifier 33:13-19 unless) [
            (Identifier 33:20-24 char)
            (Identifier 33:26-36 whitespace)
          ])
      ]))
  
  (DeclareGlobal 35:0-30
    (Identifier 35:0-4 word)
    (Function 35:7-30
      (Identifier 35:7-11 many) [
        (Or 35:12-29
          (Identifier 35:12-17 alnum)
          (Or 35:20-29
            (String 35:20-23 "_")
            (String 35:26-29 "-")))
      ]))
  
  (DeclareGlobal 37:0-42
    (Identifier 37:0-4 line)
    (Function 37:7-42
      (Identifier 37:7-18 chars_until) [
        (Or 37:19-41
          (Identifier 37:19-26 newline)
          (Identifier 37:29-41 end_of_input))
      ]))
  
  (DeclareGlobal 39:0-97
    (Identifier 39:0-5 space)
    (Or 40:2-89
      (String 40:2-5 " ")
      (Or 40:8-89
        (String 40:8-12 "\t") (esc)
        (Or 40:15-89
          (String 40:15-25 "\xc2\xa0") (esc)
          (Or 40:28-89
            (Range 40:28-50 (String 40:28-38 "\xe2\x80\x80") (String 40:40-50 "\xe2\x80\x8a")) (esc)
            (Or 40:53-89
              (String 40:53-63 "\xe2\x80\xaf") (esc)
              (Or 40:66-89
                (String 40:66-76 "\xe2\x81\x9f") (esc)
                (String 40:79-89 "\xe3\x80\x80")))))))) (esc)
  
  (DeclareGlobal 42:0-20
    (Identifier 42:0-6 spaces)
    (Function 42:9-20
      (Identifier 42:9-13 many) [
        (Identifier 42:14-19 space)
      ]))
  
  (DeclareGlobal 44:0-80
    (Identifier 44:0-7 newline)
    (Or 44:10-80
      (String 44:10-16 "\r (esc)
  ")
      (Or 44:19-80
        (Range 44:19-41 (String 44:19-29 "
  ") (String 44:31-41 "\r (no-eol) (esc)
  "))
        (Or 44:44-80
          (String 44:44-54 "\xc2\x85") (esc)
          (Or 44:57-80
            (String 44:57-67 "\xe2\x80\xa8") (esc)
            (String 44:70-80 "\xe2\x80\xa9")))))) (esc)
  
  (DeclareGlobal 46:0-12
    (Identifier 46:0-2 nl)
    (Identifier 46:5-12 newline))
  
  (DeclareGlobal 48:0-24
    (Identifier 48:0-8 newlines)
    (Function 48:11-24
      (Identifier 48:11-15 many) [
        (Identifier 48:16-23 newline)
      ]))
  
  (DeclareGlobal 50:0-14
    (Identifier 50:0-3 nls)
    (Identifier 50:6-14 newlines))
  
  (DeclareGlobal 52:0-34
    (Identifier 52:0-10 whitespace)
    (Function 52:13-34
      (Identifier 52:13-17 many) [
        (Or 52:18-33
          (Identifier 52:18-23 space)
          (Identifier 52:26-33 newline))
      ]))
  
  (DeclareGlobal 54:0-15
    (Identifier 54:0-2 ws)
    (Identifier 54:5-15 whitespace))
  
  (DeclareGlobal 56:0-42
    (Function 56:0-17
      (Identifier 56:0-11 chars_until) [
        (Identifier 56:12-16 stop)
      ])
    (Function 56:20-42
      (Identifier 56:20-30 many_until) [
        (Identifier 56:31-35 char)
        (Identifier 56:37-41 stop)
      ]))
  
  (DeclareGlobal 58:0-34
    (Identifier 58:0-9 ctrl_char)
    (Range 58:12-34 (String 58:12-22 "\x00") (String 58:24-34 "\x1f"))) (esc)
