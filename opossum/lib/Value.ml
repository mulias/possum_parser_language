open Program
open! Base

let pp (f : Formatter.t) (v : value) : unit = Yojson.pp f (v :> Yojson.t)

let to_type_string (v : value) : string =
  match v with
  | `Null -> "null"
  | `Bool true -> "true"
  | `Bool false -> "false"
  | `String _ -> "string"
  | `Intlit _ -> "number"
  | `Floatlit _ -> "number"
  | `Assoc _ -> "object"
  | `List _ -> "array"

let to_json_string (v : value) : string = (v :> Yojson.t) |> Yojson.to_string

let pretty_print_json (v : value) : unit =
  (v :> Yojson.t) |> Yojson.pretty_to_string |> Stdio.print_endline

let equal (a : value) (b : value) : bool =
  Yojson.equal (a :> Yojson.t) (b :> Yojson.t)
