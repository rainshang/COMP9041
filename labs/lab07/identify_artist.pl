#!/usr/bin/perl -w
$debug = 0;
%file_lyricwords = ();

# read artist lyrics into arrays seperately
sub initArtistData {
    my $file = $_[0];
    open F, '<', $file or die "cannot open $file: $!\n";
    my @words = ();
    while ($input = <F>) {
        my $input = lc $input;
        my @line_words = $input =~ /[a-z]+/g;
        push @words, @line_words;
    }
    # read F, my $file_content, -s F;
    close F;
    @{$file_lyricwords{$file}} = @words;
}

sub getArtistByFile {
    my $file = $_[0];
    my $artist = $file;
    $artist =~ s/lyrics\/(.*)\.txt/$1/;
    $artist =~ s/_/ /g;
    return $artist;
}

# calculate the Log Probability of one word in one lyric array
sub calculateWordLogProbability {
    my $keyword = lc shift;
    my @lyricwords = @_;

    my $c_word=0;
    foreach $word (@lyricwords) {
        $c_word++ if ($word eq $keyword);
    }
    return log(($c_word + 1)/ @lyricwords);
}

# read test file into array
sub file2Words {
    my $file = $_[0];
    open F, '<', $file or die "cannot open $file: $!\n";
    read F, my $file_content, -s F;
    close F;
    my @words = $file_content =~ /[a-zA-Z]+/g;
    return @words;
}

sub calculateMostLogProbability {
    my $file = $_[0];
    my @words = file2Words($file);
    my %artist_log = ();

    foreach $word (@words) {
        foreach $key (keys %file_lyricwords) {
            @lyricwords = @{$file_lyricwords{$key}};
            $lp = calculateWordLogProbability($word, @lyricwords);
            $artist_log{$key} += $lp;
        }
    }

    my $most_log = 0;
    my $most_artist;
    foreach $key (sort { $artist_log{$b} <=> $artist_log{$a} } keys %artist_log) {
        if(!$most_log) {
            $most_log = $artist_log{$key};
            $most_artist= getArtistByFile($key);
        }
        printf "%s: log_probability of %.1f for %s\n", $file, $artist_log{$key}, getArtistByFile($key) if ($debug);
    }
    printf "%s most resembles the work of %s (log-probability=%.1f)\n", $file, $most_artist, $most_log;
}


foreach $file (glob "lyrics/*.txt") {
    initArtistData($file);
}

for ($i = 0; $i < @ARGV; $i++) {
    if ($i == 0) {
        if ($ARGV[$i] eq '-d') {
            $debug = 1;
            next;
        }
    }
    calculateMostLogProbability($ARGV[$i]);
}