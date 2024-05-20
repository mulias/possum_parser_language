  $ export PRINT_COMPILED_BYTECODE=true RUN_VM=false

  $ possum $TESTDIR/../stdlib.possum -i ''
  
  =================alpha==================
  0000    5 SetInputMark
  0001    | GetConstant 0: "a".."z"
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "A".."Z"
  0010    | CallFunction 0
  0012    | End
  ========================================
  
  =================alphas=================
  0000    7 GetConstant 0: many
  0002    | GetConstant 1: alpha
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================lowers=================
  0000   11 GetConstant 0: many
  0002    | GetConstant 1: "a".."z"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================uppers=================
  0000   15 GetConstant 0: many
  0002    | GetConstant 1: "A".."Z"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ================numerals================
  0000   19 GetConstant 0: many
  0002    | GetConstant 1: "0".."9"
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================alnum==================
  0000   21 SetInputMark
  0001    | GetConstant 0: alpha
  0003    | CallFunction 0
  0005    | Or 5 -> 12
  0008    | GetConstant 1: "0".."9"
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
  0024    | Or 24 -> 31
  0027    | GetConstant 3: "\xe2\x80\x80".."\xe2\x80\x8a" (esc)
  0029    | CallFunction 0
  0031    | Or 31 -> 38
  0034    | GetConstant 4: "\xe2\x80\xaf" (esc)
  0036    | CallFunction 0
  0038    | Or 38 -> 45
  0041    | GetConstant 5: "\xe2\x81\x9f" (esc)
  0043    | CallFunction 0
  0045    | Or 45 -> 52
  0048    | GetConstant 6: "\xe3\x80\x80" (esc)
  0050    | CallFunction 0
  0052    | End
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
  0008    | Or 8 -> 15
  0011    | GetConstant 1: "
  ".."\r (no-eol) (esc)
  "
  0013    | CallFunction 0
  0015    | Or 15 -> 22
  0018    | GetConstant 2: "\xc2\x85" (esc)
  0020    | CallFunction 0
  0022    | Or 22 -> 29
  0025    | GetConstant 3: "\xe2\x80\xa8" (esc)
  0027    | CallFunction 0
  0029    | Or 29 -> 36
  0032    | GetConstant 4: "\xe2\x80\xa9" (esc)
  0034    | CallFunction 0
  0036    | End
  ========================================
  
  ================newlines================
  0000   34 GetConstant 0: many
  0002    | GetConstant 1: newline
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  ==============end_of_input==============
  0000   38 SetInputMark
  0001    | GetConstant 0: peek
  0003    | GetConstant 1: "\x00".."\xf4\x8f\xbf\xbf" (esc)
  0005    | CallFunction 1
  0007    | ConditionalThen 7 -> 17
  0010    | GetConstant 2: @fail
  0012    | CallFunction 0
  0014    | ConditionalElse 14 -> 21
  0017    | GetConstant 3: succeed
  0019    | CallFunction 0
  0021    | End
  ========================================
  
  =================@fn20==================
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
  0002    | GetConstant 1: @fn20
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn21==================
  0000   46 GetConstant 0: unless
  0002    | GetConstant 1: "\x00".."\xf4\x8f\xbf\xbf" (esc)
  0004    | GetConstant 2: whitespace
  0006    | CallTailFunction 2
  0008    | End
  ========================================
  
  =================token==================
  0000   46 GetConstant 0: many
  0002    | GetConstant 1: @fn21
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn22==================
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
  0002    | GetConstant 1: @fn22
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn23==================
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
  0002    | GetConstant 1: "\x00".."\xf4\x8f\xbf\xbf" (esc)
  0004    | GetConstant 2: @fn23
  0006    | CallTailFunction 2
  0008    | End
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
  
  =================@fn24==================
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
  0002    | GetConstant 1: @fn24
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn25==================
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
  0002    | GetConstant 1: @fn25
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn26==================
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
  0002    | GetConstant 1: @fn26
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn27==================
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
  0002   68 GetConstant 1: @fn27
  0004   66 CallTailFunction 1
  0006    | End
  ========================================
  
  =================@fn28==================
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
  0002   74 GetConstant 1: @fn28
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
  0001    | GetConstant 0: "1".."9"
  0003    | CallFunction 0
  0005    | JumpIfFailure 5 -> 13
  0008    | GetConstant 1: numerals
  0010    | CallFunction 0
  0012    | Merge
  0013    | Or 13 -> 20
  0016    | GetConstant 2: "0".."9"
  0018    | CallFunction 0
  0020    | End
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
  
  =================@fn29==================
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
  0017    | GetConstant 3: @fn29
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
  0008    | GetConstant 0: "\x00".."\xf4\x8f\xbf\xbf" (esc)
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
  
  ================surround================
  0000  116 GetBoundLocal 1
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
  
  =================@fn30==================
  0000  118 GetConstant 0: maybe
  0002    | GetConstant 1: whitespace
  0004    | CallTailFunction 1
  0006    | End
  ========================================
  
  =================input==================
  0000  118 GetConstant 0: surround
  0002    | GetBoundLocal 0
  0004    | GetConstant 1: @fn30
  0006    | CallFunction 2
  0008    | JumpIfFailure 8 -> 16
  0011    | GetConstant 2: end_of_input
  0013    | CallFunction 0
  0015    | TakeLeft
  0016    | End
  ========================================
  
  ==================many==================
  0000  120 GetConstant 0: First
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
  0000  122 GetConstant 0: Next
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | GetLocal 2
  0009    | Destructure
  0010    | ConditionalThen 10 -> 27
  0013    | GetConstant 1: _many
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetBoundLocal 2
  0021    | Merge
  0022    | CallTailFunction 2
  0024    | ConditionalElse 24 -> 33
  0027    | GetConstant 2: const
  0029    | GetBoundLocal 1
  0031    | CallTailFunction 1
  0033    | End
  ========================================
  
  =================@fn31==================
  0000  124 GetConstant 0: sep
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
  0000  124 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 26
  0012    | GetConstant 1: _many
  0014    | GetConstant 2: @fn31
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetBoundLocal 2
  0024    | CallTailFunction 2
  0026    | End
  ========================================
  
  ===============many_until===============
  0000  126 GetConstant 0: First
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
  0000  131 GetConstant 0: Next
  0002  129 SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012  130 GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 44
  0021  131 GetBoundLocal 0
  0023    | CallFunction 0
  0025    | GetLocal 3
  0027    | Destructure
  0028    | TakeRight 28 -> 44
  0031    | GetConstant 3: _many_until
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | GetBoundLocal 2
  0039    | GetBoundLocal 3
  0041    | Merge
  0042    | CallTailFunction 3
  0044  129 End
  ========================================
  
  ===============maybe_many===============
  0000  133 SetInputMark
  0001    | GetConstant 0: many
  0003    | GetBoundLocal 0
  0005    | CallFunction 1
  0007    | Or 7 -> 14
  0010    | GetConstant 1: succeed
  0012    | CallFunction 0
  0014    | End
  ========================================
  
  =============maybe_many_sep=============
  0000  135 SetInputMark
  0001    | GetConstant 0: many_sep
  0003    | GetBoundLocal 0
  0005    | GetBoundLocal 1
  0007    | CallFunction 2
  0009    | Or 9 -> 16
  0012    | GetConstant 1: succeed
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================array==================
  0000  137 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 1
  0008    | Destructure
  0009    | TakeRight 9 -> 21
  0012    | GetConstant 1: _array
  0014    | GetBoundLocal 0
  0016    | GetConstant 2: [First]
  0018    | ResolveUnboundVars
  0019    | CallTailFunction 2
  0021    | End
  ========================================
  
  =================_array=================
  0000  140 GetConstant 0: Elem
  0002    | SetInputMark
  0003    | GetBoundLocal 0
  0005    | CallFunction 0
  0007    | GetLocal 2
  0009    | Destructure
  0010    | ConditionalThen 10 -> 28
  0013  141 GetConstant 1: _array
  0015    | GetBoundLocal 0
  0017    | GetBoundLocal 1
  0019    | GetConstant 2: [Elem]
  0021    | ResolveUnboundVars
  0022    | Merge
  0023    | CallTailFunction 2
  0025    | ConditionalElse 25 -> 34
  0028  142 GetConstant 3: const
  0030    | GetBoundLocal 1
  0032    | CallTailFunction 1
  0034  140 End
  ========================================
  
  =================@fn32==================
  0000  144 GetConstant 0: sep
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
  0000  144 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 27
  0012    | GetConstant 1: _array
  0014    | GetConstant 2: @fn32
  0016    | CaptureLocal 0 1
  0019    | CaptureLocal 1 0
  0022    | GetConstant 3: [First]
  0024    | ResolveUnboundVars
  0025    | CallTailFunction 2
  0027    | End
  ========================================
  
  ==============array_until===============
  0000  147 GetConstant 0: First
  0002    | GetConstant 1: unless
  0004    | GetBoundLocal 0
  0006    | GetBoundLocal 1
  0008    | CallFunction 2
  0010    | GetLocal 2
  0012    | Destructure
  0013    | TakeRight 13 -> 27
  0016    | GetConstant 2: _array_until
  0018    | GetBoundLocal 0
  0020    | GetBoundLocal 1
  0022    | GetConstant 3: [First]
  0024    | ResolveUnboundVars
  0025    | CallTailFunction 3
  0027    | End
  ========================================
  
  ==============_array_until==============
  0000  152 GetConstant 0: Elem
  0002  150 SetInputMark
  0003    | GetConstant 1: peek
  0005    | GetBoundLocal 1
  0007    | CallFunction 1
  0009    | ConditionalThen 9 -> 21
  0012  151 GetConstant 2: const
  0014    | GetBoundLocal 2
  0016    | CallTailFunction 1
  0018    | ConditionalElse 18 -> 45
  0021  152 GetBoundLocal 0
  0023    | CallFunction 0
  0025    | GetLocal 3
  0027    | Destructure
  0028    | TakeRight 28 -> 45
  0031    | GetConstant 3: _array_until
  0033    | GetBoundLocal 0
  0035    | GetBoundLocal 1
  0037    | GetBoundLocal 2
  0039    | GetConstant 4: [Elem]
  0041    | ResolveUnboundVars
  0042    | Merge
  0043    | CallTailFunction 3
  0045  150 End
  ========================================
  
  =================@fn33==================
  0000  154 GetConstant 0: elem
  0002    | SetClosureCaptures
  0003    | GetConstant 1: array
  0005    | GetBoundLocal 0
  0007    | CallTailFunction 1
  0009    | End
  ========================================
  
  ==============maybe_array===============
  0000  154 GetConstant 0: default
  0002    | GetConstant 1: @fn33
  0004    | CaptureLocal 0 0
  0007    | GetConstant 2: []
  0009    | CallTailFunction 2
  0011    | End
  ========================================
  
  =================@fn34==================
  0000  156 GetConstant 0: elem
  0002    | GetConstant 1: sep
  0004    | SetClosureCaptures
  0005    | GetConstant 2: array_sep
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ============maybe_array_sep=============
  0000  156 GetConstant 0: default
  0002    | GetConstant 1: @fn34
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: []
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================tuple1=================
  0000  158 GetConstant 0: Elem
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 1
  0008    | Destructure
  0009    | TakeRight 9 -> 15
  0012    | GetConstant 1: [Elem]
  0014    | ResolveUnboundVars
  0015    | End
  ========================================
  
  =================tuple2=================
  0000  160 GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 2
  0010    | Destructure
  0011    | TakeRight 11 -> 27
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | GetLocal 3
  0020    | Destructure
  0021    | TakeRight 21 -> 27
  0024    | GetConstant 2: [E1, E2]
  0026    | ResolveUnboundVars
  0027    | End
  ========================================
  
  ===============tuple2_sep===============
  0000  162 GetConstant 0: E1
  0002    | GetConstant 1: E2
  0004    | GetBoundLocal 0
  0006    | CallFunction 0
  0008    | GetLocal 3
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 1
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 34
  0021    | GetBoundLocal 2
  0023    | CallFunction 0
  0025    | GetLocal 4
  0027    | Destructure
  0028    | TakeRight 28 -> 34
  0031    | GetConstant 2: [E1, E2]
  0033    | ResolveUnboundVars
  0034    | End
  ========================================
  
  =================tuple3=================
  0000  165 GetConstant 0: E1
  0002  166 GetConstant 1: E2
  0004  167 GetConstant 2: E3
  0006  165 GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 3
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016  166 GetBoundLocal 1
  0018    | CallFunction 0
  0020    | GetLocal 4
  0022    | Destructure
  0023    | TakeRight 23 -> 39
  0026  167 GetBoundLocal 2
  0028    | CallFunction 0
  0030    | GetLocal 5
  0032    | Destructure
  0033    | TakeRight 33 -> 39
  0036  168 GetConstant 3: [E1, E2, E3]
  0038    | ResolveUnboundVars
  0039  166 End
  ========================================
  
  ===============tuple3_sep===============
  0000  171 GetConstant 0: E1
  0002  172 GetConstant 1: E2
  0004  173 GetConstant 2: E3
  0006  171 GetBoundLocal 0
  0008    | CallFunction 0
  0010    | GetLocal 5
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 1
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023  172 GetBoundLocal 2
  0025    | CallFunction 0
  0027    | GetLocal 6
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 3
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 53
  0040  173 GetBoundLocal 4
  0042    | CallFunction 0
  0044    | GetLocal 7
  0046    | Destructure
  0047    | TakeRight 47 -> 53
  0050  174 GetConstant 3: [E1, E2, E3]
  0052    | ResolveUnboundVars
  0053  172 End
  ========================================
  
  ===============table_sep================
  0000  177 GetConstant 0: First
  0002    | GetBoundLocal 0
  0004    | CallFunction 0
  0006    | GetLocal 3
  0008    | Destructure
  0009    | TakeRight 9 -> 27
  0012    | GetConstant 1: _table_sep
  0014    | GetBoundLocal 0
  0016    | GetBoundLocal 1
  0018    | GetBoundLocal 2
  0020    | GetConstant 2: [First]
  0022    | ResolveUnboundVars
  0023    | GetConstant 3: []
  0025    | CallTailFunction 5
  0027    | End
  ========================================
  
  ===============_table_sep===============
  0000  180 GetConstant 0: Elem
  0002  182 GetConstant 1: NextRow
  0004  180 SetInputMark
  0005    | GetBoundLocal 1
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 0
  0014    | CallFunction 0
  0016    | GetLocal 5
  0018    | Destructure
  0019    | ConditionalThen 19 -> 43
  0022  181 GetConstant 2: _table_sep
  0024    | GetBoundLocal 0
  0026    | GetBoundLocal 1
  0028    | GetBoundLocal 2
  0030    | GetBoundLocal 3
  0032    | GetConstant 3: [Elem]
  0034    | ResolveUnboundVars
  0035    | Merge
  0036    | GetBoundLocal 4
  0038    | CallTailFunction 5
  0040    | ConditionalElse 40 -> 93
  0043  182 SetInputMark
  0044    | GetBoundLocal 2
  0046    | CallFunction 0
  0048    | TakeRight 48 -> 55
  0051    | GetBoundLocal 0
  0053    | CallFunction 0
  0055    | GetLocal 6
  0057    | Destructure
  0058    | ConditionalThen 58 -> 83
  0061  183 GetConstant 4: _table_sep
  0063    | GetBoundLocal 0
  0065    | GetBoundLocal 1
  0067    | GetBoundLocal 2
  0069    | GetConstant 5: [NextRow]
  0071    | ResolveUnboundVars
  0072    | GetBoundLocal 4
  0074    | GetConstant 6: [AccRow]
  0076    | ResolveUnboundVars
  0077    | Merge
  0078    | CallTailFunction 5
  0080    | ConditionalElse 80 -> 93
  0083  184 GetConstant 7: const
  0085    | GetBoundLocal 4
  0087    | GetConstant 8: [AccRow]
  0089    | ResolveUnboundVars
  0090    | Merge
  0091    | CallTailFunction 1
  0093  180 End
  ========================================
  
  =================@fn35==================
  0000  187 GetConstant 0: elem
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
  0000  187 GetConstant 0: default
  0002    | GetConstant 1: @fn35
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | GetConstant 2: [[]]
  0015    | ResolveUnboundVars
  0016    | CallTailFunction 2
  0018    | End
  ========================================
  
  =================object=================
  0000  190 GetConstant 0: K
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
  0021    | TakeRight 21 -> 35
  0024  191 GetConstant 2: _object
  0026    | GetBoundLocal 0
  0028    | GetBoundLocal 1
  0030    | GetConstant 3: {"K": V}
  0032    | ResolveUnboundVars
  0033    | CallTailFunction 3
  0035  190 End
  ========================================
  
  ================_object=================
  0000  194 GetConstant 0: K
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
  0022    | ConditionalThen 22 -> 42
  0025  195 GetConstant 2: _object
  0027    | GetBoundLocal 0
  0029    | GetBoundLocal 1
  0031    | GetBoundLocal 2
  0033    | GetConstant 3: {"K": V}
  0035    | ResolveUnboundVars
  0036    | Merge
  0037    | CallTailFunction 3
  0039    | ConditionalElse 39 -> 48
  0042  196 GetConstant 4: const
  0044    | GetBoundLocal 2
  0046    | CallTailFunction 1
  0048  194 End
  ========================================
  
  =================@fn36==================
  0000  200 GetConstant 0: sep
  0002    | GetConstant 1: key
  0004    | SetClosureCaptures
  0005    | GetBoundLocal 0
  0007    | CallFunction 0
  0009    | TakeRight 9 -> 16
  0012    | GetBoundLocal 1
  0014    | CallFunction 0
  0016    | End
  ========================================
  
  =================@fn37==================
  0000  200 GetConstant 0: pair_sep
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
  0000  199 GetConstant 0: K
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
  0028    | TakeRight 28 -> 54
  0031  200 GetConstant 2: _object
  0033    | GetConstant 3: @fn36
  0035    | CaptureLocal 0 1
  0038    | CaptureLocal 3 0
  0041    | GetConstant 4: @fn37
  0043    | CaptureLocal 1 0
  0046    | CaptureLocal 2 1
  0049    | GetConstant 5: {"K": V}
  0051    | ResolveUnboundVars
  0052    | CallTailFunction 3
  0054  199 End
  ========================================
  
  ==============object_until==============
  0000  203 GetConstant 0: K
  0002  204 GetConstant 1: V
  0004  203 GetConstant 2: unless
  0006    | GetBoundLocal 0
  0008    | GetBoundLocal 2
  0010    | CallFunction 2
  0012    | GetLocal 3
  0014    | Destructure
  0015    | TakeRight 15 -> 25
  0018  204 GetBoundLocal 1
  0020    | CallFunction 0
  0022    | GetLocal 4
  0024    | Destructure
  0025    | TakeRight 25 -> 41
  0028  205 GetConstant 3: _object_until
  0030    | GetBoundLocal 0
  0032    | GetBoundLocal 1
  0034    | GetBoundLocal 2
  0036    | GetConstant 4: {"K": V}
  0038    | ResolveUnboundVars
  0039    | CallTailFunction 4
  0041  204 End
  ========================================
  
  =============_object_until==============
  0000  210 GetConstant 0: K
  0002    | GetConstant 1: V
  0004  208 SetInputMark
  0005    | GetConstant 2: peek
  0007    | GetBoundLocal 2
  0009    | CallFunction 1
  0011    | ConditionalThen 11 -> 23
  0014  209 GetConstant 3: const
  0016    | GetBoundLocal 3
  0018    | CallTailFunction 1
  0020    | ConditionalElse 20 -> 59
  0023  210 GetBoundLocal 0
  0025    | CallFunction 0
  0027    | GetLocal 4
  0029    | Destructure
  0030    | TakeRight 30 -> 40
  0033    | GetBoundLocal 1
  0035    | CallFunction 0
  0037    | GetLocal 5
  0039    | Destructure
  0040    | TakeRight 40 -> 59
  0043    | GetConstant 4: _object_until
  0045    | GetBoundLocal 0
  0047    | GetBoundLocal 1
  0049    | GetBoundLocal 2
  0051    | GetBoundLocal 3
  0053    | GetConstant 5: {"K": V}
  0055    | ResolveUnboundVars
  0056    | Merge
  0057    | CallTailFunction 4
  0059  208 End
  ========================================
  
  =================@fn38==================
  0000  212 GetConstant 0: key
  0002    | GetConstant 1: value
  0004    | SetClosureCaptures
  0005    | GetConstant 2: object
  0007    | GetBoundLocal 0
  0009    | GetBoundLocal 1
  0011    | CallTailFunction 2
  0013    | End
  ========================================
  
  ==============maybe_object==============
  0000  212 GetConstant 0: default
  0002    | GetConstant 1: @fn38
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | GetConstant 2: {}
  0012    | CallTailFunction 2
  0014    | End
  ========================================
  
  =================@fn39==================
  0000  215 GetConstant 0: key
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
  0000  215 GetConstant 0: default
  0002    | GetConstant 1: @fn39
  0004    | CaptureLocal 0 0
  0007    | CaptureLocal 1 1
  0010    | CaptureLocal 2 2
  0013    | CaptureLocal 3 3
  0016    | GetConstant 2: {}
  0018    | CallTailFunction 2
  0020    | End
  ========================================
  
  ================record1=================
  0000  217 GetConstant 0: Value
  0002    | GetBoundLocal 1
  0004    | CallFunction 0
  0006    | GetLocal 2
  0008    | Destructure
  0009    | TakeRight 9 -> 15
  0012    | GetConstant 1: {"Key": Value}
  0014    | ResolveUnboundVars
  0015    | End
  ========================================
  
  ================record2=================
  0000  220 GetConstant 0: V1
  0002  221 GetConstant 1: V2
  0004  220 GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 4
  0010    | Destructure
  0011    | TakeRight 11 -> 27
  0014  221 GetBoundLocal 3
  0016    | CallFunction 0
  0018    | GetLocal 5
  0020    | Destructure
  0021    | TakeRight 21 -> 27
  0024  222 GetConstant 2: {"Key1": V1, "Key2": V2}
  0026    | ResolveUnboundVars
  0027  220 End
  ========================================
  
  ==============record2_sep===============
  0000  225 GetConstant 0: V1
  0002  226 GetConstant 1: V2
  0004  225 GetBoundLocal 1
  0006    | CallFunction 0
  0008    | GetLocal 5
  0010    | Destructure
  0011    | TakeRight 11 -> 18
  0014    | GetBoundLocal 2
  0016    | CallFunction 0
  0018    | TakeRight 18 -> 34
  0021  226 GetBoundLocal 4
  0023    | CallFunction 0
  0025    | GetLocal 6
  0027    | Destructure
  0028    | TakeRight 28 -> 34
  0031  227 GetConstant 2: {"Key1": V1, "Key2": V2}
  0033    | ResolveUnboundVars
  0034  225 End
  ========================================
  
  ================record3=================
  0000  230 GetConstant 0: V1
  0002  231 GetConstant 1: V2
  0004  232 GetConstant 2: V3
  0006  230 GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 6
  0012    | Destructure
  0013    | TakeRight 13 -> 23
  0016  231 GetBoundLocal 3
  0018    | CallFunction 0
  0020    | GetLocal 7
  0022    | Destructure
  0023    | TakeRight 23 -> 39
  0026  232 GetBoundLocal 5
  0028    | CallFunction 0
  0030    | GetLocal 8
  0032    | Destructure
  0033    | TakeRight 33 -> 39
  0036  233 GetConstant 3: {"Key1": V1, "Key2": V2, "Key3": V3}
  0038    | ResolveUnboundVars
  0039  231 End
  ========================================
  
  ==============record3_sep===============
  0000  236 GetConstant 0: V1
  0002  237 GetConstant 1: V2
  0004  238 GetConstant 2: V3
  0006  236 GetBoundLocal 1
  0008    | CallFunction 0
  0010    | GetLocal 8
  0012    | Destructure
  0013    | TakeRight 13 -> 20
  0016    | GetBoundLocal 2
  0018    | CallFunction 0
  0020    | TakeRight 20 -> 30
  0023  237 GetBoundLocal 4
  0025    | CallFunction 0
  0027    | GetLocal 9
  0029    | Destructure
  0030    | TakeRight 30 -> 37
  0033    | GetBoundLocal 5
  0035    | CallFunction 0
  0037    | TakeRight 37 -> 53
  0040  238 GetBoundLocal 7
  0042    | CallFunction 0
  0044    | GetLocal 10
  0046    | Destructure
  0047    | TakeRight 47 -> 53
  0050  239 GetConstant 3: {"Key1": V1, "Key2": V2, "Key3": V3}
  0052    | ResolveUnboundVars
  0053  237 End
  ========================================

