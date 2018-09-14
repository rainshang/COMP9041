#!/usr/bin/perl -w
$url_post = 'http://legacy.handbook.unsw.edu.au/postgraduate/courses/2018/';
$url_under = 'http://legacy.handbook.unsw.edu.au/undergraduate/courses/2018/';
$suffix = '.html';
$course = $ARGV[0];
$course =~ tr/a-z/A-Z/;

%pre_courses = ();

$url = "$url_post"."$course".$suffix;
wget_parse();
$url = "$url_under"."$course".$suffix;
wget_parse();

foreach $pre_course (sort keys %pre_courses) {
    print "$pre_course\n";
}

sub wget_parse {
    open F, "wget -q -O- $url|" or die;
    while ($line = <F>) {
        chomp $line;
        if($line =~ /<meta name="DC.Title" content="404 Page Not Found">/) {
            last;
        }
        if($line =~ /<p>Prerequisites?:/) {
            $line =~ s/<p>.*Prerequisites?: //;
            $line =~ s/<\/p>.*//;

            foreach $word (split(/([A-Z]{4}\d{4})/, $line)) {
                if($word =~ /([A-Z]{4}\d{4})/) {
                    $pre_courses{$word}++;
                }
            }
            last;
        }
    }
    close F;
}

