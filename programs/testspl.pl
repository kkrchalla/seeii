#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  my $eenadu = "kishore-reddy--'0";

  my $special_chars;

  foreach my $number (keys %entities) {
    $special_chars .= chr($number);
  }

  $temp = ord("�");
#  print chr(2350);
#  print $temp;
#  print $special_chars . "\n\n";
  print $eenadu . "\n\n";

#  $eenadu =~ s/([$special_chars])/"&#".ord($1).";"/gse;
#  $eenadu =~ tr/a-zA-Z0-9_\-&#;/ /cs;
#  $eenadu =~ s/'//cs;

  print $eenadu . "\n\n";

  my %entities = (
 	216 => 'Oslash',	#  capital O, slash
	217 => 'Ugrave',	#  capital U, grave accent
	218 => 'Uacute',	#  capital U, acute accent
	219 => 'Ucirc',		#  capital U, circumflex accent
	220 => 'Uuml',		#  capital U, dieresis or umlaut mark
	221 => 'Yacute',	#  capital Y, acute accent
	222 => 'THORN',		#  capital THORN, Icelandic
	223 => 'szlig',		#  small sharp s, German (sz ligature)
	224 => 'agrave',	#  small a, grave accent
	225 => 'aacute',	#  small a, acute accent
	226 => 'acirc',		#  small a, circumflex accent
	227 => 'atilde',	#  small a, tilde
	228 => 'auml',		#  small a, dieresis or umlaut mark
	229 => 'aring',		#  small a, ring
       2305 => '',        #  HINDI SIGN CANDRABINDU
        2306 => '',        #  HINDI SIGN ANUSVARA
        2307 => '',        #  HINDI SIGN VISARGA
        2308 => '',        #  HINDI LETTER SHORT A
        2309 => '',        #  HINDI LETTER A
        2310 => '',        #  HINDI LETTER AA
        2311 => '',        #  HINDI LETTER I
        2312 => '',        #  HINDI LETTER II
        2313 => '',        #  HINDI LETTER U
        2314 => '',        #  HINDI LETTER UU
        2315 => '',        #  HINDI LETTER VOCALIC R
        2316 => '',        #  HINDI LETTER VOCALIC L
        2317 => '',        #  HINDI LETTER CANDRA E
        2318 => '',        #  HINDI LETTER SHORT E
        2319 => '',        #  HINDI LETTER E
        2320 => '',        #  HINDI LETTER AI
        2321 => '',        #  HINDI LETTER CANDRA O
        2322 => '',        #  HINDI LETTER SHORT O
        2323 => '',        #  HINDI LETTER O
        2324 => '',        #  HINDI LETTER AU
        2325 => '',        #  HINDI LETTER KA
        2326 => '',        #  HINDI LETTER KHA
        2327 => '',        #  HINDI LETTER GA
        2328 => '',        #  HINDI LETTER GHA
        2329 => '',        #  HINDI LETTER NGA
        2330 => '',        #  HINDI LETTER CA
        2331 => '',        #  HINDI LETTER CHA
        2332 => '',        #  HINDI LETTER JA
        2333 => '',        #  HINDI LETTER JHA
        2334 => '',        #  HINDI LETTER NYA
        2335 => '',        #  HINDI LETTER TTA
        2336 => '',        #  HINDI LETTER TTHA
        2337 => '',        #  HINDI LETTER DDA
        2338 => '',        #  HINDI LETTER DDHA
        2339 => '',        #  HINDI LETTER NNA
        2340 => '',        #  HINDI LETTER TA
        2341 => '',        #  HINDI LETTER THA
        2342 => '',        #  HINDI LETTER DA
        2343 => '',        #  HINDI LETTER DHA
        2344 => '',        #  HINDI LETTER NA
        2345 => '',        #  HINDI LETTER NNNA
        2346 => '',        #  HINDI LETTER PA
        2347 => '',        #  HINDI LETTER PHA
        2348 => '',        #  HINDI LETTER BA
        2349 => '',        #  HINDI LETTER BHA
        2350 => '',        #  HINDI LETTER MA
        2351 => '',        #  HINDI LETTER YA
        2352 => '',        #  HINDI LETTER RA
        2353 => '',        #  HINDI LETTER RRA
        2354 => '',        #  HINDI LETTER LA
        2355 => '',        #  HINDI LETTER LLA
        2356 => '',        #  HINDI LETTER LLLA
        2357 => '',        #  HINDI LETTER VA
        2358 => '',        #  HINDI LETTER SHA
        2359 => '',        #  HINDI LETTER SSA
        2360 => '',        #  HINDI LETTER SA
        2361 => '',        #  HINDI LETTER HA
        2364 => '',        #  HINDI SIGN NUKTA
        2365 => '',        #  HINDI SIGN AVAGRAHA
        2366 => '',        #  HINDI VOWEL SIGN AA
        2367 => '',        #  HINDI VOWEL SIGN I
        2368 => '',        #  HINDI VOWEL SIGN II
        2369 => '',        #  HINDI VOWEL SIGN U
        2370 => '',        #  HINDI VOWEL SIGN UU
        2371 => '',        #  HINDI VOWEL SIGN VOCALIC R
        2372 => '',        #  HINDI VOWEL SIGN VOCALIC RR
        2373 => '',        #  HINDI VOWEL SIGN CANDRA E
        2374 => '',        #  HINDI VOWEL SIGN SHORT E
        2375 => '',        #  HINDI VOWEL SIGN E
        2376 => '',        #  HINDI VOWEL SIGN AI
        2377 => '',        #  HINDI VOWEL SIGN CANDRA O
        2378 => '',        #  HINDI VOWEL SIGN SHORT O
        2379 => '',        #  HINDI VOWEL SIGN O
        2380 => '',        #  HINDI VOWEL SIGN AU
        2381 => '',        #  HINDI SIGN VIRAMA
        2384 => '',        #  HINDI OM
        2385 => '',        #  HINDI STRESS SIGN UDATTA
        2386 => '',        #  HINDI STRESS SIGN ANUDATTA
        2387 => '',        #  HINDI GRAVE ACCENT
        2388 => '',        #  HINDI ACUTE ACCENT
        2392 => '',        #  HINDI LETTER QA
        2393 => '',        #  HINDI LETTER KHHA
        2394 => '',        #  HINDI LETTER GHHA
        2395 => '',        #  HINDI LETTER ZA
        2396 => '',        #  HINDI LETTER DDDHA
        2397 => '',        #  HINDI LETTER RHA
        2398 => '',        #  HINDI LETTER FA
        2399 => '',        #  HINDI LETTER YYA
        2400 => '',        #  HINDI LETTER VOCALIC RR
        2401 => '',        #  HINDI LETTER VOCALIC LL
        2402 => '',        #  HINDI VOWEL SIGN VOCALIC L
        2403 => '',        #  HINDI VOWEL SIGN VOCALIC LL
        2404 => '',        #  HINDI DANDA
        2405 => '',        #  HINDI DOUBLE DANDA
        2406 => '0',        #  HINDI DIGIT ZERO
        2407 => '1',        #  HINDI DIGIT ONE
        2408 => '2',        #  HINDI DIGIT TWO
        2409 => '3',        #  HINDI DIGIT THREE
        2410 => '4',        #  HINDI DIGIT FOUR
        2411 => '5',        #  HINDI DIGIT FIVE
        2412 => '6',        #  HINDI DIGIT SIX
        2413 => '7',        #  HINDI DIGIT SEVEN
        2414 => '8',        #  HINDI DIGIT EIGHT
        2415 => '9',        #  HINDI DIGIT NINE
        2416 => '',        #  HINDI ABBREVIATION SIGN
        2429 => '',        #  HINDI LETTER GLOTTAL STOP
        2433 => '',        #  BENGALI SIGN CANDRABINDU
        2434 => '',        #  BENGALI SIGN ANUSVARA
        2435 => '',        #  BENGALI SIGN VISARGA
        2437 => '',        #  BENGALI LETTER A
        2438 => '',        #  BENGALI LETTER AA
        2439 => '',        #  BENGALI LETTER I
        2440 => '',        #  BENGALI LETTER II
        2441 => '',        #  BENGALI LETTER U
        2442 => '',        #  BENGALI LETTER UU
        2443 => '',        #  BENGALI LETTER VOCALIC R
        2444 => '',        #  BENGALI LETTER VOCALIC L
        2447 => '',        #  BENGALI LETTER E
        2448 => '',        #  BENGALI LETTER AI
        2451 => '',        #  BENGALI LETTER O
        2452 => '',        #  BENGALI LETTER AU
        2453 => '',        #  BENGALI LETTER KA
        2454 => '',        #  BENGALI LETTER KHA
        2455 => '',        #  BENGALI LETTER GA
        2456 => '',        #  BENGALI LETTER GHA
        2457 => '',        #  BENGALI LETTER NGA
        2458 => '',        #  BENGALI LETTER CA
        2459 => '',        #  BENGALI LETTER CHA
        2460 => '',        #  BENGALI LETTER JA
        2461 => '',        #  BENGALI LETTER JHA
        2462 => '',        #  BENGALI LETTER NYA
        2463 => '',        #  BENGALI LETTER TTA
        2464 => '',        #  BENGALI LETTER TTHA
        2465 => '',        #  BENGALI LETTER DDA
        2466 => '',        #  BENGALI LETTER DDHA
        2467 => '',        #  BENGALI LETTER NNA
        2468 => '',        #  BENGALI LETTER TA
        2469 => '',        #  BENGALI LETTER THA
        2470 => '',        #  BENGALI LETTER DA
        2471 => '',        #  BENGALI LETTER DHA
        2472 => '',        #  BENGALI LETTER NA
        2474 => '',        #  BENGALI LETTER PA
        2475 => '',        #  BENGALI LETTER PHA
        2476 => '',        #  BENGALI LETTER BA
        2477 => '',        #  BENGALI LETTER BHA
        2478 => '',        #  BENGALI LETTER MA
        2479 => '',        #  BENGALI LETTER YA
        2480 => '',        #  BENGALI LETTER RA
        2482 => '',        #  BENGALI LETTER LA
        2486 => '',        #  BENGALI LETTER SHA
        2487 => '',        #  BENGALI LETTER SSA
        2488 => '',        #  BENGALI LETTER SA
        2489 => '',        #  BENGALI LETTER HA
        2492 => '',        #  BENGALI SIGN NUKTA
        2493 => '',        #  BENGALI SIGN AVAGRAHA
        2494 => '',        #  BENGALI VOWEL SIGN AA
        2495 => '',        #  BENGALI VOWEL SIGN I
        2496 => '',        #  BENGALI VOWEL SIGN II
        2497 => '',        #  BENGALI VOWEL SIGN U
        2498 => '',        #  BENGALI VOWEL SIGN UU
        2499 => '',        #  BENGALI VOWEL SIGN VOCALIC R
        2500 => '',        #  BENGALI VOWEL SIGN VOCALIC RR
        2503 => '',        #  BENGALI VOWEL SIGN E
        2504 => '',        #  BENGALI VOWEL SIGN AI
        2507 => '',        #  BENGALI VOWEL SIGN O
        2508 => '',        #  BENGALI VOWEL SIGN AU
        2509 => '',        #  BENGALI SIGN VIRAMA
        2510 => '',        #  BENGALI LETTER KHANDA TA
        2519 => '',        #  BENGALI AU LENGTH MARK
        2524 => '',        #  BENGALI LETTER RRA
        2525 => '',        #  BENGALI LETTER RHA
        2527 => '',        #  BENGALI LETTER YYA
        2528 => '',        #  BENGALI LETTER VOCALIC RR
        2529 => '',        #  BENGALI LETTER VOCALIC LL
        2530 => '',        #  BENGALI VOWEL SIGN VOCALIC L
        2531 => '',        #  BENGALI VOWEL SIGN VOCALIC LL
        2534 => '0',        #  BENGALI DIGIT ZERO
        2535 => '1',        #  BENGALI DIGIT ONE
        2536 => '2',        #  BENGALI DIGIT TWO
        2537 => '3',        #  BENGALI DIGIT THREE
        2538 => '4',        #  BENGALI DIGIT FOUR
        2539 => '5',        #  BENGALI DIGIT FIVE
        2540 => '6',        #  BENGALI DIGIT SIX
        2541 => '7',        #  BENGALI DIGIT SEVEN
        2542 => '8',        #  BENGALI DIGIT EIGHT
        2543 => '9',        #  BENGALI DIGIT NINE
        2544 => '',        #  BENGALI LETTER RA WITH MIDDLE DIAGONAL
        2545 => '',        #  BENGALI LETTER RA WITH LOWER DIAGONAL
        2546 => '',        #  BENGALI RUPEE MARK
        2547 => '',        #  BENGALI RUPEE SIGN
        2548 => '',        #  BENGALI CURRENCY NUMERATOR ONE
        2549 => '',        #  BENGALI CURRENCY NUMERATOR TWO
        2550 => '',        #  BENGALI CURRENCY NUMERATOR THREE
        2551 => '',        #  BENGALI CURRENCY NUMERATOR FOUR
        2552 => '',        #  BENGALI CURRENCY NUMERATOR ONE LESS THAN THE DENOMINATOR
        2553 => '',        #  BENGALI CURRENCY DENOMINATOR SIXTEEN
        2554 => '',        #  BENGALI ISSHAR
        2561 => '',        #  PUNJABI SIGN ADAK BINDI
        2562 => '',        #  PUNJABI SIGN BINDI
        2563 => '',        #  PUNJABI SIGN VISARGA
        2565 => '',        #  PUNJABI LETTER A
        2566 => '',        #  PUNJABI LETTER AA
        2567 => '',        #  PUNJABI LETTER I
        2568 => '',        #  PUNJABI LETTER II
        2569 => '',        #  PUNJABI LETTER U
        2570 => '',        #  PUNJABI LETTER UU
        2575 => '',        #  PUNJABI LETTER EE
        2576 => '',        #  PUNJABI LETTER AI
        2579 => '',        #  PUNJABI LETTER OO
        2580 => '',        #  PUNJABI LETTER AU
        2581 => '',        #  PUNJABI LETTER KA
        2582 => '',        #  PUNJABI LETTER KHA
        2583 => '',        #  PUNJABI LETTER GA
        2584 => '',        #  PUNJABI LETTER GHA
        2585 => '',        #  PUNJABI LETTER NGA
        2586 => '',        #  PUNJABI LETTER CA
        2587 => '',        #  PUNJABI LETTER CHA
        2588 => '',        #  PUNJABI LETTER JA
        2589 => '',        #  PUNJABI LETTER JHA
        2590 => '',        #  PUNJABI LETTER NYA
        2591 => '',        #  PUNJABI LETTER TTA
        2592 => '',        #  PUNJABI LETTER TTHA
        2593 => '',        #  PUNJABI LETTER DDA
        2594 => '',        #  PUNJABI LETTER DDHA
        2595 => '',        #  PUNJABI LETTER NNA
        2596 => '',        #  PUNJABI LETTER TA
        2597 => '',        #  PUNJABI LETTER THA
        2598 => '',        #  PUNJABI LETTER DA
        2599 => '',        #  PUNJABI LETTER DHA
        2600 => '',        #  PUNJABI LETTER NA
        2602 => '',        #  PUNJABI LETTER PA
        2603 => '',        #  PUNJABI LETTER PHA
        2604 => '',        #  PUNJABI LETTER BA
        2605 => '',        #  PUNJABI LETTER BHA
        2606 => '',        #  PUNJABI LETTER MA
        2607 => '',        #  PUNJABI LETTER YA
        2608 => '',        #  PUNJABI LETTER RA
        2610 => '',        #  PUNJABI LETTER LA
        2611 => '',        #  PUNJABI LETTER LLA
        2613 => '',        #  PUNJABI LETTER VA
        2614 => '',        #  PUNJABI LETTER SHA
        2616 => '',        #  PUNJABI LETTER SA
        2617 => '',        #  PUNJABI LETTER HA
        2620 => '',        #  PUNJABI SIGN NUKTA
        2622 => '',        #  PUNJABI VOWEL SIGN AA
        2623 => '',        #  PUNJABI VOWEL SIGN I
        2624 => '',        #  PUNJABI VOWEL SIGN II
        2625 => '',        #  PUNJABI VOWEL SIGN U
        2626 => '',        #  PUNJABI VOWEL SIGN UU
        2631 => '',        #  PUNJABI VOWEL SIGN EE
        2632 => '',        #  PUNJABI VOWEL SIGN AI
        2635 => '',        #  PUNJABI VOWEL SIGN OO
        2636 => '',        #  PUNJABI VOWEL SIGN AU
        2637 => '',        #  PUNJABI SIGN VIRAMA
        2649 => '',        #  PUNJABI LETTER KHHA
        2650 => '',        #  PUNJABI LETTER GHHA
        2651 => '',        #  PUNJABI LETTER ZA
        2652 => '',        #  PUNJABI LETTER RRA
        2654 => '',        #  PUNJABI LETTER FA
        2662 => '0',        #  PUNJABI DIGIT ZERO
        2663 => '1',        #  PUNJABI DIGIT ONE
        2664 => '2',        #  PUNJABI DIGIT TWO
        2665 => '3',        #  PUNJABI DIGIT THREE
        2666 => '4',        #  PUNJABI DIGIT FOUR
        2667 => '5',        #  PUNJABI DIGIT FIVE
        2668 => '6',        #  PUNJABI DIGIT SIX
        2669 => '7',        #  PUNJABI DIGIT SEVEN
        2670 => '8',        #  PUNJABI DIGIT EIGHT
        2671 => '9',        #  PUNJABI DIGIT NINE
        2672 => '',        #  PUNJABI TIPPI
        2673 => '',        #  PUNJABI ADDAK
        2674 => '',        #  PUNJABI IRI
        2675 => '',        #  PUNJABI URA
        2676 => '',        #  PUNJABI EK ONKAR
        2689 => '',        #  GUJARATI SIGN CANDRABINDU
        2690 => '',        #  GUJARATI SIGN ANUSVARA
        2691 => '',        #  GUJARATI SIGN VISARGA
        2693 => '',        #  GUJARATI LETTER A
        2694 => '',        #  GUJARATI LETTER AA
        2695 => '',        #  GUJARATI LETTER I
        2696 => '',        #  GUJARATI LETTER II
        2697 => '',        #  GUJARATI LETTER U
        2698 => '',        #  GUJARATI LETTER UU
        2699 => '',        #  GUJARATI LETTER VOCALIC R
        2700 => '',        #  GUJARATI LETTER VOCALIC L
        2701 => '',        #  GUJARATI VOWEL CANDRA E
        2703 => '',        #  GUJARATI LETTER E
        2704 => '',        #  GUJARATI LETTER AI
        2705 => '',        #  GUJARATI VOWEL CANDRA O
        2707 => '',        #  GUJARATI LETTER O
        2708 => '',        #  GUJARATI LETTER AU
        2709 => '',        #  GUJARATI LETTER KA
        2710 => '',        #  GUJARATI LETTER KHA
        2711 => '',        #  GUJARATI LETTER GA
        2712 => '',        #  GUJARATI LETTER GHA
        2713 => '',        #  GUJARATI LETTER NGA
        2714 => '',        #  GUJARATI LETTER CA
        2715 => '',        #  GUJARATI LETTER CHA
        2716 => '',        #  GUJARATI LETTER JA
        2717 => '',        #  GUJARATI LETTER JHA
        2718 => '',        #  GUJARATI LETTER NYA
        2719 => '',        #  GUJARATI LETTER TTA
        2720 => '',        #  GUJARATI LETTER TTHA
        2721 => '',        #  GUJARATI LETTER DDA
        2722 => '',        #  GUJARATI LETTER DDHA
        2723 => '',        #  GUJARATI LETTER NNA
        2724 => '',        #  GUJARATI LETTER TA
        2725 => '',        #  GUJARATI LETTER THA
        2726 => '',        #  GUJARATI LETTER DA
        2727 => '',        #  GUJARATI LETTER DHA
        2728 => '',        #  GUJARATI LETTER NA
        2730 => '',        #  GUJARATI LETTER PA
        2731 => '',        #  GUJARATI LETTER PHA
        2732 => '',        #  GUJARATI LETTER BA
        2733 => '',        #  GUJARATI LETTER BHA
        2734 => '',        #  GUJARATI LETTER MA
        2735 => '',        #  GUJARATI LETTER YA
        2736 => '',        #  GUJARATI LETTER RA
        2738 => '',        #  GUJARATI LETTER LA
        2739 => '',        #  GUJARATI LETTER LLA
        2741 => '',        #  GUJARATI LETTER VA
        2742 => '',        #  GUJARATI LETTER SHA
        2743 => '',        #  GUJARATI LETTER SSA
        2744 => '',        #  GUJARATI LETTER SA
        2745 => '',        #  GUJARATI LETTER HA
        2748 => '',        #  GUJARATI SIGN NUKTA
        2749 => '',        #  GUJARATI SIGN AVAGRAHA
        2750 => '',        #  GUJARATI VOWEL SIGN AA
        2751 => '',        #  GUJARATI VOWEL SIGN I
        2752 => '',        #  GUJARATI VOWEL SIGN II
        2753 => '',        #  GUJARATI VOWEL SIGN U
        2754 => '',        #  GUJARATI VOWEL SIGN UU
        2755 => '',        #  GUJARATI VOWEL SIGN VOCALIC R
        2756 => '',        #  GUJARATI VOWEL SIGN VOCALIC RR
        2757 => '',        #  GUJARATI VOWEL SIGN CANDRA E
        2759 => '',        #  GUJARATI VOWEL SIGN E
        2760 => '',        #  GUJARATI VOWEL SIGN AI
        2761 => '',        #  GUJARATI VOWEL SIGN CANDRA O
        2763 => '',        #  GUJARATI VOWEL SIGN O
        2764 => '',        #  GUJARATI VOWEL SIGN AU
        2765 => '',        #  GUJARATI SIGN VIRAMA
        2768 => '',        #  GUJARATI OM
        2784 => '',        #  GUJARATI LETTER VOCALIC RR
        2785 => '',        #  GUJARATI LETTER VOCALIC LL
        2786 => '',        #  GUJARATI VOWEL SIGN VOCALIC L
        2787 => '',        #  GUJARATI VOWEL SIGN VOCALIC LL
        2790 => '0',        #  GUJARATI DIGIT ZERO
        2791 => '1',        #  GUJARATI DIGIT ONE
        2792 => '2',        #  GUJARATI DIGIT TWO
        2793 => '3',        #  GUJARATI DIGIT THREE
        2794 => '4',        #  GUJARATI DIGIT FOUR
        2795 => '5',        #  GUJARATI DIGIT FIVE
        2796 => '6',        #  GUJARATI DIGIT SIX
        2797 => '7',        #  GUJARATI DIGIT SEVEN
        2798 => '8',        #  GUJARATI DIGIT EIGHT
        2799 => '9',        #  GUJARATI DIGIT NINE
        2801 => '',        #  GUJARATI RUPEE SIGN
        2817 => '',        #  ORIYA SIGN CANDRABINDU
        2818 => '',        #  ORIYA SIGN ANUSVARA
        2819 => '',        #  ORIYA SIGN VISARGA
        2821 => '',        #  ORIYA LETTER A
        2822 => '',        #  ORIYA LETTER AA
        2823 => '',        #  ORIYA LETTER I
        2824 => '',        #  ORIYA LETTER II
        2825 => '',        #  ORIYA LETTER U
        2826 => '',        #  ORIYA LETTER UU
        2827 => '',        #  ORIYA LETTER VOCALIC R
        2828 => '',        #  ORIYA LETTER VOCALIC L
        2831 => '',        #  ORIYA LETTER E
        2832 => '',        #  ORIYA LETTER AI
        2835 => '',        #  ORIYA LETTER O
        2836 => '',        #  ORIYA LETTER AU
        2837 => '',        #  ORIYA LETTER KA
        2838 => '',        #  ORIYA LETTER KHA
        2839 => '',        #  ORIYA LETTER GA
        2840 => '',        #  ORIYA LETTER GHA
        2841 => '',        #  ORIYA LETTER NGA
        2842 => '',        #  ORIYA LETTER CA
        2843 => '',        #  ORIYA LETTER CHA
        2844 => '',        #  ORIYA LETTER JA
        2845 => '',        #  ORIYA LETTER JHA
        2846 => '',        #  ORIYA LETTER NYA
        2847 => '',        #  ORIYA LETTER TTA
        2848 => '',        #  ORIYA LETTER TTHA
        2849 => '',        #  ORIYA LETTER DDA
        2850 => '',        #  ORIYA LETTER DDHA
        2851 => '',        #  ORIYA LETTER NNA
        2852 => '',        #  ORIYA LETTER TA
        2853 => '',        #  ORIYA LETTER THA
        2854 => '',        #  ORIYA LETTER DA
        2855 => '',        #  ORIYA LETTER DHA
        2856 => '',        #  ORIYA LETTER NA
        2858 => '',        #  ORIYA LETTER PA
        2859 => '',        #  ORIYA LETTER PHA
        2860 => '',        #  ORIYA LETTER BA
        2861 => '',        #  ORIYA LETTER BHA
        2862 => '',        #  ORIYA LETTER MA
        2863 => '',        #  ORIYA LETTER YA
        2864 => '',        #  ORIYA LETTER RA
        2866 => '',        #  ORIYA LETTER LA
        2867 => '',        #  ORIYA LETTER LLA
        2869 => '',        #  ORIYA LETTER VA
        2870 => '',        #  ORIYA LETTER SHA
        2871 => '',        #  ORIYA LETTER SSA
        2872 => '',        #  ORIYA LETTER SA
        2873 => '',        #  ORIYA LETTER HA
        2876 => '',        #  ORIYA SIGN NUKTA
        2877 => '',        #  ORIYA SIGN AVAGRAHA
        2878 => '',        #  ORIYA VOWEL SIGN AA
        2879 => '',        #  ORIYA VOWEL SIGN I
        2880 => '',        #  ORIYA VOWEL SIGN II
        2881 => '',        #  ORIYA VOWEL SIGN U
        2882 => '',        #  ORIYA VOWEL SIGN UU
        2883 => '',        #  ORIYA VOWEL SIGN VOCALIC R
        2887 => '',        #  ORIYA VOWEL SIGN E
        2888 => '',        #  ORIYA VOWEL SIGN AI
        2891 => '',        #  ORIYA VOWEL SIGN O
        2892 => '',        #  ORIYA VOWEL SIGN AU
        2893 => '',        #  ORIYA SIGN VIRAMA
        2902 => '',        #  ORIYA AI LENGTH MARK
        2903 => '',        #  ORIYA AU LENGTH MARK
        2908 => '',        #  ORIYA LETTER RRA
        2909 => '',        #  ORIYA LETTER RHA
        2911 => '',        #  ORIYA LETTER YYA
        2912 => '',        #  ORIYA LETTER VOCALIC RR
        2913 => '',        #  ORIYA LETTER VOCALIC LL
        2918 => '0',        #  ORIYA DIGIT ZERO
        2919 => '1',        #  ORIYA DIGIT ONE
        2920 => '2',        #  ORIYA DIGIT TWO
        2921 => '3',        #  ORIYA DIGIT THREE
        2922 => '4',        #  ORIYA DIGIT FOUR
        2923 => '5',        #  ORIYA DIGIT FIVE
        2924 => '6',        #  ORIYA DIGIT SIX
        2925 => '7',        #  ORIYA DIGIT SEVEN
        2926 => '8',        #  ORIYA DIGIT EIGHT
        2927 => '9',        #  ORIYA DIGIT NINE
        2928 => '',        #  ORIYA ISSHAR
        2929 => '',        #  ORIYA LETTER WA
        2946 => '',        #  TAMIL SIGN ANUSVARA
        2947 => '',        #  TAMIL SIGN VISARGA
        2949 => '',        #  TAMIL LETTER A
        2950 => '',        #  TAMIL LETTER AA
        2951 => '',        #  TAMIL LETTER I
        2952 => '',        #  TAMIL LETTER II
        2953 => '',        #  TAMIL LETTER U
        2954 => '',        #  TAMIL LETTER UU
        2958 => '',        #  TAMIL LETTER E
        2959 => '',        #  TAMIL LETTER EE
        2960 => '',        #  TAMIL LETTER AI
        2962 => '',        #  TAMIL LETTER O
        2963 => '',        #  TAMIL LETTER OO
        2964 => '',        #  TAMIL LETTER AU
        2965 => '',        #  TAMIL LETTER KA
        2969 => '',        #  TAMIL LETTER NGA
        2970 => '',        #  TAMIL LETTER CA
        2972 => '',        #  TAMIL LETTER JA
        2974 => '',        #  TAMIL LETTER NYA
        2975 => '',        #  TAMIL LETTER TTA
        2979 => '',        #  TAMIL LETTER NNA
        2980 => '',        #  TAMIL LETTER TA
        2984 => '',        #  TAMIL LETTER NA
        2985 => '',        #  TAMIL LETTER NNNA
        2986 => '',        #  TAMIL LETTER PA
        2990 => '',        #  TAMIL LETTER MA
        2991 => '',        #  TAMIL LETTER YA
        2992 => '',        #  TAMIL LETTER RA
        2993 => '',        #  TAMIL LETTER RRA
        2994 => '',        #  TAMIL LETTER LA
        2995 => '',        #  TAMIL LETTER LLA
        2996 => '',        #  TAMIL LETTER LLLA
        2997 => '',        #  TAMIL LETTER VA
        2998 => '',        #  TAMIL LETTER SHA
        2999 => '',        #  TAMIL LETTER SSA
        3000 => '',        #  TAMIL LETTER SA
        3001 => '',        #  TAMIL LETTER HA
        3006 => '',        #  TAMIL VOWEL SIGN AA
        3007 => '',        #  TAMIL VOWEL SIGN I
        3008 => '',        #  TAMIL VOWEL SIGN II
        3009 => '',        #  TAMIL VOWEL SIGN U
        3010 => '',        #  TAMIL VOWEL SIGN UU
        3014 => '',        #  TAMIL VOWEL SIGN E
        3015 => '',        #  TAMIL VOWEL SIGN EE
        3016 => '',        #  TAMIL VOWEL SIGN AI
        3018 => '',        #  TAMIL VOWEL SIGN O
        3019 => '',        #  TAMIL VOWEL SIGN OO
        3020 => '',        #  TAMIL VOWEL SIGN AU
        3021 => '',        #  TAMIL SIGN VIRAMA
        3031 => '',        #  TAMIL AU LENGTH MARK
        3046 => '0',        #  TAMIL DIGIT ZERO
        3047 => '1',        #  TAMIL DIGIT ONE
        3048 => '2',        #  TAMIL DIGIT TWO
        3049 => '3',        #  TAMIL DIGIT THREE
        3050 => '4',        #  TAMIL DIGIT FOUR
        3051 => '5',        #  TAMIL DIGIT FIVE
        3052 => '6',        #  TAMIL DIGIT SIX
        3053 => '7',        #  TAMIL DIGIT SEVEN
        3054 => '8',        #  TAMIL DIGIT EIGHT
        3055 => '9',        #  TAMIL DIGIT NINE
        3056 => '10',        #  TAMIL NUMBER TEN
        3057 => '100',        #  TAMIL NUMBER ONE HUNDRED
        3058 => '1000',        #  TAMIL NUMBER ONE THOUSAND
        3073 => '',        #  TELUGU SIGN CANDRABINDU
        3074 => '',        #  TELUGU SIGN ANUSVARA
        3075 => '',        #  TELUGU SIGN VISARGA
        3077 => '',        #  TELUGU LETTER A
        3078 => '',        #  TELUGU LETTER AA
        3079 => '',        #  TELUGU LETTER I
        3080 => '',        #  TELUGU LETTER II
        3081 => '',        #  TELUGU LETTER U
        3082 => '',        #  TELUGU LETTER UU
        3083 => '',        #  TELUGU LETTER VOCALIC R
        3084 => '',        #  TELUGU LETTER VOCALIC L
        3086 => '',        #  TELUGU LETTER E
        3087 => '',        #  TELUGU LETTER EE
        3088 => '',        #  TELUGU LETTER AI
        3090 => '',        #  TELUGU LETTER O
        3091 => '',        #  TELUGU LETTER OO
        3092 => '',        #  TELUGU LETTER AU
        3093 => '',        #  TELUGU LETTER KA
        3094 => '',        #  TELUGU LETTER KHA
        3095 => '',        #  TELUGU LETTER GA
        3096 => '',        #  TELUGU LETTER GHA
        3097 => '',        #  TELUGU LETTER NGA
        3098 => '',        #  TELUGU LETTER CA
        3099 => '',        #  TELUGU LETTER CHA
        3100 => '',        #  TELUGU LETTER JA
        3101 => '',        #  TELUGU LETTER JHA
        3102 => '',        #  TELUGU LETTER NYA
        3103 => '',        #  TELUGU LETTER TTA
        3104 => '',        #  TELUGU LETTER TTHA
        3105 => '',        #  TELUGU LETTER DDA
        3106 => '',        #  TELUGU LETTER DDHA
        3107 => '',        #  TELUGU LETTER NNA
        3108 => '',        #  TELUGU LETTER TA
        3109 => '',        #  TELUGU LETTER THA
        3110 => '',        #  TELUGU LETTER DA
        3111 => '',        #  TELUGU LETTER DHA
        3112 => '',        #  TELUGU LETTER NA
        3114 => '',        #  TELUGU LETTER PA
        3115 => '',        #  TELUGU LETTER PHA
        3116 => '',        #  TELUGU LETTER BA
        3117 => '',        #  TELUGU LETTER BHA
        3118 => '',        #  TELUGU LETTER MA
        3119 => '',        #  TELUGU LETTER YA
        3120 => '',        #  TELUGU LETTER RA
        3121 => '',        #  TELUGU LETTER RRA
        3122 => '',        #  TELUGU LETTER LA
        3123 => '',        #  TELUGU LETTER LLA
        3125 => '',        #  TELUGU LETTER VA
        3126 => '',        #  TELUGU LETTER SHA
        3127 => '',        #  TELUGU LETTER SSA
        3128 => '',        #  TELUGU LETTER SA
        3129 => '',        #  TELUGU LETTER HA
        3134 => '',        #  TELUGU VOWEL SIGN AA
        3135 => '',        #  TELUGU VOWEL SIGN I
        3136 => '',        #  TELUGU VOWEL SIGN II
        3137 => '',        #  TELUGU VOWEL SIGN U
        3138 => '',        #  TELUGU VOWEL SIGN UU
        3139 => '',        #  TELUGU VOWEL SIGN VOCALIC R
        3140 => '',        #  TELUGU VOWEL SIGN VOCALIC RR
        3142 => '',        #  TELUGU VOWEL SIGN E
        3143 => '',        #  TELUGU VOWEL SIGN EE
        3144 => '',        #  TELUGU VOWEL SIGN AI
        3146 => '',        #  TELUGU VOWEL SIGN O
        3147 => '',        #  TELUGU VOWEL SIGN OO
        3148 => '',        #  TELUGU VOWEL SIGN AU
        3149 => '',        #  TELUGU SIGN VIRAMA
        3157 => '',        #  TELUGU LENGTH MARK
        3158 => '',        #  TELUGU AI LENGTH MARK
        3168 => '',        #  TELUGU LETTER VOCALIC RR
        3169 => '',        #  TELUGU LETTER VOCALIC LL
        3174 => '0',        #  TELUGU DIGIT ZERO
        3175 => '1',        #  TELUGU DIGIT ONE
        3176 => '2',        #  TELUGU DIGIT TWO
        3177 => '3',        #  TELUGU DIGIT THREE
        3178 => '4',        #  TELUGU DIGIT FOUR
        3179 => '5',        #  TELUGU DIGIT FIVE
        3180 => '6',        #  TELUGU DIGIT SIX
        3181 => '7',        #  TELUGU DIGIT SEVEN
        3182 => '8',        #  TELUGU DIGIT EIGHT
        3183 => '9',        #  TELUGU DIGIT NINE
        3202 => '',        #  KANNADA SIGN ANUSVARA
        3203 => '',        #  KANNADA SIGN VISARGA
        3205 => '',        #  KANNADA LETTER A
        3206 => '',        #  KANNADA LETTER AA
        3207 => '',        #  KANNADA LETTER I
        3208 => '',        #  KANNADA LETTER II
        3209 => '',        #  KANNADA LETTER U
        3210 => '',        #  KANNADA LETTER UU
        3211 => '',        #  KANNADA LETTER VOCALIC R
        3212 => '',        #  KANNADA LETTER VOCALIC L
        3214 => '',        #  KANNADA LETTER E
        3215 => '',        #  KANNADA LETTER EE
        3216 => '',        #  KANNADA LETTER AI
        3218 => '',        #  KANNADA LETTER O
        3219 => '',        #  KANNADA LETTER OO
        3220 => '',        #  KANNADA LETTER AU
        3221 => '',        #  KANNADA LETTER KA
        3222 => '',        #  KANNADA LETTER KHA
        3223 => '',        #  KANNADA LETTER GA
        3224 => '',        #  KANNADA LETTER GHA
        3225 => '',        #  KANNADA LETTER NGA
        3226 => '',        #  KANNADA LETTER CA
        3227 => '',        #  KANNADA LETTER CHA
        3228 => '',        #  KANNADA LETTER JA
        3229 => '',        #  KANNADA LETTER JHA
        3230 => '',        #  KANNADA LETTER NYA
        3231 => '',        #  KANNADA LETTER TTA
        3232 => '',        #  KANNADA LETTER TTHA
        3233 => '',        #  KANNADA LETTER DDA
        3234 => '',        #  KANNADA LETTER DDHA
        3235 => '',        #  KANNADA LETTER NNA
        3236 => '',        #  KANNADA LETTER TA
        3237 => '',        #  KANNADA LETTER THA
        3238 => '',        #  KANNADA LETTER DA
        3239 => '',        #  KANNADA LETTER DHA
        3240 => '',        #  KANNADA LETTER NA
        3242 => '',        #  KANNADA LETTER PA
        3243 => '',        #  KANNADA LETTER PHA
        3244 => '',        #  KANNADA LETTER BA
        3245 => '',        #  KANNADA LETTER BHA
        3246 => '',        #  KANNADA LETTER MA
        3247 => '',        #  KANNADA LETTER YA
        3248 => '',        #  KANNADA LETTER RA
        3249 => '',        #  KANNADA LETTER RRA
        3250 => '',        #  KANNADA LETTER LA
        3251 => '',        #  KANNADA LETTER LLA
        3253 => '',        #  KANNADA LETTER VA
        3254 => '',        #  KANNADA LETTER SHA
        3255 => '',        #  KANNADA LETTER SSA
        3256 => '',        #  KANNADA LETTER SA
        3257 => '',        #  KANNADA LETTER HA
        3260 => '',        #  KANNADA SIGN NUKTA
        3261 => '',        #  KANNADA SIGN AVAGRAHA
        3262 => '',        #  KANNADA VOWEL SIGN AA
        3263 => '',        #  KANNADA VOWEL SIGN I
        3264 => '',        #  KANNADA VOWEL SIGN II
        3265 => '',        #  KANNADA VOWEL SIGN U
        3266 => '',        #  KANNADA VOWEL SIGN UU
        3267 => '',        #  KANNADA VOWEL SIGN VOCALIC R
        3268 => '',        #  KANNADA VOWEL SIGN VOCALIC RR
        3270 => '',        #  KANNADA VOWEL SIGN E
        3271 => '',        #  KANNADA VOWEL SIGN EE
        3272 => '',        #  KANNADA VOWEL SIGN AI
        3274 => '',        #  KANNADA VOWEL SIGN O
        3275 => '',        #  KANNADA VOWEL SIGN OO
        3276 => '',        #  KANNADA VOWEL SIGN AU
        3277 => '',        #  KANNADA SIGN VIRAMA
        3285 => '',        #  KANNADA LENGTH MARK
        3286 => '',        #  KANNADA AI LENGTH MARK
        3294 => '',        #  KANNADA LETTER FA
        3296 => '',        #  KANNADA LETTER VOCALIC RR
        3297 => '',        #  KANNADA LETTER VOCALIC LL
        3302 => '0',        #  KANNADA DIGIT ZERO
        3303 => '1',        #  KANNADA DIGIT ONE
        3304 => '2',        #  KANNADA DIGIT TWO
        3305 => '3',        #  KANNADA DIGIT THREE
        3306 => '4',        #  KANNADA DIGIT FOUR
        3307 => '5',        #  KANNADA DIGIT FIVE
        3308 => '6',        #  KANNADA DIGIT SIX
        3309 => '7',        #  KANNADA DIGIT SEVEN
        3310 => '8',        #  KANNADA DIGIT EIGHT
        3311 => '9',        #  KANNADA DIGIT NINE
        3330 => '',        #  MALAYALAM SIGN ANUSVARA
        3331 => '',        #  MALAYALAM SIGN VISARGA
        3333 => '',        #  MALAYALAM LETTER A
        3334 => '',        #  MALAYALAM LETTER AA
        3335 => '',        #  MALAYALAM LETTER I
        3336 => '',        #  MALAYALAM LETTER II
        3337 => '',        #  MALAYALAM LETTER U
        3338 => '',        #  MALAYALAM LETTER UU
        3339 => '',        #  MALAYALAM LETTER VOCALIC R
        3340 => '',        #  MALAYALAM LETTER VOCALIC L
        3342 => '',        #  MALAYALAM LETTER E
        3343 => '',        #  MALAYALAM LETTER EE
        3344 => '',        #  MALAYALAM LETTER AI
        3346 => '',        #  MALAYALAM LETTER O
        3347 => '',        #  MALAYALAM LETTER OO
        3348 => '',        #  MALAYALAM LETTER AU
        3349 => '',        #  MALAYALAM LETTER KA
        3350 => '',        #  MALAYALAM LETTER KHA
        3351 => '',        #  MALAYALAM LETTER GA
        3352 => '',        #  MALAYALAM LETTER GHA
        3353 => '',        #  MALAYALAM LETTER NGA
        3354 => '',        #  MALAYALAM LETTER CA
        3355 => '',        #  MALAYALAM LETTER CHA
        3356 => '',        #  MALAYALAM LETTER JA
        3357 => '',        #  MALAYALAM LETTER JHA
        3358 => '',        #  MALAYALAM LETTER NYA
        3359 => '',        #  MALAYALAM LETTER TTA
        3360 => '',        #  MALAYALAM LETTER TTHA
        3361 => '',        #  MALAYALAM LETTER DDA
        3362 => '',        #  MALAYALAM LETTER DDHA
        3363 => '',        #  MALAYALAM LETTER NNA
        3364 => '',        #  MALAYALAM LETTER TA
        3365 => '',        #  MALAYALAM LETTER THA
        3366 => '',        #  MALAYALAM LETTER DA
        3367 => '',        #  MALAYALAM LETTER DHA
        3368 => '',        #  MALAYALAM LETTER NA
        3370 => '',        #  MALAYALAM LETTER PA
        3371 => '',        #  MALAYALAM LETTER PHA
        3372 => '',        #  MALAYALAM LETTER BA
        3373 => '',        #  MALAYALAM LETTER BHA
        3374 => '',        #  MALAYALAM LETTER MA
        3375 => '',        #  MALAYALAM LETTER YA
        3376 => '',        #  MALAYALAM LETTER RA
        3377 => '',        #  MALAYALAM LETTER RRA
        3378 => '',        #  MALAYALAM LETTER LA
        3379 => '',        #  MALAYALAM LETTER LLA
        3380 => '',        #  MALAYALAM LETTER LLLA
        3381 => '',        #  MALAYALAM LETTER VA
        3382 => '',        #  MALAYALAM LETTER SHA
        3383 => '',        #  MALAYALAM LETTER SSA
        3384 => '',        #  MALAYALAM LETTER SA
        3385 => '',        #  MALAYALAM LETTER HA
        3390 => '',        #  MALAYALAM VOWEL SIGN AA
        3391 => '',        #  MALAYALAM VOWEL SIGN I
        3392 => '',        #  MALAYALAM VOWEL SIGN II
        3393 => '',        #  MALAYALAM VOWEL SIGN U
        3394 => '',        #  MALAYALAM VOWEL SIGN UU
        3395 => '',        #  MALAYALAM VOWEL SIGN VOCALIC R
        3398 => '',        #  MALAYALAM VOWEL SIGN E
        3399 => '',        #  MALAYALAM VOWEL SIGN EE
        3400 => '',        #  MALAYALAM VOWEL SIGN AI
        3402 => '',        #  MALAYALAM VOWEL SIGN O
        3403 => '',        #  MALAYALAM VOWEL SIGN OO
        3404 => '',        #  MALAYALAM VOWEL SIGN AU
        3405 => '',        #  MALAYALAM SIGN VIRAMA
        3415 => '',        #  MALAYALAM AU LENGTH MARK
        3424 => '',        #  MALAYALAM LETTER VOCALIC RR
        3425 => '',        #  MALAYALAM LETTER VOCALIC LL
        3430 => '0',        #  MALAYALAM DIGIT ZERO
        3431 => '1',        #  MALAYALAM DIGIT ONE
        3432 => '2',        #  MALAYALAM DIGIT TWO
        3433 => '3',        #  MALAYALAM DIGIT THREE
        3434 => '4',        #  MALAYALAM DIGIT FOUR
        3435 => '5',        #  MALAYALAM DIGIT FIVE
        3436 => '6',        #  MALAYALAM DIGIT SIX
        3437 => '7',        #  MALAYALAM DIGIT SEVEN
        3438 => '8',        #  MALAYALAM DIGIT EIGHT
        3439 => '9',        #  MALAYALAM DIGIT NINE
  );


  exit;