Created-stage goal IR for the surface operators. Sequencing subsumes `&`,
`>`, `<`, and `$` as a seq with a result index; `|` and `?:` both lower to
one flat alt whose guard/body split encodes the commit point.

  $ export PRINT_GOAL_AST=true RUN_VM=false

take_right keeps the last result, take_left the first.

  $ possum -p '"a" > "b" > "c"' -i ''
  main =
    (seq result=1
      (seq result=1
        (call "a")
        (call "b"))
      (call "c"))

  $ possum -p '"a" < "b"' -i ''
  main =
    (seq result=0
      (call "a")
      (call "b"))

  $ possum -p '"a" & "b" & "c"' -i ''
  main =
    (seq result=1
      (seq result=1
        (call "a")
        (call "b"))
      (call "c"))

  $ possum -p '"a" $ 1' -i ''
  main =
    (seq result=1
      (call "a")
      1)

Merge and negation.

  $ possum -p '"a" + "b"' -i ''
  main =
    (merge (call "a") (call "b"))

  $ possum -p '-int' -i ''
  main =
    (neg (call int))

Ordered choice flattens into one alt: guard-only arms, then a body-only
final arm. Guard failure tries the next arm.

  $ possum -p '"a" | "b" | "c"' -i ''
  main =
    (alt
      (arm
        guard: (call "a"))
      (arm
        guard: (call "b"))
      (arm
        body: (call "c")))

`?:` arms carry both guard and body: the condition commits to the branch.

  $ possum -p '"a" ? "b" : "c"' -i ''
  main =
    (alt
      (arm
        guard: (call "a")
        body: (call "b"))
      (arm
        body: (call "c")))

The operator decides where the guard/body split lands. `(a & b) | c`
backtracks out of the whole guard; `a ? b : c` commits after `a`.

  $ possum -p '("a" & "b") | "c"' -i ''
  main =
    (alt
      (arm
        guard: (seq result=1
          (call "a")
          (call "b")))
      (arm
        body: (call "c")))

Nested alts in final-arm position splice into the parent; no pass sees a
right-nested chain.

  $ possum -p '"a" ? "b" : "c" ? "d" : "e"' -i ''
  main =
    (alt
      (arm
        guard: (call "a")
        body: (call "b"))
      (arm
        guard: (call "c")
        body: (call "d"))
      (arm
        body: (call "e")))

  $ possum -p '"a" | ("b" ? "c" : "d")' -i ''
  main =
    (alt
      (arm
        guard: (call "a"))
      (arm
        guard: (call "b")
        body: (call "c"))
      (arm
        body: (call "d")))
