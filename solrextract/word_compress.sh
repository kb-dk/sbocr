#!/bin/bash

# Takes text output from normalise.sh and extracts unique words and their count.


function usage() {
    echo "./word_compress.sh inputfile*"
    echo ""
    echo "inputfile: Output from normalise.sh"
    exit
}

for FILE in $@; do
    if [ -s "$FILE" ]; then
        less "$FILE" | sort | uniq -c
    fi
done
