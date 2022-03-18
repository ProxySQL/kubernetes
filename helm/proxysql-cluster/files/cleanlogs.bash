#!/bin/bash
set -e

TAIL_CMD=$(($KEEP_FILES+1))

cd $DIR

while true
do
    ls -tp | grep -v '/$' | tail -n +$TAIL_CMD | while read line
    do
        echo "Removing file $line"
        rm $line
    done
    sleep 5
done
