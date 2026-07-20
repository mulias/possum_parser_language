Full created-stage goal form of stdlib/toml.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/toml.possum -i '' --no-stdlib
  simple =
    (call custom [simple_value])
  
  tagged =
    (call custom [tagged_value])
  
  custom(value) =
    (seq result=1
      (seq result=1
        (call maybe [
          (lambda @fn0
            (merge (call _comments) (call maybe [ws])))
        ])
        (match
          scrutinee: (alt
            (arm
              guard: (call _with_root_table [value~0]))
            (arm
              body: (call _no_root_table [value~0])))
          %0 = scrutinee
          (arm
            (bind %0 Doc~1))))
      (seq result=1
        (call maybe [
          (lambda @fn1
            (merge (call maybe [ws]) (call _comments)))
        ])
        (call _Doc.Value [Doc~1])))
  
  _with_root_table(value) =
    (seq result=1
      (match
        scrutinee: (call _root_table [value~0 _Doc.Empty])
        %0 = scrutinee
        (arm
          (bind %0 RootDoc~1)))
      (alt
        (arm
          guard: (seq result=1
            (call _ws)
            (call _tables [value~0 RootDoc~1])))
        (arm
          body: (call const [RootDoc~1]))))
  
  _root_table(value, Doc) =
    (call _table_body [
      value~0
      (array [])
      Doc~1
    ])
  
  _no_root_table(value) =
    (seq result=1
      (match
        scrutinee: (alt
          (arm
            guard: (call _table [value~0 _Doc.Empty]))
          (arm
            body: (call _array_of_tables [value~0 _Doc.Empty])))
        %0 = scrutinee
        (arm
          (bind %0 NewDoc~1)))
      (call _tables [value~0 NewDoc~1]))
  
  _tables(value, Doc) =
    (alt
      (arm
        guard: (match
          scrutinee: (alt
            (arm
              guard: (seq result=1
                (call _ws)
                (call _table [value~0 Doc~1])))
            (arm
              body: (call _array_of_tables [value~0 Doc~1])))
          %0 = scrutinee
          (arm
            (bind %0 NewDoc~2)))
        body: (call _tables [value~0 NewDoc~2]))
      (arm
        body: (call const [Doc~1])))
  
  _table(value, Doc) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call _table_header)
          %0 = scrutinee
          (arm
            (bind %0 HeaderPath~2)))
        (call _ws_newline))
      (alt
        (arm
          guard: (call _table_body [value~0 HeaderPath~2 Doc~1]))
        (arm
          body: (call const [(call _Doc.EnsureTableAtPath [Doc~1 HeaderPath~2])]))))
  
  _array_of_tables(value, Doc) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call _array_of_tables_header)
          %0 = scrutinee
          (arm
            (bind %0 HeaderPath~2)))
        (call _ws_newline))
      (seq result=1
        (match
          scrutinee: (call default [
            (lambda @fn2 captures=[value]
              (call _table_body [
                value~0
                (array [])
                _Doc.Empty
              ]))
            _Doc.Empty
          ])
          %0 = scrutinee
          (arm
            (bind %0 InnerDoc~3)))
        (call _Doc.AppendAtPath [Doc~1 HeaderPath~2 InnerDoc~3])))
  
  _ws =
    (call maybe_many [
      (lambda @fn3
        (alt
          (arm
            guard: (call ws))
          (arm
            body: (call _comment))))
    ])
  
  _ws_line =
    (call maybe_many [
      (lambda @fn4
        (alt
          (arm
            guard: (call spaces))
          (arm
            body: (call _comment))))
    ])
  
  _ws_newline =
    (merge
      (merge
        (call _ws_line)
        (alt
          (arm
            guard: (call nl))
          (arm
            body: (call end))))
      (call _ws))
  
  _comments =
    (call many_sep [_comment ws])
  
  _table_header =
    (seq result=0
      (seq result=1
        (call "[")
        (call surround [
          _path
          (lambda @fn5
            (call maybe [ws]))
        ]))
      (call "]"))
  
  _array_of_tables_header =
    (seq result=0
      (seq result=1
        (call "[[")
        (call surround [
          _path
          (lambda @fn6
            (call maybe [ws]))
        ]))
      (call "]]"))
  
  _table_body(value, HeaderPath, Doc) =
    (seq result=1
      (seq result=1
        (seq result=1
          (match
            scrutinee: (call _table_pair [value~0])
            %0 = scrutinee
            %1 = elem %0 0
            %2 = elem %0 1
            (arm
              (is_type %0 array)
              (len_eq %0 2)
              (bind %1 KeyPath~3)
              (bind %2 Val~4)))
          (call _ws_newline))
        (match
          scrutinee: (call const [(call _Doc.InsertPairAtHeaderPath [Doc~2 HeaderPath~1 KeyPath~3 Val~4])])
          %0 = scrutinee
          (arm
            (bind %0 NewDoc~5))))
      (alt
        (arm
          guard: (call _table_body [value~0 HeaderPath~1 NewDoc~5]))
        (arm
          body: (call const [NewDoc~5]))))
  
  _table_pair(value) =
    (call tuple2_sep [
      _path
      (lambda @fn7
        (call surround [
          "="
          (lambda @fn8
            (call maybe [spaces]))
        ]))
      value~0
    ])
  
  _path =
    (call array_sep [
      _key
      (lambda @fn9
        (call surround [
          "."
          (lambda @fn10
            (call maybe [ws]))
        ]))
    ])
  
  _key =
    (alt
      (arm
        guard: (call many [
          (lambda @fn11
            (alt
              (arm
                guard: (call alpha))
              (arm
                guard: (call numeral))
              (arm
                guard: (call "_"))
              (arm
                body: (call "-"))))
        ]))
      (arm
        guard: (call string.basic))
      (arm
        body: (call string.literal)))
  
  _comment =
    (seq result=1
      (call "#")
      (call maybe [line]))
  
  simple_value =
    (alt
      (arm
        guard: (call string))
      (arm
        guard: (call datetime))
      (arm
        guard: (call number))
      (arm
        guard: (call boolean))
      (arm
        guard: (call array [simple_value]))
      (arm
        body: (call inline_table [simple_value])))
  
  tagged_value =
    (alt
      (arm
        guard: (call string))
      (arm
        guard: (call _tag ["datetime" "offset" datetime.offset]))
      (arm
        guard: (call _tag ["datetime" "local" datetime.local]))
      (arm
        guard: (call _tag ["datetime" "date-local" datetime.local_date]))
      (arm
        guard: (call _tag ["datetime" "time-local" datetime.local_time]))
      (arm
        guard: (call number.binary_integer))
      (arm
        guard: (call number.octal_integer))
      (arm
        guard: (call number.hex_integer))
      (arm
        guard: (call _tag ["float" "infinity" number.infinity]))
      (arm
        guard: (call _tag ["float" "not-a-number" number.not_a_number]))
      (arm
        guard: (call number.float))
      (arm
        guard: (call number.integer))
      (arm
        guard: (call boolean))
      (arm
        guard: (call array [tagged_value]))
      (arm
        body: (call inline_table [tagged_value])))
  
  _tag(Type, Subtype, value) =
    (seq result=1
      (match
        scrutinee: (call value~2)
        %0 = scrutinee
        (arm
          (bind %0 Value~3)))
      (object [
        (pair "type" Type~0)
        (pair "subtype" Subtype~1)
        (pair "value" Value~3)
      ]))
  
  string =
    (alt
      (arm
        guard: (call string.multi_line_basic))
      (arm
        guard: (call string.multi_line_literal))
      (arm
        guard: (call string.basic))
      (arm
        body: (call string.literal)))
  
  datetime =
    (alt
      (arm
        guard: (call datetime.offset))
      (arm
        guard: (call datetime.local))
      (arm
        guard: (call datetime.local_date))
      (arm
        body: (call datetime.local_time)))
  
  number =
    (alt
      (arm
        guard: (call number.binary_integer))
      (arm
        guard: (call number.octal_integer))
      (arm
        guard: (call number.hex_integer))
      (arm
        guard: (call number.infinity))
      (arm
        guard: (call number.not_a_number))
      (arm
        guard: (call number.float))
      (arm
        body: (call number.integer)))
  
  boolean =
    (call _@import0 ["true" "false"])
  
  array(elem) =
    (seq result=0
      (seq result=0
        (seq result=1
          (seq result=1
            (call "[")
            (call _ws))
          (call default [
            (lambda @fn12 captures=[elem]
              (seq result=0
                (call array_sep [
                  (lambda @fn13 captures=[elem]
                    (call surround [elem~0 _ws]))
                  ","
                ])
                (call maybe [
                  (lambda @fn14
                    (call surround ["," _ws]))
                ])))
            (array [])
          ]))
        (call _ws))
      (call "]"))
  
  inline_table(value) =
    (seq result=1
      (match
        scrutinee: (alt
          (arm
            guard: (call _empty_inline_table))
          (arm
            body: (call _nonempty_inline_table [value~0])))
        %0 = scrutinee
        (arm
          (bind %0 InlineDoc~1)))
      (call _Doc.Value [InlineDoc~1]))
  
  _empty_inline_table =
    (seq result=1
      (seq result=0
        (seq result=1
          (call "{")
          (call maybe [spaces]))
        (call "}"))
      _Doc.Empty)
  
  _nonempty_inline_table(value) =
    (seq result=1
      (match
        scrutinee: (seq result=1
          (seq result=1
            (call "{")
            (call maybe [spaces]))
          (call _inline_table_pair [value~0 _Doc.Empty]))
        %0 = scrutinee
        (arm
          (bind %0 DocWithFirstPair~1)))
      (seq result=0
        (seq result=0
          (call _inline_table_body [value~0 DocWithFirstPair~1])
          (call maybe [spaces]))
        (call "}")))
  
  _inline_table_body(value, Doc) =
    (alt
      (arm
        guard: (match
          scrutinee: (seq result=1
            (call ",")
            (call _inline_table_pair [value~0 Doc~1]))
          %0 = scrutinee
          (arm
            (bind %0 NewDoc~2)))
        body: (call _inline_table_body [value~0 NewDoc~2]))
      (arm
        body: (call const [Doc~1])))
  
  _inline_table_pair(value, Doc) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (seq result=1
              (seq result=1
                (call maybe [spaces])
                (match
                  scrutinee: (call _path)
                  %0 = scrutinee
                  (arm
                    (bind %0 Key~2))))
              (call maybe [spaces]))
            (call "="))
          (call maybe [spaces]))
        (match
          scrutinee: (call value~0)
          %0 = scrutinee
          (arm
            (bind %0 Val~3))))
      (seq result=1
        (call maybe [spaces])
        (call _Doc.InsertAtPath [Doc~1 Key~2 Val~3])))
  
  string.multi_line_basic =
    (merge
      (merge
        (merge
          (merge
            (call skip ["""""])
            (call skip [
              (lambda @fn15
                (call maybe [nl]))
            ]))
          (call default [
            (lambda @fn16
              (call many_until [
                (lambda @fn17
                  (alt
                    (arm
                      guard: (call _escaped_ctrl_char))
                    (arm
                      guard: (call _escaped_unicode))
                    (arm
                      guard: (call ws))
                    (arm
                      guard: (seq result=1
                        (merge (call "\") (call ws))
                        (call "")))
                    (arm
                      body: (call unless [
                        char
                        (lambda @fn18
                          (alt
                            (arm
                              guard: (call ctrl_char))
                            (arm
                              body: (call "\"))))
                      ]))))
                """""
              ]))
            ""
          ]))
        (call skip ["""""]))
      (repeat
        body: (call """)
        cap: 2
        count: (set
          %0 = scrutinee
          (in_range %0 0 2))))
  
  string.multi_line_literal =
    (merge
      (merge
        (merge
          (merge
            (call skip ["'''"])
            (call skip [
              (lambda @fn19
                (call maybe [nl]))
            ]))
          (call default [
            (lambda @fn20
              (call many_until [char "'''"]))
            ""
          ]))
        (call skip ["'''"]))
      (repeat
        body: (call "'")
        cap: 2
        count: (set
          %0 = scrutinee
          (in_range %0 0 2))))
  
  string.basic =
    (seq result=0
      (seq result=1
        (call """)
        (call _string.basic_body))
      (call """))
  
  _string.basic_body =
    (alt
      (arm
        guard: (call many [
          (lambda @fn21
            (alt
              (arm
                guard: (call _escaped_ctrl_char))
              (arm
                guard: (call _escaped_unicode))
              (arm
                body: (call unless [
                  char
                  (lambda @fn22
                    (alt
                      (arm
                        guard: (call ctrl_char))
                      (arm
                        guard: (call "\"))
                      (arm
                        body: (call """))))
                ]))))
        ]))
      (arm
        body: (call const [""])))
  
  string.literal =
    (seq result=0
      (seq result=1
        (call "'")
        (call default [
          (lambda @fn23
            (call chars_until ["'"]))
          ""
        ]))
      (call "'"))
  
  _escaped_ctrl_char =
    (alt
      (arm
        guard: (seq result=1
          (call "\"")
          """))
      (arm
        guard: (seq result=1
          (call "\\")
          "\"))
      (arm
        guard: (seq result=1
          (call "\b")
          "\x08")) (esc)
      (arm
        guard: (seq result=1
          (call "\f")
          "\x0c")) (esc)
      (arm
        guard: (seq result=1
          (call "\n")
          "
  "))
      (arm
        guard: (seq result=1
          (call "\r")
          "\r (no-eol) (esc)
  "))
      (arm
        body: (seq result=1
          (call "\t")
          "\t"))) (esc)
  
  _escaped_unicode =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: (seq result=1
              (call "\u")
              (repeat
                body: (call hex_numeral)
                cap: 4
                count: (set
                  %0 = scrutinee
                  (eq_const %0 4))))
            %0 = scrutinee
            (arm
              (bind %0 U~0)))
          (call @Codepoint [U~0])))
      (arm
        body: (seq result=1
          (match
            scrutinee: (seq result=1
              (call "\U")
              (repeat
                body: (call hex_numeral)
                cap: 8
                count: (set
                  %0 = scrutinee
                  (eq_const %0 8))))
            %0 = scrutinee
            (arm
              (bind %0 U~0)))
          (call @Codepoint [U~0]))))
  
  datetime.offset =
    (merge
      (merge
        (call datetime.local_date)
        (alt
          (arm
            guard: (call "T"))
          (arm
            guard: (call "t"))
          (arm
            body: (call " "))))
      (call _datetime.time_offset))
  
  datetime.local =
    (merge
      (merge
        (call datetime.local_date)
        (alt
          (arm
            guard: (call "T"))
          (arm
            guard: (call "t"))
          (arm
            body: (call " "))))
      (call datetime.local_time))
  
  datetime.local_date =
    (merge (merge (merge (merge (call _datetime.year) (call "-")) (call _datetime.month)) (call "-")) (call _datetime.mday))
  
  _datetime.year =
    (repeat
      body: (call numeral)
      cap: 4
      count: (set
        %0 = scrutinee
        (eq_const %0 4)))
  
  _datetime.month =
    (alt
      (arm
        guard: (merge (call "0") (call (range "1" "9"))))
      (arm
        body: (merge (call "1") (call (range "0" "2")))))
  
  _datetime.mday =
    (alt
      (arm
        guard: (merge (call (range "0" "2")) (call (range "1" "9"))))
      (arm
        guard: (call "30"))
      (arm
        body: (call "31")))
  
  datetime.local_time =
    (merge
      (merge (merge (merge (merge (call _datetime.hours) (call ":")) (call _datetime.minutes)) (call ":")) (call _datetime.seconds))
      (call maybe [
        (lambda @fn24
          (merge
            (call ".")
            (repeat
              body: (call numeral)
              cap: 9
              count: (set
                %0 = scrutinee
                (in_range %0 1 9)))))
      ]))
  
  _datetime.time_offset =
    (merge
      (call datetime.local_time)
      (alt
        (arm
          guard: (call "Z"))
        (arm
          guard: (call "z"))
        (arm
          body: (call _datetime.time_numoffset))))
  
  _datetime.time_numoffset =
    (merge
      (merge
        (merge
          (alt
            (arm
              guard: (call "+"))
            (arm
              body: (call "-")))
          (call _datetime.hours))
        (call ":"))
      (call _datetime.minutes))
  
  _datetime.hours =
    (alt
      (arm
        guard: (merge (call (range "0" "1")) (call (range "0" "9"))))
      (arm
        body: (merge (call "2") (call (range "0" "3")))))
  
  _datetime.minutes =
    (merge (call (range "0" "5")) (call (range "0" "9")))
  
  _datetime.seconds =
    (alt
      (arm
        guard: (merge (call (range "0" "5")) (call (range "0" "9"))))
      (arm
        body: (call "60")))
  
  number.integer =
    (call as_number [
      (lambda @fn25
        (merge (call _number.sign) (call _number.integer_part)))
    ])
  
  _number.sign =
    (call maybe [
      (lambda @fn26
        (alt
          (arm
            guard: (call "-"))
          (arm
            body: (call skip ["+"]))))
    ])
  
  _number.integer_part =
    (alt
      (arm
        guard: (merge
          (call (range "1" "9"))
          (call many [
            (lambda @fn27
              (seq result=1
                (call maybe ["_"])
                (call numeral)))
          ])))
      (arm
        body: (call numeral)))
  
  number.float =
    (call as_number [
      (lambda @fn28
        (merge
          (merge (call _number.sign) (call _number.integer_part))
          (alt
            (arm
              guard: (merge (call _number.fraction_part) (call maybe [_number.exponent_part])))
            (arm
              body: (call _number.exponent_part)))))
    ])
  
  _number.fraction_part =
    (merge
      (call ".")
      (call many_sep [
        numerals
        (lambda @fn29
          (call maybe ["_"]))
      ]))
  
  _number.exponent_part =
    (merge
      (merge
        (alt
          (arm
            guard: (call "e"))
          (arm
            body: (call "E")))
        (call maybe [
          (lambda @fn30
            (alt
              (arm
                guard: (call "-"))
              (arm
                body: (call "+"))))
        ]))
      (call many_sep [
        numerals
        (lambda @fn31
          (call maybe ["_"]))
      ]))
  
  number.infinity =
    (merge
      (call maybe [
        (lambda @fn32
          (alt
            (arm
              guard: (call "+"))
            (arm
              body: (call "-"))))
      ])
      (call "inf"))
  
  number.not_a_number =
    (merge
      (call maybe [
        (lambda @fn33
          (alt
            (arm
              guard: (call "+"))
            (arm
              body: (call "-"))))
      ])
      (call "nan"))
  
  number.binary_integer =
    (seq result=1
      (call "0b")
      (seq result=1
        (match
          scrutinee: (call one_or_both [
            (lambda @fn34
              (merge
                (call array_sep [
                  0
                  (lambda @fn35
                    (call maybe ["_"]))
                ])
                (call maybe [
                  (lambda @fn36
                    (seq result=0
                      (call skip ["_"])
                      (call peek [binary_numeral])))
                ])))
            (lambda @fn37
              (call array_sep [
                binary_digit
                (lambda @fn38
                  (call maybe ["_"]))
              ]))
          ])
          %0 = scrutinee
          (arm
            (bind %0 Digits~0)))
        (call Num.FromBinaryDigits [Digits~0])))
  
  number.octal_integer =
    (seq result=1
      (call "0o")
      (seq result=1
        (match
          scrutinee: (call one_or_both [
            (lambda @fn39
              (merge
                (call array_sep [
                  0
                  (lambda @fn40
                    (call maybe ["_"]))
                ])
                (call maybe [
                  (lambda @fn41
                    (seq result=0
                      (call skip ["_"])
                      (call peek [octal_numeral])))
                ])))
            (lambda @fn42
              (call array_sep [
                octal_digit
                (lambda @fn43
                  (call maybe ["_"]))
              ]))
          ])
          %0 = scrutinee
          (arm
            (bind %0 Digits~0)))
        (call Num.FromOctalDigits [Digits~0])))
  
  number.hex_integer =
    (seq result=1
      (call "0x")
      (seq result=1
        (match
          scrutinee: (call one_or_both [
            (lambda @fn44
              (merge
                (call array_sep [
                  0
                  (lambda @fn45
                    (call maybe ["_"]))
                ])
                (call maybe [
                  (lambda @fn46
                    (seq result=0
                      (call skip ["_"])
                      (call peek [hex_numeral])))
                ])))
            (lambda @fn47
              (call array_sep [
                hex_digit
                (lambda @fn48
                  (call maybe ["_"]))
              ]))
          ])
          %0 = scrutinee
          (arm
            (bind %0 Digits~0)))
        (call Num.FromHexDigits [Digits~0])))
  
  _Doc.Empty =
    (object [
      (pair
        "value"
        (object []))
      (pair
        "type"
        (object []))
    ])
  
  _Doc.Value(Doc) =
    (call Obj.Get [Doc~0 "value"])
  
  _Doc.Type(Doc) =
    (call Obj.Get [Doc~0 "type"])
  
  _Doc.Has(Doc, Key) =
    (call Obj.Has [(call _Doc.Type [Doc~0]) Key~1])
  
  _Doc.Get(Doc, Key) =
    (object [
      (pair "value" (call Obj.Get [(call _Doc.Value [Doc~0]) Key~1]))
      (pair "type" (call Obj.Get [(call _Doc.Type [Doc~0]) Key~1]))
    ])
  
  _Doc.IsTable(Doc) =
    (call Is.Object [(call _Doc.Type [Doc~0])])
  
  _Doc.Insert(Doc, Key, Val, Type) =
    (seq result=1
      (call _Doc.IsTable [Doc~0])
      (object [
        (pair "value" (call Obj.Put [(call _Doc.Value [Doc~0]) Key~1 Val~2]))
        (pair "type" (call Obj.Put [(call _Doc.Type [Doc~0]) Key~1 Type~3]))
      ]))
  
  _Doc.AppendToArrayOfTables(Doc, Key, ElementDoc) =
    (seq result=1
      (match
        scrutinee: (call _Doc.Get [Doc~0 Key~1])
        %0 = scrutinee
        %1 = key %0 "value"
        %2 = key %0 "type"
        %3 = elem %2 0
        %4 = elem %2 1
        (arm
          (is_type %0 object)
          (keys_exact %0 2)
          (has_key %0 "value")
          (bind %1 Vs~3)
          (has_key %0 "type")
          (is_type %2 array)
          (len_eq %2 2)
          (eq_const %3 "array_of_tables")
          (bind %4 Ts~4)))
      (call _Doc.Insert [
        Doc~0
        Key~1
        (merge
          (merge
            (array [])
            Vs~3)
          (array [
            (call _Doc.Value [ElementDoc~2])
          ]))
        (array [
          "array_of_tables"
          (merge
            (merge
              (array [])
              Ts~4)
            (array [
              (call _Doc.Type [ElementDoc~2])
            ]))
        ])
      ]))
  
  _Doc.InsertAtPath(Doc, Path, Val) =
    (call _Doc.UpdateAtPath [Doc~0 Path~1 Val~2 _Doc.ValueUpdater])
  
  _Doc.EnsureTableAtPath(Doc, Path) =
    (call _Doc.UpdateAtHeaderPath [
      Doc~0
      Path~1
      (object [])
      _Doc.MissingTableUpdater
    ])
  
  _Doc.AppendAtPath(Doc, Path, ElementDoc) =
    (call _Doc.UpdateAtHeaderPath [Doc~0 Path~1 ElementDoc~2 _Doc.AppendUpdater])
  
  _Doc.UpdateAtPath(Doc, Path, Val, Updater) =
    (alt
      (arm
        guard: (match
          scrutinee: Path~1
          %0 = scrutinee
          %1 = elem %0 0
          (arm
            (is_type %0 array)
            (len_eq %0 1)
            (bind %1 Key~4)))
        body: (call Updater~3 [Doc~0 Key~4 Val~2]))
      (arm
        guard: (match
          scrutinee: Path~1
          %0 = scrutinee
          (arm
            (solve_merge %0 solvable=1
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (bind %1 Key~4))
              (bind PathRest~5))))
        body: (seq result=1
          (match
            scrutinee: (alt
              (arm
                guard: (call _Doc.Has [Doc~0 Key~4])
                body: (seq result=1
                  (call _Doc.IsTable [(call _Doc.Get [Doc~0 Key~4])])
                  (call _Doc.UpdateAtPath [(call _Doc.Get [Doc~0 Key~4]) PathRest~5 Val~2 Updater~3])))
              (arm
                body: (call _Doc.UpdateAtPath [_Doc.Empty PathRest~5 Val~2 Updater~3])))
            %0 = scrutinee
            (arm
              (bind %0 InnerDoc~6)))
          (call _Doc.Insert [Doc~0 Key~4 (call _Doc.Value [InnerDoc~6]) (call _Doc.Type [InnerDoc~6])])))
      (arm
        body: Doc~0))
  
  _Doc.ValueUpdater(Doc, Key, Val) =
    (alt
      (arm
        guard: (call _Doc.Has [Doc~0 Key~1])
        body: @Fail)
      (arm
        body: (call _Doc.Insert [Doc~0 Key~1 Val~2 "value"])))
  
  _Doc.MissingTableUpdater(Doc, Key, _Val) =
    (alt
      (arm
        guard: (call _Doc.Has [Doc~0 Key~1])
        body: (seq result=1
          (call _Doc.IsTable [(call _Doc.Get [Doc~0 Key~1])])
          Doc~0))
      (arm
        body: (call _Doc.Insert [
          Doc~0
          Key~1
          (object [])
          (object [])
        ])))
  
  _Doc.AppendUpdater(Doc, Key, ElementDoc) =
    (seq result=1
      (match
        scrutinee: (alt
          (arm
            guard: (call _Doc.Has [Doc~0 Key~1])
            body: Doc~0)
          (arm
            body: (call _Doc.Insert [
              Doc~0
              Key~1
              (array [])
              (array [
                "array_of_tables"
                (array [])
              ])
            ])))
        %0 = scrutinee
        (arm
          (bind %0 DocWithKey~3)))
      (call _Doc.AppendToArrayOfTables [DocWithKey~3 Key~1 ElementDoc~2]))
  
  _Doc.InsertPairAtHeaderPath(Doc, HeaderPath, KeyPath, Val) =
    (alt
      (arm
        guard: (match
          scrutinee: HeaderPath~1
          %0 = scrutinee
          (arm
            (is_type %0 array)
            (len_eq %0 0)))
        body: (call _Doc.InsertAtPath [Doc~0 KeyPath~2 Val~3]))
      (arm
        body: (call _Doc.UpdateAtHeaderPath [
          Doc~0
          HeaderPath~1
          (array [
            KeyPath~2
            Val~3
          ])
          _Doc.PairUpdater
        ])))
  
  _Doc.PairUpdater(Doc, Key, KeyPathAndVal) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (match
              scrutinee: KeyPathAndVal~2
              %0 = scrutinee
              %1 = elem %0 0
              %2 = elem %0 1
              (arm
                (is_type %0 array)
                (len_eq %0 2)
                (bind %1 KeyPath~3)
                (bind %2 Val~4)))
            (match
              scrutinee: (alt
                (arm
                  guard: (call _Doc.Has [Doc~0 Key~1])
                  body: (call _Doc.Get [Doc~0 Key~1]))
                (arm
                  body: _Doc.Empty))
              %0 = scrutinee
              (arm
                (bind %0 SubDoc~5))))
          (call _Doc.IsTable [SubDoc~5]))
        (match
          scrutinee: (call _Doc.InsertAtPath [SubDoc~5 KeyPath~3 Val~4])
          %0 = scrutinee
          (arm
            (bind %0 NewSubDoc~6))))
      (call _Doc.Insert [Doc~0 Key~1 (call _Doc.Value [NewSubDoc~6]) (call _Doc.Type [NewSubDoc~6])]))
  
  _Doc.UpdateAtHeaderPath(Doc, Path, Val, Updater) =
    (alt
      (arm
        guard: (match
          scrutinee: Path~1
          %0 = scrutinee
          %1 = elem %0 0
          (arm
            (is_type %0 array)
            (len_eq %0 1)
            (bind %1 Key~4)))
        body: (call Updater~3 [Doc~0 Key~4 Val~2]))
      (arm
        guard: (match
          scrutinee: Path~1
          %0 = scrutinee
          (arm
            (solve_merge %0 solvable=1
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (bind %1 Key~4))
              (bind PathRest~5))))
        body: (call _Doc.DescendHeaderKey [Doc~0 Key~4 PathRest~5 Val~2 Updater~3]))
      (arm
        body: Doc~0))
  
  _Doc.DescendHeaderKey(Doc, Key, PathRest, Val, Updater) =
    (alt
      (arm
        guard: (call _Doc.Has [Doc~0 Key~1])
        body: (seq result=1
          (seq result=1
            (match
              scrutinee: (call _Doc.Get [Doc~0 Key~1])
              %0 = scrutinee
              (arm
                (bind %0 Current~5)))
            (match
              scrutinee: (alt
                (arm
                  guard: (match
                    scrutinee: (call _Doc.Type [Current~5])
                    %0 = scrutinee
                    (arm
                      (solve_merge %0 solvable=1
                        (set
                          %0 = scrutinee
                          %1 = elem %0 0
                          (is_type %0 array)
                          (len_eq %0 1)
                          (eq_const %1 "array_of_tables"))
                        _)))
                  body: (call _Doc.UpdateAtLastAoTElement [Current~5 PathRest~2 Val~3 Updater~4]))
                (arm
                  body: (seq result=1
                    (call _Doc.IsTable [Current~5])
                    (call _Doc.UpdateAtHeaderPath [Current~5 PathRest~2 Val~3 Updater~4]))))
              %0 = scrutinee
              (arm
                (bind %0 Updated~7))))
          (call _Doc.Insert [Doc~0 Key~1 (call _Doc.Value [Updated~7]) (call _Doc.Type [Updated~7])])))
      (arm
        body: (seq result=1
          (match
            scrutinee: (call _Doc.UpdateAtHeaderPath [_Doc.Empty PathRest~2 Val~3 Updater~4])
            %0 = scrutinee
            (arm
              (bind %0 InnerDoc~8)))
          (call _Doc.Insert [Doc~0 Key~1 (call _Doc.Value [InnerDoc~8]) (call _Doc.Type [InnerDoc~8])]))))
  
  _Doc.UpdateAtLastAoTElement(AoTDoc, PathRest, Val, Updater) =
    (seq result=1
      (seq result=1
        (seq result=1
          (match
            scrutinee: (call _Doc.Value [AoTDoc~0])
            %0 = scrutinee
            (arm
              (solve_merge %0 solvable=1
                (set
                  %0 = scrutinee
                  (is_type %0 array)
                  (len_eq %0 0))
                (bind VsInit~4)
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (bind %1 VLast~5)))))
          (match
            scrutinee: (call _Doc.Type [AoTDoc~0])
            %0 = scrutinee
            %1 = elem %0 0
            %2 = elem %0 1
            (arm
              (is_type %0 array)
              (len_eq %0 2)
              (eq_const %1 "array_of_tables")
              (solve_merge %2 solvable=1
                (set
                  %0 = scrutinee
                  (is_type %0 array)
                  (len_eq %0 0))
                (bind TsInit~6)
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (bind %1 TLast~7))))))
        (match
          scrutinee: (call _Doc.UpdateAtHeaderPath [
            (object [
              (pair "value" VLast~5)
              (pair "type" TLast~7)
            ])
            PathRest~1
            Val~2
            Updater~3
          ])
          %0 = scrutinee
          (arm
            (bind %0 UpdatedLast~8))))
      (object [
        (pair
          "value"
          (merge
            (merge
              (array [])
              VsInit~4)
            (array [
              (call _Doc.Value [UpdatedLast~8])
            ])))
        (pair
          "type"
          (array [
            "array_of_tables"
            (merge
              (merge
                (array [])
                TsInit~6)
              (array [
                (call _Doc.Type [UpdatedLast~8])
              ]))
          ]))
      ]))
  
  main =
    (call simple)
