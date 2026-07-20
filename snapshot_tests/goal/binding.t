Binding analysis on the goal ast. PRINT_GOAL_AST=bound prints the goal
after classification: every neutral (local ...) occurrence is rewritten
to a binder (bind), a bound read (eq_slot / read), or a global reference
(eq_global / global); eval-position idents carry their frame slot as
name$slot; lambdas carry their computed capture sets; repeat caps whose
reads are unbound are cleared.

  $ export PRINT_GOAL_AST=bound RUN_VM=false

The first pattern occurrence binds, later occurrences compare, and eval
reads resolve to the bound slot.

  $ possum -p 'int -> N & int -> N $ N' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 N~0)))
      (seq result=1
        (match
          scrutinee: (call int)
          %0 = scrutinee
          (arm
            (eq_slot %0 N~0)))
        N~0))

Parameters occupy the first frame slots and are bound on entry.

  $ possum -p 'pair(p, sep) = p -> A & sep & p -> B $ [A, B]
  > main = pair(int, ",")' -i ''
  pair(p, sep) =
    (seq result=1
      (seq result=1
        (match
          scrutinee: (call p~0)
          %0 = scrutinee
          (arm
            (bind %0 A~2)))
        (call sep~1))
      (seq result=1
        (match
          scrutinee: (call p~0)
          %0 = scrutinee
          (arm
            (bind %0 B~3)))
        (array [
          A~2
          B~3
        ])))
  
  main =
    (call pair [int ","])
  

A global with the same name wins over a local in pattern position.

  $ possum -p 'Max = 5
  > main = int -> Max' -i ''
  Max =
    5
  
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (eq_global %0 Max)))
  

Merge parts classify like bare occurrences: an unbound part is the
solvable rest, a bound part compares.

  $ possum -p 'word -> ("a" + Rest) & word -> (Rest + "!")' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call word)
        %0 = scrutinee
        (arm
          (solve_merge %0
            "a"
            (bind Rest~0))))
      (match
        scrutinee: (call word)
        %0 = scrutinee
        (arm
          (solve_merge %0
            (read Rest~0)
            "!"))))

Function calls in patterns are evaluated, not solved: callees resolve as
globals and their arguments read bound slots.

  $ possum -p 'Inc(X) = X + 1
  > main = int -> N & int -> Inc(N)' -i ''
  Inc(X) =
    (merge X~0 1)
  
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
          (eval_eq %0 (call Inc [N~0])))))
  

A lambda captures the locals it reads from its parent chain; a captured
name occupies one of the lambda's first slots and reads as bound, even
in pattern position.

  $ possum -p 'int -> N & maybe("," > int -> N)' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 N~0)))
      (call maybe [
        (lambda @fn0 captures=[N]
          (match
            scrutinee: (seq result=1
              (call ",")
              (call int))
            %0 = scrutinee
            (arm
              (eq_slot %0 N~0))))
      ]))

Captures relay through intermediate lambdas: an inner read adds the
capture to every lambda between the owner and the reader.

  $ possum -p 'int -> N & maybe(maybe("," > int -> N))' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 N~0)))
      (call maybe [
        (lambda @fn0 captures=[N]
          (call maybe [
            (lambda @fn1 captures=[N]
              (match
                scrutinee: (seq result=1
                  (call ",")
                  (call int))
                %0 = scrutinee
                (arm
                  (eq_slot %0 N~0))))
          ]))
      ]))

A value repeat's count is both the loop cap and the exact-count test;
both read the bound slot.

  $ possum -p 'int -> N $ ("ab" * N)' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 N~0)))
      (repeat
        body: "ab"
        cap: N~0
        count: (set
          %0 = scrutinee
          (eval_eq %0 N~0))))
