  $ possum $TESTDIR/arithmetic.possum -i '1 + 2'
  {
    "type": "add",
    "left": {"type": "num", "value": 1},
    "right": {"type": "num", "value": 2}
  }

  $ possum $TESTDIR/arithmetic.possum -i '1 + 2 * 3 - 4'
  {
    "type": "sub",
    "left": {
      "type": "add",
      "left": {"type": "num", "value": 1},
      "right": {
        "type": "mul",
        "left": {"type": "num", "value": 2},
        "right": {"type": "num", "value": 3}
      }
    },
    "right": {"type": "num", "value": 4}
  }

  $ possum $TESTDIR/arithmetic.possum -i 'a ? b : c == 0 ? d : e'
  {
    "type": "cond",
    "middle": {"type": "var", "value": "b"},
    "left": {"type": "var", "value": "a"},
    "right": {
      "type": "cond",
      "middle": {"type": "var", "value": "d"},
      "left": {
        "type": "eql",
        "left": {"type": "var", "value": "c"},
        "right": {"type": "num", "value": 0}
      },
      "right": {"type": "var", "value": "e"}
    }
  }

  $ possum $TESTDIR/arithmetic.possum -i '--a[1 + 4 / b]! * 4 ^ 2'
  {
    "type": "mul",
    "left": {
      "type": "neg",
      "prefixed": {
        "type": "neg",
        "prefixed": {
          "type": "fac",
          "postfixed": {
            "type": "index",
            "value": {
              "type": "add",
              "left": {"type": "num", "value": 1},
              "right": {
                "type": "div",
                "left": {"type": "num", "value": 4},
                "right": {"type": "var", "value": "b"}
              }
            },
            "postfixed": {"type": "var", "value": "a"}
          }
        }
      }
    },
    "right": {
      "type": "exp",
      "left": {"type": "num", "value": 4},
      "right": {"type": "num", "value": 2}
    }
  }
