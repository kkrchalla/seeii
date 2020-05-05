#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  my $queue_num =  $ARGV[0];
  my $out_log_file = "c:/seeii/log/parser" . $queue_num . ".log";
  open(STDOUT, ">>$out_log_file") or die "Cannot open $out_log_file for WRITING: $!";
  open(STDERR, ">&STDOUT") or die "Cannot open $out_log_file for WRITING: $!";

  my $process_file = "c:/seeii/process/parser" . $queue_num;
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   Parser - $queue_num \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $force_end_file = "c:/seeii/process/endparser";

# PARSER will run constantly.
# PARSER will read the URLID, with the least ADD_DATE, from the 
# PARSE_URL_TAB table, and will take the content from the CONTENT_TAB. 
# It will then remove all the HTML tags, and get the words of meta data 
#   and put it in META of the CONTENT_TAB, words of headers in HEADER fields 
#   with main header words in HEADER1, second header words in HEADER2...
# It will also take the title and meta-description and put it in the TITLE_DESC_TAB.
# If a word is repeated multiple times, it will also repeat the word.
# In the process of parsing, it will get the linked URLS and add them to the URL_BACKLINK_TAB. 
# These URLS were already added to the URL_TAB by the reader. So, it will get
# the URL_ID from the content and it will a link in the URL_BACKLINK_TAB.
# It will add this record only once, no matter how many times the page linked to a URL. 
# It will then check the URL_LINKRANK_TAB for this URLID. If it is not present, 
#   it will add the URLID with LINKRANK = 0.
# Then it will take the text that was used in the Link, and will update the WORD_LINK_TAB. 
# It will add one word only once no matter how many times it was in a link or 
#   in how many links. But it does take all the words in all the links 
#   even though it will add a link only once.
# To improve the performance, the word_ids for a word will not be selected from the WORD_TAB on the fly.
# Instead the whole WORD_TAB table will be downloaded into a hash and this hash will be used
#   to get the word_ids.
# If in this process if it cannot find a word in the words hash, it will add a new one to the WORD_TAB.
# Then it will add a row to WORD_COUNT_RANK_TAB with the counts as follows
# 	WORDCOUNT	number of times in CONTENT
#	METACOUNT	value will be 1 if it occurs in META
#		(no matter how many times it is repeated)
#	HEADRCOUNT	(number of times in HEADR1) * 3
#			(number of times in HEADR2) * 2 
#			(number of times in HEADR3) * 1
#	ALTCOUNT	number of times in ALT
#	URLCOUNT	number of times in URL
#	TOTALUNIQUEWORDCOUNT
# In the end it will update the CONTENT in the CONTENT_TAB with the parsed 
#   one that has no html tags and metadata. 
# Once the parsing is done it will remove the URL from the PARSE_URL_TAB.
# It will also update the LAST_PARSED of URL_TAB with the current date.

  use Fcntl;
  use DBI;
  use URI;
  use IO::Handle;
