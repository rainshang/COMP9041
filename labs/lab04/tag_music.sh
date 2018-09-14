#!/bin/sh
for directory in "$@"
do
    directory=`echo $directory | sed 's/\/$//g'`
    album_year=`echo $directory | sed 's/^.*music\///g'`
    album=`echo $album_year | cut -d',' -f1`
    year=`echo $album_year | cut -d',' -f2 | sed 's/^ //g'`
    ls "$directory" |
    while read file
    do
        track_title_artist=`echo $file | sed 's/\.mp3$//g'`
        track=`echo $track_title_artist | grep -o '^[0-9]* '`
        title=`echo $track_title_artist | grep -o '\- .* \-' | sed -e 's/^- //g' -e 's/ -$//g'`
        artist=`echo $track_title_artist | sed 's/.* - .* - //g'`
        id3 -t "$title" -a "$artist" -A "$album_year" -y "$year" -T "$track" "$directory/$file" > /dev/null
    done
done