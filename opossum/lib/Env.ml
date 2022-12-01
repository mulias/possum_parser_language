open! Base

(*
  Environment to store parser and JSON variables during evaluation.
*)

let init : Program.env =
  let global_parsers = ref (Map.empty (module String)) in
  let local_parsers = Map.empty (module String) in
  let local_json = Map.empty (module String) in
  { global_parsers; local_parsers; local_json }

let init_scope (env : Program.env) : Program.env =
  let local_parsers = Map.empty (module String) in
  let local_json = Map.empty (module String) in
  { global_parsers = env.global_parsers; local_parsers; local_json }

let find_parser (env : Program.env) (id : string) : Program.json_parser Option.t
    =
  match Map.find env.local_parsers id with
  | Some p -> Some p
  | None -> Map.find !(env.global_parsers) id

let find_parser_exn (env : Program.env) (id : string) : Program.json_parser =
  find_parser env id |> Option.value_exn

let find_json (env : Program.env) (id : string) : Program.json Option.t =
  Map.find env.local_json id

let find_json_exn (env : Program.env) (id : string) : Program.json =
  find_json env id |> Option.value_exn

let extend_local_parsers (env : Program.env) (id : string)
    (p : Program.json_parser) : Program.env =
  { env with local_parsers = Map.set env.local_parsers ~key:id ~data:p }

let set_global_parser (env : Program.env) (id : string)
    (p : Program.json_parser) : unit =
  env.global_parsers := Map.set !(env.global_parsers) ~key:id ~data:p

let extend_local_json (env : Program.env) (id : string) (j : Program.json) :
    Program.env =
  { env with local_json = Map.set env.local_json ~key:id ~data:j }
