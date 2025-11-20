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
  0000    | GetConstant 0: "hello"
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p "'world'" -i ''
  
  =================@main==================
  'world'
  ========================================
  0000    | GetConstant 0: "world"
  0002    | CallFunction 0
  0004    | End
  ========================================

  $ possum -p '"%(word)"' -i ''
  
  =================@main==================
  "%(word)"
  ========================================
  0000    | PushEmptyString
  0001    | GetConstant 0: word
  0003    | CallFunction 0
  0005    | MergeAsString
  0006    | End
  ========================================

  $ possum -p '"Hello %(word)"' -i ''
  
  =================@main==================
  "Hello %(word)"
  ========================================
  0000    | GetConstant 0: "Hello "
  0002    | CallFunction 0
  0004    | GetConstant 1: word
  0006    | CallFunction 0
  0008    | MergeAsString
  0009    | End
  ========================================

  $ possum -p '"%(word) World"' -i ''
  
  =================@main==================
  "%(word) World"
  ========================================
  0000    | PushEmptyString
  0001    | GetConstant 0: word
  0003    | CallFunction 0
  0005    | MergeAsString
  0006    | GetConstant 1: " World"
  0008    | CallFunction 0
  0010    | MergeAsString
  0011    | End
  ========================================

  $ possum -p '"Hello %(word) and %(word)"' -i ''
  
  =================@main==================
  "Hello %(word) and %(word)"
  ========================================
  0000    | GetConstant 0: "Hello "
  0002    | CallFunction 0
  0004    | GetConstant 1: word
  0006    | CallFunction 0
  0008    | MergeAsString
  0009    | GetConstant 2: " and "
  0011    | CallFunction 0
  0013    | MergeAsString
  0014    | GetConstant 1: word
  0016    | CallFunction 0
  0018    | MergeAsString
  0019    | End
  ========================================

  $ possum -p '"" $ "%(5)"' -i ''
  
  =================@main==================
  "" $ "%(5)"
  ========================================
  0000    | PushEmptyString
  0001    | TakeRight 1 -> 8
  0004    | PushEmptyString
  0005    | PushNumber 5
  0007    | MergeAsString
  0008    | End
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
  0000    | GetConstant 0: "Hello "
  0002    | CallFunction 0
  0004    | GetConstant 1: integer
  0006    | CallFunction 0
  0008    | GetConstant 2: word
  0010    | CallFunction 0
  0012    | Merge
  0013    | MergeAsString
  0014    | End
  ========================================

