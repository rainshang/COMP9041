#!/usr/bin/perl -w
$file = $ARGV[0];
open F, '<', $file or die "cannot open $file: $!\n";
@lines = ();
while($input = <F>) {
    $input =~ s/\d/#/g;
    push(@lines, $input);
}
close F;
open F, '>', $file or die "cannot open $file: $!\n";
foreach $line (@lines) {
    print F $line;
}
close F;