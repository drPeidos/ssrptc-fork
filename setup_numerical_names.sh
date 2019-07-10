#!/bin/bash

i=2

# set $i to the the highest numbered folder + 1
for h in $(find . -mindepth 1 -maxdepth 1 -type d -name "[0-9][0-9]" -o -name "[0-9][0-9][0-9]" | awk -F'/' '{print $NF}'); do 
    [ $i -le $h ] && i=$(expr $h + 1)
done


SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

# if using a menu that doesnt sort, add sorting to the output of the find command below

for n in $(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | egrep -v '[0-9][0-9]$|[0-9][0-9][0-9]$' | sort); do
    echo "ORIGINAL_DIRECTORY_NAME=\"$n\"" > "./$n/ofn.txt"
    export p="$(printf "%02d\n" $i)"
    mv -v "$n" $p
    let "i+=1"
done

IFS=$SAVEIFS
