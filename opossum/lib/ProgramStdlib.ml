open Angstrom
open Angstrom.Let_syntax
open! Base

let rec parser_map (p : Program.json_parser) fn =
  match p with
  | Program.Parser p -> fn p
  | Program.Delayed (delayed_p, name, delayed_args) ->
      parser_map (JsonParser.apply name (delayed_p ()) delayed_args) fn
  | _ -> raise Errors.EvalNotEnoughArguments

let arity_0 (p : Program.json Angstrom.t) : Program.json_parser =
  Program.Parser p

let arity_1 fn : Program.json_parser =
  Program.ParserParam
    (fun ((arg, meta) : Program.json_parser * Program.meta) ->
      parser_map arg (fun p -> arity_0 (fn (p, meta))))

let arity_2 fn : Program.json_parser =
  Program.ParserParam
    (fun ((arg, meta) : Program.json_parser * Program.meta) ->
      parser_map arg (fun p -> arity_1 (fn (p, meta))))

let arity_3 fn : Program.json_parser =
  Program.ParserParam
    (fun ((arg, meta) : Program.json_parser * Program.meta) ->
      parser_map arg (fun p -> arity_2 (fn (p, meta))))

let arity_4 fn : Program.json_parser =
  Program.ParserParam
    (fun ((arg, meta) : Program.json_parser * Program.meta) ->
      parser_map arg (fun p -> arity_3 (fn (p, meta))))

let to_string s = `String s

let char_to_string c = `String (Char.to_string c)

let to_null _v = `Null

let to_intlit s = `Intlit s

let char_to_int c = `Intlit (Char.to_string c)

(* Basic parsers *)

let peek_parser = arity_1 (fun (p, _) -> Parser.peek p)

let number_of_parser =
  arity_1 (fun (p, _) ->
      p >>= function
      | (`Intlit _ | `Floatlit _) as num -> return num
      | `String s -> (
          match
            Angstrom.parse_string Parser.int_or_float s
              ~consume:Angstrom.Consume.All
          with
          | Ok (`Intlit s) -> return (`Intlit s)
          | Ok (`Floatlit s) -> return (`Floatlit s)
          | Error _ -> fail "string does not encode number")
      | _ -> fail "value does not encode number")

let string_of_parser =
  arity_1 (fun (p, _) ->
      p >>| fun value ->
      match value with
      | `String s -> `String s
      | _ -> `String (Json.to_string value))

(* String parsers *)

let char = any_char

let char_parser = arity_0 (char >>| char_to_string)

let alpha = satisfy Parser.is_alpha

let alpha_parser = arity_0 (alpha >>| char_to_string)

let lower = satisfy Parser.is_lowercase

let lower_parser = arity_0 (lower >>| char_to_string)

let upper = satisfy Parser.is_uppercase

let upper_parser = arity_0 (upper >>| char_to_string)

let numeral = satisfy Parser.is_digit

let numeral_parser = arity_0 (numeral >>| char_to_string)

let space = satisfy Parser.is_ws

let space_parser = arity_0 (space >>| char_to_string)

let symbol = satisfy Parser.is_symbol

let symbol_parser = arity_0 (symbol >>| char_to_string)

let newline = string "\r\n" <|> string "\n"

let newline_parser = arity_0 (newline >>| to_string)

let end_of_input_parser = arity_0 (end_of_input >>| to_null)

let whitespace = take_while1 Parser.is_ws

let whitespace_parser = arity_0 (whitespace >>| to_string)

let word = take_while1 Parser.is_not_ws

let word_parser = arity_0 (word >>| to_string)

(* Number parsers *)

let digit = satisfy Parser.is_digit

let digit_parser = arity_0 (digit >>| char_to_int)

let integer = Parser.number_integer_part

let integer_parser = arity_0 (integer >>| to_intlit)

let float_parser =
  let with_fraction =
    consumed
      (Parser.number_fraction_part *> Parser.maybe Parser.number_exponent_part)
  in
  let with_exponent =
    consumed
      (Parser.maybe Parser.number_fraction_part *> Parser.number_exponent_part)
  in
  arity_0
    ( Parser.number_integer_part >>= fun integer ->
      with_fraction <|> with_exponent >>| fun float_rest ->
      `Floatlit (integer ^ float_rest) )

let number_parser =
  arity_0
    ( Parser.number_integer_part >>= fun integer ->
      peek_char >>= fun next_char ->
      match next_char with
      | Some '.' ->
          consumed
            (Parser.number_fraction_part
            *> Parser.maybe Parser.number_exponent_part)
          >>| fun float_rest -> `Floatlit (integer ^ float_rest)
      | Some 'e' | Some 'E' ->
          Parser.number_exponent_part >>| fun float_rest ->
          `Floatlit (integer ^ float_rest)
      | _ -> return (to_intlit integer) )

(* True/False/Null parsers *)

let true_parser = arity_1 (fun (p, _) -> p >>| fun _ -> `Bool true)

let false_parser = arity_1 (fun (p, _) -> p >>| fun _ -> `Bool false)

let boolean_parser =
  arity_2 (fun (p_true, _) (p_false, _) ->
      p_true >>| (fun _ -> `Bool true) <|> (p_false >>| fun _ -> `Bool false))

