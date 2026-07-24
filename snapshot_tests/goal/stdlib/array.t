Full created-stage goal form of stdlib/array.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array.possum -i '' --no-stdlib
  array(elem) =
    (repeat
      body: (call tuple1 [elem~0])
      count: (set
        %0 = scrutinee
        (in_range %0 1 _)))
  
  array_sep(elem, sep) =
    (merge
      (call tuple1 [elem~0])
      (repeat
        body: (call tuple1 [
          (lambda @fn0 captures=[sep elem]
            (seq result=1
              (call sep~0)
              (call elem~1)))
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  array_until(elem, stop) =
    (seq result=0
      (repeat
        body: (call unless [
          (lambda @fn1 captures=[elem]
            (call tuple1 [elem~0]))
          stop~1
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 1 _)))
      (call peek [stop~1]))
  
  maybe_array(elem) =
    (call default [
      (lambda @fn2 captures=[elem]
        (call array [elem~0]))
      (array [])
    ])
  
  maybe_array_sep(elem, sep) =
    (call default [
      (lambda @fn3 captures=[elem sep]
        (call array_sep [elem~0 sep~1]))
      (array [])
    ])
  
  tuple1(elem) =
    (seq result=1
      (match
        scrutinee: (call elem~0)
        %0 = scrutinee
        (arm
          (bind %0 Elem~1)))
      (array [
        Elem~1
      ]))
  
  tuple2(elem1, elem2) =
    (seq result=1
      (match
        scrutinee: (call elem1~0)
        %0 = scrutinee
        (arm
          (bind %0 E1~2)))
      (seq result=1
        (match
          scrutinee: (call elem2~1)
          %0 = scrutinee
          (arm
            (bind %0 E2~3)))
        (array [
          E1~2
          E2~3
        ])))
  
  tuple2_sep(elem1, sep, elem2) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call elem1~0)
          %0 = scrutinee
          (arm
            (bind %0 E1~3)))
        (call sep~1))
      (seq result=1
        (match
          scrutinee: (call elem2~2)
          %0 = scrutinee
          (arm
            (bind %0 E2~4)))
        (array [
          E1~3
          E2~4
        ])))
  
  tuple3(elem1, elem2, elem3) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call elem1~0)
          %0 = scrutinee
          (arm
            (bind %0 E1~3)))
        (match
          scrutinee: (call elem2~1)
          %0 = scrutinee
          (arm
            (bind %0 E2~4))))
      (seq result=1
        (match
          scrutinee: (call elem3~2)
          %0 = scrutinee
          (arm
            (bind %0 E3~5)))
        (array [
          E1~3
          E2~4
          E3~5
        ])))
  
  tuple3_sep(elem1, sep1, elem2, sep2, elem3) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (match
              scrutinee: (call elem1~0)
              %0 = scrutinee
              (arm
                (bind %0 E1~5)))
            (call sep1~1))
          (match
            scrutinee: (call elem2~2)
            %0 = scrutinee
            (arm
              (bind %0 E2~6))))
        (call sep2~3))
      (seq result=1
        (match
          scrutinee: (call elem3~4)
          %0 = scrutinee
          (arm
            (bind %0 E3~7)))
        (array [
          E1~5
          E2~6
          E3~7
        ])))
  
  tuple(elem, N) =
    (repeat
      body: (call tuple1 [elem~0])
      cap: (read N~1)
      count: (set
        %0 = scrutinee
        (eq_slot %0 N~1)))
  
  tuple_sep(elem, sep, N) =
    (merge
      (call tuple1 [elem~0])
      (repeat
        body: (call tuple1 [
          (lambda @fn4 captures=[sep elem]
            (seq result=1
              (call sep~0)
              (call elem~1)))
        ])
        cap: (merge N~2 -1)
        count: (set
          %0 = scrutinee
          (solve_merge %0 ty=number
            (read N~2)
            -1))))
  
  rows(elem, col_sep, row_sep) =
    (merge
      (call tuple1 [
        (lambda @fn5 captures=[elem col_sep]
          (call array_sep [elem~0 col_sep~1]))
      ])
      (repeat
        body: (call tuple1 [
          (lambda @fn6 captures=[row_sep elem col_sep]
            (seq result=1
              (call row_sep~0)
              (call array_sep [elem~1 col_sep~2])))
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  rows_padded(elem, col_sep, row_sep, Pad) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call peek [
            (lambda @fn7 captures=[elem col_sep row_sep]
              (call _dimensions [elem~0 col_sep~1 row_sep~2]))
          ])
          %0 = scrutinee
          %1 = elem %0 0
          (arm
            (is_type %0 array)
            (len_eq %0 2)
            (bind %1 MaxRowLen~4)))
        (match
          scrutinee: (call elem~0)
          %0 = scrutinee
          (arm
            (bind %0 First~5))))
      (call _rows_padded [
        elem~0
        col_sep~1
        row_sep~2
        Pad~3
        1
        MaxRowLen~4
        (array [
          First~5
        ])
        (array [])
      ]))
  
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    (alt
      (arm
        guard: (match
          scrutinee: (seq result=1
            (call col_sep~1)
            (call elem~0))
          %0 = scrutinee
          (arm
            (bind %0 Elem~8)))
        body: (call _rows_padded [
          elem~0
          col_sep~1
          row_sep~2
          Pad~3
          (call Num.Inc [RowLen~4])
          MaxRowLen~5
          (merge
            (merge
              (array [])
              AccRow~6)
            (array [
              Elem~8
            ]))
          AccRows~7
        ]))
      (arm
        guard: (match
          scrutinee: (seq result=1
            (call row_sep~2)
            (call elem~0))
          %0 = scrutinee
          (arm
            (bind %0 NextRow~9)))
        body: (call _rows_padded [
          elem~0
          col_sep~1
          row_sep~2
          Pad~3
          1
          MaxRowLen~5
          (array [
            NextRow~9
          ])
          (merge
            (merge
              (array [])
              AccRows~7)
            (array [
              (call Array.AppendN [AccRow~6 Pad~3 (merge MaxRowLen~5 (neg RowLen~4))])
            ]))
        ]))
      (arm
        body: (call const [
          (merge
            (merge
              (array [])
              AccRows~7)
            (array [
              (call Array.AppendN [AccRow~6 Pad~3 (merge MaxRowLen~5 (neg RowLen~4))])
            ]))
        ])))
  
  _dimensions(elem, col_sep, row_sep) =
    (seq result=1
      (call elem~0)
      (call __dimensions [elem~0 col_sep~1 row_sep~2 1 1 0]))
  
  __dimensions(elem, col_sep, row_sep, RowLen, ColLen, MaxRowLen) =
    (alt
      (arm
        guard: (seq result=1
          (call col_sep~1)
          (call elem~0))
        body: (call __dimensions [elem~0 col_sep~1 row_sep~2 (call Num.Inc [RowLen~3]) ColLen~4 MaxRowLen~5]))
      (arm
        guard: (seq result=1
          (call row_sep~2)
          (call elem~0))
        body: (call __dimensions [elem~0 col_sep~1 row_sep~2 1 (call Num.Inc [ColLen~4]) (call Num.Max [RowLen~3 MaxRowLen~5])]))
      (arm
        body: (call const [
          (array [
            (call Num.Max [RowLen~3 MaxRowLen~5])
            ColLen~4
          ])
        ])))
  
  columns(elem, col_sep, row_sep) =
    (seq result=1
      (match
        scrutinee: (call rows [elem~0 col_sep~1 row_sep~2])
        %0 = scrutinee
        (arm
          (bind %0 Rows~3)))
      (call Table.Transpose [Rows~3]))
  
  cols =
    (call columns)
  
  columns_padded(elem, col_sep, row_sep, Pad) =
    (seq result=1
      (match
        scrutinee: (call rows_padded [elem~0 col_sep~1 row_sep~2 Pad~3])
        %0 = scrutinee
        (arm
          (bind %0 Rows~4)))
      (call Table.Transpose [Rows~4]))
  
  cols_padded =
    (call columns_padded)
  
