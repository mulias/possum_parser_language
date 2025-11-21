  $ possum $TESTDIR/arithmetic.possum -i '1 + 2'
  {
    "startpos": 0,
    "endpos": 5,
    "type": "add",
    "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
    "right": {"type": "num", "value": 2, "startpos": 4, "endpos": 5}
  }

  $ possum $TESTDIR/arithmetic.possum -i '1 + 2 * 3 - 4'
  {
    "startpos": 0,
    "endpos": 13,
    "type": "sub",
    "left": {
      "startpos": 0,
      "endpos": 9,
      "type": "add",
      "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
      "right": {
        "startpos": 4,
        "endpos": 9,
        "type": "mul",
        "left": {"type": "num", "value": 2, "startpos": 4, "endpos": 5},
        "right": {"type": "num", "value": 3, "startpos": 8, "endpos": 9}
      }
    },
    "right": {"type": "num", "value": 4, "startpos": 12, "endpos": 13}
  }

  $ possum $TESTDIR/arithmetic.possum -i 'a ? b : c == 0 ? d : e'
  {
    "startpos": 0,
    "endpos": 22,
    "type": "cond",
    "middle": {"type": "var", "value": "b", "startpos": 4, "endpos": 5},
    "left": {"type": "var", "value": "a", "startpos": 0, "endpos": 1},
    "right": {
      "startpos": 8,
      "endpos": 22,
      "type": "cond",
      "middle": {"type": "var", "value": "d", "startpos": 17, "endpos": 18},
      "left": {
        "startpos": 8,
        "endpos": 14,
        "type": "eql",
        "left": {"type": "var", "value": "c", "startpos": 8, "endpos": 9},
        "right": {"type": "num", "value": 0, "startpos": 13, "endpos": 14}
      },
      "right": {"type": "var", "value": "e", "startpos": 21, "endpos": 22}
    }
  }

  $ possum $TESTDIR/arithmetic.possum -i '--a[1 + 4 / b]! * 4 ^ 2'
  {
    "startpos": 0,
    "endpos": 23,
    "type": "mul",
    "left": {
      "startpos": 0,
      "endpos": 15,
      "type": "neg",
      "prefixed": {
        "startpos": 1,
        "endpos": 15,
        "type": "neg",
        "prefixed": {
          "startpos": 2,
          "endpos": 15,
          "type": "fac",
          "postfixed": {
            "startpos": 2,
            "index": {
              "startpos": 4,
              "endpos": 13,
              "type": "add",
              "left": {"type": "num", "value": 1, "startpos": 4, "endpos": 5},
              "right": {
                "startpos": 8,
                "endpos": 13,
                "type": "div",
                "left": {"type": "num", "value": 4, "startpos": 8, "endpos": 9},
                "right": {"type": "var", "value": "b", "startpos": 12, "endpos": 13}
              }
            },
            "endpos": 14,
            "type": "index",
            "postfixed": {"type": "var", "value": "a", "startpos": 2, "endpos": 3}
          }
        }
      }
    },
    "right": {
      "startpos": 18,
      "endpos": 23,
      "type": "exp",
      "left": {"type": "num", "value": 4, "startpos": 18, "endpos": 19},
      "right": {"type": "num", "value": 2, "startpos": 22, "endpos": 23}
    }
  }
