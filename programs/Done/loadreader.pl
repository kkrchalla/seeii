#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  foreach my $process (0..29) {
    my $process_file = "c:/seeii/process/reader" . $process;
    if (-e $process_file) {
       exit;
    }
  }

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   LoadReader \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $process_file = "c:/seeii/process/loadreader";
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

  open(STDOUT, ">>c:/seeii/log/loadreader.log") or die "Cannot open LOGFILE for WRITING: $!";
  open(STDERR, ">&STDOUT") or die "Cannot open LOGFILE for WRITING: $!";

  use Fcntl;
  use DBI;
#  use Text::Metaphone qw(Metaphone);

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

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

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;

  my $rlcfile = "C:/seeii/load/rtempl.txt";
  my $rrcfile = "C:/seeii/load/rtempr.txt";
  my $rdcfile = "C:/seeii/load/rtempd.txt";
  my $rucfile = "C:/seeii/load/rtempu.txt";
  my $rpcfile = "C:/seeii/load/rtempp.txt";
  my $rwcfile = "C:/seeii/load/rtempw.txt";

  my $load_url_list = $dbh->prepare("LOAD DATA INFILE '$rlcfile' IGNORE INTO TABLE URL_LIST_TAB (URL)");
  my $load_url_reject = $dbh->prepare("LOAD DATA INFILE '$rrcfile' IGNORE INTO TABLE URL_REJECTED_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (URL, REJECTED_REASON)");
  my $load_url_duplicate = $dbh->prepare("LOAD DATA INFILE '$rdcfile' IGNORE INTO TABLE URL_DUPLICATE_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (URL_ID_1, URL_ID_2)");
  my $load_url_unaccessable = $dbh->prepare("LOAD DATA INFILE '$rucfile' REPLACE INTO TABLE UNACCESSABLE_URL_TAB (URL)");
  my $load_parse_url = $dbh->prepare("LOAD DATA INFILE '$rpcfile' IGNORE INTO TABLE PARSE_URL_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (URL_ID, QUEUE_NUM)");
  my $load_word = $dbh->prepare("LOAD DATA INFILE '$rwcfile' IGNORE INTO TABLE WORD_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' (WORD, LANGUAGE)");
  my $analyze_tables = $dbh->prepare("ANALYZE TABLE URL_LIST_TAB, URL_REJECTED_TAB, URL_DUPLICATE_TAB, UNACCESSABLE_URL_TAB, PARSE_URL_TAB, WORD_TAB");

  my $wordfile = 'c:/seeii/load/words.txt';
  my %wordindex;

  undef %wordindex;

  print localtime() . " - Load Reader program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  load_words();

  consolidate();

  load_files();

  load_words_dbm();

  $dbh->disconnect;

  print localtime() . " - Load Reader program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  $process_log = " Close - " . localtime() . "   LoadReader \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $command = "perl parsersubmit.pl"; 

  exec "$command"; 

exit;

