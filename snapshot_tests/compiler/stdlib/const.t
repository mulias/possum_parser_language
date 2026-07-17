  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/const.possum -i '' --no-stdlib
  
  =================1:true=================
  true(t) = t $ true
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushTrue
  0006    | End
  ========================================
  
  ================1:false=================
  false(f) = f $ false
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushFalse
  0006    | End
  ========================================
  
  ===============1:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetLocalMove 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetLocalMove 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ===============1:boolean================
  boolean(t, f) = true(t) | false(f)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetLocalMove 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetLocalMove 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  =================1:null=================
  null(n) = n $ null
  ========================================
  0000    | CallFunctionLocal 0
  0002    | TakeRight 2 -> 6
  0005    | PushNull
  0006    | End
  ========================================
