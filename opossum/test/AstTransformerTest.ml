open Alcotest
open Opossum
open Opossum.Ast
open! Base

let check_transformed_ast (source : string) (expected : program) =
  let description = "Can transform\n" ^ source in
  let actual = source |> ProgramParser.parse |> AstTransformer.transform in
  (check (of_pp pp_program)) description expected actual

let test_tabular () =
  let input =
    {program|
    tabular(Headers, Rows) = (
      [Row, ...Rs] <- const(Rows) &
      RowObject <- zip_pairs(Headers, Row) &
      Rest <- tabular(Headers, Rs) $
      [RowObject, ...RowRest]
    ) | const([]) ;

    zip_pairs(Keys, Values) = (
      [K, ...Ks] <- const(Keys) &
      [V, ...Vs] <- const(Values) &
      Rest <- zip_pairs(Ks, Vs) $
      {K: V, ...Rest}
    ) | const({}) ;

    table_sep = ws > "|" < ws ;

    Headers <- array_sep(word, table_sep) & newline &
    Rows <- array_sep(array_sep(number | word, table_sep), newline) &
    Table <- tabular(Headers, Rows) $
    Table
    |program}
  in
  let program : program =
    Ast.Program
      { main_parser =
          Some
            ( `Sequence
                ( [ `Destructure
                      ( `ValueId
                          ("Headers", { Program.start_pos = 417; end_pos = 424 })
                      , `ParserApply
                          ( `ParserId
                              ( "array_sep"
                              , { Program.start_pos = 428; end_pos = 437 } )
                          , [ `ParserArg
                                (`ParserApply
                                  ( `ParserId
                                      ( "word"
                                      , { Program.start_pos = 438
                                        ; end_pos = 442
                                        } )
                                  , []
                                  , { Program.start_pos = 438; end_pos = 442 }
                                  ))
                            ; `ParserArg
                                (`ParserApply
                                  ( `ParserId
                                      ( "table_sep"
                                      , { Program.start_pos = 444
                                        ; end_pos = 453
                                        } )
                                  , []
                                  , { Program.start_pos = 444; end_pos = 453 }
                                  ))
                            ]
                          , { Program.start_pos = 428; end_pos = 454 } )
                      , { Program.start_pos = 417; end_pos = 454 } )
                  ; `ParserApply
                      ( `ParserId
                          ("newline", { Program.start_pos = 457; end_pos = 464 })
                      , []
                      , { Program.start_pos = 457; end_pos = 464 } )
                  ; `Destructure
                      ( `ValueId
                          ("Rows", { Program.start_pos = 471; end_pos = 475 })
                      , `ParserApply
                          ( `ParserId
                              ( "array_sep"
                              , { Program.start_pos = 479; end_pos = 488 } )
                          , [ `ParserArg
                                (`ParserApply
                                  ( `ParserId
                                      ( "array_sep"
                                      , { Program.start_pos = 489
                                        ; end_pos = 498
                                        } )
                                  , [ `ParserArg
                                        (`Or
                                          ( `ParserApply
                                              ( `ParserId
                                                  ( "number"
                                                  , { Program.start_pos = 499
                                                    ; end_pos = 505
                                                    } )
                                              , []
                                              , { Program.start_pos = 499
                                                ; end_pos = 505
                                                } )
                                          , `ParserApply
                                              ( `ParserId
                                                  ( "word"
                                                  , { Program.start_pos = 508
                                                    ; end_pos = 512
                                                    } )
                                              , []
                                              , { Program.start_pos = 508
                                                ; end_pos = 512
                                                } )
                                          , { Program.start_pos = 499
                                            ; end_pos = 512
                                            } ))
                                    ; `ParserArg
                                        (`ParserApply
                                          ( `ParserId
                                              ( "table_sep"
                                              , { Program.start_pos = 514
                                                ; end_pos = 523
                                                } )
                                          , []
                                          , { Program.start_pos = 514
                                            ; end_pos = 523
                                            } ))
                                    ]
                                  , { Program.start_pos = 489; end_pos = 524 }
                                  ))
                            ; `ParserArg
                                (`ParserApply
                                  ( `ParserId
                                      ( "newline"
                                      , { Program.start_pos = 526
                                        ; end_pos = 533
                                        } )
                                  , []
                                  , { Program.start_pos = 526; end_pos = 533 }
                                  ))
                            ]
                          , { Program.start_pos = 479; end_pos = 534 } )
                      , { Program.start_pos = 471; end_pos = 534 } )
                  ; `Destructure
                      ( `ValueId
                          ("Table", { Program.start_pos = 541; end_pos = 546 })
                      , `ParserApply
                          ( `ParserId
                              ( "tabular"
                              , { Program.start_pos = 550; end_pos = 557 } )
                          , [ `ValueArg
                                (`ValueId
                                  ( "Headers"
                                  , { Program.start_pos = 558; end_pos = 565 }
                                  ))
                            ; `ValueArg
                                (`ValueId
                                  ( "Rows"
                                  , { Program.start_pos = 567; end_pos = 571 }
                                  ))
                            ]
                          , { Program.start_pos = 550; end_pos = 572 } )
                      , { Program.start_pos = 541; end_pos = 572 } )
                  ]
                , `ValueId ("Table", { Program.start_pos = 579; end_pos = 584 })
                , { Program.start_pos = 417; end_pos = 584 } )
            , { Program.start_pos = 417; end_pos = 584 } )
      ; named_parsers =
          [ ( `ParserId ("tabular", { Program.start_pos = 5; end_pos = 12 })
            , [ `ValueId ("Headers", { Program.start_pos = 13; end_pos = 20 })
              ; `ValueId ("Rows", { Program.start_pos = 22; end_pos = 26 })
              ]
            , `Or
                ( `Sequence
                    ( [ `Destructure
                          ( `PatternArray
                              ( [ `PatternArrayElement
                                    ( `ValueId
                                        ( "Row"
                                        , { Program.start_pos = 39
                                          ; end_pos = 42
                                          } )
                                    , { Program.start_pos = 39; end_pos = 42 }
                                    )
                                ; `PatternArraySpread
                                    ( `ValueId
                                        ( "Rs"
                                        , { Program.start_pos = 47
                                          ; end_pos = 49
                                          } )
                                    , { Program.start_pos = 44; end_pos = 49 }
                                    )
                                ]
                              , { Program.start_pos = 38; end_pos = 50 } )
                          , `ParserApply
                              ( `ParserId
                                  ( "const"
                                  , { Program.start_pos = 54; end_pos = 59 } )
                              , [ `ValueArg
                                    (`ValueId
                                      ( "Rows"
                                      , { Program.start_pos = 60; end_pos = 64 }
                                      ))
                                ]
                              , { Program.start_pos = 54; end_pos = 65 } )
                          , { Program.start_pos = 38; end_pos = 65 } )
                      ; `Destructure
                          ( `ValueId
                              ( "RowObject"
                              , { Program.start_pos = 74; end_pos = 83 } )
                          , `ParserApply
                              ( `ParserId
                                  ( "zip_pairs"
                                  , { Program.start_pos = 87; end_pos = 96 } )
                              , [ `ValueArg
                                    (`ValueId
                                      ( "Headers"
                                      , { Program.start_pos = 97
                                        ; end_pos = 104
                                        } ))
                                ; `ValueArg
                                    (`ValueId
                                      ( "Row"
                                      , { Program.start_pos = 106
                                        ; end_pos = 109
                                        } ))
                                ]
                              , { Program.start_pos = 87; end_pos = 110 } )
                          , { Program.start_pos = 74; end_pos = 110 } )
                      ; `Destructure
                          ( `ValueId
                              ( "Rest"
                              , { Program.start_pos = 119; end_pos = 123 } )
                          , `ParserApply
                              ( `ParserId
                                  ( "tabular"
                                  , { Program.start_pos = 127; end_pos = 134 }
                                  )
                              , [ `ValueArg
                                    (`ValueId
                                      ( "Headers"
                                      , { Program.start_pos = 135
                                        ; end_pos = 142
                                        } ))
                                ; `ValueArg
                                    (`ValueId
                                      ( "Rs"
                                      , { Program.start_pos = 144
                                        ; end_pos = 146
                                        } ))
                                ]
                              , { Program.start_pos = 127; end_pos = 147 } )
                          , { Program.start_pos = 119; end_pos = 147 } )
                      ]
                    , `ValueArray
                        ( [ `ValueArrayElement
                              ( `ValueId
                                  ( "RowObject"
                                  , { Program.start_pos = 157; end_pos = 166 }
                                  )
                              , { Program.start_pos = 157; end_pos = 166 } )
                          ; `ValueArraySpread
                              ( `ValueId
                                  ( "RowRest"
                                  , { Program.start_pos = 171; end_pos = 178 }
                                  )
                              , { Program.start_pos = 168; end_pos = 178 } )
                          ]
                        , { Program.start_pos = 156; end_pos = 179 } )
                    , { Program.start_pos = 38; end_pos = 179 } )
                , `ParserApply
                    ( `ParserId
                        ("const", { Program.start_pos = 188; end_pos = 193 })
                    , [ `ValueArg
                          (`ValueArray
                            ([], { Program.start_pos = 194; end_pos = 196 }))
                      ]
                    , { Program.start_pos = 188; end_pos = 197 } )
                , { Program.start_pos = 30; end_pos = 197 } )
            , { Program.start_pos = 5; end_pos = 197 } )
          ; ( `ParserId ("zip_pairs", { Program.start_pos = 205; end_pos = 214 })
            , [ `ValueId ("Keys", { Program.start_pos = 215; end_pos = 219 })
              ; `ValueId ("Values", { Program.start_pos = 221; end_pos = 227 })
              ]
            , `Or
                ( `Sequence
                    ( [ `Destructure
                          ( `PatternArray
                              ( [ `PatternArrayElement
                                    ( `ValueId
                                        ( "K"
                                        , { Program.start_pos = 240
                                          ; end_pos = 241
                                          } )
                                    , { Program.start_pos = 240; end_pos = 241 }
                                    )
                                ; `PatternArraySpread
                                    ( `ValueId
                                        ( "Ks"
                                        , { Program.start_pos = 246
                                          ; end_pos = 248
                                          } )
                                    , { Program.start_pos = 243; end_pos = 248 }
                                    )
                                ]
                              , { Program.start_pos = 239; end_pos = 249 } )
                          , `ParserApply
                              ( `ParserId
                                  ( "const"
                                  , { Program.start_pos = 253; end_pos = 258 }
                                  )
                              , [ `ValueArg
                                    (`ValueId
                                      ( "Keys"
                                      , { Program.start_pos = 259
                                        ; end_pos = 263
                                        } ))
                                ]
                              , { Program.start_pos = 253; end_pos = 264 } )
                          , { Program.start_pos = 239; end_pos = 264 } )
                      ; `Destructure
                          ( `PatternArray
                              ( [ `PatternArrayElement
                                    ( `ValueId
                                        ( "V"
                                        , { Program.start_pos = 274
                                          ; end_pos = 275
                                          } )
                                    , { Program.start_pos = 274; end_pos = 275 }
                                    )
                                ; `PatternArraySpread
                                    ( `ValueId
                                        ( "Vs"
                                        , { Program.start_pos = 280
                                          ; end_pos = 282
                                          } )
                                    , { Program.start_pos = 277; end_pos = 282 }
                                    )
                                ]
                              , { Program.start_pos = 273; end_pos = 283 } )
                          , `ParserApply
                              ( `ParserId
                                  ( "const"
                                  , { Program.start_pos = 287; end_pos = 292 }
                                  )
                              , [ `ValueArg
                                    (`ValueId
                                      ( "Values"
                                      , { Program.start_pos = 293
                                        ; end_pos = 299
                                        } ))
                                ]
                              , { Program.start_pos = 287; end_pos = 300 } )
                          , { Program.start_pos = 273; end_pos = 300 } )
                      ; `Destructure
                          ( `ValueId
                              ( "Rest"
                              , { Program.start_pos = 309; end_pos = 313 } )
                          , `ParserApply
                              ( `ParserId
                                  ( "zip_pairs"
                                  , { Program.start_pos = 317; end_pos = 326 }
                                  )
                              , [ `ValueArg
                                    (`ValueId
                                      ( "Ks"
                                      , { Program.start_pos = 327
                                        ; end_pos = 329
                                        } ))
                                ; `ValueArg
                                    (`ValueId
                                      ( "Vs"
                                      , { Program.start_pos = 331
                                        ; end_pos = 333
                                        } ))
                                ]
                              , { Program.start_pos = 317; end_pos = 334 } )
                          , { Program.start_pos = 309; end_pos = 334 } )
                      ]
                    , `ValueObject
                        ( [ `ValueObjectPair
                              ( `ValueId
                                  ( "K"
                                  , { Program.start_pos = 344; end_pos = 345 }
                                  )
                              , `ValueId
                                  ( "V"
                                  , { Program.start_pos = 347; end_pos = 348 }
                                  )
                              , { Program.start_pos = 344; end_pos = 348 } )
                          ; `ValueObjectSpread
                              ( `ValueId
                                  ( "Rest"
                                  , { Program.start_pos = 353; end_pos = 357 }
                                  )
                              , { Program.start_pos = 350; end_pos = 357 } )
                          ]
                        , { Program.start_pos = 343; end_pos = 358 } )
                    , { Program.start_pos = 239; end_pos = 358 } )
                , `ParserApply
                    ( `ParserId
                        ("const", { Program.start_pos = 367; end_pos = 372 })
                    , [ `ValueArg
                          (`ValueObject
                            ([], { Program.start_pos = 373; end_pos = 375 }))
                      ]
                    , { Program.start_pos = 367; end_pos = 376 } )
                , { Program.start_pos = 231; end_pos = 376 } )
            , { Program.start_pos = 205; end_pos = 376 } )
          ; ( `ParserId ("table_sep", { Program.start_pos = 384; end_pos = 393 })
            , []
            , `TakeRight
                ( `ParserApply
                    ( `ParserId
                        ("ws", { Program.start_pos = 396; end_pos = 398 })
                    , []
                    , { Program.start_pos = 396; end_pos = 398 } )
                , `TakeLeft
                    ( `String ("|", { Program.start_pos = 401; end_pos = 404 })
                    , `ParserApply
                        ( `ParserId
                            ("ws", { Program.start_pos = 407; end_pos = 409 })
                        , []
                        , { Program.start_pos = 407; end_pos = 409 } )
                    , { Program.start_pos = 401; end_pos = 409 } )
                , { Program.start_pos = 396; end_pos = 409 } )
            , { Program.start_pos = 384; end_pos = 409 } )
          ]
      }
  in
  check_transformed_ast input program

let () =
  Alcotest.run "AST Tranformer"
    [ ("programs", [ test_case "tabular" `Quick test_tabular ]) ]
