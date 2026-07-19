Constraint scheduling on the goal ast. Classification runs through a
worklist fixpoint: the earliest ready constraint is classified first,
where ready means the constraint can solve for at most one unknown part
and no eval read of an unbound slot another pending constraint could
still bind. Binder selection is an output of readiness, not textual
first sight. Constraint lists print in scheduled order.

Goal binding is the reporter: a pattern the fixpoint cannot order prints
its bound goal and then fails compilation with an `UnboundVariable`
error. Patterns the fixpoint can order compile and run. Goal regions
point at the whole constraint since parts carry no regions.

  $ export PRINT_GOAL_AST=bound RUN_VM=false

Two rests with both vars unbound are underdetermined: for `[1, 2, 3]`
there are multiple valid assignments of A and B. The merge can never
become ready, the textual fallback classifies it, and the
one-unbound-part rule rejects it.

  $ possum -p 'input -> [...A, ...B] $ [A, B]' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call input)
        %0 = scrutinee
        (arm
          (solve_merge %0 ty=array solvable=1
            (set
              %0 = scrutinee
              (is_type %0 array)
              (len_eq %0 0))
            (bind A~0)
            (bind B~1))))
      (array [
        A~0
        B~1
      ]))
  
  Program Error: variable 'B' is unbound here: a pattern can solve at most one unbound part
  
  program:1:9-21:
  1 \xe2\x96\x8f input -> [...A, ...B] $ [A, B] (esc)
    \xe2\x96\x8f          ^^^^^^^^^^^^ (esc)
  
  [UnboundVariable]
  [1]




The same merge inside a larger pattern is decidable: element 1 binds B,
which leaves element 0's merge with one unknown. The merge delays until
B arrives — the schedule places element 1's constraint first and B
becomes a read in the merge, with A the solvable part. The pattern
compiles and runs.

  $ possum -p 'input -> [[...A, ...B], [...B]] $ [A, B]' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call input)
        %0 = scrutinee
        %1 = elem %0 0
        %2 = elem %0 1
        %3 = slice %2 0 0
        (arm
          (is_type %0 array)
          (len_eq %0 2)
          (is_type %2 array)
          (len_min %2 0)
          (bind %3 B~1)
          (solve_merge %1 ty=array solvable=1
            (set
              %0 = scrutinee
              (is_type %0 array)
              (len_eq %0 0))
            (bind A~0)
            (read B~1))))
      (array [
        A~0
        B~1
      ]))




An eval that reads a slot another constraint can bind delays until the
binder has run: the eval_eq schedules after the bind even though it
appears first, so the whole program is accepted.

  $ possum -p 'Inc(N) = N + 1 ; main = input -> [Inc(A), A] $ A' -i ''
  Inc(N) =
    (merge N~0 1)
  
  main =
    (seq result=1
      (match
        scrutinee: (call input)
        %0 = scrutinee
        %1 = elem %0 0
        %2 = elem %0 1
        (arm
          (is_type %0 array)
          (len_eq %0 2)
          (bind %2 A~0)
          (eval_eq %1 (call Inc [A~0]))))
      A~0)
  


A genuine cycle — each merge's eval needs the other merge's binder —
can never become ready. Nothing is ready, so the fixpoint falls back to
source order and the program compiles (and fails at runtime when the
solver evaluates Inc with B unbound). Reporting cycles as compile errors
from the stuck set is future work.

  $ possum -p 'Inc(N) = N + 1 ; main = input -> [("a" + A + Inc(B)), ("b" + B + Inc(A))] $ [A, B]' -i ''
  Inc(N) =
    (merge N~0 1)
  
  main =
    (seq result=1
      (match
        scrutinee: (call input)
        %0 = scrutinee
        %1 = elem %0 0
        %2 = elem %0 1
        (arm
          (is_type %0 array)
          (len_eq %0 2)
          (solve_merge %1 ty=string solvable=1
            "a"
            (bind A~0)
            (call Inc [B~1]))
          (solve_merge %2 ty=string
            "b"
            (read B~1)
            (call Inc [A~0]))))
      (array [
        A~0
        B~1
      ]))
  
  [UnsupportedPattern]
  [1]


A variable both merges could bind is not a cycle: whichever schedules
first binds, the other reads, and source order breaks the tie. The
result is identical either way because valid patterns have at most one
solution.

  $ possum -p 'input -> [[...A], [...A]] $ A' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call input)
        %0 = scrutinee
        %1 = elem %0 0
        %2 = slice %1 0 0
        %3 = elem %0 1
        %4 = slice %3 0 0
        (arm
          (is_type %0 array)
          (len_eq %0 2)
          (is_type %1 array)
          (len_min %1 0)
          (bind %2 A~0)
          (is_type %3 array)
          (len_min %3 0)
          (eq_slot %4 A~0)))
      A~0)

A chain of dependent merges schedules back to front: `[...C]` binds C,
unlocking B's merge, unlocking A's.

  $ possum -p 'input -> [[...A, ...B], [...B, ...C], [...C]] $ [A, B, C]' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call input)
        %0 = scrutinee
        %1 = elem %0 0
        %2 = elem %0 1
        %3 = elem %0 2
        %4 = slice %3 0 0
        (arm
          (is_type %0 array)
          (len_eq %0 3)
          (is_type %3 array)
          (len_min %3 0)
          (bind %4 C~2)
          (solve_merge %2 ty=array solvable=1
            (set
              %0 = scrutinee
              (is_type %0 array)
              (len_eq %0 0))
            (bind B~1)
            (read C~2))
          (solve_merge %1 ty=array solvable=1
            (set
              %0 = scrutinee
              (is_type %0 array)
              (len_eq %0 0))
            (bind A~0)
            (read B~1))))
      (array [
        A~0
        B~1
        C~2
      ]))




A merge repeating the same unbound variable has two unknown parts even
though there is one unknown: it cannot be solved by subtraction. The
solvable-part count judges parts before classification, so both count.

  $ possum -p 'input -> ("x" + A + A) $ A' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call input)
        %0 = scrutinee
        (arm
          (solve_merge %0 ty=string solvable=1
            "x"
            (bind A~0)
            (read A~0))))
      A~0)
  
  Program Error: variable 'A' is unbound here: a pattern can solve at most one unbound part
  
  program:1:9-22:
  1 \xe2\x96\x8f input -> ("x" + A + A) $ A (esc)
    \xe2\x96\x8f          ^^^^^^^^^^^^^ (esc)
  
  [UnboundVariable]
  [1]



