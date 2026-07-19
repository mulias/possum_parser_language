Pattern decomposition: a destructure lowers to a match whose arm is a flat
constraint set over interned places (%0 is the scrutinee).

  $ export PRINT_GOAL_AST=true RUN_VM=false

Literals test by constant equality; variables are neutral local
occurrences until binding analysis classifies them; `_` constrains
nothing.

  $ possum -p 'int -> 5' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (eq_const %0 5)))

  $ possum -p 'int -> N' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (bind %0 N~0)))

  $ possum -p 'int -> _' -i ''
  main =
    (call int)

Arrays decompose into shape tests plus element places.

  $ possum -p 'array(int) -> [1, A, _]' -i ''
  main =
    (match
      scrutinee: (call array [int])
      %0 = scrutinee
      %1 = elem %0 0
      %2 = elem %0 1
      (arm
        (is_type %0 array)
        (len_eq %0 3)
        (eq_const %1 1)
        (bind %2 A~0)))

  $ possum -p 'array(int) -> [[A], [B]]' -i ''
  main =
    (match
      scrutinee: (call array [int])
      %0 = scrutinee
      %1 = elem %0 0
      %2 = elem %1 0
      %3 = elem %0 1
      %4 = elem %3 0
      (arm
        (is_type %0 array)
        (len_eq %0 2)
        (is_type %1 array)
        (len_eq %1 1)
        (bind %2 A~0)
        (is_type %3 array)
        (len_eq %3 1)
        (bind %4 B~1)))

Array rests arrive from can as merge chains: solve_merge over sub-pattern
parts, each rooted at its own portion of the value.

  $ possum -p 'array(int) -> [First, ...Rest]' -i ''
  main =
    (match
      scrutinee: (call array [int])
      %0 = scrutinee
      %1 = elem %0 0
      %2 = slice %0 1 0
      (arm
        (is_type %0 array)
        (len_min %0 1)
        (bind %1 First~0)
        (bind %2 Rest~1)))

  $ possum -p 'array(int) -> [...Front, Last]' -i ''
  main =
    (match
      scrutinee: (call array [int])
      %0 = scrutinee
      %1 = slice %0 0 1
      %2 = elem_back %0 0
      (arm
        (is_type %0 array)
        (len_min %0 1)
        (bind %1 Front~0)
        (bind %2 Last~1)))

  $ possum -p 'array(int) -> [F, ...Mid, L]' -i ''
  main =
    (match
      scrutinee: (call array [int])
      %0 = scrutinee
      %1 = elem %0 0
      %2 = slice %0 1 1
      %3 = elem_back %0 0
      (arm
        (is_type %0 array)
        (len_min %0 2)
        (bind %1 F~0)
        (bind %2 Mid~1)
        (bind %3 L~2)))

Objects: constant keys become has_key tests plus key places; a computed
key searches the unmatched members with nested key/value constraint sets.

  $ possum -p 'object(word, int) -> {"a": A, W: 2}' -i ''
  main =
    (match
      scrutinee: (call object [word int])
      %0 = scrutinee
      %1 = key %0 "a"
      (arm
        (is_type %0 object)
        (keys_exact %0 2)
        (has_key %0 "a")
        (bind %1 A~0)
        (search_key %0
          key: (set
            %0 = scrutinee
            (bind %0 W~1))
          value: (set
            %0 = scrutinee
            (eq_const %0 2)))))

  $ possum -p 'object(word, int) -> {"a": 1, ...Rest}' -i ''
  main =
    (match
      scrutinee: (call object [word int])
      %0 = scrutinee
      %1 = key %0 "a"
      %2 = members_rest %0
      (arm
        (is_type %0 object)
        (keys_min %0 1)
        (has_key %0 "a")
        (eq_const %1 1)
        (bind %2 Rest~0)))

An object merge with a repeat part becomes a claim_members over the chunk
sub-pattern and count factors, with the leftover members at a members_rest.

  $ possum -p 'object(word, int) -> {...({_: _} * 2), ...Rest}' -i ''
  main =
    (match
      scrutinee: (call object [word int])
      %0 = scrutinee
      %1 = members_rest %0
      (arm
        (is_type %0 object)
        (claim_members %0
          pattern: (set
            %0 = scrutinee
            (is_type %0 object)
            (keys_exact %0 1)
            (search_key %0
              key: (set
                %0 = scrutinee)
              value: (set
                %0 = scrutinee)))
          count: 2)
        (bind %1 Rest~0)))

