  $ possum -p "'my parser'" -i "no match here"
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 1:
  no match here
  ^
  
  The last attempted parser was:
  "my parser"
  
  But no match was found.
  [123]



  $ possum -p "10" -i "0010"
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 1:
  0010
  ^
  
  The last attempted parser was:
  10
  
  But no match was found.
  [123]



  $ possum -p "'one' < ' two' | ' four'" -i "one three"
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 4:
  one three
     ^
  
  The last attempted parser was:
  " four"
  
  But no match was found.
  [123]



  $ possum -p "word > 'DEF'" -i "ABCDEF"
  
  Error Parsing End of Input
  
  ~~~(##)'>  I reached the end of the input before completing the parser.
  
  The last attempted parser was:
  "DEF"
  
  But there's not enough input left to match on.
  [123]



  $ possum -p "int < end" -i "12three"
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 3:
  12three
    ^
  
  The last attempted parser was:
  end
  regex
  
  But no match was found.
  [123]



  $ possum -p "input(int)" -i "   12three   "
  
  Error Parsing Input
  
  ~~~(##)'>  I wasn't able to fully run your parser on the provided input.
  
  The parser failed on line 1, character 6:
     12three   
       ^
  
  The last attempted parser was:
  input
  end_of_input
  regex
  
  But no match was found.
  [123]

