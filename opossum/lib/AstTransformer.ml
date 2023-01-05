open Ast
open! Base

let group_steps (steps : permissive_parser_steps) : parser_group_steps =
  let take_group ((first_step, steps) : permissive_parser_steps) :
      parser_group * (infix * permissive_parser_step) list =
    match
      List.split_while steps ~f:(function `Return, _ -> false | _ -> true)
    with
    | group, (`Return, group_return_step) :: rest ->
        let meta = merge_meta first_step group_return_step in
        (`Sequence ((first_step, group), group_return_step, meta), rest)
    | group, rest ->
        let group_meta = merge_steps_meta (first_step, group) in
        (`NonSequence ((first_step, group), group_meta), rest)
  in
  let rec group_infix_steps (steps : (infix * permissive_parser_step) list) :
      (infix * parser_group) list =
    match steps with
    | (infix, step) :: rest ->
        let group, next_steps = take_group (step, rest) in
        (infix, group) :: group_infix_steps next_steps
    | [] -> []
  in
  let group, rest = take_group steps in
  (group, group_infix_steps rest)

let rec value_of_value_like (value_like : value_like) : value =
  match value_like with
  | (`String _ | `Intlit _ | `Floatlit _ | `Bool _ | `Null _) as lit -> lit
  | `ValueLikeArray (arr, meta) -> value_of_array arr meta
  | `ValueLikeObject (assoc, meta) -> value_of_object assoc meta
  | `ValueId _ as id -> id
  | `IgnoredId meta -> raise (Errors.AstIgnoredId { meta })

and value_of_array arr meta : value =
  `ValueArray
    ( List.map arr ~f:(fun member : value_array_member ->
          match member with
          | `ValueLikeArrayElement (el, el_meta) ->
              `ValueArrayElement (value_of_value_like el, el_meta)
          | `ValueLikeArraySpread (el, el_meta) ->
              `ValueArraySpread (value_of_value_like el, el_meta))
    , meta )

and value_of_object assoc meta : value =
  `ValueObject
    ( List.map assoc ~f:(fun member : value_object_member ->
          match member with
          | `ValueLikeObjectPair (key, value, pair_meta) ->
              `ValueObjectPair
                (value_of_object_key key, value_of_value_like value, pair_meta)
          | `ValueLikeObjectSpread (el, el_meta) ->
              `ValueObjectSpread (value_of_value_like el, el_meta))
    , meta )

and value_of_object_key value =
  match value with
  | `String s -> `String s
  | `ValueId id -> `ValueId id
  | `IgnoredId meta -> raise (Errors.AstIgnoredId { meta })

let rec pattern_of_value_like (value_like : value_like) : pattern =
  match value_like with
  | (`String _ | `Intlit _ | `Floatlit _ | `Bool _ | `Null _) as lit -> lit
  | `ValueLikeArray (arr, meta) -> pattern_of_array arr meta
  | `ValueLikeObject (assoc, meta) -> pattern_of_object assoc meta
  | `ValueId _ as id -> id
  | `IgnoredId id -> `IgnoredId id

and pattern_of_array arr meta : pattern =
  `PatternArray
    ( List.map arr ~f:(fun member : pattern_array_member ->
          match member with
          | `ValueLikeArrayElement (el, el_meta) ->
              `PatternArrayElement (pattern_of_value_like el, el_meta)
          | `ValueLikeArraySpread (el, el_meta) ->
              `PatternArraySpread (pattern_of_value_like el, el_meta))
    , meta )

and pattern_of_object assoc meta : pattern =
  `PatternObject
    ( List.map assoc ~f:(fun member : pattern_object_member ->
          match member with
          | `ValueLikeObjectPair (key, value, pair_meta) ->
              `PatternObjectPair (key, pattern_of_value_like value, pair_meta)
          | `ValueLikeObjectSpread (el, el_meta) ->
              `PatternObjectSpread (pattern_of_value_like el, el_meta))
    , meta )

let rec parser_body_of_steps (steps : permissive_parser_steps) : parser_body =
  let parser_apply_argument_of_steps (steps : permissive_parser_steps) :
      parser_apply_arg =
    match steps with
    | single_step, [] -> (
        match single_step with
        | (`String _ | `Intlit _ | `Floatlit _) as lit -> `LitArg lit
        | ( `ValueLikeArray _ | `ValueLikeObject _ | `IgnoredId _ | `Bool _
          | `Null _ | `ValueId _ ) as value_like ->
            `ValueArg (value_of_value_like value_like)
        | `Group _ | `ParserApply _ | `Regex _ ->
            `ParserArg (parser_body_of_steps steps))
    | steps -> `ParserArg (parser_body_of_steps steps)
  in
  let body_of_step (step : permissive_parser_step) : parser_body =
    match step with
    | `Group (group_steps, _meta) -> parser_body_of_steps group_steps
    | `ParserApply (id, params, meta) ->
        `ParserApply
          (id, List.map params ~f:parser_apply_argument_of_steps, meta)
    | `Regex (regex, meta) -> `Regex (regex, meta)
    | (`String _ | `Intlit _ | `Floatlit _) as lit -> lit
    | `IgnoredId meta -> raise (Errors.AstIgnoredId { meta })
    | (`ValueLikeArray _ | `ValueLikeObject _ | `ValueId _ | `Bool _ | `Null _)
      as value ->
        let meta = get_meta value in
        raise
          (Errors.AstTransform
             { expected = "parser"
             ; got = "value"
             ; start_pos = meta.start_pos
             ; end_pos = meta.end_pos
             })
  in
  let value_of_step (step : permissive_parser_step) : value =
    match step with
    | (`String _ | `Intlit _ | `Floatlit _ | `Bool _ | `Null _) as lit -> lit
    | (`ValueLikeArray _ | `ValueLikeObject _ | `ValueId _ | `IgnoredId _) as
      value_like ->
        value_of_value_like value_like
    | `ParserApply (`ParserId ("true", _meta), [], meta) -> `Bool (true, meta)
    | `ParserApply (`ParserId ("false", _meta), [], meta) -> `Bool (false, meta)
    | `ParserApply (`ParserId ("null", _meta), [], meta) -> `Null meta
    | `Group (_, meta) | `ParserApply (_, _, meta) | `Regex (_, meta) ->
        raise
          (Errors.AstTransform
             { expected = "value"
             ; got = "parser"
             ; start_pos = meta.start_pos
             ; end_pos = meta.end_pos
             })
  in
  let pattern_of_step (step : permissive_parser_step) : pattern =
    match step with
    | ( `String _ | `Intlit _ | `Floatlit _ | `ValueLikeArray _
      | `ValueLikeObject _ | `IgnoredId _ | `Bool _ | `Null _ | `ValueId _ ) as
      value_like ->
        pattern_of_value_like value_like
    | `Group (_, meta) | `ParserApply (_, _, meta) | `Regex (_, meta) ->
        raise
          (Errors.AstTransform
             { expected = "pattern"
             ; got = "parser"
             ; start_pos = meta.start_pos
             ; end_pos = meta.end_pos
             })
  in
  let rec body_of_non_sequence (steps : permissive_parser_steps) (end_pos : int)
      : parser_body =
    match steps with
    | left, [] -> body_of_step left
    | left, (`Or, right) :: rest ->
        let left_meta = get_meta left in
        `Or
          ( body_of_step left
          , body_of_non_sequence (right, rest) end_pos
          , meta left_meta.start_pos end_pos )
    | left, (`TakeLeft, right) :: rest ->
        let left_meta = get_meta left in
        `TakeLeft
          ( body_of_step left
          , body_of_non_sequence (right, rest) end_pos
          , meta left_meta.start_pos end_pos )
    | left, (`TakeRight, right) :: rest ->
        let left_meta = get_meta left in
        `TakeRight
          ( body_of_step left
          , body_of_non_sequence (right, rest) end_pos
          , meta left_meta.start_pos end_pos )
    | left, (`Concat, right) :: rest ->
        let left_meta = get_meta left in
        `Concat
          ( body_of_step left
          , body_of_non_sequence (right, rest) end_pos
          , meta left_meta.start_pos end_pos )
    | left, (`Destructure, right) :: rest ->
        let left_meta = get_meta left in
        `Destructure
          ( pattern_of_step left
          , body_of_non_sequence (right, rest) end_pos
          , meta left_meta.start_pos end_pos )
    | left, (`And, _) :: _ | left, (`Return, _) :: _ ->
        let left_meta = get_meta left in
        raise
          (Errors.AstTransform
             { expected = "And inside of sequence"
             ; got = "And without sequence Return"
             ; start_pos = left_meta.start_pos
             ; end_pos
             })
  in
  let rec body_of_sequence ((first_step, steps) : permissive_parser_steps) :
      parser_body list =
    match
      List.split_while steps ~f:(function `And, _ -> false | _ -> true)
    with
    | non_sequence_steps, [] ->
        let non_sequence_steps = (first_step, non_sequence_steps) in
        let meta = merge_steps_meta non_sequence_steps in
        [ body_of_non_sequence non_sequence_steps meta.end_pos ]
    | non_sequence_steps, (`And, next_step) :: rest_steps ->
        let non_sequence_steps = (first_step, non_sequence_steps) in
        let meta = merge_steps_meta non_sequence_steps in
        body_of_non_sequence non_sequence_steps meta.end_pos
        :: body_of_sequence (next_step, rest_steps)
    | _ -> raise Errors.Unexpected
  in
  let body_of_group (group : parser_group) : parser_body =
    match group with
    | `Sequence (steps, return_step, meta) ->
        `Sequence (body_of_sequence steps, value_of_step return_step, meta)
    | `NonSequence (steps, meta) -> body_of_non_sequence steps meta.end_pos
  in
  let rec parser_body_of_group_steps (groups : parser_group_steps) : parser_body
      =
    match groups with
    | left, [] -> body_of_group left
    | left, (`Or, right) :: rest ->
        `Or
          ( body_of_group left
          , parser_body_of_group_steps (right, rest)
          , merge_meta left right )
    | left, (`TakeLeft, right) :: rest ->
        `TakeLeft
          ( body_of_group left
          , parser_body_of_group_steps (right, rest)
          , merge_meta left right )
    | left, (`TakeRight, right) :: rest ->
        `TakeRight
          ( body_of_group left
          , parser_body_of_group_steps (right, rest)
          , merge_meta left right )
    | left, (`Concat, right) :: rest ->
        `Concat
          ( body_of_group left
          , parser_body_of_group_steps (right, rest)
          , merge_meta left right )
    | left, (`Destructure, right) :: _ ->
        let meta = merge_meta left right in
        raise
          (Errors.AstTransform
             { expected = "value"
             ; got = "parser"
             ; start_pos = meta.start_pos
             ; end_pos = meta.end_pos
             })
    | left, (`And, right) :: _ | left, (`Return, right) :: _ ->
        let meta = merge_meta left right in
        raise
          (Errors.AstTransform
             { expected = "parser body"
             ; got = "And or Return without Sequence"
             ; start_pos = meta.start_pos
             ; end_pos = meta.end_pos
             })
  in
  steps |> group_steps |> parser_body_of_group_steps

let program_of_permissive_program (`Program parsers : permissive_program) :
    program =
  let main_parsers, named_parsers =
    List.partition_map parsers ~f:(function
      | `MainParser steps ->
          let body = parser_body_of_steps steps in
          let meta = get_meta body in
          Either.First (body, meta)
      | `NamedParser (name, params, steps) ->
          let body = parser_body_of_steps steps in
          let meta = merge_meta name body in
          Either.Second (name, params, body, meta))
  in
  match main_parsers with
  | [ main_parser ] -> Program { main_parser; named_parsers }
  | [] -> raise Errors.MainNotFound
  | _main_1 :: (_main_2_body, main_2_meta) :: _rest ->
      raise
        (Errors.MultipleMainParsers
           { start_pos = main_2_meta.start_pos; end_pos = main_2_meta.end_pos })

let transform = program_of_permissive_program
