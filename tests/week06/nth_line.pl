#!/usr/bin/perl -w
my $n_th = $ARGV[0];
my $file = $ARGV[1];
open F, '<', $file or die "$0: Can't open $file: $!\n";
my $i = 1;
while ($line = <F>) {
    print "$line" if ($i == $n_th);
    $i++;
}
close F;