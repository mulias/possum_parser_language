  $ for f in $TESTDIR/n_*.json; do echo "$(basename $f)"; cat $f; echo ""; possum -p 'input(json)' $f 2>err; grep -a '^\[' err; echo ""; done
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
  
