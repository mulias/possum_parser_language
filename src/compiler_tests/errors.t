  $ export RUN_VM=false

  $ possum -p 'foo(A) = "" $ A ; foo("a")' -i ''
  
  Program Error: Expected value but got parser
  
  program:1:22-25:
  1 \xe2\x96\x8f foo(A) = "" $ A ; foo("a") (esc)
    \xe2\x96\x8f                       ^^^ (esc)
  
  [FunctionCallTypeMismatch]
  [1]

  $ possum -p 'foo(a) = a ; foo([])' -i ''
  
  Program Error: Expected parser but got value
  
  program:1:17-20:
  1 \xe2\x96\x8f foo(a) = a ; foo([]) (esc)
    \xe2\x96\x8f                  ^^^ (esc)
  
  [FunctionCallTypeMismatch]
  [1]
