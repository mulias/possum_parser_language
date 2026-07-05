  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/fibonacci.possum -i '0'
  
  ==================fib===================
  fib(N) =
    const(N -> ..1) ? const(N) :
    fib(N - $1) -> N1 & fib(N - $2) -> N2 $
    (N1 + N2)
  ========================================
  0000    | PushVar2 N1
  0003    | PushVar2 N2
  0006    | SetInputMark
  0007    | GetConstant 0: const
  0009    | GetBoundLocal 0
  0011    | Destructure 0: ..1
  0013    | CallFunction 1
  0015    | ConditionalThen 15 -> 27
  0018    | GetConstant 0: const
  0020    | GetBoundLocalMove 0
  0022    | CallTailFunction 1
  0024    | Jump 24 -> 69
  0027    | GetConstant 1: fib
  0029    | GetBoundLocal 0
  0031    | JumpIfFailure 31 -> 37
  0034    | PushNegInteger -1
  0036    | Merge
  0037    | CallFunction 1
  0039    | Destructure 1: N1
  0041    | TakeRight 41 -> 69
  0044    | GetConstant 1: fib
  0046    | GetBoundLocalMove 0
  0048    | JumpIfFailure 48 -> 54
  0051    | PushNegInteger -2
  0053    | Merge
  0054    | CallFunction 1
  0056    | Destructure 2: N2
  0058    | TakeRight 58 -> 69
  0061    | GetBoundLocalMove 1
  0063    | JumpIfFailure 63 -> 69
  0066    | GetBoundLocalMove 2
  0068    | Merge
  0069    | End
  ========================================
  
  =================const==================
  const(C) = "" $ C
  ========================================
  0000    | GetBoundLocalMove 0
  0002    | End
  ========================================
  
  ==================Fib===================
  Fib(N) = N -> ..1 | (Fib(N - 1) + Fib(N - 2))
  ========================================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | Destructure 3: ..1
  0005    | Or 5 -> 36
  0008    | GetConstant 2: Fib
  0010    | GetBoundLocal 0
  0012    | JumpIfFailure 12 -> 18
  0015    | PushNegInteger -1
  0017    | Merge
  0018    | CallFunction 1
  0020    | JumpIfFailure 20 -> 36
  0023    | GetConstant 2: Fib
  0025    | GetBoundLocalMove 0
  0027    | JumpIfFailure 27 -> 33
  0030    | PushNegInteger -2
  0032    | Merge
  0033    | CallFunction 1
  0035    | Merge
  0036    | End
  ========================================
  
  =================@main==================
  0.. -> N & fib(N) -> Fib(N)
  ========================================
  0000    | PushVar2 N
  0003    | PushInteger 0
  0005    | ParseLowerBoundedRange
  0006    | Destructure 4: N
  0008    | TakeRight 8 -> 19
  0011    | GetConstant 1: fib
  0013    | GetBoundLocal 0
  0015    | CallFunction 1
  0017    | Destructure 5: Fib(N)
  0019    | End
  ========================================
