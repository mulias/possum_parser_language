Full created-stage goal form of stdlib/number_value.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number_value.possum -i '' --no-stdlib
  Num.Add =
    @Add
  
  Num.Sub =
    @Subtract
  
  Num.Mul =
    @Multiply
  
  Num.Div =
    @Divide
  
  Num.Pow =
    @Power
  
  Num.Mod =
    @Modulus
  
  Num.Floor =
    @Floor
  
  Num.Ceil =
    @Ceiling
  
  Num.Inc(N) =
    (call @Add [N~0 1])
  
  Num.Dec(N) =
    (call @Subtract [N~0 1])
  
  Num.Abs(N) =
    (alt
      (arm
        guard: (match
          scrutinee: N~0
          %0 = scrutinee
          (arm
            (in_range %0 0 _))))
      (arm
        body: (neg N~0)))
  
  Num.Max(A, B) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          (arm
            (in_range %0 (read B~1) _)))
        body: A~0)
      (arm
        body: B~1))
  
  Num.Min(A, B) =
    (alt
      (arm
        guard: (match
          scrutinee: A~0
          %0 = scrutinee
          (arm
            (in_range %0 _ (read B~1))))
        body: A~0)
      (arm
        body: B~1))
  
  Num.FromBinaryDigits(Bs) =
    (seq result=1
      (match
        scrutinee: (call Array.Length [Bs~0])
        %0 = scrutinee
        (arm
          (bind %0 Len~1)))
      (call _Num.FromBinaryDigits [Bs~0 (merge Len~1 -1) 0]))
  
  _Num.FromBinaryDigits(Bs, Pos, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Bs~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 B~3)
            (bind %2 Rest~4)))
        body: (seq result=1
          (match
            scrutinee: B~3
            %0 = scrutinee
            (arm
              (in_range %0 0 1)))
          (call _Num.FromBinaryDigits [Rest~4 (merge Pos~1 -1) (merge Acc~2 (call Num.Mul [B~3 (call Num.Pow [2 Pos~1])]))])))
      (arm
        body: Acc~2))
  
  Num.FromOctalDigits(Os) =
    (seq result=1
      (match
        scrutinee: (call Array.Length [Os~0])
        %0 = scrutinee
        (arm
          (bind %0 Len~1)))
      (call _Num.FromOctalDigits [Os~0 (merge Len~1 -1) 0]))
  
  _Num.FromOctalDigits(Os, Pos, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Os~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 O~3)
            (bind %2 Rest~4)))
        body: (seq result=1
          (match
            scrutinee: O~3
            %0 = scrutinee
            (arm
              (in_range %0 0 7)))
          (call _Num.FromOctalDigits [Rest~4 (merge Pos~1 -1) (merge Acc~2 (call Num.Mul [O~3 (call Num.Pow [8 Pos~1])]))])))
      (arm
        body: Acc~2))
  
  Num.FromHexDigits(Hs) =
    (seq result=1
      (match
        scrutinee: (call Array.Length [Hs~0])
        %0 = scrutinee
        (arm
          (bind %0 Len~1)))
      (call _Num.FromHexDigits [Hs~0 (merge Len~1 -1) 0]))
  
  _Num.FromHexDigits(Hs, Pos, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Hs~0
          %0 = scrutinee
          %1 = elem %0 0
          %2 = slice %0 1 0
          (arm
            (is_type %0 array)
            (len_min %0 1)
            (bind %1 H~3)
            (bind %2 Rest~4)))
        body: (seq result=1
          (match
            scrutinee: H~3
            %0 = scrutinee
            (arm
              (in_range %0 0 15)))
          (call _Num.FromHexDigits [Rest~4 (merge Pos~1 -1) (merge Acc~2 (call Num.Mul [H~3 (call Num.Pow [16 Pos~1])]))])))
      (arm
        body: Acc~2))
  
