  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array.possum -i '' --no-stdlib
  (Import 1:0-19 stdlib/combinator private)
  
  (Import 2:0-14 stdlib/Array private)
  
  (Import 3:0-15 stdlib/Number private)
  
  (DeclareGlobal 5:0-32
    (Function 5:0-11
      (Identifier 5:0-5 array) [
        (Identifier 5:6-10 elem)
      ])
    (Repeat 5:14-32
      (Function 5:14-26
        (Identifier 5:14-20 tuple1) [
          (Identifier 5:21-25 elem)
        ])
      (Range 5:29-32 (NumberString 5:29-30 1) ())))
  
  (DeclareGlobal 7:0-64
    (Function 7:0-20
      (Identifier 7:0-9 array_sep) [
        (Identifier 7:10-14 elem)
        (Identifier 7:16-19 sep)
      ])
    (Merge 7:23-64
      (Function 7:23-35
        (Identifier 7:23-29 tuple1) [
          (Identifier 7:30-34 elem)
        ])
      (Repeat 7:38-64
        (Function 7:39-57
          (Identifier 7:39-45 tuple1) [
            (TakeRight 7:46-56
              (Identifier 7:46-49 sep)
              (Identifier 7:52-56 elem))
          ])
        (Range 7:60-63 (NumberString 7:60-61 0) ()))))
  
  (DeclareGlobal 9:0-71
    (Function 9:0-23
      (Identifier 9:0-11 array_until) [
        (Identifier 9:12-16 elem)
        (Identifier 9:18-22 stop)
      ])
    (TakeLeft 9:26-71
      (Repeat 9:26-58
        (Function 9:26-52
          (Identifier 9:26-32 unless) [
            (Function 9:33-45
              (Identifier 9:33-39 tuple1) [
                (Identifier 9:40-44 elem)
              ])
            (Identifier 9:47-51 stop)
          ])
        (Range 9:55-58 (NumberString 9:55-56 1) ()))
      (Function 9:61-71
        (Identifier 9:61-65 peek) [
          (Identifier 9:66-70 stop)
        ])))
  
  (DeclareGlobal 11:0-44
    (Function 11:0-17
      (Identifier 11:0-11 maybe_array) [
        (Identifier 11:12-16 elem)
      ])
    (Function 11:20-44
      (Identifier 11:20-27 default) [
        (Function 11:28-39
          (Identifier 11:28-33 array) [
            (Identifier 11:34-38 elem)
          ])
        (Array 11:41-44 [])
      ]))
  
  (DeclareGlobal 13:0-62
    (Function 13:0-26
      (Identifier 13:0-15 maybe_array_sep) [
        (Identifier 13:16-20 elem)
        (Identifier 13:22-25 sep)
      ])
    (Function 13:29-62
      (Identifier 13:29-36 default) [
        (Function 13:37-57
          (Identifier 13:37-46 array_sep) [
            (Identifier 13:47-51 elem)
            (Identifier 13:53-56 sep)
          ])
        (Array 13:59-62 [])
      ]))
  
  (DeclareGlobal 15:0-37
    (Function 15:0-12
      (Identifier 15:0-6 tuple1) [
        (Identifier 15:7-11 elem)
      ])
    (Return 15:16-37
      (Destructure 15:16-28
        (Identifier 15:16-20 elem)
        (Identifier 15:24-28 Elem))
      (Array 15:31-37 [
        (Identifier 15:32-36 Elem)
      ])))
  
  (DeclareGlobal 17:0-59
    (Function 17:0-20
      (Identifier 17:0-6 tuple2) [
        (Identifier 17:7-12 elem1)
        (Identifier 17:14-19 elem2)
      ])
    (TakeRight 17:23-59
      (Destructure 17:23-34
        (Identifier 17:23-28 elem1)
        (Identifier 17:32-34 E1))
      (Return 17:37-59
        (Destructure 17:37-48
          (Identifier 17:37-42 elem2)
          (Identifier 17:46-48 E2))
        (Array 17:51-59 [
          (Identifier 17:52-54 E1)
          (Identifier 17:56-58 E2)
        ]))))
  
  (DeclareGlobal 19:0-74
    (Function 19:0-29
      (Identifier 19:0-10 tuple2_sep) [
        (Identifier 19:11-16 elem1)
        (Identifier 19:18-21 sep)
        (Identifier 19:23-28 elem2)
      ])
    (TakeRight 19:32-74
      (TakeRight 19:32-49
        (Destructure 19:32-43
          (Identifier 19:32-37 elem1)
          (Identifier 19:41-43 E1))
        (Identifier 19:46-49 sep))
      (Return 19:52-74
        (Destructure 19:52-63
          (Identifier 19:52-57 elem2)
          (Identifier 19:61-63 E2))
        (Array 19:66-74 [
          (Identifier 19:67-69 E1)
          (Identifier 19:71-73 E2)
        ]))))
  
  (DeclareGlobal 21:0-92
    (Function 21:0-27
      (Identifier 21:0-6 tuple3) [
        (Identifier 21:7-12 elem1)
        (Identifier 21:14-19 elem2)
        (Identifier 21:21-26 elem3)
      ])
    (TakeRight 22:2-62
      (TakeRight 22:2-29
        (Destructure 22:2-13
          (Identifier 22:2-7 elem1)
          (Identifier 22:11-13 E1))
        (Destructure 23:2-13
          (Identifier 23:2-7 elem2)
          (Identifier 23:11-13 E2)))
      (Return 24:2-30
        (Destructure 24:2-13
          (Identifier 24:2-7 elem3)
          (Identifier 24:11-13 E3))
        (Array 25:2-14 [
          (Identifier 25:3-5 E1)
          (Identifier 25:7-9 E2)
          (Identifier 25:11-13 E3)
        ]))))
  
  (DeclareGlobal 27:0-122
    (Function 27:0-43
      (Identifier 27:0-10 tuple3_sep) [
        (Identifier 27:11-16 elem1)
        (Identifier 27:18-22 sep1)
        (Identifier 27:24-29 elem2)
        (Identifier 27:31-35 sep2)
        (Identifier 27:37-42 elem3)
      ])
    (TakeRight 28:2-76
      (TakeRight 28:2-43
        (TakeRight 28:2-36
          (TakeRight 28:2-20
            (Destructure 28:2-13
              (Identifier 28:2-7 elem1)
              (Identifier 28:11-13 E1))
            (Identifier 28:16-20 sep1))
          (Destructure 29:2-13
            (Identifier 29:2-7 elem2)
            (Identifier 29:11-13 E2)))
        (Identifier 29:16-20 sep2))
      (Return 30:2-30
        (Destructure 30:2-13
          (Identifier 30:2-7 elem3)
          (Identifier 30:11-13 E3))
        (Array 31:2-14 [
          (Identifier 31:3-5 E1)
          (Identifier 31:7-9 E2)
          (Identifier 31:11-13 E3)
        ]))))
  
  (DeclareGlobal 33:0-33
    (Function 33:0-14
      (Identifier 33:0-5 tuple) [
        (Identifier 33:6-10 elem)
        (Identifier 33:12-13 N)
      ])
    (Repeat 33:17-33
      (Function 33:17-29
        (Identifier 33:17-23 tuple1) [
          (Identifier 33:24-28 elem)
        ])
      (Identifier 33:32-33 N)))
  
  (DeclareGlobal 35:0-71
    (Function 35:0-23
      (Identifier 35:0-9 tuple_sep) [
        (Identifier 35:10-14 elem)
        (Identifier 35:16-19 sep)
        (Identifier 35:21-22 N)
      ])
    (Merge 35:26-71
      (Function 35:26-38
        (Identifier 35:26-32 tuple1) [
          (Identifier 35:33-37 elem)
        ])
      (Repeat 35:41-71
        (Function 35:42-60
          (Identifier 35:42-48 tuple1) [
            (TakeRight 35:49-59
              (Identifier 35:49-52 sep)
              (Identifier 35:55-59 elem))
          ])
        (NumberSubtract 35:63-70
          (Identifier 35:64-65 N)
          (NumberString 35:68-69 1)))))
  
  (DeclareGlobal 37:0-120
    (Function 37:0-28
      (Identifier 37:0-4 rows) [
        (Identifier 37:5-9 elem)
        (Identifier 37:11-18 col_sep)
        (Identifier 37:20-27 row_sep)
      ])
    (Merge 38:2-89
      (Function 38:2-34
        (Identifier 38:2-8 tuple1) [
          (Function 38:9-33
            (Identifier 38:9-18 array_sep) [
              (Identifier 38:19-23 elem)
              (Identifier 38:25-32 col_sep)
            ])
        ])
      (Repeat 39:2-52
        (Function 39:3-45
          (Identifier 39:3-9 tuple1) [
            (TakeRight 39:10-44
              (Identifier 39:10-17 row_sep)
              (Function 39:20-44
                (Identifier 39:20-29 array_sep) [
                  (Identifier 39:30-34 elem)
                  (Identifier 39:36-43 col_sep)
                ]))
          ])
        (Range 39:48-51 (NumberString 39:48-49 0) ()))))
  
  (DeclareGlobal 41:0-194
    (Function 41:0-40
      (Identifier 41:0-11 rows_padded) [
        (Identifier 41:12-16 elem)
        (Identifier 41:18-25 col_sep)
        (Identifier 41:27-34 row_sep)
        (Identifier 41:36-39 Pad)
      ])
    (TakeRight 42:2-151
      (TakeRight 42:2-79
        (Destructure 42:2-61
          (Function 42:2-43
            (Identifier 42:2-6 peek) [
              (Function 42:7-42
                (Identifier 42:7-18 _dimensions) [
                  (Identifier 42:19-23 elem)
                  (Identifier 42:25-32 col_sep)
                  (Identifier 42:34-41 row_sep)
                ])
            ])
          (Array 42:47-61 [
            (Identifier 42:48-57 MaxRowLen)
            (Identifier 42:59-60 _)
          ]))
        (Destructure 43:2-15
          (Identifier 43:2-6 elem)
          (Identifier 43:10-15 First)))
      (Function 43:18-87
        (Identifier 43:18-30 _rows_padded) [
          (Identifier 43:31-35 elem)
          (Identifier 43:37-44 col_sep)
          (Identifier 43:46-53 row_sep)
          (Identifier 43:55-58 Pad)
          (ValueLabel 43:60-61 (NumberString 43:61-62 1))
          (Identifier 43:64-73 MaxRowLen)
          (Array 43:75-82 [
            (Identifier 43:76-81 First)
          ])
          (Array 43:84-87 [])
        ])))
  
  (DeclareGlobal 45:0-442
    (Function 45:0-77
      (Identifier 45:0-12 _rows_padded) [
        (Identifier 45:13-17 elem)
        (Identifier 45:19-26 col_sep)
        (Identifier 45:28-35 row_sep)
        (Identifier 45:37-40 Pad)
        (Identifier 45:42-48 RowLen)
        (Identifier 45:50-59 MaxRowLen)
        (Identifier 45:61-67 AccRow)
        (Identifier 45:69-76 AccRows)
      ])
    (Conditional 46:2-362
      (Destructure 46:2-24
        (TakeRight 46:2-16
          (Identifier 46:2-9 col_sep)
          (Identifier 46:12-16 elem))
        (Identifier 46:20-24 Elem))
      (Function 47:2-99
        (Identifier 47:2-14 _rows_padded) [
          (Identifier 47:15-19 elem)
          (Identifier 47:21-28 col_sep)
          (Identifier 47:30-37 row_sep)
          (Identifier 47:39-42 Pad)
          (Function 47:44-59
            (Identifier 47:44-51 Num.Inc) [
              (Identifier 47:52-58 RowLen)
            ])
          (Identifier 47:61-70 MaxRowLen)
          (Merge 47:72-89
            (Merge 47:72-73
              (Array 47:72-73 [])
              (Identifier 47:76-82 AccRow))
            (Array 47:84-89 [
              (Identifier 47:84-88 Elem)
            ]))
          (Identifier 47:91-98 AccRows)
        ])
      (Conditional 48:2-233
        (Destructure 48:2-27
          (TakeRight 48:2-16
            (Identifier 48:2-9 row_sep)
            (Identifier 48:12-16 elem))
          (Identifier 48:20-27 NextRow))
        (Function 49:2-131
          (Identifier 49:2-14 _rows_padded) [
            (Identifier 49:15-19 elem)
            (Identifier 49:21-28 col_sep)
            (Identifier 49:30-37 row_sep)
            (Identifier 49:39-42 Pad)
            (ValueLabel 49:44-45 (NumberString 49:45-46 1))
            (Identifier 49:48-57 MaxRowLen)
            (Array 49:59-68 [
              (Identifier 49:60-67 NextRow)
            ])
            (Merge 49:70-130
              (Merge 49:70-71
                (Array 49:70-71 [])
                (Identifier 49:74-81 AccRows))
              (Array 49:83-130 [
                (Function 49:83-129
                  (Identifier 49:83-96 Array.AppendN) [
                    (Identifier 49:97-103 AccRow)
                    (Identifier 49:105-108 Pad)
                    (NumberSubtract 49:110-128
                      (Identifier 49:110-119 MaxRowLen)
                      (Identifier 49:122-128 RowLen))
                  ])
              ]))
          ])
        (Function 50:2-69
          (Identifier 50:2-7 const) [
            (Merge 50:8-68
              (Merge 50:8-9
                (Array 50:8-9 [])
                (Identifier 50:12-19 AccRows))
              (Array 50:21-68 [
                (Function 50:21-67
                  (Identifier 50:21-34 Array.AppendN) [
                    (Identifier 50:35-41 AccRow)
                    (Identifier 50:43-46 Pad)
                    (NumberSubtract 50:48-66
                      (Identifier 50:48-57 MaxRowLen)
                      (Identifier 50:60-66 RowLen))
                  ])
              ]))
          ]))))
  
  (DeclareGlobal 52:0-95
    (Function 52:0-35
      (Identifier 52:0-11 _dimensions) [
        (Identifier 52:12-16 elem)
        (Identifier 52:18-25 col_sep)
        (Identifier 52:27-34 row_sep)
      ])
    (TakeRight 53:2-57
      (Identifier 53:2-6 elem)
      (Function 53:9-57
        (Identifier 53:9-21 __dimensions) [
          (Identifier 53:22-26 elem)
          (Identifier 53:28-35 col_sep)
          (Identifier 53:37-44 row_sep)
          (ValueLabel 53:46-47 (NumberString 53:47-48 1))
          (ValueLabel 53:50-51 (NumberString 53:51-52 1))
          (ValueLabel 53:54-55 (NumberString 53:55-56 0))
        ])))
  
  (DeclareGlobal 55:0-316
    (Function 55:0-63
      (Identifier 55:0-12 __dimensions) [
        (Identifier 55:13-17 elem)
        (Identifier 55:19-26 col_sep)
        (Identifier 55:28-35 row_sep)
        (Identifier 55:37-43 RowLen)
        (Identifier 55:45-51 ColLen)
        (Identifier 55:53-62 MaxRowLen)
      ])
    (Conditional 56:2-250
      (TakeRight 56:2-16
        (Identifier 56:2-9 col_sep)
        (Identifier 56:12-16 elem))
      (Function 57:2-74
        (Identifier 57:2-14 __dimensions) [
          (Identifier 57:15-19 elem)
          (Identifier 57:21-28 col_sep)
          (Identifier 57:30-37 row_sep)
          (Function 57:39-54
            (Identifier 57:39-46 Num.Inc) [
              (Identifier 57:47-53 RowLen)
            ])
          (Identifier 57:56-62 ColLen)
          (Identifier 57:64-73 MaxRowLen)
        ])
      (Conditional 58:2-154
        (TakeRight 58:2-16
          (Identifier 58:2-9 row_sep)
          (Identifier 58:12-16 elem))
        (Function 59:2-87
          (Identifier 59:2-14 __dimensions) [
            (Identifier 59:15-19 elem)
            (Identifier 59:21-28 col_sep)
            (Identifier 59:30-37 row_sep)
            (ValueLabel 59:39-40 (NumberString 59:40-41 1))
            (Function 59:43-58
              (Identifier 59:43-50 Num.Inc) [
                (Identifier 59:51-57 ColLen)
              ])
            (Function 59:60-86
              (Identifier 59:60-67 Num.Max) [
                (Identifier 59:68-74 RowLen)
                (Identifier 59:76-85 MaxRowLen)
              ])
          ])
        (Function 60:2-45
          (Identifier 60:2-7 const) [
            (Array 60:8-44 [
              (Function 60:9-35
                (Identifier 60:9-16 Num.Max) [
                  (Identifier 60:17-23 RowLen)
                  (Identifier 60:25-34 MaxRowLen)
                ])
              (Identifier 60:37-43 ColLen)
            ])
          ]))))
  
  (DeclareGlobal 62:0-98
    (Function 62:0-31
      (Identifier 62:0-7 columns) [
        (Identifier 62:8-12 elem)
        (Identifier 62:14-21 col_sep)
        (Identifier 62:23-30 row_sep)
      ])
    (Return 63:2-64
      (Destructure 63:2-38
        (Function 63:2-30
          (Identifier 63:2-6 rows) [
            (Identifier 63:7-11 elem)
            (Identifier 63:13-20 col_sep)
            (Identifier 63:22-29 row_sep)
          ])
        (Identifier 63:34-38 Rows))
      (Function 64:2-23
        (Identifier 64:2-17 Table.Transpose) [
          (Identifier 64:18-22 Rows)
        ])))
  
  (DeclareGlobal 66:0-14
    (Identifier 66:0-4 cols)
    (Identifier 66:7-14 columns))
  
  (DeclareGlobal 68:0-122
    (Function 68:0-43
      (Identifier 68:0-14 columns_padded) [
        (Identifier 68:15-19 elem)
        (Identifier 68:21-28 col_sep)
        (Identifier 68:30-37 row_sep)
        (Identifier 68:39-42 Pad)
      ])
    (Return 69:2-76
      (Destructure 69:2-50
        (Function 69:2-42
          (Identifier 69:2-13 rows_padded) [
            (Identifier 69:14-18 elem)
            (Identifier 69:20-27 col_sep)
            (Identifier 69:29-36 row_sep)
            (Identifier 69:38-41 Pad)
          ])
        (Identifier 69:46-50 Rows))
      (Function 70:2-23
        (Identifier 70:2-17 Table.Transpose) [
          (Identifier 70:18-22 Rows)
        ])))
  
  (DeclareGlobal 72:0-28
    (Identifier 72:0-11 cols_padded)
    (Identifier 72:14-28 columns_padded))
