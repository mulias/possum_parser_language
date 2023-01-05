open Angstrom
open Angstrom.Let_syntax
open Ast
open Parser
open! Base

(* Parser for transforming a program into an AST. *)

(* Skip whitespace and comments *)
let comment = char '#' *> take_till is_eol

let ws = skip_many (comment <|> take_while1 is_ws)

let parser_id : parser_id Angstrom.t =
  (let%map start_pos = peek_pos
   and leading_underscores = take_while is_underscore
   and lowercase_chars = take_while1 is_lowercase
   and id_rest = take_while is_id_char
   and end_pos = peek_pos in
   let id_str =
     String.concat [ leading_underscores; lowercase_chars; id_rest ]
   in
   `ParserId (id_str, meta start_pos end_pos))
  <?> "parser_id"

let _value_id =
  let%map start_pos = peek_pos
  and leading_underscores = take_while is_underscore
  and uppercase_chars = take_while1 is_uppercase
  and id_rest = take_while is_id_char
  and end_pos = peek_pos in
  let id_str =
    String.concat [ leading_underscores; uppercase_chars; id_rest ]
  in
  `ValueId (id_str, meta start_pos end_pos)

let value_id : value_id Angstrom.t = _value_id <?> "value_id"

let _id =
  let%map start_pos = peek_pos
  and leading_underscores = take_while is_underscore
  and first_char = satisfy is_alpha
  and id_rest = take_while is_id_char
  and end_pos = peek_pos in
  let id_str =
    String.concat [ leading_underscores; String.of_char first_char; id_rest ]
  in
  let meta = meta start_pos end_pos in
  if is_lowercase first_char then `ParserId (id_str, meta)
  else `ValueId (id_str, meta)

let id : id Angstrom.t = _id <?> "id"

let _ignored_id =
  let%map start_pos = peek_pos
  and _ = string "_"
  and end_pos = peek_pos in
  `IgnoredId (meta start_pos end_pos)

let value_id_or_ignored_id : [ value_id | ignored_id ] Angstrom.t =
  _value_id <|> _ignored_id <?> "value_id_or_ignored_id"

let id_or_ignored_id : [ id | ignored_id ] Angstrom.t =
  _id <|> _ignored_id <?> "id_or_ignored_id"

let single_quote_string_lit : string_lit Angstrom.t =
  (let%map start_pos = peek_pos
   and s = surround ~left:'\'' ~right:'\'' ~escape:'\\'
   and end_pos = peek_pos in
   let s_without_escapes =
     s
     |> String.substr_replace_all ~pattern:{s|\\|s} ~with_:{s|\|s}
     |> String.substr_replace_all ~pattern:{s|\'|s} ~with_:{s|'|s}
   in
   `String (s_without_escapes, meta start_pos end_pos))
  <?> "string"

let double_quote_string_lit : string_lit Angstrom.t =
  (let%map start_pos = peek_pos
   and s = surround ~left:'"' ~right:'"' ~escape:'\\'
   and end_pos = peek_pos in
   let s_without_escapes =
     s
     |> String.substr_replace_all ~pattern:{s|\\|s} ~with_:{s|\|s}
     |> String.substr_replace_all ~pattern:{s|\"|s} ~with_:{s|"|s}
   in
   `String (s_without_escapes, meta start_pos end_pos))
  <?> "string"

let number_lit : [ int_lit | float_lit ] Angstrom.t =
  (let%map start_pos = peek_pos
   and number = int_or_float
   and end_pos = peek_pos in
   let meta = meta start_pos end_pos in
   match number with
   | `Intlit n -> `Intlit (n, meta)
   | `Floatlit s -> `Floatlit (s, meta))
  <?> "number"

let true_lit : bool_lit Angstrom.t =
  (let%map start_pos = peek_pos
   and _ = string "true"
   and end_pos = peek_pos in
   `Bool (true, meta start_pos end_pos))
  <?> "true"

let false_lit : bool_lit Angstrom.t =
  (let%map start_pos = peek_pos
   and _ = string "false"
   and end_pos = peek_pos in
   `Bool (false, meta start_pos end_pos))
  <?> "false"

let null_lit : null_lit Angstrom.t =
  (let%map start_pos = peek_pos
   and _ = string "null"
   and end_pos = peek_pos in
   `Null (meta start_pos end_pos))
  <?> "null"

