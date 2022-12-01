open! Base

type parse_error =
  { buf : Angstrom.bigstring
  ; off : int
  ; len : int
  ; marks : string list
  ; msg : string
  }

exception Unexpected

exception Todo of string

exception ParseProgram of parse_error

exception
  AstTransform of
    { expected : string; got : string; start_pos : int; end_pos : int }

exception EnvFindJson of { id : string; start_pos : int; end_pos : int }

exception EnvFindParser of { id : string; start_pos : int; end_pos : int }

exception EvalJsonArraySpread

exception EvalJsonObjectSpread

exception
  EvalJsonObjectMemberName of
    { id : string option; value : Program.json; start_pos : int; end_pos : int }

exception EvalNotEnoughArguments

exception EvalTooManyArguments

exception EvalJsonType of { expected : string; got : string }

exception EvalArgumentType of { expected : string; got : string }

exception
  EvalConcat of
    { side : [ `Left | `Right ]
    ; value : Program.json
    ; start_pos : int
    ; end_pos : int
    }

exception EvalRegexPattern of { start_pos : int; end_pos : int }

exception ParseInput of parse_error

exception MainNotFound

exception MultipleMainParsers of { start_pos : int; end_pos : int }

(* Word-wrap each line of `s` so that the lines are less than `at` in length. *)
let wrap_message (s : string) ~(at : int) : string =
  let wrap_line (l : string) : string =
    String.split l ~on:' '
    |> List.fold ~init:[] ~f:(fun acc word ->
           match acc with
           | [] -> [ word ]
           | line :: lines ->
               if String.length line + String.length word <= at then
                 (line ^ " " ^ word) :: lines
               else word :: acc)
    |> List.rev
    |> String.concat ~sep:"\n"
  in
  String.split_lines s |> List.map ~f:wrap_line |> String.concat ~sep:"\n"

(* Remove the start. middle, or end of `s` so that it's less than `max_width`
   and the characters from `window_start` to `window_end` remain visible. *)
let truncate_message
    (s : string)
    ~(window_start : int)
    ~(window_end : int)
    ~(max_width : int) : string =
  let len = String.length s in
  let window_len = window_end - window_start in
  if len < max_width then s
  else if window_end + 3 < max_width then
    String.sub s ~pos:0 ~len:(max_width - 3) ^ "..."
  else if window_len > max_width then
    let side_len = (max_width - 11) / 2 in
    String.concat
      [ "..."
      ; String.sub s ~pos:window_start ~len:side_len
      ; " ... "
      ; String.sub s ~pos:(window_end - side_len) ~len:side_len
      ; "..."
      ]
  else "..." ^ String.sub s ~pos:(len - window_end) ~len:(max_width - 3)

let char_forward_idx (str : string) ~(off : int) ~(char : char) : int option =
  String.lfindi str ~pos:off ~f:(fun _i c -> Char.equal c char)

let char_backward_idx (str : string) ~(off : int) ~(char : char) : int option =
  String.rfindi str ~pos:off ~f:(fun _i c -> Char.equal c char)

let line_start_idx (str : string) ~(off : int) : int =
  match char_backward_idx str ~off:(off - 1) ~char:'\n' with
  | Some n -> n + 1
  | None -> 0

let line_end_idx (str : string) ~(off : int) : int =
  Option.value
    (char_forward_idx str ~off ~char:'\n')
    ~default:(String.length str)

let line_number (str : string) ~(pos : int) : int =
  String.sub str ~pos:0 ~len:pos
  |> String.filter ~f:(Char.equal '\n')
  |> String.length
  |> fun s -> s + 1

let parse_error_context (source_or_input : string) ({ off; _ } : parse_error) :
    string =
  let start_line = line_start_idx source_or_input ~off in
  let end_line = line_end_idx source_or_input ~off in
  let line_number = line_number source_or_input ~pos:off in
  let error_pos = off - start_line + 1 in
  let error_line =
    String.sub source_or_input ~pos:start_line ~len:(end_line - start_line)
  in
  let pointer =
    (List.init (error_pos - 1) ~f:(Fn.const " ") |> String.concat) ^ "^"
  in
  [%string
    "line %{line_number#Int}, character %{error_pos#Int}:\n\
     %{error_line}\n\
     %{pointer}"]

let parse_path ({ marks; _ } : parse_error) : string =
  String.concat marks ~sep:"\n"

let error_context (source_or_input : string) ~(start_pos : int) ~(end_pos : int)
    : string =
  let start_first_line = line_start_idx source_or_input ~off:start_pos in
  let end_last_line = line_end_idx source_or_input ~off:end_pos in
  let line_number = line_number source_or_input ~pos:start_pos in
  let relative_start_pos = start_pos - start_first_line + 1 in
  let relative_end_pos = end_pos - start_first_line in
  let context =
    String.sub source_or_input ~pos:start_first_line
      ~len:(end_last_line - start_first_line)
  in
  let underline =
    (List.init (start_pos - start_first_line) ~f:(Fn.const " ") |> String.concat)
    ^ (List.init (end_pos - start_pos) ~f:(Fn.const "^") |> String.concat)
  in
  [%string
    "line %{line_number#Int}, characters \
     %{relative_start_pos#Int}-%{relative_end_pos#Int}:\n\
     %{context}\n\
     %{underline}"]

