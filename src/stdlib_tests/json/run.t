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
  
  $ for f in $TESTDIR/n_*.json; do echo "$(basename $f)"; cat $f; echo ""; possum -p 'input(json)' $f; echo ""; done
  n_array_1_true_without_comma.json
  [1 true]
  [ParserFailure]
  
  n_array_a_invalid_utf8.json
  [a\xe5] (esc)
  [ParserFailure]
  
  n_array_colon_instead_of_comma.json
  ["": 1]
  [ParserFailure]
  
  n_array_comma_after_close.json
  [""],
  [ParserFailure]
  
  n_array_comma_and_number.json
  [,1]
  [ParserFailure]
  
  n_array_double_comma.json
  [1,,2]
  [ParserFailure]
  
  n_array_double_extra_comma.json
  ["x",,]
  [ParserFailure]
  
  n_array_extra_close.json
  ["x"]]
  [ParserFailure]
  
  n_array_extra_comma.json
  ["",]
  [ParserFailure]
  
  n_array_incomplete.json
  ["x"
  [ParserFailure]
  
  n_array_incomplete_invalid_value.json
  [x
  [ParserFailure]
  
  n_array_inner_array_no_comma.json
  [3[4]]
  [ParserFailure]
  
  n_array_invalid_utf8.json
  [\xff] (esc)
  [ParserFailure]
  
  n_array_items_separated_by_semicolon.json
  [1:2]
  [ParserFailure]
  
  n_array_just_comma.json
  [,]
  [ParserFailure]
  
  n_array_just_minus.json
  [-]
  [ParserFailure]
  
  n_array_missing_value.json
  [   , ""]
  [ParserFailure]
  
  n_array_newlines_unclosed.json
  ["a",
  4
  ,1,
  [ParserFailure]
  
  n_array_number_and_comma.json
  [1,]
  [ParserFailure]
  
  n_array_number_and_several_commas.json
  [1,,]
  [ParserFailure]
  
  n_array_spaces_vertical_tab_formfeed.json
  ["\x0ba"\\f] (esc)
  [ParserFailure]
  
  n_array_star_inside.json
  [*]
  [ParserFailure]
  
  n_array_unclosed.json
  [""
  [ParserFailure]
  
  n_array_unclosed_trailing_comma.json
  [1,
  [ParserFailure]
  
  n_array_unclosed_with_new_lines.json
  [1,
  1
  ,1
  [ParserFailure]
  
  n_array_unclosed_with_object_inside.json
  [{}
  [ParserFailure]
  
  n_incomplete_false.json
  [fals]
  [ParserFailure]
  
  n_incomplete_null.json
  [nul]
  [ParserFailure]
  
  n_incomplete_true.json
  [tru]
  [ParserFailure]
  
  n_multidigit_number_then_00.json
  123\x00 (esc)
  [ParserFailure]
  
  n_number_++.json
  [++1234]
  [ParserFailure]
  
  n_number_+1.json
  [+1]
  [ParserFailure]
  
  n_number_+Inf.json
  [+Inf]
  [ParserFailure]
  
  n_number_-01.json
  [-01]
  [ParserFailure]
  
  n_number_-1.0..json
  [-1.0.]
  [ParserFailure]
  
  n_number_-2..json
  [-2.]
  [ParserFailure]
  
  n_number_-NaN.json
  [-NaN]
  [ParserFailure]
  
  n_number_.-1.json
  [.-1]
  [ParserFailure]
  
  n_number_.2e-3.json
  [.2e-3]
  [ParserFailure]
  
  n_number_0.1.2.json
  [0.1.2]
  [ParserFailure]
  
  n_number_0.3e+.json
  [0.3e+]
  [ParserFailure]
  
  n_number_0.3e.json
  [0.3e]
  [ParserFailure]
  
  n_number_0.e1.json
  [0.e1]
  [ParserFailure]
  
  n_number_0_capital_E+.json
  [0E+]
  [ParserFailure]
  
  n_number_0_capital_E.json
  [0E]
  [ParserFailure]
  
  n_number_0e+.json
  [0e+]
  [ParserFailure]
  
  n_number_0e.json
  [0e]
  [ParserFailure]
  
  n_number_1.0e+.json
  [1.0e+]
  [ParserFailure]
  
  n_number_1.0e-.json
  [1.0e-]
  [ParserFailure]
  
  n_number_1.0e.json
  [1.0e]
  [ParserFailure]
  
  n_number_1_000.json
  [1 000.0]
  [ParserFailure]
  
  n_number_1eE2.json
  [1eE2]
  [ParserFailure]
  
  n_number_2.e+3.json
  [2.e+3]
  [ParserFailure]
  
  n_number_2.e-3.json
  [2.e-3]
  [ParserFailure]
  
  n_number_2.e3.json
  [2.e3]
  [ParserFailure]
  
  n_number_9.e+.json
  [9.e+]
  [ParserFailure]
  
  n_number_Inf.json
  [Inf]
  [ParserFailure]
  
  n_number_NaN.json
  [NaN]
  [ParserFailure]
  
  n_number_U+FF11_fullwidth_digit_one.json
  [\xef\xbc\x91] (esc)
  [ParserFailure]
  
  n_number_expression.json
  [1+2]
  [ParserFailure]
  
  n_number_hex_1_digit.json
  [0x1]
  [ParserFailure]
  
  n_number_hex_2_digits.json
  [0x42]
  [ParserFailure]
  
  n_number_infinity.json
  [Infinity]
  [ParserFailure]
  
  n_number_invalid+-.json
  [0e+-1]
  [ParserFailure]
  
  n_number_invalid-negative-real.json
  [-123.123foo]
  [ParserFailure]
  
  n_number_invalid-utf-8-in-bigger-int.json
  [123\xe5] (esc)
  [ParserFailure]
  
  n_number_invalid-utf-8-in-exponent.json
  [1e1\xe5] (esc)
  [ParserFailure]
  
  n_number_minus_infinity.json
  [-Infinity]
  [ParserFailure]
  
  n_number_minus_sign_with_trailing_garbage.json
  [-foo]
  [ParserFailure]
  
  n_number_minus_space_1.json
  [- 1]
  [ParserFailure]
  
  n_number_neg_int_starting_with_zero.json
  [-012]
  [ParserFailure]
  
  n_number_neg_real_without_int_part.json
  [-.123]
  [ParserFailure]
  
  n_number_neg_with_garbage_at_end.json
  [-1x]
  [ParserFailure]
  
  n_number_real_garbage_after_e.json
  [1ea]
  [ParserFailure]
  
  n_number_real_with_invalid_utf8_after_e.json
  [1e\xe5] (esc)
  [ParserFailure]
  
  n_number_real_without_fractional_part.json
  [1.]
  [ParserFailure]
  
  n_number_starting_with_dot.json
  [.123]
  [ParserFailure]
  
  n_number_with_alpha.json
  [1.2a-3]
  [ParserFailure]
  
  n_number_with_alpha_char.json
  [1.8011670033376514H-308]
  [ParserFailure]
  
  n_number_with_leading_zero.json
  [012]
  [ParserFailure]
  
  n_object_bad_value.json
  ["x", truth]
  [ParserFailure]
  
  n_object_bracket_key.json
  {[: "x"}
  
  [ParserFailure]
  
  n_object_comma_instead_of_colon.json
  {"x", null}
  [ParserFailure]
  
  n_object_double_colon.json
  {"x"::"b"}
  [ParserFailure]
  
  n_object_emoji.json
  {\xf0\x9f\x87\xa8\xf0\x9f\x87\xad} (esc)
  [ParserFailure]
  
  n_object_garbage_at_end.json
  {"a":"a" 123}
  [ParserFailure]
  
  n_object_key_with_single_quotes.json
  {key: 'value'}
  [ParserFailure]
  
  n_object_lone_continuation_byte_in_key_and_trailing_comma.json
  {"\xb9":"0",} (esc)
  [ParserFailure]
  
  n_object_missing_colon.json
  {"a" b}
  [ParserFailure]
  
  n_object_missing_key.json
  {:"b"}
  [ParserFailure]
  
  n_object_missing_semicolon.json
  {"a" "b"}
  [ParserFailure]
  
  n_object_missing_value.json
  {"a":
  [ParserFailure]
  
  n_object_no-colon.json
  {"a"
  [ParserFailure]
  
  n_object_non_string_key.json
  {1:1}
  [ParserFailure]
  
  n_object_non_string_key_but_huge_number_instead.json
  {9999E9999:1}
  [ParserFailure]
  
  n_object_repeated_null_null.json
  {null:null,null:null}
  [ParserFailure]
  
  n_object_several_trailing_commas.json
  {"id":0,,,,,}
  [ParserFailure]
  
  n_object_single_quote.json
  {'a':0}
  [ParserFailure]
  
  n_object_trailing_comma.json
  {"id":0,}
  [ParserFailure]
  
  n_object_trailing_comment.json
  {"a":"b"}/**/
  [ParserFailure]
  
  n_object_trailing_comment_open.json
  {"a":"b"}/**//
  [ParserFailure]
  
  n_object_trailing_comment_slash_open.json
  {"a":"b"}//
  [ParserFailure]
  
  n_object_trailing_comment_slash_open_incomplete.json
  {"a":"b"}/
  [ParserFailure]
  
  n_object_two_commas_in_a_row.json
  {"a":"b",,"c":"d"}
  [ParserFailure]
  
  n_object_unquoted_key.json
  {a: "b"}
  [ParserFailure]
  
  n_object_unterminated-value.json
  {"a":"a
  [ParserFailure]
  
  n_object_with_single_string.json
  { "foo" : "bar", "a" }
  [ParserFailure]
  
  n_object_with_trailing_garbage.json
  {"a":"b"}#
  [ParserFailure]
  
  n_single_space.json
   
  [ParserFailure]
  
  n_string_1_surrogate_then_escape.json
  ["\uD800\"]
  [ParserFailure]
  
  n_string_1_surrogate_then_escape_u.json
  ["\uD800\u"]
  [ParserFailure]
  
  n_string_1_surrogate_then_escape_u1.json
  ["\uD800\u1"]
  [ParserFailure]
  
  n_string_1_surrogate_then_escape_u1x.json
  ["\uD800\u1x"]
  [ParserFailure]
  
  n_string_accentuated_char_no_quotes.json
  [\xc3\xa9] (esc)
  [ParserFailure]
  
  n_string_backslash_00.json
  ["\\\x00"] (esc)
  [ParserFailure]
  
  n_string_escape_x.json
  ["\x00"]
  [ParserFailure]
  
  n_string_escaped_backslash_bad.json
  ["\\\"]
  [ParserFailure]
  
  n_string_escaped_ctrl_char_tab.json
  ["\\\t"] (esc)
  [ParserFailure]
  
  n_string_escaped_emoji.json
  ["\\\xf0\x9f\x8c\x80"] (esc)
  [ParserFailure]
  
  n_string_incomplete_escape.json
  ["\"]
  [ParserFailure]
  
  n_string_incomplete_escaped_character.json
  ["\u00A"]
  [ParserFailure]
  
  n_string_incomplete_surrogate.json
  ["\uD834\uDd"]
  [ParserFailure]
  
  n_string_incomplete_surrogate_escape_invalid.json
  ["\uD800\uD800\x"]
  [ParserFailure]
  
  n_string_invalid-utf-8-in-escape.json
  ["\\u\xe5"] (esc)
  [ParserFailure]
  
  n_string_invalid_backslash_esc.json
  ["\a"]
  [ParserFailure]
  
  n_string_invalid_unicode_escape.json
  ["\uqqqq"]
  [ParserFailure]
  
  n_string_invalid_utf8_after_escape.json
  ["\\\xe5"] (esc)
  [ParserFailure]
  
  n_string_leading_uescaped_thinspace.json
  [\u0020"asd"]
  [ParserFailure]
  
  n_string_no_quotes_with_bad_escape.json
  [\n]
  [ParserFailure]
  
  n_string_single_doublequote.json
  "
  [ParserFailure]
  
  n_string_single_quote.json
  ['single quote']
  [ParserFailure]
  
  n_string_single_string_no_double_quotes.json
  abc
  [ParserFailure]
  
  n_string_start_escape_unclosed.json
  ["\
  [ParserFailure]
  
  n_string_unescaped_ctrl_char.json
  ["a\x00a"] (esc)
  [ParserFailure]
  
  n_string_unescaped_newline.json
  ["new
  line"]
  [ParserFailure]
  
  n_string_unescaped_tab.json
  ["\t"] (esc)
  [ParserFailure]
  
  n_string_unicode_CapitalU.json
  "\UA66D"
  [ParserFailure]
  
  n_string_with_trailing_garbage.json
  ""x
  [ParserFailure]
  
  n_structure_U+2060_word_joined.json
  [\xe2\x81\xa0] (esc)
  [ParserFailure]
  
  n_structure_UTF8_BOM_no_data.json
  \xef\xbb\xbf (esc)
  [ParserFailure]
  
  n_structure_angle_bracket_..json
  <.>
  [ParserFailure]
  
  n_structure_angle_bracket_null.json
  [<null>]
  [ParserFailure]
  
  n_structure_array_trailing_garbage.json
  [1]x
  [ParserFailure]
  
  n_structure_array_with_extra_array_close.json
  [1]]
  [ParserFailure]
  
  n_structure_array_with_unclosed_string.json
  ["asd]
  [ParserFailure]
  
  n_structure_ascii-unicode-identifier.json
  a\xc3\xa5 (esc)
  [ParserFailure]
  
  n_structure_capitalized_True.json
  [True]
  [ParserFailure]
  
  n_structure_close_unopened_array.json
  1]
  [ParserFailure]
  
  n_structure_comma_instead_of_closing_brace.json
  {"x": true,
  [ParserFailure]
  
  n_structure_double_array.json
  [][]
  [ParserFailure]
  
  n_structure_end_array.json
  ]
  [ParserFailure]
  
  n_structure_lone-invalid-utf-8.json
  \xe5 (esc)
  [ParserFailure]
  
  n_structure_lone-open-bracket.json
  [
  [ParserFailure]
  
  n_structure_no_data.json
  
  [ParserFailure]
  
  n_structure_null-byte-outside-string.json
  [\x00] (esc)
  [ParserFailure]
  
  n_structure_number_with_trailing_garbage.json
  2@
  [ParserFailure]
  
  n_structure_object_followed_by_closing_object.json
  {}}
  [ParserFailure]
  
  n_structure_object_unclosed_no_value.json
  {"":
  [ParserFailure]
  
  n_structure_object_with_comment.json
  {"a":/*comment*/"b"}
  [ParserFailure]
  
  n_structure_object_with_trailing_garbage.json
  {"a": true} "x"
  [ParserFailure]
  
  n_structure_open_array_apostrophe.json
  ['
  [ParserFailure]
  
  n_structure_open_array_comma.json
  [,
  [ParserFailure]
  
  n_structure_open_array_open_object.json
  [{
  [ParserFailure]
  
  n_structure_open_array_open_string.json
  ["a
  [ParserFailure]
  
  n_structure_open_array_string.json
  ["a"
  [ParserFailure]
  
  n_structure_open_object.json
  {
  [ParserFailure]
  
  n_structure_open_object_close_array.json
  {]
  [ParserFailure]
  
  n_structure_open_object_comma.json
  {,
  [ParserFailure]
  
  n_structure_open_object_open_array.json
  {[
  [ParserFailure]
  
  n_structure_open_object_open_string.json
  {"a
  [ParserFailure]
  
  n_structure_open_object_string_with_apostrophes.json
  {'a'
  [ParserFailure]
  
  n_structure_open_open.json
  ["\{["\{["\{["\{
  [ParserFailure]
  
  n_structure_single_eacute.json
  \xe9 (esc)
  [ParserFailure]
  
  n_structure_single_star.json
  *
  [ParserFailure]
  
  n_structure_trailing_#.json
  {"a":"b"}#{}
  [ParserFailure]
  
  n_structure_uescaped_LF_before_string.json
  [\u000A""]
  [ParserFailure]
  
  n_structure_unclosed_array.json
  [1
  [ParserFailure]
  
  n_structure_unclosed_array_partial_null.json
  [ false, nul
  [ParserFailure]
  
  n_structure_unclosed_array_unfinished_false.json
  [ true, fals
  [ParserFailure]
  
  n_structure_unclosed_array_unfinished_true.json
  [ false, tru
  [ParserFailure]
  
  n_structure_unclosed_object.json
  {"asd":"asd"
  [ParserFailure]
  
  n_structure_unicode-identifier.json
  \xc3\xa5 (esc)
  [ParserFailure]
  
  n_structure_whitespace_U+2060_word_joiner.json
  [\xe2\x81\xa0] (esc)
  [ParserFailure]
  
  n_structure_whitespace_formfeed.json
  [\x0c] (esc)
  [ParserFailure]
  
  $ for f in $TESTDIR/i_*.json; do echo "$(basename $f)"; cat $f; echo ""; possum -p 'input(json)' $f; echo ""; done
  i_number_double_huge_neg_exp.json
  [123.456e-789]
  [123.456e-789]
  
  i_number_huge_exp.json
  [0.4e00669999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999969999999006]
  [0.4e00669999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999969999999006]
  
  i_number_neg_int_huge_exp.json
  [-1e+9999]
  [-1e+9999]
  
  i_number_pos_double_huge_exp.json
  [1.5e+9999]
  [1.5e+9999]
  
  i_number_real_neg_overflow.json
  [-123123e100000]
  [-123123e100000]
  
  i_number_real_pos_overflow.json
  [123123e100000]
  [123123e100000]
  
  i_number_real_underflow.json
  [123e-10000000]
  [123e-10000000]
  
  i_number_too_big_neg_int.json
  [-123123123123123123123123123123]
  [-123123123123123123123123123123]
  
  i_number_too_big_pos_int.json
  [100000000000000000000]
  [100000000000000000000]
  
  i_number_very_big_negative_int.json
  [-237462374673276894279832749832423479823246327846]
  [-237462374673276894279832749832423479823246327846]
  
  i_object_key_lone_2nd_surrogate.json
  {"\uDFAA":0}
  {"\xef\xbf\xbd": 0} (esc)
  
  i_string_1st_surrogate_but_2nd_missing.json
  ["\uDADA"]
  ["\xef\xbf\xbd"] (esc)
  
  i_string_1st_valid_surrogate_2nd_invalid.json
  ["\uD888\u1234"]
  ["\xef\xbf\xbd\xe1\x88\xb4"] (esc)
  
  i_string_UTF-16LE_with_BOM.json
  \xff\xfe[\x00"\x00\xe9\x00"\x00]\x00 (esc)
  [ParserFailure]
  
  i_string_UTF-8_invalid_sequence.json
  ["\xe6\x97\xa5\xd1\x88\xfa"] (esc)
  ["\xe6\x97\xa5\xd1\x88\xfa"] (esc)
  
  i_string_UTF8_surrogate_U+D800.json
  ["\xed\xa0\x80"] (esc)
  ["\xed\xa0\x80"] (esc)
  
  i_string_incomplete_surrogate_and_escape_valid.json
  ["\uD800\n"]
  ["\xef\xbf\xbd\\n"] (esc)
  
  i_string_incomplete_surrogate_pair.json
  ["\uDd1ea"]
  ["\xef\xbf\xbda"] (esc)
  
  i_string_incomplete_surrogates_escape_valid.json
  ["\uD800\uD800\n"]
  ["\xef\xbf\xbd\xef\xbf\xbd\\n"] (esc)
  
  i_string_invalid_lonely_surrogate.json
  ["\ud800"]
  ["\xef\xbf\xbd"] (esc)
  
  i_string_invalid_surrogate.json
  ["\ud800abc"]
  ["\xef\xbf\xbdabc"] (esc)
  
  i_string_invalid_utf-8.json
  ["\xff"] (esc)
  ["\xff"] (esc)
  
  i_string_inverted_surrogates_U+1D11E.json
  ["\uDd1e\uD834"]
  ["\xef\xbf\xbd\xef\xbf\xbd"] (esc)
  
  i_string_iso_latin_1.json
  ["\xe9"] (esc)
  [ParserFailure]
  
  i_string_lone_second_surrogate.json
  ["\uDFAA"]
  ["\xef\xbf\xbd"] (esc)
  
  i_string_lone_utf8_continuation_byte.json
  ["\x81"] (esc)
  ["\x81"] (esc)
  
  i_string_not_in_unicode_range.json
  ["\xf4\xbf\xbf\xbf"] (esc)
  ["\xf4\xbf\xbf\xbf"] (esc)
  
  i_string_overlong_sequence_2_bytes.json
  ["\xc0\xaf"] (esc)
  ["\xc0\xaf"] (esc)
  
  i_string_overlong_sequence_6_bytes.json
  ["\xfc\x83\xbf\xbf\xbf\xbf"] (esc)
  ["\xfc\x83\xbf\xbf\xbf\xbf"] (esc)
  
  i_string_overlong_sequence_6_bytes_null.json
  ["\xfc\x80\x80\x80\x80\x80"] (esc)
  ["\xfc\x80\x80\x80\x80\x80"] (esc)
  
  i_string_truncated-utf-8.json
  ["\xe0\xff"] (esc)
  [ParserFailure]
  
  i_string_utf16BE_no_BOM.json
  \x00[\x00"\x00\xe9\x00"\x00] (esc)
  [ParserFailure]
  
  i_string_utf16LE_no_BOM.json
  [\x00"\x00\xe9\x00"\x00]\x00 (esc)
  [ParserFailure]
  
  i_structure_UTF-8_BOM_empty_object.json
  \xef\xbb\xbf{} (esc)
  [ParserFailure]
  

  $ for f in $TESTDIR/t_*.json; do echo "$(basename $f)"; cat $f; echo ""; possum -p 'input(json)' $f; echo ""; done
  t_number_-9223372036854775808.json
  [-9223372036854775808]
  
  [-9223372036854775808]
  
  t_number_-9223372036854775809.json
  [-9223372036854775809]
  
  [-9223372036854775809]
  
  t_number_1.0.json
  [1.0]
  
  [1.0]
  
  t_number_1.000000000000000005.json
  [1.000000000000000005]
  
  [1.000000000000000005]
  
  t_number_1000000000000000.json
  [1000000000000000]
  
  [1000000000000000]
  
  t_number_10000000000000000999.json
  [10000000000000000999]
  
  [10000000000000000999]
  
  t_number_1e-999.json
  [1E-999]
  
  [1E-999]
  
  t_number_1e6.json
  [1E6]
  
  [1E6]
  
  t_number_9223372036854775807.json
  [9223372036854775807]
  
  [9223372036854775807]
  
  t_number_9223372036854775808.json
  [9223372036854775808]
  
  [9223372036854775808]
  
  t_object_key_nfc_nfd.json
  {"\xc3\xa9":"NFC","e\xcc\x81":"NFD"} (esc)
  {"\xc3\xa9": "NFC", "e\xcc\x81": "NFD"} (esc)
  
  t_object_key_nfd_nfc.json
  {"e\xcc\x81":"NFD","\xc3\xa9":"NFC"} (esc)
  {"e\xcc\x81": "NFD", "\xc3\xa9": "NFC"} (esc)
  
  t_object_same_key_different_values.json
  {"a":1,"a":2}
  {"a": 2}
  
  t_object_same_key_same_value.json
  {"a":1,"a":1}
  {"a": 1}
  
  t_object_same_key_unclear_values.json
  {"a":0, "a":-0}
  
  {"a": -0}
  
  t_string_1_escaped_invalid_codepoint.json
  ["\uD800"]
  ["\xef\xbf\xbd"] (esc)
  
  t_string_1_invalid_codepoint.json
  ["\xed\xa0\x80"] (esc)
  ["\xed\xa0\x80"] (esc)
  
  t_string_2_escaped_invalid_codepoints.json
  ["\uD800\uD800"]
  ["\xef\xbf\xbd\xef\xbf\xbd"] (esc)
  
  t_string_2_invalid_codepoints.json
  ["\xed\xa0\x80\xed\xa0\x80"] (esc)
  ["\xed\xa0\x80\xed\xa0\x80"] (esc)
  
  t_string_3_escaped_invalid_codepoints.json
  ["\uD800\uD800\uD800"]
  ["\xef\xbf\xbd\xef\xbf\xbd\xef\xbf\xbd"] (esc)
  
  t_string_3_invalid_codepoints.json
  ["\xed\xa0\x80\xed\xa0\x80\xed\xa0\x80"] (esc)
  ["\xed\xa0\x80\xed\xa0\x80\xed\xa0\x80"] (esc)
  
  t_string_with_escaped_NULL.json
  ["A\u0000B"]
  ["A\u0000B"]
  
