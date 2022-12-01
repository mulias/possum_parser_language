open Angstrom
open Angstrom.Let_syntax
open! Base

(*
  Evaluate a parser program, producing a parser which can be ran on string
  input and returns JSON on sccess.
*)

let current_input_ref = ref None
let clear_current_input_ref () = current_input_ref := None

let peek_current_input =
  match !current_input_ref with
  | None ->
      Parser.peek_input >>= fun input ->
      current_input_ref := Some input;
      return input
  | Some input -> return input

let eval_literal_json (ast : Ast.json_literal) : Program.json =
  match ast with
  | `String (s, _) -> `String s
  | `Intlit (s, _) -> `Intlit s
  | `Floatlit (s, _) -> `Floatlit s
  | `True _ -> `Bool true
  | `False _ -> `Bool false
  | `Null _ -> `Null

let rec eval_json (ast : Ast.json) (env : Program.env) : Program.json =
  match ast with
  | (`String _ | `Intlit _ | `Floatlit _ | `True _ | `False _ | `Null _) as lit
    ->
      eval_literal_json lit
  | `JsonArray (members, _) ->
      `List
        (List.fold_right members
           ~f:(fun member acc ->
             match member with
             | `JsonArrayElement (j, _) -> eval_json j env :: acc
             | `JsonArraySpread (j, _) -> (
                 match eval_json j env with
                 | `List lst -> List.append lst acc
                 | _ -> raise Errors.EvalJsonArraySpread))
           ~init:[])
  | `JsonObject (members, _) ->
      `Assoc
        (List.fold_right members
           ~f:(fun member acc ->
             match member with
             | `JsonObjectPair (`String (s, _), j, _) ->
                 (s, eval_json j env) :: acc
             | `JsonObjectPair (`JsonId (id, id_meta), j, _) -> (
                 match Env.find_json env id with
                 | Some (`String s) -> (s, eval_json j env) :: acc
                 | None ->
                     raise
                       (Errors.EnvFindJson
                          {
                            id;
                            start_pos = id_meta.start_pos;
                            end_pos = id_meta.end_pos;
                          })
                 | Some non_string ->
                     raise
                       (Errors.EvalJsonObjectMemberName
                          {
                            id = Some id;
                            value = non_string;
                            start_pos = id_meta.start_pos;
                            end_pos = id_meta.end_pos;
                          }))
             | `JsonObjectSpread (j, _) -> (
                 match eval_json j env with
                 | `Assoc assoc -> List.append assoc acc
                 | _ -> raise Errors.EvalJsonObjectSpread))
           ~init:[])
  | `JsonId (id, meta) -> (
      match Env.find_json env id with
      | Some j -> j
      | None ->
          raise
            (Errors.EnvFindJson
               { id; start_pos = meta.start_pos; end_pos = meta.end_pos }))

let rec match_pattern (env : Program.env) (pattern : Ast.json)
    (json : Program.json) : (Program.env, unit) Result.t =
  match (pattern, json) with
  | `JsonId (id, _), j -> (
      match Env.find_json env id with
      | Some pattern_from_env ->
          match_pattern_from_env env pattern_from_env json
      | None -> Ok (Env.extend_local_json env id j))
  | `String (p, _), `String j -> if String.equal p j then Ok env else Error ()
  | `Intlit (p, _), `Intlit j -> if String.equal p j then Ok env else Error ()
  | `Floatlit (p, _), `Floatlit j ->
      if String.equal p j then Ok env else Error ()
  | `True _, `Bool true -> Ok env
  | `False _, `Bool false -> Ok env
  | `Null _, `Null -> Ok env
  | `JsonArray (p, _), `List j -> match_array_pattern env p j
  | `JsonObject (p, _), `Assoc j -> match_object_pattern env p j
  | _, _ -> Error ()

