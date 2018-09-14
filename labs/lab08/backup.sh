#!/bin/sh
fileName=$1
maxVersion=`ls ".$fileName."* 2> /dev/null |
cut -d'.' -f4 |
sort -nr |
head -1`
if [ -z $maxVersion ]
then
    maxVersion=0
else
    maxVersion=$(expr $maxVersion + 1)
fi
cp "$fileName" ".$fileName.$maxVersion"
echo "Backup of '$fileName' saved as '.$fileName.$maxVersion'"
