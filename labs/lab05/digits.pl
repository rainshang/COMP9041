#!/usr/bin/perl -w
while ($input = <>) {
    @chars = split(//, $input);
    foreach $char (@chars) {
        if ($char eq '0'
            || $char eq '1'
            || $char eq '2'
            || $char eq '3'
            || $char eq '4') {
            print '<';
        }
        elsif ($char eq '6'
                || $char eq '7'
                || $char eq '8'
                || $char eq '9') {
            print '>';
        }
        else {
            print $char;
        }
    }
}