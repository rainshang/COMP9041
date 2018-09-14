#!/usr/bin/perl -w
$i = 0;
while ($input = <>) {
    @words = $input =~ /[a-zA-Z]+/g;
    $i += @words;
}
print("$i words\n");