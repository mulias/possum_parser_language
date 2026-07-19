Repeat unification: one node shape, a greedy loop with an optional cap
followed by an ordinary pattern test of the iteration count. The cap is
populated proactively whenever the count pattern implies one (exact
counts, bare locals, upper range limits, evaluable expressions); binding
analysis later keeps a cap whose reads are all bound and clears it
otherwise.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum -p 'digit * 5' -i ''
  main =
    (repeat
      body: (call digit)
      cap: 5
      count: (set
        %0 = scrutinee
        (eq_const %0 5)))

  $ possum -p 'int -> N & digit * N' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (local %0 N)))
      (repeat
        body: (call digit)
        cap: (local N)
        count: (set
          %0 = scrutinee
          (local %0 N))))

  $ possum -p 'digit * (0..)' -i ''
  main =
    (repeat
      body: (call digit)
      count: (set
        %0 = scrutinee
        (in_range %0 0 _)))

  $ possum -p 'digit * (..3)' -i ''
  main =
    (repeat
      body: (call digit)
      cap: 3
      count: (set
        %0 = scrutinee
        (in_range %0 _ 3)))

  $ possum -p 'digit * (1..100)' -i ''
  main =
    (repeat
      body: (call digit)
      cap: 100
      count: (set
        %0 = scrutinee
        (in_range %0 1 100)))

A local count caps tentatively: binding analysis keeps the cap if the
local is bound and clears it if the count binds instead.

  $ possum -p 'digit * N $ N' -i ''
  main =
    (seq result=1
      (repeat
        body: (call digit)
        cap: (local N)
        count: (set
          %0 = scrutinee
          (local %0 N)))
      N)

A count expression caps the same way; it is computed at runtime when its
reads are bound, and the cap is cleared when the count test must solve.

  $ possum -p 'digit * (N + 2) $ N' -i ''
  main =
    (seq result=1
      (repeat
        body: (call digit)
        cap: (merge N 2)
        count: (set
          %0 = scrutinee
          (solve_merge %0
            (local N)
            2)))
      N)

A value repeat's count is evaluable, so it is both the loop cap and an
eval_eq exact-count test.

  $ possum -p '"" $ ("ab" * 3)' -i ''
  main =
    (seq result=1
      (call "")
      (repeat
        body: "ab"
        cap: 3
        count: (set
          %0 = scrutinee
          (eval_eq %0 3))))
