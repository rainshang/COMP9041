#!/bin/sh
for file in $@
do
    cat $file |
    grep '#include "[a-z]\+\.h"' |
    sed 's/^ *#include "//' |
    sed 's/" *$//' |
    while read line
    do
        if [ ! -e $line ]
        then
            echo "$line included into $file does not exist"
        fi
    done
done