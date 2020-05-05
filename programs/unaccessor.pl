#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}


# This program will delete all the unaccessable urls that have null add_date.
# This program will delete the urls from all the tables.
# In the end, it will update the unaccessable_url_tab with the current timestamp as the add date.

  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_unaccess  = $dbh->prepare_cached("SELECT URL FROM UNACCESSABLE_URL_TAB WHERE ADD_DATE IS NULL");
  my $update_unaccess  = $dbh->prepare_cached("UPDATE UNACCESSABLE_URL_TAB SET ADD_DATE = CURRENT TIMESTAMP WHERE URL = ?");
  my $select_url     = $dbh->prepare_cached("SELECT URL_ID FROM URL_TAB WHERE URL = ?");
  my $delete_url_list = $dbh->prepare_cached("DELETE FROM URL_TAB WHERE URL = ?");
  my $delect_url     = $dbh->prepare_cached("DELETE FROM URL_TAB WHERE URL_ID = ?");
  my $delect_url_backlink = $dbh->prepare_cached("DELETE FROM URL_BACKLINK_TAB WHERE URL_ID_TO = ? OR URL_ID_FROM = ?");
  my $delect_word_link    = $dbh->prepare_cached("DELETE FROM WORD_LINK_TAB WHERE URL_ID_TO = ? OR URL_ID_FROM = ?");
  my $delect_content     = $dbh->prepare_cached("DELETE FROM CONTENT_TAB WHERE URL_ID = ?");
  my $delect_title_desc  = $dbh->prepare_cached("DELETE FROM TITLE_DESC_TAB WHERE URL_ID = ?");
  my $delect_read     = $dbh->prepare_cached("DELETE FROM READ_URL_TAB WHERE URL_ID = ?");
  my $delect_parse     = $dbh->prepare_cached("DELETE FROM PARSE_URL_TAB WHERE URL_ID = ?");
  my $delect_duplicate = $dbh->prepare_cached("DELETE FROM URL_DUPLICATE_TAB WHERE URL_ID_1 = ? OR URL_ID_2 = ?");
  my $delect_url_linkrank     = $dbh->prepare_cached("DELETE FROM URL_LINKRANK_TAB WHERE URL_ID = ?");
  my $delect_word_linkrank     = $dbh->prepare_cached("DELETE FROM WORD_LINKRANK_TAB WHERE URL_ID = ?");
  my $delect_word_countrank     = $dbh->prepare_cached("DELETE FROM WORD_COUNT_RANK_TAB WHERE URL_ID = ?");
  my $delect_word_rank     = $dbh->prepare_cached("DELETE FROM WORD_RANK_TAB WHERE URL_ID = ?");

  print localtime() . " - UNACCESSOR program started\n";

  process_unaccess();

  $dbh->disconnect;

  print localtime() . " - UNACCESSOR program ended\n";

  exit;

sub process_unaccess {

  my @row_unaccess = ();
  my @row_url = ();
  my ($url_id, $url);

  # select rows from unaccessable_url
  $select_unaccess->execute();
  # for each row from unaccessable_url
  while(@row_unaccess = $select_unaccess->fetchrow_array) {
    $success = 1;
    $url = $row_unaccess[0];

    # select url_id from url_tab
    $select_url->execute($url);
    @row_url = $select_url->fetchrow_array;
    $select_url->finish;

    # if url_id is found in url_tab
    if ($row_url[0]) {
      $url_id = $row_url[0];

      # start deleting
      $success &&= $delete_url_list->execute($url);
      $success &&= $delete_word_rank->execute($url_id);
      $success &&= $delete_word_countrank->execute($url_id);
      $success &&= $delete_word_linkrank->execute($url_id);
      $success &&= $delete_url_linkrank->execute($url_id);
      $success &&= $delete_duplicate->execute($url_id, $url_id);
      $success &&= $delete_parse->execute($url_id);
      $success &&= $delete_read->execute($url_id);
      $success &&= $delete_title_desc->execute($url_id);
      $success &&= $delete_content->execute($url_id);
      $success &&= $delete_word_link->execute($url_id, $url_id);
      $success &&= $delete_url_backlink->execute($url_id, $url_id);
      $success &&= $delete_url->execute($url_id);
      $success &&= $update_unaccess->execute($url);
    }
    $result = ($success ? $dbh->commit : $dbh->rollback);
    unless ($result) { 
      print "Error committing changes to unaccessing URL: $url, URL-ID: $url_id \n";
    }

  }
  if ($select_unaccess->rows == 0) {
    print "No entries in the UNACCESSABLE_URL_TAB\n\n";
  }
  $select_unaccess->finish;

  return;

}


1;
