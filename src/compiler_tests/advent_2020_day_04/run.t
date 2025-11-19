  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  =================@fn477=================
  space | nl
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 5: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 6: newline
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ================passport================
  passport = object_sep(alphas, ":", token, space | nl)
  ========================================
  0000    | GetConstant 0: object_sep
  0002    | GetConstant 1: alphas
  0004    | GetConstant 2: ":"
  0006    | GetConstant 3: token
  0008    | GetConstant 4: @fn477
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
  0000    | GetConstant 7: _
  0002    | GetConstant 8: passport
  0004    | CallFunction 0
  0006    | Destructure 0: ({"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _} + _)
  0008    | End
  ========================================
  
  ==========count_valid_passport==========
  count_valid_passport = (valid_passport $ 1) | (passport $ 0)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 9: valid_passport
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | GetConstant 10: 1
  0010    | Or 10 -> 22
  0013    | GetConstant 8: passport
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 22
  0020    | GetConstant 11: 0
  0022    | End
  ========================================
  
  =================@fn478=================
  nl+nl
  ========================================
  0000    | GetConstant 6: newline
  0002    | CallFunction 0
  0004    | GetConstant 6: newline
  0006    | CallFunction 0
  0008    | Merge
  0009    | End
  ========================================
  
  =================@main==================
  many_sep(count_valid_passport, nl+nl)
  ========================================
  0000    | GetConstant 12: many_sep
  0002    | GetConstant 13: count_valid_passport
  0004    | GetConstant 14: @fn478
  0006    | CallFunction 2
  0008    | End
  ========================================

