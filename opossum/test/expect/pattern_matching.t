  $ possum -p "
  > match(Pattern, A) = Pattern <- const(A) $ A ;
  > nonempty(p) =
  >   A <- p &
  >   true <- match('', A) | match([], A) | match({}, A) | const(true) $
  >   A ;
  > nonempty(array(digit))
  > " -i "123"
  [ 1, 2, 3 ]

  $ possum -p "X <- const(1) & X <- const(2) $ X" -i ''
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 1:
  
  ^
  
  The last attempted parser was:
  
  
  But no match was found.
  [123]
