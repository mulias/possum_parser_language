Local value variables are scoped at compile time: a binding made inside a
parser that fails is out of scope afterward, and every read must be of a
variable that is bound on all paths.

Reading a variable whose only binding is inside a failed alternative is a
compile error; the named-parser form `p = foo -> A & bar ; p | const(A)`
and the inline form behave the same.

  $ possum -p 'foo = 1 ; bar = 2 ; (foo -> A & bar) | const(A)' -i '11'
  
  Program Error: variable 'A' is unbound here: its binding is out of scope
  
  program:1:45-46:
  1 \xe2\x96\x8f foo = 1 ; bar = 2 ; (foo -> A & bar) | const(A) (esc)
    \xe2\x96\x8f                                              ^ (esc)
  
  [UnboundVariable]
  [1]

A pattern occurrence of a variable bound on only some paths is a compile
error: it would be a fresh binding on one path and an equality check on
the other.

  $ possum -p '((1 -> A) | 2) & (3 -> A)' -i '23'
  
  Program Error: variable 'A' may be unbound here: it is not bound on every path
  
  program:1:23-24:
  1 \xe2\x96\x8f ((1 -> A) | 2) & (3 -> A) (esc)
    \xe2\x96\x8f                        ^ (esc)
  
  [UnboundVariable]
  [1]

The same applies to reads.

  $ possum -p '((1 -> A) | 2) & const(A)' -i '2'
  
  Program Error: variable 'A' may be unbound here: it is not bound on every path
  
  program:1:23-24:
  1 \xe2\x96\x8f ((1 -> A) | 2) & const(A) (esc)
    \xe2\x96\x8f                        ^ (esc)
  
  [UnboundVariable]
  [1]

A binding that only becomes visible later in the parser can't be read
before it happens.

  $ possum -p 'const(A) & 1 -> A' -i '1'
  
  Program Error: variable 'A' is unbound here
  
  program:1:6-7:
  1 \xe2\x96\x8f const(A) & 1 -> A (esc)
    \xe2\x96\x8f       ^ (esc)
  
  [UnboundVariable]
  [1]

Closures capture variables by value, so capturing a variable before it is
bound is a compile error.

  $ possum -p 'many(const(A)) & 1 -> A' -i '1'
  
  Program Error: variable 'A' is unbound here
  
  program:1:5-13:
  1 \xe2\x96\x8f many(const(A)) & 1 -> A (esc)
    \xe2\x96\x8f      ^^^^^^^^ (esc)
  
  [UnboundVariable]
  [1]

Repeat bodies bind fresh each iteration and the final iteration may fail
after binding, so body bindings are out of scope after the loop.

  $ possum -p '("a" -> A) * 2 & const(A)' -i 'aa'
  
  Program Error: variable 'A' is unbound here: its binding is out of scope
  
  program:1:23-24:
  1 \xe2\x96\x8f ("a" -> A) * 2 & const(A) (esc)
    \xe2\x96\x8f                        ^ (esc)
  
  [UnboundVariable]
  [1]

Unbound variables can't be passed to functions as value arguments. Every
unbound use in the function is reported.

  $ possum -p 'f(V) = 1 -> V ; f(A) & const(A)' -i '1'
  
  Program Error: variable 'A' is unbound here
  
  program:1:18-19:
  1 \xe2\x96\x8f f(V) = 1 -> V ; f(A) & const(A) (esc)
    \xe2\x96\x8f                   ^ (esc)
  
  
  Program Error: variable 'A' is unbound here
  
  program:1:29-30:
  1 \xe2\x96\x8f f(V) = 1 -> V ; f(A) & const(A) (esc)
    \xe2\x96\x8f                              ^ (esc)
  
  [UnboundVariable]
  [1]

The pattern solver can solve for at most one unbound part per merge, so a
merge with a second unbound part is a compile error.

  $ possum -p 'number -> (A + B) $ [A, B]' -i '5'
  
  Program Error: variable 'B' is unbound here: a merge can solve at most one unbound part
  
  program:1:15-16:
  1 \xe2\x96\x8f number -> (A + B) $ [A, B] (esc)
    \xe2\x96\x8f                ^ (esc)
  
  [UnboundVariable]
  [1]

String templates are matched like string merges: at most one unbound
variable-length segment.

  $ possum -p 'json -> "%(A)-%(B)" $ [A, B]' -i '"x-y"'
  
  Program Error: variable 'B' is unbound here: a merge can solve at most one unbound part
  
  program:1:16-17:
  1 \xe2\x96\x8f json -> "%(A)-%(B)" $ [A, B] (esc)
    \xe2\x96\x8f                 ^ (esc)
  
  [UnboundVariable]
  [1]

