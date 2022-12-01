open Angstrom
open Angstrom.Let_syntax
open Ast
open Parser
open! Base

(*
  Parser for transforming a program into an AST.
*)

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

let json_id : json_id Angstrom.t =
  (let%map start_pos = peek_pos
   and leading_underscores = take_while is_underscore
   and uppercase_chars = take_while1 is_uppercase
   and id_rest = take_while is_id_char
   and end_pos = peek_pos in
   let id_str =
     String.concat [ leading_underscores; uppercase_chars; id_rest ]
   in
   `JsonId (id_str, meta start_pos end_pos))
  <?> "json_id"

let id : id Angstrom.t =
  (let%map start_pos = peek_pos
   and leading_underscores = take_while is_underscore
   and first_char = satisfy is_alpha
   and id_rest = take_while is_id_char
   and end_pos = peek_pos in
   let id_str =
     String.concat [ leading_underscores; String.of_char first_char; id_rest ]
   in
   let meta = meta start_pos end_pos in
   if is_lowercase first_char then `ParserId (id_str, meta)
   else `JsonId (id_str, meta))
  <?> "id"

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

let true_lit : true_lit Angstrom.t =
  (let%map start_pos = peek_pos and _ = string "true" and end_pos = peek_pos in
   `True (meta start_pos end_pos))
  <?> "true"

let false_lit : false_lit Angstrom.t =
  (let%map start_pos = peek_pos and _ = string "false" and end_pos = peek_pos in
   `False (meta start_pos end_pos))
  <?> "false"

let null_lit : null_lit Angstrom.t =
  (let%map start_pos = peek_pos and _ = string "null" and end_pos = peek_pos in
   `Null (meta start_pos end_pos))
  <?> "null"

let json : json Angstrom.t =
  fix (fun json : json Angstrom.t ->
      let json_array_spread : json_array_member Angstrom.t =
        (let%map start_pos = peek_pos
         and j = string "..." *> json
         and end_pos = peek_pos in
         `JsonArraySpread (j, meta start_pos end_pos))
        <?> "json_array_spread"
      in
      let json_array_element : json_array_member Angstrom.t =
        (let%map start_pos = peek_pos and j = json and end_pos = peek_pos in
         `JsonArrayElement (j, meta start_pos end_pos))
        <?> "json_array_element"
      in
      let json_array_member : json_array_member Angstrom.t =
        peek_char_fail
        >>= (function '.' -> json_array_spread | _ -> json_array_element)
        <?> "json_array_member"
      in
      let json_array : json Angstrom.t =
        (let%map start_pos = peek_pos
         and arr =
           char '[' *> sep_by (char ',') (ws *> json_array_member <* ws)
           <* char ']'
         and end_pos = peek_pos in
         `JsonArray (arr, meta start_pos end_pos))
        <?> "json_array"
      in
      let json_object_spread : json_object_member Angstrom.t =
        (let%map start_pos = peek_pos
         and j = string "..." *> json
         and end_pos = peek_pos in
         `JsonObjectSpread (j, meta start_pos end_pos))
        <?> "json_object_spread"
      in
      let json_object_pair : json_object_member Angstrom.t =
        (let%map start_pos = peek_pos
         and n =
           peek_char_fail >>= function
           | '\'' ->
               (single_quote_string_lit :> json_object_member_name Angstrom.t)
           | '"' ->
               (double_quote_string_lit :> json_object_member_name Angstrom.t)
           | _ -> (json_id :> json_object_member_name Angstrom.t)
         and v = ws *> char ':' *> ws *> json
         and end_pos = peek_pos in
         `JsonObjectPair (n, v, meta start_pos end_pos))
        <?> "json_object_pair"
      in
      let json_object_member : json_object_member Angstrom.t =
        peek_char_fail
        >>= (function '.' -> json_object_spread | _ -> json_object_pair)
        <?> "json_object_member"
      in
      let json_object : json Angstrom.t =
        (let%map start_pos = peek_pos
         and o =
           char '{' *> ws *> sep_by (ws *> char ',' <* ws) json_object_member
           <* ws <* char '}'
         and end_pos = peek_pos in
         `JsonObject (o, meta start_pos end_pos))
        <?> "json_object"
      in
      ws *> peek_char_fail >>= function
      | '[' -> json_array
      | '{' -> json_object
      | '\'' -> (single_quote_string_lit :> json Angstrom.t)
      | '"' -> (double_quote_string_lit :> json Angstrom.t)
      | 't' -> (true_lit :> json Angstrom.t)
      | 'f' -> (false_lit :> json Angstrom.t)
      | 'n' -> (null_lit :> json Angstrom.t)
      | '-' -> (number_lit :> json Angstrom.t)
      | d when is_digit d -> (number_lit :> json Angstrom.t)
      | _ -> (json_id :> json Angstrom.t))
  <?> "json"

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
              | '[' | '{' -> (json :> permissive_parser_step Angstrom.t)
              | _ -> (
                  id >>= function
                  | `JsonId _ as j -> return j <?> "json_id"
                  | `ParserId (id_str, id_meta) as id -> (
                      peek_char >>= fun next_char ->
                      match (id_str, next_char) with
                      | _, Some '(' ->
                          (let%map args = parser_apply_args
                           and end_pos = peek_pos in
                           `ParserApply
                             (id, args, meta id_meta.start_pos end_pos))
                          <?> "parser_apply"
                      | "true", _ -> return (`True id_meta) <?> "true"
                      | "false", _ -> return (`False id_meta) <?> "false"
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
                 (`Assign, next_step) :: rest_steps)
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
      let%map first_step = step and rest_steps = infix_steps in
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
  let%map program = defs and _ = end_of_input <?> "end_of_input" in
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
