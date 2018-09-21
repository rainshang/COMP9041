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

print_title 'legit.pl commit [-a] -m <message>'
execute_cmd './legit.pl init'
print_description '1.no commit, legit.pl log'
execute_cmd './legit.pl log'
print_description '2.argv errors'
execute_cmd './legit.pl commit -m'
execute_cmd './legit.pl commit -m hi space'
print_description '3.commet with no add'
execute_cmd "./legit.pl commit -m 'commet with no add'" 1
./legit.pl commit -m 'commet with no add'
print_description '4.legit.pl commit -m <message>'
execute_cmd 'echo line 1 > a' 1
echo line 1 > a
execute_cmd './legit.pl add a'
execute_cmd "./legit.pl commit -m 'first commit'" 1
./legit.pl commit -m 'first commit'
print_description '5.modify added file, commit without adding'
execute_cmd 'echo line 2 >> a' 1
echo line 2 >> a
execute_cmd "./legit.pl commit -m 'try second commit'" 1
./legit.pl commit -m 'try second commit'
print_description '6.add not modified file and commit'
execute_cmd './legit.pl add a'
execute_cmd "./legit.pl commit -m 'second commit'" 1
./legit.pl commit -m 'second commit'
execute_cmd './legit.pl add a'
execute_cmd "./legit.pl commit -m 'try third commit'" 1
./legit.pl commit -m 'try third commit'
print_description '7.legit.pl commit -a -m <message>'
execute_cmd 'touch b'
execute_cmd './legit.pl add b'
execute_cmd 'echo line 3 with b >> a' 1
echo line 3 with b >> a
execute_cmd 'echo line 3 with a >> b' 1
echo line 3 with a >> b
execute_cmd './legit.pl ls-files -s'
execute_cmd "./legit.pl commit -a -m 'add all'" 1
./legit.pl commit -a -m 'add all'
execute_cmd './legit.pl ls-files -s'
print_description '8.legit.pl log'
execute_cmd './legit.pl log'
execute_cmd 'rm a'
execute_cmd 'rm b'
execute_cmd 'rm -rf .legit'