An object repeat with an unbound count is itself a solvable part, so it
can't share a merge with an unbound rest.

  $ possum -p 'json -> ({A: B} * N + C) $ [N, C]' -i '{"a":1,"b":2}'
  
  Program Error: variable 'C' is unbound here: a merge can solve at most one unbound part
  
  program:1:22-23:
  1 \xe2\x96\x8f json -> ({A: B} * N + C) $ [N, C] (esc)
    \xe2\x96\x8f                       ^ (esc)
  
  [UnboundVariable]
  [1]

Placeholders are unbound parts too; a part with no variable to name gets
a generic message.

  $ possum -p 'json -> (_ + _)' -i '[1,2]'
  
  Program Error: pattern part is unbound here: a merge can solve at most one unbound part
  
  program:1:13-14:
  1 \xe2\x96\x8f json -> (_ + _) (esc)
    \xe2\x96\x8f              ^ (esc)
  
  [UnboundVariable]
  [1]

Repeat counts are destructured like any pattern, so a count merge with
two unbound variables is rejected.

  $ possum -p '("a" -> V) * (N + M) $ [N, M]' -i 'aaa'
  
  Program Error: variable 'M' is unbound here: a merge can solve at most one unbound part
  
  program:1:18-19:
  1 \xe2\x96\x8f ("a" -> V) * (N + M) $ [N, M] (esc)
    \xe2\x96\x8f                   ^ (esc)
  
  [UnboundVariable]
  [1]

Every extra unbound part is reported.

  $ possum -p 'number -> (A + B + C) $ [A, B, C]' -i '5'
  
  Program Error: variable 'B' is unbound here: a merge can solve at most one unbound part
  
  program:1:15-16:
  1 \xe2\x96\x8f number -> (A + B + C) $ [A, B, C] (esc)
    \xe2\x96\x8f                ^ (esc)
  
  
  Program Error: variable 'C' is unbound here: a merge can solve at most one unbound part
  
  program:1:19-20:
  1 \xe2\x96\x8f number -> (A + B + C) $ [A, B, C] (esc)
    \xe2\x96\x8f                    ^ (esc)
  
  [UnboundVariable]
  [1]

Function calls in patterns are evaluated, not solved: an argument
variable with no binding occurrence anywhere in the pattern is a compile
error.

  $ possum -p '1 -> Num.Add(A, 1)' -i '1'
  
  Program Error: variable 'A' is unbound here: variables in pattern function calls must be bound
  
  program:1:13-14:
  1 \xe2\x96\x8f 1 -> Num.Add(A, 1) (esc)
    \xe2\x96\x8f              ^ (esc)
  
  [UnboundVariable]
  [1]

The same applies to the callee, which also catches misspelled function
names since an unknown UpperCamelCase name is an unbound local.

  $ possum -p '1 -> F(2)' -i '1'
  
  Program Error: variable 'F' is unbound here: variables in pattern function calls must be bound
  
  program:1:5-6:
  1 \xe2\x96\x8f 1 -> F(2) (esc)
    \xe2\x96\x8f      ^ (esc)
  
  [UnboundVariable]
  [1]

Placeholders are never bound, so a placeholder argument is rejected.

  $ possum -p '2 -> Num.Add(_, 1)' -i '2'
  
  Program Error: variable '_' is unbound here: variables in pattern function calls must be bound
  
  program:1:13-14:
  1 \xe2\x96\x8f 2 -> Num.Add(_, 1) (esc)
    \xe2\x96\x8f              ^ (esc)
  
  [UnboundVariable]
  [1]

An argument bound on only some paths with no binding occurrence in the
pattern is rejected too.

  $ possum -p '((1 -> A) | 2) & 3 -> Num.Add(A, 1)' -i '13'
  
  Program Error: variable 'A' is unbound here: variables in pattern function calls must be bound
  
  program:1:30-31:
  1 \xe2\x96\x8f ((1 -> A) | 2) & 3 -> Num.Add(A, 1) (esc)
    \xe2\x96\x8f                               ^ (esc)
  
  [UnboundVariable]
  [1]

A variable bound before an alternation stays visible on both sides and
afterward, and a variable bound in every branch is visible afterward;
neither is an error.

  $ export RUN_VM=false

  $ possum -p '1 -> A & ((2 & const(A)) | const(A)) & const(A)' -i ''

  $ possum -p '((1 -> A) | (2 -> A)) & const(A)' -i ''
