  $ possum -p "I <- int $ {I: 'foo'}" -i "23"
  
  Error Creating Object
  
  ~~~(##)'>  I wasn't able to create an object because one of the name/value pairs
  has a name which is not a string.
  
  The parser failed on line 1, characters 13-13:
  I <- int $ {I: 'foo'}
              ^
  
  The value assigned to `I` is a number, but it needs to be a string in order to
  create a valid object.
  [123]


  $ possum -p "object_sep(number, ':', alpha, ',')" -i "0:a,1:b"
  
  Error Creating Object
  
  ~~~(##)'>  I wasn't able to create an object because one of the name/value pairs
  has a name which is not a string.
  
  The parser failed on line 1, characters 12-17:
  object_sep(number, ':', alpha, ',')
             ^^^^^^
  
  This parser returned a number, but every returned value needs to be a string in
  order to create a valid object.
  [123]
