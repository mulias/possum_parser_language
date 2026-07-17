  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/combinator.possum -i '' --no-stdlib
  (Import 1:0-15 stdlib/string private)
  
  (Import 2:0-14 stdlib/const private)
  
  (DeclareGlobal 4:0-17
    (Function 4:0-7
      (Identifier 4:0-4 many) [
        (Identifier 4:5-6 p)
      ])
    (Repeat 4:10-17
      (Identifier 4:10-11 p)
      (Range 4:14-17 (NumberString 4:14-15 1) ())))
  
  (DeclareGlobal 6:0-40
    (Function 6:0-16
      (Identifier 6:0-8 many_sep) [
        (Identifier 6:9-10 p)
        (Identifier 6:12-15 sep)
      ])
    (Merge 6:19-40
      (Identifier 6:19-20 p)
      (Repeat 6:23-40
        (TakeRight 6:24-33
          (Identifier 6:25-28 sep)
          (Identifier 6:31-32 p))
        (Range 6:36-39 (NumberString 6:36-37 0) ()))))
  
  (DeclareGlobal 8:0-56
    (Function 8:0-19
      (Identifier 8:0-10 many_until) [
        (Identifier 8:11-12 p)
        (Identifier 8:14-18 stop)
      ])
    (TakeLeft 8:22-56
      (Repeat 8:22-43
        (Function 8:22-37
          (Identifier 8:22-28 unless) [
            (Identifier 8:29-30 p)
            (Identifier 8:32-36 stop)
          ])
        (Range 8:40-43 (NumberString 8:40-41 1) ()))
      (Function 8:46-56
        (Identifier 8:46-50 peek) [
          (Identifier 8:51-55 stop)
        ])))
  
  (DeclareGlobal 10:0-23
    (Function 10:0-13
      (Identifier 10:0-10 maybe_many) [
        (Identifier 10:11-12 p)
      ])
    (Repeat 10:16-23
      (Identifier 10:16-17 p)
      (Range 10:20-23 (NumberString 10:20-21 0) ())))
  
  (DeclareGlobal 12:0-51
    (Function 12:0-22
      (Identifier 12:0-14 maybe_many_sep) [
        (Identifier 12:15-16 p)
        (Identifier 12:18-21 sep)
      ])
    (Or 12:25-51
      (Function 12:25-41
        (Identifier 12:25-33 many_sep) [
          (Identifier 12:34-35 p)
          (Identifier 12:37-40 sep)
        ])
      (Identifier 12:44-51 succeed)))
  
  (DeclareGlobal 14:0-44
    (Function 14:0-7
      (Identifier 14:0-4 peek) [
        (Identifier 14:5-6 p)
      ])
    (TakeRight 14:10-44
      (Destructure 14:10-30
        (Identifier 14:10-23 @input.offset)
        (Identifier 14:27-30 Pos))
      (Function 14:33-44
        (Identifier 14:33-36 @at) [
          (Identifier 14:37-40 Pos)
          (Identifier 14:42-43 p)
        ])))
  
  (DeclareGlobal 16:0-22
    (Function 16:0-8
      (Identifier 16:0-5 maybe) [
        (Identifier 16:6-7 p)
      ])
    (Or 16:11-22
      (Identifier 16:11-12 p)
      (Identifier 16:15-22 succeed)))
  
  (DeclareGlobal 18:0-42
    (Function 18:0-19
      (Identifier 18:0-6 unless) [
        (Identifier 18:7-8 p)
        (Identifier 18:10-18 excluded)
      ])
    (Conditional 18:22-42
      (Identifier 18:22-30 excluded)
      (Identifier 18:33-38 @fail)
      (Identifier 18:41-42 p)))
  
  (DeclareGlobal 20:0-17
    (Function 20:0-7
      (Identifier 20:0-4 skip) [
        (Identifier 20:5-6 p)
      ])
    (Function 20:10-17
      (Null 20:10-14) [
        (Identifier 20:15-16 p)
      ]))
  
  (DeclareGlobal 22:0-30
    (Function 22:0-7
      (Identifier 22:0-4 find) [
        (Identifier 22:5-6 p)
      ])
    (Or 22:10-30
      (Identifier 22:10-11 p)
      (TakeRight 22:14-30
        (Identifier 22:15-19 char)
        (Function 22:22-29
          (Identifier 22:22-26 find) [
            (Identifier 22:27-28 p)
          ]))))
  
  (DeclareGlobal 24:0-56
    (Function 24:0-11
      (Identifier 24:0-8 find_all) [
        (Identifier 24:9-10 p)
      ])
    (TakeLeft 24:14-56
      (Function 24:14-36
        (Import 24:14-27 stdlib .array) [
          (Function 24:28-35
            (Identifier 24:28-32 find) [
              (Identifier 24:33-34 p)
            ])
        ])
      (Function 24:39-56
        (Identifier 24:39-44 maybe) [
          (Function 24:45-55
            (Identifier 24:45-49 many) [
              (Identifier 24:50-54 char)
            ])
        ])))
  
  (DeclareGlobal 26:0-71
    (Function 26:0-20
      (Identifier 26:0-11 find_before) [
        (Identifier 26:12-13 p)
        (Identifier 26:15-19 stop)
      ])
    (Conditional 26:23-71
      (Identifier 26:23-27 stop)
      (Identifier 26:30-35 @fail)
      (Or 26:38-71
        (Identifier 26:38-39 p)
        (TakeRight 26:42-71
          (Identifier 26:43-47 char)
          (Function 26:50-70
            (Identifier 26:50-61 find_before) [
              (Identifier 26:62-63 p)
              (Identifier 26:65-69 stop)
            ])))))
  
  (DeclareGlobal 28:0-89
    (Function 28:0-24
      (Identifier 28:0-15 find_all_before) [
        (Identifier 28:16-17 p)
        (Identifier 28:19-23 stop)
      ])
    (TakeLeft 28:27-89
      (Function 28:27-62
        (Import 28:27-40 stdlib .array) [
          (Function 28:41-61
            (Identifier 28:41-52 find_before) [
              (Identifier 28:53-54 p)
              (Identifier 28:56-60 stop)
            ])
        ])
      (Function 28:65-89
        (Identifier 28:65-70 maybe) [
          (Function 28:71-88
            (Identifier 28:71-82 chars_until) [
              (Identifier 28:83-87 stop)
            ])
        ])))
  
  (DeclareGlobal 30:0-22
    (Identifier 30:0-7 succeed)
    (Function 30:10-22
      (Identifier 30:10-15 const) [
        (ValueLabel 30:16-17 (Null 30:17-21))
      ]))
  
  (DeclareGlobal 32:0-28
    (Function 32:0-13
      (Identifier 32:0-7 default) [
        (Identifier 32:8-9 p)
        (Identifier 32:11-12 D)
      ])
    (Or 32:16-28
      (Identifier 32:16-17 p)
      (Function 32:20-28
        (Identifier 32:20-25 const) [
          (Identifier 32:26-27 D)
        ])))
  
  (DeclareGlobal 34:0-17
    (Function 34:0-8
      (Identifier 34:0-5 const) [
        (Identifier 34:6-7 C)
      ])
    (Return 34:11-17
      (String 34:11-13 "")
      (Identifier 34:16-17 C)))
  
  (DeclareGlobal 36:0-34
    (Function 36:0-12
      (Identifier 36:0-9 as_number) [
        (Identifier 36:10-11 p)
      ])
    (Return 36:15-34
      (Destructure 36:15-30
        (Identifier 36:15-16 p)
        (StringTemplate 36:20-30 [
          (Merge 36:23-28
            (NumberString 36:23-24 0)
            (Identifier 36:27-28 N))
        ]))
      (Identifier 36:33-34 N)))
  
  (DeclareGlobal 38:0-21
    (Function 38:0-12
      (Identifier 38:0-9 as_string) [
        (Identifier 38:10-11 p)
      ])
    (StringTemplate 38:15-21 [
      (Identifier 38:18-19 p)
    ]))
  
  (DeclareGlobal 40:0-35
    (Function 40:0-17
      (Identifier 40:0-8 surround) [
        (Identifier 40:9-10 p)
        (Identifier 40:12-16 fill)
      ])
    (TakeLeft 40:20-35
      (TakeRight 40:20-28
        (Identifier 40:20-24 fill)
        (Identifier 40:27-28 p))
      (Identifier 40:31-35 fill)))
  
  (DeclareGlobal 42:0-37
    (Identifier 42:0-12 end_of_input)
    (Conditional 42:15-37
      (Identifier 42:15-19 char)
      (Identifier 42:22-27 @fail)
      (Identifier 42:30-37 succeed)))
  
  (DeclareGlobal 44:0-18
    (Identifier 44:0-3 end)
    (Identifier 44:6-18 end_of_input))
  
  (DeclareGlobal 46:0-56
    (Function 46:0-8
      (Identifier 46:0-5 input) [
        (Identifier 46:6-7 p)
      ])
    (TakeLeft 46:11-56
      (Function 46:11-41
        (Identifier 46:11-19 surround) [
          (Identifier 46:20-21 p)
          (Function 46:23-40
            (Identifier 46:23-28 maybe) [
              (Identifier 46:29-39 whitespace)
            ])
        ])
      (Identifier 46:44-56 end_of_input)))
  
  (DeclareGlobal 48:0-51
    (Function 48:0-17
      (Identifier 48:0-11 one_or_both) [
        (Identifier 48:12-13 a)
        (Identifier 48:15-16 b)
      ])
    (Or 48:20-51
      (Merge 48:20-34
        (Identifier 48:21-22 a)
        (Function 48:25-33
          (Identifier 48:25-30 maybe) [
            (Identifier 48:31-32 b)
          ]))
      (Merge 48:37-51
        (Function 48:38-46
          (Identifier 48:38-43 maybe) [
            (Identifier 48:44-45 a)
          ])
        (Identifier 48:49-50 b))))
