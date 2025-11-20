  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '""' -i ''
  
  =================@main==================
  ""
  ========================================
  0000    | PushEmptyString
  0001    | End
  ========================================

  $ possum -p '"hello"' -i ''
  
  =================@main==================
  "hello"
  ========================================
  0000    | CallFunctionConstant 0: "hello"
  0002    | End
  ========================================

  $ possum -p "'world'" -i ''
  
  =================@main==================
  'world'
  ========================================
  0000    | CallFunctionConstant 0: "world"
  0002    | End
  ========================================

  $ possum -p '"%(word)"' -i ''
  
  =================@main==================
  "%(word)"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionConstant 0: word
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p '"Hello %(word)"' -i ''
  
  =================@main==================
  "Hello %(word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | CallFunctionConstant 1: word
  0004    | MergeAsString
  0005    | End
  ========================================

  $ possum -p '"%(word) World"' -i ''
  
  =================@main==================
  "%(word) World"
  ========================================
  0000    | PushEmptyString
  0001    | CallFunctionConstant 0: word
  0003    | MergeAsString
  0004    | CallFunctionConstant 1: " World"
  0006    | MergeAsString
  0007    | End
  ========================================

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  
  =================@main==================
  "Hello %(word) and %(word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | CallFunctionConstant 1: word
  0004    | MergeAsString
  0005    | CallFunctionConstant 2: " and "
  0007    | MergeAsString
  0008    | CallFunctionConstant 1: word
  0010    | MergeAsString
  0011    | End
  ========================================

  $ possum -p '"" $ "%(5)"' -i ''
  
  =================@main==================
  "" $ "%(5)"
  ========================================
  0000    | PushEmptyString
  0001    | PushNumber 5
  0003    | MergeAsString
  0004    | End
  ========================================

  $ possum -p '"" -> "%(Str)"' -i ''
  
  =================@main==================
  "" -> "%(Str)"
  ========================================
  0000    | GetConstant 0: Str
  0002    | PushEmptyString
  0003    | Destructure 0: "%(Str)"
  0005    | End
  ========================================

  $ possum -p '"Hello %(int + word)"' -i ''
  
  =================@main==================
  "Hello %(int + word)"
  ========================================
  0000    | CallFunctionConstant 0: "Hello "
  0002    | CallFunctionConstant 1: integer
  0004    | CallFunctionConstant 2: word
  0006    | Merge
  0007    | MergeAsString
  0008    | End
  ========================================

