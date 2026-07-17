  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number_value.possum -i '' --no-stdlib
  (Import 1:0-14 stdlib/Array private)
  
  (DeclareGlobal 3:0-14
    (Identifier 3:0-7 Num.Add)
    (Identifier 3:10-14 @Add))
  
  (DeclareGlobal 5:0-19
    (Identifier 5:0-7 Num.Sub)
    (Identifier 5:10-19 @Subtract))
  
  (DeclareGlobal 7:0-19
    (Identifier 7:0-7 Num.Mul)
    (Identifier 7:10-19 @Multiply))
  
  (DeclareGlobal 9:0-17
    (Identifier 9:0-7 Num.Div)
    (Identifier 9:10-17 @Divide))
  
  (DeclareGlobal 11:0-16
    (Identifier 11:0-7 Num.Pow)
    (Identifier 11:10-16 @Power))
  
  (DeclareGlobal 13:0-18
    (Identifier 13:0-7 Num.Mod)
    (Identifier 13:10-18 @Modulus))
  
  (DeclareGlobal 15:0-18
    (Identifier 15:0-9 Num.Floor)
    (Identifier 15:12-18 @Floor))
  
  (DeclareGlobal 17:0-19
    (Identifier 17:0-8 Num.Ceil)
    (Identifier 17:11-19 @Ceiling))
  
  (DeclareGlobal 19:0-23
    (Function 19:0-10
      (Identifier 19:0-7 Num.Inc) [
        (Identifier 19:8-9 N)
      ])
    (Function 19:13-23
      (Identifier 19:13-17 @Add) [
        (Identifier 19:18-19 N)
        (NumberString 19:21-22 1)
      ]))
  
  (DeclareGlobal 21:0-28
    (Function 21:0-10
      (Identifier 21:0-7 Num.Dec) [
        (Identifier 21:8-9 N)
      ])
    (Function 21:13-28
      (Identifier 21:13-22 @Subtract) [
        (Identifier 21:23-24 N)
        (NumberString 21:26-27 1)
      ]))
  
  (DeclareGlobal 23:0-26
    (Function 23:0-10
      (Identifier 23:0-7 Num.Abs) [
        (Identifier 23:8-9 N)
      ])
    (Or 23:13-26
      (Destructure 23:13-21
        (Identifier 23:13-14 N)
        (Range 23:18-21 (NumberString 23:18-19 0) ()))
      (Negation 23:24-26 (Identifier 23:25-26 N))))
  
  (DeclareGlobal 25:0-32
    (Function 25:0-13
      (Identifier 25:0-7 Num.Max) [
        (Identifier 25:8-9 A)
        (Identifier 25:11-12 B)
      ])
    (Conditional 25:16-32
      (Destructure 25:16-24
        (Identifier 25:16-17 A)
        (Range 25:21-24 (Identifier 25:21-22 B) ()))
      (Identifier 25:27-28 A)
      (Identifier 25:31-32 B)))
  
  (DeclareGlobal 27:0-32
    (Function 27:0-13
      (Identifier 27:0-7 Num.Min) [
        (Identifier 27:8-9 A)
        (Identifier 27:11-12 B)
      ])
    (Conditional 27:16-32
      (Destructure 27:16-24
        (Identifier 27:16-17 A)
        (Range 27:21-24 () (Identifier 27:23-24 B)))
      (Identifier 27:27-28 A)
      (Identifier 27:31-32 B)))
  
  (DeclareGlobal 29:0-94
    (Function 29:0-24
      (Identifier 29:0-20 Num.FromBinaryDigits) [
        (Identifier 29:21-23 Bs)
      ])
    (TakeRight 30:2-67
      (Destructure 30:2-25
        (Function 30:2-18
          (Identifier 30:2-14 Array.Length) [
            (Identifier 30:15-17 Bs)
          ])
        (Identifier 30:22-25 Len))
      (Function 31:2-39
        (Identifier 31:2-23 _Num.FromBinaryDigits) [
          (Identifier 31:24-26 Bs)
          (NumberSubtract 31:28-35
            (Identifier 31:28-31 Len)
            (NumberString 31:34-35 1))
          (NumberString 31:37-38 0)
        ])))
  
  (DeclareGlobal 33:0-191
    (Function 33:0-35
      (Identifier 33:0-21 _Num.FromBinaryDigits) [
        (Identifier 33:22-24 Bs)
        (Identifier 33:26-29 Pos)
        (Identifier 33:31-34 Acc)
      ])
    (Conditional 34:2-153
      (Destructure 34:2-20
        (Identifier 34:2-4 Bs)
        (Merge 34:8-20
          (Array 34:8-9 [
            (Identifier 34:9-10 B)
          ])
          (Identifier 34:15-19 Rest)))
      (TakeRight 34:23-145
        (Destructure 35:4-13
          (Identifier 35:4-5 B)
          (Range 35:9-13 (NumberString 35:9-10 0) (NumberString 35:12-13 1)))
        (Function 36:4-100
          (Identifier 36:4-25 _Num.FromBinaryDigits) [
            (Identifier 37:6-10 Rest)
            (NumberSubtract 38:6-13
              (Identifier 38:6-9 Pos)
              (NumberString 38:12-13 1))
            (Merge 39:6-39
              (Identifier 39:6-9 Acc)
              (Function 39:12-39
                (Identifier 39:12-19 Num.Mul) [
                  (Identifier 39:20-21 B)
                  (Function 39:23-38
                    (Identifier 39:23-30 Num.Pow) [
                      (NumberString 39:31-32 2)
                      (Identifier 39:34-37 Pos)
                    ])
                ]))
          ]))
      (Identifier 42:2-5 Acc)))
  
  (DeclareGlobal 44:0-92
    (Function 44:0-23
      (Identifier 44:0-19 Num.FromOctalDigits) [
        (Identifier 44:20-22 Os)
      ])
    (TakeRight 45:2-66
      (Destructure 45:2-25
        (Function 45:2-18
          (Identifier 45:2-14 Array.Length) [
            (Identifier 45:15-17 Os)
          ])
        (Identifier 45:22-25 Len))
      (Function 46:2-38
        (Identifier 46:2-22 _Num.FromOctalDigits) [
          (Identifier 46:23-25 Os)
          (NumberSubtract 46:27-34
            (Identifier 46:27-30 Len)
            (NumberString 46:33-34 1))
          (NumberString 46:36-37 0)
        ])))
  
  (DeclareGlobal 48:0-189
    (Function 48:0-34
      (Identifier 48:0-20 _Num.FromOctalDigits) [
        (Identifier 48:21-23 Os)
        (Identifier 48:25-28 Pos)
        (Identifier 48:30-33 Acc)
      ])
    (Conditional 49:2-152
      (Destructure 49:2-20
        (Identifier 49:2-4 Os)
        (Merge 49:8-20
          (Array 49:8-9 [
            (Identifier 49:9-10 O)
          ])
          (Identifier 49:15-19 Rest)))
      (TakeRight 49:23-144
        (Destructure 50:4-13
          (Identifier 50:4-5 O)
          (Range 50:9-13 (NumberString 50:9-10 0) (NumberString 50:12-13 7)))
        (Function 51:4-99
          (Identifier 51:4-24 _Num.FromOctalDigits) [
            (Identifier 52:6-10 Rest)
            (NumberSubtract 53:6-13
              (Identifier 53:6-9 Pos)
              (NumberString 53:12-13 1))
            (Merge 54:6-39
              (Identifier 54:6-9 Acc)
              (Function 54:12-39
                (Identifier 54:12-19 Num.Mul) [
                  (Identifier 54:20-21 O)
                  (Function 54:23-38
                    (Identifier 54:23-30 Num.Pow) [
                      (NumberString 54:31-32 8)
                      (Identifier 54:34-37 Pos)
                    ])
                ]))
          ]))
      (Identifier 57:2-5 Acc)))
  
  (DeclareGlobal 59:0-88
    (Function 59:0-21
      (Identifier 59:0-17 Num.FromHexDigits) [
        (Identifier 59:18-20 Hs)
      ])
    (TakeRight 60:2-64
      (Destructure 60:2-25
        (Function 60:2-18
          (Identifier 60:2-14 Array.Length) [
            (Identifier 60:15-17 Hs)
          ])
        (Identifier 60:22-25 Len))
      (Function 61:2-36
        (Identifier 61:2-20 _Num.FromHexDigits) [
          (Identifier 61:21-23 Hs)
          (NumberSubtract 61:25-32
            (Identifier 61:25-28 Len)
            (NumberString 61:31-32 1))
          (NumberString 61:34-35 0)
        ])))
  
  (DeclareGlobal 63:0-187
    (Function 63:0-32
      (Identifier 63:0-18 _Num.FromHexDigits) [
        (Identifier 63:19-21 Hs)
        (Identifier 63:23-26 Pos)
        (Identifier 63:28-31 Acc)
      ])
    (Conditional 64:2-152
      (Destructure 64:2-20
        (Identifier 64:2-4 Hs)
        (Merge 64:8-20
          (Array 64:8-9 [
            (Identifier 64:9-10 H)
          ])
          (Identifier 64:15-19 Rest)))
      (TakeRight 64:23-144
        (Destructure 65:4-14
          (Identifier 65:4-5 H)
          (Range 65:9-14 (NumberString 65:9-10 0) (NumberString 65:12-14 15)))
        (Function 66:4-98
          (Identifier 66:4-22 _Num.FromHexDigits) [
            (Identifier 67:6-10 Rest)
            (NumberSubtract 68:6-13
              (Identifier 68:6-9 Pos)
              (NumberString 68:12-13 1))
            (Merge 69:6-40
              (Identifier 69:6-9 Acc)
              (Function 69:12-40
                (Identifier 69:12-19 Num.Mul) [
                  (Identifier 69:20-21 H)
                  (Function 69:23-39
                    (Identifier 69:23-30 Num.Pow) [
                      (NumberString 69:31-33 16)
                      (Identifier 69:35-38 Pos)
                    ])
                ]))
          ]))
      (Identifier 72:2-5 Acc)))
