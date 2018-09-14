#!/usr/bin/perl -w
$keyword = lc $ARGV[0];
$i = 0;
while ($input = <STDIN>) {
    @words = $input =~ /[a-zA-Z]+/g;
    foreach $word (@words) {
        $word = lc $word;
        $i++ if ($word eq $keyword);
    }
}
print("$ARGV[0] occurred $i times\n");