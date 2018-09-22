#!/bin/sh
red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 6`
reset=`tput sgr0`

print_title() {
    echo "${red}=======$1=======${reset}"
}
print_description() {
    echo "${blue}$1${reset}"
}

execute_cmd() {
    echo ${green}\$ $1${reset}
    eval $1
}


print_title 'legit.pl rm [--force] [--cached] <filenames...>'
execute_cmd './legit.pl init'

print_description '1.wrong format'
execute_cmd './legit.pl rm'
execute_cmd './legit.pl rm --force'

print_description '2.rm without any commit'
execute_cmd './legit.pl rm a'

echo
execute_cmd 'echo a line 1 > a'
execute_cmd 'echo b line 1 > b'

print_description '3.rm not tracked file'
execute_cmd './legit.pl add a'
execute_cmd "./legit.pl commit -m 'first commit'"
execute_cmd './legit.pl rm a b'
execute_cmd './legit.pl rm --force a b'
print_description 'partical failed operation should be all aborted'
execute_cmd './legit.pl ls-files -s'
execute_cmd 'ls a b'

print_description '4.rm modified file not added'
execute_cmd 'echo a line 2 >> a'
execute_cmd './legit.pl rm --cached a'
execute_cmd './legit.pl rm a'

print_description '5.rm modified file added'
execute_cmd './legit.pl add a'
execute_cmd './legit.pl rm a'
execute_cmd './legit.pl rm --cached a'

print_description '6.rm modified file not added but same as head'
execute_cmd './legit.pl add a'
execute_cmd 'echo a line 1 > a'
execute_cmd './legit.pl rm a'
execute_cmd './legit.pl rm --cached a'

print_description '7.force rm'
execute_cmd './legit.pl rm --force --cached a'
execute_cmd './legit.pl ls-files'

print_description '8.rm modified file with added but no commit history'
execute_cmd './legit.pl add b'


# execute_cmd "./legit.pl commit -m 'second commit'"
# execute_cmd './legit.pl rm b'

execute_cmd 'rm -rf .legit a b'