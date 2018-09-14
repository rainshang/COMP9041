#!/bin/sh
start=$1
end=$2
file=$3
i=$start
rm "$file" 2> /dev/null
while [ $i -le $end ]
do
    echo $i >> "$file"
    i=$(expr $i + 1)
done