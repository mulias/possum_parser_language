Advent of Code 2022 Day 11
https://adventofcode.com/2022/day/11

  $ possum $TESTDIR/input.possum $TESTDIR/input.txt
  [
    {
      "id": 0,
      "starting_items": [79, 98],
      "operation": {"left": "old", "operator": "*", "right": 19},
      "test": 23,
      "if_true": 2,
      "if_false": 3
    },
    {
      "id": 1,
      "starting_items": [54, 65, 75, 74],
      "operation": {"left": "old", "operator": "+", "right": 6},
      "test": 19,
      "if_true": 2,
      "if_false": 0
    },
    {
      "id": 2,
      "starting_items": [79, 60, 97],
      "operation": {"left": "old", "operator": "*", "right": "old"},
      "test": 13,
      "if_true": 1,
      "if_false": 3
    },
    {
      "id": 3,
      "starting_items": [74],
      "operation": {"left": "old", "operator": "+", "right": 3},
      "test": 17,
      "if_true": 0,
      "if_false": 1
    }
  ]
