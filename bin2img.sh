#!/bin/bash

#find . -iname "*.bin" | sort | xargs -0 -I {} sh -c 'echo "{}"; cat "{}" >> out.img;'

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

for i in $(LANG=C; find . -iname "*.bin" | sort); do 
    echo "$i"
    cat "$i" >> out.img;
done
IFS=$SAVEIFS
