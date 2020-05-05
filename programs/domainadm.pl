#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  use CGI;
  use DBI;

  package main;

  my $query = new CGI;
  my $cmd       = $query->param('cmd');
  my $in_accept = $query->param('acc');
  my $skip      = $query->param('skip');

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_domain;

  if (! $skip) {
    $skip = 0;
  }

  if (($in_accept eq 'Y') || ($in_accept eq 'y')) {
    $select_domain = $dbh->prepare_cached("SELECT DOMAIN_ID, DOMAIN, ACCEPT FROM INDEX_DB.DOMAIN_TAB WHERE ACCEPT = 'Y' LIMIT ($skip, 50)");
  } elsif (($in_accept eq 'N') || ($in_accept eq 'n')) {
    $select_domain = $dbh->prepare_cached("SELECT DOMAIN_ID, DOMAIN, ACCEPT FROM INDEX_DB.DOMAIN_TAB WHERE ACCEPT = 'N' LIMIT ($skip, 50)");
  } elsif (($in_accept eq 'NULL') || ($in_accept eq 'null')) {
    $select_domain = $dbh->prepare_cached("SELECT DOMAIN_ID, DOMAIN, ACCEPT FROM INDEX_DB.DOMAIN_TAB WHERE ACCEPT = NULL LIMIT ($skip, 50)");
  } else {
    $select_domain = $dbh->prepare_cached("SELECT DOMAIN_ID, DOMAIN, ACCEPT FROM INDEX_DB.DOMAIN_TAB LIMIT ($skip, 50)");
  } 

  $skip = $skip + 50;

  my $update_domain = $dbh->prepare_cached("UPDATE INDEX_DB.DOMAIN_TAB SET ACCEPT = 'Y' WHERE DOMAIN_ID = ?");
  my $insert_domain_reject = $dbh->prepare_cached("INSERT INTO INDEX_DB.DOMAIN_REJECTED_TAB (DOMAIN) VALUES (?) ON DUPLICATE KEY SET REJECTED_DATE = CURRENT_TIMESTAMP");
  my $delete_reject = $dbh->prepare_cached("DELETE FROM INDEX_DB.DOMAIN_REJECTED_TAB WHERE DOMAIN = ?");

  if ($cmd eq "update") {
    update_domain();
  }

  get_domain();

  exit;


sub get_domain {

  my @row_domain = ();

  $select_domain->execute();

  while(@row_domain = $select_domain->fetchrow_array) {

	display all 50

  }

  display accept, skip count
  print html;

  return;

}

sub update_domain {
  my $domain_id = 
  my $domain = 
  my $upd_accept = 

  foreach input-->
    if ($upd_accept eq 'N') {
       insert_domain_reject->execute($domain);
    } else {
       if ($upd_accept eq 'Y') {
         update_domain->execute($domain_id);
       } else {
         update_domain_null->execute($domain_id);
       }
       delete_reject->execute($domain);
    }
  }

  return;

}