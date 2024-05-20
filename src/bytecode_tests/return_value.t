  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '"" $ [1, 2, [1+1+1]]' -i ''
  
  =================@main==================
  0000    1 GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 25
  0007    | GetConstant 1: [1, 2, _]
  0009    | GetConstant 2: [_]
  0011    | GetConstant 3: 1
  0013    | GetConstant 4: 1
  0015    | Merge
  0016    | GetConstant 5: 1
  0018    | Merge
  0019    | InsertAtIndex 0
  0021    | ResolveUnboundVars
  0022    | InsertAtIndex 2
  0024    | ResolveUnboundVars
  0025    | End
  ========================================
