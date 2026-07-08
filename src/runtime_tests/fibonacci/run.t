  $ export PRINT_VM=true

  $ possum $TESTDIR/fibonacci.possum -i '4'
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main
  0000    | PushVar N
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N
  0002    | PushInteger 0
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N, 0
  0004    | ParseLowerBoundedRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  0005    | DestructurePlan 1: bind N
  
  Destructure:
      4 -> N
  Destructure Success: 4 -> N
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4
  0007    | TakeRight 7 -> 16
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4
  0010    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, Fib
  0012    | GetBoundLocalMove 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, null, Fib, 4
  0014    | CallTailFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      4 -> ..1
  Destructure Failure: 4 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  0008    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib
  0010    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  0012    | JumpIfFailure 12 -> 18
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  0015    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, -1
  0017    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 3
  0018    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      3 -> ..1
  Destructure Failure: 3 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0008    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib
  0010    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  0012    | JumpIfFailure 12 -> 18
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  0015    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, -1
  0017    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0018    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      2 -> ..1
  Destructure Failure: 2 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0008    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib
  0010    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  0012    | JumpIfFailure 12 -> 18
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  0015    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, -1
  0017    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0018    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      1 -> ..1
  Destructure Success: 1 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0020    | JumpIfFailure 20 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0023    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib
  0025    | GetBoundLocalMove 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 2
  0027    | JumpIfFailure 27 -> 33
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 2
  0030    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 2, -2
  0032    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 0
  0033    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 0
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 0
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 0, 0
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      0 -> ..1
  Destructure Success: 0 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 0, 0
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, Fib, 0, 0
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1, 0
  0035    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, null, 1
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  0020    | JumpIfFailure 20 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  0023    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib
  0025    | GetBoundLocalMove 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 3
  0027    | JumpIfFailure 27 -> 33
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 3
  0030    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 3, -2
  0032    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 1
  0033    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 1
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 1, 1
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      1 -> ..1
  Destructure Success: 1 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 1, 1
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, Fib, 1, 1
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, null, 1, 1
  0035    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, null, 2
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  0020    | JumpIfFailure 20 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  0023    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib
  0025    | GetBoundLocalMove 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, null, 2, Fib, 4
  0027    | JumpIfFailure 27 -> 33
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, null, 2, Fib, 4
  0030    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, null, 2, Fib, 4, -2
  0032    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, null, 2, Fib, 2
  0033    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, 2
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      2 -> ..1
  Destructure Failure: 2 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, @Failure
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2
  0008    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib
  0010    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 2
  0012    | JumpIfFailure 12 -> 18
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 2
  0015    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 2, -1
  0017    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 1
  0018    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 1
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 1, 1
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      1 -> ..1
  Destructure Success: 1 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 1, 1
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, Fib, 1, 1
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, 1
  0020    | JumpIfFailure 20 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, 1
  0023    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, 2, 1, Fib
  0025    | GetBoundLocalMove 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 2
  0027    | JumpIfFailure 27 -> 33
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 2
  0030    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 2, -2
  0032    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 0
  0033    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 0
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 0
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 0, 0
  0003    | DestructurePlan 0: ..1
  
  Destructure:
      0 -> ..1
  Destructure Success: 0 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 0, 0
  0005    | Or 5 -> 36
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, Fib, 0, 0
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1, 0
  0035    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, null, 2, Fib, null, 1
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, null, 2, 1
  0035    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, null, 3
  0036    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | 
  Stack   | 3
  3
