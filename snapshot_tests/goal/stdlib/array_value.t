Full created-stage goal form of stdlib/array_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/array_value.possum -i '' --no-stdlib
  Array.First(A) =
    (seq result=1
      (match
        scrutinee: A
        %0 = scrutinee
        (arm
          (solve_merge %0
            (set
              %0 = scrutinee
              %1 = elem %0 0
              (is_type %0 array)
              (len_eq %0 1)
              (local %1 F))
            _)))
      F)
  
  Array.Rest(A) =
    (seq result=1
      (match
        scrutinee: A
        %0 = scrutinee
        (arm
          (solve_merge %0
            (set
              %0 = scrutinee
              (is_type %0 array)
              (len_eq %0 1))
            (local R))))
      R)
  
  Array.Length(A) =
    (seq result=1
      (match
        scrutinee: A
        %0 = scrutinee
        (arm
          (solve_repeat %0
            pattern: (set
              %0 = scrutinee
              (is_type %0 array)
              (len_eq %0 1))
            count: (local L))))
      L)
  
  Array.Reverse(A) =
    (call _Array.Reverse [
      A
      (array [])
    ])
  
  _Array.Reverse(A, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 First))
              (local Rest))))
        body: (call _Array.Reverse [
          Rest
          (merge
            (array [
              First
            ])
            Acc)
        ]))
      (arm
        body: Acc))
  
  Array.Map(A, Fn) =
    (call _Array.Map [
      A
      Fn
      (array [])
    ])
  
  _Array.Map(A, Fn, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 First))
              (local Rest))))
        body: (call _Array.Map [
          Rest
          Fn
          (merge
            (merge
              (array [])
              Acc)
            (array [
              (call Fn [First])
            ]))
        ]))
      (arm
        body: Acc))
  
  Array.Filter(A, Pred) =
    (call _Array.Filter [
      A
      Pred
      (array [])
    ])
  
  _Array.Filter(A, Pred, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 First))
              (local Rest))))
        body: (call _Array.Filter [
          Rest
          Pred
          (alt
            (arm
              guard: (call Pred [First])
              body: (merge
                (merge
                  (array [])
                  Acc)
                (array [
                  First
                ])))
            (arm
              body: Acc))
        ]))
      (arm
        body: Acc))
  
  Array.Reject(A, Pred) =
    (call _Array.Reject [
      A
      Pred
      (array [])
    ])
  
  _Array.Reject(A, Pred, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 First))
              (local Rest))))
        body: (call _Array.Reject [
          Rest
          Pred
          (alt
            (arm
              guard: (call Pred [First])
              body: Acc)
            (arm
              body: (merge
                (merge
                  (array [])
                  Acc)
                (array [
                  First
                ]))))
        ]))
      (arm
        body: Acc))
  
  Array.Merge(A) =
    (call _Array.Merge [A null])
  
  _Array.Merge(A, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 First))
              (local Rest))))
        body: (call _Array.Merge [Rest (merge Acc First)]))
      (arm
        body: Acc))
  
  Array.MapMerge(A, Fn) =
    (call _Array.MapMerge [A Fn null])
  
  _Array.MapMerge(A, Fn, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 First))
              (local Rest))))
        body: (call _Array.MapMerge [Rest Fn (merge Acc (call Fn [First]))]))
      (arm
        body: Acc))
  
  Array.Reduce(A, Fn, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 First))
              (local Rest))))
        body: (call Array.Reduce [Rest Fn (call Fn [Acc First])]))
      (arm
        body: Acc))
  
  Array.ZipObject(Ks, Vs) =
    (call _Array.ZipObject [
      Ks
      Vs
      (object [])
    ])
  
  _Array.ZipObject(Ks, Vs, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: Ks
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 K))
                (local KsRest))))
          (match
            scrutinee: Vs
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 V))
                (local VsRest)))))
        body: (call _Array.ZipObject [
          KsRest
          VsRest
          (merge
            (merge
              (object [])
              Acc)
            (object [
              (pair K V)
            ]))
        ]))
      (arm
        body: Acc))
  
  Array.ZipPairs(A1, A2) =
    (call _Array.ZipPairs [
      A1
      A2
      (array [])
    ])
  
  _Array.ZipPairs(A1, A2, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: A1
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 First1))
                (local Rest1))))
          (match
            scrutinee: A2
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 First2))
                (local Rest2)))))
        body: (call _Array.ZipPairs [
          Rest1
          Rest2
          (merge
            (merge
              (array [])
              Acc)
            (array [
              (array [
                First1
                First2
              ])
            ]))
        ]))
      (arm
        body: Acc))
  
  Array.AppendN(A, Val, N) =
    (merge
      A
      (repeat
        body: (array [
          Val
        ])
        cap: N
        count: (set
          %0 = scrutinee
          (eval_eq %0 N))))
  
  Table.Transpose(T) =
    (call _Table.Transpose [
      T
      (array [])
    ])
  
  _Table.Transpose(T, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: (call _Table.FirstPerRow [T])
            %0 = scrutinee
            (arm
              (local %0 FirstPerRow)))
          (match
            scrutinee: (call _Table.RestPerRow [T])
            %0 = scrutinee
            (arm
              (local %0 RestPerRow))))
        body: (call _Table.Transpose [
          RestPerRow
          (merge
            (merge
              (array [])
              Acc)
            (array [
              FirstPerRow
            ]))
        ]))
      (arm
        body: Acc))
  
  _Table.FirstPerRow(T) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: T
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 Row))
              (local Rest))))
        (match
          scrutinee: Row
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 VeryFirst))
              _))))
      (call __Table.FirstPerRow [
        Rest
        (array [
          VeryFirst
        ])
      ]))
  
  __Table.FirstPerRow(T, Acc) =
    (alt
      (arm
        guard: (seq result=1
          (match
            scrutinee: T
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 Row))
                (local Rest))))
          (match
            scrutinee: Row
            %0 = scrutinee
            (arm
              (solve_merge %0
                (set
                  %0 = scrutinee
                  %1 = elem %0 0
                  (is_type %0 array)
                  (len_eq %0 1)
                  (local %1 First))
                _))))
        body: (call __Table.FirstPerRow [
          Rest
          (merge
            (merge
              (array [])
              Acc)
            (array [
              First
            ]))
        ]))
      (arm
        body: Acc))
  
  _Table.RestPerRow(T) =
    (call __Table.RestPerRow [
      T
      (array [])
    ])
  
  __Table.RestPerRow(T, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: T
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 Row))
              (local Rest))))
        body: (alt
          (arm
            guard: (match
              scrutinee: Row
              %0 = scrutinee
              (arm
                (solve_merge %0
                  (set
                    %0 = scrutinee
                    (is_type %0 array)
                    (len_eq %0 1))
                  (local RowRest))))
            body: (call __Table.RestPerRow [
              Rest
              (merge
                (merge
                  (array [])
                  Acc)
                (array [
                  RowRest
                ]))
            ]))
          (arm
            body: (call __Table.RestPerRow [
              Rest
              (merge
                (merge
                  (array [])
                  Acc)
                (array [
                  (array [])
                ]))
            ]))))
      (arm
        body: Acc))
  
  Table.RotateClockwise(T) =
    (call Array.Map [(call Table.Transpose [T]) Array.Reverse])
  
  Table.RotateCounterClockwise(T) =
    (call Array.Reverse [(call Table.Transpose [T])])
  
  Table.ZipObjects(Ks, Rows) =
    (call _Table.ZipObjects [
      Ks
      Rows
      (array [])
    ])
  
  _Table.ZipObjects(Ks, Rows, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Rows
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 Row))
              (local Rest))))
        body: (call _Table.ZipObjects [
          Ks
          Rest
          (merge
            (merge
              (array [])
              Acc)
            (array [
              (call Array.ZipObject [Ks Row])
            ]))
        ]))
      (arm
        body: Acc))
  
