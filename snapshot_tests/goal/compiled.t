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
  0011    | CallFunctionConstant 0: @main
  0013    | JumpIfFailure 13 -> 56
  0016    | MatchScrutinee r2
  0018    | MatchType r2 array -> 55
  0023    | MatchLen r2 3 -> 55
  0028    | MatchElem r3 r2[0]
  0032    | MatchBind l0 r3
  0035    | MatchElem r4 r2[1]
  0039    | MatchConst r4 2 -> 55
  0045    | MatchElem r5 r2[2]
  0049    | MatchBind l1 r5
  0052    | Jump 52 -> 56
  0055    | MatchFail
  0056    | TakeRight 56 -> 69
  0059    | GetConstantMutable 2: [_, _]
  0061    | GetLocalMove l1
  0063    | InsertAtIndex 0
  0065    | GetLocalMove l0
  0067    | InsertAtIndex 1
  0069    | End

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