let null_parser = arity_1 (fun (p, _) -> p >>| fun _ -> `Null)

(* Repeated string parsers *)

let concat_strings (p : Program.json list Angstrom.t) : Program.t =
  p >>| fun lst ->
  lst
  |> List.map ~f:(function
       | `String s -> s
       | _ ->
           raise
             (Errors.EvalJsonType { expected = "string"; got = "not string" }))
  |> String.concat
  |> fun s -> `String s

let many_parser = arity_1 (fun (s, _) -> concat_strings (many1 s))

let until_parser =
  let until_rec p stop =
    fix (fun until_rec ->
        p >>= fun first ->
        Parser.peek stop
        >>= (fun _ -> return [ first ])
        <|> (until_rec >>= fun rest -> return (first :: rest)))
  in
  arity_2 (fun (p, _) (stop, _) ->
      let%map p_str = concat_strings (until_rec p stop)
      and _has_stop = Parser.peek stop in
      p_str)

let scan_parser =
  arity_1 (fun (p, _) ->
      let%map _ = many_till any_char (Parser.peek p)
      and value = p in
      value)

(* Collection parsers *)

let array_parser =
  arity_1 (fun (elem, _) -> many1 elem >>| fun arr -> `List arr)

let array_sep_parser =
  arity_2 (fun (elem, _) (sep, _) -> sep_by1 sep elem >>| fun arr -> `List arr)

let table_sep_parser =
  arity_3 (fun (elem, _) (sep, _) (row_sep, _) ->
      sep_by1 row_sep (sep_by1 sep elem) >>| fun table ->
      `List (List.map table ~f:(fun row -> `List row)))

let object_parser =
  arity_2 (fun (name, name_meta) (value, _) ->
      many1 (both name value) >>| fun alist ->
      `Assoc
        (List.map alist ~f:(function
          | `String s, j -> (s, j)
          | non_string, _ ->
              raise
                (Errors.EvalJsonObjectMemberName
                   { id = None
                   ; value = non_string
                   ; start_pos = name_meta.start_pos
                   ; end_pos = name_meta.end_pos
                   }))))

let object_sep_parser =
  arity_4 (fun (name, name_meta) (pair_sep, _) (value, _) (sep, _) ->
      sep_by1 sep (both name (pair_sep *> value)) >>| fun alist ->
      `Assoc
        (List.map alist ~f:(function
          | `String s, j -> (s, j)
          | non_string, _ ->
              raise
                (Errors.EvalJsonObjectMemberName
                   { id = None
                   ; value = non_string
                   ; start_pos = name_meta.start_pos
                   ; end_pos = name_meta.end_pos
                   }))))

(* Utility parsers *)

let input_parser =
  arity_1 (fun (body, _) ->
      take_while Parser.is_ws *> body <* take_while Parser.is_ws <* end_of_input)

let fail_parser = arity_0 (fail "fail")

let succeed_parser = arity_0 (return `Null)

let maybe_parser = arity_1 (fun (p, _) -> option `Null p)

let default_parser =
  Program.ParserParam
    (fun (p, _) ->
      Program.JsonParam
        (fun (default, _) ->
          parser_map p (fun p -> Program.Parser (option default p))))

let const_parser = Program.JsonParam (fun (json, _) -> arity_0 (return json))

let debug_line_parser =
  arity_0
    ( Parser.peek_line >>= fun input ->
      Stdio.eprintf "debug: \"%s\"\n" input ;
      return `Null )

let load (env : Program.env) =
  [ ("char", char_parser)
  ; ("peek", peek_parser)
  ; ("string_of", string_of_parser)
  ; ("number_of", number_of_parser)
  ; ("alpha", alpha_parser)
  ; ("lower", lower_parser)
  ; ("upper", upper_parser)
  ; ("numeral", numeral_parser)
  ; ("space", space_parser)
  ; ("symbol", symbol_parser)
  ; ("newline", newline_parser)
  ; ("nl", newline_parser)
  ; ("end_of_input", end_of_input_parser)
  ; ("end", end_of_input_parser)
  ; ("whitespace", whitespace_parser)
  ; ("ws", whitespace_parser)
  ; ("word", word_parser)
  ; ("digit", digit_parser)
  ; ("integer", integer_parser)
  ; ("int", integer_parser)
  ; ("float", float_parser)
  ; ("number", number_parser)
  ; ("num", number_parser)
  ; ("true", true_parser)
  ; ("false", false_parser)
  ; ("boolean", boolean_parser)
  ; ("bool", boolean_parser)
  ; ("null", null_parser)
  ; ("many", many_parser)
  ; ("until", until_parser)
  ; ("scan", scan_parser)
  ; ("array", array_parser)
  ; ("array_sep", array_sep_parser)
  ; ("table_sep", table_sep_parser)
  ; ("object", object_parser)
  ; ("object_sep", object_sep_parser)
  ; ("input", input_parser)
  ; ("fail", fail_parser)
  ; ("succeed", succeed_parser)
  ; ("maybe", maybe_parser)
  ; ("default", default_parser)
  ; ("const", const_parser)
  ; ("debug_line", debug_line_parser)
  ]
  |> List.iter ~f:(fun (name, p) -> Env.set_global_parser env name p)
