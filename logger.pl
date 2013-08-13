#!/usr/bin/env perl
#
# This is a simple PERL program for opening a UDP ocket & listening for
# UDP logging datagrams.
#
# Each log message is in ASCII and is formatted as:
#
# <file>:<log test>
#
# A hash table (hashing filenames into file handles) is maintained to keep
# track of open files to which data is logged.
#
use strict;
use warnings 'all';
use Socket;
use POSIX;
use Getopt::Std;

# globals
my %handles        = ();
my $maxRotateBytes = 1000000;
my $maxFiles       = 12;
our($opt_p, $opt_d, $opt_f, $opt_m);

sub check_rotate {
    my $file = $_[0];
    my $done = 0;
    my $filesz;
    my $i;
    my $j;
    my $tmp;

    if ( $handles{$file} ) {
        $tmp = sysseek( $handles{$file}, 0, SEEK_CUR );
        $filesz = $tmp;

        #      print "$file: $filesz of $maxRotateBytes\n";
        if ( $filesz > $maxRotateBytes ) {

            #	   print "$file > $maxRotateBytes\n";
            for ( $i = 1 ; $i < $maxFiles && $done == 0 ; ) {
                if ( !-e "$file.$i" ) {
                    $done = 1;
                }
                else {
                    $i++;
                }
            }

            #	   print "largest suffix is $i\n";

            if ( $i == $maxFiles ) {

                #	     print "rmmax $file.$i\n";
                unlink("$file.$i");
            }

            # blank out the hashmap entry; a new file will
            # be opened when the next log message arrives
            #	   print "close $file\n";
            close( $handles{$file} );
            undef $handles{$file};

            # Now do the actual 'rotate'
            for ( $j = $i - 1 ; $j >= 0 ; $j--, $i-- ) {
                if ( $j == 0 ) {

                    # move filename to filename.1
                    #	           print "mv $file, $file.$i\n";
                    rename( $file, "$file.$i" );
                }
                else {
                    # move filename.i-1 to filename.i
                    #	           print "mv $file.$j, $file.$i\n";
                    rename( "$file.$j", "$file.$i" );
                }
            }
        }
    }
}

# parse command line options
my $port = 2500;
my $logdir  = ".";
getopt('pdfm');

if ($opt_p) {
    $port = $opt_p;
}
if ($opt_d) {
    $logdir = $opt_d;
    printf( "logdir=%s\n", $logdir );
}
if ($opt_f) {
    $maxFiles = $opt_f;
    printf( "maxFiles=%s\n", $maxFiles );
}
if ($opt_m) {
    $maxFiles = $opt_m;
    printf( "maxRotateBytes=%s\n", $maxRotateBytes );
}

if ( ( length($logdir) > 1 ) || ( $logdir ne "." ) ) {
    if ( !-d $logdir ) {
        printf("Invalid target directory specified\n");
        exit;
    }
    chdir($logdir) || die "Cannot change to $logdir";
}

printf(
"logger.pl: Listening on port %d; Logging to '%s'; Rotate=%d@%d\n",
    $port, $logdir, $maxFiles, $maxRotateBytes
);

my $proto = getprotobyname('udp');
if ( socket( LISTEN, PF_INET, SOCK_DGRAM, $proto ) ) {
    setsockopt( LISTEN, SOL_SOCKET, SO_REUSEADDR, pack( "l", 1 ) );
    bind( LISTEN, sockaddr_in( $port, INADDR_ANY ) );
    listen( LISTEN, SOMAXCONN );
}
else {
    print STDERR "Failed to open listening socket : $!\n";
}

#
# need to keep a dynamically instantiated table of logfile names to
# file descriptors.
#

while (1) {
    my $from = recv LISTEN, my $rcvbuf, 1024, 0;
    my $fromip = inet_ntoa( ( unpack_sockaddr_in($from) )[1] );
    # $toip = inet_ntoa((unpack_sockaddr_in(getsockname(LISTEN)))[1]);
    # get the target file

    # skip packet if undesirable most likely empty packet
    next if length($rcvbuf) <= 1;

    my @fields = split( /:/, $rcvbuf );
    # skip packet if no filename
    next if length($fields[0]) < 1;
    # skip packet if no data inside
    next if !defined $fields[1] or (length($fields[1]) <= 1);

    my $leaffile = $fields[0];
    my $dir = $fromip;

    # create directory and set filename
    mkdir $dir, 0777 if !-d $dir;
    my $file = "$dir/$leaffile";

    # remove the file prefix from the buffer...
    my $outbuf = substr $rcvbuf, length($leaffile) + 1;

    # check to see if the file should be rotated...
    check_rotate($file) if -e $file;

    #
    # Check to see if the extracted filename already exists in our
    # table of open file decriptors.
    #
    if ( !$handles{$file} ) {
        if ( open( $handles{$file}, ">> $file" ) ) {
                print "opened $file\n" if !-e "$file.1";
        }
        else {
            print "Failed to open $file !!!\n";
        }
    }

    # write to the file
    syswrite $handles{$file}, "$outbuf\n";

    # listen for more messages...
    listen LISTEN, SOMAXCONN;
}
