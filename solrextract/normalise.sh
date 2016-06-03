#!/bin/bash

# Normalises text: Lowercases letters, removes punctuation, ensures 1 word/line, no empty lines

function usage() {
    echo "./normalise.sh inputfile*"
    echo ""
    echo "inputfile: Play on gzipped text"
    exit
}

if [ "." == "$1" ]; then
    usage
fi

for FILE in $@; do
    if [ -s "$FILE" ]; then
        less $FILE | tr '[:upper:]' '[:lower:]' | tr -d '[:punct:]' | tr -s ' ' '\n' | grep -v "^$"
    else
        echo "No content for $FILE" 1>&2
    fi
done
