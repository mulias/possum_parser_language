open Alcotest
open Opossum
open Opossum.Ast
open! Base

let parse = ProgramParser.parse `Parser

let check_program_ast (source : string) (expected : permissive_program) =
  let description = "Can parse\n" ^ source in
  (check (of_pp pp_permissive_program)) description expected (parse source)

let test_number () =
  let program = "0" in
  let ast : permissive_program =
    `Program
      [ `MainParser
          (`Intlit ("0", { source = `Parser; start_pos = 0; end_pos = 1 }), [])
      ]
  in
  check_program_ast program ast

let test_string () =
  let program = {program|"a"|program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          (`String ("a", { source = `Parser; start_pos = 0; end_pos = 3 }), [])
      ]
  in
  check_program_ast program ast

let test_string_whitespace () =
  let program = {program|   "a"   |program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          (`String ("a", { source = `Parser; start_pos = 3; end_pos = 6 }), [])
      ]
  in
  check_program_ast program ast

let test_empty_string () =
  let program = "''" in
  let ast : permissive_program =
    `Program
      [ `MainParser
          (`String ("", { source = `Parser; start_pos = 0; end_pos = 2 }), [])
      ]
  in
  check_program_ast program ast

let test_string_with_escaped_double_quote () =
  let program = {program|"\""|program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `String ({s|"|s}, { source = `Parser; start_pos = 0; end_pos = 4 })
          , [] )
      ]
  in
  check_program_ast program ast

let test_string_with_escaped_single_quote () =
  let program = {program|'\''|program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          (`String ("'", { source = `Parser; start_pos = 0; end_pos = 4 }), [])
      ]
  in
  check_program_ast program ast

let test_string_with_escaped_backslash () =
  let program = {program|"\\"|program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `String ({s|\|s}, { source = `Parser; start_pos = 0; end_pos = 4 })
          , [] )
      ]
  in
  check_program_ast program ast

let test_string_with_escaped_quotes_and_backslashes () =
  let program = {program|"\\\"\"\\\\\"\\"|program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `String
              ({s|\""\\"\|s}, { source = `Parser; start_pos = 0; end_pos = 16 })
          , [] )
      ]
  in
  check_program_ast program ast

let test_regex_pattern () =
  let program = "/[a-z]+/" in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `Regex ("[a-z]+", { source = `Parser; start_pos = 0; end_pos = 8 })
          , [] )
      ]
  in
  check_program_ast program ast

let test_regex_pattern_with_escaped_slash () =
  let program = {program|/[a-z]+\/[0-9]*/|program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `Regex
              ( {s|[a-z]+\/[0-9]*|s}
              , { source = `Parser; start_pos = 0; end_pos = 16 } )
          , [] )
      ]
  in
  check_program_ast program ast

