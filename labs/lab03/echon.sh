#!/bin/sh
if test $# -ne 2
then
    echo "Usage: $0 <number of lines> <string>"
else
    if echo $1 | egrep '^[0-9]+$' > /dev/null
    then
        i=0
        while test "$i" -lt "$1"
        do
            echo $2
            i=$(expr $i + 1)
        done
    else
        echo "$0: argument 1 must be a non-negative integer"
    fi
fi