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


print_title 'legit.pl branch [-d] [branch-name]'
execute_cmd './legit.pl init'

print_description '1.ls all branches'
execute_cmd 'touch a'
execute_cmd './legit.pl add a'
execute_cmd "./legit.pl commit -m 'first commit'"
execute_cmd './legit.pl branch'

print_description '2.arguments errors'
execute_cmd './legit.pl branch -d'
execute_cmd './legit.pl branch b1 b2'

print_description '3.duplicated branch'
execute_cmd './legit.pl branch master'

print_description '4.create branch'
execute_cmd './legit.pl branch b1'
execute_cmd './legit.pl branch s1'
execute_cmd './legit.pl branch'

print_description '5.delete branch'
execute_cmd './legit.pl branch -d s1'
execute_cmd './legit.pl branch'

print_description '6.delete current branch'
execute_cmd './legit.pl branch -d master'

execute_cmd 'rm -rf .legit'