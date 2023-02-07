open! Core

let load (env : Program.env) : unit =
  let ast =
    PossumStdlibSource.read
    |> ProgramParser.parse `Stdlib
    |> AstTransformer.transform
  in
  let _program = Evaluator.eval ast env in
  ()
