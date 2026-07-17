  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/stdlib.possum -i '' --no-stdlib
  (Import 1:0-14 stdlib/string)
  
  (Import 2:0-14 stdlib/number)
  
  (Import 3:0-13 stdlib/const)
  
  (Import 4:0-13 stdlib/array)
  
  (Import 5:0-14 stdlib/object)
  
  (Import 6:0-14 stdlib/repeat)
  
  (Import 7:0-12 stdlib/util)
  
  (DeclareGlobal 8:0-19
    (Identifier 8:0-4 json)
    (Import 8:7-19 stdlib/json))
  
  (DeclareGlobal 9:0-19
    (Identifier 9:0-4 toml)
    (Import 9:7-19 stdlib/toml))
  
  (DeclareGlobal 10:0-17
    (Identifier 10:0-3 ast)
    (Import 10:6-17 stdlib/ast))
  
  (Import 11:0-14 stdlib/String)
  
  (Import 12:0-14 stdlib/Number)
  
  (Import 13:0-13 stdlib/Array)
  
  (Import 14:0-14 stdlib/Object)
  
  (Import 15:0-17 stdlib/Predicate)
  
  (Import 16:0-12 stdlib/Cast)
