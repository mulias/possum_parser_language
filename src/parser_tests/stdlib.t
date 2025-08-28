  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i ''
  (DeclareGlobal 5:0-19
    (ParserVar 5:0-4 char)
    (Range 5:7-19 (String 5:7-17 "\x00") ())) (esc)
  
  (DeclareGlobal 7:0-30
    (ParserVar 7:0-5 ascii)
    (Range 7:8-30 (String 7:8-18 "\x00") (String 7:20-30 "\x7f"))) (esc)
  
  (DeclareGlobal 9:0-27
    (ParserVar 9:0-5 alpha)
    (Or 9:8-27
      (Range 9:8-16 (String 9:8-11 "a") (String 9:13-16 "z"))
      (Range 9:19-27 (String 9:19-22 "A") (String 9:24-27 "Z"))))
  
  (DeclareGlobal 11:0-20
    (ParserVar 11:0-6 alphas)
    (Function 11:9-20
      (ParserVar 11:9-13 many) [
        (ParserVar 11:14-19 alpha)
      ]))
  
  (DeclareGlobal 13:0-16
    (ParserVar 13:0-5 lower)
    (Range 13:8-16 (String 13:8-11 "a") (String 13:13-16 "z")))
  
  (DeclareGlobal 15:0-20
    (ParserVar 15:0-6 lowers)
    (Function 15:9-20
      (ParserVar 15:9-13 many) [
        (ParserVar 15:14-19 lower)
      ]))
  
  (DeclareGlobal 17:0-16
    (ParserVar 17:0-5 upper)
    (Range 17:8-16 (String 17:8-11 "A") (String 17:13-16 "Z")))
  
  (DeclareGlobal 19:0-20
    (ParserVar 19:0-6 uppers)
    (Function 19:9-20
      (ParserVar 19:9-13 many) [
        (ParserVar 19:14-19 upper)
      ]))
  
  (DeclareGlobal 21:0-18
    (ParserVar 21:0-7 numeral)
    (Range 21:10-18 (String 21:10-13 "0") (String 21:15-18 "9")))
  
  (DeclareGlobal 23:0-24
    (ParserVar 23:0-8 numerals)
    (Function 23:11-24
      (ParserVar 23:11-15 many) [
        (ParserVar 23:16-23 numeral)
      ]))
  
  (DeclareGlobal 25:0-26
    (ParserVar 25:0-14 binary_numeral)
    (Or 25:17-26
      (String 25:17-20 "0")
      (String 25:23-26 "1")))
  
  (DeclareGlobal 27:0-24
    (ParserVar 27:0-13 octal_numeral)
    (Range 27:16-24 (String 27:16-19 "0") (String 27:21-24 "7")))
  
  (DeclareGlobal 29:0-43
    (ParserVar 29:0-11 hex_numeral)
    (Or 29:14-43
      (ParserVar 29:14-21 numeral)
      (Or 29:24-43
        (Range 29:24-32 (String 29:24-27 "a") (String 29:29-32 "f"))
        (Range 29:35-43 (String 29:35-38 "A") (String 29:40-43 "F")))))
  
  (DeclareGlobal 31:0-23
    (ParserVar 31:0-5 alnum)
    (Or 31:8-23
      (ParserVar 31:8-13 alpha)
      (ParserVar 31:16-23 numeral)))
  
  (DeclareGlobal 33:0-20
    (ParserVar 33:0-6 alnums)
    (Function 33:9-20
      (ParserVar 33:9-13 many) [
        (ParserVar 33:14-19 alnum)
      ]))
  
  (DeclareGlobal 35:0-38
    (ParserVar 35:0-5 token)
    (Function 35:8-38
      (ParserVar 35:8-12 many) [
        (Function 35:13-37
          (ParserVar 35:13-19 unless) [
            (ParserVar 35:20-24 char)
            (ParserVar 35:26-36 whitespace)
          ])
      ]))
  
  (DeclareGlobal 37:0-30
    (ParserVar 37:0-4 word)
    (Function 37:7-30
      (ParserVar 37:7-11 many) [
        (Or 37:12-29
          (ParserVar 37:12-17 alnum)
          (Or 37:20-29
            (String 37:20-23 "_")
            (String 37:26-29 "-")))
      ]))
  
  (DeclareGlobal 39:0-42
    (ParserVar 39:0-4 line)
    (Function 39:7-42
      (ParserVar 39:7-18 chars_until) [
        (Or 39:19-41
          (ParserVar 39:19-26 newline)
          (ParserVar 39:29-41 end_of_input))
      ]))
  
  (DeclareGlobal 41:0-97
    (ParserVar 41:0-5 space)
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
    (ParserVar 44:0-6 spaces)
    (Function 44:9-20
      (ParserVar 44:9-13 many) [
        (ParserVar 44:14-19 space)
      ]))
  
  (DeclareGlobal 46:0-80
    (ParserVar 46:0-7 newline)
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
    (ParserVar 48:0-2 nl)
    (ParserVar 48:5-12 newline))
  
  (DeclareGlobal 50:0-24
    (ParserVar 50:0-8 newlines)
    (Function 50:11-24
      (ParserVar 50:11-15 many) [
        (ParserVar 50:16-23 newline)
      ]))
  
  (DeclareGlobal 52:0-14
    (ParserVar 52:0-3 nls)
    (ParserVar 52:6-14 newlines))
  
  (DeclareGlobal 54:0-34
    (ParserVar 54:0-10 whitespace)
    (Function 54:13-34
      (ParserVar 54:13-17 many) [
        (Or 54:18-33
          (ParserVar 54:18-23 space)
          (ParserVar 54:26-33 newline))
      ]))
  
  (DeclareGlobal 56:0-15
    (ParserVar 56:0-2 ws)
    (ParserVar 56:5-15 whitespace))
  
  (DeclareGlobal 58:0-42
    (Function 58:0-17
      (ParserVar 58:0-11 chars_until) [
        (ParserVar 58:12-16 stop)
      ])
    (Function 58:20-42
      (ParserVar 58:20-30 many_until) [
        (ParserVar 58:31-35 char)
        (ParserVar 58:37-41 stop)
      ]))
  
  (DeclareGlobal 62:0-12
    (ParserVar 62:0-5 digit)
    (Range 62:8-12 (NumberString 62:8-9 0) (NumberString 62:11-12 9)))
  
  (DeclareGlobal 64:0-54
    (ParserVar 64:0-7 integer)
    (Function 64:10-54
      (ParserVar 64:10-19 as_number) [
        (Merge 64:20-53
          (Function 64:20-30
            (ParserVar 64:20-25 maybe) [
              (String 64:26-29 "-")
            ])
          (ParserVar 64:33-53 _number_integer_part))
      ]))
  
  (DeclareGlobal 66:0-13
    (ParserVar 66:0-3 int)
    (ParserVar 66:6-13 integer))
  
  (DeclareGlobal 68:0-54
    (ParserVar 68:0-20 non_negative_integer)
    (Function 68:23-54
      (ParserVar 68:23-32 as_number) [
        (ParserVar 68:33-53 _number_integer_part)
      ]))
  
  (DeclareGlobal 70:0-56
    (ParserVar 70:0-16 negative_integer)
    (Function 70:19-56
      (ParserVar 70:19-28 as_number) [
        (Merge 70:29-55
          (String 70:29-32 "-")
          (ParserVar 70:35-55 _number_integer_part))
      ]))
  
  (DeclareGlobal 72:0-76
    (ParserVar 72:0-5 float)
    (Function 72:8-76
      (ParserVar 72:8-17 as_number) [
        (Merge 72:18-75
          (Merge 72:18-51
            (Function 72:18-28
              (ParserVar 72:18-23 maybe) [
                (String 72:24-27 "-")
              ])
            (ParserVar 72:31-51 _number_integer_part))
          (ParserVar 72:54-75 _number_fraction_part))
      ]))
  
  (DeclareGlobal 74:0-97
    (ParserVar 74:0-18 scientific_integer)
    (Function 74:21-97
      (ParserVar 74:21-30 as_number) [
        (Merge 75:2-63
          (Merge 75:2-37
            (Function 75:2-12
              (ParserVar 75:2-7 maybe) [
                (String 75:8-11 "-")
              ])
            (ParserVar 76:2-22 _number_integer_part))
          (ParserVar 77:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 80:0-121
    (ParserVar 80:0-16 scientific_float)
    (Function 80:19-121
      (ParserVar 80:19-28 as_number) [
        (Merge 81:2-89
          (Merge 81:2-63
            (Merge 81:2-37
              (Function 81:2-12
                (ParserVar 81:2-7 maybe) [
                  (String 81:8-11 "-")
                ])
              (ParserVar 82:2-22 _number_integer_part))
            (ParserVar 83:2-23 _number_fraction_part))
          (ParserVar 84:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 87:0-125
    (ParserVar 87:0-6 number)
    (Function 87:9-125
      (ParserVar 87:9-18 as_number) [
        (Merge 88:2-103
          (Merge 88:2-70
            (Merge 88:2-37
              (Function 88:2-12
                (ParserVar 88:2-7 maybe) [
                  (String 88:8-11 "-")
                ])
              (ParserVar 89:2-22 _number_integer_part))
            (Function 90:2-30
              (ParserVar 90:2-7 maybe) [
                (ParserVar 90:8-29 _number_fraction_part)
              ]))
          (Function 91:2-30
            (ParserVar 91:2-7 maybe) [
              (ParserVar 91:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 94:0-12
    (ParserVar 94:0-3 num)
    (ParserVar 94:6-12 number))
  
  (DeclareGlobal 96:0-123
    (ParserVar 96:0-19 non_negative_number)
    (Function 96:22-123
      (ParserVar 96:22-31 as_number) [
        (Merge 97:2-88
          (Merge 97:2-55
            (ParserVar 97:2-22 _number_integer_part)
            (Function 98:2-30
              (ParserVar 98:2-7 maybe) [
                (ParserVar 98:8-29 _number_fraction_part)
              ]))
          (Function 99:2-30
            (ParserVar 99:2-7 maybe) [
              (ParserVar 99:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 102:0-127
    (ParserVar 102:0-15 negative_number)
    (Function 102:18-127
      (ParserVar 102:18-27 as_number) [
        (Merge 103:2-96
          (Merge 103:2-63
            (Merge 103:2-30
              (String 103:2-5 "-")
              (ParserVar 104:2-22 _number_integer_part))
            (Function 105:2-30
              (ParserVar 105:2-7 maybe) [
                (ParserVar 105:8-29 _number_fraction_part)
              ]))
          (Function 106:2-30
            (ParserVar 106:2-7 maybe) [
              (ParserVar 106:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 109:0-54
    (ParserVar 109:0-20 _number_integer_part)
    (Or 109:23-54
      (Merge 109:23-44
        (Range 109:24-32 (String 109:24-27 "1") (String 109:29-32 "9"))
        (ParserVar 109:35-43 numerals))
      (ParserVar 109:47-54 numeral)))
  
  (DeclareGlobal 111:0-38
    (ParserVar 111:0-21 _number_fraction_part)
    (Merge 111:24-38
      (String 111:24-27 ".")
      (ParserVar 111:30-38 numerals)))
  
  (DeclareGlobal 113:0-65
    (ParserVar 113:0-21 _number_exponent_part)
    (Merge 113:24-65
      (Merge 113:24-54
        (Or 113:24-35
          (String 113:25-28 "e")
          (String 113:31-34 "E"))
        (Function 113:38-54
          (ParserVar 113:38-43 maybe) [
            (Or 113:44-53
              (String 113:44-47 "-")
              (String 113:50-53 "+"))
          ]))
      (ParserVar 113:57-65 numerals)))
  
  (DeclareGlobal 115:0-19
    (ParserVar 115:0-12 binary_digit)
    (Range 115:15-19 (NumberString 115:15-16 0) (NumberString 115:18-19 1)))
  
  (DeclareGlobal 117:0-18
    (ParserVar 117:0-11 octal_digit)
    (Range 117:14-18 (NumberString 117:14-15 0) (NumberString 117:17-18 7)))
  
  (DeclareGlobal 119:0-145
    (ParserVar 119:0-9 hex_digit)
    (Or 120:2-133
      (ParserVar 120:2-7 digit)
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
    (ParserVar 128:0-14 binary_integer)
    (Return 128:17-77
      (Destructure 128:17-46
        (Function 128:17-36
          (ParserVar 128:17-22 array) [
            (ParserVar 128:23-35 binary_digit)
          ])
        (ValueVar 128:40-46 Digits))
      (Function 128:49-77
        (ValueVar 128:49-69 Num.FromBinaryDigits) [
          (ValueVar 128:70-76 Digits)
        ])))
  
  (DeclareGlobal 130:0-74
    (ParserVar 130:0-13 octal_integer)
    (Return 130:16-74
      (Destructure 130:16-44
        (Function 130:16-34
          (ParserVar 130:16-21 array) [
            (ParserVar 130:22-33 octal_digit)
          ])
        (ValueVar 130:38-44 Digits))
      (Function 130:47-74
        (ValueVar 130:47-66 Num.FromOctalDigits) [
          (ValueVar 130:67-73 Digits)
        ])))
  
  (DeclareGlobal 132:0-68
    (ParserVar 132:0-11 hex_integer)
    (Return 132:14-68
      (Destructure 132:14-40
        (Function 132:14-30
          (ParserVar 132:14-19 array) [
            (ParserVar 132:20-29 hex_digit)
          ])
        (ValueVar 132:34-40 Digits))
      (Function 132:43-68
        (ValueVar 132:43-60 Num.FromHexDigits) [
          (ValueVar 132:61-67 Digits)
        ])))
  
  (DeclareGlobal 136:0-18
    (Function 136:0-7
      (True 136:0-4) [
        (ParserVar 136:5-6 t)
      ])
    (Return 136:10-18
      (ParserVar 136:10-11 t)
      (True 136:14-18)))
  
  (DeclareGlobal 138:0-20
    (Function 138:0-8
      (False 138:0-5) [
        (ParserVar 138:6-7 f)
      ])
    (Return 138:11-20
      (ParserVar 138:11-12 f)
      (False 138:15-20)))
  
  (DeclareGlobal 140:0-34
    (Function 140:0-13
      (ParserVar 140:0-7 boolean) [
        (ParserVar 140:8-9 t)
        (ParserVar 140:11-12 f)
      ])
    (Or 140:16-34
      (Function 140:16-23
        (True 140:16-20) [
          (ParserVar 140:21-22 t)
        ])
      (Function 140:26-34
        (False 140:26-31) [
          (ParserVar 140:32-33 f)
        ])))
  
  (DeclareGlobal 142:0-14
    (ParserVar 142:0-4 bool)
    (ParserVar 142:7-14 boolean))
  
  (DeclareGlobal 144:0-18
    (Function 144:0-7
      (Null 144:0-4) [
        (ParserVar 144:5-6 n)
      ])
    (Return 144:10-18
      (ParserVar 144:10-11 n)
      (Null 144:14-18)))
  
  (DeclareGlobal 148:0-32
    (Function 148:0-11
      (ParserVar 148:0-5 array) [
        (ParserVar 148:6-10 elem)
      ])
    (Repeat 148:14-32
      (Function 148:14-26
        (ParserVar 148:14-20 tuple1) [
          (ParserVar 148:21-25 elem)
        ])
      (Range 148:29-32 (NumberString 148:29-30 1) ())))
  
  (DeclareGlobal 150:0-64
    (Function 150:0-20
      (ParserVar 150:0-9 array_sep) [
        (ParserVar 150:10-14 elem)
        (ParserVar 150:16-19 sep)
      ])
    (Merge 150:23-64
      (Function 150:23-35
        (ParserVar 150:23-29 tuple1) [
          (ParserVar 150:30-34 elem)
        ])
      (Repeat 150:38-64
        (Function 150:39-57
          (ParserVar 150:39-45 tuple1) [
            (TakeRight 150:46-56
              (ParserVar 150:46-49 sep)
              (ParserVar 150:52-56 elem))
          ])
        (Range 150:60-63 (NumberString 150:60-61 0) ()))))
  
  (DeclareGlobal 152:0-71
    (Function 152:0-23
      (ParserVar 152:0-11 array_until) [
        (ParserVar 152:12-16 elem)
        (ParserVar 152:18-22 stop)
      ])
    (TakeLeft 152:26-71
      (Repeat 152:26-58
        (Function 152:26-52
          (ParserVar 152:26-32 unless) [
            (Function 152:33-45
              (ParserVar 152:33-39 tuple1) [
                (ParserVar 152:40-44 elem)
              ])
            (ParserVar 152:47-51 stop)
          ])
        (Range 152:55-58 (NumberString 152:55-56 1) ()))
      (Function 152:61-71
        (ParserVar 152:61-65 peek) [
          (ParserVar 152:66-70 stop)
        ])))
  
  (DeclareGlobal 154:0-44
    (Function 154:0-17
      (ParserVar 154:0-11 maybe_array) [
        (ParserVar 154:12-16 elem)
      ])
    (Function 154:20-44
      (ParserVar 154:20-27 default) [
        (Function 154:28-39
          (ParserVar 154:28-33 array) [
            (ParserVar 154:34-38 elem)
          ])
        (Array 154:41-44 [])
      ]))
  
  (DeclareGlobal 156:0-62
    (Function 156:0-26
      (ParserVar 156:0-15 maybe_array_sep) [
        (ParserVar 156:16-20 elem)
        (ParserVar 156:22-25 sep)
      ])
    (Function 156:29-62
      (ParserVar 156:29-36 default) [
        (Function 156:37-57
          (ParserVar 156:37-46 array_sep) [
            (ParserVar 156:47-51 elem)
            (ParserVar 156:53-56 sep)
          ])
        (Array 156:59-62 [])
      ]))
  
  (DeclareGlobal 158:0-37
    (Function 158:0-12
      (ParserVar 158:0-6 tuple1) [
        (ParserVar 158:7-11 elem)
      ])
    (Return 158:16-37
      (Destructure 158:16-28
        (ParserVar 158:16-20 elem)
        (ValueVar 158:24-28 Elem))
      (Array 158:31-37 [
        (ValueVar 158:32-36 Elem)
      ])))
  
  (DeclareGlobal 160:0-59
    (Function 160:0-20
      (ParserVar 160:0-6 tuple2) [
        (ParserVar 160:7-12 elem1)
        (ParserVar 160:14-19 elem2)
      ])
    (TakeRight 160:23-59
      (Destructure 160:23-34
        (ParserVar 160:23-28 elem1)
        (ValueVar 160:32-34 E1))
      (Return 160:37-59
        (Destructure 160:37-48
          (ParserVar 160:37-42 elem2)
          (ValueVar 160:46-48 E2))
        (Array 160:51-59 [
          (ValueVar 160:52-54 E1)
          (ValueVar 160:56-58 E2)
        ]))))
  
  (DeclareGlobal 162:0-74
    (Function 162:0-29
      (ParserVar 162:0-10 tuple2_sep) [
        (ParserVar 162:11-16 elem1)
        (ParserVar 162:18-21 sep)
        (ParserVar 162:23-28 elem2)
      ])
    (TakeRight 162:32-74
      (TakeRight 162:32-49
        (Destructure 162:32-43
          (ParserVar 162:32-37 elem1)
          (ValueVar 162:41-43 E1))
        (ParserVar 162:46-49 sep))
      (Return 162:52-74
        (Destructure 162:52-63
          (ParserVar 162:52-57 elem2)
          (ValueVar 162:61-63 E2))
        (Array 162:66-74 [
          (ValueVar 162:67-69 E1)
          (ValueVar 162:71-73 E2)
        ]))))
  
  (DeclareGlobal 164:0-92
    (Function 164:0-27
      (ParserVar 164:0-6 tuple3) [
        (ParserVar 164:7-12 elem1)
        (ParserVar 164:14-19 elem2)
        (ParserVar 164:21-26 elem3)
      ])
    (TakeRight 165:2-62
      (TakeRight 165:2-29
        (Destructure 165:2-13
          (ParserVar 165:2-7 elem1)
          (ValueVar 165:11-13 E1))
        (Destructure 166:2-13
          (ParserVar 166:2-7 elem2)
          (ValueVar 166:11-13 E2)))
      (Return 167:2-30
        (Destructure 167:2-13
          (ParserVar 167:2-7 elem3)
          (ValueVar 167:11-13 E3))
        (Array 168:2-14 [
          (ValueVar 168:3-5 E1)
          (ValueVar 168:7-9 E2)
          (ValueVar 168:11-13 E3)
        ]))))
  
  (DeclareGlobal 170:0-122
    (Function 170:0-43
      (ParserVar 170:0-10 tuple3_sep) [
        (ParserVar 170:11-16 elem1)
        (ParserVar 170:18-22 sep1)
        (ParserVar 170:24-29 elem2)
        (ParserVar 170:31-35 sep2)
        (ParserVar 170:37-42 elem3)
      ])
    (TakeRight 171:2-76
      (TakeRight 171:2-43
        (TakeRight 171:2-36
          (TakeRight 171:2-20
            (Destructure 171:2-13
              (ParserVar 171:2-7 elem1)
              (ValueVar 171:11-13 E1))
            (ParserVar 171:16-20 sep1))
          (Destructure 172:2-13
            (ParserVar 172:2-7 elem2)
            (ValueVar 172:11-13 E2)))
        (ParserVar 172:16-20 sep2))
      (Return 173:2-30
        (Destructure 173:2-13
          (ParserVar 173:2-7 elem3)
          (ValueVar 173:11-13 E3))
        (Array 174:2-14 [
          (ValueVar 174:3-5 E1)
          (ValueVar 174:7-9 E2)
          (ValueVar 174:11-13 E3)
        ]))))
  
  (DeclareGlobal 176:0-33
    (Function 176:0-14
      (ParserVar 176:0-5 tuple) [
        (ParserVar 176:6-10 elem)
        (ValueVar 176:12-13 N)
      ])
    (Repeat 176:17-33
      (Function 176:17-29
        (ParserVar 176:17-23 tuple1) [
          (ParserVar 176:24-28 elem)
        ])
      (ValueVar 176:32-33 N)))
  
  (DeclareGlobal 178:0-71
    (Function 178:0-23
      (ParserVar 178:0-9 tuple_sep) [
        (ParserVar 178:10-14 elem)
        (ParserVar 178:16-19 sep)
        (ValueVar 178:21-22 N)
      ])
    (Merge 178:26-71
      (Function 178:26-38
        (ParserVar 178:26-32 tuple1) [
          (ParserVar 178:33-37 elem)
        ])
      (Repeat 178:41-71
        (Function 178:42-60
          (ParserVar 178:42-48 tuple1) [
            (TakeRight 178:49-59
              (ParserVar 178:49-52 sep)
              (ParserVar 178:55-59 elem))
          ])
        (NumberSubtract 178:63-70
          (ValueVar 178:64-65 N)
          (NumberString 178:68-69 1)))))
  
  (DeclareGlobal 180:0-120
    (Function 180:0-28
      (ParserVar 180:0-4 rows) [
        (ParserVar 180:5-9 elem)
        (ParserVar 180:11-18 col_sep)
        (ParserVar 180:20-27 row_sep)
      ])
    (Merge 181:2-89
      (Function 181:2-34
        (ParserVar 181:2-8 tuple1) [
          (Function 181:9-33
            (ParserVar 181:9-18 array_sep) [
              (ParserVar 181:19-23 elem)
              (ParserVar 181:25-32 col_sep)
            ])
        ])
      (Repeat 182:2-52
        (Function 182:3-45
          (ParserVar 182:3-9 tuple1) [
            (TakeRight 182:10-44
              (ParserVar 182:10-17 row_sep)
              (Function 182:20-44
                (ParserVar 182:20-29 array_sep) [
                  (ParserVar 182:30-34 elem)
                  (ParserVar 182:36-43 col_sep)
                ]))
          ])
        (Range 182:48-51 (NumberString 182:48-49 0) ()))))
  
  (DeclareGlobal 184:0-194
    (Function 184:0-40
      (ParserVar 184:0-11 rows_padded) [
        (ParserVar 184:12-16 elem)
        (ParserVar 184:18-25 col_sep)
        (ParserVar 184:27-34 row_sep)
        (ValueVar 184:36-39 Pad)
      ])
    (TakeRight 185:2-151
      (TakeRight 185:2-79
        (Destructure 185:2-61
          (Function 185:2-43
            (ParserVar 185:2-6 peek) [
              (Function 185:7-42
                (ParserVar 185:7-18 _dimensions) [
                  (ParserVar 185:19-23 elem)
                  (ParserVar 185:25-32 col_sep)
                  (ParserVar 185:34-41 row_sep)
                ])
            ])
          (Array 185:47-61 [
            (ValueVar 185:48-57 MaxRowLen)
            (ValueVar 185:59-60 _)
          ]))
        (Destructure 186:2-15
          (ParserVar 186:2-6 elem)
          (ValueVar 186:10-15 First)))
      (Function 186:18-87
        (ParserVar 186:18-30 _rows_padded) [
          (ParserVar 186:31-35 elem)
          (ParserVar 186:37-44 col_sep)
          (ParserVar 186:46-53 row_sep)
          (ValueVar 186:55-58 Pad)
          (ValueLabel 186:60-61 (NumberString 186:61-62 1))
          (ValueVar 186:64-73 MaxRowLen)
          (Array 186:75-82 [
            (ValueVar 186:76-81 First)
          ])
          (Array 186:84-87 [])
        ])))
  
  (DeclareGlobal 188:0-442
    (Function 188:0-77
      (ParserVar 188:0-12 _rows_padded) [
        (ParserVar 188:13-17 elem)
        (ParserVar 188:19-26 col_sep)
        (ParserVar 188:28-35 row_sep)
        (ValueVar 188:37-40 Pad)
        (ValueVar 188:42-48 RowLen)
        (ValueVar 188:50-59 MaxRowLen)
        (ValueVar 188:61-67 AccRow)
        (ValueVar 188:69-76 AccRows)
      ])
    (Conditional 189:2-362
      (Destructure 189:2-24
        (TakeRight 189:2-16
          (ParserVar 189:2-9 col_sep)
          (ParserVar 189:12-16 elem))
        (ValueVar 189:20-24 Elem))
      (Function 190:2-99
        (ParserVar 190:2-14 _rows_padded) [
          (ParserVar 190:15-19 elem)
          (ParserVar 190:21-28 col_sep)
          (ParserVar 190:30-37 row_sep)
          (ValueVar 190:39-42 Pad)
          (Function 190:44-59
            (ValueVar 190:44-51 Num.Inc) [
              (ValueVar 190:52-58 RowLen)
            ])
          (ValueVar 190:61-70 MaxRowLen)
          (Merge 190:72-89
            (Merge 190:72-73
              (Array 190:72-73 [])
              (ValueVar 190:76-82 AccRow))
            (Array 190:84-89 [
              (ValueVar 190:84-88 Elem)
            ]))
          (ValueVar 190:91-98 AccRows)
        ])
      (Conditional 191:2-233
        (Destructure 191:2-27
          (TakeRight 191:2-16
            (ParserVar 191:2-9 row_sep)
            (ParserVar 191:12-16 elem))
          (ValueVar 191:20-27 NextRow))
        (Function 192:2-131
          (ParserVar 192:2-14 _rows_padded) [
            (ParserVar 192:15-19 elem)
            (ParserVar 192:21-28 col_sep)
            (ParserVar 192:30-37 row_sep)
            (ValueVar 192:39-42 Pad)
            (ValueLabel 192:44-45 (NumberString 192:45-46 1))
            (ValueVar 192:48-57 MaxRowLen)
            (Array 192:59-68 [
              (ValueVar 192:60-67 NextRow)
            ])
            (Merge 192:70-130
              (Merge 192:70-71
                (Array 192:70-71 [])
                (ValueVar 192:74-81 AccRows))
              (Array 192:83-130 [
                (Function 192:83-129
                  (ValueVar 192:83-96 Array.AppendN) [
                    (ValueVar 192:97-103 AccRow)
                    (ValueVar 192:105-108 Pad)
                    (NumberSubtract 192:110-128
                      (ValueVar 192:110-119 MaxRowLen)
                      (ValueVar 192:122-128 RowLen))
                  ])
              ]))
          ])
        (Function 193:2-69
          (ParserVar 193:2-7 const) [
            (Merge 193:8-68
              (Merge 193:8-9
                (Array 193:8-9 [])
                (ValueVar 193:12-19 AccRows))
              (Array 193:21-68 [
                (Function 193:21-67
                  (ValueVar 193:21-34 Array.AppendN) [
                    (ValueVar 193:35-41 AccRow)
                    (ValueVar 193:43-46 Pad)
                    (NumberSubtract 193:48-66
                      (ValueVar 193:48-57 MaxRowLen)
                      (ValueVar 193:60-66 RowLen))
                  ])
              ]))
          ]))))
  
  (DeclareGlobal 195:0-95
    (Function 195:0-35
      (ParserVar 195:0-11 _dimensions) [
        (ParserVar 195:12-16 elem)
        (ParserVar 195:18-25 col_sep)
        (ParserVar 195:27-34 row_sep)
      ])
    (TakeRight 196:2-57
      (ParserVar 196:2-6 elem)
      (Function 196:9-57
        (ParserVar 196:9-21 __dimensions) [
          (ParserVar 196:22-26 elem)
          (ParserVar 196:28-35 col_sep)
          (ParserVar 196:37-44 row_sep)
          (ValueLabel 196:46-47 (NumberString 196:47-48 1))
          (ValueLabel 196:50-51 (NumberString 196:51-52 1))
          (ValueLabel 196:54-55 (NumberString 196:55-56 0))
        ])))
  
  (DeclareGlobal 198:0-316
    (Function 198:0-63
      (ParserVar 198:0-12 __dimensions) [
        (ParserVar 198:13-17 elem)
        (ParserVar 198:19-26 col_sep)
        (ParserVar 198:28-35 row_sep)
        (ValueVar 198:37-43 RowLen)
        (ValueVar 198:45-51 ColLen)
        (ValueVar 198:53-62 MaxRowLen)
      ])
    (Conditional 199:2-250
      (TakeRight 199:2-16
        (ParserVar 199:2-9 col_sep)
        (ParserVar 199:12-16 elem))
      (Function 200:2-74
        (ParserVar 200:2-14 __dimensions) [
          (ParserVar 200:15-19 elem)
          (ParserVar 200:21-28 col_sep)
          (ParserVar 200:30-37 row_sep)
          (Function 200:39-54
            (ValueVar 200:39-46 Num.Inc) [
              (ValueVar 200:47-53 RowLen)
            ])
          (ValueVar 200:56-62 ColLen)
          (ValueVar 200:64-73 MaxRowLen)
        ])
      (Conditional 201:2-154
        (TakeRight 201:2-16
          (ParserVar 201:2-9 row_sep)
          (ParserVar 201:12-16 elem))
        (Function 202:2-87
          (ParserVar 202:2-14 __dimensions) [
            (ParserVar 202:15-19 elem)
            (ParserVar 202:21-28 col_sep)
            (ParserVar 202:30-37 row_sep)
            (ValueLabel 202:39-40 (NumberString 202:40-41 1))
            (Function 202:43-58
              (ValueVar 202:43-50 Num.Inc) [
                (ValueVar 202:51-57 ColLen)
              ])
            (Function 202:60-86
              (ValueVar 202:60-67 Num.Max) [
                (ValueVar 202:68-74 RowLen)
                (ValueVar 202:76-85 MaxRowLen)
              ])
          ])
        (Function 203:2-45
          (ParserVar 203:2-7 const) [
            (Array 203:8-44 [
              (Function 203:9-35
                (ValueVar 203:9-16 Num.Max) [
                  (ValueVar 203:17-23 RowLen)
                  (ValueVar 203:25-34 MaxRowLen)
                ])
              (ValueVar 203:37-43 ColLen)
            ])
          ]))))
  
  (DeclareGlobal 205:0-98
    (Function 205:0-31
      (ParserVar 205:0-7 columns) [
        (ParserVar 205:8-12 elem)
        (ParserVar 205:14-21 col_sep)
        (ParserVar 205:23-30 row_sep)
      ])
    (Return 206:2-64
      (Destructure 206:2-38
        (Function 206:2-30
          (ParserVar 206:2-6 rows) [
            (ParserVar 206:7-11 elem)
            (ParserVar 206:13-20 col_sep)
            (ParserVar 206:22-29 row_sep)
          ])
        (ValueVar 206:34-38 Rows))
      (Function 207:2-23
        (ValueVar 207:2-17 Table.Transpose) [
          (ValueVar 207:18-22 Rows)
        ])))
  
  (DeclareGlobal 209:0-14
    (ParserVar 209:0-4 cols)
    (ParserVar 209:7-14 columns))
  
  (DeclareGlobal 211:0-122
    (Function 211:0-43
      (ParserVar 211:0-14 columns_padded) [
        (ParserVar 211:15-19 elem)
        (ParserVar 211:21-28 col_sep)
        (ParserVar 211:30-37 row_sep)
        (ValueVar 211:39-42 Pad)
      ])
    (Return 212:2-76
      (Destructure 212:2-50
        (Function 212:2-42
          (ParserVar 212:2-13 rows_padded) [
            (ParserVar 212:14-18 elem)
            (ParserVar 212:20-27 col_sep)
            (ParserVar 212:29-36 row_sep)
            (ValueVar 212:38-41 Pad)
          ])
        (ValueVar 212:46-50 Rows))
      (Function 213:2-23
        (ValueVar 213:2-17 Table.Transpose) [
          (ValueVar 213:18-22 Rows)
        ])))
  
  (DeclareGlobal 215:0-28
    (ParserVar 215:0-11 cols_padded)
    (ParserVar 215:14-28 columns_padded))
  
  (DeclareGlobal 219:0-43
    (Function 219:0-18
      (ParserVar 219:0-6 object) [
        (ParserVar 219:7-10 key)
        (ParserVar 219:12-17 value)
      ])
    (Repeat 219:21-43
      (Function 219:21-37
        (ParserVar 219:21-25 pair) [
          (ParserVar 219:26-29 key)
          (ParserVar 219:31-36 value)
        ])
      (Range 219:40-43 (NumberString 219:40-41 1) ())))
  
  (DeclareGlobal 221:0-117
    (Function 221:0-35
      (ParserVar 221:0-10 object_sep) [
        (ParserVar 221:11-14 key)
        (ParserVar 221:16-22 kv_sep)
        (ParserVar 221:24-29 value)
        (ParserVar 221:31-34 sep)
      ])
    (Merge 222:2-79
      (Function 222:2-30
        (ParserVar 222:2-10 pair_sep) [
          (ParserVar 222:11-14 key)
          (ParserVar 222:16-22 kv_sep)
          (ParserVar 222:24-29 value)
        ])
      (Repeat 223:2-46
        (TakeRight 223:3-39
          (ParserVar 223:4-7 sep)
          (Function 223:10-38
            (ParserVar 223:10-18 pair_sep) [
              (ParserVar 223:19-22 key)
              (ParserVar 223:24-30 kv_sep)
              (ParserVar 223:32-37 value)
            ]))
        (Range 223:42-45 (NumberString 223:42-43 0) ()))))
  
  (DeclareGlobal 225:0-84
    (Function 225:0-30
      (ParserVar 225:0-12 object_until) [
        (ParserVar 225:13-16 key)
        (ParserVar 225:18-23 value)
        (ParserVar 225:25-29 stop)
      ])
    (TakeLeft 226:2-51
      (Repeat 226:2-38
        (Function 226:2-32
          (ParserVar 226:2-8 unless) [
            (Function 226:9-25
              (ParserVar 226:9-13 pair) [
                (ParserVar 226:14-17 key)
                (ParserVar 226:19-24 value)
              ])
            (ParserVar 226:27-31 stop)
          ])
        (Range 226:35-38 (NumberString 226:35-36 1) ()))
      (Function 226:41-51
        (ParserVar 226:41-45 peek) [
          (ParserVar 226:46-50 stop)
        ])))
  
  (DeclareGlobal 228:0-58
    (Function 228:0-24
      (ParserVar 228:0-12 maybe_object) [
        (ParserVar 228:13-16 key)
        (ParserVar 228:18-23 value)
      ])
    (Function 228:27-58
      (ParserVar 228:27-34 default) [
        (Function 228:35-53
          (ParserVar 228:35-41 object) [
            (ParserVar 228:42-45 key)
            (ParserVar 228:47-52 value)
          ])
        (Object 228:55-58 [])
      ]))
  
  (DeclareGlobal 230:0-98
    (Function 230:0-43
      (ParserVar 230:0-16 maybe_object_sep) [
        (ParserVar 230:17-20 key)
        (ParserVar 230:22-30 pair_sep)
        (ParserVar 230:32-37 value)
        (ParserVar 230:39-42 sep)
      ])
    (Function 231:2-52
      (ParserVar 231:2-9 default) [
        (Function 231:10-47
          (ParserVar 231:10-20 object_sep) [
            (ParserVar 231:21-24 key)
            (ParserVar 231:26-34 pair_sep)
            (ParserVar 231:36-41 value)
            (ParserVar 231:43-46 sep)
          ])
        (Object 231:49-52 [])
      ]))
  
  (DeclareGlobal 233:0-49
    (Function 233:0-16
      (ParserVar 233:0-4 pair) [
        (ParserVar 233:5-8 key)
        (ParserVar 233:10-15 value)
      ])
    (TakeRight 233:19-49
      (Destructure 233:19-27
        (ParserVar 233:19-22 key)
        (ValueVar 233:26-27 K))
      (Return 233:30-49
        (Destructure 233:30-40
          (ParserVar 233:30-35 value)
          (ValueVar 233:39-40 V))
        (Object 233:43-49 [
          (ObjectPair (ValueVar 233:44-45 K) (ValueVar 233:47-48 V))
        ]))))
  
  (DeclareGlobal 235:0-64
    (Function 235:0-25
      (ParserVar 235:0-8 pair_sep) [
        (ParserVar 235:9-12 key)
        (ParserVar 235:14-17 sep)
        (ParserVar 235:19-24 value)
      ])
    (TakeRight 235:28-64
      (TakeRight 235:28-42
        (Destructure 235:28-36
          (ParserVar 235:28-31 key)
          (ValueVar 235:35-36 K))
        (ParserVar 235:39-42 sep))
      (Return 235:45-64
        (Destructure 235:45-55
          (ParserVar 235:45-50 value)
          (ValueVar 235:54-55 V))
        (Object 235:58-64 [
          (ObjectPair (ValueVar 235:59-60 K) (ValueVar 235:62-63 V))
        ]))))
  
  (DeclareGlobal 237:0-51
    (Function 237:0-19
      (ParserVar 237:0-7 record1) [
        (ValueVar 237:8-11 Key)
        (ParserVar 237:13-18 value)
      ])
    (Return 237:22-51
      (Destructure 237:22-36
        (ParserVar 237:22-27 value)
        (ValueVar 237:31-36 Value))
      (Object 237:39-51 [
        (ObjectPair (ValueVar 237:40-43 Key) (ValueVar 237:45-50 Value))
      ])))
  
  (DeclareGlobal 239:0-94
    (Function 239:0-35
      (ParserVar 239:0-7 record2) [
        (ValueVar 239:8-12 Key1)
        (ParserVar 239:14-20 value1)
        (ValueVar 239:22-26 Key2)
        (ParserVar 239:28-34 value2)
      ])
    (TakeRight 240:2-56
      (Destructure 240:2-14
        (ParserVar 240:2-8 value1)
        (ValueVar 240:12-14 V1))
      (Return 241:2-39
        (Destructure 241:2-14
          (ParserVar 241:2-8 value2)
          (ValueVar 241:12-14 V2))
        (Object 242:2-22 [
          (ObjectPair (ValueVar 242:3-7 Key1) (ValueVar 242:9-11 V1))
          (ObjectPair (ValueVar 242:13-17 Key2) (ValueVar 242:19-21 V2))
        ]))))
  
  (DeclareGlobal 244:0-109
    (Function 244:0-44
      (ParserVar 244:0-11 record2_sep) [
        (ValueVar 244:12-16 Key1)
        (ParserVar 244:18-24 value1)
        (ParserVar 244:26-29 sep)
        (ValueVar 244:31-35 Key2)
        (ParserVar 244:37-43 value2)
      ])
    (TakeRight 245:2-62
      (TakeRight 245:2-20
        (Destructure 245:2-14
          (ParserVar 245:2-8 value1)
          (ValueVar 245:12-14 V1))
        (ParserVar 245:17-20 sep))
      (Return 246:2-39
        (Destructure 246:2-14
          (ParserVar 246:2-8 value2)
          (ValueVar 246:12-14 V2))
        (Object 247:2-22 [
          (ObjectPair (ValueVar 247:3-7 Key1) (ValueVar 247:9-11 V1))
          (ObjectPair (ValueVar 247:13-17 Key2) (ValueVar 247:19-21 V2))
        ]))))
  
  (DeclareGlobal 249:0-135
    (Function 249:0-49
      (ParserVar 249:0-7 record3) [
        (ValueVar 249:8-12 Key1)
        (ParserVar 249:14-20 value1)
        (ValueVar 249:22-26 Key2)
        (ParserVar 249:28-34 value2)
        (ValueVar 249:36-40 Key3)
        (ParserVar 249:42-48 value3)
      ])
    (TakeRight 250:2-83
      (TakeRight 250:2-31
        (Destructure 250:2-14
          (ParserVar 250:2-8 value1)
          (ValueVar 250:12-14 V1))
        (Destructure 251:2-14
          (ParserVar 251:2-8 value2)
          (ValueVar 251:12-14 V2)))
      (Return 252:2-49
        (Destructure 252:2-14
          (ParserVar 252:2-8 value3)
          (ValueVar 252:12-14 V3))
        (Object 253:2-32 [
          (ObjectPair (ValueVar 253:3-7 Key1) (ValueVar 253:9-11 V1))
          (ObjectPair (ValueVar 253:13-17 Key2) (ValueVar 253:19-21 V2))
          (ObjectPair (ValueVar 253:23-27 Key3) (ValueVar 253:29-31 V3))
        ]))))
  
  (DeclareGlobal 255:0-165
    (Function 255:0-65
      (ParserVar 255:0-11 record3_sep) [
        (ValueVar 255:12-16 Key1)
        (ParserVar 255:18-24 value1)
        (ParserVar 255:26-30 sep1)
        (ValueVar 255:32-36 Key2)
        (ParserVar 255:38-44 value2)
        (ParserVar 255:46-50 sep2)
        (ValueVar 255:52-56 Key3)
        (ParserVar 255:58-64 value3)
      ])
    (TakeRight 256:2-97
      (TakeRight 256:2-45
        (TakeRight 256:2-38
          (TakeRight 256:2-21
            (Destructure 256:2-14
              (ParserVar 256:2-8 value1)
              (ValueVar 256:12-14 V1))
            (ParserVar 256:17-21 sep1))
          (Destructure 257:2-14
            (ParserVar 257:2-8 value2)
            (ValueVar 257:12-14 V2)))
        (ParserVar 257:17-21 sep2))
      (Return 258:2-49
        (Destructure 258:2-14
          (ParserVar 258:2-8 value3)
          (ValueVar 258:12-14 V3))
        (Object 259:2-32 [
          (ObjectPair (ValueVar 259:3-7 Key1) (ValueVar 259:9-11 V1))
          (ObjectPair (ValueVar 259:13-17 Key2) (ValueVar 259:19-21 V2))
          (ObjectPair (ValueVar 259:23-27 Key3) (ValueVar 259:29-31 V3))
        ]))))
  
  (DeclareGlobal 263:0-17
    (Function 263:0-7
      (ParserVar 263:0-4 many) [
        (ParserVar 263:5-6 p)
      ])
    (Repeat 263:10-17
      (ParserVar 263:10-11 p)
      (Range 263:14-17 (NumberString 263:14-15 1) ())))
  
  (DeclareGlobal 265:0-40
    (Function 265:0-16
      (ParserVar 265:0-8 many_sep) [
        (ParserVar 265:9-10 p)
        (ParserVar 265:12-15 sep)
      ])
    (Merge 265:19-40
      (ParserVar 265:19-20 p)
      (Repeat 265:23-40
        (TakeRight 265:24-33
          (ParserVar 265:25-28 sep)
          (ParserVar 265:31-32 p))
        (Range 265:36-39 (NumberString 265:36-37 0) ()))))
  
  (DeclareGlobal 267:0-56
    (Function 267:0-19
      (ParserVar 267:0-10 many_until) [
        (ParserVar 267:11-12 p)
        (ParserVar 267:14-18 stop)
      ])
    (TakeLeft 267:22-56
      (Repeat 267:22-43
        (Function 267:22-37
          (ParserVar 267:22-28 unless) [
            (ParserVar 267:29-30 p)
            (ParserVar 267:32-36 stop)
          ])
        (Range 267:40-43 (NumberString 267:40-41 1) ()))
      (Function 267:46-56
        (ParserVar 267:46-50 peek) [
          (ParserVar 267:51-55 stop)
        ])))
  
  (DeclareGlobal 269:0-23
    (Function 269:0-13
      (ParserVar 269:0-10 maybe_many) [
        (ParserVar 269:11-12 p)
      ])
    (Repeat 269:16-23
      (ParserVar 269:16-17 p)
      (Range 269:20-23 (NumberString 269:20-21 0) ())))
  
  (DeclareGlobal 271:0-51
    (Function 271:0-22
      (ParserVar 271:0-14 maybe_many_sep) [
        (ParserVar 271:15-16 p)
        (ParserVar 271:18-21 sep)
      ])
    (Or 271:25-51
      (Function 271:25-41
        (ParserVar 271:25-33 many_sep) [
          (ParserVar 271:34-35 p)
          (ParserVar 271:37-40 sep)
        ])
      (ParserVar 271:44-51 succeed)))
  
  (DeclareGlobal 275:0-27
    (Function 275:0-7
      (ParserVar 275:0-4 peek) [
        (ParserVar 275:5-6 p)
      ])
    (Backtrack 275:10-27
      (Destructure 275:10-16
        (ParserVar 275:10-11 p)
        (ValueVar 275:15-16 V))
      (Function 275:19-27
        (ParserVar 275:19-24 const) [
          (ValueVar 275:25-26 V)
        ])))
  
  (DeclareGlobal 277:0-22
    (Function 277:0-8
      (ParserVar 277:0-5 maybe) [
        (ParserVar 277:6-7 p)
      ])
    (Or 277:11-22
      (ParserVar 277:11-12 p)
      (ParserVar 277:15-22 succeed)))
  
  (DeclareGlobal 279:0-42
    (Function 279:0-19
      (ParserVar 279:0-6 unless) [
        (ParserVar 279:7-8 p)
        (ParserVar 279:10-18 excluded)
      ])
    (Conditional 279:22-42
      (ParserVar 279:22-30 excluded)
      (ParserVar 279:33-38 @fail)
      (ParserVar 279:41-42 p)))
  
  (DeclareGlobal 281:0-17
    (Function 281:0-7
      (ParserVar 281:0-4 skip) [
        (ParserVar 281:5-6 p)
      ])
    (Function 281:10-17
      (Null 281:10-14) [
        (ParserVar 281:15-16 p)
      ]))
  
  (DeclareGlobal 283:0-30
    (Function 283:0-7
      (ParserVar 283:0-4 find) [
        (ParserVar 283:5-6 p)
      ])
    (Or 283:10-30
      (ParserVar 283:10-11 p)
      (TakeRight 283:14-30
        (ParserVar 283:15-19 char)
        (Function 283:22-29
          (ParserVar 283:22-26 find) [
            (ParserVar 283:27-28 p)
          ]))))
  
  (DeclareGlobal 285:0-48
    (Function 285:0-11
      (ParserVar 285:0-8 find_all) [
        (ParserVar 285:9-10 p)
      ])
    (TakeLeft 285:14-48
      (Function 285:14-28
        (ParserVar 285:14-19 array) [
          (Function 285:20-27
            (ParserVar 285:20-24 find) [
              (ParserVar 285:25-26 p)
            ])
        ])
      (Function 285:31-48
        (ParserVar 285:31-36 maybe) [
          (Function 285:37-47
            (ParserVar 285:37-41 many) [
              (ParserVar 285:42-46 char)
            ])
        ])))
  
  (DeclareGlobal 287:0-71
    (Function 287:0-20
      (ParserVar 287:0-11 find_before) [
        (ParserVar 287:12-13 p)
        (ParserVar 287:15-19 stop)
      ])
    (Conditional 287:23-71
      (ParserVar 287:23-27 stop)
      (ParserVar 287:30-35 @fail)
      (Or 287:38-71
        (ParserVar 287:38-39 p)
        (TakeRight 287:42-71
          (ParserVar 287:43-47 char)
          (Function 287:50-70
            (ParserVar 287:50-61 find_before) [
              (ParserVar 287:62-63 p)
              (ParserVar 287:65-69 stop)
            ])))))
  
  (DeclareGlobal 289:0-81
    (Function 289:0-24
      (ParserVar 289:0-15 find_all_before) [
        (ParserVar 289:16-17 p)
        (ParserVar 289:19-23 stop)
      ])
    (TakeLeft 289:27-81
      (Function 289:27-54
        (ParserVar 289:27-32 array) [
          (Function 289:33-53
            (ParserVar 289:33-44 find_before) [
              (ParserVar 289:45-46 p)
              (ParserVar 289:48-52 stop)
            ])
        ])
      (Function 289:57-81
        (ParserVar 289:57-62 maybe) [
          (Function 289:63-80
            (ParserVar 289:63-74 chars_until) [
              (ParserVar 289:75-79 stop)
            ])
        ])))
  
  (DeclareGlobal 291:0-22
    (ParserVar 291:0-7 succeed)
    (Function 291:10-22
      (ParserVar 291:10-15 const) [
        (ValueLabel 291:16-17 (Null 291:17-21))
      ]))
  
  (DeclareGlobal 293:0-28
    (Function 293:0-13
      (ParserVar 293:0-7 default) [
        (ParserVar 293:8-9 p)
        (ValueVar 293:11-12 D)
      ])
    (Or 293:16-28
      (ParserVar 293:16-17 p)
      (Function 293:20-28
        (ParserVar 293:20-25 const) [
          (ValueVar 293:26-27 D)
        ])))
  
  (DeclareGlobal 295:0-17
    (Function 295:0-8
      (ParserVar 295:0-5 const) [
        (ValueVar 295:6-7 C)
      ])
    (Return 295:11-17
      (String 295:11-13 "")
      (ValueVar 295:16-17 C)))
  
  (DeclareGlobal 297:0-34
    (Function 297:0-12
      (ParserVar 297:0-9 as_number) [
        (ParserVar 297:10-11 p)
      ])
    (Return 297:15-34
      (Destructure 297:15-30
        (ParserVar 297:15-16 p)
        (StringTemplate 297:20-30 [
          (Merge 297:23-28
            (NumberString 297:23-24 0)
            (ValueVar 297:27-28 N))
        ]))
      (ValueVar 297:33-34 N)))
  
  (DeclareGlobal 299:0-21
    (Function 299:0-12
      (ParserVar 299:0-9 as_string) [
        (ParserVar 299:10-11 p)
      ])
    (StringTemplate 299:15-21 [
      (ParserVar 299:18-19 p)
    ]))
  
  (DeclareGlobal 301:0-35
    (Function 301:0-17
      (ParserVar 301:0-8 surround) [
        (ParserVar 301:9-10 p)
        (ParserVar 301:12-16 fill)
      ])
    (TakeLeft 301:20-35
      (TakeRight 301:20-28
        (ParserVar 301:20-24 fill)
        (ParserVar 301:27-28 p))
      (ParserVar 301:31-35 fill)))
  
  (DeclareGlobal 303:0-37
    (ParserVar 303:0-12 end_of_input)
    (Conditional 303:15-37
      (ParserVar 303:15-19 char)
      (ParserVar 303:22-27 @fail)
      (ParserVar 303:30-37 succeed)))
  
  (DeclareGlobal 305:0-18
    (ParserVar 305:0-3 end)
    (ParserVar 305:6-18 end_of_input))
  
  (DeclareGlobal 307:0-56
    (Function 307:0-8
      (ParserVar 307:0-5 input) [
        (ParserVar 307:6-7 p)
      ])
    (TakeLeft 307:11-56
      (Function 307:11-41
        (ParserVar 307:11-19 surround) [
          (ParserVar 307:20-21 p)
          (Function 307:23-40
            (ParserVar 307:23-28 maybe) [
              (ParserVar 307:29-39 whitespace)
            ])
        ])
      (ParserVar 307:44-56 end_of_input)))
  
  (DeclareGlobal 309:0-51
    (Function 309:0-17
      (ParserVar 309:0-11 one_or_both) [
        (ParserVar 309:12-13 a)
        (ParserVar 309:15-16 b)
      ])
    (Or 309:20-51
      (Merge 309:20-34
        (ParserVar 309:21-22 a)
        (Function 309:25-33
          (ParserVar 309:25-30 maybe) [
            (ParserVar 309:31-32 b)
          ]))
      (Merge 309:37-51
        (Function 309:38-46
          (ParserVar 309:38-43 maybe) [
            (ParserVar 309:44-45 a)
          ])
        (ParserVar 309:49-50 b))))
  
  (DeclareGlobal 313:0-110
    (ParserVar 313:0-4 json)
    (Or 314:2-103
      (ParserVar 314:2-14 json.boolean)
      (Or 315:2-86
        (ParserVar 315:2-11 json.null)
        (Or 316:2-72
          (ParserVar 316:2-13 json.number)
          (Or 317:2-56
            (ParserVar 317:2-13 json.string)
            (Or 318:2-40
              (Function 318:2-18
                (ParserVar 318:2-12 json.array) [
                  (ParserVar 318:13-17 json)
                ])
              (Function 319:2-19
                (ParserVar 319:2-13 json.object) [
                  (ParserVar 319:14-18 json)
                ])))))))
  
  (DeclareGlobal 321:0-39
    (ParserVar 321:0-12 json.boolean)
    (Function 321:15-39
      (ParserVar 321:15-22 boolean) [
        (String 321:23-29 "true")
        (String 321:31-38 "false")
      ]))
  
  (DeclareGlobal 323:0-24
    (ParserVar 323:0-9 json.null)
    (Function 323:12-24
      (Null 323:12-16) [
        (String 323:17-23 "null")
      ]))
  
  (DeclareGlobal 325:0-20
    (ParserVar 325:0-11 json.number)
    (ParserVar 325:14-20 number))
  
  (DeclareGlobal 327:0-43
    (ParserVar 327:0-11 json.string)
    (TakeLeft 327:14-43
      (TakeRight 327:14-37
        (String 327:14-17 """)
        (ParserVar 327:20-37 _json.string_body))
      (String 327:40-43 """)))
  
  (DeclareGlobal 329:0-133
    (ParserVar 329:0-17 _json.string_body)
    (Or 330:2-113
      (Function 330:2-100
        (ParserVar 330:2-6 many) [
          (Or 331:4-88
            (ParserVar 331:4-22 _escaped_ctrl_char)
            (Or 332:4-63
              (ParserVar 332:4-20 _escaped_unicode)
              (Function 333:4-40
                (ParserVar 333:4-10 unless) [
                  (ParserVar 333:11-15 char)
                  (Or 333:17-39
                    (ParserVar 333:17-27 _ctrl_char)
                    (Or 333:30-39
                      (String 333:30-33 "\")
                      (String 333:36-39 """)))
                ])))
        ])
      (Function 334:6-16
        (ParserVar 334:6-11 const) [
          (ValueLabel 334:12-13 (String 334:13-15 ""))
        ])))
  
  (DeclareGlobal 336:0-35
    (ParserVar 336:0-10 _ctrl_char)
    (Range 336:13-35 (String 336:13-23 "\x00") (String 336:25-35 "\x1f"))) (esc)
  
  (DeclareGlobal 338:0-159
    (ParserVar 338:0-18 _escaped_ctrl_char)
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
    (ParserVar 348:0-16 _escaped_unicode)
    (Or 348:19-63
      (ParserVar 348:19-42 _escaped_surrogate_pair)
      (ParserVar 348:45-63 _escaped_codepoint)))
  
  (DeclareGlobal 350:0-73
    (ParserVar 350:0-23 _escaped_surrogate_pair)
    (Or 350:26-73
      (ParserVar 350:26-47 _valid_surrogate_pair)
      (ParserVar 350:50-73 _invalid_surrogate_pair)))
  
  (DeclareGlobal 352:0-100
    (ParserVar 352:0-21 _valid_surrogate_pair)
    (TakeRight 353:2-76
      (Destructure 353:2-22
        (ParserVar 353:2-17 _high_surrogate)
        (ValueVar 353:21-22 H))
      (Return 353:25-76
        (Destructure 353:25-44
          (ParserVar 353:25-39 _low_surrogate)
          (ValueVar 353:43-44 L))
        (Function 353:47-76
          (ValueVar 353:47-70 @SurrogatePairCodepoint) [
            (ValueVar 353:71-72 H)
            (ValueVar 353:74-75 L)
          ]))))
  
  (DeclareGlobal 355:0-71
    (ParserVar 355:0-23 _invalid_surrogate_pair)
    (Return 355:26-71
      (Or 355:26-58
        (ParserVar 355:26-40 _low_surrogate)
        (ParserVar 355:43-58 _high_surrogate))
      (String 355:61-71 "\xef\xbf\xbd"))) (esc)
  
  (DeclareGlobal 357:0-104
    (ParserVar 357:0-15 _high_surrogate)
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
        (ParserVar 358:61-72 hex_numeral))
      (ParserVar 358:75-86 hex_numeral)))
  
  (DeclareGlobal 360:0-89
    (ParserVar 360:0-14 _low_surrogate)
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
        (ParserVar 361:47-58 hex_numeral))
      (ParserVar 361:61-72 hex_numeral)))
  
  (DeclareGlobal 363:0-66
    (ParserVar 363:0-18 _escaped_codepoint)
    (Return 363:21-66
      (Destructure 363:21-50
        (TakeRight 363:21-45
          (String 363:21-25 "\u")
          (Repeat 363:28-45
            (ParserVar 363:29-40 hex_numeral)
            (NumberString 363:43-44 4)))
        (ValueVar 363:49-50 U))
      (Function 363:53-66
        (ValueVar 363:53-63 @Codepoint) [
          (ValueVar 363:64-65 U)
        ])))
  
  (DeclareGlobal 365:0-78
    (Function 365:0-16
      (ParserVar 365:0-10 json.array) [
        (ParserVar 365:11-15 elem)
      ])
    (TakeLeft 365:19-78
      (TakeRight 365:19-72
        (String 365:19-22 "[")
        (Function 365:25-72
          (ParserVar 365:25-40 maybe_array_sep) [
            (Function 365:41-66
              (ParserVar 365:41-49 surround) [
                (ParserVar 365:50-54 elem)
                (Function 365:56-65
                  (ParserVar 365:56-61 maybe) [
                    (ParserVar 365:62-64 ws)
                  ])
              ])
            (String 365:68-71 ",")
          ]))
      (String 365:75-78 "]")))
  
  (DeclareGlobal 367:0-139
    (Function 367:0-18
      (ParserVar 367:0-11 json.object) [
        (ParserVar 367:12-17 value)
      ])
    (TakeLeft 368:2-118
      (TakeRight 368:2-110
        (String 368:2-5 "{")
        (Function 369:2-102
          (ParserVar 369:2-18 maybe_object_sep) [
            (Function 370:4-36
              (ParserVar 370:4-12 surround) [
                (ParserVar 370:13-24 json.string)
                (Function 370:26-35
                  (ParserVar 370:26-31 maybe) [
                    (ParserVar 370:32-34 ws)
                  ])
              ])
            (String 370:38-41 ":")
            (Function 371:4-30
              (ParserVar 371:4-12 surround) [
                (ParserVar 371:13-18 value)
                (Function 371:20-29
                  (ParserVar 371:20-25 maybe) [
                    (ParserVar 371:26-28 ws)
                  ])
              ])
            (String 371:32-35 ",")
          ]))
      (String 373:4-7 "}")))
  
  (DeclareGlobal 377:0-18
    (ParserVar 377:0-4 toml)
    (ParserVar 377:7-18 toml.simple))
  
  (DeclareGlobal 379:0-44
    (ParserVar 379:0-11 toml.simple)
    (Function 379:14-44
      (ParserVar 379:14-25 toml.custom) [
        (ParserVar 379:26-43 toml.simple_value)
      ]))
  
  (DeclareGlobal 381:0-44
    (ParserVar 381:0-11 toml.tagged)
    (Function 381:14-44
      (ParserVar 381:14-25 toml.custom) [
        (ParserVar 381:26-43 toml.tagged_value)
      ]))
  
  (DeclareGlobal 383:0-188
    (Function 383:0-18
      (ParserVar 383:0-11 toml.custom) [
        (ParserVar 383:12-17 value)
      ])
    (TakeRight 384:2-167
      (TakeRight 384:2-104
        (Function 384:2-35
          (ParserVar 384:2-7 maybe) [
            (Merge 384:8-34
              (ParserVar 384:8-22 _toml.comments)
              (Function 384:25-34
                (ParserVar 384:25-30 maybe) [
                  (ParserVar 384:31-33 ws)
                ]))
          ])
        (Destructure 385:2-66
          (Or 385:2-59
            (Function 385:2-30
              (ParserVar 385:2-23 _toml.with_root_table) [
                (ParserVar 385:24-29 value)
              ])
            (Function 385:33-59
              (ParserVar 385:33-52 _toml.no_root_table) [
                (ParserVar 385:53-58 value)
              ]))
          (ValueVar 385:63-66 Doc)))
      (Return 386:2-60
        (Function 386:2-35
          (ParserVar 386:2-7 maybe) [
            (Merge 386:8-34
              (Function 386:8-17
                (ParserVar 386:8-13 maybe) [
                  (ParserVar 386:14-16 ws)
                ])
              (ParserVar 386:20-34 _toml.comments))
          ])
        (Function 387:2-22
          (ValueVar 387:2-17 _Toml.Doc.Value) [
            (ValueVar 387:18-21 Doc)
          ]))))
  
  (DeclareGlobal 389:0-147
    (Function 389:0-28
      (ParserVar 389:0-21 _toml.with_root_table) [
        (ParserVar 389:22-27 value)
      ])
    (TakeRight 390:2-116
      (Destructure 390:2-53
        (Function 390:2-42
          (ParserVar 390:2-18 _toml.root_table) [
            (ParserVar 390:19-24 value)
            (ValueVar 390:26-41 _Toml.Doc.Empty)
          ])
        (ValueVar 390:46-53 RootDoc))
      (Or 391:2-60
        (TakeRight 391:2-43
          (ParserVar 391:3-11 _toml.ws)
          (Function 391:14-42
            (ParserVar 391:14-26 _toml.tables) [
              (ParserVar 391:27-32 value)
              (ValueVar 391:34-41 RootDoc)
            ]))
        (Function 391:46-60
          (ParserVar 391:46-51 const) [
            (ValueVar 391:52-59 RootDoc)
          ]))))
  
  (DeclareGlobal 393:0-65
    (Function 393:0-28
      (ParserVar 393:0-16 _toml.root_table) [
        (ParserVar 393:17-22 value)
        (ValueVar 393:24-27 Doc)
      ])
    (Function 394:2-34
      (ParserVar 394:2-18 _toml.table_body) [
        (ParserVar 394:19-24 value)
        (Array 394:26-29 [])
        (ValueVar 394:30-33 Doc)
      ]))
  
  (DeclareGlobal 396:0-156
    (Function 396:0-26
      (ParserVar 396:0-19 _toml.no_root_table) [
        (ParserVar 396:20-25 value)
      ])
    (TakeRight 397:2-127
      (Destructure 397:2-95
        (Or 397:2-85
          (Function 397:2-37
            (ParserVar 397:2-13 _toml.table) [
              (ParserVar 397:14-19 value)
              (ValueVar 397:21-36 _Toml.Doc.Empty)
            ])
          (Function 397:40-85
            (ParserVar 397:40-61 _toml.array_of_tables) [
              (ParserVar 397:62-67 value)
              (ValueVar 397:69-84 _Toml.Doc.Empty)
            ]))
        (ValueVar 397:89-95 NewDoc))
      (Function 398:2-29
        (ParserVar 398:2-14 _toml.tables) [
          (ParserVar 398:15-20 value)
          (ValueVar 398:22-28 NewDoc)
        ])))
  
  (DeclareGlobal 400:0-158
    (Function 400:0-24
      (ParserVar 400:0-12 _toml.tables) [
        (ParserVar 400:13-18 value)
        (ValueVar 400:20-23 Doc)
      ])
    (Conditional 401:2-131
      (Destructure 401:2-84
        (Or 401:2-74
          (TakeRight 401:2-38
            (ParserVar 401:2-10 _toml.ws)
            (Function 402:2-25
              (ParserVar 402:2-13 _toml.table) [
                (ParserVar 402:14-19 value)
                (ValueVar 402:21-24 Doc)
              ]))
          (Function 402:28-61
            (ParserVar 402:28-49 _toml.array_of_tables) [
              (ParserVar 402:50-55 value)
              (ValueVar 402:57-60 Doc)
            ]))
        (ValueVar 402:65-71 NewDoc))
      (Function 403:2-29
        (ParserVar 403:2-14 _toml.tables) [
          (ParserVar 403:15-20 value)
          (ValueVar 403:22-28 NewDoc)
        ])
      (Function 404:2-12
        (ParserVar 404:2-7 const) [
          (ValueVar 404:8-11 Doc)
        ])))
  
  (DeclareGlobal 406:0-190
    (Function 406:0-23
      (ParserVar 406:0-11 _toml.table) [
        (ParserVar 406:12-17 value)
        (ValueVar 406:19-22 Doc)
      ])
    (TakeRight 407:2-164
      (TakeRight 407:2-53
        (Destructure 407:2-34
          (ParserVar 407:2-20 _toml.table_header)
          (ValueVar 407:24-34 HeaderPath))
        (ParserVar 407:37-53 _toml.ws_newline))
      (Or 407:56-164
        (Function 408:4-44
          (ParserVar 408:4-20 _toml.table_body) [
            (ParserVar 408:21-26 value)
            (ValueVar 408:28-38 HeaderPath)
            (ValueVar 408:40-43 Doc)
          ])
        (Function 409:4-55
          (ParserVar 409:4-9 const) [
            (Function 409:10-54
              (ValueVar 409:10-37 _Toml.Doc.EnsureTableAtPath) [
                (ValueVar 409:38-41 Doc)
                (ValueVar 409:43-53 HeaderPath)
              ])
          ]))))
  
  (DeclareGlobal 412:0-257
    (Function 412:0-33
      (ParserVar 412:0-21 _toml.array_of_tables) [
        (ParserVar 412:22-27 value)
        (ValueVar 412:29-32 Doc)
      ])
    (TakeRight 413:2-221
      (TakeRight 413:2-63
        (Destructure 413:2-44
          (ParserVar 413:2-30 _toml.array_of_tables_header)
          (ValueVar 413:34-44 HeaderPath))
        (ParserVar 413:47-63 _toml.ws_newline))
      (Return 414:2-155
        (Destructure 414:2-84
          (Function 414:2-72
            (ParserVar 414:2-9 default) [
              (Function 414:10-54
                (ParserVar 414:10-26 _toml.table_body) [
                  (ParserVar 414:27-32 value)
                  (Array 414:34-37 [])
                  (ValueVar 414:38-53 _Toml.Doc.Empty)
                ])
              (ValueVar 414:56-71 _Toml.Doc.Empty)
            ])
          (ValueVar 414:76-84 InnerDoc))
        (Function 415:2-68
          (ValueVar 415:2-24 _Toml.Doc.AppendAtPath) [
            (ValueVar 415:25-28 Doc)
            (ValueVar 415:30-40 HeaderPath)
            (Function 415:42-67
              (ValueVar 415:42-57 _Toml.Doc.Value) [
                (ValueVar 415:58-66 InnerDoc)
              ])
          ]))))
  
  (DeclareGlobal 417:0-41
    (ParserVar 417:0-8 _toml.ws)
    (Function 417:11-41
      (ParserVar 417:11-21 maybe_many) [
        (Or 417:22-40
          (ParserVar 417:22-24 ws)
          (ParserVar 417:27-40 _toml.comment))
      ]))
  
  (DeclareGlobal 419:0-50
    (ParserVar 419:0-13 _toml.ws_line)
    (Function 419:16-50
      (ParserVar 419:16-26 maybe_many) [
        (Or 419:27-49
          (ParserVar 419:27-33 spaces)
          (ParserVar 419:36-49 _toml.comment))
      ]))
  
  (DeclareGlobal 421:0-56
    (ParserVar 421:0-16 _toml.ws_newline)
    (Merge 421:19-56
      (Merge 421:19-45
        (ParserVar 421:19-32 _toml.ws_line)
        (Or 421:35-45
          (ParserVar 421:36-38 nl)
          (ParserVar 421:41-44 end)))
      (ParserVar 421:48-56 _toml.ws)))
  
  (DeclareGlobal 423:0-44
    (ParserVar 423:0-14 _toml.comments)
    (Function 423:17-44
      (ParserVar 423:17-25 many_sep) [
        (ParserVar 423:26-39 _toml.comment)
        (ParserVar 423:41-43 ws)
      ]))
  
  (DeclareGlobal 425:0-64
    (ParserVar 425:0-18 _toml.table_header)
    (TakeLeft 425:21-64
      (TakeRight 425:21-58
        (String 425:21-24 "[")
        (Function 425:27-58
          (ParserVar 425:27-35 surround) [
            (ParserVar 425:36-46 _toml.path)
            (Function 425:48-57
              (ParserVar 425:48-53 maybe) [
                (ParserVar 425:54-56 ws)
              ])
          ]))
      (String 425:61-64 "]")))
  
  (DeclareGlobal 427:0-78
    (ParserVar 427:0-28 _toml.array_of_tables_header)
    (TakeLeft 428:2-47
      (TakeRight 428:2-40
        (String 428:2-6 "[[")
        (Function 428:9-40
          (ParserVar 428:9-17 surround) [
            (ParserVar 428:18-28 _toml.path)
            (Function 428:30-39
              (ParserVar 428:30-35 maybe) [
                (ParserVar 428:36-38 ws)
              ])
          ]))
      (String 428:43-47 "]]")))
  
  (DeclareGlobal 430:0-245
    (Function 430:0-40
      (ParserVar 430:0-16 _toml.table_body) [
        (ParserVar 430:17-22 value)
        (ValueVar 430:24-34 HeaderPath)
        (ValueVar 430:36-39 Doc)
      ])
    (TakeRight 431:2-202
      (TakeRight 431:2-138
        (TakeRight 431:2-62
          (Destructure 431:2-43
            (Function 431:2-25
              (ParserVar 431:2-18 _toml.table_pair) [
                (ParserVar 431:19-24 value)
              ])
            (Array 431:29-43 [
              (ValueVar 431:30-37 KeyPath)
              (ValueVar 431:39-42 Val)
            ]))
          (ParserVar 431:46-62 _toml.ws_newline))
        (Destructure 432:2-73
          (Function 432:2-63
            (ParserVar 432:2-7 const) [
              (Function 432:8-62
                (ValueVar 432:8-30 _Toml.Doc.InsertAtPath) [
                  (ValueVar 432:31-34 Doc)
                  (Merge 432:36-56
                    (ValueVar 432:36-46 HeaderPath)
                    (ValueVar 432:49-56 KeyPath))
                  (ValueVar 432:58-61 Val)
                ])
            ])
          (ValueVar 432:67-73 NewDoc)))
      (Or 433:2-61
        (Function 433:2-45
          (ParserVar 433:2-18 _toml.table_body) [
            (ParserVar 433:19-24 value)
            (ValueVar 433:26-36 HeaderPath)
            (ValueVar 433:38-44 NewDoc)
          ])
        (Function 433:48-61
          (ParserVar 433:48-53 const) [
            (ValueVar 433:54-60 NewDoc)
          ]))))
  
  (DeclareGlobal 435:0-87
    (Function 435:0-23
      (ParserVar 435:0-16 _toml.table_pair) [
        (ParserVar 435:17-22 value)
      ])
    (Function 436:2-61
      (ParserVar 436:2-12 tuple2_sep) [
        (ParserVar 436:13-23 _toml.path)
        (Function 436:25-53
          (ParserVar 436:25-33 surround) [
            (String 436:34-37 "=")
            (Function 436:39-52
              (ParserVar 436:39-44 maybe) [
                (ParserVar 436:45-51 spaces)
              ])
          ])
        (ParserVar 436:55-60 value)
      ]))
  
  (DeclareGlobal 438:0-59
    (ParserVar 438:0-10 _toml.path)
    (Function 438:13-59
      (ParserVar 438:13-22 array_sep) [
        (ParserVar 438:23-32 _toml.key)
        (Function 438:34-58
          (ParserVar 438:34-42 surround) [
            (String 438:43-46 ".")
            (Function 438:48-57
              (ParserVar 438:48-53 maybe) [
                (ParserVar 438:54-56 ws)
              ])
          ])
      ]))
  
  (DeclareGlobal 440:0-93
    (ParserVar 440:0-9 _toml.key)
    (Or 441:2-81
      (Function 441:2-35
        (ParserVar 441:2-6 many) [
          (Or 441:7-34
            (ParserVar 441:7-12 alpha)
            (Or 441:15-34
              (ParserVar 441:15-22 numeral)
              (Or 441:25-34
                (String 441:25-28 "_")
                (String 441:31-34 "-"))))
        ])
      (Or 442:2-43
        (ParserVar 442:2-19 toml.string.basic)
        (ParserVar 443:2-21 toml.string.literal))))
  
  (DeclareGlobal 445:0-33
    (ParserVar 445:0-13 _toml.comment)
    (TakeRight 445:16-33
      (String 445:16-19 "#")
      (Function 445:22-33
        (ParserVar 445:22-27 maybe) [
          (ParserVar 445:28-32 line)
        ])))
  
  (DeclareGlobal 447:0-159
    (ParserVar 447:0-17 toml.simple_value)
    (Or 448:2-139
      (ParserVar 448:2-13 toml.string)
      (Or 449:2-123
        (ParserVar 449:2-15 toml.datetime)
        (Or 450:2-105
          (ParserVar 450:2-13 toml.number)
          (Or 451:2-89
            (ParserVar 451:2-14 toml.boolean)
            (Or 452:2-72
              (Function 452:2-31
                (ParserVar 452:2-12 toml.array) [
                  (ParserVar 452:13-30 toml.simple_value)
                ])
              (Function 453:2-38
                (ParserVar 453:2-19 toml.inline_table) [
                  (ParserVar 453:20-37 toml.simple_value)
                ])))))))
  
  (DeclareGlobal 455:0-640
    (ParserVar 455:0-17 toml.tagged_value)
    (Or 456:2-620
      (ParserVar 456:2-13 toml.string)
      (Or 457:2-604
        (Function 457:2-57
          (ParserVar 457:2-11 _toml.tag) [
            (ValueLabel 457:12-13 (String 457:13-23 "datetime"))
            (ValueLabel 457:25-26 (String 457:26-34 "offset"))
            (ParserVar 457:36-56 toml.datetime.offset)
          ])
        (Or 458:2-544
          (Function 458:2-55
            (ParserVar 458:2-11 _toml.tag) [
              (ValueLabel 458:12-13 (String 458:13-23 "datetime"))
              (ValueLabel 458:25-26 (String 458:26-33 "local"))
              (ParserVar 458:35-54 toml.datetime.local)
            ])
          (Or 459:2-486
            (Function 459:2-65
              (ParserVar 459:2-11 _toml.tag) [
                (ValueLabel 459:12-13 (String 459:13-23 "datetime"))
                (ValueLabel 459:25-26 (String 459:26-38 "date-local"))
                (ParserVar 459:40-64 toml.datetime.local_date)
              ])
            (Or 460:2-418
              (Function 460:2-65
                (ParserVar 460:2-11 _toml.tag) [
                  (ValueLabel 460:12-13 (String 460:13-23 "datetime"))
                  (ValueLabel 460:25-26 (String 460:26-38 "time-local"))
                  (ParserVar 460:40-64 toml.datetime.local_time)
                ])
              (Or 461:2-350
                (ParserVar 461:2-28 toml.number.binary_integer)
                (Or 462:2-319
                  (ParserVar 462:2-27 toml.number.octal_integer)
                  (Or 463:2-289
                    (ParserVar 463:2-25 toml.number.hex_integer)
                    (Or 464:2-261
                      (Function 464:2-56
                        (ParserVar 464:2-11 _toml.tag) [
                          (ValueLabel 464:12-13 (String 464:13-20 "float"))
                          (ValueLabel 464:22-23 (String 464:23-33 "infinity"))
                          (ParserVar 464:35-55 toml.number.infinity)
                        ])
                      (Or 465:2-202
                        (Function 465:2-64
                          (ParserVar 465:2-11 _toml.tag) [
                            (ValueLabel 465:12-13 (String 465:13-20 "float"))
                            (ValueLabel 465:22-23 (String 465:23-37 "not-a-number"))
                            (ParserVar 465:39-63 toml.number.not_a_number)
                          ])
                        (Or 466:2-135
                          (ParserVar 466:2-19 toml.number.float)
                          (Or 467:2-113
                            (ParserVar 467:2-21 toml.number.integer)
                            (Or 468:2-89
                              (ParserVar 468:2-14 toml.boolean)
                              (Or 469:2-72
                                (Function 469:2-31
                                  (ParserVar 469:2-12 toml.array) [
                                    (ParserVar 469:13-30 toml.tagged_value)
                                  ])
                                (Function 470:2-38
                                  (ParserVar 470:2-19 toml.inline_table) [
                                    (ParserVar 470:20-37 toml.tagged_value)
                                  ]))))))))))))))))
  
  (DeclareGlobal 472:0-103
    (Function 472:0-31
      (ParserVar 472:0-9 _toml.tag) [
        (ValueVar 472:10-14 Type)
        (ValueVar 472:16-23 Subtype)
        (ParserVar 472:25-30 value)
      ])
    (Return 473:2-69
      (Destructure 473:2-16
        (ParserVar 473:2-7 value)
        (ValueVar 473:11-16 Value))
      (Object 473:19-69 [
        (ObjectPair (String 473:20-26 "type") (ValueVar 473:28-32 Type))
        (ObjectPair (String 473:34-43 "subtype") (ValueVar 473:45-52 Subtype))
        (ObjectPair (String 473:54-61 "value") (ValueVar 473:63-68 Value))
      ])))
  
  (DeclareGlobal 475:0-125
    (ParserVar 475:0-11 toml.string)
    (Or 476:2-111
      (ParserVar 476:2-30 toml.string.multi_line_basic)
      (Or 477:2-78
        (ParserVar 477:2-32 toml.string.multi_line_literal)
        (Or 478:2-43
          (ParserVar 478:2-19 toml.string.basic)
          (ParserVar 479:2-21 toml.string.literal)))))
  
  (DeclareGlobal 481:0-120
    (ParserVar 481:0-13 toml.datetime)
    (Or 482:2-104
      (ParserVar 482:2-22 toml.datetime.offset)
      (Or 483:2-79
        (ParserVar 483:2-21 toml.datetime.local)
        (Or 484:2-55
          (ParserVar 484:2-26 toml.datetime.local_date)
          (ParserVar 485:2-26 toml.datetime.local_time)))))
  
  (DeclareGlobal 487:0-200
    (ParserVar 487:0-11 toml.number)
    (Or 488:2-186
      (ParserVar 488:2-28 toml.number.binary_integer)
      (Or 489:2-155
        (ParserVar 489:2-27 toml.number.octal_integer)
        (Or 490:2-125
          (ParserVar 490:2-25 toml.number.hex_integer)
          (Or 491:2-97
            (ParserVar 491:2-22 toml.number.infinity)
            (Or 492:2-72
              (ParserVar 492:2-26 toml.number.not_a_number)
              (Or 493:2-43
                (ParserVar 493:2-19 toml.number.float)
                (ParserVar 494:2-21 toml.number.integer))))))))
  
  (DeclareGlobal 496:0-39
    (ParserVar 496:0-12 toml.boolean)
    (Function 496:15-39
      (ParserVar 496:15-22 boolean) [
        (String 496:23-29 "true")
        (String 496:31-38 "false")
      ]))
  
  (DeclareGlobal 498:0-153
    (Function 498:0-16
      (ParserVar 498:0-10 toml.array) [
        (ParserVar 498:11-15 elem)
      ])
    (TakeLeft 499:2-134
      (TakeLeft 499:2-128
        (TakeRight 499:2-117
          (TakeRight 499:2-16
            (String 499:2-5 "[")
            (ParserVar 499:8-16 _toml.ws))
          (Function 499:19-117
            (ParserVar 499:19-26 default) [
              (TakeLeft 500:4-77
                (Function 500:4-44
                  (ParserVar 500:4-13 array_sep) [
                    (Function 500:14-38
                      (ParserVar 500:14-22 surround) [
                        (ParserVar 500:23-27 elem)
                        (ParserVar 500:29-37 _toml.ws)
                      ])
                    (String 500:40-43 ",")
                  ])
                (Function 500:47-77
                  (ParserVar 500:47-52 maybe) [
                    (Function 500:53-76
                      (ParserVar 500:53-61 surround) [
                        (String 500:62-65 ",")
                        (ParserVar 500:67-75 _toml.ws)
                      ])
                  ]))
              (Array 501:4-10 [])
            ]))
        (ParserVar 502:6-14 _toml.ws))
      (String 502:17-20 "]")))
  
  (DeclareGlobal 504:0-134
    (Function 504:0-24
      (ParserVar 504:0-17 toml.inline_table) [
        (ParserVar 504:18-23 value)
      ])
    (Return 505:2-107
      (Destructure 505:2-76
        (Or 505:2-63
          (ParserVar 505:2-26 _toml.empty_inline_table)
          (Function 505:29-63
            (ParserVar 505:29-56 _toml.nonempty_inline_table) [
              (ParserVar 505:57-62 value)
            ]))
        (ValueVar 505:67-76 InlineDoc))
      (Function 506:2-28
        (ValueVar 506:2-17 _Toml.Doc.Value) [
          (ValueVar 506:18-27 InlineDoc)
        ])))
  
  (DeclareGlobal 508:0-70
    (ParserVar 508:0-24 _toml.empty_inline_table)
    (Return 508:27-70
      (TakeLeft 508:27-52
        (TakeRight 508:27-46
          (String 508:27-30 "{")
          (Function 508:33-46
            (ParserVar 508:33-38 maybe) [
              (ParserVar 508:39-45 spaces)
            ]))
        (String 508:49-52 "}"))
      (ValueVar 508:55-70 _Toml.Doc.Empty)))
  
  (DeclareGlobal 510:0-207
    (Function 510:0-34
      (ParserVar 510:0-27 _toml.nonempty_inline_table) [
        (ParserVar 510:28-33 value)
      ])
    (TakeRight 511:2-170
      (Destructure 511:2-93
        (TakeRight 511:2-73
          (TakeRight 511:2-21
            (String 511:2-5 "{")
            (Function 511:8-21
              (ParserVar 511:8-13 maybe) [
                (ParserVar 511:14-20 spaces)
              ]))
          (Function 512:2-49
            (ParserVar 512:2-25 _toml.inline_table_pair) [
              (ParserVar 512:26-31 value)
              (ValueVar 512:33-48 _Toml.Doc.Empty)
            ]))
        (ValueVar 512:53-69 DocWithFirstPair))
      (TakeLeft 513:2-74
        (TakeLeft 513:2-68
          (Function 513:2-50
            (ParserVar 513:2-25 _toml.inline_table_body) [
              (ParserVar 513:26-31 value)
              (ValueVar 513:33-49 DocWithFirstPair)
            ])
          (Function 514:4-17
            (ParserVar 514:4-9 maybe) [
              (ParserVar 514:10-16 spaces)
            ]))
        (String 514:20-23 "}"))))
  
  (DeclareGlobal 516:0-149
    (Function 516:0-35
      (ParserVar 516:0-23 _toml.inline_table_body) [
        (ParserVar 516:24-29 value)
        (ValueVar 516:31-34 Doc)
      ])
    (Conditional 517:2-111
      (Destructure 517:2-53
        (TakeRight 517:2-43
          (String 517:2-5 ",")
          (Function 517:8-43
            (ParserVar 517:8-31 _toml.inline_table_pair) [
              (ParserVar 517:32-37 value)
              (ValueVar 517:39-42 Doc)
            ]))
        (ValueVar 517:47-53 NewDoc))
      (Function 518:2-40
        (ParserVar 518:2-25 _toml.inline_table_body) [
          (ParserVar 518:26-31 value)
          (ValueVar 518:33-39 NewDoc)
        ])
      (Function 519:2-12
        (ParserVar 519:2-7 const) [
          (ValueVar 519:8-11 Doc)
        ])))
  
  (DeclareGlobal 521:0-192
    (Function 521:0-35
      (ParserVar 521:0-23 _toml.inline_table_pair) [
        (ParserVar 521:24-29 value)
        (ValueVar 521:31-34 Doc)
      ])
    (TakeRight 522:2-154
      (TakeRight 522:2-94
        (TakeRight 522:2-77
          (TakeRight 522:2-61
            (TakeRight 522:2-55
              (TakeRight 522:2-37
                (Function 522:2-15
                  (ParserVar 522:2-7 maybe) [
                    (ParserVar 522:8-14 spaces)
                  ])
                (Destructure 523:2-19
                  (ParserVar 523:2-12 _toml.path)
                  (ValueVar 523:16-19 Key)))
              (Function 524:2-15
                (ParserVar 524:2-7 maybe) [
                  (ParserVar 524:8-14 spaces)
                ]))
            (String 524:18-21 "="))
          (Function 524:24-37
            (ParserVar 524:24-29 maybe) [
              (ParserVar 524:30-36 spaces)
            ]))
        (Destructure 525:2-14
          (ParserVar 525:2-7 value)
          (ValueVar 525:11-14 Val)))
      (Return 526:2-57
        (Function 526:2-15
          (ParserVar 526:2-7 maybe) [
            (ParserVar 526:8-14 spaces)
          ])
        (Function 527:2-39
          (ValueVar 527:2-24 _Toml.Doc.InsertAtPath) [
            (ValueVar 527:25-28 Doc)
            (ValueVar 527:30-33 Key)
            (ValueVar 527:35-38 Val)
          ]))))
  
  (DeclareGlobal 529:0-85
    (ParserVar 529:0-28 toml.string.multi_line_basic)
    (TakeRight 529:31-85
      (TakeRight 529:31-48
        (String 529:31-36 """"")
        (Function 529:39-48
          (ParserVar 529:39-44 maybe) [
            (ParserVar 529:45-47 nl)
          ]))
      (Function 529:51-85
        (ParserVar 529:51-80 _toml.string.multi_line_basic) [
          (ValueLabel 529:81-82 (String 529:82-84 ""))
        ])))
  
  (DeclareGlobal 531:0-292
    (Function 531:0-34
      (ParserVar 531:0-29 _toml.string.multi_line_basic) [
        (ValueVar 531:30-33 Acc)
      ])
    (Or 532:2-255
      (Return 532:2-26
        (String 532:3-10 """"""")
        (Merge 532:13-25
          (ValueVar 532:14-17 Acc)
          (String 532:20-24 """")))
      (Or 533:2-226
        (Return 533:2-24
          (String 533:3-9 """""")
          (Merge 533:12-23
            (ValueVar 533:13-16 Acc)
            (String 533:19-22 """)))
        (Or 534:2-199
          (Return 534:2-15
            (String 534:3-8 """"")
            (ValueVar 534:11-14 Acc))
          (TakeRight 535:2-181
            (Destructure 536:4-128
              (Or 536:4-123
                (ParserVar 536:4-27 _toml.escaped_ctrl_char)
                (Or 537:4-93
                  (ParserVar 537:4-25 _toml.escaped_unicode)
                  (Or 538:4-65
                    (ParserVar 538:4-6 ws)
                    (Or 539:4-56
                      (TakeRight 539:4-19
                        (Merge 539:5-13
                          (String 539:5-8 "\")
                          (ParserVar 539:11-13 ws))
                        (String 539:16-18 ""))
                      (Function 540:4-34
                        (ParserVar 540:4-10 unless) [
                          (ParserVar 540:11-15 char)
                          (Or 540:17-33
                            (ParserVar 540:17-27 _ctrl_char)
                            (String 540:30-33 "\"))
                        ])))))
              (ValueVar 540:38-39 C))
            (Function 541:4-42
              (ParserVar 541:4-33 _toml.string.multi_line_basic) [
                (Merge 541:34-41
                  (ValueVar 541:34-37 Acc)
                  (ValueVar 541:40-41 C))
              ]))))))
  
  (DeclareGlobal 544:0-89
    (ParserVar 544:0-30 toml.string.multi_line_literal)
    (TakeRight 544:33-89
      (TakeRight 544:33-50
        (String 544:33-38 "'''")
        (Function 544:41-50
          (ParserVar 544:41-46 maybe) [
            (ParserVar 544:47-49 nl)
          ]))
      (Function 544:53-89
        (ParserVar 544:53-84 _toml.string.multi_line_literal) [
          (ValueLabel 544:85-86 (String 544:86-88 ""))
        ])))
  
  (DeclareGlobal 546:0-169
    (Function 546:0-36
      (ParserVar 546:0-31 _toml.string.multi_line_literal) [
        (ValueVar 546:32-35 Acc)
      ])
    (Or 547:2-130
      (Return 547:2-26
        (String 547:3-10 "'''''")
        (Merge 547:13-25
          (ValueVar 547:14-17 Acc)
          (String 547:20-24 "''")))
      (Or 548:2-101
        (Return 548:2-24
          (String 548:3-9 "''''")
          (Merge 548:12-23
            (ValueVar 548:13-16 Acc)
            (String 548:19-22 "'")))
        (Or 549:2-74
          (Return 549:2-15
            (String 549:3-8 "'''")
            (ValueVar 549:11-14 Acc))
          (TakeRight 550:2-56
            (Destructure 550:3-12
              (ParserVar 550:3-7 char)
              (ValueVar 550:11-12 C))
            (Function 550:15-55
              (ParserVar 550:15-46 _toml.string.multi_line_literal) [
                (Merge 550:47-54
                  (ValueVar 550:47-50 Acc)
                  (ValueVar 550:53-54 C))
              ]))))))
  
  (DeclareGlobal 552:0-55
    (ParserVar 552:0-17 toml.string.basic)
    (TakeLeft 552:20-55
      (TakeRight 552:20-49
        (String 552:20-23 """)
        (ParserVar 552:26-49 _toml.string.basic_body))
      (String 552:52-55 """)))
  
  (DeclareGlobal 554:0-149
    (ParserVar 554:0-23 _toml.string.basic_body)
    (Or 555:2-123
      (Function 555:2-110
        (ParserVar 555:2-6 many) [
          (Or 556:4-98
            (ParserVar 556:4-27 _toml.escaped_ctrl_char)
            (Or 557:4-68
              (ParserVar 557:4-25 _toml.escaped_unicode)
              (Function 558:4-40
                (ParserVar 558:4-10 unless) [
                  (ParserVar 558:11-15 char)
                  (Or 558:17-39
                    (ParserVar 558:17-27 _ctrl_char)
                    (Or 558:30-39
                      (String 558:30-33 "\")
                      (String 558:36-39 """)))
                ])))
        ])
      (Function 559:6-16
        (ParserVar 559:6-11 const) [
          (ValueLabel 559:12-13 (String 559:13-15 ""))
        ])))
  
  (DeclareGlobal 561:0-64
    (ParserVar 561:0-19 toml.string.literal)
    (TakeLeft 561:22-64
      (TakeRight 561:22-58
        (String 561:22-25 "'")
        (Function 561:28-58
          (ParserVar 561:28-35 default) [
            (Function 561:36-52
              (ParserVar 561:36-47 chars_until) [
                (String 561:48-51 "'")
              ])
            (ValueLabel 561:54-55 (String 561:55-57 ""))
          ]))
      (String 561:61-64 "'")))
  
  (DeclareGlobal 563:0-147
    (ParserVar 563:0-23 _toml.escaped_ctrl_char)
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
    (ParserVar 572:0-21 _toml.escaped_unicode)
    (Or 573:2-101
      (Return 573:2-49
        (Destructure 573:3-32
          (TakeRight 573:3-27
            (String 573:3-7 "\u")
            (Repeat 573:10-27
              (ParserVar 573:11-22 hex_numeral)
              (NumberString 573:25-26 4)))
          (ValueVar 573:31-32 U))
        (Function 573:35-48
          (ValueVar 573:35-45 @Codepoint) [
            (ValueVar 573:46-47 U)
          ]))
      (Return 574:2-49
        (Destructure 574:3-32
          (TakeRight 574:3-27
            (String 574:3-7 "\U")
            (Repeat 574:10-27
              (ParserVar 574:11-22 hex_numeral)
              (NumberString 574:25-26 8)))
          (ValueVar 574:31-32 U))
        (Function 574:35-48
          (ValueVar 574:35-45 @Codepoint) [
            (ValueVar 574:46-47 U)
          ]))))
  
  (DeclareGlobal 576:0-96
    (ParserVar 576:0-20 toml.datetime.offset)
    (Merge 576:23-96
      (Merge 576:23-67
        (ParserVar 576:23-47 toml.datetime.local_date)
        (Or 576:50-67
          (String 576:51-54 "T")
          (Or 576:57-66
            (String 576:57-60 "t")
            (String 576:63-66 " "))))
      (ParserVar 576:70-96 _toml.datetime.time_offset)))
  
  (DeclareGlobal 578:0-93
    (ParserVar 578:0-19 toml.datetime.local)
    (Merge 578:22-93
      (Merge 578:22-66
        (ParserVar 578:22-46 toml.datetime.local_date)
        (Or 578:49-66
          (String 578:50-53 "T")
          (Or 578:56-65
            (String 578:56-59 "t")
            (String 578:62-65 " "))))
      (ParserVar 578:69-93 toml.datetime.local_time)))
  
  (DeclareGlobal 580:0-105
    (ParserVar 580:0-24 toml.datetime.local_date)
    (Merge 581:2-78
      (Merge 581:2-56
        (Merge 581:2-50
          (Merge 581:2-27
            (ParserVar 581:2-21 _toml.datetime.year)
            (String 581:24-27 "-"))
          (ParserVar 581:30-50 _toml.datetime.month))
        (String 581:53-56 "-"))
      (ParserVar 581:59-78 _toml.datetime.mday)))
  
  (DeclareGlobal 583:0-33
    (ParserVar 583:0-19 _toml.datetime.year)
    (Repeat 583:22-33
      (ParserVar 583:22-29 numeral)
      (NumberString 583:32-33 4)))
  
  (DeclareGlobal 585:0-53
    (ParserVar 585:0-20 _toml.datetime.month)
    (Or 585:23-53
      (Merge 585:23-39
        (String 585:24-27 "0")
        (Range 585:30-38 (String 585:30-33 "1") (String 585:35-38 "9")))
      (Or 585:42-53
        (String 585:42-46 "11")
        (String 585:49-53 "12"))))
  
  (DeclareGlobal 587:0-57
    (ParserVar 587:0-19 _toml.datetime.mday)
    (Or 587:22-57
      (Merge 587:22-43
        (Range 587:23-31 (String 587:23-26 "0") (String 587:28-31 "2"))
        (Range 587:34-42 (String 587:34-37 "1") (String 587:39-42 "9")))
      (Or 587:46-57
        (String 587:46-50 "30")
        (String 587:53-57 "31"))))
  
  (DeclareGlobal 589:0-149
    (ParserVar 589:0-24 toml.datetime.local_time)
    (Merge 590:2-122
      (Merge 590:2-88
        (Merge 590:2-61
          (Merge 590:2-55
            (Merge 590:2-28
              (ParserVar 590:2-22 _toml.datetime.hours)
              (String 590:25-28 ":"))
            (ParserVar 591:2-24 _toml.datetime.minutes))
          (String 591:27-30 ":"))
        (ParserVar 592:2-24 _toml.datetime.seconds))
      (Function 593:2-31
        (ParserVar 593:2-7 maybe) [
          (Merge 593:8-30
            (String 593:8-11 ".")
            (Repeat 593:14-30
              (ParserVar 593:15-22 numeral)
              (Range 593:25-29 (NumberString 593:25-26 1) (NumberString 593:28-29 9))))
        ])))
  
  (DeclareGlobal 595:0-99
    (ParserVar 595:0-26 _toml.datetime.time_offset)
    (Merge 595:29-99
      (ParserVar 595:29-53 toml.datetime.local_time)
      (Or 595:56-99
        (String 595:57-60 "Z")
        (Or 595:63-98
          (String 595:63-66 "z")
          (ParserVar 595:69-98 _toml.datetime.time_numoffset)))))
  
  (DeclareGlobal 597:0-97
    (ParserVar 597:0-29 _toml.datetime.time_numoffset)
    (Merge 597:32-97
      (Merge 597:32-72
        (Merge 597:32-66
          (Or 597:32-43
            (String 597:33-36 "+")
            (String 597:39-42 "-"))
          (ParserVar 597:46-66 _toml.datetime.hours))
        (String 597:69-72 ":"))
      (ParserVar 597:75-97 _toml.datetime.minutes)))
  
  (DeclareGlobal 599:0-63
    (ParserVar 599:0-20 _toml.datetime.hours)
    (Or 599:23-63
      (Merge 599:23-44
        (Range 599:24-32 (String 599:24-27 "0") (String 599:29-32 "1"))
        (Range 599:35-43 (String 599:35-38 "0") (String 599:40-43 "9")))
      (Merge 599:47-63
        (String 599:48-51 "2")
        (Range 599:54-62 (String 599:54-57 "0") (String 599:59-62 "3")))))
  
  (DeclareGlobal 601:0-44
    (ParserVar 601:0-22 _toml.datetime.minutes)
    (Merge 601:25-44
      (Range 601:25-33 (String 601:25-28 "0") (String 601:30-33 "5"))
      (Range 601:36-44 (String 601:36-39 "0") (String 601:41-44 "9"))))
  
  (DeclareGlobal 603:0-53
    (ParserVar 603:0-22 _toml.datetime.seconds)
    (Or 603:25-53
      (Merge 603:25-46
        (Range 603:26-34 (String 603:26-29 "0") (String 603:31-34 "5"))
        (Range 603:37-45 (String 603:37-40 "0") (String 603:42-45 "9")))
      (String 603:49-53 "60")))
  
  (DeclareGlobal 605:0-84
    (ParserVar 605:0-19 toml.number.integer)
    (Function 605:22-84
      (ParserVar 605:22-31 as_number) [
        (Merge 606:2-49
          (ParserVar 606:2-19 _toml.number.sign)
          (ParserVar 607:2-27 _toml.number.integer_part))
      ]))
  
  (DeclareGlobal 610:0-42
    (ParserVar 610:0-17 _toml.number.sign)
    (Function 610:20-42
      (ParserVar 610:20-25 maybe) [
        (Or 610:26-41
          (String 610:26-29 "-")
          (Function 610:32-41
            (ParserVar 610:32-36 skip) [
              (String 610:37-40 "+")
            ]))
      ]))
  
  (DeclareGlobal 612:0-79
    (ParserVar 612:0-25 _toml.number.integer_part)
    (Or 613:2-51
      (Merge 613:2-41
        (Range 613:3-11 (String 613:3-6 "1") (String 613:8-11 "9"))
        (Function 613:14-40
          (ParserVar 613:14-18 many) [
            (TakeRight 613:19-39
              (Function 613:19-29
                (ParserVar 613:19-24 maybe) [
                  (String 613:25-28 "_")
                ])
              (ParserVar 613:32-39 numeral))
          ]))
      (ParserVar 613:44-51 numeral)))
  
  (DeclareGlobal 615:0-192
    (ParserVar 615:0-17 toml.number.float)
    (Function 615:20-192
      (ParserVar 615:20-29 as_number) [
        (Merge 616:2-159
          (Merge 616:2-49
            (ParserVar 616:2-19 _toml.number.sign)
            (ParserVar 617:2-27 _toml.number.integer_part))
          (Or 617:30-137
            (Merge 618:4-68
              (ParserVar 618:5-31 _toml.number.fraction_part)
              (Function 618:34-67
                (ParserVar 618:34-39 maybe) [
                  (ParserVar 618:40-66 _toml.number.exponent_part)
                ]))
            (ParserVar 619:4-30 _toml.number.exponent_part)))
      ]))
  
  (DeclareGlobal 623:0-65
    (ParserVar 623:0-26 _toml.number.fraction_part)
    (Merge 623:29-65
      (String 623:29-32 ".")
      (Function 623:35-65
        (ParserVar 623:35-43 many_sep) [
          (ParserVar 623:44-52 numerals)
          (Function 623:54-64
            (ParserVar 623:54-59 maybe) [
              (String 623:60-63 "_")
            ])
        ])))
  
  (DeclareGlobal 625:0-94
    (ParserVar 625:0-26 _toml.number.exponent_part)
    (Merge 626:2-65
      (Merge 626:2-32
        (Or 626:2-13
          (String 626:3-6 "e")
          (String 626:9-12 "E"))
        (Function 626:16-32
          (ParserVar 626:16-21 maybe) [
            (Or 626:22-31
              (String 626:22-25 "-")
              (String 626:28-31 "+"))
          ]))
      (Function 626:35-65
        (ParserVar 626:35-43 many_sep) [
          (ParserVar 626:44-52 numerals)
          (Function 626:54-64
            (ParserVar 626:54-59 maybe) [
              (String 626:60-63 "_")
            ])
        ])))
  
  (DeclareGlobal 628:0-47
    (ParserVar 628:0-20 toml.number.infinity)
    (Merge 628:23-47
      (Function 628:23-39
        (ParserVar 628:23-28 maybe) [
          (Or 628:29-38
            (String 628:29-32 "+")
            (String 628:35-38 "-"))
        ])
      (String 628:42-47 "inf")))
  
  (DeclareGlobal 630:0-51
    (ParserVar 630:0-24 toml.number.not_a_number)
    (Merge 630:27-51
      (Function 630:27-43
        (ParserVar 630:27-32 maybe) [
          (Or 630:33-42
            (String 630:33-36 "+")
            (String 630:39-42 "-"))
        ])
      (String 630:46-51 "nan")))
  
  (DeclareGlobal 632:0-209
    (ParserVar 632:0-26 toml.number.binary_integer)
    (TakeRight 633:2-180
      (String 633:2-6 "0b")
      (Return 633:9-180
        (Destructure 633:9-147
          (Function 633:9-137
            (ParserVar 633:9-20 one_or_both) [
              (Merge 634:4-70
                (Function 634:4-28
                  (ParserVar 634:4-13 array_sep) [
                    (NumberString 634:14-15 0)
                    (Function 634:17-27
                      (ParserVar 634:17-22 maybe) [
                        (String 634:23-26 "_")
                      ])
                  ])
                (Function 634:31-70
                  (ParserVar 634:31-36 maybe) [
                    (TakeLeft 634:37-69
                      (Function 634:37-46
                        (ParserVar 634:37-41 skip) [
                          (String 634:42-45 "_")
                        ])
                      (Function 634:49-69
                        (ParserVar 634:49-53 peek) [
                          (ParserVar 634:54-68 binary_numeral)
                        ]))
                  ]))
              (Function 635:4-39
                (ParserVar 635:4-13 array_sep) [
                  (ParserVar 635:14-26 binary_digit)
                  (Function 635:28-38
                    (ParserVar 635:28-33 maybe) [
                      (String 635:34-37 "_")
                    ])
                ])
            ])
          (ValueVar 636:7-13 Digits))
        (Function 637:2-30
          (ValueVar 637:2-22 Num.FromBinaryDigits) [
            (ValueVar 637:23-29 Digits)
          ]))))
  
  (DeclareGlobal 639:0-205
    (ParserVar 639:0-25 toml.number.octal_integer)
    (TakeRight 640:2-177
      (String 640:2-6 "0o")
      (Return 640:9-177
        (Destructure 640:9-145
          (Function 640:9-135
            (ParserVar 640:9-20 one_or_both) [
              (Merge 641:4-69
                (Function 641:4-28
                  (ParserVar 641:4-13 array_sep) [
                    (NumberString 641:14-15 0)
                    (Function 641:17-27
                      (ParserVar 641:17-22 maybe) [
                        (String 641:23-26 "_")
                      ])
                  ])
                (Function 641:31-69
                  (ParserVar 641:31-36 maybe) [
                    (TakeLeft 641:37-68
                      (Function 641:37-46
                        (ParserVar 641:37-41 skip) [
                          (String 641:42-45 "_")
                        ])
                      (Function 641:49-68
                        (ParserVar 641:49-53 peek) [
                          (ParserVar 641:54-67 octal_numeral)
                        ]))
                  ]))
              (Function 642:4-38
                (ParserVar 642:4-13 array_sep) [
                  (ParserVar 642:14-25 octal_digit)
                  (Function 642:27-37
                    (ParserVar 642:27-32 maybe) [
                      (String 642:33-36 "_")
                    ])
                ])
            ])
          (ValueVar 643:7-13 Digits))
        (Function 644:2-29
          (ValueVar 644:2-21 Num.FromOctalDigits) [
            (ValueVar 644:22-28 Digits)
          ]))))
  
  (DeclareGlobal 646:0-197
    (ParserVar 646:0-23 toml.number.hex_integer)
    (TakeRight 647:2-171
      (String 647:2-6 "0x")
      (Return 647:9-171
        (Destructure 647:9-141
          (Function 647:9-131
            (ParserVar 647:9-20 one_or_both) [
              (Merge 648:4-67
                (Function 648:4-28
                  (ParserVar 648:4-13 array_sep) [
                    (NumberString 648:14-15 0)
                    (Function 648:17-27
                      (ParserVar 648:17-22 maybe) [
                        (String 648:23-26 "_")
                      ])
                  ])
                (Function 648:31-67
                  (ParserVar 648:31-36 maybe) [
                    (TakeLeft 648:37-66
                      (Function 648:37-46
                        (ParserVar 648:37-41 skip) [
                          (String 648:42-45 "_")
                        ])
                      (Function 648:49-66
                        (ParserVar 648:49-53 peek) [
                          (ParserVar 648:54-65 hex_numeral)
                        ]))
                  ]))
              (Function 649:4-36
                (ParserVar 649:4-13 array_sep) [
                  (ParserVar 649:14-23 hex_digit)
                  (Function 649:25-35
                    (ParserVar 649:25-30 maybe) [
                      (String 649:31-34 "_")
                    ])
                ])
            ])
          (ValueVar 650:7-13 Digits))
        (Function 651:2-27
          (ValueVar 651:2-19 Num.FromHexDigits) [
            (ValueVar 651:20-26 Digits)
          ]))))
  
  (DeclareGlobal 653:0-43
    (ValueVar 653:0-15 _Toml.Doc.Empty)
    (Object 653:18-43 [
      (ObjectPair (String 653:19-26 "value") (Object 653:28-31 []))
      (ObjectPair (String 653:32-38 "type") (Object 653:40-43 []))
    ]))
  
  (DeclareGlobal 655:0-44
    (Function 655:0-20
      (ValueVar 655:0-15 _Toml.Doc.Value) [
        (ValueVar 655:16-19 Doc)
      ])
    (Function 655:23-44
      (ValueVar 655:23-30 Obj.Get) [
        (ValueVar 655:31-34 Doc)
        (String 655:36-43 "value")
      ]))
  
  (DeclareGlobal 657:0-42
    (Function 657:0-19
      (ValueVar 657:0-14 _Toml.Doc.Type) [
        (ValueVar 657:15-18 Doc)
      ])
    (Function 657:22-42
      (ValueVar 657:22-29 Obj.Get) [
        (ValueVar 657:30-33 Doc)
        (String 657:35-41 "type")
      ]))
  
  (DeclareGlobal 659:0-59
    (Function 659:0-23
      (ValueVar 659:0-13 _Toml.Doc.Has) [
        (ValueVar 659:14-17 Doc)
        (ValueVar 659:19-22 Key)
      ])
    (Function 659:26-59
      (ValueVar 659:26-33 Obj.Has) [
        (Function 659:34-53
          (ValueVar 659:34-48 _Toml.Doc.Type) [
            (ValueVar 659:49-52 Doc)
          ])
        (ValueVar 659:55-58 Key)
      ]))
  
  (DeclareGlobal 661:0-121
    (Function 661:0-23
      (ValueVar 661:0-13 _Toml.Doc.Get) [
        (ValueVar 661:14-17 Doc)
        (ValueVar 661:19-22 Key)
      ])
    (Object 661:26-121 [
      (ObjectPair
        (String 662:2-9 "value")
        (Function 662:11-45
          (ValueVar 662:11-18 Obj.Get) [
            (Function 662:19-39
              (ValueVar 662:19-34 _Toml.Doc.Value) [
                (ValueVar 662:35-38 Doc)
              ])
            (ValueVar 662:41-44 Key)
          ]))
      (ObjectPair
        (String 663:2-8 "type")
        (Function 663:10-43
          (ValueVar 663:10-17 Obj.Get) [
            (Function 663:18-37
              (ValueVar 663:18-32 _Toml.Doc.Type) [
                (ValueVar 663:33-36 Doc)
              ])
            (ValueVar 663:39-42 Key)
          ]))
    ]))
  
  (DeclareGlobal 666:0-55
    (Function 666:0-22
      (ValueVar 666:0-17 _Toml.Doc.IsTable) [
        (ValueVar 666:18-21 Doc)
      ])
    (Function 666:25-55
      (ValueVar 666:25-34 Is.Object) [
        (Function 666:35-54
          (ValueVar 666:35-49 _Toml.Doc.Type) [
            (ValueVar 666:50-53 Doc)
          ])
      ]))
  
  (DeclareGlobal 668:0-181
    (Function 668:0-37
      (ValueVar 668:0-16 _Toml.Doc.Insert) [
        (ValueVar 668:17-20 Doc)
        (ValueVar 668:22-25 Key)
        (ValueVar 668:27-30 Val)
        (ValueVar 668:32-36 Type)
      ])
    (TakeRight 669:2-141
      (Function 669:2-24
        (ValueVar 669:2-19 _Toml.Doc.IsTable) [
          (ValueVar 669:20-23 Doc)
        ])
      (Object 670:2-114 [
        (ObjectPair
          (String 671:4-11 "value")
          (Function 671:13-52
            (ValueVar 671:13-20 Obj.Put) [
              (Function 671:21-41
                (ValueVar 671:21-36 _Toml.Doc.Value) [
                  (ValueVar 671:37-40 Doc)
                ])
              (ValueVar 671:43-46 Key)
              (ValueVar 671:48-51 Val)
            ]))
        (ObjectPair
          (String 672:4-10 "type")
          (Function 672:12-51
            (ValueVar 672:12-19 Obj.Put) [
              (Function 672:20-39
                (ValueVar 672:20-34 _Toml.Doc.Type) [
                  (ValueVar 672:35-38 Doc)
                ])
              (ValueVar 672:41-44 Key)
              (ValueVar 672:46-50 Type)
            ]))
      ])))
  
  (DeclareGlobal 675:0-184
    (Function 675:0-46
      (ValueVar 675:0-31 _Toml.Doc.AppendToArrayOfTables) [
        (ValueVar 675:32-35 Doc)
        (ValueVar 675:37-40 Key)
        (ValueVar 675:42-45 Val)
      ])
    (TakeRight 676:2-135
      (Destructure 676:2-70
        (Function 676:2-25
          (ValueVar 676:2-15 _Toml.Doc.Get) [
            (ValueVar 676:16-19 Doc)
            (ValueVar 676:21-24 Key)
          ])
        (Object 676:29-70 [
          (ObjectPair (String 676:30-37 "value") (ValueVar 676:39-42 AoT))
          (ObjectPair (String 676:44-50 "type") (String 676:52-69 "array_of_tables"))
        ]))
      (Function 677:2-62
        (ValueVar 677:2-18 _Toml.Doc.Insert) [
          (ValueVar 677:19-22 Doc)
          (ValueVar 677:24-27 Key)
          (Merge 677:29-42
            (Merge 677:29-30
              (Array 677:29-30 [])
              (ValueVar 677:33-36 AoT))
            (Array 677:38-42 [
              (ValueVar 677:38-41 Val)
            ]))
          (String 677:44-61 "array_of_tables")
        ])))
  
  (DeclareGlobal 679:0-105
    (Function 679:0-38
      (ValueVar 679:0-22 _Toml.Doc.InsertAtPath) [
        (ValueVar 679:23-26 Doc)
        (ValueVar 679:28-32 Path)
        (ValueVar 679:34-37 Val)
      ])
    (Function 680:2-64
      (ValueVar 680:2-24 _Toml.Doc.UpdateAtPath) [
        (ValueVar 680:25-28 Doc)
        (ValueVar 680:30-34 Path)
        (ValueVar 680:36-39 Val)
        (ValueVar 680:41-63 _Toml.Doc.ValueUpdater)
      ]))
  
  (DeclareGlobal 682:0-111
    (Function 682:0-38
      (ValueVar 682:0-27 _Toml.Doc.EnsureTableAtPath) [
        (ValueVar 682:28-31 Doc)
        (ValueVar 682:33-37 Path)
      ])
    (Function 683:2-70
      (ValueVar 683:2-24 _Toml.Doc.UpdateAtPath) [
        (ValueVar 683:25-28 Doc)
        (ValueVar 683:30-34 Path)
        (Object 683:36-39 [])
        (ValueVar 683:40-69 _Toml.Doc.MissingTableUpdater)
      ]))
  
  (DeclareGlobal 685:0-106
    (Function 685:0-38
      (ValueVar 685:0-22 _Toml.Doc.AppendAtPath) [
        (ValueVar 685:23-26 Doc)
        (ValueVar 685:28-32 Path)
        (ValueVar 685:34-37 Val)
      ])
    (Function 686:2-65
      (ValueVar 686:2-24 _Toml.Doc.UpdateAtPath) [
        (ValueVar 686:25-28 Doc)
        (ValueVar 686:30-34 Path)
        (ValueVar 686:36-39 Val)
        (ValueVar 686:41-64 _Toml.Doc.AppendUpdater)
      ]))
  
  (DeclareGlobal 688:0-494
    (Function 688:0-47
      (ValueVar 688:0-22 _Toml.Doc.UpdateAtPath) [
        (ValueVar 688:23-26 Doc)
        (ValueVar 688:28-32 Path)
        (ValueVar 688:34-37 Val)
        (ValueVar 688:39-46 Updater)
      ])
    (Conditional 689:2-444
      (Destructure 689:2-15
        (ValueVar 689:2-6 Path)
        (Array 689:10-15 [
          (ValueVar 689:11-14 Key)
        ]))
      (Function 689:18-40
        (ValueVar 689:18-25 Updater) [
          (ValueVar 689:26-29 Doc)
          (ValueVar 689:31-34 Key)
          (ValueVar 689:36-39 Val)
        ])
      (Conditional 690:2-401
        (Destructure 690:2-28
          (ValueVar 690:2-6 Path)
          (Merge 690:10-28
            (Array 690:10-11 [
              (ValueVar 690:11-14 Key)
            ])
            (ValueVar 690:19-27 PathRest)))
        (TakeRight 690:31-393
          (Destructure 691:4-270
            (Conditional 691:4-258
              (Function 692:6-29
                (ValueVar 692:6-19 _Toml.Doc.Has) [
                  (ValueVar 692:20-23 Doc)
                  (ValueVar 692:25-28 Key)
                ])
              (TakeRight 692:32-174
                (Function 693:8-50
                  (ValueVar 693:8-25 _Toml.Doc.IsTable) [
                    (Function 693:26-49
                      (ValueVar 693:26-39 _Toml.Doc.Get) [
                        (ValueVar 693:40-43 Doc)
                        (ValueVar 693:45-48 Key)
                      ])
                  ])
                (Function 694:8-79
                  (ValueVar 694:8-30 _Toml.Doc.UpdateAtPath) [
                    (Function 694:31-54
                      (ValueVar 694:31-44 _Toml.Doc.Get) [
                        (ValueVar 694:45-48 Doc)
                        (ValueVar 694:50-53 Key)
                      ])
                    (ValueVar 694:56-64 PathRest)
                    (ValueVar 694:66-69 Val)
                    (ValueVar 694:71-78 Updater)
                  ]))
              (Function 696:6-69
                (ValueVar 696:6-28 _Toml.Doc.UpdateAtPath) [
                  (ValueVar 696:29-44 _Toml.Doc.Empty)
                  (ValueVar 696:46-54 PathRest)
                  (ValueVar 696:56-59 Val)
                  (ValueVar 696:61-68 Updater)
                ]))
            (ValueVar 697:9-17 InnerDoc))
          (Function 698:4-83
            (ValueVar 698:4-20 _Toml.Doc.Insert) [
              (ValueVar 698:21-24 Doc)
              (ValueVar 698:26-29 Key)
              (Function 698:31-56
                (ValueVar 698:31-46 _Toml.Doc.Value) [
                  (ValueVar 698:47-55 InnerDoc)
                ])
              (Function 698:58-82
                (ValueVar 698:58-72 _Toml.Doc.Type) [
                  (ValueVar 698:73-81 InnerDoc)
                ])
            ]))
        (ValueVar 700:2-5 Doc))))
  
  (DeclareGlobal 702:0-116
    (Function 702:0-37
      (ValueVar 702:0-22 _Toml.Doc.ValueUpdater) [
        (ValueVar 702:23-26 Doc)
        (ValueVar 702:28-31 Key)
        (ValueVar 702:33-36 Val)
      ])
    (Conditional 703:2-76
      (Function 703:2-25
        (ValueVar 703:2-15 _Toml.Doc.Has) [
          (ValueVar 703:16-19 Doc)
          (ValueVar 703:21-24 Key)
        ])
      (ValueVar 703:28-33 @Fail)
      (Function 703:36-76
        (ValueVar 703:36-52 _Toml.Doc.Insert) [
          (ValueVar 703:53-56 Doc)
          (ValueVar 703:58-61 Key)
          (ValueVar 703:63-66 Val)
          (String 703:68-75 "value")
        ])))
  
  (DeclareGlobal 705:0-137
    (Function 705:0-45
      (ValueVar 705:0-29 _Toml.Doc.MissingTableUpdater) [
        (ValueVar 705:30-33 Doc)
        (ValueVar 705:35-38 Key)
        (ValueVar 705:40-44 _Val)
      ])
    (Conditional 706:2-89
      (Function 706:2-44
        (ValueVar 706:2-19 _Toml.Doc.IsTable) [
          (Function 706:20-43
            (ValueVar 706:20-33 _Toml.Doc.Get) [
              (ValueVar 706:34-37 Doc)
              (ValueVar 706:39-42 Key)
            ])
        ])
      (ValueVar 706:47-50 Doc)
      (Function 707:2-36
        (ValueVar 707:2-18 _Toml.Doc.Insert) [
          (ValueVar 707:19-22 Doc)
          (ValueVar 707:24-27 Key)
          (Object 707:29-32 [])
          (Object 707:33-36 [])
        ])))
  
  (DeclareGlobal 709:0-210
    (Function 709:0-38
      (ValueVar 709:0-23 _Toml.Doc.AppendUpdater) [
        (ValueVar 709:24-27 Doc)
        (ValueVar 709:29-32 Key)
        (ValueVar 709:34-37 Val)
      ])
    (TakeRight 710:2-169
      (Destructure 710:2-111
        (Conditional 710:2-97
          (Function 711:4-27
            (ValueVar 711:4-17 _Toml.Doc.Has) [
              (ValueVar 711:18-21 Doc)
              (ValueVar 711:23-26 Key)
            ])
          (ValueVar 711:30-33 Doc)
          (Function 712:4-53
            (ValueVar 712:4-20 _Toml.Doc.Insert) [
              (ValueVar 712:21-24 Doc)
              (ValueVar 712:26-29 Key)
              (Array 712:31-34 [])
              (String 712:35-52 "array_of_tables")
            ]))
        (ValueVar 713:7-17 DocWithKey))
      (Function 714:2-55
        (ValueVar 714:2-33 _Toml.Doc.AppendToArrayOfTables) [
          (ValueVar 714:34-44 DocWithKey)
          (ValueVar 714:46-49 Key)
          (ValueVar 714:51-54 Val)
        ])))
  
  (DeclareGlobal 719:0-129
    (Function 719:0-61
      (ParserVar 719:0-28 ast.with_operator_precedence) [
        (ParserVar 719:29-36 operand)
        (ParserVar 719:38-44 prefix)
        (ParserVar 719:46-51 infix)
        (ParserVar 719:53-60 postfix)
      ])
    (Function 720:2-65
      (ParserVar 720:2-28 _ast.with_precedence_start) [
        (ParserVar 720:29-36 operand)
        (ParserVar 720:38-44 prefix)
        (ParserVar 720:46-51 infix)
        (ParserVar 720:53-60 postfix)
        (ValueLabel 720:62-63 (NumberString 720:63-64 0))
      ]))
  
  (DeclareGlobal 722:0-509
    (Function 722:0-77
      (ParserVar 722:0-26 _ast.with_precedence_start) [
        (ParserVar 722:27-34 operand)
        (ParserVar 722:36-42 prefix)
        (ParserVar 722:44-49 infix)
        (ParserVar 722:51-58 postfix)
        (ValueVar 722:60-76 LeftBindingPower)
      ])
    (Conditional 723:2-429
      (Destructure 723:2-40
        (ParserVar 723:2-8 prefix)
        (Array 723:12-40 [
          (ValueVar 723:13-19 OpNode)
          (ValueVar 723:21-39 PrefixBindingPower)
        ]))
      (TakeRight 723:43-312
        (Destructure 724:4-117
          (Function 724:4-101
            (ParserVar 724:4-30 _ast.with_precedence_start) [
              (ParserVar 725:6-13 operand)
              (ParserVar 725:15-21 prefix)
              (ParserVar 725:23-28 infix)
              (ParserVar 725:30-37 postfix)
              (ValueVar 726:6-24 PrefixBindingPower)
            ])
          (ValueVar 727:9-21 PrefixedNode))
        (Function 728:4-143
          (ParserVar 728:4-29 _ast.with_precedence_rest) [
            (ParserVar 729:6-13 operand)
            (ParserVar 729:15-21 prefix)
            (ParserVar 729:23-28 infix)
            (ParserVar 729:30-37 postfix)
            (ValueVar 730:6-22 LeftBindingPower)
            (Merge 731:6-43
              (Merge 731:6-7
                (Object 731:6-7 [])
                (ValueVar 731:10-16 OpNode))
              (Object 731:18-43 [
                (ObjectPair (String 731:18-28 "prefixed") (ValueVar 731:30-42 PrefixedNode))
              ]))
          ]))
      (TakeRight 733:6-120
        (Destructure 734:4-19
          (ParserVar 734:4-11 operand)
          (ValueVar 734:15-19 Node))
        (Function 735:4-86
          (ParserVar 735:4-29 _ast.with_precedence_rest) [
            (ParserVar 735:30-37 operand)
            (ParserVar 735:39-45 prefix)
            (ParserVar 735:47-52 infix)
            (ParserVar 735:54-61 postfix)
            (ValueVar 735:63-79 LeftBindingPower)
            (ValueVar 735:81-85 Node)
          ]))))
  
  (DeclareGlobal 738:0-748
    (Function 738:0-82
      (ParserVar 738:0-25 _ast.with_precedence_rest) [
        (ParserVar 738:26-33 operand)
        (ParserVar 738:35-41 prefix)
        (ParserVar 738:43-48 infix)
        (ParserVar 738:50-57 postfix)
        (ValueVar 738:59-75 LeftBindingPower)
        (ValueVar 738:77-81 Node)
      ])
    (Conditional 739:2-663
      (TakeRight 739:2-100
        (Destructure 739:2-40
          (ParserVar 739:2-9 postfix)
          (Array 739:13-40 [
            (ValueVar 739:14-20 OpNode)
            (ValueVar 739:22-39 RightBindingPower)
          ]))
        (Function 740:2-57
          (ParserVar 740:2-7 const) [
            (Function 740:8-56
              (ValueVar 740:8-19 Is.LessThan) [
                (ValueVar 740:20-36 LeftBindingPower)
                (ValueVar 740:38-55 RightBindingPower)
              ])
          ]))
      (Function 740:60-202
        (ParserVar 741:4-29 _ast.with_precedence_rest) [
          (ParserVar 742:6-13 operand)
          (ParserVar 742:15-21 prefix)
          (ParserVar 742:23-28 infix)
          (ParserVar 742:30-37 postfix)
          (ValueVar 743:6-22 LeftBindingPower)
          (Merge 744:6-36
            (Merge 744:6-7
              (Object 744:6-7 [])
              (ValueVar 744:10-16 OpNode))
            (Object 744:18-36 [
              (ObjectPair (String 744:18-29 "postfixed") (ValueVar 744:31-35 Node))
            ]))
        ])
      (Conditional 747:2-415
        (TakeRight 747:2-120
          (Destructure 747:2-60
            (ParserVar 747:2-7 infix)
            (Array 747:11-60 [
              (ValueVar 747:12-18 OpNode)
              (ValueVar 747:20-37 RightBindingPower)
              (ValueVar 747:39-59 NextLeftBindingPower)
            ]))
          (Function 748:2-57
            (ParserVar 748:2-7 const) [
              (Function 748:8-56
                (ValueVar 748:8-19 Is.LessThan) [
                  (ValueVar 748:20-36 LeftBindingPower)
                  (ValueVar 748:38-55 RightBindingPower)
                ])
            ]))
        (TakeRight 748:60-336
          (Destructure 749:4-116
            (Function 749:4-103
              (ParserVar 749:4-30 _ast.with_precedence_start) [
                (ParserVar 750:6-13 operand)
                (ParserVar 750:15-21 prefix)
                (ParserVar 750:23-28 infix)
                (ParserVar 750:30-37 postfix)
                (ValueVar 751:6-26 NextLeftBindingPower)
              ])
            (ValueVar 752:9-18 RightNode))
          (Function 753:4-151
            (ParserVar 753:4-29 _ast.with_precedence_rest) [
              (ParserVar 754:6-13 operand)
              (ParserVar 754:15-21 prefix)
              (ParserVar 754:23-28 infix)
              (ParserVar 754:30-37 postfix)
              (ValueVar 755:6-22 LeftBindingPower)
              (Merge 756:6-51
                (Merge 756:6-7
                  (Object 756:6-7 [])
                  (ValueVar 756:10-16 OpNode))
                (Object 756:18-51 [
                  (ObjectPair (String 756:18-24 "left") (ValueVar 756:26-30 Node))
                  (ObjectPair (String 756:32-39 "right") (ValueVar 756:41-50 RightNode))
                ]))
            ]))
        (Function 759:2-13
          (ParserVar 759:2-7 const) [
            (ValueVar 759:8-12 Node)
          ]))))
  
  (DeclareGlobal 761:0-73
    (Function 761:0-21
      (ParserVar 761:0-8 ast.node) [
        (ValueVar 761:9-13 Type)
        (ParserVar 761:15-20 value)
      ])
    (Return 762:2-49
      (Destructure 762:2-16
        (ParserVar 762:2-7 value)
        (ValueVar 762:11-16 Value))
      (Object 762:19-49 [
        (ObjectPair (String 762:20-26 "type") (ValueVar 762:28-32 Type))
        (ObjectPair (String 762:34-41 "value") (ValueVar 762:43-48 Value))
      ])))
  
  (DeclareGlobal 768:0-14
    (ValueVar 768:0-7 Num.Add)
    (ValueVar 768:10-14 @Add))
  
  (DeclareGlobal 770:0-19
    (ValueVar 770:0-7 Num.Sub)
    (ValueVar 770:10-19 @Subtract))
  
  (DeclareGlobal 772:0-19
    (ValueVar 772:0-7 Num.Mul)
    (ValueVar 772:10-19 @Multiply))
  
  (DeclareGlobal 774:0-17
    (ValueVar 774:0-7 Num.Div)
    (ValueVar 774:10-17 @Divide))
  
  (DeclareGlobal 776:0-16
    (ValueVar 776:0-7 Num.Pow)
    (ValueVar 776:10-16 @Power))
  
  (DeclareGlobal 778:0-23
    (Function 778:0-10
      (ValueVar 778:0-7 Num.Inc) [
        (ValueVar 778:8-9 N)
      ])
    (Function 778:13-23
      (ValueVar 778:13-17 @Add) [
        (ValueVar 778:18-19 N)
        (NumberString 778:21-22 1)
      ]))
  
  (DeclareGlobal 780:0-28
    (Function 780:0-10
      (ValueVar 780:0-7 Num.Dec) [
        (ValueVar 780:8-9 N)
      ])
    (Function 780:13-28
      (ValueVar 780:13-22 @Subtract) [
        (ValueVar 780:23-24 N)
        (NumberString 780:26-27 1)
      ]))
  
  (DeclareGlobal 782:0-26
    (Function 782:0-10
      (ValueVar 782:0-7 Num.Abs) [
        (ValueVar 782:8-9 N)
      ])
    (Or 782:13-26
      (Destructure 782:13-21
        (ValueVar 782:13-14 N)
        (Range 782:18-21 (NumberString 782:18-19 0) ()))
      (Negation 782:24-26 (ValueVar 782:25-26 N))))
  
  (DeclareGlobal 784:0-32
    (Function 784:0-13
      (ValueVar 784:0-7 Num.Max) [
        (ValueVar 784:8-9 A)
        (ValueVar 784:11-12 B)
      ])
    (Conditional 784:16-32
      (Destructure 784:16-24
        (ValueVar 784:16-17 A)
        (Range 784:21-24 (ValueVar 784:21-22 B) ()))
      (ValueVar 784:27-28 A)
      (ValueVar 784:31-32 B)))
  
  (DeclareGlobal 786:0-94
    (Function 786:0-24
      (ValueVar 786:0-20 Num.FromBinaryDigits) [
        (ValueVar 786:21-23 Bs)
      ])
    (TakeRight 787:2-67
      (Destructure 787:2-25
        (Function 787:2-18
          (ValueVar 787:2-14 Array.Length) [
            (ValueVar 787:15-17 Bs)
          ])
        (ValueVar 787:22-25 Len))
      (Function 788:2-39
        (ValueVar 788:2-23 _Num.FromBinaryDigits) [
          (ValueVar 788:24-26 Bs)
          (NumberSubtract 788:28-35
            (ValueVar 788:28-31 Len)
            (NumberString 788:34-35 1))
          (NumberString 788:37-38 0)
        ])))
  
  (DeclareGlobal 790:0-191
    (Function 790:0-35
      (ValueVar 790:0-21 _Num.FromBinaryDigits) [
        (ValueVar 790:22-24 Bs)
        (ValueVar 790:26-29 Pos)
        (ValueVar 790:31-34 Acc)
      ])
    (Conditional 791:2-153
      (Destructure 791:2-20
        (ValueVar 791:2-4 Bs)
        (Merge 791:8-20
          (Array 791:8-9 [
            (ValueVar 791:9-10 B)
          ])
          (ValueVar 791:15-19 Rest)))
      (TakeRight 791:23-145
        (Destructure 792:4-13
          (ValueVar 792:4-5 B)
          (Range 792:9-13 (NumberString 792:9-10 0) (NumberString 792:12-13 1)))
        (Function 793:4-100
          (ValueVar 793:4-25 _Num.FromBinaryDigits) [
            (ValueVar 794:6-10 Rest)
            (NumberSubtract 795:6-13
              (ValueVar 795:6-9 Pos)
              (NumberString 795:12-13 1))
            (Merge 796:6-39
              (ValueVar 796:6-9 Acc)
              (Function 796:12-39
                (ValueVar 796:12-19 Num.Mul) [
                  (ValueVar 796:20-21 B)
                  (Function 796:23-38
                    (ValueVar 796:23-30 Num.Pow) [
                      (NumberString 796:31-32 2)
                      (ValueVar 796:34-37 Pos)
                    ])
                ]))
          ]))
      (ValueVar 799:2-5 Acc)))
  
  (DeclareGlobal 801:0-92
    (Function 801:0-23
      (ValueVar 801:0-19 Num.FromOctalDigits) [
        (ValueVar 801:20-22 Os)
      ])
    (TakeRight 802:2-66
      (Destructure 802:2-25
        (Function 802:2-18
          (ValueVar 802:2-14 Array.Length) [
            (ValueVar 802:15-17 Os)
          ])
        (ValueVar 802:22-25 Len))
      (Function 803:2-38
        (ValueVar 803:2-22 _Num.FromOctalDigits) [
          (ValueVar 803:23-25 Os)
          (NumberSubtract 803:27-34
            (ValueVar 803:27-30 Len)
            (NumberString 803:33-34 1))
          (NumberString 803:36-37 0)
        ])))
  
  (DeclareGlobal 805:0-189
    (Function 805:0-34
      (ValueVar 805:0-20 _Num.FromOctalDigits) [
        (ValueVar 805:21-23 Os)
        (ValueVar 805:25-28 Pos)
        (ValueVar 805:30-33 Acc)
      ])
    (Conditional 806:2-152
      (Destructure 806:2-20
        (ValueVar 806:2-4 Os)
        (Merge 806:8-20
          (Array 806:8-9 [
            (ValueVar 806:9-10 O)
          ])
          (ValueVar 806:15-19 Rest)))
      (TakeRight 806:23-144
        (Destructure 807:4-13
          (ValueVar 807:4-5 O)
          (Range 807:9-13 (NumberString 807:9-10 0) (NumberString 807:12-13 7)))
        (Function 808:4-99
          (ValueVar 808:4-24 _Num.FromOctalDigits) [
            (ValueVar 809:6-10 Rest)
            (NumberSubtract 810:6-13
              (ValueVar 810:6-9 Pos)
              (NumberString 810:12-13 1))
            (Merge 811:6-39
              (ValueVar 811:6-9 Acc)
              (Function 811:12-39
                (ValueVar 811:12-19 Num.Mul) [
                  (ValueVar 811:20-21 O)
                  (Function 811:23-38
                    (ValueVar 811:23-30 Num.Pow) [
                      (NumberString 811:31-32 8)
                      (ValueVar 811:34-37 Pos)
                    ])
                ]))
          ]))
      (ValueVar 814:2-5 Acc)))
  
  (DeclareGlobal 816:0-88
    (Function 816:0-21
      (ValueVar 816:0-17 Num.FromHexDigits) [
        (ValueVar 816:18-20 Hs)
      ])
    (TakeRight 817:2-64
      (Destructure 817:2-25
        (Function 817:2-18
          (ValueVar 817:2-14 Array.Length) [
            (ValueVar 817:15-17 Hs)
          ])
        (ValueVar 817:22-25 Len))
      (Function 818:2-36
        (ValueVar 818:2-20 _Num.FromHexDigits) [
          (ValueVar 818:21-23 Hs)
          (NumberSubtract 818:25-32
            (ValueVar 818:25-28 Len)
            (NumberString 818:31-32 1))
          (NumberString 818:34-35 0)
        ])))
  
  (DeclareGlobal 820:0-187
    (Function 820:0-32
      (ValueVar 820:0-18 _Num.FromHexDigits) [
        (ValueVar 820:19-21 Hs)
        (ValueVar 820:23-26 Pos)
        (ValueVar 820:28-31 Acc)
      ])
    (Conditional 821:2-152
      (Destructure 821:2-20
        (ValueVar 821:2-4 Hs)
        (Merge 821:8-20
          (Array 821:8-9 [
            (ValueVar 821:9-10 H)
          ])
          (ValueVar 821:15-19 Rest)))
      (TakeRight 821:23-144
        (Destructure 822:4-14
          (ValueVar 822:4-5 H)
          (Range 822:9-14 (NumberString 822:9-10 0) (NumberString 822:12-14 15)))
        (Function 823:4-98
          (ValueVar 823:4-22 _Num.FromHexDigits) [
            (ValueVar 824:6-10 Rest)
            (NumberSubtract 825:6-13
              (ValueVar 825:6-9 Pos)
              (NumberString 825:12-13 1))
            (Merge 826:6-40
              (ValueVar 826:6-9 Acc)
              (Function 826:12-40
                (ValueVar 826:12-19 Num.Mul) [
                  (ValueVar 826:20-21 H)
                  (Function 826:23-39
                    (ValueVar 826:23-30 Num.Pow) [
                      (NumberString 826:31-33 16)
                      (ValueVar 826:35-38 Pos)
                    ])
                ]))
          ]))
      (ValueVar 829:2-5 Acc)))
  
  (DeclareGlobal 833:0-43
    (Function 833:0-18
      (ValueVar 833:0-11 Array.First) [
        (ValueVar 833:12-17 Array)
      ])
    (TakeRight 833:21-43
      (Destructure 833:21-39
        (ValueVar 833:21-26 Array)
        (Merge 833:30-39
          (Array 833:30-31 [
            (ValueVar 833:31-32 F)
          ])
          (ValueVar 833:37-38 _)))
      (ValueVar 833:42-43 F)))
  
  (DeclareGlobal 835:0-42
    (Function 835:0-17
      (ValueVar 835:0-10 Array.Rest) [
        (ValueVar 835:11-16 Array)
      ])
    (TakeRight 835:20-42
      (Destructure 835:20-38
        (ValueVar 835:20-25 Array)
        (Merge 835:29-38
          (Array 835:29-30 [
            (ValueVar 835:30-31 _)
          ])
          (ValueVar 835:36-37 R)))
      (ValueVar 835:41-42 R)))
  
  (DeclareGlobal 837:0-37
    (Function 837:0-15
      (ValueVar 837:0-12 Array.Length) [
        (ValueVar 837:13-14 A)
      ])
    (Function 837:18-37
      (ValueVar 837:18-31 _Array.Length) [
        (ValueVar 837:32-33 A)
        (NumberString 837:35-36 0)
      ]))
  
  (DeclareGlobal 839:0-84
    (Function 839:0-21
      (ValueVar 839:0-13 _Array.Length) [
        (ValueVar 839:14-15 A)
        (ValueVar 839:17-20 Acc)
      ])
    (Conditional 840:2-60
      (Destructure 840:2-19
        (ValueVar 840:2-3 A)
        (Merge 840:7-19
          (Array 840:7-8 [
            (ValueVar 840:8-9 _)
          ])
          (ValueVar 840:14-18 Rest)))
      (Function 841:2-30
        (ValueVar 841:2-15 _Array.Length) [
          (ValueVar 841:16-20 Rest)
          (Merge 841:22-29
            (ValueVar 841:22-25 Acc)
            (NumberString 841:28-29 1))
        ])
      (ValueVar 842:2-5 Acc)))
  
  (DeclareGlobal 844:0-40
    (Function 844:0-16
      (ValueVar 844:0-13 Array.Reverse) [
        (ValueVar 844:14-15 A)
      ])
    (Function 844:19-40
      (ValueVar 844:19-33 _Array.Reverse) [
        (ValueVar 844:34-35 A)
        (Array 844:37-40 [])
      ]))
  
  (DeclareGlobal 846:0-98
    (Function 846:0-22
      (ValueVar 846:0-14 _Array.Reverse) [
        (ValueVar 846:15-16 A)
        (ValueVar 846:18-21 Acc)
      ])
    (Conditional 847:2-73
      (Destructure 847:2-23
        (ValueVar 847:2-3 A)
        (Merge 847:7-23
          (Array 847:7-8 [
            (ValueVar 847:8-13 First)
          ])
          (ValueVar 847:18-22 Rest)))
      (Function 848:2-39
        (ValueVar 848:2-16 _Array.Reverse) [
          (ValueVar 848:17-21 Rest)
          (Merge 848:23-38
            (Array 848:23-24 [
              (ValueVar 848:24-29 First)
            ])
            (ValueVar 848:34-37 Acc))
        ])
      (ValueVar 849:2-5 Acc)))
  
  (DeclareGlobal 851:0-40
    (Function 851:0-16
      (ValueVar 851:0-9 Array.Map) [
        (ValueVar 851:10-11 A)
        (ValueVar 851:13-15 Fn)
      ])
    (Function 851:19-40
      (ValueVar 851:19-29 _Array.Map) [
        (ValueVar 851:30-31 A)
        (ValueVar 851:33-35 Fn)
        (Array 851:37-40 [])
      ]))
  
  (DeclareGlobal 853:0-102
    (Function 853:0-22
      (ValueVar 853:0-10 _Array.Map) [
        (ValueVar 853:11-12 A)
        (ValueVar 853:14-16 Fn)
        (ValueVar 853:18-21 Acc)
      ])
    (Conditional 854:2-77
      (Destructure 854:2-23
        (ValueVar 854:2-3 A)
        (Merge 854:7-23
          (Array 854:7-8 [
            (ValueVar 854:8-13 First)
          ])
          (ValueVar 854:18-22 Rest)))
      (Function 855:2-43
        (ValueVar 855:2-12 _Array.Map) [
          (ValueVar 855:13-17 Rest)
          (ValueVar 855:19-21 Fn)
          (Merge 855:23-42
            (Merge 855:23-24
              (Array 855:23-24 [])
              (ValueVar 855:27-30 Acc))
            (Array 855:32-42 [
              (Function 855:32-41
                (ValueVar 855:32-34 Fn) [
                  (ValueVar 855:35-40 First)
                ])
            ]))
        ])
      (ValueVar 856:2-5 Acc)))
  
  (DeclareGlobal 858:0-50
    (Function 858:0-21
      (ValueVar 858:0-12 Array.Filter) [
        (ValueVar 858:13-14 A)
        (ValueVar 858:16-20 Pred)
      ])
    (Function 858:24-50
      (ValueVar 858:24-37 _Array.Filter) [
        (ValueVar 858:38-39 A)
        (ValueVar 858:41-45 Pred)
        (Array 858:47-50 [])
      ]))
  
  (DeclareGlobal 860:0-128
    (Function 860:0-27
      (ValueVar 860:0-13 _Array.Filter) [
        (ValueVar 860:14-15 A)
        (ValueVar 860:17-21 Pred)
        (ValueVar 860:23-26 Acc)
      ])
    (Conditional 861:2-98
      (Destructure 861:2-23
        (ValueVar 861:2-3 A)
        (Merge 861:7-23
          (Array 861:7-8 [
            (ValueVar 861:8-13 First)
          ])
          (ValueVar 861:18-22 Rest)))
      (Function 862:2-64
        (ValueVar 862:2-15 _Array.Filter) [
          (ValueVar 862:16-20 Rest)
          (ValueVar 862:22-26 Pred)
          (Conditional 862:28-63
            (Function 862:28-39
              (ValueVar 862:28-32 Pred) [
                (ValueVar 862:33-38 First)
              ])
            (Merge 862:42-57
              (Merge 862:42-43
                (Array 862:42-43 [])
                (ValueVar 862:46-49 Acc))
              (Array 862:51-57 [
                (ValueVar 862:51-56 First)
              ]))
            (ValueVar 862:60-63 Acc))
        ])
      (ValueVar 863:2-5 Acc)))
  
  (DeclareGlobal 865:0-50
    (Function 865:0-21
      (ValueVar 865:0-12 Array.Reject) [
        (ValueVar 865:13-14 A)
        (ValueVar 865:16-20 Pred)
      ])
    (Function 865:24-50
      (ValueVar 865:24-37 _Array.Reject) [
        (ValueVar 865:38-39 A)
        (ValueVar 865:41-45 Pred)
        (Array 865:47-50 [])
      ]))
  
  (DeclareGlobal 867:0-128
    (Function 867:0-27
      (ValueVar 867:0-13 _Array.Reject) [
        (ValueVar 867:14-15 A)
        (ValueVar 867:17-21 Pred)
        (ValueVar 867:23-26 Acc)
      ])
    (Conditional 868:2-98
      (Destructure 868:2-23
        (ValueVar 868:2-3 A)
        (Merge 868:7-23
          (Array 868:7-8 [
            (ValueVar 868:8-13 First)
          ])
          (ValueVar 868:18-22 Rest)))
      (Function 869:2-64
        (ValueVar 869:2-15 _Array.Reject) [
          (ValueVar 869:16-20 Rest)
          (ValueVar 869:22-26 Pred)
          (Conditional 869:28-63
            (Function 869:28-39
              (ValueVar 869:28-32 Pred) [
                (ValueVar 869:33-38 First)
              ])
            (ValueVar 869:42-45 Acc)
            (Merge 869:48-63
              (Merge 869:48-49
                (Array 869:48-49 [])
                (ValueVar 869:52-55 Acc))
              (Array 869:57-63 [
                (ValueVar 869:57-62 First)
              ])))
        ])
      (ValueVar 870:2-5 Acc)))
  
  (DeclareGlobal 872:0-54
    (Function 872:0-23
      (ValueVar 872:0-15 Array.ZipObject) [
        (ValueVar 872:16-18 Ks)
        (ValueVar 872:20-22 Vs)
      ])
    (Function 872:26-54
      (ValueVar 872:26-42 _Array.ZipObject) [
        (ValueVar 872:43-45 Ks)
        (ValueVar 872:47-49 Vs)
        (Object 872:51-54 [])
      ]))
  
  (DeclareGlobal 874:0-138
    (Function 874:0-29
      (ValueVar 874:0-16 _Array.ZipObject) [
        (ValueVar 874:17-19 Ks)
        (ValueVar 874:21-23 Vs)
        (ValueVar 874:25-28 Acc)
      ])
    (Conditional 875:2-106
      (TakeRight 875:2-45
        (Destructure 875:2-22
          (ValueVar 875:2-4 Ks)
          (Merge 875:8-22
            (Array 875:8-9 [
              (ValueVar 875:9-10 K)
            ])
            (ValueVar 875:15-21 KsRest)))
        (Destructure 875:25-45
          (ValueVar 875:25-27 Vs)
          (Merge 875:31-45
            (Array 875:31-32 [
              (ValueVar 875:32-33 V)
            ])
            (ValueVar 875:38-44 VsRest))))
      (Function 876:2-50
        (ValueVar 876:2-18 _Array.ZipObject) [
          (ValueVar 876:19-25 KsRest)
          (ValueVar 876:27-33 VsRest)
          (Merge 876:35-49
            (Merge 876:35-36
              (Object 876:35-36 [])
              (ValueVar 876:39-42 Acc))
            (Object 876:44-49 [
              (ObjectPair (ValueVar 876:44-45 K) (ValueVar 876:47-48 V))
            ]))
        ])
      (ValueVar 877:2-5 Acc)))
  
  (DeclareGlobal 879:0-52
    (Function 879:0-22
      (ValueVar 879:0-14 Array.ZipPairs) [
        (ValueVar 879:15-17 A1)
        (ValueVar 879:19-21 A2)
      ])
    (Function 879:25-52
      (ValueVar 879:25-40 _Array.ZipPairs) [
        (ValueVar 879:41-43 A1)
        (ValueVar 879:45-47 A2)
        (Array 879:49-52 [])
      ]))
  
  (DeclareGlobal 881:0-154
    (Function 881:0-28
      (ValueVar 881:0-15 _Array.ZipPairs) [
        (ValueVar 881:16-18 A1)
        (ValueVar 881:20-22 A2)
        (ValueVar 881:24-27 Acc)
      ])
    (Conditional 882:2-123
      (TakeRight 882:2-53
        (Destructure 882:2-26
          (ValueVar 882:2-4 A1)
          (Merge 882:8-26
            (Array 882:8-9 [
              (ValueVar 882:9-15 First1)
            ])
            (ValueVar 882:20-25 Rest1)))
        (Destructure 882:29-53
          (ValueVar 882:29-31 A2)
          (Merge 882:35-53
            (Array 882:35-36 [
              (ValueVar 882:36-42 First2)
            ])
            (ValueVar 882:47-52 Rest2))))
      (Function 883:2-59
        (ValueVar 883:2-17 _Array.ZipPairs) [
          (ValueVar 883:18-23 Rest1)
          (ValueVar 883:25-30 Rest2)
          (Merge 883:32-58
            (Merge 883:32-33
              (Array 883:32-33 [])
              (ValueVar 883:36-39 Acc))
            (Array 883:41-58 [
              (Array 883:41-57 [
                (ValueVar 883:42-48 First1)
                (ValueVar 883:50-56 First2)
              ])
            ]))
        ])
      (ValueVar 884:2-5 Acc)))
  
  (DeclareGlobal 886:0-42
    (Function 886:0-24
      (ValueVar 886:0-13 Array.AppendN) [
        (ValueVar 886:14-15 A)
        (ValueVar 886:17-20 Val)
        (ValueVar 886:22-23 N)
      ])
    (Merge 886:27-42
      (ValueVar 886:27-28 A)
      (Repeat 886:31-42
        (Array 886:32-37 [
          (ValueVar 886:33-36 Val)
        ])
        (ValueVar 886:40-41 N))))
  
  (DeclareGlobal 888:0-44
    (Function 888:0-18
      (ValueVar 888:0-15 Table.Transpose) [
        (ValueVar 888:16-17 T)
      ])
    (Function 888:21-44
      (ValueVar 888:21-37 _Table.Transpose) [
        (ValueVar 888:38-39 T)
        (Array 888:41-44 [])
      ]))
  
  (DeclareGlobal 890:0-168
    (Function 890:0-24
      (ValueVar 890:0-16 _Table.Transpose) [
        (ValueVar 890:17-18 T)
        (ValueVar 890:20-23 Acc)
      ])
    (Conditional 891:2-141
      (TakeRight 891:2-77
        (Destructure 891:2-38
          (Function 891:2-23
            (ValueVar 891:2-20 _Table.FirstPerRow) [
              (ValueVar 891:21-22 T)
            ])
          (ValueVar 891:27-38 FirstPerRow))
        (Destructure 892:2-36
          (Function 892:2-22
            (ValueVar 892:2-19 _Table.RestPerRow) [
              (ValueVar 892:20-21 T)
            ])
          (ValueVar 892:26-36 RestPerRow)))
      (Function 893:2-53
        (ValueVar 893:2-18 _Table.Transpose) [
          (ValueVar 893:19-29 RestPerRow)
          (Merge 893:31-52
            (Merge 893:31-32
              (Array 893:31-32 [])
              (ValueVar 893:35-38 Acc))
            (Array 893:40-52 [
              (ValueVar 893:40-51 FirstPerRow)
            ]))
        ])
      (ValueVar 894:2-5 Acc)))
  
  (DeclareGlobal 896:0-115
    (Function 896:0-21
      (ValueVar 896:0-18 _Table.FirstPerRow) [
        (ValueVar 896:19-20 T)
      ])
    (TakeRight 897:2-91
      (TakeRight 897:2-48
        (Destructure 897:2-21
          (ValueVar 897:2-3 T)
          (Merge 897:7-21
            (Array 897:7-8 [
              (ValueVar 897:8-11 Row)
            ])
            (ValueVar 897:16-20 Rest)))
        (Destructure 897:24-48
          (ValueVar 897:24-27 Row)
          (Merge 897:31-48
            (Array 897:31-32 [
              (ValueVar 897:32-41 VeryFirst)
            ])
            (ValueVar 897:46-47 _))))
      (Function 898:2-40
        (ValueVar 898:2-21 __Table.FirstPerRow) [
          (ValueVar 898:22-26 Rest)
          (Array 898:28-39 [
            (ValueVar 898:29-38 VeryFirst)
          ])
        ])))
  
  (DeclareGlobal 900:0-129
    (Function 900:0-27
      (ValueVar 900:0-19 __Table.FirstPerRow) [
        (ValueVar 900:20-21 T)
        (ValueVar 900:23-26 Acc)
      ])
    (Conditional 901:2-99
      (TakeRight 901:2-44
        (Destructure 901:2-21
          (ValueVar 901:2-3 T)
          (Merge 901:7-21
            (Array 901:7-8 [
              (ValueVar 901:8-11 Row)
            ])
            (ValueVar 901:16-20 Rest)))
        (Destructure 901:24-44
          (ValueVar 901:24-27 Row)
          (Merge 901:31-44
            (Array 901:31-32 [
              (ValueVar 901:32-37 First)
            ])
            (ValueVar 901:42-43 _))))
      (Function 902:2-44
        (ValueVar 902:2-21 __Table.FirstPerRow) [
          (ValueVar 902:22-26 Rest)
          (Merge 902:28-43
            (Merge 902:28-29
              (Array 902:28-29 [])
              (ValueVar 902:32-35 Acc))
            (Array 902:37-43 [
              (ValueVar 902:37-42 First)
            ]))
        ])
      (ValueVar 903:2-5 Acc)))
  
  (DeclareGlobal 905:0-48
    (Function 905:0-20
      (ValueVar 905:0-17 _Table.RestPerRow) [
        (ValueVar 905:18-19 T)
      ])
    (Function 905:23-48
      (ValueVar 905:23-41 __Table.RestPerRow) [
        (ValueVar 905:42-43 T)
        (Array 905:45-48 [])
      ]))
  
  (DeclareGlobal 907:0-188
    (Function 907:0-26
      (ValueVar 907:0-18 __Table.RestPerRow) [
        (ValueVar 907:19-20 T)
        (ValueVar 907:22-25 Acc)
      ])
    (Conditional 908:2-159
      (Destructure 908:2-21
        (ValueVar 908:2-3 T)
        (Merge 908:7-21
          (Array 908:7-8 [
            (ValueVar 908:8-11 Row)
          ])
          (ValueVar 908:16-20 Rest)))
      (Conditional 908:24-151
        (Destructure 909:4-26
          (ValueVar 909:4-7 Row)
          (Merge 909:11-26
            (Array 909:11-12 [
              (ValueVar 909:12-13 _)
            ])
            (ValueVar 909:18-25 RowRest)))
        (Function 910:4-47
          (ValueVar 910:4-22 __Table.RestPerRow) [
            (ValueVar 910:23-27 Rest)
            (Merge 910:29-46
              (Merge 910:29-30
                (Array 910:29-30 [])
                (ValueVar 910:33-36 Acc))
              (Array 910:38-46 [
                (ValueVar 910:38-45 RowRest)
              ]))
          ])
        (Function 911:4-42
          (ValueVar 911:4-22 __Table.RestPerRow) [
            (ValueVar 911:23-27 Rest)
            (Merge 911:29-41
              (Merge 911:29-30
                (Array 911:29-30 [])
                (ValueVar 911:33-36 Acc))
              (Array 911:38-41 [
                (Array 911:38-41 [])
              ]))
          ]))
      (ValueVar 913:2-5 Acc)))
  
  (DeclareGlobal 915:0-71
    (Function 915:0-24
      (ValueVar 915:0-21 Table.RotateClockwise) [
        (ValueVar 915:22-23 T)
      ])
    (Function 915:27-71
      (ValueVar 915:27-36 Array.Map) [
        (Function 915:37-55
          (ValueVar 915:37-52 Table.Transpose) [
            (ValueVar 915:53-54 T)
          ])
        (ValueVar 915:57-70 Array.Reverse)
      ]))
  
  (DeclareGlobal 917:0-67
    (Function 917:0-31
      (ValueVar 917:0-28 Table.RotateCounterClockwise) [
        (ValueVar 917:29-30 T)
      ])
    (Function 917:34-67
      (ValueVar 917:34-47 Array.Reverse) [
        (Function 917:48-66
          (ValueVar 917:48-63 Table.Transpose) [
            (ValueVar 917:64-65 T)
          ])
      ]))
  
  (DeclareGlobal 919:0-60
    (Function 919:0-26
      (ValueVar 919:0-16 Table.ZipObjects) [
        (ValueVar 919:17-19 Ks)
        (ValueVar 919:21-25 Rows)
      ])
    (Function 919:29-60
      (ValueVar 919:29-46 _Table.ZipObjects) [
        (ValueVar 919:47-49 Ks)
        (ValueVar 919:51-55 Rows)
        (Array 919:57-60 [])
      ]))
  
  (DeclareGlobal 921:0-135
    (Function 921:0-32
      (ValueVar 921:0-17 _Table.ZipObjects) [
        (ValueVar 921:18-20 Ks)
        (ValueVar 921:22-26 Rows)
        (ValueVar 921:28-31 Acc)
      ])
    (Conditional 922:2-100
      (Destructure 922:2-24
        (ValueVar 922:2-6 Rows)
        (Merge 922:10-24
          (Array 922:10-11 [
            (ValueVar 922:11-14 Row)
          ])
          (ValueVar 922:19-23 Rest)))
      (Function 923:2-65
        (ValueVar 923:2-19 _Table.ZipObjects) [
          (ValueVar 923:20-22 Ks)
          (ValueVar 923:24-28 Rest)
          (Merge 923:30-64
            (Merge 923:30-31
              (Array 923:30-31 [])
              (ValueVar 923:34-37 Acc))
            (Array 923:39-64 [
              (Function 923:39-63
                (ValueVar 923:39-54 Array.ZipObject) [
                  (ValueVar 923:55-57 Ks)
                  (ValueVar 923:59-62 Row)
                ])
            ]))
        ])
      (ValueVar 924:2-5 Acc)))
  
  (DeclareGlobal 928:0-33
    (Function 928:0-13
      (ValueVar 928:0-7 Obj.Has) [
        (ValueVar 928:8-9 O)
        (ValueVar 928:11-12 K)
      ])
    (Destructure 928:16-33
      (ValueVar 928:16-17 O)
      (Merge 928:21-33
        (Object 928:21-31 [
          (ObjectPair (ValueVar 928:22-23 K) (ValueVar 928:25-26 _))
        ])
        (ValueVar 928:31-32 _))))
  
  (DeclareGlobal 930:0-37
    (Function 930:0-13
      (ValueVar 930:0-7 Obj.Get) [
        (ValueVar 930:8-9 O)
        (ValueVar 930:11-12 K)
      ])
    (TakeRight 930:16-37
      (Destructure 930:16-33
        (ValueVar 930:16-17 O)
        (Merge 930:21-33
          (Object 930:21-31 [
            (ObjectPair (ValueVar 930:22-23 K) (ValueVar 930:25-26 V))
          ])
          (ValueVar 930:31-32 _)))
      (ValueVar 930:36-37 V)))
  
  (DeclareGlobal 932:0-31
    (Function 932:0-16
      (ValueVar 932:0-7 Obj.Put) [
        (ValueVar 932:8-9 O)
        (ValueVar 932:11-12 K)
        (ValueVar 932:14-15 V)
      ])
    (Merge 932:19-31
      (Merge 932:19-20
        (Object 932:19-20 [])
        (ValueVar 932:23-24 O))
      (Object 932:26-31 [
        (ObjectPair (ValueVar 932:26-27 K) (ValueVar 932:29-30 V))
      ])))
  
  (DeclareGlobal 936:0-61
    (Function 936:0-36
      (ValueVar 936:0-14 Ast.Precedence) [
        (ValueVar 936:15-21 OpNode)
        (ValueVar 936:23-35 BindingPower)
      ])
    (Array 936:39-61 [
      (ValueVar 936:40-46 OpNode)
      (ValueVar 936:48-60 BindingPower)
    ]))
  
  (DeclareGlobal 938:0-114
    (Function 938:0-64
      (ValueVar 938:0-19 Ast.InfixPrecedence) [
        (ValueVar 938:20-26 OpNode)
        (ValueVar 938:28-44 LeftBindingPower)
        (ValueVar 938:46-63 RightBindingPower)
      ])
    (Array 939:2-47 [
      (ValueVar 939:3-9 OpNode)
      (ValueVar 939:11-27 LeftBindingPower)
      (ValueVar 939:29-46 RightBindingPower)
    ]))
  
  (DeclareGlobal 943:0-28
    (Function 943:0-12
      (ValueVar 943:0-9 Is.String) [
        (ValueVar 943:10-11 V)
      ])
    (Destructure 943:15-28
      (ValueVar 943:15-16 V)
      (Merge 943:20-28
        (String 943:21-23 "")
        (ValueVar 943:26-27 _))))
  
  (DeclareGlobal 945:0-27
    (Function 945:0-12
      (ValueVar 945:0-9 Is.Number) [
        (ValueVar 945:10-11 V)
      ])
    (Destructure 945:15-27
      (ValueVar 945:15-16 V)
      (Merge 945:20-27
        (NumberString 945:21-22 0)
        (ValueVar 945:25-26 _))))
  
  (DeclareGlobal 947:0-29
    (Function 947:0-10
      (ValueVar 947:0-7 Is.Bool) [
        (ValueVar 947:8-9 V)
      ])
    (Destructure 947:13-29
      (ValueVar 947:13-14 V)
      (Merge 947:18-29
        (False 947:19-24)
        (ValueVar 947:27-28 _))))
  
  (DeclareGlobal 949:0-22
    (Function 949:0-10
      (ValueVar 949:0-7 Is.Null) [
        (ValueVar 949:8-9 V)
      ])
    (Destructure 949:13-22
      (ValueVar 949:13-14 V)
      (Null 949:18-22)))
  
  (DeclareGlobal 951:0-25
    (Function 951:0-11
      (ValueVar 951:0-8 Is.Array) [
        (ValueVar 951:9-10 V)
      ])
    (Destructure 951:14-25
      (ValueVar 951:14-15 V)
      (Merge 951:19-25
        (Array 951:19-20 [])
        (ValueVar 951:23-24 _))))
  
  (DeclareGlobal 953:0-26
    (Function 953:0-12
      (ValueVar 953:0-9 Is.Object) [
        (ValueVar 953:10-11 V)
      ])
    (Destructure 953:15-26
      (ValueVar 953:15-16 V)
      (Merge 953:20-26
        (Object 953:20-21 [])
        (ValueVar 953:24-25 _))))
  
  (DeclareGlobal 955:0-23
    (Function 955:0-14
      (ValueVar 955:0-8 Is.Equal) [
        (ValueVar 955:9-10 A)
        (ValueVar 955:12-13 B)
      ])
    (Destructure 955:17-23
      (ValueVar 955:17-18 A)
      (ValueVar 955:22-23 B)))
  
  (DeclareGlobal 957:0-45
    (Function 957:0-17
      (ValueVar 957:0-11 Is.LessThan) [
        (ValueVar 957:12-13 A)
        (ValueVar 957:15-16 B)
      ])
    (Conditional 957:20-45
      (Destructure 957:20-26
        (ValueVar 957:20-21 A)
        (ValueVar 957:25-26 B))
      (ValueVar 957:29-34 @Fail)
      (Destructure 957:37-45
        (ValueVar 957:37-38 A)
        (Range 957:42-45 () (ValueVar 957:44-45 B)))))
  
  (DeclareGlobal 959:0-35
    (Function 959:0-24
      (ValueVar 959:0-18 Is.LessThanOrEqual) [
        (ValueVar 959:19-20 A)
        (ValueVar 959:22-23 B)
      ])
    (Destructure 959:27-35
      (ValueVar 959:27-28 A)
      (Range 959:32-35 () (ValueVar 959:34-35 B))))
  
  (DeclareGlobal 961:0-48
    (Function 961:0-20
      (ValueVar 961:0-14 Is.GreaterThan) [
        (ValueVar 961:15-16 A)
        (ValueVar 961:18-19 B)
      ])
    (Conditional 961:23-48
      (Destructure 961:23-29
        (ValueVar 961:23-24 A)
        (ValueVar 961:28-29 B))
      (ValueVar 961:32-37 @Fail)
      (Destructure 961:40-48
        (ValueVar 961:40-41 A)
        (Range 961:45-48 (ValueVar 961:45-46 B) ()))))
  
  (DeclareGlobal 963:0-38
    (Function 963:0-27
      (ValueVar 963:0-21 Is.GreaterThanOrEqual) [
        (ValueVar 963:22-23 A)
        (ValueVar 963:25-26 B)
      ])
    (Destructure 963:30-38
      (ValueVar 963:30-31 A)
      (Range 963:35-38 (ValueVar 963:35-36 B) ())))
  
  (DeclareGlobal 967:0-51
    (Function 967:0-12
      (ValueVar 967:0-9 As.Number) [
        (ValueVar 967:10-11 V)
      ])
    (Or 967:15-51
      (Function 967:15-27
        (ValueVar 967:15-24 Is.Number) [
          (ValueVar 967:25-26 V)
        ])
      (Return 967:30-51
        (Destructure 967:31-46
          (ValueVar 967:31-32 V)
          (StringTemplate 967:36-46 [
            (Merge 967:39-44
              (NumberString 967:39-40 0)
              (ValueVar 967:43-44 N))
          ]))
        (ValueVar 967:49-50 N))))
  
  (DeclareGlobal 969:0-21
    (Function 969:0-12
      (ValueVar 969:0-9 As.String) [
        (ValueVar 969:10-11 V)
      ])
    (StringTemplate 969:15-21 [
      (ValueVar 969:18-19 V)
    ]))

