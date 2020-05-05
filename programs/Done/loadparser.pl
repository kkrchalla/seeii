#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  foreach my $process (0..29) {
    my $process_file = "c:/seeii/process/parser" . $process;
    if (-e $process_file) {
       exit;
    }
  }

  my $process_file = "c:/seeii/process/loadparser";
  if (-e $process_file) {
     exit;
  }
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   LoadParser \n";
  print PLFILE $process_log;
  close(PLFILE);

  open(STDOUT, ">>c:/seeii/log/loadparser.log") or die "Cannot open LOGFILE for WRITING: $!";
  open(STDERR, ">&STDOUT") or die "Cannot open LOGFILE for WRITING: $!";

  use Fcntl;
  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  print localtime() . " - Load Parser program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  my $pwccfile = "c:/seeii/load/ptempwc.txt";
  my $placfile = "C:/seeii/load/ptempla.txt";
  my $plicfile = "C:/seeii/load/ptempli.txt";
  my $pblcfile = "C:/seeii/load/ptempbl.txt";
  my $plrcfile = "C:/seeii/load/ptemplr.txt";
  my $ptdcfile = "C:/seeii/load/ptemptd.txt";

  open(PWCCFILE, ">>$pwccfile") or (die "Cannot open '$pwccfile': $!" and return);
  open(PLACFILE, ">>$placfile") or (die "Cannot open '$placfile': $!" and return);
  open(PLICFILE, ">>$plicfile") or (die "Cannot open '$plicfile': $!" and return);
  open(PBLCFILE, ">>$pblcfile") or (die "Cannot open '$pblcfile': $!" and return);
  open(PLRCFILE, ">>$plrcfile") or (die "Cannot open '$plrcfile': $!" and return);
  open(PTDCFILE, ">>$ptdcfile") or (die "Cannot open '$ptdcfile': $!" and return);

  foreach my $queue_num (0..29) {
    consolidate($queue_num);
  }

  close(PWCCFILE);
  close(PLACFILE);
  close(PLICFILE);
  close(PBLCFILE);
  close(PLRCFILE);
  close(PTDCFILE);

  loadfiles();

  $dbh->disconnect;

  print localtime() . " - Load Parser program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  $process_log = " Close - " . localtime() . "   LoadParser \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $command = "perl readersubmit.pl";

#  exec "$command";

  exit;



sub consolidate {

  my $queue_num = shift;

  my $pwcfile = "c:/seeii/load/ptempwc" . $queue_num . ".txt";
  my $plafile = "C:/seeii/load/ptempla" . $queue_num . ".txt";
  my $plifile = "C:/seeii/load/ptempli" . $queue_num . ".txt";
  my $pblfile = "C:/seeii/load/ptempbl" . $queue_num . ".txt";
  my $plrfile = "C:/seeii/load/ptemplr" . $queue_num . ".txt";
  my $ptdfile = "C:/seeii/load/ptemptd" . $queue_num . ".txt";

  if (-e $pwcfile) {
        open(FILE, $pwcfile) or (die "Cannot open '$pwcfile': $!" and return);
        while (<FILE>) {
           print PWCCFILE $_;
        }
        close(FILE);
        unlink $pwcfile or warn "Cannot remove '$pwcfile: $!'";
  }

  if (-e $plafile) {
        open(FILE, $plafile) or (die "Cannot open '$plafile': $!" and return);
        while (<FILE>) {
           print PLACFILE $_;
        }
        close(FILE);
        unlink $plafile or warn "Cannot remove '$plafile: $!'";
  }

  if (-e $plifile) {
        open(FILE, $plifile) or (die "Cannot open '$plifile': $!" and return);
        while (<FILE>) {
           print PLICFILE $_;
        }
        close(FILE);
        unlink $plifile or warn "Cannot remove '$plifile: $!'";
  }

  if (-e $pblfile) {
        open(FILE, $pblfile) or (die "Cannot open '$pblfile': $!" and return);
        while (<FILE>) {
           print PBLCFILE $_;
        }
        close(FILE);
        unlink $pblfile or warn "Cannot remove '$pblfile: $!'";
  }

  if (-e $plrfile) {
        open(FILE, $plrfile) or (die "Cannot open '$plrfile': $!" and return);
        while (<FILE>) {
           print PLRCFILE $_;
        }
        close(FILE);
        unlink $plrfile or warn "Cannot remove '$plrfile: $!'";
  }

  if (-e $ptdfile) {
        open(FILE, $ptdfile) or (die "Cannot open '$ptdfile': $!" and return);
        while (<FILE>) {
           print PTDCFILE $_;
        }
        close(FILE);
        unlink $ptdfile or warn "Cannot remove '$ptdfile: $!'";
  }

  return;

}


