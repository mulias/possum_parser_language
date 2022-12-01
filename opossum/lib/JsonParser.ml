open Angstrom
open Angstrom.Let_syntax
open! Base

(*
  Helper functions for manipulating json parsers.
*)

let compose (c : 'a Angstrom.t -> 'a Angstrom.t -> 'a Angstrom.t)
    (p1 : Program.json_parser) (p2 : Program.json_parser) : Program.json_parser
    =
  match (p1, p2) with
  | Parser p1, Parser p2 -> Parser (c p1 p2)
  | _ -> raise Errors.EvalNotEnoughArguments

let concat_strings (p1 : Program.json_parser) (p2 : Program.json_parser)
    (meta : Program.meta) : Program.json_parser =
  let concat (pa : Program.t) (pb : Program.t) : Program.t =
    let%map ja = pa and jb = pb in
    match (ja, jb) with
    | `String sa, `String sb -> `String (sa ^ sb)
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
             })
  in
  compose concat p1 p2

(* Given a parser `p` and a list of `args`, recursivly apply each arg. The
   result is either a `CurriedParser` which needs more args, a fully satisfied
   `Parser`, or a `RuntimeError` if too many args were provided.
*)
let rec apply (name : string) (p : Program.json_parser)
    (args : Program.json_parser_arg list) : Program.json_parser =
  match (p, args) with
  | Delayed (delayed_p, _, delayed_args), _ ->
      Delayed (delayed_p, name, List.append args delayed_args)
  | Parser p, [] -> Parser (p <?> name)
  | json_parser, [] -> json_parser
  | ParserParam fn, ParserArg (p, meta) :: args_tl ->
      apply name (fn (p, meta)) args_tl
  | ParserParam fn, LitArg (p, _, meta) :: args_tl ->
      apply name (fn (p, meta)) args_tl
  | JsonParam fn, JsonArg (j, meta) :: args_tl ->
      apply name (fn (j, meta)) args_tl
  | JsonParam fn, LitArg (_, j, meta) :: args_tl ->
      apply name (fn (j, meta)) args_tl
  | Parser _, _ :: _ -> raise Errors.EvalTooManyArguments
  | ParserParam _, JsonArg _ :: _ ->
      raise (Errors.EvalArgumentType { expected = "parser"; got = "json" })
  | JsonParam _, ParserArg _ :: _ ->
      raise (Errors.EvalArgumentType { expected = "json"; got = "parser" })

(* Given a parser `p` and a list of `params`, wrap `p` in layers of
   `CurriedParser` so that when `apply` is called each argument is assigned to
   the corresponding param in the environment.
*)
let rec curry (p : Program.env -> Program.json_parser) (params : Ast.id list)
    (env : Program.env) : Program.json_parser =
  match params with
  | [] -> p env
  | `ParserId (param_id, _) :: rest ->
      ParserParam
        (fun (arg, _meta) ->
          let env = Env.extend_local_parsers env param_id arg in
          curry p rest env)
  | `JsonId (param_id, _) :: rest ->
      JsonParam
        (fun (arg, _meta) ->
          let env = Env.extend_local_json env param_id arg in
          curry p rest env)
