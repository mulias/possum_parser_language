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

  $ possum -p '@main = 3 ; @main' -i ''
  
  Validation Error: Unable to declare '@main', '@' is reserved for builtins
  
  program:1:0-5:
  1 \xe2\x96\x8f @main = 3 ; @main (esc)
    \xe2\x96\x8f ^^^^^ (esc)
  
  [ReservedBuiltinName]
  [1]

  $ possum -p '@main' -i ''
  
  Program Error: undefined variable '@main'
  
  program:1:0-5:
  1 \xe2\x96\x8f @main (esc)
    \xe2\x96\x8f ^^^^^ (esc)
  
  [UndefinedVariable]
  [1]

  $ possum -p '@my_parser = 99 ; @my_parser' -i '99'
  
  Validation Error: Unable to declare '@my_parser', '@' is reserved for builtins
  
  program:1:0-10:
  1 \xe2\x96\x8f @my_parser = 99 ; @my_parser (esc)
    \xe2\x96\x8f ^^^^^^^^^^ (esc)
  
  [ReservedBuiltinName]
  [1]

  $ possum -p 'foo(@a) = @a ; foo' -i ''
  
  Validation Error: Invalid function param, '@' is reserved for builtins
  
  program:1:4-6:
  1 \xe2\x96\x8f foo(@a) = @a ; foo (esc)
    \xe2\x96\x8f     ^^ (esc)
  
  [ReservedBuiltinName]
  [1]

  $ possum -p '@my_parser' -i ''
  
  Program Error: undefined variable '@my_parser'
  
  program:1:0-10:
  1 \xe2\x96\x8f @my_parser (esc)
    \xe2\x96\x8f ^^^^^^^^^^ (esc)
  
  [UndefinedVariable]
  [1]

  $ possum -p 'foo(a) = a ; foo("x")("y")' -i 'xy'
  
  Program Error: Only named functions can be called
  
  program:1:13-21:
  1 \xe2\x96\x8f foo(a) = a ; foo("x")("y") (esc)
    \xe2\x96\x8f              ^^^^^^^^ (esc)
  
  [InvalidAst]
  [1]

  $ possum -p 'Foo(A) = A ; "" $ Foo(1)(2)' -i ''
  
  Program Error: Only named functions can be called
  
  program:1:18-24:
  1 \xe2\x96\x8f Foo(A) = A ; "" $ Foo(1)(2) (esc)
    \xe2\x96\x8f                   ^^^^^^ (esc)
  
  [InvalidAst]
  [1]

Underscored stdlib names are private to the stdlib module:

  $ possum -p '_number_integer_part' -i '5'
  
  Program Error: undefined variable '_number_integer_part'
  
  program:1:0-20:
  1 \xe2\x96\x8f _number_integer_part (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [UndefinedVariable]
  [1]

Underscored names are usable within their own module:

  $ possum -p '_five = "5" ; _five' -i '5'
  "5"
