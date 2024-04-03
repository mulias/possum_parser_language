Advent of Code 2022 Day 2
https://adventofcode.com/2022/day/2

  $ possum -p 'array_sep(P1<-char&ws&P2<-char$[P1,P2],nl)' $TESTDIR/input.txt
  [
    [
      "A",
      "Y"
    ],
    [
      "B",
      "X"
    ],
    [
      "C",
      "Z"
    ]
  ]

  $ possum $TESTDIR/input.parser $TESTDIR/input.txt
  [
    [
      {
        "hand_shape": "rock"
      },
      {
        "hand_shape": "paper",
        "end_goal": "draw"
      }
    ],
    [
      {
        "hand_shape": "paper"
      },
      {
        "hand_shape": "rock",
        "end_goal": "lose"
      }
    ],
    [
      {
        "hand_shape": "scissors"
      },
      {
        "hand_shape": "scissors",
        "end_goal": "win"
      }
    ]
  ]
