#!/usr/bin/perl -w
print("#!/usr/bin/perl -w\n");
print("print(\"");

@arg = ();
for my $c (split //, $ARGV[0]) {
    if ($c =~ /[\.\$\^\{\[\(\|\)\*\+\?\\\'\"]/) {
        push @arg, "\\$c";
    } else {
        push @arg, $c;
    }
}
print(@arg);

print("\\n\");");