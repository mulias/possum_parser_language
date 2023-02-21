open Angstrom
open Angstrom.Let_syntax
open! Base

(* General use parser combinators. *)

let is_eol = function '\n' | '\r' -> true | _ -> false

let is_ws = function ' ' | '\t' | '\r' | '\n' -> true | _ -> false

let is_underscore = function '_' -> true | _ -> false

let is_lowercase = function 'a' .. 'z' -> true | _ -> false

let is_uppercase = function 'A' .. 'Z' -> true | _ -> false

let is_alpha a = is_lowercase a || is_uppercase a

let is_id_char = function
  | 'a' .. 'z' | 'A' .. 'Z' | '0' .. '9' | '_' -> true
  | _ -> false

let is_digit = function '0' .. '9' -> true | _ -> false

let is_one_nine = function '1' .. '9' -> true | _ -> false

let peek p =
  let peek_value = ref None in
  let assign_peak =
    p >>= fun value ->
    let _ = peek_value := Some value in
    fail "peek backtrack"
  in
  let return_peak =
    return () >>= fun _ ->
    match !peek_value with
    | Some v ->
        peek_value := None ;
        return v
    | None ->
        peek_value := None ;
        fail "peek fail"
  in
  assign_peak <|> return_peak

let peek_pos = pos

let peek_input =
  peek (skip_while (fun _ -> true)) >>= fun _ ->
  Unsafe.peek 0 (fun str ~off:_ ~len:_ -> Bigstringaf.to_string str)

let peek_line = peek (take_while (fun c -> not (is_eol c)))

let maybe p = option None (p >>| fun x -> Some x)

let number_integer_part =
  let multi_digit = consumed (satisfy is_one_nine *> take_while is_digit) in
  let single_digit = consumed (satisfy is_digit) in
  consumed (maybe (char '-') *> (multi_digit <|> single_digit))

let number_fraction_part = consumed (char '.' *> take_while1 is_digit)

let number_exponent_part =
  consumed
    ((char 'e' <|> char 'E')
    *> maybe (char '-' <|> char '+')
    *> take_while1 is_digit)

let int_or_float : [ `Intlit of string | `Floatlit of string ] Angstrom.t =
  let%map integer = number_integer_part
  and maybe_fraction = maybe number_fraction_part
  and maybe_exponent = maybe number_exponent_part in
  if Option.is_none maybe_fraction && Option.is_none maybe_exponent then
    `Intlit integer
  else
    `Floatlit
      (integer
      ^ Option.value maybe_fraction ~default:""
      ^ Option.value maybe_exponent ~default:"")

let regex (re : Re.re) (input : string) (pos : int) : Program.value Angstrom.t =
  let group_offsets =
    try Re.exec re input ~pos |> Re.Group.all_offset |> Array.to_list
    with Caml.Not_found -> []
  in
  let match_str s start_pos end_pos =
    `String (String.sub s ~pos:start_pos ~len:(end_pos - start_pos))
  in
  match group_offsets with
  | [ (start_match, end_match) ] when start_match = pos ->
      take (end_match - start_match) >>= fun substr -> return (`String substr)
  | (start_match, end_match) :: capture_groups when start_match = pos ->
      take (end_match - start_match) >>= fun substr ->
      let whole_match = `String substr in
      let capture_matches =
        List.map capture_groups ~f:(function
          | -1, -1 -> `String ""
          | start_capture, end_capture ->
              match_str input start_capture end_capture)
      in
      return (`List (whole_match :: capture_matches))
  | [] | [ (_, _) ] | (_, _) :: _ -> fail "no match"

let surround ~(left : char) ~(right : char) ~(escape : char) =
  char left
  *> scan_string `Next (fun state c ->
         match state with
         | `Next when Char.equal c right -> None
         | `Escaped when Char.equal c right -> Some `Next
         | `Escaped when Char.equal c escape -> Some `Next
         | _ when Char.equal c escape -> Some `Escaped
         | _ -> Some `Next)
  <* char right
