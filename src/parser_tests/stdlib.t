  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i ''
  (DeclareGlobal 5:0-19
    (ParserVar 5:0-4 char)
    (Range 5:7-19 (String 5:7-17 _0) ()))
  
  (DeclareGlobal 7:0-30
    (ParserVar 7:0-5 ascii)
    (Range 7:8-30 (String 7:8-18 _0) (String 7:20-30 "\x7f"))) (esc)
  
  (DeclareGlobal 9:0-27
    (ParserVar 9:0-5 alpha)
    (Or 9:8-27
      (Range 9:8-16 (String 9:8-11 "a") (String 9:13-16 "z"))
      (Range 9:19-27 (String 9:19-22 "A") (String 9:24-27 "Z"))))
  
  (DeclareGlobal 11:0-20
    (ParserVar 11:0-6 alphas)
    (Function 11:9-20 (ParserVar 11:9-13 many) ((ParserVar 11:14-19 alpha))))
  
  (DeclareGlobal 13:0-16
    (ParserVar 13:0-5 lower)
    (Range 13:8-16 (String 13:8-11 "a") (String 13:13-16 "z")))
  
  (DeclareGlobal 15:0-20
    (ParserVar 15:0-6 lowers)
    (Function 15:9-20 (ParserVar 15:9-13 many) ((ParserVar 15:14-19 lower))))
  
  (DeclareGlobal 17:0-16
    (ParserVar 17:0-5 upper)
    (Range 17:8-16 (String 17:8-11 "A") (String 17:13-16 "Z")))
  
  (DeclareGlobal 19:0-20
    (ParserVar 19:0-6 uppers)
    (Function 19:9-20 (ParserVar 19:9-13 many) ((ParserVar 19:14-19 upper))))
  
  (DeclareGlobal 21:0-18
    (ParserVar 21:0-7 numeral)
    (Range 21:10-18 (String 21:10-13 "0") (String 21:15-18 "9")))
  
  (DeclareGlobal 23:0-24
    (ParserVar 23:0-8 numerals)
    (Function 23:11-24 (ParserVar 23:11-15 many) ((ParserVar 23:16-23 numeral))))
  
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
    (Function 33:9-20 (ParserVar 33:9-13 many) ((ParserVar 33:14-19 alnum))))
  
  (DeclareGlobal 35:0-38
    (ParserVar 35:0-5 token)
    (Function 35:8-38 (ParserVar 35:8-12 many) ((Function 35:13-37 (ParserVar 35:13-19 unless) ((ParserVar 35:20-24 char) (ParserVar 35:26-36 whitespace))))))
  
  (DeclareGlobal 37:0-30
    (ParserVar 37:0-4 word)
    (Function 37:7-30
      (ParserVar 37:7-11 many)
      ((Or 37:12-29
          (ParserVar 37:12-17 alnum)
          (Or 37:20-29
            (String 37:20-23 "_")
            (String 37:26-29 "-"))))))
  
  (DeclareGlobal 39:0-42
    (ParserVar 39:0-4 line)
    (Function 39:7-42
      (ParserVar 39:7-18 chars_until)
      ((Or 39:19-41
          (ParserVar 39:19-26 newline)
          (ParserVar 39:29-41 end_of_input)))))
  
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
    (Function 44:9-20 (ParserVar 44:9-13 many) ((ParserVar 44:14-19 space))))
  
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
    (Function 50:11-24 (ParserVar 50:11-15 many) ((ParserVar 50:16-23 newline))))
  
  (DeclareGlobal 52:0-14
    (ParserVar 52:0-3 nls)
    (ParserVar 52:6-14 newlines))
  
  (DeclareGlobal 54:0-34
    (ParserVar 54:0-10 whitespace)
    (Function 54:13-34
      (ParserVar 54:13-17 many)
      ((Or 54:18-33
          (ParserVar 54:18-23 space)
          (ParserVar 54:26-33 newline)))))
  
  (DeclareGlobal 56:0-15
    (ParserVar 56:0-2 ws)
    (ParserVar 56:5-15 whitespace))
  
  (DeclareGlobal 58:0-42
    (Function 58:0-17 (ParserVar 58:0-11 chars_until) ((ParserVar 58:12-16 stop)))
    (Function 58:20-42 (ParserVar 58:20-30 many_until) ((ParserVar 58:31-35 char) (ParserVar 58:37-41 stop))))
  
  (DeclareGlobal 62:0-12
    (ParserVar 62:0-5 digit)
    (Range 62:8-12 (NumberString 62:8-9 0) (NumberString 62:11-12 9)))
  
  (DeclareGlobal 64:0-54
    (ParserVar 64:0-7 integer)
    (Function 64:10-54
      (ParserVar 64:10-19 as_number)
      ((Merge 64:20-53
          (Function 64:20-30 (ParserVar 64:20-25 maybe) ((String 64:26-29 "-")))
          (ParserVar 64:33-53 _number_integer_part)))))
  
  (DeclareGlobal 66:0-13
    (ParserVar 66:0-3 int)
    (ParserVar 66:6-13 integer))
  
  (DeclareGlobal 68:0-54
    (ParserVar 68:0-20 non_negative_integer)
    (Function 68:23-54 (ParserVar 68:23-32 as_number) ((ParserVar 68:33-53 _number_integer_part))))
  
  (DeclareGlobal 70:0-56
    (ParserVar 70:0-16 negative_integer)
    (Function 70:19-56
      (ParserVar 70:19-28 as_number)
      ((Merge 70:29-55
          (String 70:29-32 "-")
          (ParserVar 70:35-55 _number_integer_part)))))
  
  (DeclareGlobal 72:0-76
    (ParserVar 72:0-5 float)
    (Function 72:8-76
      (ParserVar 72:8-17 as_number)
      ((Merge 72:18-75
          (Merge 72:18-51
            (Function 72:18-28 (ParserVar 72:18-23 maybe) ((String 72:24-27 "-")))
            (ParserVar 72:31-51 _number_integer_part))
          (ParserVar 72:54-75 _number_fraction_part)))))
  
  (DeclareGlobal 74:0-97
    (ParserVar 74:0-18 scientific_integer)
    (Function 74:21-97
      (ParserVar 74:21-30 as_number)
      ((Merge 75:2-63
          (Merge 75:2-37
            (Function 75:2-12 (ParserVar 75:2-7 maybe) ((String 75:8-11 "-")))
            (ParserVar 76:2-22 _number_integer_part))
          (ParserVar 77:2-23 _number_exponent_part)))))
  
  (DeclareGlobal 80:0-121
    (ParserVar 80:0-16 scientific_float)
    (Function 80:19-121
      (ParserVar 80:19-28 as_number)
      ((Merge 81:2-89
          (Merge 81:2-63
            (Merge 81:2-37
              (Function 81:2-12 (ParserVar 81:2-7 maybe) ((String 81:8-11 "-")))
              (ParserVar 82:2-22 _number_integer_part))
            (ParserVar 83:2-23 _number_fraction_part))
          (ParserVar 84:2-23 _number_exponent_part)))))
  
  (DeclareGlobal 87:0-125
    (ParserVar 87:0-6 number)
    (Function 87:9-125
      (ParserVar 87:9-18 as_number)
      ((Merge 88:2-103
          (Merge 88:2-70
            (Merge 88:2-37
              (Function 88:2-12 (ParserVar 88:2-7 maybe) ((String 88:8-11 "-")))
              (ParserVar 89:2-22 _number_integer_part))
            (Function 90:2-30 (ParserVar 90:2-7 maybe) ((ParserVar 90:8-29 _number_fraction_part))))
          (Function 91:2-30 (ParserVar 91:2-7 maybe) ((ParserVar 91:8-29 _number_exponent_part)))))))
  
  (DeclareGlobal 94:0-12
    (ParserVar 94:0-3 num)
    (ParserVar 94:6-12 number))
  
  (DeclareGlobal 96:0-123
    (ParserVar 96:0-19 non_negative_number)
    (Function 96:22-123
      (ParserVar 96:22-31 as_number)
      ((Merge 97:2-88
          (Merge 97:2-55
            (ParserVar 97:2-22 _number_integer_part)
            (Function 98:2-30 (ParserVar 98:2-7 maybe) ((ParserVar 98:8-29 _number_fraction_part))))
          (Function 99:2-30 (ParserVar 99:2-7 maybe) ((ParserVar 99:8-29 _number_exponent_part)))))))
  
  (DeclareGlobal 102:0-127
    (ParserVar 102:0-15 negative_number)
    (Function 102:18-127
      (ParserVar 102:18-27 as_number)
      ((Merge 103:2-96
          (Merge 103:2-63
            (Merge 103:2-30
              (String 103:2-5 "-")
              (ParserVar 104:2-22 _number_integer_part))
            (Function 105:2-30 (ParserVar 105:2-7 maybe) ((ParserVar 105:8-29 _number_fraction_part))))
          (Function 106:2-30 (ParserVar 106:2-7 maybe) ((ParserVar 106:8-29 _number_exponent_part)))))))
  
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
          (ParserVar 113:38-43 maybe)
          ((Or 113:44-53
              (String 113:44-47 "-")
              (String 113:50-53 "+")))))
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
        (Function 128:17-36 (ParserVar 128:17-22 array) ((ParserVar 128:23-35 binary_digit)))
        (ValueVar 128:40-46 Digits))
      (Function 128:49-77 (ValueVar 128:49-69 Num.FromBinaryDigits) ((ValueVar 128:70-76 Digits)))))
  
  (DeclareGlobal 130:0-74
    (ParserVar 130:0-13 octal_integer)
    (Return 130:16-74
      (Destructure 130:16-44
        (Function 130:16-34 (ParserVar 130:16-21 array) ((ParserVar 130:22-33 octal_digit)))
        (ValueVar 130:38-44 Digits))
      (Function 130:47-74 (ValueVar 130:47-66 Num.FromOctalDigits) ((ValueVar 130:67-73 Digits)))))
  
  (DeclareGlobal 132:0-68
    (ParserVar 132:0-11 hex_integer)
    (Return 132:14-68
      (Destructure 132:14-40
        (Function 132:14-30 (ParserVar 132:14-19 array) ((ParserVar 132:20-29 hex_digit)))
        (ValueVar 132:34-40 Digits))
      (Function 132:43-68 (ValueVar 132:43-60 Num.FromHexDigits) ((ValueVar 132:61-67 Digits)))))
  
  (DeclareGlobal 136:0-18
    (Function 136:0-7 (Boolean 136:0-4 true) ((ParserVar 136:5-6 t)))
    (Return 136:10-18
      (ParserVar 136:10-11 t)
      (Boolean 136:14-18 true)))
  
  (DeclareGlobal 138:0-20
    (Function 138:0-8 (Boolean 138:0-5 false) ((ParserVar 138:6-7 f)))
    (Return 138:11-20
      (ParserVar 138:11-12 f)
      (Boolean 138:15-20 false)))
  
  (DeclareGlobal 140:0-34
    (Function 140:0-13 (ParserVar 140:0-7 boolean) ((ParserVar 140:8-9 t) (ParserVar 140:11-12 f)))
    (Or 140:16-34
      (Function 140:16-23 (Boolean 140:16-20 true) ((ParserVar 140:21-22 t)))
      (Function 140:26-34 (Boolean 140:26-31 false) ((ParserVar 140:32-33 f)))))
  
  (DeclareGlobal 142:0-14
    (ParserVar 142:0-4 bool)
    (ParserVar 142:7-14 boolean))
  
  (DeclareGlobal 144:0-18
    (Function 144:0-7 (Null 144:0-4 null) ((ParserVar 144:5-6 n)))
    (Return 144:10-18
      (ParserVar 144:10-11 n)
      (Null 144:14-18 null)))
  
  (DeclareGlobal 148:0-51
    (Function 148:0-11 (ParserVar 148:0-5 array) ((ParserVar 148:6-10 elem)))
    (TakeRight 148:14-51
      (Destructure 148:14-27
        (ParserVar 148:14-18 elem)
        (ValueVar 148:22-27 First))
      (Function 148:30-51 (ParserVar 148:30-36 _array) ((ParserVar 148:37-41 elem) (Array 148:43-50 ((ValueVar 148:44-49 First)))))))
  
  (DeclareGlobal 150:0-82
    (Function 150:0-17 (ParserVar 150:0-6 _array) ((ParserVar 150:7-11 elem) (ValueVar 150:13-16 Acc)))
    (Conditional 151:2-62
      (condition (Destructure 151:2-14
          (ParserVar 151:2-6 elem)
          (ValueVar 151:10-14 Elem)))
      (then (Function 152:2-30
          (ParserVar 152:2-8 _array)
          ((ParserVar 152:9-13 elem)
           (Merge 152:15-29
              (Merge 152:15-16
                (Array 152:15-16 ())
                (ValueVar 152:19-22 Acc))
              (Array 152:24-29 ((ValueVar 152:24-28 Elem)))))))
      (else (Function 153:2-12 (ParserVar 153:2-7 const) ((ValueVar 153:8-11 Acc))))))
  
  (DeclareGlobal 155:0-66
    (Function 155:0-20 (ParserVar 155:0-9 array_sep) ((ParserVar 155:10-14 elem) (ParserVar 155:16-19 sep)))
    (TakeRight 155:23-66
      (Destructure 155:23-36
        (ParserVar 155:23-27 elem)
        (ValueVar 155:31-36 First))
      (Function 155:39-66
        (ParserVar 155:39-45 _array)
        ((TakeRight 155:46-56
            (ParserVar 155:46-49 sep)
            (ParserVar 155:52-56 elem))
         (Array 155:58-65 ((ValueVar 155:59-64 First)))))))
  
  (DeclareGlobal 157:0-91
    (Function 157:0-23 (ParserVar 157:0-11 array_until) ((ParserVar 157:12-16 elem) (ParserVar 157:18-22 stop)))
    (TakeRight 158:2-65
      (Destructure 158:2-29
        (Function 158:2-20 (ParserVar 158:2-8 unless) ((ParserVar 158:9-13 elem) (ParserVar 158:15-19 stop)))
        (ValueVar 158:24-29 First))
      (Function 158:32-65
        (ParserVar 158:32-44 _array_until)
        ((ParserVar 158:45-49 elem)
         (ParserVar 158:51-55 stop)
         (Array 158:57-64 ((ValueVar 158:58-63 First)))))))
  
  (DeclareGlobal 160:0-119
    (Function 160:0-29
      (ParserVar 160:0-12 _array_until)
      ((ParserVar 160:13-17 elem)
       (ParserVar 160:19-23 stop)
       (ValueVar 160:25-28 Acc)))
    (Conditional 161:2-87
      (condition (Function 161:2-12 (ParserVar 161:2-6 peek) ((ParserVar 161:7-11 stop))))
      (then (Function 162:2-12 (ParserVar 162:2-7 const) ((ValueVar 162:8-11 Acc))))
      (else (TakeRight 163:2-57
          (Destructure 163:2-14
            (ParserVar 163:2-6 elem)
            (ValueVar 163:10-14 Elem))
          (Function 163:17-57
            (ParserVar 163:17-29 _array_until)
            ((ParserVar 163:30-34 elem)
             (ParserVar 163:36-40 stop)
             (Merge 163:42-56
                (Merge 163:42-43
                  (Array 163:42-43 ())
                  (ValueVar 163:46-49 Acc))
                (Array 163:51-56 ((ValueVar 163:51-55 Elem))))))))))
  
  (DeclareGlobal 165:0-44
    (Function 165:0-17 (ParserVar 165:0-11 maybe_array) ((ParserVar 165:12-16 elem)))
    (Function 165:20-44 (ParserVar 165:20-27 default) ((Function 165:28-39 (ParserVar 165:28-33 array) ((ParserVar 165:34-38 elem))) (Array 165:41-44 ()))))
  
  (DeclareGlobal 167:0-62
    (Function 167:0-26 (ParserVar 167:0-15 maybe_array_sep) ((ParserVar 167:16-20 elem) (ParserVar 167:22-25 sep)))
    (Function 167:29-62 (ParserVar 167:29-36 default) ((Function 167:37-57 (ParserVar 167:37-46 array_sep) ((ParserVar 167:47-51 elem) (ParserVar 167:53-56 sep))) (Array 167:59-62 ()))))
  
  (DeclareGlobal 169:0-37
    (Function 169:0-12 (ParserVar 169:0-6 tuple1) ((ParserVar 169:7-11 elem)))
    (Return 169:16-37
      (Destructure 169:16-28
        (ParserVar 169:16-20 elem)
        (ValueVar 169:24-28 Elem))
      (Array 169:31-37 ((ValueVar 169:32-36 Elem)))))
  
  (DeclareGlobal 171:0-59
    (Function 171:0-20 (ParserVar 171:0-6 tuple2) ((ParserVar 171:7-12 elem1) (ParserVar 171:14-19 elem2)))
    (TakeRight 171:23-59
      (Destructure 171:23-34
        (ParserVar 171:23-28 elem1)
        (ValueVar 171:32-34 E1))
      (Return 171:37-59
        (Destructure 171:37-48
          (ParserVar 171:37-42 elem2)
          (ValueVar 171:46-48 E2))
        (Array 171:51-59 ((ValueVar 171:52-54 E1) (ValueVar 171:56-58 E2))))))
  
  (DeclareGlobal 173:0-74
    (Function 173:0-29
      (ParserVar 173:0-10 tuple2_sep)
      ((ParserVar 173:11-16 elem1)
       (ParserVar 173:18-21 sep)
       (ParserVar 173:23-28 elem2)))
    (TakeRight 173:32-74
      (TakeRight 173:32-49
        (Destructure 173:32-43
          (ParserVar 173:32-37 elem1)
          (ValueVar 173:41-43 E1))
        (ParserVar 173:46-49 sep))
      (Return 173:52-74
        (Destructure 173:52-63
          (ParserVar 173:52-57 elem2)
          (ValueVar 173:61-63 E2))
        (Array 173:66-74 ((ValueVar 173:67-69 E1) (ValueVar 173:71-73 E2))))))
  
  (DeclareGlobal 175:0-92
    (Function 175:0-27
      (ParserVar 175:0-6 tuple3)
      ((ParserVar 175:7-12 elem1)
       (ParserVar 175:14-19 elem2)
       (ParserVar 175:21-26 elem3)))
    (TakeRight 176:2-62
      (TakeRight 176:2-29
        (Destructure 176:2-13
          (ParserVar 176:2-7 elem1)
          (ValueVar 176:11-13 E1))
        (Destructure 177:2-13
          (ParserVar 177:2-7 elem2)
          (ValueVar 177:11-13 E2)))
      (Return 178:2-30
        (Destructure 178:2-13
          (ParserVar 178:2-7 elem3)
          (ValueVar 178:11-13 E3))
        (Array 179:2-14 ((ValueVar 179:3-5 E1) (ValueVar 179:7-9 E2) (ValueVar 179:11-13 E3))))))
  
  (DeclareGlobal 181:0-122
    (Function 181:0-43
      (ParserVar 181:0-10 tuple3_sep)
      ((ParserVar 181:11-16 elem1)
       (ParserVar 181:18-22 sep1)
       (ParserVar 181:24-29 elem2)
       (ParserVar 181:31-35 sep2)
       (ParserVar 181:37-42 elem3)))
    (TakeRight 182:2-76
      (TakeRight 182:2-43
        (TakeRight 182:2-36
          (TakeRight 182:2-20
            (Destructure 182:2-13
              (ParserVar 182:2-7 elem1)
              (ValueVar 182:11-13 E1))
            (ParserVar 182:16-20 sep1))
          (Destructure 183:2-13
            (ParserVar 183:2-7 elem2)
            (ValueVar 183:11-13 E2)))
        (ParserVar 183:16-20 sep2))
      (Return 184:2-30
        (Destructure 184:2-13
          (ParserVar 184:2-7 elem3)
          (ValueVar 184:11-13 E3))
        (Array 185:2-14 ((ValueVar 185:3-5 E1) (ValueVar 185:7-9 E2) (ValueVar 185:11-13 E3))))))
  
  (DeclareGlobal 187:0-79
    (Function 187:0-14 (ParserVar 187:0-5 tuple) ((ParserVar 187:6-10 elem) (ValueVar 187:12-13 N)))
    (TakeRight 188:2-62
      (Function 188:2-38 (ParserVar 188:2-7 const) ((Function 188:8-37 (ValueVar 188:8-34 _Assert.NonNegativeInteger) ((ValueVar 188:35-36 N)))))
      (Function 189:2-21
        (ParserVar 189:2-8 _tuple)
        ((ParserVar 189:9-13 elem)
         (ValueVar 189:15-16 N)
         (Array 189:18-21 ())))))
  
  (DeclareGlobal 191:0-115
    (Function 191:0-20
      (ParserVar 191:0-6 _tuple)
      ((ParserVar 191:7-11 elem)
       (ValueVar 191:13-14 N)
       (ValueVar 191:16-19 Acc)))
    (Conditional 192:2-92
      (condition (Function 192:2-17
          (ParserVar 192:2-7 const)
          ((Destructure 192:8-16
              (ValueVar 192:8-9 N)
              (Range 192:13-16 () (NumberString 192:15-16 0))))))
      (then (Function 193:2-12 (ParserVar 193:2-7 const) ((ValueVar 193:8-11 Acc))))
      (else (TakeRight 194:2-57
          (Destructure 194:2-14
            (ParserVar 194:2-6 elem)
            (ValueVar 194:10-14 Elem))
          (Function 194:17-57
            (ParserVar 194:17-23 _tuple)
            ((ParserVar 194:24-28 elem)
             (Function 194:30-40 (ValueVar 194:30-37 Num.Dec) ((ValueVar 194:38-39 N)))
             (Merge 194:42-56
                (Merge 194:42-43
                  (Array 194:42-43 ())
                  (ValueVar 194:46-49 Acc))
                (Array 194:51-56 ((ValueVar 194:51-55 Elem))))))))))
  
  (DeclareGlobal 196:0-97
    (Function 196:0-23
      (ParserVar 196:0-9 tuple_sep)
      ((ParserVar 196:10-14 elem)
       (ParserVar 196:16-19 sep)
       (ValueVar 196:21-22 N)))
    (TakeRight 197:2-71
      (Function 197:2-38 (ParserVar 197:2-7 const) ((Function 197:8-37 (ValueVar 197:8-34 _Assert.NonNegativeInteger) ((ValueVar 197:35-36 N)))))
      (Function 198:2-30
        (ParserVar 198:2-12 _tuple_sep)
        ((ParserVar 198:13-17 elem)
         (ParserVar 198:19-22 sep)
         (ValueVar 198:24-25 N)
         (Array 198:27-30 ())))))
  
  (DeclareGlobal 200:0-139
    (Function 200:0-29
      (ParserVar 200:0-10 _tuple_sep)
      ((ParserVar 200:11-15 elem)
       (ParserVar 200:17-20 sep)
       (ValueVar 200:22-23 N)
       (ValueVar 200:25-28 Acc)))
    (Conditional 201:2-107
      (condition (Function 201:2-17
          (ParserVar 201:2-7 const)
          ((Destructure 201:8-16
              (ValueVar 201:8-9 N)
              (Range 201:13-16 () (NumberString 201:15-16 0))))))
      (then (Function 202:2-12 (ParserVar 202:2-7 const) ((ValueVar 202:8-11 Acc))))
      (else (TakeRight 203:2-72
          (Destructure 203:2-20
            (TakeRight 203:2-12
              (ParserVar 203:2-5 sep)
              (ParserVar 203:8-12 elem))
            (ValueVar 203:16-20 Elem))
          (Function 203:23-72
            (ParserVar 203:23-33 _tuple_sep)
            ((ParserVar 203:34-38 elem)
             (ParserVar 203:40-43 sep)
             (Function 203:45-55 (ValueVar 203:45-52 Num.Dec) ((ValueVar 203:53-54 N)))
             (Merge 203:57-71
                (Merge 203:57-58
                  (Array 203:57-58 ())
                  (ValueVar 203:61-64 Acc))
                (Array 203:66-71 ((ValueVar 203:66-70 Elem))))))))))
  
  (DeclareGlobal 205:0-91
    (Function 205:0-28
      (ParserVar 205:0-4 rows)
      ((ParserVar 205:5-9 elem)
       (ParserVar 205:11-18 col_sep)
       (ParserVar 205:20-27 row_sep)))
    (TakeRight 206:2-60
      (Destructure 206:2-15
        (ParserVar 206:2-6 elem)
        (ValueVar 206:10-15 First))
      (Function 206:18-60
        (ParserVar 206:18-23 _rows)
        ((ParserVar 206:24-28 elem)
         (ParserVar 206:30-37 col_sep)
         (ParserVar 206:39-46 row_sep)
         (Array 206:48-55 ((ValueVar 206:49-54 First)))
         (Array 206:57-60 ())))))
  
  (DeclareGlobal 208:0-264
    (Function 208:0-46
      (ParserVar 208:0-5 _rows)
      ((ParserVar 208:6-10 elem)
       (ParserVar 208:12-19 col_sep)
       (ParserVar 208:21-28 row_sep)
       (ValueVar 208:30-36 AccRow)
       (ValueVar 208:38-45 AccRows)))
    (Conditional 209:2-215
      (condition (Destructure 209:2-24
          (TakeRight 209:2-16
            (ParserVar 209:2-9 col_sep)
            (ParserVar 209:12-16 elem))
          (ValueVar 209:20-24 Elem)))
      (then (Function 210:2-59
          (ParserVar 210:2-7 _rows)
          ((ParserVar 210:8-12 elem)
           (ParserVar 210:14-21 col_sep)
           (ParserVar 210:23-30 row_sep)
           (Merge 210:32-49
              (Merge 210:32-33
                (Array 210:32-33 ())
                (ValueVar 210:36-42 AccRow))
              (Array 210:44-49 ((ValueVar 210:44-48 Elem))))
           (ValueVar 210:51-58 AccRows))))
      (else (Conditional 211:2-126
          (condition (Destructure 211:2-27
              (TakeRight 211:2-16
                (ParserVar 211:2-9 row_sep)
                (ParserVar 211:12-16 elem))
              (ValueVar 211:20-27 NextRow)))
          (then (Function 212:2-64
              (ParserVar 212:2-7 _rows)
              ((ParserVar 212:8-12 elem)
               (ParserVar 212:14-21 col_sep)
               (ParserVar 212:23-30 row_sep)
               (Array 212:32-41 ((ValueVar 212:33-40 NextRow)))
               (Merge 212:43-63
                  (Merge 212:43-44
                    (Array 212:43-44 ())
                    (ValueVar 212:47-54 AccRows))
                  (Array 212:56-63 ((ValueVar 212:56-62 AccRow)))))))
          (else (Function 213:2-29
              (ParserVar 213:2-7 const)
              ((Merge 213:8-28
                  (Merge 213:8-9
                    (Array 213:8-9 ())
                    (ValueVar 213:12-19 AccRows))
                  (Array 213:21-28 ((ValueVar 213:21-27 AccRow)))))))))))
  
  (DeclareGlobal 215:0-194
    (Function 215:0-40
      (ParserVar 215:0-11 rows_padded)
      ((ParserVar 215:12-16 elem)
       (ParserVar 215:18-25 col_sep)
       (ParserVar 215:27-34 row_sep)
       (ValueVar 215:36-39 Pad)))
    (TakeRight 216:2-151
      (TakeRight 216:2-79
        (Destructure 216:2-61
          (Function 216:2-43
            (ParserVar 216:2-6 peek)
            ((Function 216:7-42
                (ParserVar 216:7-18 _dimensions)
                ((ParserVar 216:19-23 elem)
                 (ParserVar 216:25-32 col_sep)
                 (ParserVar 216:34-41 row_sep)))))
          (Array 216:47-61 ((ValueVar 216:48-57 MaxRowLen) (ValueVar 216:59-60 _))))
        (Destructure 217:2-15
          (ParserVar 217:2-6 elem)
          (ValueVar 217:10-15 First)))
      (Function 217:18-87
        (ParserVar 217:18-30 _rows_padded)
        ((ParserVar 217:31-35 elem)
         (ParserVar 217:37-44 col_sep)
         (ParserVar 217:46-53 row_sep)
         (ValueVar 217:55-58 Pad)
         (ValueLabel 217:60-61 (NumberString 217:61-62 1))
         (ValueVar 217:64-73 MaxRowLen)
         (Array 217:75-82 ((ValueVar 217:76-81 First)))
         (Array 217:84-87 ())))))
  
  (DeclareGlobal 219:0-442
    (Function 219:0-77
      (ParserVar 219:0-12 _rows_padded)
      ((ParserVar 219:13-17 elem)
       (ParserVar 219:19-26 col_sep)
       (ParserVar 219:28-35 row_sep)
       (ValueVar 219:37-40 Pad)
       (ValueVar 219:42-48 RowLen)
       (ValueVar 219:50-59 MaxRowLen)
       (ValueVar 219:61-67 AccRow)
       (ValueVar 219:69-76 AccRows)))
    (Conditional 220:2-362
      (condition (Destructure 220:2-24
          (TakeRight 220:2-16
            (ParserVar 220:2-9 col_sep)
            (ParserVar 220:12-16 elem))
          (ValueVar 220:20-24 Elem)))
      (then (Function 221:2-99
          (ParserVar 221:2-14 _rows_padded)
          ((ParserVar 221:15-19 elem)
           (ParserVar 221:21-28 col_sep)
           (ParserVar 221:30-37 row_sep)
           (ValueVar 221:39-42 Pad)
           (Function 221:44-59 (ValueVar 221:44-51 Num.Inc) ((ValueVar 221:52-58 RowLen)))
           (ValueVar 221:61-70 MaxRowLen)
           (Merge 221:72-89
              (Merge 221:72-73
                (Array 221:72-73 ())
                (ValueVar 221:76-82 AccRow))
              (Array 221:84-89 ((ValueVar 221:84-88 Elem))))
           (ValueVar 221:91-98 AccRows))))
      (else (Conditional 222:2-233
          (condition (Destructure 222:2-27
              (TakeRight 222:2-16
                (ParserVar 222:2-9 row_sep)
                (ParserVar 222:12-16 elem))
              (ValueVar 222:20-27 NextRow)))
          (then (Function 223:2-131
              (ParserVar 223:2-14 _rows_padded)
              ((ParserVar 223:15-19 elem)
               (ParserVar 223:21-28 col_sep)
               (ParserVar 223:30-37 row_sep)
               (ValueVar 223:39-42 Pad)
               (ValueLabel 223:44-45 (NumberString 223:45-46 1))
               (ValueVar 223:48-57 MaxRowLen)
               (Array 223:59-68 ((ValueVar 223:60-67 NextRow)))
               (Merge 223:70-130
                  (Merge 223:70-71
                    (Array 223:70-71 ())
                    (ValueVar 223:74-81 AccRows))
                  (Array 223:83-130 (
                    (Function 223:83-129
                      (ValueVar 223:83-96 Array.AppendN)
                      ((ValueVar 223:97-103 AccRow)
                       (ValueVar 223:105-108 Pad)
                       (Merge 223:110-128
                          (ValueVar 223:110-119 MaxRowLen)
                          (Negation 223:122-128 (ValueVar 223:122-128 RowLen)))))
                  ))))))
          (else (Function 224:2-69
              (ParserVar 224:2-7 const)
              ((Merge 224:8-68
                  (Merge 224:8-9
                    (Array 224:8-9 ())
                    (ValueVar 224:12-19 AccRows))
                  (Array 224:21-68 (
                    (Function 224:21-67
                      (ValueVar 224:21-34 Array.AppendN)
                      ((ValueVar 224:35-41 AccRow)
                       (ValueVar 224:43-46 Pad)
                       (Merge 224:48-66
                          (ValueVar 224:48-57 MaxRowLen)
                          (Negation 224:60-66 (ValueVar 224:60-66 RowLen)))))
                  ))))))))))
  
  (DeclareGlobal 226:0-95
    (Function 226:0-35
      (ParserVar 226:0-11 _dimensions)
      ((ParserVar 226:12-16 elem)
       (ParserVar 226:18-25 col_sep)
       (ParserVar 226:27-34 row_sep)))
    (TakeRight 227:2-57
      (ParserVar 227:2-6 elem)
      (Function 227:9-57
        (ParserVar 227:9-21 __dimensions)
        ((ParserVar 227:22-26 elem)
         (ParserVar 227:28-35 col_sep)
         (ParserVar 227:37-44 row_sep)
         (ValueLabel 227:46-47 (NumberString 227:47-48 1))
         (ValueLabel 227:50-51 (NumberString 227:51-52 1))
         (ValueLabel 227:54-55 (NumberString 227:55-56 0))))))
  
  (DeclareGlobal 229:0-316
    (Function 229:0-63
      (ParserVar 229:0-12 __dimensions)
      ((ParserVar 229:13-17 elem)
       (ParserVar 229:19-26 col_sep)
       (ParserVar 229:28-35 row_sep)
       (ValueVar 229:37-43 RowLen)
       (ValueVar 229:45-51 ColLen)
       (ValueVar 229:53-62 MaxRowLen)))
    (Conditional 230:2-250
      (condition (TakeRight 230:2-16
          (ParserVar 230:2-9 col_sep)
          (ParserVar 230:12-16 elem)))
      (then (Function 231:2-74
          (ParserVar 231:2-14 __dimensions)
          ((ParserVar 231:15-19 elem)
           (ParserVar 231:21-28 col_sep)
           (ParserVar 231:30-37 row_sep)
           (Function 231:39-54 (ValueVar 231:39-46 Num.Inc) ((ValueVar 231:47-53 RowLen)))
           (ValueVar 231:56-62 ColLen)
           (ValueVar 231:64-73 MaxRowLen))))
      (else (Conditional 232:2-154
          (condition (TakeRight 232:2-16
              (ParserVar 232:2-9 row_sep)
              (ParserVar 232:12-16 elem)))
          (then (Function 233:2-87
              (ParserVar 233:2-14 __dimensions)
              ((ParserVar 233:15-19 elem)
               (ParserVar 233:21-28 col_sep)
               (ParserVar 233:30-37 row_sep)
               (ValueLabel 233:39-40 (NumberString 233:40-41 1))
               (Function 233:43-58 (ValueVar 233:43-50 Num.Inc) ((ValueVar 233:51-57 ColLen)))
               (Function 233:60-86 (ValueVar 233:60-67 Num.Max) ((ValueVar 233:68-74 RowLen) (ValueVar 233:76-85 MaxRowLen))))))
          (else (Function 234:2-45 (ParserVar 234:2-7 const) ((Array 234:8-44 ((Function 234:9-35 (ValueVar 234:9-16 Num.Max) ((ValueVar 234:17-23 RowLen) (ValueVar 234:25-34 MaxRowLen))) (ValueVar 234:37-43 ColLen))))))))))
  
  (DeclareGlobal 236:0-98
    (Function 236:0-31
      (ParserVar 236:0-7 columns)
      ((ParserVar 236:8-12 elem)
       (ParserVar 236:14-21 col_sep)
       (ParserVar 236:23-30 row_sep)))
    (Return 237:2-64
      (Destructure 237:2-38
        (Function 237:2-30
          (ParserVar 237:2-6 rows)
          ((ParserVar 237:7-11 elem)
           (ParserVar 237:13-20 col_sep)
           (ParserVar 237:22-29 row_sep)))
        (ValueVar 237:34-38 Rows))
      (Function 238:2-23 (ValueVar 238:2-17 Table.Transpose) ((ValueVar 238:18-22 Rows)))))
  
  (DeclareGlobal 240:0-14
    (ParserVar 240:0-4 cols)
    (ParserVar 240:7-14 columns))
  
  (DeclareGlobal 242:0-122
    (Function 242:0-43
      (ParserVar 242:0-14 columns_padded)
      ((ParserVar 242:15-19 elem)
       (ParserVar 242:21-28 col_sep)
       (ParserVar 242:30-37 row_sep)
       (ValueVar 242:39-42 Pad)))
    (Return 243:2-76
      (Destructure 243:2-50
        (Function 243:2-42
          (ParserVar 243:2-13 rows_padded)
          ((ParserVar 243:14-18 elem)
           (ParserVar 243:20-27 col_sep)
           (ParserVar 243:29-36 row_sep)
           (ValueVar 243:38-41 Pad)))
        (ValueVar 243:46-50 Rows))
      (Function 244:2-23 (ValueVar 244:2-17 Table.Transpose) ((ValueVar 244:18-22 Rows)))))
  
  (DeclareGlobal 246:0-28
    (ParserVar 246:0-11 cols_padded)
    (ParserVar 246:14-28 columns_padded))
  
  (DeclareGlobal 250:0-76
    (Function 250:0-18 (ParserVar 250:0-6 object) ((ParserVar 250:7-10 key) (ParserVar 250:12-17 value)))
    (TakeRight 251:2-55
      (TakeRight 251:2-23
        (Destructure 251:2-10
          (ParserVar 251:2-5 key)
          (ValueVar 251:9-10 K))
        (Destructure 251:13-23
          (ParserVar 251:13-18 value)
          (ValueVar 251:22-23 V)))
      (Function 252:2-29
        (ParserVar 252:2-9 _object)
        ((ParserVar 252:10-13 key)
         (ParserVar 252:15-20 value)
         (Object 252:22-28
            ((ValueVar 252:23-24 K) (ValueVar 252:26-27 V)))))))
  
  (DeclareGlobal 254:0-105
    (Function 254:0-24
      (ParserVar 254:0-7 _object)
      ((ParserVar 254:8-11 key)
       (ParserVar 254:13-18 value)
       (ValueVar 254:20-23 Acc)))
    (Conditional 255:2-78
      (condition (TakeRight 255:2-23
          (Destructure 255:2-10
            (ParserVar 255:2-5 key)
            (ValueVar 255:9-10 K))
          (Destructure 255:13-23
            (ParserVar 255:13-18 value)
            (ValueVar 255:22-23 V))))
      (then (Function 256:2-37
          (ParserVar 256:2-9 _object)
          ((ParserVar 256:10-13 key)
           (ParserVar 256:15-20 value)
           (Merge 256:22-36
              (Merge 256:22-23
                (Object 256:22-23)
                (ValueVar 256:26-29 Acc))
              (Object 256:31-36
                ((ValueVar 256:31-32 K) (ValueVar 256:34-35 V)))))))
      (else (Function 257:2-12 (ParserVar 257:2-7 const) ((ValueVar 257:8-11 Acc))))))
  
  (DeclareGlobal 259:0-123
    (Function 259:0-37
      (ParserVar 259:0-10 object_sep)
      ((ParserVar 259:11-14 key)
       (ParserVar 259:16-24 pair_sep)
       (ParserVar 259:26-31 value)
       (ParserVar 259:33-36 sep)))
    (TakeRight 260:2-83
      (TakeRight 260:2-34
        (TakeRight 260:2-21
          (Destructure 260:2-10
            (ParserVar 260:2-5 key)
            (ValueVar 260:9-10 K))
          (ParserVar 260:13-21 pair_sep))
        (Destructure 260:24-34
          (ParserVar 260:24-29 value)
          (ValueVar 260:33-34 V)))
      (Function 261:2-46
        (ParserVar 261:2-9 _object)
        ((TakeRight 261:10-19
            (ParserVar 261:10-13 sep)
            (ParserVar 261:16-19 key))
         (TakeRight 261:21-37
            (ParserVar 261:21-29 pair_sep)
            (ParserVar 261:32-37 value))
         (Object 261:39-45
            ((ValueVar 261:40-41 K) (ValueVar 261:43-44 V)))))))
  
  (DeclareGlobal 263:0-116
    (Function 263:0-30
      (ParserVar 263:0-12 object_until)
      ((ParserVar 263:13-16 key)
       (ParserVar 263:18-23 value)
       (ParserVar 263:25-29 stop)))
    (TakeRight 264:2-83
      (TakeRight 264:2-39
        (Destructure 264:2-24
          (Function 264:2-19 (ParserVar 264:2-8 unless) ((ParserVar 264:9-12 key) (ParserVar 264:14-18 stop)))
          (ValueVar 264:23-24 K))
        (Destructure 265:2-12
          (ParserVar 265:2-7 value)
          (ValueVar 265:11-12 V)))
      (Function 266:2-41
        (ParserVar 266:2-15 _object_until)
        ((ParserVar 266:16-19 key)
         (ParserVar 266:21-26 value)
         (ParserVar 266:28-32 stop)
         (Object 266:34-40
            ((ValueVar 266:35-36 K) (ValueVar 266:38-39 V)))))))
  
  (DeclareGlobal 268:0-142
    (Function 268:0-36
      (ParserVar 268:0-13 _object_until)
      ((ParserVar 268:14-17 key)
       (ParserVar 268:19-24 value)
       (ParserVar 268:26-30 stop)
       (ValueVar 268:32-35 Acc)))
    (Conditional 269:2-103
      (condition (Function 269:2-12 (ParserVar 269:2-6 peek) ((ParserVar 269:7-11 stop))))
      (then (Function 270:2-12 (ParserVar 270:2-7 const) ((ValueVar 270:8-11 Acc))))
      (else (TakeRight 271:2-73
          (TakeRight 271:2-23
            (Destructure 271:2-10
              (ParserVar 271:2-5 key)
              (ValueVar 271:9-10 K))
            (Destructure 271:13-23
              (ParserVar 271:13-18 value)
              (ValueVar 271:22-23 V)))
          (Function 271:26-73
            (ParserVar 271:26-39 _object_until)
            ((ParserVar 271:40-43 key)
             (ParserVar 271:45-50 value)
             (ParserVar 271:52-56 stop)
             (Merge 271:58-72
                (Merge 271:58-59
                  (Object 271:58-59)
                  (ValueVar 271:62-65 Acc))
                (Object 271:67-72
                  ((ValueVar 271:67-68 K) (ValueVar 271:70-71 V))))))))))
  
  (DeclareGlobal 273:0-58
    (Function 273:0-24 (ParserVar 273:0-12 maybe_object) ((ParserVar 273:13-16 key) (ParserVar 273:18-23 value)))
    (Function 273:27-58 (ParserVar 273:27-34 default) ((Function 273:35-53 (ParserVar 273:35-41 object) ((ParserVar 273:42-45 key) (ParserVar 273:47-52 value))) (Object 273:55-58))))
  
  (DeclareGlobal 275:0-98
    (Function 275:0-43
      (ParserVar 275:0-16 maybe_object_sep)
      ((ParserVar 275:17-20 key)
       (ParserVar 275:22-30 pair_sep)
       (ParserVar 275:32-37 value)
       (ParserVar 275:39-42 sep)))
    (Function 276:2-52
      (ParserVar 276:2-9 default)
      ((Function 276:10-47
          (ParserVar 276:10-20 object_sep)
          ((ParserVar 276:21-24 key)
           (ParserVar 276:26-34 pair_sep)
           (ParserVar 276:36-41 value)
           (ParserVar 276:43-46 sep)))
       (Object 276:49-52))))
  
  (DeclareGlobal 278:0-49
    (Function 278:0-16 (ParserVar 278:0-4 pair) ((ParserVar 278:5-8 key) (ParserVar 278:10-15 value)))
    (TakeRight 278:19-49
      (Destructure 278:19-27
        (ParserVar 278:19-22 key)
        (ValueVar 278:26-27 K))
      (Return 278:30-49
        (Destructure 278:30-40
          (ParserVar 278:30-35 value)
          (ValueVar 278:39-40 V))
        (Object 278:43-49
          ((ValueVar 278:44-45 K) (ValueVar 278:47-48 V))))))
  
  (DeclareGlobal 280:0-64
    (Function 280:0-25
      (ParserVar 280:0-8 pair_sep)
      ((ParserVar 280:9-12 key)
       (ParserVar 280:14-17 sep)
       (ParserVar 280:19-24 value)))
    (TakeRight 280:28-64
      (TakeRight 280:28-42
        (Destructure 280:28-36
          (ParserVar 280:28-31 key)
          (ValueVar 280:35-36 K))
        (ParserVar 280:39-42 sep))
      (Return 280:45-64
        (Destructure 280:45-55
          (ParserVar 280:45-50 value)
          (ValueVar 280:54-55 V))
        (Object 280:58-64
          ((ValueVar 280:59-60 K) (ValueVar 280:62-63 V))))))
  
  (DeclareGlobal 282:0-51
    (Function 282:0-19 (ParserVar 282:0-7 record1) ((ValueVar 282:8-11 Key) (ParserVar 282:13-18 value)))
    (Return 282:22-51
      (Destructure 282:22-36
        (ParserVar 282:22-27 value)
        (ValueVar 282:31-36 Value))
      (Object 282:39-51
        ((ValueVar 282:40-43 Key) (ValueVar 282:45-50 Value)))))
  
  (DeclareGlobal 284:0-94
    (Function 284:0-35
      (ParserVar 284:0-7 record2)
      ((ValueVar 284:8-12 Key1)
       (ParserVar 284:14-20 value1)
       (ValueVar 284:22-26 Key2)
       (ParserVar 284:28-34 value2)))
    (TakeRight 285:2-56
      (Destructure 285:2-14
        (ParserVar 285:2-8 value1)
        (ValueVar 285:12-14 V1))
      (Return 286:2-39
        (Destructure 286:2-14
          (ParserVar 286:2-8 value2)
          (ValueVar 286:12-14 V2))
        (Object 287:2-22
          ((ValueVar 287:3-7 Key1) (ValueVar 287:9-11 V1))
          ((ValueVar 287:13-17 Key2) (ValueVar 287:19-21 V2))))))
  
  (DeclareGlobal 289:0-109
    (Function 289:0-44
      (ParserVar 289:0-11 record2_sep)
      ((ValueVar 289:12-16 Key1)
       (ParserVar 289:18-24 value1)
       (ParserVar 289:26-29 sep)
       (ValueVar 289:31-35 Key2)
       (ParserVar 289:37-43 value2)))
    (TakeRight 290:2-62
      (TakeRight 290:2-20
        (Destructure 290:2-14
          (ParserVar 290:2-8 value1)
          (ValueVar 290:12-14 V1))
        (ParserVar 290:17-20 sep))
      (Return 291:2-39
        (Destructure 291:2-14
          (ParserVar 291:2-8 value2)
          (ValueVar 291:12-14 V2))
        (Object 292:2-22
          ((ValueVar 292:3-7 Key1) (ValueVar 292:9-11 V1))
          ((ValueVar 292:13-17 Key2) (ValueVar 292:19-21 V2))))))
  
  (DeclareGlobal 294:0-135
    (Function 294:0-49
      (ParserVar 294:0-7 record3)
      ((ValueVar 294:8-12 Key1)
       (ParserVar 294:14-20 value1)
       (ValueVar 294:22-26 Key2)
       (ParserVar 294:28-34 value2)
       (ValueVar 294:36-40 Key3)
       (ParserVar 294:42-48 value3)))
    (TakeRight 295:2-83
      (TakeRight 295:2-31
        (Destructure 295:2-14
          (ParserVar 295:2-8 value1)
          (ValueVar 295:12-14 V1))
        (Destructure 296:2-14
          (ParserVar 296:2-8 value2)
          (ValueVar 296:12-14 V2)))
      (Return 297:2-49
        (Destructure 297:2-14
          (ParserVar 297:2-8 value3)
          (ValueVar 297:12-14 V3))
        (Object 298:2-32
          ((ValueVar 298:3-7 Key1) (ValueVar 298:9-11 V1))
          ((ValueVar 298:13-17 Key2) (ValueVar 298:19-21 V2))
          ((ValueVar 298:23-27 Key3) (ValueVar 298:29-31 V3))))))
  
  (DeclareGlobal 300:0-165
    (Function 300:0-65
      (ParserVar 300:0-11 record3_sep)
      ((ValueVar 300:12-16 Key1)
       (ParserVar 300:18-24 value1)
       (ParserVar 300:26-30 sep1)
       (ValueVar 300:32-36 Key2)
       (ParserVar 300:38-44 value2)
       (ParserVar 300:46-50 sep2)
       (ValueVar 300:52-56 Key3)
       (ParserVar 300:58-64 value3)))
    (TakeRight 301:2-97
      (TakeRight 301:2-45
        (TakeRight 301:2-38
          (TakeRight 301:2-21
            (Destructure 301:2-14
              (ParserVar 301:2-8 value1)
              (ValueVar 301:12-14 V1))
            (ParserVar 301:17-21 sep1))
          (Destructure 302:2-14
            (ParserVar 302:2-8 value2)
            (ValueVar 302:12-14 V2)))
        (ParserVar 302:17-21 sep2))
      (Return 303:2-49
        (Destructure 303:2-14
          (ParserVar 303:2-8 value3)
          (ValueVar 303:12-14 V3))
        (Object 304:2-32
          ((ValueVar 304:3-7 Key1) (ValueVar 304:9-11 V1))
          ((ValueVar 304:13-17 Key2) (ValueVar 304:19-21 V2))
          ((ValueVar 304:23-27 Key3) (ValueVar 304:29-31 V3))))))
  
  (DeclareGlobal 308:0-38
    (Function 308:0-7 (ParserVar 308:0-4 many) ((ParserVar 308:5-6 p)))
    (TakeRight 308:10-38
      (Destructure 308:10-20
        (ParserVar 308:10-11 p)
        (ValueVar 308:15-20 First))
      (Function 308:23-38 (ParserVar 308:23-28 _many) ((ParserVar 308:29-30 p) (ValueVar 308:32-37 First)))))
  
  (DeclareGlobal 310:0-61
    (Function 310:0-13 (ParserVar 310:0-5 _many) ((ParserVar 310:6-7 p) (ValueVar 310:9-12 Acc)))
    (Conditional 310:16-61
      (condition (Destructure 310:16-25
          (ParserVar 310:16-17 p)
          (ValueVar 310:21-25 Next)))
      (then (Function 310:28-48
          (ParserVar 310:28-33 _many)
          ((ParserVar 310:34-35 p)
           (Merge 310:37-47
              (ValueVar 310:37-40 Acc)
              (ValueVar 310:43-47 Next)))))
      (else (Function 310:51-61 (ParserVar 310:51-56 const) ((ValueVar 310:57-60 Acc))))))
  
  (DeclareGlobal 312:0-53
    (Function 312:0-16 (ParserVar 312:0-8 many_sep) ((ParserVar 312:9-10 p) (ParserVar 312:12-15 sep)))
    (TakeRight 312:19-53
      (Destructure 312:19-29
        (ParserVar 312:19-20 p)
        (ValueVar 312:24-29 First))
      (Function 312:32-53
        (ParserVar 312:32-37 _many)
        ((TakeRight 312:38-45
            (ParserVar 312:38-41 sep)
            (ParserVar 312:44-45 p))
         (ValueVar 312:47-52 First)))))
  
  (DeclareGlobal 314:0-76
    (Function 314:0-19 (ParserVar 314:0-10 many_until) ((ParserVar 314:11-12 p) (ParserVar 314:14-18 stop)))
    (TakeRight 314:22-76
      (Destructure 314:22-46
        (Function 314:22-37 (ParserVar 314:22-28 unless) ((ParserVar 314:29-30 p) (ParserVar 314:32-36 stop)))
        (ValueVar 314:41-46 First))
      (Function 314:49-76
        (ParserVar 314:49-60 _many_until)
        ((ParserVar 314:61-62 p)
         (ParserVar 314:64-68 stop)
         (ValueVar 314:70-75 First)))))
  
  (DeclareGlobal 316:0-104
    (Function 316:0-25
      (ParserVar 316:0-11 _many_until)
      ((ParserVar 316:12-13 p)
       (ParserVar 316:15-19 stop)
       (ValueVar 316:21-24 Acc)))
    (Conditional 317:2-76
      (condition (Function 317:2-12 (ParserVar 317:2-6 peek) ((ParserVar 317:7-11 stop))))
      (then (Function 318:2-12 (ParserVar 318:2-7 const) ((ValueVar 318:8-11 Acc))))
      (else (TakeRight 319:2-46
          (Destructure 319:2-11
            (ParserVar 319:2-3 p)
            (ValueVar 319:7-11 Next))
          (Function 319:14-46
            (ParserVar 319:14-25 _many_until)
            ((ParserVar 319:26-27 p)
             (ParserVar 319:29-33 stop)
             (Merge 319:35-45
                (ValueVar 319:35-38 Acc)
                (ValueVar 319:41-45 Next))))))))
  
  (DeclareGlobal 321:0-33
    (Function 321:0-13 (ParserVar 321:0-10 maybe_many) ((ParserVar 321:11-12 p)))
    (Or 321:16-33
      (Function 321:16-23 (ParserVar 321:16-20 many) ((ParserVar 321:21-22 p)))
      (ParserVar 321:26-33 succeed)))
  
  (DeclareGlobal 323:0-51
    (Function 323:0-22 (ParserVar 323:0-14 maybe_many_sep) ((ParserVar 323:15-16 p) (ParserVar 323:18-21 sep)))
    (Or 323:25-51
      (Function 323:25-41 (ParserVar 323:25-33 many_sep) ((ParserVar 323:34-35 p) (ParserVar 323:37-40 sep)))
      (ParserVar 323:44-51 succeed)))
  
  (DeclareGlobal 325:0-18
    (Function 325:0-10 (ParserVar 325:0-7 repeat2) ((ParserVar 325:8-9 p)))
    (Merge 325:13-18
      (ParserVar 325:13-14 p)
      (ParserVar 325:17-18 p)))
  
  (DeclareGlobal 327:0-22
    (Function 327:0-10 (ParserVar 327:0-7 repeat3) ((ParserVar 327:8-9 p)))
    (Merge 327:13-22
      (Merge 327:13-18
        (ParserVar 327:13-14 p)
        (ParserVar 327:17-18 p))
      (ParserVar 327:21-22 p)))
  
  (DeclareGlobal 329:0-26
    (Function 329:0-10 (ParserVar 329:0-7 repeat4) ((ParserVar 329:8-9 p)))
    (Merge 329:13-26
      (Merge 329:13-22
        (Merge 329:13-18
          (ParserVar 329:13-14 p)
          (ParserVar 329:17-18 p))
        (ParserVar 329:21-22 p))
      (ParserVar 329:25-26 p)))
  
  (DeclareGlobal 331:0-30
    (Function 331:0-10 (ParserVar 331:0-7 repeat5) ((ParserVar 331:8-9 p)))
    (Merge 331:13-30
      (Merge 331:13-26
        (Merge 331:13-22
          (Merge 331:13-18
            (ParserVar 331:13-14 p)
            (ParserVar 331:17-18 p))
          (ParserVar 331:21-22 p))
        (ParserVar 331:25-26 p))
      (ParserVar 331:29-30 p)))
  
  (DeclareGlobal 333:0-34
    (Function 333:0-10 (ParserVar 333:0-7 repeat6) ((ParserVar 333:8-9 p)))
    (Merge 333:13-34
      (Merge 333:13-30
        (Merge 333:13-26
          (Merge 333:13-22
            (Merge 333:13-18
              (ParserVar 333:13-14 p)
              (ParserVar 333:17-18 p))
            (ParserVar 333:21-22 p))
          (ParserVar 333:25-26 p))
        (ParserVar 333:29-30 p))
      (ParserVar 333:33-34 p)))
  
  (DeclareGlobal 335:0-38
    (Function 335:0-10 (ParserVar 335:0-7 repeat7) ((ParserVar 335:8-9 p)))
    (Merge 335:13-38
      (Merge 335:13-34
        (Merge 335:13-30
          (Merge 335:13-26
            (Merge 335:13-22
              (Merge 335:13-18
                (ParserVar 335:13-14 p)
                (ParserVar 335:17-18 p))
              (ParserVar 335:21-22 p))
            (ParserVar 335:25-26 p))
          (ParserVar 335:29-30 p))
        (ParserVar 335:33-34 p))
      (ParserVar 335:37-38 p)))
  
  (DeclareGlobal 337:0-42
    (Function 337:0-10 (ParserVar 337:0-7 repeat8) ((ParserVar 337:8-9 p)))
    (Merge 337:13-42
      (Merge 337:13-38
        (Merge 337:13-34
          (Merge 337:13-30
            (Merge 337:13-26
              (Merge 337:13-22
                (Merge 337:13-18
                  (ParserVar 337:13-14 p)
                  (ParserVar 337:17-18 p))
                (ParserVar 337:21-22 p))
              (ParserVar 337:25-26 p))
            (ParserVar 337:29-30 p))
          (ParserVar 337:33-34 p))
        (ParserVar 337:37-38 p))
      (ParserVar 337:41-42 p)))
  
  (DeclareGlobal 339:0-46
    (Function 339:0-10 (ParserVar 339:0-7 repeat9) ((ParserVar 339:8-9 p)))
    (Merge 339:13-46
      (Merge 339:13-42
        (Merge 339:13-38
          (Merge 339:13-34
            (Merge 339:13-30
              (Merge 339:13-26
                (Merge 339:13-22
                  (Merge 339:13-18
                    (ParserVar 339:13-14 p)
                    (ParserVar 339:17-18 p))
                  (ParserVar 339:21-22 p))
                (ParserVar 339:25-26 p))
              (ParserVar 339:29-30 p))
            (ParserVar 339:33-34 p))
          (ParserVar 339:37-38 p))
        (ParserVar 339:41-42 p))
      (ParserVar 339:45-46 p)))
  
  (DeclareGlobal 341:0-78
    (Function 341:0-12 (ParserVar 341:0-6 repeat) ((ParserVar 341:7-8 p) (ValueVar 341:10-11 N)))
    (TakeRight 342:2-63
      (Function 342:2-38 (ParserVar 342:2-7 const) ((Function 342:8-37 (ValueVar 342:8-34 _Assert.NonNegativeInteger) ((ValueVar 342:35-36 N)))))
      (Function 343:2-22
        (ParserVar 343:2-9 _repeat)
        ((ParserVar 343:10-11 p)
         (ValueVar 343:13-14 N)
         (ValueLabel 343:16-17 (Null 343:17-21 null))))))
  
  (DeclareGlobal 345:0-104
    (Function 345:0-18
      (ParserVar 345:0-7 _repeat)
      ((ParserVar 345:8-9 p)
       (ValueVar 345:11-12 N)
       (ValueVar 345:14-17 Acc)))
    (Conditional 346:2-83
      (condition (Function 346:2-17
          (ParserVar 346:2-7 const)
          ((Destructure 346:8-16
              (ValueVar 346:8-9 N)
              (Range 346:13-16 () (NumberString 346:15-16 0))))))
      (then (Function 347:2-12 (ParserVar 347:2-7 const) ((ValueVar 347:8-11 Acc))))
      (else (TakeRight 348:2-48
          (Destructure 348:2-11
            (ParserVar 348:2-3 p)
            (ValueVar 348:7-11 Next))
          (Function 348:14-48
            (ParserVar 348:14-21 _repeat)
            ((ParserVar 348:22-23 p)
             (Function 348:25-35 (ValueVar 348:25-32 Num.Dec) ((ValueVar 348:33-34 N)))
             (Merge 348:37-47
                (ValueVar 348:37-40 Acc)
                (ValueVar 348:43-47 Next))))))))
  
  (DeclareGlobal 350:0-141
    (Function 350:0-23
      (ParserVar 350:0-14 repeat_between)
      ((ParserVar 350:15-16 p)
       (ValueVar 350:18-19 N)
       (ValueVar 350:21-22 M)))
    (TakeRight 351:2-115
      (TakeRight 351:2-79
        (Function 351:2-38 (ParserVar 351:2-7 const) ((Function 351:8-37 (ValueVar 351:8-34 _Assert.NonNegativeInteger) ((ValueVar 351:35-36 N)))))
        (Function 352:2-38 (ParserVar 352:2-7 const) ((Function 352:8-37 (ValueVar 352:8-34 _Assert.NonNegativeInteger) ((ValueVar 352:35-36 M))))))
      (Function 353:2-33
        (ParserVar 353:2-17 _repeat_between)
        ((ParserVar 353:18-19 p)
         (ValueVar 353:21-22 N)
         (ValueVar 353:24-25 M)
         (ValueLabel 353:27-28 (Null 353:28-32 null))))))
  
  (DeclareGlobal 355:0-182
    (Function 355:0-29
      (ParserVar 355:0-15 _repeat_between)
      ((ParserVar 355:16-17 p)
       (ValueVar 355:19-20 N)
       (ValueVar 355:22-23 M)
       (ValueVar 355:25-28 Acc)))
    (Conditional 356:2-150
      (condition (Function 356:2-17
          (ParserVar 356:2-7 const)
          ((Destructure 356:8-16
              (ValueVar 356:8-9 M)
              (Range 356:13-16 () (NumberString 356:15-16 0))))))
      (then (Function 357:2-12 (ParserVar 357:2-7 const) ((ValueVar 357:8-11 Acc))))
      (else (Conditional 358:2-115
          (condition (Destructure 358:2-11
              (ParserVar 358:2-3 p)
              (ValueVar 358:7-11 Next)))
          (then (Function 359:2-56
              (ParserVar 359:2-17 _repeat_between)
              ((ParserVar 359:18-19 p)
               (Function 359:21-31 (ValueVar 359:21-28 Num.Dec) ((ValueVar 359:29-30 N)))
               (Function 359:33-43 (ValueVar 359:33-40 Num.Dec) ((ValueVar 359:41-42 M)))
               (Merge 359:45-55
                  (ValueVar 359:45-48 Acc)
                  (ValueVar 359:51-55 Next)))))
          (else (Conditional 360:2-42
              (condition (Function 360:2-17
                  (ParserVar 360:2-7 const)
                  ((Destructure 360:8-16
                      (ValueVar 360:8-9 N)
                      (Range 360:13-16 () (NumberString 360:15-16 0))))))
              (then (Function 361:2-12 (ParserVar 361:2-7 const) ((ValueVar 361:8-11 Acc))))
              (else (ParserVar 362:2-7 @fail))))))))
  
  (DeclareGlobal 364:0-51
    (Function 364:0-17 (ParserVar 364:0-11 one_or_both) ((ParserVar 364:12-13 a) (ParserVar 364:15-16 b)))
    (Or 364:20-51
      (Merge 364:20-34
        (ParserVar 364:21-22 a)
        (Function 364:25-33 (ParserVar 364:25-30 maybe) ((ParserVar 364:31-32 b))))
      (Merge 364:37-51
        (Function 364:38-46 (ParserVar 364:38-43 maybe) ((ParserVar 364:44-45 a)))
        (ParserVar 364:49-50 b))))
  
  (DeclareGlobal 368:0-27
    (Function 368:0-7 (ParserVar 368:0-4 peek) ((ParserVar 368:5-6 p)))
    (Backtrack 368:10-27
      (Destructure 368:10-16
        (ParserVar 368:10-11 p)
        (ValueVar 368:15-16 V))
      (Function 368:19-27 (ParserVar 368:19-24 const) ((ValueVar 368:25-26 V)))))
  
  (DeclareGlobal 370:0-22
    (Function 370:0-8 (ParserVar 370:0-5 maybe) ((ParserVar 370:6-7 p)))
    (Or 370:11-22
      (ParserVar 370:11-12 p)
      (ParserVar 370:15-22 succeed)))
  
  (DeclareGlobal 372:0-42
    (Function 372:0-19 (ParserVar 372:0-6 unless) ((ParserVar 372:7-8 p) (ParserVar 372:10-18 excluded)))
    (Conditional 372:22-42
      (condition (ParserVar 372:22-30 excluded))
      (then (ParserVar 372:33-38 @fail))
      (else (ParserVar 372:41-42 p))))
  
  (DeclareGlobal 374:0-17
    (Function 374:0-7 (ParserVar 374:0-4 skip) ((ParserVar 374:5-6 p)))
    (Function 374:10-17 (Null 374:10-14 null) ((ParserVar 374:15-16 p))))
  
  (DeclareGlobal 376:0-30
    (Function 376:0-7 (ParserVar 376:0-4 find) ((ParserVar 376:5-6 p)))
    (Or 376:10-30
      (ParserVar 376:10-11 p)
      (TakeRight 376:14-30
        (ParserVar 376:15-19 char)
        (Function 376:22-29 (ParserVar 376:22-26 find) ((ParserVar 376:27-28 p))))))
  
  (DeclareGlobal 378:0-48
    (Function 378:0-11 (ParserVar 378:0-8 find_all) ((ParserVar 378:9-10 p)))
    (TakeLeft 378:14-48
      (Function 378:14-28 (ParserVar 378:14-19 array) ((Function 378:20-27 (ParserVar 378:20-24 find) ((ParserVar 378:25-26 p)))))
      (Function 378:31-48 (ParserVar 378:31-36 maybe) ((Function 378:37-47 (ParserVar 378:37-41 many) ((ParserVar 378:42-46 char)))))))
  
  (DeclareGlobal 380:0-72
    (Function 380:0-20 (ParserVar 380:0-11 find_before) ((ParserVar 380:12-13 p) (ParserVar 380:15-19 stop)))
    (Conditional 380:23-72
      (condition (ParserVar 380:23-27 stop))
      (then (ParserVar 380:30-35 @fail))
      (else (Or 380:39-72
          (ParserVar 380:39-40 p)
          (TakeRight 380:43-72
            (ParserVar 380:44-48 char)
            (Function 380:51-71 (ParserVar 380:51-62 find_before) ((ParserVar 380:63-64 p) (ParserVar 380:66-70 stop))))))))
  
  (DeclareGlobal 382:0-81
    (Function 382:0-24 (ParserVar 382:0-15 find_all_before) ((ParserVar 382:16-17 p) (ParserVar 382:19-23 stop)))
    (TakeLeft 382:27-81
      (Function 382:27-54 (ParserVar 382:27-32 array) ((Function 382:33-53 (ParserVar 382:33-44 find_before) ((ParserVar 382:45-46 p) (ParserVar 382:48-52 stop)))))
      (Function 382:57-81 (ParserVar 382:57-62 maybe) ((Function 382:63-80 (ParserVar 382:63-74 chars_until) ((ParserVar 382:75-79 stop)))))))
  
  (DeclareGlobal 384:0-22
    (ParserVar 384:0-7 succeed)
    (Function 384:10-22 (ParserVar 384:10-15 const) ((ValueLabel 384:16-17 (Null 384:17-21 null)))))
  
  (DeclareGlobal 386:0-28
    (Function 386:0-13 (ParserVar 386:0-7 default) ((ParserVar 386:8-9 p) (ValueVar 386:11-12 D)))
    (Or 386:16-28
      (ParserVar 386:16-17 p)
      (Function 386:20-28 (ParserVar 386:20-25 const) ((ValueVar 386:26-27 D)))))
  
  (DeclareGlobal 388:0-17
    (Function 388:0-8 (ParserVar 388:0-5 const) ((ValueVar 388:6-7 C)))
    (Return 388:11-17
      (String 388:11-13 "")
      (ValueVar 388:16-17 C)))
  
  (DeclareGlobal 390:0-34
    (Function 390:0-12 (ParserVar 390:0-9 as_number) ((ParserVar 390:10-11 p)))
    (Return 390:15-34
      (Destructure 390:15-30
        (ParserVar 390:15-16 p)
        (StringTemplate 390:20-30 (Merge 390:23-28
          (NumberString 390:23-24 0)
          (ValueVar 390:27-28 N))))
      (ValueVar 390:33-34 N)))
  
  (DeclareGlobal 392:0-21
    (Function 392:0-12 (ParserVar 392:0-9 string_of) ((ParserVar 392:10-11 p)))
    (StringTemplate 392:15-21 (ParserVar 392:18-19 p)))
  
  (DeclareGlobal 394:0-35
    (Function 394:0-17 (ParserVar 394:0-8 surround) ((ParserVar 394:9-10 p) (ParserVar 394:12-16 fill)))
    (TakeLeft 394:20-35
      (TakeRight 394:20-28
        (ParserVar 394:20-24 fill)
        (ParserVar 394:27-28 p))
      (ParserVar 394:31-35 fill)))
  
  (DeclareGlobal 396:0-37
    (ParserVar 396:0-12 end_of_input)
    (Conditional 396:15-37
      (condition (ParserVar 396:15-19 char))
      (then (ParserVar 396:22-27 @fail))
      (else (ParserVar 396:30-37 succeed))))
  
  (DeclareGlobal 398:0-18
    (ParserVar 398:0-3 end)
    (ParserVar 398:6-18 end_of_input))
  
  (DeclareGlobal 400:0-56
    (Function 400:0-8 (ParserVar 400:0-5 input) ((ParserVar 400:6-7 p)))
    (TakeLeft 400:11-56
      (Function 400:11-41 (ParserVar 400:11-19 surround) ((ParserVar 400:20-21 p) (Function 400:23-40 (ParserVar 400:23-28 maybe) ((ParserVar 400:29-39 whitespace)))))
      (ParserVar 400:44-56 end_of_input)))
  
  (DeclareGlobal 404:0-110
    (ParserVar 404:0-4 json)
    (Or 405:2-103
      (ParserVar 405:2-14 json.boolean)
      (Or 406:2-86
        (ParserVar 406:2-11 json.null)
        (Or 407:2-72
          (ParserVar 407:2-13 json.number)
          (Or 408:2-56
            (ParserVar 408:2-13 json.string)
            (Or 409:2-40
              (Function 409:2-18 (ParserVar 409:2-12 json.array) ((ParserVar 409:13-17 json)))
              (Function 410:2-19 (ParserVar 410:2-13 json.object) ((ParserVar 410:14-18 json)))))))))
  
  (DeclareGlobal 412:0-39
    (ParserVar 412:0-12 json.boolean)
    (Function 412:15-39 (ParserVar 412:15-22 boolean) ((String 412:23-29 "true") (String 412:31-38 "false"))))
  
  (DeclareGlobal 414:0-24
    (ParserVar 414:0-9 json.null)
    (Function 414:12-24 (Null 414:12-16 null) ((String 414:17-23 "null"))))
  
  (DeclareGlobal 416:0-20
    (ParserVar 416:0-11 json.number)
    (ParserVar 416:14-20 number))
  
  (DeclareGlobal 418:0-43
    (ParserVar 418:0-11 json.string)
    (TakeLeft 418:14-43
      (TakeRight 418:14-37
        (String 418:14-17 """)
        (ParserVar 418:20-37 _json.string_body))
      (String 418:40-43 """)))
  
  (DeclareGlobal 420:0-133
    (ParserVar 420:0-17 _json.string_body)
    (Or 421:2-113
      (Function 421:2-100
        (ParserVar 421:2-6 many)
        ((Or 422:4-88
            (ParserVar 422:4-22 _escaped_ctrl_char)
            (Or 423:4-63
              (ParserVar 423:4-20 _escaped_unicode)
              (Function 424:4-40
                (ParserVar 424:4-10 unless)
                ((ParserVar 424:11-15 char)
                 (Or 424:17-39
                    (ParserVar 424:17-27 _ctrl_char)
                    (Or 424:30-39
                      (String 424:30-33 "\")
                      (String 424:36-39 """)))))))))
      (Function 425:6-16 (ParserVar 425:6-11 const) ((ValueLabel 425:12-13 (String 425:13-15 ""))))))
  
  (DeclareGlobal 427:0-35
    (ParserVar 427:0-10 _ctrl_char)
    (Range 427:13-35 (String 427:13-23 _0) (String 427:25-35 "\x1f"))) (esc)
  
  (DeclareGlobal 429:0-159
    (ParserVar 429:0-18 _escaped_ctrl_char)
    (Or 430:2-138
      (Return 430:2-14
        (String 430:3-7 "\"")
        (String 430:10-13 """))
      (Or 431:2-121
        (Return 431:2-14
          (String 431:3-7 "\\")
          (String 431:10-13 "\"))
        (Or 432:2-104
          (Return 432:2-14
            (String 432:3-7 "\/")
            (String 432:10-13 "/"))
          (Or 433:2-87
            (Return 433:2-15
              (String 433:3-7 "\b")
              (String 433:10-14 "\x08")) (esc)
            (Or 434:2-69
              (Return 434:2-15
                (String 434:3-7 "\f")
                (String 434:10-14 "\x0c")) (esc)
              (Or 435:2-51
                (Return 435:2-15
                  (String 435:3-7 "\n")
                  (String 435:10-14 "
  "))
                (Or 436:2-33
                  (Return 436:2-15
                    (String 436:3-7 "\r")
                    (String 436:10-14 "\r (no-eol) (esc)
  "))
                  (Return 437:2-15
                    (String 437:3-7 "\t")
                    (String 437:10-14 "\t")))))))))) (esc)
  
  (DeclareGlobal 439:0-63
    (ParserVar 439:0-16 _escaped_unicode)
    (Or 439:19-63
      (ParserVar 439:19-42 _escaped_surrogate_pair)
      (ParserVar 439:45-63 _escaped_codepoint)))
  
  (DeclareGlobal 441:0-73
    (ParserVar 441:0-23 _escaped_surrogate_pair)
    (Or 441:26-73
      (ParserVar 441:26-47 _valid_surrogate_pair)
      (ParserVar 441:50-73 _invalid_surrogate_pair)))
  
  (DeclareGlobal 443:0-100
    (ParserVar 443:0-21 _valid_surrogate_pair)
    (TakeRight 444:2-76
      (Destructure 444:2-22
        (ParserVar 444:2-17 _high_surrogate)
        (ValueVar 444:21-22 H))
      (Return 444:25-76
        (Destructure 444:25-44
          (ParserVar 444:25-39 _low_surrogate)
          (ValueVar 444:43-44 L))
        (Function 444:47-76 (ValueVar 444:47-70 @SurrogatePairCodepoint) ((ValueVar 444:71-72 H) (ValueVar 444:74-75 L))))))
  
  (DeclareGlobal 446:0-71
    (ParserVar 446:0-23 _invalid_surrogate_pair)
    (Return 446:26-71
      (Or 446:26-58
        (ParserVar 446:26-40 _low_surrogate)
        (ParserVar 446:43-58 _high_surrogate))
      (String 446:61-71 "\xef\xbf\xbd"))) (esc)
  
  (DeclareGlobal 448:0-104
    (ParserVar 448:0-15 _high_surrogate)
    (Merge 449:2-86
      (Merge 449:2-72
        (Merge 449:2-58
          (TakeRight 449:2-20
            (String 449:2-6 "\u")
            (Or 449:9-20
              (String 449:10-13 "D")
              (String 449:16-19 "d")))
          (Or 449:23-58
            (String 449:24-27 "8")
            (Or 449:30-57
              (String 449:30-33 "9")
              (Or 449:36-57
                (String 449:36-39 "A")
                (Or 449:42-57
                  (String 449:42-45 "B")
                  (Or 449:48-57
                    (String 449:48-51 "a")
                    (String 449:54-57 "b")))))))
        (ParserVar 449:61-72 hex_numeral))
      (ParserVar 449:75-86 hex_numeral)))
  
  (DeclareGlobal 451:0-89
    (ParserVar 451:0-14 _low_surrogate)
    (Merge 452:2-72
      (Merge 452:2-58
        (Merge 452:2-44
          (TakeRight 452:2-20
            (String 452:2-6 "\u")
            (Or 452:9-20
              (String 452:10-13 "D")
              (String 452:16-19 "d")))
          (Or 452:23-44
            (Range 452:24-32 (String 452:24-27 "C") (String 452:29-32 "F"))
            (Range 452:35-43 (String 452:35-38 "c") (String 452:40-43 "f"))))
        (ParserVar 452:47-58 hex_numeral))
      (ParserVar 452:61-72 hex_numeral)))
  
  (DeclareGlobal 454:0-69
    (ParserVar 454:0-18 _escaped_codepoint)
    (Return 454:21-69
      (Destructure 454:21-53
        (TakeRight 454:21-48
          (String 454:21-25 "\u")
          (Function 454:28-48 (ParserVar 454:28-35 repeat4) ((ParserVar 454:36-47 hex_numeral))))
        (ValueVar 454:52-53 U))
      (Function 454:56-69 (ValueVar 454:56-66 @Codepoint) ((ValueVar 454:67-68 U)))))
  
  (DeclareGlobal 456:0-78
    (Function 456:0-16 (ParserVar 456:0-10 json.array) ((ParserVar 456:11-15 elem)))
    (TakeLeft 456:19-78
      (TakeRight 456:19-72
        (String 456:19-22 "[")
        (Function 456:25-72 (ParserVar 456:25-40 maybe_array_sep) ((Function 456:41-66 (ParserVar 456:41-49 surround) ((ParserVar 456:50-54 elem) (Function 456:56-65 (ParserVar 456:56-61 maybe) ((ParserVar 456:62-64 ws))))) (String 456:68-71 ","))))
      (String 456:75-78 "]")))
  
  (DeclareGlobal 458:0-139
    (Function 458:0-18 (ParserVar 458:0-11 json.object) ((ParserVar 458:12-17 value)))
    (TakeLeft 459:2-118
      (TakeRight 459:2-110
        (String 459:2-5 "{")
        (Function 460:2-102
          (ParserVar 460:2-18 maybe_object_sep)
          ((Function 461:4-36 (ParserVar 461:4-12 surround) ((ParserVar 461:13-24 json.string) (Function 461:26-35 (ParserVar 461:26-31 maybe) ((ParserVar 461:32-34 ws)))))
           (String 461:38-41 ":")
           (Function 462:4-30 (ParserVar 462:4-12 surround) ((ParserVar 462:13-18 value) (Function 462:20-29 (ParserVar 462:20-25 maybe) ((ParserVar 462:26-28 ws)))))
           (String 462:32-35 ","))))
      (String 464:4-7 "}")))
  
  (DeclareGlobal 468:0-18
    (ParserVar 468:0-4 toml)
    (ParserVar 468:7-18 toml.simple))
  
  (DeclareGlobal 470:0-44
    (ParserVar 470:0-11 toml.simple)
    (Function 470:14-44 (ParserVar 470:14-25 toml.custom) ((ParserVar 470:26-43 toml.simple_value))))
  
  (DeclareGlobal 472:0-44
    (ParserVar 472:0-11 toml.tagged)
    (Function 472:14-44 (ParserVar 472:14-25 toml.custom) ((ParserVar 472:26-43 toml.tagged_value))))
  
  (DeclareGlobal 474:0-188
    (Function 474:0-18 (ParserVar 474:0-11 toml.custom) ((ParserVar 474:12-17 value)))
    (TakeRight 475:2-167
      (TakeRight 475:2-104
        (Function 475:2-35
          (ParserVar 475:2-7 maybe)
          ((Merge 475:8-34
              (ParserVar 475:8-22 _toml.comments)
              (Function 475:25-34 (ParserVar 475:25-30 maybe) ((ParserVar 475:31-33 ws))))))
        (Destructure 476:2-66
          (Or 476:2-59
            (Function 476:2-30 (ParserVar 476:2-23 _toml.with_root_table) ((ParserVar 476:24-29 value)))
            (Function 476:33-59 (ParserVar 476:33-52 _toml.no_root_table) ((ParserVar 476:53-58 value))))
          (ValueVar 476:63-66 Doc)))
      (Return 477:2-60
        (Function 477:2-35
          (ParserVar 477:2-7 maybe)
          ((Merge 477:8-34
              (Function 477:8-17 (ParserVar 477:8-13 maybe) ((ParserVar 477:14-16 ws)))
              (ParserVar 477:20-34 _toml.comments))))
        (Function 478:2-22 (ValueVar 478:2-17 _Toml.Doc.Value) ((ValueVar 478:18-21 Doc))))))
  
  (DeclareGlobal 480:0-147
    (Function 480:0-28 (ParserVar 480:0-21 _toml.with_root_table) ((ParserVar 480:22-27 value)))
    (TakeRight 481:2-116
      (Destructure 481:2-53
        (Function 481:2-42 (ParserVar 481:2-18 _toml.root_table) ((ParserVar 481:19-24 value) (ValueVar 481:26-41 _Toml.Doc.Empty)))
        (ValueVar 481:46-53 RootDoc))
      (Or 482:2-60
        (TakeRight 482:2-43
          (ParserVar 482:3-11 _toml.ws)
          (Function 482:14-42 (ParserVar 482:14-26 _toml.tables) ((ParserVar 482:27-32 value) (ValueVar 482:34-41 RootDoc))))
        (Function 482:46-60 (ParserVar 482:46-51 const) ((ValueVar 482:52-59 RootDoc))))))
  
  (DeclareGlobal 484:0-65
    (Function 484:0-28 (ParserVar 484:0-16 _toml.root_table) ((ParserVar 484:17-22 value) (ValueVar 484:24-27 Doc)))
    (Function 485:2-34
      (ParserVar 485:2-18 _toml.table_body)
      ((ParserVar 485:19-24 value)
       (Array 485:26-29 ())
       (ValueVar 485:30-33 Doc))))
  
  (DeclareGlobal 487:0-156
    (Function 487:0-26 (ParserVar 487:0-19 _toml.no_root_table) ((ParserVar 487:20-25 value)))
    (TakeRight 488:2-127
      (Destructure 488:2-95
        (Or 488:2-85
          (Function 488:2-37 (ParserVar 488:2-13 _toml.table) ((ParserVar 488:14-19 value) (ValueVar 488:21-36 _Toml.Doc.Empty)))
          (Function 488:40-85 (ParserVar 488:40-61 _toml.array_of_tables) ((ParserVar 488:62-67 value) (ValueVar 488:69-84 _Toml.Doc.Empty))))
        (ValueVar 488:89-95 NewDoc))
      (Function 489:2-29 (ParserVar 489:2-14 _toml.tables) ((ParserVar 489:15-20 value) (ValueVar 489:22-28 NewDoc)))))
  
  (DeclareGlobal 491:0-158
    (Function 491:0-24 (ParserVar 491:0-12 _toml.tables) ((ParserVar 491:13-18 value) (ValueVar 491:20-23 Doc)))
    (Conditional 492:2-131
      (condition (Destructure 492:2-84
          (Or 492:2-74
            (TakeRight 492:2-38
              (ParserVar 492:2-10 _toml.ws)
              (Function 493:2-25 (ParserVar 493:2-13 _toml.table) ((ParserVar 493:14-19 value) (ValueVar 493:21-24 Doc))))
            (Function 493:28-61 (ParserVar 493:28-49 _toml.array_of_tables) ((ParserVar 493:50-55 value) (ValueVar 493:57-60 Doc))))
          (ValueVar 493:65-71 NewDoc)))
      (then (Function 494:2-29 (ParserVar 494:2-14 _toml.tables) ((ParserVar 494:15-20 value) (ValueVar 494:22-28 NewDoc))))
      (else (Function 495:2-12 (ParserVar 495:2-7 const) ((ValueVar 495:8-11 Doc))))))
  
  (DeclareGlobal 497:0-190
    (Function 497:0-23 (ParserVar 497:0-11 _toml.table) ((ParserVar 497:12-17 value) (ValueVar 497:19-22 Doc)))
    (TakeRight 498:2-164
      (TakeRight 498:2-53
        (Destructure 498:2-34
          (ParserVar 498:2-20 _toml.table_header)
          (ValueVar 498:24-34 HeaderPath))
        (ParserVar 498:37-53 _toml.ws_newline))
      (Or 498:56-164
        (Function 499:4-44
          (ParserVar 499:4-20 _toml.table_body)
          ((ParserVar 499:21-26 value)
           (ValueVar 499:28-38 HeaderPath)
           (ValueVar 499:40-43 Doc)))
        (Function 500:4-55 (ParserVar 500:4-9 const) ((Function 500:10-54 (ValueVar 500:10-37 _Toml.Doc.EnsureTableAtPath) ((ValueVar 500:38-41 Doc) (ValueVar 500:43-53 HeaderPath))))))))
  
  (DeclareGlobal 503:0-257
    (Function 503:0-33 (ParserVar 503:0-21 _toml.array_of_tables) ((ParserVar 503:22-27 value) (ValueVar 503:29-32 Doc)))
    (TakeRight 504:2-221
      (TakeRight 504:2-63
        (Destructure 504:2-44
          (ParserVar 504:2-30 _toml.array_of_tables_header)
          (ValueVar 504:34-44 HeaderPath))
        (ParserVar 504:47-63 _toml.ws_newline))
      (Return 505:2-155
        (Destructure 505:2-84
          (Function 505:2-72
            (ParserVar 505:2-9 default)
            ((Function 505:10-54
                (ParserVar 505:10-26 _toml.table_body)
                ((ParserVar 505:27-32 value)
                 (Array 505:34-37 ())
                 (ValueVar 505:38-53 _Toml.Doc.Empty)))
             (ValueVar 505:56-71 _Toml.Doc.Empty)))
          (ValueVar 505:76-84 InnerDoc))
        (Function 506:2-68
          (ValueVar 506:2-24 _Toml.Doc.AppendAtPath)
          ((ValueVar 506:25-28 Doc)
           (ValueVar 506:30-40 HeaderPath)
           (Function 506:42-67 (ValueVar 506:42-57 _Toml.Doc.Value) ((ValueVar 506:58-66 InnerDoc))))))))
  
  (DeclareGlobal 508:0-41
    (ParserVar 508:0-8 _toml.ws)
    (Function 508:11-41
      (ParserVar 508:11-21 maybe_many)
      ((Or 508:22-40
          (ParserVar 508:22-24 ws)
          (ParserVar 508:27-40 _toml.comment)))))
  
  (DeclareGlobal 510:0-50
    (ParserVar 510:0-13 _toml.ws_line)
    (Function 510:16-50
      (ParserVar 510:16-26 maybe_many)
      ((Or 510:27-49
          (ParserVar 510:27-33 spaces)
          (ParserVar 510:36-49 _toml.comment)))))
  
  (DeclareGlobal 512:0-56
    (ParserVar 512:0-16 _toml.ws_newline)
    (Merge 512:19-56
      (Merge 512:19-45
        (ParserVar 512:19-32 _toml.ws_line)
        (Or 512:35-45
          (ParserVar 512:36-38 nl)
          (ParserVar 512:41-44 end)))
      (ParserVar 512:48-56 _toml.ws)))
  
  (DeclareGlobal 514:0-44
    (ParserVar 514:0-14 _toml.comments)
    (Function 514:17-44 (ParserVar 514:17-25 many_sep) ((ParserVar 514:26-39 _toml.comment) (ParserVar 514:41-43 ws))))
  
  (DeclareGlobal 516:0-64
    (ParserVar 516:0-18 _toml.table_header)
    (TakeLeft 516:21-64
      (TakeRight 516:21-58
        (String 516:21-24 "[")
        (Function 516:27-58 (ParserVar 516:27-35 surround) ((ParserVar 516:36-46 _toml.path) (Function 516:48-57 (ParserVar 516:48-53 maybe) ((ParserVar 516:54-56 ws))))))
      (String 516:61-64 "]")))
  
  (DeclareGlobal 518:0-78
    (ParserVar 518:0-28 _toml.array_of_tables_header)
    (TakeLeft 519:2-47
      (TakeRight 519:2-40
        (String 519:2-6 "[[")
        (Function 519:9-40 (ParserVar 519:9-17 surround) ((ParserVar 519:18-28 _toml.path) (Function 519:30-39 (ParserVar 519:30-35 maybe) ((ParserVar 519:36-38 ws))))))
      (String 519:43-47 "]]")))
  
  (DeclareGlobal 521:0-245
    (Function 521:0-40
      (ParserVar 521:0-16 _toml.table_body)
      ((ParserVar 521:17-22 value)
       (ValueVar 521:24-34 HeaderPath)
       (ValueVar 521:36-39 Doc)))
    (TakeRight 522:2-202
      (TakeRight 522:2-138
        (TakeRight 522:2-62
          (Destructure 522:2-43
            (Function 522:2-25 (ParserVar 522:2-18 _toml.table_pair) ((ParserVar 522:19-24 value)))
            (Array 522:29-43 ((ValueVar 522:30-37 KeyPath) (ValueVar 522:39-42 Val))))
          (ParserVar 522:46-62 _toml.ws_newline))
        (Destructure 523:2-73
          (Function 523:2-63
            (ParserVar 523:2-7 const)
            ((Function 523:8-62
                (ValueVar 523:8-30 _Toml.Doc.InsertAtPath)
                ((ValueVar 523:31-34 Doc)
                 (Merge 523:36-56
                    (ValueVar 523:36-46 HeaderPath)
                    (ValueVar 523:49-56 KeyPath))
                 (ValueVar 523:58-61 Val)))))
          (ValueVar 523:67-73 NewDoc)))
      (Or 524:2-61
        (Function 524:2-45
          (ParserVar 524:2-18 _toml.table_body)
          ((ParserVar 524:19-24 value)
           (ValueVar 524:26-36 HeaderPath)
           (ValueVar 524:38-44 NewDoc)))
        (Function 524:48-61 (ParserVar 524:48-53 const) ((ValueVar 524:54-60 NewDoc))))))
  
  (DeclareGlobal 526:0-87
    (Function 526:0-23 (ParserVar 526:0-16 _toml.table_pair) ((ParserVar 526:17-22 value)))
    (Function 527:2-61
      (ParserVar 527:2-12 tuple2_sep)
      ((ParserVar 527:13-23 _toml.path)
       (Function 527:25-53 (ParserVar 527:25-33 surround) ((String 527:34-37 "=") (Function 527:39-52 (ParserVar 527:39-44 maybe) ((ParserVar 527:45-51 spaces)))))
       (ParserVar 527:55-60 value))))
  
  (DeclareGlobal 529:0-59
    (ParserVar 529:0-10 _toml.path)
    (Function 529:13-59 (ParserVar 529:13-22 array_sep) ((ParserVar 529:23-32 _toml.key) (Function 529:34-58 (ParserVar 529:34-42 surround) ((String 529:43-46 ".") (Function 529:48-57 (ParserVar 529:48-53 maybe) ((ParserVar 529:54-56 ws))))))))
  
  (DeclareGlobal 531:0-93
    (ParserVar 531:0-9 _toml.key)
    (Or 532:2-81
      (Function 532:2-35
        (ParserVar 532:2-6 many)
        ((Or 532:7-34
            (ParserVar 532:7-12 alpha)
            (Or 532:15-34
              (ParserVar 532:15-22 numeral)
              (Or 532:25-34
                (String 532:25-28 "_")
                (String 532:31-34 "-"))))))
      (Or 533:2-43
        (ParserVar 533:2-19 toml.string.basic)
        (ParserVar 534:2-21 toml.string.literal))))
  
  (DeclareGlobal 536:0-33
    (ParserVar 536:0-13 _toml.comment)
    (TakeRight 536:16-33
      (String 536:16-19 "#")
      (Function 536:22-33 (ParserVar 536:22-27 maybe) ((ParserVar 536:28-32 line)))))
  
  (DeclareGlobal 538:0-159
    (ParserVar 538:0-17 toml.simple_value)
    (Or 539:2-139
      (ParserVar 539:2-13 toml.string)
      (Or 540:2-123
        (ParserVar 540:2-15 toml.datetime)
        (Or 541:2-105
          (ParserVar 541:2-13 toml.number)
          (Or 542:2-89
            (ParserVar 542:2-14 toml.boolean)
            (Or 543:2-72
              (Function 543:2-31 (ParserVar 543:2-12 toml.array) ((ParserVar 543:13-30 toml.simple_value)))
              (Function 544:2-38 (ParserVar 544:2-19 toml.inline_table) ((ParserVar 544:20-37 toml.simple_value)))))))))
  
  (DeclareGlobal 546:0-640
    (ParserVar 546:0-17 toml.tagged_value)
    (Or 547:2-620
      (ParserVar 547:2-13 toml.string)
      (Or 548:2-604
        (Function 548:2-57
          (ParserVar 548:2-11 _toml.tag)
          ((ValueLabel 548:12-13 (String 548:13-23 "datetime"))
           (ValueLabel 548:25-26 (String 548:26-34 "offset"))
           (ParserVar 548:36-56 toml.datetime.offset)))
        (Or 549:2-544
          (Function 549:2-55
            (ParserVar 549:2-11 _toml.tag)
            ((ValueLabel 549:12-13 (String 549:13-23 "datetime"))
             (ValueLabel 549:25-26 (String 549:26-33 "local"))
             (ParserVar 549:35-54 toml.datetime.local)))
          (Or 550:2-486
            (Function 550:2-65
              (ParserVar 550:2-11 _toml.tag)
              ((ValueLabel 550:12-13 (String 550:13-23 "datetime"))
               (ValueLabel 550:25-26 (String 550:26-38 "date-local"))
               (ParserVar 550:40-64 toml.datetime.local_date)))
            (Or 551:2-418
              (Function 551:2-65
                (ParserVar 551:2-11 _toml.tag)
                ((ValueLabel 551:12-13 (String 551:13-23 "datetime"))
                 (ValueLabel 551:25-26 (String 551:26-38 "time-local"))
                 (ParserVar 551:40-64 toml.datetime.local_time)))
              (Or 552:2-350
                (ParserVar 552:2-28 toml.number.binary_integer)
                (Or 553:2-319
                  (ParserVar 553:2-27 toml.number.octal_integer)
                  (Or 554:2-289
                    (ParserVar 554:2-25 toml.number.hex_integer)
                    (Or 555:2-261
                      (Function 555:2-56
                        (ParserVar 555:2-11 _toml.tag)
                        ((ValueLabel 555:12-13 (String 555:13-20 "float"))
                         (ValueLabel 555:22-23 (String 555:23-33 "infinity"))
                         (ParserVar 555:35-55 toml.number.infinity)))
                      (Or 556:2-202
                        (Function 556:2-64
                          (ParserVar 556:2-11 _toml.tag)
                          ((ValueLabel 556:12-13 (String 556:13-20 "float"))
                           (ValueLabel 556:22-23 (String 556:23-37 "not-a-number"))
                           (ParserVar 556:39-63 toml.number.not_a_number)))
                        (Or 557:2-135
                          (ParserVar 557:2-19 toml.number.float)
                          (Or 558:2-113
                            (ParserVar 558:2-21 toml.number.integer)
                            (Or 559:2-89
                              (ParserVar 559:2-14 toml.boolean)
                              (Or 560:2-72
                                (Function 560:2-31 (ParserVar 560:2-12 toml.array) ((ParserVar 560:13-30 toml.tagged_value)))
                                (Function 561:2-38 (ParserVar 561:2-19 toml.inline_table) ((ParserVar 561:20-37 toml.tagged_value))))))))))))))))))
  
  (DeclareGlobal 563:0-103
    (Function 563:0-31
      (ParserVar 563:0-9 _toml.tag)
      ((ValueVar 563:10-14 Type)
       (ValueVar 563:16-23 Subtype)
       (ParserVar 563:25-30 value)))
    (Return 564:2-69
      (Destructure 564:2-16
        (ParserVar 564:2-7 value)
        (ValueVar 564:11-16 Value))
      (Object 564:19-69
        ((String 564:20-26 "type") (ValueVar 564:28-32 Type))
        ((String 564:34-43 "subtype") (ValueVar 564:45-52 Subtype))
        ((String 564:54-61 "value") (ValueVar 564:63-68 Value)))))
  
  (DeclareGlobal 566:0-125
    (ParserVar 566:0-11 toml.string)
    (Or 567:2-111
      (ParserVar 567:2-30 toml.string.multi_line_basic)
      (Or 568:2-78
        (ParserVar 568:2-32 toml.string.multi_line_literal)
        (Or 569:2-43
          (ParserVar 569:2-19 toml.string.basic)
          (ParserVar 570:2-21 toml.string.literal)))))
  
  (DeclareGlobal 572:0-120
    (ParserVar 572:0-13 toml.datetime)
    (Or 573:2-104
      (ParserVar 573:2-22 toml.datetime.offset)
      (Or 574:2-79
        (ParserVar 574:2-21 toml.datetime.local)
        (Or 575:2-55
          (ParserVar 575:2-26 toml.datetime.local_date)
          (ParserVar 576:2-26 toml.datetime.local_time)))))
  
  (DeclareGlobal 578:0-200
    (ParserVar 578:0-11 toml.number)
    (Or 579:2-186
      (ParserVar 579:2-28 toml.number.binary_integer)
      (Or 580:2-155
        (ParserVar 580:2-27 toml.number.octal_integer)
        (Or 581:2-125
          (ParserVar 581:2-25 toml.number.hex_integer)
          (Or 582:2-97
            (ParserVar 582:2-22 toml.number.infinity)
            (Or 583:2-72
              (ParserVar 583:2-26 toml.number.not_a_number)
              (Or 584:2-43
                (ParserVar 584:2-19 toml.number.float)
                (ParserVar 585:2-21 toml.number.integer))))))))
  
  (DeclareGlobal 587:0-39
    (ParserVar 587:0-12 toml.boolean)
    (Function 587:15-39 (ParserVar 587:15-22 boolean) ((String 587:23-29 "true") (String 587:31-38 "false"))))
  
  (DeclareGlobal 589:0-153
    (Function 589:0-16 (ParserVar 589:0-10 toml.array) ((ParserVar 589:11-15 elem)))
    (TakeLeft 590:2-134
      (TakeLeft 590:2-128
        (TakeRight 590:2-117
          (TakeRight 590:2-16
            (String 590:2-5 "[")
            (ParserVar 590:8-16 _toml.ws))
          (Function 590:19-117
            (ParserVar 590:19-26 default)
            ((TakeLeft 591:4-77
                (Function 591:4-44 (ParserVar 591:4-13 array_sep) ((Function 591:14-38 (ParserVar 591:14-22 surround) ((ParserVar 591:23-27 elem) (ParserVar 591:29-37 _toml.ws))) (String 591:40-43 ",")))
                (Function 591:47-77 (ParserVar 591:47-52 maybe) ((Function 591:53-76 (ParserVar 591:53-61 surround) ((String 591:62-65 ",") (ParserVar 591:67-75 _toml.ws))))))
             (Array 592:4-10 ()))))
        (ParserVar 593:6-14 _toml.ws))
      (String 593:17-20 "]")))
  
  (DeclareGlobal 595:0-134
    (Function 595:0-24 (ParserVar 595:0-17 toml.inline_table) ((ParserVar 595:18-23 value)))
    (Return 596:2-107
      (Destructure 596:2-76
        (Or 596:2-63
          (ParserVar 596:2-26 _toml.empty_inline_table)
          (Function 596:29-63 (ParserVar 596:29-56 _toml.nonempty_inline_table) ((ParserVar 596:57-62 value))))
        (ValueVar 596:67-76 InlineDoc))
      (Function 597:2-28 (ValueVar 597:2-17 _Toml.Doc.Value) ((ValueVar 597:18-27 InlineDoc)))))
  
  (DeclareGlobal 599:0-70
    (ParserVar 599:0-24 _toml.empty_inline_table)
    (Return 599:27-70
      (TakeLeft 599:27-52
        (TakeRight 599:27-46
          (String 599:27-30 "{")
          (Function 599:33-46 (ParserVar 599:33-38 maybe) ((ParserVar 599:39-45 spaces))))
        (String 599:49-52 "}"))
      (ValueVar 599:55-70 _Toml.Doc.Empty)))
  
  (DeclareGlobal 601:0-207
    (Function 601:0-34 (ParserVar 601:0-27 _toml.nonempty_inline_table) ((ParserVar 601:28-33 value)))
    (TakeRight 602:2-170
      (Destructure 602:2-93
        (TakeRight 602:2-73
          (TakeRight 602:2-21
            (String 602:2-5 "{")
            (Function 602:8-21 (ParserVar 602:8-13 maybe) ((ParserVar 602:14-20 spaces))))
          (Function 603:2-49 (ParserVar 603:2-25 _toml.inline_table_pair) ((ParserVar 603:26-31 value) (ValueVar 603:33-48 _Toml.Doc.Empty))))
        (ValueVar 603:53-69 DocWithFirstPair))
      (TakeLeft 604:2-74
        (TakeLeft 604:2-68
          (Function 604:2-50 (ParserVar 604:2-25 _toml.inline_table_body) ((ParserVar 604:26-31 value) (ValueVar 604:33-49 DocWithFirstPair)))
          (Function 605:4-17 (ParserVar 605:4-9 maybe) ((ParserVar 605:10-16 spaces))))
        (String 605:20-23 "}"))))
  
  (DeclareGlobal 607:0-149
    (Function 607:0-35 (ParserVar 607:0-23 _toml.inline_table_body) ((ParserVar 607:24-29 value) (ValueVar 607:31-34 Doc)))
    (Conditional 608:2-111
      (condition (Destructure 608:2-53
          (TakeRight 608:2-43
            (String 608:2-5 ",")
            (Function 608:8-43 (ParserVar 608:8-31 _toml.inline_table_pair) ((ParserVar 608:32-37 value) (ValueVar 608:39-42 Doc))))
          (ValueVar 608:47-53 NewDoc)))
      (then (Function 609:2-40 (ParserVar 609:2-25 _toml.inline_table_body) ((ParserVar 609:26-31 value) (ValueVar 609:33-39 NewDoc))))
      (else (Function 610:2-12 (ParserVar 610:2-7 const) ((ValueVar 610:8-11 Doc))))))
  
  (DeclareGlobal 612:0-192
    (Function 612:0-35 (ParserVar 612:0-23 _toml.inline_table_pair) ((ParserVar 612:24-29 value) (ValueVar 612:31-34 Doc)))
    (TakeRight 613:2-154
      (TakeRight 613:2-94
        (TakeRight 613:2-77
          (TakeRight 613:2-61
            (TakeRight 613:2-55
              (TakeRight 613:2-37
                (Function 613:2-15 (ParserVar 613:2-7 maybe) ((ParserVar 613:8-14 spaces)))
                (Destructure 614:2-19
                  (ParserVar 614:2-12 _toml.path)
                  (ValueVar 614:16-19 Key)))
              (Function 615:2-15 (ParserVar 615:2-7 maybe) ((ParserVar 615:8-14 spaces))))
            (String 615:18-21 "="))
          (Function 615:24-37 (ParserVar 615:24-29 maybe) ((ParserVar 615:30-36 spaces))))
        (Destructure 616:2-14
          (ParserVar 616:2-7 value)
          (ValueVar 616:11-14 Val)))
      (Return 617:2-57
        (Function 617:2-15 (ParserVar 617:2-7 maybe) ((ParserVar 617:8-14 spaces)))
        (Function 618:2-39
          (ValueVar 618:2-24 _Toml.Doc.InsertAtPath)
          ((ValueVar 618:25-28 Doc)
           (ValueVar 618:30-33 Key)
           (ValueVar 618:35-38 Val))))))
  
  (DeclareGlobal 620:0-85
    (ParserVar 620:0-28 toml.string.multi_line_basic)
    (TakeRight 620:31-85
      (TakeRight 620:31-48
        (String 620:31-36 """"")
        (Function 620:39-48 (ParserVar 620:39-44 maybe) ((ParserVar 620:45-47 nl))))
      (Function 620:51-85 (ParserVar 620:51-80 _toml.string.multi_line_basic) ((ValueLabel 620:81-82 (String 620:82-84 ""))))))
  
  (DeclareGlobal 622:0-292
    (Function 622:0-34 (ParserVar 622:0-29 _toml.string.multi_line_basic) ((ValueVar 622:30-33 Acc)))
    (Or 623:2-255
      (Return 623:2-26
        (String 623:3-10 """"""")
        (Merge 623:13-25
          (ValueVar 623:14-17 Acc)
          (String 623:20-24 """")))
      (Or 624:2-226
        (Return 624:2-24
          (String 624:3-9 """""")
          (Merge 624:12-23
            (ValueVar 624:13-16 Acc)
            (String 624:19-22 """)))
        (Or 625:2-199
          (Return 625:2-15
            (String 625:3-8 """"")
            (ValueVar 625:11-14 Acc))
          (TakeRight 626:2-181
            (Destructure 627:4-128
              (Or 627:4-123
                (ParserVar 627:4-27 _toml.escaped_ctrl_char)
                (Or 628:4-93
                  (ParserVar 628:4-25 _toml.escaped_unicode)
                  (Or 629:4-65
                    (ParserVar 629:4-6 ws)
                    (Or 630:4-56
                      (TakeRight 630:4-19
                        (Merge 630:5-13
                          (String 630:5-8 "\")
                          (ParserVar 630:11-13 ws))
                        (String 630:16-18 ""))
                      (Function 631:4-34
                        (ParserVar 631:4-10 unless)
                        ((ParserVar 631:11-15 char)
                         (Or 631:17-33
                            (ParserVar 631:17-27 _ctrl_char)
                            (String 631:30-33 "\"))))))))
              (ValueVar 631:38-39 C))
            (Function 632:4-42
              (ParserVar 632:4-33 _toml.string.multi_line_basic)
              ((Merge 632:34-41
                  (ValueVar 632:34-37 Acc)
                  (ValueVar 632:40-41 C)))))))))
  
  (DeclareGlobal 635:0-89
    (ParserVar 635:0-30 toml.string.multi_line_literal)
    (TakeRight 635:33-89
      (TakeRight 635:33-50
        (String 635:33-38 "'''")
        (Function 635:41-50 (ParserVar 635:41-46 maybe) ((ParserVar 635:47-49 nl))))
      (Function 635:53-89 (ParserVar 635:53-84 _toml.string.multi_line_literal) ((ValueLabel 635:85-86 (String 635:86-88 ""))))))
  
  (DeclareGlobal 637:0-169
    (Function 637:0-36 (ParserVar 637:0-31 _toml.string.multi_line_literal) ((ValueVar 637:32-35 Acc)))
    (Or 638:2-130
      (Return 638:2-26
        (String 638:3-10 "'''''")
        (Merge 638:13-25
          (ValueVar 638:14-17 Acc)
          (String 638:20-24 "''")))
      (Or 639:2-101
        (Return 639:2-24
          (String 639:3-9 "''''")
          (Merge 639:12-23
            (ValueVar 639:13-16 Acc)
            (String 639:19-22 "'")))
        (Or 640:2-74
          (Return 640:2-15
            (String 640:3-8 "'''")
            (ValueVar 640:11-14 Acc))
          (TakeRight 641:2-56
            (Destructure 641:3-12
              (ParserVar 641:3-7 char)
              (ValueVar 641:11-12 C))
            (Function 641:15-55
              (ParserVar 641:15-46 _toml.string.multi_line_literal)
              ((Merge 641:47-54
                  (ValueVar 641:47-50 Acc)
                  (ValueVar 641:53-54 C)))))))))
  
  (DeclareGlobal 643:0-55
    (ParserVar 643:0-17 toml.string.basic)
    (TakeLeft 643:20-55
      (TakeRight 643:20-49
        (String 643:20-23 """)
        (ParserVar 643:26-49 _toml.string.basic_body))
      (String 643:52-55 """)))
  
  (DeclareGlobal 645:0-149
    (ParserVar 645:0-23 _toml.string.basic_body)
    (Or 646:2-123
      (Function 646:2-110
        (ParserVar 646:2-6 many)
        ((Or 647:4-98
            (ParserVar 647:4-27 _toml.escaped_ctrl_char)
            (Or 648:4-68
              (ParserVar 648:4-25 _toml.escaped_unicode)
              (Function 649:4-40
                (ParserVar 649:4-10 unless)
                ((ParserVar 649:11-15 char)
                 (Or 649:17-39
                    (ParserVar 649:17-27 _ctrl_char)
                    (Or 649:30-39
                      (String 649:30-33 "\")
                      (String 649:36-39 """)))))))))
      (Function 650:6-16 (ParserVar 650:6-11 const) ((ValueLabel 650:12-13 (String 650:13-15 ""))))))
  
  (DeclareGlobal 652:0-64
    (ParserVar 652:0-19 toml.string.literal)
    (TakeLeft 652:22-64
      (TakeRight 652:22-58
        (String 652:22-25 "'")
        (Function 652:28-58 (ParserVar 652:28-35 default) ((Function 652:36-52 (ParserVar 652:36-47 chars_until) ((String 652:48-51 "'"))) (ValueLabel 652:54-55 (String 652:55-57 "")))))
      (String 652:61-64 "'")))
  
  (DeclareGlobal 654:0-147
    (ParserVar 654:0-23 _toml.escaped_ctrl_char)
    (Or 655:2-121
      (Return 655:2-14
        (String 655:3-7 "\"")
        (String 655:10-13 """))
      (Or 656:2-104
        (Return 656:2-14
          (String 656:3-7 "\\")
          (String 656:10-13 "\"))
        (Or 657:2-87
          (Return 657:2-15
            (String 657:3-7 "\b")
            (String 657:10-14 "\x08")) (esc)
          (Or 658:2-69
            (Return 658:2-15
              (String 658:3-7 "\f")
              (String 658:10-14 "\x0c")) (esc)
            (Or 659:2-51
              (Return 659:2-15
                (String 659:3-7 "\n")
                (String 659:10-14 "
  "))
              (Or 660:2-33
                (Return 660:2-15
                  (String 660:3-7 "\r")
                  (String 660:10-14 "\r (no-eol) (esc)
  "))
                (Return 661:2-15
                  (String 661:3-7 "\t")
                  (String 661:10-14 "\t"))))))))) (esc)
  
  (DeclareGlobal 663:0-131
    (ParserVar 663:0-21 _toml.escaped_unicode)
    (Or 664:2-107
      (Return 664:2-52
        (Destructure 664:3-35
          (TakeRight 664:3-30
            (String 664:3-7 "\u")
            (Function 664:10-30 (ParserVar 664:10-17 repeat4) ((ParserVar 664:18-29 hex_numeral))))
          (ValueVar 664:34-35 U))
        (Function 664:38-51 (ValueVar 664:38-48 @Codepoint) ((ValueVar 664:49-50 U))))
      (Return 665:2-52
        (Destructure 665:3-35
          (TakeRight 665:3-30
            (String 665:3-7 "\U")
            (Function 665:10-30 (ParserVar 665:10-17 repeat8) ((ParserVar 665:18-29 hex_numeral))))
          (ValueVar 665:34-35 U))
        (Function 665:38-51 (ValueVar 665:38-48 @Codepoint) ((ValueVar 665:49-50 U))))))
  
  (DeclareGlobal 667:0-96
    (ParserVar 667:0-20 toml.datetime.offset)
    (Merge 667:23-96
      (Merge 667:23-67
        (ParserVar 667:23-47 toml.datetime.local_date)
        (Or 667:50-67
          (String 667:51-54 "T")
          (Or 667:57-66
            (String 667:57-60 "t")
            (String 667:63-66 " "))))
      (ParserVar 667:70-96 _toml.datetime.time_offset)))
  
  (DeclareGlobal 669:0-93
    (ParserVar 669:0-19 toml.datetime.local)
    (Merge 669:22-93
      (Merge 669:22-66
        (ParserVar 669:22-46 toml.datetime.local_date)
        (Or 669:49-66
          (String 669:50-53 "T")
          (Or 669:56-65
            (String 669:56-59 "t")
            (String 669:62-65 " "))))
      (ParserVar 669:69-93 toml.datetime.local_time)))
  
  (DeclareGlobal 671:0-105
    (ParserVar 671:0-24 toml.datetime.local_date)
    (Merge 672:2-78
      (Merge 672:2-56
        (Merge 672:2-50
          (Merge 672:2-27
            (ParserVar 672:2-21 _toml.datetime.year)
            (String 672:24-27 "-"))
          (ParserVar 672:30-50 _toml.datetime.month))
        (String 672:53-56 "-"))
      (ParserVar 672:59-78 _toml.datetime.mday)))
  
  (DeclareGlobal 674:0-38
    (ParserVar 674:0-19 _toml.datetime.year)
    (Function 674:22-38 (ParserVar 674:22-29 repeat4) ((ParserVar 674:30-37 numeral))))
  
  (DeclareGlobal 676:0-53
    (ParserVar 676:0-20 _toml.datetime.month)
    (Or 676:23-53
      (Merge 676:23-39
        (String 676:24-27 "0")
        (Range 676:30-38 (String 676:30-33 "1") (String 676:35-38 "9")))
      (Or 676:42-53
        (String 676:42-46 "11")
        (String 676:49-53 "12"))))
  
  (DeclareGlobal 678:0-57
    (ParserVar 678:0-19 _toml.datetime.mday)
    (Or 678:22-57
      (Merge 678:22-43
        (Range 678:23-31 (String 678:23-26 "0") (String 678:28-31 "2"))
        (Range 678:34-42 (String 678:34-37 "1") (String 678:39-42 "9")))
      (Or 678:46-57
        (String 678:46-50 "30")
        (String 678:53-57 "31"))))
  
  (DeclareGlobal 680:0-164
    (ParserVar 680:0-24 toml.datetime.local_time)
    (Merge 681:2-137
      (Merge 681:2-88
        (Merge 681:2-61
          (Merge 681:2-55
            (Merge 681:2-28
              (ParserVar 681:2-22 _toml.datetime.hours)
              (String 681:25-28 ":"))
            (ParserVar 682:2-24 _toml.datetime.minutes))
          (String 682:27-30 ":"))
        (ParserVar 683:2-24 _toml.datetime.seconds))
      (Function 684:2-46
        (ParserVar 684:2-7 maybe)
        ((Merge 684:8-45
            (String 684:8-11 ".")
            (Function 684:14-45
              (ParserVar 684:14-28 repeat_between)
              ((ParserVar 684:29-36 numeral)
               (ValueLabel 684:38-39 (NumberString 684:39-40 1))
               (ValueLabel 684:42-43 (NumberString 684:43-44 9)))))))))
  
  (DeclareGlobal 686:0-99
    (ParserVar 686:0-26 _toml.datetime.time_offset)
    (Merge 686:29-99
      (ParserVar 686:29-53 toml.datetime.local_time)
      (Or 686:56-99
        (String 686:57-60 "Z")
        (Or 686:63-98
          (String 686:63-66 "z")
          (ParserVar 686:69-98 _toml.datetime.time_numoffset)))))
  
  (DeclareGlobal 688:0-97
    (ParserVar 688:0-29 _toml.datetime.time_numoffset)
    (Merge 688:32-97
      (Merge 688:32-72
        (Merge 688:32-66
          (Or 688:32-43
            (String 688:33-36 "+")
            (String 688:39-42 "-"))
          (ParserVar 688:46-66 _toml.datetime.hours))
        (String 688:69-72 ":"))
      (ParserVar 688:75-97 _toml.datetime.minutes)))
  
  (DeclareGlobal 690:0-63
    (ParserVar 690:0-20 _toml.datetime.hours)
    (Or 690:23-63
      (Merge 690:23-44
        (Range 690:24-32 (String 690:24-27 "0") (String 690:29-32 "1"))
        (Range 690:35-43 (String 690:35-38 "0") (String 690:40-43 "9")))
      (Merge 690:47-63
        (String 690:48-51 "2")
        (Range 690:54-62 (String 690:54-57 "0") (String 690:59-62 "3")))))
  
  (DeclareGlobal 692:0-44
    (ParserVar 692:0-22 _toml.datetime.minutes)
    (Merge 692:25-44
      (Range 692:25-33 (String 692:25-28 "0") (String 692:30-33 "5"))
      (Range 692:36-44 (String 692:36-39 "0") (String 692:41-44 "9"))))
  
  (DeclareGlobal 694:0-53
    (ParserVar 694:0-22 _toml.datetime.seconds)
    (Or 694:25-53
      (Merge 694:25-46
        (Range 694:26-34 (String 694:26-29 "0") (String 694:31-34 "5"))
        (Range 694:37-45 (String 694:37-40 "0") (String 694:42-45 "9")))
      (String 694:49-53 "60")))
  
  (DeclareGlobal 696:0-84
    (ParserVar 696:0-19 toml.number.integer)
    (Function 696:22-84
      (ParserVar 696:22-31 as_number)
      ((Merge 697:2-49
          (ParserVar 697:2-19 _toml.number.sign)
          (ParserVar 698:2-27 _toml.number.integer_part)))))
  
  (DeclareGlobal 701:0-42
    (ParserVar 701:0-17 _toml.number.sign)
    (Function 701:20-42
      (ParserVar 701:20-25 maybe)
      ((Or 701:26-41
          (String 701:26-29 "-")
          (Function 701:32-41 (ParserVar 701:32-36 skip) ((String 701:37-40 "+")))))))
  
  (DeclareGlobal 703:0-79
    (ParserVar 703:0-25 _toml.number.integer_part)
    (Or 704:2-51
      (Merge 704:2-41
        (Range 704:3-11 (String 704:3-6 "1") (String 704:8-11 "9"))
        (Function 704:14-40
          (ParserVar 704:14-18 many)
          ((TakeRight 704:19-39
              (Function 704:19-29 (ParserVar 704:19-24 maybe) ((String 704:25-28 "_")))
              (ParserVar 704:32-39 numeral)))))
      (ParserVar 704:44-51 numeral)))
  
  (DeclareGlobal 706:0-192
    (ParserVar 706:0-17 toml.number.float)
    (Function 706:20-192
      (ParserVar 706:20-29 as_number)
      ((Merge 707:2-159
          (Merge 707:2-49
            (ParserVar 707:2-19 _toml.number.sign)
            (ParserVar 708:2-27 _toml.number.integer_part))
          (Or 708:30-137
            (Merge 709:4-68
              (ParserVar 709:5-31 _toml.number.fraction_part)
              (Function 709:34-67 (ParserVar 709:34-39 maybe) ((ParserVar 709:40-66 _toml.number.exponent_part))))
            (ParserVar 710:4-30 _toml.number.exponent_part))))))
  
  (DeclareGlobal 714:0-65
    (ParserVar 714:0-26 _toml.number.fraction_part)
    (Merge 714:29-65
      (String 714:29-32 ".")
      (Function 714:35-65 (ParserVar 714:35-43 many_sep) ((ParserVar 714:44-52 numerals) (Function 714:54-64 (ParserVar 714:54-59 maybe) ((String 714:60-63 "_")))))))
  
  (DeclareGlobal 716:0-94
    (ParserVar 716:0-26 _toml.number.exponent_part)
    (Merge 717:2-65
      (Merge 717:2-32
        (Or 717:2-13
          (String 717:3-6 "e")
          (String 717:9-12 "E"))
        (Function 717:16-32
          (ParserVar 717:16-21 maybe)
          ((Or 717:22-31
              (String 717:22-25 "-")
              (String 717:28-31 "+")))))
      (Function 717:35-65 (ParserVar 717:35-43 many_sep) ((ParserVar 717:44-52 numerals) (Function 717:54-64 (ParserVar 717:54-59 maybe) ((String 717:60-63 "_")))))))
  
  (DeclareGlobal 719:0-47
    (ParserVar 719:0-20 toml.number.infinity)
    (Merge 719:23-47
      (Function 719:23-39
        (ParserVar 719:23-28 maybe)
        ((Or 719:29-38
            (String 719:29-32 "+")
            (String 719:35-38 "-"))))
      (String 719:42-47 "inf")))
  
  (DeclareGlobal 721:0-51
    (ParserVar 721:0-24 toml.number.not_a_number)
    (Merge 721:27-51
      (Function 721:27-43
        (ParserVar 721:27-32 maybe)
        ((Or 721:33-42
            (String 721:33-36 "+")
            (String 721:39-42 "-"))))
      (String 721:46-51 "nan")))
  
  (DeclareGlobal 723:0-209
    (ParserVar 723:0-26 toml.number.binary_integer)
    (TakeRight 724:2-180
      (String 724:2-6 "0b")
      (Return 724:9-180
        (Destructure 724:9-147
          (Function 724:9-137
            (ParserVar 724:9-20 one_or_both)
            ((Merge 725:4-70
                (Function 725:4-28 (ParserVar 725:4-13 array_sep) ((NumberString 725:14-15 0) (Function 725:17-27 (ParserVar 725:17-22 maybe) ((String 725:23-26 "_")))))
                (Function 725:31-70
                  (ParserVar 725:31-36 maybe)
                  ((TakeLeft 725:37-69
                      (Function 725:37-46 (ParserVar 725:37-41 skip) ((String 725:42-45 "_")))
                      (Function 725:49-69 (ParserVar 725:49-53 peek) ((ParserVar 725:54-68 binary_numeral)))))))
             (Function 726:4-39 (ParserVar 726:4-13 array_sep) ((ParserVar 726:14-26 binary_digit) (Function 726:28-38 (ParserVar 726:28-33 maybe) ((String 726:34-37 "_")))))))
          (ValueVar 727:7-13 Digits))
        (Function 728:2-30 (ValueVar 728:2-22 Num.FromBinaryDigits) ((ValueVar 728:23-29 Digits))))))
  
  (DeclareGlobal 730:0-205
    (ParserVar 730:0-25 toml.number.octal_integer)
    (TakeRight 731:2-177
      (String 731:2-6 "0o")
      (Return 731:9-177
        (Destructure 731:9-145
          (Function 731:9-135
            (ParserVar 731:9-20 one_or_both)
            ((Merge 732:4-69
                (Function 732:4-28 (ParserVar 732:4-13 array_sep) ((NumberString 732:14-15 0) (Function 732:17-27 (ParserVar 732:17-22 maybe) ((String 732:23-26 "_")))))
                (Function 732:31-69
                  (ParserVar 732:31-36 maybe)
                  ((TakeLeft 732:37-68
                      (Function 732:37-46 (ParserVar 732:37-41 skip) ((String 732:42-45 "_")))
                      (Function 732:49-68 (ParserVar 732:49-53 peek) ((ParserVar 732:54-67 octal_numeral)))))))
             (Function 733:4-38 (ParserVar 733:4-13 array_sep) ((ParserVar 733:14-25 octal_digit) (Function 733:27-37 (ParserVar 733:27-32 maybe) ((String 733:33-36 "_")))))))
          (ValueVar 734:7-13 Digits))
        (Function 735:2-29 (ValueVar 735:2-21 Num.FromOctalDigits) ((ValueVar 735:22-28 Digits))))))
  
  (DeclareGlobal 737:0-197
    (ParserVar 737:0-23 toml.number.hex_integer)
    (TakeRight 738:2-171
      (String 738:2-6 "0x")
      (Return 738:9-171
        (Destructure 738:9-141
          (Function 738:9-131
            (ParserVar 738:9-20 one_or_both)
            ((Merge 739:4-67
                (Function 739:4-28 (ParserVar 739:4-13 array_sep) ((NumberString 739:14-15 0) (Function 739:17-27 (ParserVar 739:17-22 maybe) ((String 739:23-26 "_")))))
                (Function 739:31-67
                  (ParserVar 739:31-36 maybe)
                  ((TakeLeft 739:37-66
                      (Function 739:37-46 (ParserVar 739:37-41 skip) ((String 739:42-45 "_")))
                      (Function 739:49-66 (ParserVar 739:49-53 peek) ((ParserVar 739:54-65 hex_numeral)))))))
             (Function 740:4-36 (ParserVar 740:4-13 array_sep) ((ParserVar 740:14-23 hex_digit) (Function 740:25-35 (ParserVar 740:25-30 maybe) ((String 740:31-34 "_")))))))
          (ValueVar 741:7-13 Digits))
        (Function 742:2-27 (ValueVar 742:2-19 Num.FromHexDigits) ((ValueVar 742:20-26 Digits))))))
  
  (DeclareGlobal 744:0-43
    (ValueVar 744:0-15 _Toml.Doc.Empty)
    (Object 744:18-43
      ((String 744:19-26 "value") (Object 744:28-31))
      ((String 744:32-38 "type") (Object 744:40-43))))
  
  (DeclareGlobal 746:0-44
    (Function 746:0-20 (ValueVar 746:0-15 _Toml.Doc.Value) ((ValueVar 746:16-19 Doc)))
    (Function 746:23-44 (ValueVar 746:23-30 Obj.Get) ((ValueVar 746:31-34 Doc) (String 746:36-43 "value"))))
  
  (DeclareGlobal 748:0-42
    (Function 748:0-19 (ValueVar 748:0-14 _Toml.Doc.Type) ((ValueVar 748:15-18 Doc)))
    (Function 748:22-42 (ValueVar 748:22-29 Obj.Get) ((ValueVar 748:30-33 Doc) (String 748:35-41 "type"))))
  
  (DeclareGlobal 750:0-59
    (Function 750:0-23 (ValueVar 750:0-13 _Toml.Doc.Has) ((ValueVar 750:14-17 Doc) (ValueVar 750:19-22 Key)))
    (Function 750:26-59 (ValueVar 750:26-33 Obj.Has) ((Function 750:34-53 (ValueVar 750:34-48 _Toml.Doc.Type) ((ValueVar 750:49-52 Doc))) (ValueVar 750:55-58 Key))))
  
  (DeclareGlobal 752:0-121
    (Function 752:0-23 (ValueVar 752:0-13 _Toml.Doc.Get) ((ValueVar 752:14-17 Doc) (ValueVar 752:19-22 Key)))
    (Object 752:26-121
      ((String 753:2-9 "value") (Function 753:11-45 (ValueVar 753:11-18 Obj.Get) ((Function 753:19-39 (ValueVar 753:19-34 _Toml.Doc.Value) ((ValueVar 753:35-38 Doc))) (ValueVar 753:41-44 Key))))
      ((String 754:2-8 "type") (Function 754:10-43 (ValueVar 754:10-17 Obj.Get) ((Function 754:18-37 (ValueVar 754:18-32 _Toml.Doc.Type) ((ValueVar 754:33-36 Doc))) (ValueVar 754:39-42 Key))))))
  
  (DeclareGlobal 757:0-55
    (Function 757:0-22 (ValueVar 757:0-17 _Toml.Doc.IsTable) ((ValueVar 757:18-21 Doc)))
    (Function 757:25-55 (ValueVar 757:25-34 Is.Object) ((Function 757:35-54 (ValueVar 757:35-49 _Toml.Doc.Type) ((ValueVar 757:50-53 Doc))))))
  
  (DeclareGlobal 759:0-181
    (Function 759:0-37
      (ValueVar 759:0-16 _Toml.Doc.Insert)
      ((ValueVar 759:17-20 Doc)
       (ValueVar 759:22-25 Key)
       (ValueVar 759:27-30 Val)
       (ValueVar 759:32-36 Type)))
    (TakeRight 760:2-141
      (Function 760:2-24 (ValueVar 760:2-19 _Toml.Doc.IsTable) ((ValueVar 760:20-23 Doc)))
      (Object 761:2-114
        ((String 762:4-11 "value") (Function 762:13-52
            (ValueVar 762:13-20 Obj.Put)
            ((Function 762:21-41 (ValueVar 762:21-36 _Toml.Doc.Value) ((ValueVar 762:37-40 Doc)))
             (ValueVar 762:43-46 Key)
             (ValueVar 762:48-51 Val))))
        ((String 763:4-10 "type") (Function 763:12-51
            (ValueVar 763:12-19 Obj.Put)
            ((Function 763:20-39 (ValueVar 763:20-34 _Toml.Doc.Type) ((ValueVar 763:35-38 Doc)))
             (ValueVar 763:41-44 Key)
             (ValueVar 763:46-50 Type)))))))
  
  (DeclareGlobal 766:0-184
    (Function 766:0-46
      (ValueVar 766:0-31 _Toml.Doc.AppendToArrayOfTables)
      ((ValueVar 766:32-35 Doc)
       (ValueVar 766:37-40 Key)
       (ValueVar 766:42-45 Val)))
    (TakeRight 767:2-135
      (Destructure 767:2-70
        (Function 767:2-25 (ValueVar 767:2-15 _Toml.Doc.Get) ((ValueVar 767:16-19 Doc) (ValueVar 767:21-24 Key)))
        (Object 767:29-70
          ((String 767:30-37 "value") (ValueVar 767:39-42 AoT))
          ((String 767:44-50 "type") (String 767:52-69 "array_of_tables"))))
      (Function 768:2-62
        (ValueVar 768:2-18 _Toml.Doc.Insert)
        ((ValueVar 768:19-22 Doc)
         (ValueVar 768:24-27 Key)
         (Merge 768:29-42
            (Merge 768:29-30
              (Array 768:29-30 ())
              (ValueVar 768:33-36 AoT))
            (Array 768:38-42 ((ValueVar 768:38-41 Val))))
         (String 768:44-61 "array_of_tables")))))
  
  (DeclareGlobal 770:0-105
    (Function 770:0-38
      (ValueVar 770:0-22 _Toml.Doc.InsertAtPath)
      ((ValueVar 770:23-26 Doc)
       (ValueVar 770:28-32 Path)
       (ValueVar 770:34-37 Val)))
    (Function 771:2-64
      (ValueVar 771:2-24 _Toml.Doc.UpdateAtPath)
      ((ValueVar 771:25-28 Doc)
       (ValueVar 771:30-34 Path)
       (ValueVar 771:36-39 Val)
       (ValueVar 771:41-63 _Toml.Doc.ValueUpdater))))
  
  (DeclareGlobal 773:0-111
    (Function 773:0-38 (ValueVar 773:0-27 _Toml.Doc.EnsureTableAtPath) ((ValueVar 773:28-31 Doc) (ValueVar 773:33-37 Path)))
    (Function 774:2-70
      (ValueVar 774:2-24 _Toml.Doc.UpdateAtPath)
      ((ValueVar 774:25-28 Doc)
       (ValueVar 774:30-34 Path)
       (Object 774:36-39)
       (ValueVar 774:40-69 _Toml.Doc.MissingTableUpdater))))
  
  (DeclareGlobal 776:0-106
    (Function 776:0-38
      (ValueVar 776:0-22 _Toml.Doc.AppendAtPath)
      ((ValueVar 776:23-26 Doc)
       (ValueVar 776:28-32 Path)
       (ValueVar 776:34-37 Val)))
    (Function 777:2-65
      (ValueVar 777:2-24 _Toml.Doc.UpdateAtPath)
      ((ValueVar 777:25-28 Doc)
       (ValueVar 777:30-34 Path)
       (ValueVar 777:36-39 Val)
       (ValueVar 777:41-64 _Toml.Doc.AppendUpdater))))
  
  (DeclareGlobal 779:0-494
    (Function 779:0-47
      (ValueVar 779:0-22 _Toml.Doc.UpdateAtPath)
      ((ValueVar 779:23-26 Doc)
       (ValueVar 779:28-32 Path)
       (ValueVar 779:34-37 Val)
       (ValueVar 779:39-46 Updater)))
    (Conditional 780:2-444
      (condition (Destructure 780:2-15
          (ValueVar 780:2-6 Path)
          (Array 780:10-15 ((ValueVar 780:11-14 Key)))))
      (then (Function 780:18-40
          (ValueVar 780:18-25 Updater)
          ((ValueVar 780:26-29 Doc)
           (ValueVar 780:31-34 Key)
           (ValueVar 780:36-39 Val))))
      (else (Conditional 781:2-401
          (condition (Destructure 781:2-28
              (ValueVar 781:2-6 Path)
              (Merge 781:10-28
                (Array 781:10-11 ((ValueVar 781:11-14 Key)))
                (ValueVar 781:19-27 PathRest))))
          (then (TakeRight 781:31-393
              (Destructure 782:4-270
                (Conditional 782:4-258
                  (condition (Function 783:6-29 (ValueVar 783:6-19 _Toml.Doc.Has) ((ValueVar 783:20-23 Doc) (ValueVar 783:25-28 Key))))
                  (then (TakeRight 783:32-174
                      (Function 784:8-50 (ValueVar 784:8-25 _Toml.Doc.IsTable) ((Function 784:26-49 (ValueVar 784:26-39 _Toml.Doc.Get) ((ValueVar 784:40-43 Doc) (ValueVar 784:45-48 Key)))))
                      (Function 785:8-79
                        (ValueVar 785:8-30 _Toml.Doc.UpdateAtPath)
                        ((Function 785:31-54 (ValueVar 785:31-44 _Toml.Doc.Get) ((ValueVar 785:45-48 Doc) (ValueVar 785:50-53 Key)))
                         (ValueVar 785:56-64 PathRest)
                         (ValueVar 785:66-69 Val)
                         (ValueVar 785:71-78 Updater)))))
                  (else (Function 787:6-69
                      (ValueVar 787:6-28 _Toml.Doc.UpdateAtPath)
                      ((ValueVar 787:29-44 _Toml.Doc.Empty)
                       (ValueVar 787:46-54 PathRest)
                       (ValueVar 787:56-59 Val)
                       (ValueVar 787:61-68 Updater)))))
                (ValueVar 788:9-17 InnerDoc))
              (Function 789:4-83
                (ValueVar 789:4-20 _Toml.Doc.Insert)
                ((ValueVar 789:21-24 Doc)
                 (ValueVar 789:26-29 Key)
                 (Function 789:31-56 (ValueVar 789:31-46 _Toml.Doc.Value) ((ValueVar 789:47-55 InnerDoc)))
                 (Function 789:58-82 (ValueVar 789:58-72 _Toml.Doc.Type) ((ValueVar 789:73-81 InnerDoc)))))))
          (else (ValueVar 791:2-5 Doc))))))
  
  (DeclareGlobal 793:0-116
    (Function 793:0-37
      (ValueVar 793:0-22 _Toml.Doc.ValueUpdater)
      ((ValueVar 793:23-26 Doc)
       (ValueVar 793:28-31 Key)
       (ValueVar 793:33-36 Val)))
    (Conditional 794:2-76
      (condition (Function 794:2-25 (ValueVar 794:2-15 _Toml.Doc.Has) ((ValueVar 794:16-19 Doc) (ValueVar 794:21-24 Key))))
      (then (ValueVar 794:28-33 @Fail))
      (else (Function 794:36-76
          (ValueVar 794:36-52 _Toml.Doc.Insert)
          ((ValueVar 794:53-56 Doc)
           (ValueVar 794:58-61 Key)
           (ValueVar 794:63-66 Val)
           (String 794:68-75 "value"))))))
  
  (DeclareGlobal 796:0-137
    (Function 796:0-45
      (ValueVar 796:0-29 _Toml.Doc.MissingTableUpdater)
      ((ValueVar 796:30-33 Doc)
       (ValueVar 796:35-38 Key)
       (ValueVar 796:40-44 _Val)))
    (Conditional 797:2-89
      (condition (Function 797:2-44 (ValueVar 797:2-19 _Toml.Doc.IsTable) ((Function 797:20-43 (ValueVar 797:20-33 _Toml.Doc.Get) ((ValueVar 797:34-37 Doc) (ValueVar 797:39-42 Key))))))
      (then (ValueVar 797:47-50 Doc))
      (else (Function 798:2-36
          (ValueVar 798:2-18 _Toml.Doc.Insert)
          ((ValueVar 798:19-22 Doc)
           (ValueVar 798:24-27 Key)
           (Object 798:29-32)
           (Object 798:33-36))))))
  
  (DeclareGlobal 800:0-210
    (Function 800:0-38
      (ValueVar 800:0-23 _Toml.Doc.AppendUpdater)
      ((ValueVar 800:24-27 Doc)
       (ValueVar 800:29-32 Key)
       (ValueVar 800:34-37 Val)))
    (TakeRight 801:2-169
      (Destructure 801:2-111
        (Conditional 801:2-97
          (condition (Function 802:4-27 (ValueVar 802:4-17 _Toml.Doc.Has) ((ValueVar 802:18-21 Doc) (ValueVar 802:23-26 Key))))
          (then (ValueVar 802:30-33 Doc))
          (else (Function 803:4-53
              (ValueVar 803:4-20 _Toml.Doc.Insert)
              ((ValueVar 803:21-24 Doc)
               (ValueVar 803:26-29 Key)
               (Array 803:31-34 ())
               (String 803:35-52 "array_of_tables")))))
        (ValueVar 804:7-17 DocWithKey))
      (Function 805:2-55
        (ValueVar 805:2-33 _Toml.Doc.AppendToArrayOfTables)
        ((ValueVar 805:34-44 DocWithKey)
         (ValueVar 805:46-49 Key)
         (ValueVar 805:51-54 Val)))))
  
  (DeclareGlobal 810:0-129
    (Function 810:0-61
      (ParserVar 810:0-28 ast.with_operator_precedence)
      ((ParserVar 810:29-36 operand)
       (ParserVar 810:38-44 prefix)
       (ParserVar 810:46-51 infix)
       (ParserVar 810:53-60 postfix)))
    (Function 811:2-65
      (ParserVar 811:2-28 _ast.with_precedence_start)
      ((ParserVar 811:29-36 operand)
       (ParserVar 811:38-44 prefix)
       (ParserVar 811:46-51 infix)
       (ParserVar 811:53-60 postfix)
       (ValueLabel 811:62-63 (NumberString 811:63-64 0)))))
  
  (DeclareGlobal 813:0-509
    (Function 813:0-77
      (ParserVar 813:0-26 _ast.with_precedence_start)
      ((ParserVar 813:27-34 operand)
       (ParserVar 813:36-42 prefix)
       (ParserVar 813:44-49 infix)
       (ParserVar 813:51-58 postfix)
       (ValueVar 813:60-76 LeftBindingPower)))
    (Conditional 814:2-429
      (condition (Destructure 814:2-40
          (ParserVar 814:2-8 prefix)
          (Array 814:12-40 ((ValueVar 814:13-19 OpNode) (ValueVar 814:21-39 PrefixBindingPower)))))
      (then (TakeRight 814:43-312
          (Destructure 815:4-117
            (Function 815:4-101
              (ParserVar 815:4-30 _ast.with_precedence_start)
              ((ParserVar 816:6-13 operand)
               (ParserVar 816:15-21 prefix)
               (ParserVar 816:23-28 infix)
               (ParserVar 816:30-37 postfix)
               (ValueVar 817:6-24 PrefixBindingPower)))
            (ValueVar 818:9-21 PrefixedNode))
          (Function 819:4-143
            (ParserVar 819:4-29 _ast.with_precedence_rest)
            ((ParserVar 820:6-13 operand)
             (ParserVar 820:15-21 prefix)
             (ParserVar 820:23-28 infix)
             (ParserVar 820:30-37 postfix)
             (ValueVar 821:6-22 LeftBindingPower)
             (Merge 822:6-43
                (Merge 822:6-7
                  (Object 822:6-7)
                  (ValueVar 822:10-16 OpNode))
                (Object 822:18-43
                  ((String 822:18-28 "prefixed") (ValueVar 822:30-42 PrefixedNode))))))))
      (else (TakeRight 824:6-120
          (Destructure 825:4-19
            (ParserVar 825:4-11 operand)
            (ValueVar 825:15-19 Node))
          (Function 826:4-86
            (ParserVar 826:4-29 _ast.with_precedence_rest)
            ((ParserVar 826:30-37 operand)
             (ParserVar 826:39-45 prefix)
             (ParserVar 826:47-52 infix)
             (ParserVar 826:54-61 postfix)
             (ValueVar 826:63-79 LeftBindingPower)
             (ValueVar 826:81-85 Node)))))))
  
  (DeclareGlobal 829:0-748
    (Function 829:0-82
      (ParserVar 829:0-25 _ast.with_precedence_rest)
      ((ParserVar 829:26-33 operand)
       (ParserVar 829:35-41 prefix)
       (ParserVar 829:43-48 infix)
       (ParserVar 829:50-57 postfix)
       (ValueVar 829:59-75 LeftBindingPower)
       (ValueVar 829:77-81 Node)))
    (Conditional 830:2-663
      (condition (TakeRight 830:2-100
          (Destructure 830:2-40
            (ParserVar 830:2-9 postfix)
            (Array 830:13-40 ((ValueVar 830:14-20 OpNode) (ValueVar 830:22-39 RightBindingPower))))
          (Function 831:2-57 (ParserVar 831:2-7 const) ((Function 831:8-56 (ValueVar 831:8-19 Is.LessThan) ((ValueVar 831:20-36 LeftBindingPower) (ValueVar 831:38-55 RightBindingPower)))))))
      (then (Function 831:60-202
          (ParserVar 832:4-29 _ast.with_precedence_rest)
          ((ParserVar 833:6-13 operand)
           (ParserVar 833:15-21 prefix)
           (ParserVar 833:23-28 infix)
           (ParserVar 833:30-37 postfix)
           (ValueVar 834:6-22 LeftBindingPower)
           (Merge 835:6-36
              (Merge 835:6-7
                (Object 835:6-7)
                (ValueVar 835:10-16 OpNode))
              (Object 835:18-36
                ((String 835:18-29 "postfixed") (ValueVar 835:31-35 Node)))))))
      (else (Conditional 838:2-415
          (condition (TakeRight 838:2-120
              (Destructure 838:2-60
                (ParserVar 838:2-7 infix)
                (Array 838:11-60 ((ValueVar 838:12-18 OpNode) (ValueVar 838:20-37 RightBindingPower) (ValueVar 838:39-59 NextLeftBindingPower))))
              (Function 839:2-57 (ParserVar 839:2-7 const) ((Function 839:8-56 (ValueVar 839:8-19 Is.LessThan) ((ValueVar 839:20-36 LeftBindingPower) (ValueVar 839:38-55 RightBindingPower)))))))
          (then (TakeRight 839:60-336
              (Destructure 840:4-116
                (Function 840:4-103
                  (ParserVar 840:4-30 _ast.with_precedence_start)
                  ((ParserVar 841:6-13 operand)
                   (ParserVar 841:15-21 prefix)
                   (ParserVar 841:23-28 infix)
                   (ParserVar 841:30-37 postfix)
                   (ValueVar 842:6-26 NextLeftBindingPower)))
                (ValueVar 843:9-18 RightNode))
              (Function 844:4-151
                (ParserVar 844:4-29 _ast.with_precedence_rest)
                ((ParserVar 845:6-13 operand)
                 (ParserVar 845:15-21 prefix)
                 (ParserVar 845:23-28 infix)
                 (ParserVar 845:30-37 postfix)
                 (ValueVar 846:6-22 LeftBindingPower)
                 (Merge 847:6-51
                    (Merge 847:6-7
                      (Object 847:6-7)
                      (ValueVar 847:10-16 OpNode))
                    (Object 847:18-51
                      ((String 847:18-24 "left") (ValueVar 847:26-30 Node))
                      ((String 847:32-39 "right") (ValueVar 847:41-50 RightNode))))))))
          (else (Function 850:2-13 (ParserVar 850:2-7 const) ((ValueVar 850:8-12 Node))))))))
  
  (DeclareGlobal 852:0-73
    (Function 852:0-21 (ParserVar 852:0-8 ast.node) ((ValueVar 852:9-13 Type) (ParserVar 852:15-20 value)))
    (Return 853:2-49
      (Destructure 853:2-16
        (ParserVar 853:2-7 value)
        (ValueVar 853:11-16 Value))
      (Object 853:19-49
        ((String 853:20-26 "type") (ValueVar 853:28-32 Type))
        ((String 853:34-41 "value") (ValueVar 853:43-48 Value)))))
  
  (DeclareGlobal 859:0-14
    (ValueVar 859:0-7 Num.Add)
    (ValueVar 859:10-14 @Add))
  
  (DeclareGlobal 861:0-19
    (ValueVar 861:0-7 Num.Sub)
    (ValueVar 861:10-19 @Subtract))
  
  (DeclareGlobal 863:0-19
    (ValueVar 863:0-7 Num.Mul)
    (ValueVar 863:10-19 @Multiply))
  
  (DeclareGlobal 865:0-17
    (ValueVar 865:0-7 Num.Div)
    (ValueVar 865:10-17 @Divide))
  
  (DeclareGlobal 867:0-16
    (ValueVar 867:0-7 Num.Pow)
    (ValueVar 867:10-16 @Power))
  
  (DeclareGlobal 869:0-23
    (Function 869:0-10 (ValueVar 869:0-7 Num.Inc) ((ValueVar 869:8-9 N)))
    (Function 869:13-23 (ValueVar 869:13-17 @Add) ((ValueVar 869:18-19 N) (NumberString 869:21-22 1))))
  
  (DeclareGlobal 871:0-28
    (Function 871:0-10 (ValueVar 871:0-7 Num.Dec) ((ValueVar 871:8-9 N)))
    (Function 871:13-28 (ValueVar 871:13-22 @Subtract) ((ValueVar 871:23-24 N) (NumberString 871:26-27 1))))
  
  (DeclareGlobal 873:0-26
    (Function 873:0-10 (ValueVar 873:0-7 Num.Abs) ((ValueVar 873:8-9 N)))
    (Or 873:13-26
      (Destructure 873:13-21
        (ValueVar 873:13-14 N)
        (Range 873:18-21 (NumberString 873:18-19 0) ()))
      (Negation 873:24-26 (ValueVar 873:25-26 N))))
  
  (DeclareGlobal 875:0-32
    (Function 875:0-13 (ValueVar 875:0-7 Num.Max) ((ValueVar 875:8-9 A) (ValueVar 875:11-12 B)))
    (Conditional 875:16-32
      (condition (Destructure 875:16-24
          (ValueVar 875:16-17 A)
          (Range 875:21-24 (ValueVar 875:21-22 B) ())))
      (then (ValueVar 875:27-28 A))
      (else (ValueVar 875:31-32 B))))
  
  (DeclareGlobal 877:0-94
    (Function 877:0-24 (ValueVar 877:0-20 Num.FromBinaryDigits) ((ValueVar 877:21-23 Bs)))
    (TakeRight 878:2-67
      (Destructure 878:2-25
        (Function 878:2-18 (ValueVar 878:2-14 Array.Length) ((ValueVar 878:15-17 Bs)))
        (ValueVar 878:22-25 Len))
      (Function 879:2-39
        (ValueVar 879:2-23 _Num.FromBinaryDigits)
        ((ValueVar 879:24-26 Bs)
         (Merge 879:28-35
            (ValueVar 879:28-31 Len)
            (Negation 879:34-35 (NumberString 879:34-35 1)))
         (NumberString 879:37-38 0)))))
  
  (DeclareGlobal 881:0-191
    (Function 881:0-35
      (ValueVar 881:0-21 _Num.FromBinaryDigits)
      ((ValueVar 881:22-24 Bs)
       (ValueVar 881:26-29 Pos)
       (ValueVar 881:31-34 Acc)))
    (Conditional 882:2-153
      (condition (Destructure 882:2-20
          (ValueVar 882:2-4 Bs)
          (Merge 882:8-20
            (Array 882:8-9 ((ValueVar 882:9-10 B)))
            (ValueVar 882:15-19 Rest))))
      (then (TakeRight 882:23-145
          (Destructure 883:4-13
            (ValueVar 883:4-5 B)
            (Range 883:9-13 (NumberString 883:9-10 0) (NumberString 883:12-13 1)))
          (Function 884:4-100
            (ValueVar 884:4-25 _Num.FromBinaryDigits)
            ((ValueVar 885:6-10 Rest)
             (Merge 886:6-13
                (ValueVar 886:6-9 Pos)
                (Negation 886:12-13 (NumberString 886:12-13 1)))
             (Merge 887:6-39
                (ValueVar 887:6-9 Acc)
                (Function 887:12-39 (ValueVar 887:12-19 Num.Mul) ((ValueVar 887:20-21 B) (Function 887:23-38 (ValueVar 887:23-30 Num.Pow) ((NumberString 887:31-32 2) (ValueVar 887:34-37 Pos))))))))))
      (else (ValueVar 890:2-5 Acc))))
  
  (DeclareGlobal 892:0-92
    (Function 892:0-23 (ValueVar 892:0-19 Num.FromOctalDigits) ((ValueVar 892:20-22 Os)))
    (TakeRight 893:2-66
      (Destructure 893:2-25
        (Function 893:2-18 (ValueVar 893:2-14 Array.Length) ((ValueVar 893:15-17 Os)))
        (ValueVar 893:22-25 Len))
      (Function 894:2-38
        (ValueVar 894:2-22 _Num.FromOctalDigits)
        ((ValueVar 894:23-25 Os)
         (Merge 894:27-34
            (ValueVar 894:27-30 Len)
            (Negation 894:33-34 (NumberString 894:33-34 1)))
         (NumberString 894:36-37 0)))))
  
  (DeclareGlobal 896:0-189
    (Function 896:0-34
      (ValueVar 896:0-20 _Num.FromOctalDigits)
      ((ValueVar 896:21-23 Os)
       (ValueVar 896:25-28 Pos)
       (ValueVar 896:30-33 Acc)))
    (Conditional 897:2-152
      (condition (Destructure 897:2-20
          (ValueVar 897:2-4 Os)
          (Merge 897:8-20
            (Array 897:8-9 ((ValueVar 897:9-10 O)))
            (ValueVar 897:15-19 Rest))))
      (then (TakeRight 897:23-144
          (Destructure 898:4-13
            (ValueVar 898:4-5 O)
            (Range 898:9-13 (NumberString 898:9-10 0) (NumberString 898:12-13 7)))
          (Function 899:4-99
            (ValueVar 899:4-24 _Num.FromOctalDigits)
            ((ValueVar 900:6-10 Rest)
             (Merge 901:6-13
                (ValueVar 901:6-9 Pos)
                (Negation 901:12-13 (NumberString 901:12-13 1)))
             (Merge 902:6-39
                (ValueVar 902:6-9 Acc)
                (Function 902:12-39 (ValueVar 902:12-19 Num.Mul) ((ValueVar 902:20-21 O) (Function 902:23-38 (ValueVar 902:23-30 Num.Pow) ((NumberString 902:31-32 8) (ValueVar 902:34-37 Pos))))))))))
      (else (ValueVar 905:2-5 Acc))))
  
  (DeclareGlobal 907:0-88
    (Function 907:0-21 (ValueVar 907:0-17 Num.FromHexDigits) ((ValueVar 907:18-20 Hs)))
    (TakeRight 908:2-64
      (Destructure 908:2-25
        (Function 908:2-18 (ValueVar 908:2-14 Array.Length) ((ValueVar 908:15-17 Hs)))
        (ValueVar 908:22-25 Len))
      (Function 909:2-36
        (ValueVar 909:2-20 _Num.FromHexDigits)
        ((ValueVar 909:21-23 Hs)
         (Merge 909:25-32
            (ValueVar 909:25-28 Len)
            (Negation 909:31-32 (NumberString 909:31-32 1)))
         (NumberString 909:34-35 0)))))
  
  (DeclareGlobal 911:0-187
    (Function 911:0-32
      (ValueVar 911:0-18 _Num.FromHexDigits)
      ((ValueVar 911:19-21 Hs)
       (ValueVar 911:23-26 Pos)
       (ValueVar 911:28-31 Acc)))
    (Conditional 912:2-152
      (condition (Destructure 912:2-20
          (ValueVar 912:2-4 Hs)
          (Merge 912:8-20
            (Array 912:8-9 ((ValueVar 912:9-10 H)))
            (ValueVar 912:15-19 Rest))))
      (then (TakeRight 912:23-144
          (Destructure 913:4-14
            (ValueVar 913:4-5 H)
            (Range 913:9-14 (NumberString 913:9-10 0) (NumberString 913:12-14 15)))
          (Function 914:4-98
            (ValueVar 914:4-22 _Num.FromHexDigits)
            ((ValueVar 915:6-10 Rest)
             (Merge 916:6-13
                (ValueVar 916:6-9 Pos)
                (Negation 916:12-13 (NumberString 916:12-13 1)))
             (Merge 917:6-40
                (ValueVar 917:6-9 Acc)
                (Function 917:12-40 (ValueVar 917:12-19 Num.Mul) ((ValueVar 917:20-21 H) (Function 917:23-39 (ValueVar 917:23-30 Num.Pow) ((NumberString 917:31-33 16) (ValueVar 917:35-38 Pos))))))))))
      (else (ValueVar 920:2-5 Acc))))
  
  (DeclareGlobal 924:0-43
    (Function 924:0-18 (ValueVar 924:0-11 Array.First) ((ValueVar 924:12-17 Array)))
    (TakeRight 924:21-43
      (Destructure 924:21-39
        (ValueVar 924:21-26 Array)
        (Merge 924:30-39
          (Array 924:30-31 ((ValueVar 924:31-32 F)))
          (ValueVar 924:37-38 _)))
      (ValueVar 924:42-43 F)))
  
  (DeclareGlobal 926:0-42
    (Function 926:0-17 (ValueVar 926:0-10 Array.Rest) ((ValueVar 926:11-16 Array)))
    (TakeRight 926:20-42
      (Destructure 926:20-38
        (ValueVar 926:20-25 Array)
        (Merge 926:29-38
          (Array 926:29-30 ((ValueVar 926:30-31 _)))
          (ValueVar 926:36-37 R)))
      (ValueVar 926:41-42 R)))
  
  (DeclareGlobal 928:0-37
    (Function 928:0-15 (ValueVar 928:0-12 Array.Length) ((ValueVar 928:13-14 A)))
    (Function 928:18-37 (ValueVar 928:18-31 _Array.Length) ((ValueVar 928:32-33 A) (NumberString 928:35-36 0))))
  
  (DeclareGlobal 930:0-84
    (Function 930:0-21 (ValueVar 930:0-13 _Array.Length) ((ValueVar 930:14-15 A) (ValueVar 930:17-20 Acc)))
    (Conditional 931:2-60
      (condition (Destructure 931:2-19
          (ValueVar 931:2-3 A)
          (Merge 931:7-19
            (Array 931:7-8 ((ValueVar 931:8-9 _)))
            (ValueVar 931:14-18 Rest))))
      (then (Function 932:2-30
          (ValueVar 932:2-15 _Array.Length)
          ((ValueVar 932:16-20 Rest)
           (Merge 932:22-29
              (ValueVar 932:22-25 Acc)
              (NumberString 932:28-29 1)))))
      (else (ValueVar 933:2-5 Acc))))
  
  (DeclareGlobal 935:0-40
    (Function 935:0-16 (ValueVar 935:0-13 Array.Reverse) ((ValueVar 935:14-15 A)))
    (Function 935:19-40 (ValueVar 935:19-33 _Array.Reverse) ((ValueVar 935:34-35 A) (Array 935:37-40 ()))))
  
  (DeclareGlobal 937:0-98
    (Function 937:0-22 (ValueVar 937:0-14 _Array.Reverse) ((ValueVar 937:15-16 A) (ValueVar 937:18-21 Acc)))
    (Conditional 938:2-73
      (condition (Destructure 938:2-23
          (ValueVar 938:2-3 A)
          (Merge 938:7-23
            (Array 938:7-8 ((ValueVar 938:8-13 First)))
            (ValueVar 938:18-22 Rest))))
      (then (Function 939:2-39
          (ValueVar 939:2-16 _Array.Reverse)
          ((ValueVar 939:17-21 Rest)
           (Merge 939:23-38
              (Array 939:23-24 ((ValueVar 939:24-29 First)))
              (ValueVar 939:34-37 Acc)))))
      (else (ValueVar 940:2-5 Acc))))
  
  (DeclareGlobal 942:0-40
    (Function 942:0-16 (ValueVar 942:0-9 Array.Map) ((ValueVar 942:10-11 A) (ValueVar 942:13-15 Fn)))
    (Function 942:19-40
      (ValueVar 942:19-29 _Array.Map)
      ((ValueVar 942:30-31 A)
       (ValueVar 942:33-35 Fn)
       (Array 942:37-40 ()))))
  
  (DeclareGlobal 944:0-102
    (Function 944:0-22
      (ValueVar 944:0-10 _Array.Map)
      ((ValueVar 944:11-12 A)
       (ValueVar 944:14-16 Fn)
       (ValueVar 944:18-21 Acc)))
    (Conditional 945:2-77
      (condition (Destructure 945:2-23
          (ValueVar 945:2-3 A)
          (Merge 945:7-23
            (Array 945:7-8 ((ValueVar 945:8-13 First)))
            (ValueVar 945:18-22 Rest))))
      (then (Function 946:2-43
          (ValueVar 946:2-12 _Array.Map)
          ((ValueVar 946:13-17 Rest)
           (ValueVar 946:19-21 Fn)
           (Merge 946:23-42
              (Merge 946:23-24
                (Array 946:23-24 ())
                (ValueVar 946:27-30 Acc))
              (Array 946:32-42 ((Function 946:32-41 (ValueVar 946:32-34 Fn) ((ValueVar 946:35-40 First)))))))))
      (else (ValueVar 947:2-5 Acc))))
  
  (DeclareGlobal 949:0-50
    (Function 949:0-21 (ValueVar 949:0-12 Array.Filter) ((ValueVar 949:13-14 A) (ValueVar 949:16-20 Pred)))
    (Function 949:24-50
      (ValueVar 949:24-37 _Array.Filter)
      ((ValueVar 949:38-39 A)
       (ValueVar 949:41-45 Pred)
       (Array 949:47-50 ()))))
  
  (DeclareGlobal 951:0-128
    (Function 951:0-27
      (ValueVar 951:0-13 _Array.Filter)
      ((ValueVar 951:14-15 A)
       (ValueVar 951:17-21 Pred)
       (ValueVar 951:23-26 Acc)))
    (Conditional 952:2-98
      (condition (Destructure 952:2-23
          (ValueVar 952:2-3 A)
          (Merge 952:7-23
            (Array 952:7-8 ((ValueVar 952:8-13 First)))
            (ValueVar 952:18-22 Rest))))
      (then (Function 953:2-64
          (ValueVar 953:2-15 _Array.Filter)
          ((ValueVar 953:16-20 Rest)
           (ValueVar 953:22-26 Pred)
           (Conditional 953:28-63
              (condition (Function 953:28-39 (ValueVar 953:28-32 Pred) ((ValueVar 953:33-38 First))))
              (then (Merge 953:42-57
                  (Merge 953:42-43
                    (Array 953:42-43 ())
                    (ValueVar 953:46-49 Acc))
                  (Array 953:51-57 ((ValueVar 953:51-56 First)))))
              (else (ValueVar 953:60-63 Acc))))))
      (else (ValueVar 954:2-5 Acc))))
  
  (DeclareGlobal 956:0-50
    (Function 956:0-21 (ValueVar 956:0-12 Array.Reject) ((ValueVar 956:13-14 A) (ValueVar 956:16-20 Pred)))
    (Function 956:24-50
      (ValueVar 956:24-37 _Array.Reject)
      ((ValueVar 956:38-39 A)
       (ValueVar 956:41-45 Pred)
       (Array 956:47-50 ()))))
  
  (DeclareGlobal 958:0-128
    (Function 958:0-27
      (ValueVar 958:0-13 _Array.Reject)
      ((ValueVar 958:14-15 A)
       (ValueVar 958:17-21 Pred)
       (ValueVar 958:23-26 Acc)))
    (Conditional 959:2-98
      (condition (Destructure 959:2-23
          (ValueVar 959:2-3 A)
          (Merge 959:7-23
            (Array 959:7-8 ((ValueVar 959:8-13 First)))
            (ValueVar 959:18-22 Rest))))
      (then (Function 960:2-64
          (ValueVar 960:2-15 _Array.Reject)
          ((ValueVar 960:16-20 Rest)
           (ValueVar 960:22-26 Pred)
           (Conditional 960:28-63
              (condition (Function 960:28-39 (ValueVar 960:28-32 Pred) ((ValueVar 960:33-38 First))))
              (then (ValueVar 960:42-45 Acc))
              (else (Merge 960:48-63
                  (Merge 960:48-49
                    (Array 960:48-49 ())
                    (ValueVar 960:52-55 Acc))
                  (Array 960:57-63 ((ValueVar 960:57-62 First)))))))))
      (else (ValueVar 961:2-5 Acc))))
  
  (DeclareGlobal 963:0-54
    (Function 963:0-23 (ValueVar 963:0-15 Array.ZipObject) ((ValueVar 963:16-18 Ks) (ValueVar 963:20-22 Vs)))
    (Function 963:26-54
      (ValueVar 963:26-42 _Array.ZipObject)
      ((ValueVar 963:43-45 Ks)
       (ValueVar 963:47-49 Vs)
       (Object 963:51-54))))
  
  (DeclareGlobal 965:0-138
    (Function 965:0-29
      (ValueVar 965:0-16 _Array.ZipObject)
      ((ValueVar 965:17-19 Ks)
       (ValueVar 965:21-23 Vs)
       (ValueVar 965:25-28 Acc)))
    (Conditional 966:2-106
      (condition (TakeRight 966:2-45
          (Destructure 966:2-22
            (ValueVar 966:2-4 Ks)
            (Merge 966:8-22
              (Array 966:8-9 ((ValueVar 966:9-10 K)))
              (ValueVar 966:15-21 KsRest)))
          (Destructure 966:25-45
            (ValueVar 966:25-27 Vs)
            (Merge 966:31-45
              (Array 966:31-32 ((ValueVar 966:32-33 V)))
              (ValueVar 966:38-44 VsRest)))))
      (then (Function 967:2-50
          (ValueVar 967:2-18 _Array.ZipObject)
          ((ValueVar 967:19-25 KsRest)
           (ValueVar 967:27-33 VsRest)
           (Merge 967:35-49
              (Merge 967:35-36
                (Object 967:35-36)
                (ValueVar 967:39-42 Acc))
              (Object 967:44-49
                ((ValueVar 967:44-45 K) (ValueVar 967:47-48 V)))))))
      (else (ValueVar 968:2-5 Acc))))
  
  (DeclareGlobal 970:0-52
    (Function 970:0-22 (ValueVar 970:0-14 Array.ZipPairs) ((ValueVar 970:15-17 A1) (ValueVar 970:19-21 A2)))
    (Function 970:25-52
      (ValueVar 970:25-40 _Array.ZipPairs)
      ((ValueVar 970:41-43 A1)
       (ValueVar 970:45-47 A2)
       (Array 970:49-52 ()))))
  
  (DeclareGlobal 972:0-154
    (Function 972:0-28
      (ValueVar 972:0-15 _Array.ZipPairs)
      ((ValueVar 972:16-18 A1)
       (ValueVar 972:20-22 A2)
       (ValueVar 972:24-27 Acc)))
    (Conditional 973:2-123
      (condition (TakeRight 973:2-53
          (Destructure 973:2-26
            (ValueVar 973:2-4 A1)
            (Merge 973:8-26
              (Array 973:8-9 ((ValueVar 973:9-15 First1)))
              (ValueVar 973:20-25 Rest1)))
          (Destructure 973:29-53
            (ValueVar 973:29-31 A2)
            (Merge 973:35-53
              (Array 973:35-36 ((ValueVar 973:36-42 First2)))
              (ValueVar 973:47-52 Rest2)))))
      (then (Function 974:2-59
          (ValueVar 974:2-17 _Array.ZipPairs)
          ((ValueVar 974:18-23 Rest1)
           (ValueVar 974:25-30 Rest2)
           (Merge 974:32-58
              (Merge 974:32-33
                (Array 974:32-33 ())
                (ValueVar 974:36-39 Acc))
              (Array 974:41-58 ((Array 974:41-57 ((ValueVar 974:42-48 First1) (ValueVar 974:50-56 First2)))))))))
      (else (ValueVar 975:2-5 Acc))))
  
  (DeclareGlobal 977:0-114
    (Function 977:0-24
      (ValueVar 977:0-13 Array.AppendN)
      ((ValueVar 977:14-15 A)
       (ValueVar 977:17-20 Val)
       (ValueVar 977:22-23 N)))
    (Conditional 978:2-87
      (condition (TakeRight 978:2-42
          (Function 978:2-31 (ValueVar 978:2-28 _Assert.NonNegativeInteger) ((ValueVar 978:29-30 N)))
          (Destructure 979:2-8
            (ValueVar 979:2-3 N)
            (NumberString 979:7-8 0))))
      (then (ValueVar 979:11-12 A))
      (else (Function 979:15-53
          (ValueVar 979:15-28 Array.AppendN)
          ((Merge 979:29-40
              (Merge 979:29-30
                (Array 979:29-30 ())
                (ValueVar 979:33-34 A))
              (Array 979:36-40 ((ValueVar 979:36-39 Val))))
           (ValueVar 979:42-45 Val)
           (Merge 979:47-52
              (ValueVar 979:47-48 N)
              (Negation 979:51-52 (NumberString 979:51-52 1))))))))
  
  (DeclareGlobal 981:0-44
    (Function 981:0-18 (ValueVar 981:0-15 Table.Transpose) ((ValueVar 981:16-17 T)))
    (Function 981:21-44 (ValueVar 981:21-37 _Table.Transpose) ((ValueVar 981:38-39 T) (Array 981:41-44 ()))))
  
  (DeclareGlobal 983:0-168
    (Function 983:0-24 (ValueVar 983:0-16 _Table.Transpose) ((ValueVar 983:17-18 T) (ValueVar 983:20-23 Acc)))
    (Conditional 984:2-141
      (condition (TakeRight 984:2-77
          (Destructure 984:2-38
            (Function 984:2-23 (ValueVar 984:2-20 _Table.FirstPerRow) ((ValueVar 984:21-22 T)))
            (ValueVar 984:27-38 FirstPerRow))
          (Destructure 985:2-36
            (Function 985:2-22 (ValueVar 985:2-19 _Table.RestPerRow) ((ValueVar 985:20-21 T)))
            (ValueVar 985:26-36 RestPerRow))))
      (then (Function 986:2-53
          (ValueVar 986:2-18 _Table.Transpose)
          ((ValueVar 986:19-29 RestPerRow)
           (Merge 986:31-52
              (Merge 986:31-32
                (Array 986:31-32 ())
                (ValueVar 986:35-38 Acc))
              (Array 986:40-52 ((ValueVar 986:40-51 FirstPerRow)))))))
      (else (ValueVar 987:2-5 Acc))))
  
  (DeclareGlobal 989:0-115
    (Function 989:0-21 (ValueVar 989:0-18 _Table.FirstPerRow) ((ValueVar 989:19-20 T)))
    (TakeRight 990:2-91
      (TakeRight 990:2-48
        (Destructure 990:2-21
          (ValueVar 990:2-3 T)
          (Merge 990:7-21
            (Array 990:7-8 ((ValueVar 990:8-11 Row)))
            (ValueVar 990:16-20 Rest)))
        (Destructure 990:24-48
          (ValueVar 990:24-27 Row)
          (Merge 990:31-48
            (Array 990:31-32 ((ValueVar 990:32-41 VeryFirst)))
            (ValueVar 990:46-47 _))))
      (Function 991:2-40 (ValueVar 991:2-21 __Table.FirstPerRow) ((ValueVar 991:22-26 Rest) (Array 991:28-39 ((ValueVar 991:29-38 VeryFirst)))))))
  
  (DeclareGlobal 993:0-129
    (Function 993:0-27 (ValueVar 993:0-19 __Table.FirstPerRow) ((ValueVar 993:20-21 T) (ValueVar 993:23-26 Acc)))
    (Conditional 994:2-99
      (condition (TakeRight 994:2-44
          (Destructure 994:2-21
            (ValueVar 994:2-3 T)
            (Merge 994:7-21
              (Array 994:7-8 ((ValueVar 994:8-11 Row)))
              (ValueVar 994:16-20 Rest)))
          (Destructure 994:24-44
            (ValueVar 994:24-27 Row)
            (Merge 994:31-44
              (Array 994:31-32 ((ValueVar 994:32-37 First)))
              (ValueVar 994:42-43 _)))))
      (then (Function 995:2-44
          (ValueVar 995:2-21 __Table.FirstPerRow)
          ((ValueVar 995:22-26 Rest)
           (Merge 995:28-43
              (Merge 995:28-29
                (Array 995:28-29 ())
                (ValueVar 995:32-35 Acc))
              (Array 995:37-43 ((ValueVar 995:37-42 First)))))))
      (else (ValueVar 996:2-5 Acc))))
  
  (DeclareGlobal 998:0-48
    (Function 998:0-20 (ValueVar 998:0-17 _Table.RestPerRow) ((ValueVar 998:18-19 T)))
    (Function 998:23-48 (ValueVar 998:23-41 __Table.RestPerRow) ((ValueVar 998:42-43 T) (Array 998:45-48 ()))))
  
  (DeclareGlobal 1000:0-188
    (Function 1000:0-26 (ValueVar 1000:0-18 __Table.RestPerRow) ((ValueVar 1000:19-20 T) (ValueVar 1000:22-25 Acc)))
    (Conditional 1001:2-159
      (condition (Destructure 1001:2-21
          (ValueVar 1001:2-3 T)
          (Merge 1001:7-21
            (Array 1001:7-8 ((ValueVar 1001:8-11 Row)))
            (ValueVar 1001:16-20 Rest))))
      (then (Conditional 1001:24-151
          (condition (Destructure 1002:4-26
              (ValueVar 1002:4-7 Row)
              (Merge 1002:11-26
                (Array 1002:11-12 ((ValueVar 1002:12-13 _)))
                (ValueVar 1002:18-25 RowRest))))
          (then (Function 1003:4-47
              (ValueVar 1003:4-22 __Table.RestPerRow)
              ((ValueVar 1003:23-27 Rest)
               (Merge 1003:29-46
                  (Merge 1003:29-30
                    (Array 1003:29-30 ())
                    (ValueVar 1003:33-36 Acc))
                  (Array 1003:38-46 ((ValueVar 1003:38-45 RowRest)))))))
          (else (Function 1004:4-42
              (ValueVar 1004:4-22 __Table.RestPerRow)
              ((ValueVar 1004:23-27 Rest)
               (Merge 1004:29-41
                  (Merge 1004:29-30
                    (Array 1004:29-30 ())
                    (ValueVar 1004:33-36 Acc))
                  (Array 1004:38-41 ((Array 1004:38-41 ())))))))))
      (else (ValueVar 1006:2-5 Acc))))
  
  (DeclareGlobal 1008:0-71
    (Function 1008:0-24 (ValueVar 1008:0-21 Table.RotateClockwise) ((ValueVar 1008:22-23 T)))
    (Function 1008:27-71 (ValueVar 1008:27-36 Array.Map) ((Function 1008:37-55 (ValueVar 1008:37-52 Table.Transpose) ((ValueVar 1008:53-54 T))) (ValueVar 1008:57-70 Array.Reverse))))
  
  (DeclareGlobal 1010:0-67
    (Function 1010:0-31 (ValueVar 1010:0-28 Table.RotateCounterClockwise) ((ValueVar 1010:29-30 T)))
    (Function 1010:34-67 (ValueVar 1010:34-47 Array.Reverse) ((Function 1010:48-66 (ValueVar 1010:48-63 Table.Transpose) ((ValueVar 1010:64-65 T))))))
  
  (DeclareGlobal 1012:0-60
    (Function 1012:0-26 (ValueVar 1012:0-16 Table.ZipObjects) ((ValueVar 1012:17-19 Ks) (ValueVar 1012:21-25 Rows)))
    (Function 1012:29-60
      (ValueVar 1012:29-46 _Table.ZipObjects)
      ((ValueVar 1012:47-49 Ks)
       (ValueVar 1012:51-55 Rows)
       (Array 1012:57-60 ()))))
  
  (DeclareGlobal 1014:0-135
    (Function 1014:0-32
      (ValueVar 1014:0-17 _Table.ZipObjects)
      ((ValueVar 1014:18-20 Ks)
       (ValueVar 1014:22-26 Rows)
       (ValueVar 1014:28-31 Acc)))
    (Conditional 1015:2-100
      (condition (Destructure 1015:2-24
          (ValueVar 1015:2-6 Rows)
          (Merge 1015:10-24
            (Array 1015:10-11 ((ValueVar 1015:11-14 Row)))
            (ValueVar 1015:19-23 Rest))))
      (then (Function 1016:2-65
          (ValueVar 1016:2-19 _Table.ZipObjects)
          ((ValueVar 1016:20-22 Ks)
           (ValueVar 1016:24-28 Rest)
           (Merge 1016:30-64
              (Merge 1016:30-31
                (Array 1016:30-31 ())
                (ValueVar 1016:34-37 Acc))
              (Array 1016:39-64 ((Function 1016:39-63 (ValueVar 1016:39-54 Array.ZipObject) ((ValueVar 1016:55-57 Ks) (ValueVar 1016:59-62 Row)))))))))
      (else (ValueVar 1017:2-5 Acc))))
  
  (DeclareGlobal 1021:0-33
    (Function 1021:0-13 (ValueVar 1021:0-7 Obj.Has) ((ValueVar 1021:8-9 O) (ValueVar 1021:11-12 K)))
    (Destructure 1021:16-33
      (ValueVar 1021:16-17 O)
      (Merge 1021:21-33
        (Object 1021:21-31
          ((ValueVar 1021:22-23 K) (ValueVar 1021:25-26 _)))
        (ValueVar 1021:31-32 _))))
  
  (DeclareGlobal 1023:0-37
    (Function 1023:0-13 (ValueVar 1023:0-7 Obj.Get) ((ValueVar 1023:8-9 O) (ValueVar 1023:11-12 K)))
    (TakeRight 1023:16-37
      (Destructure 1023:16-33
        (ValueVar 1023:16-17 O)
        (Merge 1023:21-33
          (Object 1023:21-31
            ((ValueVar 1023:22-23 K) (ValueVar 1023:25-26 V)))
          (ValueVar 1023:31-32 _)))
      (ValueVar 1023:36-37 V)))
  
  (DeclareGlobal 1025:0-31
    (Function 1025:0-16
      (ValueVar 1025:0-7 Obj.Put)
      ((ValueVar 1025:8-9 O)
       (ValueVar 1025:11-12 K)
       (ValueVar 1025:14-15 V)))
    (Merge 1025:19-31
      (Merge 1025:19-20
        (Object 1025:19-20)
        (ValueVar 1025:23-24 O))
      (Object 1025:26-31
        ((ValueVar 1025:26-27 K) (ValueVar 1025:29-30 V)))))
  
  (DeclareGlobal 1029:0-61
    (Function 1029:0-36 (ValueVar 1029:0-14 Ast.Precedence) ((ValueVar 1029:15-21 OpNode) (ValueVar 1029:23-35 BindingPower)))
    (Array 1029:39-61 ((ValueVar 1029:40-46 OpNode) (ValueVar 1029:48-60 BindingPower))))
  
  (DeclareGlobal 1031:0-114
    (Function 1031:0-64
      (ValueVar 1031:0-19 Ast.InfixPrecedence)
      ((ValueVar 1031:20-26 OpNode)
       (ValueVar 1031:28-44 LeftBindingPower)
       (ValueVar 1031:46-63 RightBindingPower)))
    (Array 1032:2-47 ((ValueVar 1032:3-9 OpNode) (ValueVar 1032:11-27 LeftBindingPower) (ValueVar 1032:29-46 RightBindingPower))))
  
  (DeclareGlobal 1036:0-28
    (Function 1036:0-12 (ValueVar 1036:0-9 Is.String) ((ValueVar 1036:10-11 V)))
    (Destructure 1036:15-28
      (ValueVar 1036:15-16 V)
      (Merge 1036:20-28
        (String 1036:21-23 "")
        (ValueVar 1036:26-27 _))))
  
  (DeclareGlobal 1038:0-27
    (Function 1038:0-12 (ValueVar 1038:0-9 Is.Number) ((ValueVar 1038:10-11 V)))
    (Destructure 1038:15-27
      (ValueVar 1038:15-16 V)
      (Merge 1038:20-27
        (NumberString 1038:21-22 0)
        (ValueVar 1038:25-26 _))))
  
  (DeclareGlobal 1040:0-29
    (Function 1040:0-10 (ValueVar 1040:0-7 Is.Bool) ((ValueVar 1040:8-9 V)))
    (Destructure 1040:13-29
      (ValueVar 1040:13-14 V)
      (Merge 1040:18-29
        (Boolean 1040:19-24 false)
        (ValueVar 1040:27-28 _))))
  
  (DeclareGlobal 1042:0-22
    (Function 1042:0-10 (ValueVar 1042:0-7 Is.Null) ((ValueVar 1042:8-9 V)))
    (Destructure 1042:13-22
      (ValueVar 1042:13-14 V)
      (Null 1042:18-22 null)))
  
  (DeclareGlobal 1044:0-25
    (Function 1044:0-11 (ValueVar 1044:0-8 Is.Array) ((ValueVar 1044:9-10 V)))
    (Destructure 1044:14-25
      (ValueVar 1044:14-15 V)
      (Merge 1044:19-25
        (Array 1044:19-20 ())
        (ValueVar 1044:23-24 _))))
  
  (DeclareGlobal 1046:0-26
    (Function 1046:0-12 (ValueVar 1046:0-9 Is.Object) ((ValueVar 1046:10-11 V)))
    (Destructure 1046:15-26
      (ValueVar 1046:15-16 V)
      (Merge 1046:20-26
        (Object 1046:20-21)
        (ValueVar 1046:24-25 _))))
  
  (DeclareGlobal 1048:0-23
    (Function 1048:0-14 (ValueVar 1048:0-8 Is.Equal) ((ValueVar 1048:9-10 A) (ValueVar 1048:12-13 B)))
    (Destructure 1048:17-23
      (ValueVar 1048:17-18 A)
      (ValueVar 1048:22-23 B)))
  
  (DeclareGlobal 1050:0-45
    (Function 1050:0-17 (ValueVar 1050:0-11 Is.LessThan) ((ValueVar 1050:12-13 A) (ValueVar 1050:15-16 B)))
    (Conditional 1050:20-45
      (condition (Destructure 1050:20-26
          (ValueVar 1050:20-21 A)
          (ValueVar 1050:25-26 B)))
      (then (ValueVar 1050:29-34 @Fail))
      (else (Destructure 1050:37-45
          (ValueVar 1050:37-38 A)
          (Range 1050:42-45 () (ValueVar 1050:44-45 B))))))
  
  (DeclareGlobal 1052:0-35
    (Function 1052:0-24 (ValueVar 1052:0-18 Is.LessThanOrEqual) ((ValueVar 1052:19-20 A) (ValueVar 1052:22-23 B)))
    (Destructure 1052:27-35
      (ValueVar 1052:27-28 A)
      (Range 1052:32-35 () (ValueVar 1052:34-35 B))))
  
  (DeclareGlobal 1054:0-48
    (Function 1054:0-20 (ValueVar 1054:0-14 Is.GreaterThan) ((ValueVar 1054:15-16 A) (ValueVar 1054:18-19 B)))
    (Conditional 1054:23-48
      (condition (Destructure 1054:23-29
          (ValueVar 1054:23-24 A)
          (ValueVar 1054:28-29 B)))
      (then (ValueVar 1054:32-37 @Fail))
      (else (Destructure 1054:40-48
          (ValueVar 1054:40-41 A)
          (Range 1054:45-48 (ValueVar 1054:45-46 B) ())))))
  
  (DeclareGlobal 1056:0-38
    (Function 1056:0-27 (ValueVar 1056:0-21 Is.GreaterThanOrEqual) ((ValueVar 1056:22-23 A) (ValueVar 1056:25-26 B)))
    (Destructure 1056:30-38
      (ValueVar 1056:30-31 A)
      (Range 1056:35-38 (ValueVar 1056:35-36 B) ())))
  
  (DeclareGlobal 1060:0-51
    (Function 1060:0-12 (ValueVar 1060:0-9 As.Number) ((ValueVar 1060:10-11 V)))
    (Or 1060:15-51
      (Function 1060:15-27 (ValueVar 1060:15-24 Is.Number) ((ValueVar 1060:25-26 V)))
      (Return 1060:30-51
        (Destructure 1060:31-46
          (ValueVar 1060:31-32 V)
          (StringTemplate 1060:36-46 (Merge 1060:39-44
            (NumberString 1060:39-40 0)
            (ValueVar 1060:43-44 N))))
        (ValueVar 1060:49-50 N))))
  
  (DeclareGlobal 1064:0-96
    (Function 1064:0-29 (ValueVar 1064:0-26 _Assert.NonNegativeInteger) ((ValueVar 1064:27-28 V)))
    (Or 1065:2-64
      (Destructure 1065:2-10
        (ValueVar 1065:2-3 V)
        (Range 1065:7-10 (NumberString 1065:7-8 0) ()))
      (Function 1065:13-64
        (ValueVar 1065:13-19 @Crash)
        ((StringTemplate 1065:20-63
            (String 1065:21-58 "Expected a non-negative integer, got ")
            (ValueVar 1065:60-61 V))))))

