#!/usr/bin/perl -w
sub countWordWords {
    $keyword = lc $_[0];
    $file = $_[1];
    open F, '<', $file or die "cannot open $file: $!\n";
    $c_word = 0;
    $c_words = 0;
    while ($input = <F>) {
        @words = $input =~ /[a-zA-Z]+/g;
        foreach $word (@words) {
            $word = lc $word;
            $c_word++ if ($word eq $keyword);
        }
        $c_words += @words;
    }
    return "$c_word,$c_words";
}

foreach $file (glob "lyrics/*.txt") {
    ($word, $words) = split(',', countWordWords($ARGV[0], $file));
    $artist = $file;
    $artist =~ s/lyrics\/(.*)\.txt/$1/;
    $artist =~ s/_/ /g;
    printf "log((%d+1)/%6d) = %8.4f %s\n", $word, $words, log(($word + 1)/ $words), $artist;
}