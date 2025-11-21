  $ possum -p '1 * @Add' -i '11111'
  
  Runtime Error: Invalid repeat pattern
  
  
  program:1:4-8:
  
  1 \xe2\x96\x8f 1 * @Add (esc)
    \xe2\x96\x8f     ^^^^ (esc)
  
  [RuntimeError]
  [1]

  $ possum -p 'foo(p) = p(1, 2) ; bar(a, B) = a $ B ; foo(bar)' -i ''
  
  Runtime Error: Function parameter types do not match expected types.
  
  
  program:1:9-16:
  
  1 \xe2\x96\x8f foo(p) = p(1, 2) ; bar(a, B) = a $ B ; foo(bar) (esc)
    \xe2\x96\x8f          ^^^^^^^ (esc)
  
  [RuntimeError]
  [1]

  $ possum -p 'foo(p) = p($1, []) ; bar(a, B) = a $ B ; foo(bar)' -i ''
  
  Runtime Error: Function parameter types do not match expected types.
  
  
  program:1:9-18:
  
  1 \xe2\x96\x8f foo(p) = p($1, []) ; bar(a, B) = a $ B ; foo(bar) (esc)
    \xe2\x96\x8f          ^^^^^^^^^ (esc)
  
  [RuntimeError]
  [1]

  $ possum -p 'foo(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29, A30, A31, A32) = "cool" ; 0' -i '0'
  
  Program Error: Can't have more than 31 parameters.
  
  program:1:150-153:
  1 \xe2\x96\x8f foo(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11, A12, A13, A14, A15, A16, A17, A18, A19, A20, A21, A22, A23, A24, A25, A26, A27, A28, A29, A30, A31, A32) = "cool" ; 0 (esc)
    \xe2\x96\x8f                                                                                                                                                       ^^^ (esc)
  
  [MaxFunctionLocals]
  [1]



