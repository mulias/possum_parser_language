Full created-stage goal form of stdlib/combinator.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/combinator.possum -i '' --no-stdlib
  many(p) =
    (repeat
      body: (call p~0)
      count: (set
        %0 = scrutinee
        (in_range %0 1 _)))
  
  many_sep(p, sep) =
    (merge
      (call p~0)
      (repeat
        body: (seq result=1
          (call sep~1)
          (call p~0))
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  many_until(p, stop) =
    (seq result=0
      (repeat
        body: (call unless [p~0 stop~1])
        count: (set
          %0 = scrutinee
          (in_range %0 1 _)))
      (call peek [stop~1]))
  
  maybe_many(p) =
    (repeat
      body: (call p~0)
      count: (set
        %0 = scrutinee
        (in_range %0 0 _)))
  
  maybe_many_sep(p, sep) =
    (alt
      (arm
        guard: (call many_sep [p~0 sep~1]))
      (arm
        body: (call succeed)))
  
  peek(p) =
    (seq result=1
      (match
        scrutinee: (call @input.offset)
        %0 = scrutinee
        (arm
          (bind %0 Pos~1)))
      (call @at [Pos~1 p~0]))
  
  maybe(p) =
    (alt
      (arm
        guard: (call p~0))
      (arm
        body: (call succeed)))
  
  unless(p, excluded) =
    (alt
      (arm
        guard: (call excluded~1)
        body: (call @fail))
      (arm
        body: (call p~0)))
  
  skip(p) =
    (call null [p~0])
  
  find(p) =
    (alt
      (arm
        guard: (call p~0))
      (arm
        body: (seq result=1
          (call char)
          (call find [p~0]))))
  
  find_all(p) =
    (seq result=0
      (call _@import0 [
        (lambda @fn0 captures=[p]
          (call find [p~0]))
      ])
      (call maybe [
        (lambda @fn1
          (call many [char]))
      ]))
  
  find_before(p, stop) =
    (alt
      (arm
        guard: (call stop~1)
        body: (call @fail))
      (arm
        guard: (call p~0))
      (arm
        body: (seq result=1
          (call char)
          (call find_before [p~0 stop~1]))))
  
  find_all_before(p, stop) =
    (seq result=0
      (call _@import1 [
        (lambda @fn2 captures=[p stop]
          (call find_before [p~0 stop~1]))
      ])
      (call maybe [
        (lambda @fn3 captures=[stop]
          (call chars_until [stop~0]))
      ]))
  
  succeed =
    (call const [null])
  
  default(p, D) =
    (alt
      (arm
        guard: (call p~0))
      (arm
        body: (call const [D~1])))
  
  const(C) =
    (seq result=1
      (call "")
      C~0)
  
  as_number(p) =
    (seq result=1
      (match
        scrutinee: (call p~0)
        %0 = scrutinee
        (arm
          (match_template %0
            (set
              %0 = scrutinee
              (solve_merge %0
                0
                (bind N~1))))))
      N~1)
  
  as_string(p) =
    (to_string (call p~0))
  
  surround(p, fill) =
    (seq result=0
      (seq result=1
        (call fill~1)
        (call p~0))
      (call fill~1))
  
  end_of_input =
    (alt
      (arm
        guard: (call char)
        body: (call @fail))
      (arm
        body: (call succeed)))
  
  end =
    (call end_of_input)
  
  input(p) =
    (seq result=0
      (call surround [
        p~0
        (lambda @fn4
          (call maybe [whitespace]))
      ])
      (call end_of_input))
  
  one_or_both(a, b) =
    (alt
      (arm
        guard: (merge (call a~0) (call maybe [b~1])))
      (arm
        body: (merge (call maybe [a~0]) (call b~1))))
  
