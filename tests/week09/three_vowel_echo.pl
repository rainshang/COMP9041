#!/usr/bin/perl -w
foreach my $word (@ARGV) {
    print("$word ") if ($word =~ /[aeiouAEIOU]{3}/);
}
print("\n");