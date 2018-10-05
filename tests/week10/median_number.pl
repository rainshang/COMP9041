#!/usr/bin/perl -w
@sorted = sort { $a<=>$b } @ARGV;
print "$sorted[@sorted / 2]\n";