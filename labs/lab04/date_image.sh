#!/bin/sh
for file in $@
do
    date=`ls -l $file | cut -d' ' -f5- | sed 's/^ *[0-9]* //g' | cut -d' ' -f1-3`
    convert -gravity south -pointsize 36 -draw "text 0,10 '$date'" $file tmp.jpg
    mv tmp.jpg $file
done