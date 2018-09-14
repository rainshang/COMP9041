#!/bin/sh
ls *.htm |
while read line
do
    if [ -e "$line"l ]
    then
        echo "$line"l exists
        exit 1
    fi
    mv "$line" "$line"l
done