open! Base

let pp (f : Formatter.t) (v : Program.value) : unit =
  Yojson.pp f (v :> Yojson.t)

let type_string (v : Program.value) : string =
  match v with
  | `Null -> "null"
  | `Bool true -> "true"
  | `Bool false -> "false"
  | `String _ -> "string"
  | `Intlit _ -> "number"
  | `Floatlit _ -> "number"
  | `Assoc _ -> "object"
  | `List _ -> "array"

let to_string (v : Program.value) : string = (v :> Yojson.t) |> Yojson.to_string

let pretty_print (v : Program.value) : unit =
  (v :> Yojson.t) |> Yojson.pretty_to_string |> Stdio.print_endline

let equal (a : Program.value) (b : Program.value) : bool =
  Yojson.equal (a :> Yojson.t) (b :> Yojson.t)
