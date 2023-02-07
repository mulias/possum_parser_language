open Alcotest
open Opossum
open Printf
open! Base

let eval (source : string) (input : string) : Program.value =
  let ast = source |> ProgramParser.parse `Parser |> AstTransformer.transform in
  let env = Env.init in
  let _ = PossumCore.load env in
  let _ = PossumStdlib.load env in
  let program = Evaluator.eval ast env |> Option.value_exn in
  Executor.execute program input

let check_eval (program : string) (input : string) (expected : Program.value) =
  let description = sprintf "Can parse\n%s\nwith program\n%s" input program in
  (check (of_pp Value.pp)) description expected (eval program input)

let check_eval_error (program : string) (input : string) (expected : exn) =
  let description =
    sprintf "Fail to parse\n%s\nwith program\n%s" input program
  in
  check_raises description expected (fun () ->
      let _ = eval program input in
      ())

let test_number () =
  let program = "0" in
  let input = "0" in
  let expected : Program.value = `Intlit "0" in
  check_eval program input expected

let test_negative_number () =
  let program = "-100" in
  let input = "-100" in
  let expected : Program.value = `Intlit "-100" in
  check_eval program input expected

let test_number_with_leading_zeros () =
  let program = "maybe(many('0')) > 1" in
  let input = "0000001" in
  let expected : Program.value = `Intlit "1" in
  check_eval program input expected

let test_big_number () =
  let program = "9999999999999999999999999999999999999" in
  let input = "9999999999999999999999999999999999999" in
  let expected : Program.value =
    `Intlit "9999999999999999999999999999999999999"
  in
  check_eval program input expected

let test_big_number_with_leading_zeros () =
  let program = "many('0') > 444444444444444444444444444444444" in
  let input = "000000444444444444444444444444444444444" in
  let expected : Program.value = `Intlit "444444444444444444444444444444444" in
  check_eval program input expected

let test_float () =
  let program = "12.123" in
  let input = "12.123" in
  let expected : Program.value = `Floatlit "12.123" in
  check_eval program input expected

let test_negative_float () =
  let program = "-0.99" in
  let input = "-0.99" in
  let expected : Program.value = `Floatlit "-0.99" in
  check_eval program input expected

let test_float_with_leading_zeros () =
  let program = "many('0') > 8.0" in
  let input = "00008.0" in
  let expected : Program.value = `Floatlit "8.0" in
  check_eval program input expected

let test_big_float () =
  let program = "9999999999999999999999999999999999999.9" in
  let input = "9999999999999999999999999999999999999.9" in
  let expected : Program.value =
    `Floatlit "9999999999999999999999999999999999999.9"
  in
  check_eval program input expected

let test_big_float_with_leading_zeros () =
  let program = "many('0') > 444444444444444444444444444444444.123" in
  let input = "000000444444444444444444444444444444444.123" in
  let expected : Program.value =
    `Floatlit "444444444444444444444444444444444.123"
  in
  check_eval program input expected

let test_string () =
  let program = "\"a\"" in
  let input = "a" in
  let expected : Program.value = `String "a" in
  check_eval program input expected

let test_parser_def () =
  let program = "field = 1 ; field" in
  let input = "1" in
  let expected : Program.value = `Intlit "1" in
  check_eval program input expected

let test_defs_as_args () =
  let program = "foo(a) = a(1) ; bar(a) = a ; foo(bar)" in
  let input = "1" in
  let expected : Program.value = `Intlit "1" in
  check_eval program input expected

let test_mutual_recursion () =
  let program = {parser|
  bar = foo ;
  foo = 1 | bar ;
  bar
  |parser} in
  let input = "1" in
  let expected : Program.value = `Intlit "1" in
  check_eval program input expected

let test_infix_or () =
  let program = "1 | 2 | 3" in
  let input = "2" in
  let expected : Program.value = `Intlit "2" in
  check_eval program input expected

let test_infix_take_left () =
  let program = "1 < 2 < 3" in
  let input = "123" in
  let expected : Program.value = `Intlit "1" in
  check_eval program input expected

let test_infix_take_right () =
  let program = "1 > 2 > 3" in
  let input = "123" in
  let expected : Program.value = `Intlit "3" in
  check_eval program input expected