A repeated variable is two local occurrences of the same name; binding
analysis later classifies binder vs read.

  $ possum -p 'int -> A & int -> A' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 A~0)))
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (eq_slot %0 A~0))))

Pattern function calls evaluate and compare in place: eval_eq, no place
defined.

  $ cat > inc.possum <<'EOF'
  > Inc(N) = N + 1
  > main = int -> A & int -> Inc(A)
  > EOF
  $ possum inc.possum -i ''
  Inc(N) =
    (merge N~0 1)
  
  main =
    (seq result=1
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (bind %0 A~0)))
      (match
        scrutinee: (call int)
        %0 = scrutinee
        (arm
          (eval_eq %0 (call Inc [A~0])))))
  



Numeric negation wraps the inner part with a count.

  $ possum -p 'int -> -N' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (negated %0 1 (bind N~0))))

  $ possum -p 'int -> --N' -i ''
  main =
    (match
      scrutinee: (call int)
      %0 = scrutinee
      (arm
        (negated %0 2 (bind N~0))))

String template patterns keep their segments as a match_template
constraint.

  $ possum -p 'word -> "a%(Mid)z"' -i ''
  main =
    (match
      scrutinee: (call word)
      %0 = scrutinee
      (arm
        (match_template %0
          "a"
          (bind Mid~0)
          "z")))

Pattern repeats become solve_repeat over pattern and count parts.

  $ possum -p 'word -> ("ab" * N)' -i ''
  main =
    (match
      scrutinee: (call word)
      %0 = scrutinee
      (arm
        (solve_repeat %0 solvable=0
          pattern: "ab"
          count: (bind N~0))))

Value-context destructure is the same match node.

  $ possum -p '"" $ (1 -> N)' -i ''
  main =
    (seq result=1
      (call "")
      (match
        scrutinee: 1
        %0 = scrutinee
        (arm
          (bind %0 N~0))))

Merge parts type the merge at creation: the first structurally typed part
names it, and a later part with a conflicting static type is an error
reported against that part.

  $ possum -p 'json -> ([1] + "a" + R) $ R' -i ''
  
  Validation Error: cannot merge a string into an array merge
  
  program:1:15-18:
  1 \xe2\x96\x8f json -> ([1] + "a" + R) $ R (esc)
    \xe2\x96\x8f                ^^^ (esc)
  
  [MergeTypeConflict]
  [1]

  $ possum -p 'json -> (1 + [2] + R) $ R' -i ''
  
  Validation Error: cannot merge an array into a number merge
  
  program:1:13-16:
  1 \xe2\x96\x8f json -> (1 + [2] + R) $ R (esc)
    \xe2\x96\x8f              ^^^ (esc)
  
  [MergeTypeConflict]
  [1]

Ranges type as number for conflict purposes: constant number ranges fold
by interval arithmetic, and a surviving range part is invalid in every
merge type.

  $ possum -p 'json -> ("a" + 1..2) $ "ok"' -i ''
  
  Validation Error: cannot merge a number into a string merge
  
  program:1:15-19:
  1 \xe2\x96\x8f json -> ("a" + 1..2) $ "ok" (esc)
    \xe2\x96\x8f                ^^^^ (esc)
  
  [MergeTypeConflict]
  [1]

Parts without a static type stay legal in any merge; their values type
the merge at match time.

  $ possum -p 'const([1,2]) -> (Head + [2]) $ Head' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call const [
          (array [
            1
            2
          ])
        ])
        %0 = scrutinee
        %1 = slice %0 0 1
        %2 = elem_back %0 0
        (arm
          (is_type %0 array)
          (len_min %0 1)
          (bind %1 Head~0)
          (eq_const %2 2)))
      Head~0)

String merges with a static byte layout flatten the same way: literal
parts become prefix/suffix byte tests and the one unknown-length part
takes the byte slice.

  $ possum -p 'word -> ("a" + Mid + "fg")' -i ''
  main =
    (match
      scrutinee: (call word)
      %0 = scrutinee
      %1 = slice %0 1 2
      (arm
        (is_type %0 string)
        (len_min %0 3)
        (str_prefix %0 "a")
        (str_suffix %0 "fg")
        (bind %1 Mid~0)))

Templates keep match_template in the IR: whether an interpolation binds
a substring or stringifies a bound value before comparing is only known
after binding analysis, so the backend decides the flattening.

  $ possum -p 'word -> "a%(Mid)fg"' -i ''
  main =
    (match
      scrutinee: (call word)
      %0 = scrutinee
      (arm
        (match_template %0
          "a"
          (bind Mid~0)
          "fg")))
