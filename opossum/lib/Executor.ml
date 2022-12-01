open! Base

let execute (program : Program.json Angstrom.t) (input : string) : Program.json
    =
  Angstrom.Buffered.parse program |> fun ang ->
  Angstrom.Buffered.feed ang (`String input) |> fun ang ->
  Angstrom.Buffered.feed ang `Eof |> fun ang ->
  match ang with
  | Angstrom.Buffered.Done (_buf, json) -> json
  | Angstrom.Buffered.Fail (state, marks, msg) ->
      raise
        (Errors.ParseInput
           { buf = state.buf; off = state.off; len = state.len; marks; msg })
  | Angstrom.Buffered.Partial _ -> raise Errors.Unexpected
