  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/toml.possum -i '' --no-stdlib
  (Import 1:0-15 stdlib/string)
  
  (Import 2:0-15 stdlib/number)
  
  (Import 3:0-14 stdlib/array)
  
  (Import 4:0-13 stdlib/util)
  
  (Import 5:0-15 stdlib/Number)
  
  (Import 6:0-15 stdlib/Object)
  
  (Import 7:0-18 stdlib/Predicate)
  
  (Identifier 9:0-6 simple)
  
  (DeclareGlobal 11:0-29
    (Identifier 11:0-6 simple)
    (Function 11:9-29
      (Identifier 11:9-15 custom) [
        (Identifier 11:16-28 simple_value)
      ]))
  
  (DeclareGlobal 13:0-29
    (Identifier 13:0-6 tagged)
    (Function 13:9-29
      (Identifier 13:9-15 custom) [
        (Identifier 13:16-28 tagged_value)
      ]))
  
  (DeclareGlobal 15:0-158
    (Function 15:0-13
      (Identifier 15:0-6 custom) [
        (Identifier 15:7-12 value)
      ])
    (TakeRight 16:2-142
      (TakeRight 16:2-89
        (Function 16:2-30
          (Identifier 16:2-7 maybe) [
            (Merge 16:8-29
              (Identifier 16:8-17 _comments)
              (Function 16:20-29
                (Identifier 16:20-25 maybe) [
                  (Identifier 16:26-28 ws)
                ]))
          ])
        (Destructure 17:2-56
          (Or 17:2-49
            (Function 17:2-25
              (Identifier 17:2-18 _with_root_table) [
                (Identifier 17:19-24 value)
              ])
            (Function 17:28-49
              (Identifier 17:28-42 _no_root_table) [
                (Identifier 17:43-48 value)
              ]))
          (Identifier 17:53-56 Doc)))
      (Return 18:2-50
        (Function 18:2-30
          (Identifier 18:2-7 maybe) [
            (Merge 18:8-29
              (Function 18:8-17
                (Identifier 18:8-13 maybe) [
                  (Identifier 18:14-16 ws)
                ])
              (Identifier 18:20-29 _comments))
          ])
        (Function 19:2-17
          (Identifier 19:2-12 _Doc.Value) [
            (Identifier 19:13-16 Doc)
          ]))))
  
  (DeclareGlobal 21:0-122
    (Function 21:0-23
      (Identifier 21:0-16 _with_root_table) [
        (Identifier 21:17-22 value)
      ])
    (TakeRight 22:2-96
      (Destructure 22:2-43
        (Function 22:2-32
          (Identifier 22:2-13 _root_table) [
            (Identifier 22:14-19 value)
            (Identifier 22:21-31 _Doc.Empty)
          ])
        (Identifier 22:36-43 RootDoc))
      (Or 23:2-50
        (TakeRight 23:2-33
          (Identifier 23:3-6 _ws)
          (Function 23:9-32
            (Identifier 23:9-16 _tables) [
              (Identifier 23:17-22 value)
              (Identifier 23:24-31 RootDoc)
            ]))
        (Function 23:36-50
          (Identifier 23:36-41 const) [
            (Identifier 23:42-49 RootDoc)
          ]))))
  
  (DeclareGlobal 25:0-55
    (Function 25:0-23
      (Identifier 25:0-11 _root_table) [
        (Identifier 25:12-17 value)
        (Identifier 25:19-22 Doc)
      ])
    (Function 26:2-29
      (Identifier 26:2-13 _table_body) [
        (Identifier 26:14-19 value)
        (Array 26:21-24 [])
        (Identifier 26:25-28 Doc)
      ]))
  
  (DeclareGlobal 28:0-126
    (Function 28:0-21
      (Identifier 28:0-14 _no_root_table) [
        (Identifier 28:15-20 value)
      ])
    (TakeRight 29:2-102
      (Destructure 29:2-75
        (Or 29:2-65
          (Function 29:2-27
            (Identifier 29:2-8 _table) [
              (Identifier 29:9-14 value)
              (Identifier 29:16-26 _Doc.Empty)
            ])
          (Function 29:30-65
            (Identifier 29:30-46 _array_of_tables) [
              (Identifier 29:47-52 value)
              (Identifier 29:54-64 _Doc.Empty)
            ]))
        (Identifier 29:69-75 NewDoc))
      (Function 30:2-24
        (Identifier 30:2-9 _tables) [
          (Identifier 30:10-15 value)
          (Identifier 30:17-23 NewDoc)
        ])))
  
  (DeclareGlobal 32:0-133
    (Function 32:0-19
      (Identifier 32:0-7 _tables) [
        (Identifier 32:8-13 value)
        (Identifier 32:15-18 Doc)
      ])
    (Conditional 33:2-111
      (Destructure 33:2-69
        (Or 33:2-59
          (TakeRight 33:2-28
            (Identifier 33:2-5 _ws)
            (Function 34:2-20
              (Identifier 34:2-8 _table) [
                (Identifier 34:9-14 value)
                (Identifier 34:16-19 Doc)
              ]))
          (Function 34:23-51
            (Identifier 34:23-39 _array_of_tables) [
              (Identifier 34:40-45 value)
              (Identifier 34:47-50 Doc)
            ]))
        (Identifier 34:55-61 NewDoc))
      (Function 35:2-24
        (Identifier 35:2-9 _tables) [
          (Identifier 35:10-15 value)
          (Identifier 35:17-23 NewDoc)
        ])
      (Function 36:2-12
        (Identifier 36:2-7 const) [
          (Identifier 36:8-11 Doc)
        ])))
  
  (DeclareGlobal 38:0-165
    (Function 38:0-18
      (Identifier 38:0-6 _table) [
        (Identifier 38:7-12 value)
        (Identifier 38:14-17 Doc)
      ])
    (TakeRight 39:2-144
      (TakeRight 39:2-43
        (Destructure 39:2-29
          (Identifier 39:2-15 _table_header)
          (Identifier 39:19-29 HeaderPath))
        (Identifier 39:32-43 _ws_newline))
      (Or 39:46-144
        (Function 40:4-39
          (Identifier 40:4-15 _table_body) [
            (Identifier 40:16-21 value)
            (Identifier 40:23-33 HeaderPath)
            (Identifier 40:35-38 Doc)
          ])
        (Function 41:4-50
          (Identifier 41:4-9 const) [
            (Function 41:10-49
              (Identifier 41:10-32 _Doc.EnsureTableAtPath) [
                (Identifier 41:33-36 Doc)
                (Identifier 41:38-48 HeaderPath)
              ])
          ]))))
  
  (DeclareGlobal 44:0-205
    (Function 44:0-28
      (Identifier 44:0-16 _array_of_tables) [
        (Identifier 44:17-22 value)
        (Identifier 44:24-27 Doc)
      ])
    (TakeRight 45:2-174
      (TakeRight 45:2-53
        (Destructure 45:2-39
          (Identifier 45:2-25 _array_of_tables_header)
          (Identifier 45:29-39 HeaderPath))
        (Identifier 45:42-53 _ws_newline))
      (Return 46:2-118
        (Destructure 46:2-69
          (Function 46:2-57
            (Identifier 46:2-9 default) [
              (Function 46:10-44
                (Identifier 46:10-21 _table_body) [
                  (Identifier 46:22-27 value)
                  (Array 46:29-32 [])
                  (Identifier 46:33-43 _Doc.Empty)
                ])
              (Identifier 46:46-56 _Doc.Empty)
            ])
          (Identifier 46:61-69 InnerDoc))
        (Function 47:2-46
          (Identifier 47:2-19 _Doc.AppendAtPath) [
            (Identifier 47:20-23 Doc)
            (Identifier 47:25-35 HeaderPath)
            (Identifier 47:37-45 InnerDoc)
          ]))))
  
  (DeclareGlobal 49:0-31
    (Identifier 49:0-3 _ws)
    (Function 49:6-31
      (Identifier 49:6-16 maybe_many) [
        (Or 49:17-30
          (Identifier 49:17-19 ws)
          (Identifier 49:22-30 _comment))
      ]))
  
  (DeclareGlobal 51:0-40
    (Identifier 51:0-8 _ws_line)
    (Function 51:11-40
      (Identifier 51:11-21 maybe_many) [
        (Or 51:22-39
          (Identifier 51:22-28 spaces)
          (Identifier 51:31-39 _comment))
      ]))
  
  (DeclareGlobal 53:0-41
    (Identifier 53:0-11 _ws_newline)
    (Merge 53:14-41
      (Merge 53:14-35
        (Identifier 53:14-22 _ws_line)
        (Or 53:25-35
          (Identifier 53:26-28 nl)
          (Identifier 53:31-34 end)))
      (Identifier 53:38-41 _ws)))
  
  (DeclareGlobal 55:0-34
    (Identifier 55:0-9 _comments)
    (Function 55:12-34
      (Identifier 55:12-20 many_sep) [
        (Identifier 55:21-29 _comment)
        (Identifier 55:31-33 ws)
      ]))
  
  (DeclareGlobal 57:0-54
    (Identifier 57:0-13 _table_header)
    (TakeLeft 57:16-54
      (TakeRight 57:16-48
        (String 57:16-19 "[")
        (Function 57:22-48
          (Identifier 57:22-30 surround) [
            (Identifier 57:31-36 _path)
            (Function 57:38-47
              (Identifier 57:38-43 maybe) [
                (Identifier 57:44-46 ws)
              ])
          ]))
      (String 57:51-54 "]")))
  
  (DeclareGlobal 59:0-68
    (Identifier 59:0-23 _array_of_tables_header)
    (TakeLeft 60:2-42
      (TakeRight 60:2-35
        (String 60:2-6 "[[")
        (Function 60:9-35
          (Identifier 60:9-17 surround) [
            (Identifier 60:18-23 _path)
            (Function 60:25-34
              (Identifier 60:25-30 maybe) [
                (Identifier 60:31-33 ws)
              ])
          ]))
      (String 60:38-42 "]]")))
  
  (DeclareGlobal 62:0-229
    (Function 62:0-35
      (Identifier 62:0-11 _table_body) [
        (Identifier 62:12-17 value)
        (Identifier 62:19-29 HeaderPath)
        (Identifier 62:31-34 Doc)
      ])
    (TakeRight 63:2-191
      (TakeRight 63:2-132
        (TakeRight 63:2-52
          (Destructure 63:2-38
            (Function 63:2-20
              (Identifier 63:2-13 _table_pair) [
                (Identifier 63:14-19 value)
              ])
            (Array 63:24-38 [
              (Identifier 63:25-32 KeyPath)
              (Identifier 63:34-37 Val)
            ]))
          (Identifier 63:41-52 _ws_newline))
        (Destructure 64:2-77
          (Function 64:2-67
            (Identifier 64:2-7 const) [
              (Function 64:8-66
                (Identifier 64:8-35 _Doc.InsertPairAtHeaderPath) [
                  (Identifier 64:36-39 Doc)
                  (Identifier 64:41-51 HeaderPath)
                  (Identifier 64:53-60 KeyPath)
                  (Identifier 64:62-65 Val)
                ])
            ])
          (Identifier 64:71-77 NewDoc)))
      (Or 65:2-56
        (Function 65:2-40
          (Identifier 65:2-13 _table_body) [
            (Identifier 65:14-19 value)
            (Identifier 65:21-31 HeaderPath)
            (Identifier 65:33-39 NewDoc)
          ])
        (Function 65:43-56
          (Identifier 65:43-48 const) [
            (Identifier 65:49-55 NewDoc)
          ]))))
  
  (DeclareGlobal 67:0-77
    (Function 67:0-18
      (Identifier 67:0-11 _table_pair) [
        (Identifier 67:12-17 value)
      ])
    (Function 68:2-56
      (Identifier 68:2-12 tuple2_sep) [
        (Identifier 68:13-18 _path)
        (Function 68:20-48
          (Identifier 68:20-28 surround) [
            (String 68:29-32 "=")
            (Function 68:34-47
              (Identifier 68:34-39 maybe) [
                (Identifier 68:40-46 spaces)
              ])
          ])
        (Identifier 68:50-55 value)
      ]))
  
  (DeclareGlobal 70:0-49
    (Identifier 70:0-5 _path)
    (Function 70:8-49
      (Identifier 70:8-17 array_sep) [
        (Identifier 70:18-22 _key)
        (Function 70:24-48
          (Identifier 70:24-32 surround) [
            (String 70:33-36 ".")
            (Function 70:38-47
              (Identifier 70:38-43 maybe) [
                (Identifier 70:44-46 ws)
              ])
          ])
      ]))
  
  (DeclareGlobal 72:0-78
    (Identifier 72:0-4 _key)
    (Or 73:2-71
      (Function 73:2-35
        (Identifier 73:2-6 many) [
          (Or 73:7-34
            (Identifier 73:7-12 alpha)
            (Or 73:15-34
              (Identifier 73:15-22 numeral)
              (Or 73:25-34
                (String 73:25-28 "_")
                (String 73:31-34 "-"))))
        ])
      (Or 74:2-33
        (Identifier 74:2-14 string.basic)
        (Identifier 75:2-16 string.literal))))
  
  (DeclareGlobal 77:0-28
    (Identifier 77:0-8 _comment)
    (TakeRight 77:11-28
      (String 77:11-14 "#")
      (Function 77:17-28
        (Identifier 77:17-22 maybe) [
          (Identifier 77:23-27 line)
        ])))
  
  (DeclareGlobal 79:0-114
    (Identifier 79:0-12 simple_value)
    (Or 80:2-99
      (Identifier 80:2-8 string)
      (Or 81:2-88
        (Identifier 81:2-10 datetime)
        (Or 82:2-75
          (Identifier 82:2-8 number)
          (Or 83:2-64
            (Identifier 83:2-9 boolean)
            (Or 84:2-52
              (Function 84:2-21
                (Identifier 84:2-7 array) [
                  (Identifier 84:8-20 simple_value)
                ])
              (Function 85:2-28
                (Identifier 85:2-14 inline_table) [
                  (Identifier 85:15-27 simple_value)
                ])))))))
  
  (DeclareGlobal 87:0-520
    (Identifier 87:0-12 tagged_value)
    (Or 88:2-505
      (Identifier 88:2-8 string)
      (Or 89:2-494
        (Function 89:2-47
          (Identifier 89:2-6 _tag) [
            (ValueLabel 89:7-8 (String 89:8-18 "datetime"))
            (ValueLabel 89:20-21 (String 89:21-29 "offset"))
            (Identifier 89:31-46 datetime.offset)
          ])
        (Or 90:2-444
          (Function 90:2-45
            (Identifier 90:2-6 _tag) [
              (ValueLabel 90:7-8 (String 90:8-18 "datetime"))
              (ValueLabel 90:20-21 (String 90:21-28 "local"))
              (Identifier 90:30-44 datetime.local)
            ])
          (Or 91:2-396
            (Function 91:2-55
              (Identifier 91:2-6 _tag) [
                (ValueLabel 91:7-8 (String 91:8-18 "datetime"))
                (ValueLabel 91:20-21 (String 91:21-33 "date-local"))
                (Identifier 91:35-54 datetime.local_date)
              ])
            (Or 92:2-338
              (Function 92:2-55
                (Identifier 92:2-6 _tag) [
                  (ValueLabel 92:7-8 (String 92:8-18 "datetime"))
                  (ValueLabel 92:20-21 (String 92:21-33 "time-local"))
                  (Identifier 92:35-54 datetime.local_time)
                ])
              (Or 93:2-280
                (Identifier 93:2-23 number.binary_integer)
                (Or 94:2-254
                  (Identifier 94:2-22 number.octal_integer)
                  (Or 95:2-229
                    (Identifier 95:2-20 number.hex_integer)
                    (Or 96:2-206
                      (Function 96:2-46
                        (Identifier 96:2-6 _tag) [
                          (ValueLabel 96:7-8 (String 96:8-15 "float"))
                          (ValueLabel 96:17-18 (String 96:18-28 "infinity"))
                          (Identifier 96:30-45 number.infinity)
                        ])
                      (Or 97:2-157
                        (Function 97:2-54
                          (Identifier 97:2-6 _tag) [
                            (ValueLabel 97:7-8 (String 97:8-15 "float"))
                            (ValueLabel 97:17-18 (String 97:18-32 "not-a-number"))
                            (Identifier 97:34-53 number.not_a_number)
                          ])
                        (Or 98:2-100
                          (Identifier 98:2-14 number.float)
                          (Or 99:2-83
                            (Identifier 99:2-16 number.integer)
                            (Or 100:2-64
                              (Identifier 100:2-9 boolean)
                              (Or 101:2-52
                                (Function 101:2-21
                                  (Identifier 101:2-7 array) [
                                    (Identifier 101:8-20 tagged_value)
                                  ])
                                (Function 102:2-28
                                  (Identifier 102:2-14 inline_table) [
                                    (Identifier 102:15-27 tagged_value)
                                  ]))))))))))))))))
  
  (DeclareGlobal 104:0-98
    (Function 104:0-26
      (Identifier 104:0-4 _tag) [
        (Identifier 104:5-9 Type)
        (Identifier 104:11-18 Subtype)
        (Identifier 104:20-25 value)
      ])
    (Return 105:2-69
      (Destructure 105:2-16
        (Identifier 105:2-7 value)
        (Identifier 105:11-16 Value))
      (Object 105:19-69 [
        (ObjectPair (String 105:20-26 "type") (Identifier 105:28-32 Type))
        (ObjectPair (String 105:34-43 "subtype") (Identifier 105:45-52 Subtype))
        (ObjectPair (String 105:54-61 "value") (Identifier 105:63-68 Value))
      ])))
  
  (DeclareGlobal 107:0-100
    (Identifier 107:0-6 string)
    (Or 108:2-91
      (Identifier 108:2-25 string.multi_line_basic)
      (Or 109:2-63
        (Identifier 109:2-27 string.multi_line_literal)
        (Or 110:2-33
          (Identifier 110:2-14 string.basic)
          (Identifier 111:2-16 string.literal)))))
  
  (DeclareGlobal 113:0-95
    (Identifier 113:0-8 datetime)
    (Or 114:2-84
      (Identifier 114:2-17 datetime.offset)
      (Or 115:2-64
        (Identifier 115:2-16 datetime.local)
        (Or 116:2-45
          (Identifier 116:2-21 datetime.local_date)
          (Identifier 117:2-21 datetime.local_time)))))
  
  (DeclareGlobal 119:0-160
    (Identifier 119:0-6 number)
    (Or 120:2-151
      (Identifier 120:2-23 number.binary_integer)
      (Or 121:2-125
        (Identifier 121:2-22 number.octal_integer)
        (Or 122:2-100
          (Identifier 122:2-20 number.hex_integer)
          (Or 123:2-77
            (Identifier 123:2-17 number.infinity)
            (Or 124:2-57
              (Identifier 124:2-21 number.not_a_number)
              (Or 125:2-33
                (Identifier 125:2-14 number.float)
                (Identifier 126:2-16 number.integer))))))))
  
  (DeclareGlobal 128:0-42
    (Identifier 128:0-7 boolean)
    (Function 128:10-42
      (Import 128:10-25 stdlib .boolean) [
        (String 128:26-32 "true")
        (String 128:34-41 "false")
      ]))
  
  (DeclareGlobal 130:0-128
    (Function 130:0-11
      (Identifier 130:0-5 array) [
        (Identifier 130:6-10 elem)
      ])
    (TakeLeft 131:2-114
      (TakeLeft 131:2-108
        (TakeRight 131:2-102
          (TakeRight 131:2-11
            (String 131:2-5 "[")
            (Identifier 131:8-11 _ws))
          (Function 131:14-102
            (Identifier 131:14-21 default) [
              (TakeLeft 132:4-67
                (Function 132:4-39
                  (Identifier 132:4-13 array_sep) [
                    (Function 132:14-33
                      (Identifier 132:14-22 surround) [
                        (Identifier 132:23-27 elem)
                        (Identifier 132:29-32 _ws)
                      ])
                    (String 132:35-38 ",")
                  ])
                (Function 132:42-67
                  (Identifier 132:42-47 maybe) [
                    (Function 132:48-66
                      (Identifier 132:48-56 surround) [
                        (String 132:57-60 ",")
                        (Identifier 132:62-65 _ws)
                      ])
                  ]))
              (Array 133:4-10 [])
            ]))
        (Identifier 134:6-9 _ws))
      (String 134:12-15 "]")))
  
  (DeclareGlobal 136:0-114
    (Function 136:0-19
      (Identifier 136:0-12 inline_table) [
        (Identifier 136:13-18 value)
      ])
    (Return 137:2-92
      (Destructure 137:2-66
        (Or 137:2-53
          (Identifier 137:2-21 _empty_inline_table)
          (Function 137:24-53
            (Identifier 137:24-46 _nonempty_inline_table) [
              (Identifier 137:47-52 value)
            ]))
        (Identifier 137:57-66 InlineDoc))
      (Function 138:2-23
        (Identifier 138:2-12 _Doc.Value) [
          (Identifier 138:13-22 InlineDoc)
        ])))
  
  (DeclareGlobal 140:0-60
    (Identifier 140:0-19 _empty_inline_table)
    (Return 140:22-60
      (TakeLeft 140:22-47
        (TakeRight 140:22-41
          (String 140:22-25 "{")
          (Function 140:28-41
            (Identifier 140:28-33 maybe) [
              (Identifier 140:34-40 spaces)
            ]))
        (String 140:44-47 "}"))
      (Identifier 140:50-60 _Doc.Empty)))
  
  (DeclareGlobal 142:0-187
    (Function 142:0-29
      (Identifier 142:0-22 _nonempty_inline_table) [
        (Identifier 142:23-28 value)
      ])
    (TakeRight 143:2-155
      (Destructure 143:2-83
        (TakeRight 143:2-63
          (TakeRight 143:2-21
            (String 143:2-5 "{")
            (Function 143:8-21
              (Identifier 143:8-13 maybe) [
                (Identifier 143:14-20 spaces)
              ]))
          (Function 144:2-39
            (Identifier 144:2-20 _inline_table_pair) [
              (Identifier 144:21-26 value)
              (Identifier 144:28-38 _Doc.Empty)
            ]))
        (Identifier 144:43-59 DocWithFirstPair))
      (TakeLeft 145:2-69
        (TakeLeft 145:2-63
          (Function 145:2-45
            (Identifier 145:2-20 _inline_table_body) [
              (Identifier 145:21-26 value)
              (Identifier 145:28-44 DocWithFirstPair)
            ])
          (Function 146:4-17
            (Identifier 146:4-9 maybe) [
              (Identifier 146:10-16 spaces)
            ]))
        (String 146:20-23 "}"))))
  
  (DeclareGlobal 148:0-134
    (Function 148:0-30
      (Identifier 148:0-18 _inline_table_body) [
        (Identifier 148:19-24 value)
        (Identifier 148:26-29 Doc)
      ])
    (Conditional 149:2-101
      (Destructure 149:2-48
        (TakeRight 149:2-38
          (String 149:2-5 ",")
          (Function 149:8-38
            (Identifier 149:8-26 _inline_table_pair) [
              (Identifier 149:27-32 value)
              (Identifier 149:34-37 Doc)
            ]))
        (Identifier 149:42-48 NewDoc))
      (Function 150:2-35
        (Identifier 150:2-20 _inline_table_body) [
          (Identifier 150:21-26 value)
          (Identifier 150:28-34 NewDoc)
        ])
      (Function 151:2-12
        (Identifier 151:2-7 const) [
          (Identifier 151:8-11 Doc)
        ])))
  
  (DeclareGlobal 153:0-177
    (Function 153:0-30
      (Identifier 153:0-18 _inline_table_pair) [
        (Identifier 153:19-24 value)
        (Identifier 153:26-29 Doc)
      ])
    (TakeRight 154:2-144
      (TakeRight 154:2-89
        (TakeRight 154:2-72
          (TakeRight 154:2-56
            (TakeRight 154:2-50
              (TakeRight 154:2-32
                (Function 154:2-15
                  (Identifier 154:2-7 maybe) [
                    (Identifier 154:8-14 spaces)
                  ])
                (Destructure 155:2-14
                  (Identifier 155:2-7 _path)
                  (Identifier 155:11-14 Key)))
              (Function 156:2-15
                (Identifier 156:2-7 maybe) [
                  (Identifier 156:8-14 spaces)
                ]))
            (String 156:18-21 "="))
          (Function 156:24-37
            (Identifier 156:24-29 maybe) [
              (Identifier 156:30-36 spaces)
            ]))
        (Destructure 157:2-14
          (Identifier 157:2-7 value)
          (Identifier 157:11-14 Val)))
      (Return 158:2-52
        (Function 158:2-15
          (Identifier 158:2-7 maybe) [
            (Identifier 158:8-14 spaces)
          ])
        (Function 159:2-34
          (Identifier 159:2-19 _Doc.InsertAtPath) [
            (Identifier 159:20-23 Doc)
            (Identifier 159:25-28 Key)
            (Identifier 159:30-33 Val)
          ]))))
  
  (DeclareGlobal 161:0-254
    (Identifier 161:0-23 string.multi_line_basic)
    (Merge 162:2-228
      (Merge 162:2-213
        (Merge 162:2-197
          (Merge 162:2-31
            (Function 162:2-13
              (Identifier 162:2-6 skip) [
                (String 162:7-12 """"")
              ])
            (Function 162:16-31
              (Identifier 162:16-20 skip) [
                (Function 162:21-30
                  (Identifier 162:21-26 maybe) [
                    (Identifier 162:27-29 nl)
                  ])
              ]))
          (Function 163:2-163
            (Identifier 163:2-9 default) [
              (Function 164:4-139
                (Identifier 164:4-14 many_until) [
                  (Or 165:6-104
                    (Identifier 165:6-24 _escaped_ctrl_char)
                    (Or 165:27-104
                      (Identifier 165:27-43 _escaped_unicode)
                      (Or 166:6-58
                        (Identifier 166:6-8 ws)
                        (Or 166:11-58
                          (TakeRight 166:11-26
                            (Merge 166:12-20
                              (String 166:12-15 "\")
                              (Identifier 166:18-20 ws))
                            (String 166:23-25 ""))
                          (Function 166:29-58
                            (Identifier 166:29-35 unless) [
                              (Identifier 166:36-40 char)
                              (Or 166:42-57
                                (Identifier 166:42-51 ctrl_char)
                                (String 166:54-57 "\"))
                            ])))))
                  (String 167:6-11 """"")
                ])
              (ValueLabel 169:4-5 (String 169:5-7 ""))
            ]))
        (Function 171:4-15
          (Identifier 171:4-8 skip) [
            (String 171:9-14 """"")
          ]))
      (Repeat 171:18-30
        (String 171:19-22 """)
        (Range 171:25-29 (NumberString 171:25-26 0) (NumberString 171:28-29 2)))))
  
  (DeclareGlobal 173:0-132
    (Identifier 173:0-25 string.multi_line_literal)
    (Merge 174:2-104
      (Merge 174:2-89
        (Merge 174:2-73
          (Merge 174:2-31
            (Function 174:2-13
              (Identifier 174:2-6 skip) [
                (String 174:7-12 "'''")
              ])
            (Function 174:16-31
              (Identifier 174:16-20 skip) [
                (Function 174:21-30
                  (Identifier 174:21-26 maybe) [
                    (Identifier 174:27-29 nl)
                  ])
              ]))
          (Function 175:2-39
            (Identifier 175:2-9 default) [
              (Function 175:10-33
                (Identifier 175:10-20 many_until) [
                  (Identifier 175:21-25 char)
                  (String 175:27-32 "'''")
                ])
              (ValueLabel 175:35-36 (String 175:36-38 ""))
            ]))
        (Function 176:4-15
          (Identifier 176:4-8 skip) [
            (String 176:9-14 "'''")
          ]))
      (Repeat 176:18-30
        (String 176:19-22 "'")
        (Range 176:25-29 (NumberString 176:25-26 0) (NumberString 176:28-29 2)))))
  
  (DeclareGlobal 178:0-45
    (Identifier 178:0-12 string.basic)
    (TakeLeft 178:15-45
      (TakeRight 178:15-39
        (String 178:15-18 """)
        (Identifier 178:21-39 _string.basic_body))
      (String 178:42-45 """)))
  
  (DeclareGlobal 180:0-133
    (Identifier 180:0-18 _string.basic_body)
    (Or 181:2-112
      (Function 181:2-99
        (Identifier 181:2-6 many) [
          (Or 182:4-87
            (Identifier 182:4-22 _escaped_ctrl_char)
            (Or 183:4-62
              (Identifier 183:4-20 _escaped_unicode)
              (Function 184:4-39
                (Identifier 184:4-10 unless) [
                  (Identifier 184:11-15 char)
                  (Or 184:17-38
                    (Identifier 184:17-26 ctrl_char)
                    (Or 184:29-38
                      (String 184:29-32 "\")
                      (String 184:35-38 """)))
                ])))
        ])
      (Function 185:6-16
        (Identifier 185:6-11 const) [
          (ValueLabel 185:12-13 (String 185:13-15 ""))
        ])))
  
  (DeclareGlobal 187:0-59
    (Identifier 187:0-14 string.literal)
    (TakeLeft 187:17-59
      (TakeRight 187:17-53
        (String 187:17-20 "'")
        (Function 187:23-53
          (Identifier 187:23-30 default) [
            (Function 187:31-47
              (Identifier 187:31-42 chars_until) [
                (String 187:43-46 "'")
              ])
            (ValueLabel 187:49-50 (String 187:50-52 ""))
          ]))
      (String 187:56-59 "'")))
  
  (DeclareGlobal 189:0-142
    (Identifier 189:0-18 _escaped_ctrl_char)
    (Or 190:2-121
      (Return 190:2-14
        (String 190:3-7 "\"")
        (String 190:10-13 """))
      (Or 191:2-104
        (Return 191:2-14
          (String 191:3-7 "\\")
          (String 191:10-13 "\"))
        (Or 192:2-87
          (Return 192:2-15
            (String 192:3-7 "\b")
            (String 192:10-14 "\x08")) (esc)
          (Or 193:2-69
            (Return 193:2-15
              (String 193:3-7 "\f")
              (String 193:10-14 "\x0c")) (esc)
            (Or 194:2-51
              (Return 194:2-15
                (String 194:3-7 "\n")
                (String 194:10-14 "
  "))
              (Or 195:2-33
                (Return 195:2-15
                  (String 195:3-7 "\r")
                  (String 195:10-14 "\r (no-eol) (esc)
  "))
                (Return 196:2-15
                  (String 196:3-7 "\t")
                  (String 196:10-14 "\t"))))))))) (esc)
  
  (DeclareGlobal 198:0-120
    (Identifier 198:0-16 _escaped_unicode)
    (Or 199:2-101
      (Return 199:2-49
        (Destructure 199:3-32
          (TakeRight 199:3-27
            (String 199:3-7 "\u")
            (Repeat 199:10-27
              (Identifier 199:11-22 hex_numeral)
              (NumberString 199:25-26 4)))
          (Identifier 199:31-32 U))
        (Function 199:35-48
          (Identifier 199:35-45 @Codepoint) [
            (Identifier 199:46-47 U)
          ]))
      (Return 200:2-49
        (Destructure 200:3-32
          (TakeRight 200:3-27
            (String 200:3-7 "\U")
            (Repeat 200:10-27
              (Identifier 200:11-22 hex_numeral)
              (NumberString 200:25-26 8)))
          (Identifier 200:31-32 U))
        (Function 200:35-48
          (Identifier 200:35-45 @Codepoint) [
            (Identifier 200:46-47 U)
          ]))))
  
  (DeclareGlobal 202:0-81
    (Identifier 202:0-15 datetime.offset)
    (Merge 202:18-81
      (Merge 202:18-57
        (Identifier 202:18-37 datetime.local_date)
        (Or 202:40-57
          (String 202:41-44 "T")
          (Or 202:47-56
            (String 202:47-50 "t")
            (String 202:53-56 " "))))
      (Identifier 202:60-81 _datetime.time_offset)))
  
  (DeclareGlobal 204:0-78
    (Identifier 204:0-14 datetime.local)
    (Merge 204:17-78
      (Merge 204:17-56
        (Identifier 204:17-36 datetime.local_date)
        (Or 204:39-56
          (String 204:40-43 "T")
          (Or 204:46-55
            (String 204:46-49 "t")
            (String 204:52-55 " "))))
      (Identifier 204:59-78 datetime.local_time)))
  
  (DeclareGlobal 206:0-85
    (Identifier 206:0-19 datetime.local_date)
    (Merge 207:2-63
      (Merge 207:2-46
        (Merge 207:2-40
          (Merge 207:2-22
            (Identifier 207:2-16 _datetime.year)
            (String 207:19-22 "-"))
          (Identifier 207:25-40 _datetime.month))
        (String 207:43-46 "-"))
      (Identifier 207:49-63 _datetime.mday)))
  
  (DeclareGlobal 209:0-28
    (Identifier 209:0-14 _datetime.year)
    (Repeat 209:17-28
      (Identifier 209:17-24 numeral)
      (NumberString 209:27-28 4)))
  
  (DeclareGlobal 211:0-53
    (Identifier 211:0-15 _datetime.month)
    (Or 211:18-53
      (Merge 211:18-34
        (String 211:19-22 "0")
        (Range 211:25-33 (String 211:25-28 "1") (String 211:30-33 "9")))
      (Merge 211:37-53
        (String 211:38-41 "1")
        (Range 211:44-52 (String 211:44-47 "0") (String 211:49-52 "2")))))
  
  (DeclareGlobal 213:0-52
    (Identifier 213:0-14 _datetime.mday)
    (Or 213:17-52
      (Merge 213:17-38
        (Range 213:18-26 (String 213:18-21 "0") (String 213:23-26 "2"))
        (Range 213:29-37 (String 213:29-32 "1") (String 213:34-37 "9")))
      (Or 213:41-52
        (String 213:41-45 "30")
        (String 213:48-52 "31"))))
  
  (DeclareGlobal 215:0-129
    (Identifier 215:0-19 datetime.local_time)
    (Merge 216:2-107
      (Merge 216:2-73
        (Merge 216:2-51
          (Merge 216:2-45
            (Merge 216:2-23
              (Identifier 216:2-17 _datetime.hours)
              (String 216:20-23 ":"))
            (Identifier 217:2-19 _datetime.minutes))
          (String 217:22-25 ":"))
        (Identifier 218:2-19 _datetime.seconds))
      (Function 219:2-31
        (Identifier 219:2-7 maybe) [
          (Merge 219:8-30
            (String 219:8-11 ".")
            (Repeat 219:14-30
              (Identifier 219:15-22 numeral)
              (Range 219:25-29 (NumberString 219:25-26 1) (NumberString 219:28-29 9))))
        ])))
  
  (DeclareGlobal 221:0-84
    (Identifier 221:0-21 _datetime.time_offset)
    (Merge 221:24-84
      (Identifier 221:24-43 datetime.local_time)
      (Or 221:46-84
        (String 221:47-50 "Z")
        (Or 221:53-83
          (String 221:53-56 "z")
          (Identifier 221:59-83 _datetime.time_numoffset)))))
  
  (DeclareGlobal 223:0-82
    (Identifier 223:0-24 _datetime.time_numoffset)
    (Merge 223:27-82
      (Merge 223:27-62
        (Merge 223:27-56
          (Or 223:27-38
            (String 223:28-31 "+")
            (String 223:34-37 "-"))
          (Identifier 223:41-56 _datetime.hours))
        (String 223:59-62 ":"))
      (Identifier 223:65-82 _datetime.minutes)))
  
  (DeclareGlobal 225:0-58
    (Identifier 225:0-15 _datetime.hours)
    (Or 225:18-58
      (Merge 225:18-39
        (Range 225:19-27 (String 225:19-22 "0") (String 225:24-27 "1"))
        (Range 225:30-38 (String 225:30-33 "0") (String 225:35-38 "9")))
      (Merge 225:42-58
        (String 225:43-46 "2")
        (Range 225:49-57 (String 225:49-52 "0") (String 225:54-57 "3")))))
  
  (DeclareGlobal 227:0-39
    (Identifier 227:0-17 _datetime.minutes)
    (Merge 227:20-39
      (Range 227:20-28 (String 227:20-23 "0") (String 227:25-28 "5"))
      (Range 227:31-39 (String 227:31-34 "0") (String 227:36-39 "9"))))
  
  (DeclareGlobal 229:0-48
    (Identifier 229:0-17 _datetime.seconds)
    (Or 229:20-48
      (Merge 229:20-41
        (Range 229:21-29 (String 229:21-24 "0") (String 229:26-29 "5"))
        (Range 229:32-40 (String 229:32-35 "0") (String 229:37-40 "9")))
      (String 229:44-48 "60")))
  
  (DeclareGlobal 231:0-69
    (Identifier 231:0-14 number.integer)
    (Function 231:17-69
      (Identifier 231:17-26 as_number) [
        (Merge 232:2-39
          (Identifier 232:2-14 _number.sign)
          (Identifier 233:2-22 _number.integer_part))
      ]))
  
  (DeclareGlobal 236:0-37
    (Identifier 236:0-12 _number.sign)
    (Function 236:15-37
      (Identifier 236:15-20 maybe) [
        (Or 236:21-36
          (String 236:21-24 "-")
          (Function 236:27-36
            (Identifier 236:27-31 skip) [
              (String 236:32-35 "+")
            ]))
      ]))
  
  (DeclareGlobal 238:0-74
    (Identifier 238:0-20 _number.integer_part)
    (Or 239:2-51
      (Merge 239:2-41
        (Range 239:3-11 (String 239:3-6 "1") (String 239:8-11 "9"))
        (Function 239:14-40
          (Identifier 239:14-18 many) [
            (TakeRight 239:19-39
              (Function 239:19-29
                (Identifier 239:19-24 maybe) [
                  (String 239:25-28 "_")
                ])
              (Identifier 239:32-39 numeral))
          ]))
      (Identifier 239:44-51 numeral)))
  
  (DeclareGlobal 241:0-162
    (Identifier 241:0-12 number.float)
    (Function 241:15-162
      (Identifier 241:15-24 as_number) [
        (Merge 242:2-134
          (Merge 242:2-39
            (Identifier 242:2-14 _number.sign)
            (Identifier 243:2-22 _number.integer_part))
          (Or 243:25-117
            (Merge 244:4-58
              (Identifier 244:5-26 _number.fraction_part)
              (Function 244:29-57
                (Identifier 244:29-34 maybe) [
                  (Identifier 244:35-56 _number.exponent_part)
                ]))
            (Identifier 245:4-25 _number.exponent_part)))
      ]))
  
  (DeclareGlobal 249:0-60
    (Identifier 249:0-21 _number.fraction_part)
    (Merge 249:24-60
      (String 249:24-27 ".")
      (Function 249:30-60
        (Identifier 249:30-38 many_sep) [
          (Identifier 249:39-47 numerals)
          (Function 249:49-59
            (Identifier 249:49-54 maybe) [
              (String 249:55-58 "_")
            ])
        ])))
  
  (DeclareGlobal 251:0-89
    (Identifier 251:0-21 _number.exponent_part)
    (Merge 252:2-65
      (Merge 252:2-32
        (Or 252:2-13
          (String 252:3-6 "e")
          (String 252:9-12 "E"))
        (Function 252:16-32
          (Identifier 252:16-21 maybe) [
            (Or 252:22-31
              (String 252:22-25 "-")
              (String 252:28-31 "+"))
          ]))
      (Function 252:35-65
        (Identifier 252:35-43 many_sep) [
          (Identifier 252:44-52 numerals)
          (Function 252:54-64
            (Identifier 252:54-59 maybe) [
              (String 252:60-63 "_")
            ])
        ])))
  
  (DeclareGlobal 254:0-42
    (Identifier 254:0-15 number.infinity)
    (Merge 254:18-42
      (Function 254:18-34
        (Identifier 254:18-23 maybe) [
          (Or 254:24-33
            (String 254:24-27 "+")
            (String 254:30-33 "-"))
        ])
      (String 254:37-42 "inf")))
  
  (DeclareGlobal 256:0-46
    (Identifier 256:0-19 number.not_a_number)
    (Merge 256:22-46
      (Function 256:22-38
        (Identifier 256:22-27 maybe) [
          (Or 256:28-37
            (String 256:28-31 "+")
            (String 256:34-37 "-"))
        ])
      (String 256:41-46 "nan")))
  
  (DeclareGlobal 258:0-204
    (Identifier 258:0-21 number.binary_integer)
    (TakeRight 259:2-180
      (String 259:2-6 "0b")
      (Return 259:9-180
        (Destructure 259:9-147
          (Function 259:9-137
            (Identifier 259:9-20 one_or_both) [
              (Merge 260:4-70
                (Function 260:4-28
                  (Identifier 260:4-13 array_sep) [
                    (NumberString 260:14-15 0)
                    (Function 260:17-27
                      (Identifier 260:17-22 maybe) [
                        (String 260:23-26 "_")
                      ])
                  ])
                (Function 260:31-70
                  (Identifier 260:31-36 maybe) [
                    (TakeLeft 260:37-69
                      (Function 260:37-46
                        (Identifier 260:37-41 skip) [
                          (String 260:42-45 "_")
                        ])
                      (Function 260:49-69
                        (Identifier 260:49-53 peek) [
                          (Identifier 260:54-68 binary_numeral)
                        ]))
                  ]))
              (Function 261:4-39
                (Identifier 261:4-13 array_sep) [
                  (Identifier 261:14-26 binary_digit)
                  (Function 261:28-38
                    (Identifier 261:28-33 maybe) [
                      (String 261:34-37 "_")
                    ])
                ])
            ])
          (Identifier 262:7-13 Digits))
        (Function 263:2-30
          (Identifier 263:2-22 Num.FromBinaryDigits) [
            (Identifier 263:23-29 Digits)
          ]))))
  
  (DeclareGlobal 265:0-200
    (Identifier 265:0-20 number.octal_integer)
    (TakeRight 266:2-177
      (String 266:2-6 "0o")
      (Return 266:9-177
        (Destructure 266:9-145
          (Function 266:9-135
            (Identifier 266:9-20 one_or_both) [
              (Merge 267:4-69
                (Function 267:4-28
                  (Identifier 267:4-13 array_sep) [
                    (NumberString 267:14-15 0)
                    (Function 267:17-27
                      (Identifier 267:17-22 maybe) [
                        (String 267:23-26 "_")
                      ])
                  ])
                (Function 267:31-69
                  (Identifier 267:31-36 maybe) [
                    (TakeLeft 267:37-68
                      (Function 267:37-46
                        (Identifier 267:37-41 skip) [
                          (String 267:42-45 "_")
                        ])
                      (Function 267:49-68
                        (Identifier 267:49-53 peek) [
                          (Identifier 267:54-67 octal_numeral)
                        ]))
                  ]))
              (Function 268:4-38
                (Identifier 268:4-13 array_sep) [
                  (Identifier 268:14-25 octal_digit)
                  (Function 268:27-37
                    (Identifier 268:27-32 maybe) [
                      (String 268:33-36 "_")
                    ])
                ])
            ])
          (Identifier 269:7-13 Digits))
        (Function 270:2-29
          (Identifier 270:2-21 Num.FromOctalDigits) [
            (Identifier 270:22-28 Digits)
          ]))))
  
  (DeclareGlobal 272:0-192
    (Identifier 272:0-18 number.hex_integer)
    (TakeRight 273:2-171
      (String 273:2-6 "0x")
      (Return 273:9-171
        (Destructure 273:9-141
          (Function 273:9-131
            (Identifier 273:9-20 one_or_both) [
              (Merge 274:4-67
                (Function 274:4-28
                  (Identifier 274:4-13 array_sep) [
                    (NumberString 274:14-15 0)
                    (Function 274:17-27
                      (Identifier 274:17-22 maybe) [
                        (String 274:23-26 "_")
                      ])
                  ])
                (Function 274:31-67
                  (Identifier 274:31-36 maybe) [
                    (TakeLeft 274:37-66
                      (Function 274:37-46
                        (Identifier 274:37-41 skip) [
                          (String 274:42-45 "_")
                        ])
                      (Function 274:49-66
                        (Identifier 274:49-53 peek) [
                          (Identifier 274:54-65 hex_numeral)
                        ]))
                  ]))
              (Function 275:4-36
                (Identifier 275:4-13 array_sep) [
                  (Identifier 275:14-23 hex_digit)
                  (Function 275:25-35
                    (Identifier 275:25-30 maybe) [
                      (String 275:31-34 "_")
                    ])
                ])
            ])
          (Identifier 276:7-13 Digits))
        (Function 277:2-27
          (Identifier 277:2-19 Num.FromHexDigits) [
            (Identifier 277:20-26 Digits)
          ]))))
  
  (DeclareGlobal 279:0-38
    (Identifier 279:0-10 _Doc.Empty)
    (Object 279:13-38 [
      (ObjectPair (String 279:14-21 "value") (Object 279:23-26 []))
      (ObjectPair (String 279:27-33 "type") (Object 279:35-38 []))
    ]))
  
  (DeclareGlobal 281:0-39
    (Function 281:0-15
      (Identifier 281:0-10 _Doc.Value) [
        (Identifier 281:11-14 Doc)
      ])
    (Function 281:18-39
      (Identifier 281:18-25 Obj.Get) [
        (Identifier 281:26-29 Doc)
        (String 281:31-38 "value")
      ]))
  
  (DeclareGlobal 283:0-37
    (Function 283:0-14
      (Identifier 283:0-9 _Doc.Type) [
        (Identifier 283:10-13 Doc)
      ])
    (Function 283:17-37
      (Identifier 283:17-24 Obj.Get) [
        (Identifier 283:25-28 Doc)
        (String 283:30-36 "type")
      ]))
  
  (DeclareGlobal 285:0-49
    (Function 285:0-18
      (Identifier 285:0-8 _Doc.Has) [
        (Identifier 285:9-12 Doc)
        (Identifier 285:14-17 Key)
      ])
    (Function 285:21-49
      (Identifier 285:21-28 Obj.Has) [
        (Function 285:29-43
          (Identifier 285:29-38 _Doc.Type) [
            (Identifier 285:39-42 Doc)
          ])
        (Identifier 285:45-48 Key)
      ]))
  
  (DeclareGlobal 287:0-106
    (Function 287:0-18
      (Identifier 287:0-8 _Doc.Get) [
        (Identifier 287:9-12 Doc)
        (Identifier 287:14-17 Key)
      ])
    (Object 287:21-106 [
      (ObjectPair
        (String 288:2-9 "value")
        (Function 288:11-40
          (Identifier 288:11-18 Obj.Get) [
            (Function 288:19-34
              (Identifier 288:19-29 _Doc.Value) [
                (Identifier 288:30-33 Doc)
              ])
            (Identifier 288:36-39 Key)
          ]))
      (ObjectPair
        (String 289:2-8 "type")
        (Function 289:10-38
          (Identifier 289:10-17 Obj.Get) [
            (Function 289:18-32
              (Identifier 289:18-27 _Doc.Type) [
                (Identifier 289:28-31 Doc)
              ])
            (Identifier 289:34-37 Key)
          ]))
    ]))
  
  (DeclareGlobal 292:0-45
    (Function 292:0-17
      (Identifier 292:0-12 _Doc.IsTable) [
        (Identifier 292:13-16 Doc)
      ])
    (Function 292:20-45
      (Identifier 292:20-29 Is.Object) [
        (Function 292:30-44
          (Identifier 292:30-39 _Doc.Type) [
            (Identifier 292:40-43 Doc)
          ])
      ]))
  
  (DeclareGlobal 294:0-161
    (Function 294:0-32
      (Identifier 294:0-11 _Doc.Insert) [
        (Identifier 294:12-15 Doc)
        (Identifier 294:17-20 Key)
        (Identifier 294:22-25 Val)
        (Identifier 294:27-31 Type)
      ])
    (TakeRight 295:2-126
      (Function 295:2-19
        (Identifier 295:2-14 _Doc.IsTable) [
          (Identifier 295:15-18 Doc)
        ])
      (Object 296:2-104 [
        (ObjectPair
          (String 297:4-11 "value")
          (Function 297:13-47
            (Identifier 297:13-20 Obj.Put) [
              (Function 297:21-36
                (Identifier 297:21-31 _Doc.Value) [
                  (Identifier 297:32-35 Doc)
                ])
              (Identifier 297:38-41 Key)
              (Identifier 297:43-46 Val)
            ]))
        (ObjectPair
          (String 298:4-10 "type")
          (Function 298:12-46
            (Identifier 298:12-19 Obj.Put) [
              (Function 298:20-34
                (Identifier 298:20-29 _Doc.Type) [
                  (Identifier 298:30-33 Doc)
                ])
              (Identifier 298:36-39 Key)
              (Identifier 298:41-45 Type)
            ]))
      ])))
  
  (DeclareGlobal 301:0-254
    (Function 301:0-48
      (Identifier 301:0-26 _Doc.AppendToArrayOfTables) [
        (Identifier 301:27-30 Doc)
        (Identifier 301:32-35 Key)
        (Identifier 301:37-47 ElementDoc)
      ])
    (TakeRight 302:2-203
      (Destructure 302:2-70
        (Function 302:2-20
          (Identifier 302:2-10 _Doc.Get) [
            (Identifier 302:11-14 Doc)
            (Identifier 302:16-19 Key)
          ])
        (Object 302:24-70 [
          (ObjectPair (String 302:25-32 "value") (Identifier 302:34-36 Vs))
          (ObjectPair
            (String 302:38-44 "type")
            (Array 302:46-69 [
              (String 302:47-64 "array_of_tables")
              (Identifier 302:66-68 Ts)
            ]))
        ]))
      (Function 303:2-130
        (Identifier 303:2-13 _Doc.Insert) [
          (Identifier 304:4-7 Doc)
          (Identifier 305:4-7 Key)
          (Merge 306:4-35
            (Merge 306:4-5
              (Array 306:4-5 [])
              (Identifier 306:8-10 Vs))
            (Array 306:12-35 [
              (Function 306:12-34
                (Identifier 306:12-22 _Doc.Value) [
                  (Identifier 306:23-33 ElementDoc)
                ])
            ]))
          (Array 307:4-55 [
            (String 307:5-22 "array_of_tables")
            (Merge 307:24-54
              (Merge 307:24-25
                (Array 307:24-25 [])
                (Identifier 307:28-30 Ts))
              (Array 307:32-54 [
                (Function 307:32-53
                  (Identifier 307:32-41 _Doc.Type) [
                    (Identifier 307:42-52 ElementDoc)
                  ])
              ]))
          ])
        ])))
  
  (DeclareGlobal 310:0-90
    (Function 310:0-33
      (Identifier 310:0-17 _Doc.InsertAtPath) [
        (Identifier 310:18-21 Doc)
        (Identifier 310:23-27 Path)
        (Identifier 310:29-32 Val)
      ])
    (Function 311:2-54
      (Identifier 311:2-19 _Doc.UpdateAtPath) [
        (Identifier 311:20-23 Doc)
        (Identifier 311:25-29 Path)
        (Identifier 311:31-34 Val)
        (Identifier 311:36-53 _Doc.ValueUpdater)
      ]))
  
  (DeclareGlobal 313:0-102
    (Function 313:0-33
      (Identifier 313:0-22 _Doc.EnsureTableAtPath) [
        (Identifier 313:23-26 Doc)
        (Identifier 313:28-32 Path)
      ])
    (Function 314:2-66
      (Identifier 314:2-25 _Doc.UpdateAtHeaderPath) [
        (Identifier 314:26-29 Doc)
        (Identifier 314:31-35 Path)
        (Object 314:37-40 [])
        (Identifier 314:41-65 _Doc.MissingTableUpdater)
      ]))
  
  (DeclareGlobal 316:0-111
    (Function 316:0-40
      (Identifier 316:0-17 _Doc.AppendAtPath) [
        (Identifier 316:18-21 Doc)
        (Identifier 316:23-27 Path)
        (Identifier 316:29-39 ElementDoc)
      ])
    (Function 317:2-68
      (Identifier 317:2-25 _Doc.UpdateAtHeaderPath) [
        (Identifier 317:26-29 Doc)
        (Identifier 317:31-35 Path)
        (Identifier 317:37-47 ElementDoc)
        (Identifier 317:49-67 _Doc.AppendUpdater)
      ]))
  
  (DeclareGlobal 319:0-439
    (Function 319:0-42
      (Identifier 319:0-17 _Doc.UpdateAtPath) [
        (Identifier 319:18-21 Doc)
        (Identifier 319:23-27 Path)
        (Identifier 319:29-32 Val)
        (Identifier 319:34-41 Updater)
      ])
    (Conditional 320:2-394
      (Destructure 320:2-15
        (Identifier 320:2-6 Path)
        (Array 320:10-15 [
          (Identifier 320:11-14 Key)
        ]))
      (Function 320:18-40
        (Identifier 320:18-25 Updater) [
          (Identifier 320:26-29 Doc)
          (Identifier 320:31-34 Key)
          (Identifier 320:36-39 Val)
        ])
      (Conditional 321:2-351
        (Destructure 321:2-28
          (Identifier 321:2-6 Path)
          (Merge 321:10-28
            (Array 321:10-11 [
              (Identifier 321:11-14 Key)
            ])
            (Identifier 321:19-27 PathRest)))
        (TakeRight 321:31-343
          (Destructure 322:4-235
            (Conditional 322:4-223
              (Function 323:6-24
                (Identifier 323:6-14 _Doc.Has) [
                  (Identifier 323:15-18 Doc)
                  (Identifier 323:20-23 Key)
                ])
              (TakeRight 323:27-149
                (Function 324:8-40
                  (Identifier 324:8-20 _Doc.IsTable) [
                    (Function 324:21-39
                      (Identifier 324:21-29 _Doc.Get) [
                        (Identifier 324:30-33 Doc)
                        (Identifier 324:35-38 Key)
                      ])
                  ])
                (Function 325:8-69
                  (Identifier 325:8-25 _Doc.UpdateAtPath) [
                    (Function 325:26-44
                      (Identifier 325:26-34 _Doc.Get) [
                        (Identifier 325:35-38 Doc)
                        (Identifier 325:40-43 Key)
                      ])
                    (Identifier 325:46-54 PathRest)
                    (Identifier 325:56-59 Val)
                    (Identifier 325:61-68 Updater)
                  ]))
              (Function 327:6-59
                (Identifier 327:6-23 _Doc.UpdateAtPath) [
                  (Identifier 327:24-34 _Doc.Empty)
                  (Identifier 327:36-44 PathRest)
                  (Identifier 327:46-49 Val)
                  (Identifier 327:51-58 Updater)
                ]))
            (Identifier 328:9-17 InnerDoc))
          (Function 329:4-68
            (Identifier 329:4-15 _Doc.Insert) [
              (Identifier 329:16-19 Doc)
              (Identifier 329:21-24 Key)
              (Function 329:26-46
                (Identifier 329:26-36 _Doc.Value) [
                  (Identifier 329:37-45 InnerDoc)
                ])
              (Function 329:48-67
                (Identifier 329:48-57 _Doc.Type) [
                  (Identifier 329:58-66 InnerDoc)
                ])
            ]))
        (Identifier 331:2-5 Doc))))
  
  (DeclareGlobal 333:0-101
    (Function 333:0-32
      (Identifier 333:0-17 _Doc.ValueUpdater) [
        (Identifier 333:18-21 Doc)
        (Identifier 333:23-26 Key)
        (Identifier 333:28-31 Val)
      ])
    (Conditional 334:2-66
      (Function 334:2-20
        (Identifier 334:2-10 _Doc.Has) [
          (Identifier 334:11-14 Doc)
          (Identifier 334:16-19 Key)
        ])
      (Identifier 334:23-28 @Fail)
      (Function 334:31-66
        (Identifier 334:31-42 _Doc.Insert) [
          (Identifier 334:43-46 Doc)
          (Identifier 334:48-51 Key)
          (Identifier 334:53-56 Val)
          (String 334:58-65 "value")
        ])))
  
  (DeclareGlobal 336:0-142
    (Function 336:0-40
      (Identifier 336:0-24 _Doc.MissingTableUpdater) [
        (Identifier 336:25-28 Doc)
        (Identifier 336:30-33 Key)
        (Identifier 336:35-39 _Val)
      ])
    (Conditional 337:2-99
      (Function 337:2-20
        (Identifier 337:2-10 _Doc.Has) [
          (Identifier 337:11-14 Doc)
          (Identifier 337:16-19 Key)
        ])
      (TakeRight 338:2-42
        (Function 338:3-35
          (Identifier 338:3-15 _Doc.IsTable) [
            (Function 338:16-34
              (Identifier 338:16-24 _Doc.Get) [
                (Identifier 338:25-28 Doc)
                (Identifier 338:30-33 Key)
              ])
          ])
        (Identifier 338:38-41 Doc))
      (Function 339:2-31
        (Identifier 339:2-13 _Doc.Insert) [
          (Identifier 339:14-17 Doc)
          (Identifier 339:19-22 Key)
          (Object 339:24-27 [])
          (Object 339:28-31 [])
        ])))
  
  (DeclareGlobal 341:0-210
    (Function 341:0-40
      (Identifier 341:0-18 _Doc.AppendUpdater) [
        (Identifier 341:19-22 Doc)
        (Identifier 341:24-27 Key)
        (Identifier 341:29-39 ElementDoc)
      ])
    (TakeRight 342:2-167
      (Destructure 342:2-107
        (Conditional 342:2-93
          (Function 343:4-22
            (Identifier 343:4-12 _Doc.Has) [
              (Identifier 343:13-16 Doc)
              (Identifier 343:18-21 Key)
            ])
          (Identifier 343:25-28 Doc)
          (Function 344:4-54
            (Identifier 344:4-15 _Doc.Insert) [
              (Identifier 344:16-19 Doc)
              (Identifier 344:21-24 Key)
              (Array 344:26-29 [])
              (Array 344:30-53 [
                (String 344:31-48 "array_of_tables")
                (Array 344:50-53 [])
              ])
            ]))
        (Identifier 345:7-17 DocWithKey))
      (Function 346:2-57
        (Identifier 346:2-28 _Doc.AppendToArrayOfTables) [
          (Identifier 346:29-39 DocWithKey)
          (Identifier 346:41-44 Key)
          (Identifier 346:46-56 ElementDoc)
        ])))
  
  (DeclareGlobal 348:0-197
    (Function 348:0-58
      (Identifier 348:0-27 _Doc.InsertPairAtHeaderPath) [
        (Identifier 348:28-31 Doc)
        (Identifier 348:33-43 HeaderPath)
        (Identifier 348:45-52 KeyPath)
        (Identifier 348:54-57 Val)
      ])
    (Conditional 349:2-136
      (Destructure 349:2-20
        (Identifier 349:2-12 HeaderPath)
        (Array 349:16-20 []))
      (Function 349:21-57
        (Identifier 349:21-38 _Doc.InsertAtPath) [
          (Identifier 349:39-42 Doc)
          (Identifier 349:44-51 KeyPath)
          (Identifier 349:53-56 Val)
        ])
      (Function 350:2-76
        (Identifier 350:2-25 _Doc.UpdateAtHeaderPath) [
          (Identifier 350:26-29 Doc)
          (Identifier 350:31-41 HeaderPath)
          (Array 350:43-57 [
            (Identifier 350:44-51 KeyPath)
            (Identifier 350:53-56 Val)
          ])
          (Identifier 350:59-75 _Doc.PairUpdater)
        ])))
  
  (DeclareGlobal 352:0-299
    (Function 352:0-41
      (Identifier 352:0-16 _Doc.PairUpdater) [
        (Identifier 352:17-20 Doc)
        (Identifier 352:22-25 Key)
        (Identifier 352:27-40 KeyPathAndVal)
      ])
    (TakeRight 353:2-255
      (TakeRight 353:2-184
        (TakeRight 353:2-127
          (TakeRight 353:2-102
            (Destructure 353:2-33
              (Identifier 353:2-15 KeyPathAndVal)
              (Array 353:19-33 [
                (Identifier 353:20-27 KeyPath)
                (Identifier 353:29-32 Val)
              ]))
            (Destructure 354:2-66
              (Conditional 354:2-56
                (Function 354:3-21
                  (Identifier 354:3-11 _Doc.Has) [
                    (Identifier 354:12-15 Doc)
                    (Identifier 354:17-20 Key)
                  ])
                (Function 354:24-42
                  (Identifier 354:24-32 _Doc.Get) [
                    (Identifier 354:33-36 Doc)
                    (Identifier 354:38-41 Key)
                  ])
                (Identifier 354:45-55 _Doc.Empty))
              (Identifier 354:60-66 SubDoc)))
          (Function 355:2-22
            (Identifier 355:2-14 _Doc.IsTable) [
              (Identifier 355:15-21 SubDoc)
            ]))
        (Destructure 356:2-54
          (Function 356:2-41
            (Identifier 356:2-19 _Doc.InsertAtPath) [
              (Identifier 356:20-26 SubDoc)
              (Identifier 356:28-35 KeyPath)
              (Identifier 356:37-40 Val)
            ])
          (Identifier 356:45-54 NewSubDoc)))
      (Function 357:2-68
        (Identifier 357:2-13 _Doc.Insert) [
          (Identifier 357:14-17 Doc)
          (Identifier 357:19-22 Key)
          (Function 357:24-45
            (Identifier 357:24-34 _Doc.Value) [
              (Identifier 357:35-44 NewSubDoc)
            ])
          (Function 357:47-67
            (Identifier 357:47-56 _Doc.Type) [
              (Identifier 357:57-66 NewSubDoc)
            ])
        ])))
  
  (DeclareGlobal 359:0-190
    (Function 359:0-48
      (Identifier 359:0-23 _Doc.UpdateAtHeaderPath) [
        (Identifier 359:24-27 Doc)
        (Identifier 359:29-33 Path)
        (Identifier 359:35-38 Val)
        (Identifier 359:40-47 Updater)
      ])
    (Conditional 360:2-139
      (Destructure 360:2-15
        (Identifier 360:2-6 Path)
        (Array 360:10-15 [
          (Identifier 360:11-14 Key)
        ]))
      (Function 360:18-40
        (Identifier 360:18-25 Updater) [
          (Identifier 360:26-29 Doc)
          (Identifier 360:31-34 Key)
          (Identifier 360:36-39 Val)
        ])
      (Conditional 361:2-96
        (Destructure 361:2-28
          (Identifier 361:2-6 Path)
          (Merge 361:10-28
            (Array 361:10-11 [
              (Identifier 361:11-14 Key)
            ])
            (Identifier 361:19-27 PathRest)))
        (Function 362:2-57
          (Identifier 362:2-23 _Doc.DescendHeaderKey) [
            (Identifier 362:24-27 Doc)
            (Identifier 362:29-32 Key)
            (Identifier 362:34-42 PathRest)
            (Identifier 362:44-47 Val)
            (Identifier 362:49-56 Updater)
          ])
        (Identifier 363:2-5 Doc))))
  
  (DeclareGlobal 365:0-587
    (Function 365:0-55
      (Identifier 365:0-21 _Doc.DescendHeaderKey) [
        (Identifier 365:22-25 Doc)
        (Identifier 365:27-30 Key)
        (Identifier 365:32-40 PathRest)
        (Identifier 365:42-45 Val)
        (Identifier 365:47-54 Updater)
      ])
    (Conditional 366:2-529
      (Function 366:2-20
        (Identifier 366:2-10 _Doc.Has) [
          (Identifier 366:11-14 Doc)
          (Identifier 366:16-19 Key)
        ])
      (TakeRight 366:23-374
        (TakeRight 367:4-276
          (Destructure 367:4-33
            (Function 367:4-22
              (Identifier 367:4-12 _Doc.Get) [
                (Identifier 367:13-16 Doc)
                (Identifier 367:18-21 Key)
              ])
            (Identifier 367:26-33 Current))
          (Destructure 368:4-240
            (Conditional 368:4-229
              (Destructure 369:6-53
                (Function 369:6-24
                  (Identifier 369:6-15 _Doc.Type) [
                    (Identifier 369:16-23 Current)
                  ])
                (Merge 369:28-53
                  (Array 369:28-29 [
                    (String 369:29-46 "array_of_tables")
                  ])
                  (Identifier 369:51-52 _)))
              (Function 370:6-66
                (Identifier 370:6-33 _Doc.UpdateAtLastAoTElement) [
                  (Identifier 370:34-41 Current)
                  (Identifier 370:43-51 PathRest)
                  (Identifier 370:53-56 Val)
                  (Identifier 370:58-65 Updater)
                ])
              (TakeRight 371:6-92
                (Function 371:6-27
                  (Identifier 371:6-18 _Doc.IsTable) [
                    (Identifier 371:19-26 Current)
                  ])
                (Function 372:6-62
                  (Identifier 372:6-29 _Doc.UpdateAtHeaderPath) [
                    (Identifier 372:30-37 Current)
                    (Identifier 372:39-47 PathRest)
                    (Identifier 372:49-52 Val)
                    (Identifier 372:54-61 Updater)
                  ])))
            (Identifier 373:9-16 Updated)))
        (Function 374:4-66
          (Identifier 374:4-15 _Doc.Insert) [
            (Identifier 374:16-19 Doc)
            (Identifier 374:21-24 Key)
            (Function 374:26-45
              (Identifier 374:26-36 _Doc.Value) [
                (Identifier 374:37-44 Updated)
              ])
            (Function 374:47-65
              (Identifier 374:47-56 _Doc.Type) [
                (Identifier 374:57-64 Updated)
              ])
          ]))
      (TakeRight 375:6-158
        (Destructure 376:4-75
          (Function 376:4-63
            (Identifier 376:4-27 _Doc.UpdateAtHeaderPath) [
              (Identifier 376:28-38 _Doc.Empty)
              (Identifier 376:40-48 PathRest)
              (Identifier 376:50-53 Val)
              (Identifier 376:55-62 Updater)
            ])
          (Identifier 376:67-75 InnerDoc))
        (Function 377:4-68
          (Identifier 377:4-15 _Doc.Insert) [
            (Identifier 377:16-19 Doc)
            (Identifier 377:21-24 Key)
            (Function 377:26-46
              (Identifier 377:26-36 _Doc.Value) [
                (Identifier 377:37-45 InnerDoc)
              ])
            (Function 377:48-67
              (Identifier 377:48-57 _Doc.Type) [
                (Identifier 377:58-66 InnerDoc)
              ])
          ]))))
  
  (DeclareGlobal 380:0-408
    (Function 380:0-59
      (Identifier 380:0-27 _Doc.UpdateAtLastAoTElement) [
        (Identifier 380:28-34 AoTDoc)
        (Identifier 380:36-44 PathRest)
        (Identifier 380:46-49 Val)
        (Identifier 380:51-58 Updater)
      ])
    (TakeRight 381:2-346
      (TakeRight 381:2-215
        (TakeRight 381:2-107
          (Destructure 381:2-42
            (Function 381:2-20
              (Identifier 381:2-12 _Doc.Value) [
                (Identifier 381:13-19 AoTDoc)
              ])
            (Merge 381:24-42
              (Merge 381:24-25
                (Array 381:24-25 [])
                (Identifier 381:28-34 VsInit))
              (Array 381:36-42 [
                (Identifier 381:36-41 VLast)
              ])))
          (Destructure 382:2-62
            (Function 382:2-19
              (Identifier 382:2-11 _Doc.Type) [
                (Identifier 382:12-18 AoTDoc)
              ])
            (Array 382:23-62 [
              (String 382:24-41 "array_of_tables")
              (Merge 382:43-61
                (Merge 382:43-44
                  (Array 382:43-44 [])
                  (Identifier 382:47-53 TsInit))
                (Array 382:55-61 [
                  (Identifier 382:55-60 TLast)
                ]))
            ])))
        (Destructure 383:2-105
          (Function 383:2-90
            (Identifier 383:2-25 _Doc.UpdateAtHeaderPath) [
              (Object 384:4-35 [
                (ObjectPair (String 384:5-12 "value") (Identifier 384:14-19 VLast))
                (ObjectPair (String 384:21-27 "type") (Identifier 384:29-34 TLast))
              ])
              (Identifier 384:37-45 PathRest)
              (Identifier 384:47-50 Val)
              (Identifier 384:52-59 Updater)
            ])
          (Identifier 385:7-18 UpdatedLast)))
      (Object 386:2-128 [
        (ObjectPair
          (String 387:4-11 "value")
          (Merge 387:13-49
            (Merge 387:13-14
              (Array 387:13-14 [])
              (Identifier 387:17-23 VsInit))
            (Array 387:25-49 [
              (Function 387:25-48
                (Identifier 387:25-35 _Doc.Value) [
                  (Identifier 387:36-47 UpdatedLast)
                ])
            ])))
        (ObjectPair
          (String 388:4-10 "type")
          (Array 388:12-68 [
            (String 388:13-30 "array_of_tables")
            (Merge 388:32-67
              (Merge 388:32-33
                (Array 388:32-33 [])
                (Identifier 388:36-42 TsInit))
              (Array 388:44-67 [
                (Function 388:44-66
                  (Identifier 388:44-53 _Doc.Type) [
                    (Identifier 388:54-65 UpdatedLast)
                  ])
              ]))
          ]))
      ])))
