  $ possum -p "array_sep(P1 <-char & ws & P2 <-char $ [P1, P2], nl)" input_sample.txt
  [ [ "A", "Y" ], [ "B", "X" ], [ "C", "Z" ] ]

  $ possum input.parser input.txt
  [
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "paper", "end_goal": "draw" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "scissors" },
      { "hand_shape": "rock", "end_goal": "lose" }
    ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "paper" }, { "hand_shape": "paper", "end_goal": "draw" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "paper" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [ { "hand_shape": "rock" }, { "hand_shape": "rock", "end_goal": "lose" } ],
    [
      { "hand_shape": "rock" }, { "hand_shape": "scissors", "end_goal": "win" }
    ],
    [
      { "hand_shape": "paper" },
      { "hand_shape": "scissors", "end_goal": "win" }
    ]
  ]
