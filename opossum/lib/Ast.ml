open Program
open! Base

(* The abstract syntax tree for a possum program. *)

(* Variable id referencing a parser in the environment. *)
type parser_id = [ `ParserId of string * meta ] [@@deriving show]

(* Variable id referencing a JSON value in the environment. *)
type json_id = [ `JsonId of string * meta ] [@@deriving show]

(* All variable ids. *)
type id = [ parser_id | json_id ] [@@deriving show]

(* JSON literal values. Can be interpreted either as a parser for the literal,
   or the JSON literal itself depending on context. *)

type string_lit = [ `String of string * meta ] [@@deriving show]

type int_lit = [ `Intlit of string * meta ] [@@deriving show]

type float_lit = [ `Floatlit of string * meta ] [@@deriving show]

type true_lit = [ `True of meta ] [@@deriving show]

type false_lit = [ `False of meta ] [@@deriving show]

type null_lit = [ `Null of meta ] [@@deriving show]

type json_literal =
  [ string_lit | int_lit | float_lit | true_lit | false_lit | null_lit ]
[@@deriving show]

type parser_literal = [ string_lit | int_lit | float_lit ] [@@deriving show]

(* All types supported by JSON, plus JSON variable ids for values which have
   been set in the environment. *)
type json =
  [ json_literal
  | `JsonArray of
    [ `JsonArrayElement of json * meta | `JsonArraySpread of json * meta ] list
    * meta
  | `JsonObject of
    [ `JsonObjectPair of [ string_lit | json_id ] * json * meta
    | `JsonObjectSpread of json * meta ]
    list
    * meta
  | json_id ]
[@@deriving show]

(* JSON arrays. Can contain other JSON values, or a "spread" value, which
   inserts array members into the parent array. *)
type json_array_element = [ `JsonArrayElement of json * meta ] [@@deriving show]

type json_array_spread = [ `JsonArraySpread of json * meta ] [@@deriving show]

type json_array_member = [ json_array_element | json_array_spread ]
[@@deriving show]

type json_array = [ `JsonArray of json_array_member * meta list ]
[@@deriving show]

(* JSON objects. Can contain other JSON values, or a "spread" value, which
   inserts object members into the parent object. *)
type json_object_member_name = [ string_lit | json_id ] [@@deriving show]

type json_object_pair =
  [ `JsonObjectPair of json_object_member_name * json * meta ]
[@@deriving show]

type json_object_spread = [ `JsonObjectSpread of json * meta ] [@@deriving show]

type json_object_member = [ json_object_pair | json_object_spread ]
[@@deriving show]

type json_object = [ `JsonObject of json_object_member list * meta ]
[@@deriving show]

(* Infix combinators for composing parsers. *)
type infix =
  [ `Or | `TakeLeft | `TakeRight | `Concat | `Destructure | `And | `Return ]
[@@deriving show]

(* Permissive Program AST This part of the AST is produced by the ProgramParser
   and represents a program which is at least minimally syntactically
   correct. *)

(* A list of parsers interspersed with infix operators. Does not impose certian
   requirements, such as that a sequence of `And infixes must be followed by a
   `Return. *)
type permissive_parser_steps =
  permissive_parser_step * (infix * permissive_parser_step) list

(* A parser. Does not impose certain requirements, such as that json values can
   only come before a `Destructure or after a `Return. *)
and permissive_parser_step =
  [ `Group of permissive_parser_steps * meta
  | `ParserApply of parser_id * permissive_parser_steps list * meta
  | `Regex of string * meta
  | json
  | parser_literal ]
[@@deriving show]

(* Main parser to run as the entry point to the program, or named parsers which
   are added to the environment and referenced from the main parser. *)

type permissive_main_parser = [ `MainParser of permissive_parser_steps ]
[@@deriving show]

type permissive_named_parser =
  [ `NamedParser of parser_id * id list * permissive_parser_steps ]
[@@deriving show]

type permissive_parser = [ permissive_main_parser | permissive_named_parser ]
[@@deriving show]

(* A program which parses structured text into JSON. Does not require that there
   is exactly one main parser to start at. *)
type permissive_program = [ `Program of permissive_parser list ]
[@@deriving show]

(* AstTransformer Intermediary Grouping In order to transform the permissive
   parser AST to the program AST we need to split the permissive parser step
   lists into sub lists so that the steps are grouped into a sequence, or are
   not part of a sequence. *)

(* A list of grouped parser steps interspersed with infix operators. *)
type parser_group_steps = parser_group * (infix * parser_group) list

(* Either a sequence of parsers ending with a return step, or a parser which is
   not inside of a sequence. *)
and parser_group =
  [ `Sequence of permissive_parser_steps * permissive_parser_step * meta
  | `NonSequence of permissive_parser_steps * meta ]
[@@deriving show]

(* Program AST This AST is produced by the AstTransformer, which iterates over
   the tree to build a more strict version which can be evaluated. *)

(* A parser. Incorporates infix ops into the tree and requires that json nodes
   are only used in appropriate positions. *)
type parser_body =
  [ `ParserApply of parser_id * parser_apply_arg list * meta
  | `Regex of string * meta
  | `Sequence of parser_body list * json * meta
  | `Or of parser_body * parser_body * meta
  | `TakeLeft of parser_body * parser_body * meta
  | `TakeRight of parser_body * parser_body * meta
  | `Concat of parser_body * parser_body * meta
  | `Destructure of json * parser_body * meta
  | parser_literal ]
[@@deriving show]

and parser_apply_arg =
  [ `ParserArg of parser_body | `JsonArg of json | `LitArg of parser_literal ]
[@@deriving show]

(* Program with one main parser and supporting named parsers. *)
type main_parser = parser_body * meta [@@deriving show]

type named_parser = parser_id * id list * parser_body * meta [@@deriving show]

type program =
  | Program of { main_parser : main_parser; named_parsers : named_parser list }
[@@deriving show]

let meta start_pos end_pos : meta = { start_pos; end_pos }

let get_meta (ast : 'a) : meta =
  match ast with
  | `Group (_, meta)
  | `ParserApply (_, _, meta)
  | `Regex (_, meta)
  | `String (_, meta)
  | `Intlit (_, meta)
  | `Floatlit (_, meta)
  | `True meta
  | `False meta
  | `Null meta
  | `JsonArray (_, meta)
  | `JsonObject (_, meta)
  | `JsonId (_, meta)
  | `ParserId (_, meta)
  | `Sequence (_, _, meta)
  | `NonSequence (_, meta)
  | `MainParser (_, meta)
  | `NamedParser (_, _, _, meta)
  | `Or (_, _, meta)
  | `TakeLeft (_, _, meta)
  | `TakeRight (_, _, meta)
  | `Concat (_, _, meta)
  | `Destructure (_, _, meta) ->
      meta

let merge_meta left right : meta =
  let left_meta = get_meta left in
  let right_meta = get_meta right in
  meta left_meta.start_pos right_meta.end_pos

let merge_steps_meta ((first_step, steps) : permissive_parser_steps) : meta =
  match List.last steps with
  | Some (_, last_step) -> merge_meta first_step last_step
  | None -> get_meta first_step