let value_like : value_like Angstrom.t =
  fix (fun value_like : value_like Angstrom.t ->
      let value_array_spread : value_like_array_member Angstrom.t =
        (let%map start_pos = peek_pos
         and v = string "..." *> value_like
         and end_pos = peek_pos in
         `ValueLikeArraySpread (v, meta start_pos end_pos))
        <?> "value_like_array_spread"
      in
      let value_array_element : value_like_array_member Angstrom.t =
        (let%map start_pos = peek_pos
         and v = value_like
         and end_pos = peek_pos in
         `ValueLikeArrayElement (v, meta start_pos end_pos))
        <?> "value_like_array_element"
      in
      let value_array_member : value_like_array_member Angstrom.t =
        peek_char_fail
        >>= (function '.' -> value_array_spread | _ -> value_array_element)
        <?> "value_like_array_member"
      in
      let value_array : value_like Angstrom.t =
        (let%map start_pos = peek_pos
         and arr =
           char '[' *> sep_by (char ',') (ws *> value_array_member <* ws)
           <* char ']'
         and end_pos = peek_pos in
         `ValueLikeArray (arr, meta start_pos end_pos))
        <?> "value_like_array"
      in
      let value_object_spread : value_like_object_member Angstrom.t =
        (let%map start_pos = peek_pos
         and v = string "..." *> value_like
         and end_pos = peek_pos in
         `ValueLikeObjectSpread (v, meta start_pos end_pos))
        <?> "value_like_object_spread"
      in
      let value_object_pair : value_like_object_member Angstrom.t =
        (let%map start_pos = peek_pos
         and n =
           peek_char_fail >>= function
           | '\'' ->
               (single_quote_string_lit
                 :> value_like_object_member_name Angstrom.t)
           | '"' ->
               (double_quote_string_lit
                 :> value_like_object_member_name Angstrom.t)
           | _ ->
               (value_id_or_ignored_id
                 :> value_like_object_member_name Angstrom.t)
         and v = ws *> char ':' *> ws *> value_like
         and end_pos = peek_pos in
         `ValueLikeObjectPair (n, v, meta start_pos end_pos))
        <?> "value_like_object_pair"
      in
      let value_object_member : value_like_object_member Angstrom.t =
        peek_char_fail
        >>= (function '.' -> value_object_spread | _ -> value_object_pair)
        <?> "value_like_object_member"
      in
      let value_object : value_like Angstrom.t =
        (let%map start_pos = peek_pos
         and o =
           char '{' *> ws *> sep_by (ws *> char ',' <* ws) value_object_member
           <* ws
           <* char '}'
         and end_pos = peek_pos in
         `ValueLikeObject (o, meta start_pos end_pos))
        <?> "value_like_object"
      in
      ws *> peek_char_fail >>= function
      | '[' -> value_array
      | '{' -> value_object
      | '\'' -> (single_quote_string_lit :> value_like Angstrom.t)
      | '"' -> (double_quote_string_lit :> value_like Angstrom.t)
      | 't' -> (true_lit :> value_like Angstrom.t)
      | 'f' -> (false_lit :> value_like Angstrom.t)
      | 'n' -> (null_lit :> value_like Angstrom.t)
      | '-' -> (number_lit :> value_like Angstrom.t)
      | d when is_digit d -> (number_lit :> value_like Angstrom.t)
      | _ -> (value_id_or_ignored_id :> value_like Angstrom.t))
  <?> "value_like"

