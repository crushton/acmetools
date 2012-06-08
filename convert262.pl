#!/usr/bin/env perl
###
## Copyright (c) 2012, Chris Rushton
##
## Permission to use, copy, modify, and distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
## OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
###
#
# This script converts HMR's on a 4250 running 6.0/6.1 to the new 6.2 format.
# All hyphens are converted to underscores in header rule name and element rule name.
# All uppercase letters are converted to lowercase letters in header rule name and element rule name.
# All header rule or element rule names starting with a number have a "z" appened to the front.
# All changes to header rule name and element rule names are updated in match value and new value in case they are used as variables.

## Requrements
# gzip
# 

$filename = $ARGV[0];

if (($#ARGV+1) != 1) {
  print "Please enter a filename.\n";
  print "Example: convert262.pl <filename>\n";
  exit 1;
}

if (($filename !~ /^.*.gz/) || !(-e $filename))
{
    print "Please input a valid SBC backup config.\n";
    exit 1;
}

$cmd = "cp $filename $filename.orig";
if (system($cmd)) { die("Backup original file failed, please verify!"); }

$cmd = "gzip -d $filename";
if (system($cmd)) { die("Un-gzip failed, please verify!"); }

$filename =~ s/\.gz//;

open(FILE, $filename) || die("Could not open file, please verify!");
@raw_data=<FILE>;
close(FILE);
chomp(@raw_data);

$length = scalar(@raw_data) - 1;

@hmr = ();

## Gets start and end of all HMR's in order to parse through them for changes that need to be made.
for ($count = 0; $count <= $length; $count++) {
    if ($raw_data[$count] =~ /<sipManipulation/ || $raw_data[$count] =~ /<\/sipManipulation>/)
    {
        if ($raw_data[$count] =~ /<\//)
        {
            $end = $count;
            push(@hmr,[$start,$end]);
        } 
        else
        {
            $start = $count;
        }
    }
}

foreach $sipmanip (@hmr)
{
    $start = $sipmanip->[0];
    $end = $sipmanip->[1];
    #print "start: $start\nend: $end\n\n";
    @names=();
    for ($count = $start; $count <= $end; $count++) {
        if ($raw_data[$count] =~ /<sipManipulation name='(.*)'/) 
        {
            print "==== HMR Name: $1 ====\n";
        } 
		## Gets a list of header rule names and element rule names which were updated in order to check for variables after.
        elsif ($raw_data[$count] =~ /name='(.+)'/ && defined $1)
        {
            $old = $1;
            if ($old =~ /[A-Z-]/)
            {
                if ($old =~ /^[0-9]/) {$old =~ s/$old/z$old/; };
                $lineno = $count + 1;
                $new = lc($old);
                $new =~ s/-/_/g;
                push(@names,[$old,$new]);
                print "$lineno old: $old\n$lineno new: $new\n\n";
                $raw_data[$count] =~ s/name='(.+)'/name='$new'/g;
                print "$raw_data[$count]\n";
            }
        }
    }
	## Replaces all instances of the old names to new names in case are being used as placeholder variables.
    for ($count = $start; $count <= $end; $count++) {
        if ($raw_data[$count] =~ /matchValue=/ || $raw_data[$count] =~ /newValue=/)
        {
            foreach $value (@names)
            {
                $old = $value->[0];
                $new = $value->[1];
                $raw_data[$count] =~ s/$old/$new/g;
            }
        }
    }
}

#create new backup config to load
$newfile = $filename."_new";
open(FILE, ">$newfile") || die("Unable to create new file, please verify!");

for ($count = 0; $count <= $length; $count++) {
    if ($count == $length)
    {
        print FILE $raw_data[$count];
    } 
    else
    {
        print FILE "$raw_data[$count]\n";
    }
}

close(FILE);

$cmd = "gzip -9 $newfile";
if (system($cmd)) { die("Unable to compress new file, please verify!"); }

print "Created new backup config \"".$newfile.".gz\"\n";
print "USE ARE YOUR OWN RISK!!!!!\n"
