Bindings made inside a failed alternative are out of scope: when the rhs
of `|` binds the same variable, it binds fresh instead of equality-checking
against the failed branch's value.

  $ possum -p '(1 -> A & 2) | (1 & (3 -> A))' -i '13'
  3

A variable bound in every branch of an alternation is visible afterward.

  $ possum -p '((1 -> A) | (2 -> A)) & const(A)' -i '2'
  2

Repeat bodies bind fresh each iteration: the second iteration rebinds A
rather than equality-checking against the first iteration's value.

  $ possum -p '((("a" -> A) | ("b" -> A)) & const(A)) * 2' -i 'ab'
  "ab"

A conditional's condition binds into the then branch; when the condition
fails partway its bindings are out of scope in the else branch, which can
bind the variable fresh.

  $ possum -p '(1 -> A & 9) ? const(A) : ((2 -> A) & const(A))' -i '2'
  2

A repeat with an unbound count still binds the count to the number of
completed iterations.

  $ possum -p '("ab" * N) & const(N)' -i 'ababab'
  3

A merge solves for at most one unbound part, but nested merges are
independent: array and object parts are matched by length or by member,
so their contents don't consume the enclosing merge's solvable slot.

  $ possum -p 'json -> {A: [B, C + 1, D] + E} $ [A, B, C, D, E]' -i '{"x": [1, 2, 3, 4, 5]}'
  [
    "x",
    1,
    1,
    3,
    [4, 5]
  ]

A merge part whose variables are already bound evaluates to a value, so a
different part may be unbound.

  $ possum -p 'number -> A & "," & number -> (A + B) $ B' -i '3,5'
  2

An object repeat with a bound count is matched by member count, leaving
the merge's solvable slot for the rest part.

  $ possum -p 'json -> ({A: B} * 1 + C) $ [A, B, C]' -i '{"a":1,"b":2}'
  [
    "a",
    1,
    {"b": 2}
  ]

A string merge solves for one unbound rest part between bound parts.

  $ possum -p '"abbc" -> ("a" + R + "c") $ R' -i 'abbc'
  "bb"

A function argument bound by an earlier occurrence in the same pattern is
evaluated with the bound value.

  $ possum -p 'const([1, 2]) -> [A, Num.Add(A, 1)]' -i ''
  [1, 2]

An argument whose binding occurrence comes later in the pattern compiles,
but the solver matches in order and reaches the call first, so the match
is a runtime error today.

  $ possum -p 'const([1, 2]) -> [Num.Sub(A, 1), A]' -i ''
  [RuntimeError]
  [1]
