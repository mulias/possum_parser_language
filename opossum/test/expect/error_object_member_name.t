  $ possum -p "I <- int $ {I: 'foo'}" -i "23"
  
  Error Creating Object
  
  ~~~(##)'>  I wasn't able to create an object because one of the key/value pairs
  has a key which is not a string.
  
  The parser failed on line 1, characters 13-13:
  I <- int $ {I: 'foo'}
              ^
  
  The value assigned to `I` is a number, but it needs to be a string in order to
  create a valid object.
  [123]


  $ possum -p "object_sep(number, ':', alpha, ',')" -i "0:a,1:b"
  
  Error Creating Object
  
  ~~~(##)'>  I wasn't able to create an object because one of the key/value pairs
  has a key which is not a string.
  
  The parser failed on line 94, characters 4-4:
    {K: V, ...Rest}
     ^
  
  The value assigned to `K` is a number, but it needs to be a string in order to
  create a valid object.
  [123]
