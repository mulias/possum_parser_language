  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '1..(..90)' -i '1111'
  
  Program Error: Range bound must be an integer or codepoint
  
  program:1:3-9:
  1 \xe2\x96\x8f 1..(..90) (esc)
    \xe2\x96\x8f    ^^^^^^ (esc)
  
  [InvalidAst]
  [1]
