#!/usr/bin/perl -w
open F, '<', $ARGV[1] or die "$0: Can't open $ARGV[1]: $!\n";
$podCount = 0;
$individualCount = 0;
while ($input = <F>) {
    $input =~ s/^(\d\d\/){2}\d\d //;
    $hit = $input =~ s/ $ARGV[0]$//;
    if($hit) {
        $podCount++;
        $individualCount += $input;
    }
}
close F;
print "$ARGV[0] observations: $podCount pods, $individualCount individuals\n";