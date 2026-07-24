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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 4, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4
  Pattern | 4, _
  0026    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  Pattern | 4, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  Pattern | 
  0031    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib
  Pattern | 
  0033    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  Pattern | 
  0035    | JumpIfFailure 35 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  Pattern | 
  0038    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, -1
  Pattern | 
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0041    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 3, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3
  Pattern | 3, _
  0026    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  Pattern | 3, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  Pattern | 
  0031    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib
  Pattern | 
  0033    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  Pattern | 
  0035    | JumpIfFailure 35 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  Pattern | 
  0038    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, -1
  Pattern | 
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0041    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 2, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2
  Pattern | 2, _
  0026    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  Pattern | 2, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  Pattern | 
  0031    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib
  Pattern | 
  0033    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  Pattern | 
  0035    | JumpIfFailure 35 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  Pattern | 
  0038    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, -1
  Pattern | 
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  Pattern | 
  0041    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0023    | Jump 23 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  Pattern | 
  0043    | JumpIfFailure 43 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  Pattern | 
  0046    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib
  Pattern | 
  0048    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2
  Pattern | 
  0050    | JumpIfFailure 50 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2
  Pattern | 
  0053    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 2, -2
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0
  Pattern | 
  0056    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0023    | Jump 23 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1, 0
  Pattern | 
  0058    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, _, 1
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  Pattern | 
  0043    | JumpIfFailure 43 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  Pattern | 
  0046    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib
  Pattern | 
  0048    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3
  Pattern | 
  0050    | JumpIfFailure 50 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3
  Pattern | 
  0053    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 3, -2
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1
  Pattern | 
  0056    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0023    | Jump 23 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 1, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, Fib, 1, 1
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 1, 1
  Pattern | 
  0058    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, _, 2
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  Pattern | 
  0043    | JumpIfFailure 43 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  Pattern | 
  0046    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib
  Pattern | 
  0048    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4
  Pattern | 
  0050    | JumpIfFailure 50 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4
  Pattern | 
  0053    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 4, -2
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0056    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 2, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 2
  Pattern | 2, _
  0026    | MatchFail
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, @Failure
  Pattern | 2, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, @Failure
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2
  Pattern | 
  0031    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib
  Pattern | 
  0033    | GetLocal l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2
  Pattern | 
  0035    | JumpIfFailure 35 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2
  Pattern | 
  0038    | PushNegInteger -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 2, -1
  Pattern | 
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1
  Pattern | 
  0041    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0023    | Jump 23 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 1, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, Fib, 1, 1
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1
  Pattern | 
  0043    | JumpIfFailure 43 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1
  Pattern | 
  0046    | GetConstant 1: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, 2, 1, Fib
  Pattern | 
  0048    | GetLocalMove l0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2
  Pattern | 
  0050    | JumpIfFailure 50 -> 56
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2
  Pattern | 
  0053    | PushNegInteger -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 2, -2
  Pattern | 
  0055    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0
  Pattern | 
  0056    | CallFunction 1
  
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
  0003    | JumpIfFailure 3 -> 28
  
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
  0010    | MatchType r0 num_or_codepoint -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0015    | MatchBound r0 hi 1 -> 26
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0023    | Jump 23 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 0, _
  0027    | MatchWindowExit
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0028    | Or 28 -> 59
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, Fib, 0, 0
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1, 0
  Pattern | 
  0058    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, _, 2, Fib, _, 1
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 2, 1
  Pattern | 
  0058    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, _, 3
  Pattern | 
  0059    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | 
  Stack   | 3
  Pattern | 
  3
