open! Core

let read_file name = In_channel.read_all name

let execute (source : string) (input : string) : unit =
  match Main.execute source input with
  | Ok json -> Json.pretty_print json
  | Error msg ->
      Stdio.eprintf "%s\n" msg;
      Command.exit 1

let command =
  Command.basic ~summary:"Generate an MD5 hash of the input data"
    ~readme:(fun () -> "More detailed information")
    (let open Command.Let_syntax in
    let open Command.Param in
    let%map files = anon (sequence ("input/output files" %: string))
    and program = flag "-p" (optional string) ~doc:"Parser program"
    and input = flag "-i" (optional string) ~doc:"Input text" in
    fun () ->
      match (files, program, input) with
      | [ program_file; input_file ], None, None ->
          execute (read_file program_file) (read_file input_file)
      | [ program_file ], None, Some input ->
          execute (read_file program_file) input
      | [ input_file ], Some program, None ->
          execute program (read_file input_file)
      | [], Some program, Some input -> execute program input
      | _ -> ())

let run = Command_unix.run command