sub loadfiles {

  my $load_word_count = $dbh->prepare_cached("LOAD DATA INFILE '$pwccfile' IGNORE INTO TABLE WORD_COUNT_RANK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");
  my $load_word_lang = $dbh->prepare_cached("LOAD DATA INFILE '$placfile' IGNORE INTO TABLE WORD_LANG_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");
  my $load_word_link = $dbh->prepare_cached("LOAD DATA INFILE '$plicfile' IGNORE INTO TABLE WORD_LINK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");
  my $load_url_backlink = $dbh->prepare_cached("LOAD DATA INFILE '$pblcfile' IGNORE INTO TABLE URL_BACKLINK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");
  my $load_url_linkrank = $dbh->prepare_cached("LOAD DATA INFILE '$plrcfile' IGNORE INTO TABLE URL_LINKRANK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");
  my $load_url_titledesc = $dbh->prepare_cached("LOAD DATA INFILE '$ptdcfile' REPLACE INTO TABLE TITLE_DESC_TAB FIELDS TERMINATED BY '-seeii-' LINES TERMINATED BY '\n'");
  my $analyze_tables = $dbh->prepare("ANALYZE TABLE WORD_COUNT_RANK_TAB, WORD_LANG_TAB, WORD_LINK_TAB, URL_BACKLINK_TAB, URL_LINKRANK_TAB, TITLE_DESC_TAB");
#  my $optimize_tables = $dbh->prepare("OPTIMIZE TABLE URL_LIST_TAB, CONTENT_TAB, PARSE_URL_TAB, READ_URL_TAB, URL_BACKLINK_TAB, WORD_COUNT_RANK_TAB, WORD_LINK_TAB, WORD_LINKRANK_TAB");

  my $set_unique_0 = $dbh->prepare("SET UNIQUE_CHECKS = 0");
  my $set_foreign_key_0 = $dbh->prepare("SET FOREIGN_KEY_CHECKS = 0");
  my $set_foreign_key_1 = $dbh->prepare("SET FOREIGN_KEY_CHECKS = 1");
  my $set_unique_1 = $dbh->prepare("SET UNIQUE_CHECKS = 1");
  my $disable_keys = $dbh->prepare("ALTER TABLE WORD_COUNT_RANK_TAB DISABLE KEYS");
  my $enable_keys = $dbh->prepare("ALTER TABLE WORD_COUNT_RANK_TAB ENABLE KEYS");

  $set_foreign_key_0->execute();
  if (-e $placfile) {
         $success = 1;
         $success &&= $load_word_lang->execute;
         if ($success) {
           print " Success updating the Word Langs = $success at " . localtime() . " \n";
           unlink $placfile or warn "Cannot remove '$placfile: $!'";
         } else {
           print " Error updating the Word Langs at " . localtime() . " \n";
         }
  } else {
      print " Load Word Langs not run - $placfile does not exist \n";
  }

  if (-e $plicfile) {
         $success = 1;
         $success &&= $load_word_link->execute;
         if ($success) {
           print " Success updating the Word Links = $success at " . localtime() . " \n";
           unlink $plicfile or warn "Cannot remove '$plicfile: $!'";
         } else {
           print " Error updating the Word Links at " . localtime() . " \n";
         }
  } else {
      print " Load Word Links not run - $plicfile does not exist \n";
  }

  if (-e $pblcfile) {
         $success = 1;
         $success &&= $load_url_backlink->execute;
         if ($success) {
           print " Success updating the Url Back Links = $success at " . localtime() . " \n";
           unlink $pblcfile or warn "Cannot remove '$pblcfile: $!'";
         } else {
           print " Error updating the Url Back Links at " . localtime() . " \n";
         }
  } else {
      print " Load Url Back Links not run - $pblcfile does not exist \n";
  }

  if (-e $plrcfile) {
         $success = 1;
         $success &&= $load_url_linkrank->execute;
         if ($success) {
           print " Success updating the Url Link Ranks = $success at " . localtime() . " \n";
           unlink $plrcfile or warn "Cannot remove '$plrcfile: $!'";
         } else {
           print " Error updating the Url Link Ranks at " . localtime() . " \n";
         }
  } else {
      print " Load Url Link Ranks not run - $plrcfile does not exist \n";
  }

  if (-e $ptdcfile) {
         $success = 1;
         $success &&= $load_url_titledesc->execute;
         if ($success) {
           print " Success updating the Title Descriptions = $success at " . localtime() . " \n";
           unlink $ptdcfile or warn "Cannot remove '$ptdcfile: $!'";
         } else {
           print " Error updating the Title Descriptions at " . localtime() . " \n";
         }
  } else {
      print " Load Title Descriptions not run - $ptdcfile does not exist \n";
  }

 ### Submit readersubmit in parallel to the load word_counts
    eval {
        $pid = fork();
        if ($pid == 0) {
          close STDIN;
          close STDOUT;
          close STDERR;

          my $command = "perl readersubmit.pl"; 

          exec "$command"; 

        } elsif (!defined $pid) {
          print "  Fork failed during Readersubmit from LoadParser";
        }
    };


#  $dbh->{AutoCommit} = 0;
  $set_unique_0->execute();
  $disable_keys->execute();
  if (-e $pwccfile) {
         $success = 1;
         $success = $load_word_count->execute();
         if ($success) {
#           $dbh->commit;
           print " Success updating the Word Counts = $success at " . localtime() . " \n";
           unlink $pwccfile or warn "Cannot remove '$pwccfile: $!'";
         } else {
#           $dbh->rollback;
           print " Error updating the Word Counts at " . localtime() . " \n";
         }
  } else {
      print " Load Word Counts not run - $pwccfile does not exist \n";
  }
  $enable_keys->execute();
  $set_unique_1->execute();
#  $dbh->{AutoCommit} = 1;

  $set_foreign_key_1->execute();

  $success = 1;
  $success = $analyze_tables->execute;
  if ($success) {
         print " Success analyzing tables at " . localtime() . " \n";
  } else {
         print " Error analyzing tables at " . localtime() . "\n";
  }

#  $success = 1;
#  $success = $optimize_tables->execute;
#  if ($success) {
#         print " Success optimizing tables at " . localtime() . " \n";
#  } else {
#         print " Error optimizing tables at " . localtime() . "\n";
#  }

  return;

}

1;