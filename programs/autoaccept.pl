#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

open(STDOUT, ">>c:/seeii/log/autoaccept.log") or die "Cannot open LOGFILE for WRITING: $!";
open(STDERR, ">&STDOUT") or die "Cannot open LOGFILE for WRITING: $!";

  #Loading acceptwords...
  my $ACCEPTWORDS_FILE = 'c:/seeii/programs/acceptwords.txt';
  my @acceptwords = ();
  build_accept_array();

#  use IP::Country::Fast;
#  my $reg = IP::Country::Fast->new();

  use DBI;
  use URI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;

  my $select_domain  = $dbh->prepare_cached("SELECT DOMAIN_ID, DOMAIN FROM DOMAIN_TAB WHERE ACCEPT IS NULL LIMIT 50000");
  my $update_domain  = $dbh->prepare_cached("UPDATE DOMAIN_TAB SET ACCEPT = ? WHERE DOMAIN_ID = ?");

  print localtime() . " - Autoaccept program started\n";

  process_accept();

  $dbh->disconnect;

  print localtime() . " - Autoaccept program ended\n";

  exit;



sub process_accept {

  my @row_domain = ();
  my $accept_count = 0;
  my $running_count = 0;
  my $kcount = 0;
  my $icount = 0;
  my $0count = 0;

  # select rows from domain_tab
  $select_domain->execute;
  # for each row from domain_tab
  while(@row_domain = $select_domain->fetchrow_array) {
    $success = 1;
    my $domain_id = $row_domain[0];
    my $domain    = $row_domain[1];
    my $accept_ind = '0';
    my $country_code = "";

    foreach my $acc_word (@acceptwords) {
      if( $domain =~ m/$acc_word/ ) {
        $accept_ind = 'K';
        ++$kcount;
        last;
      }
    }
    if ($accept_ind == 0) {
#      my $uri = new URI($url);
#      $hostname = $uri->host;
#      $country_code = $reg->inet_atocc($hostname);
#      if ($country_code eq 'IN') {
#        $accept_ind = 'I';
#        ++$icount;
#      } else {
        ++$0count;
#      }
    }

    $update_domain->execute($domain_id);
    ++$accept_count;
    ++$running_count;
    if ($running_count == 1000) {
       $running_count = 0;
       print "     " . localtime() . " - Running Count = $accept_count\n";
    }
  }
  my $select_count = $select_domain->rows;
  if ($select_count == 0) {
    print "No entries in the PARSE_URL_TAB\n";
  } else {
    print "Total records read            = $select_count \n";
    print "Total records processed       = $accept_count \n";
    print "Total domains accepted by key = $kcount \n";
    print "Total domains accepted by ip  = $icount \n";
    print "Total domains not know        = $0count \n";
  }
  $select_domain->finish;

  return;

}

# Load the user's list of accept words.
#
sub build_accept_array {
  open(FILE, $ACCEPTWORDS_FILE) or (warn "Cannot open '$ACCEPTWORDS_FILE': $!" and return);
  while (<FILE>) {
    chomp;
    $_ =~ s/\r//g; # get rid of carriage returns
    push @acceptwords, $_;
  }
  close(FILE);
  return;
}

1;
