  $ possum $TESTDIR/produce_parser.possum $TESTDIR/produce.txt
  [
    {"Fruit": "Apple", "Price": 10, "Quantity": 5},
    {"Fruit": "Banana", "Price": 40, "Quantity": 8},
    {"Fruit": "Pear", "Price": 20, "Quantity": 2},
    {"Fruit": "Mango", "Price": 12, "Quantity": 20},
    {"Fruit": "Peach", "Price": 33, "Quantity": 1}
  ]

  $ possum $TESTDIR/schedule_parser.possum $TESTDIR/schedule.txt
  {
    "Monday": {"8am": "Dance", "9am": "Math", "10am": "Chemistry", "11am": "French", "12pm": "Geology", "1pm": "Lunch"},
    "Tuesday": {"8am": "Math", "9am": "French", "10am": "Kickboxing", "11am": "Nap", "12pm": "Lunch", "1pm": "Lunch"},
    "Wednesday": {"8am": "Dance", "9am": "Dance", "10am": "Dance", "11am": "Chemistry", "12pm": "Dance", "1pm": "Lunch"}
  }
