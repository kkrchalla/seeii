#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}


# This program will rejected domains that have null rejected_date.
# This program will get all the urls associated with this domain and will add them to the url_rejected_tab with null add_date
# In the end, it will update the domain_rejected_tab with the current timestamp as the rejected date.

  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_reject  = $dbh->prepare_cached("SELECT DOMAIN FROM DOMAIN_REJECTED_TAB WHERE REJECTED_DATE IS NULL");
  my $update_reject  = $dbh->prepare_cached("UPDATE DOMAIN_REJECTED_TAB SET REJECTED_DATE = CURRENT TIMESTAMP WHERE DOMAIN = ?");
  my $insert_domain  = $dbh->prepare_cached("INSERT INTO DOMAIN_TAB (DOMAIN, ACCEPT) VALUES (?, 'N') ON DUPLICATE KEY UPDATE ACCEPT = VALUES(ACCEPT)");
  my $select_domain  = $dbh->prepare_cached("SELECT DOMAIN_ID FROM DOMAIN_TAB WHERE DOMAIN = ?");
  my $select_url     = $dbh->prepare_cached("SELECT URL FROM URL_TAB WHERE DOMAIN_ID = ?");
  my $insert_url_reject = = $dbh->prepare_cached("INSERT INTO URL_REJECTED_TAB (URL, REJECTED_REASON) VALUES (?, ?)");

  print localtime() . " - DOMAIN REJECTOR program started\n";

  process_reject();

  $dbh->disconnect;

  print localtime() . " - DOMAIN REJECTOR program ended\n";

  exit;

sub process_reject {

  my @row_reject = ();
  my @row_domain = ();
  my ($domain_id, $domain, $url);
  my $reject_reason = 9;

  # select rows from reject_domain
  $select_reject->execute();

  # for each row from reject_domain
  while(@row_reject = $select_reject->fetchrow_array) {
    $success = 1;
    $domain = $row_reject[0];

    # insert this domain in the domain_tab, or update the accept with 'N'
    $success &&= $insert_domain->execute($domain);

    # get the domain_id
    $select_domain->execute($domain);
    @row_domain = $select_domain->fetchrow_array;
    $select_domain->finish;
    $domain_id = $row_domain[0];

    # get all the urls for the domain from the url_tab
    $select_url->execute($domain_id);

    # for each url, add a row in url_rejected_tab with reject_reason = 9 (unacceptable domain)
    while (@row_url = $select_url->fetchrow_array) {
      $url = $row_url[0];
      $success &&= $insert_url_reject->execute($url, $reject_reason);
    }

    $select_url->finish;

    $success &&= $update_reject->execute($domain);

    $result = ($success ? $dbh->commit : $dbh->rollback);
    unless ($result) { 
      print "Error committing changes to rejecting domain: $domain, DOMAIN-ID: $domain_id \n";
    }

  }
  if ($select_reject->rows == 0) {
    print "No entries in the DOMAIN_REJECTED_TAB\n\n";
  }
  $select_reject->finish;

  return;

}


1;
