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
          (bind %0 N~0)))
      (repeat
        body: (call digit)
        cap: (read N~0)
        count: (set
          %0 = scrutinee
          (eq_slot %0 N~0))))

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
        count: (set
          %0 = scrutinee
          (bind %0 N~0)))
      N~0)

A count expression caps the same way; it is computed at runtime when its
reads are bound, and the cap is cleared when the count test must solve.

  $ possum -p 'digit * (N + 2) $ N' -i ''
  main =
    (seq result=1
      (repeat
        body: (call digit)
        count: (set
          %0 = scrutinee
          (solve_merge %0 ty=number solvable=0
            (bind N~0)
            2)))
      N~0)

A value repeat is not a loop: it lowers to a mult node compiled to the
RepeatValue op, evaluating each side once.

  $ possum -p '"" $ ("ab" * 3)' -i ''
  main =
    (seq result=1
      (call "")
      (mult "ab" 3))

Mult folds only constant-size results, following Elem.repeat: numbers
multiply, but string and array repeats stay unfolded so the output is
never materialized at compile time. A placeholder left side absorbs any
count; a placeholder count never folds.

  $ possum -p '"" $ (2 * 3)' -i ''
  main =
    (seq result=1
      (call "")
      6)

  $ possum -p '"" $ (_ * 5)' -i ''
  main =
    (seq result=1
      (call "")
      _)

  $ possum -p '"" $ (5 * _)' -i ''
  main =
    (seq result=1
      (call "")
      (mult 5 _))

  $ possum -p '"" $ (_ * _)' -i ''
  main =
    (seq result=1
      (call "")
      (mult _ _))

A repeat count that can never be a number is rejected at
canonicalization, in parser, value, and pattern contexts alike.

  $ possum -p '"a" * "b"' -i ''
  
  Validation Error: Repeat count must be a number, variable, function call, or a compound of those
  
  program:1:6-9:
  1 \xe2\x96\x8f "a" * "b" (esc)
    \xe2\x96\x8f       ^^^ (esc)
  
  [InvalidAst]
  [1]

  $ possum -p '"" $ (1 * (N + "a"))' -i ''
  
  Validation Error: Repeat count must be a number, variable, function call, or a compound of those
  
  program:1:15-18:
  1 \xe2\x96\x8f "" $ (1 * (N + "a")) (esc)
    \xe2\x96\x8f                ^^^ (esc)
  
  [InvalidAst]
  [1]
