Full created-stage goal form of stdlib/cast_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/cast_value.possum -i '' --no-stdlib
  As.Number(V) =
    (alt
      (arm
        guard: (call Is.Number [V~0]))
      (arm
        body: (seq result=1
          (match
            scrutinee: V~0
            %0 = scrutinee
            (arm
              (match_template %0
                (set
                  %0 = scrutinee
                  (solve_merge %0
                    0
                    (bind N~1))))))
          N~1)))
  
  As.String(V) =
    (to_string V~0)
  
