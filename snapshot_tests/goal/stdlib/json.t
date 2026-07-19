Full created-stage goal form of stdlib/json.

  $ export PRINT_GOAL_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/json.possum -i '' --no-stdlib
  value =
    (alt
      (arm
        guard: (call boolean))
      (arm
        guard: (call null))
      (arm
        guard: (call number))
      (arm
        guard: (call string))
      (arm
        guard: (call array [value]))
      (arm
        body: (call object [value])))
  
  boolean =
    (call _@import0 ["true" "false"])
  
  null =
    (call _@import1 ["null"])
  
  string =
    (seq result=0
      (seq result=1
        (call """)
        (call _string_body))
      (call """))
  
  _string_body =
    (alt
      (arm
        guard: (call many [
          (lambda @fn0
            (alt
              (arm
                guard: (call _escaped_ctrl_char))
              (arm
                guard: (call _escaped_unicode))
              (arm
                body: (call unless [
                  char
                  (lambda @fn1
                    (alt
                      (arm
                        guard: (call ctrl_char))
                      (arm
                        guard: (call "\"))
                      (arm
                        body: (call """))))
                ]))))
        ]))
      (arm
        body: (call const [""])))
  
  _escaped_ctrl_char =
    (alt
      (arm
        guard: (seq result=1
          (call "\"")
          """))
      (arm
        guard: (seq result=1
          (call "\\")
          "\"))
      (arm
        guard: (seq result=1
          (call "\/")
          "/"))
      (arm
        guard: (seq result=1
          (call "\b")
          "\x08")) (esc)
      (arm
        guard: (seq result=1
          (call "\f")
          "\x0c")) (esc)
      (arm
        guard: (seq result=1
          (call "\n")
          "
  "))
      (arm
        guard: (seq result=1
          (call "\r")
          "\r (no-eol) (esc)
  "))
      (arm
        body: (seq result=1
          (call "\t")
          "\t"))) (esc)
  
  _escaped_unicode =
    (alt
      (arm
        guard: (call _escaped_surrogate_pair))
      (arm
        body: (call _escaped_codepoint)))
  
  _escaped_surrogate_pair =
    (alt
      (arm
        guard: (call _valid_surrogate_pair))
      (arm
        body: (call _invalid_surrogate_pair)))
  
  _valid_surrogate_pair =
    (seq result=1
      (match
        scrutinee: (call _high_surrogate)
        %0 = scrutinee
        (arm
          (local %0 H)))
      (seq result=1
        (match
          scrutinee: (call _low_surrogate)
          %0 = scrutinee
          (arm
            (local %0 L)))
        (call @SurrogatePairCodepoint [H L])))
  
  _invalid_surrogate_pair =
    (seq result=1
      (alt
        (arm
          guard: (call _low_surrogate))
        (arm
          body: (call _high_surrogate)))
      "\xef\xbf\xbd") (esc)
  
  _high_surrogate =
    (merge
      (merge
        (merge
          (seq result=1
            (call "\u")
            (alt
              (arm
                guard: (call "D"))
              (arm
                body: (call "d"))))
          (alt
            (arm
              guard: (call "8"))
            (arm
              guard: (call "9"))
            (arm
              guard: (call "A"))
            (arm
              guard: (call "B"))
            (arm
              guard: (call "a"))
            (arm
              body: (call "b"))))
        (call hex_numeral))
      (call hex_numeral))
  
  _low_surrogate =
    (merge
      (merge
        (merge
          (seq result=1
            (call "\u")
            (alt
              (arm
                guard: (call "D"))
              (arm
                body: (call "d"))))
          (alt
            (arm
              guard: (call (range "C" "F")))
            (arm
              body: (call (range "c" "f")))))
        (call hex_numeral))
      (call hex_numeral))
  
  _escaped_codepoint =
    (seq result=1
      (match
        scrutinee: (seq result=1
          (call "\u")
          (repeat
            body: (call hex_numeral)
            cap: 4
            count: (set
              %0 = scrutinee
              (eq_const %0 4))))
        %0 = scrutinee
        (arm
          (local %0 U)))
      (call @Codepoint [U]))
  
  array(elem) =
    (seq result=0
      (seq result=1
        (call "[")
        (call _@import2 [
          (lambda @fn2
            (call surround [
              elem
              (lambda @fn3
                (call maybe [ws]))
            ]))
          ","
        ]))
      (call "]"))
  
  object(value) =
    (seq result=0
      (seq result=1
        (call "{")
        (call _@import3 [
          (lambda @fn4
            (call surround [
              string
              (lambda @fn5
                (call maybe [ws]))
            ]))
          ":"
          (lambda @fn6
            (call surround [
              value
              (lambda @fn7
                (call maybe [ws]))
            ]))
          ","
        ]))
      (call "}"))
  
  main =
    (call value)
