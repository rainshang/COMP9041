#!/usr/bin/perl -w
sub readFile2String {
    open F, '<', $_[0] or die "cannot open $_[0]: $!\n";
    read F, my $file_content, -s F;
    close F;
    return $file_content;
}

if(@ARGV < 2) {
    print("Usage: $0 <files>");
} else {
    $previous_file_content = '';
    $all_pass = 1;
    for($i = 0; $i < @ARGV; $i++) {
        if ($i == 0) {
            $previous_file_content = readFile2String($ARGV[$i]);
        } else {
            my $current_file_content = readFile2String($ARGV[$i]);
            if ($current_file_content ne $previous_file_content) {
                print("$ARGV[$i] is not identical\n");
                $all_pass = 0;
                last;
            }
            $previous_file_content = $current_file_content;
        }
    }
    print("All files are identical\n") if ($all_pass);
}
