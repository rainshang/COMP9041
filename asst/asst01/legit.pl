#!/usr/bin/perl -w
use autodie;
use File::Basename;
use File::Spec::Functions;
use Digest::SHA qw(sha1_hex);

$LE_GIT_DIR = '.legit';

$LE_GIT_OBJECTS_DIR = $LE_GIT_DIR.'/objects';
$LE_GIT_REFS_DIR = $LE_GIT_DIR.'/refs';

$LE_GIT_HEAD = $LE_GIT_DIR.'/HEAD';
$LE_GIT_INDEX = $LE_GIT_DIR.'/index';

$LE_GIT_REFS_HEADS_DIR = $LE_GIT_REFS_DIR.'/heads';

$LE_GIT_OBJECT_TYPE_BLOB = 0;
$LE_GIT_OBJECT_TYPE_TREE = 1;
$LE_GIT_OBJECT_TYPE_COMMIT = 2;

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

sub splitHash {
    my ($sha1) = @_;
    my $a = substr($sha1, 0, 2);
    my $b = substr($sha1, 2);
    return ($a, $b);
}

# type data
sub hashObject {
    my ($data, $object_type, $not_write) = @_;
    my $full_data = "$object_type $data";
    my $digest = sha1_hex($full_data);
    if (!$not_write) {
        my ($a, $b) = splitHash($digest);
        if (!-d $LE_GIT_OBJECTS_DIR."/$a") {
            mkdir $LE_GIT_OBJECTS_DIR."/$a";
        }
        if (!-e $LE_GIT_OBJECTS_DIR."/$a/$b") {
            writeFile($full_data, $LE_GIT_OBJECTS_DIR."/$a/$b");
        }
    }
    return $digest;
}

sub objectExists {
    my ($sha1) = @_;
    my ($a, $b) = splitHash($sha1);
    return -e $LE_GIT_OBJECTS_DIR."/$a/$b";
}

sub readObject {
    my ($sha1) = @_;
    if (objectExists($sha1)) {
        my ($a, $b) = splitHash($sha1);
        my $full_data = readFile($LE_GIT_OBJECTS_DIR."/$a/$b");
        (my $type) = $full_data =~ /^(\w+) /;
        # read hashObject to see how to save
        my $data = substr($full_data, length($type)+1);
        return ($type, $data);
    } else {
        die "Object '$sha1' cannot found!\n";
    }
}

sub readIndex {
    if (!-e $LE_GIT_INDEX) {
        return;
    } else {
        return split("\n", readFile($LE_GIT_INDEX));
    }
}

# sha-1 conflict filename
sub writeIndex {
    my @index = @_;
    writeFile(join("\n", @index), $LE_GIT_INDEX);
}

sub writeTree {
    my @index = readIndex();
    if (@index) {
        my $data = join("\n", @index);
        # not write yet
        my $tree = hashObject($data, $LE_GIT_OBJECT_TYPE_TREE, 1);
        if (objectExists($tree)) {
            # this tree has already been written
            return;
        } else {
            return hashObject($data, $LE_GIT_OBJECT_TYPE_TREE);
        }
    } else {
        return;
    }
}

sub whichBranch {
    my $head = readFile($LE_GIT_HEAD);
    chomp $head;
    my ($branch) = $head =~ /\/(\w+)$/;
    return $branch;
}

sub getHead {
    # find which branch
    my $branch = whichBranch();
    $head = "$LE_GIT_REFS_HEADS_DIR/$branch";
    # get the head hash of this branch
    if (-e $head) {
        $head = readFile($head);
        chomp $head;
        return $head;
    } else {
        return;
    }
}

sub writeHead {
    my ($sha1) = @_;
    my $branch = whichBranch();
    $head = "$LE_GIT_REFS_HEADS_DIR/$branch";
    writeFile($sha1, $head);
}

# tree msg 0
# or
# tree msg parent version_code
sub readCommit {
    my ($sha1) = @_;
    my $commit = (readObject($sha1))[1];
    return split("\n", $commit);
}

if (@ARGV) {
    $command = $ARGV[0];
    # legit init
    if ('init' eq $command) {
        if (-d $LE_GIT_DIR) {
            die basename($0).": error: $LE_GIT_DIR already exists\n";
        } else {
            mkdir($LE_GIT_DIR) and
            mkdir($LE_GIT_OBJECTS_DIR) and
            mkdir($LE_GIT_REFS_DIR) and
            mkdir($LE_GIT_REFS_HEADS_DIR) and
            writeFile("ref: refs/heads/master\n", $LE_GIT_HEAD) and
            print("Initialized empty legit repository in $LE_GIT_DIR\n");
        }
    }
    # legit ls-files --stage
    elsif ('ls-files' eq $command) {
        checkGitDir();
        my @index = readIndex();
        if (my $option = $ARGV[1]) {
            if ('-s' eq $option or '--stage' eq $option) {
                map{print "$_\n"} @index; 
            }
        } else {
            foreach my $record (@index) {
                my $filename = (split ' ', $record)[2];
                print("$filename\n");
            }
        }
    }
    # legit.pl add <filenames...>
    elsif ('add' eq $command) {
        checkGitDir();
        die basename($0).": error: nothing added.\nMaybe you wanted to say 'git add .'?\n" if (@ARGV < 2);
        my @files = getRelativeFiles(@ARGV[1..$#ARGV]);
        my @index = readIndex();
        my @not_changed = ();
        foreach my $record (@index) {
            my ($sha_1, $conflict, $filename) = split(' ', $record);
            my $hit;
            foreach my $file (@files) {
                $hit = 1 if ($file eq $filename);
            }
            if (!$hit) {
                push(@not_changed, $record);
            }
        }
        @index = ();
        push(@index, @not_changed);
        foreach my $file (@files) {
            if ($file =~ /^[a-zA-Z0-9][a-zA-Z0-9.-_]*/) {
                $sha1 = hashObject(readFile($file), $LE_GIT_OBJECT_TYPE_BLOB);
                my $record = "$sha1 0 $file";
                push(@index, $record);
            } else {
                die basename($0).": error: invalid filename '$file'\n";
            }
        }
        writeIndex(@index);
    }
    # legit.pl commit [-a] -m <message>
    elsif ('commit' eq $command) {
        checkGitDir();
        my $msg;
        my $a_mode;
        if (@ARGV == 3 and '-m' eq $ARGV[1]) {
            $msg = $ARGV[2];
        }
        elsif (@ARGV == 4 and '-a' eq $ARGV[1] and '-m' eq $ARGV[2]) {
            $a_mode = 1;
            $msg = $ARGV[3]; 
        }
        else {
            die "usage: legit.pl commit [-a] -m commit-message\n";
        }
        my $tree = writeTree();
        if ($tree) {
            # tree msg parent version_code
            my $parent = getHead();
            my $data = "$tree\n$msg\n";
            my $version;
            if ($parent) {
                my @parent = readCommit($parent);
                $version = 1;
                $version += $parent[3] if (@parent == 4);
                $data = "$data\n$parent\n$version";
            } else {
                $version = 0;
                $data = "$data\n$version";
            }
            my $commit = hashObject($data, $LE_GIT_OBJECT_TYPE_COMMIT);
            writeHead($commit);
            print("Committed as commit $version\n");
        } else {
            die "nothing to commit\n";
        }
    }
    elsif ("test" eq $command) {
    }
}