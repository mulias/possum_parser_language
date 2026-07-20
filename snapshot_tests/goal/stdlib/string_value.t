Full created-stage goal form of stdlib/string_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/string_value.possum -i '' --no-stdlib
  Str.Length(S) =
    (seq result=1
      (match
        scrutinee: S~0
        %0 = scrutinee
        (arm
          (solve_repeat %0
            pattern: (set
              %0 = scrutinee
              (in_range %0 "\x00" _)) (esc)
            count: (bind L~1))))
      L~1)
  