let handle ~(source : string) ?(input : string option) (f : unit -> 'a) :
    ('a, string) Result.t =
  try Ok (f ()) with
  | Todo msg -> Error ("Todo: " ^ msg)
  | ParseProgram parse_error ->
      let context = parse_error_context source parse_error in
      let parse_path = parse_path parse_error in
      let msg =
        [%string
          "\n\
           Error Reading Program\n\n\
           ~~~(##)'>  I ran into a syntax issue in your program.\n\n\
           The issue starts on %{context}\n\n\
           Eventually there will be a more helpful error message here, but in \
           the meantime here's the parsing steps leading up to the failure:\n\
           %{parse_path}\n\n\
           The last step did not succeed and there were no other options."]
        |> wrap_message ~at:80
      in
      Error msg
  | AstTransform { expected; got; start_pos; end_pos } ->
      let context = error_context source ~start_pos ~end_pos in
      let msg = [%string "Expected %{expected}, got %{got} at %{context}"] in
      Error msg
  | EnvFindJson { id; start_pos; end_pos } ->
      let context = error_context source ~start_pos ~end_pos in
      let msg =
        [%string
          "\n\
           Error Finding Value\n\n\
           ~~~(##)'>  I tried to look up the value associated with a variable \
           but couldn't find anything.\n\n\
           The value is used on %{context}\n\n\
           Variable `%{id}` is undefined."]
        |> wrap_message ~at:80
      in
      Error msg
  | EnvFindParser { id; start_pos; end_pos } ->
      let context = error_context source ~start_pos ~end_pos in
      let msg =
        [%string
          "\n\
           Error Finding Parser\n\n\
           ~~~(##)'>  I tried to look up the parser associated with a variable \
           but couldn't find anything.\n\n\
           The parser is used on %{context}\n\n\
           Variable `%{id}` is undefined."]
        |> wrap_message ~at:80
      in
      Error msg
  | EvalJsonArraySpread -> Error "EvalJsonArraySpread"
  | EvalJsonObjectSpread -> Error "EvalJsonObjectSpread"
  | EvalJsonObjectMemberName { id; value; start_pos; end_pos } ->
      let value_type = Json.type_string value in
      let value_description =
        match id with
        | Some id_str ->
            [%string
              "The value assigned to `%{id_str}` is a %{value_type}, but it \
               needs to be a string in order to create a valid object"]
        | None ->
            [%string
              "This parser returned a %{value_type}, but every returned value \
               needs to be a string in order to create a valid object"]
      in
      let context = error_context source ~start_pos ~end_pos in
      let msg =
        [%string
          "\n\
           Error Creating Object\n\n\
           ~~~(##)'>  I wasn't able to create an object because one of the \
           name/value pairs has a name which is not a string.\n\n\
           The parser failed on %{context}\n\n\
           %{value_description}."]
        |> wrap_message ~at:80
      in
      Error msg
  | EvalNotEnoughArguments -> Error "EvalNotEnoughArguments"
  | EvalTooManyArguments -> Error "EvalTooManyArguments"
  | EvalJsonType { expected; got } ->
      Error [%string "Expected %{expected}, got %{got}"]
  | EvalArgumentType { expected; got } ->
      Error [%string "Expected %{expected}, got %{got}"]
  | EvalConcat { side = left_or_right; value; start_pos; end_pos } ->
      let side =
        match left_or_right with `Left -> "left-side" | `Right -> "right-side"
      in
      let value_type = Json.type_string value in
      let context = error_context source ~start_pos ~end_pos in
      let msg =
        [%string
          "\n\
           Error Concatenating Strings\n\n\
           ~~~(##)'>  I successfully parsed two values, but couldn't \
           concatenate the result because at least one of the values is not a \
           string.\n\n\
           The parser failed on %{context}\n\n\
           The %{side} parser returned a %{value_type} instead of a string."]
        |> wrap_message ~at:80
      in
      Error msg
  | EvalRegexPattern { start_pos; end_pos } ->
      let context = error_context source ~start_pos ~end_pos in
      let msg =
        [%string
          "\n\
           Error Executing Regular Expression\n\n\
           ~~~(##)'>  I tried to parse your input with a regular expression \
           but the regex pattern failed to compile.\n\n\
           The malformed regex is on %{context}\n\n\
           there's likely a syntax issue in this pattern, but unfortunately I \
           don't have more specific insight into what went wrong."]
        |> wrap_message ~at:80
      in
      Error msg
  | ParseInput parse_error when String.equal parse_error.msg "not enough input"
    ->
      let parse_path = parse_path parse_error in
      let msg =
        [%string
          "\n\
           Error Parsing End of Input\n\n\
           ~~~(##)'>  I reached the end of the input before completing the \
           parser.\n\n\
           The last attempted parser was:\n\
           %{parse_path}\n\n\
           But there's not enough input left to match on."]
        |> wrap_message ~at:80
      in
      Error msg
  | ParseInput parse_error ->
      let context = parse_error_context (Option.value_exn input) parse_error in
      let parse_path = parse_path parse_error in
      let msg =
        [%string
          "\n\
           Error Parsing Input\n\n\
           ~~~(##)'>  I wasn't able to fully run your parser on the provided \
           input.\n\n\
           The parser failed on %{context}\n\n\
           The last attempted parser was:\n\
           %{parse_path}\n\n\
           But no match was found."]
        |> wrap_message ~at:80
      in
      Error msg
  | MainNotFound -> Error "MainNotFound"
  | MultipleMainParsers { start_pos; end_pos } ->
      let context = error_context source ~start_pos ~end_pos in
      let msg =
        [%string "Expected one main parser, found a second one at %{context}"]
        |> wrap_message ~at:80
      in
      Error msg
  | Unexpected -> Error "Unexpected Error"
