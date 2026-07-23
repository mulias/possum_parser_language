A template hole whose pattern is a structural array or object casts the
hole's byte range by parsing it as JSON, then matches the parsed container
against the sub-pattern. The parse and match run inline (no plan
interpreter): MatchStrRest takes the byte range, MatchCastJson parses it,
and a child window matches the parsed value.

An array cast between fixed literals binds the array's elements:

  $ possum -p 'json -> "x%([A, B])y" $ [A, B]' -i '"x[3, 4]y"'
  [3, 4]

A whole-string hole casts the source value directly:

  $ possum -p 'json -> "%([A, B])" $ [A, B]' -i '"[3, 4]"'
  [3, 4]

The match result is the scrutinee string, unchanged:

  $ possum -p 'json -> "x%([1])y"' -i '"x[1]y"'
  "x[1]y"

An object cast binds a member value:

  $ possum -p 'json -> "id=%({`id`: Id})" $ Id' -i '"id={\"id\": 7}"'
  7

A nested structural cast opens a fresh child window per level:

  $ possum -p 'json -> "%([X, [Y, Z]])" $ [X, Y, Z]' -i '"[1, [2, 3]]"'
  [1, 2, 3]

A hole whose bytes are not the pattern's shape fails the match:

  $ possum -p 'json -> "x%([A, B])y" $ [A, B]' -i '"xhelloy"'
  
  Parse Failure: value "xhelloy" did not match pattern "x%([A, B])y"
  
  input:1:9:
  
  1 \xe2\x96\x8f "xhelloy" (esc)
    \xe2\x96\x8f          ^ (esc)
  
  expected one of:
    @fail (parser `unless`, stdlib/combinator.possum:18:33)
    "x%([A, B])y" (parser `@main`, program:1:8)
  [ParserFailure]
  [1]

Malformed JSON in the hole also fails the match rather than erroring:

  $ possum -p 'json -> "x%([A, B])y" $ [A, B]' -i '"x[1,y"'
  
  Parse Failure: value "x[1,y" did not match pattern "x%([A, B])y"
  
  input:1:7:
  
  1 \xe2\x96\x8f "x[1,y" (esc)
    \xe2\x96\x8f        ^ (esc)
  
  expected one of:
    @fail (parser `unless`, stdlib/combinator.possum:18:33)
    "x%([A, B])y" (parser `@main`, program:1:8)
  [ParserFailure]
  [1]

