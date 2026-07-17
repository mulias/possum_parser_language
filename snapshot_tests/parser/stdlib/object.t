  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object.possum -i '' --no-stdlib
  (Import 1:0-13 stdlib/util)
  
  (DeclareGlobal 3:0-43
    (Function 3:0-18
      (Identifier 3:0-6 object) [
        (Identifier 3:7-10 key)
        (Identifier 3:12-17 value)
      ])
    (Repeat 3:21-43
      (Function 3:21-37
        (Identifier 3:21-25 pair) [
          (Identifier 3:26-29 key)
          (Identifier 3:31-36 value)
        ])
      (Range 3:40-43 (NumberString 3:40-41 1) ())))
  
  (DeclareGlobal 5:0-117
    (Function 5:0-35
      (Identifier 5:0-10 object_sep) [
        (Identifier 5:11-14 key)
        (Identifier 5:16-22 kv_sep)
        (Identifier 5:24-29 value)
        (Identifier 5:31-34 sep)
      ])
    (Merge 6:2-79
      (Function 6:2-30
        (Identifier 6:2-10 pair_sep) [
          (Identifier 6:11-14 key)
          (Identifier 6:16-22 kv_sep)
          (Identifier 6:24-29 value)
        ])
      (Repeat 7:2-46
        (TakeRight 7:3-39
          (Identifier 7:4-7 sep)
          (Function 7:10-38
            (Identifier 7:10-18 pair_sep) [
              (Identifier 7:19-22 key)
              (Identifier 7:24-30 kv_sep)
              (Identifier 7:32-37 value)
            ]))
        (Range 7:42-45 (NumberString 7:42-43 0) ()))))
  
  (DeclareGlobal 9:0-84
    (Function 9:0-30
      (Identifier 9:0-12 object_until) [
        (Identifier 9:13-16 key)
        (Identifier 9:18-23 value)
        (Identifier 9:25-29 stop)
      ])
    (TakeLeft 10:2-51
      (Repeat 10:2-38
        (Function 10:2-32
          (Identifier 10:2-8 unless) [
            (Function 10:9-25
              (Identifier 10:9-13 pair) [
                (Identifier 10:14-17 key)
                (Identifier 10:19-24 value)
              ])
            (Identifier 10:27-31 stop)
          ])
        (Range 10:35-38 (NumberString 10:35-36 1) ()))
      (Function 10:41-51
        (Identifier 10:41-45 peek) [
          (Identifier 10:46-50 stop)
        ])))
  
  (DeclareGlobal 12:0-58
    (Function 12:0-24
      (Identifier 12:0-12 maybe_object) [
        (Identifier 12:13-16 key)
        (Identifier 12:18-23 value)
      ])
    (Function 12:27-58
      (Identifier 12:27-34 default) [
        (Function 12:35-53
          (Identifier 12:35-41 object) [
            (Identifier 12:42-45 key)
            (Identifier 12:47-52 value)
          ])
        (Object 12:55-58 [])
      ]))
  
  (DeclareGlobal 14:0-98
    (Function 14:0-43
      (Identifier 14:0-16 maybe_object_sep) [
        (Identifier 14:17-20 key)
        (Identifier 14:22-30 pair_sep)
        (Identifier 14:32-37 value)
        (Identifier 14:39-42 sep)
      ])
    (Function 15:2-52
      (Identifier 15:2-9 default) [
        (Function 15:10-47
          (Identifier 15:10-20 object_sep) [
            (Identifier 15:21-24 key)
            (Identifier 15:26-34 pair_sep)
            (Identifier 15:36-41 value)
            (Identifier 15:43-46 sep)
          ])
        (Object 15:49-52 [])
      ]))
  
  (DeclareGlobal 17:0-49
    (Function 17:0-16
      (Identifier 17:0-4 pair) [
        (Identifier 17:5-8 key)
        (Identifier 17:10-15 value)
      ])
    (TakeRight 17:19-49
      (Destructure 17:19-27
        (Identifier 17:19-22 key)
        (Identifier 17:26-27 K))
      (Return 17:30-49
        (Destructure 17:30-40
          (Identifier 17:30-35 value)
          (Identifier 17:39-40 V))
        (Object 17:43-49 [
          (ObjectPair (Identifier 17:44-45 K) (Identifier 17:47-48 V))
        ]))))
  
  (DeclareGlobal 19:0-64
    (Function 19:0-25
      (Identifier 19:0-8 pair_sep) [
        (Identifier 19:9-12 key)
        (Identifier 19:14-17 sep)
        (Identifier 19:19-24 value)
      ])
    (TakeRight 19:28-64
      (TakeRight 19:28-42
        (Destructure 19:28-36
          (Identifier 19:28-31 key)
          (Identifier 19:35-36 K))
        (Identifier 19:39-42 sep))
      (Return 19:45-64
        (Destructure 19:45-55
          (Identifier 19:45-50 value)
          (Identifier 19:54-55 V))
        (Object 19:58-64 [
          (ObjectPair (Identifier 19:59-60 K) (Identifier 19:62-63 V))
        ]))))
  
  (DeclareGlobal 21:0-51
    (Function 21:0-19
      (Identifier 21:0-7 record1) [
        (Identifier 21:8-11 Key)
        (Identifier 21:13-18 value)
      ])
    (Return 21:22-51
      (Destructure 21:22-36
        (Identifier 21:22-27 value)
        (Identifier 21:31-36 Value))
      (Object 21:39-51 [
        (ObjectPair (Identifier 21:40-43 Key) (Identifier 21:45-50 Value))
      ])))
  
  (DeclareGlobal 23:0-94
    (Function 23:0-35
      (Identifier 23:0-7 record2) [
        (Identifier 23:8-12 Key1)
        (Identifier 23:14-20 value1)
        (Identifier 23:22-26 Key2)
        (Identifier 23:28-34 value2)
      ])
    (TakeRight 24:2-56
      (Destructure 24:2-14
        (Identifier 24:2-8 value1)
        (Identifier 24:12-14 V1))
      (Return 25:2-39
        (Destructure 25:2-14
          (Identifier 25:2-8 value2)
          (Identifier 25:12-14 V2))
        (Object 26:2-22 [
          (ObjectPair (Identifier 26:3-7 Key1) (Identifier 26:9-11 V1))
          (ObjectPair (Identifier 26:13-17 Key2) (Identifier 26:19-21 V2))
        ]))))
  
  (DeclareGlobal 28:0-109
    (Function 28:0-44
      (Identifier 28:0-11 record2_sep) [
        (Identifier 28:12-16 Key1)
        (Identifier 28:18-24 value1)
        (Identifier 28:26-29 sep)
        (Identifier 28:31-35 Key2)
        (Identifier 28:37-43 value2)
      ])
    (TakeRight 29:2-62
      (TakeRight 29:2-20
        (Destructure 29:2-14
          (Identifier 29:2-8 value1)
          (Identifier 29:12-14 V1))
        (Identifier 29:17-20 sep))
      (Return 30:2-39
        (Destructure 30:2-14
          (Identifier 30:2-8 value2)
          (Identifier 30:12-14 V2))
        (Object 31:2-22 [
          (ObjectPair (Identifier 31:3-7 Key1) (Identifier 31:9-11 V1))
          (ObjectPair (Identifier 31:13-17 Key2) (Identifier 31:19-21 V2))
        ]))))
  
  (DeclareGlobal 33:0-135
    (Function 33:0-49
      (Identifier 33:0-7 record3) [
        (Identifier 33:8-12 Key1)
        (Identifier 33:14-20 value1)
        (Identifier 33:22-26 Key2)
        (Identifier 33:28-34 value2)
        (Identifier 33:36-40 Key3)
        (Identifier 33:42-48 value3)
      ])
    (TakeRight 34:2-83
      (TakeRight 34:2-31
        (Destructure 34:2-14
          (Identifier 34:2-8 value1)
          (Identifier 34:12-14 V1))
        (Destructure 35:2-14
          (Identifier 35:2-8 value2)
          (Identifier 35:12-14 V2)))
      (Return 36:2-49
        (Destructure 36:2-14
          (Identifier 36:2-8 value3)
          (Identifier 36:12-14 V3))
        (Object 37:2-32 [
          (ObjectPair (Identifier 37:3-7 Key1) (Identifier 37:9-11 V1))
          (ObjectPair (Identifier 37:13-17 Key2) (Identifier 37:19-21 V2))
          (ObjectPair (Identifier 37:23-27 Key3) (Identifier 37:29-31 V3))
        ]))))
  
  (DeclareGlobal 39:0-165
    (Function 39:0-65
      (Identifier 39:0-11 record3_sep) [
        (Identifier 39:12-16 Key1)
        (Identifier 39:18-24 value1)
        (Identifier 39:26-30 sep1)
        (Identifier 39:32-36 Key2)
        (Identifier 39:38-44 value2)
        (Identifier 39:46-50 sep2)
        (Identifier 39:52-56 Key3)
        (Identifier 39:58-64 value3)
      ])
    (TakeRight 40:2-97
      (TakeRight 40:2-45
        (TakeRight 40:2-38
          (TakeRight 40:2-21
            (Destructure 40:2-14
              (Identifier 40:2-8 value1)
              (Identifier 40:12-14 V1))
            (Identifier 40:17-21 sep1))
          (Destructure 41:2-14
            (Identifier 41:2-8 value2)
            (Identifier 41:12-14 V2)))
        (Identifier 41:17-21 sep2))
      (Return 42:2-49
        (Destructure 42:2-14
          (Identifier 42:2-8 value3)
          (Identifier 42:12-14 V3))
        (Object 43:2-32 [
          (ObjectPair (Identifier 43:3-7 Key1) (Identifier 43:9-11 V1))
          (ObjectPair (Identifier 43:13-17 Key2) (Identifier 43:19-21 V2))
          (ObjectPair (Identifier 43:23-27 Key3) (Identifier 43:29-31 V3))
        ]))))
