#!/bin/sh
cat "$1" |
sed -n 's/^.*"name": "\(.*\)", .*$/\1/p' |
sort |
uniq