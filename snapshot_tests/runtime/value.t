  $ possum -p 'const({"a" + "b": 1})' -i ''
  {"ab": 1}

  $ possum -p 'const({"ab":2, "a" + "b": 1})' -i ''
  {"ab": 1}

  $ possum -p 'const({"a" + "b": 1, "ab":2})' -i ''
  {"ab": 2}

  $ possum -p 'const({"a": 1 + 3, "ab": 2})' -i ''
  {"a": 4, "ab": 2}

  $ possum -p 'Foo(K) = {K: 1, "b": 2, "a": 3} ; "" $ Foo("a")' -i ''
  {"b": 2, "a": 3}


A null argument to a numeric builtin is the identity where one exists:
the other argument passes through unchanged, and all-null arguments
return null.

  $ possum -p '"x" $ @Add(5, null)' -i 'x'
  5

  $ possum -p '"x" $ @Add(null, 5)' -i 'x'
  5

  $ possum -p '"x" $ @Add(null, null)' -i 'x'
  null

  $ possum -p '"x" $ @Multiply(null, 5)' -i 'x'
  5

  $ possum -p '"x" $ @Subtract(5, null)' -i 'x'
  5

  $ possum -p '"x" $ @Subtract(null, null)' -i 'x'
  null

  $ possum -p '"x" $ @Divide(5, null)' -i 'x'
  5

  $ possum -p '"x" $ @Power(2, null)' -i 'x'
  2

  $ possum -p '"x" $ @Floor(null)' -i 'x'
  null

  $ possum -p '"x" $ @Ceiling(null)' -i 'x'
  null

A failed argument makes the call fail before null handling.

  $ possum -p '"x" $ (@Add(@Fail, 5) | 99)' -i 'x'
  99

Null in a non-identity position is a runtime error.

  $ possum -p '"x" $ @Subtract(null, 5)' -i 'x'
  
  Runtime Error: @Subtract cannot subtract from null
  
  
  program:1:6-24:
  
  1 \xe2\x96\x8f "x" $ @Subtract(null, 5) (esc)
    \xe2\x96\x8f       ^^^^^^^^^^^^^^^^^^ (esc)
  
  [RuntimeError]
  [1]

  $ possum -p '"x" $ @Divide(null, 4)' -i 'x'
  
  Runtime Error: @Divide cannot divide null
  
  
  program:1:6-22:
  
  1 \xe2\x96\x8f "x" $ @Divide(null, 4) (esc)
    \xe2\x96\x8f       ^^^^^^^^^^^^^^^^ (esc)
  
  [RuntimeError]
  [1]

  $ possum -p '"x" $ @Power(null, 2)' -i 'x'
  
  Runtime Error: @Power cannot raise null to a power
  
  
  program:1:6-21:
  
  1 \xe2\x96\x8f "x" $ @Power(null, 2) (esc)
    \xe2\x96\x8f       ^^^^^^^^^^^^^^^ (esc)
  
  [RuntimeError]
  [1]

  $ possum -p '"x" $ @Modulus(5, null)' -i 'x'
  
  Runtime Error: @Modulus arguments cannot be null
  
  
  program:1:6-23:
  
  1 \xe2\x96\x8f "x" $ @Modulus(5, null) (esc)
    \xe2\x96\x8f       ^^^^^^^^^^^^^^^^^ (esc)
  
  [RuntimeError]
  [1]
