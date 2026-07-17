  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/json.possum -i '' --no-stdlib
  (Import 1:0-15 stdlib/string private)
  
  (Import 2:0-19 stdlib/combinator private)
  
  (Identifier 4:0-5 value)
  
  (DeclareGlobal 6:0-83
    (Identifier 6:0-5 value)
    (Or 7:2-75
      (Identifier 7:2-9 boolean)
      (Or 8:2-63
        (Null 8:2-6)
        (Or 9:2-54
          (Identifier 9:2-8 number)
          (Or 10:2-43
            (Identifier 10:2-8 string)
            (Or 11:2-32
              (Function 11:2-14
                (Identifier 11:2-7 array) [
                  (Identifier 11:8-13 value)
                ])
              (Function 12:2-15
                (Identifier 12:2-8 object) [
                  (Identifier 12:9-14 value)
                ])))))))
  
  (DeclareGlobal 14:0-42
    (Identifier 14:0-7 boolean)
    (Function 14:10-42
      (Import 14:10-25 stdlib .boolean) [
        (String 14:26-32 "true")
        (String 14:34-41 "false")
      ]))
  
  (DeclareGlobal 16:0-27
    (Null 16:0-4)
    (Function 16:7-27
      (Import 16:7-19 stdlib .null) [
        (String 16:20-26 "null")
      ]))
  
  (DeclareGlobal 18:0-23
    (Identifier 18:0-6 number)
    (Import 18:9-23 stdlib .number))
  
  (DeclareGlobal 20:0-33
    (Identifier 20:0-6 string)
    (TakeLeft 20:9-33
      (TakeRight 20:9-27
        (String 20:9-12 """)
        (Identifier 20:15-27 _string_body))
      (String 20:30-33 """)))
  
  (DeclareGlobal 22:0-127
    (Identifier 22:0-12 _string_body)
    (Or 23:2-112
      (Function 23:2-99
        (Identifier 23:2-6 many) [
          (Or 24:4-87
            (Identifier 24:4-22 _escaped_ctrl_char)
            (Or 25:4-62
              (Identifier 25:4-20 _escaped_unicode)
              (Function 26:4-39
                (Identifier 26:4-10 unless) [
                  (Identifier 26:11-15 char)
                  (Or 26:17-38
                    (Identifier 26:17-26 ctrl_char)
                    (Or 26:29-38
                      (String 26:29-32 "\")
                      (String 26:35-38 """)))
                ])))
        ])
      (Function 27:6-16
        (Identifier 27:6-11 const) [
          (ValueLabel 27:12-13 (String 27:13-15 ""))
        ])))
  
  (DeclareGlobal 29:0-159
    (Identifier 29:0-18 _escaped_ctrl_char)
    (Or 30:2-138
      (Return 30:2-14
        (String 30:3-7 "\"")
        (String 30:10-13 """))
      (Or 31:2-121
        (Return 31:2-14
          (String 31:3-7 "\\")
          (String 31:10-13 "\"))
        (Or 32:2-104
          (Return 32:2-14
            (String 32:3-7 "\/")
            (String 32:10-13 "/"))
          (Or 33:2-87
            (Return 33:2-15
              (String 33:3-7 "\b")
              (String 33:10-14 "\x08")) (esc)
            (Or 34:2-69
              (Return 34:2-15
                (String 34:3-7 "\f")
                (String 34:10-14 "\x0c")) (esc)
              (Or 35:2-51
                (Return 35:2-15
                  (String 35:3-7 "\n")
                  (String 35:10-14 "
  "))
                (Or 36:2-33
                  (Return 36:2-15
                    (String 36:3-7 "\r")
                    (String 36:10-14 "\r (no-eol) (esc)
  "))
                  (Return 37:2-15
                    (String 37:3-7 "\t")
                    (String 37:10-14 "\t")))))))))) (esc)
  
  (DeclareGlobal 39:0-63
    (Identifier 39:0-16 _escaped_unicode)
    (Or 39:19-63
      (Identifier 39:19-42 _escaped_surrogate_pair)
      (Identifier 39:45-63 _escaped_codepoint)))
  
  (DeclareGlobal 41:0-73
    (Identifier 41:0-23 _escaped_surrogate_pair)
    (Or 41:26-73
      (Identifier 41:26-47 _valid_surrogate_pair)
      (Identifier 41:50-73 _invalid_surrogate_pair)))
  
  (DeclareGlobal 43:0-100
    (Identifier 43:0-21 _valid_surrogate_pair)
    (TakeRight 44:2-76
      (Destructure 44:2-22
        (Identifier 44:2-17 _high_surrogate)
        (Identifier 44:21-22 H))
      (Return 44:25-76
        (Destructure 44:25-44
          (Identifier 44:25-39 _low_surrogate)
          (Identifier 44:43-44 L))
        (Function 44:47-76
          (Identifier 44:47-70 @SurrogatePairCodepoint) [
            (Identifier 44:71-72 H)
            (Identifier 44:74-75 L)
          ]))))
  
  (DeclareGlobal 46:0-71
    (Identifier 46:0-23 _invalid_surrogate_pair)
    (Return 46:26-71
      (Or 46:26-58
        (Identifier 46:26-40 _low_surrogate)
        (Identifier 46:43-58 _high_surrogate))
      (String 46:61-71 "\xef\xbf\xbd"))) (esc)
  
  (DeclareGlobal 48:0-104
    (Identifier 48:0-15 _high_surrogate)
    (Merge 49:2-86
      (Merge 49:2-72
        (Merge 49:2-58
          (TakeRight 49:2-20
            (String 49:2-6 "\u")
            (Or 49:9-20
              (String 49:10-13 "D")
              (String 49:16-19 "d")))
          (Or 49:23-58
            (String 49:24-27 "8")
            (Or 49:30-57
              (String 49:30-33 "9")
              (Or 49:36-57
                (String 49:36-39 "A")
                (Or 49:42-57
                  (String 49:42-45 "B")
                  (Or 49:48-57
                    (String 49:48-51 "a")
                    (String 49:54-57 "b")))))))
        (Identifier 49:61-72 hex_numeral))
      (Identifier 49:75-86 hex_numeral)))
  
  (DeclareGlobal 51:0-89
    (Identifier 51:0-14 _low_surrogate)
    (Merge 52:2-72
      (Merge 52:2-58
        (Merge 52:2-44
          (TakeRight 52:2-20
            (String 52:2-6 "\u")
            (Or 52:9-20
              (String 52:10-13 "D")
              (String 52:16-19 "d")))
          (Or 52:23-44
            (Range 52:24-32 (String 52:24-27 "C") (String 52:29-32 "F"))
            (Range 52:35-43 (String 52:35-38 "c") (String 52:40-43 "f"))))
        (Identifier 52:47-58 hex_numeral))
      (Identifier 52:61-72 hex_numeral)))
  
  (DeclareGlobal 54:0-66
    (Identifier 54:0-18 _escaped_codepoint)
    (Return 54:21-66
      (Destructure 54:21-50
        (TakeRight 54:21-45
          (String 54:21-25 "\u")
          (Repeat 54:28-45
            (Identifier 54:29-40 hex_numeral)
            (NumberString 54:43-44 4)))
        (Identifier 54:49-50 U))
      (Function 54:53-66
        (Identifier 54:53-63 @Codepoint) [
          (Identifier 54:64-65 U)
        ])))
  
  (DeclareGlobal 56:0-82
    (Function 56:0-11
      (Identifier 56:0-5 array) [
        (Identifier 56:6-10 elem)
      ])
    (TakeLeft 56:14-82
      (TakeRight 56:14-76
        (String 56:14-17 "[")
        (Function 56:20-76
          (Import 56:20-43 stdlib .maybe_array_sep) [
            (Function 56:45-70
              (Identifier 56:45-53 surround) [
                (Identifier 56:54-58 elem)
                (Function 56:60-69
                  (Identifier 56:60-65 maybe) [
                    (Identifier 56:66-68 ws)
                  ])
              ])
            (String 56:72-75 ",")
          ]))
      (String 56:79-82 "]")))
  
  (DeclareGlobal 58:0-137
    (Function 58:0-13
      (Identifier 58:0-6 object) [
        (Identifier 58:7-12 value)
      ])
    (TakeLeft 59:2-121
      (TakeRight 59:2-113
        (String 59:2-5 "{")
        (Function 60:2-105
          (Import 60:2-26 stdlib .maybe_object_sep) [
            (Function 61:4-31
              (Identifier 61:4-12 surround) [
                (Identifier 61:13-19 string)
                (Function 61:21-30
                  (Identifier 61:21-26 maybe) [
                    (Identifier 61:27-29 ws)
                  ])
              ])
            (String 61:33-36 ":")
            (Function 62:4-30
              (Identifier 62:4-12 surround) [
                (Identifier 62:13-18 value)
                (Function 62:20-29
                  (Identifier 62:20-25 maybe) [
                    (Identifier 62:26-28 ws)
                  ])
              ])
            (String 62:32-35 ",")
          ]))
      (String 64:4-7 "}")))
