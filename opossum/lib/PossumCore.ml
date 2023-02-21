open Angstrom
open Angstrom.Let_syntax
open! Base

let rec parser_map (p : Program.parser_fn) fn =
  match p with
  | Program.Parser p -> fn p
  | Program.Delayed (delayed_p, name, delayed_args) ->
      parser_map (ParserFn.apply name (delayed_p ()) delayed_args) fn
  | _ -> raise Errors.EvalNotEnoughArguments

let arity_0 (p : Program.value Angstrom.t) : Program.parser_fn =
  Program.Parser p

let arity_1 fn : Program.parser_fn =
  Program.ParserParam
    (fun ((arg, meta) : Program.parser_fn * Program.meta) ->
      parser_map arg (fun p -> arity_0 (fn (p, meta))))

let char_parser = arity_0 (any_char >>| fun c -> `String (Char.to_string c))

let string_of_parser =
  arity_1 (fun (p, _) ->
      p >>| fun value ->
      match value with
      | `String s -> `String s
      | _ -> `String (Value.to_json_string value))

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

let debug_line_parser =
  arity_0
    ( Parser.peek_line >>= fun input ->
      Stdio.eprintf "debug: \"%s\"\n" input ;
      return `Null )

let extend_env (env : Program.env) : Program.env =
  let extended_env = Env.extend env in
  [ ("char", char_parser)
  ; ("string_of", string_of_parser)
  ; ("number_of", number_of_parser)
  ; ("debug_line", debug_line_parser)
  ]
  |> List.iter ~f:(fun (name, p) -> Env.set_global_parser extended_env name p) ;
  extended_env
