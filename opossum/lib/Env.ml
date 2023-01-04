open! Base

(* Environment to store parser and value variables during evaluation. *)

let init : Program.env =
  let global_parsers = ref (Map.empty (module String)) in
  let parsers = Map.empty (module String) in
  let values = Map.empty (module String) in
  { global_parsers; parsers; values }

let init_scope (env : Program.env) : Program.env =
  let parsers = Map.empty (module String) in
  let values = Map.empty (module String) in
  { global_parsers = env.global_parsers; parsers; values }

let find_parser (env : Program.env) (id : string) : Program.parser_fn Option.t =
  match Map.find env.parsers id with
  | Some p -> Some p
  | None -> Map.find !(env.global_parsers) id

let find_parser_exn (env : Program.env) (id : string) : Program.parser_fn =
  find_parser env id |> Option.value_exn

let find_value (env : Program.env) (id : string) : Program.value Option.t =
  Map.find env.values id

let find_value_exn (env : Program.env) (id : string) : Program.value =
  find_value env id |> Option.value_exn

let extend_parsers (env : Program.env) (id : string) (p : Program.parser_fn) :
    Program.env =
  { env with parsers = Map.set env.parsers ~key:id ~data:p }

let set_global_parser (env : Program.env) (id : string) (p : Program.parser_fn)
    : unit =
  env.global_parsers := Map.set !(env.global_parsers) ~key:id ~data:p

let extend_values (env : Program.env) (id : string) (j : Program.value) :
    Program.env =
  { env with values = Map.set env.values ~key:id ~data:j }
