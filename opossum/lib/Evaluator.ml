open Angstrom
open Angstrom.Let_syntax
open! Base

(* Evaluate a parser program, producing a parser which can be ran on string
   input and returns a value on sccess. *)

let current_input_ref = ref None

let clear_current_input_ref () = current_input_ref := None

let peek_current_input =
  match !current_input_ref with
  | None ->
      Parser.peek_input >>= fun input ->
      current_input_ref := Some input ;
      return input
  | Some input -> return input

let eval_literal_value (ast : Ast.value_literal) : Program.value =
  match ast with
  | `String (s, _) -> `String s
  | `Intlit (s, _) -> `Intlit s
  | `Floatlit (s, _) -> `Floatlit s
  | `Bool (true, _) -> `Bool true
  | `Bool (false, _) -> `Bool false
  | `Null _ -> `Null

let rec eval_value (ast : Ast.value) (env : Program.env) : Program.value =
  match ast with
  | (`String _ | `Intlit _ | `Floatlit _ | `Bool _ | `Null _) as lit ->
      eval_literal_value lit
  | `ValueArray (members, _) ->
      `List
        (List.fold_right members
           ~f:(fun member acc ->
             match member with
             | `ValueArrayElement (j, _) -> eval_value j env :: acc
             | `ValueArraySpread (j, _) -> (
                 match eval_value j env with
                 | `List lst -> List.append lst acc
                 | _ -> raise Errors.EvalValueArraySpread))
           ~init:[])
  | `ValueObject (members, _) ->
      `Assoc
        (List.fold_right members
           ~f:(fun member acc ->
             match member with
             | `ValueObjectPair (`String (s, _), j, _) ->
                 (s, eval_value j env) :: acc
             | `ValueObjectPair (`ValueId (id, id_meta), j, _) -> (
                 match Env.find_value env id with
                 | Some (`String s) -> (s, eval_value j env) :: acc
                 | None ->
                     raise
                       (Errors.EnvFindValue
                          { id
                          ; start_pos = id_meta.start_pos
                          ; end_pos = id_meta.end_pos
                          })
                 | Some non_string ->
                     raise
                       (Errors.EvalValueObjectMemberKey
                          { id = Some id
                          ; value = non_string
                          ; start_pos = id_meta.start_pos
                          ; end_pos = id_meta.end_pos
                          }))
             | `ValueObjectSpread (j, _) -> (
                 match eval_value j env with
                 | `Assoc assoc -> List.append assoc acc
                 | _ -> raise Errors.EvalValueObjectSpread))
           ~init:[])
  | `ValueId (id, meta) -> (
      match Env.find_value env id with
      | Some j -> j
      | None ->
          raise
            (Errors.EnvFindValue
               { id; start_pos = meta.start_pos; end_pos = meta.end_pos }))

let rec destructure
    (env : Program.env)
    (pattern : Ast.pattern)
    (value : Program.value) : (Program.env, unit) Result.t =
  match (pattern, value) with
  | `IgnoredId _, _ -> Ok env
  | `ValueId (id, _), v -> (
      match Env.find_value env id with
      | Some value_from_env -> destructure_from_env env value_from_env v
      | None -> Ok (Env.extend_values env id v))
  | `String (p, _), `String v -> if String.equal p v then Ok env else Error ()
  | `Intlit (p, _), `Intlit v -> if String.equal p v then Ok env else Error ()
  | `Floatlit (p, _), `Floatlit v ->
      if String.equal p v then Ok env else Error ()
  | `Bool (true, _), `Bool true -> Ok env
  | `Bool (false, _), `Bool false -> Ok env
  | `Null _, `Null -> Ok env
  | `PatternArray (p, _), `List v -> destructure_array env p v
  | `PatternObject (p, _), `Assoc v -> destructure_object env p v
  | _, _ -> Error ()

and destructure_array
    (env : Program.env)
    (pattern : Ast.pattern_array_member list)
    (arr : Program.value list) : (Program.env, unit) Result.t =
  let open Result in
  match (pattern, arr) with
  | `PatternArrayElement (p, _) :: pattern_rest, v :: arr_rest ->
      destructure env p v >>= fun env ->
      destructure_array env pattern_rest arr_rest
  | [ `PatternArraySpread (p, _) ], arr -> destructure env p (`List arr)
  | [], [] -> Ok env
  | _, _ -> Error ()

and destructure_object
    (env : Program.env)
    (pattern : Ast.pattern_object_member list)
    (assoc : (string * Program.value) list) : (Program.env, unit) Result.t =
  match (pattern, assoc) with
  | `PatternObjectPair (obj_key, obj_value, _) :: pattern_rest, assoc -> (
      let open Result in
      match obj_key with
      | `String (p, _) -> (
          (* The key/value pair has a string for the key. Look for that key in
             the value env. If it's found then match the env value against
             p_value. If it's not found than the pattern match fails. *)
          match List.Assoc.find assoc ~equal:String.equal p with
          | Some found_value ->
              let assoc_rest = List.Assoc.remove assoc ~equal:String.equal p in
              destructure env obj_value found_value >>= fun env ->
              destructure_object env pattern_rest assoc_rest
          | None -> Error ())
      | `ValueId _ | `IgnoredId _ ->
          (* The key/value pair has an id for the key. We could try to pattern
             match on the value and then assign the key to the first key found
             with that value, but the value might have more ids to assign inside
             it so the complexity here is non-trivial. *)
          raise (Errors.Todo "pattern match on variable in object member key"))
  | [ `PatternObjectSpread (p, _) ], assoc -> destructure env p (`Assoc assoc)
  | [], [] -> Ok env
  | _, _ -> Error ()

and destructure_from_env
    (env : Program.env)
    (value_from_env : Program.value)
    (value : Program.value) : (Program.env, unit) Result.t =
  if Value.equal value_from_env value then Ok env else Error ()

let eval_literal_parser (ast : Ast.parser_literal) : Program.t =
  match ast with
  | `String (s, _) -> string s *> return (`String s) <?> [%string "\"%{s}\""]
  | `Intlit (s, _) -> string s *> return (`Intlit s) <?> s
  | `Floatlit (s, _) -> string s *> return (`Floatlit s) <?> s

let rec eval_parser_body (ast : Ast.parser_body) (env : Program.env) :
    (Program.value * Program.env) Angstrom.t =
  let rec resolve_delayed_parser id args (delayed_p, delayed_args) =
    return () >>= fun _ ->
    let evaled_args = List.map args ~f:(fun a -> eval_parser_apply_arg a env) in
    match
      ParserFn.apply id (delayed_p ()) (List.append delayed_args evaled_args)
    with
    | Parser p -> p >>= fun value -> return (value, env)
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
            List.map args ~f:(fun a -> eval_parser_apply_arg a env)
          in
          match ParserFn.apply id p evaled_args with
          | Parser p -> p >>= fun value -> return (value, env)
          | Delayed (delayed_p, _, delayed_args) ->
              resolve_delayed_parser id args (delayed_p, delayed_args)
          | _ -> raise Errors.EvalNotEnoughArguments)
      | None ->
          raise
            (Errors.EnvFindParser
               { id; start_pos = id_meta.start_pos; end_pos = id_meta.end_pos })
      )
  | (`String _ | `Intlit _ | `Floatlit _) as lit ->
      eval_literal_parser lit >>= fun value -> return (value, env)
  | `Regex (pattern, { start_pos; end_pos }) ->
      let r =
        try Re.Perl.re pattern ~opts:[ `Multiline ] |> Re.compile
        with _ -> raise (Errors.EvalRegexPattern { start_pos; end_pos })
      in
      peek_current_input
      >>= (fun i -> Parser.peek_pos >>= fun p -> Parser.regex r i p)
      <?> "regex"
      >>= fun value -> return (value, env)
  | `Sequence (seq, return_value, _) -> eval_sequence seq return_value env
  | `Or (left, right, _) ->
      eval_parser_body left env <|> eval_parser_body right env
  | `TakeLeft (left, right, _) ->
      eval_parser_body left env >>= fun (v_left, env_left) ->
      eval_parser_body right env_left >>= fun (_v_right, env_right) ->
      return (v_left, env_right)
  | `TakeRight (left, right, _) ->
      eval_parser_body left env >>= fun (_v_left, env_left) ->
      eval_parser_body right env_left
  | `Concat (left, right, meta) -> (
      eval_parser_body left env >>= fun (v_left, env_left) ->
      eval_parser_body right env_left >>= fun (v_right, env_right) ->
      match (v_left, v_right) with
      | `String s_left, `String s_right ->
          return (`String (s_left ^ s_right), env_right)
      | `String _, not_string ->
          raise
            (Errors.EvalConcat
               { side = `Right
               ; value = not_string
               ; start_pos = meta.start_pos
               ; end_pos = meta.end_pos
               })
      | not_string, _ ->
          raise
            (Errors.EvalConcat
               { side = `Left
               ; value = not_string
               ; start_pos = meta.start_pos
               ; end_pos = meta.end_pos
               }))
  | `Destructure (left, right, _) -> (
      eval_parser_body right env >>= fun (v_right, env_right) ->
      match destructure env_right left v_right with
      | Ok new_env -> return (v_right, new_env)
      | Error _ -> fail "Destructure" <?> "Destructure")

and eval_parser_body_partial (ast : Ast.parser_body) (env : Program.env) :
    Program.parser_fn =
  match ast with
  | `ParserApply (`ParserId (id, id_meta), args, _) -> (
      match Env.find_parser env id with
      | Some parser_fn ->
          let evaled_args =
            List.map args ~f:(fun a -> eval_parser_apply_arg a env)
          in
          ParserFn.apply id parser_fn evaled_args
      | None ->
          raise
            (Errors.EnvFindParser
               { id; start_pos = id_meta.start_pos; end_pos = id_meta.end_pos })
      )
  | _ -> Parser (eval_parser_body ast env >>= fun (value, _env) -> return value)

and eval_sequence
    (steps : Ast.parser_body list)
    (return_value : Ast.value)
    (env : Program.env) : (Program.value * Program.env) Angstrom.t =
  let rec build_parser steps return_value env =
    match steps with
    | step :: steps_rest ->
        eval_parser_body step env >>= fun (_value, body_env) ->
        build_parser steps_rest return_value body_env
    | [] -> return (eval_value return_value env, env)
  in
  build_parser steps return_value env

and eval_parser_apply_arg (arg : Ast.parser_apply_arg) (env : Program.env) :
    Program.parser_fn_arg =
  match arg with
  | `ParserArg arg ->
      ParserArg (eval_parser_body_partial arg env, Ast.get_meta arg)
  | `ValueArg arg -> ValueArg (eval_value arg env, Ast.get_meta arg)
  | `LitArg arg ->
      LitArg
        ( Parser (eval_literal_parser arg)
        , eval_literal_value (arg :> Ast.value_literal)
        , Ast.get_meta arg )

let eval_named_parser
    (id : string)
    (params : Ast.id list)
    (body : Ast.parser_body)
    (env : Program.env) : Program.parser_fn =
  Program.Delayed
    ( (fun () ->
        (* First check that the delayed parser hasn't already been evaluated and
           updated in the global env. *)
        match Env.find_parser env id with
        | None | Some (Delayed _) ->
            let p = ParserFn.curry (eval_parser_body_partial body) params env in
            Env.set_global_parser env id p ;
            p
        | Some p -> p)
    , id
    , [] )

let eval_main_parser
    ((body, _) : Ast.parser_body * Program.meta)
    (env : Program.env) : Program.t =
  eval_parser_body body env >>= fun (value, _env) -> return value

let eval_program
    (Program { main_parser; named_parsers } : Ast.program)
    (env : Program.env) : Program.t Option.t =
  let _ = clear_current_input_ref () in
  let named_parsers =
    List.map named_parsers ~f:(fun named_parser ->
        let `ParserId (id, _), params, body, _ = named_parser in
        (id, eval_named_parser id params body env))
  in
  List.iter named_parsers ~f:(fun (id, p) -> Env.set_global_parser env id p) ;
  Option.map main_parser ~f:(fun p -> eval_main_parser p env)

let eval = eval_program
