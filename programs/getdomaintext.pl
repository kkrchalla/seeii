#!/usr/bin/perl -w

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  use Fcntl;
  use CGI;
  use MIME::Lite;
  use LWP::UserAgent;
  use URI;
  use Crypt::SSLeay;

  my $url = 'http://finance.yahoo.com/q?s=aapl';

  my $uri = new URI($url);
  $base_domain = $uri->scheme."://".$uri->host;

  print $base_domain .'\n';

  exit;