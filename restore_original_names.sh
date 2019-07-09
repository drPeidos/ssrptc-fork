#!/bin/bash


for i in $(find . -mindepth 1 -maxdepth 1 -type d -name "[0-9][0-9]" -o -name "[0-9][0-9][0-9]"| egrep -v '^./01$'); do

    source $i/ofn.txt
    mv -v $i "$ORIGINAL_DIRECTORY_NAME"

 done