and match_array_pattern (env : Program.env)
    (pattern : Ast.json_array_member list) (json : Program.json list) :
    (Program.env, unit) Result.t =
  let open Result in
  match (pattern, json) with
  | `JsonArrayElement (p, _) :: pattern_rest, j :: json_rest ->
      match_pattern env p j >>= fun env ->
      match_array_pattern env pattern_rest json_rest
  | [ `JsonArraySpread (p, _) ], j -> match_pattern env p (`List j)
  | [], [] -> Ok env
  | _, _ -> Error ()

and match_object_pattern (env : Program.env)
    (pattern : Ast.json_object_member list)
    (json : (string * Program.json) list) : (Program.env, unit) Result.t =
  match (pattern, json) with
  | `JsonObjectPair (p_name, p_value, _) :: pattern_rest, json -> (
      let open Result in
      match p_name with
      | `String (p, _) -> (
          (* The name/value pair has a string for the name. Look for that name
             in the json env. If it's found then match the env value against
             p_value. If it's not found than the pattern match fails.
          *)
          match List.Assoc.find json ~equal:String.equal p with
          | Some j_value ->
              let json_rest = List.Assoc.remove json ~equal:String.equal p in
              match_pattern env p_value j_value >>= fun env ->
              match_object_pattern env pattern_rest json_rest
          | None -> Error ())
      | `JsonId _ ->
          (* The name/value pair has an id for the name. We could try to
             pattern match on the value and then assign the name to the first
             key found with that value, but the value might have more ids to
             assign inside it so the complexity here is non-trivial.
          *)
          raise
            (Errors.Todo "pattern match on JSON variable in object member name")
      )
  | [ `JsonObjectSpread (p, _) ], j -> match_pattern env p (`Assoc j)
  | [], [] -> Ok env
  | _, _ -> Error ()

and match_pattern_from_env (env : Program.env) (pattern : Program.json)
    (json : Program.json) : (Program.env, unit) Result.t =
  if Json.equal pattern json then Ok env else Error ()

and match_object_name_pattern (env : Program.env)
    (pattern : Ast.json_object_member_name) (json : string) :
    (Program.env, unit) Result.t =
  match pattern with
  | `JsonId (id, _) -> Ok (Env.extend_local_json env id (`String json))
  | `String (p, _) -> if String.equal p json then Ok env else Error ()

let eval_literal_parser (ast : Ast.parser_literal) : Program.t =
  match ast with
  | `String (s, _) -> string s *> return (`String s) <?> [%string "\"%{s}\""]
  | `Intlit (s, _) -> string s *> return (`Intlit s) <?> s
  | `Floatlit (s, _) -> string s *> return (`Floatlit s) <?> s

let rec eval_parser_body (ast : Ast.parser_body)
    ?(extended_env : Program.env option) (env : Program.env) : Program.t =
  let extended_env = Option.value extended_env ~default:env in
  let rec resolve_delayed_parser id args (delayed_p, delayed_args) =
    return () >>= fun _ ->
    let evaled_args =
      List.map args ~f:(fun a -> eval_parser_apply_arg a env ~extended_env)
    in
    match
      JsonParser.apply id (delayed_p ()) (List.append delayed_args evaled_args)
    with
    | Parser p -> p
    | Delayed (delayed_p, _, delayed_args) ->
        resolve_delayed_parser id [] (delayed_p, delayed_args)
    | _ -> raise Errors.EvalNotEnoughArguments
  in
  match ast with
  | `ParserApply (`ParserId (id, id_meta), args, _) -> (
      return () >>= fun _ ->
      match Env.find_parser env id with
      | Some (Delayed (delayed_p, _, delayed_args)) ->
          resolve_delayed_parser id args (delayed_p, delayed_args)
      | Some p -> (
          let evaled_args =
            List.map args ~f:(fun a ->
                eval_parser_apply_arg a env ~extended_env)
          in
          match JsonParser.apply id p evaled_args with
          | Parser p -> p
          | Delayed (delayed_p, _, delayed_args) ->
              resolve_delayed_parser id args (delayed_p, delayed_args)
          | _ -> raise Errors.EvalNotEnoughArguments)
      | None ->
          raise
            (Errors.EnvFindParser
               { id; start_pos = id_meta.start_pos; end_pos = id_meta.end_pos })
      )
  | (`String _ | `Intlit _ | `Floatlit _) as lit -> eval_literal_parser lit
  | `Regex (pattern, { start_pos; end_pos }) ->
      let r =
        try Re.Perl.re pattern ~opts:[ `Multiline ] |> Re.compile
        with _ -> raise (Errors.EvalRegexPattern { start_pos; end_pos })
      in
      peek_current_input
      >>= (fun i -> Parser.peek_pos >>= fun p -> Parser.regex r i p)
      <?> "regex"
  | `Sequence (seq, json_return, _) ->
      eval_sequence seq json_return extended_env
  | `Or (left, right, _) ->
      let p_left = eval_parser_body left env ~extended_env in
      let p_right = eval_parser_body right env ~extended_env in
      p_left <|> p_right
  | `TakeLeft (left, right, _) ->
      let p_left = eval_parser_body left env ~extended_env in
      let p_right = eval_parser_body right env ~extended_env in
      p_left <* p_right
  | `TakeRight (left, right, _) ->
      let p_left = eval_parser_body left env ~extended_env in
      let p_right = eval_parser_body right env ~extended_env in
      p_left *> p_right
  | `Concat (left, right, meta) -> (
      let p_left = eval_parser_body left env ~extended_env in
      let p_right = eval_parser_body right env ~extended_env in
      let%map j_left = p_left and j_right = p_right in
      match (j_left, j_right) with
      | `String s_left, `String s_right -> `String (s_left ^ s_right)
      | `String _, not_string ->
          raise
            (Errors.EvalConcat
               {
                 side = `Right;
                 value = not_string;
                 start_pos = meta.start_pos;
                 end_pos = meta.end_pos;
               })
      | not_string, _ ->
          raise
            (Errors.EvalConcat
               {
                 side = `Left;
                 value = not_string;
                 start_pos = meta.start_pos;
                 end_pos = meta.end_pos;
               }))

and eval_parser_body_partial (ast : Ast.parser_body)
    ?(extended_env : Program.env option) (env : Program.env) :
    Program.json_parser =
  let extended_env = Option.value extended_env ~default:env in
  match ast with
  | `ParserApply (`ParserId (id, id_meta), args, _) -> (
      match Env.find_parser env id with
      | Some json_parser ->
          let evaled_args =
            List.map args ~f:(fun a ->
                eval_parser_apply_arg a env ~extended_env)
          in
          JsonParser.apply id json_parser evaled_args
      | None ->
          raise
            (Errors.EnvFindParser
               { id; start_pos = id_meta.start_pos; end_pos = id_meta.end_pos })
      )
  | _ -> Parser (eval_parser_body ast env ~extended_env)

and eval_sequence (seq : (Ast.json option * Ast.parser_body) list)
    (json_return : Ast.json) (env : Program.env) : Program.t =
  let rec build_parser seq json_return extended_env : Program.json Angstrom.t =
    match seq with
    | (optional_pattern, step) :: seq_rest -> (
        eval_parser_body step env ~extended_env >>= fun j ->
        let pattern_extended_env =
          match optional_pattern with
          | Some pattern -> match_pattern extended_env pattern j
          | None -> Ok extended_env
        in
        match pattern_extended_env with
        | Ok new_env -> build_parser seq_rest json_return new_env
        | Error _ -> fail "foo")
    | [] -> return (eval_json json_return extended_env)
  in
  build_parser seq json_return env

and eval_parser_apply_arg (arg : Ast.parser_apply_arg) (env : Program.env)
    ~(extended_env : Program.env) : Program.json_parser_arg =
  match arg with
  | `ParserArg arg ->
      ParserArg
        (eval_parser_body_partial arg env ~extended_env, Ast.get_meta arg)
  | `JsonArg arg -> JsonArg (eval_json arg extended_env, Ast.get_meta arg)
  | `LitArg arg ->
      LitArg
        ( Parser (eval_literal_parser arg),
          eval_literal_json (arg :> Ast.json_literal),
          Ast.get_meta arg )

let eval_named_parser (id : string) (params : Ast.id list)
    (body : Ast.parser_body) (env : Program.env) : Program.json_parser =
  Program.Delayed
    ( (fun () ->
        (* First check that the delayed parser hasn't already been evaluated
           and updated in the global env.
        *)
        match Env.find_parser env id with
        | None | Some (Delayed _) ->
            let p =
              JsonParser.curry (eval_parser_body_partial body) params env
            in
            Env.set_global_parser env id p;
            p
        | Some p -> p),
      id,
      [] )

let eval_main_parser ((body, _) : Ast.parser_body * Program.meta)
    (env : Program.env) : Program.t =
  eval_parser_body body env

let eval_program (Program { main_parser; named_parsers } : Ast.program)
    (env : Program.env) : Program.t =
  let _ = clear_current_input_ref () in
  let named_parsers =
    List.map named_parsers ~f:(fun named_parser ->
        let `ParserId (id, _), params, body, _ = named_parser in
        (id, eval_named_parser id params body env))
  in
  List.iter named_parsers ~f:(fun (id, p) -> Env.set_global_parser env id p);
  eval_main_parser main_parser env

let eval = eval_program
