Full created-stage goal form of stdlib/object.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object.possum -i '' --no-stdlib
  object(key, value) =
    (repeat
      body: (call pair [key value])
      count: (set
        %0 = scrutinee
        (in_range %0 1 _)))
  
  object_sep(key, kv_sep, value, sep) =
    (merge
      (call pair_sep [key kv_sep value])
      (repeat
        body: (seq result=1
          (call sep)
          (call pair_sep [key kv_sep value]))
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  object_until(key, value, stop) =
    (seq result=0
      (repeat
        body: (call unless [
          (lambda @fn0
            (call pair [key value]))
          stop
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 1 _)))
      (call peek [stop]))
  
  maybe_object(key, value) =
    (call default [
      (lambda @fn1
        (call object [key value]))
      (object [])
    ])
  
  maybe_object_sep(key, pair_sep, value, sep) =
    (call default [
      (lambda @fn2
        (call object_sep [key pair_sep value sep]))
      (object [])
    ])
  
  pair(key, value) =
    (seq result=1
      (match
        scrutinee: (call key)
        %0 = scrutinee
        (arm
          (local %0 K)))
      (seq result=1
        (match
          scrutinee: (call value)
          %0 = scrutinee
          (arm
            (local %0 V)))
        (object [
          (pair K V)
        ])))
  
  pair_sep(key, sep, value) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call key)
          %0 = scrutinee
          (arm
            (local %0 K)))
        (call sep))
      (seq result=1
        (match
          scrutinee: (call value)
          %0 = scrutinee
          (arm
            (local %0 V)))
        (object [
          (pair K V)
        ])))
  
  record1(Key, value) =
    (seq result=1
      (match
        scrutinee: (call value)
        %0 = scrutinee
        (arm
          (local %0 Value)))
      (object [
        (pair Key Value)
      ]))
  
  record2(Key1, value1, Key2, value2) =
    (seq result=1
      (match
        scrutinee: (call value1)
        %0 = scrutinee
        (arm
          (local %0 V1)))
      (seq result=1
        (match
          scrutinee: (call value2)
          %0 = scrutinee
          (arm
            (local %0 V2)))
        (object [
          (pair Key1 V1)
          (pair Key2 V2)
        ])))
  
  record2_sep(Key1, value1, sep, Key2, value2) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call value1)
          %0 = scrutinee
          (arm
            (local %0 V1)))
        (call sep))
      (seq result=1
        (match
          scrutinee: (call value2)
          %0 = scrutinee
          (arm
            (local %0 V2)))
        (object [
          (pair Key1 V1)
          (pair Key2 V2)
        ])))
  
  record3(Key1, value1, Key2, value2, Key3, value3) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call value1)
          %0 = scrutinee
          (arm
            (local %0 V1)))
        (match
          scrutinee: (call value2)
          %0 = scrutinee
          (arm
            (local %0 V2))))
      (seq result=1
        (match
          scrutinee: (call value3)
          %0 = scrutinee
          (arm
            (local %0 V3)))
        (object [
          (pair Key1 V1)
          (pair Key2 V2)
          (pair Key3 V3)
        ])))
  
  record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (match
              scrutinee: (call value1)
              %0 = scrutinee
              (arm
                (local %0 V1)))
            (call sep1))
          (match
            scrutinee: (call value2)
            %0 = scrutinee
            (arm
              (local %0 V2))))
        (call sep2))
      (seq result=1
        (match
          scrutinee: (call value3)
          %0 = scrutinee
          (arm
            (local %0 V3)))
        (object [
          (pair Key1 V1)
          (pair Key2 V2)
          (pair Key3 V3)
        ])))
  
