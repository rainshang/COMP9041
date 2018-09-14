#!/bin/sh
cat "$1" |
grep 'COMP[29]041' |
cut -d'|' -f3 |
sed 's/^[A-Z][a-z]\+, //' |
cut -d' ' -f1 |
sort |
uniq -c |
sort -bnr |
head -1 |
rev |
cut -d' ' -f1 |
rev