  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  =================@fn433=================
  space | nl
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 4: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 5: newline
  0010    | CallFunction 0
  0012    | End
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
  0001    | GetConstant 6: passport
  0003    | CallFunction 0
  0005    | Destructure 0: ({"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _} + _)
  0007    | End
  ========================================
  
  ==========count_valid_passport==========
  count_valid_passport = (valid_passport $ 1) | (passport $ 0)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 7: valid_passport
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 9
  0008    | PushNumberOne
  0009    | Or 9 -> 20
  0012    | GetConstant 6: passport
  0014    | CallFunction 0
  0016    | TakeRight 16 -> 20
  0019    | PushNumberZero
  0020    | End
  ========================================
  
  =================@fn434=================
  nl+nl
  ========================================
  0000    | GetConstant 5: newline
  0002    | CallFunction 0
  0004    | GetConstant 5: newline
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
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

