open! Core

(* Entry point for evaluating parser programs and then running the program to
   parse structured text into JSON. *)

let parse_exn (source : string) : Ast.program =
  source |> ProgramParser.parse |> AstTransformer.transform

let eval_exn (source : string) : Program.t =
  let ast = parse_exn source in
  let env = Env.init in
  PossumCore.load env ;
  PossumStdlib.load env ;
  match Evaluator.eval ast env with
  | Some program -> program
  | None -> raise Errors.MainNotFound

let execute_exn (source : string) (input : string) : Program.value =
  let program = eval_exn source in
  Executor.execute program input

let parse source = Errors.handle (fun () -> parse_exn source) ~source

let eval source = Errors.handle (fun () -> eval_exn source) ~source

let execute source input =
  Errors.handle (fun () -> execute_exn source input) ~source ~input
