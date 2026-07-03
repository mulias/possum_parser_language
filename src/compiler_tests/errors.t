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

  $ possum -p 'foo(a, a) = a ; foo("x", "y")' -i 'x'
  
  Validation Error: Duplicate parameter 'a'
  
  program:1:7-8:
  1 \xe2\x96\x8f foo(a, a) = a ; foo("x", "y") (esc)
    \xe2\x96\x8f        ^ (esc)
  
  [DuplicateParameterName]
  [1]

  $ possum -p 'foo = "a" ; foo = "b" ; foo' -i 'b'
  
  Validation Error: 'foo' is already declared in this module
  
  program:1:12-15:
  1 \xe2\x96\x8f foo = "a" ; foo = "b" ; foo (esc)
    \xe2\x96\x8f             ^^^ (esc)
  
  [DuplicateDeclaration]
  [1]
