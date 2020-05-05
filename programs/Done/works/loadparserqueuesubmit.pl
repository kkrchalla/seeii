#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  $|=1;

  foreach my $queue_num (0..29) {
    eval {
        $pid = fork();
        if ($pid == 0) {
          close STDIN;
          close STDOUT;
          close STDERR;

          my $command = "perl loadparser.pl $queue_num"; 

          exec "$command"; 

        } elsif (!defined $pid) {
          print "  Fork failed during LoadParser - $queue_num submit";
        }
    };
  }

  exit;


