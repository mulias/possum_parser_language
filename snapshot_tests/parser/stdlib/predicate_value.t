  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../../stdlib/predicate_value.possum -i '' --no-stdlib
  (DeclareGlobal 1:0-28
    (Function 1:0-12
      (Identifier 1:0-9 Is.String) [
        (Identifier 1:10-11 V)
      ])
    (Destructure 1:15-28
      (Identifier 1:15-16 V)
      (Merge 1:20-28
        (String 1:21-23 "")
        (Identifier 1:26-27 _))))
  
  (DeclareGlobal 3:0-27
    (Function 3:0-12
      (Identifier 3:0-9 Is.Number) [
        (Identifier 3:10-11 V)
      ])
    (Destructure 3:15-27
      (Identifier 3:15-16 V)
      (Merge 3:20-27
        (NumberString 3:21-22 0)
        (Identifier 3:25-26 _))))
  
  (DeclareGlobal 5:0-29
    (Function 5:0-10
      (Identifier 5:0-7 Is.Bool) [
        (Identifier 5:8-9 V)
      ])
    (Destructure 5:13-29
      (Identifier 5:13-14 V)
      (Merge 5:18-29
        (False 5:19-24)
        (Identifier 5:27-28 _))))
  
  (DeclareGlobal 7:0-22
    (Function 7:0-10
      (Identifier 7:0-7 Is.Null) [
        (Identifier 7:8-9 V)
      ])
    (Destructure 7:13-22
      (Identifier 7:13-14 V)
      (Null 7:18-22)))
  
  (DeclareGlobal 9:0-25
    (Function 9:0-11
      (Identifier 9:0-8 Is.Array) [
        (Identifier 9:9-10 V)
      ])
    (Destructure 9:14-25
      (Identifier 9:14-15 V)
      (Merge 9:19-25
        (Array 9:19-20 [])
        (Identifier 9:23-24 _))))
  
  (DeclareGlobal 11:0-26
    (Function 11:0-12
      (Identifier 11:0-9 Is.Object) [
        (Identifier 11:10-11 V)
      ])
    (Destructure 11:15-26
      (Identifier 11:15-16 V)
      (Merge 11:20-26
        (Object 11:20-21 [])
        (Identifier 11:24-25 _))))
  
  (DeclareGlobal 13:0-23
    (Function 13:0-14
      (Identifier 13:0-8 Is.Equal) [
        (Identifier 13:9-10 A)
        (Identifier 13:12-13 B)
      ])
    (Destructure 13:17-23
      (Identifier 13:17-18 A)
      (Identifier 13:22-23 B)))
  
  (DeclareGlobal 15:0-45
    (Function 15:0-17
      (Identifier 15:0-11 Is.LessThan) [
        (Identifier 15:12-13 A)
        (Identifier 15:15-16 B)
      ])
    (Conditional 15:20-45
      (Destructure 15:20-26
        (Identifier 15:20-21 A)
        (Identifier 15:25-26 B))
      (Identifier 15:29-34 @Fail)
      (Destructure 15:37-45
        (Identifier 15:37-38 A)
        (Range 15:42-45 () (Identifier 15:44-45 B)))))
  
  (DeclareGlobal 17:0-35
    (Function 17:0-24
      (Identifier 17:0-18 Is.LessThanOrEqual) [
        (Identifier 17:19-20 A)
        (Identifier 17:22-23 B)
      ])
    (Destructure 17:27-35
      (Identifier 17:27-28 A)
      (Range 17:32-35 () (Identifier 17:34-35 B))))
  
  (DeclareGlobal 19:0-48
    (Function 19:0-20
      (Identifier 19:0-14 Is.GreaterThan) [
        (Identifier 19:15-16 A)
        (Identifier 19:18-19 B)
      ])
    (Conditional 19:23-48
      (Destructure 19:23-29
        (Identifier 19:23-24 A)
        (Identifier 19:28-29 B))
      (Identifier 19:32-37 @Fail)
      (Destructure 19:40-48
        (Identifier 19:40-41 A)
        (Range 19:45-48 (Identifier 19:45-46 B) ()))))
  
  (DeclareGlobal 21:0-38
    (Function 21:0-27
      (Identifier 21:0-21 Is.GreaterThanOrEqual) [
        (Identifier 21:22-23 A)
        (Identifier 21:25-26 B)
      ])
    (Destructure 21:30-38
      (Identifier 21:30-31 A)
      (Range 21:35-38 (Identifier 21:35-36 B) ())))
