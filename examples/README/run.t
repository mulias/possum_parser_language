  $ possum --parser='table_sep(int, ",", nl)' $TESTDIR/numbers.txt
  [
    [31, 88, 35, 24, 46, 48, 95, 42, 18, 43, 71, 32, 92, 62, 97, 63, 50, 2, 60, 58, 74, 66],
    [15, 87, 57, 34, 14, 3, 54, 93, 75, 22, 45, 10],
    [56, 12, 83, 30, 8, 76, 1, 78, 82, 39, 98, 37, 19, 26, 81, 64, 55, 41, 16, 4, 72, 5],
    [52, 80, 84, 67, 21, 86, 23, 91, 0, 68, 36, 13, 44, 20, 69, 40, 90],
    [96, 27, 77, 38, 49, 94, 47, 9, 65, 28, 59, 79, 6, 29, 61, 53, 11, 17, 73, 99, 25, 89, 51, 7, 33, 85, 70]
  ]

  $ possum $TESTDIR/lines_parser.possum $TESTDIR/lines.txt
  [
    {
      "from": [8, 0],
      "to": [0, 8]
    },
    {
      "from": [0, 9],
      "to": [5, 9]
    },
    {
      "from": [9, 4],
      "to": [3, 4]
    },
    {
      "from": [2, 2],
      "to": [2, 1]
    },
    {
      "from": [7, 0],
      "to": [7, 4]
    },
    {
      "from": [6, 4],
      "to": [2, 0]
    },
    {
      "from": [0, 9],
      "to": [2, 9]
    },
    {
      "from": [3, 4],
      "to": [1, 4]
    },
    {
      "from": [0, 0],
      "to": [8, 8]
    },
    {
      "from": [5, 5],
      "to": [8, 2]
    }
  ]

  $ possum $TESTDIR/lisp_ast $TESTDIR/fibonacci.rkt
  {
    "type": "program",
    "value": [
      {
        "type": "apply",
        "value": [
          {"type": "atom", "value": "define"},
          {
            "type": "apply",
            "value": [
              {"type": "atom", "value": "fib"},
              {"type": "atom", "value": "n"}
            ]
          },
          {
            "type": "apply",
            "value": [
              {"type": "atom", "value": "if"},
              {
                "type": "apply",
                "value": [
                  {"type": "atom", "value": "<="},
                  {"type": "atom", "value": "n"},
                  {"type": "number", "value": 1}
                ]
              },
              {"type": "atom", "value": "n"},
              {
                "type": "apply",
                "value": [
                  {"type": "atom", "value": "+"},
                  {
                    "type": "apply",
                    "value": [
                      {"type": "atom", "value": "fib"},
                      {
                        "type": "apply",
                        "value": [
                          {"type": "atom", "value": "-"},
                          {"type": "atom", "value": "n"},
                          {"type": "number", "value": 1}
                        ]
                      }
                    ]
                  },
                  {
                    "type": "apply",
                    "value": [
                      {"type": "atom", "value": "fib"},
                      {
                        "type": "apply",
                        "value": [
                          {"type": "atom", "value": "-"},
                          {"type": "atom", "value": "n"},
                          {"type": "number", "value": 2}
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
      },
      {
        "type": "apply",
        "value": [
          {"type": "atom", "value": "display"},
          {"type": "string", "value": "Fibonacci of 10 is "}
        ]
      },
      {
        "type": "apply",
        "value": [
          {"type": "atom", "value": "display"},
          {
            "type": "apply",
            "value": [
              {"type": "atom", "value": "fib"},
              {"type": "number", "value": 10}
            ]
          }
        ]
      }
    ]
  }

  $ possum $TESTDIR/fibonacci.possum --input=10
  "Fibonacci of 10 is 55"
