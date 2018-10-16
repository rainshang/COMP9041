#!/usr/bin/perl -w
open F, '<', $ARGV[1];
read F, my $json, -s F;
close F;
my @how_manys = $json =~ /\"how_many\": (\d*),\s*\"species\": \"$ARGV[0]\"/g;
my $sum = 0;
foreach my $how_many (@how_manys) {
    $sum += $how_many;
}
print "$sum\n";