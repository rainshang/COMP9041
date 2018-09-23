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


print_title 'legit.pl status'
execute_cmd './legit.pl init'

print_description '1.no commit'
execute_cmd './legit.pl status'

print_description '2.same as repo'
execute_cmd 'touch a'
execute_cmd './legit.pl add a'
execute_cmd "./legit.pl commit -m 'first commit'"
execute_cmd './legit.pl status'

print_description '2.untracked'
execute_cmd 'touch b'
execute_cmd './legit.pl status'

print_description '3.added to index'
execute_cmd './legit.pl add b'
execute_cmd './legit.pl status'

print_description '4.changes not staged for commit'
execute_cmd 'echo a > a'
execute_cmd './legit.pl status'

print_description '5.changes staged for commit'
execute_cmd './legit.pl add a'
execute_cmd './legit.pl status'

print_description '6.different changes staged for commit'
execute_cmd 'echo aa > a'
execute_cmd './legit.pl status'

print_description '7.file deleted'
execute_cmd "./legit.pl commit -m 'second commit'"
execute_cmd 'rm a'
execute_cmd './legit.pl status'

print_description '8.deleted'
execute_cmd './legit.pl rm a'
execute_cmd './legit.pl status'

execute_cmd 'rm -rf a b .legit'