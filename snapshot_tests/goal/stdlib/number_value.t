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
    (call @Add [N 1])
  
  Num.Dec(N) =
    (call @Subtract [N 1])
  
  Num.Abs(N) =
    (alt
      (arm
        guard: (match
          scrutinee: N
          %0 = scrutinee
          (arm
            (in_range %0 0 _))))
      (arm
        body: (neg N)))
  
  Num.Max(A, B) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (in_range %0 (local B) _)))
        body: A)
      (arm
        body: B))
  
  Num.Min(A, B) =
    (alt
      (arm
        guard: (match
          scrutinee: A
          %0 = scrutinee
          (arm
            (in_range %0 _ (local B))))
        body: A)
      (arm
        body: B))
  
  Num.FromBinaryDigits(Bs) =
    (seq result=1
      (match
        scrutinee: (call Array.Length [Bs])
        %0 = scrutinee
        (arm
          (local %0 Len)))
      (call _Num.FromBinaryDigits [Bs (merge Len -1) 0]))
  
  _Num.FromBinaryDigits(Bs, Pos, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Bs
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 B))
              (local Rest))))
        body: (seq result=1
          (match
            scrutinee: B
            %0 = scrutinee
            (arm
              (in_range %0 0 1)))
          (call _Num.FromBinaryDigits [Rest (merge Pos -1) (merge Acc (call Num.Mul [B (call Num.Pow [2 Pos])]))])))
      (arm
        body: Acc))
  
  Num.FromOctalDigits(Os) =
    (seq result=1
      (match
        scrutinee: (call Array.Length [Os])
        %0 = scrutinee
        (arm
          (local %0 Len)))
      (call _Num.FromOctalDigits [Os (merge Len -1) 0]))
  
  _Num.FromOctalDigits(Os, Pos, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Os
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 O))
              (local Rest))))
        body: (seq result=1
          (match
            scrutinee: O
            %0 = scrutinee
            (arm
              (in_range %0 0 7)))
          (call _Num.FromOctalDigits [Rest (merge Pos -1) (merge Acc (call Num.Mul [O (call Num.Pow [8 Pos])]))])))
      (arm
        body: Acc))
  
  Num.FromHexDigits(Hs) =
    (seq result=1
      (match
        scrutinee: (call Array.Length [Hs])
        %0 = scrutinee
        (arm
          (local %0 Len)))
      (call _Num.FromHexDigits [Hs (merge Len -1) 0]))
  
  _Num.FromHexDigits(Hs, Pos, Acc) =
    (alt
      (arm
        guard: (match
          scrutinee: Hs
          %0 = scrutinee
          (arm
            (solve_merge %0
              (set
                %0 = scrutinee
                %1 = elem %0 0
                (is_type %0 array)
                (len_eq %0 1)
                (local %1 H))
              (local Rest))))
        body: (seq result=1
          (match
            scrutinee: H
            %0 = scrutinee
            (arm
              (in_range %0 0 15)))
          (call _Num.FromHexDigits [Rest (merge Pos -1) (merge Acc (call Num.Mul [H (call Num.Pow [16 Pos])]))])))
      (arm
        body: Acc))
  
