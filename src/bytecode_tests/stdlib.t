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
  
  =================@fn397=================
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
  0002    | GetConstant 1: @fn397
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn398=================
  0000   46 GetConstant 0: unless
  0002    | GetConstant 1: char
  0004    | GetConstant 2: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  0000   46 GetConstant 0: many
  0002    | GetConstant 1: @fn398
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn399=================
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
  0002    | GetConstant 1: @fn399
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn400=================
  0000   50 SetInputMark
  0001    | GetConstant 0: newline
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: end_of_input
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  ==================line==================
  0000   50 GetConstant 0: many_until
  0002    | GetConstant 1: char
  0004    | GetConstant 2: @fn400
  0006    | CallTailFunction 2
  0008    | End
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
  
  =================@fn401=================
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
  0002    | GetConstant 1: @fn401
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn402=================
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
  0002    | GetConstant 1: @fn402
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn403=================
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
  0002    | GetConstant 1: @fn403
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn404=================
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
  0002   68 GetConstant 1: @fn404
  0004   66 CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn405=================
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
  0002   74 GetConstant 1: @fn405
  0004   72 CallTailFunction 1
  0006    | End
  ========================================
  
  ==========_number_integer_part==========
  0000   80 GetConstant 0: maybe
  0002    | GetConstant 1: "-"
  0004    | CallFunction 1
  0006    | JumpIfFailure 6 -> 14
  0009    | GetConstant 2: _number_non_negative_integer_part
  0011    | CallFunction 0
  0013    | Merge
  0014    | End
  ========================================
  
  ===_number_non_negative_integer_part====
  0000   82 SetInputMark
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
  0000   84 GetConstant 0: "."
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: numerals
  0009    | CallFunction 0
  0011    | Merge
  0012    | End
  ========================================
  
  =================@fn406=================
  0000   86 SetInputMark
  0001    | GetConstant 0: "-"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "+"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =========_number_exponent_part==========
  0000   86 SetInputMark
  0001    | GetConstant 0: "e"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "E"
  0010    | CallFunction 0
  0012    | JumpIfFailure 12 -> 22
  0015    | GetConstant 2: maybe
  0017    | GetConstant 3: @fn406
  0019    | CallFunction 1
  0021    | Merge
  0022    | JumpIfFailure 22 -> 30
  0025    | GetConstant 4: numerals
  0027    | CallFunction 0
  0029    | Merge
  0030    | End
  ========================================
  
  ==================true==================
  0000   88 GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | True
  0008    | End
  ========================================
  
  =================false==================
  0000   90 GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | False
  0008    | End
  ========================================
  
  ================boolean=================
  0000   92 SetInputMark
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
  0000   96 GetBoundLocal 0
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 8
  0007    | Null
  0008    | End
  ========================================
  
  ==================peek==================
  0000   98 GetConstant 0: V
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
  0000  100 SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 0: succeed
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================unless=================
  0000  102 SetInputMark
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
  0000  104 GetConstant 0: null
  0002    | GetBoundLocal 0
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==================scan==================
  0000  106 SetInputMark
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
  
  ================succeed=================
  0000  108 GetConstant 0: const
  0002    | Null
  0003    | CallTailFunction 1
  0005    | End
  ========================================
  
  ================default=================
  0000  110 SetInputMark
  0001    | GetBoundLocal 0
  0003    | CallFunction 0
  0005    | Or 5 -> 14
  0008    | GetConstant 0: const
  0010    | GetBoundLocal 1
  0012    | CallTailFunction 1
  0014    | End
  ========================================
  
  =================const==================
  0000  112 GetConstant 0: ""
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 9
  0007    | GetBoundLocal 0
  0009    | End
  ========================================
  
  ===============string_of================
  0000  116 GetConstant 0: ""
  0002    | CallFunction 0
  0004    1 GetBoundLocal 0
  0006    | CallFunction 0
  0008  116 MergeAsString
  0009    | End
  ========================================
  
  ================surround================
  0000  118 GetBoundLocal 1
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
  
  =================@fn407=================
  0000  120 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  0000  120 GetConstant 0: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: @fn407
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 16
  0011    | GetConstant 2: end_of_input
  0013    | CallFunction 0
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ==================many==================
  0000  122 GetConstant 0: First
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
  0000  124 GetConstant 0: Next
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
  
  =================@fn408=================
  0000  126 GetConstant 0: sep
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
  0000  126 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 26
  0012    | GetConstant 1: _many
  0014    | GetConstant 2: @fn408
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetBoundLocal 2
  0024    | CallTailFunction 2
  0026    | End
  ========================================
  
  ===============many_until===============
  0000  128 GetConstant 0: First
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
  0000  133 GetConstant 0: Next
  0002  131 SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012  132 GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 47
  0021  133 GetBoundLocal 0
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
  0047  131 End
  ========================================
  
  ===============maybe_many===============
  0000  135 SetInputMark
  0001    | GetConstant 0: many
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 14
  0010    | GetConstant 1: succeed
  0012    | CallFunction 0
  0014    | End
  ========================================
  
  =============maybe_many_sep=============
  0000  137 SetInputMark
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
  0000  141 GetConstant 0: First
  0002  140 GetConstant 1: const
  0004    | GetConstant 2: AssertPositiveInteger
  0006    | GetBoundLocal 1
  0008    | CallFunction 1
  0010    | CallFunction 1
  0012    | TakeRight 12 -> 22
  0015  141 GetBoundLocal 0
  0017    | CallFunction 0
  0019    | GetLocal 2
  0021    | Destructure
  0022    | TakeRight 22 -> 39
  0025  142 GetConstant 3: _repeat
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 1
  0031    | GetConstant 4: 1
  0033    | NegateNumber
  0034    | Merge
  0035    | GetBoundLocal 2
  0037    | CallTailFunction 3
  0039  141 End
  ========================================
  
  ================_repeat=================
  0000  147 GetConstant 0: Next
  0002  145 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 1
  0007    | GetConstant 2: 0
  0009    | Destructure
  0010    | CallFunction 1
  0012    | ConditionalThen 12 -> 24
  0015  146 GetConstant 3: const
  0017    | GetBoundLocal 2
  0019    | CallTailFunction 1
  0021    | ConditionalElse 21 -> 54
  0024  147 GetBoundLocal 0
  0026    | CallFunction 0
  0028    | GetLocal 3
  0030    | Destructure
  0031    | TakeRight 31 -> 54
  0034    | GetConstant 4: _repeat
  0036    | GetBoundLocal 0
  0038    | GetBoundLocal 1
  0040    | GetConstant 5: 1
  0042    | NegateNumber
  0043    | Merge
  0044    | GetBoundLocal 2
  0046    | JumpIfFailure 46 -> 52
  0049    | GetBoundLocal 3
  0051    | Merge
  0052    | CallTailFunction 3
  0054  145 End
  ========================================
  
  =============repeat_between=============
  0000  152 GetConstant 0: First
  0002  150 GetConstant 1: const
  0004    | GetConstant 2: AssertPositiveInteger
  0006    | GetBoundLocal 1
  0008    | CallFunction 1
  0010    | CallFunction 1
  0012    | TakeRight 12 -> 25
  0015  151 GetConstant 3: const
  0017    | GetConstant 4: AssertPositiveInteger
  0019    | GetBoundLocal 2
  0021    | CallFunction 1
  0023    | CallFunction 1
  0025    | TakeRight 25 -> 35
  0028  152 GetBoundLocal 0
  0030    | CallFunction 0
  0032    | GetLocal 3
  0034    | Destructure
  0035    | TakeRight 35 -> 58
  0038  153 GetConstant 5: _repeat_between
  0040    | GetBoundLocal 0
  0042    | GetBoundLocal 1
  0044    | GetConstant 6: 1
  0046    | NegateNumber
  0047    | Merge
  0048    | GetBoundLocal 2
  0050    | GetConstant 7: 1
  0052    | NegateNumber
  0053    | Merge
  0054    | GetBoundLocal 3
  0056    | CallTailFunction 4
  0058  152 End
  ========================================
  
  ============_repeat_between=============
  0000  158 GetConstant 0: Next
  0002  156 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 2
  0007    | GetConstant 2: 0
  0009    | Destructure
  0010    | CallFunction 1
  0012    | ConditionalThen 12 -> 24
  0015  157 GetConstant 3: const
  0017    | GetBoundLocal 3
  0019    | CallTailFunction 1
  0021    | ConditionalElse 21 -> 92
  0024  158 SetInputMark
  0025    | GetBoundLocal 0
  0027    | CallFunction 0
  0029    | GetLocal 4
  0031    | Destructure
  0032    | ConditionalThen 32 -> 64
  0035  159 GetConstant 4: _repeat_between
  0037    | GetBoundLocal 0
  0039    | GetBoundLocal 1
  0041    | GetConstant 5: 1
  0043    | NegateNumber
  0044    | Merge
  0045    | GetBoundLocal 2
  0047    | GetConstant 6: 1
  0049    | NegateNumber
  0050    | Merge
  0051    | GetBoundLocal 3
  0053    | JumpIfFailure 53 -> 59
  0056    | GetBoundLocal 4
  0058    | Merge
  0059    | CallTailFunction 4
  0061    | ConditionalElse 61 -> 92
  0064  160 SetInputMark
  0065    | GetConstant 7: const
  0067    | GetBoundLocal 1
  0069    | GetConstant 8: _
  0071    | GetConstant 9: 0
  0073    | DestructureRange
  0074    | CallFunction 1
  0076    | ConditionalThen 76 -> 88
  0079  161 GetConstant 10: const
  0081    | GetBoundLocal 3
  0083    | CallTailFunction 1
  0085    | ConditionalElse 85 -> 92
  0088  162 GetConstant 11: @fail
  0090    | CallFunction 0
  0092  156 End
  ========================================
  
  =================array==================
  0000  164 GetConstant 0: First
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
  0000  167 GetConstant 0: Elem
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | GetLocal 2
  0009    | Destructure
  0010    | ConditionalThen 10 -> 40
  0013  168 GetConstant 1: _array
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
  0040  169 GetConstant 4: const
  0042    | GetBoundLocal 1
  0044    | CallTailFunction 1
  0046  167 End
  ========================================
  
  =================@fn409=================
  0000  171 GetConstant 0: sep
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
  0000  171 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 30
  0012    | GetConstant 1: _array
  0014    | GetConstant 2: @fn409
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetConstant 3: [_]
  0024    | GetBoundLocal 2
  0026    | InsertAtIndex 0
  0028    | CallTailFunction 2
  0030    | End
  ========================================
  
  ==============array_until===============
  0000  174 GetConstant 0: First
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
  0000  179 GetConstant 0: Elem
  0002  177 SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012  178 GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 57
  0021  179 GetBoundLocal 0
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
  0057  177 End
  ========================================
  
  =================@fn410=================
  0000  181 GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: array
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  0000  181 GetConstant 0: default
  0002    | GetConstant 1: @fn410
  0004    | CaptureLocal 0 0
  0007    | GetConstant 2: []
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn411=================
  0000  183 GetConstant 0: elem
  0002    | GetConstant 1: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 2: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  0000  183 GetConstant 0: default
  0002    | GetConstant 1: @fn411
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: []
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================tuple1=================
  0000  185 GetConstant 0: Elem
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
  0000  187 GetConstant 0: E1
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
  0000  189 GetConstant 0: E1
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
  0000  192 GetConstant 0: E1
  0002  193 GetConstant 1: E2
  0004  194 GetConstant 2: E3
  0006  192 GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 3
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016  193 GetBoundLocal 1
  0018    | CallFunction 0
  0020    | GetLocal 4
  0022    | Destructure
  0023    | TakeRight 23 -> 50
  0026  194 GetBoundLocal 2
  0028    | CallFunction 0
  0030    | GetLocal 5
  0032    | Destructure
  0033    | TakeRight 33 -> 50
  0036  195 GetConstant 3: [_, _, _]
  0038    | GetBoundLocal 3
  0040    | InsertAtIndex 0
  0042    | GetBoundLocal 4
  0044    | InsertAtIndex 1
  0046    | GetBoundLocal 5
  0048    | InsertAtIndex 2
  0050  193 End
  ========================================
  
  ===============tuple3_sep===============
  0000  198 GetConstant 0: E1
  0002  199 GetConstant 1: E2
  0004  200 GetConstant 2: E3
  0006  198 GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 5
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 1
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023  199 GetBoundLocal 2
  0025    | CallFunction 0
  0027    | GetLocal 6
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 3
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 64
  0040  200 GetBoundLocal 4
  0042    | CallFunction 0
  0044    | GetLocal 7
  0046    | Destructure
  0047    | TakeRight 47 -> 64
  0050  201 GetConstant 3: [_, _, _]
  0052    | GetBoundLocal 5
  0054    | InsertAtIndex 0
  0056    | GetBoundLocal 6
  0058    | InsertAtIndex 1
  0060    | GetBoundLocal 7
  0062    | InsertAtIndex 2
  0064  199 End
  ========================================
  
  =================tuple==================
  0000  204 GetConstant 0: const
  0002    | GetConstant 1: AssertNonNegativeInteger
  0004    | GetBoundLocal 1
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 23
  0013  205 GetConstant 2: _tuple
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetConstant 3: []
  0021    | CallTailFunction 3
  0023  204 End
  ========================================
  
  =================_tuple=================
  0000  210 GetConstant 0: Elem
  0002  208 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 1
  0007    | GetConstant 2: 0
  0009    | Destructure
  0010    | CallFunction 1
  0012    | ConditionalThen 12 -> 24
  0015  209 GetConstant 3: const
  0017    | GetBoundLocal 2
  0019    | CallTailFunction 1
  0021    | ConditionalElse 21 -> 64
  0024  210 GetBoundLocal 0
  0026    | CallFunction 0
  0028    | GetLocal 3
  0030    | Destructure
  0031    | TakeRight 31 -> 64
  0034    | GetConstant 4: _tuple
  0036    | GetBoundLocal 0
  0038    | GetBoundLocal 1
  0040    | GetConstant 5: 1
  0042    | NegateNumber
  0043    | Merge
  0044    | GetConstant 6: []
  0046    | JumpIfFailure 46 -> 52
  0049    | GetBoundLocal 2
  0051    | Merge
  0052    | JumpIfFailure 52 -> 62
  0055    | GetConstant 7: [_]
  0057    | GetBoundLocal 3
  0059    | InsertAtIndex 0
  0061    | Merge
  0062    | CallTailFunction 3
  0064  208 End
  ========================================
  
  ===============tuple_sep================
  0000  213 GetConstant 0: const
  0002    | GetConstant 1: AssertNonNegativeInteger
  0004    | GetBoundLocal 2
  0006    | CallFunction 1
  0008    | CallFunction 1
  0010    | TakeRight 10 -> 25
  0013  214 GetConstant 2: _tuple_sep
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetBoundLocal 2
  0021    | GetConstant 3: []
  0023    | CallTailFunction 4
  0025  213 End
  ========================================
  
  ===============_tuple_sep===============
  0000  219 GetConstant 0: Elem
  0002  217 SetInputMark
  0003    | GetConstant 1: const
  0005    | GetBoundLocal 2
  0007    | GetConstant 2: 0
  0009    | Destructure
  0010    | CallFunction 1
  0012    | ConditionalThen 12 -> 24
  0015  218 GetConstant 3: const
  0017    | GetBoundLocal 3
  0019    | CallTailFunction 1
  0021    | ConditionalElse 21 -> 73
  0024  219 GetBoundLocal 1
  0026    | CallFunction 0
  0028    | TakeRight 28 -> 35
  0031    | GetBoundLocal 0
  0033    | CallFunction 0
  0035    | GetLocal 4
  0037    | Destructure
  0038    | TakeRight 38 -> 73
  0041    | GetConstant 4: _tuple_sep
  0043    | GetBoundLocal 0
  0045    | GetBoundLocal 1
  0047    | GetBoundLocal 2
  0049    | GetConstant 5: 1
  0051    | NegateNumber
  0052    | Merge
  0053    | GetConstant 6: []
  0055    | JumpIfFailure 55 -> 61
  0058    | GetBoundLocal 3
  0060    | Merge
  0061    | JumpIfFailure 61 -> 71
  0064    | GetConstant 7: [_]
  0066    | GetBoundLocal 4
  0068    | InsertAtIndex 0
  0070    | Merge
  0071    | CallTailFunction 4
  0073  217 End
  ========================================
  
  ===============table_sep================
  0000  222 GetConstant 0: First
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
  0000  225 GetConstant 0: Elem
  0002  227 GetConstant 1: NextRow
  0004  225 SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | GetLocal 5
  0018    | Destructure
  0019    | ConditionalThen 19 -> 55
  0022  226 GetConstant 2: _table_sep
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
  0055  227 SetInputMark
  0056    | GetBoundLocal 2
  0058    | CallFunction 0
  0060    | TakeRight 60 -> 67
  0063    | GetBoundLocal 0
  0065    | CallFunction 0
  0067    | GetLocal 6
  0069    | Destructure
  0070    | ConditionalThen 70 -> 110
  0073  228 GetConstant 5: _table_sep
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
  0110  229 GetConstant 9: const
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
  0132  225 End
  ========================================
  
  =================@fn412=================
  0000  232 GetConstant 0: elem
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
  0000  232 GetConstant 0: default
  0002    | GetConstant 1: @fn412
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | GetConstant 2: [[]]
  0015    | CallTailFunction 2
  0017    | End
  ========================================
  
  =================object=================
  0000  235 GetConstant 0: K
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
  0024  236 GetConstant 2: _object
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | GetConstant 3: {}
  0032    | GetBoundLocal 2
  0034    | GetBoundLocal 3
  0036    | InsertKeyVal
  0037    | CallTailFunction 3
  0039  235 End
  ========================================
  
  ================_object=================
  0000  239 GetConstant 0: K
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
  0025  240 GetConstant 2: _object
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
  0049  241 GetConstant 4: const
  0051    | GetBoundLocal 2
  0053    | CallTailFunction 1
  0055  239 End
  ========================================
  
  =================@fn413=================
  0000  245 GetConstant 0: sep
  0002    | GetConstant 1: key
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn414=================
  0000  245 GetConstant 0: pair_sep
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
  0000  244 GetConstant 0: K
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
  0031  245 GetConstant 2: _object
  0033    | GetConstant 3: @fn413
  0035    | CaptureLocal 0 1
  0038    | CaptureLocal 3 0
  0041    | GetConstant 4: @fn414
  0043    | CaptureLocal 1 0
  0046    | CaptureLocal 2 1
  0049    | GetConstant 5: {}
  0051    | GetBoundLocal 4
  0053    | GetBoundLocal 5
  0055    | InsertKeyVal
  0056    | CallTailFunction 3
  0058  244 End
  ========================================
  
  ==============object_until==============
  0000  248 GetConstant 0: K
  0002  249 GetConstant 1: V
  0004  248 GetConstant 2: unless
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 2
  0010    | CallFunction 2
  0012    | GetLocal 3
  0014    | Destructure
  0015    | TakeRight 15 -> 25
  0018  249 GetBoundLocal 1
  0020    | CallFunction 0
  0022    | GetLocal 4
  0024    | Destructure
  0025    | TakeRight 25 -> 45
  0028  250 GetConstant 3: _object_until
  0030    | GetBoundLocal 0
  0032    | GetBoundLocal 1
  0034    | GetBoundLocal 2
  0036    | GetConstant 4: {}
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 4
  0042    | InsertKeyVal
  0043    | CallTailFunction 4
  0045  249 End
  ========================================
  
  =============_object_until==============
  0000  255 GetConstant 0: K
  0002    | GetConstant 1: V
  0004  253 SetInputMark
  0005    | GetConstant 2: peek
  0007    | GetBoundLocal 2
  0009    | CallFunction 1
  0011    | ConditionalThen 11 -> 23
  0014  254 GetConstant 3: const
  0016    | GetBoundLocal 3
  0018    | CallTailFunction 1
  0020    | ConditionalElse 20 -> 66
  0023  255 GetBoundLocal 0
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
  0066  253 End
  ========================================
  
  =================@fn415=================
  0000  257 GetConstant 0: key
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetConstant 2: object
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  0000  257 GetConstant 0: default
  0002    | GetConstant 1: @fn415
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: {}
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================@fn416=================
  0000  260 GetConstant 0: key
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
  0000  260 GetConstant 0: default
  0002    | GetConstant 1: @fn416
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | CaptureLocal 3 3
  0016    | GetConstant 2: {}
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ================record1=================
  0000  262 GetConstant 0: Value
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
  0000  265 GetConstant 0: V1
  0002  266 GetConstant 1: V2
  0004  265 GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 4
  0010    | Destructure
  0011    | TakeRight 11 -> 36
  0014  266 GetBoundLocal 3
  0016    | CallFunction 0
  0018    | GetLocal 5
  0020    | Destructure
  0021    | TakeRight 21 -> 36
  0024  267 GetConstant 2: {}
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 4
  0030    | InsertKeyVal
  0031    | GetBoundLocal 2
  0033    | GetBoundLocal 5
  0035    | InsertKeyVal
  0036  265 End
  ========================================
  
  ==============record2_sep===============
  0000  270 GetConstant 0: V1
  0002  271 GetConstant 1: V2
  0004  270 GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 5
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 2
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 43
  0021  271 GetBoundLocal 4
  0023    | CallFunction 0
  0025    | GetLocal 6
  0027    | Destructure
  0028    | TakeRight 28 -> 43
  0031  272 GetConstant 2: {}
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 5
  0037    | InsertKeyVal
  0038    | GetBoundLocal 3
  0040    | GetBoundLocal 6
  0042    | InsertKeyVal
  0043  270 End
  ========================================
  
  ================record3=================
  0000  275 GetConstant 0: V1
  0002  276 GetConstant 1: V2
  0004  277 GetConstant 2: V3
  0006  275 GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 6
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016  276 GetBoundLocal 3
  0018    | CallFunction 0
  0020    | GetLocal 7
  0022    | Destructure
  0023    | TakeRight 23 -> 53
  0026  277 GetBoundLocal 5
  0028    | CallFunction 0
  0030    | GetLocal 8
  0032    | Destructure
  0033    | TakeRight 33 -> 53
  0036  278 GetConstant 3: {}
  0038    | GetBoundLocal 0
  0040    | GetBoundLocal 6
  0042    | InsertKeyVal
  0043    | GetBoundLocal 2
  0045    | GetBoundLocal 7
  0047    | InsertKeyVal
  0048    | GetBoundLocal 4
  0050    | GetBoundLocal 8
  0052    | InsertKeyVal
  0053  276 End
  ========================================
  
  ==============record3_sep===============
  0000  281 GetConstant 0: V1
  0002  282 GetConstant 1: V2
  0004  283 GetConstant 2: V3
  0006  281 GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 8
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 2
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023  282 GetBoundLocal 4
  0025    | CallFunction 0
  0027    | GetLocal 9
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 5
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 67
  0040  283 GetBoundLocal 7
  0042    | CallFunction 0
  0044    | GetLocal 10
  0046    | Destructure
  0047    | TakeRight 47 -> 67
  0050  284 GetConstant 3: {}
  0052    | GetBoundLocal 0
  0054    | GetBoundLocal 8
  0056    | InsertKeyVal
  0057    | GetBoundLocal 3
  0059    | GetBoundLocal 9
  0061    | InsertKeyVal
  0062    | GetBoundLocal 6
  0064    | GetBoundLocal 10
  0066    | InsertKeyVal
  0067  282 End
  ========================================
  
  ==================json==================
  0000  291 SetInputMark
  0001  290 SetInputMark
  0002  289 SetInputMark
  0003  288 SetInputMark
  0004  287 SetInputMark
  0005    | GetConstant 0: boolean
  0007    | GetConstant 1: "true"
  0009    | GetConstant 2: "false"
  0011    | CallFunction 2
  0013    | Or 13 -> 22
  0016  288 GetConstant 3: null
  0018    | GetConstant 4: "null"
  0020    | CallFunction 1
  0022    | Or 22 -> 29
  0025  289 GetConstant 5: number
  0027    | CallFunction 0
  0029    | Or 29 -> 36
  0032  290 GetConstant 6: json_string
  0034    | CallFunction 0
  0036    | Or 36 -> 43
  0039  291 GetConstant 7: json_array
  0041    | CallFunction 0
  0043    | Or 43 -> 50
  0046  292 GetConstant 8: json_object
  0048    | CallFunction 0
  0050  291 End
  ========================================
  
  ==============json_string===============
  0000  294 GetConstant 0: """
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 13
  0007    | GetConstant 1: _json_string
  0009    | GetConstant 2: ""
  0011    | CallTailFunction 1
  0013    | End
  ========================================
  
  ==============_json_string==============
  0000  299 GetConstant 0: Next
  0002  297 SetInputMark
  0003    | GetConstant 1: """
  0005    | CallFunction 0
  0007    | ConditionalThen 7 -> 19
  0010  298 GetConstant 2: const
  0012    | GetBoundLocal 0
  0014    | CallTailFunction 1
  0016    | ConditionalElse 16 -> 61
  0019  299 SetInputMark
  0020    | SetInputMark
  0021    | GetConstant 3: _escape_char
  0023    | CallFunction 0
  0025    | Or 25 -> 32
  0028    | GetConstant 4: _escape_unicode
  0030    | CallFunction 0
  0032    | Or 32 -> 43
  0035    | GetConstant 5: unless
  0037    | GetConstant 6: char
  0039    | GetConstant 7: "\"
  0041    | CallFunction 2
  0043    | GetLocal 1
  0045    | Destructure
  0046    | TakeRight 46 -> 61
  0049  300 GetConstant 8: _json_string
  0051    | GetBoundLocal 0
  0053    | JumpIfFailure 53 -> 59
  0056    | GetBoundLocal 1
  0058    | Merge
  0059    | CallTailFunction 1
  0061  297 End
  ========================================
  
  ==============_escape_char==============
  0000  302 SetInputMark
  0001    | SetInputMark
  0002    | SetInputMark
  0003    | SetInputMark
  0004    | SetInputMark
  0005    | SetInputMark
  0006    | SetInputMark
  0007    | GetConstant 0: "\""
  0009    | CallFunction 0
  0011    | Or 11 -> 18
  0014    | GetConstant 1: "\\"
  0016    | CallFunction 0
  0018    | Or 18 -> 25
  0021    | GetConstant 2: "\/"
  0023    | CallFunction 0
  0025    | Or 25 -> 32
  0028    | GetConstant 3: "\b"
  0030    | CallFunction 0
  0032    | Or 32 -> 39
  0035    | GetConstant 4: "\f"
  0037    | CallFunction 0
  0039    | Or 39 -> 46
  0042    | GetConstant 5: "\n"
  0044    | CallFunction 0
  0046    | Or 46 -> 53
  0049    | GetConstant 6: "\r"
  0051    | CallFunction 0
  0053    | Or 53 -> 60
  0056    | GetConstant 7: "\t"
  0058    | CallFunction 0
  0060    | End
  ========================================
  
  ============_escape_unicode=============
  0000  304 GetConstant 0: "\u"
  0002    | CallFunction 0
  0004    | JumpIfFailure 4 -> 12
  0007    | GetConstant 1: _hex
  0009    | CallFunction 0
  0011    | Merge
  0012    | JumpIfFailure 12 -> 20
  0015    | GetConstant 2: _hex
  0017    | CallFunction 0
  0019    | Merge
  0020    | JumpIfFailure 20 -> 28
  0023    | GetConstant 3: _hex
  0025    | CallFunction 0
  0027    | Merge
  0028    | JumpIfFailure 28 -> 36
  0031    | GetConstant 4: _hex
  0033    | CallFunction 0
  0035    | Merge
  0036    | End
  ========================================
  
  ==================_hex==================
  0000  306 SetInputMark
  0001    | SetInputMark
  0002    | GetConstant 0: digit
  0004    | CallFunction 0
  0006    | Or 6 -> 12
  0009    | ParseRange 1 2: "a" "f"
  0012    | Or 12 -> 18
  0015    | ParseRange 3 4: "A" "F"
  0018    | End
  ========================================
  
  =================@fn418=================
  0000  308 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn417=================
  0000  308 GetConstant 0: surround
  0002    | GetConstant 1: json
  0004    | GetConstant 2: @fn418
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ===============json_array===============
  0000  308 GetConstant 0: "["
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 15
  0007    | GetConstant 1: maybe_array_sep
  0009    | GetConstant 2: @fn417
  0011    | GetConstant 3: ","
  0013    | CallFunction 2
  0015    | JumpIfFailure 15 -> 23
  0018    | GetConstant 4: "]"
  0020    | CallFunction 0
  0022    | TakeLeft
  0023    | End
  ========================================
  
  =================@fn420=================
  0000  313 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn419=================
  0000  313 GetConstant 0: surround
  0002    | GetConstant 1: json_string
  0004    | GetConstant 2: @fn420
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================@fn422=================
  0000  314 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn421=================
  0000  314 GetConstant 0: surround
  0002    | GetConstant 1: json
  0004    | GetConstant 2: @fn422
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ==============json_object===============
  0000  311 GetConstant 0: "{"
  0002    | CallFunction 0
  0004    | TakeRight 4 -> 19
  0007  312 GetConstant 1: maybe_object_sep
  0009  313 GetConstant 2: @fn419
  0011    | GetConstant 3: ":"
  0013  314 GetConstant 4: @fn421
  0015    | GetConstant 5: ","
  0017  312 CallFunction 4
  0019  316 JumpIfFailure 19 -> 27
  0022    | GetConstant 6: "}"
  0024    | CallFunction 0
  0026    | TakeLeft
  0027    | End
  ========================================
  
  =============ZipIntoObject==============
  0000  318 GetConstant 0: _ZipIntoObject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: {}
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  =============_ZipIntoObject=============
  0000  321 GetConstant 0: K
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
  0109  322 GetConstant 8: _ZipIntoObject
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
  0133  323 GetBoundLocal 2
  0135  321 End
  ========================================
  
  ==================Map===================
  0000  325 GetConstant 0: _Map
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ==================_Map==================
  0000  328 GetConstant 0: First
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
  0055  329 GetConstant 4: _Map
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
  0088  330 GetBoundLocal 2
  0090  328 End
  ========================================
  
  ===============ArrayFirst===============
  0000  332 GetConstant 0: F
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
  0000  334 GetConstant 0: _
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
  0000  336 GetConstant 0: _TransposeTable
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ============_TransposeTable=============
  0000  339 GetConstant 0: FirstPerRow
  0002  340 GetConstant 1: RestPerRow
  0004    | SetInputMark
  0005  339 GetConstant 2: Map
  0007    | GetBoundLocal 0
  0009    | GetConstant 3: ArrayFirst
  0011    | CallFunction 2
  0013    | GetLocal 2
  0015    | Destructure
  0016    | TakeRight 16 -> 30
  0019  340 GetConstant 4: Map
  0021    | GetBoundLocal 0
  0023    | GetConstant 5: ArrayRest
  0025    | CallFunction 2
  0027    | GetLocal 3
  0029    | Destructure
  0030    | ConditionalThen 30 -> 60
  0033  341 GetConstant 6: _TransposeTable
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
  0060  342 GetBoundLocal 1
  0062  340 End
  ========================================
  
  ==========RotateTableClockwise==========
  0000  344 GetConstant 0: Map
  0002    | GetConstant 1: TransposeTable
  0004    | GetBoundLocal 0
  0006    | CallFunction 1
  0008    | GetConstant 2: Reverse
  0010    | CallTailFunction 2
  0012    | End
  ========================================
  
  ================Reverse=================
  0000  346 GetConstant 0: _Reverse
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: []
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  ================_Reverse================
  0000  349 GetConstant 0: First
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
  0055  350 GetConstant 4: _Reverse
  0057    | GetBoundLocal 3
  0059    | GetConstant 5: [_]
  0061    | GetBoundLocal 2
  0063    | InsertAtIndex 0
  0065    | JumpIfFailure 65 -> 71
  0068    | GetBoundLocal 1
  0070    | Merge
  0071    | CallTailFunction 2
  0073    | ConditionalElse 73 -> 78
  0076  351 GetBoundLocal 1
  0078  349 End
  ========================================
  
  =================Reject=================
  0000  353 GetConstant 0: _Reject
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ================_Reject=================
  0000  356 GetConstant 0: First
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
  0055  357 GetConstant 4: _Reject
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
  0099  358 GetBoundLocal 2
  0101  356 End
  ========================================
  
  =================IsNull=================
  0000  360 GetBoundLocal 0
  0002    | Null
  0003    | Destructure
  0004    | End
  ========================================
  
  ================Tabular=================
  0000  362 GetConstant 0: _Tabular
  0002    | GetBoundLocal 0
  0004    | GetBoundLocal 1
  0006    | GetConstant 1: []
  0008    | CallTailFunction 3
  0010    | End
  ========================================
  
  ================_Tabular================
  0000  365 GetConstant 0: Row
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
  0055  366 GetConstant 4: _Tabular
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
  0090  367 GetBoundLocal 2
  0092  365 End
  ========================================
  
  =========AssertPositiveInteger==========
  0000  370 SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: 1
  0005    | GetConstant 1: _
  0007    | DestructureRange
  0008    | Or 8 -> 20
  0011    | GetConstant 2: @Crash
  0013    | GetConstant 3: "Expected a positive integer, got "
  0015    1 GetBoundLocal 0
  0017  370 MergeAsString
  0018    | CallTailFunction 1
  0020    | End
  ========================================
  
  ========AssertNonNegativeInteger========
  0000  373 SetInputMark
  0001    | GetBoundLocal 0
  0003    | GetConstant 0: 0
  0005    | GetConstant 1: _
  0007    | DestructureRange
  0008    | Or 8 -> 20
  0011    | GetConstant 2: @Crash
  0013    | GetConstant 3: "Expected a non-negative integer, got "
  0015    1 GetBoundLocal 0
  0017  373 MergeAsString
  0018    | CallTailFunction 1
  0020    | End
  ========================================

