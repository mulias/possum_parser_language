Full created-stage goal form of stdlib/object_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object_value.possum -i '' --no-stdlib
  Obj.Has(O, K) =
    (match
      scrutinee: O
      %0 = scrutinee
      (arm
        (solve_merge %0
          (set
            %0 = scrutinee
            (is_type %0 object)
            (keys_exact %0 1)
            (search_key %0
              key: (set
                %0 = scrutinee
                (local %0 K))
              value: (set
                %0 = scrutinee)))
          _)))
  
  Obj.Get(O, K) =
    (seq result=1
      (match
        scrutinee: O
        %0 = scrutinee
        (arm
          (solve_merge %0
            (set
              %0 = scrutinee
              (is_type %0 object)
              (keys_exact %0 1)
              (search_key %0
                key: (set
                  %0 = scrutinee
                  (local %0 K))
                value: (set
                  %0 = scrutinee
                  (local %0 V))))
            _)))
      V)
  
  Obj.Put(O, K, V) =
    (merge
      (merge
        (object [])
        O)
      (object [
        (pair K V)
      ]))
  
  Obj.Size(O) =
    (seq result=1
      (match
        scrutinee: O
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
            count: (local S))))
      S)
  
  Obj.Keys(O) =
    (call _Obj.Keys [
      O
      (array [])
    ])
  
  _Obj.Keys(O, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: O
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                (is_type %0 object)
                (keys_exact %0 1)
                (search_key %0
                  key: (set
                    %0 = scrutinee
                    (local %0 K))
                  value: (set
                    %0 = scrutinee)))
              (local Rest))))
        body: (call _Obj.Keys [
          Rest
          (merge
            (merge
              (array [])
              Acc)
            (array [
              K
            ]))
        ]))
      (arm
        body: Acc))
  
  Obj.Values(O) =
    (call _Obj.Values [
      O
      (array [])
    ])
  
  _Obj.Values(O, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: O
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                (is_type %0 object)
                (keys_exact %0 1)
                (search_key %0
                  key: (set
                    %0 = scrutinee)
                  value: (set
                    %0 = scrutinee
                    (local %0 V))))
              (local Rest))))
        body: (call _Obj.Values [
          Rest
          (merge
            (merge
              (array [])
              Acc)
            (array [
              V
            ]))
        ]))
      (arm
        body: Acc))
  
