  $ for f in $TESTDIR/i_*.json; do echo "$(basename $f)"; cat $f; echo ""; possum -p 'input(json)' $f 2>err; grep -a '^\[' err; echo ""; done
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
  
