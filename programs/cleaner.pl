#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}


# Will delete all records from UNACCESSABLE_URL_TAB table that were tried 30 days ago.

  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);

  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;

  my $delete_unaccessable = $dbh->prepare_cached("DELETE FROM UNACCESSABLE_URL_TAB WHERE DATEDIFF(NOW(),LAST_TRIED_DATE) = 120");

  print localtime() . " - CLEANER program started\n";

  process_clean();

  $dbh->disconnect;

  print localtime() . " - CLEANER program ended\n";

  exit;


sub process_clean {

  $delete_unaccessable->execute();

  return;

}


1;
