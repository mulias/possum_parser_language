  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '1..(..90)' -i '1111'
  
  Program Error: Range bound must be an integer or codepoint
  
  program:1:3-9:
  1 \xe2\x96\x8f 1..(..90) (esc)
    \xe2\x96\x8f    ^^^^^^ (esc)
  
  [InvalidAst]
  [1]

Pattern lowering rejects some shapes as [UnsupportedPattern]. The cases below
document the current behavior next to the intended behavior.

  $ export PRINT_COMPILED_BYTECODE=false RUN_VM=true

A leading underscore designates a private/helper function; calling one in a
pattern should work like any other pattern call. Expected: 6.

  $ possum -p '_Inc(N) = N + 1 ; number -> _Inc(5)' -i '6'
  [UnsupportedPattern]
  [1]

Calling through an underscored local should behave like the non-underscored
equivalent, which checks function-ness at match time. Expected: the
[RuntimeError] the second case reports.

  $ possum -p 'json -> [_F, _F(1)]' -i '[1, 2]'
  [UnsupportedPattern]
  [1]

  $ possum -p 'json -> [F, F(1)]' -i '[1, 2]'
  [RuntimeError]
  [1]

Functions are valid call arguments and the VM evaluates pattern calls, so
pattern position should support what parser position already does.
Expected: 4.

  $ possum -p 'Double(F, N) = F(N) + F(N) ; Inc(N) = N + 1 ; "" $ Double(Inc, 1)' -i ''
  4

  $ possum -p 'Double(F, N) = F(N) + F(N) ; Inc(N) = N + 1 ; ("" $ 4) -> Double(Inc, 1)' -i ''
  [UnsupportedPattern]
  [1]

A placeholder range limit is the same as an absent one. Expected: 3, like
the unbounded case.

  $ possum -p 'number -> (..5)' -i '3'
  3

  $ possum -p 'number -> (_..5)' -i '3'
  [UnsupportedPattern]
  [1]

A negated range as a string-template segment matches the stringified number,
since templates check a stringified version of any json value. These work:

  $ possum -p '"-3" -> "%(-(1..5))"' -i '-3'
  "-3"

  $ possum -p '"a-3" -> "a%(-(1..5))"' -i 'a-3'
  "a-3"

A negated range repeat count works for numbers:

  $ possum -p 'number -> (2 * -(1..5))' -i '-4'
  -4

...and correctly rejects collections, where a negative repeat count cannot
match:

  $ possum -p 'json -> ("a" * -(1..2))' -i '"aa"'
  
  Parse Failure: value "aa" did not match pattern ("a" * -(1..2))
  
  input:1:4:
  
  1 \xe2\x96\x8f "aa" (esc)
    \xe2\x96\x8f     ^ (esc)
  
  expected one of:
    @fail (parser `unless`, stdlib/util.possum:8:33)
    ("a" * -(1..2)) (parser `@main`, program:1:8)
  [ParserFailure]
  [1]

...but a negated range count inside a merge part is not lowered yet.
Expected: 6, solving 6 = 2 * -2 + 10 with -2 in -(1..5).

  $ possum -p 'number -> (2 * -(1..5) + 10)' -i '6'
  [UnsupportedPattern]
  [1]

A bare function global in pattern position, a call to a non-function global,
and an arity mismatch with a constant callee are all knowable-at-compile-time
mistakes; each deserves a real diagnostic instead of [UnsupportedPattern].

  $ possum -p 'Inc(A) = A + 1 ; number -> Inc' -i '6'
  [UnsupportedPattern]
  [1]

  $ possum -p 'Two = 2 ; number -> Two(5)' -i '6'
  [UnsupportedPattern]
  [1]

  $ possum -p 'Inc(A) = A + 1 ; number -> Inc(1, 2)' -i '6'
  [UnsupportedPattern]
  [1]

A global as a range limit should fold like any other constant. Expected: 3.

  $ possum -p 'Two = 2 ; number -> (Two..5)' -i '3'
  [UnsupportedPattern]
  [1]

Call arguments only lower literals, bare locals, and zero-arity function
globals. A bound local works:

  $ possum -p 'Inc(A) = A + 1 ; json -> [N, Inc(N)]' -i '[1, 2]'
  [1, 2]

...but compound arguments the VM could evaluate do not. Expected: 3 and
[1, 3].

  $ possum -p 'Inc(A) = A + 1 ; number -> Inc(Inc(1))' -i '3'
  [UnsupportedPattern]
  [1]

  $ possum -p 'Inc(A) = A + 1 ; json -> [N, Inc(N + 1)]' -i '[1, 3]'
  [UnsupportedPattern]
  [1]

Non-solvable template segments only lower constants, bound locals, calls,
and ranges. Compound segments that fold or evaluate to a value do not.
Expected: [1, "x2y"] and "x[1]y".

  $ possum -p 'json -> [A, "x%(A + 1)y"]' -i '[1, "x2y"]'
  [UnsupportedPattern]
  [1]

  $ possum -p 'json -> "x%([1])y"' -i '"x[1]y"'
  [UnsupportedPattern]
  [1]

A bound repeat count in a merge part only lowers constants, bound locals,
and calls, not compound expressions of bound values. Expected: "x".

  $ possum -p 'json -> [N, ("a" * (N + 1) + R)] $ R' -i '[1, "aax"]'
  [UnsupportedPattern]
  [1]

A counted-structural repeat merge part is only supported for object
patterns, not strings or arrays. Expected: "x".

  $ possum -p 'Two = 2 ; json -> ("a" * Two + R) $ R' -i '"aax"'
  [UnsupportedPattern]
  [1]

A solvable repeat's count must be a bare unbound local; a compound count
would need inverse solving. Expected: 1, solving [1] * (C + 1) = [1, 1].

  $ possum -p 'json -> ([1] * (C + 1) + [9]) $ C' -i '[1,1,9]'
  [UnsupportedPattern]
  [1]

An unbound compound range limit would also need inverse solving.
Expected: 2, solving (A + 1) <= 3.

  $ possum -p 'number -> ((A + 1)..5) $ A' -i '3'
  [UnsupportedPattern]
  [1]
