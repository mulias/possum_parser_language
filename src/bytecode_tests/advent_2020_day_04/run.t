  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/part_1.possum $TESTDIR/input.txt
  
  =================@fn563=================
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
  0008    | GetConstant 4: @fn563
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
  0006    | GetConstant 2: {"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _}
  0008    | GetLocal 0
  0010    | PrepareMergePattern 2
  0012    | JumpIfFailure 12 -> 112
  0015    | GetConstant 3: {"byr": _, "iyr": _, "eyr": _, "hgt": _, "hcl": _, "ecl": _, "pid": _}
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 96
  0021    | GetConstant 4: "byr"
  0023    | GetAtKey
  0024    | GetLocal 0
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 94
  0030    | Pop
  0031    | GetConstant 5: "iyr"
  0033    | GetAtKey
  0034    | GetLocal 0
  0036    | Destructure
  0037    | JumpIfFailure 37 -> 94
  0040    | Pop
  0041    | GetConstant 6: "eyr"
  0043    | GetAtKey
  0044    | GetLocal 0
  0046    | Destructure
  0047    | JumpIfFailure 47 -> 94
  0050    | Pop
  0051    | GetConstant 7: "hgt"
  0053    | GetAtKey
  0054    | GetLocal 0
  0056    | Destructure
  0057    | JumpIfFailure 57 -> 94
  0060    | Pop
  0061    | GetConstant 8: "hcl"
  0063    | GetAtKey
  0064    | GetLocal 0
  0066    | Destructure
  0067    | JumpIfFailure 67 -> 94
  0070    | Pop
  0071    | GetConstant 9: "ecl"
  0073    | GetAtKey
  0074    | GetLocal 0
  0076    | Destructure
  0077    | JumpIfFailure 77 -> 94
  0080    | Pop
  0081    | GetConstant 10: "pid"
  0083    | GetAtKey
  0084    | GetLocal 0
  0086    | Destructure
  0087    | JumpIfFailure 87 -> 94
  0090    | Pop
  0091    | JumpIfSuccess 91 -> 96
  0094    | Swap
  0095    | Pop
  0096    | JumpIfFailure 96 -> 110
  0099    | Pop
  0100    | GetLocal 0
  0102    | Destructure
  0103    | JumpIfFailure 103 -> 110
  0106    | Pop
  0107    | JumpIfSuccess 107 -> 112
  0110    | Swap
  0111    | Pop
  0112    | End
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
  
  =================@fn566=================
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
  0004    | GetConstant 2: @fn566
  0006    | CallFunction 2
  0008    | End
  ========================================

