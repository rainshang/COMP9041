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
    echo ${green}$1${reset}
    if [ ! $2 ]
    then
    $1
    fi
}


print_title 'legit.pl show <commit>:<filename>'
execute_cmd './legit.pl init'
execute_cmd 'echo line 1 > a' 1
echo line 1 > a
execute_cmd 'echo hello world > b' 1
echo hello world > b
execute_cmd './legit.pl add a b'
execute_cmd "./legit.pl commit -m 'first commit'" 1
./legit.pl commit -m 'first commit'
execute_cmd 'echo line 2 >> a' 1
echo line 2 >> a
execute_cmd './legit.pl add a'
execute_cmd "./legit.pl commit -m 'second commit'" 1
./legit.pl commit -m 'second commit'
execute_cmd 'echo line 3 >> a' 1
echo line 3 >> a
execute_cmd './legit.pl add a'
execute_cmd 'echo line 4 >> a' 1
echo line 4 >> a

print_description '1.not acceptable arguments'
execute_cmd './legit.pl show'
execute_cmd './legit.pl show afaf:'
execute_cmd './legit.pl show afaf:a'
execute_cmd './legit.pl show 0:../../a'

print_description '2.commit not found'
execute_cmd './legit.pl show 3:a'

print_description '3.file not found'
execute_cmd './legit.pl show 0:c'

print_description '4.normal'
execute_cmd './legit.pl show 0:a'
execute_cmd './legit.pl show 1:a'
execute_cmd './legit.pl show 0:b'
execute_cmd './legit.pl show 1:b'

print_description '4.omitted commit'
execute_cmd './legit.pl show :a'
execute_cmd 'cat a'

execute_cmd 'rm a'
execute_cmd 'rm b'
execute_cmd 'rm -rf .legit'