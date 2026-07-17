  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number.possum -i '' --no-stdlib
  (Import 1:0-15 stdlib/string private)
  
  (Import 2:0-14 stdlib/array private)
  
  (Import 3:0-19 stdlib/combinator private)
  
  (Import 4:0-15 stdlib/Number private)
  
  (DeclareGlobal 6:0-12
    (Identifier 6:0-5 digit)
    (Range 6:8-12 (NumberString 6:8-9 0) (NumberString 6:11-12 9)))
  
  (DeclareGlobal 8:0-54
    (Identifier 8:0-7 integer)
    (Function 8:10-54
      (Identifier 8:10-19 as_number) [
        (Merge 8:20-53
          (Function 8:20-30
            (Identifier 8:20-25 maybe) [
              (String 8:26-29 "-")
            ])
          (Identifier 8:33-53 _number_integer_part))
      ]))
  
  (DeclareGlobal 10:0-13
    (Identifier 10:0-3 int)
    (Identifier 10:6-13 integer))
  
  (DeclareGlobal 12:0-54
    (Identifier 12:0-20 non_negative_integer)
    (Function 12:23-54
      (Identifier 12:23-32 as_number) [
        (Identifier 12:33-53 _number_integer_part)
      ]))
  
  (DeclareGlobal 14:0-56
    (Identifier 14:0-16 negative_integer)
    (Function 14:19-56
      (Identifier 14:19-28 as_number) [
        (Merge 14:29-55
          (String 14:29-32 "-")
          (Identifier 14:35-55 _number_integer_part))
      ]))
  
  (DeclareGlobal 16:0-76
    (Identifier 16:0-5 float)
    (Function 16:8-76
      (Identifier 16:8-17 as_number) [
        (Merge 16:18-75
          (Merge 16:18-51
            (Function 16:18-28
              (Identifier 16:18-23 maybe) [
                (String 16:24-27 "-")
              ])
            (Identifier 16:31-51 _number_integer_part))
          (Identifier 16:54-75 _number_fraction_part))
      ]))
  
  (DeclareGlobal 18:0-97
    (Identifier 18:0-18 scientific_integer)
    (Function 18:21-97
      (Identifier 18:21-30 as_number) [
        (Merge 19:2-63
          (Merge 19:2-37
            (Function 19:2-12
              (Identifier 19:2-7 maybe) [
                (String 19:8-11 "-")
              ])
            (Identifier 20:2-22 _number_integer_part))
          (Identifier 21:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 24:0-121
    (Identifier 24:0-16 scientific_float)
    (Function 24:19-121
      (Identifier 24:19-28 as_number) [
        (Merge 25:2-89
          (Merge 25:2-63
            (Merge 25:2-37
              (Function 25:2-12
                (Identifier 25:2-7 maybe) [
                  (String 25:8-11 "-")
                ])
              (Identifier 26:2-22 _number_integer_part))
            (Identifier 27:2-23 _number_fraction_part))
          (Identifier 28:2-23 _number_exponent_part))
      ]))
  
  (DeclareGlobal 31:0-125
    (Identifier 31:0-6 number)
    (Function 31:9-125
      (Identifier 31:9-18 as_number) [
        (Merge 32:2-103
          (Merge 32:2-70
            (Merge 32:2-37
              (Function 32:2-12
                (Identifier 32:2-7 maybe) [
                  (String 32:8-11 "-")
                ])
              (Identifier 33:2-22 _number_integer_part))
            (Function 34:2-30
              (Identifier 34:2-7 maybe) [
                (Identifier 34:8-29 _number_fraction_part)
              ]))
          (Function 35:2-30
            (Identifier 35:2-7 maybe) [
              (Identifier 35:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 38:0-12
    (Identifier 38:0-3 num)
    (Identifier 38:6-12 number))
  
  (DeclareGlobal 40:0-123
    (Identifier 40:0-19 non_negative_number)
    (Function 40:22-123
      (Identifier 40:22-31 as_number) [
        (Merge 41:2-88
          (Merge 41:2-55
            (Identifier 41:2-22 _number_integer_part)
            (Function 42:2-30
              (Identifier 42:2-7 maybe) [
                (Identifier 42:8-29 _number_fraction_part)
              ]))
          (Function 43:2-30
            (Identifier 43:2-7 maybe) [
              (Identifier 43:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 46:0-127
    (Identifier 46:0-15 negative_number)
    (Function 46:18-127
      (Identifier 46:18-27 as_number) [
        (Merge 47:2-96
          (Merge 47:2-63
            (Merge 47:2-30
              (String 47:2-5 "-")
              (Identifier 48:2-22 _number_integer_part))
            (Function 49:2-30
              (Identifier 49:2-7 maybe) [
                (Identifier 49:8-29 _number_fraction_part)
              ]))
          (Function 50:2-30
            (Identifier 50:2-7 maybe) [
              (Identifier 50:8-29 _number_exponent_part)
            ]))
      ]))
  
  (DeclareGlobal 53:0-54
    (Identifier 53:0-20 _number_integer_part)
    (Or 53:23-54
      (Merge 53:23-44
        (Range 53:24-32 (String 53:24-27 "1") (String 53:29-32 "9"))
        (Identifier 53:35-43 numerals))
      (Identifier 53:47-54 numeral)))
  
  (DeclareGlobal 55:0-38
    (Identifier 55:0-21 _number_fraction_part)
    (Merge 55:24-38
      (String 55:24-27 ".")
      (Identifier 55:30-38 numerals)))
  
  (DeclareGlobal 57:0-65
    (Identifier 57:0-21 _number_exponent_part)
    (Merge 57:24-65
      (Merge 57:24-54
        (Or 57:24-35
          (String 57:25-28 "e")
          (String 57:31-34 "E"))
        (Function 57:38-54
          (Identifier 57:38-43 maybe) [
            (Or 57:44-53
              (String 57:44-47 "-")
              (String 57:50-53 "+"))
          ]))
      (Identifier 57:57-65 numerals)))
  
  (DeclareGlobal 59:0-19
    (Identifier 59:0-12 binary_digit)
    (Range 59:15-19 (NumberString 59:15-16 0) (NumberString 59:18-19 1)))
  
  (DeclareGlobal 61:0-18
    (Identifier 61:0-11 octal_digit)
    (Range 61:14-18 (NumberString 61:14-15 0) (NumberString 61:17-18 7)))
  
  (DeclareGlobal 63:0-145
    (Identifier 63:0-9 hex_digit)
    (Or 64:2-133
      (Identifier 64:2-7 digit)
      (Or 65:2-123
        (Return 65:2-18
          (Or 65:3-12
            (String 65:3-6 "a")
            (String 65:9-12 "A"))
          (NumberString 65:15-17 10))
        (Or 66:2-102
          (Return 66:2-18
            (Or 66:3-12
              (String 66:3-6 "b")
              (String 66:9-12 "B"))
            (NumberString 66:15-17 11))
          (Or 67:2-81
            (Return 67:2-18
              (Or 67:3-12
                (String 67:3-6 "c")
                (String 67:9-12 "C"))
              (NumberString 67:15-17 12))
            (Or 68:2-60
              (Return 68:2-18
                (Or 68:3-12
                  (String 68:3-6 "d")
                  (String 68:9-12 "D"))
                (NumberString 68:15-17 13))
              (Or 69:2-39
                (Return 69:2-18
                  (Or 69:3-12
                    (String 69:3-6 "e")
                    (String 69:9-12 "E"))
                  (NumberString 69:15-17 14))
                (Return 70:2-18
                  (Or 70:3-12
                    (String 70:3-6 "f")
                    (String 70:9-12 "F"))
                  (NumberString 70:15-17 15)))))))))
  
  (DeclareGlobal 72:0-77
    (Identifier 72:0-14 binary_integer)
    (Return 72:17-77
      (Destructure 72:17-46
        (Function 72:17-36
          (Identifier 72:17-22 array) [
            (Identifier 72:23-35 binary_digit)
          ])
        (Identifier 72:40-46 Digits))
      (Function 72:49-77
        (Identifier 72:49-69 Num.FromBinaryDigits) [
          (Identifier 72:70-76 Digits)
        ])))
  
  (DeclareGlobal 74:0-74
    (Identifier 74:0-13 octal_integer)
    (Return 74:16-74
      (Destructure 74:16-44
        (Function 74:16-34
          (Identifier 74:16-21 array) [
            (Identifier 74:22-33 octal_digit)
          ])
        (Identifier 74:38-44 Digits))
      (Function 74:47-74
        (Identifier 74:47-66 Num.FromOctalDigits) [
          (Identifier 74:67-73 Digits)
        ])))
  
  (DeclareGlobal 76:0-68
    (Identifier 76:0-11 hex_integer)
    (Return 76:14-68
      (Destructure 76:14-40
        (Function 76:14-30
          (Identifier 76:14-19 array) [
            (Identifier 76:20-29 hex_digit)
          ])
        (Identifier 76:34-40 Digits))
      (Function 76:43-68
        (Identifier 76:43-60 Num.FromHexDigits) [
          (Identifier 76:61-67 Digits)
        ])))
