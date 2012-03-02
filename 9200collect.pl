#!/usr/bin/env perl
###
# Copyright (c) 2012, Chris Rushton
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
###

# This script ftp's the log files and crash dumps from a 9200 to the local machine.
# It puts the files in a local directory of the hostname.

use Net::FTP;
use File::Path;
use POSIX;
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

$now = sprintf("%d%d%d",$hour,$min,$sec);

$host = $ARGV[0];
$user = $ARGV[1];
$pass = $ARGV[2];
$port = 41;
$dir = $host."_".$now;
$debug=0;

@cores = ();
@dumps = ();

@spu1slot0 = ("0.0.0","0.0.1","0.1.0","0.1.1","0.2.0","0.2.1","0.3.0","0.3.1","0.4.0","0.4.1");
@spu1slot1 = ("1.0.0","1.0.1","1.1.0","1.1.1","1.2.0","1.2.1","1.3.0","1.3.1","1.4.0","1.4.1");
@npu1slot2 = ("2.0.0", "2.0.1");
@npu1slot3 = ("3.0.0", "3.0.1");
@spu2slot0 = ("0.0.0","0.1.0","0.2.0","0.3.0");
@spu2slot1 = ("1.0.0","1.1.0","1.2.0","1.3.0");
@npu2slot2 = ("2.0.0");
@npu2slot3 = ("3.0.0");
@tcu1slot4 = ("4.0.0", "4.0.1", "4.1.0", "4.1.1");
@tcu1slot5 = ("5.0.0", "5.0.1", "5.1.0", "5.1.1");
@tcu1slot6 = ("6.0.0", "6.0.1", "6.1.0", "6.1.1");

@coredumps = ("000", "001", "010", "011", 
"020", "021", "030", "031", 
"040", "041", 
"100", "101", "110", "111", 
"120", "121", "130", "131", 
"140", "141", 
"200", "201", 
"300", "301", 
"400", "401", "410", "411", 
"500", "501", "510", "511", 
"600", "601", "610", "611"
);

if (($#ARGV+1) != 3) {
    print "Please enter a hostname.\n";
    print "Example: 9200collect.pl <hostname> <user> <pass>\n";
  exit 1;
}

$ftp=Net::FTP->new($host, Port=>$port, Passive=>1, Timeout=>240, Debug=>$debug) or $newerr=1;
    push @ERRORS, "Can't ftp to $host: $!\n" if $newerr;
    myerr() if $newerr;

$ftp->login($user,$pass) or $newerr=1;
  push @ERRORS, "Can't login to $host: $!\n" if $newerr;
  $ftp->quit if $newerr;
  myerr() if $newerr;

if ( $ftp->cwd('/0.2.0/logs') or $ftp->cwd('/0.3.0/logs') or $ftp->cwd('/0.4.0/logs') ) {
    push @cores, @spu1slot0;
    push @dumps, "0.0.0";
} elsif ( $ftp->cwd('/0.0.0/logs') or $ftp->cwd('/0.1.0/logs') ) {
    push @cores, @spu2slot0;
    push @dumps, "0.0.0";
}

if ( $ftp->cwd('/1.2.0/logs') or $ftp->cwd('/1.3.0/logs') or $ftp->cwd('/1.4.0/logs') ) {
    push @cores, @spu1slot1;
    push @dumps, "1.0.0";
} elsif ( $ftp->cwd('/1.0.0/logs') or $ftp->cwd('/1.1.0/logs') ) {
    push @cores, @spu2slot1;
    push @dumps, "1.0.0";
}

if ( $ftp->cwd('/2.0.1/logs') ) {
    push @cores, @npu1slot2;
} elsif ( $ftp->cwd('/2.0.0/logs') ) {
    push @cores, @npu2slot2;
}

if ( $ftp->cwd('/3.0.1/logs') ) {
    push @cores, @npu1slot3;
} elsif ( $ftp->cwd('/3.0.0/logs') ) {
    push @cores, @npu2slot3;
}

if ( $ftp->cwd('/4.0.0/logs') ) {
    push @cores, @tcu1slot4;
}

if ( $ftp->cwd('/5.0.0/logs') ) {
    push @cores, @tcu1slot5;
}

if ( $ftp->cwd('/6.0.0/logs') ) {
    push @cores, @tcu1slot6;
}

@cores = sort(@cores);

mkdir($dir);

print "-- LOG FILES --\n";
foreach $core (@cores) {
    $coredir = "$dir/$core";
    mkdir($coredir);
    $logdir = "/$core/logs";
    $ftp->cwd($logdir) or print $!;
	@files = $ftp->dir;
	foreach $file (@files) {
            @fields=split(/\s+/,$file);
            $file = $fields[8];
            if ( $file =~ /^\.{1,2}$/ or $file =~ /^dump$/ ) { next; }
            if ( $file =~ /^.*gz$/ ) { $ftp->binary; $binary=1;}
	    $newfile = "$dir/$core/$file";
	    if ( $ftp->get($file,$newfile) ) {
                print "Got $newfile\n";
            } else {
                print "ERROR: $newfile\n";
            }
            if ( $binary ) { $ftp->ascii; $binary=0; }
        }
}

print "\n-- CRASH DUMPS --\n";
foreach $coredump (@coredumps) {
    $dumpdir = "/ramdrv/logs/dump/$coredump";
    if ( $ftp->cwd($dumpdir) ) {
        $dumpcheck = 1;
        $dumppath = "$dir/dump/$coredump";
        mkpath($dumppath);
        @files = $ftp->dir;
        foreach $file (@files) {
            @fields=split(/\s+/,$file);
            $file = $fields[8];
            if ( $file =~ /^\.{1,2}$/ ) { next; }
            $newfile = "$dumpath/$file";
            $ftp->binary;
            if ( $ftp->get($file,$newfile) ) {
                print "Got Dump: $newfile\n";
            } else {
                print "ERROR Dump: $newfile\n";
            }
        }
    }
}

if ( !$dumpcheck ) { print "none...\n"; }

$ftp->quit;

print "\n";
exit 0;

sub myerr {
    print "Error: \n";
    print @ERRORS;
    exit 1;
}
