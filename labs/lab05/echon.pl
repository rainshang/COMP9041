#!/usr/bin/perl -w
if (@ARGV != 2) {
    print "Usage: $0 <number of lines> <string>\n"
}
else {
    if ($ARGV[0] =~ /^[0-9]+$/) {
        for ($i = 0; $i < $ARGV[0]; $i++) {
            print "$ARGV[1]\n"
        }
    }
    else {
        print "$0: argument 1 must be a non-negative integer\n"
    }
}