let test_parser_apply () =
  let program = {program|field( "a"  , 1,2,  3 )|program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `ParserApply
              ( `ParserId
                  ("field", { source = `Parser; start_pos = 0; end_pos = 5 })
              , [ ( `String
                      ("a", { source = `Parser; start_pos = 7; end_pos = 10 })
                  , [] )
                ; ( `Intlit
                      ("1", { source = `Parser; start_pos = 14; end_pos = 15 })
                  , [] )
                ; ( `Intlit
                      ("2", { source = `Parser; start_pos = 16; end_pos = 17 })
                  , [] )
                ; ( `Intlit
                      ("3", { source = `Parser; start_pos = 20; end_pos = 21 })
                  , [] )
                ]
              , { source = `Parser; start_pos = 0; end_pos = 23 } )
          , [] )
      ]
  in
  check_program_ast program ast

let test_parser_def () =
  let program = "field = 1 ; field" in
  let ast : permissive_program =
    `Program
      [ `NamedParser
          ( `ParserId ("field", { source = `Parser; start_pos = 0; end_pos = 5 })
          , []
          , (`Intlit ("1", { source = `Parser; start_pos = 8; end_pos = 9 }), [])
          )
      ; `MainParser
          ( `ParserApply
              ( `ParserId
                  ("field", { source = `Parser; start_pos = 12; end_pos = 17 })
              , []
              , { source = `Parser; start_pos = 12; end_pos = 17 } )
          , [] )
      ]
  in
  check_program_ast program ast

let test_infix_or () =
  let program = "1 | 2 | 3" in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `Intlit ("1", { source = `Parser; start_pos = 0; end_pos = 1 })
          , [ ( `Or
              , `Intlit ("2", { source = `Parser; start_pos = 4; end_pos = 5 })
              )
            ; ( `Or
              , `Intlit ("3", { source = `Parser; start_pos = 8; end_pos = 9 })
              )
            ] )
      ]
  in
  check_program_ast program ast

let test_infix_and_program () =
  let program =
    {parser|
    bingo_numbers = array_sep(int, ',') ;
    bingo_board_line = array_sep(int, spaces) ;
    bingo_board = array_sep(bingo_board_line, newline) ;
    bingo_boards = array_sep(bingo_board, newline) ;

    Numbers <- whitespace > bingo_numbers &
    Boards <- whitespace > bingo_boards $
    {'numbers': Numbers, 'boards': Boards}
    < whitespace < end
    |parser}
  in
  let ast : permissive_program =
    `Program
      [ `NamedParser
          ( `ParserId
              ( "bingo_numbers"
              , { source = `Parser; start_pos = 5; end_pos = 18 } )
          , []
          , ( `ParserApply
                ( `ParserId
                    ( "array_sep"
                    , { source = `Parser; start_pos = 21; end_pos = 30 } )
                , [ ( `ParserApply
                        ( `ParserId
                            ( "int"
                            , { source = `Parser; start_pos = 31; end_pos = 34 }
                            )
                        , []
                        , { source = `Parser; start_pos = 31; end_pos = 34 } )
                    , [] )
                  ; ( `String
                        (",", { source = `Parser; start_pos = 36; end_pos = 39 })
                    , [] )
                  ]
                , { source = `Parser; start_pos = 21; end_pos = 40 } )
            , [] ) )
      ; `NamedParser
          ( `ParserId
              ( "bingo_board_line"
              , { source = `Parser; start_pos = 47; end_pos = 63 } )
          , []
          , ( `ParserApply
                ( `ParserId
                    ( "array_sep"
                    , { source = `Parser; start_pos = 66; end_pos = 75 } )
                , [ ( `ParserApply
                        ( `ParserId
                            ( "int"
                            , { source = `Parser; start_pos = 76; end_pos = 79 }
                            )
                        , []
                        , { source = `Parser; start_pos = 76; end_pos = 79 } )
                    , [] )
                  ; ( `ParserApply
                        ( `ParserId
                            ( "spaces"
                            , { source = `Parser; start_pos = 81; end_pos = 87 }
                            )
                        , []
                        , { source = `Parser; start_pos = 81; end_pos = 87 } )
                    , [] )
                  ]
                , { source = `Parser; start_pos = 66; end_pos = 88 } )
            , [] ) )
      ; `NamedParser
          ( `ParserId
              ( "bingo_board"
              , { source = `Parser; start_pos = 95; end_pos = 106 } )
          , []
          , ( `ParserApply
                ( `ParserId
                    ( "array_sep"
                    , { source = `Parser; start_pos = 109; end_pos = 118 } )
                , [ ( `ParserApply
                        ( `ParserId
                            ( "bingo_board_line"
                            , { source = `Parser
                              ; start_pos = 119
                              ; end_pos = 135
                              } )
                        , []
                        , { source = `Parser; start_pos = 119; end_pos = 135 }
                        )
                    , [] )
                  ; ( `ParserApply
                        ( `ParserId
                            ( "newline"
                            , { source = `Parser
                              ; start_pos = 137
                              ; end_pos = 144
                              } )
                        , []
                        , { source = `Parser; start_pos = 137; end_pos = 144 }
                        )
                    , [] )
                  ]
                , { source = `Parser; start_pos = 109; end_pos = 145 } )
            , [] ) )
      ; `NamedParser
          ( `ParserId
              ( "bingo_boards"
              , { source = `Parser; start_pos = 152; end_pos = 164 } )
          , []
          , ( `ParserApply
                ( `ParserId
                    ( "array_sep"
                    , { source = `Parser; start_pos = 167; end_pos = 176 } )
                , [ ( `ParserApply
                        ( `ParserId
                            ( "bingo_board"
                            , { source = `Parser
                              ; start_pos = 177
                              ; end_pos = 188
                              } )
                        , []
                        , { source = `Parser; start_pos = 177; end_pos = 188 }
                        )
                    , [] )
                  ; ( `ParserApply
                        ( `ParserId
                            ( "newline"
                            , { source = `Parser
                              ; start_pos = 190
                              ; end_pos = 197
                              } )
                        , []
                        , { source = `Parser; start_pos = 190; end_pos = 197 }
                        )
                    , [] )
                  ]
                , { source = `Parser; start_pos = 167; end_pos = 198 } )
            , [] ) )
      ; `MainParser
          ( `ValueId
              ("Numbers", { source = `Parser; start_pos = 206; end_pos = 213 })
          , [ ( `Destructure
              , `ParserApply
                  ( `ParserId
                      ( "whitespace"
                      , { source = `Parser; start_pos = 217; end_pos = 227 } )
                  , []
                  , { source = `Parser; start_pos = 217; end_pos = 227 } ) )
            ; ( `TakeRight
              , `ParserApply
                  ( `ParserId
                      ( "bingo_numbers"
                      , { source = `Parser; start_pos = 230; end_pos = 243 } )
                  , []
                  , { source = `Parser; start_pos = 230; end_pos = 243 } ) )
            ; ( `And
              , `ValueId
                  ( "Boards"
                  , { source = `Parser; start_pos = 250; end_pos = 256 } ) )
            ; ( `Destructure
              , `ParserApply
                  ( `ParserId
                      ( "whitespace"
                      , { source = `Parser; start_pos = 260; end_pos = 270 } )
                  , []
                  , { source = `Parser; start_pos = 260; end_pos = 270 } ) )
            ; ( `TakeRight
              , `ParserApply
                  ( `ParserId
                      ( "bingo_boards"
                      , { source = `Parser; start_pos = 273; end_pos = 285 } )
                  , []
                  , { source = `Parser; start_pos = 273; end_pos = 285 } ) )
            ; ( `Return
              , `ValueLikeObject
                  ( [ `ValueLikeObjectPair
                        ( `String
                            ( "numbers"
                            , { source = `Parser
                              ; start_pos = 293
                              ; end_pos = 302
                              } )
                        , `ValueId
                            ( "Numbers"
                            , { source = `Parser
                              ; start_pos = 304
                              ; end_pos = 311
                              } )
                        , { source = `Parser; start_pos = 293; end_pos = 311 }
                        )
                    ; `ValueLikeObjectPair
                        ( `String
                            ( "boards"
                            , { source = `Parser
                              ; start_pos = 313
                              ; end_pos = 321
                              } )
                        , `ValueId
                            ( "Boards"
                            , { source = `Parser
                              ; start_pos = 323
                              ; end_pos = 329
                              } )
                        , { source = `Parser; start_pos = 313; end_pos = 329 }
                        )
                    ]
                  , { source = `Parser; start_pos = 292; end_pos = 330 } ) )
            ; ( `TakeLeft
              , `ParserApply
                  ( `ParserId
                      ( "whitespace"
                      , { source = `Parser; start_pos = 337; end_pos = 347 } )
                  , []
                  , { source = `Parser; start_pos = 337; end_pos = 347 } ) )
            ; ( `TakeLeft
              , `ParserApply
                  ( `ParserId
                      ( "end"
                      , { source = `Parser; start_pos = 350; end_pos = 353 } )
                  , []
                  , { source = `Parser; start_pos = 350; end_pos = 353 } ) )
            ] )
      ]
  in
  check_program_ast program ast

let test_infix_and_return () =
  let program = "'a' $ []" in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `String ("a", { source = `Parser; start_pos = 0; end_pos = 3 })
          , [ ( `Return
              , `ValueLikeArray
                  ([], { source = `Parser; start_pos = 6; end_pos = 8 }) )
            ] )
      ]
  in
  check_program_ast program ast

let test_infix_and_assignment () =
  let program = "N <- number $ [N]" in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `ValueId ("N", { source = `Parser; start_pos = 0; end_pos = 1 })
          , [ ( `Destructure
              , `ParserApply
                  ( `ParserId
                      ( "number"
                      , { source = `Parser; start_pos = 5; end_pos = 11 } )
                  , []
                  , { source = `Parser; start_pos = 5; end_pos = 11 } ) )
            ; ( `Return
              , `ValueLikeArray
                  ( [ `ValueLikeArrayElement
                        ( `ValueId
                            ( "N"
                            , { source = `Parser; start_pos = 15; end_pos = 16 }
                            )
                        , { source = `Parser; start_pos = 15; end_pos = 16 } )
                    ]
                  , { source = `Parser; start_pos = 14; end_pos = 17 } ) )
            ] )
      ]
  in
  check_program_ast program ast

