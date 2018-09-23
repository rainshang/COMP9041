#!/usr/bin/perl -w
use File::Basename;
use File::Spec::Functions;
use Digest::SHA qw(sha1_hex);

$LE_GIT_DIR = '.legit';

$LE_GIT_OBJECTS_DIR = $LE_GIT_DIR.'/objects';
$LE_GIT_REFS_DIR = $LE_GIT_DIR.'/refs';

$LE_GIT_HEAD = $LE_GIT_DIR.'/HEAD';
$LE_GIT_INDEX = $LE_GIT_DIR.'/index';
$LE_GIT_LATEST_COMMIT_CODE = $LE_GIT_DIR.'/latest';

$LE_GIT_REFS_HEADS_DIR = $LE_GIT_REFS_DIR.'/heads';

$LE_GIT_OBJECT_TYPE_BLOB = 0;
$LE_GIT_OBJECT_TYPE_TREE = 1;
$LE_GIT_OBJECT_TYPE_COMMIT = 2;

sub writeFile {
    my ($data, $file) = @_;
    open my $fh, '>', $file or die basename($0).": error: can not open '$file'\n";
    print $fh $data;
    close $fh;
}

sub readFile {
    my ($file) = @_;
    open my $fh, '<', $file or die basename($0).": error: can not open '$file'\n";
    read $fh, my $data, -s $fh;
    close $fh;
    return $data;
}

sub checkGitDir {
    if (!-d $LE_GIT_DIR) {
        die basename($0).": error: no $LE_GIT_DIR directory containing legit repository exists\n";
    }
}

