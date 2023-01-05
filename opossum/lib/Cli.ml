open! Base

let read_file name = Core.In_channel.read_all name

let execute (source : string) (input : string) : unit =
  match Main.execute source input with
  | Ok value -> Value.pretty_print_json value
  | Error msg ->
      Stdio.eprintf "%s\n" msg ;
      Caml.exit Cmdliner.Cmd.Exit.some_error

let possum files program input =
  match (files, program, input) with
  | [ program_file; input_file ], None, None ->
      `Ok (execute (read_file program_file) (read_file input_file))
  | [ program_file ], None, Some input ->
      `Ok (execute (read_file program_file) input)
  | [ input_file ], Some program, None ->
      `Ok (execute program (read_file input_file))
  | [], Some program, Some input -> `Ok (execute program input)
  | _, _, _ ->
      `Error
        ( true
        , "expected a parser file or the `--parser` option, and an input file \
           or the `--input` option" )

let run =
  let open Cmdliner in
  let files =
    let doc = "A parser program file to run and and an input file to parse" in
    Arg.(value & pos_all non_dir_file [] & info ~docv:"FILES" ~doc [])
  in
  let program =
    let doc = "Program used to parse input, used in place of a parser file" in
    Arg.(
      value
      & opt (some string) None
      & info [ "p"; "parser" ] ~docv:"PARSER" ~doc)
  in
  let input =
    let doc = "Text to parse, used in place of an input file" in
    Arg.(
      value & opt (some string) None & info [ "i"; "input" ] ~docv:"INPUT" ~doc)
  in
  let possum_term = Term.(ret (const possum $ files $ program $ input)) in
  let info =
    let doc = "A tiny text parsing language" in
    let man =
      [ `S Manpage.s_bugs
      ; `P
          "Report bugs to \
           https://github.com/mulias/possum_parser_language/issues"
      ]
    in
    Cmd.info "possum" ~version:"v0.2.0" ~doc ~exits:Cmd.Exit.defaults ~man
  in
  let possum_cmd = Cmd.v info possum_term in
  Caml.exit (Cmd.eval possum_cmd)
