open Angstrom
open Angstrom.Let_syntax
open! Base

(* Helper functions for manipulating possum parser functions. *)

let compose
    (c : 'a Angstrom.t -> 'a Angstrom.t -> 'a Angstrom.t)
    (p1 : Program.parser_fn)
    (p2 : Program.parser_fn) : Program.parser_fn =
  match (p1, p2) with
  | Parser p1, Parser p2 -> Parser (c p1 p2)
  | _ -> raise Errors.EvalNotEnoughArguments

let concat_strings
    (p1 : Program.parser_fn)
    (p2 : Program.parser_fn)
    (meta : Program.meta) : Program.parser_fn =
  let concat (pa : Program.t) (pb : Program.t) : Program.t =
    let%map ja = pa
    and jb = pb in
    match (ja, jb) with
    | `String sa, `String sb -> `String (sa ^ sb)
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
             })
  in
  compose concat p1 p2

(* Given a parser `p` and a list of `args`, recursivly apply each arg. The
   result is either a `CurriedParser` which needs more args, a fully satisfied
   `Parser`, or a `RuntimeError` if too many args were provided. *)
let rec apply
    (name : string)
    (p : Program.parser_fn)
    (args : Program.parser_fn_arg list) : Program.parser_fn =
  match (p, args) with
  | Delayed (delayed_p, _, delayed_args), _ ->
      Delayed (delayed_p, name, List.append args delayed_args)
  | Parser p, [] -> Parser (p <?> name)
  | parser_fn, [] -> parser_fn
  | ParserParam fn, ParserArg (p, meta) :: args_tl ->
      apply name (fn (p, meta)) args_tl
  | ParserParam fn, LitArg (p, _, meta) :: args_tl ->
      apply name (fn (p, meta)) args_tl
  | ValueParam fn, ValueArg (j, meta) :: args_tl ->
      apply name (fn (j, meta)) args_tl
  | ValueParam fn, LitArg (_, j, meta) :: args_tl ->
      apply name (fn (j, meta)) args_tl
  | Parser _, _ :: _ -> raise Errors.EvalTooManyArguments
  | ParserParam _, ValueArg (_, meta) :: _ ->
      raise
        (Errors.EvalArgumentType { expected = "parser"; got = "value"; meta })
  | ValueParam _, ParserArg (_, meta) :: _ ->
      raise
        (Errors.EvalArgumentType { expected = "value"; got = "parser"; meta })

(* Given a parser `p` and a list of `params`, wrap `p` in layers of
   `CurriedParser` so that when `apply` is called each argument is assigned to
   the corresponding param in the environment. *)
let rec curry
    (p : Program.env -> Program.parser_fn)
    (params : Ast.id list)
    (env : Program.env) : Program.parser_fn =
  match params with
  | [] -> p env
  | `ParserId (param_id, _) :: rest ->
      ParserParam
        (fun (arg, _meta) ->
          let env = Env.extend_parsers env param_id arg in
          curry p rest env)
  | `ValueId (param_id, _) :: rest ->
      ValueParam
        (fun (arg, _meta) ->
          let env = Env.extend_values env param_id arg in
          curry p rest env)
