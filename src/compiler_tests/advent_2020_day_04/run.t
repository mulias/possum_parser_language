  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  =================@fn433=================
  space | nl
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 4: space
  0003    | Or 3 -> 8
  0006    | CallFunctionConstant 5: newline
  0008    | End
  ========================================
  
  ================passport================
  passport = object_sep(alphas, ":", token, space | nl)
  ========================================
  0000    | GetConstant 0: object_sep
  0002    | GetConstant 1: alphas
  0004    | PushChar ':'
  0006    | GetConstant 2: token
  0008    | GetConstant 3: @fn433
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =============valid_passport=============
  valid_passport =
    passport -> {
      "byr": _, "iyr": _, "eyr": _, "hgt": _,
      "hcl": _, "ecl": _, "pid": _, ..._,
    }
  ========================================
  0000    | PushUnderscoreVar
  0001    | CallFunctionConstant 6: passport
  0003    | Destructure 0: ({"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _} + _)
  0005    | End
  ========================================
  
  ==========count_valid_passport==========
  count_valid_passport = (valid_passport $ 1) | (passport $ 0)
  ========================================
  0000    | SetInputMark
  0001    | CallFunctionConstant 7: valid_passport
  0003    | TakeRight 3 -> 7
  0006    | PushNumberOne
  0007    | Or 7 -> 16
  0010    | CallFunctionConstant 6: passport
  0012    | TakeRight 12 -> 16
  0015    | PushNumberZero
  0016    | End
  ========================================
  
  =================@fn434=================
  nl+nl
  ========================================
  0000    | CallFunctionConstant 5: newline
  0002    | CallFunctionConstant 5: newline
  0004    | Merge
  0005    | End
  ========================================
  
  =================@main==================
  many_sep(count_valid_passport, nl+nl)
  ========================================
  0000    | GetConstant 8: many_sep
  0002    | GetConstant 9: count_valid_passport
  0004    | GetConstant 10: @fn434
  0006    | CallFunction 2
  0008    | End
  ========================================

