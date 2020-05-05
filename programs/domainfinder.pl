#!/usr/bin/perl
#$rcs = ' $Id: search,v 1.0 2004/03/30 00:00:00 Exp $ ' ;

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

$|=1;    # autoflush
open(STDSAVE, ">&STDOUT");
  use DBI;
  use URI;
  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my $sth;

  my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;

  $select_url  = $dbh->prepare_cached("SELECT URL FROM INDEX_DB.URL_LIST_TAB");
  $insert_domain  = $dbh->prepare_cached("INSERT INTO INDEX_DB.DOMAIN_TAB (DOMAIN) VALUES (?)");
  $select_domain  = $dbh->prepare_cached("SELECT 1 FROM INDEX_DB.DOMAIN_TAB WHERE DOMAIN = ?");

  my $LOG_FILE = 'c:/seeii/domainfindlog.txt';

  open(STDOUT, ">>$LOG_FILE") or die "Cannot open LOGFILE for WRITING: $!";
  print "STARTING DOMAINFINDER \n";

  my $count = 0;
  my $row_url = ();

  $select_url->execute();
  while (@row_url = $select_url->fetchrow_array) { 
        $url = @row_url[0];
     my $uri = new URI($url);
	eval {
       my $domain = $uri->scheme."://".$uri->host;
       my @row_domain = ();
          $select_domain->execute($domain);
          @row_domain = $select_domain->fetchrow_array;
          $select_domain->finish;
          if (! @row_domain) {
             $success = $insert_domain->execute($domain);
             if ($success != 1) { print " error for $domain \n";}
             $count++;
          }
	};
	if ($@) {
	  print STDSAVE "ERROR $url\n"
	}
  }
  $select_url->finish;
  print " count = $count \n";
  print STDSAVE " count = $count \n";
  $dbh->disconnect;
  flock(LOGFLE, LOCK_UN);
  close(LOGFLE);

exit;
