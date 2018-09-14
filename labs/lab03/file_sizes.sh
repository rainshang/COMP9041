#!/bin/sh
for file in *
do
    line=$(cat $file | wc -l)
    if test $line -lt 10
    then
        sf=$sf" $file"
    elif test $line -lt 100
    then
        mf=$mf" $file"
    else
        lf=$lf" $file"
    fi
done
echo 'Small files:'$sf
echo 'Medium-sized files:'$mf
echo 'Large files:'$lf