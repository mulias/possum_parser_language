Advent of Code 2022 Day 2
https://adventofcode.com/2022/day/2

  $ possum -p 'array_sep(char->P1&ws&char->P2$[P1,P2],nl)' $TESTDIR/input.txt
  [
    ["A", "Y"],
    ["B", "X"],
    ["C", "Z"]
  ]

  $ possum $TESTDIR/input.possum $TESTDIR/input.txt
  [
    [
      {"hand_shape": "rock"},
      {"hand_shape": "paper", "end_goal": "draw"}
    ],
    [
      {"hand_shape": "paper"},
      {"hand_shape": "rock", "end_goal": "lose"}
    ],
    [
      {"hand_shape": "scissors"},
      {"hand_shape": "scissors", "end_goal": "win"}
    ]
  ]
