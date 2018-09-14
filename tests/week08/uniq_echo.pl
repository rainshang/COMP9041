#!/usr/bin/perl -w
%dict = ();
$index = 1;
foreach $argv (@ARGV) {
    if (!$dict{$argv}) {
        $dict{$argv} = $index;
    }
    $index++;
}
foreach $key (sort {$dict{$a} <=> $dict{$b}} keys %dict) {
    print("$key ");
}
print("\n");