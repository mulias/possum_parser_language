  $ possum -p "foo(a,b,c) = 'foo' ; foo(1 2 3)" -i "foo"
  
  Error Reading Program
  
  ~~~(##)'>  I ran into a syntax issue in your program.
  
  The issue starts on line 1, character 28:
  foo(a,b,c) = 'foo' ; foo(1 2 3)
                             ^
  
  Eventually there will be a more helpful error message here, but in the meantime
  here's the parsing steps leading up to the failure:
  main_parser
  parser_steps
  step
  parser_apply
  parser_apply_args
  
  The last step did not succeed and there were no other options.
  [123]


  $ possum -p "1 2" -i "1 2"
  Expected one main parser, found a second one at line 1, characters 3-3:
  1 2
    ^
  [123]


  $ possum -p "1 && 2" -i "1 2"
  
  Error Reading Program
  
  ~~~(##)'>  I ran into a syntax issue in your program.
  
  The issue starts on line 1, character 4:
  1 && 2
     ^
  
  Eventually there will be a more helpful error message here, but in the meantime
  here's the parsing steps leading up to the failure:
  main_parser
  parser_steps
  infix_steps
  infix
  step
  id_or_ignored_id
  
  The last step did not succeed and there were no other options.
  [123]


  $ possum -p "(123" -i "123"
  
  Error Reading Program
  
  ~~~(##)'>  I ran into a syntax issue in your program.
  
  The issue starts on line 1, character 5:
  (123
      ^
  
  Eventually there will be a more helpful error message here, but in the meantime
  here's the parsing steps leading up to the failure:
  main_parser
  parser_steps
  step
  group
  
  The last step did not succeed and there were no other options.
  [123]


  $ possum -p "'' $ [1, 2" -i "foo bar"
  
  Error Reading Program
  
  ~~~(##)'>  I ran into a syntax issue in your program.
  
  The issue starts on line 1, character 11:
  '' $ [1, 2
            ^
  
  Eventually there will be a more helpful error message here, but in the meantime
  here's the parsing steps leading up to the failure:
  main_parser
  parser_steps
  infix_steps
  infix
  step
  value_like
  value_like_array
  
  The last step did not succeed and there were no other options.
  [123]
