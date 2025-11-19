  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum -p '""' -i ''
  
  =================@main==================
  ""
  ========================================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | End
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
  0000    | GetConstant 0: ""
  0002    | GetConstant 1: word
  0004    | CallFunction 0
  0006    | MergeAsString
  0007    | End
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
  0000    | GetConstant 0: ""
  0002    | GetConstant 1: word
  0004    | CallFunction 0
  0006    | MergeAsString
  0007    | GetConstant 2: " World"
  0009    | CallFunction 0
  0011    | MergeAsString
  0012    | End
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
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 12
  0007    | GetConstant 0: ""
  0009    | GetConstant 1: 5
  0011    | MergeAsString
  0012    | End
  ========================================

  $ possum -p '"" -> "%(Str)"' -i ''
  
  =================@main==================
  "" -> "%(Str)"
  ========================================
  0000    | GetConstant 0: Str
  0002    | GetConstant 1: ""
  0004    | CallFunction 0
  0006    | Destructure 0: "%(Str)"
  0008    | End
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

