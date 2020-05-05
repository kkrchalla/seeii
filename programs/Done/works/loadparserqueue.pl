#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  my $queue_num =  $ARGV[0];
  my $out_log_file = "c:/seeii/log/loadparser" . $queue_num . ".log";

  open(STDOUT, ">>$out_log_file") or die "Cannot open $out_log_file for WRITING: $!";
  open(STDERR, ">&STDOUT") or die "Cannot open $out_log_file for WRITING: $!";

  my $process_file = "c:/seeii/process/loadparser" . $queue_num;
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   LoadParser - $queue_num \n";
  print PLFILE $process_log;
  close(PLFILE);

  use Fcntl;
  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  print localtime() . " - Load Parser - $queue_num program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  my $pwccfile = "c:/seeii/load/ptempwc" . $queue_num . ".txt";
  my $placfile = "C:/seeii/load/ptempla" . $queue_num . ".txt";
  my $plicfile = "C:/seeii/load/ptempli" . $queue_num . ".txt";
  my $pblcfile = "C:/seeii/load/ptempbl" . $queue_num . ".txt";
  my $plrcfile = "C:/seeii/load/ptemplr" . $queue_num . ".txt";
  my $ptdcfile = "C:/seeii/load/ptemptd" . $queue_num . ".txt";

  loadfiles();

  $dbh->disconnect;

  print localtime() . " - Load Parser - $queue_num program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Close - " . localtime() . "   LoadParser - $queue_num \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $command = "perl lister.pl"; 

#  exec "$command"; 

  exit;

sub loadfiles {
 
  if ($queue_num < 5) {
     loadpwcc();
     loadplac();
     loadplic();
     loadpblc();
     loadplrc();
     loadptdc();
  } elsif ($queue_num < 10) {
     loadplac();
     loadplic();
     loadpblc();
     loadplrc();
     loadptdc();
     loadpwcc();
  } elsif ($queue_num < 15) {
     loadplic();
     loadpblc();
     loadplrc();
     loadptdc();
     loadpwcc();
     loadplac();
  } elsif ($queue_num < 20) {
     loadpblc();
     loadplrc();
     loadptdc();
     loadpwcc();
     loadplac();
     loadplic();
  } elsif ($queue_num < 25) {
     loadplrc();
     loadptdc();
     loadpwcc();
     loadplac();
     loadplic();
     loadpblc();
  } else {
     loadptdc();
     loadpwcc();
     loadplac();
     loadplic();
     loadpblc();
     loadplrc();
  }

  foreach my $process (0..29) {
    if ($process == $queue_num) {
       next;
    }
    my $process_file = "c:/seeii/process/loadparser" . $process;
    if (-e $process_file) {
       return;
    }
  }

  analyze();
  optimize();

}


sub loadplac {

  my $load_word_lang = $dbh->prepare_cached("LOAD DATA INFILE '$placfile' IGNORE INTO TABLE WORD_LANG_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");

  if (-e $placfile) {
         $success = 1;
         $success &&= $load_word_lang->execute;
         if ($success) {
           print " Success updating the Word Langs = $success at " . localtime() . " \n";
#           unlink $placfile or warn "Cannot remove '$placfile: $!'";
         } else {
           print " Error updating the Word Langs at " . localtime() . " \n";
         }
  } else {
      print " Load Word Langs not run - $placfile does not exist \n";
  }

  return;

}


sub loadplic {

  my $load_word_link = $dbh->prepare_cached("LOAD DATA INFILE '$plicfile' IGNORE INTO TABLE WORD_LINK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");

  if (-e $plicfile) {
         $success = 1;
         $success &&= $load_word_link->execute;
         if ($success) {
           print " Success updating the Word Links = $success at " . localtime() . " \n";
#           unlink $plicfile or warn "Cannot remove '$plicfile: $!'";
         } else {
           print " Error updating the Word Links at " . localtime() . " \n";
         }
  } else {
      print " Load Word Links not run - $plicfile does not exist \n";
  }

  return;

}

