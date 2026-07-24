Full created-stage goal form of stdlib/array_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  Array.First(A) =
    (seq result=1
      (match
        scrutinee: A~0
        %0 = scrutinee
        %1 = elem %0 0
        (arm
          (is_type %0 array)
          (len_min %0 1)
          (bind %1 F~1)))
      F~1)
  
  Array.Rest(A) =
    (seq result=1
      (match
        scrutinee: A~0
        %0 = scrutinee
        %1 = slice %0 1 0
        (arm
          (is_type %0 array)
          (len_min %0 1)
          (bind %1 R~1)))
      R~1)
  
  Array.Length(A) =
    (seq result=1
      (match
        scrutinee: A~0
        %0 = scrutinee
        (arm
          (solve_repeat %0
            pattern: (set
              %0 = scrutinee
              (is_type %0 array)
              (len_eq %0 1))
            count: (bind L~1))))
      L~1)
  
  Array.Reverse(A) =
    (call _Array.Reverse [
      A~0
      (array [])
    ])
  
  _Array.Reverse(A, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 First~2)
            (bind %2 Rest~3)))
        body: (call _Array.Reverse [
          Rest~3
          (merge
            (array [
              First~2
            ])
            Acc~1)
        ]))
      (arm
        body: Acc~1))
  
  Array.Map(A, Fn) =
    (call _Array.Map [
      A~0
      Fn~1
      (array [])
    ])
  
  _Array.Map(A, Fn, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 First~3)
            (bind %2 Rest~4)))
        body: (call _Array.Map [
          Rest~4
          Fn~1
          (merge
            (merge
              (array [])
              Acc~2)
            (array [
              (call Fn~1 [First~3])
            ]))
        ]))
      (arm
        body: Acc~2))
  
  Array.Filter(A, Pred) =
    (call _Array.Filter [
      A~0
      Pred~1
      (array [])
    ])
  
  _Array.Filter(A, Pred, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 First~3)
            (bind %2 Rest~4)))
        body: (call _Array.Filter [
          Rest~4
          Pred~1
          (alt
            (arm
              guard: (call Pred~1 [First~3])
              body: (merge
                (merge
                  (array [])
                  Acc~2)
                (array [
                  First~3
                ])))
            (arm
              body: Acc~2))
        ]))
      (arm
        body: Acc~2))
  
  Array.Reject(A, Pred) =
    (call _Array.Reject [
      A~0
      Pred~1
      (array [])
    ])
  
  _Array.Reject(A, Pred, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 First~3)
            (bind %2 Rest~4)))
        body: (call _Array.Reject [
          Rest~4
          Pred~1
          (alt
            (arm
              guard: (call Pred~1 [First~3])
              body: Acc~2)
            (arm
              body: (merge
                (merge
                  (array [])
                  Acc~2)
                (array [
                  First~3
                ]))))
        ]))
      (arm
        body: Acc~2))
  
  Array.Merge(A) =
    (call _Array.Merge [A~0 null])
  
  _Array.Merge(A, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 First~2)
            (bind %2 Rest~3)))
        body: (call _Array.Merge [Rest~3 (merge Acc~1 First~2)]))
      (arm
        body: Acc~1))
  
  Array.MapMerge(A, Fn) =
    (call _Array.MapMerge [A~0 Fn~1 null])
  
  _Array.MapMerge(A, Fn, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 First~3)
            (bind %2 Rest~4)))
        body: (call _Array.MapMerge [Rest~4 Fn~1 (merge Acc~2 (call Fn~1 [First~3]))]))
      (arm
        body: Acc~2))
  
  Array.Reduce(A, Fn, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 First~3)
            (bind %2 Rest~4)))
        body: (call Array.Reduce [Rest~4 Fn~1 (call Fn~1 [Acc~2 First~3])]))
      (arm
        body: Acc~2))
  
  Array.ZipObject(Ks, Vs) =
    (call _Array.ZipObject [
      Ks~0
      Vs~1
      (object [])
    ])
  
  _Array.ZipObject(Ks, Vs, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: Ks~0
            %0 = scrutinee
            %1 = elem %0 0
            %2 = slice %0 1 0
            (arm
              (is_type %0 array)
              (len_min %0 1)
              (bind %1 K~3)
              (bind %2 KsRest~4)))
          (match
            scrutinee: Vs~1
            %0 = scrutinee
            %1 = elem %0 0
            %2 = slice %0 1 0
            (arm
              (is_type %0 array)
              (len_min %0 1)
              (bind %1 V~5)
              (bind %2 VsRest~6))))
        body: (call _Array.ZipObject [
          KsRest~4
          VsRest~6
          (merge
            (merge
              (object [])
              Acc~2)
            (object [
              (pair K~3 V~5)
            ]))
        ]))
      (arm
        body: Acc~2))
  
  Array.ZipPairs(A1, A2) =
    (call _Array.ZipPairs [
      A1~0
      A2~1
      (array [])
    ])
  
  _Array.ZipPairs(A1, A2, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: A1~0
            %0 = scrutinee
            %1 = elem %0 0
            %2 = slice %0 1 0
            (arm
              (is_type %0 array)
              (len_min %0 1)
              (bind %1 First1~3)
              (bind %2 Rest1~4)))
          (match
            scrutinee: A2~1
            %0 = scrutinee
            %1 = elem %0 0
            %2 = slice %0 1 0
            (arm
              (is_type %0 array)
              (len_min %0 1)
              (bind %1 First2~5)
              (bind %2 Rest2~6))))
        body: (call _Array.ZipPairs [
          Rest1~4
          Rest2~6
          (merge
            (merge
              (array [])
              Acc~2)
            (array [
              (array [
                First1~3
                First2~5
              ])
            ]))
        ]))
      (arm
        body: Acc~2))
  
  Array.AppendN(A, Val, N) =
    (merge
      A~0
      (mult
        (array [
          Val~1
        ])
        N~2))
  
  Table.Transpose(T) =
    (call _Table.Transpose [
      T~0
      (array [])
    ])
  
  _Table.Transpose(T, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: (call _Table.FirstPerRow [T~0])
            %0 = scrutinee
            (arm
              (bind %0 FirstPerRow~2)))
          (match
            scrutinee: (call _Table.RestPerRow [T~0])
            %0 = scrutinee
            (arm
              (bind %0 RestPerRow~3))))
        body: (call _Table.Transpose [
          RestPerRow~3
          (merge
            (merge
              (array [])
              Acc~1)
            (array [
              FirstPerRow~2
            ]))
        ]))
      (arm
        body: Acc~1))
  
  _Table.FirstPerRow(T) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: T~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 Row~1)
            (bind %2 Rest~2)))
        (match
          scrutinee: Row~1
          %0 = scrutinee
          %1 = elem %0 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 VeryFirst~3))))
      (call __Table.FirstPerRow [
        Rest~2
        (array [
          VeryFirst~3
        ])
      ]))
  
  __Table.FirstPerRow(T, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: T~0
            %0 = scrutinee
            %1 = elem %0 0
            %2 = slice %0 1 0
            (arm
              (is_type %0 array)
              (len_min %0 1)
              (bind %1 Row~2)
              (bind %2 Rest~3)))
          (match
            scrutinee: Row~2
            %0 = scrutinee
            %1 = elem %0 0
            (arm
              (is_type %0 array)
              (len_min %0 1)
              (bind %1 First~4))))
        body: (call __Table.FirstPerRow [
          Rest~3
          (merge
            (merge
              (array [])
              Acc~1)
            (array [
              First~4
            ]))
        ]))
      (arm
        body: Acc~1))
  
  _Table.RestPerRow(T) =
    (call __Table.RestPerRow [
      T~0
      (array [])
    ])
  
  __Table.RestPerRow(T, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: T~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 Row~2)
            (bind %2 Rest~3)))
        body: (alt
          (arm
            guard: (match
              scrutinee: Row~2
              %0 = scrutinee
              %1 = slice %0 1 0
              (arm
                (is_type %0 array)
                (len_min %0 1)
                (bind %1 RowRest~4)))
            body: (call __Table.RestPerRow [
              Rest~3
              (merge
                (merge
                  (array [])
                  Acc~1)
                (array [
                  RowRest~4
                ]))
            ]))
          (arm
            body: (call __Table.RestPerRow [
              Rest~3
              (merge
                (merge
                  (array [])
                  Acc~1)
                (array [
                  (array [])
                ]))
            ]))))
      (arm
        body: Acc~1))
  
  Table.RotateClockwise(T) =
    (call Array.Map [(call Table.Transpose [T~0]) Array.Reverse])
  
  Table.RotateCounterClockwise(T) =
    (call Array.Reverse [(call Table.Transpose [T~0])])
  
  Table.ZipObjects(Ks, Rows) =
    (call _Table.ZipObjects [
      Ks~0
      Rows~1
      (array [])
    ])
  
  _Table.ZipObjects(Ks, Rows, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Rows~1
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 Row~3)
            (bind %2 Rest~4)))
        body: (call _Table.ZipObjects [
          Ks~0
          Rest~4
          (merge
            (merge
              (array [])
              Acc~2)
            (array [
              (call Array.ZipObject [Ks~0 Row~3])
            ]))
        ]))
      (arm
        body: Acc~2))
  
