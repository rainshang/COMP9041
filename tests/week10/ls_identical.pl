#!/usr/bin/perl -w
foreach my $file1 (sort { $a cmp $b } (glob "$ARGV[0]/*")) {
    foreach my $file2 (sort { $a cmp $b } (glob "$ARGV[1]/*")) {
        my $file_name1 = (split(/\//, $file1))[1];
        my $file_name2 = (split(/\//, $file2))[1];
        if ($file_name1 eq $file_name2) {
            open F, '<', $file1;
            read F, my $content1, -s F;
            close F;
            open F, '<', $file2;
            read F, my $content2, -s F;
            close F;
            if ($content1 eq $content2) {
                print("$file_name1\n");
            }
        }
    }
}