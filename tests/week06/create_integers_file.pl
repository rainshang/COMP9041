#!/usr/bin/perl -w
my $start=$ARGV[0];
my $end=$ARGV[1];
my $file=$ARGV[2];
my $i=$start;
open F, '>', $file or die "$0: Can't open $file: $!\n";
for (my $i = $start; $i <= $end; $i++) {
    print F "$i\n";
}
close F;