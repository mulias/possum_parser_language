Full created-stage goal form of stdlib/predicate_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/predicate_value.possum -i '' --no-stdlib
  Is.String(V) =
    (match
      scrutinee: V~0
      %0 = scrutinee
      (arm
        (solve_merge %0 solvable=1
          ""
          _)))
  
  Is.Number(V) =
    (match
      scrutinee: V~0
      %0 = scrutinee
      (arm
        (solve_merge %0 solvable=1
          0
          _)))
  
  Is.Bool(V) =
    (match
      scrutinee: V~0
      %0 = scrutinee
      (arm
        (solve_merge %0 solvable=1
          false
          _)))
  
  Is.Null(V) =
    (match
      scrutinee: V~0
      %0 = scrutinee
      (arm
        (eq_const %0 null)))
  
  Is.Array(V) =
    (match
      scrutinee: V~0
      %0 = scrutinee
      (arm
        (solve_merge %0 solvable=1
          (set
            %0 = scrutinee
            (is_type %0 array)
            (len_eq %0 0))
          _)))
  
  Is.Object(V) =
    (match
      scrutinee: V~0
      %0 = scrutinee
      (arm
        (solve_merge %0 solvable=1
          (set
            %0 = scrutinee
            (is_type %0 object)
            (keys_exact %0 0))
          _)))
  
  Is.Equal(A, B) =
    (match
      scrutinee: A~0
      %0 = scrutinee
      (arm
        (eq_slot %0 B~1)))
  
  Is.LessThan(A, B) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          (arm
            (eq_slot %0 B~1)))
        body: @Fail)
      (arm
        body: (match
          scrutinee: A~0
          %0 = scrutinee
          (arm
            (in_range %0 _ (read B~1))))))
  
  Is.LessThanOrEqual(A, B) =
    (match
      scrutinee: A~0
      %0 = scrutinee
      (arm
        (in_range %0 _ (read B~1))))
  
  Is.GreaterThan(A, B) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          (arm
            (eq_slot %0 B~1)))
        body: @Fail)
      (arm
        body: (match
          scrutinee: A~0
          %0 = scrutinee
          (arm
            (in_range %0 (read B~1) _)))))
  
  Is.GreaterThanOrEqual(A, B) =
    (match
      scrutinee: A~0
      %0 = scrutinee
      (arm
        (in_range %0 (read B~1) _)))
  
