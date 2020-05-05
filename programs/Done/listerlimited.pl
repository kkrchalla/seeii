#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

open(STDOUT, ">>c:/seeii/log/listerlimited.log") or die "Cannot open LOGFILE for WRITING: $!";
open(STDERR, ">&STDOUT") or die "Cannot open LOGFILE for WRITING: $!";

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   Listerlimited \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $process_file = "c:/seeii/process/listerlimited";
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

# This program will read the urls from the URL_LIST_TAB.
# Then it will check the accept flag, force flag, and places the url
# accordingly in the READ_URL_TAB, and URL_REJECTED_TAB.

  use DBI;
  use URI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_url_list = $dbh->prepare_cached("SELECT URL, ACCEPT, FORCE_IND, DATE(ADD_DATE) FROM URL_LIST_TAB WHERE ACCEPT IS NOT NULL ORDER BY 4 LIMIT 200000");
  my $select_url     = $dbh->prepare_cached("SELECT URL_ID, LAST_READ_DATE, DATEDIFF(NOW(),LAST_READ_DATE), QUALIFIED_FOR_LINK FROM URL_TAB WHERE URL = ?");
  my $insert_url = $dbh->prepare_cached("INSERT INTO URL_TAB (URL) VALUES (?)");
  my $insert_reject = $dbh->prepare_cached("INSERT IGNORE INTO URL_REJECTED_TAB (URL, REJECTED_REASON) VALUES (?,?)");
  my $insert_read = $dbh->prepare_cached("INSERT INTO READ_URL_TAB (URL_ID, QUEUE_NUM) VALUES (?, ?) ON DUPLICATE KEY UPDATE ADD_DATE = NOW()");
  my $delete_url_list = $dbh->prepare_cached("DELETE FROM URL_LIST_TAB WHERE URL = ?");

  my $lister_processed = 0;

  print localtime() . " - LISTER limited program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  process_list();

  $dbh->disconnect;

  print localtime() . " - LISTER limited program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  $process_log = " Close - " . localtime() . "   Lister limited - $lister_processed \n";
  print PLFILE $process_log;
  close(PLFILE);

  exit;


