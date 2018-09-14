#!/bin/sh
for file in *
do
    file_name=`echo $file | sed -n 's/\.jpg$//gp'`
    if [ -n "$file_name" ]
    then
        if [ -e "./$file_name.png" ]
        then
            echo "$file_name.png already exists"
            exit 1
        else
            convert "$file" "$file_name.png"
            rm "$file"
        fi
    fi
done