Monkey 0:
  Starting items: 72, 97
  Operation: new = old * 13
  Test: divisible by 19
    If true: throw to monkey 5
    If false: throw to monkey 6

Monkey 1:
  Starting items: 55, 70, 90, 74, 95
  Operation: new = old * old
  Test: divisible by 7
    If true: throw to monkey 5
    If false: throw to monkey 0

Monkey 2:
  Starting items: 74, 97, 66, 57
  Operation: new = old + 6
  Test: divisible by 17
    If true: throw to monkey 1
    If false: throw to monkey 0

Monkey 3:
  Starting items: 86, 54, 53
  Operation: new = old + 2
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 2

Monkey 4:
  Starting items: 50, 65, 78, 50, 62, 99
  Operation: new = old + 3
  Test: divisible by 11
    If true: throw to monkey 3
    If false: throw to monkey 7

Monkey 5:
  Starting items: 90
  Operation: new = old + 4
  Test: divisible by 2
    If true: throw to monkey 4
    If false: throw to monkey 6

Monkey 6:
  Starting items: 88, 92, 63, 94, 96, 82, 53, 53
  Operation: new = old + 8
  Test: divisible by 5
    If true: throw to monkey 4
    If false: throw to monkey 7

Monkey 7:
  Starting items: 70, 60, 71, 69, 77, 70, 98
  Operation: new = old * 7
  Test: divisible by 3
    If true: throw to monkey 2
    If false: throw to monkey 3