sub process_list {

  my @row_list = ();
  my @row_url = ();
  my @row_read = ();
  my ($url_id, $url, $accept, $force, $donotprocess, $donotindex);
  my $running_count = 0;
  my $host;

  # select rows from url_list
  $select_url_list->execute();
  # for each row from url_list
  while(@row_list = $select_url_list->fetchrow_array) {
    $success = 1;
    $url = $row_list[0];
    $accept = $row_list[1];
    $force = $row_list[2];
    $donotprocess = 'n';
    $donotindex = 'n';
    $queue_num = 0;
    $skip_ind = 'n';
    $url = lc $url;

    # ignore "empty" links (shouldn't happen):
    if( ! $url || $url eq '' ) {
        $skip_ind = 'y';
    }
    # ignore everything other than http.. links:
    if( $url !~ m/^http/ ) {
        $skip_ind = 'y';
    }
    # keep feed urls for future:
    if( $url =~ m/^feed/ ) {
        $donotindex = 'y';
    }
    # ignore document internal links:
    if( $url =~ m/^#/i ) {
        $skip_ind = 'y';
    }

    my $uri = new URI($url);
    eval {
        $host = $uri->host;
    };
    if ($@) {
        $skip_ind = 'y';
    }

    # if force or accept, add the url to url_tab and read_url
    if ($skip_ind eq 'n') {
      if (($force eq 'Y') || ($accept eq 'Y')) {
      $url_id = add_url($url);
       if ($url_id && ($donotindex eq 'n')) {

        my $queue_char = substr($host,4,1);
        if ($queue_char eq 'a') {
                $queue_num = 1;
        } elsif ($queue_char eq 'b') {
                $queue_num = 2;
        } elsif ($queue_char eq 'c') {
                $queue_num = 3;
        } elsif ($queue_char eq 'd') {
                $queue_num = 4;
        } elsif ($queue_char eq 'e') {
                $queue_num = 5;
        } elsif ($queue_char eq 'f') {
                $queue_num = 6;
        } elsif ($queue_char eq 'g') {
                $queue_num = 7;
        } elsif ($queue_char eq 'h') {
                $queue_num = 8;
        } elsif ($queue_char eq 'i') {
                $queue_num = 9;
        } elsif ($queue_char eq 'j') {
                $queue_num = 10;
        } elsif ($queue_char eq 'k') {
                $queue_num = 11;
        } elsif ($queue_char eq 'l') {
                $queue_num = 12;
        } elsif ($queue_char eq 'm') {
                $queue_num = 13;
        } elsif ($queue_char eq 'n') {
                $queue_num = 14;
        } elsif ($queue_char eq 'o') {
                $queue_num = 15;
        } elsif ($queue_char eq 'p') {
                $queue_num = 16;
        } elsif ($queue_char eq 'q') {
                $queue_num = 17;
        } elsif ($queue_char eq 'r') {
                $queue_num = 18;
        } elsif ($queue_char eq 's') {
                $queue_num = 19;
        } elsif ($queue_char eq 't') {
                $queue_num = 20;
        } elsif ($queue_char eq 'u') {
                $queue_num = 21;
        } elsif ($queue_char eq 'v') {
                $queue_num = 22;
        } elsif ($queue_char eq 'w') {
                $queue_num = 23;
        } elsif ($queue_char eq 'x') {
                $queue_num = 24;
        } elsif ($queue_char eq 'y') {
                $queue_num = 25;
        } elsif ($queue_char eq 'z') {
                $queue_num = 26;
        } elsif ($queue_char eq '1')  {
                $queue_num = 27;
        } elsif (($queue_char eq '2') || ($queue_char eq '3') || ($queue_char eq '4') || ($queue_char eq '5'))  {
                $queue_num = 28;
        } elsif (($queue_char eq '6') || ($queue_char eq '7') || ($queue_char eq '8') || ($queue_char eq '9'))  {
                $queue_num = 29;
        } else {
                $queue_num = 0;
        }

        $success &&= $insert_read->execute($url_id, $queue_num);
        ++$lister_processed;
        ++$running_count;
        if ($running_count == 1000) {
           $running_count = 0;
           print "     " . localtime() . " - Running Count = $lister_processed \n";
        }

       }

      # if reject, add url to reject_tab
     } elsif ($accept eq 'N') {
       add_reject($url, 0);
     } else {
       # else, don't do anything
       $donotprocess = 'y';
     }

    }

    if ($donotprocess eq 'n') {
       $success &&= $delete_url_list->execute($url);
    }

    $result = ($success ? $dbh->commit : $dbh->rollback);
    unless ($result) {
      print "Error committing changes to listing URL: $url \n";
    }

  }
  my $lister_count = $select_url_list->rows;
  if ($lister_count == 0) {
    print "No entries in the URL_LIST_TAB\n\n";
  } else {
    print "Total records read      = $lister_count \n";
    print "Total records processed = $lister_processed \n";
  }
  $select_url_list->finish;

  return;

}


sub add_url {
  my $url = shift;
  my @row_url = ();

  $select_url->execute($url);
  @row_url = $select_url->fetchrow_array;
  $select_url->finish;
  # if url is not found in the url_tab
  if (! @row_url) {
        $success &&= $insert_url->execute($url);
        $select_url->execute($url);
        @row_url = $select_url->fetchrow_array;
        $select_url->finish;
  } else {
        if (($row_url[1] > '0000-00-00 00:00:00') && ($row_url[2] < 100)) {
                return;
        }
        # if the url is in pending status or not qualified status, do not process
        if ($row_url[3] eq 'P') {
                return;
        }
  }

  # return url_id
  return $row_url[0];

}


sub add_reject {
  my $url = shift;
  my $reject_reason = shift;

  $success &&= $insert_reject->execute($url, $reject_reason);

  return;

}


1;