let parser_steps : permissive_parser_steps Angstrom.t =
  fix (fun parser_steps : permissive_parser_steps Angstrom.t ->
      let group : permissive_parser_step Angstrom.t =
        (let%map start_pos = peek_pos
         and group = char '(' *> ws *> parser_steps <* ws <* char ')'
         and end_pos = peek_pos in
         `Group (group, meta start_pos end_pos))
        <?> "group"
      in
      let regex : permissive_parser_step Angstrom.t =
        (let%map start_pos = peek_pos
         and s = surround ~left:'/' ~right:'/' ~escape:'\\'
         and end_pos = peek_pos in
         `Regex (s, meta start_pos end_pos))
        <?> "regex"
      in
      let parser_apply_args : permissive_parser_steps list Angstrom.t =
        peek_char
        >>= (function
              | Some '(' ->
                  char '(' *> sep_by (char ',') (ws *> parser_steps <* ws)
                  <* char ')'
              | _ -> return [])
        <?> "parser_apply_args"
      in
      let step : permissive_parser_step Angstrom.t =
        ws *> peek_char_fail
        >>= (function
              | '(' -> group
              | '/' -> regex
              | '\'' ->
                  (single_quote_string_lit :> permissive_parser_step Angstrom.t)
              | '"' ->
                  (double_quote_string_lit :> permissive_parser_step Angstrom.t)
              | '-' -> (number_lit :> permissive_parser_step Angstrom.t)
              | d when is_digit d ->
                  (number_lit :> permissive_parser_step Angstrom.t)
              | '[' | '{' -> (value_like :> permissive_parser_step Angstrom.t)
              | _ -> (
                  id_or_ignored_id >>= function
                  | `ValueId _ as v -> return v <?> "value_id"
                  | `IgnoredId _ as i -> return i <?> "ignored_id"
                  | `ParserId (id_str, id_meta) as id -> (
                      peek_char >>= fun next_char ->
                      match (id_str, next_char) with
                      | _, Some '(' ->
                          (let%map args = parser_apply_args
                           and end_pos = peek_pos in
                           `ParserApply
                             (id, args, meta id_meta.start_pos end_pos))
                          <?> "parser_apply"
                      | "true", _ -> return (`Bool (true, id_meta)) <?> "true"
                      | "false", _ ->
                          return (`Bool (false, id_meta)) <?> "false"
                      | "null", _ -> return (`Null id_meta) <?> "null"
                      | _, _ ->
                          return (`ParserApply (id, [], id_meta))
                          <?> "parser_apply")))
        <?> "step"
      in
      let infix_steps : (infix * permissive_parser_step) list Angstrom.t =
        fix (fun infix_steps ->
            ws *> peek_char >>= function
            | Some '|' ->
                let%map next_step = char '|' *> step <?> "infix"
                and rest_steps = infix_steps in
                (`Or, next_step) :: rest_steps
            | Some '>' ->
                let%map next_step = char '>' *> step <?> "infix"
                and rest_steps = infix_steps in
                (`TakeRight, next_step) :: rest_steps
            | Some '<' ->
                (let%map next_step = string "<-" *> step <?> "infix"
                 and rest_steps = infix_steps in
                 (`Destructure, next_step) :: rest_steps)
                <|> let%map next_step = char '<' *> step <?> "infix"
                    and rest_steps = infix_steps in
                    (`TakeLeft, next_step) :: rest_steps
            | Some '+' ->
                let%map next_step = char '+' *> step <?> "infix"
                and rest_steps = infix_steps in
                (`Concat, next_step) :: rest_steps
            | Some '&' ->
                let%map next_step = char '&' *> step <?> "infix"
                and rest_steps = infix_steps in
                (`And, next_step) :: rest_steps
            | Some '$' ->
                let%map next_step = char '$' *> step <?> "infix"
                and rest_steps = infix_steps in
                (`Return, next_step) :: rest_steps
            | _ -> return [])
        <?> "infix_steps"
      in
      let%map first_step = step
      and rest_steps = infix_steps in
      (first_step, rest_steps))
  <?> "parser_steps"

let named_parser : permissive_named_parser Angstrom.t =
  let params =
    peek_char
    >>= (function
          | Some '(' ->
              char '(' *> sep_by (char ',') (ws *> id <* ws) <* char ')'
          | _ -> return [])
    <?> "named_parser_params"
  in
  (let%map id = parser_id
   and p = option [] params
   and body = ws *> char '=' *> ws *> parser_steps in
   `NamedParser (id, p, body))
  <?> "named_parser"

let main_parser : permissive_main_parser Angstrom.t =
  (let%map body = parser_steps in
   `MainParser body)
  <?> "main_parser"

let program : permissive_program Angstrom.t =
  let named = (named_parser :> permissive_parser Angstrom.t) in
  let main = (main_parser :> permissive_parser Angstrom.t) in
  let defs =
    fix (fun defs ->
        ws *> (named <|> main) <* ws >>= fun def ->
        peek_char >>= function
        | Some ';' ->
            char ';' *> ws *> end_of_input *> return [ def ]
            <|> (char ';' *> defs >>= fun defs_rest -> return (def :: defs_rest))
        | _ -> return [ def ])
  in
  let%map program = defs
  and _ = end_of_input <?> "end_of_input" in
  `Program program

let parse (source : string) : permissive_program =
  Angstrom.Buffered.parse program |> fun ang ->
  Angstrom.Buffered.feed ang (`String source) |> fun ang ->
  Angstrom.Buffered.feed ang `Eof |> fun ang ->
  match ang with
  | Angstrom.Buffered.Done (_buf, ast) -> ast
  | Angstrom.Buffered.Fail (state, marks, msg) ->
      raise
        (Errors.ParseProgram
           { buf = state.buf; off = state.off; len = state.len; marks; msg })
  | Angstrom.Buffered.Partial _ -> raise Errors.Unexpected
