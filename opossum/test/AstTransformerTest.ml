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

    zip_pairs(Names, Values) = (
      [N, ...Ns] <- const(Names) &
      [V, ...Vs] <- const(Values) &
      Rest <- zip_pairs(Ns, Vs) $
      {N: V, ...Rest}
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
          ( `Sequence
              ( [ ( Some
                      (`JsonId
                        ("Headers", { Program.start_pos = 419; end_pos = 426 }))
                  , `ParserApply
                      ( `ParserId
                          ( "array_sep"
                          , { Program.start_pos = 430; end_pos = 439 } )
                      , [ `ParserArg
                            (`ParserApply
                              ( `ParserId
                                  ( "word"
                                  , { Program.start_pos = 440; end_pos = 444 }
                                  )
                              , []
                              , { Program.start_pos = 440; end_pos = 444 } ))
                        ; `ParserArg
                            (`ParserApply
                              ( `ParserId
                                  ( "table_sep"
                                  , { Program.start_pos = 446; end_pos = 455 }
                                  )
                              , []
                              , { Program.start_pos = 446; end_pos = 455 } ))
                        ]
                      , { Program.start_pos = 430; end_pos = 456 } ) )
                ; ( None
                  , `ParserApply
                      ( `ParserId
                          ("newline", { Program.start_pos = 459; end_pos = 466 })
                      , []
                      , { Program.start_pos = 459; end_pos = 466 } ) )
                ; ( Some
                      (`JsonId
                        ("Rows", { Program.start_pos = 473; end_pos = 477 }))
                  , `ParserApply
                      ( `ParserId
                          ( "array_sep"
                          , { Program.start_pos = 481; end_pos = 490 } )
                      , [ `ParserArg
                            (`ParserApply
                              ( `ParserId
                                  ( "array_sep"
                                  , { Program.start_pos = 491; end_pos = 500 }
                                  )
                              , [ `ParserArg
                                    (`Or
                                      ( `ParserApply
                                          ( `ParserId
                                              ( "number"
                                              , { Program.start_pos = 501
                                                ; end_pos = 507
                                                } )
                                          , []
                                          , { Program.start_pos = 501
                                            ; end_pos = 507
                                            } )
                                      , `ParserApply
                                          ( `ParserId
                                              ( "word"
                                              , { Program.start_pos = 510
                                                ; end_pos = 514
                                                } )
                                          , []
                                          , { Program.start_pos = 510
                                            ; end_pos = 514
                                            } )
                                      , { Program.start_pos = 501
                                        ; end_pos = 514
                                        } ))
                                ; `ParserArg
                                    (`ParserApply
                                      ( `ParserId
                                          ( "table_sep"
                                          , { Program.start_pos = 516
                                            ; end_pos = 525
                                            } )
                                      , []
                                      , { Program.start_pos = 516
                                        ; end_pos = 525
                                        } ))
                                ]
                              , { Program.start_pos = 491; end_pos = 526 } ))
                        ; `ParserArg
                            (`ParserApply
                              ( `ParserId
                                  ( "newline"
                                  , { Program.start_pos = 528; end_pos = 535 }
                                  )
                              , []
                              , { Program.start_pos = 528; end_pos = 535 } ))
                        ]
                      , { Program.start_pos = 481; end_pos = 536 } ) )
                ; ( Some
                      (`JsonId
                        ("Table", { Program.start_pos = 543; end_pos = 548 }))
                  , `ParserApply
                      ( `ParserId
                          ("tabular", { Program.start_pos = 552; end_pos = 559 })
                      , [ `JsonArg
                            (`JsonId
                              ( "Headers"
                              , { Program.start_pos = 560; end_pos = 567 } ))
                        ; `JsonArg
                            (`JsonId
                              ( "Rows"
                              , { Program.start_pos = 569; end_pos = 573 } ))
                        ]
                      , { Program.start_pos = 552; end_pos = 574 } ) )
                ]
              , `JsonId ("Table", { Program.start_pos = 581; end_pos = 586 })
              , { Program.start_pos = 419; end_pos = 586 } )
          , { Program.start_pos = 419; end_pos = 586 } )
      ; named_parsers =
          [ ( `ParserId ("tabular", { Program.start_pos = 5; end_pos = 12 })
            , [ `JsonId ("Headers", { Program.start_pos = 13; end_pos = 20 })
              ; `JsonId ("Rows", { Program.start_pos = 22; end_pos = 26 })
              ]
            , `Or
                ( `Sequence
                    ( [ ( Some
                            (`JsonArray
                              ( [ `JsonArrayElement
                                    ( `JsonId
                                        ( "Row"
                                        , { Program.start_pos = 39
                                          ; end_pos = 42
                                          } )
                                    , { Program.start_pos = 39; end_pos = 42 }
                                    )
                                ; `JsonArraySpread
                                    ( `JsonId
                                        ( "Rs"
                                        , { Program.start_pos = 47
                                          ; end_pos = 49
                                          } )
                                    , { Program.start_pos = 44; end_pos = 49 }
                                    )
                                ]
                              , { Program.start_pos = 38; end_pos = 50 } ))
                        , `ParserApply
                            ( `ParserId
                                ( "const"
                                , { Program.start_pos = 54; end_pos = 59 } )
                            , [ `JsonArg
                                  (`JsonId
                                    ( "Rows"
                                    , { Program.start_pos = 60; end_pos = 64 }
                                    ))
                              ]
                            , { Program.start_pos = 54; end_pos = 65 } ) )
                      ; ( Some
                            (`JsonId
                              ( "RowObject"
                              , { Program.start_pos = 74; end_pos = 83 } ))
                        , `ParserApply
                            ( `ParserId
                                ( "zip_pairs"
                                , { Program.start_pos = 87; end_pos = 96 } )
                            , [ `JsonArg
                                  (`JsonId
                                    ( "Headers"
                                    , { Program.start_pos = 97; end_pos = 104 }
                                    ))
                              ; `JsonArg
                                  (`JsonId
                                    ( "Row"
                                    , { Program.start_pos = 106; end_pos = 109 }
                                    ))
                              ]
                            , { Program.start_pos = 87; end_pos = 110 } ) )
                      ; ( Some
                            (`JsonId
                              ( "Rest"
                              , { Program.start_pos = 119; end_pos = 123 } ))
                        , `ParserApply
                            ( `ParserId
                                ( "tabular"
                                , { Program.start_pos = 127; end_pos = 134 } )
                            , [ `JsonArg
                                  (`JsonId
                                    ( "Headers"
                                    , { Program.start_pos = 135; end_pos = 142 }
                                    ))
                              ; `JsonArg
                                  (`JsonId
                                    ( "Rs"
                                    , { Program.start_pos = 144; end_pos = 146 }
                                    ))
                              ]
                            , { Program.start_pos = 127; end_pos = 147 } ) )
                      ]
                    , `JsonArray
                        ( [ `JsonArrayElement
                              ( `JsonId
                                  ( "RowObject"
                                  , { Program.start_pos = 157; end_pos = 166 }
                                  )
                              , { Program.start_pos = 157; end_pos = 166 } )
                          ; `JsonArraySpread
                              ( `JsonId
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
                    , [ `JsonArg
                          (`JsonArray
                            ([], { Program.start_pos = 194; end_pos = 196 }))
                      ]
                    , { Program.start_pos = 188; end_pos = 197 } )
                , { Program.start_pos = 30; end_pos = 197 } )
            , { Program.start_pos = 5; end_pos = 197 } )
          ; ( `ParserId ("zip_pairs", { Program.start_pos = 205; end_pos = 214 })
            , [ `JsonId ("Names", { Program.start_pos = 215; end_pos = 220 })
              ; `JsonId ("Values", { Program.start_pos = 222; end_pos = 228 })
              ]
            , `Or
                ( `Sequence
                    ( [ ( Some
                            (`JsonArray
                              ( [ `JsonArrayElement
                                    ( `JsonId
                                        ( "N"
                                        , { Program.start_pos = 241
                                          ; end_pos = 242
                                          } )
                                    , { Program.start_pos = 241; end_pos = 242 }
                                    )
                                ; `JsonArraySpread
                                    ( `JsonId
                                        ( "Ns"
                                        , { Program.start_pos = 247
                                          ; end_pos = 249
                                          } )
                                    , { Program.start_pos = 244; end_pos = 249 }
                                    )
                                ]
                              , { Program.start_pos = 240; end_pos = 250 } ))
                        , `ParserApply
                            ( `ParserId
                                ( "const"
                                , { Program.start_pos = 254; end_pos = 259 } )
                            , [ `JsonArg
                                  (`JsonId
                                    ( "Names"
                                    , { Program.start_pos = 260; end_pos = 265 }
                                    ))
                              ]
                            , { Program.start_pos = 254; end_pos = 266 } ) )
                      ; ( Some
                            (`JsonArray
                              ( [ `JsonArrayElement
                                    ( `JsonId
                                        ( "V"
                                        , { Program.start_pos = 276
                                          ; end_pos = 277
                                          } )
                                    , { Program.start_pos = 276; end_pos = 277 }
                                    )
                                ; `JsonArraySpread
                                    ( `JsonId
                                        ( "Vs"
                                        , { Program.start_pos = 282
                                          ; end_pos = 284
                                          } )
                                    , { Program.start_pos = 279; end_pos = 284 }
                                    )
                                ]
                              , { Program.start_pos = 275; end_pos = 285 } ))
                        , `ParserApply
                            ( `ParserId
                                ( "const"
                                , { Program.start_pos = 289; end_pos = 294 } )
                            , [ `JsonArg
                                  (`JsonId
                                    ( "Values"
                                    , { Program.start_pos = 295; end_pos = 301 }
                                    ))
                              ]
                            , { Program.start_pos = 289; end_pos = 302 } ) )
                      ; ( Some
                            (`JsonId
                              ( "Rest"
                              , { Program.start_pos = 311; end_pos = 315 } ))
                        , `ParserApply
                            ( `ParserId
                                ( "zip_pairs"
                                , { Program.start_pos = 319; end_pos = 328 } )
                            , [ `JsonArg
                                  (`JsonId
                                    ( "Ns"
                                    , { Program.start_pos = 329; end_pos = 331 }
                                    ))
                              ; `JsonArg
                                  (`JsonId
                                    ( "Vs"
                                    , { Program.start_pos = 333; end_pos = 335 }
                                    ))
                              ]
                            , { Program.start_pos = 319; end_pos = 336 } ) )
                      ]
                    , `JsonObject
                        ( [ `JsonObjectPair
                              ( `JsonId
                                  ( "N"
                                  , { Program.start_pos = 346; end_pos = 347 }
                                  )
                              , `JsonId
                                  ( "V"
                                  , { Program.start_pos = 349; end_pos = 350 }
                                  )
                              , { Program.start_pos = 346; end_pos = 350 } )
                          ; `JsonObjectSpread
                              ( `JsonId
                                  ( "Rest"
                                  , { Program.start_pos = 355; end_pos = 359 }
                                  )
                              , { Program.start_pos = 352; end_pos = 359 } )
                          ]
                        , { Program.start_pos = 345; end_pos = 360 } )
                    , { Program.start_pos = 240; end_pos = 360 } )
                , `ParserApply
                    ( `ParserId
                        ("const", { Program.start_pos = 369; end_pos = 374 })
                    , [ `JsonArg
                          (`JsonObject
                            ([], { Program.start_pos = 375; end_pos = 377 }))
                      ]
                    , { Program.start_pos = 369; end_pos = 378 } )
                , { Program.start_pos = 232; end_pos = 378 } )
            , { Program.start_pos = 205; end_pos = 378 } )
          ; ( `ParserId ("table_sep", { Program.start_pos = 386; end_pos = 395 })
            , []
            , `TakeRight
                ( `ParserApply
                    ( `ParserId
                        ("ws", { Program.start_pos = 398; end_pos = 400 })
                    , []
                    , { Program.start_pos = 398; end_pos = 400 } )
                , `TakeLeft
                    ( `String ("|", { Program.start_pos = 403; end_pos = 406 })
                    , `ParserApply
                        ( `ParserId
                            ("ws", { Program.start_pos = 409; end_pos = 411 })
                        , []
                        , { Program.start_pos = 409; end_pos = 411 } )
                    , { Program.start_pos = 403; end_pos = 411 } )
                , { Program.start_pos = 398; end_pos = 411 } )
            , { Program.start_pos = 386; end_pos = 411 } )
          ]
      }
  in
  check_transformed_ast input program

let () =
  Alcotest.run "AST Tranformer"
    [ ("programs", [ test_case "tabular" `Quick test_tabular ]) ]
