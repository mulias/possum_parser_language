  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/util.possum -i '' --no-stdlib
  (Import 1:0-15 stdlib/string)
  
  (Import 2:0-14 stdlib/const)
  
  (DeclareGlobal 4:0-44
    (Function 4:0-7
      (Identifier 4:0-4 peek) [
        (Identifier 4:5-6 p)
      ])
    (TakeRight 4:10-44
      (Destructure 4:10-30
        (Identifier 4:10-23 @input.offset)
        (Identifier 4:27-30 Pos))
      (Function 4:33-44
        (Identifier 4:33-36 @at) [
          (Identifier 4:37-40 Pos)
          (Identifier 4:42-43 p)
        ])))
  
  (DeclareGlobal 6:0-22
    (Function 6:0-8
      (Identifier 6:0-5 maybe) [
        (Identifier 6:6-7 p)
      ])
    (Or 6:11-22
      (Identifier 6:11-12 p)
      (Identifier 6:15-22 succeed)))
  
  (DeclareGlobal 8:0-42
    (Function 8:0-19
      (Identifier 8:0-6 unless) [
        (Identifier 8:7-8 p)
        (Identifier 8:10-18 excluded)
      ])
    (Conditional 8:22-42
      (Identifier 8:22-30 excluded)
      (Identifier 8:33-38 @fail)
      (Identifier 8:41-42 p)))
  
  (DeclareGlobal 10:0-17
    (Function 10:0-7
      (Identifier 10:0-4 skip) [
        (Identifier 10:5-6 p)
      ])
    (Function 10:10-17
      (Null 10:10-14) [
        (Identifier 10:15-16 p)
      ]))
  
  (DeclareGlobal 12:0-30
    (Function 12:0-7
      (Identifier 12:0-4 find) [
        (Identifier 12:5-6 p)
      ])
    (Or 12:10-30
      (Identifier 12:10-11 p)
      (TakeRight 12:14-30
        (Identifier 12:15-19 char)
        (Function 12:22-29
          (Identifier 12:22-26 find) [
            (Identifier 12:27-28 p)
          ]))))
  
  (DeclareGlobal 14:0-56
    (Function 14:0-11
      (Identifier 14:0-8 find_all) [
        (Identifier 14:9-10 p)
      ])
    (TakeLeft 14:14-56
      (Function 14:14-36
        (Import 14:14-27 stdlib .array) [
          (Function 14:28-35
            (Identifier 14:28-32 find) [
              (Identifier 14:33-34 p)
            ])
        ])
      (Function 14:39-56
        (Identifier 14:39-44 maybe) [
          (Function 14:45-55
            (Identifier 14:45-49 many) [
              (Identifier 14:50-54 char)
            ])
        ])))
  
  (DeclareGlobal 16:0-71
    (Function 16:0-20
      (Identifier 16:0-11 find_before) [
        (Identifier 16:12-13 p)
        (Identifier 16:15-19 stop)
      ])
    (Conditional 16:23-71
      (Identifier 16:23-27 stop)
      (Identifier 16:30-35 @fail)
      (Or 16:38-71
        (Identifier 16:38-39 p)
        (TakeRight 16:42-71
          (Identifier 16:43-47 char)
          (Function 16:50-70
            (Identifier 16:50-61 find_before) [
              (Identifier 16:62-63 p)
              (Identifier 16:65-69 stop)
            ])))))
  
  (DeclareGlobal 18:0-89
    (Function 18:0-24
      (Identifier 18:0-15 find_all_before) [
        (Identifier 18:16-17 p)
        (Identifier 18:19-23 stop)
      ])
    (TakeLeft 18:27-89
      (Function 18:27-62
        (Import 18:27-40 stdlib .array) [
          (Function 18:41-61
            (Identifier 18:41-52 find_before) [
              (Identifier 18:53-54 p)
              (Identifier 18:56-60 stop)
            ])
        ])
      (Function 18:65-89
        (Identifier 18:65-70 maybe) [
          (Function 18:71-88
            (Identifier 18:71-82 chars_until) [
              (Identifier 18:83-87 stop)
            ])
        ])))
  
  (DeclareGlobal 20:0-22
    (Identifier 20:0-7 succeed)
    (Function 20:10-22
      (Identifier 20:10-15 const) [
        (ValueLabel 20:16-17 (Null 20:17-21))
      ]))
  
  (DeclareGlobal 22:0-28
    (Function 22:0-13
      (Identifier 22:0-7 default) [
        (Identifier 22:8-9 p)
        (Identifier 22:11-12 D)
      ])
    (Or 22:16-28
      (Identifier 22:16-17 p)
      (Function 22:20-28
        (Identifier 22:20-25 const) [
          (Identifier 22:26-27 D)
        ])))
  
  (DeclareGlobal 24:0-17
    (Function 24:0-8
      (Identifier 24:0-5 const) [
        (Identifier 24:6-7 C)
      ])
    (Return 24:11-17
      (String 24:11-13 "")
      (Identifier 24:16-17 C)))
  
  (DeclareGlobal 26:0-34
    (Function 26:0-12
      (Identifier 26:0-9 as_number) [
        (Identifier 26:10-11 p)
      ])
    (Return 26:15-34
      (Destructure 26:15-30
        (Identifier 26:15-16 p)
        (StringTemplate 26:20-30 [
          (Merge 26:23-28
            (NumberString 26:23-24 0)
            (Identifier 26:27-28 N))
        ]))
      (Identifier 26:33-34 N)))
  
  (DeclareGlobal 28:0-21
    (Function 28:0-12
      (Identifier 28:0-9 as_string) [
        (Identifier 28:10-11 p)
      ])
    (StringTemplate 28:15-21 [
      (Identifier 28:18-19 p)
    ]))
  
  (DeclareGlobal 30:0-35
    (Function 30:0-17
      (Identifier 30:0-8 surround) [
        (Identifier 30:9-10 p)
        (Identifier 30:12-16 fill)
      ])
    (TakeLeft 30:20-35
      (TakeRight 30:20-28
        (Identifier 30:20-24 fill)
        (Identifier 30:27-28 p))
      (Identifier 30:31-35 fill)))
  
  (DeclareGlobal 32:0-37
    (Identifier 32:0-12 end_of_input)
    (Conditional 32:15-37
      (Identifier 32:15-19 char)
      (Identifier 32:22-27 @fail)
      (Identifier 32:30-37 succeed)))
  
  (DeclareGlobal 34:0-18
    (Identifier 34:0-3 end)
    (Identifier 34:6-18 end_of_input))
  
  (DeclareGlobal 36:0-56
    (Function 36:0-8
      (Identifier 36:0-5 input) [
        (Identifier 36:6-7 p)
      ])
    (TakeLeft 36:11-56
      (Function 36:11-41
        (Identifier 36:11-19 surround) [
          (Identifier 36:20-21 p)
          (Function 36:23-40
            (Identifier 36:23-28 maybe) [
              (Identifier 36:29-39 whitespace)
            ])
        ])
      (Identifier 36:44-56 end_of_input)))
  
  (DeclareGlobal 38:0-51
    (Function 38:0-17
      (Identifier 38:0-11 one_or_both) [
        (Identifier 38:12-13 a)
        (Identifier 38:15-16 b)
      ])
    (Or 38:20-51
      (Merge 38:20-34
        (Identifier 38:21-22 a)
        (Function 38:25-33
          (Identifier 38:25-30 maybe) [
            (Identifier 38:31-32 b)
          ]))
      (Merge 38:37-51
        (Function 38:38-46
          (Identifier 38:38-43 maybe) [
            (Identifier 38:44-45 a)
          ])
        (Identifier 38:49-50 b))))
