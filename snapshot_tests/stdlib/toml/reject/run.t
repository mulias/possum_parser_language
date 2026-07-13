  $ for f in $TESTDIR/n_*.toml; do echo "$(basename $f)"; cat $f; echo "--------"; possum -p 'input(toml.tagged)' $f 2>err; grep -a '^\[' err; echo ""; done
  n_append_array_of_tables_element_to_array.toml
  fruits = []
  
  [[fruits]]
  --------
  [ParserFailure]
  
  n_append_array_of_tables_element_to_table.toml
  [fruit.physical]
  color = "red"
  shape = "round"
  
  [[fruit]]
  name = "apple"
  --------
  [ParserFailure]
  
  n_append_with_dotted_keys.toml
  # First a.b.c defines a table: a.b.c = {z=9}
  #
  # Then we define a.b.c.t = "str" to add a str to the above table, making it:
  #
  #   a.b.c = {z=9, t="..."}
  #
  # While this makes sense, logically, it was decided this is not valid TOML as
  # it's too confusing/convoluted.
  #
  # See: https://github.com/toml-lang/toml/issues/846
  #      https://github.com/toml-lang/toml/pull/859
  
  [a.b.c]
  z = 9
  
  [a]
  b.c.t = "Using dotted keys to add to [a.b.c] after explicitly defining it above is not allowed"
  --------
  {
    "a": {
      "b": {
        "c": {"z": 9, "t": "Using dotted keys to add to [a.b.c] after explicitly defining it above is not allowed"}
      }
    }
  }
  
  n_array_of_tables_header.toml
  [[table] ]
  --------
  [ParserFailure]
  
  n_empty_bare_key.toml
  = "no key name"
  --------
  [ParserFailure]
  
  n_empty_doc.toml
  # this file contains a comment and newline but no key/value pairs
  
  --------
  [ParserFailure]
  
  n_extend_defined_array_of_tables.toml
  [[tab.arr]]
  [tab]
  arr.val1=1
  --------
  [ParserFailure]
  
  n_extend_inline_table_with_table.toml
  [product]
  type = { name = "Nail" }
  type.edible = false
  --------
  [ParserFailure]
  
  n_extend_table_with_inline_table.toml
  [product]
  type.name = "Nail"
  type = { edible = false }
  --------
  [ParserFailure]
  
  n_floats.toml
  invalid_float_1 = .7
  invalid_float_2 = 7.
  invalid_float_3 = 3.e+20
  --------
  [ParserFailure]
  
  n_inline_table_trailing_comma.toml
  # A terminating comma (also called trailing comma) is not permitted after the
  # last key/value pair in an inline table
  abc = { abc = 123, }
  --------
  [ParserFailure]
  
  n_pair_no_newline.toml
  first = "Tom" last = "Preston-Werner"
  --------
  [ParserFailure]
  
  n_pair_unspecified_value.toml
  key =
  --------
  [ParserFailure]
  
  n_redefine_2.toml
  [t1]
  t2.t3.v = 0
  [t1.t2]
  --------
  {
    "t1": {
      "t2": {
        "t3": {"v": 0}
      }
    }
  }
  
  n_redefine_3.toml
  [t1]
  t2.t3.v = 0
  [t1.t2.t3]
  --------
  {
    "t1": {
      "t2": {
        "t3": {"v": 0}
      }
    }
  }
  
  n_repeated_bare_key.toml
  name = "Tom"
  name = "Pradyun"
  --------
  [ParserFailure]
  
  n_repeated_quoted_key.toml
  spelling = "favorite"
  "spelling" = "favourite"
  --------
  [ParserFailure]
  
  n_super_twice.toml
  [a.b]
  [a]
  [a]
  --------
  {
    "a": {
      "b": {}
    }
  }
  
  n_table_repeated_bare_key.toml
  [fruit]
  apple = "red"
  
  [fruit]
  orange = "orange"
  --------
  {
    "fruit": {"apple": "red", "orange": "orange"}
  }
  
  n_table_repeated_nested_key.toml
  [fruit]
  apple = "red"
  
  [fruit.apple]
  texture = "smooth"
  --------
  [ParserFailure]
  
  n_three_quotes_inside_multi_line_basic_string.toml
  str5 = """Here are three quotation marks: """"""
  --------
  [ParserFailure]
  
  n_three_quotes_inside_multi_line_literal_string.toml
  apos15 = '''Here are fifteen apostrophes: ''''''''''''''''''
  --------
  [ParserFailure]
  
  n_treat_non_table_value_as_table.toml
  # This defines the value of fruit.apple to be an integer.
  fruit.apple = 1
  
  # But then this treats fruit.apple like it's a table.
  # You can't turn an integer into a table.
  fruit.apple.smooth = true
  --------
  [ParserFailure]
  
