Full created-stage goal form of stdlib/string.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/string.possum -i '' --no-stdlib
  char =
    (call (range "\x00" _)) (esc)
  
  ascii =
    (call (range "\x00" "\x7f")) (esc)
  
  alpha =
    (alt
      (arm
        guard: (call (range "a" "z")))
      (arm
        body: (call (range "A" "Z"))))
  
  alphas =
    (call many [alpha])
  
  lower =
    (call (range "a" "z"))
  
  lowers =
    (call many [lower])
  
  upper =
    (call (range "A" "Z"))
  
  uppers =
    (call many [upper])
  
  numeral =
    (call (range "0" "9"))
  
  numerals =
    (call many [numeral])
  
  binary_numeral =
    (alt
      (arm
        guard: (call "0"))
      (arm
        body: (call "1")))
  
  octal_numeral =
    (call (range "0" "7"))
  
  hex_numeral =
    (alt
      (arm
        guard: (call numeral))
      (arm
        guard: (call (range "a" "f")))
      (arm
        body: (call (range "A" "F"))))
  
  alnum =
    (alt
      (arm
        guard: (call alpha))
      (arm
        body: (call numeral)))
  
  alnums =
    (call many [alnum])
  
  token =
    (call many [
      (lambda @fn0
        (call unless [char whitespace]))
    ])
  
  word =
    (call many [
      (lambda @fn1
        (alt
          (arm
            guard: (call alnum))
          (arm
            guard: (call "_"))
          (arm
            body: (call "-"))))
    ])
  
  line =
    (call chars_until [
      (lambda @fn2
        (alt
          (arm
            guard: (call newline))
          (arm
            body: (call end_of_input))))
    ])
  
  space =
    (alt
      (arm
        guard: (call " "))
      (arm
        guard: (call "\t")) (esc)
      (arm
        guard: (call "\xc2\xa0")) (esc)
      (arm
        guard: (call (range "\xe2\x80\x80" "\xe2\x80\x8a"))) (esc)
      (arm
        guard: (call "\xe2\x80\xaf")) (esc)
      (arm
        guard: (call "\xe2\x81\x9f")) (esc)
      (arm
        body: (call "\xe3\x80\x80"))) (esc)
  
  spaces =
    (call many [space])
  
  newline =
    (alt
      (arm
        guard: (call "\r (esc)
  "))
      (arm
        guard: (call (range "
  " "\r (no-eol) (esc)
  ")))
      (arm
        guard: (call "\xc2\x85")) (esc)
      (arm
        guard: (call "\xe2\x80\xa8")) (esc)
      (arm
        body: (call "\xe2\x80\xa9"))) (esc)
  
  nl =
    (call newline)
  
  newlines =
    (call many [newline])
  
  nls =
    (call newlines)
  
  whitespace =
    (call many [
      (lambda @fn3
        (alt
          (arm
            guard: (call space))
          (arm
            body: (call newline))))
    ])
  
  ws =
    (call whitespace)
  
  chars_until(stop) =
    (call many_until [char stop~0])
  
  ctrl_char =
    (call (range "\x00" "\x1f")) (esc)
  
