  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/json.possum -i '' --no-stdlib
  (Import 1:0-15 stdlib/string)
  
  (Import 2:0-15 stdlib/repeat)
  
  (Import 3:0-13 stdlib/util)
  
  (Identifier 5:0-5 value)
  
  (DeclareGlobal 7:0-83
    (Identifier 7:0-5 value)
    (Or 8:2-75
      (Identifier 8:2-9 boolean)
      (Or 9:2-63
        (Null 9:2-6)
        (Or 10:2-54
          (Identifier 10:2-8 number)
          (Or 11:2-43
            (Identifier 11:2-8 string)
            (Or 12:2-32
              (Function 12:2-14
                (Identifier 12:2-7 array) [
                  (Identifier 12:8-13 value)
                ])
              (Function 13:2-15
                (Identifier 13:2-8 object) [
                  (Identifier 13:9-14 value)
                ])))))))
  
  (DeclareGlobal 15:0-42
    (Identifier 15:0-7 boolean)
    (Function 15:10-42
      (Import 15:10-25 stdlib .boolean) [
        (String 15:26-32 "true")
        (String 15:34-41 "false")
      ]))
  
  (DeclareGlobal 17:0-27
    (Null 17:0-4)
    (Function 17:7-27
      (Import 17:7-19 stdlib .null) [
        (String 17:20-26 "null")
      ]))
  
  (DeclareGlobal 19:0-23
    (Identifier 19:0-6 number)
    (Import 19:9-23 stdlib .number))
  
  (DeclareGlobal 21:0-33
    (Identifier 21:0-6 string)
    (TakeLeft 21:9-33
      (TakeRight 21:9-27
        (String 21:9-12 """)
        (Identifier 21:15-27 _string_body))
      (String 21:30-33 """)))
  
  (DeclareGlobal 23:0-127
    (Identifier 23:0-12 _string_body)
    (Or 24:2-112
      (Function 24:2-99
        (Identifier 24:2-6 many) [
          (Or 25:4-87
            (Identifier 25:4-22 _escaped_ctrl_char)
            (Or 26:4-62
              (Identifier 26:4-20 _escaped_unicode)
              (Function 27:4-39
                (Identifier 27:4-10 unless) [
                  (Identifier 27:11-15 char)
                  (Or 27:17-38
                    (Identifier 27:17-26 ctrl_char)
                    (Or 27:29-38
                      (String 27:29-32 "\")
                      (String 27:35-38 """)))
                ])))
        ])
      (Function 28:6-16
        (Identifier 28:6-11 const) [
          (ValueLabel 28:12-13 (String 28:13-15 ""))
        ])))
  
  (DeclareGlobal 30:0-159
    (Identifier 30:0-18 _escaped_ctrl_char)
    (Or 31:2-138
      (Return 31:2-14
        (String 31:3-7 "\"")
        (String 31:10-13 """))
      (Or 32:2-121
        (Return 32:2-14
          (String 32:3-7 "\\")
          (String 32:10-13 "\"))
        (Or 33:2-104
          (Return 33:2-14
            (String 33:3-7 "\/")
            (String 33:10-13 "/"))
          (Or 34:2-87
            (Return 34:2-15
              (String 34:3-7 "\b")
              (String 34:10-14 "\x08")) (esc)
            (Or 35:2-69
              (Return 35:2-15
                (String 35:3-7 "\f")
                (String 35:10-14 "\x0c")) (esc)
              (Or 36:2-51
                (Return 36:2-15
                  (String 36:3-7 "\n")
                  (String 36:10-14 "
  "))
                (Or 37:2-33
                  (Return 37:2-15
                    (String 37:3-7 "\r")
                    (String 37:10-14 "\r (no-eol) (esc)
  "))
                  (Return 38:2-15
                    (String 38:3-7 "\t")
                    (String 38:10-14 "\t")))))))))) (esc)
  
  (DeclareGlobal 40:0-63
    (Identifier 40:0-16 _escaped_unicode)
    (Or 40:19-63
      (Identifier 40:19-42 _escaped_surrogate_pair)
      (Identifier 40:45-63 _escaped_codepoint)))
  
  (DeclareGlobal 42:0-73
    (Identifier 42:0-23 _escaped_surrogate_pair)
    (Or 42:26-73
      (Identifier 42:26-47 _valid_surrogate_pair)
      (Identifier 42:50-73 _invalid_surrogate_pair)))
  
  (DeclareGlobal 44:0-100
    (Identifier 44:0-21 _valid_surrogate_pair)
    (TakeRight 45:2-76
      (Destructure 45:2-22
        (Identifier 45:2-17 _high_surrogate)
        (Identifier 45:21-22 H))
      (Return 45:25-76
        (Destructure 45:25-44
          (Identifier 45:25-39 _low_surrogate)
          (Identifier 45:43-44 L))
        (Function 45:47-76
          (Identifier 45:47-70 @SurrogatePairCodepoint) [
            (Identifier 45:71-72 H)
            (Identifier 45:74-75 L)
          ]))))
  
  (DeclareGlobal 47:0-71
    (Identifier 47:0-23 _invalid_surrogate_pair)
    (Return 47:26-71
      (Or 47:26-58
        (Identifier 47:26-40 _low_surrogate)
        (Identifier 47:43-58 _high_surrogate))
      (String 47:61-71 "\xef\xbf\xbd"))) (esc)
  
  (DeclareGlobal 49:0-104
    (Identifier 49:0-15 _high_surrogate)
    (Merge 50:2-86
      (Merge 50:2-72
        (Merge 50:2-58
          (TakeRight 50:2-20
            (String 50:2-6 "\u")
            (Or 50:9-20
              (String 50:10-13 "D")
              (String 50:16-19 "d")))
          (Or 50:23-58
            (String 50:24-27 "8")
            (Or 50:30-57
              (String 50:30-33 "9")
              (Or 50:36-57
                (String 50:36-39 "A")
                (Or 50:42-57
                  (String 50:42-45 "B")
                  (Or 50:48-57
                    (String 50:48-51 "a")
                    (String 50:54-57 "b")))))))
        (Identifier 50:61-72 hex_numeral))
      (Identifier 50:75-86 hex_numeral)))
  
  (DeclareGlobal 52:0-89
    (Identifier 52:0-14 _low_surrogate)
    (Merge 53:2-72
      (Merge 53:2-58
        (Merge 53:2-44
          (TakeRight 53:2-20
            (String 53:2-6 "\u")
            (Or 53:9-20
              (String 53:10-13 "D")
              (String 53:16-19 "d")))
          (Or 53:23-44
            (Range 53:24-32 (String 53:24-27 "C") (String 53:29-32 "F"))
            (Range 53:35-43 (String 53:35-38 "c") (String 53:40-43 "f"))))
        (Identifier 53:47-58 hex_numeral))
      (Identifier 53:61-72 hex_numeral)))
  
  (DeclareGlobal 55:0-66
    (Identifier 55:0-18 _escaped_codepoint)
    (Return 55:21-66
      (Destructure 55:21-50
        (TakeRight 55:21-45
          (String 55:21-25 "\u")
          (Repeat 55:28-45
            (Identifier 55:29-40 hex_numeral)
            (NumberString 55:43-44 4)))
        (Identifier 55:49-50 U))
      (Function 55:53-66
        (Identifier 55:53-63 @Codepoint) [
          (Identifier 55:64-65 U)
        ])))
  
  (DeclareGlobal 57:0-82
    (Function 57:0-11
      (Identifier 57:0-5 array) [
        (Identifier 57:6-10 elem)
      ])
    (TakeLeft 57:14-82
      (TakeRight 57:14-76
        (String 57:14-17 "[")
        (Function 57:20-76
          (Import 57:20-43 stdlib .maybe_array_sep) [
            (Function 57:45-70
              (Identifier 57:45-53 surround) [
                (Identifier 57:54-58 elem)
                (Function 57:60-69
                  (Identifier 57:60-65 maybe) [
                    (Identifier 57:66-68 ws)
                  ])
              ])
            (String 57:72-75 ",")
          ]))
      (String 57:79-82 "]")))
  
  (DeclareGlobal 59:0-137
    (Function 59:0-13
      (Identifier 59:0-6 object) [
        (Identifier 59:7-12 value)
      ])
    (TakeLeft 60:2-121
      (TakeRight 60:2-113
        (String 60:2-5 "{")
        (Function 61:2-105
          (Import 61:2-26 stdlib .maybe_object_sep) [
            (Function 62:4-31
              (Identifier 62:4-12 surround) [
                (Identifier 62:13-19 string)
                (Function 62:21-30
                  (Identifier 62:21-26 maybe) [
                    (Identifier 62:27-29 ws)
                  ])
              ])
            (String 62:33-36 ":")
            (Function 63:4-30
              (Identifier 63:4-12 surround) [
                (Identifier 63:13-18 value)
                (Function 63:20-29
                  (Identifier 63:20-25 maybe) [
                    (Identifier 63:26-28 ws)
                  ])
              ])
            (String 63:32-35 ",")
          ]))
      (String 65:4-7 "}")))