sub consolidate {

  open(RLCFILE, ">>$rlcfile") or (die "Cannot open '$rlcfile': $!" and return);
  open(RRCFILE, ">>$rrcfile") or (die "Cannot open '$rrcfile': $!" and return);
  open(RDCFILE, ">>$rdcfile") or (die "Cannot open '$rdcfile': $!" and return);
  open(RUCFILE, ">>$rucfile") or (die "Cannot open '$rucfile': $!" and return);
  open(RPCFILE, ">>$rpcfile") or (die "Cannot open '$rpcfile': $!" and return);
  open(RWCFILE, ">>$rwcfile") or (die "Cannot open '$rwcfile': $!" and return);

  foreach my $queue_num (0..29) {
     my $rlfile = "C:/seeii/load/rtempl" . $queue_num . ".txt";
     my $rrfile = "C:/seeii/load/rtempr" . $queue_num . ".txt";
     my $rdfile = "C:/seeii/load/rtempd" . $queue_num . ".txt";
     my $rufile = "C:/seeii/load/rtempu" . $queue_num . ".txt";
     my $rpfile = "C:/seeii/load/rtempp" . $queue_num . ".txt";
     my $rwfile = "C:/seeii/load/rtempw" . $queue_num . ".txt";


     if (-e $rlfile) {
        open(FILE, $rlfile) or (die "Cannot open '$rlfile': $!" and return);
        while (<FILE>) {
           print RLCFILE $_;
        }
        close(FILE);
        unlink $rlfile or warn "Cannot remove '$rlfile: $!'";
     }

     if (-e $rrfile) {
        open(FILE, $rrfile) or (die "Cannot open '$rrfile': $!" and return);
        while (<FILE>) {
           print RRCFILE $_;
        }
        close(FILE);
        unlink $rrfile or warn "Cannot remove '$rrfile: $!'";
     }

     if (-e $rdfile) {
        open(FILE, $rdfile) or (die "Cannot open '$rdfile': $!" and return);
        while (<FILE>) {
           print RDCFILE $_;
        }
        close(FILE);
        unlink $rdfile or warn "Cannot remove '$rdfile: $!'";
     }

     if (-e $rufile) {
        open(FILE, $rufile) or (die "Cannot open '$rufile': $!" and return);
        while (<FILE>) {
           print RUCFILE $_;
        }
        close(FILE);
        unlink $rufile or warn "Cannot remove '$rufile: $!'";
     }

     if (-e $rpfile) {
        open(FILE, $rpfile) or (die "Cannot open '$rpfile': $!" and return);
        while (<FILE>) {
           print RPCFILE $_;
        }
        close(FILE);
        unlink $rpfile or warn "Cannot remove '$rpfile: $!'";
     }

     if (-e $rwfile) {
        open(FILE, $rwfile) or (die "Cannot open '$rwfile': $!" and return);
        while (<FILE>) {
           chomp;
           my @word_row = ();
           $_ =~ s/\r//g; # get rid of carriage returns
           @word_row = split ",", $_;
           my $wordlang = $word_row[0] . $word_row[1];
           if (!$wordindex{$wordlang}) {
#              my $sound_ex = Metaphone($word);
              my $dataw = $word_row[0] . "," . $word_row[1] . "\n";
              print RWCFILE $dataw;
              $wordindex{$wordlang} = 1;
           }
        }
        close(FILE);
        unlink $rwfile or warn "Cannot remove '$rwfile: $!'";
     }

  }

  undef %wordindex;

  close(RLCFILE);
  close(RRCFILE);
  close(RDCFILE);
  close(RUCFILE);
  close(RPCFILE);
  close(RWCFILE);

  return;

}


