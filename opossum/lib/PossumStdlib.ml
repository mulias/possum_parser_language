open! Core

let extend_env (env : Program.env) : Program.env =
  let extended_env = Env.extend env in
  let ast =
    PossumStdlibSource.read
    |> ProgramParser.parse `Stdlib
    |> AstTransformer.transform
  in
  let _program = Evaluator.eval ast extended_env in
  extended_env
