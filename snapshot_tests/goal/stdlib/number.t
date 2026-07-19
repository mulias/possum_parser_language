Full created-stage goal form of stdlib/number.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/number.possum -i '' --no-stdlib
  digit =
    (call (range 0 9))
  
  integer =
    (call as_number [
      (lambda @fn0
        (merge (call maybe ["-"]) (call _number_integer_part)))
    ])
  
  int =
    (call integer)
  
  non_negative_integer =
    (call as_number [_number_integer_part])
  
  negative_integer =
    (call as_number [
      (lambda @fn1
        (merge (call "-") (call _number_integer_part)))
    ])
  
  float =
    (call as_number [
      (lambda @fn2
        (merge (merge (call maybe ["-"]) (call _number_integer_part)) (call _number_fraction_part)))
    ])
  
  scientific_integer =
    (call as_number [
      (lambda @fn3
        (merge (merge (call maybe ["-"]) (call _number_integer_part)) (call _number_exponent_part)))
    ])
  
  scientific_float =
    (call as_number [
      (lambda @fn4
        (merge (merge (merge (call maybe ["-"]) (call _number_integer_part)) (call _number_fraction_part)) (call _number_exponent_part)))
    ])
  
  number =
    (call as_number [
      (lambda @fn5
        (merge (merge (merge (call maybe ["-"]) (call _number_integer_part)) (call maybe [_number_fraction_part])) (call maybe [_number_exponent_part])))
    ])
  
  num =
    (call number)
  
  non_negative_number =
    (call as_number [
      (lambda @fn6
        (merge (merge (call _number_integer_part) (call maybe [_number_fraction_part])) (call maybe [_number_exponent_part])))
    ])
  
  negative_number =
    (call as_number [
      (lambda @fn7
        (merge (merge (merge (call "-") (call _number_integer_part)) (call maybe [_number_fraction_part])) (call maybe [_number_exponent_part])))
    ])
  
  _number_integer_part =
    (alt
      (arm
        guard: (merge (call (range "1" "9")) (call numerals)))
      (arm
        body: (call numeral)))
  
  _number_fraction_part =
    (merge (call ".") (call numerals))
  
  _number_exponent_part =
    (merge
      (merge
        (alt
          (arm
            guard: (call "e"))
          (arm
            body: (call "E")))
        (call maybe [
          (lambda @fn8
            (alt
              (arm
                guard: (call "-"))
              (arm
                body: (call "+"))))
        ]))
      (call numerals))
  
  binary_digit =
    (call (range 0 1))
  
  octal_digit =
    (call (range 0 7))
  
  hex_digit =
    (alt
      (arm
        guard: (call digit))
      (arm
        guard: (seq result=1
          (alt
            (arm
              guard: (call "a"))
            (arm
              body: (call "A")))
          10))
      (arm
        guard: (seq result=1
          (alt
            (arm
              guard: (call "b"))
            (arm
              body: (call "B")))
          11))
      (arm
        guard: (seq result=1
          (alt
            (arm
              guard: (call "c"))
            (arm
              body: (call "C")))
          12))
      (arm
        guard: (seq result=1
          (alt
            (arm
              guard: (call "d"))
            (arm
              body: (call "D")))
          13))
      (arm
        guard: (seq result=1
          (alt
            (arm
              guard: (call "e"))
            (arm
              body: (call "E")))
          14))
      (arm
        body: (seq result=1
          (alt
            (arm
              guard: (call "f"))
            (arm
              body: (call "F")))
          15)))
  
  binary_integer =
    (seq result=1
      (match
        scrutinee: (call array [binary_digit])
        %0 = scrutinee
        (arm
          (bind %0 Digits~0)))
      (call Num.FromBinaryDigits [Digits~0]))
  
  octal_integer =
    (seq result=1
      (match
        scrutinee: (call array [octal_digit])
        %0 = scrutinee
        (arm
          (bind %0 Digits~0)))
      (call Num.FromOctalDigits [Digits~0]))
  
  hex_integer =
    (seq result=1
      (match
        scrutinee: (call array [hex_digit])
        %0 = scrutinee
        (arm
          (bind %0 Digits~0)))
      (call Num.FromHexDigits [Digits~0]))
  
