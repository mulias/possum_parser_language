# Possum CLI

NAME
       possum - A tiny text parsing language

SYNOPSIS
        possum [PARSER_FILE] [INPUT_FILE] [OPTIONS]

ARGUMENTS
        PARSER_FILE
            A parser program file to run on the input. This argument can be
            omitted if the -p or --parser flag is used instead. When PARSER_FILE
            is - read the parser from standard input.

        INPUT_FILE
           An input file to parse. This argument can be omitted if the -i or
           --input flag is used instead. When INPUT_FILE is - read the input
           from standard input.

OPTIONS
        -p PARSER, --parser=PARSER
            Parser program to run on the input, used in place of a parser file.

        -i INPUT, --input=INPUT
            Text to parse, used in place of an input file.

        --no-stdlib
            Do not import the standard library.

        --import=FILES
            Whitespace separated list of files. These files are interpreted in
            left-to-right order and any named parsers and values are added to
            the program environment. The main parser file is interpreted last
            and then the main parser is ran on the input.

       --error-format=[plain | json]
            Return errors as plain text or as JSON. Default is plain.

       --help
           Show this help text.

       --version
           Show version information.

       --docs=[overview | advanced | language | cli | stdlib]
           Show possum's documentation.

EXAMPLES
        See `possum --docs=overview` for extensive examples.

BUGS
        Report bugs to https://github.com/mulias/possum_parser_language/issues
