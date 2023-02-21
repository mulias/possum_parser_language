open! Base

(* Shared types used to parse, evaluate, and execute a program. *)

type source = [ `Parser | `Stdlib ] [@@deriving show]

(* Metadata collected while parsing program file. *)
type meta = { source : source; start_pos : int; end_pos : int }
[@@deriving show]

(* Programs produce JSON encoded as this type. *)
type value =
  [ `Null
  | `Bool of bool
  | `Intlit of string
  | `Floatlit of string
  | `String of string
  | `Assoc of (string * value) list
  | `List of value list ]

(* A Program is a parser which when ran on a text input produces a value *)
type t = value Angstrom.t

type 'a id_map = (string, 'a, String.comparator_witness) Map.t

(* Parser function which is either waiting for params or ready for input. A
   parser which has been defined but has not yet been invoked may be in the
   `Delayed` state. *)
type parser_fn =
  | ParserParam of (parser_fn * meta -> parser_fn)
  | ValueParam of (value * meta -> parser_fn)
  | Delayed of (unit -> parser_fn) * string * parser_fn_arg list
  | Parser of value Angstrom.t

(* Program environment, passed through all the parsers and sub-parsers. *)
and env_scope =
  { global_parsers : parser_fn id_map ref
  ; parsers : parser_fn id_map
  ; values : value id_map
  }

and env = env_scope List.t

and parser_fn_arg =
  | ParserArg of parser_fn * meta
  | ValueArg of value * meta
  | LitArg of parser_fn * value * meta
