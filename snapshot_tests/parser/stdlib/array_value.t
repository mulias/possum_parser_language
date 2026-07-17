  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  (DeclareGlobal 1:0-35
    (Function 1:0-14
      (Identifier 1:0-11 Array.First) [
        (Identifier 1:12-13 A)
      ])
    (TakeRight 1:17-35
      (Destructure 1:17-31
        (Identifier 1:17-18 A)
        (Merge 1:22-31
          (Array 1:22-23 [
            (Identifier 1:23-24 F)
          ])
          (Identifier 1:29-30 _)))
      (Identifier 1:34-35 F)))
  
  (DeclareGlobal 3:0-34
    (Function 3:0-13
      (Identifier 3:0-10 Array.Rest) [
        (Identifier 3:11-12 A)
      ])
    (TakeRight 3:16-34
      (Destructure 3:16-30
        (Identifier 3:16-17 A)
        (Merge 3:21-30
          (Array 3:21-22 [
            (Identifier 3:22-23 _)
          ])
          (Identifier 3:28-29 R)))
      (Identifier 3:33-34 R)))
  
  (DeclareGlobal 5:0-36
    (Function 5:0-15
      (Identifier 5:0-12 Array.Length) [
        (Identifier 5:13-14 A)
      ])
    (TakeRight 5:18-36
      (Destructure 5:18-32
        (Identifier 5:18-19 A)
        (Repeat 5:23-32
          (Array 5:24-27 [
            (Identifier 5:25-26 _)
          ])
          (Identifier 5:30-31 L)))
      (Identifier 5:35-36 L)))
  
  (DeclareGlobal 7:0-40
    (Function 7:0-16
      (Identifier 7:0-13 Array.Reverse) [
        (Identifier 7:14-15 A)
      ])
    (Function 7:19-40
      (Identifier 7:19-33 _Array.Reverse) [
        (Identifier 7:34-35 A)
        (Array 7:37-40 [])
      ]))
  
  (DeclareGlobal 9:0-94
    (Function 9:0-22
      (Identifier 9:0-14 _Array.Reverse) [
        (Identifier 9:15-16 A)
        (Identifier 9:18-21 Acc)
      ])
    (Conditional 10:2-69
      (Destructure 10:2-23
        (Identifier 10:2-3 A)
        (Merge 10:7-23
          (Array 10:7-8 [
            (Identifier 10:8-13 First)
          ])
          (Identifier 10:18-22 Rest)))
      (Function 10:26-63
        (Identifier 10:26-40 _Array.Reverse) [
          (Identifier 10:41-45 Rest)
          (Merge 10:47-62
            (Array 10:47-48 [
              (Identifier 10:48-53 First)
            ])
            (Identifier 10:58-61 Acc))
        ])
      (Identifier 10:66-69 Acc)))
  
  (DeclareGlobal 12:0-40
    (Function 12:0-16
      (Identifier 12:0-9 Array.Map) [
        (Identifier 12:10-11 A)
        (Identifier 12:13-15 Fn)
      ])
    (Function 12:19-40
      (Identifier 12:19-29 _Array.Map) [
        (Identifier 12:30-31 A)
        (Identifier 12:33-35 Fn)
        (Array 12:37-40 [])
      ]))
  
  (DeclareGlobal 14:0-98
    (Function 14:0-22
      (Identifier 14:0-10 _Array.Map) [
        (Identifier 14:11-12 A)
        (Identifier 14:14-16 Fn)
        (Identifier 14:18-21 Acc)
      ])
    (Conditional 15:2-73
      (Destructure 15:2-23
        (Identifier 15:2-3 A)
        (Merge 15:7-23
          (Array 15:7-8 [
            (Identifier 15:8-13 First)
          ])
          (Identifier 15:18-22 Rest)))
      (Function 15:26-67
        (Identifier 15:26-36 _Array.Map) [
          (Identifier 15:37-41 Rest)
          (Identifier 15:43-45 Fn)
          (Merge 15:47-66
            (Merge 15:47-48
              (Array 15:47-48 [])
              (Identifier 15:51-54 Acc))
            (Array 15:56-66 [
              (Function 15:56-65
                (Identifier 15:56-58 Fn) [
                  (Identifier 15:59-64 First)
                ])
            ]))
        ])
      (Identifier 15:70-73 Acc)))
  
  (DeclareGlobal 17:0-50
    (Function 17:0-21
      (Identifier 17:0-12 Array.Filter) [
        (Identifier 17:13-14 A)
        (Identifier 17:16-20 Pred)
      ])
    (Function 17:24-50
      (Identifier 17:24-37 _Array.Filter) [
        (Identifier 17:38-39 A)
        (Identifier 17:41-45 Pred)
        (Array 17:47-50 [])
      ]))
  
  (DeclareGlobal 19:0-128
    (Function 19:0-27
      (Identifier 19:0-13 _Array.Filter) [
        (Identifier 19:14-15 A)
        (Identifier 19:17-21 Pred)
        (Identifier 19:23-26 Acc)
      ])
    (Conditional 20:2-98
      (Destructure 20:2-23
        (Identifier 20:2-3 A)
        (Merge 20:7-23
          (Array 20:7-8 [
            (Identifier 20:8-13 First)
          ])
          (Identifier 20:18-22 Rest)))
      (Function 21:2-64
        (Identifier 21:2-15 _Array.Filter) [
          (Identifier 21:16-20 Rest)
          (Identifier 21:22-26 Pred)
          (Conditional 21:28-63
            (Function 21:28-39
              (Identifier 21:28-32 Pred) [
                (Identifier 21:33-38 First)
              ])
            (Merge 21:42-57
              (Merge 21:42-43
                (Array 21:42-43 [])
                (Identifier 21:46-49 Acc))
              (Array 21:51-57 [
                (Identifier 21:51-56 First)
              ]))
            (Identifier 21:60-63 Acc))
        ])
      (Identifier 22:2-5 Acc)))
  
  (DeclareGlobal 24:0-50
    (Function 24:0-21
      (Identifier 24:0-12 Array.Reject) [
        (Identifier 24:13-14 A)
        (Identifier 24:16-20 Pred)
      ])
    (Function 24:24-50
      (Identifier 24:24-37 _Array.Reject) [
        (Identifier 24:38-39 A)
        (Identifier 24:41-45 Pred)
        (Array 24:47-50 [])
      ]))
  
  (DeclareGlobal 26:0-128
    (Function 26:0-27
      (Identifier 26:0-13 _Array.Reject) [
        (Identifier 26:14-15 A)
        (Identifier 26:17-21 Pred)
        (Identifier 26:23-26 Acc)
      ])
    (Conditional 27:2-98
      (Destructure 27:2-23
        (Identifier 27:2-3 A)
        (Merge 27:7-23
          (Array 27:7-8 [
            (Identifier 27:8-13 First)
          ])
          (Identifier 27:18-22 Rest)))
      (Function 28:2-64
        (Identifier 28:2-15 _Array.Reject) [
          (Identifier 28:16-20 Rest)
          (Identifier 28:22-26 Pred)
          (Conditional 28:28-63
            (Function 28:28-39
              (Identifier 28:28-32 Pred) [
                (Identifier 28:33-38 First)
              ])
            (Identifier 28:42-45 Acc)
            (Merge 28:48-63
              (Merge 28:48-49
                (Array 28:48-49 [])
                (Identifier 28:52-55 Acc))
              (Array 28:57-63 [
                (Identifier 28:57-62 First)
              ])))
        ])
      (Identifier 29:2-5 Acc)))
  
  (DeclareGlobal 31:0-38
    (Function 31:0-14
      (Identifier 31:0-11 Array.Merge) [
        (Identifier 31:12-13 A)
      ])
    (Function 31:17-38
      (Identifier 31:17-29 _Array.Merge) [
        (Identifier 31:30-31 A)
        (Null 31:33-37)
      ]))
  
  (DeclareGlobal 33:0-86
    (Function 33:0-20
      (Identifier 33:0-12 _Array.Merge) [
        (Identifier 33:13-14 A)
        (Identifier 33:16-19 Acc)
      ])
    (Conditional 34:2-63
      (Destructure 34:2-23
        (Identifier 34:2-3 A)
        (Merge 34:7-23
          (Array 34:7-8 [
            (Identifier 34:8-13 First)
          ])
          (Identifier 34:18-22 Rest)))
      (Function 34:26-57
        (Identifier 34:26-38 _Array.Merge) [
          (Identifier 34:39-43 Rest)
          (Merge 34:45-56
            (Identifier 34:45-48 Acc)
            (Identifier 34:51-56 First))
        ])
      (Identifier 34:60-63 Acc)))
  
  (DeclareGlobal 36:0-52
    (Function 36:0-21
      (Identifier 36:0-14 Array.MapMerge) [
        (Identifier 36:15-16 A)
        (Identifier 36:18-20 Fn)
      ])
    (Function 36:24-52
      (Identifier 36:24-39 _Array.MapMerge) [
        (Identifier 36:40-41 A)
        (Identifier 36:43-45 Fn)
        (Null 36:47-51)
      ]))
  
  (DeclareGlobal 38:0-104
    (Function 38:0-27
      (Identifier 38:0-15 _Array.MapMerge) [
        (Identifier 38:16-17 A)
        (Identifier 38:19-21 Fn)
        (Identifier 38:23-26 Acc)
      ])
    (Conditional 39:2-74
      (Destructure 39:2-23
        (Identifier 39:2-3 A)
        (Merge 39:7-23
          (Array 39:7-8 [
            (Identifier 39:8-13 First)
          ])
          (Identifier 39:18-22 Rest)))
      (Function 39:26-68
        (Identifier 39:26-41 _Array.MapMerge) [
          (Identifier 39:42-46 Rest)
          (Identifier 39:48-50 Fn)
          (Merge 39:52-67
            (Identifier 39:52-55 Acc)
            (Function 39:58-67
              (Identifier 39:58-60 Fn) [
                (Identifier 39:61-66 First)
              ]))
        ])
      (Identifier 39:71-74 Acc)))
  
  (DeclareGlobal 41:0-97
    (Function 41:0-24
      (Identifier 41:0-12 Array.Reduce) [
        (Identifier 41:13-14 A)
        (Identifier 41:16-18 Fn)
        (Identifier 41:20-23 Acc)
      ])
    (Conditional 42:2-70
      (Destructure 42:2-23
        (Identifier 42:2-3 A)
        (Merge 42:7-23
          (Array 42:7-8 [
            (Identifier 42:8-13 First)
          ])
          (Identifier 42:18-22 Rest)))
      (Function 42:26-64
        (Identifier 42:26-38 Array.Reduce) [
          (Identifier 42:39-43 Rest)
          (Identifier 42:45-47 Fn)
          (Function 42:49-63
            (Identifier 42:49-51 Fn) [
              (Identifier 42:52-55 Acc)
              (Identifier 42:57-62 First)
            ])
        ])
      (Identifier 42:67-70 Acc)))
  
  (DeclareGlobal 44:0-54
    (Function 44:0-23
      (Identifier 44:0-15 Array.ZipObject) [
        (Identifier 44:16-18 Ks)
        (Identifier 44:20-22 Vs)
      ])
    (Function 44:26-54
      (Identifier 44:26-42 _Array.ZipObject) [
        (Identifier 44:43-45 Ks)
        (Identifier 44:47-49 Vs)
        (Object 44:51-54 [])
      ]))
  
  (DeclareGlobal 46:0-138
    (Function 46:0-29
      (Identifier 46:0-16 _Array.ZipObject) [
        (Identifier 46:17-19 Ks)
        (Identifier 46:21-23 Vs)
        (Identifier 46:25-28 Acc)
      ])
    (Conditional 47:2-106
      (TakeRight 47:2-45
        (Destructure 47:2-22
          (Identifier 47:2-4 Ks)
          (Merge 47:8-22
            (Array 47:8-9 [
              (Identifier 47:9-10 K)
            ])
            (Identifier 47:15-21 KsRest)))
        (Destructure 47:25-45
          (Identifier 47:25-27 Vs)
          (Merge 47:31-45
            (Array 47:31-32 [
              (Identifier 47:32-33 V)
            ])
            (Identifier 47:38-44 VsRest))))
      (Function 48:2-50
        (Identifier 48:2-18 _Array.ZipObject) [
          (Identifier 48:19-25 KsRest)
          (Identifier 48:27-33 VsRest)
          (Merge 48:35-49
            (Merge 48:35-36
              (Object 48:35-36 [])
              (Identifier 48:39-42 Acc))
            (Object 48:44-49 [
              (ObjectPair (Identifier 48:44-45 K) (Identifier 48:47-48 V))
            ]))
        ])
      (Identifier 49:2-5 Acc)))
  
  (DeclareGlobal 51:0-52
    (Function 51:0-22
      (Identifier 51:0-14 Array.ZipPairs) [
        (Identifier 51:15-17 A1)
        (Identifier 51:19-21 A2)
      ])
    (Function 51:25-52
      (Identifier 51:25-40 _Array.ZipPairs) [
        (Identifier 51:41-43 A1)
        (Identifier 51:45-47 A2)
        (Array 51:49-52 [])
      ]))
  
  (DeclareGlobal 53:0-154
    (Function 53:0-28
      (Identifier 53:0-15 _Array.ZipPairs) [
        (Identifier 53:16-18 A1)
        (Identifier 53:20-22 A2)
        (Identifier 53:24-27 Acc)
      ])
    (Conditional 54:2-123
      (TakeRight 54:2-53
        (Destructure 54:2-26
          (Identifier 54:2-4 A1)
          (Merge 54:8-26
            (Array 54:8-9 [
              (Identifier 54:9-15 First1)
            ])
            (Identifier 54:20-25 Rest1)))
        (Destructure 54:29-53
          (Identifier 54:29-31 A2)
          (Merge 54:35-53
            (Array 54:35-36 [
              (Identifier 54:36-42 First2)
            ])
            (Identifier 54:47-52 Rest2))))
      (Function 55:2-59
        (Identifier 55:2-17 _Array.ZipPairs) [
          (Identifier 55:18-23 Rest1)
          (Identifier 55:25-30 Rest2)
          (Merge 55:32-58
            (Merge 55:32-33
              (Array 55:32-33 [])
              (Identifier 55:36-39 Acc))
            (Array 55:41-58 [
              (Array 55:41-57 [
                (Identifier 55:42-48 First1)
                (Identifier 55:50-56 First2)
              ])
            ]))
        ])
      (Identifier 56:2-5 Acc)))
  
  (DeclareGlobal 58:0-42
    (Function 58:0-24
      (Identifier 58:0-13 Array.AppendN) [
        (Identifier 58:14-15 A)
        (Identifier 58:17-20 Val)
        (Identifier 58:22-23 N)
      ])
    (Merge 58:27-42
      (Identifier 58:27-28 A)
      (Repeat 58:31-42
        (Array 58:32-37 [
          (Identifier 58:33-36 Val)
        ])
        (Identifier 58:40-41 N))))
  
  (DeclareGlobal 60:0-44
    (Function 60:0-18
      (Identifier 60:0-15 Table.Transpose) [
        (Identifier 60:16-17 T)
      ])
    (Function 60:21-44
      (Identifier 60:21-37 _Table.Transpose) [
        (Identifier 60:38-39 T)
        (Array 60:41-44 [])
      ]))
  
  (DeclareGlobal 62:0-168
    (Function 62:0-24
      (Identifier 62:0-16 _Table.Transpose) [
        (Identifier 62:17-18 T)
        (Identifier 62:20-23 Acc)
      ])
    (Conditional 63:2-141
      (TakeRight 63:2-77
        (Destructure 63:2-38
          (Function 63:2-23
            (Identifier 63:2-20 _Table.FirstPerRow) [
              (Identifier 63:21-22 T)
            ])
          (Identifier 63:27-38 FirstPerRow))
        (Destructure 64:2-36
          (Function 64:2-22
            (Identifier 64:2-19 _Table.RestPerRow) [
              (Identifier 64:20-21 T)
            ])
          (Identifier 64:26-36 RestPerRow)))
      (Function 65:2-53
        (Identifier 65:2-18 _Table.Transpose) [
          (Identifier 65:19-29 RestPerRow)
          (Merge 65:31-52
            (Merge 65:31-32
              (Array 65:31-32 [])
              (Identifier 65:35-38 Acc))
            (Array 65:40-52 [
              (Identifier 65:40-51 FirstPerRow)
            ]))
        ])
      (Identifier 66:2-5 Acc)))
  
  (DeclareGlobal 68:0-115
    (Function 68:0-21
      (Identifier 68:0-18 _Table.FirstPerRow) [
        (Identifier 68:19-20 T)
      ])
    (TakeRight 69:2-91
      (TakeRight 69:2-48
        (Destructure 69:2-21
          (Identifier 69:2-3 T)
          (Merge 69:7-21
            (Array 69:7-8 [
              (Identifier 69:8-11 Row)
            ])
            (Identifier 69:16-20 Rest)))
        (Destructure 69:24-48
          (Identifier 69:24-27 Row)
          (Merge 69:31-48
            (Array 69:31-32 [
              (Identifier 69:32-41 VeryFirst)
            ])
            (Identifier 69:46-47 _))))
      (Function 70:2-40
        (Identifier 70:2-21 __Table.FirstPerRow) [
          (Identifier 70:22-26 Rest)
          (Array 70:28-39 [
            (Identifier 70:29-38 VeryFirst)
          ])
        ])))
  
  (DeclareGlobal 72:0-129
    (Function 72:0-27
      (Identifier 72:0-19 __Table.FirstPerRow) [
        (Identifier 72:20-21 T)
        (Identifier 72:23-26 Acc)
      ])
    (Conditional 73:2-99
      (TakeRight 73:2-44
        (Destructure 73:2-21
          (Identifier 73:2-3 T)
          (Merge 73:7-21
            (Array 73:7-8 [
              (Identifier 73:8-11 Row)
            ])
            (Identifier 73:16-20 Rest)))
        (Destructure 73:24-44
          (Identifier 73:24-27 Row)
          (Merge 73:31-44
            (Array 73:31-32 [
              (Identifier 73:32-37 First)
            ])
            (Identifier 73:42-43 _))))
      (Function 74:2-44
        (Identifier 74:2-21 __Table.FirstPerRow) [
          (Identifier 74:22-26 Rest)
          (Merge 74:28-43
            (Merge 74:28-29
              (Array 74:28-29 [])
              (Identifier 74:32-35 Acc))
            (Array 74:37-43 [
              (Identifier 74:37-42 First)
            ]))
        ])
      (Identifier 75:2-5 Acc)))
  
  (DeclareGlobal 77:0-48
    (Function 77:0-20
      (Identifier 77:0-17 _Table.RestPerRow) [
        (Identifier 77:18-19 T)
      ])
    (Function 77:23-48
      (Identifier 77:23-41 __Table.RestPerRow) [
        (Identifier 77:42-43 T)
        (Array 77:45-48 [])
      ]))
  
  (DeclareGlobal 79:0-188
    (Function 79:0-26
      (Identifier 79:0-18 __Table.RestPerRow) [
        (Identifier 79:19-20 T)
        (Identifier 79:22-25 Acc)
      ])
    (Conditional 80:2-159
      (Destructure 80:2-21
        (Identifier 80:2-3 T)
        (Merge 80:7-21
          (Array 80:7-8 [
            (Identifier 80:8-11 Row)
          ])
          (Identifier 80:16-20 Rest)))
      (Conditional 80:24-151
        (Destructure 81:4-26
          (Identifier 81:4-7 Row)
          (Merge 81:11-26
            (Array 81:11-12 [
              (Identifier 81:12-13 _)
            ])
            (Identifier 81:18-25 RowRest)))
        (Function 82:4-47
          (Identifier 82:4-22 __Table.RestPerRow) [
            (Identifier 82:23-27 Rest)
            (Merge 82:29-46
              (Merge 82:29-30
                (Array 82:29-30 [])
                (Identifier 82:33-36 Acc))
              (Array 82:38-46 [
                (Identifier 82:38-45 RowRest)
              ]))
          ])
        (Function 83:4-42
          (Identifier 83:4-22 __Table.RestPerRow) [
            (Identifier 83:23-27 Rest)
            (Merge 83:29-41
              (Merge 83:29-30
                (Array 83:29-30 [])
                (Identifier 83:33-36 Acc))
              (Array 83:38-41 [
                (Array 83:38-41 [])
              ]))
          ]))
      (Identifier 85:2-5 Acc)))
  
  (DeclareGlobal 87:0-71
    (Function 87:0-24
      (Identifier 87:0-21 Table.RotateClockwise) [
        (Identifier 87:22-23 T)
      ])
    (Function 87:27-71
      (Identifier 87:27-36 Array.Map) [
        (Function 87:37-55
          (Identifier 87:37-52 Table.Transpose) [
            (Identifier 87:53-54 T)
          ])
        (Identifier 87:57-70 Array.Reverse)
      ]))
  
  (DeclareGlobal 89:0-67
    (Function 89:0-31
      (Identifier 89:0-28 Table.RotateCounterClockwise) [
        (Identifier 89:29-30 T)
      ])
    (Function 89:34-67
      (Identifier 89:34-47 Array.Reverse) [
        (Function 89:48-66
          (Identifier 89:48-63 Table.Transpose) [
            (Identifier 89:64-65 T)
          ])
      ]))
  
  (DeclareGlobal 91:0-60
    (Function 91:0-26
      (Identifier 91:0-16 Table.ZipObjects) [
        (Identifier 91:17-19 Ks)
        (Identifier 91:21-25 Rows)
      ])
    (Function 91:29-60
      (Identifier 91:29-46 _Table.ZipObjects) [
        (Identifier 91:47-49 Ks)
        (Identifier 91:51-55 Rows)
        (Array 91:57-60 [])
      ]))
  
  (DeclareGlobal 93:0-135
    (Function 93:0-32
      (Identifier 93:0-17 _Table.ZipObjects) [
        (Identifier 93:18-20 Ks)
        (Identifier 93:22-26 Rows)
        (Identifier 93:28-31 Acc)
      ])
    (Conditional 94:2-100
      (Destructure 94:2-24
        (Identifier 94:2-6 Rows)
        (Merge 94:10-24
          (Array 94:10-11 [
            (Identifier 94:11-14 Row)
          ])
          (Identifier 94:19-23 Rest)))
      (Function 95:2-65
        (Identifier 95:2-19 _Table.ZipObjects) [
          (Identifier 95:20-22 Ks)
          (Identifier 95:24-28 Rest)
          (Merge 95:30-64
            (Merge 95:30-31
              (Array 95:30-31 [])
              (Identifier 95:34-37 Acc))
            (Array 95:39-64 [
              (Function 95:39-63
                (Identifier 95:39-54 Array.ZipObject) [
                  (Identifier 95:55-57 Ks)
                  (Identifier 95:59-62 Row)
                ])
            ]))
        ])
      (Identifier 96:2-5 Acc)))
