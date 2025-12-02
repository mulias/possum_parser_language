  $ possum $TESTDIR/arithmetic.possum -i '1 + 2'
  {
    "type": "add",
    "endpos": 5,
    "startpos": 0,
    "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
    "right": {"type": "num", "value": 2, "startpos": 4, "endpos": 5}
  }

  $ possum $TESTDIR/arithmetic.possum -i '1 + 2 * 3 - 4'
  {
    "type": "sub",
    "endpos": 13,
    "startpos": 0,
    "left": {
      "type": "add",
      "endpos": 9,
      "startpos": 0,
      "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
      "right": {
        "type": "mul",
        "endpos": 9,
        "startpos": 4,
        "left": {"type": "num", "value": 2, "startpos": 4, "endpos": 5},
        "right": {"type": "num", "value": 3, "startpos": 8, "endpos": 9}
      }
    },
    "right": {"type": "num", "value": 4, "startpos": 12, "endpos": 13}
  }

  $ possum $TESTDIR/arithmetic.possum -i 'a ? b : c == 0 ? d : e'
  {
    "endpos": 22,
    "type": "cond",
    "middle": {"type": "var", "value": "b", "startpos": 4, "endpos": 5},
    "startpos": 0,
    "left": {"type": "var", "value": "a", "startpos": 0, "endpos": 1},
    "right": {
      "endpos": 22,
      "type": "cond",
      "middle": {"type": "var", "value": "d", "startpos": 17, "endpos": 18},
      "startpos": 8,
      "left": {
        "type": "eql",
        "endpos": 14,
        "startpos": 8,
        "left": {"type": "var", "value": "c", "startpos": 8, "endpos": 9},
        "right": {"type": "num", "value": 0, "startpos": 13, "endpos": 14}
      },
      "right": {"type": "var", "value": "e", "startpos": 21, "endpos": 22}
    }
  }

  $ possum $TESTDIR/arithmetic.possum -i '--a[1 + 4 / b]! * 4 ^ 2'
  {
    "type": "mul",
    "endpos": 23,
    "startpos": 0,
    "left": {
      "type": "neg",
      "endpos": 15,
      "startpos": 0,
      "prefixed": {
        "type": "neg",
        "endpos": 15,
        "startpos": 1,
        "prefixed": {
          "type": "fac",
          "endpos": 15,
          "startpos": 2,
          "postfixed": {
            "index": {
              "type": "add",
              "endpos": 13,
              "startpos": 4,
              "left": {"type": "num", "value": 1, "startpos": 4, "endpos": 5},
              "right": {
                "type": "div",
                "endpos": 13,
                "startpos": 8,
                "left": {"type": "num", "value": 4, "startpos": 8, "endpos": 9},
                "right": {"type": "var", "value": "b", "startpos": 12, "endpos": 13}
              }
            },
            "type": "index",
            "endpos": 14,
            "startpos": 2,
            "postfixed": {"type": "var", "value": "a", "startpos": 2, "endpos": 3}
          }
        }
      }
    },
    "right": {
      "type": "exp",
      "endpos": 23,
      "startpos": 18,
      "left": {"type": "num", "value": 4, "startpos": 18, "endpos": 19},
      "right": {"type": "num", "value": 2, "startpos": 22, "endpos": 23}
    }
  }
