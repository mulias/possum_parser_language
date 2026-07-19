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
  0005    | JumpIfFailure 5 -> 18
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  Pattern | 
  0008    | MatchWindowEnter 2 fail->17
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  Pattern | _, _
  0012    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  Pattern | 4, _
  0014    | MatchBind l0 r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4
  Pattern | 4, _
  0017    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4
  Pattern | 
  0018    | TakeRight 18 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4
  Pattern | 
  0021    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, Fib
  Pattern | 
  0023    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, _, Fib, 4
  Pattern | 
  0025    | CallTailFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 4, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 4, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 4, _
  0024    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  Pattern | 4, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  Pattern | 
  0029    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib
  Pattern | 
  0031    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  Pattern | 
  0033    | JumpIfFailure 33 -> 39
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  Pattern | 
  0036    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, -1
  Pattern | 
  0038    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0039    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 3, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 3, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 3, _
  0024    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  Pattern | 3, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0029    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib
  Pattern | 
  0031    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  Pattern | 
  0033    | JumpIfFailure 33 -> 39
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  Pattern | 
  0036    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, -1
  Pattern | 
  0038    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0039    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 2, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 2, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 2, _
  0024    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  Pattern | 2, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0029    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib
  Pattern | 
  0031    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  Pattern | 
  0033    | JumpIfFailure 33 -> 39
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  Pattern | 
  0036    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, -1
  Pattern | 
  0038    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  Pattern | 
  0039    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0021    | Jump 21 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  Pattern | 
  0041    | JumpIfFailure 41 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  Pattern | 
  0044    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib
  Pattern | 
  0046    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2
  Pattern | 
  0048    | JumpIfFailure 48 -> 54
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2
  Pattern | 
  0051    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2, -2
  Pattern | 
  0053    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0
  Pattern | 
  0054    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0021    | Jump 21 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, 0
  Pattern | 
  0056    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  Pattern | 
  0041    | JumpIfFailure 41 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  Pattern | 
  0044    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib
  Pattern | 
  0046    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3
  Pattern | 
  0048    | JumpIfFailure 48 -> 54
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3
  Pattern | 
  0051    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3, -2
  Pattern | 
  0053    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1
  Pattern | 
  0054    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0021    | Jump 21 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, 1
  Pattern | 
  0056    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 2
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  Pattern | 
  0041    | JumpIfFailure 41 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  Pattern | 
  0044    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib
  Pattern | 
  0046    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4
  Pattern | 
  0048    | JumpIfFailure 48 -> 54
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4
  Pattern | 
  0051    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4, -2
  Pattern | 
  0053    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0054    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 2, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 2, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 2, _
  0024    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, @Failure
  Pattern | 2, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, @Failure
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0029    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib
  Pattern | 
  0031    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2
  Pattern | 
  0033    | JumpIfFailure 33 -> 39
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2
  Pattern | 
  0036    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2, -1
  Pattern | 
  0038    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1
  Pattern | 
  0039    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0021    | Jump 21 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1
  Pattern | 
  0041    | JumpIfFailure 41 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1
  Pattern | 
  0044    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1, Fib
  Pattern | 
  0046    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2
  Pattern | 
  0048    | JumpIfFailure 48 -> 54
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2
  Pattern | 
  0051    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2, -2
  Pattern | 
  0053    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0
  Pattern | 
  0054    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0006    | MatchWindowEnter 2 fail->24
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | _, _
  0010    | MatchScrutinee r0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0012    | MatchType r0 num_or_codepoint
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0015    | MatchBound r0 hi 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0021    | Jump 21 -> 25
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0025    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0026    | Or 26 -> 57
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, 0
  Pattern | 
  0056    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, 1
  Pattern | 
  0056    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 3
  Pattern | 
  0057    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | 
  Stack   | 3
  Pattern | 
  3
