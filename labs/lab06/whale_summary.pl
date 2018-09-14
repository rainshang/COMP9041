#!/usr/bin/perl -w
open F, '<', $ARGV[0] or die "$0: Can't open $ARGV[0]: $!\n";
%species_pod = ();
%species_individual = ();
while ($input = <F>) {
    chomp $input;
    $input =~ s/^(\d\d\/){2}\d\d +//;
    @count_names = split(/ +/, $input);
    $count = $count_names[0];
    shift(@count_names);
    $species = join(' ', @count_names);
    $species =~ tr/A-Z/a-z/;
    $species =~ s/s$//;
    $species_pod{$species}++;
    $species_individual{$species} +=$count;
}
close F;
foreach $species (sort keys %species_pod) {
    print "$species observations: $species_pod{$species} pods, $species_individual{$species} individuals\n"
}