#!/bin/sh
for file in "$@"
do
    display "$file"
done
echo -n 'Address to e-mail this image to? '
read email
echo -n 'Message to accompany image? '
read msg
for file in "$@"
do
    file_name=`echo "$file" | sed -n 's/\...*$//gp'`
    #if echo "$msg" | sed 's/ //g' | egrep -i "$file_name" > /dev/null
    #then
    if echo "$msg" | mutt -s "$file_name!" -e 'set copy=no' -a "$file" -- "$email"
    then
        echo "$file sent to $email"
    else
        echo "$file CANNOT sent to $email"
    fi
    #fi
done