sub loadpblc {

  my $load_url_backlink = $dbh->prepare_cached("LOAD DATA INFILE '$pblcfile' IGNORE INTO TABLE URL_BACKLINK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");

  if (-e $pblcfile) {
         $success = 1;
         $success &&= $load_url_backlink->execute;
         if ($success) {
           print " Success updating the Url Back Links = $success at " . localtime() . " \n";
#           unlink $pblcfile or warn "Cannot remove '$pblcfile: $!'";
         } else {
           print " Error updating the Url Back Links at " . localtime() . " \n";
         }
  } else {
      print " Load Url Back Links not run - $pblcfile does not exist \n";
  }

  return;

}

sub loadplrc {

  my $load_url_linkrank = $dbh->prepare_cached("LOAD DATA INFILE '$plrcfile' IGNORE INTO TABLE URL_LINKRANK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");

  if (-e $plrcfile) {
         $success = 1;
         $success &&= $load_url_linkrank->execute;
         if ($success) {
           print " Success updating the Url Link Ranks = $success at " . localtime() . " \n";
#           unlink $plrcfile or warn "Cannot remove '$plrcfile: $!'";
         } else {
           print " Error updating the Url Link Ranks at " . localtime() . " \n";
         }
  } else {
      print " Load Url Link Ranks not run - $plrcfile does not exist \n";
  }

  return;

}

sub loadptdc {

  my $load_url_titledesc = $dbh->prepare_cached("LOAD DATA INFILE '$ptdcfile' REPLACE INTO TABLE TITLE_DESC_TAB FIELDS TERMINATED BY '-seeii-' LINES TERMINATED BY '\n'");

  if (-e $ptdcfile) {
         $success = 1;
         $success &&= $load_url_titledesc->execute;
         if ($success) {
           print " Success updating the Title Descriptions = $success at " . localtime() . " \n";
#           unlink $ptdcfile or warn "Cannot remove '$ptdcfile: $!'";
         } else {
           print " Error updating the Title Descriptions at " . localtime() . " \n";
         }
  } else {
      print " Load Title Descriptions not run - $ptdcfile does not exist \n";
  }

  return;

}

sub loadpwcc {

  my $load_word_count = $dbh->prepare_cached("LOAD DATA INFILE '$pwccfile' IGNORE INTO TABLE WORD_COUNT_RANK_TAB FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n'");
  my $set_unique_0 = $dbh->prepare("SET UNIQUE_CHECKS = 0");
  my $set_foreign_key_0 = $dbh->prepare("SET FOREIGN_KEY_CHECKS = 0");
  my $set_foreign_key_1 = $dbh->prepare("SET FOREIGN_KEY_CHECKS = 1");
  my $set_unique_1 = $dbh->prepare("SET UNIQUE_CHECKS = 1");

  if (-e $pwccfile) {
         $success = 1;
         $dbh->{AutoCommit} = 0;
         $set_unique_0->execute();
         $set_foreign_key_0->execute();
         $success = $load_word_count->execute;
         if ($success) {
           $dbh->commit;
           print " Success updating the Word Counts = $success at " . localtime() . " \n";
#           unlink $pwccfile or warn "Cannot remove '$pwccfile: $!'";
         } else {
           $dbh->rollback;
           print " Error updating the Word Counts at " . localtime() . " \n";
         }
         $set_foreign_key_0->execute();
         $set_unique_0->execute();
         $dbh->{AutoCommit} = 1;
  } else {
      print " Load Word Counts not run - $pwccfile does not exist \n";
  }

  return;

}

sub analyze {

  my $analyze_tables = $dbh->prepare("ANALYZE TABLE WORD_COUNT_RANK_TAB, WORD_LANG_TAB, WORD_LINK_TAB, URL_BACKLINK_TAB, URL_LINKRANK_TAB, TITLE_DESC_TAB");

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

sub optimize {

  my $optimize_tables = $dbh->prepare("OPTIMIZE TABLE URL_LIST_TAB, CONTENT_TAB, PARSE_URL_TAB, READ_URL_TAB, URL_BACKLINK_TAB, WORD_COUNT_RANK_TAB, WORD_LINK_TAB, WORD_LINKRANK_TAB");

  $success = 1;
  $success = $optimize_tables->execute;
  if ($success) {
         print " Success optimizing tables at " . localtime() . " \n";
  } else {
         print " Error optimizing tables at " . localtime() . "\n";
  }

  return;

}

1;