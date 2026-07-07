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

A variable bound before an alternation stays visible on both sides and
afterward, and a variable bound in every branch is visible afterward;
neither is an error.

  $ export RUN_VM=false

  $ possum -p '1 -> A & ((2 & const(A)) | const(A)) & const(A)' -i ''

  $ possum -p '((1 -> A) | (2 -> A)) & const(A)' -i ''