let test_infix_and_inside_parser () =
  let program =
    {parser|
    signal_patterns = array_sep(many(alpha), " ") ;

    input(
      array_sep(
        UniqueDigits <- signal_patterns & " | " & OutputDigits <- signal_patterns $
        {"unique": UniqueDigits, "output": OutputDigits},
        newline
      )
    )
    |parser}
  in
  let ast : permissive_program =
    `Program
      [ `NamedParser
          ( `ParserId
              ( "signal_patterns"
              , { source = `Parser; start_pos = 5; end_pos = 20 } )
          , []
          , ( `ParserApply
                ( `ParserId
                    ( "array_sep"
                    , { source = `Parser; start_pos = 23; end_pos = 32 } )
                , [ ( `ParserApply
                        ( `ParserId
                            ( "many"
                            , { source = `Parser; start_pos = 33; end_pos = 37 }
                            )
                        , [ ( `ParserApply
                                ( `ParserId
                                    ( "alpha"
                                    , { source = `Parser
                                      ; start_pos = 38
                                      ; end_pos = 43
                                      } )
                                , []
                                , { source = `Parser
                                  ; start_pos = 38
                                  ; end_pos = 43
                                  } )
                            , [] )
                          ]
                        , { source = `Parser; start_pos = 33; end_pos = 44 } )
                    , [] )
                  ; ( `String
                        (" ", { source = `Parser; start_pos = 46; end_pos = 49 })
                    , [] )
                  ]
                , { source = `Parser; start_pos = 23; end_pos = 50 } )
            , [] ) )
      ; `MainParser
          ( `ParserApply
              ( `ParserId
                  ("input", { source = `Parser; start_pos = 58; end_pos = 63 })
              , [ ( `ParserApply
                      ( `ParserId
                          ( "array_sep"
                          , { source = `Parser; start_pos = 71; end_pos = 80 }
                          )
                      , [ ( `ValueId
                              ( "UniqueDigits"
                              , { source = `Parser
                                ; start_pos = 90
                                ; end_pos = 102
                                } )
                          , [ ( `Destructure
                              , `ParserApply
                                  ( `ParserId
                                      ( "signal_patterns"
                                      , { source = `Parser
                                        ; start_pos = 106
                                        ; end_pos = 121
                                        } )
                                  , []
                                  , { source = `Parser
                                    ; start_pos = 106
                                    ; end_pos = 121
                                    } ) )
                            ; ( `And
                              , `String
                                  ( " | "
                                  , { source = `Parser
                                    ; start_pos = 124
                                    ; end_pos = 129
                                    } ) )
                            ; ( `And
                              , `ValueId
                                  ( "OutputDigits"
                                  , { source = `Parser
                                    ; start_pos = 132
                                    ; end_pos = 144
                                    } ) )
                            ; ( `Destructure
                              , `ParserApply
                                  ( `ParserId
                                      ( "signal_patterns"
                                      , { source = `Parser
                                        ; start_pos = 148
                                        ; end_pos = 163
                                        } )
                                  , []
                                  , { source = `Parser
                                    ; start_pos = 148
                                    ; end_pos = 163
                                    } ) )
                            ; ( `Return
                              , `ValueLikeObject
                                  ( [ `ValueLikeObjectPair
                                        ( `String
                                            ( "unique"
                                            , { source = `Parser
                                              ; start_pos = 175
                                              ; end_pos = 183
                                              } )
                                        , `ValueId
                                            ( "UniqueDigits"
                                            , { source = `Parser
                                              ; start_pos = 185
                                              ; end_pos = 197
                                              } )
                                        , { source = `Parser
                                          ; start_pos = 175
                                          ; end_pos = 197
                                          } )
                                    ; `ValueLikeObjectPair
                                        ( `String
                                            ( "output"
                                            , { source = `Parser
                                              ; start_pos = 199
                                              ; end_pos = 207
                                              } )
                                        , `ValueId
                                            ( "OutputDigits"
                                            , { source = `Parser
                                              ; start_pos = 209
                                              ; end_pos = 221
                                              } )
                                        , { source = `Parser
                                          ; start_pos = 199
                                          ; end_pos = 221
                                          } )
                                    ]
                                  , { source = `Parser
                                    ; start_pos = 174
                                    ; end_pos = 222
                                    } ) )
                            ] )
                        ; ( `ParserApply
                              ( `ParserId
                                  ( "newline"
                                  , { source = `Parser
                                    ; start_pos = 232
                                    ; end_pos = 239
                                    } )
                              , []
                              , { source = `Parser
                                ; start_pos = 232
                                ; end_pos = 239
                                } )
                          , [] )
                        ]
                      , { source = `Parser; start_pos = 71; end_pos = 247 } )
                  , [] )
                ]
              , { source = `Parser; start_pos = 58; end_pos = 253 } )
          , [] )
      ]
  in
  check_program_ast program ast

