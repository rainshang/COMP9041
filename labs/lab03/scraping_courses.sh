#!/bin/sh
u_url='http://www.handbook.unsw.edu.au/vbook2018/brCoursesByAtoZ.jsp?StudyLevel=Undergraduate&descr='
p_url='http://www.handbook.unsw.edu.au/vbook2018/brCoursesByAtoZ.jsp?StudyLevel=Postgraduate&descr='
in_pair=false
((wget -q -O- $u_url$1) && (wget -q -O- $p_url$1)) | grep '<TD .*'$1 | sed 's/<[^>]\+>//g' | sed 's/^[[:space:]]*//' |
while read -r line
do
    if $in_pair
    then
        echo $output' '$line >> tmp
        in_pair=false
    else
        output=$line
        in_pair=true
    fi
done
cat tmp | sort | uniq
rm tmp