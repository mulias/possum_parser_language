Advent of Code 2022 Day 5
https://adventofcode.com/2022/day/5

  $ possum input.rows_parser input.txt
  {
    "cargo_rows": [
      [ null, "D", null ], [ "N", "C", null ], [ "Z", "M", "P" ]
    ],
    "steps": [
      { "count": 1, "from": "2", "to": "1" },
      { "count": 3, "from": "1", "to": "3" },
      { "count": 2, "from": "2", "to": "1" },
      { "count": 1, "from": "1", "to": "2" }
    ]
  }

  $ possum input.stacks_parser input.txt
  {
    "stacks": { "1": [ "Z", "N" ], "2": [ "M", "C", "D" ], "3": [ "P" ] },
    "steps": [
      { "count": 1, "from": "2", "to": "1" },
      { "count": 3, "from": "1", "to": "3" },
      { "count": 2, "from": "2", "to": "1" },
      { "count": 1, "from": "1", "to": "2" }
    ]
  }
