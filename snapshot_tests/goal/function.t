Argument lowering. `call` is the only invoking construct: a bare ident in
operand position becomes a zero-arg call, and literal parsers are
call-wrapped the same way. In argument position parsers are passed as
values, never invoked.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum -p 'digit' -i ''
  main =
    (call digit)

  $ possum -p '"ab"' -i ''
  main =
    (call "ab")

  $ possum -p '5' -i ''
  main =
    (call 5)

Identifier arguments are eta-reduced: passed bare, no thunk.

  $ possum -p 'maybe(digit)' -i ''
  main =
    (call maybe [digit])

Composite parser arguments arrive from can as anonymous-function thunks,
which lower to lambdas.

  $ possum -p 'maybe(digit > alpha)' -i ''
  main =
    (call maybe [
      (lambda @fn0
        (seq result=1
          (call digit)
          (call alpha)))
    ])

  $ possum -p 'many("a" | "b")' -i ''
  main =
    (call many [
      (lambda @fn0
        (alt
          (arm
            guard: (call "a"))
          (arm
            body: (call "b"))))
    ])

Value declarations and calls are eager: bare idents stay values, and a
value call's arguments evaluate in place.

  $ cat > fns.possum <<'EOF'
  > double(p) = p > p
  > Add(A, B) = A + B
  > main = double(int) $ Add(1, 2)
  > EOF
  $ possum fns.possum -i ''
  double(p) =
    (seq result=1
      (call p)
      (call p))
  
  Add(A, B) =
    (merge A B)
  
  main =
    (seq result=1
      (call double [int])
      (call Add [1 2]))
  