let test_array_spread () =
  let program = "'' $ [...A, 1, ...B]" in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `String ("", { source = `Parser; start_pos = 0; end_pos = 2 })
          , [ ( `Return
              , `ValueLikeArray
                  ( [ `ValueLikeArraySpread
                        ( `ValueId
                            ( "A"
                            , { source = `Parser; start_pos = 9; end_pos = 10 }
                            )
                        , { source = `Parser; start_pos = 6; end_pos = 10 } )
                    ; `ValueLikeArrayElement
                        ( `Intlit
                            ( "1"
                            , { source = `Parser; start_pos = 12; end_pos = 13 }
                            )
                        , { source = `Parser; start_pos = 12; end_pos = 13 } )
                    ; `ValueLikeArraySpread
                        ( `ValueId
                            ( "B"
                            , { source = `Parser; start_pos = 18; end_pos = 19 }
                            )
                        , { source = `Parser; start_pos = 15; end_pos = 19 } )
                    ]
                  , { source = `Parser; start_pos = 5; end_pos = 20 } ) )
            ] )
      ]
  in
  check_program_ast program ast

let test_object_pattern_match () =
  let program =
    "{'foo': _Foo, ...Rest} <- object_sep(many(alpha), '=', int, ws) $ Rest"
  in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `ValueLikeObject
              ( [ `ValueLikeObjectPair
                    ( `String
                        ("foo", { source = `Parser; start_pos = 1; end_pos = 6 })
                    , `ValueId
                        ( "_Foo"
                        , { source = `Parser; start_pos = 8; end_pos = 12 } )
                    , { source = `Parser; start_pos = 1; end_pos = 12 } )
                ; `ValueLikeObjectSpread
                    ( `ValueId
                        ( "Rest"
                        , { source = `Parser; start_pos = 17; end_pos = 21 } )
                    , { source = `Parser; start_pos = 14; end_pos = 21 } )
                ]
              , { source = `Parser; start_pos = 0; end_pos = 22 } )
          , [ ( `Destructure
              , `ParserApply
                  ( `ParserId
                      ( "object_sep"
                      , { source = `Parser; start_pos = 26; end_pos = 36 } )
                  , [ ( `ParserApply
                          ( `ParserId
                              ( "many"
                              , { source = `Parser
                                ; start_pos = 37
                                ; end_pos = 41
                                } )
                          , [ ( `ParserApply
                                  ( `ParserId
                                      ( "alpha"
                                      , { source = `Parser
                                        ; start_pos = 42
                                        ; end_pos = 47
                                        } )
                                  , []
                                  , { source = `Parser
                                    ; start_pos = 42
                                    ; end_pos = 47
                                    } )
                              , [] )
                            ]
                          , { source = `Parser; start_pos = 37; end_pos = 48 }
                          )
                      , [] )
                    ; ( `String
                          ( "="
                          , { source = `Parser; start_pos = 50; end_pos = 53 }
                          )
                      , [] )
                    ; ( `ParserApply
                          ( `ParserId
                              ( "int"
                              , { source = `Parser
                                ; start_pos = 55
                                ; end_pos = 58
                                } )
                          , []
                          , { source = `Parser; start_pos = 55; end_pos = 58 }
                          )
                      , [] )
                    ; ( `ParserApply
                          ( `ParserId
                              ( "ws"
                              , { source = `Parser
                                ; start_pos = 60
                                ; end_pos = 62
                                } )
                          , []
                          , { source = `Parser; start_pos = 60; end_pos = 62 }
                          )
                      , [] )
                    ]
                  , { source = `Parser; start_pos = 26; end_pos = 63 } ) )
            ; ( `Return
              , `ValueId
                  ("Rest", { source = `Parser; start_pos = 66; end_pos = 70 })
              )
            ] )
      ]
  in
  check_program_ast program ast

let test_comment_before () =
  let program = {program|
    # comment
    # comment
    123
  |program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          ( `Intlit ("123", { source = `Parser; start_pos = 33; end_pos = 36 })
          , [] )
      ]
  in
  check_program_ast program ast

let test_comment_same_line () =
  let program = {program|
    123 # comment
  |program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          (`Intlit ("123", { source = `Parser; start_pos = 5; end_pos = 8 }), [])
      ]
  in
  check_program_ast program ast

let test_comment_after () =
  let program = {program|
    123
    # comment
    # comment
  |program} in
  let ast : permissive_program =
    `Program
      [ `MainParser
          (`Intlit ("123", { source = `Parser; start_pos = 5; end_pos = 8 }), [])
      ]
  in
  check_program_ast program ast

let test_comments_everywhere () =
  let program =
    {program|
    # foo = "b"
    foo = "a" ; #comment2
    # comment 3
    123 ; # bar = 4
    # comment   4
    bar = 5 # comment5
    # comment6
  |program}
  in
  let ast : permissive_program =
    `Program
      [ `NamedParser
          ( `ParserId ("foo", { source = `Parser; start_pos = 21; end_pos = 24 })
          , []
          , ( `String ("a", { source = `Parser; start_pos = 27; end_pos = 30 })
            , [] ) )
      ; `MainParser
          ( `Intlit ("123", { source = `Parser; start_pos = 63; end_pos = 66 })
          , [] )
      ; `NamedParser
          ( `ParserId
              ("bar", { source = `Parser; start_pos = 101; end_pos = 104 })
          , []
          , ( `Intlit ("5", { source = `Parser; start_pos = 107; end_pos = 108 })
            , [] ) )
      ]
  in
  check_program_ast program ast

let () =
  Alcotest.run "Parser"
    [ ("number", [ test_case "Single digit" `Quick test_number ])
    ; ( "string"
      , [ test_case "Single character" `Quick test_string
        ; test_case "String with whitespace" `Quick test_string_whitespace
        ; test_case "Empty string" `Quick test_empty_string
        ; test_case "Escaped double quote" `Quick
            test_string_with_escaped_double_quote
        ; test_case "Escaped single quote" `Quick
            test_string_with_escaped_single_quote
        ; test_case "Escaped backslash" `Quick
            test_string_with_escaped_backslash
        ; test_case "Escaped quotes and backslashes" `Quick
            test_string_with_escaped_quotes_and_backslashes
        ] )
    ; ( "regex"
      , [ test_case "Basic pattern" `Quick test_regex_pattern
        ; test_case "Basic pattern" `Quick test_regex_pattern_with_escaped_slash
        ] )
    ; ("parser_apply", [ test_case "One arg" `Quick test_parser_apply ])
    ; ("parser_def", [ test_case "Single def" `Quick test_parser_def ])
    ; ("infix", [ test_case "`InfixBinary |" `Quick test_infix_or ])
    ; ( "infix and"
      , [ test_case "Multi line program" `Quick test_infix_and_program
        ; test_case "Empty parser with return" `Quick test_infix_and_return
        ; test_case "Assign variable" `Quick test_infix_and_assignment
        ; test_case "Array value spread" `Quick test_array_spread
        ; test_case "Pattern match object" `Quick test_object_pattern_match
        ; test_case "inside parser" `Quick test_infix_and_inside_parser
        ] )
    ; ( "comments"
      , [ test_case "Comment before parser" `Quick test_comment_before
        ; test_case "Comment on parser line" `Quick test_comment_same_line
        ; test_case "Comment after parser" `Quick test_comment_after
        ; test_case "Comments surrounding parser" `Quick
            test_comments_everywhere
        ] )
    ]
