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


print_title 'legit init'

print_description '1.test in current directory'
rm -rf .legit
execute_cmd './legit.pl init'
execute_cmd 'ls -d .legit'
execute_cmd './legit.pl init'
execute_cmd 'rm -rf .legit'

print_description '2.test in other directory'
execute_cmd 'mkdir subdir'
execute_cmd 'cd subdir'
execute_cmd '../legit.pl init'
execute_cmd 'ls -d .legit'
execute_cmd '../legit.pl init'
execute_cmd 'cd ..'
execute_cmd 'rm -rf subdir'


print_title 'legit.pl add <filenames...>'
execute_cmd './legit.pl init'

print_description '1.test invalid filename'
execute_cmd './legit.pl add'
execute_cmd './legit.pl add .'
execute_cmd './legit.pl add ./'
execute_cmd './legit.pl add .a'
execute_cmd './legit.pl add _a'
execute_cmd './legit.pl add -a'

print_description '2.test invalid filename (not in current repository)'
current=`pwd`
execute_cmd 'pwd'
execute_cmd 'cd ..'
execute_cmd 'touch a'
execute_cmd "cd $current"
execute_cmd './legit.pl add ../a'
execute_cmd 'rm ../a'

print_description '3.test multi add'
execute_cmd 'echo line 1 > a'
execute_cmd './legit.pl add a'
execute_cmd './legit.pl ls-files -s'
execute_cmd 'echo line 2 >> a'
execute_cmd './legit.pl add a'
execute_cmd './legit.pl ls-files -s'
execute_cmd './legit.pl add a'
execute_cmd './legit.pl ls-files -s'

print_description '4.test add subdir file'
execute_cmd 'mkdir subdir'
execute_cmd 'touch subdir/b'
execute_cmd './legit.pl add subdir/b'
execute_cmd './legit.pl ls-files'

print_description '5.test add and delete add'
execute_cmd './legit.pl ls-files'
execute_cmd 'rm a'
execute_cmd './legit.pl add a'
execute_cmd './legit.pl ls-files'

execute_cmd 'rm -rf a subdir .legit'
