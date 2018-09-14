#!/usr/bin/perl -w
while($input = <>) {
    $input =~ s/\s+/ /g;
    @words = split(' ', $input);
    @words = sort @words;
    print("@words\n");
}