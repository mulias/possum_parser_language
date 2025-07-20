  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  =================@fn562=================
  0000    | SetInputMark
  0001    | GetConstant 0: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: newline
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ================passport================
  0000    | GetConstant 0: object_sep
  0002    | GetConstant 1: alphas
  0004    | GetConstant 2: ":"
  0006    | GetConstant 3: token
  0008    | GetConstant 4: @fn562
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =============valid_passport=============
  0000    | GetConstant 0: _
  0002    | GetConstant 1: passport
  0004    | CallFunction 0
  0006    | GetConstant 2: {"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _}
  0008    | GetLocal 0
  0010    | GetConstant 3: {}
  0012    | PrepareMergePattern 3
  0014    | JumpIfFailure 14 -> 121
  0017    | GetConstant 4: {"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _}
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 98
  0023    | GetConstant 5: "byr"
  0025    | GetAtKey
  0026    | GetLocal 0
  0028    | Destructure
  0029    | JumpIfFailure 29 -> 96
  0032    | Pop
  0033    | GetConstant 6: "iyr"
  0035    | GetAtKey
  0036    | GetLocal 0
  0038    | Destructure
  0039    | JumpIfFailure 39 -> 96
  0042    | Pop
  0043    | GetConstant 7: "eyr"
  0045    | GetAtKey
  0046    | GetLocal 0
  0048    | Destructure
  0049    | JumpIfFailure 49 -> 96
  0052    | Pop
  0053    | GetConstant 8: "hgt"
  0055    | GetAtKey
  0056    | GetLocal 0
  0058    | Destructure
  0059    | JumpIfFailure 59 -> 96
  0062    | Pop
  0063    | GetConstant 9: "hcl"
  0065    | GetAtKey
  0066    | GetLocal 0
  0068    | Destructure
  0069    | JumpIfFailure 69 -> 96
  0072    | Pop
  0073    | GetConstant 10: "ecl"
  0075    | GetAtKey
  0076    | GetLocal 0
  0078    | Destructure
  0079    | JumpIfFailure 79 -> 96
  0082    | Pop
  0083    | GetConstant 11: "pid"
  0085    | GetAtKey
  0086    | GetLocal 0
  0088    | Destructure
  0089    | JumpIfFailure 89 -> 96
  0092    | Pop
  0093    | JumpIfSuccess 93 -> 98
  0096    | Swap
  0097    | Pop
  0098    | JumpIfFailure 98 -> 119
  0101    | Pop
  0102    | GetLocal 0
  0104    | Destructure
  0105    | JumpIfFailure 105 -> 119
  0108    | Pop
  0109    | GetConstant 12: {}
  0111    | Destructure
  0112    | JumpIfFailure 112 -> 119
  0115    | Pop
  0116    | JumpIfSuccess 116 -> 121
  0119    | Swap
  0120    | Pop
  0121    | End
  ========================================
  
  ==========count_valid_passport==========
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
  
  =================@fn563=================
  0000    | GetConstant 0: newline
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: newline
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  =================@main==================
  0000    | GetConstant 0: many_sep
  0002    | GetConstant 1: count_valid_passport
  0004    | GetConstant 2: @fn563
  0006    | CallFunction 2
  0008    | End
  ========================================

