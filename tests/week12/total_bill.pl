#!/usr/bin/perl -w
$sum = 0;
while($line = <>) {
    my ($price) = $line =~ /\"price\": \"\$([\d\.]+)\"/g;
    if ($price) {
        $sum += $price;
    }
}
printf "\$%.2f\n", $sum;