let test_infix_concat () =
  let program = "'a' + 'b'" in
  let input = "ab" in
  let expected : Program.value = `String "ab" in
  check_eval program input expected

let test_stdlib () =
  let program = "array_sep(int, ws)" in
  let input = "1    2 2 33" in
  let expected : Program.value =
    `List [ `Intlit "1"; `Intlit "2"; `Intlit "2"; `Intlit "33" ]
  in
  check_eval program input expected

let test_infix_return () =
  let program = "'' $ [1, 2, 3]" in
  let input = "" in
  let expected : Program.value =
    `List [ `Intlit "1"; `Intlit "2"; `Intlit "3" ]
  in
  check_eval program input expected

let test_infix_and_assignment () =
  let program = "N <- int $ [N]" in
  let input = "2345" in
  let expected : Program.value = `List [ `Intlit "2345" ] in
  check_eval program input expected

let test_object_key_var () =
  let program = "X <- word $ {X: 1}" in
  let input = "foo" in
  let expected : Program.value = `Assoc [ ("foo", `Intlit "1") ] in
  check_eval program input expected

let test_array_pattern_match () =
  let program = "[_A, _B, ...C] <- array_sep(int, ',') $ C" in
  let input = "1,2,3,4,5" in
  let expected : Program.value =
    `List [ `Intlit "3"; `Intlit "4"; `Intlit "5" ]
  in
  check_eval program input expected

