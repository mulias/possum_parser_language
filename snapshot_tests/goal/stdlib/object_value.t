Full created-stage goal form of stdlib/object_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  Obj.Has(O, K) =
    (match
      scrutinee: O~0
      %0 = scrutinee
      (arm
        (solve_merge %0 solvable=1
          (set
            %0 = scrutinee
            (is_type %0 object)
            (keys_exact %0 1)
            (search_key %0
              key: (set
                %0 = scrutinee
                (eq_slot %0 K~1))
              value: (set
                %0 = scrutinee)))
          _)))
  
  Obj.Get(O, K) =
    (seq result=1
      (match
        scrutinee: O~0
        %0 = scrutinee
        (arm
          (solve_merge %0 solvable=1
            (set
              %0 = scrutinee
              (is_type %0 object)
              (keys_exact %0 1)
              (search_key %0
                key: (set
                  %0 = scrutinee
                  (eq_slot %0 K~1))
                value: (set
                  %0 = scrutinee
                  (bind %0 V~2))))
            _)))
      V~2)
  
  Obj.Put(O, K, V) =
    (merge
      (merge
        (object [])
        O~0)
      (object [
        (pair K~1 V~2)
      ]))
  
  Obj.Size(O) =
    (seq result=1
      (match
        scrutinee: O~0
        %0 = scrutinee
        (arm
          (solve_repeat %0
            pattern: (set
              %0 = scrutinee
              (is_type %0 object)
              (keys_exact %0 1)
              (search_key %0
                key: (set
                  %0 = scrutinee)
                value: (set
                  %0 = scrutinee)))
            count: (bind S~2))))
      S~2)
  
  Obj.Keys(O) =
    (call _Obj.Keys [
      O~0
      (array [])
    ])
  
  _Obj.Keys(O, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: O~0
          %0 = scrutinee
          (arm
            (solve_merge %0 solvable=1
              (set
                %0 = scrutinee
                (is_type %0 object)
                (keys_exact %0 1)
                (search_key %0
                  key: (set
                    %0 = scrutinee
                    (bind %0 K~2))
                  value: (set
                    %0 = scrutinee)))
              (bind Rest~4))))
        body: (call _Obj.Keys [
          Rest~4
          (merge
            (merge
              (array [])
              Acc~1)
            (array [
              K~2
            ]))
        ]))
      (arm
        body: Acc~1))
  
  Obj.Values(O) =
    (call _Obj.Values [
      O~0
      (array [])
    ])
  
  _Obj.Values(O, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: O~0
          %0 = scrutinee
          (arm
            (solve_merge %0 solvable=1
              (set
                %0 = scrutinee
                (is_type %0 object)
                (keys_exact %0 1)
                (search_key %0
                  key: (set
                    %0 = scrutinee)
                  value: (set
                    %0 = scrutinee
                    (bind %0 V~3))))
              (bind Rest~4))))
        body: (call _Obj.Values [
          Rest~4
          (merge
            (merge
              (array [])
              Acc~1)
            (array [
              V~3
            ]))
        ]))
      (arm
        body: Acc~1))
  
