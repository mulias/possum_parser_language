  $ export PRINT_VM=true

  $ possum $TESTDIR/fibonacci.possum -i '4'
  
  input   | 4 @ 0
  Frames  | @main
  Stack   | @main
  0000    6 GetConstant 0: N
  
  input   | 4 @ 0
  Frames  | @main
  Stack   | @main, N
  0002    | GetConstant 1: integer
  
  input   | 4 @ 0
  Frames  | @main
  Stack   | @main, N, integer
  0004    | CallFunction 0
  
  input   | 4 @ 0
  Frames  | @main, integer
  Stack   | @main, N, integer
  0000   54 GetConstant 0: @number_of
  
  input   | 4 @ 0
  Frames  | @main, integer
  Stack   | @main, N, integer, @number_of
  0002    | GetConstant 1: _number_integer_part
  
  input   | 4 @ 0
  Frames  | @main, integer
  Stack   | @main, N, integer, @number_of, _number_integer_part
  0004    | CallTailFunction 1
  
  input   | 4 @ 0
  Frames  | @main, @number_of
  Stack   | @main, N, @number_of, _number_integer_part
  0000    0 GetLocal 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part
  0002    | CallFunction 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part
  0000   80 GetConstant 0: maybe
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe
  0002    | GetConstant 1: "-"
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-"
  0004    | CallFunction 1
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-"
  0000  100 SetInputMark
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-"
  0001    | GetBoundLocal 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", "-"
  0003    | CallFunction 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", @Failure
  0005    | Or 5 -> 12
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-"
  0008    | GetConstant 0: succeed
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", succeed
  0010    | CallFunction 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, succeed
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", succeed
  0000  108 GetConstant 0: const
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, succeed
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", succeed, const
  0002    | Null
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, succeed
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", succeed, const, null
  0003    | CallTailFunction 1
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, const
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", const, null
  0000  112 GetConstant 0: ""
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, const
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", const, null, ""
  0002    | CallFunction 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, const
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", const, null, ""
  0004    | TakeRight 4 -> 9
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, const
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", const, null
  0007    | GetBoundLocal 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe, const
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", const, null, null
  0009    | End
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, maybe
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, maybe, "-", null
  0012    | End
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null
  0006    | JumpIfFailure 6 -> 14
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null
  0009    | GetConstant 2: _number_non_negative_integer_part
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part
  0011    | CallFunction 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part
  0000   82 SetInputMark
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part
  0001    | ParseCharacterRange 0 1: 49 57
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4"
  0004    | JumpIfFailure 4 -> 12
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4"
  0007    | GetConstant 2: numerals
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", numerals
  0009    | CallFunction 0
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, numerals
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", numerals
  0000   19 GetConstant 0: many
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, numerals
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", numerals, many
  0002    | GetConstant 1: numeral
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, numerals
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", numerals, many, numeral
  0004    | CallTailFunction 1
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral
  0000  122 GetConstant 0: First
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First
  0002    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First, numeral
  0004    | CallFunction 0
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many, numeral
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First, numeral
  0000   17 ParseCharacterRange 0 1: 48 57
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many, numeral
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First, numeral, @Failure
  0003    | End
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First, @Failure
  0006    | GetLocal 1
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First, @Failure, First
  0008    | Destructure
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First, @Failure
  0009    | TakeRight 9 -> 20
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, many
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", many, numeral, First, @Failure
  0020    | End
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4", @Failure
  0011    | Merge
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, @Failure
  0012    | Or 12 -> 19
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part
  0015    | GetConstant 3: numeral
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, numeral
  0017    | CallFunction 0
  
  input   | 4 @ 0
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, numeral
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, numeral
  0000   17 ParseCharacterRange 0 1: 48 57
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part, numeral
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, numeral, "4"
  0003    | End
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part, _number_non_negative_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, _number_non_negative_integer_part, "4"
  0019    | End
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, null, "4"
  0013    | Merge
  
  input   | 4 @ 1
  Frames  | @main, @number_of, _number_integer_part
  Stack   | @main, N, @number_of, _number_integer_part, _number_integer_part, "4"
  0014    | End
  
  input   | 4 @ 1
  Frames  | @main, @number_of
  Stack   | @main, N, @number_of, _number_integer_part, "4"
  0004    | NumberOf
  
  input   | 4 @ 1
  Frames  | @main, @number_of
  Stack   | @main, N, @number_of, _number_integer_part, 4
  0005    | End
  
  input   | 4 @ 1
  Frames  | @main
  Stack   | @main, N, 4
  0006    | GetLocal 0
  
  input   | 4 @ 1
  Frames  | @main
  Stack   | @main, N, 4, N
  0008    | Destructure
  
  input   | 4 @ 1
  Frames  | @main
  Stack   | @main, 4, 4
  0009    | TakeRight 9 -> 18
  
  input   | 4 @ 1
  Frames  | @main
  Stack   | @main, 4
  0012    | GetConstant 2: Fib
  
  input   | 4 @ 1
  Frames  | @main
  Stack   | @main, 4, Fib
  0014    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | @main
  Stack   | @main, 4, Fib, 4
  0016    | CallTailFunction 1
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 4, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4
  0014    3 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4
  0015    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  0017    | GetConstant 2: 1
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 4, 1
  0019    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  0020    | ConditionalThen 20 -> 28
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4
  0028    4 GetConstant 4: Fib
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, Fib
  0030    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  0032    | GetConstant 5: 1
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, 1
  0034    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, -1
  0035    | Merge
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 3
  0036    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0014    3 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0015    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  0017    | GetConstant 2: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3, 1
  0019    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  0020    | ConditionalThen 20 -> 28
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0028    4 GetConstant 4: Fib
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib
  0030    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  0032    | GetConstant 5: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, 1
  0034    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, -1
  0035    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0036    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0014    3 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0015    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  0017    | GetConstant 2: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2, 1
  0019    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  0020    | ConditionalThen 20 -> 28
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0028    4 GetConstant 4: Fib
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib
  0030    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  0032    | GetConstant 5: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, 1
  0034    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, -1
  0035    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0036    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, @Failure
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0014    3 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0015    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0017    | GetConstant 2: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1, 1
  0019    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0020    | ConditionalThen 20 -> 28
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0023    | GetConstant 3: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0025    | ConditionalElse 25 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0038    | JumpIfFailure 38 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0041    | GetConstant 6: Fib
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib
  0043    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2
  0045    | GetConstant 7: 2
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2, 2
  0047    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2, -2
  0048    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0049    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0009    | GetConstant 1: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0011    | ConditionalElse 11 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, 0
  0051    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  0038    | JumpIfFailure 38 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  0041    | GetConstant 6: Fib
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib
  0043    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3
  0045    | GetConstant 7: 2
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3, 2
  0047    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3, -2
  0048    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0049    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, @Failure
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0014    3 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0015    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0017    | GetConstant 2: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1, 1
  0019    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0020    | ConditionalThen 20 -> 28
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0023    | GetConstant 3: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0025    | ConditionalElse 25 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, 1
  0051    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 2
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  0038    | JumpIfFailure 38 -> 52
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  0041    | GetConstant 6: Fib
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib
  0043    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4
  0045    | GetConstant 7: 2
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4, 2
  0047    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4, -2
  0048    | Merge
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 2
  0049    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 2
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 2, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, @Failure
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0014    3 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0015    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 2
  0017    | GetConstant 2: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 2, 1
  0019    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, @Failure
  0020    | ConditionalThen 20 -> 28
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0028    4 GetConstant 4: Fib
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib
  0030    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2
  0032    | GetConstant 5: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2, 1
  0034    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2, -1
  0035    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0036    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, @Failure
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0014    3 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0015    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0017    | GetConstant 2: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1, 1
  0019    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0020    | ConditionalThen 20 -> 28
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0023    | GetConstant 3: 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0025    | ConditionalElse 25 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0038    | JumpIfFailure 38 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0041    | GetConstant 6: Fib
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib
  0043    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2
  0045    | GetConstant 7: 2
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2, 2
  0047    | NegateNumber
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2, -2
  0048    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0049    | CallFunction 1
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0000    2 SetInputMark
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0001    | GetBoundLocal 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0003    | GetConstant 0: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0, 0
  0005    | Destructure
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0006    | ConditionalThen 6 -> 14
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0009    | GetConstant 1: 0
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0011    | ConditionalElse 11 -> 52
  
  input   | 4 @ 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, 0
  0051    | Merge
  
  input   | 4 @ 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0052    2 End
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 2, 1
  0051    | Merge
  
  input   | 4 @ 1
  Frames  | Fib
  Stack   | Fib, 4, 3
  0052    2 End
  
  input   | 4 @ 1
  Frames  | 
  Stack   | 3
  3
