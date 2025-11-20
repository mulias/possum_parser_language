  $ possum $TESTDIR/arithmetic.possum -i '1 + 2'
  {
    "type": "add",
    "startpos": 0,
    "endpos": 5,
    "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
    "right": {"type": "num", "value": 2, "startpos": 4, "endpos": 5}
  }

  $ possum $TESTDIR/arithmetic.possum -i '1 + 2 * 3 - 4'
  {
    "type": "sub",
    "startpos": 0,
    "endpos": 13,
    "left": {
      "type": "add",
      "startpos": 0,
      "endpos": 9,
      "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
      "right": {
        "type": "mul",
        "startpos": 4,
        "endpos": 9,
        "left": {"type": "num", "value": 2, "startpos": 4, "endpos": 5},
        "right": {"type": "num", "value": 3, "startpos": 8, "endpos": 9}
      }
    },
    "right": {"type": "num", "value": 4, "startpos": 12, "endpos": 13}
  }

  $ possum $TESTDIR/arithmetic.possum -i 'a ? b : c == 0 ? d : e'
  {
    "type": "cond",
    "startpos": 0,
    "middle": {"type": "var", "value": "b", "startpos": 4, "endpos": 5},
    "endpos": 22,
    "left": {"type": "var", "value": "a", "startpos": 0, "endpos": 1},
    "right": {
      "type": "cond",
      "startpos": 8,
      "middle": {"type": "var", "value": "d", "startpos": 17, "endpos": 18},
      "endpos": 22,
      "left": {
        "type": "eql",
        "startpos": 8,
        "endpos": 14,
        "left": {"type": "var", "value": "c", "startpos": 8, "endpos": 9},
        "right": {"type": "num", "value": 0, "startpos": 13, "endpos": 14}
      },
      "right": {"type": "var", "value": "e", "startpos": 21, "endpos": 22}
    }
  }

  $ possum $TESTDIR/arithmetic.possum -i '--a[1 + 4 / b]! * 4 ^ 2'
  {
    "type": "mul",
    "startpos": 0,
    "endpos": 23,
    "left": {
      "type": "neg",
      "startpos": 0,
      "endpos": 15,
      "prefixed": {
        "type": "neg",
        "startpos": 1,
        "endpos": 15,
        "prefixed": {
          "type": "fac",
          "startpos": 2,
          "endpos": 15,
          "postfixed": {
            "index": {
              "type": "add",
              "startpos": 4,
              "endpos": 13,
              "left": {"type": "num", "value": 1, "startpos": 4, "endpos": 5},
              "right": {
                "type": "div",
                "startpos": 8,
                "endpos": 13,
                "left": {"type": "num", "value": 4, "startpos": 8, "endpos": 9},
                "right": {"type": "var", "value": "b", "startpos": 12, "endpos": 13}
              }
            },
            "type": "index",
            "startpos": 2,
            "endpos": 14,
            "postfixed": {"type": "var", "value": "a", "startpos": 2, "endpos": 3}
          }
        }
      }
    },
    "right": {
      "type": "exp",
      "startpos": 18,
      "endpos": 23,
      "left": {"type": "num", "value": 4, "startpos": 18, "endpos": 19},
      "right": {"type": "num", "value": 2, "startpos": 22, "endpos": 23}
    }
  }
