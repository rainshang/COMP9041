#!/usr/bin/perl -w
open F, '<', $ARGV[0] or die "$0: Can't open $ARGV[0]: $!\n";
$count = 0;
while ($input = <F>) {
    $input =~ s/^(\d\d\/){2}\d\d //;
    $hit = $input =~ s/ Orca$//;
    if($hit) {
        $count += $input;
    }
}
close F;
print "$count Orcas reported in $ARGV[0]\n";
