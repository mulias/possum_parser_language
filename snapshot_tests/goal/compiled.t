The goal compiler: GOAL_COMPILER=true emits function bodies from the
goal ast. Match arms whose constraints are all simple (array/object
shape tests, projections, binds, constant and slot comparisons) compile
to inline step ops on frame-slot registers; everything else lowers to a
match plan built from the goal constraints and runs on the existing plan
interpreter.

  $ export GOAL_COMPILER=true

The JSON hot path inlines fully: shape tests with fail jumps, det
projections into registers, binds into locals. The shared MatchFail
tail swaps the scrutinee for the failure const.

  $ PRINT_COMPILED_BYTECODE=true RUN_VM=false possum -p 'json -> [A, 2, B] $ [B, A]' -i '' 2>&1 | sed -n '/@main/,/^====*$/p' | sed '1d;$d'
  value
  ========================================
  ================2:@main=================
  json -> [A, 2, B] $ [B, A]
  ========================================
  0006    | CallFunctionConstant 0: @main
  0008    | JumpIfFailure 8 -> 59
  0011    | MatchWindowEnter 5
  0013    | MatchScrutinee r0
  0015    | MatchType r0 array -> 57
  0020    | MatchCount r0 ==3 -> 57
  0026    | MatchElem r1 r0[0]
  0031    | MatchBind l0 r1
  0034    | MatchElem r2 r0[1]
  0039    | MatchCmp r2 == 2 -> 57
  0046    | MatchElem r3 r0[2]
  0051    | MatchBind l1 r3
  0054    | Jump 54 -> 58
  0057    | MatchFail
  0058    | MatchWindowExit
  0059    | TakeRight 59 -> 72
  0062    | GetConstantMutable 2: [_, _]
  0064    | GetLocalMove l1
  0066    | InsertAtIndex 0
  0068    | GetLocalMove l0
  0070    | InsertAtIndex 1
  0072    | End

Behavior parity across the shapes: steps, plan-lowered composites, alt
commits, repeats, and the stdlib parsers.

  $ possum -p 'json -> [A, 2, B] $ [B, A]' -i '[1,2,3]'
  [3, 1]

  $ possum -p 'json -> [A, 2, B] $ [B, A]' -i '[1,9,3]'
  
  Parse Failure: value [1, 9, 3] did not match pattern [A, 2, B]
  
  input:1:7:
  
  1 \xe2\x96\x8f [1,9,3] (esc)
    \xe2\x96\x8f        ^ (esc)
  
  while matching parser `@main`
  
  program:1:8-17:
  
  1 \xe2\x96\x8f json -> [A, 2, B] $ [B, A] (esc)
    \xe2\x96\x8f         ^^^^^^^^^ (esc)
  
  [ParserFailure]
  [1]

  $ possum -p 'json -> {"a": A, "b": 2} $ A' -i '{"a":1,"b":2}'
  1

  $ possum -p 'word -> ("x" + R) $ R' -i 'xyz'
  "yz"

  $ possum -p '"a" ? "b" : "c" | "d"' -i 'd'
  "d"

  $ possum -p 'int -> N & "a" * N $ N' -i '3aaa'
  3

  $ possum -p 'w(p) = p + p ; w("a" | "b")' -i 'ab'
  "ab"

  $ possum -p 'json' -i '{"k":[1,{"n":null},"s"]}'
  {
    "k": [
      1,
      {"n": null},
      "s"
    ]
  }
