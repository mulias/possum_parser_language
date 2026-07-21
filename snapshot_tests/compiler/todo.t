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

Calling through an underscored local should behave like the non-underscored
equivalent, which checks function-ness at match time. A value-cased local
callee keeps the plan path, so both still report at match time rather than
lowering to inline steps. Expected: the [RuntimeError] the second case
reports for the underscored case too.

$ possum -p 'json -> [_F, _F(1)]' -i '[1, 2]'

$ possum -p 'json -> [F, F(1)]' -i '[1, 2]'

  $ possum -p 'json -> ("a" * -(1..2))' -i '"aa"'
  
  Parse Failure: value "aa" did not match pattern ("a" * -(1..2))
  
  input:1:4:
  
  1 \xe2\x96\x8f "aa" (esc)
    \xe2\x96\x8f     ^ (esc)
  
  expected one of:
    @fail (parser `unless`, stdlib/combinator.possum:18:33)
    ("a" * -(1..2)) (parser `@main`, program:1:8)
  [ParserFailure]
  [1]

...but a negated range count inside a merge part is not lowered yet.
Expected: 6, solving 6 = 2 * -2 + 10 with -2 in -(1..5).

  $ possum -p 'number -> (2 * -(1..5) + 10)' -i '6'
  [UnsupportedPattern]
  [1]

A bare function global in pattern position is still lowered as
[UnsupportedPattern] and deserves a real diagnostic.

  $ possum -p 'Inc(A) = A + 1 ; number -> Inc' -i '6'
  [UnsupportedPattern]
  [1]

A call to a non-function global and an arity mismatch with a constant callee
are knowable at compile time; the step path reports both.

  $ possum -p 'Two = 2 ; number -> Two(5)' -i '6'
  
  Program Error: Only named functions can be called
  
  program:1:20-23:
  1 \xe2\x96\x8f Two = 2 ; number -> Two(5) (esc)
    \xe2\x96\x8f                     ^^^ (esc)
  
  [InvalidAst]
  [1]

  $ possum -p 'Inc(A) = A + 1 ; number -> Inc(1, 2)' -i '6'
  
  Program Error: Function 'Inc' expects 1 arguments but got 2
  
  program:1:27-36:
  1 \xe2\x96\x8f Inc(A) = A + 1 ; number -> Inc(1, 2) (esc)
    \xe2\x96\x8f                            ^^^^^^^^^ (esc)
  
  [FunctionCallTooManyArgs]
  [1]

Non-solvable template segments only lower constants, bound locals, calls,
and ranges. Compound segments that fold or evaluate to a value do not.
Expected: [1, "x2y"] and "x[1]y".

$ possum -p 'json -> [A, "x%(A + 1)y"]' -i '[1, "x2y"]'

$ possum -p 'json -> "x%([1])y"' -i '"x[1]y"'

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
  
  Runtime Error: Undefined variable 'A'.
  
  
  program:1:12-13:
  
  1 \xe2\x96\x8f number -> ((A + 1)..5) $ A (esc)
    \xe2\x96\x8f             ^ (esc)
  
  [RuntimeError]
  [1]

An unresolvable definition cycle through import expressions leaks the
synthesized alias name. Expected: a message naming 'foo' and the files
in the cycle, not '_@import0'.

  $ cat > cyc_a.possum <<'CYCA'
  > foo = !"cyc_b.possum".foo
  > CYCA
  $ cat > cyc_b.possum <<'CYCB'
  > foo = !"cyc_a.possum".foo
  > CYCB

  $ possum -p '!"cyc_a.possum".foo' -i ''
  
  Program Error: '_@import0' is not exported by the module imported as '_@import0'
  
  program:1:0-19:
  1 \xe2\x96\x8f !"cyc_a.possum".foo (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ImportResolution]
  [1]

Selecting a private member inline leaks the synthesized alias name the
same way. Expected: a message naming '_secret' and the module.

  $ cat > priv.possum <<'PRIV'
  > _secret = "s"
  > PRIV

  $ possum -p '!"priv.possum"._secret' -i 's'
  
  Program Error: '_@import0' is private to the module imported as '_@import0'
  
  program:1:0-22:
  1 \xe2\x96\x8f !"priv.possum"._secret (esc)
    \xe2\x96\x8f ^^^^^^^^^^^^^^^^^^^^^^ (esc)
  
  [ImportResolution]
  [1]
