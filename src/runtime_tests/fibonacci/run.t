  $ export PRINT_VM=true

  $ possum $TESTDIR/fibonacci.possum -i '4'
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main
  0000    | GetConstant 0: N
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N
  0002    | ParseLowerBoundedRange 1: 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  0004    | GetLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4, N
  0006    | Destructure
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, 4
  0007    | TakeRight 7 -> 16
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4
  0010    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, Fib
  0012    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, 4, Fib, 4
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
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 4, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4
  0011    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib
  0013    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  0015    | JumpIfFailure 15 -> 22
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4
  0018    | GetConstant 3: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, 1
  0020    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, -1
  0021    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 3
  0022    | CallFunction 1
  
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
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 3, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3
  0011    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib
  0013    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  0015    | JumpIfFailure 15 -> 22
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3
  0018    | GetConstant 3: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, 1
  0020    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, -1
  0021    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0022    | CallFunction 1
  
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
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 2, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0011    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib
  0013    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  0015    | JumpIfFailure 15 -> 22
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2
  0018    | GetConstant 3: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, 1
  0020    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, -1
  0021    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0022    | CallFunction 1
  
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
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0024    | JumpIfFailure 24 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0027    | GetConstant 4: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib
  0029    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2
  0031    | JumpIfFailure 31 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2
  0034    | GetConstant 5: 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2, 2
  0036    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2, -2
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, 0
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  0024    | JumpIfFailure 24 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  0027    | GetConstant 4: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib
  0029    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3
  0031    | JumpIfFailure 31 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3
  0034    | GetConstant 5: 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3, 2
  0036    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3, -2
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, 1
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 2
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  0024    | JumpIfFailure 24 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  0027    | GetConstant 4: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib
  0029    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4
  0031    | JumpIfFailure 31 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4
  0034    | GetConstant 5: 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4, 2
  0036    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4, -2
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 2
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 2
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 2, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 2, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, @Failure
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0011    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib
  0013    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2
  0015    | JumpIfFailure 15 -> 22
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2
  0018    | GetConstant 3: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2, 1
  0020    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2, -1
  0021    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0022    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0024    | JumpIfFailure 24 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0027    | GetConstant 4: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib
  0029    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2
  0031    | JumpIfFailure 31 -> 38
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2
  0034    | GetConstant 5: 2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2, 2
  0036    | NegateNumber
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2, -2
  0037    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0038    | CallFunction 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0000    | SetInputMark
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0001    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0003    | GetConstant 0: _
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0, _
  0005    | GetConstant 1: 1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0, _, 1
  0007    | DestructureRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0008    | Or 8 -> 41
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, 0
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, 1
  0040    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 3
  0041    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | 
  Stack   | 3
  3
