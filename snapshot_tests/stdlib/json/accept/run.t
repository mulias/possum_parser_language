  $ for f in $TESTDIR/y_*.json; do echo "$(basename $f)"; cat $f; echo ""; possum -p 'input(json)' $f; echo ""; done
  y_array_arraysWithSpaces.json
  [[]   ]
  [
    []
  ]
  
  y_array_empty-string.json
  [""]
  [""]
  
  y_array_empty.json
  []
  []
  
  y_array_ending_with_newline.json
  ["a"]
  ["a"]
  
  y_array_false.json
  [false]
  [false]
  
  y_array_heterogeneous.json
  [null, 1, "1", {}]
  [
    null,
    1,
    "1",
    {}
  ]
  
  y_array_null.json
  [null]
  [null]
  
  y_array_with_1_and_newline.json
  [1
  ]
  [1]
  
  y_array_with_leading_space.json
   [1]
  [1]
  
  y_array_with_several_null.json
  [1,null,null,null,2]
  [1, null, null, null, 2]
  
  y_array_with_trailing_space.json
  [2] 
  [2]
  
  y_number.json
  [123e65]
  [123e65]
  
  y_number_0e+1.json
  [0e+1]
  [0e+1]
  
  y_number_0e1.json
  [0e1]
  [0e1]
  
  y_number_after_space.json
  [ 4]
  [4]
  
  y_number_double_close_to_zero.json
  [-0.000000000000000000000000000000000000000000000000000000000000000000000000000001]
  
  [-0.000000000000000000000000000000000000000000000000000000000000000000000000000001]
  
  y_number_int_with_exp.json
  [20e1]
  [20e1]
  
  y_number_minus_zero.json
  [-0]
  [-0]
  
  y_number_negative_int.json
  [-123]
  [-123]
  
  y_number_negative_one.json
  [-1]
  [-1]
  
  y_number_negative_zero.json
  [-0]
  [-0]
  
  y_number_real_capital_e.json
  [1E22]
  [1E22]
  
  y_number_real_capital_e_neg_exp.json
  [1E-2]
  [1E-2]
  
  y_number_real_capital_e_pos_exp.json
  [1E+2]
  [1E+2]
  
  y_number_real_exponent.json
  [123e45]
  [123e45]
  
  y_number_real_fraction_exponent.json
  [123.456e78]
  [123.456e78]
  
  y_number_real_neg_exp.json
  [1e-2]
  [1e-2]
  
  y_number_real_pos_exponent.json
  [1e+2]
  [1e+2]
  
  y_number_simple_int.json
  [123]
  [123]
  
  y_number_simple_real.json
  [123.456789]
  [123.456789]
  
  y_object.json
  {"asd":"sdf", "dfg":"fgh"}
  {"asd": "sdf", "dfg": "fgh"}
  
  y_object_basic.json
  {"asd":"sdf"}
  {"asd": "sdf"}
  
  y_object_duplicated_key.json
  {"a":"b","a":"c"}
  {"a": "c"}
  
  y_object_duplicated_key_and_value.json
  {"a":"b","a":"b"}
  {"a": "b"}
  
  y_object_empty.json
  {}
  {}
  
  y_object_empty_key.json
  {"":0}
  {"": 0}
  
  y_object_extreme_numbers.json
  { "min": -1.0e+28, "max": 1.0e+28 }
  {"min": -1.0e+28, "max": 1.0e+28}
  
  y_object_long_strings.json
  {"x":[{"id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}], "id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
  {
    "x": [
      {"id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"}
    ],
    "id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }
  
  y_object_simple.json
  {"a":[]}
  {
    "a": []
  }
  
  y_object_string_unicode.json
  {"title":"\u041f\u043e\u043b\u0442\u043e\u0440\u0430 \u0417\u0435\u043c\u043b\u0435\u043a\u043e\u043f\u0430" }
  {"title": "\xd0\x9f\xd0\xbe\xd0\xbb\xd1\x82\xd0\xbe\xd1\x80\xd0\xb0 \xd0\x97\xd0\xb5\xd0\xbc\xd0\xbb\xd0\xb5\xd0\xba\xd0\xbe\xd0\xbf\xd0\xb0"} (esc)
  
  y_object_with_newlines.json
  {
  "a": "b"
  }
  {"a": "b"}
  
  y_string_1_2_3_bytes_UTF-8_sequences.json
  ["\u0060\u012a\u12AB"]
  ["`\xc4\xaa\xe1\x8a\xab"] (esc)
  
  y_string_accepted_surrogate_pair.json
  ["\uD801\udc37"]
  ["\xf0\x90\x90\xb7"] (esc)
  
  y_string_accepted_surrogate_pairs.json
  ["\ud83d\ude39\ud83d\udc8d"]
  ["\xf0\x9f\x98\xb9\xf0\x9f\x92\x8d"] (esc)
  
  y_string_allowed_escapes.json
  ["\"\\\/\b\f\n\r\t"]
  ["\"\\/\b\f\n\r\t"]
  
  y_string_backslash_and_u_escaped_zero.json
  ["\\u0000"]
  ["\\u0000"]
  
  y_string_backslash_doublequotes.json
  ["\""]
  ["\""]
  
  y_string_comments.json
  ["a/*b*/c/*d//e"]
  ["a/*b*/c/*d//e"]
  
  y_string_double_escape_a.json
  ["\\a"]
  ["\\a"]
  
  y_string_double_escape_n.json
  ["\\n"]
  ["\\n"]
  
  y_string_escaped_control_character.json
  ["\u0012"]
  ["\u0012"]
  
  y_string_escaped_noncharacter.json
  ["\uFFFF"]
  ["\xef\xbf\xbf"] (esc)
  
  y_string_in_array.json
  ["asd"]
  ["asd"]
  
  y_string_in_array_with_leading_space.json
  [ "asd"]
  ["asd"]
  
  y_string_last_surrogates_1_and_2.json
  ["\uDBFF\uDFFF"]
  ["\xf4\x8f\xbf\xbf"] (esc)
  
  y_string_nbsp_uescaped.json
  ["new\u00A0line"]
  ["new\xc2\xa0line"] (esc)
  
  y_string_nonCharacterInUTF-8_U+10FFFF.json
  ["\xf4\x8f\xbf\xbf"] (esc)
  ["\xf4\x8f\xbf\xbf"] (esc)
  
  y_string_nonCharacterInUTF-8_U+FFFF.json
  ["\xef\xbf\xbf"] (esc)
  ["\xef\xbf\xbf"] (esc)
  
  y_string_null_escape.json
  ["\u0000"]
  ["\u0000"]
  
  y_string_one-byte-utf-8.json
  ["\u002c"]
  [","]
  
  y_string_pi.json
  ["\xcf\x80"] (esc)
  ["\xcf\x80"] (esc)
  
  y_string_reservedCharacterInUTF-8_U+1BFFF.json
  ["\xf0\x9b\xbf\xbf"] (esc)
  ["\xf0\x9b\xbf\xbf"] (esc)
  
  y_string_simple_ascii.json
  ["asd "]
  ["asd "]
  
  y_string_space.json
  " "
  " "
  
  y_string_surrogates_U+1D11E_MUSICAL_SYMBOL_G_CLEF.json
  ["\uD834\uDd1e"]
  ["\xf0\x9d\x84\x9e"] (esc)
  
  y_string_three-byte-utf-8.json
  ["\u0821"]
  ["\xe0\xa0\xa1"] (esc)
  
  y_string_two-byte-utf-8.json
  ["\u0123"]
  ["\xc4\xa3"] (esc)
  
  y_string_u+2028_line_sep.json
  ["\xe2\x80\xa8"] (esc)
  ["\xe2\x80\xa8"] (esc)
  
  y_string_u+2029_par_sep.json
  ["\xe2\x80\xa9"] (esc)
  ["\xe2\x80\xa9"] (esc)
  
  y_string_uEscape.json
  ["\u0061\u30af\u30EA\u30b9"]
  ["a\xe3\x82\xaf\xe3\x83\xaa\xe3\x82\xb9"] (esc)
  
  y_string_uescaped_newline.json
  ["new\u000Aline"]
  ["new\nline"]
  
  y_string_unescaped_char_delete.json
  ["\x7f"] (esc)
  ["\x7f"] (esc)
  
  y_string_unicode.json
  ["\uA66D"]
  ["\xea\x99\xad"] (esc)
  
  y_string_unicodeEscapedBackslash.json
  ["\u005C"]
  ["\\"]
  
  y_string_unicode_2.json
  ["\xe2\x8d\x82\xe3\x88\xb4\xe2\x8d\x82"] (esc)
  ["\xe2\x8d\x82\xe3\x88\xb4\xe2\x8d\x82"] (esc)
  
  y_string_unicode_U+10FFFE_nonchar.json
  ["\uDBFF\uDFFE"]
  ["\xf4\x8f\xbf\xbe"] (esc)
  
  y_string_unicode_U+1FFFE_nonchar.json
  ["\uD83F\uDFFE"]
  ["\xf0\x9f\xbf\xbe"] (esc)
  
  y_string_unicode_U+200B_ZERO_WIDTH_SPACE.json
  ["\u200B"]
  ["\xe2\x80\x8b"] (esc)
  
  y_string_unicode_U+2064_invisible_plus.json
  ["\u2064"]
  ["\xe2\x81\xa4"] (esc)
  
  y_string_unicode_U+FDD0_nonchar.json
  ["\uFDD0"]
  ["\xef\xb7\x90"] (esc)
  
  y_string_unicode_U+FFFE_nonchar.json
  ["\uFFFE"]
  ["\xef\xbf\xbe"] (esc)
  
  y_string_unicode_escaped_double_quote.json
  ["\u0022"]
  ["\""]
  
  y_string_utf8.json
  ["\xe2\x82\xac\xf0\x9d\x84\x9e"] (esc)
  ["\xe2\x82\xac\xf0\x9d\x84\x9e"] (esc)
  
  y_string_with_del_character.json
  ["a\x7fa"] (esc)
  ["a\x7fa"] (esc)
  
  y_structure_lonely_false.json
  false
  false
  
  y_structure_lonely_int.json
  42
  42
  
  y_structure_lonely_negative_real.json
  -0.1
  -0.1
  
  y_structure_lonely_null.json
  null
  null
  
  y_structure_lonely_string.json
  "asd"
  "asd"
  
  y_structure_lonely_true.json
  true
  true
  
  y_structure_string_empty.json
  ""
  ""
  
  y_structure_trailing_newline.json
  ["a"]
  
  ["a"]
  
  y_structure_true_in_array.json
  [true]
  [true]
  
  y_structure_whitespace_array.json
   [] 
  []
  
