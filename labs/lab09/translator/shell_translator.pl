#!/usr/bin/perl -w
$shell_file = $ARGV[0];
open my $f, '<', $shell_file or die "$0: can't open $shell_file\n";
@lines = <$f>;
close $f;

print("#!/usr/bin/perl -w\n");
foreach $line (@lines) {
    if ($line !~ /^#!/) {
        if ($line =~ /^#/) {
            print("$line");
        } else {
            $line = parser($line);
            print($line);
            print(";\n") if ($line !~ /[{}}]$/ and $line !~ /^\s*$/);
        }
    }
}

sub parser {
    my $input = $_[0];
    
    # assignment statement
    if ((my $a_indent, my $l_expr, my $r_expr) = $input =~ /^(\s*)(\w+)=([^=].*)$/) {
        return $a_indent.parser($l_expr, 0)." = ".parser($r_expr, 1);
    }
    # while statement
    elsif ((my $w_indent, my $w_expr) = $input =~ /^(\s*)while (.*)$/) {
        return $w_indent."while (".parser($w_expr).") {";
    }
    # if statement
    elsif ((my $i_indent, my $i_expr) = $input =~ /^(\s*)if (.*)$/) {
        return $i_indent."if (".parser($i_expr).") {";
    }
    # elif statement
    elsif ((my $ei_indent, my $ei_expr) = $input =~ /^(\s*)elif (.*)$/) {
        return $ei_indent."} elsif (".parser($ei_expr).") {";
    }
    # (()) statement
    elsif ((my $c_expr) = $input =~ /^\$?\(\((.*)\)\)$/) {
        return parser($c_expr);
    }
    # binary operators
    elsif ((my $expr0, my $op,my $expr1) = $input =~ /^(.+) ([\+\-\*\/\>\<\%]|>=|<=|==|!=) (.+)$/) {
        return parser($expr0, 0)." $op ".parser($expr1, 0);
    }
    # assignment statement expr
    elsif (@_ > 1) {
        my $expr_type = $_[1];
        # left value expr
        if ($expr_type==0) {
            # scalar cannot start with digitals
            if ($input =~ /^(\d+)$/) {
                return "$input";
            }
            # is simple a scalar
            elsif ($input =~ /^(\w+)$/) {
                return "\$$input";
            } else {
                return parser($input);
            }
        }
        # right value expr
        else {
            # is simple a scalar
            if ($input =~ /^(\$\w+)$/) {
                return "$input";
            } else {
                return parser($input);
            }
        }
    }
    #  token
    elsif ((my $t_indent, my $token, my $others) = $input =~ /^(\s*)(\w+)\s(.*)$/) {
        if ("do" eq $token) {
            return "\n";
        }
        elsif ("done" eq $token) {
            return "$t_indent}\n";
        }
        elsif ("then" eq $token) {
            return "\n";
        }
        elsif ("else" eq $token) {
            return "$t_indent} else {\n";
        }
        elsif ("fi" eq $token) {
            return "$t_indent}\n";
        }
        elsif ("echo" eq $token) {
            return $t_indent."print \"$others\\n\"";
        }
        # theoretically, we'll never be here
        else {
            print("theoretically, we'll never be here\n");
            return "$token";
        }
    }
    else {
        return $input;
    }
}