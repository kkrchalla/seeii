#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}


# This program will search for the key words and give the urls
# along with title and description.
# For performance reasons, this program will have the html embedded in it
# If no results are found, this program will wait for 5 seconds before
# displaying the results. This is to make the user feel that we have tried
# hard to find the results.

  use DBI;

  my $db   = "index_db";
  my $host = "localhost";
  my $port = "3306";
  my ($dbh, $success);
  my @row_search = ();
  my $next_pos = 
  my $num_results = 10;
  my $query = 
  my $lang_e = 
  my $lang_h = 
  my $lang_te = 
  my $lang_ta = 
  my $lang_k =
  my $lang_m =
  my $lang_b =
  my $lang_p =
  my $lang_g =


  $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port","root", "password")
            or die "Couldn't connect to database: " . DBI->errstr;
  $dbh->{AutoCommit} = 0;

  my $select_results = $dbh->prepare_cached("");
  my $insert_found = $dbh->prepare_cached("");
  my $insert_notfound = $dbh->prepare_cached("");

  # select rows from search_view
  $select_results->execute();
  # for each row from search_view
  while(@row_search = $select_results->fetchrow_array) {
    $url = $row_search[0];
    $title = $row_search[1];
    $desc = $row_search[2];
    $size = $row_search[3];
    $date = $row_search[4];
    $rank = $row_search[5];
    $total = $row_search[6];

    # build a row in html

  }
  if ($select_results->rows == 0) {
    wait for 5 seconds
    print not found html
  }
  $select_search->finish;

  log the search results in background

  $dbh->disconnect;

  exit;
