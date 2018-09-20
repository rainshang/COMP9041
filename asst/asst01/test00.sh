#!/bin/sh

# test working well in current directory
rm -rf .legit
./legit.pl init
ls -d .legit
./legit.pl init
rm -rf .legit

# test working well in other directory
mkdir subdir
cd subdir
pwd
../legit.pl init
../legit.pl init
cd ..
pwd
rm -rf subdir

# test invalid filename
./legit.pl add
./legit.pl add .
./

# test invalid filename
current=`pwd`
cd ..
touch a
cd "$current"
./legit.pl add ../a
rm ../a

# test add
touch a b c
./legit.pl add a
./legit.pl ls-files -s
echo new content > a
./legit.pl add a
./legit.pl ls-files -s
./legit.pl add *
./legit.pl ls-files -s
