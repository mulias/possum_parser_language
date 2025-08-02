  $ possum -p 'const({"a" + "b": 1})' -i ''
  {"ab": 1}

  $ possum -p 'const({"ab":2, "a" + "b": 1})' -i ''
  {"ab": 1}

  $ possum -p 'const({"a" + "b": 1, "ab":2})' -i ''
  {"ab": 2}

  $ possum -p 'const({"a": 1 + 3, "ab": 2})' -i ''
  {"ab": 2, "a": 4}

  $ possum -p 'Foo(K) = {K: 1, "b": 2, "a": 3} ; "" $ Foo("a")' -i ''
  {"b": 2, "a": 3}

