  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/stdlib.possum -i '' --no-stdlib
  (Import 1:0-14 stdlib/string)
  
  (Import 2:0-14 stdlib/number)
  
  (Import 3:0-13 stdlib/const)
  
  (Import 4:0-13 stdlib/array)
  
  (Import 5:0-14 stdlib/object)
  
  (Import 6:0-18 stdlib/combinator)
  
  (DeclareGlobal 7:0-19
    (Identifier 7:0-4 json)
    (Import 7:7-19 stdlib/json))
  
  (DeclareGlobal 8:0-19
    (Identifier 8:0-4 toml)
    (Import 8:7-19 stdlib/toml))
  
  (DeclareGlobal 9:0-17
    (Identifier 9:0-3 ast)
    (Import 9:6-17 stdlib/ast))
  
  (Import 10:0-14 stdlib/String)
  
  (Import 11:0-14 stdlib/Number)
  
  (Import 12:0-13 stdlib/Array)
  
  (Import 13:0-14 stdlib/Object)
  
  (Import 14:0-17 stdlib/Predicate)
  
  (Import 15:0-12 stdlib/Cast)