let test_object_pattern_match () =
  let program =
    "{'foo': _Foo, ...Rest} <- object_sep(many(alpha), '=', int, ws) $ Rest"
  in
  let input = "a=1 b=2 foo=3 foo=12" in
  let expected : Program.value =
    `Assoc [ ("a", `Intlit "1"); ("b", `Intlit "2") ]
  in
  check_eval program input expected

let test_bingo_parser () =
  let program =
    {parser|
    bingo_numbers = array_sep(int, ',') ;
    bingo_board_line = maybe(many(' ')) > array_sep(int, many(' ')) ;
    bingo_board = array_sep(bingo_board_line, newline) ;
    bingo_boards = array_sep(bingo_board, newline + newline) ;

    Numbers <- whitespace > bingo_numbers &
    Boards <- whitespace > bingo_boards $
    {'numbers': Numbers, 'boards': Boards}
    < whitespace < end
    |parser}
  in
  let input =
    {input|
    31,88,35

    50 83  3
    47  9 94
    61 22 53

    1 1 1
    1 1 1
    1 1 1
    |input}
  in
  let expected : Program.value =
    `Assoc
      [ ("numbers", `List [ `Intlit "31"; `Intlit "88"; `Intlit "35" ])
      ; ( "boards"
        , `List
            [ `List
                [ `List [ `Intlit "50"; `Intlit "83"; `Intlit "3" ]
                ; `List [ `Intlit "47"; `Intlit "9"; `Intlit "94" ]
                ; `List [ `Intlit "61"; `Intlit "22"; `Intlit "53" ]
                ]
            ; `List
                [ `List [ `Intlit "1"; `Intlit "1"; `Intlit "1" ]
                ; `List [ `Intlit "1"; `Intlit "1"; `Intlit "1" ]
                ; `List [ `Intlit "1"; `Intlit "1"; `Intlit "1" ]
                ]
            ] )
      ]
  in
  check_eval program input expected

let test_recursive_parsers () =
  let program =
    {parser|
    input(array_sep(maybe(ws) > snail_num, newline)) ;

    snail_num = int | snail_num_pair ;
    snail_num_pair = "[" & N1 <- snail_num & "," & N2 <- snail_num & "]" $ [N1, N2] ;
    |parser}
  in
  let input =
    {input|
    [[[[6,3],7],0],[[7,0],0]]
    [[[4,7],[6,[6,5]]],[4,[[6,5],[9,1]]]]
    |input}
  in
  let expected : Program.value =
    `List
      [ `List
          [ `List
              [ `List [ `List [ `Intlit "6"; `Intlit "3" ]; `Intlit "7" ]
              ; `Intlit "0"
              ]
          ; `List [ `List [ `Intlit "7"; `Intlit "0" ]; `Intlit "0" ]
          ]
      ; `List
          [ `List
              [ `List [ `Intlit "4"; `Intlit "7" ]
              ; `List [ `Intlit "6"; `List [ `Intlit "6"; `Intlit "5" ] ]
              ]
          ; `List
              [ `Intlit "4"
              ; `List
                  [ `List [ `Intlit "6"; `Intlit "5" ]
                  ; `List [ `Intlit "9"; `Intlit "1" ]
                  ]
              ]
          ]
      ]
  in
  check_eval program input expected

let test_env_scope_for_parser () =
  let program = "I <- int & X <- foo $ X ; foo = const(I)" in
  let input = "23" in
  let expected =
    Errors.EnvFindValue
      { id = "I"; source = `Parser; start_pos = 38; end_pos = 39 }
  in
  check_eval_error program input expected

let test_env_scope_for_sequence () =
  let program =
    {program|
    foo(p, A, B, C) = (A <- p) | (B <- p) | (C <- p) ;
    foo(digit, 1, 2, 3)
    |program}
  in
  let input = "2" in
  let expected = `Intlit "2" in
  check_eval program input expected

let test_env_scope_for_two_sequences () =
  let program = "(A <- int $ A) > ('' $ A)" in
  let input = "123" in
  let expected = `Intlit "123" in
  check_eval program input expected

let () =
  Alcotest.run "Evaluator"
    [ ( "number"
      , [ test_case "Single digit" `Quick test_number
        ; test_case "Negative" `Quick test_negative_number
        ; test_case "Leading zeros" `Quick test_number_with_leading_zeros
        ; test_case "Bigger than 64 bit int" `Quick test_big_number
        ; test_case "Big number with leading zeros" `Quick
            test_big_number_with_leading_zeros
        ; test_case "Float" `Quick test_float
        ; test_case "Negative float" `Quick test_negative_float
        ; test_case "Float with leading zeros" `Quick
            test_float_with_leading_zeros
        ; test_case "Big float" `Quick test_big_float
        ; test_case "Big float with leading zeros" `Quick
            test_big_float_with_leading_zeros
        ] )
    ; ("string", [ test_case "Single character" `Quick test_string ])
    ; ( "parser def"
      , [ test_case "Single def" `Quick test_parser_def
        ; test_case "Pass named defs as args" `Quick test_defs_as_args
        ; test_case "Mutually recursive defs" `Quick test_mutual_recursion
        ] )
    ; ( "infix"
      , [ test_case "InfixBinary |" `Quick test_infix_or
        ; test_case "InfixBinary <" `Quick test_infix_take_left
        ; test_case "InfixBinary >" `Quick test_infix_take_right
        ; test_case "InfixBinary +" `Quick test_infix_concat
          (* test_case "Infix normal precedence" `Quick *)
          (*   test_infix_normal_precedence; *)
          (* test_case "Infix group precedence" `Quick test_infix_group_precedence; *)
        ] )
    ; ( "standard library"
      , [ test_case "Access stdlib parsers" `Quick test_stdlib ] )
    ; ( "infix and"
      , [ test_case "Return array" `Quick test_infix_return
        ; test_case "Assign variable" `Quick test_infix_and_assignment
        ; test_case "var as object key" `Quick test_object_key_var
        ; test_case "Patten match array in assignment" `Quick
            test_array_pattern_match
        ; test_case "Patten match object in assignment" `Quick
            test_object_pattern_match
        ] )
    ; ( "programs"
      , [ test_case "Bingo boards" `Quick test_bingo_parser
        ; test_case "Snail numbers" `Quick test_recursive_parsers
        ] )
    ; ( "env"
      , [ test_case "Env scope excludes sequence assigns in named parser" `Quick
            test_env_scope_for_parser
        ; test_case "Env scope includes assigns in sequence" `Quick
            test_env_scope_for_sequence
        ; test_case "Env scope share assigns between sequences" `Quick
            test_env_scope_for_two_sequences
        ] )
    ]
