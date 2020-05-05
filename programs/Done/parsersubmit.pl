#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  $|=1;

  my $loadparser_file = "c:/seeii/process/loadparser";
  if (-e $loadparser_file) {
     exit;
  }

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   Parsersubmit \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $process_file = "c:/seeii/process/parsersubmit";
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

# This program will submit the parsers 30 wide.

  my $out_log_file = "c:/seeii/log/parsersubmit.log";
  my $success = 1;

  open(STDOUT, ">>$out_log_file") or die "Cannot open $out_log_file for WRITING: $!";
  open(STDERR, ">&STDOUT") or die "Cannot open $out_log_file for WRITING: $!";

  use Fcntl;
  use DBI;

  print localtime() . " - Parser Submit program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  process_submit();

  print localtime() . " - Parser program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  $process_log = " Close - " . localtime() . "   Parsersubmit \n";
  print PLFILE $process_log;
  close(PLFILE);

  exit;


sub process_submit {

  foreach my $queue_num (0..29) {
    eval {
        $pid = fork();
        if ($pid == 0) {
          close STDIN;
          close STDOUT;
          close STDERR;

          my $command = "perl parser.pl $queue_num"; 

          exec "$command"; 

        } elsif (!defined $pid) {
          print "  Fork failed during Parser - $queue_num submit";
        }
    };
  }

  return;

}

 
1;