#  use Text::Metaphone qw(Metaphone);

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success, $global_content);

  my $db_package = "";
  package AnyDBM_File;
  @ISA = qw(DB_File);
  # You may try to comment in the next line if you don't have DB_File. Still
  # this is not recommended.
  #@ISA = qw(DB_File GDBM_File SDBM_File ODBM_File NDBM_File);
  foreach my $isa (@ISA) {
    if( eval("require $isa") ) {
      $db_package = $isa;
      last;
    }
  }
  if( $db_package  ne 'DB_File' ) {
    print "No DBM file... \n";
    exit;
  }

  my @EXT = ("html", "HTML", "htm", "HTM", "shtml", "SHTML", "pdf", "PDF", "doc", "DOC");
  my $CONTEXT_SIZE = undef;	# seeii - move a real value to CONTEXT_SIZE to store content
  my $DESC_WORDS = 25;
  my $MAX_TITLE_LENGTH = 80;
  my (%uw, %aw, %bw, %hw1, %hw2, %hw3, %tmw);

  my ($ldatawc, $ldatawli, $ldatawla, $ldatabl, $ldatalr, $ldatatd);
  my ($temp1file, $temp2file, $temp3file, $temp4file, $temp5file, $temp6file);
  my ($select_parse, $delete_parse, $update_url, $update_url_child, $select_content, $update_content, $select_word, $insert_word);

  my $total_unique_word_count;

  my $special_chars = undef;


  my %entities = (
	192 => 'Agrave',	#  capital A, grave accent 
	193 => 'Aacute',	#  capital A, acute accent 
	194 => 'Acirc',		#  capital A, circumflex accent 
	195 => 'Atilde',	#  capital A, tilde 
	196 => 'Auml',		#  capital A, dieresis or umlaut mark 
	197 => 'Aring',		#  capital A, ring 
	198 => 'AElig',		#  capital AE diphthong (ligature) 
	199 => 'Ccedil',	#  capital C, cedilla 
	200 => 'Egrave',	#  capital E, grave accent 
	201 => 'Eacute',	#  capital E, acute accent 
	202 => 'Ecirc',		#  capital E, circumflex accent 
	203 => 'Euml',		#  capital E, dieresis or umlaut mark 
	205 => 'Igrave',	#  capital I, grave accent 
	204 => 'Iacute',	#  capital I, acute accent 
	206 => 'Icirc',		#  capital I, circumflex accent 
	207 => 'Iuml',		#  capital I, dieresis or umlaut mark 
	208 => 'ETH',		#  capital Eth, Icelandic (Dstrok) 
	209 => 'Ntilde',	#  capital N, tilde 
	210 => 'Ograve',	#  capital O, grave accent 
	211 => 'Oacute',	#  capital O, acute accent 
	212 => 'Ocirc',		#  capital O, circumflex accent 
	213 => 'Otilde',	#  capital O, tilde 
	214 => 'Ouml',		#  capital O, dieresis or umlaut mark 
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
	230 => 'aelig',		#  small ae diphthong (ligature) 
	231 => 'ccedil',	#  small c, cedilla 
	232 => 'egrave',	#  small e, grave accent 
	233 => 'eacute',	#  small e, acute accent 
	234 => 'ecirc',		#  small e, circumflex accent 
	235 => 'euml',		#  small e, dieresis or umlaut mark 
	236 => 'igrave',	#  small i, grave accent 
	237 => 'iacute',	#  small i, acute accent 
	238 => 'icirc',		#  small i, circumflex accent 
	239 => 'iuml',		#  small i, dieresis or umlaut mark 
	240 => 'eth',		#  small eth, Icelandic 
	241 => 'ntilde',	#  small n, tilde 
	242 => 'ograve',	#  small o, grave accent 
	243 => 'oacute',	#  small o, acute accent 
	244 => 'ocirc',		#  small o, circumflex accent 
	245 => 'otilde',	#  small o, tilde 
	246 => 'ouml',		#  small o, dieresis or umlaut mark 
	248 => 'oslash',	#  small o, slash 
	249 => 'ugrave',	#  small u, grave accent 
	250 => 'uacute',	#  small u, acute accent 
	251 => 'ucirc',		#  small u, circumflex accent 
	252 => 'uuml',		#  small u, dieresis or umlaut mark 
	253 => 'yacute',	#  small y, acute accent 
	254 => 'thorn',		#  small thorn, Icelandic 
	255 => 'yuml',		#  small y, dieresis or umlaut mark
  );


  my %indian_chars = (
        2305 => 'n',        #  DEVANAGARI SIGN CANDRABINDU
        2306 => 'n',        #  DEVANAGARI SIGN ANUSVARA
        2307 => 'aha',      #  DEVANAGARI SIGN VISARGA
#        2308 => '',         #  DEVANAGARI LETTER SHORT A
        2309 => 'a',        #  DEVANAGARI LETTER A
        2310 => 'aa',       #  DEVANAGARI LETTER AA
        2311 => 'i',        #  DEVANAGARI LETTER I
        2312 => 'ii',       #  DEVANAGARI LETTER II
        2313 => 'u',        #  DEVANAGARI LETTER U
        2314 => 'uu',       #  DEVANAGARI LETTER UU
        2315 => 'ru',       #  DEVANAGARI LETTER VOCALIC R
        2316 => 'lu',       #  DEVANAGARI LETTER VOCALIC L
        2317 => 'e',        #  DEVANAGARI LETTER CANDRA E
        2318 => 'e',        #  DEVANAGARI LETTER SHORT E
        2319 => 'e',        #  DEVANAGARI LETTER E
        2320 => 'ai',       #  DEVANAGARI LETTER AI
        2321 => 'o',        #  DEVANAGARI LETTER CANDRA O
        2322 => 'o',        #  DEVANAGARI LETTER SHORT O
        2323 => 'o',        #  DEVANAGARI LETTER O
        2324 => 'au',       #  DEVANAGARI LETTER AU
        2325 => 'ka',       #  DEVANAGARI LETTER KA
        2326 => 'kha',      #  DEVANAGARI LETTER KHA
        2327 => 'ga',       #  DEVANAGARI LETTER GA
        2328 => 'gha',      #  DEVANAGARI LETTER GHA
        2329 => 'nga',      #  DEVANAGARI LETTER NGA
        2330 => 'cha',      #  DEVANAGARI LETTER CA
        2331 => 'chha',     #  DEVANAGARI LETTER CHA
        2332 => 'ja',       #  DEVANAGARI LETTER JA
        2333 => 'jha',      #  DEVANAGARI LETTER JHA
        2334 => 'nya',      #  DEVANAGARI LETTER NYA
        2335 => 'ta',       #  DEVANAGARI LETTER TTA
        2336 => 'tta',      #  DEVANAGARI LETTER TTHA
        2337 => 'da',       #  DEVANAGARI LETTER DDA
        2338 => 'dda',      #  DEVANAGARI LETTER DDHA
        2339 => 'na',       #  DEVANAGARI LETTER NNA
        2340 => 'tha',      #  DEVANAGARI LETTER TA
        2341 => 'thha',     #  DEVANAGARI LETTER THA
        2342 => 'dha',      #  DEVANAGARI LETTER DA
        2343 => 'dhha',     #  DEVANAGARI LETTER DHA
        2344 => 'na',       #  DEVANAGARI LETTER NA
        2345 => 'nnna',     #  DEVANAGARI LETTER NNNA
        2346 => 'pa',       #  DEVANAGARI LETTER PA
        2347 => 'pha',      #  DEVANAGARI LETTER PHA
        2348 => 'ba',       #  DEVANAGARI LETTER BA
        2349 => 'bha',      #  DEVANAGARI LETTER BHA
        2350 => 'ma',       #  DEVANAGARI LETTER MA
        2351 => 'ya',       #  DEVANAGARI LETTER YA
        2352 => 'ra',       #  DEVANAGARI LETTER RA
        2353 => 'rra',      #  DEVANAGARI LETTER RRA
        2354 => 'la',       #  DEVANAGARI LETTER LA
        2355 => 'lla',      #  DEVANAGARI LETTER LLA
        2356 => 'llla',     #  DEVANAGARI LETTER LLLA
        2357 => 'va',       #  DEVANAGARI LETTER VA
        2358 => 'sha',      #  DEVANAGARI LETTER SHA
        2359 => 'sha',      #  DEVANAGARI LETTER SSA
        2360 => 'sa',       #  DEVANAGARI LETTER SA
        2361 => 'ha',       #  DEVANAGARI LETTER HA
#        2364 => '',         #  DEVANAGARI SIGN NUKTA
#        2365 => '',         #  DEVANAGARI SIGN AVAGRAHA
        2366 => '-aa',        #  DEVANAGARI VOWEL SIGN AA
        2367 => '-i',        #  DEVANAGARI VOWEL SIGN I
        2368 => '-ii',       #  DEVANAGARI VOWEL SIGN II
        2369 => '-u',        #  DEVANAGARI VOWEL SIGN U
        2370 => '-uu',       #  DEVANAGARI VOWEL SIGN UU
        2371 => '-ru',       #  DEVANAGARI VOWEL SIGN VOCALIC R
        2372 => '-ruu',      #  DEVANAGARI VOWEL SIGN VOCALIC RR
        2373 => '-e',        #  DEVANAGARI VOWEL SIGN CANDRA E
        2374 => '-e',        #  DEVANAGARI VOWEL SIGN SHORT E
        2375 => '-e',        #  DEVANAGARI VOWEL SIGN E
        2376 => '-ai',       #  DEVANAGARI VOWEL SIGN AI
        2377 => '-o',        #  DEVANAGARI VOWEL SIGN CANDRA O
        2378 => '-o',        #  DEVANAGARI VOWEL SIGN SHORT O
        2379 => '-o',        #  DEVANAGARI VOWEL SIGN O
        2380 => '-au',       #  DEVANAGARI VOWEL SIGN AU
        2381 => '-',        #  DEVANAGARI SIGN VIRAMA
        2384 => 'om',       #  DEVANAGARI OM
#        2385 => '',         #  DEVANAGARI STRESS SIGN UDATTA
#        2386 => '',         #  DEVANAGARI STRESS SIGN ANUDATTA
#        2387 => '',         #  DEVANAGARI GRAVE ACCENT
#        2388 => '',         #  DEVANAGARI ACUTE ACCENT
        2392 => 'qa',       #  DEVANAGARI LETTER QA
        2393 => 'khha',     #  DEVANAGARI LETTER KHHA
        2394 => 'ghha',     #  DEVANAGARI LETTER GHHA
        2395 => 'za',       #  DEVANAGARI LETTER ZA
        2396 => 'ddha',     #  DEVANAGARI LETTER DDDHA
        2397 => 'rha',      #  DEVANAGARI LETTER RHA
        2398 => 'fa',       #  DEVANAGARI LETTER FA
        2399 => 'yya',      #  DEVANAGARI LETTER YYA
        2400 => 'ruu',      #  DEVANAGARI LETTER VOCALIC RR
        2401 => 'luu',      #  DEVANAGARI LETTER VOCALIC LL
        2402 => '-lu',       #  DEVANAGARI VOWEL SIGN VOCALIC L
        2403 => '-luu',      #  DEVANAGARI VOWEL SIGN VOCALIC LL
#        2404 => '',         #  DEVANAGARI DANDA
#        2405 => '',         #  DEVANAGARI DOUBLE DANDA
        2406 => '0',        #  DEVANAGARI DIGIT ZERO
        2407 => '1',        #  DEVANAGARI DIGIT ONE
        2408 => '2',        #  DEVANAGARI DIGIT TWO
        2409 => '3',        #  DEVANAGARI DIGIT THREE
        2410 => '4',        #  DEVANAGARI DIGIT FOUR
        2411 => '5',        #  DEVANAGARI DIGIT FIVE
        2412 => '6',        #  DEVANAGARI DIGIT SIX
        2413 => '7',        #  DEVANAGARI DIGIT SEVEN
        2414 => '8',        #  DEVANAGARI DIGIT EIGHT
        2415 => '9',        #  DEVANAGARI DIGIT NINE
#        2416 => '',         #  DEVANAGARI ABBREVIATION SIGN
#        2429 => '',         #  DEVANAGARI LETTER GLOTTAL STOP
        2433 => 'n',        #  BENGALI SIGN CANDRABINDU
        2434 => 'n',        #  BENGALI SIGN ANUSVARA
        2435 => 'aha',      #  BENGALI SIGN VISARGA
        2437 => 'a',        #  BENGALI LETTER A
        2438 => 'aa',       #  BENGALI LETTER AA
        2439 => 'i',        #  BENGALI LETTER I
        2440 => 'ii',       #  BENGALI LETTER II
        2441 => 'u',        #  BENGALI LETTER U
        2442 => 'uu',       #  BENGALI LETTER UU
        2443 => 'ru',       #  BENGALI LETTER VOCALIC R
        2444 => 'lu',       #  BENGALI LETTER VOCALIC L
        2447 => 'e',        #  BENGALI LETTER E
        2448 => 'ai',       #  BENGALI LETTER AI
        2451 => 'o',        #  BENGALI LETTER O
        2452 => 'au',       #  BENGALI LETTER AU
        2453 => 'ka',       #  BENGALI LETTER KA
        2454 => 'kha',      #  BENGALI LETTER KHA
        2455 => 'ga',       #  BENGALI LETTER GA
        2456 => 'gha',      #  BENGALI LETTER GHA
        2457 => 'nga',      #  BENGALI LETTER NGA
        2458 => 'cha',      #  BENGALI LETTER CA
        2459 => 'chha',     #  BENGALI LETTER CHA
        2460 => 'ja',       #  BENGALI LETTER JA
        2461 => 'jha',      #  BENGALI LETTER JHA
        2462 => 'nya',      #  BENGALI LETTER NYA
        2463 => 'ta',       #  BENGALI LETTER TTA
        2464 => 'tta',      #  BENGALI LETTER TTHA
        2465 => 'da',       #  BENGALI LETTER DDA
        2466 => 'dda',      #  BENGALI LETTER DDHA
        2467 => 'na',       #  BENGALI LETTER NNA
        2468 => 'tha',      #  BENGALI LETTER TA
        2469 => 'thha',     #  BENGALI LETTER THA
        2470 => 'dha',      #  BENGALI LETTER DA
        2471 => 'dhha',     #  BENGALI LETTER DHA
        2472 => 'na',       #  BENGALI LETTER NA
        2474 => 'pa',       #  BENGALI LETTER PA
        2475 => 'pha',      #  BENGALI LETTER PHA
        2476 => 'ba',       #  BENGALI LETTER BA
        2477 => 'bha',      #  BENGALI LETTER BHA
        2478 => 'ma',       #  BENGALI LETTER MA
        2479 => 'ya',       #  BENGALI LETTER YA
        2480 => 'ra',       #  BENGALI LETTER RA
        2482 => 'la',       #  BENGALI LETTER LA
        2486 => 'sha',      #  BENGALI LETTER SHA
        2487 => 'sha',      #  BENGALI LETTER SSA
        2488 => 'sa',       #  BENGALI LETTER SA
        2489 => 'ha',       #  BENGALI LETTER HA
#        2492 => '',         #  BENGALI SIGN NUKTA
#        2493 => '',         #  BENGALI SIGN AVAGRAHA
        2494 => '-aa',       #  BENGALI VOWEL SIGN AA
        2495 => '-i',        #  BENGALI VOWEL SIGN I
        2496 => '-ii',       #  BENGALI VOWEL SIGN II
        2497 => '-u',        #  BENGALI VOWEL SIGN U
        2498 => '-uu',       #  BENGALI VOWEL SIGN UU
        2499 => '-ru',       #  BENGALI VOWEL SIGN VOCALIC R
        2500 => '-ruu',      #  BENGALI VOWEL SIGN VOCALIC RR
        2503 => '-e',        #  BENGALI VOWEL SIGN E
        2504 => '-ai',       #  BENGALI VOWEL SIGN AI
        2507 => '-o',        #  BENGALI VOWEL SIGN O
        2508 => '-au',       #  BENGALI VOWEL SIGN AU
        2509 => '-',        #  BENGALI SIGN VIRAMA
#        2510 => '',         #  BENGALI LETTER KHANDA TA
        2519 => '-au',      #  BENGALI AU LENGTH MARK
        2524 => 'rra',      #  BENGALI LETTER RRA
        2525 => 'rha',      #  BENGALI LETTER RHA
        2527 => 'yya',      #  BENGALI LETTER YYA
        2528 => 'ruu',      #  BENGALI LETTER VOCALIC RR
        2529 => 'luu',      #  BENGALI LETTER VOCALIC LL
        2530 => '-lu',       #  BENGALI VOWEL SIGN VOCALIC L
        2531 => '-luu',      #  BENGALI VOWEL SIGN VOCALIC LL
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
        2544 => 'ra',       #  BENGALI LETTER RA WITH MIDDLE DIAGONAL
        2545 => 'ra',       #  BENGALI LETTER RA WITH LOWER DIAGONAL
#        2546 => '',         #  BENGALI RUPEE MARK
#        2547 => '',         #  BENGALI RUPEE SIGN
#        2548 => '',         #  BENGALI CURRENCY NUMERATOR ONE
#        2549 => '',         #  BENGALI CURRENCY NUMERATOR TWO
#        2550 => '',         #  BENGALI CURRENCY NUMERATOR THREE
#        2551 => '',         #  BENGALI CURRENCY NUMERATOR FOUR
#        2552 => '',         #  BENGALI CURRENCY NUMERATOR ONE LESS THAN THE DENOMINATOR
#        2553 => '',         #  BENGALI CURRENCY DENOMINATOR SIXTEEN
#        2554 => '',         #  BENGALI ISSHAR
#        2561 => '',         #  GURMUKHI SIGN ADAK BINDI
        2562 => 'n',        #  GURMUKHI SIGN BINDI
        2563 => 'aha',      #  GURMUKHI SIGN VISARGA
        2565 => 'a',        #  GURMUKHI LETTER A
        2566 => 'aa',       #  GURMUKHI LETTER AA
        2567 => 'i',        #  GURMUKHI LETTER I
        2568 => 'ii',       #  GURMUKHI LETTER II
        2569 => 'u',        #  GURMUKHI LETTER U
        2570 => 'uu',       #  GURMUKHI LETTER UU
        2575 => 'ee',       #  GURMUKHI LETTER EE
        2576 => 'ai',       #  GURMUKHI LETTER AI
        2579 => 'oo',       #  GURMUKHI LETTER OO
        2580 => 'au',       #  GURMUKHI LETTER AU
        2581 => 'ka',       #  GURMUKHI LETTER KA
        2582 => 'kha',      #  GURMUKHI LETTER KHA
        2583 => 'ga',       #  GURMUKHI LETTER GA
        2584 => 'gha',      #  GURMUKHI LETTER GHA
        2585 => 'nga',      #  GURMUKHI LETTER NGA
        2586 => 'cha',      #  GURMUKHI LETTER CA
        2587 => 'chha',     #  GURMUKHI LETTER CHA
        2588 => 'ja',       #  GURMUKHI LETTER JA
        2589 => 'jha',      #  GURMUKHI LETTER JHA
        2590 => 'nya',      #  GURMUKHI LETTER NYA
        2591 => 'ta',       #  GURMUKHI LETTER TTA
        2592 => 'tta',      #  GURMUKHI LETTER TTHA
        2593 => 'da',       #  GURMUKHI LETTER DDA
        2594 => 'dda',      #  GURMUKHI LETTER DDHA
        2595 => 'na',       #  GURMUKHI LETTER NNA
        2596 => 'tha',      #  GURMUKHI LETTER TA
        2597 => 'thha',     #  GURMUKHI LETTER THA
        2598 => 'dha',      #  GURMUKHI LETTER DA
        2599 => 'dhha',     #  GURMUKHI LETTER DHA
        2600 => 'na',       #  GURMUKHI LETTER NA
        2602 => 'pa',       #  GURMUKHI LETTER PA
        2603 => 'pha',      #  GURMUKHI LETTER PHA
        2604 => 'ba',       #  GURMUKHI LETTER BA
        2605 => 'bha',      #  GURMUKHI LETTER BHA
        2606 => 'ma',       #  GURMUKHI LETTER MA
        2607 => 'ya',       #  GURMUKHI LETTER YA
        2608 => 'ra',       #  GURMUKHI LETTER RA
        2610 => 'la',       #  GURMUKHI LETTER LA
        2611 => 'lla',      #  GURMUKHI LETTER LLA
        2613 => 'va',       #  GURMUKHI LETTER VA
        2614 => 'sha',      #  GURMUKHI LETTER SHA
        2616 => 'sa',       #  GURMUKHI LETTER SA
        2617 => 'ha',       #  GURMUKHI LETTER HA
#        2620 => '',         #  GURMUKHI SIGN NUKTA
        2622 => '-aa',       #  GURMUKHI VOWEL SIGN AA
        2623 => '-i',        #  GURMUKHI VOWEL SIGN I
        2624 => '-ii',       #  GURMUKHI VOWEL SIGN II
        2625 => '-u',        #  GURMUKHI VOWEL SIGN U
        2626 => '-uu',       #  GURMUKHI VOWEL SIGN UU
        2631 => '-ee',       #  GURMUKHI VOWEL SIGN EE
        2632 => '-ai',       #  GURMUKHI VOWEL SIGN AI
        2635 => '-oo',       #  GURMUKHI VOWEL SIGN OO
        2636 => '-au',       #  GURMUKHI VOWEL SIGN AU
        2637 => '-',        #  GURMUKHI SIGN VIRAMA
        2649 => 'khha',     #  GURMUKHI LETTER KHHA
        2650 => 'ghha',     #  GURMUKHI LETTER GHHA
        2651 => 'za',       #  GURMUKHI LETTER ZA
        2652 => 'rr',       #  GURMUKHI LETTER RRA
        2654 => 'fa',       #  GURMUKHI LETTER FA
        2662 => '0',        #  GURMUKHI DIGIT ZERO
        2663 => '1',        #  GURMUKHI DIGIT ONE
        2664 => '2',        #  GURMUKHI DIGIT TWO
        2665 => '3',        #  GURMUKHI DIGIT THREE
        2666 => '4',        #  GURMUKHI DIGIT FOUR
        2667 => '5',        #  GURMUKHI DIGIT FIVE
        2668 => '6',        #  GURMUKHI DIGIT SIX
        2669 => '7',        #  GURMUKHI DIGIT SEVEN
        2670 => '8',        #  GURMUKHI DIGIT EIGHT
        2671 => '9',        #  GURMUKHI DIGIT NINE
#        2672 => '',         #  GURMUKHI TIPPI
#        2673 => '',         #  GURMUKHI ADDAK
#        2674 => '',         #  GURMUKHI IRI
#        2675 => '',         #  GURMUKHI URA
        2676 => 'om',       #  GURMUKHI EK ONKAR
        2689 => 'n',        #  GUJARATI SIGN CANDRABINDU
        2690 => 'n',        #  GUJARATI SIGN ANUSVARA
        2691 => 'aha',      #  GUJARATI SIGN VISARGA
        2693 => 'a',        #  GUJARATI LETTER A
        2694 => 'aa',       #  GUJARATI LETTER AA
        2695 => 'i',        #  GUJARATI LETTER I
        2696 => 'ii',       #  GUJARATI LETTER II
        2697 => 'u',        #  GUJARATI LETTER U
        2698 => 'uu',       #  GUJARATI LETTER UU
        2699 => 'ru',       #  GUJARATI LETTER VOCALIC R
        2700 => 'lu',       #  GUJARATI LETTER VOCALIC L
        2701 => 'e',        #  GUJARATI VOWEL CANDRA E
        2703 => 'ee',       #  GUJARATI LETTER E
        2704 => 'ai',       #  GUJARATI LETTER AI
        2705 => 'o',        #  GUJARATI VOWEL CANDRA O
        2707 => 'oo',       #  GUJARATI LETTER O
        2708 => 'au',       #  GUJARATI LETTER AU
        2709 => 'ka',       #  GUJARATI LETTER KA
        2710 => 'kha',      #  GUJARATI LETTER KHA
        2711 => 'ga',       #  GUJARATI LETTER GA
        2712 => 'gha',      #  GUJARATI LETTER GHA
        2713 => 'nga',      #  GUJARATI LETTER NGA
        2714 => 'cha',      #  GUJARATI LETTER CA
        2715 => 'chha',     #  GUJARATI LETTER CHA
        2716 => 'ja',       #  GUJARATI LETTER JA
        2717 => 'jha',      #  GUJARATI LETTER JHA
        2718 => 'nya',      #  GUJARATI LETTER NYA
        2719 => 'ta',       #  GUJARATI LETTER TTA
        2720 => 'tta',      #  GUJARATI LETTER TTHA
        2721 => 'da',       #  GUJARATI LETTER DDA
        2722 => 'dda',      #  GUJARATI LETTER DDHA
        2723 => 'na',       #  GUJARATI LETTER NNA
        2724 => 'tha',      #  GUJARATI LETTER TA
        2725 => 'thha',     #  GUJARATI LETTER THA
        2726 => 'dha',      #  GUJARATI LETTER DA
        2727 => 'dhha',     #  GUJARATI LETTER DHA
        2728 => 'na',       #  GUJARATI LETTER NA
        2730 => 'pa',       #  GUJARATI LETTER PA
        2731 => 'pha',      #  GUJARATI LETTER PHA
        2732 => 'ba',       #  GUJARATI LETTER BA
        2733 => 'bha',      #  GUJARATI LETTER BHA
        2734 => 'ma',       #  GUJARATI LETTER MA
        2735 => 'ya',       #  GUJARATI LETTER YA
        2736 => 'ra',       #  GUJARATI LETTER RA
        2738 => 'la',       #  GUJARATI LETTER LA
        2739 => 'lla',      #  GUJARATI LETTER LLA
        2741 => 'va',       #  GUJARATI LETTER VA
        2742 => 'sha',      #  GUJARATI LETTER SHA
        2743 => 'sha',      #  GUJARATI LETTER SSA
        2744 => 'sa',       #  GUJARATI LETTER SA
        2745 => 'ha',       #  GUJARATI LETTER HA
#        2748 => '',         #  GUJARATI SIGN NUKTA
#        2749 => '',         #  GUJARATI SIGN AVAGRAHA
        2750 => '-aa',       #  GUJARATI VOWEL SIGN AA
        2751 => '-i',        #  GUJARATI VOWEL SIGN I
        2752 => '-ii',       #  GUJARATI VOWEL SIGN II
        2753 => '-u',        #  GUJARATI VOWEL SIGN U
        2754 => '-uu',       #  GUJARATI VOWEL SIGN UU
        2755 => '-ru',       #  GUJARATI VOWEL SIGN VOCALIC R
        2756 => '-ruu',      #  GUJARATI VOWEL SIGN VOCALIC RR
        2757 => '-e',        #  GUJARATI VOWEL SIGN CANDRA E
        2759 => '-ee',       #  GUJARATI VOWEL SIGN E
        2760 => '-ai',       #  GUJARATI VOWEL SIGN AI
        2761 => '-o',        #  GUJARATI VOWEL SIGN CANDRA O
        2763 => '-oo',       #  GUJARATI VOWEL SIGN O
        2764 => '-au',       #  GUJARATI VOWEL SIGN AU
        2765 => '-',        #  GUJARATI SIGN VIRAMA
        2768 => 'om',       #  GUJARATI OM
        2784 => 'ruu',      #  GUJARATI LETTER VOCALIC RR
#        2785 => '',         #  GUJARATI LETTER VOCALIC LL
#        2786 => '',         #  GUJARATI VOWEL SIGN VOCALIC L
#        2787 => '',         #  GUJARATI VOWEL SIGN VOCALIC LL
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
#        2801 => '',         #  GUJARATI RUPEE SIGN
        2817 => 'n',        #  ORIYA SIGN CANDRABINDU
        2818 => 'n',        #  ORIYA SIGN ANUSVARA
        2819 => 'aha',      #  ORIYA SIGN VISARGA
        2821 => 'a',        #  ORIYA LETTER A
        2822 => 'aa',       #  ORIYA LETTER AA
        2823 => 'i',        #  ORIYA LETTER I
        2824 => 'ii',       #  ORIYA LETTER II
        2825 => 'u',        #  ORIYA LETTER U
        2826 => 'uu',       #  ORIYA LETTER UU
        2827 => 'ru',       #  ORIYA LETTER VOCALIC R
        2828 => 'lu',       #  ORIYA LETTER VOCALIC L
        2831 => 'e',        #  ORIYA LETTER E
        2832 => 'ai',       #  ORIYA LETTER AI
        2835 => 'o',        #  ORIYA LETTER O
        2836 => 'au',       #  ORIYA LETTER AU
        2837 => 'ka',       #  ORIYA LETTER KA
        2838 => 'kha',      #  ORIYA LETTER KHA
        2839 => 'ga',       #  ORIYA LETTER GA
        2840 => 'gha',      #  ORIYA LETTER GHA
        2841 => 'nga',      #  ORIYA LETTER NGA
        2842 => 'cha',      #  ORIYA LETTER CA
        2843 => 'chha',     #  ORIYA LETTER CHA
        2844 => 'ja',       #  ORIYA LETTER JA
        2845 => 'jha',      #  ORIYA LETTER JHA
        2846 => 'nya',      #  ORIYA LETTER NYA
        2847 => 'ta',       #  ORIYA LETTER TTA
        2848 => 'tta',      #  ORIYA LETTER TTHA
        2849 => 'da',       #  ORIYA LETTER DDA
        2850 => 'dda',      #  ORIYA LETTER DDHA
        2851 => 'na',       #  ORIYA LETTER NNA
        2852 => 'tha',      #  ORIYA LETTER TA
        2853 => 'thha',     #  ORIYA LETTER THA
        2854 => 'dha',      #  ORIYA LETTER DA
        2855 => 'dhha',     #  ORIYA LETTER DHA
        2856 => 'na',       #  ORIYA LETTER NA
        2858 => 'pa',       #  ORIYA LETTER PA
        2859 => 'pha',      #  ORIYA LETTER PHA
        2860 => 'ba',       #  ORIYA LETTER BA
        2861 => 'bha',      #  ORIYA LETTER BHA
        2862 => 'ma',       #  ORIYA LETTER MA
        2863 => 'ya',       #  ORIYA LETTER YA
        2864 => 'ra',       #  ORIYA LETTER RA
        2866 => 'la',       #  ORIYA LETTER LA
        2867 => 'lla',      #  ORIYA LETTER LLA
        2869 => 'va',       #  ORIYA LETTER VA
        2870 => 'sha',      #  ORIYA LETTER SHA
        2871 => 'sha',      #  ORIYA LETTER SSA
        2872 => 'sa',       #  ORIYA LETTER SA
        2873 => 'ha',       #  ORIYA LETTER HA
#        2876 => '',         #  ORIYA SIGN NUKTA
#        2877 => '',         #  ORIYA SIGN AVAGRAHA
        2878 => '-aa',       #  ORIYA VOWEL SIGN AA
        2879 => '-i',        #  ORIYA VOWEL SIGN I
        2880 => '-ii',       #  ORIYA VOWEL SIGN II
        2881 => '-u',        #  ORIYA VOWEL SIGN U
        2882 => '-uu',       #  ORIYA VOWEL SIGN UU
        2883 => '-ru',       #  ORIYA VOWEL SIGN VOCALIC R
        2887 => '-e',        #  ORIYA VOWEL SIGN E
        2888 => '-ai',       #  ORIYA VOWEL SIGN AI
        2891 => '-o',        #  ORIYA VOWEL SIGN O
        2892 => '-au',       #  ORIYA VOWEL SIGN AU
        2893 => '-',        #  ORIYA SIGN VIRAMA
        2902 => '-ai',      #  ORIYA AI LENGTH MARK
        2903 => '-au',      #  ORIYA AU LENGTH MARK
        2908 => 'ru',       #  ORIYA LETTER RRA
        2909 => 'rhu',      #  ORIYA LETTER RHA
        2911 => 'yya',      #  ORIYA LETTER YYA
        2912 => 'ruu',      #  ORIYA LETTER VOCALIC RR
        2913 => 'luu',      #  ORIYA LETTER VOCALIC LL
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
#        2928 => '',         #  ORIYA ISSHAR
#        2929 => '',         #  ORIYA LETTER WA
        2946 => 'n',        #  TAMIL SIGN ANUSVARA
        2947 => 'aha',      #  TAMIL SIGN VISARGA
        2949 => 'a',        #  TAMIL LETTER A
        2950 => 'aa',       #  TAMIL LETTER AA
        2951 => 'i',        #  TAMIL LETTER I
        2952 => 'ii',       #  TAMIL LETTER II
        2953 => 'u',        #  TAMIL LETTER U
        2954 => 'uu',       #  TAMIL LETTER UU
        2958 => 'e',        #  TAMIL LETTER E
        2959 => 'ee',       #  TAMIL LETTER EE
        2960 => 'ai',       #  TAMIL LETTER AI
        2962 => 'o',        #  TAMIL LETTER O
        2963 => 'oo',       #  TAMIL LETTER OO
        2964 => 'au',       #  TAMIL LETTER AU
        2965 => 'ka',       #  TAMIL LETTER KA
        2969 => 'nga',      #  TAMIL LETTER NGA
        2970 => 'cha',      #  TAMIL LETTER CA
        2972 => 'ja',       #  TAMIL LETTER JA
        2974 => 'nya',      #  TAMIL LETTER NYA
        2975 => 'ta',       #  TAMIL LETTER TTA
        2979 => 'na',       #  TAMIL LETTER NNA
        2980 => 'tha',      #  TAMIL LETTER TA
        2984 => 'na',       #  TAMIL LETTER NA
        2985 => 'na',       #  TAMIL LETTER NNNA
        2986 => 'pa',       #  TAMIL LETTER PA
        2990 => 'ma',       #  TAMIL LETTER MA
        2991 => 'ya',       #  TAMIL LETTER YA
        2992 => 'ra',       #  TAMIL LETTER RA
        2993 => 'rra',      #  TAMIL LETTER RRA
        2994 => 'la',       #  TAMIL LETTER LA
        2995 => 'lla',      #  TAMIL LETTER LLA
        2996 => 'llla',     #  TAMIL LETTER LLLA
        2997 => 'va',       #  TAMIL LETTER VA
        2998 => 'sha',      #  TAMIL LETTER SHA
        2999 => 'sha',      #  TAMIL LETTER SSA
        3000 => 'sa',       #  TAMIL LETTER SA
        3001 => 'ha',       #  TAMIL LETTER HA
        3006 => '-aa',       #  TAMIL VOWEL SIGN AA
        3007 => '-i',        #  TAMIL VOWEL SIGN I
        3008 => '-ii',       #  TAMIL VOWEL SIGN II
        3009 => '-u',        #  TAMIL VOWEL SIGN U
        3010 => '-uu',       #  TAMIL VOWEL SIGN UU
        3014 => '-e',        #  TAMIL VOWEL SIGN E
        3015 => '-ee',       #  TAMIL VOWEL SIGN EE
        3016 => '-ai',       #  TAMIL VOWEL SIGN AI
        3018 => '-o',        #  TAMIL VOWEL SIGN O
        3019 => '-oo',       #  TAMIL VOWEL SIGN OO
        3020 => '-au',       #  TAMIL VOWEL SIGN AU
        3021 => '-',        #  TAMIL SIGN VIRAMA
        3031 => '-au',      #  TAMIL AU LENGTH MARK
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
        3056 => '10',       #  TAMIL NUMBER TEN
        3057 => '100',      #  TAMIL NUMBER ONE HUNDRED
        3058 => '1000',     #  TAMIL NUMBER ONE THOUSAND
#        3059 => '',         #  TAMIL DAY SIGN
#        3060 => '',         #  TAMIL MONTH SIGN
#        3061 => '',         #  TAMIL YEAR SIGN
#        3062 => '',         #  TAMIL DEBIT SIGN
#        3063 => '',         #  TAMIL CREDIT SIGN
#        3064 => '',         #  TAMIL AS ABOVE SIGN
#        3065 => '',         #  TAMIL RUPEE SIGN
#        3066 => '',         #  TAMIL NUMBER SIGN
        3073 => 'n',        #  TELUGU SIGN CANDRABINDU
        3074 => 'n',        #  TELUGU SIGN ANUSVARA
        3075 => 'aha',      #  TELUGU SIGN VISARGA
        3077 => 'a',        #  TELUGU LETTER A
        3078 => 'aa',       #  TELUGU LETTER AA
        3079 => 'i',        #  TELUGU LETTER I
        3080 => 'ii',       #  TELUGU LETTER II
        3081 => 'u',        #  TELUGU LETTER U
        3082 => 'uu',       #  TELUGU LETTER UU
        3083 => 'ru',       #  TELUGU LETTER VOCALIC R
        3084 => 'lu',       #  TELUGU LETTER VOCALIC L
        3086 => 'e',        #  TELUGU LETTER E
        3087 => 'ee',       #  TELUGU LETTER EE
        3088 => 'ai',       #  TELUGU LETTER AI
        3090 => 'o',        #  TELUGU LETTER O
        3091 => 'oo',       #  TELUGU LETTER OO
        3092 => 'au',       #  TELUGU LETTER AU
        3093 => 'ka',       #  TELUGU LETTER KA
        3094 => 'kha',      #  TELUGU LETTER KHA
        3095 => 'ga',       #  TELUGU LETTER GA
        3096 => 'gha',      #  TELUGU LETTER GHA
        3097 => 'nga',      #  TELUGU LETTER NGA
        3098 => 'cha',      #  TELUGU LETTER CA
        3099 => 'chha',     #  TELUGU LETTER CHA
        3100 => 'ja',       #  TELUGU LETTER JA
        3101 => 'jha',      #  TELUGU LETTER JHA
        3102 => 'nya',      #  TELUGU LETTER NYA
        3103 => 'ta',       #  TELUGU LETTER TTA
        3104 => 'tta',      #  TELUGU LETTER TTHA
        3105 => 'da',       #  TELUGU LETTER DDA
        3106 => 'dda',      #  TELUGU LETTER DDHA
        3107 => 'na',       #  TELUGU LETTER NNA
        3108 => 'tha',      #  TELUGU LETTER TA
        3109 => 'thha',     #  TELUGU LETTER THA
        3110 => 'dha',      #  TELUGU LETTER DA
        3111 => 'dhha',     #  TELUGU LETTER DHA
        3112 => 'na',       #  TELUGU LETTER NA
        3114 => 'pa',       #  TELUGU LETTER PA
        3115 => 'pha',      #  TELUGU LETTER PHA
        3116 => 'ba',       #  TELUGU LETTER BA
        3117 => 'bha',      #  TELUGU LETTER BHA
        3118 => 'ma',       #  TELUGU LETTER MA
        3119 => 'ya',       #  TELUGU LETTER YA
        3120 => 'ra',       #  TELUGU LETTER RA
        3121 => 'rra',      #  TELUGU LETTER RRA
        3122 => 'la',       #  TELUGU LETTER LA
        3123 => 'lla',      #  TELUGU LETTER LLA
        3125 => 'va',       #  TELUGU LETTER VA
        3126 => 'sha',      #  TELUGU LETTER SHA
        3127 => 'sha',      #  TELUGU LETTER SSA
        3128 => 'sa',       #  TELUGU LETTER SA
        3129 => 'ha',       #  TELUGU LETTER HA
        3134 => '-aa',       #  TELUGU VOWEL SIGN AA
        3135 => '-i',        #  TELUGU VOWEL SIGN I
        3136 => '-ii',       #  TELUGU VOWEL SIGN II
        3137 => '-u',        #  TELUGU VOWEL SIGN U
        3138 => '-uu',       #  TELUGU VOWEL SIGN UU
        3139 => '-ru',       #  TELUGU VOWEL SIGN VOCALIC R
        3140 => '-ruu',      #  TELUGU VOWEL SIGN VOCALIC RR
        3142 => '-e',        #  TELUGU VOWEL SIGN E
        3143 => '-ee',       #  TELUGU VOWEL SIGN EE
        3144 => '-ai',       #  TELUGU VOWEL SIGN AI
        3146 => '-o',        #  TELUGU VOWEL SIGN O
        3147 => '-oo',       #  TELUGU VOWEL SIGN OO
        3148 => '-au',       #  TELUGU VOWEL SIGN AU
        3149 => '-',        #  TELUGU SIGN VIRAMA
        3157 => '-aa',       #  TELUGU LENGTH MARK
        3158 => '-ai',      #  TELUGU AI LENGTH MARK
        3168 => 'ruu',      #  TELUGU LETTER VOCALIC RR
        3169 => 'luu',      #  TELUGU LETTER VOCALIC LL
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
        3202 => 'n',        #  KANNADA SIGN ANUSVARA
        3203 => 'aha',      #  KANNADA SIGN VISARGA
        3205 => 'a',        #  KANNADA LETTER A
        3206 => 'aa',       #  KANNADA LETTER AA
        3207 => 'i',        #  KANNADA LETTER I
        3208 => 'ii',       #  KANNADA LETTER II
        3209 => 'u',        #  KANNADA LETTER U
        3210 => 'uu',       #  KANNADA LETTER UU
        3211 => 'ru',       #  KANNADA LETTER VOCALIC R
        3212 => 'lu',       #  KANNADA LETTER VOCALIC L
        3214 => 'e',        #  KANNADA LETTER E
        3215 => 'ee',       #  KANNADA LETTER EE
        3216 => 'ai',       #  KANNADA LETTER AI
        3218 => 'o',        #  KANNADA LETTER O
        3219 => 'oo',       #  KANNADA LETTER OO
        3220 => 'au',       #  KANNADA LETTER AU
        3221 => 'ka',       #  KANNADA LETTER KA
        3222 => 'kha',      #  KANNADA LETTER KHA
        3223 => 'ga',       #  KANNADA LETTER GA
        3224 => 'gha',      #  KANNADA LETTER GHA
        3225 => 'nga',      #  KANNADA LETTER NGA
        3226 => 'cha',      #  KANNADA LETTER CA
        3227 => 'chha',     #  KANNADA LETTER CHA
        3228 => 'ja',       #  KANNADA LETTER JA
        3229 => 'jha',      #  KANNADA LETTER JHA
        3230 => 'nya',      #  KANNADA LETTER NYA
        3231 => 'ta',       #  KANNADA LETTER TTA
        3232 => 'tta',      #  KANNADA LETTER TTHA
        3233 => 'da',       #  KANNADA LETTER DDA
        3234 => 'dda',      #  KANNADA LETTER DDHA
        3235 => 'na',       #  KANNADA LETTER NNA
        3236 => 'tha',      #  KANNADA LETTER TA
        3237 => 'thha',     #  KANNADA LETTER THA
        3238 => 'dha',      #  KANNADA LETTER DA
        3239 => 'dhha',     #  KANNADA LETTER DHA
        3240 => 'na',       #  KANNADA LETTER NA
        3242 => 'pa',       #  KANNADA LETTER PA
        3243 => 'pha',      #  KANNADA LETTER PHA
        3244 => 'ba',       #  KANNADA LETTER BA
        3245 => 'bha',      #  KANNADA LETTER BHA
        3246 => 'ma',       #  KANNADA LETTER MA
        3247 => 'ya',       #  KANNADA LETTER YA
        3248 => 'ra',       #  KANNADA LETTER RA
        3249 => 'rra',      #  KANNADA LETTER RRA
        3250 => 'la',       #  KANNADA LETTER LA
        3251 => 'lla',      #  KANNADA LETTER LLA
        3253 => 'va',       #  KANNADA LETTER VA
        3254 => 'sha',      #  KANNADA LETTER SHA
        3255 => 'sha',      #  KANNADA LETTER SSA
        3256 => 'sa',       #  KANNADA LETTER SA
        3257 => 'ha',       #  KANNADA LETTER HA
#        3260 => '',         #  KANNADA SIGN NUKTA
#        3261 => '',         #  KANNADA SIGN AVAGRAHA
        3262 => '-aa',       #  KANNADA VOWEL SIGN AA
        3263 => '-i',        #  KANNADA VOWEL SIGN I
        3264 => '-ii',       #  KANNADA VOWEL SIGN II
        3265 => '-u',        #  KANNADA VOWEL SIGN U
        3266 => '-uu',       #  KANNADA VOWEL SIGN UU
        3267 => '-ru',       #  KANNADA VOWEL SIGN VOCALIC R
        3268 => '-ruu',      #  KANNADA VOWEL SIGN VOCALIC RR
        3270 => '-e',        #  KANNADA VOWEL SIGN E
        3271 => '-ee',       #  KANNADA VOWEL SIGN EE
        3272 => '-ai',       #  KANNADA VOWEL SIGN AI
        3274 => '-o',        #  KANNADA VOWEL SIGN O
        3275 => '-oo',       #  KANNADA VOWEL SIGN OO
        3276 => '-au',       #  KANNADA VOWEL SIGN AU
        3277 => '-',        #  KANNADA SIGN VIRAMA
        3285 => '-aa',       #  KANNADA LENGTH MARK
        3286 => '-ai',      #  KANNADA AI LENGTH MARK
        3294 => 'fa',       #  KANNADA LETTER FA
        3296 => 'ruu',      #  KANNADA LETTER VOCALIC RR
        3297 => 'luu',      #  KANNADA LETTER VOCALIC LL
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
        3330 => 'n',        #  MALAYALAM SIGN ANUSVARA
        3331 => 'aha',      #  MALAYALAM SIGN VISARGA
        3333 => 'a',        #  MALAYALAM LETTER A
        3334 => 'aa',       #  MALAYALAM LETTER AA
        3335 => 'i',        #  MALAYALAM LETTER I
        3336 => 'ii',       #  MALAYALAM LETTER II
        3337 => 'u',        #  MALAYALAM LETTER U
        3338 => 'uu',       #  MALAYALAM LETTER UU
        3339 => 'ru',       #  MALAYALAM LETTER VOCALIC R
        3340 => 'lu',       #  MALAYALAM LETTER VOCALIC L
        3342 => 'e',        #  MALAYALAM LETTER E
        3343 => 'ee',       #  MALAYALAM LETTER EE
        3344 => 'ai',       #  MALAYALAM LETTER AI
        3346 => 'o',        #  MALAYALAM LETTER O
        3347 => 'oo',       #  MALAYALAM LETTER OO
        3348 => 'au',       #  MALAYALAM LETTER AU
        3349 => 'ka',       #  MALAYALAM LETTER KA
        3350 => 'kha',      #  MALAYALAM LETTER KHA
        3351 => 'ga',       #  MALAYALAM LETTER GA
        3352 => 'gha',      #  MALAYALAM LETTER GHA
        3353 => 'nga',      #  MALAYALAM LETTER NGA
        3354 => 'cha',      #  MALAYALAM LETTER CA
        3355 => 'chha',     #  MALAYALAM LETTER CHA
        3356 => 'ja',       #  MALAYALAM LETTER JA
        3357 => 'jha',      #  MALAYALAM LETTER JHA
        3358 => 'nya',      #  MALAYALAM LETTER NYA
        3359 => 'ta',       #  MALAYALAM LETTER TTA
        3360 => 'tta',      #  MALAYALAM LETTER TTHA
        3361 => 'da',       #  MALAYALAM LETTER DDA
        3362 => 'dda',      #  MALAYALAM LETTER DDHA
        3363 => 'na',       #  MALAYALAM LETTER NNA
        3364 => 'tha',      #  MALAYALAM LETTER TA
        3365 => 'thha',     #  MALAYALAM LETTER THA
        3366 => 'dha',      #  MALAYALAM LETTER DA
        3367 => 'dhha',     #  MALAYALAM LETTER DHA
        3368 => 'na',       #  MALAYALAM LETTER NA
        3370 => 'pa',       #  MALAYALAM LETTER PA
        3371 => 'pha',      #  MALAYALAM LETTER PHA
        3372 => 'ba',       #  MALAYALAM LETTER BA
        3373 => 'bha',      #  MALAYALAM LETTER BHA
        3374 => 'ma',       #  MALAYALAM LETTER MA
        3375 => 'ya',       #  MALAYALAM LETTER YA
        3376 => 'ra',       #  MALAYALAM LETTER RA
        3377 => 'rra',      #  MALAYALAM LETTER RRA
        3378 => 'la',       #  MALAYALAM LETTER LA
        3379 => 'lla',      #  MALAYALAM LETTER LLA
        3380 => 'llla',     #  MALAYALAM LETTER LLLA
        3381 => 'va',       #  MALAYALAM LETTER VA
        3382 => 'sha',      #  MALAYALAM LETTER SHA
        3383 => 'sha',      #  MALAYALAM LETTER SSA
        3384 => 'sa',       #  MALAYALAM LETTER SA
        3385 => 'ha',       #  MALAYALAM LETTER HA
        3390 => '-aa',       #  MALAYALAM VOWEL SIGN AA
        3391 => '-i',        #  MALAYALAM VOWEL SIGN I
        3392 => '-ii',       #  MALAYALAM VOWEL SIGN II
        3393 => '-u',        #  MALAYALAM VOWEL SIGN U
        3394 => '-uu',       #  MALAYALAM VOWEL SIGN UU
        3395 => '-ru',       #  MALAYALAM VOWEL SIGN VOCALIC R
        3398 => '-e',        #  MALAYALAM VOWEL SIGN E
        3399 => '-ee',       #  MALAYALAM VOWEL SIGN EE
        3400 => '-ai',       #  MALAYALAM VOWEL SIGN AI
        3402 => '-o',        #  MALAYALAM VOWEL SIGN O
        3403 => '-oo',       #  MALAYALAM VOWEL SIGN OO
        3404 => '-au',       #  MALAYALAM VOWEL SIGN AU
        3405 => '-',        #  MALAYALAM SIGN VIRAMA
        3415 => '-au',      #  MALAYALAM AU LENGTH MARK
        3424 => 'ruu',      #  MALAYALAM LETTER VOCALIC RR
        3425 => 'luu',      #  MALAYALAM LETTER VOCALIC LL
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

  my $STOPWORDS_FILE = 'c:/seeii/common/stopwords.txt';
  my %stopwords;
  my $worddbm = 'c:/seeii/common/worddbm';
  my %wordindex;

  $temp1file = "C:/seeii/load/ptempwc" . $queue_num . ".txt";
  $temp2file = "C:/seeii/load/ptempla" . $queue_num . ".txt";
  $temp3file = "C:/seeii/load/ptempli" . $queue_num . ".txt";
  $temp4file = "C:/seeii/load/ptempbl" . $queue_num . ".txt";
  $temp5file = "C:/seeii/load/ptemplr" . $queue_num . ".txt";
  $temp6file = "C:/seeii/load/ptemptd" . $queue_num . ".txt";

  #Building string of special characters...
  build_char_string();

  #Loading stopwords...
  %stopwords = load_stopwords();

  #Building indian keywords array...
  my $indiankeywords_file = 'c:/seeii/common/indiankeywords.txt';
  my @indian_array = ();
  build_indian_array();

  use Fcntl;
  #Tie to wordindex...
  eval {
    tie %wordindex, $db_package, $worddbm, O_RDONLY, 0755 or die "Cannot open $worddbm: $!";
  };
  if ($@){
    print "cannot tie wordindex ,$@ \n";
    exit;
  }

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  $select_parse   = $dbh->prepare_cached("SELECT A.URL_ID, A.ADD_DATE, B.URL, B.QUALIFIED_FOR_LINK FROM PARSE_URL_TAB A, URL_TAB B WHERE A.URL_ID = B.URL_ID AND A.QUEUE_NUM = ? ORDER BY 2 LIMIT 4000");
  $delete_parse   = $dbh->prepare_cached("DELETE FROM PARSE_URL_TAB WHERE URL_ID = ?");
  $update_url     = $dbh->prepare_cached("UPDATE URL_TAB SET LAST_PARSED_DATE = NOW(), QUALIFIED_FOR_LINK = ? WHERE URL_ID = ?");
  $update_url_child = $dbh->prepare_cached("UPDATE URL_TAB SET QUALIFIED_FOR_LINK = ? WHERE URL_ID = ?");
  $select_content = $dbh->prepare_cached("SELECT CONTENT FROM CONTENT_TAB WHERE URL_ID = ?");
  $update_content = $dbh->prepare_cached("UPDATE CONTENT_TAB SET CONTENT = NULL, META_DATA = ?, HEADR1 = ?, HEADR2 = ?, HEADR3 = ?, ALT_DATA = ?, TOTAL_UNIQUE_WORDS = ? WHERE URL_ID = ?");
  $select_word    = $dbh->prepare_cached("SELECT WORD_ID FROM WORD_TAB WHERE WORD = ? AND LANGUAGE = ?");
  $insert_word    = $dbh->prepare_cached("INSERT IGNORE INTO WORD_TAB (WORD, LANGUAGE) VALUES (?, ?)");

  my $premature_end = '';
  my $forced_end = '';
  my $parser_count = 0;
  my $parent_url_status;

  print localtime() . " - Parse URL - $queue_num program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  process_content();

  $dbh->disconnect;

  untie %wordindex;

  print localtime() . " - Parse URL - $queue_num program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  $process_log = " Close - " . localtime() . "   Parser - $queue_num - $parser_count $premature_end $forced_end \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $command = "perl loadparser.pl"; 

  exec "$command"; 

  exit;


sub process_content {

  my @row_parse = ();
  my @row_content = ();
  my ($url_id, $url);
  my $running_count = 0;
  my $start_time = time();

  $global_content = "";

  open(TMPWCFILE, ">>$temp1file") or (die "Cannot write '$temp1file': $!");
  open(TMPLAFILE, ">>$temp2file") or (die "Cannot write '$temp2file': $!");
  open(TMPLIFILE, ">>$temp3file") or (die "Cannot write '$temp3file': $!");
  open(TMPBLFILE, ">>$temp4file") or (die "Cannot write '$temp4file': $!");
  open(TMPLRFILE, ">>$temp5file") or (die "Cannot write '$temp5file': $!");
  open(TMPTDFILE, ">>$temp6file") or (die "Cannot write '$temp6file': $!");

  TMPWCFILE->autoflush(1);
  TMPLAFILE->autoflush(1);
  TMPLIFILE->autoflush(1);
  TMPBLFILE->autoflush(1);
  TMPLRFILE->autoflush(1);
  TMPTDFILE->autoflush(1);


  # select rows from parse_url
  $select_parse->execute($queue_num);
  # for each row from parse_url
  while(@row_parse = $select_parse->fetchrow_array) {
    $success = 1;
    $url_id = $row_parse[0];
    $url = $row_parse[2];
    $parent_url_status = $row_parse[3];
    $ldatawc = "";
    $ldatawla = "";
    $ldatawli = "";
    $ldatabl = "";
    $ldatalr = "";
    $ldatatd = "";

    # select the content
    $select_content->execute($url_id);
    @row_content = $select_content->fetchrow_array;
    $select_content->finish;

    if (@row_content) {
      $global_content = $row_content[0];
      @row_content = ();
      # parse the content
      $return_code = parse_content($url_id, \$global_content, $url);
      if ($return_code == 1) {
        # if the parsing is successful, delete the entry in the parse_url_tab
        $success &&= $delete_parse->execute($url_id);
        ++$parser_count;
        ++$running_count;
        if ($running_count == 1000) {
           $running_count = 0;
           print "     " . localtime() . " - Running Count = $parser_count\n";
        }

        if ($success) {
           print TMPWCFILE $ldatawc;
           print TMPLIFILE $ldatawli;
           print TMPLAFILE $ldatawla;
           print TMPBLFILE $ldatabl;
           print TMPLRFILE $ldatalr;
           print TMPTDFILE $ldatatd;
        }

      } else {
        print "Error parsing URL: $url, URL-ID: $url_id \n";
      }

      $result = ($success ? $dbh->commit : $dbh->rollback);
      unless ($result) { 
        print "Error committing changes to reading URL: $url, URL-ID: $url_id \n";
      }

    }

    if (time() - $start_time > 14400) {
      print "Premature Ending due to the time limit of 4 hours. \n";
      $premature_end = '- Premature End';
      last;
    }

    if (-e $force_end_file) {
      print "Forcely Ending. \n";
      $forced_end = '- Forced End';
      last;
    }

  }
  my $select_count = $select_parse->rows;
  if ($select_count == 0) {
    print "No entries in the PARSE_URL_TAB\n";
  } else {
    print "Total records read = $select_count \n";
    print "Total records parsed = $parser_count \n";
  }
  $select_parse->finish;

  close(TMPWCFILE);
  close(TMPLIFILE);
  close(TMPLAFILE);
  close(TMPBLFILE);
  close(TMPLRFILE);
  close(TMPTDFILE);

  return;

}


sub parse_content {
  my ($url_id, $buffer, $url) = @_;
  my ($word, $word_id);
  my $header1 = "";
  my $header2 = "";
  my $header3 = "";
  my $title_meta = "";
  my $alt = "";
  my $url_content = "";
  my @row_linkrank = ();

  undef %uw;
  undef %aw;
  undef %bw;
  undef %hw1;
  undef %hw2;
  undef %hw3;
  undef %tmw;
  $total_unique_word_count = 0;

  # Many auto-generated HTML files contain (correct) syntax that makes our
  # regexp very slow. So better clean up now:
  ${$buffer} =~ s/\s+>/>/gs;
  ${$buffer} =~ s/<\s+/</gs;

  # remove javascript and style code
  ${$buffer} =~ s/<script.*?\/script>//gis;
  ${$buffer} =~ s/<style.*?\/style>//gis;

  # to search for parts of URLs, e.g. filenames:
  ${$buffer} = ${$buffer} . " " . $url;

  if ($parent_url_status ne 'D') {
     process_qualification ($buffer); 
  }

  process_links($url_id, $buffer, $url);

  record_desc($url_id, $buffer, $url);

  # to rank words in headlines differently:
  $header1 = get_headline_contents($buffer,1);
  $header2 = get_headline_contents($buffer,2);
  $header3 = get_headline_contents($buffer,3);

  # to search for text in title and the follwing meta tags:
  # the reason to use different field title_meta is to keep the numbers in the title and meta tags
  $title_meta = get_tag_contents("title", $buffer);
  $title_meta .= " ".get_meta_content("description", $buffer, $META_WEIGHT);
  $title_meta .= " ".get_meta_content("keywords", $buffer, $META_WEIGHT);

  # to search for images' alt texts:
  $alt = get_alt_texts($buffer);

  normalize($buffer, 1);
  normalize(\$header1, 1);
  normalize(\$header2, 1);
  normalize(\$header3, 1);
  normalize(\$alt, 1);
  normalize(\$title_meta, 1);
#  normalize(\$url_content, 1);

  # Replace numbers by spaces, except in title_meta:
  ${$buffer} =~ s/(\s+\d+\s+)/ /gs;
  $header1   =~ s/(\s+\d+\s+)/ /gs;
  $header2   =~ s/(\s+\d+\s+)/ /gs;
  $header3   =~ s/(\s+\d+\s+)/ /gs;
  $alt       =~ s/(\s+\d+\s+)/ /gs;

  my $bword;
  while (${$buffer} =~ m/(\w+)/g) {
    $bword = $1;
    next if(length($bword) > 100);    # ignore words longer than 100 characters
    $word_id = get_wordid($bword,0);
    if ($word_id) {
      ++$bw{$word_id};
      $uw{$word_id} = 1 if (! $uw{$word_id});
    }
  }

  foreach (split " ", $header1) {
    next if(length($_) > 100);    # ignore words longer than 100 characters
    $word_id = get_wordid($_,0);
    if ($word_id) {
      ++$hw1{$word_id};
      $uw{$word_id} = 1 if (! $uw{$word_id});
    }
  }

  foreach (split " ", $header2) {
    next if(length($_) > 100);    # ignore words longer than 100 characters
    $word_id = get_wordid($_,0);
    if ($word_id) {
      ++$hw2{$word_id};
      $uw{$word_id} = 1 if (! $uw{$word_id});
    }
  }

  foreach (split " ", $header3) {
    next if(length($_) > 100);    # ignore words longer than 100 characters
    $word_id = get_wordid($_,0);
    ++$hw3{$word_id};
    $uw{$word_id} = 1 if (! $uw{$word_id});
  }

  foreach (split " ", $alt) {
    next if(length($_) > 100);    # ignore words longer than 100 characters
    $word_id = get_wordid($_,0);
    if ($word_id) {
      ++$aw{$word_id};
      $uw{$word_id} = 1 if (! $uw{$word_id});
    }
  }

  foreach (split " ", $title_meta) {
    # stop words will not be ignored for title, meta data
    next if(length($_) > 100);    # ignore words longer than 100 characters
    $word_id = get_wordid($_,1);
    if ($word_id) {
      ++$tmw{$word_id};
      $uw{$word_id} = 1 if (! $uw{$word_id});
    }
  }

  foreach (keys %uw) {
    my $word_count = 0;
    my $header_count = 0;
    my $header1_count = 0;
    my $header2_count = 0;
    my $header3_count = 0;
    my $alt_count = 0;
    my $meta_count = 0;
    my $url_count = 0;

    ++$total_unique_word_count;
    $word_count = $bw{$_} if ($bw{$_});
    $header1_count = $hw1{$_} if ($hw1{$_});
    $header2_count = $hw2{$_} if ($hw2{$_});
    $header3_count = $hw3{$_} if ($hw3{$_});
    $header_count  = ($header1_count * 3) + ($header2_count * 2) + $header3_count;
    $alt_count = $aw{$_} if ($aw{$_});
    $meta_count = $tmw{$_} if ($tmw{$_});

    # insert into word_count_rank
    $ldatawc .= $_ . "," . $url_id . "," . $word_count . "," . $meta_count . "," . $header_count . "," . $alt_count . "," . $url_count . "\n";


  }

  # update the url_tab
  $success &&= $update_url->execute($parent_url_status, $url_id);

  # update the content_tab
  $success &&= $update_content->execute($title_meta, $header1, $header2, $header3, $alt, $total_unique_word_count, $url_id);

  # if not in url_linkrank_tab, add entry for this url in the url_linkrank_tab with linkrank = 0
  $ldatalr .= $url_id . "," . $linkrank . "\n";

  return 1;

}


# qualify the url and put status code for url
#  Y = qualified by anchor text and content
#  L = qualified by anchor text
#  C = qualified by content
#  D = domain qualified
#  R = ready for indexing
#  P = pending for qualification status
#  N = not qualified
sub process_qualification {

  my $buffer = shift;

  # the content has to be scanned even if the url was already fully qualified
  # this has to be done because the content could have changed since the last time

  if ((check_for_keywords($buffer)) eq 'y') {
     if ($parent_url_status eq 'L' || 'S') {
	$parent_url_status = 'Y';
     } elsif ($parent_url_status ne 'D') {
	$parent_url_status = 'C';
     }
  } else {
     if ($parent_url_status eq 'Y') {
	$parent_url_status = 'L';
     } elsif ($parent_url_status eq 'S' || 'L') {
	$parent_url_status = 'L';
     } elsif ($parent_url_status ne 'D') {
	$parent_url_status = 'N';
     }
  }
  
  return;

}


sub process_links {
  my ($url_id, $buffer, $url) = @_;
  my $new_url;
  my $linktext;
  my $url_string;
  my $child_url_status;
  my $new_url_status;
  
  # 'parse' HTML for new URLs - Anchors:
  # seeii - in future frames should probably added
  while( ${$buffer} =~ m/<\s*a\s*href\s*=\s*["'](.*?)['"].*?>(.*?)(<\/a>|<a)/gisx ) {
    $url_string = $1;
    $linktext = $2;

    $new_url_id = substr $url_string, 0, -1;
    $child_url_status = substr $url_string,-1;
    if ($child_url_status eq 'X') {
       $child_url_status = ' ';
    }

    $new_url_status = $child_url_status;

    if ($new_url_id && $new_url_id !~ m/\D/) {

      normalize(\$linktext, 1);

      if ($new_url_id != $url_id) {
         if ($parent_url_status eq 'N') {
            if ($child_url_status eq 'N' || ' ') {
               $new_url_status = 'P';
            }
         } else {
            
           # if the anchor has india related words, no matter what the parent status is...
           if ($child_url_status eq 'C' || 'P' || 'N' || ' ' || 'R') {
              if ((check_for_keywords(\$linktext)) eq 'y') {
                 if ($child_url_status eq 'C') {
                    $new_url_status = 'Y';
                 }
                 if ($child_url_status eq 'N' || ' ') {
                    $new_url_status = 'L';
                 }
                 if ($child_url_status eq 'P' || 'R') {
                    $new_url_status = 'S';
                 }
              } else {
                 if ($child_url_status eq 'P') {
                    $new_url_status = 'R';
                 }
              }
           }
         }
      }
      my %linkwords;
      my %linkwordids;

      $ldatabl .= $new_url_id . "," . $url_id . "\n";
      foreach (split " ", $linktext) {
        next if( $linkwords{$_} );
        next if(length($_) > 100);    # ignore words longer than 100 characters
        $word_id = get_wordid($_,0);
        if ($word_id) {
          ++$linkwords{$_};
          ++$linkwordids{$word_id};
        }
      }
      foreach (keys %linkwordids) {
         $ldatawli .= $_ . "," . $new_url_id . "," . $url_id . "\n";
      }

      if ($new_url_status ne $child_url_status) {
         # update the url_tab
         $success &&= $update_url_child->execute($new_url_status,$new_url_id);
      }

    }
  }
}


## check for the indian keywords in the string passed
sub check_for_keywords {
  my $string = shift;

  foreach (@indian_array) {
    if (${$string} =~ m/$_/igs) {
       return 'y';
    }
  }

  return;
} 


## Return an absolute version of the $new_url, which is relative
## to $url.
sub next_url {
  my $base_url = shift;
  my $new_url = shift;
  # a hack by Daniel Quappe to work around some strange bug in the URI module:
  $new_url =~ s/^javascript:/mailto:/igs;
  my $new_uri = URI->new_abs($new_url, $base_url);
  # get rid of "#fragment":
  $new_uri = URI->new($new_uri->scheme.":".$new_uri->opaque);
  # get the right URL even if the link has too many "../":
  my $path = $new_uri->path;
  $path =~ s/\.\.\///g;
  $new_uri->path($path);
  $new_url = $new_uri->as_string;
  return $new_url;
}


# Save a short description for every document to the database. If no 
# meta description tag is available, take the first words from the body.
# Also save the <title> to the database.
sub record_desc {
  my ($url_id, $buffer, $url) = @_;
  my ($desc, $title, $cleanbody);
  my @desc_ary;

  # Save Description or beginning of body:
  $desc = get_meta_content("description", $buffer, 1);

  if( ! $desc || $CONTEXT_SIZE ) {
    $cleanbody = get_cleaned_body($buffer, $url);
  }
  unless ($desc) {
    @desc_ary = split " ", $cleanbody;
    my $to = $DESC_WORDS;
    $to = scalar(@desc_ary)-1 if( $DESC_WORDS >= scalar(@desc_ary) );
    $desc = join " ", @desc_ary[0..$to];
    $desc .= "..." if( $desc !~ m/\.\s*$/ );
  }

  # Save title:
  ($title) = (${$buffer} =~ m/<TITLE>(.*?)<\/TITLE>/is);
  if( (! $title) || $title =~ m/^\s+$/ ) {
    $title = $url;
  }
  if( length($title) > $MAX_TITLE_LENGTH ) {
    $title = substr($title, 0, $MAX_TITLE_LENGTH) . "...";
  }
  normalize(\$title, 0);
  normalize(\$desc, 0);

  # add title, and desc tab
  $ldatatd .= $url_id . "-seeii-" . $title . "-seeii-" . $desc . "\n";

  # Optionally save the document (to show results with context):
  if( $CONTEXT_SIZE ) {
    my $cont = $cleanbody;
    $cont = substr($cont, 0, $CONTEXT_SIZE) if( $CONTEXT_SIZE != -1 );
    # seeii - save content in the content_tab
  }
}


# Return the body without HTML and unnecessary whitespace.
sub get_cleaned_body {
  my $buffer = $_[0];
  my $filename = $_[1];
  my $cleaned = "";
  if( isHTML($filename) ) {
    ($cleaned) = (${$buffer} =~ m/<BODY.*?>(.*)<\/BODY>/is);
    $cleaned = ${$buffer} if( ! $cleaned );    # broken HTML files maybe don't have a <body>
  } else {
    # non HTML files don't have a "body" (e.g. PDF)
    $cleaned = ${$buffer};
  }
# $cleaned =~ s/$IGNORE_TEXT_START.*?$IGNORE_TEXT_END//gis;  # strip user defined parts
  ##### old comment - comment out the following line if you want to index Arabic (and other non-Latin1 charstets?):
  normalize(\$cleaned, 0);
  return $cleaned;
}

# Get the content part for a certain meta tag. Weight with
# a certain factor by just repeating the result that often.
sub get_meta_content {
  my $name = $_[0];
  my $buffer = $_[1];
  my ($content) = (${$buffer} =~ m/<META\s+name\s*=\s*[\"\']?$name[\"\']?\s+content=[\"\'](.*?)[\"\'][\/\s]*>/is);
  # replace the meta contents with spaces
  ${$buffer} =~ s/<META\s+name\s*=\s*[\"\']?$name[\"\']?\s+content=[\"\'](.*?)[\"\'][\/\s]*>//is;
  return "" if( ! $content || $content =~ m/^\s+$/ );
  return $content;  
}

# Get all values for alt="..."
sub get_alt_texts {
  my $buffer = $_[0];
  my $alt_texts = "";
  while( ${$buffer} =~ m/alt\s*=\s*[\"\'](.*?)[\"\']/gis ) { 
    $alt_texts .= " ".$1;
    # replace the alt text with spaces
    ${$buffer} =~ s/alt\s*=\s*[\"\'](.*?)[\"\']//gis;
  }
  return $alt_texts;
}

# Get the contents of a certain tag
sub get_tag_contents {
  my $tag = $_[0];
  my $buffer = $_[1];
  my $tag_content = "";
  while( ${$buffer} =~ m/<$tag.*?>(.*?)<\/$tag>/igs ) {
    $tag_content .= " ".$1;
    # replace the tag contents with spaces
    ${$buffer} =~ s/<$tag.*?>(.*?)<\/$tag>//igs;
  }
  return $tag_content;
}

# Get the contents of all headline levels
sub get_headline_contents {
  my $buffer = $_[0];
  my $level = $_[1];
  my $headlines = "";
  for( $level = 1; $level <= 3; $level++ ) {
    while( ${$buffer} =~ m/<h$level.*?>(.*?)<\/h$level>/igs ) {
      $headlines .= " ".$1;
      # replace the headline with spaces
      ${$buffer} =~ s/<h$level.*?>(.*?)<\/h$level>//igs;
    }
  }
  return $headlines;
}

# Get the wordid from the words hash. 
# If it does not exist, add it to the word_tab and return the ID.
sub get_wordid {
  my $in_word = $_[0];
  my $in_trans = $_[1];
  my $word_id = "";
  my $word = "";
  my $language = 0;

  $word = substr $in_word, 0, -1;
  $language = substr $in_word,-1;
  if ($language !~ m/\d/) {
     $word = $in_word;
     $language = 0;
  }

  if ($in_trans == 0) {
    return if(($language == 0) && ($stopwords{$word}));    # ignore stopwords
  }

  $word_id = $wordindex{$in_word};  

  # if the word is not present in the words hash
  if (! $word_id) {
#    my $sound_ex = Metaphone($word);
    $success &&= $insert_word->execute($word, $language);
    $select_word->execute($word, $language);
    $word_id = $select_word->fetchrow_array;
    $select_word->finish;
  }

  return $word_id;

}


# Replace umlauts etc by ASCII characters, remove HTML, 
# remove remaining special charcaters. In the end, we only have [a-zA-Z0-9_$#;].
# Then it is converted to lowercase and returned.
sub normalize {
  my $buffer = $_[0];
  my $tran_ind = $_[1];

  removeHTML($buffer);
  ${$buffer} = normalize_special_chars($buffer, $tran_ind);
}


# Remove HTML from a string.
sub removeHTML {
  my $str = $_[0];
  ${$str} =~ s/<!--.*?-->//igs;
  ${$str} =~ s/-/ /g;  # replace hyphen with space
  ${$str} =~ s/<.*?>//igs;
  ${$str} =~ s/[<>]//igs;    # these may be left
  ${$str} =~ s/&nbsp;/ /igs;
  ${$str} =~ s/&quot;/"/igs;
  ${$str} =~ s/&apos;/'/igs;
  ${$str} =~ s/&gt;/>/igs;
  ${$str} =~ s/&lt;/</igs;
  ${$str} =~ s/&copy;/(c)/igs;
  ${$str} =~ s/&trade;/(tm)/igs;
  ${$str} =~ s/&#8220;/"/igs;
  ${$str} =~ s/&#8221;/"/igs;
  ${$str} =~ s/&#8211;/-/igs;
  ${$str} =~ s/&#8217;/'/igs;
  ${$str} =~ s/&#38;/&/igs;
  ${$str} =~ s/&#169;/(c)/igs;
  ${$str} =~ s/&#8482;/(tm)/igs;
  ${$str} =~ s/&#151;/--/igs;
  ${$str} =~ s/&#147;/"/igs;
  ${$str} =~ s/&#148;/"/igs;
  ${$str} =~ s/&#149;/*/igs;
  ${$str} =~ s/&reg;/(R)/igs;
  ${$str} =~ s/&amp;/&/igs;
  ${$str} =~ s/\s+/ /gis;      # strip too much whitespace
  ${$str} =~ tr/\n\r/ /s;

  return;
}

# Represent all special characters as HTML entities like &<entitiy>;
sub normalize_special_chars {
  my $buffer = $_[0];
  my $trans_ind = $_[1];
  my $out_buffer = "";

  # There may be special characters that are not encoded, so encode them:
  # resolve this error later
#  ${$buffer} =~ s/([$special_chars])/"&#".ord($1).";"/gse;

  # Special characters can be encoded using hex values:
  # some could be 3 byte long,
  ${$buffer} =~ s/&#x([\dA-F]{3});/"&#".hex("0x".$1).";"/igse;
  # and some could be 4 byte long,
  ${$buffer} =~ s/&#x([\dA-F]{4});/"&#".hex("0x".$1).";"/igse;

  # change the common european special characters
  ${$buffer} =~ s/&#(\d\d\d);/if( $1 >= 192 && $1 <= 255 ) { "&$entities{$1};"; }/gse;
  ${$buffer} =~ s/&#0(\d\d\d);/if( $1 >= 192 && $1 <= 255 ) { "&$entities{$1};"; }/gse;
  remove_accents($buffer);

  # Space out special characters that are not indian (use the if() to avoid warnings):
#  ${$buffer} =~ s/&#(\d\d\d\d);/if( $1 < 2304 || $1 > 3583 ) { " "; }/gse;

  # do not tranlate when storing title, desc, and content
  if ($trans_ind == 1) {

    ${$buffer} =~ s/'//g;  # remove apostrophe
    ${$buffer} = lc ${$buffer};
    ${$buffer} =~ tr/a-z0-9_&#;/ /cs;

    foreach (split " ", ${$buffer}) {
      my $inword = $_;
      my $transword = "";
      my $lang = 0;
      my $trans_lang = 0;
      my $outword = "";
      my $badword = "n";
      if ($inword =~ m/[&#;]/) {
        if ($inword =~ m/[a-z]/) {
           # word has both unicode and english.. so ignore it
           next;
        }
        while ($inword =~ /&#(.*?);/gs) {
           if ($1 >= 2304 && $1 <= 2431) {
              $lang = 1;		# hindi
           } elsif ($1 >= 2432 && $1 <= 2559) {
              $lang = 7;		# bengali
           } elsif ($1 >= 2560 && $1 <= 2687) {
              $lang = 9;		# punjabi
           } elsif ($1 >= 2688 && $1 <= 2815) {
              $lang = 6;		# gujarati
           } elsif ($1 >= 2816 && $1 <= 2943) {
              $lang = 8;		# oriya
           } elsif ($1 >= 2944 && $1 <= 3071) {
              $lang = 3;		# tamil
           } elsif ($1 >= 3072 && $1 <= 3199) {
              $lang = 2;		# telugu
           } elsif ($1 >= 3200 && $1 <= 3327) {
              $lang = 4;		# kannada
           } elsif ($1 >= 3328 && $1 <= 3455) {
              $lang = 5;		# malayalam
           } else {
              $bad_word = "y";
              last;
           }

           if ($trans_lang == 0) {
             $trans_lang = $lang;
           }
        }

        if ($bad_word eq "y") {
           next;
        }

        if ($trans_lang == 0) {
           next;
        }

        if ($lang != $trans_lang) {
           next;
        }

        $transword = $inword;
        $transword =~ s/&#(.*?);/$indian_chars{$1}/igse;
        $transword =~ s/a-//igse;
        $transword =~ s/-//igse;

        $ldatawla .= $transword . "," . $inword . "," . $trans_lang . "\n";

      } else {
        # word is purely english
        $transword = $inword;
      }
      $outword = $transword . $lang;
      $out_buffer .= " " . $outword;
    }

  } else {
    $out_buffer = ${$buffer};
  }

  return $out_buffer;
}

# Represent all special characters as the character they are based on.
sub remove_accents {
  my $buffer = $_[0];
  # Special cases:
  ${$buffer} =~ s/&thorn;/th/igs;
  ${$buffer} =~ s/&eth;/d/igs;
  ${$buffer} =~ s/&szlig;/ss/igs;
  # Now represent special characters as the characters they are based on:
  ${$buffer} =~ s/&(..?)(grave|acute|circ|tilde|uml|ring|cedil|slash|lig);/$1/igs;
  return;
}

# For development only: check memory usage during indexing.
sub memory_usage {
  my $pid = $$;
  my $str = `top -b -n 0 -p $pid`;
  my ($line) = ($str =~ m/^(.*?grepinbot\.*?)$/igm);
  $line =~ s/^\s+//;
  my @line = split(/\s+/, $line);
  print "mem: $line[4]\n";
}

sub isHTML {
  my $url = shift;
  my $ext = get_suffix($url);
  if( $ext ) {
    eval {
      return grep(/^$ext$/i, @EXT);
    };
    if ($@) {
      return 0;
    } 
  } else {
    return 0;
  }
}

sub get_suffix {
  my $url = shift;
  ($suffix) = ($url =~ m/\.([^.]*)$/);
  return $suffix;
}


# Load the user's list of (common) words that should not be indexed.
# Use a hash so lookup is faster. Well-chosen stopwords can make 
# indexing faster.
sub load_stopwords {
  my %stopwords;
  open(FILE, $STOPWORDS_FILE) or (die "Cannot open '$STOPWORDS_FILE': $!" and return);
  while (<FILE>) {
    chomp;
    $_ =~ s/\r//g; # get rid of carriage returns
    $stopwords{$_} = 1;
  }
  close(FILE);
  return %stopwords;
}

# Build list of special characters that will be replaced in normalize(),
# put this list in global variable $special_chars.
sub build_char_string {
  foreach my $number (keys %entities) {
    $special_chars .= chr($number);
  }
}


sub build_indian_array {
  open(FILE, $indiankeywords_file) or (die "Cannot open '$indiankeywords_file': $!" and return);
  while (<FILE>) {
    chomp;
    $_ =~ s/\r//g; # get rid of carriage returns
    push @indian_array, $_;
  }
  close(FILE);
  return;
}


1;