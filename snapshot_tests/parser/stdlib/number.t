  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number.possum -i '' --no-stdlib
  (Import 1:0-14 stdlib/array)
  
  (Import 2:0-13 stdlib/util)
  
  (Import 3:0-15 stdlib/Number)
  
  (DeclareGlobal 5:0-12
    (Identifier 5:0-5 digit)
    (Range 5:8-12 (NumberString 5:8-9 0) (NumberString 5:11-12 9)))
  
  (DeclareGlobal 7:0-54
    (Identifier 7:0-7 integer)
    (Function 7:10-54
      (Identifier 7:10-19 as_number) [
        (Merge 7:20-53
          (Function 7:20-30
            (Identifier 7:20-25 maybe) [
              (String 7:26-29 "-")
            ])
          (Identifier 7:33-53 _number_integer_part))
      ]))
  
  (DeclareGlobal 9:0-13
    (Identifier 9:0-3 int)
    (Identifier 9:6-13 integer))
  
  (DeclareGlobal 11:0-54
    (Identifier 11:0-20 non_negative_integer)
    (Function 11:23-54
      (Identifier 11:23-32 as_number) [
        (Identifier 11:33-53 _number_integer_part)
      ]))
  
  (DeclareGlobal 13:0-56
    (Identifier 13:0-16 negative_integer)
    (Function 13:19-56
      (Identifier 13:19-28 as_number) [
        (Merge 13:29-55
          (String 13:29-32 "-")
          (Identifier 13:35-55 _number_integer_part))
      ]))
  
  (DeclareGlobal 15:0-76
    (Identifier 15:0-5 float)
    (Function 15:8-76
      (Identifier 15:8-17 as_number) [
        (Merge 15:18-75
          (Merge 15:18-51
            (Function 15:18-28
              (Identifier 15:18-23 maybe) [
                (String 15:24-27 "-")
              ])
            (Identifier 15:31-51 _number_integer_part))
          (Identifier 15:54-75 _number_fraction_part))
      ]))
  
  (DeclareGlobal 17:0-97
    (Identifier 17:0-18 scientific_integer)
    (Function 17:21-97
      (Identifier 17:21-30 as_number) [
        (Merge 18:2-63
          (Merge 18:2-37
            (Function 18:2-12
              (Identifier 18:2-7 maybe) [
                (String 18:8-11 "-")
              ])
            (Identifier 19:2-22 _number_integer_part))
          (Identifier 20:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 23:0-121
    (Identifier 23:0-16 scientific_float)
    (Function 23:19-121
      (Identifier 23:19-28 as_number) [
        (Merge 24:2-89
          (Merge 24:2-63
            (Merge 24:2-37
              (Function 24:2-12
                (Identifier 24:2-7 maybe) [
                  (String 24:8-11 "-")
                ])
              (Identifier 25:2-22 _number_integer_part))
            (Identifier 26:2-23 _number_fraction_part))
          (Identifier 27:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 30:0-125
    (Identifier 30:0-6 number)
    (Function 30:9-125
      (Identifier 30:9-18 as_number) [
        (Merge 31:2-103
          (Merge 31:2-70
            (Merge 31:2-37
              (Function 31:2-12
                (Identifier 31:2-7 maybe) [
                  (String 31:8-11 "-")
                ])
              (Identifier 32:2-22 _number_integer_part))
            (Function 33:2-30
              (Identifier 33:2-7 maybe) [
                (Identifier 33:8-29 _number_fraction_part)
              ]))
          (Function 34:2-30
            (Identifier 34:2-7 maybe) [
              (Identifier 34:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 37:0-12
    (Identifier 37:0-3 num)
    (Identifier 37:6-12 number))
  
  (DeclareGlobal 39:0-123
    (Identifier 39:0-19 non_negative_number)
    (Function 39:22-123
      (Identifier 39:22-31 as_number) [
        (Merge 40:2-88
          (Merge 40:2-55
            (Identifier 40:2-22 _number_integer_part)
            (Function 41:2-30
              (Identifier 41:2-7 maybe) [
                (Identifier 41:8-29 _number_fraction_part)
              ]))
          (Function 42:2-30
            (Identifier 42:2-7 maybe) [
              (Identifier 42:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 45:0-127
    (Identifier 45:0-15 negative_number)
    (Function 45:18-127
      (Identifier 45:18-27 as_number) [
        (Merge 46:2-96
          (Merge 46:2-63
            (Merge 46:2-30
              (String 46:2-5 "-")
              (Identifier 47:2-22 _number_integer_part))
            (Function 48:2-30
              (Identifier 48:2-7 maybe) [
                (Identifier 48:8-29 _number_fraction_part)
              ]))
          (Function 49:2-30
            (Identifier 49:2-7 maybe) [
              (Identifier 49:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 52:0-54
    (Identifier 52:0-20 _number_integer_part)
    (Or 52:23-54
      (Merge 52:23-44
        (Range 52:24-32 (String 52:24-27 "1") (String 52:29-32 "9"))
        (Identifier 52:35-43 numerals))
      (Identifier 52:47-54 numeral)))
  
  (DeclareGlobal 54:0-38
    (Identifier 54:0-21 _number_fraction_part)
    (Merge 54:24-38
      (String 54:24-27 ".")
      (Identifier 54:30-38 numerals)))
  
  (DeclareGlobal 56:0-65
    (Identifier 56:0-21 _number_exponent_part)
    (Merge 56:24-65
      (Merge 56:24-54
        (Or 56:24-35
          (String 56:25-28 "e")
          (String 56:31-34 "E"))
        (Function 56:38-54
          (Identifier 56:38-43 maybe) [
            (Or 56:44-53
              (String 56:44-47 "-")
              (String 56:50-53 "+"))
          ]))
      (Identifier 56:57-65 numerals)))
  
  (DeclareGlobal 58:0-19
    (Identifier 58:0-12 binary_digit)
    (Range 58:15-19 (NumberString 58:15-16 0) (NumberString 58:18-19 1)))
  
  (DeclareGlobal 60:0-18
    (Identifier 60:0-11 octal_digit)
    (Range 60:14-18 (NumberString 60:14-15 0) (NumberString 60:17-18 7)))
  
  (DeclareGlobal 62:0-145
    (Identifier 62:0-9 hex_digit)
    (Or 63:2-133
      (Identifier 63:2-7 digit)
      (Or 64:2-123
        (Return 64:2-18
          (Or 64:3-12
            (String 64:3-6 "a")
            (String 64:9-12 "A"))
          (NumberString 64:15-17 10))
        (Or 65:2-102
          (Return 65:2-18
            (Or 65:3-12
              (String 65:3-6 "b")
              (String 65:9-12 "B"))
            (NumberString 65:15-17 11))
          (Or 66:2-81
            (Return 66:2-18
              (Or 66:3-12
                (String 66:3-6 "c")
                (String 66:9-12 "C"))
              (NumberString 66:15-17 12))
            (Or 67:2-60
              (Return 67:2-18
                (Or 67:3-12
                  (String 67:3-6 "d")
                  (String 67:9-12 "D"))
                (NumberString 67:15-17 13))
              (Or 68:2-39
                (Return 68:2-18
                  (Or 68:3-12
                    (String 68:3-6 "e")
                    (String 68:9-12 "E"))
                  (NumberString 68:15-17 14))
                (Return 69:2-18
                  (Or 69:3-12
                    (String 69:3-6 "f")
                    (String 69:9-12 "F"))
                  (NumberString 69:15-17 15)))))))))
  
  (DeclareGlobal 71:0-77
    (Identifier 71:0-14 binary_integer)
    (Return 71:17-77
      (Destructure 71:17-46
        (Function 71:17-36
          (Identifier 71:17-22 array) [
            (Identifier 71:23-35 binary_digit)
          ])
        (Identifier 71:40-46 Digits))
      (Function 71:49-77
        (Identifier 71:49-69 Num.FromBinaryDigits) [
          (Identifier 71:70-76 Digits)
        ])))
  
  (DeclareGlobal 73:0-74
    (Identifier 73:0-13 octal_integer)
    (Return 73:16-74
      (Destructure 73:16-44
        (Function 73:16-34
          (Identifier 73:16-21 array) [
            (Identifier 73:22-33 octal_digit)
          ])
        (Identifier 73:38-44 Digits))
      (Function 73:47-74
        (Identifier 73:47-66 Num.FromOctalDigits) [
          (Identifier 73:67-73 Digits)
        ])))
  
  (DeclareGlobal 75:0-68
    (Identifier 75:0-11 hex_integer)
    (Return 75:14-68
      (Destructure 75:14-40
        (Function 75:14-30
          (Identifier 75:14-19 array) [
            (Identifier 75:20-29 hex_digit)
          ])
        (Identifier 75:34-40 Digits))
      (Function 75:43-68
        (Identifier 75:43-60 Num.FromHexDigits) [
          (Identifier 75:61-67 Digits)
        ])))
