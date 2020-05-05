#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  $|=1;

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   Readersubmit \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $process_file = "c:/seeii/process/readersubmit";
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

# This program will submit the readers 30 wide.

# Reader program will read the urls from the READ_URL_TAB.
# Then it accesses the web to read the content and stores it in the CONTENT_TAB
# In this process, it checks for the urls that are not accepted,
# checks for the last modified date,
# checks if the content is modified at all since the last time it read
# checks for the duplicates
# checks for the robots.txt, and robot metatags
# adds the domain name to the database

  my $out_log_file = "c:/seeii/log/readersubmit.log";

  open(STDOUT, ">>$out_log_file") or die "Cannot open $out_log_file for WRITING: $!";
  open(STDERR, ">&STDOUT") or die "Cannot open $out_log_file for WRITING: $!";

  use Fcntl;

  print localtime() . " - Reader Submit program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  process_submit();

  print localtime() . " - Read URL program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  $process_log = " Close - " . localtime() . "   Readersubmit \n";
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

        my $command = "perl reader.pl $queue_num"; 

        exec "$command"; 

      } elsif (!defined $pid) {
        print "  Fork failed during Reader - $queue_num submit";
      }
    };
  }

  return;

}


1;