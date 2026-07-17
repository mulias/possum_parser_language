  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  (DeclareGlobal 1:0-33
    (Function 1:0-13
      (Identifier 1:0-7 Obj.Has) [
        (Identifier 1:8-9 O)
        (Identifier 1:11-12 K)
      ])
    (Destructure 1:16-33
      (Identifier 1:16-17 O)
      (Merge 1:21-33
        (Object 1:21-31 [
          (ObjectPair (Identifier 1:22-23 K) (Identifier 1:25-26 _))
        ])
        (Identifier 1:31-32 _))))
  
  (DeclareGlobal 3:0-37
    (Function 3:0-13
      (Identifier 3:0-7 Obj.Get) [
        (Identifier 3:8-9 O)
        (Identifier 3:11-12 K)
      ])
    (TakeRight 3:16-37
      (Destructure 3:16-33
        (Identifier 3:16-17 O)
        (Merge 3:21-33
          (Object 3:21-31 [
            (ObjectPair (Identifier 3:22-23 K) (Identifier 3:25-26 V))
          ])
          (Identifier 3:31-32 _)))
      (Identifier 3:36-37 V)))
  
  (DeclareGlobal 5:0-31
    (Function 5:0-16
      (Identifier 5:0-7 Obj.Put) [
        (Identifier 5:8-9 O)
        (Identifier 5:11-12 K)
        (Identifier 5:14-15 V)
      ])
    (Merge 5:19-31
      (Merge 5:19-20
        (Object 5:19-20 [])
        (Identifier 5:23-24 O))
      (Object 5:26-31 [
        (ObjectPair (Identifier 5:26-27 K) (Identifier 5:29-30 V))
      ])))
  
  (DeclareGlobal 7:0-35
    (Function 7:0-11
      (Identifier 7:0-8 Obj.Size) [
        (Identifier 7:9-10 O)
      ])
    (TakeRight 7:14-35
      (Destructure 7:14-31
        (Identifier 7:14-15 O)
        (Repeat 7:19-31
          (Object 7:20-26 [
            (ObjectPair (Identifier 7:21-22 _) (Identifier 7:24-25 _))
          ])
          (Identifier 7:29-30 S)))
      (Identifier 7:34-35 S)))
  
  (DeclareGlobal 9:0-30
    (Function 9:0-11
      (Identifier 9:0-8 Obj.Keys) [
        (Identifier 9:9-10 O)
      ])
    (Function 9:14-30
      (Identifier 9:14-23 _Obj.Keys) [
        (Identifier 9:24-25 O)
        (Array 9:27-30 [])
      ]))
  
  (DeclareGlobal 11:0-77
    (Function 11:0-17
      (Identifier 11:0-9 _Obj.Keys) [
        (Identifier 11:10-11 O)
        (Identifier 11:13-16 Acc)
      ])
    (Conditional 11:20-77
      (Destructure 11:20-40
        (Identifier 11:20-21 O)
        (Merge 11:25-40
          (Object 11:25-35 [
            (ObjectPair (Identifier 11:26-27 K) (Identifier 11:29-30 _))
          ])
          (Identifier 11:35-39 Rest)))
      (Function 11:43-71
        (Identifier 11:43-52 _Obj.Keys) [
          (Identifier 11:53-57 Rest)
          (Merge 11:59-70
            (Merge 11:59-60
              (Array 11:59-60 [])
              (Identifier 11:63-66 Acc))
            (Array 11:68-70 [
              (Identifier 11:68-69 K)
            ]))
        ])
      (Identifier 11:74-77 Acc)))
  
  (DeclareGlobal 13:0-34
    (Function 13:0-13
      (Identifier 13:0-10 Obj.Values) [
        (Identifier 13:11-12 O)
      ])
    (Function 13:16-34
      (Identifier 13:16-27 _Obj.Values) [
        (Identifier 13:28-29 O)
        (Array 13:31-34 [])
      ]))
  
  (DeclareGlobal 15:0-81
    (Function 15:0-19
      (Identifier 15:0-11 _Obj.Values) [
        (Identifier 15:12-13 O)
        (Identifier 15:15-18 Acc)
      ])
    (Conditional 15:22-81
      (Destructure 15:22-42
        (Identifier 15:22-23 O)
        (Merge 15:27-42
          (Object 15:27-37 [
            (ObjectPair (Identifier 15:28-29 _) (Identifier 15:31-32 V))
          ])
          (Identifier 15:37-41 Rest)))
      (Function 15:45-75
        (Identifier 15:45-56 _Obj.Values) [
          (Identifier 15:57-61 Rest)
          (Merge 15:63-74
            (Merge 15:63-64
              (Array 15:63-64 [])
              (Identifier 15:67-70 Acc))
            (Array 15:72-74 [
              (Identifier 15:72-73 V)
            ]))
        ])
      (Identifier 15:78-81 Acc)))
