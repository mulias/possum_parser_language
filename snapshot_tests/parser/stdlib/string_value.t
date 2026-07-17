  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/string_value.possum -i '' --no-stdlib
  (DeclareGlobal 1:0-43
    (Function 1:0-13
      (Identifier 1:0-10 Str.Length) [
        (Identifier 1:11-12 S)
      ])
    (Return 1:16-43
      (Destructure 1:16-39
        (Identifier 1:16-17 S)
        (Repeat 1:21-39
          (Range 1:22-34 (String 1:22-32 "\x00") ()) (esc)
          (Identifier 1:37-38 L)))
      (Identifier 1:42-43 L)))
