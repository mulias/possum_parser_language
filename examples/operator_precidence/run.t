  $ possum $TESTDIR/arithmetic.possum -i '1 + 2'
  {
    "endpos": 5,
    "startpos": 0,
    "type": "add",
    "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
    "right": {"type": "num", "value": 2, "startpos": 4, "endpos": 5}
  }

  $ possum $TESTDIR/arithmetic.possum -i '1 + 2 * 3 - 4'
  {
    "endpos": 13,
    "startpos": 0,
    "type": "sub",
    "left": {
      "endpos": 9,
      "startpos": 0,
      "type": "add",
      "left": {"type": "num", "value": 1, "startpos": 0, "endpos": 1},
      "right": {
        "endpos": 9,
        "startpos": 4,
        "type": "mul",
        "left": {"type": "num", "value": 2, "startpos": 4, "endpos": 5},
        "right": {"type": "num", "value": 3, "startpos": 8, "endpos": 9}
      }
    },
    "right": {"type": "num", "value": 4, "startpos": 12, "endpos": 13}
  }

  $ possum $TESTDIR/arithmetic.possum -i 'a ? b : c == 0 ? d : e'
  {
    "middle": {"type": "var", "value": "b", "startpos": 4, "endpos": 5},
    "endpos": 22,
    "startpos": 0,
    "type": "cond",
    "left": {"type": "var", "value": "a", "startpos": 0, "endpos": 1},
    "right": {
      "middle": {"type": "var", "value": "d", "startpos": 17, "endpos": 18},
      "endpos": 22,
      "startpos": 8,
      "type": "cond",
      "left": {
        "endpos": 14,
        "startpos": 8,
        "type": "eql",
        "left": {"type": "var", "value": "c", "startpos": 8, "endpos": 9},
        "right": {"type": "num", "value": 0, "startpos": 13, "endpos": 14}
      },
      "right": {"type": "var", "value": "e", "startpos": 21, "endpos": 22}
    }
  }

  $ possum $TESTDIR/arithmetic.possum -i '--a[1 + 4 / b]! * 4 ^ 2'
  {
    "endpos": 23,
    "startpos": 0,
    "type": "mul",
    "left": {
      "endpos": 15,
      "startpos": 0,
      "type": "neg",
      "prefixed": {
        "endpos": 15,
        "startpos": 1,
        "type": "neg",
        "prefixed": {
          "endpos": 15,
          "startpos": 2,
          "type": "fac",
          "postfixed": {
            "endpos": 14,
            "index": {
              "endpos": 13,
              "startpos": 4,
              "type": "add",
              "left": {"type": "num", "value": 1, "startpos": 4, "endpos": 5},
              "right": {
                "endpos": 13,
                "startpos": 8,
                "type": "div",
                "left": {"type": "num", "value": 4, "startpos": 8, "endpos": 9},
                "right": {"type": "var", "value": "b", "startpos": 12, "endpos": 13}
              }
            },
            "startpos": 2,
            "type": "index",
            "postfixed": {"type": "var", "value": "a", "startpos": 2, "endpos": 3}
          }
        }
      }
    },
    "right": {
      "endpos": 23,
      "startpos": 18,
      "type": "exp",
      "left": {"type": "num", "value": 4, "startpos": 18, "endpos": 19},
      "right": {"type": "num", "value": 2, "startpos": 22, "endpos": 23}
    }
  }
