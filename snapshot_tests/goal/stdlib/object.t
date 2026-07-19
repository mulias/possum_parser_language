Full created-stage goal form of stdlib/object.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/object.possum -i '' --no-stdlib
  object(key, value) =
    (repeat
      body: (call pair [key~0 value~1])
      count: (set
        %0 = scrutinee
        (in_range %0 1 _)))
  
  object_sep(key, kv_sep, value, sep) =
    (merge
      (call pair_sep [key~0 kv_sep~1 value~2])
      (repeat
        body: (seq result=1
          (call sep~3)
          (call pair_sep [key~0 kv_sep~1 value~2]))
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  object_until(key, value, stop) =
    (seq result=0
      (repeat
        body: (call unless [
          (lambda @fn0 captures=[key value]
            (call pair [key~0 value~1]))
          stop~2
        ])
        count: (set
          %0 = scrutinee
          (in_range %0 1 _)))
      (call peek [stop~2]))
  
  maybe_object(key, value) =
    (call default [
      (lambda @fn1 captures=[key value]
        (call object [key~0 value~1]))
      (object [])
    ])
  
  maybe_object_sep(key, pair_sep, value, sep) =
    (call default [
      (lambda @fn2 captures=[key pair_sep value sep]
        (call object_sep [key~0 pair_sep~1 value~2 sep~3]))
      (object [])
    ])
  
  pair(key, value) =
    (seq result=1
      (match
        scrutinee: (call key~0)
        %0 = scrutinee
        (arm
          (bind %0 K~2)))
      (seq result=1
        (match
          scrutinee: (call value~1)
          %0 = scrutinee
          (arm
            (bind %0 V~3)))
        (object [
          (pair K~2 V~3)
        ])))
  
  pair_sep(key, sep, value) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call key~0)
          %0 = scrutinee
          (arm
            (bind %0 K~3)))
        (call sep~1))
      (seq result=1
        (match
          scrutinee: (call value~2)
          %0 = scrutinee
          (arm
            (bind %0 V~4)))
        (object [
          (pair K~3 V~4)
        ])))
  
  record1(Key, value) =
    (seq result=1
      (match
        scrutinee: (call value~1)
        %0 = scrutinee
        (arm
          (bind %0 Value~2)))
      (object [
        (pair Key~0 Value~2)
      ]))
  
  record2(Key1, value1, Key2, value2) =
    (seq result=1
      (match
        scrutinee: (call value1~1)
        %0 = scrutinee
        (arm
          (bind %0 V1~4)))
      (seq result=1
        (match
          scrutinee: (call value2~3)
          %0 = scrutinee
          (arm
            (bind %0 V2~5)))
        (object [
          (pair Key1~0 V1~4)
          (pair Key2~2 V2~5)
        ])))
  
  record2_sep(Key1, value1, sep, Key2, value2) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call value1~1)
          %0 = scrutinee
          (arm
            (bind %0 V1~5)))
        (call sep~2))
      (seq result=1
        (match
          scrutinee: (call value2~4)
          %0 = scrutinee
          (arm
            (bind %0 V2~6)))
        (object [
          (pair Key1~0 V1~5)
          (pair Key2~3 V2~6)
        ])))
  
  record3(Key1, value1, Key2, value2, Key3, value3) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call value1~1)
          %0 = scrutinee
          (arm
            (bind %0 V1~6)))
        (match
          scrutinee: (call value2~3)
          %0 = scrutinee
          (arm
            (bind %0 V2~7))))
      (seq result=1
        (match
          scrutinee: (call value3~5)
          %0 = scrutinee
          (arm
            (bind %0 V3~8)))
        (object [
          (pair Key1~0 V1~6)
          (pair Key2~2 V2~7)
          (pair Key3~4 V3~8)
        ])))
  
  record3_sep(Key1, value1, sep1, Key2, value2, sep2, Key3, value3) =
    (seq result=1
      (seq result=1
        (seq result=1
          (seq result=1
            (match
              scrutinee: (call value1~1)
              %0 = scrutinee
              (arm
                (bind %0 V1~8)))
            (call sep1~2))
          (match
            scrutinee: (call value2~4)
            %0 = scrutinee
            (arm
              (bind %0 V2~9))))
        (call sep2~5))
      (seq result=1
        (match
          scrutinee: (call value3~7)
          %0 = scrutinee
          (arm
            (bind %0 V3~10)))
        (object [
          (pair Key1~0 V1~8)
          (pair Key2~3 V2~9)
          (pair Key3~6 V3~10)
        ])))
  
