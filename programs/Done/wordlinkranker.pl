#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

#open(STDOUT, "| tee c:/seeii/log/wordlinkranker.log STDOUT");
open(STDOUT, ">>c:/seeii/log/wordlinkranker.log") or die "Cannot open LOGFILE for WRITING: $!";
open(STDERR, ">&STDOUT") or die "Cannot open LOGFILE for WRITING: $!";

# This program calculated the word link ranks and updates the WORD_LINKRANK_TAB.
# Word Link Rank is the total of all the LINKRANKs of all URLs that we get the link from.

  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_calculated_linkrank = $dbh->prepare_cached("SELECT A.WORD_ID, B.URL_ID_TO, SUM(C.LINKRANK), A.LAST_LINKRANK_UPDATED_DATE FROM WORD_TAB A, WORD_LINK_TAB B, URL_LINKRANK_TAB C, URL_TAB D WHERE A.WORD_ID = B.WORD_ID AND B.URL_ID_FROM = C.URL_ID AND C.URL_ID = D.URL_ID AND D.QUALIFIED_FOR_LINK = 'Y' GROUP BY A.WORD_ID, B.URL_ID_TO ORDER BY A.LAST_LINKRANK_UPDATED_DATE LIMIT 1000000");
  my $update_word = $dbh->prepare_cached("UPDATE WORD_TAB SET LAST_LINKRANK_UPDATED_DATE = CURRENT_TIMESTAMP WHERE WORD_ID = ?");
  my $insert_word_linkrank = $dbh->prepare_cached("INSERT INTO WORD_LINKRANK_TAB VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE LINKRANK = VALUES(LINKRANK)");

  print localtime() . " - WORDLINKRANKER program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  process_linkrank();

  $dbh->disconnect;

  print localtime() . " - WORDLINKRANKER program ended\n";

  exit;


sub process_linkrank {

  my @row_url = ();
  my ($word_id, $url_id, $linkrank);
  my $total_ranked = 0;
  my $running_count = 0;

  # select rows from url_tab and others
  $select_calculated_linkrank->execute();
  # for each row from url_tab and others
  while(@row_url = $select_calculated_linkrank->fetchrow_array) {
    $success = 1;
    $word_id = $row_url[0];
    $url_id = $row_url[1];
    $linkrank = $row_url[2];

    $success &&= $insert_word_linkrank->execute($word_id, $url_id, $linkrank);
    $success &&= $update_word->execute($word_id);
    ++$total_ranked;
    ++$running_count;
    if ($running_count == 1000) {
       $running_count = 0;
       print "     " . localtime() . " - Running Count = $total_ranked \n";
    }

    $result = ($success ? $dbh->commit : $dbh->rollback);
    unless ($result) { 
      print "Error committing changes to wordlinkranking URL_ID: $url_id \n";
    }

  }
  my $wordlink_count = $select_calculated_linkrank->rows;
  if ($wordlink_count == 0) {
    print "No entries in the WORD_TAB\n";
  } else {
    print "Total records processed = $wordlink_count\n";
    print "Total records ranked    = $total_ranked \n";
  }
  $select_calculated_linkrank->finish;

  return;

}


1;
