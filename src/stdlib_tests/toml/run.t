  $ for f in $TESTDIR/y_*.toml; do echo "$(basename $f)"; cat $f; echo "--------"; possum -p 'input(toml.tagged)' $f; echo ""; done
  y_array_multi_line.toml
  integers2 = [
    1, 2, 3
  ]
  --------
  {
    "integers2": [1, 2, 3]
  }
  
  y_array_nested_inline_table.toml
  a = [ { b = {} } ]
  --------
  {
    "a": [
      {
        "b": {}
      }
    ]
  }
  
  y_array_of_inline_tables.toml
  points = [ { x = 1, y = 2, z = 3 },
             { x = 7, y = 8, z = 9 },
             { x = 2, y = 4, z = 8 } ]
  --------
  {
    "points": [
      {"x": 1, "y": 2, "z": 3},
      {"x": 7, "y": 8, "z": 9},
      {"x": 2, "y": 4, "z": 8}
    ]
  }
  
  y_array_of_tables.toml
  [[products]]
  name = "Hammer"
  sku = 738594937
  
  [[products]]  # empty table within the array
  
  [[products]]
  name = "Nail"
  sku = 284758393
  
  color = "gray"
  --------
  {
    "products": [
      {"name": "Hammer", "sku": 738594937},
      {},
      {"name": "Nail", "sku": 284758393, "color": "gray"}
    ]
  }
  
  y_array_of_tables_with_subtables.toml
  [[fruits]]
  name = "apple"
  
  [fruits.physical]  # subtable
  color = "red"
  shape = "round"
  
  [[fruits.varieties]]  # nested array of tables
  name = "red delicious"
  
  [[fruits.varieties]]
  name = "granny smith"
  
  
  [[fruits]]
  name = "banana"
  
  [[fruits.varieties]]
  name = "plantain"
  --------
  {
    "fruits": [
      {
        "name": "apple",
        "physical": {"color": "red", "shape": "round"},
        "varieties": [
          {"name": "red delicious"},
          {"name": "granny smith"}
        ]
      },
      {
        "name": "banana",
        "varieties": [
          {"name": "plantain"}
        ]
      }
    ]
  }
  
  y_array_trailing_comma.toml
  integers1 = [1, 2, 3,  ]
  
  integers2 = [
    1,
    2,
  ]
  --------
  {
    "integers1": [1, 2, 3],
    "integers2": [1, 2]
  }
  
  y_arrays.toml
  integers = [ 1, 2, 3 ]
  colors = [ "red", "yellow", "green" ]
  nested_arrays_of_ints = [ [ 1, 2 ], [3, 4, 5] ]
  nested_mixed_array = [ [ 1, 2 ], ["a", "b", "c"] ]
  string_array = [ "all", 'strings', """are the same""", '''type''' ]
  
  # Mixed-type arrays are allowed
  numbers = [ 0.1, 0.2, 0.5, 1, 2, 5 ]
  contributors = [
    "Foo Bar <foo@example.com>",
    { name = "Baz Qux", email = "bazqux@example.com", url = "https://example.com/bazqux" }
  ]
  
  dates = [
    1987-07-05T17:45:00Z,
    1979-05-27T07:32:00Z,
    2006-06-01T11:00:00Z,
  ]
  
  comments = [
    1,
    2, #this is ok
  ]
  --------
  {
    "integers": [1, 2, 3],
    "colors": ["red", "yellow", "green"],
    "nested_arrays_of_ints": [
      [1, 2],
      [3, 4, 5]
    ],
    "nested_mixed_array": [
      [1, 2],
      ["a", "b", "c"]
    ],
    "string_array": ["all", "strings", "are the same", "type"],
    "numbers": [0.1, 0.2, 0.5, 1, 2, 5],
    "contributors": [
      "Foo Bar <foo@example.com>",
      {"name": "Baz Qux", "email": "bazqux@example.com", "url": "https://example.com/bazqux"}
    ],
    "dates": [
      {"type": "datetime", "subtype": "offset", "value": "1987-07-05T17:45:00Z"},
      {"type": "datetime", "subtype": "offset", "value": "1979-05-27T07:32:00Z"},
      {"type": "datetime", "subtype": "offset", "value": "2006-06-01T11:00:00Z"}
    ],
    "comments": [1, 2]
  }
  
  y_bare_keys.toml
  key = "value"
  bare_key = "value"
  bare-key = "value"
  1234 = "value"
  --------
  {"key": "value", "bare_key": "value", "bare-key": "value", "1234": "value"}
  
  y_basic_string.toml
  str = "I'm a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF."
  --------
  {"str": "I'm a string. \\"You can quote me\\". Name\\tJos\xc3\xa9\\nLocation\\tSF."} (esc)
  
  y_binary_integer.toml
  bin1 = 0b11010110
  bin2 = 0b1_0_1
  --------
  {"bin1": 214, "bin2": 5}
  
  y_boolean.toml
  bool1 = true
  bool2 = false
  --------
  {"bool1": true, "bool2": false}
  
  y_comment.toml
  # This is a full-line comment
  key = "value"  # This is a comment at the end of a line
  another = "# This is not a comment"
  --------
  {"key": "value", "another": "# This is not a comment"}
  
  y_comments_everywhere.toml
  # Top comment.
   # Top comment.
  # Top comment.
  
  # [no-extraneous-groups-please]
  
  [group] # Comment
  answer = 42 # Comment
  # no-extraneous-keys-please = 999
  # Inbetween comment.
  more = [ # Comment
   # What about multiple # comments?
   # Can you handle it?
   #
           # Evil.
  # Evil.
   42, 42, # Comments within arrays are fun.
   # What about multiple # comments?
   # Can you handle it?
   #
           # Evil.
  # Evil.
  # ] Did I fool you?
  ] # Hopefully not.
  
  # Make sure the space between the datetime and "#" isn't lexed.
  dt = 1979-05-27T07:32:12-07:00  # c
  d = 1979-05-27 # Comment
  --------
  {
    "group": {
      "answer": 42,
      "more": [42, 42],
      "dt": {"type": "datetime", "subtype": "offset", "value": "1979-05-27T07:32:12-07:00"},
      "d": {"type": "datetime", "subtype": "date-local", "value": "1979-05-27"}
    }
  }
  
  y_date_local.toml
  ld1 = 1979-05-27
  --------
  {
    "ld1": {"type": "datetime", "subtype": "date-local", "value": "1979-05-27"}
  }
  
  y_date_time.toml
  space = 1987-07-05 17:45:00Z
  
  # ABNF is case-insensitive, both "Z" and "z" must be supported.
  lower = 1987-07-05t17:45:00z
  --------
  {
    "space": {"type": "datetime", "subtype": "offset", "value": "1987-07-05 17:45:00Z"},
    "lower": {"type": "datetime", "subtype": "offset", "value": "1987-07-05t17:45:00z"}
  }
  
  y_date_time_local.toml
  ldt1 = 1979-05-27T07:32:00
  ldt2 = 1979-05-27T00:32:00.999999
  local = 1987-07-05T17:45:00
  milli = 1977-12-21T10:32:00.555
  space = 1987-07-05 17:45:00
  --------
  {
    "ldt1": {"type": "datetime", "subtype": "local", "value": "1979-05-27T07:32:00"},
    "ldt2": {"type": "datetime", "subtype": "local", "value": "1979-05-27T00:32:00.999999"},
    "local": {"type": "datetime", "subtype": "local", "value": "1987-07-05T17:45:00"},
    "milli": {"type": "datetime", "subtype": "local", "value": "1977-12-21T10:32:00.555"},
    "space": {"type": "datetime", "subtype": "local", "value": "1987-07-05 17:45:00"}
  }
  
  y_date_time_offset.toml
  odt1 = 1979-05-27T07:32:00Z
  odt2 = 1979-05-27T00:32:00-07:00
  odt3 = 1979-05-27T00:32:00.999999-07:00
  odt4 = 1979-05-27 07:32:00Z
  --------
  {
    "odt1": {"type": "datetime", "subtype": "offset", "value": "1979-05-27T07:32:00Z"},
    "odt2": {"type": "datetime", "subtype": "offset", "value": "1979-05-27T00:32:00-07:00"},
    "odt3": {"type": "datetime", "subtype": "offset", "value": "1979-05-27T00:32:00.999999-07:00"},
    "odt4": {"type": "datetime", "subtype": "offset", "value": "1979-05-27 07:32:00Z"}
  }
  
  y_dotted_key_looks_like_float.toml
  3.14159 = "pi"
  --------
  {
    "3": {"14159": "pi"}
  }
  
  y_dotted_keys.toml
  name = "Orange"
  physical.color = "orange"
  physical.shape = "round"
  site."google.com" = true
  --------
  {
    "name": "Orange",
    "physical": {"color": "orange", "shape": "round"},
    "site": {"google.com": true}
  }
  
  y_dotted_keys_extra_whitespace.toml
  fruit.name = "banana"     # this is best practice
  fruit. color = "yellow"    # same as fruit.color
  fruit . flavor = "banana"   # same as fruit.flavor
  --------
  {
    "fruit": {"name": "banana", "color": "yellow", "flavor": "banana"}
  }
  
  y_dotted_keys_ordered.toml
  apple.type = "fruit"
  apple.skin = "thin"
  apple.color = "red"
  
  orange.type = "fruit"
  orange.skin = "thick"
  orange.color = "orange"
  --------
  {
    "apple": {"type": "fruit", "skin": "thin", "color": "red"},
    "orange": {"type": "fruit", "skin": "thick", "color": "orange"}
  }
  
  y_dotted_keys_out_of_order.toml
  # VALID BUT DISCOURAGED
  
  apple.type = "fruit"
  orange.type = "fruit"
  
  apple.skin = "thin"
  orange.skin = "thick"
  
  apple.color = "red"
  orange.color = "orange"
  --------
  {
    "apple": {"type": "fruit", "skin": "thin", "color": "red"},
    "orange": {"type": "fruit", "skin": "thick", "color": "orange"}
  }
  
  y_empty_quoted_key_nested.toml
  "".basic = "key after blank"
  --------
  {
    "": {"basic": "key after blank"}
  }
  
  y_empty_quoted_keys.toml
  "" = "blank"
  literal.'' = 'blank after key'
  --------
  {
    "": "blank",
    "literal": {"": "blank after key"}
  }
  
  y_empty_table.toml
  [table]
  --------
  {
    "table": {}
  }
  
  y_floats.toml
  # fractional
  flt1 = +1.0
  flt2 = 3.1415
  flt3 = -0.01
  
  # exponent
  flt4 = 5e+22
  flt5 = 1e06
  flt6 = -2E-2
  
  # both
  flt7 = 6.626e-34
  --------
  {"flt1": 1.0, "flt2": 3.1415, "flt3": -0.01, "flt4": 5e+22, "flt5": 1e06, "flt6": -2E-2, "flt7": 6.626e-34}
  
  y_floats_with_underscores.toml
  flt8 = 224_617.445_991_228
  before = 3_141.5927
  after = 3141.592_7
  exponent = 3e1_4
  --------
  {"flt8": 224617.445991228, "before": 3141.5927, "after": 3141.5927, "exponent": 3e14}
  
  y_hexadecimal_integer.toml
  hex1 = 0xDEADBEEF
  hex2 = 0xdeadbeef
  hex3 = 0xdead_beef
  hex4 = 0x00987
  --------
  {"hex1": 3735928559, "hex2": 3735928559, "hex3": 3735928559, "hex4": 2439}
  
  y_indentation.toml
    fruit.name = "banana"
        fruit. color = "yellow"
  
      fruit . flavor = "banana"
  --------
  {
    "fruit": {"name": "banana", "color": "yellow", "flavor": "banana"}
  }
  
  y_inline_tables.toml
  name = { first = "Tom", last = "Preston-Werner" }
  point = { x = 1, y = 2 }
  animal = { type.name = "pug" }
  
  [empty]
  empty1 = {}
  empty2 = { }
  empty_in_array = [ { not_empty = 1 }, {} ]
  empty_in_array2 = [{},{not_empty=1}]
  many_empty = [{},{},{}]
  nested_empty = {"empty"={}}
  with_cmt ={            }#nothing here
  --------
  {
    "name": {"first": "Tom", "last": "Preston-Werner"},
    "point": {"x": 1, "y": 2},
    "animal": {
      "type": {"name": "pug"}
    },
    "empty": {
      "empty1": {},
      "empty2": {},
      "empty_in_array": [
        {"not_empty": 1},
        {}
      ],
      "empty_in_array2": [
        {},
        {"not_empty": 1}
      ],
      "many_empty": [
        {},
        {},
        {}
      ],
      "nested_empty": {
        "empty": {}
      },
      "with_cmt": {}
    }
  }
  
  y_integers.toml
  int1 = +99
  int2 = 42
  int3 = 0
  int4 = -17
  --------
  {"int1": 99, "int2": 42, "int3": 0, "int4": -17}
  
  y_integers_with_underscores.toml
  int5 = 1_000
  int6 = 5_349_221
  int7 = 53_49_221  # Indian number system grouping
  int8 = 1_2_3_4_5  # VALID but discouraged
  --------
  {"int5": 1000, "int6": 5349221, "int7": 5349221, "int8": 12345}
  
  y_literal_strings.toml
  winpath  = 'C:\Users\nodejs\templates'
  winpath2 = '\\ServerX\admin$\system32\'
  quoted   = 'Tom "Dubs" Preston-Werner'
  regex    = '<\i\c*\s*>'
  --------
  {"winpath": "C:\\Users\\nodejs\\templates", "winpath2": "\\\\ServerX\\admin$\\system32\\", "quoted": "Tom \"Dubs\" Preston-Werner", "regex": "<\\i\\c*\\s*>"}
  
  y_multi_line_basic_string.toml
  str1 = """
  Roses are red
  Violets are blue"""
  --------
  {"str1": "Roses are red\nViolets are blue"}
  
  y_multi_line_basic_string_line_ending_backslash.toml
  # The following strings are byte-for-byte equivalent:
  str1 = "The quick brown fox jumps over the lazy dog."
  
  str2 = """
  The quick brown \
  
  
    fox jumps over \
      the lazy dog."""
  
  str3 = """\
         The quick brown \
         fox jumps over \
         the lazy dog.\
         """
  --------
  {"str1": "The quick brown fox jumps over the lazy dog.", "str2": "The quick brown fox jumps over the lazy dog.", "str3": "The quick brown fox jumps over the lazy dog."}
  
  y_multi_line_literal_strings.toml
  regex2 = '''I [dw]on't need \d{2} apples'''
  lines  = '''
  The first newline is
  trimmed in raw strings.
     All other whitespace
     is preserved.
  '''
  --------
  {"regex2": "I [dw]on't need \\d{2} apples", "lines": "The first newline is\ntrimmed in raw strings.\n   All other whitespace\n   is preserved.\n"}
  
  y_new_key_in_defined_table.toml
  # This makes the key "fruit" into a table.
  fruit.apple.smooth = true
  
  # So then you can add to the table "fruit" like so:
  fruit.orange = 2
  --------
  {
    "fruit": {
      "apple": {"smooth": true},
      "orange": 2
    }
  }
  
  y_octal_integer.toml
  oct1 = 0o01234567
  oct2 = 0o755 # useful for Unix file permissions
  oct3 = 0o7_6_5
  --------
  {"oct1": 342391, "oct2": 493, "oct3": 501}
  
  y_pair.toml
  key = "value"
  --------
  {"key": "value"}
  
  y_quoted_keys.toml
  "127.0.0.1" = "value"
  "character encoding" = "value"
  "\xca\x8e\xc7\x9d\xca\x9e" = "value" (esc)
  'key2' = "value"
  'quoted "value"' = "value"
  --------
  {"127.0.0.1": "value", "character encoding": "value", "\xca\x8e\xc7\x9d\xca\x9e": "value", "key2": "value", "quoted "value"": "value"} (esc)
  
  y_quotes_inside_multi_line_basic_string.toml
  str4 = """Here are two quotation marks: "". Simple enough."""
  str5 = """Here are three quotation marks: ""\"."""
  str6 = """Here are fifteen quotation marks: ""\"""\"""\"""\"""\"."""
  str7 = """"This," she said, "is just a pointless statement.""""
  --------
  {"str4": "Here are two quotation marks: \"\". Simple enough.", "str5": "Here are three quotation marks: \"\"\".", "str6": "Here are fifteen quotation marks: \"\"\"\"\"\"\"\"\"\"\"\"\"\"\".", "str7": "\"This,\" she said, \"is just a pointless statement.\""}
  
  y_quotes_inside_multi_line_literal_string.toml
  quot15 = '''Here are fifteen quotation marks: """""""""""""""'''
  
  apos15 = "Here are fifteen apostrophes: '''''''''''''''"
  
  str = ''''That,' she said, 'is still pointless.''''
  --------
  {"quot15": "Here are fifteen quotation marks: \"\"\"\"\"\"\"\"\"\"\"\"\"\"\"", "apos15": "Here are fifteen apostrophes: '''''''''''''''", "str": "'That,' she said, 'is still pointless.'"}
  
  y_root_table.toml
  fruit.apple.color = "red"
  # Defines a table named fruit
  # Defines a table named fruit.apple
  
  fruit.apple.taste.sweet = true
  # Defines a table named fruit.apple.taste
  # fruit and fruit.apple were already created
  --------
  {
    "fruit": {
      "apple": {
        "color": "red",
        "taste": {"sweet": true}
      }
    }
  }
  
  y_special_floats.toml
  sf0 = +0.0
  sf00 = -0.0
  
  sf1 = inf
  sf2 = +inf
  sf3 = -inf
  
  sf4 = nan
  sf5 = +nan
  sf6 = -nan
  --------
  {
    "sf0": 0.0,
    "sf00": -0.0,
    "sf1": {"type": "float", "subtype": "infinity", "value": "inf"},
    "sf2": {"type": "float", "subtype": "infinity", "value": "+inf"},
    "sf3": {"type": "float", "subtype": "infinity", "value": "-inf"},
    "sf4": {"type": "float", "subtype": "not-a-number", "value": "nan"},
    "sf5": {"type": "float", "subtype": "not-a-number", "value": "+nan"},
    "sf6": {"type": "float", "subtype": "not-a-number", "value": "-nan"}
  }
  
  y_sub_table.toml
  [fruit]
  apple.color = "red"
  apple.taste.sweet = true
  
  [fruit.apple.texture]
  smooth = true
  --------
  {
    "fruit": {
      "apple": {
        "color": "red",
        "taste": {"sweet": true},
        "texture": {"smooth": true}
      }
    }
  }
  
  y_table_dotted_keys.toml
  [dog."tater.man"]
  type.name = "pug"
  
  # [x] you
  # [x.y] don't
  # [x.y.z] need these
  [x.y.z.w] # for this to work
  
  [x] # defining a super-table afterward is ok
  --------
  {
    "dog": {
      "tater.man": {
        "type": {"name": "pug"}
      }
    },
    "x": {
      "y": {
        "z": {
          "w": {}
        }
      }
    }
  }
  
  y_table_dotted_keys_ordered.toml
  [fruit.apple]
  [fruit.orange]
  [animal]
  --------
  {
    "fruit": {
      "apple": {},
      "orange": {}
    },
    "animal": {}
  }
  
  y_table_dotted_keys_out_of_order.toml
  [fruit.apple]
  [animal]
  [fruit.orange]
  --------
  {
    "fruit": {
      "apple": {},
      "orange": {}
    },
    "animal": {}
  }
  
  y_table_key_extra_whitespace.toml
  [a.b.c]            # this is best practice
  [ d.e.f ]          # same as [d.e.f]
  [ g .  h  . i ]    # same as [g.h.i]
  [ j . "\xca\x9e" . 'l' ]  # same as [j."\xca\x9e".'l'] (esc)
  --------
  {
    "a": {
      "b": {
        "c": {}
      }
    },
    "d": {
      "e": {
        "f": {}
      }
    },
    "g": {
      "h": {
        "i": {}
      }
    },
    "j": {
      "\xca\x9e": { (esc)
        "l": {}
      }
    }
  }
  
  y_tables.toml
  [table-1]
  key1 = "some string"
  key2 = 123
  
  [table-2]
  key1 = "another string"
  key2 = 456
  --------
  {
    "table-1": {"key1": "some string", "key2": 123},
    "table-2": {"key1": "another string", "key2": 456}
  }
  
  y_time_local.toml
  lt1 = 07:32:00
  lt2 = 00:32:00.999999
  --------
  {
    "lt1": {"type": "datetime", "subtype": "time-local", "value": "07:32:00"},
    "lt2": {"type": "datetime", "subtype": "time-local", "value": "00:32:00.999999"}
  }
  
  y_top_level_table.toml
  # Top-level table begins.
  name = "Fido"
  breed = "pug"
  
  # Top-level table ends.
  [owner]
  name = "Regina Dogman"
  member_since = 1999-08-04
  --------
  {
    "name": "Fido",
    "breed": "pug",
    "owner": {
      "name": "Regina Dogman",
      "member_since": {"type": "datetime", "subtype": "date-local", "value": "1999-08-04"}
    }
  }
  

  $ for f in $TESTDIR/n_*.toml; do echo "$(basename $f)"; cat $f; echo "--------"; possum -p 'input(json)' $f; echo ""; done
  n_append_array_of_tables_element_to_array.toml
  fruits = []
  
  [[fruits]]
  --------
  Parser Failure
  
  n_append_array_of_tables_element_to_table.toml
  [fruit.physical]
  color = "red"
  shape = "round"
  
  [[fruit]]
  name = "apple"
  --------
  Parser Failure
  
  n_empty_bare_key.toml
  = "no key name"
  --------
  Parser Failure
  
  n_extend_inline_table_with_table.toml
  [product]
  type = { name = "Nail" }
  type.edible = false
  --------
  Parser Failure
  
  n_extend_table_with_inline_table.toml
  [product]
  type.name = "Nail"
  type = { edible = false }
  --------
  Parser Failure
  
  n_floats.toml
  invalid_float_1 = .7
  invalid_float_2 = 7.
  invalid_float_3 = 3.e+20
  --------
  Parser Failure
  
  n_pair_no_newline.toml
  first = "Tom" last = "Preston-Werner"
  --------
  Parser Failure
  
  n_pair_unspecified_value.toml
  key =
  --------
  Parser Failure
  
  n_repeated_bare_key.toml
  name = "Tom"
  name = "Pradyun"
  --------
  Parser Failure
  
  n_repeated_quoted_key.toml
  spelling = "favorite"
  "spelling" = "favourite"
  --------
  Parser Failure
  
  n_table_repeated_bare_key.toml
  [fruit]
  apple = "red"
  
  [fruit]
  orange = "orange"
  --------
  Parser Failure
  
  n_table_repeated_nested_key.toml
  [fruit]
  apple = "red"
  
  [fruit.apple]
  texture = "smooth"
  --------
  Parser Failure
  
  n_three_quotes_inside_multi_line_basic_string.toml
  str5 = """Here are three quotation marks: """."""
  --------
  Parser Failure
  
  n_three_quotes_inside_multi_line_literal_string.toml
  apos15 = '''Here are fifteen apostrophes: ''''''''''''''''''
  --------
  Parser Failure
  
  n_treat_non_table_value_as_table.toml
  # This defines the value of fruit.apple to be an integer.
  fruit.apple = 1
  
  # But then this treats fruit.apple like it's a table.
  # You can't turn an integer into a table.
  fruit.apple.smooth = true
  --------
  Parser Failure
  
