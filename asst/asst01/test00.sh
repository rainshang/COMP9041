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
