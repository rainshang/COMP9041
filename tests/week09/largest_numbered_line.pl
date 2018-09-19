#!/usr/bin/perl -w
$largest_number = 0;
@largest_number_lines = ();
while ($line = <>) {
    if (my @numbers = $line =~ /(-?\d*\.\d+|-?\d+)/g) {
        if (@numbers) {
            @numbers = sort {$b <=> $a} @numbers;
            my $c_largest_number = $numbers[0];
            if (@largest_number_lines and $largest_number) {
                if ($largest_number < $c_largest_number) {
                    $largest_number = $c_largest_number;
                    @largest_number_lines = ();
                    push @largest_number_lines, $line;
                } elsif ($largest_number == $c_largest_number) {
                    push @largest_number_lines, $line;
                }
            } else {
                $largest_number = $c_largest_number;
                push @largest_number_lines, $line;
            }
        }
    }
}
print(@largest_number_lines);