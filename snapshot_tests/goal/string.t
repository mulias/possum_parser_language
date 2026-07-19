String templates desugar to merge chains of literal segments and
to_string-wrapped interpolations; there is no template goal node. Pattern
templates stay match_template constraints (see pattern.t).

  $ export PRINT_GOAL_AST=true RUN_VM=false

A parser template runs its interpolations as parsers.

  $ possum -p '"hi %(word)"' -i ''
  main =
    (merge (call "hi ") (to_string (call word)))

A single-interpolation template is just the stringified interpolation.

  $ possum -p '"%(digit)"' -i ''
  main =
    (to_string (call digit))

A value template stringifies value reads.

  $ possum -p 'word -> W $ "hi %(W)"' -i ''
  main =
    (seq result=1
      (match
        scrutinee: (call word)
        %0 = scrutinee
        (arm
          (local %0 W)))
      (merge "hi " (to_string W)))
