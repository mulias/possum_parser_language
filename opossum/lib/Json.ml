open! Base

let pp (f : Formatter.t) (j : Program.json) : unit = Yojson.pp f (j :> Yojson.t)

let type_string (json : Program.json) : string =
  match json with
  | `Null -> "null"
  | `Bool true -> "true"
  | `Bool false -> "false"
  | `String _ -> "string"
  | `Intlit _ -> "number"
  | `Floatlit _ -> "number"
  | `Assoc _ -> "object"
  | `List _ -> "array"

let to_string (json : Program.json) : string =
  (json :> Yojson.t) |> Yojson.to_string

let pretty_print (json : Program.json) : unit =
  (json :> Yojson.t) |> Yojson.pretty_to_string |> Stdio.print_endline

let equal (a : Program.json) (b : Program.json) : bool =
  Yojson.equal (a :> Yojson.t) (b :> Yojson.t)
