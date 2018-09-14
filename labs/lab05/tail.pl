#!/usr/bin/perl -w
$n = 10;

sub Readlines_and_tail {
    my $n_args = @_;
    my @lines;
    if ($n_args == 0) {
        while ($input = <>) {
            push @lines, $input;
        }
    } elsif ($n_args == 1) {
        my $file = $_[0];
        open F, '<', $file or die "$0: Can't open $file: $!\n";
        while ($input = <F>) {
            push @lines, $input;
        }
        close F;
    }
    if (@lines < $n) {
        print @lines;
    } else {
        print @lines[-$n..-1];
    }
}



if (@ARGV == 0) {
    Readlines_and_tail();
} else {
    foreach $arg (@ARGV) {
        if ($arg =~ /-\d+/) {
            $n = substr($arg, 1);
        } else {
            push @files, $arg;
        }
    }
    if (@files == 1) {
        $file = $files[0];
        Readlines_and_tail($file);
    } elsif (@files > 1) {
        foreach $file (@files) {
            print "==> $file <==\n";
            Readlines_and_tail($file);
        }
    }
}