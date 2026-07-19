Full created-stage goal form of stdlib/const.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/const.possum -i '' --no-stdlib
  true(t) =
    (seq result=1
      (call t~0)
      true)
  
  false(f) =
    (seq result=1
      (call f~0)
      false)
  
  boolean(t, f) =
    (alt
      (arm
        guard: (call true [t~0]))
      (arm
        body: (call false [f~1])))
  
  bool =
    (call boolean)
  
  null(n) =
    (seq result=1
      (call n~0)
      null)
  
