  $ export PRINT_AST=true RUN_VM=false

  $ possum $TESTDIR/../../stdlib/core.possum -i ''
  (DeclareGlobal 23-42
    (ParserVar 23-27 char)
    (Range 30-42 (String 30-40 _0) ()))
  (DeclareGlobal 44-74
    (ParserVar 44-49 ascii)
    (Range 52-74 (String 52-62 _0) (String 64-74 "\x7f"))) (esc)
  (DeclareGlobal 76-103
    (ParserVar 76-81 alpha)
    (Or 84-103
      (Range 84-92 (String 84-87 "a") (String 89-92 "z"))
      (Range 95-103 (String 95-98 "A") (String 100-103 "Z"))))
  (DeclareGlobal 105-125
    (ParserVar 105-111 alphas)
    (Function 114-125 (ParserVar 114-118 many) ((ParserVar 119-124 alpha))))
  (DeclareGlobal 127-143
    (ParserVar 127-132 lower)
    (Range 135-143 (String 135-138 "a") (String 140-143 "z")))
  (DeclareGlobal 145-165
    (ParserVar 145-151 lowers)
    (Function 154-165 (ParserVar 154-158 many) ((ParserVar 159-164 lower))))
  (DeclareGlobal 167-183
    (ParserVar 167-172 upper)
    (Range 175-183 (String 175-178 "A") (String 180-183 "Z")))
  (DeclareGlobal 185-205
    (ParserVar 185-191 uppers)
    (Function 194-205 (ParserVar 194-198 many) ((ParserVar 199-204 upper))))
  (DeclareGlobal 207-225
    (ParserVar 207-214 numeral)
    (Range 217-225 (String 217-220 "0") (String 222-225 "9")))
  (DeclareGlobal 227-251
    (ParserVar 227-235 numerals)
    (Function 238-251 (ParserVar 238-242 many) ((ParserVar 243-250 numeral))))
  (DeclareGlobal 253-279
    (ParserVar 253-267 binary_numeral)
    (Or 270-279
      (String 270-273 "0")
      (String 276-279 "1")))
  (DeclareGlobal 281-305
    (ParserVar 281-294 octal_numeral)
    (Range 297-305 (String 297-300 "0") (String 302-305 "7")))
  (DeclareGlobal 307-350
    (ParserVar 307-318 hex_numeral)
    (Or 321-350
      (ParserVar 321-328 numeral)
      (Or 331-350
        (Range 331-339 (String 331-334 "a") (String 336-339 "f"))
        (Range 342-350 (String 342-345 "A") (String 347-350 "F")))))
  (DeclareGlobal 352-375
    (ParserVar 352-357 alnum)
    (Or 360-375
      (ParserVar 360-365 alpha)
      (ParserVar 368-375 numeral)))
  (DeclareGlobal 377-397
    (ParserVar 377-383 alnums)
    (Function 386-397 (ParserVar 386-390 many) ((ParserVar 391-396 alnum))))
  (DeclareGlobal 399-437
    (ParserVar 399-404 token)
    (Function 407-437 (ParserVar 407-411 many) ((Function 412-436 (ParserVar 412-418 unless) ((ParserVar 419-423 char) (ParserVar 425-435 whitespace))))))
  (DeclareGlobal 439-469
    (ParserVar 439-443 word)
    (Function 446-469
      (ParserVar 446-450 many)
      ((Or 451-468
          (ParserVar 451-456 alnum)
          (Or 459-468
            (String 459-462 "_")
            (String 465-468 "-"))))))
  (DeclareGlobal 471-513
    (ParserVar 471-475 line)
    (Function 478-513
      (ParserVar 478-489 chars_until)
      ((Or 490-512
          (ParserVar 490-497 newline)
          (ParserVar 500-512 end_of_input)))))
  (DeclareGlobal 515-612
    (ParserVar 515-520 space)
    (Or 525-612
      (String 525-528 " ")
      (Or 531-612
        (String 531-535 "\t") (esc)
        (Or 538-612
          (String 538-548 "\xc2\xa0") (esc)
          (Or 551-612
            (Range 551-573 (String 551-561 "\xe2\x80\x80") (String 563-573 "\xe2\x80\x8a")) (esc)
            (Or 576-612
              (String 576-586 "\xe2\x80\xaf") (esc)
              (Or 589-612
                (String 589-599 "\xe2\x81\x9f") (esc)
                (String 602-612 "\xe3\x80\x80")))))))) (esc)
  (DeclareGlobal 614-634
    (ParserVar 614-620 spaces)
    (Function 623-634 (ParserVar 623-627 many) ((ParserVar 628-633 space))))
  (DeclareGlobal 636-716
    (ParserVar 636-643 newline)
    (Or 646-716
      (String 646-652 "\r (esc)
  ")
      (Or 655-716
        (Range 655-677 (String 655-665 "
  ") (String 667-677 "\r (no-eol) (esc)
  "))
        (Or 680-716
          (String 680-690 "\xc2\x85") (esc)
          (Or 693-716
            (String 693-703 "\xe2\x80\xa8") (esc)
            (String 706-716 "\xe2\x80\xa9")))))) (esc)
  (DeclareGlobal 718-730
    (ParserVar 718-720 nl)
    (ParserVar 723-730 newline))
  (DeclareGlobal 732-756
    (ParserVar 732-740 newlines)
    (Function 743-756 (ParserVar 743-747 many) ((ParserVar 748-755 newline))))
  (DeclareGlobal 758-772
    (ParserVar 758-761 nls)
    (ParserVar 764-772 newlines))
  (DeclareGlobal 774-808
    (ParserVar 774-784 whitespace)
    (Function 787-808
      (ParserVar 787-791 many)
      ((Or 792-807
          (ParserVar 792-797 space)
          (ParserVar 800-807 newline)))))
  (DeclareGlobal 810-825
    (ParserVar 810-812 ws)
    (ParserVar 815-825 whitespace))
  (DeclareGlobal 827-869
    (Function 827-844 (ParserVar 827-838 chars_until) ((ParserVar 839-843 stop)))
    (Function 847-869 (ParserVar 847-857 many_until) ((ParserVar 858-862 char) (ParserVar 864-868 stop))))
  (DeclareGlobal 883-895
    (ParserVar 883-888 digit)
    (Range 891-895 (NumberString 891-892 0) (NumberString 894-895 9)))
  (DeclareGlobal 897-951
    (ParserVar 897-904 integer)
    (Function 907-951
      (ParserVar 907-916 as_number)
      ((Merge 917-950
          (Function 917-927 (ParserVar 917-922 maybe) ((String 923-926 "-")))
          (ParserVar 930-950 _number_integer_part)))))
  (DeclareGlobal 953-966
    (ParserVar 953-956 int)
    (ParserVar 959-966 integer))
  (DeclareGlobal 968-1022
    (ParserVar 968-988 non_negative_integer)
    (Function 991-1022 (ParserVar 991-1000 as_number) ((ParserVar 1001-1021 _number_integer_part))))
  (DeclareGlobal 1024-1080
    (ParserVar 1024-1040 negative_integer)
    (Function 1043-1080
      (ParserVar 1043-1052 as_number)
      ((Merge 1053-1079
          (String 1053-1056 "-")
          (ParserVar 1059-1079 _number_integer_part)))))
  (DeclareGlobal 1082-1158
    (ParserVar 1082-1087 float)
    (Function 1090-1158
      (ParserVar 1090-1099 as_number)
      ((Merge 1100-1157
          (Merge 1100-1133
            (Function 1100-1110 (ParserVar 1100-1105 maybe) ((String 1106-1109 "-")))
            (ParserVar 1113-1133 _number_integer_part))
          (ParserVar 1136-1157 _number_fraction_part)))))
  (DeclareGlobal 1160-1257
    (ParserVar 1160-1178 scientific_integer)
    (Function 1181-1257
      (ParserVar 1181-1190 as_number)
      ((Merge 1194-1255
          (Merge 1194-1229
            (Function 1194-1204 (ParserVar 1194-1199 maybe) ((String 1200-1203 "-")))
            (ParserVar 1209-1229 _number_integer_part))
          (ParserVar 1234-1255 _number_exponent_part)))))
  (DeclareGlobal 1259-1380
    (ParserVar 1259-1275 scientific_float)
    (Function 1278-1380
      (ParserVar 1278-1287 as_number)
      ((Merge 1291-1378
          (Merge 1291-1352
            (Merge 1291-1326
              (Function 1291-1301 (ParserVar 1291-1296 maybe) ((String 1297-1300 "-")))
              (ParserVar 1306-1326 _number_integer_part))
            (ParserVar 1331-1352 _number_fraction_part))
          (ParserVar 1357-1378 _number_exponent_part)))))
  (DeclareGlobal 1382-1507
    (ParserVar 1382-1388 number)
    (Function 1391-1507
      (ParserVar 1391-1400 as_number)
      ((Merge 1404-1505
          (Merge 1404-1472
            (Merge 1404-1439
              (Function 1404-1414 (ParserVar 1404-1409 maybe) ((String 1410-1413 "-")))
              (ParserVar 1419-1439 _number_integer_part))
            (Function 1444-1472 (ParserVar 1444-1449 maybe) ((ParserVar 1450-1471 _number_fraction_part))))
          (Function 1477-1505 (ParserVar 1477-1482 maybe) ((ParserVar 1483-1504 _number_exponent_part)))))))
  (DeclareGlobal 1509-1521
    (ParserVar 1509-1512 num)
    (ParserVar 1515-1521 number))
  (DeclareGlobal 1523-1646
    (ParserVar 1523-1542 non_negative_number)
    (Function 1545-1646
      (ParserVar 1545-1554 as_number)
      ((Merge 1558-1644
          (Merge 1558-1611
            (ParserVar 1558-1578 _number_integer_part)
            (Function 1583-1611 (ParserVar 1583-1588 maybe) ((ParserVar 1589-1610 _number_fraction_part))))
          (Function 1616-1644 (ParserVar 1616-1621 maybe) ((ParserVar 1622-1643 _number_exponent_part)))))))
  (DeclareGlobal 1648-1775
    (ParserVar 1648-1663 negative_number)
    (Function 1666-1775
      (ParserVar 1666-1675 as_number)
      ((Merge 1679-1773
          (Merge 1679-1740
            (Merge 1679-1707
              (String 1679-1682 "-")
              (ParserVar 1687-1707 _number_integer_part))
            (Function 1712-1740 (ParserVar 1712-1717 maybe) ((ParserVar 1718-1739 _number_fraction_part))))
          (Function 1745-1773 (ParserVar 1745-1750 maybe) ((ParserVar 1751-1772 _number_exponent_part)))))))
  (DeclareGlobal 1777-1831
    (ParserVar 1777-1797 _number_integer_part)
    (Or 1800-1831
      (Merge 1800-1821
        (Range 1801-1809 (String 1801-1804 "1") (String 1806-1809 "9"))
        (ParserVar 1812-1820 numerals))
      (ParserVar 1824-1831 numeral)))
  (DeclareGlobal 1833-1871
    (ParserVar 1833-1854 _number_fraction_part)
    (Merge 1857-1871
      (String 1857-1860 ".")
      (ParserVar 1863-1871 numerals)))
  (DeclareGlobal 1873-1938
    (ParserVar 1873-1894 _number_exponent_part)
    (Merge 1897-1938
      (Merge 1897-1927
        (Or 1897-1908
          (String 1898-1901 "e")
          (String 1904-1907 "E"))
        (Function 1911-1927
          (ParserVar 1911-1916 maybe)
          ((Or 1917-1926
              (String 1917-1920 "-")
              (String 1923-1926 "+")))))
      (ParserVar 1930-1938 numerals)))
  (DeclareGlobal 1940-1959
    (ParserVar 1940-1952 binary_digit)
    (Range 1955-1959 (NumberString 1955-1956 0) (NumberString 1958-1959 1)))
  (DeclareGlobal 1961-1979
    (ParserVar 1961-1972 octal_digit)
    (Range 1975-1979 (NumberString 1975-1976 0) (NumberString 1978-1979 7)))
  (DeclareGlobal 1981-2126
    (ParserVar 1981-1990 hex_digit)
    (Or 1995-2126
      (ParserVar 1995-2000 digit)
      (Or 2005-2126
        (Return 2005-2021
          (Or 2006-2015
            (String 2006-2009 "a")
            (String 2012-2015 "A"))
          (NumberString 2018-2020 10))
        (Or 2026-2126
          (Return 2026-2042
            (Or 2027-2036
              (String 2027-2030 "b")
              (String 2033-2036 "B"))
            (NumberString 2039-2041 11))
          (Or 2047-2126
            (Return 2047-2063
              (Or 2048-2057
                (String 2048-2051 "c")
                (String 2054-2057 "C"))
              (NumberString 2060-2062 12))
            (Or 2068-2126
              (Return 2068-2084
                (Or 2069-2078
                  (String 2069-2072 "d")
                  (String 2075-2078 "D"))
                (NumberString 2081-2083 13))
              (Or 2089-2126
                (Return 2089-2105
                  (Or 2090-2099
                    (String 2090-2093 "e")
                    (String 2096-2099 "E"))
                  (NumberString 2102-2104 14))
                (Return 2110-2126
                  (Or 2111-2120
                    (String 2111-2114 "f")
                    (String 2117-2120 "F"))
                  (NumberString 2123-2125 15)))))))))
  (DeclareGlobal 2128-2205
    (ParserVar 2128-2142 binary_integer)
    (Return 2145-2205
      (Destructure 2145-2174
        (Function 2145-2164 (ParserVar 2145-2150 array) ((ParserVar 2151-2163 binary_digit)))
        (ValueVar 2168-2174 Digits))
      (Function 2177-2205 (ValueVar 2177-2197 Num.FromBinaryDigits) ((ValueVar 2198-2204 Digits)))))
  (DeclareGlobal 2207-2281
    (ParserVar 2207-2220 octal_integer)
    (Return 2223-2281
      (Destructure 2223-2251
        (Function 2223-2241 (ParserVar 2223-2228 array) ((ParserVar 2229-2240 octal_digit)))
        (ValueVar 2245-2251 Digits))
      (Function 2254-2281 (ValueVar 2254-2273 Num.FromOctalDigits) ((ValueVar 2274-2280 Digits)))))
  (DeclareGlobal 2283-2351
    (ParserVar 2283-2294 hex_integer)
    (Return 2297-2351
      (Destructure 2297-2323
        (Function 2297-2313 (ParserVar 2297-2302 array) ((ParserVar 2303-2312 hex_digit)))
        (ValueVar 2317-2323 Digits))
      (Function 2326-2351 (ValueVar 2326-2343 Num.FromHexDigits) ((ValueVar 2344-2350 Digits)))))
  (DeclareGlobal 2367-2385
    (Function 2367-2374 (Boolean 2367-2371 true) ((ParserVar 2372-2373 t)))
    (Return 2377-2385
      (ParserVar 2377-2378 t)
      (Boolean 2381-2385 true)))
  (DeclareGlobal 2387-2407
    (Function 2387-2395 (Boolean 2387-2392 false) ((ParserVar 2393-2394 f)))
    (Return 2398-2407
      (ParserVar 2398-2399 f)
      (Boolean 2402-2407 false)))
  (DeclareGlobal 2409-2443
    (Function 2409-2422 (ParserVar 2409-2416 boolean) ((ParserVar 2417-2418 t) (ParserVar 2420-2421 f)))
    (Or 2425-2443
      (Function 2425-2432 (Boolean 2425-2429 true) ((ParserVar 2430-2431 t)))
      (Function 2435-2443 (Boolean 2435-2440 false) ((ParserVar 2441-2442 f)))))
  (DeclareGlobal 2445-2459
    (ParserVar 2445-2449 bool)
    (ParserVar 2452-2459 boolean))
  (DeclareGlobal 2461-2479
    (Function 2461-2468 (Null 2461-2465 null) ((ParserVar 2466-2467 n)))
    (Return 2471-2479
      (ParserVar 2471-2472 n)
      (Null 2475-2479 null)))
  (DeclareGlobal 2491-2542
    (Function 2491-2502 (ParserVar 2491-2496 array) ((ParserVar 2497-2501 elem)))
    (TakeRight 2505-2542
      (Destructure 2505-2518
        (ParserVar 2505-2509 elem)
        (ValueVar 2513-2518 First))
      (Function 2521-2542 (ParserVar 2521-2527 _array) ((ParserVar 2528-2532 elem) (Array 2534-2541 ((ValueVar 2535-2540 First)))))))
  (DeclareGlobal 2544-2626
    (Function 2544-2561 (ParserVar 2544-2550 _array) ((ParserVar 2551-2555 elem) (ValueVar 2557-2560 Acc)))
    (Conditional 2566-2626
      (condition (Destructure 2566-2578
          (ParserVar 2566-2570 elem)
          (ValueVar 2574-2578 Elem)))
      (then (Function 2583-2611
          (ParserVar 2583-2589 _array)
          ((ParserVar 2590-2594 elem)
           (Merge 2600-2610
              (Merge 2600-2603
                (Array 2596-2597 ())
                (ValueVar 2600-2603 Acc))
              (Array 2605-2610 ((ValueVar 2605-2609 Elem)))))))
      (else (Function 2616-2626 (ParserVar 2616-2621 const) ((ValueVar 2622-2625 Acc))))))
  (DeclareGlobal 2628-2694
    (Function 2628-2648 (ParserVar 2628-2637 array_sep) ((ParserVar 2638-2642 elem) (ParserVar 2644-2647 sep)))
    (TakeRight 2651-2694
      (Destructure 2651-2664
        (ParserVar 2651-2655 elem)
        (ValueVar 2659-2664 First))
      (Function 2667-2694
        (ParserVar 2667-2673 _array)
        ((TakeRight 2674-2684
            (ParserVar 2674-2677 sep)
            (ParserVar 2680-2684 elem))
         (Array 2686-2693 ((ValueVar 2687-2692 First)))))))
  (DeclareGlobal 2696-2787
    (Function 2696-2719 (ParserVar 2696-2707 array_until) ((ParserVar 2708-2712 elem) (ParserVar 2714-2718 stop)))
    (TakeRight 2724-2787
      (Destructure 2724-2751
        (Function 2724-2742 (ParserVar 2724-2730 unless) ((ParserVar 2731-2735 elem) (ParserVar 2737-2741 stop)))
        (ValueVar 2746-2751 First))
      (Function 2754-2787
        (ParserVar 2754-2766 _array_until)
        ((ParserVar 2767-2771 elem)
         (ParserVar 2773-2777 stop)
         (Array 2779-2786 ((ValueVar 2780-2785 First)))))))
  (DeclareGlobal 2789-2908
    (Function 2789-2818
      (ParserVar 2789-2801 _array_until)
      ((ParserVar 2802-2806 elem)
       (ParserVar 2808-2812 stop)
       (ValueVar 2814-2817 Acc)))
    (Conditional 2823-2908
      (condition (Function 2823-2833 (ParserVar 2823-2827 peek) ((ParserVar 2828-2832 stop))))
      (then (Function 2838-2848 (ParserVar 2838-2843 const) ((ValueVar 2844-2847 Acc))))
      (else (TakeRight 2853-2908
          (Destructure 2853-2865
            (ParserVar 2853-2857 elem)
            (ValueVar 2861-2865 Elem))
          (Function 2868-2908
            (ParserVar 2868-2880 _array_until)
            ((ParserVar 2881-2885 elem)
             (ParserVar 2887-2891 stop)
             (Merge 2897-2907
                (Merge 2897-2900
                  (Array 2893-2894 ())
                  (ValueVar 2897-2900 Acc))
                (Array 2902-2907 ((ValueVar 2902-2906 Elem))))))))))
  (DeclareGlobal 2910-2954
    (Function 2910-2927 (ParserVar 2910-2921 maybe_array) ((ParserVar 2922-2926 elem)))
    (Function 2930-2954 (ParserVar 2930-2937 default) ((Function 2938-2949 (ParserVar 2938-2943 array) ((ParserVar 2944-2948 elem))) (Array 2951-2954 ()))))
  (DeclareGlobal 2956-3018
    (Function 2956-2982 (ParserVar 2956-2971 maybe_array_sep) ((ParserVar 2972-2976 elem) (ParserVar 2978-2981 sep)))
    (Function 2985-3018 (ParserVar 2985-2992 default) ((Function 2993-3013 (ParserVar 2993-3002 array_sep) ((ParserVar 3003-3007 elem) (ParserVar 3009-3012 sep))) (Array 3015-3018 ()))))
  (DeclareGlobal 3020-3057
    (Function 3020-3032 (ParserVar 3020-3026 tuple1) ((ParserVar 3027-3031 elem)))
    (Return 3036-3057
      (Destructure 3036-3048
        (ParserVar 3036-3040 elem)
        (ValueVar 3044-3048 Elem))
      (Array 3051-3057 ((ValueVar 3052-3056 Elem)))))
  (DeclareGlobal 3059-3118
    (Function 3059-3079 (ParserVar 3059-3065 tuple2) ((ParserVar 3066-3071 elem1) (ParserVar 3073-3078 elem2)))
    (TakeRight 3082-3118
      (Destructure 3082-3093
        (ParserVar 3082-3087 elem1)
        (ValueVar 3091-3093 E1))
      (Return 3096-3118
        (Destructure 3096-3107
          (ParserVar 3096-3101 elem2)
          (ValueVar 3105-3107 E2))
        (Array 3110-3118 ((ValueVar 3111-3113 E1) (ValueVar 3115-3117 E2))))))
  (DeclareGlobal 3120-3194
    (Function 3120-3149
      (ParserVar 3120-3130 tuple2_sep)
      ((ParserVar 3131-3136 elem1)
       (ParserVar 3138-3141 sep)
       (ParserVar 3143-3148 elem2)))
    (TakeRight 3152-3194
      (TakeRight 3152-3169
        (Destructure 3152-3163
          (ParserVar 3152-3157 elem1)
          (ValueVar 3161-3163 E1))
        (ParserVar 3166-3169 sep))
      (Return 3172-3194
        (Destructure 3172-3183
          (ParserVar 3172-3177 elem2)
          (ValueVar 3181-3183 E2))
        (Array 3186-3194 ((ValueVar 3187-3189 E1) (ValueVar 3191-3193 E2))))))
  (DeclareGlobal 3196-3288
    (Function 3196-3223
      (ParserVar 3196-3202 tuple3)
      ((ParserVar 3203-3208 elem1)
       (ParserVar 3210-3215 elem2)
       (ParserVar 3217-3222 elem3)))
    (TakeRight 3228-3288
      (TakeRight 3228-3255
        (Destructure 3228-3239
          (ParserVar 3228-3233 elem1)
          (ValueVar 3237-3239 E1))
        (Destructure 3244-3255
          (ParserVar 3244-3249 elem2)
          (ValueVar 3253-3255 E2)))
      (Return 3260-3288
        (Destructure 3260-3271
          (ParserVar 3260-3265 elem3)
          (ValueVar 3269-3271 E3))
        (Array 3276-3288 ((ValueVar 3277-3279 E1) (ValueVar 3281-3283 E2) (ValueVar 3285-3287 E3))))))
  (DeclareGlobal 3290-3412
    (Function 3290-3333
      (ParserVar 3290-3300 tuple3_sep)
      ((ParserVar 3301-3306 elem1)
       (ParserVar 3308-3312 sep1)
       (ParserVar 3314-3319 elem2)
       (ParserVar 3321-3325 sep2)
       (ParserVar 3327-3332 elem3)))
    (TakeRight 3338-3412
      (TakeRight 3338-3379
        (TakeRight 3338-3372
          (TakeRight 3338-3356
            (Destructure 3338-3349
              (ParserVar 3338-3343 elem1)
              (ValueVar 3347-3349 E1))
            (ParserVar 3352-3356 sep1))
          (Destructure 3361-3372
            (ParserVar 3361-3366 elem2)
            (ValueVar 3370-3372 E2)))
        (ParserVar 3375-3379 sep2))
      (Return 3384-3412
        (Destructure 3384-3395
          (ParserVar 3384-3389 elem3)
          (ValueVar 3393-3395 E3))
        (Array 3400-3412 ((ValueVar 3401-3403 E1) (ValueVar 3405-3407 E2) (ValueVar 3409-3411 E3))))))
  (DeclareGlobal 3414-3493
    (Function 3414-3428 (ParserVar 3414-3419 tuple) ((ParserVar 3420-3424 elem) (ValueVar 3426-3427 N)))
    (TakeRight 3433-3493
      (Function 3433-3469 (ParserVar 3433-3438 const) ((Function 3439-3468 (ValueVar 3439-3465 _Assert.NonNegativeInteger) ((ValueVar 3466-3467 N)))))
      (Function 3474-3493
        (ParserVar 3474-3480 _tuple)
        ((ParserVar 3481-3485 elem)
         (ValueVar 3487-3488 N)
         (Array 3490-3493 ())))))
  (DeclareGlobal 3495-3610
    (Function 3495-3515
      (ParserVar 3495-3501 _tuple)
      ((ParserVar 3502-3506 elem)
       (ValueVar 3508-3509 N)
       (ValueVar 3511-3514 Acc)))
    (Conditional 3520-3610
      (condition (Function 3520-3535
          (ParserVar 3520-3525 const)
          ((Destructure 3526-3534
              (ValueVar 3526-3527 N)
              (Range 3531-3534 () (NumberString 3533-3534 0))))))
      (then (Function 3540-3550 (ParserVar 3540-3545 const) ((ValueVar 3546-3549 Acc))))
      (else (TakeRight 3555-3610
          (Destructure 3555-3567
            (ParserVar 3555-3559 elem)
            (ValueVar 3563-3567 Elem))
          (Function 3570-3610
            (ParserVar 3570-3576 _tuple)
            ((ParserVar 3577-3581 elem)
             (Function 3583-3593 (ValueVar 3583-3590 Num.Dec) ((ValueVar 3591-3592 N)))
             (Merge 3599-3609
                (Merge 3599-3602
                  (Array 3595-3596 ())
                  (ValueVar 3599-3602 Acc))
                (Array 3604-3609 ((ValueVar 3604-3608 Elem))))))))))
  (DeclareGlobal 3612-3709
    (Function 3612-3635
      (ParserVar 3612-3621 tuple_sep)
      ((ParserVar 3622-3626 elem)
       (ParserVar 3628-3631 sep)
       (ValueVar 3633-3634 N)))
    (TakeRight 3640-3709
      (Function 3640-3676 (ParserVar 3640-3645 const) ((Function 3646-3675 (ValueVar 3646-3672 _Assert.NonNegativeInteger) ((ValueVar 3673-3674 N)))))
      (Function 3681-3709
        (ParserVar 3681-3691 _tuple_sep)
        ((ParserVar 3692-3696 elem)
         (ParserVar 3698-3701 sep)
         (ValueVar 3703-3704 N)
         (Array 3706-3709 ())))))
  (DeclareGlobal 3711-3850
    (Function 3711-3740
      (ParserVar 3711-3721 _tuple_sep)
      ((ParserVar 3722-3726 elem)
       (ParserVar 3728-3731 sep)
       (ValueVar 3733-3734 N)
       (ValueVar 3736-3739 Acc)))
    (Conditional 3745-3850
      (condition (Function 3745-3760
          (ParserVar 3745-3750 const)
          ((Destructure 3751-3759
              (ValueVar 3751-3752 N)
              (Range 3756-3759 () (NumberString 3758-3759 0))))))
      (then (Function 3765-3775 (ParserVar 3765-3770 const) ((ValueVar 3771-3774 Acc))))
      (else (TakeRight 3780-3850
          (Destructure 3780-3798
            (TakeRight 3780-3790
              (ParserVar 3780-3783 sep)
              (ParserVar 3786-3790 elem))
            (ValueVar 3794-3798 Elem))
          (Function 3801-3850
            (ParserVar 3801-3811 _tuple_sep)
            ((ParserVar 3812-3816 elem)
             (ParserVar 3818-3821 sep)
             (Function 3823-3833 (ValueVar 3823-3830 Num.Dec) ((ValueVar 3831-3832 N)))
             (Merge 3839-3849
                (Merge 3839-3842
                  (Array 3835-3836 ())
                  (ValueVar 3839-3842 Acc))
                (Array 3844-3849 ((ValueVar 3844-3848 Elem))))))))))
  (DeclareGlobal 3852-3943
    (Function 3852-3880
      (ParserVar 3852-3856 rows)
      ((ParserVar 3857-3861 elem)
       (ParserVar 3863-3870 col_sep)
       (ParserVar 3872-3879 row_sep)))
    (TakeRight 3885-3943
      (Destructure 3885-3898
        (ParserVar 3885-3889 elem)
        (ValueVar 3893-3898 First))
      (Function 3901-3943
        (ParserVar 3901-3906 _rows)
        ((ParserVar 3907-3911 elem)
         (ParserVar 3913-3920 col_sep)
         (ParserVar 3922-3929 row_sep)
         (Array 3931-3938 ((ValueVar 3932-3937 First)))
         (Array 3940-3943 ())))))
  (DeclareGlobal 3945-4209
    (Function 3945-3991
      (ParserVar 3945-3950 _rows)
      ((ParserVar 3951-3955 elem)
       (ParserVar 3957-3964 col_sep)
       (ParserVar 3966-3973 row_sep)
       (ValueVar 3975-3981 AccRow)
       (ValueVar 3983-3990 AccRows)))
    (Conditional 3996-4209
      (condition (Destructure 3996-4018
          (TakeRight 3996-4010
            (ParserVar 3996-4003 col_sep)
            (ParserVar 4006-4010 elem))
          (ValueVar 4014-4018 Elem)))
      (then (Function 4023-4080
          (ParserVar 4023-4028 _rows)
          ((ParserVar 4029-4033 elem)
           (ParserVar 4035-4042 col_sep)
           (ParserVar 4044-4051 row_sep)
           (Merge 4057-4070
              (Merge 4057-4063
                (Array 4053-4054 ())
                (ValueVar 4057-4063 AccRow))
              (Array 4065-4070 ((ValueVar 4065-4069 Elem))))
           (ValueVar 4072-4079 AccRows))))
      (else (Conditional 4085-4209
          (condition (Destructure 4085-4110
              (TakeRight 4085-4099
                (ParserVar 4085-4092 row_sep)
                (ParserVar 4095-4099 elem))
              (ValueVar 4103-4110 NextRow)))
          (then (Function 4115-4177
              (ParserVar 4115-4120 _rows)
              ((ParserVar 4121-4125 elem)
               (ParserVar 4127-4134 col_sep)
               (ParserVar 4136-4143 row_sep)
               (Array 4145-4154 ((ValueVar 4146-4153 NextRow)))
               (Merge 4160-4176
                  (Merge 4160-4167
                    (Array 4156-4157 ())
                    (ValueVar 4160-4167 AccRows))
                  (Array 4169-4176 ((ValueVar 4169-4175 AccRow)))))))
          (else (Function 4182-4209
              (ParserVar 4182-4187 const)
              ((Merge 4192-4208
                  (Merge 4192-4199
                    (Array 4188-4189 ())
                    (ValueVar 4192-4199 AccRows))
                  (Array 4201-4208 ((ValueVar 4201-4207 AccRow)))))))))))
  (DeclareGlobal 4211-4405
    (Function 4211-4251
      (ParserVar 4211-4222 rows_padded)
      ((ParserVar 4223-4227 elem)
       (ParserVar 4229-4236 col_sep)
       (ParserVar 4238-4245 row_sep)
       (ValueVar 4247-4250 Pad)))
    (TakeRight 4256-4405
      (TakeRight 4256-4333
        (Destructure 4256-4315
          (Function 4256-4297
            (ParserVar 4256-4260 peek)
            ((Function 4261-4296
                (ParserVar 4261-4272 _dimensions)
                ((ParserVar 4273-4277 elem)
                 (ParserVar 4279-4286 col_sep)
                 (ParserVar 4288-4295 row_sep)))))
          (Array 4301-4315 ((ValueVar 4302-4311 MaxRowLen) (ValueVar 4313-4314 _))))
        (Destructure 4320-4333
          (ParserVar 4320-4324 elem)
          (ValueVar 4328-4333 First)))
      (Function 4336-4405
        (ParserVar 4336-4348 _rows_padded)
        ((ParserVar 4349-4353 elem)
         (ParserVar 4355-4362 col_sep)
         (ParserVar 4364-4371 row_sep)
         (ValueVar 4373-4376 Pad)
         (ValueLabel 4378-4379 (NumberString 4379-4380 1))
         (ValueVar 4382-4391 MaxRowLen)
         (Array 4393-4400 ((ValueVar 4394-4399 First)))
         (Array 4402-4405 ())))))
  (DeclareGlobal 4407-4849
    (Function 4407-4484
      (ParserVar 4407-4419 _rows_padded)
      ((ParserVar 4420-4424 elem)
       (ParserVar 4426-4433 col_sep)
       (ParserVar 4435-4442 row_sep)
       (ValueVar 4444-4447 Pad)
       (ValueVar 4449-4455 RowLen)
       (ValueVar 4457-4466 MaxRowLen)
       (ValueVar 4468-4474 AccRow)
       (ValueVar 4476-4483 AccRows)))
    (Conditional 4489-4849
      (condition (Destructure 4489-4511
          (TakeRight 4489-4503
            (ParserVar 4489-4496 col_sep)
            (ParserVar 4499-4503 elem))
          (ValueVar 4507-4511 Elem)))
      (then (Function 4516-4613
          (ParserVar 4516-4528 _rows_padded)
          ((ParserVar 4529-4533 elem)
           (ParserVar 4535-4542 col_sep)
           (ParserVar 4544-4551 row_sep)
           (ValueVar 4553-4556 Pad)
           (Function 4558-4573 (ValueVar 4558-4565 Num.Inc) ((ValueVar 4566-4572 RowLen)))
           (ValueVar 4575-4584 MaxRowLen)
           (Merge 4590-4603
              (Merge 4590-4596
                (Array 4586-4587 ())
                (ValueVar 4590-4596 AccRow))
              (Array 4598-4603 ((ValueVar 4598-4602 Elem))))
           (ValueVar 4605-4612 AccRows))))
      (else (Conditional 4618-4849
          (condition (Destructure 4618-4643
              (TakeRight 4618-4632
                (ParserVar 4618-4625 row_sep)
                (ParserVar 4628-4632 elem))
              (ValueVar 4636-4643 NextRow)))
          (then (Function 4648-4777
              (ParserVar 4648-4660 _rows_padded)
              ((ParserVar 4661-4665 elem)
               (ParserVar 4667-4674 col_sep)
               (ParserVar 4676-4683 row_sep)
               (ValueVar 4685-4688 Pad)
               (ValueLabel 4690-4691 (NumberString 4691-4692 1))
               (ValueVar 4694-4703 MaxRowLen)
               (Array 4705-4714 ((ValueVar 4706-4713 NextRow)))
               (Merge 4720-4776
                  (Merge 4720-4727
                    (Array 4716-4717 ())
                    (ValueVar 4720-4727 AccRows))
                  (Array 4729-4776 (
                    (Function 4729-4775
                      (ValueVar 4729-4742 Array.AppendN)
                      ((ValueVar 4743-4749 AccRow)
                       (ValueVar 4751-4754 Pad)
                       (Merge 4756-4774
                          (ValueVar 4756-4765 MaxRowLen)
                          (Negation 4768-4774 (ValueVar 4768-4774 RowLen)))))
                  ))))))
          (else (Function 4782-4849
              (ParserVar 4782-4787 const)
              ((Merge 4792-4848
                  (Merge 4792-4799
                    (Array 4788-4789 ())
                    (ValueVar 4792-4799 AccRows))
                  (Array 4801-4848 (
                    (Function 4801-4847
                      (ValueVar 4801-4814 Array.AppendN)
                      ((ValueVar 4815-4821 AccRow)
                       (ValueVar 4823-4826 Pad)
                       (Merge 4828-4846
                          (ValueVar 4828-4837 MaxRowLen)
                          (Negation 4840-4846 (ValueVar 4840-4846 RowLen)))))
                  ))))))))))
  (DeclareGlobal 4851-4946
    (Function 4851-4886
      (ParserVar 4851-4862 _dimensions)
      ((ParserVar 4863-4867 elem)
       (ParserVar 4869-4876 col_sep)
       (ParserVar 4878-4885 row_sep)))
    (TakeRight 4891-4946
      (ParserVar 4891-4895 elem)
      (Function 4898-4946
        (ParserVar 4898-4910 __dimensions)
        ((ParserVar 4911-4915 elem)
         (ParserVar 4917-4924 col_sep)
         (ParserVar 4926-4933 row_sep)
         (ValueLabel 4935-4936 (NumberString 4936-4937 1))
         (ValueLabel 4939-4940 (NumberString 4940-4941 1))
         (ValueLabel 4943-4944 (NumberString 4944-4945 0))))))
  (DeclareGlobal 4948-5264
    (Function 4948-5011
      (ParserVar 4948-4960 __dimensions)
      ((ParserVar 4961-4965 elem)
       (ParserVar 4967-4974 col_sep)
       (ParserVar 4976-4983 row_sep)
       (ValueVar 4985-4991 RowLen)
       (ValueVar 4993-4999 ColLen)
       (ValueVar 5001-5010 MaxRowLen)))
    (Conditional 5016-5264
      (condition (TakeRight 5016-5030
          (ParserVar 5016-5023 col_sep)
          (ParserVar 5026-5030 elem)))
      (then (Function 5035-5107
          (ParserVar 5035-5047 __dimensions)
          ((ParserVar 5048-5052 elem)
           (ParserVar 5054-5061 col_sep)
           (ParserVar 5063-5070 row_sep)
           (Function 5072-5087 (ValueVar 5072-5079 Num.Inc) ((ValueVar 5080-5086 RowLen)))
           (ValueVar 5089-5095 ColLen)
           (ValueVar 5097-5106 MaxRowLen))))
      (else (Conditional 5112-5264
          (condition (TakeRight 5112-5126
              (ParserVar 5112-5119 row_sep)
              (ParserVar 5122-5126 elem)))
          (then (Function 5131-5216
              (ParserVar 5131-5143 __dimensions)
              ((ParserVar 5144-5148 elem)
               (ParserVar 5150-5157 col_sep)
               (ParserVar 5159-5166 row_sep)
               (ValueLabel 5168-5169 (NumberString 5169-5170 1))
               (Function 5172-5187 (ValueVar 5172-5179 Num.Inc) ((ValueVar 5180-5186 ColLen)))
               (Function 5189-5215 (ValueVar 5189-5196 Num.Max) ((ValueVar 5197-5203 RowLen) (ValueVar 5205-5214 MaxRowLen))))))
          (else (Function 5221-5264 (ParserVar 5221-5226 const) ((Array 5227-5263 ((Function 5228-5254 (ValueVar 5228-5235 Num.Max) ((ValueVar 5236-5242 RowLen) (ValueVar 5244-5253 MaxRowLen))) (ValueVar 5256-5262 ColLen))))))))))
  (DeclareGlobal 5266-5364
    (Function 5266-5297
      (ParserVar 5266-5273 columns)
      ((ParserVar 5274-5278 elem)
       (ParserVar 5280-5287 col_sep)
       (ParserVar 5289-5296 row_sep)))
    (Return 5302-5364
      (Destructure 5302-5338
        (Function 5302-5330
          (ParserVar 5302-5306 rows)
          ((ParserVar 5307-5311 elem)
           (ParserVar 5313-5320 col_sep)
           (ParserVar 5322-5329 row_sep)))
        (ValueVar 5334-5338 Rows))
      (Function 5343-5364 (ValueVar 5343-5358 Table.Transpose) ((ValueVar 5359-5363 Rows)))))
  (DeclareGlobal 5366-5380
    (ParserVar 5366-5370 cols)
    (ParserVar 5373-5380 columns))
  (DeclareGlobal 5382-5504
    (Function 5382-5425
      (ParserVar 5382-5396 columns_padded)
      ((ParserVar 5397-5401 elem)
       (ParserVar 5403-5410 col_sep)
       (ParserVar 5412-5419 row_sep)
       (ValueVar 5421-5424 Pad)))
    (Return 5430-5504
      (Destructure 5430-5478
        (Function 5430-5470
          (ParserVar 5430-5441 rows_padded)
          ((ParserVar 5442-5446 elem)
           (ParserVar 5448-5455 col_sep)
           (ParserVar 5457-5464 row_sep)
           (ValueVar 5466-5469 Pad)))
        (ValueVar 5474-5478 Rows))
      (Function 5483-5504 (ValueVar 5483-5498 Table.Transpose) ((ValueVar 5499-5503 Rows)))))
  (DeclareGlobal 5506-5534
    (ParserVar 5506-5517 cols_padded)
    (ParserVar 5520-5534 columns_padded))
  (DeclareGlobal 5548-5624
    (Function 5548-5566 (ParserVar 5548-5554 object) ((ParserVar 5555-5558 key) (ParserVar 5560-5565 value)))
    (TakeRight 5571-5624
      (TakeRight 5571-5592
        (Destructure 5571-5579
          (ParserVar 5571-5574 key)
          (ValueVar 5578-5579 K))
        (Destructure 5582-5592
          (ParserVar 5582-5587 value)
          (ValueVar 5591-5592 V)))
      (Function 5597-5624
        (ParserVar 5597-5604 _object)
        ((ParserVar 5605-5608 key)
         (ParserVar 5610-5615 value)
         (Object 5617-5623
            ((ValueVar 5618-5619 K) (ValueVar 5621-5622 V)))))))
  (DeclareGlobal 5626-5731
    (Function 5626-5650
      (ParserVar 5626-5633 _object)
      ((ParserVar 5634-5637 key)
       (ParserVar 5639-5644 value)
       (ValueVar 5646-5649 Acc)))
    (Conditional 5655-5731
      (condition (TakeRight 5655-5676
          (Destructure 5655-5663
            (ParserVar 5655-5658 key)
            (ValueVar 5662-5663 K))
          (Destructure 5666-5676
            (ParserVar 5666-5671 value)
            (ValueVar 5675-5676 V))))
      (then (Function 5681-5716
          (ParserVar 5681-5688 _object)
          ((ParserVar 5689-5692 key)
           (ParserVar 5694-5699 value)
           (Merge 5705-5715
              (Merge 5705-5708
                (Object 5701-5702)
                (ValueVar 5705-5708 Acc))
              (Object 5710-5715
                ((ValueVar 5710-5711 K) (ValueVar 5713-5714 V)))))))
      (else (Function 5721-5731 (ParserVar 5721-5726 const) ((ValueVar 5727-5730 Acc))))))
  (DeclareGlobal 5733-5856
    (Function 5733-5770
      (ParserVar 5733-5743 object_sep)
      ((ParserVar 5744-5747 key)
       (ParserVar 5749-5757 pair_sep)
       (ParserVar 5759-5764 value)
       (ParserVar 5766-5769 sep)))
    (TakeRight 5775-5856
      (TakeRight 5775-5807
        (TakeRight 5775-5794
          (Destructure 5775-5783
            (ParserVar 5775-5778 key)
            (ValueVar 5782-5783 K))
          (ParserVar 5786-5794 pair_sep))
        (Destructure 5797-5807
          (ParserVar 5797-5802 value)
          (ValueVar 5806-5807 V)))
      (Function 5812-5856
        (ParserVar 5812-5819 _object)
        ((TakeRight 5820-5829
            (ParserVar 5820-5823 sep)
            (ParserVar 5826-5829 key))
         (TakeRight 5831-5847
            (ParserVar 5831-5839 pair_sep)
            (ParserVar 5842-5847 value))
         (Object 5849-5855
            ((ValueVar 5850-5851 K) (ValueVar 5853-5854 V)))))))
  (DeclareGlobal 5858-5974
    (Function 5858-5888
      (ParserVar 5858-5870 object_until)
      ((ParserVar 5871-5874 key)
       (ParserVar 5876-5881 value)
       (ParserVar 5883-5887 stop)))
    (TakeRight 5893-5974
      (TakeRight 5893-5930
        (Destructure 5893-5915
          (Function 5893-5910 (ParserVar 5893-5899 unless) ((ParserVar 5900-5903 key) (ParserVar 5905-5909 stop)))
          (ValueVar 5914-5915 K))
        (Destructure 5920-5930
          (ParserVar 5920-5925 value)
          (ValueVar 5929-5930 V)))
      (Function 5935-5974
        (ParserVar 5935-5948 _object_until)
        ((ParserVar 5949-5952 key)
         (ParserVar 5954-5959 value)
         (ParserVar 5961-5965 stop)
         (Object 5967-5973
            ((ValueVar 5968-5969 K) (ValueVar 5971-5972 V)))))))
  (DeclareGlobal 5976-6118
    (Function 5976-6012
      (ParserVar 5976-5989 _object_until)
      ((ParserVar 5990-5993 key)
       (ParserVar 5995-6000 value)
       (ParserVar 6002-6006 stop)
       (ValueVar 6008-6011 Acc)))
    (Conditional 6017-6118
      (condition (Function 6017-6027 (ParserVar 6017-6021 peek) ((ParserVar 6022-6026 stop))))
      (then (Function 6032-6042 (ParserVar 6032-6037 const) ((ValueVar 6038-6041 Acc))))
      (else (TakeRight 6047-6118
          (TakeRight 6047-6068
            (Destructure 6047-6055
              (ParserVar 6047-6050 key)
              (ValueVar 6054-6055 K))
            (Destructure 6058-6068
              (ParserVar 6058-6063 value)
              (ValueVar 6067-6068 V)))
          (Function 6071-6118
            (ParserVar 6071-6084 _object_until)
            ((ParserVar 6085-6088 key)
             (ParserVar 6090-6095 value)
             (ParserVar 6097-6101 stop)
             (Merge 6107-6117
                (Merge 6107-6110
                  (Object 6103-6104)
                  (ValueVar 6107-6110 Acc))
                (Object 6112-6117
                  ((ValueVar 6112-6113 K) (ValueVar 6115-6116 V))))))))))
  (DeclareGlobal 6120-6178
    (Function 6120-6144 (ParserVar 6120-6132 maybe_object) ((ParserVar 6133-6136 key) (ParserVar 6138-6143 value)))
    (Function 6147-6178 (ParserVar 6147-6154 default) ((Function 6155-6173 (ParserVar 6155-6161 object) ((ParserVar 6162-6165 key) (ParserVar 6167-6172 value))) (Object 6175-6178))))
  (DeclareGlobal 6180-6278
    (Function 6180-6223
      (ParserVar 6180-6196 maybe_object_sep)
      ((ParserVar 6197-6200 key)
       (ParserVar 6202-6210 pair_sep)
       (ParserVar 6212-6217 value)
       (ParserVar 6219-6222 sep)))
    (Function 6228-6278
      (ParserVar 6228-6235 default)
      ((Function 6236-6273
          (ParserVar 6236-6246 object_sep)
          ((ParserVar 6247-6250 key)
           (ParserVar 6252-6260 pair_sep)
           (ParserVar 6262-6267 value)
           (ParserVar 6269-6272 sep)))
       (Object 6275-6278))))
  (DeclareGlobal 6280-6329
    (Function 6280-6296 (ParserVar 6280-6284 pair) ((ParserVar 6285-6288 key) (ParserVar 6290-6295 value)))
    (TakeRight 6299-6329
      (Destructure 6299-6307
        (ParserVar 6299-6302 key)
        (ValueVar 6306-6307 K))
      (Return 6310-6329
        (Destructure 6310-6320
          (ParserVar 6310-6315 value)
          (ValueVar 6319-6320 V))
        (Object 6323-6329
          ((ValueVar 6324-6325 K) (ValueVar 6327-6328 V))))))
  (DeclareGlobal 6331-6395
    (Function 6331-6356
      (ParserVar 6331-6339 pair_sep)
      ((ParserVar 6340-6343 key)
       (ParserVar 6345-6348 sep)
       (ParserVar 6350-6355 value)))
    (TakeRight 6359-6395
      (TakeRight 6359-6373
        (Destructure 6359-6367
          (ParserVar 6359-6362 key)
          (ValueVar 6366-6367 K))
        (ParserVar 6370-6373 sep))
      (Return 6376-6395
        (Destructure 6376-6386
          (ParserVar 6376-6381 value)
          (ValueVar 6385-6386 V))
        (Object 6389-6395
          ((ValueVar 6390-6391 K) (ValueVar 6393-6394 V))))))
  (DeclareGlobal 6397-6448
    (Function 6397-6416 (ParserVar 6397-6404 record1) ((ValueVar 6405-6408 Key) (ParserVar 6410-6415 value)))
    (Return 6419-6448
      (Destructure 6419-6433
        (ParserVar 6419-6424 value)
        (ValueVar 6428-6433 Value))
      (Object 6436-6448
        ((ValueVar 6437-6440 Key) (ValueVar 6442-6447 Value)))))
  (DeclareGlobal 6450-6544
    (Function 6450-6485
      (ParserVar 6450-6457 record2)
      ((ValueVar 6458-6462 Key1)
       (ParserVar 6464-6470 value1)
       (ValueVar 6472-6476 Key2)
       (ParserVar 6478-6484 value2)))
    (TakeRight 6490-6544
      (Destructure 6490-6502
        (ParserVar 6490-6496 value1)
        (ValueVar 6500-6502 V1))
      (Return 6507-6544
        (Destructure 6507-6519
          (ParserVar 6507-6513 value2)
          (ValueVar 6517-6519 V2))
        (Object 6524-6544
          ((ValueVar 6525-6529 Key1) (ValueVar 6531-6533 V1))
          ((ValueVar 6535-6539 Key2) (ValueVar 6541-6543 V2))))))
  (DeclareGlobal 6546-6655
    (Function 6546-6590
      (ParserVar 6546-6557 record2_sep)
      ((ValueVar 6558-6562 Key1)
       (ParserVar 6564-6570 value1)
       (ParserVar 6572-6575 sep)
       (ValueVar 6577-6581 Key2)
       (ParserVar 6583-6589 value2)))
    (TakeRight 6595-6655
      (TakeRight 6595-6613
        (Destructure 6595-6607
          (ParserVar 6595-6601 value1)
          (ValueVar 6605-6607 V1))
        (ParserVar 6610-6613 sep))
      (Return 6618-6655
        (Destructure 6618-6630
          (ParserVar 6618-6624 value2)
          (ValueVar 6628-6630 V2))
        (Object 6635-6655
          ((ValueVar 6636-6640 Key1) (ValueVar 6642-6644 V1))
          ((ValueVar 6646-6650 Key2) (ValueVar 6652-6654 V2))))))
  (DeclareGlobal 6657-6792
    (Function 6657-6706
      (ParserVar 6657-6664 record3)
      ((ValueVar 6665-6669 Key1)
       (ParserVar 6671-6677 value1)
       (ValueVar 6679-6683 Key2)
       (ParserVar 6685-6691 value2)
       (ValueVar 6693-6697 Key3)
       (ParserVar 6699-6705 value3)))
    (TakeRight 6711-6792
      (TakeRight 6711-6740
        (Destructure 6711-6723
          (ParserVar 6711-6717 value1)
          (ValueVar 6721-6723 V1))
        (Destructure 6728-6740
          (ParserVar 6728-6734 value2)
          (ValueVar 6738-6740 V2)))
      (Return 6745-6792
        (Destructure 6745-6757
          (ParserVar 6745-6751 value3)
          (ValueVar 6755-6757 V3))
        (Object 6762-6792
          ((ValueVar 6763-6767 Key1) (ValueVar 6769-6771 V1))
          ((ValueVar 6773-6777 Key2) (ValueVar 6779-6781 V2))
          ((ValueVar 6783-6787 Key3) (ValueVar 6789-6791 V3))))))
  (DeclareGlobal 6794-6959
    (Function 6794-6859
      (ParserVar 6794-6805 record3_sep)
      ((ValueVar 6806-6810 Key1)
       (ParserVar 6812-6818 value1)
       (ParserVar 6820-6824 sep1)
       (ValueVar 6826-6830 Key2)
       (ParserVar 6832-6838 value2)
       (ParserVar 6840-6844 sep2)
       (ValueVar 6846-6850 Key3)
       (ParserVar 6852-6858 value3)))
    (TakeRight 6864-6959
      (TakeRight 6864-6907
        (TakeRight 6864-6900
          (TakeRight 6864-6883
            (Destructure 6864-6876
              (ParserVar 6864-6870 value1)
              (ValueVar 6874-6876 V1))
            (ParserVar 6879-6883 sep1))
          (Destructure 6888-6900
            (ParserVar 6888-6894 value2)
            (ValueVar 6898-6900 V2)))
        (ParserVar 6903-6907 sep2))
      (Return 6912-6959
        (Destructure 6912-6924
          (ParserVar 6912-6918 value3)
          (ValueVar 6922-6924 V3))
        (Object 6929-6959
          ((ValueVar 6930-6934 Key1) (ValueVar 6936-6938 V1))
          ((ValueVar 6940-6944 Key2) (ValueVar 6946-6948 V2))
          ((ValueVar 6950-6954 Key3) (ValueVar 6956-6958 V3))))))
  (DeclareGlobal 6974-7012
    (Function 6974-6981 (ParserVar 6974-6978 many) ((ParserVar 6979-6980 p)))
    (TakeRight 6984-7012
      (Destructure 6984-6994
        (ParserVar 6984-6985 p)
        (ValueVar 6989-6994 First))
      (Function 6997-7012 (ParserVar 6997-7002 _many) ((ParserVar 7003-7004 p) (ValueVar 7006-7011 First)))))
  (DeclareGlobal 7014-7075
    (Function 7014-7027 (ParserVar 7014-7019 _many) ((ParserVar 7020-7021 p) (ValueVar 7023-7026 Acc)))
    (Conditional 7030-7075
      (condition (Destructure 7030-7039
          (ParserVar 7030-7031 p)
          (ValueVar 7035-7039 Next)))
      (then (Function 7042-7062
          (ParserVar 7042-7047 _many)
          ((ParserVar 7048-7049 p)
           (Merge 7051-7061
              (ValueVar 7051-7054 Acc)
              (ValueVar 7057-7061 Next)))))
      (else (Function 7065-7075 (ParserVar 7065-7070 const) ((ValueVar 7071-7074 Acc))))))
  (DeclareGlobal 7077-7130
    (Function 7077-7093 (ParserVar 7077-7085 many_sep) ((ParserVar 7086-7087 p) (ParserVar 7089-7092 sep)))
    (TakeRight 7096-7130
      (Destructure 7096-7106
        (ParserVar 7096-7097 p)
        (ValueVar 7101-7106 First))
      (Function 7109-7130
        (ParserVar 7109-7114 _many)
        ((TakeRight 7115-7122
            (ParserVar 7115-7118 sep)
            (ParserVar 7121-7122 p))
         (ValueVar 7124-7129 First)))))
  (DeclareGlobal 7132-7208
    (Function 7132-7151 (ParserVar 7132-7142 many_until) ((ParserVar 7143-7144 p) (ParserVar 7146-7150 stop)))
    (TakeRight 7154-7208
      (Destructure 7154-7178
        (Function 7154-7169 (ParserVar 7154-7160 unless) ((ParserVar 7161-7162 p) (ParserVar 7164-7168 stop)))
        (ValueVar 7173-7178 First))
      (Function 7181-7208
        (ParserVar 7181-7192 _many_until)
        ((ParserVar 7193-7194 p)
         (ParserVar 7196-7200 stop)
         (ValueVar 7202-7207 First)))))
  (DeclareGlobal 7210-7314
    (Function 7210-7235
      (ParserVar 7210-7221 _many_until)
      ((ParserVar 7222-7223 p)
       (ParserVar 7225-7229 stop)
       (ValueVar 7231-7234 Acc)))
    (Conditional 7240-7314
      (condition (Function 7240-7250 (ParserVar 7240-7244 peek) ((ParserVar 7245-7249 stop))))
      (then (Function 7255-7265 (ParserVar 7255-7260 const) ((ValueVar 7261-7264 Acc))))
      (else (TakeRight 7270-7314
          (Destructure 7270-7279
            (ParserVar 7270-7271 p)
            (ValueVar 7275-7279 Next))
          (Function 7282-7314
            (ParserVar 7282-7293 _many_until)
            ((ParserVar 7294-7295 p)
             (ParserVar 7297-7301 stop)
             (Merge 7303-7313
                (ValueVar 7303-7306 Acc)
                (ValueVar 7309-7313 Next))))))))
  (DeclareGlobal 7316-7349
    (Function 7316-7329 (ParserVar 7316-7326 maybe_many) ((ParserVar 7327-7328 p)))
    (Or 7332-7349
      (Function 7332-7339 (ParserVar 7332-7336 many) ((ParserVar 7337-7338 p)))
      (ParserVar 7342-7349 succeed)))
  (DeclareGlobal 7351-7402
    (Function 7351-7373 (ParserVar 7351-7365 maybe_many_sep) ((ParserVar 7366-7367 p) (ParserVar 7369-7372 sep)))
    (Or 7376-7402
      (Function 7376-7392 (ParserVar 7376-7384 many_sep) ((ParserVar 7385-7386 p) (ParserVar 7388-7391 sep)))
      (ParserVar 7395-7402 succeed)))
  (DeclareGlobal 7404-7422
    (Function 7404-7414 (ParserVar 7404-7411 repeat2) ((ParserVar 7412-7413 p)))
    (Merge 7417-7422
      (ParserVar 7417-7418 p)
      (ParserVar 7421-7422 p)))
  (DeclareGlobal 7424-7446
    (Function 7424-7434 (ParserVar 7424-7431 repeat3) ((ParserVar 7432-7433 p)))
    (Merge 7437-7446
      (Merge 7437-7442
        (ParserVar 7437-7438 p)
        (ParserVar 7441-7442 p))
      (ParserVar 7445-7446 p)))
  (DeclareGlobal 7448-7474
    (Function 7448-7458 (ParserVar 7448-7455 repeat4) ((ParserVar 7456-7457 p)))
    (Merge 7461-7474
      (Merge 7461-7470
        (Merge 7461-7466
          (ParserVar 7461-7462 p)
          (ParserVar 7465-7466 p))
        (ParserVar 7469-7470 p))
      (ParserVar 7473-7474 p)))
  (DeclareGlobal 7476-7506
    (Function 7476-7486 (ParserVar 7476-7483 repeat5) ((ParserVar 7484-7485 p)))
    (Merge 7489-7506
      (Merge 7489-7502
        (Merge 7489-7498
          (Merge 7489-7494
            (ParserVar 7489-7490 p)
            (ParserVar 7493-7494 p))
          (ParserVar 7497-7498 p))
        (ParserVar 7501-7502 p))
      (ParserVar 7505-7506 p)))
  (DeclareGlobal 7508-7542
    (Function 7508-7518 (ParserVar 7508-7515 repeat6) ((ParserVar 7516-7517 p)))
    (Merge 7521-7542
      (Merge 7521-7538
        (Merge 7521-7534
          (Merge 7521-7530
            (Merge 7521-7526
              (ParserVar 7521-7522 p)
              (ParserVar 7525-7526 p))
            (ParserVar 7529-7530 p))
          (ParserVar 7533-7534 p))
        (ParserVar 7537-7538 p))
      (ParserVar 7541-7542 p)))
  (DeclareGlobal 7544-7582
    (Function 7544-7554 (ParserVar 7544-7551 repeat7) ((ParserVar 7552-7553 p)))
    (Merge 7557-7582
      (Merge 7557-7578
        (Merge 7557-7574
          (Merge 7557-7570
            (Merge 7557-7566
              (Merge 7557-7562
                (ParserVar 7557-7558 p)
                (ParserVar 7561-7562 p))
              (ParserVar 7565-7566 p))
            (ParserVar 7569-7570 p))
          (ParserVar 7573-7574 p))
        (ParserVar 7577-7578 p))
      (ParserVar 7581-7582 p)))
  (DeclareGlobal 7584-7626
    (Function 7584-7594 (ParserVar 7584-7591 repeat8) ((ParserVar 7592-7593 p)))
    (Merge 7597-7626
      (Merge 7597-7622
        (Merge 7597-7618
          (Merge 7597-7614
            (Merge 7597-7610
              (Merge 7597-7606
                (Merge 7597-7602
                  (ParserVar 7597-7598 p)
                  (ParserVar 7601-7602 p))
                (ParserVar 7605-7606 p))
              (ParserVar 7609-7610 p))
            (ParserVar 7613-7614 p))
          (ParserVar 7617-7618 p))
        (ParserVar 7621-7622 p))
      (ParserVar 7625-7626 p)))
  (DeclareGlobal 7628-7674
    (Function 7628-7638 (ParserVar 7628-7635 repeat9) ((ParserVar 7636-7637 p)))
    (Merge 7641-7674
      (Merge 7641-7670
        (Merge 7641-7666
          (Merge 7641-7662
            (Merge 7641-7658
              (Merge 7641-7654
                (Merge 7641-7650
                  (Merge 7641-7646
                    (ParserVar 7641-7642 p)
                    (ParserVar 7645-7646 p))
                  (ParserVar 7649-7650 p))
                (ParserVar 7653-7654 p))
              (ParserVar 7657-7658 p))
            (ParserVar 7661-7662 p))
          (ParserVar 7665-7666 p))
        (ParserVar 7669-7670 p))
      (ParserVar 7673-7674 p)))
  (DeclareGlobal 7676-7754
    (Function 7676-7688 (ParserVar 7676-7682 repeat) ((ParserVar 7683-7684 p) (ValueVar 7686-7687 N)))
    (TakeRight 7693-7754
      (Function 7693-7729 (ParserVar 7693-7698 const) ((Function 7699-7728 (ValueVar 7699-7725 _Assert.NonNegativeInteger) ((ValueVar 7726-7727 N)))))
      (Function 7734-7754
        (ParserVar 7734-7741 _repeat)
        ((ParserVar 7742-7743 p)
         (ValueVar 7745-7746 N)
         (ValueLabel 7748-7749 (Null 7749-7753 null))))))
  (DeclareGlobal 7756-7860
    (Function 7756-7774
      (ParserVar 7756-7763 _repeat)
      ((ParserVar 7764-7765 p)
       (ValueVar 7767-7768 N)
       (ValueVar 7770-7773 Acc)))
    (Conditional 7779-7860
      (condition (Function 7779-7794
          (ParserVar 7779-7784 const)
          ((Destructure 7785-7793
              (ValueVar 7785-7786 N)
              (Range 7790-7793 () (NumberString 7792-7793 0))))))
      (then (Function 7799-7809 (ParserVar 7799-7804 const) ((ValueVar 7805-7808 Acc))))
      (else (TakeRight 7814-7860
          (Destructure 7814-7823
            (ParserVar 7814-7815 p)
            (ValueVar 7819-7823 Next))
          (Function 7826-7860
            (ParserVar 7826-7833 _repeat)
            ((ParserVar 7834-7835 p)
             (Function 7837-7847 (ValueVar 7837-7844 Num.Dec) ((ValueVar 7845-7846 N)))
             (Merge 7849-7859
                (ValueVar 7849-7852 Acc)
                (ValueVar 7855-7859 Next))))))))
  (DeclareGlobal 7862-8003
    (Function 7862-7885
      (ParserVar 7862-7876 repeat_between)
      ((ParserVar 7877-7878 p)
       (ValueVar 7880-7881 N)
       (ValueVar 7883-7884 M)))
    (TakeRight 7890-8003
      (TakeRight 7890-7967
        (Function 7890-7926 (ParserVar 7890-7895 const) ((Function 7896-7925 (ValueVar 7896-7922 _Assert.NonNegativeInteger) ((ValueVar 7923-7924 N)))))
        (Function 7931-7967 (ParserVar 7931-7936 const) ((Function 7937-7966 (ValueVar 7937-7963 _Assert.NonNegativeInteger) ((ValueVar 7964-7965 M))))))
      (Function 7972-8003
        (ParserVar 7972-7987 _repeat_between)
        ((ParserVar 7988-7989 p)
         (ValueVar 7991-7992 N)
         (ValueVar 7994-7995 M)
         (ValueLabel 7997-7998 (Null 7998-8002 null))))))
  (DeclareGlobal 8005-8187
    (Function 8005-8034
      (ParserVar 8005-8020 _repeat_between)
      ((ParserVar 8021-8022 p)
       (ValueVar 8024-8025 N)
       (ValueVar 8027-8028 M)
       (ValueVar 8030-8033 Acc)))
    (Conditional 8039-8187
      (condition (Function 8039-8054
          (ParserVar 8039-8044 const)
          ((Destructure 8045-8053
              (ValueVar 8045-8046 M)
              (Range 8050-8053 () (NumberString 8052-8053 0))))))
      (then (Function 8059-8069 (ParserVar 8059-8064 const) ((ValueVar 8065-8068 Acc))))
      (else (Conditional 8074-8187
          (condition (Destructure 8074-8083
              (ParserVar 8074-8075 p)
              (ValueVar 8079-8083 Next)))
          (then (Function 8088-8142
              (ParserVar 8088-8103 _repeat_between)
              ((ParserVar 8104-8105 p)
               (Function 8107-8117 (ValueVar 8107-8114 Num.Dec) ((ValueVar 8115-8116 N)))
               (Function 8119-8129 (ValueVar 8119-8126 Num.Dec) ((ValueVar 8127-8128 M)))
               (Merge 8131-8141
                  (ValueVar 8131-8134 Acc)
                  (ValueVar 8137-8141 Next)))))
          (else (Conditional 8147-8187
              (condition (Function 8147-8162
                  (ParserVar 8147-8152 const)
                  ((Destructure 8153-8161
                      (ValueVar 8153-8154 N)
                      (Range 8158-8161 () (NumberString 8160-8161 0))))))
              (then (Function 8167-8177 (ParserVar 8167-8172 const) ((ValueVar 8173-8176 Acc))))
              (else (ParserVar 8182-8187 @fail))))))))
  (DeclareGlobal 8189-8240
    (Function 8189-8206 (ParserVar 8189-8200 one_or_both) ((ParserVar 8201-8202 a) (ParserVar 8204-8205 b)))
    (Or 8209-8240
      (Merge 8209-8223
        (ParserVar 8210-8211 a)
        (Function 8214-8222 (ParserVar 8214-8219 maybe) ((ParserVar 8220-8221 b))))
      (Merge 8226-8240
        (Function 8227-8235 (ParserVar 8227-8232 maybe) ((ParserVar 8233-8234 a)))
        (ParserVar 8238-8239 b))))
  (DeclareGlobal 8254-8281
    (Function 8254-8261 (ParserVar 8254-8258 peek) ((ParserVar 8259-8260 p)))
    (Backtrack 8264-8281
      (Destructure 8264-8270
        (ParserVar 8264-8265 p)
        (ValueVar 8269-8270 V))
      (Function 8273-8281 (ParserVar 8273-8278 const) ((ValueVar 8279-8280 V)))))
  (DeclareGlobal 8283-8305
    (Function 8283-8291 (ParserVar 8283-8288 maybe) ((ParserVar 8289-8290 p)))
    (Or 8294-8305
      (ParserVar 8294-8295 p)
      (ParserVar 8298-8305 succeed)))
  (DeclareGlobal 8307-8349
    (Function 8307-8326 (ParserVar 8307-8313 unless) ((ParserVar 8314-8315 p) (ParserVar 8317-8325 excluded)))
    (Conditional 8329-8349
      (condition (ParserVar 8329-8337 excluded))
      (then (ParserVar 8340-8345 @fail))
      (else (ParserVar 8348-8349 p))))
  (DeclareGlobal 8351-8368
    (Function 8351-8358 (ParserVar 8351-8355 skip) ((ParserVar 8356-8357 p)))
    (Function 8361-8368 (Null 8361-8365 null) ((ParserVar 8366-8367 p))))
  (DeclareGlobal 8370-8400
    (Function 8370-8377 (ParserVar 8370-8374 find) ((ParserVar 8375-8376 p)))
    (Or 8380-8400
      (ParserVar 8380-8381 p)
      (TakeRight 8384-8400
        (ParserVar 8385-8389 char)
        (Function 8392-8399 (ParserVar 8392-8396 find) ((ParserVar 8397-8398 p))))))
  (DeclareGlobal 8402-8450
    (Function 8402-8413 (ParserVar 8402-8410 find_all) ((ParserVar 8411-8412 p)))
    (TakeLeft 8416-8450
      (Function 8416-8430 (ParserVar 8416-8421 array) ((Function 8422-8429 (ParserVar 8422-8426 find) ((ParserVar 8427-8428 p)))))
      (Function 8433-8450 (ParserVar 8433-8438 maybe) ((Function 8439-8449 (ParserVar 8439-8443 many) ((ParserVar 8444-8448 char)))))))
  (DeclareGlobal 8452-8524
    (Function 8452-8472 (ParserVar 8452-8463 find_before) ((ParserVar 8464-8465 p) (ParserVar 8467-8471 stop)))
    (Conditional 8475-8524
      (condition (ParserVar 8475-8479 stop))
      (then (ParserVar 8482-8487 @fail))
      (else (Or 8491-8524
          (ParserVar 8491-8492 p)
          (TakeRight 8495-8524
            (ParserVar 8496-8500 char)
            (Function 8503-8523 (ParserVar 8503-8514 find_before) ((ParserVar 8515-8516 p) (ParserVar 8518-8522 stop))))))))
  (DeclareGlobal 8526-8607
    (Function 8526-8550 (ParserVar 8526-8541 find_all_before) ((ParserVar 8542-8543 p) (ParserVar 8545-8549 stop)))
    (TakeLeft 8553-8607
      (Function 8553-8580 (ParserVar 8553-8558 array) ((Function 8559-8579 (ParserVar 8559-8570 find_before) ((ParserVar 8571-8572 p) (ParserVar 8574-8578 stop)))))
      (Function 8583-8607 (ParserVar 8583-8588 maybe) ((Function 8589-8606 (ParserVar 8589-8600 chars_until) ((ParserVar 8601-8605 stop)))))))
  (DeclareGlobal 8609-8631
    (ParserVar 8609-8616 succeed)
    (Function 8619-8631 (ParserVar 8619-8624 const) ((ValueLabel 8625-8626 (Null 8626-8630 null)))))
  (DeclareGlobal 8633-8661
    (Function 8633-8646 (ParserVar 8633-8640 default) ((ParserVar 8641-8642 p) (ValueVar 8644-8645 D)))
    (Or 8649-8661
      (ParserVar 8649-8650 p)
      (Function 8653-8661 (ParserVar 8653-8658 const) ((ValueVar 8659-8660 D)))))
  (DeclareGlobal 8663-8680
    (Function 8663-8671 (ParserVar 8663-8668 const) ((ValueVar 8669-8670 C)))
    (Return 8674-8680
      (String 8674-8676 "")
      (ValueVar 8679-8680 C)))
  (DeclareGlobal 8682-8716
    (Function 8682-8694 (ParserVar 8682-8691 as_number) ((ParserVar 8692-8693 p)))
    (Return 8697-8716
      (Destructure 8697-8712
        (ParserVar 8697-8698 p)
        (StringTemplate 8702-8712 (Merge 8705-8710
          (NumberString 8705-8706 0)
          (ValueVar 8709-8710 N))))
      (ValueVar 8715-8716 N)))
  (DeclareGlobal 8718-8739
    (Function 8718-8730 (ParserVar 8718-8727 string_of) ((ParserVar 8728-8729 p)))
    (StringTemplate 8733-8739 (ParserVar 8736-8737 p)))
  (DeclareGlobal 8741-8776
    (Function 8741-8758 (ParserVar 8741-8749 surround) ((ParserVar 8750-8751 p) (ParserVar 8753-8757 fill)))
    (TakeLeft 8761-8776
      (TakeRight 8761-8769
        (ParserVar 8761-8765 fill)
        (ParserVar 8768-8769 p))
      (ParserVar 8772-8776 fill)))
  (DeclareGlobal 8778-8815
    (ParserVar 8778-8790 end_of_input)
    (Conditional 8793-8815
      (condition (ParserVar 8793-8797 char))
      (then (ParserVar 8800-8805 @fail))
      (else (ParserVar 8808-8815 succeed))))
  (DeclareGlobal 8817-8835
    (ParserVar 8817-8820 end)
    (ParserVar 8823-8835 end_of_input))
  (DeclareGlobal 8837-8893
    (Function 8837-8845 (ParserVar 8837-8842 input) ((ParserVar 8843-8844 p)))
    (TakeLeft 8848-8893
      (Function 8848-8878 (ParserVar 8848-8856 surround) ((ParserVar 8857-8858 p) (Function 8860-8877 (ParserVar 8860-8865 maybe) ((ParserVar 8866-8876 whitespace)))))
      (ParserVar 8881-8893 end_of_input)))
  (DeclareGlobal 8904-9014
    (ParserVar 8904-8908 json)
    (Or 8913-9014
      (ParserVar 8913-8925 json.boolean)
      (Or 8930-9014
        (ParserVar 8930-8939 json.null)
        (Or 8944-9014
          (ParserVar 8944-8955 json.number)
          (Or 8960-9014
            (ParserVar 8960-8971 json.string)
            (Or 8976-9014
              (Function 8976-8992 (ParserVar 8976-8986 json.array) ((ParserVar 8987-8991 json)))
              (Function 8997-9014 (ParserVar 8997-9008 json.object) ((ParserVar 9009-9013 json)))))))))
  (DeclareGlobal 9016-9055
    (ParserVar 9016-9028 json.boolean)
    (Function 9031-9055 (ParserVar 9031-9038 boolean) ((String 9039-9045 "true") (String 9047-9054 "false"))))
  (DeclareGlobal 9057-9081
    (ParserVar 9057-9066 json.null)
    (Function 9069-9081 (Null 9069-9073 null) ((String 9074-9080 "null"))))
  (DeclareGlobal 9083-9103
    (ParserVar 9083-9094 json.number)
    (ParserVar 9097-9103 number))
  (DeclareGlobal 9105-9148
    (ParserVar 9105-9116 json.string)
    (TakeLeft 9119-9148
      (TakeRight 9119-9142
        (String 9119-9122 """)
        (ParserVar 9125-9142 _json.string_body))
      (String 9145-9148 """)))
  (DeclareGlobal 9150-9283
    (ParserVar 9150-9167 _json.string_body)
    (Or 9172-9283
      (Function 9172-9270
        (ParserVar 9172-9176 many)
        ((Or 9182-9266
            (ParserVar 9182-9200 _escaped_ctrl_char)
            (Or 9207-9266
              (ParserVar 9207-9223 _escaped_unicode)
              (Function 9230-9266
                (ParserVar 9230-9236 unless)
                ((ParserVar 9237-9241 char)
                 (Or 9243-9265
                    (ParserVar 9243-9253 _ctrl_char)
                    (Or 9256-9265
                      (String 9256-9259 "\")
                      (String 9262-9265 """)))))))))
      (Function 9273-9283 (ParserVar 9273-9278 const) ((ValueLabel 9279-9280 (String 9280-9282 ""))))))
  (DeclareGlobal 9285-9320
    (ParserVar 9285-9295 _ctrl_char)
    (Range 9298-9320 (String 9298-9308 _0) (String 9310-9320 "\x1f"))) (esc)
  (DeclareGlobal 9322-9481
    (ParserVar 9322-9340 _escaped_ctrl_char)
    (Or 9345-9481
      (Return 9345-9357
        (String 9346-9350 "\"")
        (String 9353-9356 """))
      (Or 9362-9481
        (Return 9362-9374
          (String 9363-9367 "\\")
          (String 9370-9373 "\"))
        (Or 9379-9481
          (Return 9379-9391
            (String 9380-9384 "\/")
            (String 9387-9390 "/"))
          (Or 9396-9481
            (Return 9396-9409
              (String 9397-9401 "\b")
              (String 9404-9408 "\x08")) (esc)
            (Or 9414-9481
              (Return 9414-9427
                (String 9415-9419 "\f")
                (String 9422-9426 "\x0c")) (esc)
              (Or 9432-9481
                (Return 9432-9445
                  (String 9433-9437 "\n")
                  (String 9440-9444 "
  "))
                (Or 9450-9481
                  (Return 9450-9463
                    (String 9451-9455 "\r")
                    (String 9458-9462 "\r (no-eol) (esc)
  "))
                  (Return 9468-9481
                    (String 9469-9473 "\t")
                    (String 9476-9480 "\t")))))))))) (esc)
  (DeclareGlobal 9483-9546
    (ParserVar 9483-9499 _escaped_unicode)
    (Or 9502-9546
      (ParserVar 9502-9525 _escaped_surrogate_pair)
      (ParserVar 9528-9546 _escaped_codepoint)))
  (DeclareGlobal 9548-9621
    (ParserVar 9548-9571 _escaped_surrogate_pair)
    (Or 9574-9621
      (ParserVar 9574-9595 _valid_surrogate_pair)
      (ParserVar 9598-9621 _invalid_surrogate_pair)))
  (DeclareGlobal 9623-9723
    (ParserVar 9623-9644 _valid_surrogate_pair)
    (TakeRight 9649-9723
      (Destructure 9649-9669
        (ParserVar 9649-9664 _high_surrogate)
        (ValueVar 9668-9669 H))
      (Return 9672-9723
        (Destructure 9672-9691
          (ParserVar 9672-9686 _low_surrogate)
          (ValueVar 9690-9691 L))
        (Function 9694-9723 (ValueVar 9694-9717 @SurrogatePairCodepoint) ((ValueVar 9718-9719 H) (ValueVar 9721-9722 L))))))
  (DeclareGlobal 9725-9796
    (ParserVar 9725-9748 _invalid_surrogate_pair)
    (Return 9751-9796
      (Or 9751-9783
        (ParserVar 9751-9765 _low_surrogate)
        (ParserVar 9768-9783 _high_surrogate))
      (String 9786-9796 "\xef\xbf\xbd"))) (esc)
  (DeclareGlobal 9798-9902
    (ParserVar 9798-9813 _high_surrogate)
    (Merge 9818-9902
      (Merge 9818-9888
        (Merge 9818-9874
          (TakeRight 9818-9836
            (String 9818-9822 "\u")
            (Or 9825-9836
              (String 9826-9829 "D")
              (String 9832-9835 "d")))
          (Or 9839-9874
            (String 9840-9843 "8")
            (Or 9846-9873
              (String 9846-9849 "9")
              (Or 9852-9873
                (String 9852-9855 "A")
                (Or 9858-9873
                  (String 9858-9861 "B")
                  (Or 9864-9873
                    (String 9864-9867 "a")
                    (String 9870-9873 "b")))))))
        (ParserVar 9877-9888 hex_numeral))
      (ParserVar 9891-9902 hex_numeral)))
  (DeclareGlobal 9904-9993
    (ParserVar 9904-9918 _low_surrogate)
    (Merge 9923-9993
      (Merge 9923-9979
        (Merge 9923-9965
          (TakeRight 9923-9941
            (String 9923-9927 "\u")
            (Or 9930-9941
              (String 9931-9934 "D")
              (String 9937-9940 "d")))
          (Or 9944-9965
            (Range 9945-9953 (String 9945-9948 "C") (String 9950-9953 "F"))
            (Range 9956-9964 (String 9956-9959 "c") (String 9961-9964 "f"))))
        (ParserVar 9968-9979 hex_numeral))
      (ParserVar 9982-9993 hex_numeral)))
  (DeclareGlobal 9995-10064
    (ParserVar 9995-10013 _escaped_codepoint)
    (Return 10016-10064
      (Destructure 10016-10048
        (TakeRight 10016-10043
          (String 10016-10020 "\u")
          (Function 10023-10043 (ParserVar 10023-10030 repeat4) ((ParserVar 10031-10042 hex_numeral))))
        (ValueVar 10047-10048 U))
      (Function 10051-10064 (ValueVar 10051-10061 @Codepoint) ((ValueVar 10062-10063 U)))))
  (DeclareGlobal 10066-10144
    (Function 10066-10082 (ParserVar 10066-10076 json.array) ((ParserVar 10077-10081 elem)))
    (TakeLeft 10085-10144
      (TakeRight 10085-10138
        (String 10085-10088 "[")
        (Function 10091-10138 (ParserVar 10091-10106 maybe_array_sep) ((Function 10107-10132 (ParserVar 10107-10115 surround) ((ParserVar 10116-10120 elem) (Function 10122-10131 (ParserVar 10122-10127 maybe) ((ParserVar 10128-10130 ws))))) (String 10134-10137 ","))))
      (String 10141-10144 "]")))
  (DeclareGlobal 10146-10285
    (Function 10146-10164 (ParserVar 10146-10157 json.object) ((ParserVar 10158-10163 value)))
    (TakeLeft 10169-10285
      (TakeRight 10169-10277
        (String 10169-10172 "{")
        (Function 10177-10277
          (ParserVar 10177-10193 maybe_object_sep)
          ((Function 10199-10231 (ParserVar 10199-10207 surround) ((ParserVar 10208-10219 json.string) (Function 10221-10230 (ParserVar 10221-10226 maybe) ((ParserVar 10227-10229 ws)))))
           (String 10233-10236 ":")
           (Function 10242-10268 (ParserVar 10242-10250 surround) ((ParserVar 10251-10256 value) (Function 10258-10267 (ParserVar 10258-10263 maybe) ((ParserVar 10264-10266 ws)))))
           (String 10270-10273 ","))))
      (String 10282-10285 "}")))
  (DeclareGlobal 10296-10314
    (ParserVar 10296-10300 toml)
    (ParserVar 10303-10314 toml.simple))
  (DeclareGlobal 10316-10360
    (ParserVar 10316-10327 toml.simple)
    (Function 10330-10360 (ParserVar 10330-10341 toml.custom) ((ParserVar 10342-10359 toml.simple_value))))
  (DeclareGlobal 10362-10406
    (ParserVar 10362-10373 toml.tagged)
    (Function 10376-10406 (ParserVar 10376-10387 toml.custom) ((ParserVar 10388-10405 toml.tagged_value))))
  (DeclareGlobal 10408-10596
    (Function 10408-10426 (ParserVar 10408-10419 toml.custom) ((ParserVar 10420-10425 value)))
    (TakeRight 10431-10596
      (TakeRight 10431-10533
        (Function 10431-10464
          (ParserVar 10431-10436 maybe)
          ((Merge 10437-10463
              (ParserVar 10437-10451 _toml.comments)
              (Function 10454-10463 (ParserVar 10454-10459 maybe) ((ParserVar 10460-10462 ws))))))
        (Destructure 10469-10533
          (Or 10469-10526
            (Function 10469-10497 (ParserVar 10469-10490 _toml.with_root_table) ((ParserVar 10491-10496 value)))
            (Function 10500-10526 (ParserVar 10500-10519 _toml.no_root_table) ((ParserVar 10520-10525 value))))
          (ValueVar 10530-10533 Doc)))
      (Return 10538-10596
        (Function 10538-10571
          (ParserVar 10538-10543 maybe)
          ((Merge 10544-10570
              (Function 10544-10553 (ParserVar 10544-10549 maybe) ((ParserVar 10550-10552 ws)))
              (ParserVar 10556-10570 _toml.comments))))
        (Function 10576-10596 (ValueVar 10576-10591 _Toml.Doc.Value) ((ValueVar 10592-10595 Doc))))))
  (DeclareGlobal 10598-10745
    (Function 10598-10626 (ParserVar 10598-10619 _toml.with_root_table) ((ParserVar 10620-10625 value)))
    (TakeRight 10631-10745
      (Destructure 10631-10682
        (Function 10631-10671 (ParserVar 10631-10647 _toml.root_table) ((ParserVar 10648-10653 value) (ValueVar 10655-10670 _Toml.Doc.Empty)))
        (ValueVar 10675-10682 RootDoc))
      (Or 10687-10745
        (TakeRight 10687-10728
          (ParserVar 10688-10696 _toml.ws)
          (Function 10699-10727 (ParserVar 10699-10711 _toml.tables) ((ParserVar 10712-10717 value) (ValueVar 10719-10726 RootDoc))))
        (Function 10731-10745 (ParserVar 10731-10736 const) ((ValueVar 10737-10744 RootDoc))))))
  (DeclareGlobal 10747-10812
    (Function 10747-10775 (ParserVar 10747-10763 _toml.root_table) ((ParserVar 10764-10769 value) (ValueVar 10771-10774 Doc)))
    (Function 10780-10812
      (ParserVar 10780-10796 _toml.table_body)
      ((ParserVar 10797-10802 value)
       (Array 10804-10807 ())
       (ValueVar 10808-10811 Doc))))
  (DeclareGlobal 10814-10970
    (Function 10814-10840 (ParserVar 10814-10833 _toml.no_root_table) ((ParserVar 10834-10839 value)))
    (TakeRight 10845-10970
      (Destructure 10845-10938
        (Or 10845-10928
          (Function 10845-10880 (ParserVar 10845-10856 _toml.table) ((ParserVar 10857-10862 value) (ValueVar 10864-10879 _Toml.Doc.Empty)))
          (Function 10883-10928 (ParserVar 10883-10904 _toml.array_of_tables) ((ParserVar 10905-10910 value) (ValueVar 10912-10927 _Toml.Doc.Empty))))
        (ValueVar 10932-10938 NewDoc))
      (Function 10943-10970 (ParserVar 10943-10955 _toml.tables) ((ParserVar 10956-10961 value) (ValueVar 10963-10969 NewDoc)))))
  (DeclareGlobal 10972-11130
    (Function 10972-10996 (ParserVar 10972-10984 _toml.tables) ((ParserVar 10985-10990 value) (ValueVar 10992-10995 Doc)))
    (Conditional 11001-11130
      (condition (Destructure 11001-11083
          (Or 11001-11073
            (TakeRight 11001-11037
              (ParserVar 11001-11009 _toml.ws)
              (Function 11014-11037 (ParserVar 11014-11025 _toml.table) ((ParserVar 11026-11031 value) (ValueVar 11033-11036 Doc))))
            (Function 11040-11073 (ParserVar 11040-11061 _toml.array_of_tables) ((ParserVar 11062-11067 value) (ValueVar 11069-11072 Doc))))
          (ValueVar 11077-11083 NewDoc)))
      (then (Function 11088-11115 (ParserVar 11088-11100 _toml.tables) ((ParserVar 11101-11106 value) (ValueVar 11108-11114 NewDoc))))
      (else (Function 11120-11130 (ParserVar 11120-11125 const) ((ValueVar 11126-11129 Doc))))))
  (DeclareGlobal 11132-11322
    (Function 11132-11155 (ParserVar 11132-11143 _toml.table) ((ParserVar 11144-11149 value) (ValueVar 11151-11154 Doc)))
    (TakeRight 11160-11322
      (TakeRight 11160-11211
        (Destructure 11160-11192
          (ParserVar 11160-11178 _toml.table_header)
          (ValueVar 11182-11192 HeaderPath))
        (ParserVar 11195-11211 _toml.ws_newline))
      (Or 11214-11322
        (Function 11220-11260
          (ParserVar 11220-11236 _toml.table_body)
          ((ParserVar 11237-11242 value)
           (ValueVar 11244-11254 HeaderPath)
           (ValueVar 11256-11259 Doc)))
        (Function 11267-11318 (ParserVar 11267-11272 const) ((Function 11273-11317 (ValueVar 11273-11300 _Toml.Doc.EnsureTableAtPath) ((ValueVar 11301-11304 Doc) (ValueVar 11306-11316 HeaderPath))))))))
  (DeclareGlobal 11324-11581
    (Function 11324-11357 (ParserVar 11324-11345 _toml.array_of_tables) ((ParserVar 11346-11351 value) (ValueVar 11353-11356 Doc)))
    (TakeRight 11362-11581
      (TakeRight 11362-11423
        (Destructure 11362-11404
          (ParserVar 11362-11390 _toml.array_of_tables_header)
          (ValueVar 11394-11404 HeaderPath))
        (ParserVar 11407-11423 _toml.ws_newline))
      (Return 11428-11581
        (Destructure 11428-11510
          (Function 11428-11498
            (ParserVar 11428-11435 default)
            ((Function 11436-11480
                (ParserVar 11436-11452 _toml.table_body)
                ((ParserVar 11453-11458 value)
                 (Array 11460-11463 ())
                 (ValueVar 11464-11479 _Toml.Doc.Empty)))
             (ValueVar 11482-11497 _Toml.Doc.Empty)))
          (ValueVar 11502-11510 InnerDoc))
        (Function 11515-11581
          (ValueVar 11515-11537 _Toml.Doc.AppendAtPath)
          ((ValueVar 11538-11541 Doc)
           (ValueVar 11543-11553 HeaderPath)
           (Function 11555-11580 (ValueVar 11555-11570 _Toml.Doc.Value) ((ValueVar 11571-11579 InnerDoc))))))))
  (DeclareGlobal 11583-11624
    (ParserVar 11583-11591 _toml.ws)
    (Function 11594-11624
      (ParserVar 11594-11604 maybe_many)
      ((Or 11605-11623
          (ParserVar 11605-11607 ws)
          (ParserVar 11610-11623 _toml.comment)))))
  (DeclareGlobal 11626-11676
    (ParserVar 11626-11639 _toml.ws_line)
    (Function 11642-11676
      (ParserVar 11642-11652 maybe_many)
      ((Or 11653-11675
          (ParserVar 11653-11659 spaces)
          (ParserVar 11662-11675 _toml.comment)))))
  (DeclareGlobal 11678-11734
    (ParserVar 11678-11694 _toml.ws_newline)
    (Merge 11697-11734
      (Merge 11697-11723
        (ParserVar 11697-11710 _toml.ws_line)
        (Or 11713-11723
          (ParserVar 11714-11716 nl)
          (ParserVar 11719-11722 end)))
      (ParserVar 11726-11734 _toml.ws)))
  (DeclareGlobal 11736-11780
    (ParserVar 11736-11750 _toml.comments)
    (Function 11753-11780 (ParserVar 11753-11761 many_sep) ((ParserVar 11762-11775 _toml.comment) (ParserVar 11777-11779 ws))))
  (DeclareGlobal 11782-11846
    (ParserVar 11782-11800 _toml.table_header)
    (TakeLeft 11803-11846
      (TakeRight 11803-11840
        (String 11803-11806 "[")
        (Function 11809-11840 (ParserVar 11809-11817 surround) ((ParserVar 11818-11828 _toml.path) (Function 11830-11839 (ParserVar 11830-11835 maybe) ((ParserVar 11836-11838 ws))))))
      (String 11843-11846 "]")))
  (DeclareGlobal 11848-11926
    (ParserVar 11848-11876 _toml.array_of_tables_header)
    (TakeLeft 11881-11926
      (TakeRight 11881-11919
        (String 11881-11885 "[[")
        (Function 11888-11919 (ParserVar 11888-11896 surround) ((ParserVar 11897-11907 _toml.path) (Function 11909-11918 (ParserVar 11909-11914 maybe) ((ParserVar 11915-11917 ws))))))
      (String 11922-11926 "]]")))
  (DeclareGlobal 11928-12173
    (Function 11928-11968
      (ParserVar 11928-11944 _toml.table_body)
      ((ParserVar 11945-11950 value)
       (ValueVar 11952-11962 HeaderPath)
       (ValueVar 11964-11967 Doc)))
    (TakeRight 11973-12173
      (TakeRight 11973-12109
        (TakeRight 11973-12033
          (Destructure 11973-12014
            (Function 11973-11996 (ParserVar 11973-11989 _toml.table_pair) ((ParserVar 11990-11995 value)))
            (Array 12000-12014 ((ValueVar 12001-12008 KeyPath) (ValueVar 12010-12013 Val))))
          (ParserVar 12017-12033 _toml.ws_newline))
        (Destructure 12038-12109
          (Function 12038-12099
            (ParserVar 12038-12043 const)
            ((Function 12044-12098
                (ValueVar 12044-12066 _Toml.Doc.InsertAtPath)
                ((ValueVar 12067-12070 Doc)
                 (Merge 12072-12092
                    (ValueVar 12072-12082 HeaderPath)
                    (ValueVar 12085-12092 KeyPath))
                 (ValueVar 12094-12097 Val)))))
          (ValueVar 12103-12109 NewDoc)))
      (Or 12114-12173
        (Function 12114-12157
          (ParserVar 12114-12130 _toml.table_body)
          ((ParserVar 12131-12136 value)
           (ValueVar 12138-12148 HeaderPath)
           (ValueVar 12150-12156 NewDoc)))
        (Function 12160-12173 (ParserVar 12160-12165 const) ((ValueVar 12166-12172 NewDoc))))))
  (DeclareGlobal 12175-12262
    (Function 12175-12198 (ParserVar 12175-12191 _toml.table_pair) ((ParserVar 12192-12197 value)))
    (Function 12203-12262
      (ParserVar 12203-12213 tuple2_sep)
      ((ParserVar 12214-12224 _toml.path)
       (Function 12226-12254 (ParserVar 12226-12234 surround) ((String 12235-12238 "=") (Function 12240-12253 (ParserVar 12240-12245 maybe) ((ParserVar 12246-12252 spaces)))))
       (ParserVar 12256-12261 value))))
  (DeclareGlobal 12264-12323
    (ParserVar 12264-12274 _toml.path)
    (Function 12277-12323 (ParserVar 12277-12286 array_sep) ((ParserVar 12287-12296 _toml.key) (Function 12298-12322 (ParserVar 12298-12306 surround) ((String 12307-12310 ".") (Function 12312-12321 (ParserVar 12312-12317 maybe) ((ParserVar 12318-12320 ws))))))))
  (DeclareGlobal 12325-12418
    (ParserVar 12325-12334 _toml.key)
    (Or 12339-12418
      (Function 12339-12372
        (ParserVar 12339-12343 many)
        ((Or 12344-12371
            (ParserVar 12344-12349 alpha)
            (Or 12352-12371
              (ParserVar 12352-12359 numeral)
              (Or 12362-12371
                (String 12362-12365 "_")
                (String 12368-12371 "-"))))))
      (Or 12377-12418
        (ParserVar 12377-12394 toml.string.basic)
        (ParserVar 12399-12418 toml.string.literal))))
  (DeclareGlobal 12420-12453
    (ParserVar 12420-12433 _toml.comment)
    (TakeRight 12436-12453
      (String 12436-12439 "#")
      (Function 12442-12453 (ParserVar 12442-12447 maybe) ((ParserVar 12448-12452 line)))))
  (DeclareGlobal 12455-12614
    (ParserVar 12455-12472 toml.simple_value)
    (Or 12477-12614
      (ParserVar 12477-12488 toml.string)
      (Or 12493-12614
        (ParserVar 12493-12506 toml.datetime)
        (Or 12511-12614
          (ParserVar 12511-12522 toml.number)
          (Or 12527-12614
            (ParserVar 12527-12539 toml.boolean)
            (Or 12544-12614
              (Function 12544-12573 (ParserVar 12544-12554 toml.array) ((ParserVar 12555-12572 toml.simple_value)))
              (Function 12578-12614 (ParserVar 12578-12595 toml.inline_table) ((ParserVar 12596-12613 toml.simple_value)))))))))
  (DeclareGlobal 12616-13256
    (ParserVar 12616-12633 toml.tagged_value)
    (Or 12638-13256
      (ParserVar 12638-12649 toml.string)
      (Or 12654-13256
        (Function 12654-12709
          (ParserVar 12654-12663 _toml.tag)
          ((ValueLabel 12664-12665 (String 12665-12675 "datetime"))
           (ValueLabel 12677-12678 (String 12678-12686 "offset"))
           (ParserVar 12688-12708 toml.datetime.offset)))
        (Or 12714-13256
          (Function 12714-12767
            (ParserVar 12714-12723 _toml.tag)
            ((ValueLabel 12724-12725 (String 12725-12735 "datetime"))
             (ValueLabel 12737-12738 (String 12738-12745 "local"))
             (ParserVar 12747-12766 toml.datetime.local)))
          (Or 12772-13256
            (Function 12772-12835
              (ParserVar 12772-12781 _toml.tag)
              ((ValueLabel 12782-12783 (String 12783-12793 "datetime"))
               (ValueLabel 12795-12796 (String 12796-12808 "date-local"))
               (ParserVar 12810-12834 toml.datetime.local_date)))
            (Or 12840-13256
              (Function 12840-12903
                (ParserVar 12840-12849 _toml.tag)
                ((ValueLabel 12850-12851 (String 12851-12861 "datetime"))
                 (ValueLabel 12863-12864 (String 12864-12876 "time-local"))
                 (ParserVar 12878-12902 toml.datetime.local_time)))
              (Or 12908-13256
                (ParserVar 12908-12934 toml.number.binary_integer)
                (Or 12939-13256
                  (ParserVar 12939-12964 toml.number.octal_integer)
                  (Or 12969-13256
                    (ParserVar 12969-12992 toml.number.hex_integer)
                    (Or 12997-13256
                      (Function 12997-13051
                        (ParserVar 12997-13006 _toml.tag)
                        ((ValueLabel 13007-13008 (String 13008-13015 "float"))
                         (ValueLabel 13017-13018 (String 13018-13028 "infinity"))
                         (ParserVar 13030-13050 toml.number.infinity)))
                      (Or 13056-13256
                        (Function 13056-13118
                          (ParserVar 13056-13065 _toml.tag)
                          ((ValueLabel 13066-13067 (String 13067-13074 "float"))
                           (ValueLabel 13076-13077 (String 13077-13091 "not-a-number"))
                           (ParserVar 13093-13117 toml.number.not_a_number)))
                        (Or 13123-13256
                          (ParserVar 13123-13140 toml.number.float)
                          (Or 13145-13256
                            (ParserVar 13145-13164 toml.number.integer)
                            (Or 13169-13256
                              (ParserVar 13169-13181 toml.boolean)
                              (Or 13186-13256
                                (Function 13186-13215 (ParserVar 13186-13196 toml.array) ((ParserVar 13197-13214 toml.tagged_value)))
                                (Function 13220-13256 (ParserVar 13220-13237 toml.inline_table) ((ParserVar 13238-13255 toml.tagged_value))))))))))))))))))
  (DeclareGlobal 13258-13361
    (Function 13258-13289
      (ParserVar 13258-13267 _toml.tag)
      ((ValueVar 13268-13272 Type)
       (ValueVar 13274-13281 Subtype)
       (ParserVar 13283-13288 value)))
    (Return 13294-13361
      (Destructure 13294-13308
        (ParserVar 13294-13299 value)
        (ValueVar 13303-13308 Value))
      (Object 13311-13361
        ((String 13312-13318 "type") (ValueVar 13320-13324 Type))
        ((String 13326-13335 "subtype") (ValueVar 13337-13344 Subtype))
        ((String 13346-13353 "value") (ValueVar 13355-13360 Value)))))
  (DeclareGlobal 13363-13488
    (ParserVar 13363-13374 toml.string)
    (Or 13379-13488
      (ParserVar 13379-13407 toml.string.multi_line_basic)
      (Or 13412-13488
        (ParserVar 13412-13442 toml.string.multi_line_literal)
        (Or 13447-13488
          (ParserVar 13447-13464 toml.string.basic)
          (ParserVar 13469-13488 toml.string.literal)))))
  (DeclareGlobal 13490-13610
    (ParserVar 13490-13503 toml.datetime)
    (Or 13508-13610
      (ParserVar 13508-13528 toml.datetime.offset)
      (Or 13533-13610
        (ParserVar 13533-13552 toml.datetime.local)
        (Or 13557-13610
          (ParserVar 13557-13581 toml.datetime.local_date)
          (ParserVar 13586-13610 toml.datetime.local_time)))))
  (DeclareGlobal 13612-13812
    (ParserVar 13612-13623 toml.number)
    (Or 13628-13812
      (ParserVar 13628-13654 toml.number.binary_integer)
      (Or 13659-13812
        (ParserVar 13659-13684 toml.number.octal_integer)
        (Or 13689-13812
          (ParserVar 13689-13712 toml.number.hex_integer)
          (Or 13717-13812
            (ParserVar 13717-13737 toml.number.infinity)
            (Or 13742-13812
              (ParserVar 13742-13766 toml.number.not_a_number)
              (Or 13771-13812
                (ParserVar 13771-13788 toml.number.float)
                (ParserVar 13793-13812 toml.number.integer))))))))
  (DeclareGlobal 13814-13853
    (ParserVar 13814-13826 toml.boolean)
    (Function 13829-13853 (ParserVar 13829-13836 boolean) ((String 13837-13843 "true") (String 13845-13852 "false"))))
  (DeclareGlobal 13855-14008
    (Function 13855-13871 (ParserVar 13855-13865 toml.array) ((ParserVar 13866-13870 elem)))
    (TakeLeft 13876-14008
      (TakeLeft 13876-14002
        (TakeRight 13876-13991
          (TakeRight 13876-13890
            (String 13876-13879 "[")
            (ParserVar 13882-13890 _toml.ws))
          (Function 13893-13991
            (ParserVar 13893-13900 default)
            ((TakeLeft 13906-13979
                (Function 13906-13946 (ParserVar 13906-13915 array_sep) ((Function 13916-13940 (ParserVar 13916-13924 surround) ((ParserVar 13925-13929 elem) (ParserVar 13931-13939 _toml.ws))) (String 13942-13945 ",")))
                (Function 13949-13979 (ParserVar 13949-13954 maybe) ((Function 13955-13978 (ParserVar 13955-13963 surround) ((String 13964-13967 ",") (ParserVar 13969-13977 _toml.ws))))))
             (Array 13985-13991 ()))))
        (ParserVar 13994-14002 _toml.ws))
      (String 14005-14008 "]")))
  (DeclareGlobal 14010-14144
    (Function 14010-14034 (ParserVar 14010-14027 toml.inline_table) ((ParserVar 14028-14033 value)))
    (Return 14039-14144
      (Destructure 14039-14113
        (Or 14039-14100
          (ParserVar 14039-14063 _toml.empty_inline_table)
          (Function 14066-14100 (ParserVar 14066-14093 _toml.nonempty_inline_table) ((ParserVar 14094-14099 value))))
        (ValueVar 14104-14113 InlineDoc))
      (Function 14118-14144 (ValueVar 14118-14133 _Toml.Doc.Value) ((ValueVar 14134-14143 InlineDoc)))))
  (DeclareGlobal 14146-14216
    (ParserVar 14146-14170 _toml.empty_inline_table)
    (Return 14173-14216
      (TakeLeft 14173-14198
        (TakeRight 14173-14192
          (String 14173-14176 "{")
          (Function 14179-14192 (ParserVar 14179-14184 maybe) ((ParserVar 14185-14191 spaces))))
        (String 14195-14198 "}"))
      (ValueVar 14201-14216 _Toml.Doc.Empty)))
  (DeclareGlobal 14218-14425
    (Function 14218-14252 (ParserVar 14218-14245 _toml.nonempty_inline_table) ((ParserVar 14246-14251 value)))
    (TakeRight 14257-14425
      (Destructure 14257-14348
        (TakeRight 14257-14328
          (TakeRight 14257-14276
            (String 14257-14260 "{")
            (Function 14263-14276 (ParserVar 14263-14268 maybe) ((ParserVar 14269-14275 spaces))))
          (Function 14281-14328 (ParserVar 14281-14304 _toml.inline_table_pair) ((ParserVar 14305-14310 value) (ValueVar 14312-14327 _Toml.Doc.Empty))))
        (ValueVar 14332-14348 DocWithFirstPair))
      (TakeLeft 14353-14425
        (TakeLeft 14353-14419
          (Function 14353-14401 (ParserVar 14353-14376 _toml.inline_table_body) ((ParserVar 14377-14382 value) (ValueVar 14384-14400 DocWithFirstPair)))
          (Function 14406-14419 (ParserVar 14406-14411 maybe) ((ParserVar 14412-14418 spaces))))
        (String 14422-14425 "}"))))
  (DeclareGlobal 14427-14576
    (Function 14427-14462 (ParserVar 14427-14450 _toml.inline_table_body) ((ParserVar 14451-14456 value) (ValueVar 14458-14461 Doc)))
    (Conditional 14467-14576
      (condition (Destructure 14467-14518
          (TakeRight 14467-14508
            (String 14467-14470 ",")
            (Function 14473-14508 (ParserVar 14473-14496 _toml.inline_table_pair) ((ParserVar 14497-14502 value) (ValueVar 14504-14507 Doc))))
          (ValueVar 14512-14518 NewDoc)))
      (then (Function 14523-14561 (ParserVar 14523-14546 _toml.inline_table_body) ((ParserVar 14547-14552 value) (ValueVar 14554-14560 NewDoc))))
      (else (Function 14566-14576 (ParserVar 14566-14571 const) ((ValueVar 14572-14575 Doc))))))
  (DeclareGlobal 14578-14770
    (Function 14578-14613 (ParserVar 14578-14601 _toml.inline_table_pair) ((ParserVar 14602-14607 value) (ValueVar 14609-14612 Doc)))
    (TakeRight 14618-14770
      (TakeRight 14618-14710
        (TakeRight 14618-14693
          (TakeRight 14618-14677
            (TakeRight 14618-14671
              (TakeRight 14618-14653
                (Function 14618-14631 (ParserVar 14618-14623 maybe) ((ParserVar 14624-14630 spaces)))
                (Destructure 14636-14653
                  (ParserVar 14636-14646 _toml.path)
                  (ValueVar 14650-14653 Key)))
              (Function 14658-14671 (ParserVar 14658-14663 maybe) ((ParserVar 14664-14670 spaces))))
            (String 14674-14677 "="))
          (Function 14680-14693 (ParserVar 14680-14685 maybe) ((ParserVar 14686-14692 spaces))))
        (Destructure 14698-14710
          (ParserVar 14698-14703 value)
          (ValueVar 14707-14710 Val)))
      (Return 14715-14770
        (Function 14715-14728 (ParserVar 14715-14720 maybe) ((ParserVar 14721-14727 spaces)))
        (Function 14733-14770
          (ValueVar 14733-14755 _Toml.Doc.InsertAtPath)
          ((ValueVar 14756-14759 Doc)
           (ValueVar 14761-14764 Key)
           (ValueVar 14766-14769 Val))))))
  (DeclareGlobal 14772-14857
    (ParserVar 14772-14800 toml.string.multi_line_basic)
    (TakeRight 14803-14857
      (TakeRight 14803-14820
        (String 14803-14808 """"")
        (Function 14811-14820 (ParserVar 14811-14816 maybe) ((ParserVar 14817-14819 nl))))
      (Function 14823-14857 (ParserVar 14823-14852 _toml.string.multi_line_basic) ((ValueLabel 14853-14854 (String 14854-14856 ""))))))
  (DeclareGlobal 14859-15151
    (Function 14859-14893 (ParserVar 14859-14888 _toml.string.multi_line_basic) ((ValueVar 14889-14892 Acc)))
    (Or 14898-15151
      (Return 14898-14922
        (String 14899-14906 """"""")
        (Merge 14909-14921
          (ValueVar 14910-14913 Acc)
          (String 14916-14920 """")))
      (Or 14927-15151
        (Return 14927-14949
          (String 14928-14934 """""")
          (Merge 14937-14948
            (ValueVar 14938-14941 Acc)
            (String 14944-14947 """)))
        (Or 14954-15151
          (Return 14954-14967
            (String 14955-14960 """"")
            (ValueVar 14963-14966 Acc))
          (TakeRight 14972-15151
            (Destructure 14978-15102
              (Or 14978-15097
                (ParserVar 14978-15001 _toml.escaped_ctrl_char)
                (Or 15008-15097
                  (ParserVar 15008-15029 _toml.escaped_unicode)
                  (Or 15036-15097
                    (ParserVar 15036-15038 ws)
                    (Or 15045-15097
                      (TakeRight 15045-15060
                        (Merge 15046-15054
                          (String 15046-15049 "\")
                          (ParserVar 15052-15054 ws))
                        (String 15057-15059 ""))
                      (Function 15067-15097
                        (ParserVar 15067-15073 unless)
                        ((ParserVar 15074-15078 char)
                         (Or 15080-15096
                            (ParserVar 15080-15090 _ctrl_char)
                            (String 15093-15096 "\"))))))))
              (ValueVar 15101-15102 C))
            (Function 15109-15147
              (ParserVar 15109-15138 _toml.string.multi_line_basic)
              ((Merge 15139-15146
                  (ValueVar 15139-15142 Acc)
                  (ValueVar 15145-15146 C)))))))))
  (DeclareGlobal 15153-15242
    (ParserVar 15153-15183 toml.string.multi_line_literal)
    (TakeRight 15186-15242
      (TakeRight 15186-15203
        (String 15186-15191 "'''")
        (Function 15194-15203 (ParserVar 15194-15199 maybe) ((ParserVar 15200-15202 nl))))
      (Function 15206-15242 (ParserVar 15206-15237 _toml.string.multi_line_literal) ((ValueLabel 15238-15239 (String 15239-15241 ""))))))
  (DeclareGlobal 15244-15413
    (Function 15244-15280 (ParserVar 15244-15275 _toml.string.multi_line_literal) ((ValueVar 15276-15279 Acc)))
    (Or 15285-15413
      (Return 15285-15309
        (String 15286-15293 "'''''")
        (Merge 15296-15308
          (ValueVar 15297-15300 Acc)
          (String 15303-15307 "''")))
      (Or 15314-15413
        (Return 15314-15336
          (String 15315-15321 "''''")
          (Merge 15324-15335
            (ValueVar 15325-15328 Acc)
            (String 15331-15334 "'")))
        (Or 15341-15413
          (Return 15341-15354
            (String 15342-15347 "'''")
            (ValueVar 15350-15353 Acc))
          (TakeRight 15359-15413
            (Destructure 15360-15369
              (ParserVar 15360-15364 char)
              (ValueVar 15368-15369 C))
            (Function 15372-15412
              (ParserVar 15372-15403 _toml.string.multi_line_literal)
              ((Merge 15404-15411
                  (ValueVar 15404-15407 Acc)
                  (ValueVar 15410-15411 C)))))))))
  (DeclareGlobal 15415-15470
    (ParserVar 15415-15432 toml.string.basic)
    (TakeLeft 15435-15470
      (TakeRight 15435-15464
        (String 15435-15438 """)
        (ParserVar 15441-15464 _toml.string.basic_body))
      (String 15467-15470 """)))
  (DeclareGlobal 15472-15621
    (ParserVar 15472-15495 _toml.string.basic_body)
    (Or 15500-15621
      (Function 15500-15608
        (ParserVar 15500-15504 many)
        ((Or 15510-15604
            (ParserVar 15510-15533 _toml.escaped_ctrl_char)
            (Or 15540-15604
              (ParserVar 15540-15561 _toml.escaped_unicode)
              (Function 15568-15604
                (ParserVar 15568-15574 unless)
                ((ParserVar 15575-15579 char)
                 (Or 15581-15603
                    (ParserVar 15581-15591 _ctrl_char)
                    (Or 15594-15603
                      (String 15594-15597 "\")
                      (String 15600-15603 """)))))))))
      (Function 15611-15621 (ParserVar 15611-15616 const) ((ValueLabel 15617-15618 (String 15618-15620 ""))))))
  (DeclareGlobal 15623-15687
    (ParserVar 15623-15642 toml.string.literal)
    (TakeLeft 15645-15687
      (TakeRight 15645-15681
        (String 15645-15648 "'")
        (Function 15651-15681 (ParserVar 15651-15658 default) ((Function 15659-15675 (ParserVar 15659-15670 chars_until) ((String 15671-15674 "'"))) (ValueLabel 15677-15678 (String 15678-15680 "")))))
      (String 15684-15687 "'")))
  (DeclareGlobal 15689-15836
    (ParserVar 15689-15712 _toml.escaped_ctrl_char)
    (Or 15717-15836
      (Return 15717-15729
        (String 15718-15722 "\"")
        (String 15725-15728 """))
      (Or 15734-15836
        (Return 15734-15746
          (String 15735-15739 "\\")
          (String 15742-15745 "\"))
        (Or 15751-15836
          (Return 15751-15764
            (String 15752-15756 "\b")
            (String 15759-15763 "\x08")) (esc)
          (Or 15769-15836
            (Return 15769-15782
              (String 15770-15774 "\f")
              (String 15777-15781 "\x0c")) (esc)
            (Or 15787-15836
              (Return 15787-15800
                (String 15788-15792 "\n")
                (String 15795-15799 "
  "))
              (Or 15805-15836
                (Return 15805-15818
                  (String 15806-15810 "\r")
                  (String 15813-15817 "\r (no-eol) (esc)
  "))
                (Return 15823-15836
                  (String 15824-15828 "\t")
                  (String 15831-15835 "\t"))))))))) (esc)
  (DeclareGlobal 15838-15969
    (ParserVar 15838-15859 _toml.escaped_unicode)
    (Or 15864-15969
      (Return 15864-15914
        (Destructure 15865-15897
          (TakeRight 15865-15892
            (String 15865-15869 "\u")
            (Function 15872-15892 (ParserVar 15872-15879 repeat4) ((ParserVar 15880-15891 hex_numeral))))
          (ValueVar 15896-15897 U))
        (Function 15900-15913 (ValueVar 15900-15910 @Codepoint) ((ValueVar 15911-15912 U))))
      (Return 15919-15969
        (Destructure 15920-15952
          (TakeRight 15920-15947
            (String 15920-15924 "\U")
            (Function 15927-15947 (ParserVar 15927-15934 repeat8) ((ParserVar 15935-15946 hex_numeral))))
          (ValueVar 15951-15952 U))
        (Function 15955-15968 (ValueVar 15955-15965 @Codepoint) ((ValueVar 15966-15967 U))))))
  (DeclareGlobal 15971-16067
    (ParserVar 15971-15991 toml.datetime.offset)
    (Merge 15994-16067
      (Merge 15994-16038
        (ParserVar 15994-16018 toml.datetime.local_date)
        (Or 16021-16038
          (String 16022-16025 "T")
          (Or 16028-16037
            (String 16028-16031 "t")
            (String 16034-16037 " "))))
      (ParserVar 16041-16067 _toml.datetime.time_offset)))
  (DeclareGlobal 16069-16162
    (ParserVar 16069-16088 toml.datetime.local)
    (Merge 16091-16162
      (Merge 16091-16135
        (ParserVar 16091-16115 toml.datetime.local_date)
        (Or 16118-16135
          (String 16119-16122 "T")
          (Or 16125-16134
            (String 16125-16128 "t")
            (String 16131-16134 " "))))
      (ParserVar 16138-16162 toml.datetime.local_time)))
  (DeclareGlobal 16164-16269
    (ParserVar 16164-16188 toml.datetime.local_date)
    (Merge 16193-16269
      (Merge 16193-16247
        (Merge 16193-16241
          (Merge 16193-16218
            (ParserVar 16193-16212 _toml.datetime.year)
            (String 16215-16218 "-"))
          (ParserVar 16221-16241 _toml.datetime.month))
        (String 16244-16247 "-"))
      (ParserVar 16250-16269 _toml.datetime.mday)))
  (DeclareGlobal 16271-16309
    (ParserVar 16271-16290 _toml.datetime.year)
    (Function 16293-16309 (ParserVar 16293-16300 repeat4) ((ParserVar 16301-16308 numeral))))
  (DeclareGlobal 16311-16364
    (ParserVar 16311-16331 _toml.datetime.month)
    (Or 16334-16364
      (Merge 16334-16350
        (String 16335-16338 "0")
        (Range 16341-16349 (String 16341-16344 "1") (String 16346-16349 "9")))
      (Or 16353-16364
        (String 16353-16357 "11")
        (String 16360-16364 "12"))))
  (DeclareGlobal 16366-16423
    (ParserVar 16366-16385 _toml.datetime.mday)
    (Or 16388-16423
      (Merge 16388-16409
        (Range 16389-16397 (String 16389-16392 "0") (String 16394-16397 "2"))
        (Range 16400-16408 (String 16400-16403 "1") (String 16405-16408 "9")))
      (Or 16412-16423
        (String 16412-16416 "30")
        (String 16419-16423 "31"))))
  (DeclareGlobal 16425-16589
    (ParserVar 16425-16449 toml.datetime.local_time)
    (Merge 16454-16589
      (Merge 16454-16540
        (Merge 16454-16513
          (Merge 16454-16507
            (Merge 16454-16480
              (ParserVar 16454-16474 _toml.datetime.hours)
              (String 16477-16480 ":"))
            (ParserVar 16485-16507 _toml.datetime.minutes))
          (String 16510-16513 ":"))
        (ParserVar 16518-16540 _toml.datetime.seconds))
      (Function 16545-16589
        (ParserVar 16545-16550 maybe)
        ((Merge 16551-16588
            (String 16551-16554 ".")
            (Function 16557-16588
              (ParserVar 16557-16571 repeat_between)
              ((ParserVar 16572-16579 numeral)
               (ValueLabel 16581-16582 (NumberString 16582-16583 1))
               (ValueLabel 16585-16586 (NumberString 16586-16587 9)))))))))
  (DeclareGlobal 16591-16690
    (ParserVar 16591-16617 _toml.datetime.time_offset)
    (Merge 16620-16690
      (ParserVar 16620-16644 toml.datetime.local_time)
      (Or 16647-16690
        (String 16648-16651 "Z")
        (Or 16654-16689
          (String 16654-16657 "z")
          (ParserVar 16660-16689 _toml.datetime.time_numoffset)))))
  (DeclareGlobal 16692-16789
    (ParserVar 16692-16721 _toml.datetime.time_numoffset)
    (Merge 16724-16789
      (Merge 16724-16764
        (Merge 16724-16758
          (Or 16724-16735
            (String 16725-16728 "+")
            (String 16731-16734 "-"))
          (ParserVar 16738-16758 _toml.datetime.hours))
        (String 16761-16764 ":"))
      (ParserVar 16767-16789 _toml.datetime.minutes)))
  (DeclareGlobal 16791-16854
    (ParserVar 16791-16811 _toml.datetime.hours)
    (Or 16814-16854
      (Merge 16814-16835
        (Range 16815-16823 (String 16815-16818 "0") (String 16820-16823 "1"))
        (Range 16826-16834 (String 16826-16829 "0") (String 16831-16834 "9")))
      (Merge 16838-16854
        (String 16839-16842 "2")
        (Range 16845-16853 (String 16845-16848 "0") (String 16850-16853 "3")))))
  (DeclareGlobal 16856-16900
    (ParserVar 16856-16878 _toml.datetime.minutes)
    (Merge 16881-16900
      (Range 16881-16889 (String 16881-16884 "0") (String 16886-16889 "5"))
      (Range 16892-16900 (String 16892-16895 "0") (String 16897-16900 "9"))))
  (DeclareGlobal 16902-16955
    (ParserVar 16902-16924 _toml.datetime.seconds)
    (Or 16927-16955
      (Merge 16927-16948
        (Range 16928-16936 (String 16928-16931 "0") (String 16933-16936 "5"))
        (Range 16939-16947 (String 16939-16942 "0") (String 16944-16947 "9")))
      (String 16951-16955 "60")))
  (DeclareGlobal 16957-17041
    (ParserVar 16957-16976 toml.number.integer)
    (Function 16979-17041
      (ParserVar 16979-16988 as_number)
      ((Merge 16992-17039
          (ParserVar 16992-17009 _toml.number.sign)
          (ParserVar 17014-17039 _toml.number.integer_part)))))
  (DeclareGlobal 17043-17085
    (ParserVar 17043-17060 _toml.number.sign)
    (Function 17063-17085
      (ParserVar 17063-17068 maybe)
      ((Or 17069-17084
          (String 17069-17072 "-")
          (Function 17075-17084 (ParserVar 17075-17079 skip) ((String 17080-17083 "+")))))))
  (DeclareGlobal 17087-17166
    (ParserVar 17087-17112 _toml.number.integer_part)
    (Or 17117-17166
      (Merge 17117-17156
        (Range 17118-17126 (String 17118-17121 "1") (String 17123-17126 "9"))
        (Function 17129-17155
          (ParserVar 17129-17133 many)
          ((TakeRight 17134-17154
              (Function 17134-17144 (ParserVar 17134-17139 maybe) ((String 17140-17143 "_")))
              (ParserVar 17147-17154 numeral)))))
      (ParserVar 17159-17166 numeral)))
  (DeclareGlobal 17168-17360
    (ParserVar 17168-17185 toml.number.float)
    (Function 17188-17360
      (ParserVar 17188-17197 as_number)
      ((Merge 17201-17358
          (Merge 17201-17248
            (ParserVar 17201-17218 _toml.number.sign)
            (ParserVar 17223-17248 _toml.number.integer_part))
          (Or 17251-17358
            (Merge 17257-17321
              (ParserVar 17258-17284 _toml.number.fraction_part)
              (Function 17287-17320 (ParserVar 17287-17292 maybe) ((ParserVar 17293-17319 _toml.number.exponent_part))))
            (ParserVar 17328-17354 _toml.number.exponent_part))))))
  (DeclareGlobal 17362-17427
    (ParserVar 17362-17388 _toml.number.fraction_part)
    (Merge 17391-17427
      (String 17391-17394 ".")
      (Function 17397-17427 (ParserVar 17397-17405 many_sep) ((ParserVar 17406-17414 numerals) (Function 17416-17426 (ParserVar 17416-17421 maybe) ((String 17422-17425 "_")))))))
  (DeclareGlobal 17429-17523
    (ParserVar 17429-17455 _toml.number.exponent_part)
    (Merge 17460-17523
      (Merge 17460-17490
        (Or 17460-17471
          (String 17461-17464 "e")
          (String 17467-17470 "E"))
        (Function 17474-17490
          (ParserVar 17474-17479 maybe)
          ((Or 17480-17489
              (String 17480-17483 "-")
              (String 17486-17489 "+")))))
      (Function 17493-17523 (ParserVar 17493-17501 many_sep) ((ParserVar 17502-17510 numerals) (Function 17512-17522 (ParserVar 17512-17517 maybe) ((String 17518-17521 "_")))))))
  (DeclareGlobal 17525-17572
    (ParserVar 17525-17545 toml.number.infinity)
    (Merge 17548-17572
      (Function 17548-17564
        (ParserVar 17548-17553 maybe)
        ((Or 17554-17563
            (String 17554-17557 "+")
            (String 17560-17563 "-"))))
      (String 17567-17572 "inf")))
  (DeclareGlobal 17574-17625
    (ParserVar 17574-17598 toml.number.not_a_number)
    (Merge 17601-17625
      (Function 17601-17617
        (ParserVar 17601-17606 maybe)
        ((Or 17607-17616
            (String 17607-17610 "+")
            (String 17613-17616 "-"))))
      (String 17620-17625 "nan")))
  (DeclareGlobal 17627-17836
    (ParserVar 17627-17653 toml.number.binary_integer)
    (TakeRight 17658-17836
      (String 17658-17662 "0b")
      (Return 17665-17836
        (Destructure 17665-17803
          (Function 17665-17793
            (ParserVar 17665-17676 one_or_both)
            ((Merge 17682-17748
                (Function 17682-17706 (ParserVar 17682-17691 array_sep) ((NumberString 17692-17693 0) (Function 17695-17705 (ParserVar 17695-17700 maybe) ((String 17701-17704 "_")))))
                (Function 17709-17748
                  (ParserVar 17709-17714 maybe)
                  ((TakeLeft 17715-17747
                      (Function 17715-17724 (ParserVar 17715-17719 skip) ((String 17720-17723 "_")))
                      (Function 17727-17747 (ParserVar 17727-17731 peek) ((ParserVar 17732-17746 binary_numeral)))))))
             (Function 17754-17789 (ParserVar 17754-17763 array_sep) ((ParserVar 17764-17776 binary_digit) (Function 17778-17788 (ParserVar 17778-17783 maybe) ((String 17784-17787 "_")))))))
          (ValueVar 17797-17803 Digits))
        (Function 17808-17836 (ValueVar 17808-17828 Num.FromBinaryDigits) ((ValueVar 17829-17835 Digits))))))
  (DeclareGlobal 17838-18043
    (ParserVar 17838-17863 toml.number.octal_integer)
    (TakeRight 17868-18043
      (String 17868-17872 "0o")
      (Return 17875-18043
        (Destructure 17875-18011
          (Function 17875-18001
            (ParserVar 17875-17886 one_or_both)
            ((Merge 17892-17957
                (Function 17892-17916 (ParserVar 17892-17901 array_sep) ((NumberString 17902-17903 0) (Function 17905-17915 (ParserVar 17905-17910 maybe) ((String 17911-17914 "_")))))
                (Function 17919-17957
                  (ParserVar 17919-17924 maybe)
                  ((TakeLeft 17925-17956
                      (Function 17925-17934 (ParserVar 17925-17929 skip) ((String 17930-17933 "_")))
                      (Function 17937-17956 (ParserVar 17937-17941 peek) ((ParserVar 17942-17955 octal_numeral)))))))
             (Function 17963-17997 (ParserVar 17963-17972 array_sep) ((ParserVar 17973-17984 octal_digit) (Function 17986-17996 (ParserVar 17986-17991 maybe) ((String 17992-17995 "_")))))))
          (ValueVar 18005-18011 Digits))
        (Function 18016-18043 (ValueVar 18016-18035 Num.FromOctalDigits) ((ValueVar 18036-18042 Digits))))))
  (DeclareGlobal 18045-18242
    (ParserVar 18045-18068 toml.number.hex_integer)
    (TakeRight 18073-18242
      (String 18073-18077 "0x")
      (Return 18080-18242
        (Destructure 18080-18212
          (Function 18080-18202
            (ParserVar 18080-18091 one_or_both)
            ((Merge 18097-18160
                (Function 18097-18121 (ParserVar 18097-18106 array_sep) ((NumberString 18107-18108 0) (Function 18110-18120 (ParserVar 18110-18115 maybe) ((String 18116-18119 "_")))))
                (Function 18124-18160
                  (ParserVar 18124-18129 maybe)
                  ((TakeLeft 18130-18159
                      (Function 18130-18139 (ParserVar 18130-18134 skip) ((String 18135-18138 "_")))
                      (Function 18142-18159 (ParserVar 18142-18146 peek) ((ParserVar 18147-18158 hex_numeral)))))))
             (Function 18166-18198 (ParserVar 18166-18175 array_sep) ((ParserVar 18176-18185 hex_digit) (Function 18187-18197 (ParserVar 18187-18192 maybe) ((String 18193-18196 "_")))))))
          (ValueVar 18206-18212 Digits))
        (Function 18217-18242 (ValueVar 18217-18234 Num.FromHexDigits) ((ValueVar 18235-18241 Digits))))))
  (DeclareGlobal 18244-18287
    (ValueVar 18244-18259 _Toml.Doc.Empty)
    (Object 18262-18287
      ((String 18263-18270 "value") (Object 18272-18275))
      ((String 18276-18282 "type") (Object 18284-18287))))
  (DeclareGlobal 18289-18333
    (Function 18289-18309 (ValueVar 18289-18304 _Toml.Doc.Value) ((ValueVar 18305-18308 Doc)))
    (Function 18312-18333 (ValueVar 18312-18319 Obj.Get) ((ValueVar 18320-18323 Doc) (String 18325-18332 "value"))))
  (DeclareGlobal 18335-18377
    (Function 18335-18354 (ValueVar 18335-18349 _Toml.Doc.Type) ((ValueVar 18350-18353 Doc)))
    (Function 18357-18377 (ValueVar 18357-18364 Obj.Get) ((ValueVar 18365-18368 Doc) (String 18370-18376 "type"))))
  (DeclareGlobal 18379-18438
    (Function 18379-18402 (ValueVar 18379-18392 _Toml.Doc.Has) ((ValueVar 18393-18396 Doc) (ValueVar 18398-18401 Key)))
    (Function 18405-18438 (ValueVar 18405-18412 Obj.Has) ((Function 18413-18432 (ValueVar 18413-18427 _Toml.Doc.Type) ((ValueVar 18428-18431 Doc))) (ValueVar 18434-18437 Key))))
  (DeclareGlobal 18440-18561
    (Function 18440-18463 (ValueVar 18440-18453 _Toml.Doc.Get) ((ValueVar 18454-18457 Doc) (ValueVar 18459-18462 Key)))
    (Object 18466-18561
      ((String 18470-18477 "value") (Function 18479-18513 (ValueVar 18479-18486 Obj.Get) ((Function 18487-18507 (ValueVar 18487-18502 _Toml.Doc.Value) ((ValueVar 18503-18506 Doc))) (ValueVar 18509-18512 Key))))
      ((String 18517-18523 "type") (Function 18525-18558 (ValueVar 18525-18532 Obj.Get) ((Function 18533-18552 (ValueVar 18533-18547 _Toml.Doc.Type) ((ValueVar 18548-18551 Doc))) (ValueVar 18554-18557 Key))))))
  (DeclareGlobal 18563-18618
    (Function 18563-18585 (ValueVar 18563-18580 _Toml.Doc.IsTable) ((ValueVar 18581-18584 Doc)))
    (Function 18588-18618 (ValueVar 18588-18597 Is.Object) ((Function 18598-18617 (ValueVar 18598-18612 _Toml.Doc.Type) ((ValueVar 18613-18616 Doc))))))
  (DeclareGlobal 18620-18801
    (Function 18620-18657
      (ValueVar 18620-18636 _Toml.Doc.Insert)
      ((ValueVar 18637-18640 Doc)
       (ValueVar 18642-18645 Key)
       (ValueVar 18647-18650 Val)
       (ValueVar 18652-18656 Type)))
    (TakeRight 18662-18801
      (Function 18662-18684 (ValueVar 18662-18679 _Toml.Doc.IsTable) ((ValueVar 18680-18683 Doc)))
      (Object 18689-18801
        ((String 18695-18702 "value") (Function 18704-18743
            (ValueVar 18704-18711 Obj.Put)
            ((Function 18712-18732 (ValueVar 18712-18727 _Toml.Doc.Value) ((ValueVar 18728-18731 Doc)))
             (ValueVar 18734-18737 Key)
             (ValueVar 18739-18742 Val))))
        ((String 18749-18755 "type") (Function 18757-18796
            (ValueVar 18757-18764 Obj.Put)
            ((Function 18765-18784 (ValueVar 18765-18779 _Toml.Doc.Type) ((ValueVar 18780-18783 Doc)))
             (ValueVar 18786-18789 Key)
             (ValueVar 18791-18795 Type)))))))
  (DeclareGlobal 18803-18987
    (Function 18803-18849
      (ValueVar 18803-18834 _Toml.Doc.AppendToArrayOfTables)
      ((ValueVar 18835-18838 Doc)
       (ValueVar 18840-18843 Key)
       (ValueVar 18845-18848 Val)))
    (TakeRight 18854-18987
      (Destructure 18854-18922
        (Function 18854-18877 (ValueVar 18854-18867 _Toml.Doc.Get) ((ValueVar 18868-18871 Doc) (ValueVar 18873-18876 Key)))
        (Object 18881-18922
          ((String 18882-18889 "value") (ValueVar 18891-18894 AoT))
          ((String 18896-18902 "type") (String 18904-18921 "array_of_tables"))))
      (Function 18927-18987
        (ValueVar 18927-18943 _Toml.Doc.Insert)
        ((ValueVar 18944-18947 Doc)
         (ValueVar 18949-18952 Key)
         (Merge 18958-18967
            (Merge 18958-18961
              (Array 18954-18955 ())
              (ValueVar 18958-18961 AoT))
            (Array 18963-18967 ((ValueVar 18963-18966 Val))))
         (String 18969-18986 "array_of_tables")))))
  (DeclareGlobal 18989-19094
    (Function 18989-19027
      (ValueVar 18989-19011 _Toml.Doc.InsertAtPath)
      ((ValueVar 19012-19015 Doc)
       (ValueVar 19017-19021 Path)
       (ValueVar 19023-19026 Val)))
    (Function 19032-19094
      (ValueVar 19032-19054 _Toml.Doc.UpdateAtPath)
      ((ValueVar 19055-19058 Doc)
       (ValueVar 19060-19064 Path)
       (ValueVar 19066-19069 Val)
       (ValueVar 19071-19093 _Toml.Doc.ValueUpdater))))
  (DeclareGlobal 19096-19207
    (Function 19096-19134 (ValueVar 19096-19123 _Toml.Doc.EnsureTableAtPath) ((ValueVar 19124-19127 Doc) (ValueVar 19129-19133 Path)))
    (Function 19139-19207
      (ValueVar 19139-19161 _Toml.Doc.UpdateAtPath)
      ((ValueVar 19162-19165 Doc)
       (ValueVar 19167-19171 Path)
       (Object 19173-19176)
       (ValueVar 19177-19206 _Toml.Doc.MissingTableUpdater))))
  (DeclareGlobal 19209-19315
    (Function 19209-19247
      (ValueVar 19209-19231 _Toml.Doc.AppendAtPath)
      ((ValueVar 19232-19235 Doc)
       (ValueVar 19237-19241 Path)
       (ValueVar 19243-19246 Val)))
    (Function 19252-19315
      (ValueVar 19252-19274 _Toml.Doc.UpdateAtPath)
      ((ValueVar 19275-19278 Doc)
       (ValueVar 19280-19284 Path)
       (ValueVar 19286-19289 Val)
       (ValueVar 19291-19314 _Toml.Doc.AppendUpdater))))
  (DeclareGlobal 19317-19811
    (Function 19317-19364
      (ValueVar 19317-19339 _Toml.Doc.UpdateAtPath)
      ((ValueVar 19340-19343 Doc)
       (ValueVar 19345-19349 Path)
       (ValueVar 19351-19354 Val)
       (ValueVar 19356-19363 Updater)))
    (Conditional 19369-19811
      (condition (Destructure 19369-19382
          (ValueVar 19369-19373 Path)
          (Array 19377-19382 ((ValueVar 19378-19381 Key)))))
      (then (Function 19385-19407
          (ValueVar 19385-19392 Updater)
          ((ValueVar 19393-19396 Doc)
           (ValueVar 19398-19401 Key)
           (ValueVar 19403-19406 Val))))
      (else (Conditional 19412-19811
          (condition (Destructure 19412-19438
              (ValueVar 19412-19416 Path)
              (Merge 19429-19438
                (Array 19420-19421 ((ValueVar 19421-19424 Key)))
                (ValueVar 19429-19437 PathRest))))
          (then (TakeRight 19441-19803
              (Destructure 19447-19713
                (Conditional 19447-19701
                  (condition (Function 19455-19478 (ValueVar 19455-19468 _Toml.Doc.Has) ((ValueVar 19469-19472 Doc) (ValueVar 19474-19477 Key))))
                  (then (TakeRight 19481-19623
                      (Function 19491-19533 (ValueVar 19491-19508 _Toml.Doc.IsTable) ((Function 19509-19532 (ValueVar 19509-19522 _Toml.Doc.Get) ((ValueVar 19523-19526 Doc) (ValueVar 19528-19531 Key)))))
                      (Function 19544-19615
                        (ValueVar 19544-19566 _Toml.Doc.UpdateAtPath)
                        ((Function 19567-19590 (ValueVar 19567-19580 _Toml.Doc.Get) ((ValueVar 19581-19584 Doc) (ValueVar 19586-19589 Key)))
                         (ValueVar 19592-19600 PathRest)
                         (ValueVar 19602-19605 Val)
                         (ValueVar 19607-19614 Updater)))))
                  (else (Function 19632-19695
                      (ValueVar 19632-19654 _Toml.Doc.UpdateAtPath)
                      ((ValueVar 19655-19670 _Toml.Doc.Empty)
                       (ValueVar 19672-19680 PathRest)
                       (ValueVar 19682-19685 Val)
                       (ValueVar 19687-19694 Updater)))))
                (ValueVar 19705-19713 InnerDoc))
              (Function 19720-19799
                (ValueVar 19720-19736 _Toml.Doc.Insert)
                ((ValueVar 19737-19740 Doc)
                 (ValueVar 19742-19745 Key)
                 (Function 19747-19772 (ValueVar 19747-19762 _Toml.Doc.Value) ((ValueVar 19763-19771 InnerDoc)))
                 (Function 19774-19798 (ValueVar 19774-19788 _Toml.Doc.Type) ((ValueVar 19789-19797 InnerDoc)))))))
          (else (ValueVar 19808-19811 Doc))))))
  (DeclareGlobal 19813-19929
    (Function 19813-19850
      (ValueVar 19813-19835 _Toml.Doc.ValueUpdater)
      ((ValueVar 19836-19839 Doc)
       (ValueVar 19841-19844 Key)
       (ValueVar 19846-19849 Val)))
    (Conditional 19855-19929
      (condition (Function 19855-19878 (ValueVar 19855-19868 _Toml.Doc.Has) ((ValueVar 19869-19872 Doc) (ValueVar 19874-19877 Key))))
      (then (ValueVar 19881-19886 @Fail))
      (else (Function 19889-19929
          (ValueVar 19889-19905 _Toml.Doc.Insert)
          ((ValueVar 19906-19909 Doc)
           (ValueVar 19911-19914 Key)
           (ValueVar 19916-19919 Val)
           (String 19921-19928 "value"))))))
  (DeclareGlobal 19931-20068
    (Function 19931-19976
      (ValueVar 19931-19960 _Toml.Doc.MissingTableUpdater)
      ((ValueVar 19961-19964 Doc)
       (ValueVar 19966-19969 Key)
       (ValueVar 19971-19975 _Val)))
    (Conditional 19981-20068
      (condition (Function 19981-20023 (ValueVar 19981-19998 _Toml.Doc.IsTable) ((Function 19999-20022 (ValueVar 19999-20012 _Toml.Doc.Get) ((ValueVar 20013-20016 Doc) (ValueVar 20018-20021 Key))))))
      (then (ValueVar 20026-20029 Doc))
      (else (Function 20034-20068
          (ValueVar 20034-20050 _Toml.Doc.Insert)
          ((ValueVar 20051-20054 Doc)
           (ValueVar 20056-20059 Key)
           (Object 20061-20064)
           (Object 20065-20068))))))
  (DeclareGlobal 20070-20280
    (Function 20070-20108
      (ValueVar 20070-20093 _Toml.Doc.AppendUpdater)
      ((ValueVar 20094-20097 Doc)
       (ValueVar 20099-20102 Key)
       (ValueVar 20104-20107 Val)))
    (TakeRight 20113-20280
      (Destructure 20113-20222
        (Conditional 20113-20208
          (condition (Function 20119-20142 (ValueVar 20119-20132 _Toml.Doc.Has) ((ValueVar 20133-20136 Doc) (ValueVar 20138-20141 Key))))
          (then (ValueVar 20145-20148 Doc))
          (else (Function 20155-20204
              (ValueVar 20155-20171 _Toml.Doc.Insert)
              ((ValueVar 20172-20175 Doc)
               (ValueVar 20177-20180 Key)
               (Array 20182-20185 ())
               (String 20186-20203 "array_of_tables")))))
        (ValueVar 20212-20222 DocWithKey))
      (Function 20227-20280
        (ValueVar 20227-20258 _Toml.Doc.AppendToArrayOfTables)
        ((ValueVar 20259-20269 DocWithKey)
         (ValueVar 20271-20274 Key)
         (ValueVar 20276-20279 Val)))))
  (DeclareGlobal 20309-20438
    (Function 20309-20370
      (ParserVar 20309-20337 ast.with_operator_precedence)
      ((ParserVar 20338-20345 operand)
       (ParserVar 20347-20353 prefix)
       (ParserVar 20355-20360 infix)
       (ParserVar 20362-20369 postfix)))
    (Function 20375-20438
      (ParserVar 20375-20401 _ast.with_precedence_start)
      ((ParserVar 20402-20409 operand)
       (ParserVar 20411-20417 prefix)
       (ParserVar 20419-20424 infix)
       (ParserVar 20426-20433 postfix)
       (ValueLabel 20435-20436 (NumberString 20436-20437 0)))))
  (DeclareGlobal 20440-20949
    (Function 20440-20517
      (ParserVar 20440-20466 _ast.with_precedence_start)
      ((ParserVar 20467-20474 operand)
       (ParserVar 20476-20482 prefix)
       (ParserVar 20484-20489 infix)
       (ParserVar 20491-20498 postfix)
       (ValueVar 20500-20516 LeftBindingPower)))
    (Conditional 20522-20949
      (condition (Destructure 20522-20560
          (ParserVar 20522-20528 prefix)
          (Array 20532-20560 ((ValueVar 20533-20539 OpNode) (ValueVar 20541-20559 PrefixBindingPower)))))
      (then (TakeRight 20563-20832
          (Destructure 20569-20682
            (Function 20569-20666
              (ParserVar 20569-20595 _ast.with_precedence_start)
              ((ParserVar 20603-20610 operand)
               (ParserVar 20612-20618 prefix)
               (ParserVar 20620-20625 infix)
               (ParserVar 20627-20634 postfix)
               (ValueVar 20642-20660 PrefixBindingPower)))
            (ValueVar 20670-20682 PrefixedNode))
          (Function 20689-20828
            (ParserVar 20689-20714 _ast.with_precedence_rest)
            ((ParserVar 20722-20729 operand)
             (ParserVar 20731-20737 prefix)
             (ParserVar 20739-20744 infix)
             (ParserVar 20746-20753 postfix)
             (ValueVar 20761-20777 LeftBindingPower)
             (Merge 20789-20822
                (Merge 20789-20795
                  (Object 20785-20786)
                  (ValueVar 20789-20795 OpNode))
                (Object 20797-20822
                  ((String 20797-20807 "prefixed") (ValueVar 20809-20821 PrefixedNode))))))))
      (else (TakeRight 20835-20949
          (Destructure 20841-20856
            (ParserVar 20841-20848 operand)
            (ValueVar 20852-20856 Node))
          (Function 20863-20945
            (ParserVar 20863-20888 _ast.with_precedence_rest)
            ((ParserVar 20889-20896 operand)
             (ParserVar 20898-20904 prefix)
             (ParserVar 20906-20911 infix)
             (ParserVar 20913-20920 postfix)
             (ValueVar 20922-20938 LeftBindingPower)
             (ValueVar 20940-20944 Node)))))))
  (DeclareGlobal 20951-21699
    (Function 20951-21033
      (ParserVar 20951-20976 _ast.with_precedence_rest)
      ((ParserVar 20977-20984 operand)
       (ParserVar 20986-20992 prefix)
       (ParserVar 20994-20999 infix)
       (ParserVar 21001-21008 postfix)
       (ValueVar 21010-21026 LeftBindingPower)
       (ValueVar 21028-21032 Node)))
    (Conditional 21038-21699
      (condition (TakeRight 21038-21136
          (Destructure 21038-21076
            (ParserVar 21038-21045 postfix)
            (Array 21049-21076 ((ValueVar 21050-21056 OpNode) (ValueVar 21058-21075 RightBindingPower))))
          (Function 21081-21136 (ParserVar 21081-21086 const) ((Function 21087-21135 (ValueVar 21087-21098 Is.LessThan) ((ValueVar 21099-21115 LeftBindingPower) (ValueVar 21117-21134 RightBindingPower)))))))
      (then (Function 21139-21281
          (ParserVar 21145-21170 _ast.with_precedence_rest)
          ((ParserVar 21178-21185 operand)
           (ParserVar 21187-21193 prefix)
           (ParserVar 21195-21200 infix)
           (ParserVar 21202-21209 postfix)
           (ValueVar 21217-21233 LeftBindingPower)
           (Merge 21245-21271
              (Merge 21245-21251
                (Object 21241-21242)
                (ValueVar 21245-21251 OpNode))
              (Object 21253-21271
                ((String 21253-21264 "postfixed") (ValueVar 21266-21270 Node)))))))
      (else (Conditional 21286-21699
          (condition (TakeRight 21286-21404
              (Destructure 21286-21344
                (ParserVar 21286-21291 infix)
                (Array 21295-21344 ((ValueVar 21296-21302 OpNode) (ValueVar 21304-21321 RightBindingPower) (ValueVar 21323-21343 NextLeftBindingPower))))
              (Function 21349-21404 (ParserVar 21349-21354 const) ((Function 21355-21403 (ValueVar 21355-21366 Is.LessThan) ((ValueVar 21367-21383 LeftBindingPower) (ValueVar 21385-21402 RightBindingPower)))))))
          (then (TakeRight 21407-21683
              (Destructure 21413-21525
                (Function 21413-21512
                  (ParserVar 21413-21439 _ast.with_precedence_start)
                  ((ParserVar 21447-21454 operand)
                   (ParserVar 21456-21462 prefix)
                   (ParserVar 21464-21469 infix)
                   (ParserVar 21471-21478 postfix)
                   (ValueVar 21486-21506 NextLeftBindingPower)))
                (ValueVar 21516-21525 RightNode))
              (Function 21532-21679
                (ParserVar 21532-21557 _ast.with_precedence_rest)
                ((ParserVar 21565-21572 operand)
                 (ParserVar 21574-21580 prefix)
                 (ParserVar 21582-21587 infix)
                 (ParserVar 21589-21596 postfix)
                 (ValueVar 21604-21620 LeftBindingPower)
                 (Merge 21632-21673
                    (Merge 21632-21638
                      (Object 21628-21629)
                      (ValueVar 21632-21638 OpNode))
                    (Object 21640-21673
                      ((String 21640-21646 "left") (ValueVar 21648-21652 Node))
                      ((String 21654-21661 "right") (ValueVar 21663-21672 RightNode))))))))
          (else (Function 21688-21699 (ParserVar 21688-21693 const) ((ValueVar 21694-21698 Node))))))))
  (DeclareGlobal 21701-21774
    (Function 21701-21722 (ParserVar 21701-21709 ast.node) ((ValueVar 21710-21714 Type) (ParserVar 21716-21721 value)))
    (Return 21727-21774
      (Destructure 21727-21741
        (ParserVar 21727-21732 value)
        (ValueVar 21736-21741 Value))
      (Object 21744-21774
        ((String 21745-21751 "type") (ValueVar 21753-21757 Type))
        ((String 21759-21766 "value") (ValueVar 21768-21773 Value)))))
  (DeclareGlobal 21798-21812
    (ValueVar 21798-21805 Num.Add)
    (ValueVar 21808-21812 @Add))
  (DeclareGlobal 21814-21833
    (ValueVar 21814-21821 Num.Sub)
    (ValueVar 21824-21833 @Subtract))
  (DeclareGlobal 21835-21854
    (ValueVar 21835-21842 Num.Mul)
    (ValueVar 21845-21854 @Multiply))
  (DeclareGlobal 21856-21873
    (ValueVar 21856-21863 Num.Div)
    (ValueVar 21866-21873 @Divide))
  (DeclareGlobal 21875-21891
    (ValueVar 21875-21882 Num.Pow)
    (ValueVar 21885-21891 @Power))
  (DeclareGlobal 21893-21916
    (Function 21893-21903 (ValueVar 21893-21900 Num.Inc) ((ValueVar 21901-21902 N)))
    (Function 21906-21916 (ValueVar 21906-21910 @Add) ((ValueVar 21911-21912 N) (NumberString 21914-21915 1))))
  (DeclareGlobal 21918-21946
    (Function 21918-21928 (ValueVar 21918-21925 Num.Dec) ((ValueVar 21926-21927 N)))
    (Function 21931-21946 (ValueVar 21931-21940 @Subtract) ((ValueVar 21941-21942 N) (NumberString 21944-21945 1))))
  (DeclareGlobal 21948-21974
    (Function 21948-21958 (ValueVar 21948-21955 Num.Abs) ((ValueVar 21956-21957 N)))
    (Or 21961-21974
      (Destructure 21961-21969
        (ValueVar 21961-21962 N)
        (Range 21966-21969 (NumberString 21966-21967 0) ()))
      (Negation 21972-21974 (ValueVar 21973-21974 N))))
  (DeclareGlobal 21976-22008
    (Function 21976-21989 (ValueVar 21976-21983 Num.Max) ((ValueVar 21984-21985 A) (ValueVar 21987-21988 B)))
    (Conditional 21992-22008
      (condition (Destructure 21992-22000
          (ValueVar 21992-21993 A)
          (Range 21997-22000 (ValueVar 21997-21998 B) ())))
      (then (ValueVar 22003-22004 A))
      (else (ValueVar 22007-22008 B))))
  (DeclareGlobal 22010-22104
    (Function 22010-22034 (ValueVar 22010-22030 Num.FromBinaryDigits) ((ValueVar 22031-22033 Bs)))
    (TakeRight 22039-22104
      (Destructure 22039-22062
        (Function 22039-22055 (ValueVar 22039-22051 Array.Length) ((ValueVar 22052-22054 Bs)))
        (ValueVar 22059-22062 Len))
      (Function 22067-22104
        (ValueVar 22067-22088 _Num.FromBinaryDigits)
        ((ValueVar 22089-22091 Bs)
         (Merge 22093-22100
            (ValueVar 22093-22096 Len)
            (Negation 22099-22100 (NumberString 22099-22100 1)))
         (NumberString 22102-22103 0)))))
  (DeclareGlobal 22106-22297
    (Function 22106-22141
      (ValueVar 22106-22127 _Num.FromBinaryDigits)
      ((ValueVar 22128-22130 Bs)
       (ValueVar 22132-22135 Pos)
       (ValueVar 22137-22140 Acc)))
    (Conditional 22146-22297
      (condition (Destructure 22146-22164
          (ValueVar 22146-22148 Bs)
          (Merge 22159-22164
            (Array 22152-22153 ((ValueVar 22153-22154 B)))
            (ValueVar 22159-22163 Rest))))
      (then (TakeRight 22167-22289
          (Destructure 22173-22182
            (ValueVar 22173-22174 B)
            (Range 22178-22182 (NumberString 22178-22179 0) (NumberString 22181-22182 1)))
          (Function 22189-22285
            (ValueVar 22189-22210 _Num.FromBinaryDigits)
            ((ValueVar 22218-22222 Rest)
             (Merge 22230-22237
                (ValueVar 22230-22233 Pos)
                (Negation 22236-22237 (NumberString 22236-22237 1)))
             (Merge 22245-22278
                (ValueVar 22245-22248 Acc)
                (Function 22251-22278 (ValueVar 22251-22258 Num.Mul) ((ValueVar 22259-22260 B) (Function 22262-22277 (ValueVar 22262-22269 Num.Pow) ((NumberString 22270-22271 2) (ValueVar 22273-22276 Pos))))))))))
      (else (ValueVar 22294-22297 Acc))))
  (DeclareGlobal 22299-22391
    (Function 22299-22322 (ValueVar 22299-22318 Num.FromOctalDigits) ((ValueVar 22319-22321 Os)))
    (TakeRight 22327-22391
      (Destructure 22327-22350
        (Function 22327-22343 (ValueVar 22327-22339 Array.Length) ((ValueVar 22340-22342 Os)))
        (ValueVar 22347-22350 Len))
      (Function 22355-22391
        (ValueVar 22355-22375 _Num.FromOctalDigits)
        ((ValueVar 22376-22378 Os)
         (Merge 22380-22387
            (ValueVar 22380-22383 Len)
            (Negation 22386-22387 (NumberString 22386-22387 1)))
         (NumberString 22389-22390 0)))))
  (DeclareGlobal 22393-22582
    (Function 22393-22427
      (ValueVar 22393-22413 _Num.FromOctalDigits)
      ((ValueVar 22414-22416 Os)
       (ValueVar 22418-22421 Pos)
       (ValueVar 22423-22426 Acc)))
    (Conditional 22432-22582
      (condition (Destructure 22432-22450
          (ValueVar 22432-22434 Os)
          (Merge 22445-22450
            (Array 22438-22439 ((ValueVar 22439-22440 O)))
            (ValueVar 22445-22449 Rest))))
      (then (TakeRight 22453-22574
          (Destructure 22459-22468
            (ValueVar 22459-22460 O)
            (Range 22464-22468 (NumberString 22464-22465 0) (NumberString 22467-22468 7)))
          (Function 22475-22570
            (ValueVar 22475-22495 _Num.FromOctalDigits)
            ((ValueVar 22503-22507 Rest)
             (Merge 22515-22522
                (ValueVar 22515-22518 Pos)
                (Negation 22521-22522 (NumberString 22521-22522 1)))
             (Merge 22530-22563
                (ValueVar 22530-22533 Acc)
                (Function 22536-22563 (ValueVar 22536-22543 Num.Mul) ((ValueVar 22544-22545 O) (Function 22547-22562 (ValueVar 22547-22554 Num.Pow) ((NumberString 22555-22556 8) (ValueVar 22558-22561 Pos))))))))))
      (else (ValueVar 22579-22582 Acc))))
  (DeclareGlobal 22584-22672
    (Function 22584-22605 (ValueVar 22584-22601 Num.FromHexDigits) ((ValueVar 22602-22604 Hs)))
    (TakeRight 22610-22672
      (Destructure 22610-22633
        (Function 22610-22626 (ValueVar 22610-22622 Array.Length) ((ValueVar 22623-22625 Hs)))
        (ValueVar 22630-22633 Len))
      (Function 22638-22672
        (ValueVar 22638-22656 _Num.FromHexDigits)
        ((ValueVar 22657-22659 Hs)
         (Merge 22661-22668
            (ValueVar 22661-22664 Len)
            (Negation 22667-22668 (NumberString 22667-22668 1)))
         (NumberString 22670-22671 0)))))
  (DeclareGlobal 22674-22861
    (Function 22674-22706
      (ValueVar 22674-22692 _Num.FromHexDigits)
      ((ValueVar 22693-22695 Hs)
       (ValueVar 22697-22700 Pos)
       (ValueVar 22702-22705 Acc)))
    (Conditional 22711-22861
      (condition (Destructure 22711-22729
          (ValueVar 22711-22713 Hs)
          (Merge 22724-22729
            (Array 22717-22718 ((ValueVar 22718-22719 H)))
            (ValueVar 22724-22728 Rest))))
      (then (TakeRight 22732-22853
          (Destructure 22738-22748
            (ValueVar 22738-22739 H)
            (Range 22743-22748 (NumberString 22743-22744 0) (NumberString 22746-22748 15)))
          (Function 22755-22849
            (ValueVar 22755-22773 _Num.FromHexDigits)
            ((ValueVar 22781-22785 Rest)
             (Merge 22793-22800
                (ValueVar 22793-22796 Pos)
                (Negation 22799-22800 (NumberString 22799-22800 1)))
             (Merge 22808-22842
                (ValueVar 22808-22811 Acc)
                (Function 22814-22842 (ValueVar 22814-22821 Num.Mul) ((ValueVar 22822-22823 H) (Function 22825-22841 (ValueVar 22825-22832 Num.Pow) ((NumberString 22833-22835 16) (ValueVar 22837-22840 Pos))))))))))
      (else (ValueVar 22858-22861 Acc))))
  (DeclareGlobal 22874-22917
    (Function 22874-22892 (ValueVar 22874-22885 Array.First) ((ValueVar 22886-22891 Array)))
    (TakeRight 22895-22917
      (Destructure 22895-22913
        (ValueVar 22895-22900 Array)
        (Merge 22911-22913
          (Array 22904-22905 ((ValueVar 22905-22906 F)))
          (ValueVar 22911-22912 _)))
      (ValueVar 22916-22917 F)))
  (DeclareGlobal 22919-22961
    (Function 22919-22936 (ValueVar 22919-22929 Array.Rest) ((ValueVar 22930-22935 Array)))
    (TakeRight 22939-22961
      (Destructure 22939-22957
        (ValueVar 22939-22944 Array)
        (Merge 22955-22957
          (Array 22948-22949 ((ValueVar 22949-22950 _)))
          (ValueVar 22955-22956 R)))
      (ValueVar 22960-22961 R)))
  (DeclareGlobal 22963-23000
    (Function 22963-22978 (ValueVar 22963-22975 Array.Length) ((ValueVar 22976-22977 A)))
    (Function 22981-23000 (ValueVar 22981-22994 _Array.Length) ((ValueVar 22995-22996 A) (NumberString 22998-22999 0))))
  (DeclareGlobal 23002-23086
    (Function 23002-23023 (ValueVar 23002-23015 _Array.Length) ((ValueVar 23016-23017 A) (ValueVar 23019-23022 Acc)))
    (Conditional 23028-23086
      (condition (Destructure 23028-23045
          (ValueVar 23028-23029 A)
          (Merge 23040-23045
            (Array 23033-23034 ((ValueVar 23034-23035 _)))
            (ValueVar 23040-23044 Rest))))
      (then (Function 23050-23078
          (ValueVar 23050-23063 _Array.Length)
          ((ValueVar 23064-23068 Rest)
           (Merge 23070-23077
              (ValueVar 23070-23073 Acc)
              (NumberString 23076-23077 1)))))
      (else (ValueVar 23083-23086 Acc))))
  (DeclareGlobal 23088-23128
    (Function 23088-23104 (ValueVar 23088-23101 Array.Reverse) ((ValueVar 23102-23103 A)))
    (Function 23107-23128 (ValueVar 23107-23121 _Array.Reverse) ((ValueVar 23122-23123 A) (Array 23125-23128 ()))))
  (DeclareGlobal 23130-23228
    (Function 23130-23152 (ValueVar 23130-23144 _Array.Reverse) ((ValueVar 23145-23146 A) (ValueVar 23148-23151 Acc)))
    (Conditional 23157-23228
      (condition (Destructure 23157-23178
          (ValueVar 23157-23158 A)
          (Merge 23173-23178
            (Array 23162-23163 ((ValueVar 23163-23168 First)))
            (ValueVar 23173-23177 Rest))))
      (then (Function 23183-23220
          (ValueVar 23183-23197 _Array.Reverse)
          ((ValueVar 23198-23202 Rest)
           (Merge 23215-23219
              (Array 23204-23205 ((ValueVar 23205-23210 First)))
              (ValueVar 23215-23218 Acc)))))
      (else (ValueVar 23225-23228 Acc))))
  (DeclareGlobal 23230-23270
    (Function 23230-23246 (ValueVar 23230-23239 Array.Map) ((ValueVar 23240-23241 A) (ValueVar 23243-23245 Fn)))
    (Function 23249-23270
      (ValueVar 23249-23259 _Array.Map)
      ((ValueVar 23260-23261 A)
       (ValueVar 23263-23265 Fn)
       (Array 23267-23270 ()))))
  (DeclareGlobal 23272-23374
    (Function 23272-23294
      (ValueVar 23272-23282 _Array.Map)
      ((ValueVar 23283-23284 A)
       (ValueVar 23286-23288 Fn)
       (ValueVar 23290-23293 Acc)))
    (Conditional 23299-23374
      (condition (Destructure 23299-23320
          (ValueVar 23299-23300 A)
          (Merge 23315-23320
            (Array 23304-23305 ((ValueVar 23305-23310 First)))
            (ValueVar 23315-23319 Rest))))
      (then (Function 23325-23366
          (ValueVar 23325-23335 _Array.Map)
          ((ValueVar 23336-23340 Rest)
           (ValueVar 23342-23344 Fn)
           (Merge 23350-23365
              (Merge 23350-23353
                (Array 23346-23347 ())
                (ValueVar 23350-23353 Acc))
              (Array 23355-23365 ((Function 23355-23364 (ValueVar 23355-23357 Fn) ((ValueVar 23358-23363 First)))))))))
      (else (ValueVar 23371-23374 Acc))))
  (DeclareGlobal 23376-23426
    (Function 23376-23397 (ValueVar 23376-23388 Array.Filter) ((ValueVar 23389-23390 A) (ValueVar 23392-23396 Pred)))
    (Function 23400-23426
      (ValueVar 23400-23413 _Array.Filter)
      ((ValueVar 23414-23415 A)
       (ValueVar 23417-23421 Pred)
       (Array 23423-23426 ()))))
  (DeclareGlobal 23428-23556
    (Function 23428-23455
      (ValueVar 23428-23441 _Array.Filter)
      ((ValueVar 23442-23443 A)
       (ValueVar 23445-23449 Pred)
       (ValueVar 23451-23454 Acc)))
    (Conditional 23460-23556
      (condition (Destructure 23460-23481
          (ValueVar 23460-23461 A)
          (Merge 23476-23481
            (Array 23465-23466 ((ValueVar 23466-23471 First)))
            (ValueVar 23476-23480 Rest))))
      (then (Function 23486-23548
          (ValueVar 23486-23499 _Array.Filter)
          ((ValueVar 23500-23504 Rest)
           (ValueVar 23506-23510 Pred)
           (Conditional 23512-23547
              (condition (Function 23512-23523 (ValueVar 23512-23516 Pred) ((ValueVar 23517-23522 First))))
              (then (Merge 23530-23541
                  (Merge 23530-23533
                    (Array 23526-23527 ())
                    (ValueVar 23530-23533 Acc))
                  (Array 23535-23541 ((ValueVar 23535-23540 First)))))
              (else (ValueVar 23544-23547 Acc))))))
      (else (ValueVar 23553-23556 Acc))))
  (DeclareGlobal 23558-23608
    (Function 23558-23579 (ValueVar 23558-23570 Array.Reject) ((ValueVar 23571-23572 A) (ValueVar 23574-23578 Pred)))
    (Function 23582-23608
      (ValueVar 23582-23595 _Array.Reject)
      ((ValueVar 23596-23597 A)
       (ValueVar 23599-23603 Pred)
       (Array 23605-23608 ()))))
  (DeclareGlobal 23610-23738
    (Function 23610-23637
      (ValueVar 23610-23623 _Array.Reject)
      ((ValueVar 23624-23625 A)
       (ValueVar 23627-23631 Pred)
       (ValueVar 23633-23636 Acc)))
    (Conditional 23642-23738
      (condition (Destructure 23642-23663
          (ValueVar 23642-23643 A)
          (Merge 23658-23663
            (Array 23647-23648 ((ValueVar 23648-23653 First)))
            (ValueVar 23658-23662 Rest))))
      (then (Function 23668-23730
          (ValueVar 23668-23681 _Array.Reject)
          ((ValueVar 23682-23686 Rest)
           (ValueVar 23688-23692 Pred)
           (Conditional 23694-23729
              (condition (Function 23694-23705 (ValueVar 23694-23698 Pred) ((ValueVar 23699-23704 First))))
              (then (ValueVar 23708-23711 Acc))
              (else (Merge 23718-23729
                  (Merge 23718-23721
                    (Array 23714-23715 ())
                    (ValueVar 23718-23721 Acc))
                  (Array 23723-23729 ((ValueVar 23723-23728 First)))))))))
      (else (ValueVar 23735-23738 Acc))))
  (DeclareGlobal 23740-23794
    (Function 23740-23763 (ValueVar 23740-23755 Array.ZipObject) ((ValueVar 23756-23758 Ks) (ValueVar 23760-23762 Vs)))
    (Function 23766-23794
      (ValueVar 23766-23782 _Array.ZipObject)
      ((ValueVar 23783-23785 Ks)
       (ValueVar 23787-23789 Vs)
       (Object 23791-23794))))
  (DeclareGlobal 23796-23934
    (Function 23796-23825
      (ValueVar 23796-23812 _Array.ZipObject)
      ((ValueVar 23813-23815 Ks)
       (ValueVar 23817-23819 Vs)
       (ValueVar 23821-23824 Acc)))
    (Conditional 23830-23934
      (condition (TakeRight 23830-23873
          (Destructure 23830-23850
            (ValueVar 23830-23832 Ks)
            (Merge 23843-23850
              (Array 23836-23837 ((ValueVar 23837-23838 K)))
              (ValueVar 23843-23849 KsRest)))
          (Destructure 23853-23873
            (ValueVar 23853-23855 Vs)
            (Merge 23866-23873
              (Array 23859-23860 ((ValueVar 23860-23861 V)))
              (ValueVar 23866-23872 VsRest)))))
      (then (Function 23878-23926
          (ValueVar 23878-23894 _Array.ZipObject)
          ((ValueVar 23895-23901 KsRest)
           (ValueVar 23903-23909 VsRest)
           (Merge 23915-23925
              (Merge 23915-23918
                (Object 23911-23912)
                (ValueVar 23915-23918 Acc))
              (Object 23920-23925
                ((ValueVar 23920-23921 K) (ValueVar 23923-23924 V)))))))
      (else (ValueVar 23931-23934 Acc))))
  (DeclareGlobal 23936-23988
    (Function 23936-23958 (ValueVar 23936-23950 Array.ZipPairs) ((ValueVar 23951-23953 A1) (ValueVar 23955-23957 A2)))
    (Function 23961-23988
      (ValueVar 23961-23976 _Array.ZipPairs)
      ((ValueVar 23977-23979 A1)
       (ValueVar 23981-23983 A2)
       (Array 23985-23988 ()))))
  (DeclareGlobal 23990-24144
    (Function 23990-24018
      (ValueVar 23990-24005 _Array.ZipPairs)
      ((ValueVar 24006-24008 A1)
       (ValueVar 24010-24012 A2)
       (ValueVar 24014-24017 Acc)))
    (Conditional 24023-24144
      (condition (TakeRight 24023-24074
          (Destructure 24023-24047
            (ValueVar 24023-24025 A1)
            (Merge 24041-24047
              (Array 24029-24030 ((ValueVar 24030-24036 First1)))
              (ValueVar 24041-24046 Rest1)))
          (Destructure 24050-24074
            (ValueVar 24050-24052 A2)
            (Merge 24068-24074
              (Array 24056-24057 ((ValueVar 24057-24063 First2)))
              (ValueVar 24068-24073 Rest2)))))
      (then (Function 24079-24136
          (ValueVar 24079-24094 _Array.ZipPairs)
          ((ValueVar 24095-24100 Rest1)
           (ValueVar 24102-24107 Rest2)
           (Merge 24113-24135
              (Merge 24113-24116
                (Array 24109-24110 ())
                (ValueVar 24113-24116 Acc))
              (Array 24118-24135 ((Array 24118-24134 ((ValueVar 24119-24125 First1) (ValueVar 24127-24133 First2)))))))))
      (else (ValueVar 24141-24144 Acc))))
  (DeclareGlobal 24146-24260
    (Function 24146-24170
      (ValueVar 24146-24159 Array.AppendN)
      ((ValueVar 24160-24161 A)
       (ValueVar 24163-24166 Val)
       (ValueVar 24168-24169 N)))
    (Conditional 24175-24260
      (condition (TakeRight 24175-24215
          (Function 24175-24204 (ValueVar 24175-24201 _Assert.NonNegativeInteger) ((ValueVar 24202-24203 N)))
          (Destructure 24209-24215
            (ValueVar 24209-24210 N)
            (NumberString 24214-24215 0))))
      (then (ValueVar 24218-24219 A))
      (else (Function 24222-24260
          (ValueVar 24222-24235 Array.AppendN)
          ((Merge 24240-24247
              (Merge 24240-24241
                (Array 24236-24237 ())
                (ValueVar 24240-24241 A))
              (Array 24243-24247 ((ValueVar 24243-24246 Val))))
           (ValueVar 24249-24252 Val)
           (Merge 24254-24259
              (ValueVar 24254-24255 N)
              (Negation 24258-24259 (NumberString 24258-24259 1))))))))
  (DeclareGlobal 24262-24306
    (Function 24262-24280 (ValueVar 24262-24277 Table.Transpose) ((ValueVar 24278-24279 T)))
    (Function 24283-24306 (ValueVar 24283-24299 _Table.Transpose) ((ValueVar 24300-24301 T) (Array 24303-24306 ()))))
  (DeclareGlobal 24308-24476
    (Function 24308-24332 (ValueVar 24308-24324 _Table.Transpose) ((ValueVar 24325-24326 T) (ValueVar 24328-24331 Acc)))
    (Conditional 24337-24476
      (condition (TakeRight 24337-24412
          (Destructure 24337-24373
            (Function 24337-24358 (ValueVar 24337-24355 _Table.FirstPerRow) ((ValueVar 24356-24357 T)))
            (ValueVar 24362-24373 FirstPerRow))
          (Destructure 24378-24412
            (Function 24378-24398 (ValueVar 24378-24395 _Table.RestPerRow) ((ValueVar 24396-24397 T)))
            (ValueVar 24402-24412 RestPerRow))))
      (then (Function 24417-24468
          (ValueVar 24417-24433 _Table.Transpose)
          ((ValueVar 24434-24444 RestPerRow)
           (Merge 24450-24467
              (Merge 24450-24453
                (Array 24446-24447 ())
                (ValueVar 24450-24453 Acc))
              (Array 24455-24467 ((ValueVar 24455-24466 FirstPerRow)))))))
      (else (ValueVar 24473-24476 Acc))))
  (DeclareGlobal 24478-24593
    (Function 24478-24499 (ValueVar 24478-24496 _Table.FirstPerRow) ((ValueVar 24497-24498 T)))
    (TakeRight 24504-24593
      (TakeRight 24504-24550
        (Destructure 24504-24523
          (ValueVar 24504-24505 T)
          (Merge 24518-24523
            (Array 24509-24510 ((ValueVar 24510-24513 Row)))
            (ValueVar 24518-24522 Rest)))
        (Destructure 24526-24550
          (ValueVar 24526-24529 Row)
          (Merge 24548-24550
            (Array 24533-24534 ((ValueVar 24534-24543 VeryFirst)))
            (ValueVar 24548-24549 _))))
      (Function 24555-24593 (ValueVar 24555-24574 __Table.FirstPerRow) ((ValueVar 24575-24579 Rest) (Array 24581-24592 ((ValueVar 24582-24591 VeryFirst)))))))
  (DeclareGlobal 24595-24724
    (Function 24595-24622 (ValueVar 24595-24614 __Table.FirstPerRow) ((ValueVar 24615-24616 T) (ValueVar 24618-24621 Acc)))
    (Conditional 24627-24724
      (condition (TakeRight 24627-24669
          (Destructure 24627-24646
            (ValueVar 24627-24628 T)
            (Merge 24641-24646
              (Array 24632-24633 ((ValueVar 24633-24636 Row)))
              (ValueVar 24641-24645 Rest)))
          (Destructure 24649-24669
            (ValueVar 24649-24652 Row)
            (Merge 24667-24669
              (Array 24656-24657 ((ValueVar 24657-24662 First)))
              (ValueVar 24667-24668 _)))))
      (then (Function 24674-24716
          (ValueVar 24674-24693 __Table.FirstPerRow)
          ((ValueVar 24694-24698 Rest)
           (Merge 24704-24715
              (Merge 24704-24707
                (Array 24700-24701 ())
                (ValueVar 24704-24707 Acc))
              (Array 24709-24715 ((ValueVar 24709-24714 First)))))))
      (else (ValueVar 24721-24724 Acc))))
  (DeclareGlobal 24726-24774
    (Function 24726-24746 (ValueVar 24726-24743 _Table.RestPerRow) ((ValueVar 24744-24745 T)))
    (Function 24749-24774 (ValueVar 24749-24767 __Table.RestPerRow) ((ValueVar 24768-24769 T) (Array 24771-24774 ()))))
  (DeclareGlobal 24776-24964
    (Function 24776-24802 (ValueVar 24776-24794 __Table.RestPerRow) ((ValueVar 24795-24796 T) (ValueVar 24798-24801 Acc)))
    (Conditional 24807-24964
      (condition (Destructure 24807-24826
          (ValueVar 24807-24808 T)
          (Merge 24821-24826
            (Array 24812-24813 ((ValueVar 24813-24816 Row)))
            (ValueVar 24821-24825 Rest))))
      (then (Conditional 24829-24956
          (condition (Destructure 24835-24857
              (ValueVar 24835-24838 Row)
              (Merge 24849-24857
                (Array 24842-24843 ((ValueVar 24843-24844 _)))
                (ValueVar 24849-24856 RowRest))))
          (then (Function 24864-24907
              (ValueVar 24864-24882 __Table.RestPerRow)
              ((ValueVar 24883-24887 Rest)
               (Merge 24893-24906
                  (Merge 24893-24896
                    (Array 24889-24890 ())
                    (ValueVar 24893-24896 Acc))
                  (Array 24898-24906 ((ValueVar 24898-24905 RowRest)))))))
          (else (Function 24914-24952
              (ValueVar 24914-24932 __Table.RestPerRow)
              ((ValueVar 24933-24937 Rest)
               (Merge 24943-24951
                  (Merge 24943-24946
                    (Array 24939-24940 ())
                    (ValueVar 24943-24946 Acc))
                  (Array 24948-24951 ((Array 24948-24951 ())))))))))
      (else (ValueVar 24961-24964 Acc))))
  (DeclareGlobal 24966-25037
    (Function 24966-24990 (ValueVar 24966-24987 Table.RotateClockwise) ((ValueVar 24988-24989 T)))
    (Function 24993-25037 (ValueVar 24993-25002 Array.Map) ((Function 25003-25021 (ValueVar 25003-25018 Table.Transpose) ((ValueVar 25019-25020 T))) (ValueVar 25023-25036 Array.Reverse))))
  (DeclareGlobal 25039-25106
    (Function 25039-25070 (ValueVar 25039-25067 Table.RotateCounterClockwise) ((ValueVar 25068-25069 T)))
    (Function 25073-25106 (ValueVar 25073-25086 Array.Reverse) ((Function 25087-25105 (ValueVar 25087-25102 Table.Transpose) ((ValueVar 25103-25104 T))))))
  (DeclareGlobal 25108-25168
    (Function 25108-25134 (ValueVar 25108-25124 Table.ZipObjects) ((ValueVar 25125-25127 Ks) (ValueVar 25129-25133 Rows)))
    (Function 25137-25168
      (ValueVar 25137-25154 _Table.ZipObjects)
      ((ValueVar 25155-25157 Ks)
       (ValueVar 25159-25163 Rows)
       (Array 25165-25168 ()))))
  (DeclareGlobal 25170-25305
    (Function 25170-25202
      (ValueVar 25170-25187 _Table.ZipObjects)
      ((ValueVar 25188-25190 Ks)
       (ValueVar 25192-25196 Rows)
       (ValueVar 25198-25201 Acc)))
    (Conditional 25207-25305
      (condition (Destructure 25207-25229
          (ValueVar 25207-25211 Rows)
          (Merge 25224-25229
            (Array 25215-25216 ((ValueVar 25216-25219 Row)))
            (ValueVar 25224-25228 Rest))))
      (then (Function 25234-25297
          (ValueVar 25234-25251 _Table.ZipObjects)
          ((ValueVar 25252-25254 Ks)
           (ValueVar 25256-25260 Rest)
           (Merge 25266-25296
              (Merge 25266-25269
                (Array 25262-25263 ())
                (ValueVar 25266-25269 Acc))
              (Array 25271-25296 ((Function 25271-25295 (ValueVar 25271-25286 Array.ZipObject) ((ValueVar 25287-25289 Ks) (ValueVar 25291-25294 Row)))))))))
      (else (ValueVar 25302-25305 Acc))))
  (DeclareGlobal 25319-25352
    (Function 25319-25332 (ValueVar 25319-25326 Obj.Has) ((ValueVar 25327-25328 O) (ValueVar 25330-25331 K)))
    (Destructure 25335-25352
      (ValueVar 25335-25336 O)
      (Merge 25350-25352
        (Object 25340-25350
          ((ValueVar 25341-25342 K) (ValueVar 25344-25345 _)))
        (ValueVar 25350-25351 _))))
  (DeclareGlobal 25354-25391
    (Function 25354-25367 (ValueVar 25354-25361 Obj.Get) ((ValueVar 25362-25363 O) (ValueVar 25365-25366 K)))
    (TakeRight 25370-25391
      (Destructure 25370-25387
        (ValueVar 25370-25371 O)
        (Merge 25385-25387
          (Object 25375-25385
            ((ValueVar 25376-25377 K) (ValueVar 25379-25380 V)))
          (ValueVar 25385-25386 _)))
      (ValueVar 25390-25391 V)))
  (DeclareGlobal 25393-25424
    (Function 25393-25409
      (ValueVar 25393-25400 Obj.Put)
      ((ValueVar 25401-25402 O)
       (ValueVar 25404-25405 K)
       (ValueVar 25407-25408 V)))
    (Merge 25416-25424
      (Merge 25416-25417
        (Object 25412-25413)
        (ValueVar 25416-25417 O))
      (Object 25419-25424
        ((ValueVar 25419-25420 K) (ValueVar 25422-25423 V)))))
  (DeclareGlobal 25452-25513
    (Function 25452-25488 (ValueVar 25452-25466 Ast.Precedence) ((ValueVar 25467-25473 OpNode) (ValueVar 25475-25487 BindingPower)))
    (Array 25491-25513 ((ValueVar 25492-25498 OpNode) (ValueVar 25500-25512 BindingPower))))
  (DeclareGlobal 25515-25629
    (Function 25515-25579
      (ValueVar 25515-25534 Ast.InfixPrecedence)
      ((ValueVar 25535-25541 OpNode)
       (ValueVar 25543-25559 LeftBindingPower)
       (ValueVar 25561-25578 RightBindingPower)))
    (Array 25584-25629 ((ValueVar 25585-25591 OpNode) (ValueVar 25593-25609 LeftBindingPower) (ValueVar 25611-25628 RightBindingPower))))
  (DeclareGlobal 25646-25674
    (Function 25646-25658 (ValueVar 25646-25655 Is.String) ((ValueVar 25656-25657 V)))
    (Destructure 25661-25674
      (ValueVar 25661-25662 V)
      (Merge 25666-25674
        (String 25667-25669 "")
        (ValueVar 25672-25673 _))))
  (DeclareGlobal 25676-25703
    (Function 25676-25688 (ValueVar 25676-25685 Is.Number) ((ValueVar 25686-25687 V)))
    (Destructure 25691-25703
      (ValueVar 25691-25692 V)
      (Merge 25696-25703
        (NumberString 25697-25698 0)
        (ValueVar 25701-25702 _))))
  (DeclareGlobal 25705-25734
    (Function 25705-25715 (ValueVar 25705-25712 Is.Bool) ((ValueVar 25713-25714 V)))
    (Destructure 25718-25734
      (ValueVar 25718-25719 V)
      (Merge 25723-25734
        (Boolean 25724-25729 false)
        (ValueVar 25732-25733 _))))
  (DeclareGlobal 25736-25758
    (Function 25736-25746 (ValueVar 25736-25743 Is.Null) ((ValueVar 25744-25745 V)))
    (Destructure 25749-25758
      (ValueVar 25749-25750 V)
      (Null 25754-25758 null)))
  (DeclareGlobal 25760-25785
    (Function 25760-25771 (ValueVar 25760-25768 Is.Array) ((ValueVar 25769-25770 V)))
    (Destructure 25774-25785
      (ValueVar 25774-25775 V)
      (Merge 25783-25785
        (Array 25779-25780 ())
        (ValueVar 25783-25784 _))))
  (DeclareGlobal 25787-25813
    (Function 25787-25799 (ValueVar 25787-25796 Is.Object) ((ValueVar 25797-25798 V)))
    (Destructure 25802-25813
      (ValueVar 25802-25803 V)
      (Merge 25811-25813
        (Object 25807-25808)
        (ValueVar 25811-25812 _))))
  (DeclareGlobal 25815-25838
    (Function 25815-25829 (ValueVar 25815-25823 Is.Equal) ((ValueVar 25824-25825 A) (ValueVar 25827-25828 B)))
    (Destructure 25832-25838
      (ValueVar 25832-25833 A)
      (ValueVar 25837-25838 B)))
  (DeclareGlobal 25840-25885
    (Function 25840-25857 (ValueVar 25840-25851 Is.LessThan) ((ValueVar 25852-25853 A) (ValueVar 25855-25856 B)))
    (Conditional 25860-25885
      (condition (Destructure 25860-25866
          (ValueVar 25860-25861 A)
          (ValueVar 25865-25866 B)))
      (then (ValueVar 25869-25874 @Fail))
      (else (Destructure 25877-25885
          (ValueVar 25877-25878 A)
          (Range 25882-25885 () (ValueVar 25884-25885 B))))))
  (DeclareGlobal 25887-25922
    (Function 25887-25911 (ValueVar 25887-25905 Is.LessThanOrEqual) ((ValueVar 25906-25907 A) (ValueVar 25909-25910 B)))
    (Destructure 25914-25922
      (ValueVar 25914-25915 A)
      (Range 25919-25922 () (ValueVar 25921-25922 B))))
  (DeclareGlobal 25924-25972
    (Function 25924-25944 (ValueVar 25924-25938 Is.GreaterThan) ((ValueVar 25939-25940 A) (ValueVar 25942-25943 B)))
    (Conditional 25947-25972
      (condition (Destructure 25947-25953
          (ValueVar 25947-25948 A)
          (ValueVar 25952-25953 B)))
      (then (ValueVar 25956-25961 @Fail))
      (else (Destructure 25964-25972
          (ValueVar 25964-25965 A)
          (Range 25969-25972 (ValueVar 25969-25970 B) ())))))
  (DeclareGlobal 25974-26012
    (Function 25974-26001 (ValueVar 25974-25995 Is.GreaterThanOrEqual) ((ValueVar 25996-25997 A) (ValueVar 25999-26000 B)))
    (Destructure 26004-26012
      (ValueVar 26004-26005 A)
      (Range 26009-26012 (ValueVar 26009-26010 B) ())))
  (DeclareGlobal 26029-26080
    (Function 26029-26041 (ValueVar 26029-26038 As.Number) ((ValueVar 26039-26040 V)))
    (Or 26044-26080
      (Function 26044-26056 (ValueVar 26044-26053 Is.Number) ((ValueVar 26054-26055 V)))
      (Return 26059-26080
        (Destructure 26060-26075
          (ValueVar 26060-26061 V)
          (StringTemplate 26065-26075 (Merge 26068-26073
            (NumberString 26068-26069 0)
            (ValueVar 26072-26073 N))))
        (ValueVar 26078-26079 N))))
  (DeclareGlobal 26094-26190
    (Function 26094-26123 (ValueVar 26094-26120 _Assert.NonNegativeInteger) ((ValueVar 26121-26122 V)))
    (Or 26128-26190
      (Destructure 26128-26136
        (ValueVar 26128-26129 V)
        (Range 26133-26136 (NumberString 26133-26134 0) ()))
      (Function 26139-26190
        (ValueVar 26139-26145 @Crash)
        ((StringTemplate 26146-26189
            (String 26147-26184 "Expected a non-negative integer, got ")
            (ValueVar 26186-26187 V))))))

