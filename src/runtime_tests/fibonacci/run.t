  $ export PRINT_VM=true

  $ possum $TESTDIR/fibonacci.possum -i '4'
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main
  0000    | GetConstant 0: N
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N
  0002    | GetConstant 1: 0
  
  input   | 4 @ Line 1 byte 0
  Frames  | @main
  Stack   | @main, N, 0
  0004    | ParseLowerBoundedRange
  
  input   | 4 @ Line 1 byte 1
  Frames  | @main
  Stack   | @main, N, 4
  0005    | Destructure 0: N
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      4 -> ..1
  Destructure Failure: 4 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, @Failure
  0005    | Or 5 -> 27
  
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
  0012    | GetConstant 1: -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 4, -1
  0014    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, Fib, 3
  0015    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      3 -> ..1
  Destructure Failure: 3 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, @Failure
  0005    | Or 5 -> 27
  
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
  0012    | GetConstant 1: -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 3, -1
  0014    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2
  0015    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      2 -> ..1
  Destructure Failure: 2 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, @Failure
  0005    | Or 5 -> 27
  
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
  0012    | GetConstant 1: -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 2, -1
  0014    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1
  0015    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      1 -> ..1
  Destructure Success: 1 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0005    | Or 5 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, Fib, 1, 1
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0017    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib
  0019    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2
  0021    | GetConstant 3: -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 2, -2
  0023    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0
  0024    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      0 -> ..1
  Destructure Success: 0 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0005    | Or 5 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, Fib, 0, 0
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1, 0
  0026    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, Fib, 2, 1
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1
  0017    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib
  0019    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3
  0021    | GetConstant 3: -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 3, -2
  0023    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1
  0024    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      1 -> ..1
  Destructure Success: 1 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0005    | Or 5 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, Fib, 1, 1
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 1, 1
  0026    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, Fib, 3, 2
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2
  0017    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib
  0019    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4
  0021    | GetConstant 3: -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 4, -2
  0023    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, Fib, 2
  0024    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      2 -> ..1
  Destructure Failure: 2 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, @Failure
  0005    | Or 5 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2
  0008    | GetConstant 0: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib
  0010    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2
  0012    | GetConstant 1: -1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 2, -1
  0014    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1
  0015    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      1 -> ..1
  Destructure Success: 1 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0005    | Or 5 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, Fib, 1, 1
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0017    | GetConstant 2: Fib
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib
  0019    | GetBoundLocal 0
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2
  0021    | GetConstant 3: -2
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 2, -2
  0023    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0
  0024    | CallFunction 1
  
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
  0003    | Destructure 0: ..1
  
  Destructure:
      0 -> ..1
  Destructure Success: 0 -> ..1
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0005    | Or 5 -> 27
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, Fib, 0, 0
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1, 0
  0026    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib, Fib
  Stack   | Fib, 4, 2, Fib, 2, 1
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 2, 1
  0026    | Merge
  
  input   | 4 @ Line 1 byte 1
  Frames  | Fib
  Stack   | Fib, 4, 3
  0027    | End
  
  input   | 4 @ Line 1 byte 1
  Frames  | 
  Stack   | 3
  3
