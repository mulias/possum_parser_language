open! Core

(* Entry point for evaluating parser programs and then running the program to
   parse structured text into JSON. *)

let parse_exn (source : string) : Ast.program =
  source |> ProgramParser.parse `Parser |> AstTransformer.transform

let eval_exn (source : string) : Program.t =
  let ast = parse_exn source in
  let env =
    Env.init |> PossumCore.extend_env |> PossumStdlib.extend_env |> Env.extend
  in
  match Evaluator.eval ast env with
  | Some program -> program
  | None -> raise Errors.MainNotFound

let execute_exn (source : string) (input : string) : Program.value =
  let program = eval_exn source in
  Executor.execute program input

let parse parser_source =
  Errors.handle (fun () -> parse_exn parser_source) ~parser_source

let eval parser_source =
  Errors.handle (fun () -> eval_exn parser_source) ~parser_source

let execute parser_source input =
  Errors.handle
    (fun () -> execute_exn parser_source input)
    ~parser_source ~input
