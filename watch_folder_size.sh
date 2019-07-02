#!/bin/bash


WATCH_DIR='.'
SD_SIZE='127865454592'


while true; do
    DIR_SIZE="$(du -b "$WATCH_DIR" | tail -1 | awk '{print $1}')"
    PERCENTAGE="$(echo "$DIR_SIZE / $SD_SIZE" | bc -l)"
    echo -ne " $PERCENTAGE %  \r"
    sleep 1s
done
