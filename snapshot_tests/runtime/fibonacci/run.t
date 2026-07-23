  $ export PRINT_VM=true

  $ possum $TESTDIR/fibonacci.possum -i '4'
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main
  Pattern | 
  0000    | PushVar N
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N
  Pattern | 
  0002    | PushInteger 0
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N, 0
  Pattern | 
  0004    | ParseLowerBoundedRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  Pattern | 
  0005    | JumpIfFailure 5 -> 16
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  Pattern | 
  0008    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  Pattern | 4, _
  0012    | MatchBind l0 r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4
  Pattern | 4, _
  0015    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4
  Pattern | 
  0016    | TakeRight 16 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4
  Pattern | 
  0019    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, Fib
  Pattern | 
  0021    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, _, Fib, 4
  Pattern | 
  0023    | CallTailFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 4, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 4, _
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  Pattern | 4, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  Pattern | 
  0028    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib
  Pattern | 
  0030    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  Pattern | 
  0032    | JumpIfFailure 32 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  Pattern | 
  0035    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, -1
  Pattern | 
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 3, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 3, _
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  Pattern | 3, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0028    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib
  Pattern | 
  0030    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  Pattern | 
  0032    | JumpIfFailure 32 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  Pattern | 
  0035    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, -1
  Pattern | 
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 2, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 2, _
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  Pattern | 2, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0028    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib
  Pattern | 
  0030    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  Pattern | 
  0032    | JumpIfFailure 32 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  Pattern | 
  0035    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, -1
  Pattern | 
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  Pattern | 
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  Pattern | 
  0040    | JumpIfFailure 40 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  Pattern | 
  0043    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib
  Pattern | 
  0045    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2
  Pattern | 
  0047    | JumpIfFailure 47 -> 53
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2
  Pattern | 
  0050    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2, -2
  Pattern | 
  0052    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0
  Pattern | 
  0053    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, 0
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  Pattern | 
  0040    | JumpIfFailure 40 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  Pattern | 
  0043    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib
  Pattern | 
  0045    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3
  Pattern | 
  0047    | JumpIfFailure 47 -> 53
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3
  Pattern | 
  0050    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3, -2
  Pattern | 
  0052    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1
  Pattern | 
  0053    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, 1
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 2
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  Pattern | 
  0040    | JumpIfFailure 40 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  Pattern | 
  0043    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib
  Pattern | 
  0045    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4
  Pattern | 
  0047    | JumpIfFailure 47 -> 53
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4
  Pattern | 
  0050    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4, -2
  Pattern | 
  0052    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0053    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 2, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 2, _
  0023    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, @Failure
  Pattern | 2, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, @Failure
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0028    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib
  Pattern | 
  0030    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2
  Pattern | 
  0032    | JumpIfFailure 32 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2
  Pattern | 
  0035    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2, -1
  Pattern | 
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1
  Pattern | 
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1
  Pattern | 
  0040    | JumpIfFailure 40 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1
  Pattern | 
  0043    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1, Fib
  Pattern | 
  0045    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2
  Pattern | 
  0047    | JumpIfFailure 47 -> 53
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2
  Pattern | 
  0050    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2, -2
  Pattern | 
  0052    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0
  Pattern | 
  0053    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0
  Pattern | 
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0
  Pattern | 
  0001    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0003    | JumpIfFailure 3 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0006    | MatchWindowEnter 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | _, _
  0008    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0010    | MatchInRange r0 ..1 -> 23
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0020    | Jump 20 -> 24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0024    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0025    | Or 25 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, 0
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, 1
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 3
  Pattern | 
  0056    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | 
  Stack   | 3
  Pattern | 
  3
