#!/usr/bin/perl -w
use File::Basename;

$LE_GIT_DIR = ".legit";

$LE_GIT_OBJECTS_DIR = $LE_GIT_DIR."/objects";
$LE_GIT_REFS_DIR = $LE_GIT_DIR."/refs";

$LE_GIT_REFS_HEADS_DIR = $LE_GIT_REFS_DIR."/heads";

sub string2file {
    my ($string, $file) = @_;
    open(my $fh, '>', $file) or die;
    print $fh $string;
    close $fh;
}


sub checkGitDir {
    if (!-d $LE_GIT_DIR) {
        die basename($0).": error: no $LE_GIT_DIR directory containing legit repository exists\n";
    }
}


if (@ARGV == 1) {
    if ("init" eq $ARGV[0]) {
        if (-d $LE_GIT_DIR) {
            die basename($0).": error: $LE_GIT_DIR already exists\n";
        } else {
            mkdir($LE_GIT_DIR) and
            mkdir($LE_GIT_OBJECTS_DIR) and
            mkdir($LE_GIT_REFS_DIR) and
            mkdir($LE_GIT_REFS_HEADS_DIR) and
            string2file("ref: refs/heads/master\n", $LE_GIT_DIR."/HEAD") and
            print("Initialized empty legit repository in $LE_GIT_DIR\n");
        }
    }
} elsif (@ARGV >= 1) {
    checkGitDir();
    $n = @ARGV;
    print("$n\n")
}