open! Base

(* Environment to store parser and value variables during evaluation. *)

let init : Program.env = []

let extend (env : Program.env) : Program.env =
  let global_parsers = ref (Map.empty (module String)) in
  let parsers = Map.empty (module String) in
  let values = Map.empty (module String) in
  let new_scope : Program.env_scope = { global_parsers; parsers; values } in
  new_scope :: env

let find_parser_in_scope (scope : Program.env_scope) (id : string) :
    Program.parser_fn Option.t =
  match Map.find scope.parsers id with
  | Some p -> Some p
  | None -> Map.find !(scope.global_parsers) id

let find_value_in_scope (scope : Program.env_scope) (id : string) :
    Program.value Option.t =
  Map.find scope.values id

let rec find_parser (env : Program.env) (id : string) :
    (Program.parser_fn * Program.env) Option.t =
  match env with
  | scope :: env_rest -> (
      match find_parser_in_scope scope id with
      | Some p -> Some (p, env)
      | None -> find_parser env_rest id)
  | [] -> None

let find_value (env : Program.env) (id : string) : Program.value Option.t =
  List.find_map env ~f:(fun scope -> find_value_in_scope scope id)

let set_global_parser (env : Program.env) (id : string) (p : Program.parser_fn)
    : unit =
  match List.hd env with
  | Some scope ->
      scope.global_parsers := Map.set !(scope.global_parsers) ~key:id ~data:p ;
      ()
  | None -> ()

let extend_parsers (env : Program.env) (id : string) (p : Program.parser_fn) :
    Program.env =
  match env with
  | scope :: env_rest ->
      { scope with parsers = Map.set scope.parsers ~key:id ~data:p } :: env_rest
  | [] -> env

let extend_values (env : Program.env) (id : string) (v : Program.value) :
    Program.env =
  match env with
  | scope :: env_rest ->
      { scope with values = Map.set scope.values ~key:id ~data:v } :: env_rest
  | [] -> env
