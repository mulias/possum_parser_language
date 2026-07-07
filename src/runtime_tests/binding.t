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
