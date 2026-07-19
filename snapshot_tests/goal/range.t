Ranges. A range in operand position is a literal parser elem, so it is
call-wrapped like other literals; a range pattern is an in_range
constraint whose limits are none, a bare local, or an evaluable
expression goal.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum -p '"a".."z"' -i ''
  main =
    (call (range "a" "z"))

  $ possum -p '1..9' -i ''
  main =
    (call (range 1 9))

  $ possum -p 'int -> 1..9' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (in_range %0 1 9)))

  $ possum -p 'int -> 0..' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (in_range %0 0 _)))

An unbound local limit binds the matched value; a bound one compares.
Either way it prints as a local limit at the created stage.

  $ possum -p 'int -> N & int -> 0..N' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 N~0)))
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (in_range %0 0 (read N~0)))))

Expression limits evaluate at match time.

  $ possum -p 'int -> N & int -> 0..(N + 1)' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 N~0)))
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (in_range %0 0 (merge N~0 1)))))
