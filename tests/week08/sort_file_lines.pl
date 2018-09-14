#!/usr/bin/perl -w
open F, '<', $ARGV[0] or die "Cannot open $ARGV[0]: $!\n";
@lines = ();
while ($line = <F>) {
    push @lines, $line;
}
close F;
@lines = sort { length $a <=> length $b || $a cmp $b } @lines;
print(@lines);