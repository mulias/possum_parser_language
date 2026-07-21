  $ export PRINT_VM=true

  $ possum $TESTDIR/fibonacci.possum -i '4'
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main
  0000    | PushVar N
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N
  0002    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N, _
  0003    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N, _, _
  0004    | PushInteger 0
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N, _, _, 0
  0006    | ParseLowerBoundedRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, _, _, 4
  0007    | JumpIfFailure 7 -> 15
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, _, _, 4
  0010    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4, _, 4
  0012    | MatchBind l0 r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4, _, 4
  0015    | TakeRight 15 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4, _
  0018    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4, _, Fib
  0020    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, _, 4, _, Fib, 4
  0022    | CallTailFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, _, _, 4
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, _, _, 4
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, 4
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, 4
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, @Failure
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _
  0027    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, Fib
  0029    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, Fib, 4
  0031    | JumpIfFailure 31 -> 37
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, Fib, 4
  0034    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, Fib, 4, -1
  0036    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, Fib, 3
  0037    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, _, _, 3
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, _, _, 3
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, 3
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, 3
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, @Failure
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _
  0027    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib
  0029    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 3
  0031    | JumpIfFailure 31 -> 37
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 3
  0034    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 3, -1
  0036    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2
  0037    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, _, _, 2
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, _, _, 2
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, 2
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, 2
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, @Failure
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _
  0027    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib
  0029    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 2
  0031    | JumpIfFailure 31 -> 37
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 2
  0034    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 2, -1
  0036    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1
  0037    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, _, _, 1
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, _, _, 1
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, 1
  0039    | JumpIfFailure 39 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, 1
  0042    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, 2, 2, _, 1, Fib
  0044    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 2
  0046    | JumpIfFailure 46 -> 52
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 2
  0049    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 2, -2
  0051    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0
  0052    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, _, _, 0
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, _, _, 0
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1, 0
  0054    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, Fib, _, 2, _, 1
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, 1
  0039    | JumpIfFailure 39 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, 1
  0042    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, 3, 3, _, 1, Fib
  0044    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 3
  0046    | JumpIfFailure 46 -> 52
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 3
  0049    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 3, -2
  0051    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1
  0052    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, _, _, 1
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, _, _, 1
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, 1, _, 1
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, 1, _, 1
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, 1, _, 1
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, Fib, 1, 1, _, 1
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 1, 1
  0054    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 4, _, Fib, _, 3, _, 2
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, 2
  0039    | JumpIfFailure 39 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, 2
  0042    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, 2, Fib
  0044    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 4, _, 2, Fib, 4
  0046    | JumpIfFailure 46 -> 52
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 4, _, 2, Fib, 4
  0049    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 4, _, 2, Fib, 4, -2
  0051    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2
  0052    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, _, _, 2
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, _, _, 2
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, 2
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, 2
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, @Failure
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _
  0027    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib
  0029    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 2
  0031    | JumpIfFailure 31 -> 37
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 2
  0034    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 2, -1
  0036    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1
  0037    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, _, _, 1
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, _, _, 1
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, Fib, 1, 1, _, 1
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, 1
  0039    | JumpIfFailure 39 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, 1
  0042    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, 2, 2, _, 1, Fib
  0044    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 2
  0046    | JumpIfFailure 46 -> 52
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 2
  0049    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 2, -2
  0051    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0
  0052    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0
  0000    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, _
  0001    | PushUnderscoreVar
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, _, _
  0002    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, _, _
  0003    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, _, _, 0
  0005    | JumpIfFailure 5 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, _, _, 0
  0008    | MatchScrutinee r1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0010    | MatchInRange r1 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0024    | Or 24 -> 55
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, Fib, 0, 0, _, 0
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1, 0
  0054    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 4, _, 2, Fib, _, 2, _, 1
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 4, _, 2, 1
  0054    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 4, _, 3
  0055    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | 
  Stack   | 3
  3
