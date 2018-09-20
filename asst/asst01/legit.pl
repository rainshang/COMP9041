#!/usr/bin/perl -w
use autodie;
use File::Basename;
use File::Spec::Functions;
use Digest::SHA qw(sha1_hex);
use experimental 'smartmatch';

$LE_GIT_DIR = ".legit";

$LE_GIT_OBJECTS_DIR = $LE_GIT_DIR."/objects";
$LE_GIT_REFS_DIR = $LE_GIT_DIR."/refs";
$LE_GIT_INDEX = $LE_GIT_DIR."/index";

$LE_GIT_REFS_HEADS_DIR = $LE_GIT_REFS_DIR."/heads";

sub writeFile {
    my ($data, $file) = @_;
    open my $fh, '>', $file;
    print $fh $data;
    close $fh;
}

sub readFile {
    my ($file) = @_;
    open my $fh, '<', $file;
    read $fh, my $data, -s $fh;
    close $fh;
    return $data;
}

sub checkGitDir {
    if (!-d $LE_GIT_DIR) {
        die basename($0).": error: no $LE_GIT_DIR directory containing legit repository exists\n";
    }
}

sub getRelativeFiles {
    my @files = @_;
    my @r_files = ();
    foreach my $file (@files) {
        my $r_file = catfile($file);
        if ($r_file !~ /\.\./) {
            push @r_files, $r_file;
        } else {
            # cannot be out of respository
            die basename($0).": error: invalid filename '$file'\n";
        }
    }
    return @r_files;
}

sub readIndex {
    if (!-e $LE_GIT_INDEX) {
        return;
    } else {
        open my $fh, '<', $LE_GIT_INDEX;
        my @index = ();
        while (my $line = <$fh>) {
            chomp $line;
            push @index, $line;
        }
        close $fh; 
        return @index;
    }
}

# sha-1 conflict filename
sub writeIndex {
    my @index = @_;
    open my $fh, '>', $LE_GIT_INDEX;
    foreach my $record (@index) {
        print $fh "$record\n";
    }
    close $fh;
}

sub hashObject {
    my ($file) = @_;
    my $data = readFile($file);
    my $digest = sha1_hex($data);
    my $a = substr($digest, 0, 2);
    my $b = substr($digest, 2);
    if (!-d $LE_GIT_OBJECTS_DIR."/$a") {
        mkdir $LE_GIT_OBJECTS_DIR."/$a";
    }
    if (!-e $LE_GIT_OBJECTS_DIR."/$a/$b") {
        writeFile($data, $LE_GIT_OBJECTS_DIR."/$a/$b");
    }
    return $digest;
}

if (@ARGV) {
    $command = $ARGV[0];
    # legit init
    if ("init" eq $command) {
        if (-d $LE_GIT_DIR) {
            die basename($0).": error: $LE_GIT_DIR already exists\n";
        } else {
            mkdir($LE_GIT_DIR) and
            mkdir($LE_GIT_OBJECTS_DIR) and
            mkdir($LE_GIT_REFS_DIR) and
            mkdir($LE_GIT_REFS_HEADS_DIR) and
            writeFile("ref: refs/heads/master\n", $LE_GIT_DIR."/HEAD") and
            print("Initialized empty legit repository in $LE_GIT_DIR\n");
        }
    }
    # legit ls-files --stage
    elsif ("ls-files" eq $command) {
        checkGitDir();
        my @index = readIndex();
        if (my $option = $ARGV[1]) {
            if ("-s" eq $option or "--stage" eq $option) {
                map{print "$_\n"} @index; 
            }
        } else {
            foreach my $record (@index) {
                my $filename = (split / /, $record)[2];
                print("$filename\n");
            }
        }
    }
    # legit.pl add <filenames>
    elsif ("add" eq $command) {
        checkGitDir();
        die basename($0).": error: nothing added.\nMaybe you wanted to say 'git add .'?\n" if (@ARGV < 2);
        my @files = getRelativeFiles(@ARGV[1..$#ARGV]);
        my @index = readIndex();
        my @not_changed = ();
        foreach my $record (@index) {
            my ($sha_1, $conflict, $filename) = split(/ /, $record);
            if ($filename !~ @files) {
                push(@not_changed, $record);
            }
        }
        @index = ();
        push(@index, @not_changed);
        foreach my $file (@files) {
            if ($file =~ /^[a-zA-Z0-9][a-zA-Z0-9.-_]*/) {
                $sha1 = hashObject($file);
                my $record = "$sha1 0 $file";
                push(@index, $record);
            } else {
                die basename($0).": error: invalid filename '$file'\n";
            }
        }
        writeIndex(@index);
    }
}