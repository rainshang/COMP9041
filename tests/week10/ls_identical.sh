#!/bin/sh
ls "$1" |
sort |
while read file1
do
    ls "$2" |
    sort |
    while read file2
    do
        if [ "$file1" = "$file2" ]
        then
            content1=`cat "$1/$file1"`
            content2=`cat "$2/$file2"`
            if [ "$content1" = "$content2" ]
            then
                echo "$file1"
            fi
        fi
    done
done