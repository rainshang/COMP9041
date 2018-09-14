#!/usr/bin/perl -w
use File::Basename;
use File::Copy;

$filepath=$ARGV[0];
my($filename, $dir) = fileparse($filepath);

opendir(my $dh, $dir) or die "Can't opendir $dir: $!";
@versions = ();
while (my $file = readdir($dh)) {
    my $version = $file;
    if($version =~ s/\.$filename\.([\d]+)/$1/) {
        push @versions, $version;
    }
}
closedir $dh;

if(@versions > 0) {
    @versions = sort {$b <=> $a} @versions;
    $max_version = $versions[0] + 1;
} else {
    $max_version = 0;
}

copy($filepath, "$dir/.$filename.$max_version");
if($dir eq './') {
    print "Backup of '$filepath' saved as '.$filename.$max_version'\n";
} else {
    print "Backup of '$filepath' saved as '$dir/.$filename.$max_version'\n";
}