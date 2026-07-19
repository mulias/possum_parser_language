Full created-stage goal form of stdlib/combinator.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/combinator.possum -i '' --no-stdlib
  many(p) =
    (repeat
      body: (call p)
      count: (set
        %0 = scrutinee
        (in_range %0 1 _)))
  
  many_sep(p, sep) =
    (merge
      (call p)
      (repeat
        body: (seq result=1
          (call sep)
          (call p))
        count: (set
          %0 = scrutinee
          (in_range %0 0 _))))
  
  many_until(p, stop) =
    (seq result=0
      (repeat
        body: (call unless [p stop])
        count: (set
          %0 = scrutinee
          (in_range %0 1 _)))
      (call peek [stop]))
  
  maybe_many(p) =
    (repeat
      body: (call p)
      count: (set
        %0 = scrutinee
        (in_range %0 0 _)))
  
  maybe_many_sep(p, sep) =
    (alt
      (arm
        guard: (call many_sep [p sep]))
      (arm
        body: (call succeed)))
  
  peek(p) =
    (seq result=1
      (match
        scrutinee: (call @input.offset)
        %0 = scrutinee
        (arm
          (local %0 Pos)))
      (call @at [Pos p]))
  
  maybe(p) =
    (alt
      (arm
        guard: (call p))
      (arm
        body: (call succeed)))
  
  unless(p, excluded) =
    (alt
      (arm
        guard: (call excluded)
        body: (call @fail))
      (arm
        body: (call p)))
  
  skip(p) =
    (call null [p])
  
  find(p) =
    (alt
      (arm
        guard: (call p))
      (arm
        body: (seq result=1
          (call char)
          (call find [p]))))
  
  find_all(p) =
    (seq result=0
      (call _@import0 [
        (lambda @fn0
          (call find [p]))
      ])
      (call maybe [
        (lambda @fn1
          (call many [char]))
      ]))
  
  find_before(p, stop) =
    (alt
      (arm
        guard: (call stop)
        body: (call @fail))
      (arm
        guard: (call p))
      (arm
        body: (seq result=1
          (call char)
          (call find_before [p stop]))))
  
  find_all_before(p, stop) =
    (seq result=0
      (call _@import1 [
        (lambda @fn2
          (call find_before [p stop]))
      ])
      (call maybe [
        (lambda @fn3
          (call chars_until [stop]))
      ]))
  
  succeed =
    (call const [null])
  
  default(p, D) =
    (alt
      (arm
        guard: (call p))
      (arm
        body: (call const [D])))
  
  const(C) =
    (seq result=1
      (call "")
      C)
  
  as_number(p) =
    (seq result=1
      (match
        scrutinee: (call p)
        %0 = scrutinee
        (arm
          (match_template %0
            (set
              %0 = scrutinee
              (solve_merge %0
                0
                (local N))))))
      N)
  
  as_string(p) =
    (to_string (call p))
  
  surround(p, fill) =
    (seq result=0
      (seq result=1
        (call fill)
        (call p))
      (call fill))
  
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
        p
        (lambda @fn4
          (call maybe [whitespace]))
      ])
      (call end_of_input))
  
  one_or_both(a, b) =
    (alt
      (arm
        guard: (merge (call a) (call maybe [b])))
      (arm
        body: (merge (call maybe [a]) (call b))))
  
