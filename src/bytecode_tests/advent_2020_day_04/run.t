  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  =================@fn503=================
  space | nl
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: newline
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
  0008    | GetConstant 4: @fn503
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
  0000    | GetConstant 0: _
  0002    | GetConstant 1: passport
  0004    | CallFunction 0
  0006    | Destructure 0: ({"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _} + _)
  0008    | End
  ========================================
  
  ==========count_valid_passport==========
  count_valid_passport = (valid_passport $ 1) | (passport $ 0)
  ========================================
  0000    | SetInputMark
  0001    | GetConstant 0: valid_passport
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 10
  0008    | GetConstant 1: 1
  0010    | Or 10 -> 22
  0013    | GetConstant 2: passport
  0015    | CallFunction 0
  0017    | TakeRight 17 -> 22
  0020    | GetConstant 3: 0
  0022    | End
  ========================================
  
  =================@fn504=================
  nl+nl
  ========================================
  0000    | GetConstant 0: newline
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: newline
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  =================@main==================
  many_sep(count_valid_passport, nl+nl)
  ========================================
  0000    | GetConstant 0: many_sep
  0002    | GetConstant 1: count_valid_passport
  0004    | GetConstant 2: @fn504
  0006    | CallFunction 2
  0008    | End
  ========================================

