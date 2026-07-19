Full created-stage goal form of stdlib/const.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/const.possum -i '' --no-stdlib
  true(t) =
    (seq result=1
      (call t)
      true)
  
  false(f) =
    (seq result=1
      (call f)
      false)
  
  boolean(t, f) =
    (alt
      (arm
        guard: (call true [t]))
      (arm
        body: (call false [f])))
  
  bool =
    (call boolean)
  
  null(n) =
    (seq result=1
      (call n)
      null)
  
