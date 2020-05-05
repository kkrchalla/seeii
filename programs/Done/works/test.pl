#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  use Geo::IP qw(GEOIP_STANDARD);

  my $gi = Geo::IP->open("C:/Program Files/GeoIP/GeoIP.dat",GEOIP_STANDARD );


  # look up IP address '24.24.24.24'
  # returns undef if country is unallocated, or not defined in our database
  my $country = $gi->country_code_by_name('www.seeii.com');
  if ($country) {
    print "country = $country \n";
  } else {
    print "not found \n";
  }

  my $xx = "http://www.teluguone.com";
            my $indianword = "telugu";
  if ($xx =~ m/$indianword/igs) {
#print " $indianword \n";
  }

  exit;