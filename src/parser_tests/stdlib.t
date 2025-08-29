  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i ''
  (DeclareGlobal 5:0-19
    (Identifier 5:0-4 char)
    (Range 5:7-19 (String 5:7-17 "\x00") ())) (esc)
  
  (DeclareGlobal 7:0-30
    (Identifier 7:0-5 ascii)
    (Range 7:8-30 (String 7:8-18 "\x00") (String 7:20-30 "\x7f"))) (esc)
  
  (DeclareGlobal 9:0-27
    (Identifier 9:0-5 alpha)
    (Or 9:8-27
      (Range 9:8-16 (String 9:8-11 "a") (String 9:13-16 "z"))
      (Range 9:19-27 (String 9:19-22 "A") (String 9:24-27 "Z"))))
  
  (DeclareGlobal 11:0-20
    (Identifier 11:0-6 alphas)
    (Function 11:9-20
      (Identifier 11:9-13 many) [
        (Identifier 11:14-19 alpha)
      ]))
  
  (DeclareGlobal 13:0-16
    (Identifier 13:0-5 lower)
    (Range 13:8-16 (String 13:8-11 "a") (String 13:13-16 "z")))
  
  (DeclareGlobal 15:0-20
    (Identifier 15:0-6 lowers)
    (Function 15:9-20
      (Identifier 15:9-13 many) [
        (Identifier 15:14-19 lower)
      ]))
  
  (DeclareGlobal 17:0-16
    (Identifier 17:0-5 upper)
    (Range 17:8-16 (String 17:8-11 "A") (String 17:13-16 "Z")))
  
  (DeclareGlobal 19:0-20
    (Identifier 19:0-6 uppers)
    (Function 19:9-20
      (Identifier 19:9-13 many) [
        (Identifier 19:14-19 upper)
      ]))
  
  (DeclareGlobal 21:0-18
    (Identifier 21:0-7 numeral)
    (Range 21:10-18 (String 21:10-13 "0") (String 21:15-18 "9")))
  
  (DeclareGlobal 23:0-24
    (Identifier 23:0-8 numerals)
    (Function 23:11-24
      (Identifier 23:11-15 many) [
        (Identifier 23:16-23 numeral)
      ]))
  
  (DeclareGlobal 25:0-26
    (Identifier 25:0-14 binary_numeral)
    (Or 25:17-26
      (String 25:17-20 "0")
      (String 25:23-26 "1")))
  
  (DeclareGlobal 27:0-24
    (Identifier 27:0-13 octal_numeral)
    (Range 27:16-24 (String 27:16-19 "0") (String 27:21-24 "7")))
  
  (DeclareGlobal 29:0-43
    (Identifier 29:0-11 hex_numeral)
    (Or 29:14-43
      (Identifier 29:14-21 numeral)
      (Or 29:24-43
        (Range 29:24-32 (String 29:24-27 "a") (String 29:29-32 "f"))
        (Range 29:35-43 (String 29:35-38 "A") (String 29:40-43 "F")))))
  
  (DeclareGlobal 31:0-23
    (Identifier 31:0-5 alnum)
    (Or 31:8-23
      (Identifier 31:8-13 alpha)
      (Identifier 31:16-23 numeral)))
  
  (DeclareGlobal 33:0-20
    (Identifier 33:0-6 alnums)
    (Function 33:9-20
      (Identifier 33:9-13 many) [
        (Identifier 33:14-19 alnum)
      ]))
  
  (DeclareGlobal 35:0-38
    (Identifier 35:0-5 token)
    (Function 35:8-38
      (Identifier 35:8-12 many) [
        (Function 35:13-37
          (Identifier 35:13-19 unless) [
            (Identifier 35:20-24 char)
            (Identifier 35:26-36 whitespace)
          ])
      ]))
  
  (DeclareGlobal 37:0-30
    (Identifier 37:0-4 word)
    (Function 37:7-30
      (Identifier 37:7-11 many) [
        (Or 37:12-29
          (Identifier 37:12-17 alnum)
          (Or 37:20-29
            (String 37:20-23 "_")
            (String 37:26-29 "-")))
      ]))
  
  (DeclareGlobal 39:0-42
    (Identifier 39:0-4 line)
    (Function 39:7-42
      (Identifier 39:7-18 chars_until) [
        (Or 39:19-41
          (Identifier 39:19-26 newline)
          (Identifier 39:29-41 end_of_input))
      ]))
  
  (DeclareGlobal 41:0-97
    (Identifier 41:0-5 space)
    (Or 42:2-89
      (String 42:2-5 " ")
      (Or 42:8-89
        (String 42:8-12 "\t") (esc)
        (Or 42:15-89
          (String 42:15-25 "\xc2\xa0") (esc)
          (Or 42:28-89
            (Range 42:28-50 (String 42:28-38 "\xe2\x80\x80") (String 42:40-50 "\xe2\x80\x8a")) (esc)
            (Or 42:53-89
              (String 42:53-63 "\xe2\x80\xaf") (esc)
              (Or 42:66-89
                (String 42:66-76 "\xe2\x81\x9f") (esc)
                (String 42:79-89 "\xe3\x80\x80")))))))) (esc)
  
  (DeclareGlobal 44:0-20
    (Identifier 44:0-6 spaces)
    (Function 44:9-20
      (Identifier 44:9-13 many) [
        (Identifier 44:14-19 space)
      ]))
  
  (DeclareGlobal 46:0-80
    (Identifier 46:0-7 newline)
    (Or 46:10-80
      (String 46:10-16 "\r (esc)
  ")
      (Or 46:19-80
        (Range 46:19-41 (String 46:19-29 "
  ") (String 46:31-41 "\r (no-eol) (esc)
  "))
        (Or 46:44-80
          (String 46:44-54 "\xc2\x85") (esc)
          (Or 46:57-80
            (String 46:57-67 "\xe2\x80\xa8") (esc)
            (String 46:70-80 "\xe2\x80\xa9")))))) (esc)
  
  (DeclareGlobal 48:0-12
    (Identifier 48:0-2 nl)
    (Identifier 48:5-12 newline))
  
  (DeclareGlobal 50:0-24
    (Identifier 50:0-8 newlines)
    (Function 50:11-24
      (Identifier 50:11-15 many) [
        (Identifier 50:16-23 newline)
      ]))
  
  (DeclareGlobal 52:0-14
    (Identifier 52:0-3 nls)
    (Identifier 52:6-14 newlines))
  
  (DeclareGlobal 54:0-34
    (Identifier 54:0-10 whitespace)
    (Function 54:13-34
      (Identifier 54:13-17 many) [
        (Or 54:18-33
          (Identifier 54:18-23 space)
          (Identifier 54:26-33 newline))
      ]))
  
  (DeclareGlobal 56:0-15
    (Identifier 56:0-2 ws)
    (Identifier 56:5-15 whitespace))
  
  (DeclareGlobal 58:0-42
    (Function 58:0-17
      (Identifier 58:0-11 chars_until) [
        (Identifier 58:12-16 stop)
      ])
    (Function 58:20-42
      (Identifier 58:20-30 many_until) [
        (Identifier 58:31-35 char)
        (Identifier 58:37-41 stop)
      ]))
  
  (DeclareGlobal 62:0-12
    (Identifier 62:0-5 digit)
    (Range 62:8-12 (NumberString 62:8-9 0) (NumberString 62:11-12 9)))
  
  (DeclareGlobal 64:0-54
    (Identifier 64:0-7 integer)
    (Function 64:10-54
      (Identifier 64:10-19 as_number) [
        (Merge 64:20-53
          (Function 64:20-30
            (Identifier 64:20-25 maybe) [
              (String 64:26-29 "-")
            ])
          (Identifier 64:33-53 _number_integer_part))
      ]))
  
  (DeclareGlobal 66:0-13
    (Identifier 66:0-3 int)
    (Identifier 66:6-13 integer))
  
  (DeclareGlobal 68:0-54
    (Identifier 68:0-20 non_negative_integer)
    (Function 68:23-54
      (Identifier 68:23-32 as_number) [
        (Identifier 68:33-53 _number_integer_part)
      ]))
  
  (DeclareGlobal 70:0-56
    (Identifier 70:0-16 negative_integer)
    (Function 70:19-56
      (Identifier 70:19-28 as_number) [
        (Merge 70:29-55
          (String 70:29-32 "-")
          (Identifier 70:35-55 _number_integer_part))
      ]))
  
  (DeclareGlobal 72:0-76
    (Identifier 72:0-5 float)
    (Function 72:8-76
      (Identifier 72:8-17 as_number) [
        (Merge 72:18-75
          (Merge 72:18-51
            (Function 72:18-28
              (Identifier 72:18-23 maybe) [
                (String 72:24-27 "-")
              ])
            (Identifier 72:31-51 _number_integer_part))
          (Identifier 72:54-75 _number_fraction_part))
      ]))
  
  (DeclareGlobal 74:0-97
    (Identifier 74:0-18 scientific_integer)
    (Function 74:21-97
      (Identifier 74:21-30 as_number) [
        (Merge 75:2-63
          (Merge 75:2-37
            (Function 75:2-12
              (Identifier 75:2-7 maybe) [
                (String 75:8-11 "-")
              ])
            (Identifier 76:2-22 _number_integer_part))
          (Identifier 77:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 80:0-121
    (Identifier 80:0-16 scientific_float)
    (Function 80:19-121
      (Identifier 80:19-28 as_number) [
        (Merge 81:2-89
          (Merge 81:2-63
            (Merge 81:2-37
              (Function 81:2-12
                (Identifier 81:2-7 maybe) [
                  (String 81:8-11 "-")
                ])
              (Identifier 82:2-22 _number_integer_part))
            (Identifier 83:2-23 _number_fraction_part))
          (Identifier 84:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 87:0-125
    (Identifier 87:0-6 number)
    (Function 87:9-125
      (Identifier 87:9-18 as_number) [
        (Merge 88:2-103
          (Merge 88:2-70
            (Merge 88:2-37
              (Function 88:2-12
                (Identifier 88:2-7 maybe) [
                  (String 88:8-11 "-")
                ])
              (Identifier 89:2-22 _number_integer_part))
            (Function 90:2-30
              (Identifier 90:2-7 maybe) [
                (Identifier 90:8-29 _number_fraction_part)
              ]))
          (Function 91:2-30
            (Identifier 91:2-7 maybe) [
              (Identifier 91:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 94:0-12
    (Identifier 94:0-3 num)
    (Identifier 94:6-12 number))
  
  (DeclareGlobal 96:0-123
    (Identifier 96:0-19 non_negative_number)
    (Function 96:22-123
      (Identifier 96:22-31 as_number) [
        (Merge 97:2-88
          (Merge 97:2-55
            (Identifier 97:2-22 _number_integer_part)
            (Function 98:2-30
              (Identifier 98:2-7 maybe) [
                (Identifier 98:8-29 _number_fraction_part)
              ]))
          (Function 99:2-30
            (Identifier 99:2-7 maybe) [
              (Identifier 99:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 102:0-127
    (Identifier 102:0-15 negative_number)
    (Function 102:18-127
      (Identifier 102:18-27 as_number) [
        (Merge 103:2-96
          (Merge 103:2-63
            (Merge 103:2-30
              (String 103:2-5 "-")
              (Identifier 104:2-22 _number_integer_part))
            (Function 105:2-30
              (Identifier 105:2-7 maybe) [
                (Identifier 105:8-29 _number_fraction_part)
              ]))
          (Function 106:2-30
            (Identifier 106:2-7 maybe) [
              (Identifier 106:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 109:0-54
    (Identifier 109:0-20 _number_integer_part)
    (Or 109:23-54
      (Merge 109:23-44
        (Range 109:24-32 (String 109:24-27 "1") (String 109:29-32 "9"))
        (Identifier 109:35-43 numerals))
      (Identifier 109:47-54 numeral)))
  
  (DeclareGlobal 111:0-38
    (Identifier 111:0-21 _number_fraction_part)
    (Merge 111:24-38
      (String 111:24-27 ".")
      (Identifier 111:30-38 numerals)))
  
  (DeclareGlobal 113:0-65
    (Identifier 113:0-21 _number_exponent_part)
    (Merge 113:24-65
      (Merge 113:24-54
        (Or 113:24-35
          (String 113:25-28 "e")
          (String 113:31-34 "E"))
        (Function 113:38-54
          (Identifier 113:38-43 maybe) [
            (Or 113:44-53
              (String 113:44-47 "-")
              (String 113:50-53 "+"))
          ]))
      (Identifier 113:57-65 numerals)))
  
  (DeclareGlobal 115:0-19
    (Identifier 115:0-12 binary_digit)
    (Range 115:15-19 (NumberString 115:15-16 0) (NumberString 115:18-19 1)))
  
  (DeclareGlobal 117:0-18
    (Identifier 117:0-11 octal_digit)
    (Range 117:14-18 (NumberString 117:14-15 0) (NumberString 117:17-18 7)))
  
  (DeclareGlobal 119:0-145
    (Identifier 119:0-9 hex_digit)
    (Or 120:2-133
      (Identifier 120:2-7 digit)
      (Or 121:2-123
        (Return 121:2-18
          (Or 121:3-12
            (String 121:3-6 "a")
            (String 121:9-12 "A"))
          (NumberString 121:15-17 10))
        (Or 122:2-102
          (Return 122:2-18
            (Or 122:3-12
              (String 122:3-6 "b")
              (String 122:9-12 "B"))
            (NumberString 122:15-17 11))
          (Or 123:2-81
            (Return 123:2-18
              (Or 123:3-12
                (String 123:3-6 "c")
                (String 123:9-12 "C"))
              (NumberString 123:15-17 12))
            (Or 124:2-60
              (Return 124:2-18
                (Or 124:3-12
                  (String 124:3-6 "d")
                  (String 124:9-12 "D"))
                (NumberString 124:15-17 13))
              (Or 125:2-39
                (Return 125:2-18
                  (Or 125:3-12
                    (String 125:3-6 "e")
                    (String 125:9-12 "E"))
                  (NumberString 125:15-17 14))
                (Return 126:2-18
                  (Or 126:3-12
                    (String 126:3-6 "f")
                    (String 126:9-12 "F"))
                  (NumberString 126:15-17 15)))))))))
  
  (DeclareGlobal 128:0-77
    (Identifier 128:0-14 binary_integer)
    (Return 128:17-77
      (Destructure 128:17-46
        (Function 128:17-36
          (Identifier 128:17-22 array) [
            (Identifier 128:23-35 binary_digit)
          ])
        (Identifier 128:40-46 Digits))
      (Function 128:49-77
        (Identifier 128:49-69 Num.FromBinaryDigits) [
          (Identifier 128:70-76 Digits)
        ])))
  
  (DeclareGlobal 130:0-74
    (Identifier 130:0-13 octal_integer)
    (Return 130:16-74
      (Destructure 130:16-44
        (Function 130:16-34
          (Identifier 130:16-21 array) [
            (Identifier 130:22-33 octal_digit)
          ])
        (Identifier 130:38-44 Digits))
      (Function 130:47-74
        (Identifier 130:47-66 Num.FromOctalDigits) [
          (Identifier 130:67-73 Digits)
        ])))
  
  (DeclareGlobal 132:0-68
    (Identifier 132:0-11 hex_integer)
    (Return 132:14-68
      (Destructure 132:14-40
        (Function 132:14-30
          (Identifier 132:14-19 array) [
            (Identifier 132:20-29 hex_digit)
          ])
        (Identifier 132:34-40 Digits))
      (Function 132:43-68
        (Identifier 132:43-60 Num.FromHexDigits) [
          (Identifier 132:61-67 Digits)
        ])))
  
  (DeclareGlobal 136:0-18
    (Function 136:0-7
      (True 136:0-4) [
        (Identifier 136:5-6 t)
      ])
    (Return 136:10-18
      (Identifier 136:10-11 t)
      (True 136:14-18)))
  
  (DeclareGlobal 138:0-20
    (Function 138:0-8
      (False 138:0-5) [
        (Identifier 138:6-7 f)
      ])
    (Return 138:11-20
      (Identifier 138:11-12 f)
      (False 138:15-20)))
  
  (DeclareGlobal 140:0-34
    (Function 140:0-13
      (Identifier 140:0-7 boolean) [
        (Identifier 140:8-9 t)
        (Identifier 140:11-12 f)
      ])
    (Or 140:16-34
      (Function 140:16-23
        (True 140:16-20) [
          (Identifier 140:21-22 t)
        ])
      (Function 140:26-34
        (False 140:26-31) [
          (Identifier 140:32-33 f)
        ])))
  
  (DeclareGlobal 142:0-14
    (Identifier 142:0-4 bool)
    (Identifier 142:7-14 boolean))
  
  (DeclareGlobal 144:0-18
    (Function 144:0-7
      (Null 144:0-4) [
        (Identifier 144:5-6 n)
      ])
    (Return 144:10-18
      (Identifier 144:10-11 n)
      (Null 144:14-18)))
  
  (DeclareGlobal 148:0-32
    (Function 148:0-11
      (Identifier 148:0-5 array) [
        (Identifier 148:6-10 elem)
      ])
    (Repeat 148:14-32
      (Function 148:14-26
        (Identifier 148:14-20 tuple1) [
          (Identifier 148:21-25 elem)
        ])
      (Range 148:29-32 (NumberString 148:29-30 1) ())))
  
  (DeclareGlobal 150:0-64
    (Function 150:0-20
      (Identifier 150:0-9 array_sep) [
        (Identifier 150:10-14 elem)
        (Identifier 150:16-19 sep)
      ])
    (Merge 150:23-64
      (Function 150:23-35
        (Identifier 150:23-29 tuple1) [
          (Identifier 150:30-34 elem)
        ])
      (Repeat 150:38-64
        (Function 150:39-57
          (Identifier 150:39-45 tuple1) [
            (TakeRight 150:46-56
              (Identifier 150:46-49 sep)
              (Identifier 150:52-56 elem))
          ])
        (Range 150:60-63 (NumberString 150:60-61 0) ()))))
  
  (DeclareGlobal 152:0-71
    (Function 152:0-23
      (Identifier 152:0-11 array_until) [
        (Identifier 152:12-16 elem)
        (Identifier 152:18-22 stop)
      ])
    (TakeLeft 152:26-71
      (Repeat 152:26-58
        (Function 152:26-52
          (Identifier 152:26-32 unless) [
            (Function 152:33-45
              (Identifier 152:33-39 tuple1) [
                (Identifier 152:40-44 elem)
              ])
            (Identifier 152:47-51 stop)
          ])
        (Range 152:55-58 (NumberString 152:55-56 1) ()))
      (Function 152:61-71
        (Identifier 152:61-65 peek) [
          (Identifier 152:66-70 stop)
        ])))
  
  (DeclareGlobal 154:0-44
    (Function 154:0-17
      (Identifier 154:0-11 maybe_array) [
        (Identifier 154:12-16 elem)
      ])
    (Function 154:20-44
      (Identifier 154:20-27 default) [
        (Function 154:28-39
          (Identifier 154:28-33 array) [
            (Identifier 154:34-38 elem)
          ])
        (Array 154:41-44 [])
      ]))
  
  (DeclareGlobal 156:0-62
    (Function 156:0-26
      (Identifier 156:0-15 maybe_array_sep) [
        (Identifier 156:16-20 elem)
        (Identifier 156:22-25 sep)
      ])
    (Function 156:29-62
      (Identifier 156:29-36 default) [
        (Function 156:37-57
          (Identifier 156:37-46 array_sep) [
            (Identifier 156:47-51 elem)
            (Identifier 156:53-56 sep)
          ])
        (Array 156:59-62 [])
      ]))
  
  (DeclareGlobal 158:0-37
    (Function 158:0-12
      (Identifier 158:0-6 tuple1) [
        (Identifier 158:7-11 elem)
      ])
    (Return 158:16-37
      (Destructure 158:16-28
        (Identifier 158:16-20 elem)
        (Identifier 158:24-28 Elem))
      (Array 158:31-37 [
        (Identifier 158:32-36 Elem)
      ])))
  
  (DeclareGlobal 160:0-59
    (Function 160:0-20
      (Identifier 160:0-6 tuple2) [
        (Identifier 160:7-12 elem1)
        (Identifier 160:14-19 elem2)
      ])
    (TakeRight 160:23-59
      (Destructure 160:23-34
        (Identifier 160:23-28 elem1)
        (Identifier 160:32-34 E1))
      (Return 160:37-59
        (Destructure 160:37-48
          (Identifier 160:37-42 elem2)
          (Identifier 160:46-48 E2))
        (Array 160:51-59 [
          (Identifier 160:52-54 E1)
          (Identifier 160:56-58 E2)
        ]))))
  
  (DeclareGlobal 162:0-74
    (Function 162:0-29
      (Identifier 162:0-10 tuple2_sep) [
        (Identifier 162:11-16 elem1)
        (Identifier 162:18-21 sep)
        (Identifier 162:23-28 elem2)
      ])
    (TakeRight 162:32-74
      (TakeRight 162:32-49
        (Destructure 162:32-43
          (Identifier 162:32-37 elem1)
          (Identifier 162:41-43 E1))
        (Identifier 162:46-49 sep))
      (Return 162:52-74
        (Destructure 162:52-63
          (Identifier 162:52-57 elem2)
          (Identifier 162:61-63 E2))
        (Array 162:66-74 [
          (Identifier 162:67-69 E1)
          (Identifier 162:71-73 E2)
        ]))))
  
  (DeclareGlobal 164:0-92
    (Function 164:0-27
      (Identifier 164:0-6 tuple3) [
        (Identifier 164:7-12 elem1)
        (Identifier 164:14-19 elem2)
        (Identifier 164:21-26 elem3)
      ])
    (TakeRight 165:2-62
      (TakeRight 165:2-29
        (Destructure 165:2-13
          (Identifier 165:2-7 elem1)
          (Identifier 165:11-13 E1))
        (Destructure 166:2-13
          (Identifier 166:2-7 elem2)
          (Identifier 166:11-13 E2)))
      (Return 167:2-30
        (Destructure 167:2-13
          (Identifier 167:2-7 elem3)
          (Identifier 167:11-13 E3))
        (Array 168:2-14 [
          (Identifier 168:3-5 E1)
          (Identifier 168:7-9 E2)
          (Identifier 168:11-13 E3)
        ]))))
  
  (DeclareGlobal 170:0-122
    (Function 170:0-43
      (Identifier 170:0-10 tuple3_sep) [
        (Identifier 170:11-16 elem1)
        (Identifier 170:18-22 sep1)
        (Identifier 170:24-29 elem2)
        (Identifier 170:31-35 sep2)
        (Identifier 170:37-42 elem3)
      ])
    (TakeRight 171:2-76
      (TakeRight 171:2-43
        (TakeRight 171:2-36
          (TakeRight 171:2-20
            (Destructure 171:2-13
              (Identifier 171:2-7 elem1)
              (Identifier 171:11-13 E1))
            (Identifier 171:16-20 sep1))
          (Destructure 172:2-13
            (Identifier 172:2-7 elem2)
            (Identifier 172:11-13 E2)))
        (Identifier 172:16-20 sep2))
      (Return 173:2-30
        (Destructure 173:2-13
          (Identifier 173:2-7 elem3)
          (Identifier 173:11-13 E3))
        (Array 174:2-14 [
          (Identifier 174:3-5 E1)
          (Identifier 174:7-9 E2)
          (Identifier 174:11-13 E3)
        ]))))
  
  (DeclareGlobal 176:0-33
    (Function 176:0-14
      (Identifier 176:0-5 tuple) [
        (Identifier 176:6-10 elem)
        (Identifier 176:12-13 N)
      ])
    (Repeat 176:17-33
      (Function 176:17-29
        (Identifier 176:17-23 tuple1) [
          (Identifier 176:24-28 elem)
        ])
      (Identifier 176:32-33 N)))
  
  (DeclareGlobal 178:0-71
    (Function 178:0-23
      (Identifier 178:0-9 tuple_sep) [
        (Identifier 178:10-14 elem)
        (Identifier 178:16-19 sep)
        (Identifier 178:21-22 N)
      ])
    (Merge 178:26-71
      (Function 178:26-38
        (Identifier 178:26-32 tuple1) [
          (Identifier 178:33-37 elem)
        ])
      (Repeat 178:41-71
        (Function 178:42-60
          (Identifier 178:42-48 tuple1) [
            (TakeRight 178:49-59
              (Identifier 178:49-52 sep)
              (Identifier 178:55-59 elem))
          ])
        (NumberSubtract 178:63-70
          (Identifier 178:64-65 N)
          (NumberString 178:68-69 1)))))
  
  (DeclareGlobal 180:0-120
    (Function 180:0-28
      (Identifier 180:0-4 rows) [
        (Identifier 180:5-9 elem)
        (Identifier 180:11-18 col_sep)
        (Identifier 180:20-27 row_sep)
      ])
    (Merge 181:2-89
      (Function 181:2-34
        (Identifier 181:2-8 tuple1) [
          (Function 181:9-33
            (Identifier 181:9-18 array_sep) [
              (Identifier 181:19-23 elem)
              (Identifier 181:25-32 col_sep)
            ])
        ])
      (Repeat 182:2-52
        (Function 182:3-45
          (Identifier 182:3-9 tuple1) [
            (TakeRight 182:10-44
              (Identifier 182:10-17 row_sep)
              (Function 182:20-44
                (Identifier 182:20-29 array_sep) [
                  (Identifier 182:30-34 elem)
                  (Identifier 182:36-43 col_sep)
                ]))
          ])
        (Range 182:48-51 (NumberString 182:48-49 0) ()))))
  
  (DeclareGlobal 184:0-194
    (Function 184:0-40
      (Identifier 184:0-11 rows_padded) [
        (Identifier 184:12-16 elem)
        (Identifier 184:18-25 col_sep)
        (Identifier 184:27-34 row_sep)
        (Identifier 184:36-39 Pad)
      ])
    (TakeRight 185:2-151
      (TakeRight 185:2-79
        (Destructure 185:2-61
          (Function 185:2-43
            (Identifier 185:2-6 peek) [
              (Function 185:7-42
                (Identifier 185:7-18 _dimensions) [
                  (Identifier 185:19-23 elem)
                  (Identifier 185:25-32 col_sep)
                  (Identifier 185:34-41 row_sep)
                ])
            ])
          (Array 185:47-61 [
            (Identifier 185:48-57 MaxRowLen)
            (Identifier 185:59-60 _)
          ]))
        (Destructure 186:2-15
          (Identifier 186:2-6 elem)
          (Identifier 186:10-15 First)))
      (Function 186:18-87
        (Identifier 186:18-30 _rows_padded) [
          (Identifier 186:31-35 elem)
          (Identifier 186:37-44 col_sep)
          (Identifier 186:46-53 row_sep)
          (Identifier 186:55-58 Pad)
          (ValueLabel 186:60-61 (NumberString 186:61-62 1))
          (Identifier 186:64-73 MaxRowLen)
          (Array 186:75-82 [
            (Identifier 186:76-81 First)
          ])
          (Array 186:84-87 [])
        ])))
  
  (DeclareGlobal 188:0-442
    (Function 188:0-77
      (Identifier 188:0-12 _rows_padded) [
        (Identifier 188:13-17 elem)
        (Identifier 188:19-26 col_sep)
        (Identifier 188:28-35 row_sep)
        (Identifier 188:37-40 Pad)
        (Identifier 188:42-48 RowLen)
        (Identifier 188:50-59 MaxRowLen)
        (Identifier 188:61-67 AccRow)
        (Identifier 188:69-76 AccRows)
      ])
    (Conditional 189:2-362
      (Destructure 189:2-24
        (TakeRight 189:2-16
          (Identifier 189:2-9 col_sep)
          (Identifier 189:12-16 elem))
        (Identifier 189:20-24 Elem))
      (Function 190:2-99
        (Identifier 190:2-14 _rows_padded) [
          (Identifier 190:15-19 elem)
          (Identifier 190:21-28 col_sep)
          (Identifier 190:30-37 row_sep)
          (Identifier 190:39-42 Pad)
          (Function 190:44-59
            (Identifier 190:44-51 Num.Inc) [
              (Identifier 190:52-58 RowLen)
            ])
          (Identifier 190:61-70 MaxRowLen)
          (Merge 190:72-89
            (Merge 190:72-73
              (Array 190:72-73 [])
              (Identifier 190:76-82 AccRow))
            (Array 190:84-89 [
              (Identifier 190:84-88 Elem)
            ]))
          (Identifier 190:91-98 AccRows)
        ])
      (Conditional 191:2-233
        (Destructure 191:2-27
          (TakeRight 191:2-16
            (Identifier 191:2-9 row_sep)
            (Identifier 191:12-16 elem))
          (Identifier 191:20-27 NextRow))
        (Function 192:2-131
          (Identifier 192:2-14 _rows_padded) [
            (Identifier 192:15-19 elem)
            (Identifier 192:21-28 col_sep)
            (Identifier 192:30-37 row_sep)
            (Identifier 192:39-42 Pad)
            (ValueLabel 192:44-45 (NumberString 192:45-46 1))
            (Identifier 192:48-57 MaxRowLen)
            (Array 192:59-68 [
              (Identifier 192:60-67 NextRow)
            ])
            (Merge 192:70-130
              (Merge 192:70-71
                (Array 192:70-71 [])
                (Identifier 192:74-81 AccRows))
              (Array 192:83-130 [
                (Function 192:83-129
                  (Identifier 192:83-96 Array.AppendN) [
                    (Identifier 192:97-103 AccRow)
                    (Identifier 192:105-108 Pad)
                    (NumberSubtract 192:110-128
                      (Identifier 192:110-119 MaxRowLen)
                      (Identifier 192:122-128 RowLen))
                  ])
              ]))
          ])
        (Function 193:2-69
          (Identifier 193:2-7 const) [
            (Merge 193:8-68
              (Merge 193:8-9
                (Array 193:8-9 [])
                (Identifier 193:12-19 AccRows))
              (Array 193:21-68 [
                (Function 193:21-67
                  (Identifier 193:21-34 Array.AppendN) [
                    (Identifier 193:35-41 AccRow)
                    (Identifier 193:43-46 Pad)
                    (NumberSubtract 193:48-66
                      (Identifier 193:48-57 MaxRowLen)
                      (Identifier 193:60-66 RowLen))
                  ])
              ]))
          ]))))
  
  (DeclareGlobal 195:0-95
    (Function 195:0-35
      (Identifier 195:0-11 _dimensions) [
        (Identifier 195:12-16 elem)
        (Identifier 195:18-25 col_sep)
        (Identifier 195:27-34 row_sep)
      ])
    (TakeRight 196:2-57
      (Identifier 196:2-6 elem)
      (Function 196:9-57
        (Identifier 196:9-21 __dimensions) [
          (Identifier 196:22-26 elem)
          (Identifier 196:28-35 col_sep)
          (Identifier 196:37-44 row_sep)
          (ValueLabel 196:46-47 (NumberString 196:47-48 1))
          (ValueLabel 196:50-51 (NumberString 196:51-52 1))
          (ValueLabel 196:54-55 (NumberString 196:55-56 0))
        ])))
  
  (DeclareGlobal 198:0-316
    (Function 198:0-63
      (Identifier 198:0-12 __dimensions) [
        (Identifier 198:13-17 elem)
        (Identifier 198:19-26 col_sep)
        (Identifier 198:28-35 row_sep)
        (Identifier 198:37-43 RowLen)
        (Identifier 198:45-51 ColLen)
        (Identifier 198:53-62 MaxRowLen)
      ])
    (Conditional 199:2-250
      (TakeRight 199:2-16
        (Identifier 199:2-9 col_sep)
        (Identifier 199:12-16 elem))
      (Function 200:2-74
        (Identifier 200:2-14 __dimensions) [
          (Identifier 200:15-19 elem)
          (Identifier 200:21-28 col_sep)
          (Identifier 200:30-37 row_sep)
          (Function 200:39-54
            (Identifier 200:39-46 Num.Inc) [
              (Identifier 200:47-53 RowLen)
            ])
          (Identifier 200:56-62 ColLen)
          (Identifier 200:64-73 MaxRowLen)
        ])
      (Conditional 201:2-154
        (TakeRight 201:2-16
          (Identifier 201:2-9 row_sep)
          (Identifier 201:12-16 elem))
        (Function 202:2-87
          (Identifier 202:2-14 __dimensions) [
            (Identifier 202:15-19 elem)
            (Identifier 202:21-28 col_sep)
            (Identifier 202:30-37 row_sep)
            (ValueLabel 202:39-40 (NumberString 202:40-41 1))
            (Function 202:43-58
              (Identifier 202:43-50 Num.Inc) [
                (Identifier 202:51-57 ColLen)
              ])
            (Function 202:60-86
              (Identifier 202:60-67 Num.Max) [
                (Identifier 202:68-74 RowLen)
                (Identifier 202:76-85 MaxRowLen)
              ])
          ])
        (Function 203:2-45
          (Identifier 203:2-7 const) [
            (Array 203:8-44 [
              (Function 203:9-35
                (Identifier 203:9-16 Num.Max) [
                  (Identifier 203:17-23 RowLen)
                  (Identifier 203:25-34 MaxRowLen)
                ])
              (Identifier 203:37-43 ColLen)
            ])
          ]))))
  
  (DeclareGlobal 205:0-98
    (Function 205:0-31
      (Identifier 205:0-7 columns) [
        (Identifier 205:8-12 elem)
        (Identifier 205:14-21 col_sep)
        (Identifier 205:23-30 row_sep)
      ])
    (Return 206:2-64
      (Destructure 206:2-38
        (Function 206:2-30
          (Identifier 206:2-6 rows) [
            (Identifier 206:7-11 elem)
            (Identifier 206:13-20 col_sep)
            (Identifier 206:22-29 row_sep)
          ])
        (Identifier 206:34-38 Rows))
      (Function 207:2-23
        (Identifier 207:2-17 Table.Transpose) [
          (Identifier 207:18-22 Rows)
        ])))
  
  (DeclareGlobal 209:0-14
    (Identifier 209:0-4 cols)
    (Identifier 209:7-14 columns))
  
  (DeclareGlobal 211:0-122
    (Function 211:0-43
      (Identifier 211:0-14 columns_padded) [
        (Identifier 211:15-19 elem)
        (Identifier 211:21-28 col_sep)
        (Identifier 211:30-37 row_sep)
        (Identifier 211:39-42 Pad)
      ])
    (Return 212:2-76
      (Destructure 212:2-50
        (Function 212:2-42
          (Identifier 212:2-13 rows_padded) [
            (Identifier 212:14-18 elem)
            (Identifier 212:20-27 col_sep)
            (Identifier 212:29-36 row_sep)
            (Identifier 212:38-41 Pad)
          ])
        (Identifier 212:46-50 Rows))
      (Function 213:2-23
        (Identifier 213:2-17 Table.Transpose) [
          (Identifier 213:18-22 Rows)
        ])))
  
  (DeclareGlobal 215:0-28
    (Identifier 215:0-11 cols_padded)
    (Identifier 215:14-28 columns_padded))
  
  (DeclareGlobal 219:0-43
    (Function 219:0-18
      (Identifier 219:0-6 object) [
        (Identifier 219:7-10 key)
        (Identifier 219:12-17 value)
      ])
    (Repeat 219:21-43
      (Function 219:21-37
        (Identifier 219:21-25 pair) [
          (Identifier 219:26-29 key)
          (Identifier 219:31-36 value)
        ])
      (Range 219:40-43 (NumberString 219:40-41 1) ())))
  
  (DeclareGlobal 221:0-117
    (Function 221:0-35
      (Identifier 221:0-10 object_sep) [
        (Identifier 221:11-14 key)
        (Identifier 221:16-22 kv_sep)
        (Identifier 221:24-29 value)
        (Identifier 221:31-34 sep)
      ])
    (Merge 222:2-79
      (Function 222:2-30
        (Identifier 222:2-10 pair_sep) [
          (Identifier 222:11-14 key)
          (Identifier 222:16-22 kv_sep)
          (Identifier 222:24-29 value)
        ])
      (Repeat 223:2-46
        (TakeRight 223:3-39
          (Identifier 223:4-7 sep)
          (Function 223:10-38
            (Identifier 223:10-18 pair_sep) [
              (Identifier 223:19-22 key)
              (Identifier 223:24-30 kv_sep)
              (Identifier 223:32-37 value)
            ]))
        (Range 223:42-45 (NumberString 223:42-43 0) ()))))
  
  (DeclareGlobal 225:0-84
    (Function 225:0-30
      (Identifier 225:0-12 object_until) [
        (Identifier 225:13-16 key)
        (Identifier 225:18-23 value)
        (Identifier 225:25-29 stop)
      ])
    (TakeLeft 226:2-51
      (Repeat 226:2-38
        (Function 226:2-32
          (Identifier 226:2-8 unless) [
            (Function 226:9-25
              (Identifier 226:9-13 pair) [
                (Identifier 226:14-17 key)
                (Identifier 226:19-24 value)
              ])
            (Identifier 226:27-31 stop)
          ])
        (Range 226:35-38 (NumberString 226:35-36 1) ()))
      (Function 226:41-51
        (Identifier 226:41-45 peek) [
          (Identifier 226:46-50 stop)
        ])))
  
  (DeclareGlobal 228:0-58
    (Function 228:0-24
      (Identifier 228:0-12 maybe_object) [
        (Identifier 228:13-16 key)
        (Identifier 228:18-23 value)
      ])
    (Function 228:27-58
      (Identifier 228:27-34 default) [
        (Function 228:35-53
          (Identifier 228:35-41 object) [
            (Identifier 228:42-45 key)
            (Identifier 228:47-52 value)
          ])
        (Object 228:55-58 [])
      ]))
  
  (DeclareGlobal 230:0-98
    (Function 230:0-43
      (Identifier 230:0-16 maybe_object_sep) [
        (Identifier 230:17-20 key)
        (Identifier 230:22-30 pair_sep)
        (Identifier 230:32-37 value)
        (Identifier 230:39-42 sep)
      ])
    (Function 231:2-52
      (Identifier 231:2-9 default) [
        (Function 231:10-47
          (Identifier 231:10-20 object_sep) [
            (Identifier 231:21-24 key)
            (Identifier 231:26-34 pair_sep)
            (Identifier 231:36-41 value)
            (Identifier 231:43-46 sep)
          ])
        (Object 231:49-52 [])
      ]))
  
  (DeclareGlobal 233:0-49
    (Function 233:0-16
      (Identifier 233:0-4 pair) [
        (Identifier 233:5-8 key)
        (Identifier 233:10-15 value)
      ])
    (TakeRight 233:19-49
      (Destructure 233:19-27
        (Identifier 233:19-22 key)
        (Identifier 233:26-27 K))
      (Return 233:30-49
        (Destructure 233:30-40
          (Identifier 233:30-35 value)
          (Identifier 233:39-40 V))
        (Object 233:43-49 [
          (ObjectPair (Identifier 233:44-45 K) (Identifier 233:47-48 V))
        ]))))
  
  (DeclareGlobal 235:0-64
    (Function 235:0-25
      (Identifier 235:0-8 pair_sep) [
        (Identifier 235:9-12 key)
        (Identifier 235:14-17 sep)
        (Identifier 235:19-24 value)
      ])
    (TakeRight 235:28-64
      (TakeRight 235:28-42
        (Destructure 235:28-36
          (Identifier 235:28-31 key)
          (Identifier 235:35-36 K))
        (Identifier 235:39-42 sep))
      (Return 235:45-64
        (Destructure 235:45-55
          (Identifier 235:45-50 value)
          (Identifier 235:54-55 V))
        (Object 235:58-64 [
          (ObjectPair (Identifier 235:59-60 K) (Identifier 235:62-63 V))
        ]))))
  
  (DeclareGlobal 237:0-51
    (Function 237:0-19
      (Identifier 237:0-7 record1) [
        (Identifier 237:8-11 Key)
        (Identifier 237:13-18 value)
      ])
    (Return 237:22-51
      (Destructure 237:22-36
        (Identifier 237:22-27 value)
        (Identifier 237:31-36 Value))
      (Object 237:39-51 [
        (ObjectPair (Identifier 237:40-43 Key) (Identifier 237:45-50 Value))
      ])))
  
  (DeclareGlobal 239:0-94
    (Function 239:0-35
      (Identifier 239:0-7 record2) [
        (Identifier 239:8-12 Key1)
        (Identifier 239:14-20 value1)
        (Identifier 239:22-26 Key2)
        (Identifier 239:28-34 value2)
      ])
    (TakeRight 240:2-56
      (Destructure 240:2-14
        (Identifier 240:2-8 value1)
        (Identifier 240:12-14 V1))
      (Return 241:2-39
        (Destructure 241:2-14
          (Identifier 241:2-8 value2)
          (Identifier 241:12-14 V2))
        (Object 242:2-22 [
          (ObjectPair (Identifier 242:3-7 Key1) (Identifier 242:9-11 V1))
          (ObjectPair (Identifier 242:13-17 Key2) (Identifier 242:19-21 V2))
        ]))))
  
  (DeclareGlobal 244:0-109
    (Function 244:0-44
      (Identifier 244:0-11 record2_sep) [
        (Identifier 244:12-16 Key1)
        (Identifier 244:18-24 value1)
        (Identifier 244:26-29 sep)
        (Identifier 244:31-35 Key2)
        (Identifier 244:37-43 value2)
      ])
    (TakeRight 245:2-62
      (TakeRight 245:2-20
        (Destructure 245:2-14
          (Identifier 245:2-8 value1)
          (Identifier 245:12-14 V1))
        (Identifier 245:17-20 sep))
      (Return 246:2-39
        (Destructure 246:2-14
          (Identifier 246:2-8 value2)
          (Identifier 246:12-14 V2))
        (Object 247:2-22 [
          (ObjectPair (Identifier 247:3-7 Key1) (Identifier 247:9-11 V1))
          (ObjectPair (Identifier 247:13-17 Key2) (Identifier 247:19-21 V2))
        ]))))
  
  (DeclareGlobal 249:0-135
    (Function 249:0-49
      (Identifier 249:0-7 record3) [
        (Identifier 249:8-12 Key1)
        (Identifier 249:14-20 value1)
        (Identifier 249:22-26 Key2)
        (Identifier 249:28-34 value2)
        (Identifier 249:36-40 Key3)
        (Identifier 249:42-48 value3)
      ])
    (TakeRight 250:2-83
      (TakeRight 250:2-31
        (Destructure 250:2-14
          (Identifier 250:2-8 value1)
          (Identifier 250:12-14 V1))
        (Destructure 251:2-14
          (Identifier 251:2-8 value2)
          (Identifier 251:12-14 V2)))
      (Return 252:2-49
        (Destructure 252:2-14
          (Identifier 252:2-8 value3)
          (Identifier 252:12-14 V3))
        (Object 253:2-32 [
          (ObjectPair (Identifier 253:3-7 Key1) (Identifier 253:9-11 V1))
          (ObjectPair (Identifier 253:13-17 Key2) (Identifier 253:19-21 V2))
          (ObjectPair (Identifier 253:23-27 Key3) (Identifier 253:29-31 V3))
        ]))))
  
  (DeclareGlobal 255:0-165
    (Function 255:0-65
      (Identifier 255:0-11 record3_sep) [
        (Identifier 255:12-16 Key1)
        (Identifier 255:18-24 value1)
        (Identifier 255:26-30 sep1)
        (Identifier 255:32-36 Key2)
        (Identifier 255:38-44 value2)
        (Identifier 255:46-50 sep2)
        (Identifier 255:52-56 Key3)
        (Identifier 255:58-64 value3)
      ])
    (TakeRight 256:2-97
      (TakeRight 256:2-45
        (TakeRight 256:2-38
          (TakeRight 256:2-21
            (Destructure 256:2-14
              (Identifier 256:2-8 value1)
              (Identifier 256:12-14 V1))
            (Identifier 256:17-21 sep1))
          (Destructure 257:2-14
            (Identifier 257:2-8 value2)
            (Identifier 257:12-14 V2)))
        (Identifier 257:17-21 sep2))
      (Return 258:2-49
        (Destructure 258:2-14
          (Identifier 258:2-8 value3)
          (Identifier 258:12-14 V3))
        (Object 259:2-32 [
          (ObjectPair (Identifier 259:3-7 Key1) (Identifier 259:9-11 V1))
          (ObjectPair (Identifier 259:13-17 Key2) (Identifier 259:19-21 V2))
          (ObjectPair (Identifier 259:23-27 Key3) (Identifier 259:29-31 V3))
        ]))))
  
  (DeclareGlobal 263:0-17
    (Function 263:0-7
      (Identifier 263:0-4 many) [
        (Identifier 263:5-6 p)
      ])
    (Repeat 263:10-17
      (Identifier 263:10-11 p)
      (Range 263:14-17 (NumberString 263:14-15 1) ())))
  
  (DeclareGlobal 265:0-40
    (Function 265:0-16
      (Identifier 265:0-8 many_sep) [
        (Identifier 265:9-10 p)
        (Identifier 265:12-15 sep)
      ])
    (Merge 265:19-40
      (Identifier 265:19-20 p)
      (Repeat 265:23-40
        (TakeRight 265:24-33
          (Identifier 265:25-28 sep)
          (Identifier 265:31-32 p))
        (Range 265:36-39 (NumberString 265:36-37 0) ()))))
  
  (DeclareGlobal 267:0-56
    (Function 267:0-19
      (Identifier 267:0-10 many_until) [
        (Identifier 267:11-12 p)
        (Identifier 267:14-18 stop)
      ])
    (TakeLeft 267:22-56
      (Repeat 267:22-43
        (Function 267:22-37
          (Identifier 267:22-28 unless) [
            (Identifier 267:29-30 p)
            (Identifier 267:32-36 stop)
          ])
        (Range 267:40-43 (NumberString 267:40-41 1) ()))
      (Function 267:46-56
        (Identifier 267:46-50 peek) [
          (Identifier 267:51-55 stop)
        ])))
  
  (DeclareGlobal 269:0-23
    (Function 269:0-13
      (Identifier 269:0-10 maybe_many) [
        (Identifier 269:11-12 p)
      ])
    (Repeat 269:16-23
      (Identifier 269:16-17 p)
      (Range 269:20-23 (NumberString 269:20-21 0) ())))
  
  (DeclareGlobal 271:0-51
    (Function 271:0-22
      (Identifier 271:0-14 maybe_many_sep) [
        (Identifier 271:15-16 p)
        (Identifier 271:18-21 sep)
      ])
    (Or 271:25-51
      (Function 271:25-41
        (Identifier 271:25-33 many_sep) [
          (Identifier 271:34-35 p)
          (Identifier 271:37-40 sep)
        ])
      (Identifier 271:44-51 succeed)))
  
  (DeclareGlobal 275:0-27
    (Function 275:0-7
      (Identifier 275:0-4 peek) [
        (Identifier 275:5-6 p)
      ])
    (Backtrack 275:10-27
      (Destructure 275:10-16
        (Identifier 275:10-11 p)
        (Identifier 275:15-16 V))
      (Function 275:19-27
        (Identifier 275:19-24 const) [
          (Identifier 275:25-26 V)
        ])))
  
  (DeclareGlobal 277:0-22
    (Function 277:0-8
      (Identifier 277:0-5 maybe) [
        (Identifier 277:6-7 p)
      ])
    (Or 277:11-22
      (Identifier 277:11-12 p)
      (Identifier 277:15-22 succeed)))
  
  (DeclareGlobal 279:0-42
    (Function 279:0-19
      (Identifier 279:0-6 unless) [
        (Identifier 279:7-8 p)
        (Identifier 279:10-18 excluded)
      ])
    (Conditional 279:22-42
      (Identifier 279:22-30 excluded)
      (Identifier 279:33-38 @fail)
      (Identifier 279:41-42 p)))
  
  (DeclareGlobal 281:0-17
    (Function 281:0-7
      (Identifier 281:0-4 skip) [
        (Identifier 281:5-6 p)
      ])
    (Function 281:10-17
      (Null 281:10-14) [
        (Identifier 281:15-16 p)
      ]))
  
  (DeclareGlobal 283:0-30
    (Function 283:0-7
      (Identifier 283:0-4 find) [
        (Identifier 283:5-6 p)
      ])
    (Or 283:10-30
      (Identifier 283:10-11 p)
      (TakeRight 283:14-30
        (Identifier 283:15-19 char)
        (Function 283:22-29
          (Identifier 283:22-26 find) [
            (Identifier 283:27-28 p)
          ]))))
  
  (DeclareGlobal 285:0-48
    (Function 285:0-11
      (Identifier 285:0-8 find_all) [
        (Identifier 285:9-10 p)
      ])
    (TakeLeft 285:14-48
      (Function 285:14-28
        (Identifier 285:14-19 array) [
          (Function 285:20-27
            (Identifier 285:20-24 find) [
              (Identifier 285:25-26 p)
            ])
        ])
      (Function 285:31-48
        (Identifier 285:31-36 maybe) [
          (Function 285:37-47
            (Identifier 285:37-41 many) [
              (Identifier 285:42-46 char)
            ])
        ])))
  
  (DeclareGlobal 287:0-71
    (Function 287:0-20
      (Identifier 287:0-11 find_before) [
        (Identifier 287:12-13 p)
        (Identifier 287:15-19 stop)
      ])
    (Conditional 287:23-71
      (Identifier 287:23-27 stop)
      (Identifier 287:30-35 @fail)
      (Or 287:38-71
        (Identifier 287:38-39 p)
        (TakeRight 287:42-71
          (Identifier 287:43-47 char)
          (Function 287:50-70
            (Identifier 287:50-61 find_before) [
              (Identifier 287:62-63 p)
              (Identifier 287:65-69 stop)
            ])))))
  
  (DeclareGlobal 289:0-81
    (Function 289:0-24
      (Identifier 289:0-15 find_all_before) [
        (Identifier 289:16-17 p)
        (Identifier 289:19-23 stop)
      ])
    (TakeLeft 289:27-81
      (Function 289:27-54
        (Identifier 289:27-32 array) [
          (Function 289:33-53
            (Identifier 289:33-44 find_before) [
              (Identifier 289:45-46 p)
              (Identifier 289:48-52 stop)
            ])
        ])
      (Function 289:57-81
        (Identifier 289:57-62 maybe) [
          (Function 289:63-80
            (Identifier 289:63-74 chars_until) [
              (Identifier 289:75-79 stop)
            ])
        ])))
  
  (DeclareGlobal 291:0-22
    (Identifier 291:0-7 succeed)
    (Function 291:10-22
      (Identifier 291:10-15 const) [
        (ValueLabel 291:16-17 (Null 291:17-21))
      ]))
  
  (DeclareGlobal 293:0-28
    (Function 293:0-13
      (Identifier 293:0-7 default) [
        (Identifier 293:8-9 p)
        (Identifier 293:11-12 D)
      ])
    (Or 293:16-28
      (Identifier 293:16-17 p)
      (Function 293:20-28
        (Identifier 293:20-25 const) [
          (Identifier 293:26-27 D)
        ])))
  
  (DeclareGlobal 295:0-17
    (Function 295:0-8
      (Identifier 295:0-5 const) [
        (Identifier 295:6-7 C)
      ])
    (Return 295:11-17
      (String 295:11-13 "")
      (Identifier 295:16-17 C)))
  
  (DeclareGlobal 297:0-34
    (Function 297:0-12
      (Identifier 297:0-9 as_number) [
        (Identifier 297:10-11 p)
      ])
    (Return 297:15-34
      (Destructure 297:15-30
        (Identifier 297:15-16 p)
        (StringTemplate 297:20-30 [
          (Merge 297:23-28
            (NumberString 297:23-24 0)
            (Identifier 297:27-28 N))
        ]))
      (Identifier 297:33-34 N)))
  
  (DeclareGlobal 299:0-21
    (Function 299:0-12
      (Identifier 299:0-9 as_string) [
        (Identifier 299:10-11 p)
      ])
    (StringTemplate 299:15-21 [
      (Identifier 299:18-19 p)
    ]))
  
  (DeclareGlobal 301:0-35
    (Function 301:0-17
      (Identifier 301:0-8 surround) [
        (Identifier 301:9-10 p)
        (Identifier 301:12-16 fill)
      ])
    (TakeLeft 301:20-35
      (TakeRight 301:20-28
        (Identifier 301:20-24 fill)
        (Identifier 301:27-28 p))
      (Identifier 301:31-35 fill)))
  
  (DeclareGlobal 303:0-37
    (Identifier 303:0-12 end_of_input)
    (Conditional 303:15-37
      (Identifier 303:15-19 char)
      (Identifier 303:22-27 @fail)
      (Identifier 303:30-37 succeed)))
  
  (DeclareGlobal 305:0-18
    (Identifier 305:0-3 end)
    (Identifier 305:6-18 end_of_input))
  
  (DeclareGlobal 307:0-56
    (Function 307:0-8
      (Identifier 307:0-5 input) [
        (Identifier 307:6-7 p)
      ])
    (TakeLeft 307:11-56
      (Function 307:11-41
        (Identifier 307:11-19 surround) [
          (Identifier 307:20-21 p)
          (Function 307:23-40
            (Identifier 307:23-28 maybe) [
              (Identifier 307:29-39 whitespace)
            ])
        ])
      (Identifier 307:44-56 end_of_input)))
  
  (DeclareGlobal 309:0-51
    (Function 309:0-17
      (Identifier 309:0-11 one_or_both) [
        (Identifier 309:12-13 a)
        (Identifier 309:15-16 b)
      ])
    (Or 309:20-51
      (Merge 309:20-34
        (Identifier 309:21-22 a)
        (Function 309:25-33
          (Identifier 309:25-30 maybe) [
            (Identifier 309:31-32 b)
          ]))
      (Merge 309:37-51
        (Function 309:38-46
          (Identifier 309:38-43 maybe) [
            (Identifier 309:44-45 a)
          ])
        (Identifier 309:49-50 b))))
  
  (DeclareGlobal 313:0-110
    (Identifier 313:0-4 json)
    (Or 314:2-103
      (Identifier 314:2-14 json.boolean)
      (Or 315:2-86
        (Identifier 315:2-11 json.null)
        (Or 316:2-72
          (Identifier 316:2-13 json.number)
          (Or 317:2-56
            (Identifier 317:2-13 json.string)
            (Or 318:2-40
              (Function 318:2-18
                (Identifier 318:2-12 json.array) [
                  (Identifier 318:13-17 json)
                ])
              (Function 319:2-19
                (Identifier 319:2-13 json.object) [
                  (Identifier 319:14-18 json)
                ])))))))
  
  (DeclareGlobal 321:0-39
    (Identifier 321:0-12 json.boolean)
    (Function 321:15-39
      (Identifier 321:15-22 boolean) [
        (String 321:23-29 "true")
        (String 321:31-38 "false")
      ]))
  
  (DeclareGlobal 323:0-24
    (Identifier 323:0-9 json.null)
    (Function 323:12-24
      (Null 323:12-16) [
        (String 323:17-23 "null")
      ]))
  
  (DeclareGlobal 325:0-20
    (Identifier 325:0-11 json.number)
    (Identifier 325:14-20 number))
  
  (DeclareGlobal 327:0-43
    (Identifier 327:0-11 json.string)
    (TakeLeft 327:14-43
      (TakeRight 327:14-37
        (String 327:14-17 """)
        (Identifier 327:20-37 _json.string_body))
      (String 327:40-43 """)))
  
  (DeclareGlobal 329:0-133
    (Identifier 329:0-17 _json.string_body)
    (Or 330:2-113
      (Function 330:2-100
        (Identifier 330:2-6 many) [
          (Or 331:4-88
            (Identifier 331:4-22 _escaped_ctrl_char)
            (Or 332:4-63
              (Identifier 332:4-20 _escaped_unicode)
              (Function 333:4-40
                (Identifier 333:4-10 unless) [
                  (Identifier 333:11-15 char)
                  (Or 333:17-39
                    (Identifier 333:17-27 _ctrl_char)
                    (Or 333:30-39
                      (String 333:30-33 "\")
                      (String 333:36-39 """)))
                ])))
        ])
      (Function 334:6-16
        (Identifier 334:6-11 const) [
          (ValueLabel 334:12-13 (String 334:13-15 ""))
        ])))
  
  (DeclareGlobal 336:0-35
    (Identifier 336:0-10 _ctrl_char)
    (Range 336:13-35 (String 336:13-23 "\x00") (String 336:25-35 "\x1f"))) (esc)
  
  (DeclareGlobal 338:0-159
    (Identifier 338:0-18 _escaped_ctrl_char)
    (Or 339:2-138
      (Return 339:2-14
        (String 339:3-7 "\"")
        (String 339:10-13 """))
      (Or 340:2-121
        (Return 340:2-14
          (String 340:3-7 "\\")
          (String 340:10-13 "\"))
        (Or 341:2-104
          (Return 341:2-14
            (String 341:3-7 "\/")
            (String 341:10-13 "/"))
          (Or 342:2-87
            (Return 342:2-15
              (String 342:3-7 "\b")
              (String 342:10-14 "\x08")) (esc)
            (Or 343:2-69
              (Return 343:2-15
                (String 343:3-7 "\f")
                (String 343:10-14 "\x0c")) (esc)
              (Or 344:2-51
                (Return 344:2-15
                  (String 344:3-7 "\n")
                  (String 344:10-14 "
  "))
                (Or 345:2-33
                  (Return 345:2-15
                    (String 345:3-7 "\r")
                    (String 345:10-14 "\r (no-eol) (esc)
  "))
                  (Return 346:2-15
                    (String 346:3-7 "\t")
                    (String 346:10-14 "\t")))))))))) (esc)
  
  (DeclareGlobal 348:0-63
    (Identifier 348:0-16 _escaped_unicode)
    (Or 348:19-63
      (Identifier 348:19-42 _escaped_surrogate_pair)
      (Identifier 348:45-63 _escaped_codepoint)))
  
  (DeclareGlobal 350:0-73
    (Identifier 350:0-23 _escaped_surrogate_pair)
    (Or 350:26-73
      (Identifier 350:26-47 _valid_surrogate_pair)
      (Identifier 350:50-73 _invalid_surrogate_pair)))
  
  (DeclareGlobal 352:0-100
    (Identifier 352:0-21 _valid_surrogate_pair)
    (TakeRight 353:2-76
      (Destructure 353:2-22
        (Identifier 353:2-17 _high_surrogate)
        (Identifier 353:21-22 H))
      (Return 353:25-76
        (Destructure 353:25-44
          (Identifier 353:25-39 _low_surrogate)
          (Identifier 353:43-44 L))
        (Function 353:47-76
          (Identifier 353:47-70 @SurrogatePairCodepoint) [
            (Identifier 353:71-72 H)
            (Identifier 353:74-75 L)
          ]))))
  
  (DeclareGlobal 355:0-71
    (Identifier 355:0-23 _invalid_surrogate_pair)
    (Return 355:26-71
      (Or 355:26-58
        (Identifier 355:26-40 _low_surrogate)
        (Identifier 355:43-58 _high_surrogate))
      (String 355:61-71 "\xef\xbf\xbd"))) (esc)
  
  (DeclareGlobal 357:0-104
    (Identifier 357:0-15 _high_surrogate)
    (Merge 358:2-86
      (Merge 358:2-72
        (Merge 358:2-58
          (TakeRight 358:2-20
            (String 358:2-6 "\u")
            (Or 358:9-20
              (String 358:10-13 "D")
              (String 358:16-19 "d")))
          (Or 358:23-58
            (String 358:24-27 "8")
            (Or 358:30-57
              (String 358:30-33 "9")
              (Or 358:36-57
                (String 358:36-39 "A")
                (Or 358:42-57
                  (String 358:42-45 "B")
                  (Or 358:48-57
                    (String 358:48-51 "a")
                    (String 358:54-57 "b")))))))
        (Identifier 358:61-72 hex_numeral))
      (Identifier 358:75-86 hex_numeral)))
  
  (DeclareGlobal 360:0-89
    (Identifier 360:0-14 _low_surrogate)
    (Merge 361:2-72
      (Merge 361:2-58
        (Merge 361:2-44
          (TakeRight 361:2-20
            (String 361:2-6 "\u")
            (Or 361:9-20
              (String 361:10-13 "D")
              (String 361:16-19 "d")))
          (Or 361:23-44
            (Range 361:24-32 (String 361:24-27 "C") (String 361:29-32 "F"))
            (Range 361:35-43 (String 361:35-38 "c") (String 361:40-43 "f"))))
        (Identifier 361:47-58 hex_numeral))
      (Identifier 361:61-72 hex_numeral)))
  
  (DeclareGlobal 363:0-66
    (Identifier 363:0-18 _escaped_codepoint)
    (Return 363:21-66
      (Destructure 363:21-50
        (TakeRight 363:21-45
          (String 363:21-25 "\u")
          (Repeat 363:28-45
            (Identifier 363:29-40 hex_numeral)
            (NumberString 363:43-44 4)))
        (Identifier 363:49-50 U))
      (Function 363:53-66
        (Identifier 363:53-63 @Codepoint) [
          (Identifier 363:64-65 U)
        ])))
  
  (DeclareGlobal 365:0-78
    (Function 365:0-16
      (Identifier 365:0-10 json.array) [
        (Identifier 365:11-15 elem)
      ])
    (TakeLeft 365:19-78
      (TakeRight 365:19-72
        (String 365:19-22 "[")
        (Function 365:25-72
          (Identifier 365:25-40 maybe_array_sep) [
            (Function 365:41-66
              (Identifier 365:41-49 surround) [
                (Identifier 365:50-54 elem)
                (Function 365:56-65
                  (Identifier 365:56-61 maybe) [
                    (Identifier 365:62-64 ws)
                  ])
              ])
            (String 365:68-71 ",")
          ]))
      (String 365:75-78 "]")))
  
  (DeclareGlobal 367:0-139
    (Function 367:0-18
      (Identifier 367:0-11 json.object) [
        (Identifier 367:12-17 value)
      ])
    (TakeLeft 368:2-118
      (TakeRight 368:2-110
        (String 368:2-5 "{")
        (Function 369:2-102
          (Identifier 369:2-18 maybe_object_sep) [
            (Function 370:4-36
              (Identifier 370:4-12 surround) [
                (Identifier 370:13-24 json.string)
                (Function 370:26-35
                  (Identifier 370:26-31 maybe) [
                    (Identifier 370:32-34 ws)
                  ])
              ])
            (String 370:38-41 ":")
            (Function 371:4-30
              (Identifier 371:4-12 surround) [
                (Identifier 371:13-18 value)
                (Function 371:20-29
                  (Identifier 371:20-25 maybe) [
                    (Identifier 371:26-28 ws)
                  ])
              ])
            (String 371:32-35 ",")
          ]))
      (String 373:4-7 "}")))
  
  (DeclareGlobal 377:0-18
    (Identifier 377:0-4 toml)
    (Identifier 377:7-18 toml.simple))
  
  (DeclareGlobal 379:0-44
    (Identifier 379:0-11 toml.simple)
    (Function 379:14-44
      (Identifier 379:14-25 toml.custom) [
        (Identifier 379:26-43 toml.simple_value)
      ]))
  
  (DeclareGlobal 381:0-44
    (Identifier 381:0-11 toml.tagged)
    (Function 381:14-44
      (Identifier 381:14-25 toml.custom) [
        (Identifier 381:26-43 toml.tagged_value)
      ]))
  
  (DeclareGlobal 383:0-188
    (Function 383:0-18
      (Identifier 383:0-11 toml.custom) [
        (Identifier 383:12-17 value)
      ])
    (TakeRight 384:2-167
      (TakeRight 384:2-104
        (Function 384:2-35
          (Identifier 384:2-7 maybe) [
            (Merge 384:8-34
              (Identifier 384:8-22 _toml.comments)
              (Function 384:25-34
                (Identifier 384:25-30 maybe) [
                  (Identifier 384:31-33 ws)
                ]))
          ])
        (Destructure 385:2-66
          (Or 385:2-59
            (Function 385:2-30
              (Identifier 385:2-23 _toml.with_root_table) [
                (Identifier 385:24-29 value)
              ])
            (Function 385:33-59
              (Identifier 385:33-52 _toml.no_root_table) [
                (Identifier 385:53-58 value)
              ]))
          (Identifier 385:63-66 Doc)))
      (Return 386:2-60
        (Function 386:2-35
          (Identifier 386:2-7 maybe) [
            (Merge 386:8-34
              (Function 386:8-17
                (Identifier 386:8-13 maybe) [
                  (Identifier 386:14-16 ws)
                ])
              (Identifier 386:20-34 _toml.comments))
          ])
        (Function 387:2-22
          (Identifier 387:2-17 _Toml.Doc.Value) [
            (Identifier 387:18-21 Doc)
          ]))))
  
  (DeclareGlobal 389:0-147
    (Function 389:0-28
      (Identifier 389:0-21 _toml.with_root_table) [
        (Identifier 389:22-27 value)
      ])
    (TakeRight 390:2-116
      (Destructure 390:2-53
        (Function 390:2-42
          (Identifier 390:2-18 _toml.root_table) [
            (Identifier 390:19-24 value)
            (Identifier 390:26-41 _Toml.Doc.Empty)
          ])
        (Identifier 390:46-53 RootDoc))
      (Or 391:2-60
        (TakeRight 391:2-43
          (Identifier 391:3-11 _toml.ws)
          (Function 391:14-42
            (Identifier 391:14-26 _toml.tables) [
              (Identifier 391:27-32 value)
              (Identifier 391:34-41 RootDoc)
            ]))
        (Function 391:46-60
          (Identifier 391:46-51 const) [
            (Identifier 391:52-59 RootDoc)
          ]))))
  
  (DeclareGlobal 393:0-65
    (Function 393:0-28
      (Identifier 393:0-16 _toml.root_table) [
        (Identifier 393:17-22 value)
        (Identifier 393:24-27 Doc)
      ])
    (Function 394:2-34
      (Identifier 394:2-18 _toml.table_body) [
        (Identifier 394:19-24 value)
        (Array 394:26-29 [])
        (Identifier 394:30-33 Doc)
      ]))
  
  (DeclareGlobal 396:0-156
    (Function 396:0-26
      (Identifier 396:0-19 _toml.no_root_table) [
        (Identifier 396:20-25 value)
      ])
    (TakeRight 397:2-127
      (Destructure 397:2-95
        (Or 397:2-85
          (Function 397:2-37
            (Identifier 397:2-13 _toml.table) [
              (Identifier 397:14-19 value)
              (Identifier 397:21-36 _Toml.Doc.Empty)
            ])
          (Function 397:40-85
            (Identifier 397:40-61 _toml.array_of_tables) [
              (Identifier 397:62-67 value)
              (Identifier 397:69-84 _Toml.Doc.Empty)
            ]))
        (Identifier 397:89-95 NewDoc))
      (Function 398:2-29
        (Identifier 398:2-14 _toml.tables) [
          (Identifier 398:15-20 value)
          (Identifier 398:22-28 NewDoc)
        ])))
  
  (DeclareGlobal 400:0-158
    (Function 400:0-24
      (Identifier 400:0-12 _toml.tables) [
        (Identifier 400:13-18 value)
        (Identifier 400:20-23 Doc)
      ])
    (Conditional 401:2-131
      (Destructure 401:2-84
        (Or 401:2-74
          (TakeRight 401:2-38
            (Identifier 401:2-10 _toml.ws)
            (Function 402:2-25
              (Identifier 402:2-13 _toml.table) [
                (Identifier 402:14-19 value)
                (Identifier 402:21-24 Doc)
              ]))
          (Function 402:28-61
            (Identifier 402:28-49 _toml.array_of_tables) [
              (Identifier 402:50-55 value)
              (Identifier 402:57-60 Doc)
            ]))
        (Identifier 402:65-71 NewDoc))
      (Function 403:2-29
        (Identifier 403:2-14 _toml.tables) [
          (Identifier 403:15-20 value)
          (Identifier 403:22-28 NewDoc)
        ])
      (Function 404:2-12
        (Identifier 404:2-7 const) [
          (Identifier 404:8-11 Doc)
        ])))
  
  (DeclareGlobal 406:0-190
    (Function 406:0-23
      (Identifier 406:0-11 _toml.table) [
        (Identifier 406:12-17 value)
        (Identifier 406:19-22 Doc)
      ])
    (TakeRight 407:2-164
      (TakeRight 407:2-53
        (Destructure 407:2-34
          (Identifier 407:2-20 _toml.table_header)
          (Identifier 407:24-34 HeaderPath))
        (Identifier 407:37-53 _toml.ws_newline))
      (Or 407:56-164
        (Function 408:4-44
          (Identifier 408:4-20 _toml.table_body) [
            (Identifier 408:21-26 value)
            (Identifier 408:28-38 HeaderPath)
            (Identifier 408:40-43 Doc)
          ])
        (Function 409:4-55
          (Identifier 409:4-9 const) [
            (Function 409:10-54
              (Identifier 409:10-37 _Toml.Doc.EnsureTableAtPath) [
                (Identifier 409:38-41 Doc)
                (Identifier 409:43-53 HeaderPath)
              ])
          ]))))
  
  (DeclareGlobal 412:0-257
    (Function 412:0-33
      (Identifier 412:0-21 _toml.array_of_tables) [
        (Identifier 412:22-27 value)
        (Identifier 412:29-32 Doc)
      ])
    (TakeRight 413:2-221
      (TakeRight 413:2-63
        (Destructure 413:2-44
          (Identifier 413:2-30 _toml.array_of_tables_header)
          (Identifier 413:34-44 HeaderPath))
        (Identifier 413:47-63 _toml.ws_newline))
      (Return 414:2-155
        (Destructure 414:2-84
          (Function 414:2-72
            (Identifier 414:2-9 default) [
              (Function 414:10-54
                (Identifier 414:10-26 _toml.table_body) [
                  (Identifier 414:27-32 value)
                  (Array 414:34-37 [])
                  (Identifier 414:38-53 _Toml.Doc.Empty)
                ])
              (Identifier 414:56-71 _Toml.Doc.Empty)
            ])
          (Identifier 414:76-84 InnerDoc))
        (Function 415:2-68
          (Identifier 415:2-24 _Toml.Doc.AppendAtPath) [
            (Identifier 415:25-28 Doc)
            (Identifier 415:30-40 HeaderPath)
            (Function 415:42-67
              (Identifier 415:42-57 _Toml.Doc.Value) [
                (Identifier 415:58-66 InnerDoc)
              ])
          ]))))
  
  (DeclareGlobal 417:0-41
    (Identifier 417:0-8 _toml.ws)
    (Function 417:11-41
      (Identifier 417:11-21 maybe_many) [
        (Or 417:22-40
          (Identifier 417:22-24 ws)
          (Identifier 417:27-40 _toml.comment))
      ]))
  
  (DeclareGlobal 419:0-50
    (Identifier 419:0-13 _toml.ws_line)
    (Function 419:16-50
      (Identifier 419:16-26 maybe_many) [
        (Or 419:27-49
          (Identifier 419:27-33 spaces)
          (Identifier 419:36-49 _toml.comment))
      ]))
  
  (DeclareGlobal 421:0-56
    (Identifier 421:0-16 _toml.ws_newline)
    (Merge 421:19-56
      (Merge 421:19-45
        (Identifier 421:19-32 _toml.ws_line)
        (Or 421:35-45
          (Identifier 421:36-38 nl)
          (Identifier 421:41-44 end)))
      (Identifier 421:48-56 _toml.ws)))
  
  (DeclareGlobal 423:0-44
    (Identifier 423:0-14 _toml.comments)
    (Function 423:17-44
      (Identifier 423:17-25 many_sep) [
        (Identifier 423:26-39 _toml.comment)
        (Identifier 423:41-43 ws)
      ]))
  
  (DeclareGlobal 425:0-64
    (Identifier 425:0-18 _toml.table_header)
    (TakeLeft 425:21-64
      (TakeRight 425:21-58
        (String 425:21-24 "[")
        (Function 425:27-58
          (Identifier 425:27-35 surround) [
            (Identifier 425:36-46 _toml.path)
            (Function 425:48-57
              (Identifier 425:48-53 maybe) [
                (Identifier 425:54-56 ws)
              ])
          ]))
      (String 425:61-64 "]")))
  
  (DeclareGlobal 427:0-78
    (Identifier 427:0-28 _toml.array_of_tables_header)
    (TakeLeft 428:2-47
      (TakeRight 428:2-40
        (String 428:2-6 "[[")
        (Function 428:9-40
          (Identifier 428:9-17 surround) [
            (Identifier 428:18-28 _toml.path)
            (Function 428:30-39
              (Identifier 428:30-35 maybe) [
                (Identifier 428:36-38 ws)
              ])
          ]))
      (String 428:43-47 "]]")))
  
  (DeclareGlobal 430:0-245
    (Function 430:0-40
      (Identifier 430:0-16 _toml.table_body) [
        (Identifier 430:17-22 value)
        (Identifier 430:24-34 HeaderPath)
        (Identifier 430:36-39 Doc)
      ])
    (TakeRight 431:2-202
      (TakeRight 431:2-138
        (TakeRight 431:2-62
          (Destructure 431:2-43
            (Function 431:2-25
              (Identifier 431:2-18 _toml.table_pair) [
                (Identifier 431:19-24 value)
              ])
            (Array 431:29-43 [
              (Identifier 431:30-37 KeyPath)
              (Identifier 431:39-42 Val)
            ]))
          (Identifier 431:46-62 _toml.ws_newline))
        (Destructure 432:2-73
          (Function 432:2-63
            (Identifier 432:2-7 const) [
              (Function 432:8-62
                (Identifier 432:8-30 _Toml.Doc.InsertAtPath) [
                  (Identifier 432:31-34 Doc)
                  (Merge 432:36-56
                    (Identifier 432:36-46 HeaderPath)
                    (Identifier 432:49-56 KeyPath))
                  (Identifier 432:58-61 Val)
                ])
            ])
          (Identifier 432:67-73 NewDoc)))
      (Or 433:2-61
        (Function 433:2-45
          (Identifier 433:2-18 _toml.table_body) [
            (Identifier 433:19-24 value)
            (Identifier 433:26-36 HeaderPath)
            (Identifier 433:38-44 NewDoc)
          ])
        (Function 433:48-61
          (Identifier 433:48-53 const) [
            (Identifier 433:54-60 NewDoc)
          ]))))
  
  (DeclareGlobal 435:0-87
    (Function 435:0-23
      (Identifier 435:0-16 _toml.table_pair) [
        (Identifier 435:17-22 value)
      ])
    (Function 436:2-61
      (Identifier 436:2-12 tuple2_sep) [
        (Identifier 436:13-23 _toml.path)
        (Function 436:25-53
          (Identifier 436:25-33 surround) [
            (String 436:34-37 "=")
            (Function 436:39-52
              (Identifier 436:39-44 maybe) [
                (Identifier 436:45-51 spaces)
              ])
          ])
        (Identifier 436:55-60 value)
      ]))
  
  (DeclareGlobal 438:0-59
    (Identifier 438:0-10 _toml.path)
    (Function 438:13-59
      (Identifier 438:13-22 array_sep) [
        (Identifier 438:23-32 _toml.key)
        (Function 438:34-58
          (Identifier 438:34-42 surround) [
            (String 438:43-46 ".")
            (Function 438:48-57
              (Identifier 438:48-53 maybe) [
                (Identifier 438:54-56 ws)
              ])
          ])
      ]))
  
  (DeclareGlobal 440:0-93
    (Identifier 440:0-9 _toml.key)
    (Or 441:2-81
      (Function 441:2-35
        (Identifier 441:2-6 many) [
          (Or 441:7-34
            (Identifier 441:7-12 alpha)
            (Or 441:15-34
              (Identifier 441:15-22 numeral)
              (Or 441:25-34
                (String 441:25-28 "_")
                (String 441:31-34 "-"))))
        ])
      (Or 442:2-43
        (Identifier 442:2-19 toml.string.basic)
        (Identifier 443:2-21 toml.string.literal))))
  
  (DeclareGlobal 445:0-33
    (Identifier 445:0-13 _toml.comment)
    (TakeRight 445:16-33
      (String 445:16-19 "#")
      (Function 445:22-33
        (Identifier 445:22-27 maybe) [
          (Identifier 445:28-32 line)
        ])))
  
  (DeclareGlobal 447:0-159
    (Identifier 447:0-17 toml.simple_value)
    (Or 448:2-139
      (Identifier 448:2-13 toml.string)
      (Or 449:2-123
        (Identifier 449:2-15 toml.datetime)
        (Or 450:2-105
          (Identifier 450:2-13 toml.number)
          (Or 451:2-89
            (Identifier 451:2-14 toml.boolean)
            (Or 452:2-72
              (Function 452:2-31
                (Identifier 452:2-12 toml.array) [
                  (Identifier 452:13-30 toml.simple_value)
                ])
              (Function 453:2-38
                (Identifier 453:2-19 toml.inline_table) [
                  (Identifier 453:20-37 toml.simple_value)
                ])))))))
  
  (DeclareGlobal 455:0-640
    (Identifier 455:0-17 toml.tagged_value)
    (Or 456:2-620
      (Identifier 456:2-13 toml.string)
      (Or 457:2-604
        (Function 457:2-57
          (Identifier 457:2-11 _toml.tag) [
            (ValueLabel 457:12-13 (String 457:13-23 "datetime"))
            (ValueLabel 457:25-26 (String 457:26-34 "offset"))
            (Identifier 457:36-56 toml.datetime.offset)
          ])
        (Or 458:2-544
          (Function 458:2-55
            (Identifier 458:2-11 _toml.tag) [
              (ValueLabel 458:12-13 (String 458:13-23 "datetime"))
              (ValueLabel 458:25-26 (String 458:26-33 "local"))
              (Identifier 458:35-54 toml.datetime.local)
            ])
          (Or 459:2-486
            (Function 459:2-65
              (Identifier 459:2-11 _toml.tag) [
                (ValueLabel 459:12-13 (String 459:13-23 "datetime"))
                (ValueLabel 459:25-26 (String 459:26-38 "date-local"))
                (Identifier 459:40-64 toml.datetime.local_date)
              ])
            (Or 460:2-418
              (Function 460:2-65
                (Identifier 460:2-11 _toml.tag) [
                  (ValueLabel 460:12-13 (String 460:13-23 "datetime"))
                  (ValueLabel 460:25-26 (String 460:26-38 "time-local"))
                  (Identifier 460:40-64 toml.datetime.local_time)
                ])
              (Or 461:2-350
                (Identifier 461:2-28 toml.number.binary_integer)
                (Or 462:2-319
                  (Identifier 462:2-27 toml.number.octal_integer)
                  (Or 463:2-289
                    (Identifier 463:2-25 toml.number.hex_integer)
                    (Or 464:2-261
                      (Function 464:2-56
                        (Identifier 464:2-11 _toml.tag) [
                          (ValueLabel 464:12-13 (String 464:13-20 "float"))
                          (ValueLabel 464:22-23 (String 464:23-33 "infinity"))
                          (Identifier 464:35-55 toml.number.infinity)
                        ])
                      (Or 465:2-202
                        (Function 465:2-64
                          (Identifier 465:2-11 _toml.tag) [
                            (ValueLabel 465:12-13 (String 465:13-20 "float"))
                            (ValueLabel 465:22-23 (String 465:23-37 "not-a-number"))
                            (Identifier 465:39-63 toml.number.not_a_number)
                          ])
                        (Or 466:2-135
                          (Identifier 466:2-19 toml.number.float)
                          (Or 467:2-113
                            (Identifier 467:2-21 toml.number.integer)
                            (Or 468:2-89
                              (Identifier 468:2-14 toml.boolean)
                              (Or 469:2-72
                                (Function 469:2-31
                                  (Identifier 469:2-12 toml.array) [
                                    (Identifier 469:13-30 toml.tagged_value)
                                  ])
                                (Function 470:2-38
                                  (Identifier 470:2-19 toml.inline_table) [
                                    (Identifier 470:20-37 toml.tagged_value)
                                  ]))))))))))))))))
  
  (DeclareGlobal 472:0-103
    (Function 472:0-31
      (Identifier 472:0-9 _toml.tag) [
        (Identifier 472:10-14 Type)
        (Identifier 472:16-23 Subtype)
        (Identifier 472:25-30 value)
      ])
    (Return 473:2-69
      (Destructure 473:2-16
        (Identifier 473:2-7 value)
        (Identifier 473:11-16 Value))
      (Object 473:19-69 [
        (ObjectPair (String 473:20-26 "type") (Identifier 473:28-32 Type))
        (ObjectPair (String 473:34-43 "subtype") (Identifier 473:45-52 Subtype))
        (ObjectPair (String 473:54-61 "value") (Identifier 473:63-68 Value))
      ])))
  
  (DeclareGlobal 475:0-125
    (Identifier 475:0-11 toml.string)
    (Or 476:2-111
      (Identifier 476:2-30 toml.string.multi_line_basic)
      (Or 477:2-78
        (Identifier 477:2-32 toml.string.multi_line_literal)
        (Or 478:2-43
          (Identifier 478:2-19 toml.string.basic)
          (Identifier 479:2-21 toml.string.literal)))))
  
  (DeclareGlobal 481:0-120
    (Identifier 481:0-13 toml.datetime)
    (Or 482:2-104
      (Identifier 482:2-22 toml.datetime.offset)
      (Or 483:2-79
        (Identifier 483:2-21 toml.datetime.local)
        (Or 484:2-55
          (Identifier 484:2-26 toml.datetime.local_date)
          (Identifier 485:2-26 toml.datetime.local_time)))))
  
  (DeclareGlobal 487:0-200
    (Identifier 487:0-11 toml.number)
    (Or 488:2-186
      (Identifier 488:2-28 toml.number.binary_integer)
      (Or 489:2-155
        (Identifier 489:2-27 toml.number.octal_integer)
        (Or 490:2-125
          (Identifier 490:2-25 toml.number.hex_integer)
          (Or 491:2-97
            (Identifier 491:2-22 toml.number.infinity)
            (Or 492:2-72
              (Identifier 492:2-26 toml.number.not_a_number)
              (Or 493:2-43
                (Identifier 493:2-19 toml.number.float)
                (Identifier 494:2-21 toml.number.integer))))))))
  
  (DeclareGlobal 496:0-39
    (Identifier 496:0-12 toml.boolean)
    (Function 496:15-39
      (Identifier 496:15-22 boolean) [
        (String 496:23-29 "true")
        (String 496:31-38 "false")
      ]))
  
  (DeclareGlobal 498:0-153
    (Function 498:0-16
      (Identifier 498:0-10 toml.array) [
        (Identifier 498:11-15 elem)
      ])
    (TakeLeft 499:2-134
      (TakeLeft 499:2-128
        (TakeRight 499:2-117
          (TakeRight 499:2-16
            (String 499:2-5 "[")
            (Identifier 499:8-16 _toml.ws))
          (Function 499:19-117
            (Identifier 499:19-26 default) [
              (TakeLeft 500:4-77
                (Function 500:4-44
                  (Identifier 500:4-13 array_sep) [
                    (Function 500:14-38
                      (Identifier 500:14-22 surround) [
                        (Identifier 500:23-27 elem)
                        (Identifier 500:29-37 _toml.ws)
                      ])
                    (String 500:40-43 ",")
                  ])
                (Function 500:47-77
                  (Identifier 500:47-52 maybe) [
                    (Function 500:53-76
                      (Identifier 500:53-61 surround) [
                        (String 500:62-65 ",")
                        (Identifier 500:67-75 _toml.ws)
                      ])
                  ]))
              (Array 501:4-10 [])
            ]))
        (Identifier 502:6-14 _toml.ws))
      (String 502:17-20 "]")))
  
  (DeclareGlobal 504:0-134
    (Function 504:0-24
      (Identifier 504:0-17 toml.inline_table) [
        (Identifier 504:18-23 value)
      ])
    (Return 505:2-107
      (Destructure 505:2-76
        (Or 505:2-63
          (Identifier 505:2-26 _toml.empty_inline_table)
          (Function 505:29-63
            (Identifier 505:29-56 _toml.nonempty_inline_table) [
              (Identifier 505:57-62 value)
            ]))
        (Identifier 505:67-76 InlineDoc))
      (Function 506:2-28
        (Identifier 506:2-17 _Toml.Doc.Value) [
          (Identifier 506:18-27 InlineDoc)
        ])))
  
  (DeclareGlobal 508:0-70
    (Identifier 508:0-24 _toml.empty_inline_table)
    (Return 508:27-70
      (TakeLeft 508:27-52
        (TakeRight 508:27-46
          (String 508:27-30 "{")
          (Function 508:33-46
            (Identifier 508:33-38 maybe) [
              (Identifier 508:39-45 spaces)
            ]))
        (String 508:49-52 "}"))
      (Identifier 508:55-70 _Toml.Doc.Empty)))
  
  (DeclareGlobal 510:0-207
    (Function 510:0-34
      (Identifier 510:0-27 _toml.nonempty_inline_table) [
        (Identifier 510:28-33 value)
      ])
    (TakeRight 511:2-170
      (Destructure 511:2-93
        (TakeRight 511:2-73
          (TakeRight 511:2-21
            (String 511:2-5 "{")
            (Function 511:8-21
              (Identifier 511:8-13 maybe) [
                (Identifier 511:14-20 spaces)
              ]))
          (Function 512:2-49
            (Identifier 512:2-25 _toml.inline_table_pair) [
              (Identifier 512:26-31 value)
              (Identifier 512:33-48 _Toml.Doc.Empty)
            ]))
        (Identifier 512:53-69 DocWithFirstPair))
      (TakeLeft 513:2-74
        (TakeLeft 513:2-68
          (Function 513:2-50
            (Identifier 513:2-25 _toml.inline_table_body) [
              (Identifier 513:26-31 value)
              (Identifier 513:33-49 DocWithFirstPair)
            ])
          (Function 514:4-17
            (Identifier 514:4-9 maybe) [
              (Identifier 514:10-16 spaces)
            ]))
        (String 514:20-23 "}"))))
  
  (DeclareGlobal 516:0-149
    (Function 516:0-35
      (Identifier 516:0-23 _toml.inline_table_body) [
        (Identifier 516:24-29 value)
        (Identifier 516:31-34 Doc)
      ])
    (Conditional 517:2-111
      (Destructure 517:2-53
        (TakeRight 517:2-43
          (String 517:2-5 ",")
          (Function 517:8-43
            (Identifier 517:8-31 _toml.inline_table_pair) [
              (Identifier 517:32-37 value)
              (Identifier 517:39-42 Doc)
            ]))
        (Identifier 517:47-53 NewDoc))
      (Function 518:2-40
        (Identifier 518:2-25 _toml.inline_table_body) [
          (Identifier 518:26-31 value)
          (Identifier 518:33-39 NewDoc)
        ])
      (Function 519:2-12
        (Identifier 519:2-7 const) [
          (Identifier 519:8-11 Doc)
        ])))
  
  (DeclareGlobal 521:0-192
    (Function 521:0-35
      (Identifier 521:0-23 _toml.inline_table_pair) [
        (Identifier 521:24-29 value)
        (Identifier 521:31-34 Doc)
      ])
    (TakeRight 522:2-154
      (TakeRight 522:2-94
        (TakeRight 522:2-77
          (TakeRight 522:2-61
            (TakeRight 522:2-55
              (TakeRight 522:2-37
                (Function 522:2-15
                  (Identifier 522:2-7 maybe) [
                    (Identifier 522:8-14 spaces)
                  ])
                (Destructure 523:2-19
                  (Identifier 523:2-12 _toml.path)
                  (Identifier 523:16-19 Key)))
              (Function 524:2-15
                (Identifier 524:2-7 maybe) [
                  (Identifier 524:8-14 spaces)
                ]))
            (String 524:18-21 "="))
          (Function 524:24-37
            (Identifier 524:24-29 maybe) [
              (Identifier 524:30-36 spaces)
            ]))
        (Destructure 525:2-14
          (Identifier 525:2-7 value)
          (Identifier 525:11-14 Val)))
      (Return 526:2-57
        (Function 526:2-15
          (Identifier 526:2-7 maybe) [
            (Identifier 526:8-14 spaces)
          ])
        (Function 527:2-39
          (Identifier 527:2-24 _Toml.Doc.InsertAtPath) [
            (Identifier 527:25-28 Doc)
            (Identifier 527:30-33 Key)
            (Identifier 527:35-38 Val)
          ]))))
  
  (DeclareGlobal 529:0-85
    (Identifier 529:0-28 toml.string.multi_line_basic)
    (TakeRight 529:31-85
      (TakeRight 529:31-48
        (String 529:31-36 """"")
        (Function 529:39-48
          (Identifier 529:39-44 maybe) [
            (Identifier 529:45-47 nl)
          ]))
      (Function 529:51-85
        (Identifier 529:51-80 _toml.string.multi_line_basic) [
          (ValueLabel 529:81-82 (String 529:82-84 ""))
        ])))
  
  (DeclareGlobal 531:0-292
    (Function 531:0-34
      (Identifier 531:0-29 _toml.string.multi_line_basic) [
        (Identifier 531:30-33 Acc)
      ])
    (Or 532:2-255
      (Return 532:2-26
        (String 532:3-10 """"""")
        (Merge 532:13-25
          (Identifier 532:14-17 Acc)
          (String 532:20-24 """")))
      (Or 533:2-226
        (Return 533:2-24
          (String 533:3-9 """""")
          (Merge 533:12-23
            (Identifier 533:13-16 Acc)
            (String 533:19-22 """)))
        (Or 534:2-199
          (Return 534:2-15
            (String 534:3-8 """"")
            (Identifier 534:11-14 Acc))
          (TakeRight 535:2-181
            (Destructure 536:4-128
              (Or 536:4-123
                (Identifier 536:4-27 _toml.escaped_ctrl_char)
                (Or 537:4-93
                  (Identifier 537:4-25 _toml.escaped_unicode)
                  (Or 538:4-65
                    (Identifier 538:4-6 ws)
                    (Or 539:4-56
                      (TakeRight 539:4-19
                        (Merge 539:5-13
                          (String 539:5-8 "\")
                          (Identifier 539:11-13 ws))
                        (String 539:16-18 ""))
                      (Function 540:4-34
                        (Identifier 540:4-10 unless) [
                          (Identifier 540:11-15 char)
                          (Or 540:17-33
                            (Identifier 540:17-27 _ctrl_char)
                            (String 540:30-33 "\"))
                        ])))))
              (Identifier 540:38-39 C))
            (Function 541:4-42
              (Identifier 541:4-33 _toml.string.multi_line_basic) [
                (Merge 541:34-41
                  (Identifier 541:34-37 Acc)
                  (Identifier 541:40-41 C))
              ]))))))
  
  (DeclareGlobal 544:0-89
    (Identifier 544:0-30 toml.string.multi_line_literal)
    (TakeRight 544:33-89
      (TakeRight 544:33-50
        (String 544:33-38 "'''")
        (Function 544:41-50
          (Identifier 544:41-46 maybe) [
            (Identifier 544:47-49 nl)
          ]))
      (Function 544:53-89
        (Identifier 544:53-84 _toml.string.multi_line_literal) [
          (ValueLabel 544:85-86 (String 544:86-88 ""))
        ])))
  
  (DeclareGlobal 546:0-169
    (Function 546:0-36
      (Identifier 546:0-31 _toml.string.multi_line_literal) [
        (Identifier 546:32-35 Acc)
      ])
    (Or 547:2-130
      (Return 547:2-26
        (String 547:3-10 "'''''")
        (Merge 547:13-25
          (Identifier 547:14-17 Acc)
          (String 547:20-24 "''")))
      (Or 548:2-101
        (Return 548:2-24
          (String 548:3-9 "''''")
          (Merge 548:12-23
            (Identifier 548:13-16 Acc)
            (String 548:19-22 "'")))
        (Or 549:2-74
          (Return 549:2-15
            (String 549:3-8 "'''")
            (Identifier 549:11-14 Acc))
          (TakeRight 550:2-56
            (Destructure 550:3-12
              (Identifier 550:3-7 char)
              (Identifier 550:11-12 C))
            (Function 550:15-55
              (Identifier 550:15-46 _toml.string.multi_line_literal) [
                (Merge 550:47-54
                  (Identifier 550:47-50 Acc)
                  (Identifier 550:53-54 C))
              ]))))))
  
  (DeclareGlobal 552:0-55
    (Identifier 552:0-17 toml.string.basic)
    (TakeLeft 552:20-55
      (TakeRight 552:20-49
        (String 552:20-23 """)
        (Identifier 552:26-49 _toml.string.basic_body))
      (String 552:52-55 """)))
  
  (DeclareGlobal 554:0-149
    (Identifier 554:0-23 _toml.string.basic_body)
    (Or 555:2-123
      (Function 555:2-110
        (Identifier 555:2-6 many) [
          (Or 556:4-98
            (Identifier 556:4-27 _toml.escaped_ctrl_char)
            (Or 557:4-68
              (Identifier 557:4-25 _toml.escaped_unicode)
              (Function 558:4-40
                (Identifier 558:4-10 unless) [
                  (Identifier 558:11-15 char)
                  (Or 558:17-39
                    (Identifier 558:17-27 _ctrl_char)
                    (Or 558:30-39
                      (String 558:30-33 "\")
                      (String 558:36-39 """)))
                ])))
        ])
      (Function 559:6-16
        (Identifier 559:6-11 const) [
          (ValueLabel 559:12-13 (String 559:13-15 ""))
        ])))
  
  (DeclareGlobal 561:0-64
    (Identifier 561:0-19 toml.string.literal)
    (TakeLeft 561:22-64
      (TakeRight 561:22-58
        (String 561:22-25 "'")
        (Function 561:28-58
          (Identifier 561:28-35 default) [
            (Function 561:36-52
              (Identifier 561:36-47 chars_until) [
                (String 561:48-51 "'")
              ])
            (ValueLabel 561:54-55 (String 561:55-57 ""))
          ]))
      (String 561:61-64 "'")))
  
  (DeclareGlobal 563:0-147
    (Identifier 563:0-23 _toml.escaped_ctrl_char)
    (Or 564:2-121
      (Return 564:2-14
        (String 564:3-7 "\"")
        (String 564:10-13 """))
      (Or 565:2-104
        (Return 565:2-14
          (String 565:3-7 "\\")
          (String 565:10-13 "\"))
        (Or 566:2-87
          (Return 566:2-15
            (String 566:3-7 "\b")
            (String 566:10-14 "\x08")) (esc)
          (Or 567:2-69
            (Return 567:2-15
              (String 567:3-7 "\f")
              (String 567:10-14 "\x0c")) (esc)
            (Or 568:2-51
              (Return 568:2-15
                (String 568:3-7 "\n")
                (String 568:10-14 "
  "))
              (Or 569:2-33
                (Return 569:2-15
                  (String 569:3-7 "\r")
                  (String 569:10-14 "\r (no-eol) (esc)
  "))
                (Return 570:2-15
                  (String 570:3-7 "\t")
                  (String 570:10-14 "\t"))))))))) (esc)
  
  (DeclareGlobal 572:0-125
    (Identifier 572:0-21 _toml.escaped_unicode)
    (Or 573:2-101
      (Return 573:2-49
        (Destructure 573:3-32
          (TakeRight 573:3-27
            (String 573:3-7 "\u")
            (Repeat 573:10-27
              (Identifier 573:11-22 hex_numeral)
              (NumberString 573:25-26 4)))
          (Identifier 573:31-32 U))
        (Function 573:35-48
          (Identifier 573:35-45 @Codepoint) [
            (Identifier 573:46-47 U)
          ]))
      (Return 574:2-49
        (Destructure 574:3-32
          (TakeRight 574:3-27
            (String 574:3-7 "\U")
            (Repeat 574:10-27
              (Identifier 574:11-22 hex_numeral)
              (NumberString 574:25-26 8)))
          (Identifier 574:31-32 U))
        (Function 574:35-48
          (Identifier 574:35-45 @Codepoint) [
            (Identifier 574:46-47 U)
          ]))))
  
  (DeclareGlobal 576:0-96
    (Identifier 576:0-20 toml.datetime.offset)
    (Merge 576:23-96
      (Merge 576:23-67
        (Identifier 576:23-47 toml.datetime.local_date)
        (Or 576:50-67
          (String 576:51-54 "T")
          (Or 576:57-66
            (String 576:57-60 "t")
            (String 576:63-66 " "))))
      (Identifier 576:70-96 _toml.datetime.time_offset)))
  
  (DeclareGlobal 578:0-93
    (Identifier 578:0-19 toml.datetime.local)
    (Merge 578:22-93
      (Merge 578:22-66
        (Identifier 578:22-46 toml.datetime.local_date)
        (Or 578:49-66
          (String 578:50-53 "T")
          (Or 578:56-65
            (String 578:56-59 "t")
            (String 578:62-65 " "))))
      (Identifier 578:69-93 toml.datetime.local_time)))
  
  (DeclareGlobal 580:0-105
    (Identifier 580:0-24 toml.datetime.local_date)
    (Merge 581:2-78
      (Merge 581:2-56
        (Merge 581:2-50
          (Merge 581:2-27
            (Identifier 581:2-21 _toml.datetime.year)
            (String 581:24-27 "-"))
          (Identifier 581:30-50 _toml.datetime.month))
        (String 581:53-56 "-"))
      (Identifier 581:59-78 _toml.datetime.mday)))
  
  (DeclareGlobal 583:0-33
    (Identifier 583:0-19 _toml.datetime.year)
    (Repeat 583:22-33
      (Identifier 583:22-29 numeral)
      (NumberString 583:32-33 4)))
  
  (DeclareGlobal 585:0-53
    (Identifier 585:0-20 _toml.datetime.month)
    (Or 585:23-53
      (Merge 585:23-39
        (String 585:24-27 "0")
        (Range 585:30-38 (String 585:30-33 "1") (String 585:35-38 "9")))
      (Or 585:42-53
        (String 585:42-46 "11")
        (String 585:49-53 "12"))))
  
  (DeclareGlobal 587:0-57
    (Identifier 587:0-19 _toml.datetime.mday)
    (Or 587:22-57
      (Merge 587:22-43
        (Range 587:23-31 (String 587:23-26 "0") (String 587:28-31 "2"))
        (Range 587:34-42 (String 587:34-37 "1") (String 587:39-42 "9")))
      (Or 587:46-57
        (String 587:46-50 "30")
        (String 587:53-57 "31"))))
  
  (DeclareGlobal 589:0-149
    (Identifier 589:0-24 toml.datetime.local_time)
    (Merge 590:2-122
      (Merge 590:2-88
        (Merge 590:2-61
          (Merge 590:2-55
            (Merge 590:2-28
              (Identifier 590:2-22 _toml.datetime.hours)
              (String 590:25-28 ":"))
            (Identifier 591:2-24 _toml.datetime.minutes))
          (String 591:27-30 ":"))
        (Identifier 592:2-24 _toml.datetime.seconds))
      (Function 593:2-31
        (Identifier 593:2-7 maybe) [
          (Merge 593:8-30
            (String 593:8-11 ".")
            (Repeat 593:14-30
              (Identifier 593:15-22 numeral)
              (Range 593:25-29 (NumberString 593:25-26 1) (NumberString 593:28-29 9))))
        ])))
  
  (DeclareGlobal 595:0-99
    (Identifier 595:0-26 _toml.datetime.time_offset)
    (Merge 595:29-99
      (Identifier 595:29-53 toml.datetime.local_time)
      (Or 595:56-99
        (String 595:57-60 "Z")
        (Or 595:63-98
          (String 595:63-66 "z")
          (Identifier 595:69-98 _toml.datetime.time_numoffset)))))
  
  (DeclareGlobal 597:0-97
    (Identifier 597:0-29 _toml.datetime.time_numoffset)
    (Merge 597:32-97
      (Merge 597:32-72
        (Merge 597:32-66
          (Or 597:32-43
            (String 597:33-36 "+")
            (String 597:39-42 "-"))
          (Identifier 597:46-66 _toml.datetime.hours))
        (String 597:69-72 ":"))
      (Identifier 597:75-97 _toml.datetime.minutes)))
  
  (DeclareGlobal 599:0-63
    (Identifier 599:0-20 _toml.datetime.hours)
    (Or 599:23-63
      (Merge 599:23-44
        (Range 599:24-32 (String 599:24-27 "0") (String 599:29-32 "1"))
        (Range 599:35-43 (String 599:35-38 "0") (String 599:40-43 "9")))
      (Merge 599:47-63
        (String 599:48-51 "2")
        (Range 599:54-62 (String 599:54-57 "0") (String 599:59-62 "3")))))
  
  (DeclareGlobal 601:0-44
    (Identifier 601:0-22 _toml.datetime.minutes)
    (Merge 601:25-44
      (Range 601:25-33 (String 601:25-28 "0") (String 601:30-33 "5"))
      (Range 601:36-44 (String 601:36-39 "0") (String 601:41-44 "9"))))
  
  (DeclareGlobal 603:0-53
    (Identifier 603:0-22 _toml.datetime.seconds)
    (Or 603:25-53
      (Merge 603:25-46
        (Range 603:26-34 (String 603:26-29 "0") (String 603:31-34 "5"))
        (Range 603:37-45 (String 603:37-40 "0") (String 603:42-45 "9")))
      (String 603:49-53 "60")))
  
  (DeclareGlobal 605:0-84
    (Identifier 605:0-19 toml.number.integer)
    (Function 605:22-84
      (Identifier 605:22-31 as_number) [
        (Merge 606:2-49
          (Identifier 606:2-19 _toml.number.sign)
          (Identifier 607:2-27 _toml.number.integer_part))
      ]))
  
  (DeclareGlobal 610:0-42
    (Identifier 610:0-17 _toml.number.sign)
    (Function 610:20-42
      (Identifier 610:20-25 maybe) [
        (Or 610:26-41
          (String 610:26-29 "-")
          (Function 610:32-41
            (Identifier 610:32-36 skip) [
              (String 610:37-40 "+")
            ]))
      ]))
  
  (DeclareGlobal 612:0-79
    (Identifier 612:0-25 _toml.number.integer_part)
    (Or 613:2-51
      (Merge 613:2-41
        (Range 613:3-11 (String 613:3-6 "1") (String 613:8-11 "9"))
        (Function 613:14-40
          (Identifier 613:14-18 many) [
            (TakeRight 613:19-39
              (Function 613:19-29
                (Identifier 613:19-24 maybe) [
                  (String 613:25-28 "_")
                ])
              (Identifier 613:32-39 numeral))
          ]))
      (Identifier 613:44-51 numeral)))
  
  (DeclareGlobal 615:0-192
    (Identifier 615:0-17 toml.number.float)
    (Function 615:20-192
      (Identifier 615:20-29 as_number) [
        (Merge 616:2-159
          (Merge 616:2-49
            (Identifier 616:2-19 _toml.number.sign)
            (Identifier 617:2-27 _toml.number.integer_part))
          (Or 617:30-137
            (Merge 618:4-68
              (Identifier 618:5-31 _toml.number.fraction_part)
              (Function 618:34-67
                (Identifier 618:34-39 maybe) [
                  (Identifier 618:40-66 _toml.number.exponent_part)
                ]))
            (Identifier 619:4-30 _toml.number.exponent_part)))
      ]))
  
  (DeclareGlobal 623:0-65
    (Identifier 623:0-26 _toml.number.fraction_part)
    (Merge 623:29-65
      (String 623:29-32 ".")
      (Function 623:35-65
        (Identifier 623:35-43 many_sep) [
          (Identifier 623:44-52 numerals)
          (Function 623:54-64
            (Identifier 623:54-59 maybe) [
              (String 623:60-63 "_")
            ])
        ])))
  
  (DeclareGlobal 625:0-94
    (Identifier 625:0-26 _toml.number.exponent_part)
    (Merge 626:2-65
      (Merge 626:2-32
        (Or 626:2-13
          (String 626:3-6 "e")
          (String 626:9-12 "E"))
        (Function 626:16-32
          (Identifier 626:16-21 maybe) [
            (Or 626:22-31
              (String 626:22-25 "-")
              (String 626:28-31 "+"))
          ]))
      (Function 626:35-65
        (Identifier 626:35-43 many_sep) [
          (Identifier 626:44-52 numerals)
          (Function 626:54-64
            (Identifier 626:54-59 maybe) [
              (String 626:60-63 "_")
            ])
        ])))
  
  (DeclareGlobal 628:0-47
    (Identifier 628:0-20 toml.number.infinity)
    (Merge 628:23-47
      (Function 628:23-39
        (Identifier 628:23-28 maybe) [
          (Or 628:29-38
            (String 628:29-32 "+")
            (String 628:35-38 "-"))
        ])
      (String 628:42-47 "inf")))
  
  (DeclareGlobal 630:0-51
    (Identifier 630:0-24 toml.number.not_a_number)
    (Merge 630:27-51
      (Function 630:27-43
        (Identifier 630:27-32 maybe) [
          (Or 630:33-42
            (String 630:33-36 "+")
            (String 630:39-42 "-"))
        ])
      (String 630:46-51 "nan")))
  
  (DeclareGlobal 632:0-209
    (Identifier 632:0-26 toml.number.binary_integer)
    (TakeRight 633:2-180
      (String 633:2-6 "0b")
      (Return 633:9-180
        (Destructure 633:9-147
          (Function 633:9-137
            (Identifier 633:9-20 one_or_both) [
              (Merge 634:4-70
                (Function 634:4-28
                  (Identifier 634:4-13 array_sep) [
                    (NumberString 634:14-15 0)
                    (Function 634:17-27
                      (Identifier 634:17-22 maybe) [
                        (String 634:23-26 "_")
                      ])
                  ])
                (Function 634:31-70
                  (Identifier 634:31-36 maybe) [
                    (TakeLeft 634:37-69
                      (Function 634:37-46
                        (Identifier 634:37-41 skip) [
                          (String 634:42-45 "_")
                        ])
                      (Function 634:49-69
                        (Identifier 634:49-53 peek) [
                          (Identifier 634:54-68 binary_numeral)
                        ]))
                  ]))
              (Function 635:4-39
                (Identifier 635:4-13 array_sep) [
                  (Identifier 635:14-26 binary_digit)
                  (Function 635:28-38
                    (Identifier 635:28-33 maybe) [
                      (String 635:34-37 "_")
                    ])
                ])
            ])
          (Identifier 636:7-13 Digits))
        (Function 637:2-30
          (Identifier 637:2-22 Num.FromBinaryDigits) [
            (Identifier 637:23-29 Digits)
          ]))))
  
  (DeclareGlobal 639:0-205
    (Identifier 639:0-25 toml.number.octal_integer)
    (TakeRight 640:2-177
      (String 640:2-6 "0o")
      (Return 640:9-177
        (Destructure 640:9-145
          (Function 640:9-135
            (Identifier 640:9-20 one_or_both) [
              (Merge 641:4-69
                (Function 641:4-28
                  (Identifier 641:4-13 array_sep) [
                    (NumberString 641:14-15 0)
                    (Function 641:17-27
                      (Identifier 641:17-22 maybe) [
                        (String 641:23-26 "_")
                      ])
                  ])
                (Function 641:31-69
                  (Identifier 641:31-36 maybe) [
                    (TakeLeft 641:37-68
                      (Function 641:37-46
                        (Identifier 641:37-41 skip) [
                          (String 641:42-45 "_")
                        ])
                      (Function 641:49-68
                        (Identifier 641:49-53 peek) [
                          (Identifier 641:54-67 octal_numeral)
                        ]))
                  ]))
              (Function 642:4-38
                (Identifier 642:4-13 array_sep) [
                  (Identifier 642:14-25 octal_digit)
                  (Function 642:27-37
                    (Identifier 642:27-32 maybe) [
                      (String 642:33-36 "_")
                    ])
                ])
            ])
          (Identifier 643:7-13 Digits))
        (Function 644:2-29
          (Identifier 644:2-21 Num.FromOctalDigits) [
            (Identifier 644:22-28 Digits)
          ]))))
  
  (DeclareGlobal 646:0-197
    (Identifier 646:0-23 toml.number.hex_integer)
    (TakeRight 647:2-171
      (String 647:2-6 "0x")
      (Return 647:9-171
        (Destructure 647:9-141
          (Function 647:9-131
            (Identifier 647:9-20 one_or_both) [
              (Merge 648:4-67
                (Function 648:4-28
                  (Identifier 648:4-13 array_sep) [
                    (NumberString 648:14-15 0)
                    (Function 648:17-27
                      (Identifier 648:17-22 maybe) [
                        (String 648:23-26 "_")
                      ])
                  ])
                (Function 648:31-67
                  (Identifier 648:31-36 maybe) [
                    (TakeLeft 648:37-66
                      (Function 648:37-46
                        (Identifier 648:37-41 skip) [
                          (String 648:42-45 "_")
                        ])
                      (Function 648:49-66
                        (Identifier 648:49-53 peek) [
                          (Identifier 648:54-65 hex_numeral)
                        ]))
                  ]))
              (Function 649:4-36
                (Identifier 649:4-13 array_sep) [
                  (Identifier 649:14-23 hex_digit)
                  (Function 649:25-35
                    (Identifier 649:25-30 maybe) [
                      (String 649:31-34 "_")
                    ])
                ])
            ])
          (Identifier 650:7-13 Digits))
        (Function 651:2-27
          (Identifier 651:2-19 Num.FromHexDigits) [
            (Identifier 651:20-26 Digits)
          ]))))
  
  (DeclareGlobal 653:0-43
    (Identifier 653:0-15 _Toml.Doc.Empty)
    (Object 653:18-43 [
      (ObjectPair (String 653:19-26 "value") (Object 653:28-31 []))
      (ObjectPair (String 653:32-38 "type") (Object 653:40-43 []))
    ]))
  
  (DeclareGlobal 655:0-44
    (Function 655:0-20
      (Identifier 655:0-15 _Toml.Doc.Value) [
        (Identifier 655:16-19 Doc)
      ])
    (Function 655:23-44
      (Identifier 655:23-30 Obj.Get) [
        (Identifier 655:31-34 Doc)
        (String 655:36-43 "value")
      ]))
  
  (DeclareGlobal 657:0-42
    (Function 657:0-19
      (Identifier 657:0-14 _Toml.Doc.Type) [
        (Identifier 657:15-18 Doc)
      ])
    (Function 657:22-42
      (Identifier 657:22-29 Obj.Get) [
        (Identifier 657:30-33 Doc)
        (String 657:35-41 "type")
      ]))
  
  (DeclareGlobal 659:0-59
    (Function 659:0-23
      (Identifier 659:0-13 _Toml.Doc.Has) [
        (Identifier 659:14-17 Doc)
        (Identifier 659:19-22 Key)
      ])
    (Function 659:26-59
      (Identifier 659:26-33 Obj.Has) [
        (Function 659:34-53
          (Identifier 659:34-48 _Toml.Doc.Type) [
            (Identifier 659:49-52 Doc)
          ])
        (Identifier 659:55-58 Key)
      ]))
  
  (DeclareGlobal 661:0-121
    (Function 661:0-23
      (Identifier 661:0-13 _Toml.Doc.Get) [
        (Identifier 661:14-17 Doc)
        (Identifier 661:19-22 Key)
      ])
    (Object 661:26-121 [
      (ObjectPair
        (String 662:2-9 "value")
        (Function 662:11-45
          (Identifier 662:11-18 Obj.Get) [
            (Function 662:19-39
              (Identifier 662:19-34 _Toml.Doc.Value) [
                (Identifier 662:35-38 Doc)
              ])
            (Identifier 662:41-44 Key)
          ]))
      (ObjectPair
        (String 663:2-8 "type")
        (Function 663:10-43
          (Identifier 663:10-17 Obj.Get) [
            (Function 663:18-37
              (Identifier 663:18-32 _Toml.Doc.Type) [
                (Identifier 663:33-36 Doc)
              ])
            (Identifier 663:39-42 Key)
          ]))
    ]))
  
  (DeclareGlobal 666:0-55
    (Function 666:0-22
      (Identifier 666:0-17 _Toml.Doc.IsTable) [
        (Identifier 666:18-21 Doc)
      ])
    (Function 666:25-55
      (Identifier 666:25-34 Is.Object) [
        (Function 666:35-54
          (Identifier 666:35-49 _Toml.Doc.Type) [
            (Identifier 666:50-53 Doc)
          ])
      ]))
  
  (DeclareGlobal 668:0-181
    (Function 668:0-37
      (Identifier 668:0-16 _Toml.Doc.Insert) [
        (Identifier 668:17-20 Doc)
        (Identifier 668:22-25 Key)
        (Identifier 668:27-30 Val)
        (Identifier 668:32-36 Type)
      ])
    (TakeRight 669:2-141
      (Function 669:2-24
        (Identifier 669:2-19 _Toml.Doc.IsTable) [
          (Identifier 669:20-23 Doc)
        ])
      (Object 670:2-114 [
        (ObjectPair
          (String 671:4-11 "value")
          (Function 671:13-52
            (Identifier 671:13-20 Obj.Put) [
              (Function 671:21-41
                (Identifier 671:21-36 _Toml.Doc.Value) [
                  (Identifier 671:37-40 Doc)
                ])
              (Identifier 671:43-46 Key)
              (Identifier 671:48-51 Val)
            ]))
        (ObjectPair
          (String 672:4-10 "type")
          (Function 672:12-51
            (Identifier 672:12-19 Obj.Put) [
              (Function 672:20-39
                (Identifier 672:20-34 _Toml.Doc.Type) [
                  (Identifier 672:35-38 Doc)
                ])
              (Identifier 672:41-44 Key)
              (Identifier 672:46-50 Type)
            ]))
      ])))
  
  (DeclareGlobal 675:0-184
    (Function 675:0-46
      (Identifier 675:0-31 _Toml.Doc.AppendToArrayOfTables) [
        (Identifier 675:32-35 Doc)
        (Identifier 675:37-40 Key)
        (Identifier 675:42-45 Val)
      ])
    (TakeRight 676:2-135
      (Destructure 676:2-70
        (Function 676:2-25
          (Identifier 676:2-15 _Toml.Doc.Get) [
            (Identifier 676:16-19 Doc)
            (Identifier 676:21-24 Key)
          ])
        (Object 676:29-70 [
          (ObjectPair (String 676:30-37 "value") (Identifier 676:39-42 AoT))
          (ObjectPair (String 676:44-50 "type") (String 676:52-69 "array_of_tables"))
        ]))
      (Function 677:2-62
        (Identifier 677:2-18 _Toml.Doc.Insert) [
          (Identifier 677:19-22 Doc)
          (Identifier 677:24-27 Key)
          (Merge 677:29-42
            (Merge 677:29-30
              (Array 677:29-30 [])
              (Identifier 677:33-36 AoT))
            (Array 677:38-42 [
              (Identifier 677:38-41 Val)
            ]))
          (String 677:44-61 "array_of_tables")
        ])))
  
  (DeclareGlobal 679:0-105
    (Function 679:0-38
      (Identifier 679:0-22 _Toml.Doc.InsertAtPath) [
        (Identifier 679:23-26 Doc)
        (Identifier 679:28-32 Path)
        (Identifier 679:34-37 Val)
      ])
    (Function 680:2-64
      (Identifier 680:2-24 _Toml.Doc.UpdateAtPath) [
        (Identifier 680:25-28 Doc)
        (Identifier 680:30-34 Path)
        (Identifier 680:36-39 Val)
        (Identifier 680:41-63 _Toml.Doc.ValueUpdater)
      ]))
  
  (DeclareGlobal 682:0-111
    (Function 682:0-38
      (Identifier 682:0-27 _Toml.Doc.EnsureTableAtPath) [
        (Identifier 682:28-31 Doc)
        (Identifier 682:33-37 Path)
      ])
    (Function 683:2-70
      (Identifier 683:2-24 _Toml.Doc.UpdateAtPath) [
        (Identifier 683:25-28 Doc)
        (Identifier 683:30-34 Path)
        (Object 683:36-39 [])
        (Identifier 683:40-69 _Toml.Doc.MissingTableUpdater)
      ]))
  
  (DeclareGlobal 685:0-106
    (Function 685:0-38
      (Identifier 685:0-22 _Toml.Doc.AppendAtPath) [
        (Identifier 685:23-26 Doc)
        (Identifier 685:28-32 Path)
        (Identifier 685:34-37 Val)
      ])
    (Function 686:2-65
      (Identifier 686:2-24 _Toml.Doc.UpdateAtPath) [
        (Identifier 686:25-28 Doc)
        (Identifier 686:30-34 Path)
        (Identifier 686:36-39 Val)
        (Identifier 686:41-64 _Toml.Doc.AppendUpdater)
      ]))
  
  (DeclareGlobal 688:0-494
    (Function 688:0-47
      (Identifier 688:0-22 _Toml.Doc.UpdateAtPath) [
        (Identifier 688:23-26 Doc)
        (Identifier 688:28-32 Path)
        (Identifier 688:34-37 Val)
        (Identifier 688:39-46 Updater)
      ])
    (Conditional 689:2-444
      (Destructure 689:2-15
        (Identifier 689:2-6 Path)
        (Array 689:10-15 [
          (Identifier 689:11-14 Key)
        ]))
      (Function 689:18-40
        (Identifier 689:18-25 Updater) [
          (Identifier 689:26-29 Doc)
          (Identifier 689:31-34 Key)
          (Identifier 689:36-39 Val)
        ])
      (Conditional 690:2-401
        (Destructure 690:2-28
          (Identifier 690:2-6 Path)
          (Merge 690:10-28
            (Array 690:10-11 [
              (Identifier 690:11-14 Key)
            ])
            (Identifier 690:19-27 PathRest)))
        (TakeRight 690:31-393
          (Destructure 691:4-270
            (Conditional 691:4-258
              (Function 692:6-29
                (Identifier 692:6-19 _Toml.Doc.Has) [
                  (Identifier 692:20-23 Doc)
                  (Identifier 692:25-28 Key)
                ])
              (TakeRight 692:32-174
                (Function 693:8-50
                  (Identifier 693:8-25 _Toml.Doc.IsTable) [
                    (Function 693:26-49
                      (Identifier 693:26-39 _Toml.Doc.Get) [
                        (Identifier 693:40-43 Doc)
                        (Identifier 693:45-48 Key)
                      ])
                  ])
                (Function 694:8-79
                  (Identifier 694:8-30 _Toml.Doc.UpdateAtPath) [
                    (Function 694:31-54
                      (Identifier 694:31-44 _Toml.Doc.Get) [
                        (Identifier 694:45-48 Doc)
                        (Identifier 694:50-53 Key)
                      ])
                    (Identifier 694:56-64 PathRest)
                    (Identifier 694:66-69 Val)
                    (Identifier 694:71-78 Updater)
                  ]))
              (Function 696:6-69
                (Identifier 696:6-28 _Toml.Doc.UpdateAtPath) [
                  (Identifier 696:29-44 _Toml.Doc.Empty)
                  (Identifier 696:46-54 PathRest)
                  (Identifier 696:56-59 Val)
                  (Identifier 696:61-68 Updater)
                ]))
            (Identifier 697:9-17 InnerDoc))
          (Function 698:4-83
            (Identifier 698:4-20 _Toml.Doc.Insert) [
              (Identifier 698:21-24 Doc)
              (Identifier 698:26-29 Key)
              (Function 698:31-56
                (Identifier 698:31-46 _Toml.Doc.Value) [
                  (Identifier 698:47-55 InnerDoc)
                ])
              (Function 698:58-82
                (Identifier 698:58-72 _Toml.Doc.Type) [
                  (Identifier 698:73-81 InnerDoc)
                ])
            ]))
        (Identifier 700:2-5 Doc))))
  
  (DeclareGlobal 702:0-116
    (Function 702:0-37
      (Identifier 702:0-22 _Toml.Doc.ValueUpdater) [
        (Identifier 702:23-26 Doc)
        (Identifier 702:28-31 Key)
        (Identifier 702:33-36 Val)
      ])
    (Conditional 703:2-76
      (Function 703:2-25
        (Identifier 703:2-15 _Toml.Doc.Has) [
          (Identifier 703:16-19 Doc)
          (Identifier 703:21-24 Key)
        ])
      (Identifier 703:28-33 @Fail)
      (Function 703:36-76
        (Identifier 703:36-52 _Toml.Doc.Insert) [
          (Identifier 703:53-56 Doc)
          (Identifier 703:58-61 Key)
          (Identifier 703:63-66 Val)
          (String 703:68-75 "value")
        ])))
  
  (DeclareGlobal 705:0-137
    (Function 705:0-45
      (Identifier 705:0-29 _Toml.Doc.MissingTableUpdater) [
        (Identifier 705:30-33 Doc)
        (Identifier 705:35-38 Key)
        (Identifier 705:40-44 _Val)
      ])
    (Conditional 706:2-89
      (Function 706:2-44
        (Identifier 706:2-19 _Toml.Doc.IsTable) [
          (Function 706:20-43
            (Identifier 706:20-33 _Toml.Doc.Get) [
              (Identifier 706:34-37 Doc)
              (Identifier 706:39-42 Key)
            ])
        ])
      (Identifier 706:47-50 Doc)
      (Function 707:2-36
        (Identifier 707:2-18 _Toml.Doc.Insert) [
          (Identifier 707:19-22 Doc)
          (Identifier 707:24-27 Key)
          (Object 707:29-32 [])
          (Object 707:33-36 [])
        ])))
  
  (DeclareGlobal 709:0-210
    (Function 709:0-38
      (Identifier 709:0-23 _Toml.Doc.AppendUpdater) [
        (Identifier 709:24-27 Doc)
        (Identifier 709:29-32 Key)
        (Identifier 709:34-37 Val)
      ])
    (TakeRight 710:2-169
      (Destructure 710:2-111
        (Conditional 710:2-97
          (Function 711:4-27
            (Identifier 711:4-17 _Toml.Doc.Has) [
              (Identifier 711:18-21 Doc)
              (Identifier 711:23-26 Key)
            ])
          (Identifier 711:30-33 Doc)
          (Function 712:4-53
            (Identifier 712:4-20 _Toml.Doc.Insert) [
              (Identifier 712:21-24 Doc)
              (Identifier 712:26-29 Key)
              (Array 712:31-34 [])
              (String 712:35-52 "array_of_tables")
            ]))
        (Identifier 713:7-17 DocWithKey))
      (Function 714:2-55
        (Identifier 714:2-33 _Toml.Doc.AppendToArrayOfTables) [
          (Identifier 714:34-44 DocWithKey)
          (Identifier 714:46-49 Key)
          (Identifier 714:51-54 Val)
        ])))
  
  (DeclareGlobal 719:0-129
    (Function 719:0-61
      (Identifier 719:0-28 ast.with_operator_precedence) [
        (Identifier 719:29-36 operand)
        (Identifier 719:38-44 prefix)
        (Identifier 719:46-51 infix)
        (Identifier 719:53-60 postfix)
      ])
    (Function 720:2-65
      (Identifier 720:2-28 _ast.with_precedence_start) [
        (Identifier 720:29-36 operand)
        (Identifier 720:38-44 prefix)
        (Identifier 720:46-51 infix)
        (Identifier 720:53-60 postfix)
        (ValueLabel 720:62-63 (NumberString 720:63-64 0))
      ]))
  
  (DeclareGlobal 722:0-509
    (Function 722:0-77
      (Identifier 722:0-26 _ast.with_precedence_start) [
        (Identifier 722:27-34 operand)
        (Identifier 722:36-42 prefix)
        (Identifier 722:44-49 infix)
        (Identifier 722:51-58 postfix)
        (Identifier 722:60-76 LeftBindingPower)
      ])
    (Conditional 723:2-429
      (Destructure 723:2-40
        (Identifier 723:2-8 prefix)
        (Array 723:12-40 [
          (Identifier 723:13-19 OpNode)
          (Identifier 723:21-39 PrefixBindingPower)
        ]))
      (TakeRight 723:43-312
        (Destructure 724:4-117
          (Function 724:4-101
            (Identifier 724:4-30 _ast.with_precedence_start) [
              (Identifier 725:6-13 operand)
              (Identifier 725:15-21 prefix)
              (Identifier 725:23-28 infix)
              (Identifier 725:30-37 postfix)
              (Identifier 726:6-24 PrefixBindingPower)
            ])
          (Identifier 727:9-21 PrefixedNode))
        (Function 728:4-143
          (Identifier 728:4-29 _ast.with_precedence_rest) [
            (Identifier 729:6-13 operand)
            (Identifier 729:15-21 prefix)
            (Identifier 729:23-28 infix)
            (Identifier 729:30-37 postfix)
            (Identifier 730:6-22 LeftBindingPower)
            (Merge 731:6-43
              (Merge 731:6-7
                (Object 731:6-7 [])
                (Identifier 731:10-16 OpNode))
              (Object 731:18-43 [
                (ObjectPair (String 731:18-28 "prefixed") (Identifier 731:30-42 PrefixedNode))
              ]))
          ]))
      (TakeRight 733:6-120
        (Destructure 734:4-19
          (Identifier 734:4-11 operand)
          (Identifier 734:15-19 Node))
        (Function 735:4-86
          (Identifier 735:4-29 _ast.with_precedence_rest) [
            (Identifier 735:30-37 operand)
            (Identifier 735:39-45 prefix)
            (Identifier 735:47-52 infix)
            (Identifier 735:54-61 postfix)
            (Identifier 735:63-79 LeftBindingPower)
            (Identifier 735:81-85 Node)
          ]))))
  
  (DeclareGlobal 738:0-748
    (Function 738:0-82
      (Identifier 738:0-25 _ast.with_precedence_rest) [
        (Identifier 738:26-33 operand)
        (Identifier 738:35-41 prefix)
        (Identifier 738:43-48 infix)
        (Identifier 738:50-57 postfix)
        (Identifier 738:59-75 LeftBindingPower)
        (Identifier 738:77-81 Node)
      ])
    (Conditional 739:2-663
      (TakeRight 739:2-100
        (Destructure 739:2-40
          (Identifier 739:2-9 postfix)
          (Array 739:13-40 [
            (Identifier 739:14-20 OpNode)
            (Identifier 739:22-39 RightBindingPower)
          ]))
        (Function 740:2-57
          (Identifier 740:2-7 const) [
            (Function 740:8-56
              (Identifier 740:8-19 Is.LessThan) [
                (Identifier 740:20-36 LeftBindingPower)
                (Identifier 740:38-55 RightBindingPower)
              ])
          ]))
      (Function 740:60-202
        (Identifier 741:4-29 _ast.with_precedence_rest) [
          (Identifier 742:6-13 operand)
          (Identifier 742:15-21 prefix)
          (Identifier 742:23-28 infix)
          (Identifier 742:30-37 postfix)
          (Identifier 743:6-22 LeftBindingPower)
          (Merge 744:6-36
            (Merge 744:6-7
              (Object 744:6-7 [])
              (Identifier 744:10-16 OpNode))
            (Object 744:18-36 [
              (ObjectPair (String 744:18-29 "postfixed") (Identifier 744:31-35 Node))
            ]))
        ])
      (Conditional 747:2-415
        (TakeRight 747:2-120
          (Destructure 747:2-60
            (Identifier 747:2-7 infix)
            (Array 747:11-60 [
              (Identifier 747:12-18 OpNode)
              (Identifier 747:20-37 RightBindingPower)
              (Identifier 747:39-59 NextLeftBindingPower)
            ]))
          (Function 748:2-57
            (Identifier 748:2-7 const) [
              (Function 748:8-56
                (Identifier 748:8-19 Is.LessThan) [
                  (Identifier 748:20-36 LeftBindingPower)
                  (Identifier 748:38-55 RightBindingPower)
                ])
            ]))
        (TakeRight 748:60-336
          (Destructure 749:4-116
            (Function 749:4-103
              (Identifier 749:4-30 _ast.with_precedence_start) [
                (Identifier 750:6-13 operand)
                (Identifier 750:15-21 prefix)
                (Identifier 750:23-28 infix)
                (Identifier 750:30-37 postfix)
                (Identifier 751:6-26 NextLeftBindingPower)
              ])
            (Identifier 752:9-18 RightNode))
          (Function 753:4-151
            (Identifier 753:4-29 _ast.with_precedence_rest) [
              (Identifier 754:6-13 operand)
              (Identifier 754:15-21 prefix)
              (Identifier 754:23-28 infix)
              (Identifier 754:30-37 postfix)
              (Identifier 755:6-22 LeftBindingPower)
              (Merge 756:6-51
                (Merge 756:6-7
                  (Object 756:6-7 [])
                  (Identifier 756:10-16 OpNode))
                (Object 756:18-51 [
                  (ObjectPair (String 756:18-24 "left") (Identifier 756:26-30 Node))
                  (ObjectPair (String 756:32-39 "right") (Identifier 756:41-50 RightNode))
                ]))
            ]))
        (Function 759:2-13
          (Identifier 759:2-7 const) [
            (Identifier 759:8-12 Node)
          ]))))
  
  (DeclareGlobal 761:0-73
    (Function 761:0-21
      (Identifier 761:0-8 ast.node) [
        (Identifier 761:9-13 Type)
        (Identifier 761:15-20 value)
      ])
    (Return 762:2-49
      (Destructure 762:2-16
        (Identifier 762:2-7 value)
        (Identifier 762:11-16 Value))
      (Object 762:19-49 [
        (ObjectPair (String 762:20-26 "type") (Identifier 762:28-32 Type))
        (ObjectPair (String 762:34-41 "value") (Identifier 762:43-48 Value))
      ])))
  
  (DeclareGlobal 768:0-14
    (Identifier 768:0-7 Num.Add)
    (Identifier 768:10-14 @Add))
  
  (DeclareGlobal 770:0-19
    (Identifier 770:0-7 Num.Sub)
    (Identifier 770:10-19 @Subtract))
  
  (DeclareGlobal 772:0-19
    (Identifier 772:0-7 Num.Mul)
    (Identifier 772:10-19 @Multiply))
  
  (DeclareGlobal 774:0-17
    (Identifier 774:0-7 Num.Div)
    (Identifier 774:10-17 @Divide))
  
  (DeclareGlobal 776:0-16
    (Identifier 776:0-7 Num.Pow)
    (Identifier 776:10-16 @Power))
  
  (DeclareGlobal 778:0-23
    (Function 778:0-10
      (Identifier 778:0-7 Num.Inc) [
        (Identifier 778:8-9 N)
      ])
    (Function 778:13-23
      (Identifier 778:13-17 @Add) [
        (Identifier 778:18-19 N)
        (NumberString 778:21-22 1)
      ]))
  
  (DeclareGlobal 780:0-28
    (Function 780:0-10
      (Identifier 780:0-7 Num.Dec) [
        (Identifier 780:8-9 N)
      ])
    (Function 780:13-28
      (Identifier 780:13-22 @Subtract) [
        (Identifier 780:23-24 N)
        (NumberString 780:26-27 1)
      ]))
  
  (DeclareGlobal 782:0-26
    (Function 782:0-10
      (Identifier 782:0-7 Num.Abs) [
        (Identifier 782:8-9 N)
      ])
    (Or 782:13-26
      (Destructure 782:13-21
        (Identifier 782:13-14 N)
        (Range 782:18-21 (NumberString 782:18-19 0) ()))
      (Negation 782:24-26 (Identifier 782:25-26 N))))
  
  (DeclareGlobal 784:0-32
    (Function 784:0-13
      (Identifier 784:0-7 Num.Max) [
        (Identifier 784:8-9 A)
        (Identifier 784:11-12 B)
      ])
    (Conditional 784:16-32
      (Destructure 784:16-24
        (Identifier 784:16-17 A)
        (Range 784:21-24 (Identifier 784:21-22 B) ()))
      (Identifier 784:27-28 A)
      (Identifier 784:31-32 B)))
  
  (DeclareGlobal 786:0-94
    (Function 786:0-24
      (Identifier 786:0-20 Num.FromBinaryDigits) [
        (Identifier 786:21-23 Bs)
      ])
    (TakeRight 787:2-67
      (Destructure 787:2-25
        (Function 787:2-18
          (Identifier 787:2-14 Array.Length) [
            (Identifier 787:15-17 Bs)
          ])
        (Identifier 787:22-25 Len))
      (Function 788:2-39
        (Identifier 788:2-23 _Num.FromBinaryDigits) [
          (Identifier 788:24-26 Bs)
          (NumberSubtract 788:28-35
            (Identifier 788:28-31 Len)
            (NumberString 788:34-35 1))
          (NumberString 788:37-38 0)
        ])))
  
  (DeclareGlobal 790:0-191
    (Function 790:0-35
      (Identifier 790:0-21 _Num.FromBinaryDigits) [
        (Identifier 790:22-24 Bs)
        (Identifier 790:26-29 Pos)
        (Identifier 790:31-34 Acc)
      ])
    (Conditional 791:2-153
      (Destructure 791:2-20
        (Identifier 791:2-4 Bs)
        (Merge 791:8-20
          (Array 791:8-9 [
            (Identifier 791:9-10 B)
          ])
          (Identifier 791:15-19 Rest)))
      (TakeRight 791:23-145
        (Destructure 792:4-13
          (Identifier 792:4-5 B)
          (Range 792:9-13 (NumberString 792:9-10 0) (NumberString 792:12-13 1)))
        (Function 793:4-100
          (Identifier 793:4-25 _Num.FromBinaryDigits) [
            (Identifier 794:6-10 Rest)
            (NumberSubtract 795:6-13
              (Identifier 795:6-9 Pos)
              (NumberString 795:12-13 1))
            (Merge 796:6-39
              (Identifier 796:6-9 Acc)
              (Function 796:12-39
                (Identifier 796:12-19 Num.Mul) [
                  (Identifier 796:20-21 B)
                  (Function 796:23-38
                    (Identifier 796:23-30 Num.Pow) [
                      (NumberString 796:31-32 2)
                      (Identifier 796:34-37 Pos)
                    ])
                ]))
          ]))
      (Identifier 799:2-5 Acc)))
  
  (DeclareGlobal 801:0-92
    (Function 801:0-23
      (Identifier 801:0-19 Num.FromOctalDigits) [
        (Identifier 801:20-22 Os)
      ])
    (TakeRight 802:2-66
      (Destructure 802:2-25
        (Function 802:2-18
          (Identifier 802:2-14 Array.Length) [
            (Identifier 802:15-17 Os)
          ])
        (Identifier 802:22-25 Len))
      (Function 803:2-38
        (Identifier 803:2-22 _Num.FromOctalDigits) [
          (Identifier 803:23-25 Os)
          (NumberSubtract 803:27-34
            (Identifier 803:27-30 Len)
            (NumberString 803:33-34 1))
          (NumberString 803:36-37 0)
        ])))
  
  (DeclareGlobal 805:0-189
    (Function 805:0-34
      (Identifier 805:0-20 _Num.FromOctalDigits) [
        (Identifier 805:21-23 Os)
        (Identifier 805:25-28 Pos)
        (Identifier 805:30-33 Acc)
      ])
    (Conditional 806:2-152
      (Destructure 806:2-20
        (Identifier 806:2-4 Os)
        (Merge 806:8-20
          (Array 806:8-9 [
            (Identifier 806:9-10 O)
          ])
          (Identifier 806:15-19 Rest)))
      (TakeRight 806:23-144
        (Destructure 807:4-13
          (Identifier 807:4-5 O)
          (Range 807:9-13 (NumberString 807:9-10 0) (NumberString 807:12-13 7)))
        (Function 808:4-99
          (Identifier 808:4-24 _Num.FromOctalDigits) [
            (Identifier 809:6-10 Rest)
            (NumberSubtract 810:6-13
              (Identifier 810:6-9 Pos)
              (NumberString 810:12-13 1))
            (Merge 811:6-39
              (Identifier 811:6-9 Acc)
              (Function 811:12-39
                (Identifier 811:12-19 Num.Mul) [
                  (Identifier 811:20-21 O)
                  (Function 811:23-38
                    (Identifier 811:23-30 Num.Pow) [
                      (NumberString 811:31-32 8)
                      (Identifier 811:34-37 Pos)
                    ])
                ]))
          ]))
      (Identifier 814:2-5 Acc)))
  
  (DeclareGlobal 816:0-88
    (Function 816:0-21
      (Identifier 816:0-17 Num.FromHexDigits) [
        (Identifier 816:18-20 Hs)
      ])
    (TakeRight 817:2-64
      (Destructure 817:2-25
        (Function 817:2-18
          (Identifier 817:2-14 Array.Length) [
            (Identifier 817:15-17 Hs)
          ])
        (Identifier 817:22-25 Len))
      (Function 818:2-36
        (Identifier 818:2-20 _Num.FromHexDigits) [
          (Identifier 818:21-23 Hs)
          (NumberSubtract 818:25-32
            (Identifier 818:25-28 Len)
            (NumberString 818:31-32 1))
          (NumberString 818:34-35 0)
        ])))
  
  (DeclareGlobal 820:0-187
    (Function 820:0-32
      (Identifier 820:0-18 _Num.FromHexDigits) [
        (Identifier 820:19-21 Hs)
        (Identifier 820:23-26 Pos)
        (Identifier 820:28-31 Acc)
      ])
    (Conditional 821:2-152
      (Destructure 821:2-20
        (Identifier 821:2-4 Hs)
        (Merge 821:8-20
          (Array 821:8-9 [
            (Identifier 821:9-10 H)
          ])
          (Identifier 821:15-19 Rest)))
      (TakeRight 821:23-144
        (Destructure 822:4-14
          (Identifier 822:4-5 H)
          (Range 822:9-14 (NumberString 822:9-10 0) (NumberString 822:12-14 15)))
        (Function 823:4-98
          (Identifier 823:4-22 _Num.FromHexDigits) [
            (Identifier 824:6-10 Rest)
            (NumberSubtract 825:6-13
              (Identifier 825:6-9 Pos)
              (NumberString 825:12-13 1))
            (Merge 826:6-40
              (Identifier 826:6-9 Acc)
              (Function 826:12-40
                (Identifier 826:12-19 Num.Mul) [
                  (Identifier 826:20-21 H)
                  (Function 826:23-39
                    (Identifier 826:23-30 Num.Pow) [
                      (NumberString 826:31-33 16)
                      (Identifier 826:35-38 Pos)
                    ])
                ]))
          ]))
      (Identifier 829:2-5 Acc)))
  
  (DeclareGlobal 833:0-43
    (Function 833:0-18
      (Identifier 833:0-11 Array.First) [
        (Identifier 833:12-17 Array)
      ])
    (TakeRight 833:21-43
      (Destructure 833:21-39
        (Identifier 833:21-26 Array)
        (Merge 833:30-39
          (Array 833:30-31 [
            (Identifier 833:31-32 F)
          ])
          (Identifier 833:37-38 _)))
      (Identifier 833:42-43 F)))
  
  (DeclareGlobal 835:0-42
    (Function 835:0-17
      (Identifier 835:0-10 Array.Rest) [
        (Identifier 835:11-16 Array)
      ])
    (TakeRight 835:20-42
      (Destructure 835:20-38
        (Identifier 835:20-25 Array)
        (Merge 835:29-38
          (Array 835:29-30 [
            (Identifier 835:30-31 _)
          ])
          (Identifier 835:36-37 R)))
      (Identifier 835:41-42 R)))
  
  (DeclareGlobal 837:0-37
    (Function 837:0-15
      (Identifier 837:0-12 Array.Length) [
        (Identifier 837:13-14 A)
      ])
    (Function 837:18-37
      (Identifier 837:18-31 _Array.Length) [
        (Identifier 837:32-33 A)
        (NumberString 837:35-36 0)
      ]))
  
  (DeclareGlobal 839:0-84
    (Function 839:0-21
      (Identifier 839:0-13 _Array.Length) [
        (Identifier 839:14-15 A)
        (Identifier 839:17-20 Acc)
      ])
    (Conditional 840:2-60
      (Destructure 840:2-19
        (Identifier 840:2-3 A)
        (Merge 840:7-19
          (Array 840:7-8 [
            (Identifier 840:8-9 _)
          ])
          (Identifier 840:14-18 Rest)))
      (Function 841:2-30
        (Identifier 841:2-15 _Array.Length) [
          (Identifier 841:16-20 Rest)
          (Merge 841:22-29
            (Identifier 841:22-25 Acc)
            (NumberString 841:28-29 1))
        ])
      (Identifier 842:2-5 Acc)))
  
  (DeclareGlobal 844:0-40
    (Function 844:0-16
      (Identifier 844:0-13 Array.Reverse) [
        (Identifier 844:14-15 A)
      ])
    (Function 844:19-40
      (Identifier 844:19-33 _Array.Reverse) [
        (Identifier 844:34-35 A)
        (Array 844:37-40 [])
      ]))
  
  (DeclareGlobal 846:0-98
    (Function 846:0-22
      (Identifier 846:0-14 _Array.Reverse) [
        (Identifier 846:15-16 A)
        (Identifier 846:18-21 Acc)
      ])
    (Conditional 847:2-73
      (Destructure 847:2-23
        (Identifier 847:2-3 A)
        (Merge 847:7-23
          (Array 847:7-8 [
            (Identifier 847:8-13 First)
          ])
          (Identifier 847:18-22 Rest)))
      (Function 848:2-39
        (Identifier 848:2-16 _Array.Reverse) [
          (Identifier 848:17-21 Rest)
          (Merge 848:23-38
            (Array 848:23-24 [
              (Identifier 848:24-29 First)
            ])
            (Identifier 848:34-37 Acc))
        ])
      (Identifier 849:2-5 Acc)))
  
  (DeclareGlobal 851:0-40
    (Function 851:0-16
      (Identifier 851:0-9 Array.Map) [
        (Identifier 851:10-11 A)
        (Identifier 851:13-15 Fn)
      ])
    (Function 851:19-40
      (Identifier 851:19-29 _Array.Map) [
        (Identifier 851:30-31 A)
        (Identifier 851:33-35 Fn)
        (Array 851:37-40 [])
      ]))
  
  (DeclareGlobal 853:0-102
    (Function 853:0-22
      (Identifier 853:0-10 _Array.Map) [
        (Identifier 853:11-12 A)
        (Identifier 853:14-16 Fn)
        (Identifier 853:18-21 Acc)
      ])
    (Conditional 854:2-77
      (Destructure 854:2-23
        (Identifier 854:2-3 A)
        (Merge 854:7-23
          (Array 854:7-8 [
            (Identifier 854:8-13 First)
          ])
          (Identifier 854:18-22 Rest)))
      (Function 855:2-43
        (Identifier 855:2-12 _Array.Map) [
          (Identifier 855:13-17 Rest)
          (Identifier 855:19-21 Fn)
          (Merge 855:23-42
            (Merge 855:23-24
              (Array 855:23-24 [])
              (Identifier 855:27-30 Acc))
            (Array 855:32-42 [
              (Function 855:32-41
                (Identifier 855:32-34 Fn) [
                  (Identifier 855:35-40 First)
                ])
            ]))
        ])
      (Identifier 856:2-5 Acc)))
  
  (DeclareGlobal 858:0-50
    (Function 858:0-21
      (Identifier 858:0-12 Array.Filter) [
        (Identifier 858:13-14 A)
        (Identifier 858:16-20 Pred)
      ])
    (Function 858:24-50
      (Identifier 858:24-37 _Array.Filter) [
        (Identifier 858:38-39 A)
        (Identifier 858:41-45 Pred)
        (Array 858:47-50 [])
      ]))
  
  (DeclareGlobal 860:0-128
    (Function 860:0-27
      (Identifier 860:0-13 _Array.Filter) [
        (Identifier 860:14-15 A)
        (Identifier 860:17-21 Pred)
        (Identifier 860:23-26 Acc)
      ])
    (Conditional 861:2-98
      (Destructure 861:2-23
        (Identifier 861:2-3 A)
        (Merge 861:7-23
          (Array 861:7-8 [
            (Identifier 861:8-13 First)
          ])
          (Identifier 861:18-22 Rest)))
      (Function 862:2-64
        (Identifier 862:2-15 _Array.Filter) [
          (Identifier 862:16-20 Rest)
          (Identifier 862:22-26 Pred)
          (Conditional 862:28-63
            (Function 862:28-39
              (Identifier 862:28-32 Pred) [
                (Identifier 862:33-38 First)
              ])
            (Merge 862:42-57
              (Merge 862:42-43
                (Array 862:42-43 [])
                (Identifier 862:46-49 Acc))
              (Array 862:51-57 [
                (Identifier 862:51-56 First)
              ]))
            (Identifier 862:60-63 Acc))
        ])
      (Identifier 863:2-5 Acc)))
  
  (DeclareGlobal 865:0-50
    (Function 865:0-21
      (Identifier 865:0-12 Array.Reject) [
        (Identifier 865:13-14 A)
        (Identifier 865:16-20 Pred)
      ])
    (Function 865:24-50
      (Identifier 865:24-37 _Array.Reject) [
        (Identifier 865:38-39 A)
        (Identifier 865:41-45 Pred)
        (Array 865:47-50 [])
      ]))
  
  (DeclareGlobal 867:0-128
    (Function 867:0-27
      (Identifier 867:0-13 _Array.Reject) [
        (Identifier 867:14-15 A)
        (Identifier 867:17-21 Pred)
        (Identifier 867:23-26 Acc)
      ])
    (Conditional 868:2-98
      (Destructure 868:2-23
        (Identifier 868:2-3 A)
        (Merge 868:7-23
          (Array 868:7-8 [
            (Identifier 868:8-13 First)
          ])
          (Identifier 868:18-22 Rest)))
      (Function 869:2-64
        (Identifier 869:2-15 _Array.Reject) [
          (Identifier 869:16-20 Rest)
          (Identifier 869:22-26 Pred)
          (Conditional 869:28-63
            (Function 869:28-39
              (Identifier 869:28-32 Pred) [
                (Identifier 869:33-38 First)
              ])
            (Identifier 869:42-45 Acc)
            (Merge 869:48-63
              (Merge 869:48-49
                (Array 869:48-49 [])
                (Identifier 869:52-55 Acc))
              (Array 869:57-63 [
                (Identifier 869:57-62 First)
              ])))
        ])
      (Identifier 870:2-5 Acc)))
  
  (DeclareGlobal 872:0-54
    (Function 872:0-23
      (Identifier 872:0-15 Array.ZipObject) [
        (Identifier 872:16-18 Ks)
        (Identifier 872:20-22 Vs)
      ])
    (Function 872:26-54
      (Identifier 872:26-42 _Array.ZipObject) [
        (Identifier 872:43-45 Ks)
        (Identifier 872:47-49 Vs)
        (Object 872:51-54 [])
      ]))
  
  (DeclareGlobal 874:0-138
    (Function 874:0-29
      (Identifier 874:0-16 _Array.ZipObject) [
        (Identifier 874:17-19 Ks)
        (Identifier 874:21-23 Vs)
        (Identifier 874:25-28 Acc)
      ])
    (Conditional 875:2-106
      (TakeRight 875:2-45
        (Destructure 875:2-22
          (Identifier 875:2-4 Ks)
          (Merge 875:8-22
            (Array 875:8-9 [
              (Identifier 875:9-10 K)
            ])
            (Identifier 875:15-21 KsRest)))
        (Destructure 875:25-45
          (Identifier 875:25-27 Vs)
          (Merge 875:31-45
            (Array 875:31-32 [
              (Identifier 875:32-33 V)
            ])
            (Identifier 875:38-44 VsRest))))
      (Function 876:2-50
        (Identifier 876:2-18 _Array.ZipObject) [
          (Identifier 876:19-25 KsRest)
          (Identifier 876:27-33 VsRest)
          (Merge 876:35-49
            (Merge 876:35-36
              (Object 876:35-36 [])
              (Identifier 876:39-42 Acc))
            (Object 876:44-49 [
              (ObjectPair (Identifier 876:44-45 K) (Identifier 876:47-48 V))
            ]))
        ])
      (Identifier 877:2-5 Acc)))
  
  (DeclareGlobal 879:0-52
    (Function 879:0-22
      (Identifier 879:0-14 Array.ZipPairs) [
        (Identifier 879:15-17 A1)
        (Identifier 879:19-21 A2)
      ])
    (Function 879:25-52
      (Identifier 879:25-40 _Array.ZipPairs) [
        (Identifier 879:41-43 A1)
        (Identifier 879:45-47 A2)
        (Array 879:49-52 [])
      ]))
  
  (DeclareGlobal 881:0-154
    (Function 881:0-28
      (Identifier 881:0-15 _Array.ZipPairs) [
        (Identifier 881:16-18 A1)
        (Identifier 881:20-22 A2)
        (Identifier 881:24-27 Acc)
      ])
    (Conditional 882:2-123
      (TakeRight 882:2-53
        (Destructure 882:2-26
          (Identifier 882:2-4 A1)
          (Merge 882:8-26
            (Array 882:8-9 [
              (Identifier 882:9-15 First1)
            ])
            (Identifier 882:20-25 Rest1)))
        (Destructure 882:29-53
          (Identifier 882:29-31 A2)
          (Merge 882:35-53
            (Array 882:35-36 [
              (Identifier 882:36-42 First2)
            ])
            (Identifier 882:47-52 Rest2))))
      (Function 883:2-59
        (Identifier 883:2-17 _Array.ZipPairs) [
          (Identifier 883:18-23 Rest1)
          (Identifier 883:25-30 Rest2)
          (Merge 883:32-58
            (Merge 883:32-33
              (Array 883:32-33 [])
              (Identifier 883:36-39 Acc))
            (Array 883:41-58 [
              (Array 883:41-57 [
                (Identifier 883:42-48 First1)
                (Identifier 883:50-56 First2)
              ])
            ]))
        ])
      (Identifier 884:2-5 Acc)))
  
  (DeclareGlobal 886:0-42
    (Function 886:0-24
      (Identifier 886:0-13 Array.AppendN) [
        (Identifier 886:14-15 A)
        (Identifier 886:17-20 Val)
        (Identifier 886:22-23 N)
      ])
    (Merge 886:27-42
      (Identifier 886:27-28 A)
      (Repeat 886:31-42
        (Array 886:32-37 [
          (Identifier 886:33-36 Val)
        ])
        (Identifier 886:40-41 N))))
  
  (DeclareGlobal 888:0-44
    (Function 888:0-18
      (Identifier 888:0-15 Table.Transpose) [
        (Identifier 888:16-17 T)
      ])
    (Function 888:21-44
      (Identifier 888:21-37 _Table.Transpose) [
        (Identifier 888:38-39 T)
        (Array 888:41-44 [])
      ]))
  
  (DeclareGlobal 890:0-168
    (Function 890:0-24
      (Identifier 890:0-16 _Table.Transpose) [
        (Identifier 890:17-18 T)
        (Identifier 890:20-23 Acc)
      ])
    (Conditional 891:2-141
      (TakeRight 891:2-77
        (Destructure 891:2-38
          (Function 891:2-23
            (Identifier 891:2-20 _Table.FirstPerRow) [
              (Identifier 891:21-22 T)
            ])
          (Identifier 891:27-38 FirstPerRow))
        (Destructure 892:2-36
          (Function 892:2-22
            (Identifier 892:2-19 _Table.RestPerRow) [
              (Identifier 892:20-21 T)
            ])
          (Identifier 892:26-36 RestPerRow)))
      (Function 893:2-53
        (Identifier 893:2-18 _Table.Transpose) [
          (Identifier 893:19-29 RestPerRow)
          (Merge 893:31-52
            (Merge 893:31-32
              (Array 893:31-32 [])
              (Identifier 893:35-38 Acc))
            (Array 893:40-52 [
              (Identifier 893:40-51 FirstPerRow)
            ]))
        ])
      (Identifier 894:2-5 Acc)))
  
  (DeclareGlobal 896:0-115
    (Function 896:0-21
      (Identifier 896:0-18 _Table.FirstPerRow) [
        (Identifier 896:19-20 T)
      ])
    (TakeRight 897:2-91
      (TakeRight 897:2-48
        (Destructure 897:2-21
          (Identifier 897:2-3 T)
          (Merge 897:7-21
            (Array 897:7-8 [
              (Identifier 897:8-11 Row)
            ])
            (Identifier 897:16-20 Rest)))
        (Destructure 897:24-48
          (Identifier 897:24-27 Row)
          (Merge 897:31-48
            (Array 897:31-32 [
              (Identifier 897:32-41 VeryFirst)
            ])
            (Identifier 897:46-47 _))))
      (Function 898:2-40
        (Identifier 898:2-21 __Table.FirstPerRow) [
          (Identifier 898:22-26 Rest)
          (Array 898:28-39 [
            (Identifier 898:29-38 VeryFirst)
          ])
        ])))
  
  (DeclareGlobal 900:0-129
    (Function 900:0-27
      (Identifier 900:0-19 __Table.FirstPerRow) [
        (Identifier 900:20-21 T)
        (Identifier 900:23-26 Acc)
      ])
    (Conditional 901:2-99
      (TakeRight 901:2-44
        (Destructure 901:2-21
          (Identifier 901:2-3 T)
          (Merge 901:7-21
            (Array 901:7-8 [
              (Identifier 901:8-11 Row)
            ])
            (Identifier 901:16-20 Rest)))
        (Destructure 901:24-44
          (Identifier 901:24-27 Row)
          (Merge 901:31-44
            (Array 901:31-32 [
              (Identifier 901:32-37 First)
            ])
            (Identifier 901:42-43 _))))
      (Function 902:2-44
        (Identifier 902:2-21 __Table.FirstPerRow) [
          (Identifier 902:22-26 Rest)
          (Merge 902:28-43
            (Merge 902:28-29
              (Array 902:28-29 [])
              (Identifier 902:32-35 Acc))
            (Array 902:37-43 [
              (Identifier 902:37-42 First)
            ]))
        ])
      (Identifier 903:2-5 Acc)))
  
  (DeclareGlobal 905:0-48
    (Function 905:0-20
      (Identifier 905:0-17 _Table.RestPerRow) [
        (Identifier 905:18-19 T)
      ])
    (Function 905:23-48
      (Identifier 905:23-41 __Table.RestPerRow) [
        (Identifier 905:42-43 T)
        (Array 905:45-48 [])
      ]))
  
  (DeclareGlobal 907:0-188
    (Function 907:0-26
      (Identifier 907:0-18 __Table.RestPerRow) [
        (Identifier 907:19-20 T)
        (Identifier 907:22-25 Acc)
      ])
    (Conditional 908:2-159
      (Destructure 908:2-21
        (Identifier 908:2-3 T)
        (Merge 908:7-21
          (Array 908:7-8 [
            (Identifier 908:8-11 Row)
          ])
          (Identifier 908:16-20 Rest)))
      (Conditional 908:24-151
        (Destructure 909:4-26
          (Identifier 909:4-7 Row)
          (Merge 909:11-26
            (Array 909:11-12 [
              (Identifier 909:12-13 _)
            ])
            (Identifier 909:18-25 RowRest)))
        (Function 910:4-47
          (Identifier 910:4-22 __Table.RestPerRow) [
            (Identifier 910:23-27 Rest)
            (Merge 910:29-46
              (Merge 910:29-30
                (Array 910:29-30 [])
                (Identifier 910:33-36 Acc))
              (Array 910:38-46 [
                (Identifier 910:38-45 RowRest)
              ]))
          ])
        (Function 911:4-42
          (Identifier 911:4-22 __Table.RestPerRow) [
            (Identifier 911:23-27 Rest)
            (Merge 911:29-41
              (Merge 911:29-30
                (Array 911:29-30 [])
                (Identifier 911:33-36 Acc))
              (Array 911:38-41 [
                (Array 911:38-41 [])
              ]))
          ]))
      (Identifier 913:2-5 Acc)))
  
  (DeclareGlobal 915:0-71
    (Function 915:0-24
      (Identifier 915:0-21 Table.RotateClockwise) [
        (Identifier 915:22-23 T)
      ])
    (Function 915:27-71
      (Identifier 915:27-36 Array.Map) [
        (Function 915:37-55
          (Identifier 915:37-52 Table.Transpose) [
            (Identifier 915:53-54 T)
          ])
        (Identifier 915:57-70 Array.Reverse)
      ]))
  
  (DeclareGlobal 917:0-67
    (Function 917:0-31
      (Identifier 917:0-28 Table.RotateCounterClockwise) [
        (Identifier 917:29-30 T)
      ])
    (Function 917:34-67
      (Identifier 917:34-47 Array.Reverse) [
        (Function 917:48-66
          (Identifier 917:48-63 Table.Transpose) [
            (Identifier 917:64-65 T)
          ])
      ]))
  
  (DeclareGlobal 919:0-60
    (Function 919:0-26
      (Identifier 919:0-16 Table.ZipObjects) [
        (Identifier 919:17-19 Ks)
        (Identifier 919:21-25 Rows)
      ])
    (Function 919:29-60
      (Identifier 919:29-46 _Table.ZipObjects) [
        (Identifier 919:47-49 Ks)
        (Identifier 919:51-55 Rows)
        (Array 919:57-60 [])
      ]))
  
  (DeclareGlobal 921:0-135
    (Function 921:0-32
      (Identifier 921:0-17 _Table.ZipObjects) [
        (Identifier 921:18-20 Ks)
        (Identifier 921:22-26 Rows)
        (Identifier 921:28-31 Acc)
      ])
    (Conditional 922:2-100
      (Destructure 922:2-24
        (Identifier 922:2-6 Rows)
        (Merge 922:10-24
          (Array 922:10-11 [
            (Identifier 922:11-14 Row)
          ])
          (Identifier 922:19-23 Rest)))
      (Function 923:2-65
        (Identifier 923:2-19 _Table.ZipObjects) [
          (Identifier 923:20-22 Ks)
          (Identifier 923:24-28 Rest)
          (Merge 923:30-64
            (Merge 923:30-31
              (Array 923:30-31 [])
              (Identifier 923:34-37 Acc))
            (Array 923:39-64 [
              (Function 923:39-63
                (Identifier 923:39-54 Array.ZipObject) [
                  (Identifier 923:55-57 Ks)
                  (Identifier 923:59-62 Row)
                ])
            ]))
        ])
      (Identifier 924:2-5 Acc)))
  
  (DeclareGlobal 928:0-33
    (Function 928:0-13
      (Identifier 928:0-7 Obj.Has) [
        (Identifier 928:8-9 O)
        (Identifier 928:11-12 K)
      ])
    (Destructure 928:16-33
      (Identifier 928:16-17 O)
      (Merge 928:21-33
        (Object 928:21-31 [
          (ObjectPair (Identifier 928:22-23 K) (Identifier 928:25-26 _))
        ])
        (Identifier 928:31-32 _))))
  
  (DeclareGlobal 930:0-37
    (Function 930:0-13
      (Identifier 930:0-7 Obj.Get) [
        (Identifier 930:8-9 O)
        (Identifier 930:11-12 K)
      ])
    (TakeRight 930:16-37
      (Destructure 930:16-33
        (Identifier 930:16-17 O)
        (Merge 930:21-33
          (Object 930:21-31 [
            (ObjectPair (Identifier 930:22-23 K) (Identifier 930:25-26 V))
          ])
          (Identifier 930:31-32 _)))
      (Identifier 930:36-37 V)))
  
  (DeclareGlobal 932:0-31
    (Function 932:0-16
      (Identifier 932:0-7 Obj.Put) [
        (Identifier 932:8-9 O)
        (Identifier 932:11-12 K)
        (Identifier 932:14-15 V)
      ])
    (Merge 932:19-31
      (Merge 932:19-20
        (Object 932:19-20 [])
        (Identifier 932:23-24 O))
      (Object 932:26-31 [
        (ObjectPair (Identifier 932:26-27 K) (Identifier 932:29-30 V))
      ])))
  
  (DeclareGlobal 936:0-61
    (Function 936:0-36
      (Identifier 936:0-14 Ast.Precedence) [
        (Identifier 936:15-21 OpNode)
        (Identifier 936:23-35 BindingPower)
      ])
    (Array 936:39-61 [
      (Identifier 936:40-46 OpNode)
      (Identifier 936:48-60 BindingPower)
    ]))
  
  (DeclareGlobal 938:0-114
    (Function 938:0-64
      (Identifier 938:0-19 Ast.InfixPrecedence) [
        (Identifier 938:20-26 OpNode)
        (Identifier 938:28-44 LeftBindingPower)
        (Identifier 938:46-63 RightBindingPower)
      ])
    (Array 939:2-47 [
      (Identifier 939:3-9 OpNode)
      (Identifier 939:11-27 LeftBindingPower)
      (Identifier 939:29-46 RightBindingPower)
    ]))
  
  (DeclareGlobal 943:0-28
    (Function 943:0-12
      (Identifier 943:0-9 Is.String) [
        (Identifier 943:10-11 V)
      ])
    (Destructure 943:15-28
      (Identifier 943:15-16 V)
      (Merge 943:20-28
        (String 943:21-23 "")
        (Identifier 943:26-27 _))))
  
  (DeclareGlobal 945:0-27
    (Function 945:0-12
      (Identifier 945:0-9 Is.Number) [
        (Identifier 945:10-11 V)
      ])
    (Destructure 945:15-27
      (Identifier 945:15-16 V)
      (Merge 945:20-27
        (NumberString 945:21-22 0)
        (Identifier 945:25-26 _))))
  
  (DeclareGlobal 947:0-29
    (Function 947:0-10
      (Identifier 947:0-7 Is.Bool) [
        (Identifier 947:8-9 V)
      ])
    (Destructure 947:13-29
      (Identifier 947:13-14 V)
      (Merge 947:18-29
        (False 947:19-24)
        (Identifier 947:27-28 _))))
  
  (DeclareGlobal 949:0-22
    (Function 949:0-10
      (Identifier 949:0-7 Is.Null) [
        (Identifier 949:8-9 V)
      ])
    (Destructure 949:13-22
      (Identifier 949:13-14 V)
      (Null 949:18-22)))
  
  (DeclareGlobal 951:0-25
    (Function 951:0-11
      (Identifier 951:0-8 Is.Array) [
        (Identifier 951:9-10 V)
      ])
    (Destructure 951:14-25
      (Identifier 951:14-15 V)
      (Merge 951:19-25
        (Array 951:19-20 [])
        (Identifier 951:23-24 _))))
  
  (DeclareGlobal 953:0-26
    (Function 953:0-12
      (Identifier 953:0-9 Is.Object) [
        (Identifier 953:10-11 V)
      ])
    (Destructure 953:15-26
      (Identifier 953:15-16 V)
      (Merge 953:20-26
        (Object 953:20-21 [])
        (Identifier 953:24-25 _))))
  
  (DeclareGlobal 955:0-23
    (Function 955:0-14
      (Identifier 955:0-8 Is.Equal) [
        (Identifier 955:9-10 A)
        (Identifier 955:12-13 B)
      ])
    (Destructure 955:17-23
      (Identifier 955:17-18 A)
      (Identifier 955:22-23 B)))
  
  (DeclareGlobal 957:0-45
    (Function 957:0-17
      (Identifier 957:0-11 Is.LessThan) [
        (Identifier 957:12-13 A)
        (Identifier 957:15-16 B)
      ])
    (Conditional 957:20-45
      (Destructure 957:20-26
        (Identifier 957:20-21 A)
        (Identifier 957:25-26 B))
      (Identifier 957:29-34 @Fail)
      (Destructure 957:37-45
        (Identifier 957:37-38 A)
        (Range 957:42-45 () (Identifier 957:44-45 B)))))
  
  (DeclareGlobal 959:0-35
    (Function 959:0-24
      (Identifier 959:0-18 Is.LessThanOrEqual) [
        (Identifier 959:19-20 A)
        (Identifier 959:22-23 B)
      ])
    (Destructure 959:27-35
      (Identifier 959:27-28 A)
      (Range 959:32-35 () (Identifier 959:34-35 B))))
  
  (DeclareGlobal 961:0-48
    (Function 961:0-20
      (Identifier 961:0-14 Is.GreaterThan) [
        (Identifier 961:15-16 A)
        (Identifier 961:18-19 B)
      ])
    (Conditional 961:23-48
      (Destructure 961:23-29
        (Identifier 961:23-24 A)
        (Identifier 961:28-29 B))
      (Identifier 961:32-37 @Fail)
      (Destructure 961:40-48
        (Identifier 961:40-41 A)
        (Range 961:45-48 (Identifier 961:45-46 B) ()))))
  
  (DeclareGlobal 963:0-38
    (Function 963:0-27
      (Identifier 963:0-21 Is.GreaterThanOrEqual) [
        (Identifier 963:22-23 A)
        (Identifier 963:25-26 B)
      ])
    (Destructure 963:30-38
      (Identifier 963:30-31 A)
      (Range 963:35-38 (Identifier 963:35-36 B) ())))
  
  (DeclareGlobal 967:0-51
    (Function 967:0-12
      (Identifier 967:0-9 As.Number) [
        (Identifier 967:10-11 V)
      ])
    (Or 967:15-51
      (Function 967:15-27
        (Identifier 967:15-24 Is.Number) [
          (Identifier 967:25-26 V)
        ])
      (Return 967:30-51
        (Destructure 967:31-46
          (Identifier 967:31-32 V)
          (StringTemplate 967:36-46 [
            (Merge 967:39-44
              (NumberString 967:39-40 0)
              (Identifier 967:43-44 N))
          ]))
        (Identifier 967:49-50 N))))
  
  (DeclareGlobal 969:0-21
    (Function 969:0-12
      (Identifier 969:0-9 As.String) [
        (Identifier 969:10-11 V)
      ])
    (StringTemplate 969:15-21 [
      (Identifier 969:18-19 V)
    ]))

