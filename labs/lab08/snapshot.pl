#!/usr/bin/perl -w
use File::Copy;

# return the latest version to save
sub getVersion {
    opendir(my $dh, './');
    my @versions = ();
    while (my $item = readdir($dh)) {
        my $version = $item;
        if(-d $item
            and $version =~ s/\.snapshot\.([\d]+)/$1/) {
            push @versions, $version;
        }
    }
    closedir $dh;
    
    if(@versions > 0) {
        @versions = sort {$b <=> $a} @versions;
        return $versions[0] + 1;
    } else {
        return 0;
    }
}

sub save {
    $version = getVersion();
    $tmp_dir = ".snapshot._$version";
    mkdir $tmp_dir;
    foreach $item (glob './*') {
        if(-f $item
            and $item ne $0) {
            copy($item, "$tmp_dir/$item");
            }
    }
    rename $tmp_dir, ".snapshot.$version";
    print("Creating snapshot $version\n");
}

$method = $ARGV[0];
if ('save' eq $method) {
    save();
} elsif ('load' eq $method) {
    $n = $ARGV[1];
    $dir = ".snapshot.$n/";
    if (-d $dir) {
        save();
        foreach $item (glob "$dir*") {
            $file = $item;
            $file =~ s/$dir//;
            copy($item, $file);
        }
        print("Restoring snapshot $n\n");
    } else {
        die "Snapshot $n does not exist.\n";
    }
} else {
    die "Illegal method called.\n";
}