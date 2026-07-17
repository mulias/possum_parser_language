  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array.possum -i '' --no-stdlib
  (Import 1:0-13 stdlib/util)
  
  (Import 2:0-15 stdlib/Number)
  
  (DeclareGlobal 4:0-32
    (Function 4:0-11
      (Identifier 4:0-5 array) [
        (Identifier 4:6-10 elem)
      ])
    (Repeat 4:14-32
      (Function 4:14-26
        (Identifier 4:14-20 tuple1) [
          (Identifier 4:21-25 elem)
        ])
      (Range 4:29-32 (NumberString 4:29-30 1) ())))
  
  (DeclareGlobal 6:0-64
    (Function 6:0-20
      (Identifier 6:0-9 array_sep) [
        (Identifier 6:10-14 elem)
        (Identifier 6:16-19 sep)
      ])
    (Merge 6:23-64
      (Function 6:23-35
        (Identifier 6:23-29 tuple1) [
          (Identifier 6:30-34 elem)
        ])
      (Repeat 6:38-64
        (Function 6:39-57
          (Identifier 6:39-45 tuple1) [
            (TakeRight 6:46-56
              (Identifier 6:46-49 sep)
              (Identifier 6:52-56 elem))
          ])
        (Range 6:60-63 (NumberString 6:60-61 0) ()))))
  
  (DeclareGlobal 8:0-71
    (Function 8:0-23
      (Identifier 8:0-11 array_until) [
        (Identifier 8:12-16 elem)
        (Identifier 8:18-22 stop)
      ])
    (TakeLeft 8:26-71
      (Repeat 8:26-58
        (Function 8:26-52
          (Identifier 8:26-32 unless) [
            (Function 8:33-45
              (Identifier 8:33-39 tuple1) [
                (Identifier 8:40-44 elem)
              ])
            (Identifier 8:47-51 stop)
          ])
        (Range 8:55-58 (NumberString 8:55-56 1) ()))
      (Function 8:61-71
        (Identifier 8:61-65 peek) [
          (Identifier 8:66-70 stop)
        ])))
  
  (DeclareGlobal 10:0-44
    (Function 10:0-17
      (Identifier 10:0-11 maybe_array) [
        (Identifier 10:12-16 elem)
      ])
    (Function 10:20-44
      (Identifier 10:20-27 default) [
        (Function 10:28-39
          (Identifier 10:28-33 array) [
            (Identifier 10:34-38 elem)
          ])
        (Array 10:41-44 [])
      ]))
  
  (DeclareGlobal 12:0-62
    (Function 12:0-26
      (Identifier 12:0-15 maybe_array_sep) [
        (Identifier 12:16-20 elem)
        (Identifier 12:22-25 sep)
      ])
    (Function 12:29-62
      (Identifier 12:29-36 default) [
        (Function 12:37-57
          (Identifier 12:37-46 array_sep) [
            (Identifier 12:47-51 elem)
            (Identifier 12:53-56 sep)
          ])
        (Array 12:59-62 [])
      ]))
  
  (DeclareGlobal 14:0-37
    (Function 14:0-12
      (Identifier 14:0-6 tuple1) [
        (Identifier 14:7-11 elem)
      ])
    (Return 14:16-37
      (Destructure 14:16-28
        (Identifier 14:16-20 elem)
        (Identifier 14:24-28 Elem))
      (Array 14:31-37 [
        (Identifier 14:32-36 Elem)
      ])))
  
  (DeclareGlobal 16:0-59
    (Function 16:0-20
      (Identifier 16:0-6 tuple2) [
        (Identifier 16:7-12 elem1)
        (Identifier 16:14-19 elem2)
      ])
    (TakeRight 16:23-59
      (Destructure 16:23-34
        (Identifier 16:23-28 elem1)
        (Identifier 16:32-34 E1))
      (Return 16:37-59
        (Destructure 16:37-48
          (Identifier 16:37-42 elem2)
          (Identifier 16:46-48 E2))
        (Array 16:51-59 [
          (Identifier 16:52-54 E1)
          (Identifier 16:56-58 E2)
        ]))))
  
  (DeclareGlobal 18:0-74
    (Function 18:0-29
      (Identifier 18:0-10 tuple2_sep) [
        (Identifier 18:11-16 elem1)
        (Identifier 18:18-21 sep)
        (Identifier 18:23-28 elem2)
      ])
    (TakeRight 18:32-74
      (TakeRight 18:32-49
        (Destructure 18:32-43
          (Identifier 18:32-37 elem1)
          (Identifier 18:41-43 E1))
        (Identifier 18:46-49 sep))
      (Return 18:52-74
        (Destructure 18:52-63
          (Identifier 18:52-57 elem2)
          (Identifier 18:61-63 E2))
        (Array 18:66-74 [
          (Identifier 18:67-69 E1)
          (Identifier 18:71-73 E2)
        ]))))
  
  (DeclareGlobal 20:0-92
    (Function 20:0-27
      (Identifier 20:0-6 tuple3) [
        (Identifier 20:7-12 elem1)
        (Identifier 20:14-19 elem2)
        (Identifier 20:21-26 elem3)
      ])
    (TakeRight 21:2-62
      (TakeRight 21:2-29
        (Destructure 21:2-13
          (Identifier 21:2-7 elem1)
          (Identifier 21:11-13 E1))
        (Destructure 22:2-13
          (Identifier 22:2-7 elem2)
          (Identifier 22:11-13 E2)))
      (Return 23:2-30
        (Destructure 23:2-13
          (Identifier 23:2-7 elem3)
          (Identifier 23:11-13 E3))
        (Array 24:2-14 [
          (Identifier 24:3-5 E1)
          (Identifier 24:7-9 E2)
          (Identifier 24:11-13 E3)
        ]))))
  
  (DeclareGlobal 26:0-122
    (Function 26:0-43
      (Identifier 26:0-10 tuple3_sep) [
        (Identifier 26:11-16 elem1)
        (Identifier 26:18-22 sep1)
        (Identifier 26:24-29 elem2)
        (Identifier 26:31-35 sep2)
        (Identifier 26:37-42 elem3)
      ])
    (TakeRight 27:2-76
      (TakeRight 27:2-43
        (TakeRight 27:2-36
          (TakeRight 27:2-20
            (Destructure 27:2-13
              (Identifier 27:2-7 elem1)
              (Identifier 27:11-13 E1))
            (Identifier 27:16-20 sep1))
          (Destructure 28:2-13
            (Identifier 28:2-7 elem2)
            (Identifier 28:11-13 E2)))
        (Identifier 28:16-20 sep2))
      (Return 29:2-30
        (Destructure 29:2-13
          (Identifier 29:2-7 elem3)
          (Identifier 29:11-13 E3))
        (Array 30:2-14 [
          (Identifier 30:3-5 E1)
          (Identifier 30:7-9 E2)
          (Identifier 30:11-13 E3)
        ]))))
  
  (DeclareGlobal 32:0-33
    (Function 32:0-14
      (Identifier 32:0-5 tuple) [
        (Identifier 32:6-10 elem)
        (Identifier 32:12-13 N)
      ])
    (Repeat 32:17-33
      (Function 32:17-29
        (Identifier 32:17-23 tuple1) [
          (Identifier 32:24-28 elem)
        ])
      (Identifier 32:32-33 N)))
  
  (DeclareGlobal 34:0-71
    (Function 34:0-23
      (Identifier 34:0-9 tuple_sep) [
        (Identifier 34:10-14 elem)
        (Identifier 34:16-19 sep)
        (Identifier 34:21-22 N)
      ])
    (Merge 34:26-71
      (Function 34:26-38
        (Identifier 34:26-32 tuple1) [
          (Identifier 34:33-37 elem)
        ])
      (Repeat 34:41-71
        (Function 34:42-60
          (Identifier 34:42-48 tuple1) [
            (TakeRight 34:49-59
              (Identifier 34:49-52 sep)
              (Identifier 34:55-59 elem))
          ])
        (NumberSubtract 34:63-70
          (Identifier 34:64-65 N)
          (NumberString 34:68-69 1)))))
  
  (DeclareGlobal 36:0-120
    (Function 36:0-28
      (Identifier 36:0-4 rows) [
        (Identifier 36:5-9 elem)
        (Identifier 36:11-18 col_sep)
        (Identifier 36:20-27 row_sep)
      ])
    (Merge 37:2-89
      (Function 37:2-34
        (Identifier 37:2-8 tuple1) [
          (Function 37:9-33
            (Identifier 37:9-18 array_sep) [
              (Identifier 37:19-23 elem)
              (Identifier 37:25-32 col_sep)
            ])
        ])
      (Repeat 38:2-52
        (Function 38:3-45
          (Identifier 38:3-9 tuple1) [
            (TakeRight 38:10-44
              (Identifier 38:10-17 row_sep)
              (Function 38:20-44
                (Identifier 38:20-29 array_sep) [
                  (Identifier 38:30-34 elem)
                  (Identifier 38:36-43 col_sep)
                ]))
          ])
        (Range 38:48-51 (NumberString 38:48-49 0) ()))))
  
  (DeclareGlobal 40:0-194
    (Function 40:0-40
      (Identifier 40:0-11 rows_padded) [
        (Identifier 40:12-16 elem)
        (Identifier 40:18-25 col_sep)
        (Identifier 40:27-34 row_sep)
        (Identifier 40:36-39 Pad)
      ])
    (TakeRight 41:2-151
      (TakeRight 41:2-79
        (Destructure 41:2-61
          (Function 41:2-43
            (Identifier 41:2-6 peek) [
              (Function 41:7-42
                (Identifier 41:7-18 _dimensions) [
                  (Identifier 41:19-23 elem)
                  (Identifier 41:25-32 col_sep)
                  (Identifier 41:34-41 row_sep)
                ])
            ])
          (Array 41:47-61 [
            (Identifier 41:48-57 MaxRowLen)
            (Identifier 41:59-60 _)
          ]))
        (Destructure 42:2-15
          (Identifier 42:2-6 elem)
          (Identifier 42:10-15 First)))
      (Function 42:18-87
        (Identifier 42:18-30 _rows_padded) [
          (Identifier 42:31-35 elem)
          (Identifier 42:37-44 col_sep)
          (Identifier 42:46-53 row_sep)
          (Identifier 42:55-58 Pad)
          (ValueLabel 42:60-61 (NumberString 42:61-62 1))
          (Identifier 42:64-73 MaxRowLen)
          (Array 42:75-82 [
            (Identifier 42:76-81 First)
          ])
          (Array 42:84-87 [])
        ])))
  
  (DeclareGlobal 44:0-442
    (Function 44:0-77
      (Identifier 44:0-12 _rows_padded) [
        (Identifier 44:13-17 elem)
        (Identifier 44:19-26 col_sep)
        (Identifier 44:28-35 row_sep)
        (Identifier 44:37-40 Pad)
        (Identifier 44:42-48 RowLen)
        (Identifier 44:50-59 MaxRowLen)
        (Identifier 44:61-67 AccRow)
        (Identifier 44:69-76 AccRows)
      ])
    (Conditional 45:2-362
      (Destructure 45:2-24
        (TakeRight 45:2-16
          (Identifier 45:2-9 col_sep)
          (Identifier 45:12-16 elem))
        (Identifier 45:20-24 Elem))
      (Function 46:2-99
        (Identifier 46:2-14 _rows_padded) [
          (Identifier 46:15-19 elem)
          (Identifier 46:21-28 col_sep)
          (Identifier 46:30-37 row_sep)
          (Identifier 46:39-42 Pad)
          (Function 46:44-59
            (Identifier 46:44-51 Num.Inc) [
              (Identifier 46:52-58 RowLen)
            ])
          (Identifier 46:61-70 MaxRowLen)
          (Merge 46:72-89
            (Merge 46:72-73
              (Array 46:72-73 [])
              (Identifier 46:76-82 AccRow))
            (Array 46:84-89 [
              (Identifier 46:84-88 Elem)
            ]))
          (Identifier 46:91-98 AccRows)
        ])
      (Conditional 47:2-233
        (Destructure 47:2-27
          (TakeRight 47:2-16
            (Identifier 47:2-9 row_sep)
            (Identifier 47:12-16 elem))
          (Identifier 47:20-27 NextRow))
        (Function 48:2-131
          (Identifier 48:2-14 _rows_padded) [
            (Identifier 48:15-19 elem)
            (Identifier 48:21-28 col_sep)
            (Identifier 48:30-37 row_sep)
            (Identifier 48:39-42 Pad)
            (ValueLabel 48:44-45 (NumberString 48:45-46 1))
            (Identifier 48:48-57 MaxRowLen)
            (Array 48:59-68 [
              (Identifier 48:60-67 NextRow)
            ])
            (Merge 48:70-130
              (Merge 48:70-71
                (Array 48:70-71 [])
                (Identifier 48:74-81 AccRows))
              (Array 48:83-130 [
                (Function 48:83-129
                  (Identifier 48:83-96 Array.AppendN) [
                    (Identifier 48:97-103 AccRow)
                    (Identifier 48:105-108 Pad)
                    (NumberSubtract 48:110-128
                      (Identifier 48:110-119 MaxRowLen)
                      (Identifier 48:122-128 RowLen))
                  ])
              ]))
          ])
        (Function 49:2-69
          (Identifier 49:2-7 const) [
            (Merge 49:8-68
              (Merge 49:8-9
                (Array 49:8-9 [])
                (Identifier 49:12-19 AccRows))
              (Array 49:21-68 [
                (Function 49:21-67
                  (Identifier 49:21-34 Array.AppendN) [
                    (Identifier 49:35-41 AccRow)
                    (Identifier 49:43-46 Pad)
                    (NumberSubtract 49:48-66
                      (Identifier 49:48-57 MaxRowLen)
                      (Identifier 49:60-66 RowLen))
                  ])
              ]))
          ]))))
  
  (DeclareGlobal 51:0-95
    (Function 51:0-35
      (Identifier 51:0-11 _dimensions) [
        (Identifier 51:12-16 elem)
        (Identifier 51:18-25 col_sep)
        (Identifier 51:27-34 row_sep)
      ])
    (TakeRight 52:2-57
      (Identifier 52:2-6 elem)
      (Function 52:9-57
        (Identifier 52:9-21 __dimensions) [
          (Identifier 52:22-26 elem)
          (Identifier 52:28-35 col_sep)
          (Identifier 52:37-44 row_sep)
          (ValueLabel 52:46-47 (NumberString 52:47-48 1))
          (ValueLabel 52:50-51 (NumberString 52:51-52 1))
          (ValueLabel 52:54-55 (NumberString 52:55-56 0))
        ])))
  
  (DeclareGlobal 54:0-316
    (Function 54:0-63
      (Identifier 54:0-12 __dimensions) [
        (Identifier 54:13-17 elem)
        (Identifier 54:19-26 col_sep)
        (Identifier 54:28-35 row_sep)
        (Identifier 54:37-43 RowLen)
        (Identifier 54:45-51 ColLen)
        (Identifier 54:53-62 MaxRowLen)
      ])
    (Conditional 55:2-250
      (TakeRight 55:2-16
        (Identifier 55:2-9 col_sep)
        (Identifier 55:12-16 elem))
      (Function 56:2-74
        (Identifier 56:2-14 __dimensions) [
          (Identifier 56:15-19 elem)
          (Identifier 56:21-28 col_sep)
          (Identifier 56:30-37 row_sep)
          (Function 56:39-54
            (Identifier 56:39-46 Num.Inc) [
              (Identifier 56:47-53 RowLen)
            ])
          (Identifier 56:56-62 ColLen)
          (Identifier 56:64-73 MaxRowLen)
        ])
      (Conditional 57:2-154
        (TakeRight 57:2-16
          (Identifier 57:2-9 row_sep)
          (Identifier 57:12-16 elem))
        (Function 58:2-87
          (Identifier 58:2-14 __dimensions) [
            (Identifier 58:15-19 elem)
            (Identifier 58:21-28 col_sep)
            (Identifier 58:30-37 row_sep)
            (ValueLabel 58:39-40 (NumberString 58:40-41 1))
            (Function 58:43-58
              (Identifier 58:43-50 Num.Inc) [
                (Identifier 58:51-57 ColLen)
              ])
            (Function 58:60-86
              (Identifier 58:60-67 Num.Max) [
                (Identifier 58:68-74 RowLen)
                (Identifier 58:76-85 MaxRowLen)
              ])
          ])
        (Function 59:2-45
          (Identifier 59:2-7 const) [
            (Array 59:8-44 [
              (Function 59:9-35
                (Identifier 59:9-16 Num.Max) [
                  (Identifier 59:17-23 RowLen)
                  (Identifier 59:25-34 MaxRowLen)
                ])
              (Identifier 59:37-43 ColLen)
            ])
          ]))))
  
  (DeclareGlobal 61:0-98
    (Function 61:0-31
      (Identifier 61:0-7 columns) [
        (Identifier 61:8-12 elem)
        (Identifier 61:14-21 col_sep)
        (Identifier 61:23-30 row_sep)
      ])
    (Return 62:2-64
      (Destructure 62:2-38
        (Function 62:2-30
          (Identifier 62:2-6 rows) [
            (Identifier 62:7-11 elem)
            (Identifier 62:13-20 col_sep)
            (Identifier 62:22-29 row_sep)
          ])
        (Identifier 62:34-38 Rows))
      (Function 63:2-23
        (Identifier 63:2-17 Table.Transpose) [
          (Identifier 63:18-22 Rows)
        ])))
  
  (DeclareGlobal 65:0-14
    (Identifier 65:0-4 cols)
    (Identifier 65:7-14 columns))
  
  (DeclareGlobal 67:0-122
    (Function 67:0-43
      (Identifier 67:0-14 columns_padded) [
        (Identifier 67:15-19 elem)
        (Identifier 67:21-28 col_sep)
        (Identifier 67:30-37 row_sep)
        (Identifier 67:39-42 Pad)
      ])
    (Return 68:2-76
      (Destructure 68:2-50
        (Function 68:2-42
          (Identifier 68:2-13 rows_padded) [
            (Identifier 68:14-18 elem)
            (Identifier 68:20-27 col_sep)
            (Identifier 68:29-36 row_sep)
            (Identifier 68:38-41 Pad)
          ])
        (Identifier 68:46-50 Rows))
      (Function 69:2-23
        (Identifier 69:2-17 Table.Transpose) [
          (Identifier 69:18-22 Rows)
        ])))
  
  (DeclareGlobal 71:0-28
    (Identifier 71:0-11 cols_padded)
    (Identifier 71:14-28 columns_padded))
