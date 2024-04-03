Advent of Code 2022 Day 7
https://adventofcode.com/2022/day/7

  $ possum $TESTDIR/input.linear_parser $TESTDIR/input.txt
  [
    {
      "cmd": "cd",
      "dir": "/"
    },
    {
      "cmd": "ls",
      "output": [
        {
          "type": "dir",
          "name": "a"
        },
        {
          "type": "file",
          "size": 14848514,
          "name": "b.txt"
        },
        {
          "type": "file",
          "size": 8504156,
          "name": "c.dat"
        },
        {
          "type": "dir",
          "name": "d"
        }
      ]
    },
    {
      "cmd": "cd",
      "dir": "a"
    },
    {
      "cmd": "ls",
      "output": [
        {
          "type": "dir",
          "name": "e"
        },
        {
          "type": "file",
          "size": 29116,
          "name": "f"
        },
        {
          "type": "file",
          "size": 2557,
          "name": "g"
        },
        {
          "type": "file",
          "size": 62596,
          "name": "h.lst"
        }
      ]
    },
    {
      "cmd": "cd",
      "dir": "e"
    },
    {
      "cmd": "ls",
      "output": [
        {
          "type": "file",
          "size": 584,
          "name": "i"
        }
      ]
    },
    {
      "cmd": "cd",
      "dir": ".."
    },
    {
      "cmd": "cd",
      "dir": ".."
    },
    {
      "cmd": "cd",
      "dir": "d"
    },
    {
      "cmd": "ls",
      "output": [
        {
          "type": "file",
          "size": 4060174,
          "name": "j"
        },
        {
          "type": "file",
          "size": 8033020,
          "name": "d.log"
        },
        {
          "type": "file",
          "size": 5626152,
          "name": "d.ext"
        },
        {
          "type": "file",
          "size": 7214296,
          "name": "k"
        }
      ]
    }
  ]

  $ possum $TESTDIR/input.tree_parser $TESTDIR/input.txt
  {
    "name": "/",
    "files": [
      {
        "name": "b.txt",
        "size": 14848514
      },
      {
        "name": "c.dat",
        "size": 8504156
      }
    ],
    "subdirs": [
      {
        "name": "a",
        "files": [
          {
            "name": "f",
            "size": 29116
          },
          {
            "name": "g",
            "size": 2557
          },
          {
            "name": "h.lst",
            "size": 62596
          }
        ],
        "subdirs": [
          {
            "name": "e",
            "files": [
              {
                "name": "i",
                "size": 584
              }
            ],
            "subdirs": []
          }
        ]
      },
      {
        "name": "d",
        "files": [
          {
            "name": "j",
            "size": 4060174
          },
          {
            "name": "d.log",
            "size": 8033020
          },
          {
            "name": "d.ext",
            "size": 5626152
          },
          {
            "name": "k",
            "size": 7214296
          }
        ],
        "subdirs": []
      }
    ]
  }
