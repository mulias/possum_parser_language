open Program
open! Base

(* The abstract syntax tree for a possum program. *)

(* Variable id referencing a parser in the environment. *)
type parser_id = [ `ParserId of string * meta ] [@@deriving show]

(* Variable id referencing a value in the environment. *)
type value_id = [ `ValueId of string * meta ] [@@deriving show]

(* All variable ids. *)
type id = [ parser_id | value_id ] [@@deriving show]

(* Literal values. Can be interpreted either as a parser for the literal, or the
   literal value itself depending on context. *)

type string_lit = [ `String of string * meta ] [@@deriving show]

type int_lit = [ `Intlit of string * meta ] [@@deriving show]

type float_lit = [ `Floatlit of string * meta ] [@@deriving show]

type bool_lit = [ `Bool of bool * meta ] [@@deriving show]

type null_lit = [ `Null of meta ] [@@deriving show]

type value_literal = [ string_lit | int_lit | float_lit | bool_lit | null_lit ]
[@@deriving show]

type parser_literal = [ string_lit | int_lit | float_lit ] [@@deriving show]

(* All types supported by JSON, plus variable ids for values which have been set
   in the environment. *)
type value =
  [ value_literal
  | `ValueArray of
    [ `ValueArrayElement of value * meta | `ValueArraySpread of value * meta ]
    list
    * meta
  | `ValueObject of
    [ `ValueObjectPair of [ string_lit | value_id ] * value * meta
    | `ValueObjectSpread of value * meta ]
    list
    * meta
  | value_id ]
[@@deriving show]

(* Collection of ordered values. Can contain other values, or a "spread" value,
   which inserts array members into the parent array. *)

type value_array_element = [ `ValueArrayElement of value * meta ]
[@@deriving show]

type value_array_spread = [ `ValueArraySpread of value * meta ]
[@@deriving show]

type value_array_member = [ value_array_element | value_array_spread ]
[@@deriving show]

type value_array = [ `ValueArray of value_array_member * meta list ]
[@@deriving show]

(* Collection with key/value pairs. Can contain other values, or a "spread"
   value, which inserts object members into the parent object. *)

type value_object_member_name = [ string_lit | value_id ] [@@deriving show]

type value_object_pair =
  [ `ValueObjectPair of value_object_member_name * value * meta ]
[@@deriving show]

type value_object_spread = [ `ValueObjectSpread of value * meta ]
[@@deriving show]

type value_object_member = [ value_object_pair | value_object_spread ]
[@@deriving show]

type value_object = [ `ValueObject of value_object_member list * meta ]
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

(* A parser. Does not impose certain requirements, such as that values can only
   come before a `Destructure or after a `Return. *)
and permissive_parser_step =
  [ `Group of permissive_parser_steps * meta
  | `ParserApply of parser_id * permissive_parser_steps list * meta
  | `Regex of string * meta
  | value
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

(* A parser. Incorporates infix ops into the tree and requires that values are
   only used in appropriate places. *)
type parser_body =
  [ `ParserApply of parser_id * parser_apply_arg list * meta
  | `Regex of string * meta
  | `Sequence of parser_body list * value * meta
  | `Or of parser_body * parser_body * meta
  | `TakeLeft of parser_body * parser_body * meta
  | `TakeRight of parser_body * parser_body * meta
  | `Concat of parser_body * parser_body * meta
  | `Destructure of value * parser_body * meta
  | parser_literal ]
[@@deriving show]

and parser_apply_arg =
  [ `ParserArg of parser_body | `ValueArg of value | `LitArg of parser_literal ]
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
  | `Bool (_, meta)
  | `Null meta
  | `ValueArray (_, meta)
  | `ValueObject (_, meta)
  | `ValueId (_, meta)
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
