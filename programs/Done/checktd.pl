#!/usr/bin/perl

BEGIN {
   $|=1;
   use CGI::Carp('fatalsToBrowser');
}

  my $process_log_file = "c:/seeii/process/log.txt";
  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  my $process_log = " Start - " . localtime() . "   CheckTD \n";
  print PLFILE $process_log;
  close(PLFILE);

  my $process_file = "c:/seeii/process/checktd";
  open(PFILE, ">$process_file") or warn "Cannot open $process_file for WRITING: $!";
  close(PFILE);

  open(STDOUT, ">>c:/seeii/log/checktd.log") or die "Cannot open LOGFILE for WRITING: $!";
  open(STDERR, ">&STDOUT") or die "Cannot open LOGFILE for WRITING: $!";

  use Fcntl;

  my $tdfile = "C:/seeii/load/ptemptd.txt";

  my $row_counter = 0;

  print localtime() . " - Check TD program started\n";
  my $pid = $$;
  print "     Process Id = $pid \n";

  check_file();

  print " Total Records Read = $row_counter \n";

  print localtime() . " - Check TD program ended\n";

  unlink $process_file or warn "Cannot remove '$process_file: $!'";

  open(PLFILE, ">>$process_log_file") or warn "Cannot open $process_log_file for WRITING: $!";
  $process_log = " Close - " . localtime() . "   CheckTD \n";
  print PLFILE $process_log;
  close(PLFILE);

exit;

sub check_file {

     if (-e $tdfile) {
        open(FILE, $tdfile) or (die "Cannot open '$tdfile': $!" and return);
        while (<FILE>) {
          ++$row_counter;
          my @td_array = split "-seeii-", $_;
          my $title_length = length($td_array[1]);
          if ($title_length > 85) {
                print "Long Title at record - $row_counter - $title_length - $td_array[1]\n";
          }
          if (scalar(@td_array) > 3) {
                print "More than 3 fields at - $row_counter \n";
          }
        }
        close(FILE);
     }

  return;

}

1;