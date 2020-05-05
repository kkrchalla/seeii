#!/usr/bin/perl -w
  
BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}



  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_calculated_linkrank = $dbh->prepare_cached("SELECT A.WORD_ID, B.URL_ID_TO, SUM(C.LINKRANK), A.LAST_LINKRANK_UPDATED FROM WORD_TAB A, WORD_LINK_TAB B, URL_LINKRANK_TAB C, URL_TAB D WHERE A.WORD_ID = B.WORD_ID AND B.URL_ID_FROM = C.URL_ID AND C.URL_ID = D.URL_ID AND D.QUALIFIED_FOR_LINK = 'Y' GROUP BY A.WORD_ID, B.URL_ID_TO ORDER BY A.LAST_LINKRANK_UPDATED_DATE");
  my $update_word = $dbh->prepare_cached("UPDATE WORD_TAB SET LAST_LINKRANK_UPDATED_DATE = CURRENT_TIMESTAMP WHERE WORD_ID = ?");
  my $insert_word_linkrank = $dbh->prepare_cached("INSERT INTO WORD_LINKRANK_TAB VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE LINKRANK = VALUES(LINKRANK)");

  print localtime() . " - WORDLINKRANKER program started\n";

  process_linkrank();

  $dbh->disconnect;

  print localtime() . " - WORDLINKRANKER program ended\n";

  exit;


sub process_linkrank {

  my @row_url = ();
  my ($word_id, $url_id, $linkrank);

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

    $result = ($success ? $dbh->commit : $dbh->rollback);
    unless ($result) { 
      print "Error committing changes to wordlinkranking URL_ID: $url_id \n";
    }

  }
  if ($select_calculated_linkrank->rows == 0) {
    print "No entries in the WORD_TAB\n\n";
  }
  $select_calculated_linkrank->finish;

  return;

}


1;