sub load_files {

  if (-e $rlcfile) {
         $success = 1;
         $success = $load_url_list->execute;
         if ($success) {
           print " Success updating the Url List = $success at " . localtime() . " \n";
           unlink $rlcfile or warn "Cannot remove '$rlcfile: $!'";
         } else {
           print " Error updating the Url List at " . localtime() . "\n";
         }
  } else {
         print " Load Url List not run - $rlcfile does not exist \n";
  }

  if (-e $rrcfile) {
         $success = 1;
         $success = $load_url_reject->execute;
         if ($success) {
           print " Success updating the Url Reject = $success at " . localtime() . "\n";
           unlink $rrcfile or warn "Cannot remove '$rrcfile: $!'";
         } else {
           print " Error updating the Url Reject at " . localtime() . "\n";
         }
  } else {
         print " Load Url Reject not run - $rrcfile does not exist \n";
  }
 
  if (-e $rdcfile) {
         $success = 1;
         $success = $load_url_duplicate->execute;
         if ($success) {
           print " Success updating the Url Duplicate = $success at " . localtime() . " \n";
           unlink $rdcfile or warn "Cannot remove '$rdcfile: $!'";
         } else {
           print " Error updating the Url Duplicate at " . localtime() . "\n";
         }
  } else {
         print " Load Url Duplicate not run - $rdcfile does not exist \n";
  }

  if (-e $rucfile) {
         $success = 1;
         $success = $load_url_unaccessable->execute;
         if ($success) {
           print " Success updating the Url Unaccessable = $success at " . localtime() . " \n";
           unlink $rucfile or warn "Cannot remove '$rucfile: $!'";
         } else {
           print " Error updating the Url Unaccessable at " . localtime() . "\n";
         }
  } else {
         print " Load Url Unaccessable not run - $rucfile does not exist \n";
  }

  if (-e $rpcfile) {
         $success = 1;
         $success = $load_parse_url->execute;
         if ($success) {
           print " Success updating the Parse Url = $success at " . localtime() . " \n";
           unlink $rpcfile or warn "Cannot remove '$rpcfile: $!'";
         } else {
           print " Error updating the Parse Url at " . localtime() . "\n";
         }
  } else {
         print " Load Parse Url not run - $rpcfile does not exist \n";
  }

  if (-e $rwcfile) {
         $success = 1;
         $success = $load_word->execute;
         if ($success) {
           print " Success updating the Word = $success at " . localtime() . " \n";
           unlink $rwcfile or warn "Cannot remove '$rwcfile: $!'";
         } else {
           print " Error updating the Word at " . localtime() . "\n";
         }
  } else {
         print " Load Word not run - $rwcfile does not exist \n";
  }

  $success = 1;
  $success = $analyze_tables->execute;
  $analyze_tables->finish;
  if ($success) {
         print " Success analyzing tables at " . localtime() . " \n";
  } else {
         print " Error analyzing tables at " . localtime() . "\n";
  }

  return;

}


sub load_words {

  use Fcntl;

  if (-e $wordfile) {
     unlink $wordfile or warn "Cannot remove '$wordfile: $!'";
  }

  my $select_word_file = $dbh->prepare_cached("SELECT CONCAT(WORD, LANGUAGE) INTO OUTFILE '$wordfile' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' FROM WORD_TAB");

  $success = $select_word_file->execute();

  open(FILE, $wordfile) or (die "Cannot open '$wordfile': $!" and return);
  while (<FILE>) {
    chomp;
    $_ =~ s/\r//g; # get rid of carriage returns
    $wordindex{$_} = 1;
  }
  close(FILE);

  if (-e $wordfile) {
     unlink $wordfile or warn "Cannot remove '$wordfile: $!'";
  }

  print " Load words completed at " . localtime() . "\n";

  return;

}


sub load_words_dbm {

  use Fcntl;

  my $wordfile = 'c:/seeii/common/words.txt';
  my $worddbm = 'c:/seeii/common/worddbm';

  if (-e $wordfile) {
     unlink $wordfile or warn "Cannot remove '$wordfile: $!'";
  }

  if (-e $worddbm) {
     unlink $worddbm or die "Cannot remove '$worddbm: $!'";
  }

  my $select_word_file = $dbh->prepare_cached("SELECT CONCAT(WORD, LANGUAGE), WORD_ID INTO OUTFILE '$wordfile' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' FROM WORD_TAB");

  $success = $select_word_file->execute();

  tie %wordindex, $db_package, $worddbm, O_CREAT|O_RDWR, 0755 or die "Cannot open $worddbm: $!";

  my @word_row = ();
  open(FILE, $wordfile) or (die "Cannot open '$wordfile': $!" and return);
  while (<FILE>) {
    chomp;
    @word_row = ();
    $_ =~ s/\r//g; # get rid of carriage returns
    @word_row = split ",", $_;
    $wordindex{$word_row[0]} = $word_row[1];
  }
  close(FILE);

  untie %wordindex;

  if (-e $wordfile) {
     unlink $wordfile or warn "Cannot remove '$wordfile: $!'";
  }

  print " Load words to DBM completed at " . localtime() . "\n";

  return;

}

1;