sub normalizeFiles {
    my @files = @_;
    my @r_files = ();
    foreach my $file (@files) {
        if ($file !~ /^\/?([\w.-]+\/)*[a-zA-Z0-9][\w.-]*$/) {
            die basename($0).": error: invalid filename '$file'\n";
        } else {
            my $r_file = catfile($file);
            if ($r_file !~ /\.\./) {
                push @r_files, $r_file;
            } else {
                # cannot be out of respository
                die basename($0).": error: invalid filename '$file'\n";
            }
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
    my $data = join("\n", readIndex());
    return hashObject($data, $LE_GIT_OBJECT_TYPE_TREE);
}

sub readTree {
    my ($sha1) = @_;
    my $data = (readObject($sha1))[1];
    return split("\n", $data);
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

# sha1 conflict file
sub addFiles {
    my @files = @_;
    my @index = readIndex();
    my @not_changed = ();
    foreach my $record (@index) {
        my ($sha1, $conflict, $filename) = split(' ', $record);
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
        if (isNewFile($file) or -e $file) {
            my $sha1 = hashObject(readFile($file), $LE_GIT_OBJECT_TYPE_BLOB);
            my $record = "$sha1 0 $file";
            push(@index, $record);
        }
    }
    writeIndex(@index);
}

# backtrack to check file has been commited in history
sub isNewFile {
    my ($file) = @_;
    my $is_new = 1;
    my $head = getHead();
    return $is_new if (!$head);

    my $parent = $head;
    while ($parent) {
        my @parent = readCommit($parent);
        my @his_commit = split("\n", (readObject($parent[0]))[1]);
        my $sha1_his_commit = findFileHashInTree($file, @his_commit);
        if ($sha1_his_commit) {
            $is_new = 0;
            last;
        } else {
            if (@parent == 4) {
                $parent = $parent[2];
            } else {
                $parent = undef;
            }
        }
    }
    return $is_new;
}

sub findFileHashInTree {
    my ($filename, @tree) = @_;
    foreach $record (@tree) {
        my ($sha1, $conflict, $file) = split / /, $record;
        if ($file eq $filename) {
            return $sha1;
        }
    }
    return;
}

sub showMan {
    print 
"Usage: legit.pl <command> [<args>]\n
These are the legit commands:
    init       Create an empty legit repository
    add        Add file contents to the index
    commit     Record changes to the repository
    log        Show commit log
    show       Show file at particular state
    rm         Remove files from the current directory and from the index
    status     Show the status of files in the current directory, index, and repository
    branch     list, create or delete a branch
    checkout   Switch branches or restore current directory files
    merge      Join two development histories together\n\n"
}

sub lsDirFiles {
    my ($dir) = @_;
    opendir my($dh), $dir;
    my @files = ();
    while (readdir $dh) {
        if ('.' ne $_ and '..' ne $_ and $LE_GIT_DIR ne $_) {
            my $path = $_;
            $path = "$dir/$path" if ('.' ne $dir);
            if (-d $path) {
                push @files, lsDirFiles($path);
            } elsif ($_ =~ /^[a-zA-Z0-9][\w.-]*$/) {
                push @files, $path;
            }
        }
    }
    closedir $dh;
    return @files;
}

sub getAllBranches {
    my @branch_ref = lsDirFiles($LE_GIT_REFS_HEADS_DIR);
    return sort map {substr($_, length($LE_GIT_REFS_HEADS_DIR) + 1)} @branch_ref;
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
        addFiles(normalizeFiles(@ARGV[1..$#ARGV]))
    }
    # legit.pl commit [-a] -m <message>
    elsif ('commit' eq $command) {
        checkGitDir();
        my $msg;
        if (@ARGV == 3 and '-m' eq $ARGV[1]) {
            $msg = $ARGV[2];
        }
        elsif (@ARGV == 4 and '-a' eq $ARGV[1] and '-m' eq $ARGV[2]) {
            $msg = $ARGV[3];
            my @index = readIndex();
            my @files = ();
            foreach my $record (@index) {
                my $filename = (split ' ', $record)[2];
                push @files, $filename;
            }
            addFiles(@files);
        }
        else {
            die "usage: legit.pl commit [-a] -m commit-message\n";
        }

        my $tree = writeTree();
        my $parent = getHead();
        # tree msg parent version_code
        my $data = "$tree\n$msg";
        my $version;
        if ($parent) {
            my @parent = readCommit($parent);
            die "nothing to commit\n" if ($tree eq $parent[0]);
            $version = readFile($LE_GIT_LATEST_COMMIT_CODE);
            chomp $version;
            $version++;
            $data = "$data\n$parent\n$version";
        } else {
            $version = 0;
            $data = "$data\n$version";
        }
        my $commit = hashObject($data, $LE_GIT_OBJECT_TYPE_COMMIT);
        writeHead($commit);
        writeFile($version, $LE_GIT_LATEST_COMMIT_CODE);
        print("Committed as commit $version\n");
    }
    # legit.pl log
    elsif ('log' eq $command) {
        checkGitDir();
        my $parent = getHead();
        while ($parent) {
            my @parent = readCommit($parent);
            if (@parent == 4) {
                print("$parent[3] $parent[1]\n");
                $parent = $parent[2];
            } else {
                print("$parent[2] $parent[1]\n");
                $parent = undef;
            }
        }
    }
    # legit.pl show <commit>:<filename>
    elsif ('show' eq $command) {
        checkGitDir();
        if (@ARGV == 2 and my ($commit, $filename) = $ARGV[1] =~ /^(\d*):(.+)$/) {
            ($filename) = normalizeFiles(($filename));
            if ($commit =~ /\d+/) {
                my $parent = getHead();
                while ($parent) {
                    my @parent = readCommit($parent);
                    my $version_code;
                    if (@parent == 4) {
                        $version_code = $parent[3];
                    } else {
                        $version_code = $parent[2];
                    }
                    if ($version_code == $commit) {
                        my $tree = $parent[0];
                        my @tree = readTree($tree);
                        foreach $record (@tree) {
                            my ($sha1, $conflict, $file) = split / /, $record;
                            if ($file eq $filename) {
                                print((readObject($sha1))[1]);
                                exit 0;
                            }
                        }
                        die basename($0).": error: '$filename' not found in commit $commit\n";
                    } else {
                        if (@parent == 4) {
                            $parent = $parent[2];
                        } else {
                            $parent = undef;
                        }
                    }
                }
                die basename($0).": error: unknown commit '$commit'\n";
            } else {
                my $sha1 = findFileHashInTree($filename, readIndex());
                if ($sha1) {
                    print((readObject($sha1))[1]);
                } else {
                    die basename($0).": error: '$filename' not found in index\n";
                }
            }
        } else {
            die "usage: legit.pl show <commit>:<filename>\n";
        }
    }
    # legit.pl rm [--force] [--cached] <filenames...>
    elsif ('rm' eq $command) {
        checkGitDir();
        if (@ARGV > 1) {
            my $force;
            my $cached;
            my $file_starts = 1;
            if ('--force' eq $ARGV[1] or '--cached' eq $ARGV[1]) {
                if ('--force' eq $ARGV[1]) {
                    $force = 1;
                    if ($ARGV[2] and '--cached' eq $ARGV[2]) {
                        $cached = 1;
                        $file_starts = 3;
                    } else {
                        $file_starts = 2;
                    }
                } else {
                    $cached = 1;
                    if ($ARGV[2] and '--force' eq $ARGV[2]) {
                        $force = 1;
                        $file_starts = 3;
                    } else {
                        $file_starts = 2;
                    }
                }
            }
            if ($file_starts < @ARGV) {
                my $a = @ARGV;
                my $head = getHead();
                if ($head) {
                    my @files = normalizeFiles(@ARGV[$file_starts..$#ARGV]);
                    my @file_i_index = ();# the position of file in index
                    my @index = readIndex();
                    if (@index) {
                        # check all files in index first and save their positions
                        my @index_files = ();
                        foreach my $record (@index) {
                            my $filename = (split(' ', $record))[2];
                            push @index_files, $filename;
                        }
                        foreach my $file (@files) {
                            my $hit;
                            for (my $i = 0; $i < @index_files; $i++) {
                                if ($index_files[$i] eq $file) {
                                    $hit = 1;
                                    push @file_i_index, $i;
                                    last;
                                }
                            }
                            die basename($0).": error: '$file' is not in the legit repository\n" if (!$hit);
                        }

                        if (!$force) {
                            my @last_commit = split("\n", (readObject((readCommit($head))[0]))[1]);
                            for (my $i = 0; $i < @files; $i++) {
                                my $file = $files[$i];
                                my $sha1 = -e $file ? hashObject(readFile($file), $LE_GIT_OBJECT_TYPE_BLOB, 1) : undef;
                                my $sha1_index = (split(' ', $index[$file_i_index[$i]]))[0];
                                my $sha1_commit = findFileHashInTree($file, @last_commit);
                                if ($sha1) {
                                    if ($sha1_commit) {
                                        if ($sha1_index ne $sha1 and $sha1_index ne $sha1_commit) {
                                            die basename($0).": error: '$file' in index is different to both working file and repository\n";
                                        }
                                        if ($sha1_index ne $sha1_commit) {
                                            die basename($0).": error: '$file' has changes staged in the index\n" if (!$cached);
                                        }
                                        if ($sha1_commit ne $sha1) {
                                            die basename($0).": error: '$file' in repository is different to working file\n" if !$cached;
                                        }
                                    } else {
                                        if ($sha1_index ne $sha1) {
                                            die basename($0).": error: '$file' in index is different to both working file and repository\n";
                                        }

                                        # backtrack to check file has been commited in history
                                        my $is_new = isNewFile($file);
                                        die basename($0).": error: '$file' has changes staged in the index\n" if (!$is_new or !$cached);
                                    }
                                }
                            }
                        }

                        for (my $i = 0; $i < @files; $i++) {
                            undef $index[$file_i_index[$i]];
                            unlink $files[$i] if !$cached;
                        }
                        @index = grep { defined($_) } @index;
                        writeIndex(@index);
                    } else {
                        die basename($0).": error: '$files[0]' is not in the legit repository\n";
                    }
                } else {
                   die basename($0).": error: your repository does not have any commits yet\n";
                }
            } else {
                    # no filenames
                    die "usage: legit.pl rm [--force] [--cached] <filenames...>\n";
            }
        } else {
            # no filenames
            die "usage: legit.pl rm [--force] [--cached] <filenames...>\n";
        }
    }
    # legit.pl status
    elsif ('status' eq $command) {
        checkGitDir();
        my $head = getHead();
        if ($head) {
            my @last_commit = split("\n", (readObject((readCommit($head))[0]))[1]);
            my @index = readIndex();
            my @files = lsDirFiles('.');

            # add all files in the current directory, index, and repository; sort
            my %all_files = ();
            foreach my $file (@files) {
                $all_files{$file} = 1;
            }
            foreach my $i_record (@index) {
                my ($sha1, $conflict, $file) = split / /, $i_record;
                $all_files{$file} = 1;
            }
            foreach my $h_record (@last_commit) {
                my ($sha1, $conflict, $file) = split / /, $h_record;
                $all_files{$file} = 1;
            }
            my @all_files = (sort {$a cmp $b} keys %all_files);
            foreach my $file (@all_files) {
                my $sha1 = -e $file ? hashObject(readFile($file), $LE_GIT_OBJECT_TYPE_BLOB, 1) : undef;
                my $sha1_index = @index ? findFileHashInTree($file, @index): undef;
                my $sha1_commit = findFileHashInTree($file, @last_commit);
                if ($sha1 and $sha1_index and $sha1_commit) {
                    if ($sha1_index eq $sha1
                        and $sha1_index eq $sha1_commit) {
                        print "$file - same as repo\n";
                    } elsif ($sha1_index eq $sha1) {
                        print "$file - file changed, changes staged for commit\n";
                    } elsif ($sha1_index eq $sha1_commit) {
                        print "$file - file changed, changes not staged for commit\n";
                    } else {
                        print "$file - file changed, different changes staged for commit\n";
                    }
                } elsif ($sha1 and $sha1_index) {
                    print "$file - added to index\n";
                } elsif ($sha1 and $sha1_commit) {
                     print "$file - untracked\n";
                } elsif ($sha1_index and $sha1_commit) {
                    if ($sha1_index eq $sha1_commit) {
                        print "$file - file deleted\n";
                    } else {
                        print "$file - added to index\n";
                    }
                } elsif ($sha1) {
                     print "$file - untracked\n";
                } elsif ($sha1_index) {
                    print "$file - added to index\n";
                } elsif ($sha1_commit) {
                    print "$file - deleted\n";
                } else {
                    # theoretically, we'll never be here
                }
            }
        } else {
            die basename($0).": error: your repository does not have any commits yet\n";
        }
    }
    # legit.pl branch [-d] [<branch-name>]
    elsif ('branch' eq $command) {
        checkGitDir();
        my $head = getHead();
        if ($head) {
            if (@ARGV == 1) {
                my @branches = getAllBranches();
                foreach my $branch (@branches) {
                    print "$branch\n";
                }
            }
            # legit.pl: error: branch 'b1' already exists
            elsif (@ARGV == 2) {
                die basename($0).": error: branch name required\n" if ('-d' eq $ARGV[1]);
                my $branch_name = $ARGV[1];
                my @branches = getAllBranches();
                foreach my $branch (@branches) {
                    die basename($0).": error: branch '$branch' already exists\n" if ($branch_name eq $branch);
                }
                my $branch = whichBranch();
                writeFile($head, "$LE_GIT_REFS_HEADS_DIR/$branch_name");
            }
            elsif (@ARGV == 3) {
                if ('-d' eq $ARGV[1] and my $branch_name = $ARGV[2]) {
                    my $current_branch = whichBranch();
                    if ($current_branch ne $branch_name) {
                        my @branches = getAllBranches();
                        foreach my $branch (@branches) {
                            if ($branch_name eq $branch) {
                                unlink "$LE_GIT_REFS_HEADS_DIR/$branch";
                                print "Deleted branch '$branch_name'\n";
                                exit 0;
                            }
                        }
                    } else {
                        die basename($0).": error: can not delete branch '$branch_name'\n";
                    }
                    die basename($0).": error: branch '$branch_name' does not exist\n";
                } else {
                    die "usage: legit.pl branch [-d] <branch>\n";
                }
            }
            else {
                die "usage: legit.pl branch [-d] <branch>\n";
            }
        } else {
            die basename($0).": error: your repository does not have any commits yet\n";
        }
    }
    # legit.pl checkout <branch-name>
    elsif ('checkout' eq $command) {
        checkGitDir();
        my $head = getHead();
        if ($head) {
            if (@ARGV == 2) {
                my $branch_name = $ARGV[1];
                my $current_branch = whichBranch();
                if ($current_branch ne $branch_name) {
                    my @branches = getAllBranches();
                    foreach my $branch (@branches) {
                        if ($branch_name eq $branch) {
                            my @current_commit = split("\n", (readObject((readCommit($head))[0]))[1]);
                            my @current_committed_files = map{(split / /, $_)[2]}@current_commit;

                            my $branch_head = readFile("$LE_GIT_REFS_HEADS_DIR/$branch");
                            chomp $branch_head;
                            my @branch_commit = split("\n", (readObject((readCommit($branch_head))[0]))[1]);
                            my @branch_committed_files = ();

                            my %file2write = ();
                            my %file2overwrite = ();
                            my @file_cannot_overwrite = ();
                            foreach my $record (@branch_commit) {
                                my ($sha1, $conflict, $el0) = split / /, $record;
                                push @branch_committed_files, $el0;
                                my $hit;
                                foreach my $el1 (@current_committed_files) {
                                    if ($el0 eq $el1) {
                                        $hit = 1;
                                        $file2overwrite{$el0} = $sha1 if $head ne $branch_head;
                                        last;
                                    }
                                }
                                if (!$hit) {
                                    if (!-e $el0) {
                                        $file2write{$el0} = $sha1;
                                    } else {
                                        push @file_cannot_overwrite, $el0;
                                    }
                                }
                            }

                            if (@file_cannot_overwrite) {
                                print basename($0).": error: Your changes to the following files would be overwritten by checkout:\n";
                                foreach my $file (@file_cannot_overwrite) {
                                    print "$file\n";
                                }
                                exit 1;
                            }

                            my @file2delete = ();
                            foreach my $el0 (@current_committed_files) {
                                my $hit;
                                foreach my $el1 (@branch_committed_files) {
                                    if ($el0 eq $el1) {
                                        $hit = 1;
                                        last;
                                    }
                                }
                                push @file2delete, $el0 if !$hit;
                            }

                            while(my ($file, $sha1) = each %file2overwrite) {
                                writeFile((readObject($sha1))[1], $file);
                            }
                            addFiles((keys %file2overwrite));
                            while(my ($file, $sha1) = each %file2write) {
                                writeFile((readObject($sha1))[1], $file);
                            }
                            addFiles((keys %file2write));

                            foreach my $file (@file2delete) {
                                unlink $file;
                            }
                            # rm --force --cached
                            my @index = readIndex();
                            for (my $i = 0; $i < @index; $i++) {
                                my $ifile = (split / /, $index[$i])[2];
                                foreach my $file (@file2delete) {
                                    if ($ifile eq $file) {
                                        undef $index[$i];
                                        last;
                                    }
                                }
                            }
                            @index = grep { defined($_) } @index;
                            writeIndex(@index);

                            writeFile("ref: refs/heads/$branch_name\n", $LE_GIT_HEAD);
                            print "Switched to branch '$branch_name'\n";
                            exit 0;
                        }
                    }
                    die basename($0).": error: unknown branch '$branch_name'\n";
                } else {
                    print "Already on '$branch_name'\n";
                }
            } else {
                die "usage: legit.pl checkout <branch>\n";
            }
        } else {
            die basename($0).": error: your repository does not have any commits yet\n";
        }
    }
    elsif ('test' eq $command) {
    }
    else {
        print basename($0).": error: unknown command $command\n";
        showMan();
    }
} else {
    showMan();
}