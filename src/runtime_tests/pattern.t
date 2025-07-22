  $ possum -p '4 -> (1 + 1 + 2)' -i '4'
  4

  $ possum -p '0 -> (1 + 1 + 2)' -i '0' 2>/dev/null || echo "should fail: 0 != 4"
  should fail: 0 != 4

  $ possum -p '5 -> (2 + 3)' -i '5'
  5

  $ possum -p '7 -> (2 + 3)' -i '7' 2>/dev/null || echo "should fail: 7 != 5"
  should fail: 7 != 5

  $ possum -p '10 -> (3 + 2 + 5)' -i '10'
  10

  $ possum -p 'X = 3; 7 -> (X + 4)' -i '7'
  7

  $ possum -p 'X = 3; 8 -> (X + 4)' -i '8' 2>/dev/null || echo "should fail: 8 != 7"
  should fail: 8 != 7

  $ possum -p 'X = 2; Y = 3; 5 -> (X + Y)' -i '5'
  5

  $ possum -p '6 -> (1 + X + 3) $ X' -i '6'
  2

  $ possum -p '8 -> (2 + X + 3) $ X' -i '8'
  3
