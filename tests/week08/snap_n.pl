#!/usr/bin/perl -w
$n = $ARGV[0];
%dict = ();
while($line = <STDIN>) {
    $dict{$line}++;
    if ($dict{$line} == $n) {
        print("Snap: $line");
        exit;
    }
}