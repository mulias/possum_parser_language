Full created-stage goal form of stdlib/array.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array.possum -i '' --no-stdlib
  array(elem) =
    (repeat
      body: (call tuple1 [elem])
      count: (set
        %0 = scrutinee
        (in_range %0 1 _)))
  
  array_sep(elem, sep) =
    (merge
      (call tuple1 [elem])
      (repeat
        body: (call tuple1 [
          (lambda @fn0
            (seq result=1
              (call sep)
              (call elem)))
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  array_until(elem, stop) =
    (seq result=0
      (repeat
        body: (call unless [
          (lambda @fn1
            (call tuple1 [elem]))
          stop
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 1 _)))
      (call peek [stop]))
  
  maybe_array(elem) =
    (call default [
      (lambda @fn2
        (call array [elem]))
      (array [])
    ])
  
  maybe_array_sep(elem, sep) =
    (call default [
      (lambda @fn3
        (call array_sep [elem sep]))
      (array [])
    ])
  
  tuple1(elem) =
    (seq result=1
      (match
        scrutinee: (call elem)
        %0 = scrutinee
        (arm
          (local %0 Elem)))
      (array [
        Elem
      ]))
  
  tuple2(elem1, elem2) =
    (seq result=1
      (match
        scrutinee: (call elem1)
        %0 = scrutinee
        (arm
          (local %0 E1)))
      (seq result=1
        (match
          scrutinee: (call elem2)
          %0 = scrutinee
          (arm
            (local %0 E2)))
        (array [
          E1
          E2
        ])))
  
  tuple2_sep(elem1, sep, elem2) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call elem1)
          %0 = scrutinee
          (arm
            (local %0 E1)))
        (call sep))
      (seq result=1
        (match
          scrutinee: (call elem2)
          %0 = scrutinee
          (arm
            (local %0 E2)))
        (array [
          E1
          E2
        ])))
  
  tuple3(elem1, elem2, elem3) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call elem1)
          %0 = scrutinee
          (arm
            (local %0 E1)))
        (match
          scrutinee: (call elem2)
          %0 = scrutinee
          (arm
            (local %0 E2))))
      (seq result=1
        (match
          scrutinee: (call elem3)
          %0 = scrutinee
          (arm
            (local %0 E3)))
        (array [
          E1
          E2
          E3
        ])))
  
  tuple3_sep(elem1, sep1, elem2, sep2, elem3) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (match
              scrutinee: (call elem1)
              %0 = scrutinee
              (arm
                (local %0 E1)))
            (call sep1))
          (match
            scrutinee: (call elem2)
            %0 = scrutinee
            (arm
              (local %0 E2))))
        (call sep2))
      (seq result=1
        (match
          scrutinee: (call elem3)
          %0 = scrutinee
          (arm
            (local %0 E3)))
        (array [
          E1
          E2
          E3
        ])))
  
  tuple(elem, N) =
    (repeat
      body: (call tuple1 [elem])
      cap: (local N)
      count: (set
        %0 = scrutinee
        (local %0 N)))
  
  tuple_sep(elem, sep, N) =
    (merge
      (call tuple1 [elem])
      (repeat
        body: (call tuple1 [
          (lambda @fn4
            (seq result=1
              (call sep)
              (call elem)))
        ])
        cap: (merge N -1)
        count: (set
          %0 = scrutinee
          (solve_merge %0
            (local N)
            -1))))
  
  rows(elem, col_sep, row_sep) =
    (merge
      (call tuple1 [
        (lambda @fn5
          (call array_sep [elem col_sep]))
      ])
      (repeat
        body: (call tuple1 [
          (lambda @fn6
            (seq result=1
              (call row_sep)
              (call array_sep [elem col_sep])))
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  rows_padded(elem, col_sep, row_sep, Pad) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call peek [
            (lambda @fn7
              (call _dimensions [elem col_sep row_sep]))
          ])
          %0 = scrutinee
          %1 = elem %0 0
          (arm
            (is_type %0 array)
            (len_eq %0 2)
            (local %1 MaxRowLen)))
        (match
          scrutinee: (call elem)
          %0 = scrutinee
          (arm
            (local %0 First))))
      (call _rows_padded [
        elem
        col_sep
        row_sep
        Pad
        1
        MaxRowLen
        (array [
          First
        ])
        (array [])
      ]))
  
  _rows_padded(elem, col_sep, row_sep, Pad, RowLen, MaxRowLen, AccRow, AccRows) =
    (alt
      (arm
        guard: (match
          scrutinee: (seq result=1
            (call col_sep)
            (call elem))
          %0 = scrutinee
          (arm
            (local %0 Elem)))
        body: (call _rows_padded [
          elem
          col_sep
          row_sep
          Pad
          (call Num.Inc [RowLen])
          MaxRowLen
          (merge
            (merge
              (array [])
              AccRow)
            (array [
              Elem
            ]))
          AccRows
        ]))
      (arm
        guard: (match
          scrutinee: (seq result=1
            (call row_sep)
            (call elem))
          %0 = scrutinee
          (arm
            (local %0 NextRow)))
        body: (call _rows_padded [
          elem
          col_sep
          row_sep
          Pad
          1
          MaxRowLen
          (array [
            NextRow
          ])
          (merge
            (merge
              (array [])
              AccRows)
            (array [
              (call Array.AppendN [AccRow Pad (merge MaxRowLen (neg RowLen))])
            ]))
        ]))
      (arm
        body: (call const [
          (merge
            (merge
              (array [])
              AccRows)
            (array [
              (call Array.AppendN [AccRow Pad (merge MaxRowLen (neg RowLen))])
            ]))
        ])))
  
  _dimensions(elem, col_sep, row_sep) =
    (seq result=1
      (call elem)
      (call __dimensions [elem col_sep row_sep 1 1 0]))
  
  __dimensions(elem, col_sep, row_sep, RowLen, ColLen, MaxRowLen) =
    (alt
      (arm
        guard: (seq result=1
          (call col_sep)
          (call elem))
        body: (call __dimensions [elem col_sep row_sep (call Num.Inc [RowLen]) ColLen MaxRowLen]))
      (arm
        guard: (seq result=1
          (call row_sep)
          (call elem))
        body: (call __dimensions [elem col_sep row_sep 1 (call Num.Inc [ColLen]) (call Num.Max [RowLen MaxRowLen])]))
      (arm
        body: (call const [
          (array [
            (call Num.Max [RowLen MaxRowLen])
            ColLen
          ])
        ])))
  
  columns(elem, col_sep, row_sep) =
    (seq result=1
      (match
        scrutinee: (call rows [elem col_sep row_sep])
        %0 = scrutinee
        (arm
          (local %0 Rows)))
      (call Table.Transpose [Rows]))
  
  cols =
    (call columns)
  
  columns_padded(elem, col_sep, row_sep, Pad) =
    (seq result=1
      (match
        scrutinee: (call rows_padded [elem col_sep row_sep Pad])
        %0 = scrutinee
        (arm
          (local %0 Rows)))
      (call Table.Transpose [Rows]))
  
  cols_padded =
    (call columns_padded)
  
