open! Base

(* Shared types used to parse, evaluate, and execute a program. *)

(* Metadata collected while parsing program file. *)
type meta = { start_pos : int; end_pos : int } [@@deriving show]

(* Programs produce JSON encoded as this type. *)
type json =
  [ `Null
  | `Bool of bool
  | `Intlit of string
  | `Floatlit of string
  | `String of string
  | `Assoc of (string * json) list
  | `List of json list ]

(* A Program is a parser which when ran on a text input produces JSON *)
type t = json Angstrom.t

type 'a id_map = (string, 'a, String.comparator_witness) Map.t

(* Parser which is either waiting for more params (other parsers) or ready for
   input to parse into JSON. *)
type json_parser =
  | ParserParam of (json_parser * meta -> json_parser)
  | JsonParam of (json * meta -> json_parser)
  | Delayed of (unit -> json_parser) * string * json_parser_arg list
  | Parser of json Angstrom.t

(* A partially evaluated program wich needs an environment in order to produce a
   parser. *)

(* Program environment, passed through all the parsers and sub-parsers. *)
and env =
  { global_parsers : json_parser id_map ref
  ; local_parsers : json_parser id_map
  ; local_json : json id_map
  }

and json_parser_arg =
  | ParserArg of json_parser * meta
  | JsonArg of json * meta
  | LitArg of json_parser * json * meta
