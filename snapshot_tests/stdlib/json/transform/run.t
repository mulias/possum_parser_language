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
  
