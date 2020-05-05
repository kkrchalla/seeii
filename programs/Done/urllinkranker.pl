#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

#open(STDOUT, "| tee c:/seeii/log/urllinkranker.log STDOUT");
open(STDOUT, ">>c:/seeii/log/urllinkranker.log") or die "Cannot open LOGFILE for WRITING: $!";
open(STDERR, ">&STDOUT") or die "Cannot open LOGFILE for WRITING: $!";

# This program calculated the url link ranks and updates the URL_LINKRANK_TAB.
# URL Link Rank is the (total of all the LINKRANKs of all URLs that we get the link from)/10 + 0.1

  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_calculated_linkrank = $dbh->prepare_cached("SELECT A.URL_ID, (SUM(C.LINKRANK)/10 + 0.1), A.LAST_LINKRANK_UPDATED_DATE FROM URL_TAB A, URL_BACKLINK_TAB B, URL_LINKRANK_TAB C, URL_TAB D WHERE A.URL_ID = B.URL_ID_TO AND B.URL_ID_FROM = C.URL_ID AND C.URL_ID = D.URL_ID AND D.QUALIFIED_FOR_LINK = 'Y' GROUP BY A.URL_ID ORDER BY A.LAST_LINKRANK_UPDATED_DATE LIMIT 100000");
  my $update_url = $dbh->prepare_cached("UPDATE URL_TAB SET LAST_LINKRANK_UPDATED_DATE = CURRENT_TIMESTAMP WHERE URL_ID = ?");
  my $insert_url_linkrank = $dbh->prepare_cached("INSERT INTO URL_LINKRANK_TAB VALUES (?, ?) ON DUPLICATE KEY UPDATE LINKRANK = VALUES(LINKRANK)");

  print localtime() . " - URLLINKRANKER program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  process_linkrank();

  $dbh->disconnect;

  print localtime() . " - URLLINKRANKER program ended\n";

  exit;


sub process_linkrank {

  my @row_url = ();
  my ($url_id, $linkrank);
  my $total_ranked = 0;
  my $running_count = 0;

  # select rows from url_tab and others
  $select_calculated_linkrank->execute();
  # for each row from url_tab and others
  while(@row_url = $select_calculated_linkrank->fetchrow_array) {
    $success = 1;
    $url_id = $row_url[0];
    $linkrank = $row_url[1];

    $success &&= $insert_url_linkrank->execute($url_id, $linkrank);
    $success &&= $update_url->execute($url_id);
    ++$total_ranked;
    ++$running_count;
    if ($running_count == 1000) {
       $running_count = 0;
       print "     " . localtime() . " - Running Count = $total_ranked \n";
    }

    $result = ($success ? $dbh->commit : $dbh->rollback);
    unless ($result) { 
      print "Error committing changes to urllinkranking URL_ID: $url_id \n";
    }

  }
  my $urllink_count = $select_calculated_linkrank->rows;
  if ($urllink_count == 0) {
    print "No entries in the URL_TAB\n";
  } else {
    print "Total records read   = $urllink_count\n";
    print "Total records ranked = $total_ranked \n";
  }
  $select_calculated_linkrank->finish;

  return;

}


1;
