#!/usr/bin/perl -w
open F, '<', $ARGV[0] or die;
@lines = <F>;
close F;
if (@lines) {
    $n = @lines;
    $half = $n / 2;
    if ($n % 2 == 0) {
        print("$lines[$half - 1]");
        print("$lines[$half]");
    } else {
        print("$lines[$half]");
    }
}