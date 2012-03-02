#!/usr/bin/perl

use Net::FTP;

$host = $ARGV[0];
$user = $ARGV[1];
$pass = $ARGV[2];

if (($#ARGV+1) != 3) {
  print "Please enter a hostname.\n";
  print "Example: collect4k.pl <hostname> <user> <pass>\n";
  exit 1;
}

$ftp=Net::FTP->new($host, Passive=>1, Timeout=>240) or $newerr=1;
  push @ERRORS, "Can't ftp to $host: $!\n" if $newerr;
  myerr() if $newerr;

$ftp->login($user,$pass) or $newerr=1;
  push @ERRORS, "Can't login to $host: $!\n" if $newerr;
  $ftp->quit if $newerr;
  myerr() if $newerr;

$ftp->cwd('/ramdrv/logs') or $newerr=1;
  push @ERRORS, "Can't change directory to /ramdrv/logs: $!\n" if $newerr;
  myerr() if $newerr;

@files=$ftp->ls or $newerr=1;
  push @ERRORS, "Cant list directory: $!\n" if $newerr;
  myerr() if $newerr;

foreach(@files) {
  print "Getting $_...";
  if ($ftp->get($_)) {
    print "OK\n";
  }else {
    $newerr=1;
    push @ERRORS, "Couldn't get $_ $!\n" if $newerr;
  }
}
$ftp->quit;
myerr() if $newerr;


sub myerr {
  print "Error: \n";
  print @ERRORS;
  exit 0;
}

