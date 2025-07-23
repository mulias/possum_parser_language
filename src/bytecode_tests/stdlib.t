  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i ''
  
  ==================char==================
  0000    | ParseCharacter
  0001    | End
  ========================================
  
  =================ascii==================
  0000    | ParseRange 0 1: "\x00" "\x7f" (esc)
  0003    | End
  ========================================
  
  =================alpha==================
  0000    | SetInputMark
  0001    | ParseRange 0 1: "a" "z"
  0004    | Or 4 -> 10
  0007    | ParseRange 2 3: "A" "Z"
  0010    | End
  ========================================
  
  =================alphas=================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: alpha
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================lower==================
  0000    | ParseRange 0 1: "a" "z"
  0003    | End
  ========================================
  
  =================lowers=================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: lower
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================upper==================
  0000    | ParseRange 0 1: "A" "Z"
  0003    | End
  ========================================
  
  =================uppers=================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: upper
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================numeral=================
  0000    | ParseRange 0 1: "0" "9"
  0003    | End
  ========================================
  
  ================numerals================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =============binary_numeral=============
  0000    | SetInputMark
  0001    | GetConstant 0: "0"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "1"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =============octal_numeral==============
  0000    | ParseRange 0 1: "0" "7"
  0003    | End
  ========================================
  
  ==============hex_numeral===============
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: numeral
  0004    | CallFunction 0
  0006    | Or 6 -> 12
  0009    | ParseRange 1 2: "a" "f"
  0012    | Or 12 -> 18
  0015    | ParseRange 3 4: "A" "F"
  0018    | End
  ========================================
  
  =================alnum==================
  0000    | SetInputMark
  0001    | GetConstant 0: alpha
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: numeral
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================alnums=================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: alnum
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn833=================
  0000    | GetConstant 0: unless
  0002    | GetConstant 1: char
  0004    | GetConstant 2: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn833
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn834=================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: alnum
  0004    | CallFunction 0
  0006    | Or 6 -> 13
  0009    | GetConstant 1: "_"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: "-"
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  ==================word==================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn834
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn835=================
  0000    | SetInputMark
  0001    | GetConstant 0: newline
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: end_of_input
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==================line==================
  0000    | GetConstant 0: chars_until
  0002    | GetConstant 1: @fn835
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================space==================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | SetInputMark
  0006    | GetConstant 0: " "
  0008    | CallFunction 0
  0010    | Or 10 -> 17
  0013    | GetConstant 1: "\t" (esc)
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | GetConstant 2: "\xc2\xa0" (esc)
  0022    | CallFunction 0
  0024    | Or 24 -> 30
  0027    | ParseRange 3 4: "\xe2\x80\x80" "\xe2\x80\x8a" (esc)
  0030    | Or 30 -> 37
  0033    | GetConstant 5: "\xe2\x80\xaf" (esc)
  0035    | CallFunction 0
  0037    | Or 37 -> 44
  0040    | GetConstant 6: "\xe2\x81\x9f" (esc)
  0042    | CallFunction 0
  0044    | Or 44 -> 51
  0047    | GetConstant 7: "\xe3\x80\x80" (esc)
  0049    | CallFunction 0
  0051    | End
  ========================================
  
  =================spaces=================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================newline=================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | GetConstant 0: "\r (esc)
  "
  0006    | CallFunction 0
  0008    | Or 8 -> 14
  0011    | ParseRange 1 2: "
  " "\r (no-eol) (esc)
  "
  0014    | Or 14 -> 21
  0017    | GetConstant 3: "\xc2\x85" (esc)
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 4: "\xe2\x80\xa8" (esc)
  0026    | CallFunction 0
  0028    | Or 28 -> 35
  0031    | GetConstant 5: "\xe2\x80\xa9" (esc)
  0033    | CallFunction 0
  0035    | End
  ========================================
  
  ================newlines================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn836=================
  0000    | SetInputMark
  0001    | GetConstant 0: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: newline
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ===============whitespace===============
  0000    | GetConstant 0: many
  0002    | GetConstant 1: @fn836
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============chars_until===============
  0000    | GetConstant 0: many_until
  0002    | GetConstant 1: char
  0004    | GetBoundLocal 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================digit==================
  0000    | ParseRange 0 1: 0 9
  0003    | End
  ========================================
  
  =================@fn837=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _number_integer_part
  0011    | CallFunction 0
  0013    | Merge
  0014    | End
  ========================================
  
  ================integer=================
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn837
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========non_negative_integer==========
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn838=================
  0000    | GetConstant 0: "-"
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _number_integer_part
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  ============negative_integer============
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn838
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn839=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _number_integer_part
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 22
  0017    | GetConstant 3: _number_fraction_part
  0019    | CallFunction 0
  0021    | Merge
  0022    | End
  ========================================
  
  =================float==================
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn839
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn840=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _number_integer_part
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 22
  0017    | GetConstant 3: _number_exponent_part
  0019    | CallFunction 0
  0021    | Merge
  0022    | End
  ========================================
  
  ===========scientific_integer===========
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn840
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn841=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _number_integer_part
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 22
  0017    | GetConstant 3: _number_fraction_part
  0019    | CallFunction 0
  0021    | Merge
  0022    | JumpIfFailure 22 -> 30
  0025    | GetConstant 4: _number_exponent_part
  0027    | CallFunction 0
  0029    | Merge
  0030    | End
  ========================================
  
  ============scientific_float============
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn841
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn842=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _number_integer_part
  0011    | CallFunction 0
  0013    | Merge
  0014    | JumpIfFailure 14 -> 24
  0017    | GetConstant 3: maybe
  0019    | GetConstant 4: _number_fraction_part
  0021    | CallFunction 1
  0023    | Merge
  0024    | JumpIfFailure 24 -> 34
  0027    | GetConstant 5: maybe
  0029    | GetConstant 6: _number_exponent_part
  0031    | CallFunction 1
  0033    | Merge
  0034    | End
  ========================================
  
  =================number=================
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn842
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn843=================
  0000    | GetConstant 0: _number_integer_part
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 14
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: _number_fraction_part
  0011    | CallFunction 1
  0013    | Merge
  0014    | JumpIfFailure 14 -> 24
  0017    | GetConstant 3: maybe
  0019    | GetConstant 4: _number_exponent_part
  0021    | CallFunction 1
  0023    | Merge
  0024    | End
  ========================================
  
  ==========non_negative_number===========
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn843
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn844=================
  0000    | GetConstant 0: "-"
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _number_integer_part
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 2: maybe
  0017    | GetConstant 3: _number_fraction_part
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 32
  0025    | GetConstant 4: maybe
  0027    | GetConstant 5: _number_exponent_part
  0029    | CallFunction 1
  0031    | Merge
  0032    | End
  ========================================
  
  ============negative_number=============
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn844
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_number_integer_part==========
  0000    | SetInputMark
  0001    | ParseRange 0 1: "1" "9"
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 2: numerals
  0009    | CallFunction 0
  0011    | Merge
  0012    | Or 12 -> 19
  0015    | GetConstant 3: numeral
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  =========_number_fraction_part==========
  0000    | GetConstant 0: "."
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: numerals
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  =================@fn845=================
  0000    | SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_number_exponent_part==========
  0000    | SetInputMark
  0001    | GetConstant 0: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "E"
  0010    | CallFunction 0
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 2: maybe
  0017    | GetConstant 3: @fn845
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 30
  0025    | GetConstant 4: numerals
  0027    | CallFunction 0
  0029    | Merge
  0030    | End
  ========================================
  
  ==============binary_digit==============
  0000    | ParseRange 0 1: 0 1
  0003    | End
  ========================================
  
  ==============octal_digit===============
  0000    | ParseRange 0 1: 0 7
  0003    | End
  ========================================
  
  ===============hex_digit================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | SetInputMark
  0006    | GetConstant 0: digit
  0008    | CallFunction 0
  0010    | Or 10 -> 30
  0013    | SetInputMark
  0014    | GetConstant 1: "a"
  0016    | CallFunction 0
  0018    | Or 18 -> 25
  0021    | GetConstant 2: "A"
  0023    | CallFunction 0
  0025    | TakeRight 25 -> 30
  0028    | GetConstant 3: 10
  0030    | Or 30 -> 50
  0033    | SetInputMark
  0034    | GetConstant 4: "b"
  0036    | CallFunction 0
  0038    | Or 38 -> 45
  0041    | GetConstant 5: "B"
  0043    | CallFunction 0
  0045    | TakeRight 45 -> 50
  0048    | GetConstant 6: 11
  0050    | Or 50 -> 70
  0053    | SetInputMark
  0054    | GetConstant 7: "c"
  0056    | CallFunction 0
  0058    | Or 58 -> 65
  0061    | GetConstant 8: "C"
  0063    | CallFunction 0
  0065    | TakeRight 65 -> 70
  0068    | GetConstant 9: 12
  0070    | Or 70 -> 90
  0073    | SetInputMark
  0074    | GetConstant 10: "d"
  0076    | CallFunction 0
  0078    | Or 78 -> 85
  0081    | GetConstant 11: "D"
  0083    | CallFunction 0
  0085    | TakeRight 85 -> 90
  0088    | GetConstant 12: 13
  0090    | Or 90 -> 110
  0093    | SetInputMark
  0094    | GetConstant 13: "e"
  0096    | CallFunction 0
  0098    | Or 98 -> 105
  0101    | GetConstant 14: "E"
  0103    | CallFunction 0
  0105    | TakeRight 105 -> 110
  0108    | GetConstant 15: 14
  0110    | Or 110 -> 130
  0113    | SetInputMark
  0114    | GetConstant 16: "f"
  0116    | CallFunction 0
  0118    | Or 118 -> 125
  0121    | GetConstant 17: "F"
  0123    | CallFunction 0
  0125    | TakeRight 125 -> 130
  0128    | GetConstant 18: 15
  0130    | End
  ========================================
  
  =============binary_integer=============
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: array
  0004    | GetConstant 2: binary_digit
  0006    | CallFunction 1
  0008    | GetLocal 0
  0010    | Destructure
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 3: Num.FromBinaryDigits
  0016    | GetBoundLocal 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  =============octal_integer==============
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: array
  0004    | GetConstant 2: octal_digit
  0006    | CallFunction 1
  0008    | GetLocal 0
  0010    | Destructure
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 3: Num.FromOctalDigits
  0016    | GetBoundLocal 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  ==============hex_integer===============
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: array
  0004    | GetConstant 2: hex_digit
  0006    | CallFunction 1
  0008    | GetLocal 0
  0010    | Destructure
  0011    | TakeRight 11 -> 20
  0014    | GetConstant 3: Num.FromHexDigits
  0016    | GetBoundLocal 0
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  ==================true==================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | True
  0008    | End
  ========================================
  
  =================false==================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | False
  0008    | End
  ========================================
  
  ================boolean=================
  0000    | SetInputMark
  0001    | GetConstant 0: true
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 1: false
  0012    | GetBoundLocal 1
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ==================null==================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | Null
  0008    | End
  ========================================
  
  =================array==================
  0000    | GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 1
  0008    | Destructure
  0009    | TakeRight 9 -> 24
  0012    | GetConstant 1: _array
  0014    | GetBoundLocal 0
  0016    | GetConstant 2: [_]
  0018    | GetBoundLocal 1
  0020    | InsertAtIndex 0
  0022    | CallTailFunction 2
  0024    | End
  ========================================
  
  =================_array=================
  0000    | GetConstant 0: Elem
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | GetLocal 2
  0009    | Destructure
  0010    | ConditionalThen 10 -> 40
  0013    | GetConstant 1: _array
  0015    | GetBoundLocal 0
  0017    | GetConstant 2: []
  0019    | JumpIfFailure 19 -> 25
  0022    | GetBoundLocal 1
  0024    | Merge
  0025    | JumpIfFailure 25 -> 35
  0028    | GetConstant 3: [_]
  0030    | GetBoundLocal 2
  0032    | InsertAtIndex 0
  0034    | Merge
  0035    | CallTailFunction 2
  0037    | ConditionalElse 37 -> 46
  0040    | GetConstant 4: const
  0042    | GetBoundLocal 1
  0044    | CallTailFunction 1
  0046    | End
  ========================================
  
  =================@fn849=================
  0000    | GetConstant 0: sep
  0002    | GetConstant 1: elem
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ===============array_sep================
  0000    | GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 30
  0012    | GetConstant 1: _array
  0014    | GetConstant 2: @fn849
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetConstant 3: [_]
  0024    | GetBoundLocal 2
  0026    | InsertAtIndex 0
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ==============array_until===============
  0000    | GetConstant 0: First
  0002    | GetConstant 1: unless
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | GetLocal 2
  0012    | Destructure
  0013    | TakeRight 13 -> 30
  0016    | GetConstant 2: _array_until
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | GetConstant 3: [_]
  0024    | GetBoundLocal 2
  0026    | InsertAtIndex 0
  0028    | CallTailFunction 3
  0030    | End
  ========================================
  
  ==============_array_until==============
  0000    | GetConstant 0: Elem
  0002    | SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012    | GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 57
  0021    | GetBoundLocal 0
  0023    | CallFunction 0
  0025    | GetLocal 3
  0027    | Destructure
  0028    | TakeRight 28 -> 57
  0031    | GetConstant 3: _array_until
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | GetConstant 4: []
  0039    | JumpIfFailure 39 -> 45
  0042    | GetBoundLocal 2
  0044    | Merge
  0045    | JumpIfFailure 45 -> 55
  0048    | GetConstant 5: [_]
  0050    | GetBoundLocal 3
  0052    | InsertAtIndex 0
  0054    | Merge
  0055    | CallTailFunction 3
  0057    | End
  ========================================
  
  =================@fn854=================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: array
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn854
  0004    | CaptureLocal 0 0
  0007    | GetConstant 2: []
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn856=================
  0000    | GetConstant 0: elem
  0002    | GetConstant 1: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 2: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn856
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: []
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================tuple1=================
  0000    | GetConstant 0: Elem
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 1
  0008    | Destructure
  0009    | TakeRight 9 -> 18
  0012    | GetConstant 1: [_]
  0014    | GetBoundLocal 1
  0016    | InsertAtIndex 0
  0018    | End
  ========================================
  
  =================tuple2=================
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 2
  0010    | Destructure
  0011    | TakeRight 11 -> 34
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | GetLocal 3
  0020    | Destructure
  0021    | TakeRight 21 -> 34
  0024    | GetConstant 2: [_, _]
  0026    | GetBoundLocal 2
  0028    | InsertAtIndex 0
  0030    | GetBoundLocal 3
  0032    | InsertAtIndex 1
  0034    | End
  ========================================
  
  ===============tuple2_sep===============
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 3
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 41
  0021    | GetBoundLocal 2
  0023    | CallFunction 0
  0025    | GetLocal 4
  0027    | Destructure
  0028    | TakeRight 28 -> 41
  0031    | GetConstant 2: [_, _]
  0033    | GetBoundLocal 3
  0035    | InsertAtIndex 0
  0037    | GetBoundLocal 4
  0039    | InsertAtIndex 1
  0041    | End
  ========================================
  
  =================tuple3=================
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetConstant 2: E3
  0006    | GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 3
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016    | GetBoundLocal 1
  0018    | CallFunction 0
  0020    | GetLocal 4
  0022    | Destructure
  0023    | TakeRight 23 -> 50
  0026    | GetBoundLocal 2
  0028    | CallFunction 0
  0030    | GetLocal 5
  0032    | Destructure
  0033    | TakeRight 33 -> 50
  0036    | GetConstant 3: [_, _, _]
  0038    | GetBoundLocal 3
  0040    | InsertAtIndex 0
  0042    | GetBoundLocal 4
  0044    | InsertAtIndex 1
  0046    | GetBoundLocal 5
  0048    | InsertAtIndex 2
  0050    | End
  ========================================
  
  ===============tuple3_sep===============
  0000    | GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetConstant 2: E3
  0006    | GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 5
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 1
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023    | GetBoundLocal 2
  0025    | CallFunction 0
  0027    | GetLocal 6
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 3
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 64
  0040    | GetBoundLocal 4
  0042    | CallFunction 0
  0044    | GetLocal 7
  0046    | Destructure
  0047    | TakeRight 47 -> 64
  0050    | GetConstant 3: [_, _, _]
  0052    | GetBoundLocal 5
  0054    | InsertAtIndex 0
  0056    | GetBoundLocal 6
  0058    | InsertAtIndex 1
  0060    | GetBoundLocal 7
  0062    | InsertAtIndex 2
  0064    | End
  ========================================
  
  =================tuple==================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: _Assert.NonNegativeInteger
  0004    | GetBoundLocal 1
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 23
  0013    | GetConstant 2: _tuple
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetConstant 3: []
  0021    | CallTailFunction 3
  0023    | End
  ========================================
  
  =================_tuple=================
  0000    | GetConstant 0: Elem
  0002    | SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 1
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017    | GetConstant 4: const
  0019    | GetBoundLocal 2
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 66
  0026    | GetBoundLocal 0
  0028    | CallFunction 0
  0030    | GetLocal 3
  0032    | Destructure
  0033    | TakeRight 33 -> 66
  0036    | GetConstant 5: _tuple
  0038    | GetBoundLocal 0
  0040    | GetConstant 6: Num.Dec
  0042    | GetBoundLocal 1
  0044    | CallFunction 1
  0046    | GetConstant 7: []
  0048    | JumpIfFailure 48 -> 54
  0051    | GetBoundLocal 2
  0053    | Merge
  0054    | JumpIfFailure 54 -> 64
  0057    | GetConstant 8: [_]
  0059    | GetBoundLocal 3
  0061    | InsertAtIndex 0
  0063    | Merge
  0064    | CallTailFunction 3
  0066    | End
  ========================================
  
  ===============tuple_sep================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: _Assert.NonNegativeInteger
  0004    | GetBoundLocal 2
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 25
  0013    | GetConstant 2: _tuple_sep
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetBoundLocal 2
  0021    | GetConstant 3: []
  0023    | CallTailFunction 4
  0025    | End
  ========================================
  
  ===============_tuple_sep===============
  0000    | GetConstant 0: Elem
  0002    | SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 2
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017    | GetConstant 4: const
  0019    | GetBoundLocal 3
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 75
  0026    | GetBoundLocal 1
  0028    | CallFunction 0
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 0
  0035    | CallFunction 0
  0037    | GetLocal 4
  0039    | Destructure
  0040    | TakeRight 40 -> 75
  0043    | GetConstant 5: _tuple_sep
  0045    | GetBoundLocal 0
  0047    | GetBoundLocal 1
  0049    | GetConstant 6: Num.Dec
  0051    | GetBoundLocal 2
  0053    | CallFunction 1
  0055    | GetConstant 7: []
  0057    | JumpIfFailure 57 -> 63
  0060    | GetBoundLocal 3
  0062    | Merge
  0063    | JumpIfFailure 63 -> 73
  0066    | GetConstant 8: [_]
  0068    | GetBoundLocal 4
  0070    | InsertAtIndex 0
  0072    | Merge
  0073    | CallTailFunction 4
  0075    | End
  ========================================
  
  ==================rows==================
  0000    | GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 3
  0008    | Destructure
  0009    | TakeRight 9 -> 30
  0012    | GetConstant 1: _rows
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | GetConstant 2: [_]
  0022    | GetBoundLocal 3
  0024    | InsertAtIndex 0
  0026    | GetConstant 3: []
  0028    | CallTailFunction 5
  0030    | End
  ========================================
  
  =================_rows==================
  0000    | GetConstant 0: Elem
  0002    | GetConstant 1: NextRow
  0004    | SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | GetLocal 5
  0018    | Destructure
  0019    | ConditionalThen 19 -> 55
  0022    | GetConstant 2: _rows
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | GetBoundLocal 2
  0030    | GetConstant 3: []
  0032    | JumpIfFailure 32 -> 38
  0035    | GetBoundLocal 3
  0037    | Merge
  0038    | JumpIfFailure 38 -> 48
  0041    | GetConstant 4: [_]
  0043    | GetBoundLocal 5
  0045    | InsertAtIndex 0
  0047    | Merge
  0048    | GetBoundLocal 4
  0050    | CallTailFunction 5
  0052    | ConditionalElse 52 -> 132
  0055    | SetInputMark
  0056    | GetBoundLocal 2
  0058    | CallFunction 0
  0060    | TakeRight 60 -> 67
  0063    | GetBoundLocal 0
  0065    | CallFunction 0
  0067    | GetLocal 6
  0069    | Destructure
  0070    | ConditionalThen 70 -> 110
  0073    | GetConstant 5: _rows
  0075    | GetBoundLocal 0
  0077    | GetBoundLocal 1
  0079    | GetBoundLocal 2
  0081    | GetConstant 6: [_]
  0083    | GetBoundLocal 6
  0085    | InsertAtIndex 0
  0087    | GetConstant 7: []
  0089    | JumpIfFailure 89 -> 95
  0092    | GetBoundLocal 4
  0094    | Merge
  0095    | JumpIfFailure 95 -> 105
  0098    | GetConstant 8: [_]
  0100    | GetBoundLocal 3
  0102    | InsertAtIndex 0
  0104    | Merge
  0105    | CallTailFunction 5
  0107    | ConditionalElse 107 -> 132
  0110    | GetConstant 9: const
  0112    | GetConstant 10: []
  0114    | JumpIfFailure 114 -> 120
  0117    | GetBoundLocal 4
  0119    | Merge
  0120    | JumpIfFailure 120 -> 130
  0123    | GetConstant 11: [_]
  0125    | GetBoundLocal 3
  0127    | InsertAtIndex 0
  0129    | Merge
  0130    | CallTailFunction 1
  0132    | End
  ========================================
  
  =================@fn878=================
  0000    | GetConstant 0: elem
  0002    | GetConstant 1: col_sep
  0004    | GetConstant 2: row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 3: _dimensions
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 2
  0015    | CallTailFunction 3
  0017    | End
  ========================================
  
  ==============rows_padded===============
  0000    | GetConstant 0: MaxRowLen
  0002    | GetConstant 1: _
  0004    | GetConstant 2: First
  0006    | GetConstant 3: peek
  0008    | GetConstant 4: @fn878
  0010    | CaptureLocal 0 0
  0013    | CaptureLocal 1 1
  0016    | CaptureLocal 2 2
  0019    | CallFunction 1
  0021    | GetConstant 5: [_, _]
  0023    | Destructure
  0024    | JumpIfFailure 24 -> 50
  0027    | GetAtIndex 0
  0029    | GetLocal 4
  0031    | Destructure
  0032    | JumpIfFailure 32 -> 48
  0035    | Pop
  0036    | GetAtIndex 1
  0038    | GetLocal 5
  0040    | Destructure
  0041    | JumpIfFailure 41 -> 48
  0044    | Pop
  0045    | JumpIfSuccess 45 -> 50
  0048    | Swap
  0049    | Pop
  0050    | TakeRight 50 -> 60
  0053    | GetBoundLocal 0
  0055    | CallFunction 0
  0057    | GetLocal 6
  0059    | Destructure
  0060    | TakeRight 60 -> 87
  0063    | GetConstant 6: _rows_padded
  0065    | GetBoundLocal 0
  0067    | GetBoundLocal 1
  0069    | GetBoundLocal 2
  0071    | GetBoundLocal 3
  0073    | GetConstant 7: 1
  0075    | GetBoundLocal 4
  0077    | GetConstant 8: [_]
  0079    | GetBoundLocal 6
  0081    | InsertAtIndex 0
  0083    | GetConstant 9: []
  0085    | CallTailFunction 8
  0087    | End
  ========================================
  
  ==============_rows_padded==============
  0000    | GetConstant 0: Elem
  0002    | GetConstant 1: NextRow
  0004    | SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | GetLocal 8
  0018    | Destructure
  0019    | ConditionalThen 19 -> 65
  0022    | GetConstant 2: _rows_padded
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | GetBoundLocal 2
  0030    | GetBoundLocal 3
  0032    | GetConstant 3: Num.Inc
  0034    | GetBoundLocal 4
  0036    | CallFunction 1
  0038    | GetBoundLocal 5
  0040    | GetConstant 4: []
  0042    | JumpIfFailure 42 -> 48
  0045    | GetBoundLocal 6
  0047    | Merge
  0048    | JumpIfFailure 48 -> 58
  0051    | GetConstant 5: [_]
  0053    | GetBoundLocal 8
  0055    | InsertAtIndex 0
  0057    | Merge
  0058    | GetBoundLocal 7
  0060    | CallTailFunction 8
  0062    | ConditionalElse 62 -> 178
  0065    | SetInputMark
  0066    | GetBoundLocal 2
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 77
  0073    | GetBoundLocal 0
  0075    | CallFunction 0
  0077    | GetLocal 9
  0079    | Destructure
  0080    | ConditionalThen 80 -> 141
  0083    | GetConstant 6: _rows_padded
  0085    | GetBoundLocal 0
  0087    | GetBoundLocal 1
  0089    | GetBoundLocal 2
  0091    | GetBoundLocal 3
  0093    | GetConstant 7: 1
  0095    | GetBoundLocal 5
  0097    | GetConstant 8: [_]
  0099    | GetBoundLocal 9
  0101    | InsertAtIndex 0
  0103    | GetConstant 9: []
  0105    | JumpIfFailure 105 -> 111
  0108    | GetBoundLocal 7
  0110    | Merge
  0111    | JumpIfFailure 111 -> 136
  0114    | GetConstant 10: [_]
  0116    | GetConstant 11: Array.AppendN
  0118    | GetBoundLocal 6
  0120    | GetBoundLocal 3
  0122    | GetBoundLocal 5
  0124    | JumpIfFailure 124 -> 131
  0127    | GetBoundLocal 4
  0129    | NegateNumber
  0130    | Merge
  0131    | CallFunction 3
  0133    | InsertAtIndex 0
  0135    | Merge
  0136    | CallTailFunction 8
  0138    | ConditionalElse 138 -> 178
  0141    | GetConstant 12: const
  0143    | GetConstant 13: []
  0145    | JumpIfFailure 145 -> 151
  0148    | GetBoundLocal 7
  0150    | Merge
  0151    | JumpIfFailure 151 -> 176
  0154    | GetConstant 14: [_]
  0156    | GetConstant 15: Array.AppendN
  0158    | GetBoundLocal 6
  0160    | GetBoundLocal 3
  0162    | GetBoundLocal 5
  0164    | JumpIfFailure 164 -> 171
  0167    | GetBoundLocal 4
  0169    | NegateNumber
  0170    | Merge
  0171    | CallFunction 3
  0173    | InsertAtIndex 0
  0175    | Merge
  0176    | CallTailFunction 1
  0178    | End
  ========================================
  
  ==============_dimensions===============
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 23
  0007    | GetConstant 0: __dimensions
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 2
  0015    | GetConstant 1: 1
  0017    | GetConstant 2: 1
  0019    | GetConstant 3: 0
  0021    | CallTailFunction 6
  0023    | End
  ========================================
  
  ==============__dimensions==============
  0000    | SetInputMark
  0001    | GetBoundLocal 1
  0003    | CallFunction 0
  0005    | TakeRight 5 -> 12
  0008    | GetBoundLocal 0
  0010    | CallFunction 0
  0012    | ConditionalThen 12 -> 38
  0015    | GetConstant 0: __dimensions
  0017    | GetBoundLocal 0
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 2
  0023    | GetConstant 1: Num.Inc
  0025    | GetBoundLocal 3
  0027    | CallFunction 1
  0029    | GetBoundLocal 4
  0031    | GetBoundLocal 5
  0033    | CallTailFunction 6
  0035    | ConditionalElse 35 -> 102
  0038    | SetInputMark
  0039    | GetBoundLocal 2
  0041    | CallFunction 0
  0043    | TakeRight 43 -> 50
  0046    | GetBoundLocal 0
  0048    | CallFunction 0
  0050    | ConditionalThen 50 -> 82
  0053    | GetConstant 2: __dimensions
  0055    | GetBoundLocal 0
  0057    | GetBoundLocal 1
  0059    | GetBoundLocal 2
  0061    | GetConstant 3: 1
  0063    | GetConstant 4: Num.Inc
  0065    | GetBoundLocal 4
  0067    | CallFunction 1
  0069    | GetConstant 5: Num.Max
  0071    | GetBoundLocal 3
  0073    | GetBoundLocal 5
  0075    | CallFunction 2
  0077    | CallTailFunction 6
  0079    | ConditionalElse 79 -> 102
  0082    | GetConstant 6: const
  0084    | GetConstant 7: [_, _]
  0086    | GetConstant 8: Num.Max
  0088    | GetBoundLocal 3
  0090    | GetBoundLocal 5
  0092    | CallFunction 2
  0094    | InsertAtIndex 0
  0096    | GetBoundLocal 4
  0098    | InsertAtIndex 1
  0100    | CallTailFunction 1
  0102    | End
  ========================================
  
  ================columns=================
  0000    | GetConstant 0: Rows
  0002    | GetConstant 1: rows
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | CallFunction 3
  0012    | GetLocal 3
  0014    | Destructure
  0015    | TakeRight 15 -> 24
  0018    | GetConstant 2: Table.Transpose
  0020    | GetBoundLocal 3
  0022    | CallTailFunction 1
  0024    | End
  ========================================
  
  =============columns_padded=============
  0000    | GetConstant 0: Rows
  0002    | GetConstant 1: rows_padded
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | GetBoundLocal 2
  0010    | GetBoundLocal 3
  0012    | CallFunction 4
  0014    | GetLocal 4
  0016    | Destructure
  0017    | TakeRight 17 -> 26
  0020    | GetConstant 2: Table.Transpose
  0022    | GetBoundLocal 4
  0024    | CallTailFunction 1
  0026    | End
  ========================================
  
  =================object=================
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 2
  0010    | Destructure
  0011    | TakeRight 11 -> 21
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | GetLocal 3
  0020    | Destructure
  0021    | TakeRight 21 -> 39
  0024    | GetConstant 2: _object
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | GetConstant 3: {}
  0032    | GetBoundLocal 2
  0034    | GetBoundLocal 3
  0036    | InsertKeyVal
  0037    | CallTailFunction 3
  0039    | End
  ========================================
  
  ================_object=================
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | GetLocal 3
  0011    | Destructure
  0012    | TakeRight 12 -> 22
  0015    | GetBoundLocal 1
  0017    | CallFunction 0
  0019    | GetLocal 4
  0021    | Destructure
  0022    | ConditionalThen 22 -> 55
  0025    | GetConstant 2: _object
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 1
  0031    | GetConstant 3: {}
  0033    | JumpIfFailure 33 -> 39
  0036    | GetBoundLocal 2
  0038    | Merge
  0039    | JumpIfFailure 39 -> 50
  0042    | GetConstant 4: {}
  0044    | GetBoundLocal 3
  0046    | GetBoundLocal 4
  0048    | InsertKeyVal
  0049    | Merge
  0050    | CallTailFunction 3
  0052    | ConditionalElse 52 -> 61
  0055    | GetConstant 5: const
  0057    | GetBoundLocal 2
  0059    | CallTailFunction 1
  0061    | End
  ========================================
  
  =================@fn893=================
  0000    | GetConstant 0: sep
  0002    | GetConstant 1: key
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn894=================
  0000    | GetConstant 0: pair_sep
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ===============object_sep===============
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 4
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 28
  0021    | GetBoundLocal 2
  0023    | CallFunction 0
  0025    | GetLocal 5
  0027    | Destructure
  0028    | TakeRight 28 -> 58
  0031    | GetConstant 2: _object
  0033    | GetConstant 3: @fn893
  0035    | CaptureLocal 0 1
  0038    | CaptureLocal 3 0
  0041    | GetConstant 4: @fn894
  0043    | CaptureLocal 1 0
  0046    | CaptureLocal 2 1
  0049    | GetConstant 5: {}
  0051    | GetBoundLocal 4
  0053    | GetBoundLocal 5
  0055    | InsertKeyVal
  0056    | CallTailFunction 3
  0058    | End
  ========================================
  
  ==============object_until==============
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | GetConstant 2: unless
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 2
  0010    | CallFunction 2
  0012    | GetLocal 3
  0014    | Destructure
  0015    | TakeRight 15 -> 25
  0018    | GetBoundLocal 1
  0020    | CallFunction 0
  0022    | GetLocal 4
  0024    | Destructure
  0025    | TakeRight 25 -> 45
  0028    | GetConstant 3: _object_until
  0030    | GetBoundLocal 0
  0032    | GetBoundLocal 1
  0034    | GetBoundLocal 2
  0036    | GetConstant 4: {}
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 4
  0042    | InsertKeyVal
  0043    | CallTailFunction 4
  0045    | End
  ========================================
  
  =============_object_until==============
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | SetInputMark
  0005    | GetConstant 2: peek
  0007    | GetBoundLocal 2
  0009    | CallFunction 1
  0011    | ConditionalThen 11 -> 23
  0014    | GetConstant 3: const
  0016    | GetBoundLocal 3
  0018    | CallTailFunction 1
  0020    | ConditionalElse 20 -> 72
  0023    | GetBoundLocal 0
  0025    | CallFunction 0
  0027    | GetLocal 4
  0029    | Destructure
  0030    | TakeRight 30 -> 40
  0033    | GetBoundLocal 1
  0035    | CallFunction 0
  0037    | GetLocal 5
  0039    | Destructure
  0040    | TakeRight 40 -> 72
  0043    | GetConstant 4: _object_until
  0045    | GetBoundLocal 0
  0047    | GetBoundLocal 1
  0049    | GetBoundLocal 2
  0051    | GetConstant 5: {}
  0053    | JumpIfFailure 53 -> 59
  0056    | GetBoundLocal 3
  0058    | Merge
  0059    | JumpIfFailure 59 -> 70
  0062    | GetConstant 6: {}
  0064    | GetBoundLocal 4
  0066    | GetBoundLocal 5
  0068    | InsertKeyVal
  0069    | Merge
  0070    | CallTailFunction 4
  0072    | End
  ========================================
  
  =================@fn899=================
  0000    | GetConstant 0: key
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetConstant 2: object
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn899
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: {}
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================@fn901=================
  0000    | GetConstant 0: key
  0002    | GetConstant 1: pair_sep
  0004    | GetConstant 2: value
  0006    | GetConstant 3: sep
  0008    | SetClosureCaptures
  0009    | GetConstant 4: object_sep
  0011    | GetBoundLocal 0
  0013    | GetBoundLocal 1
  0015    | GetBoundLocal 2
  0017    | GetBoundLocal 3
  0019    | CallTailFunction 4
  0021    | End
  ========================================
  
  ============maybe_object_sep============
  0000    | GetConstant 0: default
  0002    | GetConstant 1: @fn901
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | CaptureLocal 3 3
  0016    | GetConstant 2: {}
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ==================pair==================
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 2
  0010    | Destructure
  0011    | TakeRight 11 -> 31
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | GetLocal 3
  0020    | Destructure
  0021    | TakeRight 21 -> 31
  0024    | GetConstant 2: {}
  0026    | GetBoundLocal 2
  0028    | GetBoundLocal 3
  0030    | InsertKeyVal
  0031    | End
  ========================================
  
  ================pair_sep================
  0000    | GetConstant 0: K
  0002    | GetConstant 1: V
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 3
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 38
  0021    | GetBoundLocal 2
  0023    | CallFunction 0
  0025    | GetLocal 4
  0027    | Destructure
  0028    | TakeRight 28 -> 38
  0031    | GetConstant 2: {}
  0033    | GetBoundLocal 3
  0035    | GetBoundLocal 4
  0037    | InsertKeyVal
  0038    | End
  ========================================
  
  ================record1=================
  0000    | GetConstant 0: Value
  0002    | GetBoundLocal 1
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 19
  0012    | GetConstant 1: {}
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 2
  0018    | InsertKeyVal
  0019    | End
  ========================================
  
  ================record2=================
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
  0004    | GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 4
  0010    | Destructure
  0011    | TakeRight 11 -> 36
  0014    | GetBoundLocal 3
  0016    | CallFunction 0
  0018    | GetLocal 5
  0020    | Destructure
  0021    | TakeRight 21 -> 36
  0024    | GetConstant 2: {}
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 4
  0030    | InsertKeyVal
  0031    | GetBoundLocal 2
  0033    | GetBoundLocal 5
  0035    | InsertKeyVal
  0036    | End
  ========================================
  
  ==============record2_sep===============
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
  0004    | GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 5
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 2
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 43
  0021    | GetBoundLocal 4
  0023    | CallFunction 0
  0025    | GetLocal 6
  0027    | Destructure
  0028    | TakeRight 28 -> 43
  0031    | GetConstant 2: {}
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 5
  0037    | InsertKeyVal
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 6
  0042    | InsertKeyVal
  0043    | End
  ========================================
  
  ================record3=================
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
  0004    | GetConstant 2: V3
  0006    | GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 6
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016    | GetBoundLocal 3
  0018    | CallFunction 0
  0020    | GetLocal 7
  0022    | Destructure
  0023    | TakeRight 23 -> 53
  0026    | GetBoundLocal 5
  0028    | CallFunction 0
  0030    | GetLocal 8
  0032    | Destructure
  0033    | TakeRight 33 -> 53
  0036    | GetConstant 3: {}
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 6
  0042    | InsertKeyVal
  0043    | GetBoundLocal 2
  0045    | GetBoundLocal 7
  0047    | InsertKeyVal
  0048    | GetBoundLocal 4
  0050    | GetBoundLocal 8
  0052    | InsertKeyVal
  0053    | End
  ========================================
  
  ==============record3_sep===============
  0000    | GetConstant 0: V1
  0002    | GetConstant 1: V2
  0004    | GetConstant 2: V3
  0006    | GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 8
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 2
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023    | GetBoundLocal 4
  0025    | CallFunction 0
  0027    | GetLocal 9
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 5
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 67
  0040    | GetBoundLocal 7
  0042    | CallFunction 0
  0044    | GetLocal 10
  0046    | Destructure
  0047    | TakeRight 47 -> 67
  0050    | GetConstant 3: {}
  0052    | GetBoundLocal 0
  0054    | GetBoundLocal 8
  0056    | InsertKeyVal
  0057    | GetBoundLocal 3
  0059    | GetBoundLocal 9
  0061    | InsertKeyVal
  0062    | GetBoundLocal 6
  0064    | GetBoundLocal 10
  0066    | InsertKeyVal
  0067    | End
  ========================================
  
  ==================many==================
  0000    | GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 1
  0008    | Destructure
  0009    | TakeRight 9 -> 20
  0012    | GetConstant 1: _many
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 1
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  =================_many==================
  0000    | GetConstant 0: Next
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | GetLocal 2
  0009    | Destructure
  0010    | ConditionalThen 10 -> 30
  0013    | GetConstant 1: _many
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | JumpIfFailure 19 -> 25
  0022    | GetBoundLocal 2
  0024    | Merge
  0025    | CallTailFunction 2
  0027    | ConditionalElse 27 -> 36
  0030    | GetConstant 2: const
  0032    | GetBoundLocal 1
  0034    | CallTailFunction 1
  0036    | End
  ========================================
  
  =================@fn910=================
  0000    | GetConstant 0: sep
  0002    | GetConstant 1: p
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ================many_sep================
  0000    | GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 26
  0012    | GetConstant 1: _many
  0014    | GetConstant 2: @fn910
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetBoundLocal 2
  0024    | CallTailFunction 2
  0026    | End
  ========================================
  
  ===============many_until===============
  0000    | GetConstant 0: First
  0002    | GetConstant 1: unless
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | GetLocal 2
  0012    | Destructure
  0013    | TakeRight 13 -> 26
  0016    | GetConstant 2: _many_until
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | GetBoundLocal 2
  0024    | CallTailFunction 3
  0026    | End
  ========================================
  
  ==============_many_until===============
  0000    | GetConstant 0: Next
  0002    | SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012    | GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 47
  0021    | GetBoundLocal 0
  0023    | CallFunction 0
  0025    | GetLocal 3
  0027    | Destructure
  0028    | TakeRight 28 -> 47
  0031    | GetConstant 3: _many_until
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | GetBoundLocal 2
  0039    | JumpIfFailure 39 -> 45
  0042    | GetBoundLocal 3
  0044    | Merge
  0045    | CallTailFunction 3
  0047    | End
  ========================================
  
  ===============maybe_many===============
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 14
  0010    | GetConstant 1: succeed
  0012    | CallFunction 0
  0014    | End
  ========================================
  
  =============maybe_many_sep=============
  0000    | SetInputMark
  0001    | GetConstant 0: many_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | Or 9 -> 16
  0012    | GetConstant 1: succeed
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  ================repeat2=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  ================repeat3=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Merge
  0020    | End
  ========================================
  
  ================repeat4=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetBoundLocal 0
  0025    | CallFunction 0
  0027    | Merge
  0028    | End
  ========================================
  
  ================repeat5=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetBoundLocal 0
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetBoundLocal 0
  0033    | CallFunction 0
  0035    | Merge
  0036    | End
  ========================================
  
  ================repeat6=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetBoundLocal 0
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetBoundLocal 0
  0033    | CallFunction 0
  0035    | Merge
  0036    | JumpIfFailure 36 -> 44
  0039    | GetBoundLocal 0
  0041    | CallFunction 0
  0043    | Merge
  0044    | End
  ========================================
  
  ================repeat7=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetBoundLocal 0
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetBoundLocal 0
  0033    | CallFunction 0
  0035    | Merge
  0036    | JumpIfFailure 36 -> 44
  0039    | GetBoundLocal 0
  0041    | CallFunction 0
  0043    | Merge
  0044    | JumpIfFailure 44 -> 52
  0047    | GetBoundLocal 0
  0049    | CallFunction 0
  0051    | Merge
  0052    | End
  ========================================
  
  ================repeat8=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetBoundLocal 0
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetBoundLocal 0
  0033    | CallFunction 0
  0035    | Merge
  0036    | JumpIfFailure 36 -> 44
  0039    | GetBoundLocal 0
  0041    | CallFunction 0
  0043    | Merge
  0044    | JumpIfFailure 44 -> 52
  0047    | GetBoundLocal 0
  0049    | CallFunction 0
  0051    | Merge
  0052    | JumpIfFailure 52 -> 60
  0055    | GetBoundLocal 0
  0057    | CallFunction 0
  0059    | Merge
  0060    | End
  ========================================
  
  ================repeat9=================
  0000    | GetBoundLocal 0
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetBoundLocal 0
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetBoundLocal 0
  0033    | CallFunction 0
  0035    | Merge
  0036    | JumpIfFailure 36 -> 44
  0039    | GetBoundLocal 0
  0041    | CallFunction 0
  0043    | Merge
  0044    | JumpIfFailure 44 -> 52
  0047    | GetBoundLocal 0
  0049    | CallFunction 0
  0051    | Merge
  0052    | JumpIfFailure 52 -> 60
  0055    | GetBoundLocal 0
  0057    | CallFunction 0
  0059    | Merge
  0060    | JumpIfFailure 60 -> 68
  0063    | GetBoundLocal 0
  0065    | CallFunction 0
  0067    | Merge
  0068    | End
  ========================================
  
  =================repeat=================
  0000    | GetConstant 0: const
  0002    | GetConstant 1: _Assert.NonNegativeInteger
  0004    | GetBoundLocal 1
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 22
  0013    | GetConstant 2: _repeat
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | Null
  0020    | CallTailFunction 3
  0022    | End
  ========================================
  
  ================_repeat=================
  0000    | GetConstant 0: Next
  0002    | SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 1
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017    | GetConstant 4: const
  0019    | GetBoundLocal 2
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 56
  0026    | GetBoundLocal 0
  0028    | CallFunction 0
  0030    | GetLocal 3
  0032    | Destructure
  0033    | TakeRight 33 -> 56
  0036    | GetConstant 5: _repeat
  0038    | GetBoundLocal 0
  0040    | GetConstant 6: Num.Dec
  0042    | GetBoundLocal 1
  0044    | CallFunction 1
  0046    | GetBoundLocal 2
  0048    | JumpIfFailure 48 -> 54
  0051    | GetBoundLocal 3
  0053    | Merge
  0054    | CallTailFunction 3
  0056    | End
  ========================================
  
  =============repeat_between=============
  0000    | GetConstant 0: const
  0002    | GetConstant 1: _Assert.NonNegativeInteger
  0004    | GetBoundLocal 1
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 23
  0013    | GetConstant 2: const
  0015    | GetConstant 3: _Assert.NonNegativeInteger
  0017    | GetBoundLocal 2
  0019    | CallFunction 1
  0021    | CallFunction 1
  0023    | TakeRight 23 -> 37
  0026    | GetConstant 4: _repeat_between
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 1
  0032    | GetBoundLocal 2
  0034    | Null
  0035    | CallTailFunction 4
  0037    | End
  ========================================
  
  ============_repeat_between=============
  0000    | GetConstant 0: Next
  0002    | SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 2
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017    | GetConstant 4: const
  0019    | GetBoundLocal 3
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 94
  0026    | SetInputMark
  0027    | GetBoundLocal 0
  0029    | CallFunction 0
  0031    | GetLocal 4
  0033    | Destructure
  0034    | ConditionalThen 34 -> 66
  0037    | GetConstant 5: _repeat_between
  0039    | GetBoundLocal 0
  0041    | GetConstant 6: Num.Dec
  0043    | GetBoundLocal 1
  0045    | CallFunction 1
  0047    | GetConstant 7: Num.Dec
  0049    | GetBoundLocal 2
  0051    | CallFunction 1
  0053    | GetBoundLocal 3
  0055    | JumpIfFailure 55 -> 61
  0058    | GetBoundLocal 4
  0060    | Merge
  0061    | CallTailFunction 4
  0063    | ConditionalElse 63 -> 94
  0066    | SetInputMark
  0067    | GetConstant 8: const
  0069    | GetBoundLocal 1
  0071    | GetConstant 9: _
  0073    | GetConstant 10: 0
  0075    | DestructureRange
  0076    | CallFunction 1
  0078    | ConditionalThen 78 -> 90
  0081    | GetConstant 11: const
  0083    | GetBoundLocal 3
  0085    | CallTailFunction 1
  0087    | ConditionalElse 87 -> 94
  0090    | GetConstant 12: @fail
  0092    | CallFunction 0
  0094    | End
  ========================================
  
  ==============one_or_both===============
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | JumpIfFailure 5 -> 15
  0008    | GetConstant 0: maybe
  0010    | GetBoundLocal 1
  0012    | CallFunction 1
  0014    | Merge
  0015    | Or 15 -> 32
  0018    | GetConstant 1: maybe
  0020    | GetBoundLocal 0
  0022    | CallFunction 1
  0024    | JumpIfFailure 24 -> 32
  0027    | GetBoundLocal 1
  0029    | CallFunction 0
  0031    | Merge
  0032    | End
  ========================================
  
  ==================peek==================
  0000    | GetConstant 0: V
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | GetLocal 1
  0009    | Destructure
  0010    | Backtrack 10 -> 19
  0013    | GetConstant 1: const
  0015    | GetBoundLocal 1
  0017    | CallTailFunction 1
  0019    | End
  ========================================
  
  =================maybe==================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 0: succeed
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================unless=================
  0000    | SetInputMark
  0001    | GetBoundLocal 1
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 0: @fail
  0010    | CallFunction 0
  0012    | ConditionalElse 12 -> 19
  0015    | GetBoundLocal 0
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  ==================skip==================
  0000    | GetConstant 0: null
  0002    | GetBoundLocal 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================find==================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 21
  0008    | GetConstant 0: char
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 21
  0015    | GetConstant 1: find
  0017    | GetBoundLocal 0
  0019    | CallTailFunction 1
  0021    | End
  ========================================
  
  =================@fn911=================
  0000    | GetConstant 0: p
  0002    | SetClosureCaptures
  0003    | GetConstant 1: find
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn912=================
  0000    | GetConstant 0: many
  0002    | GetConstant 1: char
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================find_all================
  0000    | GetConstant 0: array
  0002    | GetConstant 1: @fn911
  0004    | CaptureLocal 0 0
  0007    | CallFunction 1
  0009    | JumpIfFailure 9 -> 19
  0012    | GetConstant 2: maybe
  0014    | GetConstant 3: @fn912
  0016    | CallFunction 1
  0018    | TakeLeft
  0019    | End
  ========================================
  
  ==============find_before===============
  0000    | SetInputMark
  0001    | GetBoundLocal 1
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 0: @fail
  0010    | CallFunction 0
  0012    | ConditionalElse 12 -> 38
  0015    | SetInputMark
  0016    | GetBoundLocal 0
  0018    | CallFunction 0
  0020    | Or 20 -> 38
  0023    | GetConstant 1: char
  0025    | CallFunction 0
  0027    | TakeRight 27 -> 38
  0030    | GetConstant 2: find_before
  0032    | GetBoundLocal 0
  0034    | GetBoundLocal 1
  0036    | CallTailFunction 2
  0038    | End
  ========================================
  
  =================@fn913=================
  0000    | GetConstant 0: p
  0002    | GetConstant 1: stop
  0004    | SetClosureCaptures
  0005    | GetConstant 2: find_before
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  =================@fn914=================
  0000    | GetConstant 0: stop
  0002    | SetClosureCaptures
  0003    | GetConstant 1: chars_until
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ============find_all_before=============
  0000    | GetConstant 0: array
  0002    | GetConstant 1: @fn913
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CallFunction 1
  0012    | JumpIfFailure 12 -> 25
  0015    | GetConstant 2: maybe
  0017    | GetConstant 3: @fn914
  0019    | CaptureLocal 1 0
  0022    | CallFunction 1
  0024    | TakeLeft
  0025    | End
  ========================================
  
  ================succeed=================
  0000    | GetConstant 0: const
  0002    | Null
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ================default=================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 14
  0008    | GetConstant 0: const
  0010    | GetBoundLocal 1
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  =================const==================
  0000    | GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 9
  0007    | GetBoundLocal 0
  0009    | End
  ========================================
  
  ===============string_of================
  0000    | GetConstant 0: ""
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | MergeAsString
  0007    | End
  ========================================
  
  ================surround================
  0000    | GetBoundLocal 1
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetBoundLocal 0
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  ==============end_of_input==============
  0000    | SetInputMark
  0001    | GetConstant 0: char
  0003    | CallFunction 0
  0005    | ConditionalThen 5 -> 15
  0008    | GetConstant 1: @fail
  0010    | CallFunction 0
  0012    | ConditionalElse 12 -> 19
  0015    | GetConstant 2: succeed
  0017    | CallFunction 0
  0019    | End
  ========================================
  
  =================@fn915=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  0000    | GetConstant 0: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: @fn915
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 16
  0011    | GetConstant 2: end_of_input
  0013    | CallFunction 0
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ==================json==================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | GetConstant 0: json.boolean
  0007    | CallFunction 0
  0009    | Or 9 -> 16
  0012    | GetConstant 1: json.null
  0014    | CallFunction 0
  0016    | Or 16 -> 23
  0019    | GetConstant 2: number
  0021    | CallFunction 0
  0023    | Or 23 -> 30
  0026    | GetConstant 3: json.string
  0028    | CallFunction 0
  0030    | Or 30 -> 39
  0033    | GetConstant 4: json.array
  0035    | GetConstant 5: json
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042    | GetConstant 6: json.object
  0044    | GetConstant 7: json
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  ==============json.boolean==============
  0000    | GetConstant 0: boolean
  0002    | GetConstant 1: "true"
  0004    | GetConstant 2: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============json.null================
  0000    | GetConstant 0: null
  0002    | GetConstant 1: "null"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============json.string===============
  0000    | GetConstant 0: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 1: _json.string_body
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetConstant 2: """
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =================@fn917=================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: _ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 13
  0009    | GetConstant 1: "\"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: """
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn916=================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: _escaped_ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 13
  0009    | GetConstant 1: _escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 24
  0016    | GetConstant 2: unless
  0018    | GetConstant 3: char
  0020    | GetConstant 4: @fn917
  0022    | CallTailFunction 2
  0024    | End
  ========================================
  
  ===========_json.string_body============
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetConstant 1: @fn916
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 2: const
  0012    | GetConstant 3: ""
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ===============_ctrl_char===============
  0000    | ParseRange 0 1: "\x00" "\x1f" (esc)
  0003    | End
  ========================================
  
  ===========_escaped_ctrl_char===========
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | SetInputMark
  0006    | SetInputMark
  0007    | GetConstant 0: "\""
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 16
  0014    | GetConstant 1: """
  0016    | Or 16 -> 28
  0019    | GetConstant 2: "\\"
  0021    | CallFunction 0
  0023    | TakeRight 23 -> 28
  0026    | GetConstant 3: "\"
  0028    | Or 28 -> 40
  0031    | GetConstant 4: "\/"
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 40
  0038    | GetConstant 5: "/"
  0040    | Or 40 -> 52
  0043    | GetConstant 6: "\b"
  0045    | CallFunction 0
  0047    | TakeRight 47 -> 52
  0050    | GetConstant 7: "\x08" (esc)
  0052    | Or 52 -> 64
  0055    | GetConstant 8: "\f"
  0057    | CallFunction 0
  0059    | TakeRight 59 -> 64
  0062    | GetConstant 9: "\x0c" (esc)
  0064    | Or 64 -> 76
  0067    | GetConstant 10: "\n"
  0069    | CallFunction 0
  0071    | TakeRight 71 -> 76
  0074    | GetConstant 11: "
  "
  0076    | Or 76 -> 88
  0079    | GetConstant 12: "\r"
  0081    | CallFunction 0
  0083    | TakeRight 83 -> 88
  0086    | GetConstant 13: "\r (no-eol) (esc)
  "
  0088    | Or 88 -> 100
  0091    | GetConstant 14: "\t"
  0093    | CallFunction 0
  0095    | TakeRight 95 -> 100
  0098    | GetConstant 15: "\t" (esc)
  0100    | End
  ========================================
  
  ============_escaped_unicode============
  0000    | SetInputMark
  0001    | GetConstant 0: _escaped_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _escaped_codepoint
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========_escaped_surrogate_pair=========
  0000    | SetInputMark
  0001    | GetConstant 0: _valid_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _invalid_surrogate_pair
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_valid_surrogate_pair==========
  0000    | GetConstant 0: H
  0002    | GetConstant 1: L
  0004    | GetConstant 2: _high_surrogate
  0006    | CallFunction 0
  0008    | GetLocal 0
  0010    | Destructure
  0011    | TakeRight 11 -> 32
  0014    | GetConstant 3: _low_surrogate
  0016    | CallFunction 0
  0018    | GetLocal 1
  0020    | Destructure
  0021    | TakeRight 21 -> 32
  0024    | GetConstant 4: @SurrogatePairCodepoint
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | CallTailFunction 2
  0032    | End
  ========================================
  
  ========_invalid_surrogate_pair=========
  0000    | SetInputMark
  0001    | GetConstant 0: _low_surrogate
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _high_surrogate
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 17
  0015    | GetConstant 2: "\xef\xbf\xbd" (esc)
  0017    | End
  ========================================
  
  ============_high_surrogate=============
  0000    | GetConstant 0: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | GetConstant 1: "D"
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | GetConstant 2: "d"
  0017    | CallFunction 0
  0019    | JumpIfFailure 19 -> 67
  0022    | SetInputMark
  0023    | SetInputMark
  0024    | SetInputMark
  0025    | SetInputMark
  0026    | SetInputMark
  0027    | GetConstant 3: "8"
  0029    | CallFunction 0
  0031    | Or 31 -> 38
  0034    | GetConstant 4: "9"
  0036    | CallFunction 0
  0038    | Or 38 -> 45
  0041    | GetConstant 5: "A"
  0043    | CallFunction 0
  0045    | Or 45 -> 52
  0048    | GetConstant 6: "B"
  0050    | CallFunction 0
  0052    | Or 52 -> 59
  0055    | GetConstant 7: "a"
  0057    | CallFunction 0
  0059    | Or 59 -> 66
  0062    | GetConstant 8: "b"
  0064    | CallFunction 0
  0066    | Merge
  0067    | JumpIfFailure 67 -> 75
  0070    | GetConstant 9: hex_numeral
  0072    | CallFunction 0
  0074    | Merge
  0075    | JumpIfFailure 75 -> 83
  0078    | GetConstant 10: hex_numeral
  0080    | CallFunction 0
  0082    | Merge
  0083    | End
  ========================================
  
  =============_low_surrogate=============
  0000    | GetConstant 0: "\u"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007    | SetInputMark
  0008    | GetConstant 1: "D"
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | GetConstant 2: "d"
  0017    | CallFunction 0
  0019    | JumpIfFailure 19 -> 33
  0022    | SetInputMark
  0023    | ParseRange 3 4: "C" "F"
  0026    | Or 26 -> 32
  0029    | ParseRange 5 6: "c" "f"
  0032    | Merge
  0033    | JumpIfFailure 33 -> 41
  0036    | GetConstant 7: hex_numeral
  0038    | CallFunction 0
  0040    | Merge
  0041    | JumpIfFailure 41 -> 49
  0044    | GetConstant 8: hex_numeral
  0046    | CallFunction 0
  0048    | Merge
  0049    | End
  ========================================
  
  ===========_escaped_codepoint===========
  0000    | GetConstant 0: U
  0002    | GetConstant 1: "\u"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 15
  0009    | GetConstant 2: repeat4
  0011    | GetConstant 3: hex_numeral
  0013    | CallFunction 1
  0015    | GetLocal 0
  0017    | Destructure
  0018    | TakeRight 18 -> 27
  0021    | GetConstant 4: @Codepoint
  0023    | GetBoundLocal 0
  0025    | CallTailFunction 1
  0027    | End
  ========================================
  
  =================@fn919=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn918=================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: @fn919
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===============json.array===============
  0000    | GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 18
  0007    | GetConstant 1: maybe_array_sep
  0009    | GetConstant 2: @fn918
  0011    | CaptureLocal 0 0
  0014    | GetConstant 3: ","
  0016    | CallFunction 2
  0018    | JumpIfFailure 18 -> 26
  0021    | GetConstant 4: "]"
  0023    | CallFunction 0
  0025    | TakeLeft
  0026    | End
  ========================================
  
  =================@fn921=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn920=================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: json.string
  0004    | GetConstant 2: @fn921
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn923=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn922=================
  0000    | GetConstant 0: value
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: @fn923
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ==============json.object===============
  0000    | GetConstant 0: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 22
  0007    | GetConstant 1: maybe_object_sep
  0009    | GetConstant 2: @fn920
  0011    | GetConstant 3: ":"
  0013    | GetConstant 4: @fn922
  0015    | CaptureLocal 0 0
  0018    | GetConstant 5: ","
  0020    | CallFunction 4
  0022    | JumpIfFailure 22 -> 30
  0025    | GetConstant 6: "}"
  0027    | CallFunction 0
  0029    | TakeLeft
  0030    | End
  ========================================
  
  ==============toml.simple===============
  0000    | GetConstant 0: toml.custom
  0002    | GetConstant 1: toml.simple_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============toml.tagged===============
  0000    | GetConstant 0: toml.custom
  0002    | GetConstant 1: toml.tagged_value
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn924=================
  0000    | GetConstant 0: _toml.comments
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 14
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: whitespace
  0011    | CallFunction 1
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn925=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _toml.comments
  0011    | CallFunction 0
  0013    | Merge
  0014    | End
  ========================================
  
  ==============toml.custom===============
  0000    | GetConstant 0: Doc
  0002    | GetConstant 1: maybe
  0004    | GetConstant 2: @fn924
  0006    | CallFunction 1
  0008    | TakeRight 8 -> 30
  0011    | SetInputMark
  0012    | GetConstant 3: _toml.with_root_table
  0014    | GetBoundLocal 0
  0016    | CallFunction 1
  0018    | Or 18 -> 27
  0021    | GetConstant 4: _toml.no_root_table
  0023    | GetBoundLocal 0
  0025    | CallFunction 1
  0027    | GetLocal 1
  0029    | Destructure
  0030    | TakeRight 30 -> 48
  0033    | GetConstant 5: maybe
  0035    | GetConstant 6: @fn925
  0037    | CallFunction 1
  0039    | TakeRight 39 -> 48
  0042    | GetConstant 7: _Toml.Doc.Value
  0044    | GetBoundLocal 1
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  =========_toml.with_root_table==========
  0000    | GetConstant 0: RootDoc
  0002    | GetConstant 1: _toml.root_table
  0004    | GetBoundLocal 0
  0006    | GetConstant 2: _Toml.Doc.Empty
  0008    | CallFunction 0
  0010    | CallFunction 2
  0012    | GetLocal 1
  0014    | Destructure
  0015    | TakeRight 15 -> 43
  0018    | SetInputMark
  0019    | GetConstant 3: _toml.ws
  0021    | CallFunction 0
  0023    | TakeRight 23 -> 34
  0026    | GetConstant 4: _toml.tables
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 1
  0032    | CallFunction 2
  0034    | Or 34 -> 43
  0037    | GetConstant 5: const
  0039    | GetBoundLocal 1
  0041    | CallTailFunction 1
  0043    | End
  ========================================
  
  ============_toml.root_table============
  0000    | GetConstant 0: _toml.table_body
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | GetBoundLocal 1
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==========_toml.no_root_table===========
  0000    | GetConstant 0: NewDoc
  0002    | SetInputMark
  0003    | GetConstant 1: _toml.table
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: _Toml.Doc.Empty
  0009    | CallFunction 0
  0011    | CallFunction 2
  0013    | Or 13 -> 26
  0016    | GetConstant 3: _toml.array_of_tables
  0018    | GetBoundLocal 0
  0020    | GetConstant 4: _Toml.Doc.Empty
  0022    | CallFunction 0
  0024    | CallFunction 2
  0026    | GetLocal 1
  0028    | Destructure
  0029    | TakeRight 29 -> 40
  0032    | GetConstant 5: _toml.tables
  0034    | GetBoundLocal 0
  0036    | GetBoundLocal 1
  0038    | CallTailFunction 2
  0040    | End
  ========================================
  
  ==============_toml.tables==============
  0000    | GetConstant 0: NewDoc
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | GetConstant 1: _toml.ws
  0006    | CallFunction 0
  0008    | TakeRight 8 -> 19
  0011    | GetConstant 2: _toml.table
  0013    | GetBoundLocal 0
  0015    | GetBoundLocal 1
  0017    | CallFunction 2
  0019    | Or 19 -> 30
  0022    | GetConstant 3: _toml.array_of_tables
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | CallFunction 2
  0030    | GetLocal 2
  0032    | Destructure
  0033    | ConditionalThen 33 -> 47
  0036    | GetConstant 4: _toml.tables
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 2
  0042    | CallTailFunction 2
  0044    | ConditionalElse 44 -> 53
  0047    | GetConstant 5: const
  0049    | GetBoundLocal 1
  0051    | CallTailFunction 1
  0053    | End
  ========================================
  
  ==============_toml.table===============
  0000    | GetConstant 0: HeaderPath
  0002    | GetConstant 1: _toml.table_header
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 16
  0012    | GetConstant 2: _toml.ws_newline
  0014    | CallFunction 0
  0016    | TakeRight 16 -> 45
  0019    | SetInputMark
  0020    | GetConstant 3: _toml.table_body
  0022    | GetBoundLocal 0
  0024    | GetBoundLocal 2
  0026    | GetBoundLocal 1
  0028    | CallFunction 3
  0030    | Or 30 -> 45
  0033    | GetConstant 4: const
  0035    | GetConstant 5: _Toml.Doc.EnsureTableAtPath
  0037    | GetBoundLocal 1
  0039    | GetBoundLocal 2
  0041    | CallFunction 2
  0043    | CallTailFunction 1
  0045    | End
  ========================================
  
  =================@fn927=================
  0000    | GetConstant 0: value
  0002    | SetClosureCaptures
  0003    | GetConstant 1: _toml.table_body
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: []
  0009    | GetConstant 3: _Toml.Doc.Empty
  0011    | CallFunction 0
  0013    | CallTailFunction 3
  0015    | End
  ========================================
  
  =========_toml.array_of_tables==========
  0000    | GetConstant 0: HeaderPath
  0002    | GetConstant 1: InnerDoc
  0004    | GetConstant 2: _toml.array_of_tables_header
  0006    | CallFunction 0
  0008    | GetLocal 2
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetConstant 3: _toml.ws_newline
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 54
  0021    | GetConstant 4: default
  0023    | GetConstant 5: @fn927
  0025    | CaptureLocal 0 0
  0028    | GetConstant 6: _Toml.Doc.Empty
  0030    | CallFunction 0
  0032    | CallFunction 2
  0034    | GetLocal 3
  0036    | Destructure
  0037    | TakeRight 37 -> 54
  0040    | GetConstant 7: _Toml.Doc.AppendAtPath
  0042    | GetBoundLocal 1
  0044    | GetBoundLocal 2
  0046    | GetConstant 8: _Toml.Doc.Value
  0048    | GetBoundLocal 3
  0050    | CallFunction 1
  0052    | CallTailFunction 3
  0054    | End
  ========================================
  
  =================@fn929=================
  0000    | SetInputMark
  0001    | GetConstant 0: whitespace
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _toml.comment
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ================_toml.ws================
  0000    | GetConstant 0: maybe_many
  0002    | GetConstant 1: @fn929
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn930=================
  0000    | SetInputMark
  0001    | GetConstant 0: spaces
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _toml.comment
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =============_toml.ws_line==============
  0000    | GetConstant 0: maybe_many
  0002    | GetConstant 1: @fn930
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ============_toml.ws_newline============
  0000    | GetConstant 0: _toml.ws_line
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 20
  0007    | SetInputMark
  0008    | GetConstant 1: newline
  0010    | CallFunction 0
  0012    | Or 12 -> 19
  0015    | GetConstant 2: end_of_input
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetConstant 3: _toml.ws
  0025    | CallFunction 0
  0027    | Merge
  0028    | End
  ========================================
  
  =============_toml.comments=============
  0000    | GetConstant 0: many_sep
  0002    | GetConstant 1: _toml.comment
  0004    | GetConstant 2: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn931=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ===========_toml.table_header===========
  0000    | GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: surround
  0009    | GetConstant 2: _toml.path
  0011    | GetConstant 3: @fn931
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 4: "]"
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
  ========================================
  
  =================@fn932=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ======_toml.array_of_tables_header======
  0000    | GetConstant 0: "[["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: surround
  0009    | GetConstant 2: _toml.path
  0011    | GetConstant 3: @fn932
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 4: "]]"
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
  ========================================
  
  ============_toml.table_body============
  0000    | GetConstant 0: KeyPath
  0002    | GetConstant 1: Val
  0004    | GetConstant 2: NewDoc
  0006    | GetConstant 3: _toml.table_pair
  0008    | GetBoundLocal 0
  0010    | CallFunction 1
  0012    | GetConstant 4: [_, _]
  0014    | Destructure
  0015    | JumpIfFailure 15 -> 41
  0018    | GetAtIndex 0
  0020    | GetLocal 3
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 39
  0026    | Pop
  0027    | GetAtIndex 1
  0029    | GetLocal 4
  0031    | Destructure
  0032    | JumpIfFailure 32 -> 39
  0035    | Pop
  0036    | JumpIfSuccess 36 -> 41
  0039    | Swap
  0040    | Pop
  0041    | TakeRight 41 -> 48
  0044    | GetConstant 5: _toml.ws_newline
  0046    | CallFunction 0
  0048    | TakeRight 48 -> 74
  0051    | GetConstant 6: const
  0053    | GetConstant 7: _Toml.Doc.InsertAtPath
  0055    | GetBoundLocal 2
  0057    | GetBoundLocal 1
  0059    | JumpIfFailure 59 -> 65
  0062    | GetBoundLocal 3
  0064    | Merge
  0065    | GetBoundLocal 4
  0067    | CallFunction 3
  0069    | CallFunction 1
  0071    | GetLocal 5
  0073    | Destructure
  0074    | TakeRight 74 -> 97
  0077    | SetInputMark
  0078    | GetConstant 8: _toml.table_body
  0080    | GetBoundLocal 0
  0082    | GetBoundLocal 1
  0084    | GetBoundLocal 5
  0086    | CallFunction 3
  0088    | Or 88 -> 97
  0091    | GetConstant 9: const
  0093    | GetBoundLocal 5
  0095    | CallTailFunction 1
  0097    | End
  ========================================
  
  =================@fn935=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: spaces
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn934=================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: "="
  0004    | GetConstant 2: @fn935
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_toml.table_pair============
  0000    | GetConstant 0: tuple2_sep
  0002    | GetConstant 1: _toml.path
  0004    | GetConstant 2: @fn934
  0006    | GetBoundLocal 0
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =================@fn937=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn936=================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: "."
  0004    | GetConstant 2: @fn937
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============_toml.path===============
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: _toml.key
  0004    | GetConstant 2: @fn936
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn938=================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | GetConstant 0: alpha
  0005    | CallFunction 0
  0007    | Or 7 -> 14
  0010    | GetConstant 1: numeral
  0012    | CallFunction 0
  0014    | Or 14 -> 21
  0017    | GetConstant 2: "_"
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 3: "-"
  0026    | CallFunction 0
  0028    | End
  ========================================
  
  ===============_toml.key================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: many
  0004    | GetConstant 1: @fn938
  0006    | CallFunction 1
  0008    | Or 8 -> 15
  0011    | GetConstant 2: toml.string.basic
  0013    | CallFunction 0
  0015    | Or 15 -> 22
  0018    | GetConstant 3: toml.string.literal
  0020    | CallFunction 0
  0022    | End
  ========================================
  
  =============_toml.comment==============
  0000    | GetConstant 0: "#"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: line
  0011    | CallTailFunction 1
  0013    | End
  ========================================
  
  ===========toml.simple_value============
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | GetConstant 0: toml.string
  0007    | CallFunction 0
  0009    | Or 9 -> 16
  0012    | GetConstant 1: toml.datetime
  0014    | CallFunction 0
  0016    | Or 16 -> 23
  0019    | GetConstant 2: toml.number
  0021    | CallFunction 0
  0023    | Or 23 -> 30
  0026    | GetConstant 3: toml.boolean
  0028    | CallFunction 0
  0030    | Or 30 -> 39
  0033    | GetConstant 4: toml.array
  0035    | GetConstant 5: toml.simple_value
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042    | GetConstant 6: toml.inline_table
  0044    | GetConstant 7: toml.simple_value
  0046    | CallTailFunction 1
  0048    | End
  ========================================
  
  ===========toml.tagged_value============
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | SetInputMark
  0006    | SetInputMark
  0007    | SetInputMark
  0008    | SetInputMark
  0009    | SetInputMark
  0010    | SetInputMark
  0011    | SetInputMark
  0012    | SetInputMark
  0013    | SetInputMark
  0014    | GetConstant 0: toml.string
  0016    | CallFunction 0
  0018    | Or 18 -> 31
  0021    | GetConstant 1: _toml.tag
  0023    | GetConstant 2: "datetime"
  0025    | GetConstant 3: "offset"
  0027    | GetConstant 4: toml.datetime.offset
  0029    | CallFunction 3
  0031    | Or 31 -> 44
  0034    | GetConstant 5: _toml.tag
  0036    | GetConstant 6: "datetime"
  0038    | GetConstant 7: "local"
  0040    | GetConstant 8: toml.datetime.local
  0042    | CallFunction 3
  0044    | Or 44 -> 57
  0047    | GetConstant 9: _toml.tag
  0049    | GetConstant 10: "datetime"
  0051    | GetConstant 11: "date-local"
  0053    | GetConstant 12: toml.datetime.local_date
  0055    | CallFunction 3
  0057    | Or 57 -> 70
  0060    | GetConstant 13: _toml.tag
  0062    | GetConstant 14: "datetime"
  0064    | GetConstant 15: "time-local"
  0066    | GetConstant 16: toml.datetime.local_time
  0068    | CallFunction 3
  0070    | Or 70 -> 77
  0073    | GetConstant 17: toml.number.binary_integer
  0075    | CallFunction 0
  0077    | Or 77 -> 84
  0080    | GetConstant 18: toml.number.octal_integer
  0082    | CallFunction 0
  0084    | Or 84 -> 91
  0087    | GetConstant 19: toml.number.hex_integer
  0089    | CallFunction 0
  0091    | Or 91 -> 104
  0094    | GetConstant 20: _toml.tag
  0096    | GetConstant 21: "float"
  0098    | GetConstant 22: "infinity"
  0100    | GetConstant 23: toml.number.infinity
  0102    | CallFunction 3
  0104    | Or 104 -> 117
  0107    | GetConstant 24: _toml.tag
  0109    | GetConstant 25: "float"
  0111    | GetConstant 26: "not-a-number"
  0113    | GetConstant 27: toml.number.not_a_number
  0115    | CallFunction 3
  0117    | Or 117 -> 124
  0120    | GetConstant 28: toml.number.float
  0122    | CallFunction 0
  0124    | Or 124 -> 131
  0127    | GetConstant 29: toml.number.integer
  0129    | CallFunction 0
  0131    | Or 131 -> 138
  0134    | GetConstant 30: toml.boolean
  0136    | CallFunction 0
  0138    | Or 138 -> 147
  0141    | GetConstant 31: toml.array
  0143    | GetConstant 32: toml.tagged_value
  0145    | CallFunction 1
  0147    | Or 147 -> 156
  0150    | GetConstant 33: toml.inline_table
  0152    | GetConstant 34: toml.tagged_value
  0154    | CallTailFunction 1
  0156    | End
  ========================================
  
  ===============_toml.tag================
  0000    | GetConstant 0: Value
  0002    | GetBoundLocal 2
  0004    | CallFunction 0
  0006    | GetLocal 3
  0008    | Destructure
  0009    | TakeRight 9 -> 26
  0012    | GetConstant 1: {}
  0014    | GetBoundLocal 0
  0016    | InsertAtKey 2: "type"
  0018    | GetBoundLocal 1
  0020    | InsertAtKey 3: "subtype"
  0022    | GetBoundLocal 3
  0024    | InsertAtKey 4: "value"
  0026    | End
  ========================================
  
  ==============toml.string===============
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | GetConstant 0: toml.string.multi_line_basic
  0005    | CallFunction 0
  0007    | Or 7 -> 14
  0010    | GetConstant 1: toml.string.multi_line_literal
  0012    | CallFunction 0
  0014    | Or 14 -> 21
  0017    | GetConstant 2: toml.string.basic
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 3: toml.string.literal
  0026    | CallFunction 0
  0028    | End
  ========================================
  
  =============toml.datetime==============
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | GetConstant 0: toml.datetime.offset
  0005    | CallFunction 0
  0007    | Or 7 -> 14
  0010    | GetConstant 1: toml.datetime.local
  0012    | CallFunction 0
  0014    | Or 14 -> 21
  0017    | GetConstant 2: toml.datetime.local_date
  0019    | CallFunction 0
  0021    | Or 21 -> 28
  0024    | GetConstant 3: toml.datetime.local_time
  0026    | CallFunction 0
  0028    | End
  ========================================
  
  ==============toml.number===============
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | SetInputMark
  0006    | GetConstant 0: toml.number.binary_integer
  0008    | CallFunction 0
  0010    | Or 10 -> 17
  0013    | GetConstant 1: toml.number.octal_integer
  0015    | CallFunction 0
  0017    | Or 17 -> 24
  0020    | GetConstant 2: toml.number.hex_integer
  0022    | CallFunction 0
  0024    | Or 24 -> 31
  0027    | GetConstant 3: toml.number.infinity
  0029    | CallFunction 0
  0031    | Or 31 -> 38
  0034    | GetConstant 4: toml.number.not_a_number
  0036    | CallFunction 0
  0038    | Or 38 -> 45
  0041    | GetConstant 5: toml.number.float
  0043    | CallFunction 0
  0045    | Or 45 -> 52
  0048    | GetConstant 6: toml.number.integer
  0050    | CallFunction 0
  0052    | End
  ========================================
  
  ==============toml.boolean==============
  0000    | GetConstant 0: boolean
  0002    | GetConstant 1: "true"
  0004    | GetConstant 2: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn941=================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: _toml.ws
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn942=================
  0000    | GetConstant 0: surround
  0002    | GetConstant 1: ","
  0004    | GetConstant 2: _toml.ws
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn940=================
  0000    | GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: array_sep
  0005    | GetConstant 2: @fn941
  0007    | CaptureLocal 0 0
  0010    | GetConstant 3: ","
  0012    | CallFunction 2
  0014    | JumpIfFailure 14 -> 24
  0017    | GetConstant 4: maybe
  0019    | GetConstant 5: @fn942
  0021    | CallFunction 1
  0023    | TakeLeft
  0024    | End
  ========================================
  
  ===============toml.array===============
  0000    | GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 1: _toml.ws
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 25
  0014    | GetConstant 2: default
  0016    | GetConstant 3: @fn940
  0018    | CaptureLocal 0 0
  0021    | GetConstant 4: []
  0023    | CallFunction 2
  0025    | JumpIfFailure 25 -> 33
  0028    | GetConstant 5: _toml.ws
  0030    | CallFunction 0
  0032    | TakeLeft
  0033    | JumpIfFailure 33 -> 41
  0036    | GetConstant 6: "]"
  0038    | CallFunction 0
  0040    | TakeLeft
  0041    | End
  ========================================
  
  ===========toml.inline_table============
  0000    | GetConstant 0: InlineDoc
  0002    | SetInputMark
  0003    | GetConstant 1: _toml.empty_inline_table
  0005    | CallFunction 0
  0007    | Or 7 -> 16
  0010    | GetConstant 2: _toml.nonempty_inline_table
  0012    | GetBoundLocal 0
  0014    | CallFunction 1
  0016    | GetLocal 1
  0018    | Destructure
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 3: _Toml.Doc.Value
  0024    | GetBoundLocal 1
  0026    | CallTailFunction 1
  0028    | End
  ========================================
  
  ========_toml.empty_inline_table========
  0000    | GetConstant 0: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: spaces
  0011    | CallFunction 1
  0013    | JumpIfFailure 13 -> 21
  0016    | GetConstant 3: "}"
  0018    | CallFunction 0
  0020    | TakeLeft
  0021    | TakeRight 21 -> 28
  0024    | GetConstant 4: _Toml.Doc.Empty
  0026    | CallTailFunction 0
  0028    | End
  ========================================
  
  ======_toml.nonempty_inline_table=======
  0000    | GetConstant 0: DocWithFirstPair
  0002    | GetConstant 1: "{"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 15
  0009    | GetConstant 2: maybe
  0011    | GetConstant 3: spaces
  0013    | CallFunction 1
  0015    | TakeRight 15 -> 28
  0018    | GetConstant 4: _toml.inline_table_pair
  0020    | GetBoundLocal 0
  0022    | GetConstant 5: _Toml.Doc.Empty
  0024    | CallFunction 0
  0026    | CallFunction 2
  0028    | GetLocal 1
  0030    | Destructure
  0031    | TakeRight 31 -> 60
  0034    | GetConstant 6: _toml.inline_table_body
  0036    | GetBoundLocal 0
  0038    | GetBoundLocal 1
  0040    | CallFunction 2
  0042    | JumpIfFailure 42 -> 52
  0045    | GetConstant 7: maybe
  0047    | GetConstant 8: spaces
  0049    | CallFunction 1
  0051    | TakeLeft
  0052    | JumpIfFailure 52 -> 60
  0055    | GetConstant 9: "}"
  0057    | CallFunction 0
  0059    | TakeLeft
  0060    | End
  ========================================
  
  ========_toml.inline_table_body=========
  0000    | GetConstant 0: NewDoc
  0002    | SetInputMark
  0003    | GetConstant 1: ","
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 18
  0010    | GetConstant 2: _toml.inline_table_pair
  0012    | GetBoundLocal 0
  0014    | GetBoundLocal 1
  0016    | CallFunction 2
  0018    | GetLocal 2
  0020    | Destructure
  0021    | ConditionalThen 21 -> 35
  0024    | GetConstant 3: _toml.inline_table_body
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 2
  0030    | CallTailFunction 2
  0032    | ConditionalElse 32 -> 41
  0035    | GetConstant 4: const
  0037    | GetBoundLocal 1
  0039    | CallTailFunction 1
  0041    | End
  ========================================
  
  ========_toml.inline_table_pair=========
  0000    | GetConstant 0: Key
  0002    | GetConstant 1: Val
  0004    | GetConstant 2: maybe
  0006    | GetConstant 3: spaces
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 20
  0013    | GetConstant 4: _toml.path
  0015    | CallFunction 0
  0017    | GetLocal 2
  0019    | Destructure
  0020    | TakeRight 20 -> 29
  0023    | GetConstant 5: maybe
  0025    | GetConstant 6: spaces
  0027    | CallFunction 1
  0029    | TakeRight 29 -> 36
  0032    | GetConstant 7: "="
  0034    | CallFunction 0
  0036    | TakeRight 36 -> 45
  0039    | GetConstant 8: maybe
  0041    | GetConstant 9: spaces
  0043    | CallFunction 1
  0045    | TakeRight 45 -> 55
  0048    | GetBoundLocal 0
  0050    | CallFunction 0
  0052    | GetLocal 3
  0054    | Destructure
  0055    | TakeRight 55 -> 77
  0058    | GetConstant 10: maybe
  0060    | GetConstant 11: spaces
  0062    | CallFunction 1
  0064    | TakeRight 64 -> 77
  0067    | GetConstant 12: _Toml.Doc.InsertAtPath
  0069    | GetBoundLocal 1
  0071    | GetBoundLocal 2
  0073    | GetBoundLocal 3
  0075    | CallTailFunction 3
  0077    | End
  ========================================
  
  ======toml.string.multi_line_basic======
  0000    | GetConstant 0: """""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: newline
  0011    | CallFunction 1
  0013    | TakeRight 13 -> 22
  0016    | GetConstant 3: _toml.string.multi_line_basic
  0018    | GetConstant 4: ""
  0020    | CallTailFunction 1
  0022    | End
  ========================================
  
  =================@fn944=================
  0000    | SetInputMark
  0001    | GetConstant 0: _ctrl_char
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "\"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =====_toml.string.multi_line_basic======
  0000    | GetConstant 0: C
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | GetConstant 1: """""""
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 20
  0012    | GetBoundLocal 0
  0014    | JumpIfFailure 14 -> 20
  0017    | GetConstant 2: """"
  0019    | Merge
  0020    | Or 20 -> 38
  0023    | GetConstant 3: """"""
  0025    | CallFunction 0
  0027    | TakeRight 27 -> 38
  0030    | GetBoundLocal 0
  0032    | JumpIfFailure 32 -> 38
  0035    | GetConstant 4: """
  0037    | Merge
  0038    | Or 38 -> 50
  0041    | GetConstant 5: """""
  0043    | CallFunction 0
  0045    | TakeRight 45 -> 50
  0048    | GetBoundLocal 0
  0050    | Or 50 -> 126
  0053    | SetInputMark
  0054    | SetInputMark
  0055    | SetInputMark
  0056    | SetInputMark
  0057    | GetConstant 6: _toml.escaped_ctrl_char
  0059    | CallFunction 0
  0061    | Or 61 -> 68
  0064    | GetConstant 7: _toml.escaped_unicode
  0066    | CallFunction 0
  0068    | Or 68 -> 75
  0071    | GetConstant 8: whitespace
  0073    | CallFunction 0
  0075    | Or 75 -> 97
  0078    | GetConstant 9: "\"
  0080    | CallFunction 0
  0082    | JumpIfFailure 82 -> 90
  0085    | GetConstant 10: whitespace
  0087    | CallFunction 0
  0089    | Merge
  0090    | TakeRight 90 -> 97
  0093    | GetConstant 11: ""
  0095    | CallFunction 0
  0097    | Or 97 -> 108
  0100    | GetConstant 12: unless
  0102    | GetConstant 13: char
  0104    | GetConstant 14: @fn944
  0106    | CallFunction 2
  0108    | GetLocal 1
  0110    | Destructure
  0111    | TakeRight 111 -> 126
  0114    | GetConstant 15: _toml.string.multi_line_basic
  0116    | GetBoundLocal 0
  0118    | JumpIfFailure 118 -> 124
  0121    | GetBoundLocal 1
  0123    | Merge
  0124    | CallTailFunction 1
  0126    | End
  ========================================
  
  =====toml.string.multi_line_literal=====
  0000    | GetConstant 0: "'''"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: maybe
  0009    | GetConstant 2: newline
  0011    | CallFunction 1
  0013    | TakeRight 13 -> 22
  0016    | GetConstant 3: _toml.string.multi_line_literal
  0018    | GetConstant 4: ""
  0020    | CallTailFunction 1
  0022    | End
  ========================================
  
  ====_toml.string.multi_line_literal=====
  0000    | GetConstant 0: C
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | GetConstant 1: "'''''"
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 20
  0012    | GetBoundLocal 0
  0014    | JumpIfFailure 14 -> 20
  0017    | GetConstant 2: "''"
  0019    | Merge
  0020    | Or 20 -> 38
  0023    | GetConstant 3: "''''"
  0025    | CallFunction 0
  0027    | TakeRight 27 -> 38
  0030    | GetBoundLocal 0
  0032    | JumpIfFailure 32 -> 38
  0035    | GetConstant 4: "'"
  0037    | Merge
  0038    | Or 38 -> 50
  0041    | GetConstant 5: "'''"
  0043    | CallFunction 0
  0045    | TakeRight 45 -> 50
  0048    | GetBoundLocal 0
  0050    | Or 50 -> 75
  0053    | GetConstant 6: char
  0055    | CallFunction 0
  0057    | GetLocal 1
  0059    | Destructure
  0060    | TakeRight 60 -> 75
  0063    | GetConstant 7: _toml.string.multi_line_literal
  0065    | GetBoundLocal 0
  0067    | JumpIfFailure 67 -> 73
  0070    | GetBoundLocal 1
  0072    | Merge
  0073    | CallTailFunction 1
  0075    | End
  ========================================
  
  ===========toml.string.basic============
  0000    | GetConstant 0: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 1: _toml.string.basic_body
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetConstant 2: """
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =================@fn946=================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: _ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 13
  0009    | GetConstant 1: "\"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: """
  0018    | CallFunction 0
  0020    | End
  ========================================
  
  =================@fn945=================
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: _toml.escaped_ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 13
  0009    | GetConstant 1: _toml.escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 24
  0016    | GetConstant 2: unless
  0018    | GetConstant 3: char
  0020    | GetConstant 4: @fn946
  0022    | CallTailFunction 2
  0024    | End
  ========================================
  
  ========_toml.string.basic_body=========
  0000    | SetInputMark
  0001    | GetConstant 0: many
  0003    | GetConstant 1: @fn945
  0005    | CallFunction 1
  0007    | Or 7 -> 16
  0010    | GetConstant 2: const
  0012    | GetConstant 3: ""
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  =================@fn947=================
  0000    | GetConstant 0: chars_until
  0002    | GetConstant 1: "'"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========toml.string.literal===========
  0000    | GetConstant 0: "'"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: default
  0009    | GetConstant 2: @fn947
  0011    | GetConstant 3: ""
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 4: "'"
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
  ========================================
  
  ========_toml.escaped_ctrl_char=========
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | SetInputMark
  0006    | GetConstant 0: "\""
  0008    | CallFunction 0
  0010    | TakeRight 10 -> 15
  0013    | GetConstant 1: """
  0015    | Or 15 -> 27
  0018    | GetConstant 2: "\\"
  0020    | CallFunction 0
  0022    | TakeRight 22 -> 27
  0025    | GetConstant 3: "\"
  0027    | Or 27 -> 39
  0030    | GetConstant 4: "\b"
  0032    | CallFunction 0
  0034    | TakeRight 34 -> 39
  0037    | GetConstant 5: "\x08" (esc)
  0039    | Or 39 -> 51
  0042    | GetConstant 6: "\f"
  0044    | CallFunction 0
  0046    | TakeRight 46 -> 51
  0049    | GetConstant 7: "\x0c" (esc)
  0051    | Or 51 -> 63
  0054    | GetConstant 8: "\n"
  0056    | CallFunction 0
  0058    | TakeRight 58 -> 63
  0061    | GetConstant 9: "
  "
  0063    | Or 63 -> 75
  0066    | GetConstant 10: "\r"
  0068    | CallFunction 0
  0070    | TakeRight 70 -> 75
  0073    | GetConstant 11: "\r (no-eol) (esc)
  "
  0075    | Or 75 -> 87
  0078    | GetConstant 12: "\t"
  0080    | CallFunction 0
  0082    | TakeRight 82 -> 87
  0085    | GetConstant 13: "\t" (esc)
  0087    | End
  ========================================
  
  =========_toml.escaped_unicode==========
  0000    | GetConstant 0: U
  0002    | SetInputMark
  0003    | GetConstant 1: "\u"
  0005    | CallFunction 0
  0007    | TakeRight 7 -> 16
  0010    | GetConstant 2: repeat4
  0012    | GetConstant 3: hex_numeral
  0014    | CallFunction 1
  0016    | GetLocal 0
  0018    | Destructure
  0019    | TakeRight 19 -> 28
  0022    | GetConstant 4: @Codepoint
  0024    | GetBoundLocal 0
  0026    | CallTailFunction 1
  0028    | Or 28 -> 56
  0031    | GetConstant 5: "\U"
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 44
  0038    | GetConstant 6: repeat8
  0040    | GetConstant 7: hex_numeral
  0042    | CallFunction 1
  0044    | GetLocal 0
  0046    | Destructure
  0047    | TakeRight 47 -> 56
  0050    | GetConstant 8: @Codepoint
  0052    | GetBoundLocal 0
  0054    | CallTailFunction 1
  0056    | End
  ========================================
  
  ==========toml.datetime.offset==========
  0000    | GetConstant 0: toml.datetime.local_date
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 28
  0007    | SetInputMark
  0008    | SetInputMark
  0009    | GetConstant 1: "T"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: "t"
  0018    | CallFunction 0
  0020    | Or 20 -> 27
  0023    | GetConstant 3: " "
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetConstant 4: _toml.datetime.time_offset
  0033    | CallFunction 0
  0035    | Merge
  0036    | End
  ========================================
  
  ==========toml.datetime.local===========
  0000    | GetConstant 0: toml.datetime.local_date
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 28
  0007    | SetInputMark
  0008    | SetInputMark
  0009    | GetConstant 1: "T"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: "t"
  0018    | CallFunction 0
  0020    | Or 20 -> 27
  0023    | GetConstant 3: " "
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetConstant 4: toml.datetime.local_time
  0033    | CallFunction 0
  0035    | Merge
  0036    | End
  ========================================
  
  ========toml.datetime.local_date========
  0000    | GetConstant 0: _toml.datetime.year
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: "-"
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetConstant 2: _toml.datetime.month
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetConstant 3: "-"
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetConstant 4: _toml.datetime.mday
  0033    | CallFunction 0
  0035    | Merge
  0036    | End
  ========================================
  
  ==========_toml.datetime.year===========
  0000    | GetConstant 0: repeat4
  0002    | GetConstant 1: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_toml.datetime.month==========
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: "0"
  0004    | CallFunction 0
  0006    | JumpIfFailure 6 -> 13
  0009    | ParseRange 1 2: "1" "9"
  0012    | Merge
  0013    | Or 13 -> 20
  0016    | GetConstant 3: "11"
  0018    | CallFunction 0
  0020    | Or 20 -> 27
  0023    | GetConstant 4: "12"
  0025    | CallFunction 0
  0027    | End
  ========================================
  
  ==========_toml.datetime.mday===========
  0000    | SetInputMark
  0001    | SetInputMark
  0002    | ParseRange 0 1: "0" "2"
  0005    | JumpIfFailure 5 -> 12
  0008    | ParseRange 2 3: "1" "9"
  0011    | Merge
  0012    | Or 12 -> 19
  0015    | GetConstant 4: "30"
  0017    | CallFunction 0
  0019    | Or 19 -> 26
  0022    | GetConstant 5: "31"
  0024    | CallFunction 0
  0026    | End
  ========================================
  
  =================@fn948=================
  0000    | GetConstant 0: "."
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 18
  0007    | GetConstant 1: repeat_between
  0009    | GetConstant 2: numeral
  0011    | GetConstant 3: 1
  0013    | GetConstant 4: 9
  0015    | CallFunction 3
  0017    | Merge
  0018    | End
  ========================================
  
  ========toml.datetime.local_time========
  0000    | GetConstant 0: _toml.datetime.hours
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: ":"
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetConstant 2: _toml.datetime.minutes
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetConstant 3: ":"
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetConstant 4: _toml.datetime.seconds
  0033    | CallFunction 0
  0035    | Merge
  0036    | JumpIfFailure 36 -> 46
  0039    | GetConstant 5: maybe
  0041    | GetConstant 6: @fn948
  0043    | CallFunction 1
  0045    | Merge
  0046    | End
  ========================================
  
  =======_toml.datetime.time_offset=======
  0000    | GetConstant 0: toml.datetime.local_time
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 28
  0007    | SetInputMark
  0008    | SetInputMark
  0009    | GetConstant 1: "Z"
  0011    | CallFunction 0
  0013    | Or 13 -> 20
  0016    | GetConstant 2: "z"
  0018    | CallFunction 0
  0020    | Or 20 -> 27
  0023    | GetConstant 3: _toml.datetime.time_numoffset
  0025    | CallFunction 0
  0027    | Merge
  0028    | End
  ========================================
  
  =====_toml.datetime.time_numoffset======
  0000    | SetInputMark
  0001    | GetConstant 0: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "-"
  0010    | CallFunction 0
  0012    | JumpIfFailure 12 -> 20
  0015    | GetConstant 2: _toml.datetime.hours
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetConstant 3: ":"
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetConstant 4: _toml.datetime.minutes
  0033    | CallFunction 0
  0035    | Merge
  0036    | End
  ========================================
  
  ==========_toml.datetime.hours==========
  0000    | SetInputMark
  0001    | ParseRange 0 1: "0" "1"
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseRange 2 3: "0" "9"
  0010    | Merge
  0011    | Or 11 -> 25
  0014    | GetConstant 4: "2"
  0016    | CallFunction 0
  0018    | JumpIfFailure 18 -> 25
  0021    | ParseRange 5 6: "0" "3"
  0024    | Merge
  0025    | End
  ========================================
  
  =========_toml.datetime.minutes=========
  0000    | ParseRange 0 1: "0" "5"
  0003    | JumpIfFailure 3 -> 10
  0006    | ParseRange 2 3: "0" "9"
  0009    | Merge
  0010    | End
  ========================================
  
  =========_toml.datetime.seconds=========
  0000    | SetInputMark
  0001    | ParseRange 0 1: "0" "5"
  0004    | JumpIfFailure 4 -> 11
  0007    | ParseRange 2 3: "0" "9"
  0010    | Merge
  0011    | Or 11 -> 18
  0014    | GetConstant 4: "60"
  0016    | CallFunction 0
  0018    | End
  ========================================
  
  =================@fn949=================
  0000    | GetConstant 0: _toml.number.sign
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _toml.number.integer_part
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  ==========toml.number.integer===========
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn949
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn950=================
  0000    | SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 14
  0008    | GetConstant 1: skip
  0010    | GetConstant 2: "+"
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  ===========_toml.number.sign============
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: @fn950
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn951=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 13
  0009    | GetConstant 2: numeral
  0011    | CallFunction 0
  0013    | End
  ========================================
  
  =======_toml.number.integer_part========
  0000    | SetInputMark
  0001    | ParseRange 0 1: "1" "9"
  0004    | JumpIfFailure 4 -> 14
  0007    | GetConstant 2: many
  0009    | GetConstant 3: @fn951
  0011    | CallFunction 1
  0013    | Merge
  0014    | Or 14 -> 21
  0017    | GetConstant 4: numeral
  0019    | CallFunction 0
  0021    | End
  ========================================
  
  =================@fn952=================
  0000    | GetConstant 0: _toml.number.sign
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _toml.number.integer_part
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 38
  0015    | SetInputMark
  0016    | GetConstant 2: _toml.number.fraction_part
  0018    | CallFunction 0
  0020    | JumpIfFailure 20 -> 30
  0023    | GetConstant 3: maybe
  0025    | GetConstant 4: _toml.number.exponent_part
  0027    | CallFunction 1
  0029    | Merge
  0030    | Or 30 -> 37
  0033    | GetConstant 5: _toml.number.exponent_part
  0035    | CallFunction 0
  0037    | Merge
  0038    | End
  ========================================
  
  ===========toml.number.float============
  0000    | GetConstant 0: @number_of
  0002    | GetConstant 1: @fn952
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn953=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.fraction_part=======
  0000    | GetConstant 0: "."
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 16
  0007    | GetConstant 1: many_sep
  0009    | GetConstant 2: numerals
  0011    | GetConstant 3: @fn953
  0013    | CallFunction 2
  0015    | Merge
  0016    | End
  ========================================
  
  =================@fn954=================
  0000    | SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================@fn955=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =======_toml.number.exponent_part=======
  0000    | SetInputMark
  0001    | GetConstant 0: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "E"
  0010    | CallFunction 0
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 2: maybe
  0017    | GetConstant 3: @fn954
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 34
  0025    | GetConstant 4: many_sep
  0027    | GetConstant 5: numerals
  0029    | GetConstant 6: @fn955
  0031    | CallFunction 2
  0033    | Merge
  0034    | End
  ========================================
  
  =================@fn956=================
  0000    | SetInputMark
  0001    | GetConstant 0: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "-"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==========toml.number.infinity==========
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: @fn956
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: "inf"
  0011    | CallFunction 0
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn957=================
  0000    | SetInputMark
  0001    | GetConstant 0: "+"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "-"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========toml.number.not_a_number========
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: @fn957
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: "nan"
  0011    | CallFunction 0
  0013    | Merge
  0014    | End
  ========================================
  
  =================@fn959=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn960=================
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 2: peek
  0011    | GetConstant 3: binary_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn958=================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: 0
  0004    | GetConstant 2: @fn959
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 3: maybe
  0013    | GetConstant 4: @fn960
  0015    | CallFunction 1
  0017    | Merge
  0018    | End
  ========================================
  
  =================@fn962=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn961=================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: binary_digit
  0004    | GetConstant 2: @fn962
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =======toml.number.binary_integer=======
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: "0b"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 29
  0009    | GetConstant 2: one_or_both
  0011    | GetConstant 3: @fn958
  0013    | GetConstant 4: @fn961
  0015    | CallFunction 2
  0017    | GetLocal 0
  0019    | Destructure
  0020    | TakeRight 20 -> 29
  0023    | GetConstant 5: Num.FromBinaryDigits
  0025    | GetBoundLocal 0
  0027    | CallTailFunction 1
  0029    | End
  ========================================
  
  =================@fn964=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn965=================
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 2: peek
  0011    | GetConstant 3: octal_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn963=================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: 0
  0004    | GetConstant 2: @fn964
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 3: maybe
  0013    | GetConstant 4: @fn965
  0015    | CallFunction 1
  0017    | Merge
  0018    | End
  ========================================
  
  =================@fn967=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn966=================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: octal_digit
  0004    | GetConstant 2: @fn967
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =======toml.number.octal_integer========
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: "0o"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 29
  0009    | GetConstant 2: one_or_both
  0011    | GetConstant 3: @fn963
  0013    | GetConstant 4: @fn966
  0015    | CallFunction 2
  0017    | GetLocal 0
  0019    | Destructure
  0020    | TakeRight 20 -> 29
  0023    | GetConstant 5: Num.FromOctalDigits
  0025    | GetBoundLocal 0
  0027    | CallTailFunction 1
  0029    | End
  ========================================
  
  =================@fn969=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn970=================
  0000    | GetConstant 0: skip
  0002    | GetConstant 1: "_"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 16
  0009    | GetConstant 2: peek
  0011    | GetConstant 3: hex_numeral
  0013    | CallFunction 1
  0015    | TakeLeft
  0016    | End
  ========================================
  
  =================@fn968=================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: 0
  0004    | GetConstant 2: @fn969
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 18
  0011    | GetConstant 3: maybe
  0013    | GetConstant 4: @fn970
  0015    | CallFunction 1
  0017    | Merge
  0018    | End
  ========================================
  
  =================@fn972=================
  0000    | GetConstant 0: maybe
  0002    | GetConstant 1: "_"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn971=================
  0000    | GetConstant 0: array_sep
  0002    | GetConstant 1: hex_digit
  0004    | GetConstant 2: @fn972
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ========toml.number.hex_integer=========
  0000    | GetConstant 0: Digits
  0002    | GetConstant 1: "0x"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 29
  0009    | GetConstant 2: one_or_both
  0011    | GetConstant 3: @fn968
  0013    | GetConstant 4: @fn971
  0015    | CallFunction 2
  0017    | GetLocal 0
  0019    | Destructure
  0020    | TakeRight 20 -> 29
  0023    | GetConstant 5: Num.FromHexDigits
  0025    | GetBoundLocal 0
  0027    | CallTailFunction 1
  0029    | End
  ========================================
  
  ============_Toml.Doc.Empty=============
  0000    | GetConstant 0: {"value": {}, "type": {}}
  0002    | End
  ========================================
  
  ============_Toml.Doc.Value=============
  0000    | GetConstant 0: Obj.Get
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: "value"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Toml.Doc.Type=============
  0000    | GetConstant 0: Obj.Get
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: "type"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Toml.Doc.Has==============
  0000    | GetConstant 0: Obj.Has
  0002    | GetConstant 1: _Toml.Doc.Type
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetBoundLocal 1
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  =============_Toml.Doc.Get==============
  0000    | GetConstant 0: {}
  0002    | GetConstant 2: Obj.Get
  0004    | GetConstant 3: _Toml.Doc.Value
  0006    | GetBoundLocal 0
  0008    | CallFunction 1
  0010    | GetBoundLocal 1
  0012    | CallFunction 2
  0014    | InsertAtKey 1: "value"
  0016    | GetConstant 5: Obj.Get
  0018    | GetConstant 6: _Toml.Doc.Type
  0020    | GetBoundLocal 0
  0022    | CallFunction 1
  0024    | GetBoundLocal 1
  0026    | CallFunction 2
  0028    | InsertAtKey 4: "type"
  0030    | End
  ========================================
  
  ===========_Toml.Doc.IsTable============
  0000    | GetConstant 0: Is.Object
  0002    | GetConstant 1: _Toml.Doc.Type
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ============_Toml.Doc.Insert============
  0000    | GetConstant 0: _Toml.Doc.IsTable
  0002    | GetBoundLocal 0
  0004    | CallFunction 1
  0006    | TakeRight 6 -> 43
  0009    | GetConstant 1: {}
  0011    | GetConstant 3: Obj.Put
  0013    | GetConstant 4: _Toml.Doc.Value
  0015    | GetBoundLocal 0
  0017    | CallFunction 1
  0019    | GetBoundLocal 1
  0021    | GetBoundLocal 2
  0023    | CallFunction 3
  0025    | InsertAtKey 2: "value"
  0027    | GetConstant 6: Obj.Put
  0029    | GetConstant 7: _Toml.Doc.Type
  0031    | GetBoundLocal 0
  0033    | CallFunction 1
  0035    | GetBoundLocal 1
  0037    | GetBoundLocal 3
  0039    | CallFunction 3
  0041    | InsertAtKey 5: "type"
  0043    | End
  ========================================
  
  ====_Toml.Doc.AppendToArrayOfTables=====
  0000    | GetConstant 0: AoT
  0002    | GetConstant 1: _Toml.Doc.Get
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | GetConstant 2: {"value": _, "type": "array_of_tables"}
  0012    | Destructure
  0013    | JumpIfFailure 13 -> 31
  0016    | GetConstant 3: "value"
  0018    | GetAtKey
  0019    | GetLocal 3
  0021    | Destructure
  0022    | JumpIfFailure 22 -> 29
  0025    | Pop
  0026    | JumpIfSuccess 26 -> 31
  0029    | Swap
  0030    | Pop
  0031    | TakeRight 31 -> 62
  0034    | GetConstant 4: _Toml.Doc.Insert
  0036    | GetBoundLocal 0
  0038    | GetBoundLocal 1
  0040    | GetConstant 5: []
  0042    | JumpIfFailure 42 -> 48
  0045    | GetBoundLocal 3
  0047    | Merge
  0048    | JumpIfFailure 48 -> 58
  0051    | GetConstant 6: [_]
  0053    | GetBoundLocal 2
  0055    | InsertAtIndex 0
  0057    | Merge
  0058    | GetConstant 7: "array_of_tables"
  0060    | CallTailFunction 4
  0062    | End
  ========================================
  
  =========_Toml.Doc.InsertAtPath=========
  0000    | GetConstant 0: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetConstant 1: _Toml.Doc.ValueUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  ======_Toml.Doc.EnsureTableAtPath=======
  0000    | GetConstant 0: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: {}
  0008    | GetConstant 2: _Toml.Doc.MissingTableUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =========_Toml.Doc.AppendAtPath=========
  0000    | GetConstant 0: _Toml.Doc.UpdateAtPath
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetConstant 1: _Toml.Doc.AppendUpdater
  0010    | CallTailFunction 4
  0012    | End
  ========================================
  
  =========_Toml.Doc.UpdateAtPath=========
  0000    | GetConstant 0: Key
  0002    | GetConstant 1: PathRest
  0004    | GetConstant 2: InnerDoc
  0006    | SetInputMark
  0007    | GetBoundLocal 1
  0009    | GetConstant 3: [_]
  0011    | Destructure
  0012    | JumpIfFailure 12 -> 29
  0015    | GetAtIndex 0
  0017    | GetLocal 4
  0019    | Destructure
  0020    | JumpIfFailure 20 -> 27
  0023    | Pop
  0024    | JumpIfSuccess 24 -> 29
  0027    | Swap
  0028    | Pop
  0029    | ConditionalThen 29 -> 45
  0032    | GetBoundLocal 3
  0034    | GetBoundLocal 0
  0036    | GetBoundLocal 4
  0038    | GetBoundLocal 2
  0040    | CallTailFunction 3
  0042    | ConditionalElse 42 -> 189
  0045    | SetInputMark
  0046    | GetBoundLocal 1
  0048    | GetConstant 4: [_]
  0050    | GetLocal 5
  0052    | PrepareMergePattern 2
  0054    | JumpIfFailure 54 -> 93
  0057    | GetConstant 5: [_]
  0059    | Destructure
  0060    | JumpIfFailure 60 -> 77
  0063    | GetAtIndex 0
  0065    | GetLocal 4
  0067    | Destructure
  0068    | JumpIfFailure 68 -> 75
  0071    | Pop
  0072    | JumpIfSuccess 72 -> 77
  0075    | Swap
  0076    | Pop
  0077    | JumpIfFailure 77 -> 91
  0080    | Pop
  0081    | GetLocal 5
  0083    | Destructure
  0084    | JumpIfFailure 84 -> 91
  0087    | Pop
  0088    | JumpIfSuccess 88 -> 93
  0091    | Swap
  0092    | Pop
  0093    | ConditionalThen 93 -> 187
  0096    | SetInputMark
  0097    | GetConstant 6: _Toml.Doc.Has
  0099    | GetBoundLocal 0
  0101    | GetBoundLocal 4
  0103    | CallFunction 2
  0105    | ConditionalThen 105 -> 144
  0108    | GetConstant 7: _Toml.Doc.IsTable
  0110    | GetConstant 8: _Toml.Doc.Get
  0112    | GetBoundLocal 0
  0114    | GetBoundLocal 4
  0116    | CallFunction 2
  0118    | CallFunction 1
  0120    | TakeRight 120 -> 141
  0123    | GetConstant 9: _Toml.Doc.UpdateAtPath
  0125    | GetConstant 10: _Toml.Doc.Get
  0127    | GetBoundLocal 0
  0129    | GetBoundLocal 4
  0131    | CallFunction 2
  0133    | GetBoundLocal 5
  0135    | GetBoundLocal 2
  0137    | GetBoundLocal 3
  0139    | CallFunction 4
  0141    | ConditionalElse 141 -> 158
  0144    | GetConstant 11: _Toml.Doc.UpdateAtPath
  0146    | GetConstant 12: _Toml.Doc.Empty
  0148    | CallFunction 0
  0150    | GetBoundLocal 5
  0152    | GetBoundLocal 2
  0154    | GetBoundLocal 3
  0156    | CallFunction 4
  0158    | GetLocal 6
  0160    | Destructure
  0161    | TakeRight 161 -> 184
  0164    | GetConstant 13: _Toml.Doc.Insert
  0166    | GetBoundLocal 0
  0168    | GetBoundLocal 4
  0170    | GetConstant 14: _Toml.Doc.Value
  0172    | GetBoundLocal 6
  0174    | CallFunction 1
  0176    | GetConstant 15: _Toml.Doc.Type
  0178    | GetBoundLocal 6
  0180    | CallFunction 1
  0182    | CallTailFunction 4
  0184    | ConditionalElse 184 -> 189
  0187    | GetBoundLocal 0
  0189    | End
  ========================================
  
  =========_Toml.Doc.ValueUpdater=========
  0000    | SetInputMark
  0001    | GetConstant 0: _Toml.Doc.Has
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | ConditionalThen 9 -> 19
  0012    | GetConstant 1: @Fail
  0014    | CallTailFunction 0
  0016    | ConditionalElse 16 -> 31
  0019    | GetConstant 2: _Toml.Doc.Insert
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 1
  0025    | GetBoundLocal 2
  0027    | GetConstant 3: "value"
  0029    | CallTailFunction 4
  0031    | End
  ========================================
  
  =====_Toml.Doc.MissingTableUpdater======
  0000    | SetInputMark
  0001    | GetConstant 0: _Toml.Doc.IsTable
  0003    | GetConstant 1: _Toml.Doc.Get
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | CallFunction 1
  0013    | ConditionalThen 13 -> 21
  0016    | GetBoundLocal 0
  0018    | ConditionalElse 18 -> 33
  0021    | GetConstant 2: _Toml.Doc.Insert
  0023    | GetBoundLocal 0
  0025    | GetBoundLocal 1
  0027    | GetConstant 3: {}
  0029    | GetConstant 4: {}
  0031    | CallTailFunction 4
  0033    | End
  ========================================
  
  ========_Toml.Doc.AppendUpdater=========
  0000    | GetConstant 0: DocWithKey
  0002    | SetInputMark
  0003    | GetConstant 1: _Toml.Doc.Has
  0005    | GetBoundLocal 0
  0007    | GetBoundLocal 1
  0009    | CallFunction 2
  0011    | ConditionalThen 11 -> 19
  0014    | GetBoundLocal 0
  0016    | ConditionalElse 16 -> 31
  0019    | GetConstant 2: _Toml.Doc.Insert
  0021    | GetBoundLocal 0
  0023    | GetBoundLocal 1
  0025    | GetConstant 3: []
  0027    | GetConstant 4: "array_of_tables"
  0029    | CallFunction 4
  0031    | GetLocal 3
  0033    | Destructure
  0034    | TakeRight 34 -> 47
  0037    | GetConstant 5: _Toml.Doc.AppendToArrayOfTables
  0039    | GetBoundLocal 3
  0041    | GetBoundLocal 1
  0043    | GetBoundLocal 2
  0045    | CallTailFunction 3
  0047    | End
  ========================================
  
  ======ast.with_operator_precedence======
  0000    | GetConstant 0: _ast.with_precedence_start
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetBoundLocal 3
  0010    | GetConstant 1: 0
  0012    | CallTailFunction 5
  0014    | End
  ========================================
  
  =======_ast.with_precedence_start=======
  0000    | GetConstant 0: OpNode
  0002    | GetConstant 1: PrefixBindingPower
  0004    | GetConstant 2: PrefixedNode
  0006    | GetConstant 3: Node
  0008    | SetInputMark
  0009    | GetBoundLocal 1
  0011    | CallFunction 0
  0013    | GetConstant 4: [_, _]
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 42
  0019    | GetAtIndex 0
  0021    | GetLocal 5
  0023    | Destructure
  0024    | JumpIfFailure 24 -> 40
  0027    | Pop
  0028    | GetAtIndex 1
  0030    | GetLocal 6
  0032    | Destructure
  0033    | JumpIfFailure 33 -> 40
  0036    | Pop
  0037    | JumpIfSuccess 37 -> 42
  0040    | Swap
  0041    | Pop
  0042    | ConditionalThen 42 -> 100
  0045    | GetConstant 5: _ast.with_precedence_start
  0047    | GetBoundLocal 0
  0049    | GetBoundLocal 1
  0051    | GetBoundLocal 2
  0053    | GetBoundLocal 3
  0055    | GetBoundLocal 6
  0057    | CallFunction 5
  0059    | GetLocal 7
  0061    | Destructure
  0062    | TakeRight 62 -> 97
  0065    | GetConstant 6: _ast.with_precedence_rest
  0067    | GetBoundLocal 0
  0069    | GetBoundLocal 1
  0071    | GetBoundLocal 2
  0073    | GetBoundLocal 3
  0075    | GetBoundLocal 4
  0077    | GetConstant 7: {}
  0079    | JumpIfFailure 79 -> 85
  0082    | GetBoundLocal 5
  0084    | Merge
  0085    | JumpIfFailure 85 -> 95
  0088    | GetConstant 8: {}
  0090    | GetBoundLocal 7
  0092    | InsertAtKey 9: "prefixed"
  0094    | Merge
  0095    | CallTailFunction 6
  0097    | ConditionalElse 97 -> 126
  0100    | GetBoundLocal 0
  0102    | CallFunction 0
  0104    | GetLocal 8
  0106    | Destructure
  0107    | TakeRight 107 -> 126
  0110    | GetConstant 10: _ast.with_precedence_rest
  0112    | GetBoundLocal 0
  0114    | GetBoundLocal 1
  0116    | GetBoundLocal 2
  0118    | GetBoundLocal 3
  0120    | GetBoundLocal 4
  0122    | GetBoundLocal 8
  0124    | CallTailFunction 6
  0126    | End
  ========================================
  
  =======_ast.with_precedence_rest========
  0000    | GetConstant 0: OpNode
  0002    | GetConstant 1: RightBindingPower
  0004    | GetConstant 2: NextLeftBindingPower
  0006    | GetConstant 3: RightNode
  0008    | SetInputMark
  0009    | GetBoundLocal 3
  0011    | CallFunction 0
  0013    | GetConstant 4: [_, _]
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 42
  0019    | GetAtIndex 0
  0021    | GetLocal 6
  0023    | Destructure
  0024    | JumpIfFailure 24 -> 40
  0027    | Pop
  0028    | GetAtIndex 1
  0030    | GetLocal 7
  0032    | Destructure
  0033    | JumpIfFailure 33 -> 40
  0036    | Pop
  0037    | JumpIfSuccess 37 -> 42
  0040    | Swap
  0041    | Pop
  0042    | TakeRight 42 -> 57
  0045    | GetConstant 5: const
  0047    | GetConstant 6: Is.LessThan
  0049    | GetBoundLocal 4
  0051    | GetBoundLocal 7
  0053    | CallFunction 2
  0055    | CallFunction 1
  0057    | ConditionalThen 57 -> 95
  0060    | GetConstant 7: _ast.with_precedence_rest
  0062    | GetBoundLocal 0
  0064    | GetBoundLocal 1
  0066    | GetBoundLocal 2
  0068    | GetBoundLocal 3
  0070    | GetBoundLocal 4
  0072    | GetConstant 8: {}
  0074    | JumpIfFailure 74 -> 80
  0077    | GetBoundLocal 6
  0079    | Merge
  0080    | JumpIfFailure 80 -> 90
  0083    | GetConstant 9: {}
  0085    | GetBoundLocal 5
  0087    | InsertAtKey 10: "postfixed"
  0089    | Merge
  0090    | CallTailFunction 6
  0092    | ConditionalElse 92 -> 221
  0095    | SetInputMark
  0096    | GetBoundLocal 2
  0098    | CallFunction 0
  0100    | GetConstant 11: [_, _, _]
  0102    | Destructure
  0103    | JumpIfFailure 103 -> 138
  0106    | GetAtIndex 0
  0108    | GetLocal 6
  0110    | Destructure
  0111    | JumpIfFailure 111 -> 136
  0114    | Pop
  0115    | GetAtIndex 1
  0117    | GetLocal 7
  0119    | Destructure
  0120    | JumpIfFailure 120 -> 136
  0123    | Pop
  0124    | GetAtIndex 2
  0126    | GetLocal 8
  0128    | Destructure
  0129    | JumpIfFailure 129 -> 136
  0132    | Pop
  0133    | JumpIfSuccess 133 -> 138
  0136    | Swap
  0137    | Pop
  0138    | TakeRight 138 -> 153
  0141    | GetConstant 12: const
  0143    | GetConstant 13: Is.LessThan
  0145    | GetBoundLocal 4
  0147    | GetBoundLocal 7
  0149    | CallFunction 2
  0151    | CallFunction 1
  0153    | ConditionalThen 153 -> 215
  0156    | GetConstant 14: _ast.with_precedence_start
  0158    | GetBoundLocal 0
  0160    | GetBoundLocal 1
  0162    | GetBoundLocal 2
  0164    | GetBoundLocal 3
  0166    | GetBoundLocal 8
  0168    | CallFunction 5
  0170    | GetLocal 9
  0172    | Destructure
  0173    | TakeRight 173 -> 212
  0176    | GetConstant 15: _ast.with_precedence_rest
  0178    | GetBoundLocal 0
  0180    | GetBoundLocal 1
  0182    | GetBoundLocal 2
  0184    | GetBoundLocal 3
  0186    | GetBoundLocal 4
  0188    | GetConstant 16: {}
  0190    | JumpIfFailure 190 -> 196
  0193    | GetBoundLocal 6
  0195    | Merge
  0196    | JumpIfFailure 196 -> 210
  0199    | GetConstant 17: {}
  0201    | GetBoundLocal 5
  0203    | InsertAtKey 18: "left"
  0205    | GetBoundLocal 9
  0207    | InsertAtKey 19: "right"
  0209    | Merge
  0210    | CallTailFunction 6
  0212    | ConditionalElse 212 -> 221
  0215    | GetConstant 20: const
  0217    | GetBoundLocal 5
  0219    | CallTailFunction 1
  0221    | End
  ========================================
  
  ================ast.node================
  0000    | GetConstant 0: Value
  0002    | GetBoundLocal 1
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 22
  0012    | GetConstant 1: {}
  0014    | GetBoundLocal 0
  0016    | InsertAtKey 2: "type"
  0018    | GetBoundLocal 2
  0020    | InsertAtKey 3: "value"
  0022    | End
  ========================================
  
  ================Num.Inc=================
  0000    | GetConstant 0: @Add
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Dec=================
  0000    | GetConstant 0: @Subtract
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: 1
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================Num.Abs=================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: 0
  0005    | GetConstant 1: _
  0007    | DestructureRange
  0008    | Or 8 -> 14
  0011    | GetBoundLocal 0
  0013    | NegateNumber
  0014    | End
  ========================================
  
  ================Num.Max=================
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetLocal 1
  0005    | GetConstant 0: _
  0007    | DestructureRange
  0008    | ConditionalThen 8 -> 16
  0011    | GetBoundLocal 0
  0013    | ConditionalElse 13 -> 18
  0016    | GetBoundLocal 1
  0018    | End
  ========================================
  
  ==========Num.FromBinaryDigits==========
  0000    | GetConstant 0: Len
  0002    | GetConstant 1: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetLocal 1
  0010    | Destructure
  0011    | TakeRight 11 -> 31
  0014    | GetConstant 2: _Num.FromBinaryDigits
  0016    | GetBoundLocal 0
  0018    | GetBoundLocal 1
  0020    | JumpIfFailure 20 -> 27
  0023    | GetConstant 3: 1
  0025    | NegateNumber
  0026    | Merge
  0027    | GetConstant 4: 0
  0029    | CallTailFunction 3
  0031    | End
  ========================================
  
  =========_Num.FromBinaryDigits==========
  0000    | GetConstant 0: B
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 4
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 3
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 4
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 103
  0055    | GetBoundLocal 3
  0057    | GetConstant 4: 0
  0059    | GetConstant 5: 1
  0061    | DestructureRange
  0062    | TakeRight 62 -> 100
  0065    | GetConstant 6: _Num.FromBinaryDigits
  0067    | GetBoundLocal 4
  0069    | GetBoundLocal 1
  0071    | JumpIfFailure 71 -> 78
  0074    | GetConstant 7: 1
  0076    | NegateNumber
  0077    | Merge
  0078    | GetBoundLocal 2
  0080    | JumpIfFailure 80 -> 98
  0083    | GetConstant 8: @Multiply
  0085    | GetBoundLocal 3
  0087    | GetConstant 9: @Power
  0089    | GetConstant 10: 2
  0091    | GetBoundLocal 1
  0093    | CallFunction 2
  0095    | CallFunction 2
  0097    | Merge
  0098    | CallTailFunction 3
  0100    | ConditionalElse 100 -> 105
  0103    | GetBoundLocal 2
  0105    | End
  ========================================
  
  ==========Num.FromOctalDigits===========
  0000    | GetConstant 0: Len
  0002    | GetConstant 1: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetLocal 1
  0010    | Destructure
  0011    | TakeRight 11 -> 31
  0014    | GetConstant 2: _Num.FromOctalDigits
  0016    | GetBoundLocal 0
  0018    | GetBoundLocal 1
  0020    | JumpIfFailure 20 -> 27
  0023    | GetConstant 3: 1
  0025    | NegateNumber
  0026    | Merge
  0027    | GetConstant 4: 0
  0029    | CallTailFunction 3
  0031    | End
  ========================================
  
  ==========_Num.FromOctalDigits==========
  0000    | GetConstant 0: O
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 4
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 3
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 4
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 103
  0055    | GetBoundLocal 3
  0057    | GetConstant 4: 0
  0059    | GetConstant 5: 7
  0061    | DestructureRange
  0062    | TakeRight 62 -> 100
  0065    | GetConstant 6: _Num.FromOctalDigits
  0067    | GetBoundLocal 4
  0069    | GetBoundLocal 1
  0071    | JumpIfFailure 71 -> 78
  0074    | GetConstant 7: 1
  0076    | NegateNumber
  0077    | Merge
  0078    | GetBoundLocal 2
  0080    | JumpIfFailure 80 -> 98
  0083    | GetConstant 8: @Multiply
  0085    | GetBoundLocal 3
  0087    | GetConstant 9: @Power
  0089    | GetConstant 10: 8
  0091    | GetBoundLocal 1
  0093    | CallFunction 2
  0095    | CallFunction 2
  0097    | Merge
  0098    | CallTailFunction 3
  0100    | ConditionalElse 100 -> 105
  0103    | GetBoundLocal 2
  0105    | End
  ========================================
  
  ===========Num.FromHexDigits============
  0000    | GetConstant 0: Len
  0002    | GetConstant 1: Array.Length
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetLocal 1
  0010    | Destructure
  0011    | TakeRight 11 -> 31
  0014    | GetConstant 2: _Num.FromHexDigits
  0016    | GetBoundLocal 0
  0018    | GetBoundLocal 1
  0020    | JumpIfFailure 20 -> 27
  0023    | GetConstant 3: 1
  0025    | NegateNumber
  0026    | Merge
  0027    | GetConstant 4: 0
  0029    | CallTailFunction 3
  0031    | End
  ========================================
  
  ===========_Num.FromHexDigits===========
  0000    | GetConstant 0: H
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 4
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 3
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 4
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 103
  0055    | GetBoundLocal 3
  0057    | GetConstant 4: 0
  0059    | GetConstant 5: 15
  0061    | DestructureRange
  0062    | TakeRight 62 -> 100
  0065    | GetConstant 6: _Num.FromHexDigits
  0067    | GetBoundLocal 4
  0069    | GetBoundLocal 1
  0071    | JumpIfFailure 71 -> 78
  0074    | GetConstant 7: 1
  0076    | NegateNumber
  0077    | Merge
  0078    | GetBoundLocal 2
  0080    | JumpIfFailure 80 -> 98
  0083    | GetConstant 8: @Multiply
  0085    | GetBoundLocal 3
  0087    | GetConstant 9: @Power
  0089    | GetConstant 10: 16
  0091    | GetBoundLocal 1
  0093    | CallFunction 2
  0095    | CallFunction 2
  0097    | Merge
  0098    | CallTailFunction 3
  0100    | ConditionalElse 100 -> 105
  0103    | GetBoundLocal 2
  0105    | End
  ========================================
  
  ==============Array.First===============
  0000    | GetConstant 0: F
  0002    | GetConstant 1: _
  0004    | GetBoundLocal 0
  0006    | GetConstant 2: [_]
  0008    | GetLocal 2
  0010    | PrepareMergePattern 2
  0012    | JumpIfFailure 12 -> 51
  0015    | GetConstant 3: [_]
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 35
  0021    | GetAtIndex 0
  0023    | GetLocal 1
  0025    | Destructure
  0026    | JumpIfFailure 26 -> 33
  0029    | Pop
  0030    | JumpIfSuccess 30 -> 35
  0033    | Swap
  0034    | Pop
  0035    | JumpIfFailure 35 -> 49
  0038    | Pop
  0039    | GetLocal 2
  0041    | Destructure
  0042    | JumpIfFailure 42 -> 49
  0045    | Pop
  0046    | JumpIfSuccess 46 -> 51
  0049    | Swap
  0050    | Pop
  0051    | TakeRight 51 -> 56
  0054    | GetBoundLocal 1
  0056    | End
  ========================================
  
  ===============Array.Rest===============
  0000    | GetConstant 0: _
  0002    | GetConstant 1: R
  0004    | GetBoundLocal 0
  0006    | GetConstant 2: [_]
  0008    | GetLocal 2
  0010    | PrepareMergePattern 2
  0012    | JumpIfFailure 12 -> 51
  0015    | GetConstant 3: [_]
  0017    | Destructure
  0018    | JumpIfFailure 18 -> 35
  0021    | GetAtIndex 0
  0023    | GetLocal 1
  0025    | Destructure
  0026    | JumpIfFailure 26 -> 33
  0029    | Pop
  0030    | JumpIfSuccess 30 -> 35
  0033    | Swap
  0034    | Pop
  0035    | JumpIfFailure 35 -> 49
  0038    | Pop
  0039    | GetLocal 2
  0041    | Destructure
  0042    | JumpIfFailure 42 -> 49
  0045    | Pop
  0046    | JumpIfSuccess 46 -> 51
  0049    | Swap
  0050    | Pop
  0051    | TakeRight 51 -> 56
  0054    | GetBoundLocal 2
  0056    | End
  ========================================
  
  ==============Array.Length==============
  0000    | GetConstant 0: _Array.Length
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Array.Length==============
  0000    | GetConstant 0: _
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 3
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 2
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 3
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 72
  0055    | GetConstant 4: _Array.Length
  0057    | GetBoundLocal 3
  0059    | GetBoundLocal 1
  0061    | JumpIfFailure 61 -> 67
  0064    | GetConstant 5: 1
  0066    | Merge
  0067    | CallTailFunction 2
  0069    | ConditionalElse 69 -> 74
  0072    | GetBoundLocal 1
  0074    | End
  ========================================
  
  =============Array.Reverse==============
  0000    | GetConstant 0: _Array.Reverse
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =============_Array.Reverse=============
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 3
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 2
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 3
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 76
  0055    | GetConstant 4: _Array.Reverse
  0057    | GetBoundLocal 3
  0059    | GetConstant 5: [_]
  0061    | GetBoundLocal 2
  0063    | InsertAtIndex 0
  0065    | JumpIfFailure 65 -> 71
  0068    | GetBoundLocal 1
  0070    | Merge
  0071    | CallTailFunction 2
  0073    | ConditionalElse 73 -> 78
  0076    | GetBoundLocal 1
  0078    | End
  ========================================
  
  ===============Array.Map================
  0000    | GetConstant 0: _Array.Map
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===============_Array.Map===============
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 4
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 3
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 4
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 88
  0055    | GetConstant 4: _Array.Map
  0057    | GetBoundLocal 4
  0059    | GetBoundLocal 1
  0061    | GetConstant 5: []
  0063    | JumpIfFailure 63 -> 69
  0066    | GetBoundLocal 2
  0068    | Merge
  0069    | JumpIfFailure 69 -> 83
  0072    | GetConstant 6: [_]
  0074    | GetBoundLocal 1
  0076    | GetBoundLocal 3
  0078    | CallFunction 1
  0080    | InsertAtIndex 0
  0082    | Merge
  0083    | CallTailFunction 3
  0085    | ConditionalElse 85 -> 90
  0088    | GetBoundLocal 2
  0090    | End
  ========================================
  
  ==============Array.Filter==============
  0000    | GetConstant 0: _Array.Filter
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_Array.Filter==============
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 4
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 3
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 4
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 99
  0055    | GetConstant 4: _Array.Filter
  0057    | GetBoundLocal 4
  0059    | GetBoundLocal 1
  0061    | SetInputMark
  0062    | GetBoundLocal 1
  0064    | GetBoundLocal 3
  0066    | CallFunction 1
  0068    | ConditionalThen 68 -> 92
  0071    | GetConstant 5: []
  0073    | JumpIfFailure 73 -> 79
  0076    | GetBoundLocal 2
  0078    | Merge
  0079    | JumpIfFailure 79 -> 89
  0082    | GetConstant 6: [_]
  0084    | GetBoundLocal 3
  0086    | InsertAtIndex 0
  0088    | Merge
  0089    | ConditionalElse 89 -> 94
  0092    | GetBoundLocal 2
  0094    | CallTailFunction 3
  0096    | ConditionalElse 96 -> 101
  0099    | GetBoundLocal 2
  0101    | End
  ========================================
  
  ==============Array.Reject==============
  0000    | GetConstant 0: _Array.Reject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_Array.Reject==============
  0000    | GetConstant 0: First
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: [_]
  0009    | GetLocal 4
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 3
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 4
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 99
  0055    | GetConstant 4: _Array.Reject
  0057    | GetBoundLocal 4
  0059    | GetBoundLocal 1
  0061    | SetInputMark
  0062    | GetBoundLocal 1
  0064    | GetBoundLocal 3
  0066    | CallFunction 1
  0068    | ConditionalThen 68 -> 76
  0071    | GetBoundLocal 2
  0073    | ConditionalElse 73 -> 94
  0076    | GetConstant 5: []
  0078    | JumpIfFailure 78 -> 84
  0081    | GetBoundLocal 2
  0083    | Merge
  0084    | JumpIfFailure 84 -> 94
  0087    | GetConstant 6: [_]
  0089    | GetBoundLocal 3
  0091    | InsertAtIndex 0
  0093    | Merge
  0094    | CallTailFunction 3
  0096    | ConditionalElse 96 -> 101
  0099    | GetBoundLocal 2
  0101    | End
  ========================================
  
  ============Array.ZipObject=============
  0000    | GetConstant 0: _Array.ZipObject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: {}
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.ZipObject============
  0000    | GetConstant 0: K
  0002    | GetConstant 1: KsRest
  0004    | GetConstant 2: V
  0006    | GetConstant 3: VsRest
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | GetConstant 4: [_]
  0013    | GetLocal 4
  0015    | PrepareMergePattern 2
  0017    | JumpIfFailure 17 -> 56
  0020    | GetConstant 5: [_]
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 40
  0026    | GetAtIndex 0
  0028    | GetLocal 3
  0030    | Destructure
  0031    | JumpIfFailure 31 -> 38
  0034    | Pop
  0035    | JumpIfSuccess 35 -> 40
  0038    | Swap
  0039    | Pop
  0040    | JumpIfFailure 40 -> 54
  0043    | Pop
  0044    | GetLocal 4
  0046    | Destructure
  0047    | JumpIfFailure 47 -> 54
  0050    | Pop
  0051    | JumpIfSuccess 51 -> 56
  0054    | Swap
  0055    | Pop
  0056    | TakeRight 56 -> 106
  0059    | GetBoundLocal 1
  0061    | GetConstant 6: [_]
  0063    | GetLocal 6
  0065    | PrepareMergePattern 2
  0067    | JumpIfFailure 67 -> 106
  0070    | GetConstant 7: [_]
  0072    | Destructure
  0073    | JumpIfFailure 73 -> 90
  0076    | GetAtIndex 0
  0078    | GetLocal 5
  0080    | Destructure
  0081    | JumpIfFailure 81 -> 88
  0084    | Pop
  0085    | JumpIfSuccess 85 -> 90
  0088    | Swap
  0089    | Pop
  0090    | JumpIfFailure 90 -> 104
  0093    | Pop
  0094    | GetLocal 6
  0096    | Destructure
  0097    | JumpIfFailure 97 -> 104
  0100    | Pop
  0101    | JumpIfSuccess 101 -> 106
  0104    | Swap
  0105    | Pop
  0106    | ConditionalThen 106 -> 139
  0109    | GetConstant 8: _Array.ZipObject
  0111    | GetBoundLocal 4
  0113    | GetBoundLocal 6
  0115    | GetConstant 9: {}
  0117    | JumpIfFailure 117 -> 123
  0120    | GetBoundLocal 2
  0122    | Merge
  0123    | JumpIfFailure 123 -> 134
  0126    | GetConstant 10: {}
  0128    | GetBoundLocal 3
  0130    | GetBoundLocal 5
  0132    | InsertKeyVal
  0133    | Merge
  0134    | CallTailFunction 3
  0136    | ConditionalElse 136 -> 141
  0139    | GetBoundLocal 2
  0141    | End
  ========================================
  
  =============Array.ZipPairs=============
  0000    | GetConstant 0: _Array.ZipPairs
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ============_Array.ZipPairs=============
  0000    | GetConstant 0: First1
  0002    | GetConstant 1: Rest1
  0004    | GetConstant 2: First2
  0006    | GetConstant 3: Rest2
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | GetConstant 4: [_]
  0013    | GetLocal 4
  0015    | PrepareMergePattern 2
  0017    | JumpIfFailure 17 -> 56
  0020    | GetConstant 5: [_]
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 40
  0026    | GetAtIndex 0
  0028    | GetLocal 3
  0030    | Destructure
  0031    | JumpIfFailure 31 -> 38
  0034    | Pop
  0035    | JumpIfSuccess 35 -> 40
  0038    | Swap
  0039    | Pop
  0040    | JumpIfFailure 40 -> 54
  0043    | Pop
  0044    | GetLocal 4
  0046    | Destructure
  0047    | JumpIfFailure 47 -> 54
  0050    | Pop
  0051    | JumpIfSuccess 51 -> 56
  0054    | Swap
  0055    | Pop
  0056    | TakeRight 56 -> 106
  0059    | GetBoundLocal 1
  0061    | GetConstant 6: [_]
  0063    | GetLocal 6
  0065    | PrepareMergePattern 2
  0067    | JumpIfFailure 67 -> 106
  0070    | GetConstant 7: [_]
  0072    | Destructure
  0073    | JumpIfFailure 73 -> 90
  0076    | GetAtIndex 0
  0078    | GetLocal 5
  0080    | Destructure
  0081    | JumpIfFailure 81 -> 88
  0084    | Pop
  0085    | JumpIfSuccess 85 -> 90
  0088    | Swap
  0089    | Pop
  0090    | JumpIfFailure 90 -> 104
  0093    | Pop
  0094    | GetLocal 6
  0096    | Destructure
  0097    | JumpIfFailure 97 -> 104
  0100    | Pop
  0101    | JumpIfSuccess 101 -> 106
  0104    | Swap
  0105    | Pop
  0106    | ConditionalThen 106 -> 146
  0109    | GetConstant 8: _Array.ZipPairs
  0111    | GetBoundLocal 4
  0113    | GetBoundLocal 6
  0115    | GetConstant 9: []
  0117    | JumpIfFailure 117 -> 123
  0120    | GetBoundLocal 2
  0122    | Merge
  0123    | JumpIfFailure 123 -> 141
  0126    | GetConstant 10: [_]
  0128    | GetConstant 11: [_, _]
  0130    | GetBoundLocal 3
  0132    | InsertAtIndex 0
  0134    | GetBoundLocal 5
  0136    | InsertAtIndex 1
  0138    | InsertAtIndex 0
  0140    | Merge
  0141    | CallTailFunction 3
  0143    | ConditionalElse 143 -> 148
  0146    | GetBoundLocal 2
  0148    | End
  ========================================
  
  =============Array.AppendN==============
  0000    | SetInputMark
  0001    | GetConstant 0: _Assert.NonNegativeInteger
  0003    | GetBoundLocal 2
  0005    | CallFunction 1
  0007    | TakeRight 7 -> 15
  0010    | GetBoundLocal 2
  0012    | GetConstant 1: 0
  0014    | Destructure
  0015    | ConditionalThen 15 -> 23
  0018    | GetBoundLocal 0
  0020    | ConditionalElse 20 -> 56
  0023    | GetConstant 2: Array.AppendN
  0025    | GetConstant 3: []
  0027    | JumpIfFailure 27 -> 33
  0030    | GetBoundLocal 0
  0032    | Merge
  0033    | JumpIfFailure 33 -> 43
  0036    | GetConstant 4: [_]
  0038    | GetBoundLocal 1
  0040    | InsertAtIndex 0
  0042    | Merge
  0043    | GetBoundLocal 1
  0045    | GetBoundLocal 2
  0047    | JumpIfFailure 47 -> 54
  0050    | GetConstant 5: 1
  0052    | NegateNumber
  0053    | Merge
  0054    | CallTailFunction 3
  0056    | End
  ========================================
  
  ============Table.Transpose=============
  0000    | GetConstant 0: _Table.Transpose
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_Table.Transpose============
  0000    | GetConstant 0: FirstPerRow
  0002    | GetConstant 1: RestPerRow
  0004    | SetInputMark
  0005    | GetConstant 2: _Table.FirstPerRow
  0007    | GetBoundLocal 0
  0009    | CallFunction 1
  0011    | GetLocal 2
  0013    | Destructure
  0014    | TakeRight 14 -> 26
  0017    | GetConstant 3: _Table.RestPerRow
  0019    | GetBoundLocal 0
  0021    | CallFunction 1
  0023    | GetLocal 3
  0025    | Destructure
  0026    | ConditionalThen 26 -> 56
  0029    | GetConstant 4: _Table.Transpose
  0031    | GetBoundLocal 3
  0033    | GetConstant 5: []
  0035    | JumpIfFailure 35 -> 41
  0038    | GetBoundLocal 1
  0040    | Merge
  0041    | JumpIfFailure 41 -> 51
  0044    | GetConstant 6: [_]
  0046    | GetBoundLocal 2
  0048    | InsertAtIndex 0
  0050    | Merge
  0051    | CallTailFunction 2
  0053    | ConditionalElse 53 -> 58
  0056    | GetBoundLocal 1
  0058    | End
  ========================================
  
  ===========_Table.FirstPerRow===========
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | GetConstant 2: VeryFirst
  0006    | GetConstant 3: _
  0008    | GetBoundLocal 0
  0010    | GetConstant 4: [_]
  0012    | GetLocal 2
  0014    | PrepareMergePattern 2
  0016    | JumpIfFailure 16 -> 55
  0019    | GetConstant 5: [_]
  0021    | Destructure
  0022    | JumpIfFailure 22 -> 39
  0025    | GetAtIndex 0
  0027    | GetLocal 1
  0029    | Destructure
  0030    | JumpIfFailure 30 -> 37
  0033    | Pop
  0034    | JumpIfSuccess 34 -> 39
  0037    | Swap
  0038    | Pop
  0039    | JumpIfFailure 39 -> 53
  0042    | Pop
  0043    | GetLocal 2
  0045    | Destructure
  0046    | JumpIfFailure 46 -> 53
  0049    | Pop
  0050    | JumpIfSuccess 50 -> 55
  0053    | Swap
  0054    | Pop
  0055    | TakeRight 55 -> 105
  0058    | GetBoundLocal 1
  0060    | GetConstant 6: [_]
  0062    | GetLocal 4
  0064    | PrepareMergePattern 2
  0066    | JumpIfFailure 66 -> 105
  0069    | GetConstant 7: [_]
  0071    | Destructure
  0072    | JumpIfFailure 72 -> 89
  0075    | GetAtIndex 0
  0077    | GetLocal 3
  0079    | Destructure
  0080    | JumpIfFailure 80 -> 87
  0083    | Pop
  0084    | JumpIfSuccess 84 -> 89
  0087    | Swap
  0088    | Pop
  0089    | JumpIfFailure 89 -> 103
  0092    | Pop
  0093    | GetLocal 4
  0095    | Destructure
  0096    | JumpIfFailure 96 -> 103
  0099    | Pop
  0100    | JumpIfSuccess 100 -> 105
  0103    | Swap
  0104    | Pop
  0105    | TakeRight 105 -> 120
  0108    | GetConstant 8: __Table.FirstPerRow
  0110    | GetBoundLocal 2
  0112    | GetConstant 9: [_]
  0114    | GetBoundLocal 3
  0116    | InsertAtIndex 0
  0118    | CallTailFunction 2
  0120    | End
  ========================================
  
  ==========__Table.FirstPerRow===========
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | GetConstant 2: First
  0006    | GetConstant 3: _
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | GetConstant 4: [_]
  0013    | GetLocal 3
  0015    | PrepareMergePattern 2
  0017    | JumpIfFailure 17 -> 56
  0020    | GetConstant 5: [_]
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 40
  0026    | GetAtIndex 0
  0028    | GetLocal 2
  0030    | Destructure
  0031    | JumpIfFailure 31 -> 38
  0034    | Pop
  0035    | JumpIfSuccess 35 -> 40
  0038    | Swap
  0039    | Pop
  0040    | JumpIfFailure 40 -> 54
  0043    | Pop
  0044    | GetLocal 3
  0046    | Destructure
  0047    | JumpIfFailure 47 -> 54
  0050    | Pop
  0051    | JumpIfSuccess 51 -> 56
  0054    | Swap
  0055    | Pop
  0056    | TakeRight 56 -> 106
  0059    | GetBoundLocal 2
  0061    | GetConstant 6: [_]
  0063    | GetLocal 5
  0065    | PrepareMergePattern 2
  0067    | JumpIfFailure 67 -> 106
  0070    | GetConstant 7: [_]
  0072    | Destructure
  0073    | JumpIfFailure 73 -> 90
  0076    | GetAtIndex 0
  0078    | GetLocal 4
  0080    | Destructure
  0081    | JumpIfFailure 81 -> 88
  0084    | Pop
  0085    | JumpIfSuccess 85 -> 90
  0088    | Swap
  0089    | Pop
  0090    | JumpIfFailure 90 -> 104
  0093    | Pop
  0094    | GetLocal 5
  0096    | Destructure
  0097    | JumpIfFailure 97 -> 104
  0100    | Pop
  0101    | JumpIfSuccess 101 -> 106
  0104    | Swap
  0105    | Pop
  0106    | ConditionalThen 106 -> 136
  0109    | GetConstant 8: __Table.FirstPerRow
  0111    | GetBoundLocal 3
  0113    | GetConstant 9: []
  0115    | JumpIfFailure 115 -> 121
  0118    | GetBoundLocal 1
  0120    | Merge
  0121    | JumpIfFailure 121 -> 131
  0124    | GetConstant 10: [_]
  0126    | GetBoundLocal 4
  0128    | InsertAtIndex 0
  0130    | Merge
  0131    | CallTailFunction 2
  0133    | ConditionalElse 133 -> 138
  0136    | GetBoundLocal 1
  0138    | End
  ========================================
  
  ===========_Table.RestPerRow============
  0000    | GetConstant 0: __Table.RestPerRow
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===========__Table.RestPerRow===========
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | GetConstant 2: _
  0006    | GetConstant 3: RowRest
  0008    | SetInputMark
  0009    | GetBoundLocal 0
  0011    | GetConstant 4: [_]
  0013    | GetLocal 3
  0015    | PrepareMergePattern 2
  0017    | JumpIfFailure 17 -> 56
  0020    | GetConstant 5: [_]
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 40
  0026    | GetAtIndex 0
  0028    | GetLocal 2
  0030    | Destructure
  0031    | JumpIfFailure 31 -> 38
  0034    | Pop
  0035    | JumpIfSuccess 35 -> 40
  0038    | Swap
  0039    | Pop
  0040    | JumpIfFailure 40 -> 54
  0043    | Pop
  0044    | GetLocal 3
  0046    | Destructure
  0047    | JumpIfFailure 47 -> 54
  0050    | Pop
  0051    | JumpIfSuccess 51 -> 56
  0054    | Swap
  0055    | Pop
  0056    | ConditionalThen 56 -> 160
  0059    | SetInputMark
  0060    | GetBoundLocal 2
  0062    | GetConstant 6: [_]
  0064    | GetLocal 5
  0066    | PrepareMergePattern 2
  0068    | JumpIfFailure 68 -> 107
  0071    | GetConstant 7: [_]
  0073    | Destructure
  0074    | JumpIfFailure 74 -> 91
  0077    | GetAtIndex 0
  0079    | GetLocal 4
  0081    | Destructure
  0082    | JumpIfFailure 82 -> 89
  0085    | Pop
  0086    | JumpIfSuccess 86 -> 91
  0089    | Swap
  0090    | Pop
  0091    | JumpIfFailure 91 -> 105
  0094    | Pop
  0095    | GetLocal 5
  0097    | Destructure
  0098    | JumpIfFailure 98 -> 105
  0101    | Pop
  0102    | JumpIfSuccess 102 -> 107
  0105    | Swap
  0106    | Pop
  0107    | ConditionalThen 107 -> 137
  0110    | GetConstant 8: __Table.RestPerRow
  0112    | GetBoundLocal 3
  0114    | GetConstant 9: []
  0116    | JumpIfFailure 116 -> 122
  0119    | GetBoundLocal 1
  0121    | Merge
  0122    | JumpIfFailure 122 -> 132
  0125    | GetConstant 10: [_]
  0127    | GetBoundLocal 5
  0129    | InsertAtIndex 0
  0131    | Merge
  0132    | CallTailFunction 2
  0134    | ConditionalElse 134 -> 157
  0137    | GetConstant 11: __Table.RestPerRow
  0139    | GetBoundLocal 3
  0141    | GetConstant 12: []
  0143    | JumpIfFailure 143 -> 149
  0146    | GetBoundLocal 1
  0148    | Merge
  0149    | JumpIfFailure 149 -> 155
  0152    | GetConstant 13: [[]]
  0154    | Merge
  0155    | CallTailFunction 2
  0157    | ConditionalElse 157 -> 162
  0160    | GetBoundLocal 1
  0162    | End
  ========================================
  
  =========Table.RotateClockwise==========
  0000    | GetConstant 0: Array.Map
  0002    | GetConstant 1: Table.Transpose
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetConstant 2: Array.Reverse
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ======Table.RotateCounterClockwise======
  0000    | GetConstant 0: Array.Reverse
  0002    | GetConstant 1: Table.Transpose
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | CallTailFunction 1
  0010    | End
  ========================================
  
  ============Table.ZipObjects============
  0000    | GetConstant 0: _Table.ZipObjects
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ===========_Table.ZipObjects============
  0000    | GetConstant 0: Row
  0002    | GetConstant 1: Rest
  0004    | SetInputMark
  0005    | GetBoundLocal 1
  0007    | GetConstant 2: [_]
  0009    | GetLocal 4
  0011    | PrepareMergePattern 2
  0013    | JumpIfFailure 13 -> 52
  0016    | GetConstant 3: [_]
  0018    | Destructure
  0019    | JumpIfFailure 19 -> 36
  0022    | GetAtIndex 0
  0024    | GetLocal 3
  0026    | Destructure
  0027    | JumpIfFailure 27 -> 34
  0030    | Pop
  0031    | JumpIfSuccess 31 -> 36
  0034    | Swap
  0035    | Pop
  0036    | JumpIfFailure 36 -> 50
  0039    | Pop
  0040    | GetLocal 4
  0042    | Destructure
  0043    | JumpIfFailure 43 -> 50
  0046    | Pop
  0047    | JumpIfSuccess 47 -> 52
  0050    | Swap
  0051    | Pop
  0052    | ConditionalThen 52 -> 90
  0055    | GetConstant 4: _Table.ZipObjects
  0057    | GetBoundLocal 0
  0059    | GetBoundLocal 4
  0061    | GetConstant 5: []
  0063    | JumpIfFailure 63 -> 69
  0066    | GetBoundLocal 2
  0068    | Merge
  0069    | JumpIfFailure 69 -> 85
  0072    | GetConstant 6: [_]
  0074    | GetConstant 7: Array.ZipObject
  0076    | GetBoundLocal 0
  0078    | GetBoundLocal 3
  0080    | CallFunction 2
  0082    | InsertAtIndex 0
  0084    | Merge
  0085    | CallTailFunction 3
  0087    | ConditionalElse 87 -> 92
  0090    | GetBoundLocal 2
  0092    | End
  ========================================
  
  ================Obj.Has=================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: {}
  0006    | GetLocal 1
  0008    | GetLocal 2
  0010    | InsertKeyVal
  0011    | GetLocal 2
  0013    | PrepareMergePattern 2
  0015    | JumpIfFailure 15 -> 60
  0018    | GetConstant 2: {}
  0020    | GetLocal 1
  0022    | GetLocal 2
  0024    | InsertKeyVal
  0025    | Destructure
  0026    | JumpIfFailure 26 -> 44
  0029    | GetLocal 1
  0031    | GetAtKey
  0032    | GetLocal 2
  0034    | Destructure
  0035    | JumpIfFailure 35 -> 42
  0038    | Pop
  0039    | JumpIfSuccess 39 -> 44
  0042    | Swap
  0043    | Pop
  0044    | JumpIfFailure 44 -> 58
  0047    | Pop
  0048    | GetLocal 2
  0050    | Destructure
  0051    | JumpIfFailure 51 -> 58
  0054    | Pop
  0055    | JumpIfSuccess 55 -> 60
  0058    | Swap
  0059    | Pop
  0060    | End
  ========================================
  
  ================Obj.Get=================
  0000    | GetConstant 0: V
  0002    | GetConstant 1: _
  0004    | GetBoundLocal 0
  0006    | GetConstant 2: {}
  0008    | GetLocal 1
  0010    | GetLocal 2
  0012    | InsertKeyVal
  0013    | GetLocal 3
  0015    | PrepareMergePattern 2
  0017    | JumpIfFailure 17 -> 62
  0020    | GetConstant 3: {}
  0022    | GetLocal 1
  0024    | GetLocal 2
  0026    | InsertKeyVal
  0027    | Destructure
  0028    | JumpIfFailure 28 -> 46
  0031    | GetLocal 1
  0033    | GetAtKey
  0034    | GetLocal 2
  0036    | Destructure
  0037    | JumpIfFailure 37 -> 44
  0040    | Pop
  0041    | JumpIfSuccess 41 -> 46
  0044    | Swap
  0045    | Pop
  0046    | JumpIfFailure 46 -> 60
  0049    | Pop
  0050    | GetLocal 3
  0052    | Destructure
  0053    | JumpIfFailure 53 -> 60
  0056    | Pop
  0057    | JumpIfSuccess 57 -> 62
  0060    | Swap
  0061    | Pop
  0062    | TakeRight 62 -> 67
  0065    | GetBoundLocal 2
  0067    | End
  ========================================
  
  ================Obj.Put=================
  0000    | GetConstant 0: {}
  0002    | JumpIfFailure 2 -> 8
  0005    | GetBoundLocal 0
  0007    | Merge
  0008    | JumpIfFailure 8 -> 19
  0011    | GetConstant 1: {}
  0013    | GetBoundLocal 1
  0015    | GetBoundLocal 2
  0017    | InsertKeyVal
  0018    | Merge
  0019    | End
  ========================================
  
  =============Ast.Precedence=============
  0000    | GetConstant 0: [_, _]
  0002    | GetBoundLocal 0
  0004    | InsertAtIndex 0
  0006    | GetBoundLocal 1
  0008    | InsertAtIndex 1
  0010    | End
  ========================================
  
  ==========Ast.InfixPrecedence===========
  0000    | GetConstant 0: [_, _, _]
  0002    | GetBoundLocal 0
  0004    | InsertAtIndex 0
  0006    | GetBoundLocal 1
  0008    | InsertAtIndex 1
  0010    | GetBoundLocal 2
  0012    | InsertAtIndex 2
  0014    | End
  ========================================
  
  ===============Is.String================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: ""
  0006    | GetLocal 1
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 2: ""
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetLocal 1
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================
  
  ===============Is.Number================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: 0
  0006    | GetLocal 1
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 2: 0
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetLocal 1
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================
  
  ================Is.Bool=================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | False
  0005    | GetLocal 1
  0007    | PrepareMergePattern 2
  0009    | JumpIfFailure 9 -> 30
  0012    | False
  0013    | Destructure
  0014    | JumpIfFailure 14 -> 28
  0017    | Pop
  0018    | GetLocal 1
  0020    | Destructure
  0021    | JumpIfFailure 21 -> 28
  0024    | Pop
  0025    | JumpIfSuccess 25 -> 30
  0028    | Swap
  0029    | Pop
  0030    | End
  ========================================
  
  ================Is.Null=================
  0000    | GetBoundLocal 0
  0002    | Null
  0003    | Destructure
  0004    | End
  ========================================
  
  ================Is.Array================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | GetLocal 1
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 2: []
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetLocal 1
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================
  
  ===============Is.Object================
  0000    | GetConstant 0: _
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: {}
  0006    | GetLocal 1
  0008    | PrepareMergePattern 2
  0010    | JumpIfFailure 10 -> 32
  0013    | GetConstant 2: {}
  0015    | Destructure
  0016    | JumpIfFailure 16 -> 30
  0019    | Pop
  0020    | GetLocal 1
  0022    | Destructure
  0023    | JumpIfFailure 23 -> 30
  0026    | Pop
  0027    | JumpIfSuccess 27 -> 32
  0030    | Swap
  0031    | Pop
  0032    | End
  ========================================
  
  ================Is.Equal================
  0000    | GetBoundLocal 0
  0002    | GetLocal 1
  0004    | Destructure
  0005    | End
  ========================================
  
  ==============Is.LessThan===============
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetLocal 1
  0005    | Destructure
  0006    | ConditionalThen 6 -> 16
  0009    | GetConstant 0: @Fail
  0011    | CallTailFunction 0
  0013    | ConditionalElse 13 -> 23
  0016    | GetBoundLocal 0
  0018    | GetConstant 1: _
  0020    | GetLocal 1
  0022    | DestructureRange
  0023    | End
  ========================================
  
  ===========Is.LessThanOrEqual===========
  0000    | GetBoundLocal 0
  0002    | GetConstant 0: _
  0004    | GetLocal 1
  0006    | DestructureRange
  0007    | End
  ========================================
  
  =============Is.GreaterThan=============
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetLocal 1
  0005    | Destructure
  0006    | ConditionalThen 6 -> 16
  0009    | GetConstant 0: @Fail
  0011    | CallTailFunction 0
  0013    | ConditionalElse 13 -> 23
  0016    | GetBoundLocal 0
  0018    | GetLocal 1
  0020    | GetConstant 1: _
  0022    | DestructureRange
  0023    | End
  ========================================
  
  =========Is.GreaterThanOrEqual==========
  0000    | GetBoundLocal 0
  0002    | GetLocal 1
  0004    | GetConstant 0: _
  0006    | DestructureRange
  0007    | End
  ========================================
  
  =======_Assert.NonNegativeInteger=======
  0000    | SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: 0
  0005    | GetConstant 1: _
  0007    | DestructureRange
  0008    | Or 8 -> 20
  0011    | GetConstant 2: @Crash
  0013    | GetConstant 3: "Expected a non-negative integer, got "
  0015    | GetBoundLocal 0
  0017    | MergeAsString
  0018    | CallTailFunction 1
  0020    | End
  ========================================

