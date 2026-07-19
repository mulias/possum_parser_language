Goal→goal constant folding. The goal ast is built from unfolded can;
PRINT_GOAL_AST=created prints it as built, PRINT_GOAL_AST=folded prints
it after the fold pass (PRINT_GOAL_AST=true is the latest stage).

  $ export RUN_VM=false

Constant value merges fold bottom-up on the goals array: numbers add,
strings concatenate, null is the merge identity, booleans combine.

  $ PRINT_GOAL_AST=created possum -p 'int $ (1 + 2)' -i ''
  main =
    (seq result=1
      (call int)
      (merge 1 2))

  $ PRINT_GOAL_AST=folded possum -p 'int $ (1 + 2)' -i ''
  main =
    (seq result=1
      (call int)
      3)

  $ PRINT_GOAL_AST=folded possum -p 'int $ ("a" + "b" + "c")' -i ''
  main =
    (seq result=1
      (call int)
      "abc")

  $ PRINT_GOAL_AST=folded possum -p 'int $ (null + [1] + [2])' -i ''
  main =
    (seq result=1
      (call int)
      (array [
        1
        2
      ]))

  $ PRINT_GOAL_AST=folded possum -p 'int $ (true + false)' -i ''
  main =
    (seq result=1
      (call int)
      true)

Negation of a constant folds, including through a folded merge.

  $ PRINT_GOAL_AST=folded possum -p 'int $ -(1 + 2)' -i ''
  main =
    (seq result=1
      (call int)
      -3)

A parser merge never folds: its operands are invocations, not values.

  $ PRINT_GOAL_AST=folded possum -p '"a" + "b"' -i ''
  main =
    (merge (call "a") (call "b"))

A solve_merge whose parts are all constants collapses to eq_const.

  $ PRINT_GOAL_AST=created possum -p 'int -> ("a" + "b")' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (solve_merge %0
          "a"
          "b")))

  $ PRINT_GOAL_AST=folded possum -p 'int -> ("a" + "b")' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (eq_const %0 "ab")))

Adjacent constant parts fold together; non-constant parts survive.

  $ PRINT_GOAL_AST=folded possum -p 'int -> (A + 1 + 2)' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (solve_merge %0
          (local A)
          3)))

Null parts drop as the merge identity: a single surviving local becomes
a plain occurrence, a lone placeholder leaves the arm unconstrained (the
match then folds away entirely), and all-null merges compare against
null.

  $ PRINT_GOAL_AST=folded possum -p 'int -> (A + null)' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (local %0 A)))

  $ PRINT_GOAL_AST=folded possum -p 'int -> (_ + null)' -i ''
  main =
    (call int)

  $ PRINT_GOAL_AST=folded possum -p 'int -> (null + null)' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (eq_const %0 null)))

A negated constraint on a constant number applies its negation count at
compile time; non-constant parts stay runtime negations.

  $ PRINT_GOAL_AST=created possum -p 'int -> --5' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (negated %0 2 5)))

  $ PRINT_GOAL_AST=folded possum -p 'int -> --5' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (eq_const %0 5)))

  $ PRINT_GOAL_AST=folded possum -p 'int -> -A' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (negated %0 1 (local A))))

A structural sub-pattern that folds to a single constant comparison
collapses back to an expression part of its parent.

  $ PRINT_GOAL_AST=created possum -p 'int -> (N + -1)' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (solve_merge %0
          (local N)
          (set
            %0 = scrutinee
            (negated %0 1 1)))))

  $ PRINT_GOAL_AST=folded possum -p 'int -> (N + -1)' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (solve_merge %0
          (local N)
          -1)))

A constant repeat folds only when the result is constant-size: numbers
multiply, but string and array repeats would materialize output
proportional to the count and stay unfolded.

  $ PRINT_GOAL_AST=folded possum -p 'int -> (2 * 3)' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (eq_const %0 6)))

  $ PRINT_GOAL_AST=folded possum -p 'int -> ("ab" * 2)' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (solve_repeat %0
          pattern: "ab"
          count: 2)))

A single-arm match whose constraints all fold away, with no guard and
no body, is the identity on its scrutinee and folds to it.

  $ PRINT_GOAL_AST=created possum -p 'int -> _' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm))

  $ PRINT_GOAL_AST=folded possum -p 'int -> _' -i ''
  main =
    (call int)

A placeholder element interns its place at creation but lowers to no
constraints; simplification prunes places no constraint reaches.

  $ PRINT_GOAL_AST=created possum -p 'json -> [1, _]' -i '[1, 2]'
  main =
    (match
      scrutinee: (call json)
      %0 = scrutinee
      %1 = elem %0 0
      %2 = elem %0 1
      (arm
        (is_type %0 array)
        (len_eq %0 2)
        (eq_const %1 1)))

  $ PRINT_GOAL_AST=folded possum -p 'json -> [1, _]' -i '[1, 2]'
  main =
    (match
      scrutinee: (call json)
      %0 = scrutinee
      %1 = elem %0 0
      (arm
        (is_type %0 array)
        (len_eq %0 2)
        (eq_const %1 1)))

Adjacent placeholder parts collapse — `_ + _` is "whatever plus
whatever", one absorption — so `[1, _ + _]` folds to the same goal as
`[1, _]`. `A + _` must not fold: "A plus whatever" is underdetermined.
(The can compiler still rejects both; the goal-side error arrives with
binding on goal.)

  $ PRINT_GOAL_AST=folded possum -p 'json -> [1, _ + _]' -i '[1, 2]'
  main =
    (match
      scrutinee: (call json)
      %0 = scrutinee
      %1 = elem %0 0
      (arm
        (is_type %0 array)
        (len_eq %0 2)
        (eq_const %1 1)))
  
  Program Error: pattern part is unbound here: a merge can solve at most one unbound part
  
  program:1:16-17:
  1 \xe2\x96\x8f json -> [1, _ + _] (esc)
    \xe2\x96\x8f                 ^ (esc)
  
  [UnboundVariable]
  [1]

  $ PRINT_GOAL_AST=folded possum -p 'json -> [1, A + _]' -i '[1, 2]'
  main =
    (match
      scrutinee: (call json)
      %0 = scrutinee
      %1 = elem %0 0
      %2 = elem %0 1
      (arm
        (is_type %0 array)
        (len_eq %0 2)
        (eq_const %1 1)
        (solve_merge %2
          (local A)
          _)))
  
  Program Error: pattern part is unbound here: a merge can solve at most one unbound part
  
  program:1:16-17:
  1 \xe2\x96\x8f json -> [1, A + _] (esc)
    \xe2\x96\x8f                 ^ (esc)
  
  [UnboundVariable]
  [1]

A repeat count test that folds to an empty set drops.

  $ PRINT_GOAL_AST=created possum -p 'int * _' -i ''
  main =
    (repeat
      body: (call int)
      count: (set
        %0 = scrutinee))

  $ PRINT_GOAL_AST=folded possum -p 'int * _' -i ''
  main =
    (repeat
      body: (call int))

Repeat caps and count tests fold: the cap expression folds on the goals
array, the count pattern's solve_merge collapses to eq_const.

  $ PRINT_GOAL_AST=created possum -p 'int * (1 + 2)' -i ''
  main =
    (repeat
      body: (call int)
      cap: (merge 1 2)
      count: (set
        %0 = scrutinee
        (solve_merge %0
          1
          2)))

  $ PRINT_GOAL_AST=folded possum -p 'int * (1 + 2)' -i ''
  main =
    (repeat
      body: (call int)
      cap: 3
      count: (set
        %0 = scrutinee
        (eq_const %0 3)))
