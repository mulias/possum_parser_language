  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../stdlib.possum -i ''
  
  ==================char==================
  0000    1 ParseCharacter
  0001    | End
  ========================================
  
  =================ascii==================
  0000    3 ParseRange 0 1: "\x00" "\x7f" (esc)
  0003    | End
  ========================================
  
  =================alpha==================
  0000    5 SetInputMark
  0001    | ParseRange 0 1: "a" "z"
  0004    | Or 4 -> 10
  0007    | ParseRange 2 3: "A" "Z"
  0010    | End
  ========================================
  
  =================alphas=================
  0000    7 GetConstant 0: many
  0002    | GetConstant 1: alpha
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================lower==================
  0000    9 ParseRange 0 1: "a" "z"
  0003    | End
  ========================================
  
  =================lowers=================
  0000   11 GetConstant 0: many
  0002    | GetConstant 1: lower
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================upper==================
  0000   13 ParseRange 0 1: "A" "Z"
  0003    | End
  ========================================
  
  =================uppers=================
  0000   15 GetConstant 0: many
  0002    | GetConstant 1: upper
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================numeral=================
  0000   17 ParseRange 0 1: "0" "9"
  0003    | End
  ========================================
  
  ================numerals================
  0000   19 GetConstant 0: many
  0002    | GetConstant 1: numeral
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================alnum==================
  0000   21 SetInputMark
  0001    | GetConstant 0: alpha
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: numeral
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================alnums=================
  0000   23 GetConstant 0: many
  0002    | GetConstant 1: alnum
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================space==================
  0000   26 SetInputMark
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
  0000   28 GetConstant 0: many
  0002    | GetConstant 1: space
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================newline=================
  0000   30 SetInputMark
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
  0000   34 GetConstant 0: many
  0002    | GetConstant 1: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============end_of_input==============
  0000   38 SetInputMark
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
  
  =================@fn474=================
  0000   42 SetInputMark
  0001    | GetConstant 0: space
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: newline
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ===============whitespace===============
  0000   42 GetConstant 0: many
  0002    | GetConstant 1: @fn474
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn475=================
  0000   46 GetConstant 0: unless
  0002    | GetConstant 1: char
  0004    | GetConstant 2: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  0000   46 GetConstant 0: many
  0002    | GetConstant 1: @fn475
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn476=================
  0000   48 SetInputMark
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
  0000   48 GetConstant 0: many
  0002    | GetConstant 1: @fn476
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn477=================
  0000   50 SetInputMark
  0001    | GetConstant 0: newline
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: end_of_input
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==================line==================
  0000   50 GetConstant 0: chars_until
  0002    | GetConstant 1: @fn477
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================digit==================
  0000   52 ParseRange 0 1: 0 9
  0003    | End
  ========================================
  
  ================integer=================
  0000   54 GetConstant 0: @number_of
  0002    | GetConstant 1: _number_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==========non_negative_integer==========
  0000   58 GetConstant 0: @number_of
  0002    | GetConstant 1: _number_non_negative_integer_part
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn478=================
  0000   60 GetConstant 0: "-"
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _number_non_negative_integer_part
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  ============negative_integer============
  0000   60 GetConstant 0: @number_of
  0002    | GetConstant 1: @fn478
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn479=================
  0000   62 GetConstant 0: _number_integer_part
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _number_fraction_part
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  =================float==================
  0000   62 GetConstant 0: @number_of
  0002    | GetConstant 1: @fn479
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn480=================
  0000   64 GetConstant 0: _number_integer_part
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _number_exponent_part
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  ===========scientific_integer===========
  0000   64 GetConstant 0: @number_of
  0002    | GetConstant 1: @fn480
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn481=================
  0000   67 GetConstant 0: _number_integer_part
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007   68 GetConstant 1: _number_fraction_part
  0009    | CallFunction 0
  0011   67 Merge
  0012   68 JumpIfFailure 12 -> 20
  0015   69 GetConstant 2: _number_exponent_part
  0017    | CallFunction 0
  0019   68 Merge
  0020    | End
  ========================================
  
  ============scientific_float============
  0000   66 GetConstant 0: @number_of
  0002   68 GetConstant 1: @fn481
  0004   66 CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn482=================
  0000   73 GetConstant 0: _number_integer_part
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 14
  0007   74 GetConstant 1: maybe
  0009    | GetConstant 2: _number_fraction_part
  0011    | CallFunction 1
  0013   73 Merge
  0014   74 JumpIfFailure 14 -> 24
  0017   75 GetConstant 3: maybe
  0019    | GetConstant 4: _number_exponent_part
  0021    | CallFunction 1
  0023   74 Merge
  0024    | End
  ========================================
  
  =================number=================
  0000   72 GetConstant 0: @number_of
  0002   74 GetConstant 1: @fn482
  0004   72 CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn483=================
  0000   81 GetConstant 0: _number_non_negative_integer_part
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 14
  0007   82 GetConstant 1: maybe
  0009    | GetConstant 2: _number_fraction_part
  0011    | CallFunction 1
  0013   81 Merge
  0014   82 JumpIfFailure 14 -> 24
  0017   83 GetConstant 3: maybe
  0019    | GetConstant 4: _number_exponent_part
  0021    | CallFunction 1
  0023   82 Merge
  0024    | End
  ========================================
  
  ==========non_negative_number===========
  0000   80 GetConstant 0: @number_of
  0002   82 GetConstant 1: @fn483
  0004   80 CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn484=================
  0000   87 GetConstant 0: "-"
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007   88 GetConstant 1: _number_non_negative_integer_part
  0009    | CallFunction 0
  0011   87 Merge
  0012   88 JumpIfFailure 12 -> 22
  0015   89 GetConstant 2: maybe
  0017    | GetConstant 3: _number_fraction_part
  0019    | CallFunction 1
  0021   88 Merge
  0022   89 JumpIfFailure 22 -> 32
  0025   90 GetConstant 4: maybe
  0027    | GetConstant 5: _number_exponent_part
  0029    | CallFunction 1
  0031   89 Merge
  0032    | End
  ========================================
  
  ============negative_number=============
  0000   86 GetConstant 0: @number_of
  0002   89 GetConstant 1: @fn484
  0004   86 CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_number_integer_part==========
  0000   93 GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _number_non_negative_integer_part
  0011    | CallFunction 0
  0013    | Merge
  0014    | End
  ========================================
  
  ===_number_non_negative_integer_part====
  0000   95 SetInputMark
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
  0000   97 GetConstant 0: "."
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: numerals
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  =================@fn485=================
  0000   99 SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_number_exponent_part==========
  0000   99 SetInputMark
  0001    | GetConstant 0: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "E"
  0010    | CallFunction 0
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 2: maybe
  0017    | GetConstant 3: @fn485
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 30
  0025    | GetConstant 4: numerals
  0027    | CallFunction 0
  0029    | Merge
  0030    | End
  ========================================
  
  ==================true==================
  0000  101 GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | True
  0008    | End
  ========================================
  
  =================false==================
  0000  103 GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | False
  0008    | End
  ========================================
  
  ================boolean=================
  0000  105 SetInputMark
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
  0000  109 GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | Null
  0008    | End
  ========================================
  
  ==================peek==================
  0000  111 GetConstant 0: V
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
  0000  113 SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 0: succeed
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================unless=================
  0000  115 SetInputMark
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
  0000  117 GetConstant 0: null
  0002    | GetBoundLocal 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================scan==================
  0000  119 SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 21
  0008    | GetConstant 0: char
  0010    | CallFunction 0
  0012    | TakeRight 12 -> 21
  0015    | GetConstant 1: scan
  0017    | GetBoundLocal 0
  0019    | CallTailFunction 1
  0021    | End
  ========================================
  
  =================@fn486=================
  0000  121 GetConstant 0: p
  0002    | SetClosureCaptures
  0003    | GetConstant 1: scan
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ================find_all================
  0000  121 GetConstant 0: array
  0002    | GetConstant 1: @fn486
  0004    | CaptureLocal 0 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =================@fn487=================
  0000  123 GetConstant 0: p
  0002    | SetClosureCaptures
  0003    | GetConstant 1: scan
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  =============maybe_find_all=============
  0000  123 GetConstant 0: maybe_array
  0002    | GetConstant 1: @fn487
  0004    | CaptureLocal 0 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ================succeed=================
  0000  125 GetConstant 0: const
  0002    | Null
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ================default=================
  0000  127 SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 14
  0008    | GetConstant 0: const
  0010    | GetBoundLocal 1
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  =================const==================
  0000  129 GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 9
  0007    | GetBoundLocal 0
  0009    | End
  ========================================
  
  ===============string_of================
  0000  133 GetConstant 0: ""
  0002    | CallFunction 0
  0004    1 GetBoundLocal 0
  0006    | CallFunction 0
  0008  133 MergeAsString
  0009    | End
  ========================================
  
  ================surround================
  0000  135 GetBoundLocal 1
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
  
  =================@fn488=================
  0000  137 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  0000  137 GetConstant 0: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: @fn488
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 16
  0011    | GetConstant 2: end_of_input
  0013    | CallFunction 0
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ==================many==================
  0000  139 GetConstant 0: First
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
  0000  141 GetConstant 0: Next
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
  
  =================@fn489=================
  0000  143 GetConstant 0: sep
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
  0000  143 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 26
  0012    | GetConstant 1: _many
  0014    | GetConstant 2: @fn489
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetBoundLocal 2
  0024    | CallTailFunction 2
  0026    | End
  ========================================
  
  ===============many_until===============
  0000  145 GetConstant 0: First
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
  0000  150 GetConstant 0: Next
  0002  148 SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012  149 GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 47
  0021  150 GetBoundLocal 0
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
  0047  148 End
  ========================================
  
  ==============chars_until===============
  0000  152 GetConstant 0: many_until
  0002    | GetConstant 1: char
  0004    | GetBoundLocal 0
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============maybe_many===============
  0000  154 SetInputMark
  0001    | GetConstant 0: many
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 14
  0010    | GetConstant 1: succeed
  0012    | CallFunction 0
  0014    | End
  ========================================
  
  =============maybe_many_sep=============
  0000  156 SetInputMark
  0001    | GetConstant 0: many_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | Or 9 -> 16
  0012    | GetConstant 1: succeed
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================repeat=================
  0000  159 GetConstant 0: const
  0002    | GetConstant 1: AssertNonNegativeInteger
  0004    | GetBoundLocal 1
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 22
  0013  160 GetConstant 2: _repeat
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | Null
  0020    | CallTailFunction 3
  0022  159 End
  ========================================
  
  ================_repeat=================
  0000  165 GetConstant 0: Next
  0002  163 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 1
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017  164 GetConstant 4: const
  0019    | GetBoundLocal 2
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 56
  0026  165 GetBoundLocal 0
  0028    | CallFunction 0
  0030    | GetLocal 3
  0032    | Destructure
  0033    | TakeRight 33 -> 56
  0036    | GetConstant 5: _repeat
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 1
  0042    | GetConstant 6: 1
  0044    | NegateNumber
  0045    | Merge
  0046    | GetBoundLocal 2
  0048    | JumpIfFailure 48 -> 54
  0051    | GetBoundLocal 3
  0053    | Merge
  0054    | CallTailFunction 3
  0056  163 End
  ========================================
  
  =============repeat_between=============
  0000  168 GetConstant 0: const
  0002    | GetConstant 1: AssertNonNegativeInteger
  0004    | GetBoundLocal 1
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 23
  0013  169 GetConstant 2: const
  0015    | GetConstant 3: AssertNonNegativeInteger
  0017    | GetBoundLocal 2
  0019    | CallFunction 1
  0021    | CallFunction 1
  0023    | TakeRight 23 -> 37
  0026  170 GetConstant 4: _repeat_between
  0028    | GetBoundLocal 0
  0030    | GetBoundLocal 1
  0032    | GetBoundLocal 2
  0034    | Null
  0035    | CallTailFunction 4
  0037  169 End
  ========================================
  
  ============_repeat_between=============
  0000  175 GetConstant 0: Next
  0002  173 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 2
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017  174 GetConstant 4: const
  0019    | GetBoundLocal 3
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 94
  0026  175 SetInputMark
  0027    | GetBoundLocal 0
  0029    | CallFunction 0
  0031    | GetLocal 4
  0033    | Destructure
  0034    | ConditionalThen 34 -> 66
  0037  176 GetConstant 5: _repeat_between
  0039    | GetBoundLocal 0
  0041    | GetBoundLocal 1
  0043    | GetConstant 6: 1
  0045    | NegateNumber
  0046    | Merge
  0047    | GetBoundLocal 2
  0049    | GetConstant 7: 1
  0051    | NegateNumber
  0052    | Merge
  0053    | GetBoundLocal 3
  0055    | JumpIfFailure 55 -> 61
  0058    | GetBoundLocal 4
  0060    | Merge
  0061    | CallTailFunction 4
  0063    | ConditionalElse 63 -> 94
  0066  177 SetInputMark
  0067    | GetConstant 8: const
  0069    | GetBoundLocal 1
  0071    | GetConstant 9: _
  0073    | GetConstant 10: 0
  0075    | DestructureRange
  0076    | CallFunction 1
  0078    | ConditionalThen 78 -> 90
  0081  178 GetConstant 11: const
  0083    | GetBoundLocal 3
  0085    | CallTailFunction 1
  0087    | ConditionalElse 87 -> 94
  0090  179 GetConstant 12: @fail
  0092    | CallFunction 0
  0094  173 End
  ========================================
  
  =================array==================
  0000  181 GetConstant 0: First
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
  0000  184 GetConstant 0: Elem
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | GetLocal 2
  0009    | Destructure
  0010    | ConditionalThen 10 -> 40
  0013  185 GetConstant 1: _array
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
  0040  186 GetConstant 4: const
  0042    | GetBoundLocal 1
  0044    | CallTailFunction 1
  0046  184 End
  ========================================
  
  =================@fn490=================
  0000  188 GetConstant 0: sep
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
  0000  188 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 30
  0012    | GetConstant 1: _array
  0014    | GetConstant 2: @fn490
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetConstant 3: [_]
  0024    | GetBoundLocal 2
  0026    | InsertAtIndex 0
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ==============array_until===============
  0000  191 GetConstant 0: First
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
  0000  196 GetConstant 0: Elem
  0002  194 SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012  195 GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 57
  0021  196 GetBoundLocal 0
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
  0057  194 End
  ========================================
  
  =================@fn491=================
  0000  198 GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: array
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  0000  198 GetConstant 0: default
  0002    | GetConstant 1: @fn491
  0004    | CaptureLocal 0 0
  0007    | GetConstant 2: []
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn492=================
  0000  200 GetConstant 0: elem
  0002    | GetConstant 1: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 2: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  0000  200 GetConstant 0: default
  0002    | GetConstant 1: @fn492
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: []
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================tuple1=================
  0000  202 GetConstant 0: Elem
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
  0000  204 GetConstant 0: E1
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
  0000  206 GetConstant 0: E1
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
  0000  209 GetConstant 0: E1
  0002  210 GetConstant 1: E2
  0004  211 GetConstant 2: E3
  0006  209 GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 3
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016  210 GetBoundLocal 1
  0018    | CallFunction 0
  0020    | GetLocal 4
  0022    | Destructure
  0023    | TakeRight 23 -> 50
  0026  211 GetBoundLocal 2
  0028    | CallFunction 0
  0030    | GetLocal 5
  0032    | Destructure
  0033    | TakeRight 33 -> 50
  0036  212 GetConstant 3: [_, _, _]
  0038    | GetBoundLocal 3
  0040    | InsertAtIndex 0
  0042    | GetBoundLocal 4
  0044    | InsertAtIndex 1
  0046    | GetBoundLocal 5
  0048    | InsertAtIndex 2
  0050  210 End
  ========================================
  
  ===============tuple3_sep===============
  0000  215 GetConstant 0: E1
  0002  216 GetConstant 1: E2
  0004  217 GetConstant 2: E3
  0006  215 GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 5
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 1
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023  216 GetBoundLocal 2
  0025    | CallFunction 0
  0027    | GetLocal 6
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 3
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 64
  0040  217 GetBoundLocal 4
  0042    | CallFunction 0
  0044    | GetLocal 7
  0046    | Destructure
  0047    | TakeRight 47 -> 64
  0050  218 GetConstant 3: [_, _, _]
  0052    | GetBoundLocal 5
  0054    | InsertAtIndex 0
  0056    | GetBoundLocal 6
  0058    | InsertAtIndex 1
  0060    | GetBoundLocal 7
  0062    | InsertAtIndex 2
  0064  216 End
  ========================================
  
  =================tuple==================
  0000  221 GetConstant 0: const
  0002    | GetConstant 1: AssertNonNegativeInteger
  0004    | GetBoundLocal 1
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 23
  0013  222 GetConstant 2: _tuple
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetConstant 3: []
  0021    | CallTailFunction 3
  0023  221 End
  ========================================
  
  =================_tuple=================
  0000  227 GetConstant 0: Elem
  0002  225 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 1
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017  226 GetConstant 4: const
  0019    | GetBoundLocal 2
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 66
  0026  227 GetBoundLocal 0
  0028    | CallFunction 0
  0030    | GetLocal 3
  0032    | Destructure
  0033    | TakeRight 33 -> 66
  0036    | GetConstant 5: _tuple
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 1
  0042    | GetConstant 6: 1
  0044    | NegateNumber
  0045    | Merge
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
  0066  225 End
  ========================================
  
  ===============tuple_sep================
  0000  230 GetConstant 0: const
  0002    | GetConstant 1: AssertNonNegativeInteger
  0004    | GetBoundLocal 2
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 25
  0013  231 GetConstant 2: _tuple_sep
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetBoundLocal 2
  0021    | GetConstant 3: []
  0023    | CallTailFunction 4
  0025  230 End
  ========================================
  
  ===============_tuple_sep===============
  0000  236 GetConstant 0: Elem
  0002  234 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 2
  0007    | GetConstant 2: _
  0009    | GetConstant 3: 0
  0011    | DestructureRange
  0012    | CallFunction 1
  0014    | ConditionalThen 14 -> 26
  0017  235 GetConstant 4: const
  0019    | GetBoundLocal 3
  0021    | CallTailFunction 1
  0023    | ConditionalElse 23 -> 75
  0026  236 GetBoundLocal 1
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
  0049    | GetBoundLocal 2
  0051    | GetConstant 6: 1
  0053    | NegateNumber
  0054    | Merge
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
  0075  234 End
  ========================================
  
  ===============table_sep================
  0000  239 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 3
  0008    | Destructure
  0009    | TakeRight 9 -> 30
  0012    | GetConstant 1: _table_sep
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
  
  ===============_table_sep===============
  0000  242 GetConstant 0: Elem
  0002  244 GetConstant 1: NextRow
  0004  242 SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | GetLocal 5
  0018    | Destructure
  0019    | ConditionalThen 19 -> 55
  0022  243 GetConstant 2: _table_sep
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
  0055  244 SetInputMark
  0056    | GetBoundLocal 2
  0058    | CallFunction 0
  0060    | TakeRight 60 -> 67
  0063    | GetBoundLocal 0
  0065    | CallFunction 0
  0067    | GetLocal 6
  0069    | Destructure
  0070    | ConditionalThen 70 -> 110
  0073  245 GetConstant 5: _table_sep
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
  0110  246 GetConstant 9: const
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
  0132  242 End
  ========================================
  
  =================@fn493=================
  0000  249 GetConstant 0: elem
  0002    | GetConstant 1: sep
  0004    | GetConstant 2: row_sep
  0006    | SetClosureCaptures
  0007    | GetConstant 3: table_sep
  0009    | GetBoundLocal 0
  0011    | GetBoundLocal 1
  0013    | GetBoundLocal 2
  0015    | CallTailFunction 3
  0017    | End
  ========================================
  
  ============maybe_table_sep=============
  0000  249 GetConstant 0: default
  0002    | GetConstant 1: @fn493
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | GetConstant 2: [[]]
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  =================object=================
  0000  252 GetConstant 0: K
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
  0024  253 GetConstant 2: _object
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | GetConstant 3: {}
  0032    | GetBoundLocal 2
  0034    | GetBoundLocal 3
  0036    | InsertKeyVal
  0037    | CallTailFunction 3
  0039  252 End
  ========================================
  
  ================_object=================
  0000  256 GetConstant 0: K
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
  0022    | ConditionalThen 22 -> 49
  0025  257 GetConstant 2: _object
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 1
  0031    | GetBoundLocal 2
  0033    | JumpIfFailure 33 -> 44
  0036    | GetConstant 3: {}
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 4
  0042    | InsertKeyVal
  0043    | Merge
  0044    | CallTailFunction 3
  0046    | ConditionalElse 46 -> 55
  0049  258 GetConstant 4: const
  0051    | GetBoundLocal 2
  0053    | CallTailFunction 1
  0055  256 End
  ========================================
  
  =================@fn494=================
  0000  262 GetConstant 0: sep
  0002    | GetConstant 1: key
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn495=================
  0000  262 GetConstant 0: pair_sep
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
  0000  261 GetConstant 0: K
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
  0031  262 GetConstant 2: _object
  0033    | GetConstant 3: @fn494
  0035    | CaptureLocal 0 1
  0038    | CaptureLocal 3 0
  0041    | GetConstant 4: @fn495
  0043    | CaptureLocal 1 0
  0046    | CaptureLocal 2 1
  0049    | GetConstant 5: {}
  0051    | GetBoundLocal 4
  0053    | GetBoundLocal 5
  0055    | InsertKeyVal
  0056    | CallTailFunction 3
  0058  261 End
  ========================================
  
  ==============object_until==============
  0000  265 GetConstant 0: K
  0002  266 GetConstant 1: V
  0004  265 GetConstant 2: unless
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 2
  0010    | CallFunction 2
  0012    | GetLocal 3
  0014    | Destructure
  0015    | TakeRight 15 -> 25
  0018  266 GetBoundLocal 1
  0020    | CallFunction 0
  0022    | GetLocal 4
  0024    | Destructure
  0025    | TakeRight 25 -> 45
  0028  267 GetConstant 3: _object_until
  0030    | GetBoundLocal 0
  0032    | GetBoundLocal 1
  0034    | GetBoundLocal 2
  0036    | GetConstant 4: {}
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 4
  0042    | InsertKeyVal
  0043    | CallTailFunction 4
  0045  266 End
  ========================================
  
  =============_object_until==============
  0000  272 GetConstant 0: K
  0002    | GetConstant 1: V
  0004  270 SetInputMark
  0005    | GetConstant 2: peek
  0007    | GetBoundLocal 2
  0009    | CallFunction 1
  0011    | ConditionalThen 11 -> 23
  0014  271 GetConstant 3: const
  0016    | GetBoundLocal 3
  0018    | CallTailFunction 1
  0020    | ConditionalElse 20 -> 66
  0023  272 GetBoundLocal 0
  0025    | CallFunction 0
  0027    | GetLocal 4
  0029    | Destructure
  0030    | TakeRight 30 -> 40
  0033    | GetBoundLocal 1
  0035    | CallFunction 0
  0037    | GetLocal 5
  0039    | Destructure
  0040    | TakeRight 40 -> 66
  0043    | GetConstant 4: _object_until
  0045    | GetBoundLocal 0
  0047    | GetBoundLocal 1
  0049    | GetBoundLocal 2
  0051    | GetBoundLocal 3
  0053    | JumpIfFailure 53 -> 64
  0056    | GetConstant 5: {}
  0058    | GetBoundLocal 4
  0060    | GetBoundLocal 5
  0062    | InsertKeyVal
  0063    | Merge
  0064    | CallTailFunction 4
  0066  270 End
  ========================================
  
  =================@fn496=================
  0000  274 GetConstant 0: key
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetConstant 2: object
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  0000  274 GetConstant 0: default
  0002    | GetConstant 1: @fn496
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: {}
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================@fn497=================
  0000  277 GetConstant 0: key
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
  0000  277 GetConstant 0: default
  0002    | GetConstant 1: @fn497
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | CaptureLocal 3 3
  0016    | GetConstant 2: {}
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ==================pair==================
  0000  279 GetConstant 0: K
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
  0000  281 GetConstant 0: K
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
  0000  283 GetConstant 0: Value
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
  0000  286 GetConstant 0: V1
  0002  287 GetConstant 1: V2
  0004  286 GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 4
  0010    | Destructure
  0011    | TakeRight 11 -> 36
  0014  287 GetBoundLocal 3
  0016    | CallFunction 0
  0018    | GetLocal 5
  0020    | Destructure
  0021    | TakeRight 21 -> 36
  0024  288 GetConstant 2: {}
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 4
  0030    | InsertKeyVal
  0031    | GetBoundLocal 2
  0033    | GetBoundLocal 5
  0035    | InsertKeyVal
  0036  286 End
  ========================================
  
  ==============record2_sep===============
  0000  291 GetConstant 0: V1
  0002  292 GetConstant 1: V2
  0004  291 GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 5
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 2
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 43
  0021  292 GetBoundLocal 4
  0023    | CallFunction 0
  0025    | GetLocal 6
  0027    | Destructure
  0028    | TakeRight 28 -> 43
  0031  293 GetConstant 2: {}
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 5
  0037    | InsertKeyVal
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 6
  0042    | InsertKeyVal
  0043  291 End
  ========================================
  
  ================record3=================
  0000  296 GetConstant 0: V1
  0002  297 GetConstant 1: V2
  0004  298 GetConstant 2: V3
  0006  296 GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 6
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016  297 GetBoundLocal 3
  0018    | CallFunction 0
  0020    | GetLocal 7
  0022    | Destructure
  0023    | TakeRight 23 -> 53
  0026  298 GetBoundLocal 5
  0028    | CallFunction 0
  0030    | GetLocal 8
  0032    | Destructure
  0033    | TakeRight 33 -> 53
  0036  299 GetConstant 3: {}
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 6
  0042    | InsertKeyVal
  0043    | GetBoundLocal 2
  0045    | GetBoundLocal 7
  0047    | InsertKeyVal
  0048    | GetBoundLocal 4
  0050    | GetBoundLocal 8
  0052    | InsertKeyVal
  0053  297 End
  ========================================
  
  ==============record3_sep===============
  0000  302 GetConstant 0: V1
  0002  303 GetConstant 1: V2
  0004  304 GetConstant 2: V3
  0006  302 GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 8
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 2
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023  303 GetBoundLocal 4
  0025    | CallFunction 0
  0027    | GetLocal 9
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 5
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 67
  0040  304 GetBoundLocal 7
  0042    | CallFunction 0
  0044    | GetLocal 10
  0046    | Destructure
  0047    | TakeRight 47 -> 67
  0050  305 GetConstant 3: {}
  0052    | GetBoundLocal 0
  0054    | GetBoundLocal 8
  0056    | InsertKeyVal
  0057    | GetBoundLocal 3
  0059    | GetBoundLocal 9
  0061    | InsertKeyVal
  0062    | GetBoundLocal 6
  0064    | GetBoundLocal 10
  0066    | InsertKeyVal
  0067  303 End
  ========================================
  
  ==================json==================
  0000  312 SetInputMark
  0001  311 SetInputMark
  0002  310 SetInputMark
  0003  309 SetInputMark
  0004  308 SetInputMark
  0005    | GetConstant 0: json_boolean
  0007    | CallFunction 0
  0009    | Or 9 -> 16
  0012  309 GetConstant 1: json_null
  0014    | CallFunction 0
  0016    | Or 16 -> 23
  0019  310 GetConstant 2: number
  0021    | CallFunction 0
  0023    | Or 23 -> 30
  0026  311 GetConstant 3: json_string
  0028    | CallFunction 0
  0030    | Or 30 -> 39
  0033  312 GetConstant 4: json_array
  0035    | GetConstant 5: json
  0037    | CallFunction 1
  0039    | Or 39 -> 48
  0042  313 GetConstant 6: json_object
  0044    | GetConstant 7: json
  0046    | CallTailFunction 1
  0048  312 End
  ========================================
  
  ==============json_boolean==============
  0000  315 GetConstant 0: boolean
  0002    | GetConstant 1: "true"
  0004    | GetConstant 2: "false"
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============json_null================
  0000  317 GetConstant 0: null
  0002    | GetConstant 1: "null"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============json_string===============
  0000  321 GetConstant 0: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 11
  0007    | GetConstant 1: _json_string_body
  0009    | CallFunction 0
  0011    | JumpIfFailure 11 -> 19
  0014    | GetConstant 2: """
  0016    | CallFunction 0
  0018    | TakeLeft
  0019    | End
  ========================================
  
  =================@fn499=================
  0000  327 SetInputMark
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
  
  =================@fn498=================
  0000  326 SetInputMark
  0001  325 SetInputMark
  0002    | GetConstant 0: _escaped_ctrl_char
  0004    | CallFunction 0
  0006    | Or 6 -> 13
  0009  326 GetConstant 1: _escaped_unicode
  0011    | CallFunction 0
  0013    | Or 13 -> 24
  0016  327 GetConstant 2: unless
  0018    | GetConstant 3: char
  0020    | GetConstant 4: @fn499
  0022    | CallTailFunction 2
  0024  326 End
  ========================================
  
  ===========_json_string_body============
  0000  328 SetInputMark
  0001  324 GetConstant 0: many
  0003  326 GetConstant 1: @fn498
  0005  324 CallFunction 1
  0007  328 Or 7 -> 16
  0010    | GetConstant 2: const
  0012    | GetConstant 3: ""
  0014    | CallTailFunction 1
  0016    | End
  ========================================
  
  ===============_ctrl_char===============
  0000  330 ParseRange 0 1: "\x00" "\x1f" (esc)
  0003    | End
  ========================================
  
  ===========_escaped_ctrl_char===========
  0000  339 SetInputMark
  0001  338 SetInputMark
  0002  337 SetInputMark
  0003  336 SetInputMark
  0004  335 SetInputMark
  0005  334 SetInputMark
  0006  333 SetInputMark
  0007    | GetConstant 0: "\""
  0009    | CallFunction 0
  0011    | TakeRight 11 -> 16
  0014    | GetConstant 1: """
  0016    | Or 16 -> 28
  0019  334 GetConstant 2: "\\"
  0021    | CallFunction 0
  0023    | TakeRight 23 -> 28
  0026    | GetConstant 3: "\"
  0028    | Or 28 -> 40
  0031  335 GetConstant 4: "\/"
  0033    | CallFunction 0
  0035    | TakeRight 35 -> 40
  0038    | GetConstant 5: "/"
  0040    | Or 40 -> 52
  0043  336 GetConstant 6: "\b"
  0045    | CallFunction 0
  0047    | TakeRight 47 -> 52
  0050    | GetConstant 7: "\x08" (esc)
  0052    | Or 52 -> 64
  0055  337 GetConstant 8: "\f"
  0057    | CallFunction 0
  0059    | TakeRight 59 -> 64
  0062    | GetConstant 9: "\x0c" (esc)
  0064    | Or 64 -> 76
  0067  338 GetConstant 10: "\n"
  0069    | CallFunction 0
  0071    | TakeRight 71 -> 76
  0074    | GetConstant 11: "
  "
  0076    | Or 76 -> 88
  0079  339 GetConstant 12: "\r"
  0081    | CallFunction 0
  0083    | TakeRight 83 -> 88
  0086    | GetConstant 13: "\r (no-eol) (esc)
  "
  0088    | Or 88 -> 100
  0091  340 GetConstant 14: "\t"
  0093    | CallFunction 0
  0095    | TakeRight 95 -> 100
  0098    | GetConstant 15: "\t" (esc)
  0100  339 End
  ========================================
  
  ============_escaped_unicode============
  0000  342 SetInputMark
  0001    | GetConstant 0: _escaped_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _escaped_codepoint
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ========_escaped_surrogate_pair=========
  0000  344 SetInputMark
  0001    | GetConstant 0: _valid_surrogate_pair
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: _invalid_surrogate_pair
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_valid_surrogate_pair==========
  0000  347 GetConstant 0: H
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
  0000  349 SetInputMark
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
  0000  352 GetConstant 0: "\u"
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
  0070    | GetConstant 9: _hex
  0072    | CallFunction 0
  0074    | Merge
  0075    | JumpIfFailure 75 -> 83
  0078    | GetConstant 10: _hex
  0080    | CallFunction 0
  0082    | Merge
  0083    | End
  ========================================
  
  =============_low_surrogate=============
  0000  354 GetConstant 0: "\u"
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
  0036    | GetConstant 7: _hex
  0038    | CallFunction 0
  0040    | Merge
  0041    | JumpIfFailure 41 -> 49
  0044    | GetConstant 8: _hex
  0046    | CallFunction 0
  0048    | Merge
  0049    | End
  ========================================
  
  ===========_escaped_codepoint===========
  0000  356 GetConstant 0: U
  0002    | GetConstant 1: "\u"
  0004    | CallFunction 0
  0006    | TakeRight 6 -> 17
  0009    | GetConstant 2: repeat
  0011    | GetConstant 3: _hex
  0013    | GetConstant 4: 4
  0015    | CallFunction 2
  0017    | GetLocal 0
  0019    | Destructure
  0020    | TakeRight 20 -> 29
  0023    | GetConstant 5: @Codepoint
  0025    | GetBoundLocal 0
  0027    | CallTailFunction 1
  0029    | End
  ========================================
  
  ==================_hex==================
  0000  358 SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: numeral
  0004    | CallFunction 0
  0006    | Or 6 -> 12
  0009    | ParseRange 1 2: "a" "f"
  0012    | Or 12 -> 18
  0015    | ParseRange 3 4: "A" "F"
  0018    | End
  ========================================
  
  =================@fn501=================
  0000  360 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn500=================
  0000  360 GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: @fn501
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ===============json_array===============
  0000  360 GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 18
  0007    | GetConstant 1: maybe_array_sep
  0009    | GetConstant 2: @fn500
  0011    | CaptureLocal 0 0
  0014    | GetConstant 3: ","
  0016    | CallFunction 2
  0018    | JumpIfFailure 18 -> 26
  0021    | GetConstant 4: "]"
  0023    | CallFunction 0
  0025    | TakeLeft
  0026    | End
  ========================================
  
  =================@fn503=================
  0000  365 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn502=================
  0000  365 GetConstant 0: surround
  0002    | GetConstant 1: json_string
  0004    | GetConstant 2: @fn503
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn505=================
  0000  366 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn504=================
  0000  366 GetConstant 0: value
  0002    | SetClosureCaptures
  0003    | GetConstant 1: surround
  0005    | GetBoundLocal 0
  0007    | GetConstant 2: @fn505
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  ==============json_object===============
  0000  363 GetConstant 0: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 22
  0007  364 GetConstant 1: maybe_object_sep
  0009  365 GetConstant 2: @fn502
  0011    | GetConstant 3: ":"
  0013  366 GetConstant 4: @fn504
  0015    | CaptureLocal 0 0
  0018    | GetConstant 5: ","
  0020  364 CallFunction 4
  0022  368 JumpIfFailure 22 -> 30
  0025    | GetConstant 6: "}"
  0027    | CallFunction 0
  0029    | TakeLeft
  0030    | End
  ========================================
  
  ======ast_with_operator_precedence======
  0000  371 GetConstant 0: _ast_with_precedence_start
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetBoundLocal 2
  0008    | GetBoundLocal 3
  0010    | GetConstant 1: 0
  0012    | CallTailFunction 5
  0014    | End
  ========================================
  
  =======_ast_with_precedence_start=======
  0000  374 GetConstant 0: OpNode
  0002    | GetConstant 1: PrefixBindingPower
  0004  375 GetConstant 2: PrefixedNode
  0006  382 GetConstant 3: Node
  0008  374 SetInputMark
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
  0042    | ConditionalThen 42 -> 94
  0045  375 GetConstant 5: _ast_with_precedence_start
  0047    | GetBoundLocal 0
  0049    | GetBoundLocal 1
  0051    | GetBoundLocal 2
  0053    | GetBoundLocal 3
  0055    | GetBoundLocal 6
  0057    | CallFunction 5
  0059    | GetLocal 7
  0061    | Destructure
  0062    | TakeRight 62 -> 91
  0065  376 GetConstant 6: _ast_with_precedence_rest
  0067  377 GetBoundLocal 0
  0069    | GetBoundLocal 1
  0071    | GetBoundLocal 2
  0073    | GetBoundLocal 3
  0075  378 GetBoundLocal 4
  0077  379 GetBoundLocal 5
  0079    | JumpIfFailure 79 -> 89
  0082    | GetConstant 7: {}
  0084    | GetBoundLocal 7
  0086    | InsertAtKey 8: "prefixed"
  0088    | Merge
  0089  376 CallTailFunction 6
  0091  381 ConditionalElse 91 -> 120
  0094  382 GetBoundLocal 0
  0096    | CallFunction 0
  0098    | GetLocal 8
  0100    | Destructure
  0101    | TakeRight 101 -> 120
  0104  383 GetConstant 9: _ast_with_precedence_rest
  0106    | GetBoundLocal 0
  0108    | GetBoundLocal 1
  0110    | GetBoundLocal 2
  0112    | GetBoundLocal 3
  0114    | GetBoundLocal 4
  0116    | GetBoundLocal 8
  0118    | CallTailFunction 6
  0120  374 End
  ========================================
  
  =======_ast_with_precedence_rest========
  0000  387 GetConstant 0: OpNode
  0002    | GetConstant 1: RightBindingPower
  0004  395 GetConstant 2: NextLeftBindingPower
  0006  397 GetConstant 3: RightNode
  0008  388 SetInputMark
  0009  387 GetBoundLocal 3
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
  0045  388 GetConstant 5: const
  0047    | GetConstant 6: LessThan
  0049    | GetBoundLocal 4
  0051    | GetBoundLocal 7
  0053    | CallFunction 2
  0055    | CallFunction 1
  0057    | ConditionalThen 57 -> 89
  0060  389 GetConstant 7: _ast_with_precedence_rest
  0062  390 GetBoundLocal 0
  0064    | GetBoundLocal 1
  0066    | GetBoundLocal 2
  0068    | GetBoundLocal 3
  0070  391 GetBoundLocal 4
  0072  392 GetBoundLocal 6
  0074    | JumpIfFailure 74 -> 84
  0077    | GetConstant 8: {}
  0079    | GetBoundLocal 5
  0081    | InsertAtKey 9: "postfixed"
  0083    | Merge
  0084  389 CallTailFunction 6
  0086  394 ConditionalElse 86 -> 209
  0089  396 SetInputMark
  0090  395 GetBoundLocal 2
  0092    | CallFunction 0
  0094    | GetConstant 10: [_, _, _]
  0096    | Destructure
  0097    | JumpIfFailure 97 -> 132
  0100    | GetAtIndex 0
  0102    | GetLocal 6
  0104    | Destructure
  0105    | JumpIfFailure 105 -> 130
  0108    | Pop
  0109    | GetAtIndex 1
  0111    | GetLocal 7
  0113    | Destructure
  0114    | JumpIfFailure 114 -> 130
  0117    | Pop
  0118    | GetAtIndex 2
  0120    | GetLocal 8
  0122    | Destructure
  0123    | JumpIfFailure 123 -> 130
  0126    | Pop
  0127    | JumpIfSuccess 127 -> 132
  0130    | Swap
  0131    | Pop
  0132    | TakeRight 132 -> 147
  0135  396 GetConstant 11: const
  0137    | GetConstant 12: LessThan
  0139    | GetBoundLocal 4
  0141    | GetBoundLocal 7
  0143    | CallFunction 2
  0145    | CallFunction 1
  0147    | ConditionalThen 147 -> 203
  0150  397 GetConstant 13: _ast_with_precedence_start
  0152    | GetBoundLocal 0
  0154    | GetBoundLocal 1
  0156    | GetBoundLocal 2
  0158    | GetBoundLocal 3
  0160    | GetBoundLocal 8
  0162    | CallFunction 5
  0164    | GetLocal 9
  0166    | Destructure
  0167    | TakeRight 167 -> 200
  0170  398 GetConstant 14: _ast_with_precedence_rest
  0172  399 GetBoundLocal 0
  0174    | GetBoundLocal 1
  0176    | GetBoundLocal 2
  0178    | GetBoundLocal 3
  0180  400 GetBoundLocal 4
  0182  401 GetBoundLocal 6
  0184    | JumpIfFailure 184 -> 198
  0187    | GetConstant 15: {}
  0189    | GetBoundLocal 5
  0191    | InsertAtKey 16: "left"
  0193    | GetBoundLocal 9
  0195    | InsertAtKey 17: "right"
  0197    | Merge
  0198  398 CallTailFunction 6
  0200  403 ConditionalElse 200 -> 209
  0203  404 GetConstant 18: const
  0205    | GetBoundLocal 5
  0207    | CallTailFunction 1
  0209  388 End
  ========================================
  
  ===========ast_op_precedence============
  0000  407 GetConstant 0: OpNode
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 22
  0012    | GetConstant 1: [_, _]
  0014    | GetBoundLocal 2
  0016    | InsertAtIndex 0
  0018    | GetBoundLocal 1
  0020    | InsertAtIndex 1
  0022    | End
  ========================================
  
  ========ast_infix_op_precedence=========
  0000  410 GetConstant 0: OpNode
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 3
  0008    | Destructure
  0009    | TakeRight 9 -> 26
  0012    | GetConstant 1: [_, _, _]
  0014    | GetBoundLocal 3
  0016    | InsertAtIndex 0
  0018    | GetBoundLocal 1
  0020    | InsertAtIndex 1
  0022    | GetBoundLocal 2
  0024    | InsertAtIndex 2
  0026    | End
  ========================================
  
  ================ast_node================
  0000  412 GetConstant 0: Value
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
  
  =============ZipIntoObject==============
  0000  414 GetConstant 0: _ZipIntoObject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: {}
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_ZipIntoObject=============
  0000  417 GetConstant 0: K
  0002    | GetConstant 1: KeysRest
  0004    | GetConstant 2: V
  0006    | GetConstant 3: ValuesRest
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
  0106    | ConditionalThen 106 -> 133
  0109  418 GetConstant 8: _ZipIntoObject
  0111    | GetBoundLocal 4
  0113    | GetBoundLocal 6
  0115    | GetBoundLocal 2
  0117    | JumpIfFailure 117 -> 128
  0120    | GetConstant 9: {}
  0122    | GetBoundLocal 3
  0124    | GetBoundLocal 5
  0126    | InsertKeyVal
  0127    | Merge
  0128    | CallTailFunction 3
  0130    | ConditionalElse 130 -> 135
  0133  419 GetBoundLocal 2
  0135  417 End
  ========================================
  
  ==================Map===================
  0000  421 GetConstant 0: _Map
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==================_Map==================
  0000  424 GetConstant 0: First
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
  0055  425 GetConstant 4: _Map
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
  0088  426 GetBoundLocal 2
  0090  424 End
  ========================================
  
  ===============ArrayFirst===============
  0000  428 GetConstant 0: F
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
  
  ===============ArrayRest================
  0000  430 GetConstant 0: _
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
  
  =============TransposeTable=============
  0000  432 GetConstant 0: _TransposeTable
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_TransposeTable=============
  0000  435 GetConstant 0: FirstPerRow
  0002  436 GetConstant 1: RestPerRow
  0004    | SetInputMark
  0005  435 GetConstant 2: Map
  0007    | GetBoundLocal 0
  0009    | GetConstant 3: ArrayFirst
  0011    | CallFunction 2
  0013    | GetLocal 2
  0015    | Destructure
  0016    | TakeRight 16 -> 30
  0019  436 GetConstant 4: Map
  0021    | GetBoundLocal 0
  0023    | GetConstant 5: ArrayRest
  0025    | CallFunction 2
  0027    | GetLocal 3
  0029    | Destructure
  0030    | ConditionalThen 30 -> 60
  0033  437 GetConstant 6: _TransposeTable
  0035    | GetBoundLocal 3
  0037    | GetConstant 7: []
  0039    | JumpIfFailure 39 -> 45
  0042    | GetBoundLocal 1
  0044    | Merge
  0045    | JumpIfFailure 45 -> 55
  0048    | GetConstant 8: [_]
  0050    | GetBoundLocal 2
  0052    | InsertAtIndex 0
  0054    | Merge
  0055    | CallTailFunction 2
  0057    | ConditionalElse 57 -> 62
  0060  438 GetBoundLocal 1
  0062  436 End
  ========================================
  
  ==========RotateTableClockwise==========
  0000  440 GetConstant 0: Map
  0002    | GetConstant 1: TransposeTable
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetConstant 2: Reverse
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ================Reverse=================
  0000  442 GetConstant 0: _Reverse
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================_Reverse================
  0000  445 GetConstant 0: First
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
  0055  446 GetConstant 4: _Reverse
  0057    | GetBoundLocal 3
  0059    | GetConstant 5: [_]
  0061    | GetBoundLocal 2
  0063    | InsertAtIndex 0
  0065    | JumpIfFailure 65 -> 71
  0068    | GetBoundLocal 1
  0070    | Merge
  0071    | CallTailFunction 2
  0073    | ConditionalElse 73 -> 78
  0076  447 GetBoundLocal 1
  0078  445 End
  ========================================
  
  =================Reject=================
  0000  449 GetConstant 0: _Reject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ================_Reject=================
  0000  452 GetConstant 0: First
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
  0055  453 GetConstant 4: _Reject
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
  0099  454 GetBoundLocal 2
  0101  452 End
  ========================================
  
  =================IsNull=================
  0000  456 GetBoundLocal 0
  0002    | Null
  0003    | Destructure
  0004    | End
  ========================================
  
  ================Tabular=================
  0000  458 GetConstant 0: _Tabular
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ================_Tabular================
  0000  461 GetConstant 0: Row
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
  0055  462 GetConstant 4: _Tabular
  0057    | GetBoundLocal 0
  0059    | GetBoundLocal 4
  0061    | GetConstant 5: []
  0063    | JumpIfFailure 63 -> 69
  0066    | GetBoundLocal 2
  0068    | Merge
  0069    | JumpIfFailure 69 -> 85
  0072    | GetConstant 6: [_]
  0074    | GetConstant 7: ZipIntoObject
  0076    | GetBoundLocal 0
  0078    | GetBoundLocal 3
  0080    | CallFunction 2
  0082    | InsertAtIndex 0
  0084    | Merge
  0085    | CallTailFunction 3
  0087    | ConditionalElse 87 -> 92
  0090  463 GetBoundLocal 2
  0092  461 End
  ========================================
  
  ========AssertNonNegativeInteger========
  0000  466 SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: 0
  0005    | GetConstant 1: _
  0007    | DestructureRange
  0008    | Or 8 -> 20
  0011    | GetConstant 2: @Crash
  0013    | GetConstant 3: "Expected a non-negative integer, got "
  0015    1 GetBoundLocal 0
  0017  466 MergeAsString
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  ================LessThan================
  0000  468 SetInputMark
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
  
  ==============GreaterThan===============
  0000  470 SetInputMark
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

