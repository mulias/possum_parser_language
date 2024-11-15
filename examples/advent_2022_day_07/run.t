Advent of Code 2022 Day 7
https://adventofcode.com/2022/day/7

  $ possum $TESTDIR/input_linear.possum $TESTDIR/input.txt
  [
    {"cmd": "cd", "dir": "/"},
    {
      "cmd": "ls",
      "output": [
        {"type": "dir", "name": "a"},
        {"type": "file", "size": 14848514, "name": "b.txt"},
        {"type": "file", "size": 8504156, "name": "c.dat"},
        {"type": "dir", "name": "d"}
      ]
    },
    {"cmd": "cd", "dir": "a"},
    {
      "cmd": "ls",
      "output": [
        {"type": "dir", "name": "e"},
        {"type": "file", "size": 29116, "name": "f"},
        {"type": "file", "size": 2557, "name": "g"},
        {"type": "file", "size": 62596, "name": "h.lst"}
      ]
    },
    {"cmd": "cd", "dir": "e"},
    {
      "cmd": "ls",
      "output": [
        {"type": "file", "size": 584, "name": "i"}
      ]
    },
    {"cmd": "cd", "dir": ".."},
    {"cmd": "cd", "dir": ".."},
    {"cmd": "cd", "dir": "d"},
    {
      "cmd": "ls",
      "output": [
        {"type": "file", "size": 4060174, "name": "j"},
        {"type": "file", "size": 8033020, "name": "d.log"},
        {"type": "file", "size": 5626152, "name": "d.ext"},
        {"type": "file", "size": 7214296, "name": "k"}
      ]
    }
  ]

  $ possum $TESTDIR/input_tree.possum $TESTDIR/input.txt
  {
    "name": "/",
    "contains": [
      {"type": "dir", "name": "a"},
      {"type": "file", "name": "b.txt", "size": 14848514},
      {"type": "file", "name": "c.dat", "size": 8504156},
      {"type": "dir", "name": "d"}
    ],
    "subdirs": [
      {
        "name": "a",
        "contains": [
          {"type": "dir", "name": "e"},
          {"type": "file", "name": "f", "size": 29116},
          {"type": "file", "name": "g", "size": 2557},
          {"type": "file", "name": "h.lst", "size": 62596}
        ],
        "subdirs": [
          {
            "name": "e",
            "contains": [
              {"type": "file", "name": "i", "size": 584}
            ],
            "subdirs": []
          }
        ]
      },
      {
        "name": "d",
        "contains": [
          {"type": "file", "name": "j", "size": 4060174},
          {"type": "file", "name": "d.log", "size": 8033020},
          {"type": "file", "name": "d.ext", "size": 5626152},
          {"type": "file", "name": "k", "size": 7214296}
        ],
        "subdirs": []
      }
    ]
  }
