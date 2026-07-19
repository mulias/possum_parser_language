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
              guard: (call _with_root_table [value]))
            (arm
              body: (call _no_root_table [value])))
          %0 = scrutinee
          (arm
            (local %0 Doc))))
      (seq result=1
        (call maybe [
          (lambda @fn1
            (merge (call maybe [ws]) (call _comments)))
        ])
        (call _Doc.Value [Doc])))
  
  _with_root_table(value) =
    (seq result=1
      (match
        scrutinee: (call _root_table [value _Doc.Empty])
        %0 = scrutinee
        (arm
          (local %0 RootDoc)))
      (alt
        (arm
          guard: (seq result=1
            (call _ws)
            (call _tables [value RootDoc])))
        (arm
          body: (call const [RootDoc]))))
  
  _root_table(value, Doc) =
    (call _table_body [
      value
      (array [])
      Doc
    ])
  
  _no_root_table(value) =
    (seq result=1
      (match
        scrutinee: (alt
          (arm
            guard: (call _table [value _Doc.Empty]))
          (arm
            body: (call _array_of_tables [value _Doc.Empty])))
        %0 = scrutinee
        (arm
          (local %0 NewDoc)))
      (call _tables [value NewDoc]))
  
  _tables(value, Doc) =
    (alt
      (arm
        guard: (match
          scrutinee: (alt
            (arm
              guard: (seq result=1
                (call _ws)
                (call _table [value Doc])))
            (arm
              body: (call _array_of_tables [value Doc])))
          %0 = scrutinee
          (arm
            (local %0 NewDoc)))
        body: (call _tables [value NewDoc]))
      (arm
        body: (call const [Doc])))
  
  _table(value, Doc) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call _table_header)
          %0 = scrutinee
          (arm
            (local %0 HeaderPath)))
        (call _ws_newline))
      (alt
        (arm
          guard: (call _table_body [value HeaderPath Doc]))
        (arm
          body: (call const [(call _Doc.EnsureTableAtPath [Doc HeaderPath])]))))
  
  _array_of_tables(value, Doc) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call _array_of_tables_header)
          %0 = scrutinee
          (arm
            (local %0 HeaderPath)))
        (call _ws_newline))
      (seq result=1
        (match
          scrutinee: (call default [
            (lambda @fn2
              (call _table_body [
                value
                (array [])
                _Doc.Empty
              ]))
            _Doc.Empty
          ])
          %0 = scrutinee
          (arm
            (local %0 InnerDoc)))
        (call _Doc.AppendAtPath [Doc HeaderPath InnerDoc])))
  
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
            scrutinee: (call _table_pair [value])
            %0 = scrutinee
            %1 = elem %0 0
            %2 = elem %0 1
            (arm
              (is_type %0 array)
              (len_eq %0 2)
              (local %1 KeyPath)
              (local %2 Val)))
          (call _ws_newline))
        (match
          scrutinee: (call const [(call _Doc.InsertPairAtHeaderPath [Doc HeaderPath KeyPath Val])])
          %0 = scrutinee
          (arm
            (local %0 NewDoc))))
      (alt
        (arm
          guard: (call _table_body [value HeaderPath NewDoc]))
        (arm
          body: (call const [NewDoc]))))
  
  _table_pair(value) =
    (call tuple2_sep [
      _path
      (lambda @fn7
        (call surround [
          "="
          (lambda @fn8
            (call maybe [spaces]))
        ]))
      value
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
        scrutinee: (call value)
        %0 = scrutinee
        (arm
          (local %0 Value)))
      (object [
        (pair "type" Type)
        (pair "subtype" Subtype)
        (pair "value" Value)
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
            (lambda @fn12
              (seq result=0
                (call array_sep [
                  (lambda @fn13
                    (call surround [elem _ws]))
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
            body: (call _nonempty_inline_table [value])))
        %0 = scrutinee
        (arm
          (local %0 InlineDoc)))
      (call _Doc.Value [InlineDoc]))
  
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
          (call _inline_table_pair [value _Doc.Empty]))
        %0 = scrutinee
        (arm
          (local %0 DocWithFirstPair)))
      (seq result=0
        (seq result=0
          (call _inline_table_body [value DocWithFirstPair])
          (call maybe [spaces]))
        (call "}")))
  
  _inline_table_body(value, Doc) =
    (alt
      (arm
        guard: (match
          scrutinee: (seq result=1
            (call ",")
            (call _inline_table_pair [value Doc]))
          %0 = scrutinee
          (arm
            (local %0 NewDoc)))
        body: (call _inline_table_body [value NewDoc]))
      (arm
        body: (call const [Doc])))
  
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
                    (local %0 Key))))
              (call maybe [spaces]))
            (call "="))
          (call maybe [spaces]))
        (match
          scrutinee: (call value)
          %0 = scrutinee
          (arm
            (local %0 Val))))
      (seq result=1
        (call maybe [spaces])
        (call _Doc.InsertAtPath [Doc Key Val])))
  
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
              (local %0 U)))
          (call @Codepoint [U])))
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
              (local %0 U)))
          (call @Codepoint [U]))))
  
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
            (local %0 Digits)))
        (call Num.FromBinaryDigits [Digits])))
  
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
            (local %0 Digits)))
        (call Num.FromOctalDigits [Digits])))
  
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
            (local %0 Digits)))
        (call Num.FromHexDigits [Digits])))
  
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
    (call Obj.Get [Doc "value"])
  
  _Doc.Type(Doc) =
    (call Obj.Get [Doc "type"])
  
  _Doc.Has(Doc, Key) =
    (call Obj.Has [(call _Doc.Type [Doc]) Key])
  
  _Doc.Get(Doc, Key) =
    (object [
      (pair "value" (call Obj.Get [(call _Doc.Value [Doc]) Key]))
      (pair "type" (call Obj.Get [(call _Doc.Type [Doc]) Key]))
    ])
  
  _Doc.IsTable(Doc) =
    (call Is.Object [(call _Doc.Type [Doc])])
  
  _Doc.Insert(Doc, Key, Val, Type) =
    (seq result=1
      (call _Doc.IsTable [Doc])
      (object [
        (pair "value" (call Obj.Put [(call _Doc.Value [Doc]) Key Val]))
        (pair "type" (call Obj.Put [(call _Doc.Type [Doc]) Key Type]))
      ]))
  
  _Doc.AppendToArrayOfTables(Doc, Key, ElementDoc) =
    (seq result=1
      (match
        scrutinee: (call _Doc.Get [Doc Key])
        %0 = scrutinee
        %1 = key %0 "value"
        %2 = key %0 "type"
        %3 = elem %2 0
        %4 = elem %2 1
        (arm
          (is_type %0 object)
          (keys_exact %0 2)
          (has_key %0 "value")
          (local %1 Vs)
          (has_key %0 "type")
          (is_type %2 array)
          (len_eq %2 2)
          (eq_const %3 "array_of_tables")
          (local %4 Ts)))
      (call _Doc.Insert [
        Doc
        Key
        (merge
          (merge
            (array [])
            Vs)
          (array [
            (call _Doc.Value [ElementDoc])
          ]))
        (array [
          "array_of_tables"
          (merge
            (merge
              (array [])
              Ts)
            (array [
              (call _Doc.Type [ElementDoc])
            ]))
        ])
      ]))
  
  _Doc.InsertAtPath(Doc, Path, Val) =
    (call _Doc.UpdateAtPath [Doc Path Val _Doc.ValueUpdater])
  
  _Doc.EnsureTableAtPath(Doc, Path) =
    (call _Doc.UpdateAtHeaderPath [
      Doc
      Path
      (object [])
      _Doc.MissingTableUpdater
    ])
  
  _Doc.AppendAtPath(Doc, Path, ElementDoc) =
    (call _Doc.UpdateAtHeaderPath [Doc Path ElementDoc _Doc.AppendUpdater])
  
  _Doc.UpdateAtPath(Doc, Path, Val, Updater) =
    (alt
      (arm
        guard: (match
          scrutinee: Path
          %0 = scrutinee
          %1 = elem %0 0
          (arm
            (is_type %0 array)
            (len_eq %0 1)
            (local %1 Key)))
        body: (call Updater [Doc Key Val]))
      (arm
        guard: (match
          scrutinee: Path
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 Key))
              (local PathRest))))
        body: (seq result=1
          (match
            scrutinee: (alt
              (arm
                guard: (call _Doc.Has [Doc Key])
                body: (seq result=1
                  (call _Doc.IsTable [(call _Doc.Get [Doc Key])])
                  (call _Doc.UpdateAtPath [(call _Doc.Get [Doc Key]) PathRest Val Updater])))
              (arm
                body: (call _Doc.UpdateAtPath [_Doc.Empty PathRest Val Updater])))
            %0 = scrutinee
            (arm
              (local %0 InnerDoc)))
          (call _Doc.Insert [Doc Key (call _Doc.Value [InnerDoc]) (call _Doc.Type [InnerDoc])])))
      (arm
        body: Doc))
  
  _Doc.ValueUpdater(Doc, Key, Val) =
    (alt
      (arm
        guard: (call _Doc.Has [Doc Key])
        body: @Fail)
      (arm
        body: (call _Doc.Insert [Doc Key Val "value"])))
  
  _Doc.MissingTableUpdater(Doc, Key, _Val) =
    (alt
      (arm
        guard: (call _Doc.Has [Doc Key])
        body: (seq result=1
          (call _Doc.IsTable [(call _Doc.Get [Doc Key])])
          Doc))
      (arm
        body: (call _Doc.Insert [
          Doc
          Key
          (object [])
          (object [])
        ])))
  
  _Doc.AppendUpdater(Doc, Key, ElementDoc) =
    (seq result=1
      (match
        scrutinee: (alt
          (arm
            guard: (call _Doc.Has [Doc Key])
            body: Doc)
          (arm
            body: (call _Doc.Insert [
              Doc
              Key
              (array [])
              (array [
                "array_of_tables"
                (array [])
              ])
            ])))
        %0 = scrutinee
        (arm
          (local %0 DocWithKey)))
      (call _Doc.AppendToArrayOfTables [DocWithKey Key ElementDoc]))
  
  _Doc.InsertPairAtHeaderPath(Doc, HeaderPath, KeyPath, Val) =
    (alt
      (arm
        guard: (match
          scrutinee: HeaderPath
          %0 = scrutinee
          (arm
            (is_type %0 array)
            (len_eq %0 0)))
        body: (call _Doc.InsertAtPath [Doc KeyPath Val]))
      (arm
        body: (call _Doc.UpdateAtHeaderPath [
          Doc
          HeaderPath
          (array [
            KeyPath
            Val
          ])
          _Doc.PairUpdater
        ])))
  
  _Doc.PairUpdater(Doc, Key, KeyPathAndVal) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (match
              scrutinee: KeyPathAndVal
              %0 = scrutinee
              %1 = elem %0 0
              %2 = elem %0 1
              (arm
                (is_type %0 array)
                (len_eq %0 2)
                (local %1 KeyPath)
                (local %2 Val)))
            (match
              scrutinee: (alt
                (arm
                  guard: (call _Doc.Has [Doc Key])
                  body: (call _Doc.Get [Doc Key]))
                (arm
                  body: _Doc.Empty))
              %0 = scrutinee
              (arm
                (local %0 SubDoc))))
          (call _Doc.IsTable [SubDoc]))
        (match
          scrutinee: (call _Doc.InsertAtPath [SubDoc KeyPath Val])
          %0 = scrutinee
          (arm
            (local %0 NewSubDoc))))
      (call _Doc.Insert [Doc Key (call _Doc.Value [NewSubDoc]) (call _Doc.Type [NewSubDoc])]))
  
  _Doc.UpdateAtHeaderPath(Doc, Path, Val, Updater) =
    (alt
      (arm
        guard: (match
          scrutinee: Path
          %0 = scrutinee
          %1 = elem %0 0
          (arm
            (is_type %0 array)
            (len_eq %0 1)
            (local %1 Key)))
        body: (call Updater [Doc Key Val]))
      (arm
        guard: (match
          scrutinee: Path
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 Key))
              (local PathRest))))
        body: (call _Doc.DescendHeaderKey [Doc Key PathRest Val Updater]))
      (arm
        body: Doc))
  
  _Doc.DescendHeaderKey(Doc, Key, PathRest, Val, Updater) =
    (alt
      (arm
        guard: (call _Doc.Has [Doc Key])
        body: (seq result=1
          (seq result=1
            (match
              scrutinee: (call _Doc.Get [Doc Key])
              %0 = scrutinee
              (arm
                (local %0 Current)))
            (match
              scrutinee: (alt
                (arm
                  guard: (match
                    scrutinee: (call _Doc.Type [Current])
                    %0 = scrutinee
                    (arm
                      (solve_merge %0
                        (set
                          %0 = scrutinee
                          %1 = elem %0 0
                          (is_type %0 array)
                          (len_eq %0 1)
                          (eq_const %1 "array_of_tables"))
                        _)))
                  body: (call _Doc.UpdateAtLastAoTElement [Current PathRest Val Updater]))
                (arm
                  body: (seq result=1
                    (call _Doc.IsTable [Current])
                    (call _Doc.UpdateAtHeaderPath [Current PathRest Val Updater]))))
              %0 = scrutinee
              (arm
                (local %0 Updated))))
          (call _Doc.Insert [Doc Key (call _Doc.Value [Updated]) (call _Doc.Type [Updated])])))
      (arm
        body: (seq result=1
          (match
            scrutinee: (call _Doc.UpdateAtHeaderPath [_Doc.Empty PathRest Val Updater])
            %0 = scrutinee
            (arm
              (local %0 InnerDoc)))
          (call _Doc.Insert [Doc Key (call _Doc.Value [InnerDoc]) (call _Doc.Type [InnerDoc])]))))
  
  _Doc.UpdateAtLastAoTElement(AoTDoc, PathRest, Val, Updater) =
    (seq result=1
      (seq result=1
        (seq result=1
          (match
            scrutinee: (call _Doc.Value [AoTDoc])
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  (is_type %0 array)
                  (len_eq %0 0))
                (local VsInit)
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 VLast)))))
          (match
            scrutinee: (call _Doc.Type [AoTDoc])
            %0 = scrutinee
            %1 = elem %0 0
            %2 = elem %0 1
            (arm
              (is_type %0 array)
              (len_eq %0 2)
              (eq_const %1 "array_of_tables")
              (solve_merge %2
                (set
                  %0 = scrutinee
                  (is_type %0 array)
                  (len_eq %0 0))
                (local TsInit)
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 TLast))))))
        (match
          scrutinee: (call _Doc.UpdateAtHeaderPath [
            (object [
              (pair "value" VLast)
              (pair "type" TLast)
            ])
            PathRest
            Val
            Updater
          ])
          %0 = scrutinee
          (arm
            (local %0 UpdatedLast))))
      (object [
        (pair
          "value"
          (merge
            (merge
              (array [])
              VsInit)
            (array [
              (call _Doc.Value [UpdatedLast])
            ])))
        (pair
          "type"
          (array [
            "array_of_tables"
            (merge
              (merge
                (array [])
                TsInit)
              (array [
                (call _Doc.Type [UpdatedLast])
              ]))
          ]))
      ]))
  
  main =
    (call simple)
